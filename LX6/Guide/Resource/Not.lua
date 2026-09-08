-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\Not.lua
-- Decompiled from: 00490_Not.lua_45e4a966c4d7.luajit

C_GuideBT_Not = DefClass("C_GuideBT_Not", C_GuideBT_Not, C_GuideBT_ResourceBase)
local M = C_GuideBT_Not

M.Eval = function(self)
	self.output.val = not self.input:Eval()
end
