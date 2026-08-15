C_GuideBT_Invert = DefClass("C_GuideBT_Invert", C_GuideBT_Invert, C_GuideBT_DecoratorBase)
local M = C_GuideBT_Invert

function M:OnTick()
	local child = self:GetChild()

	if not child then
		return gGuideNodeState.Failure
	end

	local state = child:DoTick()

	if state == gGuideNodeState.Success then
		return gGuideNodeState.Failure
	elseif state == gGuideNodeState.Failure then
		return gGuideNodeState.Success
	else
		return state
	end
end
