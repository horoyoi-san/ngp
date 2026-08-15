C_GuideBT_WaitUGuideAutoNavigation = DefClass("C_GuideBT_WaitUGuideAutoNavigation", C_GuideBT_WaitUGuideAutoNavigation, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitUGuideAutoNavigation

function M:OnTick()
	if SGUI.GuideMgr.IsUGuideEnabled(self.guideId) then
		if SGUI.GuideMgr.TryMakeUGuideSelected(self.guideId) then
			return gGuideNodeState.Success
		else
			return gGuideNodeState.Running
		end
	else
		return gGuideNodeState.Running
	end
end
