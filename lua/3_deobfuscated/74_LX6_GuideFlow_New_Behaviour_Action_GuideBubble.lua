C_GuideBT_GuideBubble = DefClass("C_GuideBT_GuideBubble", C_GuideBT_GuideBubble, C_GuideBT_ActionBase)
local M = C_GuideBT_GuideBubble

function M:OnCreate()
	return
end

function M:OnTick()
	local nextState = self._nextState

	if nextState then
		self._nextState = nil

		return nextState
	end

	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	local param = {
		guideTeachId = self.guideTeachId
	}

	if self.closeTime and self.closeTime > 0 then
		param.closeTime = self.closeTime
	end

	function param.finishNode()
		self._nextState = gGuideNodeState.Success
	end

	gPanelManager:CheckShow(gPanelId.S_GUIDE_BUBBLE, param)
end

function M:OnExitRunning()
	gPanelManager:Close(gPanelId.S_GUIDE_BUBBLE)
	gPanelManager:Close(gPanelId.GUIDE_BUBBLE_FULL_SCREEN_PANEL)
end
