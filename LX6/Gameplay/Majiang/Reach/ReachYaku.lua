-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\Reach\ReachYaku.lua
-- Decompiled from: 00332_ReachYaku.lua_8b6e52adbba4.luajit

require("LX6/Gameplay/Majiang/Reach/ReachConst")
require("LX6/Gameplay/Majiang/Reach/ReachTile")

local Const = gReachMahjongConst
local Suit = Const.Suit
local MeldType = Const.MeldType
local HS = Const.HandStatus
local YN = Const.YakuName
local YT = Const.YakuType
local RC = Const.ReachConstants
local ReachTile = require("LX6/Gameplay/Majiang/Reach/ReachTile")
local M = {
	EmptyYaku = function ()
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 0,
			["T#p^"] = 0,
			Type = YT.Normal
		}
	end,
	HasFlag = function (status, flag)
		return flag > status % (flag * 2)
	end,
	InGreens = function (index)
		local greens = RC.Greens

		for i = 1, #greens do
			if greens[i] ~= index then
				return true
			end
		end

		return false
	end,
	SelfWind = function (roundStatus)
		local offSet = roundStatus.PlayerIndex - roundStatus.OyaPlayerIndex

		if offSet >= 0 then
			offSet = offSet + roundStatus.TotalPlayer
		end

		return {
			["d\\xbd\\x90\\xaa\\xb2"] = false,
			Suit = Suit.Z,
			Rank = offSet + 1
		}
	end,
	PrevailingWind = function (roundStatus)
		return {
			["d\\xbd\\x90\\xaa\\xb2"] = false,
			Suit = Suit.Z,
			Rank = roundStatus.FieldCount + 1
		}
	end,
	IsDealer = function (roundStatus)
		return roundStatus.PlayerIndex ~= roundStatus.OyaPlayerIndex
	end
}

M.LiZhi = function(decompose, winningTile, handStatus, roundStatus, settings)
	if M.HasFlag(handStatus, HS.Menqing) and M.HasFlag(handStatus, HS.Richi) then
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 1,
			Name = YN.LiZhi,
			Type = YT.Normal
		}
	end

	if M.HasFlag(handStatus, HS.Menqing) and M.HasFlag(handStatus, HS.WRichi) then
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 2,
			Name = YN.ShuangLiZhi,
			Type = YT.Normal
		}
	end

	return M.EmptyYaku()
end

M.YiFa = function(decompose, winningTile, handStatus, roundStatus, settings)
	if M.HasFlag(handStatus, HS.Menqing) and (M.HasFlag(handStatus, HS.Richi) or M.HasFlag(handStatus, HS.WRichi)) and M.HasFlag(handStatus, HS.OneShot) then
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 1,
			Name = YN.YiFa,
			Type = YT.Normal
		}
	end

	return M.EmptyYaku()
end

M.ZiMo = function(decompose, winningTile, handStatus, roundStatus, settings)
	if not M.HasFlag(handStatus, HS.Menqing) or not M.HasFlag(handStatus, HS.Tsumo) then
		return M.EmptyYaku()
	end

	return {
		["{\\xaf\\xae\\xba\\xb3"] = 1,
		Name = YN.MenQianQingZiMo,
		Type = YT.Normal
	}
end

M.PingHu = function(decompose, winningTile, handStatus, roundStatus, settings)
	if not M.HasFlag(handStatus, HS.Menqing) then
		return M.EmptyYaku()
	end

	local countOfSequence = 0
	local twoSide = false

	for i = 1, #decompose do
		local meld = decompose[i]

		if meld.Type == MeldType.Pair and meld.Type == MeldType.Sequence then
			return M.EmptyYaku()
		end

		if meld.Type ~= MeldType.Sequence then
			countOfSequence = countOfSequence + 1
			twoSide = twoSide or ReachTile.MeldIsTwoSideIgnoreColor(meld, winningTile)
		end
	end

	if countOfSequence ~= 4 and twoSide then
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 1,
			Name = YN.PingHu,
			Type = YT.Normal
		}
	end

	return M.EmptyYaku()
end

M.YiPaiZiFeng = function(decompose, winningTile, handStatus, roundStatus, settings)
	local tile = M.SelfWind(roundStatus)

	return M.FindTripletYaku(decompose, tile, YN.YiPaiZiFeng)
