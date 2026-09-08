-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\Clamp.lua
-- Decompiled from: 00469_Clamp.lua_709b1d38e797.luajit

C_GuideBT_Clamp = DefClass("C_GuideBT_Clamp", C_GuideBT_Clamp, C_GuideBT_ResourceBase)
local M = C_GuideBT_Clamp

M.Eval = function(self)
	local val = self.input:Eval()
	local min = self.min:Eval()
	local max = self.max:Eval()
	val = Mathf.Clamp(val, min, max)
	self.output.val = val
end
