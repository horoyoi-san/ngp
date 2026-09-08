-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingModeOnline.lua
-- Decompiled from: 00657_BowlingModeOnline.lua_789a17a15ab4.luajit

gBowlingModeOnline = DefClass("BowlingModeOnline", gBowlingModeOnline, gBowlingModeBase)
local BowlingModeOnline = gBowlingModeOnline
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local GameState = BowlingConstants.GameState
local OnlineGameState = BowlingConstants.OnlineGameState
local TimelineScene = BowlingConstants.TimelineScene
local BConfig = require("LX6/MiniGame/BowlingGame/BowlingConfig")
local BowlingUtils = require("LX6/MiniGame/BowlingGame/BowlingUtils")
local BowlingBallMirror = require("LX6/MiniGame/BowlingGame/BowlingBallMirror")
local BowlingPinMirror = require("LX6/MiniGame/BowlingGame/BowlingPinMirror")

require("LX6/MiniGame/BowlingGame/BowlingNpcRandomAiController")
require("LX6/MiniGame/BowlingGame/BowlingNpcTechAiController")

local json = require("cjson/json")

local print_debug = function(...)
	if gBowlingGameManager.debug then
		print_warn("[BowlingGameOnline]", ...)
	end
end

BowlingModeOnline.InitData = function(self)
	BowlingModeOnline.base.InitData(self)
	self:InitPlayerData()

	self._succIconLastCounts = {}
	self.maxFrames = self.config.maxFrames or 3
	self.currentFrame = 1
	self.onlineGameState = OnlineGameState.WAITING
	self.currentRound = 1
	self.currentTurn = 1
	self.isCurrentTurn = false
	self.localPlayerId = gPlayerManager.infoBase.bindData.Pid
	self.remoteBallMirror = BowlingBallMirror.new(self.game)
	self.remotePinMirror = BowlingPinMirror.new(self.game)
	self.isHosting = false
	self.pendingHostingResetPins = false
	self.lastAppliedRackState = nil
	self.isHosted = false
	self.hostedPlayerIndex = nil
	self.hostedPlayerPid = nil
	self.hostedAi = nil

	self:OnSyncZoneInfo(self.game.args.zoneInfo)
end

