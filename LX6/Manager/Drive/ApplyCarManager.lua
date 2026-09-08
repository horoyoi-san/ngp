-- Original chunk: @Lua\LuaFiles\LX6\Manager\Drive\ApplyCarManager.lua
-- Decompiled from: 00720_ApplyCarManager.lua_7a579d53255b.luajit

C_ApplyCarManager = DefClass("C_ApplyCarManager", C_ApplyCarManager)
local M = C_ApplyCarManager
local DriveUtils = LX6.Drive.DriveUtils
local VehicleConfig = LTConfig.VehicleConfig
local CarShopConfig = LTConfig.CarShopConfig
local MessageConfig = LTConfig.MessageConfig
local LoadingConfig = LTConfig.LoadingConfig
local VehicleSeatState = LX6.Drive.VehicleSeatState
local E_VehicleOwnedBy = LX6.Drive.E_VehicleOwnedBy

M.ctor = function(self)
	self.indoorCarShopId = {}
	self.carShopApplyCarAreas = {}
	self.carShopCfgId = 0
	self.shopId = 0
	self.currentCarUid = nil
	self.parkingCfgId = nil
	self.realVehicleDestroyed = false
	self.UnlockedVehicles = {}
	self.driveCarTypeId = 0
	self.hasEnterRepairShop = false
	self.isDebug = false
	self.leaveRepairEnterHandler = nil
	self.leaveRepairEnterTimer = nil

	self:InitListener()
end

M.InitListener = function(self)
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
		self:OnChangeIndoor(data)
	end)
	gMessageManager:AddMessageListener(gEventConstants.LOADING_FINISHED, function ()
		self:OnLoadingFinish()
	end)
end

M.GetCarShopByIndoor = function(self)
	self.indoorCarShopId = {}

	for index = 0, CarShopConfig.count - 1 do
		local cfg = CarShopConfig.LoadAt(index)

		if cfg then
			self.indoorCarShopId[cfg.CarShopId] = cfg.Id
		end
	end
end

M.InitCarShopApplyAreas = function(self)
	self.carShopApplyCarAreas = {}

	for index = 0, CarShopConfig.count - 1 do
		local curCarShopCfg = CarShopConfig.LoadAt(index)

		if curCarShopCfg == nil and curCarShopCfg.VehicleIdentifyAreaId then
			self.carShopApplyCarAreas[curCarShopCfg.VehicleIdentifyAreaId] = {
				cfgId = curCarShopCfg.Id
			}
		end
	end
end

M.OnChangeIndoor = function(self, data)
	if gMapManager.IndoorId ~= 0 then
		self.hasEnterRepairShop = false

		self:ClearLeaveRepairEnterWait()

		if self.carShopCfgId <= 0 then
			self:HideVehicleModel()

			self.carShopCfgId = 0
			self.shopId = 0
			self.driveCarTypeId = 0
			self.currentCarUid = nil
		end
	end

	if not data.isSwitchScene and gLuaDataManager.gameStage == gGFConstant.GameStage.Loading then
		self:OnLoadingFinish()
	end
end

M.OnLoadingFinish = function(self)
	if table.isNilOrEmpty(self.indoorCarShopId) then
		self:GetCarShopByIndoor()
	end

	if table.isNilOrEmpty(self.carShopApplyCarAreas) then
		self:InitCarShopApplyAreas()
	end

	if not self.hasEnterRepairShop and gMapManager.IndoorId <= 0 then
		local vehicleId = gPlayerManager.infoMinor.bindData.VehicleInfo and gPlayerManager.infoMinor.bindData.VehicleInfo.ParkingVehicleId

		if vehicleId == 0 then
			local carShopId = self.indoorCarShopId[gMapManager.IndoorId]

			if carShopId then
				self.carShopCfgId = carShopId
				self.hasEnterRepairShop = true
			end
		end
	end
end

M.HideVehicleModel = function(self)
	local cfg = CarShopConfig.GetConfig(self.carShopCfgId)

	if cfg then
		if self.currentCarUid ~= nil then
			return
		end

		local vehicle = LX6.Drive.DriveUtils.GetBaseVehicle(self.currentCarUid)

		if vehicle and vehicle.gameObject and not gCS.LuaUtils.IsNull(vehicle.gameObject) then
			vehicle.gameObject:SetActive(false)
		end
	end
