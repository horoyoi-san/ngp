C_WorkActionModule = DefClass("C_WorkActionModule", C_WorkActionModule)
local WorkActionModule = C_WorkActionModule

function WorkActionModule:ctor()
	self.counterValues = {}
	self.configCounterValues = {}
end

function WorkActionModule:OnInit()
	return
end

function WorkActionModule:RefreshTaskCounterValues(taskId, taskState)
	if taskState == UX.Game.TaskState.Aborted or taskState == UX.Game.TaskState.Submited then
		if self.counterValues[taskId] then
			self.counterValues[taskId] = nil
		end

		if self.configCounterValues[taskId] then
			self.configCounterValues[taskId] = nil
		end
	else
		if gTaskManager.tasks[taskId] == nil then
			self.counterValues[taskId] = nil
			self.configCounterValues[taskId] = nil

			return
		end

		if not self.counterValues[taskId] then
			self.counterValues[taskId] = {}
		end

		if not self.configCounterValues[taskId] then
			self.configCounterValues[taskId] = {}
		end

		if gTaskManager.tasks[taskId] and gTaskManager.tasks[taskId].Counters then
			if #self.counterValues[taskId] == 0 then
				for i, v in ipairs(gTaskManager.tasks[taskId].CounterValues) do
					table.insert(self.counterValues[taskId], v)
				end

				if gTaskManager.tasks[taskId].config and gTaskManager.tasks[taskId].config.WorkAction then
					for i, v in ipairs(gTaskManager.tasks[taskId].config.WorkAction) do
						table.insert(self.configCounterValues[taskId], v.CounterValue)
					end
				end
			else
				for i, v in ipairs(gTaskManager.tasks[taskId].CounterValues) do
					self.counterValues[taskId][i] = v
				end

				for i, v in ipairs(gTaskManager.tasks[taskId].config.WorkAction) do
					self.configCounterValues[taskId][i] = v.CounterValue
				end
			end
		end
	end
end

return WorkActionModule