BowlingModeOnline.InitPlayerData = function(self)
	self.currentPlayerIndex = 1
	self.players = {}
	self.isFirstSwitch = true

	for i = 1, self.config.playerCount do
		self.players[i] = {
			["lc\\xbeeI\\xbc\\xe6ax{sI"] = 1,
			["\\xd0\\xc827\\xe5"] = true,
			["\\xd0\\xc8& \\xe8"] = false,
			["MBt}z/"] = 1,
			["\\x96'3y\\x84`\\xde6\\xa3\\xb7"] = false,
			["\\xbb\\xbd\\xb2o,\\xd77"] = 0,
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

BowlingModeOnline.GetCurrentPlayer = function(self)
	return self.players[self.currentPlayerIndex]
end

BowlingModeOnline.GetLocalPlayer = function(self)
	return self.players[self.localPlayerIndex], self.localPlayerIndex
end

BowlingModeOnline.SetCurrentPlayerBallIndex = function(self, ballIndex)
	local currentPlayer = self.GetCurrentPlayer(self)

	if currentPlayer then
		currentPlayer.curBallIndex = ballIndex
	end
end

BowlingModeOnline.GetCurrentPlayerBallIndex = function(self)
	local currentPlayer = self:GetCurrentPlayer()

	return currentPlayer and currentPlayer.curBallIndex or 1
end

BowlingModeOnline.ProcessGameState = function(self)
	local gameState = self.game.gameState

	print_debug("gameState", gameState, "onlineGameState", self.onlineGameState)

	if self.onlineGameState ~= OnlineGameState.WAITING then
		self.ProcessState_Waiting(self)
	elseif self.onlineGameState ~= OnlineGameState.READY then
		if gameState ~= GameState.INIT then
			self.ProcessState_Init(self)
		elseif gameState ~= GameState.ANIM then
			self.ProcessState_Anim(self)
		elseif gameState ~= GameState.READY then
			self.ProcessState_Ready(self)
		elseif gameState ~= GameState.THROWING then
			self.ProcessState_Throwing(self)
		elseif gameState ~= GameState.ROLLING then
			self.ProcessState_Rolling(self)
		elseif gameState ~= GameState.SCORING then
			self.ProcessState_Scoring(self)
		elseif gameState ~= GameState.RESETTING then
			self.ProcessState_Resetting(self)
		elseif gameState ~= GameState.CELEBRATE then
			self.ProcessState_Celebrate(self)
		end
	elseif self.onlineGameState ~= OnlineGameState.PLAYING then
		if self.IsAuthorityTurn(self) then
			if gameState ~= GameState.INIT then
				self.ProcessState_Init(self)
			elseif gameState ~= GameState.ANIM then
				self.ProcessState_Anim(self)
			elseif gameState ~= GameState.READY then
				self.ProcessState_Ready(self)
			elseif gameState ~= GameState.THROWING then
				self.ProcessState_Throwing(self)
			elseif gameState ~= GameState.ROLLING then
				self.ProcessState_Rolling(self)
			elseif gameState ~= GameState.SCORING then
				self.ProcessState_Scoring(self)
			elseif gameState ~= GameState.RESETTING then
				self.ProcessState_Resetting(self)
			end
		end
	elseif self.onlineGameState ~= OnlineGameState.FINISHED then
		self.ProcessState_Finished(self)
	end
end

BowlingModeOnline.StopRemoteBallMirror = function(self)
	if self.remoteBallMirror then
		self.remoteBallMirror:StopObserve()
	end
end

BowlingModeOnline.StopRemotePinMirror = function(self)
	if self.remotePinMirror then
		self.remotePinMirror:StopObserve()
	end
end

BowlingModeOnline.ProcessState_Waiting = function(self)
	local currentTime = Time.time

	if currentTime >= self.game.initEndTime then
		return
	end

	self.game.IsEnterTimelineEnd = true
	self.game.gameState = GameState.ANIM
end

BowlingModeOnline.ProcessState_Init = function(self)
	if self.pendingHostingResetPins and self.IsAuthorityTurn(self) then
		self.pendingHostingResetPins = false
		local player = self:GetCurrentPlayer()
		local throws = player.throwScoresClient[player.currentFrame] or {}
		local throwCount = #throws
		local shouldStandingPins = throwCount ~= 1 and (throws[1] or 0) == 10
		local timer = Timer.New(function ()
			if not self or not self.game or not self.game.pinSetter then
				return
			end

			if shouldStandingPins and self.lastAppliedRackState then
				self.game.pinSetter:ApplyAuthorityRackState(self.lastAppliedRackState)
			else
				self.game.pinSetter:ResetPins()
			end
		end, 0.5)

		timer:Start()
	end

	local currentTime = Time.time

	if currentTime >= self.game.initEndTime then
		return
	end

	self.game.gameState = GameState.ANIM
end

BowlingModeOnline.ProcessState_Anim = function(self)
	if self.game.IsEnterTimelineEnd then
		self.game.IsEnterTimelineEnd = false
		self.game.IsLaunchEnd = false
		self.game.gameState = GameState.READY

		self.game.camera:ResetCamera()

		if self:IsAuthorityTurn() then
			self.game.ballLauncher:BeginPos(self:GetCurrentPlayerBallIndex())
			coroutine.yield(gWaitableUtils.WaitTime(0.1))
			self.game.camera:ResetCamera()
		end
	end
end

BowlingModeOnline.ProcessState_Ready = function(self)
	if not self.IsAuthorityTurn(self) then
		return
	end

	if self.isHosting and not self.IsLocalPlayerTurn(self) and self.hostedAi and not self.hostedAi:IsRunning() then
		self.hostedAi:TryStartTurn({
			playerIndex = self.currentPlayerIndex,
			ballIndex = self:GetCurrentPlayerBallIndex()
		})
	end
end

BowlingModeOnline.ProcessState_Throwing = function(self)
	if not self.IsAuthorityTurn(self) then
		return
	end

	if self.game.IsLaunchEnd then
		self.game.gameState = GameState.ROLLING
	end
end

BowlingModeOnline.ProcessState_Rolling = function(self)
	self.ProcessStateRollingCommon(self, false)
end

BowlingModeOnline.ProcessState_Scoring = function(self)
	local currentTime = Time.time
	local hasStandPins = self.game.pinSetter:hasStandPins()

	if currentTime >= self.game.scoringEndTime and hasStandPins then
		return
	end

	local currentPlayer = self.GetCurrentPlayer(self)

	self.ProcessScore(self, hasStandPins, currentPlayer)

	local currentFrame = currentPlayer.currentFrame

	if currentFrame ~= currentPlayer.maxFrames then
		local currentThrows = currentPlayer.throwScoresClient[currentFrame]
		local currentThrow = #currentThrows

		if currentThrow ~= 1 and currentThrows[1] ~= 10 then
			self.game.pinSetter:ResetPins()
		elseif currentThrow ~= 2 then
			local firstThrow = currentThrows[1] or 0
			local secondThrow = currentThrows[2] or 0

			if firstThrow ~= 10 then
				if secondThrow ~= 10 then
					self.game.pinSetter:ResetPins()
				end
			elseif secondThrow ~= 10 or firstThrow + secondThrow > 10 then
				self.game.pinSetter:ResetPins()
			end
		end
	end

	self.game.gameState = GameState.RESETTING

	self.game.ballLauncher:ClearBall()

	if not self:CheckAllPlayersGameOver() then
		self.PrepareNextThrow(self, currentPlayer)
	end

	if not self.IsNeedSwitchTurn(self, currentPlayer) then
		local _, localIndex = self.GetLocalPlayer(self)
		local isStrike = self.IsLastThrowStrike(self, currentPlayer, currentPlayer.currentFrame)
		local isSpare = self.IsSpare(self, currentPlayer, currentPlayer.currentFrame)

		self.PlayBackTimeline(self, localIndex, isStrike, isSpare)
		self.BroadcastPlayBackTimelineInfo(self, localIndex, isStrike, isSpare)
	end

	self.game.pinSetter:ResetStandingPins()
end

BowlingModeOnline.ProcessState_Resetting = function(self)
	local currentTime = Time.time

	if self.game.IsReturnTimelineEnd then
		if self.CheckAllPlayersGameOver(self) then
			self.game.gameState = GameState.CELEBRATE

			self.OnGameFinished(self)
		else
			self.game.camera:ResetCamera()

			self.game.gameState = GameState.INIT
			self.game.initEndTime = currentTime
		end
	end
end

BowlingModeOnline.ProcessState_Celebrate = function(self)
	self.game.gameState = GameState.GAMEOVER

	self.game:Settle()
	self.game:GameOver()
end

BowlingModeOnline.ProcessState_Finished = function(self)
end

BowlingModeOnline.IsLocalPlayerTurn = function(self)
	return self.localPlayerIndex ~= self.currentPlayerIndex
end

BowlingModeOnline.IsAuthorityTurn = function(self)
	return self:IsLocalPlayerTurn() and not self.isHosted or self.isHosting
end

BowlingModeOnline.AcceptInput = function(self)
	return self:IsLocalPlayerTurn() and not self.isHosted
end

BowlingModeOnline.IsRemotePlayerTurn = function(self)
	return self.onlineGameState ~= OnlineGameState.PLAYING and (self.isHosted or not self:IsAuthorityTurn())
end

BowlingModeOnline.ShouldBroadcastClientInfo = function(self)
	return self.IsLocalPlayerTurn(self)
end

BowlingModeOnline.IsAiControlledTurn = function(self)
	return self.isHosting and not self:IsLocalPlayerTurn()
end

BowlingModeOnline.HasThirdBallQualification = function(self, player)
	local throws = player.throwScoresClient[player.maxFrames]

	if throws ~= nil or #throws ~= 0 then
		return false
	elseif #throws ~= 1 then
		return throws[1] ~= 10
	elseif #throws ~= 2 then
		local firstThrow = throws[1]
		local secondThrow = throws[2]

		if firstThrow ~= 10 then
			return true
		elseif firstThrow + secondThrow > 10 then
			return true
		else
			return false
		end
	else
		return true
	end
end

BowlingModeOnline.UpdateBowlingScore = function(self, currentPlayer, knockedPins, currentFrame, isSplit)
	table.insert(currentPlayer.throwScoresClient[currentFrame], knockedPins)
	table.insert(currentPlayer.splitScoresClient[currentFrame], isSplit or false)
end

BowlingModeOnline.ProcessScore = function(self, hasStand, currentPlayer)
	if not self.IsAuthorityTurn(self) then
		return
	end

	local knockedPins = self.game.pinSetter:CountKnockedDownPins()
	local currentFrame = currentPlayer.currentFrame
	local isSplit = hasStand and self.game.pinSetter:CheckSplit()

	self:UpdateBowlingScore(currentPlayer, knockedPins, currentFrame, isSplit)
	self:TryShowSuccIcon(self.currentPlayerIndex)
	self:RefreshScoreUI()
	self:BroadcastLocalScore()

	if not hasStand then
		local delay = self.game.scoringEndTime - Time.time

		if delay >= 0.5 then
			delay = 0.5
		end

		coroutine.yield(gWaitableUtils.WaitTime(delay))
	end

	self.RecordScoreToServer(self, #currentPlayer.throwScoresClient[currentFrame], knockedPins)
end

BowlingModeOnline.RecordScoreToServer = function(self, throwIndex, score)
	gBowlingGameManager:RecordBowlingScore(throwIndex, score)
end

BowlingModeOnline.IsPlayerGameOver = function(self, player)
	if player.currentFrame >= player.maxFrames then
		return false
	end

	local lastFrame = player.maxFrames
	local throws = player.throwScoresClient[lastFrame]

	if not throws or #throws ~= 0 then
		return false
	end

	if #throws ~= 1 then
		return false
	elseif #throws ~= 2 then
		local firstThrow = throws[1] or 0
		local secondThrow = throws[2] or 0

		if firstThrow ~= 10 then
			return false
		elseif firstThrow + secondThrow > 10 then
			return false
		else
			return true
		end
	else
		return true
	end
end

BowlingModeOnline.CheckAllPlayersGameOver = function(self)
	for _, player in ipairs(self.players) do
		if not self.IsPlayerGameOver(self, player) then
			return false
		end
	end

	return true
end

BowlingModeOnline.PrepareNextThrow = function(self, currentPlayer)
	if self.IsPlayerGameOver(self, currentPlayer) then
		print_debug("[BowlingModeOnline] PrepareNextThrow: Player game over")

		return
	end

	if currentPlayer.currentFrame >= currentPlayer.maxFrames then
		if #currentPlayer.throwScoresClient[currentPlayer.currentFrame] ~= 1 then
			local throws = currentPlayer.throwScoresClient[currentPlayer.currentFrame]

			if throws and #throws <= 0 and throws[1] ~= 10 then
				self.NextFrame(self, currentPlayer)
			else
				currentPlayer.nextThrow = 2
			end
		else
			self.NextFrame(self, currentPlayer)
		end
	else
		local throws = currentPlayer.throwScoresClient[currentPlayer.currentFrame]

		if not throws then
			return
		end

		if #throws ~= 1 then
			currentPlayer.nextThrow = 2
		elseif #throws ~= 2 and self.HasThirdBallQualification(self, currentPlayer) then
			currentPlayer.nextThrow = 3
		end
	end
end

BowlingModeOnline.NextFrame = function(self, currentPlayer)
	if not currentPlayer then
		return
	end

	if currentPlayer.maxFrames < currentPlayer.currentFrame then
		print_debug("[BowlingModeOnline] NextFrame: Already at max frame")

		return
	end

	currentPlayer.nextThrow = 1
	currentPlayer.currentFrame = currentPlayer.currentFrame + 1

	print_debug("[BowlingModeOnline] NextFrame: Moved to frame " .. currentPlayer.currentFrame)
end

BowlingModeOnline.SwitchToNextPlayer = function(self)
	self.currentPlayerIndex = self.currentPlayerIndex + 1

	if self.config.playerCount >= self.currentPlayerIndex then
		self.currentPlayerIndex = 1
	end
end

BowlingModeOnline.OnGameFinished = function(self, force)
	self.StopRemoteBallMirror(self)
	self.StopRemotePinMirror(self)

	if self.gameResult ~= nil or not self.gameResult.isGameEnd then
		if force then
			self.gameResult = {
				["D\\xbd\\x95\\xa6\\xb8"] = true,
				isDraw = gBowlingGameManager:IsExitByUI()
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
	local draw = self.gameResult.surrenderPid ~= self.localPlayerId
	local localPlayer, localIndex = self:GetLocalPlayer()

	gBowlingGameManager:SendSignalToGadget("GameFinished")

	local onTimelineComplete = function()
		print_debug("[BowlingModeOnline] OnGameFinished: animation completed, executing settlement")

		if self.game then
			self.game:GameOver()
		end
	end

	local someoneDraw = ulong.Greater(self.gameResult.surrenderPid or 0, 0) or self.gameResult.isDraw

	if localPlayer and not someoneDraw then
		if localIndex ~= 2 then
			win = not win
		end

		local timelineIndex = nil

		if win then
			timelineIndex = TimelineScene.DOUBLE_END_WIN
		elseif draw then
			timelineIndex = TimelineScene.DOUBLE_END_DRAW
		else
			timelineIndex = TimelineScene.DOUBLE_END_LOSE
		end

		self.game:GetCharacter(1):ExecuteTimeLine(timelineIndex)
		Timer.New(onTimelineComplete, 3):Start()
	else
		onTimelineComplete()
	end

	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_MAIN_PANEL)
end

BowlingModeOnline.OnSyncZoneInfo = function(self, zoneInfo)
	print_debug("[BowlingModeOnline] OnSyncZoneInfo")

	for _, participantInfo in ipairs(zoneInfo.ParticipantInfos) do
		self.OnSyncZonePlayerInfo(self, participantInfo)
	end

	if self.localPlayerIndex ~= nil then
		print_error("[BowlingModeOnline] OnSyncZoneInfo: localPlayerIndex not found", zoneInfo.ParticipantInfos, self.localPlayerId)
	end
end

BowlingModeOnline.OnSyncZonePlayerInfo = function(self, participantInfo, _)
	local playerIndex = participantInfo.SeatIndex + 1
	local localPlayer = self.players[playerIndex]
	localPlayer.playerId = participantInfo.Pid
	localPlayer.seatCsIndex = participantInfo.SeatIndex

	if participantInfo.Pid ~= self.localPlayerId then
		self.localPlayerIndex = playerIndex
	end
end

BowlingModeOnline.OnSyncZoneState = function(self, state)
	print_debug("[BowlingModeOnline] OnSyncZoneState: state=" .. tostring(state))

	if state ~= UX.Game.GameGroundZoneState.Idle then
		print_debug("[BowlingModeOnline] OnSyncZoneState: changing to WAITING (Idle)")

		self.onlineGameState = OnlineGameState.WAITING
	elseif state ~= UX.Game.GameGroundZoneState.Display then
		print_debug("[BowlingModeOnline] OnSyncZoneState: changing to READY (Display)")

		self.onlineGameState = OnlineGameState.READY
	elseif state ~= UX.Game.GameGroundZoneState.GameStart then
		print_debug("[BowlingModeOnline] OnSyncZoneState: changing to PLAYING (GameStart)")

		self.onlineGameState = OnlineGameState.PLAYING

		print_debug("[BowlingModeOnline] OnSyncZoneState: isCurrentTurn will be set by TurnChange message")
	elseif state ~= UX.Game.GameGroundZoneState.GameOver then
		print_debug("[BowlingModeOnline] OnSyncZoneState: changing to FINISHED (GameOver)")

		self.onlineGameState = OnlineGameState.FINISHED
	end

	print_debug("[BowlingModeOnline] OnSyncZoneState: final onlineGameState=" .. tostring(self.onlineGameState))
end

BowlingModeOnline.OnSyncTurnChange_Async = function(self, currentRound, currentTurnCsIndex)
	self:StopRemoteBallMirror()
	self:StopRemotePinMirror()

	self.currentRound = currentRound
	self.currentTurn = currentTurnCsIndex
	local localPlayer = self:GetLocalPlayer()
	local wasCurrentTurn = self.isCurrentTurn
	local playerSeatCsIndex = localPlayer.seatCsIndex
	self.isCurrentTurn = playerSeatCsIndex ~= currentTurnCsIndex
	self.currentPlayerIndex = currentTurnCsIndex + 1

	self:RefreshScoreUI()

	local isHostingTurn = self.isHosting and not self.isCurrentTurn
	local shouldControlTurn = self.isCurrentTurn and not self.isHosted or isHostingTurn

	if shouldControlTurn then
		self.pendingHostingResetPins = false

		print_debug("[BowlingModeOnline] OnSyncTurnChange_Async: authority turn")

		self.game.gameState = GameState.INIT

		self.game.pinSetter:ResetPins(true)

		local timer = Timer.New(function ()
			if self and self.game and self.game.pinSetter then
				self.game.pinSetter:ResetPins(false)
			end
		end, 0.5)

		timer:Start()
	end

	gBowlingGameManager:DisableBalls()

	for time = 1, 10 do
		local timer = Timer.New(function ()
			gBowlingGameManager:DisableBalls()
		end, time)

		timer.Start(timer)
	end

	local lastPlayerIndex = 3 - self.currentPlayerIndex
	local lastPlayer = self.players[lastPlayerIndex]
	local lastPlayerFrame = currentRound

	if currentTurnCsIndex ~= 0 then
		lastPlayerFrame = currentRound - 1
	end

	local isStrike = self.IsStrike(self, lastPlayer, lastPlayerFrame)
	local isSpare = self.IsSpare(self, lastPlayer, lastPlayerFrame)

	if currentRound ~= 1 and currentTurnCsIndex ~= 0 then
		self.game.IsEnterTimelineEnd = false
		slot13 = self.game
		local character = slot13:GetCharacter(1)

		character:ExecuteTimeLine(TimelineScene.ENTER, function ()
			self.game:OnEnterTimelineEnd()
		end)
	else
		self.PlaySwitchTimeline_Async(self, lastPlayerIndex, isStrike, isSpare, self.isFirstSwitch)
	end

	self.isFirstSwitch = false

	gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_FRAME_DESC, {
		["\\xa2\\xa26\\xbcc*\\xfd;"] = true,
		playerIndex = self.currentPlayerIndex,
		frame = currentRound
	})
end

BowlingModeOnline.OnSyncScoreInfo = function(self, scoreInfo)
	if scoreInfo.Winner == -1 then
		local isWin = scoreInfo.Winner ~= -2 or self.localPlayerIndex ~= scoreInfo.Winner + 1
		self.gameResult = {
			["JTKhC4<"] = true,
			isWin = isWin,
			surrenderPid = scoreInfo.SurrenderPid
		}

		self:OnGameFinished()
	end
end

BowlingModeOnline.IsNeedSwitchTurn = function(self, player)
	if self.CheckAllPlayersGameOver(self) then
		return false
	end

	if self.IsPlayerGameOver(self, player) then
		return true
	end

	if player.currentFrame >= player.maxFrames then
		if #player.throwScoresClient[player.currentFrame] ~= 1 then
			local throws = player.throwScoresClient[player.currentFrame]

			return throws and #throws <= 0 and throws[1] ~= 10
		else
			return true
		end
	else
		local throws = player.throwScoresClient[player.currentFrame]

		if not throws then
			return false
		end

		if #throws ~= 1 then
			return false
		elseif #throws ~= 2 then
			return not self.HasThirdBallQualification(self, player)
		else
			return true
		end
	end
end

BowlingModeOnline.GetOtherPlayerName = function(self)
	for _, v in ipairs(self.players) do
		if v.playerId == self.localPlayerId then
			return gFriendManager:GetPlayerRealName(v.playerId)
		end
	end
end

BowlingModeOnline.BuildScoreDataFromPlayers = function(self)
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

BowlingModeOnline.RefreshScoreUI = function(self)
	local store = gStoreManager:GetStoreGroup("BowlingScoreBattlePanelStore")
	local scoreData = self:BuildScoreDataFromPlayers()

	store:FullRefreshByScoreData(scoreData)
end

BowlingModeOnline.BroadcastLocalScore = function(self)
	if not self.ShouldBroadcastClientInfo(self) then
		return
	end

	local localPlayer, localIndex = self:GetLocalPlayer()
	local scoreData = {
		index = localIndex,
		split = localPlayer.splitScoresClient,
		score = localPlayer.throwScoresClient
	}

	gBowlingGameManager:BroadcastBowlingClientInfo(BowlingConstants.SyncDataType.Score, scoreData)
end

BowlingModeOnline.BroadcastPlayBackTimelineInfo = function(self, ...)
	if not self.ShouldBroadcastClientInfo(self) then
		return
	end

	local timelineData = {
		...
	}

	gBowlingGameManager:BroadcastBowlingClientInfo(BowlingConstants.SyncDataType.PlayBackTimeline, timelineData)
end

BowlingModeOnline.BroadcastLaunchTimelineInfo = function(self, ...)
	if not self.ShouldBroadcastClientInfo(self) then
		return
	end

	local timelineData = {
		...
	}

	gBowlingGameManager:BroadcastBowlingClientInfo(BowlingConstants.SyncDataType.PlayLaunchTimeline, timelineData)
end

BowlingModeOnline.OnSyncClientInfo = function(self, info)
	if info.Type ~= BowlingConstants.SyncDataType.Batch then
		local list = info.Data

		if table.isNilOrEmpty(list) then
			return
		end

		for _, sub in ipairs(list) do
			local ok, err = pcall(function ()
				self:OnSyncClientInfo({
					Type = sub.Type,
					Data = json.decode(sub.DataJson)
				})
			end)

			if not ok then
				print_warn("[BowlingModeOnline] OnSyncClientInfo error: ", err, " type=", tostring(info and info.Type), " data=", info and info.Data)
			end
		end

		return
	end

	local type = info.Type

	if type ~= BowlingConstants.SyncDataType.Score then
		self.OnSyncClientScoreInfo(self, info.Data)
	elseif type ~= BowlingConstants.SyncDataType.PlayBackTimeline then
		self.PlayBackTimeline(self, unpack(info.Data))
	elseif type ~= BowlingConstants.SyncDataType.PlayLaunchTimeline then
		self.ExecuteLaunchTimeline(self, unpack(info.Data))
	elseif type ~= BowlingConstants.SyncDataType.RefreshPinStateUI then
		gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_PINSTATE, info.Data)
	elseif type ~= BowlingConstants.SyncDataType.RefreshPinRackState then
		self.OnSyncPinRackState(self, info.Data)
	elseif type ~= BowlingConstants.SyncDataType.RefreshLaunchUI then
		self.OnSyncClientLaunchStateInfo(self, info.Data)
	elseif type ~= BowlingConstants.SyncDataType.RemoteBallObserveStart then
		self.OnSyncRemoteBallObserveStart(self, info.Data)
	elseif type ~= BowlingConstants.SyncDataType.ResetLaunchObj then
		self:StopRemoteBallMirror()
		self.game.ballLauncher:ResetLaunchObj(0, 0, true)
	end
