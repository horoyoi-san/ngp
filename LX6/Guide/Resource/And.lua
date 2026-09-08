-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\And.lua
-- Decompiled from: 00456_And.lua_bc0d122445b0.luajit

C_GuideBT_And = DefClass("C_GuideBT_And", C_GuideBT_And, C_GuideBT_ResourceBase)
local M = C_GuideBT_And

M.Eval = function(self)
	local result = self.lhs:Eval()
	result = result and self.rhs:Eval()
	self.output.val = result
end
