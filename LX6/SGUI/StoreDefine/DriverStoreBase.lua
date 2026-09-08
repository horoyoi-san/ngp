-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DriverStoreBase.lua
-- Decompiled from: 01838_DriverStoreBase.lua_c6457fe2ddf2.luajit

C_DriverStoreBase = DefClass("C_DriverStoreBase", C_DriverStoreBase, C_StoreGroup)
GroupName2Class.DriverStoreBase = C_DriverStoreBase
local M = C_DriverStoreBase

M.ctor = function(self)
	self.entered = false
	self.showing = false
	self.vehicleCs = nil
	self.vehicleId = nil
end

M.CheckReady = function(self)
	return self.showing and self.STATE_Started
end

M.TryEnter = function(self)
	if self.vehicleCs and self.CheckReady(self) and not self.entered then
		self.entered = true

		self.OnEnterFinish(self)
	end
end

M.TryExit = function(self)
	if self.entered then
		self.entered = false

		self.OnExitStart(self)
	end
end

M.OnEnterFinish = function(self)
end

M.OnExitStart = function(self)
end

M.OnStart = function(self)
	self.TryEnter(self)
end

M.OnDestroy = function(self)
	self.showing = false
	self.vehicleCs = nil
	self.vehicleId = nil

	self.TryExit(self)
end

M.OnShow = function(self, panelId, data)
	self.showing = true
	self.vehicleCs = data.vehicleCs
	self.vehicleId = data.vehicleId

	self.TryEnter(self)
end

M.OnClose = function(self)
	self.showing = false
	self.vehicleCs = nil
	self.vehicleId = nil

	self.TryExit(self)
end
