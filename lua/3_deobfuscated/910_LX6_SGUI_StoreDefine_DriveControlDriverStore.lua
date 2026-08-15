local DriveManager = gCS.DriveManager
local BuffConfig = LTConfig.BuffConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local HudDescConfig = LTConfig.HudDescConfig
local VehiclePart = LX6.Drive.DriveManager.E_VehicleButtonControlPart
local bit = require("bit")
local ControlType = {
	False = 0,
	True = 1
}
local ArrowType = {
	Right = 2,
	Left = 1,
	None = 0
}
C_DriveControlDriverStore = DefClass("C_DriveControlDriverStore", C_DriveControlDriverStore, C_StoreGroup)
GroupName2Class.DriveControlDriverStore = C_DriveControlDriverStore
local M = C_DriveControlDriverStore

function M:ctor()
	self.spoonHideReset = false
end

function M:DefineAllVariables()
	self.needUpdate = false
	self.forwardDown = false
	self.backwardDown = false
	self.leftDown = false
	self.rightDown = false
	self.gamepadMode = false
	self.isXinShouRaid = false
	self.IsPhoneMode = false
	self.rightStickValue = {
		x = 0,
		y = 0
	}
	self.gamepadUpdateRotate = false
	self.IsResetValid = true
	self.IsConvertibleValid = false
	self.IsStartDriving = false
	self.mobileJoystickOperation = false
	self.AutoDrive = {
		AskWait = false,
		FlagEnable = false,
		TargetEnable = false,
		IsAutoDriving = false,
		TargetPos = Vector3.New(0, 0, 0)
	}
	self.btnDownFanseAni = "s_vx_HudSkillbtn_fanse"
	self.btnUpFanseAni = "s_vx_HudSkillbtn_fanse_up"
	self.skillReady = false
	self.enableProfessionSkill = false
	self.professionSkillBtnTimes = 0
	self.maxProfessionSkillBtnTimes = 0
	self.needUpdateProfessionSkillBtnCD = false
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
	self.forwardBtnStore = self:GetStoreByWidget(self.bindData.forwardBtn)
	self.backwardBtnStore = self:GetStoreByWidget(self.bindData.backwardBtn)
	self.leftBtnStore = self:GetStoreByWidget(self.bindData.leftBtn)
	self.rightBtnStore = self:GetStoreByWidget(self.bindData.rightBtn)
	self.forwardBtnPhoneStore = self:GetStoreByWidget(self.bindData.forwardBtnPhone)
	self.backwardBtnPhoneStore = self:GetStoreByWidget(self.bindData.backwardBtnPhone)
	self.leftBtnPhoneStore = self:GetStoreByWidget(self.bindData.leftBtnPhone)
	self.rightBtnPhoneStore = self:GetStoreByWidget(self.bindData.rightBtnPhone)
	self.driftBtnStore = self:GetStoreByWidget(self.bindData.driftBtn)
	self.outOfCarBtnStore = self:GetStoreByWidget(self.bindData.outOfCarBtn)
	self.outOfFreezeBtnStore = self:GetStoreByWidget(self.bindData.outOfFreezeBtn)
	self.ringBellBtnStore = self:GetStoreByWidget(self.bindData.ringBellBtn)
	self.professionSkillBtnStore = self:GetStoreByWidget(self.bindData.professionSkillBtn)
	self.professionSkillBtnMobileStore = self:GetStoreByWidget(self.bindData.professionSkillBtnMobile)
	self.viewBtnStore = self:GetStoreByWidget(self.bindData.viewBtn)
	self.convertibleBtnStore = self:GetStoreByWidget(self.bindData.convertibleBtn)
	self.hornBtnStore = self:GetStoreByWidget(self.bindData.hornBtn)
	self.autoDriveBtnStore = self:GetStoreByWidget(self.bindData.autoDriveBtn)
	self.forwardBtnStore.btnId = HudDescConfig.FORWARD_BTN
	self.backwardBtnStore.btnId = HudDescConfig.BACKWARD_BTN
	self.leftBtnStore.btnId = HudDescConfig.LEFT_BTN
	self.rightBtnStore.btnId = HudDescConfig.RIGHT_BTN
	self.driftBtnStore.btnId = HudDescConfig.DRIFT_BTN
	self.outOfCarBtnStore.btnId = HudDescConfig.DRIVER_OUT_OF_CAR_BTN
	self.outOfFreezeBtnStore.btnId = HudDescConfig.OUT_OF_FREEZE_BTN
	self.ringBellBtnStore.btnId = HudDescConfig.RING_BELL_BTN
	self.professionSkillBtnStore.btnId = HudDescConfig.PROFESSION_SKILL_BTN
	self.professionSkillBtnMobileStore.btnId = HudDescConfig.PROFESSION_SKILL_BTN_MOBILE
	self.viewBtnStore.btnId = HudDescConfig.DRIVER_VIEW_BTN
	self.forwardBtnPhoneStore.btnId = HudDescConfig.FORWARD_BTN_PHONE
	self.backwardBtnPhoneStore.btnId = HudDescConfig.BACKWARD_BTN_PHONE
	self.leftBtnPhoneStore.btnId = HudDescConfig.LEFT_BTN_PHONE
	self.rightBtnPhoneStore.btnId = HudDescConfig.RIGHT_BTN_PHONE

	gStoreButtonMgr:SetButtonEnterBarBsae(self.outOfFreezeBtnStore, false)
