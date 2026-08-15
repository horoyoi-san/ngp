C_GuideBT_GuideTip = DefClass("C_GuideBT_GuideTip", C_GuideBT_GuideTip, C_GuideBT_ActionBase)
local M = C_GuideBT_GuideTip

function M:OnTick()
	local nextState = self.nextState

	if nextState then
		self.nextState = nil

		return nextState
	end

	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	local param = {
		titleId = self.titleId
	}

	if self.guideText == nil then
		print_error("@huangzhecong [" .. self.tree.guideId .. "_" .. self.tree.counterId .. "] 中的GuideTip没有设置guideText")

		return
	end

	param.guideText = self.guideText:Eval()
	param.escShowDelay = self.escShowDelay
	param.titleIconId = self.titleIconId

	function param.onPlayerClose()
		self.nextState = gGuideNodeState.Success
	end

	self:ClearTimer()

	if self.duration and self.duration > 0 then
		self._timer = Timer.New(function ()
			self.nextState = gGuideNodeState.Success
		end, self.duration):Start()
	end

	gNewPopupManager:SetAreaFiveEnable(self.guid, false)
	gPanelManager:CheckShow(gPanelId.S_GUIDE_TIP, param)
	print_notice("C_GuideBT_GuideTip:OnEnterRunning")
end

function M:OnExitRunning()
	gNewPopupManager:SetAreaFiveEnable(self.guid, true)
	self:ClosePanel()
	print_notice("C_GuideBT_GuideTip:OnExitRunning")
end

function M:ClearTimer()
	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end

function M:ClosePanel()
	local storeGroup = gStoreManager:GetStoreGroup("GuideTipStore")

	if storeGroup then
		storeGroup:PlayCloseAnim()
	end
end
