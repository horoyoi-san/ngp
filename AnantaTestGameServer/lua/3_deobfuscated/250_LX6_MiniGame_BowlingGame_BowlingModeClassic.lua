gBowlingModeClassic = DefClass("BowlingModeClassic", gBowlingModeClassic, gBowlingModeBase)
local BowlingModeClassic = gBowlingModeClassic
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local GameState = BowlingConstants.GameState
local GameMode = BowlingConstants.GameMode
local TimelineScene = BowlingConstants.TimelineScene
local BConfig = require("LX6/MiniGame/BowlingGame/BowlingConfig")
local BowlingMessageManager = require("LX6/MiniGame/BowlingGame/BowlingMessageManager")

function BowlingModeClassic:InitData()
	BowlingModeClassic.base.InitData(self)
	self:InitPlayers()

	self.maxFrames = self.config.maxFrames or 10
	self.currentFrame = 1
end

function BowlingModeClassic:InitPlayers()
	self.currentPlayerIndex = 1
	self.players = {}
	self.isFirstSwitch = true

	for i = 1, self.config.playerCount do
		self.players[i] = {
			knockedPins = 0,
			currentThrow = 1,
			CountExBall = 0,
			previousFrameScore = 0,
			isFirst = true,
			isSplit = false,
			totalScore = 0,
			currentFrame = 1,
			isSpare = false,
			isGameOver = false,
			isStrike = false,
			maxFrames = self.config.maxFrames or 3,
			frameScores = {},
			frameSpare = {},
			frameCompleted = {},
			frameBonus = {},
			knockedPinsHistory = {},
			isNPC = i ~= 1,
			curBallIndex = math.ceil(#BConfig.Launcher.prefabPaths.balls / 2)
		}
	end
end

function BowlingModeClassic:GetCurrentPlayer()
	return self.players[self.currentPlayerIndex]
end

function BowlingModeClassic:SetCurrentPlayerBallIndex(ballIndex)
	self.players[self.currentPlayerIndex].curBallIndex = ballIndex
end

function BowlingModeClassic:GetCurrentPlayerBallIndex()
	return self.players[self.currentPlayerIndex].curBallIndex
end

function BowlingModeClassic:ProcessGameState()
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
	else
		print_error("Unknown game state: ", self.game.gameState)
	end
end

function BowlingModeClassic:ProcessState_Mode()
	return
end

function BowlingModeClassic:ProcessState_Init()
	local currentTime = Time.time

	if self.game.initEndTime <= currentTime then
		self.NpcOp = false
		self.game.IsWalkEnd = false

		if self.game.IsFirst and self.game:GetCurrentCharacter() then
			self.game.IsFirst = false

			self.game.pinSetter:ResetPins()
		end

		local currentPlayer = self:GetCurrentPlayer()

		if currentPlayer and currentPlayer.isFirst and self.currentPlayerIndex == 1 then
			currentPlayer.isFirst = false
			local currentCharacter = self.game:GetCurrentCharacter()

			currentCharacter:ExecuteTimeLine(TimelineScene.ENTER, function ()
				gBowlingGameManager.currentGame:OnEventAnimWalkEnd()
			end)
		else
			self.game.IsWalkEnd = true
		end

		self.game.gameState = GameState.ANIM
	end
end

function BowlingModeClassic:ProcessState_Anim()
	if self.game.IsWalkEnd then
		self.game.IsLaunchEnd = false
		self.game.gameState = GameState.READY

		self.game.camera:ResetCamera()

		if self.game.ballLauncher then
			self.game.ballLauncher:BeginPos(self:GetCurrentPlayerBallIndex())
			coroutine.wait(0.1)
			self.game.camera:ResetCamera()
			self:SendScoreArrow()
		end
	end
end

function BowlingModeClassic:ProcessState_Ready()
	if self.NpcOp == false then
		self:NpcLaunch()
	end
end

function BowlingModeClassic:ProcessState_Throwing()
	self.NpcOp = false

	if self.game.IsLaunchEnd then
		self.game.gameState = GameState.ROLLING
	end
end

function BowlingModeClassic:ProcessState_Rolling()
	local currentTime = Time.time

	if self.game:CheckBallAndPinsSettled() then
		self.game.gameState = GameState.SCORING
		self.game.scoringEndTime = currentTime + 3

		self.game.camera:AddShake(0.2, 0.3)
		self.game.camera:StopFollow()
	end
end

function BowlingModeClassic:ProcessState_Scoring()
	local currentTime = Time.time
	local hasStand = self.game.pinSetter:hasStandPins()

	if self.game.scoringEndTime <= currentTime or not hasStand then
		self:ProcessScore(hasStand)

		self.game.gameState = GameState.RESETTING

		if self:CheckSwitch() then
			self.game:OnEventAnimBackBegin(true)

			self.isFirstSwitch = false
			local curIndex = self.currentPlayerIndex + 1

			if self.config.playerCount < curIndex then
				curIndex = 1
			end
		else
			self.game:OnEventAnimBackBegin(false)
		end

		self.game.ballLauncher:ClearBall()

		if not self:CheckAllPlayersGameOver() then
			self:PrepareNextThrow()
		end
	end
end

function BowlingModeClassic:ProcessState_Resetting()
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

function BowlingModeClassic:ProcessState_Celebrate()
	self.game.gameState = GameState.GAMEOVER

	self.game:Settle()
	self.game:GameOver()
end

function BowlingModeClassic:ClosePanel()
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_MAIN_PANEL)
end

