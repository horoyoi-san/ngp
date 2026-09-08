-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhoneAppHomePanelStore_Front_Fullscreen.lua
-- Decompiled from: 02116_PhoneAppHomePanelStore_Front_Fullscreen.lua_5cf44b7b2f97.luajit

C_PhoneAppHomePanelStore_Front_Fullscreen = DefClass("C_PhoneAppHomePanelStore_Front_Fullscreen", C_PhoneAppHomePanelStore_Front_Fullscreen, C_PhoneAppHomePanelStore)
GroupName2Class.PhoneAppHomePanelStore_Front_Fullscreen = C_PhoneAppHomePanelStore_Front_Fullscreen
local M = C_PhoneAppHomePanelStore_Front_Fullscreen

M.OnShow = function(self, panelId, data)
	M.base.OnShow(self, panelId, data)

	gClientUtils.frontPhoneShowing = true
end

M.OnClose = function(self)
	M.base.OnClose(self)

	gClientUtils.frontPhoneShowing = nil
	self.currentMainStore = nil
end
