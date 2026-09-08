-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\CheckCondition.lua
-- Decompiled from: 00402_CheckCondition.lua_a5969b88902f.luajit

C_GuideBT_CheckCondition = DefClass("C_GuideBT_CheckCondition", C_GuideBT_CheckCondition, C_GuideBT_ActionBase)
local M = C_GuideBT_CheckCondition

M.OnTick = function(self)
	return self.condition:Eval() and gGuideNodeState.Success or gGuideNodeState.Failure
end
