gBowlingGame = DefClass("BowlingGame", gBowlingGame, gBaseMiniGame)
local BowlingGame = gBowlingGame
local Config = require("LX6/MiniGame/BowlingGame/BowlingConfig").Launcher
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local GameState = BowlingConstants.GameState
local GameMode = BowlingConstants.GameMode
local TimelineScene = BowlingConstants.TimelineScene
local BowlingMessageManager = require("LX6/MiniGame/BowlingGame/BowlingMessageManager")
local DataSet = require("LX6/DataBind/DataSet")
local GameGroundZoneState = UX.Game.GameGroundZoneState
local GameGroundZoneSyncReason = UX.Game.GameGroundZoneSyncReason
local GameGroundZoneType = UX.Game.GameGroundZoneType
local GameGroundParticipantInfo = UX.Game.GameGroundParticipantInfo
local GameGroundZoneInfo = UX.Game.GameGroundZoneInfo
local GameGroundZoneStartReason = UX.Game.GameGroundZoneStartReason

function BowlingGame:Initialize(args)
	self:InitData(args)
	self:InitBowlingScene()
	BowlingGame.base.SetSceneOtherNodesVisible(self, false)
	self:InitCoroutine()
end

function BowlingGame:InitData(args)
	self.args = args
	self.wayPointPosition = args.wayPointPosition
	self.wayPointRotation = args.wayPointRotation
	self.maxFrames = 3
	self.currentFrame = 1
	self.currentThrow = 1
	self.totalScore = 0
	self.frameScores = {}
	self.frameSpare = {}
	self.frameCompleted = {}
	self.previousFrameScore = 0
	self.knockedPins = 0
	self.IsWalkEnd = false
	self.IsLaunchEnd = false
	self.initEndTime = Time.time + 2
	self.throwingEndTime = 0
	self.scoringEndTime = 0
	self.IsFirst = true
	self.gameState = GameState.MODE
	self.dataSet = DataSet.New({})
	self.activeSounds = {}
	self.soundCoroutines = {}
end

function BowlingGame:GetCurrentCharacter()
	if not self then
		print_debug("Error: self is nil in GetCurrentCharacter")

		return nil
	end

	if not self.gameMode then
		print_debug("Error: gameMode is nil in GetCurrentCharacter")

		return nil
	end

	if not self.gameMode.currentPlayerIndex then
		print_debug("Error: currentPlayerIndex is nil in GetCurrentCharacter")

		return nil
	end

	if not self.characters then
		print_debug("Error: characters array is nil in GetCurrentCharacter")

		return nil
	end

	return self.characters[self.gameMode.currentPlayerIndex]
end

function BowlingGame:GetCharacter(playerIndex)
	if not self then
		print_debug("Error: self is nil in GetCurrentCharacter")

		return nil
	end

	if not self.gameMode then
		print_debug("Error: gameMode is nil in GetCurrentCharacter")

		return nil
	end

	if not playerIndex then
		print_debug("Error: currentPlayerIndex is nil in GetCurrentCharacter")

		return nil
	end

	if not self.characters then
		print_debug("Error: characters array is nil in GetCurrentCharacter")

		return nil
	end

	return self.characters[playerIndex]
end

function BowlingGame:ResetCharacterAnim(playerIndex)
	if playerIndex == 0 then
		for i, char in ipairs(self.characters) do
			char:ExecuteReset()
		end
	else
		for i, char in ipairs(self.characters) do
			if i == playerIndex then
				char:ExecuteReset()
			end
		end
	end
end

function BowlingGame:SetCharacterActive(playerIndex, IsActive)
	if playerIndex == 0 then
		for i, char in ipairs(self.characters) do
			char:SetActive(IsActive)
		end
	else
		for i, char in ipairs(self.characters) do
			if i == playerIndex then
				char:SetActive(IsActive)
			end
		end
	end
end

function BowlingGame:SwitchCharacter(playerIndex)
	for i, char in ipairs(self.characters) do
		char:SetActive(i == playerIndex)
	end
