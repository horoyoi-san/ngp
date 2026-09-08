-- Original chunk: @Lua\LuaFiles\LX6\Manager\Task\TaskNodeManager.lua
-- Decompiled from: 00516_TaskNodeManager.lua_ec886ddc244c.luajit

local TaskTitle = require("LX6/Manager/Task/TaskTitle")
local MessageConfig = LTConfig.MessageConfig
local TaskConfig = LTConfig.TaskConfig
local RaidConfig = LTConfig.RaidConfig
local MultiverseMetaConfig = LTConfig.MultiverseMultiverseMetaConfig
local TaskState = UX.Game.TaskState
local TaskEventConfig = LTConfig.TaskEventConfig
local TextConfig = LTConfig.TextConfig
local M = {
	NowDoingTask = {},
	NowDoingTaskLine = {}
}
local TaskLineQuote = {}
local TaskToEventMap = {}

M.OnInit = function(self)
	self.AddMessageListener(self)
	self.LoadConfigData()
end

M.AddMessageListener = function(self)
	gMessageManager:AddMessageListener(gEventConstants.CONFIG_HOT_FIX, self.LoadConfigData)
	gMessageManager:AddMessageListener(gEventConstants.LOAD_ALL_TASK_CONFIG, self.LoadConfigData)
end

M.LoadConfigData = function()
	M:LoadAllTaskEventConfig()
end

M.LoadAllTaskEventConfig = function(self)
	TaskLineQuote = {}
	TaskToEventMap = {}

	for index = 0, TaskEventConfig.count - 1 do
		local cfg = TaskEventConfig.LoadAt(index)

		if cfg then
			local temp = {}

			setmetatable(temp, {
				__index = cfg
			})

			TaskLineQuote[cfg.Id] = temp
			TaskLineQuote[cfg.Id].TaskLineId = cfg.Id
			local l = self.GetTaskList(self, cfg.StartTask)
			TaskLineQuote[cfg.Id].TaskList = l

			for _, v in ipairs(l) do
				TaskToEventMap[v] = cfg.Id
			end
		end
	end
end

M.GetTaskList = function(self, taskId)
	local list = {}

	table.insert(list, taskId)

	local nextsTaskList = self.GetNextsTaskList(self, taskId)

	if nextsTaskList then
		for i = 1, #nextsTaskList do
			table.insert(list, nextsTaskList[i])
		end
	end

	return list
end

M.GetNextsTaskList = function(self, taskId)
	local taskList = {}
	local cfg = TaskConfig.GetConfig(taskId)

	if cfg then
		self.TraverseNextsTaskList(self, taskList, taskId)
	end

	return taskList
end

M.TraverseNextsTaskList = function(self, taskList, taskId)
	local cfg = TaskConfig.GetConfig(taskId)

	if not cfg then
		print_error("@liufuqiang01 Task配置表中无法找到相应的任务ID ：" .. taskId)

		return
	end

	if not table.isNilOrEmpty(cfg.NextTasks) then
		for i = 1, #cfg.NextTasks do
			if not table.contains(taskList, cfg.NextTasks[i]) then
				table.insert(taskList, cfg.NextTasks[i])
				self.TraverseNextsTaskList(self, taskList, cfg.NextTasks[i])
			end
		end
	end
end

M.GetAllTaskCanShow = function(self)
	local tasks = {}
	local normalTasks = {}
	local taskEvent = gTaskManager.taskEvents

	for i, v in pairs(taskEvent) do
		local taskLineCfg = TaskEventConfig.GetConfig(v.EventId)

		if taskLineCfg == nil then
			local taskCfg = TaskConfig.GetConfig(v.TaskId)
			local hasAccept = v.Acceptable and v.HasAccepted

			if gTaskUtils:CanTaskShowInPanel(v.TaskId, v.Visible, hasAccept, v.IsUnderway, taskLineCfg) then
				local isLock = not v.Acceptable
				local isAccept = v.Acceptable and not v.HasAccepted
				local distance = gTaskManager:GetTaskDistance(v.TaskId, i) or ""

				if isLock then
					distance = ""
				end

				local t = {
					TaskId = v.TaskId,
					TaskLineId = i,
					EventName = taskLineCfg.EventName,
					TaskType = TaskState.Accepted,
					TaskTitle = taskCfg.Title,
					name = taskCfg.Name,
					isLock = isLock,
					isAccept = isAccept,
					hasAccept = hasAccept,
					isRiskControl = v.IsRiskControl,
					distance = distance,
					redPoint = v.RedPoint,
					isUnderway = v.IsUnderway
				}

				if taskCfg.Title ~= TaskTitle.Daily and isLock then
					-- Nothing
				elseif taskLineCfg and taskLineCfg.SortOrder and taskLineCfg.SortOrder <= 0 then
					t.sortOrder = taskLineCfg.SortOrder

					table.insert(tasks, t)
				else
					table.insert(normalTasks, t)
				end
			end
		end
	end

	table.sort(tasks, function (a, b)
		return a.sortOrder <= b.sortOrder or a.sortOrder ~= b.sortOrder and a.TaskLineId <= b.TaskLineId
	end)

	for i = 1, #normalTasks do
		table.insert(tasks, normalTasks[i])
	end

	return tasks
