if not gPoliceJobManager or not gPoliceJobManager.escortMgr then
	local PoliceEscortManager = {
		stateTreeEscortToVehicle = false,
		stateTreeEscortFromVehicle = false,
		debug_addEscortFromButtonToVehicle = false,
		debug_addEscortInButtonToVehicle = false,
		CanInteract = true,
		taskEscortVehicle = false,
		states = {
			LTConfig.UnitStateConfig.HideBattleUIJump,
			LTConfig.UnitStateConfig.ForbidChangeFightSpirit
		},
		ESCORT_STAGE = {
			ESCORT_TO_ANIMATION = 1,
			ESCORT_To_EXAMINE_ANIMATION = 3,
			ESCORTING = 0,
			ESCORT_FROM_ANIMATION = 2
		}
	}
end

local this = PoliceEscortManager
local PoliceJobUtils = L18.Gameplay.PoliceJobUtils
local MyPlayerManager = gCS.MyPlayerManager
local SceneDataMgr = gCS.SceneDataMgr

function PoliceEscortManager:EnterEscort(data)
	if gPoliceJobManager.currentStage ~= gPoliceJobManager.POLICE_STAGE.NONE then
		if gPoliceJobManager.isDebug then
			if gPoliceJobManager.currentStage == gPoliceJobManager.POLICE_STAGE.EXAMINE then
				print_notice("PoliceEscortManager 当前正在盘查中，进入押送失败！")
			elseif gPoliceJobManager.currentStage == gPoliceJobManager.POLICE_STAGE.ESCORT then
				print_notice("PoliceEscortManager 当前正在押送中，进入押送失败！")
			end
		end

		return
	end

	if not data.interact or data.interact == 0 then
		print_error("PoliceEscortManager: interactId is invalid!")

		return
	end

	local npcUnit = SceneDataMgr.GetUnit(data.targetPid)

	if not gPoliceJobManager.IsUnitValid(npcUnit) then
		print_error("PoliceEscortManager: InitScene npcUnit is nil!, targetPid", data.targetPid)

		return
	end

	local enterEscortReactionCfg = LTConfig.PoliceExamReactionConfig.GetConfig(data.reactionId)

	if enterEscortReactionCfg and enterEscortReactionCfg.MultiInteractType and enterEscortReactionCfg.MultiInteractType > 0 then
		local success, interactMainPos, interactMainDir, interactCoPos, interactCoDir = L18.Gameplay.PoliceJobManager.TryGetMultiInteractPosAndDir(enterEscortReactionCfg.MultiInteractType, MyPlayerManager.PlayerUnit, npcUnit, nil, nil, nil, nil)

		if not success then
			print_warn("PoliceEscortManager: 获取押送开始双人交互点位朝向失败!")
			gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.TargetCanNotInteract)

			return
		end
	end

	gCS.MindPowerMgr:BreakAll()
	gPoliceJobManager:ChangePoliceStage(gPoliceJobManager.POLICE_STAGE.ESCORT)
	gPoliceJobManager.cs:ChangeNpcExamineState(data.targetPid, gPoliceJobManager.CS_EXAMINE_STAGE.ESCORTING)
	gCS.BaseUnitUtils.MuteUnitServerControl(data.targetPid, true)

	local module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(npcUnit)

	if module then
		local extraData = module.ClientExtraData

		if not extraData then
			extraData = {}
			module.ClientExtraData = extraData
		end

		if data.hideEscortLeaveBtn == true or data.hideEscortLeaveBtn == false then
			extraData.hideEscortLeaveBtn = data.hideEscortLeaveBtn
		elseif extraData.hideEscortLeaveBtn == nil then
			extraData.hideEscortLeaveBtn = false
		end

		if data.hideEscortReleaseBtn == true or data.hideEscortReleaseBtn == false then
			extraData.hideEscortReleaseBtn = data.hideEscortReleaseBtn
		elseif extraData.hideEscortReleaseBtn == nil then
			extraData.hideEscortReleaseBtn = false
		end

		if data.hideEscortToExamineBtn == true or data.hideEscortToExamineBtn == false then
			extraData.hideEscortToExamineBtn = data.hideEscortToExamineBtn
		elseif extraData.hideEscortToExamineBtn == nil then
			extraData.hideEscortToExamineBtn = false
		end
	end

	if data.reactDirectly and data.reactionId and data.reactionId > 0 then
		gPoliceJobManager:AddWaitForReactionCallback(function ()
			return
		end, gPoliceJobManager.WAIT_REACTION.WAIT_LEAVE_ESCORT_RES)
	else
		gPoliceJobManager:AddWaitForReactionCallback(function (reactionCfg)
			if reactionCfg then
				self:CommonReactionDeal(reactionCfg)
			end

			if reactionCfg and reactionCfg.MultiInteractType and reactionCfg.MultiInteractType > 0 then
				if gPoliceJobManager.cs:TryMultiInteract(reactionCfg.MultiInteractType, MyPlayerManager.PlayerUnit, npcUnit) then
					if gPoliceJobManager.isDebug then
						print_notice("PoliceEscortManager : 开始双人交互" .. tostring(reactionCfg.MultiInteractType))
					end

					self.needEscortPid = data.targetPid
					self.CanInteract = false

					gCS.BaseUnitUtils.MuteUnitServerControl(data.targetPid, false)
				else
					self:EnterEscortFail(data.targetPid)
					gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.TargetCanNotInteract)
				end
			end
		end, gPoliceJobManager.WAIT_REACTION.WAIT_LEAVE_ESCORT_RES)
	end

	if gPoliceJobManager.isDebug then
		print_notice("PoliceEscortManager : 请求服务器 开始押送")
	end

	gClientToGameDelegate:AskPolicePrepareEscort(data.targetPid).Callback = function (err)
		gCS.BaseUnitUtils.MuteUnitServerControl(data.targetPid, false)

		if err ~= LTConfig.MessageConfig.Ok then
			self:EnterEscortFail(data.targetPid)
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end

	gClientToGameDelegate:AskPoliceExamInteract(data.targetPid, data.interact).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			self:EnterEscortFail(data.targetPid)
			gPoliceJobManager:ClearWaitForReactionCallback()
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end

	if data.reactDirectly and data.reactionId and data.reactionId > 0 then
		local reactionCfg = enterEscortReactionCfg

		if reactionCfg then
			self:CommonReactionDeal(reactionCfg)
		end

		if reactionCfg.MultiInteractType and reactionCfg.MultiInteractType > 0 then
			if gPoliceJobManager.cs:TryMultiInteract(reactionCfg.MultiInteractType, MyPlayerManager.PlayerUnit, npcUnit) then
				if gPoliceJobManager.isDebug then
					print_notice("PoliceEscortManager : 开始双人交互" .. tostring(reactionCfg.MultiInteractType))
				end

				self.needEscortPid = data.targetPid

				gCS.BaseUnitUtils.MuteUnitServerControl(data.targetPid, false)

				self.CanInteract = false

				gPoliceJobManager.cs:SetInteractProcessPrepared(npcUnit)
			else
				self:EnterEscortFail(data.targetPid)
				gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.TargetCanNotInteract)
			end
		end
	end
