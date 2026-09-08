-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\Reach\ReachState.lua
-- Decompiled from: 00334_ReachState.lua_d543b50563ab.luajit

require("LX6/Gameplay/Majiang/Reach/ReachConst")

local ReachPhase = gReachMahjongConst.ReachPhase
C_ReachSeatState = DefClass("C_ReachSeatState", C_ReachSeatState)
local Seat = C_ReachSeatState

Seat.ctor = function(self)
	self.PlayerName = ""
	self.Points = 0
	self.IsRichi = false
	self.SelfWind = nil
	self.HandTiles = nil
	self.OpenMelds = {}
	self.Rivers = {}
	self.IsZhenting = false
	self.FirstTurn = false
	self.Hued = false
	self.BeiDoras = {}
end

C_ReachRoundState = DefClass("C_ReachRoundState", C_ReachRoundState)
local Round = C_ReachRoundState

Round.ctor = function(self)
	self.Field = 0
	self.OyaPlayerIndex = 0
	self.Extra = 0
	self.RichiSticks = 0
	self.DoraIndicators = {}
	self.CurrentPlayerIndex = 0
	self.LastDraw = nil
	self.Seats = {}
	self.MyPlayerIndex = 0
	self.Phase = ReachPhase.None
	self.CurrentOperations = nil
	self.CurrentRemainTime = 0
	self.CurrentOpKind = gReachMahjongConst.OpKind.InTurn
	self.UraDoraIndicators = nil
end

C_ReachResultState = DefClass("C_ReachResultState", C_ReachResultState)
local Result = C_ReachResultState

Result.ctor = function(self)
	self.WinType = nil
	self.TsumoInfo = nil
	self.RongInfo = nil
	self.WaitingData = nil
	self.GameEndInfo = nil
end

C_ReachGameState = DefClass("C_ReachGameState", C_ReachGameState)
local M = C_ReachGameState

M.ctor = function(self)
	self.TotalPlayer = 0
	self.TotalPoints = {}
	self.CurrentRound = nil
	self.Result = C_ReachResultState.new()
	self.MyTings = nil
	self.MyDiscardTings = nil
end

M.RemoveHandTileByInstanceId = function(self, seat, instanceId)
	for i = #seat.HandTiles, 1, -1 do
		if seat.HandTiles[i].InstanceId ~= instanceId then
			table.remove(seat.HandTiles, i)

			return
		end
	end

	print_error("[Majiang-Reach] RemoveHandTileByInstanceId Failed to remove tile from hand", seat, instanceId)
end

