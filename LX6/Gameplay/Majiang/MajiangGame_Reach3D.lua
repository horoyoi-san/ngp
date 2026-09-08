-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MajiangGame_Reach3D.lua
-- Decompiled from: 00344_MajiangGame_Reach3D.lua_62cadf041b2c.luajit

local M = C_MajiangGame
local MahjongUtils = L18.Mahjong.MahjongUtils
local MjType = UX.Game.MjType
local PCGType = UX.Game.MjPCGType
local MjActionType = UX.Game.MjActionType
local ReachTile = require("LX6/Gameplay/Majiang/Reach/ReachTile")

M.IsReach = function(self)
	return self.manager.gameType ~= UX.Game.MahjongGameType.Reach
end

M.GetTotalCards = function(self)
	return self.rule:GetTotalCards()
end

M.Reach3D_TakeCard = function(self)
	local machine = self.GetMachine(self)

	if gClientUtils.IsNil(machine) then
		return nil
	end

	local cardEnt = machine.GetNextCardInWall(machine)

	if gClientUtils.IsNil(cardEnt) then
		print_error("[Majiang-Reach] TakeCard no wall card")

		return nil
	end

	machine.RemoveOneFromWall(machine)

	return cardEnt
end

M.Reach3D_GetCard = function(self)
	if self.reach3DFreeCards and #self.reach3DFreeCards <= 0 then
		local ent = self.reach3DFreeCards[#self.reach3DFreeCards]
		self.reach3DFreeCards[#self.reach3DFreeCards] = nil

		if not gClientUtils.IsNil(ent) then
			ent.gameObject:SetActive(true)

			return ent
		end
	end

	return self.Reach3D_TakeCard(self)
end

M.Reach3D_SetCardFace = function(self, cardEnt, tile, isBack)
	if gClientUtils.IsNil(cardEnt) then
		return
	end

	if isBack or tile ~= nil then
		cardEnt.cardInfo = MahjongUtils.CreateMahjongCardInfo(1, MjType.Tong, gMaJiangConst.MahjongState.None)
	else
		local pai, mType, isRed = self:GetRule():GetCardDisplayInfo(tile)
		cardEnt.cardInfo = MahjongUtils.CreateMahjongCardInfo(pai, mType, gMaJiangConst.MahjongState.None, isRed)
	end
end

M.Reach3D_PlaceHandCard = function(self, seatID, cardEnt, i)
	local machine = self.GetMachine(self)

	if gClientUtils.IsNil(machine) or gClientUtils.IsNil(cardEnt) then
		return
	end

	local areaTf = machine.handCardArea[seatID]

	if gClientUtils.IsNil(areaTf) then
		return
	end

	cardEnt.transform:SetParent(areaTf)
	machine:ShowCard(cardEnt.transform)

	local posX = -1 * (i - 1) * (self.machineInfo.cardBound.x + LTConfig.MahjongConfig.normalCardInterval)

	self:SetLocalPosition(cardEnt.transform, Vector3.Fetch(posX, 0, 0))

	cardEnt.transform.localRotation = Quaternion.identity
end

M.Reach3D_PlaceDiscardCard = function(self, seatID, cardEnt, i)
	local machine = self.GetMachine(self)

	if gClientUtils.IsNil(machine) or gClientUtils.IsNil(cardEnt) then
		return
	end

	local areaTf = machine.discardArea[seatID]

	if gClientUtils.IsNil(areaTf) then
		return
	end

	cardEnt.transform:SetParent(areaTf)
	machine:ShowCard(cardEnt.transform)
	self:ApplyDiscardSlotTransform(seatID, i, cardEnt.transform)
end

M.Reach3D_RecycleAll = function(self)
	self.reach3DUsedCards = self.reach3DUsedCards or {}

	for i = 1, #self.reach3DUsedCards do
		local ent = self.reach3DUsedCards[i]

		if not gClientUtils.IsNil(ent) then
			ent.gameObject:SetActive(false)

			self.reach3DFreeCards = self.reach3DFreeCards or {}
			self.reach3DFreeCards[#self.reach3DFreeCards + 1] = ent
		end
	end

	self.reach3DUsedCards = {}
end

M.Reach3D_BindMyHandToCardMgr = function(self, handTiles)
	handTiles = handTiles or {}

	for i = 1, #handTiles do
		local tile = handTiles[i]
		local instanceId = tile and tile.InstanceId or 0

		if instanceId <= 0 and gClientUtils.IsNil(self.cardMgr:GetCardEntByInstanceId(instanceId)) then
			self.TakeCardFromWall(self, instanceId, self.mySeatID, "Reach3D_BindMyHand", false, false)
		end
	end
end

M.Reach3D_RefreshAll = function(self, isReveal)
	local machine = self.GetMachine(self)

	if gClientUtils.IsNil(machine) or self.machineInfo ~= nil then
		return
	end

	local state = self.reachGameState

	if state ~= nil or state.CurrentRound ~= nil then
		return
	end

	local round = state.CurrentRound
	local totalPlayer = state.TotalPlayer or 4
	local serverGameInfo = self.serverGameInfo

	if serverGameInfo ~= nil then
		return
	end

	local winType = state.Result and state.Result.WinType
	local waitingData = state.Result and state.Result.WaitingData
	local winTypeConst = gReachMahjongConst.WinType

	for seatID = 0, totalPlayer - 1 do
		local seat = round.Seats[seatID + 1]
		local seatInfo = serverGameInfo.SeatInfos[seatID + 1]

		if seat and seatInfo then
			local open = false

			if isReveal then
				if winType ~= winTypeConst.Tsumo or winType ~= winTypeConst.Rong then
					open = seat.Hued ~= true
				elseif winType ~= winTypeConst.RoundDraw then
					local wd = waitingData and waitingData[seatID + 1]
					open = wd == nil and wd.WaitingTiles == nil and #wd.WaitingTiles >= 0
				end
			end

			self:RefreshHandArea(seatID, seat.HandTiles, open)

			if isReveal then
				seatInfo.Holds = seat.HandTiles or {}
			end

			local riverPaiInfos = self:GetRule():GetDiscardRenderList(seatID)

			self:RefreshDiscardArea(seatID, riverPaiInfos)
			self:RefreshPengGangArea(seatID, seatInfo.Sequence)
		end
	end
end

M.Reach3D_OnRoundPrepare = function(self, prepareInfo)
	if prepareInfo ~= nil then
		return
	end

	local mySeatID = prepareInfo.PlayerIndex or 0
	local myPid = gPlayerManager.infoBase.bindData.Pid
	local names = prepareInfo.PlayerNames or {}
	local points = prepareInfo.Points or {}
	local npcMahjongIds = prepareInfo.NpcMahjongIds or {}
	local npcCultivationIds = prepareInfo.NpcCultivationIds or {}
	local playerInfos = {}

	for i = 1, #names do
		local seatID = i - 1
		playerInfos[i] = {
			["dFalm,"] = 0,
			SeatIndex = seatID,
			Name = names[i],
			Score = tostring(points[i] or 0),
			Pid = seatID ~= mySeatID and myPid or ulong.new(0, seatID + 1),
			PzHeadInfo = {
				["\\o\\xbfcI\\xbf\\xdaBk~WH"] = 0
			},
			NpcMahjongId = npcMahjongIds[i] or 0,
			NpcCultivationId = npcCultivationIds[i] or 0
		}
	end

	self.SetServerRoomInfo(self, {
		RoomType = UX.Game.MahjongRoomType.Npc,
		State = UX.Game.MahjongRoomState.Display,
		PlayerInfos = playerInfos,
		HasReady = {
			false,
			false,
			false,
			false
		}
	})
end

M.Reach3D_OnRoundStart = function(self, startInfo)
	if startInfo ~= nil then
		return
	end

	local state = self.reachGameState

	if state ~= nil or state.CurrentRound ~= nil then
		return
	end

	local machine = self.GetMachine(self)

	if gClientUtils.IsNil(machine) then
		print_warn("[Majiang-Reach] OnRoundStart machine not ready")

		return
	end

	local round = state.CurrentRound
	local totalPlayer = state.TotalPlayer or 4
	local seatInfos = {}

	for seatID = 0, totalPlayer - 1 do
		local seat = round.Seats[seatID + 1]
		local holds = seat and seat.HandTiles or {}
		seatInfos[seatID + 1] = {
			["\\xbf}c"] = 0,
			Score = startInfo.Points and startInfo.Points[seatID + 1] or 0,
			HoldsCount = #holds,
			Holds = holds,
			Folds = {},
			Sequence = {},
			HuPais = {}
		}
	end

	self:SetServerGameInfo({
		["\\x87\\xb0\\xbf^+\\xec="] = -1,
		["*;\\x83\\xf9\\x86\\xa8ا\\xb3\\xbb\\xd8\\xe3&\\xef\\x94$\\x9a\\xfa"] = -1,
		GameState = UX.Game.MjGameStateEnum.Playing,
		Banker = startInfo.OyaPlayerIndex or 0,
		Turn = startInfo.PlayerIndex or 0,
		Remainders = startInfo.MahjongSetData and startInfo.MahjongSetData.TilesRemain or 0,
		SeatInfos = seatInfos,
		DoraIndicatorLs = {}
	})
	L18.Mahjong.MahjongUtils.DisableCheckStippleAlpha(true)
	self:BeginMajiangGameAfterReceiveServerData()

	for seatID = 0, totalPlayer - 1 do
		local fsm = self.GetCharacterFSM(self, seatID)

		if fsm then
			fsm.ForceTransitToState(fsm, gMaJiangConst.MjStateType.Idle)
		end
	end
end

M.Reach3D_OnDrawTile = function(self, info)
	local state = self.reachGameState

	if state ~= nil or state.CurrentRound ~= nil then
		return
	end

	local round = state.CurrentRound
	local seatID = info.DrawPlayerIndex
	local tile = info.Tile

	if tile ~= nil or (tile.InstanceId or 0) < 0 then
		return
	end

	self.FinishAllPendingAttaches(self, "ReachDrawTile")

	local wallDirection = -1
	local wallPileIndex = -1
	local cardEnt = self.GetCardEntByInstanceId(self, tile.InstanceId)

	if gClientUtils.NotNil(cardEnt) then
		self.ConsumeNextMoPaiFromTail(self)
	else
		local drawFromTail = self.ConsumeNextMoPaiFromTail(self)
		cardEnt, wallDirection, wallPileIndex = self.TakeCardFromWall(self, tile.InstanceId, seatID, "ReachDrawTile", false, drawFromTail)
	end

	if gClientUtils.IsNil(cardEnt) then
		return
	end

	if seatID == round.MyPlayerIndex then
		cardEnt.cardInfo = MahjongUtils.CreateMahjongCardInfo(1, 1, gMaJiangConst.MahjongState.None)
	else
		local pai, mType, isRed = self:GetRule():GetCardDisplayInfo(tile)
		cardEnt.cardInfo = MahjongUtils.CreateMahjongCardInfo(pai, mType, gMaJiangConst.MahjongState.None, isRed)
	end

	local fsm = self:GetCharacterFSM(seatID)

	fsm:SetHandCardsFromInfo(round.Seats[seatID + 1].HandTiles)

	local tokenId = self.cardMgr:BeginFlow(tile.InstanceId, "Draw", seatID, -1)

	fsm:QueueNextAttach(cardEnt, tile, gMaJiangConst.AttachType.DrawCard, tokenId, tile.InstanceId)
	self:FSM_TriggerDrawCard(seatID, tile.InstanceId, wallDirection, wallPileIndex)
end

M.Reach3D_OnDiscardOperation = function(self, info)
	local state = self.reachGameState

	if state ~= nil or state.CurrentRound ~= nil then
		return
	end

	local round = state.CurrentRound
	local seatID = info.CurrentTurnPlayerIndex
	local tile = info.Tile

	if tile ~= nil or (tile.InstanceId or 0) < 0 then
		return
	end

	local serverGameInfo = self.serverGameInfo

	if serverGameInfo ~= nil or self.fsmDisposed then
		return
	end

	self.FinishAllPendingAttaches(self, "ReachDiscard")

	local fsm = self.GetCharacterFSM(self, seatID)

	if fsm and fsm.GetState(fsm) ~= gMaJiangConst.MjStateType.DrawCard then
		fsm.ForceTransitToState(fsm, gMaJiangConst.MjStateType.Idle)
	end

	local seatInfo = serverGameInfo.SeatInfos[seatID + 1]
	seatInfo.HoldsCount = #round.Seats[seatID + 1].HandTiles
	local folds = seatInfo.Folds
	folds[#folds + 1] = tile
	self.lastDiscardInstanceId = tile.InstanceId
	self.lastGangId = -1

	if fsm.discardTriggeredByUI then
		fsm.discardTriggeredByUI = false
	end

	fsm.SetHandCardsFromInfo(fsm, round.Seats[seatID + 1].HandTiles)

	local DoChuPaiAction = function()
		self:DoChuPaiActionImpl(seatID, tile, serverGameInfo, fsm)
	end

	if fsm.GetState(fsm) ~= gMaJiangConst.MjStateType.DrawCard then
		fsm.SetPendingTask(fsm, DoChuPaiAction)
	else
		DoChuPaiAction()
	end
end

M.Reach3D_OnOperationPerform = function(self, info)
	local state = self.reachGameState

	if state ~= nil or state.CurrentRound ~= nil then
		return
	end

	local round = state.CurrentRound
	local seatID = info.OperationPlayerIndex
	local op = info.Operation

	if op ~= nil then
		return
	end

	local opType = op.Type

	if opType == UX.Game.OutTurnOperationType.Pong and opType == UX.Game.OutTurnOperationType.Chow and opType == UX.Game.OutTurnOperationType.Kong then
		return
	end

	local serverGameInfo = self.serverGameInfo

	if serverGameInfo ~= nil then
		return
	end

	self.FinishAllPendingAttaches(self, "ReachOpPerform")

	local tile = op.Tile
	local meld = op.Meld
	local instanceId = tile.InstanceId
	local sourceSeatID = self.RemoveFromLastFolds(self, tile)

	if sourceSeatID >= 0 then
		print_error("[Majiang-Manager] Reach3D_OnOperationPerform RemoveFromLastFolds not found", seatID, instanceId)
	end

	local sourceFSM = self.GetCharacterFSM(self, sourceSeatID)

	if sourceFSM then
		sourceFSM.ClearPendingDiscard(sourceFSM, instanceId)
	end

	local selectPais = {}

	for _, t in ipairs(meld.Meld.Tiles) do
		if t.InstanceId == instanceId then
			selectPais[#selectPais + 1] = t
		end
	end

	local pcgType, actionType = nil

	if opType ~= UX.Game.OutTurnOperationType.Pong then
		pcgType = PCGType.Peng
		actionType = nil
	elseif opType ~= UX.Game.OutTurnOperationType.Chow then
		pcgType = PCGType.Chi
		actionType = nil
	else
		pcgType = PCGType.MingGang
		actionType = MjActionType.MingGang
	end

	local seq = serverGameInfo.SeatInfos[seatID + 1].Sequence
	seq[#seq + 1] = {
		Pai = tile,
		Source = sourceSeatID,
		SelectPais = selectPais,
		PCGType = pcgType
	}
	local fsm = self.GetCharacterFSM(self, seatID)

	fsm.SetHandCardsFromInfo(fsm, round.Seats[seatID + 1].HandTiles)

	if opType ~= UX.Game.OutTurnOperationType.Kong then
		self.lastGangId = seatID

		self.MarkNextMoPaiFromTail(self)
	end

	local outCardEnt = self:GetCardEntByInstanceId(instanceId)
	local outCardState = self:GetCardStateByInstanceId(instanceId)
	local outCardPosition = outCardState and outCardState.plannedWorldPos or gClientUtils.NotNil(outCardEnt) and outCardEnt.transform.position or nil
	local flowType = opType ~= UX.Game.OutTurnOperationType.Kong and "Gang" or "Peng"
	local tokenId = self.cardMgr:BeginFlow(instanceId, flowType, seatID, sourceSeatID)

	fsm:QueueNextAttach(outCardEnt, tile, gMaJiangConst.AttachType.ChiPongKong, tokenId, instanceId)
	self:FSM_TriggerChiPongKong(seatID, true, instanceId, sourceSeatID, outCardPosition, actionType)
end

M.Reach3D_OnKongInfo = function(self, info)
	local state = self.reachGameState

	if state ~= nil or state.CurrentRound ~= nil then
		return
	end

	local round = state.CurrentRound
	local seatID = info.KongPlayerIndex
	local serverGameInfo = self.serverGameInfo

	if serverGameInfo ~= nil then
		return
	end

	self.FinishAllPendingAttaches(self, "ReachKongInfo")

	local openMelds = info.HandData.OpenMelds
	local meld = openMelds[info.MeldIndex + 1]
	local meldData = meld.Meld
	local seatInfo = serverGameInfo.SeatInfos[seatID + 1]
	local seq = seatInfo.Sequence
	local instanceId, tile, selectPais, actionType = nil
	local sourceSeatID = -1

	if meld.IsAdded then
		actionType = MjActionType.JiaGang
		tile = meld.Extra
		instanceId = tile.InstanceId
		selectPais = {
			tile
		}

		for _, s in ipairs(seq) do
			if s.PCGType ~= PCGType.Peng and self.CheckSamePai(self, s.Pai, tile) then
				s.PCGType = PCGType.JiaGang
				s.SelectPais[#s.SelectPais + 1] = tile

				break
			end
		end
	else
		actionType = MjActionType.AnGang
		tile = meldData.Tiles[1]
		instanceId = tile.InstanceId
		selectPais = {}

		for i = 2, #meldData.Tiles do
			selectPais[#selectPais + 1] = meldData.Tiles[i]
		end

		seq[#seq + 1] = {
			["/G\\x84\\x9c\\x80D"] = -1,
			Pai = tile,
			SelectPais = selectPais,
			PCGType = PCGType.AnGang
		}
	end

	local fsm = self:GetCharacterFSM(seatID)

	fsm:SetHandCardsFromInfo(round.Seats[seatID + 1].HandTiles)

	self.lastGangId = seatID

	self:MarkNextMoPaiFromTail()

	local outCardEnt = self:GetCardEntByInstanceId(instanceId)
	local outCardState = self:GetCardStateByInstanceId(instanceId)
	local outCardPosition = outCardState and outCardState.plannedWorldPos or gClientUtils.NotNil(outCardEnt) and outCardEnt.transform.position or nil
	local tokenId = self.cardMgr:BeginFlow(instanceId, "Gang", seatID, sourceSeatID)

	fsm:QueueNextAttach(outCardEnt, tile, gMaJiangConst.AttachType.ChiPongKong, tokenId, instanceId)
	self:FSM_TriggerChiPongKong(seatID, false, instanceId, sourceSeatID, outCardPosition, actionType)
end

M.Reach3D_OnBeiDora = function(self, info)
	self.Reach3D_RefreshAll(self)
end

M.Reach3D_OnTsumo = function(self, info)
	self.FinishAllPendingAttaches(self, "ReachTsumo")
	self.Reach3D_RefreshAll(self, true)
end

M.Reach3D_OnRong = function(self, info)
	self.FinishAllPendingAttaches(self, "ReachRong")
	self.Reach3D_RefreshAll(self, true)
end

M.Reach3D_OnTurnEnd = function(self, info)
	local state = self.reachGameState

	if state and state.CurrentRound then
		self.turnSeatId = state.CurrentRound.CurrentPlayerIndex
	end
end

M.Reach3D_OnPointTransfer = function(self, info)
	local seatInfos = self.serverGameInfo and self.serverGameInfo.SeatInfos

	if seatInfos ~= nil then
		return
	end

	local points = info.Points or {}

	for i = 1, #points do
		if seatInfos[i] then
			seatInfos[i].Score = points[i]
		end
	end
end

M.Reach3D_OnRoundDraw = function(self, info)
	self.FinishAllPendingAttaches(self, "ReachRoundDraw")
	self.Reach3D_RefreshAll(self, true)
end

M.Reach3D_OnGameEnd = function(self, info)
end
