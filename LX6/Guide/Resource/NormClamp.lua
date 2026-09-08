-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\NormClamp.lua
-- Decompiled from: 00489_NormClamp.lua_8c0a1bde0352.luajit

C_GuideBT_NormClamp = DefClass("C_GuideBT_NormClamp", C_GuideBT_NormClamp, C_GuideBT_ResourceBase)
local M = C_GuideBT_NormClamp

M.Eval = function(self)
	local val = self.input:Eval()
	local min = self.min:Eval()
	local max = self.max:Eval()
	val = val - min
	val = val / (max - min)
	val = Mathf.Clamp01(val)
	self.output.val = val
end
