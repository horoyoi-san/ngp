local GymConfig = LTConfig.GymConfig
local CameraConfig = LTConfig.GymCameraConfig
local GymSitupCurveConfig = LTConfig.GymSitupCurveConfig
local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local DiversityConfigUtils = LX6.Utils.DiversityConfigUtils
local ExternalSourceType = LX6.Audio.ExternalSourceType
local GameplayEvent = MuGenStates.Logic.GameplayEvent
local MyPlayerManager = gCS.MyPlayerManager
local Side = {
	Left = 1,
	Right = 2
}
local Rating = C_GymManager.EXERCISE_RATING
local ExerciseType = C_GymManager.EXERCISE_TYPE
local SitupStage = {
	DOWN = 2,
	UP = 1,
	IDLE = 0
}
local BUBBLE_CLIPNAME = {
	"S_Vx_GameFitnessPanel_Perfect",
	"S_Vx_GameFitnessPanel_Great",
	"S_Vx_GameFitnessPanel_Good",
	"S_Vx_GameFitnessPanel_Complete"
}
local SITUP_CLIPNAME = {
	PS_Press = "S_Vx_GameFitnessPanel_BtnPressPS5",
	PS_Idle = "S_Vx_GameFitnessPanel_BtnTips2PS5",
	Idle = "S_Vx_GameFitnessPanel_BtnTips",
	Press = "S_Vx_GameFitnessPanel_BtnLongPress"
}
local SQUAT_CLIPNAME = {
	PS_Press = "S_Vx_GameFitnessPanel_BtnPressPS5",
	PS_Idle = "S_Vx_GameFitnessPanel_BtnTipsPS5",
	Idle = "S_Vx_GameFitnessPanel_BtnTips2",
	Press = "S_Vx_GameFitnessPanel_BtnPress"
}
local DUAL_NAME = {
	Squat_Great = "ExHandle_QTECommon2",
	Squat = "ExHandle_QTECommonHeavy",
	Situp_Great = "ExHandle_QTECommon2",
	BenchPress_Great = "ExHandle_QTECommon2",
	Situp_Good = "ExHandle_QTECommon1",
	Run_Great = "ExHandle_QTECommon2"
}
local Rating2BubbleCtrl = {
	[Rating.GREAT] = 1,
	[Rating.GOOD] = 2,
	[Rating.BAD] = 3,
	[Rating.NONE] = 4
}
local Type2Tab = {
	[ExerciseType.SITUP] = 0,
	[ExerciseType.BENCH_PRESS] = 1,
	[ExerciseType.SQUAT] = 2,
	[ExerciseType.RUN] = 3
}
C_GameFitnessPanelStore = DefClass("C_GameFitnessPanelStore", C_GameFitnessPanelStore, C_StoreGroup)
GroupName2Class.GameFitnessPanelStore = C_GameFitnessPanelStore
local M = C_GameFitnessPanelStore

function M:ctor()
	self.SPORT_STAGE = {
		SQUAT_BAD = 9,
		BENCH_PRESS_WAIT = 1,
		SQUAT_START = 7,
		RUN_ENTER = 10,
		SQUAT_WAIT = 6,
		SQUAT_GOOD = 8,
		BENCH_PRESS_START = 2,
		RUN_PREPARE_LOOP = 12,
		BENCH_PRESS_BAD = 4,
		RUN_BAD = 13,
		RUN_START = 11,
		BENCH_PRESS_ENTER = 0,
		BENCH_PRESS_GOOD = 3,
		SQUAT_ENTER = 5
	}
end

function M:OnAwake()
	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	self.bindData.btnSwitchCam.luaClick = self:CreateAction("OnClickBtnSwitchCam")
	self.bindData.btnSitup.luaPress = self:CreateAction("OnBeginLongPressSitup")
	self.bindData.btnSitup.luaRelease = self:CreateAction("OnEndLongPressSitup")
	self.bindData.btnBenchPressLeft.luaClick = self:CreateAction("OnClickBtnBenchPressLeft")
	self.bindData.btnBenchPressRight.luaClick = self:CreateAction("OnClickBtnBenchPressRight")
	self.bindData.btnSquat.luaClick = self:CreateAction("OnClickBtnSquat")
	self.bindData.btnSquat.luaPress = self:CreateAction("OnPressBtnSquat")
	self.bindData.runBtnLeft.luaClick = self:CreateAction("OnRunBtnLeftClick")
	self.bindData.runBtnRight.luaClick = self:CreateAction("OnRunBtnRightClick")
	self.bindData.runSpeedUp.luaClick = self:CreateAction("OnRunSpeedUpClick")
	self.bindData.runSpeedDown.luaClick = self:CreateAction("OnRunSpeedDownClick")

	if self.isMobile then
		local dragBtn = SGUI.EventSystems.DragEventListener.Get(self.bindData.squatQTEBtnMobile.gameObject)
		dragBtn.onBeginDrag = self:CreateAction("OnSquatQTEBtnBeginDrag")
		dragBtn.onDrag = self:CreateAction("OnSquatQTEBtnDragging")
		dragBtn.onEndDrag = self:CreateAction("OnSquatQTEBtnEndDrag")
		local runSpeedDragBtn = SGUI.EventSystems.DragEventListener.Get(self.bindData.runSpeedSlider.gameObject)
		runSpeedDragBtn.onBeginDrag = self:CreateAction("OnRunSpeedBtnBeginDrag")
		runSpeedDragBtn.onDrag = self:CreateAction("OnRunSpeedBtnDragging")
		runSpeedDragBtn.onEndDrag = self:CreateAction("OnRunSpeedBtnEndDrag")
	else
		self.bindData.squatQTEBtn.luaPress = self:CreateAction("OnSquatQTEBtnPress")
		self.bindData.squatFailedQTEBtn1.luaPress = self:CreateAction("OnSquatQTEFailedBtnPress")
		self.bindData.squatFailedQTEBtn2.luaPress = self:CreateAction("OnSquatQTEFailedBtnPress")
		self.bindData.squatFailedQTEBtn3.luaPress = self:CreateAction("OnSquatQTEFailedBtnPress")

		if self.bindData.runCustomWheelRespond then
			self.bindData.runCustomWheelRespond.luaGamePadInputChanged = self:CreateAction("OnRunSpeedChangeInput")
		end
	end

	if self.bindData.customNavRespond then
		self.bindData.customNavRespond.luaGamePadInputChanged = self:CreateAction("OnRotateCameraInput")
	end

	if self.bindData.runSpeedAxis then
		self.bindData.runSpeedAxis.luaGamePadInputChanged = self:CreateAction("OnRunSpeedAxis")
	end

	self.gameplayHudPanelStore = nil
	self.fixedFrameCount = nil
	self.curExerciseType = nil
	self.curExerciseCfg = nil
	self.isPauseGame = true
	self.fixedUpdateHandler = nil
	self.updateHandler = nil
	self.duration = nil
	self.countDownStartTime = nil
	self.countDownNowTime = nil
	self.countDownEndTime = nil
	self.blockFramer = 0
	self.blockAllFrame = 0
	self.blockFinishAction = nil
	self.isBlock = false
	self.ratingCount = {
		[Rating.NONE] = 0,
		[Rating.GOOD] = 0,
		[Rating.GREAT] = 0,
		[Rating.BAD] = 0
	}
	self.ratingFactorCount = {
		[Rating.NONE] = 0,
		[Rating.GOOD] = 0,
		[Rating.GREAT] = 0,
		[Rating.BAD] = 0
	}
	self.ratingTimer = nil
	self.curDialogId = 0
	self.curCameraIndex = 0
	self.maxCameraIndex = 0
	self.cameraList = {}
	self.successCount = 0
	self.bubbleAnims = {}
	self.isRotatingCamera = false
	self.rotateParam = nil
	self.curRatio = 0
	self.lastRatio = 0
	self.initFullDuration = 50
	self.curFullDuration = 0
	self.fullFramer = 0
	self.modifyFullSpeed = 1
	self.greatShrinkList = {}
	self.goodShrinkList = {}
	self.curGoodFill = 0
	self.curGreatFill = 0
	self.isLongPressBtnSitup = false
	self.curSitupStage = SitupStage.IDLE
	self.isGetUpFrame = false
	self.isGetDownFrame = false
	self.curSitupCurveCfg = nil
	self.situpCurve = nil
	self.situpCurveStage = 0
	self.waitDecay = false
	self.maxGrid = 0
	self.gridCount = {
		[Side.Left] = 0,
		[Side.Right] = 0
	}
	self.confirmTime = {
		[Side.Left] = 0,
		[Side.Right] = 0
	}
	self.decayStartTime = 0
	self.decayInterval = 0
	self.checkFramer = {
		[Side.Left] = 0,
		[Side.Right] = 0
	}
	self.decayFramer = {
		[Side.Left] = 0,
		[Side.Right] = 0
	}
	self.isDecay = {
		[Side.Left] = false,
		[Side.Right] = false
	}
	self.pressAnimTimer = {
		[Side.Left] = nil,
		[Side.Right] = nil
	}
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
	self.runAnimSpeed = 0
	self.runSpeedDecreaseFactor = 1
	self.runSpeedGreatScoreFactor = 1
