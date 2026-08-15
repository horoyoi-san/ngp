local MessageConfig = LTConfig.MessageConfig
local HouseConfig = LTConfig.HouseConfig
local VehicleConfig = LTConfig.VehicleConfig
local SpawnVehicleParam = LX6.Drive.SpawnVehicleParam
local DriveUtils = LX6.Drive.DriveUtils
local M = {
	HasEnterGarage = false,
	VehicleId = 0,
	CurrentHouseId = 0,
	CarprotState = {
		Parking = 2,
		OpenInfo = 1,
		Leave = 0
	},
	parkinginfolist = {},
	currentParkingInfo = {},
	OnInit = function (self)
		gMessageManager:AddMessageListener(gEventConstants.BUY_HOUSE_CARPORT_STATE, function (_, data)
			self:CheckCarprotState(data:ToTable())
		end)
		gMessageManager:AddMessageListener(gEventConstants.BUY_HOUSE_ENTER_GARAGE, function (_, data)
			self:CheckEnterGarage(data)
		end)
		gMessageManager:AddMessageListener(gEventConstants.BUY_HOUSE_EXIT_GARAGE, function (_, data)
			self:LeaveGarage(data)
		end)
		gMessageManager:AddMessageListener(gEventConstants.MAP_CHANGE_TO_INDOOR_MAP, function (eventId, data)
			self:ChangeIndoor(data)
		end)
		gMessageManager:AddMessageListener(gEventConstants.LOADING_FINISHED, function (eventId, data)
			self:LoadingFinish()
		end)
	end,
	OnBeforeSwitchScene = function (self, switchType)
		if switchType and switchType == gSwitchSceneType.Reconnect then
			if gPlayerManager.infoMinor.bindData.housesInfo.HouseInfoList.Count == 0 then
				self:LeaveGarage()
			end
		elseif switchType == gSwitchSceneType.KickToLogin then
			self.CurrentHouseId = 0
			self.VehicleId = 0
			self.parkinginfolist = {}
			self.currentParkingInfo = {}
			self.HasEnterGarage = false
		end
	end,
	CheckEnterGarage = function (self, houseId)
		if self.HasEnterGarage then
			return
		end

		self.CurrentHouseId = houseId
		local vehicle = gDriveVehiclesManager.cs_manager:GetBaseVehicle(gDriveVehiclesManager.cs_manager.CurDriveVehicleUid)

		if vehicle == nil then
			print_error("车辆进入车库失败，GetVehicle找不到对应车辆数据, CurDriveVehicleUid = " .. gDriveVehiclesManager.cs_manager.CurDriveVehicleUid)

			return
		end

		self.VehicleId = vehicle.vehicleControl.typeId

		if not gApplyCarManager:VehicleCanBeApplied(self.VehicleId) then
			gDialogManager:ShowGeneralDialog(HouseConfig.Dialog_EnterGarage_CarCannotBuy, gDialogSource.Vehicle)

			return
		end

		self:CheckHouseInfo(houseId)

		if table.isNilOrEmpty(self.parkinginfolist[houseId]) then
			print_warn("当前house未购买或者house数据有问题  houseId = " .. houseId)

			return
		end

		self.currentParkingInfo = self.parkinginfolist[houseId]

		local function askHouseParking()
			self:AskHouseParking(self.VehicleId, function ()
				self.HasEnterGarage = true

				if vehicle then
					vehicle:SetEnterVehicleEnable(false)
				end

				self:CreateAllVehicleModel()
			end)
		end

		local alreadyBought = gApplyCarManager:CheckPlayerAlreadyHasVehicle(self.VehicleId)

		if alreadyBought then
			askHouseParking()
		else
			gPanelManager:CheckShow(gPanelId.S_APPLY_CAR, {
				vehicleId = self.VehicleId,
				callback = function ()
					if gApplyCarManager:CheckPlayerAlreadyHasVehicle(self.VehicleId) then
						askHouseParking()
					end
				end
			})
		end
	end,
	LeaveGarage = function (self, parkingId)
		local houseId = self.CurrentHouseId

		if houseId and not table.isNilOrEmpty(self.currentParkingInfo) and not table.isNilOrEmpty(self.currentParkingInfo.ParkingInfo) then
			local vehicleUid = self.currentParkingInfo.ParkingVehicleUid[parkingId]
			local vehicle = gDriveVehiclesManager.cs_manager:GetBaseVehicle(vehicleUid)

			if vehicle ~= nil and vehicle.vehicleControl ~= nil and vehicle.vehicleControl.seats ~= nil then
				vehicle.vehicleControl.seats:EnableDoorDetector(true)
				gVehicleGamePlayManager.cs_manager:RegisterSummonVehicle(vehicleUid)
			end

			self:PlayLoadingCutscene(houseId, parkingId, false, vehicleUid, function ()
				self:DestoryAllVehicleModel()

				self.HasEnterGarage = false
				self.CurrentHouseId = 0
				self.VehicleId = 0
				self.currentParkingInfo = {}

				gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
					signalKey = "ExitGarageRefreshButton"
				})
			end)
		end
	end
}

