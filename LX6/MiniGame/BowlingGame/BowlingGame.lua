-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingGame.lua
-- Decompiled from: 00644_BowlingGame.lua_eed7ca7f084a.luajit

gBowlingGame = DefClass("BowlingGame", gBowlingGame, gBaseMiniGame)
local BowlingGame = gBowlingGame
local Config = require("LX6/MiniGame/BowlingGame/BowlingConfig").Launcher
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local GameState = BowlingConstants.GameState
local GameMode = BowlingConstants.GameMode
local TimelineScene = BowlingConstants.TimelineScene
local LifecycleState = BowlingConstants.LifecycleState
local DataSet = require("LX6/DataBind/DataSet")
local BowlingBallUtils = require("LX6/MiniGame/BowlingGame/BowlingBallUtils")
local GameGroundZoneState = UX.Game.GameGroundZoneState

BowlingGame.Initialize = function(self, args)
	self:InitData(args)

	self.pinSetter = gBowlingPinSetter.new(self)
	self.ballLauncher = gBowlingBallLauncher.new(self)
	self.camera = gBowlingCamera.new(self)
	self.timelineManager = gBowlingGameManager.gameInstance.cacheTimeline or gBowlingTimelineClipManager.new()

	self:SetSceneOtherNodesVisible(false)

	self.onReturnTimelineBegin = self:CreateAction(self.OnReturnTimelineBegin)

	gMessageManager:AddMessageListener(gEventConstants.MINIGAME_BOWLING_BACK_BEGIN, self.onReturnTimelineBegin)
end

BowlingGame.BeforeInitialize = function(self)
end

BowlingGame.OnReturnTimelineBegin = function(self)
	self.IsEnterTimelineEnd = false
	self.IsReturnTimelineEnd = false
end

BowlingGame.InitData = function(self, args)
	self.args = args
	self.linkPlayId = gLinkManager.targetPlayId
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
	self.IsEnterTimelineEnd = false
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

BowlingGame.GetCurrentCharacter = function(self)
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

BowlingGame.GetCharacter = function(self, playerIndex)
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

BowlingGame.InitBowlingScene_Async = function(self)
	local scenePath = Config.prefabPaths.scene
	local loadOp = gResourceManager:LoadAssetAsync(scenePath, typeof(UnityEngine.GameObject))

	coroutine.yield(loadOp)

	if self.hasDestroy then
		gResourceManager:UnloadAssetLoadOp(loadOp)

		return
	end

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

	slot6 = self.pinSetter

	slot6:SetSceneNode(bowlingSceneNodeGo)

	self.scenePoints = {
		virtualCamera = virtualCamera,
		playerPoint = bowlingSceneNodeGo.transform:Find("PivotNode/PlayerPoint"),
		PlayerPointBack = bowlingSceneNodeGo.transform:Find("PivotNode/PlayerPointBack"),
		pinPoint = bowlingSceneNodeGo.transform:Find("PivotNode/PinPoint"),
		endVirtualCameraGo = bowlingSceneNodeGo.transform:Find("EndVirtualCamera").gameObject
	}

	self.timelineManager:Init(bowlingSceneNodeGo, virtualCamera, self.scenePoints.playerPoint, true, self)
end

