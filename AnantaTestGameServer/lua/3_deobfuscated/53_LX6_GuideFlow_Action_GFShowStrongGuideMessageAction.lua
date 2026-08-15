C_GFShowStrongGuideMessageAction = DefClass("C_GFShowStrongGuideMessageAction", C_GFShowStrongGuideMessageAction, C_GFWaitActionBase)
local C_GFShowStrongGuideMessageAction = C_GFShowStrongGuideMessageAction

function C_GFShowStrongGuideMessageAction:ctor(id, isMonitor, params)
	self.params = {
		guideText = params.guideText,
		showType = params.showType,
		modal = params.isModal,
		keyEventId = params.keyEventId,
		iconId = params.iconId,
		fontSize = params.fontSize,
		timeScale = params.timeScale,
		mId = self.mId,
		controllerButtonCellId = params.controllerButtonCellId
	}
	self.finishCondition = params.finishCondition
	self.countDownTime = params.countDownTime or -1
	self.mNodeName = "C_GFShowStrongGuideMessageAction"
	self.msgEvents = {}
end

function C_GFShowStrongGuideMessageAction:OnStartAction()
	self:InitFinishTimer()
	self:InitCheckBlock()

	self.mStartAction = true
end

function C_GFShowStrongGuideMessageAction:OnStopNode()
	self.mStartAction = false

	self:SetFinish(false)

	if not self.mSelfFinished or not self.mSelfCleared then
		self:CloseGuidePanel()
	end
end

function C_GFShowStrongGuideMessageAction:OnSetSuccess()
	self.mSelfFinished = true
end

function C_GFShowStrongGuideMessageAction:CloseGuidePanel()
	return
end

return C_GFShowStrongGuideMessageAction
