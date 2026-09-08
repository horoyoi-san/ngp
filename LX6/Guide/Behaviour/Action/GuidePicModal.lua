-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\GuidePicModal.lua
-- Decompiled from: 00417_GuidePicModal.lua_10d52ae80aa3.luajit

C_GuideBT_GuidePicModal = DefClass("C_GuideBT_GuidePicModal", C_GuideBT_GuidePicModal, C_GuideBT_ActionBase)
local M = C_GuideBT_GuidePicModal

M.OnTick = function(self)
	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	local param = {
		titleId = self.titleId,
		typeTextId = self.typeTextId,
		mainPicId = self.mainPicId,
		videoId = self.videoId
	}

	if self.guideText ~= nil then
		print_error("@huangzhecong [" .. self.tree.guideId .. "_" .. self.tree.counterId .. "] 中的GuidePicModal没有设置guideText")

		return
	end

	param.guideText = self.guideText:Eval()
	param.notInteractiveTime = self.notInteractiveTime

	gNewPopupManager:SetAreaFiveEnable(self.guid, false)
	gPanelManager:CheckShow(gPanelId.GUIDE_PIC_MODAL_PANEL, param)

	self.pauseUUID = gCS.PauseManager.Instance:SetGlobalPause(UX.Game.GamePauseReason.Guide, 0, -1)
end

M.OnExitRunning = function(self)
	gNewPopupManager:SetAreaFiveEnable(self.guid, true)
	gPanelManager:Close(gPanelId.GUIDE_PIC_MODAL_PANEL)

	if self.pauseUUID then
		gCS.PauseManager.Instance:RemoveGlobalPause(self.pauseUUID)

		self.pauseUUID = nil
	end
end

M.GetPreLoadPanelIds = function(self)
	return gPanelId.GUIDE_PIC_MODAL_PANEL
end
