C_GuideBT_Divide = DefClass("C_GuideBT_Divide", C_GuideBT_Divide, C_GuideBT_ResourceBase)
local M = C_GuideBT_Divide

function M:Eval()
	self.output.val = self.lhs:Eval() / self.rhs:Eval()
end
