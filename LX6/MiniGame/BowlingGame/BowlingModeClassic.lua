-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingModeClassic.lua
-- Decompiled from: 00650_BowlingModeClassic.lua_ae14267c9183.luajit

gBowlingModeClassic = DefClass("BowlingModeClassic", gBowlingModeClassic, gBowlingModeBase)
local BowlingModeClassic = gBowlingModeClassic
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local GameState = BowlingConstants.GameState
local GameMode = BowlingConstants.GameMode
local TimelineScene = BowlingConstants.TimelineScene
local BConfig = require("LX6/MiniGame/BowlingGame/BowlingConfig")

require("LX6/MiniGame/BowlingGame/BowlingNpcRandomAiController")
require("LX6/MiniGame/BowlingGame/BowlingNpcTechAiController")

BowlingModeClassic.ResolveNpcAiCfg = function(self, fightSpiritId)
	for i = 0, LTConfig.PoiGameBowlingAIConfig.count - 1 do
		if LTConfig.PoiGameBowlingAIConfig.GetConfigValueByIndex(i, "FightSpiritID") ~= fightSpiritId then
			return LTConfig.PoiGameBowlingAIConfig.LoadAt(i)
		end
	end

	return nil
end

BowlingModeClassic.InitData = function(self)
	BowlingModeClassic.base.InitData(self)
	self:InitPlayers()

	self.maxFrames = self.config.maxFrames or 10
	self.currentFrame = 1

	if self.game.args.npcFightSpiritId <= 0 then
		local npcFightSpiritId = self.game.args.npcFightSpiritId
		local aiCfg = self.ResolveNpcAiCfg(self, npcFightSpiritId)

		if aiCfg ~= nil then
			aiCfg = LTConfig.PoiGameBowlingAIConfig.LoadAt(0)

			print_error("找不到指定的AI配置，请策划检查！FightSpiritId=", npcFightSpiritId)
		end

		self.npcAi = self.CreateNpcAi(self, aiCfg)
	elseif gBowlingGameManager:IsInOnlineDoubleAiGame() then
		local randomAiCfg = LTConfig.PoiGameBowlingAIConfig.LoadAt(math.random(0, LTConfig.PoiGameBowlingAIConfig.count - 1))
		self.npcAi = self.CreateNpcAi(self, randomAiCfg)
	end
end

BowlingModeClassic.CreateNpcAi = function(self, aiCfg)
	if aiCfg.NPCType ~= 1 then
		return gBowlingNpcTechAiController.new({
			game = self.game,
			aiCfg = aiCfg
		})
	else
		return gBowlingNpcRandomAiController.new({
			game = self.game,
			aiCfg = aiCfg
		})
	end
end

