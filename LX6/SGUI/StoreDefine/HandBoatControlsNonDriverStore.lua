-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HandBoatControlsNonDriverStore.lua
-- Decompiled from: 01707_HandBoatControlsNonDriverStore.lua_3953c691c01a.luajit

local DriveManager = gCS.DriveManager
local HudDescConfig = LTConfig.HudDescConfig
C_HandBoatControlsNonDriverStore = DefClass("C_HandBoatControlsNonDriverStore", C_HandBoatControlsNonDriverStore, C_StoreGroup)
GroupName2Class.HandBoatControlsNonDriverStore = C_HandBoatControlsNonDriverStore
local M = C_HandBoatControlsNonDriverStore

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

M.DefineAllEnumsAutoGen = function(self)
	self.btnHideCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.wordsCtrlEnum = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
	self.qteVxCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.btnHideCtrlEnum = nil
	self.wordsCtrlEnum = nil
	self.qteVxCtrlEnum = nil
end

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())
	LX6.GUI.NavMgrEx.Instance:AddBanArea(self.bindData.navArea)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	self.started = true
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.started = nil
	self.IsPhoneMode = nil
	self.gamePadMode = nil

	LX6.GUI.NavMgrEx.Instance:RemoveBanArea(self.bindData.navArea)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.currVehicleData = data
	self.showing = true
	self.IsPhoneMode = gClientUtils.CheckMainPhoneIsShowing()

	gPanelManager:PushPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIHandBoat)
	gPanelManager:DisableSpecialController()
	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER, 4)
end

M.OnClose = function(self)
	gPanelManager:PopPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIHandBoat)
	gPanelManager:EnableSpecialController()
	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER)

	self.currVehicleData = nil
	self.showing = false
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

M.OnActiveDeviceChange = function(self, device)
	self.gamePadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.GenMessageEvents = function(self)
	self.msgEvents = {}
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

M.SetBtnVisible = function(self, btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
end

M.SetBtnActive = function(self, btn, active)
	btn.SetActive(btn, active)
end