end

function BowlingGame:InitBowlingScene()
	self.pinSetter = gBowlingPinSetter.new()
	self.ballLauncher = gBowlingBallLauncher.new()
	self.camera = gBowlingCamera.new()
	self.timelineManager = gBowlingTimelineClipManager.new()
	local basketballSceneNodePath = Config.prefabPaths.scene

	gResourceManager:LoadAssetWithCallBack(basketballSceneNodePath, typeof(UnityEngine.GameObject), function (loadOp)
		if self.hasDestroy then
			gResourceManager:UnloadAssetLoadOp(loadOp)

			return
		else
			self.loadOp = loadOp
			local bowlingSceneNodeGo = UnityEngine.GameObject.Instantiate(self.loadOp.asset)
			self.SceneNodeGo = bowlingSceneNodeGo
			bowlingSceneNodeGo.transform.position = self.wayPointPosition
			bowlingSceneNodeGo.transform.rotation = self.wayPointRotation
			bowlingSceneNodeGo.gameObject.name = "BowlingSceneNode"

			bowlingSceneNodeGo.gameObject:SetActive(true)

			local virtualCameraNode = bowlingSceneNodeGo.transform:Find("VirtualCamera")
			local virtualCamera = virtualCameraNode:GetComponent(typeof(Cinemachine.CinemachineVirtualCamera))

			self.camera:InitCamera(virtualCameraNode, virtualCamera)
			self.ballLauncher:SetSceneNode(bowlingSceneNodeGo)
			self.pinSetter:SetSceneNode(bowlingSceneNodeGo)

			self.scenePoints = {
				virtualCamera = virtualCamera,
				playerPoint = bowlingSceneNodeGo.transform:Find("PivotNode/PlayerPoint"),
				PlayerPointBack = bowlingSceneNodeGo.transform:Find("PivotNode/PlayerPointBack"),
				pinPoint = bowlingSceneNodeGo.transform:Find("PivotNode/PinPoint")
			}

			self.timelineManager:Init(bowlingSceneNodeGo, virtualCamera, self.scenePoints.playerPoint, true)
		end
	end)
end

function BowlingGame:InitCharactersWithScenePoints(agentId, npcUnit)
	if not self.scenePoints then
		print_debug("Warning: Scene points not initialized")

		return
	end

	if self.characters then
		for _, char in ipairs(self.characters) do
			char:Destroy()
		end
	end

	self.characters = {}
	local playerCharacter = gBowlingCharacter.new({
		playerIndex = 1,
		sceneNode = self.SceneNodeGo,
		pinPoint = self.scenePoints.pinPoint,
		playerPoint = self.scenePoints.playerPoint,
		virtualCamera = self.scenePoints.virtualCamera
	})

	table.insert(self.characters, playerCharacter)

	if self.gameMode.config.playerCount == 1 then
		return
	end

	local npcCharacter = gBowlingCharacter.new({
		playerIndex = 2,
		sceneNode = self.SceneNodeGo,
		pinPoint = self.scenePoints.pinPoint,
		playerPoint = self.scenePoints.playerPoint,
		virtualCamera = self.scenePoints.virtualCamera,
		npcId = self.args.agentTemplateId,
		agentId = agentId,
		npcUnit = npcUnit
	})

	table.insert(self.characters, npcCharacter)
end

function BowlingGame:GetNpcName()
	return self.gameMode:GetOtherPlayerName()
end

function BowlingGame:InitUI()
	gPanelManager:CheckShow(gPanelId.MINI_GAMES_BOWLING_MODE_PANEL)
end

function BowlingGame:InitCoroutineCamera()
	self.stateCoroutineCamera = coroutine.start(function ()
		while true do
			coroutine.wait(0.01)

			if self.camera then
				self.camera:UpdateCameraTransform()
			end
		end
	end)
end

