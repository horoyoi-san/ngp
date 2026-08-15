C_GuideBT_GuideHUDLongPress = DefClass("C_GuideBT_GuideHUDLongPress", C_GuideBT_GuideHUDLongPress, C_GuideBT_ActionBase)
local M = C_GuideBT_GuideHUDLongPress

function M:OnCreate()
	function self.successHandler(guideId)
		if self.startLongPressId == guideId then
			self:OnPressStart()
		elseif self.endLongPressId == guideId then
			self:OnPressEnd()
		end
	end
end

function M:StartCountDown()
	self.isCountDownEnd = false

	if self.LongPressTime and self.LongPressTime > 0 then
		self._timer = Timer.New(function ()
			self:EndCountDown()
		end, self.LongPressTime):Start()

		gMessageManager:SendMessage(gEventConstants.GUIDE_HUD_LONGPRESS_CHANGE, {
			countDownStart = 1,
			time = self.LongPressTime
		})
	else
		self:EndCountDown()
	end
end

function M:EndCountDown()
	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end

	self.isCountDownEnd = true
	self._nextState = gGuideNodeState.Success
end

function M:OnTick()
	if self._nextState then
		return self._nextState
	end

	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	gPanelManager:CheckShow(gPanelId.HUD_LONGPRESS_PANEL, {
		longPressTime = self.LongPressTime
	})
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
	gMessageManager:SendMessage(gEventConstants.GUIDE_HUD_LONGPRESS_CHANGE, {
		countDownEnd = 1
	})
end

function M:OnPressStart()
	SGUI.GuideMgr.CloseActiveGuide()
	SGUI.GuideMgr.OpenGuide(self.endLongPressId)
	self:StartCountDown()
end

function M:OnPressEnd()
	if not self.isCountDownEnd then
		if self._timer then
			self._timer:Stop()

			self._timer = nil
		end

		gMessageManager:SendMessage(gEventConstants.GUIDE_HUD_LONGPRESS_CHANGE, {
			countDownReset = 1
		})
		SGUI.GuideMgr.CloseActiveGuide()
		SGUI.GuideMgr.OpenGuide(self.startLongPressId)
	end
end
