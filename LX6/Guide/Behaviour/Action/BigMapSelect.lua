-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\BigMapSelect.lua
-- Decompiled from: 00401_BigMapSelect.lua_8eb585637ee7.luajit

C_GuideBT_BigMapSelect = DefClass("C_GuideBT_BigMapSelect", C_GuideBT_BigMapSelect, C_GuideBT_ActionBase)
local M = C_GuideBT_BigMapSelect

M.DoTick = function(self)
	if gBigMapHelper:TrySelectOnBigMapByGpsId(self.gpsId) then
		return gGuideNodeState.Success
	else
		return gGuideNodeState.Running
	end
end
