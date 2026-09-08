-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PoliceTaskPanelStore.lua
-- Decompiled from: 00792_PoliceTaskPanelStore.lua_5c1040a8f4ea.luajit

C_PoliceTaskPanelStore = DefClass("C_PoliceTaskPanelStore", C_PoliceTaskPanelStore, C_StoreGroup)
GroupName2Class.PoliceTaskPanelStore = C_PoliceTaskPanelStore
local M = C_PoliceTaskPanelStore
local MessageConfig = LTConfig.MessageConfig
local UrbanJobJobClassConfig = LTConfig.UrbanJobJobClassConfig
local TextConfig = LTConfig.TextScriptTextConfig
local TaskState = {
	["i\\xa1\\xab\\xa1\\xb1"] = 2,
	["\\xee\\xda\t*\\xf6"] = 0,
	["_:|V"] = 4,
	["^0rK"] = 3,
	["\\xfa\\xda*\\xf6"] = 1
}
local PolicePanelState = {
	["gU\\xfc\\xb8\\x85\\x9d\\xc8\\xe5"] = 4,
	["i\\xa1\\xab\\xa1\\xb1"] = 1,
	["_:|V"] = 2,
	["\\xad13+w\\x8f@\\xcd>\\xa5\\xb7"] = 3,
	["Y#qW"] = 0
}
local policeTaskConfig = LTConfig.PolicePoliceMissionConfig
local factConfig = LTConfig.PoliceExamFactConfig
local urbanJobConfig = LTConfig.UrbanJobConfig
local PoliceConfig = LTConfig.PoliceConfig
local TaskShortCutConfig = LTConfig.TaskShortCutConfig
local TaskConfig = LTConfig.TaskConfig

M.ctor = function(self)
	self.curIconList = {}
	self.eventId = 0
	self.isUpdate = false

	if urbanJobConfig == nil then
		self.waitTime = urbanJobConfig.JobTaskForwardInfoTime == nil and urbanJobConfig.JobTaskForwardInfoTime or 20
	else
		self.waitTime = 20
	end

	self.pressTime = 1
	self.padPressTime = 0
	self.isPadPressingTaskBtn = false
	self.startPressTime = 0
	self.startPress = false
	self.startTime = 0
	self.curTaskId = 0
	self.isStartBar = false
	self.minProficiency = 0
	self.maxProficiency = 0
	self.duration = 3
	self.proportion = 0.5
	self.isNeedMid = false
	self.targetPoint = nil
	self.factLists = {}
	self.maxProgress = 100
	self.msgEvents = {
		[gEventConstants.POLICE_TASK_DISTRIBUTE] = self.CreateAction(self, self.PoliceStateToCalling),
		[gEventConstants.POLICE_DROP_EVENT] = self.CreateAction(self, self.PoliceDropPlane),
		[gEventConstants.POLICE_TASK_TO_WAIT] = self.CreateAction(self, self.ChangeToWaiting),
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self.CreateAction(self, self.ChangeBtnState),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, self.ChangeBtnState),
		[gEventConstants.POLICE_TASK_SHORTCUT_CHANGE] = self.CreateAction(self, self.OnTaskShortcutChange),
		[gEventConstants.CURRENT_TASK_CHANGE] = self.CreateAction(self, self.OnCurrentChange),
		[gEventConstants.POLICE_TASK_TO_DOING] = self.CreateAction(self, self.PoliceTaskRecover),
		[gEventConstants.POLICE_FACT_START] = self.CreateAction(self, self.TaskToExamState),
		[gEventConstants.FAKE_POLICE_PANEL_STATE_EVENT] = self.CreateAction(self, self.FakePolicePanelEvent),
		[gEventConstants.TASK_STATE_CHANGED] = self.CreateAction(self, self.TaskStateChange),
		[gEventConstants.POLICE_SYNC_MISSION_COUNT] = self.CreateAction(self, self.OnSyncMissionCount)
	}
end

M.OnDisable = function(self)
end

M.UpdatePanelHeight = function(self, state)
	self.height = gTaskUtils:GetMobileTaskPaneDefaultHeight(gTaskUtils.TaskGuideSubPanel.Police, state)

	gTaskUtils:SendMobileTaskPanelChange(self.height)
end

