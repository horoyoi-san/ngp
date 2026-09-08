-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\ChineseChess\ChineseChessMgr.lua
-- Decompiled from: 02171_ChineseChessMgr.lua_5e7c2115dc47.luajit

C_ChineseChessMgr = DefClass("C_ChineseChessMgr", C_ChineseChessMgr)
local M = C_ChineseChessMgr
local ChineseChessConfig = require("LX6/MiniGame/ChineseChess/ChineseChessConfig")

M.ctor = function(self)
	self.AiLevel = 1
	self._pendingInGameMessages = nil
end

M.Init = function(self, isFlipChart, mode)
	self.GameModeConfig = gChineseChessTools.GetGameModeConfig(mode)

	self:RemoveBoard()

	self.IsFlipChart = isFlipChart or false
	self.EffectMgr = self.EffectMgr or C_ChineseChessEffectMgr.New()

	if self.IsFlipChart then
		self.Board = C_ChineseChessFlipBoard.New()
	else
		self.Board = C_ChineseChessBoard.New()
	end

	self.BoardGo = self:GetOrCreateBoardGameObject()

	if self.IsFlipChart then
		self.Chart = C_ChineseChessFlipChart.New()
	else
		self.Chart = C_ChineseChessChart.New()
	end

	self.Chart:InitUndoLimit(self.GameModeConfig.UndoCount)

	self._gameMode = mode
end

M.LoadGame = function(self, gameMode, baseTransform, entityInstanceId, opponentNpcId, endGameGroup, onExitFullBonesCleanup)
	gameMode = gameMode or gChineseChessMode.Chess
	self.SpoonBaseTransform = baseTransform
	self.gadgetUId = entityInstanceId
	self.CustomOpponentNpcId = opponentNpcId
	self.EndGameGroup = endGameGroup or 0
	self._onExitFullBonesCleanup = onExitFullBonesCleanup
	self.isExiting = false

	self:InitMessages()

	self.LoadGameCo = gCoroutineManager:StartCoroutine(function ()
		if not self:LoadAllPrefabs_Async() then
			return
		end

		self:AnchorDesk(self.SpoonBaseTransform)
		gPanelManager:CheckShow(gPanelId.CHINESE_CHESS_START_PANEL, {
			defaultMode = gameMode,
			endGameGroup = self.EndGameGroup
		})
	end)
end

