local VehicleFeatureConfig = LTConfig.VehicleFeatureConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local CarShopSetConfig = LTConfig.CarShopSetConfig
local CarShopOutColorConfig = LTConfig.CarShopOutColorConfig
local CarShopMaterialConfig = LTConfig.CarShopMaterialConfig
local CarShopInColorConfig = LTConfig.CarShopInColorConfig
local CarShopWheelConfig = LTConfig.CarShopWheelConfig
local MessageConfig = LTConfig.MessageConfig
local BuyVehicleCameraState = LX6.Cinemachine.BuyVehicleCameraState
local ShopConfig = LTConfig.ShopConfig
local CarShopConfig = LTConfig.CarShopConfig
C_CarStoreManager = DefClass("C_CarStoreManager", C_CarStoreManager)
local M = C_CarStoreManager

function M:ctor()
	self.vehicleId2Feature = {}
	self.moneyType = 0
	self.lastCameraState = 0
	self.vehicle2Model = {}
	self.commidity2Type = {}
	self.VIEW_TYPE = {
		Center = 2,
		Wheel = 3,
		Right = 1,
		Trim = 4,
		None = 0
	}
	self.COMMIDITY_TYPE = {
		OTHER = 2,
		CAR = 1
	}
end

function M:InitCarShopCfg()
	self.vehicleId2CarSetId = {}

	for i = 0, CarShopSetConfig.count - 1 do
		local cfg = CarShopSetConfig.LoadAt(i)

		if self.vehicleId2CarSetId[cfg.VehicleId] == nil then
			self.vehicleId2CarSetId[cfg.VehicleId] = {}
		end

		table.insert(self.vehicleId2CarSetId[cfg.VehicleId], cfg)

		self.commidity2Type[cfg.CommodityId] = self.COMMIDITY_TYPE.OTHER
	end

	for i = 0, CarShopOutColorConfig.count - 1 do
		local cfg = CarShopOutColorConfig.LoadAt(i)
		self.commidity2Type[cfg.CommodityId] = self.COMMIDITY_TYPE.OTHER
	end

	for i = 0, CarShopMaterialConfig.count - 1 do
		local cfg = CarShopMaterialConfig.LoadAt(i)
		self.commidity2Type[cfg.CommodityId] = self.COMMIDITY_TYPE.OTHER
	end

	for i = 0, CarShopInColorConfig.count - 1 do
		local cfg = CarShopInColorConfig.LoadAt(i)
		self.commidity2Type[cfg.CommodityId] = self.COMMIDITY_TYPE.OTHER
	end

	for i = 0, CarShopWheelConfig.count - 1 do
		local cfg = CarShopWheelConfig.LoadAt(i)
		self.commidity2Type[cfg.CommodityId] = self.COMMIDITY_TYPE.OTHER
	end
end

function M:InitFeatureCfg()
	self.vehicleId2Feature = {}

	for i = 0, VehicleFeatureConfig.count - 1 do
		local cfg = VehicleFeatureConfig.LoadAt(i)

		if self.vehicleId2Feature[cfg.VehicleId] ~= nil then
			print_error("VehicleFeatureConfig 车辆特征表重复", cfg.VehicleId)
		else
			self.vehicleId2Feature[cfg.VehicleId] = cfg
		end
	end
end

function M:GetFeatureByVehicleId(vehicleId)
	if table.isNilOrEmpty(self.vehicleId2Feature) then
		self:InitFeatureCfg()
	end

	return self.vehicleId2Feature[vehicleId]
end

function M:InitCarSetCfg()
	for i = 0, CarShopSetConfig.count - 1 do
		local cfg = CarShopSetConfig.LoadAt(i)

		if self.vehicleId2CarSetId[cfg.VehicleId] == nil then
			self.vehicleId2CarSetId[cfg.VehicleId] = {}
		end

		table.insert(self.vehicleId2CarSetId[cfg.VehicleId], cfg)
	end
end

function M:GetCarSetByVehicleId(vehicleId)
	if table.isNilOrEmpty(self.vehicleId2CarSetId) then
		self:InitCarSetCfg()
	end

	return self.vehicleId2CarSetId[vehicleId]
end

function M:ClearBaseVehicle()
	self.baseVehicle = nil

	if not table.isNilOrEmpty(self.vehicle2Model) then
		for _, vehicleUid in pairs(self.vehicle2Model) do
			LX6.Drive.DriveUtils.DestroyVehicleClient(vehicleUid)
		end
	end

	self.vehicle2Model = {}

	LX6.Item.DynamicGoManager.SetDynamicGoActive(23001409, false)
