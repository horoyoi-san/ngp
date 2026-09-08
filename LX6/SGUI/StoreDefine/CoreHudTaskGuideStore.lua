-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CoreHudTaskGuideStore.lua
-- Decompiled from: 01500_CoreHudTaskGuideStore.lua_c655990edbc0.luajit

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
local RogueRaidConfig = LTConfig.RogueRaidConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local JobClassConfig = LTConfig.UrbanJobJobClassConfig
local AnimType = {
	U2xU = 4,
	["h\\xa0\\xb6\\xaa\\xa4"] = 2,
	["a_ȯ\\x81\\xb0 \\xcc\\xfb"] = 3,
	["_:tO"] = 1
}

M.ctor = function(self)
	self.isStart = false
	self.panelCallback = {}
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
	self.isShowMapPanel = false
	self.cultivationId = nil
	self.listenHpChanged = false
end

M.OnGroupDisable = function(self)
	self.isStart = false
	self.panelCallback = {}
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

	self.OnChangeHpListening(self, nil)
end

M.OnStart = function(self)
	self.isStart = true

	if self.panelCallback then
		for _, func in ipairs(self.panelCallback) do
			func()
		end

		self.panelCallback = {}
	end
end

M.SetBloodBarPosition = function(self, height)
	if not self.bindData.gameBarPanel then
		return
	end

	local pos = self.bindData.gameBarPanel.rectTransform.anchoredPosition
	self.bindData.gameBarPanel.rectTransform.anchoredPosition = Vector2.New(pos.x, -height)
end

M.GetGameBarPanelHeight = function(self)
	local hasHealthyBarData = gBloodBarGameManager:HasHealthyBarData()

	if not hasHealthyBarData or not self.bindData.gameBarPanel or not self.bindData.gameBarPanel.gameObject.activeSelf then
		return 0
	end

	return self.bindData.gameBarPanel:GetTargetHeight()
end

M.OnAwake = function(self)
	self.msgEvents = {
		[gEventConstants.CURRENT_TASK_CHANGE] = self:CreateAction("OnCurrentChange"),
		[gEventConstants.TEMPORARY_CURRENT_TASK_CHANGE] = self:CreateAction("OnTempChange"),
		[gEventConstants.TASK_EVENT_CHANGE] = self:CreateAction("OnTaskEventChange"),
		[gEventConstants.ON_GM_CHANGE_TASK] = self:CreateAction("OnGMTaskChange"),
		[gEventConstants.TASK_SHORTCUT_CHANGE] = self:CreateAction("OnTaskShortcutChange"),
		[gEventConstants.LOADING_FINISHED] = self:CreateAction("CheckBaseCondition"),
		[gEventConstants.CLIENT_RANDOM_EVENT_LOCAL_SIGNAL] = self:CreateAction("OnClientRandomEventLocalSignal"),
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self:CreateAction("OnSystemUnlock"),
		[gEventConstants.HUD_OPEN_BIG_MAP_TIP_CHANGE] = self:CreateAction("TryShowNewestMainTaskGuide"),
		[gEventConstants.ON_SYNC_TASK_RIDE_NPC_CULTIVATION_ID] = self:CreateAction("OnSyncRideCultivationId"),
		[gEventConstants.BLOOD_BAR_START_OR_CLOSE] = self:CreateAction("OnBloodBarStartClose"),
		[gEventConstants.CHANGE_COUNTER_DES_GPS] = self:CreateAction("OnChangeCurDes"),
		[gEventConstants.WATCHING_TASK_CHANGE] = self:CreateAction("OnWatchingTaskChange"),
		[gEventConstants.ON_MINIMAP_VISIBILITY_CHANGE] = self:CreateAction("OnMiniMapClosed"),
		[gEventConstants.L50_AFTER_SWITCH_SCENE] = self:CreateAction("OnAfterSwitchScene")
	}

	self:RegisterMessageEvents(self.msgEvents)

	self.bindData.positionCtrl = 0

	self.bindData.gameBarPanel:SetActive(false)

	self.bindData.tab.OnRenderTab = self:CreateAction("OnRenderTaskTab")
	self.bindData.entranceBtn.luaClick = self:CreateAction("OnEntranceBtn")
