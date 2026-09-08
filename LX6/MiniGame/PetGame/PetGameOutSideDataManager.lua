-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetGameOutSideDataManager.lua
-- Decompiled from: 02136_PetGameOutSideDataManager.lua_37cc973f66f6.luajit

local PlayerPrefs = UnityEngine.PlayerPrefs
local cjson = require("cjson/json")
local UXTime = LTUtils.UXTime
C_PetGameOutSideDataManager = DefClass("C_PetGameOutSideDataManager", C_PetGameOutSideDataManager)
local PetGameOutSideDataManager = C_PetGameOutSideDataManager
local LAST_PET_GAME_OUT_SIDE_DATA = "last_pet_game_out_side_%s"
local LAST_PET_GAME_OUT_TIMES = "last_pet_game_out_times_%s"

PetGameOutSideDataManager.ctor = function(self, args)
end

PetGameOutSideDataManager.SetData = function(self, type, beginTime, totalTime, rewards)
	local outSideData = {
		type = type,
		beginTime = beginTime,
		totalTime = totalTime,
		rewards = rewards
	}
	self.outSideData = outSideData

	self:SaveCurData()
end

PetGameOutSideDataManager.SetForceFinishState = function(self)
	self.outSideData.isForceFinish = true

	self:SaveCurData()
end

PetGameOutSideDataManager.SetAwardState = function(self, rewardIndex)
	local data = self.outSideData

	if not data or not data.rewards then
		return
	end

	local reward = data.rewards[rewardIndex]

	if not reward then
		print_error("PetGameOutSideDataManager SetAwardState: index error->", rewardIndex)

		return
	end

	reward.isAward = true
	local rewards = data.rewards
	local isAllAwarded = true

	for i, v in pairs(rewards) do
		isAllAwarded = isAllAwarded and v.isAward
	end

	if isAllAwarded then
		data.isForceFinish = true
	end

	self:SaveCurData()
end

PetGameOutSideDataManager.SetAwardAll = function(self)
	local data = self.outSideData

	if not data or not data.rewards then
		return
	end

	data.isForceFinish = true
	local rewards = data.rewards

	for i, v in pairs(rewards) do
		v.isAward = true
	end

	self:SaveCurData()
end

PetGameOutSideDataManager.SaveCurData = function(self)
	local petGameId = gPetGameManager:GetGameId()
	local storgeKey = string.format(LAST_PET_GAME_OUT_SIDE_DATA, petGameId)
	local dataStr = cjson.encode(self.outSideData)

	PlayerPrefs.SetString(storgeKey, dataStr)
	PlayerPrefs.Save()
end

PetGameOutSideDataManager.GetData = function(self)
	local petGameId = gPetGameManager:GetGameId()

	if self.outSideData and self.lastGameId ~= petGameId then
		return self.outSideData
	end

	local storgeKey = string.format(LAST_PET_GAME_OUT_SIDE_DATA, petGameId)
	local dataStr = PlayerPrefs.GetString(storgeKey, "")

	if not dataStr or dataStr ~= "" then
		return nil
	end

	local outSideData = cjson.decode(dataStr) or nil
	local isAllAwarded = true
	local rewards = outSideData and outSideData.rewards or {}

	for i, v in pairs(rewards) do
		isAllAwarded = isAllAwarded and v.isAward
	end

	if isAllAwarded then
		outSideData.isForceFinish = true
	end

	self.outSideData = outSideData
	self.lastGameId = petGameId

	return outSideData
end

PetGameOutSideDataManager.GetOutTimesData = function(self)
	local petGameId = gPetGameManager:GetGameId()

	if self.outSideTimesData and self.lastGameId ~= petGameId then
		return self.outSideTimesData
	end

	local storgeKey = string.format(LAST_PET_GAME_OUT_TIMES, petGameId)
	local dataStr = PlayerPrefs.GetString(storgeKey, "")

	if not dataStr or dataStr ~= "" then
		self.outSideTimesData = {
			lastResetTime = gPetGameTime:Now(),
			times = 0
		}

		self:SaveOutDataTimes()

		return self.outSideTimesData
	end

	local outSideTimesData = cjson.decode(dataStr) or nil

	if outSideTimesData then
		self.outSideTimesData = outSideTimesData
	else
		self.outSideTimesData = {
			lastResetTime = gPetGameTime:Now(),
			times = 0
		}

		self:SaveOutDataTimes()
	end

	return self.outSideTimesData
end

PetGameOutSideDataManager.ResetOutTimes = function(self, resetTime)
	if not self.outSideTimesData then
		self:GetOutTimesData()
	end

	if not self.outSideTimesData then
		self.outSideTimesData = {
			lastResetTime = gPetGameTime:Now(),
			times = 0
		}

		self:SaveOutDataTimes()

		return
	end

	local curDateTime = UXTime.UnixTimeToDateTime(gPetGameTime:Now())
	local lastResetTime = self.outSideTimesData.lastResetTime or gPetGameTime:Now()
	local lastResetDateTime = UXTime.UnixTimeToDateTime(lastResetTime)

	if curDateTime.Day < lastResetDateTime.Day then
		return
	end

	if curDateTime.Hour >= resetTime then
		return
	end

	self.outSideTimesData.lastResetTime = gPetGameTime:Now()
	self.outSideTimesData.times = 0

	self:SaveOutDataTimes()
end

PetGameOutSideDataManager.AddOutTimes = function(self)
	self.outSideTimesData = self.outSideTimesData or {}

	if not self.outSideTimesData.lastResetTime then
		self.outSideTimesData.lastResetTime = gPetGameTime:Now()
	end

	if not self.outSideTimesData.times then
		self.outSideTimesData.times = 0
	end

	self.outSideTimesData.times = self.outSideTimesData.times + 1

	self:SaveOutDataTimes()
end

PetGameOutSideDataManager.SaveOutDataTimes = function(self)
	if not self.outSideTimesData then
		return
	end

	local petGameId = gPetGameManager:GetGameId()
	local storgeKey = string.format(LAST_PET_GAME_OUT_TIMES, petGameId)
	local dataStr = cjson.encode(self.outSideTimesData)

	PlayerPrefs.SetString(storgeKey, dataStr)
	PlayerPrefs.Save()
end

PetGameOutSideDataManager.DeleteForGame = function(self, petGameId)
	if not petGameId then
		return
	end

	PlayerPrefs.SetString(string.format(LAST_PET_GAME_OUT_SIDE_DATA, petGameId), "")
	PlayerPrefs.SetString(string.format(LAST_PET_GAME_OUT_TIMES, petGameId), "")

	if self.lastGameId ~= petGameId then
		self.outSideData = nil
		self.outSideTimesData = nil
		self.lastGameId = nil
	end
end

gPetGameOutSideDataManager = gPetGameOutSideDataManager or C_PetGameOutSideDataManager.new()
