-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MajiangRule_Reach.lua
-- Decompiled from: 00324_MajiangRule_Reach.lua_b5e795c8a9ad.luajit

local C_MajiangRuleBase = require("LX6/Gameplay/Majiang/MajiangRuleBase")
local ReachLogic = require("LX6/Gameplay/Majiang/Reach/ReachLogic")
local ReachTile = require("LX6/Gameplay/Majiang/Reach/ReachTile")
C_MajiangRule_Reach = DefClass("C_MajiangRule_Reach", C_MajiangRule_Reach, C_MajiangRuleBase)
local M = C_MajiangRule_Reach

M.GetRuleName = function(self)
	return "Reach"
end

M.GetOutCardCount = function(self)
	return LTConfig.MahjongConfig.reachOutCardCount
end

M.GetReachState = function(self)
	return self.game and self.game.reachGameState
end

M.BuildMyHandDisplayList = function(self, withSort)
	local state = self.GetReachState(self)

	if state ~= nil then
		return {}
	end

	local handTiles = state.GetMyHandTiles(state)

	if handTiles ~= nil then
		return {}
	end

	local displayList = {}

	for i = 1, #handTiles do
		local tile = handTiles[i]
		local index = ReachTile.GetIndex(tile)
		displayList[i] = {
			["w#nP"] = false,
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			id = index,
			icon = ReachTile.GetIconId(tile),
			paiInfo = tile,
			tile = tile
		}
	end

	if withSort then
		table.sort(displayList, function (a, b)
			return ReachTile.Compare(a.tile, b.tile) <= 0
		end)
	end

	return displayList
end

