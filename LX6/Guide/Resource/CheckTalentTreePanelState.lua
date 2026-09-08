-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\CheckTalentTreePanelState.lua
-- Decompiled from: 00467_CheckTalentTreePanelState.lua_edae1dcd00b8.luajit

C_GuideBT_CheckTalentTreePanelState = DefClass("C_GuideBT_CheckTalentTreePanelState", C_GuideBT_CheckTalentTreePanelState, C_GuideBT_ResourceBase)
local M = C_GuideBT_CheckTalentTreePanelState

M.Eval = function(self)
	if not self.talentTreeStore then
		self.talentTreeStore = gStoreManager:GetStoreGroup("TalentTreePanelStore")
	end

	self.isJobMatch.val = self.talentTreeStore.showData and self.talentTreeStore.showData.jobClass and self.talentTreeStore.showData.jobClass ~= self.jobClassId
	self.isPanelOpen.val = gPanelManager:IsPanelShowing(gPanelId.TALENT_TREE_PANEL)
end
