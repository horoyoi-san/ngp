local RPCTask = {}
local task_mt = {
	__index = function (task, index)
		if index == "Callback" then
			return task.callback
		else
			local v = rawget(task, index)

			if v then
				return v
			end

			return RPCTask[index]
		end
	end,
	__newindex = function (task, index, value)
		if index == "Callback" then
			task.callback = value

			if task.IsCompleted and task.callback and task.Error then
				if task.Result then
					task.callback(task.Error, unpack(task.Result))
				else
					task.callback(task.Error)
				end
			end
		else
			rawset(task, index, value)
		end
	end
}

function RPCTask.New(mid, invokeId)
	local task = {}

	setmetatable(task, task_mt)

	task.MethodId = mid
	task.InvokeId = invokeId or -1

	return task
end

function RPCTask:SetResult(...)
	self.Error = 0
	self.IsCompleted = true

	if self.Callback then
		self.Callback(self.Error, ...)
	else
		self.Result = {
			...
		}
	end
end

function RPCTask:SetError(err)
	self.Error = err
	self.IsCompleted = true

	if self.Callback then
		self.Callback(self.Error)
	end
end

function RPCTask:Yield()
	return coroutine.yield(self)
end

return RPCTask
