-- Original chunk: @Lua\LuaFiles\LX6\Utils\FormulaUtils.lua
-- Decompiled from: 02248_FormulaUtils.lua_96c672804f24.luajit

local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local ScriptBattleUnit = require("LX6/Utils/FormulaScriptBattleUnit")
local TaskState = UX.Game.TaskState
local FormulaUtils = {
	["*9\\xe7g\\x91\\xf8:\\x9b'\\xe9\\xe5\\xcbg\\xfc"] = false
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
		if count ~= nil then
			count = 1
		end

		return count > gCommonItemManager:GetPackItemNum(itemTemplateId)
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
		return gTaskManager:GetTaskState(taskId) ~= TaskState.Submited
	end,
	TaskHasAccepted = function (self, taskId)
		return gTaskManager:GetTaskState(taskId) ~= TaskState.Accepted
	end,
	EventHasUnlocked = function (self, eventId)
		return gTaskNodeManager:IsTaskEventUnlock(eventId) or gTaskNodeManager:IsTaskEventSubmit(eventId)
	end,
	HasEventUnlock = function (self, eventId)
		return gTaskNodeManager:IsTaskEventUnlock(eventId)
	end,
	HasEventSubmit = function (self, eventId)
		return gTaskNodeManager:IsTaskEventSubmit(eventId)
	end,
	HasFinishTaskCounter = function (self, taskId, taskCounterIndex)
		return gTaskManager:CheckTaskCounterFinished(taskId, taskCounterIndex)
	end,
	SpiritId = function (self, spiritId)
		return spiritId ~= gCS.MyPlayerManager.PlayerUnit.Pid
	end,
	JobId = function (self, jobId)
		return jobId ~= gSpiritJobManager:GetCurJobId()
	end,
	JobClassId = function (self, jobClassId)
		local jobId = gSpiritJobManager:GetCurJobId()

		return LTConfig.UrbanJobConfig.GetConfig(jobId).JobClass ~= jobClassId
	end,
	HasState = function (self, state)
		return gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, state)
	end,
	UnitHasGameplayTag = function (self, tagId)
		local gameplayConfig = LTConfig.GameplayTagConfig.GetConfig(tagId)
		local unit = gCS.SceneDataMgr.GetUnit(L50.L50App.L50Game.InteractBtnMgr.curCheckTableConditionUnitPid)

		if unit ~= nil or gameplayConfig ~= nil then
			return false
		end

		return unit.HasGameplayTag(unit, tagId)
	end,
	GetAnimalFavorLevel = function (self)
		local unit = gCS.SceneDataMgr.GetUnit(L50.L50App.L50Game.InteractBtnMgr.curCheckTableConditionUnitPid)

		if unit ~= nil then
			return 0
		end

		local animalInfo = gPlayerManager.infoMinorAtmosphereGameplay.bindData.animalInfos[unit.ClientData.SubType]

		if animalInfo then
			return animalInfo.FavorLevel
		end

		return 0
	end,
	IsInRaid = function (self, raidId)
		return gRaidDataManager.RaidId ~= raidId
	end,
	SubQuestHasFinished = function (self, subQuestId)
		local CompletedSubQuestCnt = gPlayerManager.infoAchievement.bindData.CompletedSubQuestCnt

		return CompletedSubQuestCnt[subQuestId] == nil
	end,
	ShowMessage = function (self, messageId, args)
		if this.noDisplayMsg then
			return
		end

		this.isActionShowMsg = true

		gDisplayMessageMgr:ShowMessage(messageId, nil, , args and unpack(args))
	end,
	CanTransformOn = function (self)
		return true
	end,
	HasNotReceiveReward = function (self)
		return gLuaDataManager.receivedRewardEnemies[gLuaDataManager.currentInteractEnemyPid] ~= nil
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
		return gCS.MyPlayerManager.PlayerUnit and (gCS.MyPlayerManager.PlayerUnit.ClientData.SubType ~= LTConfig.FightSpiritConfig.DefaultMale or gCS.MyPlayerManager.PlayerUnit.ClientData.SubType ~= LTConfig.FightSpiritConfig.DefaultFemale)
	end,
	HasFerrisTicket = function (self, index)
		return gFerrisMgr:GetTicketType() ~= index or gFerrisMgr:GetTicketType() ~= 3
	end,
	HasKTVTicket = function (self, ticketId)
		return gKTVGameManager:HasTicket()
	end,
	CanRolePlayKTV = function (self)
		return gKTVGameManager:IsPlayableRole()
	end,
	IsOnlineMode = function (self)
		return gLinkManager:CheckInLinkMode()
	end,
	CheckIsAgentProfileHasReward = function (self, id)
		return gAgentTrustManager:CheckHasRewardCanGot(id)
	end,
	UnitIsPlayer = function ()
		return gCS.MyPlayerManager.PlayerUnit == nil and gCS.MyPlayerManager.PlayerUnit.Pid ~= L50.L50App.L50Game.InteractBtnMgr.curCheckTableConditionUnitPid
	end,
	IsAgentProfileActivate = function (self, id)
		return gAgentTrustManager:GetIfAcquaintedByProfileId(id)
	end,
	IsMoneyMoreThan = function (self, x)
		return x > gPlayerManager.infoItem.bindData.money
	end,
	IsInLinkBasketballLink = function ()
		local linkBasketballManager = gCS.LinkBasketballManager.Instance

		return linkBasketballManager.isInBasketballLink
	end,
	IsInDoubleFerrisInvite = function ()
		return L50.L50App.Scene.FerrisMgr:IsInDoubleInvite()
	end,
	IsMartialArtistQuestCompleted = function (self, id)
		return gMartialArtistManager:IsQuestCompleted(id)
	end,
	IsMartialArtistQuestUnlocked = function (self, id)
		return gMartialArtistManager:IsQuestUnlocked(id)
	end,
	HasHouse = function (self, houseId)
		return gHouseManager:HasHouse(houseId)
	end,
	CanSubmitItemEvent = function (self, eventId)
		return gCommonItemManager:CanSubmitItem(eventId)
	end,
	CheckIsAgentInTemporaryActivity = function (self, agentTag)
		return gNpcDaliyManager.NpcBusyInfo[agentTag] == nil
	end
}