end

M.OnEnable = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		if not gPanelManager:IsPanelShowing(gPanelId.S_MINI_MAP_PANEL) then
			local state = gUIFunctionStateManager:GetExitEnable()

			if state then
				self.bindData.positionCtrl = 1
			else
				self.bindData.positionCtrl = 2
			end
		else
			self.bindData.positionCtrl = 0
		end

		gTaskUtils:SendMobileTaskPanelChange(0)
	end

	local curRaidCfg = RaidConfig.GetConfig(gSceneDataMgr.CurrentRaidId)

	if curRaidCfg and curRaidCfg.RaidType ~= RogueRaidConfig.RogueRaidType then
		self.OpenTaskPanel(self, gTaskUtils.TaskGuideSubPanel.Roguelike, gSceneDataMgr.CurrentRaidId)
	elseif self.curType ~= gTaskUtils.TaskGuideSubPanel.Roguelike then
		self.HandlePanelClose(self)
	end
end

M.OnRenderTaskTab = function(self, index, widget)
	self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeStore then
		self.curTypeStore:OnShow(self.curTypeData)
	end
end

M.OnWatchingTaskChange = function(self, eventId, data)
	if data.isWatching and self.curType == gTaskUtils.TaskGuideSubPanel.Normal then
		self.OpenTaskPanel(self, gTaskUtils.TaskGuideSubPanel.Normal)
	end

	gStoreManager:GetStoreGroup("NormalTaskPanelStore"):OnWatchingTaskChange(nil, data)

	if not data.isWatching then
		gTaskUtils:HandleTaskGuideClose()
	end
end

M.OpenTaskPanel = function(self, type, data)
	if not self.isStart then
		table.insert(self.panelCallback, function ()
			self:OpenTaskPanel(type, data)
		end)

		return
	end

	self.curType = type
	self.curTypeData = data
	self.bindData.tab.selectedIndex = self.curType
end

M.CloseTaskPanel = function(self, data)
	if not self.isStart then
		table.insert(self.panelCallback, function ()
			self:CloseTaskPanel(data)
		end)

		return
	end

	if self.curTypeStore then
		self.curTypeStore:OnClose(data)
	end

	self.curType = -1
	self.curTypeStore = nil
	self.curTypeData = nil

	if self.bindData.tab then
		self.bindData.tab.selectedIndex = self.curType
	end

	gTaskUtils:SendMobileTaskPanelChange(0)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnEntranceBtn = function(self)
	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.TaskUnlock) then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_TASK_LIST)
end

M.OnMiniMapClosed = function(self, eventId, data)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	local state = gUIFunctionStateManager:GetExitEnable()

	if not data then
		if state then
			self.bindData.positionCtrl = 1
		else
			self.bindData.positionCtrl = 2
		end
	else
		self.bindData.positionCtrl = 0
	end
end

M.OnAfterSwitchScene = function(self, eventId, data)
	local curRaidId = data.curRaidId
	local preRaidId = data.prevRaidId

	if curRaidId == preRaidId then
		local curRaidCfg = RaidConfig.GetConfig(curRaidId)

		if curRaidCfg and curRaidCfg.RaidType ~= RogueRaidConfig.RogueRaidType then
			self.OpenTaskPanel(self, gTaskUtils.TaskGuideSubPanel.Roguelike, curRaidId)
		elseif self.curType ~= gTaskUtils.TaskGuideSubPanel.Roguelike then
			local preRaidCfg = RaidConfig.GetConfig(preRaidId)

			if not preRaidCfg or preRaidCfg.RaidType ~= RogueRaidConfig.RogueRaidType then
				self.HandlePanelClose(self)
			end
		end
	end
end

M.OnBloodBarStartClose = function(self, eventId, data)
	gBloodBarGameManager:OnGameStartOrClose(data)
end

M.SetBloodBarEnable = function(self, enable)
	if not self.isStart then
		table.insert(self.panelCallback, function ()
			self.bindData.gameBarPanel:SetActive(enable)
		end)

		return
	end

	self.bindData.gameBarPanel:SetActive(enable)
end

M.OnSyncRideCultivationId = function(self, eventId, cultivationId)
	self.cultivationId = cultivationId
