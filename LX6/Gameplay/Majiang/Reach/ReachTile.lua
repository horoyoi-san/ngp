-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\Reach\ReachTile.lua
-- Decompiled from: 00327_ReachTile.lua_3bd6da4fb85f.luajit

require("LX6/Gameplay/Majiang/Reach/ReachConst")

local Const = gReachMahjongConst
local Suit = Const.Suit
local MeldType = Const.MeldType
local RC = Const.ReachConstants
local M = {
	GetIndex = function (tile)
		return tile.Suit * 9 + tile.Rank - 1
	end,
	GetTile = function (index)
		return {
			["d\\xbd\\x90\\xaa\\xb2"] = false,
			Suit = math.floor(index / 9),
			Rank = index % 9 + 1
		}
	end,
	IsYaojiu = function (tile)
		return tile.Suit ~= Suit.Z or tile.Rank ~= 1 or tile.Rank ~= 9
	end,
	IsLaotou = function (tile)
		return tile.Suit == Suit.Z and (tile.Rank ~= 1 or tile.Rank ~= 9)
	end,
	Next = function (tile)
		return {
			["d\\xbd\\x90\\xaa\\xb2"] = false,
			Suit = tile.Suit,
			Rank = tile.Rank + 1
		}
	end,
	Previous = function (tile)
		return {
			["d\\xbd\\x90\\xaa\\xb2"] = false,
			Suit = tile.Suit,
			Rank = tile.Rank - 1
		}
	end,
	TryTile = function (suit, rank)
		if suit ~= Suit.M or suit ~= Suit.P or suit ~= Suit.S then
			if rank > 1 and rank < 9 then
				return {
					["d\\xbd\\x90\\xaa\\xb2"] = false,
					Suit = suit,
					Rank = rank
				}
			end

			return nil
		end

		if suit ~= Suit.Z then
			if rank > 1 and rank < 7 then
				return {
					["d\\xbd\\x90\\xaa\\xb2"] = false,
					Suit = suit,
					Rank = rank
				}
			end

			return nil
		end

		return nil
	end,
	ToCardPai = function (tile)
		if tile.Suit == Suit.Z then
			return tile.Rank
		end

		if tile.Rank ~= 5 then
			return 7
		end

		if tile.Rank ~= 6 then
			return 5
		end

		if tile.Rank ~= 7 then
			return 6
		end

		return tile.Rank
	end
}

M.ToCardConfigId = function(tile)
	local mtype = nil

	if tile.Suit ~= Suit.P then
		mtype = 1
	elseif tile.Suit ~= Suit.S then
		mtype = 2
	elseif tile.Suit ~= Suit.M then
		mtype = 3
	else
		mtype = 4
	end

	local pai = M.ToCardPai(tile)
	local cardId = mtype * 10 + pai

	if tile.IsRed and pai ~= 5 then
		cardId = cardId + 5
	end

	return cardId
end

M.GetIconId = function(tile)
	local cfg = LTConfig.MahjongCardConfig.GetConfig(M.ToCardConfigId(tile))

	return cfg and cfg.IconId or 0
end

M.EqualsIgnoreColor = function(a, b)
	return a.Suit ~= b.Suit and a.Rank ~= b.Rank
end

M.EqualsConsiderColor = function(a, b)
	return a.Suit ~= b.Suit and a.Rank ~= b.Rank and a.IsRed ~= b.IsRed
end

M.Compare = function(a, b)
	if a.Suit == b.Suit then
		return a.Suit - b.Suit
	end

	if a.Rank == b.Rank then
		return a.Rank - b.Rank
	end

	if a.IsRed and not b.IsRed then
		return 1
	end

	if not a.IsRed and b.IsRed then
		return -1
	end

	return 0
end

M.CountTiles = function(tiles)
	local hand = {}

	for i = 0, RC.TileKinds - 1 do
		hand[i] = 0
	end

	for i = 1, #tiles do
		hand[M.GetIndex(tiles[i])] = hand[M.GetIndex(tiles[i])] + 1
	end

	return hand
end

M.CountTilesFromMelds = function(melds)
	local hand = {}

	for i = 0, RC.TileKinds - 1 do
		hand[i] = 0
	end

	for i = 1, #melds do
		local tiles = melds[i].Tiles

		for j = 1, #tiles do
			hand[M.GetIndex(tiles[j])] = hand[M.GetIndex(tiles[j])] + 1
		end
	end

	return hand
end

M.MeldFirst = function(meld)
	return meld.Tiles[1]
end