end

function M:OnGroupDisable()
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

		self.currVehicleData = nil
	else
		print_warn("[CoreHudShootStore]OnClose: currVehicleId is null")
	end
end

function M:OnUpdate()
	if self.needUpdate then
		if self.gamepadMode then
			self:UpdateCameraRotateGamePad()
		end

		if self.enableProfessionSkill then
			self:UpdateProfessionSkillBtnCD()
		end
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
		[gEventConstants.NOTIFY_CHANGE_SKILL_RESOURCE] = self:CreateAction("OnSkillResourceChanged"),
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self:CreateAction("OnSystemUnlock"),
		[gEventConstants.VEHICLE_RESET_STATE_CHANGED] = self:CreateAction("OnResetChange"),
		[gEventConstants.VEHICLE_BUTTON_CONTROL_PART_STATE_CHANGE] = self:CreateAction("RefreshConvertibleTip"),
		[gEventConstants.VEHICLE_START_DRIVING_STATE_CHANGED] = self:CreateAction("RefreshTriggerFeedback"),
		[gEventConstants.SETTING_SEND_VEHICLE_MODE] = self:CreateAction("OnVehicleControlModeChange"),
		[gEventConstants.VEHICLE_NAV_TARGET_STATE_CHANGE] = self:CreateAction("OnVehicleNavTargetChange"),
		[gEventConstants.ON_VEHICLE_TASK_DELETE] = self:CreateAction("OnVehicleTaskDeleteChange")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:RegisterWidget()
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
	self.bindData.driftBtn.luaPress = self:CreateActionWithArgs("OnBtnDrift", true)
	self.bindData.driftBtn.luaRelease = self:CreateActionWithArgs("OnBtnDrift", false)
	self.bindData.outOfCarBtn.luaLongPress = self:CreateAction("OnBtnOutOfCar")
	self.bindData.outOfCarBtn.luaClick = self:CreateAction("OnBtnOutOfCar")
	self.bindData.outOfFreezeBtn.luaPress = self:CreateAction("OnBtnOutOfFreeze")
	self.bindData.ringBellBtn.luaPress = self:CreateActionWithArgs("OnBtnRingBell", true)
	self.bindData.ringBellBtn.luaRelease = self:CreateActionWithArgs("OnBtnRingBell", false)
	self.bindData.cameraRotateRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")
	self.bindData.leftStickRespond.luaGamePadInputChanged = self:CreateAction("OnLeftStickControl")
	self.bindData.leftTriggerRespond.luaGamePadInputChanged = self:CreateAction("OnLeftTriggerControl")
	self.bindData.rightTriggerRespond.luaGamePadInputChanged = self:CreateAction("OnRightTriggerControl")
	self.bindData.professionSkillBtn.luaPress = self:CreateAction("OnBtnProfessionSkillDown")
	self.bindData.professionSkillBtn.luaRelease = self:CreateAction("OnBtnProfessionSkillUp")
	self.bindData.professionSkillBtnMobile.luaPress = self:CreateAction("OnBtnProfessionSkillDown")
	self.bindData.professionSkillBtnMobile.luaRelease = self:CreateAction("OnBtnProfessionSkillUp")
	self.bindData.viewBtn.luaClick = self:CreateAction("OnBtnView")
	self.bindData.convertibleBtn.luaClick = self:CreateAction("OnBtnConvertible")
	self.bindData.hornBtn.luaPress = self:CreateAction("OnBtnHornPress")
	self.bindData.hornBtn.luaRelease = self:CreateAction("OnBtnHornRelease")
	self.bindData.joystick.luaValueChanged = self:CreateAction("OnJoystickMove")
	self.bindData.autoDriveBtn.luaClick = self:CreateAction("OnBtnAutoDrive")
	self.started = false
