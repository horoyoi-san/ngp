C_BowlingGameMainPanelStore = DefClass("C_BowlingGameMainPanelStore", C_BowlingGameMainPanelStore, C_StoreGroup)
GroupName2Class.BowlingGameMainPanelStore = C_BowlingGameMainPanelStore
local M = C_BowlingGameMainPanelStore
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local LaunchState = BowlingConstants.LaunchState
local Config = require("LX6/MiniGame/BowlingGame/BowlingConfig").Launcher
local MaxRotationLevel = 5
local RotationIndicators = {
	left = {
		"PowerL1",
		"PowerL2",
		"PowerL3",
		"PowerL4",
		"PowerL5"
	},
	right = {
		"PowerR1",
		"PowerR2",
		"PowerR3",
		"PowerR4",
		"PowerR5"
	}
}
local RotationConfig = {
	right = {
		tipsAnim = "S_vx_ui_panel_Bowling_BallRtips",
		clipName = "S_vx_ui_panel_Bowling_BallR",
		direction = 1
	},
	left = {
		tipsAnim = "S_vx_ui_panel_Bowling_BallLtips",
		clipName = "S_vx_ui_panel_Bowling_BallL",
		direction = -1
	}
}

function M:OnAwake()
	self.bindData.rightStick.luaGamePadInputChanged = self:CreateAction("OnRightStickInputChanged")
	self.bindData.leftStick.luaGamePadInputChanged = self:CreateAction("OnLeftStickInputChanged")
	self.bindData.BtnSpace.luaPress = self:CreateAction("LaunchNextState")
	self.bindData.BtnLeftClick.luaPress = self:CreateAction("LaunchNextState")
	self.bindData.BtnF.luaClick = self:CreateAction("OnExitClick")
	self.bindData.BtnUp.luaClick = self:CreateAction("OnButtonUpClick")
	self.bindData.BtnDown.luaClick = self:CreateAction("OnButtonDownClick")
	self.bindData.BallPosBtnRight.luaPress = self:CreateAction("BallPosBtnRightOnPress")
	self.bindData.BallPosBtnRight.luaRelease = self:CreateAction("BallPosBtnRightOnRelease")
	self.bindData.BallPosBtnLeft.luaPress = self:CreateAction("BallPosBtnLeftOnPress")
	self.bindData.BallPosBtnLeft.luaRelease = self:CreateAction("BallPosBtnLeftOnRelease")
	self.bindData.BtnPRight.luaClick = self:CreateAction("BtnRotRightOnClick")
	self.bindData.BtnPLeft.luaClick = self:CreateAction("BtnRotLeftOnClick")
	self.bindData.slider.luaValueChanged = self:CreateAction("OnSliderValueChanged")
	self.hasDestroy = nil
end

function M:OnStart()
	self.lastStandingPins = nil
	self.isClosed = false
	self.IsExit = false
	self.ballIndex = math.ceil(#Config.prefabPaths.balls / 2)

	self:InitMessages()
end

function M:InitMessages()
	self:RegisterMessageEvents({
		[gEventConstants.BOWLING_GAME_REFRESH_SCORE] = self:CreateAction("RefreshPlayerView"),
		[gEventConstants.BOWLING_GAME_PINSTATE] = self:CreateAction("RefreshPinState"),
		[gEventConstants.BOWLING_GAME_LANUCH_STATE] = self:CreateAction("OnEventLanuchState"),
		[gEventConstants.BOWLING_TECH_SUCCICON_HIDE] = self:CreateAction("OnEventSuccIconHide"),
		[gEventConstants.BOWLING_NPC_ROT] = self:CreateAction("OnEventNpcRot"),
		[gEventConstants.BOWLING_GAME_FRAME_DESC] = self:CreateAction("RefreshFrameDesc"),
		[gEventConstants.PANEL_ON_SHOW] = self:CreateAction("OnPanelShow"),
		[gEventConstants.PANEL_ON_CLOSE] = self:CreateAction("OnPanelClose"),
		[gEventConstants.ON_BOWLING_BALL_INDEX_CHANGE] = self:CreateAction("OnBallIndexChange")
	})
end

function M:OnShow(_, data)
	self.timer = 0
	self.animationSpeed = 0.9

	self:RefreshPanelView(data)
	self:InitBallSpiritList()

	self.ballRotationTransform = self.bindData.progress.transform:Find("Handle/Ball")
end

function M:InitBallSpiritList()
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
		28051433
	}
