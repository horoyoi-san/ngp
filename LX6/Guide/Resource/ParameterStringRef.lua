-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\ParameterStringRef.lua
-- Decompiled from: 00495_ParameterStringRef.lua_539ca7a95f81.luajit

C_GuideBT_ParameterStringRef = DefClass("C_GuideBT_ParameterStringRef", C_GuideBT_ParameterStringRef, C_GuideBT_ResourceBase)
local M = C_GuideBT_ParameterStringRef

M.Eval = function(self)
	self.output.val = self.value or ""
end
