-- Original chunk: @Lua\LuaFiles\LX6\Fight\LockTargetMgr.lua
-- Decompiled from: 00681_LockTargetMgr.lua_64d738cf2a4b.luajit

local BuffConfig = LTConfig.BuffConfig
local WeaponLockPointType = LTConfig.SceneitemConfig.WeaponLockPointType
local GameConfig = LTConfig.GameConfig

if not gLockTargetMgr then
	local M = {
		["\\xdf4\\x8c\r\\x8e\\xdfK\\x9eܜI\\xda\\xe7\\xa6\\xb2X8\\x8a\\x82<l\\xbd\\xce,\\x9f\\xa7\\xde\\\\xb3\\xf0\\x9dG\\xcbצ"] = false,
		LockTargetTypeType = LTConfig.SkillConfig.LockTargetTypeType
	}
end

M.lockEffectTargetInfo = {
	["[\\xa4\\x80\\x8aU"] = false,
	["\\x9eab"] = 0
}
M.isStrongLock = false
M.isWeakLock = false
M.lockTargetToken = 0

M.ClearTargetInfo = function(self)
	self.lockEffectTargetInfo.pid = 0
	self.lockEffectTargetInfo.isUnit = false
	self.lockEffectTargetInfo.target = nil
end

M.StrongLockFuncTable = {
	[M.LockTargetTypeType.Agent] = function (data)
		local unit = data.unit

		if unit ~= nil then
			return
		end

		if gBossViewManager.bossIDs[unit.Pid] then
			gBossViewManager:LockBoss(unit.Pid)
		end

		M:CheckLockEffectSgui(unit, data.IsDisplayLockPoint, true, data.unitPartIndex)
		gCS.BattleManager.CheckUnitBattleLookAtIK_CS()
	end,
	[M.LockTargetTypeType.SceneItem] = function (data)
		local item = data.sceneItem

		if not item then
			return
		end

		M:CheckLockDestructibleItemEffectSgui(item, data.IsDisplayLockPoint, true)
	end
}
M.StrongUnLockFuncTable = {
	[M.LockTargetTypeType.Agent] = function (data)
		local unit = data.unit

		if unit ~= nil then
			return
		end

		M:CheckLockEffectSgui(unit, false, true, data.unitPartIndex)
		gBossViewManager:UnLockBoss()
		gCS.BattleManager.CheckUnitBattleLookAtIK_CS()
	end,
	[M.LockTargetTypeType.SceneItem] = function (data)
		local item = data.sceneItem

		if not item then
			return
		end

		M:CheckLockDestructibleItemEffectSgui(item, false, true)
	end
}

M.OnStrongLockChanged = function(self, oldData, newData)
	if oldData then
		local func = self.StrongUnLockFuncTable[oldData.TargetType]

		if func then
			func(oldData)
		end
	end

	if newData then
		local func = self.StrongLockFuncTable[newData.TargetType]

		if func then
			func(newData)
		end

		self.isStrongLock = true

		gBattleMgr:CombatConfrontPressShiftUnlockEnter(GameConfig.PressShiftLeaveStrongLockTime)
	else
		self.isStrongLock = false

		gBattleMgr:CombatConfrontPressShiftUnlockExit()
	end

	self.lockTargetToken = self.lockTargetToken + 1
end

M.WeakLockFuncTable = {
	[M.LockTargetTypeType.Agent] = function (data)
		local unit = data.unit

		if unit ~= nil then
			return
		end

		M:CheckLockEffectSgui(unit, data.IsDisplayLockPoint, false, data.unitPartIndex)
	end,
	[M.LockTargetTypeType.SceneItem] = function (data)
		local item = data.sceneItem

		if not item then
			return
		end

		M:CheckLockDestructibleItemEffectSgui(item, data.IsDisplayLockPoint, false)
	end
}
M.WeakUnLockFuncTable = {
	[M.LockTargetTypeType.Agent] = function (data)
		local unit = data.unit

		if unit ~= nil then
			return
		end

		M:CheckLockEffectSgui(unit, false, false, data.unitPartIndex)
	end,
	[M.LockTargetTypeType.SceneItem] = function (data)
		local item = data.sceneItem

		if not item then
			return
		end

		M:CheckLockDestructibleItemEffectSgui(item, false, false)
	end
}

M.OnWeakLockChanged = function(self, oldData, newData)
	if oldData then
		local func = self.WeakUnLockFuncTable[oldData.TargetType]

		if func then
			func(oldData)
		end
	end

	if newData then
		self.isWeakLock = true
		local func = self.WeakLockFuncTable[newData.TargetType]

		if func then
			func(newData)
		end
	else
		self.isWeakLock = false
	end

	self.lockTargetToken = self.lockTargetToken + 1
end

M.LockEnemyHintType = {
	["2G\\x83\\x83\\x82M"] = 0,
	["a\\xaf\\xb0\\xa8\\xb3"] = 2,
	["M'|P"] = 1,
	["T-s^"] = -1
}