end

function M:RefreshPanelView(data)
	self.ballIndex = data and data.ballIndex or math.ceil(#Config.prefabPaths.balls / 2)

	self:InitUI()

	if data and data.showPanelId then
		gPanelManager:CheckShow(data.showPanelId)
	end

	self:RefreshLaunchUI(self.launchState)
end

function M:OnBallIndexChange(_, data)
	self:RefreshPanelView(data)
end

function M:OnUpdate()
	if self:NotInteractable() then
		return
	end

	local currentGame = gBowlingGameManager.currentGame

	if self.isBallPosBtnRightDown or self.isBallPosBtnLeftDown then
		currentGame:ExecuteLongPressPos(self.isBallPosBtnRightDown)
	end

	if self.launchState == LaunchState.DIR then
		if gGmUtils.isBowlingGameEnableDireDebug then
			if currentGame.ballLauncher.objArrowTips then
				local mouseX = UnityEngine.Input.mousePosition.x
				local t = mouseX / UnityEngine.Screen.width * 2 - 1
				local yAngle = t * 45
				local localEuler = currentGame.ballLauncher.objArrowTips.transform.localEulerAngles
				localEuler.y = Mathf.Clamp(yAngle, -4.5, 4.5)
				currentGame.ballLauncher.objArrowTips.transform.localEulerAngles = localEuler
				currentGame.ballLauncher.launchDir = localEuler.y
			end
		else
			currentGame:ExecuteLongPressDirAuto()
		end
	end

	if self.launchState == LaunchState.POWER then
		local powerPercent = currentGame:ExecuteLongPressPowerAuto()

		self:UpdatePower(powerPercent)
	end

	if self:NeedSync() then
		local currentTime = Time.realtimeSinceStartup

		if self.nextSyncLaunchTime == nil or self.nextSyncLaunchTime < currentTime then
			self.nextSyncLaunchTime = currentTime + 0.2

			self:SyncLaunchState()
		end
	end
end

function M:UpdatePower(powerPercent)
	local currentTime = Time.realtimeSinceStartup

	if self:NeedSync() and (self.nextSyncPowerTime == nil or self.nextSyncPowerTime < currentTime) then
		self.nextSyncPowerTime = currentTime + 0.2

		self:BroadcastLaunchStateInfo("UpdatePower", powerPercent)
	end

	self.bindData.progress.value = powerPercent
	self.bindData.BallpowerFill.fillAmount = powerPercent
	self.bindData.PowerNum.text = math.ceil(powerPercent * 100)
end

function M:OnClose()
	self.isClosed = true
	self.coroutineSuccIconShow = coroutine.stop(self.coroutineSuccIconShow)
	self.coroutineFrameDescHide = coroutine.stop(self.coroutineFrameDescHide)

	self:ClearMessageEvents()
end

function M:OnDestroy()
	self.ballSpiritList = nil
	self.hasDestroy = true
	self.waitAnimationCo = coroutine.stop(self.waitAnimationCo)
	self.startButtonUpClickCo = coroutine.stop(self.startButtonUpClickCo)
	self.startButtonDownClickCo = coroutine.stop(self.startButtonDownClickCo)
	self.startDotRightClickCo = coroutine.stop(self.startDotRightClickCo)
	self.startDotLeftClickCo = coroutine.stop(self.startDotLeftClickCo)

	self.bindData.ULanuchRot.gameObject.transform:DOKill()
	self.bindData.ULanuchPower.gameObject.transform:DOKill()
	self.ballRotationTransform:DOKill()

	self.ballRotationTweener = nil
end

function M:InitUI()
	if not self.ballIndex then
		self.ballIndex = math.ceil(#Config.prefabPaths.balls / 2)
	end

	self.ballIndexMin = 1
	self.ballIndexMax = #Config.prefabPaths.balls - 1
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

function M:BtnRotRightOnClick()
	self:OnRotationButtonClick("right")
end

function M:BtnRotLeftOnClick()
	self:OnRotationButtonClick("left")
end

function M:OnSliderValueChanged(value)
	if self:IsRemotePlayerTurn() then
		return
	end

	local currentGame = gBowlingGameManager.currentGame
	self.minLaunchOffset = Config.minLaunchOffset
	self.maxLaunchOffset = Config.maxLaunchOffset
	local percent = value / self.bindData.slider.maxValue
	local launchOffset = self:MapLaunchOffset(percent)

	currentGame:SetChargingPos(launchOffset, percent)
end

function M:MapLaunchOffset(x)
	return Config.minLaunchOffset - (Config.minLaunchOffset - Config.maxLaunchOffset) * x
end

function M:UpdateRotHeight()
	if self:NotInteractable() or self.hasDestroy then
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

function M:UpdateRotationIndicators(side, level)
	local indicators = RotationIndicators[side]

	for i = 1, MaxRotationLevel do
		local indicatorName = indicators[i]
		local indicator = self.bindData[indicatorName]

		indicator.gameObject:SetActive(i <= level)
	end
end

function M:UpdatePowerRot(rotIndex)
	if self:NeedSync() then
		self:BroadcastLaunchStateInfo("UpdatePowerRot", rotIndex)
	end

	local leftLevel = math.max(0, -rotIndex)
	local rightLevel = math.max(0, rotIndex)

	self:UpdateRotationIndicators("left", leftLevel)
	self:UpdateRotationIndicators("right", rightLevel)
end

function M:ClearPowerRot(isRight)
	if isRight then
		self:UpdateRotationIndicators("right", 0)
	else
		self:UpdateRotationIndicators("left", 0)
	end
end

function M:PlayRotationAnimation(config)
	local animation = config.direction == 1 and self.bindData.ballRotationRightAnimation or self.bindData.ballRotationLeftAnimation

	gCS.LuaUtils.PlayAnimationByName(animation, config.tipsAnim)

	if self.RotIndex == 0 then
		self.ballRotationTweener:Kill()

		self.ballRotationTweener = nil
	end

	if self.RotIndex * config.direction > 0 then
		if not self.ballRotationTweener then
			local rotationZ = config.direction > 0 and -360 or 360
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

function M:OnRotationButtonClick(direction)
	if gBowlingGameManager.currentGame:GetIsNpc() then
		return
	end

	if self.launchState ~= LaunchState.ROT then
		return
	end

	local config = RotationConfig[direction]
	local newRotIndex = self.RotIndex + config.direction

	if newRotIndex >= -MaxRotationLevel and newRotIndex <= MaxRotationLevel then
		self.RotIndex = newRotIndex

		self:PlayRotationAnimation(config)
		self:UpdatePowerRot(self.RotIndex)
		gBowlingGameManager.currentGame:ExecutePressRot(self.RotIndex)
	end
end

function M:LaunchNextState()
	if gBowlingGameManager.currentGame:GetIsNpc() then
		return
	end

	if self.launchState == LaunchState.ROT then
		return
	end

	self.isBallPosBtnRightDown = false
	self.isBallPosBtnLeftDown = false

	gBowlingGameManager.currentGame:ExecuteShootKeyUp()
end

function M:BallPosBtnRightOnPress()
	if gBowlingGameManager.currentGame:GetIsNpc() then
		return
	end

	gBowlingGameManager.currentGame:ExecuteShootKeyDown()

	self.isBallPosBtnRightDown = true
end

function M:BallPosBtnRightOnRelease()
	if gBowlingGameManager.currentGame:GetIsNpc() then
		return
	end

	self.isBallPosBtnRightDown = false
end

function M:BallPosBtnLeftOnPress()
	if gBowlingGameManager.currentGame:GetIsNpc() then
		return
	end

	gBowlingGameManager.currentGame:ExecuteShootKeyDown()

	self.isBallPosBtnLeftDown = true
end

function M:BallPosBtnLeftOnRelease()
	if gBowlingGameManager.currentGame:GetIsNpc() then
		return
	end

	self.isBallPosBtnLeftDown = false
end

function M:OnExitClick()
	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
		isSuccess = false
	})

	self.IsExit = true

	gBowlingGameManager:ExecuteExitGame()
