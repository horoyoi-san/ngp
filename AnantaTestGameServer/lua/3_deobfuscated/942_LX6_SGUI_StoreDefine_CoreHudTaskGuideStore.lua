local TaskTitle = require("LX6/Manager/Task/TaskTitle")
C_CoreHudTaskGuideStore = DefClass("C_CoreHudTaskGuideStore", C_CoreHudTaskGuideStore, C_StoreGroup)
GroupName2Class.CoreHudTaskGuideStore = C_CoreHudTaskGuideStore
local M = C_CoreHudTaskGuideStore
local GameConfig = LTConfig.GameConfig
local UnitStateConfig = LTConfig.UnitStateConfig
local MessageConfig = LTConfig.MessageConfig
local TaskState = UX.Game.TaskState
local TaskConfig = LTConfig.TaskConfig
local RaidConfig = LTConfig.RaidConfig
local RaidTagConfig = LTConfig.RaidTagConfig
local TaskEventConfig = LTConfig.TaskEventConfig
local RaidRaidTypeConfig = LTConfig.RaidRaidTypeConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local JobClassConfig = LTConfig.UrbanJobJobClassConfig
local AnimType = {
	Open = 4,
	Enter = 2,
	RefreshDes = 3,
	Exit = 1
}

function M:ctor()
	self.TemporaryTaskShowTime = GameConfig.HideTemporaryTaskTime
	self.curTaskId = 0
	self.currentTaskType = 0
	self.curTaskIsFirst = false
	self.curTaskInfo = nil
	self.preTaskInfo = nil
	self.curType = -1
	self.curTypeStore = nil
	self.shortCutRecordById = {}
	self.curCfgId = 0
	self.isShowShortCut = false
	self.isTaskBtnActive = false
	self.isShowMapPanel = false
	self.cultivationId = nil
	gLuaUIMgr.taskGuidePanel = self
end

function M:OnClose()
	self.curTaskId = 0
	self.currentTaskType = 0
	self.curTaskIsFirst = false
	self.curTaskInfo = nil
	self.preTaskInfo = nil
	self.curType = -1
	self.curTypeStore = nil
	self.shortCutRecordById = {}
	self.curCfgId = 0
	self.isShowShortCut = false
	self.cultivationId = nil
	gLuaUIMgr.taskGuidePanel = nil
end

function M:OnAwake()
	self.msgEvents = {
		[gEventConstants.MAP_CHANGE_TO_INDOOR_MAP] = self:CreateAction("OnMapChangeToIndoor"),
		[gEventConstants.SYNC_SERVER_DIALOG] = self:CreateAction("OnSyncServerDialog"),
		[gEventConstants.CURRENT_TASK_CHANGE] = self:CreateAction("OnCurrentChange"),
		[gEventConstants.TEMPORARY_CURRENT_TASK_CHANGE] = self:CreateAction("OnTempChange"),
		[gEventConstants.TASK_EVENT_CHANGE] = self:CreateAction("OnTaskEventChange"),
		[gEventConstants.ON_GM_CHANGE_TASK] = self:CreateAction("OnGMTaskChange"),
		[gEventConstants.TASK_SHORTCUT_CHANGE] = self:CreateAction("OnTaskShortcutChange"),
		[gEventConstants.LOADING_FINISHED] = self:CreateAction("CheckBaseCondition"),
		[gEventConstants.CLIENT_RANDOM_EVENT_LOCAL_SIGNAL] = self:CreateAction("OnClientRandomEventLocalSignal"),
		[gEventConstants.SWITCH_GPS_SHOW_MODE] = self:CreateAction("OnSwitchGpsShowMode"),
		[gEventConstants.INVITE_RIDING_STATE_CHANGE] = self:CreateAction("OnSwitchGpsShowMode"),
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self:CreateAction("OnSystemUnlock"),
		[gEventConstants.MAP_GLOBAL_GPS_UPDATE] = self:CreateAction("OnMapGpsChange"),
		[gEventConstants.HUD_OPEN_BIG_MAP_TIP_CHANGE] = self:CreateAction("TryShowNewestMainTaskGuide"),
		[gEventConstants.ON_SYNC_TASK_RIDE_NPC_CULTIVATION_ID] = self:CreateAction("OnSyncRideCultivationId")
	}

	self:RegisterMessageEvents(self.msgEvents)

	self.bindData.tab.OnRenderTab = self:CreateAction("OnRenderTaskTab")
	self.bindData.entranceBtn.luaClick = self:CreateAction("OnEntranceBtn")
