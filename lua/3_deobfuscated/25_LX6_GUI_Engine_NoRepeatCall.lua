local Time = UnityEngine.Time
CNoRepeatCall = DefClass("CNoRepeatCall", CNoRepeatCall)
local M = CNoRepeatCall

function M:ctor(func, time, failFunc)
	self.func = func
	self.delta = time or self.DEFAULT_CALL_DURATION
	self.lastTime = 0
	self.failFunc = failFunc
end

function M:Call(...)
	local now = Time.realtimeSinceStartup

	if self.delta < now - self.lastTime then
		self.lastTime = now

		self.func(...)
	elseif self.failFunc then
		self.failFunc()
	end
end

CNoRepeatCall = M
