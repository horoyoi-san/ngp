local DriveManager = gCS.DriveManager
C_CoreHudBoatControlStore = DefClass("C_CoreHudBoatControlStore", C_CoreHudBoatControlStore, C_StoreGroup)
GroupName2Class.CoreHudBoatControlStore = C_CoreHudBoatControlStore
local M = C_CoreHudBoatControlStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.gamePadMode = false
	self.IsPhoneMode = false
	self.rightStickValue = {
		x = 0,
		y = 0
	}
	self.gamepadUpdateRotate = false
	self.ControlType = {
		False = 0,
		True = 1
	}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())
	LX6.GUI.NavMgrEx.Instance:AddBanArea(self.bindData.navArea)
end

function M:OnStart()
	self.started = true

	if self.showing and self.started then
		self:RefreshButtonState()
		self:RefreshOutOfVehicleState()
	end
end

function M:OnDestroy()
	self.started = nil
	self.IsPhoneMode = nil
	self.gamePadMode = nil

	LX6.GUI.NavMgrEx.Instance:RemoveBanArea(self.bindData.navArea)
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)

	self.forwardBtnStore = self:GetStoreByWidget(self.bindData.forwardBtn)
	self.backwardBtnStore = self:GetStoreByWidget(self.bindData.backwardBtn)
	self.leftBtnStore = self:GetStoreByWidget(self.bindData.leftBtn)
	self.rightBtnStore = self:GetStoreByWidget(self.bindData.rightBtn)
	self.forwardBtnPhoneStore = self:GetStoreByWidget(self.bindData.forwardBtnPhone)
	self.backwardBtnPhoneStore = self:GetStoreByWidget(self.bindData.backwardBtnPhone)
	self.leftBtnPhoneStore = self:GetStoreByWidget(self.bindData.leftBtnPhone)
	self.rightBtnPhoneStore = self:GetStoreByWidget(self.bindData.rightBtnPhone)
	self.outOfBoatBtnStore = self:GetStoreByWidget(self.bindData.outOfBoatBtn)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self.currVehicleData = data
	self.showing = true

	if self.showing and self.started then
		self:RefreshButtonState()
		self:RefreshOutOfVehicleState()
	end

	gPanelManager:PushPanelContext(gPanelId.S_CORE_HUD_PANEL, LTConfig.InputUIContextConfig.UIBoat)
end

function M:OnUpdate()
	if self.gamePadMode then
		self:UpdateCameraRotateGamePad()
	end
end

function M:UpdateCameraRotateGamePad()
	if not self.gamepadUpdateRotate then
		return
	end

	gCameraUtils:DoRotateCameraByGamePad(4, self.rightStickValue.x, self.rightStickValue.y)
end

function M:OnClose()
	gPanelManager:PopPanelContext(gPanelId.S_CORE_HUD_PANEL, LTConfig.InputUIContextConfig.UIBoat)

	self.currVehicleData = nil
	self.showing = false
end

function M:OnActiveDeviceChange(device)
	self.gamePadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self:CreateAction("OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self:CreateAction("OnPhoneAppHide"),
		[gEventConstants.LOCK_DRIVE_MODE] = self:CreateAction("RefreshOutOfVehicleState")
	}
end

function M:RegisterWidget()
	self.bindData.viewBtn.luaClick = self:CreateAction("OnBtnView")
	self.bindData.outOfBoatBtn.luaLongPress = self:CreateAction("OnBtnOutOfBoat")
	self.bindData.outOfBoatBtn.luaClick = self:CreateAction("OnBtnOutOfBoat")
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
	self.bindData.cameraRotateRespond.luaGamePadInputChanged = self:CreateAction("OnCameraRotateRespondInputChanged")
	self.bindData.leftStickRespond.luaGamePadInputChanged = self:CreateAction("OnLeftStickRespondInputChanged")
	self.bindData.leftTriggerRespond.luaGamePadInputChanged = self:CreateAction("OnLeftTriggerRespondInputChanged")
	self.bindData.rightTriggerRespond.luaGamePadInputChanged = self:CreateAction("OnRightTriggerRespondInputChanged")
end

function M:OnCameraRotateRespondInputChanged(context)
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

function M:OnLeftStickRespondInputChanged(context)
	if context.started or context.performed then
		local val = context:ReadValueVector2()

		DriveManager:SetHorizontalAxisGamePad(val.x, val.y)
	end

	if context.canceled then
		DriveManager:SetHorizontalAxisGamePad(0, 0)
	end
end

function M:OnLeftTriggerRespondInputChanged(context)
	if context.started or context.performed then
		DriveManager:SetBackwardInputGamePad(context:ReadValueFloat())
	end

	if context.canceled then
		DriveManager:SetBackwardInputGamePad(0)
	end
end

function M:OnRightTriggerRespondInputChanged(context)
	if context.started or context.performed then
		DriveManager:SetForwardInputGamePad(context:ReadValueFloat())
	end

	if context.canceled then
		DriveManager:SetForwardInputGamePad(0)
	end
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
	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	self.bindData.PhoneAndDriveCtrl = self.IsPhoneMode and self.ControlType.True or self.ControlType.False

	self:SetBtnVisible(self.leftBtnStore, self.isMobile)
	self:SetBtnVisible(self.rightBtnStore, self.isMobile)
	self:SetBtnVisible(self.forwardBtnStore, self.isMobile)
	self:SetBtnVisible(self.backwardBtnStore, self.isMobile)
	self:SetBtnVisible(self.leftBtnPhoneStore, self.isMobile)
	self:SetBtnVisible(self.rightBtnPhoneStore, self.isMobile)
	self:SetBtnVisible(self.forwardBtnPhoneStore, self.isMobile)
	self:SetBtnVisible(self.backwardBtnPhoneStore, self.isMobile)
	self:SetBtnVisible(self.outOfBoatBtnStore, self.isMobile)
end

function M:RefreshOutOfVehicleState(eventId, lock)
	if not self.showing or not self.started then
		return
	end

	local vehicle = self.currVehicleData.vehicleCs

	if vehicle then
		self:SetBtnActive(self.bindData.outOfBoatBtn, not vehicle:IsSeatLockLeave(gDriveVehiclesManager.cs_manager.CurDriveSeatIndex))
	end
end

function M:OnBtnForward(isDown)
	DriveManager:ForwardThrottleButtonHandle(isDown)
end

function M:OnBtnBackward(isDown)
	DriveManager:BackwardThrottleButtonHandle(isDown)
end

function M:OnBtnLeft(isDown)
	DriveManager:LeftSteerButtonHandle(isDown)
end

function M:OnBtnRight(isDown)
	DriveManager:RightSteerButtonHandle(isDown)
end

function M:OnBtnOutOfBoat()
	gDriveVehiclesManager:OnEnterExitKeyDown()
end

function M:SetBtnVisible(btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
end

function M:SetBtnInteractable(btnStore, interactable)
	gStoreButtonMgr:SetButtonInteractableBase(btnStore, interactable)
end

function M:SetBtnControl(btnStore, visible, interactable)
	gStoreButtonMgr:SetButtonControlBase(btnStore, visible, interactable)
end

function M:SetBtnActive(btn, active)
	btn:SetActive(active)
end
