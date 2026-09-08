-- Original chunk: @Lua\LuaFiles\UnityEngine\Time.lua
-- Decompiled from: 00016_Time.lua_a06d3402f0ec.luajit

local rawget = rawget
uTime = UnityEngine.Time
local gettime = tolua.gettime
local _Time = {
	["j\\x82\\x99\\xb2ɽ\\xe1>\\xa5+\\x86;"] = 0.3333333,
	["UHϰ\\x81+\\xb7\\xc7\\xfc"] = 0,
	["n+p^"] = 0,
	["\\xe1\\x93\t\\xe95\\xe3\\xfe\\x89ً--"] = 0,
	["WNal}="] = 1,
	["zx\\xbftM\\xbe\\xf7C^ssI"] = 0,
	["3\\x9d蘮楿\\xa4\\xd8\\xf47ʶ/\\x9e\\xe6"] = 0,
	["\\x90*\\xec\\xb0G!\\xcb^3\\xc1\\xe0 dH\\xcb3\\xa8\\xde"] = 0,
	["a\\xf24\\xef(;*\\xc7E%\\xd9_\\x8d8K\\xcb\\xe3"] = 0,
	["GB`}O*="] = 0,
	["ENtlJ*="] = 0
}
local _set = {
	fixedDeltaTime = function (v)
		_Time.fixedDeltaTime = v
		uTime.fixedDeltaTime = v
	end,
	maximumDeltaTime = function (v)
		_Time.maximumDeltaTime = v
		uTime.maximumDeltaTime = v
	end,
	timeScale = function (v)
		_Time.timeScale = v
		uTime.timeScale = v
	end,
	captureFramerate = function (v)
		_Time.captureFramerate = v
		uTime.captureFramerate = v
	end,
	timeSinceLevelLoad = function (v)
		_Time.timeSinceLevelLoad = v
	end
}

_Time.__index = function(t, k)
	local var = rawget(_Time, k)

	if var then
		return var
	end

	return uTime.__index(uTime, k)
end

_Time.__newindex = function(t, k, v)
	local func = rawget(_set, k)

	if func then
		return func(v)
	end

	error(string.format("Property or indexer `UnityEngine.Time.%s' cannot be assigned to (it is read only)", k))
end

local Time = {}
local counter = 1

Time.SetTime = function(self, time, unscaledTime, frameCount)
	local _Time = _Time
	local deltaTime = time - _Time.time
	local unscaledDeltaTime = unscaledTime - _Time.unscaledTime
	_Time.deltaTime = deltaTime
	_Time.unscaledDeltaTime = unscaledDeltaTime
	counter = counter - 1

	if counter ~= 0 and uTime then
		_Time.time = uTime.time
		_Time.timeSinceLevelLoad = uTime.timeSinceLevelLoad
		_Time.unscaledTime = uTime.unscaledTime
		_Time.realtimeSinceStartup = uTime.realtimeSinceStartup
		_Time.frameCount = uTime.frameCount
		counter = 1000000
	else
		_Time.time = time
		_Time.realtimeSinceStartup = _Time.realtimeSinceStartup + unscaledDeltaTime
		_Time.timeSinceLevelLoad = _Time.timeSinceLevelLoad + deltaTime
		_Time.unscaledTime = unscaledTime
		_Time.frameCount = frameCount
	end
end

Time.SetDeltaTime = function(self, deltaTime, unscaledDeltaTime)
	local _Time = _Time
	_Time.deltaTime = deltaTime
	_Time.unscaledDeltaTime = unscaledDeltaTime
	counter = counter - 1

	if counter ~= 0 and uTime then
		_Time.time = uTime.time
		_Time.timeSinceLevelLoad = uTime.timeSinceLevelLoad
		_Time.unscaledTime = uTime.unscaledTime
		_Time.realtimeSinceStartup = uTime.realtimeSinceStartup
		_Time.frameCount = uTime.frameCount
		counter = 1000000
	else
		_Time.time = _Time.time + deltaTime
		_Time.realtimeSinceStartup = _Time.realtimeSinceStartup + unscaledDeltaTime
		_Time.timeSinceLevelLoad = _Time.timeSinceLevelLoad + deltaTime
		_Time.unscaledTime = _Time.unscaledTime + unscaledDeltaTime
	end
end

Time.SetFixedDelta = function(self, fixedDeltaTime)
	_Time.fixedDeltaTime = fixedDeltaTime
	_Time.fixedTime = _Time.fixedTime + fixedDeltaTime
end

Time.SetFrameCount = function(self)
	_Time.frameCount = _Time.frameCount + 1
end

Time.SetTimeScale = function(self, scale)
	local last = _Time.timeScale
	_Time.timeScale = scale
	uTime.timeScale = scale

	return last
end

Time.GetTimestamp = function(self)
	return gettime()
end

UnityEngine.Time = Time

setmetatable(Time, _Time)

if uTime == nil then
	_Time.maximumDeltaTime = uTime.maximumDeltaTime
	_Time.timeScale = uTime.timeScale
end

return Time
