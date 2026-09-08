-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\TaskGpsId.lua
-- Decompiled from: 00501_TaskGpsId.lua_5849c0e6fddf.luajit

C_GuideBT_TaskGpsId = DefClass("C_GuideBT_TaskGpsId", C_GuideBT_TaskGpsId, C_GuideBT_ResourceBase)
local M = C_GuideBT_TaskGpsId

M.Eval = function(self)
	self.output.val = self.GetGpsIdByTaskId(self, self.taskId)
end

M.GetGpsIdByTaskId = function(self, taskId)
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
