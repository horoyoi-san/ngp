local Define = require("LX6/Service/RPCCommonDefine")

require("Core/Timer")

local TimerPool = {}
local TimerPoolMaxCount = 10

local function GetTimer()
	local count = #TimerPool

	for i = 1, count do
		local t = TimerPool[i]

		if not t.running then
			return t
		end
	end

	return nil
end

local idx = 0

local function StartTimer(func)
	local timer = GetTimer()
	idx = idx + 1

	if timer then
		timer:Reset(func, 5)
	else
		timer = Timer.New(func, 5)
		local count = #TimerPool

		if count < TimerPoolMaxCount then
			TimerPool[count + 1] = timer
		end
	end

	timer:Start()
end

local Q = {
	__index = Q,
	New = function (self, o)
		o = o or {}

		setmetatable(o, self)

		o.tasks = {}

		return o
	end,
	EnqueueResult = function (self, task)
		self.tasks[task.InvokeId] = task

		StartTimer(function ()
			local queuedTask = self:RemoveResult(task.InvokeId)

			if not queuedTask then
				return
			end

			queuedTask:SetError(Define.UXRPCTaskError.TimeOut)
			print_warn("Ontimeout mid=" .. task.MethodId .. " invokeId=" .. task.InvokeId)
		end)
	end,
	RemoveResult = function (self, invokeId)
		local r = self.tasks[invokeId]

		if r then
			-- Nothing
		end

		self.tasks[invokeId] = nil

		return r
	end,
	Clear = function (self)
		for id, task in pairs(self.tasks) do
			task:SetError(Define.UXRPCTaskError.Disconnect)
		end

		self.tasks = {}
	end
}
local queues = {}

return function (sender)
	local q = queues[sender]

	if not q then
		q = Q:New()
		queues[sender] = q
	end

	return q
end