M.LoadAllPrefabs_Async = function(self)
	if self.IsPrefabsLoaded then
		return true
	end

	self.IsPrefabsLoaded = true
	self.Prefabs = {}
	self._loadOps = {}
	local waitTokens = {}

	local fireLoad = function(path)
		local loadOp = gResourceManager:LoadAssetAsync(path, typeof(UnityEngine.GameObject))
		self._loadOps[#self._loadOps + 1] = loadOp
		waitTokens[#waitTokens + 1] = gWaitToken.Create():WaitUntil(function ()
			return loadOp.isDone or self.isExiting
		end)

		return loadOp
	end

	local chessLoadOps = {}
	local chessPrefabs = {
		[gChineseChessColor.Red] = gChineseChessPrefabs[gChineseChessColor.Red],
		[gChineseChessColor.Black] = gChineseChessPrefabs[gChineseChessColor.Black]
	}

	for color, paths in pairs(chessPrefabs) do
		self.Prefabs[color] = {}

		for chessType, path in pairs(paths) do
			local loadOp = fireLoad(path)
			chessLoadOps[loadOp] = {
				color = color,
				chessType = chessType
			}
		end
	end

	local faceDownLoadOp = fireLoad(gChineseChessPrefabs.ChineseChessFaceDownPrefabPath)
	local deskLoadOp = fireLoad(gChineseChessPrefabs.ChineseChessDeskPrefabPath)
	local flipBoardLoadOp = fireLoad(gChineseChessPrefabs.ChineseChessFlipBoardPrefabPath)
	local boardLoadOp = fireLoad(gChineseChessPrefabs.ChineseChessBoardPrefabPath)
	self.EffectMgr = self.EffectMgr or C_ChineseChessEffectMgr.New()
	local waitAllToken = gWaitToken.WaitAll(waitTokens):SetTimeout(10)

	coroutine.yield(waitAllToken)

	if self.isExiting then
		self:_CleanupLoadOps()

		return false
	end

	if waitAllToken.isTimeout then
		print_error("[ChineseChess] LoadGame 资源加载超时，无法开局")
		self:_CleanupLoadOps()

		return false
	end

	for loadOp, info in pairs(chessLoadOps) do
		self.Prefabs[info.color][info.chessType] = loadOp.asset
	end

	self.FaceDownPrefab = faceDownLoadOp.asset
	self.DeskPrefab = deskLoadOp.asset
	self.FlipBoardPrefab = flipBoardLoadOp.asset
	self.BoardPrefab = boardLoadOp.asset

	self:GetOrCreateDeskGameObject()

	self._loadOps = nil

	return true
end

M._CleanupLoadOps = function(self)
	if self._loadOps then
		for _, loadOp in ipairs(self._loadOps) do
			gResourceManager:UnloadAssetLoadOp(loadOp)
		end

		self._loadOps = nil
	end
end

M.AnchorDesk = function(self, baseTransform)
	if gClientUtils.IsNil(self.DeskGo) or gClientUtils.IsNil(baseTransform) then
		return
	end

	local tableNode = self.DeskGo.transform:Find("p_interaction_custommodels_table01a")

	if gClientUtils.NotNil(tableNode) then
		local delta = self.DeskGo.transform.position - tableNode.position
		self.DeskGo.transform.position = baseTransform.position + delta
	else
		self.DeskGo.transform.position = baseTransform.position
	end

	self.DeskGo.transform.rotation = baseTransform.rotation
end

M.StartGameByMode = function(self, gameMode, endGameId)
	self.EnterGameCo = gCoroutineManager:StartCoroutine(function ()
		self:EnterGame_Async(gameMode, endGameId)
	end)
end

M.EnterGame_Async = function(self, gameMode, endGameId)
	self.OpponentAgentInstanceId = nil
	self.WaitOpponentAgentInstanceIdToken = gWaitToken.Create()

	gBlackScreenManager:OpenTransition(gBlackScreenId.CHINESE_CHESS, "", false, false, ChineseChessConfig.BlackScreenOpenTime, -1, -1, ChineseChessConfig.BlackScreenCloseTime)
	coroutine.yield(gWaitableUtils.WaitTime(ChineseChessConfig.BlackScreenOpenTime))

	if self.isExiting then
		gBlackScreenManager:ClearTransition(gBlackScreenId.CHINESE_CHESS, false)

		return
	end

	local enterToken = gWaitToken.Create()
	local opponentNpcId = self.CustomOpponentNpcId and self.CustomOpponentNpcId == 0 and self.CustomOpponentNpcId or gChineseChessConst.DEFAULT_OPPONENT_NPC_ID

	if gameMode ~= gChineseChessMode.Late then
		self.CurrentEndGameId = endGameId or 1
		local endGameCfg = LTConfig.PoiGameChineseChessEndGameConfig.GetConfig(self.CurrentEndGameId)
		self.IsRed = endGameCfg.IsRedFirst
		self.PlayerId = self.IsRed and 1 or 2

		self:Init(false, gameMode)

		gClientToGameSceneDelegate:AskChineseChessEnterZoneEndGame(self.gadgetUId, opponentNpcId, self.CurrentEndGameId).Callback = function (err)
			enterToken:SetResult(err)
		end
	elseif gameMode ~= gChineseChessMode.Flip then
		self.PlayerId = self.IsRed and 1 or 2

		self:Init(true, gameMode)

		gClientToGameSceneDelegate:AskChineseChessFlipEnterZoneDoubleAI(self.gadgetUId, opponentNpcId, self.IsRed, self:GetDifficultyEnum(self.AiLevel)).Callback = function (err)
			enterToken:SetResult(err)
		end
	else
		self.PlayerId = self.IsRed and 1 or 2

		self:Init(false, gameMode)

		gClientToGameSceneDelegate:AskChineseChessEnterZoneDoubleAI(self.gadgetUId, opponentNpcId, self.IsRed, self:GetDifficultyEnum(self.AiLevel)).Callback = function (err)
			enterToken:SetResult(err)
		end
	end

	coroutine.yield(enterToken)

	if self.isExiting then
		gBlackScreenManager:ClearTransition(gBlackScreenId.CHINESE_CHESS, false)

		return
	end

	if enterToken.result == LTConfig.MessageConfig.Ok then
		gDisplayMessageMgr:DisplayServerMessageId(enterToken.result)
		self:Exit()

		return
	end

	self:OnEnterZoneSuccess(gameMode)
end

M.GetDifficultyEnum = function(self, aiLevel)
	if aiLevel > 5 then
		return UX.Game.ChineseChessAIDifficulty.Expert
	elseif aiLevel > 4 then
		return UX.Game.ChineseChessAIDifficulty.Hard
	elseif aiLevel > 3 then
		return UX.Game.ChineseChessAIDifficulty.Medium
	elseif aiLevel > 2 then
		return UX.Game.ChineseChessAIDifficulty.Easy
	else
		return UX.Game.ChineseChessAIDifficulty.Beginner
	end
end

M.CancelWaitPlayersCo = function(self)
	if self._waitPlayersCo then
		gCoroutineManager:CancelCoroutine(self._waitPlayersCo)

		self._waitPlayersCo = nil
	end
end

M.OnEnterZoneSuccess = function(self, gameMode)
	self._hasInitialSync = false

	self:CancelWaitPlayersCo()
	self:CreatePlayers()

	self._waitPlayersCo = gCoroutineManager:StartCoroutine(function ()
		while true do
			if self.isExiting then
				return
			end

			if self.Player1 and self.Player2 and self.Player1.IsModelLoaded and self.Player2.IsModelLoaded then
				break
			end

			coroutine.yield(nil)
		end

		self:InitPlayersForMode(gameMode)
		self:CreateChessCamera()

		self._waitPanelReadyToken = gWaitToken.Create()

		if gPanelManager:IsPanelShowing(gPanelId.CHINESE_CHESS_PLAY_PANEL) then
			self:GetPlayPanel():Init(self._waitPanelReadyToken)
		else
			gPanelManager:CheckShow(gPanelId.CHINESE_CHESS_PLAY_PANEL)
		end

		coroutine.yield(self._waitPanelReadyToken)

		self._waitPanelReadyToken = nil
		self.IsPlaying = true

		self:UpdateTurnState()
		self:FlushPendingMessages()
		self:ProcessMoveQueue()
		self:SendSignalToGadget("ChineseChessStart")
		coroutine.yield(nil)
		coroutine.yield(nil)
		gBlackScreenManager:CloseTransition(gBlackScreenId.CHINESE_CHESS)
	end)
end

M.GetPlayerSizeByAgentId = function(self, agentId)
	local agentCfg = agentId and LTConfig.AgentConfig.GetConfig(agentId)
	local generalModelCfg = agentCfg and LTConfig.GeneralModelConfig.GetConfig(agentCfg.GeneralModelId)

	if not generalModelCfg then
		return nil
	end

	return gChessPlayerBodyTypeMap[generalModelCfg.BodyType] or gChessPlayerBodyTypeMap[generalModelCfg.BodyType - 6]
end

M.CreatePlayers = function(self)
	local seat1 = self.DeskGo.transform:Find("Reference/seat_1")
	local seat2 = self.DeskGo.transform:Find("Reference/seat_2")
	local hand_1 = self.DeskGo.transform:Find("Reference/hand_1")
	local hand_1_c = self.DeskGo.transform:Find("Reference/hand_1_c")
	local hand_2 = self.DeskGo.transform:Find("Reference/hand_2")
	local hand_2_c = self.DeskGo.transform:Find("Reference/hand_2_c")
	local recycle_1 = self.BoardGo.transform:Find("recycle_1")
	local recycle_2 = self.BoardGo.transform:Find("recycle_2")

	if self.Player1 then
		self.Player1.RecycleGo = recycle_1
		self.Player2.RecycleGo = recycle_2

		self.Player1:Reset()
		self.Player2:Reset()
	else
		local selfAgentId = gCS.MyPlayerManager.PlayerUnit.ClientData.AgentId
		local opponentNpcId = self.CustomOpponentNpcId and self.CustomOpponentNpcId == 0 and self.CustomOpponentNpcId or gChineseChessConst.DEFAULT_OPPONENT_NPC_ID
		local selfModelInfo = {
			["[\\xa2\\x8b\\x8fG"] = true,
			agentId = selfAgentId
		}
		local enemyModelInfo = {
			["[\\xa2\\x8b\\x8fG"] = false,
			agentId = opponentNpcId
		}
		local selfPlayerSize = self:GetPlayerSizeByAgentId(selfAgentId)
		local enemyPlayerSize = self:GetPlayerSizeByAgentId(opponentNpcId)
		self.Player1 = C_ChineseChessPlayer.New(seat1, hand_1, hand_1_c, recycle_1, selfModelInfo, selfPlayerSize)
		self.Player2 = C_ChineseChessPlayer.New(seat2, hand_2, hand_2_c, recycle_2, enemyModelInfo, enemyPlayerSize)
	end

	local clearRecycleSlotChildren = function(recycle)
		for i = 0, recycle.childCount - 1 do
			local slot = recycle:GetChild(i)

			for j = slot.childCount - 1, 0, -1 do
				gClientUtils.DestroyUnityObject(slot:GetChild(j).gameObject)
			end
		end
	end

	clearRecycleSlotChildren(recycle_1)
	clearRecycleSlotChildren(recycle_2)
end

M.InitPlayersForMode = function(self, gameMode)
	local selfPlayerId = self.IsRed and 1 or 2
	local enemyPlayerId = self.IsRed and 2 or 1
	local selfInfo = C_ChineseChessPlayerInfo.New(selfPlayerId, self.IsRed, 100, 300, 0)
	selfInfo.Name = gClientUtils.GetCurrentSpiritDisplayName()
	local spiritId = gBattleSpiritMgr.currentSpiritTemplateId
	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)
	selfInfo.AvatarImageId = spiritCfg and spiritCfg.SHeadIconID or 0
	local enemyInfo = C_ChineseChessPlayerInfo.New(enemyPlayerId, not self.IsRed, 100, 300, 0)
	local opponentNpcId = self.CustomOpponentNpcId and self.CustomOpponentNpcId == 0 and self.CustomOpponentNpcId or gChineseChessConst.DEFAULT_OPPONENT_NPC_ID
	local agentCfg = LTConfig.AgentConfig.GetConfig(opponentNpcId)
	local agentSpecificTypeCfg = LTConfig.AgentAgentSpecificTypeConfig.GetConfig(agentCfg.AgentSpecificType)
	enemyInfo.Name = agentCfg.Name
	local headIconList = agentSpecificTypeCfg and agentSpecificTypeCfg.HeadIcon
	enemyInfo.AvatarImageId = headIconList and headIconList[1]
	self.Player1.PlayerInfo = selfInfo
	self.Player2.PlayerInfo = enemyInfo
	self.IsMirror = not self.IsRed

	if gameMode ~= gChineseChessMode.Late then
		local endGameId = self.CurrentEndGameId or 1
		local cfg = LTConfig.PoiGameChineseChessEndGameConfig.GetConfig(endGameId)

		if cfg then
			gChineseChessTools.LoadEndGamePieces(self.Chart, cfg.RedPos, cfg.BlackPos)
		end
	else
		self.Chart:InitChartBoard()
	end

	self.Board:Init(self.BoardGo, self.Chart, self.Player1, self.Player2, not self.IsRed)

	self.Player1.ChesssGo = self.BoardGo.transform:Find("Chesss")
	self.Player2.ChesssGo = self.Player1.ChesssGo

	self.Board:Start()