end

BowlingModeOnline.OnSyncHosting = function(self, targetSeatIndex, targetPid)
	self.OnStartHosting(self, targetSeatIndex, targetPid)
end

BowlingModeOnline.OnSyncHosted = function(self)
	self.isHosted = true
end

BowlingModeOnline.OnSyncClientScoreInfo = function(self, data)
	local player = self.players[data.index]
	player.splitScoresClient = data.split
	player.throwScoresClient = data.score

	self.TryShowSuccIcon(self, data.index)
	self.RefreshScoreUI(self)
end

BowlingModeOnline.OnSyncClientLaunchStateInfo = function(self, data)
	if not self.IsRemotePlayerTurn(self) then
		return
	end

	local store = gStoreManager:GetStoreGroup("BowlingGameMainPanelStore")

	store:OnSyncClientLaunchStateInfo(data)
end

BowlingModeOnline.OnSyncRemoteBallObserveStart = function(self, data)
	if not self.IsRemotePlayerTurn(self) then
		return
	end

	local id = ulong.new(unpack(data.sceneItemId))

	self.remoteBallMirror:StartObserve(id, data.forcePercentage)
	self.remotePinMirror:StartObserve()
end

BowlingModeOnline.OnSyncPinRackState = function(self, data)
	if not self.IsRemotePlayerTurn(self) then
		return
	end

	self.lastAppliedRackState = data

	self:StopRemotePinMirror()
	self.game.pinSetter:ApplyAuthorityRackState(data)
