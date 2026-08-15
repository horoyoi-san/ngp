C_GuideBT_CheckAgentProfilePanelState = DefClass("C_GuideBT_CheckAgentProfilePanelState", C_GuideBT_CheckAgentProfilePanelState, C_GuideBT_ResourceBase)
local M = C_GuideBT_CheckAgentProfilePanelState

function M:Eval()
	if not self.agentProfileStore then
		self.agentProfileStore = gStoreManager:GetStoreGroup("NewAgentProfilePanelStore")
	end

	self.isProfileIdMatch.val = self.agentProfileStore and self.agentProfileStore.selectAgentProfileId and self.agentProfileStore.selectAgentProfileId == self.agentProfileId
	self.isPanelOpen.val = gPanelManager:IsPanelShowing(gPanelId.NEW_AGENT_PROFILE_PANEL)
end