end

function M:NextBall()
	self.bindData.BallpowerFill.fillAmount = 0
	self.bindData.PowerNum.text = 0
end

function M:GetScoreText(score)
	if score > 0 then
		return tostring(score)
	end

	return "-"
end

function M:RefreshFrameDesc(_, params)
	if gBowlingGameManager.currentGame.maxFrames < params.frame then
		return
	end

	local delay = 0

	if params.frame == 2 then
		self.bindData.roundText = LTConfig.TextScriptTextConfig.GetConfig(89901325).Text
	elseif params.frame == 3 then
		self.bindData.roundText = LTConfig.TextScriptTextConfig.GetConfig(89901326).Text
	end

	self.bindData.roundNode:SetActive(true)
	self.bindData.switchNode:SetActive(false)

	if params.isSwitch then
		delay = 1.3

		if params.playerIndex ~= 1 then
			self.bindData.switchNode:SetActive(true)
			self.bindData.roundNode:SetActive(false)
		end
	end

	self.coroutineFrameDescHide = coroutine.start(function ()
		if delay > 0 then
			coroutine.wait(delay)
		end

		self:RefreshSuccessIcon(0, 0)
		self.bindData.Mid.gameObject:SetActive(true)
		coroutine.wait(2)
		self.bindData.Mid.gameObject:SetActive(false)
	end)
