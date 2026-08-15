C_GuideBT_UntilSuccess = DefClass("C_GuideBT_UntilSuccess", C_GuideBT_UntilSuccess, C_GuideBT_DecoratorBase)
local M = C_GuideBT_UntilSuccess

function M:OnTick()
	local child = self:GetChild()

	if not child then
		return gGuideNodeState.Failure
	end

	local state = child:DoTick()

	if state == gGuideNodeState.Success then
		return gGuideNodeState.Success
	else
		return gGuideNodeState.Running
	end
end
