C_GuideBT_WaitPanelOpen = DefClass("C_GuideBT_WaitPanelOpen", C_GuideBT_WaitPanelOpen, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitPanelOpen

function M:OnTick()
	if gPanelManager:IsPanelShowing(self.panelId) then
		return gGuideNodeState.Success
	else
		return gGuideNodeState.Running
	end
end