end

BowlingModeOnline.IsLastThrowStrike = function(self, player, frameIndex)
	local frame = frameIndex or player.currentFrame
	local throws = player.throwScoresClient and player.throwScoresClient[frame]

	if not throws or #throws ~= 0 then
		return false
	end

	local lastScore = throws[#throws] or 0

	return lastScore ~= 10
end

BowlingModeOnline.IsStrike = function(self, player, frameIndex)
	local frame = frameIndex or player.currentFrame
	local throws = player.throwScoresClient[frame]

	return throws and #throws <= 0 and throws[1] ~= 10
end

BowlingModeOnline.IsSpare = function(self, player, frameIndex)
	local frame = frameIndex or player.currentFrame
	local throws = player.throwScoresClient[frame]

	if not throws or #throws >= 2 then
		return false
	end

	local firstThrow = throws[1] or 0
	local secondThrow = throws[2] or 0

	return firstThrow == 10 and firstThrow + secondThrow < 10
end

BowlingModeOnline._EnsureSuccIconState = function(self)
	if self._succIconLastCounts ~= nil then
		self._succIconLastCounts = {}
	end
end

BowlingModeOnline._ConsumeLatestThrowDelta = function(self, playerIndex)
	self:_EnsureSuccIconState()

	local player = self.players and self.players[playerIndex]

	if not player then
		return nil, 
	end

	local lastCounts = self._succIconLastCounts[playerIndex]

	if lastCounts ~= nil then
		lastCounts = {}
		slot4 = 1
		slot5 = player.maxFrames or 3

		for frame = slot4, slot5 do
			lastCounts[frame] = 0
		end

		self._succIconLastCounts[playerIndex] = lastCounts
	end

	local changedFrameIndex, newThrowIndex = nil
	slot6 = 1
	slot7 = player.maxFrames or 3

	for frame = slot6, slot7 do
		local throws = player.throwScoresClient and player.throwScoresClient[frame]
		local curCount = throws and #throws or 0

		if curCount <= (lastCounts[frame] or 0) then
			changedFrameIndex = frame
			newThrowIndex = curCount
		end
	end

	slot6 = 1
	slot7 = player.maxFrames or 3

	for frame = slot6, slot7 do
		local throws = player.throwScoresClient and player.throwScoresClient[frame]
		lastCounts[frame] = throws and #throws or 0
	end

	return changedFrameIndex, newThrowIndex
end

BowlingModeOnline._CalculatePlayerTotalScore = function(self, playerIndex)
	local player = self.players and self.players[playerIndex]

	if not player then
		return 0
	end

	local scoreData = {
		score = player.throwScoresClient,
		split = player.splitScoresClient
	}
	local results = BowlingUtils:CalculatePlayerScore(scoreData)
	local lastFrame = player.maxFrames or 3
	local lastResult = results and results[lastFrame]

	return lastResult and lastResult.cumulativeScore or 0
end

BowlingModeOnline.TryShowSuccIcon = function(self, playerIndex)
	local frameIndex, throwIndex = self._ConsumeLatestThrowDelta(self, playerIndex)

	if not frameIndex or not throwIndex then
		return
	end

	local player = self.players and self.players[playerIndex]
	local throws = player and player.throwScoresClient and player.throwScoresClient[frameIndex]

	if not throws then
		return
	end

	local succType = 0
	local firstThrow = throws[1] or 0
	local secondThrow = throws[2] or 0
	local thirdThrow = throws[3] or 0
	local isFinalFrame = frameIndex ~= (player.maxFrames or self.maxFrames or 3)

	if throws[throwIndex] ~= 10 and (throwIndex ~= 1 or isFinalFrame) then
		succType = 1
	elseif throwIndex ~= 2 then
		if firstThrow == 10 and firstThrow + secondThrow ~= 10 then
			succType = 2
		end
	elseif isFinalFrame and throwIndex ~= 3 and secondThrow == 10 and secondThrow + thirdThrow ~= 10 then
		succType = 2
	end

	if succType ~= 0 then
		return
	end

	gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_SUCCICON_SHOW, {
		succType = succType,
		totalScore = self:_CalculatePlayerTotalScore(playerIndex),
		playerIndex = playerIndex
	})