M.FakePolicePanelEvent = function(self, data)
	data = data or {
		state = PolicePanelState.Call
	}
	self.currentFakeStateData = data
	self.titleDes = PoliceConfig.FakeTaskName

	if data.state ~= PolicePanelState.Restoration then
		self.maxProgress = 100
		self.bindData.acceptBtn.luaClick = self.CreateAction(self, self.OnAcceptBtnClick)
		self.bindData.giveUpBtn.luaClick = self.CreateAction(self, self.OnGiveUpBtnClick)

		self.ChangeToWaiting(self)
		self.InitClickCallBack(self)
	elseif data.state ~= PolicePanelState.Call then
		self.bindData.acceptBtn.luaClick = self.CreateAction(self, self.OnFakeAcceptBtnClick)
		self.bindData.giveUpBtn.luaClick = self.CreateAction(self, self.OnFakeGiveUpBtnClick)

		self.FakeOpenCall(self)
		self.InitClickCallBack(self)
	elseif data.state ~= PolicePanelState.Doing then
		self.FakeOpenTask(self)
		self.InitClickCallBack(self)
	elseif data.state ~= PolicePanelState.Exam then
		self.maxProgress = 100
		self.factLists = {}

		self.FakeOpenExam(self, data.progress, data.isSubmit, data.isShow)
	elseif data.state ~= PolicePanelState.ToRealExam then
		self.factLists = {}
		self.bindData.examTaskName = PoliceConfig.FakeTaskName
		self.maxProgress = data.maxProgress or 100

		self:RefreshTaskInfo()
	end
end

M.OnFakeAcceptBtnClick = function(self)
	self.FakeOpenTask(self)
end

M.OnFakeGiveUpBtnClick = function(self)
	self.StartUpdate(self)
end

M.PoliceTaskRecover = function(self, _, data)
	self.InitPoliceData(self, data.id, data.eventId)
	self.ChangeToDoing(self, data.id, true)
end

M.TaskStateChange = function(self, _, data)
	local eventInfo = gTaskNodeManager:GetTaskLineByTask(data[1])

	if eventInfo and eventInfo.TaskLineId ~= self.eventId and self.curTaskType == policeTaskConfig.MissionTypeType.BattleCamp and data[2] ~= UX.Game.TaskState.Aborted then
		self.ChangeToWaiting(self)
	end
end

M.OnSyncMissionCount = function(self, eventId, data)
	local taskId = TaskConfig.PoliceHideTask
	self.currentSyncMissionInfo = data

	if gPoliceJobManager.isInHideTask and data.completeCntInHideTask and data.completeCntInHideTask > 0 then
		local taskInfo, _, _ = gTaskNodeManager:GetTaskCounterInfo(taskId)

		if taskInfo then
			local cfg = gTaskManager:GetTaskConfigInfo(taskId)
			local allCounterValue = cfg.Counter[1]
			self.bindData.waitingText = PoliceConfig.DispatchQuestTitle .. "[" .. data.completeCntInHideTask .. "/" .. allCounterValue .. "]"
		else
			self.bindData.waitingText = PoliceConfig.DispatchingTitle
		end
	elseif data.todayCompleteCnt and data.todayCompleteCnt == 0 and PoliceConfig.DailyTaskLimit < data.todayCompleteCnt then
		self.bindData.waitingText = PoliceConfig.DispatchLimitTitle
	else
		self.bindData.waitingText = PoliceConfig.DispatchingTitle
	end
end

M.OnCurrentChange = function(self, _, data)
	self.taskId = data.TaskId
	self.curTaskInfo = gTaskNodeManager:GetTaskCounterInfo(self.taskId)

	if not self.curTaskInfo then
		return
	end

	local isSameRaid = self.curTaskInfo.RaidId ~= gRaidDataManager.RaidId
	self.isInTaskRaid = isSameRaid and not gUIUtils:IsInOtherWorld()
	local cfg = gTaskManager:GetTaskConfigInfo(self.taskId)
	self.isShowTaskCounter = array.contains(cfg.Tags, TaskConfig.TagsType.ShowCounter) or self.curTaskInfo.ShowCounter

	self:RefreshCurrentTaskDes()
	self:RefreshExamProgress()
end

M.RefreshCurrentTaskDes = function(self)
	if not self.curTaskInfo then
		return
	end

	local des = gUtils:GetSpecialDescription(self.curTaskInfo.WorkDescription, true) or ""

	if self.isInTaskRaid then
		self.SwitchTaskInfo(self, des .. self.GetTaskCounter(self))
	else
		self:SwitchTaskInfo(self.curTaskInfo.EventObjective or "")
	end

	if gTaskManager:IsTaskInRiskControl(self.curTaskInfo.TaskId) then
		self.SwitchTaskInfo(self, LTConfig.TextScriptTextConfig.GetConfig(89900961).Text)
	end
end

