C_GuideBT_UGuideAutoNavigation = DefClass("C_GuideBT_UGuideAutoNavigation", C_GuideBT_UGuideAutoNavigation, C_GuideBT_ActionBase)
local M = C_GuideBT_UGuideAutoNavigation

function M:OnTick()
	if SGUI.GuideMgr.IsUGuideEnabled(self.guideId) then
		if SGUI.GuideMgr.TryMakeUGuideSelected(self.guideId) then
			return gGuideNodeState.Success
		else
			return gGuideNodeState.Failure
		end
	else
		return gGuideNodeState.Failure
	end
end
