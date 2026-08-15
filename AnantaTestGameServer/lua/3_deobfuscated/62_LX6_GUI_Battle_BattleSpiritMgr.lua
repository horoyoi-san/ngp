local UnitStateConfig = LTConfig.UnitStateConfig
local FashionSlot = LX6.Share.FashionSlot

if not gBattleSpiritMgr then
	local BattleSpiritMgr = {
		currentSpiritTemplateId = 0,
		currentSpiritPid = 0,
		battleSpiritList = {}
	}
end

local this = BattleSpiritMgr

function BattleSpiritMgr:OnInit()
	return
end

function BattleSpiritMgr.SyncPlayerCurrentSpirit(pid, templateId, spiritId, isAgentSwitch)
	if isAgentSwitch then
		gLoadingManager:SwitchTeleport_CloseUpPrepare()
	end

	if gPlayerManager.infoBase.bindData.Pid == pid then
		gBattleSpiritMgr:SyncBattleSpirits(pid, templateId, spiritId)
		gBattleSpiritMgr:SyncCurBattleFight(spiritId, templateId)
		gBattleSpiritMgr:ChangeMyCurSpirit(templateId, spiritId)
		gMessageManager:SendMessage(gEventConstants.SYNC_CURRENT_SPIRIT, templateId)
		gMainMenuMgr:SetTableVisible(gMainMenuMgr.jumpUIVisiable, 2, gCS.MyPlayerManager.CheckEventForbidden(UX.Game.TwoDimConfig.UnitState.JumpEvent, true) and 1 or 0)
	end

	if isAgentSwitch then
		gLoadingManager:SwitchTeleport_CloseUpSync()
	end
end

function BattleSpiritMgr:SyncBattleSpirits(pid, templateId, spiritId)
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

function BattleSpiritMgr:SyncPlayerInfo(infoSpirit)
	self.currentSpiritTemplateId = infoSpirit.ActiveSpirit
end

function BattleSpiritMgr:SyncCurBattleFight(pid, templateId)
	self.currentSpiritPid = pid
	self.currentSpiritTemplateId = templateId
end

function BattleSpiritMgr:RefreshBattleSpiritUI()
	gBattleMgr:SyncRefreshFight()
	gCS.BattleManager.RefreshAllSkills(false, false)
	gMainMenuMgr:SetTableVisible(gMainMenuMgr.battleUIVisiable, 4, 1)
	gMessageManager:SendMessage(gEventConstants.CONTROLPOWER_REFRESH)
end

function BattleSpiritMgr:GetBattleSpiritList()
	return self.battleSpiritList
end

function BattleSpiritMgr:GetBattleSpiritByTid(templateId)
	for i = 1, #self.battleSpiritList do
		if self.battleSpiritList[i].templateId == templateId then
			return self.battleSpiritList[i]
		end
	end

	return nil
end

function BattleSpiritMgr:GetBattleSpiritUnitByTid(templateId)
	for i = 1, #self.battleSpiritList do
		if self.battleSpiritList[i].templateId == templateId then
			local cs_unit = gCS.SceneDataMgr.GetUnit(this.battleSpiritList[i].pid)

			return cs_unit
		end
	end

	return nil
end

function BattleSpiritMgr:IsFightSpiritAllFightS()
	return gPlayerManager.main.bindData.isInFightState
end

function BattleSpiritMgr:ChangeMyCurSpirit(cardTempalteId, spiritId, isInit)
	local cs_spiritUnit = gCS.SceneDataMgr.GetUnit(spiritId)
	self.currentSpiritId = spiritId

	self:SyncCurBattleFight(spiritId, cardTempalteId)

	if not cs_spiritUnit then
		return
	end

	local isRepeat = cs_spiritUnit.IsMe

	if not isRepeat then
		self:SetPlayerCardId(spiritId, cardTempalteId)
		gSwitchSpiritManager:BeforeSetChangeUnit(spiritId, false)
	end
end

function BattleSpiritMgr:ChangeMyCurSpiritNotDestroy(spiritId)
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

function BattleSpiritMgr:SetPlayerCardId(unitId, cardTempalteId)
	local cs_unit = gCS.SceneDataMgr.GetUnit(unitId)

	if cs_unit and cs_unit.ClientData.cardId ~= cardTempalteId then
		if cs_unit.ClientData.Type == UX.Game.EntityType.Player then
			cs_unit.ClientData.SubType = cardTempalteId
		end

		cs_unit.ClientData.cardId = cardTempalteId
	end
end

function BattleSpiritMgr:ResetPlayerCardId(unitId, cardTempalteId)
	local cs_unit = gCS.SceneDataMgr.GetUnit(unitId)

	if cs_unit and cs_unit.ClientData.cardId ~= cardTempalteId then
		cs_unit.ClientData.cardId = cardTempalteId

		FashionSlot.SyncSetPlayerFashionInfo(cs_unit.ClientData)
		gCS.UnitModelManager.ResetChangeModel(cs_unit, false)

		return true
	end

	return false
end

gBattleSpiritMgr = this
