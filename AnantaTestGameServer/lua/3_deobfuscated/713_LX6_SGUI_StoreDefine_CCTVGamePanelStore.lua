local PhotographTemplateConfig = LTConfig.PhotoPhotographTemplateConfig
local PhotoTemplate = gTakePhotoUtils.PhotoTemplate
local GameInputManager = LX6.Manager.GameInputManager
local VideoState = gTakePhotoUtils.PhotoTaskTargetState
C_CCTVGamePanelStore = DefClass("C_CCTVGamePanelStore", C_CCTVGamePanelStore, C_StoreGroup)
GroupName2Class.CCTVGamePanelStore = C_CCTVGamePanelStore
local M = C_CCTVGamePanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.photoTemplate = PhotoTemplate.SlotEntity
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
end

function M:OnAwake()
	self:DefineAllVariables()

	local config = PhotographTemplateConfig.GetConfig(self.photoTemplate)

	if not config then
		print_error("不存在的拍照模板配置:", self.photoTemplate)

		return
	end

	self:CacheConfig(config)
	self:GenMessageEvents()
	self:RegisterWidget()
	gTakePhotoUtils.CallOnPhotoPanelAwake()
end

function M:OnEnable()
	return
end

function M:OnDisable()
	gTakePhotoUtils.CallOnPhotoPanelDisable()
end

function M:OnDestroy()
	gMessageManager:SendMessage(gEventConstants.PHOTO_CONTROLLER_DESTROY)

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

	self:InitUIElement()
	gCS.CameraDataMgr.cinemachineManager:SetFov(self.templateConfig.FOV.defaultValue, 0.1, 0, false)
end

function M:OnClose()
	LX6.Share.SceneRoomR.LockRoomProbe(false)

	if gClientUtils.CheckMainPhoneIsShowing() then
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false
	end

	gCS.CameraDataMgr.cinemachineManager:SetFov(50, 0, 0, false)
end

function M:OnUpdate()
	self:UpdateHudTargetData()
	self:UpdateGamepadCamera()
	self:UpdateFovByJoyStick()
end

function M:OnCameraUpdate()
	self:UpdateVideoTargetOnce()
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.PHOTO_CUSTOM_TARGET] = function (eventId, data)
			self.updateHudData = data
		end
	}
end

function M:RegisterWidget()
	self.bindData.closeBtn.luaClick = self:CreateAction("OnClickCloseBtn")
	self.bindData.DOFSlider.luaValueChanged = self:CreateAction("OnDOFSliderValueChanged")
	local fov = self.templateConfig.FOV
	self.bindData.DOFSlider.minValue = 0
	self.bindData.DOFSlider.maxValue = 100
	self.bindData.DOFSlider.stepSize = 5
	self.bindData.DOFSlider.luaValueChanged = self:CreateAction("OnDOFSliderValueChanged")
	self.bindData.DOFSlider.value = 50
	self.bindData.sliderStyle = 1
	self.defaultFov = fov.defaultValue

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
		realValue = minFov + value / 10 * (defaultValue - minFov) / 5
		showValue = 0.5 + value / 10 * 0.1
	end

	self.bindData.DOFSlider.valueText.text = string.format("%.1fx", showValue)

	gCS.CameraDataMgr.cinemachineManager:SetFov(maxFov + minFov - realValue, 0.1, 0, false)
end

function M:OnMouseScroll(context)
	if SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() or self.isSwitching then
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
		gCameraUtils:DoRotateCameraByGamePad(8, self.rightStickValue.x, self.rightStickValue.y)
	else
		gCameraUtils:DoRotateCameraByGamePad(8, 0, 0)
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

function M:UpdateFovByMouseScroll(op)
	self.bindData.DOFSlider.value = self.bindData.DOFSlider.value + op * self.bindData.DOFSlider.stepSize
end

function M:UpdateHudTargetData()
	if self.isSwitching or not self.updateHudData then
		self.bindData.videoFocusCtrls = 3

		return
	end

	if self.updateHudData.Type == gTakePhotoUtils.PhotoCustomTargetType.Video then
		self:UpdateVideoTarget(self.updateHudData)

		self.updateHudData = nil
	end
end

local function CalNotFocusTime(self)
	if not gTakePhotoUtils.AllowVideoSettle then
		self.videoFocusTime = 0

		return
	end

	self.videoNotFocusTime = self.videoNotFocusTime + Time.deltaTime
	self.videoFocusTime = 0
end

local function CalFocusTime(self)
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

		return
	end

	local pos = data.meetPos
	local videoState = gTakePhotoUtils.GetTaskPositionState(pos, self.bindData.focusWidget, self.rootWidget.rectTransform)
	local sqrInterval = data.sqrInterval
	local successDistance = data.successDistance
	local successMinDistance = data.successMinDistance
	local successTime = data.successTime
	local failureTime = data.failureTime

	if videoState == VideoState.IN_VIEW then
		if sqrInterval < successMinDistance * successMinDistance then
			CalNotFocusTime(self)

			self.bindData.videoFocusCtrls = 2
			self.isAlreadyPlayFocus = false
		elseif sqrInterval > successDistance * successDistance then
			CalNotFocusTime(self)

			self.bindData.videoFocusCtrls = 1
			self.isAlreadyPlayFocus = false
		else
			CalFocusTime(self)

			self.bindData.videoFocusCtrls = 0

			if not self.isAlreadyPlayFocus then
				self.isAlreadyPlayFocus = true
			end
		end
	elseif videoState == VideoState.OUT_VIEW then
		CalNotFocusTime(self)

		self.bindData.videoFocusCtrls = 4
		self.isAlreadyPlayFocus = false
	else
		CalNotFocusTime(self)

		self.bindData.videoFocusCtrls = 3
		self.isAlreadyPlayFocus = false
	end

	self.videoFocusTrans = pos

	if gTakePhotoUtils.AllowVideoSettle and self.bindData.videoFocusCtrls ~= 0 then
		self.bindData.timeText:SetActive(true)

		self.bindData.timeText.text = string.format("%.1fs", failureTime - self.videoNotFocusTime)
	else
		self.bindData.timeText:SetActive(false)
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

	local x, y, _ = gCS.LuaUtils.WorldToScreenPointProjected(self.videoFocusTrans, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
	local uiPos = gCS.LuaUtils.ScreenPointToUINoRay(x, y)
	uiPos = uiPos / SGUI.UIConfig.instance:GetCurrentAdaptationScale()

	self.bindData.videoTarget:SetLocalPosition(uiPos)
end
