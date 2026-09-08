-- Original chunk: @Lua\LuaGen\Fight\SkillJumpScriptFunc.lua
-- Decompiled from: 00572_SkillJumpScriptFunc.lua_6056973c12f6.luajit

local BaseUnitUtils = LX6.Utils.BaseUnitUtils
local PlayerRouteManager = LX6.Manager.PlayerRouteManager
local AnimationManager = LX6.Units.AnimationManager
local BeCounterType = LX6.SlateData.HState_BeCounterType
local SceneitemConfig = LTConfig.SceneitemConfig
local Orientation = {
	["\\xa7\\xa5\\xa7\\xa2"] = 3,
	["k\\xbc\\xad\\xa1\\xa2"] = 1,
	["X#~P"] = 4,
	["V'{O"] = 2,
	["T-s^"] = 0
}
local OrientationName = {
	[Orientation.None] = "None",
	[Orientation.Front] = "Front",
	[Orientation.Left] = "Left",
	[Orientation.Right] = "Right",
	[Orientation.Back] = "Back"
}
local M = {
	currentActionTag = nil,
	currentHitUnitId = nil
}

M.SetCurrentHitUnitId = function(unitId)
	M.currentHitUnitId = unitId
end

M.ClearCurrentHitUnitId = function()
	M.currentHitUnitId = nil
end

M.GetJumpBoardRawValue = function(key, global)
	return gCS.SkillJumpManager.GetJumpBoardRawValue(key, global)
end

M.GetJumpBoardFloatValue = function(key, global)
	return gCS.SkillJumpManager.GetJumpBoardFloatValue(key, global)
end

M.GetJumpBoardUlongValue = function(key, global)
	return gCS.SkillJumpManager.GetJumpBoardUlongValue(key, global)
end

M.GetJumpBoardIntValue = function(key, global)
	return gCS.SkillJumpManager.GetJumpBoardIntValue(key, global)
end

M.IsTargetHasShieldType = function(shieldType)
	return gCS.SkillJumpManager.IsTargetHasShieldType(shieldType)
end

M.IsReplaceTargetHasShieldType = function(shieldType)
	return gCS.SkillJumpManager.IsReplaceTargetHasShieldType(shieldType)
end

M.GetJumpTargetBuffTierCount = function(buffId)
	return gCS.SkillJumpManager.GetJumpTargetBuffTierCount_CS(buffId)
end

M.GetReplaceTargetBuffTierCount = function(buffId)
	return gCS.SkillJumpManager.GetReplaceTargetBuffTierCount(buffId)
end

M.GetJumpUnitBuffTierCount = function(buffId)
	return gCS.SkillJumpManager.GetJumpUnitBuffTierCount(buffId)
end

M.GetSkillReplaceUnitBuffTierCount = function(buffId)
	return gCS.SkillJumpManager.GetReplaceUnitBuffTierCount(buffId)
end

M.GetPlayerUnitBuffTierCount = function(buffId)
	return gCS.SkillJumpManager.GetPlayerBuffTierCount(buffId)
end

M.GetLatestWeakUnitPid = function()
	return gCS.SkillJumpManager.GetLatestWeakUnitPid()
end

M.GetCurrentWeaponConfigId = function()
	return gCS.SkillJumpManager.GetCurrentRealWeaponId()
end

M.GetPlayerForwardToReplaceTargetAngle = function()
	return gCS.SkillJumpManager.GetPlayerForwardToReplaceTargetAngle()
end

M.IsPlayerForwardToReplaceTargetWithin = function(minAngle, maxAngle)
	return gCS.SkillJumpManager.IsPlayerForwardToReplaceTargetWithin(minAngle, maxAngle)
end

M.CheckMeHasZone = function(zoneId)
	return gCS.SkillJumpManager.CheckMeHasZone_CS(zoneId)
end

M.GetHurtImpact = function()
	return gCS.SkillJumpManager.GetHurtImpact_CS()
end

M.GetHurtFirmLevel = function()
	return gCS.SkillJumpManager.GetHurtFirmLevel_CS()
end

M.IsBlockHitLevel = function(level)
	if M.GetHurtFirmLevel() > 5 then
		return false
	end

	local impact = M.GetHurtImpact()

	if level ~= "Light" then
		return impact ~= 1
	elseif level ~= "Medium" then
		return impact ~= 2 or impact ~= 3
	elseif level ~= "Heavy" then
		return impact < 4
	end

	return false
end

M.IsCameraOnUnitLeftWithoutLock = function()
	return gCS.SkillJumpManager.IsCameraOnUnitsLeft()
end

M.GetLockTargetToTerrainKillAngle = function()
	return gCS.SkillJumpManager.GetLockTargetToTerrainKillAngle_CS()
end

M.GetLastSkillHitEnemyPid = function()
	return gCS.SkillJumpManager.GetLastSkillHitEnemyPid()
end

M.IsLockTargetInTerrainKillFront = function()
	return gCS.SkillJumpManager.IsLockTargetInFrontOfTerrainKill()
end

M.GetSkillReplaceTargetToNearestWallDistance = function()
	return gCS.SkillJumpManager.GetSkillReplaceTargetToNearestWallDistance_CS()
end

M.GetSkillJumpTargetToNearestWallDistance = function()
	return gCS.SkillJumpManager.GetSkillJumpTargetToNearestWallDistance()
end

M.GetPlayerToSkillReplaceTargetForwardAngle = function()
	return gCS.SkillJumpManager.GetPlayerToSkillReplaceTargetForwardAngle()
