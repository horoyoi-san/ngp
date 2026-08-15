C_GuideBT_GuidePic = DefClass("C_GuideBT_GuidePic", C_GuideBT_GuidePic, C_GuideBT_ActionBase)
local M = C_GuideBT_GuidePic

function M:OnTick()
	local _nextState = self._nextState

	if _nextState then
		self._nextState = nil

		return _nextState
	end

	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	self:ClearTimer()

	local param = {
		titleId = self.titleId,
		typeTextId = self.typeTextId,
		mainPicId = self.mainPicId,
		videoId = self.videoId
	}

	if self.guideText == nil then
		print_error("@huangzhecong [" .. self.tree.guideId .. "_" .. self.tree.counterId .. "] 中的GuidePic没有设置guideText")

		return
	end

	param.guideText = self.guideText:Eval()
	param.notInteractiveTime = self.notInteractiveTime

	function param.onClose()
		self._nextState = gGuideNodeState.Success
	end

	if self.autoCloseTime and self.autoCloseTime > 0 then
		self._timer = Timer.New(function ()
			self._nextState = gGuideNodeState.Success
		end, self.autoCloseTime):Start()
	end

	gNewPopupManager:SetAreaFiveEnable(self.guid, false)
	gPanelManager:CheckShow(gPanelId.S_GUIDE_PIC, param)
end

function M:OnExitRunning()
	self:ClearTimer()
	gNewPopupManager:SetAreaFiveEnable(self.guid, true)
	self:ClosePanel()
end

function M:ClearTimer()
	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end

function M:ClosePanel()
	local storeGroup = gStoreManager:GetStoreGroup("GuidePicPanelStore")

	if storeGroup then
		storeGroup:PlayCloseAnim()
	end
end