BowlingModeClassic.InitPlayers = function(self)
	self.currentPlayerIndex = 1
	self.players = {}
	self.isFirstSwitch = true

	for i = 1, self.config.playerCount do
		self.players[i] = {
			["\\x94:/<s\\x98E\\xe9>\\xa4\\xaa"] = 0,
			["lc\\xbeeI\\xbc\\xe6sbhq["] = 1,
			["\\xbc;51l\\xb8Y\\xfb6\\xa6\\xb5"] = 0,
			["(\\x95\\xfb\\xa2\\xa8\\xfd\\xb5\\x9c\\x9a\\xdc\\xef7\\xf5\\x99/\\x8d\\xe7"] = 0,
			["\\xd0\\xc827\\xe5"] = true,
			["\\xd0\\xc8'\r-\\xe5"] = false,
			["GUڼ\\x88;\\xbb\\xdb\\xed"] = 0,
			["lc\\xbeeI\\xbc\\xe6ax{sI"] = 1,
			["\\xd0\\xc8'\r6\\xf4"] = false,
			["ZI鼉\r\\x97\\xcc\\xfa"] = false,
			["\\xa2\\xa26\\xbfx7\\xf56"] = false,
			maxFrames = self.config.maxFrames or 3,
			frameScores = {},
			frameSpare = {},
			frameCompleted = {},
			frameBonus = {},
			knockedPinsHistory = {},
			isNPC = i == 1,
			curBallIndex = math.ceil(#BConfig.Launcher.prefabPaths.balls / 2)
		}
	end
end

BowlingModeClassic.GetCurrentPlayer = function(self)
	return self.players[self.currentPlayerIndex]
end

BowlingModeClassic.SetCurrentPlayerBallIndex = function(self, ballIndex)
	self.players[self.currentPlayerIndex].curBallIndex = ballIndex
end

BowlingModeClassic.GetCurrentPlayerBallIndex = function(self)
	return self.players[self.currentPlayerIndex].curBallIndex
end

BowlingModeClassic.IsLocalPlayerTurn = function(self)
	return self.currentPlayerIndex ~= 1
end

BowlingModeClassic.ProcessGameState = function(self)
	local gameState = self.game.gameState

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
	else
		print_error("Unknown game state: ", gameState)
	end
end

BowlingModeClassic.ProcessState_Init = function(self)
	local currentTime = Time.time

	if self.game.initEndTime < currentTime then
		if gBowlingGameManager:IsInOnlineDoubleAiGame() then
			gBowlingGameManager:AskHandHoldSceneItem()
		end

		self.game.IsEnterTimelineEnd = false

		if self.game.IsFirst and self.game:GetCurrentCharacter() then
			self.game.IsFirst = false

			self.game.pinSetter:ResetPins()
		end

		local currentPlayer = self.GetCurrentPlayer(self)

		if currentPlayer and currentPlayer.isFirst and self.currentPlayerIndex ~= 1 then
			currentPlayer.isFirst = false
			slot3 = self.game
			local currentCharacter = slot3:GetCurrentCharacter()

			currentCharacter:ExecuteTimeLine(TimelineScene.ENTER, function ()
				self.game:OnEnterTimelineEnd()
			end)
		else
			self.game.IsEnterTimelineEnd = true
		end

		self.game.gameState = GameState.ANIM
	end
end

BowlingModeClassic.ProcessState_Anim = function(self)
	if self.game.IsEnterTimelineEnd then
		self.game.IsLaunchEnd = false
		self.game.gameState = GameState.READY

		self.game.camera:ResetCamera()

		if self.game.ballLauncher then
			self.game.ballLauncher:BeginPos(self:GetCurrentPlayerBallIndex())
			coroutine.yield(gWaitableUtils.WaitTime(0.1))
			self.game.camera:ResetCamera()
			self:SendScoreArrow()
		end
	end
end

BowlingModeClassic.ProcessState_Ready = function(self)
	local currentPlayer = self.GetCurrentPlayer(self)

	if not currentPlayer or not currentPlayer.isNPC then
		return
	end

	if self.npcAi and not self.npcAi:IsRunning() then
		self.npcAi:TryStartTurn({
			playerIndex = self.currentPlayerIndex,
			ballIndex = self:GetCurrentPlayerBallIndex()
		})
	end
end

BowlingModeClassic.ProcessState_Throwing = function(self)
	if self.game.IsLaunchEnd then
		self.game.gameState = GameState.ROLLING
	end
end

BowlingModeClassic.ProcessState_Rolling = function(self)
	self.ProcessStateRollingCommon(self, false)
end

BowlingModeClassic.ProcessState_Scoring = function(self)
	local currentTime = Time.time
	local hasStand = self.game.pinSetter:hasStandPins()

	if self.game.scoringEndTime > currentTime or not hasStand then
		self.ProcessScore(self, hasStand)

		self.game.gameState = GameState.RESETTING

		if self.CheckSwitch(self) then
			self.game:PlayReturnTimeline(true)

			self.isFirstSwitch = false
		else
			self.game:PlayReturnTimeline(false)
		end

		self.game.ballLauncher:ClearBall()

		if not self:CheckAllPlayersGameOver() then
			self.PrepareNextThrow(self)
		end
	end
end

BowlingModeClassic.ProcessState_Resetting = function(self)
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

BowlingModeClassic.ProcessState_Celebrate = function(self)
	self.game.gameState = GameState.GAMEOVER

	self.game:Settle()
	self.game:GameOver()
end

BowlingModeClassic.ClosePanel = function(self)
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_MAIN_PANEL)
end

