-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineArcadeCenterInfoPanelStore.lua
-- Decompiled from: 01098_OnlineArcadeCenterInfoPanelStore.lua_6cea09aed5e3.luajit

C_OnlineArcadeCenterInfoPanelStore = DefClass("C_OnlineArcadeCenterInfoPanelStore", C_OnlineArcadeCenterInfoPanelStore, C_StoreGroup)
GroupName2Class.OnlineArcadeCenterInfoPanelStore = C_OnlineArcadeCenterInfoPanelStore
local M = C_OnlineArcadeCenterInfoPanelStore
local LinkHubConfig = LTConfig.LinkHubConfig
local LinkHubRobHubConfig = LTConfig.LinkHubRobHubConfig
local LinkHubExtractionHubConfig = LTConfig.LinkHubExtractionHubConfig
local LinkHubMidSizeHubConfig = LTConfig.LinkHubMidSizeHubConfig
local LinkHubSmallSizeHubConfig = LTConfig.LinkHubSmallSizeHubConfig
local LinkMultiPlayerConfig = LTConfig.LinkMultiPlayerConfig
local LinkHubTagConfig = LTConfig.LinkHubTagConfig
local LinkHubButtonConfig = LTConfig.LinkHubButtonConfig
local TaskEventState = UX.Game.TaskEventState

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.pageCtrlEnum = {
		["rHͼ\\x80\r\\x94\r\\xda\\xfc"] = 1,
		["S,{T"] = 0
	}
	self.showInfoCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.pageCtrlEnum = nil
	self.showInfoCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.moveBarSize = Vector2.New(0, self.bindData.selectedMoveBar and self.bindData.selectedMoveBar.rect.height or 0)
end

M.OnGroupDisable = function(self)
	self.moveBarSize = nil
end

M.OnShow = function(self, panelId, data)
end

M.ShowPanel = function(self, args)
	self.curGameType = args.gameType or gClientConst.ArcadeCenterGameType.Rob
	self.curGameplayId = 0

	self:InitTabInfo(self.bindData.tabWidget, args.gameType)

	if args.showAllGame then
		self.showAllGame = true

		self.RefreshAllGame(self)
	else
		self.showAllGame = false

		self.ChangeGameType(self, self.curGameType, args.gameplayId)
	end
end

M.OnClose = function(self)
	self.allGameListData = nil
	self.allGameBtnIns = nil
	self.tabListIns = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.centerWidget.luaClick = self.CreateAction(self, "OnClickCenterWidget")
	self.bindData.leftList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderLeftListItem")
	self.bindData.allList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderAllListItem")
	self.bindData.leftList.luaSelectedChanged = self.CreateAction(self, "OnLeftListSelectChanged")
	self.bindData.allList.luaSelectedChanged = self.CreateAction(self, "OnAllListSelectChanged")
end

M.OnClickCenterWidget = function(self)
end

M.OnClickAllGame = function(self)
	if not self.showAllGame then
		self.showAllGame = true

		self:RefreshAllGame()
		self.tabListIns:DeselectAll(false)
	end
end

M.OnClickGoShopGame = function(self)
	local shopLinkId = LinkHubConfig.JumpToLinkStore

	if shopLinkId and shopLinkId <= 0 then
		local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(shopLinkId, nil)

		if hyperLinkInfo and hyperLinkInfo.callback then
			hyperLinkInfo.callback()
		end

		gPanelManager:Close(gPanelId.ONLINE_ARCADE_CENTER_MAIN_PNEL)
	end
end

M.OnBackBtnClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_ARCADE_CENTER_CLOSE_PANEL)
end

M.OnSimpleRenderLeftListItem = function(self, btn, index)
	local data = self.leftListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.icon = data.playIcon
	store.showSubTitleCtrl = 1
	local playConfig = LinkMultiPlayerConfig.GetConfig(data.playId)

	if playConfig then
		store.name = playConfig.Name
	end
end

M.OnSimpleClickLeftList = function(self, btn, index)
end

M.OnSimpleRenderAllListItem = function(self, btn, index)
	local data = self.allGameListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.icon = data.playIcon
	store.showSubTitleCtrl = 1
	local playConfig = LinkMultiPlayerConfig.GetConfig(data.playId)

	if playConfig then
		store.name = playConfig.Name
	end
end

M.OnSimpleClickAllList = function(self, btn, index)
end

M.OnSimpleDynamicRenderTabListItem = function(self, btn, index)
	local data = self.tabListData[index + 1]

	if not data then
		return
	end

	local config = LinkHubConfig.GetConfig(data.Id)

	if config then
		btn.title.text = config.Name
	end
