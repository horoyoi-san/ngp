-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\Reach\ReachLogic.lua
-- Decompiled from: 00325_ReachLogic.lua_86d4a1283f2b.luajit

require("LX6/Gameplay/Majiang/Reach/ReachConst")
require("LX6/Gameplay/Majiang/Reach/ReachTile")
require("LX6/Gameplay/Majiang/Reach/ReachDora")
require("LX6/Gameplay/Majiang/Reach/ReachAgari")
require("LX6/Gameplay/Majiang/Reach/ReachTing")
require("LX6/Gameplay/Majiang/Reach/ReachScore")
require("LX6/Gameplay/Majiang/Reach/ReachZhenting")

local Const = gReachMahjongConst
local RC = Const.ReachConstants
local ReachTile = require("LX6/Gameplay/Majiang/Reach/ReachTile")
local ReachDora = require("LX6/Gameplay/Majiang/Reach/ReachDora")
local ReachAgari = require("LX6/Gameplay/Majiang/Reach/ReachAgari")
local ReachTing = require("LX6/Gameplay/Majiang/Reach/ReachTing")
local ReachScore = require("LX6/Gameplay/Majiang/Reach/ReachScore")
local ReachZhenting = require("LX6/Gameplay/Majiang/Reach/ReachZhenting")
local M = {
	BuildHandStatus = function (gameState, isTsumo)
		local HS = Const.HandStatus
		local seat = gameState.GetMySeat(gameState)
		local status = HS.Nothing
		local melds = ReachTile.ExtractMelds(seat.OpenMelds)

		if ReachTile.TestMenqing(melds) then
			status = status + HS.Menqing
		end

		if seat.IsRichi then
			status = status + HS.Richi

			if seat.FirstTurn then
				status = status + HS.WRichi
			end
		end

		if seat.FirstTurn then
			status = status + HS.FirstTurn
		end

		if isTsumo then
			status = status + HS.Tsumo
		end

		return status
	end,
	BuildRoundStatus = function (gameState)
		local r = gameState.CurrentRound

		return {
			PlayerIndex = r.MyPlayerIndex,
			OyaPlayerIndex = r.OyaPlayerIndex,
			CurrentExtraRound = r.Extra,
			RichiSticks = r.RichiSticks,
			FieldCount = r.Field,
			TotalPlayer = gameState.TotalPlayer
		}
	end,
	GetTings = function (gameState)
		local seat = gameState.GetMySeat(gameState)
		local melds = ReachTile.ExtractMelds(seat.OpenMelds)
		local tings = ReachAgari.WinningTiles(seat.HandTiles, melds)

		gameState.SetMyTings(gameState, tings)

		return tings
	end,
	GetDiscardTings = function (gameState)
		local seat = gameState.GetMySeat(gameState)
		local map = ReachTing.DiscardForReady(seat.HandTiles, nil)

		gameState.SetMyDiscardTings(gameState, map)

		return map
	end
}