function BowlingGame:StopCoroutineCamera()
	self.stateCoroutineCamera = coroutine.stop(self.stateCoroutineCamera)
end

function BowlingGame:InitCoroutine()
	self.stateCoroutine = coroutine.start(function ()
		while true do
			coroutine.wait(0.1)

			if self.gameState == GameState.GAMEOVER then
				return
			end

			if self.gameState ~= GameState.MODE then
				self.gameMode:ProcessGameState()
			end
		end
	end)
end

function BowlingGame:ExecuteShootKeyDown()
	if self.gameState ~= GameState.READY then
		return false
	end

	return self.ballLauncher:StartCharging()
end

function BowlingGame:ExecuteShootKeyLongPress()
	if self.gameState ~= GameState.READY then
		return 0
	end

	return self.ballLauncher:UpdateCharging()
end

function BowlingGame:ExecuteLongPressPowerAuto()
	if self.gameState ~= GameState.READY then
		return 0
	end

	return self.ballLauncher:UpdateChargingPowerAuto()
end

function BowlingGame:ExecuteLongPressPos(dir)
	if self.gameState ~= GameState.READY then
		return -1
	end

	return self.ballLauncher:UpdateChargingPos(dir)
end

function BowlingGame:SetChargingPos(launchOffset, posRatio)
	if self.gameState ~= GameState.READY then
		return -1
	end

	self.ballLauncher:SetChargingPos(launchOffset, posRatio)
end

function BowlingGame:ExecuteLongPressRot(dir)
	if self.gameState ~= GameState.THROWING then
		return -1
	end

	return self.ballLauncher:UpdateChargingRot(dir)
end

function BowlingGame:ExecutePressRot(RotIndex)
	if self.gameState ~= GameState.THROWING then
		return 0
	end

	return self.ballLauncher:UpdateRotIndex(RotIndex)
end

function BowlingGame:ExecuteLongPressDir(dir)
	if self.gameState ~= GameState.READY then
		return 0
	end

	return self.ballLauncher:UpdateChargingDir(dir)
end

function BowlingGame:ExecuteLongPressDirAuto()
	if self.gameState ~= GameState.READY then
		return 0
	end

	return self.ballLauncher:UpdateChargingDirAuto()
end

function BowlingGame:ExecuteShootKeyUp()
	if self.gameState ~= GameState.READY then
		return
	end

	if self.ballLauncher:LaunchKeyUp() then
		self.gameState = GameState.THROWING

		self:OnEventLaunch()
	end
end

function BowlingGame:SetPlayers()
	self.gameMode:InitPlayers()
end

function BowlingGame:WaitForSceneLoaded(callback)
	if self.SceneNodeGo and self.timelineManager and self.timelineManager.isLoaded then
		callback()

		return
	end

	self.waitSceneCoroutine = coroutine.start(function ()
		while not self.SceneNodeGo or not self.timelineManager or not self.timelineManager.isLoaded do
			coroutine.wait(0.1)
		end

		callback()
	end)
end

function BowlingGame:ExecuteSelectMode(mode)
	mode = gBowlingGameManager.debugMode or mode
	self.mode = mode
	local createModeFunc = {
		[GameMode.SINGLE] = self.ExecuteSelectModeSingle,
		[GameMode.NPC_BATTLE] = self.ExecuteSelectModeBattle,
		[GameMode.TECHNICAL] = self.ExecuteSelectModeTech,
		[GameMode.ONLINE_BATTLE] = self.ExecuteSelectModeOnline
	}

	if createModeFunc[mode] then
		createModeFunc[mode](self)
	else
		print_error("Unknown game mode: " .. mode)
	end
end

function BowlingGame:ExecuteSelectModeSingle()
	self.gameMode = gBowlingModeClassic.new(self, {
		technicalChallenges = 1,
		playerCount = 1,
		maxFrames = 3
	})

	self:WaitForSceneLoaded(function ()
		if self.pinSetter then
			self.pinSetter:ResetPins(true)
		end

		self:SetPlayers()
		self:InitCharactersWithScenePoints()
		gPanelManager:CheckShow(gPanelId.MINI_GAMES_BOWLING_MAIN_PANEL, {
			showPanelId = gPanelId.MINI_GAMES_BOWLING_SCORE_SINGLE_PANEL
		})

		self.gameState = GameState.INIT
	end)
