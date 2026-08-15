C_GuideBT_Multiply = DefClass("C_GuideBT_Multiply", C_GuideBT_Multiply, C_GuideBT_ResourceBase)
local M = C_GuideBT_Multiply

function M:Eval()
	self.output.val = self.lhs:Eval() * self.rhs:Eval()
end
