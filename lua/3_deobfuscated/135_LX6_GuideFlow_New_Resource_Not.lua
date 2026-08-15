C_GuideBT_Not = DefClass("C_GuideBT_Not", C_GuideBT_Not, C_GuideBT_ResourceBase)
local M = C_GuideBT_Not

function M:Eval()
	self.output.val = not self.input:Eval()
end