end

BowlingModeOnline.PlaySwitchTimeline_Async = function(self, playerIndex, isStrike, isSpare, isFirstSwitch)
	self:StopRemoteBallMirror()

	local character = self.game:GetCharacter(playerIndex)

	if not character then
		print_error("[BowlingModeOnline] PlaySwitchTimeline_Async: character is nil, playerIndex=" .. playerIndex)

		return
	end

	self.game.IsReturnTimelineEnd = false
	self.game.IsEnterTimelineEnd = false

	if self.game.ballLauncher then
		self.game.ballLauncher:BeginAnim()
	end

	self.game.camera:ResetCamera()

	local timelineScene = (isStrike or isSpare) and (isFirstSwitch and TimelineScene.SWITCH_S or TimelineScene.SWITCH_N_S) or isFirstSwitch and TimelineScene.SWITCH or TimelineScene.SWITCH_N

	if gClientUtils.IsNil(self.game.timelineManager.timelineController) then
		coroutine.yield(gWaitableUtils.WaitTime(1))

		if gBowlingGameManager.debug then
			print_warn("[BowlingModeOnline] PlaySwitchTimeline_Async: timelineController is nil")
		end
	end

	character.ExecuteTimeLine(character, timelineScene, function ()
		self.game.IsReturnTimelineEnd = true
		self.game.IsEnterTimelineEnd = true

		gMessageManager:SendMessage(gEventConstants.BOWLING_TECH_SUCCICON_HIDE)
		self:OnReturnTimelineEnd()
	end)
