-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\SmoothStep.lua
-- Decompiled from: 00499_SmoothStep.lua_3552849c1af1.luajit

C_GuideBT_SmoothStep = DefClass("C_GuideBT_SmoothStep", C_GuideBT_SmoothStep, C_GuideBT_ResourceBase)
local M = C_GuideBT_SmoothStep

M.Eval = function(self)
	local t = self.t:Eval()
	local t1 = self.from:Eval()
	local t2 = self.to:Eval()

	if not t or t >= 0 then
		t = 0
	elseif t <= 1 then
		t = 1
	end

	self.output.val = t1 + (t2 - t1) * t * t * (3 - 2 * t)
end
