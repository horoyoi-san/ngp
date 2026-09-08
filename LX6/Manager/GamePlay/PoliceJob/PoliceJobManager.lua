-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\PoliceJob\PoliceJobManager.lua
-- Decompiled from: 00548_PoliceJobManager.lua_4cfe93aacf03.luajit

local JobClassConfig = LTConfig.UrbanJobJobClassConfig
local MessageConfig = LTConfig.MessageConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local TaskEventState = UX.Game.TaskEventState
local MyPlayerManager = gCS.MyPlayerManager
local SceneDataMgr = gCS.SceneDataMgr
local TaskState = UX.Game.TaskState

if not gPoliceJobManager then
	local PoliceJobManager = {
		["7%$\\xe5j\\xb5\\xfe'\\xbb&\\xe9\\xfc\\xc5z\\xef"] = 0,
		["\\xd0\\xc801\\xf6"] = false,
		["9\\xb9\\xf03v*1\\x82'啑6\\xad\\x96څ"] = 0,
		["fe\\x85yd\\xbb\\xf6B^{mG"] = false,
		actionMgr = require("LX6/Manager/GamePlay/PoliceJob/PoliceGameplayActions"),
		examineMgr = require("LX6/Manager/GamePlay/PoliceJob/PoliceExamineManager"),
		escortMgr = require("LX6/Manager/GamePlay/PoliceJob/PoliceEscortManager"),
		panelMgr = require("LX6/Manager/GamePlay/PoliceJob/PolicePanelManager"),
		npcStatusDict = {},
		vehicleStatusDict = {}
	}
end

PoliceJobManager.OnInit = function(self)
	self.POLICE_STAGE = {
		["9{\\xb2\\xa1\\xb1u"] = 3,
		["\\xfc\\xe3507\n\\xd4"] = 2,
		["T\rS~"] = 1
	}
	self.POLICE_NOTICE_TYPE = {
		["unCEo*8="] = 2,
		["\\x82\\x9f&\\x82N\\xd0"] = 1,
		["T\rS~"] = 0
	}
	self.ARREST_NOTIFY_ID = {
		["/m\\xb0\\xbc\\xa0i"] = 0,
		["+i\\xbf\\xba\\xa6e"] = 1
	}

	self.panelMgr:OnInit()

	self.cs = L18.Gameplay.PoliceJobManager.Instance
	self.fakeJobEvent = 0
	self.isPoliceJob = false
	self.isReceivingOrder = false
	self.panelCallBack = {}
	self.panelIsRegister = false
	self.containPoliceJob = false
	self.fleeCarGpsId = "PoliceCarFlee"
	self.curTracedFleeVehicleId = 0

	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self.OnBeforeSwitchScene)
	gMessageManager:AddMessageListener(gEventConstants.L50_AFTER_SWITCH_SCENE, self.OnAfterSwitchScene)
	self:RegisterPanelMessageEvents()
	self.examineMgr:Init()

	self.canExamineRaid = {}
	local raidId = LTConfig.PoliceConfig.CanExamineRaidId

	if #raidId <= 0 then
		for i = 1, #raidId do
			self.canExamineRaid[raidId[i]] = true
		end
	end
end

PoliceJobManager.CreateAction = function(self, action, target)
	return function (...)
		target = target or self

		if type(action) ~= "string" then
			if target[action] then
				return target[action](target, ...)
			end
		else
			return action(target, ...)
		end
	end
end

PoliceJobManager.RegisterPanelMessageEvents = function(self)
	gMessageManager:AddMessageListener(gEventConstants.JOB_CHANGE_EVENT, self:CreateAction(self.OnJobStateChange))
	gMessageManager:AddMessageListener(gEventConstants.SYNC_CURRENT_SPIRIT, self:CreateAction(self.OnSpiritChange))
	gMessageManager:AddMessageListener(gEventConstants.JOB_MISSION_STATE_CHANGE, self:CreateAction(self.JobMissionStateChange))
	gMessageManager:AddMessageListener(gEventConstants.POLICE_BEGIN_FAKE_ACTIVE, self:CreateAction(self.StartPoliceFakeActive))
	gMessageManager:AddMessageListener(gEventConstants.ON_EVENT_STATE_CHANGE, self:CreateAction(self.EventStateChange))
	gMessageManager:AddMessageListener(gEventConstants.POLICE_BEGIN_FAKE_NEW, self:CreateAction(self.StartFakeTask))
	gMessageManager:AddMessageListener(gEventConstants.TASK_STATE_CHANGED, self:CreateAction(self.OnTaskStateChanged))
	gMessageManager:AddMessageListener(gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE, self:CreateAction(self.OnSystemUnlockChanged))