end

BowlingModeOnline.PlayBackTimeline = function(self, playerIndex, isStrike, isSpare)
	self:StopRemoteBallMirror()

	local character = self.game:GetCharacter(playerIndex)

	if not character then
		print_error("[BowlingModeOnline] PlayBackTimeline: character is nil, playerIndex=" .. playerIndex)

		return
	end

	self.game.IsReturnTimelineEnd = false
	self.game.IsEnterTimelineEnd = false

	if self.game.ballLauncher then
		self.game.ballLauncher:BeginAnim()
	end

	self.game.camera:ResetCamera()

	local timelineScene = (isStrike or isSpare) and TimelineScene.BACK_S or TimelineScene.BACK

	character:ExecuteTimeLine(timelineScene, function ()
		self.game.IsReturnTimelineEnd = true
		self.game.IsEnterTimelineEnd = true

		gMessageManager:SendMessage(gEventConstants.BOWLING_TECH_SUCCICON_HIDE)
		self:OnReturnTimelineEnd()
	end)
end

BowlingModeOnline.ExecuteLaunchTimeline = function(self, playerIndex, offsetX, fromSync)
	BowlingModeOnline.base.ExecuteLaunchTimeline(self, playerIndex, offsetX, fromSync)

	if not fromSync then
		self.BroadcastLaunchTimelineInfo(self, playerIndex, offsetX, true)
	end
