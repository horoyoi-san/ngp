-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SettingDevicePopupStore.lua
-- Decompiled from: 00884_SettingDevicePopupStore.lua_93aa284b4358.luajit

C_SettingDevicePopupStore = DefClass("C_SettingDevicePopupStore", C_SettingDevicePopupStore, C_StoreGroup)
GroupName2Class.SettingDevicePopupStore = C_SettingDevicePopupStore
local M = C_SettingDevicePopupStore

M.ctor = function(self)
	self.isStart = false
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
	self.isStart = true

	self.bindData:Commit("text", LTConfig.ShezhiPanelConfig.VideoMemoryAlertText)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	if self.isStart then
		self.bindData:Commit("text", LTConfig.ShezhiPanelConfig.VideoMemoryAlertText)
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.turnToBtn.luaClick = self.CreateAction(self, "OnClickTurnToBtn")
end

M.OnClickTurnToBtn = function(self)
	gPanelManager:CheckShow(gPanelId.S_SETTINGS_PANEL, {
		["j#z^"] = 1
	})
end