end

function BowlingGame:ExecuteSelectModeBattle()
	self.gameMode = gBowlingModeClassic.new(self, {
		technicalChallenges = 1,
		playerCount = 2,
		maxFrames = 3
	})

	self:WaitForSceneLoaded(function ()
		self:SetPlayers()

		if self.pinSetter then
			self.pinSetter:ResetPins(true)
		end

		gPanelManager:CheckShow(gPanelId.MINI_GAMES_BOWLING_MAIN_PANEL, {
			showPanelId = gPanelId.MINI_GAMES_BOWLING_SCORE_BATTLE_PANEL
		})

		local function EnterGameCallback(npcUnit)
			self:InitCharactersWithScenePoints(nil, npcUnit)

			self.gameState = GameState.INIT
		end

		local npcCfg = LTConfig.AgentConfig.GetConfig(self.args.agentTemplateId)

		gCS.UnitsManager:GetDialogModelByAgentId(EnterGameCallback, UX.Game.SexType.UnKnow, npcCfg.Id, false, true, true)
	end)
end

function BowlingGame:ExecuteSelectModeTech()
	self.gameMode = gBowlingModeTech.new(self, {
		technicalChallenges = 1,
		playerCount = 1,
		maxFrames = 3
	})

	self:WaitForSceneLoaded(function ()
		self:SetPlayers()
		self:InitCharactersWithScenePoints()

		if self.pinSetter then
			self.pinSetter:ResetPins(true)
		end

		gPanelManager:CheckShow(gPanelId.MINI_GAMES_BOWLING_MAIN_PANEL, {
			showPanelId = gPanelId.MINI_GAMES_BOWLING_SCORE_TECH_PANEL
		})

		self.gameState = GameState.INIT
	end)
end

function BowlingGame:ExecuteSelectModeOnline()
	self.gameMode = gBowlingModeOnline.new(self, {
		technicalChallenges = 1,
		playerCount = 2,
		maxFrames = 3
	})

	self:WaitForSceneLoaded(function ()
		self:InitCharactersWithScenePoints()
		self.pinSetter:ResetPins(true)
		gPanelManager:CheckShow(gPanelId.MINI_GAMES_BOWLING_MAIN_PANEL, {
			showPanelId = gPanelId.MINI_GAMES_BOWLING_SCORE_BATTLE_PANEL
		})

		self.gameState = GameState.INIT

		gBowlingGameManager:SetReady(true)
	end)
end

function BowlingGame:ExecuteTechPinsSelected(index)
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_TECH_PINS_PANEL)
	gMessageManager:SendMessage(gEventConstants.ON_BOWLING_BALL_INDEX_CHANGE, {
		ballIndex = self.ballLauncher.CurBallIndex
	})
	self:SelectTechPattern(index)
end

function BowlingGame:SelectTechPattern(patternIndex)
	if self.gameMode and self.gameMode.SelectPattern then
		return self.gameMode:SelectPattern(patternIndex)
	end

	return false
end

function BowlingGame:OnEventLaunch()
	local character = self:GetCurrentCharacter()

	if character then
		self.gameMode:ExecuteLaunchTimeline(self.gameMode.currentPlayerIndex, self.ballLauncher:GetLaunchOffset(), false)
	else
		print_error("BowlingGame:OnEventLaunch() character is nil, 会卡流程！self=", self)
	end
end

