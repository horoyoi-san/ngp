-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SeasonLogMainPanelStore.lua
-- Decompiled from: 00878_SeasonLogMainPanelStore.lua_9b1db242055a.luajit

local ScriptText = LTConfig.TextScriptTextConfig
C_SeasonLogMainPanelStore = DefClass("C_SeasonLogMainPanelStore", C_SeasonLogMainPanelStore, C_StoreGroup)
GroupName2Class.SeasonLogMainPanelStore = C_SeasonLogMainPanelStore
local M = C_SeasonLogMainPanelStore
local Consts = gClientConst
local BOOL2CTL = Consts.BOOL2CTL
local TREE_TEMPLATE = {
	["\\-q_"] = 1,
	["N#nP"] = 2,
	["V-~P"] = 3,
	I6xK = 0
}
local TREE_NODE_TYPE = {
	["N#nP"] = "n#nP",
	["}\\xa6\\xa3\\xbc\\xb3"] = "]\\xa6\\xa3\\xbc\\xb3",
	["V-~P"] = "v-~P",
	["\\-q_"] = "|-q_"
}

M.ctor = function(self)
	self.pendingSchemeIdx = nil
end

M.DefineAllVariables = function(self)
	self.activityDataList = {}
	self.rewardDataList = {}
	self.currentViewIndex = nil
	self.claimableRewardList = nil
	self.currentDropList = nil
	self.schemeIds = {}
	self.currentSchemeIdx = 1
	self.currentSchemeId = 0
	self.currentSchemeName = ""
	self.phaseDataList = {}
	self.taskTypeGroupsByPhaseId = {}
	self.foldState = {}
	self._allFoldExpanded = true
	self.treeDataList = {}
	self.visibleTaskNodeIndexById = {}
	self.taskNodeMetaById = {}
	self.selectedTaskId = 0
	self.selectedTaskCfg = nil
	self.taskRewardDropList = {}
	self.tabStore = nil
	self.defaultExpandAll = false
	self.taskInfoStore = nil
	self.taskInfoContentStore = nil
	self._subWidgetsRegistered = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)

	self.mgr = gOnlineSeasonProgressMgr

	self.RegisterWidget(self)

	self.msgEvents = {
		[gEventConstants.ONLINE_SEASON_PROGRESS_STATE_CHANGED] = self.CreateAction(self, "OnSeasonStateChanged"),
		[gEventConstants.ON_ACTIVE_DEVICE_CHANGED] = self.CreateAction(self, "OnActiveDeviceChanged")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBack")
	self.bindData.claimAllBtn.luaClick = self.CreateAction(self, "OnClickClaimAll")
	self.bindData.prevLevelBtn.luaClick = self.CreateActionWithArgs(self, "OnClickSwitchLevel", -1)
	self.bindData.nextLevelBtn.luaClick = self.CreateActionWithArgs(self, "OnClickSwitchLevel", 1)
	self.bindData.levelRewardList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderLevelRewardItem")
	self.bindData.levelRewardList.luaSimpleClick = self.CreateAction(self, "OnClickLevelReward")
	self.bindData.activityList.onGetTIndex = self.CreateAction(self, "OnGetActivityTIndex")
	self.bindData.activityList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderActivity")
	self.bindData.activityList.luaDynamicRenderItem = self.CreateAction(self, "OnRenderActivity")
	self.bindData.activityList.luaSimpleClick = self.CreateAction(self, "OnClickActivity")

	if self.bindData.countDown then
		self.bindData.countDown.luaFinished = self.CreateAction(self, "OnCountDownFinished")
	end

	if self.bindData.openAllBtn then
		self.bindData.openAllBtn.luaClick = self.CreateAction(self, "UnfoldAllBtn")
	end

	if self.bindData.closeAllBtn then
		self.bindData.closeAllBtn.luaClick = self.CreateAction(self, "FoldAllBtn")
	end
end

M.OnShow = function(self, panelId, data)
	if not self.mgr:HasActiveSeason() then
		print_error("[SeasonLogMain] 无激活赛季，关闭面板")

		if data and data.onShowCallback then
			data.onShowCallback()
		end

		gPanelManager:Close(self.m_Id)

		return
	end

	self.schemeIds = self.mgr:GetTaskSchemeIds()
	self.currentSchemeIdx = self.pendingSchemeIdx or 1
	self.pendingSchemeIdx = nil

	self:RefreshAll()
	self:InitTabs()
	self.mgr:RefreshRedDot()

	if data and data.onShowCallback then
		local onShowCallback = data.onShowCallback
		data.onShowCallback = nil

		onShowCallback()
	end
end

M.OnClose = function(self)
	self.StopCountDown(self)
	self.ClearMessageEvents(self)
	self.DefineAllVariables(self)
end

M.RegisterSubStoreWidgets = function(self)
	if self._subWidgetsRegistered then
		return
	end

	if not self.bindData.taskInfoRoot then
		print_notice("[SeasonLogMain][DBG] RegisterSubStoreWidgets: taskInfoRoot 为 nil")

		return
	end

	local infoStore = self.GetStoreByWidget(self, self.bindData.taskInfoRoot)

	if not infoStore then
		print_notice("[SeasonLogMain][DBG] RegisterSubStoreWidgets: GetStoreByWidget(taskInfoRoot) 返回 nil")

		return
	end

	self._subWidgetsRegistered = true
	self.taskInfoStore = infoStore
	local taskInfoContent = infoStore.taskInfoRect.content
	self.taskInfoContentStore = gStoreManager:GetStoreGroup(taskInfoContent.Store):GetStoreByWidget(taskInfoContent)

	print_notice("[SeasonLogMain][DBG] RegisterSubStoreWidgets 成功: infoStore=", tostring(infoStore), " contentStore=", tostring(self.taskInfoContentStore), " rewardList=", tostring(infoStore.rewardList), " claimBtn=", tostring(infoStore.claimBtn))

	if infoStore.rewardList then
		infoStore.rewardList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderTaskRewardItem")
		infoStore.rewardList.luaSimpleClick = self.CreateAction(self, "OnClickTaskRewardItem")
	end

	if infoStore.claimBtn then
		infoStore.claimBtn.luaClick = self.CreateAction(self, "OnClickClaimTaskReward")
	end

	if infoStore.locateBtn then
		infoStore.locateBtn.luaClick = self.CreateActionWithArgs(self, "OnClickJumpToDetail", 0)
	end

	if infoStore.acceptBtn then
		infoStore.acceptBtn.luaClick = self.CreateAction(self, "OnClickAcceptTask")
	end
end

M.InitTabs = function(self)
	self.tabStore = self.SubGroup and self.SubGroup.CommonTabSingleStore

	if not self.tabStore then
		print_error("[SeasonLogMain] CommonTabSingleStore not found")

		return
	end

	self.defaultExpandAll = gClientUtils.CheckIsGamePadMode()
	local tabList = {}

	for i, schemeId in ipairs(self.schemeIds) do
		local schemeCfg = self.mgr:GetSchemeConfig(schemeId)
		tabList[i] = {
			id = schemeId,
			title = schemeCfg and schemeCfg.Name or ""
		}
	end

	self.defaultExpandAll = gClientUtils.CheckIsGamePadMode()

	self:_BuildSchemeData(self.schemeIds[self.currentSchemeIdx])
	self:_InitFoldState(self.defaultExpandAll)
	self:_BuildTreeData()

	local selectedTreeIndex = self:_FindPreferredVisibleTaskNodeIndex()

	self.tabStore:SetData(tabList, self.treeDataList, self.currentSchemeIdx - 1, selectedTreeIndex or -1, self:CreateAction(self.OnTabChanged), self:CreateAction(self.OnRenderTabItem), nil, true)

	if selectedTreeIndex ~= nil then
		self.ClearTaskSelection(self)
	end

	self._RefreshFoldButtons(self)
end

M._RefreshCurrentTree = function(self, preferCurrentSelectedTask)
	if not self.tabStore then
		return
	end

	self:_BuildTreeData()
	self.tabStore:SetTabList(self.treeDataList, true)
	self:_SelectTreeTask(preferCurrentSelectedTask)
	self:_RefreshFoldButtons()
end

M._SelectTreeTask = function(self, preferCurrentSelectedTask)
	local selectedIndex = nil

	if preferCurrentSelectedTask and self.selectedTaskId <= 0 then
		selectedIndex = self.visibleTaskNodeIndexById[self.selectedTaskId]
	end

	if selectedIndex ~= nil then
		selectedIndex = self._FindPreferredVisibleTaskNodeIndex(self)
	end

	if selectedIndex == nil then
		self.tabStore:SetSelectedIndex(selectedIndex, true, true)
		self:_FocusTreeItem(selectedIndex)

		return
	end

	for index, node in ipairs(self.treeDataList) do
		if node.nodeType ~= TREE_NODE_TYPE.Fold then
			local foldIndex = index - 1

			self.tabStore:SetSelectedIndex(foldIndex, false, true)
			self:_FocusTreeItem(foldIndex)

			return
		end
	end

	self.tabStore:SetSelectedIndex(-1, false, true)
	self:ClearTaskSelection()
end

M._FocusTreeItem = function(self, index)
	if not self.tabStore or index ~= nil or index >= 0 then
		return
	end

	local tree = self.tabStore.bindData and self.tabStore.bindData.subTabTree

	if not tree then
		return
	end

	local _, btn = tree.TryGetChildAt(tree, index, nil)

	if not btn or not btn.cachedNavArea then
		return
	end

	btn.cachedNavArea.CurrentActiveContent = btn
end

M.OnTabChanged = function(self, uList, isSub)
	if not self.tabStore then
		return
	end

	if isSub then
		slot3 = ipairs
		slot5 = self.tabStore.cacheSubList or {}

		for _, item in slot3(slot5) do
			if item.nodeType ~= TREE_NODE_TYPE.Fold and item.foldKey then
				self.foldState[item.foldKey] = item.expanded == true
			end
		end

		self:_RefreshAllFoldExpanded()
		self:_RefreshFoldButtons()

		local node = self.tabStore:GetSubSelectedItem()

		if not node then
			self.ClearTaskSelection(self)

			return
		end

		return
	end

	local newIdx = uList.selectedIndex + 1

	if newIdx == self.currentSchemeIdx then
		self.SwitchScheme(self, newIdx)
	end
end

M.OnRenderTabItem = function(self, btn, index, data, store, isSub, uList)
	if not isSub then
		local schemeId = self.schemeIds[index + 1]

		if schemeId then
			local phaseSchemeId = self.mgr:GetPhaseSchemeIdByTaskSchemeId(schemeId)

			uList:SetItemId(index, phaseSchemeId)

			btn.redKey = ("SeasonLog.Scheme:%d"):format(schemeId)
		end

		return
	end

	if not data then
		return
	end

	if data.nodeType ~= TREE_NODE_TYPE.Phase then
		self._RenderPhaseNode(self, btn, store, data)
	elseif data.nodeType ~= TREE_NODE_TYPE.Fold then
		self._RenderFoldNode(self, btn, store, data)
	elseif data.nodeType ~= TREE_NODE_TYPE.Lock then
		self._RenderLockNode(self, btn, store, data)
	else
		self._RenderTaskNode(self, btn, store, data)
	end
end

M._RenderPhaseNode = function(self, btn, store, node)
	local title = node.title or ""
	store.title = title
	btn.redKey = ("SeasonLog.Phase:%d"):format(node.id)
end

M._RenderFoldNode = function(self, btn, store, node)
	local title = node.title or ""
	store.title = title
	local isLockedNode = node.nodeType ~= TREE_NODE_TYPE.Lock
	store.lockCtrl = BOOL2CTL[isLockedNode]
	store.keyTaskCntText = node.keyTaskCntText or ""
	local nav = btn.navigation
	nav.mode = self._allFoldExpanded and 0 or 3
	btn.navigation = nav

	if isLockedNode then
		btn.redKey = ""
	else
		btn.redKey = ("SeasonLog.TaskType:%d"):format(node.id)
	end
end

M._RenderTaskNode = function(self, btn, store, node)
	local title = node.title or ""
	local isLockedNode = node.nodeType ~= TREE_NODE_TYPE.Lock
	store.title = title

	if node.taskCfg then
		local maxProgress = node.taskCfg.MaxProgress or 0
		local progress = self.mgr:GetTaskProgress(node.taskCfg)
		store.progress = string.format("(%d/%d)", progress, maxProgress)
	else
		store.progress = ""
	end

	store.lockCtrl = BOOL2CTL[isLockedNode]
	store.keyTaskCntText = node.keyTaskCntText or ""
	store.ordinaryTaskCntText = node.ordinaryTaskCntText or ""

	if isLockedNode or not node.taskCfg then
		btn.redKey = ""

		return
	end

	local taskId = node.taskCfg.Id

	if node.taskCfg.IsKeyTask then
		store.typeCtrl = 0
	elseif node.taskCfg.CanRepeatComplete then
		store.typeCtrl = 2
	else
		store.typeCtrl = 1
	end

	local state = node.taskState
	local STS = self.mgr.SeasonTaskState

	if state ~= STS.Unlocked then
		store.modeCtrl = 0
	elseif state ~= STS.InProgress then
		store.modeCtrl = 1
	elseif state ~= STS.Completed then
		store.modeCtrl = 2
	elseif state ~= STS.Claimed then
		store.modeCtrl = 3
	end

	btn.redKey = ("SeasonLog.Task:%d"):format(taskId)
	local rewardRenderData = nil

	if node.taskCfg and node.taskCfg.Reward and node.taskCfg.Reward <= 0 then
		rewardRenderData = gCommonItemManager:GetSingleSortedListRenderData(node.taskCfg.Reward) or {}
		local isLock = state ~= STS.Locked
		local isOwned = state ~= STS.Claimed

		for _, rd in ipairs(rewardRenderData) do
			rd.isLock = isLock
			rd.IsOwned = isOwned
		end
	end

	if store.acceptBtn then
		store.acceptBtn.luaClick = self.CreateActionWithArgs(self, "OnClickAcceptTask", taskId)
	end

	if store.locateBtn then
		store.locateBtn.luaClick = self.CreateActionWithArgs(self, "OnClickJumpToDetail", taskId)
	end

	if store.claimRewardBtn then
		store.claimRewardBtn.luaClick = self.CreateActionWithArgs(self, "OnClickClaimTaskReward", taskId)
	end

	if store.rewardList then
		store.rewardList.EnableImmediatelyCommit = true
		store.rewardList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderRewardItem", rewardRenderData)

		store.rewardList:SetSimpleList(rewardRenderData and #rewardRenderData or 0)
	end
end

M._RenderLockNode = function(self, btn, store, node)
	store.keyTaskCntText = node.keyTaskCntText or ""
end

M.OnRenderRewardItem = function(self, rewardRenderData, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.EnableImmediatelyCommit(store, true)
	end

	local data = rewardRenderData and rewardRenderData[index + 1]

	if data then
		gCommonItemManager:OnCommonItemRender(btn, index, data)
	end
end

M.SwitchScheme = function(self, schemeIdx)
	local schemeId = self.schemeIds[schemeIdx]

	if not schemeId then
		return
	end

	self.currentSchemeIdx = schemeIdx
	self.selectedTaskId = 0
	self.selectedTaskCfg = nil

	self.ShowTaskInfo(self, false)
	self._BuildSchemeData(self, schemeId)
	self._InitFoldState(self, self.defaultExpandAll)
	self._RefreshCurrentTree(self, false)
end

M.OnSeasonStateChanged = function(self)
	self.RefreshAll(self)

	if self.currentSchemeId == 0 then
		self.RefreshCurrentScheme(self)
	end
end

M.RefreshCurrentScheme = function(self)
	self._BuildSchemeData(self, self.currentSchemeId)
	self._RefreshCurrentTree(self, true)
end

M.SelectTask = function(self, taskCfg)
	if not taskCfg then
		return
	end

	print_notice("[SeasonLogMain][DBG] SelectTask taskId=", taskCfg.Id)

	self.selectedTaskId = taskCfg.Id
	self.selectedTaskCfg = taskCfg

	self.ShowTaskInfo(self, true)
	self.RefreshTaskDetail(self)
end

M.ClearTaskSelection = function(self)
	self.selectedTaskId = 0
	self.selectedTaskCfg = nil

	self.ShowTaskInfo(self, false)
end

M.ShowTaskInfo = function(self, visible)
	print_notice("[SeasonLogMain][DBG] ShowTaskInfo visible=", visible, " taskInfoRoot=", tostring(self.bindData.taskInfoRoot))

	if self.bindData.taskInfoRoot == nil then
		self.bindData.taskInfoRoot:SetActiveFastest(visible)
	end
end

M.RefreshTaskDetail = function(self)
	local cfg = self.selectedTaskCfg

	if not cfg then
		print_error("[SeasonLogMain][DBG] RefreshTaskDetail: selectedTaskCfg 为 nil")

		return
	end

	local infoStore = self.taskInfoStore

	if not infoStore or not self.taskInfoContentStore then
		print_error("[SeasonLogMain][DBG] RefreshTaskDetail: infoStore=", tostring(infoStore), " contentStore=", tostring(self.taskInfoContentStore), " (有一个为 nil，提前返回)")

		return
	end

	local state = self.mgr:GetTaskState(cfg.Id)
	local STS = self.mgr.SeasonTaskState
	infoStore.taskNameText = cfg.Title or ""
	infoStore.taskTypeText = self.currentSchemeName
	self.taskInfoContentStore.taskDesText = self.mgr:FormatTaskText(cfg.Description, cfg.MaxProgress)

	if state ~= STS.Locked then
		infoStore.claimBtnCtrl = 0
		infoStore.taskBtnFinishCtrl = 2
	elseif state ~= STS.Unlocked then
		infoStore.claimBtnCtrl = 2
		infoStore.taskBtnFinishCtrl = 2
	elseif state ~= STS.InProgress then
		infoStore.claimBtnCtrl = 0
		infoStore.taskBtnFinishCtrl = 1
	elseif state ~= STS.Completed then
		infoStore.claimBtnCtrl = 1
		infoStore.taskBtnFinishCtrl = 2
	elseif state ~= STS.Claimed then
		infoStore.claimBtnCtrl = 0
		infoStore.taskBtnFinishCtrl = 0
	end

	self.taskRewardDropList = {}

	if cfg.Reward and cfg.Reward <= 0 then
		self.taskRewardDropList = gCommonItemManager:GetSingleSortedListRenderData(cfg.Reward) or {}
	end

	if infoStore.rewardList then
		infoStore.rewardList:SetSimpleList(#self.taskRewardDropList)
	end
end

M.OnRenderTaskRewardItem = function(self, btn, index)
	local data = self.taskRewardDropList[index + 1]

	if data then
		gCommonItemManager:OnCommonItemRender(btn, index, data)
	end
end

M.OnClickTaskRewardItem = function(self, btn, index)
end

M.OnClickClaimTaskReward = function(self, taskId)
	if taskId < 0 then
		return
	end

	local STS = self.mgr.SeasonTaskState

	if self.mgr:GetTaskState(taskId) == STS.Completed then
		return
	end

	local oldLevel = self.mgr.seasonLevel
	slot4 = self.mgr

	slot4:AskTakeTaskReward(taskId, function (success)
		if success then
			self:OnSeasonStateChanged()
			self:_SwitchToCurrentLevelIfLevelChanged(oldLevel)
		end
	end)
end

M.OnClickJumpToDetail = function(self, taskId)
	taskId = taskId or self.selectedTaskId or 0
	local gameplayId = 0

	if taskId <= 0 then
		local taskCfg = LTConfig.OnlineSeasonProgressPrimaryTasksConfig.GetConfig(taskId)
		gameplayId = taskCfg and taskCfg.JumpToLinkGameplay or 0
	end

	if not gameplayId or gameplayId < 0 then
		print_error("[SeasonLogMain] 跳转玩法详情: taskId=%d 未配置 JumpToLinkGameplay，暂不切换 HotCenter 详情页", taskId)
		gPanelManager:Close(self.m_Id)

		return
	end

	local gameplayCfg = LTConfig.LinkHubGameplayConfig.GetConfig(gameplayId)
	local gameType = nil

	if gameplayCfg then
		gameType = gameplayCfg.HubID
	elseif LTConfig.LinkHubRobHubConfig.GetConfig(gameplayId) then
		gameType = Consts.HotCenterOnlineGameType.Rob
	elseif LTConfig.PublicEventConfig.GetConfig(gameplayId) then
		gameType = Consts.HotCenterOnlineGameType.PublicEvent
	end

	self.pendingSchemeIdx = self.currentSchemeIdx

	gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_SWITCH_SUB_PANEL, {
		mainType = Consts.HotCenterType.Online,
		subType = Consts.HotCenterSubType.OnlineDetail,
		gameType = gameType,
		gameplayId = gameplayId,
		returnPanelId = gPanelId.SEASON_LOG_MAIN_PANEL
	})
	gPanelManager:Close(self.m_Id)
end

M.OnClickAcceptTask = function(self, taskId)
	if taskId < 0 then
		return
	end

	local STS = self.mgr.SeasonTaskState

	if self.mgr:GetTaskState(taskId) == STS.Unlocked then
		return
	end

	slot3 = self.mgr

	slot3:AskAcceptOnlineSeasonTask(taskId, function (success)
		if success then
			self:OnSeasonStateChanged()
		end
	end)
end

M._AppendTreeNode = function(self, node)
	node.selected = false
	self.treeDataList[#self.treeDataList + 1] = node

	return #self.treeDataList - 1
end

M._BuildSchemeData = function(self, schemeId)
	if not schemeId then
		self.currentSchemeId = 0
		self.currentSchemeName = ""
		self.phaseDataList = {}
		self.taskTypeGroupsByPhaseId = {}

		return
	end

	self.currentSchemeId = schemeId
	local schemeCfg = self.mgr:GetSchemeConfig(schemeId)
	self.currentSchemeName = schemeCfg and schemeCfg.Name or ""
	local phaseSchemeId = self.mgr:GetPhaseSchemeIdByTaskSchemeId(schemeId)
	self.phaseDataList = self.mgr:GetPhasesByScheme(phaseSchemeId)
	self.taskTypeGroupsByPhaseId = {}

	for _, phaseCfg in ipairs(self.phaseDataList) do
		local tasks = self.mgr:GetTasksByPhase(phaseCfg.Id)
		local typeOrder = {}
		local typeMap = {}

		for _, taskCfg in ipairs(tasks) do
			local taskType = taskCfg.TaskType or ""

			if not typeMap[taskType] then
				typeMap[taskType] = {}
				typeOrder[#typeOrder + 1] = taskType
			end

			typeMap[taskType][#typeMap[taskType] + 1] = {
				cfg = taskCfg,
				state = self.mgr:GetTaskState(taskCfg.Id)
			}
		end

		local groups = {}

		for _, taskType in ipairs(typeOrder) do
			local taskList = typeMap[taskType]

			table.sort(taskList, function (a, b)
				local getPriority = function(state)
					local STS = self.mgr.SeasonTaskState

					if state ~= STS.Completed then
						return 0
					elseif state ~= STS.InProgress then
						return 1
					elseif state ~= STS.Unlocked then
						return 2
					elseif state ~= STS.Locked then
						return 3
					else
						return 4
					end
				end

				local aPriority = getPriority(a.state)
				local bPriority = getPriority(b.state)

				if aPriority == bPriority then
					return aPriority <= bPriority
				end

				return a.cfg.Id <= b.cfg.Id
			end)

			groups[#groups + 1] = {
				taskType = taskType,
				title = taskType,
				tasks = taskList
			}
		end

		self.taskTypeGroupsByPhaseId[phaseCfg.Id] = groups
	end
end

M._BuildTreeData = function(self)
	self.treeDataList = {}
	self.visibleTaskNodeIndexById = {}
	self.taskNodeMetaById = {}

	for _, phaseCfg in ipairs(self.phaseDataList) do
		if not self.IsPhaseUnlocked(self, phaseCfg) then
			local prevPhaseId = self:_GetPrevPhaseId(phaseCfg.Id)
			local keyDone, ordinaryDone = self:_CountCompletedTasksInPhase(prevPhaseId)

			self:_AppendTreeNode({
				["FTȲ\\x88\\xb9\\xc5\\xed"] = true,
				["I\\xab\\xb2\\xbb\\xbe"] = 1,
				nodeType = TREE_NODE_TYPE.Lock,
				id = string.format("phase_lock_%s", tostring(phaseCfg.Id)),
				phaseId = phaseCfg.Id,
				title = phaseCfg.Description or "",
				keyTaskCntText = string.format("%d/%d", keyDone, phaseCfg.KeyTaskCount or 0),
				ordinaryTaskCntText = string.format("%d/%d", ordinaryDone, phaseCfg.OrdinaryTaskCount or 0),
				tIndex = TREE_TEMPLATE.Lock
			})
		else
			self:_AppendTreeNode({
				["FTȲ\\x88\\xb9\\xc5\\xed"] = true,
				["I\\xab\\xb2\\xbb\\xbe"] = 0,
				["\\xae\\xa9\\xaad:\\xfb7"] = true,
				nodeType = TREE_NODE_TYPE.Phase,
				id = phaseCfg.Id,
				title = phaseCfg.Description or string.format(ScriptText.GetConfig(89901474).Text, phaseCfg.PhaseId or 0),
				tIndex = TREE_TEMPLATE.Step
			})

			local groups = self.taskTypeGroupsByPhaseId[phaseCfg.Id] or {}

			for groupIdx, group in ipairs(groups) do
				local foldKey = self:_FoldKey(phaseCfg.Id, group.taskType)
				local isCollapsed = self.foldState[foldKey] ~= true

				self:_AppendTreeNode({
					["FTȲ\\x88\\xb9\\xc5\\xed"] = false,
					["I\\xab\\xb2\\xbb\\xbe"] = 1,
					nodeType = TREE_NODE_TYPE.Fold,
					id = self:_GetTaskTypeUniqueId(phaseCfg.Id, groupIdx),
					phaseId = phaseCfg.Id,
					foldKey = foldKey,
					title = group.title or group.taskType,
					tIndex = TREE_TEMPLATE.Fold,
					expanded = not isCollapsed
				})

				local isVisible = not isCollapsed
				local taskTypeUniqueId = self:_GetTaskTypeUniqueId(phaseCfg.Id, groupIdx)
				local STS = self.mgr.SeasonTaskState

				for _, taskData in ipairs(group.tasks) do
					if taskData.state == STS.Locked then
						local treeIndex = self:_AppendTreeNode({
							["I\\xab\\xb2\\xbb\\xbe"] = 2,
							nodeType = TREE_NODE_TYPE.Task,
							id = taskData.cfg.Id,
							phaseId = phaseCfg.Id,
							foldKey = foldKey,
							taskTypeUniqueId = taskTypeUniqueId,
							taskCfg = taskData.cfg,
							taskState = taskData.state,
							title = self.mgr:FormatTaskText(taskData.cfg.Description, taskData.cfg.MaxProgress),
							tIndex = TREE_TEMPLATE.Task,
							visible = isVisible
						})
						self.taskNodeMetaById[taskData.cfg.Id] = {
							phaseId = phaseCfg.Id,
							foldKey = foldKey,
							visible = isVisible
						}

						if isVisible then
							self.visibleTaskNodeIndexById[taskData.cfg.Id] = treeIndex
						end
					end
				end
			end
		end
	end
end

M._FindPreferredVisibleTaskNodeIndex = function(self)
	local STS = self.mgr.SeasonTaskState
	local firstCompleted, firstInProgress, firstAny = nil

	for index, node in ipairs(self.treeDataList) do
		if node.nodeType ~= TREE_NODE_TYPE.Task and node.taskCfg and node.visible then
			if node.taskState ~= STS.Completed and firstCompleted ~= nil then
				firstCompleted = index - 1
			end

			if node.taskState ~= STS.InProgress and firstInProgress ~= nil then
				firstInProgress = index - 1
			end

			if firstAny ~= nil then
				firstAny = index - 1
			end
		end
	end

	return firstCompleted or firstInProgress or firstAny
end

M._GetTaskTypeUniqueId = function(self, phaseId, groupIdx)
	return phaseId * 100 + groupIdx
end

M._FoldKey = function(self, phaseId, taskType)
	return phaseId .. "_" .. tostring(taskType)
end

M.IsPhaseUnlocked = function(self, phaseCfg)
	if not phaseCfg then
		return false
	end

	local STS = self.mgr.SeasonTaskState
	local tasks = self.mgr:GetTasksByPhase(phaseCfg.Id)

	for _, taskCfg in ipairs(tasks) do
		if self.mgr:GetTaskState(taskCfg.Id) == STS.Locked then
			return true
		end
	end

	return false
end

M._GetPrevPhaseId = function(self, phaseId)
	for i, phaseCfg in ipairs(self.phaseDataList) do
		if phaseCfg.Id ~= phaseId then
			local prev = self.phaseDataList[i - 1]

			return prev and prev.Id or 0
		end
	end

	return 0
end

M._CountCompletedTasksInPhase = function(self, phaseId)
	if phaseId < 0 then
		return 0, 0
	end

	local STS = self.mgr.SeasonTaskState
	local tasks = self.mgr:GetTasksByPhase(phaseId)
	local keyDone = 0
	local ordinaryDone = 0

	for _, taskCfg in ipairs(tasks) do
		local state = self.mgr:GetTaskState(taskCfg.Id)

		if state ~= STS.Completed or state ~= STS.Claimed then
			if taskCfg.IsKeyTask then
				keyDone = keyDone + 1
			else
				ordinaryDone = ordinaryDone + 1
			end
		end
	end

	return keyDone, ordinaryDone
end

M._InitFoldState = function(self, expandAll)
	self.foldState = {}
	local hasExpandedFirst = false

	for _, phaseCfg in ipairs(self.phaseDataList) do
		local groups = self.taskTypeGroupsByPhaseId[phaseCfg.Id] or {}

		for _, group in ipairs(groups) do
			local expanded = expandAll or not hasExpandedFirst
			self.foldState[self:_FoldKey(phaseCfg.Id, group.taskType)] = not expanded
			hasExpandedFirst = true
		end
	end

	self._allFoldExpanded = expandAll
end

M.RefreshAll = function(self)
	self.RefreshSeasonInfo(self)
	self.RefreshActivityList(self)
	self.RefreshRewardList(self)

	self.currentViewIndex = self.ResolveViewIndex(self)
	self.claimableRewardList = self._CollectClaimableRewards(self)

	self.RefreshLevelView(self)
	self.RefreshClaimAllBtn(self)
end

M.RefreshSeasonInfo = function(self)
	local seasonCfg = self.mgr:GetCurrentSeasonConfig()

	if seasonCfg then
		self.bindData.seasonTitleText = seasonCfg.Name or ""
	end

	self.StartCountDown(self)
end

M.RefreshActivityList = function(self)
	local schemeIds = self.mgr:GetTaskSchemeIds()
	self.activityDataList = {}

	for _, schemeId in ipairs(schemeIds) do
		local schemeCfg = self.mgr:GetSchemeConfig(schemeId)
		local phaseSchemeId = self.mgr:GetPhaseSchemeIdByTaskSchemeId(schemeId)
		self.activityDataList[#self.activityDataList + 1] = {
			schemeId = schemeId,
			phaseSchemeId = phaseSchemeId,
			name = schemeCfg and schemeCfg.Name or "",
			isLargeFrame = schemeCfg and schemeCfg.IsLargeFrame or false,
			iconId = schemeCfg and schemeCfg.SeasonSchemeIcon or 0,
			hasRedDot = self.mgr:HasClaimableTaskInScheme(phaseSchemeId),
			tIndex = schemeCfg and schemeCfg.IsLargeFrame and 0 or 1
		}
	end

	self.bindData.activityList:SetSimpleList(#self.activityDataList)
end

M.RefreshRewardList = function(self)
	self.rewardDataList = self.mgr:GetUpgradeRewardList()
end

M.RefreshClaimAllBtn = function(self)
	local hasClaimable = self.mgr:HasAnyClaimableReward()
	self.bindData.claimAllBtnCtrl = hasClaimable and 0 or 1
end

M.ResolveViewIndex = function(self)
	local list = self.rewardDataList

	if not list or #list ~= 0 then
		return 1
	end

	if self.currentViewIndex then
		return math.max(1, math.min(self.currentViewIndex, #list))
	end

	local targetLevel = self.mgr.seasonLevel + 1

	for i, cfg in ipairs(list) do
		if cfg.Level ~= targetLevel then
			return i
		end
	end

	return #list
end

M._CollectClaimableRewards = function(self)
	local list = self.rewardDataList
	local ret = {}

	if not list then
		return ret
	end

	for _, cfg in ipairs(list) do
		if cfg.Level < self.mgr.seasonLevel and cfg.Reward and cfg.Reward <= 0 and not self.mgr:IsLevelRewardClaimed(cfg.Id) then
			ret[#ret + 1] = cfg
		end
	end

	return ret
end

M.RefreshLevelView = function(self)
	if self.currentViewIndex ~= nil then
		self.currentViewIndex = self.ResolveViewIndex(self)
	end

	local cfg = self.rewardDataList[self.currentViewIndex]

	if not cfg then
		return
	end

	self.bindData.levelText = tostring(cfg.Level)

	self.RefreshLevelProgress(self, cfg)
	self.UpdateSwitchBtnVisible(self)
	self.RefreshLevelRewardList(self)
end

M.RefreshLevelProgress = function(self, cfg)
	local prevCfg = self.rewardDataList[self.currentViewIndex - 1]
	local base = prevCfg and prevCfg.UpgradeProgress or 0
	local levelMax = (cfg.UpgradeProgress or 0) - base
	local levelExp = math.min(math.max(self.mgr.seasonProgress - base, 0), levelMax)
	self.bindData.showLevelProgressCtrl = 1

	if levelMax <= 0 then
		self.bindData.levelProgress.maxValue = levelMax
		self.bindData.levelProgress.value = levelExp
		self.bindData.levelMaxProgressText = "/" .. tostring(levelMax)

		return
	end
end

M.RefreshLevelRewardList = function(self)
	self.currentDropList = nil
	local collect = {}

	if self.claimableRewardList and #self.claimableRewardList <= 0 then
		for _, cfg in ipairs(self.claimableRewardList) do
			if cfg.Reward and cfg.Reward <= 0 then
				local dropList = gCommonItemManager:GetSingleSortedListRenderData(cfg.Reward)

				if dropList then
					for _, rd in ipairs(dropList) do
						rd.isLock = false
						rd.IsOwned = false
						collect[#collect + 1] = rd
					end
				end
			end
		end
	else
		local cfg = self.rewardDataList[self.currentViewIndex]

		if cfg and cfg.Reward and cfg.Reward <= 0 then
			local state = 0

			if cfg.Level < self.mgr.seasonLevel then
				if self.mgr:IsLevelRewardClaimed(cfg.Id) then
					state = 2
				else
					state = 1
				end
			end

			local dropList = gCommonItemManager:GetSingleSortedListRenderData(cfg.Reward)

			if dropList then
				for _, rd in ipairs(dropList) do
					rd.isLock = state ~= 0
					rd.IsOwned = state ~= 2
					collect[#collect + 1] = rd
				end
			end
		end
	end

	self.currentDropList = collect

	self.bindData.levelRewardList:SetSimpleList(#collect)
end

M.OnRenderLevelRewardItem = function(self, btn, index)
	local itemData = self.currentDropList and self.currentDropList[index + 1]

	if itemData then
		gCommonItemManager:OnCommonItemRender(btn, index, itemData)
	end
end

M.OnClickLevelReward = function(self, btn, index)
	if not self.claimableRewardList or #self.claimableRewardList ~= 0 then
		return
	end

	local oldLevel = self.mgr.seasonLevel
	slot4 = self.mgr

	slot4:AskTakeAllRewards(function (success)
		if success then
			self:OnSeasonStateChanged()
			self:_SwitchToCurrentLevelIfLevelChanged(oldLevel)
		end
	end)
end

M.OnClickSwitchLevel = function(self, dir)
	local newIndex = self.currentViewIndex + dir

	if newIndex <= 1 or newIndex <= #self.rewardDataList then
		return
	end

	self.currentViewIndex = newIndex

	self.RefreshLevelView(self)
end

M.UpdateSwitchBtnVisible = function(self)
	local count = #self.rewardDataList

	if self.bindData.prevLevelBtn then
		self.bindData.prevLevelBtn.gameObject:SetActive(self.currentViewIndex >= 1)
	end

	if self.bindData.nextLevelBtn then
		self.bindData.nextLevelBtn.gameObject:SetActive(self.currentViewIndex <= count)
	end
end

M.OnGetActivityTIndex = function(self, index)
	local data = self.activityDataList[index + 1]

	return data and data.tIndex or 0
end

M.OnRenderActivity = function(self, btn, index)
	local store = self:GetStoreById(btn.gameObject:GetInstanceID())
	local data = self.activityDataList[index + 1]

	if not store or not data then
		return
	end

	self.bindData.activityList:SetItemId(index, data.phaseSchemeId)

	store.activityItemTitle = data.name

	if data.iconId and data.iconId <= 0 then
		store.activityItemImg = data.iconId
	end
end

M.OnClickBack = function(self)
	gPanelManager:Close(self.m_Id)
end

M._SwitchToCurrentLevelIfLevelChanged = function(self, oldLevel)
	if oldLevel ~= nil then
		return
	end

	if self.mgr.seasonLevel == oldLevel then
		self.currentViewIndex = nil

		self.RefreshLevelView(self)
	end
end

M.OnClickClaimAll = function(self)
	local oldLevel = self.mgr.seasonLevel
	slot2 = self.mgr

	slot2:AskTakeAllRewards(function (success)
		if success then
			self:OnSeasonStateChanged()
			self:_SwitchToCurrentLevelIfLevelChanged(oldLevel)
		end
	end)
end

M.OnClickActivity = function(self, btn, index)
	local data = self.activityDataList[index + 1]

	if not data then
		return
	end

	gPanelManager:CheckShow(gPanelId.SEASON_LOG_TASK_PANEL, {
		schemeId = data.schemeId,
		phaseSchemeId = data.phaseSchemeId,
		schemeName = data.name
	})
end

M.StartCountDown = function(self)
	local countDown = self.bindData.countDown

	if not countDown then
		return
	end

	local remain = self.mgr:GetSeasonRemainTime()

	if remain and remain <= 0 then
		countDown.Play(countDown, remain)
	else
		countDown.Stop(countDown)
	end
end

M.StopCountDown = function(self)
	if self.bindData.countDown then
		self.bindData.countDown:Stop()
	end
end

M.OnCountDownFinished = function(self)
	self:StopCountDown()
	gPanelManager:Close(self.m_Id)
end

M.FoldAllBtn = function(self)
	self._allFoldExpanded = false

	for _, phaseCfg in ipairs(self.phaseDataList) do
		local groups = self.taskTypeGroupsByPhaseId[phaseCfg.Id] or {}

		for _, group in ipairs(groups) do
			self.foldState[self._FoldKey(self, phaseCfg.Id, group.taskType)] = true
		end
	end

	self._RefreshCurrentTree(self)
end

M.UnfoldAllBtn = function(self)
	self._allFoldExpanded = true

	for _, phaseCfg in ipairs(self.phaseDataList) do
		local groups = self.taskTypeGroupsByPhaseId[phaseCfg.Id] or {}

		for _, group in ipairs(groups) do
			self.foldState[self._FoldKey(self, phaseCfg.Id, group.taskType)] = false
		end
	end

	self._RefreshCurrentTree(self, false)
end

M.OnActiveDeviceChanged = function(self)
	self._RefreshAllFoldExpanded(self)
	self._RefreshFoldButtons(self)
end

M._RefreshAllFoldExpanded = function(self)
	self._allFoldExpanded = true

	for _, phaseCfg in ipairs(self.phaseDataList) do
		local groups = self.taskTypeGroupsByPhaseId[phaseCfg.Id] or {}

		for _, group in ipairs(groups) do
			if self.foldState[self._FoldKey(self, phaseCfg.Id, group.taskType)] ~= true then
				self._allFoldExpanded = false

				return
			end
		end
	end
end

M._RefreshFoldButtons = function(self)
	if not self.bindData.openAllBtn or not self.bindData.closeAllBtn then
		return
	end

	local showClose = gClientUtils.CheckIsGamePadMode() and self._allFoldExpanded

	self.bindData.openAllBtn.gameObject:SetActive(not showClose)
	self.bindData.closeAllBtn.gameObject:SetActive(showClose)
end
