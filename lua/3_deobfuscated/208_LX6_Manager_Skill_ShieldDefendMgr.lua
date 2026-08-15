local ShieldConfig = LTConfig.ShieldConfig
local M = {
	UseNewWeakMode = true,
	InValidIndex = -1,
	OnBeforeSwitchScene = function (self, switchType)
		self.CanShow = {}
	end,
	OnRefreshEnemyShieldValue = function (self, pid, index, shieldConfigId)
		local cs_unit = gCS.SceneDataMgr.GetUnit(pid)
		local shieldConfig = ShieldConfig.GetConfig(shieldConfigId)

		if cs_unit.ClientData.Type == UX.Game.EntityType.Enemy and shieldConfig then
			if shieldConfig.IsWholeBody or shieldConfig.ShowShieldLoc == LTConfig.ShieldConfig.ShowShieldLocType.BossLoc then
				if ulong.equals(pid, gBossViewManager.bossId) or shieldConfig.ShowShieldLoc == LTConfig.ShieldConfig.ShowShieldLocType.BossLoc then
					gBossViewManager:RefreshBossWholeShield()
				else
					gHudMgr:HpChanged(pid)
					gHudMgr:PartShieldChanged(pid, index)
				end
			elseif shieldConfig.ShowShield then
				if gCS.BattleManager.GetPartShieldValue(cs_unit, index) ~= 0 then
					if not gShieldDefendMgr.CanShow[pid] then
						gShieldDefendMgr.CanShow[pid] = {}
					end

					gShieldDefendMgr.CanShow[pid][index] = true
				end

				gHudMgr:PartShieldChanged(pid, index)
			end
		end

		self:OnPartShieldChanged(pid)
	end,
	OnRefreshEnemyShieldOn = function (self, pid, index, shieldConfigId)
		local cs_unit = gCS.SceneDataMgr.GetUnit(pid)
		local config = ShieldConfig.GetConfig(shieldConfigId)

		if not gShieldDefendMgr.CanShow[pid] then
			gShieldDefendMgr.CanShow[pid] = {}
		end

		gShieldDefendMgr.CanShow[pid][index] = true

		if cs_unit.ClientData.Type == UX.Game.EntityType.Enemy then
			if config.IsWholeBody or config.ShowShieldLoc == LTConfig.ShieldConfig.ShowShieldLocType.BossLoc then
				if ulong.equals(pid, gBossViewManager.bossId) or config.ShowShieldLoc == LTConfig.ShieldConfig.ShowShieldLocType.BossLoc then
					gBossViewManager:RefreshBossWholeShield()
					gBossViewManager:ShowStartShieldEffect()
				else
					gHudMgr:HpChanged(pid)
					gHudMgr:PartShieldChanged(pid, index)
				end
			elseif config.ShowShield then
				gHudMgr:PartShieldChanged(pid, index)
			end
		end

		self:OnPartShieldChanged(pid)
	end,
	OnRefreshEnemyShieldOff = function (self, pid, index, shieldConfigId)
		local cs_unit = gCS.SceneDataMgr.GetUnit(pid)

		if not cs_unit then
			return
		end

		local shieldConfig = ShieldConfig.GetConfig(shieldConfigId)

		self:OnPartShieldChanged(pid)

		if cs_unit.ClientData.Type == UX.Game.EntityType.Enemy and shieldConfig then
			if shieldConfig.IsWholeBody or shieldConfig.ShowShieldLoc == LTConfig.ShieldConfig.ShowShieldLocType.BossLoc then
				if ulong.equals(pid, gBossViewManager.bossId) or shieldConfig.ShowShieldLoc == LTConfig.ShieldConfig.ShowShieldLocType.BossLoc then
					gBossViewManager:RefreshBossWholeShield()
					gBossViewManager:ShowEndShieldEffect()
				else
					gHudMgr:HpChanged(pid)
					gHudMgr:PartShieldChanged(pid, index)
				end
			elseif shieldConfig.ShowShield then
				gHudMgr:PartShieldChanged(pid, index)
			end
		end
	end,
	OnRefreshEnemyShieldBreak = function (self, pid, shieldConfigId)
		local shieldConfig = ShieldConfig.GetConfig(shieldConfigId)

		self:OnPartShieldChanged(pid)

		if ulong.equals(pid, gBossViewManager.bossId) or shieldConfig and shieldConfig.ShowShieldLoc == LTConfig.ShieldConfig.ShowShieldLocType.BossLoc then
			gBossViewManager:ShowEndShieldEffect()
		end
	end,
	OnPartShieldChanged = function (self, pid)
		local dataSet = gDataSetManager:GetUnitData(pid)

		if dataSet then
			dataSet.partShieldChanged = 1 - dataSet.partShieldChanged
		end
	end
}
gShieldDefendMgr = M