end

M.GetOrientationEnemyCount = function(orientation, dis)
	local orientationInt = Orientation[orientation]

	return gCS.SkillJumpManager.Instance:GetOrientationEnemyCount(orientationInt, dis)
end

M.GetNewLockEnemyToSkillReplacePlayerOrientation = function()
	local orientation = gCS.SkillJumpManager.GetReplaceEnemyToPlayerOrientation()

	return OrientationName[orientation]
end

M.GetTargetOrienTationFromPlayer = function()
	local orientation = gCS.SkillJumpManager.Instance:GetTargetOrientationFromPlayer()

	return OrientationName[orientation]
end

M.IsNewLockEnemyInDistance = function(lowerBound, upperBound)
	return gCS.SkillJumpManager.IsReplaceEnemyInDistance(lowerBound, upperBound)
end

M.GetReplaceMindTargetDistance = function()
	return gCS.SkillJumpManager.GetToMindAimDistance()
end

M.GetCurrentLockTargetOrientation = function()
	local orientation = gCS.SkillJumpManager.Instance:GetCurrentActiveSkillJumpToLockTargetOrientation()

	return OrientationName[orientation]
end

M.GetCounterTargetToPlayerOrientation = function()
	local orientation = gCS.SkillJumpManager.Instance:GetCounterTargetToPlayerOrientation_CS()

	return OrientationName[orientation]
end

M.IsSkillReplaceTargetFrontToPlayer = function()
	return gCS.SkillJumpManager.Instance:IsSkillReplaceTargetFrontToPlayer()
end

M.GetSkillReplaceTargetForwardAngleFromPlayer = function()
	return gCS.SkillJumpManager.Instance:GetSkillReplaceTargetForwardAngleFromPlayer()
end

M.GetSkillReplaceTargetOrientationEnemyCount = function(orientation, dis)
	return gCS.SkillJumpManager.Instance:GetSkillReplaceTargetOrientationEnemyCount(Orientation[orientation], dis)
end

M.GetSkillReplaceOrientationEnemyCount = function(orientation, dis)
	return gCS.SkillJumpManager.Instance:GetSkillReplaceOrientationEnemyCount_CS(Orientation[orientation], dis)
end

M.GetSkillReplaceTargetOrientationFromPlayer = function()
	return OrientationName[gCS.SkillJumpManager.Instance:GetSkillReplaceTargetOrientationFromPlayer()]
end

M.GetCurrentRealWeaponDurability = function()
	local durability = gCS.SkillJumpManager.GetCurrentRealWeaponDurability_CS()

	return durability
end

M.GetCurrentGunCanReload = function()
	return gCS.SkillJumpManager.GetCurrentGunCanReload()
end

M.CheckCurrentActiveSkillJumpHasActiveSkillAndHit = function()
	local hitCount = gCS.SkillJumpManager.Instance:GetCurrentSkillJumpSkillHitCount()

	if gCS.BattleManager.IsUseNewComboDebug then
		print_warn("CheckCurrentActiveSkillJumpHasActiveSkillAndHit ends, hitCount: " .. hitCount)
	end

	return hitCount >= 0
end

M.CheckHitUnitBodyType = function(bodyType)
	if M.currentHitUnitId ~= nil then
		if gCS.BattleManager.IsUseNewComboDebug then
			print_warn("CheckHitUnitBodyType ends, currentHitUnitId is nil")
		end

		return false
	end

	return gCS.SkillJumpManager.CheckHitUnitBodyTyp_CS(M.currentHitUnitId, bodyType)
end

M.GetCurrentToughness = function()
	if M.currentHitUnitId ~= nil then
		if gCS.BattleManager.IsUseNewComboDebug then
			print_warn("GetCurrentToughness ends, currentHitUnitId is nil")
		end

		return 0
	end

	local ret = gCS.SkillJumpManager.GetCurrentToughness_CS(M.currentHitUnitId)

	return ret
end

M.CheckHitUnitEnemyClassType = function(enemyClassType)
	if M.currentHitUnitId ~= nil then
		if gCS.BattleManager.IsUseNewComboDebug then
			print_warn("CheckHitUnitEnemyClassType ends, currentHitUnitId is nil")
		end

		return false
	end

	return gCS.SkillJumpManager.CheckHitUnitEnemyClassType_CS(M.currentHitUnitId, enemyClassType)
end

M.IsHitUnitTheLockTarget = function()
	if gCS.BattleManager.IsUseNewComboDebug then
		print_warn("CheckHitUnitIsLockTarget begins")
	end

	if M.currentHitUnitId ~= nil then
		if gCS.BattleManager.IsUseNewComboDebug then
			print_warn("CheckHitUnitIsLockTarget ends, currentHitUnitId is nil")
		end

		return false
	end

	if gCS.BattleManager.IsUseNewComboDebug then
		print_warn("CheckHitUnitIsLockTarget ends, the result: ", ulong.equals(M.currentHitUnitId, gCS.LockTargetMgr:GetLockEnemyId()))
	end

	return ulong.equals(M.currentHitUnitId, gCS.LockTargetMgr:GetLockEnemyId())
end

M.CheckLockUnitBodyType = function(bodyType)
	return gCS.SkillJumpManager.CheckLockUnitBodyType_CS(bodyType)
end

M.GetLockUnitBodyType = function()
	return gCS.SkillJumpManager.GetLockUnitBodyType_CS()