BowlingGame.InitCharactersWithScenePoints_Async = function(self, agentId, npcUnit)
	if not self.scenePoints then
		print_debug("Warning: Scene points not initialized")

		return false
	end

	if self.characters then
		for _, char in ipairs(self.characters) do
			char.Destroy(char)
		end
	end

	self.characters = {}
	local playerCharacter = gBowlingCharacter.Create_Async({
		["\\x8f8!&}\\x8fh\\xd73\\xaf\\xa1"] = 1,
		sceneNode = self.SceneNodeGo,
		pinPoint = self.scenePoints.pinPoint,
		playerPoint = self.scenePoints.playerPoint,
		virtualCamera = self.scenePoints.virtualCamera,
		game = self
	})

	table.insert(self.characters, playerCharacter)
	self.timelineManager:RegisterPlayerUnit(1, playerCharacter.baseUnit)

	if self.gameMode.config.playerCount ~= 1 then
		local timelineLoadToken = gWaitToken.Create()
		slot5 = self.timelineManager

		slot5:LoadAndPlayTimeline(1, function (success)
			timelineLoadToken:SetResult(success)
		end)
		coroutine.yield(timelineLoadToken)

		if not timelineLoadToken.result then
			print_error("保龄球 主Timeline加载失败，销毁游戏")
			gBowlingGameManager:DestroyGame()

			return false
		end

		return true
	end

	local serverAgentInstanceId = ulong.new(0, 0)

	if gBowlingGameManager.gameInstance and gBowlingGameManager.gameInstance.zoneInfo then
		local participantInfos = gBowlingGameManager.gameInstance.zoneInfo.ParticipantInfos or {}
		local npcParticipantInfo = participantInfos[2] or {}
		serverAgentInstanceId = npcParticipantInfo.AgentInstanceId or ulong.new(0, 0)
		gBowlingGameManager.gameInstance.npcAIAgentInfo = npcParticipantInfo.AIAgentInfo
	end

	local npcCharacter = gBowlingCharacter.Create_Async({
		["\\x8f8!&}\\x8fh\\xd73\\xaf\\xa1"] = 2,
		sceneNode = self.SceneNodeGo,
		pinPoint = self.scenePoints.pinPoint,
		playerPoint = self.scenePoints.playerPoint,
		virtualCamera = self.scenePoints.virtualCamera,
		game = self,
		npcId = self.args.agentTemplateId,
		agentId = agentId,
		npcUnit = npcUnit,
		needDestroyNpcUnit = self.args.needDestroyNpcUnit,
		serverAgentInstanceId = serverAgentInstanceId
	})

	table.insert(self.characters, npcCharacter)

	slot6 = self.timelineManager

	slot6:RegisterPlayerUnit(2, npcCharacter.baseUnit)

	local timelineLoadToken = gWaitToken.Create()
	slot7 = self.timelineManager

	slot7:LoadAndPlayTimeline(2, function (success)
		timelineLoadToken:SetResult(success)
	end)
	coroutine.yield(timelineLoadToken)

	if not timelineLoadToken.result then
		print_error("保龄球 主Timeline加载失败，销毁游戏")
		gBowlingGameManager:DestroyGame()

		return false
	end

	return true
end

BowlingGame.InitCoroutine = function(self)
	slot1 = gCoroutineManager
	self.stateCoroutine = slot1:StartCoroutine(function ()
		while true do
			coroutine.yield(gWaitableUtils.WaitTime(0.1))

			if self.gameState ~= GameState.GAMEOVER then
				return
			end

			if self.gameState == GameState.MODE then
				self.gameMode:ProcessGameState()
			end
		end
	end)
end

BowlingGame.ExecuteShootKeyDown = function(self)
	if self.gameState == GameState.READY then
		return false
	end

	return self.ballLauncher:StartCharging()
end

BowlingGame.ExecuteShootKeyLongPress = function(self)
	if self.gameState == GameState.READY then
		return 0
	end

	return self.ballLauncher:UpdateCharging()
end

BowlingGame.ExecuteLongPressPowerAuto = function(self)
	if self.gameState == GameState.READY then
		return 0
	end

	return self.ballLauncher:UpdateChargingPowerAuto()
end

BowlingGame.ExecuteLongPressPos = function(self, dir)
	if self.gameState == GameState.READY then
		return -1
	end

	return self.ballLauncher:UpdateChargingPos(dir)
end

BowlingGame.SetChargingPos = function(self, launchOffset, posRatio)
	if self.gameState == GameState.READY then
		return -1
	end

	self.ballLauncher:SetChargingPos(launchOffset, posRatio)
