-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MainJoystickPanelStore.lua
-- Decompiled from: 01525_MainJoystickPanelStore.lua_06fe22802354.luajit

C_MainJoystickPanelStore = DefClass("C_MainJoystickPanelStore", C_MainJoystickPanelStore, C_StoreGroup)
GroupName2Class.MainJoystickPanelStore = C_MainJoystickPanelStore
local M = C_MainJoystickPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnLanguageChange = function(self, lang)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_JOYSTICK_ANIM] = self.CreateAction(self, "PlayThrowMoveAni"),
		[gEventConstants.SET_JOYSTICK_STYLE] = function (_, style)
			self.bindData.typeCtrl = style
		end
	}
end

M.RegisterWidget = function(self)
end

M.PlayThrowMoveAni = function(self, eventId, enable)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if enable then
		self.bindData.baoShuaiAnim:SetActive(true)
	else
		self.bindData.baoShuaiAnim:SetActive(false)
	end
end
