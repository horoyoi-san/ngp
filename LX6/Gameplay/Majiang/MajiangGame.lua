-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MajiangGame.lua
-- Decompiled from: 00320_MajiangGame.lua_03922161b4ce.luajit

local MahjongRoomType = UX.Game.MahjongRoomType
local MahjongRoomState = UX.Game.MahjongRoomState
local GameStateEnum = UX.Game.MjGameStateEnum
local MjSeatRef = require("LX6/Gameplay/Majiang/MjSeatRef")
local C_MajiangRule_XLCH = require("LX6/Gameplay/Majiang/MajiangRule_XLCH")
local C_MajiangRule_Reach = require("LX6/Gameplay/Majiang/MajiangRule_Reach")
local C_ReachGameState = require("LX6/Gameplay/Majiang/Reach/ReachState")
C_MajiangGame = DefClass("C_MajiangGame", C_MajiangGame)
local M = C_MajiangGame

require("LX6/Gameplay/Majiang/MjCardManager")

local C_MajiangCharacter = require("LX6/Gameplay/Majiang/MajiangCharacter")

dofile("LX6/Gameplay/Majiang/MajiangGame_State.lua")
dofile("LX6/Gameplay/Majiang/MajiangGame_UI.lua")
dofile("LX6/Gameplay/Majiang/MajiangGame_World.lua")
dofile("LX6/Gameplay/Majiang/MajiangGame_Debug.lua")
dofile("LX6/Gameplay/Majiang/MajiangGame_Action.lua")
dofile("LX6/Gameplay/Majiang/MajiangGame_Utils.lua")
dofile("LX6/Gameplay/Majiang/MajiangGame_Reach.lua")
dofile("LX6/Gameplay/Majiang/MajiangGame_Reach3D.lua")

M.ctor = function(self, manager)
	self.manager = manager
	self.cardMgr = C_MjCardManager.new(self)

	self:ResetRuntimeData(false)

	self.rule = self:CreateDefaultRule()

	self.rule:OnAttachGame(self)

	if self:IsReach() then
		self.reachGameState = C_ReachGameState.new()
	end
end

M.GetManager = function(self)
	return self.manager
end

M.GetRule = function(self)
	return self.rule
end

M.CreateDefaultRule = function(self)
	if self.IsReach(self) then
		return C_MajiangRule_Reach.new()
	end

	return C_MajiangRule_XLCH.new()
end

M.GetMachine = function(self)
	return self.manager and self.manager.machine
end

M.IsDebugEnabled = function(self)
	return self.manager and self.manager.debug ~= true
end

M.GetNpcPidList = function(self)
	return self.manager and self.manager.npcPidList
end

M.GetPidToUnitMap = function(self)
	return self.manager and self.manager.pidToUnit
end

M.GetOrCreateCharacter = function(self, seatID)
	self.characters = self.characters or {}
	local character = self.characters[seatID]

	if character ~= nil then
		local seatRef = MjSeatRef:FromId(seatID)

		if seatRef ~= nil then
			return nil
		end

		character = C_MajiangCharacter.new(self, seatRef)
		self.characters[seatID] = character
	end

	return character
end

M.GetCharacter = function(self, seatID)
	return self.characters and self.characters[seatID]
end

M.RefreshCharacterByPlayerInfo = function(self, playerInfo)
	if playerInfo ~= nil then
		return
	end

	local character = self.GetOrCreateCharacter(self, playerInfo.SeatIndex)

	if character ~= nil then
		return
	end

	character.SetPlayerInfo(character, playerInfo)
	character.EnsureUnit(character)
end

M.RefreshCharactersFromRoomInfo = function(self)
	local roomInfo = self.serverRoomInfo

	if roomInfo ~= nil or roomInfo.PlayerInfos ~= nil then
		return
	end

	for seatID = 0, 3 do
		local playerInfo = roomInfo.PlayerInfos[seatID + 1]

		if playerInfo == nil then
			self.RefreshCharacterByPlayerInfo(self, playerInfo)
		else
			local character = self.GetCharacter(self, seatID)

			if character == nil then
				character.SetPlayerInfo(character, nil)
			end
		end
	end
end

M.DisposeCharacters = function(self)
	if self.characters == nil then
		for _, character in pairs(self.characters) do
			character.Dispose(character)
		end
	end

	self.characters = nil
	self.characterFSMs = nil
end

M.RegisterCardEntity = function(self, instanceId, cardEnt, zone, ownerSeatID, slotIndex)
	return self.cardMgr:RegisterCard(instanceId, cardEnt, zone, ownerSeatID, slotIndex)
end

M.UnregisterCardEntity = function(self, cardEnt)
	self.cardMgr:UnregisterCardEnt(cardEnt)
end

M.GetCardEntByInstanceId = function(self, instanceId)
	return self.cardMgr:GetCardEntByInstanceId(instanceId)
