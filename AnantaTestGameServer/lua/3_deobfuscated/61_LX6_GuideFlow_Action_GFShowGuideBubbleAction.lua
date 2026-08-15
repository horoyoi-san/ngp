C_GFShowGuideBubbleAction = DefClass("C_GFShowGuideBubbleAction", C_GFShowGuideBubbleAction, C_GFWaitActionBase)
local C_GFShowGuideBubbleAction = C_GFShowGuideBubbleAction

function C_GFShowGuideBubbleAction:ctor(id, isMonitor, params)
	self.mNodeName = "C_GFShowGuideBubbleAction"
	self.params = {
		guideTeachId = params.guideTeachId,
		timeScale = params.timeScale,
		mId = self.mId,
		bubbleAction = self,
		countDownTime = params.countDownTime
	}
	self.directToGuidePic = false
	self.countDownTime = params.countDownTime
	self.msgEvents = {
		[gEventConstants.GUIDE_GF_WAIT_ACTION_FINISH] = function (eventId, data)
			if data == self.mId then
				self:SetFinish(true)
			end
		end
	}
end

function C_GFShowGuideBubbleAction:OnStartAction()
	return
end

function C_GFShowGuideBubbleAction:OnStopNode()
	self.mStartAction = false

	self:SetFinish(false)

	if self.directToGuidePic then
		self:CloseGuidePanel(true)

		self.directToGuidePic = false
	end

	if not self.mSelfCleared then
		self:CloseGuidePanel(false)
	end
end

function C_GFShowGuideBubbleAction:OnSetSuccess()
	self.mSelfFinished = true

	self:SetFinish(false)

	if self.directToGuidePic then
		self:CloseGuidePanel(true)

		self.directToGuidePic = false
	end

	if not self.finishNoClear then
		self:CloseGuidePanel(false)

		self.mSelfCleared = true
	end
end

function C_GFShowGuideBubbleAction:SetFinish(success)
	self:ClearCheckBlock()
	self:ClearFinishTimer()

	if not success then
		return
	end

	if self.mStartAction then
		self.mSelfFinished = true

		if self.directToGuidePic then
			self:CloseGuidePanel(true)

			self.directToGuidePic = false
		elseif not self.finishNoClear then
			self:CloseGuidePanel(false)

			self.mSelfCleared = true
		end
	else
		self:CloseGuidePanel(true)

		self.directToGuidePic = false

		self:CloseGuidePanel(false)

		self.mSelfCleared = true
	end
end

function C_GFShowGuideBubbleAction:CloseGuidePanel(isGuidePic)
	if isGuidePic then
		-- Nothing
	end
end

return C_GFShowGuideBubbleAction
