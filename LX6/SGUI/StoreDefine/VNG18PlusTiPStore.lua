-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\VNG18PlusTiPStore.lua
-- Decompiled from: 01145_VNG18PlusTiPStore.lua_d56c4236452a.luajit

C_VNG18PlusTiPStore = DefClass("C_VNG18PlusTiPStore", C_VNG18PlusTiPStore, C_StoreGroup)
GroupName2Class.VNG18PlusTiPStore = C_VNG18PlusTiPStore
local M = C_VNG18PlusTiPStore

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