end

function PoliceEscortManager:EnterEscortFail(pid)
	if gPoliceJobManager.isDebug then
		print_notice("PoliceEscortManager:EnterEscortFail")
	end

	gPoliceJobManager:ClearWaitForReactionCallback()
	gPoliceJobManager:ChangePoliceStage(gPoliceJobManager.POLICE_STAGE.NONE)
	gPoliceJobManager.cs:ChangeNpcExamineState(pid, gPoliceJobManager.CS_EXAMINE_STAGE.NONE)
	gCS.BaseUnitUtils.MuteUnitServerControl(pid, false)

	if self.needEscortPid then
		gClientToGameDelegate:AskPoliceExitEscortOrExam(self.needEscortPid).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end

	self.needEscortPid = nil
end

function PoliceEscortManager:StateTreePoliceEscortMoveFinish()
	if self.needEscortPid then
		self:EnterEscortFromExamine(self.needEscortPid, false, true)

		self.needEscortPid = nil
	end
end

function PoliceEscortManager:EnterEscortFromExamine(targetPid, fromExamine, switchWeaponToHand)
	gPoliceJobManager.currentWaitAnimationPid = targetPid
	self.targetPid = targetPid
	self.lastTargetPid = targetPid
	local params = {
		targetPid = targetPid
	}

	gPoliceJobManager:SetNpcExitState(self.targetPid, gPoliceJobManager.CS_EXIT_STATE.ESCORTING_EXIT)

	for _, state in ipairs(self.states) do
		gCS.UnitStateMgr:AddClientState(MyPlayerManager.PlayerUnit.Pid, state, 999999)
	end

	gPoliceJobManager:ChangePoliceStage(gPoliceJobManager.POLICE_STAGE.ESCORT)
	gPoliceJobManager.cs:ChangeNpcExamineState(targetPid, gPoliceJobManager.CS_EXAMINE_STAGE.ESCORTING)
	gCS.BaseUnitUtils.ChangeAuthorityState(targetPid, LX6.Units.Module.AuthorityState.Interacting, true)

	if gPoliceJobManager.isDebug then
		print_notice("Police NPC ChangeAuthorityState interacting true, pid " .. tostring(targetPid))
	end

	self.currentStage = self.ESCORT_STAGE.ESCORTING
	self.hideEscortLeaveBtn = self.hideEscortLeaveBtnPid and self.hideEscortLeaveBtnPid == targetPid

	if switchWeaponToHand then
		gPoliceJobManager:SwitchWeaponToHand()
	end

	self.waitExitEscort = false
	self.hideEscortLeaveBtn = false
	self.hideEscortReleaseBtn = false
	self.hideEscortToExamineBtn = false
	local unit = SceneDataMgr.GetUnit(targetPid)

	if gPoliceJobManager.IsUnitValid(unit) then
		local module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(unit)

		if module and module.ClientExtraData then
			self.hideEscortLeaveBtn = module.ClientExtraData.hideEscortLeaveBtn
			self.hideEscortReleaseBtn = module.ClientExtraData.hideEscortReleaseBtn
			self.hideEscortToExamineBtn = module.ClientExtraData.hideEscortToExamineBtn
		end
	end

	self.desiredNpcState = nil
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	gameplayControlStore:StartGameplayByType(gHUDGameplayType.POLICE_ESCORT, params)
end

function PoliceEscortManager:OnUnitBeAttacked(pid)
	if self.panel and self.panel.isShow and MyPlayerManager.PlayerUnit and pid == MyPlayerManager.PlayerUnit.Pid or self.lastTargetPid == pid then
		self:ExitByBadReason(self.lastTargetPid, true)

		if gPoliceJobManager.isDebug then
			print_notice("PoliceEscortManager ExitByBadReason by OnUnitBeAttacked pid " .. ulong.tostring(pid))
		end
	elseif gPoliceJobManager:TrySetNpcExitState(pid, gPoliceJobManager.CS_EXIT_STATE.NONE) then
		gClientToGameDelegate:AskPoliceExitEscortOrExam(pid).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end
end

function PoliceEscortManager:OnUnitBeDestroy(pid)
	if self.panel and self.panel.isShow and MyPlayerManager.PlayerUnit and pid == MyPlayerManager.PlayerUnit.Pid or self.lastTargetPid == pid then
		if gPoliceJobManager.isDebug then
			print_notice("PoliceEscortManager ExitByBadReason by OnUnitBeDestroy pid " .. ulong.tostring(pid))
		end

		if self.panel and self.panel.isShow then
			if gPoliceJobManager.isDebug then
				print_notice("PoliceEscortManager : 强制退出押送")
			end

			local reactionCfg = LTConfig.PoliceExamReactionConfig.GetConfig(18001)

			if pid ~= MyPlayerManager.PlayerUnit.Pid then
				if reactionCfg.GameplayEvent and reactionCfg.GameplayEvent > 0 then
					gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, reactionCfg.GameplayEvent)

					if gPoliceJobManager.isDebug then
						print_notice("PoliceEscortManager : 开始玩家动作" .. tostring(reactionCfg.GameplayEvent))
					end
				end

				for _, state in ipairs(self.states) do
					gCS.UnitStateMgr:RemoveClientState(MyPlayerManager.PlayerUnit.Pid, state)
				end

				gPoliceJobManager:SwitchWeaponToCachedWeapon()
			end

			if self.lastTargetPid ~= pid then
				local unit = SceneDataMgr.GetUnit(self.lastTargetPid)

				if unit then
					if reactionCfg.NPCGameplaySignal and reactionCfg.NPCGameplaySignal > 0 then
						gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, reactionCfg.NPCGameplaySignal)

						if gPoliceJobManager.isDebug then
							print_notice("PoliceEscortManager : 开始NPC动作" .. tostring(reactionCfg.NPCGameplaySignal))
						end
					end

					gCS.BaseUnitUtils.ChangeAuthorityState(pid, LX6.Units.Module.AuthorityState.Interacting, false)
					gPoliceJobManager.cs:ChangeNpcExamineState(self.targetPid, self.desiredNpcState or gPoliceJobManager.CS_EXAMINE_STAGE.NONE)
				end
			end

			local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

			gameplayControlStore:StopGameplayByType(gHUDGameplayType.POLICE_ESCORT)
			gPoliceJobManager:CancelWaitOutwardSignal()
			gPoliceJobManager:ChangePoliceStage(gPoliceJobManager.POLICE_STAGE.NONE)
			gPoliceJobManager:RefreshVehicleMenu()

			self.CanInteract = true

			gPoliceJobManager:StopWaitVehicleOutwardSignal()

			self.desiredNpcState = nil
			self.currentStage = self.ESCORT_STAGE.ESCORTING
		end
	elseif gPoliceJobManager.npcStatusDict[pid] then
		gPoliceJobManager:SetNpcExitState(pid, gPoliceJobManager.CS_EXIT_STATE.NONE)

		gPoliceJobManager.npcStatusDict[pid] = nil
	end
