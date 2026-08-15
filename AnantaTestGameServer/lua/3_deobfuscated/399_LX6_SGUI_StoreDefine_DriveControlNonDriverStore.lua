local HudDescConfig = LTConfig.HudDescConfig
local DriveManager = gCS.DriveManager
local VehiclePart = LX6.Drive.DriveManager.E_VehicleButtonControlPart
C_DriveControlNonDriverStore = DefClass("C_DriveControlNonDriverStore", C_DriveControlNonDriverStore, C_StoreGroup)
GroupName2Class.DriveControlNonDriverStore = C_DriveControlNonDriverStore
local M = C_DriveControlNonDriverStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.needUpdate = false
	self.gamepadMode = false
	self.isXinShouRaid = false
	self.IsPhoneMode = false
	self.rightStickValue = {
		x = 0,
		y = 0
	}
	self.gamepadUpdateRotate = false
	self.IsConvertibleValid = false
end

function M:GetInstRefByPath(path)
	local inst = self.bindData[path]

	if not inst then
		return nil
	end

	return inst
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnStart()
	self.started = true

	self:OnEnterVehicleFinish(self.currVehicleData)
end

function M:OnDestroy()
	self.started = nil
end

function M:OnGroupEnable()
	self.outOfCarBtnStore = self:GetStoreByWidget(self.bindData.outOfCarBtn)
	self.convertibleBtnStore = self:GetStoreByWidget(self.bindData.convertibleBtn)
	self.outOfCarBtnStore.btnId = HudDescConfig.NON_DRIVER_OUT_OF_CAR_BTN
end

function M:OnGroupDisable()
	self.outOfCarBtnStore = nil

	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self.showing = true
	self.currVehicleData = data
	self.IsConvertibleValid = false

	if self.started and self.currVehicleData then
		self:OnEnterVehicleFinish(self.currVehicleData)
	end

	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

function M:OnClose()
	self.showing = false

	if self.currVehicleData then
		self:OnExitVehicleStart(self.currVehicleData)
	else
		print_warn("[CoreHudShootStore]OnClose: currVehicleData is null")
	end
end

function M:OnUpdate()
	if self.needUpdate and self.gamepadMode then
		self:UpdateCameraRotateGamePad()
	end
end

function M:UpdateCameraRotateGamePad()
	if not self.gamepadUpdateRotate then
		return
	end

	local csUnit = gCS.MyPlayerManager.PlayerUnit

	if gCS.ShootModule.GetVehicleShootState(csUnit) ~= LX6.Units.Module.ShootModule.VehicleShootState.None then
		gCameraUtils:DoRotateCameraByGamePad(6, self.rightStickValue.x, self.rightStickValue.y)
	else
		gCameraUtils:DoRotateCameraByGamePad(4, self.rightStickValue.x, self.rightStickValue.y)
	end
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.LOCK_DRIVE_MODE] = self:CreateAction("RefreshOutOfVehicleState"),
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self:CreateAction("OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self:CreateAction("OnPhoneAppHide"),
		[gEventConstants.VEHICLE_BUTTON_CONTROL_PART_STATE_CHANGE] = self:CreateAction("RefreshConvertibleTip")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:RegisterWidget()
	self.bindData.outOfCarBtn.luaLongPress = self:CreateAction("OnBtnOutOfCar")
	self.bindData.outOfCarBtn.luaClick = self:CreateAction("OnBtnOutOfCar")
	self.bindData.convertibleBtn.luaClick = self:CreateAction("OnBtnConvertible")
	self.bindData.cameraRotateRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")
	self.started = false
end

function M:OnBtnOutOfCar()
	gDriveVehiclesManager:OnEnterExitKeyDown()
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
		local csUnit = gCS.MyPlayerManager.PlayerUnit

		if gCS.ShootModule.GetIsInVehicleShootState(csUnit) or gCS.ShootModule.GetIsInVehicleForwardShootState(csUnit) then
			gCameraUtils:DoRotateCameraByGamePad(6, 0, 0)
		else
			gCameraUtils:DoRotateCameraByGamePad(4, 0, 0)
		end
	end
end

function M:OnBtnConvertible()
	DriveManager:PlayPartAnim(VehiclePart.Convertible)
end

function M:OnEnterVehicleFinish(vehicleId)
	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())

	self.needUpdate = true
	self.isXinShouRaid = gUIUtils:IsInXinShouRaid()
	self.IsPhoneMode = gClientUtils.CheckMainPhoneIsShowing()
	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	self.IsConvertibleValid = DriveManager:ContainsPart(VehiclePart.Convertible)

	self:RefreshButtonState()
end

function M:OnExitVehicleStart(vehicleId)
	self.needUpdate = false
	self.rightStickValue.x = 0
	self.rightStickValue.y = 0
	self.currVehicleData = nil
end

function M:RefreshButtonState()
	if not self.showing or not self.started then
		return
	end

	self:RefreshOutOfVehicleState()
	self:RefreshConvertibleState()
	self:RefreshTipShowPhone()
	self:RefreshConvertibleTip()
end

function M:OnPhoneAppShow()
	self:EnterPhoneMode()
end

function M:OnPhoneAppHide()
	self:ExitPhoneMode()
end

function M:EnterPhoneMode()
	self.IsPhoneMode = true

	if self.showing and self.started then
		self:RefreshButtonState()
	end
end

function M:ExitPhoneMode()
	self.IsPhoneMode = false

	if self.showing and self.started then
		self:RefreshButtonState()
	end
end

function M:RefreshTipShowPhone()
	self.bindData.navArea:ChangeButtonShowTipByRespond(self.bindData.outOfCarBtn, not self.IsPhoneMode)
	self.bindData.outOfCarBtn:SetPCKeyTipShowTip(not self.IsPhoneMode)
end

function M:RefreshOutOfVehicleState(eventId, lock)
	if not self.showing or not self.started then
		return
	end

	self:SetBtnVisible(self.outOfCarBtnStore, not self.IsPhoneMode and self.isMobile)

	local vehicle = self.currVehicleData.vehicleCs

	if vehicle then
		self:SetBtnActive(self.bindData.outOfCarBtn, not vehicle:IsSeatLockLeave(gDriveVehiclesManager.cs_manager.CurDriveSeatIndex))
	end
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

function M:RefreshConvertibleState()
	if not self.showing then
		return
	end

	self:SetBtnActive(self.bindData.convertibleBtn, self.IsConvertibleValid and not self.IsPhoneMode)
	self:SetBtnVisible(self.convertibleBtnStore, self.IsConvertibleValid and not self.IsPhoneMode and self.isMobile)
end

function M:RefreshConvertibleTip()
	if not self.showing or not self.IsConvertibleValid then
		return
	end

	local id = DriveManager:GetPartStateInputId(VehiclePart.Convertible)
	local cfg = LTConfig.InputButtonNameConfig.GetConfig(id)

	if not cfg then
		print_error("GetPartStateInputId fail, buttonControlPart=", VehiclePart.Convertible, "InputId=", id)
	end

	self.bindData.convertibleBtn:SetPCKeyInfoTipNameId(id)

	self.convertibleBtnStore.notifyWord = cfg and cfg.Name or ""

	self.bindData.navArea:SetButtonInfoTipNameId(id, 3)
end