end

function M:RefreshPlayerView(_, params)
	if self:NotInteractable() then
		return
	end

	self:NextBall()

	local total = 0

	for _, score in ipairs(params.frameScores) do
		total = total + score
	end

	local succType = params.frameSpare[params.currentFrame]

	self:RefreshSuccessIcon(succType, total)

	self.coroutineSuccIconShow = coroutine.start(function ()
		coroutine.wait(3)
		self:RefreshSuccessIcon(0, 0)
	end)
end

function M:OnPanelShow(_, panelId)
	if panelId == gPanelId.MINI_GAMES_BOWLING_TECH_PINS_PANEL then
		self.bindData.BtnF:SetActive(false)
	end
end

function M:OnPanelClose(_, panelId)
	if panelId == gPanelId.MINI_GAMES_BOWLING_TECH_PINS_PANEL then
		self.bindData.BtnF:SetActive(true)
	end
end

function M:RefreshSuccessIcon(currentFrameResult, totalScore)
	if self:NotInteractable() then
		return
	end

	if totalScore == 90 then
		self.bindData.IconPrefect.gameObject:SetActive(true)
	elseif currentFrameResult == 1 then
		self.bindData.IconStrike.gameObject:SetActive(true)
	elseif currentFrameResult == 2 then
		self.bindData.IconSpare.gameObject:SetActive(true)
	else
		self.bindData.IconStrike.gameObject:SetActive(false)
		self.bindData.IconSpare.gameObject:SetActive(false)
		self.bindData.IconPrefect.gameObject:SetActive(false)
	end
end

function M:RefreshPinState(_, params)
	if self:NotInteractable() then
		return
	end

	self.lastStandingPins = self.lastStandingPins or params.standingPins
	local hasScore = #params.standingPins < #self.lastStandingPins
	self.lastStandingPins = params.standingPins

	self:ResetPinState(false)

	local function refreshPinsState()
		local pinState = self.bindData.PinsState

		for _, pinIndex in ipairs(params.standingPins) do
			local pn = "PT" .. tostring(pinIndex)
			local bUi = pinState.transform:Find(pn)

			bUi.gameObject:SetActive(true)
		end
	end

	if hasScore then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.pinsStateAnimation, "S_vx_ui_panel_Bowling_PinsState")

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

function M:ResetPinState(bState)
	if self:NotInteractable() then
		return
	end

	local pinState = self.bindData.PinsState

	for i = 1, 10 do
		local pn = "PT" .. tostring(i)
		local bUi = pinState.transform:Find(pn)

		bUi.gameObject:SetActive(bState)
	end
end

function M:OnButtonUpClick()
	if gBowlingGameManager.currentGame:GetIsNpc() or self:IsRemotePlayerTurn() then
		return
	end

	if self.bindData.ballAnimation.isPlaying then
		return
	end

	if self.ballIndex < self.ballIndexMax then
		self.ballIndex = self.ballIndex + 1
		local time = gCS.LuaUtils.PlayAnimationByName(self.bindData.ballAnimation, "S_vx_ui_panel_Bowling_ball_down")
		self.waitAnimationCo = coroutine.start(function ()
			coroutine.wait(time)
			self:ShowBallIcon(self.ballIndex)
		end)
	end

	gBowlingGameManager.currentGame:SelectBall(self.ballIndex)
