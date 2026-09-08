-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\GamePlayBeginManager.lua
-- Decompiled from: 00726_GamePlayBeginManager.lua_f5a428aada44.luajit

local BeginConfig = LTConfig.GameplayHudDescBeginConfig
local DropConfig = LTConfig.DropConfig
local LinkMultiPlayerConfig = LTConfig.LinkMultiPlayerConfig
C_GamePlayBeginManager = DefClass("C_GamePlayBeginManager", C_GamePlayBeginManager)
local M = C_GamePlayBeginManager

M.ctor = function(self)
end

M.OnBegin = function(self, id, options, customData)
	local cfg = BeginConfig.GetConfig(id)

	if not cfg then
		return
	end

	local action = self:CreateAction(cfg.StartAction)

	if action then
		action(options, customData)
	end
end

M.BeginGobang = function(self, options)
	print_debug("[C_GamePlayBeginManager] BeginGobang")

	local difficulty = 0
	local useBlack = false
	local mode = 2

	for option, index in pairs(options) do
		if option ~= LTConfig.GameplayHudDescBeginOptionConfig.SelectDifficulty then
			difficulty = index
		elseif option ~= LTConfig.GameplayHudDescBeginOptionConfig.SelectSide then
			useBlack = index ~= 0
		elseif option ~= LTConfig.GameplayHudDescBeginOptionConfig.SelectSkillMode then
			if index ~= 0 then
				mode = 2
			elseif index ~= 1 then
				mode = 4
			end
		end
	end

	L50.L50App.Scene.GomokuManager:StartGomoke(mode, useBlack, difficulty)
	gPanelManager:Close(gPanelId.COMMON_GAMEPLAY_START_PANEL)
end

M.BeginDiceGame = function(self, options, customData)
	local level = options[1]
	local modeIndex = options[LTConfig.GameplayHudDescBeginOptionConfig.SelectDiceMode] or 0
	local gameType = modeIndex ~= 0 and 1 or 0

	if customData.isPVP then
		local linkModeId = gameType ~= 0 and LinkMultiPlayerConfig.DiceGame_Complex or LinkMultiPlayerConfig.DiceGame_Simple

		gLinkManager:AskMatchBegin(linkModeId, true)
	else
		gPanelManager:CheckShow(gPanelId.S_BAR_GAME_START_PANEL, {
			level = level,
			customData = customData,
			gameType = gameType
		})
		gPanelManager:Close(gPanelId.COMMON_GAMEPLAY_START_PANEL)
	end
end

M.BeginPalmKing = function(self, options, customData)
	gPanelManager:CheckShow(gPanelId.S_PALM_KING_PANEL, {
		[3] = customData,
		slapAIId = 100 + (options[LTConfig.GameplayHudDescBeginOptionConfig.SelectPalmKingDifficulty] or 0)
	})
	gPanelManager:Close(gPanelId.COMMON_GAMEPLAY_START_PANEL)
end

M.BeginNightRun = function(self, options, customData)
	local trackId = customData and customData.trackId or 0

	if trackId < 0 then
		print_error("[C_GamePlayBeginManager] BeginNightRun 缺少 trackId")

		return
	end

	gNightRunManager:StartPlay(trackId)
	gPanelManager:Close(gPanelId.COMMON_GAMEPLAY_START_PANEL)
end

M.BeginDraw = function(self, options)
	local usingAI = false

	for option, index in pairs(options) do
		if option ~= LTConfig.GameplayHudDescBeginOptionConfig.SelectDraw then
			usingAI = false
		elseif option ~= LTConfig.GameplayHudDescBeginOptionConfig.SelectAIDraw then
			usingAI = true
		end
	end

	gPanelManager:Close(gPanelId.COMMON_GAMEPLAY_START_PANEL)
	gPanelManager:CheckShow(gPanelId.PAINTING_PANEL, usingAI)
end

M.GetRewardListByOptions = function(self, optionsList, options)
	local rewardList = {}

	if not optionsList then
		return rewardList
	end

	for i = 1, #optionsList do
		local optionData = optionsList[i]
		local optionIndex = (options[optionData.id] or 0) + 1
		local drop = optionData.options[optionIndex] and optionData.options[optionIndex].drop or 0

		if drop <= 0 then
			local dropConfig = DropConfig.GetConfig(drop)

			if dropConfig then
				table.insert(rewardList, {
					dropId = drop
				})
			end
		end
	end

	return rewardList
end

gGamePlayBeginMgr = gGamePlayBeginMgr or C_GamePlayBeginManager.new()
