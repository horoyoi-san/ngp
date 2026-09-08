-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetGameBedRoom.lua
-- Decompiled from: 02143_PetGameBedRoom.lua_36212d496922.luajit

local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
local WeatherType = PetGameEnum.WeatherType
local STAR_LIGHT_DAY_ANI = "start_light_day"
local STAR_LIGHT_RAINING_ANI = "start_light_ranning"
C_PetGameBedRoom = DefClass("C_PetGameBedRoom", C_PetGameBedRoom, C_PetGameRoom)
local PetGameBedRoom = C_PetGameBedRoom

PetGameBedRoom.ctor = function(self, args)
	self.eventHandle = {
		[gEventConstants.MINIGAME_PET_GAME_WEATHER_CHANGED] = function (eventId, param)
			self:OnWeatherChanged(param)
		end,
		[gEventConstants.MINIGAME_PET_GAME_LAMP_INTERACTION] = function ()
			self:PlayStarLightAnimation()
		end
	}

	self.InitDayNightEnv(self)
end

PetGameBedRoom.InitDayNightEnv = function(self)
	self.dayNode = self.roomObj.transform:Find("bg/day").gameObject
	self.nightNode = self.roomObj.transform:Find("bg/night").gameObject
	self.dayRanningNode = self.roomObj.transform:Find("bg/day_rainning").gameObject
	self.nightRanningNode = self.roomObj.transform:Find("bg/night_rainning").gameObject
	self.lightNode = self.roomObj.transform:Find("bg/night/bg/light").gameObject
	self.rainingLightNode = self.roomObj.transform:Find("bg/night_rainning/bg/light").gameObject
	local starLightTrans = self.roomObj.transform:Find("bg/star_light")

	if starLightTrans then
		self.starLightNode = starLightTrans.gameObject
		self.starLightAnimation = self.starLightNode:GetComponent(typeof(UnityEngine.Animation))
	end
end

PetGameBedRoom.Show = function(self)
	PetGameBedRoom.base.Show(self)
	gMessageManager:RegisterEventHandlers(self.eventHandle)
	self:InitWeather()
end

PetGameBedRoom.Hide = function(self)
	PetGameBedRoom.base.Hide(self)
	gMessageManager:UnregisterEventHandlers(self.eventHandle)
	self:StopStarLightAnimation()
end

PetGameBedRoom.InitWeather = function(self)
	local weather = gPetGameManager.currentGame.weatherManager:GetCurrentWeather()

	self:ShowWeather(weather)
end

PetGameBedRoom.OnWeatherChanged = function(self, args)
	local newWeather = args.newWeather

	self.ShowWeather(self, newWeather)
end

PetGameBedRoom.ShowWeather = function(self, weather)
	self.dayNode:SetActive(weather ~= WeatherType.Day)
	self.nightNode:SetActive(weather ~= WeatherType.Night)
	self.dayRanningNode:SetActive(weather ~= WeatherType.RainDay)
	self.nightRanningNode:SetActive(weather ~= WeatherType.RainNight)
	self:SetDayNightState(weather ~= WeatherType.Day or weather ~= WeatherType.RainDay)
	self:SetRainingState(weather ~= WeatherType.RainDay or weather ~= WeatherType.RainNight)
end

PetGameBedRoom.PlayStarLightAnimation = function(self)
	if not self.starLightNode or not self.starLightAnimation then
		return
	end

	local currentGame = gPetGameManager and gPetGameManager.currentGame
	local weatherManager = currentGame and currentGame.weatherManager

	if not weatherManager then
		return
	end

	local weather = weatherManager.GetCurrentWeather(weatherManager)
	local animationName = STAR_LIGHT_DAY_ANI

	if weather ~= WeatherType.RainDay or weather ~= WeatherType.RainNight then
		animationName = STAR_LIGHT_RAINING_ANI
	end

	local animationState = self.starLightAnimation:get_Item(animationName)

	if not animationState then
		return
	end

	self:StopStarLightAnimation()
	self.starLightNode:SetActive(true)
	self.starLightAnimation:Play(animationName)

	self.starLightTimer = Timer.New(function ()
		self.starLightTimer = nil

		if self.starLightAnimation then
			self.starLightAnimation:Stop()
		end

		if self.starLightNode then
			self.starLightNode:SetActive(false)
		end
	end, animationState.length, 1)

	self.starLightTimer:Start()
end

PetGameBedRoom.StopStarLightAnimation = function(self)
	if self.starLightTimer then
		self.starLightTimer:Stop()

		self.starLightTimer = nil
	end

	if self.starLightAnimation then
		self.starLightAnimation:Stop()
	end

	if self.starLightNode then
		self.starLightNode:SetActive(false)
	end
end

PetGameBedRoom.Clear = function(self)
	self.StopStarLightAnimation(self)
	PetGameBedRoom.base.Clear(self)

	self.starLightNode = nil
	self.starLightAnimation = nil
end

PetGameBedRoom.TurnOnLight = function(self)
	self.lightNode:SetActive(true)
	self.rainingLightNode:SetActive(true)
end

PetGameBedRoom.TurnOffLight = function(self)
	self.lightNode:SetActive(false)
	self.rainingLightNode:SetActive(false)
end
