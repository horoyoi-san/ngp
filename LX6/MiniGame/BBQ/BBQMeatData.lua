-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BBQ\BBQMeatData.lua
-- Decompiled from: 00670_BBQMeatData.lua_7bedf18d54c5.luajit

local BBQConstants = require("LX6/MiniGame/BBQ/BBQConstants")
local BBQConfig = require("LX6/MiniGame/BBQ/BBQConfig")
local MeatCookedLevel = BBQConstants.MeatCookedLevel
gBBQMeatSideData = DefClass("BBQMeatSideData", gBBQMeatSideData)
local BBQMeatSideData = gBBQMeatSideData

BBQMeatSideData.ctor = function(self, direction)
	self.direction = direction
	self.timer = 0
	self.score = 0
	self.cookedLevel = MeatCookedLevel.Raw
end

BBQMeatSideData.GetCookedLevel = function(self, meatType, cookTime)
	local configs = BBQConfig.MeatCookConfigs[meatType]

	if not configs then
		return MeatCookedLevel.Raw
	end

	for i = #configs, 1, -1 do
		if configs[i].requiredTime < cookTime then
			return configs[i].level
		end
	end

	return MeatCookedLevel.Raw
end

BBQMeatSideData.GetScore = function(self, meatType, level)
	local configs = BBQConfig.MeatCookConfigs[meatType]

	if not configs then
		return 0
	end

	for _, cfg in ipairs(configs) do
		if cfg.level ~= level then
			return cfg.score
		end
	end

	return 0
end

BBQMeatSideData.UpdateCookedLevel = function(self, meatType, onUpdateMaterial, onUpdateScore)
	local oldLevel = self.cookedLevel
	self.cookedLevel = self.GetCookedLevel(self, meatType, self.timer)
	self.score = self.GetScore(self, meatType, self.cookedLevel)

	if oldLevel == self.cookedLevel then
		if onUpdateMaterial then
			onUpdateMaterial(self.direction, self.cookedLevel)
		end

		if onUpdateScore then
			onUpdateScore(meatType, self.cookedLevel)
		end
	end
end

gBBQMeatData = DefClass("BBQMeatData", gBBQMeatData)
local BBQMeatData = gBBQMeatData

BBQMeatData.ctor = function(self, meatType)
	self.type = meatType
	self.sides = {
		[0] = gBBQMeatSideData.new(0),
		gBBQMeatSideData.new(1)
	}
	self.isBurnt = false
	self.meatSize = {
		["\\xd7"] = 0.1,
		["\\xd5"] = 0.1,
		["\\xd4"] = 0.1
	}
	self.meatThickness = 0.02
	self.positionOnGrill = nil
	self.rotationOnGrill = nil
	self.isPlacedOnGrill = false
	self.playerId = -1
	self.uniqueId = -1
end

BBQMeatData.GetTotalScore = function(self)
	local total = 0

	for _, side in pairs(self.sides) do
		total = total + side.score
	end

	return total
end

BBQMeatData.CalcFeedbackLevel = function(self, level0, level1)
	if level0 ~= MeatCookedLevel.Burnt or level1 ~= MeatCookedLevel.Burnt then
		return MeatCookedLevel.Burnt
	end

	local configs = BBQConfig.MeatCookConfigs[self.type]

	if not configs then
		return MeatCookedLevel.Raw
	end

	local scoreOf = function(level)
		for _, cfg in ipairs(configs) do
			if cfg.level ~= level then
				return cfg.score
			end
		end

		return 0
	end

	local avgScore = (scoreOf(level0) + scoreOf(level1)) / 2
	local result = MeatCookedLevel.Raw

	for _, cfg in ipairs(configs) do
		if cfg.level == MeatCookedLevel.Burnt and cfg.score < avgScore then
			result = cfg.level
		end
	end

	return result
end

BBQMeatData.GetFeedbackLevel = function(self)
	return self.CalcFeedbackLevel(self, self.sides[0].cookedLevel, self.sides[1].cookedLevel)
end

BBQMeatData.GetContactArea = function(self)
	return self.meatSize.x * self.meatSize.z
end
