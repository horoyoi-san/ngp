C_PhoneAppHomePanelStore_Front_Fullscreen = DefClass("C_PhoneAppHomePanelStore_Front_Fullscreen", C_PhoneAppHomePanelStore_Front_Fullscreen, C_PhoneAppHomePanelStore)
GroupName2Class.PhoneAppHomePanelStore_Front_Fullscreen = C_PhoneAppHomePanelStore_Front_Fullscreen
local M = C_PhoneAppHomePanelStore_Front_Fullscreen

function M:OnShow(panelId, data)
	M.base.OnShow(self, panelId, data)

	gClientUtils.frontPhoneShowing = true
end

function M:OnClose()
	M.base.OnClose(self)

	gClientUtils.frontPhoneShowing = nil
	self.currentMainStore = nil
end