end

BowlingGame.ExecutePressRot = function(self, RotIndex)
	if self.gameState == GameState.THROWING then
		return 0
	end

	return self.ballLauncher:UpdateRotIndex(RotIndex)
end

BowlingGame.ExecuteLongPressDirAuto = function(self)
	if self.gameState == GameState.READY then
		return 0
	end

	return self.ballLauncher:UpdateChargingDirAuto()
end

BowlingGame.ExecuteShootKeyUp = function(self)
	self.ballLauncher:HandleAimConfirm()
end

BowlingGame.ExecuteSelectMode_Async = function(self, mode)
	if gBowlingGameManager.gameInstance.zoneInfo.GameType ~= UX.Game.BowlingGameType.DoubleAI then
		mode = GameMode.NPC_BATTLE
	end

	mode = gBowlingGameManager.debugMode or mode
	self.mode = mode
	local createModeFunc = {
		[GameMode.SINGLE] = self.ExecuteSelectModeSingle_Async,
		[GameMode.NPC_BATTLE] = self.ExecuteSelectModeBattle_Async,
		[GameMode.TECHNICAL] = self.ExecuteSelectModeTech_Async,
		[GameMode.ONLINE_BATTLE] = self.ExecuteSelectModeOnline_Async,
		[GameMode.RIDE_NPC_BATTLE] = self.ExecuteSelectModeBattle_Async
	}

	if createModeFunc[mode] then
		return createModeFunc[mode](self)
	else
		print_error("Unknown game mode: " .. mode)

		return false
	end
end

BowlingGame.ExecuteSelectModeSingle_Async = function(self)
	self.gameMode = gBowlingModeClassic.new(self, {
		["i\t\\xb19\\xf9p\r\\xacv\t6&}\\xa4\\xf0\"\\xdc\\xf4"] = 1,
		["\\x8f8!&}\\x8fb\\xd6\"\\xa4\\xad"] = 1,
		["NFtO\\+"] = 3
	})

	if self.pinSetter then
		self.pinSetter:ResetPins(true)
	end

	self.gameMode:InitPlayers()

	if not self:InitCharactersWithScenePoints_Async() then
		return false
	end

	self:ShowMainPanel(gPanelId.MINI_GAMES_BOWLING_SCORE_SINGLE_PANEL)

	self.gameState = GameState.INIT

	gBowlingGameManager:SetLifecycleState(LifecycleState.RUNNING)

	return true
end

BowlingGame.ExecuteSelectModeBattle_Async = function(self)
	self.gameMode = gBowlingModeClassic.new(self, {
		["i\t\\xb19\\xf9p\r\\xacv\t6&}\\xa4\\xf0\"\\xdc\\xf4"] = 1,
		["\\x8f8!&}\\x8fb\\xd6\"\\xa4\\xad"] = 2,
		["NFtO\\+"] = 3
	})

	self.gameMode:InitPlayers()

	if self.pinSetter then
		self.pinSetter:ResetPins(true)
	end

	if not self.InitCharactersWithScenePoints_Async(self, nil, gBowlingGameManager.gameInstance.npcUnit) then
		return false
	end

	self:ShowMainPanel(gPanelId.MINI_GAMES_BOWLING_SCORE_BATTLE_PANEL)

	self.gameState = GameState.INIT

	gBowlingGameManager:SetLifecycleState(LifecycleState.RUNNING)

	return true
end

BowlingGame.ExecuteSelectModeTech_Async = function(self)
	self.gameMode = gBowlingModeTech.new(self, {
		["i\t\\xb19\\xf9p\r\\xacv\t6&}\\xa4\\xf0\"\\xdc\\xf4"] = 1,
		["\\x8f8!&}\\x8fb\\xd6\"\\xa4\\xad"] = 1,
		["NFtO\\+"] = 3
	})

	self.gameMode:InitPlayers()

	if not self:InitCharactersWithScenePoints_Async() then
		return false
	end

	if self.pinSetter then
		self.pinSetter:ResetPins(true)
	end

	self:ShowMainPanel(gPanelId.MINI_GAMES_BOWLING_SCORE_TECH_PANEL)

	self.gameState = GameState.INIT

	gBowlingGameManager:SetLifecycleState(LifecycleState.RUNNING)

	return true
