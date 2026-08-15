C_GFShowWeakGuideMessageAction = DefClass("C_GFShowWeakGuideMessageAction", C_GFShowWeakGuideMessageAction, C_GFWaitActionBase)
local C_GFShowWeakGuideMessageAction = C_GFShowWeakGuideMessageAction

function C_GFShowWeakGuideMessageAction:ctor(id, isMonitor, params)
	self.params = {
		guideText = params.guideText,
		showType = params.showType,
		modal = params.isModal,
		keyEventId = params.keyEventId,
		iconId = params.iconId,
		fontSize = params.fontSize,
		timeScale = params.timeScale,
		mId = self.mId,
		controllerButtonCellId = params.controllerButtonCellId,
		extendKeyEventId = params.extendKeyEventId,
		keyEventBehaviour = params.keyEventBehaviour,
		_tmp_IsWeak = true,
		_tmp_GFNode = self
	}
	self.countDownTime = params.countDownTime or -1
	self.finishCondition = params.finishCondition
	self.mNodeName = "C_GFShowWeakGuideMessageAction"
	self.msgEvents = {}
end

function C_GFShowWeakGuideMessageAction:OnStartAction()
	self:InitFinishTimer()
	self:InitCheckBlock()

	self.mStartAction = true
end

function C_GFShowWeakGuideMessageAction:OnStopNode()
	self.mStartAction = false

	self:SetFinish(false)

	if not self.mSelfFinished or not self.mSelfCleared then
		self:CloseGuidePanel()
	end
end

function C_GFShowWeakGuideMessageAction:OnSetSuccess()
	self.mSelfFinished = true
end

function C_GFShowWeakGuideMessageAction:CloseGuidePanel()
	return
end

return C_GFShowWeakGuideMessageAction