BowlingModeClassic.OnGameFinished = function(self, onlineGameDraw)
	self:ClosePanel()
	gBowlingGameManager:SendSignalToGadget("GameFinished")

	if onlineGameDraw then
		gBowlingGameManager:SendSignalToGadget("BowlingLoseNpc")
		self.game:GetCharacter(1):ExecuteTimeLine(TimelineScene.DOUBLE_END_LOSE)

		self.game.gameState = GameState.GAMEOVER

		self.game:GameOver()

		return
	end

	if self.config.playerCount < 1 then
		self.game:GetCharacter(1):ExecuteTimeLine(TimelineScene.SINGLE_END)
	elseif self.players[2].totalScore >= self.players[1].totalScore then
		gBowlingGameManager:SendSignalToGadget("BowlingWinNpc")
		self.game:GetCharacter(1):ExecuteTimeLine(TimelineScene.DOUBLE_END_WIN)
	elseif self.players[1].totalScore >= self.players[2].totalScore then
		gBowlingGameManager:SendSignalToGadget("BowlingLoseNpc")
		self.game:GetCharacter(1):ExecuteTimeLine(TimelineScene.DOUBLE_END_LOSE)
	else
		gBowlingGameManager:SendSignalToGadget("BowlingDraw")
		self.game:GetCharacter(1):ExecuteTimeLine(TimelineScene.DOUBLE_END_DRAW)
	end
end

BowlingModeClassic.ProcessScore = function(self, hasStand)
	local currentPlayer = self:GetCurrentPlayer()
	local knockedPins = self.game.pinSetter:CountKnockedDownPins()
	currentPlayer.knockedPins = knockedPins
	currentPlayer.isSplit = false

	if currentPlayer.currentThrow ~= 1 then
		local isSplit = self.game.pinSetter:CheckSplit()
		currentPlayer.isSplit = isSplit
	end

	if not currentPlayer.knockedPinsHistory[currentPlayer.currentFrame] then
		currentPlayer.knockedPinsHistory[currentPlayer.currentFrame] = {}
	end

	table.insert(currentPlayer.knockedPinsHistory[currentPlayer.currentFrame], knockedPins)

	if currentPlayer.CountExBall <= 0 then
		currentPlayer.CountExBall = currentPlayer.CountExBall - 1
	end

	for frame = 1, currentPlayer.currentFrame - 1 do
		if currentPlayer.frameBonus[frame] and currentPlayer.frameBonus[frame] <= 0 then
			if frame >= self.game.maxFrames then
				currentPlayer.frameScores[frame] = currentPlayer.frameScores[frame] + knockedPins
			end

			currentPlayer.frameBonus[frame] = currentPlayer.frameBonus[frame] - 1
		end
	end

	if currentPlayer.currentThrow ~= 1 then
		currentPlayer.frameSpare[currentPlayer.currentFrame] = 0
		currentPlayer.frameScores[currentPlayer.currentFrame] = knockedPins

		if knockedPins ~= 10 then
			currentPlayer.frameSpare[currentPlayer.currentFrame] = 1
			currentPlayer.isStrike = true
			currentPlayer.frameBonus[currentPlayer.currentFrame] = 2

			if currentPlayer.currentFrame ~= currentPlayer.maxFrames then
				currentPlayer.CountExBall = 2
			end
		end
	else
		local frameTotal = (currentPlayer.frameScores[currentPlayer.currentFrame] or 0) + knockedPins
		currentPlayer.frameScores[currentPlayer.currentFrame] = frameTotal

		if frameTotal ~= 10 then
			currentPlayer.frameSpare[currentPlayer.currentFrame] = 2
			currentPlayer.isSpare = true
			currentPlayer.frameBonus[currentPlayer.currentFrame] = 1

			if currentPlayer.currentFrame ~= currentPlayer.maxFrames then
				currentPlayer.CountExBall = 1
			end
		end
	end

	if currentPlayer.maxFrames >= currentPlayer.currentFrame then
		currentPlayer.isGameOver = currentPlayer.CountExBall > 0
	elseif currentPlayer.currentFrame ~= currentPlayer.maxFrames and currentPlayer.currentThrow > 2 then
		currentPlayer.isGameOver = currentPlayer.CountExBall > 0
	end

	currentPlayer.totalScore = 0

	for _, score in ipairs(currentPlayer.frameScores) do
		currentPlayer.totalScore = currentPlayer.totalScore + (score or 0)
	end

	for frame = 1, currentPlayer.currentFrame do
		if not currentPlayer.frameCompleted[frame] then
			if currentPlayer.isGameOver then
				currentPlayer.frameCompleted[frame] = true
			elseif frame >= currentPlayer.currentFrame and (not currentPlayer.frameBonus[frame] or currentPlayer.frameBonus[frame] < 0) then
				currentPlayer.frameCompleted[frame] = true
			elseif currentPlayer.currentFrame ~= frame and currentPlayer.currentThrow > 2 and currentPlayer.frameSpare[frame] ~= 0 then
				currentPlayer.frameCompleted[frame] = true
			end
		end
	end

	self.game:SendRefreshViewMessage()

	if gBowlingGameManager:IsInOnlineDoubleAiGame() then
		local throwIndex = #currentPlayer.knockedPinsHistory[currentPlayer.currentFrame]

		self.RecordScoreToServer(self, throwIndex, knockedPins)
	end

	if not hasStand then
		local delay = self.game.scoringEndTime - Time.time

		if delay >= 0.5 then
			delay = 0.5
		end

		coroutine.yield(gWaitableUtils.WaitTime(delay))
	end