end

BowlingGame.ExecuteSelectModeOnline_Async = function(self)
	self.gameMode = gBowlingModeOnline.new(self, {
		["i\t\\xb19\\xf9p\r\\xacv\t6&}\\xa4\\xf0\"\\xdc\\xf4"] = 1,
		["\\x8f8!&}\\x8fb\\xd6\"\\xa4\\xad"] = 2,
		["NFtO\\+"] = 3
	})

	if not self.InitCharactersWithScenePoints_Async(self) then
		return false
	end

	self.pinSetter:ResetPins(true)
	self:ShowMainPanel(gPanelId.MINI_GAMES_BOWLING_SCORE_BATTLE_PANEL)

	self.gameState = GameState.INIT

	gBowlingGameManager:SetLifecycleState(LifecycleState.RUNNING)

	return true
end

BowlingGame.ExecuteTechPinsSelected = function(self, index)
	gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_TECH_PINS_PANEL)
	gMessageManager:SendMessage(gEventConstants.ON_BOWLING_BALL_INDEX_CHANGE, {
		ballIndex = self.ballLauncher.CurBallIndex
	})
	self:SelectTechPattern(index)
end

BowlingGame.SelectTechPattern = function(self, patternIndex)
	if self.gameMode and self.gameMode.SelectPattern then
		return self.gameMode:SelectPattern(patternIndex)
	end

	return false
end

BowlingGame.SetGameState = function(self, state)
	self.gameState = state
end

BowlingGame.SetCurrentBall = function(self, ball)
	self.currentBall = ball
end

BowlingGame.SetIsLaunchEnd = function(self, value)
	self.IsLaunchEnd = value
end

BowlingGame.PlayLaunchTimeline = function(self)
	local character = self.GetCurrentCharacter(self)

	if character then
		self.gameMode:ExecuteLaunchTimeline(self.gameMode.currentPlayerIndex, self.ballLauncher:GetLaunchOffset(), false)
	else
		print_error("BowlingGame:PlayLaunchTimeline() character is nil, 会卡流程！self=", self)
	end
end

BowlingGame.OnEnterTimelineEnd = function(self)
	self.IsEnterTimelineEnd = true
end

BowlingGame.GetCurrentLaunchForcePercentage = function(self)
	if not self.ballLauncher then
		return 0
	end

	local maxForce = self.ballLauncher.maxLaunchForce[self.ballLauncher.CurBallIndex]
	local minForce = self.ballLauncher.minLaunchForce[self.ballLauncher.CurBallIndex]
	local currentForce = self.ballLauncher.launchForce
	local forceRatio = 0

	if minForce >= maxForce then
		forceRatio = (currentForce - minForce) / (maxForce - minForce)
	end

	return forceRatio * 100
end

BowlingGame.StartBallLaunchEffects = function(self, sceneItemId, forcePercentage, followBall, canRestoreColliderSound)
	if self.camera and followBall then
		self.camera:StartFollow(followBall)
	end

	self:PlaySound(LTConfig.PoiGameConfig.BowlingSound_BallLand)

	local rollSoundId = self:PlaySound(LTConfig.PoiGameConfig.BowlingSound_BallRoll)

	BowlingBallUtils:SetColliderSound(sceneItemId, 0)

	local timer = Timer.New(function ()
		if canRestoreColliderSound ~= nil or canRestoreColliderSound() then
			BowlingBallUtils:SetColliderSound(sceneItemId, LTConfig.PoiGameConfig.BowlingSound_GutterBump)
		end
	end, 1)

	timer:Start()

	if rollSoundId and forcePercentage == nil then
		self.SetSoundRTPCValue(self, rollSoundId, gSoundMgr.RTPCGroup.ObjectForceBar, forcePercentage)
	end

	return rollSoundId