end

PoliceJobManager.OnJobStateChange = function(self, _, data)
	if data ~= nil then
		slot3 = gCoroutineManager

		slot3:StartCoroutine(function ()
			while gLuaDataManager.gameStage == gGFConstant.GameStage.GameScene do
				coroutine.yield(nil)
			end

			data = gSpiritJobManager:GetCurJobId()

			self:CheckIsPoliceJob(data)
		end)
	else
		self.CheckIsPoliceJob(self, data)
	end
end

PoliceJobManager.OnSkipNext = function(self, messageId)
	self.panelMgr:OnSkipNext(messageId)
end

PoliceJobManager.CheckIsPoliceJob = function(self, data, isActive)
	data = data or 0
	local cfg = LTConfig.UrbanJobConfig.GetConfig(data)

	if (cfg and cfg.JobClass ~= JobClassConfig.Police or isActive) and not self.fakeActive then
		if not self.isPoliceJob then
			self.isPoliceJob = true
		end

		if not self.isReceivingOrder then
			return
		end

		slot4 = gTaskUtils

		slot4:OpenTaskGuideCurTab(gTaskUtils.TaskGuideSubPanel.Police)
		table.insert(self.panelCallBack, function ()
			gMessageManager:SendMessage(gEventConstants.POLICE_SYNC_MISSION_COUNT, {
				completeCntInHideTask = self.completeCntInHideTask or 0,
				todayCompleteCnt = self.todayMissionCnt
			})
		end)
	elseif self.isPoliceJob then
		self.isPoliceJob = false

		gTaskUtils:HandleTaskGuideClose()
		gTaskUtils.TryShowNewestMainTaskGuide()
	end

	self.containPoliceJob = gSpiritJobManager:CheckContainJobClassId(LTConfig.UrbanJobJobClassConfig.Police)

	self:PoliceJobMissionStateChange(self.fakeActive, self.isPoliceJob)
end

PoliceJobManager.SendMessageToPanel = function(self, callback)
	if not self.panelIsRegister then
		table.insert(self.panelCallBack, callback)
	else
		callback()
	end
end

PoliceJobManager.PoliceTaskRecover = function(self, id, eventId)
	if not gTaskUtils:GetTaskGuideCurType() or gTaskUtils:GetTaskGuideCurType() == gTaskUtils.TaskGuideSubPanel.Police then
		slot3 = gTaskUtils

		slot3:OpenTaskGuideCurTab(gTaskUtils.TaskGuideSubPanel.Police)
		table.insert(self.panelCallBack, function ()
			gMessageManager:SendMessage(gEventConstants.POLICE_SYNC_MISSION_COUNT, {
				completeCntInHideTask = self.completeCntInHideTask or 0,
				todayCompleteCnt = self.todayMissionCnt
			})
		end)
	end

	self.SendMessageToPanel(self, function ()
		gMessageManager:SendMessage(gEventConstants.POLICE_TASK_TO_DOING, {
			id = id,
			eventId = eventId
		})
	end)
end

PoliceJobManager.IsPanelShow = function(self)
	return self.isPoliceJob and not self.fakeActive
end

PoliceJobManager.OnTaskCounterChange = function(self, taskId)
	if not taskId or taskId == LTConfig.TaskConfig.PoliceHideTask then
		return
	end

	local taskValue, _, _ = gTaskNodeManager:GetTaskCounterInfo(taskId)
	self.completeCntInHideTask = taskValue.CounterValue or 0

	gMessageManager:SendMessage(gEventConstants.POLICE_SYNC_MISSION_COUNT, {
		completeCntInHideTask = self.completeCntInHideTask,
		todayCompleteCnt = self.todayMissionCnt
	})
end