end

M.GetRideCultivationId = function(self)
	return self.cultivationId
end

M.IsInCultivation = function(self)
	if self.curTaskInfo and self.curTaskInfo.Title ~= 12 then
		return true
	end

	return false
end

M.SetTaskGuidePanelActive = function(self, active)
	self.bindData.taskGuidePanel:SetActive(active)

	if not active then
		gTaskUtils:SendMobileTaskPanelChange(0)
	end
end

M.OnLanguageChange = function(self)
	self.curTaskInfo, _, _ = gTaskNodeManager:GetTaskCounterInfo(self.curTaskId)

	if self.curTypeStore and self.curTypeStore.LanguageChange == nil then
		self.curTypeStore:LanguageChange()
	end
end

M.RecoverShortCutButtonActive = function(self)
	if self.isShowShortCut then
		self.SetShortCutButtonActive(self, true)
	end
end

M.SetShortCutButtonActive = function(self, isActive)
	gStoreManager:GetStoreGroup("NormalTaskPanelStore").bindData.nTaskGuideBtn.gameObject:SetActive(isActive)
end

M.OnSystemUnlock = function(self, eventId, data)
	local isUnlock = gSystemUnlockMgr:IsUnlock(data)

	if data ~= SystemUnlockConfig.TaskGuideUnlock and self.bindData.taskGuidePanel then
		self.bindData.taskGuidePanel.gameObject:SetActive(isUnlock)
	end
end

M.CheckBaseCondition = function(self)
	if not gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.TaskGuideUnlock) and self.bindData.taskGuidePanel then
		self.bindData.taskGuidePanel.gameObject:SetActive(false)
	end

	local raidCfg = RaidConfig.GetConfig(gSceneDataMgr.CurrentRaidId)
	local cfg = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)
	self.bindData.RaidType = cfg.hideTaskList - 1
end

M.OnEntranceBtn = function(self)
	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.TaskUnlock) then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_TASK_LIST)
end

M.OnTaskShortcutChange = function(self, eventId, data)
	local isShow = data.isShow or false

	if data.keyId and not string.is_null_or_empty(data.keyId) then
		local isShowById = self.shortCutRecordById[data.keyId]

		if isShowById == nil and isShowById ~= isShow then
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

M.OnGMTaskChange = function(self, eventId, data)
	if data then
		self.bindData.taskGuidePanel.gameObject:SetActive(true)
	else
		self.bindData.taskGuidePanel.gameObject:SetActive(false)
	end
end

M.PlayAnim = function(self, type)
	local name, animComp = nil

	if self.bindData.type ~= 0 then
		if type ~= AnimType.Exit then
			name = "S_Vx_S_NormalTask_01"
		elseif type ~= AnimType.Enter then
			name = "S_Vx_S_NormalTask_02"
		elseif type ~= AnimType.RefreshDes then
			name = "S_Vx_S_NormalTask_des"
		elseif type ~= AnimType.Open then
			name = "S_Vx_S_NormalTask_open"
		end

		if not gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
			animComp = self.bindData.nAnim
		else
			animComp = self.bindData.nAnim_PC
		end

		animComp.Play(animComp, name)

		return gCS.LuaUtils.GetAnimationTime(animComp, name)
	elseif self.bindData.type ~= 1 then
		if type ~= AnimType.Exit then
			name = "S_Vx_S_SwitchTask_02"
		elseif type ~= AnimType.Enter then
			name = "S_Vx_S_SwitchTask_01"
		end

		if self.bindData.platform ~= 0 then
			animComp = self.bindData.sAnim
		else
			animComp = self.bindData.sAnim_PC
		end

		animComp.Play(animComp, name)

		return gCS.LuaUtils.GetAnimationTime(animComp, name)
	end

	return 0
end

