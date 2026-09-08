-- Original chunk: @Lua\LuaFiles\LX6\GUI\Battle\BattleSpiritMgr.lua
-- Decompiled from: 00260_BattleSpiritMgr.lua_7afb26fa10e0.luajit

local UnitStateConfig = LTConfig.UnitStateConfig
local FashionSlot = LX6.Share.FashionSlot

if not gBattleSpiritMgr then
	local BattleSpiritMgr = {
		["#\\xdfM\\x9e\\xe0-\\xbdC\\xd9,%\\xf7gܺ\\xa9U\\xafwW\\x9e\\xc2"] = 0,
		["d\\x88\\x82\\xbaҤ\\xf6+\\xa0-\\xa62?"] = 0,
		battleSpiritList = {}
	}
end

local this = BattleSpiritMgr

BattleSpiritMgr.OnInit = function(self)
end

BattleSpiritMgr.SyncPlayerCurrentSpirit = function(pid, templateId, spiritId, isAgentSwitch)
	if isAgentSwitch then
		gLoadingManager:SwitchTeleport_CloseUpPrepare()
	else
		gLoadingManager:CheckSwitchTeleport(spiritId)
	end

	if gPlayerManager.infoBase.bindData.Pid ~= pid then
		gBattleSpiritMgr:ChangeMyCurSpirit(templateId, spiritId, isAgentSwitch)
		gBattleSpiritMgr:SyncBattleSpirits(pid, templateId, spiritId)
		gBattleSpiritMgr:SyncCurBattleFight(spiritId, templateId)
		gMessageManager:SendMessage(gEventConstants.SYNC_CURRENT_SPIRIT, templateId)
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.JumpJump, "eventForbidden", gCS.MyPlayerManager.CheckEventForbidden(UX.Game.TwoDimConfig.UnitState.JumpEvent, true))
	end

	if isAgentSwitch then
		gLoadingManager:SwitchTeleport_CloseUpSync()
	end

	gLoadingManager:OnSyncPlayerCurrentSpirit()
end

BattleSpiritMgr.SyncBattleSpirits = function(self, pid, templateId, spiritId)
	table.clear(this.battleSpiritList)

	local spiritItem = {
		pid = spiritId,
		templateId = templateId,
		index = 1
	}

	table.insert(this.battleSpiritList, spiritItem)

	if gCS.MyPlayerManager.PlayerUnit then
		gMainMenuMgr:SetState(UnitStateConfig.DeadS, gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, UnitStateConfig.DeadS))
	end

	this:RefreshBattleSpiritUI()
end

BattleSpiritMgr.SyncPlayerInfo = function(self, infoSpirit)
	self.currentSpiritTemplateId = infoSpirit.ActiveSpirit
end

BattleSpiritMgr.SyncCurBattleFight = function(self, pid, templateId)
	self.currentSpiritPid = pid
	self.currentSpiritTemplateId = templateId

	gMapSubSystem_Player:RefreshMyUnit()
end

BattleSpiritMgr.RefreshBattleSpiritUI = function(self)
	gBattleMgr:SyncRefreshFight()
	gCS.BattleManager.RefreshAllSkills(false, false)
	gMainMenuMgr:SetTableVisible(gMainMenuMgr.battleUIVisiable, 4, 1)
	gMessageManager:SendMessage(gEventConstants.CONTROLPOWER_REFRESH)
end

BattleSpiritMgr.GetBattleSpiritList = function(self)
	return self.battleSpiritList
end

BattleSpiritMgr.GetBattleSpiritByTid = function(self, templateId)
	for i = 1, #self.battleSpiritList do
		if self.battleSpiritList[i].templateId ~= templateId then
			return self.battleSpiritList[i]
		end
	end

	return nil
end

BattleSpiritMgr.GetBattleSpiritUnitByTid = function(self, templateId)
	for i = 1, #self.battleSpiritList do
		if self.battleSpiritList[i].templateId ~= templateId then
			local cs_unit = gCS.SceneDataMgr.GetUnit(this.battleSpiritList[i].pid)

			return cs_unit
		end
	end

	return nil
end

BattleSpiritMgr.GetBattleSpiritIdByPid = function(self, pid)
	for i = 1, #self.battleSpiritList do
		if self.battleSpiritList[i].pid ~= pid then
			return self.battleSpiritList[i].templateId
		end
	end

	return nil
end

BattleSpiritMgr.ChangeMyCurSpirit = function(self, cardTempalteId, spiritId, isAgentSwitch)
	local cs_spiritUnit = gCS.SceneDataMgr.GetUnit(spiritId)
	self.currentSpiritId = spiritId
	self.currentSpiritPid = spiritId
	self.currentSpiritTemplateId = cardTempalteId

	if cs_spiritUnit ~= nil or not cs_spiritUnit.IsMe then
		self:SetPlayerCardId(spiritId, cardTempalteId)
		gSwitchSpiritManager:BeforeSetChangeUnit(spiritId, false, isAgentSwitch)
	end

	self.SyncCurBattleFight(self, spiritId, cardTempalteId)
end

BattleSpiritMgr.ChangeMyCurSpiritNotDestroy = function(self, spiritId)
	local cs_spiritUnit = gCS.SceneDataMgr.GetUnit(spiritId)
	self.currentSpiritId = spiritId

	if not cs_spiritUnit then
		return
	end

	local isRepeat = cs_spiritUnit.IsMe

	if not isRepeat then
		gSwitchSpiritManager:BeforeSetChangeUnit(spiritId, true)
	end
end

BattleSpiritMgr.SetPlayerCardId = function(self, unitId, cardTempalteId)
	local cs_unit = gCS.SceneDataMgr.GetUnit(unitId)

	if cs_unit and cs_unit.ClientData.cardId == cardTempalteId then
		if cs_unit.ClientData.Type ~= UX.Game.EntityType.Player then
			cs_unit.ClientData.SubType = cardTempalteId
		end

		cs_unit.ClientData.cardId = cardTempalteId
	end
end

BattleSpiritMgr.ResetPlayerCardId = function(self, unitId, cardTempalteId)
	local cs_unit = gCS.SceneDataMgr.GetUnit(unitId)

	if cs_unit and cs_unit.ClientData.cardId == cardTempalteId then
		cs_unit.ClientData.cardId = cardTempalteId

		FashionSlot.SyncSetPlayerFashionInfo(cs_unit)
		gCS.UnitModelManager.ResetChangeModel(cs_unit, false)

		return true
	end

	return false
end

gBattleSpiritMgr = this