function M:CheckCarprotState(data)
	local parkingId = tonumber(data.parkingId)

	if data.carprotState == M.CarprotState.Parking then
		local args = {
			showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.CallPhone,
			secondShowType = gClientConst.CallPhoneShowType.Call_Car,
			onConfirmCallback = function (newVehicleId)
				self:SwitchCarprotVehicle(parkingId, 0, newVehicleId)
			end
		}

		gPanelManager:CheckShow(gPanelId.S_HALF_PHONE_APP_HOME_PANEL, args)
	elseif data.carprotState == M.CarprotState.Leave then
		self:LeaveGarage(parkingId)
	elseif data.carprotState == M.CarprotState.OpenInfo then
		local vehicleId = self.currentParkingInfo.ParkingInfo[parkingId]

		local function callback(newVehicleId)
			if newVehicleId ~= nil then
				self:SwitchCarprotVehicle(parkingId, vehicleId, newVehicleId)
			end
		end

		gPanelManager:CheckShow(gPanelId.S_APPLY_CAR, {
			isExchange = true,
			banApply = true,
			vehicleId = vehicleId,
			callback = callback,
			banVehicleIdList = {
				vehicleId
			}
		})
	end
end

function M:ChangeIndoor(data)
	if gMapManager.IndoorId == 0 then
		if self.HasEnterGarage then
			self:DestoryAllVehicleModel()

			self.HasEnterGarage = false
		end

		return
	end

	if self.HasEnterGarage then
		return
	end

	if table.isNilOrEmpty(self.GarageIndoorIdList) then
		self.garageIndoorIdList = {}

		for i = 0, HouseConfig.count - 1 do
			local cfg = HouseConfig.LoadAt(i)

			if cfg.GarageIndoorId then
				self.garageIndoorIdList[cfg.GarageIndoorId] = cfg.Id

				table.insert(self.garageIndoorIdList, cfg.ParkingSpaceWaypoints)
			end
		end
	end

	if not data.isSwitchScene and gLuaDataManager.gameStage ~= gGFConstant.GameStage.Loading then
		self:LoadingFinish()
	end
end

function M:LoadingFinish()
	if not self.HasEnterGarage and not table.isNilOrEmpty(self.garageIndoorIdList) and self.garageIndoorIdList[gMapManager.IndoorId] then
		self.CurrentHouseId = self.garageIndoorIdList[gMapManager.IndoorId]

		self:CheckHouseInfo(self.CurrentHouseId)
		self:CreateAllVehicleModel(true)

		self.HasEnterGarage = true
	end
end

function M:TeleportToHouseGarage(houseId, cParkIndex, cb)
	local cfg = HouseConfig.GetConfig(houseId)

	if cfg then
		gClientToGameDelegate:AskTeleportToHouseGarage(houseId, cParkIndex).Callback = function (err, data)
			if err == MessageConfig.Ok then
				self.HasEnterGarage = true

				cb()
			end
		end
	end
end

function M:TeleportFromHouseGarage(houseId, cParkIndex, cb)
	local cfg = HouseConfig.GetConfig(houseId)

	if cfg then
		gClientToGameDelegate:AskTeleportFromHouseGarage(houseId, cParkIndex).Callback = function (err, data)
			if err == MessageConfig.Ok then
				cb()
			else
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end
end

