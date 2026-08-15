local MessageConfig = LTConfig.MessageConfig
local VehiclePartConfig = LTConfig.VehiclePartConfig
local VehicleConfig = LTConfig.VehicleConfig
local NpcShopCommodityCfg = LTConfig.ShopCommodityConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local SpawnVehicleParam = LX6.Drive.SpawnVehicleParam
local DriveUtils = LX6.Drive.DriveUtils
local NpcShopConfig = LTConfig.ShopConfig
local VehiclePartShopTabConfig = LTConfig.VehiclePartShopTabConfig
local VehicleColorConfig = LTConfig.VehicleColorConfig
local ViewType = LTConfig.VehiclePartShopTabConfig.ViewTypeType
local ShopConfig = LTConfig.ShopConfig
local VehiclePartTagConfig = LTConfig.VehiclePartTagConfig
local StaticProps = {}
C_NewCarStoreMgr = DefClass("C_NewCarStoreMgr", C_NewCarStoreMgr, nil, StaticProps)
local M = C_NewCarStoreMgr

function M:ctor()
	self.commdityInfoList = {}
	self.commdity2VehicleInfo = {}
	self.vehicleId2CommdityId = {}
	self.currentVehicle = nil
	self.pendingVehicle = nil
	self.spawnSeq = 0
	self.DisplayType = {
		Vehicle = 0,
		Part = 1
	}
	self.BOOL2CTL = {
		[true] = 1,
		[false] = 0
	}
	self.defaultColor = "#404040"
	self.isDebug = true
	self.partShowFieldName = {}
	self.part2colorCode = {}

	for i = 1, #VehiclePartConfig.MatGroup do
		local groupId = VehiclePartConfig.MatGroup[i]
		local cfg = VehiclePartConfig.GetConfig(groupId)

		for j = 1, #cfg.BindParts do
			local partId = cfg.BindParts[j]
			local colorPartCfg = VehiclePartConfig.GetConfig(partId)
			local colorCfg = VehicleColorConfig.GetConfig(colorPartCfg.PartID)
			self.part2colorCode[partId] = colorCfg.MainColor
		end
	end

	self.isLightLoaded = false
	self.lightLoadOp = nil
	self.lightInstance = nil
end

function M:Log(...)
	if self.isDebug then
		print_debug("[C_NewCarStoreMgr]", ...)
	end
end

function M:OnBeginShop(shopId, pos, facing, endPos, endFacing)
	self:SetKeepScene(true)
	LX6.Item.DynamicGoManager.SetDynamicGoActive(23001409, true)
	self:SetWeather(true)
	DriveUtils.SwitchCarStoreRenderMode(true)

	self.isShopping = true
	self.currentVehicleList = {}
	self.currentVehiclePartList = {}
	self.activeVehicleDict = {}
	self.unlockedVehiclesDict = {}
	self.commdityInfoList = {}
	self.currentShopCfg = NpcShopConfig.GetConfig(shopId)
	self.curtPos = pos and Vector3.New(pos.x, pos.y, pos.z) or self:GetCurrentPos()
	self.curtfacing = facing or 0
	self.endPos = endPos and Vector3.New(endPos.x, endPos.y, endPos.z) or self:GetCurrentPos()
	self.endFacing = endFacing or 0

	self:SetLight()

	self.currentVehicle = nil
	self.spawnSeq = 0
	local unlockedVehicles = gApplyCarManager.UnlockedVehicles

	for _, vehicleInfo in ipairs(unlockedVehicles) do
		self.unlockedVehiclesDict[vehicleInfo.Id] = true
	end

	gClientToGameDelegate:AskNpcShopCommodityInfo(shopId).Callback = function (err, npcShopInfo)
		if err == MessageConfig.Ok then
			local commodityInfoList = npcShopInfo.CommodityInfoList

			for i = 1, #commodityInfoList do
				local info = self:GetVehicleDetailInfoByCommdity(commodityInfoList[i].TemplateId)

				if info then
					if info.isVehicle then
						self.currentVehicleList[#self.currentVehicleList + 1] = {
							id = info.id,
							isGot = self.unlockedVehiclesDict[info.id] == true,
							vehicleSubType = info.vehicleSubType
						}
					else
						local partCfg = VehiclePartConfig.GetConfig(info.id)
						self.currentVehiclePartList[partCfg.PartTag] = self.currentVehiclePartList[partCfg.PartTag] or {}

						table.insert(self.currentVehiclePartList[partCfg.PartTag], info.id)
					end

					self.activeVehicleDict[info.id] = true
					self.vehicleId2CommdityId[info.id] = commodityInfoList[i].TemplateId
					self.commdityInfoList[commodityInfoList[i].TemplateId] = gShopManager:GenCommodityItem(commodityInfoList[i].TemplateId, i)
				end
			end

			gShopManager:UpdateCommodityInfo(self.commdityInfoList, commodityInfoList)

			self.currentDiscount = npcShopInfo.CurrentDiscount

			gMessageManager:SendMessage(gEventConstants.CAR_SHOP_INFO_CHANGE)
		end
	end
