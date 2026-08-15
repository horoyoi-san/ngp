C_CoreHudMotoControlStore = DefClass("C_CoreHudMotoControlStore", C_CoreHudMotoControlStore, C_StoreGroup)
GroupName2Class.CoreHudMotoControlStore = C_CoreHudMotoControlStore
local M = C_CoreHudMotoControlStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.ControlType = {
		False = 0,
		True = 1
	}
	self.IsPhoneMode = gClientUtils.CheckMainPhoneIsShowing()
	self.started = false
	self.rightStickValue = {
		x = 0,
		y = 0
	}
	self.gamepadUpdateRotate = false
	self.UP_DOWN_THRESHOLD = 0.5
	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())
	LX6.GUI.NavMgrEx.Instance:AddBanArea(self.bindData.naveArea)
end

function M:OnEnable()
	return
end

function M:OnStart()
	self.started = true

	self:RefreshOutOfVehicleState()
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self.started = nil
	self.IsPhoneMode = nil
	self.gamepadMode = nil

	LX6.GUI.NavMgrEx.Instance:RemoveBanArea(self.bindData.naveArea)
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnUpdate()
	if self.gamePadMode then
		self:UpdateCameraRotateGamePad()
	end
end

function M:OnShow(panelId, data)
	self.showing = true
	self.moto = data.vehicleCs
	self.upPress = false
	self.downPress = false

	gPanelManager:PushPanelContext(gPanelId.S_CORE_HUD_PANEL, LTConfig.InputUIContextConfig.UIMoto)

	self.mobileJoystickOperation = LX6.Engine.ProfileManager.gameProfile.isVehicleJoystickMode
	self.bindData.OperationModeCtrl = self.isMobile and self.mobileJoystickOperation and self.ControlType.True or self.ControlType.False

	self:RefreshOutOfVehicleState()
end

function M:OnClose()
	self.showing = false

	gPanelManager:PopPanelContext(gPanelId.S_CORE_HUD_PANEL, LTConfig.InputUIContextConfig.UIMoto)

	self.moto = nil
end

function M:OnActiveDeviceChange(device)
	self.gamePadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:OnPhoneAppShow()
	self:EnterPhoneMode()
end

function M:OnPhoneAppHide()
	self:ExitPhoneMode()
end

function M:EnterPhoneMode()
	self.IsPhoneMode = true

	if self.started then
		self:RefreshButtonState()
	end
end

function M:ExitPhoneMode()
	self.IsPhoneMode = false

	if self.started then
		self:RefreshButtonState()
	end
end

function M:RefreshButtonState()
	self.bindData.PhoneOpenCtrl = self.IsPhoneMode and self.ControlType.True or self.ControlType.False
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self:CreateAction("OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self:CreateAction("OnPhoneAppHide"),
		[gEventConstants.SETTING_SEND_VEHICLE_MODE] = self:CreateAction("OnVehicleControlModeChange"),
		[gEventConstants.LOCK_DRIVE_MODE] = self:CreateAction("RefreshOutOfVehicleState")
	}
end

function M:RegisterWidget()
	self.bindData.upBtn.luaPress = self:CreateActionWithArgs("OnClickUpBtn", true)
	self.bindData.upBtn.luaRelease = self:CreateActionWithArgs("OnClickUpBtn", false)
	self.bindData.downBtn.luaPress = self:CreateActionWithArgs("OnClickDownBtn", true)
	self.bindData.downBtn.luaRelease = self:CreateActionWithArgs("OnClickDownBtn", false)
	self.bindData.driftBtn.luaPress = self:CreateActionWithArgs("OnClickDriftBtn", true)
	self.bindData.driftBtn.luaRelease = self:CreateActionWithArgs("OnClickDriftBtn", false)
	self.bindData.outOfMotoBtn.luaClick = self:CreateAction("OnClickOutOfMotoBtn")
	self.bindData.outOfMotoBtn.luaLongPress = self:CreateAction("OnClickOutOfMotoBtn")
	self.bindData.viewBtn.luaClick = self:CreateAction("OnClickViewBtn")
	self.bindData.outOfFreezeBtn.luaClick = self:CreateAction("OnClickOutOfFreezeBtn")
	self.bindData.forwardBtn.luaPress = self:CreateActionWithArgs("OnBtnForward", true)
	self.bindData.forwardBtn.luaRelease = self:CreateActionWithArgs("OnBtnForward", false)
	self.bindData.backwardBtn.luaPress = self:CreateActionWithArgs("OnBtnBackward", true)
	self.bindData.backwardBtn.luaRelease = self:CreateActionWithArgs("OnBtnBackward", false)
	self.bindData.leftBtn.luaPress = self:CreateActionWithArgs("OnBtnLeft", true)
	self.bindData.leftBtn.luaRelease = self:CreateActionWithArgs("OnBtnLeft", false)
	self.bindData.rightBtn.luaPress = self:CreateActionWithArgs("OnBtnRight", true)
	self.bindData.rightBtn.luaRelease = self:CreateActionWithArgs("OnBtnRight", false)
	self.bindData.forwardBtnPhone.luaPress = self:CreateActionWithArgs("OnBtnForward", true)
	self.bindData.forwardBtnPhone.luaRelease = self:CreateActionWithArgs("OnBtnForward", false)
	self.bindData.backwardBtnPhone.luaPress = self:CreateActionWithArgs("OnBtnBackward", true)
	self.bindData.backwardBtnPhone.luaRelease = self:CreateActionWithArgs("OnBtnBackward", false)
	self.bindData.leftBtnPhone.luaPress = self:CreateActionWithArgs("OnBtnLeft", true)
	self.bindData.leftBtnPhone.luaRelease = self:CreateActionWithArgs("OnBtnLeft", false)
	self.bindData.rightBtnPhone.luaPress = self:CreateActionWithArgs("OnBtnRight", true)
	self.bindData.rightBtnPhone.luaRelease = self:CreateActionWithArgs("OnBtnRight", false)
	self.bindData.joystick.luaValueChanged = self:CreateAction("OnJoystickMove")
	self.bindData.leftStickRespond.luaGamePadInputChanged = self:CreateAction("OnLeftStickControl")
	self.bindData.rightStickRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")
	self.bindData.leftTriggerRespond.luaGamePadInputChanged = self:CreateAction("OnLeftTriggerControl")
	self.bindData.rightTriggerRespond.luaGamePadInputChanged = self:CreateAction("OnRightTriggerControl")