end

M.CheckCarShopCanEnterTask = function(self, carShopCfgId)
	local cfg = CarShopConfig.GetConfig(carShopCfgId)

	if cfg then
		if cfg.UnlockTask and cfg.UnlockTask <= 0 then
			if gTaskNodeManager:IsTaskEventSubmit(cfg.UnlockTask) or gTaskNodeManager:GetTaskLineState(cfg.UnlockTask) ~= gTaskLineState.Doing then
				return true
			end
		else
			return true
		end
	end

	return false
end

M.CheckCanEnterCarShop = function(self, carShopId)
	if not self:IsMySummonVehicle() then
		gDisplayMessageMgr:ShowMessageContent("只能驾驶自己的载具进入")

		if self.isDebug then
			print_debug("ApplyCarManager-进入车库的车辆不是玩家本人召唤的车辆，无法进入  VehicleUid = " .. ulong.tostring(self.currentCarUid))
		end

		return false
	end

	if self:HasOtherPassenger() then
		gDisplayMessageMgr:ShowMessageContent("车上还有其他乘客，无法进入")

		if self.isDebug then
			print_debug("ApplyCarManager-进入车库的车辆上有其他乘客，无法进入  VehicleUid = " .. ulong.tostring(self.currentCarUid))
		end

		return false
	end

	if not self:CheckCarShopCanEnterTask(carShopId) then
		return false
	end

	if not self:VehicleCanBeApplied(self.driveCarTypeId) then
		gDialogManager:ShowGeneralDialog(VehicleConfig.VehicleGetFailDialog, gDialogSource.Vehicle)

		return false
	end

	if gCS.LuaUtils.IsPlayerJumpingOutOfVehicle() then
		gDisplayMessageMgr:ShowMessageContent("正在离开车辆，无法进入")

		if self.isDebug then
			print_debug("ApplyCarManager-玩家正在跳车，禁止进入车库  VehicleUid = " .. ulong.tostring(self.currentCarUid))
		end

		return false
	end

	return true
end

M.OnVehicleEnterIdentifyArea = function(self, data)
	if data and data.ToTable then
		data = data:ToTable()
	end

	local carShopId = data.carShopId
	local cfg = CarShopConfig.GetConfig(carShopId)

	if cfg ~= nil then
		return
	end

	self.carShopCfgId = carShopId
	self.shopId = cfg.ShopID or 0
	self.currentCarUid = gDriveVehiclesManager.cs_manager.CurDriveVehicleUid
	local vehicle = DriveUtils.GetBaseVehicle(self.currentCarUid)

	if vehicle ~= nil then
		return
	end

	if gPlayerManager.infoMinor.bindData.VehicleInfo then
		gPlayerManager.infoMinor.bindData.VehicleInfo.ParkingVehicleId = vehicle.cfgId
	end

	self.driveCarTypeId = vehicle.cfgId

	if self.hasEnterRepairShop then
		return
	end

	if not self:CheckCanEnterCarShop(carShopId) then
		return
	end

	if data and data.callBack then
		if data.callBack.DynamicInvoke then
			data.callBack:DynamicInvoke()
		else
			data.callBack()
		end
	end

	self:EnterRepairShop(carShopId, vehicle)
end