M.OnCurrentChange = function(self, eventId, data)
	local currentTaskType = data.CurrentTaskType
	self.IsFirstTime = data.IsFirstTime or false

	if currentTaskType ~= gTaskManager.CurrentTaskType.Task1 then
		self.SetCurrentTaskData(self, data)
	end

	if self.curTaskInfo then
		local taskCfg = TaskConfig.GetConfig(self.curTaskId)
		local challnegeId = gChallengeManager:GetChallengeIdByTaskId(self.curTaskId)

		if challnegeId or gChallengeManager.isWushuMode then
			self.OpenTaskPanel(self, gTaskUtils.TaskGuideSubPanel.Challenge, data)
		elseif taskCfg and array.contains(taskCfg.Tags, TaskConfig.TagsType.HideAndSeek) then
			self.OpenTaskPanel(self, gTaskUtils.TaskGuideSubPanel.CatRats, data)
		else
			if (not self.CheckIsJobTaskType(self) or not gDeliveryTaskManager.isDeliveryJob and not gPoliceJobManager.isReceivingOrder) and not gPoliceJobManager.isFakeTaskPanel and not gWasherManager.showWasherHud and not gWasherManager.showGlueHud then
				self:OpenTaskPanel(gTaskUtils.TaskGuideSubPanel.Normal, data)
				gStoreManager:GetStoreGroup("NormalTaskPanelStore"):InitTrueBranchData()
				gStoreManager:GetStoreGroup("NormalTaskPanelStore"):OnShow()
			end

			self.RefreshGameplayRule(self)
		end

		self.RefreshCurTaskGps(self)
	else
		if gTaskManager.NearTrigger then
			gTaskManager.NearTrigger:ClearTriggerInfo()
		end

		if self.CheckIsInJobState(self) then
			return
		end

		self.ClearGameplayRule(self)
		self.CloseTaskPanel(self, data)
		self.TryShowNewestMainTaskGuide(self)
	end

	self.CheckShowTaskRaidMessageTip(self, data)
end

M.OnChangeCurDes = function(self, eventId, data)
	if not self.isStart then
		table.insert(self.panelCallback, function ()
			self:OnChangeCurDes(eventId, data)
		end)

		return
	end

	if self.curTypeStore and self.curTypeStore.OnChangeCurDes then
		self.curTypeStore:OnChangeCurDes(eventId, data)
	end
end

M.CheckIsInJobState = function(self)
	return gDeliveryTaskManager:CheckIsDeliveryPanel() or gWasherManager.showWasherHud or gWasherManager.showGlueHud or gPoliceJobManager.isPoliceJob and gPoliceJobManager.isReceivingOrder or self:CheckIsInRogueLike()
end

M.CheckIsInRogueLike = function(self)
	local raidCfg = RaidConfig.GetConfig(gSceneDataMgr.CurrentRaidId)
	local cfg = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType or 0)

	return cfg and cfg.Type ~= RaidRaidTypeConfig.TypeType.SoloPve
end

M.TryShowNewestMainTaskGuide = function(self)
	if not self.isStart then
		table.insert(self.panelCallback, function ()
			self:TryShowNewestMainTaskGuide()
		end)

		return
	end

	if self.curTaskInfo or self.CheckIsInJobState(self) then
		return
	end

	local isOpen = gMapSystem.ui:HudHasOpenBigMapTip()

	if isOpen then
		if self.curType ~= gTaskUtils.TaskGuideSubPanel.MapGuide then
			return
		else
			self.OpenTaskPanel(self, gTaskUtils.TaskGuideSubPanel.MapGuide)
		end
	elseif self.bindData.tab.selectedIndex ~= gTaskUtils.TaskGuideSubPanel.MapGuide then
		self.CloseTaskPanel(self)
	end
end

M.CheckTaskPanelState = function(self, panelState)
	return self.curType ~= panelState
end

M.CheckIsJobTaskType = function(self)
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

	return jobId ~= JobClassConfig.Delivery or gPoliceJobManager.isFakeTaskPanel or jobId ~= JobClassConfig.Police
end

M.CheckShowTaskRaidMessageTip = function(self, data)
	if not data or not data.Reason then
		return
	end

	if not data.TaskId then
		return
	end

	if data.TaskId ~= 0 then
		return
	end

	if data.Reason == UX.Game.ChangeCurrentTaskReason.ForceSet and data.Reason == UX.Game.ChangeCurrentTaskReason.Client then
		return
	end

	local taskCfg = gTaskManager:GetTaskConfigInfo(self.curTaskId)

	if array.contains(taskCfg.Tags, TaskConfig.TagsType.HideDestinationMessage) then
		return
	end

	if not self.isInRelateTaskRaid then
		local indoorId = gTaskManager:GetTaskInfoIndoorId(self.curTaskInfo)

		if indoorId <= 0 then
			return
		end

		local cfg = RaidConfig.GetConfig(self.curTaskInfo.RaidId)

		if cfg then
			gDisplayMessageMgr:ShowMessage(MessageConfig.OutOfRaid, nil, , cfg.Name)
		end
	end
