C_ApplyCarManager = DefClass("C_ApplyCarManager", C_ApplyCarManager)
local M = C_ApplyCarManager
local DriveUtils = LX6.Drive.DriveUtils
local VehicleConfig = LTConfig.VehicleConfig
local CarShopConfig = LTConfig.CarShopConfig
local MessageConfig = LTConfig.MessageConfig

function M:ctor()
	self.vehiclesInIdentifyAreas = {}
	self.indoorCarShopId = {}
	self.carShopApplyCarAreas = {}
	self.lastPlayerDriveIntoCarShopVehicleTypeId = -1
	self.lastPlayerDriveIntoCarShopVehicleUId = -1
	self.carShopCfgId = 0
	self.currentCarUid = nil
	self.UnlockedVehicles = {}
	self.driveCarTypeId = 0
	self.hasEnterRepairShop = false
	self.VehicleGetway = {
		Drop = 2,
		Mass = 1
	}

	for index = 0, CarShopConfig.count - 1 do
		local curCarShopCfg = CarShopConfig.LoadAt(index)

		if curCarShopCfg ~= nil and curCarShopCfg.VehicleIdentifyAreaId then
			self.carShopApplyCarAreas[curCarShopCfg.VehicleIdentifyAreaId] = {
				cfgId = curCarShopCfg.Id
			}
		end
	end

	self:InitListener()
end

function M:InitListener()
	gMessageManager:AddMessageListener(gEventConstants.VEHICLE_ENTER_APPLY, function (eventId, data)
		self:OnVehicleEnterIdentifyArea(data)
	end)
	gMessageManager:AddMessageListener(gEventConstants.VEHICLE_EXIT_APPLY, function (eventId, data)
		self:OnVehicleLeaveIdentifyArea(data)
	end)
	gMessageManager:AddMessageListener(gEventConstants.VEHICLE_APPLY_CAPTURE, function (eventId, data)
		self:ControlCameraCaptureVehicle(data)
	end)
	gMessageManager:AddMessageListener(gEventConstants.MAP_CHANGE_TO_INDOOR_MAP, function (eventId, data)
		self:ChangeIndoor(data)
	end)
	gMessageManager:AddMessageListener(gEventConstants.LOADING_FINISHED, function ()
		self:LoadingFinish()
	end)
end

function M:GetCarShopByIndoor()
	self.indoorCarShopId = {}

	for index = 0, CarShopConfig.count - 1 do
		local cfg = CarShopConfig.LoadAt(index)

		if cfg then
			self.indoorCarShopId[cfg.CarShopId] = cfg.Id
		end
	end
end

function M:ChangeIndoor(data)
	if gMapManager.IndoorId == 0 then
		self.hasEnterRepairShop = false

		if self.carShopCfgId > 0 then
			self:DestoryVehicleModel()

			self.carShopCfgId = 0
			self.driveCarTypeId = 0
			self.currentCarUid = nil
		end
	end

	if not data.isSwitchScene and gLuaDataManager.gameStage ~= gGFConstant.GameStage.Loading then
		self:LoadingFinish()
	end
end

function M:LoadingFinish()
	if table.isNilOrEmpty(self.indoorCarShopId) then
		self:GetCarShopByIndoor()
	end

	if not self.hasEnterRepairShop and gMapManager.IndoorId > 0 then
		local vehicleId = gPlayerManager.infoMinor.bindData.VehicleInfo and gPlayerManager.infoMinor.bindData.VehicleInfo.ParkingVehicleId

		if vehicleId ~= 0 then
			local carShopId = self.indoorCarShopId[gMapManager.IndoorId]

			if carShopId then
				self.carShopCfgId = carShopId

				self:CreateVehicleModel(vehicleId, carShopId)

				self.hasEnterRepairShop = true
			end
		end
	end
end

function M:CreateVehicleModel(VehicleId, carShopId)
	local cfg = CarShopConfig.GetConfig(carShopId)

	if cfg == nil then
		return
	end

	local VehicleCfg = VehicleConfig.GetConfig(VehicleId)

	if not VehicleCfg then
		print_error("VehicleId在车辆表未找到，VehicleId = " .. VehicleId)
	end