PoliceJobManager.OnTaskStateChanged = function(self, eventId, data)
	if not data then
		return
	end

	local taskId = data[1]
	local taskState = data[2]

	if not taskId or not taskState then
		return
	end

	if taskId ~= LTConfig.TaskConfig.PoliceHideTask then
		if taskState ~= TaskState.Accepted then
			self.isInHideTask = true
			local taskValue, _, _ = gTaskNodeManager:GetTaskCounterInfo(taskId)
			self.completeCntInHideTask = taskValue.CounterValue or 0

			gMessageManager:SendMessage(gEventConstants.POLICE_SYNC_MISSION_COUNT, {
				completeCntInHideTask = self.completeCntInHideTask,
				todayCompleteCnt = self.todayMissionCnt
			})
		else
			self.isInHideTask = false
			self.completeCntInHideTask = 0
		end
	end
end

PoliceJobManager.OnSystemUnlockChanged = function(self, eventId, systemUnlockId)
	if systemUnlockId ~= SystemUnlockConfig.PoliceApp then
		self.RefreshPoliceStage(self)
	end
end

PoliceJobManager.StartFakeTask = function(self, _, data)
	gPoliceJobManager.isFakeTaskPanel = data ~= nil or data.isFakeTaskPanel

	if not self.panelIsRegister then
		local fakeCallBack = function()
			gTaskUtils:OpenTaskGuideCurTab(gTaskUtils.TaskGuideSubPanel.Police)
			gStoreManager:GetStoreGroup("PoliceTaskPanelStore"):FakePolicePanelEvent(data)
		end

		table.insert(self.panelCallBack, fakeCallBack)
		self.JobMissionStateChange(self, _, {
			["K\\xa1\\xb0\\xac\\xb3"] = true,
			["K\\x85\\x87\\x95D"] = true,
			job = JobClassConfig.Police
		})
	else
		gTaskUtils:OpenTaskGuideCurTab(gTaskUtils.TaskGuideSubPanel.Police)
		gStoreManager:GetStoreGroup("PoliceTaskPanelStore"):FakePolicePanelEvent(data)
	end
end

PoliceJobManager.ExecuteCallback = function(self)
	for _, func in pairs(self.panelCallBack) do
		func()
	end

	self.panelCallBack = {}
end

PoliceJobManager.StartPoliceJobWithFakeTaskCallBack = function(self, data)
	if not gSpiritJobManager:CheckIsCurrentjob(JobClassConfig.Police) then
		slot2 = gClientToGameDelegate

		slot2:AskStartJob(JobClassConfig.Police).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			gPoliceJobManager:StartFakeTask(gEventConstants.FAKE_POLICE_PANEL_STATE_EVENT, data)
		end
	else
		gPoliceJobManager:StartFakeTask(gEventConstants.FAKE_POLICE_PANEL_STATE_EVENT, data)
	end
end

PoliceJobManager.OnSpiritChange = function(self, _, data)
	local spirit = gSpiritManager:GetSpirit(data)

	if spirit == nil then
		local jobId = spirit.SpiritInfo.SpiritJobInfo.CurrentJob

		self.CheckIsPoliceJob(self, jobId)
	end

	self.containPoliceJob = gSpiritJobManager:CheckContainJobClassId(LTConfig.UrbanJobJobClassConfig.Police)

	self:PoliceJobMissionStateChange(self.fakeActive, self.isPoliceJob)
end

PoliceJobManager.CheckCurSpiritJob = function(self, switchType)
	if switchType ~= gSwitchSceneType.NewScene then
		local jobId = gSpiritJobManager:GetCurJobId()

		self:CheckIsPoliceJob(jobId)
	end
end

PoliceJobManager.JobMissionStateChange = function(self, _, data)
	self.isReceivingOrder = data.active or data.force

	if data.job ~= JobClassConfig.Police and (not self.isFakeTaskPanel or data.force) then
		self.CheckIsPoliceJob(self, nil, data.active)
	end
end

