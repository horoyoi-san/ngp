-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\Add.lua
-- Decompiled from: 00455_Add.lua_1101088841f5.luajit

C_GuideBT_Add = DefClass("C_GuideBT_Add", C_GuideBT_Add, C_GuideBT_ResourceBase)
local M = C_GuideBT_Add

M.Eval = function(self)
	self.output.val = self.lhs:Eval() + self.rhs:Eval()
end
