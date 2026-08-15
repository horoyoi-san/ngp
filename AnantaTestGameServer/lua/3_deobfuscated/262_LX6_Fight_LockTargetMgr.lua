local BuffConfig = LTConfig.BuffConfig
local WeaponLockPointType = LTConfig.WeaponConfig.WeaponLockPointType

if not gLockTargetMgr then
	local M = {
		currentFightStateShowNormalLockEffect = false,
		LockTargetTypeType = LTConfig.SkillConfig.LockTargetTypeType
	}
end

M.lockEffectTargetInfo = {
	isUnit = false,
	pid = 0
}

function M:ClearTargetInfo()
	self.lockEffectTargetInfo.pid = 0
	self.lockEffectTargetInfo.isUnit = false
	self.lockEffectTargetInfo.target = nil
end

M.StrongLockFuncTable = {
	[M.LockTargetTypeType.Agent] = function (data)
		local unit = data.unit

		if unit == nil then
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

		if unit == nil then
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

function M:OnStrongLockChanged(oldData, newData)
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
	end
end

M.WeakLockFuncTable = {
	[M.LockTargetTypeType.Agent] = function (data)
		local unit = data.unit

		if unit == nil then
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

		if unit == nil then
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

function M:OnWeakLockChanged(oldData, newData)
	if oldData then
		local func = self.WeakUnLockFuncTable[oldData.TargetType]

		if func then
			func(oldData)
		end
	end

	if newData then
		local func = self.WeakLockFuncTable[newData.TargetType]

		if func then
			func(newData)
		end
	end
end

M.LockEnemyHintType = {
	Normal = 0,
	Large = 2,
	Weak = 1,
	None = -1
}

function M:RefreshLockPoint(lockData, isStrong)
	if lockData.TargetType == M.LockTargetTypeType.Agent then
		local data = lockData
		local unit = data.unit

		if unit == nil then
			return
		end

		self:CheckLockEffectSgui(unit, data.IsDisplayLockPoint, isStrong, data.unitPartIndex)
	elseif lockData.TargetType == M.LockTargetTypeType.SceneItem then
		local data = lockData
		local item = data.sceneItem

		if not item then
			return
		end

		self:CheckLockDestructibleItemEffectSgui(item, data.IsDisplayLockPoint, isStrong)
	end
end

function M:CheckLockEffectSgui(unit, show, isStrong, bodyPartIndex)
	if gInteractionManager.hintInfosHudStore == nil then
		return
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample("CheckLockEffectSgui")
	end

	if show then
		local lockEnemyHintType = self.LockEnemyHintType.None
		local weaponLockType = gCS.WeaponMgr:GetCurWeaponLockPointType()

		if weaponLockType == WeaponLockPointType.Kesi then
			lockEnemyHintType = self.LockEnemyHintType.Large
		else
			local isWeak = bodyPartIndex >= 0 and gCS.ShieldManager:IsWeakPoint(unit.ClientData.SubType, bodyPartIndex)

			if isWeak then
				lockEnemyHintType = self.LockEnemyHintType.Weak
			else
				lockEnemyHintType = self.LockEnemyHintType.Normal
			end
		end

		self.lockEffectTargetInfo.isUnit = true
		self.lockEffectTargetInfo.pid = unit.Pid

		if bodyPartIndex >= 0 then
			local unitHitPart = unit:GetUnitPartHitByIndex(bodyPartIndex)

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
		gCS.LuaUtils.EndSample()
	end
end

function M:CheckShowLockEffectActiveSguiByPid(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit == nil then
		return
	end

	self:CheckShowLockEffectActiveSgui(unit)
end

function M:GetCanShowLockUI(unit)
	local pid = unit.Pid
	local unitDataSet = gDataSetManager:GetUnitData(pid)
	local mindAimEnemy = gInteractionManager.hintInfosHudStore and ulong.equals(pid, gInteractionManager.hintInfosHudStore.curMindEnemyPid)
	local canShow = not mindAimEnemy and not ulong.equals(pid, gCS.BattleManager.GetFeiSuoAttackLockEnemyId()) and (not unitDataSet or not unitDataSet.realInVisiable) and not gGadgetManager:AgentExistHackIcon(pid) and not unit.IsDead and not ulong.equals(pid, gFeisuoAssassMgr.feisuoCrouchAssTarget1) and not ulong.equals(pid, gFeisuoAssassMgr.feisuoCrouchAssTarget2)

	return canShow
end

function M:CheckShowLockEffectActiveSgui(unit)
	if gBattleMgr.lockEnemyHintType and gBattleMgr.lockEnemyHintType ~= self.LockEnemyHintType.None then
		local pid = unit.Pid
		local isLock, isStrong = gCS.LockTargetMgr:IsLockUnit(pid, false)

		if isLock then
			local canShow = self:GetCanShowLockUI(unit)

			gInteractionManager.hintInfosHudStore:ShowLockEffect(canShow, gBattleMgr.lockEnemyHintType, isStrong)
		end
	end
end

function M:CheckLockDestructibleItemEffectSgui(sceneItem, show, isStrong)
	if gLuaUIMgr.hudPanel == nil or gInteractionManager.hintInfosHudStore == nil then
		return
	end

	local id = sceneItem.InstanceId

	if show then
		local lockEnemyHintType = self.LockEnemyHintType.Normal
		self.lockEffectTargetInfo.isUnit = false
		self.lockEffectTargetInfo.target = gCS.DestructibleMgr:GetDestructibleHUDTarget(id)

		gInteractionManager.hintInfosHudStore:ShowLockEffect(true, lockEnemyHintType, false, self.lockEffectTargetInfo)
		self:ClearTargetInfo()
	else
		gInteractionManager.hintInfosHudStore:ShowLockEffect(false)
	end
end

function M.CheckNoMindBuffer(pid)
	if gCS.MindPowerMgr:HasMindEnemy(pid) then
		return true
	end

	if gBuffUtils.HasBuff(pid, BuffConfig.NoLockByNoMind) then
		return true
	end

	return false
end

gLockTargetMgr = M
