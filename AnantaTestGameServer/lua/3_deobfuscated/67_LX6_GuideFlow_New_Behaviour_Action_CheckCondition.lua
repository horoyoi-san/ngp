C_GuideBT_CheckCondition = DefClass("C_GuideBT_CheckCondition", C_GuideBT_CheckCondition, C_GuideBT_ActionBase)
local M = C_GuideBT_CheckCondition

function M:OnTick()
	return self.condition:Eval() and gGuideNodeState.Success or gGuideNodeState.Failure
end
