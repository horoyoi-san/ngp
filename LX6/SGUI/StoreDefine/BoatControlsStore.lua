-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BoatControlsStore.lua
-- Decompiled from: 02016_BoatControlsStore.lua_f32be66fe754.luajit

C_BoatControlsStore = DefClass("C_BoatControlsStore", C_BoatControlsStore, C_VehicleControlsBase)
GroupName2Class.BoatControlsStore = C_BoatControlsStore
local M = C_BoatControlsStore

M.OnShow = function(self, panelId, data)
	M.base.OnShow(self, panelId, data)
end