end

M.CheckLockUnitEnemyClassType = function(enemyClassType)
	return gCS.SkillJumpManager.CheckLockUnitEnemyClassType_CS(enemyClassType)
end

M.GetLockUnitToughness = function()
	return gCS.SkillJumpManager.GetLockTargetToughness()
end

M.GetDistanceToLockedUnitHorizontally = function()
	return gCS.SkillJumpManager.GetDistanceToLockedUnitHorizontally_CS()
end

M.GetPlayerHeightToGround = function()
	if not gCS.SkillJumpManager.MeExist() then
		if gCS.BattleManager.IsUseNewComboDebug then
			print_warn("GetPlayerHeightToGround ends, me is nil")
		end

		return 0
	end

	local height = gCS.MyPlayerManager.PlayerUnit:GetFloorHeightOffsetWithWater()

	if gCS.BattleManager.IsUseNewComboDebug then
		print_warn("GetPlayerHeightToGround ends, the height: " .. height)
	end

	return height
end

M.GetDistanceToLockedUnitVertically = function()
	return gCS.SkillJumpManager.GetDistanceToLockedUnitVertically_CS()
end

M.GetHeightToGroundOfLockedUnit = function()
	return gCS.SkillJumpManager.GetHeightToGroundOfLockedUnit_CS()
end

M.IsCurrentActionHaveTag = function(tag)
	if M.currentActionTag ~= nil then
		return false
	end

	return M.currentActionTag ~= tag
end

M.IsHaveLockUnit = function()
	return gCS.LockTargetMgr:IsLockAny()
end

M.IsWeakLockAny = function()
	return gCS.LockTargetMgr:IsWeakLockAny()
end

M.IsPressAngle = function(minAngle, maxAngle, clampMin, clampMax)
	if clampMin and clampMax then
		return gCS.SkillJumpManager.IsPressAngleClamp(minAngle, maxAngle, clampMin, clampMax)
	else
		return gCS.SkillJumpManager.IsPressAngleNoClamp(minAngle, maxAngle)
	end
end

M.GetKeyDirectionAngleDiff = function(minAngle, maxAngle)
	if not gUnitOperateManager.isOnJoystickMove then
		return false
	end

	local angle = gCS.LuaUtils.GetKeyDirectionAngleDiff()

	return minAngle < angle and angle > maxAngle
end

M.IsDistance = function(distance)
	return gCS.SkillJumpManager.IsDistance_CS(distance)
end

M.IsOnJoystick = function()
	return gUnitOperateManager.isOnJoystickMove
end

M.IsLeftJoystick = function(angle1, angle2)
	if not gUnitOperateManager.isOnJoystickMove then
		return false
	end

	local valid = false
	local vecx = 0
	local vecz = 0
	valid, vecx, vecz = gCS.SkillJumpManager.GetLockUnitToMeVec_CS(0, 0)

	if not valid then
		return false
	end

	local lockUnit2MeDir = Vector2.New(vecx, vecz)
	local keyDownDir = gCS.MyPlayerManager.PlayerUnit.State.KeyDownDirection
	local keyDownDir2 = Vector2.New(keyDownDir.x, keyDownDir.z)
	local angle = -Vector2.SignedAngle(lockUnit2MeDir, keyDownDir2)

	return angle1 < angle and angle > angle2
end

M.IsRightJoystick = function(angle1, angle2)
	if not gUnitOperateManager.isOnJoystickMove then
		return false
	end

	local valid = false
	local vecx = 0
	local vecz = 0
	valid, vecx, vecz = gCS.SkillJumpManager.GetLockUnitToMeVec_CS(0, 0)

	if not valid then
		return false
	end

	local lockUnit2MeDir = Vector2.New(vecx, vecz)
	local keyDownDir = gCS.MyPlayerManager.PlayerUnit.State.KeyDownDirection
	local keyDownDir2 = Vector2.New(keyDownDir.x, keyDownDir.z)
	local angle = Vector2.SignedAngle(lockUnit2MeDir, keyDownDir2)

	return angle1 < angle and angle > angle2
end

M.IsLockEnemyAngleDiff = function(minAngle, maxAngle, range, effectTarget)
	if not gCS.LockTargetMgr:IsStrongLockAnyEnemy() then
		return false
	end

	local unit = gCS.SceneDataMgr.GetUnit(gCS.LockTargetMgr:GetLockEnemyId())

	if not unit then
		return false
	end

	local angle = gCS.LuaUtils.GetUnitToMeAngleDiff(unit.Pid)

	if minAngle < angle and angle < maxAngle then
		return true
	end

	return false
end

M.IsNearHaveEnemy = function(range, effectTarget)
	return gCS.SkillJumpManager.IsNearHaveEnemy_CS(range, effectTarget)
end

M.GetNearUnitCount = function(range, angle, effectTarget)
	local count = gCS.FightDataMgr:GetNearUnitCount(gCS.MyPlayerManager.PlayerUnit, range, angle, effectTarget or 0)

	return count
end

M.IsLockEnemyHaveLockUnit = function(range, effectTarget)
	if not gCS.LockTargetMgr:IsStrongLockAnyEnemy() then
		return false
	end

	local unit = gCS.SceneDataMgr.GetUnit(gCS.LockTargetMgr:GetLockEnemyId())

	if not unit then
		return false
	end

	return not ulong.equals(unit.LockTargetId, 0)
end

