local FormulaUtils = nil
local TaskTipsType = require("LX6/Manager/Task/TaskTipsType")
local TaskTitle = require("LX6/Manager/Task/TaskTitle")
local DataSet = require("LX6/DataBind/DataSet")
local TaskFeiSuoModule = require("LX6/Manager/Task/TaskFeiSuoModule")
local NearTriggerModule = require("LX6/Manager/Task/NearTriggerModule")
local WorkActionModule = require("LX6/Manager/Task/WorkActionModule")
local TaskState = UX.Game.TaskState
local TaskEventState = UX.Game.TaskEventState
local TaskConfig = LTConfig.TaskConfig
local TaskTitleConfig = LTConfig.TaskTitleConfig
local MessageConfig = LTConfig.MessageConfig
local RaidConfig = LTConfig.RaidConfig
local ChangeCurrentTaskReason = UX.Game.ChangeCurrentTaskReason
local TaskEventConfig = LTConfig.TaskEventConfig
local TaskChapterConfig = LTConfig.TaskChapterConfig
local CollectionChallengeConfig = LTConfig.CollectionChallengeConfig
local CollectionSubQuestConfig = LTConfig.CollectionSubQuestConfig
local IndoorConfig = LTConfig.IndoorConfig
local AgentConfig = LTConfig.AgentConfig
local M = {
	ChallengeTaskUseTime = 0,
	taskDescChangedId = 0,
	showHud = true,
	changedTaskCounterIndex = -1,
	ChallengeTaskLeftTime = 0,
	isTaskDescChanged = false,
	curBranchIndex = -1,
	ForceHideFeiSuo = false,
	TaskScore = 0,
	tasks = {},
	taskEvents = {},
	eventInfos = {},
	taskSubmitEvents = {},
	submitTasks = {},
	acceptedTasks = {},
	dailyTask = {},
	collectionTask = {},
	allChallengeTasks = {},
	ChallengeTasks = {},
	TaskVolumeEffect = {},
	taskFeiSuo = DataSet.New({
		hasTaskFeiSuo = false
	}),
	CurrentTaskGps = {
		Npc = 3,
		Position = 1,
		Enemy = 2,
		None = 0
	},
	TaskState = {
		Finish = 2,
		Lose = 3,
		Wait = 4,
		Accept = 1
	},
	TaskColor = {},
	TaskEffectId = {},
	TaskIconId = {},
	TaskSIconId = {},
	TaskGuideEventIconId = {},
	ChallengeTargetType = {
		ScoreClient = 4,
		Rank = 2,
		TimeUp = 1,
		TimeDown = 0,
		ScoreTask = 3
	},
	ShowMessageTipsType = {
		TaskTitle.Main,
		TaskTitle.Branch,
		TaskTitle.TanLaboratory,
		TaskTitle.CHALLENGE
	},
	ShowSetTaskMessageTipsType = {
		TaskTitle.Daily,
		TaskTitle.Situational,
		TaskTitle.RandomEvent
	},
	CurrentTaskType = {
		Task1 = 0,
		Task2 = 1
	},
	closeTaskPanelWhenThisExists = {
		gPanelId.S_SEASON_GAMEPLAY_PANEL
	},
	m_Modules = {},
	_workActionCache = {}
}

function M:OnInit()
	self:InitData()
	gMessageManager:AddMessageListener(gEventConstants.TAKE_PHOTO, self.CheckTakePhotosTask)

	local modules = {
		TaskFeiSuo = TaskFeiSuoModule.new(),
		NearTrigger = NearTriggerModule.new(),
		WorkActions = WorkActionModule.new()
	}

	setmetatable(M, {
		__index = modules
	})

	for _, instance in pairs(modules) do
		instance:OnInit()
	end
end

function M:InitData()
	self:InitChallengeData()
	self:InitTaskIconId()

	self.redDot = {}
end

function M:InitTaskIconId()
	self.TaskIconId = {}
	self.TaskSIconId = {}
	self.TaskColor = {}
	self.TaskEffectId = {}

	for i = 0, LTConfig.TaskTitleConfig.count - 1 do
		local titleCfg = LTConfig.TaskTitleConfig.LoadAt(i)
		self.TaskIconId[titleCfg.Id] = 0
		self.TaskSIconId[titleCfg.Id] = titleCfg.SQuestIcon
		self.TaskColor[titleCfg.Id] = titleCfg.TaskColor
		self.TaskEffectId[titleCfg.Id] = titleCfg.TaskLight > 0 and titleCfg.TaskLight or 53610322
	end

	self.TaskGuideEventIconId = {}

	for i = 1, #TaskConfig.TaskGuideEventIcon do
		local taskIconInfo = TaskConfig.TaskGuideEventIcon[i]
		self.TaskGuideEventIconId[taskIconInfo.TitleId] = taskIconInfo.ImageId
	end
end

function M:InitCollectionTask()
	self.collectionTask = {}

	for i = 0, CollectionSubQuestConfig.count - 1 do
		local cfg = CollectionSubQuestConfig.LoadAt(i)

		if cfg.TaskId and cfg.TaskId > 0 then
			table.insert(self.collectionTask, cfg.TaskId)
		end
	end