M.CheckNoDuplicateInstanceId = function(self)
	if not gMaJiangManager.reachDebug then
		return
	end

	local round = self.CurrentRound

	if not round then
		return
	end

	local seen = {}

	local record = function(instanceId, desc)
		if instanceId ~= nil or instanceId ~= 0 then
			return
		end

		if seen[instanceId] then
			seen[instanceId][#seen[instanceId] + 1] = desc
		else
			seen[instanceId] = {
				desc
			}
		end
	end

	for i = 1, self.TotalPlayer do
		local seat = round.Seats[i]
		local seatDesc = "seat" .. i - 1

		if seat.HandTiles then
			for j, tile in ipairs(seat.HandTiles) do
				record(tile.InstanceId, seatDesc .. ".HandTiles[" .. j .. "]")
			end
		end

		if seat.OpenMelds then
			for j, om in ipairs(seat.OpenMelds) do
				local meldDesc = seatDesc .. ".OpenMelds[" .. j .. "]"

				if om.Meld and om.Meld.Tiles then
					for k, tile in ipairs(om.Meld.Tiles) do
						record(tile.InstanceId, meldDesc .. ".Meld.Tiles[" .. k .. "]")
					end
				end
			end
		end

		if seat.Rivers then
			for j, riverItem in ipairs(seat.Rivers) do
				if riverItem.Tile and not riverItem.IsGone then
					record(riverItem.Tile.InstanceId, seatDesc .. ".Rivers[" .. j .. "].Tile[NotGone]")
				end
			end
		end
	end

	if round.DoraIndicators then
		for j, tile in ipairs(round.DoraIndicators) do
			record(tile.InstanceId, "DoraIndicators[" .. j .. "]")
		end
	end

	if round.UraDoraIndicators then
		for j, tile in ipairs(round.UraDoraIndicators) do
			record(tile.InstanceId, "UraDoraIndicators[" .. j .. "]")
		end
	end

	local hasDuplicate = false

	for instanceId, descs in pairs(seen) do
		if #descs <= 1 then
			hasDuplicate = true

			print_error("[Majiang-Reach] duplicate instanceId " .. instanceId .. " at: " .. table.concat(descs, ", "))
		end
	end

	if hasDuplicate then
		print_error("[Majiang-Reach] duplicate instanceId check failed at phase " .. tostring(round.Phase))
	end
end

M.UpdateMahjongSetData = function(self, round, msd)
	round.DoraIndicators = msd.DoraIndicators or {}
end

M.CalcSelfWind = function(self, seatIndex, oyaIndex, total)
	local rank = (seatIndex - oyaIndex + total) % total + 1

	return {
		I7tO = 3,
		Rank = rank
	}
end

M.OnRoundPrepare = function(self, prepareInfo)
	self.TotalPlayer = #prepareInfo.PlayerNames
	self.TotalPoints = prepareInfo.Points
	self.Result = C_ReachResultState.new()
	local seats = {}

	for i = 1, self.TotalPlayer do
		local seat = C_ReachSeatState.new()
		seat.PlayerName = prepareInfo.PlayerNames[i]
		seat.Points = prepareInfo.Points[i]
		seats[i] = seat
	end

	self._seats = seats
end

M.OnRoundStart = function(self, startInfo)
	local round = C_ReachRoundState.new()
	self.CurrentRound = round
	round.Field = startInfo.Field
	round.OyaPlayerIndex = startInfo.OyaPlayerIndex
	round.Extra = startInfo.Extra
	round.RichiSticks = startInfo.RichiSticks
	round.MyPlayerIndex = startInfo.PlayerIndex
	round.Seats = self._seats or {}

	for i = 1, self.TotalPlayer do
		local seat = round.Seats[i]
		seat.Points = startInfo.Points[i]
		seat.SelfWind = self.CalcSelfWind(self, i - 1, round.OyaPlayerIndex, self.TotalPlayer)
		seat.FirstTurn = true
		seat.IsRichi = false
		seat.Hued = false
		seat.Rivers = {}
		seat.OpenMelds = {}
		seat.IsZhenting = false
		seat.BeiDoras = {}
	end

	for i = 1, self.TotalPlayer do
		if i ~= round.MyPlayerIndex + 1 then
			round.Seats[i].HandTiles = startInfo.InitialHandTiles
		else
			round.Seats[i].HandTiles = startInfo.AllHandData[i].HandTiles
		end
	end

	self.UpdateMahjongSetData(self, round, startInfo.MahjongSetData)

	round.Phase = ReachPhase.RoundStart
	self.Result = C_ReachResultState.new()

	self.ClearMyTings(self)
	self.CheckNoDuplicateInstanceId(self)

	if gMaJiangManager.reachDebug then
		local parts = {}

		for i = 1, self.TotalPlayer do
			if i == round.MyPlayerIndex + 1 then
				local t = {}

				for _, tile in ipairs(round.Seats[i].HandTiles) do
					t[#t + 1] = tostring(tile.InstanceId)
				end

				parts[#parts + 1] = string.format("seat%d:[%s]", i - 1, table.concat(t, ","))
			end
		end
	end
end

M.OnDrawTile = function(self, info)
	local round = self.CurrentRound
	round.CurrentPlayerIndex = info.DrawPlayerIndex

	self.UpdateMahjongSetData(self, round, info.MahjongSetData)

	local drawSeat = round.Seats[info.DrawPlayerIndex + 1]

	table.insert(drawSeat.HandTiles, info.Tile)

	if info.DrawPlayerIndex ~= round.MyPlayerIndex then
		round.LastDraw = info.Tile
		drawSeat.IsZhenting = info.Zhenting
	end

	round.CurrentOperations = info.Operations
	round.CurrentRemainTime = info.RemainTurnTime
	round.CurrentOpKind = gReachMahjongConst.OpKind.InTurn
	round.Phase = ReachPhase.DrawTile

	self.CheckNoDuplicateInstanceId(self)
end

M.OnDiscardOperation = function(self, info)
	local round = self.CurrentRound

	for i = 1, self.TotalPlayer do
		local riverData = info.Rivers[i]
		round.Seats[i].Rivers = riverData and riverData.River or {}
	end

	if info.IsRichiing then
		round.Seats[info.CurrentTurnPlayerIndex + 1].IsRichi = true
	end

	local me = round.Seats[round.MyPlayerIndex + 1]
	me.HandTiles = info.HandTiles
	me.IsZhenting = info.Zhenting
	round.LastDraw = nil
	local discarderIdx = info.CurrentTurnPlayerIndex

	if discarderIdx == round.MyPlayerIndex then
		local discarder = round.Seats[discarderIdx + 1]
		local river = info.Rivers[discarderIdx + 1].River
		local lastTile = river[#river].Tile

		self.RemoveHandTileByInstanceId(self, discarder, lastTile.InstanceId)
	end

	round.CurrentOperations = info.Operations
	round.CurrentRemainTime = info.RemainTurnTime
	round.CurrentOpKind = gReachMahjongConst.OpKind.OutTurn
	round.Phase = ReachPhase.DiscardWait

	self.CheckNoDuplicateInstanceId(self)
end

M.OnOperationPerform = function(self, info)
	local round = self.CurrentRound
	local opSeat = round.Seats[info.OperationPlayerIndex + 1]
	opSeat.OpenMelds = info.HandData.OpenMelds
	opSeat.HandTiles = info.HandData.HandTiles

	for i = 1, self.TotalPlayer do
		local rd = info.Rivers[i]

		if rd then
			round.Seats[i].Rivers = rd.River
		end
	end

	self.UpdateMahjongSetData(self, round, info.MahjongSetData)

	round.CurrentPlayerIndex = info.OperationPlayerIndex
	round.CurrentRemainTime = info.RemainTurnTime
	round.Phase = ReachPhase.OperationPerform

	self.CheckNoDuplicateInstanceId(self)
end

M.OnKongInfo = function(self, info)
	local round = self.CurrentRound
	local seat = round.Seats[info.KongPlayerIndex + 1]
	seat.OpenMelds = info.HandData.OpenMelds
	seat.HandTiles = info.HandData.HandTiles
	round.CurrentOperations = info.Operations
	round.CurrentRemainTime = info.RemainTurnTime
	round.CurrentOpKind = gReachMahjongConst.OpKind.OutTurn

	self.UpdateMahjongSetData(self, round, info.MahjongSetData)

	round.Phase = ReachPhase.OperationPerform

	self.CheckNoDuplicateInstanceId(self)
end

M.OnBeiDora = function(self, info)
	local round = self.CurrentRound
	local seat = round.Seats[info.BeiDoraPlayerIndex + 1]
	seat.BeiDoras = info.BeiDoras
	seat.OpenMelds = info.HandData.OpenMelds
	seat.HandTiles = info.HandData.HandTiles
	round.CurrentOperations = info.Operations
	round.CurrentRemainTime = info.RemainTurnTime
	round.CurrentOpKind = gReachMahjongConst.OpKind.OutTurn

	self.UpdateMahjongSetData(self, round, info.MahjongSetData)

	round.Phase = ReachPhase.OperationPerform

	self.CheckNoDuplicateInstanceId(self)
end

M.OnTurnEnd = function(self, info)
	local round = self.CurrentRound

	for i = 1, self.TotalPlayer do
		round.Seats[i].IsRichi = info.RichiStatus[i]
		round.Seats[i].Points = info.Points[i]
	end

	round.RichiSticks = info.RichiSticks

	if info.PlayerIndex ~= round.MyPlayerIndex then
		round.Seats[round.MyPlayerIndex + 1].IsZhenting = info.Zhenting
	end

	self.UpdateMahjongSetData(self, round, info.MahjongSetData)

	round.CurrentOperations = info.Operations
	round.CurrentRemainTime = 0
	round.CurrentOpKind = gReachMahjongConst.OpKind.OutTurn
	round.Phase = ReachPhase.DiscardWait

	self.CheckNoDuplicateInstanceId(self)
end

M.OnTsumo = function(self, info)
	local round = self.CurrentRound
	self.Result.WinType = gReachMahjongConst.WinType.Tsumo
	self.Result.TsumoInfo = info
	round.Seats[info.TsumoPlayerIndex + 1].Hued = true

	for i = 1, self.TotalPlayer do
		local handData = info.AllHandData[i]

		if handData then
			round.Seats[i].HandTiles = handData.HandTiles
			round.Seats[i].OpenMelds = handData.OpenMelds
		end
	end

	round.DoraIndicators = info.DoraIndicators
	round.UraDoraIndicators = info.UraDoraIndicators
	round.Phase = ReachPhase.Tsumo

	self.CheckNoDuplicateInstanceId(self)
end

M.OnRong = function(self, info)
	local round = self.CurrentRound
	self.Result.WinType = gReachMahjongConst.WinType.Rong
	self.Result.RongInfo = info

	for idx, rongSeat in ipairs(info.RongPlayerIndices) do
		local seat = round.Seats[rongSeat + 1]
		seat.Hued = true
		seat.IsRichi = info.RongPlayerRichiStatus[idx]
	end

	for i = 1, self.TotalPlayer do
		local handData = info.AllHandData[i]

		if handData then
			round.Seats[i].HandTiles = handData.HandTiles
			round.Seats[i].OpenMelds = handData.OpenMelds
		end
	end

	round.DoraIndicators = info.DoraIndicators
	round.UraDoraIndicators = info.UraDoraIndicators
	round.Phase = ReachPhase.Rong

	self.CheckNoDuplicateInstanceId(self)
end

M.OnPointTransfer = function(self, info)
	local round = self.CurrentRound

	for i = 1, self.TotalPlayer do
		round.Seats[i].Points = info.Points[i]
	end

	self.TotalPoints = info.Points
	round.Phase = ReachPhase.PointTransfer
end

M.OnRoundDraw = function(self, info)
	self.Result.WinType = gReachMahjongConst.WinType.RoundDraw
	self.Result.WaitingData = info.WaitingData
	local round = self.CurrentRound

	for i = 1, self.TotalPlayer do
		local handData = info.AllHandData[i]

		if handData then
			round.Seats[i].HandTiles = handData.HandTiles
			round.Seats[i].OpenMelds = handData.OpenMelds
		end
	end

	round.Phase = ReachPhase.RoundDraw

	self.CheckNoDuplicateInstanceId(self)
end

M.OnGameEnd = function(self, info)
	self.Result.WinType = gReachMahjongConst.WinType.GameEnd
	self.Result.GameEndInfo = info

	if self.CurrentRound then
		self.CurrentRound.Phase = ReachPhase.GameEnd
	end
end

M.SetMyTings = function(self, tiles)
	self.MyTings = tiles
end

M.SetMyDiscardTings = function(self, map)
	self.MyDiscardTings = map
end

M.ClearMyTings = function(self)
	self.MyTings = nil
	self.MyDiscardTings = nil
end

M.GetMySeat = function(self)
	return self.CurrentRound.Seats[self.CurrentRound.MyPlayerIndex + 1]
end

M.GetMyHandTiles = function(self)
	return self.GetMySeat(self).HandTiles
end

M.GetMyOpenMelds = function(self)
	return self.GetMySeat(self).OpenMelds
end

M.GetMyRivers = function(self)
	return self.GetMySeat(self).Rivers
end

M.GetMyZhenting = function(self)
	return self.GetMySeat(self).IsZhenting
end

M.GetDoraIndicators = function(self)
	return self.CurrentRound.DoraIndicators
end

M.GetUraDoraIndicators = function(self)
	return self.CurrentRound.UraDoraIndicators
end

M.GetRoundStatus = function(self)
	local r = self.CurrentRound

	return {
		IsDealer = r.MyPlayerIndex ~= r.OyaPlayerIndex,
		TotalPlayer = self.TotalPlayer,
		PrevailingWind = {
			I7tO = 3,
			Rank = r.Field + 1
		},
		SelfWind = self:GetMySeat().SelfWind
	}
end

M.Reset = function(self)
	self.TotalPlayer = 0
	self.TotalPoints = {}
	self.CurrentRound = nil
	self.Result = C_ReachResultState.new()
	self.MyTings = nil
	self.MyDiscardTings = nil
	self._seats = nil
end

return M