M.IsLockEnemyLockMe = function(range, effectTarget)
	if not gCS.LockTargetMgr:IsStrongLockAnyEnemy() then
		return false
	end

	local unit = gCS.SceneDataMgr.GetUnit(gCS.LockTargetMgr:GetLockEnemyId())

	if not unit then
		return false
	end

	return ulong.equals(unit.LockTargetId, gCS.SkillJumpManager.MeUnitID())
end

M.IsMyUnitHaveBuff = function(buffid)
	return gBuffUtils.HasBuff(gCS.SkillJumpManager.MeUnitID(), buffid)
end

M.IsLockUnitHaveBuff = function(buffid)
	if not gCS.LockTargetMgr:IsStrongLockAnyEnemy() then
		if gCS.BattleManager.IsUseNewComboDebug then
			print_warn("IsLockUnitHaveBuff: Not strongly locking any enemy, returning false")
		end

		return false
	end

	local result = gBuffUtils.HasBuff(gCS.LockTargetMgr:GetLockEnemyId(), buffid)

	if gCS.BattleManager.IsUseNewComboDebug then
		print_warn("IsLockUnitHaveBuff: Lock unit has buff " .. buffid .. ": " .. tostring(result))
	end

	return result
end

M.IsSkillReplaceTargetHasBuff = function(buffId)
	return gCS.SkillJumpManager.SkillReplaceTargetHasBuff(buffId)
end

M.IsSkillReplaceTargetHasState = function(stateId)
	return gCS.SkillJumpManager.SkillReplaceUnitHasState(stateId)
end

M.IsCommonBodyType = function(type)
	return false
end

M.DistanceToGround = function(dis)
	return gCS.SkillJumpManager.CheckDistanceToGround_CS(dis)
end

M.IsAutoBlock = function(dir)
	if M.GetHurtFirmLevel() < 5 or M.GetHurtFirmLevel() < 0 then
		return false
	end

	return gCS.SkillJumpManager.IsAutoBlock_CS(dir)
end

M.CheckSpawnItemClipSceneItemByConfigId = function(configId)
	return gCS.SkillJumpManager.CheckSpawnItemClipSceneItemByConfigId(configId)
end

M.CheckSpawnItemClipSceneItemByType = function(itemType)
	return gCS.SkillJumpManager.CheckSpawnItemClipSceneItemByType(itemType)
end

M.CheckSpawnItemClipSceneItemBySubType = function(itemSubType)
	return gCS.SkillJumpManager.CheckSpawnItemClipSceneItemBySubType(itemSubType)
end

M.CurrentAniPlayTime = function(time)
	return time > AnimationManager.GetCurrentActionTime(gCS.MyPlayerManager.PlayerUnit, 0)
end

M.IsInBattleFight = function()
	return gBattleMgr.isBattleUI
end

M.IsClimbing = function()
	return gPlayerManager.main.bindData.isInClimbing
end

M.IsMeHaveState = function(state)
	return gCS.SkillJumpManager.MeHasState_CS(state)
end

M.IsLockUnitHaveState = function(state)
	return gCS.SkillJumpManager.IsLockUnitHasState_CS(state)
end

M.IsWeakLockUnitHaveState = function(state)
	return gCS.SkillJumpManager.IsWeakLockUnitHaveState_CS(state)
end

M.IsOnBaiDang = function()
	return gPlayerManager.main.bindData.isSwing
end

M.IsJump = function()
	return false
end

M.LastPressDownJoystickTime = function()
	return gCS.SkillJumpManager.Instance:GetLastPressDownJoyStickTime()
end

M.LastPressLeftJoystickTime = function()
	return gCS.SkillJumpManager.Instance:GetLastPressLeftJoyStickTime()
end

M.LastPressRightJoystickTime = function()
	return gCS.SkillJumpManager.Instance:GetLastPressRightJoyStickTime()
end

M.LastPressUpJoystickTime = function()
	return gCS.SkillJumpManager.Instance:GetLastPressUpJoyStickTime()
end

M.CurrentTime = function()
	return Time.realtimeSinceStartup
end

M.IsInActionGroup = function(groupId)
	local valid = false
	local nowActionID = 0
	local nowActionGroupID = 0
	valid, nowActionID, nowActionGroupID = gCS.SkillJumpManager.GetMeAction_CS(0, 0)

	if valid ~= true then
		return nowActionGroupID ~= groupId
	end

	return false
end

M.IsInActionId = function(actionId)
	local valid = false
	local nowActionID = 0
	local nowActionGroupID = 0
	valid, nowActionID, nowActionGroupID = gCS.SkillJumpManager.GetMeAction_CS(0, 0)

	if valid ~= true then
		return nowActionID ~= actionId
	end

	return false
end

M.IsSkillBtnPress = function(index)
	return gCS.SkillJumpManager.Instance:GetSkillButtonPressState(index)
end

M.GetSkillBtnPressTime = function(index)
	if gCS.SkillJumpManager.Instance:HasSkillButtonPressInfo(index) then
		return gCS.SkillJumpManager.Instance:GetSkillButtonPressTime(index)
	else
		return -1
	end
end

M.IsHaveMindItem = function()
	return gPlayerManager.main.bindData.hasMindPowerTarget
end

M.IsRunOrRush = function()
	return gCS.SkillJumpManager.IsRunOrRush()
end

M.IsRush = function()
	return gCS.SkillJumpManager.IsRush()
end

M.GetParkourState = function()
	return gCS.PaoKuManager.ParkourStateLua