end

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self.tasks = {}
		self.taskEvents = {}
		self.taskSubmitEvents = {}
		self.submitTasks = {}
		self.acceptedTasks = {}
		self.dailyTask = {}
		self.collectionTask = {}
		self.ChallengeTasks = {}
		self._workActionCache = {}
		gTaskNodeManager.NowDoingTask = {}
		self.changedTaskCounterIndex = -1
	end
end

function M:OnAfterSwitchScene()
	self:InitTaskIconId()
end

function M:CS_SyncAllTaskInfo()
	for _, task in pairs(self.tasks) do
		gMessageManager:SendMessage(gEventConstants.TASK_STATE_CHANGED, {
			task.TaskId,
			task.State,
			true
		})
	end

	for taskId, isSubmit in pairs(self.submitTasks) do
		if isSubmit then
			self:ClearRedDot(taskId)
			gMessageManager:SendMessage(gEventConstants.TASK_STATE_CHANGED, {
				taskId,
				TaskState.Submited,
				true
			})
		end
	end
end

function M:CS_SyncTaskInfo(taskId, taskState, taskStateChange, taskCounterChange, changedTaskCounterIndex)
	local cfg = self:GetTaskConfigInfo(taskId)

	if cfg == nil then
		return
	end

	local taskInfo = self.tasks[taskId]

	if taskInfo then
		taskInfo.config = cfg
	end

	if self.WorkActions then
		self.WorkActions:RefreshTaskCounterValues(taskId, taskState)
	end

	self.changedTaskCounterIndex = changedTaskCounterIndex

	if taskStateChange and taskState == TaskState.Accepted then
		if self.TaskFeiSuo then
			self.TaskFeiSuo:AddTaskStaticFeiSuoInfo(taskId)
		end

		local eventInfo = gTaskNodeManager:GetTaskLineByTask(taskId)

		if not table.isNilOrEmpty(eventInfo) and eventInfo.StartTask == taskId then
			local titleCfg = TaskTitleConfig.GetConfig(cfg.Title)
			local titleNoShow = false

			if titleCfg then
				titleNoShow = titleCfg.NoShowEventTip
			end

			if not titleNoShow then
				local eventTags = eventInfo.EventTag

				if not array.contains(eventTags, TaskEventConfig.EventTagType.NoShow) then
					if array.contains(eventTags, TaskEventConfig.EventTagType.ShowChapterStart) then
						local mainLabel = nil
						local eventChapter = eventInfo.Chapter

						if eventChapter and eventChapter ~= 0 then
							mainLabel = TaskChapterConfig.GetConfig(eventChapter).ChapterName

							gPanelManager:CheckShow(gPanelId.S_TASK_TIP_FULL_SCREEN_PANEL, {
								ShowType = 0,
								TaskStartMainLabel = mainLabel
							})
						else
							print_error("当前打了ShowChapterStart标签的event没有Chapter对应")
						end
					else
						self:ShowEventOpenOrCloseTips(eventInfo.Id, true, TaskTipsType.Event)
					end
				end
			end
		end
	elseif taskState ~= TaskState.Accepted and self.TaskFeiSuo then
		self.TaskFeiSuo:ClearTaskFeiSuo(taskId)
	end

	if taskCounterChange then
		gTaskNodeManager:OnTaskCounterChange(taskId, self.changedTaskCounterIndex)
	end

	if taskStateChange then
		gTaskNodeManager:OnTaskStateChange(taskId, taskState)
	end

	if taskStateChange and taskState == TaskState.Accepted and taskStateChange then
		gMessageManager:SendMessage(gEventConstants.TASK_ACCEPTED, taskId)
	end

	if taskState == TaskState.Submited then
		gTaskNodeManager:OnTaskSubmit(taskId)
		self:ClearRedDot(taskId)
	end

	gMessageManager:SendMessage(gEventConstants.TASK_STATE_CHANGED, {
		taskId,
		taskState,
		false,
		taskCounterChange
	})

	local currentTaskType = self:GetCurrentTaskType(taskId)

	if gTaskNodeManager.NowDoingTask[currentTaskType] == taskId and taskCounterChange then
		gMessageManager:SendMessage(gEventConstants.CURRENT_TASK_CHANGE, {
			TaskCounterChange = true,
			TaskId = taskId,
			CurrentTaskType = currentTaskType,
			changedCounterIndex = self.changedTaskCounterIndex
		})
	end

	if taskState == TaskState.Submited then
		local eventInfo = gTaskNodeManager:GetTaskLineByTask(taskId)

		if not table.isNilOrEmpty(eventInfo) and table.contains(eventInfo.EndTask, taskId) then
			local titleCfg = TaskTitleConfig.GetConfig(cfg.Title)
			local titleNoShow = false

			if titleCfg then
				titleNoShow = titleCfg.NoShowEventTip
			end

			if not titleNoShow then
				local eventTags = eventInfo.EventTag

				if not array.contains(eventTags, TaskEventConfig.EventTagType.NoShow) then
					if array.contains(eventTags, TaskEventConfig.EventTagType.ShowChapterEnd) then
						local mainLabel = nil
						local eventChapter = eventInfo.Chapter

						if eventChapter and eventChapter ~= 0 then
							mainLabel = TaskChapterConfig.GetConfig(eventChapter).ChapterName

							gPanelManager:CheckShow(gPanelId.S_TASK_TIP_FULL_SCREEN_PANEL, {
								ShowType = 2,
								TaskSubmitMainLabel = mainLabel
							})
						else
							print_error("当前打了ShowChapterEnd标签的event没有Chapter对应")
						end
					else
						self:ShowEventOpenOrCloseTips(eventInfo.Id, false, TaskTipsType.Event)
					end
				end
			end
		end
	end
