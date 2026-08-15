local BaseUnitUtils = LX6.Utils.BaseUnitUtils
local PlayerRouteManager = LX6.Manager.PlayerRouteManager
local AnimationManager = LX6.Units.AnimationManager
local DestructibleMgr = LX6.Item.DestructibleMgr.Instance
local BeCounterType = LX6.SlateData.HState.BeCounterType
local Orientation = {
	Right = 3,
	Front = 1,
	Back = 4,
	Left = 2,
	None = 0
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

function M.SetCurrentHitUnitId(unitId)
	M.currentHitUnitId = unitId
end

function M.ClearCurrentHitUnitId()
	M.currentHitUnitId = nil
end

function M.GetJumpBoardRawValue(key, global)
	return gCS.SkillJumpManager.GetJumpBoardRawValue(key, global)
end

function M.GetJumpBoardFloatValue(key, global)
	return gCS.SkillJumpManager.GetJumpBoardFloatValue(key, global)
end

function M.GetJumpBoardUlongValue(key, global)
	return gCS.SkillJumpManager.GetJumpBoardUlongValue(key, global)
end

function M.GetJumpBoardIntValue(key, global)
	return gCS.SkillJumpManager.GetJumpBoardIntValue(key, global)
end

function M.IsTargetHasShieldType(shieldType)
	return gCS.SkillJumpManager.IsTargetHasShieldType(shieldType)
end

function M.IsReplaceTargetHasShieldType(shieldType)
	return gCS.SkillJumpManager.IsReplaceTargetHasShieldType(shieldType)
end

function M.GetJumpTargetBuffTierCount(buffId)
	return gCS.SkillJumpManager.GetJumpTargetBuffTierCount(buffId)
end

function M.GetReplaceTargetBuffTierCount(buffId)
	return gCS.SkillJumpManager.GetReplaceTargetBuffTierCount(buffId)
end

function M.GetLatestWeakUnitPid()
	return gCS.SkillJumpManager.GetLatestWeakUnitPid()
end

function M.GetCurrentWeaponConfigId()
	return gCS.SkillJumpManager.GetCurrentRealWeaponId()
end

function M.CheckMeHasZone(zoneId)
	return gCS.SkillJumpManager.CheckMeHasZone_CS(zoneId)
end

function M.GetHurtImpact()
	return gCS.SkillJumpManager.GetHurtImpact()
end

function M.GetHurtFirmLevel()
	return gCS.SkillJumpManager.GetHurtFirmLevel()
end

function M.IsCameraOnUnitLeftWithoutLock()
	return gCS.SkillJumpManager.IsCameraOnUnitsLeft()
end

function M.GetLockTargetToTerrainKillAngle()
	return gCS.SkillJumpManager.GetLockTargetToTerrainKillAngle()
end

function M.GetLastSkillHitEnemyPid()
	return gCS.SkillJumpManager.GetLastSkillHitEnemyPid()
end

function M.IsLockTargetInTerrainKillFront()
	return gCS.SkillJumpManager.IsLockTargetInFrontOfTerrainKill()
end

function M.GetSkillReplaceTargetToNearestWallDistance()
	return gCS.SkillJumpManager.GetSkillReplaceTargetToNearestWallDistance()
end

function M.GetPlayerToSkillReplaceTargetForwardAngle()
	return gCS.SkillJumpManager.GetPlayerToSkillReplaceTargetForwardAngle()
end

function M.GetOrientationEnemyCount(orientation, dis)
	local orientationInt = Orientation[orientation]

	return gCS.SkillJumpManager.Instance:GetOrientationEnemyCount(orientationInt, dis)
end

function M.GetNewLockEnemyToSkillReplacePlayerOrientation()
	local orientation = gCS.SkillJumpManager.GetReplaceEnemyToPlayerOrientation()

	return OrientationName[orientation]
end

function M.GetTargetOrienTationFromPlayer()
	local orientation = gCS.SkillJumpManager.Instance:GetTargetOrientationFromPlayer()

	return OrientationName[orientation]
end

function M.IsNewLockEnemyInDistance(lowerBound, upperBound)
	return gCS.SkillJumpManager.IsReplaceEnemyInDistance(lowerBound, upperBound)
end

function M.GetReplaceMindTargetDistance()
	return gCS.SkillJumpManager.GetToMindAimDistance()
end

function M.GetCurrentLockTargetOrientation()
	local orientation = gCS.SkillJumpManager.Instance:GetCurrentActiveSkillJumpToLockTargetOrientation()

	return OrientationName[orientation]
end

function M.GetCounterTargetToPlayerOrientation()
	local orientation = gCS.SkillJumpManager.Instance:GetCounterTargetToPlayerOrientation()

	return OrientationName[orientation]
end

function M.IsSkillReplaceTargetFrontToPlayer()
	return gCS.SkillJumpManager.Instance:IsSkillReplaceTargetFrontToPlayer()
end

function M.GetSkillReplaceTargetForwardAngleFromPlayer()
	return gCS.SkillJumpManager.Instance:GetSkillReplaceTargetForwardAngleFromPlayer()
end

function M.GetSkillReplaceTargetOrientationEnemyCount(orientation, dis)
	return gCS.SkillJumpManager.Instance:GetSkillReplaceTargetOrientationEnemyCount(Orientation[orientation], dis)
end

function M.GetSkillReplaceOrientationEnemyCount(orientation, dis)
	return gCS.SkillJumpManager.Instance:GetSkillReplaceOrientationEnemyCount(Orientation[orientation], dis)
end

function M.GetSkillReplaceTargetOrientationFromPlayer()
	return OrientationName[gCS.SkillJumpManager.Instance:GetSkillReplaceTargetOrientationFromPlayer()]
end

function M.GetCurrentRealWeaponDurability()
	local durability = gCS.SkillJumpManager.GetCurrentRealWeaponDurability()

	return durability
end

function M.CheckCurrentActiveSkillJumpHasActiveSkillAndHit()
	local hitCount = gCS.SkillJumpManager.Instance:GetCurrentSkillJumpSkillHitCount()

	if gCS.BattleManager.IsUseNewComboDebug then
		print_warn("CheckCurrentActiveSkillJumpHasActiveSkillAndHit ends, hitCount: " .. hitCount)
	end

	return hitCount > 0
end

function M.CheckHitUnitBodyType(bodyType)
	if M.currentHitUnitId == nil then
		if gCS.BattleManager.IsUseNewComboDebug then
			print_warn("CheckHitUnitBodyType ends, currentHitUnitId is nil")
		end

		return false
	end

	return gCS.SkillJumpManager.CheckHitUnitBodyTyp_CS(M.currentHitUnitId, bodyType)
end

function M.GetCurrentToughness()
	if M.currentHitUnitId == nil then
		if gCS.BattleManager.IsUseNewComboDebug then
			print_warn("GetCurrentToughness ends, currentHitUnitId is nil")
		end

		return 0
	end

	local ret = gCS.SkillJumpManager.GetCurrentToughness_CS(M.currentHitUnitId)

	return ret
end

function M.CheckHitUnitEnemyClassType(enemyClassType)
	if M.currentHitUnitId == nil then
		if gCS.BattleManager.IsUseNewComboDebug then
			print_warn("CheckHitUnitEnemyClassType ends, currentHitUnitId is nil")
		end

		return false
	end

	return gCS.SkillJumpManager.CheckHitUnitEnemyClassType_CS(M.currentHitUnitId, enemyClassType)
end

function M.IsHitUnitTheLockTarget()
	if gCS.BattleManager.IsUseNewComboDebug then
		print_warn("CheckHitUnitIsLockTarget begins")
	end

	if M.currentHitUnitId == nil then
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

function M.CheckLockUnitBodyType(bodyType)
	return gCS.SkillJumpManager.CheckLockUnitBodyType_CS(bodyType)
end

function M:GetLockUnitBodyType()
	return gCS.SkillJumpManager.GetLockUnitBodyType()
end

function M.CheckLockUnitEnemyClassType(enemyClassType)
	return gCS.SkillJumpManager.CheckLockUnitEnemyClassType_CS(enemyClassType)
end

function M.GetLockUnitToughness()
	return gCS.SkillJumpManager.GetLockTargetToughness()
end

function M.GetDistanceToLockedUnitHorizontally()
	return gCS.SkillJumpManager.GetDistanceToLockedUnitHorizontally_CS()
end

function M.GetPlayerHeightToGround()
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

function M.GetDistanceToLockedUnitVertically()
	return gCS.SkillJumpManager.GetDistanceToLockedUnitVertically_CS()
end

function M.GetHeightToGroundOfLockedUnit()
	return gCS.SkillJumpManager.GetHeightToGroundOfLockedUnit_CS()
end

function M.IsCurrentActionHaveTag(tag)
	if M.currentActionTag == nil then
		return false
	end

	return M.currentActionTag == tag
end

function M.IsHaveLockUnit()
	return gCS.LockTargetMgr:IsLockAny()
end

function M.IsWeakLockAny()
	return gCS.LockTargetMgr:IsWeakLockAny()
end

function M.IsPressAngle(minAngle, maxAngle, clampMin, clampMax)
	if clampMin and clampMax then
		return gCS.SkillJumpManager.IsPressAngleClamp(minAngle, maxAngle, clampMin, clampMax)
	else
		return gCS.SkillJumpManager.IsPressAngleNoClamp(minAngle, maxAngle)
	end
end

function M.GetKeyDirectionAngleDiff(minAngle, maxAngle)
	if not gUnitOperateManager.isOnJoystickMove then
		return false
	end

	local angle = gCS.LuaUtils.GetKeyDirectionAngleDiff()

	return minAngle <= angle and angle <= maxAngle
end

function M.IsDistance(distance)
	return gCS.SkillJumpManager.IsDistance_CS(distance)
end

function M.IsOnJoystick()
	return gUnitOperateManager.isOnJoystickMove
end

function M.IsLeftJoystick(angle1, angle2)
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

	return angle1 <= angle and angle <= angle2
end

function M.IsRightJoystick(angle1, angle2)
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

	return angle1 <= angle and angle <= angle2
end

function M.IsLockEnemyAngleDiff(minAngle, maxAngle, range, effectTarget)
	if not gCS.LockTargetMgr:IsStrongLockAnyEnemy() then
		return false
	end

	local unit = gCS.SceneDataMgr.GetUnit(gCS.LockTargetMgr:GetLockEnemyId())

	if not unit then
		return false
	end

	local angle = gCS.LuaUtils.GetUnitToMeAngleDiff(unit.Pid)

	if minAngle <= angle and angle <= maxAngle then
		return true
	end

	return false
end

function M.IsNearHaveEnemy(range, effectTarget)
	return gCS.SkillJumpManager.IsNearHaveEnemy_CS(range, effectTarget)
end

function M.GetNearUnitCount(range, angle, effectTarget)
	local count = gCS.FightDataMgr:GetNearUnitCount(gCS.MyPlayerManager.PlayerUnit, range, angle, effectTarget or 0)

	return count
end

function M.IsLockEnemyHaveLockUnit(range, effectTarget)
	if not gCS.LockTargetMgr:IsStrongLockAnyEnemy() then
		return false
	end

	local unit = gCS.SceneDataMgr.GetUnit(gCS.LockTargetMgr:GetLockEnemyId())

	if not unit then
		return false
	end

	return not ulong.equals(unit.LockTargetId, 0)
end

function M.IsLockEnemyLockMe(range, effectTarget)
	if not gCS.LockTargetMgr:IsStrongLockAnyEnemy() then
		return false
	end

	local unit = gCS.SceneDataMgr.GetUnit(gCS.LockTargetMgr:GetLockEnemyId())

	if not unit then
		return false
	end

	return ulong.equals(unit.LockTargetId, gCS.SkillJumpManager.MeUnitID())
end

function M.IsMyUnitHaveBuff(buffid)
	return gBuffUtils.HasBuff(gCS.SkillJumpManager.MeUnitID(), buffid)
end

function M.IsLockUnitHaveBuff(buffid)
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

function M.IsSkillReplaceTargetHasBuff(buffId)
	return gCS.SkillJumpManager.SkillReplaceTargetHasBuff(buffId)
end

function M.IsSkillReplaceTargetHasState(stateId)
	return gCS.SkillJumpManager.SkillReplaceUnitHasState(stateId)
end

function M.IsCommonBodyType(type)
	return false
end

function M.DistanceToGround(dis)
	return gCS.SkillJumpManager.CheckDistanceToGround_CS(dis)
end

function M.CurrentAniPlayTime(time)
	return time <= AnimationManager.GetCurrentActionTime(gCS.MyPlayerManager.PlayerUnit, 0)
end

function M.IsInBattleFight()
	return gBattleMgr.isBattleUI
end

function M.IsClimbing()
	return gPlayerManager.main.bindData.isInClimbing
end

function M.IsMeHaveState(state)
	return gCS.SkillJumpManager.MeHasState_CS(state)
end

function M.IsLockUnitHaveState(state)
	return gCS.SkillJumpManager.IsLockUnitHasState_CS(state)
end

function M.IsWeakLockUnitHaveState(state)
	return gCS.SkillJumpManager.IsWeakLockUnitHaveState_CS(state)
end

function M.IsOnBaiDang()
	return gPlayerManager.main.bindData.isSwing
end

function M.IsJump()
	return false
end

function M.LastPressDownJoystickTime()
	return gCS.SkillJumpManager.Instance:GetLastPressDownJoyStickTime()
end

function M.LastPressLeftJoystickTime()
	return gCS.SkillJumpManager.Instance:GetLastPressLeftJoyStickTime()
end

function M.LastPressRightJoystickTime()
	return gCS.SkillJumpManager.Instance:GetLastPressRightJoyStickTime()
end

function M.LastPressUpJoystickTime()
	return gCS.SkillJumpManager.Instance:GetLastPressUpJoyStickTime()
end

function M.CurrentTime()
	return Time.realtimeSinceStartup
end

function M.IsInActionGroup(groupId)
	local valid = false
	local nowActionID = 0
	local nowActionGroupID = 0
	valid, nowActionID, nowActionGroupID = gCS.SkillJumpManager.GetMeAction_CS(0, 0)

	if valid == true then
		return nowActionGroupID == groupId
	end

	return false
end

function M.IsInActionId(actionId)
	local valid = false
	local nowActionID = 0
	local nowActionGroupID = 0
	valid, nowActionID, nowActionGroupID = gCS.SkillJumpManager.GetMeAction_CS(0, 0)

	if valid == true then
		return nowActionID == actionId
	end

	return false
end

function M.IsSkillBtnPress(index)
	return gCS.SkillJumpManager.Instance:GetSkillButtonPressState(index)
end

function M.GetSkillBtnPressTime(index)
	if gCS.SkillJumpManager.Instance:HasSkillButtonPressInfo(index) then
		return gCS.SkillJumpManager.Instance:GetSkillButtonPressTime(index)
	else
		return -1
	end
end

function M.IsHaveMindItem()
	return gPlayerManager.main.bindData.hasMindPowerTarget
end

function M.IsRunOrRush()
	return gCS.SkillJumpManager.IsRunOrRush()
end

function M.IsRush()
	return gCS.SkillJumpManager.IsRush()
end

function M.GetParkourState()
	return gCS.PaoKuManager.ParkourStateLua
end

function M.IsOnSkillState()
	return gCS.SkillJumpManager.IsMeOnSkillState_CS()
end

function M.IsMindSkillReplace()
	return gCS.SkillJumpManager.IsMeMindSkillReplace_CS()
end

function M.IsCastSkillId(skillId)
	return gCS.SkillJumpManager.IsMeCastSkillID_CS(skillId)
end

function M.IsCastSkillSettled()
	return gCS.SkillJumpManager.IsCastSkillSettled_CS()
end

function M.IsCastSkillOnCD(skillId)
	if skillId and skillId > 0 then
		return not gCS.BattleManager.IsCDFinished(skillId)
	end

	return false
end

function M.IsLockAnyEnemy()
	return gCS.LockTargetMgr:IsLockAnyEnemy()
end

function M.LockDestructibleId()
	return gCS.SkillJumpManager.GetMindLockItemTemplateId()
end

function M.IsInFeiSuoCrouch()
	return gPlayerManager.main.bindData.isFeiSuoCrouch
end

function M.ReplaceTargetOutDistance(distance)
	return gCS.SkillJumpManager.ReplaceTargetOutOfDistance(distance)
end

function M.OutDistance(distance)
	return gCS.SkillJumpManager.OutDistance_CS(distance)
end

M.csSkillData = nil
M.isDebugging = false
M.CallReasonType = {
	SkillJump = 1,
	SkillCondition = 2,
	None = 0
}
M.callReason = M.CallReasonType.None
M.unitPid = nil
M.isSwitchSpiritDodgeAttack = false

function M.ClearSkillConditionData()
	M.isSwitchSpiritDodgeAttack = false
end

function M.EnableDebug(enable)
	M.isDebugging = enable
end

function M.TestTrue()
	return true
end

function M.TestFalse()
	return false
end

function M.DebugLog(...)
	if M.csSkillData then
		print_error("技能条件Log信息  |  pid：" .. ulong.tostring(M.unitPid), "UUID：" .. M.csSkillData.skillUUID, "skillId：" .. M.csSkillData.skillId .. "  |  ", ...)

		return
	end
end

function M.IsSwitchSpiritDodgeAttack()
	return M.isSwitchSpiritDodgeAttack
end

function M.HasBuff(buffID)
	return gBuffUtils.HasBuff(M.unitPid, buffID)
end

function M.CheckFightSpiritID(SpiritID)
	local CurSpiritId = gBattleSpiritMgr.currentSpiritTemplateId

	return CurSpiritId == SpiritID
end

function M.CheckClipHasHit(triggerIndex)
	if M.csSkillData then
		return gCS.SkillHelper:GetClipHasHit(M.csSkillData.pid, M.csSkillData.skillUUID, triggerIndex)
	end

	return false
end

function M.HasLockTarget()
	if M.callReason == M.CallReasonType.SkillCondition and M.csSkillData then
		return not ulong.equals(M.csSkillData.targetId, 0)
	end

	return gCS.LockTargetMgr:IsLockAnyEnemy()
end

function M.CheckLockTargetDistance(distance)
	if not M.HasLockTarget() then
		return false
	end

	if M.csSkillData then
		return gUtils:GetDistance(M.csSkillData.lockData:GetPosition(), M.csSkillData.unit.LocalPosition) < distance
	end

	return false
end

function M.CheckLockTargetHasState(unitState)
	if not M.HasLockTarget() then
		return false
	end

	if M.csSkillData then
		return gCS.SkillJumpManager.HasState_CS(M.csSkillData.targetId, unitState)
	end

	return false
end

function M.CheckLockTargetHasBuff(buffId)
	if not M.HasLockTarget() then
		return false
	end

	if M.csSkillData then
		return gBuffUtils.HasBuff(M.csSkillData.targetId, buffId)
	end

	return false
end

function M.CheckLockTargetIsMe()
	if not M.HasLockTarget() then
		return false
	end

	if M.csSkillData then
		local unitLockData = M.csSkillData.lockData

		return unitLockData.unit.IsMe
	end

	return false
end

function M.GetMindDestructibleTid()
	local mType = 0
	local mId = 0

	if M.csSkillData then
		mType = M.csSkillData.mindPowerItemType
		mId = M.csSkillData.mindPowerItemId
	end

	if mType ~= MindPowerConst.MindObjType.Item and mId == 0 then
		if M.isDebugging then
			M.DebugLog("GetMindDestructibleTid", "mType ~= MindPowerConst.MindObjType.Item")
		end

		return 0
	end

	local item = gCS.MindPowerMgr:GetCanMindItem(MindPowerConst.MindObjType.Item, mId)

	if item == nil then
		if M.isDebugging then
			M.DebugLog("GetMindDestructibleTid", item == nil)
		end

		return 0
	end

	if M.isDebugging then
		M.DebugLog("GetMindDestructibleTid", item.itemId)
	end

	return item.DestructibleCfgId
end

function M.IsCameraLockBoss()
	return gCS.CameraDataMgr.cinemachineManager.isLockingBoss
end

function M.IsTargetOnForwardRange(minAngle, maxAngle)
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
	local ok = minAngle <= angle and angle <= maxAngle

	return ok
end

function M.CheckMeHasState(unitStateId)
	return gCS.SkillJumpManager.MeHasState_CS(unitStateId)
end

function M.IsUltCameraOpen()
	return gCS.CameraDataMgr.cinemachineManager.enableAnimCamera
end

function M.GetChargeWeaponValue()
	if M.csSkillData then
		return M.csSkillData.chargeHoldWeapon
	end

	return 0
end

function M.IsSkillMindFinish()
	local mType = 0
	local mId = 0

	if M.csSkillData then
		mType = M.csSkillData.mindPowerItemType
		mId = M.csSkillData.mindPowerItemId
	end

	if mType == MindPowerConst.MindObjType.None then
		return true
	end

	return gCS.MindPowerMgr:GetCanMindItem(mType, mId) == nil
end

function M.IsFromCanYingMindPower()
	return gCS.SkillJumpManager.IsFromCanYingMindPower()
end

function M.ShanBiBreakTimeSwitch()
	return not gBattleSwitch.ShanBiBreakTimeSwitch
end

function M.NormalAttackBreakSwitch()
	return not gBattleSwitch.NormalAttackBreakSwitch
end

M.beforeSwitchSpiritIsBattle = false

function M.BeforeSwitchSpiritIsBattle()
	return gSkillJumpScriptFunc.beforeSwitchSpiritIsBattle
end

function M.GetCustomSwitch(index)
	if gBattleSwitch.CustomSwitch[index] then
		return gBattleSwitch.CustomSwitch[index].active
	end

	return false
end

function M.IsHaveEnemyByDistance(enemyId, distance)
	return gCS.SkillJumpManager.IsHaveEnemyByDistance_CS(enemyId, distance)
end

function M.IsCameraOnUnitLeft()
	if not gCS.SkillJumpManager.MeExist() then
		return false
	end

	if gCS.LockTargetMgr:IsLockAnyEnemy() then
		return M.IsCameraOnUnitToLockLeft()
	else
		return M.IsCameraOnUnitFaceLeft()
	end
end

function M.IsCameraOnUnitToLockLeft()
	local unitToLockDir = Vector3.zero
	local unitToCameraDir = Vector3.zero
	local valid = false
	valid, unitToLockDir, unitToCameraDir = gCS.SkillJumpManager.Getu2lAndu2cDir_CS(Vector3.zero, Vector3.zero)

	if not valid then
		return false
	end

	local angle = -gUtils:FormatAngle180(BaseUnitUtils.GetAngle(unitToLockDir, unitToCameraDir))

	return angle > 0
end

function M.IsCameraOnUnitFaceLeft()
	local valid = false
	local unitToCameraDir = Vector3.zero
	valid, unitToCameraDir = gCS.SkillJumpManager.Getu2cDir_CS(Vector3.zero)

	if not valid then
		return false
	end

	local face = gCS.MyPlayerManager.PlayerUnit.Forward
	local angle = -gUtils:FormatAngle180(BaseUnitUtils.GetAngle(face, unitToCameraDir))

	return angle > 0
end

function M.GetIllusionBlendDistance(triggerIndex)
	return 0
end

function M.CheckEffectClipPlayed(triggerIndex)
	return gCS.SkillHelper:CheckEffectClipPlayed(M.unitPid, M.csSkillData.skillUUID, triggerIndex)
end

function M.GetSkillResourceCountById(id)
	local flag, value, isFull, isFree = nil
	flag, value, isFull, isFree = gCS.BattleManager.GetFightResource(gCS.MyPlayerManager.PlayerUnit, id, value, isFull, isFree)

	return value
end

M.randMinValue = 1
M.randMaxValue = 100
M.randValue = 0
M.randFrame = Time.frameCount

function M.RandomValue(min, max)
	if M.randFrame ~= Time.frameCount then
		M.randValue = Mathf.Random(M.randMinValue, M.randMaxValue)
		M.randFrame = Time.frameCount
	end

	return min <= M.randValue and M.randValue <= max
end

function M.GetRandomNumberFromX(x)
	local randomNumber = gCS.SkillJumpManager.GetDifferentRandomNumber(x)

	if gCS.BattleManager.IsUseNewComboDebug then
		print_warn("GetRandomNumber ends, the random number: " .. randomNumber)
	end

	return randomNumber
end

M.randNumbers = {}
M.randNumber = 0
M.randNumberFrame = 0

function M.GetRandomNumber()
	if #M.randNumbers == 0 then
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

	if M.randNumberFrame ~= Time.frameCount then
		M.randNumber = table.remove(M.randNumbers, #M.randNumbers)
		M.randNumberFrame = Time.frameCount
	end

	return M.randNumber
end

function M.CheckDodgeDirection(type)
	return type == gCS.DodgeCounterMgr.dodgeDirection
end

function M.CheckCanDodgeCounter()
	return gCS.DodgeCounterMgr.GetCounterScore(BeCounterType.DoegeCounterAttack)
end

function M.GetDodgeScore()
	return gCS.DodgeCounterMgr.GetCounterScore(BeCounterType.DoegeCounterAttack)
end

function M.GetBlockScore()
	return gCS.DodgeCounterMgr.GetCounterScore(BeCounterType.BlockCounterAttack)
end

function M.GetBeDodgeCounterSkillId()
	return gCS.DodgeCounterMgr.GetBeDodgeCounterSkillId()
end

function M.GetCounterLevel()
	return gCS.DodgeCounterMgr.curThreatLevel
end

function M.ResetStartTime()
	print_error("skilljumpscriptfunc resetstarttime无实现")
end

function M.IsGadgetTerrainKillingTemplate(cfgId)
	return gCS.BattleManager.IsGadgetTerrainKillingTemplate(cfgId)
end

function M.IsCurrentIsRoarRadio()
	if M.unitPid == nil then
		return false
	end

	return gRoarPlayerManager:IsCurrentRoarRadio(M.unitPid)
end

function M.IsCurrentWeaponIsRoarRadio()
	return gRoarPlayerManager:IsCurrentRoarRadio(gCS.WeaponMgr:GetCurrentWeaponInstanceId())
end

function M.IsStiffDownUp()
	return gCS.SkillJumpManager.IsStiffDownUp_CS()
end

function M.GetWeaponActionType()
	return gCS.BattleManager.GetWeaponActionType(gCS.SkillJumpManager.MeUnitID())
end

function M.IsInShoulderFire()
	return gCS.GunModule.IsMeInShoulderFire
end

function M:CSSkillClipRunCondition(skillData, conditionStr)
	conditionStr = "local M = gSkillJumpScriptFunc " .. conditionStr
	local func = load(conditionStr, nil, "t")

	if func then
		gSkillJumpScriptFunc.unitPid = skillData.pid
		gSkillJumpScriptFunc.csSkillData = skillData
		local status, ret = xpcall(func, tolua.traceback)
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

function M:CSSkillEnterRunCondition(pid, skillId, conditionStr)
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

function M:RunSkillJumpScriptFuncCode(code, reason)
	M:SetSkillJumpScriptFuncCallReason(reason)

	local ret = M:ExecuteCode(code)

	M:SetSkillJumpScriptFuncCallReason(M.CallReasonType.None)

	return ret
end

function M:ExecuteCode(code)
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

function M:SetSkillJumpScriptFuncCallReason(reason)
	gSkillJumpScriptFunc.callReason = reason
end

function M:ClearSkillJumpSkillConditionData()
	gSkillJumpScriptFunc.ClearSkillConditionData()
end

gSkillJumpScriptFunc = M
