-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\BigMapFocusV1.lua
-- Decompiled from: 00400_BigMapFocusV1.lua_65df2512e1a9.luajit

C_GuideBT_BigMapFocusV1 = DefClass("C_GuideBT_BigMapFocusV1", C_GuideBT_BigMapFocusV1, C_GuideBT_ActionBase)
local M = C_GuideBT_BigMapFocusV1

M.DoTick = function(self)
	if gBigMapHelper:TryFocusOnBigMapByGpsId(self.gpsId) then
		return gGuideNodeState.Success
	else
		return gGuideNodeState.Running
	end
end
