-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WuShuCountDownPanelStore.lua
-- Decompiled from: 01163_WuShuCountDownPanelStore.lua_7f753d29e883.luajit

C_WuShuCountDownPanelStore = DefClass("C_WuShuCountDownPanelStore", C_WuShuCountDownPanelStore, C_StoreGroup)
GroupName2Class.WuShuCountDownPanelStore = C_WuShuCountDownPanelStore
local M = C_WuShuCountDownPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.visibleEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.visibleEnum = nil
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
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end
