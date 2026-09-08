-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FakeSwapCharacterNotifyPanelStore.lua
-- Decompiled from: 01859_FakeSwapCharacterNotifyPanelStore.lua_091774a5b88c.luajit

C_FakeSwapCharacterNotifyPanelStore = DefClass("C_FakeSwapCharacterNotifyPanelStore", C_FakeSwapCharacterNotifyPanelStore, C_StoreGroup)
GroupName2Class.FakeSwapCharacterNotifyPanelStore = C_FakeSwapCharacterNotifyPanelStore
local M = C_FakeSwapCharacterNotifyPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.activeButtonCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.activeButtonCtrlEnum = nil
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.bindData.activeButtonCtrl = 1
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.switchBtn.luaPress = self.CreateAction(self, "OnClickSwitchBtn")
	self.bindData.switchBtn.luaRelease = self.CreateAction(self, "ReleaseCloseCharacterSwitch")
end

M.OnClickSwitchBtn = function(self)
	gPanelManager:CheckShow(gPanelId.S_TL_FAKE_SWAP_CHARACTER_LIST_PANEL)
end

M.ReleaseCloseCharacterSwitch = function(self)
	gPanelManager:Close(gPanelId.S_TL_FAKE_SWAP_CHARACTER_LIST_PANEL)
end
