local JobClassConfig = LTConfig.UrbanJobJobClassConfig
local MessageConfig = LTConfig.MessageConfig
local TaskEventState = UX.Game.TaskEventState
local MyPlayerManager = gCS.MyPlayerManager
local SceneDataMgr = gCS.SceneDataMgr

if not gPoliceJobManager then
	local PoliceJobManager = {
		cachedWeaponIndex = 0,
		isDebug = true,
		actionMgr = require("LX6/Manager/GamePlay/PoliceJob/PoliceGameplayActions"),
		examineMgr = require("LX6/Manager/GamePlay/PoliceJob/PoliceExamineManager"),
		searchCarMgr = require("LX6/Manager/GamePlay/PoliceJob/PoliceSearchCarManager"),
		escortMgr = require("LX6/Manager/GamePlay/PoliceJob/PoliceEscortManager"),
		panelMgr = require("LX6/Manager/GamePlay/PoliceJob/PolicePanelManager"),
		npcStatusDict = {},
		vehicleStatusDict = {}
	}
end

function PoliceJobManager:OnInit()
	self.WAIT_REACTION = {
		WAIT_DRUG_TEST_RES = 5,
		WAIT_LEAVE_ESCORT_RES = 11,
		WAIT_ENTER_ESCORT_RES = 10,
		WAIT_MOVE_FINISH = 0,
		WAIT_ESCORT_TO_EXAMINE_RES = 13,
		WAIT_COMMAND_RES = 6,
		WAIT_ID_CHECK_RES = 1,
		WAIT_FINE_RES = 2,
		WAIT_RELEASE_ESCORT_RES = 12,
		WAIT_ARREST_RES = 8,
		WAIT_ALCOHOL_TEST_RES = 4,
		WAIT_LEAVE_RES = 9,
		WAIT_RELEASE_RES = 7,
		WAIT_BODY_SEARCH_RES = 3,
		WAIT_ESCORT_TO_CAR = 14,
		WAIT_ESCORT_FROM_CAR = 15
	}
	self.POLICE_STAGE = {
		ESCORT = 3,
		EXAMINE = 2,
		NONE = 1
	}
	self.CS_EXAMINE_STAGE = {
		ESCORTING_INCAR = 3,
		INWARD = 4,
		ESCORTING = 2,
		EXAMINING = 1,
		NONE = 0
	}
	self.CS_EXIT_STATE = {
		ESCORTING_EXIT = 2,
		EXAMINING_EXIT = 1,
		NONE = 0
	}
	self.currentStage = self.POLICE_STAGE.NONE
	self.dutyDisable = {
		[self.POLICE_STAGE.EXAMINE] = true,
		[self.POLICE_STAGE.ESCORT] = true
	}

	self.panelMgr:OnInit()

	self.cs = L18.Gameplay.PoliceJobManager.Instance
	self.fakeJobEvent = 0
	self.isPoliceJob = false
	self.panelCallBack = {}
	self.panelIsRegister = false
	self.containPoliceJob = false
	self.typeToEscortToWardTLName = {
		[8] = "play_police_arrest_mm",
		[9] = "play_police_arrest_lm",
		[10] = "play_police_arrest_sf",
		[11] = "play_police_arrest_mf",
		[12] = "play_police_arrest_lf"
	}
	self.fleeCarGpsId = "PoliceCarFlee"
	self.curTracedFleeVehicleId = 0

	gMessageManager:AddMessageListener(gEventConstants.HIT_UNIT, self.OnUnitBeHurt)
	gMessageManager:AddMessageListener(gEventConstants.UNIT_DESTROY, self.OnUnitBeDestroy)
	gMessageManager:AddMessageListener(gEventConstants.ON_BEGIN_PORTAL, self.OnBeginPortal)
	gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, self.OnBeforeSwitchScene)
	gMessageManager:AddMessageListener(gEventConstants.AFTER_SWITCH_SCENE, self.OnAfterSwitchScene)
	gMessageManager:AddMessageListener(gEventConstants.TIMELINE_START, self.OnTimeLineStart)
	self:RegisterPanelMessageEvents()
	self.examineMgr:Init()
end

function PoliceJobManager:CreateAction(action, target)
	return function (...)
		target = target or self

		if type(action) == "string" then
			if target[action] then
				return target[action](target, ...)
			end
		else
			return action(target, ...)
		end
	end
end

function PoliceJobManager:RegisterPanelMessageEvents()
	gMessageManager:AddMessageListener(gEventConstants.JOB_CHANGE_EVENT, self:CreateAction(self.OnJobStateChange))
	gMessageManager:AddMessageListener(gEventConstants.SYNC_CURRENT_SPIRIT, self:CreateAction(self.OnSpiritChange))
	gMessageManager:AddMessageListener(gEventConstants.JOB_MISSION_STATE_CHANGE, self:CreateAction(self.JobMissionStateChange))
	gMessageManager:AddMessageListener(gEventConstants.POLICE_BEGIN_FAKE_ACTIVE, self:CreateAction(self.StartPoliceFakeActive))
	gMessageManager:AddMessageListener(gEventConstants.ON_EVENT_STATE_CHANGE, self:CreateAction(self.EventStateChange))
	gMessageManager:AddMessageListener(gEventConstants.POLICE_BEGIN_FAKE_NEW, self:CreateAction(self.StartFakeTask))