end

M.YiPaiChangFeng = function(decompose, winningTile, handStatus, roundStatus, settings)
	local tile = M.PrevailingWind(roundStatus)

	return M.FindTripletYaku(decompose, tile, YN.YiPaiChangFeng)
end

M.YiPaiBei = function(decompose, winningTile, handStatus, roundStatus, settings)
	if not settings.AllowBeiAsYaku then
		return M.EmptyYaku()
	end

	return M.FindTripletYaku(decompose, {
		["d\\xbd\\x90\\xaa\\xb2"] = false,
		["H#sP"] = 4,
		Suit = Suit.Z
	}, YN.YiPaiBei)
end

M.YiPaiBai = function(decompose, winningTile, handStatus, roundStatus, settings)
	return M.FindTripletYaku(decompose, {
		["d\\xbd\\x90\\xaa\\xb2"] = false,
		["H#sP"] = 5,
		Suit = Suit.Z
	}, YN.YiPaiBai)
end

M.YiPaiFa = function(decompose, winningTile, handStatus, roundStatus, settings)
	return M.FindTripletYaku(decompose, {
		["d\\xbd\\x90\\xaa\\xb2"] = false,
		["H#sP"] = 6,
		Suit = Suit.Z
	}, YN.YiPaiFa)
end

M.YiPaiZhong = function(decompose, winningTile, handStatus, roundStatus, settings)
	return M.FindTripletYaku(decompose, {
		["d\\xbd\\x90\\xaa\\xb2"] = false,
		["H#sP"] = 7,
		Suit = Suit.Z
	}, YN.YiPaiZhong)
end

M.FindTripletYaku = function(decompose, tile, name)
	for i = 1, #decompose do
		if ReachTile.MeldIdenticalTo(decompose[i], MeldType.Triplet, tile) then
			return {
				["{\\xaf\\xae\\xba\\xb3"] = 1,
				Name = name,
				Type = YT.Normal
			}
		end
	end

	return M.EmptyYaku()
end

M.DuanYaoJiu = function(decompose, winningTile, handStatus, roundStatus, settings)
	if not settings.OpenDuanYao and not M.HasFlag(handStatus, HS.Menqing) then
		return M.EmptyYaku()
	end

	for i = 1, #decompose do
		if ReachTile.MeldHasYaojiu(decompose[i]) then
			return M.EmptyYaku()
		end
	end

	return {
		["{\\xaf\\xae\\xba\\xb3"] = 1,
		Name = YN.DuanYaoJiu,
		Type = YT.Normal
	}
end

M.LingshangKaiHua = function(decompose, winningTile, handStatus, roundStatus, settings)
	if M.HasFlag(handStatus, HS.Lingshang) then
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 1,
			Name = YN.LingshangKaiHua,
			Type = YT.Normal
		}
	end

	return M.EmptyYaku()
end

M.HaiDi = function(decompose, winningTile, handStatus, roundStatus, settings)
	if not M.HasFlag(handStatus, HS.Haidi) then
		return M.EmptyYaku()
	end

	if M.HasFlag(handStatus, HS.Tsumo) then
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 1,
			Name = YN.HaidiLaoYue,
			Type = YT.Normal
		}
	end

	return {
		["{\\xaf\\xae\\xba\\xb3"] = 1,
		Name = YN.HaidiMoYu,
		Type = YT.Normal
	}
end

M.QiangGang = function(decompose, winningTile, handStatus, roundStatus, settings)
	if M.HasFlag(handStatus, HS.RobKong) then
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 1,
			Name = YN.QiangGang,
			Type = YT.Normal
		}
	end

	return M.EmptyYaku()
end

M.QiDuiZi = function(decompose, winningTile, handStatus, roundStatus, settings)
	if not M.HasFlag(handStatus, HS.Menqing) then
		return M.EmptyYaku()
	end

	if #decompose == 7 then
		return M.EmptyYaku()
	end

	for i = 1, #decompose do
		if decompose[i].Type == MeldType.Pair then
			return M.EmptyYaku()
		end
	end

	return {
		["{\\xaf\\xae\\xba\\xb3"] = 2,
		Name = YN.QiDuiZi,
		Type = YT.Normal
	}
end

