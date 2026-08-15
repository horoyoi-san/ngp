local PhotographTemplateConfig = LTConfig.PhotoPhotographTemplateConfig
local PhotoTemplate = gTakePhotoUtils.PhotoTemplate
local PhotoMode = gTakePhotoUtils.PhotoMode
local GameInputManager = LX6.Manager.GameInputManager
local HUDManager = LX6.GUI.HUDNew.HUDManager
local MainViewUtils = LX6.Gps.MainViewUtils
local DOTween = DOTween
local Ease = DG.Tweening.Ease
local VideoState = gTakePhotoUtils.PhotoTaskTargetState
C_PhotographGamePanelStore = DefClass("C_PhotographGamePanelStore", C_PhotographGamePanelStore, C_StoreGroup)
GroupName2Class.PhotographGamePanelStore = C_PhotographGamePanelStore
local M = C_PhotographGamePanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.photoTemplate = PhotoTemplate.Default
	self.templateConfig = {}
	self.isSwitching = false
	self.updateHudData = nil
	self.videoFocusTime = 0
	self.videoNotFocusTime = 0
	self.beginVideo = false
	self.videoFocusTrans = nil
	self.isAlreadyPlayFocus = false
	self.rightStickValue = {
		x = 0,
		y = 0
	}
	self.isFovBtnPressing = false
	self.FovChangeType = 0
	self.FovChangeTimeSignal = 0
	self.FovTimes = 1
	self.currentFOV = 0
	self.isLEndPress = true
	self.isREndPress = true
	self.inPhotoMode = false
	self.photoFailTime = 0
	self.photoSuccessTimes = 0
	self.photoNowTimes = 0
end

function M:OnAwake()
	self:DefineAllVariables()

	self.photoTemplate = gTakePhotoUtils.GetPhotoTemplate()
	local config = PhotographTemplateConfig.GetConfig(self.photoTemplate)

	if not config then
		print_error("不存在的拍照模板配置:", self.photoTemplate)

		return
	end

	self:CacheConfig(config)
	self:GenMessageEvents()
	self:RegisterWidget()

	self.photoTemplate = gTakePhotoUtils.GetPhotoTemplate()

	gTakePhotoUtils.CallOnPhotoPanelAwake()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	gTakePhotoUtils.CallOnPhotoPanelDisable()
end

function M:OnDestroy()
	gTakePhotoUtils.CallOnPhotoPanelDestroy()

	if gClientUtils.CheckMainPhoneIsShowing() then
		gTakePhotoUtils.PlayTakePhotoAction(gClientConst.TakePhotoAnimationState.LookAtPhone)
	else
		gTakePhotoUtils.PlayTakePhotoAction(gClientConst.TakePhotoAnimationState.Clear)
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		GameInputManager.UnregisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.mouseScrollCallback)
	end
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	if data and data.isBanClose then
		self.bindData.closeBtn:SetActive(false)
	end

	gTakePhotoUtils.PlayTakePhotoAction(gClientConst.TakePhotoAnimationState.NormalTakePhoto)
	gTakePhotoUtils.PlayTakePhotoCamera(PhotoMode.FullView, self.photoTemplate, 1)

	local hideTime = self.templateConfig.enterPhotoModeSec

	self:InitUIElement()
	self:HideWholePanel(hideTime)
	gTakePhotoUtils.CallOnPhotoPanelShow()
	HUDManager.SetForceShow(true)
	HUDManager.ForceSetHUDTargetShow(gHudMgr.HUDTargetType.Npc)
	self:OnDOFSliderValueChanged(50)

	self.isFovBtnPressing = false
end

function M:OnClose()
	gTakePhotoUtils.CallOnPhotoPanelClose()
	gTakePhotoUtils.PlayTakePhotoCamera(PhotoMode.None, self.photoTemplate, 1)

	if gClientUtils.CheckMainPhoneIsShowing() then
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false
	end

	HUDManager.SetForceShow(false)

	if self.photoTimeTween then
		self.photoTimeTween:Kill()
	end
end

function M:OnLateUpdate()
	self:UpdateGamepadCamera()
	self:UpdateFovByJoyStick()
end