end

function PoliceEscortManager:OnBeginPortal()
	if self.panel and self.panel.isShow and self.lastTargetPid then
		self:ExitByBadReason(self.lastTargetPid, true, true)

		if gPoliceJobManager.isDebug then
			print_notice("PoliceEscortManager ExitByBadReason by OnBeginPortal")
		end
	elseif self.needEscortPid then
		self:EnterEscortFail(self.needEscortPid)
	end
end

function PoliceEscortManager:OnBeginTimeline()
	if self.panel and self.panel.isShow and self.lastTargetPid then
		self:ExitByBadReason(self.lastTargetPid, true)

		if gPoliceJobManager.isDebug then
			print_notice("PoliceEscortManager ExitByBadReason by OnBeginTimeline")
		end
	elseif self.needEscortPid then
		self:EnterEscortFail(self.needEscortPid)
	end
end

function PoliceEscortManager:StateTreePoliceExit(pid)
	if self.currentStage == self.ESCORT_STAGE.ESCORTING and self.panel and self.panel.isShow and MyPlayerManager.PlayerUnit and pid == MyPlayerManager.PlayerUnit.Pid then
		self:ExitByBadReason(self.lastTargetPid, true)

		if gPoliceJobManager.isDebug then
			print_notice("PoliceEscortManager ExitByBadReason by StateTreePoliceExit pid " .. ulong.tostring(pid))
		end
	end
end

function PoliceEscortManager:ExitByBadReason(pid, clearNpcCanInteractEscort, skipReportExit)
	if self.panel and self.panel.isShow then
		if gPoliceJobManager.isDebug then
			print_notice("PoliceEscortManager : 强制退出押送")
		end

		local reactionCfg = LTConfig.PoliceExamReactionConfig.GetConfig(18001)

		if reactionCfg.IsEndMultiInteract then
			gPoliceJobManager.cs:TryStopMultiInteract()
		end

		if reactionCfg.GameplayEvent and reactionCfg.GameplayEvent > 0 then
			gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, reactionCfg.GameplayEvent)

			if gPoliceJobManager.isDebug then
				print_notice("PoliceEscortManager : 开始玩家动作" .. tostring(reactionCfg.GameplayEvent))
			end
		end

		if pid then
			local unit = SceneDataMgr.GetUnit(pid)

			if unit and reactionCfg.NPCGameplaySignal and reactionCfg.NPCGameplaySignal > 0 then
				gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, reactionCfg.NPCGameplaySignal)

				if gPoliceJobManager.isDebug then
					print_notice("PoliceEscortManager : 开始NPC动作" .. tostring(reactionCfg.NPCGameplaySignal))
				end
			end
		end

		self:OnExitEscort()
		gCS.BaseUnitUtils.ChangeAuthorityState(pid, LX6.Units.Module.AuthorityState.Interacting, false)

		if clearNpcCanInteractEscort and gPoliceJobManager:TrySetNpcExitState(pid, gPoliceJobManager.CS_EXIT_STATE.NONE) and not skipReportExit then
			gClientToGameDelegate:AskPoliceExitEscortOrExam(pid).Callback = function (err)
				if err ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end
			end
		end
	end
end

function PoliceEscortManager:ClearStatus()
	self.stateTreeEscortFromVehicle = false
	self.stateTreeEscortToVehicle = false
	self.taskEscortVehicle = false
	self.CanInteract = true
	self.needEscortPid = nil
	self.needRelease = nil
	self.waitExitEscort = false
	self.currentStage = self.ESCORT_STAGE.ESCORTING
	self.cacheVehicleId = nil
	self.cacheSeatIndex = nil
	self.interactVehicleId = nil
	self.interactVehicleSeatIndex = nil
	self.interactBtnVehicleId = nil
	self.vehicleData = nil
	self.waitCarAniNPCSignal = nil
	self.waitCarAniGameplayEvent = nil
	self.waitCarNpcPid = nil
end

function PoliceEscortManager:OnExitEscort()
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	gameplayControlStore:StopGameplayByType(gHUDGameplayType.POLICE_ESCORT)

	for _, state in ipairs(self.states) do
		gCS.UnitStateMgr:RemoveClientState(MyPlayerManager.PlayerUnit.Pid, state)
	end

	gPoliceJobManager:CheckWaitOutwardSignal()
	gPoliceJobManager:ChangePoliceStage(gPoliceJobManager.POLICE_STAGE.NONE)
	gPoliceJobManager.cs:ChangeNpcExamineState(self.targetPid, self.desiredNpcState or gPoliceJobManager.CS_EXAMINE_STAGE.NONE)
	gPoliceJobManager:SwitchWeaponToCachedWeapon()
	gPoliceJobManager:RefreshVehicleMenu()

	self.CanInteract = true

	gPoliceJobManager:StopWaitVehicleOutwardSignal()

	self.desiredNpcState = nil
	self.currentStage = self.ESCORT_STAGE.ESCORTING
end

function PoliceEscortManager:EscortToLeave(targetPid)
	if self.currentStage ~= self.ESCORT_STAGE.ESCORTING then
		return
	end

	if gPoliceJobManager.isDebug then
		print_notice("Police EscortToLeaved  Press")
	end

	gPoliceJobManager:CheckWaitOutwardSignal()
	gPoliceJobManager:AddWaitForReactionCallback(function (reactionCfg)
		if reactionCfg then
			self:CommonReactionDeal(reactionCfg)
		else
			self:ExitByBadReason(self.targetPid, true)

			if gPoliceJobManager.isDebug then
				print_notice("PoliceEscortManager ExitByBadReason by EscortToLeave reactionCfg nil")
			end
		end

		if reactionCfg and reactionCfg.NPCGameplaySignal and reactionCfg.NPCGameplaySignal > 0 and self.targetPid then
			self:SetPanelBtnShow(false)
			self:SetWaitCloseTimer()
		else
			self:OnExitEscort()
		end

		if gPoliceJobManager.isDebug then
			print_notice("Police NPC ChangeAuthorityState interacting false, pid " .. tostring(self.targetPid))
		end
	end, gPoliceJobManager.WAIT_REACTION.WAIT_LEAVE_ESCORT_RES)

	if gPoliceJobManager.isDebug then
		print_notice("PoliceEscortManager : 请求服务器" .. tostring(LTConfig.PoliceExamInteractConfig.TemporaryLeave))
	end

	gClientToGameDelegate:AskPoliceExamInteract(self.targetPid, LTConfig.PoliceExamInteractConfig.TemporaryLeave).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gPoliceJobManager:ClearWaitForReactionCallback()
			gDisplayMessageMgr:DisplayServerMessageId(err)
			self:ExitByBadReason(self.targetPid, true)

			if gPoliceJobManager.isDebug then
				print_notice("PoliceEscortManager ExitByBadReason by EscortToLeave AskPoliceExamInteract failed")
			end
		end
	end

	self.CanInteract = false