end

function M:TryShowFailPanel(taskId, stateData, fromDead)
	local cfg = self:GetTaskConfigInfo(taskId)

	if cfg == nil then
		return
	end

	local failTextId = stateData.FailTextId
	local canSkip = stateData.CanSkip

	self:ShowFailPanel(taskId, cfg, failTextId, canSkip, fromDead)
end

function M:ShowFailPanel(taskId, cfg, failTextId, canSkip, fromDead)
	local secondLabel = nil

	if failTextId then
		local failTextCfg = LTConfig.TextConfig.GetConfig(failTextId)

		if failTextCfg then
			secondLabel = failTextCfg.Text
		end
	end

	if fromDead then
		gPanelManager:CheckShowSync(gPanelId.S_TASK_TIP_FULL_SCREEN_PANEL, {
			ShowType = 1,
			TaskId = taskId,
			TaskFailSecondLabel = secondLabel,
			OtherData = {
				CanSkip = canSkip
			}
		})

		return
	end

	if array.contains(cfg.Tags, TaskConfig.TagsType.FailPanelOn) then
		gPanelManager:CheckShowSync(gPanelId.S_TASK_TIP_FULL_SCREEN_PANEL, {
			ShowType = 1,
			TaskId = taskId,
			TaskFailSecondLabel = secondLabel,
			OtherData = {
				CanSkip = canSkip
			}
		})

		return
	elseif array.contains(cfg.Tags, TaskConfig.TagsType.FailPanelOff) then
		return
	else
		local eventInfo = gTaskNodeManager:GetTaskLineByTask(taskId)
		local eventTags = eventInfo.EventTag

		if array.contains(eventTags, TaskEventConfig.EventTagType.FailPanelOn) then
			gPanelManager:CheckShowSync(gPanelId.S_TASK_TIP_FULL_SCREEN_PANEL, {
				ShowType = 1,
				TaskId = taskId,
				TaskFailSecondLabel = secondLabel,
				OtherData = {
					CanSkip = canSkip
				}
			})

			return
		elseif array.contains(eventTags, TaskEventConfig.EventTagType.FailPanelOff) then
			return
		else
			local titleCfg = TaskTitleConfig.GetConfig(cfg.Title)
			local showFailPanel = titleCfg.ShowFailPanel

			if showFailPanel then
				gPanelManager:CheckShowSync(gPanelId.S_TASK_TIP_FULL_SCREEN_PANEL, {
					ShowType = 1,
					TaskId = taskId,
					TaskFailSecondLabel = secondLabel,
					OtherData = {
						CanSkip = canSkip
					}
				})
			end
		end
	end
end

function M:TryHandleCurrentTaskFeiSuo()
	if self.TaskFeiSuo then
		self.TaskFeiSuo:HandleCurrentTaskFeiSuo()
	end
end

function M:TryEnableTaskStaticFeiSuo(taskId, feisuoId, enable)
	if self.TaskFeiSuo then
		self.TaskFeiSuo:EnableTaskStaticFeiSuo(taskId, feisuoId, enable)
	end
end

function M:GetTaskConfigInfo(taskId)
	if taskId == nil or taskId == 0 then
		return
	end

	if self._workActionCache[taskId] and self._workActionCache[taskId].WorkAction then
		return self._workActionCache[taskId]
	end

	local cfg = TaskConfig.GetConfig(taskId)

	if cfg == nil then
		return
	end

	local temp = gCS.LuaUtils.GetSpoonTaskMgrWorkActionDic(taskId)
	temp = temp or {}

	setmetatable(temp, {
		__index = cfg
	})

	cfg = temp
	self._workActionCache[taskId] = cfg

	return cfg
end

function M:CS_SyncCurrentTask(currentTaskType, currentTaskId, eventId, isFirstTime, reason)
	if currentTaskId == 0 then
		self.changedTaskCounterIndex = 0
		gTaskNodeManager.NowDoingTask[currentTaskType] = nil
	else
		gTaskNodeManager.NowDoingTask[currentTaskType] = currentTaskId
	end

	gTaskNodeManager.NowDoingTaskLine[currentTaskType] = eventId

	if reason ~= ChangeCurrentTaskReason.TaskCounterAdd then
		gMessageManager:SendMessage(gEventConstants.CURRENT_TASK_CHANGE, {
			Reason = reason,
			TaskId = currentTaskId,
			CurrentTaskType = currentTaskType,
			IsFirstTime = isFirstTime,
			TaskCounterChange = reason == ChangeCurrentTaskReason.SubmitTask
		})
	end

	if currentTaskId ~= 0 and (reason == ChangeCurrentTaskReason.AcceptTask or reason == ChangeCurrentTaskReason.Gm or reason == ChangeCurrentTaskReason.LoginGameServer or reason == ChangeCurrentTaskReason.LoadComplete or reason == ChangeCurrentTaskReason.Client or reason == ChangeCurrentTaskReason.ForceSet) then
		gGpsManager:SwitchGpsShowMode(gGpsShowMode.ShowTaskMode)
	end