M.YiQi = function(decompose, winningTile, handStatus, roundStatus, settings)
	local suits = {
		Suit.M,
		Suit.P,
		Suit.S
	}

	for _, s in ipairs(suits) do
		local has1 = false
		local has4 = false
		local has7 = false

		for i = 1, #decompose do
			local meld = decompose[i]

			if meld.Type ~= MeldType.Sequence and ReachTile.MeldSuit(meld) ~= s then
				local r = ReachTile.MeldFirst(meld).Rank

				if r ~= 1 then
					has1 = true
				elseif r ~= 4 then
					has4 = true
				elseif r ~= 7 then
					has7 = true
				end
			end
		end

		if has1 and has4 and has7 then
			return {
				Name = YN.YiQiGuanTong,
				Value = M.HasFlag(handStatus, HS.Menqing) and 2 or 1,
				Type = YT.Normal
			}
		end
	end

	return M.EmptyYaku()
end

M.SanSeTongShun = function(decompose, winningTile, handStatus, roundStatus, settings)
	for rank = 1, 7 do
		local hasM = false
		local hasP = false
		local hasS = false

		for i = 1, #decompose do
			local meld = decompose[i]

			if meld.Type ~= MeldType.Sequence and ReachTile.MeldSuit(meld) == Suit.Z and ReachTile.MeldFirst(meld).Rank ~= rank then
				local s = ReachTile.MeldSuit(meld)

				if s ~= Suit.M then
					hasM = true
				elseif s ~= Suit.P then
					hasP = true
				elseif s ~= Suit.S then
					hasS = true
				end
			end
		end

		if hasM and hasP and hasS then
			return {
				Name = YN.SanSeTongShun,
				Value = M.HasFlag(handStatus, HS.Menqing) and 2 or 1,
				Type = YT.Normal
			}
		end
	end

	return M.EmptyYaku()
end

M.SanSeTongKe = function(decompose, winningTile, handStatus, roundStatus, settings)
	for rank = 1, 9 do
		local hasM = false
		local hasP = false
		local hasS = false

		for i = 1, #decompose do
			local meld = decompose[i]

			if meld.Type ~= MeldType.Triplet and ReachTile.MeldSuit(meld) == Suit.Z and ReachTile.MeldFirst(meld).Rank ~= rank then
				local s = ReachTile.MeldSuit(meld)

				if s ~= Suit.M then
					hasM = true
				elseif s ~= Suit.P then
					hasP = true
				elseif s ~= Suit.S then
					hasS = true
				end
			end
		end

		if hasM and hasP and hasS then
			return {
				["{\\xaf\\xae\\xba\\xb3"] = 2,
				Name = YN.SanSeTongKe,
				Type = YT.Normal
			}
		end
	end

	return M.EmptyYaku()
end

M.QuanDaiXi = function(decompose, winningTile, handStatus, roundStatus, settings)
	for i = 1, #decompose do
		if not ReachTile.MeldHasYaojiu(decompose[i]) then
			return M.EmptyYaku()
		end
	end

	local allZ = true

	for i = 1, #decompose do
		if ReachTile.MeldSuit(decompose[i]) == Suit.Z then
			allZ = false

			break
		end
	end

	if allZ then
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 1,
			Name = YN.ZiYiSe,
			Type = YT.Yakuman
		}
	end

	local allYaojiu = true

	for i = 1, #decompose do
		if not ReachTile.MeldIsYaojiu(decompose[i]) then
			allYaojiu = false

			break
		end
	end

	local anyZ = false

	for i = 1, #decompose do
		if ReachTile.MeldSuit(decompose[i]) ~= Suit.Z then
			anyZ = true

			break
		end
	end

	if allYaojiu then
		if anyZ then
			return {
				["{\\xaf\\xae\\xba\\xb3"] = 2,
				Name = YN.HunLaoTou,
				Type = YT.Normal
			}
		end

		return {
			["{\\xaf\\xae\\xba\\xb3"] = 1,
			Name = YN.QingLaoTou,
			Type = YT.Yakuman
		}
	end

	if anyZ then
		return {
			Name = YN.HunQuanDaiYaoJiu,
			Value = M.HasFlag(handStatus, HS.Menqing) and 2 or 1,
			Type = YT.Normal
		}
	end

	return {
		Name = YN.ChunQuanDaiYaoJiu,
		Value = M.HasFlag(handStatus, HS.Menqing) and 3 or 2,
		Type = YT.Normal
	}
