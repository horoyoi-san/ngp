-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\CheckAgentProfilePanelState.lua
-- Decompiled from: 00458_CheckAgentProfilePanelState.lua_15f39f63fb99.luajit

C_GuideBT_CheckAgentProfilePanelState = DefClass("C_GuideBT_CheckAgentProfilePanelState", C_GuideBT_CheckAgentProfilePanelState, C_GuideBT_ResourceBase)
local M = C_GuideBT_CheckAgentProfilePanelState

M.Eval = function(self)
	if not self.agentProfileStore then
		self.agentProfileStore = gStoreManager:GetStoreGroup("NewAgentProfilePanelStore")
	end

	self.isProfileIdMatch.val = self.agentProfileStore and self.agentProfileStore.selectAgentProfileId and self.agentProfileStore.selectAgentProfileId ~= self.agentProfileId
	self.isPanelOpen.val = gPanelManager:IsPanelShowing(gPanelId.NEW_AGENT_PROFILE_PANEL)
end

M.GetDebugLabel = function(self)
	return string.format("isProfileIdMatch: %s\nisPanelOpen: %s", self.isProfileIdMatch.val, self.isPanelOpen.val)
end