end

function M:ShowTaskChangePanel(oldCurrentId, newCurrentId)
	local taskLineInfo = gTaskNodeManager:GetTaskLineByTask(newCurrentId)

	if taskLineInfo then
		local eventTags = taskLineInfo.EventTag

		if not array.contains(eventTags, TaskEventConfig.EventTagType.NoChangePanel) then
			gPanelManager:CheckShowSync(gPanelId.S_TASK_CHANGE_FULL_SCREEN_PANEL, {
				taskId = newCurrentId
			})
			self:_WaitLoadSpoonResource(newCurrentId)
		end
	end
end

function M:_WaitLoadSpoonResource(taskId)
	if taskId then
		local waitLoadMaxTime = TaskConfig.WaitLoadMaxTime

		L18.Spoon.Task.TaskManager.Instance:WaitTaskResourceDependedLoadComplete(taskId, waitLoadMaxTime, function ()
			FrameTimer.New(function ()
				local ui = gStoreManager:GetStoreGroup("TaskChangedFullScreenStore")

				if ui then
					ui:CloseByAnim()
				end
			end, 5):Start()
		end)
	else
		FrameTimer.New(function ()
			local ui = gStoreManager:GetStoreGroup("TaskChangedFullScreenStore")

			if ui then
				ui:CloseByAnim()
			end
		end, 1):Start()
	end
end

function M:JumpToTaskListPanel(eventId)
	if eventId then
		gPanelManager:CheckShow(gPanelId.S_TASK_LIST, {
			eventId = eventId
		})
	end
end

function M:SyncTemporaryCurrentTask(taskId, eventId, reason)
	if not taskId then
		return
	end

	local cfg = TaskEventConfig.GetConfig(eventId)

	if not cfg then
		return
	end

	local data = {
		taskId = taskId,
		taskLineId = eventId,
		reason = reason
	}
	local eventInfo = self.taskEvents[eventId]

	if eventInfo and not eventInfo.IsUnderway then
		local taskName = cfg.EventName .. LTConfig.TextScriptTextConfig.GetConfig(89900945).Text

		self:ShowTaskTips(taskId, TaskTipsType.Task, self.TaskState.Wait, taskName)
	end

	gMessageManager:SendMessage(gEventConstants.TEMPORARY_CURRENT_TASK_CHANGE, data)
end

local function SetTaskList(dicSource, listNew, state, isInit)
	local tempDicNew = {}

	for i = 1, #listNew do
		local taskId = listNew[i]

		if TaskConfig.GetConfig(taskId) ~= nil then
			tempDicNew[taskId] = true
			M.tasks[taskId] = nil

			if not dicSource[taskId] then
				dicSource[taskId] = true

				gMessageManager:SendMessage(gEventConstants.TASK_STATE_CHANGED, {
					taskId,
					state,
					isInit
				})
			end
		end
	end

	local removeList = {}

	for k, _ in pairs(dicSource) do
		if not tempDicNew[k] then
			removeList[#removeList + 1] = k
		end
	end

	for i = 1, #removeList do
		local taskId = removeList[i]
		dicSource[taskId] = nil

		gMessageManager:SendMessage(gEventConstants.TASK_STATE_CHANGED, {
			taskId,
			TaskState.Aborted,
			isInit
		})
	end
end

function M:CS_SyncEventPanelView(eventId, becomeAcceptable)
	local eventInfo = self.taskEvents[eventId]

	if eventInfo then
		eventInfo.redPoint = eventInfo.RedPoint

		self:SetRedDot(eventInfo)
	else
		print_error("CS_SyncEventPanelView eventInfo is null")

		return
	end

	gMessageManager:SendMessage(gEventConstants.TASK_EVENT_CHANGE, eventInfo)
	gMessageManager:SendMessage(gEventConstants.SYNC_TASK_EVENT, {
		eventInfo = eventInfo,
		becomeAcceptable = becomeAcceptable
	})
	gMessageManager:SendMessage(gEventConstants.ON_EVENT_STATE_CHANGE, {
		eventId = eventInfo.EventId,
		state = self:GetTaskEventState(eventInfo.EventId)
	})
end

function M:CS_SyncDeleteEventPanelView(eventId, state)
	for i, eventInfo in pairs(self.taskEvents) do
		self:ClearRedDot(eventInfo.TaskId)
	end

	gMessageManager:SendMessage(gEventConstants.ON_EVENT_STATE_CHANGE, {
		eventId = eventId,
		state = state
	})
end

function M:CS_SyncPlayerAllEventPanel()
	for _, eventInfo in pairs(self.taskEvents) do
		eventInfo.redPoint = eventInfo.RedPoint

		self:SetRedDot(eventInfo)
	end

	for _, eventId in pairs(self.taskSubmitEvents) do
		gTaskNodeManager:GetTaskLineById(eventId)
	end
end

function M:AskGpsArriveTask(taskId, nowTargetIndex, isOnFoot, callback)
	gClientToGameDelegate:ActiveTaskCounter(taskId, nowTargetIndex, isOnFoot).Callback = function (err)
		if err == MessageConfig.Ok and callback then
			callback()
		end
	end
end

function M:IsCurrentTask(taskId)
	return taskId ~= 0 and table.contains(gTaskNodeManager.NowDoingTask, taskId)
end

function M:IsCouterChange(taskId, newCounters, oldCounters)
	local cfgCounter = self:GetTaskConfigInfo(taskId).Counter
	local changeIndex = -1

	if #newCounters == 0 then
		return false, changeIndex
	end

	local isChange = false

	if oldCounters then
		for i = 1, #oldCounters do
			if newCounters[i].Value ~= oldCounters[i].Value then
				isChange = true
				changeIndex = i
			end
		end
	else
		for i = 1, #cfgCounter do
			if newCounters[i].Value ~= cfgCounter[i] then
				isChange = true
				changeIndex = i
			end
		end
	end

	return isChange, changeIndex
end

function M:CheckTaskCounterFinished(taskId, counterIndex)
	counterIndex = counterIndex or 1
	local cfgCounter = self:GetTaskConfigInfo(taskId).Counter[counterIndex]
	local counterValue = self:GetTaskCounterValue(taskId, counterIndex)

	return cfgCounter <= counterValue
end

function M:ShowTaskTips(taskId, tipType, taskState, taskName, description, towerState)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_HUDTipsPanel, {
		Param = {
			taskId = taskId,
			TipType = tipType,
			taskState = taskState or 1,
			name = taskName,
			des = description,
			towerState = towerState
		}
	})
