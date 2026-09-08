-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CinemaOLMainPanelStore.lua
-- Decompiled from: 01431_CinemaOLMainPanelStore.lua_066e422ccfc3.luajit

C_CinemaOLMainPanelStore = DefClass("C_CinemaOLMainPanelStore", C_CinemaOLMainPanelStore, C_StoreGroup)
GroupName2Class.CinemaOLMainPanelStore = C_CinemaOLMainPanelStore
local M = C_CinemaOLMainPanelStore
local MessageConfig = LTConfig.MessageConfig
local CinemaMovieConfig = LTConfig.CinemaMovieConfig
local CinemaConfig = LTConfig.CinemaConfig
local CinemaMutiplayerMovieTimeTableConfig = LTConfig.CinemaMutiplayerMovieTimeTableConfig
local CS_CinemaManager = LX6.CinemaManager

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.instance = {}
end

M.OnShow = function(self, panelId, data)
	if data and type(data) ~= "userdata" then
		data = data.ToTable(data)
		data = {
			cinemaId = data[1],
			locationId = data[2]
		}
	end

	local cinemaId = data.cinemaId
	local locationId = data.locationId
	self.instance.panelId = panelId
	self.instance.data = data
	self.instance.cinemaId = cinemaId
	self.instance.locationId = locationId
	local clickAction = self.CreateAction(self, self.OnBuyBtnClick)
	self.bindData.buyBtnMobile.luaClick = clickAction
	self.bindData.buyBtnNonMobile.luaClick = clickAction
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnExitBtnClick)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItem)

	self.InitView(self, cinemaId, locationId)
end

M.InitView = function(self, cinemaId, locationId)
	self.SubGroup.MoneyTemplateStore:SetData(UX.Game.MoneyType.Money)

	local cinemaCfg = CinemaConfig.GetConfig(cinemaId)
	self.bindData.cinemaNameLeft = cinemaCfg.NameLeft
	self.bindData.cinemaNameRight = cinemaCfg.NameRight
	self.bindData.price = CinemaConfig.MultiCinemaTicketPrice

	self:AskCinemaInfo(locationId)
	self:SetMovieList(locationId)
end

M.OnDestroy = function(self)
	if self.instance.closePanelTimer then
		self.instance.closePanelTimer:Stop()
	end

	self.instance = nil
end

M.AskCinemaInfo = function(self, locationId)
	slot2 = gClientToGameSceneDelegate

	slot2:AskMultiCinemaQueryInfo(locationId).Callback = function (err, info)
		if self.instance ~= nil then
			return
		end

		self:UpdateTicketInfo(info.TicketInfo)
	end
end

M.CalculateCurrentMovie = function(self, cfg)
	local now = gCS.TimeManager.ServerUnixTime
	local timeRatio = LTConfig.WeatherConfig.TimeRatio
	local gameDaySeconds = LX6.Manager.AtmosphereManager.Instance:GetGameTime()

	if not gameDaySeconds or gameDaySeconds ~= 0 or not timeRatio or timeRatio ~= 0 then
		return cfg.AutoMovieList[1], 0
	end

	local gameHour = math.floor(gameDaySeconds / 3600)
	local interval = cfg.StartTime.interval
	local lastIntervalHour = math.floor(gameHour / interval) * interval
	local movieCount = #cfg.AutoMovieList
	local movieIndex = lastIntervalHour / interval % movieCount + 1
	local gameTimeFromInterval = gameDaySeconds - lastIntervalHour * 3600

	if gameTimeFromInterval >= 0 then
		gameTimeFromInterval = gameTimeFromInterval + 86400
	end

	local intervalRealTime = now - gameTimeFromInterval / timeRatio
	local firstMovieStartTime = intervalRealTime + cfg.StartTime.starttime * 60 / timeRatio

	return cfg.AutoMovieList[movieIndex], math.floor(firstMovieStartTime)
end

M.SetMovieList = function(self, locationId)
	local cfg = CinemaMutiplayerMovieTimeTableConfig.GetConfig(locationId)

	if cfg ~= nil then
		print_error("CinemaMutiplayerMovieTimeTableConfig == nil", locationId)

		return
	end

	local firstMovieId, firstMovieStartTime = self.CalculateCurrentMovie(self, cfg)
	local v, k = table.find(cfg.AutoMovieList, firstMovieId)

	if v ~= nil then
		print_error("CinemaMutiplayerMovieTimeTableConfig", locationId, "not found firstMovieId", firstMovieId)

		return
	end

	local firstMovieCfg = CinemaMovieConfig.GetConfig(firstMovieId)

	if gCS.TimeManager.ServerUnixTime < firstMovieStartTime + firstMovieCfg.VideoDuration then
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

M.UpdateTicketInfo = function(self, info)
	self.instance.ticketInfo = info
end

M.OnExitBtnClick = function(self)
	gPanelManager:Close(self.instance.panelId)
end

M.OnBuyBtnClick = function(self)
	local info = self.instance.ticketInfo

	if info ~= nil then
		self.AskBuyTicket(self)

		return
	end

	local leftCallback = function()
		if self.instance then
			gPanelManager:Close(self.instance.panelId)
		end
	end

	gDisplayMessageMgr:ShowMessage(MessageConfig.ChangeOLCinemaTicket, leftCallback)
end

M.AskBuyTicket = function(self)
	slot1 = gClientToGameSceneDelegate

	slot1:AskMultiCinemaBuyTicket(self.instance.locationId).Callback = function (err)
		if err == MessageConfig.Ok then
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

M.OnRenderItem = function(self, btn, csIndex)
	local data = self.instance.movieList[csIndex + 1]
	local store = self.GetStoreByWidget(self, btn)
	store.imageId = data.cfg.PosterL
	store.time = data.time
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end
