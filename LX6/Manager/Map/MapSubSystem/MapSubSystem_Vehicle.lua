-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_Vehicle.lua
-- Decompiled from: 02311_MapSubSystem_Vehicle.lua_2c29b79e2426.luajit

local DriveUtils = LX6.Drive.DriveUtils
MapSubSystem_Vehicle = DefClass("MapSubSystem_Vehicle", MapSubSystem_Vehicle, MapSubSystemBase)
local M = MapSubSystem_Vehicle

M.OnInit = function(self)
	self._policeCars = {}
	self._detectRangeCache = {}
	self._chasingCars = {}
	self._milkCars = {}
	self._taskPlayerVehicleGps = {}
	self.GpsOffsetY = 2
	self.showPlayerVehicleHP = false
	self.miniMapInFightActivate = false
	self.miniMapArrestActivate = false
	self.showVehicleCountdown = false
	self.vehicleCountdownEscapeTextId = 0
	self.vehicleCountdownArrestTextId = 0
	self.vehicleCountdownShowProgressBar = false
	self.vehicleCountdownEnableBlink = false
	self.vehicleCountdownShowTimeText = false

	self.InitEventHandlers(self)
end

M.InitEventHandlers = function(self)
	self.eventHandlers = {
		[gEventConstants.VEHICLE_CHASE_INFO_CHANGE] = self:CreateAction("OnVehicleChangeInfoChange"),
		[gEventConstants.ENTER_BASE_VEHICLE_FINISH] = self:CreateAction("OnPlayerEnterVehicleFinish"),
		[gEventConstants.EXIT_BASE_VEHICLE_FINISH] = self:CreateAction("OnPlayerExitVehicleFinish")
	}

	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

M.OnLogout = function(self)
	self._detectRangeCache = {}

	for vehicleId, element in pairs(self._policeCars) do
		element.Dispose(element)
	end

	table.clear(self._policeCars)

	for vehicleId, element in pairs(self._chasingCars) do
		element.Dispose(element)
	end

	table.clear(self._chasingCars)

	for vehicleId, element in pairs(self._milkCars) do
		element.Dispose(element)
	end

	table.clear(self._milkCars)

	if self._taskPlayerVehicleGps then
		for vehicleUid, element in pairs(self._taskPlayerVehicleGps) do
			element.Dispose(element)
		end

		table.clear(self._taskPlayerVehicleGps)
	end
end

M.Tick = function(self)
	self.TickVehicleGps(self, self._policeCars, true, true)
	self.TickVehicleGps(self, self._chasingCars, true, false)
	self.TickVehicleGps(self, self._milkCars, false, false)
	self.TickVehicleRotation(self, self._policeCars)
end

M.TickVehicleGps = function(self, vehicles, useOffsetY, rotate)
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

M.TickVehicleRotation = function(self, vehicles)
	for vehicleId, element in pairs(vehicles) do
		local vehicle = DriveUtils.GetBaseVehicle(vehicleId)

		if vehicle and vehicle.gameObject and not gCS.LuaUtils.IsNull(vehicle.gameObject) and vehicle.gameObject.transform then
			element.mData.eulerZ = -vehicle.gameObject.transform.eulerAngles.y
		end
	end
end