function M:SwitchCarprotVehicle(parkingId, vehicleId, newVehicleId)
	local oldVehicleHouseId = 0
	local oldVehicleParkingId = 0

	if table.isNilOrEmpty(self.parkinginfolist[self.CurrentHouseId]) then
		print_warn("当前house未购买或者house数据有问题，houseId = " .. self.CurrentHouseId)

		return
	end

	if self.parkinginfolist[self.CurrentHouseId].ParkingInfo then
		for i, saveVehicleId in pairs(self.parkinginfolist[self.CurrentHouseId].ParkingInfo) do
			if saveVehicleId == newVehicleId then
				oldVehicleHouseId = self.CurrentHouseId
				oldVehicleParkingId = i

				break
			end
		end
	end

	local changeParkList = {}
	local oldView = {}
	local newView = {}

	if vehicleId > 0 then
		oldView = {
			VehicleId = vehicleId,
			HouseId = oldVehicleHouseId,
			ParkingSpaceIndex = oldVehicleParkingId - 1 >= 0 and oldVehicleParkingId - 1 or 0
		}

		table.insert(changeParkList, oldView)
	end

	if newVehicleId and newVehicleId > 0 then
		newView = {
			VehicleId = newVehicleId,
			HouseId = self.CurrentHouseId,
			ParkingSpaceIndex = parkingId - 1
		}

		table.insert(changeParkList, newView)
	end

	gClientToGameDelegate:AskHouseMoveParkingSpace(changeParkList).Callback = function (err, data)
		if err == MessageConfig.Ok then
			if oldVehicleParkingId > 0 then
				self:DestoryVehicleModel(oldVehicleParkingId)

				if vehicleId and vehicleId > 0 then
					self:CreateVehicleModel(oldVehicleParkingId, vehicleId, self.CurrentHouseId)
				end

				self.currentParkingInfo.ParkingInfo[oldVehicleParkingId] = vehicleId ~= 0 and vehicleId or nil
				self.parkinginfolist[self.CurrentHouseId].ParkingInfo[oldVehicleParkingId] = vehicleId ~= 0 and vehicleId or nil
			end

			if self.currentParkingInfo.ParkingInfo[parkingId] and self.currentParkingInfo.ParkingInfo[parkingId] > 0 then
				self:DestoryVehicleModel(parkingId)
			end

			if newVehicleId and newVehicleId > 0 then
				self:CreateVehicleModel(parkingId, newVehicleId, self.CurrentHouseId)
				gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
					signalKey = "ParkingGarageSuccess"
				})
			end

			self.currentParkingInfo.ParkingInfo[parkingId] = newVehicleId ~= 0 and newVehicleId or nil
			self.parkinginfolist[self.CurrentHouseId].ParkingInfo[parkingId] = newVehicleId ~= 0 and newVehicleId or nil
			self.VehicleId = newVehicleId
		end
	end
end

function M:CheckHouseInfo(houseId)
	local housesInfo = gPlayerManager.infoMinor.bindData.housesInfo.HouseInfoList

	if table.isNilOrEmpty(self.parkinginfolist) and housesInfo and housesInfo.Count > 0 then
		self.parkinginfolist = {}

		for i = 1, housesInfo.Count do
			local houseView = {
				HouseId = housesInfo[i].HouseId
			}

			if table.isNilOrEmpty(houseView.ParkingInfo) then
				houseView.ParkingInfo = {}
			end

			if not table.isNilOrEmpty(housesInfo[i].ParkingSpaceVehicleIdDict) then
				for t, v in pairs(housesInfo[i].ParkingSpaceVehicleIdDict) do
					houseView.ParkingInfo[t + 1] = v
				end
			end

			if table.isNilOrEmpty(self.parkinginfolist[houseView.HouseId]) then
				self.parkinginfolist[houseView.HouseId] = {}
			end

			self.parkinginfolist[houseView.HouseId] = houseView
		end
	end

	self.currentParkingInfo = self.parkinginfolist[houseId]
