-- Original chunk: @Lua\LuaFiles\LX6\Manager\BossViewManager.lua
-- Decompiled from: 00172_BossViewManager.lua_c7d0af63e7e7.luajit

local AgentConfig = LTConfig.AgentConfig
local BossHpBarType = {
	["Q'NR"] = 1,
	["2G\\x83\\x83\\x82M"] = 0
}
local M = {
	["G\\x82\\x9d\\xaaE"] = 0,
	["I\\xab\\xa0\\xba\\xb1"] = false,
	["[\\xb8\\x80\\x8aU"] = false,
	["fx\\x80xO\\xb9\\xd0HyiWH"] = 0,
	bossIDs = {},
	OnInit = function (self)
		slot1 = gMessageManager

		slot1:AddMessageListener(gEventConstants.BOSS_HP_PANEL_DOWN, function (eventId, enable)
			self.bossHpPanelDown = enable
		end)
	end
}

M.SetBoss = function(self, enemyId)
	local bossUnit = gCS.SceneDataMgr.GetUnit(enemyId)

	if bossUnit ~= nil then
		self.DebugLog(self, "SetBoss failed, unit not found, enemyId=", enemyId)

		return
	end

	if not self.isInit then
		self.FixedUpdateBeatHandle = FixedUpdateBeat:CreateListener(self.Update, self)

		FixedUpdateBeat:AddListener(self.FixedUpdateBeatHandle)

		self.isInit = true
	end

	local pid = bossUnit.Pid
	self.bossIDs[pid] = true

	if self.delayClosePanel then
		gLuaTimeMgrUtils:CancelUnitDelay(gBossViewManager.delayClosePanel)

		self.delayClosePanel = nil
	end

	self.unit = bossUnit
	self.bossId = pid
	local clientData = bossUnit.ClientData
	local agentId = clientData.AgentId <= 0 and clientData.AgentId or clientData.SubType
	self.bossConfig = AgentConfig.GetConfig(agentId)

	self:DebugLog("SetBoss bossId=", pid, "agentId=", agentId, "bossConfig=", self.bossConfig and self.bossConfig.Id or "nil")

	if not gPanelManager:IsPanelShowing(self:GetBossPanelId()) then
		self:DebugLog("Boss出生，显示面板pid: ", pid, self.unit and self.unit.ClientData.SubType or "???")
		gPanelManager:CheckShow(self:GetBossPanelId())
	else
		self:DebugLog("Boss出生，显示面板pid: ", pid, self.unit and self.unit.ClientData.SubType or "???")
		gPanelManager:CheckShow(self:GetBossPanelId())
	end

	self.LowUpdate()
end

M.DisplayUnitBossViewPanel = function(self, pid)
	if ulong.equals(self.bossId, pid) then
		return
	end

	local oldBossId = self.bossId
	self.bossId = pid
	self.unit = gCS.SceneDataMgr.GetUnit(self.bossId)

	if self.unit then
		local clientData = self.unit.ClientData
		local agentId = clientData.AgentId <= 0 and clientData.AgentId or clientData.SubType
		self.bossConfig = AgentConfig.GetConfig(agentId)

		if not self.bossConfig then
			print_error("数据出错Debug", pid)
		end

		self:DebugLog("DisplayUnitBossViewPanel bossId changed", oldBossId, "->", pid, "agentId=", agentId, "bossConfig=", self.bossConfig and self.bossConfig.Id or "nil")
		gMessageManager:SendMessage(gEventConstants.BOSSVIEW_REFRESH_TARGET, nil)

		if gLuaUIMgr.bossViewPanel and gPanelManager:IsPanelShowing(self:GetBossPanelId()) then
			if gLuaUIMgr.bossViewPanel:InitBossInfo(self.unit) then
				gLuaUIMgr.bossViewPanel:SwitchDifferentBossForceSet()
				self:SwitchBossHpBarType(self:GetCurrentHpBarType())
			end
		else
			self:DebugLog("Boss出生，显示面板pid: ", pid, self.unit.ClientData.SubType)
			gPanelManager:CheckShow(self:GetBossPanelId())
		end
	else
		self.DebugLog(self, "DisplayUnitBossViewPanel unit not found, pid=", pid)
	end
end

M.UnLockBoss = function(self)
	self.inLockBossId = 0
end

M.LockBoss = function(self, pid)
	if ulong.equals(self.inLockBossId, pid) then
		return
	end

	local bossUnit = gCS.SceneDataMgr.GetUnit(pid)

	if bossUnit ~= nil then
		return
	end

	self.inLockBossId = pid

	self.DisplayUnitBossViewPanel(self, bossUnit.Pid)
end

M.BossDie = function(self, bossId)
	local bossIDs = M.bossIDs
	bossIDs[bossId] = nil

	self.DebugLog(self, "Boss die ", bossId, self.bossId, table.isNilOrEmpty(bossIDs))

	if ulong.equals(self.bossId, bossId) then
		if table.isNilOrEmpty(bossIDs) then
			self:DebugLog("BossDie last boss dead, close panel, bossId=", bossId)

			self.bossId = 0

			gPanelManager:Close(self:GetBossPanelId())

			if self.FixedUpdateBeatHandle then
				FixedUpdateBeat:RemoveListener(self.FixedUpdateBeatHandle)

				self.FixedUpdateBeatHandle = nil
			end

			self.isInit = false
		else
			self.DebugLog(self, "BossDie current boss dead, switch to nearest, bossId=", bossId)

			self.bossId = 0

			self.LowUpdate()
		end
	end