M.GetTaskCounter = function(self)
	local taskInfo = self.curTaskInfo
	local taskCounter = ""

	if self.isShowTaskCounter and taskInfo then
		local nowCounterValue = taskInfo.CounterValue
		local allCounterValue = 0
		local cfg = gTaskManager:GetTaskConfigInfo(self.taskId)
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
			local tasks = gTaskManager:GetTaskInfo(self.taskId)

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

M.OnClickTaskBtn = function(self)
	if self.clickFunc then
		self.clickFunc()
	end
end

M.OnPressTaskBtn = function(self)
	if not self.gamepadMode then
		return
	end

	if self.clickFunc then
		self.clickFunc()
	end
end

M.ResetShortcut = function(self)
	self.clickFunc = self.defaultClickFunc
	local cfg = TextConfig.GetConfig(TextConfig.ShowPoliceApp)

	if cfg then
		self.bindData.taskBtnName = cfg.Text
	end
end

M.OnTaskShortcutChange = function(self, _, data)
	if data.reset then
		self.ResetShortcut(self)
	else
		local cfgId = data.cfgId
		local inputCfg = TaskShortCutConfig.GetConfig(cfgId)

		if inputCfg then
			self.bindData.taskBtnName = inputCfg.Name

			self.clickFunc = function()
				gDialogAction:RunCodeByTask(inputCfg.Action, self.taskId)
			end

			self.changeBtnNameFunc = function()
				local Id = data.cfgId
				local cfg = TaskShortCutConfig.GetConfig(Id)

				if cfg then
					self.bindData.taskBtnName = cfg.Name
				end
			end
		end
	end
end

M.CreateFakeSubmitButton = function(self, taskId)
	self.bindData.taskBtnName = PoliceConfig.ExamTaskFinishButton

	self.changeBtnNameFunc = function()
		self.bindData.taskBtnName = PoliceConfig.ExamTaskFinishButton
	end

	self.clickFunc = function()
		slot0 = gTaskManager

		slot0:ToSubmitTask(taskId, function ()
			self:ResetShortcut()
		end)
	end
end

M.CreateSubmitButton = function(self, taskId)
	self.bindData.taskBtnName = PoliceConfig.ExamTaskFinishButton

	self.changeBtnNameFunc = function()
		self.bindData.taskBtnName = PoliceConfig.ExamTaskFinishButton
	end

	self.clickFunc = function()
		slot0 = gTaskManager

		slot0:ToSubmitTask(taskId, function ()
			self:ResetShortcut()
			self:ChangeToDoing(self.curTaskId, false)
		end)
	end
end

M.CheckAppHomePanelState = function(self)
	if gPanelManager:IsPanelShowing(gPanelId.S_HALF_PHONE_APP_HOME_PANEL) or gPanelManager:IsPanelShowing(gPanelId.S_HALF_PHONE_APP_HOME_PANEL) then
		self.ChangeBtnState(self, gEventConstants.ON_PHONE_APP_HOME_SHOW)
	else
		self.ChangeBtnState(self, gEventConstants.ON_PHONE_APP_HOME_HIDE)
	end
end

M.ChangeBtnState = function(self, eventId)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		if self.gamepadMode then
			if eventId ~= gEventConstants.ON_PHONE_APP_HOME_SHOW then
				self.bindData.acceptBtn:SetActive(false)
				self.bindData.exitBtn:SetActive(false)
				self.bindData.giveUpBtn:SetActive(false)
				self.bindData.taskBtn:SetActive(false)
				self.bindData.exitWidget:SetActive(false)
			else
				self.bindData.acceptBtn:SetActive(true)
				self.bindData.exitBtn:SetActive(true)
				self.bindData.giveUpBtn:SetActive(true)
				self.bindData.taskBtn:SetActive(true)
				self.bindData.exitWidget:SetActive(true)
			end
		else
			self.bindData.acceptBtn:SetActive(true)
			self.bindData.exitBtn:SetActive(true)
			self.bindData.giveUpBtn:SetActive(true)
			self.bindData.taskBtn:SetActive(true)
			self.bindData.exitWidget:SetActive(true)
		end
	end
end

M.SwitchTaskInfo = function(self, data)
	self.bindData.detailedDescription = data
	self.bindData.examActionText = data
end

