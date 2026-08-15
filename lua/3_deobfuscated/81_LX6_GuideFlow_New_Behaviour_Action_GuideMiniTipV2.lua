C_GuideBT_GuideMiniTipV2 = DefClass("C_GuideBT_GuideMiniTipV2", C_GuideBT_GuideMiniTipV2, C_GuideBT_ActionBase)
local M = C_GuideBT_GuideMiniTipV2

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

	if self.duration and self.duration > 0 then
		self._timer = Timer.New(function ()
			if gPanelManager:IsPanelShowing(gPanelId.S_GUIDE_MINI_TIP_PANEL) then
				local store = gStoreManager:GetStoreGroup("GuideMiniTipStore")

				if store then
					store:PlayCloseAnim()
				else
					self._nextState = gGuideNodeState.Success
				end
			else
				self._nextState = gGuideNodeState.Success
			end
		end, self.duration):Start()
	end

	local list = {}

	for _, data in ipairs(self.guideTexts or {}) do
		if data then
			table.insert(list, data:Eval())
		end
	end

	if #list == 0 then
		print_error("@huangzhecong [" .. self.tree.guideId .. "_" .. self.tree.counterId .. "] 中的GuideMiniTipV2没有设置guideText")

		return
	end

	local param = {
		escShowDelay = self.escShowDelay,
		onPlayerClose = function ()
			self._nextState = gGuideNodeState.Success
		end,
		guideTextList = list,
		titleId = self.title
	}

	gNewPopupManager:SetAreaFiveEnable(self.guid, false)
	gPanelManager:CheckShow(gPanelId.S_GUIDE_MINI_TIP_PANEL, param)
end

function M:OnExitRunning()
	gNewPopupManager:SetAreaFiveEnable(self.guid, true)
	gPanelManager:Close(gPanelId.S_GUIDE_MINI_TIP_PANEL)
	self:ClearTimer()
end

function M:ClearTimer()
	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end

function M:ClosePanel()
	local storeGroup = gStoreManager:GetStoreGroup("GuideMiniTipStore")

	if storeGroup then
		storeGroup:PlayCloseAnim()
	end
end