end

function M:OnRenderTaskTab(index, widget)
	self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeStore then
		self.curTypeStore:OnShow(self.curTypeData)
	end
end

function M:OpenTaskPanel(type, data)
	self.curType = type
	self.curTypeData = data
	local preIndex = self.bindData.tab.selectedIndex
	self.bindData.tab.selectedIndex = self.curType

	if preIndex == self.curType and self.curType == gTaskUtils.TaskGuideSubPanel.Normal then
		if data then
			local taskInfo = gTaskManager:GetTaskInfo(data.TaskId)

			if taskInfo and data and data.TaskCounterChange and taskInfo.Counters[gTaskManager.changedTaskCounterIndex + 1].Value <= taskInfo.Counters[gTaskManager.changedTaskCounterIndex + 1].ConfigValue then
				gStoreManager:GetStoreGroup("NormalTaskPanelStore"):RefreshTaskInfo()

				return
			end
		end

		if self.curTypeStore then
			self:CloseTaskPanel(data)
			self:OpenTaskPanel(preIndex)
		end
	end
end

function M:CloseTaskPanel(data)
	if self.curTypeStore then
		self.curTypeStore:OnClose(data)
	end

	self.curType = -1
	self.curTypeStore = nil
	self.curTypeData = nil

	if self.bindData.tab then
		self.bindData.tab.selectedIndex = self.curType
	end
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnEntranceBtn()
	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.TaskUnlock) then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_TASK_LIST)
end

function M:OnSyncRideCultivationId(eventId, cultivationId)
	self.cultivationId = cultivationId
end

function M:OnLanguageChange()
	self.curTaskInfo, _, _ = gTaskNodeManager:GetTaskCounterInfo(self.curTaskId)

	if self.curTypeStore and self.curTypeStore.LanguageChange ~= nil then
		self.curTypeStore:LanguageChange()
	end
end

function M:RecoverShortCutButtonActive()
	if self.isShowShortCut then
		self:SetShortCutButtonActive(true)
	end
end

function M:SetShortCutButtonActive(isActive)
	gStoreManager:GetStoreGroup("NormalTaskPanelStore").bindData.nTaskGuideBtn.gameObject:SetActive(isActive)
end

function M:OnSwitchGpsShowMode(eventId)
	if not self.curTaskId or self.curTaskId <= 0 then
		return
	end

	local active = not gGpsManager:HudIsShowTaskMode() and not gMapSubSystem_FunctionPoint:IsInInviteRiding()
	self.isTaskBtnActive = active or false
end

function M:OnSystemUnlock(eventId, data)
	local isUnlock = gSystemUnlockMgr:IsUnlock(data)

	if data == SystemUnlockConfig.TaskGuideUnlock and self.bindData.taskGuidePanel then
		self.bindData.taskGuidePanel.gameObject:SetActive(isUnlock)
	end
end

function M:CheckBaseCondition()
	if not gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.TaskGuideUnlock) and self.bindData.taskGuidePanel then
		self.bindData.taskGuidePanel.gameObject:SetActive(false)
	end

	local raidCfg = RaidConfig.GetConfig(gSceneDataMgr.CurrentRaidId)
	local cfg = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)
	self.bindData.RaidType = cfg.hideTaskList - 1
end

function M:OnEntranceBtn()
	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.TaskUnlock) then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_TASK_LIST)
end

function M:OnTaskShortcutChange(eventId, data)
	local isShow = data.isShow or false

	if data.keyId then
		local isShowById = self.shortCutRecordById[data.keyId]

		if isShowById ~= nil and isShowById == isShow then
			return
		end

		self.shortCutRecordById[data.keyId] = isShow

		if not isShow then
			for _, v in pairs(self.shortCutRecordById) do
				if v then
					isShow = true

					break
				end
			end
		end
	end

	self.isShowShortCut = isShow

	if self.isShowShortCut then
		local cfgId = data.cfgId
		self.curCfgId = cfgId
	end
end

function M:OnGMTaskChange(eventId, data)
	if data then
		self.bindData.taskGuidePanel.gameObject:SetActive(true)
	else
		self.bindData.taskGuidePanel.gameObject:SetActive(false)
	end
end

