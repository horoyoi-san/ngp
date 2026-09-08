-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MaJiangManager_GM.lua
-- Decompiled from: 00349_MaJiangManager_GM.lua_090b4d6b1337.luajit

local M = C_MaJiangManager
local MahjongRoomType = UX.Game.MahjongRoomType
local MahjongRoomState = UX.Game.MahjongRoomState
local MjSeatRef = require("LX6/Gameplay/Majiang/MjSeatRef")

M.SetDebug = function(self, debug)
	self.debug = debug
end

M.ResetDebugPaiInstanceId = function(self)
	self.debugPaiInstanceId = 100000
end

M.AllocDebugPaiInstanceId = function(self)
	if self.debugPaiInstanceId ~= nil then
		self.ResetDebugPaiInstanceId(self)
	end

	self.debugPaiInstanceId = self.debugPaiInstanceId + 1

	return self.debugPaiInstanceId
end

M.CreateDebugPai = function(self, pai, mType, red)
	local paiValue = tonumber(pai) or 0
	local mTypeValue = tonumber(mType) or tonumber(UX.Game.MjType.Tong) or 1

	return {
		["ZI\\xfd\\xb8\\x88\r\\xbb\\xcc\\xec"] = false,
		InstanceId = self:AllocDebugPaiInstanceId(),
		Index = (mTypeValue - 1) * 9 + paiValue,
		Pai = paiValue,
		MType = mTypeValue,
		Red = red ~= true
	}
end

M.CreateDebugPaiList = function(self, count, startPai, mType)
	local paiList = {}
	local startValue = tonumber(startPai) or 0

	for i = 1, count do
		local pai = (startValue + i - 1) % 9
		paiList[i] = self.CreateDebugPai(self, pai, mType, false)
	end

	return paiList
end

M.CreateDebugPengSequence = function(self, seatID, sourceSeatID, mType)
	local pai = self.CreateDebugPai(self, (seatID * 2 + 1) % 9, mType, false)

	return {
		PCGType = UX.Game.MjPCGType.Peng,
		Pai = pai,
		Source = sourceSeatID,
		SelectPais = {
			self.CreateDebugPai(self, pai.Pai, mType, false),
			self.CreateDebugPai(self, pai.Pai, mType, false)
		}
	}
end

M.CreateDebugSeatInfo = function(self, seatID)
	local mType = UX.Game.MjType.Tong
	local holds = self.CreateDebugPaiList(self, 13, seatID * 2, mType)
	local folds = self.CreateDebugPaiList(self, 8, seatID * 2 + 1, mType)
	local huPais = self.CreateDebugPaiList(self, 1, seatID * 3 + 2, mType)

	return {
		["\\xbf}c"] = 0,
		["~\\xad\\xad\\xbd\\xb3"] = 0,
		HoldsCount = #holds,
		Holds = holds,
		Folds = folds,
		Sequence = {
			self.CreateDebugPengSequence(self, seatID, (seatID + 1) % 4, mType)
		},
		HuPais = huPais
	}
end

M.BindDebugPaiListToWall = function(self, game, seatID, paiList, reason)
	if paiList ~= nil then
		return true
	end

	for i = 1, #paiList do
		local paiInfo = paiList[i]
		local instanceId = paiInfo and paiInfo.InstanceId or 0

		if instanceId < 0 then
			print_error("[Majiang-Manager] BindDebugPaiListToWall invalid instanceId", seatID, reason, i, instanceId)

			return false
		end

		if gClientUtils.IsNil(game.GetCardEntByInstanceId(game, instanceId)) then
			local cardEnt = game.TakeCardFromWall(game, instanceId, seatID, reason, true)

			if gClientUtils.IsNil(cardEnt) then
				print_error("[Majiang-Manager] BindDebugPaiListToWall failed", seatID, reason, i, instanceId)

				return false
			end
		end
	end

	return true
end

M.BindDebugSequenceToWall = function(self, game, seatID, sequence, reason)
	if sequence ~= nil then
		return true
	end

	for i = 1, #sequence do
		local seqInfo = sequence[i]

		if seqInfo == nil then
			if not self.BindDebugPaiListToWall(self, game, seatID, {
				seqInfo.Pai
			}, reason .. "_Pai_" .. tostring(i)) then
				return false
			end

			if not self.BindDebugPaiListToWall(self, game, seatID, seqInfo.SelectPais, reason .. "_Select_" .. tostring(i)) then
				return false
			end
		end
	end

	return true
end

M.RefreshDebugSeatVisual = function(self, game, seatID, seatInfo)
	local renderHolds = game.GetSeatHoldsForRender(game, seatID, nil, "RefreshDebugSeatVisual")

	if renderHolds == nil then
		game.RefreshHandArea(game, seatID, renderHolds, false)
	end

	game.RefreshDiscardArea(game, seatID, seatInfo.Folds, true)
	game.RefreshPengGangArea(game, seatID, seatInfo.Sequence)
	game.RefreshHuArea(game, seatID, seatInfo.HuPais)
end