M.PlayLoadingCutscene = function(self, carShopId, carUid, enter)
	local cfg = CarShopConfig.GetConfig(carShopId)

	if not cfg then
		print_error("ApplyCarManager-播放汽修厂演出(通用流程)中止, 找不到配置 carShopId = " .. tostring(carShopId))

		return
	end

	if not carUid or ulong.equals(carUid, 0) then
		print_error("ApplyCarManager-播放汽修厂演出(通用流程)中止, carUid无效 carShopId = " .. tostring(carShopId))

		return
	end

	local preTeleportOption = UX.Game.PreTeleportOption.New()
	local extParams = LX6.GUI.LoadingManager.AskTeleportExtParams.New()
	local beforeWpId, beforeTLName = nil

	if enter then
		beforeWpId = cfg.StopCarWaypointId
		beforeTLName = cfg.EnterTimeline and cfg.EnterTimeline[1] or nil
	else
		beforeWpId = cfg.ParkingWaypointId
		beforeTLName = cfg.ExitTimeline and cfg.ExitTimeline[1] or nil
	end

	if beforeWpId and beforeWpId == 0 and beforeTLName and beforeTLName == "" then
		local beforePos = gSpoonMgr:GetWayPointPositionByNameOrId(beforeWpId)

		if beforePos then
			local beforeFacing = gSpoonMgr:GetWayPointFacingByNameOrId(beforeWpId) or 0
			preTeleportOption.customBeforeTrans = true
			preTeleportOption.beforePosition = UX.Game.UXVector3.New(beforePos.x, beforePos.y, beforePos.z)
			preTeleportOption.beforeRot = UX.Game.UXVector3.New(0, beforeFacing, 0)
			preTeleportOption.beforeResName = beforeTLName
		end
	end

	local afterWpId, afterTLName = nil

	if enter then
		afterWpId = cfg.ParkingWaypointId
		afterTLName = cfg.EnterTimeline and cfg.EnterTimeline[2] or nil
	else
		afterWpId = cfg.LeaveWaypointId
		afterTLName = cfg.ExitTimeline and cfg.ExitTimeline[2] or nil
	end

	if afterWpId and afterWpId == 0 and afterTLName and afterTLName == "" then
		local afterPos = gSpoonMgr:GetWayPointPositionByNameOrId(afterWpId)

		if afterPos then
			local afterFacing = gSpoonMgr:GetWayPointFacingByNameOrId(afterWpId) or 0
			preTeleportOption.customAfterTrans = true
			preTeleportOption.afterPosition = UX.Game.UXVector3.New(afterPos.x, afterPos.y, afterPos.z)
			preTeleportOption.afterRot = UX.Game.UXVector3.New(0, afterFacing, 0)
			preTeleportOption.afterResName = afterTLName
		end
	end

	if self.isDebug then
		print_debug("ApplyCarManager-播放汽修厂演出(通用流程), carShopId = " .. tostring(carShopId) .. ", enter = " .. tostring(enter) .. ", carUid = " .. ulong.tostring(carUid))
	end

	gLoadingManager:SetGarageLoadingCarUid(carUid)
	gLoadingManager:AskTeleport(LoadingConfig.EnterExitCarShop, preTeleportOption, extParams, function (loadingInfoIndex)
		if enter then
			local vehicle = DriveUtils.GetBaseVehicle(carUid)

			if vehicle then
				vehicle:SetSeatInteractOperation(0, 6)
			else
				print_error("ApplyCarManager-进入汽修厂的车辆在传送过程中找不到了  VehicleUid = " .. ulong.tostring(carUid))
			end

			gClientToGameSceneDelegate:AskTeleportToParkingWaypoint(carShopId).Callback = function (err)
				if err ~= MessageConfig.Ok then
					local vehicleUnit = DriveUtils.GetBaseVehicle(carUid)

					if vehicleUnit then
						vehicleUnit:SetEnterVehicleEnable(false)
					end
				else
					print_error("ApplyCarManager-传送进汽修厂失败(通用流程) err = " .. tostring(err) .. ", carShopId = " .. tostring(carShopId))

					self.hasEnterRepairShop = false

					gLoadingManager:StopLoading(loadingInfoIndex)
				end
			end
		elseif self:IsPlayerOnCurrentVehicle() then
			self:RequestLeaveShopTeleport(carShopId, carUid, loadingInfoIndex)
		else
			self:WaitPlayerEnterVehicleThenLeaveShop(carShopId, carUid, loadingInfoIndex)
		end
	end)
end

M.RequestLeaveShopTeleport = function(self, carShopId, carUid, loadingInfoIndex)
	gClientToGameSceneDelegate:AskTeleportToLeavingWaypoint(carShopId).Callback = function (err)
		if err ~= MessageConfig.Ok then
			local vehicle = DriveUtils.GetBaseVehicle(carUid)

			if vehicle then
				vehicle:SetEnterVehicleEnable(true)
			end

			self.carShopCfgId = 0
			self.shopId = 0
			self.currentCarUid = nil
			self.hasEnterRepairShop = false
			self.realVehicleDestroyed = false
			self.parkingCfgId = nil

			gNewCarStoreMgr:OnLeaveRepairShopComplete()

			if gPlayerManager.infoMinor.bindData.VehicleInfo then
				gPlayerManager.infoMinor.bindData.VehicleInfo.ParkingVehicleId = 0
			end
		else
			print_error("ApplyCarManager-传送出汽修厂失败(通用流程) err = " .. tostring(err) .. ", carShopId = " .. tostring(carShopId))

			self.hasEnterRepairShop = false

			gLoadingManager:StopLoading(loadingInfoIndex)
		end
	end