end

function M:ShowEventOpenOrCloseTips(eventId, isStart, tipType)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_HUDTipsPanel, {
		Param = {
			eventId = eventId,
			TipType = tipType,
			isStart = isStart
		}
	})
end

function M:GetTaskInfo(id)
	return self.tasks[id]
end

function M:GetTaskViewCounterValues(id)
	if self.WorkActions then
		return self.WorkActions.counterValues[id]
	end

	return nil
end

function M:GetTaskInfoIndoorId(taskInfo)
	if not taskInfo then
		return 0
	end

	if taskInfo.IndoorId and taskInfo.IndoorId > 0 then
		return taskInfo.IndoorId
	end

	if not taskInfo.RaidId then
		return 0
	end

	if taskInfo.RaidId <= 0 or taskInfo.RaidId == RaidConfig.WorldMap then
		return 0
	end

	for i = 0, IndoorConfig.count - 1 do
		local cfg = IndoorConfig.LoadAt(i)

		if cfg.SceneId == taskInfo.RaidId then
			return cfg.Id
		end
	end

	return 0
end

function M:GetTaskCounterValue(id, counterIndex)
	local task = self:GetTaskInfo(id)

	if task then
		if not task.CounterValues or #task.CounterValues <= 0 then
			return 0
		end

		return task.CounterValues[counterIndex] or 0
	else
		print_warn("GetTaskCounterValue no task:id=", id)

		return -1
	end
end

function M:GetTaskState(id)
	local taskInfo = self:GetTaskInfo(id)

	if taskInfo then
		return taskInfo.State
	elseif self.submitTasks[id] then
		return TaskState.Submited
	else
		return TaskState.NotAccept
	end
end

function M:GetTaskEventState(id)
	if self.taskSubmitEvents[id] then
		return TaskEventState.Submited
	end

	local taskInfo = self.taskEvents[id]

	if taskInfo then
		if taskInfo.HasAccepted then
			return TaskEventState.Accepted
		end

		if taskInfo.Acceptable then
			return TaskEventState.NotAccept
		end
	end

	return TaskEventState.Locked
end

function M:GetCurrentAcceptedMainTaskEvent()
	local titles = TaskConfig.AcceptTaskType

	for _, eventInfo in pairs(self.taskEvents) do
		if eventInfo.Acceptable and not eventInfo.HasAccepted then
			local startTask = eventInfo.TaskId
			local cfg = TaskConfig.GetConfig(startTask)

			if cfg then
				local title = cfg.Title

				if table.contains(titles, title) then
					return eventInfo
				end
			end
		end
	end

	return nil
end

function M:IsTaskSubmitted(id)
	local state = self:GetTaskState(id)

	if state == TaskState.Submited then
		return true
	end

	return false
end

function M:IsTaskWorking(id)
	local state = self:GetTaskState(id)

	if state == TaskState.Accepted then
		return true
	end

	return false
end

function M:CanShowPanel()
	for _, panelId in ipairs(self.closeTaskPanelWhenThisExists) do
		if gPanelManager:IsPanelShowing(panelId) then
			return false
		end
	end

	return true
end

function M:GetAllCurrentShowHudAcceptedTask()
	if table.isNilOrEmpty(self.tasks) then
		return {}
	end

	local tasks = {}

	for i, v in pairs(self.tasks) do
		if v.config == nil then
			v.config = TaskConfig.GetConfig(i)
		end

		local titleCfg = TaskTitleConfig.GetConfig(v.config.Title)

		if titleCfg.IsShowHud and gTaskManager:GetTaskState(i) == TaskState.Accepted then
			tasks[v.TaskId] = v
		end
	end

	return tasks
end

function M:GetAllAcceptedTask()
	return self.acceptedTasks
end

function M:GetAllReplayTaskEvents()
	local replayEvents = {}

	for eventId, _ in pairs(self.taskSubmitEvents) do
		local eventInfo = self.taskEvents[eventId]

		if eventInfo and not eventInfo.IsUnderway then
			local finishChoice = eventInfo.FinishedChoiceLs

			if not table.isNilOrEmpty(finishChoice) and finishChoice.Count > 0 then
				table.insert(replayEvents, eventInfo)
			end
		end
	end

	return replayEvents