PoliceJobManager.StartPoliceFakeActive = function(self, _, isCloseFake)
	if not isCloseFake then
		local taskId = gTaskNodeManager:GetNowDoingTask()
		local eventInfo = gTaskNodeManager:GetTaskLineByTask(taskId)

		if not table.isNilOrEmpty(eventInfo) then
			self.fakeJobEvent = eventInfo.TaskLineId

			self.PoliceJobMissionStateChange(self, true, self.isPoliceJob)
		end
	else
		self.fakeJobEvent = 0

		self.PoliceJobMissionStateChange(self, false, self.isPoliceJob)
	end
end

PoliceJobManager.EventStateChange = function(self, _, data)
	if self.fakeJobEvent ~= data.eventId and data.state == TaskEventState.Accepted and self.fakeActive then
		slot3 = gClientToGameDelegate

		slot3:AskFinishJob().Callback = function (err)
			if err == MessageConfig.Ok then
				print_error("AskFinishJob Fail", err)

				return
			end

			self.fakeJobEvent = 0

			self:PoliceJobMissionStateChange(false, self.isPoliceJob)
		end
	end
end

PoliceJobManager.OnAfterSwitchScene = function(eventId, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	gPoliceJobManager:OnAfterSwitchSceneInternal(switchType)
end

PoliceJobManager.OnSyncMissionCount = function(self, data)
	self.todayMissionCnt = data.todayCompleteCnt

	gMessageManager:SendMessage(gEventConstants.POLICE_SYNC_MISSION_COUNT, {
		completeCntInHideTask = self.completeCntInHideTask or 0,
		todayCompleteCnt = self.todayMissionCnt
	})
end

PoliceJobManager.OnAfterSwitchSceneInternal = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self.CheckCurSpiritJob(self, switchType)

		self.isInHideTask = false
		self.todayMissionCnt = 0
		self.completeCntInHideTask = 0
	end
end

PoliceJobManager.OnBeforeSwitchScene = function(eventId, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	gPoliceJobManager:OnBeforeSwitchSceneInternal(eventId, switchType)
end

PoliceJobManager.OnBeforeSwitchSceneInternal = function(self, eventId, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self.fakeActive = false
		self.isPoliceJob = false
		self.isReceivingOrder = false
		self.isFakeTaskPanel = nil
		self.panelCallBack = {}

		self.RefreshPoliceStage(self)

		if self.refreshTimer then
			self.refreshTimer:Stop()

			self.refreshTimer = nil
		end
	end
end

PoliceJobManager.PoliceJobMissionStateChange = function(self, fakeActive, isPoliceJob)
	if self.isDebug then
		print_notice("PoliceJobManager PoliceJobMissionStateChange containPoliceJob " .. tostring(self.containPoliceJob))
	end

	self.fakeActive = fakeActive

	if not fakeActive then
		self.isPoliceJob = isPoliceJob
	end

	self.ChangeCsJobManagerDuty(self)
end

PoliceJobManager.OpenPoliceEndPanel = function(self, spiritId, serviceData, stopPatrol)
	if not self.fakeActive and stopPatrol then
		gNewPopupManager:PushPopup(LTConfig.PopupConfig.PoliceEnd, {
			spiritId = spiritId,
			serviceData = serviceData
		})
	end
end

PoliceJobManager.CheckNeedPoliceInfo = function(self)
	if self.containPoliceJob then
		local isInDue = self.panelMgr:CheckIsInViolation()

		if isInDue then
			return self.POLICE_NOTICE_TYPE.VIOLATION
		end

		if self.curIncidentInfo and self.curIncidentInfo.Id <= 0 and not self.curIncidentInfo.hasGetReward then
			return self.POLICE_NOTICE_TYPE.INCIDENT
		end
	end

	return self.POLICE_NOTICE_TYPE.NONE
end

PoliceJobManager.IsRaidSupportExamine = function(self, raidId)
	return raidId and self.canExamineRaid[raidId]
end

PoliceJobManager.ChangeCsJobManagerDuty = function(self)
	local isInDue, leaveTime = self.panelMgr:CheckIsInViolation()

	if isInDue then
		if self.refreshTimer then
			self.refreshTimer:ResetTime(leaveTime + 0.1)
			self.refreshTimer:Start()
		else
			self.refreshTimer = Timer.New(function ()
				self:RefreshPoliceStage()

				self.refreshTimer = nil
			end, leaveTime + 0.1):Start()
		end
	elseif self.refreshTimer then
		self.refreshTimer:Stop()

		self.refreshTimer = nil
	end

	local supportExamine = gLinkManager.LinkMode ~= UX.Game.LinkMode.None and self:IsRaidSupportExamine(gRaidDataManager.RaidId) and gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.PoliceApp)

	self.cs:SetHasPoliceJob_Story(self.containPoliceJob and not isInDue and supportExamine)
	gMessageManager:SendMessage(gEventConstants.POLICE_SWITCH_POLICE_INFO)
end

PoliceJobManager.RefreshPoliceStage = function(self)
	if self.isDebug then
		print_notice("PoliceJobManager : RefreshPoliceStage")
	end

	self.ChangeCsJobManagerDuty(self)
end

PoliceJobManager.EnterPoliceExamineBySpoon = function(self, targetPid, customFines, customOptions, useCustomDialogs, guideOptions, guideIconId, askDialogId, hideLeaveBtn, hideEscortLeaveBtn, hideSuggestion)
	local customFinesTable = customFines:ToTable()
	local customOptionsTable = customOptions:ToTable()
	local guideOptionsTable = guideOptions:ToTable()
	local data = {
		["\\xe2S \\xd45\\xb8r\\xb1Y\\xbf\\xb8"] = true,
		targetPid = targetPid,
		customFines = customFinesTable,
		customOptions = customOptionsTable,
		useCustomDialogs = useCustomDialogs,
		guideOptions = guideOptionsTable,
		guideIconId = guideIconId,
		askDialogId = askDialogId,
		hideLeaveBtn = hideLeaveBtn,
		hideEscortLeaveBtn = hideEscortLeaveBtn,
		hideSuggestion = hideSuggestion
	}

	gPoliceJobManager.examineMgr:PrepareDataFromSpoon_Story(data)
end

PoliceJobManager.EnterPoliceEscortBySpoon = function(self, targetPid, hideEscortToExamineBtn, hideEscortLeaveBtn, hideEscortReleaseBtn, enterByTimeline, traceToNearestPoliceCar, showTraceToPoliceOfficeBtn)
	local interact = enterByTimeline and LTConfig.PoliceExamInteractConfig.PoliceGuardEnterTL or LTConfig.PoliceExamInteractConfig.EscortTransfer
	local data = {
		["A_Ͼ\\x90\\xb7\n\\xe0\\xec"] = 22001,
		targetPid = targetPid,
		hideEscortToExamineBtn = hideEscortToExamineBtn,
		hideEscortLeaveBtn = hideEscortLeaveBtn,
		hideEscortReleaseBtn = hideEscortReleaseBtn,
		reactDirectly = enterByTimeline,
		interact = interact,
		traceToNearestPoliceCar = traceToNearestPoliceCar,
		showTraceToPoliceOfficeBtn = showTraceToPoliceOfficeBtn
	}

	self.escortMgr:EnterEscort_Story(data)
end

PoliceJobManager.OpenCasePanelBySpoon = function(self)
	self.panelMgr:OpenCasePanel()
end

PoliceJobManager.OnDropPoliceJobExp = function(self, reward)
	self.examineMgr:OnDropPoliceJobExp(reward)
end

PoliceJobManager.OnDropPoliceReturnInvalidVehicleFine = function(self)
	gNewPopupManager:SetPause(true)

	local fineFailDialog = LTConfig.PoliceConfig.FineFailDialog

	if fineFailDialog <= 0 then
		slot2 = gDialogManager

		slot2:ShowGeneralDialog(fineFailDialog, gDialogSource.Police, nil, , function (_, _, state, nextDialogId)
			if nextDialogId ~= 0 and state ~= 0 then
				gNewPopupManager:SetPause(false)
			end
		end)
	else
		gNewPopupManager:SetPause(false)
	end
end

PoliceJobManager.IsUnitValid = function(unit)
	return unit == nil and not unit.IsDestroyed and not unit.IsDead
end

PoliceJobManager.TraceToPoliceOffice = function(self, force)
	local pointId = LTConfig.PoliceConfig.ArrestDestination

	if pointId and pointId <= 0 then
		local mapElement = gMapSubSystem_FunctionPoint:TryGetMapElementByFunctionPointId(pointId)

		if gMapSystem_Trace.mainTraceGpsId ~= mapElement.gpsId then
			if not force then
				gMapSubSystem_FunctionPoint:TryUnTraceByFunctionPointId(pointId)
			end
		else
			gMapSubSystem_FunctionPoint:TryTraceByFunctionPointId(pointId)
		end
	end
end

PoliceJobManager.TraceToFirstPoliceCar = function(self, VehicleIds)
	if not self.escortMgr.traceToNearestPoliceCar then
		return
	end

	local idTable = VehicleIds and VehicleIds:ToTable()

	if idTable and #idTable <= 0 then
		local added = false

		for i = 1, #idTable do
			local vehicleId = idTable[i]

			if gMapSubSystem_Vehicle:ContainsMilkCar(vehicleId) then
				added = true

				break
			end
		end

		if not added then
			self:CancelTraceToPoliceCar()

			self.curTracePoliceCar = idTable[1]

			gMapSubSystem_Vehicle:AddMilkCar(self.curTracePoliceCar, gRaidDataManager.RaidId, 28006908)
		end
	end
end

PoliceJobManager.CancelTraceToPoliceCar = function(self)
	if self.curTracePoliceCar then
		local vehicleId = self.curTracePoliceCar
		self.curTracePoliceCar = nil

		gMapSubSystem_Vehicle:RemoveMilkCar(vehicleId)
	end
end

PoliceJobManager.OpenAgentIdPanelDirectly = function(self, unit)
	if unit then
		gMainPhoneUtils.ShowPhoneAppContent({
			showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.PoliceId,
			unit = unit
		})
	end
end

PoliceJobManager.EnterPoliceTrialBySpoon = function(self, agentId)
	self.panelMgr:EnterPoliceTrialBySpoon(agentId)
end

PoliceJobManager.GetCurrentExamineUnitPid = function(self)
	return (self.examineMgr.unit or {}).Pid
end

PoliceJobManager.GMSkipPoliceAITrial = function(self, state)
	local aiTrialPanel = gStoreManager:GetStoreGroup("PoliceAITrialPanelStore")

	if state and aiTrialPanel and aiTrialPanel.isShow then
		aiTrialPanel.GMSkipPoliceAITrial(aiTrialPanel, state)
	end
end

PoliceJobManager.OnSyncAgentPoliceExamData = function(self, agentId, data)
	self.examineMgr:OnSyncExamineData(agentId, data)
end

PoliceJobManager.OnSyncPoliceDailyIncidentInfo = function(self, NowEffctIncidentConfigId, HasGetTodaysIncidentReward)
	if self.curIncidentInfo and self.curIncidentInfo.hasGetReward == HasGetTodaysIncidentReward and HasGetTodaysIncidentReward then
		gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_PoliceDailyTaskCompletePanel)
	end

	self.curIncidentInfo = {
		Id = NowEffctIncidentConfigId,
		hasGetReward = HasGetTodaysIncidentReward
	}

	gMessageManager:SendMessage(gEventConstants.POLICE_SWITCH_POLICE_INFO)
end

PoliceJobManager.OnSyncPlayerArrestStateNotify = function(self, id)
	if id ~= self.ARREST_NOTIFY_ID.SEARCH or id ~= self.ARREST_NOTIFY_ID.WANTED then
		gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_PoliceArrestTips, id)
	end