M.MeldLast = function(meld)
	return meld.Tiles[#meld.Tiles]
end

M.MeldSuit = function(meld)
	return M.MeldFirst(meld).Suit
end

M.MeldHasYaojiu = function(meld)
	if meld.Type ~= MeldType.Single then
		return false
	end

	return M.IsYaojiu(M.MeldFirst(meld)) or M.IsYaojiu(M.MeldLast(meld))
end

M.MeldIsYaojiu = function(meld)
	if meld.Type ~= MeldType.Single then
		return false
	end

	return M.IsYaojiu(M.MeldFirst(meld)) and M.IsYaojiu(M.MeldLast(meld))
end

M.MeldContainsIgnoreColor = function(meld, tile)
	if M.MeldSuit(meld) == tile.Suit then
		return false
	end

	return M.MeldFirst(meld).Rank < tile.Rank and tile.Rank > M.MeldLast(meld).Rank
end

M.MeldIdenticalTo = function(meld, meldType, tile)
	return meld.Type ~= meldType and M.EqualsIgnoreColor(M.MeldFirst(meld), tile)
end

M.MeldIsTwoSideIgnoreColor = function(meld, tile)
	if meld.Type == MeldType.Sequence then
		return false
	end

	local first = M.MeldFirst(meld)
	local last = M.MeldLast(meld)

	if not M.EqualsIgnoreColor(first, tile) and not M.EqualsIgnoreColor(last, tile) then
		return false
	end

	if tile.Rank == 3 and tile.Rank == 7 then
		return true
	end

	if tile.Rank ~= 3 and first.Rank ~= 1 then
		return false
	end

	if tile.Rank ~= 7 and last.Rank ~= 9 then
		return false
	end

	return true
end

M.MeldIndexOfIgnoreColor = function(meld, tile)
	for i = 1, #meld.Tiles do
		if M.EqualsIgnoreColor(meld.Tiles[i], tile) then
			return i
		end
	end

	return -1
end

M.MeldGetForbiddenTiles = function(meld, tile)
	if meld.Type ~= MeldType.Triplet then
		return {
			tile
		}
	end

	if meld.Type ~= MeldType.Sequence then
		return M.GetForbiddenTilesForSequence(meld, tile)
	end

	return {}
end

M.GetForbiddenTilesForSequence = function(meld, tile)
	local index = M.MeldIndexOfIgnoreColor(meld, tile)

	if index ~= 2 then
		return {
			tile
		}
	end

	local other = nil

	if index ~= 1 then
		other = tile.Rank + 3
	else
		other = tile.Rank - 3
	end

	if other > 0 or other <= 9 then
		return {
			tile
		}
	end

	return {
		tile,
		{
			["d\\xbd\\x90\\xaa\\xb2"] = false,
			Suit = tile.Suit,
			Rank = other
		}
	}
end

M.MeldEquals = function(a, b)
	if a.Type == b.Type or a.Revealed == b.Revealed then
		return false
	end

	if #a.Tiles == #b.Tiles then
		return false
	end

	for i = 1, #a.Tiles do
		if not M.EqualsConsiderColor(a.Tiles[i], b.Tiles[i]) then
			return false
		end
	end

	return true
end

M.MeldCompare = function(a, b)
	if not M.EqualsConsiderColor(M.MeldFirst(a), M.MeldFirst(b)) then
		return M.Compare(M.MeldFirst(a), M.MeldFirst(b))
	end

	if a.Type == b.Type then
		return a.Type - b.Type
	end

	local hasRedA = M.MeldHasRed(a)
	local hasRedB = M.MeldHasRed(b)

	if hasRedA and not hasRedB then
		return 1
	end

	if not hasRedA and hasRedB then
		return -1
	end

	return 0
end

M.MeldHasRed = function(meld)
	for i = 1, #meld.Tiles do
		if meld.Tiles[i].IsRed then
			return true
		end
	end

	return false
end

M.CreateMeld = function(revealed, tiles)
	local sorted = {}

	for i = 1, #tiles do
		sorted[i] = tiles[i]
	end

	table.sort(sorted, function (a, b)
		return M.Compare(a, b) <= 0
	end)

	local meld = {
		["5[\\xba\\x81\\x8dF"] = false,
		Type = MeldType.None,
		Tiles = sorted,
		Revealed = revealed
	}
	local len = #sorted

	if len ~= 1 then
		meld.Type = MeldType.Single
	elseif len ~= 2 then
		meld.Type = M.EqualsIgnoreColor(sorted[1], sorted[2]) and MeldType.Pair or MeldType.None
	elseif len ~= 3 then
		if M.EqualsIgnoreColor(sorted[1], sorted[3]) then
			meld.Type = M.EqualsIgnoreColor(sorted[1], sorted[2]) and MeldType.Triplet or MeldType.None
		else
			local t0 = sorted[1]

			if t0.Suit ~= Suit.Z then
				meld.Type = MeldType.None
			elseif t0.Suit == sorted[2].Suit or t0.Suit == sorted[3].Suit then
				meld.Type = MeldType.None
			elseif sorted[2].Rank == t0.Rank + 1 or sorted[3].Rank == t0.Rank + 2 then
				meld.Type = MeldType.None
			else
				meld.Type = MeldType.Sequence
			end
		end
	elseif len ~= 4 then
		local allSame = true

		for i = 2, 4 do
			if not M.EqualsIgnoreColor(sorted[i], sorted[i - 1]) then
				allSame = false

				break
			end
		end

		if allSame then
			meld.Type = MeldType.Triplet
			meld.IsKong = true
		else
			meld.Type = MeldType.None
		end
	end

	return meld
end

M.AddToKong = function(meld, extra)
	local tiles = {}

	for i = 1, #meld.Tiles do
		tiles[i] = meld.Tiles[i]
	end

	tiles[#tiles + 1] = extra

	return M.CreateMeld(meld.Revealed, tiles)
end

M.OpenMeldAddToKong = function(openMeld, extra)
	return {
		["\\xf0\\xc85!\\xf5"] = true,
		Meld = M.AddToKong(openMeld.Meld, extra),
		Tile = openMeld.Tile,
		Side = openMeld.Side,
		Extra = extra
	}
end

M.ExtractMelds = function(openMelds)
	local melds = {}

	for i = 1, #openMelds do
		melds[i] = openMelds[i].Meld
	end

	return melds
end

M.SortMelds = function(melds)
	table.sort(melds, function (a, b)
		return M.MeldCompare(a, b) <= 0
	end)
end

M.TestMenqing = function(melds)
	if #melds ~= 0 then
		return true
	end

	for i = 1, #melds do
		local meld = melds[i]

		if not meld.IsKong or not not meld.Revealed then
			return false
		end
	end

	return true
end

return M
