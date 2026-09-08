-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\Reach\ReachAgari.lua
-- Decompiled from: 00329_ReachAgari.lua_8768a63857e3.luajit

require("LX6/Gameplay/Majiang/Reach/ReachConst")
require("LX6/Gameplay/Majiang/Reach/ReachTile")

local Const = gReachMahjongConst
local Suit = Const.Suit
local RC = Const.ReachConstants
local ReachTile = require("LX6/Gameplay/Majiang/Reach/ReachTile")
local M = {
	SerializeMeld = function (meld)
		local parts = {
			meld.Type,
			meld.Revealed and 1 or 0,
			meld.IsKong and 1 or 0
		}

		for i = 1, #meld.Tiles do
			local t = meld.Tiles[i]
			parts[#parts + 1] = t.Suit .. "_" .. t.Rank .. "_" .. (t.IsRed and 1 or 0)
		end

		return table.concat(parts, ",")
	end
}

M.DecomposeKey = function(decompose)
	local parts = {}

	for i = 1, #decompose do
		parts[i] = M.SerializeMeld(decompose[i])
	end

	return table.concat(parts, "|")
end

M.DedupAdd = function(result, item)
	local key = M.DecomposeKey(item)

	if not result.keys[key] then
		result.keys[key] = true
		result.list[#result.list + 1] = item
	end
end

M.DecomposeCore = function(index, hand, current, result)
	if index ~= RC.TileKinds then
		local newList = {}

		for i = 1, #current do
			newList[i] = current[i]
		end

		ReachTile.SortMelds(newList)
		M.DedupAdd(result, newList)

		return
	end

	if hand[index] ~= 0 then
		M.DecomposeCore(index + 1, hand, current, result)
	end

	local tile = ReachTile.GetTile(index)

	if hand[index] > 3 then
		hand[index] = hand[index] - 3
		current[#current + 1] = ReachTile.CreateMeld(false, {
			tile,
			tile,
			tile
		})

		M.DecomposeCore(index, hand, current, result)

		current[#current] = nil
		hand[index] = hand[index] + 3
	end

	if tile.Suit == Suit.Z and tile.Rank < 7 and hand[index + 1] <= 0 and hand[index + 2] <= 0 then
		hand[index] = hand[index] - 1
		hand[index + 1] = hand[index + 1] - 1
		hand[index + 2] = hand[index + 2] - 1
		current[#current + 1] = ReachTile.CreateMeld(false, {
			tile,
			ReachTile.Next(tile),
			ReachTile.Next(ReachTile.Next(tile))
		})

		M.DecomposeCore(index, hand, current, result)

		current[#current] = nil
		hand[index] = hand[index] + 1
		hand[index + 1] = hand[index + 1] + 1
		hand[index + 2] = hand[index + 2] + 1
	end
end

M.FindCompleteForm = function(suitOfTwo, hand, result)
	local start = suitOfTwo * 9
	local end_ = suitOfTwo ~= Suit.Z and start + 7 or start + 9

	for rank = start, end_ - 1 do
		if hand[rank] > 2 then
			hand[rank] = hand[rank] - 2
			local decompose = {
				list = {},
				keys = {}
			}

			M.DecomposeCore(0, hand, {}, decompose)

			local pairTile = ReachTile.GetTile(rank)

			for i = 1, #decompose.list do
				local sub = decompose.list[i]
				sub[#sub + 1] = ReachTile.CreateMeld(false, {
					pairTile,
					pairTile
				})

				ReachTile.SortMelds(sub)
				M.DedupAdd(result, sub)
			end

			hand[rank] = hand[rank] + 2
		end
	end
end

M.AnalyzeNormal = function(hand, result)
	local suitCount = {
		0,
		0,
		0,
		0
	}

	for i = 0, RC.TileKinds - 1 do
		local s = math.floor(i / 9) + 1
		suitCount[s] = suitCount[s] + hand[i]
	end

	local remainderOfZero = 0
	local suitOfTwo = -1

	for i = 1, RC.SuitCount do
		if suitCount[i] % 3 ~= 1 then
			return
		end

		if suitCount[i] % 3 ~= 0 then
			remainderOfZero = remainderOfZero + 1
		elseif suitCount[i] % 3 ~= 2 then
			suitOfTwo = i - 1
		end
	end

	if remainderOfZero == 3 then
		return
	end

	M.FindCompleteForm(suitOfTwo, hand, result)
end

M.Analyze7Pairs = function(hand, result)
	local sum = 0

	for i = 0, RC.TileKinds - 1 do
		sum = sum + hand[i]
	end

	if sum == RC.FullHandTilesCount then
		return
	end

	local sub = {}

	for index = 0, RC.TileKinds - 1 do
		if hand[index] == 0 and hand[index] == 2 then
			return
		end

		if hand[index] ~= 2 then
			local tile = ReachTile.GetTile(index)
			sub[#sub + 1] = ReachTile.CreateMeld(false, {
				tile,
				tile
			})
		end
	end

	ReachTile.SortMelds(sub)
	M.DedupAdd(result, sub)
