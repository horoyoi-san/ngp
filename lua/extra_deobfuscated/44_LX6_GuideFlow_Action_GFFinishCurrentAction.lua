C_GFFinishCurrentAction = DefClass("C_GFFinishCurrentAction", C_GFFinishCurrentAction, C_GFActionBase)
local C_GFFinishCurrentAction = C_GFFinishCurrentAction

function C_GFFinishCurrentAction:ctor(id, isMonitor)
	self.mNodeName = "C_GFFinishCurrentAction"
end

function C_GFFinishCurrentAction:OnUpdate()
	self:FinishNode(true)
end

return C_GFFinishCurrentAction