function BowlingModeClassic:OnGameFinished()
	self:ClosePanel()
	gBowlingGameManager:SendSignalToGadget("GameFinished")

	if self.config.playerCount <= 1 then
		self.game:GetCharacter(1):ExecuteTimeLine(TimelineScene.END, function ()
			return
		end)
	elseif self.players[2].totalScore < self.players[1].totalScore then
		self.game:GetCharacter(1):ExecuteTimeLine(TimelineScene.WIN, function ()
			return
		end)
	elseif self.players[1].totalScore < self.players[2].totalScore then
		self.game:GetCharacter(1):ExecuteTimeLine(TimelineScene.LOSE, function ()
			return
		end)
	else
		self.game:GetCharacter(1):ExecuteTimeLine(TimelineScene.DRAW, function ()
			return
		end)
	end
end

function BowlingModeClassic:ProcessScore(hasStand)
	local currentPlayer = self:GetCurrentPlayer()
	local knockedPins = self.game.pinSetter:CountKnockedDownPins()
	currentPlayer.knockedPins = knockedPins
	currentPlayer.isSplit = false

	if currentPlayer.currentThrow == 1 then
		local isSplit = self.game.pinSetter:CheckSplit()
		currentPlayer.isSplit = isSplit
	end

	if not currentPlayer.knockedPinsHistory[currentPlayer.currentFrame] then
		currentPlayer.knockedPinsHistory[currentPlayer.currentFrame] = {}
	end

	table.insert(currentPlayer.knockedPinsHistory[currentPlayer.currentFrame], knockedPins)

	if currentPlayer.CountExBall > 0 then
		currentPlayer.CountExBall = currentPlayer.CountExBall - 1
	end

	for frame = 1, currentPlayer.currentFrame - 1 do
		if currentPlayer.frameBonus[frame] and currentPlayer.frameBonus[frame] > 0 then
			if frame < self.game.maxFrames then
				currentPlayer.frameScores[frame] = currentPlayer.frameScores[frame] + knockedPins
			end

			currentPlayer.frameBonus[frame] = currentPlayer.frameBonus[frame] - 1
		end
	end

	if currentPlayer.currentThrow == 1 then
		currentPlayer.frameSpare[currentPlayer.currentFrame] = 0
		currentPlayer.frameScores[currentPlayer.currentFrame] = knockedPins

		if knockedPins == 10 then
			currentPlayer.frameSpare[currentPlayer.currentFrame] = 1
			currentPlayer.isStrike = true
			currentPlayer.frameBonus[currentPlayer.currentFrame] = 2

			if currentPlayer.currentFrame == currentPlayer.maxFrames then
				currentPlayer.CountExBall = 2
			end
		end
	else
		local frameTotal = (currentPlayer.frameScores[currentPlayer.currentFrame] or 0) + knockedPins
		currentPlayer.frameScores[currentPlayer.currentFrame] = frameTotal

		if frameTotal == 10 then
			currentPlayer.frameSpare[currentPlayer.currentFrame] = 2
			currentPlayer.isSpare = true
			currentPlayer.frameBonus[currentPlayer.currentFrame] = 1

			if currentPlayer.currentFrame == currentPlayer.maxFrames then
				currentPlayer.CountExBall = 1
			end
		end
	end

	if currentPlayer.maxFrames < currentPlayer.currentFrame then
		currentPlayer.isGameOver = currentPlayer.CountExBall <= 0
	elseif currentPlayer.currentFrame == currentPlayer.maxFrames and currentPlayer.currentThrow >= 2 then
		currentPlayer.isGameOver = currentPlayer.CountExBall <= 0
	end

	currentPlayer.totalScore = 0

	for fIndex, score in ipairs(currentPlayer.frameScores) do
		if fIndex <= currentPlayer.maxFrames then
			currentPlayer.totalScore = currentPlayer.totalScore + (score or 0)
		end
	end

	for frame = 1, currentPlayer.currentFrame do
		if not currentPlayer.frameCompleted[frame] then
			if currentPlayer.isGameOver then
				currentPlayer.frameCompleted[frame] = true
			elseif frame < currentPlayer.currentFrame and (not currentPlayer.frameBonus[frame] or currentPlayer.frameBonus[frame] <= 0) then
				currentPlayer.frameCompleted[frame] = true
			elseif currentPlayer.currentFrame == frame and currentPlayer.currentThrow >= 2 and currentPlayer.frameSpare[frame] == 0 then
				currentPlayer.frameCompleted[frame] = true
			end
		end
	end

	self.game:SendRefreshViewMessage()

	if not hasStand then
		local delay = self.game.scoringEndTime - Time.time

		if delay < 0.5 then
			delay = 0.5
		end

		coroutine.wait(delay)
	end