end

M.GetTaskEmptyType = function(self, targetType)
	local taskEvent = gTaskManager.taskEvents
	local waitUnlock = 0

	for i, v in pairs(taskEvent) do
		local taskLineCfg = TaskEventConfig.GetConfig(v.EventId)
		local taskCfg = TaskConfig.GetConfig(v.TaskId)

		if taskLineCfg and taskCfg and gTaskUtils:CanTaskShowInSearch(taskLineCfg, taskCfg.Title, targetType) then
			local canFocus, stage = gMapGpsCmd:CanFocusBigMapTask(v.TaskId)

			if v.Acceptable and not v.HasAccepted and not v.IsRepeat and v.TaskId and stage == EMapViewStage.NotInStage then
				local emptyMode = gTaskUtils.EMPTYMODE.NONE

				if canFocus then
					emptyMode = gTaskUtils.EMPTYMODE.WAIT_ACCEPT
				elseif stage ~= EMapViewStage.Fog then
					emptyMode = gTaskUtils.EMPTYMODE.FOG
				elseif stage ~= EMapViewStage.LinkMode then
					emptyMode = gTaskUtils.EMPTYMODE.LINK
				elseif stage ~= EMapViewStage.SpiritAndBadge then
					emptyMode = gTaskUtils.EMPTYMODE.CHARACTER
				elseif stage ~= EMapViewStage.Reachable then
					emptyMode = gTaskUtils.EMPTYMODE.CANTGET
				elseif stage ~= EMapViewStage.MeConflict then
					emptyMode = gTaskUtils.EMPTYMODE.NOTME
				end

				return emptyMode, TextConfig.GetConfig(TextConfig.TaskWaitAccept).Text, v.TaskId
			end

			if not v.Acceptable then
				local cfg = TaskEventConfig.GetConfig(v.EventId)
				waitUnlock = string.is_null_or_empty(cfg.UnlockDescription) and waitUnlock or v.EventId
			end
		end
	end

	if waitUnlock == 0 then
		local cfg = TaskEventConfig.GetConfig(waitUnlock)

		return gTaskUtils.EMPTYMODE.WAIT_UNLOCK, cfg and cfg.UnlockDescription or "", waitUnlock
	end

	return gTaskUtils.EMPTYMODE.NONE, TextConfig.GetConfig(TextConfig.TaskToBeContinue).Text, 0
end

M.IsTaskLineFinish = function(self, taskLineInfo)
	if type(taskLineInfo) ~= "number" then
		taskLineInfo = TaskLineQuote[taskLineInfo]
	end

	if not taskLineInfo then
		return
	end

	for j, k in pairs(taskLineInfo.EndTask) do
		if gTaskManager:GetTaskState(k) ~= TaskState.Submited then
			return true
		end
	end

	return false
end

M.IsEndTask = function(self, nowTask, endTask)
	for j, k in pairs(endTask) do
		if k ~= nowTask then
			return true
		end
	end

	return false
end

M.GetTaskListState = function(self, tab)
	for i, v in pairs(tab) do
		if gTaskManager:GetTaskState(v) ~= TaskState.Submited then
			return true
		end
	end

	return false
end