M.OnFlushData = function(self)
	self.showPlayerVehicleHP = false
	self.showAiVehicleHP = false
	self.miniMapInFightActivate = false
	self.miniMapArrestActivate = false
	self.showVehicleCountdown = false
	self.vehicleCountdownEscapeTextId = 0
	self.vehicleCountdownArrestTextId = 0
	self.vehicleCountdownShowProgressBar = false
	self.vehicleCountdownEnableBlink = false
	self.vehicleCountdownShowTimeText = false

	for groupId, vehicleChaseInfo in pairs(gVehicleGamePlayManager.vehicleChaseInfos) do
		local configId = vehicleChaseInfo.configId
		local chaseConfig = LTConfig.VehicleChaseConfig.GetConfig(configId)

		if chaseConfig then
			self.showVehicleCountdown = chaseConfig.ShowVehicleCountdown or self.showVehicleCountdown
			self.vehicleCountdownEscapeTextId = chaseConfig.VehicleCountdownEscapeTextId or self.vehicleCountdownEscapeTextId
			self.vehicleCountdownArrestTextId = chaseConfig.VehicleCountdownArrestTextId or self.vehicleCountdownArrestTextId
			self.vehicleCountdownShowProgressBar = chaseConfig.VehicleCountdownShowProgressBar or self.vehicleCountdownShowProgressBar
			self.vehicleCountdownEnableBlink = chaseConfig.VehicleCountdownEnableBlink or self.vehicleCountdownEnableBlink
			self.vehicleCountdownShowTimeText = chaseConfig.VehicleCountdownShowTimeText or self.vehicleCountdownShowTimeText
			self.showPlayerVehicleHP = chaseConfig.ShowPlayerVehicleHP or self.showPlayerVehicleHP
			self.showAiVehicleHP = chaseConfig.ShowAiVehicleHP or self.showAiVehicleHP
			self.miniMapInFightActivate = chaseConfig.MiniMapInFightActivate or self.miniMapInFightActivate
			self.miniMapArrestActivate = chaseConfig.MiniMapArrestActivate or self.miniMapArrestActivate

			if vehicleChaseInfo.vehicles then
				for vehicleId, mode in pairs(vehicleChaseInfo.vehicles) do
					local modeId = 0

					if mode ~= UX.Game.VehicleChaseMode.Search then
						modeId = chaseConfig.SearchModeId
					elseif mode ~= UX.Game.VehicleChaseMode.Chase then
						modeId = chaseConfig.ChaseModeId
					end

					if modeId == 0 then
						local modeConfig = LTConfig.VehicleChaseModeConfig.GetConfig(modeId)

						if modeConfig then
							if not self._policeCars[vehicleId] then
								self.AddPoliceCar(self, vehicleId, gRaidDataManager.RaidId)
							end

							self.SetElementWithVehicleChaseModeId(self, self._policeCars[vehicleId], modeId, vehicleId)
						elseif self._policeCars[vehicleId] then
							self.RemovePoliceCar(self, vehicleId)
						end
					elseif self._policeCars[vehicleId] then
						self.RemovePoliceCar(self, vehicleId)
					end
				end
			end
		end
	end

	local miniMapStore = gStoreManager:GetStoreGroup("MiniMapPanelStore")

	if miniMapStore then
		miniMapStore.RefreshInFightCtrl(miniMapStore)
		miniMapStore.UpdateArrestMode(miniMapStore)
	end
end

M.GetMiniMapInFightActivate = function(self)
	return self.miniMapInFightActivate or false
end

M.GetMiniMapArrestActivate = function(self)
	return self.miniMapArrestActivate or false
end

M.TryShowVehicleCountdown = function(self, param)
	if not self.showVehicleCountdown then
		return
	end

	if param.isRed then
		param.textId = self.vehicleCountdownArrestTextId
	else
		param.textId = self.vehicleCountdownEscapeTextId
	end

	param.showTimeText = self.vehicleCountdownShowTimeText
	param.enableBlink = self.vehicleCountdownEnableBlink
	param.showProgressBar = self.vehicleCountdownShowProgressBar

	gPanelManager:CheckShow(gPanelId.VEHICLE_COUNTDOWN, param)
end

M.SetElementWithVehicleChaseModeId = function(self, element, modeId, vehicleId)
	if not element then
		return
	end

	if element.gpsData.chaseModeId ~= modeId then
		return
	end

	element.gpsData.chaseModeId = modeId
	local modeConfig = LTConfig.VehicleChaseModeConfig.GetConfig(modeId)

	if modeConfig then
		local viewMask = EMapViewMask.None

		if modeConfig.ShowInHUD then
			viewMask = viewMask + EMapViewMask.HudGps
		end

		if modeConfig.ShowInMiniMap then
			viewMask = viewMask + EMapViewMask.MiniMap
		end

		element.SetViewMask(element, viewMask)

		if modeConfig.HUDMaxShowDistance == 0 then
			element.gpsData.tmp_HudAutoShowDistance = modeConfig.HUDMaxShowDistance
		else
			element.gpsData.tmp_HudAutoShowDistance = nil
		end

		if modeConfig.ShowMiniMapDetectRange then
			if not element.miniMapData.detectRangeInfo then
				local vehicle = DriveUtils.GetBaseVehicle(vehicleId)

				element.AddDetectRangeVehicleInfo(element, vehicle)
			end

			element.miniMapData.detectRangeInfo.radius = modeConfig.MiniMapDetectRangeLength
			element.miniMapData.detectRangeInfo.angle = modeConfig.MiniMapDetectRangeAngle
		else
			element.miniMapData.detectRangeInfo = nil
		end
	end