end

function BowlingModeClassic:CheckSwitch()
	local currentPlayer = self:GetCurrentPlayer()

	if self:CheckAllPlayersGameOver() then
		return false
	elseif currentPlayer.isGameOver then
		return true
	elseif currentPlayer.currentThrow == 1 then
		if currentPlayer.frameScores[currentPlayer.currentFrame] == 10 then
			return self:CheckSwitchNextFrame()
		else
			return false
		end
	else
		return self:CheckSwitchNextFrame()
	end
end

function BowlingModeClassic:CheckSwitchNextFrame()
	local currentPlayer = self:GetCurrentPlayer()

	if self.config.playerCount > 1 then
		if currentPlayer.CountExBall <= 0 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function BowlingModeClassic:PrepareNextThrow()
	local currentPlayer = self:GetCurrentPlayer()
	currentPlayer.isSpare = false
	currentPlayer.isStrike = false

	if self:CheckAllPlayersGameOver() then
		return
	elseif currentPlayer.isGameOver then
		self.game.pinSetter:ResetPins()
		self:SwitchToNextPlayer()
	elseif currentPlayer.currentThrow == 1 then
		if currentPlayer.frameScores[currentPlayer.currentFrame] == 10 then
			self:NextFrame()
		else
			currentPlayer.currentThrow = 2

			self.game.pinSetter:ResetStandingPins()
		end
	else
		self:NextFrame()
	end
end

function BowlingModeClassic:CheckAllPlayersGameOver()
	for i = 1, self.config.playerCount do
		if not self.players[i].isGameOver then
			return false
		end
	end

	return true
end

function BowlingModeClassic:CheckGameOver()
	return self:CheckAllPlayersGameOver()
end

function BowlingModeClassic:NextFrame()
	local currentPlayer = self:GetCurrentPlayer()

	if not currentPlayer then
		return
	end

	currentPlayer.currentThrow = 1
	currentPlayer.currentFrame = currentPlayer.currentFrame + 1

	if self:CheckAllPlayersGameOver() then
		return
	elseif currentPlayer.isGameOver then
		self.game.pinSetter:ResetPins()
		self:SwitchToNextPlayer()
	else
		self.game.pinSetter:ResetPins()

		if self.config.playerCount > 1 and currentPlayer.CountExBall <= 0 then
			self:SwitchToNextPlayer()
		end
	end
end

