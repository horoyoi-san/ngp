-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RobberyBoardSiBaiKeHotelPanel01Store.lua
-- Decompiled from: 00918_RobberyBoardSiBaiKeHotelPanel01Store.lua_0a3677166dfe.luajit

local Ease = DG.Tweening.Ease
C_RobberyBoardSiBaiKeHotelPanel01Store = DefClass("C_RobberyBoardSiBaiKeHotelPanel01Store", C_RobberyBoardSiBaiKeHotelPanel01Store, C_StoreGroup)
GroupName2Class.RobberyBoardSiBaiKeHotelPanel01Store = C_RobberyBoardSiBaiKeHotelPanel01Store
local M = C_RobberyBoardSiBaiKeHotelPanel01Store

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.showItemDetailCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showQuickStartCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showButtonCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showTipsCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isSingleCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isSearchingCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showTabNavigationCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["i*rL"] = 1
	}
	self.daughterSelectedCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.panelTypeCtrlEnum = {
		["I\\x9f\\x8b\\x8f"] = 0,
		["I\\x9f\\x8b\\x8f"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showItemDetailCtrlEnum = nil
	self.showQuickStartCtrlEnum = nil
	self.showButtonCtrlEnum = nil
	self.showTipsCtrlEnum = nil
	self.isSingleCtrlEnum = nil
	self.isSearchingCtrlEnum = nil
	self.showTabNavigationCtrlEnum = nil
	self.daughterSelectedCtrlEnum = nil
	self.panelTypeCtrlEnum = nil
end

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	self:RegisterMessageEvents(self.msgEvents)
	gPanelManager:CheckShowInBackground(gPanelId.BACK_BTN_PANEL)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.waitEnterCo = coroutine.stop(self.waitEnterCo)
	gPlanningBoardManager.dividendsMultiPlayerIdFinished = nil

	self:ClearMessageEvents()
	gPanelManager:Close(gPanelId.BACK_BTN_PANEL)
	gCS.GuiUtils.SetPanelHideCursor(self.m_Id, false)
	self:OnExitInteraction()

	self.isEnterInteraction = nil
	self.currentStepId = nil

	if self.buttonStoreMap then
		for _, store in pairs(self.buttonStoreMap) do
			if store.maskTween then
				store.maskTween:Kill()

				store.maskTween = nil
			end
		end
	end

	self.buttonStoreMap = nil
	self.leaderActionSettingInfo = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, _, args)
	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.id = args.id
	self.ActionType = {
		["X\\xfd4\\xf8\"#\\xd7h\\xd9J\\x95\tP\\xef\\xe2"] = 8,
		["Ks\\xb8vE\\xbe\\xd7_z{pH"] = 3,
		["N\t\\xbe4\\xf4m#\\xb8v5&p\\xb8\\xfb7\\xf0\\xe3"] = 0,
		["\\xb69!8}\\xb4O\\xdd2\\xb2\\xea"] = 6,
		["\\xb69!8}\\xb4O\\xdd2\\xb2\\xed"] = 7,
		["W\\x94\\x95\\xb3\\xe8\\xa9\\xd5>\\x8a0\\xa69"] = 9,
		["\\xb69!8}\\xb4O\\xdd2\\xb2\\xe8"] = 4,
		["Q\t\\xb35\\xf2k+\\xa3n$$e\\xa4\\xec$\\xda\\xf3"] = 1,
		["\\xb69!8}\\xb4O\\xdd2\\xb2\\xeb"] = 5,
		["S\\x98\\xa3\\xbaе\\xc6/\\xac;$\\xbc3"] = 2
	}
	self.tabDataList = self.GetTabDataList(self)
	self.leaderActionSettingInfo = {}
	self.groupId = LTConfig.LinkProgressConfig.fullConfirm
	self.currentRouteId = self.GetDefaultRouteId(self)
	self.STEP_MASK_FOLD_TWEEN_DURATION = 0.15
	self.STEP_MASK_UNFOLD_TWEEN_DURATION = 0.3
	self.STEP_MASK_COLLAPSE_HEIGHT = 276.72
end

M.InitView = function(self, args)
	self.bindData.createButton:SetActive(false)
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		["PNkgO:!"] = "45\\x92﮵񖻆\\xd8\\xeeȩ(\\x90\\xf5"
	})
	SGUI.SDF.SDFAsyncFontAssetManager.CacheCharactersAddRefByFontName("MiSans-Medium_SDF", "0123456789")

	self.bindData.uNavigationArea.enabled = false

	self.rootGo.transform:ChangeLayersRecursively(Layer.Default)

	self.bindData.background.gameObject.layer = Layer.WorldUI_HitMaterial

	self:InitPosition(args.uiPivot)

	local lastMultiPlayerId = self:GetLastMultiPlayerId()

	self:UpdateActionSettingInfo({
		[self.ActionType.LastMultiPlayerId] = lastMultiPlayerId
	})
	self:RefreshViewByPanelType()
end