end

M.HandlePanelClose = function(self)
	if self.curTaskInfo then
		self.OpenTaskPanel(self, gTaskUtils.TaskGuideSubPanel.Normal)
	else
		self.CloseTaskPanel(self)
	end
end

M.SetCurrentTaskData = function(self, data)
	local currentTaskType = self.currentTaskType

	if data then
		currentTaskType = data.CurrentTaskType
		self.curTaskIsFirst = data.IsFirstTime or false
	end

	if gTaskNodeManager.NowDoingTask[currentTaskType] ~= nil or gTaskNodeManager.NowDoingTaskLine[currentTaskType] ~= nil then
		self.NoTask(self)

		return
	end

	if gTaskManager:GetTaskState(self.curTaskId) ~= TaskState.Submited then
		self.NoTask(self)

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

	if self.curTaskInfo ~= nil then
		print_error("#NoCreateIssue 当前任务找不到对应的数据，检查一下是否不在服务器下发的任务列表里, taskid = " .. self.curTaskId)

		return
	end

	local cfg = gTaskManager:GetTaskConfigInfo(self.curTaskId)
	local isSameRaid = self.curTaskInfo.RaidId ~= gRaidDataManager.RaidId
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

	self:OnChangeHpListening(self.curTaskInfo.ListenSpoonAgentId)

	local taskGps = gGpsManager.gpsList[gTaskGpsType.Trace]

	if table.isNilOrEmpty(gTaskManager.collectionTask) then
		gTaskManager:InitCollectionTask()
	end

	if taskGps and array.contains(gTaskManager.collectionTask, self.curTaskId) then
		gGpsManager:RemoveGPS(taskGps)
		gGpsManager:TryRemoveNowMapGuide()
	end
end

M.OnChangeHpListening = function(self, spoonAgentIds)
	self.listenHpChanged = spoonAgentIds == nil

	gBloodBarGameManager:OnCurrentChangeListenHpChanged(spoonAgentIds)
end

M.GetTaskCounter = function(self)
	local taskInfo = self.curTaskInfo
	local taskCounter = ""

	if self.isShowTaskCounter and taskInfo then
		local nowCounterValue = taskInfo.CounterValue
		local allCounterValue = 0
		local cfg = gTaskManager:GetTaskConfigInfo(self.curTaskId)
		local isShowAllCounter = array.contains(cfg.Tags, TaskConfig.TagsType.ShowAllCounter)

		if taskInfo.totalValue and not isShowAllCounter then
			allCounterValue = taskInfo.totalValue
		elseif self.curTaskInfo.TargetType == gTaskManager.ACTION_TYPE.NONE then
			for i = 1, #cfg.Counter do
				local couterNum = cfg.Counter[i]
				allCounterValue = allCounterValue + couterNum
			end
		end

		if isShowAllCounter then
			local tasks = gTaskManager:GetTaskInfo(self.curTaskId)

			if self.curTaskInfo.TargetType == gTaskManager.ACTION_TYPE.NONE then
				nowCounterValue = 0

				for i = 1, #tasks.Counters do
					nowCounterValue = tasks.Counters[i].Value + nowCounterValue
				end
			end
		end

		if not taskInfo.NotShowProgress or not not isShowAllCounter then
			taskCounter = "[" .. nowCounterValue .. "/" .. allCounterValue .. "]"
		end
	end

	return taskCounter
end

M.NoTask = function(self)
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

	self.OnChangeHpListening(self, nil)
end

M.OnTempChange = function(self, eventId, data)
	self.SetTemporaryTaskData(self, data)
end

