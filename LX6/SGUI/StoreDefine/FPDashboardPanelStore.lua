-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FPDashboardPanelStore.lua
-- Decompiled from: 01868_FPDashboardPanelStore.lua_5bcfabe7b308.luajit

C_FPDashboardPanelStore = DefClass("C_FPDashboardPanelStore", C_FPDashboardPanelStore, C_StoreGroup)
GroupName2Class.FPDashboardPanelStore = C_FPDashboardPanelStore
local M = C_FPDashboardPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
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
	self.vehicleCs = gDriveVehiclesManager:GetBaseVehicle(gDriveVehiclesManager.cs_manager.CurDriveVehicleUid)
	self.lastRotation = self.bindData.Speedometer.transform.localRotation
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnUpdate = function(self)
	local vehicle = self.vehicleCs

	if not vehicle then
		return
	end

	local speed = math.abs(vehicle.Speed) * 3.6
	local maxSpeed = vehicle.MaxSpeed * 3.6
	speed = math.min(math.floor(speed + 0.5), maxSpeed)
	speed = math.floor(speed + 0.5)
	local rotationZ = -speed / 200 * 230 + 2
	self.bindData.Speedometer.transform.localRotation = Quaternion.Euler(self.lastRotation.x, self.lastRotation.y, rotationZ)
	self.lastRotation = self.bindData.Speedometer.transform.localRotation
end