function BowlingModeClassic:NpcLaunch()
	local currentPlayer = self:GetCurrentPlayer()

	if not currentPlayer.isNPC or self.NpcOp then
		return
	end

	self.NpcOp = true
	local params = {
		rot = 0,
		offset = math.random(self.game.ballLauncher.maxLaunchOffset * 100 / 2, self.game.ballLauncher.minLaunchOffset * 100 / 2) / 100,
		dir = math.random(self.game.ballLauncher.minLaunchDir * 100 / 3, self.game.ballLauncher.maxLaunchDir * 100 / 3) / 100,
		power = math.random(self.game.ballLauncher.minLaunchForce[self.game.ballLauncher.CurBallIndex], self.game.ballLauncher.maxLaunchForce[self.game.ballLauncher.CurBallIndex])
	}

	self.game.ballLauncher:NPCAutoLaunch(params)
end

function BowlingModeClassic:SwitchToNextPlayer()
	self.currentPlayerIndex = self.currentPlayerIndex + 1

	if self.config.playerCount < self.currentPlayerIndex then
		self.currentPlayerIndex = 1
	end

	local currentPlayer = self:GetCurrentPlayer()

	if currentPlayer then
		self.game.ballLauncher:SetNPCMode(currentPlayer.isNPC)
		BowlingMessageManager:SendMessage(gEventConstants.BOWLING_GAME_FRAME_DESC, {
			isSwitch = true,
			playerIndex = self.currentPlayerIndex,
			frame = currentPlayer.currentFrame
		})

		local preframeSpare = 0

		if currentPlayer.currentFrame > 1 then
			preframeSpare = currentPlayer.frameSpare[currentPlayer.currentFrame - 1]
		end

		BowlingMessageManager:SendMessage(gEventConstants.BOWLING_GAME_SCORE_ARROW, {
			currentPlayerIndex = self.currentPlayerIndex,
			currentFrame = currentPlayer.currentFrame,
			currentThrow = currentPlayer.currentThrow,
			preFrameSpare = preframeSpare
		})
	end
end

function BowlingModeClassic:SendFrameDescSingle()
	if self.config.playerCount > 1 then
		return
	end

	local currentPlayer = self:GetCurrentPlayer()

	if not currentPlayer then
		return
	end

	if currentPlayer.currentThrow ~= 1 then
		return
	end

	if self.config.maxFrames < currentPlayer.currentFrame then
		return
	end

	BowlingMessageManager:SendMessage(gEventConstants.BOWLING_GAME_FRAME_DESC, {
		isSwitch = false,
		playerIndex = self.currentPlayerIndex,
		frame = currentPlayer.currentFrame
	})
end

function BowlingModeClassic:GetNextPlayerIndex()
	local nextPlayerIndex = self.currentPlayerIndex + 1

	if self.config.playerCount < nextPlayerIndex then
		nextPlayerIndex = 1
	end

	return nextPlayerIndex
end

function BowlingModeClassic:GetNextPlayer()
	local index = self:GetNextPlayerIndex()

	return self.players[index]
end

function BowlingModeClassic:GetSettleData()
	local winResult = true
	local rTitle = "比赛结果"

	if #self.players > 1 then
		if self.players[2].totalScore < self.players[1].totalScore then
			rTitle = "挑战获胜"
		elseif self.players[1].totalScore < self.players[2].totalScore then
			rTitle = "挑战失败"
			winResult = false
		else
			rTitle = "不分胜负"
		end
	end

	local data = {
		winResult = winResult,
		mode = GameMode.CLASSIC,
		players = {},
		bestScore = UnityEngine.PlayerPrefs.GetInt("BowlingBestScore", 0),
		title = rTitle
	}

	for i, player in ipairs(self.players) do
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

function BowlingModeClassic:SendScoreArrow()
	local currentPlayer = self:GetCurrentPlayer()

	if currentPlayer then
		local preframeSpare = 0

		if currentPlayer.currentFrame > 1 then
			preframeSpare = currentPlayer.frameSpare[currentPlayer.currentFrame - 1]
		end

		BowlingMessageManager:SendMessage(gEventConstants.BOWLING_GAME_SCORE_ARROW, {
			currentPlayerIndex = self.currentPlayerIndex,
			currentFrame = currentPlayer.currentFrame,
			currentThrow = currentPlayer.currentThrow,
			preFrameSpare = preframeSpare
		})
	end
end

function BowlingModeClassic:OnEventAnimBackEnd()
	self:SendFrameDescSingle()
end
