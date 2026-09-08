-- Original chunk: @Lua\LuaFiles\LX6\Manager\CombatPowerManager.lua
-- Decompiled from: 00351_CombatPowerManager.lua_ba1a50b477d4.luajit

C_CombatPowerManager = DefClass("C_CombatPowerManager", C_CombatPowerManager, nil)
local M = C_CombatPowerManager

M.ctor = function(self)
	self.spiritCombatPowers = {}
	self.startRecord = false
	self.recordPower = 0
	self.mergePanelConfigDict = {}
	self.mergePanelRecord = {}
	self.mergePanelRecordCount = 0
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.DO_CHECK_SHOW, self:CreateAction("OnPanelShow"))
	gMessageManager:AddMessageListener(gEventConstants.DO_CLOSE, self:CreateAction("OnPanelClose"))

	local mergeDict = LTConfig.PopupConfig.MergeFightScorePopUpPanelList

	table.clear(self.mergePanelConfigDict)
	table.clear(self.mergePanelRecord)

	self.mergePanelRecordCount = 0

	if mergeDict then
		for i = 1, #mergeDict do
			self.mergePanelConfigDict[mergeDict[i]] = true
		end
	end
end

M.AddMergePanel = function(self, panelId)
	if not self.mergePanelRecord[panelId] then
		self.mergePanelRecord[panelId] = true
		self.mergePanelRecordCount = self.mergePanelRecordCount + 1

		if self.mergePanelRecordCount ~= 1 then
			self.startRecord = true
			self.recordPower = self:GetSpiritCombatPower(gBattleSpiritMgr.currentSpiritTemplateId)
		end
	end
end

M.RemoveMergePanel = function(self, panelId)
	if self.mergePanelRecord[panelId] then
		self.mergePanelRecord[panelId] = nil
		self.mergePanelRecordCount = self.mergePanelRecordCount - 1

		if self.mergePanelRecordCount ~= 0 then
			self.startRecord = false
			local curr = self:GetSpiritCombatPower(gBattleSpiritMgr.currentSpiritTemplateId)

			if curr == self.recordPower then
				gNewPopupManager:PushPopup(LTConfig.PopupConfig.CombatPowerChanged, {
					tId = gBattleSpiritMgr.currentSpiritTemplateId,
					pre = self.recordPower,
					curr = curr
				})
			end
		end
	end
end

M.OnPanelShow = function(self, _, panelId)
	if self.mergePanelConfigDict[panelId] then
		self:AddMergePanel(panelId)
	end
end

M.OnPanelClose = function(self, _, panelId)
	if self.mergePanelConfigDict[panelId] then
		self:RemoveMergePanel(panelId)
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self.startRecord = false
		self.recordPower = 0

		table.clear(self.spiritCombatPowers)
		table.clear(self.mergePanelRecord)

		self.mergePanelRecordCount = 0
	end
end

M.SyncAllSpiritCombatPower = function(self, spiritCombatPowers)
	table.clear(self.spiritCombatPowers)

	for k, v in pairs(spiritCombatPowers) do
		self.spiritCombatPowers[k] = v
	end
end

M.SyncSpiritCombatPowerChanged = function(self, spiritId, combatPower)
	local pre = self.spiritCombatPowers[spiritId]

	if not pre then
		self.spiritCombatPowers[spiritId] = combatPower

		return
	end

	self.spiritCombatPowers[spiritId] = combatPower

	gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.SPIRIT_COMBAT_POWER_CHANGED, pre, combatPower)

	if not self.startRecord and spiritId ~= gBattleSpiritMgr.currentSpiritTemplateId then
		gNewPopupManager:PushPopup(LTConfig.PopupConfig.CombatPowerChanged, {
			tId = spiritId,
			pre = pre,
			curr = combatPower
		})
	end
end

M.GetSpiritCombatPower = function(self, spiritId)
	if not self.spiritCombatPowers[spiritId] then
		print_error("[CombatPower] GetSpiritCombatPower error, 客户端没有战力数据, spiritId=", spiritId)
	end

	return self.spiritCombatPowers[spiritId] or 0
end

gCombatPowerManager = gCombatPowerManager or C_CombatPowerManager.new()
