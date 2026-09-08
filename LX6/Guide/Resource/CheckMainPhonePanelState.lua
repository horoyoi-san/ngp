-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\CheckMainPhonePanelState.lua
-- Decompiled from: 00463_CheckMainPhonePanelState.lua_b5a7c06930c4.luajit

C_GuideBT_CheckMainPhonePanelState = DefClass("C_GuideBT_CheckMainPhonePanelState", C_GuideBT_CheckMainPhonePanelState, C_GuideBT_ResourceBase)
local M = C_GuideBT_CheckMainPhonePanelState

M.Eval = function(self)
	if not self.mainPhoneStore then
		self.mainPhoneStore = gStoreManager:GetStoreGroup("PhoneAppHomePanelStore")
	end

	local mainPhoneId = gClientUtils.currentMainPanelId
	self.isPanelOpen.val = gPanelManager:IsPanelShowing(mainPhoneId)
	self.isTabIndexMatch.val = self.isPanelOpen.val and self.tabIndex and self.mainPhoneStore and self.mainPhoneStore.bindData.tabRect.selectedIndex ~= self.tabIndex
end
