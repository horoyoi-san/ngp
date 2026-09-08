-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TaskListPanelStore.lua
-- Decompiled from: 01413_TaskListPanelStore.lua_a83fca8edc0d.luajit

local TaskTitleConfig = LTConfig.TaskTitleConfig
local TaskConfig = LTConfig.TaskConfig
local TaskChoiceConfig = LTConfig.TaskChoiceConfig
local TaskEventConfig = LTConfig.TaskEventConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local MessageConfig = LTConfig.MessageConfig
local TaskChapterConfig = LTConfig.TaskChapterConfig
local TaskRoleConfig = LTConfig.TaskRoleConfig
local SpiritCaseConfig = LTConfig.SpiritCaseConfig
local NowTaskType = -1
C_TaskListPanelStore = DefClass("C_TaskListPanelStore", C_TaskListPanelStore, C_StoreGroup)
GroupName2Class.TaskListPanelStore = C_TaskListPanelStore
local M = C_TaskListPanelStore

M.ctor = function(self)
	self.DefineDataVariables(self)
	self.HandleTaskChoiceData(self)
end

M.DefineDataVariables = function(self)
	self.taskChoiceList = {}
end

M.DefineAllVariables = function(self)
	self.jumpEventId = 0
	self.curTasks = {}
	self.taskView = {}
	self.tab1Data = {}
	self.selectedTab1Index = 0
	self.selectedTab2Index = -1
	self.initTab2Index = -1
	self.selectedTaskView = nil
	self.rewardItems = {}
	self.rewardItemsBtnView = {}
	self.branchList = {}
	self.redDotAction = nil
	self.tab1Type2Index = {}
	self.waitAcceptTaskId = 0
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnGroupEnable = function(self)
	self.bindData.ShowMainPageCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.S_TASK_LIST) and 1 or 0
end

M.OnDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.ani:Play("S_Vx_TaskListPanel_pc_open")
	else
		self.bindData.ani:Play("S_Vx_TaskListPanel_open")
	end

	self.RefreshEmptyLabel(self)
	self.InitTaskListData(self, data)
	self.HandleInitSelect(self)
	self.RefreshCommonTabSingle(self)
end

M.OnClose = function(self)
end

M.OnUpdate = function(self)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.resetBtn.luaClick = self.CreateAction(self, "OnClickResetBtn")
	self.bindData.chasingBtn.luaClick = self.CreateAction(self, "OnClickChasingBtn")
	self.bindData.cancelChasingBtn.luaClick = self.CreateAction(self, "OnClickCancelChasingBtn")
	self.bindData.switchCharBtn.luaClick = self.CreateAction(self, "OnClickSwitchCharBtn")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.branchList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderBranchListItem)
	self.bindData.rewardList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderRewardItem)
	self.bindData.taskSearchBtn.luaClick = self.CreateAction(self, "OnTaskSearchBtnClick")
end

M.OnRenderRewardItem = function(self, btn, index)
	local data = self.rewardItemsBtnView[index + 1]

	gCommonItemManager:OnCommonItemRender(btn, index, data)
end

M.OnDynRenderRewardItem = function(self, btn, index)
	local data = self.rewardItemsBtnView[index + 1]

	gCommonItemManager:OnDynCommonItemRender(btn, index, data)
end

M.OnClickResetBtn = function(self)
	if not self.selectedTaskView then
		return
	end

	slot1 = gTaskNodeManager

	slot1:AskResetTask(self.selectedTaskView.TaskId, function ()
		self:OnClickCloseBtn()
	end)
end

M.OnClickChasingBtn = function(self)
	if not self.selectedTaskView then
		return
	end

	gPanelManager:Close(gPanelId.S_TASK_LIST)

	if self.selectedTaskView.isUnderway then
		local SetCurrentTask = function()
			local needSwitchCha = gBattleSpiritMgr.currentSpiritTemplateId ~= self.selectedTaskView.playRole and 0 or self.selectedTaskView.playRole

			gGpsManager:TryRemoveNowMapGuide()
			gTaskManager:SetCurrentTask(self.selectedTaskView.TaskId, function ()
				local taskCfg = TaskConfig.GetConfig(self.selectedTaskView.TaskId)
				local taskEventCfg = TaskEventConfig.GetConfig(self.selectedTaskView.TaskLineId)

				if taskCfg and (taskCfg.RelatedTimeAndWeather.weatherId >= 0 or taskCfg.RelatedTimeAndWeather.timeId <= 0) then
					gDisplayMessageMgr:ShowMessage(MessageConfig.TaskChangeWeather)
				end

				gCS.LuaUtils.RemovePlayerPaoKuState()
			end, nil, needSwitchCha)
		end

		SetCurrentTask()
	else
		gTaskNodeManager:OpenMapByEventId(self.selectedTaskView.TaskLineId)
	end