end

function M:DestoryVehicleModel()
	local carShopCfgId = self.carShopCfgId
	local cfg = CarShopConfig.GetConfig(carShopCfgId)

	if cfg then
		local vehicle = LX6.Drive.DriveUtils.GetVehicleInScene(self.currentCarUid)

		if vehicle then
			vehicle.VehicleGameObject:SetActive(false)
		end

		if self.currentCarUid ~= nil then
			-- Nothing
		end
	end
end

function M:CheckCarShopCanEnterTask(carShopCfgId)
	local cfg = CarShopConfig.GetConfig(carShopCfgId)

	if cfg then
		if cfg.UnlockTask and cfg.UnlockTask > 0 then
			if cfg.UnlockTask and gTaskNodeManager:IsTaskEventSubmit(cfg.UnlockTask) or gTaskNodeManager:GetTaskLineState(cfg.UnlockTask) == gTaskLineState.Doing then
				return true
			end
		else
			return true
		end
	end

	return false
end

function M:OnVehicleEnterIdentifyArea(data)
	if data and data.ToTable then
		data = data:ToTable()
	end

	local carShopId = data.carShopId
	local cfg = CarShopConfig.GetConfig(carShopId)

	if cfg == nil then
		return
	end

	self.carShopCfgId = carShopId
	self.currentCarUid = gDriveVehiclesManager.cs_manager.CurDriveVehicleUid
	local vehicle = DriveUtils.GetVehicleInScene(self.currentCarUid)

	if vehicle == nil then
		return
	end

	if gPlayerManager.infoMinor.bindData.VehicleInfo then
		gPlayerManager.infoMinor.bindData.VehicleInfo.ParkingVehicleId = vehicle.typeId
	end

	self.driveCarTypeId = vehicle.typeId

	if not self.hasEnterRepairShop and self:CheckCarShopCanEnterTask(carShopId) and not gVehicleInteractManager.cs_manager.isInteracting then
		if self:VehicleCanBeApplied(self.driveCarTypeId) then
			local loadingInfoIndex = nil
			self.hasEnterRepairShop = true

			if data and data.callBack then
				if data.callBack.DynamicInvoke then
					data.callBack:DynamicInvoke()
				else
					data.callBack()
				end
			end

			loadingInfoIndex = gLoadingManager:Quick_CarShop(carShopId, self.currentCarUid, true, function ()
				gClientToGameSceneDelegate:AskTeleportToParkingWaypoint(carShopId).Callback = function (err, data)
					if err == MessageConfig.Ok then
						if self.currentCarUid ~= nil then
							local vehicleUnit = DriveUtils.GetVehicleInScene(self.currentCarUid)

							if vehicleUnit and vehicleUnit.seats then
								vehicleUnit.seats:EnableDoorDetector(false)
							end
						end

						gLoadingManager:StopWaitLoading(loadingInfoIndex)
					else
						self.hasEnterRepairShop = false
					end
				end
			end, function ()
				if self.currentCarUid ~= nil then
					local baseVehicle = DriveUtils.GetBaseVehicle(self.currentCarUid)

					if baseVehicle then
						baseVehicle:SetEnterVehicleEnable(false)
					end
				end
			end)

			return
		end

		gDialogManager:ShowGeneralDialog(VehicleConfig.VehicleGetFailDialog, gDialogSource.Vehicle)
	end
end

function M:OnVehicleLeaveIdentifyArea(data)
	local carShopCfgId = tonumber(data)
	gApplyCarManager.driveCarTypeId = 0
	self.hasEnterRepairShop = true
	local loadingInfoIndex = nil
	loadingInfoIndex = gLoadingManager:Quick_CarShop(carShopCfgId, self.currentCarUid, false, function ()
		gClientToGameSceneDelegate:AskTeleportToLeavingWaypoint(carShopCfgId).Callback = function ()
			gLoadingManager:StopWaitLoading(loadingInfoIndex)

			local baseVehicle = DriveUtils.GetBaseVehicle(self.currentCarUid)

			if baseVehicle then
				baseVehicle:SetEnterVehicleEnable(true)
			end

			self.carShopCfgId = 0
			self.currentCarUid = nil
			self.hasEnterRepairShop = false

			if gPlayerManager.infoMinor.bindData.VehicleInfo then
				gPlayerManager.infoMinor.bindData.VehicleInfo.ParkingVehicleId = 0
			end
		end
	end, function ()
		self.hasEnterRepairShop = false
	end)
