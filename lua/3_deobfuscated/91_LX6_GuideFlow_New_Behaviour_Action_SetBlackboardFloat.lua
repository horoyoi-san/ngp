C_GuideBT_SetBlackboardFloat = DefClass("C_GuideBT_SetBlackboardFloat", C_GuideBT_SetBlackboardFloat, C_GuideBT_ActionBase)
local M = C_GuideBT_SetBlackboardFloat

function M:OnTick()
	if self.key then
		local val = self.value:Eval()
		self:GetBlackboard()[self.key] = val
	end

	return gGuideNodeState.Success
end
