-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\Minus.lua
-- Decompiled from: 00487_Minus.lua_2f094955cb83.luajit

C_GuideBT_Minus = DefClass("C_GuideBT_Minus", C_GuideBT_Minus, C_GuideBT_ResourceBase)
local M = C_GuideBT_Minus

M.Eval = function(self)
	self.output.val = self.lhs:Eval() - self.rhs:Eval()
end
