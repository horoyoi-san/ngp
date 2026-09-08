-- Original chunk: @Lua\LuaFiles\LX6\Manager\Task\WorkActionModule.lua
-- Decompiled from: 00284_WorkActionModule.lua_f3d4a64210c8.luajit

C_WorkActionModule = DefClass("C_WorkActionModule", C_WorkActionModule)
local WorkActionModule = C_WorkActionModule

WorkActionModule.ctor = function(self)
	self.counterValues = {}
end

WorkActionModule.OnInit = function(self)
end

WorkActionModule.RefreshTaskCounterValues = function(self, taskId, taskState)
	if taskState == UX.Game.TaskState.Accepted then
		if self.counterValues[taskId] then
			self.counterValues[taskId] = nil
		end
	else
		if gTaskManager.tasks[taskId] ~= nil then
			self.counterValues[taskId] = nil

			return
		end

		if not self.counterValues[taskId] then
			self.counterValues[taskId] = {}
		end

		if gTaskManager.tasks[taskId] and gTaskManager.tasks[taskId].Counters then
			for i, v in ipairs(gTaskManager.tasks[taskId].CounterValues) do
				self.counterValues[taskId][i] = v
			end
		end
	end
end

return WorkActionModule
