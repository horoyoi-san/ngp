-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CoreHudDrivePoliceCarStore.lua
-- Decompiled from: 01493_CoreHudDrivePoliceCarStore.lua_85046224ae65.luajit

local VehicleSoundMgr = LX6.Audio.VehicleSoundMgr
C_CoreHudDrivePoliceCarStore = DefClass("C_CoreHudDrivePoliceCarStore", C_CoreHudDrivePoliceCarStore, C_StoreGroup)
GroupName2Class.CoreHudDrivePoliceCarStore = C_CoreHudDrivePoliceCarStore
local M = C_CoreHudDrivePoliceCarStore

M.ctor = function(self)
	self.policeLightOn = false
	self.policeSirenOn = false
	self.currVehicleId = 0
end

M.OnAwake = function(self)
	self.bindData.policeHornBtn.luaPress = self.CreateAction(self, "OnPoliceBtnHornPress")
	self.bindData.policeHornBtn.luaRelease = self.CreateAction(self, "OnPoliceBtnHornRelease")
	self.bindData.policeLightSwitchBtn.luaClick = self.CreateAction(self, "OnPoliceBtnLightSwitch")
	self.bindData.policeSirenSwitchBtn.luaClick = self.CreateAction(self, "OnPoliceBtnSirenSwitch")
	self.bindData.policeSirenSwitchPad.luaLongPress = self.CreateAction(self, "OnPoliceBtnSirenSwitch")
	self.bindData.policeGuideTo.luaClick = self.CreateAction(self, "OnPoliceGuideToBtnClick")
	self.bindData.policeGuideToPad.luaLongPress = self.CreateAction(self, "OnPoliceGuideToBtnClick")
	self.started = false
	self.ControlType = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
	self.msgEvents = {
		[gEventConstants.LINK_MODE_CHANGE] = self.CreateAction(self, "OnLinkModeChange")
	}
end

M.OnDestroy = function(self)
	self.started = nil
end

M.OnGroupEnable = function(self)
	self:RegisterMessageEvents(self.msgEvents)

	self.policeLightSwitchBtnStore = self:GetStoreByWidget(self.bindData.policeLightSwitchBtn)
	self.policeSirenSwitchBtnStore = self:GetStoreByWidget(self.bindData.policeSirenSwitchBtn)
	self.policeHornBtnStore = self:GetStoreByWidget(self.bindData.policeHornBtn)
	self.policeGuideToStore = self:GetStoreByWidget(self.bindData.policeGuideTo)
	self.policeLightSwitchBtnStore.btnId = LTConfig.HudDescConfig.POLICE_LIGHT_SWITCH_BTN
	self.policeSirenSwitchBtnStore.btnId = LTConfig.HudDescConfig.POLICE_SIREN_SWITCH_BTN
	self.policeHornBtnStore.btnId = LTConfig.HudDescConfig.POLICE_HORN_BTN
	self.policeGuideToStore.btnId = LTConfig.HudDescConfig.POLICE_GUIDE_TO

	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.policeLightSwitchBtnStore = nil
	self.policeSirenSwitchBtnStore = nil
	self.policeHornBtnStore = nil
	self.policeGuideToStore = nil

	self.StopAskPoliceVehicleHorn(self)
end

M.OnShow = function(self, panelId, data, widget, IsMainDrive, IsPhoneMode)
	self.currVehicleId = data.vehicleId
	self.IsPhoneMode = IsPhoneMode
	self.IsMainDrive = IsMainDrive

	self.InitPoliceStyle(self)

	if self.started then
		self.RefreshButtonState(self)
	end

	if self.bindData.policeHornBtn then
		self.bindData.policeHornBtn.interactable = true
	end
end

M.OnStart = function(self)
	self.started = true

	self.RefreshButtonState(self)
end

M.OnClose = function(self)
	self.currVehicleId = 0

	self.StopPoliceHornCD(self)
end

M.OnDestroy = function(self)
	self.currVehicleId = 0

	self.StopPoliceHornCD(self)
end

M.EnterPhoneMode = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.IsPhoneMode = true

	self.RefreshButtonState(self)
end

M.ExitPhoneMode = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.IsPhoneMode = false

	self.RefreshButtonState(self)
end

M.InitPoliceStyle = function(self)
	self.policeLightOn = gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle.PoliceLightOn
	self.policeSirenOn = VehicleSoundMgr.Instance:IsPlayPoliceSirenSound(self.currVehicleId)
	self.bindData.policeLightSwitchBtn.isSelected = self.policeLightOn
	self.bindData.policeSirenSwitchBtn.isSelected = self.policeSirenOn
	self.askHorn = false
