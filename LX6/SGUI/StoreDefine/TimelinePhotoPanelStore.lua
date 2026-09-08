-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimelinePhotoPanelStore.lua
-- Decompiled from: 01359_TimelinePhotoPanelStore.lua_6c07a4fd2ef5.luajit

C_TimelinePhotoStore = DefClass("C_TimelinePhotoStore", C_TimelinePhotoStore, C_StoreGroup)
GroupName2Class.TimelinePhotoStore = C_TimelinePhotoStore
local M = C_TimelinePhotoStore

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