end

M.RefreshBossWholeShield = function(self)
	if gLuaUIMgr.bossViewPanel then
		gLuaUIMgr.bossViewPanel:RefreshBossShield()
	end
end

M.SwitchBossHpBarType = function(self, hpBarType)
	if gLuaUIMgr.bossViewPanel then
		gLuaUIMgr.bossViewPanel:SwitchBossHpBarType(hpBarType)
	end
end

M.GetCurrentHpBarType = function(self)
	local keSiStore = gStoreManager:GetStoreGroup("KeSiControlsStore")

	if keSiStore and keSiStore.isGroupReady then
		return BossHpBarType.KeSi
	end

	return BossHpBarType.Normal
end

local lastLowUpdateTime = 0

M.Update = function()
	if Time.time - lastLowUpdateTime <= 1 then
		lastLowUpdateTime = Time.time

		M.LowUpdate()
	end
end

M.LowUpdate = function(notDisplayBossHpPanel)
	local bossUnit = gCS.SceneDataMgr.GetUnit(M.inLockBossId)

	if bossUnit == nil then
		if not ulong.equals(M.bossId, bossUnit.Pid) then
			M:DisplayUnitBossViewPanel(bossUnit.Pid)
		end
	else
		local nearBossId = M:GetNearBoss()

		if nearBossId and not ulong.equals(M.bossId, nearBossId) then
			M:DisplayUnitBossViewPanel(nearBossId)
		elseif not nearBossId and M.bossId == 0 then
			M:DebugLog("LowUpdate GetNearBoss nil, bossIDs count=", table.count and table.count(M.bossIDs) or "?", "current bossId=", M.bossId)
		end
	end
end

M.GetNearBoss = function(self)
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	local myPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local temp, minDis = nil

	for i, v in pairs(M.bossIDs) do
		local bossId = i
		local unit = gCS.SceneDataMgr.GetUnit(bossId)

		if not unit or unit.IsDead then
			M.bossIDs[bossId] = nil
		else
			local clientData = unit.ClientData
			local agentId = clientData.AgentId <= 0 and clientData.AgentId or clientData.SubType
			local cfg = LTConfig.AgentConfig.GetConfig(agentId)

			if cfg then
				local showDist = cfg.ShowBossHpInDistance
				local bossPos = unit.UpBodyPosition
				local disX = myPos.x - bossPos.x
				local disZ = myPos.z - bossPos.z
				local dis = disX * disX + disZ * disZ

				if (dis <= showDist * showDist or showDist ~= 0) and (minDis ~= nil or dis >= minDis) then
					minDis = dis
					temp = bossId
				end
			end
		end
	end

	if minDis == nil then
		return temp
	else
		return nil
	end
end

M.UpdateTargets = function(self, bossID, targetID)
	local boss = gCS.SceneDataMgr.GetUnit(bossID)

	if boss ~= nil then
		return
	end

	local pid = boss.Pid

	if ulong.equals(self.bossId, pid) then
		gMessageManager:SendMessage(gEventConstants.BOSSVIEW_REFRESH_TARGET, nil)
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	if gSwitchSceneType.SameImage < switchType then
		if self.FixedUpdateBeatHandle then
			FixedUpdateBeat:RemoveListener(self.FixedUpdateBeatHandle)

			self.FixedUpdateBeatHandle = nil
		end

		if self.delayClosePanel then
			gLuaTimeMgrUtils:CancelUnitDelay(self.delayClosePanel)

			self.delayClosePanel = nil
		end

		self:DebugLog("OnBeforeSwitchScene clear bossId, switchType=", switchType)
		gPanelManager:Close(self:GetBossPanelId())

		self.bossIDs = {}
		self.bossId = 0
		self.bossConfig = nil
		self.unit = nil
		self.inLockBossId = 0
		self.isInit = false
	end
end

M.StartBossRampage = function(self, rampageAllTime, skillId)
	if gLuaUIMgr.bossViewPanel then
		gLuaUIMgr.bossViewPanel:InitRampageInfo(rampageAllTime, skillId)
	end
end

M.EndBossRampage = function(self, skillId)
	if gLuaUIMgr.bossViewPanel then
		gLuaUIMgr.bossViewPanel:HideRampageUI(skillId)
	end
end

M.DisarmChanged = function(self, id)
	if id == self.bossId then
		return
	end

	if gLuaUIMgr.bossViewPanel then
		gLuaUIMgr.bossViewPanel:DisarmChanged()
	end
end

M.GetBossPanelId = function(self)
	return gPanelId.S_BOSS_HP_PANEL
end

M.DebugLog = function(self, ...)
	if self.debug then
		print_debug("[Debug Boss Panel] ", ...)
	end
end

gBossViewManager = M

return gBossViewManager