end

PoliceJobManager.OpenPanel_Story = function(self, pid)
	local selfUnit = MyPlayerManager.PlayerUnit
	local npcUnit = SceneDataMgr.GetUnit(pid)
	local success, interactMainPos, interactMainDir, interactCoPos, interactCoDir = L18.Gameplay.PoliceJobManager.TryGetMultiInteractPosAndDir(LTConfig.MultiInteractTypeConfig.Examine, selfUnit, npcUnit, nil, , , )
	self.examineMgr.enterExamData.npcTargetDir = interactCoDir

	gPanelManager:CheckShow(gPanelId.POLICE_INQUIRY_PANEL, self.examineMgr.enterExamData)
end

PoliceJobManager.PrepareData_Story = function(self, pid)
	self.examineMgr:PrepareData_Story(pid)
end

PoliceJobManager.CleanExamineData_Story = function(self)
	self.examineMgr:OnExitExamine()
end

PoliceJobManager.ClosePanel_Story = function(self)
	gPanelManager:Close(gPanelId.POLICE_INQUIRY_PANEL)
end

PoliceJobManager.VMSingal_Story = function(self, optionId, eventId)
	self.examineMgr:VMSingal_Story(optionId, eventId)
end

PoliceJobManager.OnSectionEnable_Story = function(self, optionId)
	self.examineMgr:OnSectionEnable_Story(optionId)