end

M.GetOrCreateDeskGameObject = function(self)
	if gClientUtils.IsNil(self.DeskGo) then
		self.DeskGo = GameObject.Instantiate(self.DeskPrefab)

		self:AnchorDesk(self.SpoonBaseTransform)

		if not self.showModels then
			local renderers = self.DeskGo:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)

			for i = 0, renderers.Length - 1 do
				renderers[i].enabled = false
			end
		end
	end

	return self.DeskGo
end

M.GetOrCreateBoardGameObject = function(self)
	local deskGo = self:GetOrCreateDeskGameObject()

	if gClientUtils.NotNil(self.BoardGo) then
		return self.BoardGo
	end

	local broadSlot = deskGo.transform:Find(self.IsFlipChart and "Reference/board_flip" or "Reference/board_chess")
	local prefab = self.IsFlipChart and self.FlipBoardPrefab or self.BoardPrefab
	self.BoardGo = GameObject.Instantiate(prefab, broadSlot)

	return self.BoardGo
end

M.InitMessages = function(self)
	self.MoveQueue = {}
	self._isProcessingQueue = false
	self._countdownVisible = true
	self.IsWaitingServerMove = false
	self._pendingInGameMessages = {}
	self.turnState = nil

	if self.IsAddMessages then
		return
	end

	self.IsAddMessages = true
	self._msgListeners = {}

	self:AddInGameMessageListener(gEventConstants.ON_CHINESE_CHESS_MOVE, function (eventId, move)
		local fromPoint = gChineseChessTools.CoordToPoint(move.FromX, move.FromY)
		local toPoint = gChineseChessTools.CoordToPoint(move.ToX, move.ToY)
		local chessId = self.Chart:GetChessByPoint(fromPoint)

		table.insert(self.MoveQueue, {
			chessId = chessId,
			toPoint = toPoint
		})
		self:ProcessMoveQueue()
	end)
	self:AddInGameMessageListener(gEventConstants.ON_CHINESE_CHESS_UNDO, function (eventId, data)
		self.MoveQueue = {}
		self._isProcessingQueue = false
		self.IsWaitingServerMove = false

		self.Board:Undo(data.undoStepCount)
		self:GetPlayPanel():RefreshTargetList()
	end)
	self:AddInGameMessageListener(gEventConstants.ON_CHINESE_CHESS_GAME_OVER, function (eventId, data)
		self._pendingGameOverData = data

		self:_HideCountdown()
		self:ProcessMoveQueue()
	end)
	self:AddInGameMessageListener(gEventConstants.ON_CHINESE_CHESS_SCORE_INFO, function (eventId, scoreInfo)
		if not self._hasInitialSync then
			self._hasInitialSync = true

			self:ReplayMoves(scoreInfo.Moves)
		end

		local myPid = gPlayerManager.infoBase.bindData.Pid

		self.Chart:OnServerUndoSync(scoreInfo.UndoCountByPid[myPid])
		self:GetPlayPanel():RefreshUndoBtn()
	end)
	self:AddInGameMessageListener(gEventConstants.ON_CHINESE_CHESS_FLIP_MOVE, function (eventId, move)
		if move.IsFlip then
			local col = move.Col
			local row = move.Row
			local point = gChineseChessTools.GetFlipPointByPosition(col, row)

			table.insert(self.MoveQueue, {
				["[\\xb7\\x82\\x8aQ"] = true,
				point = point
			})
		else
			local fromPoint = gChineseChessTools.GetFlipPointByPosition(move.FromCol, move.FromRow)
			local toPoint = gChineseChessTools.GetFlipPointByPosition(move.ToCol, move.ToRow)
			local chessId = self.Chart:GetChessByPoint(fromPoint)

			table.insert(self.MoveQueue, {
				chessId = chessId,
				toPoint = toPoint
			})
		end

		self:ProcessMoveQueue()
	end)
	self:AddInGameMessageListener(gEventConstants.ON_CHINESE_CHESS_FLIP_SCORE_INFO, function (eventId, scoreInfo)
		if not self._hasInitialSync then
			self._hasInitialSync = true

			self:ReplayFlipScoreInfo(scoreInfo)
		end

		if scoreInfo.Winner > 0 then
			self._pendingGameOverData = {
				winner = scoreInfo.Winner,
				reason = scoreInfo.OverReason
			}

			self:_HideCountdown()
			self:ProcessMoveQueue()
		end
	end)