end

M.OnClickCancelChasingBtn = function(self)
	slot1 = gTaskNodeManager

	slot1:AskCancelChasing(self.selectedTaskView.TaskId, function ()
		self:OnShow()
	end)
end

M.OnClickSwitchCharBtn = function(self)
	self.OnClickChasingBtn(self)
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnTaskSearchBtnClick = function(self)
	if self.waitAcceptTaskId ~= 0 then
		return
	end

	gMapUtils:CheckRaidCanOpenMap({
		AutoSelectTaskId = self.waitAcceptTaskId
	})
end

M.OnRenderBranchListItem = function(self, btn, index)
	local data = self.branchList[index + 1]
	local store = gStoreManager:GetStoreGroup("TaskListBranchTemplate"):GetStoreByWidget(btn)

	if store then
		store.finishCtrl = data.isFinish and 0 or 1
		store.workActionText = data.desc
	end
end

M.HandleTaskChoiceData = function(self)
	for i = 0, TaskChapterConfig.count - 1 do
		local choice = TaskChoiceConfig.LoadAt(i)

		if choice and choice.EventId then
			self.taskChoiceList[choice.EventId] = self.taskChoiceList[choice.EventId] or {}

			table.insert(self.taskChoiceList[choice.EventId], choice)
		end
	end
end

M.InitTaskListData = function(self, data)
	if data and data.eventId then
		self.jumpEventId = data.eventId
	end

	self.taskView = {}
	self.curTasks = gTaskNodeManager:GetAllTaskCanShow()

	self:BuildTabLv1()
	self:BuildTaskData()
end

M.BuildTabLv1 = function(self)
	local types = TaskTitleConfig.TabTypeType

	table.clear(self.tab1Data)

	local curTask = {
		name = TaskConfig.TaskListTabNameCurrent,
		tabType = NowTaskType,
		id = NowTaskType
	}

	table.insert(self.tab1Data, curTask)

	self.tab1Type2Index[NowTaskType] = 1
	local typesName = TaskConfig.TaskListTabName
	local index = 2

	for _, tab in pairs(types) do
		local tabData = {}
		local tabName, tabType = nil

		for _, pair in ipairs(typesName) do
			if pair.TabType ~= tab then
				tabName = pair.TabName
				tabType = pair.TabType

				break
			end
		end

		tabData.name = tabName
		tabData.tabType = tabType
		tabData.id = tabType

		if tab ~= TaskTitleConfig.TabTypeType.none then
			-- Nothing
		elseif tab ~= TaskTitleConfig.TabTypeType.online then
			if gLinkManager:CheckInLinkMode() then
				self.tab1Type2Index[tabType] = index

				table.insert(self.tab1Data, tabData)

				index = index + 1
			end
		else
			self.tab1Type2Index[tabType] = index

			table.insert(self.tab1Data, tabData)

			index = index + 1
		end
	end
end

