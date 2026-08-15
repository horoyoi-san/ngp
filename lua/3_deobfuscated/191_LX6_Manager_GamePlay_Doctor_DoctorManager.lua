local M = gDoctorManager or {}
M.IsInit = M.IsInit or false
local MyPlayerManager = gCS.MyPlayerManager
local SceneDataMgr = gCS.SceneDataMgr

function M:OnInit()
	if self.IsInit then
		return
	end

	self.STAGE_TYPE = {
		TREATING = 1,
		ENTER_TREAT_ANIM = 3,
		WAIT_REACTION = 2,
		WAIT_TREAT = 0,
		QTE = 6,
		EXIT_TREAT_ANIM = 4,
		WAIT_EXIT = 5
	}
	self.PANEL_STAGE_TYPE = {
		SEARCH = 1,
		NORMAL = 0,
		TREAT = 2
	}
	self.TREAT_ACTION = {
		INJECTION = 2,
		CPR = 3,
		AED = 4,
		GIVE_MEDICINE = 1
	}
	self.VM_TYPE = {
		END_QTE = 2,
		START_QTE = 1
	}
	self.EXIT_INWARD = {
		SUCCESS = 1062,
		FAILED = 1063
	}
	self.cureInteract = {
		[self.TREAT_ACTION.GIVE_MEDICINE] = 4,
		[self.TREAT_ACTION.INJECTION] = 3,
		[self.TREAT_ACTION.CPR] = 2,
		[self.TREAT_ACTION.AED] = 5
	}
	self.currentStage = self.STAGE_TYPE.ENTER_TREAT_ANIM
	self.currentPanelStage = self.PANEL_STAGE_TYPE.NORMAL
	self.isDebug = true
	self.cureLimit = 0
	self.cureTimes = 0
	self.isInQTE = false
	self.successQTENum = 0
	self.currentQTENum = 0
	self.totalQTENum = 0
	self.sendQTEInteract = false
	self.qteInteractId = 0
	self.IsCheckDisease = false
	self.qteTime = 2
	self.qteAniSpeed = 1
	self.showResPercent = 1
	self.needReportFinished = false

	gMessageManager:AddMessageListener(gEventConstants.SYNC_CURRENT_SPIRIT, self.OnSyncBadgeInfo)
	gMessageManager:AddMessageListener(gEventConstants.LING_GROUP_CHANGED, self.OnSyncBadgeInfo)
	gMessageManager:AddMessageListener(gEventConstants.ON_SYNC_URBAN_BADGEINFO, self.OnSyncBadgeInfo)
	gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, self.OnBeforeSwitchScene)
	gMessageManager:AddMessageListener(gEventConstants.NPC_HUD_ROOT_READY, self.OnNpcHudRootReady)

	self.cs = L18.Gameplay.DoctorManager.Instance
	self.IsInit = true
end

function M.OnSyncBadgeInfo(eventId, data)
	if gSpiritManager:GetSpirit(gSpiritManager:GetCurFirstSpiritTid()) then
		local isWork = gSpiritJobManager:CheckCurSpiritContainBadge(LTConfig.DoctorConfig.DoctorBadge)

		gDoctorManager:DoctorJobMissionStateChange(isWork)
	end
end

function M.OnBeforeSwitchScene(eventId, switchType)
	gDoctorManager.currentStage = gDoctorManager.STAGE_TYPE.ENTER_TREAT_ANIM
	gDoctorManager.currentPanelStage = gDoctorManager.PANEL_STAGE_TYPE.NORMAL
end

function M.OnNpcHudRootReady(eventId, pid)
	gDoctorManager:CheckAddVirusIcon(pid)
end

function M:CheckAddVirusIcon(pid)
	local unit = SceneDataMgr.GetUnit(pid)

	if unit and not unit.IsDestroyed then
		local module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(unit)

		if module and module.Component and module.VirusId > 0 then
			local cfg = LTConfig.DoctorSpecialVirusConfig.GetConfig(module.VirusId)

			if cfg and cfg.VirusIcon > 0 then
				gHudMgr:AddCommonHeadIcon(pid, cfg.VirusIcon)
			end
		end
	end