function M:PlayAnim(type)
	local name, animComp = nil

	if self.bindData.type == 0 then
		if type == AnimType.Exit then
			name = "S_Vx_S_NormalTask_01"
		elseif type == AnimType.Enter then
			name = "S_Vx_S_NormalTask_02"
		elseif type == AnimType.RefreshDes then
			name = "S_Vx_S_NormalTask_des"
		elseif type == AnimType.Open then
			name = "S_Vx_S_NormalTask_open"
		end

		if not gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
			animComp = self.bindData.nAnim
		else
			animComp = self.bindData.nAnim_PC
		end

		animComp:Play(name)

		return gCS.LuaUtils.GetAnimationTime(animComp, name)
	elseif self.bindData.type == 1 then
		if type == AnimType.Exit then
			name = "S_Vx_S_SwitchTask_02"
		elseif type == AnimType.Enter then
			name = "S_Vx_S_SwitchTask_01"
		end

		if self.bindData.platform == 0 then
			animComp = self.bindData.sAnim
		else
			animComp = self.bindData.sAnim_PC
		end

		animComp:Play(name)

		return gCS.LuaUtils.GetAnimationTime(animComp, name)
	end

	return 0
end

function M:OnCurrentChange(eventId, data)
	local currentTaskType = data.CurrentTaskType
	self.IsFirstTime = data.IsFirstTime or false

	if currentTaskType == gTaskManager.CurrentTaskType.Task1 then
		self:SetCurrentTaskData(data)
	end

	if self.curTaskInfo then
		if not self:CheckIsJobTaskType() or not gDeliveryTaskManager.isDeliveryJob and not gPoliceJobManager.isPoliceJob and not gPoliceJobManager.isFakeTaskPanel and not gWasherManager.isWasherJob then
			self:OpenTaskPanel(gTaskUtils.TaskGuideSubPanel.Normal, data)
			gStoreManager:GetStoreGroup("NormalTaskPanelStore"):InitTrueBranchData()
		end

		self:RefreshCurTaskGps()
	else
		if self:CheckIsInJobState() then
			return
		end

		self:CloseTaskPanel(data)

		if gTaskManager.NearTrigger then
			gTaskManager.NearTrigger:ClearTriggerInfo()
		end
	end

	self:CheckShowTaskRaidMessageTip(data)
end

function M:OnMapGpsChange()
	return
end

function M:CheckIsInJobState()
	return gDeliveryTaskManager.isDeliveryJob or gPoliceJobManager.isPoliceJob or gWasherManager.isWasherJob
end

function M:TryShowNewestMainTaskGuide()
	if self.curTaskInfo or self:CheckIsInJobState() then
		return
	end

	local isOpen = gMapSystem.ui:HudHasOpenBigMapTip()

	if isOpen then
		if self.curType == gTaskUtils.TaskGuideSubPanel.MapGuide then
			return
		else
			self:OpenTaskPanel(gTaskUtils.TaskGuideSubPanel.MapGuide)
		end
	elseif self.bindData.tab.selectedIndex == gTaskUtils.TaskGuideSubPanel.MapGuide then
		self:CloseTaskPanel()
	end
end

function M:CheckIsJobTaskType()
	local eventInfo = gTaskNodeManager:GetTaskLineByTask(self.curTaskId)

	if table.isNilOrEmpty(eventInfo) then
		return false
	end

	local taskCfg = TaskConfig.GetConfig(self.curTaskId)

	if taskCfg and array.contains(taskCfg.Tags, TaskConfig.TagsType.OccupyTaskGuide) then
		return true
	end

	local eventCfg = TaskEventConfig.GetConfig(eventInfo.TaskLineId)
	local jobId = eventCfg.UrbanJob

	return jobId == JobClassConfig.Police or jobId == JobClassConfig.Delivery or gPoliceJobManager.isFakeTaskPanel or jobId == JobClassConfig.Washer
end

function M:CheckShowTaskRaidMessageTip(data)
	if not data or not data.Reason then
		return
	end

	if not data.TaskId then
		return
	end

	if data.TaskId == 0 then
		return
	end

	if data.Reason ~= UX.Game.ChangeCurrentTaskReason.ForceSet and data.Reason ~= UX.Game.ChangeCurrentTaskReason.Client then
		return
	end

	local taskCfg = gTaskManager:GetTaskConfigInfo(self.curTaskId)

	if array.contains(taskCfg.Tags, TaskConfig.TagsType.HideDestinationMessage) then
		return
	end

	if not self.isInRelateTaskRaid then
		local indoorId = gTaskManager:GetTaskInfoIndoorId(self.curTaskInfo)

		if indoorId > 0 then
			return
		end

		local cfg = RaidConfig.GetConfig(self.curTaskInfo.RaidId)

		if cfg then
			gDisplayMessageMgr:ShowMessage(MessageConfig.OutOfRaid, nil, nil, cfg.Name)
		end
	end
