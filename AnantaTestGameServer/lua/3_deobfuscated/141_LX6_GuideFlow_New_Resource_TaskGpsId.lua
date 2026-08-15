C_GuideBT_TaskGpsId = DefClass("C_GuideBT_TaskGpsId", C_GuideBT_TaskGpsId, C_GuideBT_ResourceBase)
local M = C_GuideBT_TaskGpsId

function M:Eval()
	self.output.val = self:GetGpsIdByTaskId(self.taskId)
end

function M:GetGpsIdByTaskId(taskId)
	if not gMapSubSystem_Task then
		return ""
	end

	local instanceId = gMapSubSystem_Task:GetGpsInstanceIdByTaskId(taskId)
	local element = gMapSystem.container:Get(instanceId)

	if element then
		return element.gpsId
	else
		return ""
	end
end
