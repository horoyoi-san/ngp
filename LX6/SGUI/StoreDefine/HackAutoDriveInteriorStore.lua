-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HackAutoDriveInteriorStore.lua
-- Decompiled from: 01691_HackAutoDriveInteriorStore.lua_0ee0eb62bb74.luajit

C_HackAutoDriveInteriorStore = DefClass("C_HackAutoDriveInteriorStore", C_HackAutoDriveInteriorStore, C_StoreGroup)
GroupName2Class.HackAutoDriveInteriorStore = C_HackAutoDriveInteriorStore
local M = C_HackAutoDriveInteriorStore

M.DefineAllVariables = function(self)
	self.rightStickValue = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	self.gamepadUpdateRotate = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnShow = function(self, panelId, data)
	self.showing = true

	LX6.TouchNew.TouchProxy.SetJoyStickViewRotateContent(gPanelId.GAMEPLAY_CONTROLS, 4)
end

M.OnClose = function(self)
	LX6.TouchNew.TouchProxy.ClearJoyStickViewRotateContent(gPanelId.GAMEPLAY_CONTROLS)

	self.showing = false
end

M.OnUpdate = function(self)
	if LX6.TouchNew.TouchProxy.useNewViewRotate then
		return
	end

	self.UpdateCameraRotateGamePad(self)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.rightStickRespond.luaGamePadInputChanged = self.CreateAction(self, "OnRightStickControl")
end

M.SetBtnActive = function(self, btn, active)
	btn.SetActive(btn, active)
end

M.SetBtnVisible = function(self, btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
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