end

function M:HandlePanelClose()
	if self.curTaskInfo then
		self:OpenTaskPanel(gTaskUtils.TaskGuideSubPanel.Normal)
	else
		self:CloseTaskPanel()
	end
end

function M:SetCurrentTaskData(data)
	local currentTaskType = self.currentTaskType

	if data then
		currentTaskType = data.CurrentTaskType
		self.curTaskIsFirst = data.IsFirstTime or false
	end

	if gTaskNodeManager.NowDoingTask[currentTaskType] == nil or gTaskNodeManager.NowDoingTaskLine[currentTaskType] == nil then
		self:NoTask()

		return
	end

	if gTaskManager:GetTaskState(self.curTaskId) == TaskState.Submited then
		self:NoTask()

		return
	end

	local tempTaskId = gTaskNodeManager.NowDoingTask[currentTaskType]
	self.curTaskId = tempTaskId
	self.currentTaskType = currentTaskType
	self.taskLineId = gTaskNodeManager.NowDoingTaskLine[currentTaskType]
	self.gpsPos = nil
	self.triggerPosition = nil
	self.isChallengeRaceSpeed = false
	self.preTaskInfo = self.curTaskInfo
	self.curTaskInfo, self.taskTargetList, self.nowTargetIndex = gTaskNodeManager:GetTaskCounterInfo(self.curTaskId)

	if self.curTaskInfo == nil then
		print_error("#NoCreateIssue 当前任务找不到对应的数据，检查一下是否不在服务器下发的任务列表里, taskid = " .. self.curTaskId)

		return
	end

	local cfg = gTaskManager:GetTaskConfigInfo(self.curTaskId)
	local isSameRaid = self.curTaskInfo.RaidId == gRaidDataManager.RaidId
	self.isInTaskRaid = isSameRaid and not gUIUtils:IsInOtherWorld()
	self.isInRelateTaskRaid = gMapUtils:IsBelongRaidId(gRaidDataManager.RaidId, self.curTaskInfo.RaidId)
	self.hasGpsArrive = {}
	local me = gCS.MyPlayerManager.PlayerUnit

	if me and gRaidDataManager.RaidId then
		self.taskGuideActive = not array.contains(RaidTagConfig.GetConfig(RaidTagConfig.HideTaskPanel).Raids, gRaidDataManager.RaidId) and not gCS.UnitStateMgr:HasState(me, UnitStateConfig.HideTaskUI)
	end

	self.isNoTaskGuide = array.contains(cfg.Tags, TaskConfig.TagsType.NoTaskGuide)
	self.isShowGiveUp = array.contains(cfg.Tags, TaskConfig.TagsType.ShowGiveUpButton) or cfg.ShowGiveUpButton or false
	self.isShowRetry = array.contains(cfg.Tags, TaskConfig.TagsType.ShowRetryButton) or cfg.ShowRetryButton or false
	self.isShowTaskCounter = array.contains(cfg.Tags, TaskConfig.TagsType.ShowCounter) or self.curTaskInfo.ShowCounter
	local taskGps = gGpsManager.gpsList[gTaskGpsType.Trace]

	if table.isNilOrEmpty(gTaskManager.collectionTask) then
		gTaskManager:InitCollectionTask()
	end

	if taskGps and array.contains(gTaskManager.collectionTask, self.curTaskId) then
		gGpsManager:RemoveGPS(taskGps)
		gGpsManager:TryRemoveNowMapGuide()
	end
end

function M:GetTaskCounter()
	local taskInfo = self.curTaskInfo
	local taskCounter = ""

	if self.isShowTaskCounter and taskInfo then
		local nowCounterValue = taskInfo.CounterValue
		local allCounterValue = 0
		local cfg = gTaskManager:GetTaskConfigInfo(self.curTaskId)
		local isShowAllCounter = array.contains(cfg.Tags, TaskConfig.TagsType.ShowAllCounter)

		if taskInfo.totalValue and not isShowAllCounter then
			allCounterValue = taskInfo.totalValue
		elseif self.curTaskInfo.TargetType ~= gTaskManager.ACTION_TYPE.NONE then
			for i = 1, #cfg.Counter do
				local couterNum = cfg.Counter[i]
				allCounterValue = allCounterValue + couterNum
			end
		end

		if isShowAllCounter then
			local tasks = gTaskManager:GetTaskInfo(self.curTaskId)

			if self.curTaskInfo.TargetType ~= gTaskManager.ACTION_TYPE.NONE then
				nowCounterValue = 0

				for i = 1, #tasks.Counters do
					nowCounterValue = tasks.Counters[i].Value + nowCounterValue
				end
			end
		end

		taskCounter = "[" .. nowCounterValue .. "/" .. allCounterValue .. "]"
	end

	return taskCounter
