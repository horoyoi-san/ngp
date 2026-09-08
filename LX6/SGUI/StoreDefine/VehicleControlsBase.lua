-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\VehicleControlsBase.lua
-- Decompiled from: 01141_VehicleControlsBase.lua_ea31697ec18e.luajit

C_VehicleControlsBase = DefClass("C_VehicleControlsBase", C_VehicleControlsBase, C_StoreGroup)
GroupName2Class.VehicleControlsBase = C_VehicleControlsBase
local M = C_VehicleControlsBase

M.ctor = function(self)
	self.curTypeDriver = -1
	self.curTypeDriverStore = nil
	self.curShowDataDriver = nil
	self.currData = nil
	self.showing = false
	self.entered = false
	self.isAutoDriving = false
end

M.OnAwake = function(self)
	self.bindData.driverTabRect.OnRenderTab = self.CreateAction(self, "OnDriverRenderTab")
	self.showing = false
	self.entered = false
	self.msgEventsBase = {
		[gEventConstants.ON_PLAYER_MOVE_TO_SEAT_ON_VEHICLE] = self.CreateAction(self, "OnSwitchControl"),
		[gEventConstants.ON_PLAYER_DIRECTLY_SHIFT_SEAT_ON_VEHICLE] = self.CreateAction(self, "OnSwitchControl")
	}

	self.RegisterMessageEvents(self, self.msgEventsBase)
end

M.OnStart = function(self)
	self.TryEnter(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	self.msgEventsBase = nil

	self.TryExit(self)

	self.currData = nil
end

M.OnShow = function(self, panelId, data)
	self.showing = true
	self.currData = data

	self.TryEnter(self)
end

M.OnClose = function(self)
	self.TryExit(self)

	self.currData = nil
	self.showing = false
end

M.CheckReady = function(self)
	return self.showing and self.STATE_Started
end

M.TryEnter = function(self)
	if self.currData and self.CheckReady(self) and not self.entered then
		self.entered = true

		self.OnEnterVehicleFinish(self, self.currData)
	end
end

M.TryExit = function(self)
	if self.entered then
		self.entered = false

		self.OnExitVehicleStart(self, self.currData)
	end
end

M.OnEnterVehicleFinish = function(self, data)
	self.IsMainDrive = gDriveVehiclesManager:CheckPlayerMainDrive()

	self:DriverControlIn(data)
end

M.OnExitVehicleStart = function(self, data)
	self.DriverControlOut(self, data)

	self.IsMainDrive = false
end

M.OpenVehicleDriver = function(self, type, showData)
	self.curTypeDriver = type
	self.curShowDataDriver = showData
	self.bindData.driverTabRect.selectedIndex = self.curTypeDriver
end

M.StopVehicleDriver = function(self)
	if self.curTypeDriverStore then
		self.curTypeDriverStore:OnClose()
	end

	self.curTypeDriver = -1
	self.curTypeDriverStore = nil
	self.curShowDataDriver = nil
	self.bindData.driverTabRect.selectedIndex = self.curTypeDriver
end

M.OnDriverRenderTab = function(self, index, widget)
	self.curTypeDriverStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeDriverStore then
		if self.curTypeDriverStore.OnAutoDriveStateChange then
			self.curTypeDriverStore:OnAutoDriveStateChange(self.isAutoDriving)
		end

		self.curTypeDriverStore:OnShow(nil, self.curShowDataDriver)
	end
end

M.DriverControlIn = function(self, data)
	if self.IsMainDrive then
		self.OpenVehicleDriver(self, 0, data)
	else
		self.OpenVehicleDriver(self, 1, data)
	end
end

M.DriverControlOut = function(self, data)
	self.StopVehicleDriver(self)
end

M.OnSwitchControl = function(self)
	if not self.entered then
		return
	end

	local IsMainDrive = gDriveVehiclesManager:CheckPlayerMainDrive()

	if self.IsMainDrive ~= IsMainDrive then
		return
	end

	self.IsMainDrive = IsMainDrive

	self.DriverControlOut(self, self.currData)
	self.DriverControlIn(self, self.currData)
end

M.OnAutoDriveStateChange = function(self, driving)
	self.isAutoDriving = driving

	if self.curTypeDriverStore and self.curTypeDriverStore.OnAutoDriveStateChange then
		self.curTypeDriverStore:OnAutoDriveStateChange(driving)
	end
end
