C_GuideBT_Add = DefClass("C_GuideBT_Add", C_GuideBT_Add, C_GuideBT_ResourceBase)
local M = C_GuideBT_Add

function M:Eval()
	self.output.val = self.lhs:Eval() + self.rhs:Eval()
end
