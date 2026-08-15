C_GFShowModalMaskAction = DefClass("C_GFShowModalMaskAction", C_GFShowModalMaskAction, C_GFWaitActionBase)
local C_GFShowModalMaskAction = C_GFShowModalMaskAction

function C_GFShowModalMaskAction:ctor(id, isMonitor, params)
	self.params = {
		nodeName = params.nodeName,
		showType = params.showType,
		maskMode = params.maskMode,
		textDir = C_GFShowModalMaskAction.TextDirMap(params.textDir),
		size = params.size,
		offset = params.offset,
		delay = params.delay,
		guideText = params.guideText,
		keyEventId = params.keyEventId,
		controllerButtonCellId = params.controllerButtonCellId,
		iconId = params.iconId,
		fadeRange = params.fadeRange,
		pressTime = params.pressTime,
		clickNum = params.clickNum,
		skipCoverCheck = params.skipCoverCheck,
		mId = self.mId,
		finishNoClear = params.finishNoClear,
		controllerSize = params.controllerSize and params.controllerSize ~= "" and params.controllerSize or params.size,
		controllerOffset = params.controllerOffset and params.controllerOffset ~= "" and params.controllerOffset or params.offset,
		controllerTextDir = C_GFShowModalMaskAction.TextDirMap(params.controllerTextDir)
	}
	self.finishNoClearRecord = params.finishNoClear
	self.FinishType = {
		SafeFinish = 1,
		NormalFinish = 0
	}
	self.mNodeName = "C_GFShowModalMaskAction"
	self.msgEvents = {
		[gEventConstants.GUIDE_MASK_FINISH] = function (eventId, data)
			if data.mId == self.mId then
				if data.finishType == self.FinishType.SafeFinish then
					self.finishNoClear = false
				end

				self:SetFinish(true)

				self.finishNoClear = self.finishNoClearRecord
			end
		end
	}
end

function C_GFShowModalMaskAction:OnStartAction()
	self.params.node = gGuideNode:GetNode(self.params.nodeName)

	if not gCS.LuaUtils.IsNull(self.params.node.gameObject) and self.params.node.gameObject.activeInHierarchy then
		local guideNode = self.params.node.gameObject:GetComponent(typeof(LX6.Guide.GuideNode))

		if guideNode then
			guideNode:SetupEventLayer()
		end

		self.mStartAction = true
	end
end

function C_GFShowModalMaskAction:OnFinishAction()
	self:ClearEventLayer()

	self.mFinishAction = true
end

function C_GFShowModalMaskAction:OnStopNode()
	local started = self.mStartAction
	self.mStartAction = false

	if started then
		self:ClearEventLayer()

		if self.mSelfFinished and not self.mSelfCleared then
			-- Nothing
		end
	end
end

function C_GFShowModalMaskAction:ClearEventLayer()
	local go = self.params.node.gameObject

	if not gCS.LuaUtils.IsNull(go) then
		local guideNode = go:GetComponent(typeof(LX6.Guide.GuideNode))

		if guideNode then
			guideNode:ResetEventLayer()
		end
	end
end

function C_GFShowModalMaskAction:CloseGuidePanel()
	return
end

return C_GFShowModalMaskAction
