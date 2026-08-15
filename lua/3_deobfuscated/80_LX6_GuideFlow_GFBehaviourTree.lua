local gGFConstant = require("LX6/GuideFlow/GFConstant")
C_GFBehaviourTree = DefClass("C_GFBehaviourTree", C_GFBehaviourTree)
local C_GFBehaviourTree = C_GFBehaviourTree

function C_GFBehaviourTree:ctor(guideId, counterId, desc)
	self.mRootNode = nil
	self.mActivatedFreeClickIdToMaskParam = {}
	self.mNodeName = "C_GFBehaviourTree"
	self.mGuideId = guideId
	self.mCounterId = counterId
	self.mDescribe = desc
end

function C_GFBehaviourTree:GetState()
	return self.mRootNode and self.mRootNode.mState or gGFConstant.State.Success
end

function C_GFBehaviourTree:SetNode(node)
	self.mRootNode = node
end

function C_GFBehaviourTree:ResetNode()
	self.mRootNode = nil
end

function C_GFBehaviourTree:DoUpdateState()
	self.mRootNode:OnUpdateForce()

	return self.mRootNode:DoUpdateState()
end

function C_GFBehaviourTree:Reset()
	self.mRootNode:ResetNode()
end

function C_GFBehaviourTree:StopNode()
	self.mRootNode:StopNode()
end

function C_GFBehaviourTree:Destroy()
	self.mRootNode:DestroyNode()
end

function C_GFBehaviourTree:GetId()
	return self.mGuideId or "Unknown Id"
end

function C_GFBehaviourTree:GetCounter()
	return self.mCounterId
end

function C_GFBehaviourTree:GetDesc()
	return self.mDescribe or "No Desc"
end

function C_GFBehaviourTree:SetTree()
	self.mRootNode:SetTree(self)
end

function C_GFBehaviourTree:SetSuccess()
	self.mRootNode:SetSuccess()
end

function C_GFBehaviourTree:RefreshDebugInfo()
	self.mRootNode:RefreshDebugInfo()
end

function C_GFBehaviourTree:PrintCurrentRunningState()
	self.mRootNode:PrintCurrentRunningState()
end

return C_GFBehaviourTree
