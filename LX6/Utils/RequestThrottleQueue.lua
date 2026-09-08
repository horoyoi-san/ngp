-- Original chunk: @Lua\LuaFiles\LX6\Utils\RequestThrottleQueue.lua
-- Decompiled from: 01260_RequestThrottleQueue.lua_422cbb1f43a5.luajit

local RequestThrottleQueue = {
	__index = RequestThrottleQueue
}

RequestThrottleQueue.new = function(intervalSeconds, requestAction, requestTarget)
	local instance = {
		intervalSeconds = intervalSeconds or 1,
		requestTarget = requestTarget,
		requestAction = requestAction
	}

	setmetatable(instance, RequestThrottleQueue)

	instance.timerCallback = function()
		instance.pendingTimer = nil

		instance:OnPendingTimer()
	end

	return instance
end

RequestThrottleQueue.GetPendingTag = function(self)
	return self.pendingTag
end

RequestThrottleQueue.GetPendingParam = function(self, index)
	return self.pendingArgs and self.pendingArgs[index]
end

RequestThrottleQueue.GetWaitSeconds = function(self)
	return self.lastDispatchTime and math.max(self.lastDispatchTime + self.intervalSeconds - Time.time, 0) or 0
end

RequestThrottleQueue.Request = function(self, requestTag, onCancel, ...)
	local waitSeconds = self.GetWaitSeconds(self)

	if waitSeconds < 0 then
		self.ClearPending(self, true)
		self.DispatchRequest(self, ...)

		return
	end

	self.ClearPending(self, true)

	self.pendingTag = requestTag
	self.pendingArgs = {
		n = select("#", ...),
		...
	}
	self.pendingOnCancel = onCancel

	self.StartPendingTimer(self, waitSeconds)
end

RequestThrottleQueue.StartPendingTimer = function(self, waitSeconds)
	self:StopPendingTimer()

	self.pendingTimer = Timer.New(self.timerCallback, waitSeconds):Start()
end

RequestThrottleQueue.OnPendingTimer = function(self)
	local pendingArgs = self.pendingArgs

	if pendingArgs ~= nil then
		return
	end

	local waitSeconds = self.GetWaitSeconds(self)

	if waitSeconds <= 0 then
		self.StartPendingTimer(self, waitSeconds)

		return
	end

	self.pendingTag = nil
	self.pendingArgs = nil
	self.pendingOnCancel = nil

	self.DispatchRequest(self, unpack(pendingArgs, 1, pendingArgs.n))
end

RequestThrottleQueue.DispatchRequest = function(self, ...)
	self.lastDispatchTime = Time.time

	if self.requestTarget == nil then
		self.requestAction(self.requestTarget, ...)
	else
		self.requestAction(...)
	end
end

RequestThrottleQueue.CancelPending = function(self)
	self.ClearPending(self, true)
end

RequestThrottleQueue.ClearPending = function(self, needNotifyCancel)
	local requestTag = self.pendingTag
	local pendingArgs = self.pendingArgs
	local onCancel = self.pendingOnCancel
	self.pendingTag = nil
	self.pendingArgs = nil
	self.pendingOnCancel = nil

	self.StopPendingTimer(self)

	if needNotifyCancel and pendingArgs == nil and onCancel == nil then
		onCancel(requestTag, unpack(pendingArgs, 1, pendingArgs.n))
	end
end

RequestThrottleQueue.StopPendingTimer = function(self)
	if self.pendingTimer == nil then
		self.pendingTimer:Stop()

		self.pendingTimer = nil
	end
end

RequestThrottleQueue.Dispose = function(self)
	self.CancelPending(self)

	self.requestTarget = nil
	self.requestAction = nil
	self.timerCallback = nil
end

return RequestThrottleQueue
