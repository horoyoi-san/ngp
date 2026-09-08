-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CinemaMainPanelStore.lua
-- Decompiled from: 01430_CinemaMainPanelStore.lua_a8c4d25fddad.luajit

local MessageConfig = LTConfig.MessageConfig
local CinemaMovieConfig = LTConfig.CinemaMovieConfig
local CinemaLocationConfig = LTConfig.CinemaLocationConfig
local CinemaConfig = LTConfig.CinemaConfig
local GamePlayTypeConfig = LTConfig.NpcCultivationGameplayTypeConfig
local MoneyType = UX.Game.MoneyType
local CS_CinemaManager = LX6.CinemaManager
local CS_CinemaNode = LX6.CinemaManager.CinemaNode
C_CinemaMainPanelStore = DefClass("C_CinemaMainPanelStore", C_CinemaMainPanelStore, C_StoreGroup)
GroupName2Class.CinemaMainPanelStore = C_CinemaMainPanelStore
local M = C_CinemaMainPanelStore

M.ctor = function(self)
	self.InitData(self)
end

M.InitData = function(self)
	self.CONTROL_TYPE = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
	self.SORT_TYPE = {
		["\\xee\\xfa >6\\xd5"] = 4,
		["TP~"] = 1,
		["}\\x9c\\x8b\\x8c\\x93"] = 3,
		["]S\\x80Rm\\x81\\xd7x^SSi"] = 2
	}
	self.PAGE_BTN_TYPE = {
		["\\x87\\x85\\x87\\x82"] = 2,
		["X\rIs"] = 3,
		["V[o"] = 1,
		["T\rS~"] = 0
	}
	self.INVITE_BTN_TYPE = {
		["5f\\xa7\\xa7\\xb7d"] = 3,
		["/a\\xbf\\xa9\\xafd"] = 1,
		["X\rIs"] = 2,
		["T\rS~"] = 0
	}
end