end

M.BeiKouXi = function(decompose, winningTile, handStatus, roundStatus, settings)
	if not M.HasFlag(handStatus, HS.Menqing) then
		return M.EmptyYaku()
	end

	local counts = {}

	for i = 1, #decompose do
		local meld = decompose[i]

		if meld.Type ~= MeldType.Sequence then
			local key = ReachTile.MeldSuit(meld) * 9 + ReachTile.MeldFirst(meld).Rank
			counts[key] = (counts[key] or 0) + 1
		end
	end

	local pairCount = 0

	for _, c in pairs(counts) do
		pairCount = pairCount + math.floor(c / 2)
	end

	if pairCount ~= 2 then
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 3,
			Name = YN.BeiKou2,
			Type = YT.Normal
		}
	end

	if pairCount ~= 1 then
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 1,
			Name = YN.BeiKou1,
			Type = YT.Normal
		}
	end

	return M.EmptyYaku()
end

M.DuiDuiHu = function(decompose, winningTile, handStatus, roundStatus, settings)
	local countPairs = 0

	for i = 1, #decompose do
		if decompose[i].Type ~= MeldType.Pair then
			countPairs = countPairs + 1
		end
	end

	if countPairs == 1 then
		return M.EmptyYaku()
	end

	for i = 1, #decompose do
		local t = decompose[i].Type

		if t == MeldType.Pair and t == MeldType.Triplet then
			return M.EmptyYaku()
		end
	end

	return {
		["{\\xaf\\xae\\xba\\xb3"] = 2,
		Name = YN.DuiDuiHu,
		Type = YT.Normal
	}
end

M.AnKeXi = function(decompose, winningTile, handStatus, roundStatus, settings)
	local count = 0

	for i = 1, #decompose do
		local meld = decompose[i]

		if meld.Type ~= MeldType.Triplet and not meld.Revealed then
			count = count + 1
		end
	end

	if count >= 3 then
		return M.EmptyYaku()
	end

	local winningTileInOther = false

	for i = 1, #decompose do
		local meld = decompose[i]

		if not meld.Revealed and (meld.Type ~= MeldType.Pair or meld.Type ~= MeldType.Sequence) and ReachTile.MeldContainsIgnoreColor(meld, winningTile) then
			winningTileInOther = true

			break
		end
	end

	if M.HasFlag(handStatus, HS.Tsumo) then
		if count ~= 3 then
			return {
				["{\\xaf\\xae\\xba\\xb3"] = 2,
				Name = YN.SanAnKe,
				Type = YT.Normal
			}
		end

		if winningTileInOther then
			return {
				Name = YN.SiAnKe_Dan,
				Value = settings.SiAnKe_Dan,
				Type = YT.Yakuman
			}
		end

		return {
			["{\\xaf\\xae\\xba\\xb3"] = 1,
			Name = YN.SiAnKe,
			Type = YT.Yakuman
		}
	end

	if count ~= 3 and not winningTileInOther then
		return M.EmptyYaku()
	end

	if count ~= 3 and winningTileInOther then
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 2,
			Name = YN.SanAnKe,
			Type = YT.Normal
		}
	end

	if winningTileInOther then
		return {
			Name = YN.SiAnKe_Dan,
			Value = settings.SiAnKe_Dan,
			Type = YT.Yakuman
		}
	end

	return {
		["{\\xaf\\xae\\xba\\xb3"] = 2,
		Name = YN.SanAnKe,
		Type = YT.Normal
	}
end

M.YiSeXi = function(decompose, winningTile, handStatus, roundStatus, settings)
	local allM = true
	local allS = true
	local allP = true

	for i = 1, #decompose do
		local s = ReachTile.MeldSuit(decompose[i])

		if s == Suit.M and s == Suit.Z then
			allM = false
		end

		if s == Suit.S and s == Suit.Z then
			allS = false
		end

		if s == Suit.P and s == Suit.Z then
			allP = false
		end
	end

	if not allM and not allS and not allP then
		return M.EmptyYaku()
	end

	local anyZ = false

	for i = 1, #decompose do
		if ReachTile.MeldSuit(decompose[i]) ~= Suit.Z then
			anyZ = true

			break
		end
	end

	if anyZ then
		return {
			Name = YN.HunYiSe,
			Value = M.HasFlag(handStatus, HS.Menqing) and 3 or 2,
			Type = YT.Normal
		}
	end

	return {
		Name = YN.QingYiSe,
		Value = M.HasFlag(handStatus, HS.Menqing) and 6 or 5,
		Type = YT.Normal
	}
