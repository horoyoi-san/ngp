-- Original chunk: @Lua\LuaGen\Fight\HitSettlementFunc.lua
-- Decompiled from: 00505_HitSettlementFunc.lua_beb501637ec7.luajit

local HitLayer = LX6.SlateData.HitSettlementInfo_HitLayer
local M = gHitSettlementFunc or {}
M.hitLayer = HitLayer.None
M.srcUnitPid = 0
M.tarEnemyUnitPid = 0
M.tarDestructibleId = 0
M.tarNpcPid = 0
M.isMassNpc = false
M.isDebugging = false
M.skillId = 0
M.skillUUID = 0

M.OnInit = function(self)
	self:ClearTmpData()
end

M.OnBeforeSwitchScene = function(self, switchType)
	self:ClearTmpData()
end

M.ClearTmpData = function(self)
	self.hitLayer = HitLayer.None
	self.srcUnitPid = 0
	self.tarEnemyUnitPid = 0
	self.tarDestructibleId = 0
	self.tarNpcPid = 0
	self.isMassNpc = false
	self.skillId = 0
	self.skillUUID = 0
end

M.DebugLog = function(...)
	print_error("结算条件Log信息  |  casterUnit pid：" .. ulong.tostring(M.srcUnitPid), "hitUnit Pid：" .. ulong.tostring(M.tarEnemyUnitPid), ...)
end

M.IsHitEnemy = function()
	return M.hitLayer ~= HitLayer.Enemy
end

M.IsHitNPC = function()
	return M.hitLayer ~= HitLayer.NPC
end

M.IsHitEnvironment = function()
	return M.hitLayer ~= HitLayer.Environment
end

M.IsHitDestructible = function()
	return M.hitLayer ~= HitLayer.Destructible
end

M.SrcHasBuff = function(buffID)
	if ulong.equals(M.srcUnitPid, 0) then
		if M.isDebugging then
			M.DebugLog("SrcHasBuff", "M.srcUnit == nil")
		end

		return false
	end

	local result = gBuffUtils.HasBuff(M.srcUnitPid, buffID)

	if M.isDebugging then
		M.DebugLog("SrcHasBuff", "buffID", buffID, "result", result)
	end

	return result
end

M.TarEnemyHasBuff = function(buffID)
	if M.hitLayer == HitLayer.Enemy then
		return true
	end

	if ulong.equals(M.tarEnemyUnitPid, 0) then
		if M.isDebugging then
			M.DebugLog("TarEnemyHasBuff", "ulong.equals(M.tarEnemyUnitPid, 0)")
		end

		return false
	end

	local result = gBuffUtils.HasBuff(M.tarEnemyUnitPid, buffID)

	if M.isDebugging then
		M.DebugLog("TarEnemyHasBuff", "buffID", buffID, "result", result)
	end

	return result
end

M.GetTarEnemyToughness = function()
	local tarUnit = gCS.SceneDataMgr.GetUnit(M.tarEnemyUnitPid)

	if not tarUnit then
		if M.isDebugging then
			M.DebugLog("GetTarEnemyToughness", "tarUnit == nil")
		end

		return 0
	end

	return gCS.ToughnessMgr:GetCurrentToughness(tarUnit)
end

M.CheckClipHasHitEnemy = function(triggerIndex)
	if M.hitLayer == HitLayer.Enemy then
		return true
	end

	local result = gCS.SkillHelper:GetClipHasHit(M.srcUnitPid, M.skillUUID, triggerIndex)

	if M.isDebugging then
		M.DebugLog("CheckClipHasHitEnemy", "triggerIndex", triggerIndex, "result", result)
	end

	return result
end

M.CheckEnemyInDistance = function(distance)
	if M.hitLayer == HitLayer.Enemy then
		return true
	end

	if ulong.equals(M.srcUnitPid, 0) or ulong.equals(M.tarEnemyUnitPid, 0) then
		if M.isDebugging then
			M.DebugLog("CheckEnemyInDistance", "ulong.equals(M.srcUnitPid, 0) or ulong.equals(M.tarEnemyUnitPid, 0)")
		end

		return false
	end

	local srcUnit = gCS.SceneDataMgr.GetUnit(M.srcUnitPid)
	local tarUnit = gCS.SceneDataMgr.GetUnit(M.tarEnemyUnitPid)

	if not srcUnit or not tarUnit then
		if M.isDebugging then
			M.DebugLog("CheckEnemyInDistance", "srcUnit == nil or tarUnit == nil")
		end

		return false
	end

	local dis = gUtils:GetDistance(srcUnit.LocalPosition, tarUnit.LocalPosition)

	if M.isDebugging then
		M.DebugLog("CheckEnemyInDistance", "距离参数", distance, "两Unit之间距离", dis, "结果", dis <= distance)
	end

	return dis <= distance
