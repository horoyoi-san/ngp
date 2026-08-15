C_VehicleInteractManager = DefClass("C_VehicleInteractManager", C_VehicleInteractManager)
local M = C_VehicleInteractManager
local JobClassConfig = LTConfig.UrbanJobJobClassConfig

function M:ctor()
	self.cs_manager = LX6.Drive.VehicleInteractManager.Instance
end

function M:OnUpdate()
	return
end

function M:CheckPlayerIsPolice()
	return gSpiritJobManager:CheckContainJobClassId(JobClassConfig.Police)
end

gVehicleInteractManager = gVehicleInteractManager or C_VehicleInteractManager.new()
