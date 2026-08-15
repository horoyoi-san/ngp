local gGFConstant = require("LX6/GuideFlow/GFConstant")
C_GFSequence = DefClass("C_GFSequence", C_GFSequence, C_GFCompositeBase)
local C_GFSequence = C_GFSequence

function C_GFSequence:ctor(id, isMonitor)
	self.mRunningChildIndex = 1
	self.mNodeType = gGFConstant.NodeType.Sequence
	self.runningChildState = gGFConstant.State.Running
	self.mNodeName = "C_GFSequence"
end

function C_GFSequence:OnUpdate(manual)
	local childCount = #self.mChilds

	if childCount > 0 then
		if childCount < self.mRunningChildIndex then
			self:FinishNode(true)
		else
			self.runningChildState = self.mChilds[self.mRunningChildIndex]:DoUpdateState()

			if self.runningChildState == gGFConstant.State.Success then
				if self.mRunningChildIndex < childCount then
					if not manual then
						self.mRunningChildIndex = self.mRunningChildIndex + 1
					end
				else
					self:FinishNode(true)
				end
			elseif self.runningChildState == gGFConstant.State.Failure then
				self:FinishNode(false)
			end
		end
	else
		self:FinishNode(true)
	end
end

function C_GFSequence:OnReset()
	for i = 1, self.mRunningChildIndex do
		self.mChilds[i]:ResetNode()
	end

	self.mRunningChildIndex = 1
end

function C_GFSequence:OnStopNode()
	self.mChilds[self.mRunningChildIndex]:StopNode()
end

function C_GFSequence:OnSetSuccess()
	self.mChilds[self.mRunningChildIndex]:SetSuccess()

	self.mRunningChildIndex = #self.mChilds + 1
end

function C_GFSequence:OnDestroy()
	self.mChilds[self.mRunningChildIndex]:DestroyNode()
end

function C_GFSequence:OnUpdateForce()
	self.mChilds[self.mRunningChildIndex]:OnUpdateForce()
end

function C_GFSequence:ManualIncrement(force)
	if force or self.runningChildState == gGFConstant.State.Success then
		if self.mRunningChildIndex < #self.mChilds then
			self.mChilds[self.mRunningChildIndex]:SetSuccess()

			self.mRunningChildIndex = self.mRunningChildIndex + 1
		else
			self:FinishNode(true)
		end
	else
		self.mChilds[self.mRunningChildIndex]:StopNode()
	end
end

function C_GFSequence:PrintCurrentRunningState()
	print_notice("GF Debug => CURRENT STATE: ---引导当前执行状态=", self:GetStateName(self.mState), " 节点=", self.mNodeName, " currentRunningIndex=", self.mRunningChildIndex, " id=", self.mId)

	for k, v in pairs(self.mChilds) do
		v:PrintCurrentRunningState()
	end
end

return C_GFSequence
