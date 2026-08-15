gBowlingModeTech = DefClass("BowlingModeTech", gBowlingModeTech, gBowlingModeBase)
local BowlingModeTech = gBowlingModeTech
local BowlingTechPatterns = require("LX6/MiniGame/BowlingGame/BowlingTechPatterns")
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local GameState = BowlingConstants.GameState
local GameMode = BowlingConstants.GameMode
local TimelineScene = BowlingConstants.TimelineScene
local BConfig = require("LX6/MiniGame/BowlingGame/BowlingConfig")
local DataSet = require("LX6/DataBind/DataSet")

function BowlingModeTech:InitData()
	BowlingModeTech.base.InitData(self)

	self.maxAttempts = 3
	self.currentAttempt = 1
	self.currentPatternIndex = 1
	self.currentPattern = nil
	self.technicalScore = 0
	self.patterns = BowlingTechPatterns
	self.isPatternSelecting = true
	self.completedPatterns = {}
	self.dataSet = DataSet.New({})
	self.visiblePatternsCount = 7
end

function BowlingModeTech:InitPlayers()
	self.currentPlayerIndex = 1
	self.players = {
		{
			isNPC = false,
			isGameOver = false,
			totalScore = 0,
			curBallIndex = math.ceil(#BConfig.Launcher.prefabPaths.balls / 2)
		}
	}
end

function BowlingModeTech:Destroy()
	self.coroutineSelectPins = coroutine.stop(self.coroutineSelectPins)

	BowlingModeTech.base.Destroy(self)
end

function BowlingModeTech:GetCurrentPlayer()
	return self.players[self.currentPlayerIndex]
end

function BowlingModeTech:SetCurrentPlayerBallIndex(ballIndex)
	self.players[self.currentPlayerIndex].curBallIndex = ballIndex
end

function BowlingModeTech:SelectPattern(patternIndex)
	if not self.isPatternSelecting then
		return false
	end

	self.currentPatternIndex = patternIndex
	self.currentPattern = self.patterns[patternIndex]
	self.isPatternSelecting = false

	self:RefreshPattern()

	return true
end

function BowlingModeTech:RefreshPattern()
	local boolPattern = {}

	for i = 1, 10 do
		boolPattern[i] = false
	end

	for _, pinNumber in ipairs(self.currentPattern.pins) do
		boolPattern[pinNumber] = true
	end

	self.game.pinSetter:SetPinsPattern(boolPattern)
end

function BowlingModeTech:ProcessScore()
	local currentPlayer = self:GetCurrentPlayer()
	self.isPatternSelecting = true

	self.game.pinSetter:UpdateStandingPinsState()

	if not self.game.pinSetter:hasStandPins() then
		self.technicalScore = self.technicalScore + self.currentPattern.score
		currentPlayer.totalScore = self.technicalScore
		currentPlayer.isStrike = true
		local hasIndex = false

		for _, index in ipairs(self.completedPatterns) do
			if index == self.currentPatternIndex then
				hasIndex = true

				break
			end
		end

		if not hasIndex then
			table.insert(self.completedPatterns, self.currentPatternIndex)

			self.dataSet.completed = self.currentPatternIndex
		end
	else
		self.currentAttempt = self.currentAttempt + 1
	end

	if self.maxAttempts < self.currentAttempt or #self.completedPatterns >= #self.patterns then
		currentPlayer.isGameOver = true

		return true
	end

	return false
end

function BowlingModeTech:IsWaitingForPatternSelection()
	return self.isPatternSelecting
end

function BowlingModeTech:GetCurrentAttempt()
	return self.currentAttempt
end

function BowlingModeTech:GetMaxAttempts()
	return self.maxAttempts
end

function BowlingModeTech:GetTechnicalScore()
	return self.technicalScore
end

function BowlingModeTech:GetAvailablePatterns()
	return self.patterns
end

function BowlingModeTech:ProcessGameState()
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
	else
		print_error("Unknown game state: ", self.game.gameState)
	end
end

function BowlingModeTech:ProcessState_Init()
	if self.isPatternSelecting then
		self:CheckShowPinsPanel()

		return
	end

	self.isWaitingForSelection = false
	self.game.IsWalkEnd = false

	if self.game.IsFirst and self.game:GetCurrentCharacter() then
		self.game.IsFirst = false

		self.game:GetCurrentCharacter():ExecuteTimeLine(TimelineScene.ENTER, function ()
			gBowlingGameManager.currentGame:OnEventAnimWalkEnd()
		end)
	else
		self.game.IsWalkEnd = true
	end

	self.game.gameState = GameState.ANIM
end

function BowlingModeTech:ProcessState_Anim()
	if self.game.IsWalkEnd then
		self.game.IsLaunchEnd = false
		self.game.gameState = GameState.READY

		self.game.camera:ResetCamera()

		if self.game.ballLauncher then
			self.game.ballLauncher:BeginPos()
			coroutine.wait(0.1)
			self.game.camera:ResetCamera()
		end
	end
end

function BowlingModeTech:ProcessState_Ready()
	return
end

function BowlingModeTech:ProcessState_Throwing()
	if self.game.IsLaunchEnd then
		self.game.gameState = GameState.ROLLING
	end
end

function BowlingModeTech:ProcessState_Rolling()
	local currentTime = Time.time

	if self.game:CheckBallAndPinsSettled() then
		self.game.gameState = GameState.SCORING
		self.game.scoringEndTime = currentTime + 3

		self.game.camera:AddShake(0.2, 0.3)
		self.game.camera:StopFollow()
		self.game.ballLauncher:ClearBall()
	end
end

function BowlingModeTech:ProcessState_Scoring()
	local currentTime = Time.time

	if self.game.scoringEndTime <= currentTime then
		self:ProcessScore()

		self.game.gameState = GameState.RESETTING

		self.game:OnEventAnimBackBegin()
	end
end

function BowlingModeTech:ProcessState_Resetting()
	if not self.game.IsBackEnd then
		return
	end

	local currentTime = Time.time

	if self:CheckGameOver() then
		gBowlingGameManager.currentGame.gameMode.dataSet.count = self.maxAttempts - self.currentAttempt + 1

		self.game.ballLauncher:ClearBall()
		self:OnGameFinished()

		self.game.gameState = GameState.GAMEOVER

		self.game:Settle()
		self.game:GameOver()
	else
		if self.isPatternSelecting then
			self:CheckShowPinsPanel()

			return
		end

		self.isWaitingForSelection = false

		self:PrepareNextThrow()

		self.game.gameState = GameState.INIT
		self.game.initEndTime = currentTime

		self.game.camera:ResetCamera()
	end
end

function BowlingModeTech:OnGameFinished()
	gBowlingGameManager:SendSignalToGadget("GameFinished")
	self.game:GetCharacter(1):ExecuteTimeLine(TimelineScene.END, function ()
		return
	end, nil, true)
end

function BowlingModeTech:ClosePanel()
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_MAIN_PANEL)
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_SCORE_TECH_PANEL)
end

