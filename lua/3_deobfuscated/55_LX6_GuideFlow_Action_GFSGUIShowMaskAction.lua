local GuideMgr = SGUI.GuideMgr
C_GFSGUIShowMaskAction = DefClass("C_GFSGUIShowMaskAction", C_GFSGUIShowMaskAction, C_GFWaitActionBase)
local C_GFSGUIShowMaskAction = C_GFSGUIShowMaskAction

function C_GFSGUIShowMaskAction:ctor(id, isMonitor, params)
	self.guideId = params.guideId
	self.guideText = params.guideText
	self.mId = self.mId
	self.finishNoClear = params.finishNoClear
	self.finishNoClearRecord = params.finishNoClear
	self.pcKeyId = params.pcKeyId
	self.gamePadId = params.gamePadId
	self.autoNavigate = params.autoNavigate
	self.store = nil
	self.mNodeName = "C_GFSGUIShowMaskAction"

	function self.renderPopHandler(guideId, component)
		if guideId == self.guideId then
			if self.autoNavigate then
				SGUI.GuideMgr.TryMakeUGuideSelected(self.guideId)
			end

			self.store = gStoreManager:GetStoreGroup("DefaultUGuideStore"):GetStoreByWidget(component)

			if self.store then
				self.store.guideText = gGFFormatUtil:GetGuideText(self.guideText)
			end
		end
	end

	function self.finishHandler(guideId)
		if self.mStartAction and guideId == self.guideId then
			GuideMgr.CloseActiveGuide()

			self.store = nil

			self:SetFinish(true)
		end
	end

	function self.incorrectFinishHandler(guideId)
		if self.mStartAction and guideId == self.guideId then
			self.store = nil

			self:SetFinish(true)
		end
	end
end

function C_GFSGUIShowMaskAction:OnStart()
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.RenderGuidePopup, self.renderPopHandler)
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.IncorrectCloseGuide, self.incorrectFinishHandler)
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.NextGuide, self.finishHandler)
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.SkipGuide, self.finishHandler)
end

function C_GFSGUIShowMaskAction:OnFinish(isSuccess)
	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.RenderGuidePopup, self.renderPopHandler)
	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.IncorrectCloseGuide, self.incorrectFinishHandler)
	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.NextGuide, self.finishHandler)
	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.SkipGuide, self.finishHandler)
end

function C_GFSGUIShowMaskAction:OnStartAction()
	GuideMgr.OpenGuide(self.guideId)

	self.mStartAction = true
end

function C_GFSGUIShowMaskAction:OnStopNode()
	local started = self.mStartAction
	self.mStartAction = false

	if started and (not self.mSelfFinished or not self.mSelfCleared) then
		GuideMgr.CloseActiveGuide()

		self.store = nil
	end
end

return C_GFSGUIShowMaskAction
