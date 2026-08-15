C_GuideBT_GuideLongPressPanel = DefClass("C_GuideBT_GuideLongPressPanel", C_GuideBT_GuideLongPressPanel, C_GuideBT_ActionBase)
local M = C_GuideBT_GuideLongPressPanel

function M:OnCreate()
	function self.successHandler(guideId)
		if self.startLongPressId == guideId then
			SGUI.GuideMgr.CloseActiveGuide()
			SGUI.GuideMgr.OpenGuide(self.endLongPressId)
			self:StartCountDown()
		elseif self.endLongPressId == guideId and not self.isCountDownEnd then
			self:EndCountDown()

			self._nextState = gGuideNodeState.Failure

			SGUI.GuideMgr.CloseActiveGuide()
			SGUI.GuideMgr.OpenGuide(self.startLongPressId)
		end
	end
end

function M:StartCountDown()
	self.isCountDownEnd = false

	gPanelManager:CheckShow(gPanelId.S_GUIDE_LONG_PRESS_PANEL, {
		longPressTime = self.LongPressTime
	})

	if self.LongPressTime and self.LongPressTime > 0 then
		self._timer = Timer.New(function ()
			self:EndCountDown()

			self.isCountDownEnd = true
			self._nextState = gGuideNodeState.Success
		end, self.LongPressTime):Start()
	else
		self.isCountDownEnd = true
	end
end

function M:EndCountDown()
	gPanelManager:Close(gPanelId.S_GUIDE_LONG_PRESS_PANEL)

	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end

function M:OnTick()
	if self._nextState then
		return self._nextState
	end

	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.NextGuide, self.successHandler)
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.SkipGuide, self.successHandler)
	SGUI.GuideMgr.OpenGuide(self.startLongPressId)
end

function M:OnExitRunning()
	self._nextState = nil

	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end

	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.NextGuide, self.successHandler)
	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.SkipGuide, self.successHandler)
	SGUI.GuideMgr.CloseActiveGuide()
end
