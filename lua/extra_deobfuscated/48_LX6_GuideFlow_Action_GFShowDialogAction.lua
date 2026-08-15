C_GFShowDialogAction = DefClass("C_GFShowDialogAction", C_GFShowDialogAction, C_GFActionBase)
local C_GFShowDialogAction = C_GFShowDialogAction

function C_GFShowDialogAction:ctor(id, isMonitor, params)
	self.mNodeName = "C_GFShowDialogAction"
	self.dialogId = params.dialogId
end

function C_GFShowDialogAction:OnUpdate()
	gDialogManager:ShowGeneralDialog(self.dialogId, gDialogSource.Guide)
	self:FinishNode(true)
end

return C_GFShowDialogAction
