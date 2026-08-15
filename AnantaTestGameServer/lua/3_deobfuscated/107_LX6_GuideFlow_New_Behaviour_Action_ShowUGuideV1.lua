C_GuideBT_ShowUGuideV1 = DefClass("C_GuideBT_ShowUGuideV1", C_GuideBT_ShowUGuideV1, C_GuideBT_ActionBase)
local M = C_GuideBT_ShowUGuideV1

function M:OnCreate()
	function self.successHandler(guideId)
		if self.guideId == guideId then
			self._nextState = gGuideNodeState.Success
		end
	end

	function self.incorrectFinishHandler(guideId)
		if self.guideId == guideId then
			self._nextState = gGuideNodeState.Failure
		end
	end

	function self.renderPopHandler(guideId, component)
		if guideId == self.guideId then
			if self.autoNavigate then
				SGUI.GuideMgr.TryMakeUGuideSelected(self.guideId)
			end

			self.store = gStoreManager:GetStoreGroup("DefaultUGuideStore"):GetStoreByWidget(component)

			if self.store then
				local guideCfg = LTConfig.GuideGuideTextConfig.GetConfig(self.gudieTextId)
				self.store.guideText = guideCfg and guideCfg.Text or ""

				if self.popVideoId and self.popVideoId ~= 0 then
					self.store.videoCtrl = 1

					self.store.videoPlayer:Init()
					self.store.videoPlayer:PlayVideo(self.popVideoId, true)
				else
					self.store.videoCtrl = 0
				end
			end
		end
	end
end

function M:OnTick()
	if self._nextState then
		return self._nextState
	end

	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.RenderGuidePopup, self.renderPopHandler)
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.IncorrectCloseGuide, self.incorrectFinishHandler)
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.NextGuide, self.successHandler)
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.SkipGuide, self.successHandler)
	SGUI.GuideMgr.OpenGuide(self.guideId, self.isSupportParallel or false)
end

function M:OnExitRunning()
	self._nextState = nil

	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.RenderGuidePopup, self.renderPopHandler)
	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.IncorrectCloseGuide, self.incorrectFinishHandler)
	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.NextGuide, self.successHandler)
	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.SkipGuide, self.successHandler)
	SGUI.GuideMgr.CloseActiveGuide()
end
