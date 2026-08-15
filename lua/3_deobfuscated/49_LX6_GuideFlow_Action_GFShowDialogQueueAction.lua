C_GFShowDialogQueueAction = DefClass("C_GFShowDialogQueueAction", C_GFShowDialogQueueAction, C_GFActionBase)
local C_GFShowDialogQueueAction = C_GFShowDialogQueueAction

function C_GFShowDialogQueueAction:ctor(id, isMonitor, params)
	self.mNodeName = "C_GFShowDialogQueueAction"
	self.dialogs = type(params.dialogs) == "table" and #params.dialogs > 0 and params.dialogs
	self.isShow = false
	self.curShowDialogIndex = 1
end

function C_GFShowDialogQueueAction:OnStart()
	self.isShow = false
end

function C_GFShowDialogQueueAction:OnUpdate()
	if self.dialogs then
		if not self.isShow then
			self.isShow = true

			if not gDialogManager.isPlayingDialog then
				gDialogManager:ShowGeneralDialog(self.dialogs[self.curShowDialogIndex], gDialogSource.Guide)

				self.curShowDialogIndex = self.curShowDialogIndex + 1

				if self.curShowDialogIndex > #self.dialogs then
					self:FinishNode(true)
				end
			end
		end
	else
		self:FinishNode(true)
	end
end

function C_GFShowDialogQueueAction:OnStopNode()
	self.isShow = false
end

function C_GFShowDialogQueueAction:OnReset()
	self.isShow = false
	self.curShowDialogIndex = 1
end

function C_GFShowDialogQueueAction:OnSetSuccess()
	self.isShow = true
end

return C_GFShowDialogQueueAction
