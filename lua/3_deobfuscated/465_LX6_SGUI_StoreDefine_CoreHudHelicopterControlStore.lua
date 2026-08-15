C_CoreHudHelicopterControlStore = DefClass("C_CoreHudHelicopterControlStore", C_CoreHudHelicopterControlStore, C_StoreGroup)
GroupName2Class.CoreHudHelicopterControlStore = C_CoreHudHelicopterControlStore
local M = C_CoreHudHelicopterControlStore

function M:ctor()
	self.msgEvents = {
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self:CreateAction("OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self:CreateAction("OnPhoneAppHide"),
		[gEventConstants.LOCK_DRIVE_MODE] = self:CreateAction("RefreshOutOfVehicleState")
	}
end

function M:OnAwake()
	self.ControlType = {
		False = 0,
		True = 1
	}
	self.bindData.forwardBtn.luaPress = self:CreateActionWithArgs("OnBtnForward", true)
	self.bindData.forwardBtn.luaRelease = self:CreateActionWithArgs("OnBtnForward", false)
	self.bindData.backwardBtn.luaPress = self:CreateActionWithArgs("OnBtnBackward", true)
	self.bindData.backwardBtn.luaRelease = self:CreateActionWithArgs("OnBtnBackward", false)
	self.bindData.leftBtn.luaPress = self:CreateActionWithArgs("OnBtnLeft", true)
	self.bindData.leftBtn.luaRelease = self:CreateActionWithArgs("OnBtnLeft", false)
	self.bindData.rightBtn.luaPress = self:CreateActionWithArgs("OnBtnRight", true)
	self.bindData.rightBtn.luaRelease = self:CreateActionWithArgs("OnBtnRight", false)
	self.bindData.upBtn.luaPress = self:CreateActionWithArgs("OnBtnUp", true)
	self.bindData.upBtn.luaRelease = self:CreateActionWithArgs("OnBtnUp", false)
	self.bindData.downBtn.luaPress = self:CreateActionWithArgs("OnBtnDown", true)
	self.bindData.downBtn.luaRelease = self:CreateActionWithArgs("OnBtnDown", false)
	self.bindData.outOfDroneBtn.luaLongPress = self:CreateAction("OnBtnOutOfDrone")
	self.bindData.outOfDroneBtn.luaClick = self:CreateAction("OnBtnOutOfDrone")
	self.bindData.joystick.luaValueChanged = self:CreateAction("OnJoystickMove")
	self.bindData.leftStickRespond.luaGamePadInputChanged = self:CreateAction("OnLeftStickControl")
	self.bindData.rightStickRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")

	self:RegisterMessageEvents(self.msgEvents)
	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())
	LX6.GUI.NavMgrEx.Instance:AddBanArea(self.bindData.naveArea)

	self.IsPhoneMode = gClientUtils.CheckMainPhoneIsShowing()
	self.started = false
	self.rightStickValue = {
		x = 0,
		y = 0
	}
	self.gamepadUpdateRotate = false
end

function M:OnStart()
	self.started = true

	self:RefreshButtonState()
	self:RefreshOutOfVehicleState()
end

function M:OnDestroy()
	self.started = nil

	self:ClearMessageEvents()
	LX6.GUI.NavMgrEx.Instance:RemoveBanArea(self.bindData.naveArea)
end

function M:OnShow(panelId, data)
	self.showing = true
	self.helicopter = data.vehicleCs

	self:RefreshButtonState()
	self:RefreshOutOfVehicleState()
end

function M:OnClose()
	self.showing = false
	self.helicopter = nil
end

function M:OnUpdate()
	if self.gamepadMode then
		self:UpdateCameraRotateGamePad()
	end
end

function M:UpdateCameraRotateGamePad()
	if not self.gamepadUpdateRotate then
		return
	end

	gCameraUtils:DoRotateCameraByGamePad(4, self.rightStickValue.x, self.rightStickValue.y)
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:RefreshButtonState()
	if not self.showing or not self.started then
		return
	end

	self.bindData.phoneModeCtrl = self.IsPhoneMode and self.ControlType.True or self.ControlType.False
end

function M:OnPhoneAppShow()
	self:EnterPhoneMode()
end

function M:OnPhoneAppHide()
	self:ExitPhoneMode()
end

function M:EnterPhoneMode()
	self.IsPhoneMode = true

	if self.STATE_EnableOnce then
		if self.started then
			self:RefreshButtonState()
		end

		if self.curTypeStore and self.curTypeStore.EnterPhoneMode then
			self.curTypeStore:EnterPhoneMode()
		end
	end
end

function M:ExitPhoneMode()
	self.IsPhoneMode = false

	if self.STATE_EnableOnce then
		if self.started then
			self:RefreshButtonState()
		end

		if self.curTypeStore and self.curTypeStore.ExitPhoneMode then
			self.curTypeStore:ExitPhoneMode()
		end
	end
end

function M:OnBtnForward(isDown)
	if self.helicopter then
		self.helicopter:ModeForwardButtonHandle(isDown)
	end
end

function M:OnBtnBackward(isDown)
	if self.helicopter then
		self.helicopter:MoveBackwardButtonHandle(isDown)
	end
end

function M:OnBtnLeft(isDown)
	if self.helicopter then
		self.helicopter:ModeLeftButtonHandle(isDown)
	end
end

function M:OnBtnRight(isDown)
	if self.helicopter then
		self.helicopter:ModeRightButtonHandle(isDown)
	end
end

function M:OnBtnUp(isDown)
	if self.helicopter then
		self.helicopter:MoveUpThrottleButtonHandle(isDown)
	end
end

function M:OnBtnDown(isDown)
	if self.helicopter then
		self.helicopter:MoveDownThrottleButtonHandle(isDown)
	end
end

function M:OnJoystickMove(x, y, size)
	if self.helicopter then
		self.helicopter:MoveHandle(x, y)
	end
end

function M:OnBtnOutOfDrone()
	gVehicleInteractManager.cs_manager:OnLeaveVehicleButtonClick()
end

function M:OnLeftStickControl(context)
	local value = context:ReadValueVector2()

	if (context.started or context.performed) and self.helicopter then
		self.helicopter:MoveHandle(value.x, value.y)
	end

	if context.canceled and self.helicopter then
		self.helicopter:MoveHandle(0, 0)
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

function M:RefreshOutOfVehicleState(eventId, lock)
	if not self.showing or not self.started then
		return
	end

	if self.helicopter then
		self:SetBtnActive(self.bindData.outOfDroneBtn, not self.helicopter:IsSeatLockLeave(gDriveVehiclesManager.cs_manager.CurDriveSeatIndex))
	end
end

function M:SetBtnActive(btn, active)
	btn:SetActive(active)
end
