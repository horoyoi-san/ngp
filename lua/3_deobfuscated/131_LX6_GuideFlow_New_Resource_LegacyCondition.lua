C_GuideBT_LegacyCondition = DefClass("C_GuideBT_LegacyCondition", C_GuideBT_LegacyCondition, C_GuideBT_ResourceBase)
local M = C_GuideBT_LegacyCondition

function M:Eval()
	local result = gGFCondition:CheckCondition(self.condition)
	result = result and true or false
	self.output.val = result
end