end

function M:OnDestroy()
	self:RemoveBanKey()

	if self.ratingTimer then
		self.ratingTimer:Stop()

		self.ratingTimer = nil
	end

	self:UnRegisterUpdate()

	if self.openAnimTimer then
		self.openAnimTimer:Stop()

		self.openAnimTimer = nil
	end

	gGymManager.curGamePanel = nil
end

function M:OnActiveDeviceChange(scheme)
	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < scheme

	if SGUI.GameDevice.KeyboardMouse < self.scheme and scheme == SGUI.GameDevice.KeyboardMouse then
		self.bindData.btnBenchPressControllerRightAnim:Stop()
		self.bindData.btnBenchPressControllerLeftAnim:Stop()
		self.bindData.btnSitupControllerAnim:Stop()

		self.isRotatingCamera = false
	elseif self.scheme == SGUI.GameDevice.KeyboardMouse and SGUI.GameDevice.KeyboardMouse < scheme and (self.curExerciseType == ExerciseType.SQUAT or self.curExerciseType == ExerciseType.BENCH_PRESS) then
		self.bindData.btnBenchPressControllerRightAnim:Play(SQUAT_CLIPNAME.PS_Idle)
		self.bindData.btnBenchPressControllerLeftAnim:Play(SQUAT_CLIPNAME.PS_Idle)
	end

	self.scheme = scheme

	if self.curExerciseType == ExerciseType.SQUAT then
		if self.randomSquatQTEIndex then
			local pcKey = self.squatPCQTEKeys[self.randomSquatQTEIndex]
			local gamepadKey = self.squatGamepadQTEKeys[self.randomSquatQTEIndex]

			if pcKey and gamepadKey then
				self.bindData.squatQTEKeyText = self.gamepadMode and gamepadKey.name or pcKey.name
			end
		end

		self:RefreshShowGamepadControllerKey()
	end
end

function M:OnStart()
	return
end

function M:StartGame()
	self.isPauseGame = false
	self.countDownStartTime = Time.time
	self.countDownEndTime = self.countDownStartTime + self.duration

	self:RegisterUpdate()
	self:PlayStartAnim()
end

function M:PlayStartAnim()
	if self.curExerciseType == ExerciseType.SQUAT then
		if self.isMobile then
			self.bindData.btnSquatAnim:Play(SQUAT_CLIPNAME.Idle)
			self.bindData.btnSquatAnim:Play(SQUAT_CLIPNAME.Idle)
		end
	elseif self.curExerciseType == ExerciseType.SITUP then
		if self.isMobile then
			self.bindData.btnSitupAnim:Play(SITUP_CLIPNAME.Idle)
		elseif SGUI.GameDevice.KeyboardMouse < self.scheme then
			self.bindData.btnSitupControllerAnim:Play(SITUP_CLIPNAME.PS_Idle)
		end
	elseif self.curExerciseType == ExerciseType.BENCH_PRESS then
		if self.isMobile then
			self.bindData.btnBenchPressLeftAnim:Play(SQUAT_CLIPNAME.Idle)
			self.bindData.btnBenchPressRightAnim:Play(SQUAT_CLIPNAME.Idle)
		elseif SGUI.GameDevice.KeyboardMouse < self.scheme then
			self.bindData.btnBenchPressControllerLeftAnim:Play(SQUAT_CLIPNAME.PS_Idle)
			self.bindData.btnBenchPressControllerRightAnim:Play(SQUAT_CLIPNAME.PS_Idle)
		end
	end
end

function M:RegisterUpdate()
	self.fixedUpdateHandler = FixedUpdateBeat:CreateListener(self.FixedUpdate, self)

	FixedUpdateBeat:AddListener(self.fixedUpdateHandler)

	self.updateHandler = UpdateBeat:CreateListener(self.Update, self)

	UpdateBeat:AddListener(self.updateHandler)
end

function M:UnRegisterUpdate()
	if self.fixedUpdateHandler then
		FixedUpdateBeat:RemoveListener(self.fixedUpdateHandler)

		self.fixedUpdateHandler = nil
	end

	if self.updateHandler then
		UpdateBeat:RemoveListener(self.updateHandler)

		self.updateHandler = nil
	end
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.gameplayHudPanelStore = gStoreManager:GetStoreGroup("GameplayHudPanelStore")
	self.scheme = gCS.LuaUtils.GetActiveDevice()
	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	gGymManager.curGamePanel = self
	self.isShow = true
	self.curExerciseType = data.type
	self.curExerciseCfg = data.cfg
	self.fixedFrameCount = math.floor(1 / Time.fixedDeltaTime)
	self.duration = data.duration
	local cameraIds = data.cameraIds
	self.maxCameraIndex = cameraIds and #cameraIds or 0

	for i = 1, self.maxCameraIndex do
		self.cameraList[i] = CameraConfig.GetConfig(cameraIds[i])
	end

	if self.curExerciseType == ExerciseType.SQUAT then
		self:InitSquatGame()
	elseif self.curExerciseType == ExerciseType.SITUP then
		self:InitSitup()
	elseif self.curExerciseType == ExerciseType.BENCH_PRESS then
		self:InitBenchPressGame()
	elseif self.curExerciseType == ExerciseType.RUN then
		self:InitRunGame()
	else
		print_error("无法处理的ExerciseType=", self.curExerciseType)

		return
	end

	self.bubbleAnims = self.bindData.bubbleTrans:GetComponentsInChildren(typeof(UnityEngine.Animation)):ToTable()

	self:RefreshScore()

	self.bindData.progressCountDown.value = 1

	self.gameplayHudPanelStore:OpenStartAnime(function ()
		self.gameplayHudPanelStore:RegisterBtnBackCallback(function ()
			self:EndAction()
			gGymManager:SettleExercise(nil, 0.1 + self.blockFramer / self.fixedFrameCount)
		end)

		self.bindData.tabCtrl = Type2Tab[self.curExerciseType]
		self.bindData.showRootCtrl = 1

		self.bindData.openAnim:Play()

		self.openAnimTimer = Timer.New(function ()
			self:StartGame()
		end, self.bindData.openAnim.clip.length):Start()
	end, nil, self.curExerciseCfg.BeginIcon)

	local backBtn = self.gameplayHudPanelStore.bindData.btnExit

	if data.hideExitBtn then
		if backBtn then
			backBtn:SetActive(false)
		end
	elseif backBtn then
		backBtn:SetActive(true)
	end
end

function M:OnClose()
	self.isShow = false
	local backBtn = self.gameplayHudPanelStore and self.gameplayHudPanelStore.bindData.btnExit

	if backBtn then
		backBtn:SetActive(true)
	end
end

function M:Update()
	self:OnRotateCameraUpdate()

	if self.isPauseGame then
		return
	end

	self.countDownNowTime = Time.time

	if self.countDownEndTime < self.countDownNowTime then
		self:EndAction()
		gGymManager:SettleExercise({
			result = self.ratingFactorCount
		}, 0.1 + self.blockFramer / self.fixedFrameCount)

		return
	end

	local countDownRemainTime = self.countDownEndTime - self.countDownNowTime
	self.bindData.countDownText = gTimeUtils:FormatTime(countDownRemainTime, true)
	self.bindData.progressCountDown.value = countDownRemainTime / self.duration
end