end

M.OnTabListSelectChanged = function(self, list)
	local selectedIndex = list.selectedIndex

	if selectedIndex > 0 then
		local data = self.tabListData[selectedIndex + 1]

		if data then
			local config = LinkHubConfig.GetConfig(data.Id)

			if config then
				local gameType = self.GetGameTypeByConfig(self, config)
				self.showAllGame = false

				self.ChangeGameType(self, gameType)
			end

			local buttons = list.items:ToTable()

			self:MoveBarToButton(buttons[selectedIndex + 1])
		end
	end
end

M.OnLeftListSelectChanged = function(self, list)
	local selectedIndex = list.selectedIndex

	if selectedIndex > 0 then
		local data = self.leftListData[selectedIndex + 1]

		if data then
			self.RefreshInfo(self, data)
		end
	end
end

M.OnAllListSelectChanged = function(self, list)
	local selectedIndex = list.selectedIndex

	if selectedIndex > 0 then
		local data = self.allGameListData[selectedIndex + 1]

		if data then
			self.RefreshInfo(self, data)
		end
	end
end

M.OnClickInfoButton = function(self, data)
	local buttonCfg = LinkHubButtonConfig.GetConfig(data.btnId)

	if buttonCfg then
		if buttonCfg.ButtonType ~= LinkHubButtonConfig.ButtonTypeType.FastMatch then
			self.DoFastMatch(self, data)
		elseif buttonCfg.ButtonType ~= LinkHubButtonConfig.ButtonTypeType.HyperLink then
			self.DoHyperLink(self, data)
		end
	end
end

M.DoFastMatch = function(self, data)
	local Config = self.GetConfigByGameType(self, data.gameType)

	if Config then
		local linkHubCfg = Config.GetConfig(data.linkId)

		if linkHubCfg and linkHubCfg.PlayId <= 0 then
			gLinkManager:AskMatchBegin(linkHubCfg.PlayId, true)
			gPanelManager:Close(gPanelId.ONLINE_ARCADE_CENTER_MAIN_PNEL)
		end
	end
end

M.DoHyperLink = function(self, data)
	local Config = self.GetConfigByGameType(self, data.gameType)

	if Config then
		local linkHubCfg = Config.GetConfig(data.linkId)

		if linkHubCfg then
			local hyperLinkId = data.btnLeft and linkHubCfg.HyperlinkLeft or linkHubCfg.HyperLink

			if hyperLinkId <= 0 then
				local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, nil)

				if hyperLinkInfo and hyperLinkInfo.callback then
					hyperLinkInfo.callback()
				end

				gPanelManager:Close(gPanelId.ONLINE_ARCADE_CENTER_MAIN_PNEL)
			end
		end
	end
end

