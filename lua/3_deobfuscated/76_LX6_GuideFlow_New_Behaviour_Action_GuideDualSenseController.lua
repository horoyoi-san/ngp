C_GuideBT_GuideDualSenseController = DefClass("C_GuideBT_GuideDualSenseController", C_GuideBT_GuideDualSenseController, C_GuideBT_ActionBase)
local M = C_GuideBT_GuideDualSenseController

function M:OnTick()
	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	local param = {
		normalGuideTextId = self.normalTextId,
		dualSenseGuideTextId = self.dualSenseTextId,
		controllerTabIndex = self.controllerTabIndex
	}

	gPanelManager:CheckShow(gPanelId.GUIDE_DUAL_SENSE_CONTROLLER, param)
end

function M:OnExitRunning()
	gPanelManager:Close(gPanelId.GUIDE_DUAL_SENSE_CONTROLLER)
end
