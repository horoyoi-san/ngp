local MessageConfig = LTConfig.MessageConfig
local CinemaMovieConfig = LTConfig.CinemaMovieConfig
local CinemaLocationConfig = LTConfig.CinemaLocationConfig
local CinemaConfig = LTConfig.CinemaConfig
local NPCChatGamePlayTypeConfig = LTConfig.NPCChatGamePlayTypeConfig
local MoneyType = UX.Game.MoneyType
local CS_CinemaManager = LX6.CinemaManager
local CS_CinemaNode = LX6.CinemaManager.CinemaNode
C_CinemaMainPanelStore = DefClass("C_CinemaMainPanelStore", C_CinemaMainPanelStore, C_StoreGroup)
GroupName2Class.CinemaMainPanelStore = C_CinemaMainPanelStore
local M = C_CinemaMainPanelStore

function M:ctor()
	self:InitData()
end

function M:InitData()
	self.CONTROL_TYPE = {
		FALSE = 0,
		TRUE = 1
	}
	self.SORT_TYPE = {
		WATCHED = 4,
		NAME = 1,
		PRICE = 3,
		RELEASE_TIME = 2
	}
	self.PAGE_BTN_TYPE = {
		RIGHT = 2,
		BOTH = 3,
		LEFT = 1,
		NONE = 0
	}
	self.INVITE_BTN_TYPE = {
		INVITE = 3,
		SINGLE = 1,
		BOTH = 2,
		NONE = 0
	}
end

function M:OnAwake()
	self.CountPerPage = 5
	self.sortIncrease = true
	self.IsGetWatchedData = false
	local sortNames = CinemaConfig.CinemaSortName
	self.instance = {
		companionNpcId = 0,
		pageChangeCb = self:CreateAction("OnMoviePageChange"),
		movieList = {},
		sorterList = {
			{
				Name = sortNames[1],
				Type = self.SORT_TYPE.NAME
			},
			{
				Name = sortNames[2],
				Type = self.SORT_TYPE.RELEASE_TIME
			},
			{
				Name = sortNames[3],
				Type = self.SORT_TYPE.PRICE
			},
			{
				Name = sortNames[4],
				Type = self.SORT_TYPE.WATCHED
			}
		}
	}
	self.bindData.movieList.luaRenderItem = self:CreateAction("OnMovieListItemRender")
	self.bindData.movieList.luaSelectedChanged = self:CreateAction("OnMovieSelectChange")

	self.bindData.movieList:RegisterToPageEvent(self.instance.pageChangeCb)

	self.bindData.posterTagList.luaRenderItem = self:CreateAction("OnPosterTagItemRender")
	self.bindData.sorterList.luaRenderItem = self:CreateAction("OnSortListItemRender")
	self.bindData.sorterList.luaClick = self:CreateAction("OnSortListClick")
	self.bindData.btnSort.luaClick = self:CreateAction("SwitchSortMode")
	self.bindData.btnFilter.luaClick = self:CreateAction("OpenSortDropMenu")
	self.bindData.btnSortList.luaClick = self:CreateAction("OpenSortDropMenu")
	self.bindData.btnSortBg.luaClick = self:CreateAction("CloseSortDropMenu")
	self.bindData.btnBack.luaClick = self:CreateAction("OnBtnBackClick")
	self.bindData.btnPageLeft.luaClick = self:CreateAction("OnBtnPageLeftClick")
	self.bindData.btnPageRight.luaClick = self:CreateAction("OnBtnPageRightClick")
	self.bindData.btnAloneMobile.luaClick = self:CreateAction("OnBtnAloneClick")
	self.bindData.btnAlonePC.luaClick = self:CreateAction("OnBtnAloneClick")
	self.bindData.btnInviteMobile.luaClick = self:CreateAction("OnBtnInviteClick")
	self.bindData.btnInvitePC.luaClick = self:CreateAction("OnBtnInviteClick")

	function self.SortByName(a, b)
		if a.tIndex == 1 then
			return false
		end

		if b.tIndex == 1 then
			return true
		end

		if self.sortIncrease then
			return a.Pinyin < b.Pinyin
		else
			return b.Pinyin < a.Pinyin
		end
	end

	function self.SortByRelease(a, b)
		if a.tIndex == 1 then
			return false
		end

		if b.tIndex == 1 then
			return true
		end

		if self.sortIncrease then
			if a.Release == b.Release then
				return a.Pinyin < b.Pinyin
			end

			return a.Release < b.Release
		else
			if a.Release == b.Release then
				return b.Pinyin < a.Pinyin
			end

			return b.Release < a.Release
		end
	end

	function self.SortByWatched(a, b)
		if a.tIndex == 1 then
			return false
		end

		if b.tIndex == 1 then
			return true
		end

		if self.sortIncrease then
			if a.Watched == b.Watched then
				return a.Pinyin < b.Pinyin
			end

			return a.Watched < b.Watched
		else
			if a.Watched == b.Watched then
				return b.Pinyin < a.Pinyin
			end

			return b.Watched < a.Watched
		end
	end

	function self.SortByPrice(a, b)
		if a.tIndex == 1 then
			return false
		end

		if b.tIndex == 1 then
			return true
		end

		if self.sortIncrease then
			if a.Price == b.Price then
				return a.Pinyin < b.Pinyin
			end

			return a.Price < b.Price
		else
			if a.Price == b.Price then
				return b.Pinyin < a.Pinyin
			end

			return b.Price < a.Price
		end
	end

	self.msgEvents = {
		[gEventConstants.CINEMA_INVITE_NPC] = function (eventId, npcId)
			local movieData = self.instance.movieList[self.currSelectMovieIndex]

			if movieData and movieData.tIndex == 0 then
				self.clickProtect = true

				self:CinemaInviteNPC(self.locationId, movieData.cfg.Id, npcId, function (err, data)
					self.clickProtect = false

					if err ~= MessageConfig.Ok then
						gDisplayMessageMgr:ShowMessage(err)

						return
					end

					gPanelManager:Close(gPanelId.S_CINEMA_MAIN_PANEL)
				end)
			end
		end
	}