M.InitTabInfo = function(self, widget, defaultGameType)
	self.tabListData = {}
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	local count = LinkHubConfig.count

	for i = 0, count - 1 do
		local linkHudCfg = LinkHubConfig.LoadAt(i)

		if linkHudCfg and linkHudCfg.DisplayType ~= 1 then
			local gameType = self.GetGameTypeByConfig(self, linkHudCfg)

			table.insert(self.tabListData, {
				Id = linkHudCfg.Id,
				gameType = gameType,
				weight = linkHudCfg.Weight
			})
		end
	end

	table.sort(self.tabListData, function (a, b)
		return b.weight <= a.weight
	end)

	store.tabList.luaSimpleDynamicRenderItem = self:CreateAction("OnSimpleDynamicRenderTabListItem")
	store.tabList.luaSimpleRenderItem = self:CreateAction("OnSimpleDynamicRenderTabListItem")
	store.tabList.luaSelectedChanged = self:CreateAction("OnTabListSelectChanged")

	store.tabList:SetSimpleList(#self.tabListData)

	local index = nil

	if defaultGameType then
		for i = 1, #self.tabListData do
			if self.tabListData[i].gameType ~= defaultGameType then
				index = i - 1

				break
			end
		end
	end

	if index and index > 0 then
		store.tabList:SelectItem(index, false)

		local buttons = store.tabList.items:ToTable()

		self:MoveBarToButton(buttons[index + 1])
	else
		store.tabList:DeselectAll(false)
	end

	if store.backBtn then
		store.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	end

	if store.mobileBackBtn then
		store.mobileBackBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	end

	if store.allGameBtn then
		store.allGameBtn.luaClick = self.CreateAction(self, "OnClickAllGame")
	end

	if store.goShopBtn then
		store.goShopBtn.luaClick = self.CreateAction(self, "OnClickGoShopGame")
	end

	self.tabListIns = store.tabList
	self.allGameBtnIns = store.allGameBtn
end

M.ChangeGameType = function(self, newGameType, defaultSelect)
	self.curGameType = newGameType

	if self.showAllGame then
		return
	end

	self.bindData.pageCtrl = self.pageCtrlEnum.Info
	self.leftListData = {}
	local Config = self.GetConfigByGameType(self, self.curGameType)

	if Config then
		local count = Config.count

		for i = 0, count - 1 do
			local gameCfg = Config.LoadAt(i)

			if gameCfg then
				table.insert(self.leftListData, {
					Id = gameCfg.Id,
					playId = gameCfg.PlayId,
					weight = gameCfg.Weight,
					playIcon = gameCfg.PlayIcon,
					playImg = gameCfg.PlayImage
				})
			end
		end
	end

	table.sort(self.leftListData, function (a, b)
		return b.weight <= a.weight
	end)
	self.bindData.leftList:SetSimpleList(#self.leftListData)

	local index = 0

	if defaultSelect then
		for i = 1, #self.leftListData do
			if self.leftListData[i].Id ~= defaultSelect then
				index = i - 1

				break
			end
		end
	end

	self.bindData.leftList:SelectItem(index, true)

	if self.bindData.leftList.selectedIndex >= 0 then
		self.RefreshInfo(self)
	end
end

M.GetGameTypeByConfig = function(self, linkHubConfig)
	if linkHubConfig.MainType ~= LinkHubConfig.MainTypeType.Rob then
		return gClientConst.ArcadeCenterGameType.Rob
	elseif linkHubConfig.MainType ~= LinkHubConfig.MainTypeType.ExtractionShooter then
		return gClientConst.ArcadeCenterGameType.ExtractionShooter
	elseif linkHubConfig.MainType ~= LinkHubConfig.MainTypeType.MidSize then
		return gClientConst.ArcadeCenterGameType.MidSize
	elseif linkHubConfig.MainType ~= LinkHubConfig.MainTypeType.SmallSize then
		return gClientConst.ArcadeCenterGameType.SmallSize
	end

	return gClientConst.ArcadeCenterGameType.Unknown
end

M.GetConfigByGameType = function(self, gameType)
	if gameType ~= gClientConst.ArcadeCenterGameType.Rob then
		return LinkHubRobHubConfig
	elseif gameType ~= gClientConst.ArcadeCenterGameType.ExtractionShooter then
		return LinkHubExtractionHubConfig
	elseif gameType ~= gClientConst.ArcadeCenterGameType.MidSize then
		return LinkHubMidSizeHubConfig
	elseif gameType ~= gClientConst.ArcadeCenterGameType.SmallSize then
		return LinkHubSmallSizeHubConfig
	end

	return nil
end

M.RefreshInfo = function(self, data)
	self.bindData.showInfoCtrl = self.showInfoCtrlEnum.normal

	if data then
		local gameType = data.gameType or self.curGameType
		local Config = self:GetConfigByGameType(gameType)

		if Config then
			local gameplayCfg = Config.GetConfig(data.Id)

			if gameplayCfg then
				self.RefreshCenterWidget(self, self.bindData.centerWidget, gameplayCfg.PlayImage)
				self.RefreshInfoWidget(self, self.bindData.infoWidget, gameplayCfg, gameType)

				self.bindData.showInfoCtrl = self.showInfoCtrlEnum.active
			end
		end
	end
end

M.RefreshInfoWidget = function(self, widget, config, gameType)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	if config.PlayIcon and config.PlayIcon <= 0 then
		store.showImageCtrl = 1
		store.icon = config.PlayIcon
	else
		store.showImageCtrl = 0
	end

	local linkMultiPlayerCfg = LinkMultiPlayerConfig.GetConfig(config.PlayId)

	if linkMultiPlayerCfg then
		store.name = linkMultiPlayerCfg.Name
		store.des = linkMultiPlayerCfg.Description
	end

	local tags = {}
	local tagId = config.Tag
	local showButton = true

	if gameType ~= gClientConst.ArcadeCenterGameType.MidSize and config.PublicEvent and config.PublicEvent <= 0 then
		local taskState = gTaskManager:GetTaskEventState(config.PublicEvent)
		local eventOn = taskState ~= TaskEventState.Accepted
		showButton = eventOn
		tagId = eventOn and LinkHubConfig.PublicEventOn or LinkHubConfig.PublicEventOff
	end

	if tagId <= 0 then
		table.insert(tags, tagId)
	end

	self.RefreshTag(self, store.tagList, tags)

	if showButton and config.ButtonLeft <= 0 then
		store.matchBtn:SetActive(true)

		store.matchBtn.luaClick = self:CreateActionWithArgs("OnClickInfoButton", {
			["\\xdb\\xcf1\"\\xe5"] = true,
			["\\x97-0:j\\xb1H\\xd7<\\x83\\xbd"] = 0,
			btnId = config.ButtonLeft,
			gameType = gameType,
			linkId = config.Id
		})
		local btnCfg = LinkHubButtonConfig.GetConfig(config.ButtonLeft)
		store.matchBtn.title.text = btnCfg and btnCfg.Name or ""
	else
		store.matchBtn:SetActive(false)

		store.matchBtn.luaClick = nil
	end

	if showButton and config.ButtonRight <= 0 then
		store.startBtn:SetActive(true)

		store.startBtn.luaClick = self:CreateActionWithArgs("OnClickInfoButton", {
			["\\xdb\\xcf1\"\\xe5"] = false,
			["\\x97-0:j\\xb1H\\xd7<\\x83\\xbd"] = 0,
			btnId = config.ButtonRight,
			gameType = gameType,
			linkId = config.Id
		})
		local btnCfg = LinkHubButtonConfig.GetConfig(config.ButtonRight)
		store.startBtn.title.text = btnCfg and btnCfg.Name or ""
	else
		store.startBtn.luaClick = nil

		store.startBtn:SetActive(false)
	end
end

M.RefreshCenterWidget = function(self, widget, bigIcon)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	store.icon = bigIcon or 0
end

M.RefreshTag = function(self, list, tags)
	local cachedTags = tags or {}

	local renderFunc = function(btn, index)
		local tagId = cachedTags[index + 1]

		if tagId then
			local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

			if store then
				local tagCfg = LinkHubTagConfig.GetConfig(tagId)

				if tagCfg then
					store.quality = tagCfg.Quality

					store:Commit("text", tagCfg.Name, COMMIT_FORCE)
				end
			end
		end
	end

	list.luaSimpleDynamicRenderItem = renderFunc
	list.luaSimpleRenderItem = renderFunc

	list:SetSimpleList(#tags)
end

M.RefreshAllGame = function(self)
	self.bindData.pageCtrl = self.pageCtrlEnum.ArcadeList

	if not self.allGameListData or #self.allGameListData ~= 0 then
		self.allGameListData = {}

		self.GetListData(self, gClientConst.ArcadeCenterGameType.Rob, self.allGameListData)
		self.GetListData(self, gClientConst.ArcadeCenterGameType.SmallSize, self.allGameListData)
		self.GetListData(self, gClientConst.ArcadeCenterGameType.MidSize, self.allGameListData)
		self.GetListData(self, gClientConst.ArcadeCenterGameType.ExtractionShooter, self.allGameListData)
		table.sort(self.allGameListData, function (a, b)
			return b.weight <= a.weight
		end)
	end

	self.bindData.allList:SetSimpleList(#self.allGameListData)

	if self.bindData.allList.selectedIndex >= 0 then
		self.RefreshInfo(self)
	end

	self.MoveBarToButton(self, self.allGameBtnIns, true)
end

M.GetListData = function(self, gameType, listData)
	local Config = self.GetConfigByGameType(self, gameType)

	if Config then
		local count = Config.count

		for i = 0, count - 1 do
			local gameCfg = Config.LoadAt(i)

			if gameCfg then
				table.insert(listData, {
					Id = gameCfg.Id,
					playId = gameCfg.PlayId,
					weight = gameCfg.Weight,
					playIcon = gameCfg.PlayIcon,
					playImg = gameCfg.PlayImage,
					gameType = gameType
				})
			end
		end
	end
end

M.AdjustBarSize = function(self, targetBtn)
	self.moveBarSize.x = targetBtn.rectTransform.rect.width
	self.bindData.selectedMoveBar.sizeDelta = self.moveBarSize
end

M.MoveBarToButton = function(self, targetBtn, halfOffset)
	if targetBtn and self.bindData.selectedMoveBar then
		self.AdjustBarSize(self, targetBtn)

		self.bindData.selectedMoveBar.localPosition = self.GetTargetPosition(self, targetBtn, halfOffset)
	end
end

M.GetTargetPosition = function(self, targetBtn, halfOffset)
	local targetPos = self.bindData.tabWidget.rectTransform:InverseTransformPoint(targetBtn.position)
	targetPos.y = targetPos.y - targetBtn.rectTransform.rect.height

	if halfOffset then
		targetPos.x = targetPos.x - targetBtn.rectTransform.rect.width * 0.5
	end

	return targetPos
end