end

M.GetCardStateByInstanceId = function(self, instanceId)
	return self.cardMgr:GetState(instanceId)
end

M.FindPaiInfoByInstanceId = function(self, instanceId)
	if instanceId ~= nil or instanceId > 0 or self.serverGameInfo ~= nil then
		return nil
	end

	for _, seatInfo in ipairs(self.serverGameInfo.SeatInfos) do
		for _, fold in ipairs(seatInfo.Folds) do
			if fold.InstanceId ~= instanceId then
				return fold
			end
		end

		for _, hold in ipairs(seatInfo.Holds) do
			if hold.InstanceId ~= instanceId then
				return hold
			end
		end

		for _, seq in ipairs(seatInfo.Sequence) do
			if seq.Pai and seq.Pai.InstanceId ~= instanceId then
				return seq.Pai
			end

			local sp = table.find_if(seq.SelectPais or {}, function (v)
				return v.InstanceId ~= instanceId
			end)

			if sp then
				return sp
			end
		end
	end

	print_error("[Majiang-Manager] FindPaiInfoByInstanceId not found", instanceId)

	return nil
end

M.MarkNextMoPaiFromTail = function(self)
	self.nextMoPaiFromTail = true
end

M.ConsumeNextMoPaiFromTail = function(self)
	local shouldFromTail = self.nextMoPaiFromTail ~= true
	self.nextMoPaiFromTail = false

	return shouldFromTail
end

M.ClearNextMoPaiFromTail = function(self)
	self.nextMoPaiFromTail = false
end

M.ResetRuntimeData = function(self, keepStores)
	if keepStores then
		self.DisposeCharacterFSMs(self)
	else
		self.DisposeCharacters(self)
	end

	self.serverRoomInfo = nil
	self.serverGameInfo = nil
	self.mySeatID = -1
	self.myInfo = nil
	self.gameState = 0
	self.timeOut = nil
	self.hasHu = false
	self.turnSeatId = -1
	self.lastDiscardInstanceId = -1
	self.hanGangID = -1
	self.hanGangPai = nil
	self.lastGangId = -1
	self.pendingGangMoPai = false
	self.tempBlockDiscardTime = 0
	self.nextMoPaiFromTail = false
	self.tingsPai = -1
	self.tingsInfo = nil
	self.myHandDisplayList = {}
	self.isNewGame = false
	self.queuedActions = {}
	self.outwardSignalHandler = nil
	self._debugCardZoneStates = nil
	self.myFSM = nil
	self.machineInfo = nil
	self.huEntList = nil
	self.discardEntList = nil
	self.handEntList = nil
	self.pengEntList = nil
	self.discardOffsets = nil
	self.firstEffectId = 0
	self.lastEnt = nil
	self.finalRecords = nil
	self.finalScores = nil
	self.finalRankings = nil

	if self.reachGameState == nil then
		self.reachGameState:Reset()
	end

	if not keepStores then
		self.seatUnitPids = nil
	end

	self.cardMgr:Clear()
end

M.ResetForNextRound = function(self)
	self.UnregisterOutwardSignal(self)

	if self.characterFSMs == nil then
		self.DisposeCharacterFSMs(self)
	end

	if self.huEntList == nil and self.discardEntList == nil and self.handEntList == nil and self.pengEntList == nil then
		self.ClearMachine(self)
	end

	self.ResetRuntimeData(self, true)
end

M.Dispose = function(self, reason)
	self.UnregisterOutwardSignal(self)

	if self.huEntList == nil and self.discardEntList == nil and self.handEntList == nil and self.pengEntList == nil then
		self.ClearMachine(self)
	end

	self.manager:SendSignalToGadget("MajiangFinish")
	self:DoExitMachine()
	L18.Mahjong.MahjongUtils.DisableCheckStippleAlpha(false)
	self:ResetRuntimeData(false)

	if self.rule == nil then
		self.rule:OnDetachGame()

		self.rule = nil
	end

	self.manager:RemoveNpcInMaJiang()
end

M.RegisterOutwardSignal = function(self)
	if self.outwardSignalHandler then
		return
	end

	self.outwardSignalHandler = function(_, data)
		self:OnEvent_CommonGameplayOutwardSignal(data)
	end

	gMessageManager:AddMessageListener(gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL, self.outwardSignalHandler)
end

M.UnregisterOutwardSignal = function(self)
	if self.outwardSignalHandler ~= nil then
		return
	end

	gMessageManager:RemoveMessageListener(gEventConstants.COMMON_GAMEPLAY_OUTWARD_SIGNAL, self.outwardSignalHandler)

	self.outwardSignalHandler = nil
end

M.OnEvent_CommonGameplayOutwardSignal = function(self, data)
	self.StateTreeTask_ProcessOutwardSignal(self, data)