end

M.AddMessageListener = function(self, eventId, handler)
	gMessageManager:AddMessageListener(eventId, handler)
	table.insert(self._msgListeners, {
		eventId = eventId,
		handler = handler
	})
end

M.AddInGameMessageListener = function(self, eventId, handler)
	local wrappedHandler = function(eventIdIn, ...)
		if not self.IsPlaying then
			table.insert(self._pendingInGameMessages, {
				handler = handler,
				eventId = eventIdIn,
				args = {
					...
				}
			})

			return
		end

		handler(eventIdIn, ...)
	end

	self:AddMessageListener(eventId, wrappedHandler)
end

M.FlushPendingMessages = function(self)
	if self._pendingInGameMessages ~= nil then
		return
	end

	local pending = self._pendingInGameMessages
	self._pendingInGameMessages = {}

	for _, msg in ipairs(pending) do
		msg.handler(msg.eventId, unpack(msg.args))
	end
end

M.RemoveMessages = function(self)
	if self._msgListeners then
		for _, entry in ipairs(self._msgListeners) do
			gMessageManager:RemoveMessageListener(entry.eventId, entry.handler)
		end

		self._msgListeners = nil
	end

	self.IsAddMessages = false
end

M.SendSignalToGadget = function(self, signal, gadgetUId)
	if gadgetUId or self.gadgetUId then
		gSpoonClientMgr:TryCallInnerSignal(gadgetUId or self.gadgetUId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, signal)
	end
end

M.GetChessPrefab = function(self, color, chessType)
	return self.Prefabs[color][chessType]
end

M.GetFaceDownPrefab = function(self)
	return self.FaceDownPrefab
end

M.ChineseChessStart = function(self, players, isOnline, chessIds, flipChessIds)
	self.IsPlaying = true

	self:CreatePlayers()

	if players[0].PlayerId ~= self.PlayerId then
		self.Player1.PlayerInfo = players[0]
		self.Player2.PlayerInfo = players[1]
		self.IsMirror = false
		self.IsRed = true
	else
		self.Player1.PlayerInfo = players[1]
		self.Player2.PlayerInfo = players[0]
		self.IsMirror = true
		self.IsRed = false
	end

	self.Chart:InitChartBoard(chessIds, flipChessIds)
	self.Board:Init(self.BoardGo, self.Chart, self.Player1, self.Player2, not self.Player1.PlayerInfo.IsRed)

	self.Player1.ChesssGo = self.BoardGo.transform:Find("Chesss")
	self.Player2.ChesssGo = self.Player1.ChesssGo
	self.ReadyGoDelay = gLuaTimeMgrUtils.Delay(function ()
		self.Board:Start()
	end, 3)

	self:UpdateTurnState()
	gPanelManager:CheckShow(gPanelId.CHINESE_CHESS_PLAY_PANEL)
	self:CreateChessCamera()
end

M.FlipStartRandom = function(self)
	local players = nil
	self.PlayerId = 1

	if math.random() <= 0.5 then
		players = {
			[0] = C_ChineseChessPlayerInfo.New(1, true, 100),
			C_ChineseChessPlayerInfo.New(2, false, 100)
		}
	else
		players = {
			[0] = C_ChineseChessPlayerInfo.New(2, true, 100),
			C_ChineseChessPlayerInfo.New(1, false, 100)
		}
	end

	self:ChineseChessStart(players, false)
end

M.ReplayMoves = function(self, moves)
	if moves ~= nil or self.Chart ~= nil or self.Board ~= nil then
		return
	end

	for i = 1, moves.Count do
		local move = moves[i]
		local fromPoint = gChineseChessTools.CoordToPoint(move.FromX, move.FromY)
		local toPoint = gChineseChessTools.CoordToPoint(move.ToX, move.ToY)
		local chessId = self.Chart:GetChessByPoint(fromPoint)

		self.Board:MoveChessTo(chessId, toPoint)
	end
