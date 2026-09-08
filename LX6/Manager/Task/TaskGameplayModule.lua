-- Original chunk: @Lua\LuaFiles\LX6\Manager\Task\TaskGameplayModule.lua
-- Decompiled from: 00285_TaskGameplayModule.lua_e827ed1daa5e.luajit

C_TaskGameplayModule = DefClass("C_TaskGameplayModule", C_TaskGameplayModule)
local M = C_TaskGameplayModule

M.ctor = function(self)
	self.curTaskId = 0
	self.curTaskInfo = nil
	self.showingPanelId = {}
	self.panelState = {}
end

M.AddCurrentTaskPanel = function(self, panelId, data)
	if not gPanelManager:IsPanelShowing(panelId) then
		gPanelManager:CheckShow(panelId, data)

		self.panelState[panelId] = true

		table.insert(self.showingPanelId, panelId)
	end
end

M.ChangeCurrentPanelRule = function(self, taskId, taskInfo)
	if not taskInfo or taskId ~= 0 then
		return
	end

	self.SendChangeRuleMessage(self, taskInfo)
end

M.SendChangeRuleMessage = function(self, data)
	if data.BattleTrainingType and data.BattleTrainingType <= 0 then
		if data.BattleTrainingType ~= 3 then
			if not self.panelState[gPanelId.TRAINING_COMBO_PANEL] then
				print_debug("Training combo 打开")
				self.AddCurrentTaskPanel(self, gPanelId.TRAINING_COMBO_PANEL)
			end
		elseif not self.panelState[gPanelId.TRAINING_MAIN_PANEL] then
			print_debug("Training main 打开")
			self.AddCurrentTaskPanel(self, gPanelId.TRAINING_MAIN_PANEL)
		end
	else
		print_debug("Training main 关闭")
		gPanelManager:Close(gPanelId.TRAINING_MAIN_PANEL)
		gPanelManager:Close(gPanelId.TRAINING_COMBO_PANEL)
	end
end

M.ClearTaskPanel = function(self)
	if not self.showingPanelId or type(self.showingPanelId) == "table" or not self.panelState then
		return
	end

	for i, v in ipairs(self.showingPanelId) do
		gPanelManager:Close(v)

		self.panelState[v] = nil
	end

	self.showingPanelId = {}
end

M.OnInit = function(self)
end

M.CheckSinglePanel = function(self, panelId)
	if self.showingPanelId and not table.contains(self.showingPanelId, panelId) then
		self.panelState[panelId] = true

		table.insert(self.showingPanelId, panelId)
	end
end

M.ClearSinglePanel = function(self, panelId)
	if self.showingPanelId then
		for i = #self.showingPanelId, 1, -1 do
			if self.showingPanelId[i] ~= panelId then
				table.remove(self.showingPanelId, i)
			end
		end
	end

	if self.panelState then
		self.panelState[panelId] = nil
	end
end

return M