function BowlingModeTech:CheckShowPinsPanel()
	if self.isWaitingForSelection then
		return
	end

	self.isWaitingForSelection = true
	self.dataSet.count = self.maxAttempts - self.currentAttempt + 1
	local args = {
		selectIndex = self.currentPatternIndex,
		count = self.maxAttempts - self.currentAttempt + 1,
		completed = self.completedPatterns
	}

	gPanelManager:CheckShow(gPanelId.MINI_GAMES_BOWLING_TECH_PINS_PANEL, args)
end

function BowlingModeTech:PrepareNextThrow()
	local currentPlayer = self:GetCurrentPlayer()
	currentPlayer.isSpare = false
	currentPlayer.isStrike = false

	self.game.ballLauncher:ClearBall()

	if self:CheckGameOver() then
		self.currentPatternIndex = 3

		self.game:Settle()
		self.game:GameOver()

		return
	end

	if self.isPatternSelecting then
		self.game.pinSetter:ResetPins()
	else
		self.game.pinSetter:SetPinsPattern(self.currentPattern.pins)
	end
end

function BowlingModeTech:CheckGameOver()
	return self.maxAttempts < self.currentAttempt or #self.completedPatterns >= #self.patterns
end

function BowlingModeTech:NextFrame()
	self:PrepareNextThrow()
end

function BowlingModeTech:GetSettleData()
	local winResult = true
	local rTitle = "比赛结果"

	if #self.completedPatterns == #BowlingTechPatterns then
		rTitle = "全部达成"
	else
		winResult = false
		rTitle = #self.completedPatterns .. "/" .. tostring(#BowlingTechPatterns) .. "局达成"
	end

	local data = {
		winResult = winResult,
		mode = GameMode.TECHNICAL,
		completedPatterns = self.completedPatterns,
		title = rTitle
	}

	return data
end