end

function M:AddVirusIcon(pid, VirusId)
	if pid and VirusId > 0 then
		local cfg = LTConfig.DoctorSpecialVirusConfig.GetConfig(VirusId)

		if cfg and cfg.VirusIcon > 0 then
			gHudMgr:AddCommonHeadIcon(pid, cfg.VirusIcon)
		end
	end
end

function M:RemoveVirusIcon(pid)
	if pid then
		gHudMgr:RemoveCommonHeadIcon(pid)
	end
end

function M:DoctorJobMissionStateChange(active)
	self.isDoctorJob = active == true

	self:ChangeCsJobManagerDuty()
end

function M:ChangeCsJobManagerDuty()
	self.cs:SetIsOnDuty(self.isDoctorJob)

	if self.isDebug then
		print_notice("DoctorManager ChangeCsJobManagerDuty " .. tostring(self.isDoctorJob))
	end
end

function M:SetStage(stage)
	if stage ~= self.currentStage then
		self.currentStage = stage

		self:RefreshPanelBtn()
	end
end

function M:IsInStage(stage)
	return self.currentStage == stage
end

function M:SetPanelStage(stage)
	if stage ~= self.currentPanelStage then
		self.currentPanelStage = stage

		self:RefreshPanelBtn()
	end
end

function M:IsInPanelStage(stage)
	return self.currentPanelStage == stage
end

function M:OnTreatBtnClick(pid)
	local unit = SceneDataMgr.GetUnit(pid)

	if not unit then
		print_error("DoctorManager treat npc pid is invalid!")
	end

	self.currentTreatPid = pid
	self.exitSignal = nil
	self.waitOutwardSignal = nil
	self.stateTreeExitDoctor = false
	self.interruptCure = false

	gClientToGameDelegate:AskDoctorCheck(pid).Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			self.currentTreatPid = pid
			self.needReportFinished = false

			gDoctorManager:OnReceiveDoctorCheckData(data)
		else
			self.currentTreatPid = nil

			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

function M:GetCurrentDiseases()
	return self.currentDisease
end

function M:GetTreatPercent()
	if self.totalTreatmentCount > 0 then
		return math.max(0, math.min(1, self.curTreatmentCount / self.totalTreatmentCount))
	end

	return 0
end

function M:IsTreatmentEnable(id)
	return self.treatActionUnlockState[id]
end

function M:GetCurrentDiseaseLevel()
	return self.currentDiseaseLevel
end

function M:OnReceiveDoctorCheckData(data)
	if not data or not self.currentTreatPid then
		return
	end

	self:SetStage(self.STAGE_TYPE.ENTER_TREAT_ANIM)

	self.cureLimit = data.CureLimit
	self.cureTimes = 0
	self.IsCheckDisease = false
	self.successQTENum = 0
	self.currentQTENum = 0
	self.totalQTENum = 0
	self.sendQTEInteract = false
	self.qteInteractId = 0
	self.qteTime = LTConfig.DoctorConfig.QTETime
	self.qteAniSpeed = LTConfig.DoctorConfig.QTEAniSpeed
	self.showResPercent = 1

	self:StartTreatment()
	self:RefreshCurrentDisease()
end

