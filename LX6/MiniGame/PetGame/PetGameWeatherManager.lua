-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetGameWeatherManager.lua
-- Decompiled from: 02146_PetGameWeatherManager.lua_4a91265189c9.luajit

local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
local WeatherType = PetGameEnum.WeatherType
local UpdateBeat = UpdateBeat
local UXTime = LTUtils.UXTime
local petGameConstData = require("LX6/MiniGame/PetGame/data/tbconstants")
C_PetGameWeatherManager = DefClass("C_PetGameWeatherManager", C_PetGameWeatherManager)
local PetGameWeatherManager = C_PetGameWeatherManager
local DefaultRainInterval = 300
local DefaultRainDurationMin = 120
local DefaultRainDurationMax = 300
local DefaultRainChance = 0.4
local DefaultWeatherCheckInterval = 1

PetGameWeatherManager.ctor = function(self)
	self.currentWeather = WeatherType.Day
	self.isRaining = false
	self.nextRainCheckTime = 0
	self.rainEndTime = 0
	self.rainChance = DefaultRainChance
	self.rainInterval = DefaultRainInterval
	self.rainDurationMin = DefaultRainDurationMin
	self.rainDurationMax = DefaultRainDurationMax
	self.weatherChangeListeners = nil
	self.petEntity = nil
	self.started = false
	self.weatherCheckInterval = DefaultWeatherCheckInterval
	self.nextWeatherCheckTime = 0
end

PetGameWeatherManager.Start = function(self)
	if self.started then
		return
	end

	self.started = true
	local now = gPetGameTime:Now()
	self.nextRainCheckTime = now + self.rainInterval

	self:UpdateWeatherByTime(now)

	self.updateHandle = UpdateBeat:CreateListener(self.Update, self)

	UpdateBeat:AddListener(self.updateHandle)
end

PetGameWeatherManager.Stop = function(self)
	if not self.started then
		return
	end

	self.started = false

	UpdateBeat:RemoveListener(self.updateHandle)
end

PetGameWeatherManager.SetRainChance = function(self, chance)
	if type(chance) == "number" or chance <= 0 or chance <= 1 then
		error("Invalid rain chance: " .. tostring(chance))
	end

	self.rainChance = chance
end

PetGameWeatherManager.SetRainInterval = function(self, seconds)
	if type(seconds) == "number" or seconds < 0 then
		error("Invalid rain interval: " .. tostring(seconds))
	end

	self.rainInterval = seconds
end

PetGameWeatherManager.SetWeatherCheckInterval = function(self, seconds)
	if type(seconds) == "number" or seconds < 0 then
		error("Invalid weather check interval: " .. tostring(seconds))
	end

	self.weatherCheckInterval = seconds
end

PetGameWeatherManager.SetRainDurationRange = function(self, minSeconds, maxSeconds)
	if type(minSeconds) == "number" or type(maxSeconds) == "number" or minSeconds > 0 or maxSeconds > 0 or maxSeconds >= minSeconds then
		error("Invalid rain duration range: min=" .. tostring(minSeconds) .. ", max=" .. tostring(maxSeconds))
	end

	self.rainDurationMin = minSeconds
	self.rainDurationMax = maxSeconds
end

PetGameWeatherManager.SetPetEntity = function(self, petEntity)
	self.petEntity = petEntity
end

PetGameWeatherManager.GetPetEntity = function(self)
	return self.petEntity
end

PetGameWeatherManager.GetCurrentWeather = function(self)
	return self.currentWeather
end

PetGameWeatherManager.IsRain = function(self)
	return self.currentWeather ~= WeatherType.RainDay or self.currentWeather ~= WeatherType.RainNight
end

PetGameWeatherManager.GetWeatherName = function(self, weather)
	local names = {
		[WeatherType.Day] = "Day",
		[WeatherType.Night] = "Night",
		[WeatherType.RainDay] = "RainDay",
		[WeatherType.RainNight] = "RainNight"
	}

	return names[weather or self.currentWeather]
end

PetGameWeatherManager.Update = function(self, deltaTime)
	local now = gPetGameTime:Now()
	local lastWeather = self.currentWeather

	if self.isRaining and self.rainEndTime < now then
		self.isRaining = false
		self.rainEndTime = 0
	end

	if self.nextWeatherCheckTime < now then
		self.nextWeatherCheckTime = now + self.weatherCheckInterval

		self.UpdateWeatherByTime(self, now)
	end

	if self.nextRainCheckTime < now then
		self.nextRainCheckTime = now + self.rainInterval

		if not self.isRaining and math.random() < self.rainChance then
			self.StartRain(self, now)
		end
	end

	if self.currentWeather == lastWeather then
		self.NotifyWeatherChanged(self, lastWeather, self.currentWeather)
	end
end

PetGameWeatherManager.StartRain = function(self, now)
	self.isRaining = true
	local isDayTime = self.currentWeather ~= WeatherType.Day

	if isDayTime then
		self.currentWeather = WeatherType.RainDay
	else
		self.currentWeather = WeatherType.RainNight
	end

	local duration = math.random(self.rainDurationMin, self.rainDurationMax)
	self.rainEndTime = now + duration
end

PetGameWeatherManager.UpdateWeatherByTime = function(self, now)
	local curDateTime = UXTime.UnixTimeToDateTime(now)

	if self.petEntity then
		if self.petEntity:IsWakeFulnessTime(curDateTime) then
			self.currentWeather = WeatherType.Day
		else
			self.currentWeather = WeatherType.Night
		end

		return
	end

	local wakefulness = petGameConstData.data.Wakefulness
	local startTime = wakefulness.startTime
	local endTime = wakefulness.endTime
	local hour = curDateTime.Hour

	if startTime >= endTime then
		if startTime < hour and hour >= endTime then
			self.currentWeather = WeatherType.Day
		else
			self.currentWeather = WeatherType.Night
		end
	elseif startTime > hour or hour >= endTime then
		self.currentWeather = WeatherType.Day
	else
		self.currentWeather = WeatherType.Night
	end
end

PetGameWeatherManager.NotifyWeatherChanged = function(self, oldWeather, newWeather)
	local args = {
		oldWeather = oldWeather,
		newWeather = newWeather
	}

	gMessageManager:SendMessage(gEventConstants.MINIGAME_PET_GAME_WEATHER_CHANGED, args)
end