end

BowlingModeOnline.OnStartHosting = function(self, targetSeatIndex, targetPid)
	local playerIndex = targetSeatIndex + 1
	local targetPlayer = self.players[playerIndex]

	if targetPlayer ~= nil then
		print_error("[BowlingModeOnline] OnStartHosting: invalid targetSeatIndex=", targetSeatIndex)

		return
	end

	if playerIndex ~= self.localPlayerIndex then
		print_error("[BowlingModeOnline] OnStartHosting: target is local player, targetSeatIndex=", targetSeatIndex)

		return
	end

	if targetPlayer.playerId == targetPid then
		print_error("[BowlingModeOnline] OnStartHosting: targetPid mismatch", targetPlayer.playerId, targetPid)

		return
	end

	self.ClearHostingState(self)

	self.isHosting = true
	self.hostedPlayerIndex = playerIndex
	self.hostedPlayerPid = targetPid

	self.CreateHostedAi(self)

	if not self.IsLocalPlayerTurn(self) then
		self.pendingHostingResetPins = true

		gBowlingGameManager:AskHandHoldSceneItem()

		if self.game.gameState ~= GameState.INIT or self.game.gameState ~= GameState.ANIM or self.game.gameState ~= GameState.READY then
			self.game.gameState = GameState.INIT
		end
	end