function M:RefreshCurrentDisease(interactId, qteNum)
	self.totalTreatmentCount = 0
	self.currentDisease = {}
	self.currentDiseaseLevel = 0
	self.curTreatmentCount = 0
	local treatPercent = 1
	local treatDiseaseAndCount = nil

	if interactId and qteNum then
		local interactCfg = LTConfig.DoctorCureInteractConfig.GetConfig(interactId)

		if interactCfg and interactCfg.TreatmentID and interactCfg.TreatmentID > 0 then
			local treatmentConfig = LTConfig.DoctorTreatmentConfig.GetConfig(interactCfg.TreatmentID)

			if treatmentConfig then
				treatDiseaseAndCount = treatmentConfig.TreatDiseaseAndCount

				if qteNum and treatmentConfig.QTETimes > 0 then
					treatPercent = qteNum / treatmentConfig.QTETimes
				end
			end
		end
	end

	if self.currentTreatPid then
		local unit = SceneDataMgr.GetUnit(self.currentTreatPid)

		if unit then
			local module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(unit)

			if module and module.Component and module.Diseases then
				self.currentDisease = module.Diseases:ToTable()

				for k, v in pairs(self.currentDisease) do
					if v > 0 then
						self.totalTreatmentCount = self.totalTreatmentCount + v
						local cfg = LTConfig.DoctorDiseaseConfig.GetConfig(k)

						if cfg and self.currentDiseaseLevel < cfg.DiseasePriority then
							self.currentDiseaseLevel = cfg.DiseasePriority
						end
					end
				end

				if treatDiseaseAndCount then
					for i = 1, #treatDiseaseAndCount do
						local diseaseAndCount = treatDiseaseAndCount[i]
						local oriCount = self.currentDisease[diseaseAndCount.disease]

						if oriCount then
							local treatCount = math.floor(diseaseAndCount.count * treatPercent)

							if oriCount <= treatCount then
								self.curTreatmentCount = self.curTreatmentCount + oriCount
								self.currentDisease[diseaseAndCount.disease] = nil
							else
								self.curTreatmentCount = self.curTreatmentCount + math.max(treatCount, 0)
							end
						end
					end
				end
			end
		end
	end
end

function M:ShowEndDialog()
	if self.waitDialogId and self.waitDialogId > 0 then
		gDialogManager:ShowGeneralDialog(self.waitDialogId, gDialogSource.Doctor)

		self.waitDialogId = nil
	end
end

function M:RefreshPanelBtn()
	if self.panel and self.panel.isShow then
		local store = gStoreManager:GetStoreGroup("GameplayHudProPanelStore")

		if store then
			store:RefreshBtnState()
		end
	end
end

function M:ShowPanelTreatProcess()
	if self.panel and self.panel.isShow then
		self.panel:ShowTreatProcess(function ()
			if self.panel and self.panel.isShow then
				self.panel:ShowTreatResultInfo()
			end
		end)
	end
end

function M:StartTreatment()
	self.showResPercent = 1

	self:SetStage(self.STAGE_TYPE.WAIT_REACTION)
	self:AddWaitForReactionCallback(function (reactionCfg)
		self:SetStage(self.STAGE_TYPE.ENTER_TREAT_ANIM)
		self:CommonReactionDeal(reactionCfg)
		self.cs:TreatNpc(self.currentTreatPid)
		gCS.BaseUnitUtils.ChangeAuthorityState(self.currentTreatPid, LX6.Units.Module.AuthorityState.Interacting, true)
	end)

	gClientToGameDelegate:AskDoctorCure(self.currentTreatPid, 1).Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			self.waitDialogId = data

			if self.isDebug and self.waitDialogId and self.waitDialogId > 0 then
				print_notice("Doctor manager 收到对话id " .. tostring(self.waitDialogId))
			end
		else
			self:ClearWaitForReactionCallback()
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

function M:DoCureInteract(cureInteractId)
	self.showResPercent = 1

	self:SetStage(self.STAGE_TYPE.WAIT_REACTION)
	self:AddWaitForReactionCallback(function (reactionCfg)
		self:SetStage(self.STAGE_TYPE.TREATING)
		self:CommonReactionDeal(reactionCfg)
	end)
	self:RefreshCurrentDisease(cureInteractId, self.successQTENum)

	gClientToGameDelegate:AskDoctorCure(self.currentTreatPid, cureInteractId, self.successQTENum).Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			self.cureTimes = self.cureTimes + 1
			self.waitDialogId = data

			if self.isDebug and self.waitDialogId and self.waitDialogId > 0 then
				print_notice("Doctor manager 收到对话id " .. tostring(self.waitDialogId))
			end

			self:ShowPanelTreatProcess()

			if self.cureLimit <= self.cureTimes then
				local store = gStoreManager:GetStoreGroup("GameplayHudProPanelStore")

				if store and store.bindData.btnExit then
					store.bindData.btnExit:SetActive(false)
				end
			end

			if self.panel and self.panel.isShow then
				self.panel:RefreshCureNum()
			end
		else
			self:RefreshCurrentDisease()
			self:SetStage(self.STAGE_TYPE.WAIT_TREAT)
			self:ClearWaitForReactionCallback()
			self:RefreshPanelBtn()
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end

	if self.isDebug then
		print_notice("Doctor manager qte 成功次数 " .. tostring(self.successQTENum))
	end

	if self.panel and self.panel.isShow then
		self.panel:RefreshCureNum()
	end
