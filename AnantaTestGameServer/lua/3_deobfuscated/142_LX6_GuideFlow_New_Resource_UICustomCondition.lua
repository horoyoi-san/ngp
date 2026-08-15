C_GuideBT_UICustomCondition = DefClass("C_GuideBT_UICustomCondition", C_GuideBT_UICustomCondition, C_GuideBT_ResourceBase)
local M = C_GuideBT_UICustomCondition

function M:Eval()
	local predication = gGuideUICustomCondition[self.condition]
	self.output.val = predication and predication() or false
end
