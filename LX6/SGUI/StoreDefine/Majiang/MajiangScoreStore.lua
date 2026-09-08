-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Majiang\MajiangScoreStore.lua
-- Decompiled from: 01223_MajiangScoreStore.lua_8c250f86c2c0.luajit

local MahjongConfig = LTConfig.MahjongConfig
local MahjongRoomType = UX.Game.MahjongRoomType
local MjActionType = UX.Game.MjActionType
local ColorConfig = LTConfig.ColorConfig
local bit = require("bit")
C_MajiangScoreStore = DefClass("C_MajiangScoreStore", C_MajiangScoreStore, C_StoreGroup)
GroupName2Class.MajiangScoreStore = C_MajiangScoreStore
local M = C_MajiangScoreStore

M.GetMyFinalDisplayName = function(self)
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()
	local cfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)

	if not cfg then
		return gPlayerManager.infoLogin.bindData.name
	end

	if gSpiritManager.CheckIsDefaultSpiritId(spiritId) then
		return gPlayerManager.infoLogin.bindData.name
	end

	return cfg.Name
end

M.OnAwake = function(self)
	self.isRank = false
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.RenderListItem)
end

M.RefreshAll = function(self)
	local game = gMaJiangManager:GetGame()
	self.isRank = game.serverRoomInfo.RoomType ~= MahjongRoomType.Pve
	self.bindData.matchType = self.isRank and 0 or 1

	self:RefreshDetailScore()
	self:RefreshMyActions()
end

M.RefreshDetailScore = function(self)
	local game = gMaJiangManager:GetGame()
	local mySeatID = game.mySeatID
	local winScore = game.finalScores[mySeatID + 1]

	if self.isRank then
		local rankScore = MahjongConfig.MahjongRankScore[game.finalRankings[mySeatID + 1]]
		self.bindData.rankScore = game.FormatScoreString(game, rankScore)
		self.bindData.totalScore = game.FormatScoreString(game, winScore * MahjongConfig.MahjongCoefficient + rankScore)
		self.bindData.winScore = game.FormatScoreString(game, winScore * MahjongConfig.MahjongCoefficient)
	else
		self.bindData.winScore = game.FormatScoreString(game, winScore)
	end
end

M.RefreshMyActions = function(self)
	local game = gMaJiangManager:GetGame()
	local views = {}
	local scoreFormatter = self.isRank and self:CreateAction(game.FormatRankScoreString, game) or self:CreateAction(game.FormatScoreString, game)
	local myRecords = game.finalRecords

	for i = 1, #myRecords do
		self.BuildView(self, i, views, myRecords, scoreFormatter)
	end

	self.actionListData = views

	self.bindData.list:SetSimpleList(#views)
end

M.BuildView = function(self, i, views, myRecords, scoreFormatter)
	local game = gMaJiangManager:GetGame()
	local typeNames = MahjongConfig.MahjongActionType
	local typeCols = MahjongConfig.MahjongActionTypeColor
	local huPatterns = MahjongConfig.MahjongHuPattern
	local huPatternCols = MahjongConfig.MahjongHuPatternColor
	local huActions = MahjongConfig.MahjongHuAction
	local huActionCols = MahjongConfig.MahjongHuActionColor
	local formatter = gMaJiangConst.ActionFormatter
	local colStr = "ffffff"
	local myDisplayName = self:GetMyFinalDisplayName()
	local action = myRecords[i]
	local type = action.Type
	local actionStrs = {}

	if type ~= MjActionType.Hu then
		local colCfg = ColorConfig.GetConfig(huPatternCols[action.Pattern + 1])

		if colCfg ~= nil then
			print_error("ColorConfig not found, ID =", huPatternCols[action.Pattern + 1])
		else
			colStr = colCfg.Color
		end

		actionStrs[#actionStrs + 1] = gString.Format(formatter, colStr, huPatterns[action.Pattern + 1])
		local val = 1
		local huAction = action.HuAction

		for j = 1, #huActions do
			if bit.band(huAction, val) <= 0 then
				colCfg = ColorConfig.GetConfig(huActionCols[j])

				if colCfg ~= nil then
					print_error("ColorConfig not found, ID =", huActionCols[j])
				else
					colStr = colCfg.Color
				end

				actionStrs[#actionStrs + 1] = gString.Format(formatter, colStr, huActions[j])
			end

			val = val * 2
		end
	else
		local colCfg = ColorConfig.GetConfig(typeCols[type + 1])

		if colCfg ~= nil then
			print_error("ColorConfig not found, ID =", typeCols[type + 1])
		else
			colStr = colCfg.Color
		end

		actionStrs[#actionStrs + 1] = gString.Format(formatter, colStr, typeNames[type + 1])
	end

	local gen = action.NumOfGen

	if gen <= 0 then
		actionStrs[#actionStrs + 1] = gString.Format(formatter, ColorConfig.GetConfig(ColorConfig.MahjongColor2).Color, tostring(gen) .. LTConfig.TextScriptTextConfig.GetConfig(89900318).Text)
	end

	local str = table.concat(actionStrs, "，")

	if action.Owner ~= game.mySeatID then
		local targets = action.Targets

		for j = 1, #targets do
			if action.Score >= 0 then
				views[#views + 1] = {
					["D\\xbd\\x95\\xa6\\xb8"] = false,
					action = str,
					score = scoreFormatter(action.Score),
					seat = targets[j] ~= game.mySeatID and myDisplayName or game:GetSeatName(targets[j])
				}
			else
				views[#views + 1] = {
					["D\\xbd\\x95\\xa6\\xb8"] = true,
					action = str,
					score = scoreFormatter(action.Score),
					seat = targets[j] ~= game.mySeatID and myDisplayName or game:GetSeatName(targets[j])
				}
			end
		end
	elseif action.Score >= 0 then
		views[#views + 1] = {
			["D\\xbd\\x95\\xa6\\xb8"] = true,
			action = str,
			score = scoreFormatter(-1 * action.Score),
			seat = action.Owner ~= game.mySeatID and myDisplayName or game:GetSeatName(action.Owner)
		}
	else
		views[#views + 1] = {
			["D\\xbd\\x95\\xa6\\xb8"] = false,
			action = str,
			score = scoreFormatter(-1 * action.Score),
			seat = action.Owner ~= game.mySeatID and myDisplayName or game:GetSeatName(action.Owner)
		}
	end
end

M.RenderListItem = function(self, btn, csIndex)
	local data = self.actionListData[csIndex + 1]
	local store = self:GetStoreByWidget(btn)
	store.descLabel = data.action
	store.seatLabel = data.seat
	store.scoreLabel = data.score
	store.isWin = data.isWin and self.isWinEnum._true or self.isWinEnum._false
end

M.DefineAllEnumsAutoGen = function(self)
	self.isWinEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isWinEnum = nil
end

M.OnDestroy = function(self)
	self.isRank = nil
	self.actionListData = nil
end