end

function M:ExitCure()
	if self.currentStage == self.STAGE_TYPE.WAIT_TREAT then
		self:DoExit()
	else
		self:SetStage(self.STAGE_TYPE.WAIT_EXIT)
	end
end

function M:BackBtnExitCure()
	if self.currentStage ~= self.STAGE_TYPE.WAIT_TREAT then
		self.interruptCure = true
	end
end

function M:DoExit()
	self.showResPercent = 1

	self:SetStage(self.STAGE_TYPE.WAIT_REACTION)
	self:AddWaitForReactionCallback(function (reactionCfg)
		self:SetStage(self.STAGE_TYPE.EXIT_TREAT_ANIM)
		self:CommonReactionDeal(reactionCfg, true)
	end)

	gClientToGameDelegate:AskDoctorCure(self.currentTreatPid, 6).Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			self.waitDialogId = data

			if self.isDebug and self.waitDialogId and self.waitDialogId > 0 then
				print_notice("Doctor manager 收到对话id " .. tostring(self.waitDialogId))
			end
		else
			self:ClearWaitForReactionCallback()
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if self.panel and self.panel.isShow then
				gPanelManager:Close(gPanelId.DOCTOR_GAMEPLAY_PANEL)
			end

			self:StopQTETimer()
		end
	end
end

function M:CommonReactionDeal(reactionCfg, exit)
	self.exitSignal = nil

	if not reactionCfg then
		return
	end

	if reactionCfg.IsEndMultiInteract then
		self.cs:TryStopMultiInteract()
	end

	if reactionCfg.MultiInteractType and reactionCfg.MultiInteractType > 0 then
		local unit = SceneDataMgr.GetUnit(self.currentTreatPid)

		if unit then
			self.cs:TryMultiInteract(reactionCfg.MultiInteractType, MyPlayerManager.PlayerUnit, unit)
		end
	end

	if reactionCfg.GameplayEvent and reactionCfg.GameplayEvent > 0 then
		gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, reactionCfg.GameplayEvent)

		self.needReportFinished = true
	end

	if reactionCfg.NPCGameplaySignal and reactionCfg.NPCGameplaySignal > 0 then
		local unit = SceneDataMgr.GetUnit(self.currentTreatPid)

		if unit then
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, reactionCfg.NPCGameplaySignal)
		end
	end

	if reactionCfg.Exit ~= LTConfig.DoctorCureReactionConfig.ExitType.None then
		self:OnTreatmentExit()

		if not exit then
			local signalCfg = LTConfig.GameplaySignalInwardConfig.GetConfig(self.EXIT_INWARD.SUCCESS)

			if signalCfg then
				self:SetWaitNPCSignal(signalCfg.Outward)
			end
		end

		local store = gStoreManager:GetStoreGroup("GameplayHudProPanelStore")

		if store and store.bindData.btnExit then
			store.bindData.btnExit:SetActive(false)
		end
	end

	self.showResPercent = reactionCfg.ShowResPercent or 0.8
end

function M:OnTreatmentExit()
	self:ShowPanelTreatProcess()
end

function M:AddWaitForReactionCallback(callback)
	if self.waitForReactionCallback ~= nil then
		print_notice("#NoCreateIssue DoctorManager:AddWaitForReactionCallback overwrite an existing callback")
	end

	self.waitForReactionCallback = callback
end

function M:ClearWaitForReactionCallback()
	self.waitForReactionCallback = nil
end