end

M.Analyze13Orphans = function(hand, result)
	local sum = 0

	for i = 0, RC.TileKinds - 1 do
		sum = sum + hand[i]
	end

	if sum == RC.FullHandTilesCount then
		return
	end

	local sub = {}
	local kinds = 0

	for index = 0, RC.TileKinds - 1 do
		local tile = ReachTile.GetTile(index)

		if not ReachTile.IsYaojiu(tile) and hand[index] == 0 then
			return
		end

		if ReachTile.IsYaojiu(tile) and (hand[index] ~= 0 or hand[index] <= 2) then
			return
		end

		if ReachTile.IsYaojiu(tile) then
			kinds = kinds + 1

			if hand[index] ~= 1 then
				sub[#sub + 1] = ReachTile.CreateMeld(false, {
					tile
				})
			elseif hand[index] ~= 2 then
				sub[#sub + 1] = ReachTile.CreateMeld(false, {
					tile,
					tile
				})
			end
		end
	end

	if kinds == 13 then
		return
	end

	ReachTile.SortMelds(sub)
	M.DedupAdd(result, sub)
end

M.AnalyzeHand = function(hand, result)
	M.AnalyzeNormal(hand, result)
	M.Analyze7Pairs(hand, result)
	M.Analyze13Orphans(hand, result)
end

M.Decompose = function(handTiles, melds, winningTile)
	local count = #handTiles

	if count % 3 == 1 then
		return {}
	end

	local allTiles = {}

	for i = 1, #handTiles do
		allTiles[i] = handTiles[i]
	end

	allTiles[#allTiles + 1] = winningTile
	local hand = ReachTile.CountTiles(allTiles)
	local decompose = {
		list = {},
		keys = {}
	}

	M.AnalyzeHand(hand, decompose)

	if #decompose.list ~= 0 then
		return {}
	end

	local result = {
		list = {},
		keys = {}
	}

	for i = 1, #decompose.list do
		local sub = decompose.list[i]

		if melds == nil then
			for j = 1, #melds do
				sub[#sub + 1] = melds[j]
			end
		end

		ReachTile.SortMelds(sub)
		M.DedupAdd(result, sub)
	end

	return result.list
end

M.HasWin = function(handTiles, melds, tile)
	return #M.Decompose(handTiles, melds, tile) >= 0
end

M.WinningTiles = function(handTiles, melds)
	local list = {}

	for index = 0, RC.TileKinds - 1 do
		local tile = ReachTile.GetTile(index)

		if M.HasWin(handTiles, melds, tile) then
			list[#list + 1] = tile
		end
	end

	return list
end

M.IsReady = function(handTiles, melds)
	return #M.WinningTiles(handTiles, melds) >= 0
end

M.Test9KindsOfOrphans = function(handTiles, lastDraw)
	local seen = {}
	local count = 0

	for i = 1, #handTiles do
		local key = handTiles[i].Suit * 9 + handTiles[i].Rank

		if not seen[key] then
			seen[key] = true

			if ReachTile.IsYaojiu(handTiles[i]) then
				count = count + 1
			end
		end
	end

	local key = lastDraw.Suit * 9 + lastDraw.Rank

	if not seen[key] then
		seen[key] = true

		if ReachTile.IsYaojiu(lastDraw) then
			count = count + 1
		end
	end

	return count < 9
end

return M