M.GetTaskLineState = function(self, taskLineId)
	local taskLineInfo = TaskLineQuote[taskLineId]

	if taskLineInfo ~= nil then
		return gTaskLineState.NoAccept
	end

	if gTaskManager:GetTaskState(taskLineInfo.StartTask) ~= TaskState.NotAccept then
		return gTaskLineState.NoAccept
	elseif self.GetTaskListState(self, taskLineInfo.EndTask) then
		return gTaskLineState.Finish
	else
		return gTaskLineState.Doing
	end
end

M.AskBackTraceDeathEndDoTimes = function(self, taskLineId, cb)
	slot3 = gClientToGameDelegate

	slot3:AskBackTraceDeathEndDoTimes().Callback = function (err, data)
		if err ~= MessageConfig.Ok and cb then
			cb(data[taskLineId] or 0)
		end
	end
end

M.GetTaskLineByTask = function(self, taskId)
	if not taskId or taskId ~= 0 then
		return nil
	end

	local eventId = self.GetEventIdByTask(self, taskId)

	return self.GetTaskLineById(self, eventId)
end

M.GetEventIdByTask = function(self, taskId)
	local eventId = TaskToEventMap[taskId]

	return eventId ~= nil and 0 or eventId
end

M.GetTaskLineById = function(self, id)
	if not id or id ~= 0 then
		return nil
	end

	return TaskLineQuote[id]
end

M.IsEventContainTask = function(self, taskEvent, taskId)
	if taskEvent ~= nil or taskId ~= nil then
		return false
	end

	if type(taskEvent) ~= "number" then
		taskEvent = TaskLineQuote[taskEvent]
	end

	if taskEvent ~= nil then
		return false
	end

	if taskEvent.StartTask ~= taskId then
		return true
	end

	return table.contains(taskEvent.TaskList, taskId)
end

M.IsTaskEventUnlock = function(self, eventId)
	local events = gTaskManager.taskEvents

	if events[eventId] then
		return events[eventId].Acceptable
	end

	return false
end

M.IsTaskEventSubmit = function(self, eventId)
	local events = gTaskManager.taskSubmitEvents

	return events[eventId] or false
end

M.GetTaskTreeNowTask = function(self, nowTaskId, endTaskList)
	if self.IsEndTask(self, nowTaskId, endTaskList) then
		return nowTaskId
	end

	if gTaskManager:GetTaskState(nowTaskId) ~= TaskState.Accepted or gTaskManager:GetTaskState(nowTaskId) ~= TaskState.NotAccept then
		return nowTaskId
	else
		local taskList = self.GetNextsTaskList(self, nowTaskId)

		if #taskList ~= 1 and table.contains(taskList, nowTaskId) then
			return nowTaskId
		end

		for i = 1, #taskList do
			local mTaskId = taskList[i]

			if gTaskManager:GetTaskState(mTaskId) ~= TaskState.Submited then
				local taskId = self.GetTaskTreeNowTask(self, mTaskId, endTaskList)

				if taskId then
					return taskId
				end
			else
				return mTaskId
			end
		end
	end
end

M.GetEventNowDoTaskId = function(self, taskEventId)
	local cfg = TaskEventConfig.GetConfig(taskEventId)

	return self.GetTaskTreeNowTask(self, cfg.StartTask, cfg.EndTask)
end

M.GetEventDoTaskGps = function(self, taskEventId)
	local cfg = TaskEventConfig.GetConfig(taskEventId)

	if not cfg then
		print_error("未找到配置，taskEventId = " .. taskEventId)

		return
	end

	local doTaskId = self:GetTaskTreeNowTask(cfg.StartTask, cfg.EndTask)
	local curTaskInfo, taskTargetList, targetIndex = gTaskNodeManager:GetTaskCounterInfo(doTaskId)

	if curTaskInfo ~= nil then
		return
	end

	local targetPos, posRaidId = nil

	if targetPos ~= nil then
		targetPos = curTaskInfo.TargetPos
		posRaidId = curTaskInfo.RaidId
	end

	return targetPos, posRaidId
end

M.FindParentFirstCounterIndex = function(self, taskId)
	local cfg = gTaskManager:GetTaskConfigInfo(taskId)
	local taskInfo = gTaskManager:GetTaskInfo(taskId)

	if taskInfo then
		if #cfg.Counter ~= 0 then
			return 1
		else
			for i, v in ipairs(taskInfo.Counters) do
				if not v or v.Value >= v.ConfigValue then
					return i
				end
			end

			return #taskInfo.Counters
		end
	end
