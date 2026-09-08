-- Original chunk: @Lua\LuaFiles\LX6\Sound\LuaSoundData.lua
-- Decompiled from: 00226_LuaSoundData.lua_996b8a16d22f.luajit

local setmetatable = setmetatable
local LuaSoundData = {}
local this = LuaSoundData
local rawget = rawget
local rawset = rawset

this.__index = function(obj, key)
	local value = rawget(obj, key)

	if value then
		return value
	end

	value = this[key]

	return value
end

this.__newindex = function(obj, key, val)
	rawset(obj, key, val)
end

local _new = this.New

this.__call = function()
	return _new()
end

this.New = function()
	local table = {}
	local v = setmetatable(table, this)

	v.ResetData(v)

	return v
end

this.ResetData = function(self)
	self.NodeId = 0
	self.Sid = 0
	self.UUId = 0
	self.templateId = 0
	self.externalSource = nil
	self.externalId = nil
	self.externalType = 0
	self.isDestroy = false
	self.soundEvt = nil
	self.position = Vector3.zero
	self.eulerAngles = Vector3.zero
	self.followGo = nil
	self.isSyncSender = false
	self.isSyncPosUpdate = false
end

this.IsValid = function(self)
	return not self.isDestroy
end

this.StopSoundEvt = function(self)
	if self.soundEvt then
		self.soundEvt:Stop()

		self.soundEvt = nil
	end
end

this.Stop = function(self)
	if self.soundEvt then
		self.soundEvt:Stop()
	end
end

this.Pause = function(self, fadeTime, fadeCurve)
	fadeTime = fadeTime or -1
	fadeCurve = fadeCurve or -1

	if self.soundEvt then
		self.soundEvt:Pause(fadeTime, fadeCurve)
	end
end

this.SeekToPersent = function(self, persent)
	if self.soundEvt then
		self.soundEvt:SeekToPersent(persent)
	end
end

this.SeekToTime = function(self, time)
	if self.soundEvt then
		self.soundEvt:SeekToTime(time)
	end
end

this.GetPlayPosition = function(self)
	if self.soundEvt then
		return self.soundEvt:GetPlayPosition()
	end
end

this.SetSpeed = function(self, speed)
	if self.soundEvt then
		self.soundEvt:SetSpeed(speed)
	end
end

this.Resume = function(self, fadeTime, fadeCurve)
	fadeTime = fadeTime or -1
	fadeCurve = fadeCurve or -1

	if self.soundEvt then
		self.soundEvt:Resume(fadeTime, fadeCurve)
	end
end

this.SetRTPCValue = function(self, key, value)
	if self.soundEvt then
		self.soundEvt:SetRTPCValue(key, value)
	end
end

this.AddOnlineMarkFun = function(self, markFun)
	if self.soundEvt then
		self.soundEvt:AddOnlineMarkFun(markFun)
	end
end

return this
