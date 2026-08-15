C_GuideBT_ShowUGuideV3 = DefClass("C_GuideBT_ShowUGuideV3", C_GuideBT_ShowUGuideV3, C_GuideBT_ActionBase)
local M = C_GuideBT_ShowUGuideV3

function M:OnCreate()
	self.eventHandlers = {
		[gEventConstants.ON_ACTIVE_DEVICE_CHANGED] = function ()
			self:RefreshTipText()
			self:RefreshSmartLineTipText()
		end,
		[gEventConstants.LANGUAGE_CHANGE] = function ()
			self:RefreshTipText()
			self:RefreshSmartLineTipText()
		end
	}

	function self.successHandler(guideId)
		if self.realGuideId == guideId then
			self._nextState = gGuideNodeState.Success
			self.smartLineTipStore = nil

			if self.isRemoveTimeScaleOnSuccess then
				gNewGuideMgr:RemoveTimeScale()
			end
		end
	end

	function self.incorrectFinishHandler(guideId)
		if self.realGuideId == guideId then
			self._nextState = gGuideNodeState.Failure
			self.smartLineTipStore = nil
		end
	end

	function self.renderPopHandler(guideId, component)
		if guideId == self.realGuideId then
			if self.autoNavigate then
				SGUI.GuideMgr.TryMakeUGuideSelected(self.realGuideId)
			end

			self.tipComponent = component

			self:RefreshTipText()
		end
	end

	function self.renderSmartLineHandler(guideId, component)
		if guideId == self.realGuideId then
			self.smartLineTipComponent = component

			self:RefreshSmartLineTipText()
		end
	end
end

function M:RefreshTipText()
	if not self.tipComponent or gCS.LuaUtils.IsNull(self.tipComponent) then
		return
	end

	self.tipStore = gStoreManager:GetStoreGroup("DefaultUGuideStore"):GetStoreByWidget(self.tipComponent)

	if not self.tipStore then
		return
	end

	self.guideTextStore = gStoreManager:GetStoreGroup("GuideTextBaseStore"):GetStoreByWidget(self.tipStore.guideTextBase)
	self.tipStore.mode = 1
	self.guideTextStore.guideText = self:GetGuideText()

	if self.popVideoId and self.popVideoId ~= 0 then
		self.tipStore.videoCtrl = 1

		self.tipStore.videoPlayer:Init()
		self.tipStore.videoPlayer:PlayVideo(self.popVideoId, true)
	else
		self.tipStore.videoCtrl = 0
	end
end

function M:RefreshSmartLineTipText()
	if not self.smartLineTipComponent or gCS.LuaUtils.IsNull(self.smartLineTipComponent) then
		return
	end

	self.smartLineTipStore = gStoreManager:GetStoreGroup("UGuideSmartLineStore"):GetStoreByWidget(self.smartLineTipComponent)

	if not self.smartLineTipStore then
		return
	end

	self.smartLineGuideTextStore = gStoreManager:GetStoreGroup("GuideTextBaseStore"):GetStoreByWidget(self.smartLineTipStore.guideTextBase)
	self.smartLineGuideTextStore.guideText = self:GetGuideText()
end

function M:GetGuideText()
	if not self.guideTextData then
		print_error("#NoCreateIssue ShowUGuideV3启用了弹窗功能但是没有配置文本数据")

		return ""
	end

	local textData = self.guideTextData:Eval()

	return gGuideGlyph:GetGuideRichText(textData)
end

function M:OnTick()
	if self._nextState then
		return self._nextState
	end

	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	gMessageManager:RegisterEventHandlers(self.eventHandlers)
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.RenderGuidePopup, self.renderPopHandler)
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.IncorrectCloseGuide, self.incorrectFinishHandler)
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.NextGuide, self.successHandler)
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.SkipGuide, self.successHandler)
	gGFManager:RegisterSGUIGuideEvent(gGFManager.SEventType.RenderGuideSmartLine, self.renderSmartLineHandler)

	self.realGuideId = self.guideId:Eval()

	if self.realGuideId then
		SGUI.GuideMgr.OpenGuide(self.realGuideId, self.isSupportParallel or false)
	else
		print_error("#NoCreateIssue ShowUGuideV3没有配置guideId")
	end
end

function M:OnExitRunning()
	self.tipComponent = nil
	self.smartLineTipComponent = nil
	self.tipStore = nil
	self.guideTextStore = nil

	gMessageManager:UnregisterEventHandlers(self.eventHandlers)

	self._nextState = nil

	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.RenderGuidePopup, self.renderPopHandler)
	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.IncorrectCloseGuide, self.incorrectFinishHandler)
	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.NextGuide, self.successHandler)
	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.SkipGuide, self.successHandler)
	gGFManager:UnRegisterSGUIGuideEvent(gGFManager.SEventType.RenderGuideSmartLine, self.renderSmartLineHandler)
	SGUI.GuideMgr.CloseActiveGuide()
end