end

M.FindFirstCounterIndex = function(self, taskId)
	local cfg = gTaskManager:GetTaskConfigInfo(taskId)
	local taskInfo = gTaskManager:GetTaskInfo(taskId)

	if taskInfo then
		if #cfg.Counter ~= 0 then
			return 1
		else
			if taskInfo.Counters ~= nil then
				print_error("@buyifan, 看看哪个策划配的任务一个计数器都没有 taskInfo.Counters is nil or empty taskId = " .. taskId)

				return
			end

			for i, v in ipairs(taskInfo.Counters) do
				if not v or v.Value >= v.ConfigValue then
					return v.Index + 1
				end
			end

			return taskInfo.Counters[#taskInfo.Counters].Index + 1
		end
	end
end

M.FindFirstCounterIndexNotMyTask = function(self, taskInfo, cfg)
	if taskInfo then
		if #cfg.Counter ~= 0 then
			return 1
		else
			for i, v in ipairs(taskInfo.Counters) do
				if not v or v.Value >= v.ConfigValue then
					return v.Index + 1
				end
			end

			return taskInfo.Counters[#taskInfo.Counters].Index + 1
		end
	end
end

M.GetTaskWorkAction = function(self, taskId)
	local wa = gTaskManager:GetWorkActionInfo(taskId)

	if table.isNilOrEmpty(wa) or table.isNilOrEmpty(wa.WorkAction) then
		return {}
	end

	return wa.WorkAction
end

M.GetTaskWorkActionInfo = function(self, taskId, index)
	if index ~= nil then
		index = 1
	end

	local cfg = gTaskManager:GetTaskConfigInfo(taskId)
	local wa = gTaskManager:GetWorkActionInfo(taskId)
	local workActionList = self:GetTaskWorkAction(taskId)
	local workAction = workActionList[index]
	local taskValue = {
		TaskId = taskId,
		RaidId = cfg.RelatedRaid,
		ShowCounter = array.contains(cfg.Tags, TaskConfig.TagsType.ShowCounter) or array.contains(cfg.Tags, TaskConfig.TagsType.ShowAllCounter),
		isTaskSpoon = wa and wa.isTaskSpoon or false,
		ConfigData = cfg,
		EventObjective = cfg.EventObjective[index] or "",
		WorkDescription = cfg.EventObjective[index] or ""
	}

	if taskValue.isTaskSpoon and workAction then
		taskValue.isHideGps = workAction.IsHideGps or false
		taskValue.totalValue = wa and wa.WorkActionCount or workAction.CounterValue
		taskValue.TargetType = workAction.actionType
		taskValue.HideHintPillarRange = workAction.HideHintPillarRange
		taskValue.triggerPosition = Vector3.New(workAction.triggerPos.x, workAction.triggerPos.y, workAction.triggerPos.z)
		taskValue.Target = workAction.target
		taskValue.NpcId = workAction.NpcId or 0
		taskValue.SpiritAgentTag = workAction.SpiritAgentTag or 0
		taskValue.SlotPid = workAction.GadgetId or 0
		taskValue.SlotRefId = workAction.ButtonPosId or 0
		taskValue.TaskFeiSuoId = workAction.TaskFeiSuoId or 0
		taskValue.IsIgnoreGpsHeight = workAction.IsIgnoreGpsHeight
		taskValue.IsShowMapGuide = workAction.IsShowMapGuide
		taskValue.DontShowVehicleTrace = workAction.DontShowVehicleTrace
		taskValue.DontShowVehicleTraceOnGround = workAction.DontShowVehicleTraceOnGround
		taskValue.PreferMainRoadNavigation = workAction.PreferMainRoadNavigation
		taskValue.NpcHigh = workAction.NpcHigh or 0
		taskValue.HUDHpc = workAction.HUDHpc or 0
		taskValue.spiritWearFashionInfoList = workAction.spiritWearFashionInfoList
		taskValue.platformPartId = workAction.platformPartId or 0
		taskValue.platformId = workAction.platformId or 0
		taskValue.platformType = workAction.platformType or 0
		local isVecZero = workAction.targetPos and workAction.targetPos.x ~= 0 and workAction.targetPos.y ~= 0 and workAction.targetPos.z ~= 0

		if isVecZero then
			taskValue.TargetPos = nil
		else
			taskValue.TargetPos = workAction.targetPos and Vector3.New(workAction.targetPos.x, workAction.targetPos.y + taskValue.NpcHigh, workAction.targetPos.z)
		end

		taskValue.TargetEuler = workAction.targetEuler
		taskValue.actionType = workAction.actionType
		taskValue.TargetIconId = workAction.TargetIconId
		taskValue.IsGpsTargetItem = workAction.IsGpsTargetItem or false
		taskValue.TargetItemGpsIconId = workAction.TargetItemGpsIconId or 0
		taskValue.isHideDistance = workAction.IsHideMeter
		taskValue.TaskRange = workAction.MapRange or 0
		taskValue.gpsCustomAreas = workAction.gpsCustomAreas or {}
		taskValue.HideGpsRange = workAction.HideGpsRange or 0
		taskValue.HideGpsRangeGuideMeter = workAction.HideGpsRangeGuideMeter and workAction.HideGpsRangeGuideMeter <= 0 and workAction.HideGpsRangeGuideMeter or taskValue.HideGpsRange
		taskValue.TriggerRange = workAction.TriggerRange
		taskValue.LimitNotInDriving = workAction.LimitNotInDriving or false
		taskValue.IsOnFoot = workAction.IsOnFoot or false
		taskValue.SpecialTriggerRange = workAction.SpecialTriggerRange or 0
		taskValue.IndoorId = workAction.IndoorId or 0
		taskValue.RelatedTaskEvent = workAction.RelatedTaskEvent
		taskValue.VehicleGpsNode = workAction.VehicleGpsNode
		taskValue.VehicleId = workAction.VehicleId or 0
		taskValue.IsBranchTarget = workAction.IsBranchTarget
		taskValue.IsChasingVehicleOrUnit = workAction.IsChasingVehicleOrUnit
		taskValue.IsLeaveMapRange = workAction.IsLeaveMapRange
		taskValue.IgnoreIndoorPenetration = workAction.IgnoreIndoorPenetration
		taskValue.SubGpsInfoList = workAction.subGpsInfoList
		taskValue.HideDropInfo = workAction.HideDropInfo or false
		taskValue.specialAreaPoints = workAction.specialAreaPoints or {}
		taskValue.overrideTooltipInfo = workAction.OverrideTooltipInfo
		taskValue.SkillId = workAction.SkillId
		taskValue.MobileShowVx = workAction.MobileShowVx
		taskValue.hideBranch = workAction.hideBranch or false
		taskValue.NotShowProgress = workAction.NotShowProgress or false
		taskValue.RescueNotReach = workAction.RescueNotReach or false
		taskValue.SkipShowCounter = workAction.SkipShowCounter
		taskValue.ShowChildCounter = workAction.ShowChildCounter
		taskValue.ProgressData = workAction.ProgressData
		taskValue.ImplicitGpsTargetAgentTagList = workAction.ImplicitGpsTargetAgentTagList
		taskValue.DestructibleId = workAction.DestructibleId
		taskValue.BattleTrainingType = workAction.BattleTrainingType

		if workAction.useSpecificGpsGate then
			taskValue.preferredGateInfo = {
				gBoundId = workAction.specificLuaBoundId,
				localGateId = workAction.specificGpsGateLocalGateId
			}
		end

		if taskValue.TargetType ~= gTaskManager.ACTION_TYPE.NONE then
			if taskValue.ShowCounter then
				taskValue.totalValue = workAction.CounterValue
			else
				slot9 = taskValue.totalValue and taskValue.totalValue <= 0 and taskValue.totalValue - 1
				taskValue.totalValue = slot9
			end
		end

		if taskValue.RelatedTaskEvent and taskValue.RelatedTaskEvent <= 0 then
			if gTaskNodeManager:IsEventContainTask(taskValue.RelatedTaskEvent, taskId) then
				print_error("@dongkang02 当前任务配置错误，任务在关联RelatedTaskEvent中，任务id:" .. taskId .. "，RelatedTaskEvent:" .. taskValue.RelatedTaskEvent)

				return taskValue
			end

			local isTaskLineFinish = gTaskNodeManager:IsTaskLineFinish(taskValue.RelatedTaskEvent)

			if not isTaskLineFinish then
				local eventPos, eventRaidId = gTaskNodeManager:GetEventDoTaskGps(taskValue.RelatedTaskEvent)
				taskValue.TargetPos = eventPos or taskValue.TargetPos
				taskValue.RaidId = eventRaidId or taskValue.RaidId
			end
		end
	end

	return taskValue
end

M.GetTaskCounterInfo = function(self, taskId)
	local targetTable = {}
	local cfg = gTaskManager:GetTaskConfigInfo(taskId)
	local taskInfo = gTaskManager:GetTaskInfo(taskId)

	if not taskInfo then
		return
	end

	local nowCounterIndex = self:FindFirstCounterIndex(taskId)
	local workActionList = self:GetTaskWorkAction(taskId)
	local taskValue = self:GetTaskWorkActionInfo(taskId, nowCounterIndex)
	taskValue.CounterIndex = nowCounterIndex
	taskValue.Title = cfg.Title
	taskValue.CounterDesId = taskInfo.CounterDesId or 0
	taskValue.CounterValue = gTaskManager:GetTaskCounterValue(taskId, nowCounterIndex)
	local parentCounterIndex = self:FindParentFirstCounterIndex(taskId)

	if taskInfo.Counters then
		local childCounters = taskInfo.Counters[parentCounterIndex].Child

		if childCounters and #childCounters == 0 then
			taskValue.childCounterCnt = #childCounters
			taskValue.ChildCounterInfos = {}

			for i, v in ipairs(childCounters) do
				local childWorkActionInfo = self.GetTaskWorkActionInfo(self, taskId, v.Index + 1)

				if childWorkActionInfo then
					childWorkActionInfo.CounterIndex = v.Index + 1

					if childWorkActionInfo.ShowChildCounter and childWorkActionInfo.ProgressData.ProgressType ~= 1 then
						if not taskValue.ListenSpoonAgentId then
							taskValue.ListenSpoonAgentId = {}
						end

						table.insert(taskValue.ListenSpoonAgentId, childWorkActionInfo.ProgressData.SubCounterAgentId)
					end

					table.insert(taskValue.ChildCounterInfos, childWorkActionInfo)
				end
			end
		else
			taskValue.ListenSpoonAgentId = nil
		end
	end

	local index = 1

	for i = 1, #workActionList do
		if not taskInfo.Counters or not taskInfo.Counters[i] or not taskInfo.Counters[i].Value or taskInfo.Counters[i].Value >= cfg.Counter[i] then
			targetTable[index] = {}
			targetTable[index] = self.GetTaskWorkActionInfo(self, taskId, i)
			targetTable[index].CounterIndex = i
			index = index + 1
		end
	end

	return taskValue, targetTable, nowCounterIndex
end

M.CheckTaskIsTrueBranch = function(self, taskId)
	if not taskId or taskId ~= 0 then
		return false
	end

	local cfg = gTaskManager:GetTaskConfigInfo(taskId)

	if not cfg or not array.contains(cfg.Tags, TaskConfig.TagsType.TrueBranch) then
		return false
	end

	return true
end

M.IsTaskInCurrentMultiverse = function(self, taskId)
	if not taskId or taskId ~= 0 then
		return false
	end

	local taskCfg = TaskConfig.GetConfig(taskId)

	if not taskCfg or not taskCfg.RelatedRaid or taskCfg.RelatedRaid ~= 0 then
		return false
	end

	local raidCfg = RaidConfig.GetConfig(taskCfg.RelatedRaid)

	if not raidCfg then
		return false
	end

	local currentUniverseId = gMultiverseMgr and gMultiverseMgr.curVerseMetaId

	if not currentUniverseId or currentUniverseId ~= 0 then
		return false
	end

	if currentUniverseId ~= MultiverseMetaConfig.Online then
		return raidCfg.EnableOnline
	end

	return raidCfg.Multiverse ~= currentUniverseId
end

M.GetTakePhotosTaskByTaskList = function(self, currentRaidTaskList, name, isNpc)
	if not currentRaidTaskList or not name then
		return
	end

	local taskId = gCS.SpoonTaskMgr.Instance:GetTakePhotosTaskByTaskList(currentRaidTaskList, name)

	if taskId ~= 0 then
		return
	end

	return taskId
end

M.GetTaskCounter = function(self, taskId, counterIndex)
	local taskInfo = gTaskManager:GetTaskInfo(taskId)

	if taskInfo then
		return taskInfo.Counters[counterIndex].Value, gTaskManager:GetTaskConfigInfo(taskId).Counter[counterIndex]
	end
end

M.OnTaskSubmit = function(self, taskId)
	local cfg = TaskConfig.GetConfig(taskId)

	if not cfg then
		print_error("task not find! taskId = ", taskId)

		return
	end
end

M.OnTaskCounterChange = function(self, taskId, changedTaskCounterIndex)
	gGpsManager:TryRemoveMapGuideById(taskId)
end

M.OnTaskStateChange = function(self, taskId, taskState)
	if taskState == TaskState.Accepted then
		local cfg = TaskConfig.GetConfig(taskId)

		if cfg and cfg.Title ~= TaskTitle.Daily then
			gGpsManager:TryRemoveMapGuideById(taskId)

			return
		end
	end
end

M.NowDoingTaskContains = function(self, taskId)
	for _, v in pairs(gTaskNodeManager.NowDoingTask) do
		if v ~= taskId then
			return true
		end
	end

	return false
end

M.GetNowDoingTask = function(self)
	return gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1] or 0
end

M.IsHasNowDoingTask = function(self)
	return gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1] == nil