end

function PoliceEscortManager:EscortToRelease(targetPid)
	if self.currentStage ~= self.ESCORT_STAGE.ESCORTING then
		return
	end

	if gPoliceJobManager.isDebug then
		print_notice("Police EscortToRelease  Press")
	end

	gPoliceJobManager:CheckWaitOutwardSignal()
	gPoliceJobManager:AddWaitForReactionCallback(function (reactionCfg)
		if not reactionCfg then
			return
		end

		self:CommonReactionDeal(reactionCfg)

		if reactionCfg.NPCGameplaySignal and reactionCfg.NPCGameplaySignal > 0 and self.targetPid then
			self:SetPanelBtnShow(false)

			self.needRelease = true

			self:SetWaitCloseTimer()
		else
			self:OnExitEscort()
			gPoliceJobManager:SetNpcExitState(self.targetPid, gPoliceJobManager.CS_EXIT_STATE.NONE)
			gCS.BaseUnitUtils.ChangeAuthorityState(self.targetPid, LX6.Units.Module.AuthorityState.Interacting, false)
		end

		if gPoliceJobManager.isDebug then
			print_notice("Police NPC ChangeAuthorityState interacting false, pid " .. tostring(self.targetPid))
		end
	end, gPoliceJobManager.WAIT_REACTION.WAIT_RELEASE_ESCORT_RES)
	self:TriggerStim(LTConfig.PoliceExamInteractConfig.Clearance)

	self.CanInteract = false
end

function PoliceEscortManager:GetArrestDispatchSupportDailyLimit()
	local dailyLimit = LTConfig.PoliceConfig.ArrestSupportDefaultDailyLimit
	local badgeAddDailyLimits = LTConfig.PoliceConfig.ArrestSupportBadgeAddDailyLimit

	for badgeId, addValue in pairs(badgeAddDailyLimits) do
		if gSpiritJobManager:CheckCurSpiritContainBadge(badgeId) then
			dailyLimit = dailyLimit + addValue
		end
	end

	return dailyLimit
end

function PoliceEscortManager:IsEscortSupportEnabled()
	local tid = gSpiritManager:GetCurFirstSpiritTid()

	if tid then
		local dispatchInfo = gPoliceJobManager.panelMgr.dispatchInfo[tid]

		if dispatchInfo then
			local arrestDispatchInfo = dispatchInfo[LTConfig.PoliceDispatchConfig.AutoArrest]

			if arrestDispatchInfo and arrestDispatchInfo.NextAvailableTime <= gCS.TimeManager.ServerUnixTime then
				local timeLimit = self:GetArrestDispatchSupportDailyLimit()

				if arrestDispatchInfo.TodayArrestSupportTimes < timeLimit then
					return true
				end
			end
		end
	end

	return false
end

function PoliceEscortManager:EscortSupport(targetPid)
	if self.currentStage ~= self.ESCORT_STAGE.ESCORTING or not self:IsEscortSupportEnabled() then
		return
	end

	if gPoliceJobManager.isDebug then
		print_notice("Police EscortToLeaved  Press")
	end

	gPoliceJobManager:CheckWaitOutwardSignal()
	gPoliceJobManager:AddWaitForReactionCallback(function (reactionCfg)
		if reactionCfg then
			self:CommonReactionDeal(reactionCfg)
		else
			self:ExitByBadReason(self.targetPid, true)

			if gPoliceJobManager.isDebug then
				print_notice("PoliceEscortManager ExitByBadReason by EscortSupport reaction config nil")
			end
		end

		if reactionCfg and reactionCfg.NPCGameplaySignal and reactionCfg.NPCGameplaySignal > 0 and self.targetPid then
			self:SetPanelBtnShow(false)
			self:SetWaitCloseTimer()
		else
			self:OnExitEscort()
		end

		if gPoliceJobManager.isDebug then
			print_notice("Police NPC ChangeAuthorityState interacting false, pid " .. tostring(self.targetPid))
		end

		self.desiredNpcState = gPoliceJobManager.CS_EXAMINE_STAGE.INWARD
	end, gPoliceJobManager.WAIT_REACTION.WAIT_LEAVE_ESCORT_RES)

	if gPoliceJobManager.isDebug then
		print_notice("PoliceEscortManager : 请求服务器押送支援")
	end

	local extraInfo = {
		PrisonerId = self.targetPid
	}

	gClientToGameDelegate:AskPoliceDispatch(LTConfig.PoliceDispatchConfig.AutoArrest, extraInfo).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			print_warn("AskPoliceDispatch failed, error =", gCS.Error.GetNameById(err))
			gPoliceJobManager:ClearWaitForReactionCallback()
			gDisplayMessageMgr:DisplayServerMessageId(err)
			self:ExitByBadReason(self.targetPid, true)

			if gPoliceJobManager.isDebug then
				print_notice("PoliceEscortManager ExitByBadReason by EscortSupport AskPoliceDispatch failed")
			end

			return
		end

		local cfg = LTConfig.PoliceDispatchConfig.GetConfig(LTConfig.PoliceDispatchConfig.AutoArrest)

		if cfg.DialogId then
			gDialogManager:ShowGeneralDialog(cfg.DialogId, gDialogSource.Police)
		end
	end

	self.CanInteract = false
end

function PoliceEscortManager:SetWaitCloseTimer()
	self.waitExitEscort = true

	self:SetPanelBtnShow(false)
end

function PoliceEscortManager:OnStateTreeExitEscort()
	if self.waitExitEscort then
		self.waitExitEscort = false

		self:OnExitEscort()

		if self.needRelease then
			gPoliceJobManager:SetNpcExitState(self.targetPid, gPoliceJobManager.CS_EXIT_STATE.NONE)
			gCS.BaseUnitUtils.ChangeAuthorityState(self.targetPid, LX6.Units.Module.AuthorityState.Interacting, false)
		end

		self.needRelease = nil
		self.targetPid = nil
	end
