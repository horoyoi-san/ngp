-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SeasonLogTaskPanelStore.lua
-- Decompiled from: 00879_SeasonLogTaskPanelStore.lua_81ca7a7defb3.luajit

local ScriptText = LTConfig.TextScriptTextConfig
C_SeasonLogTaskPanelStore = DefClass("C_SeasonLogTaskPanelStore", C_SeasonLogTaskPanelStore, C_StoreGroup)
GroupName2Class.SeasonLogTaskPanelStore = C_SeasonLogTaskPanelStore
local M = C_SeasonLogTaskPanelStore
local BOOL2CTL = gClientConst.BOOL2CTL
local TREE_TEMPLATE = {
	["\\-q_"] = 1,
	["N#nP"] = 2,
	I6xK = 0
}
local TREE_NODE_TYPE = {
	["N#nP"] = "n#nP",
	["}\\xa6\\xa3\\xbc\\xb3"] = "]\\xa6\\xa3\\xbc\\xb3",
	["V-~P"] = "v-~P",
	["\\-q_"] = "|-q_"
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.schemeIds = {}
	self.currentSchemeIdx = 1
	self.currentSchemeId = 0
	self.currentSchemeName = ""
	self.phaseDataList = {}
	self.taskTypeGroupsByPhaseId = {}
	self.foldState = {}
	self.treeDataList = {}
	self.visibleTaskNodeIndexById = {}
	self.taskNodeMetaById = {}
	self.selectedTaskId = 0
	self.selectedTaskCfg = nil
	self.rewardDropList = {}
	self.tabStore = nil
	self.taskInfoStore = nil
	self.taskInfoContentStore = nil
	self._subWidgetsRegistered = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)

	self.mgr = gOnlineSeasonProgressMgr

	self.RegisterWidget(self)

	self.msgEvents = {
		[gEventConstants.ONLINE_SEASON_PROGRESS_STATE_CHANGED] = self.CreateAction(self, "OnStateChanged")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBack")

	if self.bindData.btnControllerClose then
		self.bindData.btnControllerClose.luaClick = self.CreateAction(self, "OnClickCollapseAll")
	end
end

M.RegisterSubStoreWidgets = function(self)
	if self._subWidgetsRegistered then
		return
	end

	if not self.bindData.taskInfoRoot then
		return
	end

	local infoStore = self.GetStoreByWidget(self, self.bindData.taskInfoRoot)

	if not infoStore then
		return
	end

	self._subWidgetsRegistered = true
	self.taskInfoStore = infoStore
	local taskInfoContent = infoStore.taskInfoRect.content
	self.taskInfoContentStore = gStoreManager:GetStoreGroup(taskInfoContent.Store):GetStoreByWidget(taskInfoContent)

	if infoStore.rewardList then
		infoStore.rewardList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderRewardItem")
		infoStore.rewardList.luaSimpleClick = self.CreateAction(self, "OnClickRewardItem")
	end

	if infoStore.claimBtn then
		infoStore.claimBtn.luaClick = self.CreateAction(self, "OnClickClaimTaskReward")
	end
end

M.OnShow = function(self, panelId, data)
	if not self.mgr:HasActiveSeason() then
		gPanelManager:Close(self.m_Id)

		return
	end

	self:RegisterSubStoreWidgets()
	self:ShowTaskInfo(false)

	self.schemeIds = self.mgr:GetTaskSchemeIds()
	local defaultIdx = 1

	if data and data.schemeId then
		for i, id in ipairs(self.schemeIds) do
			if id ~= data.schemeId then
				defaultIdx = i

				break
			end
		end
	end

	self.currentSchemeIdx = defaultIdx

	self:InitTabs()
	self.mgr:RefreshRedDot()
end

M.OnClose = function(self)
	self.ClearMessageEvents(self)
	self.DefineAllVariables(self)
end

M.InitTabs = function(self)
	self.tabStore = self.SubGroup and self.SubGroup.CommonTabSingleStore

	if not self.tabStore then
		print_error("[SeasonLogTask] CommonTabSingleStore not found")

		return
	end

	local tabList = {}

	for i, schemeId in ipairs(self.schemeIds) do
		local schemeCfg = self.mgr:GetSchemeConfig(schemeId)
		tabList[i] = {
			id = schemeId,
			title = schemeCfg and schemeCfg.Name or ""
		}
	end

	self:_BuildSchemeData(self.schemeIds[self.currentSchemeIdx])
	self:_InitFoldState(1)
	self:_BuildTreeData()

	local selectedTreeIndex = self:_FindPreferredVisibleTaskNodeIndex()

	self.tabStore:SetData(tabList, self.treeDataList, self.currentSchemeIdx - 1, selectedTreeIndex or -1, self:CreateAction(self.OnTabChanged), self:CreateAction(self.OnRenderTabItem), nil, true)

	if selectedTreeIndex ~= nil then
		self.ClearTaskSelection(self)
	end
end

M._RefreshCurrentTree = function(self, preferCurrentSelectedTask)
	if not self.tabStore then
		return
	end

	self:_BuildTreeData()
	self.tabStore:SetTabList(self.treeDataList, true)
	self:_SelectTreeTask(preferCurrentSelectedTask)
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
	else
		self.tabStore:SetSelectedIndex(-1, false, true)
		self:ClearTaskSelection()
	end
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

		local node = self.tabStore:GetSubSelectedItem()

		if not node then
			self.ClearTaskSelection(self)

			return
		end

		if node.nodeType ~= TREE_NODE_TYPE.Task and node.taskCfg then
			self.SelectTask(self, node.taskCfg)
		else
			self.ClearTaskSelection(self)
		end

		return
	end

	local newIdx = self.tabStore:GetSelectedIndex() + 1

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
	btn.redKey = ("SeasonLog.TaskType:%d"):format(node.id)
end

M._RenderTaskNode = function(self, btn, store, node)
	local title = node.title or ""
	local isLockedNode = node.nodeType ~= TREE_NODE_TYPE.Lock
	store.title = title
	store.lockCtrl = BOOL2CTL[isLockedNode]
	store.keyTaskCntText = node.keyTaskCntText or ""
	store.ordinaryTaskCntText = node.ordinaryTaskCntText or ""

	if isLockedNode or not node.taskCfg then
		btn.redKey = ""

		return
	end

	store.typeCtrl = node.taskCfg.IsKeyTask and 0 or 1
	local state = node.taskState or self.mgr:GetTaskState(node.taskCfg.Id)
	local STS = self.mgr.SeasonTaskState
	local isFinished = state ~= STS.Completed or state ~= STS.Claimed
	store.finishCtrl = BOOL2CTL[isFinished]
	btn.redKey = ("SeasonLog.Task:%d"):format(node.taskCfg.Id)
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
	self._InitFoldState(self, 1)
	self._RefreshCurrentTree(self, false)
end

M.OnStateChanged = function(self)
	if self.currentSchemeId == 0 then
		self.RefreshCurrentScheme(self)
	end
end

M.RefreshCurrentScheme = function(self)
	self._BuildSchemeData(self, self.currentSchemeId)
	self._RefreshCurrentTree(self, true)

	if self.selectedTaskCfg then
		self.RefreshTaskDetail(self)
	end
end

M.SelectTask = function(self, taskCfg)
	if not taskCfg then
		return
	end

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
	if self.bindData.taskInfoRoot == nil then
		self.bindData.taskInfoRoot:SetActiveFastest(visible)
	end
end

M.RefreshTaskDetail = function(self)
	local cfg = self.selectedTaskCfg

	if not cfg then
		return
	end

	local infoStore = self.taskInfoStore

	if not infoStore or not self.taskInfoContentStore then
		return
	end

	local state = self.mgr:GetTaskState(cfg.Id)
	local STS = self.mgr.SeasonTaskState
	infoStore.taskNameText = cfg.Title or ""
	infoStore.taskTypeText = self.currentSchemeName
	self.taskInfoContentStore.taskDesText = self.mgr:FormatTaskText(cfg.Description, cfg.MaxProgress)

	if state ~= STS.Locked then
		infoStore.claimBtnCtrl = 0
		infoStore.taskBtnFinishCtrl = 1
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

	self.rewardDropList = {}

	if cfg.Reward and cfg.Reward <= 0 then
		self.rewardDropList = gCommonItemManager:GetSingleSortedListRenderData(cfg.Reward) or {}
	end

	if infoStore.rewardList then
		infoStore.rewardList:SetSimpleList(#self.rewardDropList)
	end
end

M.OnRenderRewardItem = function(self, btn, index)
	local data = self.rewardDropList[index + 1]

	if data then
		gCommonItemManager:OnCommonItemRender(btn, index, data)
	end
end

M.OnClickRewardItem = function(self, btn, index)
end

M.OnClickBack = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickCollapseAll = function(self)
	for key in pairs(self.foldState) do
		self.foldState[key] = true
	end

	self._RefreshCurrentTree(self, false)
end

M.OnClickClaimTaskReward = function(self)
	if self.selectedTaskId < 0 then
		return
	end

	local STS = self.mgr.SeasonTaskState

	if self.mgr:GetTaskState(self.selectedTaskId) == STS.Completed then
		return
	end

	slot2 = self.mgr

	slot2:AskTakeTaskReward(self.selectedTaskId, function ()
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
				local STS = self.mgr.SeasonTaskState
				local aFinished = (a.state ~= STS.Completed or a.state ~= STS.Claimed) and 1 or 0
				local bFinished = (b.state ~= STS.Completed or b.state ~= STS.Claimed) and 1 or 0

				if aFinished == bFinished then
					return aFinished <= bFinished
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
		self:_AppendTreeNode({
			["FTȲ\\x88\\xb9\\xc5\\xed"] = true,
			["I\\xab\\xb2\\xbb\\xbe"] = 0,
			["\\xae\\xa9\\xaad:\\xfb7"] = true,
			nodeType = TREE_NODE_TYPE.Phase,
			id = phaseCfg.Id,
			title = phaseCfg.Description or string.format(ScriptText.GetConfig(89901474).Text, phaseCfg.PhaseId or 0),
			tIndex = TREE_TEMPLATE.Step
		})

		if self:IsPhaseUnlocked(phaseCfg) then
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

				for _, taskData in ipairs(group.tasks) do
					local treeIndex = self:_AppendTreeNode({
						["I\\xab\\xb2\\xbb\\xbe"] = 2,
						nodeType = TREE_NODE_TYPE.Task,
						id = taskData.cfg.Id,
						phaseId = phaseCfg.Id,
						foldKey = foldKey,
						taskTypeUniqueId = taskTypeUniqueId,
						taskCfg = taskData.cfg,
						taskState = taskData.state,
						title = self.mgr:FormatTaskText(taskData.cfg.Title, taskData.cfg.MaxProgress),
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
		else
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
				tIndex = TREE_TEMPLATE.Task
			})
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

M._InitFoldState = function(self, expandPhaseIdx)
	self.foldState = {}

	for i, phaseCfg in ipairs(self.phaseDataList) do
		local groups = self.taskTypeGroupsByPhaseId[phaseCfg.Id] or {}

		for _, group in ipairs(groups) do
			self.foldState[self:_FoldKey(phaseCfg.Id, group.taskType)] = i == expandPhaseIdx
		end
	end
end
