-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\GuideControllerTip.lua
-- Decompiled from: 00411_GuideControllerTip.lua_ce402fba4d44.luajit

C_GuideBT_GuideControllerTip = DefClass("C_GuideBT_GuideControllerTip", C_GuideBT_GuideControllerTip, C_GuideBT_ActionBase)
local M = C_GuideBT_GuideControllerTip

M.OnTick = function(self)
	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	local param = {
		controllerTabIndex = self.controllerTabIndex
	}

	gPanelManager:CheckShow(gPanelId.GUIDE_CONTROLLER_TIP, param)
end

M.OnExitRunning = function(self)
	gPanelManager:Close(gPanelId.GUIDE_CONTROLLER_TIP)
end

M.GetPreLoadPanelIds = function(self)
	return gPanelId.GUIDE_CONTROLLER_TIP
end
