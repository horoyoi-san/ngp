local GameStateEnum = UX.Game.MjGameStateEnum
local MjActionType = UX.Game.MjActionType
local MahjongRoomState = UX.Game.MahjongRoomState
local PCGType = UX.Game.MjPCGType
local MahjongPlayerToClientImpl = gRpcChecker:CreateRpcImpl()

function MahjongPlayerToClientImpl.SyncMjLoginResult(roomInfo)
	gMaJiangManager:SetRoomInfo(roomInfo)
	gMaJiangManager:SetGameInfo(nil)
	gMaJiangManager:OnNewGame()
	gMaJiangManager:RefreshMaJiangPanel("RefreshRoom")

	gLuaUIMgr.mjMatchTimestamp = nil
end

function MahjongPlayerToClientImpl.SyncMjGameInfo(gameInfo, elapsedTime)
	gMaJiangManager:SetGameInfo(gameInfo)
	gMaJiangManager:RefreshTimeOutByState(elapsedTime)
	gMaJiangManager:RefreshMaJiangPanel("RefreshGame")

	gLuaUIMgr.mjMatchTimestamp = nil
end

function MahjongPlayerToClientImpl.SyncMjPlayerExit(pid)
	gMaJiangManager:OnPlayerExit(pid)
end

function MahjongPlayerToClientImpl.SyncMjPlayerAdd(playerInfo)
	local roomInfo = gMaJiangManager.roomInfo

	if roomInfo == nil then
		return
	end

	local index = playerInfo.SeatIndex + 1
	roomInfo.PlayerInfos[index] = playerInfo

	if playerInfo.NpcCultivationId ~= 0 then
		playerInfo.Name = LTConfig.NpcCultivationConfig.GetConfig(playerInfo.NpcCultivationId).Name
	end

	gMaJiangManager:RunAction("AddPlayer", playerInfo)
end

function MahjongPlayerToClientImpl.SyncMjPlayerReady(seatIndex)
	local roomInfo = gMaJiangManager.roomInfo

	if roomInfo == nil then
		return
	end

	local index = seatIndex + 1
	roomInfo.HasReady[index] = true

	gMaJiangManager:RunAction("OnPlayerReady", seatIndex)
end

function MahjongPlayerToClientImpl.SyncMjRoomState(state)
	local roomInfo = gMaJiangManager.roomInfo

	if roomInfo == nil then
		return
	end

	roomInfo.State = state
	gMaJiangManager.roomState = state

	gMaJiangManager:RunAction("RefreshRoomState")

	if state == MahjongRoomState.Display then
		gPanelManager:CheckShow(gPanelId.MA_JIANG_LOADING)
	elseif state == MahjongRoomState.Begin then
		gPanelManager:Close(gPanelId.MA_JIANG_LOADING)
	end
end

function MahjongPlayerToClientImpl.SyncMjDingQueBegin(defaultQue, elapsedTime)
	gMaJiangManager:SetGameState(GameStateEnum.DingQue)
	gMaJiangManager:RefreshTimeOutByState(elapsedTime)
	gMaJiangManager:RunAction("BeginDingque", defaultQue)
end

function MahjongPlayerToClientImpl.SyncMjDingQue(ques)
	local gameInfo = gMaJiangManager.gameInfo

	if gameInfo == nil then
		return
	end

	local seats = gameInfo.SeatInfos

	for i = 1, #ques do
		seats[i].Que = ques[i]
	end

	gMaJiangManager:RunAction("FinishDingque", ques)
end

function MahjongPlayerToClientImpl.SyncMjTurn(seatId, elapsedTime)
	local isFirst = gMaJiangManager.gameState ~= GameStateEnum.Playing

	if isFirst then
		gMaJiangManager:SetGameState(GameStateEnum.Playing)
	end

	gMaJiangManager:RefreshTimeOutByState(elapsedTime)

	local gameInfo = gMaJiangManager.gameInfo

	if gameInfo ~= nil then
		gameInfo.Turn = seatId
	end

	gMaJiangManager:RunAction("RefreshTurn", seatId)

	if isFirst then
		gMaJiangManager:RunAction("CheckBankerHint")
	end
end

function MahjongPlayerToClientImpl.SyncMjChuPai(seatId, pai)
	gMaJiangManager:OnChuPai(seatId, pai)
end

function MahjongPlayerToClientImpl.SyncMjScoreChange(seatId, score, change)
	local roomInfo = gMaJiangManager.roomInfo

	if roomInfo == nil then
		return
	end

	roomInfo.PlayerInfos[seatId + 1].Score = score

	gMaJiangManager:RunAction("OnScoreChange", seatId, score, change)
end

function MahjongPlayerToClientImpl.SyncMjGameOver(result)
	gMaJiangManager:OnGameOver(result)
end

function MahjongPlayerToClientImpl.SyncMjGameReconnect()
	gMaJiangManager:OnGameReconnect()
end

function MahjongPlayerToClientImpl.SyncMjHu(seatIdList, pai)
	gMaJiangManager:OnHu(seatIdList, pai)
