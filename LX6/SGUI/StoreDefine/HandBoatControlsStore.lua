-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HandBoatControlsStore.lua
-- Decompiled from: 02048_HandBoatControlsStore.lua_5cffa4316bf9.luajit

C_HandBoatControlsStore = DefClass("C_HandBoatControlsStore", C_HandBoatControlsStore, C_VehicleControlsBase)
GroupName2Class.HandBoatControlsStore = C_HandBoatControlsStore
local M = C_HandBoatControlsStore

M.OnShow = function(self, panelId, data)
	M.base.OnShow(self, panelId, data)
end