end

M.OnPoliceBtnHornPress = function(self)
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

M.OnPoliceBtnHornRelease = function(self)
	gMessageManager:SendMessage(gEventConstants.POLICE_CAR_HORN_RELEASE)
end

M.OnPoliceBtnLightSwitch = function(self)
	self.policeLightOn = not self.policeLightOn

	if gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle then
		gDriveVehiclesManager.cs_manager.CurrentPlayerBaseVehicle.PoliceLightOn = self.policeLightOn
	end
end

M.OnPoliceBtnSirenSwitch = function(self)
	self.policeSirenOn = not self.policeSirenOn

	if self.policeSirenOn then
		VehicleSoundMgr.Instance:PlayPoliceSirenSound(self.currVehicleId)
		self:StartAskPoliceVehicleHorn()
	else
		VehicleSoundMgr.Instance:StopPoliceSirenSound(self.currVehicleId)
		self:StopAskPoliceVehicleHorn()
	end
end

M.StartAskPoliceVehicleHorn = function(self)
	self:CancelAskPoliceVehicleHornTimer()

	self.askHornCdTimer = Timer.New(function ()
		if not self.askHorn then
			gClientToGameSceneDelegate:AskPoliceVehicleHorn(self.currVehicleId, true)

			self.askHorn = true
		end
	end, LTConfig.PoliceConfig.AskPoliceVehicleHornCD):Start()
end

M.CancelAskPoliceVehicleHornTimer = function(self)
	if self.askHornCdTimer then
		self.askHornCdTimer:Stop()

		self.askHornCdTimer = nil
	end
end

M.StopAskPoliceVehicleHorn = function(self)
	self.CancelAskPoliceVehicleHornTimer(self)

	if self.askHorn then
		gClientToGameSceneDelegate:AskPoliceVehicleHorn(self.currVehicleId, false)

		self.askHorn = false
	end
end

M.OnPoliceGuideToBtnClick = function(self)
	gPoliceJobManager:TraceToPoliceOffice()
end

M.SetBtnVisible = function(self, btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
end

M.SetBtnInteractable = function(self, btnStore, interactable)
	gStoreButtonMgr:SetButtonInteractableBase(btnStore, interactable)
end

M.SetBtnControl = function(self, btnStore, visible, interactable)
	gStoreButtonMgr:SetButtonControlBase(btnStore, visible, interactable)
end

M.SetBtnActive = function(self, btn, active)
	btn.SetActive(btn, active)
end

M.RefreshButtonState = function(self)
	local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	local active = not self.IsPhoneMode and self.IsMainDrive

	self:SetBtnActive(self.bindData.policeSirenSwitchBtn, active)
	self:SetBtnActive(self.bindData.policeSirenSwitchPad, active)
	self:SetBtnActive(self.bindData.policeLightSwitchBtn, active)
	self:SetBtnActive(self.bindData.policeHornBtn, active)
	self:SetBtnActive(self.bindData.policeGuideTo, active and not gLinkManager:CheckInLinkMode())
	self:SetBtnActive(self.bindData.policeGuideToPad, active and not gLinkManager:CheckInLinkMode())
	self:SetBtnVisible(self.policeLightSwitchBtnStore, isMobile)
	self:SetBtnVisible(self.policeSirenSwitchBtnStore, isMobile)
	self:SetBtnVisible(self.policeHornBtnStore, isMobile)
	self:SetBtnVisible(self.policeGuideToStore, isMobile)
end

M.StartPoliceHornCD = function(self)
	self.StopPoliceHornCD(self)

	if self.bindData.policeHornBtn then
		self.bindData.policeHornBtn.interactable = false
	end

	self.cdHornTimer = Timer.New(function ()
		self.cdHornTimer = nil

		if not self.STATE_EnableOnce then
			return
		end

		if self.bindData.policeHornBtn then
			self.bindData.policeHornBtn.interactable = true
		end
	end, LTConfig.PoliceConfig.PoliceCarHornCD):Start()
end

M.StopPoliceHornCD = function(self)
	if self.cdHornTimer then
		self.cdHornTimer:Stop()

		self.cdHornTimer = nil
	end
end

M.OnLinkModeChange = function(self)
	if self.started then
		self.RefreshButtonState(self)
	end
end