function M:FixedUpdate()
	if self.isPauseGame then
		return
	end

	if self.isBlock then
		if self.blockFramer > 0 then
			self.blockFramer = self.blockFramer - 1
		else
			if self.blockFinishAction then
				self.blockFinishAction()
			end

			self.blockFinishAction = nil
			self.isBlock = false

			self:RefreshShowGamepadControllerKey()
		end
	end

	if self.curExerciseType == ExerciseType.SQUAT then
		local side = Side.Left

		self:DecayFrame(side)

		if not self.qteEnable and not self.isDecay[side] and self.gridCount[side] > 0 then
			self.checkFramer[side] = self.checkFramer[side] + 1

			if self.decayStartTime < self.checkFramer[side] then
				self.checkFramer[side] = 0

				self:StartDecay(side)
			end
		end

		self:RefreshSquatProgressBar()

		if self.qteEnable and self.squatQTEStartTime and self.squatMinQTETime < os.clock() - self.squatQTEStartTime then
			self.squatQTEStartTime = nil

			self:SquatQTEActionFailed(false)
		end
	elseif self.curExerciseType == ExerciseType.BENCH_PRESS then
		for i = 1, 2 do
			self:DecayFrame(i)

			if not self.isDecay[i] and self.gridCount[i] > 0 then
				self.checkFramer[i] = self.checkFramer[i] + 1

				if self.decayStartTime < self.checkFramer[i] then
					self.checkFramer[i] = 0

					self:StartDecay(i)
				end
			end
		end

		self:RefreshProgressBar()
	elseif self.curExerciseType == ExerciseType.SITUP then
		if self.curSitupStage == SitupStage.DOWN then
			if self.fullFramer > 0 then
				self.fullFramer = self.fullFramer - 1
			end
		elseif self.curSitupStage == SitupStage.UP then
			if self.isLongPressBtnSitup then
				self.fullFramer = self.fullFramer + 1

				if self.curFullDuration <= self.fullFramer then
					self:Timeout()
				end
			else
				self:Judge()
			end
		elseif self.curSitupStage == SitupStage.IDLE and self.isLongPressBtnSitup then
			self:SitupStartUp()
		end

		self:RefreshPointer()
	elseif self.curExerciseType == ExerciseType.RUN then
		self:UpdateRun()
	end
end

function M:OnActionChange(actionTime)
	if actionTime > 1000 then
		return
	end

	actionTime = math.abs(actionTime)

	if self.curExerciseType == ExerciseType.SITUP then
		if self.curSitupStage == SitupStage.DOWN then
			if not self.isGetDownFrame then
				self.isGetDownFrame = true
				self.blockFramer = math.max(self.blockFramer, actionTime * self.fixedFrameCount + 5)
				self.curFullDuration = actionTime * self.fixedFrameCount
				self.fullFramer = self.curRatio * self.curFullDuration
			end
		elseif self.curSitupStage == SitupStage.UP then
			if not self.isGetUpFrame then
				self.isGetUpFrame = true
				self.curFullDuration = actionTime * self.fixedFrameCount
			else
				self:Timeout(true)

				self.isGetDownFrame = true
				self.blockFramer = math.max(self.blockFramer, actionTime * self.fixedFrameCount + 5)
				self.curFullDuration = actionTime * self.fixedFrameCount
				self.fullFramer = self.curRatio * self.curFullDuration
			end
		end
	end
end

function M:EndAction()
	if self.curExerciseType == ExerciseType.SITUP and self.curSitupStage == SitupStage.UP then
		self:Judge(true)
	end
end

function M:InitSitup()
	self.lengthLimit = self.bindData.progressSitup.rectTransform.rect.height
	self.bindData.progressSitup.value = 0
	self.modifyFullSpeed = GymConfig.NewSitup_InitialCursorSpeed
	self.curFullDuration = self.initFullDuration / self.modifyFullSpeed
	local attr = gSpiritManager:GetUrbanAttr(gBattleSpiritMgr.currentSpiritTemplateId)
	self.curGoodFill = Formula_cs:CalNewSitup_InitialGoodRange(attr, GymConfig.NewSitup_InitialGoodRange)
	self.curGreatFill = Formula_cs:CalNewSitup_InitialGreatRange(attr, GymConfig.NewSitup_InitialGreatRange)

	self:RefreshJudgeArea()

	self.greatShrinkList = GymConfig.NewSitup_GreatRangeReductionRatio
	self.goodShrinkList = GymConfig.NewSitup_GoodRangeReductionRatio
	self.curSitupCurveCfg = self:GetCurveConfigBySpiritId(gBattleSpiritMgr.currentSpiritTemplateId)
	self.situpCurve = DiversityConfigUtils.ImportAnimationCurve(self.curSitupCurveCfg.SitupCurve)
	self.situpCurveStage = 1

	if self.isMobile then
		self.effectShow = true

		self.bindData.situpEffectR.gameObject:SetActive(true)
	end
end

function M:RefreshPointer()
	if self.curSitupStage == SitupStage.UP then
		self.curRatio = self.situpCurve:Evaluate(self.fullFramer / self.curFullDuration)
	elseif self.curSitupStage == SitupStage.DOWN then
		self.curRatio = self.fullFramer / self.curFullDuration
	else
		self.curRatio = 0
	end

	self.bindData.progressSitup.value = self.curRatio
end

function M:RefreshJudgeArea()
	self.bindData.goodFill = self.curGoodFill
	self.bindData.greatFill = self.curGreatFill

	self.bindData.greatFillTrans:SetLocalPositionY((self.curGreatFill - self.curGoodFill) * 0.5 * self.lengthLimit)
end

function M:Judge(ignoreScore)
	if self.isBlock then
		return
	end

	self.curSitupStage = SitupStage.DOWN
	local goodDownLimit = 1 - self.curGoodFill
	local goodUpLimit = 1
	local greatDownLimit = 1 - (self.curGoodFill + self.curGreatFill) * 0.5
	local greatUpLimit = 1 - (self.curGoodFill - self.curGreatFill) * 0.5
	local curRating = Rating.NONE

	if greatDownLimit <= self.curRatio and self.curRatio <= greatUpLimit then
		curRating = Rating.GREAT

		gGymManager:SetSignal("SU_DownNormal")
		gSoundMgr:PlaySoundByExternalSource(DUAL_NAME.Situp_Great, ExternalSourceType.Motion_2D)
	elseif goodDownLimit <= self.curRatio and self.curRatio <= goodUpLimit then
		curRating = Rating.GOOD

		gGymManager:SetSignal("SU_DownNormal")
		gSoundMgr:PlaySoundByExternalSource(DUAL_NAME.Situp_Good, ExternalSourceType.Motion_2D)
	else
		curRating = Rating.NONE

		gGymManager:SetSignal("SU_DownBreak")
	end

	self:AdjustDifficulty_Situp(curRating)

	self.fullFramer = self.curRatio * self.curFullDuration

	self:SetBlockFramer(self.fullFramer, function ()
		self.fullFramer = 0
		self.curSitupStage = SitupStage.IDLE

		self:PlayStartAnim()
	end)

	self.isGetDownFrame = false

	gGamePlayTransitionMgr:CheckSwitchAction()

	if not ignoreScore then
		self:IncreaseRating(curRating)

		if curRating ~= Rating.NONE then
			self:ShowRating(curRating)
			self:RefreshScore()
		end
	end
end

function M:IncreaseRating(rating, factor)
	self.ratingCount[rating] = self.ratingCount[rating] + 1
	self.ratingFactorCount[rating] = self.ratingFactorCount[rating] + (factor or 1)

	if self.curExerciseCfg.IsTask then
		gClientToGameDelegate:AskCompleteSingleGymExercise(self.curExerciseCfg.Id, rating)
	end
end

function M:SitupStartUp()
	self.curSitupStage = SitupStage.UP
	self.isGetUpFrame = false

	gGymManager:SetSignal("SU_Up")
	gGamePlayTransitionMgr:CheckSwitchAction()

	if self.isMobile then
		self.bindData.btnSitupAnim:Play(SITUP_CLIPNAME.Press)
	elseif SGUI.GameDevice.KeyboardMouse < self.scheme then
		self.bindData.btnSitupControllerAnim:Play(SITUP_CLIPNAME.PS_Press)
	end
end

function M:Timeout(isAuto)
	if self.isBlock then
		return
	end

	self.curSitupStage = SitupStage.DOWN

	self:IncreaseRating(Rating.BAD)
	self:AdjustDifficulty_Situp(Rating.NONE)
	self:SetBlockFramer(self.fullFramer, function ()
		self.fullFramer = 0
		self.curSitupStage = SitupStage.IDLE

		self:PlayStartAnim()
	end)

	if not isAuto then
		self.isGetDownFrame = false

		gGymManager:SetSignal("SU_DownOver")
		gGamePlayTransitionMgr:CheckSwitchAction()
	end

	gMessageManager:SendMessage(gEventConstants.GYM_TASK_TIP_CHANGED, {
		counter = self.ratingCount
	})
	self:ShowRating(Rating.BAD)
	self:RefreshScore()
end

