local gGFConstant = require("LX6/GuideFlow/GFConstant")
C_GFDecoratorBase = DefClass("C_GFDecoratorBase", C_GFDecoratorBase, C_GFNodeBase)
local C_GFDecoratorBase = C_GFDecoratorBase

function C_GFDecoratorBase:ctor(id, isMonitor)
	self.mNodeType = gGFConstant.NodeType.Decorator
	self.mChild = nil
	self.mNodeName = "C_GFDecoratorBase"
end

function C_GFDecoratorBase:SetChild(child)
	self.mChild = child
end

function C_GFDecoratorBase:ResetChild()
	self.mChild = nil
end

function C_GFDecoratorBase:SetTree(tree)
	self.mBTree = tree

	if self.mChild then
		self.mChild:SetTree(tree)
	end
end

function C_GFDecoratorBase:OnUpdate()
	if self.mChild then
		local state = self.mChild:DoUpdateState()

		if state == gGFConstant.State.Success then
			self:FinishNode(true)
		elseif state == gGFConstant.State.Failure then
			self:FinishNode(false)
		else
			self.mState = state
		end
	end
end

function C_GFDecoratorBase:SetSuccess()
	self:FinishNode(true)
	self:StopNode()
	self:OnSetSuccess()

	if self.mChild then
		self.mChild:SetSuccess()
	end
end

function C_GFDecoratorBase:ResetNode()
	if gGFManager.Debug then
		print_debug("GF Debug => " .. self.mNodeName .. " " .. self.mId .. " => Reset " .. Time.frameCount)
	end

	if self.mStarted then
		self.mFinishTime = Time.time
		self.mStarted = false
	end

	self:StopNode()

	self.mState = gGFConstant.State.Ready

	self:OnReset()
	self:SendNodeDebugInfo()

	if self.mChild then
		self.mChild:ResetNode()
	end
end

function C_GFDecoratorBase:StopNode()
	self:OnStopNode()

	if self.mChild then
		self.mChild:StopNode()
	end
end

function C_GFDecoratorBase:DestroyNode()
	self:StopNode()
	self:OnDestroy()

	if self.mChild then
		self.mChild:DestroyNode()
	end

	self.mState = gGFConstant.State.Ready

	self:SendNodeDebugInfo()
end

function C_GFDecoratorBase:OnUpdateForce()
	if self.mChild then
		self.mChild:OnUpdateForce()
	end
end

function C_GFDecoratorBase:RefreshDebugInfo()
	C_GFDecoratorBase.base.RefreshDebugInfo(self)

	if self.mChild then
		self.mChild:RefreshDebugInfo()
	end
end

function C_GFDecoratorBase:PrintCurrentRunningState()
	C_GFDecoratorBase.base.PrintCurrentRunningState(self)

	if self.mChild then
		self.mChild:PrintCurrentRunningState()
	end
end

return C_GFDecoratorBase
