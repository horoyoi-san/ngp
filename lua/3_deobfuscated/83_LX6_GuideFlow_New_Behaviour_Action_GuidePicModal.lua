C_GuideBT_GuidePicModal = DefClass("C_GuideBT_GuidePicModal", C_GuideBT_GuidePicModal, C_GuideBT_ActionBase)
local M = C_GuideBT_GuidePicModal

function M:OnTick()
	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	local param = {
		titleId = self.titleId,
		typeTextId = self.typeTextId,
		mainPicId = self.mainPicId,
		videoId = self.videoId
	}

	if self.guideText == nil then
		print_error("@huangzhecong [" .. self.tree.guideId .. "_" .. self.tree.counterId .. "] 中的GuidePicModal没有设置guideText")

		return
	end

	param.guideText = self.guideText:Eval()
	param.notInteractiveTime = self.notInteractiveTime

	gNewPopupManager:SetAreaFiveEnable(self.guid, false)
	gPanelManager:CheckShow(gPanelId.GUIDE_PIC_MODAL_PANEL, param)

	self.pauseUUID = gCS.PauseManager.Instance:SetGlobalPause(UX.Game.GamePauseReason.Guide, 0, -1)
end

function M:OnExitRunning()
	gNewPopupManager:SetAreaFiveEnable(self.guid, true)
	gPanelManager:Close(gPanelId.GUIDE_PIC_MODAL_PANEL)

	if self.pauseUUID then
		gCS.PauseManager.Instance:RemoveGlobalPause(self.pauseUUID)

		self.pauseUUID = nil
	end
end
