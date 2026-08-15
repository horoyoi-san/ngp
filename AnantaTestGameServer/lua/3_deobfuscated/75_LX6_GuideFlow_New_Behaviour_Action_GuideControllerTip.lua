C_GuideBT_GuideControllerTip = DefClass("C_GuideBT_GuideControllerTip", C_GuideBT_GuideControllerTip, C_GuideBT_ActionBase)
local M = C_GuideBT_GuideControllerTip

function M:OnTick()
	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	local param = {
		controllerTabIndex = self.controllerTabIndex
	}

	gPanelManager:CheckShow(gPanelId.GUIDE_CONTROLLER_TIP, param)
end

function M:OnExitRunning()
	gPanelManager:Close(gPanelId.GUIDE_CONTROLLER_TIP)
end
