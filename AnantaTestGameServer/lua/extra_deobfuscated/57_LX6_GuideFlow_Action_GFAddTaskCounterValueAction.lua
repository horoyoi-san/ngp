local MessageConfig = LTConfig.MessageConfig
C_GFAddTaskCounterValueAction = DefClass("C_GFAddTaskCounterValueAction", C_GFAddTaskCounterValueAction, C_GFActionBase)
local C_GFAddTaskCounterValueAction = C_GFAddTaskCounterValueAction

function C_GFAddTaskCounterValueAction:ctor(id, isMonitor, params)
	self.mNodeName = "C_GFAddTaskCounterValueAction"
	self.taskId = params.taskId
	self.counterIndex = params.counterIndex
	self.value = params.value
end

function C_GFAddTaskCounterValueAction:OnUpdate()
	if gTaskManager:IsTaskWorking(self.taskId) then
		gClientToGameDelegate:AskChangeTaskCounterValue(self.taskId, self.counterIndex, self.value).Callback = function (err)
			if err ~= MessageConfig.Ok then
				print_warn("AskChangeTaskCounterValue Failed! error =", gCS.Error.GetNameById(err))
			end
		end
	end

	self:FinishNode(true)
end

return C_GFAddTaskCounterValueAction
