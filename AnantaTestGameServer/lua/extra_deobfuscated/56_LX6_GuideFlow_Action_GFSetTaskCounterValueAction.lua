local MessageConfig = LTConfig.MessageConfig
C_GFSetTaskCounterValueAction = DefClass("C_GFSetTaskCounterValueAction", C_GFSetTaskCounterValueAction, C_GFActionBase)
local C_GFSetTaskCounterValueAction = C_GFSetTaskCounterValueAction

function C_GFSetTaskCounterValueAction:ctor(id, isMonitor, params)
	self.mNodeName = "C_GFSetTaskCounterValueAction"
	self.taskId = params.taskId
	self.counterIndex = params.counterIndex
	self.value = params.value
end

function C_GFSetTaskCounterValueAction:OnUpdate()
	if gTaskManager:IsTaskWorking(self.taskId) then
		gClientToGameDelegate:AskSetTaskCounterValue(self.taskId, self.counterIndex, self.value).Callback = function (err)
			if err ~= MessageConfig.Ok then
				print_warn("AskSetTaskCounterValue Failed! error =", gCS.Error.GetNameById(err))
			end
		end
	end

	self:FinishNode(true)
end

return C_GFSetTaskCounterValueAction
