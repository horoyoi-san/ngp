C_GuideBT_NormClamp = DefClass("C_GuideBT_NormClamp", C_GuideBT_NormClamp, C_GuideBT_ResourceBase)
local M = C_GuideBT_NormClamp

function M:Eval()
	local val = self.input:Eval()
	local min = self.min:Eval()
	local max = self.max:Eval()
	val = val - min
	val = val / (max - min)
	val = Mathf.Clamp01(val)
	self.output.val = val
end
