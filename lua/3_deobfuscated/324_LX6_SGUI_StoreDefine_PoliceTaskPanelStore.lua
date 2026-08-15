C_PoliceTaskPanelStore = DefClass("C_PoliceTaskPanelStore", C_PoliceTaskPanelStore, C_StoreGroup)
GroupName2Class.PoliceTaskPanelStore = C_PoliceTaskPanelStore
local M = C_PoliceTaskPanelStore
local MessageConfig = LTConfig.MessageConfig
local UrbanJobJobClassConfig = LTConfig.UrbanJobJobClassConfig
local TextConfig = LTConfig.TextScriptTextConfig
local TaskState = {
	Doing = 2,
	Waiting = 0,
	Exam = 4,
	Drop = 3,
	Calling = 1
}
local PolicePanelState = {
	ToRealExam = 4,
	Doing = 1,
	Exam = 2,
	Restoration = 3,
	Call = 0
}
local policeTaskConfig = LTConfig.PolicePoliceMissionConfig
local factConfig = LTConfig.PoliceExamFactConfig
local urbanJobConfig = LTConfig.UrbanJobConfig
local SguiImageConfig = LTConfig.SguiImageConfig
local PoliceConfig = LTConfig.PoliceConfig
local TaskShortCutConfig = LTConfig.TaskShortCutConfig
local TaskConfig = LTConfig.TaskConfig

function M:ctor()
	self.curIconList = {}
	self.eventId = 0
	self.isUpdate = false

	if urbanJobConfig ~= nil then
		self.waitTime = urbanJobConfig.JobTaskForwardInfoTime ~= nil and urbanJobConfig.JobTaskForwardInfoTime or 20
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
		[gEventConstants.POLICE_TASK_DISTRIBUTE] = self:CreateAction(self.PoliceStateToCalling),
		[gEventConstants.POLICE_DROP_EVENT] = self:CreateAction(self.PoliceDropPlane),
		[gEventConstants.POLICE_TASK_TO_WAIT] = self:CreateAction(self.ChangeToWaiting),
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self:CreateAction(self.ChangeBtnState),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self:CreateAction(self.ChangeBtnState),
		[gEventConstants.POLICE_TASK_SHORTCUT_CHANGE] = self:CreateAction(self.OnTaskShortcutChange),
		[gEventConstants.CURRENT_TASK_CHANGE] = self:CreateAction(self.OnCurrentChange),
		[gEventConstants.POLICE_TASK_TO_DOING] = self:CreateAction(self.PoliceTaskRecover),
		[gEventConstants.POLICE_FACT_START] = self:CreateAction(self.TaskToExamState),
		[gEventConstants.FAKE_POLICE_PANEL_STATE_EVENT] = self:CreateAction(self.FakePolicePanelEvent),
		[gEventConstants.TASK_STATE_CHANGED] = self:CreateAction(self.TaskStateChange)
	}
end

function M:OnDisable()
	gTaskUtils:SendMobileTaskPanelChange(0)
end

function M:UpdatePanelHeight(state)
	self.height = gTaskUtils:GetMobileTaskPaneDefaultHeight(gTaskUtils.TaskGuideSubPanel.Police, state)

	gTaskUtils:SendMobileTaskPanelChange(self.height)
end

function M:FakePolicePanelEvent(data)
	data = data or {
		state = PolicePanelState.Call
	}
	self.titleDes = PoliceConfig.FakeTaskName

	if data.state == PolicePanelState.Restoration then
		self.maxProgress = 100
		self.bindData.acceptBtn.luaClick = self:CreateAction(self.OnAcceptBtnClick)
		self.bindData.giveUpBtn.luaClick = self:CreateAction(self.OnGiveUpBtnClick)

		self:ChangeToWaiting()
		self:InitClickCallBack()
	elseif data.state == PolicePanelState.Call then
		self.bindData.acceptBtn.luaClick = self:CreateAction(self.OnFakeAcceptBtnClick)
		self.bindData.giveUpBtn.luaClick = self:CreateAction(self.OnFakeGiveUpBtnClick)

		self:FakeOpenCall()
		self:InitClickCallBack()
	elseif data.state == PolicePanelState.Doing then
		self:FakeOpenTask()
		self:InitClickCallBack()
	elseif data.state == PolicePanelState.Exam then
		self.maxProgress = 100
		self.factLists = {}

		self:FakeOpenExam(data.progress, data.isSubmit, data.isShow)
	elseif data.state == PolicePanelState.ToRealExam then
		self.factLists = {}
		self.bindData.examTaskName = PoliceConfig.FakeTaskName
		self.maxProgress = data.maxProgress or 100

		self:RefreshTaskInfo()
	end
