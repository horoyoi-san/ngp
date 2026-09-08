-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\GetBlackboardFloat.lua
-- Decompiled from: 00478_GetBlackboardFloat.lua_9c3a5e6508c5.luajit

C_GuideBT_GetBlackboardFloat = DefClass("C_GuideBT_GetBlackboardFloat", C_GuideBT_GetBlackboardFloat, C_GuideBT_ResourceBase)
local M = C_GuideBT_GetBlackboardFloat

M.Eval = function(self)
	self.output.val = self.GetBlackboard(self)[self.key]
end