function M:SyncAgentCureReaction(reactionId)
	local cfg = LTConfig.DoctorCureReactionConfig.GetConfig(reactionId)

	if not cfg then
		print("DoctorManager 收到无效reaction id ", reactionId)
	end

	if self.isDebug and cfg then
		print_notice("#DoctorManager NoCreateIssue 医生职业收到 reaction " .. tostring(reactionId) .. "Player Event" .. tostring(cfg and cfg.GameplayEvent or 0) .. " NPCGameplaySignal:" .. tostring(cfg and cfg.NPCGameplaySignal or 0))
	end

	if self.waitForReactionCallback then
		self.waitForReactionCallback(cfg)

		self.waitForReactionCallback = nil
	elseif self.isDebug then
		print_notice("#NoCreateIssue DoctorManager:SyncAgentCureReaction no callback found, reactionId " .. tostring(reactionId))
	end
end

function M:StateTreeDoctorEnterWaitTreatment()
	if self.panel and self.panel.isShow then
		self.panel.actionPanelStore:TriggerWaitFunc()
	end

	if self.currentStage == self.STAGE_TYPE.WAIT_EXIT then
		self:DoExit()
	else
		self:SetStage(self.STAGE_TYPE.WAIT_TREAT)

		if self.cureLimit <= self.cureTimes then
			self.exitSignal = self.EXIT_INWARD.FAILED

			self:DoExit()
		else
			self:RefreshPanelBtn()
		end

		if self.exitSignal then
			local signal = self.exitSignal
			self.exitSignal = nil
			local unit = SceneDataMgr.GetUnit(self.currentTreatPid)

			if unit then
				gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, signal)
			end

			local signalCfg = LTConfig.GameplaySignalInwardConfig.GetConfig(signal)

			if signalCfg then
				self:SetWaitNPCSignal(signalCfg.Outward)
			end
		end

		self:ReportCommandFinish()
	end
end

function M:ReportCommandFinish()
	if self.needReportFinished then
		self.needReportFinished = false

		if self.isDebug then
			print_notice("DoctorManager ReportCommandFinish 上报医生动作结束" .. tostring(not self.interruptCure))
		end

		gClientToGameSceneDelegate:ReportDoctorCureReactionCommandFinish(self.currentTreatPid, not self.interruptCure)
	end
end

function M:SetWaitNPCSignal(outwardSignal)
	if self.waitOutwardSignal then
		self:OnAcceptNPCOutwardSignal(self.waitOutwardSignal)
	end

	self.waitOutwardSignal = outwardSignal

	if self.isDebug then
		print_notice("DoctorManager SetWaitNPCSignal " .. tostring(outwardSignal))
	end
end

function M:OnAcceptNPCOutwardSignal(outwardSignal)
	if self.isDebug then
		print_notice("DoctorManager OnAcceptNPCOutwardSignal " .. tostring(outwardSignal) .. " cur wait id " .. tostring(self.waitOutwardSignal))
	end

	if not self.waitOutwardSignal then
		return
	end

	if outwardSignal == self.waitOutwardSignal then
		self.waitOutwardSignal = nil

		if self.stateTreeExitDoctor then
			self:DoExitInternal()
		end
	end
end

function M:DoExitInternal()
	self.cs:SetListenGameplayOutwardSignal(false)

	if self.panel and self.panel.isShow then
		gPanelManager:Close(gPanelId.GAMEPLAY_HUD_PRO_PANEL)
	end

	self:ShowEndDialog()
	gCS.BaseUnitUtils.ChangeAuthorityState(self.currentTreatPid, LX6.Units.Module.AuthorityState.Interacting, false)
	self:StopQTETimer()

	if self.hideQTETimer then
		self.hideQTETimer:Stop()

		self.hideQTETimer = nil
	end

	self:ReportCommandFinish()
end

