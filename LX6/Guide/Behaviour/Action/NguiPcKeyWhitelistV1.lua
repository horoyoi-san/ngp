-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\NguiPcKeyWhitelistV1.lua
-- Decompiled from: 00420_NguiPcKeyWhitelistV1.lua_11d8d898bf76.luajit

C_GuideBT_NguiPcKeyWhitelistV1 = DefClass("C_GuideBT_NguiPcKeyWhitelistV1", C_GuideBT_NguiPcKeyWhitelistV1, C_GuideBT_ActionBase)
local M = C_GuideBT_NguiPcKeyWhitelistV1

M.OnTick = function(self)
	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
end

M.OnExitRunning = function(self)
end