end

function M:CreateAllVehicleModel(createMe)
	if table.isNilOrEmpty(self.currentParkingInfo) or table.isNilOrEmpty(self.currentParkingInfo.ParkingInfo) then
		return
	end

	local hId = self.CurrentHouseId
	local cfg = HouseConfig.GetConfig(hId)

	if cfg and cfg.ParkingSpaceWaypoints then
		for parkId, VehicleId in pairs(self.currentParkingInfo.ParkingInfo) do
			if VehicleId == self.VehicleId then
				if table.isNilOrEmpty(self.currentParkingInfo.ParkingVehicleUid) then
					self.currentParkingInfo.ParkingVehicleUid = {}
				end

				self.currentParkingInfo.ParkingVehicleUid[parkId] = gDriveVehiclesManager.cs_manager.CurDriveVehicleUid
			end

			if VehicleId ~= self.VehicleId or createMe then
				self:CreateVehicleModel(parkId, VehicleId, hId)
			end
		end
	end
end

function M:CreateVehicleModel(parkId, VehicleId, houseId)
	local cfg = HouseConfig.GetConfig(houseId)

	if cfg == nil then
		return
	end

	local VehicleCfg = VehicleConfig.GetConfig(VehicleId)

	if VehicleCfg then
		local wayPointName = cfg.ParkingSpaceWaypoints[parkId]
		local pos = gSpoonMgr:GetWayPointPositionByNameOrId(wayPointName)
		local angle = cfg.ParkingSpaceFacings[parkId] or 0
		local spawnParam = SpawnVehicleParam.New()
		spawnParam.position = pos
		spawnParam.facing = angle
		spawnParam.forceDummy = true
		spawnParam.forceLODLevel = LX6.Share.VehicleForceLODLevel.Highest

		function spawnParam.afterLoadAction(_vehicle)
			if _vehicle ~= nil then
				if table.isNilOrEmpty(self.currentParkingInfo.ParkingVehicleUid) then
					self.currentParkingInfo.ParkingVehicleUid = {}
				end

				self.currentParkingInfo.ParkingVehicleUid[parkId] = _vehicle.uid

				_vehicle:SetEnterVehicleEnable(false)
			end
		end

		DriveUtils.SpawnVehicleClient(VehicleId, spawnParam)
	else
		print_error("VehicleId在车辆表未找到，VehicleId = " .. VehicleId)
	end
end

function M:CreateLeaveVehicleModel(VehicleId, houseId, callBack)
	local cfg = HouseConfig.GetConfig(houseId)
	local VehicleCfg = VehicleConfig.GetConfig(VehicleId)

	if VehicleCfg and cfg then
		local wayPointName = cfg.GarageOutWaypoint
		local pos = gSpoonMgr:GetWayPointPositionByNameOrId(wayPointName)
		local angle = 0
		local spawnParam = SpawnVehicleParam.New()
		spawnParam.position = pos
		spawnParam.facing = angle
		spawnParam.forceDummy = true
		spawnParam.forceLODLevel = LX6.Share.VehicleForceLODLevel.Highest

		function spawnParam.afterLoadAction(_vehicle)
			if _vehicle ~= nil then
				callBack(_vehicle.uid)
			end
		end

		DriveUtils.SpawnVehicleClient(VehicleId, spawnParam)
	else
		print_error("VehicleId在车辆表未找到，VehicleId = " .. VehicleId)
	end
end

function M:DestoryVehicleModel(parkingId)
	if table.isNilOrEmpty(self.currentParkingInfo) or table.isNilOrEmpty(self.currentParkingInfo.ParkingVehicleUid) then
		return
	end

	local VehicleUid = self.currentParkingInfo.ParkingVehicleUid[parkingId]
	local vehicle = LX6.Drive.DriveUtils.GetVehicleInScene(VehicleUid)

	if vehicle then
		vehicle.VehicleGameObject:SetActive(false)
	end

	if VehicleUid then
		self.currentParkingInfo.ParkingVehicleUid[parkingId] = nil
		self.parkinginfolist[self.CurrentHouseId].ParkingInfo[parkingId] = nil

		DriveUtils.DestroyVehicleClient(VehicleUid)
	end
