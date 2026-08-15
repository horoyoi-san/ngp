C_GFClosePanelAction = DefClass("C_GFClosePanelAction", C_GFClosePanelAction, C_GFActionBase)
local C_GFClosePanelAction = C_GFClosePanelAction

function C_GFClosePanelAction:ctor(id, isMonitor, params)
	self.mNodeName = "C_GFClosePanelAction"
	self.panelId = params.panelId
end

function C_GFClosePanelAction:OnUpdate()
	gPanelManager:Close(self.panelId)
	self:FinishNode(true)
end

return C_GFClosePanelAction