end

BowlingGame.BroadcastRemoteBallObserveStart = function(self, sceneItemId, forcePercentage)
	if not gBowlingGameManager:IsOnlineGame() or not self.gameMode:ShouldBroadcastClientInfo() then
		return
	end

	gBowlingGameManager:BroadcastBowlingClientInfo(BowlingConstants.SyncDataType.RemoteBallObserveStart, {
		sceneItemId = {
			ulong.tonum2(sceneItemId)
		},
		forcePercentage = forcePercentage
	})
end

BowlingGame.PlayReturnTimeline = function(self, isSwitchTurn)
	self.IsReturnTimelineEnd = false

	if self.ballLauncher then
		self.ballLauncher:BeginAnim()
	end

	local currentPlayer = self.gameMode:GetCurrentPlayer()
	local character = self:GetCurrentCharacter()

	if currentPlayer ~= nil or character ~= nil then
		print_error("BowlingGame:PlayReturnTimeline() currentPlayer or character is nil, self=", self)

		return
	end

	self.camera:ResetCamera()

	if isSwitchTurn and self.gameMode.config.playerCount > 2 then
		if currentPlayer.isSpare or currentPlayer.isStrike then
			local tlSceneType = TimelineScene.SWITCH_N_S

			if self.gameMode.isFirstSwitch then
				tlSceneType = TimelineScene.SWITCH_S
			end

			character.ExecuteTimeLine(character, tlSceneType, function ()
				self:OnReturnTimelineEnd()
			end)
		else
			local tlSceneType = TimelineScene.SWITCH_N

			if self.gameMode.isFirstSwitch then
				tlSceneType = TimelineScene.SWITCH
			end

			character.ExecuteTimeLine(character, tlSceneType, function ()
				self:OnReturnTimelineEnd()
			end)
		end
	elseif currentPlayer.isSpare or currentPlayer.isStrike then
		character.ExecuteTimeLine(character, TimelineScene.BACK_S, function ()
			self:OnReturnTimelineEnd()
		end)
	else
		character.ExecuteTimeLine(character, TimelineScene.BACK, function ()
			self:OnReturnTimelineEnd()
		end)
	end
end

BowlingGame.OnReturnTimelineEnd = function(self)
	self.IsReturnTimelineEnd = true

	gMessageManager:SendMessage(gEventConstants.BOWLING_TECH_SUCCICON_HIDE)
	self.gameMode:OnReturnTimelineEnd()
end

BowlingGame.Settle = function(self)
	local allScores = {}

	for i = 1, self.gameMode.config.playerCount do
		allScores[i] = self.gameMode.players[i].totalScore
	end

	local reportMyScore = allScores[1] or 0
	local reportNpcScore = allScores[2] or 0

	if self.mode ~= GameMode.TECHNICAL then
		reportMyScore = #self.gameMode.completedPatterns
	end

	gBowlingGameManager:RecordAllBowlingScoreAndDrop(self.mode, self.args.npcCultivationId, reportMyScore, reportNpcScore)

	local key = "BowlingBestScore"
	local thisGameBestScore = allScores[1] or 0
	local bestScore = UnityEngine.PlayerPrefs.GetInt(key, 0)

	if bestScore >= thisGameBestScore then
		UnityEngine.PlayerPrefs.SetInt(key, thisGameBestScore)

		bestScore = thisGameBestScore
	end

	local settleData = self.gameMode:GetSettleData()

	self:FinishTaskBowling(thisGameBestScore, bestScore, allScores, settleData)
	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
		isSuccess = settleData.winResult ~= true
	})

	self.IsFirst = true
end