end

function M:OnEndShop()
	if self.isShopping then
		self.isShopping = false

		LX6.Item.DynamicGoManager.SetDynamicGoActive(23001409, false)
		DriveUtils.SwitchCarStoreRenderMode(false)
		self:OnDestroyVehicle()

		self.spawnSeq = 0

		self:SetCameraState(ViewType.None)
		self:SetWeather(false)
		self:SetKeepScene(false)
		gCS.CameraDataMgr.cinemachineManager:ExitMovementState(LX6.Cinemachine.EMovementCamState.BuyVehicle)

		gClientToGameDelegate:AskCloseNpcShop(self.currentShopCfg.Id).Callback = function (err)
			if err ~= MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end

		self:DestroyLight()
	end
end

function M:OnBeforeSwitchScene(switchType)
	if self.isShopping then
		gPanelManager:Close(gPanelId.CAR_STORE_PANEL)
		self:OnEndShop()
	end

	self:SetKeepScene(false)
	self:UnloadLight()
end

function M:GetVehicleDetailInfoByCommdity(CommdityId)
	if self.commdity2VehicleInfo[CommdityId] then
		return self.commdity2VehicleInfo[CommdityId]
	end

	local shopCfg = NpcShopCommodityCfg.GetConfig(CommdityId)

	if not shopCfg then
		return
	end

	local cfg = ConsumableConfig.GetConfig(shopCfg.ConsumableID)

	if not cfg then
		return
	end

	local vehicleCfg = VehicleConfig.GetConfig(cfg.BindId)

	if not vehicleCfg then
		local partCfg = VehiclePartConfig.GetConfig(cfg.BindId)

		if not partCfg then
			return
		end

		self.commdity2VehicleInfo[CommdityId] = {
			isVehicle = false,
			id = cfg.BindId
		}

		return self.commdity2VehicleInfo[CommdityId]
	end

	self.commdity2VehicleInfo[CommdityId] = {
		isVehicle = true,
		id = cfg.BindId,
		vehicleSubType = cfg.VehicleSubType
	}

	return self.commdity2VehicleInfo[CommdityId]
end

function M:GetVehicleList()
	return self.currentVehicleList
end

function M:GetCurrentPos()
	local unit = gCS.MyPlayerManager.PlayerUnit.PlayerObj

	return unit.position + unit.forward * 5
end

function M:OnDestroyVehicle()
	if self.pendingVehicle then
		local uid = self.pendingVehicle.uid

		self:Log("离开商店销毁加载中载具", uid)
		DriveUtils.DestroyVehicleClient(uid)

		self.pendingVehicle = nil
	end

	if self.currentVehicle then
		local uid = self.currentVehicle.uid

		self:Log("离开商店销毁载具", uid)
		DriveUtils.DestroyVehicleClient(uid)

		self.currentVehicle = nil
	end
end

