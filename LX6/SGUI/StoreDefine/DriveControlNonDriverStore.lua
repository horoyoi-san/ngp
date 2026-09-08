-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DriveControlNonDriverStore.lua
-- Decompiled from: 01871_DriveControlNonDriverStore.lua_088d6d6c5302.luajit

local HudDescConfig = LTConfig.HudDescConfig
C_DriveControlNonDriverStore = DefClass("C_DriveControlNonDriverStore", C_DriveControlNonDriverStore, C_StoreGroup)
GroupName2Class.DriveControlNonDriverStore = C_DriveControlNonDriverStore
local M = C_DriveControlNonDriverStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.needUpdate = false
	self.gamepadMode = false
	self.isXinShouRaid = false
	self.IsPhoneMode = false
	self.rightStickValue = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	self.gamepadUpdateRotate = false
	self.IsConvertibleValid = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnStart = function(self)
	self.started = true

	self.OnEnterVehicleFinish(self, self.currVehicleData)
end

M.OnDestroy = function(self)
	self.started = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.showing = true
	self.currVehicleData = data

	if self.started and self.currVehicleData then
		self.OnEnterVehicleFinish(self, self.currVehicleData)
	end

	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

M.OnClose = function(self)
	self.showing = false

	if self.currVehicleData then
		self.OnExitVehicleStart(self, self.currVehicleData)
	else
		print_warn("[CoreHudShootStore]OnClose: currVehicleData is null")
	end
end

M.OnUpdate = function(self)
	if LX6.TouchNew.TouchProxy.useNewViewRotate then
		return
	end

	if self.needUpdate and self.gamepadMode then
		self.UpdateCameraRotateGamePad(self)
	end
end

M.UpdateCameraRotateGamePad = function(self)
	if not self.gamepadUpdateRotate then
		return
	end

	local csUnit = gCS.MyPlayerManager.PlayerUnit

	if gCS.ShootModule.GetVehicleShootState(csUnit) == LX6.Units.Module.ShootModule.VehicleShootState.None then
		gCameraUtils:DoRotateCameraByGamePad(6, self.rightStickValue.x, self.rightStickValue.y)
	else
		gCameraUtils:DoRotateCameraByGamePad(4, self.rightStickValue.x, self.rightStickValue.y)
	end
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.VEHICLE_SHOOT_STATE_CHANGED] = self.CreateAction(self, "OnVehicleShootStateChange")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.RegisterWidget = function(self)
	self.bindData.cameraRotateRespond.luaGamePadInputChanged = self.CreateAction(self, "OnRightStickControl")
	self.started = false
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
		local csUnit = gCS.MyPlayerManager.PlayerUnit

		if gCS.ShootModule.GetIsInVehicleShootState(csUnit) or gCS.ShootModule.GetIsInVehicleForwardShootState(csUnit) then
			gCameraUtils:DoRotateCameraByGamePad(6, 0, 0)
		else
			gCameraUtils:DoRotateCameraByGamePad(4, 0, 0)
		end
	end
end

M.OnEnterVehicleFinish = function(self, vehicleId)
	gPanelManager:PushPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIDriveVehicle)

	if gCS.ShootModule.GetVehicleShootState(gCS.MyPlayerManager.PlayerUnit) == LX6.Units.Module.ShootModule.VehicleShootState.None then
		LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER, 6)
	else
		LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER, 4)
	end

	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())

	self.needUpdate = true
	self.isXinShouRaid = gUIUtils:IsInXinShouRaid()
	self.IsPhoneMode = gClientUtils.CheckMainPhoneIsShowing()
	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
end

M.OnExitVehicleStart = function(self, vehicleId)
	gPanelManager:PopPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIDriveVehicle)
	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER)

	self.needUpdate = false
	self.rightStickValue.x = 0
	self.rightStickValue.y = 0
	self.currVehicleData = nil
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

M.OnVehicleShootStateChange = function(self, eventId, state)
	if self.showing then
		if state == LX6.Units.Module.ShootModule.VehicleShootState.None then
			LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER, 6)
		else
			LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER, 4)
		end
	end
end
