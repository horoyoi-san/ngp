local SkillConfig = LTConfig.SkillConfig
local AgentConfig = LTConfig.AgentConfig
local EnemyType = UX.Game.EnemyType
local M = gHurtStiffScriptFunc or {}

function M.IsBackStruck()
	return gCS.HurtStiffScriptFunc:IsBackStruck()
end

function M.IsHurtMe()
	return gCS.HurtStiffScriptFunc:IsHurtMe()
end

function M.IsHurterStiffDown()
	return gCS.HurtStiffScriptFunc:IsHurterStiffDown()
end

function M.HurterHasState(state)
	return gCS.HurtStiffScriptFunc:HurterHasState(state)
end

function M.LeftOrRightHit()
	return gCS.HurtStiffScriptFunc:LeftOrRightHit()
end

function M.HurterFloorHeightOffset()
	return gCS.HurtStiffScriptFunc:HurterFloorHeightOffset()
end

function M.IsHurterDead()
	return gCS.HurtStiffScriptFunc:IsHurterDead()
end

function M.ForbidEnemyNormalHitFly()
	return gCS.HurtStiffScriptFunc:ForbidEnemyNormalHitFly()
end

function M.GetHurterActionType()
	return gCS.HurtStiffScriptFunc:GetHurterActionType()
end

function M.GetStiffFacing()
	return gCS.HurtStiffScriptFunc:GetStiffFacing()
end

function M.IsUnbalance()
	return gCS.HurtStiffScriptFunc:IsUnbalance()
end

function M.IsFourDirHit(dirType)
	return gCS.HurtStiffScriptFunc:IsFourDirHit(dirType)
end

function M.CalcHitDir(dirType)
	return gCS.HurtStiffScriptFunc:CalcHitDir(dirType)
end

function M.AttackerAngleAtHurter(from, to)
	return gCS.HurtStiffScriptFunc:AttackerAngleAtHurter(from, to)
end

function M.GetAttackerAngleAtHurter()
	return gCS.HurtStiffScriptFunc:GetAttackerAngleAtHurter()
end

function M.ModelIdEquals(...)
	local modelIds = {
		...
	}
	local modelId = gCS.HurtStiffScriptFunc:GetHurtUnitModelId()

	if modelId then
		return table.contains(modelIds, modelId)
	end

	return false
end

function M.GetModelId()
	return gCS.HurtStiffScriptFunc:GetHurtUnitModelId()
end

function M.IsHitWallInDistance(distance, angle)
	return gCS.HurtStiffScriptFunc:IsHitWallInDistance(distance, angle)
end

function M.IsDestructibleItemHooked(hookId)
	return gCS.HurtStiffScriptFunc:IsDestructibleItemHooked(hookId)
end

function M.IsHasNormalWeapn()
	return gCS.HurtStiffScriptFunc:IsHasNormalWeapn()
end

function M.Random(value)
	return gCS.HurtStiffScriptFunc:Random(value)
end

function M.IsIdle()
	return gCS.HurtStiffScriptFunc:IsIdle()
end

function M.IsHurtBySkill(skillId)
	return gCS.HurtStiffScriptFunc:IsHurtBySkill(skillId)
end

function M.IsHurtBySkillTag(skillTag)
	return gCS.HurtStiffScriptFunc:IsHurtBySkillTag(skillTag)
end

function M.HasAction(actionId)
	return gCS.HurtStiffScriptFunc:HasAction(actionId)
end

function M:UseNewHitDir()
	return gCS.HurtStiffScriptFunc:UseNewHitDir()
end

function M:HasArmItemToMindInRange(rangeRadius)
	return gCS.HurtStiffScriptFunc:HasArmItemToMindInRange(rangeRadius)
end

function M.IsEnemyClassType(typeid)
	return gCS.HurtStiffScriptFunc:HasArmItemToMindInRange(typeid)
end

function M.GetUnitTypeForStiff()
	return gCS.HurtStiffScriptFunc:GetUnitTypeForStiff()
end

function M.CheckHitUnitBodyType(bodyType)
	return gCS.HurtStiffScriptFunc:CheckHitUnitBodyType(bodyType)
end

function M.GetHitUnitBodyType()
	return gCS.HurtStiffScriptFunc:GetHitUnitBodyType()
end

function M.CheckHurtId(hurtId)
	return gCS.HurtStiffScriptFunc:CheckHurtId(hurtId)
end

function M.IsHaveGamePlayTag(tag)
	local tagId = LTConfig.GameplayTagConfig[tag]

	if not tagId then
		print_error("GameplayTagConfig not have tag = ", tag)

		return false
	end

	return gCS.HurtStiffScriptFunc:IsHaveGamePlayTag(tagId)
end

function M.IsStiffDownUp()
	return gCS.HurtStiffScriptFunc:IsStiffDownUp()
end

function M.GetWeaponActionType()
	return gCS.HurtStiffScriptFunc:GetWeaponActionType()
end

function M.IsInShoulderFire()
	return gCS.HurtStiffScriptFunc:IsInShoulderFire()
end

function M.HitUnitHasBuff(buffId)
	return gCS.HurtStiffScriptFunc:GetHitUnitHasBuff(buffId)
end

gHurtStiffScriptFunc = M

return M
