C_GuideBT_GuideFullScreen = DefClass("C_GuideBT_GuideFullScreen", C_GuideBT_GuideFullScreen, C_GuideBT_ActionBase)
local M = C_GuideBT_GuideFullScreen

function M:OnTick()
	local _nextState = self._nextState

	if _nextState then
		self._nextState = nil

		return _nextState
	end

	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	local params = {
		pageDatas = {},
		onClose = function ()
			self._nextState = gGuideNodeState.Success
		end
	}

	for _, data in ipairs(self.fullscreenDatas or {}) do
		if data then
			table.insert(params.pageDatas, data:Eval())
		end
	end

	self.pauseUUID = gCS.PauseManager.Instance:SetGlobalPause(UX.Game.GamePauseReason.Guide, 0, -1)

	gPanelManager:CheckShow(gPanelId.GUIDE_FULL_SCREEN_PANEL, params)
end

function M:OnExitRunning()
	if gPanelManager:IsPanelShowing(gPanelId.GUIDE_FULL_SCREEN_PANEL) then
		gPanelManager:Close(gPanelId.GUIDE_FULL_SCREEN_PANEL)
	end

	if self.pauseUUID then
		gCS.PauseManager.Instance:RemoveGlobalPause(self.pauseUUID)

		self.pauseUUID = nil
	end
end
