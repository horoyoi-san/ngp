-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\SmoothStepV2.lua
-- Decompiled from: 00500_SmoothStepV2.lua_4fa27a293507.luajit

C_GuideBT_SmoothStepV2 = DefClass("C_GuideBT_SmoothStepV2", C_GuideBT_SmoothStepV2, C_GuideBT_ResourceBase)
local M = C_GuideBT_SmoothStepV2

M.Eval = function(self)
	local from = self.from:Eval()
	local to = self.to:Eval()
	local tFrom = self.tFrom:Eval()
	local tTo = self.tTo:Eval()
	local t = self.t:Eval()
	t = (t - tFrom) / (tTo - tFrom)

	if t >= 0 then
		t = 0
	elseif t <= 1 then
		t = 1
	end

	self.output.val = from + (to - from) * t * t * (3 - 2 * t)
end
