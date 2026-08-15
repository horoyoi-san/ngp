local AgentConfig = LTConfig.AgentConfig
local M = {
	bossId = 0,
	debug = true,
	isInit = false,
	inLockBossId = 0,
	bossIDs = {},
	OnInit = function (self)
		gMessageManager:AddMessageListener(gEventConstants.BOSS_HP_PANEL_DOWN, function (eventId, enable)
			self.bossHpPanelDown = enable
		end)
	end,
	SetBoss = function (self, enemyId)
		local bossUnit = gCS.SceneDataMgr.GetUnit(enemyId)

		if bossUnit == nil then
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

		if not gPanelManager:IsPanelShowing(self:GetBossPanelId()) then
			self:DebugLog("Boss出生，显示面板pid: ", pid, self.unit and self.unit.ClientData.SubType or "???")
			gPanelManager:CheckShow(self:GetBossPanelId())
		else
			self:DebugLog("Boss出生，显示面板pid: ", pid, self.unit and self.unit.ClientData.SubType or "???")
			gPanelManager:CheckShow(self:GetBossPanelId())
		end

		self.LowUpdate()
	end,
	DisplayUnitBossViewPanel = function (self, pid)
		if ulong.equals(self.bossId, pid) then
			return
		end

		self.bossId = pid
		self.unit = gCS.SceneDataMgr.GetUnit(self.bossId)

		if self.unit then
			local clientData = self.unit.ClientData
			local agentId = clientData.AgentId > 0 and clientData.AgentId or clientData.SubType
			self.bossConfig = AgentConfig.GetConfig(agentId)

			if not self.bossConfig or self.bossConfig.EnemyClassType ~= 2 then
				print_error("数据出错Debug", pid)
			end

			gMessageManager:SendMessage(gEventConstants.BOSSVIEW_REFRESH_TARGET, nil)

			if gLuaUIMgr.bossViewPanel then
				gLuaUIMgr.bossViewPanel:InitBossInfo(self.unit)
				gLuaUIMgr.bossViewPanel:SwitchDifferentBossForceSet()
			elseif gLuaUIMgr.bossViewPanel == nil then
				self:DebugLog("Boss出生，显示面板pid: ", pid, self.unit.ClientData.SubType)
				gPanelManager:CheckShow(self:GetBossPanelId())
			end
		end
	end,
	UnLockBoss = function (self)
		self.inLockBossId = 0
	end,
	LockBoss = function (self, pid)
		if ulong.equals(self.inLockBossId, pid) then
			return
		end

		local bossUnit = gCS.SceneDataMgr.GetUnit(pid)

		if bossUnit == nil then
			return
		end

		self.inLockBossId = pid

		self:DisplayUnitBossViewPanel(bossUnit.Pid)
	end
}

function M:BossDie(bossId)
	local bossIDs = M.bossIDs
	bossIDs[bossId] = nil

	self:DebugLog("Boss die ", bossId, self.bossId, table.isNilOrEmpty(bossIDs))

	if table.isNilOrEmpty(bossIDs) and ulong.equals(self.bossId, bossId) then
		self.bossId = 0

		gPanelManager:Close(self:GetBossPanelId())

		if self.FixedUpdateBeatHandle then
			FixedUpdateBeat:RemoveListener(self.FixedUpdateBeatHandle)

			self.FixedUpdateBeatHandle = nil
		end

		self.isInit = false
	end
end

function M:RefreshBossWholeShield()
	if gLuaUIMgr.bossViewPanel then
		gLuaUIMgr.bossViewPanel:RefreshBossShield()
	end
end

function M:ShowStartShieldEffect()
	if gLuaUIMgr.bossViewPanel then
		gLuaUIMgr.bossViewPanel:ShowStartShieldEffect()
	end
end

function M:ShowEndShieldEffect()
	if gLuaUIMgr.bossViewPanel then
		gLuaUIMgr.bossViewPanel:ShowEndShieldEffect()
	end
end

local lastLowUpdateTime = 0

function M.Update()
	if Time.time - lastLowUpdateTime > 1 then
		lastLowUpdateTime = Time.time

		M.LowUpdate()
	end
end

function M.LowUpdate(notDisplayBossHpPanel)
	local bossUnit = gCS.SceneDataMgr.GetUnit(M.inLockBossId)

	if bossUnit ~= nil then
		if not ulong.equals(M.bossId, bossUnit.Pid) then
			M:DisplayUnitBossViewPanel(bossUnit.Pid)
		end
	else
		local nearBossId = M:GetNearBoss()

		if nearBossId and not ulong.equals(M.bossId, nearBossId) then
			M:DisplayUnitBossViewPanel(nearBossId)
		end
	end
end

function M:GetNearBoss()
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	local myPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local temp, minDis = nil

	for i, v in pairs(M.bossIDs) do
		local bossId = i
		local unit = gCS.SceneDataMgr.GetUnit(bossId)

		if unit and not unit.IsDead then
			local clientData = unit.ClientData
			local agentId = clientData.AgentId > 0 and clientData.AgentId or clientData.SubType
			self.bossConfig = LTConfig.AgentConfig.GetConfig(agentId)

			if self.bossConfig then
				local showDist = self.bossConfig.ShowBossHpInDistance
				local bossPos = unit.UpBodyPosition
				local disX = myPos.x - bossPos.x
				local disZ = myPos.z - bossPos.z
				local dis = disX * disX + disZ * disZ

				if (dis < showDist * showDist or showDist == 0) and (minDis == nil or dis < minDis) then
					minDis = dis
					temp = bossId
				end
			end
		end
	end

	if minDis ~= nil then
		return temp
	else
		return nil
	end
end

function M:UpdateTargets(bossID, targetID)
	local boss = gCS.SceneDataMgr.GetUnit(bossID)

	if boss == nil then
		return
	end

	local pid = boss.Pid

	if ulong.equals(self.bossId, pid) then
		gMessageManager:SendMessage(gEventConstants.BOSSVIEW_REFRESH_TARGET, nil)
	end
end

function M:OnBeforeSwitchScene(switchType)
	if gSwitchSceneType.Image <= switchType then
		if self.FixedUpdateBeatHandle then
			FixedUpdateBeat:RemoveListener(self.FixedUpdateBeatHandle)

			self.FixedUpdateBeatHandle = nil
		end

		gPanelManager:Close(self:GetBossPanelId())

		self.bossIDs = {}
		self.bossId = 0
		self.unit = nil
	end
end

function M:StartBossRampage(rampageAllTime, skillId)
	if gLuaUIMgr.bossViewPanel then
		gLuaUIMgr.bossViewPanel:InitRampageInfo(rampageAllTime, skillId)
	end
end

function M:EndBossRampage(skillId)
	if gLuaUIMgr.bossViewPanel then
		gLuaUIMgr.bossViewPanel:HideRampageUI(skillId)
	end
end

function M:GetBossPanelId()
	return gPanelId.S_BOSS_HP_PANEL
end

function M:DebugLog(...)
	if self.debug then
		print_debug("[Debug Boss Panel] ", ...)
	end
end

gBossViewManager = M

return gBossViewManager
