local yield = coroutine.yield
local log = UnityEngine.Debug.Log
local Input = UnityEngine.Input
local Time = UnityEngine.Time
local M = {}

local function checkFlagProperty(wait)
	if wait.isDone == false then
		return false
	else
		return true
	end
end

function M.IsWaitDone(wait)
	local status, result = pcall(checkFlagProperty, wait)

	if status and not result then
		return false
	end

	return true
end

function M.WaitTime(d)
	local t1 = Time.time + d

	yield(nil)

	while Time.time < t1 do
		yield(nil)
	end
end

function M.WaitLogicTime(d)
	local t1 = gLogicTime.time + d

	yield(nil)

	while gLogicTime.time < t1 do
		yield(nil)
	end
end

gWaitableUtils = M