end

function M:OnEnterVehicleFinish(vehicleIData)
	gPanelManager:PushPanelContext(gPanelId.S_CORE_HUD_PANEL, LTConfig.InputUIContextConfig.UIDriveVehicle)
	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())

	self.enableProfessionSkill = self:ShowProfessionSkillButton()
	self.skillReady = true

	self:UpdateBtn_MultiUseBtn(self.professionSkillBtnStore, false, 0, 0, 0, 0)
	self:UpdateBtn_MultiUseBtn(self.professionSkillBtnMobileStore, false, 0, 0, 0, 0)

	self.needUpdate = true
	self.isXinShouRaid = gUIUtils:IsInXinShouRaid()
	self.IsPhoneMode = gClientUtils.CheckMainPhoneIsShowing()
	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	self.mobileJoystickOperation = LX6.Engine.ProfileManager.gameProfile.isVehicleJoystickMode
	self.bindData.OperationModeCtrl = self.isMobile and self.mobileJoystickOperation and ControlType.True or ControlType.False
	self.IsResetValid = vehicleIData.vehicleCs.IsResetValid
	self.IsConvertibleValid = DriveManager:ContainsPart(VehiclePart.Convertible)
	local cfg = LTConfig.VehicleConfig.GetConfig(vehicleIData.vehicleCs.cfgId)
	self.AutoDrive.FlagEnable = bit.band(cfg.VehicleFlag, LTConfig.VehicleConfig.VehicleFlagType.AutoDrive) == LTConfig.VehicleConfig.VehicleFlagType.AutoDrive
	self.AutoDrive.TargetEnable, self.AutoDrive.TargetPos = LX6.Gps.MapSystem.Instance:TryGetVehicleNavTargetPosition(self.AutoDrive.TargetPos)

	self:SetAutoDriving(false)
	self:RefreshButtonState()

	local vehicleType = cfg and cfg.VehicleType or ""
	self.vehicleTypeCfg = gDriveVehiclesManager:GetVehicleTypeConfig(vehicleType)

	self:RefreshTriggerFeedback()
	self.bindData.speedScoreComp:SetActive(not self.isXinShouRaid)
end

function M:OnExitVehicleStart(vehicleId)
	gPanelManager:PopPanelContext(gPanelId.S_CORE_HUD_PANEL, LTConfig.InputUIContextConfig.UIDriveVehicle)

	self.needUpdate = false
	self.IsMainDrive = false
	self.forwardDown = false
	self.backwardDown = false
	self.leftDown = false
	self.rightDown = false
	self.vehicleType = nil
	self.rightStickValue.x = 0
	self.rightStickValue.y = 0
	self.currVehicleData = nil
end

function M:UpdateDashboard()
	local vehicle = gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle

	if not vehicle then
		return
	end

	local speed = math.abs(vehicle.Speed) * 3.6
	local maxSpeed = vehicle.MaxSpeed * 3.6
	speed = math.min(math.floor(speed + 0.5), maxSpeed)
	speed = math.floor(speed + 0.5)

	if speed < 10 then
		speed = "0" .. speed
	end

	self.bindData.speed = speed
	local currentGear = vehicle.CurrentGear
	local showLevel = currentGear + 1

	if currentGear < 0 then
		showLevel = "R"
	elseif vehicle.IsVehicleStopped then
		showLevel = "P"
	end

	self.bindData.gearLevel = showLevel
	local percent = vehicle.CurrentRPM / vehicle.MaxRPM
	self.bindData.speedFill = percent * 0.75
	self.bindData.pointerFill = percent
	self.bindData.bloodFill = vehicle.CurrentHp / vehicle.MaxHp
	local arrow = ArrowType.None

	if vehicle.IsTurnLeft then
		arrow = ArrowType.Left
	elseif vehicle.IsTurnRight then
		arrow = ArrowType.Right
	end

	self.bindData.arrowCtrl = arrow
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

