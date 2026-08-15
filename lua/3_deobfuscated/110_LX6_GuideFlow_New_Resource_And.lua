C_GuideBT_And = DefClass("C_GuideBT_And", C_GuideBT_And, C_GuideBT_ResourceBase)
local M = C_GuideBT_And

function M:Eval()
	local result = self.lhs:Eval()
	result = result and self.rhs:Eval()
	self.output.val = result
end
