-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\Quit.lua
-- Decompiled from: 00422_Quit.lua_b71eebdae4a0.luajit

C_GuideBT_Quit = DefClass("C_GuideBT_Quit", C_GuideBT_Quit, C_GuideBT_ActionBase)
local M = C_GuideBT_Quit

M.OnTick = function(self)
	self.tree:PerformQuit()

	return gGuideNodeState.Success
end
