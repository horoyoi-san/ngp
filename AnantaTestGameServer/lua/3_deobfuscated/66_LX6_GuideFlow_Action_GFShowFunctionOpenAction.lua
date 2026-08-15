C_GFShowFunctionOpenAction = DefClass("C_GFShowFunctionOpenAction", C_GFShowFunctionOpenAction, C_GFActionBase)
local C_GFShowFunctionOpenAction = C_GFShowFunctionOpenAction

function C_GFShowFunctionOpenAction:ctor(id, isMonitor, params)
	self.mNodeName = "C_GFShowFunctionOpenAction"
	self.openName = params.openName
end

function C_GFShowFunctionOpenAction:OnUpdate()
	self:FinishNode(true)
end

return C_GFShowFunctionOpenAction
