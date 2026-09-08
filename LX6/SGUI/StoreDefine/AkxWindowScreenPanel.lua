-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AkxWindowScreenPanel.lua
-- Decompiled from: 01607_AkxWindowScreenPanel.lua_66a1e1a84585.luajit

C_AkxWindowScreenPanel = DefClass("C_AkxWindowScreenPanel", C_AkxWindowScreenPanel, C_StoreGroup)
GroupName2Class.AkxWindowScreenPanel = C_AkxWindowScreenPanel
local M = C_AkxWindowScreenPanel

M.ctor = function(self)
end

M.OnShow = function(self, panelId, data)
	local store = gStoreManager:GetStoreGroup("AkxFloatWindowPanel")

	store:OnShow(panelId, data)
end

M.OnClose = function(self)
	local store = gStoreManager:GetStoreGroup("AkxFloatWindowPanel")

	store:OnClose()
end

M.OnActiveDeviceChange = function(self, device)
end