end

function PoliceEscortManager:StateTreePoliceEnterEscortState()
	self:SetPanelBtnShow(true)
	gPoliceJobManager:RefreshVehicleMenu()

	self.CanInteract = true
end

function PoliceEscortManager:ReportMutiInteractCancel()
	if self.currentStage == self.ESCORT_STAGE.ESCORTING then
		self:ExitByBadReason(self.lastTargetPid, false)
	elseif self.needEscortPid then
		self:EnterEscortFail(self.needEscortPid)
	end
end

function PoliceEscortManager:SetPanelBtnShow(show)
	if self.panel and self.panel.isShow then
		self.panel:SetBtnShown(show)
	end
end

function PoliceEscortManager:EscortToExamine(targetPid)
	if self.currentStage ~= self.ESCORT_STAGE.ESCORTING then
		return
	end

	if gPoliceJobManager.isDebug then
		print_notice("Police EscortToExamine  Press")
	end

	gPoliceJobManager:CheckWaitOutwardSignal()

	local data = {}
	local npcUnit = SceneDataMgr.GetUnit(targetPid)
	data.targetPid = targetPid
	data.npcUnit = npcUnit
	data.npcTargetDir = npcUnit.Forward
	self.waitEscortToExamineData = data

	gPoliceJobManager:AddWaitForReactionCallback(function (reactionCfg)
		if not reactionCfg then
			return
		end

		self:SetPanelBtnShow(false)
		self:CommonReactionDeal(reactionCfg)

		self.currentStage = self.ESCORT_STAGE.ESCORT_To_EXAMINE_ANIMATION
	end, gPoliceJobManager.WAIT_REACTION.WAIT_ESCORT_TO_EXAMINE_RES)
	self:TriggerStim(LTConfig.PoliceExamInteractConfig.Examine)

	self.CanInteract = false
end

function PoliceEscortManager:StateTreePoliceEscortToExamineFinish()
	if gGameSwitch.EnablePoliceJobStoryLegacy then
		local data = self.waitEscortToExamineData
		local success, interactMainPos, interactMainDir, interactCoPos, interactCoDir = L18.Gameplay.PoliceJobManager.TryGetMultiInteractPosAndDir(LTConfig.MultiInteractTypeConfig.Examine, MyPlayerManager.PlayerUnit, data.npcUnit, nil, nil, nil, nil)

		if success then
			self.waitEscortToExamineData = nil

			LX6.PaoKu.EntrySystemManager.SetDestAndSendGameplayEvent(MyPlayerManager.PlayerUnit, 0, nil, interactMainPos, Quaternion.LookRotation(interactMainDir))
		end
	elseif self.waitEscortToExamineData and self.waitEscortToExamineData.npcUnit then
		local data = self.waitEscortToExamineData
		local success, interactMainPos, interactMainDir, interactCoPos, interactCoDir = L18.Gameplay.PoliceJobManager.TryGetMultiInteractPosAndDir(LTConfig.MultiInteractTypeConfig.Examine, MyPlayerManager.PlayerUnit, data.npcUnit, nil, nil, nil, nil)

		if success then
			self.waitEscortToExamineData = nil

			self:OnExitEscort()
			gPoliceJobManager:SetNpcExitState(data.targetPid, gPoliceJobManager.CS_EXIT_STATE.NONE)
			LX6.PaoKu.EntrySystemManager.SetDestAndSendGameplayEvent(MyPlayerManager.PlayerUnit, 0, nil, interactMainPos, Quaternion.LookRotation(interactMainDir))
			gPoliceJobManager.examineMgr:EnterExamineFormEscort(data, data.npcUnit)
			gPoliceJobManager:RefreshVehicleMenu()

			self.CanInteract = true
		end
	end
end

function PoliceEscortManager:EscortNpcToWard()
	if gPoliceJobManager.isDebug then
		print_notice("Police escort npc to ward success!")
	end

	self:OnExitEscort()
	gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.PoliceGuardToLeave)
	gPoliceJobManager.cs:ChangeNpcExamineState(self.targetPid, gPoliceJobManager.CS_EXAMINE_STAGE.INWARD)

	self.desiredNpcState = gPoliceJobManager.CS_EXAMINE_STAGE.INWARD
end

function PoliceEscortManager:TriggerStim(stimType)
	if gPoliceJobManager.isDebug then
		print_notice("PoliceEscortManager : 请求服务器" .. tostring(stimType))
	end

	gClientToGameDelegate:AskPoliceExamInteract(self.targetPid, stimType).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gPoliceJobManager:ClearWaitForReactionCallback()
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

function PoliceEscortManager:CommonReactionDeal(reactionCfg)
	if reactionCfg.IsEndMultiInteract then
		gPoliceJobManager.cs:TryStopMultiInteract()
	end

	if reactionCfg.GameplayEvent and reactionCfg.GameplayEvent > 0 then
		gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, reactionCfg.GameplayEvent)

		if gPoliceJobManager.isDebug then
			print_notice("PoliceEscortManager : 开始玩家动作" .. tostring(reactionCfg.GameplayEvent))
		end
	end

	if reactionCfg.NPCGameplaySignal and reactionCfg.NPCGameplaySignal > 0 and self.targetPid then
		local unit = SceneDataMgr.GetUnit(self.targetPid)

		if unit then
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, reactionCfg.NPCGameplaySignal)
			gPoliceJobManager:SetWaitNPCSignal(reactionCfg.NPCGameplaySignal, self.targetPid)

			if gPoliceJobManager.isDebug then
				print_notice("PoliceEscortManager Arrest: 开始NPC动作" .. tostring(reactionCfg.NPCGameplaySignal))
			end
		end

		if gPoliceJobManager.isDebug then
			print_notice("PoliceEscortManager : 开始NPC动作" .. tostring(reactionCfg.NPCGameplaySignal))
		end
	end
end

function PoliceEscortManager:StateTreeEscortNpc()
	self:OnExitEscort()
end

function PoliceEscortManager:StateTreeEscortNpcFromVehicle()
	if gPoliceJobManager.isDebug then
		print_notice("PoliceEscortManager : 主角 上车动作结束！")
	end

	self.stateTreeEscortFromVehicle = false

	if not self.taskEscortVehicle then
		self:EscortAnimFinish()
	end
end

function PoliceEscortManager:StateTreeEscortNpcToVehicle()
	if gPoliceJobManager.isDebug then
		print_notice("PoliceEscortManager : 主角 下车动作结束！")
	end

	self.stateTreeEscortToVehicle = false

	if not self.taskEscortVehicle then
		self:EscortAnimFinish()
	end
end

