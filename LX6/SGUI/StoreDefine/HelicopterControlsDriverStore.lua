-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HelicopterControlsDriverStore.lua
-- Decompiled from: 02019_HelicopterControlsDriverStore.lua_99776773a1c5.luajit

local HudDescConfig = LTConfig.HudDescConfig
C_HelicopterControlsDriverStore = DefClass("C_HelicopterControlsDriverStore", C_HelicopterControlsDriverStore, C_DriverStoreBase)
GroupName2Class.HelicopterControlsDriverStore = C_HelicopterControlsDriverStore
local M = C_HelicopterControlsDriverStore

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	LX6.GUI.NavMgrEx.Instance:AddBanArea(self.bindData.naveArea)
end

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
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self.CreateAction(self, "OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, "OnPhoneAppHide"),
		[gEventConstants.HELICOPTER_HITCH_STATE_CHANGE] = self.CreateAction(self, "OnButtonStateChange")
	}
end

M.RegisterWidget = function(self)
	self.bindData.forwardBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnForward", true)
	self.bindData.forwardBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnForward", false)
	self.bindData.backwardBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnBackward", true)
	self.bindData.backwardBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnBackward", false)
	self.bindData.leftBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnLeft", true)
	self.bindData.leftBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnLeft", false)
	self.bindData.rightBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnRight", true)
	self.bindData.rightBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnRight", false)
	self.bindData.upBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnUp", true)
	self.bindData.upBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnUp", false)
	self.bindData.downBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnDown", true)
	self.bindData.downBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnDown", false)
	self.bindData.leftRollBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnLeftRoll", true)
	self.bindData.leftRollBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnLeftRoll", false)
	self.bindData.leftRollBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnBtnLeftRoll", true)
	self.bindData.leftRollBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnBtnLeftRoll", false)
	self.bindData.rightRollBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnRightRoll", true)
	self.bindData.rightRollBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnRightRoll", false)
	self.bindData.rightRollBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnBtnRightRoll", true)
	self.bindData.rightRollBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnBtnRightRoll", false)
	self.bindData.ropeUpDownBtn.luaClick = self.CreateAction(self, "OnBtnRopeUpDown")
	self.bindData.ropeUnlockBtn.luaClick = self.CreateAction(self, "OnBtnRopeUnlock")
	self.bindData.ropeUnlockBtn.luaLongPress = self.CreateAction(self, "OnBtnRopeUnlock")
	self.bindData.joystick.luaValueChanged = self.CreateAction(self, "OnJoystickMove")
	self.bindData.leftStickRespond.luaGamePadInputChanged = self.CreateAction(self, "OnLeftStickControl")
	self.bindData.rightStickRespond.luaGamePadInputChanged = self.CreateAction(self, "OnRightStickControl")
end

M.RefreshMobileOnlyBtnVisibility = function(self)
	local hideCtrl = self.isMobile and self.ControlType.False or self.ControlType.True
	self.bindData.upBtnHideCtrl = hideCtrl
	self.bindData.downBtnHideCtrl = hideCtrl
	self.bindData.leftRollBtnHideCtrl = hideCtrl
	self.bindData.rightRollBtnHideCtrl = hideCtrl
end

M.OnGroupEnable = function(self)
	self:RegisterMessageEvents(self.msgEvents)

	self.ropeUpDownBtnStore = gStoreManager:GetStoreGroup(self.bindData.ropeUpDownBtn.Store):GetStoreByWidget(self.bindData.ropeUpDownBtn)

	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.ropeUpDownBtnStore = nil
	self.msgEvents = nil
end

M.OnDestroy = function(self)
	LX6.GUI.NavMgrEx.Instance:RemoveBanArea(self.bindData.naveArea)
	M.base.OnDestroy(self)
end

M.OnUpdate = function(self)
	if LX6.TouchNew.TouchProxy.useNewViewRotate then
		return
	end

	if self.gamepadMode then
		self.UpdateCameraRotateGamePad(self)
	end
end

M.UpdateCameraRotateGamePad = function(self)
	if not self.gamepadUpdateRotate then
		return
	end

	gCameraUtils:DoRotateCameraByGamePad(4, self.rightStickValue.x, self.rightStickValue.y)
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.OnEnterFinish = function(self)
	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())

	self.IsPhoneMode = gClientUtils.CheckMainPhoneIsShowing()
	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()

	self:RefreshMobileOnlyBtnVisibility()
	self:RefreshButtonState()
	self:RefreshRopeUpDownBtn()
	self:RefreshRopeUnlockBtn()
	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER, 4)
	gPanelManager:PushPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIDriveVehicle)
end

