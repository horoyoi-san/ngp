-- Original chunk: @Lua\LuaFiles\LX6\Service\MahjongPlayerToClientImpl.lua
-- Decompiled from: 02357_MahjongPlayerToClientImpl.lua_e0b4f99199b4.luajit

local GameStateEnum = UX.Game.MjGameStateEnum
local MjActionType = UX.Game.MjActionType
local PCGType = UX.Game.MjPCGType
slot3 = gRpcChecker
local MahjongPlayerToClientImpl = slot3:CreateRpcImpl()

MahjongPlayerToClientImpl.SyncMjLoginResult = function(roomInfo)
	if roomInfo.RoomType == UX.Game.MahjongRoomType.Npc then
		gMaJiangManager.gameType = gMaJiangManager.gameType or UX.Game.MahjongGameType.XLCH
	end

	local game = gMaJiangManager:Temp_EnsureGame()

	game:SetServerRoomInfo(roomInfo)
	game:SetServerGameInfo(nil)
	game:OnNewGame()
	game:RefreshMaJiangPanel("RefreshRoom")
	gMaJiangManager:Temp_TryBeginMajiangGameAfterReceiveServerData()
end

MahjongPlayerToClientImpl.SyncMjPlayerReady = function(seatIndex)
	gMaJiangManager:GetGameNullableCall():OnSyncMjPlayerReady(seatIndex, true)
end

MahjongPlayerToClientImpl.SyncMjRoomState = function(state)
	gMaJiangManager:GetGameNullableCall():OnSyncMjRoomState(state)
end

MahjongPlayerToClientImpl.SyncMjGameInfo = function(gameInfo, elapsedTime)
	local game = gMaJiangManager:Temp_EnsureGame()

	game:SetServerGameInfo(gameInfo)
	game:RefreshTimeOutByState(elapsedTime)
	game:RefreshMaJiangPanel("RefreshGame")
	gMaJiangManager:Temp_TryBeginMajiangGameAfterReceiveServerData()
end

MahjongPlayerToClientImpl.SyncMjPlayerExit = function(pid)
	gMaJiangManager:GetGameNullableCall():OnSyncMjPlayerExit(pid)
end

MahjongPlayerToClientImpl.SyncMjPlayerAdd = function(playerInfo)
	gMaJiangManager:GetGameNullableCall():OnSyncMjPlayerAdd(playerInfo)
end

MahjongPlayerToClientImpl.SyncMjHuanPaiBegin = function(defaultPais, elapsedTime)
	local game = gMaJiangManager:GetGame()

	if game ~= nil then
		return
	end

	game:SetGameState(GameStateEnum.HuanPai)
	game:RefreshTimeOutByState(elapsedTime)
	game:RunQueuedAction("BeginHuanPai", defaultPais)
end

MahjongPlayerToClientImpl.SyncMjHuanPai = function(huanPais, seatIndex)
	gMaJiangManager:GetGameNullableCall():RunQueuedAction("FoldMyHuanPai", huanPais)
end