end

M.IsPlayerOnCurrentVehicle = function(self)
	if not self.currentCarUid then
		return false
	end

	local csMgr = gDriveVehiclesManager.cs_manager

	return csMgr.isDriveMode and ulong.equals(csMgr.CurDriveVehicleUid, self.currentCarUid)
end

M.ClearLeaveRepairEnterWait = function(self)
	if self.leaveRepairEnterHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.ENTER_BASE_VEHICLE_FINISH, self.leaveRepairEnterHandler)

		self.leaveRepairEnterHandler = nil
	end

	if self.leaveRepairEnterTimer then
		self.leaveRepairEnterTimer:Stop()

		self.leaveRepairEnterTimer = nil
	end
end

M.WaitPlayerEnterVehicleThenLeaveShop = function(self, carShopId, carUid, loadingInfoIndex)
	self:ClearLeaveRepairEnterWait()

	self.leaveRepairEnterHandler = function(eventId, data)
		if not data or not ulong.equals(data, self.currentCarUid) then
			return
		end

		self:ClearLeaveRepairEnterWait()

		if self:IsPlayerOnCurrentVehicle() then
			self:RequestLeaveShopTeleport(carShopId, carUid, loadingInfoIndex)
		else
			print_error("ApplyCarManager-出汽修厂收到上车完成事件但玩家不在目标车上, carShopId = " .. tostring(carShopId) .. ", carUid = " .. ulong.tostring(carUid))

			self.hasEnterRepairShop = false

			gLoadingManager:StopLoading(loadingInfoIndex)
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.ENTER_BASE_VEHICLE_FINISH, self.leaveRepairEnterHandler)

	self.leaveRepairEnterTimer = Timer.New(function ()
		self.leaveRepairEnterTimer = nil

		if self.leaveRepairEnterHandler then
			self:ClearLeaveRepairEnterWait()
			print_error("ApplyCarManager-出汽修厂等待上车超时(3s), carShopId = " .. tostring(carShopId) .. ", carUid = " .. ulong.tostring(carUid))

			self.hasEnterRepairShop = false

			gLoadingManager:StopLoading(loadingInfoIndex)
		end
	end, 3):Start()
end

M.EnterRepairShop = function(self, carShopId, vehicle)
	self.hasEnterRepairShop = true
	self.parkingCfgId = vehicle.cfgId
	self.realVehicleDestroyed = false

	vehicle:SetSeatInteractOperation(0, 5)
	self:PlayLoadingCutscene(carShopId, self.currentCarUid, true)
end

M.GetParkingVehicleCfgId = function(self)
	return self.parkingCfgId
end

M.SwitchRepairVehicle = function(self, newCfgId)
	if not newCfgId or newCfgId ~= 0 then
		return
	end

	if self.parkingCfgId ~= newCfgId then
		return
	end

	self.parkingCfgId = newCfgId

	gMessageManager:SendMessage(gEventConstants.CAR_SHOP_VEHICLE_SWITCH)
end

M.TryDestroyRealVehicle = function(self)
	if self.realVehicleDestroyed then
		return
	end

	local vehicle = DriveUtils.GetBaseVehicle(self.currentCarUid)

	if vehicle then
		vehicle:HideVehicle()
		vehicle:SetForceDummy(true)
		vehicle:EnableVehicleColliders(false)
	end

	self:AskDestroyParkingVehicle()

	self.realVehicleDestroyed = true
end

M.AskDestroyParkingVehicle = function(self)
	gClientToGameDelegate:AskVehicleShopDestroyParking(self.shopId).Callback = function (err)
		if err == MessageConfig.Ok then
			print_error("[ApplyCarManager] AskDestroyParkingVehicle failed err=", err)

			self.realVehicleDestroyed = false
		end
	end
end