end

M.IsOnSkillState = function()
	return gCS.SkillJumpManager.IsMeOnSkillState_CS()
end

M.IsMindSkillReplace = function()
	return gCS.SkillJumpManager.IsMeMindSkillReplace_CS()
end

M.IsCastSkillId = function(skillId)
	return gCS.SkillJumpManager.IsMeCastSkillID_CS(skillId)
end

M.IsCastSkillSettled = function()
	return gCS.SkillJumpManager.IsCastSkillSettled_CS()
end

M.IsCastSkillOnCD = function(skillId)
	if skillId and skillId <= 0 then
		return not gCS.BattleManager.IsCDFinished(skillId)
	end

	return false
end

M.IsLockAnyEnemy = function()
	return gCS.LockTargetMgr:IsLockAnyEnemy()
end

M.LockDestructibleId = function()
	return gCS.SkillJumpManager.GetMindLockItemTemplateId()
end

M.IsInFeiSuoCrouch = function()
	return gPlayerManager.main.bindData.isFeiSuoCrouch
end

M.ReplaceTargetOutDistance = function(distance)
	return gCS.SkillJumpManager.ReplaceTargetOutOfDistance(distance)
end

M.OutDistance = function(distance)
	return gCS.SkillJumpManager.OutDistance_CS(distance)
end

M.csSkillData = nil
M.isDebugging = false
M.CallReasonType = {
	["pLeeB4("] = 1,
	["ԑ\\xe02\\xe9\\xee\\x81\\xf9\\x8b/&"] = 2,
	["T-s^"] = 0
}
M.callReason = M.CallReasonType.None
M.unitPid = nil
M.isSwitchSpiritDodgeAttack = false

M.ClearSkillConditionData = function()
	M.isSwitchSpiritDodgeAttack = false
end

M.EnableDebug = function(enable)
	M.isDebugging = enable
end

M.TestTrue = function()
	return true
end

M.TestFalse = function()
	return false
end

M.DebugLog = function(...)
	if M.csSkillData then
		print_error("技能条件Log信息  |  pid：" .. ulong.tostring(M.unitPid), "UUID：" .. M.csSkillData.skillUUID, "skillId：" .. M.csSkillData.skillId .. "  |  ", ...)

		return
	end
end

M.IsSwitchSpiritDodgeAttack = function()
	return M.isSwitchSpiritDodgeAttack
end

M.HasBuff = function(buffID)
	return gBuffUtils.HasBuff(M.unitPid, buffID)
end

M.CheckFightSpiritID = function(SpiritID)
	local CurSpiritId = gBattleSpiritMgr.currentSpiritTemplateId

	return CurSpiritId ~= SpiritID
end

M.CheckClipHasHit = function(triggerIndex)
	if M.csSkillData then
		return gCS.SkillHelper:GetClipHasHit(M.csSkillData.pid, M.csSkillData.skillUUID, triggerIndex)
	end

	return false
end

M.HasLockTarget = function()
	if M.callReason ~= M.CallReasonType.SkillCondition and M.csSkillData then
		return not ulong.equals(M.csSkillData.targetId, 0)
	end

	return gCS.LockTargetMgr:IsLockAnyEnemy()
end

M.CheckLockTargetDistance = function(distance)
	if not M.HasLockTarget() then
		return false
	end

	if M.csSkillData then
		return gUtils:GetDistance(M.csSkillData.lockData:GetPosition(), M.csSkillData.unit.LocalPosition) <= distance
	end

	return false
end

M.CheckLockTargetHasState = function(unitState)
	if not M.HasLockTarget() then
		return false
	end

	if M.csSkillData then
		return gCS.SkillJumpManager.HasState_CS(M.csSkillData.targetId, unitState)
	end

	return false
end

M.CheckLockTargetHasBuff = function(buffId)
	if not M.HasLockTarget() then
		return false
	end

	if M.csSkillData then
		return gBuffUtils.HasBuff(M.csSkillData.targetId, buffId)
	end

	return false
end

M.CheckLockTargetIsMe = function()
	if not M.HasLockTarget() then
		return false
	end

	if M.csSkillData then
		local unitLockData = M.csSkillData.lockData

		return unitLockData.unit.IsMe
	end

	return false
end

M.IsCameraLockBoss = function()
	return gCS.CameraDataMgr.cinemachineManager.isLockingBoss
end

M.IsTargetOnForwardRange = function(minAngle, maxAngle)
	if not M.HasLockTarget() then
		return false
	end

	local tarPos = nil

	if M.csSkillData then
		tarPos = M.csSkillData.lockData:GetPosition()
	end

	local unit = gCS.SceneDataMgr.GetUnit(M.unitPid)
	local dir = tarPos - unit.LocalPosition
	local angle = BaseUnitUtils.GetAngle(unit.Forward, dir)
	local ok = minAngle < angle and angle > maxAngle

	return ok
end

M.CheckMeHasState = function(unitStateId)
	return gCS.SkillJumpManager.MeHasState_CS(unitStateId)
end

M.IsUltCameraOpen = function()
	return gCS.CameraDataMgr.cinemachineManager.enableAnimCamera
end

M.GetChargeWeaponValue = function()
	if M.csSkillData then
		return M.csSkillData.chargeHoldWeapon
	end

	return 0
end