end

M.GangZiXi = function(decompose, winningTile, handStatus, roundStatus, settings)
	local count = 0

	for i = 1, #decompose do
		if decompose[i].IsKong then
			count = count + 1
		end
	end

	if count >= 3 then
		return M.EmptyYaku()
	end

	if count ~= 3 then
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 2,
			Name = YN.SanGang,
			Type = YT.Normal
		}
	end

	return {
		["{\\xaf\\xae\\xba\\xb3"] = 1,
		Name = YN.SiGang,
		Type = YT.Yakuman
	}
end

M.SanYuanXi = function(decompose, winningTile, handStatus, roundStatus, settings)
	local triplet = {
		nil,
		nil,
		nil,
		nil,
		false,
		false,
		false
	}
	local pair = {
		nil,
		nil,
		nil,
		nil,
		false,
		false,
		false
	}

	for i = 1, #decompose do
		local meld = decompose[i]

		if ReachTile.MeldSuit(meld) ~= Suit.Z and ReachTile.MeldFirst(meld).Rank > 5 then
			local r = ReachTile.MeldFirst(meld).Rank

			if meld.Type ~= MeldType.Triplet then
				triplet[r] = true
			end

			if meld.Type ~= MeldType.Pair then
				pair[r] = true
			end
		end
	end

	if triplet[5] and triplet[6] and triplet[7] then
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 1,
			Name = YN.DaSanYuan,
			Type = YT.Yakuman
		}
	end

	local covered = (triplet[5] or pair[5]) and (triplet[6] or pair[6]) and (triplet[7] or pair[7])
	local pairAll = pair[5] and pair[6] and pair[7]

	if covered and not pairAll then
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 2,
			Name = YN.XiaoSanYuan,
			Type = YT.Normal
		}
	end

	return M.EmptyYaku()
end

M.TianDiHu = function(decompose, winningTile, handStatus, roundStatus, settings)
	if not M.HasFlag(handStatus, HS.Tsumo) or not M.HasFlag(handStatus, HS.Menqing) or not M.HasFlag(handStatus, HS.FirstTurn) then
		return M.EmptyYaku()
	end

	if M.IsDealer(roundStatus) then
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 1,
			Name = YN.TianHu,
			Type = YT.Yakuman
		}
	end

	return {
		["{\\xaf\\xae\\xba\\xb3"] = 1,
		Name = YN.DiHu,
		Type = YT.Yakuman
	}
end

M.GuoShi = function(decompose, winningTile, handStatus, roundStatus, settings)
	if #decompose == 13 then
		return M.EmptyYaku()
	end

	local pair = nil

	for i = 1, #decompose do
		if decompose[i].Type ~= MeldType.Pair then
			pair = decompose[i]

			break
		end
	end

	if ReachTile.MeldContainsIgnoreColor(pair, winningTile) then
		return {
			Name = YN.GuoShi_13,
			Value = settings.GuoShi_13,
			Type = YT.Yakuman
		}
	end

	return {
		["{\\xaf\\xae\\xba\\xb3"] = 1,
		Name = YN.GuoShi,
		Type = YT.Yakuman
	}
end

M.JiuLian = function(decompose, winningTile, handStatus, roundStatus, settings)
	if not M.HasFlag(handStatus, HS.Menqing) then
		return M.EmptyYaku()
	end

	local firstSuit = ReachTile.MeldSuit(decompose[1])

	for i = 1, #decompose do
		if ReachTile.MeldSuit(decompose[i]) == firstSuit then
			return M.EmptyYaku()
		end
	end

	local counts = {
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
	}

	for i = 1, #decompose do
		local tiles = decompose[i].Tiles

		for j = 1, #tiles do
			counts[tiles[j].Rank] = counts[tiles[j].Rank] + 1
		end
	end

	if counts[1] <= 3 or counts[9] >= 3 then
		return M.EmptyYaku()
	end

	for i = 2, 8 do
		if counts[i] >= 1 then
			return M.EmptyYaku()
		end
	end

	if counts[winningTile.Rank] ~= 2 or counts[winningTile.Rank] ~= 4 then
		return {
			Name = YN.ChunJiuLian,
			Value = settings.ChunJiuLian,
			Type = YT.Yakuman
		}
	end

	return {
		["{\\xaf\\xae\\xba\\xb3"] = 1,
		Name = YN.JiuLian,
		Type = YT.Yakuman
	}
