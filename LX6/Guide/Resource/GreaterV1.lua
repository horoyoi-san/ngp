-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\GreaterV1.lua
-- Decompiled from: 00480_GreaterV1.lua_2af4779f56ea.luajit

C_GuideBT_GreaterV1 = DefClass("C_GuideBT_GreaterV1", C_GuideBT_GreaterV1, C_GuideBT_ResourceBase)
local M = C_GuideBT_GreaterV1

M.Eval = function(self)
	local l = self.lhs:Eval()
	local r = self.rhs:Eval()
	self.output.val = r <= l
end

M.GetDebugLabel = function(self)
	return self.output.val
end
