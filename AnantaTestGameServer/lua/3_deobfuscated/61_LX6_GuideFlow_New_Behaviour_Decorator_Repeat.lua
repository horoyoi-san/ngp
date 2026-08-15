C_GuideBT_Repeat = DefClass("C_GuideBT_Repeat", C_GuideBT_Repeat, C_GuideBT_DecoratorBase)
local M = C_GuideBT_Repeat

function M:OnTick()
	if self:GetChild() then
		self:GetChild():DoTick()
	end

	return gGuideNodeState.Running
end
