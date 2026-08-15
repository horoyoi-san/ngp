C_HackAutoDrivingHUDPanelStore = DefClass("C_HackAutoDrivingHUDPanelStore", C_HackAutoDrivingHUDPanelStore, C_StoreGroup)
GroupName2Class.HackAutoDrivingHUDPanelStore = C_HackAutoDrivingHUDPanelStore
local M = C_HackAutoDrivingHUDPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.AutoDrive = {
		IsAutoDriving = false,
		TargetEnable = false,
		AskWait = false,
		TargetPos = Vector3.New(0, 0, 0)
	}
	self.rightStickValue = {
		x = 0,
		y = 0
	}
	self.gamepadUpdateRotate = false
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	self.started = true

	self:RefreshAutoDriveState()
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self.started = false
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)

	self.autoDriveBtnStore = self:GetStoreByWidget(self.bindData.autoDriveBtn)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self.showing = true
	self.IsPhoneMode = gClientUtils.CheckMainPhoneIsShowing()
	self.AutoDrive.TargetEnable, self.AutoDrive.TargetPos = LX6.Gps.MapSystem.Instance:TryGetVehicleNavTargetPosition(self.AutoDrive.TargetPos)

	self:RefreshAutoDriveState()
	self:SetAutoDriving(false)
end

function M:OnClose()
	self.showing = false
end

function M:OnUpdate()
	self:UpdateCameraRotateGamePad()
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.VEHICLE_NAV_TARGET_STATE_CHANGE] = self:CreateAction("OnVehicleNavTargetChange"),
		[gEventConstants.ON_VEHICLE_TASK_DELETE] = self:CreateAction("OnVehicleTaskDeleteChange"),
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self:CreateAction("OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self:CreateAction("OnPhoneAppHide")
	}
end

function M:RegisterWidget()
	self.bindData.autoDriveBtn.luaClick = self:CreateAction("OnClickAutoDriveBtn")
	self.bindData.rightStickRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")
end

function M:OnClickAutoDriveBtn()
	if self.AutoDrive.IsAutoDriving then
		gClientToGameSceneDelegate:AskVehicleStopHackerAutonomousDriving()
	elseif self.AutoDrive.TargetEnable and not self.AutoDrive.AskWait then
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

	self:SetBtnActive(self.bindData.autoDriveBtn, not self.IsPhoneMode and self.AutoDrive.TargetEnable)
	self:SetBtnVisible(self.autoDriveBtnStore, not self.IsPhoneMode and self.AutoDrive.TargetEnable)
end

function M:SetAutoDriving(driving, token)
	self.AutoDrive.IsAutoDriving = driving
	self.AutoDrive.Token = token
	self.AutoDrive.AskWait = false

	self.bindData.autoDriveBtn:SetSelected(driving)
	self.bindData.autoDriveBtn:SetPCKeyInfoTipNameId(driving and 576 or 575)
	self.bindData.navArea:SetButtonInfoTipNameId(driving and 576 or 575, 0)
end

function M:OnVehicleNavTargetChange(eventId, hasTarget)
	self.AutoDrive.TargetEnable, self.AutoDrive.TargetPos = LX6.Gps.MapSystem.Instance:TryGetVehicleNavTargetPosition(self.AutoDrive.TargetPos)

	self:RefreshAutoDriveState()

	if self.IsAutoDriving and not self.AutoDrive.TargetEnable then
		gClientToGameSceneDelegate:AskVehicleStopHackerAutonomousDriving()
	end
end

function M:OnVehicleTaskDeleteChange(eventId, token)
	if self.AutoDrive.IsAutoDriving and self.AutoDrive.Token == token then
		self:SetAutoDriving(false)
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

	self:RefreshAutoDriveState()
end

function M:ExitPhoneMode()
	self.IsPhoneMode = false

	self:RefreshAutoDriveState()
end

function M:SetBtnActive(btn, active)
	btn:SetActive(active)
end

function M:SetBtnVisible(btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
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

function M:UpdateCameraRotateGamePad()
	if not self.gamepadUpdateRotate then
		return
	end

	gCameraUtils:DoRotateCameraByGamePad(4, self.rightStickValue.x, self.rightStickValue.y)
end