BowlingGame.FinishTaskBowling = function(self, score, bestScore, allScores, settleData)
	if gBowlingGameManager:IsMatchGame() then
		return
	end

	local callback = function(_)
		gPanelManager:CheckShow(gPanelId.MINI_GAMES_BOWLING_SETTLE_BG_PANEL, {
			score = score,
			bestScore = bestScore,
			allScores = allScores,
			exitCallback = function ()
				self:RetryGame(self)
			end,
			retryCallback = function ()
				self:RetryGame(self)
				gPanelManager:Close(gPanelId.MINI_GAMES_BOWLING_MODE_PANEL)
				gCoroutineManager:StartCoroutine(function ()
					coroutine.yield(gWaitableUtils.WaitTime(0.05))
					self:ExecuteSelectMode(self.mode)
				end)
			end
		})
	end

	callback()
end

BowlingGame.GameOver = function(self)
	if self.bGameOver then
		return
	end

	self.bGameOver = true

	self:StopAllSounds()
	gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_OVER)

	local vCam = self.timelineManager and self.timelineManager.virtualCamera

	if gClientUtils.NotNil(vCam) then
		vCam.gameObject:SetActive(false)
	end
end

BowlingGame.ExitGame = function(self)
	self.CleanGame(self)
end

BowlingGame.SendRefreshViewMessage = function(self)
	local currentPlayer = self.gameMode:GetCurrentPlayer()
	local messageData = {
		totalScore = currentPlayer.totalScore or 0,
		currentFrame = currentPlayer.currentFrame or 1,
		currentThrow = currentPlayer.currentThrow or 1,
		knockedPins = currentPlayer.knockedPins or 0,
		isSplit = currentPlayer.isSplit or false,
		frameScores = currentPlayer.frameScores or {},
		frameSpare = currentPlayer.frameSpare or {},
		frameCompleted = currentPlayer.frameCompleted or {},
		currentPlayerIndex = self.gameMode.currentPlayerIndex or 1,
		playerCount = self.gameMode.config.playerCount or 1
	}

	gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_REFRESH_SCORE, messageData)

	self.dataSet.score = messageData
end

BowlingGame.OnSyncZoneInfo = function(self, zoneInfo)
	print_debug("[BowlingGame] OnSyncZoneInfo called, gameMode exists: " .. tostring(self.gameMode == nil))

	self.zoneInfo = zoneInfo

	self:OnSyncZoneState(zoneInfo.ZoneState)

	if self.gameMode and self.gameMode.OnSyncZoneInfo then
		print_debug("[BowlingGame] OnSyncZoneInfo: calling gameMode:OnSyncZoneInfo")
		self.gameMode:OnSyncZoneInfo(zoneInfo)
	else
		print_debug("[BowlingGame] OnSyncZoneInfo: ERROR - no gameMode or OnSyncZoneInfo method")
	end
end

BowlingGame.OnSyncZoneState = function(self, state)
	if self.args.zoneInfo ~= nil then
		return
	end

	self.args.zoneInfo.ZoneState = state

	if state ~= GameGroundZoneState.Display then
		-- Nothing
	elseif state ~= GameGroundZoneState.GameStart then
		-- Nothing
	elseif state ~= GameGroundZoneState.GameOver then
		-- Nothing
	elseif state ~= GameGroundZoneState.Dispose then
		if not self.bGameOver then
			self.GameOver(self)
		else
			gBowlingGameManager:DestroyGame()
		end
	end

	if self.gameMode and self.gameMode.OnSyncZoneState then
		self.gameMode:OnSyncZoneState(state)
	end
end

BowlingGame.CheckResultIsSuccess = function(self)
	return self.isWin
end

BowlingGame.ShowResultPanel = function(self, isWin)
	self.isWin = isWin

	BowlingGame.base.ShowResultPanel(self)
end