end

M.AddPoliceCar = function(self, vehicleId, raidId)
	print_notice("AddPoliceCar", vehicleId, raidId)

	if self._policeCars[vehicleId] then
		print_warn("AddPoliceCar: vehicleId already exist", vehicleId)

		return
	end

	local element = MapElement.CreateLegacy(EMapElementType.PoliceCar, vehicleId, EMapSubSystemType.Vehicle, EMapViewMask.MiniMap + EMapViewMask.HudGps, raidId, 0)
	element.mData.sIconId = LTConfig.GpsConfig.EnemyVehiclleMiniMapIcon
	element.mData.eulerZ = 0
	element.fData.hudTIndex = 2
	element.mData.dontCull = true
	element.gpsData.tmp_HudAutoShowDistance = 150

	element.BindVehicle(element, vehicleId, nil, self.GpsOffsetY, true)
	element.SetVisible(element, true)

	if self._detectRangeCache[vehicleId] then
		local vehicle = DriveUtils.GetBaseVehicle(vehicleId)

		element.AddDetectRangeVehicleInfo(element, vehicle)
	end

	element.SetTraceInfo(element, EMapGTraceType.Other, 0, true)

	element.mData.ignoreIndoorPenetration = true
	self._policeCars[vehicleId] = element
end

M.RemovePoliceCar = function(self, vehicleId)
	print_notice("RemovePoliceCar", vehicleId)

	if not self._policeCars[vehicleId] then
		print_warn("RemovePoliceCar: vehicleId not exist", vehicleId)

		return
	end

	self._policeCars[vehicleId]:Dispose()

	self._policeCars[vehicleId] = nil
end

M.AddTaskChaseCar = function(self, vehicleId, raidId, sIconId, viewMask, tracelayerSelf)
	print_notice("AddChasingCar", vehicleId, raidId)

	if self._chasingCars[vehicleId] then
		print_warn("AddPoliceCar: vehicleId already exist", vehicleId)

		return
	end

	local element = MapElement.CreateLegacy(EMapElementType.ChasingCar, vehicleId, EMapSubSystemType.Vehicle, viewMask, raidId, 0)
	element.mData.sIconId = sIconId
	element.fData.hudTIndex = 1
	element.gpsData.tmp_HudAutoShowDistance = 150

	element.BindVehicle(element, vehicleId, nil, self.GpsOffsetY, false)
	element.SetVisible(element, true)
	element.SetTraceInfoV2(element, EMapGTraceType.Main, tracelayerSelf, 0, true)

	self._chasingCars[vehicleId] = element
end

M.RemoveTaskChaseCar = function(self, vehicleId)
	print_notice("RemovePoliceCar", vehicleId)

	if not self._chasingCars[vehicleId] then
		print_warn("RemovePoliceCar: vehicleId not exist", vehicleId)

		return
	end

	self._chasingCars[vehicleId]:Dispose()

	self._chasingCars[vehicleId] = nil
end

M.IsLocalPlayerInVehicle = function(self, vehicleUid)
	local driveManager = gDriveVehiclesManager and gDriveVehiclesManager.cs_manager

	return driveManager and driveManager.isDriveMode and ulong.equals(driveManager.CurDriveVehicleUid, vehicleUid) or false
end

M.AddTaskPlayerVehicleGps = function(self, vehicleUid, raidId, iconId)
	if not vehicleUid or ulong.equals(vehicleUid, 0) or not raidId or raidId ~= 0 or not iconId or iconId ~= 0 then
		return
	end

	self._taskPlayerVehicleGps = self._taskPlayerVehicleGps or {}
	local element = self._taskPlayerVehicleGps[vehicleUid]

	if element then
		element.mData.sIconId = iconId

		element.SetRaidId(element, raidId)
		element.SetVisible(element, not self.IsLocalPlayerInVehicle(self, vehicleUid))

		return
	end

	local gpsId = "TaskPlayerVehicle_" .. ulong.tostring(vehicleUid)
	element = MapElement.CreateLegacy(EMapElementType.CommonGps, gpsId, EMapSubSystemType.Vehicle, EMapViewMask.AllSgui, raidId)
	element.mData.sIconId = iconId
	element.bigMapData.unselectable = true

	element.BindVehicle(element, vehicleUid, nil, self.GpsOffsetY, false)
	element.SetTraceInfo(element, EMapGTraceType.Other, 0, true)
	element.SetVisible(element, not self.IsLocalPlayerInVehicle(self, vehicleUid))

	self._taskPlayerVehicleGps[vehicleUid] = element
