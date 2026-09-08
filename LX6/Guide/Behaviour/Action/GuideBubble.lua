-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\GuideBubble.lua
-- Decompiled from: 00410_GuideBubble.lua_b34cde4d4ce6.luajit

C_GuideBT_GuideBubble = DefClass("C_GuideBT_GuideBubble", C_GuideBT_GuideBubble, C_GuideBT_ActionBase)
local M = C_GuideBT_GuideBubble

M.OnCreate = function(self)
end

M.OnTick = function(self)
	local nextState = self._nextState

	if nextState then
		self._nextState = nil

		return nextState
	end

	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	local param = {
		guideTeachId = self.guideTeachId
	}

	if self.closeTime and self.closeTime <= 0 then
		param.closeTime = self.closeTime
	end

	param.finishNode = function()
		self._nextState = gGuideNodeState.Success
	end

	gPanelManager:CheckShow(gPanelId.S_GUIDE_BUBBLE, param)
end

M.OnExitRunning = function(self)
	gPanelManager:Close(gPanelId.S_GUIDE_BUBBLE)
	gPanelManager:Close(gPanelId.GUIDE_BUBBLE_FULL_SCREEN_PANEL)
end

M.GetPreLoadPanelIds = function(self)
	return {
		gPanelId.S_GUIDE_BUBBLE,
		gPanelId.GUIDE_BUBBLE_FULL_SCREEN_PANEL
	}
end