end

PoliceJobManager.OpenEscortPanel_Story = function(self, pid)
	self.escortMgr:EnterEscortFromExamine_Story(pid, true, false)
end

PoliceJobManager.CloseEscortPanel_Story = function(self)
	self.escortMgr:ExitEscort_Story()
end

PoliceJobManager.NeedGetUp_Story = function(self)
	return self.examineMgr:GetGetUpEvent() == nil
end

PoliceJobManager.AfterGetUp_Story = function(self)
	self.examineMgr:SetNotFree()
end

PoliceJobManager.GetUseCustomData_Story = function(self)
	return self.examineMgr.attachData and self.examineMgr.attachData.useCustomDialogs
end

PoliceJobManager.OnReceiveReaction_Story = function(self, reactionId)
	self.examineMgr:OnReceiveReaction(reactionId)
end

PoliceJobManager.SetBlockInteract_Story = function(self, flag)
	self.examineMgr:SetBlockInteract_Story(flag)
end

PoliceJobManager.OpenExamineCarFinePanel_Story = function(self, fineDict)
	local fineInfoDic = {}
	local fineList = nil

	if fineDict then
		local hasBuff = gBuffUtils.HasBuff(MyPlayerManager.PlayerUnit.Pid, 52810300)

		if hasBuff then
			fineList = {}
		end

		local allFine = {}
		local fineTable = fineDict.ToTable(fineDict)

		for k, v in pairs(fineTable) do
			fineInfoDic[k] = {
				isFined = v
			}

			if hasBuff then
				table.insert(allFine, k)
			end
		end

		if hasBuff and #allFine <= 0 then
			math.randomseed(os.time())

			local index = math.random(#allFine)
			local fineId = allFine[index]

			table.insert(fineList, fineId)
		end
	end

	gMainPhoneUtils.ShowPhoneAppContent({
		["fe\\x89oM\\xbf\\xfbIoY^"] = true,
		showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.PoliceFine,
		fineInfoDict = fineInfoDic,
		fineList = fineList
	})
end

PoliceJobManager.CheckAgentIsStandUp = function(self, unit)
	return self.examineMgr:CheckAgentIsStandUp(unit)
end

PoliceJobManager.TraceToNewFleeCar = function(self, vehicleId)
	self.curTracedFleeVehicleId = vehicleId
	local element = gMapSubSystem_CommonGps:CreateOrGetRawGps(self.fleeCarGpsId, gRaidDataManager.RaidId)

	element:BindVehicle(vehicleId)
	element:SetViewMask(EMapViewMask.HudGps + EMapViewMask.MiniMap)

	element.mData.sIconId = 28000181
end

PoliceJobManager.CancelTraceToFleeCar = function(self, vehicleId)
	if self.curTracedFleeVehicleId ~= vehicleId then
		self.curTracedFleeVehicleId = 0

		gMapSubSystem_CommonGps:RemoveCommonGps(self.fleeCarGpsId)
	end
end

PoliceJobManager.OpenExamineBlackScreen = function(self)
	gBlackScreenManager:OpenTransition(gBlackScreenId.POLICE_EXAMINE, nil, false, true, 0, -1, -1, 0)
end

PoliceJobManager.CloseExamineBlackScreen = function(self)
	gBlackScreenManager:CloseTransition(gBlackScreenId.POLICE_EXAMINE)
end

PoliceJobManager.IsInExamineBlackScreen = function(self)
	if gBlackScreenManager:IsOccupiedById(gBlackScreenId.POLICE_EXAMINE) then
		return true
	else
		return false
	end
end

PoliceJobManager.EnableDebug = function(self, enable)
	self.isDebug = enable
end

gPoliceJobManager = PoliceJobManager
