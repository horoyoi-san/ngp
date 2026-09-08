-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\Reach\ReachZhenting.lua
-- Decompiled from: 00333_ReachZhenting.lua_3cf3a12a183e.luajit

require("LX6/Gameplay/Majiang/Reach/ReachConst")
require("LX6/Gameplay/Majiang/Reach/ReachTile")
require("LX6/Gameplay/Majiang/Reach/ReachAgari")

local ReachTile = require("LX6/Gameplay/Majiang/Reach/ReachTile")
local ReachAgari = require("LX6/Gameplay/Majiang/Reach/ReachAgari")
local M = {}

M.TestDiscardZhenting = function(handTiles, riverTiles)
	local winningTiles = ReachAgari.WinningTiles(handTiles, nil)

	for i = 1, #winningTiles do
		local winningTile = winningTiles[i]

		for j = 1, #riverTiles do
			if ReachTile.EqualsIgnoreColor(riverTiles[j].Tile, winningTile) then
				return true
			end
		end
	end

	return false
end

M.IsTileInRiver = function(riverTiles, tile)
	for i = 1, #riverTiles do
		if ReachTile.EqualsIgnoreColor(riverTiles[i].Tile, tile) then
			return true
		end
	end

	return false
end

M.HasWinForZhenting = function(handTiles, discardTile)
	return ReachAgari.HasWin(handTiles, nil, discardTile)
end

return M