M.OnExitStart = function(self)
	gPanelManager:PopPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIDriveVehicle)
	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER)
end

M.RefreshButtonState = function(self)
	self.bindData.phoneModeCtrl = self.IsPhoneMode and self.ControlType.True or self.ControlType.False
end

M.OnPhoneAppShow = function(self)
	self.EnterPhoneMode(self)
end

M.OnPhoneAppHide = function(self)
	self.ExitPhoneMode(self)
end

M.EnterPhoneMode = function(self)
	self.IsPhoneMode = true

	if self.CheckReady(self) then
		self.RefreshButtonState(self)
	end
end

M.ExitPhoneMode = function(self)
	self.IsPhoneMode = false

	if self.CheckReady(self) then
		self.RefreshButtonState(self)
	end
end

M.OnBtnForward = function(self, isDown)
	if self.vehicleCs then
		self.vehicleCs:ModeForwardButtonHandle(isDown)
	end
end

M.OnBtnBackward = function(self, isDown)
	if self.vehicleCs then
		self.vehicleCs:MoveBackwardButtonHandle(isDown)
	end
end

M.OnBtnLeft = function(self, isDown)
	if self.vehicleCs then
		self.vehicleCs:ModeLeftButtonHandle(isDown)
	end
end

M.OnBtnRight = function(self, isDown)
	if self.vehicleCs then
		self.vehicleCs:ModeRightButtonHandle(isDown)
	end
end

M.OnBtnUp = function(self, isDown)
	if self.vehicleCs then
		self.vehicleCs:MoveUpThrottleButtonHandle(isDown)
	end
end

M.OnBtnDown = function(self, isDown)
	if self.vehicleCs then
		self.vehicleCs:MoveDownThrottleButtonHandle(isDown)
	end
end

M.OnBtnLeftRoll = function(self, isDown)
	if self.vehicleCs then
		self.vehicleCs:LeftRudderInputButtonHandle(isDown)
	end
end

M.OnBtnRightRoll = function(self, isDown)
	if self.vehicleCs then
		self.vehicleCs:RightRudderInputButtonHandle(isDown)
	end
end

M.OnBtnRopeUpDown = function(self)
	if self.vehicleCs then
		self.vehicleCs:InputTrigger(gVehicleUIButtonID.HelicopterRopeHitchButton)
	end
end

M.OnBtnRopeUnlock = function(self)
	if self.vehicleCs then
		self.vehicleCs:InputTrigger(gVehicleUIButtonID.HelicopterRopeUnbindButton)
	end
end

M.OnJoystickMove = function(self, x, y, size)
	if self.vehicleCs then
		self.vehicleCs:MoveHandle(x, y)
	end
end

M.OnLeftStickControl = function(self, context)
	local value = context.ReadValueVector2(context)

	if (context.started or context.performed) and self.vehicleCs then
		self.vehicleCs:MoveHandle(value.x, value.y)
	end

	if context.canceled and self.vehicleCs then
		self.vehicleCs:MoveHandle(0, 0)
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

M.SetBtnActive = function(self, btn, active)
	btn.SetActive(btn, active)
end

M.RefreshRopeUpDownBtn = function(self)
	local enable = self.vehicleCs and self.vehicleCs.RopeHitchButtonEnabled or false

	self.bindData.ropeUpDownBtn:SetActive(enable)

	if enable then
		local id = self.vehicleCs:RopeHitchDeployed() and 931 or 930

		self.bindData.ropeUpDownBtn:SetTipNameTotally(id)

		local cfg = LTConfig.InputButtonNameConfig.GetConfig(id)
		self.ropeUpDownBtnStore.notifyWord = cfg and cfg.Name or ""
	end
end

M.RefreshRopeUnlockBtn = function(self)
	local enable = self.vehicleCs and self.vehicleCs.RopeUnbindButtonEnabled or false

	self.bindData.ropeUnlockBtn:SetActive(enable)

	if enable then
		self.bindData.ropeUnlockBtn.interactable = self.vehicleCs:RopeCargoBinded()
	end
end

M.OnButtonStateChange = function(self, eventId, btnId, data)
	if not self.CheckReady(self) then
		return
	end

	if btnId ~= gVehicleUIButtonID.HelicopterRopeHitchButtonEnabledEventID or btnId ~= gVehicleUIButtonID.HelicopterRopeHitchDeployedEventID then
		self.RefreshRopeUpDownBtn(self)
	elseif btnId ~= gVehicleUIButtonID.HelicopterRopeUnbindButtonEnabledEventID or btnId ~= gVehicleUIButtonID.HelicopterRopeCargoBindedEventID then
		self.RefreshRopeUnlockBtn(self)
	end
end
