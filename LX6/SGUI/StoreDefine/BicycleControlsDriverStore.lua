-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BicycleControlsDriverStore.lua
-- Decompiled from: 02021_BicycleControlsDriverStore.lua_b659d308e2f5.luajit

local HudDescConfig = LTConfig.HudDescConfig
local InputButtonNameConfig = LTConfig.InputButtonNameConfig
C_BicycleControlsDriverStore = DefClass("C_BicycleControlsDriverStore", C_BicycleControlsDriverStore, C_DriverStoreBase)
GroupName2Class.BicycleControlsDriverStore = C_BicycleControlsDriverStore
local M = C_BicycleControlsDriverStore

M.DefineAllVariables = function(self)
	self.ControlType = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
	self.rightStickValue = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	self.gamepadUpdateRotate = false
	self.UP_DOWN_THRESHOLD = 0.5
	self.RIDE_POSTURE_TEXT_ID_SIT = 743
	self.RIDE_POSTURE_TEXT_ID_STAND = 744
end

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	LX6.GUI.NavMgrEx.Instance:AddBanArea(self.bindData.naveArea)
end

M.OnDestroy = function(self)
	self.IsPhoneMode = nil
	self.gamepadMode = nil

	LX6.GUI.NavMgrEx.Instance:RemoveBanArea(self.bindData.naveArea)
	M.base.OnDestroy(self)
end

M.OnGroupEnable = function(self)
	self:RegisterMessageEvents(self.msgEvents)

	self.forwardBtnStore = self:GetStoreByWidget(self.bindData.forwardBtn)
	self.backwardBtnStore = self:GetStoreByWidget(self.bindData.backwardBtn)
	self.driftBtnStore = self:GetStoreByWidget(self.bindData.driftBtn)
	self.driftBtnJoystickStore = self:GetStoreByWidget(self.bindData.driftBtnJoystick)
	self.ridePostureBtnStore = self:GetStoreByWidget(self.bindData.ridePostureBtn)

	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.forwardBtnStore = nil
	self.backwardBtnStore = nil
	self.driftBtnStore = nil
	self.driftBtnJoystickStore = nil
	self.ridePostureBtnStore = nil
end

M.OnUpdate = function(self)
	if LX6.TouchNew.TouchProxy.useNewViewRotate then
		return
	end

	if self.gamePadMode then
		self.UpdateCameraRotateGamePad(self)
	end
end

M.OnActiveDeviceChange = function(self, device)
	self.gamePadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.OnEnterFinish = function(self)
	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())

	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	self.IsPhoneMode = gClientUtils.CheckMainPhoneIsShowing()

	gPanelManager:PushPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIMoto)

	self.mobileJoystickOperation = LX6.Engine.ProfileManager.gameProfile.isVehicleJoystickMode
	self.bindData.OperationModeCtrl = self.isMobile and self.mobileJoystickOperation and self.ControlType.True or self.ControlType.False

	self:RefreshRidePostureTip()
	self:RefreshPhoneState()
	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER, 4)

	local cfg = LTConfig.VehicleConfig.GetConfig(self.vehicleCs.cfgId)
	local vehicleType = cfg and cfg.VehicleType or ""
	self.vehicleTypeCfg = gDriveVehiclesManager:GetVehicleTypeConfig(vehicleType)

	self:RefreshTriggerFeedback()
end

M.OnExitStart = function(self)
	gPanelManager:PopPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIMoto)
	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER)
end

M.OnPhoneAppShow = function(self)
	self.EnterPhoneMode(self)
end

M.OnPhoneAppHide = function(self)
	self.ExitPhoneMode(self)
end

M.EnterPhoneMode = function(self)
	self.IsPhoneMode = true

	if self.showing then
		self.RefreshPhoneState(self)
	end
end

M.ExitPhoneMode = function(self)
	self.IsPhoneMode = false

	if self.showing then
		self.RefreshPhoneState(self)
	end
end

