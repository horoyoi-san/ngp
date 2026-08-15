C_GuideBT_Float = DefClass("C_GuideBT_Float", C_GuideBT_Float, C_GuideBT_ResourceBase)
local M = C_GuideBT_Float

function M:Eval()
	self.output.val = self.value or 0
end