end

function PoliceJobManager:OnJobStateChange(_, data)
	if data == nil then
		gCoroutineManager:StartCoroutine(function ()
			while gLuaDataManager.gameStage ~= gGFConstant.GameStage.GameScene do
				coroutine.yield(nil)
			end

			data = gSpiritJobManager:GetCurJobId()

			self:CheckIsPoliceJob(data)
		end)
	else
		self:CheckIsPoliceJob(data)
	end
end

function PoliceJobManager:OnSkipNext(messageId)
	self.panelMgr:OnSkipNext(messageId)
end

function PoliceJobManager:CheckIsPoliceJob(data, isActive)
	data = data or 0
	local cfg = LTConfig.UrbanJobConfig.GetConfig(data)

	if (cfg and cfg.JobClass == JobClassConfig.Police or isActive) and not self.fakeActive then
		if not self.isPoliceJob then
			self.isPoliceJob = true
		end

		gTaskUtils:OpenTaskGuideCurTab(gTaskUtils.TaskGuideSubPanel.Police)
	elseif self.isPoliceJob then
		self.isPoliceJob = false

		gTaskUtils:HandleTaskGuideClose()
		gTaskUtils.TryShowNewestMainTaskGuide()
	end

	self.containPoliceJob = gSpiritJobManager:CheckContainJobClassId(LTConfig.UrbanJobJobClassConfig.Police)

	self:PoliceJobMissionStateChange(self.fakeActive, self.isPoliceJob)
end

function PoliceJobManager:SendMessageToPanel(callback)
	if not self.panelIsRegister then
		table.insert(self.panelCallBack, callback)
	else
		callback()
	end
end

function PoliceJobManager:PoliceTaskRecover(id, eventId)
	if not gTaskUtils:GetTaskGuideCurType() or gTaskUtils:GetTaskGuideCurType() ~= gTaskUtils.TaskGuideSubPanel.Police then
		gTaskUtils:OpenTaskGuideCurTab(gTaskUtils.TaskGuideSubPanel.Police)
	end

	self:SendMessageToPanel(function ()
		gMessageManager:SendMessage(gEventConstants.POLICE_TASK_TO_DOING, {
			id = id,
			eventId = eventId
		})
	end)
end

function PoliceJobManager:IsPanelShow()
	return self.isPoliceJob and not self.fakeActive
end

function PoliceJobManager:StartFakeTask(_, data)
	gPoliceJobManager.isFakeTaskPanel = data == nil or data.isFakeTaskPanel

	if not self.panelIsRegister then
		local function fakeCallBack()
			gTaskUtils:OpenTaskGuideCurTab(gTaskUtils.TaskGuideSubPanel.Police)
			gStoreManager:GetStoreGroup("PoliceTaskPanelStore"):FakePolicePanelEvent(data)
		end

		table.insert(self.panelCallBack, fakeCallBack)
		self:JobMissionStateChange(_, {
			force = true,
			active = true,
			job = JobClassConfig.Police
		})
	else
		gTaskUtils:OpenTaskGuideCurTab(gTaskUtils.TaskGuideSubPanel.Police)
		gStoreManager:GetStoreGroup("PoliceTaskPanelStore"):FakePolicePanelEvent(data)
	end
end

function PoliceJobManager:ExecuteCallback()
	for _, func in pairs(self.panelCallBack) do
		func()
	end

	self.panelCallBack = {}
end

function PoliceJobManager:StartPoliceJobWithFakeTaskCallBack(data)
	if not gSpiritJobManager:CheckIsCurrentjob(JobClassConfig.Police) then
		gClientToGameDelegate:AskStartJob(JobClassConfig.Police).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			gPoliceJobManager:StartFakeTask(gEventConstants.FAKE_POLICE_PANEL_STATE_EVENT, data)
		end
	else
		gPoliceJobManager:StartFakeTask(gEventConstants.FAKE_POLICE_PANEL_STATE_EVENT, data)
	end
end

function PoliceJobManager:StartPoliceJobByNode()
	local function func()
		gMessageManager:SendMessage(gEventConstants.JOB_MISSION_STATE_CHANGE, {
			active = false,
			job = JobClassConfig.Police
		})
		gMessageManager:SendMessage(gEventConstants.POLICE_BEGIN_FAKE_ACTIVE)
		gTaskUtils:OpenTaskGuideCurTab(gTaskUtils.TaskGuideSubPanel.Normal)
	end

	self:StartFakeTask(func)
end

function PoliceJobManager:OnSpiritChange(_, data)
	local spirit = gSpiritManager:GetSpirit(data)

	if spirit ~= nil then
		local jobId = spirit.SpiritInfo.SpiritJobInfo.CurrentJob

		self:CheckIsPoliceJob(jobId)
	end

	self.containPoliceJob = gSpiritJobManager:CheckContainJobClassId(LTConfig.UrbanJobJobClassConfig.Police)

	self:PoliceJobMissionStateChange(self.fakeActive, self.isPoliceJob)
end

function PoliceJobManager:CheckCurSpiritJob(switchType)
	if switchType == gSwitchSceneType.NewScene then
		local jobId = gSpiritJobManager:GetCurJobId()

		self:CheckIsPoliceJob(jobId)
	end
