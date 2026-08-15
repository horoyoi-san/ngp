local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local ScriptBattleUnit = require("LX6/Utils/FormulaScriptBattleUnit")
local TaskState = UX.Game.TaskState
local FormulaUtils = {
	isActionShowMsg = false
}
local this = FormulaUtils
local BasePlayerFormula = {
	__index = function (table, key)
		return nil
	end
}
FormulaUtils.playerFormula = {
	TaskDetail = function (self, taskId)
		return {
			GetCounterValue = function (self, taskCounterIndex)
				return gTaskManager:GetTaskCounterValue(taskId, taskCounterIndex)
			end,
			State = gTaskManager:GetTaskState(taskId)
		}
	end,
	HasItem = function (self, itemTemplateId, count)
		if count == nil then
			count = 1
		end

		return count <= gPlayerItemManager:GetPackItemNum(itemTemplateId)
	end,
	HasBuff = function (self, buffId)
		return gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, buffId)
	end,
	HasSubmitOneOfTasks = function (self, ...)
		local taskIds = {
			...
		}

		for i = 1, #taskIds do
			if gTaskManager:IsTaskSubmitted(taskIds[i]) then
				return true
			end
		end

		return false
	end,
	GetTaskState = function (self, taskId)
		return gTaskManager:GetTaskState(taskId)
	end,
	TaskHasSubmitted = function (self, taskId)
		return gTaskManager:GetTaskState(taskId) == TaskState.Submited
	end,
	TaskHasAccepted = function (self, taskId)
		return gTaskManager:GetTaskState(taskId) == TaskState.Accepted
	end,
	EventHasUnlocked = function (self, eventId)
		return gTaskNodeManager:IsTaskEventUnlock(eventId) or gTaskNodeManager:IsTaskEventSubmit(eventId)
	end,
	HasFinishTaskCounter = function (self, taskId, taskCounterIndex)
		return gTaskManager:CheckTaskCounterFinished(taskId, taskCounterIndex)
	end,
	SpiritId = function (self, spiritId)
		return spiritId == gCS.MyPlayerManager.PlayerUnit.Pid
	end,
	JobId = function (self, jobId)
		return jobId == gSpiritJobManager:GetCurJobId()
	end,
	JobClassId = function (self, jobClassId)
		local jobId = gSpiritJobManager:GetCurJobId()

		return LTConfig.UrbanJobConfig.GetConfig(jobId).JobClass == jobClassId
	end,
	HasState = function (self, state)
		return gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, state)
	end,
	IsInRaid = function (self, raidId)
		return gRaidDataManager.RaidId == raidId
	end,
	SubQuestHasFinished = function (self, subQuestId)
		local CompletedSubQuestCnt = gPlayerManager.infoAchievement.bindData.CompletedSubQuestCnt

		return CompletedSubQuestCnt[subQuestId] ~= nil
	end,
	ShowMessage = function (self, messageId, args)
		if this.noDisplayMsg then
			return
		end

		this.isActionShowMsg = true

		gDisplayMessageMgr:ShowMessage(messageId, nil, nil, args and unpack(args))
	end,
	CanTransformOn = function (self)
		return true
	end,
	HasNotReceiveReward = function (self)
		return gLuaDataManager.receivedRewardEnemies[gLuaDataManager.currentInteractEnemyPid] == nil
	end,
	IsTriggerEnemyAllDie = function (self)
		if gTriggerEnemyManager.State ~= UX.Game.TriggerEnemyState.Rewarding then
			return false
		end

		if gTriggerEnemyManager.PlayingEffect then
			return false
		end

		if not gTriggerEnemyManager.EnemyIds then
			return false
		end

		for _, v in ipairs(gTriggerEnemyManager.EnemyIds) do
			local cs_unit = gCS.SceneDataMgr.GetUnit(v)

			if cs_unit ~= nil then
				return false
			end
		end

		return true
	end,
	IsRiding = function (self)
		return gCS.BaseUnitUtils.PlayerIsRiding()
	end,
	CanRideTarget = function (self)
		local agentPid = L50.L50App.L50Game.InteractBtnMgr.curCheckTableConditionUnitPid

		return gCS.BaseUnitUtils.CanRideTarget(gCS.MyPlayerManager.PlayerUnit.Pid, agentPid)
	end,
	CanDownRideTarget = function (self)
		local agentPid = L50.L50App.L50Game.InteractBtnMgr.curCheckTableConditionUnitPid

		return gCS.BaseUnitUtils.CanDownRide(gCS.MyPlayerManager.PlayerUnit.Pid, agentPid)
	end,
	HasAgentQTESucceed = function (self)
		local agentPid = L50.L50App.L50Game.InteractBtnMgr.curCheckTableConditionUnitPid

		return gMiniGameDataManager:GetToiletNpcResult(agentPid)
	end,
	HasFengDuMergeReward = function (self)
		return false
	end,
	HasRaidRewardToGet = function ()
		return gRaidDataManager.HasReward and not gRaidDataManager.Rewarded
	end,
	HasUnLockWorkStore = function (self, storeId)
		return false
	end,
	SystemUnlock = function (self, systemId)
		return gSystemUnlockMgr:IsUnlock(systemId)
	end,
	IsPlayer = function (self)
		return gCS.MyPlayerManager.PlayerUnit and (gCS.MyPlayerManager.PlayerUnit.ClientData.SubType == LTConfig.FightSpiritConfig.DefaultMale or gCS.MyPlayerManager.PlayerUnit.ClientData.SubType == LTConfig.FightSpiritConfig.DefaultFemale)
	end,
	HasFerrisTicket = function (self, index)
		return gFerrisMgr:GetTicketType() == index or gFerrisMgr:GetTicketType() == 3
	end,
	IsOnlineMode = function (self)
		return gLinkManager:CheckInLinkMode()
	end,
	CheckIsAgentProfileHasReward = function (self, id)
		return gAgentTrustManager:CheckHasRewardCanGot(id)
	end,
	UnitIsPlayer = function ()
		return gCS.MyPlayerManager.PlayerUnit ~= nil and gCS.MyPlayerManager.PlayerUnit.Pid == L50.L50App.L50Game.InteractBtnMgr.curCheckTableConditionUnitPid
	end,
	IsAgentProfileActivate = function (self, id)
		return gAgentTrustManager:GetIfAcquaintedByProfileId(id)
	end
}

