C_GuideBT_CheckMainPhonePanelState = DefClass("C_GuideBT_CheckMainPhonePanelState", C_GuideBT_CheckMainPhonePanelState, C_GuideBT_ResourceBase)
local M = C_GuideBT_CheckMainPhonePanelState

function M:Eval()
	if not self.mainPhoneStore then
		self.mainPhoneStore = gStoreManager:GetStoreGroup("PhoneAppHomePanelStore")
	end

	self.isPanelOpen.val = gPanelManager:IsPanelShowing(gPanelId.S_PHONE_APP_HOME_PANEL) or gPanelManager:IsPanelShowing(gPanelId.S_HALF_PHONE_APP_HOME_PANEL)
	self.isTabIndexMatch.val = self.isPanelOpen.val and self.tabIndex and self.mainPhoneStore and self.mainPhoneStore.bindData.tabRect.selectedIndex == self.tabIndex
end