function BowlingGame:OnEventCreateBall()
	local ball = self.ballLauncher:GetBall()

	if ball then
		self.currentBall = ball
		self.gameState = GameState.ROLLING

		if self.camera then
			self.camera:StartFollow(ball)
		end

		self:PlaySound(LTConfig.PoiGameConfig.BowlingSound_BallLand)

		self.ballRollSound = self:PlaySound(LTConfig.PoiGameConfig.BowlingSound_BallRoll)

		if gClientUtils.NotNil(self.currentBall.gameObject) then
			local colliderSoundComp = self.currentBall.gameObject:GetOrAddComponent(typeof(LX6.Audio.PhysicsColliderSound))
			colliderSoundComp.soundId = 0
			local timer = Timer.New(function ()
				if gClientUtils.NotNil(colliderSoundComp) then
					colliderSoundComp.soundId = LTConfig.PoiGameConfig.BowlingSound_GutterBump
				end
			end, 1)

			timer:Start()
		end

		if self.ballRollSound and self.ballLauncher then
			local maxForce = self.ballLauncher.maxLaunchForce[self.ballLauncher.CurBallIndex]
			local minForce = self.ballLauncher.minLaunchForce[self.ballLauncher.CurBallIndex]
			local currentForce = self.ballLauncher.launchForce
			local forceRatio = 0

			if minForce < maxForce then
				forceRatio = (currentForce - minForce) / (maxForce - minForce)
			end

			local forcePercentage = forceRatio * 100

			self:SetSoundRTPCValue(self.ballRollSound, gSoundMgr.RTPCGroup.ObjectForceBar, forcePercentage)
		end
	end
end

function BowlingGame:OnEventAnimWalk1Begin()
	if self.ballLauncher then
		self.ballLauncher:BeginAnim()
	end
end

function BowlingGame:OnEventAnimWalkEnd()
	self.IsWalkEnd = true
end

function BowlingGame:OnEventAnimLaunchEnd(currentBall)
	if self.ballLauncher then
		self.ballLauncher:LaunchBall(currentBall)
	end

	self:OnEventCreateBall()

	self.IsLaunchEnd = true
end

function BowlingGame:OnEventAnimBackBegin(isSwitchTurn)
	self.IsBackEnd = false

	if self.ballLauncher then
		self.ballLauncher:BeginAnim()
	end

	local currentPlayer = self:GetCurrentPlayer()
	local character = self:GetCurrentCharacter()

	if currentPlayer == nil or character == nil then
		print_error("BowlingGame:OnEventAnimBackBegin() currentPlayer or character is nil, self=", self)

		return
	end

	self.camera:ResetCamera()

	if isSwitchTurn and self.gameMode.config.playerCount >= 2 then
		if currentPlayer.isSpare or currentPlayer.isStrike then
			local tlSceneType = TimelineScene.SWITCH_N_S

			if self.gameMode.isFirstSwitch then
				tlSceneType = TimelineScene.SWITCH_S
			end

			character:ExecuteTimeLine(tlSceneType, function ()
				self:OnEventAnimBackEnd()
			end)
		else
			local tlSceneType = TimelineScene.SWITCH_N

			if self.gameMode.isFirstSwitch then
				tlSceneType = TimelineScene.SWITCH
			end

			character:ExecuteTimeLine(tlSceneType, function ()
				self:OnEventAnimBackEnd()
			end)
		end
	elseif currentPlayer.isSpare or currentPlayer.isStrike then
		character:ExecuteTimeLine(TimelineScene.BACK_S, function ()
			self:OnEventAnimBackEnd()
		end)
	else
		character:ExecuteTimeLine(TimelineScene.BACK, function ()
			self:OnEventAnimBackEnd()
		end)
	end
end

function BowlingGame:OnEventAnimBackEnd()
	self.IsBackEnd = true

	BowlingMessageManager:SendMessage(gEventConstants.BOWLING_TECH_SUCCICON_HIDE)
	self.gameMode:OnEventAnimBackEnd()
end

function BowlingGame:SelectBall(BallIndex)
	self.ballLauncher:SelectBall(BallIndex)
	self.gameMode:SetCurrentPlayerBallIndex(BallIndex)
end

