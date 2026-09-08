-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BowlingGameMainPanelStore.lua
-- Decompiled from: 01681_BowlingGameMainPanelStore.lua_8d9003df3bd3.luajit

C_BowlingGameMainPanelStore = DefClass("C_BowlingGameMainPanelStore", C_BowlingGameMainPanelStore, C_StoreGroup)
GroupName2Class.BowlingGameMainPanelStore = C_BowlingGameMainPanelStore
local M = C_BowlingGameMainPanelStore
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local LaunchState = BowlingConstants.LaunchState
local GameMode = BowlingConstants.GameMode
local Config = require("LX6/MiniGame/BowlingGame/BowlingConfig").Launcher
local PoiGameConfig = LTConfig.PoiGameConfig
local MaxRotationLevel = 5
local RotationIndicators = {
	left = {
		"\\xe9\\xd4\\xa0",
		"\\xe9\\xd4\\xa3",
		"\\xe9\\xd4\\xa2",
		"\\xe9\\xd4\\xa5",
		"\\xe9\\xd4\\xa4"
	},
	right = {
		"\\xe9\\xd4\\xa0",
		"\\xe9\\xd4\\xa3",
		"\\xe9\\xd4\\xa2",
		"\\xe9\\xd4\\xa5",
		"\\xe9\\xd4\\xa4"
	}
}
local RotationConfig = {
	right = {
		["\\xbf\\xb8\\xb8K0\\xf7>"] = "\\x9d3%\\xb7\\x8f\\xf1\\xd1ҧ\\xe2\\xeb\\xeax\\xe8\\xf8\\xb0\\xa0\\x8d%\\x96\\xf4\\xdcڹ\\xf4",
		["\\xa8\\xbd\\xbbD?\\xf36"] = "\\xd8 +֍\\xac˩\\x86腞Џ\\x845Ï%\\x97\\xb6\\x9a\\xde>\\xd5",
		["GN~lM\n6"] = 1
	},
	left = {
		["\\xbf\\xb8\\xb8K0\\xf7>"] = "\\x9d3%\\xb7\\x8f\\xf1\\xd1ҧ\\xe2\\xeb\\xeax\\xe8\\xf8\\xb0\\xa0\\x8d%\\x96\\xf4\\xc2ڹ\\xf4",
		["\\xa8\\xbd\\xbbD?\\xf36"] = "\\xd8 +֍\\xac˩\\x86腞Џ\\x845Ï%\\x97\\xb6\\x9a\\xde>\\xcb",
		["GN~lM\n6"] = -1
	}
}

M.OnAwake = function(self)
	self.bindData.rightStick.luaGamePadInputChanged = self.CreateAction(self, "OnRightStickInputChanged")
	self.bindData.leftStick.luaGamePadInputChanged = self.CreateAction(self, "OnLeftStickInputChanged")
	self.bindData.BtnSpace.luaPress = self.CreateAction(self, "LaunchNextState")
	self.bindData.BtnLeftClick.luaPress = self.CreateAction(self, "LaunchNextState")
	self.bindData.BtnF.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.BtnUp.luaClick = self.CreateAction(self, "OnButtonUpClick")
	self.bindData.BtnDown.luaClick = self.CreateAction(self, "OnButtonDownClick")
	self.bindData.BallPosBtnRight.luaPress = self.CreateAction(self, "BallPosBtnRightOnPress")
	self.bindData.BallPosBtnRight.luaRelease = self.CreateAction(self, "BallPosBtnRightOnRelease")
	self.bindData.BallPosBtnLeft.luaPress = self.CreateAction(self, "BallPosBtnLeftOnPress")
	self.bindData.BallPosBtnLeft.luaRelease = self.CreateAction(self, "BallPosBtnLeftOnRelease")
	self.bindData.BtnPRight.luaPress = self.CreateAction(self, "OnBtnPRightPress")
	self.bindData.BtnPRight.luaRelease = self.CreateAction(self, "OnBtnPRightRelease")
	self.bindData.BtnPLeft.luaPress = self.CreateAction(self, "OnBtnPLeftPress")
	self.bindData.BtnPLeft.luaRelease = self.CreateAction(self, "OnBtnPLeftRelease")
	self.bindData.slider.luaValueChanged = self.CreateAction(self, "OnSliderValueChanged")
	self.bindData.teachBtn.luaClick = self.CreateAction(self, "OnTeachBtnClick")
	self.hasDestroy = nil
end