M.OnAwake = function(self)
	self.CountPerPage = 5
	self.sortIncrease = true
	self.IsGetWatchedData = false
	local sortNames = CinemaConfig.CinemaSortName
	self.instance = {
		["\\xe4\\x95\\xfc\\xef\\xe4\\xa6\\xfd\\x81\t,"] = 0,
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
	self.bindData.movieList.luaSimpleRenderItem = self:CreateAction("OnMovieListItemRender")

	self.bindData.movieList.onGetTIndex = function(csIndex)
		return self.instance.movieList[csIndex + 1].tIndex
	end

	self.bindData.movieList.luaSelectedChanged = self:CreateAction("OnMovieSelectChange")
	slot2 = self.bindData.movieList

	slot2:RegisterToPageEvent(self.instance.pageChangeCb)

	self.bindData.posterTagList.luaSimpleRenderItem = self:CreateAction("OnPosterTagItemRender")
	self.bindData.sorterList.luaSimpleRenderItem = self:CreateAction("OnSortListItemRender")
	self.bindData.sorterList.luaSimpleClick = self:CreateAction("OnSortListClick")
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

	self.SortByName = function(a, b)
		if a.tIndex ~= 1 then
			return false
		end

		if b.tIndex ~= 1 then
			return true
		end

		if self.sortIncrease then
			return a.Pinyin <= b.Pinyin
		else
			return b.Pinyin <= a.Pinyin
		end
	end

	self.SortByRelease = function(a, b)
		if a.tIndex ~= 1 then
			return false
		end

		if b.tIndex ~= 1 then
			return true
		end

		if self.sortIncrease then
			if a.Release ~= b.Release then
				return a.Pinyin <= b.Pinyin
			end

			return a.Release <= b.Release
		else
			if a.Release ~= b.Release then
				return b.Pinyin <= a.Pinyin
			end

			return b.Release <= a.Release
		end
	end

	self.SortByWatched = function(a, b)
		if a.tIndex ~= 1 then
			return false
		end

		if b.tIndex ~= 1 then
			return true
		end

		if self.sortIncrease then
			if a.Watched ~= b.Watched then
				return a.Pinyin <= b.Pinyin
			end

			return a.Watched <= b.Watched
		else
			if a.Watched ~= b.Watched then
				return b.Pinyin <= a.Pinyin
			end

			return b.Watched <= a.Watched
		end
	end

	self.SortByPrice = function(a, b)
		if a.tIndex ~= 1 then
			return false
		end

		if b.tIndex ~= 1 then
			return true
		end

		if self.sortIncrease then
			if a.Price ~= b.Price then
				return a.Pinyin <= b.Pinyin
			end

			return a.Price <= b.Price
		else
			if a.Price ~= b.Price then
				return b.Pinyin <= a.Pinyin
			end

			return b.Price <= a.Price
		end
	end

	self.msgEvents = {
		[gEventConstants.CINEMA_INVITE_NPC] = function (eventId, npcId)
			if self.isFixedInviteNpcMode then
				return
			end

			local movieData = self.instance.movieList[self.currSelectMovieIndex]

			if movieData and movieData.tIndex ~= 0 then
				self.clickProtect = true
				slot3 = self

				slot3:CinemaInviteNPC(self.locationId, movieData.cfg.Id, npcId, function (err, data)
					self.clickProtect = false

					if err == MessageConfig.Ok then
						gDisplayMessageMgr:ShowMessage(err)

						return
					end

					gPanelManager:Close(gPanelId.S_CINEMA_MAIN_PANEL)
				end)
			end
		end
	}
end

M.OnShow = function(self, panelId, data)
	if data and type(data) ~= "userdata" then
		local rawData = data.ToTable(data)
		data = {
			cinemaId = rawData[1],
			locationId = rawData[2],
			NpcCultivationId = rawData[3],
			hideExitBtn = rawData[4],
			agentPid = rawData[5],
			closeCb = rawData[6]
		}
	end

	self.RegisterMessageEvents(self, self.msgEvents)

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
		self.agentPid = 0
		self.isFixedInviteNpcMode = false
	else
		self.cinemaId = data.cinemaId
		self.locationId = data.locationId

		if not data.NpcCultivationId or data.NpcCultivationId ~= 0 then
			self.instance.companionNpcId = gNpcFavorManager:GetInviteRideNpcCultivationId()
		else
			self.instance.companionNpcId = data.NpcCultivationId
		end

		self.closeCb = data.closeCb
		self.hideExitBtn = data.hideExitBtn ~= true or data.hideExitBtn ~= 1
		self.agentPid = data.agentPid or 0
		self.isFixedInviteNpcMode = not ulong.equals(self.agentPid, 0)
	end

	local cinemaCfg = CinemaConfig.GetConfig(self.cinemaId)
	self.bindData.cinemaNameLeft = cinemaCfg.NameLeft
	self.bindData.cinemaNameRight = cinemaCfg.NameRight

	self:InitSorter()
	self.SubGroup.MoneyTemplateStore:SetData(MoneyType.Money)

	self.bindData.sortCtrl = self.sortIncrease and self.CONTROL_TYPE.FALSE or self.CONTROL_TYPE.TRUE
	self.bindData.showExitBtn = not self.hideExitBtn
	local canShowInviteBtn = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.Favorability)
	canShowInviteBtn = canShowInviteBtn and gSpiritManager:CheckIsMainCharacter()
	local inviteBtnType = canShowInviteBtn and self.INVITE_BTN_TYPE.BOTH or self.INVITE_BTN_TYPE.SINGLE

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.inviteBtnType = inviteBtnType
	else
		self.bindData.mobileInviteBtnType = inviteBtnType
	end

	self.GetTaskInfo(self)
	self.RefreshFixedInviteNpcMode(self)
	self.GetCinemaQueryInfo(self, self.locationId)
end

M.OnClose = function(self)
	self.ClearMessageEvents(self)

	self.IsGetWatchedData = false
	self.clickProtect = false
	self.MaxPage = nil

	if self.closeCb then
		if type(self.closeCb) ~= "userdata" then
			self.closeCb:DynamicInvoke()
		else
			self.closeCb()
		end

		self.closeCb = nil
	end