end

function PoliceJobManager:JobMissionStateChange(_, data)
	if data.job == JobClassConfig.Police and (not self.isFakeTaskPanel or data.force) then
		self:CheckIsPoliceJob(nil, data.active)
	end
end

function PoliceJobManager:StartPoliceFakeActive(_, isCloseFake)
	if not isCloseFake then
		local taskId = gTaskNodeManager:GetNowDoingTask()
		local eventInfo = gTaskNodeManager:GetTaskLineByTask(taskId)

		if not table.isNilOrEmpty(eventInfo) then
			self.fakeJobEvent = eventInfo.TaskLineId

			self:PoliceJobMissionStateChange(true, self.isPoliceJob)
		end
	else
		self.fakeJobEvent = 0

		self:PoliceJobMissionStateChange(false, self.isPoliceJob)
	end
end

function PoliceJobManager:EventStateChange(_, data)
	if self.fakeJobEvent == data.eventId and data.state ~= TaskEventState.Accepted and self.fakeActive then
		gClientToGameDelegate:AskFinishJob().Callback = function (err)
			if err ~= MessageConfig.Ok then
				print_error("AskFinishJob Fail", err)

				return
			end

			self.fakeJobEvent = 0

			self:PoliceJobMissionStateChange(false, self.isPoliceJob)
		end
	end
end

function PoliceJobManager.OnUnitBeAttacked(eventId, pid)
	if pid then
		if gPoliceJobManager.currentStage == gPoliceJobManager.POLICE_STAGE.EXAMINE then
			gPoliceJobManager.examineMgr:OnUnitBeAttacked(pid)
		elseif gPoliceJobManager.currentStage == gPoliceJobManager.POLICE_STAGE.ESCORT then
			gPoliceJobManager.escortMgr:OnUnitBeAttacked(pid)
		elseif gPoliceJobManager.cs:TrySetNpcExitState(pid, gPoliceJobManager.CS_EXIT_STATE.NONE) then
			gClientToGameDelegate:AskPoliceExitEscortOrExam(pid).Callback = function (err)
				if err ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end
			end
		end
	end
end

function PoliceJobManager.OnUnitBeHurt(eventId, data)
	data = data:ToTable()
	local pid = data.HitPid

	if pid then
		if gPoliceJobManager.currentStage == gPoliceJobManager.POLICE_STAGE.EXAMINE then
			gPoliceJobManager.examineMgr:OnUnitBeAttacked(pid)
		elseif gPoliceJobManager.currentStage == gPoliceJobManager.POLICE_STAGE.ESCORT then
			gPoliceJobManager.escortMgr:OnUnitBeAttacked(pid)
		elseif gPoliceJobManager.cs:TrySetNpcExitState(pid, gPoliceJobManager.CS_EXIT_STATE.NONE) then
			gClientToGameDelegate:AskPoliceExitEscortOrExam(pid).Callback = function (err)
				if err ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end
			end
		end
	end
end

function PoliceJobManager.OnUnitBeDestroy(eventId, pid)
	if pid then
		if gPoliceJobManager.currentStage == gPoliceJobManager.POLICE_STAGE.EXAMINE then
			gPoliceJobManager.examineMgr:OnUnitBeDestroy(pid)
		elseif gPoliceJobManager.currentStage == gPoliceJobManager.POLICE_STAGE.ESCORT then
			gPoliceJobManager.escortMgr:OnUnitBeDestroy(pid)
		end
	end
end

function PoliceJobManager.OnBeginPortal(eventId)
	if gPoliceJobManager.currentStage == gPoliceJobManager.POLICE_STAGE.EXAMINE then
		gPoliceJobManager.examineMgr:ExitByBadReason(true)
	elseif gPoliceJobManager.currentStage == gPoliceJobManager.POLICE_STAGE.ESCORT then
		gPoliceJobManager.escortMgr:OnBeginPortal()
	end
end

function PoliceJobManager.OnAfterSwitchScene(eventId, switchType)
	gPoliceJobManager:OnAfterSwitchSceneInternal(switchType)
end

function PoliceJobManager.OnTimeLineStart()
	gPoliceJobManager:OnTimeLineStartInternal()
end

function PoliceJobManager:OnTimeLineStartInternal()
	if self.currentStage == self.POLICE_STAGE.EXAMINE then
		self.examineMgr:ExitByBadReason()
	elseif self.currentStage == self.POLICE_STAGE.ESCORT then
		self.escortMgr:OnBeginTimeline()
	end
end