M.RefreshPhoneState = function(self)
	self.bindData.PhoneOpenCtrl = self.IsPhoneMode and self.ControlType.True or self.ControlType.False
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self.CreateAction(self, "OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, "OnPhoneAppHide"),
		[gEventConstants.SETTING_SEND_VEHICLE_MODE] = self.CreateAction(self, "OnVehicleControlModeChange"),
		[gEventConstants.VEHICLE_START_DRIVING_STATE_CHANGED] = self.CreateAction(self, "OnTriggerFeedbackChange")
	}
end

M.RegisterWidget = function(self)
	self.bindData.driftBtn.luaPress = self.CreateActionWithArgs(self, "OnClickDriftBtn", true)
	self.bindData.driftBtn.luaRelease = self.CreateActionWithArgs(self, "OnClickDriftBtn", false)
	self.bindData.driftBtnJoystick.luaPress = self.CreateActionWithArgs(self, "OnClickDriftBtn", true)
	self.bindData.driftBtnJoystick.luaRelease = self.CreateActionWithArgs(self, "OnClickDriftBtn", false)
	self.bindData.ridePostureBtn.luaClick = self.CreateAction(self, "OnClickRidePostureBtn")
	self.bindData.forwardBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnForward", true)
	self.bindData.forwardBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnForward", false)
	self.bindData.backwardBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnBackward", true)
	self.bindData.backwardBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnBackward", false)
	self.bindData.leftBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnLeft", true)
	self.bindData.leftBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnLeft", false)
	self.bindData.rightBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnRight", true)
	self.bindData.rightBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnRight", false)
	self.bindData.forwardBtnPhone.luaPress = self.CreateActionWithArgs(self, "OnBtnForward", true)
	self.bindData.forwardBtnPhone.luaRelease = self.CreateActionWithArgs(self, "OnBtnForward", false)
	self.bindData.backwardBtnPhone.luaPress = self.CreateActionWithArgs(self, "OnBtnBackward", true)
	self.bindData.backwardBtnPhone.luaRelease = self.CreateActionWithArgs(self, "OnBtnBackward", false)
	self.bindData.leftBtnPhone.luaPress = self.CreateActionWithArgs(self, "OnBtnLeft", true)
	self.bindData.leftBtnPhone.luaRelease = self.CreateActionWithArgs(self, "OnBtnLeft", false)
	self.bindData.rightBtnPhone.luaPress = self.CreateActionWithArgs(self, "OnBtnRight", true)
	self.bindData.rightBtnPhone.luaRelease = self.CreateActionWithArgs(self, "OnBtnRight", false)
	self.bindData.joystick.luaValueChanged = self.CreateAction(self, "OnJoystickMove")
	self.bindData.leftStickRespond.luaGamePadInputChanged = self.CreateAction(self, "OnLeftStickControl")
	self.bindData.rightStickRespond.luaGamePadInputChanged = self.CreateAction(self, "OnRightStickControl")
	self.bindData.leftTriggerRespond.luaGamePadInputChanged = self.CreateAction(self, "OnLeftTriggerControl")
	self.bindData.rightTriggerRespond.luaGamePadInputChanged = self.CreateAction(self, "OnRightTriggerControl")
end

M.OnBtnForward = function(self, isDown)
	if self.vehicleCs then
		self.vehicleCs:MotorcycleForwardThrottleButtonHandle(isDown)
	end
end

M.OnBtnBackward = function(self, isDown)
	if self.vehicleCs then
		self.vehicleCs:MotorcycleBackwardThrottleButtonHandle(isDown)
	end
end

M.OnBtnLeft = function(self, isDown)
	if self.vehicleCs then
		self.vehicleCs:MotorcycleLeftSteerButtonHandle(isDown)
	end
end

M.OnBtnRight = function(self, isDown)
	if self.vehicleCs then
		self.vehicleCs:MotorcycleRightSteerButtonHandle(isDown)
	end
end