M.BuildTaskData = function(self)
	local nowChaCardId = gBattleSpiritMgr.currentSpiritTemplateId
	self.taskView[NowTaskType] = {}

	for i, taskInfo in pairs(self.curTasks) do
		local taskEventConfig = TaskEventConfig.GetConfig(taskInfo.TaskLineId)
		local taskCfg = TaskConfig.GetConfig(taskInfo.TaskId)
		local chapterName = nil

		if taskEventConfig.Chapter <= 0 then
			chapterName = TaskChapterConfig.GetConfig(taskEventConfig.Chapter).ChapterName
		end

		local playRole = nil
		local isProtagonist = false
		local playRoleTeam = taskEventConfig.PlayRoleTeam
		local role = nil

		if playRoleTeam and #playRoleTeam <= 0 then
			role = playRoleTeam[1]
		end

		if taskCfg and taskCfg.RoleId <= 0 then
			role = taskCfg.RoleId
		end

		if role then
			local roleCfg = TaskRoleConfig.GetConfig(role)
			local fid = nil

			if roleCfg.IsDefault then
				local sex = gPlayerManager.infoLogin.bindData.sexType

				if sex ~= UX.Game.SexType.Male then
					fid = FightSpiritConfig.DefaultMale
				elseif sex ~= UX.Game.SexType.Female then
					fid = FightSpiritConfig.DefaultFemale
				end

				playRole = fid
				isProtagonist = true
			else
				if roleCfg.FightSpiritId <= 0 then
					fid = roleCfg.FightSpiritId
				else
					local caseId = roleCfg.SpiritCaseId
					fid = SpiritCaseConfig.GetConfig(caseId).FightSpiritId
				end

				playRole = fid
			end
		end

		local tabType = TaskTitleConfig.GetConfig(taskInfo.TaskTitle).TabType
		local isCurrent = not playRole or playRole ~= nowChaCardId
		local needChangeChar = not isCurrent
		local view = {
			["\\xa2\\xa27\\xaez2\\xff*"] = false,
			["P[\\xc0\\x8f\\x81\\xac\\xdb\\xfc"] = true,
			id = taskInfo.TaskId,
			TaskId = taskInfo.TaskId,
			TaskLineId = taskInfo.TaskLineId,
			EventName = taskInfo.EventName,
			TaskType = taskInfo.TaskType,
			TaskTitle = taskInfo.TaskTitle,
			name = taskInfo.name,
			isLock = taskInfo.isLock,
			isAccept = taskInfo.isAccept,
			hasAccept = taskInfo.hasAccept,
			isRiskControl = taskInfo.isRiskControl,
			distance = taskInfo.distance,
			ChapterName = chapterName,
			playRole = playRole,
			isProtagonist = isProtagonist,
			realTabType = tabType,
			isCurrent = isCurrent,
			needChangeChar = needChangeChar,
			isUnderway = taskInfo.isUnderway
		}
		self.taskView[tabType] = self.taskView[tabType] or {}

		if view.isCurrent and taskInfo.isUnderway then
			table.insert(self.taskView[NowTaskType], table.clone(view))
		end

		table.insert(self.taskView[tabType], view)
	end

	local replayTasks = gTaskManager:GetAllReplayTaskEvents()

	for _, event in ipairs(replayTasks) do
		local view = event
		view.isReplay = true
		local taskEventCfg = TaskEventConfig.GetConfig(event.EventId)
		local startTask = taskEventCfg.StartTask
		local startTaskCfg = TaskConfig.GetConfig(startTask)
		local title = startTaskCfg.Title
		local tabType = TaskTitleConfig.GetConfig(title).TabType
		self.taskView[tabType] = self.taskView[tabType] or {}

		table.insert(self.taskView[NowTaskType], view)
	end
end

M.BuildRewardList = function(self, taskInfo)
	local dropList = {}
	local taskLineInfo = gTaskNodeManager:GetTaskLineByTask(taskInfo.TaskId)

	if taskLineInfo then
		for i = 1, #taskLineInfo.TaskList do
			local taskId = taskLineInfo.TaskList[i]
			local cfg = TaskConfig.GetConfig(taskId)

			if cfg and cfg.Drop <= 0 then
				table.insert(dropList, cfg.Drop)
			end
		end
	end

	self.rewardItems = {}
	self.rewardItemsBtnView = {}

	if not table.isNilOrEmpty(dropList) then
		for t = 1, #dropList do
			local items = gCommonItemManager:GetItemSortedListByDropList(dropList[t], true)

			for i = 1, #items do
				local view = {}
				local itemId = items[i].Id
				view.itemId = itemId
				view.itemNum = items[i].Count
				local hasSameItem = false

				for k = 1, #self.rewardItems do
					if self.rewardItems[k].itemId ~= itemId then
						if type(self.rewardItems[k].itemNum) ~= "number" and type(items[i].Count) ~= "number" then
							self.rewardItems[k].itemNum = self.rewardItems[k].itemNum + items[i].Count
						end

						hasSameItem = true
					end
				end

				if not hasSameItem then
					table.insert(self.rewardItems, view)
				end
			end
		end
	end

	for _, view in ipairs(self.rewardItems) do
		local itemData = gCommonItemManager:GetItemRenderData({
			itemId = view.itemId,
			itemNum = view.itemNum
		})

		table.insert(self.rewardItemsBtnView, itemData)
	end

	self.bindData.rewardList:SetSimpleList(#self.rewardItemsBtnView)
end

M.RefreshTaskPage = function(self)
	local data = self.selectedTaskView

	if not data then
		self.RefreshEmptyLabel(self)

		return
	end

	self.bindData.emptyCtrl = 1

	gTaskManager:AskCancelRedPoint(data.TaskLineId)

	if data.isReplay then
		self.bindData.infoTypeCtrl = 2

		self.RefreshReplayTaskPage(self)

		return
	end

	local curTask = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1]

	if data.needChangeChar and curTask == data.id then
		self.bindData.infoTypeCtrl = 1
	else
		self.bindData.infoTypeCtrl = 0
	end

	self.RefreshCommonTaskPage(self)
