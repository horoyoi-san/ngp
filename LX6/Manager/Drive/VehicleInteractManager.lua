-- Original chunk: @Lua\LuaFiles\LX6\Manager\Drive\VehicleInteractManager.lua
-- Decompiled from: 00687_VehicleInteractManager.lua_6e94d665acc7.luajit

C_VehicleInteractManager = DefClass("C_VehicleInteractManager", C_VehicleInteractManager)
local M = C_VehicleInteractManager
local JobClassConfig = LTConfig.UrbanJobJobClassConfig

M.ctor = function(self)
	self.cs_manager = LX6.Drive.VehicleInteractManager.Instance
end

M.OnUpdate = function(self)
end

M.CheckPlayerIsPolice = function(self)
	return gSpiritJobManager:CheckContainJobClassId(JobClassConfig.Police)
end

gVehicleInteractManager = gVehicleInteractManager or C_VehicleInteractManager.new()
