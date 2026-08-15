C_GFShowGuideFullscreenAction = DefClass("C_GFShowGuideFullscreenAction", C_GFShowGuideFullscreenAction, C_GFWaitActionBase)
local C_GFShowGuideFullscreenAction = C_GFShowGuideFullscreenAction

function C_GFShowGuideFullscreenAction:ctor(id, isMonitor, params)
	self.params = {
		title = params.title,
		description = params.description,
		iconId = params.iconId,
		mId = self.mId
	}
	self.countDownTime = params.countDownTime or -1
	self.mNodeName = "C_GFShowGuideFullscreenAction"
	self.msgEvents = {
		[gEventConstants.GUIDE_GF_WAIT_ACTION_FINISH] = function (eventId, data)
			if data == self.mId then
				self:SetFinish(true)
			end
		end
	}
end

function C_GFShowGuideFullscreenAction:OnStartAction()
	self:InitFinishTimer()

	self.mStartAction = true
end

function C_GFShowGuideFullscreenAction:OnStopNode()
	self.mStartAction = false

	self:SetFinish(false)

	if not self.mSelfFinished or not self.mSelfCleared then
		self:CloseGuidePanel()
	end
end

function C_GFShowGuideFullscreenAction:OnSetSuccess()
	self.mSelfFinished = true
end

function C_GFShowGuideFullscreenAction:CloseGuidePanel()
	return
end

return C_GFShowGuideFullscreenAction