end

function M:HasTask(id)
	local state = self:GetTaskState(id)

	return state > -1 or self.submitTasks[id]
end

function M.CheckTakePhotosTask(eventID, data)
	if data == nil or data.TaskId == nil then
		if gLuaUIMgr.matchAnglePhoto then
			gTaskManager:AskChangeTaskCounterValue(gLuaUIMgr.matchAngleTask, gTaskNodeManager:FindFirstCounterIndex(gLuaUIMgr.matchAngleTask))
		end

		return
	end

	local focusUnits = gLuaUIMgr.takePhotoFocusUnit[data.TaskId]

	if #focusUnits > 0 then
		for _, focusUnit in pairs(focusUnits) do
			local currentTask = M:GetTakePhotosTaskByUnit(focusUnit)

			if currentTask then
				gTaskManager:AskChangeTaskCounterValue(currentTask, gTaskNodeManager:FindFirstCounterIndex(currentTask))
			end
		end
	elseif gLuaUIMgr.matchAnglePhoto then
		gTaskManager:AskChangeTaskCounterValue(gLuaUIMgr.matchAngleTask, gTaskNodeManager:FindFirstCounterIndex(gLuaUIMgr.matchAngleTask))
	end
end

function M:GetTakePhotosTaskByName(name, isNpc)
	local currentRaidTaskList = gTaskNodeManager.TakePhotoTaskList[gRaidDataManager.RaidId]

	if not currentRaidTaskList then
		local defaultList = gTaskNodeManager.TakePhotoTaskList[0]

		if defaultList then
			return gTaskNodeManager:GetTakePhotosTaskByTaskList(defaultList, name, isNpc)
		end

		return
	end

	return gTaskNodeManager:GetTakePhotosTaskByTaskList(currentRaidTaskList, name, isNpc)
end

function M:GetTakePhotosTaskByUnit(currentUnit)
	local unit = currentUnit.cs_unit
	local isNpc = not unit.IsBattleAiS
	local unitRealName = nil
	local enemyId = unit.ClientData.SubType
	local agentConfig = AgentConfig.GetConfig(enemyId)

	if agentConfig then
		unitRealName = agentConfig.Name
	else
		print_warn("这个enemy配表找不到,策划检查下有没有问题 npcId = ", enemyId)
	end

	if unitRealName then
		return self:GetTakePhotosTaskByName(unitRealName, isNpc)
	end
end

function M:AskChangeTaskCounterValue(taskId, counterIndex, callback)
	if counterIndex == nil then
		return
	end

	gClientToGameDelegate:AskFinishTaskCounter(taskId, counterIndex - 1).Callback = function (err)
		if err == MessageConfig.Ok then
			if callback then
				callback()
			end
		else
			print_error("AskFinishHackChangeNameTaskCounter failed! err = ", err)
		end
	end
end

function M:GetCurrentTaskType(taskId)
	return gTaskManager.CurrentTaskType.Task1
end

function M:GetNowTaskIsRoleTeamTask()
	local taskId = gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1]
	local eventInfo = gTaskNodeManager:GetTaskLineByTask(taskId)

	if not eventInfo then
		return false
	end

	local eventId = eventInfo.TaskLineId
	local eventCfg = TaskEventConfig.GetConfig(eventId)
	local playRoleTeam = eventCfg.PlayRoleTeam

	return playRoleTeam and #playRoleTeam > 0
end

function M:ToSubmitTask(taskId, callback)
	if self:IsTaskWorking(taskId) then
		gClientToGameDelegate:AskSubmitTask(taskId).Callback = function (err)
			if err == MessageConfig.Ok then
				if callback then
					callback()
				end
			else
				print_error("AskSubmitTask Aborted, err = ", tostring(MessageConfig.GetConfig(err).Content), " taskId = ", taskId, " errorCode = ", err)

				local cfg = TaskConfig.GetConfig(taskId)

				if cfg == nil then
					print_error("AskSubmitTask Aborted, taskId invalid, taskId ", taskId)

					return
				end

				if array.contains(cfg.Tags, TaskConfig.TagsType.PlayControl) then
					local taskInfo = gTaskManager:GetTaskInfo(taskId)

					if taskInfo then
						local counter = ""

						for _, v in ipairs(taskInfo.Counters) do
							if not v then
								counter = counter .. tostring(v.Value) .. " " .. tostring(v.ConfigValue) .. ","
							end
						end

						print_error("AskSubmitTask Aborted, task not complete, taskId ", taskId, " counter ", counter)
					end

					return
				end
			end
		end
	end
end

