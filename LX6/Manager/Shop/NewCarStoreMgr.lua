-- Original chunk: @Lua\LuaFiles\LX6\Manager\Shop\NewCarStoreMgr.lua
-- Decompiled from: 02253_NewCarStoreMgr.lua_33b3f54ba275.luajit

local MessageConfig = LTConfig.MessageConfig
local VehiclePartConfig = LTConfig.VehiclePartConfig
local VehicleConfig = LTConfig.VehicleConfig
local NpcShopCommodityGroupCfg = LTConfig.ShopCommodityGroupConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local SpawnVehicleParam = LX6.Drive.SpawnVehicleParam
local DriveUtils = LX6.Drive.DriveUtils
local NpcShopConfig = LTConfig.ShopConfig
local VehiclePartShopTabConfig = LTConfig.VehiclePartShopTabConfig
local VehiclePartSuitConfig = LTConfig.VehiclePartSuitConfig
local VehicleTypeConfig = LTConfig.VehicleTypeConfig
local ViewType = LTConfig.VehiclePartShopTabConfig.ViewTypeType
local VehiclePartTagConfig = LTConfig.VehiclePartTagConfig
local CommodityType = LTConfig.ShopCommodityConfig.TypeType
local CarShopConfig = LTConfig.CarShopConfig
local StaticProps = {
	SHOP_TYPE = {
		[".m\\xa1\\xaf\\xaas"] = 1,
		["\\xac]_"] = 0
	},
	MODS_TAB_PAGE = {
		["\\xef\\xfe<4=\\xd4"] = 1,
		["8m\\xa5\\xaf\\xaam"] = 2,
		["WTu"] = 0
	},
	MODS_TYPE = {
		["\\xa5AR"] = 0,
		["\\xf6\\xee 11\\xda"] = 2,
		["n\\x81\\x8e\\x80\\x84"] = 4,
		["NO~"] = 1,
		["\\xafW\\xafl\\xf8\\x89\\x9c"] = 3
	},
	MAT_TYPE = {
		["\\x86\\xb4\\xaaf2\\xf70"] = 2,
		["`\\xaf\\xb6\\xbb\\xb3"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
}
C_NewCarStoreMgr = DefClass("C_NewCarStoreMgr", C_NewCarStoreMgr, nil, StaticProps)
local M = C_NewCarStoreMgr

M.ctor = function(self)
	self.shopType = M.SHOP_TYPE.BUY
	self.commodityInfoDic = nil
	self.vehicleId2CommodityId = nil
	self.vehiclePartId2CommodityId = nil
	self.activeVehiclePartSet = nil
	self.currentVehicleList = nil
	self.unlockedVehiclesDict = nil
	self.localActiveVehiclePartSet = nil
	self.currentVehicle = nil
	self.pendingVehicle = nil
	self.spawnSeq = 0
	self.DisplayType = {
		["\\xef\\xde(\\xf4"] = 0,
		["J#oO"] = 1
	}
	self.BOOL2CTL = {
		[true] = 1,
		[false] = 0
	}
	self.defaultColor = "#404040"
	self.isDebug = true
	self.partShowFieldName = {}
	self.paintGroupByMat = nil
	self.paintGroupByColor = nil
	self.paintPartId2MatType = {}

	self:InitPaintMaterialTypeMap()

	self.isConfirmBuy = false
	self.isShopInfoReady = false
	self.isLightLoaded = false
	self.lightLoadOp = nil
	self.lightInstance = nil
	self.curtRepairCfgId = nil
	self.curtRepairDefaultPartData = nil
	self.curtRepairDefaultPartSet = nil
	self.basePartMap = nil
	self.isRepairModified = false
	self.lastFiveDimScores = nil
end

M.Log = function(self, ...)
	if self.isDebug then
		print_debug("[C_NewCarStoreMgr]", ...)
	end
end

M.InitPaintMaterialTypeMap = function(self)
	self.paintPartId2MatType = {}

	for i = 0, VehiclePartConfig.count - 1 do
		local partCfg = VehiclePartConfig.LoadAt(i)

		if partCfg.PartTag ~= VehiclePartTagConfig.Color and partCfg.MatType and partCfg.MatType > 0 then
			self.paintPartId2MatType[partCfg.Id] = partCfg.MatType
		end
	end
end

M.GetMatTypeByPartId = function(self, partId)
	return self.paintPartId2MatType and self.paintPartId2MatType[partId]
end

M.RebuildBasePartMap = function(self, vehicleId)
	local map = {}
	local suitId = 0
	local list = gApplyCarManager and gApplyCarManager.UnlockedVehicles

	if list and list.Count then
		for i = 1, list.Count do
			local info = list[i]

			if info and info.Id ~= vehicleId then
				suitId = info.SuitId or 0

				if suitId == 0 then
					local suitCfg = VehiclePartSuitConfig.GetConfig(suitId)

					if suitCfg and suitCfg.Suit then
						for i = 1, #suitCfg.Suit do
							local partId = suitCfg.Suit[i]

							if partId and partId == 0 then
								local cfg = VehiclePartConfig.GetConfig(partId)

								if cfg then
									map[cfg.PartTag] = partId
								end
							end
						end

						local vehicleCfgForSuit = VehicleConfig.GetConfig(vehicleId)
						local isDefaultSuit = vehicleCfgForSuit == nil and suitId ~= vehicleCfgForSuit.DefaultSuitId

						if not isDefaultSuit and suitCfg.SuitPaint and suitCfg.SuitPaint == 0 then
							local paintCfg = VehiclePartConfig.GetConfig(suitCfg.SuitPaint)

							if paintCfg then
								map[paintCfg.PartTag] = suitCfg.SuitPaint
							end
						end
					end
				end

				local parts = info.Parts

				if parts and parts.Count then
					for j = 1, parts.Count do
						local part = parts[j]

						if part then
							if part.ConfigId ~= 0 then
								if part.Type and part.Type == 0 then
									map[part.Type] = 0
								end
							else
								local cfg = VehiclePartConfig.GetConfig(part.ConfigId)

								if cfg then
									map[cfg.PartTag] = part.ConfigId
								end
							end
						end
					end
				end

				break
			end
		end
	end

	self:_InitBaseParts(vehicleId, map)

	self.basePartMap = map
	self.curtRepairSuitId = suitId
	local set = {}

	for _, partId in pairs(map) do
		set[partId] = true
	end

	self.curtRepairDefaultPartSet = set
end

M.RebuildPartSetByVehicleId = function(self, vehicleId)
	self:RebuildBasePartMap(vehicleId)
end

M._InitBaseParts = function(self, vehicleId, map)
	local vehicleCfg = VehicleConfig.GetConfig(vehicleId)

	if not vehicleCfg or not vehicleCfg.VehicleBase or vehicleCfg.VehicleBase ~= 0 then
		return
	end

	if map[VehiclePartTagConfig.body] and map[VehiclePartTagConfig.body] == 0 then
		return
	end

	local tryAddDefault = function(partId)
		if not partId or partId ~= 0 then
			return
		end

		local cfg = VehiclePartConfig.GetConfig(partId)

		if cfg and not map[cfg.PartTag] then
			map[cfg.PartTag] = partId
		end
	end

	tryAddDefault(vehicleCfg.VehicleBase)

	local defaultSuit = self:GetDefaultSuitParts(vehicleCfg)

	if defaultSuit then
		for i = 1, math.min(6, #defaultSuit) do
			tryAddDefault(defaultSuit[i])
		end
	end

	local wheelModel = vehicleCfg.WheelModelA

	if wheelModel then
		for i = 1, math.min(4, #wheelModel) do
			tryAddDefault(wheelModel[i])
		end
	end

	local hubColor = vehicleCfg.HubColorList

	if hubColor and hubColor[1] then
		tryAddDefault(hubColor[1])
	end

	tryAddDefault(vehicleCfg.DefaultPaint)
end

M.GetDefaultSuitParts = function(self, vehicleCfg)
	if not vehicleCfg then
		return nil
	end

	if self.useDefaultSuitIdExpand and vehicleCfg.DefaultSuitId and vehicleCfg.DefaultSuitId == 0 then
		local suitCfg = VehiclePartSuitConfig.GetConfig(vehicleCfg.DefaultSuitId)

		if suitCfg and suitCfg.Suit then
			return suitCfg.Suit
		end
	end

	return vehicleCfg.DefaultSuit
end

M.GetEffectiveParts = function(self, previewParts)
	local merged = {}

	if self.basePartMap then
		for tag, partId in pairs(self.basePartMap) do
			if partId == 0 then
				merged[tag] = partId
			end
		end
	end

	if previewParts then
		for tag, partId in pairs(previewParts) do
			if partId ~= 0 then
				merged[tag] = nil
			else
				merged[tag] = partId
			end
		end
	end

	return table.to_array(merged)
end

M.GetEffectivePartsMap = function(self, previewParts)
	local merged = {}

	if self.basePartMap then
		for tag, partId in pairs(self.basePartMap) do
			if partId == 0 then
				merged[tag] = partId
			end
		end
	end

	if previewParts then
		for tag, partId in pairs(previewParts) do
			if partId ~= 0 then
				merged[tag] = nil
			else
				merged[tag] = partId
			end
		end
	end

	return merged
end

M.IsPartEquipped = function(self, partId)
	if not self.basePartMap or not partId or partId ~= 0 then
		return false
	end

	local cfg = VehiclePartConfig.GetConfig(partId)

	if not cfg then
		return false
	end

	return self.basePartMap[cfg.PartTag] ~= partId
end

M.GetRepairShopCfg = function(self, carShopId)
	if not carShopId or carShopId ~= 0 then
		print_error("汽修店CarShopId未传入")

		return nil
	end

	local cfg = CarShopConfig.GetConfig(carShopId)

	if not cfg then
		print_error("汽修店CarShop配置不存在:", carShopId)

		return nil
	end

	return cfg
end

M.GetRepairShopPosAndRot = function(self, cfg)
	if not cfg.ParkingWaypointId then
		print_error("汽修店CarShop配置缺少停车点:", cfg.Id)

		return
	end

	local waypoint = gCS.SpoonRaidMgr.Instance:GetWayPointData(cfg.ParkingWaypointId)

	if not waypoint then
		print_error("汽修店停车点不存在:", cfg.Id, cfg.ParkingWaypointId)

		return
	end

	return waypoint.position, waypoint.facing
end

M.InitRepairShopData = function(self, carShopId)
	self.curtRepairShopId = carShopId
	local vehicleId = gApplyCarManager:GetParkingVehicleCfgId()

	if not vehicleId or vehicleId ~= 0 then
		print_error("没有找到玩家当前车辆，无法进入汽修店")

		return false
	end

	if not self:CheckVehicleOwned(vehicleId) then
		print_error("玩家开了不属于自己的车进入改装店，vehicleId=", vehicleId)

		return false
	end

	self.curtRepairCfgId = vehicleId
	self.isRepairModified = false

	self:RebuildBasePartMap(vehicleId)

	return true
end

M.CheckVehicleOwned = function(self, vehicleId)
	local unlockedList = gApplyCarManager and gApplyCarManager.UnlockedVehicles

	if unlockedList and unlockedList.Count then
		for i = 1, unlockedList.Count do
			local info = unlockedList[i]

			if info and info.Id ~= vehicleId then
				return true
			end
		end
	end

	return false
end

M.Begin4SShop = function(self, param)
	local data = param or {}
	local shopId = data.shopId or 0

	if shopId ~= 0 then
		print_error("4S店shopId无效")

		return
	end

	local pos = data.pos
	local facing = data.facing or 0
	local endPos = data.endPos
	local endFacing = data.endFacing
	data.shopType = M.SHOP_TYPE.BUY
	data.shopId = shopId
	local ok = self:OnBeginShop(shopId, M.SHOP_TYPE.BUY, pos, facing, endPos, endFacing)

	if not ok then
		return
	end

	gPanelManager:CheckShow(gPanelId.CAR_STORE_PANEL, data)
end

M.BeginRepairShop = function(self, param)
	local data = param or {}
	local carShopId = data.carShopId or 0

	if carShopId ~= 0 then
		print_error("汽修店的carShopId无效")

		return
	end

	local carShopCfg = self:GetRepairShopCfg(carShopId)

	if not carShopCfg then
		return
	end

	local shopId = carShopCfg and carShopCfg.ShopID or 0
	local pos, facing = self:GetRepairShopPosAndRot(carShopCfg)
	local ok = self:InitRepairShopData(carShopId)

	if not ok then
		return
	end

	if shopId ~= 0 then
		print_error("汽修店ShopID无效", carShopId)

		return
	end

	data.shopType = M.SHOP_TYPE.REPAIR
	data.shopId = shopId

	self:InitClientShopInfo(shopId)

	local hasValidPart = self:CheckAnyValidPart(self.curtRepairCfgId)

	if not hasValidPart then
		gDisplayMessageMgr:ShowMessage(MessageConfig.CarRepairNoneExtension)

		return
	end

	local ok = self:OnBeginShop(shopId, M.SHOP_TYPE.REPAIR, pos, facing)

	if not ok then
		return
	end

	gPanelManager:CheckShow(gPanelId.CAR_MODS_PANEL, data)
end

M.GetTabIdsByModsType = function(self, modsType)
	local tabIds = {}

	for i = 0, VehiclePartShopTabConfig.count - 1 do
		local cfg = VehiclePartShopTabConfig.LoadAt(i)

		if cfg and cfg.PanelTab ~= modsType then
			table.insert(tabIds, cfg.Id)
		end
	end

	return tabIds
end

M.InitClientShopInfo = function(self, shopId)
	if self.shopId ~= shopId then
		return
	end

	self.localActiveVehiclePartSet = {}
	local shopCfg = NpcShopConfig.GetConfig(shopId)

	if not shopCfg then
		print_error("NpcShopConfig missing", shopId)

		return
	end

	local commodityGroupIdList = shopCfg.CommodityGroupIdList

	for _, id in pairs(commodityGroupIdList) do
		local commodityCfg = NpcShopCommodityGroupCfg.GetConfig(id)

		if not commodityCfg then
			print_error("C_NewCarStoreMgr:InitClientShopInfo 商品配置不存在 CommodityId=", id)
		else
			local idList = commodityCfg.CommodityIDList

			for i, commodityId in pairs(idList) do
				local item = gShopManager:GenCommodityItem(commodityId, i)

				if not item then
					print_error("C_NewCarStoreMgr:InitClientShopInfo 商品生成失败 CommodityId=", commodityId)
				elseif item.Type ~= CommodityType.Consumable then
					local partId = item.Cfg.BindId

					if not partId then
						print_error("C_NewCarStoreMgr:InitClientShopInfo 载具部件商品类型错误,没有正确的找到部件BindId CommodityId=", commodityId)
					else
						self.localActiveVehiclePartSet[partId] = true
					end
				end
			end
		end
	end
end

M.CheckAnyValidPart = function(self, vehicleId)
	local activeParts = self:GetActiveVehiclePart(vehicleId, true)

	for _, v in pairs(activeParts) do
		if v and #v <= 0 then
			return true
		end
	end

	return false
end

M.InitServerShopInfo = function(self, groupList, groupDic, discountInfo)
	local paintDupSet = {}
	local colorCode2Idx = {}

	for groupId, commodityList in pairs(groupList) do
		for idx, item in pairs(commodityList) do
			local commodityId = item.CommodityId

			if not item.Cfg then
				print_error("C_NewCarStoreMgr:OnBeginShop 商品生成失败，没有获取到正确的商品Cfg CommodityId=", commodityId)
			elseif item.Type ~= CommodityType.Vehicle then
				local consumableCfg = ConsumableConfig.GetConfig(item.ConsumableID)
				local subType = consumableCfg.VehicleSubType

				if not subType then
					print_error("C_NewCarStoreMgr:OnBeginShop 载具商品错误，没有获取到正确的VehicleSubType CommodityId=", commodityId)
				else
					local vehicleInfo = {
						id = item.BindId,
						isGot = self.unlockedVehiclesDict[item.BindId] ~= true,
						vehicleSubType = subType
					}

					table.insert(self.currentVehicleList, vehicleInfo)

					self.vehicleId2CommodityId[item.BindId] = commodityId

					if commodityId then
						local partId = item.Cfg.BindId

						if not partId then
							print_error("C_NewCarStoreMgr:OnBeginShop @zhujiaying 载具部件商品配置错误，没有正确的找到部件BindId，检查Shop表 CommodityId=", commodityId)
						else
							local partCfg = VehiclePartConfig.GetConfig(item.Cfg.BindId)

							if not partCfg and not VehiclePartSuitConfig.GetConfig(partId) then
								print_error("C_NewCarStoreMgr:OnBeginShop @zhujiaying 载具部件商品配置错误，没有正确的找到商品绑定的部件cfg，检查VehiclePart表 CommodityId=", commodityId, " PartId=", partId)
							else
								self.vehiclePartId2CommodityId[partId] = commodityId
								self.activeVehiclePartSet[partId] = true

								if partCfg and partCfg.PartTag ~= VehiclePartTagConfig.Color and partCfg.MatType and partCfg.MatType > 0 then
									table.insert(self.paintGroupByMat[partCfg.MatType], partId)

									if not string.is_null_or_empty(partCfg.MainColor) then
										local dupKey = partCfg.MainColor .. "_" .. partCfg.MatType

										if paintDupSet[dupKey] then
											print_error("车漆配置重复：同 colorCode+MatType 存在多个 part", partCfg.MainColor, partCfg.MatType, partId)
										else
											paintDupSet[dupKey] = true
										end

										local idx = colorCode2Idx[partCfg.MainColor]

										if not idx then
											table.insert(self.paintGroupByColor, {
												colorCode = partCfg.MainColor,
												group = {}
											})

											idx = #self.paintGroupByColor
											colorCode2Idx[partCfg.MainColor] = idx
										end

										if not self.paintGroupByColor[idx].group[partCfg.MatType] then
											self.paintGroupByColor[idx].group[partCfg.MatType] = partId
										else
											print_error("车漆配置重复：同 colorCode+MatType 存在多个 part", partCfg.MainColor, partCfg.MatType, partId)
										end
									else
										print_error("车漆部件没有配置MainColor", partCfg.Id)
									end
								end

								self.commodityInfoDic[commodityId] = item
							end
						end
					end
				end
			end
		end
	end

	self.currentDiscount = discountInfo.CurrentDiscount
	self.isShopInfoReady = true

	gMessageManager:SendMessage(gEventConstants.CAR_SHOP_INFO_CHANGE)
end

M.OnBeginShop = function(self, shopId, shopType, pos, facing, endPos, endFacing)
	self.shopId = shopId or 0
	self.vehicleId2CommodityId = {}
	self.vehiclePartId2CommodityId = {}
	self.useDefaultSuitIdExpand = gGameSwitch.EnableVehicleDefaultSuitExpand ~= true
	self.isShopping = true
	self.isPopup = false
	self.isConfirmBuy = false
	self.isShopInfoReady = false
	self.shopType = shopType or M.SHOP_TYPE.BUY
	self.currentVehicleList = {}
	self.activeVehiclePartSet = {}
	self.unlockedVehiclesDict = {}
	self.commodityInfoDic = {}
	self.paintGroupByMat = {}

	for k, v in pairs(C_NewCarStoreMgr.MAT_TYPE) do
		self.paintGroupByMat[v] = {}
	end

	self.paintGroupByColor = {}
	self.currentShopCfg = NpcShopConfig.GetConfig(shopId)

	if not self.currentShopCfg then
		print_error("NpcShopConfig missing", shopId)

		self.isShopping = false

		return false
	end

	self.curtPos = pos and Vector3.New(pos.x, pos.y, pos.z) or self:GetCurrentPos()
	self.curtFacing = facing or 0
	self.endPos = endPos and Vector3.New(endPos.x, endPos.y, endPos.z) or self:GetCurrentPos()
	self.endFacing = endFacing or 0

	if shopType ~= M.SHOP_TYPE.BUY then
		LX6.Item.DynamicGoManager.SetDynamicGoActive(23001409, true)
	elseif shopType ~= M.SHOP_TYPE.REPAIR then
		self.isRepairModified = false

		gClientUtils.SetCameraRotateEnabled(false, gPanelId.CAR_STORE_PANEL)
	end

	DriveUtils.SwitchCarStoreRenderMode(true)

	if shopType ~= M.SHOP_TYPE.BUY then
		self.currentVehicle = nil
	end

	self.spawnSeq = 0
	local unlockedVehicles = gApplyCarManager.UnlockedVehicles

	for _, vehicleInfo in ipairs(unlockedVehicles) do
		self.unlockedVehiclesDict[vehicleInfo.Id] = true
	end

	gShopManager:GetShopCommodityInfo(shopId, function (isOk, groupList, groupDic, discountInfo)
		if not self.isShopping then
			return
		end

		if not isOk then
			print_error("C_NewCarStoreMgr:OnBeginShop 获取商店商品信息失败 ShopId=", shopId)

			return
		end

		self:InitServerShopInfo(groupList, groupDic, discountInfo)
	end)

	return true
end

M.OnCarShopInfoChange = function(self)
end

M.EndShop = function(self)
	if self.isShopping then
		self:Log("结束商店，清理数据")

		self.isShopping = false
		self.isShopInfoReady = false

		gClientUtils.SetCameraRotateEnabled(true, gPanelId.CAR_STORE_PANEL)

		if self.isPopup then
			gDisplayMessageMgr:CloseBombAll()

			self.isPopup = false
		end

		LX6.Item.DynamicGoManager.SetDynamicGoActive(23001409, false)
		DriveUtils.SwitchCarStoreRenderMode(false)

		if self.shopType ~= M.SHOP_TYPE.BUY then
			self:DestroyVehicle()
		elseif self.currentVehicle and not self.isRepairModified then
			self.currentVehicle:EnableVehicleColliders(true)
		end

		self.spawnSeq = 0

		self:SetCameraState(ViewType.None)
		gCS.CameraDataMgr.cinemachineManager:ExitMovementState(LX6.Cinemachine.EMovementCamState.BuyVehicle)
		self:DestroyLight()

		self.lastFiveDimScores = nil
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	if self.isShopping then
		gPanelManager:Close(gPanelId.CAR_STORE_PANEL)
		gPanelManager:Close(gPanelId.CAR_MODS_PANEL)
	end

	self:EndShop()
end

M.GetVehicleList = function(self)
	return self.currentVehicleList
end

M.GetCurrentPos = function(self)
	local unit = gCS.MyPlayerManager.PlayerUnit.PlayerObj

	return unit.position + unit.forward * 5
end

M.DestroyVehicle = function(self)
	if self.pendingVehicle then
		local uid = self.pendingVehicle.uid

		self:Log("离开商店销毁加载中载具", uid)
		DriveUtils.DestroyVehicleClient(uid)

		self.pendingVehicle = nil
	end

	if self.currentVehicle then
		local uid = self.currentVehicle.uid

		self:Log("离开商店销毁载具", uid)
		self.currentVehicle:HideVehicle()
		self.currentVehicle:EnableVehicleColliders(false)
		DriveUtils.DestroyVehicleClient(uid)

		self.currentVehicle = nil
	end
end

M.DisableCurrentVehicleColliders = function(self)
	if self.currentVehicle then
		self.currentVehicle:EnableVehicleColliders(false)
	end
end

M.CreateVehicle = function(self, vId, partsIds, callback)
	self.spawnSeq = (self.spawnSeq or 0) + 1
	local mySeq = self.spawnSeq

	self:Log("准备创建车辆", vId, "spawnSeq=", self.spawnSeq, partsIds)

	if self.shopType ~= M.SHOP_TYPE.REPAIR then
		gApplyCarManager:TryDestroyRealVehicle()
	end

	if self.pendingVehicle then
		local uid = self.pendingVehicle.uid

		self:Log("销毁正在加载的旧车辆", uid)
		DriveUtils.DestroyVehicleClient(uid)

		self.pendingVehicle = nil
	end

	if self.currentVehicle then
		self.currentVehicle:SetForceDummy(true)
		self.currentVehicle:EnableVehicleColliders(false)
	end

	local spawnParam = SpawnVehicleParam.New()
	spawnParam.position = self.curtPos
	spawnParam.facing = self.curtFacing
	spawnParam.forceLODLevel = LX6.Share.VehicleForceLODLevel.Highest

	spawnParam.beforeLoadAction = function(vehicle)
		if not self.isShopping or mySeq == self.spawnSeq then
			self:Log("beforeLoadAction 销毁车辆", vehicle.uid)
			DriveUtils.DestroyVehicleClient(vehicle.uid)

			return
		end

		self.pendingVehicle = vehicle

		vehicle:InitClientPartsData(partsIds)

		if self.currentVehicle then
			self.currentVehicle:HideVehicle()
		end
	end

	spawnParam.afterLoadAction = function(vehicle)
		if not self.isShopping or mySeq == self.spawnSeq then
			self:Log("afterLoadAction 销毁车辆", vehicle.uid)
			DriveUtils.DestroyVehicleClient(vehicle.uid)

			return
		end

		if not vehicle.gameObject or gCS.LuaUtils.IsNull(vehicle.gameObject) or not vehicle.gameObject.transform then
			print_error("NewCarStoreMgr SpawnVehicle vehicle gameObject or transform is null, vId:" .. vId)

			return
		end

		self:Log("车辆创建完成", vehicle.uid)
		self:SetCameraAsShop(vehicle)
		vehicle:SetMainLightOn(false, true)
		vehicle:SetForceDummy(true)

		if callback then
			callback(vehicle)
		end

		if self.currentVehicle and self.currentVehicle.uid == vehicle.uid then
			self:Log("替换旧车辆", self.currentVehicle.uid)
			DriveUtils.DestroyVehicleClient(self.currentVehicle.uid)
		end

		self.currentVehicle = vehicle

		gCS.LuaUtils.ForceSetPlayerTransform(self.currentVehicle.gameObject.transform)

		if self.pendingVehicle ~= vehicle then
			self.pendingVehicle = nil
		end

		gMessageManager:SendMessage(gEventConstants.CAR_SHOP_VEHICLE_READY)
	end

	self:Log("开始创建车辆", vId, partsIds, self.curtPos, self.curtFacing)
	DriveUtils.SpawnVehicleClient(vId, spawnParam)
end

M.SetWeather = function(self, isOpen)
	gCS.GuiUtils.SetXuWeiWeatherState(isOpen, 8)
end

M.SetCameraAsShop = function(self, vehicle)
	if not vehicle then
		return
	end

	gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.BuyVehicle, vehicle)
end

M.SetCameraState = function(self, camearaState)
	if not self.currentVehicle then
		return
	end

	camearaState = camearaState or ViewType.Center
	LX6.Cinemachine.BuyVehicleCameraState.CurViewType = camearaState
end

M.CreateLight = function(self)
	self:LoadLight()

	if not self.isLightLoaded then
		return
	end

	if self.lightInstance and not gCS.LuaUtils.IsNull(self.lightInstance) then
		return
	end

	self.lightInstance = GameObject.Instantiate(self.lightLoadOp.asset)

	self.lightInstance:SetActive(false)
end

M.LoadLight = function(self)
	if self.isLightLoaded then
		return
	end

	local lightPath = "Assets/Res/vehicles/super/car_s_super002/main_lights.prefab"
	local loadOp = gResourceManager:LoadAsset(lightPath, typeof(UnityEngine.GameObject))

	if not loadOp.asset or gCS.LuaUtils.IsNull(loadOp.asset) then
		print_error("Failed to load 4S Probe light prefab at path: " .. lightPath)

		return
	end

	self.lightLoadOp = loadOp
	self.isLightLoaded = true
end

M.UnloadLight = function(self)
	if self.lightLoadOp then
		gResourceManager:UnloadAssetLoadOp(self.lightLoadOp)
	end

	self.lightLoadOp = nil
	self.isLightLoaded = false
end

M.SetLight = function(self)
	if not self.lightInstance or gCS.LuaUtils.IsNull(self.lightInstance) then
		print_error("4S Probe light instance is not loaded")

		return
	end

	self.lightInstance.transform.position = self.curtPos
	self.lightInstance.transform.rotation = Quaternion.Euler(0, 140, 0)

	self.lightInstance:SetActive(true)
end

M.DestroyLight = function(self)
	if self.lightInstance and not gCS.LuaUtils.IsNull(self.lightInstance) then
		GameObject.Destroy(self.lightInstance)
	end

	self.lightInstance = nil
end

M.GetPartActiveList = function(self, infoList, isLocal)
	local ret = {}

	for i = 1, #infoList do
		local kit = infoList[i]

		if self:CheckGroupPartActive(kit, isLocal) then
			ret[#ret + 1] = kit
		end
	end

	return ret
end

M.GetActiveVehiclePart = function(self, vehicleId, isLocal)
	local cfg = VehicleConfig.GetConfig(vehicleId)
	local ret = {}

	for i = 0, VehiclePartShopTabConfig.count - 1 do
		local tabCfg = VehiclePartShopTabConfig.LoadAt(i)
		local partList = cfg[tabCfg.CfgName]
		ret[tabCfg.Id] = self:GetPartActiveList(partList, isLocal)
	end

	return ret
end

M.GetDefaultModifyInfo = function(self, vehicleId, infos, indexs, exceptTagList)
	local ret = {}

	if self.shopType ~= M.SHOP_TYPE.REPAIR and self.curtRepairDefaultPartSet then
		for partId in pairs(self.curtRepairDefaultPartSet) do
			if partId and partId == 0 then
				local cfg = VehiclePartConfig.GetConfig(partId)

				if cfg then
					ret[cfg.PartTag] = partId
				else
					print_error("汽修店模式下，默认部件数据异常，找不到对应cfg", vehicleId, partId)
				end
			end
		end
	end

	for k, v in ipairs(infos) do
		if k ~= VehiclePartShopTabConfig.Suit and self.shopType ~= M.SHOP_TYPE.BUY and indexs[k] ~= 0 then
			local vehicleCfg = VehicleConfig.GetConfig(vehicleId)
			local defaultSuit = vehicleCfg and self:GetDefaultSuitParts(vehicleCfg)

			if defaultSuit and #defaultSuit <= 0 then
				local hasBody = false

				for i = 1, #defaultSuit do
					local partId = defaultSuit[i]

					if partId and partId == 0 then
						local cfg = VehiclePartConfig.GetConfig(partId)

						if cfg and (not exceptTagList or not table.contains(exceptTagList, cfg.PartTag)) then
							ret[cfg.PartTag] = partId

							if cfg.PartTag ~= VehiclePartTagConfig.body then
								hasBody = true
							end
						end
					end
				end

				if not hasBody then
					print_error("[GetDefaultModifyInfo] vehicleId=", vehicleId, " DefaultSuit 未包含 Body 部件，请检查配表")
				end
			else
				print_error("[GetDefaultModifyInfo] vehicleId=", vehicleId, " DefaultSuit 未配置，请检查配表")
			end
		elseif #v <= 0 then
			local index = indexs[k]

			if not index then
				print_error("GetDefaultModifyInfo 部件索引异常", vehicleId, k, index)
			elseif index ~= 0 then
				-- Nothing
			else
				local ele = v[index]

				if not ele then
					print_error("GetDefaultModifyInfo 部件数据异常", vehicleId, k, index)
				elseif type(ele) ~= "number" then
					if ele == 0 then
						if k ~= VehiclePartShopTabConfig.Suit then
							local suitCfg = VehiclePartSuitConfig.GetConfig(ele)

							if suitCfg then
								local vehicleCfg = VehicleConfig.GetConfig(vehicleId)
								local isDefaultSuit = vehicleCfg == nil and ele ~= vehicleCfg.DefaultSuitId

								local tryWrite = function(partId)
									if not partId or partId ~= 0 then
										return
									end

									local cfg = VehiclePartConfig.GetConfig(partId)

									if cfg and (not exceptTagList or not table.contains(exceptTagList, cfg.PartTag)) then
										ret[cfg.PartTag] = partId
									end
								end

								if suitCfg.Suit then
									for i = 1, #suitCfg.Suit do
										tryWrite(suitCfg.Suit[i])
									end
								end

								if not isDefaultSuit then
									tryWrite(suitCfg.SuitPaint)
								end

								if not ret[VehiclePartTagConfig.body] then
									print_error("[GetDefaultModifyInfo] suitId=", ele, " Suit[] 未包含 Body 部件，请检查配表")
								end
							end
						else
							local cfg = VehiclePartConfig.GetConfig(ele)

							if cfg and (not exceptTagList or not table.contains(exceptTagList, cfg.PartTag)) then
								ret[cfg.PartTag] = ele
							end
						end
					end
				else
					for _, partId in pairs(ele) do
						if partId == vehicleId and partId == 0 then
							local cfg = VehiclePartConfig.GetConfig(partId)

							if cfg and (not exceptTagList or not table.contains(exceptTagList, cfg.PartTag)) then
								ret[cfg.PartTag] = partId
							end
						end
					end
				end
			end
		end
	end

	return table.to_array(ret)
end

M.CheckGroupPartActive = function(self, partIdList, isLocal)
	if type(partIdList) ~= "number" then
		return self:_IsValidPart(partIdList, isLocal)
	end

	for key, partId in pairs(partIdList) do
		if not string.starts_with(key, "__") and partId == 0 and not self:_IsValidPart(partId, isLocal) then
			return false
		end
	end

	return true
end

M._IsValidPart = function(self, partId, isLocal)
	if isLocal then
		return self.localActiveVehiclePartSet[partId] or false
	else
		return self.activeVehiclePartSet[partId] or false
	end
end

M.GetActivePaintFor4S = function(self, colorModifyInfo)
	local partId2colorModifyIndex = {}

	for i = 1, #colorModifyInfo do
		partId2colorModifyIndex[colorModifyInfo[i]] = i
	end

	local result = {}

	for _, entry in ipairs(self.paintGroupByColor) do
		local group = {}

		for _, partId in pairs(entry.group) do
			local modifyIdx = partId2colorModifyIndex[partId]

			if modifyIdx then
				table.insert(group, modifyIdx)
			end
		end

		table.insert(result, {
			colorCode = entry.colorCode,
			group = group
		})
	end

	return result
end

M.GetActivePaintForRepair = function(self, colorModifyInfo)
	local partId2colorModifyIndex = {}
	local paintGroupByMat = {}

	for i = 1, #colorModifyInfo do
		partId2colorModifyIndex[colorModifyInfo[i]] = i
	end

	for matType, group in pairs(self.paintGroupByMat) do
		paintGroupByMat[matType] = {}

		for idx, partId in pairs(group) do
			local modifyIdx = partId2colorModifyIndex[partId]

			if modifyIdx then
				table.insert(paintGroupByMat[matType], modifyIdx)
			end
		end
	end

	return paintGroupByMat
end

M.GetCurrentMoney = function(self)
	if not self.currentShopCfg then
		return 0
	end

	return gUIUtils:GetMoneyByType(UX.Game.MoneyType.Money)
end

M.GetPartPriceAndMoneyIcon = function(self, partList, tabIndex)
	if type(partList) ~= "number" then
		partList = {
			partList
		}
	end

	if tabIndex and not self.partShowFieldName[tabIndex] then
		local partTag = VehiclePartShopTabConfig.LoadAt(tabIndex - 1).DisplayTag
		local partCfg = VehiclePartTagConfig.GetConfig(partTag)
		self.partShowFieldName[tabIndex] = partCfg and partCfg.Desc or ""
	end

	local tot = 0
	local icon = 0
	local cmInfo = nil

	for k, v in pairs(partList) do
		if not string.starts_with(k, "__") then
			local comId = self.vehiclePartId2CommodityId[v] or self.vehicleId2CommodityId[v]
			local tmpInfo = comId and self.commodityInfoDic[comId]

			if tmpInfo then
				tot = tot + tmpInfo.PriceCurrent
				icon = tmpInfo.MoneyIconId
			end

			if cmInfo then
				if tabIndex and k ~= self.partShowFieldName[tabIndex] then
					cmInfo = tmpInfo
				end
			else
				cmInfo = tmpInfo
			end
		end
	end

	return tot, icon, cmInfo
end

M.AskBuyCar = function(self, partList, vehicleId, cb)
	if not self.isShopping then
		return
	end

	local commodityDic = {}

	for i = 1, #partList do
		local partId = partList[i]
		local commodityId = self.vehiclePartId2CommodityId[partId]

		if not commodityId then
			print_error("C_NewCarStoreMgr:AskBuyCar 没有找到对应部件的commodityId，跳过", "partId = ", partId)
		else
			local cmInfo = self.commodityInfoDic[commodityId]

			if not cmInfo then
				print_error("C_NewCarStoreMgr:AskBuyCar 没有找到对应部件的commodityInfo", "partId = ", partId, "commodityId=", commodityId)
			elseif cmInfo.SoldOut then
				print_error("C_NewCarStoreMgr:AskBuyCar 部件已售罄", "partId = ", partId, "commodityId=", commodityId)

				return
			else
				commodityDic[commodityId] = 1
			end
		end
	end

	if table.is_empty(commodityDic) then
		print_error("C_NewCarStoreMgr:AskBuyCar 没有需要购买的部件")

		return
	end

	local vehicleCommodityId = self.vehicleId2CommodityId[vehicleId]

	if vehicleCommodityId then
		commodityDic[vehicleCommodityId] = 1
	else
		print_error("C_NewCarStoreMgr:AskBuyCar 没有找到对应车辆的commodityId", vehicleId)

		return
	end

	self:Log("AskBuyCar", "partList", partList, "commodityList", commodityDic)

	gClientToGameDelegate:AskBuyCommodities(self.shopId, commodityDic).Callback = function (err)
		if err ~= MessageConfig.Ok then
			self.isConfirmBuy = true

			if cb then
				cb()
			end
		else
			local msg = self:ConcatCommodityLogMsg(commodityDic)

			gDisplayMessageMgr:ShowMessageContentDebug("4S店买车失败, commodityList=" .. msg, err)
			print_error("4S店买车失败, commodityList=" .. msg, err)
		end
	end
end

M.AskBuyParts = function(self, partList, vehicleId, cb, removedPartTypes)
	if not self.isShopping then
		return
	end

	local commodityDic = {}

	for i = 1, #partList do
		local partId = partList[i]

		if not self:IsPartEquipped(partId) then
			local commodityId = self.vehiclePartId2CommodityId[partId]

			if not commodityId then
				print_error("C_NewCarStoreMgr:AskBuyParts 没有找到对应部件的commodityId", "partId = ", partId)

				return
			end

			local cmInfo = self.commodityInfoDic[commodityId]

			if not cmInfo then
				print_error("C_NewCarStoreMgr:AskBuyParts 没有找到对应部件的commodityInfo", "partId = ", partId, "commodityId=", commodityId)

				return
			elseif cmInfo.SoldOut then
				print_error("C_NewCarStoreMgr:AskBuyParts 部件已售罄", "partId = ", partId, "commodityId=", commodityId)

				return
			else
				commodityDic[commodityId] = 1
			end
		end
	end

	if table.is_empty(commodityDic) then
		print_error("C_NewCarStoreMgr:AskBuyParts 没有需要购买的部件")

		return
	end

	self:Log("AskBuyParts", "partList", partList, "commodityList", commodityDic)

	gClientToGameDelegate:AskBuyModifyParts(self.shopId, vehicleId, commodityDic, removedPartTypes or {}).Callback = function (err)
		if err ~= MessageConfig.Ok then
			self.isConfirmBuy = true

			if cb then
				cb()
			end
		else
			local msg = self:ConcatCommodityLogMsg(commodityDic)

			gDisplayMessageMgr:ShowMessageContentDebug("汽修店购买改装件失败, commodityList=", msg)
			print_error("汽修店购买改装件失败, commodityList=", msg, gCS.Error.GetNameById(err))
		end
	end
end

M.AskRemoveParts = function(self, vehicleId, partTagList, cb)
	if not self.isShopping then
		return
	end

	if not vehicleId or not partTagList or #partTagList ~= 0 then
		print_error("[NewCarStoreMgr] AskRemoveParts: 参数无效")

		return
	end

	self:Log("AskRemoveParts", "vehicleId", vehicleId, "partTagList", partTagList)

	gClientToGameDelegate:AskBuyModifyParts(self.shopId, vehicleId, {}, partTagList).Callback = function (err)
		if err ~= MessageConfig.Ok then
			self.isConfirmBuy = true

			if cb then
				cb()
			end
		else
			print_error("[NewCarStoreMgr] AskRemoveParts 失败", err, "vehicleId=", vehicleId)
		end
	end
end

M.ConcatCommodityLogMsg = function(self, commodityDic)
	local msg = "["

	for commodityId, _ in pairs(commodityDic) do
		msg = msg .. commodityId .. ","
	end

	msg = msg .. "]"

	return msg
end

M.AskVehicleShopSpawnVehicle = function(self, vehicleId, isBind, cb)
	gClientToGameDelegate:AskVehicleShopSpawnVehicle(self.shopId, vehicleId, isBind).Callback = function (err, vehicleUid)
		if err ~= LTConfig.MessageConfig.Ok and cb then
			cb(vehicleUid)
		end
	end
end

M.LoadEndTimeLine = function(self, type, playCb)
	if not type or type ~= 0 then
		print_error("4S汽修店，车辆类型错误，无法播放购车Timeline", type)

		return
	end

	if self.endPos ~= Vector3.zero then
		print_error("4S汽修店，购车Timeline结束位置未设置，无法播放", type)

		return
	end

	local info = ConsumableConfig.VehicleShopEndTimeLine[type]

	if info then
		local data = gTimelineManager:Timeline_CreateTimelineData()
		data.pos = self.endPos
		data.loadCheck_Condition = 1
		data.loadCheck_FailedPlay = false
		data.rot = Vector3.New(0, self.endFacing, 0)

		data.onPlayCallback = function(t)
			playCb()
		end

		gTimelineManager:Timeline_LoadAndPlay(info.timelineName, data)
	else
		print_error("4S汽修店，该车辆类型没有配置购车Timeline，无法播放", type)
	end
end

M.LeaveFromRepairShop = function(self)
	gApplyCarManager:RequestLeaveRepairShop()
end

M.OnLeaveRepairShopComplete = function(self)
	self.isRepairModified = false
	self.curtRepairCfgId = nil
	self.curtRepairShopId = nil
end

M.RenderCarInfoTooltip = function(self, store, id)
	if not store then
		print_error("C_NewCarStoreMgr:RenderCarInfoTooltip 车辆信息tooltipStore不存在")

		return
	end

	local cfg = VehicleConfig.GetConfig(id)

	if not cfg then
		print_error("C_NewCarStoreMgr:RenderCarInfoTooltip 车辆配置不存在，车辆ID：" .. tostring(id))

		return
	end

	store.logo = cfg.SVehicleBrandIcon
	store.carName = cfg.VehicleName
	store.chairNum = cfg.VehicleSeatNum
	store.quality = cfg.VehicleQuality
	store.vehicleTypeText = VehicleTypeConfig.GetConfig(cfg.VehicleType).DisplayName
	local featureCfg = gCarStoreManager:GetFeatureByVehicleId(id)
	local scoreList = {}

	if featureCfg == nil then
		for i = 1, 5 do
			local view = {}

			if VehicleConfig["Feature" .. i .. "Name"] and featureCfg["Feature" .. i] then
				view.title = VehicleConfig["Feature" .. i .. "Name"]
				view.progress = featureCfg["Feature" .. i]

				table.insert(scoreList, view)
			end
		end

		store.scoreList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnRenderAttributeListItem, scoreList)

		store.scoreList:SetSimpleList(#scoreList)
	else
		print_error("#NoCreateIssue @zhujiaying 车辆属性配置缺失，车辆ID：" .. tostring(id))
		store.scoreList:SetSimpleList(0)
	end
end

M.OnRenderAttributeListItem = function(self, scoreList, btn, index)
	local data = scoreList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.title = data.title
		store.des = data.title
		store.progress.value = data.progress
		store.scoreText = data.progress
	end
end

M.RenderCarInfoTooltipV2 = function(self, store, id)
	if not store then
		print_error("C_NewCarStoreMgr:RenderCarInfoTooltipV2 车辆信息tooltipStore不存在")

		return
	end

	local cfg = VehicleConfig.GetConfig(id)

	if not cfg then
		print_error("C_NewCarStoreMgr:RenderCarInfoTooltipV2 车辆配置不存在，车辆ID：" .. tostring(id))

		return
	end

	store.logo = cfg.SVehicleBrandIcon
	store.carName = cfg.VehicleName
	store.chairNum = cfg.VehicleSeatNum
	store.quality = cfg.VehicleQuality
	store.vehicleTypeText = VehicleTypeConfig.GetConfig(cfg.VehicleType).DisplayName
	local scores = nil

	if self.currentVehicle and self.currentVehicle.cfgId ~= id then
		local partArray = self:GetEffectiveParts({})
		local ok, s = gCS.LuaUtils.TryGetFiveDimScoresWithPartList(self.currentVehicle, partArray, _)

		if ok and s then
			scores = {
				s.topSpeed,
				s.acceleration,
				s.brake,
				s.handling,
				s.defense
			}
			self.lastFiveDimScores = scores
		end
	end

	scores = scores or self.lastFiveDimScores

	if scores then
		local scoreList = {}

		for i = 1, 5 do
			local name = VehicleConfig["Feature" .. i .. "Name"]

			if name and name == "" and scores[i] == nil then
				table.insert(scoreList, {
					title = name,
					progress = math.floor(scores[i])
				})
			end
		end

		store.scoreList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnRenderAttributeListItem, scoreList)

		store.scoreList:SetSimpleList(#scoreList)
	else
		store.scoreList:SetSimpleList(0)
	end
end

gNewCarStoreMgr = gNewCarStoreMgr or C_NewCarStoreMgr.new()
