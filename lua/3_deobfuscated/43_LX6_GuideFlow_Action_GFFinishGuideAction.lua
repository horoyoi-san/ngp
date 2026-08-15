C_GFFinishGuideAction = DefClass("C_GFFinishGuideAction", C_GFFinishGuideAction, C_GFActionBase)
local C_GFFinishGuideAction = C_GFFinishGuideAction

function C_GFFinishGuideAction:ctor(id, isMonitor)
	self.mNodeName = "C_GFFinishGuideAction"
end

function C_GFFinishGuideAction:OnUpdate()
	self.mBTree:SetSuccess()
	self:FinishNode(true)
end

return C_GFFinishGuideAction