function M:SetCurrentTask(taskId, successCb, failedCb, switchSpiritId)
	local cfg = TaskConfig.GetConfig(taskId)

	if not cfg then
		return
	end

	local function callBack()
		gClientToGameDelegate:AskAcceptAndSetCurrentTask(taskId, switchSpiritId or 0, true).Callback = function (err)
			if err == MessageConfig.Ok then
				if successCb then
					successCb()
				end

				gMessageManager:SendMessage(gEventConstants.ON_SET_CURRENT_TASK_SUCCESS)
			elseif failedCb then
				failedCb()
			end
		end
	end

	if taskId ~= 0 then
		local currentTaskType = self:GetCurrentTaskType(taskId)
		local curCfg = TaskConfig.GetConfig(gTaskNodeManager.NowDoingTask[currentTaskType])

		if curCfg then
			if table.contains(self.ShowMessageTipsType, curCfg.Title) and table.contains(self.ShowSetTaskMessageTipsType, cfg.Title) then
				gDisplayMessageMgr:ShowMessage(MessageConfig.ConfirmChangeCurrentTask, function ()
					callBack()
				end, nil)
			else
				callBack()
			end
		else
			callBack()
		end
	else
		callBack()
		print_error("请检测当前任务id是否设置正确,id=" .. taskId)
	end
end

function M:RemoveCurrentTask(taskId, successCb, failedCb)
	local cfg = TaskConfig.GetConfig(taskId)

	if not cfg then
		return
	end

	gClientToGameDelegate:RemoveCurrentTask(taskId).Callback = function (err)
		if err == MessageConfig.Ok then
			if successCb then
				successCb()
			end

			gMessageManager:SendMessage(gEventConstants.ON_REMOVE_CURRENT_TASK_SUCCESS)
		elseif failedCb then
			failedCb()
		end
	end
end

function M:ToGiveUpTask(taskId, successCb, failedCb)
	local isGiveup = false

	if not gTaskUtils:CanDoTask(taskId) then
		return isGiveup
	end

	gClientToGameDelegate:AskDeleteTask(taskId, false).Callback = function (err)
		if err ~= MessageConfig.Ok then
			print_error("AskDeleteTask Aborted, err = ", gCS.Error.GetNameById(err))

			if failedCb then
				failedCb()
			end
		else
			if successCb then
				successCb()
			end

			local cfg = TaskConfig.GetConfig(taskId)
			isGiveup = true
			local taskName = cfg.Name .. LTConfig.TextScriptTextConfig.GetConfig(89900758).Text

			if cfg.Title == TaskTitle.Daily or cfg.Title == TaskTitle.Situational then
				self:ShowTaskTips(taskId, TaskTipsType.Task, self.TaskState.Lose, taskName)
			elseif cfg.Title == TaskTitle.CHALLENGE then
				taskName = cfg.Name .. LTConfig.TextScriptTextConfig.GetConfig(89900759).Text

				self:ShowTaskTips(taskId, TaskTipsType.Task, self.TaskState.Lose, taskName)
			else
				self:ShowTaskTips(taskId, TaskTipsType.Task, self.TaskState.Lose, taskName)
			end
		end
	end

	return isGiveup
end

M.ACTION_TYPE = {
	LUA_ACTION = 4,
	WAYPOINT = 3,
	NPC = 1,
	POS = 2,
	NONE = 0
}

function M:GetTaskDistance(taskId, taskLineId)
	local taskEventInfo = self.taskEvents[taskLineId]

	if taskEventInfo and taskEventInfo.IsRiskControl then
		return LTConfig.TextScriptTextConfig.GetConfig(89900961).Text
	end

	local nowCounterIndex = gTaskNodeManager:FindFirstCounterIndex(taskId)
	local curTaskInfo = gTaskNodeManager:GetTaskWorkActionInfo(taskId, nowCounterIndex)

	if curTaskInfo == nil then
		print_error("没有找到任务信息 taskId = " .. taskId)

		return ""
	end

	if curTaskInfo.TaskRange ~= nil and curTaskInfo.TaskRange > 0 then
		print("curTaskInfo.TaskRange")
		print(curTaskInfo.TaskRange)

		return LTConfig.TextScriptTextConfig.GetConfig(89900934).Text
	end

	local gpsInstanceId = gMapSubSystem_Task:GetGpsInstanceIdByTaskId(taskId)

	if not gpsInstanceId then
		return ""
	end

	local taskCountry, taskBlockId, taskDistance = gMapSystem:GetGeographInfoByInstanceId(gpsInstanceId)
	local curCountry = gMapSystem:GetCurCountryId()

	if taskCountry ~= curCountry then
		local countryCfg = LTConfig.CollectionCountryConfig.GetConfig(taskCountry)

		if countryCfg then
			return countryCfg.Name
		end
	end

	local curBlockId = gMapSystem:GetCurBlockId()

	if curBlockId ~= taskBlockId then
		local blockCfg = LTConfig.CollectionBlockConfig.GetConfig(taskBlockId)

		if blockCfg then
			return blockCfg.BlockName
		end
	end

	if not taskDistance then
		return ""
	else
		local distanceText = string.format("%.0f", taskDistance) .. LTConfig.TextScriptTextConfig.GetConfig(89900693).Text

		return distanceText
	end
end

function M:InitChallengeData()
	self.allChallengeTasks = {}

	for i = 0, CollectionChallengeConfig.count - 1 do
		local cfg = CollectionChallengeConfig.LoadAt(i)

		if not table.isNilOrEmpty(cfg.RelatedTasks) then
			for i = 1, #cfg.RelatedTasks do
				self.allChallengeTasks[cfg.RelatedTasks[i]] = cfg
			end
		end
	end
end

function M:IsChallengeTask(taskId)
	if self.allChallengeTasks and self.allChallengeTasks[taskId] then
		return true
	end

	return false
