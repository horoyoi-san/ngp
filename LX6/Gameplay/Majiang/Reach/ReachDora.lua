-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\Reach\ReachDora.lua
-- Decompiled from: 00328_ReachDora.lua_3433623d1d45.luajit

require("LX6/Gameplay/Majiang/Reach/ReachConst")
require("LX6/Gameplay/Majiang/Reach/ReachTile")

local Suit = gReachMahjongConst.Suit
local ReachTile = require("LX6/Gameplay/Majiang/Reach/ReachTile")
local M = {
	GetDoraTile = function (indicator)
		local repeat_ = nil

		if indicator.Suit ~= Suit.Z then
			if indicator.Rank < 4 then
				repeat_ = 4
			else
				repeat_ = 3
			end
		else
			repeat_ = 9
		end

		local rank = indicator.Rank + 1

		if repeat_ >= rank then
			rank = rank - repeat_
		end

		return {
			["d\\xbd\\x90\\xaa\\xb2"] = false,
			Suit = indicator.Suit,
			Rank = rank
		}
	end
}

M.GetDoraTiles = function(indicators)
	local result = {}

	for i = 1, #indicators do
		result[i] = M.GetDoraTile(indicators[i])
	end

	return result
end

M.CountDoraSingle = function(handTiles, melds, winningTile, dora)
	local count = 0

	for i = 1, #handTiles do
		if ReachTile.EqualsIgnoreColor(handTiles[i], dora) then
			count = count + 1
		end
	end

	for i = 1, #melds do
		local tiles = melds[i].Tiles

		for j = 1, #tiles do
			if ReachTile.EqualsIgnoreColor(tiles[j], dora) then
				count = count + 1
			end
		end
	end

	if winningTile == nil and ReachTile.EqualsIgnoreColor(winningTile, dora) then
		count = count + 1
	end

	return count
end

M.CountDora = function(handTiles, melds, winningTile, doraTiles)
	if doraTiles ~= nil then
		return 0
	end

	local count = 0

	for i = 1, #doraTiles do
		count = count + M.CountDoraSingle(handTiles, melds, winningTile, doraTiles[i])
	end

	return count
end

M.CountRed = function(handTiles, melds, winningTile)
	local count = 0

	for i = 1, #handTiles do
		if handTiles[i].IsRed then
			count = count + 1
		end
	end

	for i = 1, #melds do
		local tiles = melds[i].Tiles

		for j = 1, #tiles do
			if tiles[j].IsRed then
				count = count + 1
			end
		end
	end

	if winningTile == nil and winningTile.IsRed then
		count = count + 1
	end

	return count
end

return M