end

M.ReplayFlipScoreInfo = function(self, scoreInfo)
	if self.Chart ~= nil or self.Board ~= nil then
		return
	end

	local chart = self.Chart

	chart:Clear()
	chart:OnCreate()

	local chessIds = scoreInfo.ChessIds

	for i = 1, chessIds.Count do
		local chessId = chessIds[i]

		if chessId and chessId > 0 then
			local point = i - 1

			chart:SetChessPoint(chessId, point)

			chart.FaceDownMap[chessId] = true
		end
	end

	local revealedMask = scoreInfo.RevealedMask

	if revealedMask then
		for chessId = 0, 31 do
			if revealedMask[chessId + 1] and chart.ChessPointMap[chessId] and chart.ChessPointMap[chessId] == -1 then
				chart.FaceDownMap[chessId] = false
			end
		end
	end

	local redPlayer = self:GetPlayerInfo(true)
	local blackPlayer = self:GetPlayerInfo(false)

	if redPlayer then
		redPlayer.Score = scoreInfo.RedHP
	end

	if blackPlayer then
		blackPlayer.Score = scoreInfo.BlackHP
	end

	self.Board:InitChessBoard()
	chart:ClearUndoData()
	chart:Start()
end

M.IsPlayerAction = function(self)
	return self.Player1 ~= nil or self.Player1.IsAction or self.Player2.IsAction
end

M.IsTurnStateRed = function(self)
	return self.turnState ~= gChineseChessTurnState.RedTurn or self.turnState ~= gChineseChessTurnState.RedMove
end

M.IsTurnStateMoving = function(self)
	return self.turnState ~= gChineseChessTurnState.RedMove or self.turnState ~= gChineseChessTurnState.BlackMove
end

M.EnterMoveState = function(self)
	if self:IsTurnStateMoving() then
		return
	end

	local isRedTurn = self.Chart.IsRedPlayChess
	self.turnState = isRedTurn and gChineseChessTurnState.RedMove or gChineseChessTurnState.BlackMove

	self:_HideCountdown()
end

M.UpdateTurnState = function(self)
	if not self.IsPlaying or not self.Chart then
		return
	end

	local isRedTurn = self.Chart.IsRedPlayChess

	if not self.turnState then
		self.turnState = isRedTurn and gChineseChessTurnState.RedTurn or gChineseChessTurnState.BlackTurn

		return
	end

	local stateIsRed = self:IsTurnStateRed()
	local stateIsMoving = self:IsTurnStateMoving()

	if stateIsMoving then
		if stateIsRed == isRedTurn and not self:IsPlayerAction() and #self.MoveQueue ~= 0 then
			self.turnState = isRedTurn and gChineseChessTurnState.RedTurn or gChineseChessTurnState.BlackTurn

			self:GetPlayPanel():OnChangePlayer()
			self:_CancelCountdownTimer()

			self._countdownTimerId = gLuaTimeMgrUtils.Delay(function ()
				if not self._countdownVisible and self.IsPlaying then
					self:_ShowCountdown()
				end
			end, self.GameModeConfig.TurnChangeBufferTime, self.GameModeConfig.TurnChangeBufferTime)
		end
	elseif stateIsRed == isRedTurn then
		self.turnState = isRedTurn and gChineseChessTurnState.RedTurn or gChineseChessTurnState.BlackTurn

		self:GetPlayPanel():OnChangePlayer()
	end
end

M.ProcessMoveQueue = function(self)
	if not self.IsPlaying then
		return
	end

	if self._isProcessingQueue then
		return
	end

	self._isProcessingQueue = true

	while #self.MoveQueue <= 0 do
		if self:IsPlayerAction() then
			self._isProcessingQueue = false

			return
		end

		local move = table.remove(self.MoveQueue, 1)

		self:EnterMoveState()

		if move.isFlip then
			self.Board:FlipChess(move.point)
		else
			self.Board:MoveChessTo(move.chessId, move.toPoint)
		end
	end

	self._isProcessingQueue = false

	self:GetPlayPanel():RefreshUndoBtn()

	if #self.MoveQueue ~= 0 and not self:IsPlayerAction() then
		local wasMoving = self:IsTurnStateMoving()

		self:UpdateTurnState()

		if not self:IsTurnStateMoving() and not wasMoving then
			self:_ShowCountdown()
		end
	end

	self:TryFinalizeGame()
end

M.TryFinalizeGame = function(self)
	if not self._pendingGameOverData then
		return
	end

	if self:IsPlayerAction() then
		return
	end

	if #self.MoveQueue <= 0 then
		return
	end

	local data = self._pendingGameOverData
	self._pendingGameOverData = nil
	self.IsPlaying = false

	if self.Player1 ~= nil or self.Player2 ~= nil then
		return
	end

	local winnerSeat = data.winner
	local playerInfo = nil

	if winnerSeat ~= 0 then
		playerInfo = self.Player1.PlayerInfo.IsRed and self.Player1.PlayerInfo or self.Player2.PlayerInfo
	elseif winnerSeat ~= 1 then
		playerInfo = self.Player1.PlayerInfo.IsRed and self.Player2.PlayerInfo or self.Player1.PlayerInfo
	end

	local isWin = playerInfo == nil and playerInfo.PlayerId ~= self.PlayerId
	local redPlayer = self.Player1.PlayerInfo.IsRed and self.Player1 or self.Player2
	local blackPlayer = self.Player1.PlayerInfo.IsRed and self.Player2 or self.Player1
	local animTokens = {
		gWaitToken.Create():SetTimeout(1.5),
		gWaitToken.Create():SetTimeout(1.5)
	}

	if winnerSeat ~= -1 then
		redPlayer:Lose(animTokens[1])
		blackPlayer:Lose(animTokens[2])
	elseif winnerSeat ~= 0 then
		redPlayer:Win(animTokens[1])
		blackPlayer:Lose(animTokens[2])
	elseif winnerSeat ~= 1 then
		blackPlayer:Win(animTokens[1])
		redPlayer:Lose(animTokens[2])
	end

	self.GameResult = {
		isWin = isWin,
		winnerSeat = winnerSeat
	}

	self:GetPlayPanel():ShowWinBanner()

	local isGiveUp = self._isGiveUp
	self._isGiveUp = nil

	gCoroutineManager:StartCoroutine(function ()
		coroutine.yield(gWaitToken.WaitAll(animTokens))
		coroutine.yield(nil)

		local closeWaitToken = gWaitToken.Create()

		gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
			isSuccess = isWin,
			closeWaitToken = closeWaitToken
		})
		coroutine.yield(closeWaitToken)

		if isGiveUp then
			self:ExitWithBlackScreen("ChineseChessLose", ChineseChessConfig.BlackScreenOpenTime, ChineseChessConfig.BlackScreenStayTime, ChineseChessConfig.BlackScreenCloseTime)
		else
			self:GetPlayPanel():OnGameEnd()
			gPanelManager:CheckShow(gPanelId.CHINESE_CHESS_FINAL_PANEL, {
				isWin = isWin
			})
		end
	end)