end

function M:SetTaskCounterValue(taskId, counterIndex, value)
	if not self:IsTaskWorking(taskId) then
		return
	end

	gClientToGameDelegate:AskSetTaskCounterValue(taskId, counterIndex, value).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

function M:AddTaskCounterValue(taskId, counterIndex, value)
	if not self:IsTaskWorking(taskId) then
		return
	end

	gClientToGameDelegate:AskChangeTaskCounterValue(taskId, counterIndex, value).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

function M:IsSpoonEventAcceptable(eventId)
	if self.taskEvents[eventId] then
		return self.taskEvents[eventId].Acceptable
	end

	return false
end

function M:IsSpoonEventUnderway(eventId)
	if self.taskEvents[eventId] then
		return self.taskEvents[eventId].IsUnderway
	end

	return false
end

function M:IsTaskInRiskControl(taskId)
	for eventId, _ in pairs(self.taskEvents) do
		if self.taskEvents[eventId].TaskId == taskId then
			print("cslTmp-gTaskManager:IsTaskInRiskControl 当前检测的显性关闭任务的EventId：", eventId, " TaskId:", taskId, "是否显性关闭：", self.taskEvents[eventId].IsRiskControl)

			return self.taskEvents[eventId].IsRiskControl
		end
	end

	return false
end

function M:GetCounterValues(taskId)
	if not self.WorkActions.counterValues[taskId] then
		return nil
	end

	if #self.WorkActions.counterValues[taskId] == 0 then
		return nil
	end

	return self.WorkActions.counterValues[taskId]
end

function M:OpenHudTaskGuidePanel(enable)
	if enable then
		self.showHud = true

		gMessageManager:SendMessage(gEventConstants.ON_GM_CHANGE_TASK, true)
	else
		self.showHud = false

		gMessageManager:SendMessage(gEventConstants.ON_GM_CHANGE_TASK, false)
	end
end

function M:GetCurTask()
	return gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1] or 0
end

function M:ChallengeResult(taskID)
	local challengeTask = self.ChallengeTasks[taskID]
	local count = 0

	for i = 1, #challengeTask.cfg.ChallengeGoals do
		if challengeTask.cfg.TargetSource == self.ChallengeTargetType.TimeDown then
			count = self.ChallengeTaskUseTime
		elseif challengeTask.cfg.TargetSource == self.ChallengeTargetType.ScoreTask or challengeTask.cfg.TargetSource == self.ChallengeTargetType.ScoreClient then
			count = self.TaskScore
		elseif challengeTask.cfg.TargetSource == self.ChallengeTargetType.Rank then
			count = gLuaClient:GetMgr("RaceSpeedManager").speedRaceRank
		end
	end

	gClientToGameDelegate:SetChallengeResult(taskID, count, count).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			self.TaskScore = 0
			self.ChallengeTaskUseTime = 0
			self.ChallengeTaskLeftTime = 0
		else
			print_error("ChallengeResultAction:Start failed:", err)
		end
	end
end

function M:CS_ClearTable(t)
	table.clear(t)
end

function M:SetRedDot(taskInfo)
	local taskId = taskInfo.TaskId
	local eventId = taskInfo.EventId
	local taskState = self:GetTaskState(taskId)

	if taskState == TaskState.Submitted then
		self:ClearRedDot(taskId)

		return
	end

	local eventInfo = self.taskEvents[eventId]
	local taskLineCfg = TaskEventConfig.GetConfig(eventId)

	if not eventInfo or not taskLineCfg then
		return
	end

	local hasAccept = eventInfo.Acceptable and eventInfo.HasAccepted

	if not gTaskUtils:CanTaskShowInPanel(taskId, eventInfo.Visible, hasAccept, eventInfo.IsUnderway, taskLineCfg) then
		self:ClearRedDot(taskId)

		return
	end

	self.redDot[eventInfo.TaskId] = eventInfo.RedPoint and eventInfo.Acceptable

	gRedPointMgr:RegisterRedDot(self.redDot[eventInfo.TaskId], self:GetRedDot(eventInfo.TaskId))
end

function M:ClearRedDot(taskId)
	if not self.redDot[taskId] then
		return
	end

	self.redDot[taskId] = false

	gRedPointMgr:RegisterRedDot(false, self:GetRedDot(taskId))
end

function M:GetRedDot(taskId)
	local taskCfg = TaskConfig.GetConfig(taskId)

	if not taskCfg then
		return ""
	end

	local tabTypeCfg = TaskTitleConfig.GetConfig(taskCfg.Title)

	if not tabTypeCfg then
		return ""
	end

	return ("TaskList/TaskList.Tab:%d/TaskList:%d"):format(tabTypeCfg.TabType, taskId)
end

function M:AskCancelRedPoint(taskLineId)
	local eventInfo = self.taskEvents[taskLineId]

	if not eventInfo or not eventInfo.RedPoint then
		return
	end

	gClientToGameDelegate:ViewedEventPanel(taskLineId).Callback = function (err)
		if err == MessageConfig.Ok then
			if not self.taskEvents[taskLineId] then
				return
			end

			local eventInfo = self.taskEvents[taskLineId]
			self.taskEvents[taskLineId].RedPoint = false

			self:SetRedDot(eventInfo)
		end
	end
end

gTaskManager = M