M.SpawnRealVehicleForLeave = function(self, vehicleId, cb)
	gClientToGameDelegate:AskVehicleShopSpawnVehicle(self.shopId, vehicleId, false).Callback = function (err, vehicleUid)
		if err == MessageConfig.Ok then
			print_error("[ApplyCarManager] SpawnRealVehicleForLeave failed err=", err)

			return
		end

		if not vehicleUid or ulong.equals(vehicleUid, 0) then
			print_error("[ApplyCarManager] SpawnRealVehicleForLeave: uid 无效 vehicleId=", vehicleId)

			return
		end

		self.currentCarUid = vehicleUid

		if cb then
			cb(vehicleUid)
		end
	end
end

M.RequestLeaveRepairShop = function(self)
	local carShopCfgId = self.carShopCfgId

	if self.realVehicleDestroyed then
		local vehicleId = self.parkingCfgId

		if not vehicleId or vehicleId ~= 0 then
			print_error("[ApplyCarManager] RequestLeaveRepairShop: realVehicleDestroyed 但无 parkingCfgId")

			return
		end

		gNewCarStoreMgr:DisableCurrentVehicleColliders()
		self:SpawnRealVehicleForLeave(vehicleId, function (uid)
			gDriveVehiclesManager:TryGetBaseVehicleWithCallback(uid, function (vehicle)
				if not vehicle then
					print_error("[ApplyCarManager] RequestLeaveRepairShop: spawn 真车后获取失败 uid=", uid)

					return
				end

				gNewCarStoreMgr:DestroyVehicle()
				self:LeaveRepairShop(carShopCfgId, uid)
			end)
		end)
	else
		gNewCarStoreMgr:DestroyVehicle()
		self:LeaveRepairShop(carShopCfgId, self.currentCarUid)
	end
end

M.OnVehicleLeaveIdentifyArea = function(self, data)
	self:RequestLeaveRepairShop()
end

M.LeaveRepairShop = function(self, carShopCfgId, carUid)
	print_debug("ApplyCarManager-Leave CarShop, carShopCfgId = " .. tostring(carShopCfgId) .. ", carUid = " .. ulong.tostring(carUid))

	if not carUid or ulong.equals(carUid, 0) then
		print_error("出汽修店时, carUid无效")

		return
	end

	self.driveCarTypeId = 0
	self.hasEnterRepairShop = true

	self:PlayLoadingCutscene(carShopCfgId, carUid, false)
end

M.ControlCameraCaptureVehicle = function(self, str)
	local inputString = str
	local data = {}

	for key, value in string.gmatch(inputString, "(%w+)%s-=%s-(%w+)") do
		data[key] = tonumber(value) or value
	end

	if type(data.openCapture) ~= "string" then
		if data.openCapture ~= "true" then
			data.openCapture = true
		elseif data.openCapture ~= "false" then
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
		if not self.currentCarUid then
			print_error("ApplyCarManager-当前车库内车辆Uid为空, carShopId = " .. carShopId)

			return
		end

		local vehicle = DriveUtils.GetBaseVehicle(self.currentCarUid)

		if not vehicle then
			print_error("ApplyCarManager-当前车库内不存在车辆  VehicleUid = " .. self.currentCarUid)

			return
		end

		if not vehicle.gameObject or gCS.LuaUtils.IsNull(vehicle.gameObject) or not vehicle.gameObject.transform then
			print_error("ApplyCarManager-车辆gameObject或transform为空  VehicleUid = " .. self.currentCarUid)

			return
		end

		local changedLocalCoordinate = Vector3.New(cfg.CameraPos[1], cfg.CameraPos[2], cfg.CameraPos[3])
		local changedCoordinate = vehicle.gameObject.transform.right * changedLocalCoordinate.x + vehicle.gameObject.transform.up * changedLocalCoordinate.y + vehicle.gameObject.transform.forward * changedLocalCoordinate.z
		local worldCameraPos = Vector3.New(vehicle.gameObject.transform.position.x + changedCoordinate.x, vehicle.gameObject.transform.position.y + changedCoordinate.y, vehicle.gameObject.transform.position.z + changedCoordinate.z)
		local changedCoordNorm = Vector3.Normalize(changedCoordinate)
		local yaw = math.atan2(changedCoordNorm.x * -1, changedCoordNorm.z * -1) * 180 / math.pi
		local pitch = math.asin(changedCoordNorm.y) * 180 / math.pi
		local worldCameraEuler = Vector3.New(pitch, yaw, 0)

		gCS.CameraDataMgr.cinemachineManager:EnableFixCamera(true, worldCameraPos, worldCameraEuler, 60, LX6.Cinemachine.EVcamPriority.GamePlay)
	end
