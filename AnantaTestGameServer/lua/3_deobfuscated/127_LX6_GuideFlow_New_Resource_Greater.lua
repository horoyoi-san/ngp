C_GuideBT_Greater = DefClass("C_GuideBT_Greater", C_GuideBT_Greater, C_GuideBT_ResourceBase)
local M = C_GuideBT_Greater

function M:Eval()
	self.output.val = self.rhs:Eval() < self.lhs:Eval()
end