M.IsSkillMindFinish = function()
	local mType = 0
	local mId = 0

	if M.csSkillData then
		mType = M.csSkillData.mindPowerItemType
		mId = M.csSkillData.mindPowerItemId
	end

	if mType ~= MindPowerConst.MindObjType.None then
		return true
	end

	return gCS.MindPowerMgr:GetCanMindItem(mType, mId) ~= nil
end

M.IsFromCanYingMindPower = function()
	return gCS.SkillJumpManager.IsFromCanYingMindPower()
end

M.ShanBiBreakTimeSwitch = function()
	return not gBattleSwitch.ShanBiBreakTimeSwitch
end

M.NormalAttackBreakSwitch = function()
	return not gBattleSwitch.NormalAttackBreakSwitch
end

M.beforeSwitchSpiritIsBattle = false

M.BeforeSwitchSpiritIsBattle = function()
	return gSkillJumpScriptFunc.beforeSwitchSpiritIsBattle
end

M.GetCustomSwitch = function(index)
	if gBattleSwitch.CustomSwitch[index] then
		return gBattleSwitch.CustomSwitch[index].active
	end

	return false
end

M.IsHaveEnemyByDistance = function(enemyId, distance)
	return gCS.SkillJumpManager.IsHaveEnemyByDistance_CS(enemyId, distance)
end

M.IsCameraOnUnitLeft = function()
	if not gCS.SkillJumpManager.MeExist() then
		return false
	end

	if gCS.LockTargetMgr:IsLockAnyEnemy() then
		return M.IsCameraOnUnitToLockLeft()
	else
		return M.IsCameraOnUnitFaceLeft()
	end
end

M.IsCameraOnUnitToLockLeft = function()
	local unitToLockDir = Vector3.zero
	local unitToCameraDir = Vector3.zero
	local valid = false
	valid, unitToLockDir, unitToCameraDir = gCS.SkillJumpManager.Getu2lAndu2cDir_CS(Vector3.zero, Vector3.zero)

	if not valid then
		return false
	end

	local angle = -gUtils:FormatAngle180(BaseUnitUtils.GetAngle(unitToLockDir, unitToCameraDir))

	return angle >= 0
end

M.IsCameraOnUnitFaceLeft = function()
	local valid = false
	local unitToCameraDir = Vector3.zero
	valid, unitToCameraDir = gCS.SkillJumpManager.Getu2cDir_CS(Vector3.zero)

	if not valid then
		return false
	end

	local face = gCS.MyPlayerManager.PlayerUnit.Forward
	local angle = -gUtils:FormatAngle180(BaseUnitUtils.GetAngle(face, unitToCameraDir))

	return angle >= 0
end

M.IsCameraToPlayerDirIn = function(minAngle, maxAngle)
	return gCS.SkillJumpManager.IsCameraToPlayerDirIn(minAngle, maxAngle)
end

M.GetIllusionBlendDistance = function(triggerIndex)
	return 0
end

M.CheckEffectClipPlayed = function(triggerIndex)
	return gCS.SkillHelper:CheckEffectClipPlayed(M.unitPid, M.csSkillData.skillUUID, triggerIndex)
end

M.GetSkillResourceCountById = function(id)
	local flag, value, isFull, isFree, maxValue = nil
	flag, value, maxValue, isFull, isFree = gCS.BattleManager.GetFightResource(gCS.MyPlayerManager.PlayerUnit, id, value, maxValue, isFull, isFree)

	return value
end

M.HasEnoughSkillResource = function()
	return gCS.SkillJumpManager.HasEnoughSkillResource()
end

M.CheckTaiJiState = function(state)
	local res8 = M.GetSkillResourceCountById(8)
	local res10 = M.GetSkillResourceCountById(10)

	if state ~= "Yang" then
		return res8 ~= 100 and res10 ~= 0
	elseif state ~= "Yin" then
		return res8 ~= 0 and res10 ~= 100
	elseif state ~= "Balance" then
		return res8 ~= 100 and res10 ~= 100
	end

	return false
end

M.randMinValue = 1
M.randMaxValue = 100
M.randValue = 0
M.randFrame = Time.frameCount

M.RandomValue = function(min, max)
	if M.randFrame == Time.frameCount then
		M.randValue = Mathf.Random(M.randMinValue, M.randMaxValue)
		M.randFrame = Time.frameCount
	end

	return min < M.randValue and M.randValue > max
end

M.GetRandomNumberFromX = function(x)
	local randomNumber = gCS.SkillJumpManager.GetDifferentRandomNumber(x)

	if gCS.BattleManager.IsUseNewComboDebug then
		print_warn("GetRandomNumber ends, the random number: " .. randomNumber)
	end

	return randomNumber
end

M.randNumbers = {}
M.randNumber = 0
M.randNumberFrame = 0