function M:OnBtnForward(isDown)
	DriveManager:ForwardThrottleButtonHandle(isDown)

	if isDown then
		self:TryStopAutoDriving()
	end
end

function M:OnBtnBackward(isDown)
	DriveManager:BackwardThrottleButtonHandle(isDown)

	if isDown then
		self:TryStopAutoDriving()
	end
end

function M:OnBtnLeft(isDown)
	DriveManager:LeftSteerButtonHandle(isDown)

	if isDown then
		self:TryStopAutoDriving()
	end
end

function M:OnBtnRight(isDown)
	DriveManager:RightSteerButtonHandle(isDown)

	if isDown then
		self:TryStopAutoDriving()
	end
end

function M:OnBtnDrift(isDown)
	gCS.DriveManager:HandBrakeButtonHandle(isDown)

	if isDown then
		self:TryStopAutoDriving()
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
		local csUnit = gCS.MyPlayerManager.PlayerUnit

		if gCS.ShootModule.GetIsInVehicleShootState(csUnit) or gCS.ShootModule.GetIsInVehicleForwardShootState(csUnit) then
			gCameraUtils:DoRotateCameraByGamePad(6, 0, 0)
		else
			gCameraUtils:DoRotateCameraByGamePad(4, 0, 0)
		end
	end
end

function M:OnLeftStickControl(context)
	if context.started or context.performed then
		local val = context:ReadValueVector2()

		DriveManager:SetHorizontalAxisGamePad(val.x, val.y)
		self:TryStopAutoDriving()
	end

	if context.canceled then
		DriveManager:SetHorizontalAxisGamePad(0, 0)
	end
end

function M:OnLeftTriggerControl(context)
	if context.started or context.performed then
		DriveManager:SetBackwardInputGamePad(context:ReadValueFloat())
		self:TryStopAutoDriving()
	end

	if context.canceled then
		DriveManager:SetBackwardInputGamePad(0)
	end
end

function M:OnRightTriggerControl(context)
	if context.started or context.performed then
		DriveManager:SetForwardInputGamePad(context:ReadValueFloat())
		self:TryStopAutoDriving()
	end

	if context.canceled then
		DriveManager:SetForwardInputGamePad(0)
	end
end

function M:OnJoystickMove(nx, ny, size)
	DriveManager:SetInputMobileGamePad(nx * size, ny * size)
	self:TryStopAutoDriving()
end

function M:OnBtnOutOfCar()
	gDriveVehiclesManager:OnEnterExitKeyDown()
end

function M:OnBtnOutOfFreeze()
	gDriveVehiclesManager.cs_manager:ResetMyVehicle()
end

function M:OnBtnProfessionSkillDown()
	if gCS.MyPlayerManager.PlayerUnit then
		gCS.LuaUtils.PlayAnimationByName(self.professionSkillBtnStore.btnFanseAni, self.btnDownFanseAni)
		gCS.LuaUtils.PlayAnimationByName(self.professionSkillBtnMobileStore.btnFanseAni, self.btnDownFanseAni)
		gBattleMgr:ClickProfessionSkill()
	end
end

function M:OnBtnProfessionSkillUp()
	if gCS.MyPlayerManager.PlayerUnit then
		gCS.LuaUtils.PlayAnimationByName(self.professionSkillBtnStore.btnFanseAni, self.btnUpFanseAni)
		gCS.LuaUtils.PlayAnimationByName(self.professionSkillBtnMobileStore.btnFanseAni, self.btnUpFanseAni)
	end
end

function M:OnBtnView()
	local val = LX6.Cinemachine.NPDVehicleCameraState.armLengthPreference
	val = val + 1

	if val > 3 then
		val = 1
	end

	LX6.Cinemachine.NPDVehicleCameraState.armLengthPreference = val
end

function M:OnBtnConvertible()
	DriveManager:PlayPartAnim(VehiclePart.Convertible)
end

function M:ShowDriveScore(show)
	return
end

function M:ShowDriveSpeed(show)
	return
end

function M:OnDriveScoreChange(data)
	return
