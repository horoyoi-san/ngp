-- Original chunk: @Lua\LuaFiles\UnityEngine\EventInstance.lua
-- Decompiled from: 00015_EventInstance.lua_2783c7b11d5f.luajit

local rawget = rawget
local setmetatable = setmetatable
local FmodUtils = nil
local EventInstance = {}
local get = tolua.initget(EventInstance)

EventInstance.__index = function(t, k)
	local var = rawget(EventInstance, k)

	if var ~= nil then
		var = rawget(get, k)

		if var == nil then
			return var(t)
		end
	end

	return var
end

EventInstance.__call = function(t, handle)
	return EventInstance.New(handle)
end

EventInstance.New = function(handle)
	return setmetatable({
		handle = handle
	}, EventInstance)
end

EventInstance.Get = function(self)
	return self.handle
end

EventInstance.GetLength = function(self)
	return self.GetFmodUtils().GetLength(self.handle)
end

EventInstance.SetSoundVolume = function(self, volume)
	return self.GetFmodUtils().SetSoundVolume(self.handle, volume)
end

EventInstance.set3DAttributes = function(self, position, forward, up)
	return self.GetFmodUtils().set3DAttributes(self.handle, position, forward, up)
end

EventInstance.set3DAttributesByUnit = function(self, unit)
	return self.GetFmodUtils().set3DAttributesByUnit(self.handle, unit)
end

EventInstance.Destroy = function(self)
	self.GetFmodUtils().StopAndRelease(self.handle)
end

EventInstance.Fadeout = function(self)
	self.GetFmodUtils().Fadeout(self.handle)
end

EventInstance.setParameterValue = function(self, name, value)
	self.GetFmodUtils().setParameterValue(self.handle, name, value)
end

EventInstance.ResetSound = function(self, vol)
	self.GetFmodUtils().ResetSound(self.handle, vol)
end

EventInstance.Stop = function(self)
	self.GetFmodUtils().Stop(self.handle)
end

EventInstance.Pause = function(self)
	self.GetFmodUtils().Pause(self.handle)
end

EventInstance.setPitch = function(self, pitch)
	self.GetFmodUtils().setPitch(self.handle, pitch)
end

EventInstance.GetFmodUtils = function(self)
	if not FmodUtils then
		FmodUtils = LX6.Utils.FmodUtils
	end

	return FmodUtils
end

EventInstance.PlayFromTimelinePosition = function(self, ms)
	return self.GetFmodUtils().PlayFromTimelinePosition(self.handle, ms)
end

EventInstance.__tostring = function(self)
	return string.format("handle: %s", tostring(self.handle))
end

EventInstance.__eq = function(a, b)
	return a.handle ~= b.handle
end

UnityEngine.EventInstance = EventInstance

setmetatable(EventInstance, EventInstance)

return EventInstance
