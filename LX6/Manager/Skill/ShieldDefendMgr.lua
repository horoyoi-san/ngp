-- Original chunk: @Lua\LuaFiles\LX6\Manager\Skill\ShieldDefendMgr.lua
-- Decompiled from: 00574_ShieldDefendMgr.lua_99265e2a4ff3.luajit

local ShieldConfig = LTConfig.ShieldConfig
C_ShieldDefendMgr = DefClass("C_ShieldDefendMgr", C_ShieldDefendMgr)
local M = C_ShieldDefendMgr
M.UseNewWeakMode = true
M.InValidIndex = -1

M.ctor = function(self)
	self.CanShow = {}
end

M.OnBeforeSwitchScene = function(self, switchType)
	self.CanShow = {}
end

M.OnRefreshEnemyShieldValue = function(self, pid, index, shieldConfigId)
	local cs_unit = gCS.SceneDataMgr.GetUnit(pid)
	local shieldConfig = ShieldConfig.GetConfig(shieldConfigId)

	if cs_unit.ClientData.Type ~= UX.Game.EntityType.Enemy and shieldConfig then
		if shieldConfig.IsWholeBody or shieldConfig.ShowShieldLoc ~= LTConfig.ShieldConfig.ShowShieldLocType.BossLoc then
			if ulong.equals(pid, gBossViewManager.bossId) or shieldConfig.ShowShieldLoc ~= LTConfig.ShieldConfig.ShowShieldLocType.BossLoc then
				gBossViewManager:RefreshBossWholeShield()
			else
				gHudMgr:HpChanged(pid)
				gHudMgr:PartShieldChanged(pid, index)
			end
		elseif shieldConfig.ShowShield then
			if gCS.BattleManager.GetPartShieldValue(cs_unit, index) == 0 then
				if not gShieldDefendMgr.CanShow[pid] then
					gShieldDefendMgr.CanShow[pid] = {}
				end

				gShieldDefendMgr.CanShow[pid][index] = true
			end

			gHudMgr:PartShieldChanged(pid, index)
		end
	end

	self:OnPartShieldChanged(pid)
end

M.OnRefreshEnemyShieldOn = function(self, pid, index, shieldConfigId)
	local cs_unit = gCS.SceneDataMgr.GetUnit(pid)
	local config = ShieldConfig.GetConfig(shieldConfigId)

	if not gShieldDefendMgr.CanShow[pid] then
		gShieldDefendMgr.CanShow[pid] = {}
	end

	gShieldDefendMgr.CanShow[pid][index] = true

	if cs_unit.ClientData.Type ~= UX.Game.EntityType.Enemy then
		if config.IsWholeBody or config.ShowShieldLoc ~= LTConfig.ShieldConfig.ShowShieldLocType.BossLoc then
			if ulong.equals(pid, gBossViewManager.bossId) or config.ShowShieldLoc ~= LTConfig.ShieldConfig.ShowShieldLocType.BossLoc then
				gBossViewManager:RefreshBossWholeShield()
			else
				gHudMgr:HpChanged(pid)
				gHudMgr:PartShieldChanged(pid, index)
			end
		elseif config.ShowShield then
			gHudMgr:PartShieldChanged(pid, index)
		end
	end

	self:OnPartShieldChanged(pid)
end

M.OnRefreshEnemyShieldOff = function(self, pid, index, shieldConfigId)
	local cs_unit = gCS.SceneDataMgr.GetUnit(pid)

	if not cs_unit then
		return
	end

	local shieldConfig = ShieldConfig.GetConfig(shieldConfigId)

	self:OnPartShieldChanged(pid)

	if cs_unit.ClientData.Type ~= UX.Game.EntityType.Enemy and shieldConfig then
		if shieldConfig.IsWholeBody or shieldConfig.ShowShieldLoc ~= LTConfig.ShieldConfig.ShowShieldLocType.BossLoc then
			if ulong.equals(pid, gBossViewManager.bossId) or shieldConfig.ShowShieldLoc ~= LTConfig.ShieldConfig.ShowShieldLocType.BossLoc then
				gBossViewManager:RefreshBossWholeShield()
			else
				gHudMgr:HpChanged(pid)
				gHudMgr:PartShieldChanged(pid, index)
			end
		elseif shieldConfig.ShowShield then
			gHudMgr:PartShieldChanged(pid, index)
		end
	end
end

M.OnRefreshEnemyShieldBreak = function(self, pid, shieldConfigId)
	self:OnPartShieldChanged(pid)
end

M.OnPartShieldChanged = function(self, pid)
	local dataSet = gDataSetManager:GetUnitData(pid)

	if dataSet then
		dataSet.partShieldChanged = 1 - dataSet.partShieldChanged
	end
end

gShieldDefendMgr = gShieldDefendMgr or C_ShieldDefendMgr.new()
