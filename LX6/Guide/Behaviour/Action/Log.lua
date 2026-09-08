-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\Log.lua
-- Decompiled from: 00419_Log.lua_f303a2e51bd3.luajit

C_GuideBT_Log = DefClass("C_GuideBT_Log", C_GuideBT_Log, C_GuideBT_ActionBase)
local M = C_GuideBT_Log

M.OnTick = function(self)
	print_notice(self.message)

	return gGuideNodeState.Success
end