function PoliceEscortManager:IsInAnimation()
	return self.taskEscortVehicle or self.stateTreeEscortFromVehicle or self.stateTreeEscortToVehicle or self.currentStage == self.ESCORT_STAGE.ESCORT_TO_ANIMATION or self.currentStage == self.ESCORT_STAGE.ESCORT_FROM_ANIMATION or self.currentStage == self.ESCORT_STAGE.ESCORT_To_EXAMINE_ANIMATION
end

function PoliceEscortManager:CheckCarEscort(interactMenuState, vehicleId, seatIndex)
	if interactMenuState < gVehicleInteractManager.InteractMenuState.Disable then
		self.cacheVehicleId = vehicleId
		self.cacheSeatIndex = seatIndex
	elseif not gPoliceJobManager.isVehicleMenuRefresh and not gVehicleInteractManager.cs_manager.isInteracting then
		self.cacheVehicleId = nil
		self.cacheSeatIndex = nil
	end

	if self:IsInAnimation() then
		self:ExitCurrentVehicleEscortMenu()

		return true
	end

	if seatIndex == 0 or seatIndex == 1 then
		self:ExitCurrentVehicleEscortMenu()

		return not gPoliceJobManager:IsInStage(gPoliceJobManager.POLICE_STAGE.NONE)
	end

	local description = nil
	local textId = 0
	local clickEvent = nil

	if gPoliceJobManager:IsInStage(gPoliceJobManager.POLICE_STAGE.ESCORT) then
		local pid = gPoliceJobManager:GetEscortNpcInSeat(vehicleId, seatIndex)

		if pid then
			self:ExitCurrentVehicleEscortMenu()

			return true
		end

		if self.targetPid then
			description = LTConfig.TextCommonTextConfig.GetConfig(LTConfig.TextCommonTextConfig.EscortToVehicle).Text
			textId = LTConfig.TextCommonTextConfig.EscortToVehicle
			clickEvent = self.OnEscortToVehicleClick
		end
	else
		local pid = gPoliceJobManager:GetEscortNpcInSeat(vehicleId, seatIndex)

		if pid then
			local unit = SceneDataMgr.GetUnit(pid)

			if gPoliceJobManager.IsUnitValid(unit) then
				description = LTConfig.TextCommonTextConfig.GetConfig(LTConfig.TextCommonTextConfig.EscortFromVehicle).Text
				textId = LTConfig.TextCommonTextConfig.EscortFromVehicle
				clickEvent = self.OnEscortFromVehicleClick
			else
				print_error_without_stack("PoliceEscortManager check car escort.There is one npc on seat, but unit is not exist.vehicleID " .. tostring(vehicleId) .. " seatIndex " .. tostring(seatIndex))

				return true
			end
		end
	end

	if not description or not clickEvent then
		self:ExitCurrentVehicleEscortMenu()

		return false
	end

	if interactMenuState < gVehicleInteractManager.InteractMenuState.Disable then
		local isGray = interactMenuState == gVehicleInteractManager.InteractMenuState.Gray
		self.interactVehicleId = vehicleId
		self.interactVehicleSeatIndex = seatIndex
		self.interactBtnVehicleId = vehicleId
		local targetTrans = nil
		local vehicle = DriveUtils.GetVehicleInScene(vehicleId)

		if vehicle ~= nil and vehicle.seats ~= nil then
			targetTrans = vehicle.seats:GetInteractPoint(seatIndex)
		end

		local info = LX6.Interact.BaseBtnInfo.New(vehicleId, 3, targetTrans, 0, clickEvent, nil, textId)
		info.isGray = isGray

		L50.L50App.L50Game.InteractBtnMgr:AddBtn(info)
	elseif interactMenuState == gVehicleInteractManager.InteractMenuState.Disable and self.interactBtnVehicleId then
		self:ExitCurrentVehicleEscortMenu()
	end

	return true
end

function PoliceEscortManager:ExitCurrentVehicleEscortMenu()
	if self.interactBtnVehicleId and self.interactBtnVehicleId ~= 0 then
		L50.L50App.L50Game.InteractBtnMgr:RemoveBtnByType(self.interactBtnVehicleId, 3)

		self.interactBtnVehicleId = nil
	end
end

function PoliceEscortManager.OnEscortToVehicleClick()
	local self = this

	if self.currentStage ~= self.ESCORT_STAGE.ESCORTING or not self.CanInteract then
		return
	end

	gPoliceJobManager:CheckWaitOutwardSignal()

	local seatIndex = self.interactVehicleSeatIndex

	if self.interactVehicleId == nil or seatIndex == nil or not self.targetPid then
		return
	end

	local unit = SceneDataMgr.GetUnit(self.targetPid)

	if not gPoliceJobManager.IsUnitValid(unit) then
		return
	end

	local reactionCfg = LTConfig.PoliceExamReactionConfig.GetConfig(20001)

	if not reactionCfg or not reactionCfg.NPCGameplaySignal or reactionCfg.NPCGameplaySignal < 1 or not reactionCfg.GameplayEvent or reactionCfg.GameplayEvent < 1 then
		print_error("PoliceEscortManager: OnEscortToVehicleClick reactionCfg 20001 is invalid!")

		return
	end

	local succ, pos, rot = PoliceJobUtils.GetEscortToVehiclePoint(self.interactVehicleId, seatIndex, nil, nil)

	if not succ then
		if gPoliceJobManager.isDebug then
			print_notice("PoliceEscortManager: 押送上车:获取上车点位失败!")
		end

		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.TargetCanNotInteract)

		return
	end

	gPoliceJobManager:AddWaitForReactionCallback(function ()
		return
	end, gPoliceJobManager.WAIT_REACTION.WAIT_ESCORT_TO_CAR)

	if gPoliceJobManager.isDebug then
		print_notice("PoliceEscortManager : 请求服务器" .. tostring(LTConfig.PoliceExamInteractConfig.EscortEnterCar))
	end

	gClientToGameDelegate:AskPoliceExamInteract(self.targetPid, LTConfig.PoliceExamInteractConfig.EscortEnterCar).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gPoliceJobManager:ClearWaitForReactionCallback()
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end

	self.currentStage = self.ESCORT_STAGE.ESCORT_TO_ANIMATION
	LX6.Drive.VehicleInteractManager.Instance.isInteracting = true

	self:ExitCurrentVehicleEscortMenu()

	if reactionCfg.IsEndMultiInteract then
		gPoliceJobManager.cs:TryStopMultiInteract()
	end

	self.vehicleData = gPoliceJobManager.cs:StartVehicleMove(reactionCfg.GameplayEvent, pos, rot, self.interactVehicleId, seatIndex, true)
	self.waitCarAniNPCSignal = reactionCfg.NPCGameplaySignal
	self.waitCarAniGameplayEvent = reactionCfg.GameplayEvent
	self.waitCarNpcPid = self.targetPid

	self:SetPanelBtnShow(false)

	self.stateTreeEscortToVehicle = true
	self.taskEscortVehicle = true