setmetatable(FormulaUtils.playerFormula, BasePlayerFormula)

local BaseNpcCanInteract = {
	__index = function (table, key)
		if key ~= "OpenFunInteractivePanel" then
			this.npcCanInteract.canInteract = false
		else
			this.npcCanInteract.canInteract = true

			return function ()
			end
		end
	end
}
FormulaUtils.npcCanInteract = {}

setmetatable(FormulaUtils.npcCanInteract, BaseNpcCanInteract)

FormulaUtils.CheckPlotInteractCondition = function(self, interactCfgId, index)
	local interactionConfig = LTConfig.AgentDataSetsInteractSettingConfig.GetConfig(interactCfgId)

	if not interactionConfig or not interactionConfig.InteractionRequirements then
		return true
	end

	return interactionConfig.InteractionRequirements(this.playerFormula, index) == false
end

FormulaUtils.CalculateSkillDamage = function(attackerDam, defenderPhyDef, attackerLevel, skillId, triggerIndex)
	return Formula_cs:CalculateSkillDamage(attackerDam, defenderPhyDef, attackerLevel, skillId, triggerIndex)
end

FormulaUtils.GetDestructibleDamageAndForceFromVehicle = function(self, vehicleTemplateId, vehicleMass, velocity, destructibleTemplateId, reactionId, physicMatId, volumeToIndex)
	local damage = 0
	local force = 0
	damage, force = Formula_cs:GetDestructibleDamageAndForceFromVehicle(vehicleTemplateId, vehicleMass, UX.Game.UXVector3.New(velocity.x, velocity.y, velocity.z), destructibleTemplateId, reactionId, physicMatId, volumeToIndex, damage, force)

	return damage, force
end

FormulaUtils.GetSkillDamageToVehicle = function(self, vehicleTemplateId, vehicleMass, vehicleVelocity, skillId, releaserId)
	releaser = nil

	if releaserId and not ulong.equals(releaserId, 0) then
		releaser = ScriptBattleUnit.New(releaserId)
	end

	return Formula_cs:GetSkillDamageToVehicle(vehicleTemplateId, vehicleMass, UX.Game.UXVector3.New(vehicleVelocity.x, vehicleVelocity.y, vehicleVelocity.z), skillId, releaserId, releaser)
end

FormulaUtils.GetContactDamageToVehicle = function(self, vehicleTemplateId, vehicleMass, carVelocityList, RelativeVelocity, objectType, touchMass, enemyWeight, enemyRank, isPlayerOnVehicle, disableThreshold, pid)
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

FormulaUtils.GetPlayerVehicleAccelerationScale = function(self, isPlayerOnVehicle, pid)
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

FormulaUtils.GetPlayerVehicleTopSpeedScale = function(self, isPlayerOnVehicle, pid)
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

FormulaUtils.GetPlayerVehicleGroundMatDriveScale = function(self, isPlayerOnVehicle, pid)
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

FormulaUtils.GetPlayerVehicleBrakeScale = function(self, isPlayerOnVehicle, pid)
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

FormulaUtils.GetPlayerVehicleShiftTimeScale = function(self, isPlayerOnVehicle, pid)
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

FormulaUtils.GetPlayerVehicleSteerDecelerationScale = function(self, isPlayerOnVehicle, pid)
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

FormulaUtils.GetPlayerVehicleDriftDecelerationScale = function(self, isPlayerOnVehicle, pid)
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

FormulaUtils.GetPlayerVehicleFrontCollisionScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleFrontCollisionScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleFrontCollisionScale(unit)
end

