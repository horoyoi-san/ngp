local MessageConfig = LTConfig.MessageConfig
C_GFChangeTaskCounterValueAction = DefClass("C_GFChangeTaskCounterValueAction", C_GFChangeTaskCounterValueAction, C_GFActionBase)
local C_GFChangeTaskCounterValueAction = C_GFChangeTaskCounterValueAction

function C_GFChangeTaskCounterValueAction:ctor(id, isMonitor, params)
	self.mNodeName = "C_GFChangeTaskCounterValueAction"
	self.taskId = params.taskId
	self.counterIndex = params.counterIndex
	self.value = params.value
end

function C_GFChangeTaskCounterValueAction:OnUpdate()
	if gTaskManager:IsTaskWorking(self.taskId) then
		if gLuaUIMgr.playcontrolReconnectData == nil then
			gLuaUIMgr.playcontrolReconnectData = {
				instanceId = gRaidDataManager.RaidInstanceId
			}
		end

		local index = #gLuaUIMgr.playcontrolReconnectData + 1
		gLuaUIMgr.playcontrolReconnectData[index] = {
			type = 1,
			data = {
				self.taskId,
				self.counterIndex,
				self.value
			}
		}

		gClientToGameDelegate:AskChangeTaskCounterValue(self.taskId, self.counterIndex, self.value).Callback = function (err)
			if err ~= MessageConfig.Ok then
				print_warn("AskChangeTaskCounterValue Failed! error =", gCS.Error.GetNameById(err))
			elseif gLuaUIMgr.playcontrolReconnectData and index <= #gLuaUIMgr.playcontrolReconnectData then
				table.remove(gLuaUIMgr.playcontrolReconnectData, index)
			end
		end
	end

	self:FinishNode(true)
end

return C_GFChangeTaskCounterValueAction