end

M.RefreshEmptyLabel = function(self)
	local tabData = self.tab1Data[self.selectedTab1Index + 1]
	self.bindData.emptyCtrl = 0
	local tabType = table.isNilOrEmpty(tabData) and NowTaskType or tabData.tabType
	self.bindData.emptyMode, self.bindData.emptyLabel, self.waitAcceptTaskId = gTaskNodeManager:GetTaskEmptyType(tabType)

	print_debug("[C_TaskListPanelStore] RefreshEmptyLabel emptyMode = ", self.bindData.emptyMode, "taskId = ", self.waitAcceptTaskId)
end

M.RefreshCommonTaskPage = function(self)
	local data = self.selectedTaskView
	self.bindData.taskIconId = TaskTitleConfig.GetConfig(data.TaskTitle).SQuestIcon
	local taskCounter = gTaskNodeManager:FindFirstCounterIndex(data.TaskId)
	local curTaskInfo = gTaskNodeManager:GetTaskWorkActionInfo(data.TaskId, taskCounter)
	local taskEventCfg = TaskEventConfig.GetConfig(data.TaskLineId)

	if curTaskInfo ~= nil then
		print_error("没有找到任务信息 taskId = " .. data.TaskId)

		return
	end

	local des = gUtils:GetSpecialDescription(gTaskUtils:FormatTaskDes(curTaskInfo.EventObjective, data.TaskId), true) or ""
	self.bindData.workActionText = des
	self.bindData.locationText = data.distance
	local store = gStoreManager:GetStoreGroup("TaskListTaskDesTemplate"):GetStoreByWidget(self.bindData.scroll.content)
	local eventDes = taskEventCfg.EventDescription or ""
	local unlockDes = taskEventCfg.UnlockDescription or ""
	store.taskDesText = data.isLock and unlockDes or eventDes

	if data.needChangeChar then
		local config = FightSpiritConfig.GetConfig(data.playRole)
		self.bindData.avatarIconId = config.SHeadIconID

		if data.isProtagonist then
			self.bindData.avatarNameText = gPlayerManager.infoLogin.bindData.name
		else
			self.bindData.avatarNameText = config.Name
		end
	end

	self.BuildRewardList(self, curTaskInfo)
	self.RefreshBottomControl(self)
end

M.RefreshBottomControl = function(self)
	local data = self.selectedTaskView
	local curTask = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1]

	if curTask and data.TaskId ~= curTask then
		if data.canRestart then
			self.bindData.isResetCtrl = 0
		else
			self.bindData.isResetCtrl = 1
		end

		self.bindData.chasingCtrl = 0
	else
		self.bindData.chasingCtrl = 1
		self.bindData.isResetCtrl = 1
	end
end