function BowlingGame:GetLauncherState()
	return self.ballLauncher:GetLauncherState()
end

function BowlingGame:GetIsNpc()
	local currentPlayer = self:GetCurrentPlayer()

	return currentPlayer and currentPlayer.isNPC
end

function BowlingGame:CheckBallAndPinsSettled()
	return self.currentBall and self.currentBall:UpdateAndCheckSettle()
end

function BowlingGame:CheckGameOver()
	return self.gameMode:CheckGameOver()
end

function BowlingGame:ClearScore()
	self.IsFirst = true
end

function BowlingGame:Settle()
	local allScores = {}

	for i = 1, self.gameMode.config.playerCount do
		allScores[i] = self.gameMode.players[i].totalScore
	end

	local key = "BowlingBestScore"
	local thisGameBestScore = allScores[1] or 0
	local bestScore = UnityEngine.PlayerPrefs.GetInt(key, 0)

	if bestScore < thisGameBestScore then
		UnityEngine.PlayerPrefs.SetInt(key, thisGameBestScore)

		bestScore = thisGameBestScore
	end

	local settleData = self.gameMode:GetSettleData()

	self:FinishTaskBowling(thisGameBestScore, bestScore, allScores, settleData)
	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
		isSuccess = settleData.winResult == true
	})
	self:ClearScore()
end

function BowlingGame:FinishTaskBowling(score, bestScore, allScores, settleData)
	local function callback(_)
		gPanelManager:CheckShow(gPanelId.MINI_GAMES_BOWLING_SETTLE_BG_PANEL, {
			score = score,
			bestScore = bestScore,
			allScores = allScores,
			title = settleData.title,
			exitCallback = function ()
				self:RetryGame(self)
			end,
			retryCallback = function ()
				self:RetryGame(self)
				gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_MODE_PANEL)
				coroutine.start(function ()
					coroutine.wait(0.05)
					self:ExecuteSelectMode(self.mode)
				end)
			end
		})
	end

	callback()
end

function BowlingGame:GameOver()
	if self.bGameOver then
		return
	end

	self.bGameOver = true

	print_debug("BowlingGame GameOver")

	if self.pinSetter then
		self.pinSetter:Destroy()

		self.pinSetter = nil
	end

	if self.ballLauncher then
		self.ballLauncher:Destroy()

		self.ballLauncher = nil
	end

	local vCam = self.timelineManager and self.timelineManager.virtualCamera

	if gClientUtils.NotNil(vCam) then
		vCam.gameObject:SetActive(false)
	end
end

function BowlingGame:ExitGame()
	self:CleanGame()
end

function BowlingGame:GetCurrentPlayer()
	return self.gameMode:GetCurrentPlayer()
end

function BowlingGame:GetPlayerCount()
	return self.gameMode.config.playerCount
end

function BowlingGame:SendRefreshViewMessage()
	local currentPlayer = self:GetCurrentPlayer()
	local messageData = BowlingMessageManager:BuildScoreMessage(currentPlayer, self.gameMode)

	BowlingMessageManager:SendMessage(gEventConstants.BOWLING_GAME_REFRESH_SCORE, messageData)

	self.dataSet.score = messageData
end

function BowlingGame:OnSyncZoneInfo(zoneInfo)
	print_debug("[BowlingGame] OnSyncZoneInfo called, gameMode exists: " .. tostring(self.gameMode ~= nil))

	self.zoneInfo = zoneInfo

	self:OnSyncZoneState(zoneInfo.ZoneState)

	if self.gameMode and self.gameMode.OnSyncZoneInfo then
		print_debug("[BowlingGame] OnSyncZoneInfo: calling gameMode:OnSyncZoneInfo")
		self.gameMode:OnSyncZoneInfo(zoneInfo)
	else
		print_debug("[BowlingGame] OnSyncZoneInfo: ERROR - no gameMode or OnSyncZoneInfo method")
	end
end

