local gGFConstant = require("LX6/GuideFlow/GFConstant")
local static_props = {
	TextDirMap = function (dir)
		return
	end
}
C_GFWaitActionBase = DefClass("C_GFWaitActionBase", C_GFWaitActionBase, C_GFNodeBase, static_props)
local C_GFWaitActionBase = C_GFWaitActionBase

function C_GFWaitActionBase:ctor(id, isMonitor, params)
	self.mNodeType = gGFConstant.NodeType.Action
	self.mSelfFinished = false
	self.mNodeName = "C_GFWaitActionBase"
	self.finishDirectly = params.finishDirectly
	self.finishNoClear = params.finishNoClear
	self.mSelfCleared = false
	self.msgEvents = {}
	self.mStartAction = false
	self.mFinishAction = false
	self.finishCondition = nil
	self.needCheckFinish = false
	self.checkBlock = nil
	self.finishTimer = nil
	self.countDownTime = -1
end

function C_GFWaitActionBase:StartNode()
	if self.mState == gGFConstant.State.Ready then
		self.mState = gGFConstant.State.Running
		self.mStartTime = Time.time
		self.mStarted = true
		self.mSelfFinished = false
		self.mStartAction = false
		self.mFinishAction = false

		self:OnStart()

		self.mListenerAdd = false

		if not self.finishDirectly and not self.mListenerAdd then
			self:AddListeners()

			self.mListenerAdd = true
		end

		self:SendNodeDebugInfo()

		if gGFManager.Debug then
			print_debug("GF Debug => NodeName=", self.mNodeName, " id=", self.mId, " => StartNode Done", " State=", self.mState, " frame=", Time.frameCount)
		end
	end
end

function C_GFWaitActionBase:FinishNode(isSuccess)
	if self.mState == gGFConstant.State.Running then
		self.mState = isSuccess and gGFConstant.State.Success or gGFConstant.State.Failure
		self.mFinishTime = Time.time
		self.mStarted = false

		self:OnFinish(isSuccess)

		if not self.finishDirectly and self.mListenerAdd then
			self:RemoveListeners()

			self.mListenerAdd = false
		end

		self:SendNodeDebugInfo()

		if gGFManager.Debug then
			print_debug("GF Debug => NodeName=", self.mNodeName, " id=", self.mId, " => FinishNode Done, isSuccess=", isSuccess, " State=", self.mState, " frame=", Time.frameCount)
		end
	end
end

function C_GFWaitActionBase:UpdateNode()
	if self.mState == gGFConstant.State.Running then
		local GameStage = gLuaDataManager.gameStage

		if GameStage ~= gGFConstant.GameStage.GameScene then
			return
		end

		if not self.mStartAction then
			self:OnStartAction()
		end

		if self.mStartAction then
			self:OnUpdate()

			if self.finishDirectly then
				if not self.mFinishAction then
					self:OnFinishAction()
				end

				if self.mFinishAction then
					self:FinishNode(true)
				end
			elseif self.mSelfFinished then
				if not self.mFinishAction then
					self:OnFinishAction()
				end

				if self.mFinishAction then
					self:FinishNode(true)
				end
			end
		end
	end
end

function C_GFWaitActionBase:ResetNode()
	if gGFManager.Debug then
		print_debug("GF Debug => NodeName=", self.mNodeName, " id=", self.mId, " => ResetNode, frame=", Time.frameCount)
	end

	if self.mStarted then
		self.mFinishTime = Time.time
		self.mStarted = false
	end

	self:StopNode()

	self.mState = gGFConstant.State.Ready

	self:OnReset()

	if not self.finishDirectly and self.mListenerAdd then
		self:RemoveListeners()

		self.mListenerAdd = false
	end

	self.mSelfFinished = false
	self.mStartAction = false
	self.mFinishAction = false

	self:SendNodeDebugInfo()
end

function C_GFWaitActionBase:SetSuccess()
	if gGFManager.Debug then
		print_debug("GF Debug => NodeName=", self.mNodeName, " id=", self.mId, " => SetSuccess, frame=", Time.frameCount)
	end

	self:FinishNode(true)
	self:StopNode()
	self:OnSetSuccess()

	if not self.finishDirectly and self.mListenerAdd then
		self:RemoveListeners()

		self.mListenerAdd = false
	end

	self.mSelfFinished = false
	self.mStartAction = false
	self.mFinishAction = false
end

function C_GFWaitActionBase:DestroyNode()
	if gGFManager.Debug then
		print_debug("GF Debug => NodeName=", self.mNodeName, " id=", self.mId, " => DestroyNode, frame=", Time.frameCount)
	end

	if not self.finishDirectly then
		self:RemoveListeners()
	end

	self:StopNode()
	self:OnDestroy()

	self.mState = gGFConstant.State.Ready

	self:SendNodeDebugInfo()
end

function C_GFWaitActionBase:OnUpdate()
	return
end

function C_GFWaitActionBase:OnStartAction()
	self.mStartAction = true
end

function C_GFWaitActionBase:OnFinishAction()
	self.mFinishAction = true
end

function C_GFWaitActionBase:AddListeners()
	gMessageManager:RegisterEventHandlers(self.msgEvents)
end

function C_GFWaitActionBase:RemoveListeners()
	gMessageManager:UnregisterEventHandlers(self.msgEvents)
end

function C_GFWaitActionBase:OnUpdateForce()
	if self.mStartAction and self.needCheckFinish then
		local finish = self.checkBlock:Check()

		if finish then
			self:SetFinish(true)
		end
	end
end

function C_GFWaitActionBase:InitCheckBlock()
	if self.finishCondition and not string.is_null_or_empty(self.finishCondition) and gGuideConditionFormula[self.finishCondition] then
		self.needCheckFinish = true
		self.checkBlock = gGuideConditionFormula[self.finishCondition](gGuideConditionFormula)
	end
end

function C_GFWaitActionBase:ClearCheckBlock()
	self.needCheckFinish = false

	if self.checkBlock then
		self.checkBlock:Dispose()

		self.checkBlock = nil
	end
end

function C_GFWaitActionBase:InitFinishTimer()
	if self.countDownTime > 0 then
		self.finishTimer = Timer.New(function ()
			self:SetFinish(true)
		end, self.countDownTime, 1, true):Start()
	end
end

function C_GFWaitActionBase:ClearFinishTimer()
	if self.finishTimer then
		self.finishTimer:Stop()

		self.finishTimer = nil
	end
end

function C_GFWaitActionBase:SetFinish(success)
	self:ClearCheckBlock()
	self:ClearFinishTimer()

	if not success then
		return
	end

	if self.mStartAction then
		self.mSelfFinished = true
	end

	if not self.mStartAction or not self.finishNoClear then
		self:CloseGuidePanel()

		self.mSelfCleared = true
	end
end

function C_GFWaitActionBase:CloseGuidePanel()
	return
end

function C_GFWaitActionBase:PrintCurrentRunningState()
	print_notice("GF Debug => CURRENT STATE: ---引导当前执行状态=", self:GetStateName(self.mState), " 节点=", self.mNodeName, " mStartAction=", self.mStartAction, " mFinishAction=", self.mFinishAction, " finishDirectly=", self.finishDirectly, " finishNoClear=", self.finishNoClear, " mSelfCleared=", self.mSelfCleared, " id=", self.mId)
end

return C_GFWaitActionBase