end

function M:OnShow(panelId, data)
	if data and type(data) == "userdata" then
		data = data:ToTable()
		data = {
			cinemaId = data[1],
			locationId = data[2],
			NpcCultivationId = data[3],
			hideExitBtn = data[4]
		}

		if #data >= 5 then
			data.closeCb = data[5]
		end
	end

	self:RegisterMessageEvents(self.msgEvents)

	if not data then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900334).Text)

		for i = 0, CinemaConfig.count - 1 do
			if CinemaConfig.LoadAt(i) then
				self.cinemaId = CinemaConfig.LoadAt(i).Id

				break
			end
		end

		self.locationId = 0
		self.instance.companionNpcId = gNpcFavorManager:GetInviteRideNpcCultivationId()
		self.hideExitBtn = false
	else
		self.cinemaId = data.cinemaId
		self.locationId = data.locationId

		if not data.NpcCultivationId or data.NpcCultivationId == 0 then
			self.instance.companionNpcId = gNpcFavorManager:GetInviteRideNpcCultivationId()
		else
			self.instance.companionNpcId = data.NpcCultivationId
		end

		self.closeCb = data.closeCb
		self.hideExitBtn = data.hideExitBtn or false
	end

	self:InitSorter()
	self.SubGroup.MoneyTemplateStore:SetData(MoneyType.Money)

	self.bindData.sortCtrl = self.sortIncrease and self.CONTROL_TYPE.FALSE or self.CONTROL_TYPE.TRUE
	self.bindData.showExitBtn = not self.hideExitBtn
	local canShowInviteBtn = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.Favorability)
	canShowInviteBtn = canShowInviteBtn and gSpiritManager:CheckIsMainCharacter()
	self.bindData.inviteBtnType = canShowInviteBtn and self.INVITE_BTN_TYPE.BOTH or self.INVITE_BTN_TYPE.SINGLE

	self:GetTaskInfo()
	self:GetCinemaQueryInfo(self.locationId)
end

function M:OnClose()
	self:ClearMessageEvents()

	self.IsGetWatchedData = false
	self.clickProtect = false
	self.MaxPage = nil

	if self.closeCb then
		self.closeCb()

		self.closeCb = nil
	end
