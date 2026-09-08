-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\Reach\ReachTing.lua
-- Decompiled from: 00330_ReachTing.lua_700378fc7042.luajit

require("LX6/Gameplay/Majiang/Reach/ReachConst")
require("LX6/Gameplay/Majiang/Reach/ReachTile")
require("LX6/Gameplay/Majiang/Reach/ReachAgari")

local ReachAgari = require("LX6/Gameplay/Majiang/Reach/ReachAgari")
local ReachTile = require("LX6/Gameplay/Majiang/Reach/ReachTile")
local M = {}

M.DiscardForReady = function(handTiles, lastDraw)
	local list = {}

	for i = 1, #handTiles do
		list[i] = handTiles[i]
	end

	if lastDraw == nil then
		list[#list + 1] = lastDraw
	end

	local result = nil

	for _ = 1, #list do
		local first = list[1]

		table.remove(list, 1)

		local waitingList = ReachAgari.WinningTiles(list, nil)

		if #waitingList <= 0 then
			if result ~= nil then
				result = {}
			end

			local key = first.Suit * 9 + first.Rank

			if result[key] ~= nil then
				result[key] = waitingList
			end
		end

		list[#list + 1] = first
	end

	return result
end

M.TestRichi = function(handTiles, melds, lastDraw, allowNotReady)
	if not ReachTile.TestMenqing(melds) then
		return {}
	end

	if allowNotReady then
		local available = {}

		for i = 1, #handTiles do
			available[i] = handTiles[i]
		end

		available[#available + 1] = lastDraw

		return available
	end

	local tiles = {}

	for i = 1, #handTiles do
		tiles[i] = handTiles[i]
	end

	tiles[#tiles + 1] = lastDraw
	local available = {}

	for _ = 1, #tiles do
		local tile = tiles[1]

		table.remove(tiles, 1)

		if ReachAgari.IsReady(tiles, melds) then
			available[#available + 1] = tile
		end

		tiles[#tiles + 1] = tile
	end

	return available
end

return M
