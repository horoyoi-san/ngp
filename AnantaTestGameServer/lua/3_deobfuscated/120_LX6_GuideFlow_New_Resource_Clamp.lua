C_GuideBT_Clamp = DefClass("C_GuideBT_Clamp", C_GuideBT_Clamp, C_GuideBT_ResourceBase)
local M = C_GuideBT_Clamp

function M:Eval()
	local val = self.input:Eval()
	local min = self.min:Eval()
	local max = self.max:Eval()
	val = Mathf.Clamp(val, min, max)
	self.output.val = val
end