function M:AdjustDifficulty_Situp(rating)
	if rating == Rating.GOOD then
		self.curGoodFill = self.curGoodFill * self.goodShrinkList[Mathf.Clamp(self.ratingCount[Rating.GOOD], 1, #self.goodShrinkList)]
	elseif rating == Rating.GREAT then
		self.curGreatFill = self.curGreatFill * self.greatShrinkList[Mathf.Clamp(self.ratingCount[Rating.GREAT], 1, #self.greatShrinkList)]
	end

	self:RefreshJudgeArea()

	if self.situpCurveStage < 3 then
		if rating == Rating.GOOD or rating == Rating.GREAT then
			self.successCount = self.successCount + 1
		end

		if GymConfig.NewSitup_SwitchCurveTimes < self.successCount then
			self.successCount = 0
			self.situpCurveStage = self.situpCurveStage + 1

			if self.situpCurveStage == 2 then
				self.situpCurve = DiversityConfigUtils.ImportAnimationCurve(self.curSitupCurveCfg.SitupCurve2)
			elseif self.situpCurveStage == 3 then
				self.situpCurve = DiversityConfigUtils.ImportAnimationCurve(self.curSitupCurveCfg.SitupCurve3)
			else
				print_error("仰卧起坐曲线计算错误")
			end
		end
	end
end

function M:InitBenchPressGame()
	local attr = gSpiritManager:GetUrbanAttr(gBattleSpiritMgr.currentSpiritTemplateId)
	self.maxGrid = Formula_cs:CalSquat_InitialCount(attr, GymConfig.BenchPress_InitialCount)
	self.decayStartTime = GymConfig.BenchPress_InitialDecayStartTime * self.fixedFrameCount
	self.decayInterval = GymConfig.BenchPress_InitialDecayRate * self.fixedFrameCount

	self:RefreshDivideGrid()

	self.sendStartSport = false
	self.curSportStage = self.SPORT_STAGE.BENCH_PRESS_ENTER
	self.isSportBlock = true
	self.needAdjustSportDifficulty = nil
	self.confirmDelayTime = GymConfig.BenchPress_MinInterval
end

function M:ConfirmBenchPress(curSide)
	if self.isSportBlock or self.isBlock then
		return
	end

	local curTime = os.clock()

	if self.confirmDelayTime and curTime - self.confirmTime[curSide] <= self.confirmDelayTime then
		return
	end

	self.confirmTime[curSide] = curTime

	gSoundMgr:PlaySoundByExternalSource(DUAL_NAME.Squat, ExternalSourceType.Motion_2D)

	if self.isMobile then
		local anim = curSide == Side.Left and self.bindData.btnBenchPressLeftAnim or self.bindData.btnBenchPressRightAnim

		anim:Stop()
		anim:Play(SQUAT_CLIPNAME.Press)
	elseif SGUI.GameDevice.KeyboardMouse < self.scheme then
		if self.pressAnimTimer[curSide] then
			self.pressAnimTimer[curSide]:Stop()
		end

		local anim = curSide == Side.Left and self.bindData.btnBenchPressControllerLeftAnim or self.bindData.btnBenchPressControllerRightAnim

		anim:Stop()
		anim:Play(SQUAT_CLIPNAME.PS_Press)

		self.pressAnimTimer[curSide] = Timer.New(function ()
			if gPanelManager:IsPanelShowing(gPanelId.S_GAMEPLAY_HUD_PANEL) and anim then
				anim:Play(SQUAT_CLIPNAME.PS_Idle)
			end
		end, 0.17):Start()
	end

	self.isDecay[curSide] = false
	self.checkFramer[curSide] = 0

	if self.gridCount[curSide] < self.maxGrid then
		self.gridCount[curSide] = self.gridCount[curSide] + 1
	end

	if self.sendStartSport then
		self:JudeBadBenchPress()
	elseif self.gridCount[Side.Left] > 0 and self.gridCount[Side.Right] > 0 then
		gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.GymStartBenchPress)

		self.curSportStage = self.SPORT_STAGE.BENCH_PRESS_START
		self.sendStartSport = true
	end

	if self.gridCount[Side.Left] == self.maxGrid and self.gridCount[Side.Right] == self.maxGrid then
		gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.GymGoodBenchPress)

		self.curSportStage = self.SPORT_STAGE.BENCH_PRESS_GOOD

		if self.gridCount[Side.Left] > 0 or self.gridCount[Side.Right] > 0 then
			self.waitDecay = true
		end

		self.isSportBlock = true
		self.sendStartSport = false

		self:IncreaseRating(Rating.GREAT)
		self:SetBanKey()

		self.checkFramer[Side.Left] = 0
		self.checkFramer[Side.Right] = 0

		gMessageManager:SendMessage(gEventConstants.GYM_TASK_TIP_CHANGED, {
			counter = self.ratingCount
		})
		self:ShowRating(Rating.NONE)
		self:RefreshScore()

		self.needAdjustSportDifficulty = true

		gSoundMgr:PlaySoundByExternalSource(DUAL_NAME.BenchPress_Great, ExternalSourceType.Motion_2D)
	end
end

function M:JudeBadBenchPress()
	if self.curSportStage == self.SPORT_STAGE.BENCH_PRESS_START and (self.gridCount[Side.Left] == 0 or self.gridCount[Side.Right] == 0) then
		gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.GymBadBenchPress)

		self.curSportStage = self.SPORT_STAGE.BENCH_PRESS_BAD

		if self.gridCount[Side.Left] > 0 or self.gridCount[Side.Right] > 0 then
			self.waitDecay = true
		end

		self.isSportBlock = true
		self.sendStartSport = false

		self:IncreaseRating(Rating.BAD)
		self:SetBanKey()

		self.checkFramer[Side.Left] = 0
		self.checkFramer[Side.Right] = 0

		gMessageManager:SendMessage(gEventConstants.GYM_TASK_TIP_CHANGED, {
			counter = self.ratingCount
		})
		self:ShowRating(Rating.BAD)
		self:RefreshScore()

		local minTime = self.decayInterval * self.maxGrid + self.decayStartTime + 5

		self:SetBlockFramer(minTime, function ()
			self:RemoveBanKey()
			self:AdjustDifficulty_BenchPress()
		end)
	end
end

function M:StateTreeEnterBenchPressWaitLoop()
	self.curSportStage = self.SPORT_STAGE.BENCH_PRESS_WAIT

	if not self.waitDecay then
		self.isSportBlock = false
	end

	if self.needAdjustSportDifficulty then
		self:RemoveBanKey()
		self:AdjustDifficulty_BenchPress()

		self.needAdjustSportDifficulty = nil
	end
end

function M:AdjustDifficulty_BenchPress()
	local greatCount = self.ratingCount[Rating.GREAT]
	local adjustList = GymConfig.BenchPress_CountIncrease
	self.maxGrid = self.maxGrid + adjustList[Mathf.Clamp(greatCount, 1, #adjustList)]
	self.decayStartTime = self.decayStartTime * GymConfig.BenchPress_DecayTimeReduction
	self.decayInterval = self.decayInterval * GymConfig.BenchPress_DecayRateIncrease

	self:RefreshDivideGrid()
end

function M:RefreshProgressBar()
	self.bindData.progressBenchPressLeft.value = self.gridCount[Side.Left]
	self.bindData.progressBenchPressRight.value = self.gridCount[Side.Right]
end

function M:RefreshDivideGrid()
	self.bindData.progressBenchPressLeft.maxValue = self.maxGrid
	self.bindData.progressBenchPressRight.maxValue = self.maxGrid
	local templateList = {}

	for i = 1, self.maxGrid - 1 do
		table.insert(templateList, {
			tIndex = 0
		})
	end

	self.bindData.listBenchPressLeft:SetSimpleList(#templateList)
	self.bindData.listBenchPressRight:SetSimpleList(#templateList)
end

function M:StartDecay(curSide)
	self.isDecay[curSide] = true
	self.decayFramer[curSide] = self.decayInterval
end

function M:DecayFrame(curSide)
	if not self.isDecay[curSide] then
		return
	end

	if self.gridCount[curSide] == 0 then
		self:StopDecay(curSide)
	else
		self.decayFramer[curSide] = self.decayFramer[curSide] - 1

		if self.decayFramer[curSide] <= 0 then
			self.gridCount[curSide] = self.gridCount[curSide] - 1
			self.decayFramer[curSide] = self.decayInterval
		end
	end
end

function M:StopDecay(curSide)
	self.isDecay[curSide] = false

	if self.isMobile then
		local anim = nil

		if self.curExerciseType == ExerciseType.BENCH_PRESS then
			anim = curSide == Side.Left and self.bindData.btnBenchPressLeftAnim or self.bindData.btnBenchPressRightAnim
		elseif self.curExerciseType == ExerciseType.SQUAT then
			anim = self.bindData.btnSquatAnim
		end

		if anim then
			anim:Play(SQUAT_CLIPNAME.Idle)
		end
	end

	if self.curExerciseType == ExerciseType.BENCH_PRESS then
		self:JudeBadBenchPress()

		if self.gridCount[Side.Left] == 0 and self.gridCount[Side.Right] == 0 then
			self.waitDecay = false

			if self.curSportStage == self.SPORT_STAGE.BENCH_PRESS_WAIT then
				self.isSportBlock = false
			end
		end
	elseif self.curExerciseType == ExerciseType.SQUAT and self.gridCount[Side.Left] == 0 then
		self.waitDecay = false

		if self.curSportStage == self.SPORT_STAGE.SQUAT_WAIT then
			self.isSportBlock = false

			self:RefreshShowGamepadControllerKey()
		elseif self.curSportStage == self.SPORT_STAGE.SQUAT_START then
			self:FailedSquatOnce()
		end

		self:HideSquatQTE(false)
	end
end

function M:InitSquatGame()
	local attr = gSpiritManager:GetUrbanAttr(gBattleSpiritMgr.currentSpiritTemplateId)
	self.maxGrid = Formula_cs:CalSquat_InitialCount(attr, GymConfig.NewSquat_InitialCount)
	self.decayStartTime = GymConfig.NewSquat_InitialDecayStartTime * self.fixedFrameCount
	self.decayInterval = GymConfig.NewSquat_InitialDecayRate * self.fixedFrameCount
	self.qteDistance = GymConfig.NewSquat_QTEDistance

	self:RefreshSquatDivideGrid()

	self.sendStartSport = false
	self.curSportStage = self.SPORT_STAGE.SQUAT_ENTER
	self.isSportBlock = true
	self.needAdjustSportDifficulty = nil
	self.squatPCQTEKeys = {}
	self.squatGamepadQTEKeys = {}
	self.squatQTEStartTime = nil
	self.qteEnable = false
	self.squatMinQTETime = self.isMobile and GymConfig.NewSquat_MinQTEtimeMobile or GymConfig.NewSquat_MinQTEtime
	self.randomSquatQTEIndex = 0

	if not self.isMobile then
		local pcQTEKeys = GymConfig.NewSquat_QTEPcKeys or {
			11,
			12,
			13,
			14
		}

		for i = 1, #pcQTEKeys do
			local cfg = LTConfig.InputSGUIPCKeyConfig.GetConfig(pcQTEKeys[i])

			if cfg then
				table.insert(self.squatPCQTEKeys, {
					id = cfg.Id,
					name = cfg.Name
				})
			end
		end

		local gamepadQTEKeys = GymConfig.NewSquat_QTEGamePadKeys or {
			1,
			2,
			3,
			4
		}

		for i = 1, #gamepadQTEKeys do
			local cfg = LTConfig.InputSGUIGamepadConfig.GetConfig(gamepadQTEKeys[i])

			if cfg then
				table.insert(self.squatGamepadQTEKeys, {
					id = cfg.Id,
					name = cfg.Name
				})
			end
		end
	end

	self:HideSquatQTE(true)
	self:RefreshShowGamepadControllerKey()
end

function M:ConfirmSquat()
	if self.isBlock or self.isSportBlock then
		return
	end

	local side = Side.Left
	local curTime = os.clock()

	if self.confirmDelayTime and curTime - self.confirmTime[side] <= self.confirmDelayTime then
		return
	end

	self.confirmTime[side] = curTime

	gSoundMgr:PlaySoundByExternalSource(DUAL_NAME.Squat, ExternalSourceType.Motion_2D)

	if self.isMobile then
		local anim = self.bindData.btnSquatAnim

		anim:Stop()
		anim:Play(SQUAT_CLIPNAME.Press)
	elseif SGUI.GameDevice.KeyboardMouse < self.scheme then
		-- Nothing
	end

	self.isDecay[side] = false
	self.checkFramer[side] = 0

	if self.gridCount[side] < self.maxGrid then
		self.gridCount[side] = self.gridCount[side] + 1
	end

	if self.gridCount[side] > 0 and not self.sendStartSport then
		gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.GymStartSquat)

		self.curSportStage = self.SPORT_STAGE.SQUAT_START
		self.sendStartSport = true

		self:SetSquatQTEData()
	elseif self.gridCount[side] == self.maxGrid then
		self:ShowSquatQTE()
	end
end

function M:AdjustDifficulty_Squat()
	local greatCount = self.ratingCount[Rating.GREAT]
	local adjustList = GymConfig.NewSquat_CountIncrease
	self.maxGrid = self.maxGrid + adjustList[Mathf.Clamp(greatCount, 1, #adjustList)]
	self.decayStartTime = self.decayStartTime * GymConfig.NewSquat_DecayTimeReduction
	self.decayInterval = self.decayInterval * GymConfig.NewSquat_DecayRateIncrease

	self:RefreshSquatDivideGrid()
end

function M:SuccessSquatOnce()
	self.qteEnable = false

	gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.GymGoodSquat)

	self.curSportStage = self.SPORT_STAGE.SQUAT_GOOD

	if self.gridCount[Side.Left] > 0 then
		self.waitDecay = true
	end

	self.isSportBlock = true
	self.sendStartSport = false

	self:IncreaseRating(Rating.GREAT)
	self:SetBanKey()

	self.checkFramer[Side.Left] = 0

	gMessageManager:SendMessage(gEventConstants.GYM_TASK_TIP_CHANGED, {
		counter = self.ratingCount
	})
	self:ShowRating(Rating.NONE)
	self:RefreshScore()

	self.needAdjustSportDifficulty = true

	self:StartDecay(Side.Left)
	self:RefreshShowGamepadControllerKey()
	gSoundMgr:PlaySoundByExternalSource(DUAL_NAME.Squat_Great, ExternalSourceType.Motion_2D)
end

function M:RefreshShowGamepadControllerKey()
	if not self.isMobile and self.curExerciseType == ExerciseType.SQUAT then
		if not self.qteEnable and not self.isSportBlock and not self.isBlock then
			self.bindData.squatCtrlR.activation = self.gamepadMode
		else
			self.bindData.squatCtrlR.activation = false
		end
	end
end

function M:FailedSquatOnce()
	self.qteEnable = false

	gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.GymBadSquat)

	self.curSportStage = self.SPORT_STAGE.SQUAT_BAD

	if self.gridCount[Side.Left] > 0 then
		self.waitDecay = true
	end

	self.isSportBlock = true
	self.sendStartSport = false

	self:IncreaseRating(Rating.BAD)
	self:SetBanKey()

	self.checkFramer[Side.Left] = 0

	gMessageManager:SendMessage(gEventConstants.GYM_TASK_TIP_CHANGED, {
		counter = self.ratingCount
	})
	self:ShowRating(Rating.BAD)
	self:RefreshScore()

	local minTime = self.decayInterval * self.maxGrid + self.decayStartTime + 5

	self:SetBlockFramer(minTime, function ()
		self:RemoveBanKey()
	end)
	self:StartDecay(Side.Left)
	self:RefreshShowGamepadControllerKey()
end

function M:HideSquatQTE(instant)
	if instant then
		self.bindData.squatQTERoot:SetActive(false)
		self.bindData.squatQTERootMobile:SetActive(false)

		if self.bindData.squatQTECtrlRoot then
			self.bindData.squatQTECtrlRoot:SetActive(false)
		end
	else
		self.bindData.squatQTERoot:InvokeCallback(SGUI.EInvokeTime.User4)
		self.bindData.squatQTERootMobile:InvokeCallback(SGUI.EInvokeTime.User4)

		if self.bindData.squatQTECtrlRoot then
			self.bindData.squatQTECtrlRoot:SetActive(false)
		end
	end

	self.qteEnable = false

	self:RefreshShowGamepadControllerKey()
end

function M:SetSquatQTEData()
	self.randomSquatQTEIndex = math.random(4)

	if self.isMobile then
		self.bindData.squatQTEMobile = self.randomSquatQTEIndex - 1
	elseif #self.squatPCQTEKeys == 4 and #self.squatGamepadQTEKeys == 4 then
		local currentFailedBtnSuffix = 1

		for i = 1, 4 do
			local pcKey = self.squatPCQTEKeys[i]
			local gamepadKey = self.squatGamepadQTEKeys[i]

			if i ~= self.randomSquatQTEIndex then
				local btn = self.bindData["squatFailedQTEBtn" .. tostring(currentFailedBtnSuffix)]

				btn:SetPCKeyInfoWithOutTip(pcKey.id)
				self.bindData.navigationArea:ChangeActionIdByResponse(btn, gamepadKey.id)

				currentFailedBtnSuffix = currentFailedBtnSuffix + 1
			else
				self.bindData.squatQTEBtn:SetPCKeyInfoWithOutTip(pcKey.id)

				self.bindData.squatQTEKeyText = self.gamepadMode and gamepadKey.name or pcKey.name

				self.bindData.squatCtrlImg:ChangeImageAction(gamepadKey.id, 0, nil, 0, 2)
			end
		end

		self.bindData.consoleCtrl = self.randomSquatQTEIndex - 1
	else
		print_error("Squat QTE keys is not equal 4 on pc platform! pc key num " .. tostring(#self.squatPCQTEKeys) .. "gamepad key num " .. tostring(#self.squatGamepadQTEKeys))
	end
end

function M:ShowSquatQTE()
	self.qteEnable = true
	self.squatQTEStartTime = os.clock()

	if self.isMobile then
		self.bindData.squatQTERootMobile:SetActive(true)
		self.bindData.squatQTERootMobile:InvokeCallback(SGUI.EInvokeTime.User3)
	else
		self.bindData.squatQTECtrlRoot:SetActive(true)
		self.bindData.squatQTERoot:SetActive(true)

		if self.gamepadMode then
			self.bindData.squatQTECtrlRoot:InvokeCallback(SGUI.EInvokeTime.User3)
		else
			self.bindData.squatQTERoot:InvokeCallback(SGUI.EInvokeTime.User3)
		end
	end

	self:RefreshShowGamepadControllerKey()
end

function M:SquatQTEActionSuccess()
	if self.isMobile then
		self.bindData.squatQTERootMobile:InvokeCallback(SGUI.EInvokeTime.User1)
	elseif self.gamepadMode then
		self.bindData.squatQTECtrlRoot:InvokeCallback(SGUI.EInvokeTime.User1)
	else
		self.bindData.squatQTERoot:InvokeCallback(SGUI.EInvokeTime.User1)
	end

	self:SuccessSquatOnce()
end

function M:SquatQTEActionFailed(playMiss)
	if self.isMobile then
		self.bindData.squatQTERootMobile:InvokeCallback(SGUI.EInvokeTime.User2)
	elseif self.gamepadMode then
		self.bindData.squatQTECtrlRoot:InvokeCallback(SGUI.EInvokeTime.User2)
	else
		self.bindData.squatQTERoot:InvokeCallback(SGUI.EInvokeTime.User2)
	end

	self:FailedSquatOnce()
end

function M:RefreshSquatProgressBar()
	self.bindData.progressSquat.value = self.gridCount[Side.Left]
end

function M:RefreshSquatDivideGrid()
	self.bindData.progressSquat.maxValue = self.maxGrid
	local templateList = {}

	for i = 1, self.maxGrid - 1 do
		table.insert(templateList, {
			tIndex = 0
		})
	end

	self.bindData.listSquat:SetSimpleList(#templateList)
end

function M:StateTreeEnterSquatWaitLoop()
	self.curSportStage = self.SPORT_STAGE.SQUAT_WAIT

	if not self.waitDecay then
		self.isSportBlock = false
	end

	if self.needAdjustSportDifficulty then
		self:RemoveBanKey()
		self:AdjustDifficulty_Squat()

		self.needAdjustSportDifficulty = nil
	end

	self:RefreshShowGamepadControllerKey()
end

function M:InitRunGame()
	self.runBoxPos = 0
	self.runBoxLen = GymConfig.Treadmill_BoxLength
	self.runBoxMinPos = GymConfig.Treadmill_SwitchSpeedMinPosition
	self.runBoxMaxPos = GymConfig.Treadmill_SwitchSpeedMaxPosition - self.runBoxLen
	self.runGreatTime = GymConfig.Treadmill_GreatTime
	self.runFailureTime = GymConfig.Treadmill_FailureTime
	self.runMaxShowSpeed = GymConfig.Treadmill_MaxSpeed
	self.runBarIncreaseLen = GymConfig.Treadmill_BarIncreaseLength
	self.runBarDecreaseSpeed = GymConfig.Treadmill_BarDecreaseSpeed
	self.runBoxMoveTime = GymConfig.Treadmill_BoxMoveTime
	self.runBoxMovePosition = GymConfig.Treadmill_BoxMovePosition
	self.runClickChangeInterval = GymConfig.Treadmill_ClickChangeInterval or 0.05
	self.runMouseWheelChangeMultiplier = GymConfig.Treadmill_MouseWheelChangeMultiplier or 0.001
	self.runStickChangeMultiplier = GymConfig.Treadmill_StickChangeMultiplier or 0.1
	self.runAnimSpeedsArea = GymConfig.Treadmill_AnimSpeedsArea
	self.runSpeedDecreaseFactors = GymConfig.Treadmill_BarDecreaseSpeedCoefficient
	self.runSpeedGreatScoreFactors = GymConfig.Treadmill_PointCoefficient
	self.runWrestlingSpeedTopRange = GymConfig.Treadmill_WrestlingSpeedTopRange
	self.runWrestlingTime = GymConfig.Treadmill_WrestlingTime
	self.runSendEventDeltaTime = GymConfig.Treadmill_SendEventDeltaTime
	self.runBoxMoveSpeed = self.runBoxMovePosition / self.runBoxMoveTime
	self.curRunSpeed = 0
	self.runAnimSpeed = 0
	self.runBoxMoveDone = false
	self.canRunBoxMove = false
	self.sendStartSport = false
	self.curSportStage = self.SPORT_STAGE.RUN_PREPARE_LOOP
	self.isSportBlock = false
	self.isInRunLoop = false
	self.sideCheck = false
	self.confirmDelayTime = GymConfig.Treadmill_MinInterval
	self.runTargetBoxPos = self.runBoxMovePosition

	self:RefreshRunJudgeArea()

	self.lastSendRunAnimSpeed = nil
	self.lastSendRunAnimTime = nil

	self:RefreshSpeedBar()

	self.curEnableSide = Side.Left
	self.runCurve = DiversityConfigUtils.ImportAnimationCurve(GymConfig.Treadmill_BarDecreaseSpeedCurve)
	self.runBarDecreaseInterval = GymConfig.Treadmill_BarDecreaseInterval
	self.runFailureBarSpeed = GymConfig.Treadmill_FailureBarSpeed
	self.startRunTime = nil
	self.bindData.runSpeedCtrl = 0
	self.sendStartRunSpeedEffect = false

	if self.bindData.runBar then
		self.bindData.runBar:InvokeCallback(SGUI.EInvokeTime.User2)
	end
end

function M:ChangeRunSpeed(deltaSpeed)
	if self.isSportBlock or self.isBlock then
		return
	end

	if self.curSportStage == self.SPORT_STAGE.RUN_START and self.runBoxMoveDone then
		self.runBoxPos = math.max(self.runBoxMinPos, math.min(self.runBoxMaxPos, self.runBoxPos + deltaSpeed))
		self.runTargetBoxPos = self.runBoxPos

		self:RefreshRunJudgeArea()
	end
end

function M:ConfirmRun(curSide)
	if self.isSportBlock or self.isBlock or curSide ~= self.curEnableSide and self.sideCheck then
		return
	end

	self.sendStartRunSpeedEffect = true
	local curTime = os.clock()

	if self.confirmDelayTime and curTime - self.confirmTime[Side.Left] <= self.confirmDelayTime then
		return
	end

	self.sideCheck = true
	self.curRunSpeed = math.min(1, self.curRunSpeed + self.runBarIncreaseLen)

	if not self.sendStartSport then
		gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.GymStartRun)

		self.curSportStage = self.SPORT_STAGE.RUN_START
		self.canRunBoxMove = true
		self.sendStartSport = true
		self.startRunTime = os.clock()
	end

	if curSide == Side.Left then
		self:ShowRunBtn(Side.Right, true)
	else
		self:ShowRunBtn(Side.Left, true)
	end

	self:RefreshSpeedBar()
end

function M:UpdateRun()
	if self.curSportStage == self.SPORT_STAGE.RUN_BAD then
		self.curRunSpeed = math.max(0, self.curRunSpeed - Time.fixedDeltaTime * self.runFailureBarSpeed)
		self.runBoxPos = math.max(0, self.runBoxPos - Time.fixedDeltaTime * self.runFailureBarSpeed)

		self:RefreshSpeedBar()
		self:RefreshRunJudgeArea()

		if self.curRunSpeed <= 0.01 then
			self:StartBtnEffect()
		end
	elseif self.curSportStage == self.SPORT_STAGE.RUN_START then
		local speed = 0.2

		if self.runCurve and self.startRunTime and self.runBarDecreaseInterval and self.runBarDecreaseInterval > 0 then
			local time = (os.clock() - self.startRunTime) / self.runBarDecreaseInterval
			time = math.min(1, math.max(0, time))
			speed = self.runCurve:Evaluate(time)
		end

		self.curRunSpeed = math.max(0, self.curRunSpeed - Time.fixedDeltaTime * speed * self.runSpeedDecreaseFactor)

		self:RefreshSpeedBar()

		if self.canRunBoxMove and not self.runBoxMoveDone then
			self.runBoxPos = math.min(self.runTargetBoxPos, self.runBoxPos + Time.fixedDeltaTime * self.runBoxMoveSpeed)

			if self.runTargetBoxPos <= self.runBoxPos then
				self.runBoxPos = self.runTargetBoxPos
				self.runBoxMoveDone = true
			end

			self:RefreshRunJudgeArea()
		end

		if self.curSportStage == self.SPORT_STAGE.RUN_START then
			if self.curRunSpeed > 1 - self.runWrestlingSpeedTopRange then
				if self.runTriggerWrestlingSpeedTime then
					if self.runWrestlingTime <= os.clock() - self.runTriggerWrestlingSpeedTime then
						self.runTriggerWrestlingSpeedTime = os.clock()

						self:RunWrestling()
					end
				else
					self.runTriggerWrestlingSpeedTime = os.clock()

					if self.bindData.runBar then
						self.bindData.runBar:InvokeCallback(SGUI.EInvokeTime.User1)
					end
				end
			else
				self.runTriggerWrestlingSpeedTime = nil

				if self.bindData.runBar then
					self.bindData.runBar:InvokeCallback(SGUI.EInvokeTime.User2)
				end
			end

			if self.curRunSpeed > self.runBoxPos + self.runBoxLen then
				self.runTriggerFailedLowerTime = nil
				self.runTriggerGreatTime = nil

				if self.runTriggerFailedUpperTime then
					if self.runFailureTime <= os.clock() - self.runTriggerFailedUpperTime then
						self.runTriggerFailedUpperTime = os.clock()

						self:RunBad(true)

						self.runTriggerWrestlingSpeedTime = nil

						if self.bindData.runBar then
							self.bindData.runBar:InvokeCallback(SGUI.EInvokeTime.User2)
						end
					end
				else
					self.runTriggerFailedUpperTime = os.clock()
					self.bindData.runSpeedCtrl = 1
				end
			elseif self.curRunSpeed < self.runBoxPos then
				self.runTriggerFailedUpperTime = nil
				self.runTriggerGreatTime = nil

				if self.runTriggerFailedLowerTime then
					if self.runFailureTime <= os.clock() - self.runTriggerFailedLowerTime then
						self.runTriggerFailedLowerTime = os.clock()

						self:RunBad(false)
					end
				else
					self.runTriggerFailedLowerTime = os.clock()
					self.bindData.runSpeedCtrl = 1
				end
			else
				self.runTriggerFailedUpperTime = nil
				self.runTriggerFailedLowerTime = nil

				if self.runTriggerGreatTime then
					if self.runGreatTime <= os.clock() - self.runTriggerGreatTime then
						self.runTriggerGreatTime = os.clock()

						self:RunGreat()
					end
				else
					self.runTriggerGreatTime = os.clock()
					self.bindData.runSpeedCtrl = 0
				end

				if self.sendStartRunSpeedEffect then
					self.sendStartRunSpeedEffect = false

					if self.bindData.runBar then
						self.bindData.runBar:InvokeCallback(SGUI.EInvokeTime.User3)
					end
				end
			end
		end
	end

	self.sendStartRunSpeedEffect = false
end

function M:RunBad(upper)
	gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, upper and GameplayEvent.GymRunBad2 or GameplayEvent.GymRunBad1)

	self.curSportStage = self.SPORT_STAGE.RUN_BAD
	self.isSportBlock = true
	self.sendStartSport = false
	self.sideCheck = false

	self:IncreaseRating(Rating.BAD)
	self:SetBanKey()
	gMessageManager:SendMessage(gEventConstants.GYM_TASK_TIP_CHANGED, {
		counter = self.ratingCount
	})
	self:ShowRating(Rating.BAD)
	self:RefreshScore()
	self:StopBtnEffect()
end

function M:RunGreat()
	self:IncreaseRating(Rating.GREAT, self.runSpeedGreatScoreFactor)
	self:SetBanKey()
	gMessageManager:SendMessage(gEventConstants.GYM_TASK_TIP_CHANGED, {
		counter = self.ratingCount
	})
	self:ShowRating(Rating.NONE)
	self:RefreshScore()
	gSoundMgr:PlaySoundByExternalSource(DUAL_NAME.Run_Great, ExternalSourceType.Motion_2D)
end

function M:RunWrestling()
	self:StopBtnEffect()
	gGymManager:SettleExercise({
		result = self.ratingFactorCount,
		exitGameplayEvent = GameplayEvent.GymWrestlingExitRun
	}, 0.1 + self.blockFramer / self.fixedFrameCount)
end

function M:StateTreeEnterRunPrepareLoop()
	self.curSportStage = self.SPORT_STAGE.RUN_PREPARE_LOOP
	self.isSportBlock = false
	self.sendStartSport = false
	self.runBoxMoveDone = false
	self.runTriggerFailedUpperTime = nil
	self.runTriggerFailedLowerTime = nil
	self.runTriggerGreatTime = nil
	self.runBoxPos = 0
	self.curRunSpeed = 0

	self:RefreshSpeedBar()
	self:RefreshRunJudgeArea()

	self.bindData.runSpeedCtrl = 0
end

function M:RefreshSpeedBar()
	self.bindData.runBar.value = self.curRunSpeed
	self.runAnimSpeed = 0
	self.runSpeedDecreaseFactor = 1
	self.runSpeedGreatScoreFactor = 1

	if self.runAnimSpeedsArea and self.runSpeedDecreaseFactors and self.runSpeedGreatScoreFactors then
		for i = 1, #self.runAnimSpeedsArea do
			if self.curRunSpeed <= self.runAnimSpeedsArea[i] then
				self.runAnimSpeed = i - 1
				local decreaseFactor = self.runSpeedDecreaseFactors[i]

				if decreaseFactor then
					self.runSpeedDecreaseFactor = decreaseFactor
				end

				local greatScoreFactors = self.runSpeedGreatScoreFactors[i]

				if greatScoreFactors then
					self.runSpeedGreatScoreFactor = greatScoreFactors
				end

				break
			end
		end
	end

	if not self.lastSendRunAnimSpeed or not self.lastSendRunAnimTime or self.runAnimSpeed ~= self.lastSendRunAnimSpeed and self.runSendEventDeltaTime < os.clock() - self.lastSendRunAnimTime then
		self.lastSendRunAnimSpeed = self.runAnimSpeed
		self.lastSendRunAnimTime = os.clock()

		gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, GameplayEvent.GymJudgeRunSpeed)
	end
end

function M:ShowRunBtn(side, playOtherClick)
	if self.gamepadMode or self.isMobile then
		local curBtn, anotherBtn = nil

		if side == Side.Left then
			curBtn = self.bindData.runBtnLeft
			anotherBtn = self.bindData.runBtnRight
		else
			curBtn = self.bindData.runBtnRight
			anotherBtn = self.bindData.runBtnLeft
		end

		curBtn:InvokeCallback(SGUI.EInvokeTime.User2)

		if playOtherClick then
			anotherBtn:InvokeCallback(SGUI.EInvokeTime.User1)
		end
	end

	self.curEnableSide = side
end

function M:StartBtnEffect()
	if self.gamepadMode or self.isMobile then
		self.bindData.runBtnLeft:InvokeCallback(SGUI.EInvokeTime.User2)
		self.bindData.runBtnRight:InvokeCallback(SGUI.EInvokeTime.User2)
	end
end

function M:StopBtnEffect()
	if self.gamepadMode or self.isMobile then
		self.bindData.runBtnLeft:InvokeCallback(SGUI.EInvokeTime.User3)
		self.bindData.runBtnRight:InvokeCallback(SGUI.EInvokeTime.User3)
	end
end

function M:RefreshRunJudgeArea()
	local anchorMin = Vector2.New(0, self.runBoxPos)
	local anchorMax = Vector2.New(1, self.runBoxPos + self.runBoxLen)
	self.bindData.runPerfectZone.rectTransform.anchorMin = anchorMin
	self.bindData.runPerfectZone.rectTransform.anchorMax = anchorMax
	self.bindData.runPerfectZone.rectTransform.anchoredPosition = Vector2.zero
	self.bindData.runPerfectZone.rectTransform.sizeDelta = Vector2.zero
	local showSpeed = self.runMaxShowSpeed * self.runBoxPos / self.runBoxMaxPos
	self.bindData.runSpeed = string.format("%0.1f", showSpeed)
end

function M:GetCurveConfigBySpiritId(spiritId)
	for i = 0, GymSitupCurveConfig.count - 1 do
		local cfg = GymSitupCurveConfig.LoadAt(i)

		if cfg.Characterid == spiritId then
			return cfg
		end
	end

	return GymSitupCurveConfig.GetConfig(1)
end

function M:ShowRating(rating)
	if self.ratingTimer then
		self.ratingTimer:Stop()

		self.ratingTimer = nil
	end

	local bubbleIndex = Rating2BubbleCtrl[rating]
	self.bindData.bubbleCtrl = bubbleIndex

	gCS.LuaUtils.PlayAnimation(self.bindData.pointerAnim)
	self.bubbleAnims[bubbleIndex]:Stop()
	self.bubbleAnims[bubbleIndex]:Play()

	local clip = self.bubbleAnims[bubbleIndex]:GetClip(BUBBLE_CLIPNAME[bubbleIndex])
	self.ratingTimer = Timer.New(function ()
		self.bindData.bubbleCtrl = 0
	end, clip.length, nil, true):Start()
end

function M:ShowDialog(rating)
	local dialogList = {}

	if rating == Rating.NONE then
		dialogList = self.curExerciseCfg.BadDialog
	elseif rating == Rating.GOOD then
		dialogList = self.curExerciseCfg.GoodDialog
	elseif rating == Rating.GREAT then
		dialogList = self.curExerciseCfg.GreatDialog
	end

	if not dialogList or #dialogList < 2 then
		print_error("健身房弹出对话配表少于两句或者拿到了错误的评级")

		return
	end

	local validList = {}

	for i = 1, #dialogList do
		if dialogList[i] ~= self.curDialogId then
			table.insert(validList, dialogList[i])
		end
	end

	math.randomseed(os.time())

	local index = math.random(#validList)

	gDialogManager:ShowGeneralDialog(validList[index], gDialogSource.Fitness)

	self.curDialogId = validList[index]
end

function M:SetBlockFramer(frame, finishAction)
	self.isBlock = true
	self.blockAllFrame = frame
	self.blockFramer = frame
	self.blockFinishAction = finishAction

	self:RefreshShowGamepadControllerKey()
end

function M:SetBanKey()
	return
end

function M:RemoveBanKey()
	return
end

function M:SwitchCamera()
	self.curCameraIndex = self.curCameraIndex + 1

	if self.maxCameraIndex < self.curCameraIndex then
		self.bindData.VCam.gameObject:SetActive(false)

		self.curCameraIndex = 0
	else
		if self.curCameraIndex == 1 then
			self.bindData.VCam.gameObject:SetActive(true)
		end

		gUtils:SetCameraView(MyPlayerManager.PlayerUnit, self.cameraList[self.curCameraIndex], self.bindData.VCam.gameObject)
	end
end

function M:RefreshScore()
	local score = gGymManager:CalcTotalScore(self.ratingFactorCount, self.curExerciseCfg)
	self.bindData.scoreText = score
	self.bindData.scoreCtrl = self:CalcLevelCtrl(score, self.curExerciseCfg)
end

function M:CalcLevelCtrl(score, exerciseCfg)
	if exerciseCfg.SlevelPoint <= score then
		return 0
	elseif exerciseCfg.AlevelPoint <= score then
		return 1
	else
		return 2
	end
end

function M:OnClickBtnSwitchCam()
	self:SwitchCamera()
end

function M:OnBeginLongPressSitup()
	self.isLongPressBtnSitup = true

	if self.isMobile and self.effectShow then
		self.effectShow = false

		self.bindData.situpEffectR.gameObject:SetActive(false)
	end
end

function M:OnEndLongPressSitup()
	self.isLongPressBtnSitup = false
end

function M:OnClickBtnBenchPressLeft()
	self:ConfirmBenchPress(Side.Left)
end

function M:OnClickBtnBenchPressRight()
	self:ConfirmBenchPress(Side.Right)
end

function M:OnRotateCameraInput(context)
	if context.started then
		self.isRotatingCamera = true
		self.rotateParam = context:ReadValueVector2() * 20
	end

	if context.performed then
		self.rotateParam = context:ReadValueVector2() * 20
	end

	if context.canceled then
		self.isRotatingCamera = false
		self.rotateParam = nil
	end
end

function M:OnRotateCameraUpdate()
	if self.isRotatingCamera then
		gMessageManager:SendMessage(gEventConstants.GAMEPAD_CAMERA_ROTATE, self.rotateParam)
	end
end

function M:OnClickBtnSquat()
	if not self.qteEnable then
		self:ConfirmSquat(Side.Left)
	end
end

function M:OnPressBtnSquat()
	if self.isMobile and self.effectShow then
		self.effectShow = false

		self.bindData.squatEffect.gameObject:SetActive(false)
	end
end

function M:OnSquatQTEBtnPress()
	if self.qteEnable then
		self:SquatQTEActionSuccess()
	end
end

function M:OnSquatQTEBtnBeginDrag(eventData)
	self.startPosition = eventData.position
	self.dragging = true
end

function M:OnSquatQTEBtnDragging(eventData)
	if not self.dragging or not self.qteEnable then
		return
	end

	local current = eventData.position
	local passValue = self.qteDistance

	if current.y > self.startPosition.y + passValue then
		self:SquatQTEActionSuccess()

		self.dragging = false
	end
end

function M:OnSquatQTEBtnEndDrag(eventData)
	self.dragging = false
end

function M:OnSquatQTEFailedBtnPress()
	if self.qteEnable then
		self:SquatQTEActionFailed(true)
	end
end

function M:OnRunBtnLeftClick()
	self:ConfirmRun(Side.Left)
end

function M:OnRunBtnRightClick()
	self:ConfirmRun(Side.Right)
end

function M:OnRunSpeedUpClick()
	self:ChangeRunSpeed(self.runClickChangeInterval)
end

function M:OnRunSpeedDownClick()
	self:ChangeRunSpeed(-self.runClickChangeInterval)
end

function M:OnRunSpeedAxis(context)
	if context.performed then
		local param = context:ReadValueVector2().y

		self:ChangeRunSpeed(param * self.runStickChangeMultiplier)
	end
end

function M:OnRunSpeedBtnBeginDrag(eventData)
	self.runSpeedDragging = true
	self.dragStartRunBoxPos = self.runBoxPos
	local rect = self.bindData.runBar.rectTransform
	local cam = eventData.pressEventCamera and eventData.pressEventCamera or SGUI.UWidget.uiCamera

	if rect and cam then
		self.startDragRunLocalPos = SGUI.Utils.ScreenPointToLocalPoint(cam, rect, eventData.position)
	end
end

function M:OnRunSpeedBtnDragging(eventData)
	if not self.runSpeedDragging or not self.startDragRunLocalPos then
		return
	end

	local rect = self.bindData.runBar.rectTransform
	local cam = eventData.pressEventCamera and eventData.pressEventCamera or SGUI.UWidget.uiCamera

	if rect and cam then
		local newPosition = SGUI.Utils.ScreenPointToLocalPoint(cam, rect, eventData.position)
		local delta = newPosition.y - self.startDragRunLocalPos.y
		local sizeY = self.bindData.runBar.rectTransform.sizeDelta.y

		if sizeY ~= 0 then
			local deltaBoxPos = self.dragStartRunBoxPos + delta / sizeY - self.runBoxPos

			if deltaBoxPos ~= 0 then
				self:ChangeRunSpeed(deltaBoxPos)
			end
		end
	end
end

function M:OnRunSpeedBtnEndDrag(eventData)
	self.runSpeedDragging = false
	self.startDragRunLocalPos = nil
	self.dragStartRunBoxPos = nil
end

function M:OnRunSpeedChangeInput(context)
	if context.performed then
		local param = context:ReadValueVector2()

		self:ChangeRunSpeed(param.y * self.runMouseWheelChangeMultiplier)
	end
end
