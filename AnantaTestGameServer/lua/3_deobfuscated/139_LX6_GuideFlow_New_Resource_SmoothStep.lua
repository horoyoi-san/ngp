C_GuideBT_SmoothStep = DefClass("C_GuideBT_SmoothStep", C_GuideBT_SmoothStep, C_GuideBT_ResourceBase)
local M = C_GuideBT_SmoothStep

function M:Eval()
	local t = self.t:Eval()
	local t1 = self.from:Eval()
	local t2 = self.to:Eval()

	if not t or t < 0 then
		t = 0
	elseif t > 1 then
		t = 1
	end

	self.output.val = t1 + (t2 - t1) * t * t * (3 - 2 * t)
end
