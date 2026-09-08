-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BoatControlsNonDriverStore.lua
-- Decompiled from: 01679_BoatControlsNonDriverStore.lua_5ae918e429f0.luajit

local HudDescConfig = LTConfig.HudDescConfig
C_BoatControlsNonDriverStore = DefClass("C_BoatControlsNonDriverStore", C_BoatControlsNonDriverStore, C_StoreGroup)
GroupName2Class.BoatControlsNonDriverStore = C_BoatControlsNonDriverStore
local M = C_BoatControlsNonDriverStore

M.DefineAllVariables = function(self)
	self.gamePadMode = false
	self.IsPhoneMode = false
	self.rightStickValue = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	self.gamepadUpdateRotate = false
	self.ControlType = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
end

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())
	LX6.GUI.NavMgrEx.Instance:AddBanArea(self.bindData.navArea)
end

M.OnStart = function(self)
	self.started = true

	if self.showing and self.started then
		self.RefreshButtonState(self)
	end
end

M.OnDestroy = function(self)
	self.started = nil
	self.IsPhoneMode = nil
	self.gamePadMode = nil

	LX6.GUI.NavMgrEx.Instance:RemoveBanArea(self.bindData.navArea)
end

M.OnGroupEnable = function(self)
	self:RegisterMessageEvents(self.msgEvents)
	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.currVehicleData = data
	self.showing = true
	self.IsPhoneMode = gClientUtils.CheckMainPhoneIsShowing()

	if self.showing and self.started then
		self.RefreshButtonState(self)
	end

	gPanelManager:PushPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIBoat)
	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER, 4)
end

M.OnUpdate = function(self)
	if LX6.TouchNew.TouchProxy.useNewViewRotate then
		return
	end

	if self.gamePadMode then
		self.UpdateCameraRotateGamePad(self)
	end
end

M.UpdateCameraRotateGamePad = function(self)
	if not self.gamepadUpdateRotate then
		return
	end

	gCameraUtils:DoRotateCameraByGamePad(4, self.rightStickValue.x, self.rightStickValue.y)
end

M.OnClose = function(self)
	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER)
	gPanelManager:PopPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIBoat)

	self.currVehicleData = nil
	self.showing = false
end

M.OnActiveDeviceChange = function(self, device)
	self.gamePadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self.CreateAction(self, "OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, "OnPhoneAppHide")
	}
end

M.RegisterWidget = function(self)
	self.bindData.cameraRotateRespond.luaGamePadInputChanged = self.CreateAction(self, "OnCameraRotateRespondInputChanged")
end

M.OnCameraRotateRespondInputChanged = function(self, context)
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

M.OnPhoneAppShow = function(self)
	self.EnterPhoneMode(self)
end

M.OnPhoneAppHide = function(self)
	self.ExitPhoneMode(self)
end

M.EnterPhoneMode = function(self)
	self.IsPhoneMode = true

	if self.started then
		self.RefreshButtonState(self)
	end
end

M.ExitPhoneMode = function(self)
	self.IsPhoneMode = false

	if self.started then
		self.RefreshButtonState(self)
	end
end

M.RefreshButtonState = function(self)
	self.bindData.PhoneAndDriveCtrl = self.IsPhoneMode and self.ControlType.True or self.ControlType.False
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