function M:StateTreeDoctorExit()
	self.stateTreeExitDoctor = true

	if self.exitSignal then
		local signal = self.exitSignal
		self.exitSignal = nil
		local unit = SceneDataMgr.GetUnit(self.currentTreatPid)

		if unit then
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, signal)
		end

		local signalCfg = LTConfig.GameplaySignalInwardConfig.GetConfig(signal)

		if signalCfg then
			self:SetWaitNPCSignal(signalCfg.Outward)
		end
	end

	if not self.waitOutwardSignal then
		self:DoExitInternal()
	end
end

function M:StateTreeDoctorMoveEnd()
	self:RefreshUnLockState()
	gPanelManager:CheckShow(gPanelId.GAMEPLAY_HUD_PRO_PANEL, {
		groupId = LTConfig.GameplayHudDescGroupConfig.DOCTOR,
		closeCallback = function ()
			gDoctorManager:ExitCure()
		end,
		backCallback = function ()
			gDoctorManager:BackBtnExitCure()
			gPanelManager:Close(gPanelId.GAMEPLAY_HUD_PRO_PANEL)
		end
	})
	self.cs:SetListenGameplayOutwardSignal(true)
end

function M:RefreshUnLockState()
	self.treatActionUnlockState = {}

	for _, value in pairs(self.TREAT_ACTION) do
		local enableState = false
		local cfg = LTConfig.DoctorTreatmentConfig.GetConfig(value)

		if cfg then
			if cfg.BadgeId and cfg.BadgeId > 0 then
				enableState = gSpiritJobManager:CheckCurSpiritContainBadge(cfg.BadgeId)
			else
				enableState = true
			end
		end

		self.treatActionUnlockState[value] = enableState
	end
end

function M:CheckSearchEnable()
	return self:IsInStage(self.STAGE_TYPE.WAIT_TREAT) and self:IsInPanelStage(self.PANEL_STAGE_TYPE.NORMAL)
end

function M:DoSearchAction()
	if self.panel and self.panel.isShow then
		self.showResPercent = 1
		local reactionCfg = LTConfig.DoctorCureReactionConfig.GetConfig(70101)

		if reactionCfg then
			self:SetStage(self.STAGE_TYPE.TREATING)
			self:CommonReactionDeal(reactionCfg)
			self.panel:ShowSearchResult(function ()
				self.panel:ShowNormalContent()
			end)
		end
	end
end

function M:CheckGiveMedicineEnable()
	return self:IsInStage(self.STAGE_TYPE.WAIT_TREAT) and self:IsInPanelStage(self.PANEL_STAGE_TYPE.NORMAL) and self.treatActionUnlockState[self.TREAT_ACTION.GIVE_MEDICINE]
end

function M:DoGiveMedicineAction()
	if self:IsInStage(self.STAGE_TYPE.WAIT_TREAT) then
		self:DoCureInteract(self.cureInteract[self.TREAT_ACTION.GIVE_MEDICINE])
	end
end

function M:CheckInjectEnable()
	return self:IsInStage(self.STAGE_TYPE.WAIT_TREAT) and self:IsInPanelStage(self.PANEL_STAGE_TYPE.NORMAL) and self.treatActionUnlockState[self.TREAT_ACTION.INJECTION]
end

function M:DoInjectAction()
	if self:IsInStage(self.STAGE_TYPE.WAIT_TREAT) then
		self:DoCureInteract(self.cureInteract[self.TREAT_ACTION.INJECTION])
	end
end

function M:CheckCPREnable()
	return self:IsInStage(self.STAGE_TYPE.WAIT_TREAT) and self:IsInPanelStage(self.PANEL_STAGE_TYPE.NORMAL) and self.treatActionUnlockState[self.TREAT_ACTION.CPR]
end

function M:DoCPRAction()
	if self:IsInStage(self.STAGE_TYPE.WAIT_TREAT) then
		self.qteInteractId = self.cureInteract[self.TREAT_ACTION.CPR]
		self.isInQTE = false
		self.successQTENum = 0
		self.currentQTENum = 0
		self.totalQTENum = 0
		self.sendQTEInteract = false
		local treatmentCfg = LTConfig.DoctorTreatmentConfig.GetConfig(self.TREAT_ACTION.CPR)

		if treatmentCfg then
			self.totalQTENum = treatmentCfg.QTETimes
		end

		gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.DoctorEnterCPRQTE)
		self:SetStage(self.STAGE_TYPE.QTE)
	end
