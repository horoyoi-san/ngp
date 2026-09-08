-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\BoolToInt.lua
-- Decompiled from: 00457_BoolToInt.lua_2a7961e675eb.luajit

C_GuideBT_BoolToInt = DefClass("C_GuideBT_BoolToInt", C_GuideBT_BoolToInt, C_GuideBT_ResourceBase)
local M = C_GuideBT_BoolToInt

M.Eval = function(self)
	self.output.val = self.input:Eval() and 1 or 0
end