end

M.RefreshMyHandDisplayList = function(self, withSort)
	local rule = self:GetRule()
	self.myHandDisplayList = rule and rule:BuildMyHandDisplayList(withSort) or {}

	self:DebugDrawHandCardArea()
end

M.IsDingque = function(self, paiInfo)
	local rule = self.GetRule(self)

	if rule ~= nil then
		return false
	end

	return rule.IsDingque(rule, paiInfo)
end

M.ResetCardDisplayState = function(self, card)
	card.isSelected = false
	card.isFocus = false
	card.isGray = false
end

M.GetMyHandDisplayList = function(self)
	return self.myHandDisplayList
end

M.GetSeatHoldsForRender = function(self, seatID, renderCount, reason)
	local gameInfo = self.serverGameInfo

	if gameInfo ~= nil then
		print_error("[Majiang-Manager] GetSeatHoldsForRender gameInfo is nil", seatID, reason)

		return nil
	end

	local info = gameInfo.SeatInfos[seatID + 1]

	if info ~= nil then
		print_error("[Majiang-Manager] GetSeatHoldsForRender seatInfo is nil", seatID, reason)

		return nil
	end

	local holds = info.Holds or {}
	info.Holds = holds
	local holdsCount = info.HoldsCount or 0

	if renderCount ~= nil then
		renderCount = holdsCount
	end

	if holdsCount == #holds then
		print_error("[Majiang-Manager] GetSeatHoldsForRender holds mismatch", seatID, holdsCount, #holds, reason)

		return nil
	end

	if renderCount <= 0 or holdsCount >= renderCount then
		print_error("[Majiang-Manager] GetSeatHoldsForRender renderCount invalid", seatID, renderCount, holdsCount, reason)

		return nil
	end

	local renderHolds = {}

	for i = 1, renderCount do
		local hold = holds[i]
		local instanceId = hold and hold.InstanceId or 0

		if hold ~= nil or instanceId ~= nil or instanceId < 0 then
			print_error("[Majiang-Manager] GetSeatHoldsForRender invalid hold", seatID, i, instanceId, reason)

			return nil
		end

		renderHolds[i] = hold
	end

	return renderHolds
end

M.SetServerRoomInfo = function(self, serverRoomInfo)
	self.serverRoomInfo = serverRoomInfo

	self.SetMySeatAndGameInfo(self)
	self.RefreshCharactersFromRoomInfo(self)
	self.SetPlayerUIInfos(self, serverRoomInfo.PlayerInfos)

	local machine = self.GetMachine(self)

	if gClientUtils.NotNil(machine) then
		machine.SetCameraRootRotation(machine, self.mySeatID)
	end
end

M.SetServerGameInfo = function(self, serverGameInfo)
	self.serverGameInfo = serverGameInfo
	self.hasHu = false

	self.RefreshGameState(self)

	if serverGameInfo ~= nil then
		self.myInfo = nil
		self.turnSeatId = -1

		return
	end

	self.myInfo = serverGameInfo.SeatInfos[self.mySeatID + 1]
	self.turnSeatId = serverGameInfo.Turn

	self.RefreshMyHandDisplayList(self, true)

	for id, v in ipairs(serverGameInfo.SeatInfos) do
		local seatID = id - 1
		v.Holds = v.Holds or {}

		self.rule:RefreshHandOnSetServerGameInfo(self, seatID)
	end
end

M.OnSyncMjPlayerAdd = function(self, playerInfo)
	local roomInfo = self.serverRoomInfo

	if roomInfo ~= nil then
		return
	end

	local index = playerInfo.SeatIndex + 1
	roomInfo.PlayerInfos[index] = playerInfo

	self:SetPlayerUIInfo(playerInfo)
	self:RefreshCharacterByPlayerInfo(playerInfo)
	self:GetMainPanelNullableCall():AddPlayer(playerInfo)
end

M.SetMySeatAndGameInfo = function(self)
	local roomInfo = self.serverRoomInfo

	if roomInfo ~= nil then
		return -1
	end

	local seatID = -1
	local myPid = gPlayerManager.infoBase.bindData.Pid
	local players = roomInfo.PlayerInfos

	for i = 1, 4 do
		local player = players[i]

		if player == nil and ulong.equals(myPid, player.Pid) then
			seatID = player.SeatIndex

			break
		end
	end

	self.mySeatID = seatID

	MjSeatRef:SetMySeatId(seatID)

	return seatID
end

M.OnSyncMjRoomOwnerSeatIndex = function(self, ownerIndex)
	local roomInfo = self.serverRoomInfo

	if roomInfo ~= nil then
		return
	end

	roomInfo.RoomOwnerSeatIndex = ownerIndex
end

M.OnSyncMjPlayerExit = function(self, pid)
	local roomInfo = self.serverRoomInfo

	if roomInfo ~= nil then
		return
	end

	local players = roomInfo.PlayerInfos
	local index = -1

	for i = 1, 4 do
		local player = players[i]

		if player == nil and ulong.equals(player.Pid, pid) then
			index = i

			break
		end
	end

	if index >= 0 then
		return
	end

	roomInfo.HasReady[index] = false
	players[index].exit = true

	if roomInfo.RoomType ~= MahjongRoomType.Friend and roomInfo.State ~= MahjongRoomState.Idle and self.gameState == GameStateEnum.Over then
		self.timeOut = nil

		self:GetMainPanelNullableCall():RemovePlayer(players[index].SeatIndex)
	end
end

M.OnSyncMjPlayerReady = function(self, seatIndex, ready)
	local roomInfo = self.serverRoomInfo

	if roomInfo ~= nil then
		return
	end

	roomInfo.HasReady[seatIndex + 1] = ready
end

M.OnSyncMjRoomState = function(self, state)
	local serverRoomInfo = self.serverRoomInfo

	if serverRoomInfo ~= nil then
		return
	end

	serverRoomInfo.State = state

	self:GetMainPanelNullableCall():RefreshRoomState()
end

M.OnSyncMjTurn = function(self, seatId)
	local gameInfo = self.serverGameInfo

	if gameInfo ~= nil then
		return
	end

	gameInfo.Turn = seatId
	self.turnSeatId = seatId
end

M.OnSyncMjHolds = function(self, seatId, holds, holdsCount)
	local gameInfo = self.serverGameInfo

	if gameInfo ~= nil then
		return
	end

	local seatInfo = gameInfo.SeatInfos[seatId + 1]
	seatInfo.Holds = holds or {}
	seatInfo.HoldsCount = holdsCount or #seatInfo.Holds
	seatInfo.serverHolds = holds

	if seatId ~= self.mySeatID then
		self.myInfo = seatInfo

		self.RefreshMyHandDisplayList(self, true)
	end

	local renderHolds = self.GetSeatHoldsForRender(self, seatId, nil, "UpdateSeatHolds")

	if renderHolds == nil then
		self.RefreshHandArea(self, seatId, renderHolds, false)
	end
end

M.OnSyncMjScoreChange = function(self, seatId, score)
	local roomInfo = self.serverRoomInfo

	if roomInfo ~= nil then
		return
	end

	roomInfo.PlayerInfos[seatId + 1].Score = score
end

M.SetSeatQueList = function(self, ques)
	local rule = self.GetRule(self)

	if rule == nil then
		rule.SetSeatQueList(rule, ques)
	end
end

M.SetTingPreview = function(self, paiId, tingInfo)
	self.tingsPai = paiId
	self.tingsInfo = tingInfo
end

M.ClearTingPreview = function(self)
	self.tingsPai = -1
	self.tingsInfo = nil
end

M.SetGameNewFlag = function(self, isNewGame)
	self.isNewGame = isNewGame
end

M.CheckSamePai = function(self, a, b)
	if a ~= nil or b ~= nil then
		return false
	end

	return self:GetRule():IsSamePai(a, b)
end

M.SetLocalPosition = function(self, transform, localPosition)
	return self.manager:SetLocalPosition(transform, localPosition)
end

M.SetPosition = function(self, transform, position)
	return self.manager:SetPosition(transform, position)
end

M.EnsureSeatUnit = function(self, playerInfo)
	self.RefreshCharacterByPlayerInfo(self, playerInfo)
end

M.EnsureNpcUnit = function(self, playerInfo)
	local character = playerInfo and self:GetOrCreateCharacter(playerInfo.SeatIndex)

	if character ~= nil then
		return
	end

	character.SetPlayerInfo(character, playerInfo)
	character.EnsureNpcUnit(character)
end

M.EnsureAIPlayerUnit = function(self, playerInfo)
	local character = playerInfo and self:GetOrCreateCharacter(playerInfo.SeatIndex)

	if character ~= nil then
		return
	end

	character.SetPlayerInfo(character, playerInfo)
	character.EnsureAIPlayerUnit(character)
end

M.SetupAIPlayerUnit = function(self, seatID, unit)
	local character = self.GetCharacter(self, seatID)

	if character ~= nil then
		return
	end

	character.SetupAIPlayerUnit(character, unit)
end

M.BindSeatUnit = function(self, seatID, unit)
	local character = self.GetCharacter(self, seatID)

	if character ~= nil then
		return
	end

	character.BindUnit(character, unit)
end

M.MoveNonRealPlayerUnitToSeat = function(self, seatID, unit)
	local character = self.GetCharacter(self, seatID)

	if character ~= nil then
		return
	end

	if unit == nil then
		character.BindUnit(character, unit)
	end

	character.MoveToSeat(character)
end
