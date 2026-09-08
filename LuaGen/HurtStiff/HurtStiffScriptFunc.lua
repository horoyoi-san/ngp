-- Original chunk: @Lua\LuaGen\HurtStiff\HurtStiffScriptFunc.lua
-- Decompiled from: 00683_HurtStiffScriptFunc.lua_bbe6a6358ce7.luajit

local SkillConfig = LTConfig.SkillConfig
local AgentConfig = LTConfig.AgentConfig
local EnemyType = UX.Game.EnemyType
local M = gHurtStiffScriptFunc or {}

M.IsBackStruck = function()
	return gCS.HurtStiffScriptFunc:IsBackStruck()
end

M.IsHurtMe = function()
	return gCS.HurtStiffScriptFunc:IsHurtMe()
end

M.IsHurterStiffDown = function()
	return gCS.HurtStiffScriptFunc:IsHurterStiffDown()
end

M.HurterHasState = function(state)
	return gCS.HurtStiffScriptFunc:HurterHasState(state)
end

M.LeftOrRightHit = function()
	return gCS.HurtStiffScriptFunc:LeftOrRightHit()
end

M.HurterFloorHeightOffset = function()
	return gCS.HurtStiffScriptFunc:HurterFloorHeightOffset()
end

M.IsHurterDead = function()
	return gCS.HurtStiffScriptFunc:IsHurterDead()
end

M.ForbidEnemyNormalHitFly = function()
	return gCS.HurtStiffScriptFunc:ForbidEnemyNormalHitFly()
end

M.GetHurterActionType = function()
	return gCS.HurtStiffScriptFunc:GetHurterActionType()
end

M.GetStiffFacing = function()
	return gCS.HurtStiffScriptFunc:GetStiffFacing()
end

M.IsUnbalance = function()
	return gCS.HurtStiffScriptFunc:IsUnbalance()
end

M.IsFourDirHit = function(dirType)
	return gCS.HurtStiffScriptFunc:IsFourDirHit(dirType)
end

M.CalcHitDir = function(dirType)
	return gCS.HurtStiffScriptFunc:CalcHitDir(dirType)
end

M.AttackerAngleAtHurter = function(from, to)
	return gCS.HurtStiffScriptFunc:AttackerAngleAtHurter(from, to)
end

M.GetAttackerAngleAtHurter = function()
	return gCS.HurtStiffScriptFunc:GetAttackerAngleAtHurter()
end

M.ModelIdEquals = function(...)
	local modelIds = {
		...
	}
	local modelId = gCS.HurtStiffScriptFunc:GetHurtUnitModelId()

	if modelId then
		return table.contains(modelIds, modelId)
	end

	return false
end

M.GetModelId = function()
	return gCS.HurtStiffScriptFunc:GetHurtUnitModelId()
end

M.IsHitWallInDistance = function(distance, angle)
	return gCS.HurtStiffScriptFunc:IsHitWallInDistance(distance, angle)
end

M.IsDestructibleItemHooked = function(hookId)
	return gCS.HurtStiffScriptFunc:IsDestructibleItemHooked(hookId)
end

M.IsHasNormalWeapn = function()
	return gCS.HurtStiffScriptFunc:IsHasNormalWeapn()
end

M.Random = function(value)
	return gCS.HurtStiffScriptFunc:Random(value)
end

M.IsIdle = function()
	return gCS.HurtStiffScriptFunc:IsIdle()
end

M.IsHurtBySkill = function(skillId)
	return gCS.HurtStiffScriptFunc:IsHurtBySkill(skillId)
end

M.IsHurtBySkillTag = function(skillTag)
	return gCS.HurtStiffScriptFunc:IsHurtBySkillTag(skillTag)
end

M.HasAction = function(actionId)
	return gCS.HurtStiffScriptFunc:HasAction(actionId)
end

M.UseNewHitDir = function(self)
	return gCS.HurtStiffScriptFunc:UseNewHitDir()
end

M.HasArmItemToMindInRange = function(self, rangeRadius)
	return gCS.HurtStiffScriptFunc:HasArmItemToMindInRange(rangeRadius)
end

M.IsEnemyClassType = function(typeid)
	return gCS.HurtStiffScriptFunc:HasArmItemToMindInRange(typeid)
end

M.GetUnitTypeForStiff = function()
	return gCS.HurtStiffScriptFunc:GetUnitTypeForStiff()
end

M.CheckHitUnitBodyType = function(bodyType)
	return gCS.HurtStiffScriptFunc:CheckHitUnitBodyType(bodyType)
end

M.GetHitUnitBodyType = function()
	return gCS.HurtStiffScriptFunc:GetHitUnitBodyType()
end

M.CheckHurtId = function(hurtId)
	return gCS.HurtStiffScriptFunc:CheckHurtId(hurtId)
end

M.IsHaveGamePlayTag = function(tagId)
	return gCS.HurtStiffScriptFunc:IsHaveGamePlayTag(tagId)
end

M.IsStiffDownUp = function()
	return gCS.HurtStiffScriptFunc:IsStiffDownUp()
end

M.GetWeaponActionType = function()
	return gCS.HurtStiffScriptFunc:GetWeaponActionType()
end

M.IsInShoulderFire = function()
	return gCS.HurtStiffScriptFunc:IsInShoulderFire()
end

M.HitUnitHasBuff = function(buffId)
	return gCS.HurtStiffScriptFunc:GetHitUnitHasBuff(buffId)
end

M.IsAgentTemplateId = function(templateId)
	return gCS.HurtStiffScriptFunc:IsAgentTemplateId(templateId)
end

M.IsBodyParts = function(region)
	return gCS.HurtStiffScriptFunc:IsBodyParts(region)
end

gHurtStiffScriptFunc = M

return M