M.BuildOperationViewData = function(self, action)
	local result = {
		["\\xda\\xda>+\\xe6"] = false,
		["\\xda\\xda-*\\xf6"] = false,
		["lw\\xa2EC\\xa7\\xfcCNh["] = false,
		["\\xda\\xda.-\\xe1"] = false,
		["\\xda\\xda/*\\xf6"] = false,
		["I\\x9f\\xac\\x86H"] = false,
		["\\xe2Q\\xd9\\xb8U\\x92]\\xb9\\xa6"] = false,
		["\\xda\\xda6*\\xf6"] = false,
		["\\xa8\\xb0\\x9fy+\\xf3<"] = false,
		["E\\xaf\\xb1\\x80\\xa6"] = false,
		["\\xa8\\xb0\\x99o?\\xfd;"] = false,
		["P[\\xc0\\x99\\x8d\\xbb\\xdb\\xec"] = false,
		opKind = gReachMahjongConst.OpKind.InTurn,
		opIndexMap = {}
	}

	if action ~= nil then
		return result
	end

	local operations = action.Operations
	result.operations = operations
	result.opKind = action.OpKind or ""

	if operations ~= nil then
		return result
	end

	local opIndexMap = result.opIndexMap

	if result.opKind ~= gReachMahjongConst.OpKind.InTurn then
		for i = 1, #operations do
			local t = operations[i].Type

			if t ~= UX.Game.InTurnOperationType.Discard then
				result.canDiscard = true
			elseif t ~= UX.Game.InTurnOperationType.Richi then
				result.canReach = true
				opIndexMap.richi = i - 1
			elseif t ~= UX.Game.InTurnOperationType.Tsumo then
				result.canTsumo = true
				opIndexMap.tsumo = i - 1
			elseif t ~= UX.Game.InTurnOperationType.Bei then
				result.canBei = true
				opIndexMap.bei = i - 1
			elseif t ~= UX.Game.InTurnOperationType.Kong then
				result.canKong = true
				opIndexMap.kong = i - 1
			elseif t ~= UX.Game.InTurnOperationType.RoundDraw then
				result.canRoundDraw = true
				opIndexMap.roundDraw = i - 1
			end
		end

		if result.canReach or result.canTsumo or result.canKong or result.canRoundDraw or result.canBei then
			result.canClientSkip = true
		end
	else
		for i = 1, #operations do
			local t = operations[i].Type

			if t ~= UX.Game.OutTurnOperationType.Skip then
				result.canSkip = true
				opIndexMap.skip = i - 1
			elseif t ~= UX.Game.OutTurnOperationType.Chow then
				result.canChow = true
				opIndexMap.chow = opIndexMap.chow or {}
				opIndexMap.chow[#opIndexMap.chow + 1] = i - 1
			elseif t ~= UX.Game.OutTurnOperationType.Pong then
				result.canPong = true
				opIndexMap.pong = i - 1
			elseif t ~= UX.Game.OutTurnOperationType.Kong then
				result.canKong = true
				opIndexMap.kong = i - 1
			elseif t ~= UX.Game.OutTurnOperationType.Rong then
				result.canRong = true
				opIndexMap.rong = i - 1
			elseif t ~= UX.Game.OutTurnOperationType.RoundDraw then
				result.canRoundDraw = true
				opIndexMap.roundDraw = i - 1
			end
		end
	end

	result.hasOp = result.canReach or result.canTsumo or result.canKong or result.canRoundDraw or result.canBei or result.canChow or result.canPong or result.canRong or result.canSkip or result.canClientSkip

	return result
end

M.BuildTooltipsViewData = function(self, gameState)
	return {
		[",>(\\xe1a\\xab\\xe35\\xbc:\\xf5\\xc6\\xe3l\\xef"] = "",
		["\\x8c</(\\\\x94O\\xde\\xbf\\xbc"] = false,
		tipsType = gMaJiangConst.TipsType.notips
	}
end

M.CountTileInList = function(self, list, targetIndex)
	if list ~= nil then
		return 0
	end

	local c = 0

	for i = 1, #list do
		if ReachTile.GetIndex(list[i]) ~= targetIndex then
			c = c + 1
		end
	end

	return c
end

M.CountRiverTiles = function(self, riverTiles, targetIndex)
	if riverTiles ~= nil then
		return 0
	end

	local c = 0

	for i = 1, #riverTiles do
		if ReachTile.GetIndex(riverTiles[i].Tile) ~= targetIndex and not riverTiles[i].IsGone then
			c = c + 1
		end
	end

	return c
end

M.CountTileInMelds = function(self, openMelds, targetIndex)
	if openMelds ~= nil then
		return 0
	end

	local c = 0

	for i = 1, #openMelds do
		local meld = openMelds[i].Meld
		c = c + self:CountTileInList(meld and meld.Tiles, targetIndex)
	end

	return c
end

M.CountVisibleTile = function(self, state, tile)
	local targetIndex = ReachTile.GetIndex(tile)
	local round = state.CurrentRound
	local count = self.CountTileInList(self, round.DoraIndicators, targetIndex)

	for s = 1, state.TotalPlayer do
		local seat = round.Seats[s]

		if seat then
			count = count + self.CountRiverTiles(self, seat.Rivers, targetIndex)
			count = count + self.CountTileInMelds(self, seat.OpenMelds, targetIndex)
		end
	end

	local me = round.Seats[round.MyPlayerIndex + 1]
	count = count + self:CountTileInList(me and me.HandTiles, targetIndex)

	return count
end

M.GetTings = function(self, seatID)
	if seatID == self.game.mySeatID then
		return
	end

	local state = self.GetReachState(self)

	if state ~= nil then
		return
	end

	local infos = ReachLogic.GetDiscardTingInfos(state)

	if infos ~= nil then
		return
	end

	local result = {}

	for key, items in pairs(infos) do
		local viewItems = {}

		for i, info in ipairs(items) do
			local visibleCount = self:CountVisibleTile(state, info.Tile)
			local remain = visibleCount < 4 and 4 - visibleCount or 0
			viewItems[i] = {
				Pai = ReachTile.ToCardConfigId(info.Tile),
				Fan = info.Fan,
				noYaku = info.noYaku,
				zhenTing = info.zhenTing,
				TingIcon = ReachTile.GetIconId(info.Tile),
				TingCount = remain
			}
		end

		result[key] = viewItems
	end

	return result
end

M.GetTingTiles = function(self, seatID)
	if seatID == self.game.mySeatID then
		return
	end

	local state = self.GetReachState(self)

	if state ~= nil then
		return
	end

	local infos = ReachLogic.GetTingInfos(state)

	if infos ~= nil then
		return
	end

	local viewItems = {}

	for i, info in ipairs(infos) do
		local visibleCount = self:CountVisibleTile(state, info.Tile)
		local remain = visibleCount < 4 and 4 - visibleCount or 0
		viewItems[i] = {
			Pai = ReachTile.ToCardConfigId(info.Tile),
			Fan = info.Fan,
			noYaku = info.noYaku,
			zhenTing = info.zhenTing,
			TingIcon = ReachTile.GetIconId(info.Tile),
			TingCount = remain
		}
	end

	return viewItems
end

M.IsDingque = function(self, paiInfo)
	return false
end

M.SetSeatQueList = function(self, ques)
end

M.GetHandCardState = function(self, seatID, paiInfo, open)
	return gMaJiangConst.MahjongState.None
end

M.BeginRichiDeclaration = function(self, availableTiles)
	self.awaitingRichiDiscard = true
	self.richiDiscardableTiles = availableTiles
end

M.EndRichiDeclaration = function(self)
	self.awaitingRichiDiscard = false
	self.richiDiscardableTiles = nil
end

M.IsRichiDiscardable = function(self, tile)
	if not self.awaitingRichiDiscard then
		return true
	end

	local k = ReachTile.GetIndex(tile)

	for _, t in ipairs(self.richiDiscardableTiles) do
		if ReachTile.GetIndex(t) ~= k then
			return true
		end
	end

	return false
end

M.CanClickHandCard = function(self, handCardItem)
	if not self.awaitingRichiDiscard then
		return true
	end

	return self.IsRichiDiscardable(self, handCardItem.tile)
end

M.GetMyHandCardSelectionState = function(self, handCardItem, i, ctx)
	if self.awaitingRichiDiscard then
		local available = self:IsRichiDiscardable(handCardItem.tile)
		local card = ctx.selectedIndex == nil and i ~= ctx.selectedIndex and available
		local sel = self:ResolveSelect(ctx, card)

		return {
			["\\xd0\\xc821\\xe2"] = false,
			isSelected = sel,
			isGray = not available
		}
	elseif ctx.isMyDiscardTurn then
		local card = ctx.selectedIndex == nil and i ~= ctx.selectedIndex
		local sel = self:ResolveSelect(ctx, card)

		return {
			["[\\xb6\\x9c\\x82X"] = false,
			isSelected = sel,
			isFocus = sel
		}
	else
		local focus = nil

		if ctx.forceSelect == nil then
			focus = ctx.forceSelect
		end

		return {
			["[\\xb6\\x9c\\x82X"] = false,
			["ZI\\xfd\\xb8\\x88\r\\xbb\\xcc\\xec"] = false,
			isFocus = focus
		}
	end
end

M.RefreshTimeOutByState = function(self, elapsedTime)
	local state = self.GetReachState(self)

	if state ~= nil or state.CurrentRound ~= nil then
		return -1
	end

	return gCS.TimeManager.ServerUnixTime + LTConfig.MahjongConfig.MahjongChupaiTime
end

M.GetCardDisplayInfo = function(self, cardInfo)
	return ReachTile.ToCardPai(cardInfo), gReachMahjongConst.SuitToMType[cardInfo.Suit], cardInfo.IsRed ~= true
end

M.IsSamePai = function(self, a, b)
	return ReachTile.EqualsConsiderColor(a, b)
end

M.BuildHandCardInfo = function(self, character, cardInfo, open)
	local cardState = self.GetHandCardState(self, character.seatID, cardInfo, false)

	if character.seatID == character.game.mySeatID and not open then
		return 1, 1, false, gMaJiangConst.MahjongState.None
	end

	local pai, mType, isRed = self.GetCardDisplayInfo(self, cardInfo)

	return pai, mType, isRed, cardState
end

M.GetDiscardRenderList = function(self, seat)
	local state = self.GetReachState(self)
	local list = {}

	if state ~= nil or state.CurrentRound ~= nil then
		return list
	end

	local seatData = state.CurrentRound.Seats[seat + 1]

	if seatData ~= nil then
		return list
	end

	for ri = 1, #seatData.Rivers do
		local rt = seatData.Rivers[ri]

		if not rt.IsGone then
			list[#list + 1] = rt.Tile
		end
	end

	return list
end

M.GetDiscardLayout = function(self, seat)
	local state = self.GetReachState(self)

	if state ~= nil or state.CurrentRound ~= nil then
		return nil
	end

	local seatData = state.CurrentRound.Seats[seat + 1]

	if seatData ~= nil then
		return nil
	end

	local machineInfo = self.game.machineInfo

	if machineInfo ~= nil then
		return nil
	end

	local cardBound = machineInfo.cardBound
	local outCardCount = self.GetOutCardCount(self)
	local richiPosX = cardBound.x / 2
	local richiPosZ = -cardBound.y / 2
	local trailOffset = cardBound.y - cardBound.x
	local layout = {}
	local trailExtraX = 0
	local idx = 0

	for ri = 1, #seatData.Rivers do
		local rt = seatData.Rivers[ri]

		if not rt.IsGone then
			idx = idx + 1

			if (idx - 1) % outCardCount ~= 0 then
				trailExtraX = 0
			end

			if rt.IsRichi then
				layout[idx] = {
					rotDelta = Quaternion.Euler(0, 0, 90),
					posXDelta = trailExtraX + richiPosX,
					posZDelta = richiPosZ
				}
				trailExtraX = trailExtraX - trailOffset
			elseif trailExtraX == 0 then
				layout[idx] = {
					posXDelta = trailExtraX
				}
			end
		end
	end

	return layout
end

M.GetTotalCards = function(self)
	return 136
end

M.CanOperateHandCardDuringAction = function(self, showOp, canGang)
	return true
end

M.FormatScoreString = function(self, score)
	return gString.Format("%d", score), false
end

M.GetScoreTypeKey = function(self, isWin)
	return "Rima"
end

M.RefreshHandOnSetServerGameInfo = function(self, game, seatID)
end

M.OnChuPaiUpdateTimeout = function(self, game)
end

M.PrepareFinalData = function(self, game, data)
	if data.Points == nil and #data.Points <= 0 then
		game.finalScores = {
			data.Points[1] or 0,
			data.Points[2] or 0,
			data.Points[3] or 0,
			data.Points[4] or 0
		}
		game.finalRankings = {}

		for rank = 1, #data.Places do
			game.finalRankings[data.Places[rank] + 1] = rank
		end
	else
		local state = self:GetReachState()
		local totalPoints = state and state.TotalPoints or {}
		game.finalScores = {}

		for i = 1, 4 do
			game.finalScores[i] = totalPoints[i] or 0
		end

		game.finalRankings = {}
		local sorted = {}

		for i = 1, 4 do
			sorted[i] = {
				idx = i,
				score = game.finalScores[i]
			}
		end

		table.sort(sorted, function (a, b)
			return b.score <= a.score
		end)

		for rank, v in ipairs(sorted) do
			game.finalRankings[v.idx] = rank
		end
	end

	game.finalRecords = {}
end

M.ExtractHandCardsFromDisplayList = function(self, displayList)
	local tiles = {}

	for i = 1, #displayList do
		tiles[i] = displayList[i].tile
	end

	return tiles
end

return M