M.OnClickDriftBtn = function(self, isDown)
	if self.vehicleCs then
		self.vehicleCs:MotorcycleRearBrakeButtonHandle(isDown)
	end
end

M.OnJoystickMove = function(self, x, y, size)
	if self.vehicleCs then
		self.vehicleCs:MotorcycleMoveGamepadHandle(x, y)
	end
end

M.OnClickRidePostureBtn = function(self)
	if self.vehicleCs then
		self.vehicleCs:ToggleBicycleRideMode()
		self:RefreshRidePostureTip()
	end
end

M.RefreshRidePostureTip = function(self)
	local IsFastMode = self.vehicleCs.IsFastRideMode
	local textId = IsFastMode and self.RIDE_POSTURE_TEXT_ID_SIT or self.RIDE_POSTURE_TEXT_ID_STAND
	local cfg = InputButtonNameConfig.GetConfig(textId)
	self.ridePostureBtnStore.notifyWord = cfg and cfg.Name or ""

	self.bindData.ridePostureBtn:SetTipNameTotally(textId)
end

M.OnLeftStickControl = function(self, context)
	if (context.started or context.performed) and self.vehicleCs then
		local val = context:ReadValueVector2()

		self.vehicleCs:MotorcycleSteerAndWheelieGamepadHandle(val.x, 0)
	end

	if context.canceled and self.vehicleCs then
		self.vehicleCs:MotorcycleSteerAndWheelieGamepadHandle(0, 0)
	end
end

M.OnRightStickControl = function(self, context)
	local value = context.ReadValueVector2(context)

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

M.OnLeftTriggerControl = function(self, context)
	if not self.gamePadMode then
		return
	end

	if (context.started or context.performed) and self.vehicleCs then
		self.vehicleCs:MotorcycleBackwardThrottleGamepadHandle(context:ReadValueFloat())
	end

	if context.canceled and self.vehicleCs then
		self.vehicleCs:MotorcycleBackwardThrottleGamepadHandle(0)
	end
end

M.OnRightTriggerControl = function(self, context)
	if not self.gamePadMode then
		return
	end

	if (context.started or context.performed) and self.vehicleCs then
		self.vehicleCs:MotorcycleForwardThrottleGamepadHandle(context:ReadValueFloat())
	end

	if context.canceled and self.vehicleCs then
		self.vehicleCs:MotorcycleForwardThrottleGamepadHandle(0)
	end
end

M.UpdateCameraRotateGamePad = function(self)
	if not self.gamepadUpdateRotate then
		return
	end

	gCameraUtils:DoRotateCameraByGamePad(4, self.rightStickValue.x, self.rightStickValue.y)
end

M.OnVehicleControlModeChange = function(self, eventId, mode)
	if self.showing then
		self.mobileJoystickOperation = mode
		self.bindData.OperationModeCtrl = self.isMobile and self.mobileJoystickOperation and self.ControlType.True or self.ControlType.False
	end
end

M.SetBtnActive = function(self, btn, active)
	btn.SetActive(btn, active)
end

M.SetBtnVisible = function(self, btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
end

M.RefreshTriggerFeedback = function(self)
	self.IsStartDriving = self.vehicleCs.IsStartDriving

	if self.isMobile then
		return
	end

	if self.vehicleTypeCfg then
		self.bindData.naveArea:ChangeDualSenseByActionId(110, self.IsStartDriving and self.vehicleTypeCfg.InitialStopAdaptiveTrigger or self.vehicleTypeCfg.NonInitialStopAdaptiveTrigger)
		self.bindData.naveArea:ChangeDualSenseByActionId(111, self.IsStartDriving and self.vehicleTypeCfg.InitialAdaptiveTrigger or self.vehicleTypeCfg.NonInitialAdaptiveTrigger)
	end
end

M.OnTriggerFeedbackChange = function(self)
	if not self.CheckReady(self) then
		return
	end

	self.RefreshTriggerFeedback(self)
end