M.Spoon_TestMahjongMachine = function(self)
	local game = self.GetGame(self)

	if game ~= nil or gClientUtils.IsNil(self.machine) or game.serverGameInfo ~= nil then
		return
	end

	for seatID = 0, 3 do
		local seatInfo = game.serverGameInfo.SeatInfos[seatID + 1]

		if seatInfo ~= nil then
			print_error("[Majiang-Manager] Spoon_TestMahjongMachine seatInfo is nil", seatID)

			return
		end

		if not self.BindDebugPaiListToWall(self, game, seatID, seatInfo.Holds, "DebugHold_" .. tostring(seatID)) then
			return
		end

		if not self.BindDebugPaiListToWall(self, game, seatID, seatInfo.Folds, "DebugFold_" .. tostring(seatID)) then
			return
		end

		if not self.BindDebugSequenceToWall(self, game, seatID, seatInfo.Sequence, "DebugSequence_" .. tostring(seatID)) then
			return
		end

		if not self.BindDebugPaiListToWall(self, game, seatID, seatInfo.HuPais, "DebugHu_" .. tostring(seatID)) then
			return
		end
	end

	local lastSeatID = 1
	local lastSeatInfo = game.serverGameInfo.SeatInfos[lastSeatID + 1]
	local lastFolds = lastSeatInfo and lastSeatInfo.Folds or nil
	game.turnSeatId = lastSeatID
	game.lastDiscardInstanceId = lastFolds and lastFolds[#lastFolds] and lastFolds[#lastFolds].InstanceId or -1

	for seatID = 0, 3 do
		local seatInfo = game.serverGameInfo.SeatInfos[seatID + 1]

		self.RefreshDebugSeatVisual(self, game, seatID, seatInfo)
	end

	game.RefreshMyHandDisplayList(game, true)
end

M.GmMjTest = function(self, machine, agentList)
	gPanelManager:CheckShow(gPanelId.S_EMPTY_FULL_SCREEN_PANEL)

	if agentList.ToTable then
		agentList = agentList.ToTable(agentList) or agentList
	end

	self:ResetDebugPaiInstanceId()
	MjSeatRef:SetMySeatId(0)
	self:Spoon_UseMahjongMachine(machine, ulong.new(0, 0))
	gPanelManager:Close(gPanelId.S_MA_JIANG)

	local myPid = gCS.MyPlayerManager.PlayerUnitId
	self.npcPidList = {}
	self.pidToUnit = {
		[myPid] = gCS.MyPlayerManager.PlayerUnit
	}

	for i = 1, #agentList do
		local agentId = agentList[i]
		local slot = gClientUtils.NotNil(self.machine) and self.machine.playerTransforms and self.machine.playerTransforms[i]

		self:CreateNpcInMaJiang(agentId, slot, 0)
	end

	local playerInfos = {}

	for seatID = 0, 3 do
		playerInfos[seatID + 1] = {
			["Af\\xafZM\\xba\\xf8Hd}WH"] = 0,
			["I\\x99\\xb3\\xaaФ\\xcc-\\xa8+\\xbd"] = 0,
			["~\\xad\\xad\\xbd\\xb3"] = "\\x9d",
			["dFalm,"] = 0,
			SeatIndex = seatID,
			Name = seatID ~= 0 and gPlayerManager.infoLogin.bindData.name or "NPC" .. tostring(seatID),
			AgentInstanceId = ulong.new(0, 0),
			Pid = seatID ~= 0 and myPid or ulong.new(0, seatID + 1),
			PzHeadInfo = {
				["\\o\\xbfcI\\xbf\\xdaBk~WH"] = 0
			}
		}
	end

	local seatInfos = {}

	for seatID = 0, 3 do
		seatInfos[seatID + 1] = self.CreateDebugSeatInfo(self, seatID)
	end

	local usedCards = 0

	for i = 1, #seatInfos do
		local seatInfo = seatInfos[i]
		usedCards = usedCards + #(seatInfo.Holds or {})
		usedCards = usedCards + #(seatInfo.Folds or {})
		usedCards = usedCards + #(seatInfo.HuPais or {})
		local sequence = seatInfo.Sequence or {}

		for j = 1, #sequence do
			local seqInfo = sequence[j]

			if seqInfo == nil then
				usedCards = usedCards + 1 + #(seqInfo.SelectPais or {})
			end
		end
	end

	local game = self:CreateGame()
	game.mySeatID = 0

	game:SetServerRoomInfo({
		RoomType = MahjongRoomType.Npc,
		State = MahjongRoomState.Display,
		PlayerInfos = playerInfos,
		HasReady = {
			false,
			false,
			false,
			false
		}
	})

	game.mySeatID = 0

	MjSeatRef:SetMySeatId(0)
	game:SetServerGameInfo({
		["\\x87\\xb0\\xbf^+\\xec="] = -1,
		[">I\\x9f\\x85\\x86S"] = 0,
		N7oU = 0,
		["*;\\x83\\xf9\\x86\\xa8ا\\xb3\\xbb\\xd8\\xe3&\\xef\\x94$\\x9a\\xfa"] = 0,
		SeatInfos = seatInfos,
		Remainders = math.max(108 - usedCards, 0),
		GameState = UX.Game.MjGameStateEnum.Playing
	})
	game:BeginMajiangGameAfterReceiveServerData()
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, LTConfig.GameplaySignalInwardConfig.MahjongGameStart)
	self:Spoon_TestMahjongMachine()
end