end

BowlingModeClassic.CheckSwitch = function(self)
	local currentPlayer = self.GetCurrentPlayer(self)

	if self.CheckAllPlayersGameOver(self) then
		return false
	elseif currentPlayer.isGameOver then
		return true
	elseif currentPlayer.currentThrow ~= 1 then
		if currentPlayer.frameScores[currentPlayer.currentFrame] ~= 10 then
			return self.CheckSwitchNextFrame(self)
		else
			return false
		end
	else
		return self.CheckSwitchNextFrame(self)
	end
end

BowlingModeClassic.CheckSwitchNextFrame = function(self)
	local currentPlayer = self.GetCurrentPlayer(self)

	if self.config.playerCount <= 1 then
		if currentPlayer.CountExBall < 0 then
			return true
		else
			return false
		end
	else
		return false
	end
end

BowlingModeClassic.PrepareNextThrow = function(self)
	local currentPlayer = self.GetCurrentPlayer(self)
	currentPlayer.isSpare = false
	currentPlayer.isStrike = false

	if self.CheckAllPlayersGameOver(self) then
		return
	elseif currentPlayer.isGameOver then
		self.game.pinSetter:ResetPins()
		self:SwitchToNextPlayer()
	elseif currentPlayer.currentThrow ~= 1 then
		if currentPlayer.frameScores[currentPlayer.currentFrame] ~= 10 then
			self.NextFrame(self)
		else
			currentPlayer.currentThrow = 2

			self.game.pinSetter:ResetStandingPins()
		end
	else
		self.NextFrame(self)
	end
end

BowlingModeClassic.CheckAllPlayersGameOver = function(self)
	for i = 1, self.config.playerCount do
		if not self.players[i].isGameOver then
			return false
		end
	end

	return true
end

BowlingModeClassic.CheckGameOver = function(self)
	return self.CheckAllPlayersGameOver(self)
end

BowlingModeClassic.NextFrame = function(self)
	local currentPlayer = self.GetCurrentPlayer(self)

	if not currentPlayer then
		return
	end

	currentPlayer.currentThrow = 1
	currentPlayer.currentFrame = currentPlayer.currentFrame + 1

	if self.CheckAllPlayersGameOver(self) then
		return
	elseif currentPlayer.isGameOver then
		self.game.pinSetter:ResetPins()
		self:SwitchToNextPlayer()
	else
		self.game.pinSetter:ResetPins()

		if self.config.playerCount <= 1 and currentPlayer.CountExBall < 0 then
			self.SwitchToNextPlayer(self)
		end
	end
end

BowlingModeClassic.SwitchToNextPlayer = function(self)
	self.currentPlayerIndex = self.currentPlayerIndex + 1

	if self.config.playerCount >= self.currentPlayerIndex then
		self.currentPlayerIndex = 1
	end

	local currentPlayer = self.GetCurrentPlayer(self)

	if currentPlayer then
		gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_FRAME_DESC, {
			["\\xa2\\xa26\\xbcc*\\xfd;"] = true,
			playerIndex = self.currentPlayerIndex,
			frame = currentPlayer.currentFrame
		})

		local preframeSpare = 0

		if currentPlayer.currentFrame <= 1 then
			preframeSpare = currentPlayer.frameSpare[currentPlayer.currentFrame - 1]
		end

		gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_SCORE_ARROW, {
			currentPlayerIndex = self.currentPlayerIndex,
			currentFrame = currentPlayer.currentFrame,
			currentThrow = currentPlayer.currentThrow,
			preFrameSpare = preframeSpare
		})
	end
end