M.RefreshViewByPanelType = function(self)
	local panelTypeCtrl = self.GetPanelTypeCtrl(self)

	if self.bindData.panelTypeCtrl == panelTypeCtrl and panelTypeCtrl ~= self.panelTypeCtrlEnum.panel2 and self.isEnterInteraction then
		self.SetCurrentActiveContent(self, self.bindData.step1)
	end

	self.bindData.panelTypeCtrl = panelTypeCtrl
	self.teamMemberList = gPlanningBoardManager.GetTeamMemberInfoList()

	self.bindData.routePlayerList:SetSimpleList(#self.teamMemberList)
	self:RefreshAllRouteWidgets()

	local planningBoardCfg = LTConfig.PlanningBoardConfig.GetConfig(self.id)
	self.bindData.routeDesc = planningBoardCfg.Name

	self.bindData.tabList:SetSimpleList(#self.tabDataList)
	self:RefreshTabContentView()
end

M.RefreshAllRouteWidgets = function(self)
	local count = LTConfig.PlanningBoardRouteConfig.count

	for i = 1, count do
		local routeCfg = LTConfig.PlanningBoardRouteConfig.LoadAt(i - 1)

		self.RefreshRouteWidgetView(self, i, routeCfg.Id)
	end
end

M.RefreshRouteWidgetView = function(self, index, routeId)
	local widget = self.bindData[("route%dWidget"):format(index)]
	local stepIdList = self.routeStepMap[routeId]
	local stepId = stepIdList[#stepIdList]
	local stepDetailCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
	local dividendsMultiPlayerId = stepDetailCfg.TaskId
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(dividendsMultiPlayerId)
	local store = self:GetWidgetStore(widget)
	store.desc = multiPlayerCfg.Description
	local routeGroup = stepDetailCfg.RouteGroup
	local routeGroupCfg = LTConfig.PlanningBoardRouteConfig.GetConfig(routeGroup)
	store.title = routeGroupCfg.Desc
	local hasUnlocked = self:CheckRouteHasUnlocked(routeId)
	store.unlockCtrl = hasUnlocked and 1 or 0
end

M.GetWidgetStore = function(self, widget)
	return gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
end

M.GetTabDataList = function(self)
	local planningBoardCfg = LTConfig.PlanningBoardConfig.GetConfig(self.id)
	local allStepIdList = planningBoardCfg.AllStep
	self.routeStepMap = {}

	for _, stepId in ipairs(allStepIdList) do
		local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
		local stepIdList = self.routeStepMap[stepCfg.RouteGroup] or {}

		table.insert(stepIdList, stepId)

		self.routeStepMap[stepCfg.RouteGroup] = stepIdList
	end

	local routeIdList = {}

	for routeId, _ in pairs(self.routeStepMap) do
		table.insert(routeIdList, routeId)
	end

	table.sort(routeIdList)

	local viewDataList = {}

	for index, routeId in ipairs(routeIdList) do
		table.insert(viewDataList, {
			["a\\x9f\\x8a\\x86Y"] = 0,
			routeId = routeId,
			tabIndex = index - 1
		})
	end

	return viewDataList
end

M.InitPosition = function(self, uiPivot)
	if gClientUtils.IsNil(uiPivot) then
		return
	end

	self.rootGo.transform.position = uiPivot.position
	self.rootGo.transform.rotation = uiPivot.rotation
	self.rootGo.transform.localScale = uiPivot.localScale
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_ROBBERY_BOARD_ENTER_INTERACTION] = self.CreateAction(self, "OnEnterInteraction"),
		[gEventConstants.ON_ROBBERY_BOARD_EXIT_INTERACTION] = self.CreateAction(self, "OnExitInteraction"),
		[gEventConstants.TEAM_REFRESH_DATA] = self.CreateAction(self, "OnTeamRefreshData"),
		[gEventConstants.LINK_SEARCHING_REFRESH] = self.CreateAction(self, "RefreshSearchView"),
		[gEventConstants.ON_LINK_MEMBER_REJECT_CONFIRM] = self.CreateAction(self, "OnMatchCancel"),
		[gEventConstants.ON_LINK_MATCH_READY_CANCEL] = self.CreateAction(self, "OnMatchCancel"),
		[gEventConstants.ON_PLAYER_MAX_MULTI_PLAYER_ID_CHANGE] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.LINK_LEAVE_ROOM] = self.CreateAction(self, "OnMatchCancel"),
		[gEventConstants.LINK_MATCH_CANCEL_SUCCESS] = self.CreateAction(self, "OnMatchCancel"),
		[gEventConstants.LINK_SEARCHING_STATE_CHANGE] = self.CreateAction(self, "OnMatchCancel"),
		[gEventConstants.ON_GM_GAME_SWITCH_CHANGE] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.ON_LINK_SYNC_STAGE_CHANGE_PREPARE] = self.CreateAction(self, "OnStageChangePrepare"),
		[gEventConstants.LANGUAGE_CHANGE] = self.CreateAction(self, "OnLanguageChange"),
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, "OnPackageItemChanged")
	}
end

M.OnTeamRefreshData = function(self, _, args)
	if self.isEnterInteraction and self.IsTeamMemberNotLeader(self) then
		self.OnExitInteraction(self)

		return
	end

	if not self.buttonStoreMap then
		self.RefreshViewByPanelType(self)

		return
	end

	local newPanelTypeCtrl = self.GetPanelTypeCtrl(self)

	if newPanelTypeCtrl == self.bindData.panelTypeCtrl then
		self.RefreshViewByPanelType(self)

		return
	end

	self.RefreshAllRouteWidgets(self)
	self.RefreshPanelView(self)
end

M.RegisterWidget = function(self)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderTabListItem")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.detailButton.luaClick = self.CreateAction(self, "OnDetailClick")
	self.bindData.startButton.luaClick = self.CreateAction(self, "OnStartClick")
	self.bindData.createButton.luaClick = self.CreateAction(self, "OnCreateClick")
	self.bindData.matchButton.luaClick = self.CreateAction(self, "OnMatchClick")
	self.bindData.itemDetailList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderItemDetailListItem")
	self.bindData.cancelSearchButton.luaClick = self.CreateAction(self, "OnCancelSearchClick")
	self.bindData.tabLeftButton.luaClick = self.CreateActionWithArgs(self, "OnStep", -1)
	self.bindData.tabLeftButton.luaBeginLongPress = self.CreateActionWithArgs(self, "OnBeginLongPress", -1)
	self.bindData.tabLeftButton.luaEndLongPress = self.CreateAction(self, "OnEndLongPress")
	self.bindData.tabRightButton.luaClick = self.CreateActionWithArgs(self, "OnStep", 1)
	self.bindData.tabRightButton.luaBeginLongPress = self.CreateActionWithArgs(self, "OnBeginLongPress", 1)
	self.bindData.tabRightButton.luaEndLongPress = self.CreateAction(self, "OnEndLongPress")
	self.bindData.playerList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderPlayerItem")
	self.bindData.routePlayerList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderPlayerItem")
	self.bindData.route1Widget.luaClick = self.CreateActionWithArgs(self, "OnRouteClick", 1)
	self.bindData.route2Widget.luaClick = self.CreateActionWithArgs(self, "OnRouteClick", 2)
	self.bindData.route3Widget.luaClick = self.CreateActionWithArgs(self, "OnRouteClick", 3)
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, "OnFullScreenClick")
	self.bindData.controllerCloseButton.luaClick = self.CreateAction(self, "OnCloseDetailClick")
end

M.OnSimpleRenderTabListItem = function(self, btn, index)
	local store = self:GetWidgetStore(btn)
	local data = self.tabDataList[index + 1]
	local routeCfg = LTConfig.PlanningBoardRouteConfig.GetConfig(data.routeId)
	store.name = routeCfg.Desc
	local hasUnlocked = self:CheckRouteHasUnlocked(data.routeId)
	store.unlockCtrl = hasUnlocked and 1 or 0
	btn.isSelected = data.routeId ~= self.currentRouteId

	btn.luaClick = function()
		if self.currentRouteId ~= data.routeId then
			return
		end

		if hasUnlocked then
			self.currentRouteId = data.routeId

			self:SetCurrentActiveContent(btn)
			self.bindData.tabList:RefreshList()
			self:RefreshTabContentView()
			self:BroadcastCurrentRouteToTeam()
			self:SyncLeaderAction()
		else
			local tips = gString.Format(routeCfg.UnlockShow, routeCfg.MaxProgress)

			gDisplayMessageMgr:ShowMessageContent(tips)
		end
	end