function M:OnCameraUpdate()
	self:UpdateHudTargetData()
	self:UpdateVideoTargetOnce()
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.PHOTO_CUSTOM_TARGET] = function (eventId, data)
			self.updateHudData = data
		end,
		[gEventConstants.AFTER_SWITCH_SCENE] = function (eventId, switchType)
			if switchType ~= gSwitchSceneType.Reconnect then
				return
			end

			gTakePhotoUtils.PlayTakePhotoCamera(PhotoMode.FullView, self.photoTemplate, 1)
		end,
		[gEventConstants.VIDEO_CRAZY_PHOTO_MODE_SIGNAL] = function (eventId, params)
			if not gPanelManager:IsPanelShowing(gPanelId.S_PHOTOGRAPH_GAME_PANEL) then
				return
			end

			local isEnter = params.isEnter
			self.photoSuccessTimes = params.successTimes
			self.photoFailTime = isEnter and params.failTime or 0
			self.inPhotoMode = isEnter
			self.bindData.takePhotoCtrl = isEnter and 1 or 0

			if not isEnter then
				return
			end

			self.bindData.warningCtrl = 0
			self.photoNowTimes = 0
			self.bindData.photoNum = self.photoNowTimes .. "/" .. self.photoSuccessTimes
			self.photoTimeTween = DOTween.To(function ()
				return 0
			end, function (value)
				self.bindData.photoProgress = value

				if value > 0.7 then
					self.bindData.warningCtrl = 1
				end
			end, 1, self.photoFailTime):SetEase(Ease.Linear):OnComplete(function ()
				gMessageManager:SendMessage(gEventConstants.VIDEO_CRAZY_PHOTO_FAIL, true)
			end)
		end
	}
end

function M:RegisterWidget()
	self.bindData.closeBtn.luaClick = self:CreateAction("OnClickCloseBtn")
	self.bindData.takePhotoBtn.luaClick = self:CreateAction("OnClickTakePhotoBtn")
	self.bindData.DOFSlider.luaValueChanged = self:CreateAction("OnDOFSliderValueChanged")
	local fov = self.templateConfig.FOV
	self.defaultValue = fov.defaultValue
	self.bindData.DOFSlider.minValue = 0
	self.bindData.DOFSlider.maxValue = 100
	self.bindData.DOFSlider.stepSize = 5
	self.bindData.DOFSlider.value = 50
	self.bindData.sliderStyle = 1

	function self.bindData.DOFSlider.luaPress()
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false
	end

	function self.bindData.DOFSlider.luaRelease()
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	end

	self.mouseScrollCallback = self:CreateAction("OnMouseScroll")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		GameInputManager.RegisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.mouseScrollCallback)
	end

	self.bindData.FOVUpBtn.luaBeginLongPress = self:CreateActionWithArgs("OnFOVPress", {
		isEndPress = false,
		op = 1
	})
	self.bindData.FOVDownBtn.luaBeginLongPress = self:CreateActionWithArgs("OnFOVPress", {
		isEndPress = false,
		op = -1
	})
	self.bindData.FOVUpBtn.luaEndLongPress = self:CreateActionWithArgs("OnFOVPress", {
		isEndPress = true,
		op = 1
	})
	self.bindData.FOVDownBtn.luaEndLongPress = self:CreateActionWithArgs("OnFOVPress", {
		isEndPress = true,
		op = -1
	})
	self.bindData.rightJoyStick.luaGamePadInputChanged = self:CreateAction("OnRightJoyStickInputChanged")
end

function M:OnClickCloseBtn()
	gPanelManager:Close(self.m_Id)
end

function M:OnClickTakePhotoBtn()
	if not self.inPhotoMode then
		return
	end

	self.bindData.takePhotoBtn.interactable = false

	self:PlayAniChain(self.bindData.photoAni, "S_Vx_PhotoPanel_Light"):OnComplete(function ()
		self.bindData.takePhotoBtn.interactable = true
	end)

	if self.bindData.videoFocusCtrls ~= 0 then
		return
	end

	self.photoNowTimes = self.photoNowTimes + 1
	self.bindData.photoNum = self.photoNowTimes .. "/" .. self.photoSuccessTimes

	if self.photoNowTimes == self.photoSuccessTimes then
		if self.photoTimeTween then
			self.photoTimeTween:Kill()
		end

		self.bindData.photoSuccessCtrl = 1

		self:PlayAniChain(self.bindData.photoSuccessAni, "S_Vx_PhotographGamePanel_Succeed"):OnComplete(function ()
			self.bindData.takePhotoCtrl = 0

			gMessageManager:SendMessage(gEventConstants.VIDEO_CRAZY_PHOTO_FAIL, false)
		end)
	end
end