end

function M:ShowProfessionSkillButton()
	return gCS.MyPlayerManager.PlayerUnit and gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, BuffConfig.TimeScaleBadgeBuff)
end

function M:OnSkillResourceChanged(eventId, data)
	local templateId = data[0]

	if templateId == LTConfig.SkillResourcesConfig.DriveTimeScaleEnergy then
		self.professionSkillBtnTimes = data[1]
		self.maxProfessionSkillBtnTimes = data[2]
		self.needUpdateProfessionSkillBtnCD = true

		if self.STATE_EnableOnce then
			self:UpdateProfessionSkillBtnCD()
		end
	end
end

function M:UpdateProfessionSkillBtnCD(force)
	if not self.needUpdateProfessionSkillBtnCD and not force then
		return
	end

	local isShowCD = self.professionSkillBtnTimes < self.maxProfessionSkillBtnTimes

	self:SetProfessionSkillReady(self.professionSkillBtnTimes >= 1)

	local curCharge = math.floor(self.professionSkillBtnTimes)
	local cfg = LTConfig.SkillResourcesConfig.GetConfig(LTConfig.SkillResourcesConfig.DriveTimeScaleEnergy)
	local fill = 1 - self.professionSkillBtnTimes % 1
	local labelTimeLeft = fill * cfg.Interval

	self:UpdateBtn_MultiUseBtn(self.professionSkillBtnStore, isShowCD, curCharge, self.maxProfessionSkillBtnTimes, fill, labelTimeLeft)
	self:UpdateBtn_MultiUseBtn(self.professionSkillBtnMobileStore, isShowCD, curCharge, self.maxProfessionSkillBtnTimes, fill, labelTimeLeft)

	if self.professionSkillBtnTimes == self.maxProfessionSkillBtnTimes then
		self.needUpdateProfessionSkillBtnCD = false
	end
end

function M:SetProfessionSkillReady(enable)
	if self.skillReady ~= enable then
		self.skillReady = enable

		self:RefreshProfessionSkillBtn(not self.isXinShouRaid and not self.IsPhoneMode)
	end
end

function M:RefreshProfessionSkillBtn(active)
	self:SetBtnInteractable(self.professionSkillBtnStore, active and self.enableProfessionSkill and self.skillReady)
	self:SetBtnInteractable(self.professionSkillBtnMobileStore, active and self.enableProfessionSkill and self.skillReady)

	if active then
		gCS.LuaUtils.SetToLastFrame(self.professionSkillBtnStore.btnFanseAni, self.btnUpFanseAni)
		gCS.LuaUtils.SetToLastFrame(self.professionSkillBtnMobileStore.btnFanseAni, self.btnUpFanseAni)
	end
end

function M:UpdateBtn_MultiUseBtn(btn, isShowCD, curCharges, maxCharges, fillAmount, labelTimeLeft)
	if maxCharges > 1 then
		btn.skillTypeCtrl = 2

		if isShowCD then
			if curCharges == 0 then
				btn.btnInCDCtrl = 1
				btn.multiChrageCDCtrl = 0
				btn.cdTime = labelTimeLeft >= 1 and math.ceil(labelTimeLeft) or gString.Format("%.1f", labelTimeLeft)
				btn.cdCover = gBattleMgr.useV1hud and not self.isMobile and fillAmount or 1 - fillAmount
			else
				btn.btnInCDCtrl = 0
				btn.multiChrageCDCtrl = 2
				btn.multiChargeCounts = curCharges
				btn.multiChargeCd = 1 - fillAmount
			end
		else
			btn.btnInCDCtrl = 0
			btn.multiChrageCDCtrl = 1
			btn.multiChargeCounts = curCharges
			btn.multiChargeReaCounts = curCharges
			btn.multiChargeCd = 1 - fillAmount
		end
	else
		btn.skillTypeCtrl = 0
		btn.btnInCDCtrl = isShowCD and 1 or 0
		btn.cdTime = labelTimeLeft >= 1 and math.ceil(labelTimeLeft) or gString.Format("%.1f", labelTimeLeft)
		btn.cdCover = gBattleMgr.useV1hud and not self.isMobile and fillAmount or 1 - fillAmount
	end
end