end

function M:ControlCameraCaptureVehicle(str)
	local inputString = str
	local data = {}

	for key, value in string.gmatch(inputString, "(%w+)%s-=%s-(%w+)") do
		data[key] = tonumber(value) or value
	end

	if type(data.openCapture) == "string" then
		if data.openCapture == "true" then
			data.openCapture = true
		elseif data.openCapture == "false" then
			data.openCapture = false
		end
	end

	if not data.openCapture then
		gCS.CameraDataMgr.cinemachineManager:EnableFixCamera(false, Vector3.New(0, 0, 0), Vector3.New(0, 0, 0), 0, 0)

		return
	end

	local carShopId = data.carShopId
	local cfg = CarShopConfig.GetConfig(carShopId)

	if cfg then
		local vehicle = DriveUtils.GetVehicleInScene(self.currentCarUid)

		if not vehicle then
			print_error("ApplyCarManager-当前车库内不存在车辆  VehicleUid = " .. self.currentCarUid)

			return
		end

		local changedLocalCoordinate = Vector3.New(cfg.CameraPos[1], cfg.CameraPos[2], cfg.CameraPos[3])
		local changedCoordinate = vehicle.CameraTargetPos.right * changedLocalCoordinate.x + vehicle.CameraTargetPos.up * changedLocalCoordinate.y + vehicle.CameraTargetPos.forward * changedLocalCoordinate.z
		local worldCameraPos = Vector3.New(vehicle.CameraTargetPos.position.x + changedCoordinate.x, vehicle.CameraTargetPos.position.y + changedCoordinate.y, vehicle.CameraTargetPos.position.z + changedCoordinate.z)
		local changedCoordNorm = Vector3.Normalize(changedCoordinate)
		local yaw = math.atan2(changedCoordNorm.x * -1, changedCoordNorm.z * -1) * 180 / math.pi
		local pitch = math.asin(changedCoordNorm.y) * 180 / math.pi
		local worldCameraEuler = Vector3.New(pitch, yaw, 0)

		gCS.CameraDataMgr.cinemachineManager:EnableFixCamera(true, worldCameraPos, worldCameraEuler, 60, LX6.Cinemachine.EVcamPriority.GamePlay)
	end
end

function M:VehicleCanBeApplied(vehicleTypeId)
	local vehicleCfgData = VehicleConfig.GetConfig(vehicleTypeId)

	if vehicleCfgData then
		return vehicleCfgData.VehicleCanGet and vehicleCfgData.VehicleGetway == self.VehicleGetway.Mass or false
	end

	return false
end

function M:SyncAllUnlockedVehicles(unlockedVehicles)
	self.UnlockedVehicles = unlockedVehicles
end

function M:CheckPlayerAlreadyHasVehicle(vehicleTypeId)
	local UnlockedVehicles = self.UnlockedVehicles

	if not table.isNilOrEmpty(UnlockedVehicles) then
		for i = 1, UnlockedVehicles.Count do
			if UnlockedVehicles[i].Id == vehicleTypeId then
				return true
			end
		end
	end

	return false
end

function M:AddUnlockVehicle(vehicleTypeId)
	local hasVehicle = false

	if not table.isNilOrEmpty(self.UnlockedVehicles) then
		for i = 1, self.UnlockedVehicles.Count do
			if self.UnlockedVehicles[i].Id == vehicleTypeId then
				hasVehicle = true
			end
		end
	end

	if hasVehicle then
		return
	end

	local info = {
		Id = vehicleTypeId
	}

	table.insert(self.UnlockedVehicles, info)

	self.UnlockedVehicles.Count = self.UnlockedVehicles.Count + 1
	self.UnlockedVehicles.Length = self.UnlockedVehicles.Length + 1
end

gApplyCarManager = gApplyCarManager or C_ApplyCarManager.new()
