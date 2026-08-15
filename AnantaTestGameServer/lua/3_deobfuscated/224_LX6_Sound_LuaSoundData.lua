local setmetatable = setmetatable
local LuaSoundData = {}
local this = LuaSoundData
local rawget = rawget
local rawset = rawset

function this.__index(obj, key)
	local value = rawget(obj, key)

	if value then
		return value
	end

	value = this[key]

	return value
end

function this.__newindex(obj, key, val)
	rawset(obj, key, val)
end

local _new = this.New

function this.__call()
	return _new()
end

function this.New()
	local table = {}
	local v = setmetatable(table, this)

	v:ResetData()

	return v
end

function this:ResetData()
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
end

function this:IsValid()
	return not self.isDestroy
end

function this:SetSoundPosition(masterPos, eulerAngles)
	self.position = masterPos
	self.eulerAngles = eulerAngles

	self.soundEvt:SetPositionAndEulerAngles(self.position, self.eulerAngles)
end

function this:StopSoundEvt()
	if self.soundEvt then
		self.soundEvt:Stop()

		self.soundEvt = nil
	end
end

function this:Stop()
	if self.soundEvt then
		self.soundEvt:Stop()
	end
end

function this:Pause()
	if self.soundEvt then
		self.soundEvt:Pause()
	end
end

function this:SeekToPersent(persent)
	if self.soundEvt then
		self.soundEvt:SeekToPersent(persent)
	end
end

function this:SeekToTime(time)
	if self.soundEvt then
		self.soundEvt:SeekToTime(time)
	end
end

function this:GetPlayPosition()
	if self.soundEvt then
		return self.soundEvt:GetPlayPosition()
	end
end

function this:SetSpeed(speed)
	if self.soundEvt then
		self.soundEvt:SetSpeed(speed)
	end
end

function this:Resume()
	if self.soundEvt then
		self.soundEvt:Resume()
	end
end

function this:SetRTPCValue(key, value)
	if self.soundEvt then
		self.soundEvt:SetRTPCValue(key, value)
	end
end

return this
