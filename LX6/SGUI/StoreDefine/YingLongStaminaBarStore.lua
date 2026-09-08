-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YingLongStaminaBarStore.lua
-- Decompiled from: 01272_YingLongStaminaBarStore.lua_12aa9c1acf29.luajit

C_YingLongStaminaBarStore = DefClass("C_YingLongStaminaBarStore", C_YingLongStaminaBarStore, C_StoreGroup)
GroupName2Class.YingLongStaminaBarStore = C_YingLongStaminaBarStore
local M = C_YingLongStaminaBarStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.prototypeLowLimit = 1
	self.isStart = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.showCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.energyCtrlEnum = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showCtrlEnum = nil
	self.energyCtrlEnum = nil
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
	self.bindData.showCtrl = 0
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.prototypeLowLimit = nil
	self.isStart = nil
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

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PROTOTYPE_ENERGY_REFRESH] = self.CreateAction(self, "OnYingLongEnergyChange"),
		[gEventConstants.PROTOTYPE_ENERGY_LOW_LIMIT] = self.CreateAction(self, "SetYingLongLowLimit")
	}
end

M.RegisterWidget = function(self)
end

M.OnYingLongEnergyChange = function(self, eventId, data)
	if not self.isStart then
		return
	end

	self.bindData.fillBar.fillAmount = data

	if data ~= 1 then
		self.bindData.showCtrl = 0

		return
	end

	self.bindData.showCtrl = 1

	if data >= self.prototypeLowLimit then
		self.bindData.energyCtrl = 1
		self.bindData.markBar.fillAmount = self.prototypeLowLimit
	else
		self.bindData.energyCtrl = 0
	end
end

M.SetYingLongLowLimit = function(self, eventId, data)
	self.prototypeLowLimit = data
end
