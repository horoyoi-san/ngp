C_CinemaOLMainPanelStore = DefClass("C_CinemaOLMainPanelStore", C_CinemaOLMainPanelStore, C_StoreGroup)
GroupName2Class.CinemaOLMainPanelStore = C_CinemaOLMainPanelStore
local M = C_CinemaOLMainPanelStore
local MessageConfig = LTConfig.MessageConfig
local CinemaMovieConfig = LTConfig.CinemaMovieConfig
local CinemaConfig = LTConfig.CinemaConfig
local CinemaMutiplayerMovieTimeTableConfig = LTConfig.CinemaMutiplayerMovieTimeTableConfig
local CS_CinemaManager = LX6.CinemaManager

function M:ctor()
	return
end

function M:OnAwake()
	self.instance = {}
end

function M:OnShow(panelId, data)
	local cinemaId = data.cinemaId
	local locationId = data.locationId
	self.instance.panelId = panelId
	self.instance.data = data
	self.instance.cinemaId = cinemaId
	self.instance.locationId = locationId
	local clickAction = self:CreateAction(self.OnBuyBtnClick)
	self.bindData.buyBtnMobile.luaClick = clickAction
	self.bindData.buyBtnNonMobile.luaClick = clickAction
	self.bindData.exitBtn.luaClick = self:CreateAction(self.OnExitBtnClick)
	self.bindData.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderItem)

	self:InitView(cinemaId, locationId)
end

function M:InitView(cinemaId, locationId)
	self.SubGroup.MoneyTemplateStore:SetData(UX.Game.MoneyType.Money)

	local cinemaCfg = CinemaConfig.GetConfig(cinemaId)
	self.bindData.cinemaNameLeft = cinemaCfg.NameLeft
	self.bindData.cinemaNameRight = cinemaCfg.NameRight
	self.bindData.price = CinemaConfig.MultiCinemaTicketPrice

	self:AskCinemaInfo(locationId)
end

function M:OnDestroy()
	if self.instance.closePanelTimer then
		self.instance.closePanelTimer:Stop()
	end

	self.instance = nil
end

function M:AskCinemaInfo(locationId)
	gClientToGameSceneDelegate:AskMultiCinemaQueryInfo(locationId).Callback = function (err, info)
		if self.instance == nil then
			return
		end

		if err ~= MessageConfig.Ok or info == nil then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			print_error("AskMultiCinemaQueryInfo", locationId, "error", err, "info", info)

			return
		end

		self:UpdateTicketInfo(info.TicketInfo)
		self:SetMovieList(locationId, info)
	end
end

function M:SetMovieList(locationId, info)
	local cfg = CinemaMutiplayerMovieTimeTableConfig.GetConfig(locationId)

	if cfg == nil then
		print_error("CinemaMutiplayerMovieTimeTableConfig == nil", locationId, "info", info)

		return
	end

	local firstMovieId = info.LastestMovieId
	local v, k = table.find(cfg.AutoMovieList, firstMovieId)

	if v == nil then
		print_error("CinemaMutiplayerMovieTimeTableConfig", locationId, "not found firstMovieId", firstMovieId, "info", info)

		return
	end

	local firstMovieCfg = CinemaMovieConfig.GetConfig(firstMovieId)

	if gCS.TimeManager.ServerUnixTime <= info.LastestMovieStartTime + firstMovieCfg.VideoDuration then
		k = k + 1
	end

	local movieCount = #cfg.AutoMovieList - k + 1
	local movieList = table.createFixedArray(movieCount)

	for i = 1, movieCount do
		local index = i + k - 1
		local movieId = cfg.AutoMovieList[index]
		local movieCfg = CinemaMovieConfig.GetConfig(movieId)
		local h = (index - 1) * cfg.StartTime.interval
		local m = cfg.StartTime.starttime
		local time = string.format("%02d:%02d", h, m)
		movieList[i] = {
			id = movieId,
			time = time,
			cfg = movieCfg
		}
	end

	self.instance.movieList = movieList

	self.bindData.list:SetSimpleList(movieCount)
end

function M:UpdateTicketInfo(info)
	self.instance.ticketInfo = info
end

function M:OnExitBtnClick()
	gPanelManager:Close(self.instance.panelId)
end

function M:OnBuyBtnClick()
	local info = self.instance.ticketInfo

	if info == nil then
		self:AskBuyTicket()

		return
	end

	local function leftCallback()
		if self.instance then
			gPanelManager:Close(self.instance.panelId)
		end
	end

	gDisplayMessageMgr:ShowMessage(MessageConfig.ChangeOLCinemaTicket, leftCallback)
end

function M:AskBuyTicket()
	gClientToGameSceneDelegate:AskMultiCinemaBuyTicket(self.instance.locationId).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			if self.instance then
				self.instance.ticketInfo = {
					LocationId = self.instance.locationId,
					CinemaId = self.instance.cinemaId
				}
				local clipName = "S_CinemaMainPanel_Ticket_in"
				local buySuccessAnimClip = self.bindData.buyTicketAnimWidget.anim:GetClip(clipName)

				if buySuccessAnimClip then
					self.bindData.buyTicketAnimWidget:SetActive(true)
					self.bindData.buyTicketAnimWidget.anim:Play(clipName)

					self.instance.closePanelTimer = Timer.New(function ()
						gPanelManager:Close(self.instance.panelId)
					end, buySuccessAnimClip.length)

					self.instance.closePanelTimer:Start()
				else
					gPanelManager:Close(self.instance.panelId)
				end
			end

			CS_CinemaManager.Instance:RefreshMultiCinemaTicketInfo(0, true)
		end
	end
end

function M:OnRenderItem(btn, csIndex)
	local data = self.instance.movieList[csIndex + 1]
	local store = self:GetStoreByWidget(btn)
	store.imageId = data.cfg.PosterL
	store.time = data.time
end

function M:DefineAllEnumsAutoGen()
	return
end

function M:ClearAllEnumsAutoGen()
	return
end