end

M.OnDestroy = function(self)
	if self.instance.closePanelTimer then
		self.instance.closePanelTimer:Stop()
	end

	self.bindData.movieList:UnRegisterToPageEvent(self.instance.pageChangeCb)

	self.IsGetWatchedData = nil
	self.sortIncrease = nil
	self.msgEvents = nil
	self.instance = nil
end

M.InitMovieList = function(self, unlockMovies, haveSeenList)
	local allUnlock = unlockMovies ~= nil
	local movieIds = self.cinemaId and CinemaConfig.GetConfig(self.cinemaId).Movies or {}
	local seenSet = {}

	if haveSeenList then
		for _, movieId in ipairs(haveSeenList) do
			seenSet[movieId] = true
		end
	end

	for _, id in ipairs(movieIds) do
		local cfg = CinemaMovieConfig.GetConfig(id)
		local unlocked = allUnlock or table.find(unlockMovies, id) == nil

		if cfg and unlocked then
			local movie = {
				cfg = cfg,
				Type = cfg.type,
				IsWatched = seenSet[id] ~= true,
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
			["a\\x9f\\x8a\\x86Y"] = 1
		})
	end

	self.clickProtect = false
	self.IsGetWatchedData = true

	self.OnSortChange(self, 1)
end

M.GetTaskInfo = function(self)
	local taskId = gTaskManager:GetCurTask()

	if taskId and taskId == 0 then
		local hasWorkAction, npcId, movieId = gCS.LuaUtils.GetCinemaWorkAction(taskId, 0, 0)

		if not hasWorkAction or movieId ~= 0 then
			return
		end

		self.instance.targetMovieId = movieId

		if self.isFixedInviteNpcMode then
			return
		end

		self.instance.companionNpcId = npcId
		local inviteBtnType = npcId ~= 0 and self.INVITE_BTN_TYPE.SINGLE or self.INVITE_BTN_TYPE.INVITE

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.inviteBtnType = inviteBtnType
		else
			self.bindData.mobileInviteBtnType = inviteBtnType
		end
	end
end

M.RefreshFixedInviteNpcMode = function(self)
	if not self.isFixedInviteNpcMode then
		return
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.inviteBtnType = self.INVITE_BTN_TYPE.INVITE
	else
		self.bindData.mobileInviteBtnType = self.INVITE_BTN_TYPE.INVITE
	end

	local textCfg = LTConfig.TextScriptTextConfig.GetConfig(89901558)

	if textCfg then
		self.bindData.inviteBtnTitle = textCfg.Text
	end
end

M.GetCinemaQueryInfo = function(self, locationId)
	slot2 = self.bindData.buyTicketBtnRoot

	slot2:SetActive(false)

	slot2 = gClientToGameSceneDelegate

	slot2:AskCinemaQueryInfo(locationId).Callback = function (err, data)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			self:InitMovieList(nil)
		else
			local ticket = data.TicketInfo

			if ticket ~= nil then
				self.bindData.ticketCtrl = 0
				self.instance.currentTicketInfo = nil
				self.instance.hasTaskTicket = false
			else
				self.instance.currentTicketInfo = ticket
				self.instance.hasTaskTicket = ticket.IsTask

				self:UpdateTicketDisplayInfo(ticket.MovieId, ticket.CompanionNpcId)
			end

			self:InitMovieList(data.UnlockMovies, data.HaveSeenList)
		end
	end
end