M.PoliceDropPlane = function(self, _, data)
	local spiritJob, jobId = self.GetJobExp(self)

	if spiritJob == nil and jobId == nil then
		local cfg = urbanJobConfig.GetConfig(jobId)

		if cfg == nil then
			self.bindData.jobName = cfg.Name
		end
	end

	local newState = TaskState.Drop

	if not gPoliceJobManager.isFakeTaskPanel then
		local config = self.GetPoliceConfig(self, self.curTaskId)

		if config == nil then
			self.bindData.state = newState

			self.UpdatePanelHeight(self, newState)

			self.bindData.endTitle = config.Title2
			self.bindData.starNumber = config.Rank - 1

			self.SetIconList(self, self.bindData.endIconList, config.Rank, config.MissionType)
		else
			return
		end
	elseif gPoliceJobManager.isFakeTaskPanel then
		self.bindData.state = newState

		self.UpdatePanelHeight(self, newState)

		self.bindData.endTitle = PoliceConfig.FakeTaskName
		self.bindData.endTaskTitle = PoliceConfig.FakeEventName

		self.SetIconList(self, self.bindData.endIconList, PoliceConfig.FakeTaskRank, PoliceConfig.FakeTaskType)
	end

	self:ClearData()

	self.startTime = gLogicTime.time

	Timer.New(function ()
		self.isStartBar = false

		if self.bindData.state ~= TaskState.Drop then
			if gPoliceJobManager.isFakeTaskPanel then
				gPoliceJobManager:StartFakeTask(gEventConstants.FAKE_POLICE_PANEL_STATE_EVENT, {
					["*9\\xe5x\\x9d\\xc35\\xbb$\\xd6\\xf3\\xe8q\\xf7"] = false,
					state = PolicePanelState.Restoration
				})
			else
				self:ChangeToWaiting()
			end
		end
	end, self.duration):Start()
end

M.ClearData = function(self)
	self.SwitchTaskType(self, false, "")

	self.curTaskId = 0
	self.eventId = 0
	self.curTaskType = nil
end

M.GetJobExp = function(self)
	local spiritJob, _ = gSpiritJobManager:GetAvailableJobByClass(UrbanJobJobClassConfig.Police)

	if spiritJob == nil then
		return spiritJob, spiritJob.Job
	end

	return nil, 
end

M.PoliceStateToCalling = function(self, _, data)
	local deltaTime = nil

	if data.selectTime then
		deltaTime = LTUtils.UXTime.GetNowUnixTime() - data.selectTime

		if self.waitTime >= deltaTime then
			return
		end
	end

	self.ChangeToCalling(self, data.id, data.eventId, deltaTime)
end

M.OnAwake = function(self)
	self.p = gStoreManager:GetStoreGroup("CoreHudTaskGuideStore")
	self.bindData.iconList.luaSimpleRenderItem = self:CreateAction(self.RenderIconItem)
	self.bindData.endIconList.luaSimpleRenderItem = self:CreateAction(self.RenderIconItem)
	self.bindData.acceptBtn.luaClick = self:CreateAction(self.OnAcceptBtnClick)
	self.bindData.giveUpBtn.luaClick = self:CreateAction(self.OnGiveUpBtnClick)
	self.bindData.taskBtn.luaClick = self:CreateAction(self.OnClickTaskBtn)
	self.bindData.violationBtn.luaClick = self:CreateAction(self.OnViolationBtnClick)
	self.bindData.resBtn.luaClick = self:CreateAction(self.OnViolationBtnClick)
	self.bindData.factList.luaSimpleRenderItem = self:CreateAction(self.FactListRender)
	self.duration = LTConfig.DropConfig.SpecialDropShowTime
	self.proportion = PoliceConfig.ExpIncreaseRatio
	self.duration = self.duration * self.proportion

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.taskBtn.luaLongPress = self.CreateAction(self, self.OnPressTaskBtn)
		self.bindData.exitBtn.luaBeginLongPress = self.CreateAction(self, self.OnPressBtnBegin)
		self.bindData.exitBtn.luaEndLongPress = self.CreateAction(self, self.OnPressBtnEnd)
	else
		self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnClickEnd)
		self.bindData.taskBtnAnother.luaClick = self.CreateAction(self, self.OnClickTaskBtn)
	end

	self:InitClickCallBack()

	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
end

M.InitClickCallBack = function(self)
	self.defaultClickFunc = function()
		gPoliceJobManager.panelMgr:OpenMainPanel()
	end

	self.clickFunc = self.defaultClickFunc
	local cfg = TextConfig.GetConfig(TextConfig.ShowPoliceApp)

	if cfg then
		self.bindData.taskBtnName = cfg.Text
	end

	self.changeBtnNameFunc = function()
		self.bindData.taskBtnName = TextConfig.GetConfig(TextConfig.ShowPoliceApp).Text
	end
end

M.OnEnable = function(self, data)
	if not gPoliceJobManager.panelIsRegister then
		gPoliceJobManager.panelIsRegister = true

		self.RegisterMessageEvents(self, self.msgEvents)
	end

	gPoliceJobManager:ExecuteCallback()
	self:UpdatePanelHeight(TaskState.Waiting)
