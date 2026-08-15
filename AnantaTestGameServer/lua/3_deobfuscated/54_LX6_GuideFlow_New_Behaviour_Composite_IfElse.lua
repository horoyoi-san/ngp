C_GuideBT_IfElse = DefClass("C_GuideBT_IfElse", C_GuideBT_IfElse, C_GuideBT_CompositeBase)
local M = C_GuideBT_IfElse

function M:OnTick()
	if self.condition:Eval() then
		if self.children[1] then
			return self.children[1]:DoTick()
		else
			return gGuideNodeState.Success
		end
	elseif self.children[2] then
		return self.children[2]:DoTick()
	else
		return gGuideNodeState.Success
	end
end
