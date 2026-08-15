local gGFConstant = require("LX6/GuideFlow/GFConstant")
local StateNameDict = {
	[gGFConstant.State.Ready] = "Ready",
	[gGFConstant.State.Running] = "Running",
	[gGFConstant.State.Success] = "Success",
	[gGFConstant.State.Failure] = "Failure"
}
C_GFNodeBase = DefClass("C_GFNodeBase", C_GFNodeBase)
local M = C_GFNodeBase

function M:ctor(id, isMonitor)
	self.mState = gGFConstant.State.Ready
	self.mNodeType = -1
	self.mStarted = false
	self.mStartTime = 0
	self.mFinishTime = 0
	self.mNodeName = "C_GFNodeBase"
	self.mId = id
	self.mMonitor = isMonitor
	self.mBTree = nil
	self.mSelfFinished = false
	self.mDebugInfo = {
		Id = id
	}
end

function M:GetType()
	return self.mNodeType
end

function M:SetTree(tree)
	self.mBTree = tree
end

function M:GetState()
	return self.mState
end

function M:GetNodeName()
	return self.mNodeName
end

function M:GetId()
	return self.mId
end

function M:OnStart()
	return
end

function M:OnUpdate()
	self:FinishNode(true)
end

function M:OnFinish(isSuccess)
	return
end

function M:OnReset()
	return
end

function M:OnSetSuccess()
	return
end

function M:OnUpdateForce()
	return
end

function M:OnStopNode()
	return
end

function M:OnDestroy()
	return
end

function M:OnUpdateDebugInfo()
	return
end

function M:DoUpdateState(manual)
	self:StartNode(manual)
	self:UpdateNode(manual)

	return self.mState
end

function M:StartNode(manual)
	if self.mState == gGFConstant.State.Ready then
		if gGFManager.Debug then
			print_debug("GF Debug => NodeName=", self.mNodeName, " id=", self.mId, " => StartNode", " State=", self.mState, " frame=", Time.frameCount)
		end

		self.mState = gGFConstant.State.Running
		self.mStartTime = Time.time
		self.mStarted = true

		self:OnStart()
		self:SendNodeDebugInfo()
	end
end

function M:UpdateNode(manual)
	if self.mState == gGFConstant.State.Running then
		self:OnUpdate(manual)
	end
end

function M:FinishNode(isSuccess)
	if self.mState == gGFConstant.State.Running then
		self.mState = isSuccess and gGFConstant.State.Success or gGFConstant.State.Failure
		self.mFinishTime = Time.time
		self.mStarted = false

		self:OnFinish(isSuccess)
		self:SendNodeDebugInfo()

		if gGFManager.Debug then
			print_debug("GF Debug => NodeName=", self.mNodeName, " id=", self.mId, " => FinishNode Done, isSuccess=", isSuccess, " State=", self.mState, " frame=", Time.frameCount)
		end
	end
end

function M:SetSuccess()
	if gGFManager.Debug then
		print_debug("GF Debug => NodeName=", self.mNodeName, " id=", self.mId, " => SetSuccess, frame=", Time.frameCount)
	end

	self:FinishNode(true)
	self:StopNode()
	self:OnSetSuccess()
end

function M:ResetNode()
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
	self:SendNodeDebugInfo()
end

function M:StopNode()
	self:OnStopNode()
end

function M:DestroyNode()
	if gGFManager.Debug then
		print_debug("GF Debug => NodeName=", self.mNodeName, " id=", self.mId, " => DestroyNode, frame=", Time.frameCount)
	end

	self:StopNode()
	self:OnDestroy()

	self.mState = gGFConstant.State.Ready

	self:SendNodeDebugInfo()
end

function M:SendNodeDebugInfo()
	if gGFManager.Debug then
		print_notice("GF Debug => NodeDebugInfo：节点=", self.mNodeName, " 当前执行状态=", self:GetStateName(self.mState), " id=", self.mId, " frame=", Time.frameCount, " time=", Time.time)
		self:UpdateDebugInfo()

		if self.mDebugInfo then
			gMessageManager:SendMessage(gEventConstants.ON_GF_DEBUG_INFO_CHANGE, self.mDebugInfo)
		end
	end
end

function M:UpdateDebugInfo()
	self.mDebugInfo.State = self.mState
	self.mDebugInfo.Started = self.mStarted

	self:OnUpdateDebugInfo()
end

function M:RefreshDebugInfo()
	self:SendNodeDebugInfo()
end

function M:PrintCurrentRunningState()
	print_notice("GF Debug => CURRENT STATE: ---引导当前执行状态=", self:GetStateName(self.mState), " 节点=", self.mNodeName, " id=", self.mId)
end

function M:GetStateName(state)
	return StateNameDict[state] or state
end
