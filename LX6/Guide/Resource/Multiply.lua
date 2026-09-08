-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\Multiply.lua
-- Decompiled from: 00488_Multiply.lua_da449bf20b8b.luajit

C_GuideBT_Multiply = DefClass("C_GuideBT_Multiply", C_GuideBT_Multiply, C_GuideBT_ResourceBase)
local M = C_GuideBT_Multiply

M.Eval = function(self)
	self.output.val = self.lhs:Eval() * self.rhs:Eval()
end