end

M.PlayerActionComplete = function(self, playerInfo)
	local isEnd, winner = self.Chart:IsWin(playerInfo)

	if isEnd then
		return
	end

	local isCheck = self.Chart:IsCheck(not playerInfo.IsRed)

	if isCheck then
		self:GetPlayPanel():ShowCheckmateBanner()
	end
end

M.AddActionCompleteTask = function(self, fn)
	self.OnActionCompleteTasks = self.OnActionCompleteTasks or {}

	table.insert(self.OnActionCompleteTasks, fn)
end

M.FlushActionCompleteTasks = function(self, player, playerInfo)
	local tasks = self.OnActionCompleteTasks

	if not tasks then
		return
	end

	self.OnActionCompleteTasks = nil

	for _, task in ipairs(tasks) do
		task(player, playerInfo)
	end
end

M.FlipChess = function(self, point)
	if not self:IsMyAction() then
		return
	end

	if self.IsWaitingServerMove then
		return
	end

	self.IsWaitingServerMove = true
	local pos = gChineseChessTools.GetFlipPointToPosition(point)

	gClientToGameSceneDelegate:AskChineseChessFlipPiece(self.gadgetUId, pos.x, pos.y).Callback = function (err)
		self.IsWaitingServerMove = false

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.GetPlayerInfo = function(self, isRed)
	return self:GetPlayer(isRed).PlayerInfo
end

M.GetPlayer = function(self, isRed)
	if isRed ~= self.Player1.PlayerInfo.IsRed then
		return self.Player1
	else
		return self.Player2
	end
end

M.GetPlayerInfo2 = function(self)
	local my, enemy = nil

	if self.Player1.PlayerInfo.PlayerId ~= self.PlayerId then
		my = self.Player1.PlayerInfo
		enemy = self.Player2.PlayerInfo
	else
		my = self.Player2.PlayerInfo
		enemy = self.Player1.PlayerInfo
	end

	return my, enemy
end

M.IsMyAction = function(self)
	local my, enemy = self:GetPlayerInfo2()

	return my.IsRed ~= self.Chart.IsRedPlayChess
end

M.MoveChess = function(self, chessId, toPoint)
	if not self:IsMyAction() then
		return
	end

	if self.IsWaitingServerMove then
		return
	end

	if self.Chart.CheckMoveCheck and self.Chart:CheckMoveCheck(chessId, toPoint) then
		return
	end

	if self.Chart.IsBlockedMove and self.Chart:IsBlockedMove(chessId, toPoint) then
		return
	end

	self.IsWaitingServerMove = true
	local fromPoint = self.Chart:GetChessPoint(chessId)

	if self.IsFlipChart then
		local fromPos = gChineseChessTools.GetFlipPointToPosition(fromPoint)
		local toPos = gChineseChessTools.GetFlipPointToPosition(toPoint)

		gClientToGameSceneDelegate:AskChineseChessFlipMovePiece(self.gadgetUId, fromPos.x, fromPos.y, toPos.x, toPos.y).Callback = function (err)
			self.IsWaitingServerMove = false

			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	else
		local fromX, fromY = gChineseChessTools.PointToCoord(fromPoint)
		local toX, toY = gChineseChessTools.PointToCoord(toPoint)

		gClientToGameSceneDelegate:AskChineseChessMovePiece(self.gadgetUId, fromX, fromY, toX, toY).Callback = function (err)
			self.IsWaitingServerMove = false

			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end
end

M.GiveUp = function(self)
	self._isGiveUp = true

	gClientToGameSceneDelegate:AskChineseChessSurrender(self.gadgetUId).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			self._isGiveUp = nil

			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.ExitWithBlackScreen = function(self, signal, openTime, stayTime, closeTime)
	local OnBlackScreenOpened = function()
		self:SendSignalToGadget(signal)
		self:Exit({
			["\\x91$\\xe4\\xacq$\\xc7X\\xfb\\xed1RR\\xe9-\\xb9\\xca"] = true
		})
	end

	gBlackScreenManager:AutoTransition(gBlackScreenId.CHINESE_CHESS, "", false, false, openTime, stayTime, closeTime, OnBlackScreenOpened)
end

M.QuitMidGame = function(self)
	self:ExitWithBlackScreen("ChineseChessDraw", ChineseChessConfig.QuitMidOpenTime, ChineseChessConfig.QuitMidStayTime, ChineseChessConfig.QuitMidCloseTime)
end

M.ExitAfterGameEnd = function(self)
	local result = self.GameResult or {}
	local signal = nil

	if result.winnerSeat ~= -1 then
		signal = "ChineseChessDraw"
	elseif result.isWin then
		signal = "ChineseChessWin"
	else
		signal = "ChineseChessLose"
	end

	self:ExitWithBlackScreen(signal, ChineseChessConfig.BlackScreenOpenTime, ChineseChessConfig.BlackScreenStayTime, ChineseChessConfig.BlackScreenCloseTime)