end

function M:OnBtnForward(isDown)
	if self.moto then
		self.moto:MotorcycleForwardThrottleButtonHandle(isDown)
	end
end

function M:OnBtnBackward(isDown)
	if self.moto then
		self.moto:MotorcycleBackwardThrottleButtonHandle(isDown)
	end
end

function M:OnBtnLeft(isDown)
	if self.moto then
		self.moto:MotorcycleLeftSteerButtonHandle(isDown)
	end
end

function M:OnBtnRight(isDown)
	if self.moto then
		self.moto:MotorcycleRightSteerButtonHandle(isDown)
	end
end

function M:OnClickDownBtn(isDown)
	self.downPress = isDown

	if self.moto then
		self.moto:MotorcycleRearWheelieButtonHandle(isDown)
	end
end

function M:OnClickUpBtn(isDown)
	self.upPress = isDown

	if self.moto then
		self.moto:MotorcycleFrontWheelieButtonHandle(isDown)
	end
end

function M:OnClickDriftBtn(isDown)
	if self.moto then
		self.moto:MotorcycleRearBrakeButtonHandle(isDown)
	end
end

function M:OnClickOutOfMotoBtn()
	gVehicleInteractManager.cs_manager:OnLeaveVehicleButtonClick()
end

function M:OnClickOutOfFreezeBtn()
	if self.moto then
		self.moto:MotorcycleResetButtonHandle()
	end
end

function M:OnJoystickMove(x, y, size)
	if self.moto then
		self.moto:MotorcycleMoveGamepadHandle(x, y)
	end
end

function M:OnClickViewBtn()
	local val = LX6.Cinemachine.NPDVehicleCameraState.armLengthPreference
	val = val + 1

	if val > 3 then
		val = 1
	end

	LX6.Cinemachine.NPDVehicleCameraState.armLengthPreference = val
end

function M:OnLeftStickControl(context)
	if (context.started or context.performed) and self.moto then
		local val = context:ReadValueVector2()

		self.moto:MotorcycleSteerAndWheelieGamepadHandle(val.x, val.y)
	end

	if context.canceled and self.moto then
		self.moto:MotorcycleSteerAndWheelieGamepadHandle(0, 0)
	end
end

function M:OnRightStickControl(context)
	local value = context:ReadValueVector2()

	if context.started or context.performed then
		self.gamepadUpdateRotate = true
		self.rightStickValue.x = value.x
		self.rightStickValue.y = value.y
	end

	if context.canceled then
		self.gamepadUpdateRotate = false
		self.rightStickValue.x = 0
		self.rightStickValue.y = 0

		gCameraUtils:DoRotateCameraByGamePad(4, 0, 0)
	end
end

function M:OnLeftTriggerControl(context)
	if not self.gamePadMode then
		return
	end

	if (context.started or context.performed) and self.moto then
		self.moto:MotorcycleBackwardThrottleGamepadHandle(context:ReadValueFloat())
	end

	if context.canceled and self.moto then
		self.moto:MotorcycleBackwardThrottleGamepadHandle(0)
	end
end

function M:OnRightTriggerControl(context)
	if not self.gamePadMode then
		return
	end

	if (context.started or context.performed) and self.moto then
		self.moto:MotorcycleForwardThrottleGamepadHandle(context:ReadValueFloat())
	end

	if context.canceled and self.moto then
		self.moto:MotorcycleForwardThrottleGamepadHandle(0)
	end
end

function M:UpdateCameraRotateGamePad()
	if not self.gamepadUpdateRotate then
		return
	end

	gCameraUtils:DoRotateCameraByGamePad(4, self.rightStickValue.x, self.rightStickValue.y)
end

function M:OnVehicleControlModeChange(eventId, mode)
	if self.showing then
		self.mobileJoystickOperation = mode
		self.bindData.OperationModeCtrl = self.isMobile and self.mobileJoystickOperation and self.ControlType.True or self.ControlType.False
	end
end

function M:RefreshOutOfVehicleState(eventId, lock)
	if not self.showing or not self.started then
		return
	end

	if self.moto then
		self:SetBtnActive(self.bindData.outOfMotoBtn, not self.moto:IsSeatLockLeave(gDriveVehiclesManager.cs_manager.CurDriveSeatIndex))
	end
end

function M:SetBtnActive(btn, active)
	btn:SetActive(active)
end
