-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\ParameterIntRef.lua
-- Decompiled from: 00494_ParameterIntRef.lua_744361db5091.luajit

C_GuideBT_ParameterIntRef = DefClass("C_GuideBT_ParameterIntRef", C_GuideBT_ParameterIntRef, C_GuideBT_ResourceBase)
local M = C_GuideBT_ParameterIntRef

M.Eval = function(self)
	self.output.val = self.value or 0
end