M.OnStart = function(self)
	self.lastStandingPins = nil
	self.isClosed = false
	self.IsExit = false
	self.nextSyncPosSnapTime = nil
	self.ballPosLoopNid = nil
	self.velocityLoopNid = nil
	self.ballIndex = math.ceil(#Config.prefabPaths.balls / 2)
	self.game = gBowlingGameManager.currentGame
	self.gameMode = self.game.gameMode

	self.InitMessages(self)
end

M.StartBallPosLoopSound = function(self)
	if self.ballPosLoopNid then
		return
	end

	self.ballPosLoopNid = gSoundMgr:PlaySoundByTid(PoiGameConfig.BowlingSound_BallPos)
end

M.StopBallPosLoopSound = function(self)
	gSoundMgr:StopSoundByNid(self.ballPosLoopNid)

	self.ballPosLoopNid = nil
end

M.StartVelocityLoopSound = function(self)
	if self.velocityLoopNid then
		return
	end

	self.velocityLoopNid = gSoundMgr:PlaySoundByTid(PoiGameConfig.BowlingSound_Velocity)
end

M.StopVelocityLoopSound = function(self)
	gSoundMgr:StopSoundByNid(self.velocityLoopNid)

	self.velocityLoopNid = nil
end

M.StopAllSounds = function(self)
	self.StopBallPosLoopSound(self)
	self.StopVelocityLoopSound(self)
end

M.OnGameOver = function(self)
	self.StopAllSounds(self)
end

M.IsBallPosMoveAtEdge = function(self, isRight, posRatio)
	if isRight then
		return posRatio < 1
	end

	return posRatio > 0
end

M.GetBallPosRatio = function(self)
	local launcher = self.game.ballLauncher
	local denom = Config.maxLaunchOffset - Config.minLaunchOffset

	if denom ~= 0 then
		return 0.5
	end

	return Mathf.Clamp01((launcher.launchOffset - Config.minLaunchOffset) / denom)
end

M.StartBallPosLoopSoundByDirection = function(self, isRight)
	local posRatio = self.GetBallPosRatio(self)

	if self.IsBallPosMoveAtEdge(self, isRight, posRatio) then
		self.StopBallPosLoopSound(self)

		return
	end

	self.StartBallPosLoopSound(self)
end

M.RefreshBallPosLoopSoundByMoveResult = function(self, isRight, posRatio)
	if posRatio >= 0 then
		self.StopBallPosLoopSound(self)

		return
	end

	if self.IsBallPosMoveAtEdge(self, isRight, posRatio) then
		self.StopBallPosLoopSound(self)
	elseif self.launchState ~= LaunchState.POS then
		self.StartBallPosLoopSound(self)
	else
		self.StopBallPosLoopSound(self)
	end
end

M.PlayRotationLevelSound = function(self, absRotIndex)
	if absRotIndex ~= nil or absRotIndex < 0 then
		return
	end

	if absRotIndex < 2 then
		gSoundMgr:PlaySoundByTid(PoiGameConfig.BowlingSound_BallRot_Lv1)
	elseif absRotIndex < 4 then
		gSoundMgr:PlaySoundByTid(PoiGameConfig.BowlingSound_BallRot_Lv2)
	else
		gSoundMgr:PlaySoundByTid(PoiGameConfig.BowlingSound_BallRot_Lv3)
	end
end

M.IsCurrentPlayerNpc = function(self)
	local currentPlayer = self.gameMode:GetCurrentPlayer()

	return currentPlayer and currentPlayer.isNPC
end

M.SelectBall = function(self, ballIndex)
	self.game.ballLauncher:SelectBall(ballIndex)
	self.gameMode:SetCurrentPlayerBallIndex(ballIndex)
end

M.InitMessages = function(self)
	self.RegisterMessageEvents(self, {
		[gEventConstants.BOWLING_GAME_REFRESH_SCORE] = self.CreateAction(self, "RefreshPlayerView"),
		[gEventConstants.BOWLING_GAME_PINSTATE] = self.CreateAction(self, "RefreshPinState"),
		[gEventConstants.BOWLING_GAME_LANUCH_STATE] = self.CreateAction(self, "OnEventLanuchState"),
		[gEventConstants.BOWLING_TECH_SUCCICON_HIDE] = self.CreateAction(self, "OnEventSuccIconHide"),
		[gEventConstants.BOWLING_GAME_SUCCICON_SHOW] = self.CreateAction(self, "OnEventSuccIconShow"),
		[gEventConstants.BOWLING_NPC_ROT] = self.CreateAction(self, "OnEventNpcRot"),
		[gEventConstants.BOWLING_GAME_FRAME_DESC] = self.CreateAction(self, "RefreshFrameDesc"),
		[gEventConstants.PANEL_ON_SHOW] = self.CreateAction(self, "OnPanelShow"),
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, "OnPanelClose"),
		[gEventConstants.ON_BOWLING_BALL_INDEX_CHANGE] = self.CreateAction(self, "OnBallIndexChange"),
		[gEventConstants.BOWLING_GAME_OVER] = self.CreateAction(self, "OnGameOver")
	})
end

M.OnShow = function(self, _, data)
	self.timer = 0

	self.bindData.PinsState:SetActive(false)

	self.animationSpeed = 0.9

	self:InitView(data)
	self:InitBallSpiritList()

	self.ballRotationTransform = self.bindData.progress.transform:Find("Handle/Ball")

	if self.game and self.game.mode ~= GameMode.SINGLE then
		self.RefreshFrameDesc(self, nil, {
			["K\\xbc\\xa3\\xa2\\xb3"] = 1
		})
	end
end