end

M.VehicleCanBeApplied = function(self, vehicleTypeId)
	local vehicleCfgData = VehicleConfig.GetConfig(vehicleTypeId)

	if vehicleCfgData then
		return vehicleCfgData.VehicleCanGet or false
	end

	return false
end

M.IsMySummonVehicle = function(self)
	local vehicle = DriveUtils.GetBaseVehicle(gDriveVehiclesManager.cs_manager.CurDriveVehicleUid)

	if not vehicle then
		return false
	end

	if vehicle.vehicleOwnedBy == E_VehicleOwnedBy.Summon then
		return true
	end

	local csMgr = gDriveVehiclesManager.cs_manager

	return csMgr.CurrentSummonVehicle == 0 and ulong.equals(csMgr.CurrentSummonVehicle, csMgr.CurDriveVehicleUid)
end

M.HasOtherPassenger = function(self)
	local vehicle = DriveUtils.GetBaseVehicle(gDriveVehiclesManager.cs_manager.CurDriveVehicleUid)

	if not vehicle then
		return false
	end

	local seats = gCS.LuaUtils.GetVehicleSeatInfo(vehicle)

	if not seats then
		return false
	end

	for i = 0, seats.Length - 1 do
		local seat = seats[i]

		if seat.state == VehicleSeatState.Empty and seat.person and not seat.person.isMe then
			return true
		end
	end

	return false
end

M.SyncAllUnlockedVehicles = function(self, unlockedVehicles)
	self.UnlockedVehicles = unlockedVehicles

	gMessageManager:SendMessage(gEventConstants.UNLOCKED_VEHICLES_SYNC)
end

M.CheckPlayerAlreadyHasVehicle = function(self, vehicleId)
	local UnlockedVehicles = self.UnlockedVehicles

	if not table.isNilOrEmpty(UnlockedVehicles) then
		for i = 1, UnlockedVehicles.Count do
			if UnlockedVehicles[i].Id ~= vehicleId then
				return true
			end
		end
	end

	return false
end

M.AddUnlockVehicle = function(self, vehicleTypeId)
	local hasVehicle = false

	if not table.isNilOrEmpty(self.UnlockedVehicles) then
		for i = 1, self.UnlockedVehicles.Count do
			if self.UnlockedVehicles[i].Id ~= vehicleTypeId then
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

M.OnSyncCarShopParking = function(self, info)
	if not info then
		print_error("ApplyCarManager-同步汽修店重登信息失败，info为空")

		return
	end

	print_debug("ApplyCarManager-同步汽修店重登信息，VehicleEntityId = " .. ulong.tostring(info.VehicleEntityId) .. ", CarshopId = " .. info.CarshopId)

	self.carShopCfgId = info.CarshopId
	local shopCfg = CarShopConfig.GetConfig(info.CarshopId)
	self.shopId = shopCfg and shopCfg.ShopID or 0
	self.hasEnterRepairShop = true

	if info.VehicleEntityId and not ulong.equals(info.VehicleEntityId, 0) then
		self.currentCarUid = info.VehicleEntityId

		gDriveVehiclesManager:TryGetBaseVehicleWithCallback(info.VehicleEntityId, function (vehicle)
			if not vehicle then
				print_error("ApplyCarManager-同步汽修店重登信息失败，无法找到对应车辆，VehicleEntityId = " .. ulong.tostring(info.VehicleEntityId))

				return
			end

			Timer.New(function ()
				vehicle:SetEnterVehicleEnable(false)
			end, 1):Start()

			gCS.DriveManager.CurrentPlayerBaseVehicle = vehicle
		end)
	else
		self.currentCarUid = nil

		print_debug("[ApplyCarManager] 重连时 parking 真车已销毁，VehicleConfigId = " .. tostring(info.VehicleConfigId))
	end
end

gApplyCarManager = gApplyCarManager or C_ApplyCarManager.new()