end

function M:SetCarSet(setIndex)
	if self.baseVehicle then
		-- Nothing
	end
end

function M:SetOutColor(OutColorPartId)
	if self.baseVehicle then
		-- Nothing
	end
end

function M:SetInColor(InColorPartId)
	if self.baseVehicle then
		-- Nothing
	end
end

function M:SetMaterial(MaterialPartId)
	if self.baseVehicle then
		-- Nothing
	end
end

function M:SetWheel(isRevert)
	if self.baseVehicle then
		-- Nothing
	end
end

function M:OnSetVehiclePosParent(trans)
	self.parentTrans = trans
end

function M:OnCreateVehicle(vehicleconfigid)
	LX6.Item.DynamicGoManager.SetDynamicGoActive(23001409, true)

	if self.vehicle2Model[self.lastSelectVehicleConfigId] then
		local vehicle = LX6.Drive.DriveUtils.GetVehicleInScene(self.vehicle2Model[self.lastSelectVehicleConfigId])

		if vehicle then
			vehicle.VehicleGameObject:SetActive(false)
		end
	end

	if self.vehicle2Model[vehicleconfigid] then
		local vehicle = LX6.Drive.DriveUtils.GetVehicleInScene(self.vehicle2Model[vehicleconfigid])

		if vehicle then
			vehicle.VehicleGameObject:SetActive(true)

			self.lastSelectVehicleConfigId = vehicleconfigid
			local baseVehicle = gDriveVehiclesManager.cs_manager:GetBaseVehicle(self.vehicle2Model[vehicleconfigid])
			self.baseVehicle = baseVehicle

			gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.BuyVehicle, baseVehicle)

			return
		end
	end

	local pos = Vector3.New(CarShopConfig.VehicleExhibitionScenePosition[1], CarShopConfig.VehicleExhibitionScenePosition[2], CarShopConfig.VehicleExhibitionScenePosition[3])
	local vehicleLoadParam = LX6.Drive.SpawnVehicleParam.New()
	vehicleLoadParam.position = pos
	vehicleLoadParam.forceLODLevel = LX6.Share.VehicleForceLODLevel.Highest
	vehicleLoadParam.forceDummy = true

	function vehicleLoadParam.afterLoadAction(baseVehicle)
		local _vehicle = baseVehicle

		if _vehicle ~= nil then
			local vehicleUnit = _vehicle
			vehicleUnit.gameObject.transform.position = pos

			vehicleUnit.gameObject.transform:SetLocalScale(1)

			self.vehicle2Model[vehicleconfigid] = _vehicle.uid
			self.lastSelectVehicleConfigId = vehicleconfigid
			self.baseVehicle = baseVehicle

			gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.BuyVehicle, self.baseVehicle)
		end
	end

	LX6.Drive.DriveUtils.SpawnVehicleClient(vehicleconfigid, vehicleLoadParam)
end

function M:AskVehicleShopSpawnVehicle(vehicleid, cb)
	gClientToGameDelegate:AskVehicleShopSpawnVehicle(vehicleid).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok and cb then
			cb()
		end
	end
end

function M:SetCameraCenter(isShowUI, ignore)
	if self.VIEW_TYPE.Center < BuyVehicleCameraState.CurViewType and not ignore then
		return
	end

	if isShowUI then
		BuyVehicleCameraState.CurViewType = self.VIEW_TYPE.Right
	else
		BuyVehicleCameraState.CurViewType = self.VIEW_TYPE.Center
	end
end

function M:SetCameraState(cameraState)
	if cameraState then
		self.lastCameraState = cameraState
		BuyVehicleCameraState.CurViewType = cameraState
	else
		if self.lastCameraState == BuyVehicleCameraState.CurViewType then
			return
		end

		BuyVehicleCameraState.CurViewType = self.lastCameraState
	end
end

function M:LoadEndTimeLine(type, shopIndex)
	local info = ConsumableConfig.VehicleShopEndTimeLine[type] or {}

	if info then
		local data = gTimelineManager:Timeline_CreateTimelineData()
		local pos = ShopConfig.VehicleShopCreatePositon[shopIndex]
		data.pos = Vector3.New(pos.x, pos.y, pos.z)
		data.loadCheck_Condition = 1
		data.loadCheck_FailedPlay = false

		gTimelineManager:Timeline_LoadAndPlay(info.timelineName, data)
	end
end

gCarStoreManager = gCarStoreManager or C_CarStoreManager.new()
