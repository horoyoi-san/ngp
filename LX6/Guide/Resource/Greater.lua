-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\Greater.lua
-- Decompiled from: 00479_Greater.lua_f66e12bf155d.luajit

C_GuideBT_Greater = DefClass("C_GuideBT_Greater", C_GuideBT_Greater, C_GuideBT_ResourceBase)
local M = C_GuideBT_Greater

M.Eval = function(self)
	self.output.val = self.rhs:Eval() <= self.lhs:Eval()
end