M.GetRandomNumber = function()
	if #M.randNumbers ~= 0 then
		for i = 1, 6 do
			table.insert(M.randNumbers, i)
		end

		math.randomseed(os.time())

		for i = #M.randNumbers, 2, -1 do
			local j = math.random(i)
			M.randNumbers[j] = M.randNumbers[i]
			M.randNumbers[i] = M.randNumbers[j]
		end
	end

	if M.randNumberFrame == Time.frameCount then
		M.randNumber = table.remove(M.randNumbers, #M.randNumbers)
		M.randNumberFrame = Time.frameCount
	end

	return M.randNumber
end

M.CheckDodgeDirection = function(type)
	return type ~= gCS.DodgeCounterMgr.dodgeDirection
end

M.CheckCanDodgeCounter = function()
	return gCS.DodgeCounterMgr.GetCounterScore(BeCounterType.DoegeCounterAttack)
end

M.GetDodgeScore = function()
	return gCS.DodgeCounterMgr.GetCounterScore(BeCounterType.DoegeCounterAttack)
end

M.GetBlockScore = function()
	return gCS.DodgeCounterMgr.GetCounterScore(BeCounterType.BlockCounterAttack)
end

M.GetBeDodgeCounterSkillId = function()
	return gCS.DodgeCounterMgr.GetBeDodgeCounterSkillId()
end

M.GetCounterLevel = function()
	return gCS.DodgeCounterMgr.curThreatLevel
end

M.ResetStartTime = function()
	print_error("skilljumpscriptfunc resetstarttime无实现")
end

M.IsGadgetTerrainKillingTemplate = function(cfgId)
	return gCS.BattleManager.IsGadgetTerrainKillingTemplate(cfgId)
end

M.IsCurrentIsRoarRadio = function()
	if M.unitPid ~= nil then
		return false
	end

	return gRoarPlayerManager:IsCurrentRoarRadio(M.unitPid)
end

M.IsCurrentWeaponIsRoarRadio = function()
	return gRoarPlayerManager:IsCurrentRoarRadio(gCS.WeaponMgr.GetCurrentWeaponInstanceId())
end

M.IsStiffDownUp = function()
	return gCS.SkillJumpManager.IsStiffDownUp_CS()
end

M.GetWeaponActionType = function()
	return gCS.BattleManager.GetWeaponActionType(gCS.SkillJumpManager.MeUnitID())
end

M.IsInShoulderFire = function()
	return gCS.GunModule.IsMeInShoulderFire
end

M.CSSkillClipRunCondition = function(self, skillData, conditionStr)
	conditionStr = "local M = gSkillJumpScriptFunc " .. conditionStr
	local func = load(conditionStr, nil, "t")

	if func then
		gSkillJumpScriptFunc.unitPid = skillData.pid
		gSkillJumpScriptFunc.csSkillData = skillData

		M:SetSkillJumpScriptFuncCallReason(M.CallReasonType.SkillCondition)

		local status, ret = xpcall(func, tolua.traceback)

		M:SetSkillJumpScriptFuncCallReason(M.CallReasonType.None)

		gSkillJumpScriptFunc.csSkillData = nil

		if status then
			return ret
		end

		print_warn("【技能编辑器】CSSkillClipRunCondition 报错，请检查技能Clip条件是否正确", "SKillUUID", skillData.skillUUID, "SkillId", skillData.skillId, "conditionStr", conditionStr, "status", status, "ret", ret)

		return false
	end

	print_warn("【技能编辑器】CSSkillClipRunCondition 报错，请检查技能Clip条件是否正确", "SKillUUID", skillData.skillUUID, "SkillId", skillData.skillId, "conditionStr", conditionStr, "func = nil")

	return false
end

M.CSSkillEnterRunCondition = function(self, pid, skillId, conditionStr)
	conditionStr = "local M = gSkillJumpScriptFunc " .. conditionStr
	local func = load(conditionStr, nil, "t")

	if func then
		gSkillJumpScriptFunc.unitPid = pid
		local status, ret = xpcall(func, tolua.traceback)

		if status then
			return ret
		end

		print_warn("【技能编辑器】CSSkillEnterRunCondition 报错，请检查技能checkCondition条件是否正确", "SkillId", skillId, "conditionStr", conditionStr, "status", status, "ret", ret)

		return false
	end

	print_warn("【技能编辑器】CSSkillEnterRunCondition 报错，请检查技能checkCondition条件是否正确", "SkillId", skillId, "conditionStr", conditionStr, "func = nil")

	return false
end

M.RunSkillJumpScriptFuncCode = function(self, code, reason)
	M:SetSkillJumpScriptFuncCallReason(reason)

	local ret = M:ExecuteCode(code)

	M:SetSkillJumpScriptFuncCallReason(M.CallReasonType.None)

	return ret
end

M.ExecuteCode = function(self, code)
	local f, msg = load(code, nil, "t", gSkillJumpScriptFunc)

	if f then
		local status, ret = xpcall(f, tolua.traceback)

		if not status then
			print_warn("RunSkillJumpScriptFuncCode code " .. code .. " Failed: ", ret)

			return false
		end

		return ret
	end

	print_warn("Compile code " .. code .. "Failed: " .. msg)

	return false
end

M.SetSkillJumpScriptFuncCallReason = function(self, reason)
	gSkillJumpScriptFunc.callReason = reason
end

M.ClearSkillJumpSkillConditionData = function(self)
	gSkillJumpScriptFunc.ClearSkillConditionData()
end

M.GetJoystickDirection = function(fromAngle, toAngle)
	return gCS.SkillJumpManager.GetJoystickDirection(fromAngle, toAngle)
end

local GetLockUnitHpRatio = function()
	if not gCS.LockTargetMgr:IsLockAnyEnemy() then
		return 1
	end

	local unit = gCS.SceneDataMgr.GetUnit(gCS.LockTargetMgr:GetLockEnemyId())

	if not unit then
		return 1
	end

	local maxHp = unit.ClientData.MaxHp

	if maxHp < 0 then
		return 1
	end

	return unit.ClientData.Hp / maxHp
end

local IsLockUnitBoss = function()
	return gCS.SkillJumpManager.CheckLockUnitEnemyClassType_CS(2)
end

M.IsPerfectBlock = function(direction)
	local hasState = M.CheckMeHasState(10389)
	local counterLevel = M.GetCounterLevel()
	local dodgeDir = gCS.DodgeCounterMgr.dodgeDirection
	local dirMap = {
		["\\xa7\\xa5\\xa7\\xa2"] = 1,
		["V'{O"] = 3,
		["k\\xbc\\xad\\xa1\\xa2"] = 2
	}
	local dirType = dirMap[direction]

	if not hasState then
		return false
	end

	if counterLevel == 2 then
		return false
	end

	if dirType ~= nil then
		return false
	end

	return M.CheckDodgeDirection(dirType)
end

M.IsBlockCounter = function(counterType, orientation)
	orientation = orientation or "Front"
	local actualOrientation = M.GetCounterTargetToPlayerOrientation()

	if orientation ~= "Front" and (actualOrientation ~= "Left" or actualOrientation ~= "Right") then
		actualOrientation = "Front"
	end

	if actualOrientation == orientation then
		return false
	end

	if not M.CheckMeHasState(10389) then
		return false
	end

	local hpRatio = GetLockUnitHpRatio()
	local actualType = nil
	local canBig = M.GetCounterLevel() ~= 1
	local canSmall = M.GetCounterLevel() ~= 1 and M:GetLockUnitBodyType() <= 0 and M.GetLockUnitToughness() <= 3

	if hpRatio >= 0.4 then
		if canBig then
			actualType = "big"
		elseif canSmall then
			actualType = "small"
		end
	elseif canSmall then
		actualType = "small"
	end

	return actualType ~= counterType
end

M.GetPlayerAttr = function(attrType)
	return gCS.SkillJumpManager.GetPlayerAttr(attrType)
end

M.GetTaskState = function(taskId)
	return gCS.SkillJumpManager.GetTaskState(taskId)
end

M.GetCurrentTakeItemMode = function()
	return gCS.SkillJumpManager.GetCurrentTakeItemMode()
end

M.GetMindDestructibleTid = function()
	local mType = 0
	local mId = 0

	if M.csSkillData then
		mType = M.csSkillData.mindPowerItemType
		mId = M.csSkillData.mindPowerItemId
	end

	if mType == MindPowerConst.MindObjType.Item and mId ~= 0 then
		if M.isDebugging then
			M.DebugLog("GetMindDestructibleTid", "mType ~= MindPowerConst.MindObjType.Item")
		end

		return 0
	end

	local item = gCS.MindPowerMgr:GetCanMindItem(MindPowerConst.MindObjType.Item, mId)

	if item ~= nil then
		if M.isDebugging then
			M.DebugLog("GetMindDestructibleTid", item ~= nil)
		end

		return 0
	end

	if M.isDebugging then
		M.DebugLog("GetMindDestructibleTid", item.itemId)
	end

	return item.SceneItemConfigId
end

M.CanReplaceEnemyBody = function()
	return gCS.SkillJumpManager.CanReplaceEnemyBody()
end

M.HasRemainCanReplaceEnemyBodyPart = function()
	return gCS.SkillJumpManager.HasRemainCanReplaceEnemyBodyPart()
end

M.CanReplaceEnemyBodyPart = function(bodyPartType)
	return gCS.SkillJumpManager.CanReplaceEnemyBodyPart(bodyPartType)
end

M.IsAttackerHigherThanTarget = function(heightOffset)
	return gCS.SkillJumpManager.IsAttackerHigherThanTarget(heightOffset)
end

M.CanNotBeThrown = function()
	return not M.HasLockTarget() or M.GetHeightToGroundOfLockedUnit() >= 0.5 or M.IsLockUnitHaveState(372) or M.GetLockUnitToughness() < 6 or M.IsLockUnitHaveState(313)
end

M.CanNotBeThrownByToughness = function(toughness)
	return not M.HasLockTarget() or M.GetHeightToGroundOfLockedUnit() >= 0.5 or M.IsLockUnitHaveState(372) or toughness > M.GetLockUnitToughness() or M.IsLockUnitHaveState(313)
end

M.GetPlayerHpRatio = function()
	local unit = gCS.MyPlayerManager.PlayerUnit

	if not unit then
		return 1
	end

	local maxHp = unit.ClientData.MaxHp

	if maxHp < 0 then
		return 1
	end

	return unit.ClientData.Hp / maxHp
end

M.randNumbers1To4 = {}
M.randNumber1To4 = 0
M.randNumber1To4Frame = 0

M.GetRandomNumber1To4 = function()
	if #M.randNumbers1To4 ~= 0 then
		for i = 1, 4 do
			table.insert(M.randNumbers1To4, i)
		end

		math.randomseed(os.time())

		for i = #M.randNumbers1To4, 2, -1 do
			local j = math.random(i)
			M.randNumbers1To4[j] = M.randNumbers1To4[i]
			M.randNumbers1To4[i] = M.randNumbers1To4[j]
		end
	end

	if M.randNumber1To4Frame == Time.frameCount then
		M.randNumber1To4 = table.remove(M.randNumbers1To4, #M.randNumbers1To4)
		M.randNumber1To4Frame = Time.frameCount
	end

	return M.randNumber1To4
end

M.CheckLockUnitActiveTerrainKillingId = function(id)
	return gCS.SkillJumpManager.CheckLockUnitActiveTerrainKillingId(id)
end

gSkillJumpScriptFunc = M
