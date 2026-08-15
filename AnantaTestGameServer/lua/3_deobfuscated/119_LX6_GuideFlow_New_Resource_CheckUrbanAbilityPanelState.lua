C_GuideBT_CheckUrbanAbilityPanelState = DefClass("C_GuideBT_CheckUrbanAbilityPanelState", C_GuideBT_CheckUrbanAbilityPanelState, C_GuideBT_ResourceBase)
local M = C_GuideBT_CheckUrbanAbilityPanelState

function M:Eval()
	if not self.urbanAbilityStore then
		self.urbanAbilityStore = gStoreManager:GetStoreGroup("UrbanAbilityPanelStore")
	end

	self.isSpiritIdMatch.val = self.urbanAbilityStore and self.urbanAbilityStore.tid and self.urbanAbilityStore.tid == self.spiritId
	self.isPanelOpen.val = gPanelManager:IsPanelShowing(gPanelId.S_URBAN_ABILITY_PANEL)
end