end

function M:OnFakeAcceptBtnClick()
	self:FakeOpenTask()
end

function M:OnFakeGiveUpBtnClick()
	self:StartUpdate()
end

function M:PoliceTaskRecover(_, data)
	self:InitPoliceData(data.id, data.eventId)
	self:ChangeToDoing(data.id, true)
end

function M:TaskStateChange(_, data)
	local eventInfo = gTaskNodeManager:GetTaskLineByTask(data[1])

	if eventInfo and eventInfo.TaskLineId == self.eventId and self.curTaskType ~= policeTaskConfig.MissionTypeType.BattleCamp and data[2] == UX.Game.TaskState.Aborted then
		self:ChangeToWaiting()
	end
end

function M:OnCurrentChange(_, data)
	self.taskId = data.TaskId
	self.curTaskInfo = gTaskNodeManager:GetTaskCounterInfo(self.taskId)

	if not self.curTaskInfo then
		return
	end

	local isSameRaid = self.curTaskInfo.RaidId == gRaidDataManager.RaidId
	self.isInTaskRaid = isSameRaid and not gUIUtils:IsInOtherWorld()
	local cfg = gTaskManager:GetTaskConfigInfo(self.taskId)
	self.isShowTaskCounter = array.contains(cfg.Tags, TaskConfig.TagsType.ShowCounter) or self.curTaskInfo.ShowCounter

	self:RefreshCurrentTaskDes()
	self:RefreshExamProgress()
end

function M:RefreshCurrentTaskDes()
	if not self.curTaskInfo then
		return
	end

	local des = gUtils:GetSpecialDescription(self.curTaskInfo.WorkDescription, true) or ""

	if self.isInTaskRaid then
		self:SwitchTaskInfo(des .. self:GetTaskCounter())
	else
		self:SwitchTaskInfo(self.curTaskInfo.EventObjective or "")
	end

	if gTaskManager:IsTaskInRiskControl(self.curTaskInfo.TaskId) then
		self:SwitchTaskInfo(LTConfig.TextScriptTextConfig.GetConfig(89900961).Text)
	end
end

function M:GetTaskCounter()
	local taskInfo = self.curTaskInfo
	local taskCounter = ""

	if self.isShowTaskCounter and taskInfo then
		local nowCounterValue = taskInfo.CounterValue
		local allCounterValue = 0
		local cfg = gTaskManager:GetTaskConfigInfo(self.taskId)
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
			local tasks = gTaskManager:GetTaskInfo(self.taskId)

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

function M:OnClickTaskBtn()
	if self.gamepadMode then
		return
	end

	if self.clickFunc then
		self.clickFunc()
	end
end

function M:OnPressTaskBtn()
	if not self.gamepadMode then
		return
	end

	if self.clickFunc then
		self.clickFunc()
	end
end

function M:ResetShortcut()
	self.clickFunc = self.defaultClickFunc
	self.bindData.taskBtnName = self.taskBtnName
end

function M:OnTaskShortcutChange(_, data)
	if data.reset then
		self:ResetShortcut()
	else
		local cfgId = data.cfgId
		local inputCfg = TaskShortCutConfig.GetConfig(cfgId)

		if inputCfg then
			self.bindData.taskBtnName = inputCfg.Name

			function self.clickFunc()
				gDialogAction:RunCodeByTask(inputCfg.Action, self.taskId)
			end
		end
	end
end

function M:CreateFakeSubmitButton(taskId)
	self.bindData.taskBtnName = PoliceConfig.ExamTaskFinishButton

	function self.clickFunc()
		gTaskManager:ToSubmitTask(taskId, function ()
			self:ResetShortcut()
		end)
	end
end

