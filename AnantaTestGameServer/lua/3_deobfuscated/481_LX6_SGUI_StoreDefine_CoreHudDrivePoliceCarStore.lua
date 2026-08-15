local VehicleSoundMgr = LX6.Audio.VehicleSoundMgr
local ControlType = {
	False = 0,
	True = 1
}
C_CoreHudDrivePoliceCarStore = DefClass("C_CoreHudDrivePoliceCarStore", C_CoreHudDrivePoliceCarStore, C_StoreGroup)
GroupName2Class.CoreHudDrivePoliceCarStore = C_CoreHudDrivePoliceCarStore
local M = C_CoreHudDrivePoliceCarStore

function M:ctor()
	self.policeLightOn = false
	self.policeSirenOn = false
	self.currVehicleId = 0
end

function M:OnAwake()
	self.bindData.policeHornBtn.luaPress = self:CreateAction("OnPoliceBtnHornPress")
	self.bindData.policeHornBtn.luaRelease = self:CreateAction("OnPoliceBtnHornRelease")
	self.bindData.policeLightSwitchBtn.luaClick = self:CreateAction("OnPoliceBtnLightSwitch")
	self.bindData.policeSirenSwitchBtn.luaClick = self:CreateAction("OnPoliceBtnSirenSwitch")
	self.bindData.policeGuideTo.luaClick = self:CreateAction("OnPoliceGuideToBtnClick")
	self.bindData.policeSirenSwitchPad.luaLongPress = self:CreateAction("OnPoliceBtnSirenSwitch")
	self.started = false
end

function M:OnDestroy()
	self.started = nil
end

function M:OnGroupEnable()
	self.policeLightSwitchBtnStore = self:GetStoreByWidget(self.bindData.policeLightSwitchBtn)
	self.policeSirenSwitchBtnStore = self:GetStoreByWidget(self.bindData.policeSirenSwitchBtn)
	self.policeHornBtnStore = self:GetStoreByWidget(self.bindData.policeHornBtn)
end

function M:OnShow(panelId, data, widget, IsMainDrive, IsPhoneMode)
	self.currVehicleId = data.vehicleId
	self.IsPhoneMode = IsPhoneMode
	self.IsMainDrive = IsMainDrive

	self:InitPoliceStyle()

	if self.started then
		self:RefreshButtonState()
	end

	if self.bindData.policeHornBtn then
		self.bindData.policeHornBtn.interactable = true
	end
end

function M:OnStart()
	self.started = true

	self:RefreshButtonState()
end

function M:OnClose()
	self.currVehicleId = 0

	self:StopPoliceHornCD()
end

function M:EnterPhoneMode()
	if not self.STATE_EnableOnce then
		return
	end

	self.IsPhoneMode = true

	self:RefreshButtonState()
end

function M:ExitPhoneMode()
	if not self.STATE_EnableOnce then
		return
	end

	self.IsPhoneMode = false

	self:RefreshButtonState()
end

function M:InitPoliceStyle()
	self.policeLightOn = gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle.PoliceLightOn
	self.policeSirenOn = VehicleSoundMgr.Instance:IsPlayPoliceSirenSound(self.currVehicleId)
	self.bindData.policeLightSwitchBtn.isSelected = self.policeLightOn
	self.bindData.policeSirenSwitchBtn.isSelected = self.policeSirenOn
end

function M:OnPoliceBtnHornPress()
	if self.cdHornTimer then
		return
	end

	self:StartPoliceHornCD()

	if not gDialogManager:IsDialogRunning() then
		gDialogManager:ShowGeneralDialog(LTConfig.PoliceConfig.PoliceCarHornDialog, gDialogSource.Police)
	end

	gMessageManager:SendMessage(gEventConstants.POLICE_CAR_HORN_PRESS)
	gClientToGameSceneDelegate:AskStopVehicleAhead()
end

function M:OnPoliceBtnHornRelease()
	gMessageManager:SendMessage(gEventConstants.POLICE_CAR_HORN_RELEASE)
end

function M:OnPoliceBtnLightSwitch()
	self.policeLightOn = not self.policeLightOn
	gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle.PoliceLightOn = self.policeLightOn
end

function M:OnPoliceBtnSirenSwitch()
	self.policeSirenOn = not self.policeSirenOn

	if self.policeSirenOn then
		VehicleSoundMgr.Instance:PlayPoliceSirenSound(self.currVehicleId)
	else
		VehicleSoundMgr.Instance:StopPoliceSirenSound(self.currVehicleId)
	end
end

function M:OnPoliceGuideToBtnClick()
	gPoliceJobManager:TraceToPoliceOffice()
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

function M:RefreshButtonState()
	local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	local active = not self.IsPhoneMode and self.IsMainDrive

	self:SetBtnActive(self.bindData.policeSirenSwitchBtn, active)
	self:SetBtnActive(self.bindData.policeLightSwitchBtn, active)
	self:SetBtnActive(self.bindData.policeHornBtn, active)
	self:SetBtnVisible(self.policeLightSwitchBtnStore, isMobile)
	self:SetBtnVisible(self.policeSirenSwitchBtnStore, isMobile)
	self:SetBtnVisible(self.policeHornBtnStore, isMobile)
end

function M:StartPoliceHornCD()
	self:StopPoliceHornCD()

	if self.bindData.policeHornBtn then
		self.bindData.policeHornBtn.interactable = false
	end

	self.cdHornTimer = Timer.New(function ()
		self.cdHornTimer = nil

		if self.bindData.policeHornBtn then
			self.bindData.policeHornBtn.interactable = true
		end
	end, LTConfig.PoliceConfig.PoliceCarHornCD):Start()
end

function M:StopPoliceHornCD()
	if self.cdHornTimer then
		self.cdHornTimer:Stop()

		self.cdHornTimer = nil
	end
end