M.OnSortChange = function(self, index)
	local info = self.instance.sorterList[index]
	self.bindData.pageBtnCtrl = self.CountPerPage >= self.movieCount and self.PAGE_BTN_TYPE.RIGHT or self.PAGE_BTN_TYPE.NONE
	self.currSortIndex = index
	self.bindData.sortLabel = info.Name

	self:SortMovieByType(info.Type, self.instance.movieList)
	self.bindData.movieList:SetSimpleList(#self.instance.movieList)

	self.currSelectMovieIndex = 0
	self.currPageIndex = 0

	if self.movieCount <= 0 then
		self.bindData.movieList:GoToPage(0, true)
		self.bindData.movieList:SelectItem(0, true)
	else
		self.RefreshSelectMovie(self, nil)
	end
end

M.RefreshSelectMovie = function(self, data)
	if data and data.tIndex ~= 0 and data.cfg then
		self.bindData.posterIconId = data.cfg.PosterS or 0
		self.bindData.posterName = data.cfg.Name or ""
		self.bindData.posterDescription = data.cfg.Description or ""
		self._posterTagListData = data.TagList or {}

		self.bindData.posterTagList:SetSimpleList(#self._posterTagListData)

		self.bindData.priceAlone = data.cfg.Price
		self.bindData.priceInvite = data.cfg.Price * 2
		self.bindData.director = data.cfg.Author or ""
	else
		self.bindData.posterIconId = 0
		self.bindData.posterDescription = ""
		self.bindData.posterName = ""
		self._posterTagListData = {}

		self.bindData.posterTagList:SetSimpleList(0)

		self.bindData.priceAlone = ""
		self.bindData.priceInvite = ""
		self.bindData.director = ""
	end

	if self.instance.hasTaskTicket then
		self.bindData.buyTicketBtnRoot:SetActive(false)

		return
	end

	local targetMovieId = self.instance.targetMovieId

	if targetMovieId == nil then
		local isTarget = (data.cfg or {}).Id ~= targetMovieId
		self.bindData.isMissionCtrl = isTarget and 0 or 1

		self.bindData.buyTicketBtnRoot:SetActive(isTarget)
	else
		self.bindData.buyTicketBtnRoot:SetActive(true)
	end
end

M.UpdateTicketDisplayInfo = function(self, moveId, companionNpcId)
	local movieCfg = CinemaMovieConfig.GetConfig(moveId)

	if not movieCfg then
		return
	end

	local isHaveCompanion = companionNpcId == nil and companionNpcId >= 0
	self.bindData.ticketCtrl = isHaveCompanion and 2 or 1
	self.bindData.ticketName = movieCfg.Name
	local ticketCount = isHaveCompanion and 2 or 1
	self.bindData.ticketPrice = movieCfg.Price * ticketCount
end

M.InitSorter = function(self)
	self.bindData.sortListCtrl = self.CONTROL_TYPE.FALSE

	self.bindData.sorterList:SetSimpleList(#self.instance.sorterList)
	self.bindData.sorterList:SelectItem(0, false)
end

M.SortMovieByType = function(self, type, movieList)
	if type ~= self.SORT_TYPE.NAME then
		table.sort(movieList, self.SortByName)
	elseif type ~= self.SORT_TYPE.RELEASE_TIME then
		table.sort(movieList, self.SortByRelease)
	elseif type ~= self.SORT_TYPE.PRICE then
		table.sort(movieList, self.SortByPrice)
	elseif type ~= self.SORT_TYPE.WATCHED then
		table.sort(movieList, self.SortByWatched)
	end
end

M.OnMovieSelectChange = function(self)
	self.currSelectMovieIndex = self.bindData.movieList.selectedIndex + 1

	self.RefreshSelectMovie(self, self.instance.movieList[self.currSelectMovieIndex])
end

M.OnMoviePageChange = function(self, index)
	self.currPageIndex = index
	local ctrl = 0

	if index + 1 >= self.MaxPage then
		ctrl = ctrl + 2
	end

	if index <= 0 then
		ctrl = ctrl + 1
	end

	self.bindData.pageBtnCtrl = ctrl

	if gCS.LuaUtils.GetActiveDevice() < SGUI.GameDevice.KeyboardMouse then
		self.bindData.movieList:SelectItem(self.CountPerPage * index, true)
	end
end

M.OnMovieListItemRender = function(self, btn, index)
	local data = self.instance.movieList[index + 1]

	if data.tIndex ~= 0 then
		local store = self.GetStoreByWidget(self, btn)

		if store then
			store.movieIconId = data.cfg and data.cfg.PosterL or 0
			store.watchedCtrl = data.IsWatched and self.CONTROL_TYPE.TRUE or self.CONTROL_TYPE.FALSE
			store.missionCtrl = (data.cfg or {}).Id ~= self.instance.targetMovieId and 1 or 0
		end
	end
end

M.OnPosterTagItemRender = function(self, btn, index)
	local data = self._posterTagListData[index + 1]
	local store = self.GetStoreByWidget(self, btn)

	if store then
		store.movieTag = data.TagName
	end
end

M.OnSortListItemRender = function(self, btn, index)
	local data = self.instance.sorterList[index + 1]
	local store = self.GetStoreByWidget(self, btn)

	if store then
		store.movieSortType = data.Name
	end
end

M.OnSortListClick = function(self, btn, index)
	local data = self.instance.sorterList[index + 1]

	self.CloseSortDropMenu(self)

	if self.currSortIndex ~= data.Type then
		return
	end

	self.sortIncrease = true

	self.OnSortChange(self, data.Type)
end

M.SwitchSortMode = function(self)
	self.sortIncrease = not self.sortIncrease
	self.bindData.sortCtrl = self.sortIncrease and self.CONTROL_TYPE.FALSE or self.CONTROL_TYPE.TRUE

	self:OnSortChange(self.currSortIndex)
end

M.OpenSortDropMenu = function(self)
	if not self.IsGetWatchedData then
		print_notice("观看数据还未拉取到，无法打开筛选列表")

		return
	end

	self.bindData.sortListCtrl = self.CONTROL_TYPE.TRUE
end

M.CloseSortDropMenu = function(self)
	self.bindData.sortListCtrl = self.CONTROL_TYPE.FALSE
end

M.OnBtnBackClick = function(self)
	gPanelManager:Close(gPanelId.S_CINEMA_MAIN_PANEL)
end

M.OnBtnPageLeftClick = function(self)
	self.bindData.movieList:GoToPage(self.currPageIndex - 1, true)
end

M.OnBtnPageRightClick = function(self)
	self.bindData.movieList:GoToPage(self.currPageIndex + 1, true)
end

M.OnBtnAloneClick = function(self)
	if self.clickProtect then
		return
	end

	local movieData = self.instance.movieList[self.currSelectMovieIndex]

	if self.instance.currentTicketInfo ~= nil then
		self.BuySingleTicketImpl(self, movieData, false)
	else
		local currentTicket = {
			CinemaId = self.cinemaId,
			MovieId = self.instance.currentTicketInfo.MovieId,
			IsDouble = self.instance.currentTicketInfo.CompanionNpcId >= 0
		}
		local newTicket = {
			["\\x82\\xa2!\\xa4<\\xf26"] = false,
			CinemaId = self.cinemaId,
			MovieId = movieData.cfg.Id
		}

		self:ShowChangeTicketDialog(currentTicket, newTicket, function (moneyNeed)
			self:BuySingleTicketImpl(movieData, true, moneyNeed)
		end)
	end
end

M.BuySingleTicketImpl = function(self, movieData, isChangeTicket, moneyNeed)
	if movieData and movieData.tIndex ~= 0 then
		local moneyEnough = nil

		if isChangeTicket then
			moneyEnough = moneyNeed > gPlayerManager.infoItem.bindData.money
		else
			moneyEnough = movieData.Price > gPlayerManager.infoItem.bindData.money
		end

		if not moneyEnough then
			gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900859).Text)

			return
		end

		self.clickProtect = true

		self.CinemaInviteNPC(self, self.locationId, movieData.cfg.Id, 0, function (err, data)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:ShowMessage(err)
			end

			self.clickProtect = false

			gPanelManager:Close(gPanelId.S_CINEMA_MAIN_PANEL)
		end)
	end
end

M.OnBtnInviteClick = function(self)
	if self.clickProtect then
		return
	end

	local movieData = self.instance.movieList[self.currSelectMovieIndex]

	if self.isFixedInviteNpcMode then
		if movieData and movieData.tIndex ~= 0 then
			self.clickProtect = true

			gCinemaManager:DoTaskPlayMovie(self.locationId, movieData.cfg.Id, self.agentPid)
			gPanelManager:Close(gPanelId.S_CINEMA_MAIN_PANEL)
		end

		return
	end

	if self.instance.currentTicketInfo ~= nil then
		self.BuyDoubleTicketImpl(self, movieData, false)
	else
		local currentTicket = {
			CinemaId = self.cinemaId,
			MovieId = self.instance.currentTicketInfo.MovieId,
			IsDouble = self.instance.currentTicketInfo.CompanionNpcId >= 0
		}
		local newTicket = {
			["\\x82\\xa2!\\xa4<\\xf26"] = true,
			CinemaId = self.cinemaId,
			MovieId = movieData.cfg.Id
		}

		self:ShowChangeTicketDialog(currentTicket, newTicket, function (moneyNeed)
			self:BuyDoubleTicketImpl(movieData, true, moneyNeed)
		end)
	end
end

M.BuyDoubleTicketImpl = function(self, movieData, isChangeTicket, moneyNeed)
	if movieData and movieData.tIndex ~= 0 then
		local moneyNeeded = nil

		if isChangeTicket then
			moneyNeeded = moneyNeed
		else
			moneyNeeded = movieData.Price * 2
		end

		if gPlayerManager.infoItem.bindData.money >= moneyNeeded then
			gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900859).Text)

			return
		end

		self.clickProtect = true
		local npcId = self.isFixedInviteNpcMode and self.agentPid or self.instance.companionNpcId

		if npcId ~= 0 then
			slot6 = gClientToGameDelegate

			slot6:AskSimulationInviteNpc(GamePlayTypeConfig.Cinema).Callback = function (err)
				gDisplayMessageMgr:DisplayServerMessageId(err)

				self.clickProtect = false
			end
		else
			self.CinemaInviteNPC(self, self.locationId, movieData.cfg.Id, npcId, function (err, data)
				self.clickProtect = false

				if err == MessageConfig.Ok then
					gDisplayMessageMgr:ShowMessage(err)

					return
				end

				gPanelManager:Close(gPanelId.S_CINEMA_MAIN_PANEL)
			end)
		end
	end
