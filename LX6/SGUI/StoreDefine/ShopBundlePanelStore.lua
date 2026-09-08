-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ShopBundlePanelStore.lua
-- Decompiled from: 01311_ShopBundlePanelStore.lua_7e61033bc405.luajit

local MallCommodityConfig = LTConfig.MallCommodityConfig
local MallBundleConfig = LTConfig.MallBundleConfig
local MallRecommendConfig = LTConfig.MallRecommendConfig
local ConsumableConfig = LTConfig.ConsumableConfig

require("LX6/Manager/Shop/MallCameraManager")

C_ShopBundlePanelStore = DefClass("C_ShopBundlePanelStore", C_ShopBundlePanelStore, C_StoreGroup)
GroupName2Class.ShopBundlePanelStore = C_ShopBundlePanelStore
local M = C_ShopBundlePanelStore

M.ctor = function(self)
	self.recommendId = 0
	self.recommendCfg = nil
	self.bundleId = 0
	self.bundleCfg = nil
	self.itemListData = {}
	self.selectedIndex = -1
	self.rawPrice = 0
	self.nowPrice = 0
	self.moneyItemId = 0
	self.selectedSpiritId = nil
	self.isCurrentCommodityExclusive = false
	self.rootArea = nil
	self.mallCameraEnabled = false
	self.currentPreviewKind = nil
	self.homeWasShowingModel = false
end