end

function PoliceEscortManager.OnEscortFromVehicleClick()
	local self = this

	if self.currentStage ~= self.ESCORT_STAGE.ESCORTING or not self.CanInteract then
		return
	end

	gPoliceJobManager:CheckWaitOutwardSignal()

	local seatIndex = self.interactVehicleSeatIndex

	if self.interactVehicleId == nil or seatIndex == nil then
		return
	end

	local npcOnSeatPid = gPoliceJobManager:GetEscortNpcInSeat(self.interactVehicleId, seatIndex)

	if not npcOnSeatPid then
		return
	end

	local unit = SceneDataMgr.GetUnit(npcOnSeatPid)

	if not gPoliceJobManager.IsUnitValid(unit) then
		return
	end

	local reactionCfg = LTConfig.PoliceExamReactionConfig.GetConfig(21001)

	if not reactionCfg or not reactionCfg.NPCGameplaySignal or reactionCfg.NPCGameplaySignal < 1 or not reactionCfg.GameplayEvent or reactionCfg.GameplayEvent < 1 then
		print_error("PoliceEscortManager: OnEscortFromVehicleClick reactionCfg 21001 is invalid!")

		return
	end

	local succ, pos, rot = PoliceJobUtils.GetEscortFromVehiclePoint(self.interactVehicleId, seatIndex, nil, nil)

	if not succ then
		if gPoliceJobManager.isDebug then
			print_notice("PoliceEscortManager: 押送下车:获取下车点位失败!")
		end

		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.TargetCanNotInteract)

		return
	end

	self.npcEscortFromVehicle = npcOnSeatPid

	gPoliceJobManager:SwitchWeaponToHand()
	gPoliceJobManager:AddWaitForReactionCallback(function ()
		return
	end, gPoliceJobManager.WAIT_REACTION.WAIT_ESCORT_FROM_CAR)

	if gPoliceJobManager.isDebug then
		print_notice("PoliceEscortManager : 请求服务器" .. tostring(LTConfig.PoliceExamInteractConfig.EscortLeaveCar))
	end

	gClientToGameDelegate:AskPoliceExamInteract(self.targetPid, LTConfig.PoliceExamInteractConfig.EscortLeaveCar).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gPoliceJobManager:ClearWaitForReactionCallback()
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end

	LX6.Drive.VehicleInteractManager.Instance.isInteracting = true

	self:ExitCurrentVehicleEscortMenu()

	if reactionCfg.IsEndMultiInteract then
		gPoliceJobManager.cs:TryStopMultiInteract()
	end

	self.currentStage = self.ESCORT_STAGE.ESCORT_FROM_ANIMATION
	self.vehicleData = gPoliceJobManager.cs:StartVehicleMove(reactionCfg.GameplayEvent, pos, rot, self.interactVehicleId, seatIndex, false)
	self.waitCarAniNPCSignal = reactionCfg.NPCGameplaySignal
	self.waitCarAniGameplayEvent = reactionCfg.GameplayEvent
	self.waitCarNpcPid = npcOnSeatPid

	self:SetPanelBtnShow(false)

	self.stateTreeEscortFromVehicle = true
	self.taskEscortVehicle = true

	gPoliceJobManager:ChangePoliceStage(gPoliceJobManager.POLICE_STAGE.ESCORT)
end

function PoliceEscortManager:StateTreePoliceEscortCarMoveFinish()
	if not self.waitCarAniNPCSignal or self.waitCarAniNPCSignal < 1 or not self.waitCarAniGameplayEvent or self.waitCarAniGameplayEvent < 1 or not self.vehicleData then
		self:ClearVehicleInteractionState()

		return
	end

	if gPoliceJobManager.isDebug then
		print_notice("PoliceEscortManager : 开始载具动作 npc" .. tostring(self.waitCarAniNPCSignal) .. " player " .. tostring(self.waitCarAniGameplayEvent))
	end

	if self.waitCarNpcPid and gPoliceJobManager.cs:StartPoliceVehicleInteract(MyPlayerManager.PlayerUnit.Pid, self.waitCarNpcPid, self.waitCarAniNPCSignal, self.waitCarAniGameplayEvent, self.vehicleData) then
		self:ExitCurrentVehicleEscortMenu()
		gPoliceJobManager:StartWaitVehicleOutwardSignal(self.waitCarAniNPCSignal, self.waitCarNpcPid)
	else
		self:ClearVehicleInteractionState()
	end

	self.waitCarNpcPid = nil
end

function PoliceEscortManager:OnVehicleTaskEnd()
	if gPoliceJobManager.isDebug then
		print_notice("PoliceEscortManager : npc 上下车动作结束！")
	end

	self.taskEscortVehicle = false

	if not self.stateTreeEscortFromVehicle and not self.stateTreeEscortToVehicle then
		self:EscortAnimFinish()
	end
end

function PoliceEscortManager:EscortAnimFinish()
	local interactPid = nil

	if self.currentStage == self.ESCORT_STAGE.ESCORT_TO_ANIMATION then
		local data = gPoliceJobManager.npcStatusDict[self.targetPid]

		if not data then
			data = {}
			gPoliceJobManager.npcStatusDict[self.targetPid] = data
		end

		data.seatIndex = self.interactVehicleSeatIndex
		data.vehicleId = self.interactVehicleId

		self:OnExitEscort()
		gPoliceJobManager.cs:ChangeNpcExamineState(self.targetPid, gPoliceJobManager.CS_EXAMINE_STAGE.ESCORTING_INCAR)

		interactPid = self.targetPid
	elseif self.npcEscortFromVehicle then
		interactPid = self.npcEscortFromVehicle

		if gPoliceJobManager.npcStatusDict[self.npcEscortFromVehicle] then
			gPoliceJobManager.npcStatusDict[self.npcEscortFromVehicle] = nil
		end

		gPoliceJobManager.cs:ChangeNpcExamineState(self.npcEscortFromVehicle, gPoliceJobManager.CS_EXAMINE_STAGE.NONE)

		local npcUnit = SceneDataMgr.GetUnit(self.npcEscortFromVehicle)
		self.npcEscortFromVehicle = nil
		local reactionCfg = LTConfig.PoliceExamReactionConfig.GetConfig(21001)

		if gPoliceJobManager.IsUnitValid(npcUnit) and reactionCfg and reactionCfg.MultiInteractType and reactionCfg.MultiInteractType > 0 then
			if gPoliceJobManager.isDebug then
				print_notice("PoliceEscortManager : 开始双人交互" .. tostring(reactionCfg.MultiInteractType))
			end

			local pid = npcUnit.Pid

			if gPoliceJobManager.cs:TryMultiInteract(reactionCfg.MultiInteractType, MyPlayerManager.PlayerUnit, npcUnit) then
				gPoliceJobManager.cs:SetInteractProcessPrepared(MyPlayerManager.PlayerUnit)
				self:EnterEscortFromExamine(pid, false, false)
			else
				gPoliceJobManager:SetNpcExitState(pid, gPoliceJobManager.CS_EXIT_STATE.ESCORTING_EXIT)
				gPoliceJobManager:ChangePoliceStage(gPoliceJobManager.POLICE_STAGE.NONE)
				gPoliceJobManager.cs:ChangeNpcExamineState(pid, gPoliceJobManager.CS_EXAMINE_STAGE.NONE)
				gCS.BaseUnitUtils.ChangeAuthorityState(pid, LX6.Units.Module.AuthorityState.Interacting, true)
				gPoliceJobManager:SwitchWeaponToCachedWeapon()
				gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, MuGenStates.Logic.GameplayEvent.PoliceGuardToLeave)
			end
		end
	end

	self:SetPanelBtnShow(true)
	self:ClearVehicleInteractionState()

	if interactPid then
		gPoliceJobManager.cs:ClearPoliceVehicleInteract(MyPlayerManager.PlayerUnit.Pid, interactPid)
	end