function PoliceJobManager:OnAfterSwitchSceneInternal(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self.waitReturnInvalidVehicleFineDialog = false

		self:ChangePoliceStage(self.POLICE_STAGE.NONE)
		self:CheckCurSpiritJob(switchType)
		self.examineMgr:ClearStatus()
		self.escortMgr:ClearStatus()
	end
end

function PoliceJobManager.OnBeforeSwitchScene(eventId, switchType)
	gPoliceJobManager:OnBeforeSwitchSceneInternal(eventId, switchType)
end

function PoliceJobManager:OnBeforeSwitchSceneInternal(eventId, switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self.fakeActive = false
		self.isPoliceJob = false
		self.isFakeTaskPanel = nil
		self.panelCallBack = {}

		self:ChangePoliceStage(self.POLICE_STAGE.NONE)
		self:StopWaitVehicleOutwardSignal()
		self.examineMgr:ClearStatus()
		self.escortMgr:ClearStatus()

		if self.refreshTimer then
			self.refreshTimer:Stop()

			self.refreshTimer = nil
		end
	end
end

function PoliceJobManager:PoliceJobMissionStateChange(fakeActive, isPoliceJob)
	if self.isDebug then
		print_notice("PoliceJobManager PoliceJobMissionStateChange containPoliceJob " .. tostring(self.containPoliceJob))
	end

	self.fakeActive = fakeActive

	if fakeActive then
		self.isPoliceJob = true
	else
		self.isPoliceJob = isPoliceJob
	end

	self:ChangeCsJobManagerDuty()
end

function PoliceJobManager:OpenPoliceEndPanel(spiritId, serviceData, stopPatrol)
	if not self.fakeActive and stopPatrol then
		gNewPopupManager:PushPopup(LTConfig.PopupConfig.PoliceEnd, {
			spiritId = spiritId,
			serviceData = serviceData
		})
	end
end

function PoliceJobManager:CheckNeedPoliceInfo()
	if self.containPoliceJob then
		local isInDue = self.panelMgr:CheckIsInViolation()

		return isInDue
	end

	return false
end

function PoliceJobManager:ChangeCsJobManagerDuty()
	if self.dutyDisable[self.currentStage] or self.examineMgr.stateTreePlayerInExamine then
		self.cs:SetIsOnDuty(false)
	else
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

		if gGameSwitch.EnablePoliceJobStoryLegacy then
			self.cs:SetHasPoliceJob_Story(self.containPoliceJob and not isInDue)
		end

		self.cs:SetIsOnDuty(self.containPoliceJob and not isInDue)
		gMessageManager:SendMessage(gEventConstants.POLICE_SWITCH_POLICE_INFO)
	end
end

function PoliceJobManager:RefreshPoliceStage()
	if self.isDebug then
		print_notice("PoliceJobManager : RefreshPoliceStage")
	end

	self:ChangeCsJobManagerDuty()
end

function PoliceJobManager:ChangePoliceStage(newStage)
	if self.isDebug then
		print_notice("PoliceJobManager : Change to stage, ", newStage)
	end

	self.currentStage = newStage

	self:ChangeCsJobManagerDuty()
	self.cs:ChangePlayStage(newStage)
end

function PoliceJobManager:IsInStage(Stage)
	return self.currentStage == Stage
end

function PoliceJobManager:GetEscortNpcInSeat(vehicleId, seatIndex)
	for k, v in pairs(self.npcStatusDict) do
		if vehicleId == v.vehicleId and v.seatIndex == seatIndex then
			return k
		end
	end

	return nil
end

function PoliceJobManager:SetNpcExitState(pid, state)
	if pid then
		self.cs:SetNpcExitState(pid, state)
	end
end

function PoliceJobManager:TrySetNpcExitState(pid, state)
	if pid then
		return self.cs:TrySetNpcExitState(pid, state)
	end

	return false
end

function PoliceJobManager:HandleEventFromCs(signal)
	self.actionMgr:HandleEventFromCs(signal)
end

function PoliceJobManager:CheckIsSearchCar(interactMenuState, vehicleId, seatIndex)
	if self.escortMgr:CheckCarEscort(interactMenuState, vehicleId, seatIndex) then
		return true
	end

	return self.searchCarMgr:CheckIsSearchCar(interactMenuState, vehicleId, seatIndex)
end

function PoliceJobManager:SyncPoliceQuestionInfo(policeQuestionInfo)
	self.examineMgr:SyncPoliceQuestionInfo(policeQuestionInfo)
end

function PoliceJobManager:CheckPlayOpenOrCloseDoorAnim(cfg, isOpen)
	self.searchCarMgr:CheckPlayOpenOrCloseDoorAnim(cfg, isOpen)
end

function PoliceJobManager:EnterPoliceExamineBySpoon(targetPid, customFines, customOptions, useCustomDialogs, guideOptions, guideIconId, askDialogId, hideLeaveBtn, hideEscortLeaveBtn, hideSuggestion)
	local customFinesTable = customFines:ToTable()
	local customOptionsTable = customOptions:ToTable()
	local guideOptionsTable = guideOptions:ToTable()
	local data = {
		calledInSpoon = true,
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

	if gGameSwitch.EnablePoliceJobStoryLegacy then
		gPoliceJobManager.examineMgr:PrepareDataFromSpoon_Story(data)
	else
		gPoliceJobManager.examineMgr:EnterPoliceExamine(data)
	end
end

function PoliceJobManager:EnterPoliceEscortBySpoon(targetPid, hideEscortToExamineBtn, hideEscortLeaveBtn, hideEscortReleaseBtn, enterByTimeline, traceToNearestPoliceCar)
	local interact = enterByTimeline and LTConfig.PoliceExamInteractConfig.PoliceGuardEnterTL or LTConfig.PoliceExamInteractConfig.EscortTransfer
	local data = {
		reactionId = 22001,
		targetPid = targetPid,
		hideEscortToExamineBtn = hideEscortToExamineBtn,
		hideEscortLeaveBtn = hideEscortLeaveBtn,
		hideEscortReleaseBtn = hideEscortReleaseBtn,
		reactDirectly = enterByTimeline,
		interact = interact,
		traceToNearestPoliceCar = traceToNearestPoliceCar
	}

	if gGameSwitch.EnablePoliceJobStoryLegacy then
		self.escortMgr:EnterEscort_Story(data)
	else
		self.escortMgr:EnterEscort(data)
	end
end

function PoliceJobManager:EnterPoliceEscort(targetPid)
	self.escortMgr:EnterEscort({
		targetPid = targetPid,
		interact = LTConfig.PoliceExamInteractConfig.EscortTransfer
	})
end

function PoliceJobManager:EnterPoliceEscortByPounce(targetPid)
	self.escortMgr:EnterEscort({
		reactionId = 24001,
		reactDirectly = true,
		targetPid = targetPid,
		interact = LTConfig.PoliceExamInteractConfig.FallDownEscort
	})
end

function PoliceJobManager:EnterPoliceEscortByBeg(targetPid)
	self.escortMgr:EnterEscort({
		reactionId = 23001,
		reactDirectly = true,
		targetPid = targetPid,
		interact = LTConfig.PoliceExamInteractConfig.BegEscort
	})
end

function PoliceJobManager:EnterPoliceEscortByLieDown(targetPid)
	self.escortMgr:EnterEscort({
		reactionId = 23002,
		reactDirectly = true,
		targetPid = targetPid,
		interact = LTConfig.PoliceExamInteractConfig.LyingEscort
	})
end

function PoliceJobManager:OnDropPoliceJobExp(reward)
	self.examineMgr:OnDropPoliceJobExp(reward)
end

function PoliceJobManager:OnDropPoliceReturnInvalidVehicleFine()
	gNewPopupManager:SetPause(true)

	local fineFailDialog = LTConfig.PoliceConfig.FineFailDialog

	if fineFailDialog > 0 then
		gDialogManager:ShowGeneralDialog(fineFailDialog, gDialogSource.Police, nil, nil, function (_, _, state, nextDialogId)
			if nextDialogId == 0 and state == 0 then
				gNewPopupManager:SetPause(false)
			end
		end)
	else
		gNewPopupManager:SetPause(false)
	end
end

function PoliceJobManager:AddWaitForReactionCallback(callback, waitType)
	if self.waitForReactionCallback ~= nil then
		print_error("#NoCreateIssue PoliceJobManager:AddWaitForReactionCallback overwrite an existing callback")
	end

	self.waitForReactionCallback = callback
	self.waitType = waitType
end

function PoliceJobManager:ClearWaitForReactionCallback(waitType)
	if not waitType or self.waitType == waitType then
		self.waitForReactionCallback = nil
	end
end

function PoliceJobManager:SyncPoliceExamReaction(reactionId)
	local cfg = LTConfig.PoliceExamReactionConfig.GetConfig(reactionId)

	if not cfg then
		print_notice("PoliceJobManager 收到无效reaction id ", reactionId)
	end

	if self.isDebug and cfg then
		local text = nil

		if cfg.Exit == LTConfig.PoliceExamReactionConfig.ExitType.Battle then
			text = "fight"
		elseif cfg.Exit == LTConfig.PoliceExamReactionConfig.ExitType.Flee then
			text = "flee"
		elseif cfg.Exit == LTConfig.PoliceExamReactionConfig.ExitType.Exit then
			text = "exit"
		else
			text = "accept"
		end

		print_notice("#PoliceJobManager NoCreateIssue 警察职业收到 reaction " .. tostring(reactionId) .. "NPC " .. text .. " AnimaiontId:" .. tostring(cfg and cfg.AnimationCommand or 0))
	end

	if self.waitForReactionCallback then
		self.waitForReactionCallback(cfg)

		self.waitForReactionCallback = nil
	elseif self.isDebug then
		print_notice("#NoCreateIssue PoliceJobManager:SyncPoliceExamReaction no callback found, reactionId " .. tostring(reactionId))
	end
end

function PoliceJobManager:SwitchWeaponToHand()
	return
end

function PoliceJobManager:SwitchWeaponToCachedWeapon()
	return
end

function PoliceJobManager:RefreshVehicleMenu(state)
	return
end

function PoliceJobManager.IsUnitValid(unit)
	return unit ~= nil and not unit.IsDestroyed and not unit.IsDead
end

function PoliceJobManager:TraceToPoliceOffice()
	local pointId = LTConfig.PoliceConfig.ArrestDestination

	if pointId and pointId > 0 then
		gMapSubSystem_FunctionPoint:TryTraceByFunctionPointId(pointId)
	end
end

function PoliceJobManager:TraceToFirstPoliceCar(VehicleIds)
	if not self.escortMgr.traceToNearestPoliceCar then
		return
	end

	local idTable = VehicleIds and VehicleIds:ToTable()

	if idTable and #idTable > 0 then
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

function PoliceJobManager:CancelTraceToPoliceCar()
	if self.curTracePoliceCar then
		local vehicleId = self.curTracePoliceCar
		self.curTracePoliceCar = nil

		gMapSubSystem_Vehicle:RemoveMilkCar(vehicleId)
	end
end

function PoliceJobManager:StateTreePoliceExamineMoveFinish()
	self.examineMgr:StateTreePoliceExamineMoveFinish()
end

function PoliceJobManager:StateTreePoliceEscortMoveFinish()
	self.escortMgr:StateTreePoliceEscortMoveFinish()
end

function PoliceJobManager:StateTreePoliceEscortCarMoveFinish()
	self.escortMgr:StateTreePoliceEscortCarMoveFinish()
end

function PoliceJobManager:StateTreePoliceEscortToExamineFinish()
	self.escortMgr:StateTreePoliceEscortToExamineFinish()
end

function PoliceJobManager:StateTreeEscortNpc()
	self.escortMgr:StateTreeEscortNpc()
end

function PoliceJobManager:StateTreeEscortNpcFromVehicle()
	self.escortMgr:StateTreeEscortNpcFromVehicle()
end

function PoliceJobManager:StateTreeEscortNpcToVehicle()
	self.escortMgr:StateTreeEscortNpcToVehicle()
end

function PoliceJobManager:StateTreePoliceExitEscortFinish()
	self.escortMgr:OnStateTreeExitEscort()
end

function PoliceJobManager:StateTreePoliceExamineStateChange(targetState)
	self.examineMgr:StateTreePoliceExamineStateChange(targetState)
end

function PoliceJobManager:StateTreePoliceEnterEscortState()
	self.escortMgr:StateTreePoliceEnterEscortState()
end

function PoliceJobManager:OnPoliceStateExit(pid)
	return
end

function PoliceJobManager:GetCurrentExamineUnitPid()
	return (self.examineMgr.unit or {}).Pid
end

function PoliceJobManager:EnterPoliceExamineCs(param)
	param = param:ToTable()

	self.examineMgr:EnterPoliceExamine(param)
end

function PoliceJobManager:ReportMutiInteractCancel()
	if self.isDebug then
		print_notice("PoliceJobManager Report 双人交互异常结束")
	end

	if self.currentStage == self.POLICE_STAGE.EXAMINE then
		self.examineMgr:ReportMutiInteractCancel()
	elseif self.currentStage == self.POLICE_STAGE.ESCORT then
		self.escortMgr:ReportMutiInteractCancel()
	end
end

function PoliceJobManager:ReportMutiInteractPrepared()
	if self.isDebug then
		print_notice("PoliceJobManager Report 双人交互准备完成")
	end

	if self.currentStage == self.POLICE_STAGE.EXAMINE then
		self.examineMgr:ReportMutiInteractPrepared()
	end
end

function PoliceJobManager:PoliceEscortNpcToWard(targetPos)
	if self.isDebug then
		print_notice("PoliceJobManager PoliceTeleportNpcToward")
	end

	if not self.escortMgr.targetPid then
		return
	end

	if self.escortMgr.currentStage ~= self.escortMgr.ESCORT_STAGE.ESCORTING then
		if self.isDebug then
			print_notice("PoliceJobManager PoliceTeleportNpcToward, stage is not escorting. cur stage is " .. tostring(self.escortMgr.currentStage))
		end

		return
	end

	local npcUnit = SceneDataMgr.GetUnit(self.escortMgr.targetPid)

	if not npcUnit then
		return
	end

	local tlName, generalModelId, bodyType = nil
	local agentCfg = LTConfig.AgentConfig.GetConfig(npcUnit.ClientData.AgentId)

	if agentCfg and agentCfg.GeneralModelId > 0 then
		generalModelId = agentCfg.GeneralModelId
		local modelCfg = LTConfig.GeneralModelConfig.GetConfig(generalModelId)

		if modelCfg and modelCfg.BodyType > 0 then
			bodyType = modelCfg.BodyType
			tlName = self.typeToEscortToWardTLName[modelCfg.BodyType]
		end
	end

	if not tlName then
		print_error("PoliceJobManager teleport npc in ward failed!! Can not find timeline by body type. AgentCfgId " .. tostring(npcUnit.ClientData.AgentId) .. " generalModelId " .. tostring(generalModelId) .. " bodyType " .. tostring(bodyType))

		return
	end

	self:CheckWaitOutwardSignal()
	self.cs:TryStopMultiInteract()
	self.escortMgr:EscortNpcToWard()

	local tlData = gTimelineManager:Timeline_CreateTimelineData()
	local bindInfos = {}
	local npcBindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, self.escortMgr.targetPid, "fwnpc_A401058_p021_gm_actor", nil)

	table.insert(bindInfos, npcBindInfo)

	tlData.bindUnitInfos = bindInfos
	local pid = self.escortMgr.targetPid

	function tlData.onFinishCb()
		print_notice("PoliceEscortManager 押送进牢房TimeLine结束！")
		gPoliceJobManager:OnEscortNPCToWardTimelineFinished(pid)
	end

	gTimelineManager:Timeline_LoadAndPlay(tlName, tlData)
end

function PoliceJobManager:OnEscortNPCToWardTimelineFinished(pid)
	local success, pos, angle = self.cs:TryGetWardPositionAndAngle(nil, nil)

	if pid and success then
		if MyPlayerManager.PlayerUnit then
			pos.y = MyPlayerManager.PlayerUnit.Position.y + 0.1
		end

		gCS.PlayerTransitionJudge.ClearAllUpperActionTypes()

		gClientToGameDelegate:AskPoliceEscortNpc(pid).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end

			local npcUnit = SceneDataMgr.GetUnit(pid)

			if npcUnit then
				self.cs:TrySetNpcPositionAndAngle(npcUnit, Vector3.New(pos.x, pos.y, pos.z), angle)
			end
		end

		if self.isDebug then
			print_notice(string.format("PoliceJobManager teleport npc to pos(%f,%f,%f), angle (%f) success!", pos.x, pos.y, pos.z, angle))
		end
	elseif not success then
		print_error("PoliceJobManager teleport npc in ward failed!! TargetPos is invalid. ")
	elseif not pid then
		print_error("PoliceJobManager teleport npc in ward failed!! Escort npc target pid is invalid. ")
	end
end

function PoliceJobManager:OnSyncAgentPoliceExamData(agentId, data)
	self.examineMgr:OnSyncExamineData(agentId, data)
end

function PoliceJobManager:GetNPCOutwardSignal(inwardSignal)
	return inwardSignal + 10000
end

function PoliceJobManager:SetWaitNPCSignal(inwardSignal, npcPid)
	if self.curWaitOutwardSignal then
		self:OnAcceptNPCOutwardSignal(self.curWaitOutwardSignal)
	end

	self.curWaitOutwardSignal = self:GetNPCOutwardSignal(inwardSignal)
	self.curWaitSignalPid = npcPid

	self.cs:ListenNPCOutwardSignal(npcPid or 0)

	if self.isDebug then
		print_notice("PoliceJobManager SetWaitNPCSignal " .. tostring(inwardSignal))
	end
end

function PoliceJobManager:OnAcceptNPCOutwardSignal(outwardSignal)
	if self.isDebug then
		print_notice("PoliceJobManager OnAcceptNPCOutwardSignal " .. tostring(outwardSignal) .. " cur wait id " .. tostring(self.curWaitOutwardSignal))
	end

	if not self.curWaitOutwardSignal or outwardSignal ~= self.curWaitOutwardSignal then
		return
	end

	self.curWaitOutwardSignal = nil

	if self.currentWaitAnimationPid == self.curWaitSignalPid then
		if self.isDebug then
			print_notice("PoliceJobManager ReportPoliceExamCommandEnd reported to server. Task pid : " .. ulong.tostring(self.currentWaitAnimationPid) .. " wait signal " .. tostring(outwardSignal))
		end

		gClientToGameDelegate:ReportPoliceExamCommandEnd(self.currentWaitAnimationPid)

		if self.curWaitMultiInteractType then
			local unit = SceneDataMgr.GetUnit(self.curWaitSignalPid)

			if unit then
				self.cs:TryMultiInteract(self.curWaitMultiInteractType, MyPlayerManager.PlayerUnit, unit)
			end

			self.curWaitMultiInteractType = nil
		end
	end

	if self.currentStage == self.POLICE_STAGE.EXAMINE then
		self.examineMgr:ReportPoliceExamCommandEnd(outwardSignal, self.curWaitSignalPid)
	end

	self.curWaitSignalPid = nil

	self.cs:ListenNPCOutwardSignal(0)

	if self.waitVehicleOutwardSignal == outwardSignal then
		self.waitVehicleOutwardSignal = nil

		self.escortMgr:OnVehicleTaskEnd()
		self:StopWaitVehicleOutwardSignal()
	end

	self.waitVehicleOutwardSignal = nil
end

function PoliceJobManager:CheckWaitOutwardSignal()
	if self.curWaitOutwardSignal then
		self.cs:ListenNPCOutwardSignal(0)
		self:OnAcceptNPCOutwardSignal(self.curWaitOutwardSignal)

		self.curWaitOutwardSignal = nil
		self.curWaitSignalPid = nil
	end
end

function PoliceJobManager:CancelWaitOutwardSignal()
	if self.curWaitOutwardSignal then
		self.cs:ListenNPCOutwardSignal(0)

		self.curWaitOutwardSignal = nil
		self.curWaitSignalPid = nil
	end
end

function PoliceJobManager:StartWaitVehicleOutwardSignal(inwardSignal, pid)
	if self.waitVehicleOutwardSignal then
		self:OnAcceptNPCOutwardSignal(self.waitVehicleOutwardSignal)

		self.waitVehicleOutwardSignal = nil
	end

	if self.waitVehicleOutwardSignalTimer then
		self.waitVehicleOutwardSignalTimer:Stop()

		self.waitVehicleOutwardSignalTimer = nil
	end

	self:SetWaitNPCSignal(inwardSignal, pid)

	self.waitVehicleOutwardSignal = self.curWaitOutwardSignal

	if self.waitVehicleOutwardSignal then
		self.waitVehicleOutwardSignalTimer = Timer.New(function ()
			if self.waitVehicleOutwardSignal then
				self:OnAcceptNPCOutwardSignal(self.waitVehicleOutwardSignal)
			end

			self.waitVehicleOutwardSignalTimer = nil
		end, 10):Start()
	end

	if self.isDebug then
		print_notice("PoliceJobManager StartWaitVehicleOutwardSignal " .. tostring(inwardSignal))
	end
end

function PoliceJobManager:StopWaitVehicleOutwardSignal()
	if self.waitVehicleOutwardSignalTimer then
		self.waitVehicleOutwardSignalTimer:Stop()

		self.waitVehicleOutwardSignalTimer = nil
	end

	self.waitVehicleOutwardSignal = nil
end

function PoliceJobManager:SyncFakePersonRed(agentId, isRed)
	if self.isDebug then
		print_notice("PoliceJobManager : SyncFakePersonRed pid " .. ulong.tostring(agentId) .. "  isRed " .. tostring(isRed))
	end

	local unit = SceneDataMgr.GetUnit(agentId)

	if unit then
		if isRed then
			gCS.EffectMgr:PlayEffectsForUnit(unit, 53610851)
		else
			gCS.EffectMgr:StopEffectForUnit(agentId, 53610851)
		end
	end
end

function PoliceJobManager:OnAcceptNPCGetUpOutwardSignal()
	if self.isDebug then
		print_notice("PoliceJobManager OnAcceptNPCGetUpOutwardSignal")
	end

	if self.currentStage == self.POLICE_STAGE.EXAMINE then
		self.examineMgr:TriggerCachedGameplayEvent()
	end
end

function PoliceJobManager:OpenPanel_Story(pid)
	local selfUnit = MyPlayerManager.PlayerUnit
	local npcUnit = SceneDataMgr.GetUnit(pid)
	local success, interactMainPos, interactMainDir, interactCoPos, interactCoDir = L18.Gameplay.PoliceJobManager.TryGetMultiInteractPosAndDir(LTConfig.MultiInteractTypeConfig.Examine, selfUnit, npcUnit, nil, nil, nil, nil)
	self.examineMgr.enterExamData.npcTargetDir = interactCoDir

	gPanelManager:CheckShow(gPanelId.POLICE_INQUIRY_PANEL, self.examineMgr.enterExamData)
end

function PoliceJobManager:PrepareData_Story(pid)
	self.examineMgr:PrepareData_Story(pid)
end

function PoliceJobManager:CleanExamineData_Story()
	self.examineMgr:OnExitExamine()
end

function PoliceJobManager:ClosePanel_Story()
	gPanelManager:Close(gPanelId.POLICE_INQUIRY_PANEL)
end

function PoliceJobManager:VMSingal_Story(optionId, eventId)
	self.examineMgr:VMSingal_Story(optionId, eventId)
end

function PoliceJobManager:OnSectionEnable_Story(optionId)
	self.examineMgr:OnSectionEnable_Story(optionId)
end

function PoliceJobManager:OpenEscortPanel_Story(pid)
	self.escortMgr:EnterEscortFromExamine_Story(pid, true, false)
end

function PoliceJobManager:CloseEscortPanel_Story()
	self.escortMgr:ExitEscort_Story()
end

function PoliceJobManager:NeedGetUp_Story()
	return self.examineMgr:GetGetUpEvent() ~= nil
end

function PoliceJobManager:GetUseCustomData_Story()
	return self.examineMgr.attachData and self.examineMgr.attachData.useCustomDialogs
end

function PoliceJobManager:OnReceiveReaction_Story(reactionId)
	self.examineMgr:OnReceiveReaction(reactionId)
end

function PoliceJobManager:SetBlockInteract_Story(flag)
	self.examineMgr:SetBlockInteract_Story(flag)
end

function PoliceJobManager:OpenExamineCarFinePanel_Story(fineDict)
	local fineInfoDic = {}
	local fineList = nil

	if fineDict then
		local hasBuff = gBuffUtils.HasBuff(MyPlayerManager.PlayerUnit.Pid, 52810300)

		if hasBuff then
			fineList = {}
		end

		local allFine = {}
		local fineTable = fineDict:ToTable()

		for k, v in pairs(fineTable) do
			fineInfoDic[k] = {
				isFined = v
			}

			if hasBuff then
				table.insert(allFine, k)
			end
		end

		if hasBuff and #allFine > 0 then
			math.randomseed(os.time())

			local index = math.random(#allFine)
			local fineId = allFine[index]

			table.insert(fineList, fineId)
		end
	end

	gMainPhoneUtils.ShowPhoneAppContent({
		isExamineCar = true,
		showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.PoliceFine,
		fineInfoDict = fineInfoDic,
		fineList = fineList
	})
end

function PoliceJobManager:CheckAgentIsStandUp(unit)
	return self.examineMgr:CheckAgentIsStandUp(unit)
end

function PoliceJobManager:TraceToNewFleeCar(vehicleId)
	self.curTracedFleeVehicleId = vehicleId
	local element = gMapSubSystem_CommonGps:CreateOrGetRawGps(self.fleeCarGpsId, gRaidDataManager.RaidId)

	element:BindVehicle(vehicleId)
	element:SetViewMask(EMapViewMask.HudGps + EMapViewMask.MiniMap)

	element.mData.sIconId = 28000181
end

function PoliceJobManager:CancelTraceToFleeCar(vehicleId)
	if self.curTracedFleeVehicleId == vehicleId then
		self.curTracedFleeVehicleId = 0

		gMapSubSystem_CommonGps:RemoveCommonGps(self.fleeCarGpsId)
	end
end

gPoliceJobManager = PoliceJobManager
