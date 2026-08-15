local MessageConfig = LTConfig.MessageConfig
C_GFFinishTaskCounterAction = DefClass("C_GFFinishTaskCounterAction", C_GFFinishTaskCounterAction, C_GFActionBase)
local C_GFFinishTaskCounterAction = C_GFFinishTaskCounterAction

function C_GFFinishTaskCounterAction:ctor(id, isMonitor, params)
	self.mNodeName = "C_GFFinishTaskCounterAction"
	self.taskId = params.taskId
end

function C_GFFinishTaskCounterAction:OnUpdate()
	local cfg = gTaskManager:GetTaskConfigInfo(self.taskId)

	if cfg == nil then
		print_error("找不到对应配表 taskId=", self.taskId)
		self:FinishNode(false)
	else
		for i = 1, #cfg.Counter do
			self:ChangeTaskCounterValue(self.taskId, i - 1, cfg.Counter[i])
		end

		self:FinishNode(true)
	end
end

function C_GFFinishTaskCounterAction:ChangeTaskCounterValue(taskId, counterIndex, value)
	if not gTaskManager:IsTaskWorking(taskId) then
		return
	end

	if gLuaUIMgr.playcontrolReconnectData == nil then
		gLuaUIMgr.playcontrolReconnectData = {
			instanceId = gRaidDataManager.RaidInstanceId
		}
	end

	local index = #gLuaUIMgr.playcontrolReconnectData + 1
	gLuaUIMgr.playcontrolReconnectData[index] = {
		type = 1,
		data = {
			taskId,
			counterIndex,
			value
		}
	}

	gClientToGameDelegate:AskChangeTaskCounterValue(taskId, counterIndex, value).Callback = function (err)
		if err ~= MessageConfig.Ok then
			print_warn("AskChangeTaskCounterValue Failed! error =", gCS.Error.GetNameById(err))
		elseif gLuaUIMgr.playcontrolReconnectData and index <= #gLuaUIMgr.playcontrolReconnectData then
			table.remove(gLuaUIMgr.playcontrolReconnectData, index)
		end
	end
end

return C_GFFinishTaskCounterAction