M.InitView = function(self, data)
	self.bindData.PinsState:SetActive(false)

	self.ballIndex = data and data.ballIndex or math.ceil(#Config.prefabPaths.balls / 2)

	self:InitUI()
	self:RefreshLaunchUI(self.launchState)
	self:InitBallSpiritList()

	self.ballRotationTransform = self.bindData.progress.transform:Find("Handle/Ball")
	self.showPanelId = data and data.showPanelId
end

M.InitBallSpiritList = function(self)
	self.ballSpiritList = {}

	for i = 1, self.ballIndexMax do
		local icon = self.bindData.Balls.transform:Find("B" .. i)
		local uImage = icon:GetComponent(typeof(SGUI.UImage))

		table.insert(self.ballSpiritList, uImage.sprite)
	end

	self.ballIconIdList = {
		28051430,
		28051431,
		28051432,
		28051433,
		28051534
	}
end

M.RefreshPanelView = function(self, data)
	self.ballIndex = data and data.ballIndex or math.ceil(#Config.prefabPaths.balls / 2)

	if data and data.showPanelId then
		gPanelManager:CheckShow(data.showPanelId)
	end

	self.InitUI(self)
	self.RefreshLaunchUI(self, self.launchState)
end

M.OnBallIndexChange = function(self, _, data)
	self.RefreshPanelView(self, data)
end

M.OnUpdate = function(self)
	if self.NotInteractable(self) then
		return
	end

	if self.isBallPosBtnRightDown or self.isBallPosBtnLeftDown then
		local isRight = self.isBallPosBtnRightDown
		local posRatio = nil

		if self.IsRemotePlayerTurn(self) then
			posRatio = self.game.ballLauncher:UpdateChargingPos(isRight)
		else
			posRatio = self.game:ExecuteLongPressPos(isRight)
		end

		self.RefreshBallPosLoopSoundByMoveResult(self, isRight, posRatio)
	end

	if self.launchState ~= LaunchState.DIR then
		if gGmUtils.isBowlingGameEnableDireDebug and not self.IsRemotePlayerTurn(self) then
			if self.game.ballLauncher.objArrowTips then
				local mouseX = UnityEngine.Input.mousePosition.x
				local t = mouseX / UnityEngine.Screen.width * 2 - 1
				local yAngle = t * 45
				local localEuler = self.game.ballLauncher.objArrowTips.transform.localEulerAngles
				localEuler.y = Mathf.Clamp(yAngle, -4.5, 4.5)
				self.game.ballLauncher.objArrowTips.transform.localEulerAngles = localEuler
				self.game.ballLauncher.launchDir = localEuler.y
			end
		elseif self.IsRemotePlayerTurn(self) then
			self.game.ballLauncher:UpdateChargingDirAuto()
		else
			self.game:ExecuteLongPressDirAuto()
		end
	end

	if self.launchState ~= LaunchState.POWER then
		local powerPercent = nil

		if self.IsRemotePlayerTurn(self) then
			powerPercent = self.game.ballLauncher:UpdateChargingPowerAuto()
		else
			powerPercent = self.game:ExecuteLongPressPowerAuto()
		end

		self.UpdatePower(self, powerPercent)
	end
end

M.UpdatePower = function(self, powerPercent)
	self.bindData.progress.value = powerPercent
	self.bindData.BallpowerFill.fillAmount = powerPercent
	self.bindData.PowerNum.text = math.ceil(powerPercent * 100)
end

M.OnClose = function(self)
	self.isClosed = true
	self.coroutineSuccIconShow = coroutine.stop(self.coroutineSuccIconShow)
	self.coroutineFrameDescHide = coroutine.stop(self.coroutineFrameDescHide)

	self.StopAllSounds(self)
	self.ClearMessageEvents(self)
end

M.OnDestroy = function(self)
	self.hasRefreshPinScore = nil

	self:ClearMessageEvents()

	self.waitCo = coroutine.stop(self.waitCo)
	self.ballSpiritList = nil
	self.hasDestroy = true
	self.waitAnimationCo = coroutine.stop(self.waitAnimationCo)
	self.startButtonUpClickCo = coroutine.stop(self.startButtonUpClickCo)
	self.startButtonDownClickCo = coroutine.stop(self.startButtonDownClickCo)
	self.startDotRightClickCo = coroutine.stop(self.startDotRightClickCo)
	self.startDotLeftClickCo = coroutine.stop(self.startDotLeftClickCo)
	self.btnPRightCo = coroutine.stop(self.btnPRightCo)
	self.btnPLeftCo = coroutine.stop(self.btnPLeftCo)

	self:StopAllSounds()
	self.bindData.ULanuchRot.gameObject.transform:DOKill()
	self.bindData.ULanuchPower.gameObject.transform:DOKill()

	if gClientUtils.NotNil(self.ballRotationTransform) then
		self.ballRotationTransform:DOKill()
	end

	self.ballRotationTweener = nil
end

M.InitUI = function(self)
	if not self.ballIndex then
		self.ballIndex = math.ceil(#Config.prefabPaths.balls / 2)
	end

	self.ballIndexMin = 1
	self.ballIndexMax = #Config.prefabPaths.balls
	self.isBallPosBtnRightDown = false
	self.isBallPosBtnLeftDown = false
	self.RotIndex = 0

	self.bindData.DescCupSelectBall.gameObject:SetActive(false)
	self.bindData.DescCupPos.gameObject:SetActive(false)
	self.bindData.DescCupRot.gameObject:SetActive(false)
	self.bindData.BtnSpace.gameObject:SetActive(false)
	self:ClearPowerRot(false)
	self:ClearPowerRot(true)

	self.launchState = LaunchState.ANIM

	self.bindData.ULanuchSel.gameObject:SetActive(false)
end

M.OnBtnPRightPress = function(self)
	if not self.AcceptInput(self) then
		return
	end

	self.btnPLeftCo = coroutine.stop(self.btnPLeftCo)

	self.OnRotationButtonClick(self, "right")

	self.btnPRightCo = coroutine.start(function ()
		while true do
			coroutine.wait(LTConfig.PoiGameConfig.BowingGameRotStepTime)
			self:OnRotationButtonClick("right")
		end
	end)
end

M.OnBtnPRightRelease = function(self)
	self.btnPRightCo = coroutine.stop(self.btnPRightCo)
end

M.OnBtnPLeftPress = function(self)
	if not self.AcceptInput(self) then
		return
	end

	self.btnPRightCo = coroutine.stop(self.btnPRightCo)

	self.OnRotationButtonClick(self, "left")

	self.btnPLeftCo = coroutine.start(function ()
		while true do
			coroutine.wait(LTConfig.PoiGameConfig.BowingGameRotStepTime)
			self:OnRotationButtonClick("left")
		end
	end)
end

M.OnBtnPLeftRelease = function(self)
	self.btnPLeftCo = coroutine.stop(self.btnPLeftCo)
end

M.OnSliderValueChanged = function(self, value)
	if self.IsRemotePlayerTurn(self) then
		return
	end

	self.minLaunchOffset = Config.minLaunchOffset
	self.maxLaunchOffset = Config.maxLaunchOffset
	local percent = value / self.bindData.slider.maxValue
	local launchOffset = self:MapLaunchOffset(percent)

	self.game:SetChargingPos(launchOffset, percent)

	if self:NeedSync() then
		local now = Time.realtimeSinceStartup

		if self.nextSyncPosSnapTime ~= nil or self.nextSyncPosSnapTime >= now then
			self.nextSyncPosSnapTime = now + 0.25

			self.BroadcastLaunchStateInfo(self, "OnRemotePosDragSnapshot", launchOffset, percent)
		end
	end
end

M.MapLaunchOffset = function(self, x)
	return Config.minLaunchOffset - (Config.minLaunchOffset - Config.maxLaunchOffset) * x
end

M.BuildLaunchStateSyncData = function(self, prevState)
	local launcher = self.game.ballLauncher

	if prevState ~= LaunchState.POS then
		local offset = launcher.launchOffset
		local denom = Config.maxLaunchOffset - Config.minLaunchOffset
		local ratio = denom ~= 0 and 0.5 or (offset - Config.minLaunchOffset) / denom
		ratio = Mathf.Clamp01(ratio)

		return {
			commitPos = {
				launchOffset = offset,
				posRatio = ratio
			}
		}
	end

	if prevState ~= LaunchState.DIR then
		return {
			commitDir = {
				launchDir = launcher.launchDir
			}
		}
	end

	if prevState ~= LaunchState.POWER then
		return {
			commitPower = {
				powerPercent = self.bindData.BallpowerFill.fillAmount
			}
		}
	end

	return nil
end

M.UpdateRotHeight = function(self)
	if self.NotInteractable(self) or self.hasDestroy then
		return
	end

	local powerPercent = self.bindData.BallpowerFill.fillAmount
	self.bindData.PowerNum.text = math.ceil(powerPercent * 100)
	local height = self.bindData.BallpowerFill.transform.sizeDelta.y * self.bindData.ULanuchPower.transform.localScale.y
	local hH = height / 2
	local currentY = Mathf.Lerp(-hH, hH, powerPercent)
	local pos = self.bindData.ULanuchRot.gameObject.transform.localPosition
	local y = currentY + self.bindData.ULanuchPower.gameObject.transform.localPosition.y
	self.bindData.ULanuchRot.gameObject.transform.localPosition = Vector3.Fetch(pos.x, y, pos.z)
end

M.UpdateRotationIndicators = function(self, side, level)
	local indicators = RotationIndicators[side]

	for i = 1, MaxRotationLevel do
		local indicatorName = indicators[i]
		local indicator = self.bindData[indicatorName]

		indicator.gameObject:SetActive(i > level)
	end
end

M.UpdatePowerRot = function(self, rotIndex)
	if self.NeedSync(self) then
		self.BroadcastLaunchStateInfo(self, "UpdatePowerRot", rotIndex)
	end

	local leftLevel = math.max(0, -rotIndex)
	local rightLevel = math.max(0, rotIndex)

	self.UpdateRotationIndicators(self, "left", leftLevel)
	self.UpdateRotationIndicators(self, "right", rightLevel)
end

M.ClearPowerRot = function(self, isRight)
	if isRight then
		self.UpdateRotationIndicators(self, "right", 0)
	else
		self.UpdateRotationIndicators(self, "left", 0)
	end
end

M.PlayRotationAnimation = function(self, config)
	local animation = config.direction ~= 1 and self.bindData.ballRotationRightAnimation or self.bindData.ballRotationLeftAnimation

	gCS.LuaUtils.PlayAnimationByName(animation, config.tipsAnim)

	if self.RotIndex ~= 0 and self.ballRotationTweener then
		self.ballRotationTweener:Kill()

		self.ballRotationTweener = nil
	end

	if self.RotIndex * config.direction <= 0 then
		if not self.ballRotationTweener then
			local rotationZ = config.direction <= 0 and -360 or 360
			self.ballRotationTweener = self.ballRotationTransform:DOLocalRotate(Vector3.New(0, 0, rotationZ), 3, DG.Tweening.RotateMode.FastBeyond360)

			self.ballRotationTweener:SetEase(DG.Tweening.Ease.Linear):SetLoops(-1):OnKill(function ()
				self.ballRotationTweener = nil
			end)
		else
			local speed = LTConfig.PoiGameConfig.BowingGameRotateSpeedList[math.abs(self.RotIndex)]

			gCS.LuaUtils.SetTweenerTimeScale(self.ballRotationTweener, speed)
		end
	end
end

M.OnRotationButtonClick = function(self, direction)
	if not self.AcceptInput(self) then
		return
	end

	if self.launchState == LaunchState.ROT then
		return
	end

	local config = RotationConfig[direction]
	local newRotIndex = self.RotIndex + config.direction

	if newRotIndex > -MaxRotationLevel and newRotIndex < MaxRotationLevel then
		self.RotIndex = newRotIndex

		self:PlayRotationAnimation(config)
		self:UpdatePowerRot(self.RotIndex)
		self:PlayRotationLevelSound(math.abs(self.RotIndex))
		self.game:ExecutePressRot(self.RotIndex)
	end
end

M.LaunchNextState = function(self)
	if not self.AcceptInput(self) then
		return
	end

	if self.launchState ~= LaunchState.ROT then
		return
	end

	if self.NeedSync(self) and self.launchState ~= LaunchState.POS and (self.isBallPosBtnRightDown or self.isBallPosBtnLeftDown) then
		self.BroadcastLaunchStateInfo(self, "OnRemotePosMoveStop")
	end

	self.isBallPosBtnRightDown = false
	self.isBallPosBtnLeftDown = false

	self:StopBallPosLoopSound()
	self.game:ExecuteShootKeyUp()
end

M.BallPosBtnRightOnPress = function(self)
	if not self.AcceptInput(self) then
		return
	end

	self.game:ExecuteShootKeyDown()

	self.isBallPosBtnRightDown = true

	if self.launchState ~= LaunchState.POS then
		self.StartBallPosLoopSoundByDirection(self, true)
	end

	if self.NeedSync(self) then
		self.BroadcastLaunchStateInfo(self, "OnRemotePosMoveStart", true)
	end
end

M.BallPosBtnRightOnRelease = function(self)
	if not self.AcceptInput(self) then
		return
	end

	self.isBallPosBtnRightDown = false

	if not self.suppressBallPosLoopStop and not self.isBallPosBtnRightDown and not self.isBallPosBtnLeftDown then
		self.StopBallPosLoopSound(self)
	end

	if self.NeedSync(self) then
		self.BroadcastLaunchStateInfo(self, "OnRemotePosMoveStop")
	end
end

M.BallPosBtnLeftOnPress = function(self)
	if not self.AcceptInput(self) then
		return
	end

	self.game:ExecuteShootKeyDown()

	self.isBallPosBtnLeftDown = true

	if self.launchState ~= LaunchState.POS then
		self.StartBallPosLoopSoundByDirection(self, false)
	end

	if self.NeedSync(self) then
		self.BroadcastLaunchStateInfo(self, "OnRemotePosMoveStart", false)
	end
end

M.BallPosBtnLeftOnRelease = function(self)
	if not self.AcceptInput(self) then
		return
	end

	self.isBallPosBtnLeftDown = false

	if not self.suppressBallPosLoopStop and not self.isBallPosBtnRightDown and not self.isBallPosBtnLeftDown then
		self.StopBallPosLoopSound(self)
	end

	if self.NeedSync(self) then
		self.BroadcastLaunchStateInfo(self, "OnRemotePosMoveStop")
	end
end

M.OnExitClick = function(self)
	gBowlingGameManager:SendSignalToGadget("BowlingDraw")
	gBowlingGameManager:TryShowClassicModeExitDialog()

	if not gBowlingGameManager:IsOnlineGame() then
		local currentGame = gBowlingGameManager.currentGame
		local isSuccess = currentGame == nil and currentGame.mode ~= GameMode.TECHNICAL

		gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
			isSuccess = isSuccess
		})
	end

	self.IsExit = true

	gBowlingGameManager:MarkExitByUI()
	gBowlingGameManager:ExecuteExitGame()
end

M.NextBall = function(self)
	self.bindData.BallpowerFill.fillAmount = 0
	self.bindData.PowerNum.text = 0
end

M.GetScoreText = function(self, score)
	if score <= 0 then
		return tostring(score)
	end

	return "-"
end

M.RefreshFrameDesc = function(self, _, params)
	if self.game.maxFrames >= params.frame then
		return
	end

	local delay = 0

	if params.frame ~= 1 then
		self.bindData.roundText = LTConfig.TextScriptTextConfig.GetConfig(89901400).Text
	elseif params.frame ~= 2 then
		self.bindData.roundText = LTConfig.TextScriptTextConfig.GetConfig(89901325).Text
		self.bindData.roundTextEn = "ROUND 2"
	elseif params.frame ~= 3 then
		self.bindData.roundText = LTConfig.TextScriptTextConfig.GetConfig(89901326).Text
		self.bindData.roundTextEn = "ROUND 3"
	end

	self.bindData.roundNode:SetActive(true)
	self.bindData.switchNode:SetActive(false)

	if params.isSwitch then
		delay = 1.3

		if params.playerIndex == 1 then
			self.bindData.switchNode:SetActive(true)
			self.bindData.roundNode:SetActive(false)
		end
	end

	self.coroutineFrameDescHide = coroutine.start(function ()
		if delay <= 0 then
			coroutine.wait(delay)
		end

		self:RefreshSuccessIcon(0, 0)
		self.bindData.Mid.gameObject:SetActive(true)
		coroutine.wait(2)
		self.bindData.Mid.gameObject:SetActive(false)
	end)
end

M.RefreshPlayerView = function(self, _, params)
	if self.NotInteractable(self) then
		return
	end

	self.NextBall(self)

	local total = 0

	for _, score in ipairs(params.frameScores) do
		total = total + score
	end

	local succType = params.frameSpare[params.currentFrame]

	self.RefreshSuccessIcon(self, succType, total)

	self.coroutineSuccIconShow = coroutine.start(function ()
		coroutine.wait(3)
		self:RefreshSuccessIcon(0, 0)
	end)
end

M.OnPanelShow = function(self, _, panelId)
	if panelId ~= gPanelId.MINI_GAMES_BOWLING_TECH_PINS_PANEL then
		self.bindData.BtnF:SetActive(false)
	end
end

M.OnPanelClose = function(self, _, panelId)
	if panelId ~= gPanelId.MINI_GAMES_BOWLING_TECH_PINS_PANEL then
		self.bindData.BtnF:SetActive(true)
	end
end

M.RefreshSuccessIcon = function(self, currentFrameResult, totalScore)
	if self.NotInteractable(self) then
		return
	end

	if totalScore ~= 90 then
		self.bindData.IconPrefect.gameObject:SetActive(true)
	elseif currentFrameResult ~= 1 then
		self.bindData.IconStrike.gameObject:SetActive(true)
	elseif currentFrameResult ~= 2 then
		self.bindData.IconSpare.gameObject:SetActive(true)
	else
		self.bindData.IconStrike.gameObject:SetActive(false)
		self.bindData.IconSpare.gameObject:SetActive(false)
		self.bindData.IconPrefect.gameObject:SetActive(false)
	end
end

M.RefreshPinState = function(self, _, params)
	if self.NotInteractable(self) then
		return
	end

	self.lastStandingPins = self.lastStandingPins or params.standingPins
	local hasScore = #params.standingPins <= #self.lastStandingPins
	self.lastStandingPins = params.standingPins

	self:ResetPinState(false)

	local refreshPinsState = function()
		local pinState = self.bindData.PinsState

		for _, pinIndex in ipairs(params.standingPins) do
			local pn = "PT" .. tostring(pinIndex)
			local bUi = pinState.transform:Find(pn)

			bUi.gameObject:SetActive(true)
		end
	end

	if hasScore then
		self.hasRefreshPinScore = true
		self.waitAnimationCo = coroutine.start(function ()
			coroutine.wait(0.1)
			refreshPinsState()
		end)
	else
		self.waitAnimationCo = coroutine.stop(self.waitAnimationCo)

		gClientUtils.FinishAnimation(self.bindData.pinsStateAnimation, "S_vx_ui_panel_Bowling_PinsState")
		refreshPinsState()
	end
end

M.ResetPinState = function(self, bState)
	if self.NotInteractable(self) then
		return
	end

	local pinState = self.bindData.PinsState

	for i = 1, 10 do
		local pn = "PT" .. tostring(i)
		local bUi = pinState.transform:Find(pn)

		bUi.gameObject:SetActive(bState)
	end
end

M.OnButtonUpClick = function(self)
	if not self.AcceptInput(self) then
		return
	end

	if self.bindData.ballAnimation.isPlaying then
		return
	end

	local prevBallIndex = self.ballIndex

	if self.ballIndex >= self.ballIndexMax then
		self.ballIndex = self.ballIndex + 1
		local time = gCS.LuaUtils.PlayAnimationByName(self.bindData.ballAnimation, "S_vx_ui_panel_Bowling_ball_down")
		self.waitAnimationCo = coroutine.start(function ()
			coroutine.wait(time)
			self:ShowBallIcon(self.ballIndex)
		end)
	end

	self.SelectBall(self, self.ballIndex)

	if self.launchState ~= LaunchState.POS and self.ballIndex == prevBallIndex then
		gSoundMgr:PlaySoundByTid(PoiGameConfig.BowlingSound_BallSelector)
	end
end

M.OnButtonDownClick = function(self)
	if not self.AcceptInput(self) then
		return
	end

	if self.bindData.ballAnimation.isPlaying then
		return
	end

	local prevBallIndex = self.ballIndex

	if self.ballIndexMin >= self.ballIndex then
		self.ballIndex = self.ballIndex - 1
		local time = gCS.LuaUtils.PlayAnimationByName(self.bindData.ballAnimation, "S_vx_ui_panel_Bowling_ball_up")
		self.waitAnimationCo = coroutine.start(function ()
			coroutine.wait(time)
			self:ShowBallIcon(self.ballIndex)
		end)
	end

	self.SelectBall(self, self.ballIndex)

	if self.launchState ~= LaunchState.POS and self.ballIndex == prevBallIndex then
		gSoundMgr:PlaySoundByTid(PoiGameConfig.BowlingSound_BallSelector)
	end
end

M.ShowBallIcon = function(self, ballIndex)
	if self.NeedSync(self) then
		self.BroadcastLaunchStateInfo(self, "ShowBallIcon", ballIndex)
	end

	local textId = Config.prefabPaths.balls[ballIndex].name
	self.bindData.BallName.text = LTConfig.TextScriptTextConfig.GetConfig(textId).Text
	self.bindData.ball0.sprite = self.ballSpiritList[ballIndex + 1]
	self.bindData.ball1.sprite = self.ballSpiritList[ballIndex]
	self.bindData.ball2.sprite = self.ballSpiritList[ballIndex - 1]
	self.bindData.ballIconId = self.ballIconIdList[ballIndex]

	gClientUtils.ResetAnimation(self.bindData.ballAnimation, "S_vx_ui_panel_Bowling_ball_up")
	gClientUtils.ResetAnimation(self.bindData.ballAnimation, "S_vx_ui_panel_Bowling_ball_down")
end

M.RefreshBall = function(self)
	if self.NotInteractable(self) then
		return
	end

	self.ShowBallIcon(self, self.ballIndex)
	self.SelectBall(self, self.ballIndex)
end

M.RefreshLaunchUI = function(self, launchState, syncData)
	if self.NotInteractable(self) then
		return
	end

	local isPOS = launchState ~= LaunchState.POS
	local isDIR = launchState ~= LaunchState.DIR
	local isPOWER = launchState ~= LaunchState.POWER
	local isROT = launchState ~= LaunchState.ROT
	local haveControl = not self:IsCurrentPlayerNpc() and not self:IsRemotePlayerTurn()

	self.bindData.BtnSpace:SetActive(haveControl)
	self.bindData.BtnLeftClick:SetActive(haveControl)
	self.bindData.BallPosBtnRight:SetActive(haveControl)
	self.bindData.BallPosBtnLeft:SetActive(haveControl)
	self.bindData.BtnPRight:SetActive(haveControl and isROT)
	self.bindData.BtnPLeft:SetActive(haveControl and isROT)
	self.bindData.BtnUp:SetActive(haveControl)
	self.bindData.BtnDown:SetActive(haveControl)

	local stateChanged = self.launchState == launchState
	self.launchState = launchState

	if self.ballRotationTweener then
		self.ballRotationTweener:Kill()

		self.ballRotationTweener = nil
		self.ballRotationTransform.rotation = Quaternion.identity
	end

	self:ClearPowerRot(false)
	self:ClearPowerRot(true)
	self.bindData.ULanuchSel.gameObject:SetActive(isPOS)
	self.bindData.ULanuchPos.gameObject:SetActive(isPOS)
	self.bindData.ULanuchDir.gameObject:SetActive(false)
	self.bindData.ULanuchPower.gameObject:SetActive(isPOWER or isROT)
	self.bindData.ULanuchRot.gameObject:SetActive(isROT)

	self.bindData.launchRotCtrl = isROT and 1 or 0

	self.bindData.DescCupSelectBall.gameObject:SetActive(isPOS)
	self.bindData.DescCupPos.gameObject:SetActive(isPOS)
	self.bindData.DescCupRot.gameObject:SetActive(isROT)
	self.bindData.BtnSpace.gameObject:SetActive(isPOS or isDIR or isPOWER)
	self.bindData.slider:SetActive(isPOS)

	if isPOS then
		if self.showPanelId then
			if gPanelManager:IsPanelShowing(self.showPanelId) then
				self.SetScorePanelActive(self, true)
			else
				gPanelManager:CheckShow(self.showPanelId)
			end
		end

		self.bindData.PinsState:SetActive(true)

		self.bindData.slider.value = self.bindData.slider.maxValue / 2

		self:RefreshSuccessIcon(0, 0)

		self.RotIndex = 0

		self:RefreshBall()
		self:ShowPinsStateWithAnim()
	elseif isROT then
		self.UpdateRotHeight(self)
	elseif launchState ~= LaunchState.ROLLING then
		self.waitCo = coroutine.stop(self.waitCo)
		self.waitCo = coroutine.start(function ()
			coroutine.wait(0.1)

			if self.showPanelId and gPanelManager:IsPanelShowing(self.showPanelId) then
				self:SetScorePanelActive(false)
			end

			self:HidePinsStateWithAnim()
		end)
	elseif launchState ~= LaunchState.ANIM then
		self.waitCo = coroutine.stop(self.waitCo)
		self.waitCo = coroutine.start(function ()
			coroutine.wait(0.8)

			if self.showPanelId and gPanelManager:IsPanelShowing(self.showPanelId) then
				self:SetScorePanelActive(true)
			end

			self:ShowPinsStateWithAnim()
		end)
	end

	if self.IsRemotePlayerTurn(self) and (stateChanged or syncData == nil) then
		self.isBallPosBtnRightDown = false
		self.isBallPosBtnLeftDown = false

		if self.launchState == LaunchState.POS then
			self.StopBallPosLoopSound(self)
		end

		local launcher = self.game.ballLauncher
		launcher.LaunchState = launchState

		if syncData and syncData.commitPos then
			local offset = syncData.commitPos.launchOffset
			local ratio = syncData.commitPos.posRatio
			launcher.launchOffset = offset
			launcher.lastCTimePos = ratio * launcher.CTime

			launcher.CreateBallLightPoint(launcher)
			launcher.SetChargingPos(launcher, offset, ratio)

			self.bindData.slider.value = ratio * self.bindData.slider.maxValue
		end

		if syncData and syncData.commitDir then
			launcher.launchDir = syncData.commitDir.launchDir

			launcher.CreateArrowTips(launcher)

			if launcher.objArrowTips then
				launcher.objArrowTips.transform.localRotation = Quaternion.Euler(0, launcher.launchDir, 0)
			end
		end

		if syncData and syncData.commitPower then
			self.UpdatePower(self, syncData.commitPower.powerPercent)
			self.UpdateRotHeight(self)
		end

		if isPOS then
			launcher.CreateBallLightPoint(launcher)

			if launcher.objBallLightPoint then
				launcher.objBallLightPoint:SetActive(true)
			end

			if launcher.objArrowTips then
				launcher.objArrowTips:SetActive(false)
			end

			launcher.dirStartTime = nil
			launcher.powerStartTime = nil
		elseif isDIR then
			if launcher.objBallLightPoint then
				launcher.objBallLightPoint:SetActive(false)
			end

			launcher.CreateArrowTips(launcher)

			if launcher.objArrowTips then
				launcher.objArrowTips:SetActive(true)
			end

			launcher.dirStartTime = Time.time
			launcher.powerStartTime = nil
		elseif isPOWER then
			if launcher.objBallLightPoint then
				launcher.objBallLightPoint:SetActive(false)
			end

			launcher.CreateArrowTips(launcher)

			if launcher.objArrowTips then
				launcher.objArrowTips:SetActive(true)
			end

			launcher.dirStartTime = nil
			launcher.powerStartTime = Time.time
		elseif isROT then
			launcher.dirStartTime = nil
			launcher.powerStartTime = nil

			if launcher.objArrowTips then
				launcher.objArrowTips:SetActive(false)
			end
		end
	end
end

M.OnEventLanuchState = function(self, _, params)
	if self.NotInteractable(self) then
		return
	end

	local prevState = self.launchState
	local newState = params.state

	if prevState == newState then
		if prevState ~= LaunchState.POS and newState ~= LaunchState.DIR then
			gSoundMgr:PlaySoundByTid(PoiGameConfig.BowlingSound_BallStateConfirm_01)
		elseif prevState ~= LaunchState.DIR and newState ~= LaunchState.POWER then
			gSoundMgr:PlaySoundByTid(PoiGameConfig.BowlingSound_BallStateConfirm_02)
		elseif prevState ~= LaunchState.POWER and newState ~= LaunchState.ROT then
			self:StopVelocityLoopSound()
			gSoundMgr:PlaySoundByTid(PoiGameConfig.BowlingSound_BallStateConfirm_03)
		end
	end

	if newState ~= LaunchState.POWER then
		self.StartVelocityLoopSound(self)
	else
		self.StopVelocityLoopSound(self)
	end

	if newState == LaunchState.POS then
		self.StopBallPosLoopSound(self)
	end

	self.launchState = newState

	if self.launchState ~= LaunchState.ROLLING and gBowlingGameManager.printLaunchArgs then
		local launcher = self.game.ballLauncher
		local posX = launcher.launchOffset
		local rotAngle = launcher.launchDir
		local powerPercent = math.ceil(self.bindData.BallpowerFill.fillAmount * 100)
		local rotationIndex = launcher.launchRotIndex

		print_debug(string.format("bowling launch args: %f;%f;%d;%d", posX, rotAngle, powerPercent, rotationIndex))
	end

	if params.ballIndex then
		self.ballIndex = params.ballIndex
	end

	local syncData = nil

	if self.NeedSync(self) then
		syncData = self.BuildLaunchStateSyncData(self, prevState)

		self.BroadcastLaunchStateInfo(self, "RefreshLaunchUI", self.launchState, syncData)
	end

	self.RefreshLaunchUI(self, self.launchState, syncData)
end

M.OnEventSuccIconHide = function(self, _, params)
	if self.NotInteractable(self) then
		return
	end

	self.RefreshSuccessIcon(self, 0, 0)
end

M.OnEventSuccIconShow = function(self, _, params)
	if self.NotInteractable(self) then
		return
	end

	local succType = params and params.succType or 0
	local totalScore = params and params.totalScore or 0

	if succType == 1 and succType == 2 then
		return
	end

	self.RefreshSuccessIcon(self, 0, 0)
	self.RefreshSuccessIcon(self, succType, totalScore)

	self.coroutineSuccIconShow = coroutine.stop(self.coroutineSuccIconShow)
	self.coroutineSuccIconShow = coroutine.start(function ()
		coroutine.wait(3)
		self:RefreshSuccessIcon(0, 0)
	end)
end

M.OnEventNpcRot = function(self, _, params)
	if not self.gameMode:IsAiControlledTurn() then
		return
	end

	if self.launchState == LaunchState.ROT then
		return
	end

	if params.isRight ~= 1 then
		if self.RotIndex >= 5 then
			self.RotIndex = self.RotIndex + 1
		end
	elseif self.RotIndex <= -5 then
		self.RotIndex = self.RotIndex - 1
	end

	self.UpdatePowerRot(self, self.RotIndex)
end

M.OnLeftStickInputChanged = function(self, context)
	local value = context.ReadValueVector2(context)

	if context.started or context.performed then
		self.suppressBallPosLoopStop = true

		if value.x <= 0 then
			self.BallPosBtnLeftOnRelease(self)
			self.BallPosBtnRightOnPress(self)
		else
			self.BallPosBtnRightOnRelease(self)
			self.BallPosBtnLeftOnPress(self)
		end

		self.suppressBallPosLoopStop = false
	end

	if context.canceled then
		self.suppressBallPosLoopStop = false

		self.BallPosBtnLeftOnRelease(self)
		self.BallPosBtnRightOnRelease(self)
	end
end

M.OnRightStickInputChanged = function(self, context)
	local value = context.ReadValueVector2(context)

	if context.started or context.performed then
		if value.y >= 0 then
			self.OnStartButtonUpClickCo(self)
		else
			self.OnStartButtonDownClickCo(self)
		end
	end

	if context.canceled then
		self.startButtonUpClickCo = coroutine.stop(self.startButtonUpClickCo)
		self.startButtonDownClickCo = coroutine.stop(self.startButtonDownClickCo)
	end
end

M.OnStartButtonUpClickCo = function(self)
	if self.startButtonUpClickCo then
		return
	end

	self.startButtonDownClickCo = coroutine.stop(self.startButtonDownClickCo)

	self.OnButtonUpClick(self)

	self.startButtonUpClickCo = coroutine.start(function ()
		while true do
			coroutine.wait(0.5)
			self:OnButtonUpClick()
		end
	end)
end

M.OnStartButtonDownClickCo = function(self)
	if self.startButtonDownClickCo then
		return
	end

	self.startButtonUpClickCo = coroutine.stop(self.startButtonUpClickCo)

	self.OnButtonDownClick(self)

	self.startButtonDownClickCo = coroutine.start(function ()
		while true do
			coroutine.wait(0.5)
			self:OnButtonDownClick()
		end
	end)
end

M.OnRemotePosMoveStart = function(self, isRight)
	if self.launchState == LaunchState.POS then
		return
	end

	self.isBallPosBtnRightDown = isRight and true or false
	self.isBallPosBtnLeftDown = not self.isBallPosBtnRightDown
	local launcher = self.game.ballLauncher
	local denom = Config.maxLaunchOffset - Config.minLaunchOffset
	local ratio = denom ~= 0 and 0.5 or (launcher.launchOffset - Config.minLaunchOffset) / denom
	ratio = Mathf.Clamp01(ratio)
	launcher.lastCTimePos = ratio * launcher.CTime
end

M.OnRemotePosMoveStop = function(self)
	self.isBallPosBtnRightDown = false
	self.isBallPosBtnLeftDown = false

	self.StopBallPosLoopSound(self)
end

M.OnRemotePosDragSnapshot = function(self, launchOffset, posRatio)
	if self.launchState == LaunchState.POS then
		return
	end

	local launcher = self.game.ballLauncher
	launcher.launchOffset = launchOffset
	launcher.lastCTimePos = posRatio * launcher.CTime

	launcher.CreateBallLightPoint(launcher)

	if launcher.objBallLightPoint then
		launcher.objBallLightPoint:SetActive(true)

		local t = launcher.objBallLightPoint.transform
		local p = t.localPosition

		t:DOKill(false)
		t:DOLocalMove(Vector3.New(launchOffset, p.y, p.z), 0.25):SetEase(DG.Tweening.Ease.Linear)
	end

	if launcher.objArrowTips then
		local t = launcher.objArrowTips.transform
		local p = t.localPosition

		t:DOKill(false)
		t:DOLocalMove(Vector3.New(launchOffset, p.y, p.z), 0.25):SetEase(DG.Tweening.Ease.Linear)
	end

	self.bindData.slider.value = posRatio * self.bindData.slider.maxValue
end

M.OnSyncClientLaunchStateInfo = function(self, data)
	if self.NotInteractable(self) then
		return
	end

	self[data.method](self, unpack(data.args))
end

M.BroadcastLaunchStateInfo = function(self, method, ...)
	local launchStateData = {
		method = method,
		args = {
			...
		}
	}

	gBowlingGameManager:BroadcastBowlingClientInfo(BowlingConstants.SyncDataType.RefreshLaunchUI, launchStateData)
end

M.OnSyncLaunchState = function(self, launchStateData)
	if self.game.ballLauncher then
		self.game.ballLauncher:OnSyncLaunchState(launchStateData)
	end
end

M.NotInteractable = function(self)
	local result = self.IsExit or self.isClosed or not self.STATE_EnableOnce or self.game ~= nil

	return result
end

M.AcceptInput = function(self)
	return not self:NotInteractable() and self.gameMode:AcceptInput()
end

M.NeedSync = function(self)
	return gBowlingGameManager:IsOnlineGame() and self.gameMode:ShouldBroadcastClientInfo()
end

M.IsRemotePlayerTurn = function(self)
	return gBowlingGameManager:IsOnlineGame() and self.gameMode:IsRemotePlayerTurn()
end

M.SetScorePanelActive = function(self, isActive)
	gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_SWITCH_PANEL_ACTIVE, isActive)
end

M.ShowPinsStateWithAnim = function(self)
	if self.bindData.PinsState.gameObject.activeInHierarchy then
		return
	end

	self.bindData.PinsState.gameObject:SetActive(true)

	local animationName = self.hasRefreshPinScore and "S_vx_ui_panel_Bowling_PinsState" or "S_vx_ui_panel_Bowling_PinsState_open"

	if self.hasRefreshPinScore then
		self.bindData.PinsState.renderOpacity = 1
	end

	gClientUtils.ResetAnimation(self.bindData.pinsStateAnimation, animationName)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.pinsStateAnimation, animationName)

	self.hasRefreshPinScore = nil
end

M.HidePinsStateWithAnim = function(self)
	slot1 = self:PlayAniChain(self.bindData.pinsStateAnimation, "S_vx_ui_panel_Bowling_PinsState_close")

	slot1:OnComplete(function ()
		self.bindData.PinsState.gameObject:SetActive(false)
	end)
end

M.OnTeachBtnClick = function(self)
	gPanelManager:CheckShow(gPanelId.BOWLING_TEACH_PANEL)
end