function M:OnDOFSliderValueChanged(value)
	gSoundMgr:PlaySoundByTid(70601122)

	local fov = self.templateConfig.FOV
	local minFov = fov.minValue
	local maxFov = fov.maxValue
	local defaultValue = fov.defaultValue
	local realValue, showValue = nil

	if value >= 50 then
		self.bindData.DOFSlider.stepSize = 5
		realValue = defaultValue + (value - 50) / 5 * (maxFov - defaultValue) / 10
		showValue = 1 + (value - 50) / 5 * 0.1
	else
		self.bindData.DOFSlider.stepSize = 10
		realValue = minFov + value / 10 * (maxFov - defaultValue) / 5
		showValue = 0.5 + value / 10 * 0.1
	end

	self.bindData.DOFSlider.valueText.text = string.format("%.1fx", showValue)
	self.currentFOV = (maxFov + minFov - realValue) / self.FovTimes

	gTakePhotoUtils.SetPhotoCameraFOV(self.currentFOV)
end

function M:OnMouseScroll(context)
	if SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() or self.photoMode == PhotoMode.Selfie or self.isSwitching then
		return
	end

	if context.performed then
		local zoom = context:ReadValueVector2().y
		self.scrollSignal = true

		if zoom > 0 then
			self:UpdateFovByMouseScroll(1)
		else
			self:UpdateFovByMouseScroll(-1)
		end
	end
end

function M:OnFOVPress(args)
	local op = args.op

	if op == 1 then
		self.isLEndPress = args.isEndPress
	else
		self.isREndPress = args.isEndPress
	end

	local isEndPress = self.isLEndPress and self.isREndPress

	if not isEndPress then
		self.isFovBtnPressing = true

		if not self.isLEndPress and not self.isREndPress then
			if op > 0 then
				self.FovChangeType = 1
			else
				self.FovChangeType = -1
			end
		elseif self.isREndPress then
			self.FovChangeType = 1
		else
			self.FovChangeType = -1
		end
	else
		self.isFovBtnPressing = false
		self.FovChangeType = 0
	end
end

local INTERVAL = 0.1

function M:UpdateFovByJoyStick()
	if not self.isFovBtnPressing then
		return
	end

	self.FovChangeTimeSignal = self.FovChangeTimeSignal + Time.deltaTime

	if self.FovChangeTimeSignal < INTERVAL then
		return
	end

	self.FovChangeTimeSignal = 0
	self.bindData.DOFSlider.value = self.bindData.DOFSlider.value + self.FovChangeType * self.bindData.DOFSlider.stepSize
end

function M:OnRightJoyStickInputChanged(context)
	local value = context:ReadValueVector2()

	if context.started or context.performed then
		self.needUpdateCamera = true
		self.rightStickValue.x = value.x
		self.rightStickValue.y = value.y
	end

	if context.canceled then
		self.needUpdateCamera = false
		self.rightStickValue.x = 0
		self.rightStickValue.y = 0

		gCameraUtils:DoRotateCameraByGamePad(5, 0, 0)
	end
end

function M:UpdateGamepadCamera()
	if self.needUpdateCamera then
		gCameraUtils:DoRotateCameraByGamePad(5, self.rightStickValue.x, self.rightStickValue.y)
	end
end

function M:CacheConfig(config)
	self.templateConfig.FOV = config.FOV
	self.templateConfig.canUIHide = config.canUIHide
	self.templateConfig.enterPhotoModeSec = config.enterPhotoModeSec
	self.templateConfig.enterSelfieModeSec = config.enterSelfieModeSec
	self.templateConfig.backPhotoModeSec = config.backPhotoModeSec
end

function M:InitUIElement()
	self.bindData.videoFocusCtrls = 3
end

function M:HideWholePanel(time)
	self.rootGo:SetActive(false)

	self.isSwitching = true
	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false

	gLuaTimeMgrUtils.Delay(function ()
		if gPanelManager:IsPanelShowing(gPanelId.S_PHOTOGRAPH_GAME_PANEL) then
			self.rootGo:SetActive(true)
		end

		self.isSwitching = false
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	end, time)
end

function M:UpdateFovByMouseScroll(op)
	self.bindData.DOFSlider.value = self.bindData.DOFSlider.value + op * self.bindData.DOFSlider.stepSize
end

function M:UpdateHudTargetData()
	if self.isSwitching or not self.updateHudData then
		self.bindData.videoFocusCtrls = 3
		self.bindData.gpsCtrl = 1

		return
	end

	if self.updateHudData.Type == gTakePhotoUtils.PhotoCustomTargetType.Video then
		self:UpdateVideoTarget(self.updateHudData)

		self.updateHudData = nil
	end
end

local function CalNotFocusTime(self)
	if self.inPhotoMode then
		return
	end

	if not gTakePhotoUtils.AllowVideoSettle then
		self.videoFocusTime = 0

		return
	end

	self.videoNotFocusTime = self.videoNotFocusTime + Time.deltaTime
	self.videoFocusTime = 0
end

