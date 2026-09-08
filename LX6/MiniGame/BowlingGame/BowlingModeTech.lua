-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingModeTech.lua
-- Decompiled from: 00655_BowlingModeTech.lua_bd93f992f2bf.luajit

gBowlingModeTech = DefClass("BowlingModeTech", gBowlingModeTech, gBowlingModeBase)
local BowlingModeTech = gBowlingModeTech
local BowlingTechPatterns = require("LX6/MiniGame/BowlingGame/BowlingTechPatterns")
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local GameState = BowlingConstants.GameState
local GameMode = BowlingConstants.GameMode
local TimelineScene = BowlingConstants.TimelineScene
local BConfig = require("LX6/MiniGame/BowlingGame/BowlingConfig")
local DataSet = require("LX6/DataBind/DataSet")

BowlingModeTech.InitData = function(self)
	BowlingModeTech.base.InitData(self)

	self.maxAttempts = 3
	self.currentAttempt = 1
	self.currentPatternIndex = 1
	self.currentPattern = nil
	self.technicalScore = 0
	self.patterns = BowlingTechPatterns
	self.isPatternSelecting = true
	self.completedPatterns = {}
	self.dataSet = DataSet.New({
		count = self.maxAttempts
	})
end

BowlingModeTech.InitPlayers = function(self)
	self.currentPlayerIndex = 1
	self.players = {
		{
			["D\\xbd\\x8c\\x9f\\x95"] = false,
			["ZI鼉\r\\x97\\xcc\\xfa"] = false,
			["GUڼ\\x88;\\xbb\\xdb\\xed"] = 0,
			curBallIndex = math.ceil(#BConfig.Launcher.prefabPaths.balls / 2)
		}
	}
end

BowlingModeTech.Destroy = function(self)
	BowlingModeTech.base.Destroy(self)
end

BowlingModeTech.GetCurrentPlayer = function(self)
	return self.players[self.currentPlayerIndex]
end

BowlingModeTech.SetCurrentPlayerBallIndex = function(self, ballIndex)
	self.players[self.currentPlayerIndex].curBallIndex = ballIndex
end

BowlingModeTech.SelectPattern = function(self, patternIndex)
	if not self.isPatternSelecting then
		return false
	end

	self.currentPatternIndex = patternIndex
	self.currentPattern = self.patterns[patternIndex]
	self.isPatternSelecting = false

	self.RefreshPattern(self)

	return true
end

BowlingModeTech.RefreshPattern = function(self)
	local boolPattern = {}

	for i = 1, 10 do
		boolPattern[i] = false
	end

	for _, pinNumber in ipairs(self.currentPattern.pins) do
		boolPattern[pinNumber] = true
	end

	self.game.pinSetter:SetPinsPattern(boolPattern)
end

BowlingModeTech.GetRemainingAttemptCount = function(self)
	return math.max(self.maxAttempts - self.currentAttempt + 1, 0)
end

BowlingModeTech.RefreshRemainingAttemptCount = function(self)
	self.dataSet.count = self.GetRemainingAttemptCount(self)
end

BowlingModeTech.ProcessScore = function(self)
	local currentPlayer = self:GetCurrentPlayer()
	self.isPatternSelecting = true

	self.game.pinSetter:UpdateStandingPinsState()

	if not self.game.pinSetter:hasStandPins() then
		self.technicalScore = self.technicalScore + self.currentPattern.score
		currentPlayer.totalScore = self.technicalScore
		currentPlayer.isStrike = true
		local hasIndex = false

		for _, index in ipairs(self.completedPatterns) do
			if index ~= self.currentPatternIndex then
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

		self.RefreshRemainingAttemptCount(self)
	end

	if self.maxAttempts <= self.currentAttempt or #self.completedPatterns > #self.patterns then
		currentPlayer.isGameOver = true

		return true
	end

	return false
end

BowlingModeTech.ProcessGameState = function(self)
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

BowlingModeTech.ProcessState_Init = function(self)
	if self.isPatternSelecting then
		self.CheckShowPinsPanel(self)

		return
	end

	self.isWaitingForSelection = false
	self.game.IsEnterTimelineEnd = false

	if self.game.IsFirst and self.game:GetCurrentCharacter() then
		self.game.IsFirst = false
		slot1 = self.game
		slot1 = slot1:GetCurrentCharacter()

		slot1:ExecuteTimeLine(TimelineScene.ENTER, function ()
			self.game:OnEnterTimelineEnd()
		end)
	else
		self.game.IsEnterTimelineEnd = true
	end

	self.game.gameState = GameState.ANIM
end

BowlingModeTech.ProcessState_Anim = function(self)
	if self.game.IsEnterTimelineEnd then
		self.game.IsLaunchEnd = false
		self.game.gameState = GameState.READY

		self.game.camera:ResetCamera()

		if self.game.ballLauncher then
			self.game.ballLauncher:BeginPos()
			coroutine.yield(gWaitableUtils.WaitTime(0.1))
			self.game.camera:ResetCamera()
		end
	end
end

BowlingModeTech.ProcessState_Ready = function(self)
end

BowlingModeTech.ProcessState_Throwing = function(self)
	if self.game.IsLaunchEnd then
		self.game.gameState = GameState.ROLLING
	end
end

BowlingModeTech.ProcessState_Rolling = function(self)
	self.ProcessStateRollingCommon(self, true)
end

BowlingModeTech.ProcessState_Scoring = function(self)
	local currentTime = Time.time

	if self.game.scoringEndTime < currentTime then
		local isGameOver = self.ProcessScore(self)
		self.game.gameState = GameState.RESETTING

		if isGameOver then
			self.game:OnReturnTimelineEnd()
		else
			self.game:PlayReturnTimeline()
		end
	end
end

BowlingModeTech.ProcessState_Resetting = function(self)
	if not self.game.IsReturnTimelineEnd then
		return
	end

	local currentTime = Time.time

	if self.CheckGameOver(self) then
		self:RefreshRemainingAttemptCount()
		self.game.ballLauncher:ClearBall()

		self.game.gameState = GameState.CELEBRATE

		self:OnGameFinished()
	else
		if self.isPatternSelecting then
			self.CheckShowPinsPanel(self)

			return
		end

		self.isWaitingForSelection = false

		self:PrepareNextThrow()

		self.game.gameState = GameState.INIT
		self.game.initEndTime = currentTime

		self.game.camera:ResetCamera()
	end
end

BowlingModeTech.ProcessState_Celebrate = function(self)
	self.game.gameState = GameState.GAMEOVER

	self.game:Settle()
	self.game:GameOver()
end

BowlingModeTech.OnGameFinished = function(self)
	slot1 = gBowlingGameManager

	slot1:SendSignalToGadget("GameFinished")

	slot1 = self.game
	slot1 = slot1:GetCharacter(1)

	slot1:ExecuteTimeLine(TimelineScene.SINGLE_END, function ()
	end, nil, true)
end

BowlingModeTech.CheckShowPinsPanel = function(self)
	if self.isWaitingForSelection then
		return
	end

	self.isWaitingForSelection = true

	self:RefreshRemainingAttemptCount()

	local args = {
		selectIndex = self.currentPatternIndex,
		count = self:GetRemainingAttemptCount(),
		completed = self.completedPatterns
	}

	gPanelManager:CheckShow(gPanelId.MINI_GAMES_BOWLING_TECH_PINS_PANEL, args)
end

BowlingModeTech.PrepareNextThrow = function(self)
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

BowlingModeTech.CheckGameOver = function(self)
	return self.maxAttempts <= self.currentAttempt or #self.completedPatterns < #self.patterns
end

BowlingModeTech.QuickFinishGame = function(self)
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_TECH_PINS_PANEL)

	self.isPatternSelecting = false
	self.isWaitingForSelection = false
	self.completedPatterns = {}

	for i = 1, #self.patterns do
		table.insert(self.completedPatterns, i)
	end

	self.technicalScore = 0

	for _, idx in ipairs(self.completedPatterns) do
		local pattern = self.patterns[idx]

		if pattern then
			self.technicalScore = self.technicalScore + pattern.score
		end
	end

	local currentPlayer = self.GetCurrentPlayer(self)

	if currentPlayer then
		currentPlayer.totalScore = self.technicalScore
		currentPlayer.isGameOver = true
	end

	self.currentAttempt = self.maxAttempts + 1

	self:RefreshRemainingAttemptCount()

	self.dataSet.completed = self.completedPatterns[#self.completedPatterns]

	self.game.ballLauncher:ClearBall()

	self.game.gameState = GameState.CELEBRATE

	self:OnGameFinished()
end

BowlingModeTech.NextFrame = function(self)
	self.PrepareNextThrow(self)
end

BowlingModeTech.GetSettleData = function(self)
	local data = {
		["TNb[K\r,"] = true,
		mode = GameMode.TECHNICAL,
		completedPatterns = self.completedPatterns
	}

	return data
end