end

M.GetTarEnemyWeight = function()
	if M.hitLayer == HitLayer.Enemy then
		return -1
	end

	if ulong.equals(M.tarEnemyUnitPid, 0) then
		if M.isDebugging then
			M.DebugLog("GetTarEnemyWeight", "ulong.equals(M.tarEnemyUnitPid, 0)")
		end

		return -1
	end

	local tarUnit = gCS.SceneDataMgr.GetUnit(M.tarEnemyUnitPid)

	if not tarUnit then
		if M.isDebugging then
			M.DebugLog("GetTarEnemyWeight", "srcUnit == nil or tarUnit == nil")
		end

		return -1
	end

	if M.isDebugging then
		M.DebugLog("GetTarEnemyWeight", "tarUnit.cs_unit.ClientData.Weight", tarUnit.ClientData.Weight)
	end

	return tarUnit.ClientData.Weight
end

M.GetTarDestructibleMass = function()
	if M.hitLayer == HitLayer.Destructible then
		return -1
	end

	if ulong.equals(M.tarDestructibleId, 0) then
		if M.isDebugging then
			M.DebugLog("GetTarDestructibleMass ulong.equals(M.tarDestructibleId, 0)")
		end

		return -1
	end

	if M.isDebugging then
		M.DebugLog("GetTarDestructibleMass gCS.LuaUtils.IsNull(item)")
	end

	return -1
end

M.IsTarEnemyLockedBySkill = function()
	if M.hitLayer == HitLayer.Enemy then
		return true
	end

	if ulong.equals(M.srcUnitPid, 0) or ulong.equals(M.tarEnemyUnitPid, 0) then
		if M.isDebugging then
			M.DebugLog("IsTarEnemyLockedBySkill", "ulong.equals(M.srcUnitPid, 0) or ulong.equals(M.tarEnemyUnitPid, 0)")
		end

		return false
	end

	local srcUnit = gCS.SceneDataMgr.GetUnit(M.srcUnitPid)

	if not srcUnit then
		if M.isDebugging then
			M.DebugLog("IsTarEnemyLockedBySkill", "srcUnit == nil or tarUnit == nil")
		end

		return false
	end

	local skillTarget = gCS.SkillHelper:GetSkillLockTarget(M.srcUnitPid, M.skillUUID)

	if M.isDebugging then
		M.DebugLog("IsTarEnemyLockedBySkill", ulong.equals(skillTarget, M.tarEnemyUnitPid), "M.tarEnemyUnitPid", ulong.tostring(M.tarEnemyUnitPid), "clip.targetId", ulong.tostring(skillTarget))
	end

	return ulong.equals(skillTarget, M.tarEnemyUnitPid)
end

M.CSHitSettleRunCondition = function(self, conditionStr, hitLayer, srcUnitPid, tarPid, tarDid, skillId, skillUUID)
	gHitSettlementFunc.hitLayer = hitLayer
	gHitSettlementFunc.srcUnitPid = srcUnitPid
	gHitSettlementFunc.tarEnemyUnitPid = tarPid
	gHitSettlementFunc.tarDestructibleId = tarDid
	gHitSettlementFunc.skillId = skillId
	gHitSettlementFunc.skillUUID = skillUUID
	conditionStr = "local M = gHitSettlementFunc " .. conditionStr
	local func = load(conditionStr, nil, "t")

	if func then
		local status, ret = xpcall(func, tolua.traceback)

		if status then
			gHitSettlementFunc:ClearTmpData()

			return ret
		end

		print_warn("结算 RunFunc 报错，结算条件", "status", status, "ret", ret)

		return false
	end

	gHitSettlementFunc:ClearTmpData()
	print_error("结算 RunFunc 报错，结算条件")

	return false
end

gHitSettlementFunc = M