end

function M:OnButtonDownClick()
	if gBowlingGameManager.currentGame:GetIsNpc() or self:IsRemotePlayerTurn() then
		return
	end

	if self.bindData.ballAnimation.isPlaying then
		return
	end

	if self.ballIndexMin < self.ballIndex then
		self.ballIndex = self.ballIndex - 1
		local time = gCS.LuaUtils.PlayAnimationByName(self.bindData.ballAnimation, "S_vx_ui_panel_Bowling_ball_up")
		self.waitAnimationCo = coroutine.start(function ()
			coroutine.wait(time)
			self:ShowBallIcon(self.ballIndex)
		end)
	end

	gBowlingGameManager.currentGame:SelectBall(self.ballIndex)
end

function M:ShowBallIcon(ballIndex)
	if self:NeedSync() then
		self:BroadcastLaunchStateInfo("ShowBallIcon", ballIndex)
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

function M:ClearLaunchUI()
	if self:NotInteractable() then
		return
	end

	self.bindData.ULanuchSel.gameObject:SetActive(false)
	self.bindData.ULanuchPos.gameObject:SetActive(false)
	self.bindData.ULanuchDir.gameObject:SetActive(false)
	self.bindData.ULanuchPower.gameObject:SetActive(false)
	self.bindData.ULanuchRot.gameObject:SetActive(false)

	if self.ballRotationTweener then
		self.ballRotationTweener:Kill()

		self.ballRotationTweener = nil
		self.ballRotationTransform.rotation = Quaternion.identity
	end

	self:ClearPowerRot(false)
	self:ClearPowerRot(true)

	self.bindData.launchRotCtrl = 0
end

function M:ClearDescUI()
	if self:NotInteractable() then
		return
	end

	self.bindData.DescCupSelectBall.gameObject:SetActive(false)
	self.bindData.DescCupPos.gameObject:SetActive(false)
	self.bindData.DescCupRot.gameObject:SetActive(false)
	self.bindData.BtnSpace.gameObject:SetActive(false)
end

function M:RefreshBall()
	if self:NotInteractable() then
		return
	end

	self:ShowBallIcon(self.ballIndex)
	gBowlingGameManager.currentGame:SelectBall(self.ballIndex)
end

function M:RefreshLaunchUI(launchState)
	if self:NotInteractable() then
		return
	end

	if self:NeedSync() then
		self:BroadcastLaunchStateInfo("RefreshLaunchUI", launchState)
	end

	self:ClearLaunchUI()
	self:ClearDescUI()
	self.bindData.slider:SetActive(false)

	if launchState == LaunchState.POS then
		self.bindData.slider:SetActive(true)

		self.bindData.slider.value = self.bindData.slider.maxValue / 2

		self:RefreshSuccessIcon(0, 0)

		self.RotIndex = 0

		self:RefreshBall()
		self.bindData.PinsState.gameObject:SetActive(true)
		self.bindData.ULanuchSel.gameObject:SetActive(true)
		self.bindData.ULanuchPos.gameObject:SetActive(true)
		self.bindData.DescCupSelectBall.gameObject:SetActive(true)
		self.bindData.DescCupPos.gameObject:SetActive(true)
		self.bindData.BtnSpace.gameObject:SetActive(true)
	elseif launchState == LaunchState.DIR then
		self.bindData.BtnSpace.gameObject:SetActive(true)
	elseif launchState == LaunchState.POWER then
		self.bindData.ULanuchPower.gameObject:SetActive(true)
		self.bindData.BtnSpace.gameObject:SetActive(true)
	elseif launchState == LaunchState.ROT then
		self.bindData.ULanuchPower.gameObject:SetActive(true)
		self:UpdateRotHeight()
		self.bindData.ULanuchRot.gameObject:SetActive(true)
		self.bindData.DescCupRot.gameObject:SetActive(true)

		self.bindData.launchRotCtrl = 1
	elseif launchState == LaunchState.ROLLING then
		-- Nothing
	elseif launchState == LaunchState.ANIM then
		-- Nothing
	end
end