FormulaUtils.GetPlayerVehicleSideCollisionScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleSideCollisionScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleSideCollisionScale(unit)
end

FormulaUtils.GetPlayerVehicleWakeDetectRadiusScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleWakeDetectRadiusScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleWakeDetectRadiusScale(unit)
end

FormulaUtils.GetPlayerVehicleWakeRangeAngleScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleWakeRangeAngleScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleWakeRangeAngleScale(unit)
end

FormulaUtils.GetPlayerVehicleWakeMinSpeedScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleWakeMinSpeedScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleWakeMinSpeedScale(unit)
end

FormulaUtils.GetPlayerVehicleWakeMinStayTimeScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleWakeMinStayTimeScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleWakeMinStayTimeScale(unit)
end

FormulaUtils.GetPlayerVehicleWakeTopSpeedScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleWakeTopSpeedScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleWakeTopSpeedScale(unit)
end

FormulaUtils.GetPlayerVehicleWakeAccelScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleWakeAccelScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleWakeAccelScale(unit)
end

FormulaUtils.GetPlayerVehicleResetNoCollisionTimeScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleResetNoCollisionTimeScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleResetNoCollisionTimeScale(unit)
end

FormulaUtils.GetPlayerVehicleNitroAutoAccumSpeedScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleNitroAutoAccumSpeedScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleNitroAutoAccumSpeedScale(unit)
end

FormulaUtils.GetPlayerVehicleNitroDriftAccumSpeedScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleNitroDriftAccumSpeedScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleNitroDriftAccumSpeedScale(unit)
end

FormulaUtils.GetPlayerVehicleNitroAccelScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleNitroAccelScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleNitroAccelScale(unit)
end

FormulaUtils.GetPlayerVehicleNitroTopSpeedScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleNitroTopSpeedScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleNitroTopSpeedScale(unit)
end

FormulaUtils.GetPlayerVehicleNitroConsumeSpeedScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleNitroConsumeSpeedScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleNitroConsumeSpeedScale(unit)
end

FormulaUtils.GetPlayerVehicleCollisionExtraAccelScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleCollisionExtraAccelScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleCollisionExtraAccelScale(unit)
end

FormulaUtils.GetPlayerVehicleCollisionNitroAutoAccumSpeedScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleCollisionNitroAutoAccumSpeedScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleCollisionNitroAutoAccumSpeedScale(unit)
end

FormulaUtils.GetPlayerVehicleCollisionNitroConsumeSpeedScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleCollisionNitroConsumeSpeedScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleCollisionNitroConsumeSpeedScale(unit)
end

FormulaUtils.GetPlayerVehicleWakeNitroTopSpeedScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleWakeNitroTopSpeedScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleWakeNitroTopSpeedScale(unit)
end

FormulaUtils.GetPlayerVehicleWakeNitroAutoAccumSpeedScale = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleWakeNitroAutoAccumSpeedScale", isPlayerOnVehicle, pid)

			return 1
		end
	end

	return Formula_cs:GetPlayerVehicleWakeNitroAutoAccumSpeedScale(unit)
end

FormulaUtils.GetPlayerVehicleWakeAccelExtendTime = function(self, isPlayerOnVehicle, pid)
	local unit = nil

	if isPlayerOnVehicle then
		if pid and not ulong.equals(pid, 0) then
			unit = ScriptBattleUnit.New(pid)
		else
			print_debug("GetPlayerVehicleWakeAccelExtendTime", isPlayerOnVehicle, pid)

			return 0
		end
	end

	return Formula_cs:GetPlayerVehicleWakeAccelExtendTime(unit)
end

FormulaUtils.CalcVisualDetectEventAddValue = function(self, detectId, enemyPosition, eyeDirection, eventPos)
	return 0
end

FormulaUtils.CalcCrouchAssassinationVisualEventValue = function(self, detectorPos, detectorEyeDir, targetPos)
	return Formula_cs:CalcCrouchAssassinationVisualEventValue(detectorPos, detectorEyeDir, targetPos)
end

FormulaUtils.GetInspireHubTagConfigCanShow = function(self, id)
	local cfg = LTConfig.InspireHubTagConfig.GetConfig(id)

	if cfg ~= nil then
		return false
	end

	if not cfg.ShowCondition then
		return true
	end

	return cfg.ShowCondition(this.playerFormula) == false
end

FormulaUtils.GetLinkHubGameplayConfigCanShow = function(self, id)
	local cfg = LTConfig.LinkHubGameplayConfig.GetConfig(id)

	if cfg ~= nil then
		return false
	end

	if not cfg.ShowCondition then
		return true
	end

	return cfg.ShowCondition(this.playerFormula) == false
end

gFormulaUtils = FormulaUtils

return FormulaUtils