function M:CreateSubmitButton(taskId)
	self.bindData.taskBtnName = PoliceConfig.ExamTaskFinishButton

	function self.clickFunc()
		gTaskManager:ToSubmitTask(taskId, function ()
			self:ResetShortcut()
			self:ChangeToDoing(self.curTaskId, false)
		end)
	end
end

function M:CheckAppHomePanelState()
	if gPanelManager:IsPanelShowing(gPanelId.S_PHONE_APP_HOME_PANEL) or gPanelManager:IsPanelShowing(gPanelId.S_HALF_PHONE_APP_HOME_PANEL) then
		self:ChangeBtnState(gEventConstants.ON_PHONE_APP_HOME_SHOW)
	else
		self:ChangeBtnState(gEventConstants.ON_PHONE_APP_HOME_HIDE)
	end
end

function M:ChangeBtnState(eventId)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		if self.gamepadMode then
			if eventId == gEventConstants.ON_PHONE_APP_HOME_SHOW then
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

function M:SwitchTaskInfo(data)
	self.bindData.detailedDescription = data
	self.bindData.examActionText = data
end

function M:PoliceDropPlane(_, data)
	local spiritJob, jobId = self:GetJobExp()

	if spiritJob ~= nil and jobId ~= nil then
		local cfg = urbanJobConfig.GetConfig(jobId)

		if cfg ~= nil then
			self.bindData.jobName = cfg.Name
		end
	end

	local newState = TaskState.Drop

	if not gPoliceJobManager.isFakeTaskPanel then
		local config = self:GetPoliceConfig(self.curTaskId)

		if config ~= nil then
			self.bindData.state = newState

			self:UpdatePanelHeight(newState)

			self.bindData.endTitle = config.Title2
			self.bindData.starNumber = config.Rank - 1

			self:SetIconList(self.bindData.endIconList, config.Rank, config.MissionType)
		else
			return
		end
	elseif gPoliceJobManager.isFakeTaskPanel then
		self.bindData.state = newState

		self:UpdatePanelHeight(newState)

		self.bindData.endTitle = PoliceConfig.FakeTaskName
		self.bindData.endTaskTitle = PoliceConfig.FakeEventName

		self:SetIconList(self.bindData.endIconList, PoliceConfig.FakeTaskRank, PoliceConfig.FakeTaskType)
	end

	self:ClearData()

	self.startTime = gLogicTime.time

	Timer.New(function ()
		self.isStartBar = false

		if self.bindData.state == TaskState.Drop then
			if gPoliceJobManager.isFakeTaskPanel then
				gPoliceJobManager:StartFakeTask(gEventConstants.FAKE_POLICE_PANEL_STATE_EVENT, {
					isFakeTaskPanel = false,
					state = PolicePanelState.Restoration
				})
			else
				self:ChangeToWaiting()
			end
		end
	end, self.duration):Start()
end

function M:ClearData()
	self:SwitchTaskType(false, "")

	self.curTaskId = 0
	self.eventId = 0
	self.curTaskType = nil
end

function M:GetJobExp()
	local spiritJob, _ = gSpiritJobManager:GetAvailableJobByClass(UrbanJobJobClassConfig.Police)

	if spiritJob ~= nil then
		return spiritJob, spiritJob.Job
	end

	return nil, nil
end

function M:PoliceStateToCalling(_, data)
	self:ChangeToCalling(data.id, data.eventId)
end

function M:OnAwake()
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
		self.bindData.taskBtn.luaLongPress = self:CreateAction(self.OnPressTaskBtn)
		self.bindData.exitBtn.luaBeginLongPress = self:CreateAction(self.OnPressBtnBegin)
		self.bindData.exitBtn.luaEndLongPress = self:CreateAction(self.OnPressBtnEnd)
	else
		self.bindData.exitBtn.luaClick = self:CreateAction(self.OnClickEnd)
	end

	self:InitClickCallBack()

	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
end

function M:InitClickCallBack()
	function self.defaultClickFunc()
		gPoliceJobManager.panelMgr:OpenMainPanel()
	end

	self.clickFunc = self.defaultClickFunc
	local cfg = TextConfig.GetConfig(TextConfig.ShowPoliceApp)

	if cfg then
		self.taskBtnName = cfg.Text
		self.bindData.taskBtnName = self.taskBtnName
	end
