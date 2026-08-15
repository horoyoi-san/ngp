local DriveUtils = LX6.Drive.DriveUtils
MapSubSystem_Vehicle = DefClass("MapSubSystem_Vehicle", MapSubSystem_Vehicle, MapSubSystemBase)
local M = MapSubSystem_Vehicle

function M:OnInit()
	self._policeCars = {}
	self._detectRangeCache = {}
	self._chasingCars = {}
	self._milkCars = {}
	self.GpsOffsetY = 2
end

function M:OnLogout()
	self._detectRangeCache = {}

	for vehicleId, element in pairs(self._policeCars) do
		element:Dispose()
	end

	for vehicleId, element in pairs(self._chasingCars) do
		element:Dispose()
	end

	for vehicleId, element in pairs(self._milkCars) do
		element:Dispose()
	end
end

function M:Tick()
	self:TickVehicleGps(self._policeCars, true, true)
	self:TickVehicleGps(self._chasingCars, true, false)
	self:TickVehicleGps(self._milkCars, false, false)
	self:TickVehicleRotation(self._policeCars)
end

function M:TickVehicleGps(vehicles, useOffsetY, rotate)
	local toRemove = nil

	for vehicleId, element in pairs(vehicles) do
		local vehicle = DriveUtils.GetBaseVehicle(vehicleId)

		if not vehicle then
			toRemove = toRemove or {}
			toRemove[#toRemove + 1] = vehicleId
		end
	end

	if toRemove then
		for _, vehicleId in ipairs(toRemove) do
			vehicles[vehicleId]:Dispose()

			vehicles[vehicleId] = nil
		end
	end
end

function M:TickVehicleRotation(vehicles)
	for vehicleId, element in pairs(vehicles) do
		local vehicle = DriveUtils.GetBaseVehicle(vehicleId)

		if vehicle then
			element.mData.eulerZ = -vehicle.gameObject.transform.eulerAngles.y
		end
	end
end

function M:AddPoliceCar(vehicleId, raidId)
	print_notice("AddPoliceCar", vehicleId, raidId)

	if self._policeCars[vehicleId] then
		print_warn("AddPoliceCar: vehicleId already exist", vehicleId)

		return
	end

	local element = MapElement.CreateLegacy(EMapElementType.PoliceCar, vehicleId, EMapSubSystemType.Vehicle, EMapViewMask.MiniMap + EMapViewMask.HudGps, raidId, 0)
	element.mData.sIconId = 28001090
	element.mData.eulerZ = 0
	element.fData.hudTIndex = 2
	element.mData.dontCull = true

	element:BindVehicle(vehicleId, nil, self.GpsOffsetY, true)
	element:SetVisible(true)

	if self._detectRangeCache[vehicleId] then
		local vehicle = DriveUtils.GetBaseVehicle(vehicleId)

		element:AddDetectRangeVehicleInfo(vehicle)
	end

	element:SetTraceInfo(EMapGTraceType.Other, 0, true)

	self._policeCars[vehicleId] = element
end

function M:RemovePoliceCar(vehicleId)
	print_notice("RemovePoliceCar", vehicleId)

	if not self._policeCars[vehicleId] then
		print_warn("RemovePoliceCar: vehicleId not exist", vehicleId)

		return
	end

	self._policeCars[vehicleId]:Dispose()

	self._policeCars[vehicleId] = nil
end

function M:AddTaskChaseCar(vehicleId, raidId, sIconId, viewMask, tracelayerSelf)
	print_notice("AddChasingCar", vehicleId, raidId)

	if self._chasingCars[vehicleId] then
		print_warn("AddPoliceCar: vehicleId already exist", vehicleId)

		return
	end

	local element = MapElement.CreateLegacy(EMapElementType.ChasingCar, vehicleId, EMapSubSystemType.Vehicle, viewMask, raidId, 0)
	element.mData.sIconId = sIconId
	element.fData.hudTIndex = 1

	element:BindVehicle(vehicleId, nil, self.GpsOffsetY, false)
	element:SetVisible(true)
	element:SetTraceInfoV2(EMapGTraceType.Main, tracelayerSelf, 0, true)

	self._chasingCars[vehicleId] = element
end

function M:RemoveTaskChaseCar(vehicleId)
	print_notice("RemovePoliceCar", vehicleId)

	if not self._chasingCars[vehicleId] then
		print_warn("RemovePoliceCar: vehicleId not exist", vehicleId)

		return
	end

	self._chasingCars[vehicleId]:Dispose()

	self._chasingCars[vehicleId] = nil
end

function M:AddMilkCar(vehicleId, raidId, sIconId)
	if self._milkCars[vehicleId] then
		print_warn("AddMilkCar: vehicleId already exist", vehicleId)

		return
	end

	local element = MapElement.CreateLegacy(EMapElementType.MilkCar, vehicleId, EMapSubSystemType.Vehicle, EMapViewMask.MiniMap + EMapViewMask.HudGps, raidId, 0)
	element.mData.sIconId = sIconId
	local position = Vector3.zero

	GpsHelper.GetVehiclePosition(vehicleId, nil, false, position)
	element:SetPosition(position)
	element:SetVisible(true)
	element:SetTraceInfo(EMapGTraceType.Other, 0, true)
	element:BindVehicle(vehicleId, nil, nil, false)

	self._milkCars[vehicleId] = element
end

function M:AddVehicleDetectRange(vehicleId)
	local element = self._policeCars[vehicleId]

	if not element then
		self._detectRangeCache[vehicleId] = true

		return
	end

	local vehicle = DriveUtils.GetBaseVehicle(vehicleId)

	element:AddDetectRangeVehicleInfo(vehicle)

	element.mData.sIconId = LTConfig.GpsConfig.EnemyVehiclleMiniMapIcon
end

function M:RemoveVehicleDetectRange(vehicleId)
	self._detectRangeCache[vehicleId] = nil
	local element = self._policeCars[vehicleId]

	if element then
		element.miniMapData.detectRangeInfo = nil
	end
end

function M:ContainsMilkCar(vehicleId)
	return self._milkCars[vehicleId] ~= nil
end

function M:RemoveMilkCar(vehicleId)
	if not self._milkCars[vehicleId] then
		return
	end

	self._milkCars[vehicleId]:Dispose()

	self._milkCars[vehicleId] = nil
end

return M
