-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BicycleControlsNonDriverStore.lua
-- Decompiled from: 01677_BicycleControlsNonDriverStore.lua_395163e3efd4.luajit

C_BicycleControlsNonDriverStore = DefClass("C_BicycleControlsNonDriverStore", C_BicycleControlsNonDriverStore, C_StoreGroup)
GroupName2Class.BicycleControlsNonDriverStore = C_BicycleControlsNonDriverStore
local M = C_BicycleControlsNonDriverStore

M.ctor = function(self)
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

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	LX6.GUI.NavMgrEx.Instance:AddBanArea(self.bindData.naveArea)
end

M.OnDestroy = function(self)
	self.IsPhoneMode = nil
	self.gamepadMode = nil

	LX6.GUI.NavMgrEx.Instance:RemoveBanArea(self.bindData.naveArea)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnUpdate = function(self)
	if LX6.TouchNew.TouchProxy.useNewViewRotate then
		return
	end

	if self.gamePadMode then
		self.UpdateCameraRotateGamePad(self)
	end
end

M.OnShow = function(self, panelId, data)
	self.showing = true
	self.IsPhoneMode = gClientUtils.CheckMainPhoneIsShowing()
	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()

	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())

	self.vehicleCs = data.vehicleCs

	self:RefreshPhoneState()
	gPanelManager:PushPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIMoto)
	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER, 4)
end

M.OnClose = function(self)
	self.showing = false

	gPanelManager:PopPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIMoto)
	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER)

	self.vehicleCs = nil
end

M.OnActiveDeviceChange = function(self, device)
	self.gamePadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.OnPhoneAppShow = function(self)
	self.EnterPhoneMode(self)
end

M.OnPhoneAppHide = function(self)
	self.ExitPhoneMode(self)
end

M.EnterPhoneMode = function(self)
	self.IsPhoneMode = true

	if self.showing then
		self.RefreshPhoneState(self)
	end
end

M.ExitPhoneMode = function(self)
	self.IsPhoneMode = false

	if self.showing then
		self.RefreshPhoneState(self)
	end
end

M.RefreshPhoneState = function(self)
	self.bindData.PhoneOpenCtrl = self.IsPhoneMode and self.ControlType.True or self.ControlType.False
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self.CreateAction(self, "OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, "OnPhoneAppHide")
	}
end

M.RegisterWidget = function(self)
	self.bindData.rightStickRespond.luaGamePadInputChanged = self.CreateAction(self, "OnRightStickControl")
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

M.UpdateCameraRotateGamePad = function(self)
	if not self.gamepadUpdateRotate then
		return
	end

	gCameraUtils:DoRotateCameraByGamePad(4, self.rightStickValue.x, self.rightStickValue.y)
end

M.SetBtnActive = function(self, btn, active)
	btn.SetActive(btn, active)
end

M.SetBtnVisible = function(self, btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
end