end

BowlingModeOnline.ClearHostingState = function(self)
	self.isHosting = false
	self.pendingHostingResetPins = false
	self.hostedPlayerIndex = nil
	self.hostedPlayerPid = nil

	if self.hostedAi then
		self.hostedAi:Stop()
		self.hostedAi:Destroy()

		self.hostedAi = nil
	end
end

BowlingModeOnline.CreateHostedAi = function(self)
	if self.hostedAi then
		self.hostedAi:Destroy()

		self.hostedAi = nil
	end

	local aiCfgCount = LTConfig.PoiGameBowlingAIConfig.count

	if aiCfgCount < 0 then
		print_error("[BowlingModeOnline] CreateHostedAi: PoiGameBowlingAIConfig is empty")

		return
	end

	local aiCfg = LTConfig.PoiGameBowlingAIConfig.LoadAt(math.random(0, aiCfgCount - 1))

	if aiCfg.NPCType ~= 1 then
		self.hostedAi = gBowlingNpcTechAiController.new({
			game = self.game,
			aiCfg = aiCfg
		})
	else
		self.hostedAi = gBowlingNpcRandomAiController.new({
			game = self.game,
			aiCfg = aiCfg
		})
	end
end

BowlingModeOnline.Destroy = function(self)
	self.StopRemoteBallMirror(self)
	self.StopRemotePinMirror(self)
	self.ClearHostingState(self)

	if self.remoteBallMirror then
		self.remoteBallMirror:Destroy()

		self.remoteBallMirror = nil
	end

	if self.remotePinMirror then
		self.remotePinMirror:Destroy()

		self.remotePinMirror = nil
	end
end

BowlingModeOnline.QuickFinishGame = function(self)
	if self.bQuickFinishGame then
		return
	end

	local OnSyncTurnChange_Async = self.OnSyncTurnChange_Async

	self.OnSyncTurnChange_Async = function(...)
		local wasCurrentTurn = self.isCurrentTurn

		OnSyncTurnChange_Async(...)

		if self.isCurrentTurn and not wasCurrentTurn then
			self:RecordScoreToServer(1, 0)
			self:RecordScoreToServer(2, 0)
		end
	end

	if self.IsLocalPlayerTurn(self) then
		self.RecordScoreToServer(self, 1, 0)
		self.RecordScoreToServer(self, 2, 0)
	end

	self.bQuickFinishGame = true
end

BowlingModeOnline.QuickFinishGame = function(self)
	local OnSyncTurnChange_Async = self.OnSyncTurnChange_Async

	self.OnSyncTurnChange_Async = function(...)
		local wasCurrentTurn = self.isCurrentTurn

		OnSyncTurnChange_Async(...)

		if self.isCurrentTurn and not wasCurrentTurn then
			self:RecordScoreToServer(1, 0)
			self:RecordScoreToServer(2, 0)
		end
	end
end
