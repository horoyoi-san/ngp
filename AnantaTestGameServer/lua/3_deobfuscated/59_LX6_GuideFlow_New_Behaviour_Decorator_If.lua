C_GuideBT_If = DefClass("C_GuideBT_If", C_GuideBT_If, C_GuideBT_DecoratorBase)
local M = C_GuideBT_If

function M:OnTick()
	if self.condition:Eval() then
		if self:GetChild() then
			return self:GetChild():DoTick()
		else
			return gGuideNodeState.Success
		end
	end

	return gGuideNodeState.Failure
end