BowlingGame.CleanupAndDestroy = function(self)
	self.hasDestroy = true

	if self.onReturnTimelineBegin then
		gMessageManager:RemoveMessageListener(gEventConstants.MINIGAME_BOWLING_BACK_BEGIN, self.onReturnTimelineBegin)

		self.onReturnTimelineBegin = nil
	end

	if self.stateCoroutine then
		gCoroutineManager:CancelCoroutine(self.stateCoroutine)

		self.stateCoroutine = nil
	end

	if self.waitSceneCoroutine then
		gCoroutineManager:CancelCoroutine(self.waitSceneCoroutine)

		self.waitSceneCoroutine = nil
	end

	if self.gameMode then
		self.gameMode:Destroy()
	end

	gBowlingGameManager.gameInstance.isPlayAgain = nil

	if self.characters then
		for _, char in ipairs(self.characters) do
			if char and not char.hasDestroy then
				char.GameOver(char)
				char.Destroy(char)
			end
		end

		self.characters = nil
	end

	if self.pinSetter and not self.pinSetter.hasDestroy then
		self.pinSetter:Destroy()
	end

	self.pinSetter = nil

	if self.ballLauncher and not self.ballLauncher.hasDestroy then
		self.ballLauncher:Destroy()
	end

	self.ballLauncher = nil

	if self.camera then
		self.camera:Destroy()
	end

	self.camera = nil
	local preserveTimelineOnce = gBowlingGameManager.gameInstance.cacheTimeline ~= self.timelineManager and gBowlingGameManager.gameInstance.bPreserveTimelineOnce

	if self.timelineManager and not preserveTimelineOnce then
		self.timelineManager:Destroy()
	end

	self.timelineManager = nil
	self.loadOp = gResourceManager:UnloadAssetLoadOp(self.loadOp)

	if gClientUtils.NotNil(self.SceneNodeGo) then
		gBowlingGameManager:Destroy(self.SceneNodeGo)
	end

	self.SceneNodeGo = nil

	self.StopAllSounds(self)
	self.ClosePanel(self)
	self.SetSceneOtherNodesVisible(self, true)
end

BowlingGame.CleanGame = function(self)
	self.CleanupAndDestroy(self)
end

BowlingGame.ShowMainPanel = function(self, scorePanelId)
	local data = {
		showPanelId = scorePanelId
	}

	gPanelManager:CheckShow(gPanelId.MINI_GAMES_BOWLING_MAIN_PANEL, data)
end

BowlingGame.ClosePanel = function(self)
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
	gPanelManager:Close(gPanelId.BOWLING_TEACH_PANEL)
end

BowlingGame.PlaySound = function(self, soundId)
	local soundData = gSoundMgr:CreateSoundData(soundId)

	if soundData then
		local nid = gSoundMgr:PlaySoundByData(soundData)

		if nid then
			table.insert(self.activeSounds, nid)
		end

		return nid
	end
end

BowlingGame.SetSoundRTPCValue = function(self, nid, key, value)
	local soundData = gSoundMgr:GetSoundDataByNid(nid)

	if soundData then
		soundData.SetRTPCValue(soundData, key, value)
	end
end

BowlingGame.StopSound = function(self, nid)
	if nid ~= nil or nid ~= 0 then
		return
	end

	gSoundMgr:StopSoundByNid(nid)
	array.remove(self.activeSounds, nid)
end

BowlingGame.StopAllSounds = function(self)
	for _, nid in ipairs(self.activeSounds) do
		gSoundMgr:StopSoundByNid(nid)
	end

	self.activeSounds = {}

	for _, co in ipairs(self.soundCoroutines) do
		gCoroutineManager:CancelCoroutine(co)
	end

	self.soundCoroutines = {}
end

BowlingGame.SetEndVCamActive = function(self, active)
	if gClientUtils.NotNil(self.scenePoints.endVirtualCameraGo) then
		self.scenePoints.endVirtualCameraGo:SetActive(active)
	end
end
