-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimelineMonitorPanelStore.lua
-- Decompiled from: 01357_TimelineMonitorPanelStore.lua_57a6c5a9166b.luajit

C_TimelineMonitorPanelStore = DefClass("C_TimelineMonitorPanelStore", C_TimelineMonitorPanelStore, C_StoreGroup)
GroupName2Class.TimelineMonitorPanelStore = C_TimelineMonitorPanelStore
local M = C_TimelineMonitorPanelStore

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
