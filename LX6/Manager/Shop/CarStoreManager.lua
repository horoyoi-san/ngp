-- Original chunk: @Lua\LuaFiles\LX6\Manager\Shop\CarStoreManager.lua
-- Decompiled from: 00527_CarStoreManager.lua_fef664e30299.luajit

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

M.ctor = function(self)
	self.vehicleId2Feature = {}
	self.moneyType = 0
	self.lastCameraState = 0
	self.vehicle2Model = {}
	self.commidity2Type = {}
	self.VIEW_TYPE = {
		["?M\\x9f\\x9a\\x86S"] = 2,
		["z\\xa6\\xa7\\xaa\\xba"] = 3,
		["\\xa7\\xa5\\xa7\\xa2"] = 1,
		N0tV = 4,
		["T-s^"] = 0
	}
	self.COMMIDITY_TYPE = {
		["b\\x9a\\x8a\\x8a\\x84"] = 2,
		["\\xadIT"] = 1
	}
end

M.InitFeatureCfg = function(self)
	self.vehicleId2Feature = {}

	for i = 0, VehicleFeatureConfig.count - 1 do
		local cfg = VehicleFeatureConfig.LoadAt(i)

		if self.vehicleId2Feature[cfg.VehicleId] == nil then
			print_error("VehicleFeatureConfig 车辆特征表重复", cfg.VehicleId)
		else
			self.vehicleId2Feature[cfg.VehicleId] = cfg
		end
	end
end

M.GetFeatureByVehicleId = function(self, vehicleId)
	if table.isNilOrEmpty(self.vehicleId2Feature) then
		self:InitFeatureCfg()
	end

	return self.vehicleId2Feature[vehicleId]
end

M.InitCarSetCfg = function(self)
	for i = 0, CarShopSetConfig.count - 1 do
		local cfg = CarShopSetConfig.LoadAt(i)

		if self.vehicleId2CarSetId[cfg.VehicleId] ~= nil then
			self.vehicleId2CarSetId[cfg.VehicleId] = {}
		end

		table.insert(self.vehicleId2CarSetId[cfg.VehicleId], cfg)
	end
end

M.SetMaterial = function(self, MaterialPartId)
	if self.baseVehicle then
		-- Nothing
	end
end

M.AskVehicleShopSpawnVehicle = function(self, shopId, vehicleid, cb)
	gClientToGameDelegate:AskVehicleShopSpawnVehicle(shopId, vehicleid).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok and cb then
			cb()
		end
	end
end

M.SetCameraState = function(self, cameraState)
	if cameraState then
		self.lastCameraState = cameraState
		BuyVehicleCameraState.CurViewType = cameraState
	else
		if self.lastCameraState ~= BuyVehicleCameraState.CurViewType then
			return
		end

		BuyVehicleCameraState.CurViewType = self.lastCameraState
	end
end

M.LoadEndTimeLine = function(self, type, shopIndex)
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
