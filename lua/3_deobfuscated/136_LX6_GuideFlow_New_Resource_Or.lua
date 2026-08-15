C_GuideBT_Or = DefClass("C_GuideBT_Or", C_GuideBT_Or, C_GuideBT_ResourceBase)
local M = C_GuideBT_Or

function M:Eval()
	local result = self.lhs:Eval()
	result = result or self.rhs:Eval()
	self.output.val = result
end