M.DefineAllVariables = function(self)
	self.panelId = nil
	self.endTimestamp = 0
	self.bundleListData = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.typeCtrlEnum = {
		["M\\x90\\x9e\\x8cO"] = 1,
		["\\x8dit"] = 2,
		i7tO = 0,
		j0rK = 3
	}
	self.isSingleFreeCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.moneyEnoughCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.singleMoneyEnoughtCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showUICtrlEnum = {
		["\\xaf\\xb8\\xaah2\\xfb7"] = 1,
		["F\\x90\\x8c\\x8fD"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.typeCtrlEnum = nil
	self.isSingleFreeCtrlEnum = nil
	self.moneyEnoughCtrlEnum = nil
	self.singleMoneyEnoughtCtrlEnum = nil
	self.showUICtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.endTimestamp = 0
end

M.OnUpdate = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.selectedIndex = -1
	self.rootArea = self.rootGo:GetComponent("UNavigationArea")
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
	self.bindData.showUICtrl = 0
	self.homeWasShowingModel = false
	local homeStore = gStoreManager:GetStoreGroup("ShopHomePagePanelStore")

	if homeStore and homeStore.bindData and homeStore.bindData.modelBtnActive then
		self.homeWasShowingModel = true
	end

	self:InitMoneyDisplay()

	local inputBundleId = data and data.bundleId or nil
	local inputRecommendId = data and data.recommendId or nil

	self:InitBundleList()

	if (not inputBundleId or inputBundleId ~= 0) and inputRecommendId and inputRecommendId <= 0 then
		for _, bundleData in ipairs(self.bundleListData) do
			if bundleData.recommendId ~= inputRecommendId then
				inputBundleId = bundleData.bundleId

				break
			end
		end
	end

	if not inputBundleId or inputBundleId ~= 0 then
		if #self.bundleListData <= 0 then
			local firstBundleData = self.bundleListData[1]
			self.bundleId = firstBundleData.bundleId
			self.bundleCfg = MallBundleConfig.GetConfig(self.bundleId)
			self.recommendId = firstBundleData.recommendId
			self.recommendCfg = firstBundleData.recommendCfg
		else
			gDisplayMessageMgr:ShowMessageContentDebug("没有可用的礼包配置")
			gPanelManager:Close(self.m_Id)

			return
		end
	else
		self.bundleId = inputBundleId
		self.bundleCfg = MallBundleConfig.GetConfig(self.bundleId)

		for _, bundleData in ipairs(self.bundleListData) do
			if bundleData.bundleId ~= self.bundleId then
				self.recommendId = bundleData.recommendId
				self.recommendCfg = bundleData.recommendCfg

				break
			end
		end

		if not self.recommendCfg then
			local count = MallRecommendConfig.count

			for i = 0, count - 1 do
				local recommendCfg = MallRecommendConfig.LoadAt(i)

				if recommendCfg and recommendCfg.LinkTo and #recommendCfg.LinkTo > 2 and recommendCfg.LinkTo[1] ~= 2 and recommendCfg.LinkTo[2] ~= self.bundleId then
					self.recommendId = recommendCfg.Id
					self.recommendCfg = recommendCfg

					break
				end
			end
		end

		if not self.bundleCfg then
			gDisplayMessageMgr:ShowMessageContentDebug("礼包配置不存在: " .. tostring(self.bundleId))

			if #self.bundleListData <= 0 then
				local firstBundleData = self.bundleListData[1]
				self.bundleId = firstBundleData.bundleId
				self.bundleCfg = MallBundleConfig.GetConfig(self.bundleId)
				self.recommendId = firstBundleData.recommendId
				self.recommendCfg = firstBundleData.recommendCfg
			else
				gPanelManager:Close(self.m_Id)

				return
			end
		end
	end

	self:SelectBundleById(self.bundleId)

	self.selectedSpiritId = data and data.spiritId or nil

	if not self.selectedSpiritId or self.selectedSpiritId ~= 0 then
		self.selectedSpiritId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
	end

	self.UpdateAvatarIcon(self, self.selectedSpiritId)
	self.InitBundleData(self)
	self.ApplyFirstCommodityScene(self)
	self.RefreshBundleInfo(self)
end

M.InitMoneyDisplay = function(self)
	if not self.SubGroup or not self.SubGroup.MoneyTemplateStore then
		return
	end

	self.SubGroup.MoneyTemplateStore:SetData({
		{
			["iy\\xbetI\\x81\\xfaH}[zH"] = true,
			Type = ConsumableConfig.RewardGold
		},
		{
			Type = ConsumableConfig.RewardBindingGold
		}
	})
end

M.OnClose = function(self)
	self.selectedIndex = -1
	self.endTimestamp = 0

	self.DisableMallCameraControl(self)

	if self.homeWasShowingModel then
		local homeStore = gStoreManager:GetStoreGroup("ShopHomePagePanelStore")

		if homeStore and homeStore.OnReturnFromOverlay then
			homeStore.OnReturnFromOverlay(homeStore)
		end
	end

	self.homeWasShowingModel = false
end

M.OnActiveDeviceChange = function(self, device)
end

M.ClearModel = function(self)
	gMallSceneManager:ClearCharacterModel()
	gMallSceneManager:ClearVehicle()
	gMallSceneManager:ClearCommoditySceneEffects()
	gMallSceneManager:ClearCommodityDynamicLight()
end

M.TryOnFashion = function(self, commodityData)
	if not commodityData then
		return
	end

	slot2 = gMallSceneManager
	local kind = slot2:PreviewCommodityById(commodityData.id or 0, {
		onLoaded = function ()
			self:UpdateMallCameraControl()
		end
	})
	local LoadingType = gMallSceneManager.LoadingType

	if kind ~= LoadingType.Character then
		self.currentPreviewKind = LoadingType.Character
		local mappedSpiritId = commodityData.id and commodityData.id <= 0 and gMallSceneManager:GetCommoditySpiritMapping(commodityData.id) or nil
		local spiritId = gMallManager:ResolveDisplaySpiritId(commodityData, mappedSpiritId)
		local _, _, resolvedFashionId = gMallManager:BuildFashionLoadParams(commodityData, spiritId)
		self.tryOnFashionId = resolvedFashionId
	elseif kind ~= LoadingType.Vehicle then
		self.currentPreviewKind = LoadingType.Vehicle
	end
end

M.IsBundleBuyable = function(self)
	if gMallGiftManager:IsBundleCoveredByPendingGift(self.bundleId) then
		return false
	end

	for _, itemData in ipairs(self.itemListData) do
		if itemData.price and itemData.price <= 0 and gMallManager:IsCommodityBuyable(itemData) then
			return true
		end
	end

	return false
end

M.CheckCommodityOwned = function(self, itemData)
	return gMallManager:CheckMallCommodityOwned(itemData)
end

M.GetCurrentModelRoot = function(self)
	if self.currentPreviewKind ~= gMallSceneManager.LoadingType.Vehicle then
		if gMallSceneManager and gMallSceneManager.currentVehicle and gMallSceneManager.currentVehicle.gameObject then
			return gMallSceneManager.currentVehicle.gameObject.transform
		end
	elseif gMallSceneManager and gMallSceneManager.currentModelUnit and gMallSceneManager.currentModelUnit.PlayerObj then
		return gMallSceneManager.currentModelUnit.PlayerObj.transform
	end

	return nil
end

M.BuildMallCameraParams = function(self)
	local modelRoot = self.GetCurrentModelRoot(self)

	if not modelRoot then
		return nil
	end

	local vCamera = gMallSceneManager and gMallSceneManager.mallVCamera

	if gCS.LuaUtils.IsNull(vCamera) then
		return nil
	end

	local cameraControlConfig = gMallCameraManager:BuildMallCameraControlConfig(self.currentPreviewKind)

	return {
		["AFb[A\n="] = false,
		verticalButton = self.bindData.baseUpdownButton,
		basePanel = self.bindData.basePanel,
		rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
		L2CustomNavRespond = self.bindData.L2CustomNavRespond,
		R2CustomNavRespond = self.bindData.R2CustomNavRespond,
		camera = vCamera,
		modelRoot = modelRoot,
		cameraOffsetRange = cameraControlConfig.yOffsetRange,
		cameraOffset = Vector3.New(0, 0, 0),
		cameraControlConfig = cameraControlConfig
	}
end

M.UpdateMallCameraControl = function(self)
	local params = self.BuildMallCameraParams(self)

	if not params then
		self.DisableMallCameraControl(self)

		return
	end

	gMallCameraManager:SetMallPanelCamera(self.m_Id, true, params)

	self.mallCameraEnabled = true
end

M.DisableMallCameraControl = function(self)
	if not self.mallCameraEnabled then
		return
	end

	gMallCameraManager:SetMallPanelCamera(self.m_Id, false)

	self.mallCameraEnabled = false
end

M.SetCameraInputActive = function(self, active)
	local nodes = {
		self.bindData.baseUpdownButton,
		self.bindData.mouseCustomNavRespond,
		self.bindData.L2CustomNavRespond,
		self.bindData.R2CustomNavRespond
	}

	for _, node in ipairs(nodes) do
		if node and node.gameObject then
			node.gameObject:SetActive(active ~= true)
		end
	end
end

M.ShowCharacterSwitcherWithCallback = function(self, customOnSelectCallback)
	local selectedItemData = nil

	if self.selectedIndex > 0 and self.selectedIndex >= #self.itemListData then
		selectedItemData = self.itemListData[self.selectedIndex + 1]
	end

	local belongSpiritId, requiredGender = gMallManager:GetCommodityFashionRestrict(selectedItemData)
	local filterFunc = nil

	if belongSpiritId <= 0 then
		filterFunc = function(spiritId)
			if not gSpiritManager:GetSpirit(spiritId) then
				return false
			end

			return spiritId ~= belongSpiritId
		end
	end

	filterFunc = filterFunc or function (spiritId)
		return gSpiritManager:GetSpirit(spiritId) == nil
	end

	gPanelManager:CheckShow(gPanelId.S_SWITCH_CHARACTER_PANEL, {
		["ZI诋\\x95\\xc5\\xe4"] = true,
		["\\x90:,&H\\x8fD\\xcf>\\xaf\\xae"] = true,
		["\\xf4\\x92\\xfb=\\xea(\\xfa\\x81\\xff\\x8b4;"] = true,
		spiritId = self.selectedSpiritId,
		callBack = function (hasChange, selectedSpiritId)
		end,
		onSelectCallback = function (selectedSpiritId)
			self.selectedSpiritId = selectedSpiritId

			if customOnSelectCallback then
				customOnSelectCallback(selectedSpiritId)
			end
		end,
		sex = requiredGender,
		filterFunc = filterFunc
	})
end

M.InitBundleList = function(self)
	self.bundleListData = {}
	local now = gLuaDataManager.serverTime
	local count = MallRecommendConfig.count

	for i = 0, count - 1 do
		local recommendCfg = MallRecommendConfig.LoadAt(i)

		if recommendCfg and recommendCfg.LinkTo and #recommendCfg.LinkTo > 2 and recommendCfg.LinkTo[1] ~= 2 then
			local bundleId = recommendCfg.LinkTo[2]
			local bundleCfg = MallBundleConfig.GetConfig(bundleId)

			if bundleCfg and bundleCfg.Name then
				local isValid = true
				local gachaOnShelfTime, gachaOffShelfTime = gMallManager:GetRecommendShelfTimeFromGacha(recommendCfg)
				local onShelfTime = gachaOnShelfTime or recommendCfg.OnShelfTime
				local offShelfTime = gachaOffShelfTime or recommendCfg.OffShelfTime

				if onShelfTime and not gMallManager:IsTimeEmpty(onShelfTime) then
					local onShelfTimestamp = gTimeUtils:GetUnixTime(onShelfTime.year or 0, onShelfTime.month or 0, onShelfTime.day or 0, onShelfTime.hour or 0, onShelfTime.minute or 0, onShelfTime.second or 0)

					if now >= onShelfTimestamp then
						isValid = false
					end
				end

				if isValid and offShelfTime and not gMallManager:IsTimeEmpty(offShelfTime) then
					local offShelfTimestamp = gTimeUtils:GetUnixTime(offShelfTime.year or 0, offShelfTime.month or 0, offShelfTime.day or 0, offShelfTime.hour or 0, offShelfTime.minute or 0, offShelfTime.second or 0)

					if offShelfTimestamp < now then
						isValid = false
					end
				end

				if isValid then
					table.insert(self.bundleListData, {
						bundleId = bundleId,
						recommendId = recommendCfg.Id,
						recommendCfg = recommendCfg,
						title = bundleCfg.Name or ""
					})
				end
			end
		end
	end

	table.sort(self.bundleListData, function (a, b)
		return a.bundleId <= b.bundleId
	end)

	if self.bindData.bundleList then
		self.bindData.bundleList:SetSimpleList(#self.bundleListData)
	end
end

M.SelectBundleById = function(self, bundleId)
	if not self.bindData.bundleList or #self.bundleListData ~= 0 then
		return
	end

	local selectedIndex = -1

	for i, bundleData in ipairs(self.bundleListData) do
		if bundleData.bundleId ~= bundleId then
			selectedIndex = i - 1

			break
		end
	end

	if selectedIndex > 0 then
		self.bindData.bundleList:SelectItem(selectedIndex, true)
	end
end

M.InitBundleData = function(self)
	self.itemListData = {}
	self.rawPrice = 0
	self.moneyItemId = 0
	local moneyItemSet = {}

	if not self.bundleCfg.Commodities or #self.bundleCfg.Commodities ~= 0 then
		return
	end

	for _, commodityId in ipairs(self.bundleCfg.Commodities) do
		local commodityCfg = MallCommodityConfig.GetConfig(commodityId)

		if commodityCfg then
			local itemData = gMallManager:GenMallCommodityItem(commodityCfg)

			if itemData then
				itemData.commodityCfg = commodityCfg

				if commodityCfg.Price and commodityCfg.Price <= 0 then
					itemData.tIndex = 1
				else
					itemData.tIndex = 0
				end

				itemData.isOwned = self.CheckItemOwned(self, itemData)

				table.insert(self.itemListData, itemData)

				if not itemData.isOwned then
					self.rawPrice = self.rawPrice + itemData.price
				end

				if itemData.moneyItemId and itemData.moneyItemId <= 0 then
					moneyItemSet[itemData.moneyItemId] = true
				end
			end
		end
	end

	local moneyItemIds = {}

	for id, _ in pairs(moneyItemSet) do
		table.insert(moneyItemIds, id)
	end

	if #moneyItemIds <= 0 then
		self.moneyItemId = moneyItemIds[1]
	end

	local discountRate = self.bundleCfg.DiscountRate or 1
	local calculatedPrice = math.ceil(self.rawPrice * discountRate)
	self.nowPrice = self:SimplifyBundlePrice(calculatedPrice)

	self:UpdateFreeItemsOwnership()
end

M.WarmupNeighborItemScenes = function(self, centerIndex)
	if not self.itemListData or #self.itemListData ~= 0 then
		return
	end

	slot2 = gMallSceneManager

	slot2:ScheduleWarmupNeighborScenes(self.itemListData, centerIndex + 1, function (item)
		return gMallManager:GetCommoditySceneId(item and item.id)
	end)
end

M.ApplyFirstCommodityScene = function(self)
	if not self.itemListData or #self.itemListData ~= 0 then
		return
	end

	local firstItem = self.itemListData[1]

	if not firstItem then
		return
	end

	local sceneId = gMallSceneManager:ResolveSceneIdForCommodity(firstItem)

	if sceneId ~= 0 then
		if firstItem.type ~= 1 then
			sceneId = 2
		else
			sceneId = 1
		end
	end

	gMallSceneManager:ApplyMallSceneById(sceneId)
	gMallSceneManager:ApplyMallSceneCamera(false)
end

M.RefreshBundleInfo = function(self)
	self:RefreshBgIconId()

	self.bindData.bundleName = self.bundleCfg.Name or ""
	self.bindData.bundleDes = self.bundleCfg.Desc or self.bundleCfg.Name
	self.bindData.bundleNumDes = string.format(LTConfig.TextConfig.GetConfig(73970808).Text, #self.itemListData)
	self.bindData.rawPrice = tostring(self.rawPrice)
	self.bindData.nowPrice = tostring(self.nowPrice)
	local discountRate = self.bundleCfg.DiscountRate or 1

	if discountRate >= 1 then
		self.bindData.discountNum = string.format("-%d", math.floor((1 - discountRate) * 100))
	else
		self.bindData.discountNum = ""
	end

	if self.moneyItemId and self.moneyItemId <= 0 then
		local moneyCfg = ConsumableConfig.GetConfig(self.moneyItemId)
		self.bindData.bundleMoneyIcon = moneyCfg and moneyCfg.SMoneyIconId or 0
	end

	self.bindData.typeCtrl = self.typeCtrlEnum.suit

	self.bindData.itemList:SetSimpleList(#self.itemListData)
	self:InitCountDown()
	self:UpdateMoneyEnoughCtrl()

	if self.bindData.buyBundleBtn then
		self.bindData.buyBundleBtn.interactable = self.IsBundleBuyable(self)
	end

	if #self.itemListData <= 0 then
		if self.selectedIndex > 0 and self.selectedIndex >= #self.itemListData then
			self.bindData.itemList:SelectItem(self.selectedIndex, true)
			self:RefreshSingleItemInfo(self.selectedIndex)
		else
			self.bindData.itemList:SelectItem(0, true)
			self:RefreshSingleItemInfo(0)
		end
	else
		self.ClearSingleItemInfo(self)
	end
end

M.GetBundleBgIconId = function(self)
	local bgIconId = self.recommendCfg and self.recommendCfg.BigPicture or 0

	if bgIconId and bgIconId == 0 then
		return bgIconId
	end

	local displayCommodities = self.recommendCfg and self.recommendCfg.DisplayCommodities
	local commodityId = displayCommodities and displayCommodities[1] or nil

	if commodityId then
		local commodityCfg = MallCommodityConfig.GetConfig(commodityId)

		return commodityCfg and (commodityCfg.BigPicture and commodityCfg.BigPicture == 0 and commodityCfg.BigPicture or commodityCfg.Picture) or 0
	end

	return 0
end

M.RefreshBgIconId = function(self)
	self.bindData.bgIconId = self.GetBundleBgIconId(self)
end

M.InitCountDown = function(self)
	local now = gLuaDataManager.serverTime
	self.endTimestamp = 0

	if not self.recommendCfg then
		return
	end

	local _, gachaOffShelfTime = gMallManager:GetRecommendShelfTimeFromGacha(self.recommendCfg)
	local offShelfTime = gachaOffShelfTime or self.recommendCfg.OffShelfTime

	if offShelfTime and not gMallManager:IsTimeEmpty(offShelfTime) then
		self.endTimestamp = gTimeUtils:GetUnixTime(offShelfTime.year or 0, offShelfTime.month or 0, offShelfTime.day or 0, offShelfTime.hour or 0, offShelfTime.minute or 0, offShelfTime.second or 0)

		if self.endTimestamp and now >= self.endTimestamp then
			local remainingTime = self.endTimestamp - now

			if self.bindData.countDown then
				self.bindData.countDown:Play(remainingTime)
			end
		else
			self.endTimestamp = 0
		end
	end
end

M.OnCountDownFinished = function(self)
	self.endTimestamp = 0

	if self.bundleId and self.bundleId <= 0 then
		self.InitBundleData(self)
		self.RefreshBundleInfo(self)
	end
end

M.ClearSingleItemInfo = function(self)
	self.bindData.singleItemName = ""
	self.bindData.singleItemDes = ""
	self.bindData.singleItemPrice = ""
	self.bindData.singleMoneyIcon = 0
	self.bindData.isSingleFreeCtrl = 0
	self.bindData.singleMoneyEnoughtCtrl = 0
	self.selectedIndex = -1
	self.isCurrentCommodityExclusive = false

	if self.bindData.buySingleBtn then
		self.bindData.buySingleBtn.interactable = false
	end

	self.UpdateSwitchRoleButtonVisibility(self, false)
	self.DisableMallCameraControl(self)
	self.SetCameraInputActive(self, false)
	self.ClearModel(self)
end

M.RefreshSingleItemInfo = function(self, index)
	local itemData = self.itemListData[index + 1]

	if not itemData then
		self.ClearSingleItemInfo(self)

		return
	end

	self.selectedIndex = index

	self:WarmupNeighborItemScenes(index)

	self.bindData.singleItemName = itemData.name
	self.bindData.singleItemDes = gMallManager:GetCommodityDescription(itemData)
	self.bindData.singleItemPrice = tostring(itemData.price)

	if itemData.moneyItemId and itemData.moneyItemId <= 0 then
		local moneyCfg = ConsumableConfig.GetConfig(itemData.moneyItemId)
		self.bindData.singleMoneyIcon = moneyCfg and moneyCfg.SMoneyIconId or 0
	end

	self.bindData.isSingleFreeCtrl = itemData.price ~= 0 and 1 or 0
	self.bindData.buySingleBtn.interactable = gMallManager:IsCommodityBuyable(itemData)

	self:UpdateSingleMoneyEnoughCtrl()

	if itemData.tIndex ~= 0 then
		self:DisableMallCameraControl()
		self:SetCameraInputActive(false)

		local itemId = itemData.itemId or itemData.bindId or 0
		local iconId = itemData.icon or itemData.iconId or 0

		if iconId ~= 0 then
			local itemCfg = LTConfig.CommonItemConfig.GetConfig(itemId)
			iconId = itemCfg and itemCfg.SItemIconId or 0
		end

		self.bindData.itemIconId = iconId
		self.bindData.typeCtrl = self.typeCtrlEnum.prop
		self.bindData.bgActive = true
	else
		self.bindData.bgActive = false
		self.bindData.itemIconId = 0

		self.SetCameraInputActive(self, true)
		self.ShowItemModel(self, itemData)

		if itemData.type ~= 0 then
			self.bindData.typeCtrl = self.typeCtrlEnum.suit
		elseif itemData.type ~= 2 then
			self.bindData.typeCtrl = self.typeCtrlEnum.weapon
		elseif itemData.type ~= 1 then
			self.bindData.typeCtrl = self.typeCtrlEnum.car
		else
			self.bindData.typeCtrl = self.typeCtrlEnum.suit
		end
	end
end

M.ShowItemModel = function(self, itemData)
	if not itemData then
		return
	end

	local isExclusiveFashion = gMallManager:IsExclusiveFashionCommodity(itemData)
	self.isCurrentCommodityExclusive = isExclusiveFashion

	self:UpdateSwitchRoleButtonVisibility(isExclusiveFashion)

	if itemData.type ~= 0 or itemData.type ~= 1 then
		self.TryOnFashion(self, itemData)
	end

	local mappedSpiritId = itemData.id and itemData.id <= 0 and gMallSceneManager:GetCommoditySpiritMapping(itemData.id) or nil
	local shownSpiritId = gMallManager:ResolveDisplaySpiritId(itemData, mappedSpiritId)

	if shownSpiritId <= 0 then
		self.selectedSpiritId = shownSpiritId

		self.UpdateAvatarIcon(self, shownSpiritId)
	end
end

M.UpdateMoneyEnoughCtrl = function(self)
	local isEnough = true

	if self.moneyItemId and self.moneyItemId <= 0 and self.nowPrice and self.nowPrice <= 0 then
		local currentMoney = gCommonItemManager:GetPackItemNum(self.moneyItemId)
		isEnough = self.nowPrice > currentMoney
	end

	self.bindData.moneyEnoughCtrl = isEnough and 0 or 1
end

M.UpdateSingleMoneyEnoughCtrl = function(self)
	local isEnough = true

	if self.selectedIndex > 0 and self.selectedIndex >= #self.itemListData then
		local itemData = self.itemListData[self.selectedIndex + 1]

		if itemData then
			local moneyItemId = itemData.moneyItemId or 0
			local price = itemData.price or 0

			if moneyItemId <= 0 and price <= 0 then
				local currentMoney = gCommonItemManager:GetPackItemNum(moneyItemId)
				isEnough = price > currentMoney
			end
		end
	end

	self.bindData.singleMoneyEnoughtCtrl = isEnough and 0 or 1
end

M.UpdateSwitchRoleButtonVisibility = function(self, isExclusive)
	if self.bindData.switchRoleButton then
		self.bindData.switchRoleButton.gameObject:SetActive(not isExclusive)
	end
end

M.CheckItemOwned = function(self, itemData)
	return self.CheckCommodityOwned(self, itemData)
end

M.UpdateFreeItemsOwnership = function(self)
	if not self.itemListData or #self.itemListData ~= 0 then
		return false
	end

	local allPaidItemsOwned = true

	for _, itemData in ipairs(self.itemListData) do
		if itemData.price and itemData.price <= 0 and not itemData.isOwned then
			allPaidItemsOwned = false

			break
		end
	end

	local hasChanged = false

	if allPaidItemsOwned then
		for _, itemData in ipairs(self.itemListData) do
			if itemData.price and itemData.price ~= 0 and not itemData.isOwned then
				itemData.isOwned = true
				hasChanged = true
			end
		end
	end

	return hasChanged
end

M.RefreshBundleOwnershipAndPrice = function(self)
	if not self.itemListData or #self.itemListData ~= 0 then
		return
	end

	self.rawPrice = 0
	local hasAnyChange = false

	for _, itemData in ipairs(self.itemListData) do
		local wasOwned = itemData.isOwned or false
		itemData.isOwned = self:CheckItemOwned(itemData)

		if wasOwned == itemData.isOwned then
			hasAnyChange = true
		end

		if not itemData.isOwned then
			self.rawPrice = self.rawPrice + itemData.price
		end
	end

	local discountRate = self.bundleCfg.DiscountRate or 1
	local calculatedPrice = math.ceil(self.rawPrice * discountRate)
	self.nowPrice = self:SimplifyBundlePrice(calculatedPrice)
	local freeItemsChanged = self:UpdateFreeItemsOwnership()

	if freeItemsChanged then
		hasAnyChange = true

		self.bindData.itemList:RefreshList()
	end

	if self.bindData.buyBundleBtn then
		self.bindData.buyBundleBtn.interactable = self.IsBundleBuyable(self)
	end

	if self.selectedIndex > 0 and self.bindData.buySingleBtn then
		local itemData = self.itemListData[self.selectedIndex + 1]

		if itemData then
			self.bindData.buySingleBtn.interactable = gMallManager:IsCommodityBuyable(itemData)
		end
	end

	if hasAnyChange then
		self.RefreshBundleInfo(self)
	else
		self.UpdateMoneyEnoughCtrl(self)
		self.UpdateSingleMoneyEnoughCtrl(self)
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, "OnPackItemChanged"),
		[gEventConstants.MONEY_CHANGE] = self.CreateAction(self, "OnMoneyChanged")
	}
end

M.OnPackItemChanged = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.RefreshBundleOwnershipAndPrice(self)
end

M.OnMoneyChanged = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.UpdateMoneyEnoughCtrl(self)
	self.UpdateSingleMoneyEnoughCtrl(self)
end

M.RegisterWidget = function(self)
	if self.bindData.backBtn then
		self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	end

	if self.bindData.countDown then
		self.bindData.countDown.luaFinished = self.CreateAction(self, "OnCountDownFinished")
	end

	self.bindData.buySingleBtn.luaClick = self.CreateAction(self, "OnClickBuySingleBtn")
	self.bindData.buyBundleBtn.luaClick = self.CreateAction(self, "OnClickBuyBundleBtn")

	if self.bindData.switchRoleButton then
		self.bindData.switchRoleButton.luaClick = self.CreateAction(self, "OnClickSwitchRoleButton")
	end

	if self.bindData.changeRoleBtn then
		self.bindData.changeRoleBtn.luaClick = self.CreateAction(self, "OnClickSwitchRoleButton")
	end

	if self.bindData.tooltipBtn then
		self.bindData.tooltipBtn.luaClick = self.CreateAction(self, "OnClickTooltipBtn")
	end

	if self.bindData.leftBtn then
		self.bindData.leftBtn.luaClick = self.CreateActionWithArgs(self, "OnClickBundleNavBtn", -1)
	end

	if self.bindData.rightBtn then
		self.bindData.rightBtn.luaClick = self.CreateActionWithArgs(self, "OnClickBundleNavBtn", 1)
	end

	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderItemListItem")
	self.bindData.itemList.luaDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderItemListItem")
	self.bindData.itemList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickItemList")
	self.bindData.itemList.onGetTIndex = self.CreateAction(self, "OnGetItemListTIndex")

	if self.bindData.bundleList then
		self.bindData.bundleList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderBundleListItem")
		self.bindData.bundleList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickBundleList")
		self.bindData.bundleList.luaSelectedChanged = self.CreateAction(self, "OnBundleListSelectedChanged")
	end

	if self.bindData.giftBtn then
		self.bindData.giftBtn.luaClick = self.CreateAction(self, "OnClickGiftBtn")
	end

	if self.bindData.showBtn then
		self.bindData.showBtn.luaClick = self.CreateAction(self, "OnClickShowUIBtn")
	end
end

M.OnClickGiftBtn = function(self)
	if not self.bundleId or self.bundleId ~= 0 then
		gDisplayMessageMgr:ShowMessageContentDebug("temp没有可赠送的捆绑包")

		return
	end

	local giftCtx = gMallGiftManager:BuildGiftContext("bundle", self.bundleId)

	if not giftCtx then
		return
	end

	gPanelManager:CheckShow(gPanelId.SHOP_GIFT_CHOOSE_PANEL, {
		giftCtx = giftCtx
	})
end

M.OnClickBackBtn = function(self)
	if self.bindData.showUICtrl ~= 1 then
		self.OnClickShowUIBtn(self)

		return
	end

	gPanelManager:Close(self.m_Id)
end

M.OnClickShowUIBtn = function(self)
	if self.bindData.showUICtrl ~= 0 then
		self.lastShowUIArea = SGUI.UNavigationMgr.Inst.CurrentActiveArea
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootGo:GetComponent("UNavigationArea")
	else
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.lastShowUIArea
		self.lastShowUIArea = nil
	end

	self.bindData.showUICtrl = 1 - (self.bindData.showUICtrl or 0)

	self:ResetCameraForUIVisibilityToggle(self.bindData.showUICtrl ~= 1)
end

M.ResetCameraForUIVisibilityToggle = function(self, isHideUI)
	local vCamera = gMallSceneManager and gMallSceneManager.mallVCamera

	if gCS.LuaUtils.IsNull(vCamera) then
		return
	end

	vCamera.transform.localPosition = Vector3.New(0, 0, 0)

	gMallSceneManager:ApplyMallSceneCamera(isHideUI ~= true, true)
end

M.OnClickSwitchRoleButton = function(self)
	local originalOnSelectCallback = function(selectedSpiritId)
		self.selectedSpiritId = selectedSpiritId

		self:UpdateAvatarIcon(selectedSpiritId)

		if self.selectedIndex > 0 and self.selectedIndex >= #self.itemListData then
			local itemData = self.itemListData[self.selectedIndex + 1]

			if itemData then
				if itemData.id and itemData.id <= 0 and selectedSpiritId and selectedSpiritId <= 0 then
					gMallSceneManager:SaveCommoditySpiritMapping(itemData.id, selectedSpiritId)
				end

				self:ShowItemModel(itemData)
			end
		end
	end

	self.ShowCharacterSwitcherWithCallback(self, originalOnSelectCallback)
end

M.UpdateAvatarIcon = function(self, spiritId)
	local currentSpiritId = spiritId

	if not currentSpiritId or currentSpiritId ~= 0 then
		if self.selectedSpiritId and self.selectedSpiritId <= 0 then
			currentSpiritId = self.selectedSpiritId
		else
			currentSpiritId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
		end
	end

	if not currentSpiritId or currentSpiritId ~= 0 then
		return
	end

	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(currentSpiritId)
	self.bindData.avatarIconId = spiritCfg and spiritCfg.SHeadIconID or 0
end

M.OnClickTooltipBtn = function(self)
	if not self.bindData.tooltipBtn then
		return
	end

	if self.selectedIndex <= 0 or self.selectedIndex > #self.itemListData then
		return
	end

	local itemData = self.itemListData[self.selectedIndex + 1]

	if not itemData then
		return
	end

	local templateId = itemData.itemId or itemData.bindId or 0

	if templateId ~= 0 then
		return
	end

	local tooltipData = gCommonItemManager:GetItemRenderData({
		["\\xd0\\xcf01\\xfc"] = 1,
		itemId = templateId,
		IsOwned = itemData.isOwned
	})
	self.bindData.tooltipBtn.luaRenderTooltip = gCommonItemManager:CreateActionWithArgs(gCommonItemManager.OnRenderToolTips, tooltipData)
	self.bindData.tooltipBtn.luaTooltipPopup = gCommonItemManager:CreateAction(gCommonItemManager.OnToolTipsClose)

	self.bindData.tooltipBtn:CloseTooltip(true)
	self.bindData.tooltipBtn:OpenTooltip(0)
end

M.OnClickBuySingleBtn = function(self)
	if self.selectedIndex >= 0 then
		gDisplayMessageMgr:ShowMessageContentDebug("请先选择一个商品")

		return
	end

	local itemData = self.itemListData[self.selectedIndex + 1]

	if not itemData or not itemData.commodityCfg then
		gDisplayMessageMgr:ShowMessageContentDebug("商品数据异常")

		return
	end

	if not gMallManager:IsCommodityBuyable(itemData) then
		gDisplayMessageMgr:ShowMessageContentDebug("该商品已不可购买")

		return
	end

	slot2 = gMallManager

	slot2:OpenDoubleConfirmInstant(itemData, 1, function ()
		self:RefreshBundleOwnershipAndPrice()
		self:UpdateMoneyEnoughCtrl()
		self:UpdateSingleMoneyEnoughCtrl()

		if self.selectedIndex > 0 then
			local updatedItemData = self.itemListData[self.selectedIndex + 1]

			if updatedItemData and self.bindData.buySingleBtn then
				self.bindData.buySingleBtn.interactable = gMallManager:IsCommodityBuyable(updatedItemData)
			end
		end
	end)
end

M.OnClickBuyBundleBtn = function(self)
	if not self.bundleId or self.bundleId ~= 0 then
		gDisplayMessageMgr:ShowMessageContentDebug("礼包ID异常")

		return
	end

	if not self.IsBundleBuyable(self) then
		gDisplayMessageMgr:ShowMessageContentDebug("礼包已不可购买")

		return
	end

	local bundleName = self.bundleCfg and self.bundleCfg.Name or ""
	local bundleIcon = self.bundleCfg and self.bundleCfg.Image or 0

	gMallManager:OpenDoubleConfirmBundle(self.bundleId, self.nowPrice, self.moneyItemId, 1, bundleName, bundleIcon, function (bundleId)
		self:RefreshBundleOwnershipAndPrice()
		self:UpdateMoneyEnoughCtrl()
		self:UpdateSingleMoneyEnoughCtrl()

		if self.bindData.buyBundleBtn then
			self.bindData.buyBundleBtn.interactable = self:IsBundleBuyable()
		end

		if self.selectedIndex > 0 then
			local updatedItemData = self.itemListData[self.selectedIndex + 1]

			if updatedItemData and self.bindData.buySingleBtn then
				self.bindData.buySingleBtn.interactable = gMallManager:IsCommodityBuyable(updatedItemData)
			end
		end
	end)
end

M.OnGetItemListTIndex = function(self, index)
	return 0
end

M.OnSimpleRenderItemListItem = function(self, btn, index)
	local itemData = self.itemListData[index + 1]

	if not itemData then
		return
	end

	self.RenderCommonItem(self, btn, index, itemData)
end

M.RenderCommonItem = function(self, btn, index, itemData)
	local itemId = 0
	local itemNum = 1

	if itemData.dropId and itemData.dropId <= 0 then
		local fakeItems = gCommonItemManager:ConvertDropToFakeItem(itemData.dropId, 1)

		if fakeItems and #fakeItems <= 0 then
			local fakeItem = fakeItems[1]

			if fakeItem and fakeItem.Id then
				itemId = fakeItem.Id
				itemNum = fakeItem.Count or 1
			end
		end
	end

	if itemId ~= 0 then
		itemId = itemData.itemId or 0
	end

	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = itemId,
		itemNum = itemNum,
		IsOwned = itemData.isOwned
	})
	local store = gCommonItemManager:OnCommonItemRender(btn, index, renderData)

	if store then
		local isFree = not itemData.price or itemData.price > 0
		store.isFreeCtrl = isFree and 1 or 0
	end

	btn.enabledTooltip = false
end

M.RenderSuitItem = function(self, btn, itemData)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.icon = itemData.icon == 0 and itemData.icon or itemData.iconId
	store.goodsName = itemData.name
	store.price = itemData.price
	store.quality = itemData.quality
	local cfg = ConsumableConfig.GetConfig(itemData.moneyItemId)

	if cfg then
		store.moneyIcon = cfg.SMoneyIconId
	end

	store.isShowTask = 0
	store.isCollect = 0
	store.dyeType = 0
	store.isAvailable = itemData.isOwned and 0 or 1
	store.isHave = itemData.isOwned and 1 or 0

	if itemData.commodityCfg and itemData.commodityCfg.IsNew then
		store.isNew = 1
	else
		store.isNew = 0
	end

	store.isDiscount = 0
	store.isShowTime = 0

	if itemData.type ~= 0 then
		store.typeCtrl = 0
	elseif itemData.type ~= 2 then
		store.typeCtrl = 1
	elseif itemData.type ~= 1 then
		store.typeCtrl = 2
	else
		store.typeCtrl = 0
	end

	local commodityId = itemData.id or itemData.commodityId or itemData.Id
	local bgIconId = 0

	if commodityId then
		local commodityCfg = itemData.commodityCfg or MallCommodityConfig.GetConfig(commodityId)

		if commodityCfg and commodityCfg.BannerBg and commodityCfg.BannerBg <= 0 then
			bgIconId = commodityCfg.BannerBg
		end
	end

	store.iconBg = bgIconId == 0 and bgIconId or itemData.icon
end

M.OnSimpleClickItemList = function(self, btn, index)
	if not btn.isSelected then
		self:ClearSingleItemInfo()
		self.bindData.itemList:SelectItem(-1, false)

		return
	end

	self.RefreshSingleItemInfo(self, index)
end

M.OnSimpleRenderBundleListItem = function(self, btn, index)
	local bundleData = self.bundleListData[index + 1]

	if not bundleData then
		return
	end

	local store = gStoreManager:GetStoreGroup("ShopBundleTabTemplate"):GetStoreByWidget(btn)

	if store then
		store.title = bundleData.title or ""
	end
end

M.SwitchToBundle = function(self, bundleData)
	if not bundleData then
		return
	end

	if self.bundleId ~= bundleData.bundleId then
		return
	end

	self.bundleId = bundleData.bundleId
	self.bundleCfg = MallBundleConfig.GetConfig(self.bundleId)
	self.recommendId = bundleData.recommendId
	self.recommendCfg = bundleData.recommendCfg

	self.InitBundleData(self)
	self.RefreshBundleInfo(self)
end

M.OnSimpleClickBundleList = function(self, btn, index)
	local bundleData = self.bundleListData[index + 1]

	if not bundleData then
		return
	end

	self.SwitchToBundle(self, bundleData)
end

M.OnBundleListSelectedChanged = function(self, list)
	local selectedIndex = list.selectedIndex

	if selectedIndex > 0 and selectedIndex >= #self.bundleListData then
		local bundleData = self.bundleListData[selectedIndex + 1]

		if bundleData then
			self.SwitchToBundle(self, bundleData)
		end
	end

	if self.bindData.itemList and #self.itemListData <= 0 then
		self.selectedIndex = 0

		self.bindData.itemList:SelectItem(0, true)
		self:RefreshSingleItemInfo(0)
	end

	gCommonItemManager:CloseItemToolTips()
end

M.OnClickBundleNavBtn = function(self, direction)
	if not self.bundleListData or #self.bundleListData ~= 0 then
		return
	end

	if not direction or direction ~= 0 then
		return
	end

	local currentIndex = -1

	for i, bundleData in ipairs(self.bundleListData) do
		if bundleData.bundleId ~= self.bundleId then
			currentIndex = i

			break
		end
	end

	local targetIndex = currentIndex + direction

	if targetIndex >= 1 then
		targetIndex = #self.bundleListData
	elseif targetIndex <= #self.bundleListData then
		targetIndex = 1
	end

	if targetIndex > 1 and targetIndex < #self.bundleListData then
		self.bindData.bundleList:SelectItem(targetIndex - 1, true)
	end
end

M.SimplifyBundlePrice = function(self, price)
	return gMallManager:SimplifyBundlePrice(price)
end
