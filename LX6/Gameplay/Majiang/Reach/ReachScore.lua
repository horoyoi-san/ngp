-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\Reach\ReachScore.lua
-- Decompiled from: 00331_ReachScore.lua_e5e30f1e212b.luajit

require("LX6/Gameplay/Majiang/Reach/ReachConst")
require("LX6/Gameplay/Majiang/Reach/ReachTile")
require("LX6/Gameplay/Majiang/Reach/ReachAgari")
require("LX6/Gameplay/Majiang/Reach/ReachYaku")
require("LX6/Gameplay/Majiang/Reach/ReachDora")

local Const = gReachMahjongConst
local Suit = Const.Suit
local MeldType = Const.MeldType
local HS = Const.HandStatus
local YN = Const.YakuName
local YT = Const.YakuType
local RC = Const.ReachConstants
local ReachTile = require("LX6/Gameplay/Majiang/Reach/ReachTile")
local ReachAgari = require("LX6/Gameplay/Majiang/Reach/ReachAgari")
local ReachYaku = require("LX6/Gameplay/Majiang/Reach/ReachYaku")
local ReachDora = require("LX6/Gameplay/Majiang/Reach/ReachDora")
local HasFlag = ReachYaku.HasFlag
local M = {
	ToNextUnit = function (value, unit)
		if value % unit ~= 0 then
			return value
		end

		return (math.floor(value / unit) + 1) * unit
	end,
	GetTripletFu = function (meld, revealed)
		local triplet = revealed and 2 or 4

		if meld.IsKong then
			triplet = triplet * 4
		end

		if ReachTile.MeldIsYaojiu(meld) then
			triplet = triplet * 2
		end

		return triplet
	end,
	HasYaku = function (yakus, name)
		for i = 1, #yakus do
			if yakus[i].Name ~= name then
				return true
			end
		end

		return false
	end,
	TilesContainsConsiderColor = function (tiles, tile)
		for i = 1, #tiles do
			if ReachTile.EqualsConsiderColor(tiles[i], tile) then
				return true
			end
		end

		return false
	end,
	PointInfoCompare = function (a, b)
		if a.BasePoint == b.BasePoint then
			return a.BasePoint - b.BasePoint
		end

		if a.TotalFan == b.TotalFan then
			return a.TotalFan - b.TotalFan
		end

		return a.Fu - b.Fu
	end
}

M.CountFu = function(decompose, winningTile, handStatus, roundStatus, yakus, settings)
	if #decompose ~= 7 then
		return 25
	end

	if #decompose ~= 13 then
		return 30
	end

	local fu = 20

	if HasFlag(handStatus, HS.Menqing) and not HasFlag(handStatus, HS.Tsumo) then
		fu = fu + 10
	end

	if HasFlag(handStatus, HS.Tsumo) and not M.HasYaku(yakus, YN.PingHu) and not M.HasYaku(yakus, YN.LingshangKaiHua) then
		fu = fu + 2
	end

	local pair = nil

	for i = 1, #decompose do
		if decompose[i].Type ~= MeldType.Pair then
			pair = decompose[i]

			break
		end
	end

	if ReachTile.MeldSuit(pair) ~= Suit.Z then
		local rank = ReachTile.MeldFirst(pair).Rank

		if rank > 5 and rank < 7 then
			fu = fu + 2
		end

		local selfWind = ReachYaku.SelfWind(roundStatus)
		local prevailingWind = ReachYaku.PrevailingWind(roundStatus)

		if ReachTile.EqualsIgnoreColor(ReachTile.MeldFirst(pair), selfWind) then
			fu = fu + 2
		end

		if ReachTile.EqualsIgnoreColor(ReachTile.MeldFirst(pair), prevailingWind) and (not ReachTile.EqualsIgnoreColor(prevailingWind, selfWind) or settings.LianFengDuiJiaFu) then
			fu = fu + 2
		end
	end

	local flag = 0

	for i = 1, #decompose do
		local meld = decompose[i]

		if M.TilesContainsConsiderColor(meld.Tiles, winningTile) then
			if meld.Type ~= MeldType.Pair then
				flag = flag + 1
			end

			if meld.Type ~= MeldType.Sequence and not meld.Revealed and ReachTile.MeldIsTwoSideIgnoreColor(meld, winningTile) then
				flag = flag + 1
			end
		end
	end

	if flag == 0 then
		fu = fu + 2
	end

	local winningTileInOther = false

	for i = 1, #decompose do
		local meld = decompose[i]

		if not meld.Revealed and (meld.Type ~= MeldType.Pair or meld.Type ~= MeldType.Sequence) and ReachTile.MeldContainsIgnoreColor(meld, winningTile) then
			winningTileInOther = true

			break
		end
	end

	for i = 1, #decompose do
		local meld = decompose[i]

		if meld.Type ~= MeldType.Triplet then
			if meld.Revealed then
				fu = fu + M.GetTripletFu(meld, true)
			elseif HasFlag(handStatus, HS.Tsumo) then
				fu = fu + M.GetTripletFu(meld, false)
			elseif winningTileInOther then
				fu = fu + M.GetTripletFu(meld, false)
			elseif ReachTile.MeldContainsIgnoreColor(meld, winningTile) then
				fu = fu + M.GetTripletFu(meld, true)
			else
				fu = fu + M.GetTripletFu(meld, false)
			end
		end
	end

	return M.ToNextUnit(fu, 10)