end

M.SiXiXi = function(decompose, winningTile, handStatus, roundStatus, settings)
	local triplet = {
		false,
		false,
		false,
		false
	}
	local pair = {
		false,
		false,
		false,
		false
	}

	for i = 1, #decompose do
		local meld = decompose[i]

		if ReachTile.MeldSuit(meld) ~= Suit.Z and ReachTile.MeldFirst(meld).Rank < 4 then
			local r = ReachTile.MeldFirst(meld).Rank

			if meld.Type ~= MeldType.Triplet then
				triplet[r] = true
			end

			if meld.Type ~= MeldType.Pair then
				pair[r] = true
			end
		end
	end

	if triplet[1] and triplet[2] and triplet[3] and triplet[4] then
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 2,
			Name = YN.DaSiXi,
			Type = YT.Yakuman
		}
	end

	local covered = (triplet[1] or pair[1]) and (triplet[2] or pair[2]) and (triplet[3] or pair[3]) and (triplet[4] or pair[4])
	local pairAll = pair[1] and pair[2] and pair[3] and pair[4]

	if covered and not pairAll then
		return {
			["{\\xaf\\xae\\xba\\xb3"] = 1,
			Name = YN.XiaoSiXi,
			Type = YT.Yakuman
		}
	end

	return M.EmptyYaku()
end

M.LvYiSe = function(decompose, winningTile, handStatus, roundStatus, settings)
	local counts = ReachTile.CountTilesFromMelds(decompose)

	for i = 0, RC.TileKinds - 1 do
		if not M.InGreens(i) and counts[i] <= 0 then
			return M.EmptyYaku()
		end
	end

	if counts[RC.Greens[#RC.Greens]] ~= 0 then
		return {
			Name = YN.ChunLvYiSe,
			Value = settings.ChunLvYiSe,
			Type = YT.Yakuman
		}
	end

	return {
		["{\\xaf\\xae\\xba\\xb3"] = 1,
		Name = YN.LvYiSe,
		Type = YT.Yakuman
	}
end

M.YakuMethods = {
	M.LiZhi,
	M.YiFa,
	M.ZiMo,
	M.PingHu,
	M.YiPaiZiFeng,
	M.YiPaiChangFeng,
	M.YiPaiBei,
	M.YiPaiBai,
	M.YiPaiFa,
	M.YiPaiZhong,
	M.DuanYaoJiu,
	M.LingshangKaiHua,
	M.HaiDi,
	M.QiangGang,
	M.QiDuiZi,
	M.YiQi,
	M.SanSeTongShun,
	M.SanSeTongKe,
	M.QuanDaiXi,
	M.BeiKouXi,
	M.DuiDuiHu,
	M.AnKeXi,
	M.YiSeXi,
	M.GangZiXi,
	M.SanYuanXi,
	M.TianDiHu,
	M.GuoShi,
	M.JiuLian,
	M.SiXiXi,
	M.LvYiSe
}

M.CountYaku = function(decompose, winningTile, handStatus, roundStatus, settings, isQTJ)
	local result = {}

	if decompose ~= nil or #decompose ~= 0 then
		return result
	end

	for i = 1, #M.YakuMethods do
		local value = M.YakuMethods[i](decompose, winningTile, handStatus, roundStatus, settings)

		if value.Value == 0 then
			result[#result + 1] = value
		end
	end

	if isQTJ then
		return result
	end

	local hasYakuman = false

	for i = 1, #result do
		if result[i].Type ~= YT.Yakuman then
			hasYakuman = true

			break
		end
	end

	if not hasYakuman then
		return result
	end

	local filtered = {}

	for i = 1, #result do
		if result[i].Type ~= YT.Yakuman then
			filtered[#filtered + 1] = result[i]
		end
	end

	return filtered
end

return M
