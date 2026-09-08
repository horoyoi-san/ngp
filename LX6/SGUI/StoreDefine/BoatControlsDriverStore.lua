-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BoatControlsDriverStore.lua
-- Decompiled from: 02017_BoatControlsDriverStore.lua_1bcaf234c8de.luajit

local DriveManager = gCS.DriveManager
local HudDescConfig = LTConfig.HudDescConfig
C_BoatControlsDriverStore = DefClass("C_BoatControlsDriverStore", C_BoatControlsDriverStore, C_DriverStoreBase)
GroupName2Class.BoatControlsDriverStore = C_BoatControlsDriverStore
local M = C_BoatControlsDriverStore

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
	self.IsResetValid = false
	self.spoonHideReset = false
end

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	LX6.GUI.NavMgrEx.Instance:AddBanArea(self.bindData.navArea)
end

M.OnDestroy = function(self)
	LX6.GUI.NavMgrEx.Instance:RemoveBanArea(self.bindData.navArea)

	self.IsPhoneMode = nil
	self.gamePadMode = nil

	M.base.OnDestroy(self)
end

M.OnGroupEnable = function(self)
	self:RegisterMessageEvents(self.msgEvents)

	self.forwardBtnStore = self:GetStoreByWidget(self.bindData.forwardBtn)
	self.backwardBtnStore = self:GetStoreByWidget(self.bindData.backwardBtn)
	self.leftBtnStore = self:GetStoreByWidget(self.bindData.leftBtn)
	self.rightBtnStore = self:GetStoreByWidget(self.bindData.rightBtn)
	self.forwardBtnPhoneStore = self:GetStoreByWidget(self.bindData.forwardBtnPhone)
	self.backwardBtnPhoneStore = self:GetStoreByWidget(self.bindData.backwardBtnPhone)
	self.leftBtnPhoneStore = self:GetStoreByWidget(self.bindData.leftBtnPhone)
	self.rightBtnPhoneStore = self:GetStoreByWidget(self.bindData.rightBtnPhone)

	gMessageManager:SendMessage(gEventConstants.CORE_HUD_DESC_REFRESH, {
		storeName = self.m_Name
	})
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.forwardBtnStore = nil
	self.backwardBtnStore = nil
	self.leftBtnStore = nil
	self.rightBtnStore = nil
	self.forwardBtnPhoneStore = nil
	self.backwardBtnPhoneStore = nil
	self.leftBtnPhoneStore = nil
	self.rightBtnPhoneStore = nil
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

	self:RefreshButtonState()
	gPanelManager:PushPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIBoat)
	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER, 4)
end

M.OnExitStart = function(self)
	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(gPanelId.BASE_VEHICLE_CONTROLLER)
	gPanelManager:PopPanelContext(gPanelId.BASE_VEHICLE_CONTROLLER, LTConfig.InputUIContextConfig.UIBoat)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self.CreateAction(self, "OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, "OnPhoneAppHide")
	}
end

M.RegisterWidget = function(self)
	self.bindData.forwardBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnForward", true)
	self.bindData.forwardBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnForward", false)
	self.bindData.backwardBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnBackward", true)
	self.bindData.backwardBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnBackward", false)
	self.bindData.leftBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnLeft", true)
	self.bindData.leftBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnLeft", false)
	self.bindData.rightBtn.luaPress = self.CreateActionWithArgs(self, "OnBtnRight", true)
	self.bindData.rightBtn.luaRelease = self.CreateActionWithArgs(self, "OnBtnRight", false)
	self.bindData.forwardBtnPhone.luaPress = self.CreateActionWithArgs(self, "OnBtnForward", true)
	self.bindData.forwardBtnPhone.luaRelease = self.CreateActionWithArgs(self, "OnBtnForward", false)
	self.bindData.backwardBtnPhone.luaPress = self.CreateActionWithArgs(self, "OnBtnBackward", true)
	self.bindData.backwardBtnPhone.luaRelease = self.CreateActionWithArgs(self, "OnBtnBackward", false)
	self.bindData.leftBtnPhone.luaPress = self.CreateActionWithArgs(self, "OnBtnLeft", true)
	self.bindData.leftBtnPhone.luaRelease = self.CreateActionWithArgs(self, "OnBtnLeft", false)
	self.bindData.rightBtnPhone.luaPress = self.CreateActionWithArgs(self, "OnBtnRight", true)
	self.bindData.rightBtnPhone.luaRelease = self.CreateActionWithArgs(self, "OnBtnRight", false)
	self.bindData.cameraRotateRespond.luaGamePadInputChanged = self.CreateAction(self, "OnCameraRotateRespondInputChanged")
	self.bindData.leftStickRespond.luaGamePadInputChanged = self.CreateAction(self, "OnLeftStickRespondInputChanged")
	self.bindData.leftTriggerRespond.luaGamePadInputChanged = self.CreateAction(self, "OnLeftTriggerRespondInputChanged")
	self.bindData.rightTriggerRespond.luaGamePadInputChanged = self.CreateAction(self, "OnRightTriggerRespondInputChanged")
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

M.OnLeftStickRespondInputChanged = function(self, context)
	if context.started or context.performed then
		local val = context:ReadValueVector2()

		DriveManager:SetHorizontalAxisGamePad(val.x, val.y)
	end

	if context.canceled then
		DriveManager:SetHorizontalAxisGamePad(0, 0)
	end
end

M.OnLeftTriggerRespondInputChanged = function(self, context)
	if context.started or context.performed then
		DriveManager:SetBackwardInputGamePad(context:ReadValueFloat())
	end

	if context.canceled then
		DriveManager:SetBackwardInputGamePad(0)
	end
end

M.OnRightTriggerRespondInputChanged = function(self, context)
	if context.started or context.performed then
		DriveManager:SetForwardInputGamePad(context:ReadValueFloat())
	end

	if context.canceled then
		DriveManager:SetForwardInputGamePad(0)
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
	self.bindData.PhoneAndDriveCtrl = self.IsPhoneMode and self.ControlType.True or self.ControlType.False

	self:SetBtnVisible(self.leftBtnStore, self.isMobile)
	self:SetBtnVisible(self.rightBtnStore, self.isMobile)
	self:SetBtnVisible(self.forwardBtnStore, self.isMobile)
	self:SetBtnVisible(self.backwardBtnStore, self.isMobile)
	self:SetBtnVisible(self.leftBtnPhoneStore, self.isMobile)
	self:SetBtnVisible(self.rightBtnPhoneStore, self.isMobile)
	self:SetBtnVisible(self.forwardBtnPhoneStore, self.isMobile)
	self:SetBtnVisible(self.backwardBtnPhoneStore, self.isMobile)
end

M.OnBtnForward = function(self, isDown)
	DriveManager:ForwardThrottleButtonHandle(isDown)
end

M.OnBtnBackward = function(self, isDown)
	DriveManager:BackwardThrottleButtonHandle(isDown)
end

M.OnBtnLeft = function(self, isDown)
	DriveManager:LeftSteerButtonHandle(isDown)
end

M.OnBtnRight = function(self, isDown)
	DriveManager:RightSteerButtonHandle(isDown)
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