end

function MahjongPlayerToClientImpl.SyncMjHolds(holds, holdsCount, seatIndex)
	local gameInfo = gMaJiangManager.gameInfo

	if gameInfo == nil then
		return
	end

	local seatInfo = gameInfo.SeatInfos[seatIndex + 1]
	seatInfo.Holds = holds
	seatInfo.HoldsCount = holdsCount
end

function MahjongPlayerToClientImpl.SyncMjHuanPaiBegin(defaultPais, elapsedTime)
	gMaJiangManager:SetGameState(GameStateEnum.HuanPai)
	gMaJiangManager:RefreshTimeOutByState(elapsedTime)
	gMaJiangManager:RunAction("BeginHuanPai", defaultPais)
end

function MahjongPlayerToClientImpl.SyncMjHuanPai(huanPais, seatIndex)
	gMaJiangManager:RunAction("FoldMyHuanPai", huanPais)
end

function MahjongPlayerToClientImpl.SyncMjHuanPaiResult(seatId, holds, huanPais, method)
	local gameInfo = gMaJiangManager.gameInfo

	if gameInfo == nil then
		return
	end

	gMaJiangManager:SetGameState(GameStateEnum.HuanPaiOver)

	gameInfo.SeatInfos[seatId + 1].Holds = holds

	if seatId == gMaJiangManager.mySeatID then
		gMaJiangManager:RunAction("FinishHuanPai", method, huanPais)
	end
end

function MahjongPlayerToClientImpl.SyncMjOperations(action, elapsedTime)
	gMaJiangManager:RefreshTimeOutByState(elapsedTime)

	if action ~= nil then
		gMaJiangManager:RunAction("RefreshOperation", action)
	end
end

function MahjongPlayerToClientImpl.SyncMjMoPai(seatIndex, pai, remainders)
	gMaJiangManager:OnMoPai(seatIndex, pai, remainders)
end

function MahjongPlayerToClientImpl.SyncMjPeng(seatSeatIndex, pai)
	gMaJiangManager:OnPeng(seatSeatIndex, pai)
end

function MahjongPlayerToClientImpl.SyncMjGang(seatIndex, pai, type)
	if type == MjActionType.WangGang then
		gMaJiangManager:OnHanGangDone()
	else
		gMaJiangManager:OnGang(seatIndex, pai, type)
	end
end

function MahjongPlayerToClientImpl.SyncMjHanGang(seatId, pai, type)
	if type ~= PCGType.JiaGang then
		return
	end

	gMaJiangManager:OnHanGang(seatId, pai, type)
end

function MahjongPlayerToClientImpl.SyncMjGuo(chuPai)
	gMaJiangManager:OnGuo()
end

function MahjongPlayerToClientImpl.SyncMjYiPaoDuoXiang(seatIndex, cnt)
	return
end

function MahjongPlayerToClientImpl.SyncMjMaoZhuanYu(seatIndex)
	gMaJiangManager:RunAction("OnMaoZhuanYu", seatIndex)
end

function MahjongPlayerToClientImpl.SyncMjTuiShui(seatList)
	gMaJiangManager:RunAction("OnEndCheck", seatList, MjActionType.TuiShui)
end

function MahjongPlayerToClientImpl.SyncMjChaHuaZhu(seatList)
	gMaJiangManager:RunAction("OnEndCheck", seatList, MjActionType.ChaHuaZhu)
end

function MahjongPlayerToClientImpl.SyncMjChaDaJiao(seatList)
	gMaJiangManager:RunAction("OnEndCheck", seatList, MjActionType.ChaDaJiao)
end

function MahjongPlayerToClientImpl.SyncMjRoomOwnerSeatIndex(roomOwnerSeatIndex)
	gMaJiangManager:OnRoomOwnerChange(roomOwnerSeatIndex)
end

function MahjongPlayerToClientImpl.SyncMjAutoEnterTuoGuan()
	gMaJiangManager:RunAction("SetAuto")
end

function MahjongPlayerToClientImpl.SyncMahjongChat(chatType, seatIndex, msgId)
	if seatIndex == gMaJiangManager.mySeatID then
		return
	end

	gMaJiangManager:RunAction("OnReceiveQuickChat", chatType, seatIndex, msgId)
end

function MahjongPlayerToClientImpl.SyncMahjongNpcChat(seatIndex, npcChatType, dialogId)
	gMaJiangManager:RunAction("OnReceiveNpcChat", seatIndex, npcChatType, dialogId)
end

function MahjongPlayerToClientImpl.SyncMahjongGameCount(gameCount)
	gMaJiangManager:OnGameCountChange(gameCount)
end

function MahjongPlayerToClientImpl.SyncMahjongPlayerPveGameNumInfo(completeNum, hasSurpriseNpcInGame)
	gMaJiangManager:RunAction("RefreshPveGameNumInfo", completeNum)
end

function MahjongPlayerToClientImpl.SendCustomHotPatchMahjongPlayerToClient(data)
	return
end

return MahjongPlayerToClientImpl