end

M.OnClose = function(self)
end

M.OnDisable = function(self)
	if gPoliceJobManager.panelIsRegister then
		gPoliceJobManager.panelIsRegister = false

		self.ClearMessageEvents(self)
		self.ChangeToWaiting(self)
	end

	self.ClearData(self)
end

M.OnPressBtnBegin = function(self)
	if not self.bindData.exitBtn.interactable then
		return
	end

	self.bindData.longPress = 1
	self.startPress = true
	self.startPressTime = gLogicTime.time
end

M.OnPressBtnEnd = function(self)
	self.OnPressBtnEndHelper(self)
end

M.OnPressBtnEndHelper = function(self)
	self.startPress = false
	self.bindData.longPress = 0
end

M.FinishPoliceJob = function(self)
	if self.bindData.state ~= TaskState.Doing or self.bindData.state ~= TaskState.Exam then
		self.GiveUpTask(self)
	else
		slot1 = gTaskUtils

		slot1:CloseTaskGuideCurTab()

		slot1 = gClientToGameDelegate

		slot1:AskFinishJob().Callback = function (err)
			if err == MessageConfig.Ok then
				print_error("AskFinishJob Fail", err)
			end
		end
	end
end

M.GiveUpTask = function(self)
	if self.bindData.state ~= TaskState.Doing or self.bindData.state ~= TaskState.Exam then
		if self.taskId and self.taskId == 0 then
			slot1 = gTaskManager

			slot1:RemoveCurrentTask(self.taskId, function ()
				self.taskId = 0

				self:ChangeToWaiting()
			end)
		else
			slot1 = gClientToGameDelegate

			slot1:AskGiveUpPoliceTask().Callback = function (err)
				if err == MessageConfig.Ok then
					print_error("AskSkipPoliceTask Fail", err)

					return
				end

				self:SwitchTaskType(false, "")

				self.taskId = 0

				self:ChangeToWaiting()
			end
		end
	else
		self:SwitchTaskType(false, "")

		slot1 = gClientToGameDelegate

		slot1:AskSkipPoliceTask().Callback = function (err)
			if err == MessageConfig.Ok then
				print_error("AskAcceptPoliceTask Fail", err)

				return
			end

			self.curTaskId = 0

			self:ChangeToWaiting()
		end
	end
end

M.OnClickEnd = function(self)
	self.FinishPoliceJob(self)
end

M.OnAcceptBtnClick = function(self)
	slot1 = gClientToGameDelegate

	slot1:AskAcceptPoliceTask().Callback = function (err)
		if err ~= MessageConfig.Ok then
			self:ChangeToDoing(self.curTaskId)
		end
	end
end

M.OnGiveUpBtnClick = function(self)
	self.GiveUpTask(self)
end

M.GetPoliceConfig = function(self, taskId)
	local config = policeTaskConfig.GetConfig(taskId)

	if config ~= nil then
		print_warn("The ID does not exist in the configuration table policyTask, id is ", taskId)

		return nil
	end

	return config
end

M.ChangeToWaiting = function(self)
	self.isUpdate = false
	self.bindData.state = TaskState.Waiting

	self.UpdatePanelHeight(self, TaskState.Waiting)
	self.ResetShortcut(self)
end

M.StringSplit = function(self, inputStr, sep)
	if sep ~= nil then
		sep = "%s"
	end

	local t = {}
	local subStr = ""

	if inputStr == nil then
		for i = 1, #inputStr do
			local char = string.sub(inputStr, i, i)

			if char ~= sep then
				table.insert(t, subStr)

				subStr = ""
			else
				subStr = subStr .. char
			end
		end

		table.insert(t, subStr)
	end

	return t
end

M.FakeOpenCall = function(self)
	self.bindData.state = TaskState.Calling

	self.UpdatePanelHeight(self, TaskState.Calling)

	self.bindData.callTaskTile = PoliceConfig.FakeEventName
	self.curTaskType = PoliceConfig.FakeTaskType
	self.bindData.callTitle = PoliceConfig.FakeTaskName

	self.SetIconList(self, self.bindData.iconList, PoliceConfig.FakeTaskRank, PoliceConfig.FakeTaskType)

	self.targetPoint = Vector3.NewT(PoliceConfig.FakeTaskPos)

	self.StartUpdate(self)
end

M.InitPoliceData = function(self, taskId, eventId)
	local config = self.GetPoliceConfig(self, taskId)

	if config ~= nil then
		return
	end

	self.eventId = eventId
	self.bindData.callTaskTile = config.Title1
	self.bindData.starNumber = config.Rank - 1
	self.bindData.callTitle = config.Title2
	self.curTaskId = taskId

	self.SetIconList(self, self.bindData.iconList, config.Rank, config.MissionType)
	self.CalTargetPoint(self, config)