end

function M:OnDestroy()
	if self.instance.closePanelTimer then
		self.instance.closePanelTimer:Stop()
	end

	self.bindData.movieList:UnRegisterToPageEvent(self.instance.pageChangeCb)

	self.IsGetWatchedData = nil
	self.sortIncrease = nil
	self.msgEvents = nil
	self.instance = nil
end

function M:InitMovieList(unlockMovies)
	local allUnlock = unlockMovies == nil
	local movieIds = self.cinemaId and CinemaConfig.GetConfig(self.cinemaId).Movies or {}

	for _, id in ipairs(movieIds) do
		local cfg = CinemaMovieConfig.GetConfig(id)
		local unlocked = allUnlock or table.find(unlockMovies, id) ~= nil

		if cfg and unlocked then
			local movie = {
				cfg = cfg,
				Type = cfg.type,
				IsWatched = false,
				Watched = 0,
				TagList = {},
				Release = cfg.Time or 0,
				Pinyin = gCS.LuaUtils.GetPinYinShortName(cfg.Name),
				Price = cfg.Price,
				tIndex = 0
			}

			for _, tag in ipairs(cfg.type) do
				table.insert(movie.TagList, {
					TagName = CinemaConfig.TypeName[tag].descript
				})
			end

			table.insert(self.instance.movieList, movie)
		end
	end

	self.movieCount = #self.instance.movieList
	self.CountPerPage = gCS.LuaUtils.IsNonMobileAdaptive() and 5 or 4
	self.MaxPage = math.ceil(self.movieCount / self.CountPerPage)

	for i = self.movieCount + 1, self.CountPerPage * self.MaxPage do
		table.insert(self.instance.movieList, {
			tIndex = 1
		})
	end

	self.clickProtect = false

	gClientToGameSceneDelegate:AskHaveSeenCinema().Callback = function (err, data)
		if err == MessageConfig.Ok then
			if self.STATE_EnableOnce then
				data = data or {}

				for idx, movie in ipairs(self.instance.movieList) do
					if movie.tIndex == 0 and table.contains(data, movie.Id) then
						movie.IsWatched = true
						movie.Watched = 1

						self.bindData.movieList:SetElement(idx - 1, movie)
					end
				end

				self.IsGetWatchedData = true
			end
		else
			gDisplayMessageMgr:ShowMessage(err)
		end
	end

	self:OnSortChange(1)
end

function M:GetTaskInfo()
	local taskId = gTaskManager:GetCurTask()

	if taskId and taskId ~= 0 then
		local hasWorkAction, npcId, movieId = gCS.LuaUtils.GetCinemaWorkAction(taskId, 0, 0)

		if not hasWorkAction or movieId == 0 then
			return
		end

		self.instance.targetMovieId = movieId
		self.instance.companionNpcId = npcId
		self.bindData.inviteBtnType = npcId == 0 and self.INVITE_BTN_TYPE.SINGLE or self.INVITE_BTN_TYPE.INVITE
	end
end

function M:GetCinemaQueryInfo(locationId)
	self.bindData.buyTicketBtnRoot:SetActive(false)

	gClientToGameSceneDelegate:AskCinemaQueryInfo(locationId).Callback = function (err, data)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			self:InitMovieList(nil)
		else
			local ticket = data.TicketInfo

			if ticket == nil then
				self.bindData.ticketCtrl = 0
				self.instance.currentTicketInfo = nil
				self.instance.hasTaskTicket = false
			else
				self.instance.currentTicketInfo = ticket
				self.instance.hasTaskTicket = ticket.IsTask

				if ticket.CompanionNpcId > 0 then
					self.bindData.ticketCtrl = 2
				else
					self.bindData.ticketCtrl = 1
				end
			end

			self:InitMovieList(data.UnlockMovies)
		end
	end
end

