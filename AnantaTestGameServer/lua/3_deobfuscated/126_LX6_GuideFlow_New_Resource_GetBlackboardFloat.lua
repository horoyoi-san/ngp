C_GuideBT_GetBlackboardFloat = DefClass("C_GuideBT_GetBlackboardFloat", C_GuideBT_GetBlackboardFloat, C_GuideBT_ResourceBase)
local M = C_GuideBT_GetBlackboardFloat

function M:Eval()
	self.output.val = self:GetBlackboard()[self.key]
end