function M:OnEventLanuchState(_, params)
	if self:NotInteractable() then
		return
	end

	self.launchState = params.state

	if params.ballIndex then
		self.ballIndex = params.ballIndex
	end

	self:RefreshLaunchUI(self.launchState)
end

function M:OnEventSuccIconHide(_, params)
	if self:NotInteractable() then
		return
	end

	self:RefreshSuccessIcon(0, 0)
end

function M:OnEventNpcRot(_, params)
	if not gBowlingGameManager.currentGame:GetIsNpc() then
		return
	end

	if not self.launchState == LaunchState.ROT then
		return
	end

	if params.isRight == 1 then
		if self.RotIndex < 5 then
			self.RotIndex = self.RotIndex + 1
		end
	elseif self.RotIndex > -5 then
		self.RotIndex = self.RotIndex - 1
	end

	gBowlingGameManager.currentGame:ExecutePressRot(self.RotIndex)
	self:UpdatePowerRot(self.RotIndex)
end

function M:OnLeftStickInputChanged(context)
	local value = context:ReadValueVector2()

	if context.started or context.performed then
		if value.x > 0 then
			self:BallPosBtnLeftOnRelease()
			self:BallPosBtnRightOnPress()
		else
			self:BallPosBtnRightOnRelease()
			self:BallPosBtnLeftOnPress()
		end
	end

	if context.canceled then
		self:BallPosBtnLeftOnRelease()
		self:BallPosBtnRightOnRelease()
	end
end

function M:OnRightStickInputChanged(context)
	local value = context:ReadValueVector2()

	if context.started or context.performed then
		if value.y < 0 then
			self:OnStartButtonUpClickCo()
		else
			self:OnStartButtonDownClickCo()
		end
	end

	if context.canceled then
		self.startButtonUpClickCo = coroutine.stop(self.startButtonUpClickCo)
		self.startButtonDownClickCo = coroutine.stop(self.startButtonDownClickCo)
	end
end

function M:OnStartButtonUpClickCo()
	if self.startButtonUpClickCo then
		return
	end

	self.startButtonDownClickCo = coroutine.stop(self.startButtonDownClickCo)

	self:OnButtonUpClick()

	self.startButtonUpClickCo = coroutine.start(function ()
		while true do
			coroutine.wait(0.5)
			self:OnButtonUpClick()
		end
	end)
end

function M:OnStartButtonDownClickCo()
	if self.startButtonDownClickCo then
		return
	end

	self.startButtonUpClickCo = coroutine.stop(self.startButtonUpClickCo)

	self:OnButtonDownClick()

	self.startButtonDownClickCo = coroutine.start(function ()
		while true do
			coroutine.wait(0.5)
			self:OnButtonDownClick()
		end
	end)
end

function M:OnSyncClientLaunchStateInfo(data)
	if self:NotInteractable() then
		return
	end

	self[data.method](self, unpack(data.args))
end

function M:BroadcastLaunchStateInfo(method, ...)
	local launchStateData = {
		method = method,
		args = {
			...
		}
	}

	gBowlingGameManager:BroadcastBowlingClientInfo(BowlingConstants.SyncDataType.RefreshLaunchUI, launchStateData)
end

function M:SyncLaunchState()
	local ballLauncher = gBowlingGameManager.currentGame.ballLauncher

	if ballLauncher then
		local launchStateData = ballLauncher:GetSyncLaunchStateData()

		if not table.isNilOrEmpty(launchStateData) then
			self:BroadcastLaunchStateInfo("OnSyncLaunchState", launchStateData)
		end
	end
end

function M:OnSyncLaunchState(launchStateData)
	local ballLauncher = gBowlingGameManager.currentGame.ballLauncher

	if ballLauncher then
		ballLauncher:OnSyncLaunchState(launchStateData)
	end
end

function M:NotInteractable()
	local result = self.IsExit or self.isClosed or not self.STATE_EnableOnce or (gBowlingGameManager or {}).currentGame == nil

	return result
end

function M:NeedSync()
	return gBowlingGameManager:IsOnlineGame() and gBowlingGameManager.gameMode:IsLocalPlayerTurn()
end

function M:IsRemotePlayerTurn()
	return gBowlingGameManager:IsOnlineGame() and not gBowlingGameManager.gameMode:IsLocalPlayerTurn()
end
