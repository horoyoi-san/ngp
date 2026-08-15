C_GFShowGuidePicAction = DefClass("C_GFShowGuidePicAction", C_GFShowGuidePicAction, C_GFWaitActionBase)
local C_GFShowGuidePicAction = C_GFShowGuidePicAction

function C_GFShowGuidePicAction:ctor(id, isMonitor, params)
	self.mNodeName = "C_GFShowGuidePicAction"
	self.params = {
		guideTeachId = params.guideTeachId,
		mId = self.mId,
		notInteractiveTime = params.notInteractiveTime or 0
	}
	self.msgEvents = {
		[gEventConstants.GUIDE_GF_WAIT_ACTION_FINISH] = function (eventId, data)
			if data == self.mId then
				self:SetFinish(true)
			end
		end
	}
end

function C_GFShowGuidePicAction:OnStartAction()
	self.mStartAction = true
end

function C_GFShowGuidePicAction:OnStopNode()
	self.mStartAction = false

	if not self.mSelfFinished or not self.mSelfCleared then
		self:CloseGuidePanel()
	end
end

function C_GFShowGuidePicAction:OnSetSuccess()
	self.mSelfFinished = true
end

function C_GFShowGuidePicAction:CloseGuidePanel()
	return
end

return C_GFShowGuidePicAction