local function CalFocusTime(self)
	if self.inPhotoMode then
		return
	end

	if not gTakePhotoUtils.AllowVideoSettle then
		self.videoNotFocusTime = 0

		return
	end

	self.beginVideo = true
	self.videoFocusTime = self.videoFocusTime + Time.deltaTime
	self.videoNotFocusTime = 0
end

function M:UpdateVideoTarget(data)
	if not data or not data.meetPos then
		self.bindData.videoFocusCtrls = 3
		self.bindData.gpsCtrl = 1

		return
	end

	local pos = data.meetPos
	local videoState = gTakePhotoUtils.GetTaskPositionState(pos, self.bindData.focusWidget, self.rootWidget.rectTransform)
	local successTime = data.successTime
	local failureTime = data.failureTime

	if videoState == VideoState.IN_VIEW then
		if gTakePhotoUtils.AllowVideoFOVCheck then
			local successFOV = gTakePhotoUtils.VideoMaxFov
			local successMinFOV = gTakePhotoUtils.VideoMinFov

			if self.currentFOV < successMinFOV then
				CalNotFocusTime(self)

				self.bindData.videoFocusCtrls = 2
				self.isAlreadyPlayFocus = false
			elseif successFOV < self.currentFOV then
				CalNotFocusTime(self)

				self.bindData.videoFocusCtrls = 1
				self.isAlreadyPlayFocus = false
			else
				CalFocusTime(self)

				self.bindData.videoFocusCtrls = 0

				if not self.isAlreadyPlayFocus then
					self.bindData.focusAnim:Play("S_Vx_PhotographGameVideoTemplate_Green")
					self.bindData.focusFrameAni:Play("S_Vx_PhotographGameVideoTemplate_FocusFrame")

					self.isAlreadyPlayFocus = true
				end
			end
		else
			CalFocusTime(self)

			self.bindData.videoFocusCtrls = 0

			if not self.isAlreadyPlayFocus then
				self.bindData.focusAnim:Play("S_Vx_PhotographGameVideoTemplate_Green")
				self.bindData.focusFrameAni:Play("S_Vx_PhotographGameVideoTemplate_FocusFrame")

				self.isAlreadyPlayFocus = true
			end
		end

		self.bindData.gpsCtrl = 1
	elseif videoState == VideoState.OUT_VIEW then
		CalNotFocusTime(self)

		self.bindData.videoFocusCtrls = 4

		if self.isAlreadyPlayFocus then
			self.bindData.focusFrameAni:Play("S_Vx_PhotographGameVideoTemplate_FocusFrame_out")
		end

		self.isAlreadyPlayFocus = false
		self.bindData.gpsCtrl = 1
	else
		CalNotFocusTime(self)

		self.bindData.videoFocusCtrls = 3
		self.isAlreadyPlayFocus = false
		self.bindData.gpsCtrl = 0
	end

	self.videoFocusTrans = pos

	if gTakePhotoUtils.AllowVideoSettle and self.bindData.videoFocusCtrls ~= 0 then
		local time = math.max(failureTime - self.videoNotFocusTime, 0)
		self.bindData.timeText.text = math.floor(time) .. "s"
		self.bindData.timeText2.text = math.floor(time) .. "s"
	end

	if successTime <= self.videoFocusTime then
		self:DoVideoSettle(true)

		return
	end

	if failureTime <= self.videoNotFocusTime then
		self:DoVideoSettle(false)

		return
	end
end

function M:DoVideoSettle(isSuccess)
	self.videoNotFocusTime = 0
	self.videoFocusTime = 0
	self.updateHudData = nil

	if isSuccess then
		gMessageManager:SendMessage(gEventConstants.VIDEO_SHOOT_SUCCESS)
	else
		gMessageManager:SendMessage(gEventConstants.VIDEO_SHOOT_MISSING)
	end
end

function M:UpdateVideoTargetOnce()
	if not self.videoFocusTrans then
		return
	end

	if self.bindData.gpsCtrl == 1 then
		local x, y, _ = gCS.LuaUtils.WorldToScreenPointProjected(self.videoFocusTrans, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
		local uiPos = gCS.LuaUtils.ScreenPointToUINoRay(x, y)
		uiPos = uiPos / SGUI.UIConfig.instance:GetCurrentAdaptationScale()

		self.bindData.videoTarget:SetLocalPosition(uiPos)
	else
		local clamped, uiWorldPos, arrowEulerZ = MainViewUtils.TryEllipseClampWorldPos2UIWorldPos(self.videoFocusTrans, self.bindData.ellipseRT, nil, nil)
		self.bindData.gpsRT.position = uiWorldPos
		local eulerZ = clamped and arrowEulerZ - 90 or 0

		self.bindData.arrowRT:SetLocalEulerAnglesZ(eulerZ)
	end
end