end

M.RemoveTaskPlayerVehicleGps = function(self, vehicleUid)
	if not self._taskPlayerVehicleGps then
		return
	end

	local element = self._taskPlayerVehicleGps[vehicleUid]

	if not element then
		return
	end

	element.Dispose(element)

	self._taskPlayerVehicleGps[vehicleUid] = nil
end

M.SetTaskPlayerVehicleGpsVisible = function(self, vehicleUid, visible)
	if not self._taskPlayerVehicleGps then
		return
	end

	local element = self._taskPlayerVehicleGps[vehicleUid]

	if element then
		element.SetVisible(element, visible)
	end
end

M.OnPlayerEnterVehicleFinish = function(self, eventId, vehicleUid)
	self.SetTaskPlayerVehicleGpsVisible(self, vehicleUid, false)
end

M.OnPlayerExitVehicleFinish = function(self, eventId, vehicleUid)
	self.SetTaskPlayerVehicleGpsVisible(self, vehicleUid, true)
end

M.AddMilkCar = function(self, vehicleId, raidId, sIconId)
	if self._milkCars[vehicleId] then
		print_warn("AddMilkCar: vehicleId already exist", vehicleId)

		return
	end

	local element = MapElement.CreateLegacy(EMapElementType.MilkCar, vehicleId, EMapSubSystemType.Vehicle, EMapViewMask.MiniMap + EMapViewMask.HudGps, raidId, 0)
	element.mData.sIconId = sIconId
	element.gpsData.removeGpsRange = LTConfig.GpsConfig.CallCarGpsRemove
	local position = Vector3.zero

	GpsHelper.GetVehiclePosition(vehicleId, nil, false, position)
	element.SetPosition(element, position)
	element.SetVisible(element, true)
	element.SetTraceInfo(element, EMapGTraceType.Other, 0, true)
	element.BindVehicle(element, vehicleId, nil, , false)

	self._milkCars[vehicleId] = element
end

M.AddVehicleDetectRange = function(self, vehicleId)
	local element = self._policeCars[vehicleId]

	if not element then
		self._detectRangeCache[vehicleId] = true

		return
	end

	local vehicle = DriveUtils.GetBaseVehicle(vehicleId)

	element.AddDetectRangeVehicleInfo(element, vehicle)

	element.mData.sIconId = LTConfig.GpsConfig.EnemyVehiclleMiniMapIcon
end

M.RemoveVehicleDetectRange = function(self, vehicleId)
	self._detectRangeCache[vehicleId] = nil
	local element = self._policeCars[vehicleId]

	if element then
		element.miniMapData.detectRangeInfo = nil
	end
end

M.ShowVehicleGpsInMiniMap = function(self, vehicleId)
	local element = self._policeCars[vehicleId]

	if element then
		element.AddViewMask(element, EMapViewMask.MiniMap)
	end
end

M.HideVehicleGpsInMiniMap = function(self, vehicleId)
	local element = self._policeCars[vehicleId]

	if element then
		element.RemoveViewMask(element, EMapViewMask.MiniMap)
	end
end

M.ShowVehicleGpsInHUD = function(self, vehicleId)
	local element = self._policeCars[vehicleId]

	if element then
		element.AddViewMask(element, EMapViewMask.HudGps)
	end
end

M.HideVehicleGpsInHUD = function(self, vehicleId)
	local element = self._policeCars[vehicleId]

	if element then
		element.RemoveViewMask(element, EMapViewMask.HudGps)
	end
end

M.ContainsMilkCar = function(self, vehicleId)
	return self._milkCars[vehicleId] == nil
end

M.RemoveMilkCar = function(self, vehicleId)
	if not self._milkCars[vehicleId] then
		return
	end

	self._milkCars[vehicleId]:Dispose()

	self._milkCars[vehicleId] = nil
end

M.OnVehicleChangeInfoChange = function(self)
	self.OnFlushData(self)
end

return M