end

M.CheckRouteHasUnlocked = function(self, routeId)
	if not gGameSwitch.EnableLinkPlanningBoardUnlockCheck then
		return true
	end

	local unlockedMultiPlayerIdMap = self.GetUnlockedMultiPlayerIdMap(self)
	local multiPlayerIdList = {}
	local count = LTConfig.PlanningBoardStepDetailConfig.count

	for i = 0, count - 1 do
		local stepDetailCfg = LTConfig.PlanningBoardStepDetailConfig.LoadAt(i)

		if stepDetailCfg.RouteGroup ~= routeId then
			table.insert(multiPlayerIdList, stepDetailCfg.TaskId)
		end
	end

	for _, multiPlayerId in ipairs(multiPlayerIdList) do
		if unlockedMultiPlayerIdMap[multiPlayerId] then
			return true
		end
	end
end

M.CheckStepHasUnlocked = function(self, stepId)
	if not gGameSwitch.EnableLinkPlanningBoardUnlockCheck then
		return true
	end

	local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
	local routeId = stepCfg.RouteGroup
	local hasRouteUnlocked = self.CheckRouteHasUnlocked(self, routeId)

	if not hasRouteUnlocked then
		return false
	end

	local multiPlayerId = stepCfg.TaskId
	local unlockedMultiPlayerIdMap = self.GetUnlockedMultiPlayerIdMap(self)

	return unlockedMultiPlayerIdMap[multiPlayerId]
end

M.GetUnlockedMultiPlayerIdMap = function(self)
	return gPlanningBoardManager.GetUnlockedMultiPlayerIdMap()
end

M.RefreshTabContentView = function(self)
	self.InitButtonStoreMap(self)
	self.RefreshPanelView(self, true)

	self.currentStepId = nil
	self.bindData.showButtonCtrl = 0
	self.bindData.isSearchingCtrl = 0
	self.bindData.showItemDetailCtrl = 0

	self.ResetAllStepUnfoldStatus(self)

	for _, store in pairs(self.buttonStoreMap) do
		self.SetStoreImageIndex(self, store, 0)
	end
end

M.BroadcastCurrentRouteToTeam = function(self)
	local teamMemberCount = gPlanningBoardManager.GetTeamMemberCount()
	local isTeamLeader = gTeamManager:IsTeamLeader()

	if teamMemberCount <= 1 and isTeamLeader then
		self.leaderActionSettingInfo = {
			TeamLeaderSelectMultiPlayerId = 0,
			ClientCustomDatas = {
				[self.ActionType.LeaderEnterInteract] = self.isEnterInteraction and 1 or 0,
				[self.ActionType.TabSelectedIndex] = self:GetCurrentRouteTabIndex()
			}
		}

		gPlanningBoardManager:AskLinkPlanningBoardTeamLeaderUpdateSettingsInfo(self.leaderActionSettingInfo)
	end
end

M.InitButtonStoreMap = function(self)
	self.buttonStoreMap = {}
	local stepIdList = self.GetCurrentRouteStepIdList(self)

	for index, stepId in ipairs(stepIdList) do
		local fieldName = ("step%d"):format(index)
		local button = self.bindData[fieldName]
		local store = self:GetWidgetStore(button)
		self.buttonStoreMap[stepId] = store
	end
end

