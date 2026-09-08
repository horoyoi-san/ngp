-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\ParameterBoolRef.lua
-- Decompiled from: 00492_ParameterBoolRef.lua_c8619410e9d0.luajit

C_GuideBT_ParameterBoolRef = DefClass("C_GuideBT_ParameterBoolRef", C_GuideBT_ParameterBoolRef, C_GuideBT_ResourceBase)
local M = C_GuideBT_ParameterBoolRef

M.Eval = function(self)
	self.output.val = self.value or false
end
