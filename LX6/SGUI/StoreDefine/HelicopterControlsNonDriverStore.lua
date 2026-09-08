-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HelicopterControlsNonDriverStore.lua
-- Decompiled from: 01709_HelicopterControlsNonDriverStore.lua_e849ba3fbcb3.luajit

C_HelicopterControlsNonDriverStore = DefClass("C_HelicopterControlsNonDriverStore", C_HelicopterControlsNonDriverStore, C_StoreGroup)
GroupName2Class.HelicopterControlsNonDriverStore = C_HelicopterControlsNonDriverStore
local M = C_HelicopterControlsNonDriverStore

M.ctor = function(self)
	self.msgEvents = {
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self.CreateAction(self, "OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, "OnPhoneAppHide")
	}
end

M.OnAwake = function(self)
	self.ControlType = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
	self.bindData.rightStickRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")

	self:RegisterMessageEvents(self.msgEvents)
	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())
	LX6.GUI.NavMgrEx.Instance:AddBanArea(self.bindData.naveArea)

	self.IsPhoneMode = gClientUtils.CheckMainPhoneIsShowing()
	self.started = false
	self.rightStickValue = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	self.gamepadUpdateRotate = false
	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
end

M.OnStart = function(self)
	self.started = true

	self.RefreshButtonState(self)
end

M.OnGroupEnable = function(self)
	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

M.OnGroupDisable = function(self)
end

M.OnDestroy = function(self)
	self.started = nil
	self.helicopter = nil

	self:ClearMessageEvents()
	LX6.GUI.NavMgrEx.Instance:RemoveBanArea(self.bindData.naveArea)
end

M.OnShow = function(self, panelId, data)
	self.showing = true
	self.helicopter = data.vehicleCs

	self:RefreshButtonState()
	gPanelManager:PushPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIDriveVehicle)
	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER, 4)
end

M.OnClose = function(self)
	gPanelManager:PopPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIDriveVehicle)
	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER)

	self.showing = false
	self.helicopter = nil
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

M.RefreshButtonState = function(self)
	if not self.showing or not self.started then
		return
	end

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

	if not self.showing or not self.started then
		return
	end

	self.RefreshButtonState(self)
end

M.ExitPhoneMode = function(self)
	self.IsPhoneMode = false

	if not self.showing or not self.started then
		return
	end

	self.RefreshButtonState(self)
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
