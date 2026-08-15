local gGFConstant = require("LX6/GuideFlow/GFConstant")
C_GFSequenceRepeatLast = DefClass("C_GFSequenceRepeatLast", C_GFSequenceRepeatLast, C_GFCompositeBase)
local C_GFSequenceRepeatLast = C_GFSequenceRepeatLast

function C_GFSequenceRepeatLast:ctor(id, isMonitor, params)
	self.mNodeType = gGFConstant.NodeType.Sequence
	self.mRunningChildIndex = 1
	self.mNodeName = "C_GFSequenceRepeatLast"
	self.repeatNum = params.repeatNum
	self.runningChildState = gGFConstant.State.Running
	self.count = 0
	self.needUpdateDebug = false
end

function C_GFSequenceRepeatLast:OnUpdate(manual)
	local childCount = #self.mChilds

	if childCount > 0 and self.count < self.repeatNum then
		self.runningChildState = self.mChilds[self.mRunningChildIndex]:DoUpdateState()

		if self.runningChildState == gGFConstant.State.Success then
			if not manual then
				self.mChilds[self.mRunningChildIndex]:ResetNode()

				self.count = self.count + 1
				self.needUpdateDebug = true

				if self.mRunningChildIndex < childCount then
					self.mRunningChildIndex = self.mRunningChildIndex + 1
				end
			end

			if self.repeatNum <= self.count then
				self:FinishNode(true)
			end
		elseif self.runningChildState == gGFConstant.State.Failure then
			self:FinishNode(false)
		end
	else
		self:FinishNode(true)
	end

	if self.needUpdateDebug then
		self:SendNodeDebugInfo()

		self.needUpdateDebug = false
	end
end

function C_GFSequenceRepeatLast:ManualIncrement(force)
	if force or self.runningChildState == gGFConstant.State.Success then
		self.count = self.count + 1

		if self.repeatNum <= self.count then
			self:FinishNode(true)

			return
		end

		if self.mRunningChildIndex == #self.mChilds then
			self.mChilds[self.mRunningChildIndex]:ResetNode()
		else
			self.mChilds[self.mRunningChildIndex]:SetSuccess()
		end

		if self.mRunningChildIndex < #self.mChilds then
			self.mRunningChildIndex = self.mRunningChildIndex + 1
		end
	else
		self.mChilds[self.mRunningChildIndex]:StopNode()
	end
end

function C_GFSequenceRepeatLast:OnReset()
	for i = 1, self.mRunningChildIndex do
		self.mChilds[i]:ResetNode()
	end

	self.count = 0
	self.mRunningChildIndex = 1
end

function C_GFSequenceRepeatLast:OnDestroy()
	self.mChilds[self.mRunningChildIndex]:DestroyNode()
end

function C_GFSequenceRepeatLast:OnUpdateForce()
	self.mChilds[self.mRunningChildIndex]:OnUpdateForce()
end

function C_GFSequenceRepeatLast:OnStopNode()
	self.mChilds[self.mRunningChildIndex]:StopNode()
end

function C_GFSequenceRepeatLast:OnSetSuccess()
	self.mChilds[self.mRunningChildIndex]:SetSuccess()

	self.count = self.repeatNum
end

function C_GFSequenceRepeatLast:UpdateDebugInfo()
	C_GFSequenceRepeatLast.base.UpdateDebugInfo(self)

	self.mDebugInfo.repeatNum = self.count
end

function C_GFSequenceRepeatLast:PrintCurrentRunningState()
	print_notice("GF Debug => CURRENT STATE: ---引导当前执行状态=", self:GetStateName(self.mState), " 节点=", self.mNodeName, " currentRunningIndex=", self.mRunningChildIndex, " count/repeatNum=", self.count, "/", self.repeatNum, " id=", self.mId)

	for k, v in pairs(self.mChilds) do
		v:PrintCurrentRunningState()
	end
end

return C_GFSequenceRepeatLast