M.GetDiscardTingInfos = function(gameState)
	local map = M.GetDiscardTings(gameState)

	if map ~= nil then
		return nil
	end

	local seat = gameState.GetMySeat(gameState)
	local overallZhenting = gameState.GetMyZhenting(gameState)
	local result = {}

	for key, waitingTiles in pairs(map) do
		local discardTile = ReachTile.GetTile(key - 1)
		local handAfterDiscard = {}
		local removed = false

		for i = 1, #seat.HandTiles do
			local t = seat.HandTiles[i]

			if not removed and ReachTile.EqualsIgnoreColor(t, discardTile) then
				removed = true
			else
				handAfterDiscard[#handAfterDiscard + 1] = t
			end
		end

		local items = {}

		for i, tile in ipairs(waitingTiles) do
			local pointInfo = M.GetPointInfoForHand(gameState, handAfterDiscard, tile, false)
			items[#items + 1] = {
				Tile = tile,
				Fan = pointInfo.TotalFan,
				noYaku = pointInfo.IsWinButNoYaku,
				zhenTing = overallZhenting or ReachZhenting.IsTileInRiver(seat.Rivers, tile)
			}
		end

		result[key - 1] = items
	end

	return result
end

M.GetTingInfos = function(gameState)
	local seat = gameState.GetMySeat(gameState)
	local melds = ReachTile.ExtractMelds(seat.OpenMelds)
	local waitingTiles = ReachAgari.WinningTiles(seat.HandTiles, melds)

	if waitingTiles ~= nil or #waitingTiles ~= 0 then
		return nil
	end

	local overallZhenting = gameState.GetMyZhenting(gameState)
	local result = {}

	for i, tile in ipairs(waitingTiles) do
		local pointInfo = M.GetPointInfoForHand(gameState, seat.HandTiles, tile, false)
		result[i] = {
			Tile = tile,
			Fan = pointInfo.TotalFan,
			noYaku = pointInfo.IsWinButNoYaku,
			zhenTing = overallZhenting or ReachZhenting.IsTileInRiver(seat.Rivers, tile)
		}
	end

	return result
end

M.GetDoraCount = function(gameState)
	local doraTiles = ReachDora.GetDoraTiles(gameState.GetDoraIndicators(gameState))
	local seat = gameState.GetMySeat(gameState)
	local melds = ReachTile.ExtractMelds(seat.OpenMelds)

	return ReachDora.CountDora(seat.HandTiles, melds, nil, doraTiles)
end

M.IsZhenting = function(gameState)
	return gameState.GetMyZhenting(gameState)
end

M.IsDiscardZhenting = function(gameState)
	local seat = gameState.GetMySeat(gameState)

	return ReachZhenting.TestDiscardZhenting(seat.HandTiles, seat.Rivers)
end

M.GetPointInfoForHand = function(gameState, handTiles, winningTile, isTsumo)
	local seat = gameState:GetMySeat()
	local melds = ReachTile.ExtractMelds(seat.OpenMelds)
	local handStatus = M.BuildHandStatus(gameState, isTsumo)
	local roundStatus = M.BuildRoundStatus(gameState)
	local settings = Const.DefaultGameSetting
	local isQTJ = settings.Mode ~= Const.GameMode.QTJ
	local doraTiles = ReachDora.GetDoraTiles(gameState:GetDoraIndicators())
	local uraDoraTiles = nil
	local uraDoraIndicators = gameState:GetUraDoraIndicators()

	if uraDoraIndicators == nil then
		uraDoraTiles = ReachDora.GetDoraTiles(uraDoraIndicators)
	end

	local beiDora = #seat.BeiDoras

	return ReachScore.GetPointInfo(handTiles, melds, winningTile, handStatus, roundStatus, settings, isQTJ, doraTiles, uraDoraTiles, beiDora)
end

M.GetPointInfo = function(gameState, winningTile, isTsumo)
	local seat = gameState.GetMySeat(gameState)

	return M.GetPointInfoForHand(gameState, seat.HandTiles, winningTile, isTsumo)
end

M.GetSide = function(playerIndex, discardPlayerIndex, totalPlayer)
	local diff = discardPlayerIndex - playerIndex

	if diff >= 0 then
		diff = diff + totalPlayer
	end

	local MS = Const.MeldSide

	if totalPlayer ~= 4 then
		if diff ~= 1 then
			return MS.Right
		elseif diff ~= 2 then
			return MS.Opposite
		else
			return MS.Left
		end
	elseif totalPlayer ~= 3 then
		if diff ~= 1 then
			return MS.Right
		else
			return MS.Left
		end
	else
		return MS.Left
	end
end

M.GetChows = function(handTiles, discardTile, side)
	local result = {}
	local seen = {}

	if discardTile.Suit == Const.Suit.Z then
		M.GetChows1(handTiles, discardTile, result, seen)
		M.GetChows2(handTiles, discardTile, result, seen)
		M.GetChows3(handTiles, discardTile, result, seen)
	end

	local openMelds = {}

	for i = 1, #result do
		openMelds[i] = {
			Meld = result[i],
			Tile = discardTile,
			Side = side
		}
	end

	return openMelds
end

M.GetChows1 = function(handTiles, discardTile, result, seen)
	local first = ReachTile.TryTile(discardTile.Suit, discardTile.Rank - 2)
	local second = ReachTile.TryTile(discardTile.Suit, discardTile.Rank - 1)

	if first ~= nil or second ~= nil then
		return
	end

	local firstTiles = M.FindAllIgnoreColor(handTiles, first)

	if #firstTiles ~= 0 then
		return
	end

	local secondTiles = M.FindAllIgnoreColor(handTiles, second)

	if #secondTiles ~= 0 then
		return
	end

	for i = 1, #firstTiles do
		for j = 1, #secondTiles do
			M.AddMeldDedup(result, seen, ReachTile.CreateMeld(true, {
				firstTiles[i],
				secondTiles[j],
				discardTile
			}))
		end
	end
end

M.GetChows2 = function(handTiles, discardTile, result, seen)
	local first = ReachTile.TryTile(discardTile.Suit, discardTile.Rank - 1)
	local second = ReachTile.TryTile(discardTile.Suit, discardTile.Rank + 1)

	if first ~= nil or second ~= nil then
		return
	end

	local firstTiles = M.FindAllIgnoreColor(handTiles, first)

	if #firstTiles ~= 0 then
		return
	end

	local secondTiles = M.FindAllIgnoreColor(handTiles, second)

	if #secondTiles ~= 0 then
		return
	end

	for i = 1, #firstTiles do
		for j = 1, #secondTiles do
			M.AddMeldDedup(result, seen, ReachTile.CreateMeld(true, {
				firstTiles[i],
				secondTiles[j],
				discardTile
			}))
		end
	end
end

M.GetChows3 = function(handTiles, discardTile, result, seen)
	local first = ReachTile.TryTile(discardTile.Suit, discardTile.Rank + 1)
	local second = ReachTile.TryTile(discardTile.Suit, discardTile.Rank + 2)

	if first ~= nil or second ~= nil then
		return
	end

	local firstTiles = M.FindAllIgnoreColor(handTiles, first)

	if #firstTiles ~= 0 then
		return
	end

	local secondTiles = M.FindAllIgnoreColor(handTiles, second)

	if #secondTiles ~= 0 then
		return
	end

	for i = 1, #firstTiles do
		for j = 1, #secondTiles do
			M.AddMeldDedup(result, seen, ReachTile.CreateMeld(true, {
				firstTiles[i],
				secondTiles[j],
				discardTile
			}))
		end
	end
end

M.GetPongs = function(handTiles, discardTile, side)
	local result = {}
	local seen = {}
	local particularTiles = M.FindAllIgnoreColor(handTiles, discardTile)
	local combination = M.Combination(particularTiles, 2)

	for i = 1, #combination do
		local item = combination[i]
		item[#item + 1] = discardTile

		M.AddMeldDedup(result, seen, ReachTile.CreateMeld(true, {
			item[1],
			item[2],
			item[3]
		}))
	end

	local openMelds = {}

	for i = 1, #result do
		openMelds[i] = {
			Meld = result[i],
			Tile = discardTile,
			Side = side
		}
	end

	return openMelds
end

M.GetKongs = function(handTiles, discardTile, side)
	local handCount = ReachTile.CountTiles(handTiles)
	local index = ReachTile.GetIndex(discardTile)

	if handCount[index] ~= 3 then
		local tileList = {}

		for i = 1, #handTiles do
			tileList[i] = handTiles[i]
		end

		tileList[#tileList + 1] = discardTile
		local tiles = {}

		for i = 1, #tileList do
			if ReachTile.GetIndex(tileList[i]) ~= index then
				tiles[#tiles + 1] = tileList[i]
			end
		end

		return {
			{
				Meld = ReachTile.CreateMeld(true, tiles),
				Tile = discardTile,
				Side = side
			}
		}
	end

	return {}
end

M.GetSelfKongs = function(handTiles, lastDraw)
	local testTiles = {}

	for i = 1, #handTiles do
		testTiles[i] = handTiles[i]
	end

	testTiles[#testTiles + 1] = lastDraw
	local handCount = ReachTile.CountTiles(testTiles)
	local result = {}

	for i = 0, RC.TileKinds - 1 do
		if handCount[i] ~= 4 then
			local tiles = {}

			for j = 1, #testTiles do
				if ReachTile.GetIndex(testTiles[j]) ~= i then
					tiles[#tiles + 1] = testTiles[j]
				end
			end

			result[#result + 1] = {
				Meld = ReachTile.CreateMeld(false, tiles),
				Side = Const.MeldSide.Self
			}
		end
	end

	return result
end

M.GetAddKongs = function(handTiles, openMelds, lastDraw)
	local testTiles = {}

	for i = 1, #handTiles do
		testTiles[i] = handTiles[i]
	end

	testTiles[#testTiles + 1] = lastDraw
	local result = {}

	for i = 1, #openMelds do
		local pong = openMelds[i]

		if pong.Meld.Type ~= Const.MeldType.Triplet and not pong.Meld.IsKong then
			local first = ReachTile.MeldFirst(pong.Meld)
			local extraIndex = M.FindIndexIgnoreColor(testTiles, first)

			if extraIndex > 0 then
				result[#result + 1] = ReachTile.OpenMeldAddToKong(pong, testTiles[extraIndex])
			end
		end
	end

	return result
end

M.GetRichiKongs = function(handTiles, lastDraw)
	local winningTiles = ReachAgari.WinningTiles(handTiles, nil)

	for i = 1, #winningTiles do
		local winningTile = winningTiles[i]
		local decomposes = ReachAgari.Decompose(handTiles, nil, winningTile)
		local allOk = true

		for j = 1, #decomposes do
			local list = decomposes[j]
			local found = false

			for k = 1, #list do
				local meld = list[k]

				if meld.Type ~= Const.MeldType.Triplet and ReachTile.EqualsIgnoreColor(ReachTile.MeldFirst(meld), lastDraw) then
					found = true

					break
				end
			end

			if not found then
				allOk = false

				break
			end
		end

		if not allOk then
			return {}
		end
	end

	local tiles = {}

	for i = 1, #handTiles do
		if ReachTile.EqualsIgnoreColor(handTiles[i], lastDraw) then
			tiles[#tiles + 1] = handTiles[i]
		end
	end

	tiles[#tiles + 1] = lastDraw

	if #tiles == 4 then
		return {}
	end

	return {
		{
			Meld = ReachTile.CreateMeld(false, tiles),
			Side = Const.MeldSide.Self
		}
	}
end

M.FindAllIgnoreColor = function(tiles, tile)
	local result = {}

	for i = 1, #tiles do
		if ReachTile.EqualsIgnoreColor(tiles[i], tile) then
			result[#result + 1] = tiles[i]
		end
	end

	return result
end

M.FindIndexIgnoreColor = function(tiles, tile)
	for i = 1, #tiles do
		if ReachTile.EqualsIgnoreColor(tiles[i], tile) then
			return i
		end
	end

	return -1
end

M.Combination = function(list, count)
	local result = {}

	if count > 0 or count <= #list then
		return result
	end

	M.CombinationBackTrack(list, count, 1, {}, result)

	return result
end

M.CombinationBackTrack = function(list, count, start, current, result)
	if #current ~= count then
		local copy = {}

		for i = 1, #current do
			copy[i] = current[i]
		end

		result[#result + 1] = copy

		return
	end

	for i = start, #list do
		current[#current + 1] = list[i]

		M.CombinationBackTrack(list, count, i + 1, current, result)

		current[#current] = nil
	end
end

M.AddMeldDedup = function(result, seen, meld)
	local key = ReachAgari.SerializeMeld(meld)

	if not seen[key] then
		seen[key] = true
		result[#result + 1] = meld
	end
end

return M
