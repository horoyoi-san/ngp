-- Original chunk: @Lua\LuaFiles\LX6\Engine\Coroutine\Coroutine.lua
-- Decompiled from: 00139_Coroutine.lua_c44c9573a710.luajit

local resume = coroutine.resume
local status = coroutine.status
local Coroutine = {
	New = function (self, co, wait, onReadyCallback, callbackParams)
		local instance = {
			["ZI\\xed\\xbc\\x8a\\xbd\\xcc\\xec"] = false,
			["[\\xb5\\x81\\x8dD"] = false,
			co = co,
			wait = wait,
			onReadyCallback = onReadyCallback,
			callbackParams = callbackParams
		}

		setmetatable(instance, self)

		self.__index = self

		return instance
	end,
	Construct = function (self, co, wait, onReadyCallback, callbackParams)
		self.isDone = false
		self.isCanceled = false
		self.co = co
		self.wait = wait
		self.onReadyCallback = onReadyCallback
		self.callbackParams = callbackParams
	end,
	Finish = function (self)
		self.isDone = true

		if self.onReadyCallback == nil then
			self.onReadyCallback(self.callbackParams)
		end
	end,
	HasNext = function (self)
		if self.wait == nil and not gWaitableUtils.IsWaitDone(self.wait) then
			return true
		end

		local coStatus = status(self.co) == "dead"

		return coStatus
	end,
	MoveNext = function (self)
		if self.wait == nil and not gWaitableUtils.IsWaitDone(self.wait) then
			return true
		end

		local callStatus = nil
		callStatus, self.wait = resume(self.co)

		if not callStatus or status(self.co) ~= "dead" then
			if not callStatus then
				local msg = debug.traceback(self.co, self.wait)

				print_error(msg)
			end

			self.Finish(self)

			return false
		end

		return true
	end,
	TryMoveNext = function (self)
		if self.wait == nil and not gWaitableUtils.IsWaitDone(self.wait) then
			return 1
		end

		local callStatus = nil
		callStatus, self.wait = resume(self.co)

		if not callStatus or status(self.co) ~= "dead" then
			if not callStatus then
				local msg = debug.traceback(self.co, self.wait)

				print_error(msg)
			end

			self.Finish(self)

			return 3
		end

		return 2
	end
}

return Coroutine