function M:OnSortChange(index)
	local info = self.instance.sorterList[index]
	self.bindData.pageBtnCtrl = self.CountPerPage < self.movieCount and self.PAGE_BTN_TYPE.RIGHT or self.PAGE_BTN_TYPE.NONE
	self.currSortIndex = index
	self.bindData.sortLabel = info.Name

	self:SortMovieByType(info.Type, self.instance.movieList)
	self.bindData.movieList:SetList(self.instance.movieList)

	self.currSelectMovieIndex = 0
	self.currPageIndex = 0

	if self.movieCount > 0 then
		self.bindData.movieList:GoToPage(0, true)
		self.bindData.movieList:SelectItem(0, true)
	else
		self:RefreshSelectMovie(nil)
	end
end

function M:RefreshSelectMovie(data)
	if data and data.tIndex == 0 and data.cfg then
		self.bindData.posterIconId = data.cfg.PosterS
		self.bindData.posterName = data.cfg.Name
		self.bindData.posterDescription = data.cfg.Description

		self.bindData.posterTagList:SetList(data.TagList)

		self.bindData.priceAlone = data.cfg.Price
		self.bindData.priceInvite = data.cfg.Price * 2
	else
		self.bindData.posterIconId = 0
		self.bindData.posterDescription = ""
		self.bindData.posterName = ""

		self.bindData.posterTagList:SetList(EMPTY_STORE_OBJECT)

		self.bindData.priceAlone = ""
		self.bindData.priceInvite = ""
	end

	if self.instance.hasTaskTicket then
		self.bindData.buyTicketBtnRoot:SetActive(false)

		return
	end

	local targetMovieId = self.instance.targetMovieId

	if targetMovieId ~= nil then
		local isTarget = (data.cfg or {}).Id == targetMovieId
		self.bindData.isMissionCtrl = isTarget and 0 or 1

		self.bindData.buyTicketBtnRoot:SetActive(isTarget)
	else
		self.bindData.buyTicketBtnRoot:SetActive(true)
	end
end

function M:InitSorter()
	self.bindData.sortListCtrl = self.CONTROL_TYPE.FALSE

	self.bindData.sorterList:SetList(self.instance.sorterList)
	self.bindData.sorterList:SelectItem(0, false)
end

function M:SortMovieByType(type, movieList)
	if type == self.SORT_TYPE.NAME then
		table.sort(movieList, self.SortByName)
	elseif type == self.SORT_TYPE.RELEASE_TIME then
		table.sort(movieList, self.SortByRelease)
	elseif type == self.SORT_TYPE.PRICE then
		table.sort(movieList, self.SortByPrice)
	elseif type == self.SORT_TYPE.WATCHED then
		table.sort(movieList, self.SortByWatched)
	end
end

function M:OnMovieSelectChange()
	self.currSelectMovieIndex = self.bindData.movieList.selectedIndex + 1

	self:RefreshSelectMovie(self.instance.movieList[self.currSelectMovieIndex])
end

function M:OnMoviePageChange(index)
	self.currPageIndex = index
	local ctrl = 0

	if index + 1 < self.MaxPage then
		ctrl = ctrl + 2
	end

	if index > 0 then
		ctrl = ctrl + 1
	end

	self.bindData.pageBtnCtrl = ctrl

	if gCS.LuaUtils.GetActiveDevice() <= SGUI.GameDevice.KeyboardMouse then
		self.bindData.movieList:SelectItem(self.CountPerPage * index, true)
	end
end

function M:OnMovieListItemRender(btn, index, data)
	if data.tIndex == 0 then
		local store = self:GetStoreByWidget(btn)

		if store then
			store.movieIconId = data.cfg and data.cfg.PosterL or 0
			store.watchedCtrl = data.IsWatched and self.CONTROL_TYPE.TRUE or self.CONTROL_TYPE.FALSE
			store.missionCtrl = (data.cfg or {}).Id == self.instance.targetMovieId and 1 or 0
		end
	end
end

function M:OnPosterTagItemRender(btn, index, data)
	local store = self:GetStoreByWidget(btn)

	if store then
		store.movieTag = data.TagName
	end
end

function M:OnSortListItemRender(btn, index, data)
	local store = self:GetStoreByWidget(btn)

	if store then
		store.movieSortType = data.Name
	end
end

function M:OnSortListClick(btn, data)
	self:CloseSortDropMenu()

	if self.currSortIndex == data.Type then
		return
	end

	self.sortIncrease = true

	self:OnSortChange(data.Type)
