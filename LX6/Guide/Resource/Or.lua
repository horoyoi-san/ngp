-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\Or.lua
-- Decompiled from: 00491_Or.lua_8a72aadd5702.luajit

C_GuideBT_Or = DefClass("C_GuideBT_Or", C_GuideBT_Or, C_GuideBT_ResourceBase)
local M = C_GuideBT_Or

M.Eval = function(self)
	local result = self.lhs:Eval()
	result = result or self.rhs:Eval()
	self.output.val = result
end