end

M.ChangeToCalling = function(self, taskId, eventId, costTime)
	self.bindData.state = TaskState.Calling

	self.UpdatePanelHeight(self, TaskState.Calling)
	self.InitPoliceData(self, taskId, eventId)
	self.StartUpdate(self, costTime)
end

M.CalTargetPoint = function(self, config)
	self.curTaskType = config.MissionType
	self.bindData.warnCtrl = self.curTaskType ~= policeTaskConfig.MissionTypeType.Special and 1 or 0

	if self.curTaskType ~= policeTaskConfig.MissionTypeType.BattleCamp then
		local battleCfg = LTConfig.BattleCampConfig.GetConfig(self.eventId)

		if battleCfg then
			local subQuestConfig = LTConfig.CollectionSubQuestConfig.GetConfig(battleCfg.SubQuestId)
			self.targetPoint = subQuestConfig == nil and Vector3.NewT(subQuestConfig.Coordinate) or Vector3.NewT({
				0,
				0,
				0
			})
		end
	elseif self.curTaskType ~= policeTaskConfig.MissionTypeType.BattleRandom then
		local eventConfig = LTConfig.TaskEventConfig.GetConfig(self.eventId)
		self.targetPoint = eventConfig == nil and Vector3.NewT(eventConfig.CenterPos) or Vector3.NewT({
			0,
			0,
			0
		})
	else
		self.targetPoint = Vector3.NewT(config.Pos)
	end
end

