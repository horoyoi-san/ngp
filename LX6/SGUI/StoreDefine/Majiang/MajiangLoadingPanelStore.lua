-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangLoadingPanelStore.lua
-- Decompiled from: 01208_MajiangLoadingPanelStore.lua_a9006b834c62.luajit

C_MajiangLoadingPanelStore = DefClass("C_MajiangLoadingPanelStore", C_MajiangLoadingPanelStore, C_StoreGroup)
GroupName2Class.MajiangLoadingPanelStore = C_MajiangLoadingPanelStore
local M = C_MajiangLoadingPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
end

M.OnShow = function(self, panelId, data)
	local game = gMaJiangManager:GetGameOrEmpty()

	if not game.serverRoomInfo then
		return
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end