function M:RefreshButtonState()
	if not self.showing or not self.started then
		return
	end

	local active = not self.isXinShouRaid and not self.IsPhoneMode

	self:RefreshOutOfVehicleState()
	self:RefreshCarViewState()
	self:RefreshResetState()
	self:RefreshConvertibleState()
	self:RefreshAutoDriveState()
	self:SetBtnActive(self.bindData.ringBellBtn, active)
	self:SetBtnActive(self.bindData.professionSkillBtn, active and self.enableProfessionSkill)
	self:SetBtnActive(self.bindData.professionSkillBtnMobile, active and self.enableProfessionSkill)
	self:SetBtnActive(self.bindData.hornBtn, active)
	self:SetBtnVisible(self.ringBellBtnStore, self.isMobile)
	self:SetBtnInteractable(self.professionSkillBtnStore, active and self.enableProfessionSkill and self.skillReady)
	self:SetBtnInteractable(self.professionSkillBtnMobileStore, active and self.enableProfessionSkill and self.skillReady)

	self.bindData.PhoneOpenCtrl = self.IsPhoneMode and ControlType.True or ControlType.False

	self:SetBtnActive(self.bindData.driftBtn, active)
	self:SetBtnVisible(self.driftBtnStore, self.isMobile)
	self:SetBtnVisible(self.hornBtnStore, self.isMobile)
	self:RefreshTipShowPhone()
	self:RefreshConvertibleTip()
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

function M:OnSystemUnlock(eventId, id)
	if not self.showing or not self.started then
		return
	end

	if id == SystemUnlockConfig.CarView then
		self:RefreshCarViewState()
	end
end

function M:RefreshCarViewState()
	if not self.showing or not self.started then
		return
	end

	local unlock = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.CarView)

	self:SetBtnActive(self.bindData.viewBtn, unlock and not self.IsPhoneMode)
	self:SetBtnVisible(self.viewBtnStore, unlock and not self.IsPhoneMode)
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

function M:OnSpoonHideReset(hide)
	self.spoonHideReset = hide

	self:RefreshResetState()
	print_notice("[Reset]DriveControlDriverStore OnSpoonHideReset", hide)
end

function M:RefreshResetState()
	if not self.showing or not self.started then
		return
	end

	self:SetBtnVisible(self.outOfFreezeBtnStore, self.isMobile and self.IsResetValid)
	self:SetBtnActive(self.bindData.outOfFreezeBtn, not self.IsPhoneMode and not self.spoonHideReset and self.IsResetValid)
	self:SetBtnActive(self.bindData.resetPcIcon, not self.IsPhoneMode and not self.spoonHideReset and self.IsResetValid)
end

function M:OnResetChange(eventId, data)
	self.IsResetValid = data

	print_notice("[Reset]DriveControlDriverStore OnResetChange", data)
	self:RefreshResetState()
end

function M:RefreshConvertibleState()
	if not self.showing or not self.started then
		return
	end

	self:SetBtnActive(self.bindData.convertibleBtn, self.IsConvertibleValid and not self.IsPhoneMode)
	self:SetBtnVisible(self.convertibleBtnStore, self.IsConvertibleValid and not self.IsPhoneMode and self.isMobile)
end

function M:RefreshConvertibleTip()
	if not self.showing or not self.started or not self.IsConvertibleValid then
		return
	end

	local id = DriveManager:GetPartStateInputId(VehiclePart.Convertible)
	local cfg = LTConfig.InputButtonNameConfig.GetConfig(id)

	if not cfg then
		print_error("GetPartStateInputId fail, buttonControlPart=", VehiclePart.Convertible, "InputId=", id)
	end

	self.bindData.convertibleBtn:SetPCKeyInfoTipNameId(id)

	self.convertibleBtnStore.notifyWord = cfg and cfg.Name or ""

	self.bindData.navArea:SetButtonInfoTipNameId(id, 9)
end

function M:OnBtnHornPress()
	local baseVehicle = self.currVehicleData.vehicleCs

	if not baseVehicle then
		return
	end

	baseVehicle:PlayHorn()
	print_notice("OnBtnHornPress PlayPlayerManualHornSound", self.currVehicleData.vehicleId)
end

function M:OnBtnHornRelease()
	local baseVehicle = self.currVehicleData.vehicleCs

	if not baseVehicle then
		return
	end

	baseVehicle:StopHorn()
	print_notice("OnBtnHornRelease StopPlayerManualHornSound", self.currVehicleData.vehicleId)