end

function M:DestoryAllVehicleModel()
	if table.isNilOrEmpty(self.currentParkingInfo) or table.isNilOrEmpty(self.currentParkingInfo.ParkingVehicleUid) then
		return
	end

	for parkId, VehicleUid in pairs(self.currentParkingInfo.ParkingVehicleUid) do
		if VehicleUid ~= gDriveVehiclesManager.cs_manager.CurDriveVehicleUid then
			DriveUtils.DestroyVehicleClient(VehicleUid)
		end
	end
end

function M:PlayLoadingCutscene(houseId, parkingIndex, enter, vehicleUid, finalCb)
	local currentCarUid = -1

	if enter then
		currentCarUid = gDriveVehiclesManager.cs_manager.CurDriveVehicleUid
	else
		currentCarUid = vehicleUid
	end

	if currentCarUid == -1 then
		return
	end

	local cParkIndex = parkingIndex - 1

	if enter then
		local loadingInfoIndex = nil
		loadingInfoIndex = gLoadingManager:Quick_Garage(houseId, currentCarUid, cParkIndex, enter, function ()
			self:TeleportToHouseGarage(houseId, cParkIndex, function ()
				gLoadingManager:StopWaitLoading(loadingInfoIndex)
			end)
		end)

		return
	end

	local loadingInfoIndex = nil
	loadingInfoIndex = gLoadingManager:Quick_Garage(houseId, currentCarUid, cParkIndex, enter, function ()
		self:TeleportFromHouseGarage(houseId, cParkIndex, function ()
			gLoadingManager:StopWaitLoading(loadingInfoIndex)
		end)
	end)
end

function M:AskHouseParking(VehicleId, cb)
	local houseView = {
		HouseId = self.CurrentHouseId,
		VehicleId = VehicleId or self.VehicleId
	}
	local parkinglist = {}

	table.insert(parkinglist, houseView)

	gClientToGameDelegate:AskHouseParking(parkinglist).Callback = function (err, data)
		if err == MessageConfig.Ok then
			cb()
		end
	end
end

function M:SyncHouseParking(cancelInfoList, addInfoList)
	local parkingIndex = 0

	if addInfoList.Count == 0 and not table.isNilOrEmpty(self.currentParkingInfo) and not table.isNilOrEmpty(self.currentParkingInfo.ParkingInfo) then
		for i, v in pairs(self.currentParkingInfo.ParkingInfo) do
			if self.VehicleId == v then
				parkingIndex = i - 1

				break
			end
		end
	end

	for i = 1, addInfoList.Count do
		self.currentParkingInfo.ParkingInfo[addInfoList[i].ParkingSpaceIndex + 1] = addInfoList[i].VehicleId

		if table.isNilOrEmpty(self.parkinginfolist[addInfoList[i].HouseId]) then
			self.parkinginfolist[addInfoList[i].HouseId] = {
				HouseId = addInfoList[i].HouseId,
				ParkingInfo = {}
			}
		end

		if table.isNilOrEmpty(self.parkinginfolist[addInfoList[i].HouseId].ParkingInfo) then
			self.parkinginfolist[addInfoList[i].HouseId].ParkingInfo = {}
		end

		self.parkinginfolist[addInfoList[i].HouseId].ParkingInfo[addInfoList[i].ParkingSpaceIndex + 1] = addInfoList[i].VehicleId
		parkingIndex = addInfoList[i].ParkingSpaceIndex
	end

	self:PlayLoadingCutscene(self.CurrentHouseId, parkingIndex + 1, true, nil, function ()
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "EnterGarageRefreshButton"
		})
	end)
end

function M:CheckCarprotHasCar(carprotIndex)
	if gGarageManager.currentParkingInfo and gGarageManager.currentParkingInfo.ParkingInfo then
		local vehicleId = gGarageManager.currentParkingInfo and gGarageManager.currentParkingInfo.ParkingInfo[carprotIndex]

		return vehicleId ~= nil and vehicleId ~= 0
	end

	return false
end

gGarageManager = M
