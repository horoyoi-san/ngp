C_GFShowDialogUntilSuccessAction = DefClass("C_GFShowDialogUntilSuccessAction", C_GFShowDialogUntilSuccessAction, C_GFActionBase)
local C_GFShowDialogUntilSuccessAction = C_GFShowDialogUntilSuccessAction

function C_GFShowDialogUntilSuccessAction:ctor(id, isMonitor, params)
	self.mNodeName = "C_GFShowDialogUntilSuccessAction"
	self.dialogId = params.dialogId
end

function C_GFShowDialogUntilSuccessAction:OnUpdate()
	if gDialogManager.isPlayingDialog then
		return
	end

	gDialogManager:ShowGeneralDialog(self.dialogId, gDialogSource.Guide)
	self:FinishNode(true)
end

return C_GFShowDialogUntilSuccessAction