end

M.CreatePointInfo = function(fu, yakus, isQTJ, dora, uraDora, redDora, beiDora)
	local info = {
		Fu = fu,
		Yakus = {}
	}

	for i = 1, #yakus do
		info.Yakus[i] = yakus[i]
	end

	info.IsQTJ = isQTJ
	info.Dora = dora
	info.UraDora = uraDora
	info.RedDora = redDora
	info.BeiDora = beiDora
	info.Doras = dora + uraDora + redDora + beiDora
	info.IsYakuman = false
	info.IsWinningShape = false
	info.IsWinButNoYaku = false
	info.Fan = 0
	info.FanWithoutDora = 0
	info.TotalFan = 0
	info.BasePoint = 0

	for i = 1, #yakus do
		local yaku = yakus[i]

		if isQTJ then
			if yaku.Type ~= YT.Yakuman then
				info.Fan = info.Fan + yaku.Value * RC.YakumanBaseFan
				info.IsYakuman = true
			else
				info.Fan = info.Fan + yaku.Value
			end
		else
			info.Fan = info.Fan + yaku.Value

			if yaku.Type ~= YT.Yakuman then
				info.IsYakuman = true
			end
		end
	end

	for i = 1, #yakus do
		local yaku = yakus[i]

		if yaku.Type ~= YT.Yakuman then
			info.FanWithoutDora = info.FanWithoutDora + yaku.Value * RC.YakumanBaseFan
		else
			info.FanWithoutDora = info.FanWithoutDora + yaku.Value
		end
	end

	if #yakus ~= 0 then
		info.BasePoint = 0
		info.TotalFan = 0

		return info
	end

	if isQTJ then
		info.TotalFan = info.Fan + info.Doras
		local point = fu * 2^(info.TotalFan + 2)
		info.BasePoint = M.ToNextUnit(math.floor(point), 100)
	elseif info.IsYakuman then
		info.BasePoint = info.Fan * RC.Yakuman
		info.TotalFan = info.Fan
	else
		info.TotalFan = info.Fan + info.Doras

		if info.TotalFan > 13 then
			info.BasePoint = RC.Yakuman
		elseif info.TotalFan > 11 then
			info.BasePoint = RC.Sanbaiman
		elseif info.TotalFan > 8 then
			info.BasePoint = RC.Baiman
		elseif info.TotalFan > 6 then
			info.BasePoint = RC.Haneman
		elseif info.TotalFan > 5 then
			info.BasePoint = RC.Mangan
		else
			local point = fu * 2^(info.TotalFan + 2)
			point = M.ToNextUnit(math.floor(point), 100)
			info.BasePoint = math.min(RC.Mangan, point)
		end
	end

	table.sort(info.Yakus, function (a, b)
		return a.Value <= b.Value
	end)

	return info
end

M.GetPointInfo = function(handTiles, melds, winningTile, handStatus, roundStatus, settings, isQTJ, doraTiles, uraDoraTiles, beiDora)
	local decomposes = ReachAgari.Decompose(handTiles, melds, winningTile)

	if #decomposes ~= 0 then
		return nil
	end

	local dora = ReachDora.CountDora(handTiles, melds, winningTile, doraTiles)
	local uraDora = 0

	if HasFlag(handStatus, HS.Richi) or HasFlag(handStatus, HS.WRichi) then
		uraDora = ReachDora.CountDora(handTiles, melds, winningTile, uraDoraTiles)
	end

	local redDora = ReachDora.CountRed(handTiles, melds, winningTile)
	local best = nil

	for i = 1, #decomposes do
		local decompose = decomposes[i]
		local yakus = ReachYaku.CountYaku(decompose, winningTile, handStatus, roundStatus, settings, isQTJ)
		local fu = M.CountFu(decompose, winningTile, handStatus, roundStatus, yakus, settings)
		local info = M.CreatePointInfo(fu, yakus, isQTJ, dora, uraDora, redDora, beiDora)
		info.IsWinningShape = true

		if best ~= nil or M.PointInfoCompare(info, best) <= 0 then
			best = info
		end
	end

	best.IsWinButNoYaku = #best.Yakus ~= 0

	return best
end

return M