end

function M:NoTask()
	if self.delayShowCurTaskDes then
		gLuaTimeMgrUtils.CancelUnitDelay(self.delayShowCurTaskDes)

		self.delayShowCurTaskDes = nil
	end

	if self.showCurWorkActionAnim then
		gLuaTimeMgrUtils.CancelUnitDelay(self.showCurWorkActionAnim)

		self.bindData.taskWorkActionAnimActive = false
		self.showCurWorkActionAnim = nil
	end

	self.curTaskId = 0
	self.curTaskInfo = nil
	self.preTaskInfo = nil
	self.nowTargetIndex = nil
	self.taskTargetList = nil
	self.inFinishCounter = nil
	self.nowTargetIndex = nil
	self.isShowTaskCounter = nil
	self.triggerPosition = nil
	self.shortCutRecordById = {}
	self.YuandiList = {}
	self.curCfgId = 0
	self.isShowShortCut = false
end

function M:OnTempChange(eventId, data)
	if self:CheckIsInJobState() then
		return
	end

	self:SetTemporaryTaskData(data)
end

function M:SetTemporaryTaskData(data)
	if table.isNilOrEmpty(data) then
		return
	end

	local taskCfg = TaskConfig.GetConfig(self.curTaskId)

	if taskCfg and taskCfg.Title == TaskTitle.CHALLENGE then
		return
	end

	self.tempTaskId = data.taskId
	local eventInfo = gTaskNodeManager:GetTaskLineByTask(data.taskId)

	if table.isNilOrEmpty(eventInfo) then
		print_error("当前临时弹出任务找不到任何taskEvent据信息  taskId = " .. data.taskId)

		return
	end

	local cfg = TaskEventConfig.GetConfig(eventInfo.TaskLineId)

	if cfg then
		self:OpenTaskPanel(gTaskUtils.TaskGuideSubPanel.Switch, {
			taskId = data.taskId
		})
	else
		print_error("当前临时弹出任务找不到任何数据信息  taskId = " .. data.taskId)
	end
end

function M:RefreshCurTaskGps()
	if self.isInTaskRaid or self.isInRelateTaskRaid then
		gTaskManager.NearTrigger:RefreshTriggerInfo(self.curTaskId)

		return
	end
end

function M:OnMapChangeToIndoor(eventId, data)
	if not table.isNilOrEmpty(gTaskNodeManager.NowDoingTask) and data.isSwitchScene == false and self.curTaskInfo then
		self:RefreshCurTaskGps()
	end
end

function M:OnSyncServerDialog(eventId, data)
	local nowDialogId = gDialogManager.currentDialogId

	if nowDialogId and self.currentTaskInfo and nowDialogId == self.currentTaskInfo.DialogId then
		self:RefreshCurTaskGps()
	end
end

function M:AskAcceptTask(taskId)
	gClientToGameDelegate:AskAcceptTask(taskId).Callback = function (err)
		if err == MessageConfig.Ok then
			print_debug("AskAcceptRandomEvent Rpc Reply:", taskId)
		end
	end
end

function M:AskDeleteRangeEvent(taskId)
	gCoroutineManager:StartCoroutine(function ()
		while not gLuaDataManager.isNetworkAvailable or gLuaDataManager.isLoadingPanelOn do
			coroutine.yield(nil)
		end

		gClientToGameDelegate:AskDeleteTask(taskId, true).Callback = function (err)
			if err == MessageConfig.Ok then
				print_debug("AskDeleteRangeEvent Rpc Reply:", taskId)
			end
		end
	end)
end

function M:OnClientRandomEventLocalSignal(eventId, data)
	if not data.taskId then
		return
	end

	local code = data.code
	local isEnter = data.isEnter

	if code == 0 then
		if data.taskId and data.taskId ~= 0 and self.extraTaskId == data.taskId then
			return
		end

		if isEnter then
			self:AskAcceptTask(data.taskId)
		end
	elseif code == 1 then
		-- Nothing
	elseif code == 2 then
		if not isEnter then
			if gTaskManager:GetTaskState(data.taskId) ~= TaskState.Accepted then
				return
			end

			self:AskDeleteRangeEvent(data.taskId)
		end
	elseif code ~= 3 then
		return
	end
end