setmetatable(FormulaUtils.playerFormula, BasePlayerFormula)

local BaseNpcCanInteract = {
	__index = function (table, key)
		if key == "OpenFunInteractivePanel" then
			this.npcCanInteract.canInteract = false
		else
			this.npcCanInteract.canInteract = true

			return function ()
				return
			end
		end
	end
}
FormulaUtils.npcCanInteract = {}

setmetatable(FormulaUtils.npcCanInteract, BaseNpcCanInteract)

function FormulaUtils:CheckPlotInteractCondition(agentId, index)
	local cfg = LTConfig.AgentConfig.GetConfig(agentId)

	if not cfg then
		return true
	end

	local interactionConfig = LTConfig.AgentDataSetsInteractSettingConfig.GetConfig(cfg.InteractSetting)

	if not interactionConfig or not interactionConfig.InteractionRequirements then
		return true
	end

	return interactionConfig.InteractionRequirements(this.playerFormula, index) ~= false
end

function FormulaUtils.CalculateSkillDamage(attackerDam, defenderPhyDef, attackerLevel, skillId, triggerIndex)
	return Formula_cs:CalculateSkillDamage(attackerDam, defenderPhyDef, attackerLevel, skillId, triggerIndex)
end

function FormulaUtils:GetDestructibleDamageAndForceFromVehicle(vehicleTemplateId, vehicleMass, velocity, destructibleTemplateId, reactionId, physicMatId, volumeToIndex)
	local damage = 0
	local force = 0
	damage, force = Formula_cs:GetDestructibleDamageAndForceFromVehicle(vehicleTemplateId, vehicleMass, UX.Game.UXVector3.New(velocity.x, velocity.y, velocity.z), destructibleTemplateId, reactionId, physicMatId, volumeToIndex, damage, force)

	return damage, force
end

function FormulaUtils:GetSkillDamageToVehicle(vehicleTemplateId, vehicleMass, vehicleVelocity, skillId, releaserId)
	releaser = nil

	if releaserId and not ulong.equals(releaserId, 0) then
		releaser = ScriptBattleUnit.New(releaserId)
	end

	return Formula_cs:GetSkillDamageToVehicle(vehicleTemplateId, vehicleMass, UX.Game.UXVector3.New(vehicleVelocity.x, vehicleVelocity.y, vehicleVelocity.z), skillId, releaserId, releaser)
end

function FormulaUtils:GetContactDamageToVehicle(vehicleTemplateId, vehicleMass, carVelocityList, RelativeVelocity, objectType, touchMass, enemyWeight, enemyRank, isPlayerOnVehicle, disableThreshold, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetContactDamageToVehicle", isPlayerOnVehicle, vehicleTemplateId)

			return 0
		end
	end

	return Formula_cs:GetContactDamageToVehicle(vehicleTemplateId, vehicleMass, carVelocityList, UX.Game.UXVector3.New(RelativeVelocity.x, RelativeVelocity.y, RelativeVelocity.z), objectType, touchMass, enemyWeight, enemyRank, unit, disableThreshold)
end

function FormulaUtils:GetPlayerVehicleAccelerationScale(isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleAccelerationScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleAccelerationScale(unit)
end

function FormulaUtils:GetPlayerVehicleTopSpeedScale(isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleTopSpeedScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleTopSpeedScale(unit)
end

function FormulaUtils:GetPlayerVehicleGroundMatDriveScale(isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleGroundMatDriveScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleGroundMatDriveScale(unit)
end

function FormulaUtils:GetPlayerVehicleBrakeScale(isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleBrakeScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleBrakeScale(unit)
end

function FormulaUtils:GetPlayerVehicleShiftTimeScale(isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleShiftTimeScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleShiftTimeScale(unit)
end

function FormulaUtils:GetPlayerVehicleSteerDecelerationScale(isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleSteerDecelerationScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleSteerDecelerationScale(unit)
end

function FormulaUtils:GetPlayerVehicleDriftDecelerationScale(isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleDriftDecelerationScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleDriftDecelerationScale(unit)
end

function FormulaUtils:CalcVisualDetectEventAddValue(detectId, enemyPosition, eyeDirection, eventPos)
	return 0
end

function FormulaUtils:CalcCrouchAssassinationVisualEventValue(detectorPos, detectorEyeDir, targetPos)
	return Formula_cs:CalcCrouchAssassinationVisualEventValue(detectorPos, detectorEyeDir, targetPos)
end

function FormulaUtils:GetInspireHubGamePlayConfigCanShow(cfg)
	if cfg == nil then
		return false
	end

	if not cfg.ShowCondition then
		return true
	end

	return cfg.ShowCondition(this.playerFormula) ~= false
end

function FormulaUtils:GetInspireHubTagConfigCanShow(id)
	local cfg = LTConfig.InspireHubTagConfig.GetConfig(id)

	if cfg == nil then
		return false
	end

	if not cfg.ShowCondition then
		return true
	end

	return cfg.ShowCondition(this.playerFormula) ~= false
end

gFormulaUtils = FormulaUtils

return FormulaUtils