end

function M:CheckAEDEnable()
	return self:IsInStage(self.STAGE_TYPE.WAIT_TREAT) and self:IsInPanelStage(self.PANEL_STAGE_TYPE.NORMAL) and self.treatActionUnlockState[self.TREAT_ACTION.AED]
end

function M:DoAEDAction()
	if self:IsInStage(self.STAGE_TYPE.WAIT_TREAT) then
		self.qteInteractId = self.cureInteract[self.TREAT_ACTION.AED]
		self.isInQTE = false
		self.successQTENum = 0
		self.currentQTENum = 0
		self.totalQTENum = 0
		self.sendQTEInteract = false
		local treatmentCfg = LTConfig.DoctorTreatmentConfig.GetConfig(self.TREAT_ACTION.AED)

		if treatmentCfg then
			self.totalQTENum = treatmentCfg.QTETimes
		end

		gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.DoctorEnterAEDQTE)
		self:SetStage(self.STAGE_TYPE.QTE)
	end
end

function M:StartTreatmentQTE()
	if self.currentQTENum < self.totalQTENum then
		self.currentQTENum = self.currentQTENum + 1
		self.isInQTE = true

		if self.panel and self.panel.isShow then
			self.panel:ShowTreatQTE()
		end

		self:StartQTETimer()
		LX6.Units.AnimationManager.SetStateSpeed(MyPlayerManager.PlayerUnit, 0, self.qteAniSpeed)
	elseif not self.sendQTEInteract and self.qteInteractId ~= 0 then
		self:SendQTEInteract()
		self:StopQTETimer()
	end
end

function M:EndTreatmentQTE()
	if self.isInQTE then
		self.isInQTE = false

		if self.panel and self.panel.isShow then
			self.panel:TreatQTEActionFailed()
		end

		LX6.Units.AnimationManager.SetStateSpeed(MyPlayerManager.PlayerUnit, 0, 1)
	end

	if self.totalQTENum <= self.currentQTENum and not self.sendQTEInteract and self.qteInteractId ~= 0 then
		self:SendQTEInteract()
	end
end

function M:OnQTEBtnClick()
	if self.isInQTE then
		self.isInQTE = false
		self.successQTENum = self.successQTENum + 1

		if self.panel and self.panel.isShow then
			self.panel:TreatQTEActionSuccess()
		end

		LX6.Units.AnimationManager.SetStateSpeed(MyPlayerManager.PlayerUnit, 0, 1)

		if self.currentQTENum == self.totalQTENum and not self.sendQTEInteract and self.qteInteractId ~= 0 then
			self:SendQTEInteract()
		end
	end
end

function M:SendQTEInteract()
	self:DoCureInteract(self.qteInteractId)

	self.sendQTEInteract = true
	self.successQTENum = 0
	self.qteInteractId = 0

	if self.hideQTETimer then
		self.hideQTETimer:Stop()

		self.hideQTETimer = nil
	end

	self.hideQTETimer = Timer.New(function ()
		if self.panel and self.panel.isShow then
			self.panel:HideTreatQTE()
		end

		self.hideQTETimer = nil
	end, 1):Start()
end

function M:StartQTETimer()
	if self.qteTimer then
		self.qteTimer:Stop()

		self.qteTimer = nil
	end

	self.qteTimer = Timer.New(function ()
		self:EndTreatmentQTE()

		self.qteTimer = nil
	end, self.qteTime):Start()
end

function M:StopQTETimer()
	if self.qteTimer then
		self.qteTimer:Stop()

		self.qteTimer = nil

		LX6.Units.AnimationManager.SetStateSpeed(MyPlayerManager.PlayerUnit, 0, 1)
	end
end

function M:HandleEventFromCs(vmType)
	if gDoctorManager.isDebug then
		print_notice("#DoctorManager 医生 收到VM信号 " .. tostring(vmType))
	end

	self:StartTreatmentQTE()
end

gDoctorManager = M
