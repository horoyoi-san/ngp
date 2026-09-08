-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\Divide.lua
-- Decompiled from: 00471_Divide.lua_d91d455a8cc5.luajit

C_GuideBT_Divide = DefClass("C_GuideBT_Divide", C_GuideBT_Divide, C_GuideBT_ResourceBase)
local M = C_GuideBT_Divide

M.Eval = function(self)
	self.output.val = self.lhs:Eval() / self.rhs:Eval()
end