M.RefreshReplayTaskPage = function(self)
	local data = self.selectedTaskView
	local branchFinishList = {}
	local taskEventCfg = TaskEventConfig.GetConfig(data.TaskLineId)
	local store = gStoreManager:GetStoreGroup("TaskListTaskDesTemplate"):GetStoreByWidget(self.bindData.scroll.content)
	store.taskDesText = taskEventCfg.EventDescription or ""
	self.branchList = {}
	local targetTable = self.taskChoiceList[data.EventId]

	if targetTable and next(targetTable) then
		for _, action in ipairs(targetTable) do
			local branch = {
				desc = action.Description or "",
				isFinish = branchFinishList[action.Id]
			}

			table.insert(self.branchList, branch)
		end
	end

	self.bindData.branchList:SetSimpleList(#self.branchList)
end

M.GetCurrentSubList = function(self)
	if self.selectedTab1Index ~= 0 then
		return self.taskView[NowTaskType] or {}
	else
		local tabData = self.tab1Data[self.selectedTab1Index + 1]
		local tabType = tabData and tabData.tabType or NowTaskType

		return self.taskView[tabType] or {}
	end
end

M.RefreshCommonTabSingle = function(self)
	local tabCount = #self.tab1Data
	local subList = self:GetCurrentSubList()
	local subCount = #subList

	self.SubGroup.CommonTabSingleStore:SetSimpleData(tabCount, subCount, self.selectedTab1Index, 0, self:CreateAction(self.OnChangeTab), self:CreateAction(self.OnRenderTabItem))
end

M.OnChangeTab = function(self, uList, isSub)
	if isSub then
		self.selectedTab2Index = uList.selectedIndex
		local subList = self.GetCurrentSubList(self)
		self.selectedTaskView = subList[self.selectedTab2Index + 1]

		self.RefreshTaskPage(self)
	else
		self.selectedTab1Index = uList.selectedIndex
		local subList = self.GetCurrentSubList(self)
		local subCount = #subList

		if self.SubGroup and self.SubGroup.CommonTabSingleStore then
			self.SubGroup.CommonTabSingleStore:SetSimpleTabList(subCount, true)
		end

		local isEmpty = subCount ~= 0
		self.bindData.emptyCtrl = isEmpty and 0 or 1

		if not isEmpty then
			self.selectedTab2Index = self.initTab2Index and self.initTab2Index or 0
			self.initTab2Index = nil

			self.SubGroup.CommonTabSingleStore:SetSelectedIndex(self.selectedTab2Index, true, true)

			self.selectedTaskView = subList[self.selectedTab2Index + 1]

			self:RefreshTaskPage()
		else
			self.selectedTaskView = nil

			self.RefreshTaskPage(self)
		end
	end
end

local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.OnRenderTabItem = function(self, btn, index, data, store, isSub, uList)
	if isSub then
		local subList = self.GetCurrentSubList(self)
		local item = subList[index + 1]

		if not item then
			return
		end

		btn.redKey = "TaskList:" .. item.id
		btn.templateKey = "Base"
		store.isLock = BOOL2CTL[false]
		store.titleText = item.EventName
		store.locationText = item.distance

		if item.ChapterName then
			store.chapterCtrl = 1
			store.chapterText = item.ChapterName
		else
			store.chapterCtrl = 0
		end

		if item.isReplay then
			store.tagCtrl = 1

			return
		end

		if item.needChangeChar then
			store.tagCtrl = 0

			return
		end

		store.tagCtrl = 2
	else
		local info = self.tab1Data[index + 1]

		if not info then
			return
		end

		store.title = info.name

		if store.icon == nil then
			store.icon = info.iconId or 0
		end

		btn.redKey = "TaskList.Tab:" .. info.id
		btn.templateKey = "Base"
	end
end

M.HandleInitSelect = function(self)
	local setIndices = function(tabType, subIndex)
		local tIndex = self.tab1Type2Index[tabType] or 1
		self.selectedTab1Index = tIndex - 1
		self.initTab2Index = subIndex or 0
	end

	if self.jumpEventId == 0 then
		slot2 = ipairs
		slot4 = self.taskView[NowTaskType] or {}

		for idx, info in slot2(slot4) do
			if info.TaskLineId ~= self.jumpEventId then
				setIndices(NowTaskType, idx - 1)

				return
			end
		end

		for tabType, tasks in pairs(self.taskView) do
			if tabType == NowTaskType then
				for idx, info in ipairs(tasks) do
					if info.TaskLineId ~= self.jumpEventId then
						setIndices(tabType, idx - 1)

						return
					end
				end
			end
		end
	end

	local curTask = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1]

	if curTask then
		slot3 = ipairs
		slot5 = self.taskView[NowTaskType] or {}

		for idx, info in slot3(slot5) do
			if info.TaskId ~= curTask then
				setIndices(NowTaskType, idx - 1)

				return
			end
		end

		for tabType, tasks in pairs(self.taskView) do
			if tabType == NowTaskType then
				for idx, info in ipairs(tasks) do
					if info.TaskId ~= curTask then
						setIndices(tabType, idx - 1)

						return
					end
				end
			end
		end
	end

	if self.taskView[NowTaskType] and #self.taskView[NowTaskType] <= 0 then
		setIndices(NowTaskType, 0)

		return
	end

	for tabType, tasks in pairs(self.taskView) do
		if tabType == NowTaskType and #tasks <= 0 then
			setIndices(tabType, 0)

			return
		end
	end

	setIndices(NowTaskType, -1)
end
