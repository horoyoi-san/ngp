C_GuideBT_Minus = DefClass("C_GuideBT_Minus", C_GuideBT_Minus, C_GuideBT_ResourceBase)
local M = C_GuideBT_Minus

function M:Eval()
	self.output.val = self.lhs:Eval() - self.rhs:Eval()
end