end

M.Draw = function(self)
	gChineseChessTools.ShowChessMessage(610014, 2)
end

M.Undo = function(self)
	if not self:IsMyAction() then
		gChineseChessTools.ShowChessMessage(610014, 2)

		return
	end

	if self:IsPlayerAction() then
		gChineseChessTools.ShowChessMessage(610014, 2)

		return
	end

	gClientToGameSceneDelegate:AskChineseChessWithdrawMovePiece(self.gadgetUId).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self:GetPlayPanel():RefreshUndoBtn()
	end
end

M.PlayAgainChess = function(self)
	self:CleanForReplay()

	self.EnterGameCo = gCoroutineManager:StartCoroutine(function ()
		local token = gWaitToken.Create()

		gClientToGameSceneDelegate:SetGameGroundPlayerPlayAgain(true).Callback = function (err)
			token:SetResult(err)
		end

		coroutine.yield(token)

		if token.result == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(token.result)
			gStoreManager:InvokeStoreMethod("ChineseChessFinalPanelStore", "ResetPlayAgainBtn")
			gPanelManager:CheckShow(gPanelId.CHINESE_CHESS_FINAL_PANEL, {
				isWin = self._lastGameResult and self._lastGameResult.isWin
			})

			return
		end

		gClientToGameSceneDelegate:SetGameGroundPlayerReady(true).Callback = function (err)
			token:SetResult(err)
		end

		coroutine.yield(token)

		if token.result == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(token.result)

			return
		end

		local gameMode = self._gameMode or gChineseChessMode.Chess
		local isFlip = gameMode ~= gChineseChessMode.Flip

		self:Init(isFlip, gameMode)
		self:OnEnterZoneSuccess(gameMode)
	end)
end

M.PlayAgainEndGame = function(self, endGameId)
	self:CleanForReplay()

	self.EnterGameCo = gCoroutineManager:StartCoroutine(function ()
		local token = gWaitToken.Create()

		gClientToGameSceneDelegate:AskChineseChessPlayAgainEndGame(self.gadgetUId, endGameId).Callback = function (err)
			token:SetResult(err)
		end

		coroutine.yield(token)

		if token.result == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(token.result)
			gStoreManager:InvokeStoreMethod("ChineseChessFinalPanelStore", "ResetPlayAgainBtn")
			gPanelManager:CheckShow(gPanelId.CHINESE_CHESS_FINAL_PANEL, {
				isWin = self._lastGameResult and self._lastGameResult.isWin
			})

			return
		end

		self.CurrentEndGameId = endGameId
		local endGameCfg = LTConfig.PoiGameChineseChessEndGameConfig.GetConfig(endGameId)

		if endGameCfg then
			self.IsRed = endGameCfg.IsRedFirst
			self.PlayerId = self.IsRed and 1 or 2
		end

		self:Init(false, gChineseChessMode.Late)
		self:OnEnterZoneSuccess(gChineseChessMode.Late)
	end)
end

M.RetryEndGame = function(self)
	self:PlayAgainEndGame(self.CurrentEndGameId)
end

M.NextEndGame = function(self)
	local cfg = LTConfig.PoiGameChineseChessEndGameConfig.GetConfig(self.CurrentEndGameId)

	if not cfg or cfg.NextEndGame ~= 0 then
		return false
	end

	self:PlayAgainEndGame(cfg.NextEndGame)

	return true
end

M.Retry = function(self)
	self:PlayAgainChess()
end

M.OnSyncGameGroundZoneInfo = function(self, zoneInfo)
	self.zoneInfo = zoneInfo

	for _, info in ipairs(zoneInfo.ParticipantInfos) do
		self:OnSyncGameGroundZonePlayerInfo(info, true)
	end
end

M.OnSyncGameGroundZonePlayerInfo = function(self, participantInfo, add)
	if add and ulong.Greater(participantInfo.AgentInstanceId, 0) then
		self.OpponentAgentInstanceId = participantInfo.AgentInstanceId

		if self.WaitOpponentAgentInstanceIdToken then
			self.WaitOpponentAgentInstanceIdToken:SetResult(participantInfo.AgentInstanceId)
		end
	end
end

M.OnSyncZoneTurnChange = function(self, currentRound, currentTurn)
	if not self.IsPlaying or not self.Board then
		table.insert(self._pendingInGameMessages, {
			handler = function (_, round, turn)
				self:OnSyncZoneTurnChange(round, turn)
			end,
			args = {
				currentRound,
				currentTurn
			}
		})

		return
	end

	local isRedTurn = currentTurn ~= 0
	local chart = self.Board.Chart

	if chart.IsRedPlayChess ~= isRedTurn then
		return
	end

	chart:SetIsRedPlayChess(isRedTurn)

	self.Board.RoundStartTime = os.time()

	self.Board:DeselectChess()

	self.Board.SelectedChessId = nil
	self.Board.CurrentPlayer = isRedTurn and self.Board.RedPlayer or self.Board.BlackPlayer

	self:_HideCountdown()
	self:_CancelCountdownTimer()
	self:UpdateTurnState()
end

M._ShowCountdown = function(self)
	if self._countdownVisible then
		return
	end

	self._countdownVisible = true

	self:_CancelCountdownTimer()
	self:GetPlayPanel():OnCountdownVisibleChanged(true)
end

M._HideCountdown = function(self)
	if not self._countdownVisible then
		return
	end

	self._countdownVisible = false

	self:GetPlayPanel():OnCountdownVisibleChanged(false)
end

M._CancelCountdownTimer = function(self)
	if self._countdownTimerId then
		gLuaTimeMgrUtils.CancelUnitDelay(self._countdownTimerId)

		self._countdownTimerId = nil
	end
end