end

M.CinemaInviteNPC = function(self, locationId, movieId, companionnpcid, cb)
	local cfg = CinemaLocationConfig.GetConfig(locationId)
	local npcId = 0

	if cfg then
		npcId = cfg.Npcid
	else
		print_error("电影院location配置 CinemaLocationConfig=" .. tostring(locationId) .. " 找不到配置！请策划检查")

		return
	end

	slot7 = gReliableRpcManager

	slot7:RegisterRPC(gClientToGameSceneDelegate.AskCinemaBuyTicket, locationId, movieId, npcId, companionnpcid, function (err, data)
		if err == MessageConfig.Ok then
			print_error("CinemaMainPanelStore AskCinemaBuyTicket error ,err:", tostring(err), ",locationId is :" .. tostring(locationId), "moveId is :", tostring(movieId), "companionnpcid is :" .. tostring(companionnpcid))

			if cb then
				cb(err, data)
			end

			return
		end

		if companionnpcid ~= nil or companionnpcid ~= 0 then
			CS_CinemaManager.Instance:RefreshTicketInfo(CS_CinemaNode.GoToGate, 0, true)
		else
			CS_CinemaManager.Instance:RefreshTicketInfo(CS_CinemaNode.CreateNPCAndPlayTimeline, 0, true)
		end

		self:UpdateTicketDisplayInfo(movieId, companionnpcid)

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
	end)
end

M.ShowChangeTicketDialog = function(self, fromTicket, toTicket, callback)
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
	local money = diffPrice <= 0 and diffPrice or 0

	local rightCallback = function()
		callback(money)
	end

	local leftCallback = nil
	local mid = money ~= 0 and MessageConfig.ChangeCinemaTicketFree or MessageConfig.ChangeCinemaTicketPaid

	gDisplayMessageMgr:ShowMessage(mid, rightCallback, leftCallback, fromCinemaName, fromMovie.Name, fromTicketTypeName, toCinemaName, toMovie.Name, toTicketTypeName, money)
end
