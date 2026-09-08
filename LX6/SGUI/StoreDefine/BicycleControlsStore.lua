-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BicycleControlsStore.lua
-- Decompiled from: 02020_BicycleControlsStore.lua_eab2448daab4.luajit

C_BicycleControlsStore = DefClass("C_BicycleControlsStore", C_BicycleControlsStore, C_VehicleControlsBase)
GroupName2Class.BicycleControlsStore = C_BicycleControlsStore
local M = C_BicycleControlsStore

M.OnShow = function(self, panelId, data)
	M.base.OnShow(self, panelId, data)
end
