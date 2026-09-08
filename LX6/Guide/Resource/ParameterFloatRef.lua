-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\ParameterFloatRef.lua
-- Decompiled from: 00493_ParameterFloatRef.lua_8d9ac323cb53.luajit

C_GuideBT_ParameterFloatRef = DefClass("C_GuideBT_ParameterFloatRef", C_GuideBT_ParameterFloatRef, C_GuideBT_ResourceBase)
local M = C_GuideBT_ParameterFloatRef

M.Eval = function(self)
	self.output.val = self.value or 0
end