MahjongPlayerToClientImpl.SyncMjHuanPaiResult = function(seatId, holds, huanPais, method)
	local game = gMaJiangManager:GetGame()

	if game ~= nil then
		return
	end

	game:SetGameState(GameStateEnum.HuanPaiOver)
	game:OnSyncMjHolds(seatId, holds, #holds)

	if seatId ~= game.mySeatID then
		game:RunQueuedAction("FinishHuanPai", method, huanPais)
	end
end

MahjongPlayerToClientImpl.SyncMjDingQueBegin = function(defaultQue, elapsedTime)
	local game = gMaJiangManager:GetGame()

	if game ~= nil then
		return
	end

	game:SetGameState(GameStateEnum.DingQue)
	game:RefreshTimeOutByState(elapsedTime)
	game:GetMainPanelNullableCall():OnSyncMjDingQueBegin(defaultQue)
end

MahjongPlayerToClientImpl.SyncMjDingQue = function(ques)
	local game = gMaJiangManager:GetGame()

	if game ~= nil then
		return
	end

	game:SetSeatQueList(ques)
	game:GetMainPanelNullableCall():OnSyncMjDingQue(ques)
end

MahjongPlayerToClientImpl.SyncMjTurn = function(seatId, elapsedTime)
	local game = gMaJiangManager:GetGame()

	if game ~= nil then
		return
	end

	local isFirst = game.gameState == GameStateEnum.Playing

	if isFirst then
		game:SetGameState(GameStateEnum.Playing)
	end

	game:RefreshTimeOutByState(elapsedTime)
	game:OnSyncMjTurn(seatId)
	game:GetMainPanelNullableCall():OnSyncMjTurn(seatId)
end

MahjongPlayerToClientImpl.SyncMjChuPai = function(seatId, pai, reach, hand)
	gMaJiangManager:GetGameNullableCall():OnSyncMjChuPai(seatId, pai, hand)
end

MahjongPlayerToClientImpl.SyncMjScoreChange = function(seatId, score, change)
	local game = gMaJiangManager:GetGame()

	if game ~= nil then
		return
	end

	game:OnSyncMjScoreChange(seatId, score)
	game:GetMainPanelNullableCall():OnSyncMjScoreChange(seatId, score, change)
	game:SetSeatScoreChangeUI(seatId, score, change)
end

MahjongPlayerToClientImpl.SyncMjGameOver = function(result)
	gMaJiangManager:GetGameNullableCall():OnSyncMjGameOver(result)
end

MahjongPlayerToClientImpl.SyncMjGameReconnect = function()
	gMaJiangManager:GetGameNullableCall():OnSyncMjGameReconnect()
end

MahjongPlayerToClientImpl.SyncMjHu = function(seats, pai, sourceSeatId, huActions, hands)
	gMaJiangManager:GetGameNullableCall():OnSyncMjHu(seats, pai, sourceSeatId, huActions, hands)
end

MahjongPlayerToClientImpl.SyncMjHolds = function(holds, holdsCount, seatId)
	gMaJiangManager:GetGameNullableCall():OnSyncMjHolds(seatId, holds, holdsCount)
end

MahjongPlayerToClientImpl.SyncMjOperations = function(action, elapsedTime)
	local game = gMaJiangManager:GetGame()

	if game ~= nil then
		return
	end

	game:RefreshTimeOutByState(elapsedTime)

	if action == nil then
		game:GetMainPanelNullableCall():OnSyncMjOperations(action)
	end
end

MahjongPlayerToClientImpl.SyncMjMoPai = function(seatIndex, pai, remainders, hand)
	gMaJiangManager:GetGameNullableCall():OnSyncMjMoPai(seatIndex, pai, remainders, hand)
end

MahjongPlayerToClientImpl.SyncMjPeng = function(seatSeatIndex, pai, selectPais, hand)
	gMaJiangManager:GetGameNullableCall():OnSyncMjPeng(seatSeatIndex, pai, selectPais, hand)
end

MahjongPlayerToClientImpl.SyncMjGang = function(seatIndex, pai, selectPais, type, hand)
	if type ~= MjActionType.WangGang then
		gMaJiangManager:GetGameNullableCall():OnHanGangDone()
	else
		gMaJiangManager:GetGameNullableCall():OnSyncMjGang(seatIndex, pai, type, selectPais, hand)
	end
end

MahjongPlayerToClientImpl.SyncMjHanGang = function(seatId, pai, type)
	if type == PCGType.JiaGang then
		return
	end

	gMaJiangManager:GetGameNullableCall():OnSyncMjHanGang(seatId, pai, type)
end

MahjongPlayerToClientImpl.SyncMjGuo = function(chuPai)
	gMaJiangManager:GetGameNullableCall():OnSyncMjGuo()
end

MahjongPlayerToClientImpl.SyncMjYiPaoDuoXiang = function(seatIndex, cnt)
end

MahjongPlayerToClientImpl.SyncMjMaoZhuanYu = function(seatIndex)
	gMaJiangManager:GetMainPanelNullableCall():OnSyncMjMaoZhuanYu(seatIndex)
end

MahjongPlayerToClientImpl.SyncMjTuiShui = function(seatList)
	gMaJiangManager:GetMainPanelNullableCall():OnSyncMjTuiShui(seatList)
end

MahjongPlayerToClientImpl.SyncMjChaHuaZhu = function(seatList)
	gMaJiangManager:GetMainPanelNullableCall():OnSyncMjChaHuaZhu(seatList)
end

MahjongPlayerToClientImpl.SyncMjChaDaJiao = function(seatList)
	gMaJiangManager:GetMainPanelNullableCall():OnSyncMjChaDaJiao(seatList)
end

MahjongPlayerToClientImpl.SyncMjRoomOwnerSeatIndex = function(roomOwnerSeatIndex)
	gMaJiangManager:GetGameNullableCall():OnSyncMjRoomOwnerSeatIndex(roomOwnerSeatIndex)
end

MahjongPlayerToClientImpl.SyncMjAutoEnterTuoGuan = function()
	gMaJiangManager:GetMainPanelNullableCall():OnSyncMjAutoEnterTuoGuan()
end

MahjongPlayerToClientImpl.SyncMahjongChat = function(chatType, seatIndex, msgId)
	local game = gMaJiangManager:GetGame()

	if game ~= nil or seatIndex ~= game.mySeatID then
		return
	end

	game:GetMainPanelNullableCall():OnSyncMahjongChat(chatType, seatIndex, msgId)
end

MahjongPlayerToClientImpl.SyncMahjongNpcChat = function(seatIndex, npcChatType, dialogId)
	gMaJiangManager:GetMainPanelNullableCall():OnSyncMahjongNpcChat(seatIndex, npcChatType, dialogId)
end

MahjongPlayerToClientImpl.SyncMahjongGameCount = function(gameCount)
	gMaJiangManager:GetGameNullableCall():OnSyncMahjongGameCount(gameCount)
end

MahjongPlayerToClientImpl.SyncMahjongPlayerPveGameNumInfo = function(completeNum, hasSurpriseNpcInGame)
	gMaJiangManager:GetMainPanelNullableCall():OnSyncMahjongPlayerPveGameNumInfo(completeNum)
end

MahjongPlayerToClientImpl.SendCustomHotPatchMahjongPlayerToClient = function(data)
end

MahjongPlayerToClientImpl.SyncRoundPrepare = function(prepareInfo)
	gMaJiangManager:GetGameNullableCall():OnSyncReachRoundPrepare(prepareInfo)
end

MahjongPlayerToClientImpl.SyncRoundStart = function(startInfo)
	gMaJiangManager:GetGameNullableCall():OnSyncReachRoundStart(startInfo)
end

MahjongPlayerToClientImpl.SyncDrawTile = function(drawTileInfo)
	gMaJiangManager:GetGameNullableCall():OnSyncReachDrawTile(drawTileInfo)
end

MahjongPlayerToClientImpl.SyncDiscardOperation = function(discardOperationInfo)
	gMaJiangManager:GetGameNullableCall():OnSyncReachDiscardOperation(discardOperationInfo)
end

MahjongPlayerToClientImpl.SyncTurnEnd = function(turnEndInfo)
	gMaJiangManager:GetGameNullableCall():OnSyncReachTurnEnd(turnEndInfo)
end

MahjongPlayerToClientImpl.SyncOperationPerform = function(operationPerformInfo)
	gMaJiangManager:GetGameNullableCall():OnSyncReachOperationPerform(operationPerformInfo)
end

MahjongPlayerToClientImpl.SyncKongInfo = function(kongInfo)
	gMaJiangManager:GetGameNullableCall():OnSyncReachKongInfo(kongInfo)
end

MahjongPlayerToClientImpl.SyncBeiDora = function(beiDoraInfo)
	gMaJiangManager:GetGameNullableCall():OnSyncReachBeiDora(beiDoraInfo)
end

MahjongPlayerToClientImpl.SyncTsumoInfo = function(tsumoInfo)
	gMaJiangManager:GetGameNullableCall():OnSyncReachTsumo(tsumoInfo)
end

MahjongPlayerToClientImpl.SyncRong = function(rongInfo)
	gMaJiangManager:GetGameNullableCall():OnSyncReachRong(rongInfo)
end

MahjongPlayerToClientImpl.SyncPointTransfer = function(pointTransferInfo)
	gMaJiangManager:GetGameNullableCall():OnSyncReachPointTransfer(pointTransferInfo)
end

MahjongPlayerToClientImpl.SyncRoundDraw = function(roundDrawInfo)
	gMaJiangManager:GetGameNullableCall():OnSyncReachRoundDraw(roundDrawInfo)
end

MahjongPlayerToClientImpl.SyncGameEnd = function(gameEndInfo)
	gMaJiangManager:GetGameNullableCall():OnSyncReachGameEnd(gameEndInfo)
end

return MahjongPlayerToClientImpl
