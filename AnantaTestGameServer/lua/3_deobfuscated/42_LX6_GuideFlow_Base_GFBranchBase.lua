local gGFConstant = require("LX6/GuideFlow/GFConstant")
C_GFBranchBase = DefClass("C_GFBranchBase", C_GFBranchBase, C_GFNodeBase)
local C_GFBranchBase = C_GFBranchBase

function C_GFBranchBase:ctor(id, isMonitor, params)
	self.mNodeType = gGFConstant.NodeType.Branch
	self.switchType = params.switchType
	self.reverseCondition = params.reverseCondition or false
	self.mChildTrue = nil
	self.mChildFalse = nil
	self.mNodeName = "C_GFBranchBase"
	self.preCondition = nil
end

function C_GFBranchBase:AddChild(node)
	if self:HasNode(node) then
		print_error("C_GFBranchBase:AddChild(): node ", node:GetNodeName(), node:GetId(), "has exist.")

		return
	end

	if self.mChildTrue == nil then
		self.mChildTrue = node

		return
	end

	if self.mChildFalse == nil then
		self.mChildFalse = node

		return
	end

	print_error("C_GFBranchBase:AddChild(): error, trueNode and falseNode are all already set. To add node is ", node:GetNodeName(), node:GetId())
end

function C_GFBranchBase:ResetChild()
	self.mChildTrue = nil
	self.mChildFalse = nil
end

function C_GFBranchBase:SetTree(tree)
	self.mBTree = tree

	if self.mChildTrue then
		self.mChildTrue:SetTree(tree)
	end

	if self.mChildFalse then
		self.mChildFalse:SetTree(tree)
	end
end

function C_GFBranchBase:HasNode(node)
	if self.mChildTrue == node or self.mChildFalse == node then
		return true
	end

	return false
end

function C_GFBranchBase:CheckCondition()
	return true
end

function C_GFBranchBase:OnUpdate()
	local currentCondition = not self:CheckCondition() ~= not self.reverseCondition
	local conditionChange = self.preCondition ~= nil and currentCondition ~= self.preCondition
	self.preCondition = currentCondition
	local curChild, invChild = nil

	if currentCondition then
		curChild = self.mChildTrue
		invChild = self.mChildFalse
	else
		curChild = self.mChildFalse
		invChild = self.mChildTrue
	end

	if conditionChange and invChild then
		if self.switchType == gGFConstant.BranchSwitchType.Stop then
			invChild:StopNode()
		elseif self.switchType == gGFConstant.BranchSwitchType.Reset then
			invChild:ResetNode()
		else
			invChild:FinishNode(true)
		end
	end

	if curChild then
		local state = curChild:DoUpdateState()

		if state == gGFConstant.State.Success then
			self:FinishNode(true)
		elseif state == gGFConstant.State.Failure then
			self:FinishNode(false)
		else
			self.mState = state
		end
	else
		self:FinishNode(true)
	end
end

function C_GFBranchBase:SetSuccess()
	self:FinishNode(true)
	self:StopNode()
	self:OnSetSuccess()

	if self.preCondition and self.mChildTrue then
		self.mChildTrue:SetSuccess()
	end

	if not self.preCondition and self.mChildFalse then
		self.mChildFalse:SetSuccess()
	end
end

function C_GFBranchBase:ResetNode()
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

	if self.mChildTrue then
		self.mChildTrue:ResetNode()
	end

	if self.mChildFalse then
		self.mChildFalse:ResetNode()
	end
end

function C_GFBranchBase:StopNode()
	self:OnStopNode()

	if self.preCondition and self.mChildTrue then
		self.mChildTrue:StopNode()
	end

	if not self.preCondition and self.mChildFalse then
		self.mChildFalse:StopNode()
	end
end

function C_GFBranchBase:DestroyNode()
	self:StopNode()
	self:OnDestroy()

	if self.mChildTrue then
		self.mChildTrue:DestroyNode()
	end

	if self.mChildFalse then
		self.mChildFalse:DestroyNode()
	end

	self.mState = gGFConstant.State.Ready

	self:SendNodeDebugInfo()
end

function C_GFBranchBase:OnUpdateForce()
	if self.preCondition and self.mChildTrue then
		self.mChildTrue:OnUpdateForce()
	end

	if not self.preCondition and self.mChildFalse then
		self.mChildFalse:OnUpdateForce()
	end
end

function C_GFBranchBase:RefreshDebugInfo()
	C_GFBranchBase.base.RefreshDebugInfo(self)

	if self.mChildTrue then
		self.mChildTrue:RefreshDebugInfo()
	end

	if self.mChildFalse then
		self.mChildFalse:RefreshDebugInfo()
	end
end

function C_GFBranchBase:PrintCurrentRunningState()
	C_GFBranchBase.base.PrintCurrentRunningState(self)

	if self.mChildTrue then
		self.mChildTrue:PrintCurrentRunningState()
	end

	if self.mChildFalse then
		self.mChildFalse:PrintCurrentRunningState()
	end
end

return C_GFBranchBase
