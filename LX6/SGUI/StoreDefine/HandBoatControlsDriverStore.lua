-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HandBoatControlsDriverStore.lua
-- Decompiled from: 02014_HandBoatControlsDriverStore.lua_886b76b4c757.luajit

local DriveManager = gCS.DriveManager
local HudDescConfig = LTConfig.HudDescConfig
C_HandBoatControlsDriverStore = DefClass("C_HandBoatControlsDriverStore", C_HandBoatControlsDriverStore, C_DriverStoreBase)
GroupName2Class.HandBoatControlsDriverStore = C_HandBoatControlsDriverStore
local M = C_HandBoatControlsDriverStore

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
end

M.ClearAllEnumsAutoGen = function(self)
	self.btnHideCtrlEnum = nil
end

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	LX6.GUI.NavMgrEx.Instance:AddBanArea(self.bindData.navArea)
end

M.OnDestroy = function(self)
	self.IsPhoneMode = nil
	self.gamePadMode = nil

	LX6.GUI.NavMgrEx.Instance:RemoveBanArea(self.bindData.navArea)
	M.base.OnDestroy(self)
end

M.OnGroupEnable = function(self)
	self:RegisterMessageEvents(self.msgEvents)

	self.leftForwardBtnStore = self:GetStoreByWidget(self.bindData.leftForwardBtn)
	self.leftBackBtnStore = self:GetStoreByWidget(self.bindData.leftBackBtn)
	self.rightForwardBtnStore = self:GetStoreByWidget(self.bindData.rightForwardBtn)
	self.rightBackBtnStore = self:GetStoreByWidget(self.bindData.rightBackBtn)

	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.leftForwardBtnStore = nil
	self.leftBackBtnStore = nil
	self.rightForwardBtnStore = nil
	self.rightBackBtnStore = nil
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

M.OnEnterFinish = function(self)
	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())

	self.IsPhoneMode = gClientUtils.CheckMainPhoneIsShowing()

	gPanelManager:PushPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIHandBoat)
	gPanelManager:DisableSpecialController()
	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER, 4)
	self:RefreshButtonState()
end

M.OnExitStart = function(self)
	gPanelManager:PopPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIHandBoat)
	gPanelManager:EnableSpecialController()
	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self.CreateAction(self, "OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, "OnPhoneAppHide")
	}
end

M.RegisterWidget = function(self)
	self.bindData.leftForwardBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnLeftForward", true)
	self.bindData.leftForwardBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnLeftForward", false)
	self.bindData.leftBackBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnLeftBack", true)
	self.bindData.leftBackBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnLeftBack", false)
	self.bindData.rightForwardBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnRightForward", true)
	self.bindData.rightForwardBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnRightForward", false)
	self.bindData.rightBackBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnRightBack", true)
	self.bindData.rightBackBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnRightBack", false)
	self.bindData.cameraRotateRespond.luaGamePadInputChanged = self.CreateAction(self, "OnCameraRotateRespondInputChanged")
end

M.OnBtnLeftForward = function(self, isDown)
	DriveManager:LeftForwardOarButtonHandle(isDown)
end

M.OnBtnLeftBack = function(self, isDown)
	DriveManager:LeftBackwardOarButtonHandle(isDown)
end

M.OnBtnRightForward = function(self, isDown)
	DriveManager:RightForwardOarButtonHandle(isDown)
end

M.OnBtnRightBack = function(self, isDown)
	DriveManager:RightBackwardOarButtonHandle(isDown)
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

	if self.CheckReady(self) then
		self.RefreshButtonState(self)
	end
end

M.ExitPhoneMode = function(self)
	self.IsPhoneMode = false

	if self.CheckReady(self) then
		self.RefreshButtonState(self)
	end
end

M.RefreshButtonState = function(self)
	self.isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()

	self.SetBtnVisible(self, self.leftForwardBtnStore, self.isMobile)
	self.SetBtnVisible(self, self.leftBackBtnStore, self.isMobile)
	self.SetBtnVisible(self, self.rightForwardBtnStore, self.isMobile)
	self.SetBtnVisible(self, self.rightBackBtnStore, self.isMobile)

	local active = not self.IsPhoneMode

	self.SetBtnActive(self, self.bindData.leftForwardBtn, active)
	self.SetBtnActive(self, self.bindData.leftBackBtn, active)
	self.SetBtnActive(self, self.bindData.rightForwardBtn, active)
	self.SetBtnActive(self, self.bindData.rightBackBtn, active)
end

M.SetBtnVisible = function(self, btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
end

M.SetBtnActive = function(self, btn, active)
	btn.SetActive(btn, active)
end