end

function M:OnShow(data)
	if not gPoliceJobManager.panelIsRegister then
		gPoliceJobManager.panelIsRegister = true

		self:RegisterMessageEvents(self.msgEvents)
	end

	gPoliceJobManager:ExecuteCallback()
	self:UpdatePanelHeight(TaskState.Waiting)
end

function M:OnClose()
	return
end

function M:OnDisable()
	if gPoliceJobManager.panelIsRegister then
		gPoliceJobManager.panelIsRegister = false

		self:ClearMessageEvents()
		self:ChangeToWaiting()
	end

	self:ClearData()
end

function M:OnPressBtnBegin()
	if not self.bindData.exitBtn.interactable then
		return
	end

	self.bindData.longPress = 1
	self.startPress = true
	self.startPressTime = gLogicTime.time
end

function M:OnPressBtnEnd()
	self:OnPressBtnEndHelper()
end

function M:OnPressBtnEndHelper()
	self.startPress = false
	self.bindData.longPress = 0
end

function M:FinishPoliceJob()
	if self.bindData.state == TaskState.Doing or self.bindData.state == TaskState.Exam then
		self:GiveUpTask()
	else
		gTaskUtils:CloseTaskGuideCurTab()

		gClientToGameDelegate:AskFinishJob().Callback = function (err)
			if err ~= MessageConfig.Ok then
				print_error("AskFinishJob Fail", err)
			end
		end
	end
end

function M:GiveUpTask()
	if self.taskId and self.taskId ~= 0 then
		gTaskManager:RemoveCurrentTask(self.taskId, function ()
			self.taskId = 0

			self:ChangeToWaiting()
		end)
	else
		self:SwitchTaskType(false, "")

		gClientToGameDelegate:AskSkipPoliceTask().Callback = function (err)
			if err ~= MessageConfig.Ok then
				print_error("AskAcceptPoliceTask Fail", err)

				return
			end

			self.curTaskId = 0

			self:ChangeToWaiting()
		end
	end
end

function M:OnClickEnd()
	self:FinishPoliceJob()
end

function M:OnAcceptBtnClick()
	gClientToGameDelegate:AskAcceptPoliceTask().Callback = function (err)
		if err == MessageConfig.Ok then
			self:ChangeToDoing(self.curTaskId)
		end
	end
end

function M:OnGiveUpBtnClick()
	self:GiveUpTask()
end

function M:GetPoliceConfig(taskId)
	local config = policeTaskConfig.GetConfig(taskId)

	if config == nil then
		print_warn("The ID does not exist in the configuration table policyTask, id is ", taskId)

		return nil
	end

	return config
end

function M:ChangeToWaiting()
	self.isUpdate = false
	self.bindData.state = TaskState.Waiting

	self:UpdatePanelHeight(TaskState.Waiting)
	self:ResetShortcut()
end

function M:StringSplit(inputStr, sep)
	if sep == nil then
		sep = "%s"
	end

	local t = {}
	local subStr = ""

	if inputStr ~= nil then
		for i = 1, #inputStr do
			local char = string.sub(inputStr, i, i)

			if char == sep then
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

function M:FakeOpenCall()
	self.bindData.state = TaskState.Calling

	self:UpdatePanelHeight(TaskState.Calling)

	self.bindData.callTaskTile = PoliceConfig.FakeEventName
	self.curTaskType = PoliceConfig.FakeTaskType
	self.bindData.callTitle = PoliceConfig.FakeTaskName

	self:SetIconList(self.bindData.iconList, PoliceConfig.FakeTaskRank, PoliceConfig.FakeTaskType)

	self.targetPoint = Vector3.NewT(PoliceConfig.FakeTaskPos)

	self:StartUpdate()
end

function M:InitPoliceData(taskId, eventId)
	gCoroutineManager:StartCoroutine(function ()
		while gLuaDataManager.gameStage ~= gGFConstant.GameStage.GameScene do
			coroutine.yield(nil)
		end

		local config = self:GetPoliceConfig(taskId)

		if config == nil then
			return
		end

		self.eventId = eventId
		self.bindData.callTaskTile = config.Title1
		self.bindData.starNumber = config.Rank - 1
		self.bindData.callTitle = config.Title2
		self.curTaskId = taskId

		self:SetIconList(self.bindData.iconList, config.Rank, config.MissionType)
		self:CalTargetPoint(config)
	end)