M.RefreshPanelView = function(self, skipSyncLeader)
	if not self.buttonStoreMap then
		return
	end

	self.teamMemberList = gPlanningBoardManager.GetTeamMemberInfoList()

	self.bindData.playerList:SetSimpleList(#self.teamMemberList)

	local routeUnlockedCount = #self:GetUnlockedRouteIdList()
	self.bindData.showTabNavigationCtrl = routeUnlockedCount <= 1 and 1 or 0

	self.bindData.tabList:RefreshList()
	self:RefreshContentView()
	self:RefreshItemListView()

	if self.bindData.showItemDetailCtrl ~= 1 then
		self.RefreshItemDetailListView(self)
	end

	self.bindData.isSingleCtrl = gPlanningBoardManager.GetTeamMemberCount() ~= 1 and 1 or 0
	local currentStepStore = self.buttonStoreMap[self.currentStepId]

	if currentStepStore and currentStepStore.unfoldCtrl ~= 1 then
		local hasUnlocked = self:CheckStepHasUnlocked(self.currentStepId)
		self.bindData.showButtonCtrl = hasUnlocked and 1 or 0
		self.bindData.showQuickStartCtrl = self:CheckCurrentStepHasMeetPlayerNumRequire() and 1 or 0
	else
		self.bindData.showButtonCtrl = 0
	end

	if not skipSyncLeader then
		self.SyncLeaderAction(self)
	end

	self.RefreshEffectWidget(self)
end

M.RefreshEffectWidget = function(self)
	local stepIdList = self.GetCurrentRouteStepIdList(self)
	local dividendsStepId = stepIdList[#stepIdList]
	local hasUnlocked = self.CheckStepHasUnlocked(self, dividendsStepId)
	local multiPlayerId = LTConfig.PlanningBoardStepDetailConfig.GetConfig(dividendsStepId).TaskId
	local hasCompleted = gPlanningBoardManager.CheckMultiPlayerHasCompleted(multiPlayerId)

	if hasUnlocked and not hasCompleted then
		self.bindData.effectWidget:SetActive(true)
	else
		self.bindData.effectWidget:SetActive(false)
	end
end

M.GetUnlockedRouteIdList = function(self)
	local routeIdList = {}

	for _, data in ipairs(self.tabDataList) do
		if self.CheckRouteHasUnlocked(self, data.routeId) then
			table.insert(routeIdList, data.routeId)
		end
	end

	return routeIdList
end

M.RefreshSearchView = function(self)
	self.bindData.isSearchingCtrl = 1
	self.bindData.searchTime = gLinkManager.baseTime == 0 and gTimeUtils:FormatTime(Time.unscaledTime - gLinkManager.baseTime) or ""
end

M.SyncLeaderAction = function(self)
	if gPlanningBoardManager.GetTeamMemberCount() <= 1 and not gTeamManager:IsTeamLeader() then
		local info = gPlanningBoardManager:GetMemberInfo(gTeamManager.leaderPid)
		local teamSettingInfo = info and info.TeamSettingsInfo

		if teamSettingInfo and teamSettingInfo.ClientCustomDatas then
			local clientCustomDatas = teamSettingInfo.ClientCustomDatas
			self.bindData.showTipsCtrl = self:GetActionTypeValue(clientCustomDatas, self.ActionType.LeaderEnterInteract) ~= 1 and 1 or 0
			local tabSelectedIndex = self:GetActionTypeValue(clientCustomDatas, self.ActionType.TabSelectedIndex)
			local targetRouteId = self.tabDataList[tabSelectedIndex + 1] and self.tabDataList[tabSelectedIndex + 1].routeId

			if targetRouteId and self.currentRouteId == targetRouteId then
				self.currentRouteId = targetRouteId

				self.RefreshTabContentView(self)
				self.SyncLeaderAction(self)

				return
			end

			local isDetailExpand = self:GetActionTypeValue(clientCustomDatas, self.ActionType.DetailExpand) ~= 1
			self.bindData.showItemDetailCtrl = isDetailExpand and 1 or 0

			if self.bindData.showItemDetailCtrl ~= 1 then
				self.RefreshItemDetailListView(self)
			end

			self.ResetAllStepUnfoldStatus(self)

			local leaderSelectMultiPlayerId = teamSettingInfo.TeamLeaderSelectMultiPlayerId
			local stepIdList = self.GetCurrentRouteStepIdList(self)

			for _, stepId in ipairs(stepIdList) do
				local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)

				if stepCfg.TaskId ~= leaderSelectMultiPlayerId then
					self.currentStepId = stepId
					local store = self.buttonStoreMap[stepId]
					store.unfoldCtrl = 1
					self.bindData.showButtonCtrl = self:CheckStepHasUnlocked(stepId) and 1 or 0
					self.bindData.showQuickStartCtrl = self:CheckCurrentStepHasMeetPlayerNumRequire() and 1 or 0

					self:SetStepParent(stepId, true)

					break
				end
			end

			for index, stepId in ipairs(stepIdList) do
				local fieldName = ("ImageIndex%d"):format(index)
				local store = self.buttonStoreMap[stepId]
				local imageIndex = self:GetActionTypeValue(clientCustomDatas, self.ActionType[fieldName])

				self:SetStoreImageIndex(store, imageIndex)
			end
		end
	else
		self.bindData.showTipsCtrl = 0
	end
end

M.GetActionTypeValue = function(self, clientCustomDatas, actionType)
	if not clientCustomDatas then
		local info = gPlanningBoardManager:GetMemberInfo(gTeamManager.leaderPid)
		local teamSettingInfo = info and info.TeamSettingsInfo

		if teamSettingInfo and teamSettingInfo.ClientCustomDatas then
			clientCustomDatas = teamSettingInfo.ClientCustomDatas
		end
	end

	return clientCustomDatas and clientCustomDatas[actionType] or 0
end

M.RefreshItemDetailListView = function(self)
	local multiPlayerId = self:GetCurrentRouteDividendsMultiPlayerId()
	self.itemDetailDataList = gPlanningBoardManager.GetTeamItemDetailDataList(multiPlayerId)

	self.bindData.itemDetailList.onGetTIndex = function(index)
		local data = self.itemDetailDataList[index + 1]

		return data.tIndex
	end

	self.bindData.itemDetailList:SetSimpleList(#self.itemDetailDataList)
end

M.RefreshContentView = function(self)
	local stepIdList = self.GetCurrentRouteStepIdList(self)

	for index, stepId in ipairs(stepIdList) do
		local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
		local taskId = stepCfg.TaskId
		local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(taskId)

		if multiPlayerCfg.Tags ~= LTConfig.LinkMultiPlayerConfig.TagsType.PlanningBoardReady then
			self.RefreshCommonStepView(self, stepId, index)

			local store = self.buttonStoreMap[stepId]
			local itemButton = store.itemButton
			local itemId = multiPlayerCfg.KeyId

			if itemId and itemId <= 0 then
				local itemData = gCommonItemManager:GetItemRenderData({
					["\\xd0\\xcf01\\xfc"] = 1,
					itemId = itemId
				})
				itemData.toolTipsCallback = self:CreateAction("SetPopupToWorldUI")

				itemButton:SetPopupDirection(4)
				gCommonItemManager:OnCommonItemRender(store.itemButton, nil, itemData)
			end
		elseif multiPlayerCfg.Tags ~= LTConfig.LinkMultiPlayerConfig.TagsType.PlanningBoardDividends then
			self.RefreshDividendsStepView(self, stepId, index)
		end
	end
end

M.GetCurrentStepMultiPlayerId = function(self)
	local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(self.currentStepId)

	return stepCfg and stepCfg.TaskId
end

M.GetCurrentRouteDividendsMultiPlayerId = function(self)
	local stepIdList = self.GetCurrentRouteStepIdList(self)
	local stepId = stepIdList[#stepIdList]
	local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)

	return stepCfg.TaskId
end

M.RefreshItemListView = function(self)
	local dividendsMultiPlayerId = self:GetCurrentRouteDividendsMultiPlayerId()
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(dividendsMultiPlayerId)
	local needItemIdList = multiPlayerCfg.NeedKeyIds

	self.bindData.itemList.luaSimpleRenderItem = function(btn, index)
		local store = self:GetWidgetStore(btn)
		local itemId = needItemIdList[index + 1]
		local consumableCfg = LTConfig.ConsumableConfig.GetConfig(itemId)
		store.iconId = consumableCfg.SMoneyIconId
		local ownerCount = gCommonItemManager:GetPackItemNum(itemId)
		store.num = ownerCount
		local itemData = gCommonItemManager:GetItemRenderData({
			["\\xd0\\xcf01\\xfc"] = 1,
			itemId = itemId
		})
		itemData.toolTipsCallback = self:CreateAction("SetPopupToWorldUI")

		btn:SetPopupDirection(16)
		gCommonItemManager:OnCommonItemRender(btn, nil, itemData)
	end

	self.bindData.itemList:SetSimpleList(#needItemIdList)
end

M.OnStepButtonClick = function(self, stepId)
	local store = self.buttonStoreMap[stepId]

	if self.currentStepId ~= stepId and not store.button.isFocus then
		self.currentStepId = nil
		self.bindData.showButtonCtrl = 0

		self.SetStepParent(self, stepId, false)
		self.UpdateActionSettingInfo(self, {
			[self.ActionType.SelectMultiPlayerId] = 0
		})

		if store.unfoldCtrl ~= 1 and store.uMask then
			self.TweenStepMaskHeight(self, store, self.STEP_MASK_COLLAPSE_HEIGHT, self.STEP_MASK_FOLD_TWEEN_DURATION, function ()
				store.unfoldCtrl = 0
			end)
		else
			store.unfoldCtrl = 0
		end

		return
	end

	self:ResetAllStepUnfoldStatus()

	self.currentStepId = stepId
	store.unfoldCtrl = 1

	self:SetStepParent(stepId, true)

	local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)

	self:UpdateActionSettingInfo({
		[self.ActionType.SelectMultiPlayerId] = stepCfg.TaskId
	})

	local hasUnlocked = self:CheckStepHasUnlocked(stepId)
	self.bindData.showButtonCtrl = hasUnlocked and 1 or 0
	self.bindData.showQuickStartCtrl = self:CheckCurrentStepHasMeetPlayerNumRequire() and 1 or 0

	if store.uMask then
		local taskTemplateNodeHeight = store.taskTemplate.sizeDelta.y
		local rewardNodeHeight = store.reward.sizeDelta.y
		local rowSpacingHeight = store.laybox.rowSpacing * 3
		local targetHeight = self.STEP_MASK_COLLAPSE_HEIGHT + taskTemplateNodeHeight + rewardNodeHeight + rowSpacingHeight
		targetHeight = targetHeight + store.taskDes:GetPreferredHeight()

		self:TweenStepMaskHeight(store, targetHeight, self.STEP_MASK_UNFOLD_TWEEN_DURATION)
	end
end

M.TweenStepMaskHeight = function(self, store, targetHeight, duration, onComplete)
	if not store.uMask then
		return
	end

	local uMask = store.uMask
	local width = uMask.sizeDelta.x

	if store.maskTween then
		store.maskTween:Kill()

		store.maskTween = nil
	end

	local getterFunc = function()
		return uMask.sizeDelta.y
	end

	local setterFunc = function(value)
		if gClientUtils.IsNil(uMask) then
			return
		end

		uMask.transform.sizeDelta = Vector2.Fetch(width, value)
	end

	slot9 = DOTween.To(getterFunc, setterFunc, targetHeight, duration)
	slot9 = slot9:SetEase(Ease.InOutQuint)
	store.maskTween = slot9:OnComplete(function ()
		store.maskTween = nil

		if onComplete then
			onComplete()
		end
	end)
	slot9 = store.maskTween

	slot9:OnKill(function ()
		store.maskTween = nil
	end)
end

M.SetStepParent = function(self, stepId, isExpand)
	local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
	local multiPlayerId = stepCfg.TaskId
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(multiPlayerId)

	if multiPlayerCfg.Tags ~= LTConfig.LinkMultiPlayerConfig.TagsType.PlanningBoardDividends then
		return
	end

	local store = self.buttonStoreMap[stepId]

	if isExpand then
		store.button.transform:SetParent(self.bindData.prepareTaskExpand)
	else
		store.button.transform:SetParent(self.bindData.prepareTask)
	end

	self.bindData.daughterSelectedCtrl = isExpand and 1 or 0
end

M.UpdateActionSettingInfo = function(self, updates)
	local teamMemberCount = gPlanningBoardManager.GetTeamMemberCount()
	local isTeamLeader = gTeamManager:IsTeamLeader()

	if teamMemberCount <= 1 and isTeamLeader then
		self.leaderActionSettingInfo.ClientCustomDatas = self.leaderActionSettingInfo.ClientCustomDatas or {}
		local hasChange = false

		for actionType, value in pairs(updates) do
			if actionType ~= self.ActionType.SelectMultiPlayerId then
				self.leaderActionSettingInfo.TeamLeaderSelectMultiPlayerId = value
			end

			if self.leaderActionSettingInfo.ClientCustomDatas[actionType] == value then
				self.leaderActionSettingInfo.ClientCustomDatas[actionType] = value
				hasChange = true
			end
		end

		if hasChange then
			gPlanningBoardManager:AskLinkPlanningBoardTeamLeaderUpdateSettingsInfo(self.leaderActionSettingInfo)
		end
	end
end

M.SetStoreImageIndex = function(self, store, index)
	store.imageList:GoToIndex(index, true)
	store.dotList:GoToIndex(index, true)
end

M.CheckCurrentStepHasMeetPlayerNumRequire = function(self)
	local multiPlayerId = self.GetCurrentStepMultiPlayerId(self)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(multiPlayerId)

	if multiPlayerCfg then
		local playerNumMin, _ = unpack(multiPlayerCfg.PlayerNum)
		local teamMemberCount = gPlanningBoardManager.GetTeamMemberCount()

		return playerNumMin > teamMemberCount
	end
end

M.CheckKeyMeetRequire = function(self, multiPlayerId)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(multiPlayerId)

	if multiPlayerCfg.Tags ~= LTConfig.LinkMultiPlayerConfig.TagsType.PlanningBoardDividends then
		local itemIdList = multiPlayerCfg.NeedKeyIds

		for _, itemId in ipairs(itemIdList) do
			local keyOwnerCount = self.GetKeyOwnerCount(self, itemId)

			if keyOwnerCount >= 1 then
				return false
			end
		end
	end

	return true
end

M.GetCurrentRouteId = function(self)
	return self.currentRouteId
end

M.GetCurrentRouteTabIndex = function(self)
	for _, data in ipairs(self.tabDataList) do
		if data.routeId ~= self.currentRouteId then
			return data.tabIndex
		end
	end

	return 0
end

M.GetDefaultRouteId = function(self)
	local fallbackRouteId = self.tabDataList[1].routeId
	local lastMultiPlayerId = self.GetLastMultiPlayerId(self)

	if not lastMultiPlayerId or lastMultiPlayerId < 0 then
		return fallbackRouteId
	end

	local routeId = self.GetRouteIdByMultiPlayerId(self, lastMultiPlayerId)

	if not routeId or not self.CheckRouteHasUnlocked(self, routeId) then
		return fallbackRouteId
	end

	return routeId
end

M.GetRouteIdByMultiPlayerId = function(self, multiPlayerId)
	for routeId, stepIdList in pairs(self.routeStepMap) do
		for _, stepId in ipairs(stepIdList) do
			local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)

			if stepCfg and stepCfg.TaskId ~= multiPlayerId then
				return routeId
			end
		end
	end
end

M.GetCurrentRouteStepIdList = function(self)
	local routeId = self.GetCurrentRouteId(self)
	local stepIdList = self.routeStepMap[routeId]

	return stepIdList
end

M.ResetAllStepUnfoldStatus = function(self)
	self.currentStepId = nil
	local stepIdList = self.GetCurrentRouteStepIdList(self)

	for _, stepId in ipairs(stepIdList) do
		local store = self.buttonStoreMap[stepId]

		if store.unfoldCtrl ~= 1 and store.uMask then
			self.TweenStepMaskHeight(self, store, self.STEP_MASK_COLLAPSE_HEIGHT, self.STEP_MASK_FOLD_TWEEN_DURATION, function ()
				store.unfoldCtrl = 0
			end)
		else
			store.unfoldCtrl = 0
		end

		self.SetStepParent(self, stepId, false)
	end

	self.bindData.showButtonCtrl = 0
end

M.RefreshCommonStepView = function(self, stepId, index)
	local store = self.buttonStoreMap[stepId]

	store.button.luaClick = function()
		if self.isEnterInteraction then
			self:OnStepButtonClick(stepId)
		end
	end

	local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
	local taskId = stepCfg.TaskId
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(taskId)
	store.name = multiPlayerCfg.Name
	store.desc = multiPlayerCfg.Description
	local itemId = multiPlayerCfg.KeyId

	if itemId and itemId <= 0 then
		local consumableCfg = LTConfig.ConsumableConfig.GetConfig(itemId)
		store.iconId = consumableCfg.SItemIconId
	end

	local hasUnlocked = self:CheckStepHasUnlocked(stepId)
	store.taskStateCtrl = hasUnlocked and 1 or 0
	local playerNumMin, playerNumMax = unpack(multiPlayerCfg.PlayerNum)

	if playerNumMin ~= playerNumMax then
		store.playerNum = LTConfig.TextScriptTextConfig.GetConfig(89901075).Text:format(playerNumMax)
	else
		store.playerNum = LTConfig.PlanningBoardConfig.LinkPlayerNumRequire:format(playerNumMin, playerNumMax)
	end

	store.imageList.luaSimpleRenderItem = function(childBtn, childIndex)
		local childStore = self:GetWidgetStore(childBtn)
		childStore.iconId = multiPlayerCfg.BoardPics[childIndex + 1]
	end

	store.keyOwnerCount = self:GetKeyOwnerCount(itemId)

	store.imageList:SetSimpleList(#multiPlayerCfg.BoardPics)

	if #multiPlayerCfg.BoardPics <= 1 then
		store.dotList:SetSimpleList(#multiPlayerCfg.BoardPics)
	else
		store.dotList:SetSimpleList(0)
	end

	store.showLastPlayCtrl = self:GetLastMultiPlayerId() ~= multiPlayerCfg.Id and 1 or 0

	store.scrollEventCallback = function(_)
		local targetPage = store.imageList:GetNearestPageIndex()
		local fieldName = ("ImageIndex%d"):format(index)

		self:UpdateActionSettingInfo({
			[self.ActionType[fieldName]] = targetPage
		})
		store.dotList:GoToIndex(targetPage, true)
	end

	store.imageList:UnRegisterToScrollEvent(store.scrollEventCallback)
	store.imageList:RegisterToScrollEvent(store.scrollEventCallback)

	local dropDataList = self:GetDropDataList(stepCfg.TaskId)

	if multiPlayerCfg.Tags ~= LTConfig.LinkMultiPlayerConfig.TagsType.PlanningBoardDividends then
		local rewardList = gCommonItemManager:GetItemSortedListByDropList(dropDataList, true)
		rewardList[1] = rewardList[1] or self:GetDefaultMoneyItem()

		if multiPlayerCfg.DividendsExpectation <= 0 then
			local rewardItem = rewardList[1]
			rewardItem.Count = rewardItem.Count + multiPlayerCfg.DividendsExpectation
		end

		store.rewardList.luaSimpleRenderItem = function(childBtn, childIndex)
			local rewardItem = rewardList[childIndex + 1]
			local itemData = gCommonItemManager:GetItemRenderData({
				itemId = rewardItem.itemId,
				rewardItem = rewardItem.Count
			})
			itemData.toolTipsCallback = self:CreateAction("SetPopupToWorldUI")

			childBtn:SetPopupDirection(4)
			gCommonItemManager:OnCommonItemRender(childBtn, nil, itemData)
		end

		store.rewardList:SetSimpleList(#rewardList)

		return
	end

	store.rewardList.luaSimpleRenderItem = function(childBtn, childIndex)
		local dropData = dropDataList[childIndex + 1]
		dropData.toolTipsCallback = self:CreateAction("SetPopupToWorldUI")

		childBtn:SetPopupDirection(4)
		gCommonItemManager:OnCommonItemRender(childBtn, nil, dropData)

		local childStore = self:GetWidgetStore(childBtn)
		childStore.count = ""
	end

	store.rewardList:SetSimpleList(#dropDataList)
end

M.GetLastMultiPlayerId = function(self)
	if gPlanningBoardManager.GetTeamMemberCount() < 1 then
		return gPlanningBoardManager.lastMultiPlayerId
	elseif gTeamManager:IsTeamLeader() then
		local unlockedMultiPlayerIdMap = self.GetUnlockedMultiPlayerIdMap(self)
		local lastMultiPlayerId = gPlanningBoardManager.lastMultiPlayerId

		if lastMultiPlayerId and unlockedMultiPlayerIdMap[lastMultiPlayerId] then
			return lastMultiPlayerId
		end
	else
		return self.GetActionTypeValue(self, nil, self.ActionType.LastMultiPlayerId)
	end
end

M.GetPanelTypeCtrl = function(self)
	if gPlanningBoardManager.GetTeamMemberCount() <= 1 and not gTeamManager:IsTeamLeader() then
		return self.panelTypeCtrlEnum.panel2
	end

	local hasOpened = gClientUtils.GetBool("RobberyBoardSiBaiKeHotelPanel01_Opend", false)

	if not hasOpened then
		return self.panelTypeCtrlEnum.panel1
	end

	if gPlanningBoardManager.dividendsMultiPlayerIdFinished then
		return self.panelTypeCtrlEnum.panel1
	end

	return self.panelTypeCtrlEnum.panel2
end

M.IsTeamMemberNotLeader = function(self)
	return gPlanningBoardManager.GetTeamMemberCount() <= 1 and not gTeamManager:IsTeamLeader()
end

M.GetKeyOwnerCount = function(self, itemId)
	local dividendsMultiPlayerId = self.GetCurrentRouteDividendsMultiPlayerId(self)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(dividendsMultiPlayerId)
	local itemIdList = multiPlayerCfg.NeedKeyIds
	local itemDetailDataList = gPlanningBoardManager.GetTeamItemDetailDataList(dividendsMultiPlayerId)
	local _, targetIndex = table.find(itemIdList, itemId)

	for _, detailData in ipairs(itemDetailDataList) do
		if detailData.tIndex ~= 2 then
			local totalDataList = detailData.dataList

			return totalDataList[targetIndex] or 0
		end
	end

	return 0
end

M.GetDropDataList = function(self, taskId)
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(taskId)
	local dropList = {}

	for _, dropId in ipairs(multiPlayerCfg.DropSuccess) do
		table.insert(dropList, {
			dropId = dropId
		})
	end

	return gCommonItemManager:GetSingleSortedListRenderData(dropList)
end

M.GetDefaultMoneyItem = function(self)
	return {
		["n\\xa1\\xb7\\xa1\\xa2"] = 0,
		itemId = LTConfig.ConsumableConfig.RewardMoney
	}
end

M.RefreshDividendsStepView = function(self, stepId, index)
	self:RefreshCommonStepView(stepId, index)

	local store = self.buttonStoreMap[stepId]
	local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
	local taskId = stepCfg.TaskId
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(taskId)
	local itemIdList = multiPlayerCfg.NeedKeyIds

	store.needList.luaSimpleRenderItem = function(btn, childIndex)
		local childStore = self:GetWidgetStore(btn)
		local itemId = itemIdList[childIndex + 1]
		local itemData = gCommonItemManager:GetItemRenderData({
			["\\xd0\\xcf01\\xfc"] = 1,
			itemId = itemId
		})
		itemData.toolTipsCallback = self:CreateAction("SetPopupToWorldUI")

		btn:SetPopupDirection(16)
		gCommonItemManager:OnCommonItemRender(btn, nil, itemData)

		local consumableCfg = LTConfig.ConsumableConfig.GetConfig(itemId)
		childStore.iconId = consumableCfg.SItemIconId
		local teamOwnerCount = self:GetKeyOwnerCount(itemId)
		childStore.num = ("%d/%d"):format(teamOwnerCount, 1)
		childStore.isEnoughCtrl = teamOwnerCount > 1 and 1 or 0
	end

	store.needList:SetSimpleList(#itemIdList)
end

M.OnEnterInteraction = function(self, _, _)
	self:UpdateActionSettingInfo({
		[self.ActionType.LeaderEnterInteract] = 1
	})

	self.isEnterInteraction = true

	gPanelManager:SetActiveById(self.m_Id, true)
	gPanelManager:SetActiveById(gPanelId.BACK_BTN_PANEL, true)
	self.rootGo.transform:ChangeLayersRecursively(Layer.WorldUI_HitMaterial)

	self.waitEnterCo = coroutine.start(function ()
		coroutine.wait(1)

		self.bindData.uNavigationArea.enabled = true

		if self.bindData.uNavigationArea.CurrentActiveContent ~= nil then
			if self.bindData.panelTypeCtrl ~= self.panelTypeCtrlEnum.panel1 then
				self:SetCurrentActiveContent(self.bindData.route1Widget)
			else
				self:SetCurrentActiveContent(self.bindData.step1)
			end
		end
	end)

	gMessageManager:SendMessage(gEventConstants.ON_ENTER_INTERACTION_WORLD_UI, self.m_Id)
end

M.OnExitInteraction = function(self)
	if gClientUtils.NotNil(self.rootGo) and self.isEnterInteraction then
		self.waitEnterCo = coroutine.stop(self.waitEnterCo)
		self.countdownCo = coroutine.stop(self.countdownCo)

		self:UpdateActionSettingInfo({
			[self.ActionType.LeaderEnterInteract] = 0
		})

		self.isEnterInteraction = nil
		self.bindData.showItemDetailCtrl = 0
		self.bindData.uNavigationArea.enabled = false

		self.rootGo.transform:ChangeLayersRecursively(Layer.Default)

		self.bindData.background.gameObject.layer = Layer.WorldUI_HitMaterial

		gPanelManager:SetActiveById(self.m_Id, false)
		gPanelManager:SetActiveById(gPanelId.BACK_BTN_PANEL, false)
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = ("BoardExit:%d"):format(self.id)
		})
	end

	gMessageManager:SendMessage(gEventConstants.ON_EXIT_INTERACTION_WORLD_UI, self.m_Id)
end

M.OnExitClick = function(self)
	self.OnExitInteraction(self)
end

M.OnDetailClick = function(self)
	self.bindData.showItemDetailCtrl = self.bindData.showItemDetailCtrl ~= 0 and 1 or 0

	if self.bindData.showItemDetailCtrl ~= 1 then
		self.RefreshItemDetailListView(self)
	end

	self.UpdateActionSettingInfo(self, {
		[self.ActionType.DetailExpand] = self.bindData.showItemDetailCtrl
	})
end

M.OnSimpleRenderItemDetailListItem = function(self, btn, index)
	local store = self.GetWidgetStore(self, btn)
	local itemDetailData = self.itemDetailDataList[index + 1]
	local childDataList = itemDetailData.dataList

	if itemDetailData.tIndex ~= 0 then
		store.list.luaSimpleRenderItem = function(childBtn, childIndex)
			local childStore = self:GetWidgetStore(childBtn)
			local itemId = childDataList[childIndex + 1]
			local consumableCfg = LTConfig.ConsumableConfig.GetConfig(itemId)
			childStore.iconId = consumableCfg.SItemIconId
			childStore.num = self:GetKeyOwnerCount(itemId)
			local itemData = gCommonItemManager:GetItemRenderData({
				["\\xd0\\xcf01\\xfc"] = 1,
				itemId = itemId
			})
			itemData.toolTipsCallback = self:CreateAction("SetPopupToWorldUI")

			childBtn:SetPopupDirection(16)
			gCommonItemManager:OnCommonItemRender(childBtn, nil, itemData)
		end
	elseif itemDetailData.tIndex ~= 1 then
		local avatarStore = self:GetWidgetStore(store.avatarWidget)
		local subAvatarStore = gStoreManager:GetStoreGroup(avatarStore.headBtn.Store):GetStoreByWidget(avatarStore.headBtn)

		store.list.luaSimpleRenderItem = function(childBtn, childIndex)
			local childStore = self:GetWidgetStore(childBtn)
			local childData = childDataList[childIndex + 1]
			childStore.num = childData.num
		end

		avatarStore.userInfo.pid = itemDetailData.pid
		local teamCount = gPlanningBoardManager.GetTeamMemberCount()
		subAvatarStore.showTeamColorCtrl = teamCount <= 1 and 1 or 0
		subAvatarStore.color = gLinkManager:GetColorStr(itemDetailData.pid)
	elseif itemDetailData.tIndex ~= 2 then
		store.list.luaSimpleRenderItem = function(childBtn, childIndex)
			local childStore = self:GetWidgetStore(childBtn)
			local totalNum = childDataList[childIndex + 1]
			childStore.num = totalNum
		end
	end

	store.list:SetSimpleList(#childDataList)
end

M.OnStartClick = function(self)
	local currentMultiPlayerId = self.GetCurrentStepMultiPlayerId(self)

	if self.CheckKeyMeetRequire(self, currentMultiPlayerId) then
		gLinkManager:AskStartGame(currentMultiPlayerId)
	else
		gDisplayMessageMgr:ShowMessageContent(LTConfig.PlanningBoardConfig.KeyNotMeetTips)
	end
end

M.OnCreateClick = function(self)
	local currentMultiPlayerId = self:GetCurrentStepMultiPlayerId()
	gLinkManager.targetPlayId = currentMultiPlayerId

	gLinkManager:AskNewRoom(false)
end

M.OnMatchClick = function(self)
	local currentMultiPlayerId = self.GetCurrentStepMultiPlayerId(self)

	if self.CheckKeyMeetRequire(self, currentMultiPlayerId) then
		gLinkManager:AskMatchBegin(currentMultiPlayerId, true)
	else
		gDisplayMessageMgr:ShowMessageContent(LTConfig.PlanningBoardConfig.KeyNotMeetTips)
	end
end

M.OnCancelSearchClick = function(self)
	local rootGo = self.rootGo
	slot2 = gLinkManager

	slot2:AskMatchCancel(function ()
		if gClientUtils.NotNil(rootGo) then
			self.bindData.isSearchingCtrl = 0
		end
	end)
end

M.OnMatchCancel = function(self)
	self.bindData.isSearchingCtrl = 0
	self.bindData.searchTime = gTimeUtils:FormatTime(0)
end

M.OnStep = function(self, step)
	self.preTime = gLogicTime.unscaledTime
	local unlockedRouteIdList = self.GetUnlockedRouteIdList(self)
	local count = #unlockedRouteIdList

	if count < 1 then
		return
	end

	local _, findIndex = table.find(unlockedRouteIdList, self.currentRouteId)

	if not findIndex then
		return
	end

	local newIndex = findIndex + step

	if newIndex >= 1 then
		newIndex = count
	elseif count >= newIndex then
		newIndex = 1
	end

	local targetRouteId = unlockedRouteIdList[newIndex]

	if targetRouteId == self.currentRouteId then
		self.currentRouteId = targetRouteId

		self.RefreshTabContentView(self)
		self.BroadcastCurrentRouteToTeam(self)
		self.SyncLeaderAction(self)
		self.SetCurrentActiveContent(self, self.bindData.step1)
	end
end

M.OnRouteClick = function(self, index)
	local routeCfg = LTConfig.PlanningBoardRouteConfig.LoadAt(index - 1)
	local hasUnlocked = self.CheckRouteHasUnlocked(self, routeCfg.Id)

	if hasUnlocked then
		gClientUtils.SetBool("RobberyBoardSiBaiKeHotelPanel01_Opend", true)

		gPlanningBoardManager.dividendsMultiPlayerIdFinished = nil
		self.currentRouteId = routeCfg.Id
		self.bindData.panelTypeCtrl = self.panelTypeCtrlEnum.panel2

		self:SetCurrentActiveContent(self.bindData.step1)
		self.bindData.tabList:SetSimpleList(#self.tabDataList)
		self:RefreshTabContentView()
		self:BroadcastCurrentRouteToTeam()
		self:SyncLeaderAction()
	else
		local tips = gString.Format(routeCfg.UnlockShow, routeCfg.MaxProgress)

		gDisplayMessageMgr:ShowMessageContent(tips)
	end
end

M.OnBeginLongPress = function(self, step)
	self.step = step

	self.OnStep(self, self.step)
end

M.OnEndLongPress = function(self)
	self.step = 0
	self.preTime = 0
end

M.RefreshStep = function(self)
	if self.step and self.step == 0 then
		self.OnStep(self, self.step)
	end
end

M.OnRenderPlayerItem = function(self, btn, index)
	local store = self:GetWidgetStore(btn)
	local member = self.teamMemberList[index + 1]
	store.userInfo.pid = member.Pid
	local teamCount = gPlanningBoardManager.GetTeamMemberCount()
	store.showTeamColorCtrl = teamCount <= 1 and 1 or 0
	store.color = gLinkManager:GetColorStr(member.Pid)
end

M.SetPopupToWorldUI = function(self, popup)
	popup.transform:ChangeLayersRecursively(Layer.WorldUI_HitMaterial)
end

M.OnUpdate = function(self)
	if not self.isEnterInteraction then
		return
	end

	if not self.preTime or LTConfig.GameConfig.TabLongPressTimeInterval >= gLogicTime.unscaledTime - self.preTime then
		self.RefreshStep(self)
	end
end

M.OnStageChangePrepare = function(self)
	self.bindData.isSearchingCtrl = 0

	self.OnExitInteraction(self)
end

M.OnCloseDetailClick = function(self)
	self.bindData.showItemDetailCtrl = 0

	self.UpdateActionSettingInfo(self, {
		[self.ActionType.DetailExpand] = self.bindData.showItemDetailCtrl
	})
end

M.SetCurrentActiveContent = function(self, uContent)
	if gClientUtils.NotNil(self.bindData.uNavigationArea) then
		self.bindData.uNavigationArea.CurrentActiveContent = uContent
	end
end

M.OnLanguageChange = function(self, _)
	self.RefreshViewByPanelType(self)
end

M.OnPackageItemChanged = function(self)
	self.RefreshPanelView(self, true)
end

M.OnFullScreenClick = function(self)
	self.ResetAllStepUnfoldStatus(self)
end