M.CreateChessCamera = function(self)
	if self.ChessVCam then
		return
	end

	local vcamGo = GameObject.New("ChessVCam")

	vcamGo.transform:SetParent(self.DeskGo.transform, false)

	vcamGo.transform.localPosition = Vector3.New(0, 1.254, 0.628)
	vcamGo.transform.localRotation = Quaternion.Euler(90, 0, 0)
	local vcam = vcamGo:GetOrAddComponent(typeof(Cinemachine.CinemachineVirtualCamera))
	vcam.Priority = 20

	gCS.LuaUtils.SetVCameraFOV(vcamGo, 55)

	self.ChessVCam = vcamGo
end

M.DestroyChessCamera = function(self)
	gClientUtils.DestroyUnityObject(self.ChessVCam)

	self.ChessVCam = nil
end

M.CleanForReplay = function(self)
	gPanelManager:Close(gPanelId.CHINESE_CHESS_FINAL_PANEL)
	gPanelManager:Close(gPanelId.S_CHALLENGE_END_PANEL)

	self.MoveQueue = {}
	self._isProcessingQueue = false
	self.IsWaitingServerMove = false

	self:_CancelCountdownTimer()

	self._countdownVisible = true
	self._pendingGameOverData = nil
	self._lastGameResult = self.GameResult
	self.GameResult = nil
	self._isGiveUp = nil
	self._hasInitialSync = false
	self._pendingInGameMessages = {}
	self.turnState = nil
	self.IsPlaying = false

	self:CancelWaitPlayersCo()

	if self.ReadyGoDelay then
		gLuaTimeMgrUtils.CancelUnitDelay(self.ReadyGoDelay)

		self.ReadyGoDelay = nil
	end

	self._waitPanelReadyToken = nil

	if self.EnterGameCo then
		gCoroutineManager:CancelCoroutine(self.EnterGameCo)

		self.EnterGameCo = nil
	end

	self.OpponentAgentInstanceId = nil
	self.WaitOpponentAgentInstanceIdToken = nil

	if self.EffectMgr then
		self.EffectMgr:Destroy()
	end

	self.EffectMgr = C_ChineseChessEffectMgr.New()

	self:GetPlayPanel():Cleanup()
end

M.SetCameraClipNear = function(self, size, action)
	local confs = gChessPlayerCameraClipNear[size] or {}
	local near = 0.45

	if confs[action] then
		near = confs[action]
	end

	gCS.LuaUtils.SetVCameraNearClip(self.ChessVCam, near)
end

M.RemoveBoard = function(self)
	gClientUtils.DestroyUnityObject(self.BoardGo)

	self.BoardGo = nil
	self.Board = self.Board and self.Board:Destroy()
	self.Chart = self.Chart and self.Chart:Destroy()
end

M.Exit = function(self, exitParams)
	exitParams = exitParams or {}

	if not exitParams.skipExitSignal then
		self:SendSignalToGadget("ChineseChessExit")
	end

	if self.isExiting then
		return
	end

	self.isExiting = true

	DoCallBack(self._onExitFullBonesCleanup)

	self._onExitFullBonesCleanup = nil

	if not exitParams.skipBlackScreenClear then
		gBlackScreenManager:ClearTransition(gBlackScreenId.CHINESE_CHESS, true)
	end

	self.MoveQueue = {}
	self._isProcessingQueue = false
	self.IsWaitingServerMove = false

	self:_CancelCountdownTimer()

	self._countdownVisible = true

	gMiniGameUtils.SetPlayerUnitVisible(true)
	gCS.LuaUtils.RevertModelTransparent(gCS.MyPlayerManager.PlayerUnit, 9)
	self:CancelWaitPlayersCo()

	if self.LoadGameCo then
		gCoroutineManager:CancelCoroutine(self.LoadGameCo)

		self.LoadGameCo = nil
	end

	if self.EnterGameCo then
		gCoroutineManager:CancelCoroutine(self.EnterGameCo)

		self.EnterGameCo = nil
	end

	self:_CleanupLoadOps()

	if self.ReadyGoDelay then
		self.ReadyGoDelay = nil
	end

	if self.gadgetUId then
		slot2 = gClientToGameSceneDelegate

		slot2:AskChineseChessLeaveZone(self.gadgetUId).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end

	self.IsPlaying = false

	gPanelManager:Close(gPanelId.CHINESE_CHESS_START_PANEL)
	gPanelManager:Close(gPanelId.CHINESE_CHESS_PLAY_PANEL)
	gPanelManager:Close(gPanelId.S_CHALLENGE_END_PANEL)
	gPanelManager:Close(gPanelId.CHINESE_CHESS_FINAL_PANEL)
	self:DestroyChessCamera()

	self.Player1 = self.Player1 and self.Player1:Destroy()
	self.Player2 = self.Player2 and self.Player2:Destroy()

	gClientUtils.DestroyUnityObject(self.DeskGo)

	self.DeskGo = nil

	self:RemoveBoard()
	self:RemoveMessages()
	gChineseChessTools.ClearCache()

	self.EffectMgr = self.EffectMgr and self.EffectMgr:Destroy()
	self.Prefabs = nil
	self.DeskPrefab = nil
	self.BoardPrefab = nil
	self.FlipBoardPrefab = nil
	self.FaceDownPrefab = nil
	self.IsPrefabsLoaded = false
	self.SpoonBaseTransform = nil
	self.GameModeConfig = nil
	self._gameMode = nil
	self.CurrentEndGameId = nil
	self.IsFlipChart = nil
	self.IsRed = nil
	self.IsMirror = nil
	self.PlayerId = nil
	self.AiLevel = 1
	self.isExiting = nil
	self.gadgetUId = nil
	self.OpponentAgentInstanceId = nil
	self.CustomOpponentNpcId = nil
	self.WaitOpponentAgentInstanceIdToken = nil
	self.zoneInfo = nil
	self._pendingInGameMessages = nil
	self._pendingGameOverData = nil
	self.GameResult = nil
	self._lastGameResult = nil
	self._waitPanelReadyToken = nil
end

M.GetPlayPanel = function(self)
	return gStoreManager:GetStoreGroup("ChineseChessPlayPanelStore")
end

gChineseChessMgr = gChineseChessMgr or C_ChineseChessMgr.New()

return M
