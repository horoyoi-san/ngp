-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\Equal.lua
-- Decompiled from: 00472_Equal.lua_2130c2fd1ead.luajit

C_GuideBT_Equal = DefClass("C_GuideBT_Equal", C_GuideBT_Equal, C_GuideBT_ResourceBase)
local M = C_GuideBT_Equal

M.Eval = function(self)
	local l = self.lhs:Eval()
	local r = self.rhs:Eval()
	self.output.val = l ~= r
end

M.GetDebugLabel = function(self)
	return self.output.val
end