function M:OnCreateVehicle(vId, partsId, callback)
	self.spawnSeq = (self.spawnSeq or 0) + 1
	local mySeq = self.spawnSeq

	if self.pendingVehicle then
		local uid = self.pendingVehicle.uid

		self:Log("销毁正在加载的旧车辆", uid)
		DriveUtils.DestroyVehicleClient(uid)

		self.pendingVehicle = nil
	end

	local spawnParam = SpawnVehicleParam.New()
	spawnParam.position = self.curtPos
	spawnParam.facing = self.curtfacing
	spawnParam.forceDummy = true
	spawnParam.disableCollision = true
	spawnParam.forceLODLevel = LX6.Share.VehicleForceLODLevel.Highest

	function spawnParam.beforeLoadAction(vehicle)
		if not self.isShopping or mySeq ~= self.spawnSeq then
			self:Log("beforeLoadAction 销毁车辆", vehicle.uid)
			DriveUtils.DestroyVehicleClient(vehicle.uid)

			return
		end

		self.pendingVehicle = vehicle

		vehicle:InitClientPartsData(partsId)

		if self.currentVehicle then
			self.currentVehicle:HideVehicle()
		end
	end

	function spawnParam.afterLoadAction(vehicle)
		if not self.isShopping or mySeq ~= self.spawnSeq then
			self:Log("afterLoadAction 销毁车辆", vehicle.uid)
			DriveUtils.DestroyVehicleClient(vehicle.uid)

			return
		end

		self:Log("车辆创建完成", vehicle.uid)
		self:SetCameraAsShop(vehicle)
		vehicle:SetMainLightOn(false, true)
		vehicle:FixVehicleTouchGroundOffset(self.curtPos.y)

		if callback then
			callback(vehicle)
		end

		if self.currentVehicle and self.currentVehicle.uid ~= vehicle.uid then
			self:Log("替换旧车辆", self.currentVehicle.uid)
			DriveUtils.DestroyVehicleClient(self.currentVehicle.uid)
		end

		self.currentVehicle = vehicle

		gCS.LuaUtils.ForceSetPlayerTransform(self.currentVehicle.gameObject.transform)

		if self.pendingVehicle == vehicle then
			self.pendingVehicle = nil
		end
	end

	self:Log("开始创建车辆", vId, partsId, self.curtPos, self.curtfacing)
	DriveUtils.SpawnVehicleClient(vId, spawnParam)
end

function M:SetWeather(isOpen)
	gCS.GuiUtils.SetXuWeiWeatherState(isOpen, 8)
end

function M:SetKeepScene(value)
	if self.keepSceneHandleId then
		LX6.Scene.SceneTargetManager.Instance:Second_ReleaseTarget(self.keepSceneHandleId)

		self.keepSceneHandleId = nil
	end

	if value then
		local playerPos = gCS.MyPlayerManager.PlayerUnit.PlayerObj.position
		local lodFactor = 3
		local mipMapRadius = 3
		self.keepSceneHandleId = LX6.Scene.SceneTargetManager.Instance:AddSecondTarget(playerPos, lodFactor, mipMapRadius, "CarStoreKeep")
	end
end

function M:SetCameraAsShop(vehicle)
	if not vehicle then
		return
	end

	gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.BuyVehicle, vehicle)
end

function M:SetCameraState(camearaState)
	if not self.currentVehicle then
		return
	end

	camearaState = camearaState or ViewType.Center
	LX6.Cinemachine.BuyVehicleCameraState.CurViewType = camearaState
end

function M:CreateLight()
	self:LoadLight()

	if not self.isLightLoaded then
		return
	end

	if self.lightInstance and not gCS.LuaUtils.IsNull(self.lightInstance) then
		return
	end

	self.lightInstance = GameObject.Instantiate(self.lightLoadOp.asset)
end

function M:LoadLight()
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

function M:UnloadLight()
	if self.lightLoadOp then
		gResourceManager:UnloadAssetLoadOp(self.lightLoadOp)
	end

	self.lightLoadOp = nil
	self.isLightLoaded = false
end

function M:SetLight()
	if not self.lightInstance or gCS.LuaUtils.IsNull(self.lightInstance) then
		print_error("4S Probe light instance is not loaded")

		return
	end

	self.lightInstance.transform.position = self.curtPos
	self.lightInstance.transform.rotation = Quaternion.Euler(0, 140, 0)

	gCS.LuaUtils.ForceAddCustomProbeByGo(self.lightInstance)
end

function M:DestroyLight()
	if self.lightInstance and not gCS.LuaUtils.IsNull(self.lightInstance) then
		GameObject.Destroy(self.lightInstance)
	end

	self.lightInstance = nil
end