M.SetIconList = function(self, iconList, rank, missionType)
	self.curIconList = {}

	for i = 1, rank do
		table.insert(self.curIconList, {
			icon = PoliceConfig.MissonIcon[missionType + 1]
		})
	end

	iconList.SetSimpleList(iconList, #self.curIconList)
end

M.RenderIconItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.curIconList[index + 1]

	if store then
		store.icon = gUIUtils:GetSguiImagePath(data.icon)
	end
end

M.FakeOpenExam = function(self, progress, isSubmit, isShow)
	self.bindData.state = TaskState.Exam

	self:UpdatePanelHeight(TaskState.Exam)

	local factData = isShow and {
		{
			state = isSubmit and 1 or 0,
			factText = PoliceConfig.FakeTaskFact
		}
	} or {}
	self.factLists = factData
	self.bindData.examTaskName = PoliceConfig.FakeTaskName

	print_debug("FakeOpenExam", progress)

	self.bindData.examProgress = progress

	self.bindData.factList:SetSimpleList(#self.factLists)

	local taskId = gTaskManager:GetCurTask()

	if self.maxProgress < progress and taskId then
		self.CreateFakeSubmitButton(self, taskId)
	end
end

M.TaskToExamState = function(self, _, data)
	self.examTaskId = data.examTaskId
	self.examIndex = data.examIndex

	if data.examTaskId ~= 0 then
		return 0
	end

	self.bindData.state = TaskState.Exam

	self.UpdatePanelHeight(self, TaskState.Exam)

	local config = self.GetPoliceConfig(self, self.curTaskId)

	if config ~= nil then
		return
	end

	self.RefreshCurrentTaskDes(self)

	self.bindData.title = config.Title2
	self.titleDes = config.Title2

	for i, v in ipairs(self.factLists) do
		self.factLists[i].factText = factConfig.GetConfig(v.factId).Option
	end

	self.bindData.examTaskName = self.titleDes or ""

	if data.factIds then
		for i = 1, #data.factIds do
			self.ChangeFactState(self, data.factIds[i])
		end
	end

	self.bindData.factList:SetSimpleList(#self.factLists)
	print_debug("TaskToExamState", data.examTaskId)
	self:RefreshExamProgress()
end

M.RefreshExamProgress = function(self)
	if self.bindData.state == TaskState.Exam then
		return
	end

	if self.taskId == self.examTaskId then
		self.ResetShortcut(self)

		if gPoliceJobManager.isFakeTaskPanel then
			return
		end

		if self.curTaskId == 0 or self.examTaskId == 0 then
			self.ChangeToDoing(self, self.curTaskId, false)
		else
			self.ChangeToWaiting(self)
		end

		return
	end

	local taskInfo = gTaskManager:GetTaskInfo(self.examTaskId)

	print_debug("PoliceTaskPanelStore refreshExamProgress", self.examTaskId, self.examIndex)

	if taskInfo and taskInfo.Counters and taskInfo.Counters[self.examIndex + 1] then
		print_debug("PoliceTaskPanelStore refreshExamProgress Success")

		local counter = taskInfo.Counters[self.examIndex + 1]
		self.bindData.examProgress = math.floor(counter.Value / counter.ConfigValue * self.maxProgress)

		print_debug("[PoliceTaskPanelStore RefreshExamProgress]", self.examTaskId, counter.Value, counter.ConfigValue, self.maxProgress)

		if counter.ConfigValue < counter.Value then
			self.CreateSubmitButton(self, self.examTaskId)
		end
	end
end

M.ReSetFactList = function(self, factIds)
	local factData = {}

	if factIds then
		for i = 1, #factIds do
			local config = factConfig.GetConfig(factIds[i])

			if config then
				table.insert(factData, {
					["^\\xba\\xa3\\xbb\\xb3"] = 0,
					factId = factIds[i],
					factText = config.Option
				})
			end
		end
	end

	self.factLists = factData
end

M.ChangeFactState = function(self, factId)
	for _, v in pairs(self.factLists) do
		if v.factId ~= factId then
			v.state = 1

			break
		end
	end
end

M.FactListRender = function(self, btn, index)
	local data = self.factLists[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store and data then
		store.factText = data.factText
		store.finishState = data.state
	end
end

M.RefreshTaskInfo = function(self)
	local taskId = gTaskManager:GetCurTask()

	self:OnCurrentChange(_, {
		TaskId = taskId
	})
end

M.FakeOpenTask = function(self)
	self.RefreshTaskInfo(self)

	self.curTaskType = PoliceConfig.FakeTaskType

	self.PanelStateToDoingHelper(self, PoliceConfig.FakeTaskName, PoliceConfig.FakeTaskInfo, PoliceConfig.FakeTaskImage)
end

M.PanelStateToDoingHelper = function(self, titleDes, info, pic)
	self.bindData.state = TaskState.Doing

	self:UpdatePanelHeight(TaskState.Doing)

	self.isUpdate = false
	self.bindData.title = titleDes
	self.titleDes = titleDes
	local pAddStr = info
	local pAddStrList = self:StringSplit(pAddStr, "|")
	self.bindData.sexTitle = pAddStrList[1] or ""
	self.bindData.sexContent = pAddStrList[2] or ""
	self.bindData.heightTitle = pAddStrList[3] or ""
	self.bindData.heightContext = pAddStrList[4] or ""
	self.bindData.vehicleTitle = pAddStrList[5] or ""
	self.bindData.vehicleContext = pAddStrList[6] or ""
	local imageId = pic
	self.bindData.curImageUrl = gUIUtils:GetSguiImagePath(imageId)
end

M.ChangeToDoing = function(self, id, isRecover)
	local config = self.GetPoliceConfig(self, id)

	if config ~= nil then
		return
	end

	self:ReSetFactList(config.ExamFact)

	self.curTaskType = config.MissionType
	self.bindData.warnCtrl = self.curTaskType ~= policeTaskConfig.MissionTypeType.Special and 1 or 0

	self:SwitchTaskType(true, config.Des, isRecover)
	self:PanelStateToDoingHelper(config.Title2, config.Info3, config.Pic1)
end

M.SwitchTaskType = function(self, enable, Des, isRecover)
	if self.curTaskType ~= policeTaskConfig.MissionTypeType.BattleCamp then
		self.SwitchTaskInfo(self, Des)

		local battleCfg = LTConfig.BattleCampConfig.GetConfig(self.eventId)

		if battleCfg then
			if enable then
				gMapSubSystem_Camp:TryTraceAndLockAction(battleCfg.SubQuestId)
			else
				gMapSubSystem_Camp:TryUntraceAndUnlockAction(battleCfg.SubQuestId)
			end
		end
	elseif self.curTaskType ~= policeTaskConfig.MissionTypeType.BattleRandom then
		self.SwitchTaskInfo(self, Des)

		if enable then
			gMapSubSystem_RangeEvent:TryTraceRangeEvent(self.eventId)
		else
			gMapSubSystem_RangeEvent:TryUntraceRangeEvent(self.eventId)
		end
	elseif isRecover then
		local taskId = gTaskManager:GetCurTask()

		self:OnCurrentChange(_, {
			TaskId = taskId
		})
	end
end

M.StartUpdate = function(self, costTime)
	self.isUpdate = true

	if costTime then
		self.startTime = gLogicTime.time - costTime
	else
		self.startTime = gLogicTime.time
	end
end

M.OnUpdate = function(self)
	if self.isPadPressingTaskBtn then
		self.padPressTime = self.padPressTime + Time.deltaTime

		if self.gamepadMode then
			self.bindData.padPressFill = self.padPressTime
		end

		if self.padPressTime > 0.8 then
			self.padPressTime = 0
			self.isPadPressingTaskBtn = false

			if self.clickFunc then
				self.clickFunc()
			end
		end
	end

	if self.isUpdate then
		self.bindData.taskFill = 1 - (gLogicTime.time - self.startTime) / self.waitTime
		self.bindData.timeText = math.floor(self.waitTime - (gLogicTime.time - self.startTime))

		if self.waitTime >= gLogicTime.time - self.startTime then
			if not gPoliceJobManager.isFakeTaskPanel then
				self.GiveUpTask(self)

				self.isUpdate = false
			else
				self.FakeOpenCall(self)
			end
		end
	end

	if self.isStartBar then
		local nowTime = gLogicTime.time
		local fill = self.minProficiency + (nowTime - self.startTime) / self.duration * (self.maxProficiency - self.minProficiency)
		self.bindData.proficiencyFill = fill <= 1 and fill - 1 or fill

		if self.duration >= nowTime - self.startTime then
			self.isStartBar = false
		end
	end

	if self.startPress then
		local nowTime = gLogicTime.time
		self.bindData.exitFill = (nowTime - self.startPressTime) / self.pressTime

		if self.pressTime >= nowTime - self.startPressTime then
			self.OnPressBtnEndHelper(self)
			self.FinishPoliceJob(self)
		end
	end

	if self.bindData.state ~= TaskState.Calling and self.targetPoint == nil then
		local pos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
		pos.y = 0
		self.targetPoint.y = 0

		if pos == nil then
			self.bindData.distanceText = math.floor(Vector3.Distance(pos, self.targetPoint)) .. "m"
		end
	end
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnLanguageChange = function(self)
	self.curTaskInfo = gTaskNodeManager:GetTaskCounterInfo(self.taskId)

	self:CheckAppHomePanelState()

	if self.currentSyncMissionInfo then
		self.OnSyncMissionCount(self, nil, self.currentSyncMissionInfo)
	end

	if self.changeBtnNameFunc then
		self.changeBtnNameFunc()

		self.changeBtnNameFunc = nil
	else
		self.bindData.taskBtnName = TextConfig.GetConfig(TextConfig.ShowPoliceApp).Text
	end

	if gPoliceJobManager.isFakeTaskPanel then
		if self.currentFakeStateData then
			self.FakePolicePanelEvent(self, self.currentFakeStateData)
		end
	elseif self.bindData.state ~= TaskState.Doing then
		local config = self.GetPoliceConfig(self, self.curTaskId)

		if config ~= nil then
			return
		end

		self:RefreshCurrentTaskDes()

		self.bindData.title = config.Title2
		self.titleDes = config.Title2
		local pAddStr = config.Info3
		local pAddStrList = self:StringSplit(pAddStr, "|")
		self.bindData.sexTitle = pAddStrList[1] or ""
		self.bindData.sexContent = pAddStrList[2] or ""
		self.bindData.heightTitle = pAddStrList[3] or ""
		self.bindData.heightContext = pAddStrList[4] or ""
		self.bindData.vehicleTitle = pAddStrList[5] or ""
		self.bindData.vehicleContext = pAddStrList[6] or ""
	elseif self.bindData.state ~= TaskState.Calling then
		self.InitPoliceData(self, self.curTaskId, self.eventId)
	elseif self.bindData.state ~= TaskState.Waiting then
		local cfg = TextConfig.GetConfig(TextConfig.ShowPoliceApp)

		if cfg then
			self.bindData.taskBtnName = cfg.Text
		end
	elseif self.bindData.state ~= TaskState.Exam then
		local config = self.GetPoliceConfig(self, self.curTaskId)

		if config ~= nil then
			return
		end

		self.RefreshCurrentTaskDes(self)

		self.bindData.title = config.Title2
		self.titleDes = config.Title2

		for i, v in ipairs(self.factLists) do
			self.factLists[i].factText = factConfig.GetConfig(v.factId).Option
		end

		self.bindData.factList:SetSimpleList(#self.factLists)

		self.bindData.examTaskName = self.titleDes
	elseif self.bindData.state ~= TaskState.Drop then
		self.RefreshCurrentTaskDes(self)
		self.PoliceDropPlane(self)
	end
end

M.OnViolationBtnClick = function(self)
	gPoliceJobManager.panelMgr:OpenNoticePanel()
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device

	if not self.gamepadMode then
		self.bindData.padPressFill = 0
	end

	self.CheckAppHomePanelState(self)
end