function BowlingGame:OnSyncZoneState(state)
	if self.args.zoneInfo == nil then
		return
	end

	self.args.zoneInfo.ZoneState = state

	if state == GameGroundZoneState.Display then
		-- Nothing
	elseif state == GameGroundZoneState.GameStart then
		-- Nothing
	elseif state == GameGroundZoneState.GameOver then
		-- Nothing
	elseif state == GameGroundZoneState.Dispose then
		if not self.bGameOver then
			self:GameOver()
		else
			gBowlingGameManager:DestroyGame()
		end
	end

	if self.gameMode and self.gameMode.OnSyncZoneState then
		self.gameMode:OnSyncZoneState(state)
	end
end

function BowlingGame:CheckResultIsSuccess()
	return self.isWin
end

function BowlingGame:ShowResultPanel(isWin)
	self.isWin = isWin

	BowlingGame.base.ShowResultPanel(self)
end

function BowlingGame:CleanGame()
	BowlingGame.base.SetSceneOtherNodesVisible(self, true)
	self:StopCoroutineCamera()

	self.stateCoroutine = coroutine.stop(self.stateCoroutine)
	self.loadOp = gResourceManager:UnloadAssetLoadOp(self.loadOp)

	if self.characters then
		for _, char in ipairs(self.characters) do
			char:GameOver()
			char:Destroy()
		end

		self.characters = nil
	end

	if self.pinSetter then
		self.pinSetter:Destroy()

		self.pinSetter = nil
	end

	if self.ballLauncher then
		self.ballLauncher:Destroy()

		self.ballLauncher = nil
	end

	if self.camera then
		self.camera:Destroy()

		self.camera = nil
	end

	if self.timelineManager then
		self.timelineManager:Destroy()

		self.timelineManager = nil
	end

	if gClientUtils.NotNil(self.SceneNodeGo) then
		gBowlingGameManager:Destroy(self.SceneNodeGo)

		self.SceneNodeGo = nil
	end

	self:StopAllSounds()
	self:ClosePanel()
	gBowlingGameManager:SendSignalToGadget("ExitBowling")
end

function BowlingGame:ClosePanel()
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_MAIN_PANEL)
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_MODE_PANEL)
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_TECH_PINS_PANEL)
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_SCORE_SINGLE_PANEL)
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_SCORE_BATTLE_PANEL)
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_SCORE_TECH_PANEL)
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_SETTLE_SINGLE_PANEL)
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_SETTLE_BATTLE_PANEL)
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_SETTLE_TECH_PANEL)
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_SETTLE_BG_PANEL)
end

function BowlingGame:PlaySound(soundId)
	local soundData = gSoundMgr:CreateSoundData(soundId)

	if soundData then
		local nid = gSoundMgr:PlaySoundByData(soundData)

		if nid then
			table.insert(self.activeSounds, nid)
		end

		return nid
	end
end

function BowlingGame:SetSoundRTPCValue(nid, key, value)
	local soundData = gSoundMgr:GetSoundDataByNid(nid)

	if soundData then
		soundData:SetRTPCValue(key, value)
	end
end

function BowlingGame:PlaySoundDelay(soundId, delayTime, callback)
	local co = nil
	co = coroutine.start(function ()
		coroutine.wait(delayTime)

		local nid = self:PlaySound(soundId)

		if callback then
			callback(nid)
		end

		array.remove(self.soundCoroutines, co)
	end)

	table.insert(self.soundCoroutines, co)
end

function BowlingGame:StopSound(nid)
	if nid == nil or nid == 0 then
		return
	end

	gSoundMgr:StopSoundByNid(nid)
	array.remove(self.activeSounds, nid)
end

function BowlingGame:StopAllSounds()
	for _, nid in ipairs(self.activeSounds) do
		gSoundMgr:StopSoundByNid(nid)
	end

	self.activeSounds = {}

	for _, co in ipairs(self.soundCoroutines) do
		coroutine.stop(co)
	end

	self.soundCoroutines = {}
end