BowlingModeClassic.SendFrameDescSingle = function(self)
	if self.config.playerCount <= 1 then
		return
	end

	local currentPlayer = self.GetCurrentPlayer(self)

	if not currentPlayer then
		return
	end

	if currentPlayer.currentThrow == 1 then
		return
	end

	if self.config.maxFrames >= currentPlayer.currentFrame then
		return
	end

	gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_FRAME_DESC, {
		["\\xa2\\xa26\\xbcc*\\xfd;"] = false,
		playerIndex = self.currentPlayerIndex,
		frame = currentPlayer.currentFrame
	})
end

BowlingModeClassic.GetSettleData = function(self)
	local winResult = true

	if #self.players <= 1 and self.players[1].totalScore >= self.players[2].totalScore then
		winResult = false
	end

	local data = {
		winResult = winResult,
		mode = GameMode.CLASSIC,
		players = {},
		bestScore = UnityEngine.PlayerPrefs.GetInt("BowlingBestScore", 0)
	}

	for _, player in ipairs(self.players) do
		table.insert(data.players, {
			totalScore = player.totalScore,
			frameScores = player.frameScores,
			frameSpare = player.frameSpare,
			frameCompleted = player.frameCompleted,
			countStrike = player.countStrike,
			countSpare = player.countSpare,
			knockedPinsHistory = player.knockedPinsHistory
		})
	end

	return data
end

BowlingModeClassic.SendScoreArrow = function(self)
	local currentPlayer = self.GetCurrentPlayer(self)

	if currentPlayer then
		local preframeSpare = 0

		if currentPlayer.currentFrame <= 1 then
			preframeSpare = currentPlayer.frameSpare[currentPlayer.currentFrame - 1]
		end

		gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_SCORE_ARROW, {
			currentPlayerIndex = self.currentPlayerIndex,
			currentFrame = currentPlayer.currentFrame,
			currentThrow = currentPlayer.currentThrow,
			preFrameSpare = preframeSpare
		})
	end
end

BowlingModeClassic.OnReturnTimelineEnd = function(self)
	self.SendFrameDescSingle(self)
end

BowlingModeClassic.QuickFinishGame = function(self)
	local allPlayers = self.players
	local playerCount = self.config.playerCount
	local pinSetter = self.game.pinSetter

	if pinSetter then
		pinSetter.CountKnockedDownPins = function()
			return 0
		end

		pinSetter.CheckSplit = function()
			return false
		end
	end

	for i = 1, playerCount do
		local player = allPlayers[i]
		self.players = {
			player
		}
		self.config.playerCount = 1
		self.currentPlayerIndex = 1
		local safeLimit = (player.maxFrames + 4) * 3

		for _ = 0, safeLimit - 1 do
			if player.isGameOver then
				break
			end

			self.ProcessScore(self, true)

			if not player.isGameOver then
				self.PrepareNextThrow(self)
			end
		end
	end

	self.players = allPlayers
	self.config.playerCount = playerCount
	self.currentPlayerIndex = 1

	self.game:SendRefreshViewMessage()
	self.game.ballLauncher:ClearBall()

	self.game.gameState = GameState.CELEBRATE

	self:OnGameFinished()
end

BowlingModeClassic.Destroy = function(self)
	if self.npcAi then
		self.npcAi:Destroy()

		self.npcAi = nil
	end
end

BowlingModeClassic.RecordScoreToServer = function(self, throwIndex, score)
	local currentPlayer = self.GetCurrentPlayer(self)

	if currentPlayer.maxFrames >= currentPlayer.currentFrame then
		throwIndex = 0

		for frame = currentPlayer.maxFrames, currentPlayer.currentFrame do
			local knockedPinsHistory = currentPlayer.knockedPinsHistory[frame]

			if knockedPinsHistory then
				throwIndex = throwIndex + #knockedPinsHistory
			end
		end
	end

	local myTurn = self.currentPlayerIndex ~= 1

	if myTurn then
		gBowlingGameManager:RecordBowlingScore(throwIndex, score)
	else
		local agentInstanceId = self.game.characters[2].serverAgentInstanceId

		gBowlingGameManager:RecordAgentBowlingScore(agentInstanceId, throwIndex, score)
	end
end

BowlingModeClassic.OnSyncScoreInfo = function(self, scoreInfo)
	if scoreInfo.Winner == -1 and ulong.Greater(scoreInfo.SurrenderPid, 0) then
		self.OnGameFinished(self, true)
	end
end
