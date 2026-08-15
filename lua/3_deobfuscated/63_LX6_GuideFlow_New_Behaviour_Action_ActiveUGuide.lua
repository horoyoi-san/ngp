C_GuideBT_ActiveUGuide = DefClass("C_GuideBT_ActiveUGuide", C_GuideBT_ActiveUGuide, C_GuideBT_ActionBase)
local M = C_GuideBT_ActiveUGuide

function M:OnCreate()
	function self.successHandler(guideId)
		if self.guideId == guideId then
			self._nextState = self.isSupportParallel and gGuideNodeState.Match or gGuideNodeState.Success
			self.isMatchOnce = true

			print_notice("[GuideBT] ActiveUGuide successHandler " .. guideId)
		end
	end

	function self.incorrectFinishHandler(guideId)
		if self.guideId == guideId then
			self._nextState = gGuideNodeState.Failure
		end
	end

	function self.beginMatchHandler(guideId)
		if self.guideId == guideId then
			self._nextState = self.isSupportParallel and gGuideNodeState.Match or gGuideNodeState.Success

			print_notice("[GuideBT] ActiveUGuide beginMatchHandler " .. guideId)
		end
	end

	function self.endMatchHandler(guideId)
		if self.guideId == guideId then
			self._nextState = gGuideNodeState.Running

			print_notice("[GuideBT] ActiveUGuide endMatchHandler " .. guideId)
		end
	end
end

function M:OnTick()
	if self._nextState then
		local state = self._nextState

		if self._nextState == gGuideNodeState.Match and self.isMatchOnce then
			self._nextState = gGuideNodeState.Running
			self.isMatchOnce = false
		end

		return state
	end

	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.IncorrectCloseGuide, self.incorrectFinishHandler)
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.NextGuide, self.successHandler)
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.SkipGuide, self.successHandler)
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.BeginMatchGuide, self.beginMatchHandler)
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.EndMatchGuide, self.endMatchHandler)

	if self.dontDisplay then
		SGUI.GuideMgr.OpenGuideWithoutDisplay(self.guideId, self.isSupportParallel)
	else
		SGUI.GuideMgr.OpenGuide(self.guideId, self.isSupportParallel)
	end
end

function M:OnExitRunning()
	self._nextState = nil

	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.IncorrectCloseGuide, self.incorrectFinishHandler)
	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.NextGuide, self.successHandler)
	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.SkipGuide, self.successHandler)
	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.BeginMatchGuide, self.beginMatchHandler)
	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.EndMatchGuide, self.endMatchHandler)
	SGUI.GuideMgr.CloseActiveGuide()
end
