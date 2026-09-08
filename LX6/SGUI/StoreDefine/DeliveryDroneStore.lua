-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DeliveryDroneStore.lua
-- Decompiled from: 01892_DeliveryDroneStore.lua_123d4c4815df.luajit

C_DeliveryDroneStore = DefClass("C_DeliveryDroneStore", C_DeliveryDroneStore, C_StoreGroup)
GroupName2Class.DeliveryDroneStore = C_DeliveryDroneStore
local M = C_DeliveryDroneStore
local UberSimConfig = LTConfig.UberSimConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self.SetStateText(self)
end

M.SetStateText = function(self)
	local state = gDeliveryTaskManager.TryGetDroneState() or 1
	self.bindData.stateText = UberSimConfig.TruckUAVStateDescribe[state + 1].des or ""
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
	self.SetStateText(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.SetStateText(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.UAV_LOGIC_STATE_CHANGE] = self.CreateAction(self, self.UAVLoginChange)
	}
end

M.UAVLoginChange = function(self, _, state)
	self.bindData.stateText = UberSimConfig.TruckUAVStateDescribe[state + 1].des or ""
end

M.RegisterWidget = function(self)
end
