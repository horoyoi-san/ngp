-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BBQ\BBQConfig.lua
-- Decompiled from: 00664_BBQConfig.lua_64a40b9e3b21.luajit

local BBQConstants = require("LX6/MiniGame/BBQ/BBQConstants")
local MeatCookedLevel = BBQConstants.MeatCookedLevel
local BBQMeatTypeConfig = LTConfig.PoiGameBBQMeatTypeConfig

local BuildMeatCookConfigs = function()
	local configs = {}

	for i = 0, BBQMeatTypeConfig.count - 1 do
		local cfg = BBQMeatTypeConfig.LoadAt(i)

		if cfg then
			local meatType = cfg.Id
			configs[meatType] = {
				{
					level = MeatCookedLevel.Raw,
					duration = cfg.Duration[1],
					score = cfg.Score[1],
					requiredTime = cfg.RequiredTime[1]
				},
				{
					level = MeatCookedLevel.Undercooked,
					duration = cfg.Duration[2],
					score = cfg.Score[2],
					requiredTime = cfg.RequiredTime[2]
				},
				{
					level = MeatCookedLevel.Medium,
					duration = cfg.Duration[3],
					score = cfg.Score[3],
					requiredTime = cfg.RequiredTime[3]
				},
				{
					level = MeatCookedLevel.WellDone,
					duration = cfg.Duration[4],
					score = cfg.Score[4],
					requiredTime = cfg.RequiredTime[4]
				},
				{
					level = MeatCookedLevel.Burnt,
					duration = cfg.Duration[5],
					score = cfg.Score[5],
					requiredTime = cfg.RequiredTime[5]
				}
			}
		end
	end

	return configs
end

local BuildMaterialPaths = function()
	local paths = {}

	for i = 0, BBQMeatTypeConfig.count - 1 do
		local cfg = BBQMeatTypeConfig.LoadAt(i)

		if cfg and cfg.MeatMat then
			local meatType = cfg.Id
			paths[meatType] = {
				[MeatCookedLevel.Undercooked] = cfg.MeatMat[1],
				[MeatCookedLevel.Medium] = cfg.MeatMat[2],
				[MeatCookedLevel.WellDone] = cfg.MeatMat[3],
				[MeatCookedLevel.Burnt] = cfg.MeatMat[4]
			}
		end
	end

	return paths
end

local M = {
	MeatCookConfigs = BuildMeatCookConfigs(),
	AI = {
		ThinkIntervalMin = LTConfig.PoiGameConfig.BBQ_AIThinkIntervalMin or 0.3,
		ThinkIntervalMax = LTConfig.PoiGameConfig.BBQ_AIThinkIntervalMax or 1,
		MouseMoveSpeedMin = LTConfig.PoiGameConfig.BBQ_AIMouseSpeedMin or 20,
		MouseMoveSpeedMax = LTConfig.PoiGameConfig.BBQ_AIMouseSpeedMax or 30,
		BurntProb = LTConfig.PoiGameConfig.BBQ_AIBurntProb or 0.5,
		BurntMistakeProb = LTConfig.PoiGameConfig.BBQ_AIWrongPickSelfProb or 0,
		FlipProb = LTConfig.PoiGameConfig.BBQ_AIFlipProb or 0.5,
		PickProb = LTConfig.PoiGameConfig.BBQ_AIPickProb or 0.6,
		PickMistakeProb = LTConfig.PoiGameConfig.BBQ_AIWrongPickOtherProb or 0,
		CookLevelThresholdMin = LTConfig.PoiGameConfig.BBQ_AIPickDonenessMin or 2,
		CookLevelThresholdMax = LTConfig.PoiGameConfig.BBQ_AIPickDonenessMax or 4
	},
	PlateMeatTypeMap = {
		["MT\\x9dG@\\xb3\\xe6B*2*"] = 5,
		["MT\\x9dG@\\xb3\\xe6B*2,"] = 3,
		["MT\\x9dG@\\xb3\\xe6B*2/"] = 2,
		["\\x89\\x934\\x9bf?\\xea6"] = 1,
		["MT\\x9dG@\\xb3\\xe6B*2-"] = 4
	},
	MaterialPaths = BuildMaterialPaths()
}

return M
