-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\Pow.lua
-- Decompiled from: 00498_Pow.lua_2841189a9b0d.luajit

C_GuideBT_Pow = DefClass("C_GuideBT_Pow", C_GuideBT_Pow, C_GuideBT_ResourceBase)
local M = C_GuideBT_Pow

M.Eval = function(self)
	self.output.val = Mathf.Pow(self.baseValue:Eval(), self.exponent:Eval())
end
