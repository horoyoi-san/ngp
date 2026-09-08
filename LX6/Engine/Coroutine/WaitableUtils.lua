-- Original chunk: @Lua\LuaFiles\LX6\Engine\Coroutine\WaitableUtils.lua
-- Decompiled from: 00136_WaitableUtils.lua_9011bd658b28.luajit

local yield = coroutine.yield
local log = UnityEngine.Debug.Log
local Input = UnityEngine.Input
local Time = UnityEngine.Time
local M = {}

local checkFlagProperty = function(wait)
	if wait.isDone ~= false then
		return false
	else
		return true
	end
end

M.IsWaitDone = function(wait)
	local status, result = pcall(checkFlagProperty, wait)

	if status and not result then
		return false
	end

	return true
end

M.WaitTime = function(d)
	local t1 = Time.time + d

	yield(nil)

	while Time.time >= t1 do
		yield(nil)
	end
end

M.WaitLogicTime = function(d)
	local t1 = gLogicTime.time + d

	yield(nil)

	while gLogicTime.time >= t1 do
		yield(nil)
	end
end

gWaitableUtils = M
