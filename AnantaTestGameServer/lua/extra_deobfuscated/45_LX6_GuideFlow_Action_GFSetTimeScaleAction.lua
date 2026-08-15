C_GFSetTimeScaleAction = DefClass("C_GFSetTimeScaleAction", C_GFSetTimeScaleAction, C_GFActionBase)
local C_GFSetTimeScaleAction = C_GFSetTimeScaleAction

function C_GFSetTimeScaleAction:ctor(id, isMonitor, params)
	self.mNodeName = "C_GFSetTimeScaleAction"
	self.timeScale = params.timeScale
end

function C_GFSetTimeScaleAction:OnUpdate()
	Time.timeScale = self.timeScale

	self:FinishNode(true)
end

return C_GFSetTimeScaleAction