end

function M:SwitchSortMode()
	self.sortIncrease = not self.sortIncrease
	self.bindData.sortCtrl = self.sortIncrease and self.CONTROL_TYPE.FALSE or self.CONTROL_TYPE.TRUE

	self:OnSortChange(self.currSortIndex)
end

function M:OpenSortDropMenu()
	if not self.IsGetWatchedData then
		print_notice("观看数据还未拉取到，无法打开筛选列表")

		return
	end

	self.bindData.sortListCtrl = self.CONTROL_TYPE.TRUE
end

function M:CloseSortDropMenu()
	self.bindData.sortListCtrl = self.CONTROL_TYPE.FALSE
end

function M:OnBtnBackClick()
	gPanelManager:Close(gPanelId.S_CINEMA_MAIN_PANEL)
end

function M:OnBtnPageLeftClick()
	self.bindData.movieList:GoToPage(self.currPageIndex - 1, true)
end

function M:OnBtnPageRightClick()
	self.bindData.movieList:GoToPage(self.currPageIndex + 1, true)
end

function M:OnBtnAloneClick()
	if self.clickProtect then
		return
	end

	local movieData = self.instance.movieList[self.currSelectMovieIndex]

	if self.instance.currentTicketInfo == nil then
		self:BuySingleTicketImpl(movieData, false)
	else
		local currentTicket = {
			CinemaId = self.cinemaId,
			MovieId = self.instance.currentTicketInfo.MovieId,
			IsDouble = self.instance.currentTicketInfo.CompanionNpcId > 0
		}
		local newTicket = {
			IsDouble = false,
			CinemaId = self.cinemaId,
			MovieId = movieData.cfg.Id
		}

		self:ShowChangeTicketDialog(currentTicket, newTicket, function (moneyNeed)
			self:BuySingleTicketImpl(movieData, true, moneyNeed)
		end)
	end
end

function M:BuySingleTicketImpl(movieData, isChangeTicket, moneyNeed)
	if movieData and movieData.tIndex == 0 then
		local moneyEnough = nil

		if isChangeTicket then
			moneyEnough = moneyNeed <= gPlayerManager.infoItem.bindData.money
		else
			moneyEnough = movieData.Price <= gPlayerManager.infoItem.bindData.money
		end

		if not moneyEnough then
			gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900859).Text)

			return
		end

		self.clickProtect = true

		self:CinemaInviteNPC(self.locationId, movieData.cfg.Id, 0, function (err, data)
			if err ~= MessageConfig.Ok then
				gDisplayMessageMgr:ShowMessage(err)
			end

			self.clickProtect = false

			gPanelManager:Close(gPanelId.S_CINEMA_MAIN_PANEL)
		end)
	end
end

function M:OnBtnInviteClick()
	if self.clickProtect then
		return
	end

	local movieData = self.instance.movieList[self.currSelectMovieIndex]

	if self.instance.currentTicketInfo == nil then
		self:BuyDoubleTicketImpl(movieData, false)
	else
		local currentTicket = {
			CinemaId = self.cinemaId,
			MovieId = self.instance.currentTicketInfo.MovieId,
			IsDouble = self.instance.currentTicketInfo.CompanionNpcId > 0
		}
		local newTicket = {
			IsDouble = true,
			CinemaId = self.cinemaId,
			MovieId = movieData.cfg.Id
		}

		self:ShowChangeTicketDialog(currentTicket, newTicket, function (moneyNeed)
			self:BuyDoubleTicketImpl(movieData, true, moneyNeed)
		end)
	end
end

