-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BatterySaverPanelStore.lua
-- Decompiled from: 01662_BatterySaverPanelStore.lua_93009e0c44f7.luajit

C_BatterySaverPanelStore = DefClass("C_BatterySaverPanelStore", C_BatterySaverPanelStore, C_StoreGroup)
GroupName2Class.BatterySaverPanelStore = C_BatterySaverPanelStore
local M = C_BatterySaverPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.hour = 0
	self.min = 0
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
end

M.OnUpdate = function(self)
	local dt = System.DateTime.Now
	local hour = dt.Hour
	local min = dt.Minute

	if hour == self.hour or min == self.min then
		self.bindData.timeText = string.format("%02d:%02d", hour, min)
	end

	self.hour = hour
	self.min = min
end

M.GenMessageEvents = function(self)
end
