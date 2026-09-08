-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\GuideDualSenseController.lua
-- Decompiled from: 00412_GuideDualSenseController.lua_3cb716916c9e.luajit

C_GuideBT_GuideDualSenseController = DefClass("C_GuideBT_GuideDualSenseController", C_GuideBT_GuideDualSenseController, C_GuideBT_ActionBase)
local M = C_GuideBT_GuideDualSenseController

M.OnTick = function(self)
	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	local param = {
		normalGuideTextId = self.normalTextId,
		dualSenseGuideTextId = self.dualSenseTextId,
		controllerTabIndex = self.controllerTabIndex
	}

	gPanelManager:CheckShow(gPanelId.GUIDE_DUAL_SENSE_CONTROLLER, param)
end

M.OnExitRunning = function(self)
	gPanelManager:Close(gPanelId.GUIDE_DUAL_SENSE_CONTROLLER)
end

M.GetPreLoadPanelIds = function(self)
	return gPanelId.GUIDE_DUAL_SENSE_CONTROLLER
end
