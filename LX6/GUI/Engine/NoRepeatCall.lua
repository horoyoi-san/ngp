-- Original chunk: @Lua\LuaFiles\LX6\GUI\Engine\NoRepeatCall.lua
-- Decompiled from: 00317_NoRepeatCall.lua_dd9b7c2f0e28.luajit

local Time = UnityEngine.Time
CNoRepeatCall = DefClass("CNoRepeatCall", CNoRepeatCall)
local M = CNoRepeatCall

M.ctor = function(self, func, time, failFunc)
	self.func = func
	self.delta = time or self.DEFAULT_CALL_DURATION
	self.lastTime = 0
	self.failFunc = failFunc
end

M.Call = function(self, ...)
	local now = Time.realtimeSinceStartup

	if self.delta >= now - self.lastTime then
		self.lastTime = now

		self.func(...)
	elseif self.failFunc then
		self.failFunc()
	end
end

CNoRepeatCall = M