M.RefreshLockPoint = function(self, lockData, isStrong)
	if lockData.TargetType ~= M.LockTargetTypeType.Agent then
		local data = lockData
		local unit = data.unit

		if unit ~= nil then
			return
		end

		self.CheckLockEffectSgui(self, unit, data.IsDisplayLockPoint, isStrong, data.unitPartIndex)
	elseif lockData.TargetType ~= M.LockTargetTypeType.SceneItem then
		local data = lockData
		local item = data.sceneItem

		if not item then
			return
		end

		self.CheckLockDestructibleItemEffectSgui(self, item, data.IsDisplayLockPoint, isStrong)
	end
end

M.CheckLockEffectSgui = function(self, unit, show, isStrong, bodyPartIndex)
	if gInteractionManager.hintInfosHudStore ~= nil then
		return
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("CheckLockEffectSgui")
	end

	if show then
		local lockEnemyHintType = self.LockEnemyHintType.None
		local weaponLockType = gCS.WeaponMgr.GetCurWeaponLockPointType()

		if weaponLockType ~= WeaponLockPointType.Kesi then
			lockEnemyHintType = self.LockEnemyHintType.Large
		else
			local isWeak = bodyPartIndex > 0 and gCS.ShieldManager:IsWeakPoint(unit.ClientData.SubType, bodyPartIndex)

			if isWeak then
				lockEnemyHintType = self.LockEnemyHintType.Weak
			else
				lockEnemyHintType = self.LockEnemyHintType.Normal
			end
		end

		self.lockEffectTargetInfo.isUnit = true
		self.lockEffectTargetInfo.pid = unit.Pid

		if bodyPartIndex > 0 then
			local unitHitPart = unit.GetUnitPartHitByIndex(unit, bodyPartIndex)

			if unitHitPart then
				local target = unitHitPart.lockPoint or unitHitPart.transform
				self.lockEffectTargetInfo.isUnit = false
				self.lockEffectTargetInfo.target = target
			end
		end

		gBattleMgr.lockEnemyHintType = lockEnemyHintType
		local canShow = self:GetCanShowLockUI(unit)

		gInteractionManager.hintInfosHudStore:ShowLockEffect(canShow, lockEnemyHintType, isStrong, self.lockEffectTargetInfo)
		self:ClearTargetInfo()
	else
		local lockEnemyHintType = self.LockEnemyHintType.None
		gBattleMgr.lockEnemyHintType = lockEnemyHintType

		gInteractionManager.hintInfosHudStore:ShowLockEffect(false)
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.CheckShowLockEffectActiveSguiByPid = function(self, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit ~= nil then
		return
	end

	self.CheckShowLockEffectActiveSgui(self, unit)
end

M.GetCanShowLockUI = function(self, unit)
	local pid = unit.Pid
	local unitDataSet = gDataSetManager:GetUnitData(pid)
	local mindAimEnemy = gInteractionManager.hintInfosHudStore and ulong.equals(pid, gInteractionManager.hintInfosHudStore.curMindEnemyPid)
	local canShow = not mindAimEnemy and not ulong.equals(pid, gCS.BattleManager.GetFeiSuoAttackLockEnemyId()) and (not unitDataSet or not unitDataSet.realInVisiable) and not gGadgetManager:AgentExistHackIcon(pid) and not unit.IsDead and not ulong.equals(pid, gFeisuoAssassMgr.feisuoCrouchAssTarget1) and not ulong.equals(pid, gFeisuoAssassMgr.feisuoCrouchAssTarget2)

	return canShow
end

M.CheckShowLockEffectActiveSgui = function(self, unit)
	if gBattleMgr.lockEnemyHintType and gBattleMgr.lockEnemyHintType == self.LockEnemyHintType.None then
		local pid = unit.Pid
		local isLock, isStrong = gCS.LockTargetMgr:IsLockUnit(pid, false)

		if isLock then
			local canShow = self:GetCanShowLockUI(unit)

			gInteractionManager.hintInfosHudStore:ShowLockEffect(canShow, gBattleMgr.lockEnemyHintType, isStrong)
		end
	end
end

M.CheckLockDestructibleItemEffectSgui = function(self, sceneItem, show, isStrong)
	if gInteractionManager.hintInfosHudStore ~= nil then
		return
	end

	if show then
		local lockEnemyHintType = self.LockEnemyHintType.Normal
		self.lockEffectTargetInfo.isUnit = false
		self.lockEffectTargetInfo.target = sceneItem.SceneItemObj.transform

		gInteractionManager.hintInfosHudStore:ShowLockEffect(true, lockEnemyHintType, false, self.lockEffectTargetInfo)
		self:ClearTargetInfo()
	else
		gInteractionManager.hintInfosHudStore:ShowLockEffect(false)
	end
end

M.CheckNoMindBuffer = function(pid)
	if gCS.MindPowerMgr:HasMindEnemy(pid) then
		return true
	end

	if gBuffUtils.HasBuff(pid, BuffConfig.NoLockByNoMind) then
		return true
	end

	return false
end

gLockTargetMgr = M