function M:BuyDoubleTicketImpl(movieData, isChangeTicket, moneyNeed)
	if movieData and movieData.tIndex == 0 then
		local moneyNeeded = nil

		if isChangeTicket then
			moneyNeeded = moneyNeed
		else
			moneyNeeded = movieData.Price * 2
		end

		if gPlayerManager.infoItem.bindData.money < moneyNeeded then
			gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900859).Text)

			return
		end

		self.clickProtect = true

		if self.instance.companionNpcId == 0 then
			gClientToGameDelegate:AskSimulationInviteNpc(NPCChatGamePlayTypeConfig.Cinema).Callback = function (err)
				gDisplayMessageMgr:DisplayServerMessageId(err)

				self.clickProtect = false
			end
		else
			self:CinemaInviteNPC(self.locationId, movieData.cfg.Id, self.instance.companionNpcId, function (err, data)
				self.clickProtect = false

				if err ~= MessageConfig.Ok then
					gDisplayMessageMgr:ShowMessage(err)

					return
				end

				gPanelManager:Close(gPanelId.S_CINEMA_MAIN_PANEL)
			end)
		end
	end
end

function M:CinemaInviteNPC(locationId, movieId, companionnpcid, cb)
	local cfg = CinemaLocationConfig.GetConfig(locationId)
	local npcId = 0

	if cfg then
		npcId = cfg.Npcid
	else
		print_error("电影院location配置 CinemaLocationConfig=" .. tostring(locationId) .. " 找不到配置！请策划检查")

		return
	end

	gClientToGameSceneDelegate:AskCinemaBuyTicket(locationId, movieId, npcId, companionnpcid).Callback = function (err, data)
		if err ~= MessageConfig.Ok then
			print_error("CinemaMainPanelStore AskCinemaBuyTicket error ,err:", tostring(err), ",locationId is :" .. tostring(locationId), "moveId is :", tostring(movieId), "companionnpcid is :" .. tostring(companionnpcid))

			if cb then
				cb(err, data)
			end

			return
		end

		if companionnpcid == nil or companionnpcid == 0 then
			CS_CinemaManager.Instance:RefreshTicketInfo(CS_CinemaNode.GoToGate, 0, true)
		else
			CS_CinemaManager.Instance:RefreshTicketInfo(CS_CinemaNode.CreateNPCAndPlayTimeline, 0, true)
		end

		local clipName = "S_CinemaMainPanel_Ticket_in"
		local buySuccessAnimClip = self.bindData.buyTicketAnimWidget.anim:GetClip(clipName)

		if buySuccessAnimClip then
			self.bindData.buyTicketAnimWidget:SetActive(true)
			self.bindData.buyTicketAnimWidget.anim:Play(clipName)

			self.instance.closePanelTimer = Timer.New(function ()
				if cb then
					cb(err, data)
				end
			end, buySuccessAnimClip.length)

			self.instance.closePanelTimer:Start()
		elseif cb then
			cb(err, data)
		end
	end
end

function M:ShowChangeTicketDialog(fromTicket, toTicket, callback)
	local fromCinemaCfg = CinemaConfig.GetConfig(fromTicket.CinemaId)
	local fromCinemaName = fromCinemaCfg.Name
	local fromMovie = CinemaMovieConfig.GetConfig(fromTicket.MovieId)
	local fromTicketCount = fromTicket.IsDouble and 2 or 1
	local fromTicketTypeName = fromTicket.IsDouble and CinemaConfig.DoubleTicketName or CinemaConfig.SingleTicketName
	local fromTicketPrice = fromMovie.Price * fromTicketCount
	local toCinemaCfg = CinemaConfig.GetConfig(toTicket.CinemaId)
	local toCinemaName = toCinemaCfg.Name
	local toMovie = CinemaMovieConfig.GetConfig(toTicket.MovieId)
	local toTicketCount = toTicket.IsDouble and 2 or 1
	local toTicketTypeName = toTicket.IsDouble and CinemaConfig.DoubleTicketName or CinemaConfig.SingleTicketName
	local toTicketPrice = toMovie.Price * toTicketCount
	local diffPrice = toTicketPrice - fromTicketPrice
	local money = diffPrice > 0 and diffPrice or 0

	local function rightCallback()
		callback(money)
	end

	local leftCallback = nil
	local mid = money == 0 and MessageConfig.ChangeCinemaTicketFree or MessageConfig.ChangeCinemaTicketPaid

	gDisplayMessageMgr:ShowMessage(mid, rightCallback, leftCallback, fromCinemaName, fromMovie.Name, fromTicketTypeName, toCinemaName, toMovie.Name, toTicketTypeName, money)
end
