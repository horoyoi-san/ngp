gBowlingModeOnline = DefClass("BowlingModeOnline", gBowlingModeOnline, gBowlingModeBase)
local BowlingModeOnline = gBowlingModeOnline
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local GameState = BowlingConstants.GameState
local OnlineGameState = BowlingConstants.OnlineGameState
local TimelineScene = BowlingConstants.TimelineScene
local BConfig = require("LX6/MiniGame/BowlingGame/BowlingConfig")
local BowlingMessageManager = require("LX6/MiniGame/BowlingGame/BowlingMessageManager")

local function print_debug(...)
	if gBowlingGameManager.debug then
		print_warn("[BowlingGameOnline]", ...)
	end
end

function BowlingModeOnline:InitData()
	BowlingModeOnline.base.InitData(self)
	self:InitPlayerData()

	self.maxFrames = self.config.maxFrames or 3
	self.currentFrame = 1
	self.onlineGameState = OnlineGameState.WAITING
	self.currentRound = 1
	self.currentTurn = 1
	self.isCurrentTurn = false
	self.localPlayerId = gPlayerManager.infoBase.bindData.Pid

	self:OnSyncZoneInfo(self.game.args.zoneInfo)
end

function BowlingModeOnline:InitPlayerData()
	self.currentPlayerIndex = 1
	self.players = {}
	self.isFirstSwitch = true

	for i = 1, self.config.playerCount do
		self.players[i] = {
			currentFrame = 1,
			isFirst = true,
			isReady = false,
			nextThrow = 1,
			isPlayAgain = false,
			playerId = 0,
			maxFrames = self.config.maxFrames or 3,
			throwScoresClient = {
				{},
				{},
				{}
			},
			splitScoresClient = {
				{},
				{},
				{}
			},
			curBallIndex = math.ceil(#BConfig.Launcher.prefabPaths.balls / 2),
			seatCsIndex = i - 1
		}
	end
end

function BowlingModeOnline:GetCurrentPlayer()
	return self.players[self.currentPlayerIndex]
end

function BowlingModeOnline:GetLocalPlayer()
	return self.players[self.localPlayerIndex], self.localPlayerIndex
end

function BowlingModeOnline:SetCurrentPlayerBallIndex(ballIndex)
	local currentPlayer = self:GetCurrentPlayer()

	if currentPlayer then
		currentPlayer.curBallIndex = ballIndex
	end
end

function BowlingModeOnline:GetCurrentPlayerBallIndex()
	local currentPlayer = self:GetCurrentPlayer()

	return currentPlayer and currentPlayer.curBallIndex or 1
end

function BowlingModeOnline:ProcessGameState()
	if self.onlineGameState == OnlineGameState.WAITING then
		self:ProcessState_Waiting()
	elseif self.onlineGameState == OnlineGameState.READY then
		if self.game.gameState == GameState.INIT then
			self:ProcessState_Init()
		elseif self.game.gameState == GameState.ANIM then
			self:ProcessState_Anim()
		elseif self.game.gameState == GameState.READY then
			self:ProcessState_Ready()
		elseif self.game.gameState == GameState.THROWING then
			self:ProcessState_Throwing()
		elseif self.game.gameState == GameState.ROLLING then
			self:ProcessState_Rolling()
		elseif self.game.gameState == GameState.SCORING then
			self:ProcessState_Scoring()
		elseif self.game.gameState == GameState.RESETTING then
			self:ProcessState_Resetting()
		elseif self.game.gameState == GameState.CELEBRATE then
			self:ProcessState_Celebrate()
		end
	elseif self.onlineGameState == OnlineGameState.PLAYING then
		if self.isCurrentTurn then
			if self.game.gameState == GameState.INIT then
				self:ProcessState_Init()
			elseif self.game.gameState == GameState.ANIM then
				self:ProcessState_Anim()
			elseif self.game.gameState == GameState.READY then
				self:ProcessState_Ready()
			elseif self.game.gameState == GameState.THROWING then
				self:ProcessState_Throwing()
			elseif self.game.gameState == GameState.ROLLING then
				self:ProcessState_Rolling()
			elseif self.game.gameState == GameState.SCORING then
				self:ProcessState_Scoring()
			elseif self.game.gameState == GameState.RESETTING then
				self:ProcessState_Resetting()
			end
		end
	elseif self.onlineGameState == OnlineGameState.FINISHED then
		self:ProcessState_Finished()
	end
end

function BowlingModeOnline:ProcessState_Waiting()
	local currentTime = Time.time

	if currentTime < self.game.initEndTime then
		return
	end

	local localPlayer, localIndex = self:GetLocalPlayer()

	if localPlayer and localPlayer.isFirst and localIndex == 1 then
		localPlayer.isFirst = false
		local currentCharacter = self.game:GetCharacter(1)

		currentCharacter:ExecuteTimeLine(TimelineScene.ENTER, function ()
			gBowlingGameManager.currentGame:OnEventAnimWalkEnd()
		end)
	else
		self.game.IsWalkEnd = true
	end

	self.game.gameState = GameState.ANIM
end

function BowlingModeOnline:ProcessState_Init()
	local currentTime = Time.time

	if currentTime < self.game.initEndTime then
		return
	end

	local localPlayer, localIndex = self:GetLocalPlayer()

	if localPlayer and localPlayer.isFirst and self:IsLocalPlayerTurn() then
		localPlayer.isFirst = false
		local currentCharacter = self.game:GetCurrentCharacter()

		currentCharacter:ExecuteTimeLine(TimelineScene.ENTER, function ()
			gBowlingGameManager.currentGame:OnEventAnimWalkEnd()
		end)
	end

	self.game.gameState = GameState.ANIM
end

function BowlingModeOnline:ProcessState_Anim()
	if self.game.IsWalkEnd then
		self.game.IsWalkEnd = false
		self.game.IsLaunchEnd = false
		self.game.gameState = GameState.READY

		self.game.camera:ResetCamera()

		if self.game.ballLauncher and self:IsLocalPlayerTurn() then
			self.game.ballLauncher:BeginPos(self:GetCurrentPlayerBallIndex())
			coroutine.wait(0.1)
			self.game.camera:ResetCamera()

			local currentPlayer = self:GetCurrentPlayer()
		end
	end
end

function BowlingModeOnline:ProcessState_Ready()
	if not self:IsLocalPlayerTurn() then
		return
	end
end

function BowlingModeOnline:ProcessState_Throwing()
	if not self:IsLocalPlayerTurn() then
		return
	end

	if self.game.IsLaunchEnd then
		self.game.gameState = GameState.ROLLING
	end
end

function BowlingModeOnline:ProcessState_Rolling()
	if not self.game:CheckBallAndPinsSettled() then
		return
	end

	local currentTime = Time.time
	self.game.gameState = GameState.SCORING
	self.game.scoringEndTime = currentTime + 3

	self.game.camera:AddShake(0.2, 0.3)
	self.game.camera:StopFollow()
end

function BowlingModeOnline:ProcessState_Scoring()
	local currentTime = Time.time
	local hasStandPins = self.game.pinSetter:hasStandPins()

	if currentTime < self.game.scoringEndTime and hasStandPins then
		return
	end

	local currentPlayer = self:GetCurrentPlayer()

	self:ProcessScore(hasStandPins, currentPlayer)

	local currentFrame = currentPlayer.currentFrame

	if currentFrame == currentPlayer.maxFrames then
		local currentThrows = currentPlayer.throwScoresClient[currentFrame]
		local currentThrow = #currentThrows

		if currentThrow == 1 and currentThrows[1] == 10 then
			self.game.pinSetter:ResetPins()
		elseif currentThrow == 2 then
			local firstThrow = currentThrows[1]
			local secondThrow = currentThrows[2]

			if secondThrow == 10 or firstThrow + secondThrow >= 10 then
				self.game.pinSetter:ResetPins()
			end
		end
	end

	self.game.gameState = GameState.RESETTING

	self.game.ballLauncher:ClearBall()

	if not self:CheckAllPlayersGameOver() then
		self:PrepareNextThrow(currentPlayer)
	end

	if not self:IsNeedSwitchTurn(currentPlayer) then
		local localPlayer, localIndex = self:GetLocalPlayer()
		local isStrike = self:IsStrike(currentPlayer)
		local isSpare = self:IsSpare(currentPlayer)

		self:PlayBackTimeline(localIndex, isStrike, isSpare)
		self:BroadcastPlayBackTimelineInfo(localIndex, isStrike, isSpare)
	end

	self.game.pinSetter:ResetStandingPins()
end

function BowlingModeOnline:ProcessState_Resetting()
	local currentTime = Time.time

	if self.game.IsBackEnd then
		if self:CheckAllPlayersGameOver() then
			self.game.gameState = GameState.CELEBRATE

			self:OnGameFinished()
		else
			self.game.camera:ResetCamera()

			self.game.gameState = GameState.INIT
			self.game.initEndTime = currentTime
		end
	end
end

function BowlingModeOnline:ProcessState_Celebrate()
	self.game.gameState = GameState.GAMEOVER

	self.game:Settle()
	self.game:GameOver()
end

function BowlingModeOnline:ProcessState_Finished()
	return
end

function BowlingModeOnline:IsLocalPlayerTurn()
	return self.localPlayerIndex == self.currentPlayerIndex
end

function BowlingModeOnline:CalculateFrameScore(player, frameIndex)
	local throws = player.throwScoresClient[frameIndex]

	if not throws or #throws == 0 then
		return 0
	end

	local baseScore = 0

	for _, score in ipairs(throws) do
		baseScore = baseScore + score
	end

	return baseScore
end

function BowlingModeOnline:HasThirdBallQualification(player)
	local throws = player.throwScoresClient[player.maxFrames]

	if throws == nil or #throws == 0 then
		return false
	elseif #throws == 1 then
		return throws[1] == 10
	elseif #throws == 2 then
		local firstThrow = throws[1]
		local secondThrow = throws[2]

		if firstThrow == 10 then
			return true
		elseif firstThrow + secondThrow >= 10 then
			return true
		else
			return false
		end
	else
		return true
	end
end

function BowlingModeOnline:UpdateBowlingScore(currentPlayer, knockedPins, currentFrame, isSplit)
	table.insert(currentPlayer.throwScoresClient[currentFrame], knockedPins)
	table.insert(currentPlayer.splitScoresClient[currentFrame], isSplit or false)
end

function BowlingModeOnline:ProcessScore(hasStand, currentPlayer)
	if not self:IsLocalPlayerTurn() then
		return
	end

	local knockedPins = self.game.pinSetter:CountKnockedDownPins()
	local currentFrame = currentPlayer.currentFrame
	local isSplit = hasStand and self.game.pinSetter:CheckSplit()

	self:UpdateBowlingScore(currentPlayer, knockedPins, currentFrame, isSplit)
	self:RecordScoreToServer(#currentPlayer.throwScoresClient[currentFrame], knockedPins)
	self:RefreshScoreUI()
	self:BroadcastLocalScore()

	if hasStand then
		return
	end

	local delay = self.game.scoringEndTime - Time.time

	if delay < 0.5 then
		delay = 0.5
	end

	coroutine.wait(delay)
end

function BowlingModeOnline:RecordScoreToServer(throwIndex, score)
	local gadgetUId = self.game.args.entityInstanceId

	gBowlingGameManager:RecordBowlingScore(gadgetUId, throwIndex, score)
end

function BowlingModeOnline:IsPlayerGameOver(player)
	if player.currentFrame < player.maxFrames then
		return false
	end

	local lastFrame = player.maxFrames
	local throws = player.throwScoresClient[lastFrame]

	if not throws or #throws == 0 then
		return false
	end

	if #throws == 1 then
		return false
	elseif #throws == 2 then
		local firstThrow = throws[1] or 0
		local secondThrow = throws[2] or 0

		if firstThrow == 10 then
			return false
		elseif firstThrow + secondThrow >= 10 then
			return false
		else
			return true
		end
	else
		return true
	end
end

function BowlingModeOnline:CheckAllPlayersGameOver()
	for _, player in ipairs(self.players) do
		if not self:IsPlayerGameOver(player) then
			return false
		end
	end

	return true
end

function BowlingModeOnline:PrepareNextThrow(currentPlayer)
	if self:IsPlayerGameOver(currentPlayer) then
		print_debug("[BowlingModeOnline] PrepareNextThrow: Player game over")

		return
	end

	if currentPlayer.currentFrame < currentPlayer.maxFrames then
		if #currentPlayer.throwScoresClient[currentPlayer.currentFrame] == 1 then
			local throws = currentPlayer.throwScoresClient[currentPlayer.currentFrame]

			if throws and #throws > 0 and throws[1] == 10 then
				self:NextFrame(currentPlayer)
			else
				currentPlayer.nextThrow = 2
			end
		else
			self:NextFrame(currentPlayer)
		end
	else
		local throws = currentPlayer.throwScoresClient[currentPlayer.currentFrame]

		if not throws then
			return
		end

		if #throws == 1 then
			currentPlayer.nextThrow = 2
		elseif #throws == 2 and self:HasThirdBallQualification(currentPlayer) then
			currentPlayer.nextThrow = 3
		end
	end
end

function BowlingModeOnline:NextFrame(currentPlayer)
	if not currentPlayer then
		return
	end

	if currentPlayer.maxFrames <= currentPlayer.currentFrame then
		print_debug("[BowlingModeOnline] NextFrame: Already at max frame")

		return
	end

	currentPlayer.nextThrow = 1
	currentPlayer.currentFrame = currentPlayer.currentFrame + 1

	print_debug("[BowlingModeOnline] NextFrame: Moved to frame " .. currentPlayer.currentFrame)
end

function BowlingModeOnline:SwitchToNextPlayer()
	self.currentPlayerIndex = self.currentPlayerIndex + 1

	if self.config.playerCount < self.currentPlayerIndex then
		self.currentPlayerIndex = 1
	end

	local currentPlayer = self:GetCurrentPlayer()

	if currentPlayer then
		self.game.ballLauncher:SetNPCMode(false)
	end
end

function BowlingModeOnline:OnGameFinished(force)
	if self.gameResult == nil or not self.gameResult.isGameEnd then
		if force then
			self.gameResult = {
				isWin = true
			}
		else
			return
		end
	end

	if self.playGameResultTimelineOnce then
		return
	end

	self.playGameResultTimelineOnce = true
	local win = self.gameResult.isWin

	self.game:ShowResultPanel(win)

	local draw = false
	local localPlayer, localIndex = self:GetLocalPlayer()

	gBowlingGameManager:SendSignalToGadget("GameFinished")

	local function onTimelineComplete()
		print_debug("[BowlingModeOnline] OnGameFinished: animation completed, executing settlement")

		if self.game then
			self.game:GameOver()
		end

		gBowlingGameManager:SetPlayAgain(false)
		gBowlingGameManager:DestroyGame()
	end

	if localPlayer then
		if win then
			self.game:GetCharacter(localIndex):ExecuteTimeLine(TimelineScene.WIN, onTimelineComplete)
		elseif draw then
			self.game:GetCharacter(localIndex):ExecuteTimeLine(TimelineScene.DRAW, onTimelineComplete)
		else
			self.game:GetCharacter(localIndex):ExecuteTimeLine(TimelineScene.LOSE, onTimelineComplete)
		end
	else
		onTimelineComplete()
	end

	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_MAIN_PANEL)
end

function BowlingModeOnline:OnSyncZoneInfo(zoneInfo)
	print_debug("[BowlingModeOnline] OnSyncZoneInfo")

	for i, participantInfo in ipairs(zoneInfo.ParticipantInfos) do
		self:OnSyncZonePlayerInfo(participantInfo)
	end

	if self.localPlayerIndex == nil then
		print_error("[BowlingModeOnline] OnSyncZoneInfo: localPlayerIndex not found", zoneInfo.ParticipantInfos, self.localPlayerId)
	end

	local allReady = true

	for i = 1, self.config.playerCount do
		if not self.players[i].isReady then
			allReady = false

			break
		end
	end

	if allReady and self.onlineGameState == OnlineGameState.WAITING then
		print_debug("[BowlingModeOnline] OnSyncZoneInfo: all players ready, changing to READY state")

		self.onlineGameState = OnlineGameState.READY
	end
end

function BowlingModeOnline:OnSyncZonePlayerInfo(participantInfo, add)
	local playerIndex = participantInfo.SeatIndex + 1
	local localPlayer = self.players[playerIndex]
	localPlayer.playerId = participantInfo.Pid
	localPlayer.seatCsIndex = participantInfo.SeatIndex

	if participantInfo.Pid == self.localPlayerId then
		self.localPlayerIndex = playerIndex
	end
end

function BowlingModeOnline:OnSyncZoneState(state)
	print_debug("[BowlingModeOnline] OnSyncZoneState: state=" .. tostring(state))

	if state == UX.Game.GameGroundZoneState.Idle then
		print_debug("[BowlingModeOnline] OnSyncZoneState: changing to WAITING (Idle)")

		self.onlineGameState = OnlineGameState.WAITING
	elseif state == UX.Game.GameGroundZoneState.Display then
		print_debug("[BowlingModeOnline] OnSyncZoneState: changing to WAITING (Display)")

		self.onlineGameState = OnlineGameState.WAITING
	elseif state == UX.Game.GameGroundZoneState.GameStart then
		print_debug("[BowlingModeOnline] OnSyncZoneState: changing to PLAYING (GameStart)")

		self.onlineGameState = OnlineGameState.PLAYING

		print_debug("[BowlingModeOnline] OnSyncZoneState: isCurrentTurn will be set by TurnChange message")
	elseif state == UX.Game.GameGroundZoneState.GameOver then
		print_debug("[BowlingModeOnline] OnSyncZoneState: changing to FINISHED (GameOver)")

		self.onlineGameState = OnlineGameState.FINISHED
	end

	print_debug("[BowlingModeOnline] OnSyncZoneState: final onlineGameState=" .. tostring(self.onlineGameState))
end

function BowlingModeOnline:OnSyncTurnChange(currentRound, currentTurnCsIndex)
	self.currentRound = currentRound
	self.currentTurn = currentTurnCsIndex
	local localPlayer, localPlayerIndex = self:GetLocalPlayer()
	local wasCurrentTurn = self.isCurrentTurn
	local playerSeatCsIndex = localPlayer.seatCsIndex
	self.isCurrentTurn = playerSeatCsIndex == currentTurnCsIndex
	self.currentPlayerIndex = currentTurnCsIndex + 1

	if self.isCurrentTurn and not wasCurrentTurn then
		print_debug("[BowlingModeOnline] OnSyncTurnChange: now it's my turn")

		self.game.gameState = GameState.INIT

		gBowlingGameManager:AskHandHoldSceneItem()

		local timer = Timer.New(function ()
			if self and self.game and self.game.pinSetter then
				self.game.pinSetter:ResetPins()
			end
		end, 0.5)

		timer:Start()
	else
		gBowlingGameManager:AskPutDownSceneItem()
	end

	gBowlingGameManager:DisableBalls()

	for time = 1, 10 do
		local timer = Timer.New(function ()
			gBowlingGameManager:DisableBalls()
		end, time)

		timer:Start()
	end

	local lastPlayerIndex = 3 - self.currentPlayerIndex
	local lastPlayer = self.players[lastPlayerIndex]
	local isStrike = self:IsStrike(lastPlayer)
	local isSpare = self:IsSpare(lastPlayer)

	self:PlaySwitchTimeline(lastPlayerIndex, isStrike, isSpare, self.isFirstSwitch)

	self.isFirstSwitch = false

	BowlingMessageManager:SendMessage(gEventConstants.BOWLING_GAME_FRAME_DESC, {
		isSwitch = true,
		playerIndex = self.currentPlayerIndex,
		frame = lastPlayer.currentFrame
	})
end

function BowlingModeOnline:OnSyncScoreInfo(scoreInfo)
	if scoreInfo.Winner ~= -1 then
		local isWin = scoreInfo.Winner == -2 or self.localPlayerIndex == scoreInfo.Winner + 1
		self.gameResult = {
			isGameEnd = true,
			isWin = isWin
		}

		self:OnGameFinished()
	end
end

function BowlingModeOnline:IsNeedSwitchTurn(player)
	if self:CheckAllPlayersGameOver() then
		return false
	end

	if self:IsPlayerGameOver(player) then
		return true
	end

	if player.currentFrame < player.maxFrames then
		if #player.throwScoresClient[player.currentFrame] == 1 then
			local throws = player.throwScoresClient[player.currentFrame]

			return throws and #throws > 0 and throws[1] == 10
		else
			return true
		end
	else
		local throws = player.throwScoresClient[player.currentFrame]

		if not throws then
			return false
		end

		if #throws == 1 then
			return false
		elseif #throws == 2 then
			return not self:HasThirdBallQualification(player)
		else
			return true
		end
	end
end

function BowlingModeOnline:GetOtherPlayerName()
	for i, v in ipairs(self.players) do
		if v.playerId ~= self.localPlayerId then
			return gFriendManager:GetPlayerRealName(v.playerId)
		end
	end
end

function BowlingModeOnline:BuildScoreDataFromPlayers()
	local scoreData = {}

	for i = 1, #self.players do
		local player = self.players[i]
		local playerScoreData = {
			split = player.splitScoresClient,
			score = player.throwScoresClient
		}
		scoreData[i] = playerScoreData
	end

	return scoreData
end

function BowlingModeOnline:RefreshScoreUI()
	local store = gStoreManager:GetStoreGroup("BowlingScoreBattlePanelStore")
	local scoreData = self:BuildScoreDataFromPlayers()
	local isGameEnd, isWin = store:FullRefreshByScoreData(scoreData)
end

function BowlingModeOnline:BroadcastLocalScore()
	local localPlayer, localIndex = self:GetLocalPlayer()
	local scoreData = {
		index = localIndex,
		split = localPlayer.splitScoresClient,
		score = localPlayer.throwScoresClient
	}

	gBowlingGameManager:BroadcastBowlingClientInfo(BowlingConstants.SyncDataType.Score, scoreData)
end

function BowlingModeOnline:BroadcastPlayBackTimelineInfo(...)
	local timelineData = {
		...
	}

	gBowlingGameManager:BroadcastBowlingClientInfo(BowlingConstants.SyncDataType.PlayBackTimeline, timelineData)
end

function BowlingModeOnline:BroadcastLaunchTimelineInfo(...)
	local timelineData = {
		...
	}

	gBowlingGameManager:BroadcastBowlingClientInfo(BowlingConstants.SyncDataType.PlayLaunchTimeline, timelineData)
end

function BowlingModeOnline:OnSyncClientInfo(info)
	local type = info.Type

	if type == BowlingConstants.SyncDataType.Score then
		self:OnSyncClientScoreInfo(info.Data)
	elseif type == BowlingConstants.SyncDataType.PlayBackTimeline then
		self:PlayBackTimeline(unpack(info.Data))
	elseif type == BowlingConstants.SyncDataType.PlayLaunchTimeline then
		self:ExecuteLaunchTimeline(unpack(info.Data))
	elseif type == BowlingConstants.SyncDataType.RefreshPinStateUI then
		BowlingMessageManager:SendMessage(gEventConstants.BOWLING_GAME_PINSTATE, info.Data)
	elseif type == BowlingConstants.SyncDataType.RefreshLaunchUI then
		self:OnSyncClientLaunchStateInfo(info.Data)
	elseif type == BowlingConstants.SyncDataType.BallCameraFollow then
		self:OnSyncBallCameraFollow(info.Data)
	elseif type == BowlingConstants.SyncDataType.ResetCamera then
		self.game.camera:ResetCamera(true)
	elseif type == BowlingConstants.SyncDataType.BallCameraStopFollow then
		self.game.camera:StopFollow(true, false)
	elseif type == BowlingConstants.SyncDataType.ResetLaunchObj and self.game and self.game.ballLauncher then
		self.game.ballLauncher:ResetLaunchObj(0, 0, true)
	end
end

function BowlingModeOnline:OnSyncClientScoreInfo(data)
	local player = self.players[data.index]
	player.splitScoresClient = data.split
	player.throwScoresClient = data.score

	self:RefreshScoreUI()
end

function BowlingModeOnline:OnSyncClientLaunchStateInfo(data)
	if not self:IsLocalPlayerTurn() then
		local store = gStoreManager:GetStoreGroup("BowlingGameMainPanelStore")

		store:OnSyncClientLaunchStateInfo(data)
	end
end

function BowlingModeOnline:OnSyncBallCameraFollow(data)
	local id = ulong.new(unpack(data))
	local hold = gCS.SceneItemMgr:GetSceneItemHold(id)
	local ballGo = hold and hold.SceneItemObj

	if ballGo then
		self.game.camera:StartFollowFromSync(ballGo)
	else
		print_warn("[BowlingModeOnline] hold or go not found!, hold=", hold, " id=", ulong.tostring(id))
	end
end

function BowlingModeOnline:IsStrike(player)
	local throws = player.throwScoresClient[player.currentFrame]

	return throws and #throws > 0 and throws[1] == 10
end

function BowlingModeOnline:IsSpare(player)
	local throws = player.throwScoresClient[player.currentFrame]

	if not throws or #throws < 2 then
		return false
	end

	local firstThrow = throws[1] or 0
	local secondThrow = throws[2] or 0

	return firstThrow ~= 10 and firstThrow + secondThrow >= 10
end

function BowlingModeOnline:PlaySwitchTimeline(playerIndex, isStrike, isSpare, isFirstSwitch)
	local character = self.game:GetCharacter(playerIndex)

	if not character then
		print_error("[BowlingModeOnline] PlaySwitchTimeline: character is nil, playerIndex=" .. playerIndex)

		return
	end

	self.game.IsBackEnd = false
	self.game.IsWalkEnd = false

	if self.game.ballLauncher then
		self.game.ballLauncher:BeginAnim()
	end

	self.game.camera:ResetCamera()

	local timelineScene = (isStrike or isSpare) and (isFirstSwitch and TimelineScene.SWITCH_S or TimelineScene.SWITCH_N_S) or isFirstSwitch and TimelineScene.SWITCH or TimelineScene.SWITCH_N

	character:ExecuteTimeLine(timelineScene, function ()
		self.game.IsBackEnd = true
		self.game.IsWalkEnd = true

		BowlingMessageManager:SendMessage(gEventConstants.BOWLING_TECH_SUCCICON_HIDE)
		self:OnEventAnimBackEnd()
	end)
end

function BowlingModeOnline:PlayBackTimeline(playerIndex, isStrike, isSpare)
	local character = self.game:GetCharacter(playerIndex)

	if not character then
		print_error("[BowlingModeOnline] PlayBackTimeline: character is nil, playerIndex=" .. playerIndex)

		return
	end

	self.game.IsBackEnd = false
	self.game.IsWalkEnd = false

	if self.game.ballLauncher then
		self.game.ballLauncher:BeginAnim()
	end

	self.game.camera:ResetCamera()

	local timelineScene = (isStrike or isSpare) and TimelineScene.BACK_S or TimelineScene.BACK

	character:ExecuteTimeLine(timelineScene, function ()
		self.game.IsBackEnd = true
		self.game.IsWalkEnd = true

		BowlingMessageManager:SendMessage(gEventConstants.BOWLING_TECH_SUCCICON_HIDE)
		self:OnEventAnimBackEnd()
	end)
end

function BowlingModeOnline:ExecuteLaunchTimeline(playerIndex, offsetX, fromSync)
	BowlingModeOnline.base.ExecuteLaunchTimeline(self, playerIndex, offsetX, fromSync)

	if not fromSync then
		self:BroadcastLaunchTimelineInfo(playerIndex, offsetX, true)
	end
end