function M:GetPartActiveList(infoList)
	local ret = {}

	for i = 1, #infoList do
		local kit = infoList[i]

		if self:CheckGroupPartActive(kit) then
			ret[#ret + 1] = kit
		end
	end

	return ret
end

function M:GetActiveVehiclePart(vehicleId)
	local cfg = VehicleConfig.GetConfig(vehicleId)
	local ret = {}

	for i = 0, VehiclePartShopTabConfig.count - 1 do
		local tabCfg = VehiclePartShopTabConfig.LoadAt(i)
		local partList = cfg[tabCfg.CfgName]
		ret[tabCfg.Id] = self:GetPartActiveList(partList)
	end

	return ret
end

function M:GetDefaultModifyInfo(vehicleId, infos, indexs, exceptTagList)
	local ret = {}

	for k, v in ipairs(infos) do
		if #v > 0 then
			local ele = v[indexs[k]]

			if type(ele) == "number" then
				if ele ~= 0 then
					local cfg = VehiclePartConfig.GetConfig(ele)

					if cfg and (not exceptTagList or not table.contains(exceptTagList, cfg.PartTag)) then
						ret[cfg.PartTag] = ele
					end
				end
			else
				for _, partId in pairs(ele) do
					if partId ~= vehicleId and partId ~= 0 then
						local cfg = VehiclePartConfig.GetConfig(partId)

						if cfg and (not exceptTagList or not table.contains(exceptTagList, cfg.PartTag)) then
							ret[cfg.PartTag] = partId
						end
					end
				end
			end
		end
	end

	return table.to_array(ret)
end

function M:CheckGroupPartActive(partIdList)
	if type(partIdList) == "number" then
		return self.activeVehicleDict[partIdList]
	end

	for key, partId in pairs(partIdList) do
		if not string.starts_with(key, "__") and partId ~= 0 and not self.activeVehicleDict[partId] then
			return false
		end
	end

	return true
end

function M:GetColorByPartId(partId)
	local partCfg = VehiclePartConfig.GetConfig(partId)

	if not partCfg then
		return self.defaultColor
	end

	local colorCfg = VehicleColorConfig.GetConfig(partCfg.PartID)

	if not colorCfg then
		return self.defaultColor
	end

	return colorCfg.MainColor
end

function M:GetActiveColorByModifyInfo(colorModifyInfo)
	local colorList = {}
	local colorDic = {}

	for i = 1, #colorModifyInfo do
		local colorCode = self.part2colorCode[colorModifyInfo[i]]

		if not colorCode then
			print_error("没有找到对应colorCode")
		end

		if colorDic[colorCode] == nil then
			colorDic[colorCode] = {}

			table.insert(colorList, colorCode)
		end

		table.insert(colorDic[colorCode], i)
	end

	return colorList, colorDic
end

function M:GetCurrentMoney()
	if not self.currentShopCfg then
		return 0
	end

	local _, money = gCommonItemManager:GetMoneyIconAndCount(self.currentShopCfg.Money)

	return money
end

function M:GetPartPriceAndMoneyIcon(partList, tabIndex)
	if type(partList) == "number" then
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
			local comId = self.vehicleId2CommdityId[v]
			local tmpInfo = comId and self.commdityInfoList[comId]

			if tmpInfo then
				tot = tot + tmpInfo.PriceCurrent
				icon = tmpInfo.MoneyIconId
			end

			if cmInfo then
				if tabIndex and k == self.partShowFieldName[tabIndex] then
					cmInfo = tmpInfo
				end
			else
				cmInfo = tmpInfo
			end
		end
	end

	return tot, icon, cmInfo
end

function M:AskBuyPartList(partList, cb)
	local commodityList = {}

	for i = 1, #partList do
		local partId = partList[i]
		local commodityId = self.vehicleId2CommdityId[partId]

		if commodityId then
			commodityList[commodityId] = 1
		end
	end

	self:Log("AskBuyPartList", "partList", partList, "commodityList", commodityList)

	gClientToGameDelegate:AskBuyCommodities(commodityList).Callback = function (err)
		if err == MessageConfig.Ok then
			if cb then
				cb()
			end
		else
			local msg = "["

			for commodityId in ipairs(commodityList) do
				msg = msg .. commodityId .. ","
			end

			msg = msg .. "]"

			gDisplayMessageMgr:ShowMessageContentDebug("NPC商店购买商品list失败, commodityList=" .. msg, err)
		end
	end
end

function M:AskVehicleShopSpawnVehicle(vehicleId, cb)
	gClientToGameDelegate:AskVehicleShopSpawnVehicle(vehicleId).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok and cb then
			cb()
		end
	end
end

function M:LoadEndTimeLine(type, playCb)
	if not type or type == 0 then
		print_error("4S汽修店，车辆类型错误，无法播放购车Timeline", type)

		return
	end

	if self.endPos == Vector3.zero then
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

		function data.onPlayCb()
			playCb()
		end

		gTimelineManager:Timeline_LoadAndPlay(info.timelineName, data)
	else
		print_error("4S汽修店，该车辆类型没有配置购车Timeline，无法播放", type)
	end
end

gNewCarStoreMgr = gNewCarStoreMgr or C_NewCarStoreMgr.new()