end

function M:ChangeToCalling(taskId, eventId)
	self.bindData.state = TaskState.Calling

	self:UpdatePanelHeight(TaskState.Calling)
	self:InitPoliceData(taskId, eventId)
	self:StartUpdate()
end

function M:CalTargetPoint(config)
	self.curTaskType = config.MissionType

	if self.curTaskType == policeTaskConfig.MissionTypeType.BattleCamp then
		local battleCfg = LTConfig.BattleCampConfig.GetConfig(self.eventId)

		if battleCfg then
			local subQuestConfig = LTConfig.CollectionSubQuestConfig.GetConfig(battleCfg.SubQuestId)
			self.targetPoint = subQuestConfig ~= nil and Vector3.NewT(subQuestConfig.Coordinate) or Vector3.NewT({
				0,
				0,
				0
			})
		end
	elseif self.curTaskType == policeTaskConfig.MissionTypeType.BattleRandom then
		local eventConfig = LTConfig.TaskEventConfig.GetConfig(self.eventId)
		self.targetPoint = eventConfig ~= nil and Vector3.NewT(eventConfig.CenterPos) or Vector3.NewT({
			0,
			0,
			0
		})
	else
		self.targetPoint = Vector3.NewT(config.Pos)
	end
end

function M:SetIconList(iconList, rank, missionType)
	self.curIconList = {}

	for i = 1, rank do
		table.insert(self.curIconList, {
			icon = PoliceConfig.MissonIcon[missionType + 1]
		})
	end

	iconList:SetSimpleList(#self.curIconList)
end

function M:RenderIconItem(btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.curIconList[index + 1]

	if store then
		local imageCfg = SguiImageConfig.GetConfig(data.icon)

		if imageCfg then
			store.icon = imageCfg.ImgPath
		end
	end
end

function M:FakeOpenExam(progress, isSubmit, isShow)
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

	if self.maxProgress <= progress and taskId then
		self:CreateFakeSubmitButton(taskId)
	end
end

function M:TaskToExamState(_, data)
	self.examTaskId = data.examTaskId
	self.examIndex = data.examIndex

	if data.examTaskId == 0 then
		return 0
	end

	self.bindData.state = TaskState.Exam

	self:UpdatePanelHeight(TaskState.Exam)

	self.bindData.examTaskName = self.titleDes or ""

	if data.factIds then
		for i = 1, #data.factIds do
			self:ChangeFactState(data.factIds[i])
		end
	end

	self.bindData.factList:SetSimpleList(#self.factLists)
	print_debug("TaskToExamState", data.examTaskId)
	self:RefreshExamProgress()
end

function M:RefreshExamProgress()
	if self.bindData.state ~= TaskState.Exam then
		return
	end

	if self.taskId ~= self.examTaskId then
		self:ResetShortcut()

		if gPoliceJobManager.isFakeTaskPanel then
			return
		end

		if self.curTaskId ~= 0 or self.examTaskId ~= 0 then
			self:ChangeToDoing(self.curTaskId, false)
		else
			self:ChangeToWaiting()
		end

		return
	end

	local taskInfo = gTaskManager:GetTaskInfo(self.examTaskId)

	print_debug("PoliceTaskPanelStore refreshExamProgress", self.examTaskId, self.examIndex)

	if taskInfo and taskInfo.Counters and taskInfo.Counters[self.examIndex + 1] then
		print_debug("PoliceTaskPanelStore refreshExamProgress Success")

		local counter = taskInfo.Counters[self.examIndex + 1]
		self.bindData.examProgress = math.floor(counter.Value / counter.ConfigValue * self.maxProgress)

		if counter.ConfigValue <= counter.Value then
			self:CreateSubmitButton(self.examTaskId)
		end
	end
end

function M:ReSetFactList(factIds)
	local factData = {}

	if factIds then
		for i = 1, #factIds do
			local config = factConfig.GetConfig(factIds[i])

			if config then
				table.insert(factData, {
					state = 0,
					factId = factIds[i],
					factText = config.Option
				})
			end
		end
	end

	self.factLists = factData
end

function M:ChangeFactState(factId)
	for _, v in pairs(self.factLists) do
		if v.factId == factId then
			v.state = 1

			break
		end
	end
end

function M:FactListRender(btn, index)
	local data = self.factLists[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store and data then
		store.factText = data.factText
		store.finishState = data.state
	end
end

function M:RefreshTaskInfo()
	local taskId = gTaskManager:GetCurTask()

	self:OnCurrentChange(_, {
		TaskId = taskId
	})
end

function M:FakeOpenTask()
	self:RefreshTaskInfo()

	self.curTaskType = PoliceConfig.FakeTaskType

	self:PanelStateToDoingHelper(PoliceConfig.FakeTaskName, PoliceConfig.FakeTaskInfo, PoliceConfig.FakeTaskImage)
end

function M:PanelStateToDoingHelper(titleDes, info, pic)
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
	local imageCfg = SguiImageConfig.GetConfig(imageId)
	self.bindData.curImageUrl = imageCfg.ImgPath
end

function M:ChangeToDoing(id, isRecover)
	local config = self:GetPoliceConfig(id)

	if config == nil then
		return
	end

	self:ReSetFactList(config.ExamFact)

	self.curTaskType = config.MissionType

	self:SwitchTaskType(true, config.Des, isRecover)
	self:PanelStateToDoingHelper(config.Title2, config.Info3, config.Pic1)
end

function M:SwitchTaskType(enable, Des, isRecover)
	if self.curTaskType == policeTaskConfig.MissionTypeType.BattleCamp then
		self:SwitchTaskInfo(Des)

		local battleCfg = LTConfig.BattleCampConfig.GetConfig(self.eventId)

		if battleCfg then
			if enable then
				gMapSubSystem_Camp:TryTraceAndLockAction(battleCfg.SubQuestId)
			else
				gMapSubSystem_Camp:TryUntraceAndUnlockAction(battleCfg.SubQuestId)
			end
		end
	elseif self.curTaskType == policeTaskConfig.MissionTypeType.BattleRandom then
		self:SwitchTaskInfo(Des)

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

function M:StartUpdate()
	self.isUpdate = true
	self.startTime = gLogicTime.time
end

function M:OnUpdate()
	if self.isPadPressingTaskBtn then
		self.padPressTime = self.padPressTime + Time.deltaTime

		if self.gamepadMode then
			self.bindData.padPressFill = self.padPressTime
		end

		if self.padPressTime >= 0.8 then
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

		if self.waitTime < gLogicTime.time - self.startTime then
			if not gPoliceJobManager.isFakeTaskPanel then
				self:GiveUpTask()

				self.isUpdate = false
			else
				self:FakeOpenCall()
			end
		end
	end

	if self.isStartBar then
		local nowTime = gLogicTime.time
		local fill = self.minProficiency + (nowTime - self.startTime) / self.duration * (self.maxProficiency - self.minProficiency)
		self.bindData.proficiencyFill = fill > 1 and fill - 1 or fill

		if self.duration < nowTime - self.startTime then
			self.isStartBar = false
		end
	end

	if self.startPress then
		local nowTime = gLogicTime.time
		self.bindData.exitFill = (nowTime - self.startPressTime) / self.pressTime

		if self.pressTime < nowTime - self.startPressTime then
			self:OnPressBtnEndHelper()
			self:FinishPoliceJob()
		end
	end

	if self.bindData.state == TaskState.Calling and self.targetPoint ~= nil then
		local pos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
		pos.y = 0
		self.targetPoint.y = 0

		if pos ~= nil then
			self.bindData.distanceText = math.floor(Vector3.Distance(pos, self.targetPoint)) .. "m"
		end
	end
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnLanguageChange()
	if self.bindData.state == TaskState.Doing then
		self:ChangeToDoing(self.curTaskId, true)
	end

	self:CheckAppHomePanelState()
end

function M:OnViolationBtnClick()
	gPoliceJobManager.panelMgr:OpenNoticePanel()
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device

	if not self.gamepadMode then
		self.bindData.padPressFill = 0
	end

	self:CheckAppHomePanelState()
end