M.SetTemporaryTaskData = function(self, data)
	if table.isNilOrEmpty(data) then
		return
	end

	local taskCfg = TaskConfig.GetConfig(self.curTaskId)

	if taskCfg and taskCfg.Title ~= TaskTitle.CHALLENGE then
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
		self.OpenTaskPanel(self, gTaskUtils.TaskGuideSubPanel.Switch, {
			taskId = data.taskId
		})
	else
		print_error("当前临时弹出任务找不到任何数据信息  taskId = " .. data.taskId)
	end
end

M.RefreshGameplayRule = function(self)
	if not gTaskManager.TaskGamePlay then
		return
	end

	gTaskManager.TaskGamePlay:ChangeCurrentPanelRule(self.curTaskId, self.curTaskInfo)
end

M.ClearGameplayRule = function(self)
	if gTaskManager.TaskGamePlay then
		gTaskManager.TaskGamePlay:ClearTaskPanel()
	end
end

M.RefreshCurTaskGps = function(self)
	if self.isInTaskRaid or self.isInRelateTaskRaid then
		gTaskManager.NearTrigger:RefreshTriggerInfo(self.curTaskId)

		return
	end
end

M.AskAcceptTask = function(self, taskId)
	slot2 = gClientToGameDelegate

	slot2:AskAcceptTask(taskId).Callback = function (err)
		if err ~= MessageConfig.Ok then
			print_debug("AskAcceptRandomEvent Rpc Reply:", taskId)
		end
	end
end

M.AskEnterRaidRandomEvent = function(self, eventId)
	slot2 = gCoroutineManager

	slot2:StartCoroutine(function ()
		while not gLuaDataManager.isNetworkAvailable or gLuaDataManager.isLoadingPanelOn do
			coroutine.yield(nil)
		end

		gClientToGameDelegate:AskEnterRaidRandomEvent(eventId)
	end)
end

M.AskDeleteRangeEvent = function(self, taskId)
	slot2 = gCoroutineManager

	slot2:StartCoroutine(function ()
		while not gLuaDataManager.isNetworkAvailable or gLuaDataManager.isLoadingPanelOn do
			coroutine.yield(nil)
		end

		slot0 = gClientToGameDelegate

		slot0:AskDeleteTask(taskId, true).Callback = function (err)
			if err ~= MessageConfig.Ok then
				print_debug("AskDeleteRangeEvent Rpc Reply:", taskId)
			end
		end
	end)
end

M.AskLeaveRaidRandomEvent = function(self, eventId)
	slot2 = gCoroutineManager

	slot2:StartCoroutine(function ()
		while not gLuaDataManager.isNetworkAvailable or gLuaDataManager.isLoadingPanelOn do
			coroutine.yield(nil)
		end

		gClientToGameDelegate:AskLeaveRaidRandomEvent(eventId)
	end)
end

M.OnClientRandomEventLocalSignal = function(self, eventId, data)
	if gLinkManager.LinkMode ~= UX.Game.LinkMode.None then
		if not data.taskId then
			return
		end

		local code = data.code
		local isEnter = data.isEnter

		if code ~= 0 then
			if data.taskId and data.taskId == 0 and self.extraTaskId ~= data.taskId then
				return
			end

			if isEnter then
				self.AskAcceptTask(self, data.taskId)
			end
		elseif code ~= 1 then
			-- Nothing
		elseif code ~= 2 then
			if not isEnter then
				if gTaskManager:GetTaskState(data.taskId) == TaskState.Accepted then
					return
				end

				self.AskDeleteRangeEvent(self, data.taskId)
			end
		elseif code == 3 then
			return
		end
	else
		if not data.taskLineId then
			return
		end

		local code = data.code
		local isEnter = data.isEnter

		if code ~= 0 then
			if not data.taskLineId or data.taskLineId ~= 0 then
				return
			end

			if isEnter then
				self.AskEnterRaidRandomEvent(self, data.taskLineId)
			end
		elseif code ~= 1 then
			-- Nothing
		elseif code ~= 2 then
			if not isEnter then
				if data.taskId and data.taskId == 0 and gTaskManager:GetTaskState(data.taskId) == TaskState.Accepted then
					return
				end

				self.AskLeaveRaidRandomEvent(self, data.taskLineId)
			end
		elseif code == 3 then
			return
		end
	end
end