end

function M:OnBtnAutoDrive()
	if self.AutoDrive.IsAutoDriving then
		gClientToGameSceneDelegate:AskVehicleStopHackerAutonomousDriving()
	elseif self.AutoDrive.TargetEnable and self.AutoDrive.FlagEnable and not self.AutoDrive.AskWait then
		self.AutoDrive.AskWait = true

		gClientToGameSceneDelegate:AskVehicleStartHackerAutonomousDriving(UX.Game.UXVector3.New(self.AutoDrive.TargetPos.x, self.AutoDrive.TargetPos.y, self.AutoDrive.TargetPos.z)).Callback = function (err, token)
			self.AutoDrive.AskWait = false

			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			else
				self:SetAutoDriving(true, token)
				LX6.Drive.AI.VehicleMissionManager.Instance:RegisterTaskDeletedEvent(token)
			end
		end
	end
end

function M:RefreshAutoDriveState()
	if not self.showing or not self.started then
		return
	end

	self:SetBtnActive(self.bindData.autoDriveBtn, not self.IsPhoneMode and self.AutoDrive.FlagEnable and self.AutoDrive.TargetEnable)
	self:SetBtnVisible(self.autoDriveBtnStore, not self.IsPhoneMode and self.AutoDrive.FlagEnable and self.AutoDrive.TargetEnable)
end

function M:OnVehicleNavTargetChange(eventId, hasTarget)
	self.AutoDrive.TargetEnable, self.AutoDrive.TargetPos = LX6.Gps.MapSystem.Instance:TryGetVehicleNavTargetPosition(self.AutoDrive.TargetPos)

	self:RefreshAutoDriveState()

	if self.AutoDrive.IsAutoDriving and not self.AutoDrive.TargetEnable then
		gClientToGameSceneDelegate:AskVehicleStopHackerAutonomousDriving()
	end
end

function M:OnVehicleTaskDeleteChange(eventId, token)
	if self.AutoDrive.IsAutoDriving and self.AutoDrive.Token == token then
		self:SetAutoDriving(false)
	end
end

function M:SetAutoDriving(driving, token)
	if not self.showing or not self.started then
		return
	end

	self.AutoDrive.IsAutoDriving = driving
	self.AutoDrive.Token = token
	self.AutoDrive.AskWait = false

	self.bindData.autoDriveBtn:SetSelected(driving)
	self.bindData.autoDriveBtn:SetPCKeyInfoTipNameId(driving and 576 or 575)
	self.bindData.navArea:SetButtonInfoTipNameId(driving and 576 or 575, 11)
end

function M:TryStopAutoDriving()
	if self.AutoDrive.IsAutoDriving then
		gClientToGameSceneDelegate:AskVehicleStopHackerAutonomousDriving()
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
	self.bindData.navArea:ChangeButtonShowTipByCustomRespond(self.bindData.leftTriggerRespond, not self.IsPhoneMode)
	self.bindData.navArea:ChangeButtonShowTipByCustomRespond(self.bindData.rightTriggerRespond, not self.IsPhoneMode)
	self.bindData.outOfCarBtn:SetPCKeyTipShowTip(not self.IsPhoneMode)
end

function M:RefreshTriggerFeedback()
	if not self.started or not self.showing then
		return
	end

	self.IsStartDriving = self.currVehicleData.vehicleCs.IsStartDriving

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if self.vehicleTypeCfg then
		self.bindData.navArea:ChangeDualSenseByActionId(110, self.IsStartDriving and self.vehicleTypeCfg.InitialStopAdaptiveTrigger or self.vehicleTypeCfg.NonInitialStopAdaptiveTrigger)
		self.bindData.navArea:ChangeDualSenseByActionId(111, self.IsStartDriving and self.vehicleTypeCfg.InitialAdaptiveTrigger or self.vehicleTypeCfg.NonInitialAdaptiveTrigger)
	end
end

function M:OnVehicleControlModeChange(eventId, mode)
	if self.showing then
		self.mobileJoystickOperation = mode
		self.bindData.OperationModeCtrl = self.isMobile and self.mobileJoystickOperation and ControlType.True or ControlType.False
	end
end
