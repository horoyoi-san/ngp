-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\Float.lua
-- Decompiled from: 00474_Float.lua_09f15b9dc152.luajit

C_GuideBT_Float = DefClass("C_GuideBT_Float", C_GuideBT_Float, C_GuideBT_ResourceBase)
local M = C_GuideBT_Float

M.Eval = function(self)
	self.output.val = self.value or 0
end