end

M.CheckCurTaskShowPause = function(self)
	local curTask = self:GetNowDoingTask()
	local taskConfig = TaskConfig.GetConfig(curTask)

	return taskConfig and array.contains(taskConfig.Tags, TaskConfig.TagsType.ShowPauseSidebar) or false
end

M.OpenMapByEventId = function(self, eventId)
	local taskId = self.GetEventNowDoTaskId(self, eventId)

	if taskId then
		local autoSelectGpsId = gMapSubSystem_Task:GetFirstGpsIdByTaskId(taskId)

		if autoSelectGpsId then
			gMapUtils:CheckRaidCanOpenMap({
				autoSelectGpsId = autoSelectGpsId
			})

			return true
		end
	end

	gMapUtils:CheckRaidCanOpenMap({
		["\\xa2\\xbf\\xa4e,\\xd77"] = 0,
		raidId = gSceneDataMgr.CurrentRaidId
	})

	return false
end

M.OpenMapByTaskType = function(self, targetTaskType, checkHasValidTaskOnly)
	local taskEvents = gTaskManager.taskEvents
	local validTaskGpsIdList = {}

	for eventId, v in pairs(taskEvents) do
		if v.Acceptable then
			local taskId = v.TaskId
			local taskCfg = LTConfig.TaskConfig.GetConfig(taskId)
			local taskType = taskCfg.Title

			if taskType ~= targetTaskType then
				local autoSelectGpsId = gMapSubSystem_Task:GetFirstGpsIdByTaskId(taskId)

				if autoSelectGpsId then
					table.insert(validTaskGpsIdList, autoSelectGpsId)
				end
			end
		end
	end

	if #validTaskGpsIdList <= 0 then
		local randomGpsId = validTaskGpsIdList[math.random(#validTaskGpsIdList)]

		if not checkHasValidTaskOnly then
			gMapUtils:CheckRaidCanOpenMap({
				autoSelectGpsId = randomGpsId
			})
		end

		return true
	end

	if not checkHasValidTaskOnly then
		gMapUtils:CheckRaidCanOpenMap({
			["\\xa2\\xbf\\xa4e,\\xd77"] = 0,
			raidId = gSceneDataMgr.CurrentRaidId
		})
	end

	return false
end

M.AskResetTask = function(self, taskId, callback)
	slot3 = gClientToGameDelegate

	slot3:AskDeleteTask(taskId, false).Callback = function (err)
		if err == MessageConfig.Ok then
			print_error("AskDeleteTask Aborted, err = ", gCS.Error.GetNameById(err))

			return
		end

		if callback then
			callback()
		end
	end
end

M.AskCancelChasing = function(self, taskId, callback)
	slot3 = gTaskManager

	slot3:RemoveCurrentTask(taskId, function ()
		if callback then
			callback()
		end
	end)
end

gTaskNodeManager = M
