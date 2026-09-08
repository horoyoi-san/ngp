-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetGameTime.lua
-- Decompiled from: 02135_PetGameTime.lua_1266314eb8d1.luajit

local PlayerPrefs = UnityEngine.PlayerPrefs
local petGameConstData = require("LX6/MiniGame/PetGame/data/tbconstants")
C_PetGameTime = DefClass("C_PetGameTime", C_PetGameTime)
local PetGameTime = C_PetGameTime
local PET_GAME_LAST_UPDATE_KEY = "PET_GAME_LAST_UPDATE_%s"
local PET_GAME_GAME_TIME_KEY = "PET_GAME_GAME_TIME_%s"

local NowSec = function()
	local t = gCS and gCS.TimeManager and gCS.TimeManager.ServerUnixTime

	if t and t <= 0 then
		return t
	end

	return os.time()
end

PetGameTime.ctor = function(self)
	local curSystemTime = NowSec()
	self.curSystemTime = curSystemTime
	self.lastUpdateTime = curSystemTime
	self.gameTime = curSystemTime
	self.currentDayKey = self:GetDayKey(self.gameTime)
	self.petGameId = nil
	self.Inited = false
	self.timeScale = petGameConstData.data and petGameConstData.data.TimeCoefficient or 1
end

PetGameTime._GetKeys = function(self, petGameId)
	return string.format(PET_GAME_LAST_UPDATE_KEY, petGameId), string.format(PET_GAME_GAME_TIME_KEY, petGameId)
end

PetGameTime.LoadForGame = function(self, petGameId)
	self.petGameId = petGameId
	local curSystemTime = NowSec()
	local lastKey, timeKey = self:_GetKeys(petGameId)
	self.lastUpdateTime = PlayerPrefs.GetInt(lastKey, curSystemTime)
	self.gameTime = PlayerPrefs.GetInt(timeKey, curSystemTime)
	self.curSystemTime = curSystemTime
	self.currentDayKey = self:GetDayKey(self.gameTime)
end

PetGameTime.SaveForGame = function(self)
	if not self.petGameId then
		return
	end

	local lastKey, timeKey = self:_GetKeys(self.petGameId)

	PlayerPrefs.SetInt(lastKey, self.lastUpdateTime)
	PlayerPrefs.SetInt(timeKey, self.gameTime)
	PlayerPrefs.Save()
end

PetGameTime.DeleteForGame = function(self, petGameId)
	if not petGameId then
		return
	end

	local lastKey, timeKey = self:_GetKeys(petGameId)

	PlayerPrefs.SetInt(lastKey, 0)
	PlayerPrefs.SetInt(timeKey, 0)
end

PetGameTime.ResetTime = function(self)
	local curSystemTime = NowSec()
	self.lastUpdateTime = curSystemTime
	self.gameTime = curSystemTime

	self:CheckDateChanged()
end

PetGameTime.SetTime = function(self, seconds)
	self.gameTime = seconds

	self:CheckDateChanged()
end

PetGameTime.Now = function(self)
	self.curSystemTime = NowSec()
	local interval = self.curSystemTime - self.lastUpdateTime

	if interval <= 0 then
		self.gameTime = self.gameTime + interval * self.timeScale
		self.lastUpdateTime = self.curSystemTime
	elseif interval >= 0 then
		self.lastUpdateTime = self.curSystemTime
	end

	self:CheckDateChanged()

	return self.gameTime
end

PetGameTime.GetDayKey = function(self, timestamp)
	return os.date("%Y%m%d", math.floor(timestamp))
end

PetGameTime.CheckDateChanged = function(self)
	local newDayKey = self:GetDayKey(self.gameTime)
	local oldDayKey = self.currentDayKey

	if newDayKey ~= oldDayKey then
		return false
	end

	self.currentDayKey = newDayKey

	if oldDayKey and gMessageManager and gEventConstants and gEventConstants.MINIGAME_PET_GAME_DATE_CHANGED then
		gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_DATE_CHANGED, {
			oldDayKey = oldDayKey,
			newDayKey = newDayKey,
			timestamp = self.gameTime
		})
	end

	return true
end

PetGameTime.SetTimeScale = function(self, scale)
	self.timeScale = scale or 1
end

PetGameTime.GetTimeScale = function(self)
	return self.timeScale or 1
end

PetGameTime.OnDestroy = function(self)
	self:SaveForGame()
end

gPetGameTime = gPetGameTime or C_PetGameTime.new()