end

function PoliceEscortManager:ClearVehicleInteractionState()
	self.currentStage = self.ESCORT_STAGE.ESCORTING
	self.interactionData = nil
	self.waitCarAniNPCSignal = nil
	self.waitCarAniGameplayEvent = nil
	self.taskEscortVehicle = false

	if gPoliceJobManager.isDebug then
		print_notice("gPoliceJobManager gInteractionManager SetShowMode All")
	end

	LX6.Drive.VehicleInteractManager.Instance.currentVehicleInteractData = nil
	LX6.Drive.VehicleInteractManager.Instance.isInteracting = false

	gPoliceJobManager:RefreshVehicleMenu()
end

function PoliceEscortManager:EnterEscort_Story(data)
	local npcUnit = SceneDataMgr.GetUnit(data.targetPid)

	if not gPoliceJobManager.IsUnitValid(npcUnit) then
		print_error("PoliceEscortManager: InitScene npcUnit is nil!, targetPid", data.targetPid)

		return
	end

	print_notice("EnterEscort_Story")

	local module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(npcUnit)

	if module then
		local extraData = module.ClientExtraData

		if not extraData then
			extraData = {}
			module.ClientExtraData = extraData
		end

		if data.hideEscortLeaveBtn == true or data.hideEscortLeaveBtn == false then
			extraData.hideEscortLeaveBtn = data.hideEscortLeaveBtn
		elseif extraData.hideEscortLeaveBtn == nil then
			extraData.hideEscortLeaveBtn = false
		end

		if data.hideEscortReleaseBtn == true or data.hideEscortReleaseBtn == false then
			extraData.hideEscortReleaseBtn = data.hideEscortReleaseBtn
		elseif extraData.hideEscortReleaseBtn == nil then
			extraData.hideEscortReleaseBtn = false
		end

		if data.hideEscortToExamineBtn == true or data.hideEscortToExamineBtn == false then
			extraData.hideEscortToExamineBtn = data.hideEscortToExamineBtn
		elseif extraData.hideEscortToExamineBtn == nil then
			extraData.hideEscortToExamineBtn = false
		end

		if data.traceToNearestPoliceCar == true or data.traceToNearestPoliceCar == false then
			extraData.traceToNearestPoliceCar = data.traceToNearestPoliceCar
		elseif extraData.traceToNearestPoliceCar == nil then
			extraData.traceToNearestPoliceCar = true
		end
	end
end

function PoliceEscortManager:EnterEscortFromExamine_Story(targetPid, fromExamine, switchWeaponToHand)
	self.targetPid = targetPid
	self.lastTargetPid = targetPid
	local params = {
		targetPid = targetPid
	}
	self.hideEscortLeaveBtn = self.hideEscortLeaveBtnPid and self.hideEscortLeaveBtnPid == targetPid

	if switchWeaponToHand then
		gPoliceJobManager:SwitchWeaponToHand()
	end

	self.waitExitEscort = false
	self.hideEscortLeaveBtn = false
	self.hideEscortReleaseBtn = false
	self.hideEscortToExamineBtn = false
	self.traceToNearestPoliceCar = true
	local unit = SceneDataMgr.GetUnit(targetPid)

	if gPoliceJobManager.IsUnitValid(unit) then
		local module = LX6.Units.Module.Character.AgentCharacterModule.GetModule(unit)

		if module and module.ClientExtraData then
			self.hideEscortLeaveBtn = module.ClientExtraData.hideEscortLeaveBtn
			self.hideEscortReleaseBtn = module.ClientExtraData.hideEscortReleaseBtn
			self.hideEscortToExamineBtn = module.ClientExtraData.hideEscortToExamineBtn

			if module.ClientExtraData.traceToNearestPoliceCar ~= nil then
				self.traceToNearestPoliceCar = module.ClientExtraData.traceToNearestPoliceCar
			end
		end
	end

	self.desiredNpcState = nil
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	gameplayControlStore:StartGameplayByType(gHUDGameplayType.POLICE_ESCORT, params)
end

function PoliceEscortManager:EscortToRelease_Story(targetPid)
	gPoliceJobManager.cs:AskPoliceEscortInteract(targetPid, LTConfig.PoliceExamInteractConfig.Clearance)
end

function PoliceEscortManager:ExitEscort_Story()
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	gameplayControlStore:StopGameplayByType(gHUDGameplayType.POLICE_ESCORT)
end

function PoliceEscortManager:EscortToExamine_Story(targetPid)
	local data = {}
	local npcUnit = SceneDataMgr.GetUnit(targetPid)
	data.targetPid = targetPid
	data.npcUnit = npcUnit
	data.npcTargetDir = npcUnit.Forward
	self.waitEscortToExamineData = data

	gPoliceJobManager.cs:AskPoliceEscortInteract(targetPid, LTConfig.PoliceExamInteractConfig.Examine)
end

function PoliceEscortManager:EscortToLeave_Story(targetPid)
	gPoliceJobManager.cs:AskPoliceEscortInteract(targetPid, LTConfig.PoliceExamInteractConfig.TemporaryLeave)
end

function PoliceEscortManager:EscortSupport_Story(targetPid)
	gPoliceJobManager.cs:AskPoliceEscortInteract(targetPid, LTConfig.PoliceExamInteractConfig.EscortSupport)
end

return PoliceEscortManager
