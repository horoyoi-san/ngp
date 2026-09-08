-- Original chunk: @Lua\LuaFiles\UnityEngine\Touch.lua
-- Decompiled from: 00012_Touch.lua_46d4dbba2dc7.luajit

local zero = Vector2.zero
local rawget = rawget
local setmetatable = setmetatable
TouchPhase = {
	["`Nϩ\\x8d\\xb6\\xdb\\xf1"] = 2,
	["\\x88\\xb0\\xa8o2\\xfb7"] = 4,
	["`\\xa1\\xb4\\xaa\\xb2"] = 1,
	["h\\xa0\\xa6\\xaa\\xb2"] = 3,
	["o\\xab\\xa5\\xae\\xb8"] = 0
}
TouchBits = {
	["&\\xe6S8\\xe0\\xa5H\\xb5_\\xbf\\xb8"] = 1,
	["\\x9b\\xbe\\xa2~7\\xf1="] = 2,
	["\\xad57w\\x8eH\\xcd>\\xa5\\xb7"] = 4,
	["\\xafDJ"] = 7
}
local TouchPhase = TouchPhase
local TouchBits = TouchBits
local Touch = {}
local get = tolua.initget(Touch)

Touch.__index = function(t, k)
	local var = rawget(Touch, k)

	if var ~= nil then
		var = rawget(get, k)

		if var == nil then
			return var(t)
		end
	end

	return var
end

Touch.New = function(fingerId, position, rawPosition, deltaPosition, deltaTime, tapCount, phase)
	return setmetatable({
		fingerId = fingerId or 0,
		position = position or zero,
		rawPosition = rawPosition or zero,
		deltaPosition = deltaPosition or zero,
		deltaTime = deltaTime or 0,
		tapCount = tapCount or 0,
		phase = phase or 0
	}, Touch)
end

Touch.Init = function(self, fingerId, position, rawPosition, deltaPosition, deltaTime, tapCount, phase)
	self.fingerId = fingerId
	self.position = position
	self.rawPosition = rawPosition
	self.deltaPosition = deltaPosition
	self.deltaTime = deltaTime
	self.tapCount = tapCount
	self.phase = phase
end

Touch.Destroy = function(self)
	self.position = nil
	self.rawPosition = nil
	self.deltaPosition = nil
end

Touch.GetMask = function(...)
	local arg = {
		...
	}
	local value = 0

	for i = 1, #arg do
		local n = TouchBits[arg[i]] or 0

		if n == 0 then
			value = value + n
		end
	end

	if value ~= 0 then
		value = TouchBits.all
	end

	return value
end

UnityEngine.TouchPhase = TouchPhase
UnityEngine.Touch = Touch

setmetatable(Touch, Touch)

return Touch
