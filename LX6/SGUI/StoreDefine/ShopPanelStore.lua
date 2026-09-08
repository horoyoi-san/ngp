-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ShopPanelStore.lua
-- Decompiled from: 01324_ShopPanelStore.lua_4ee478ce64ba.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local FashionConfig = LTConfig.FashionConfig
local FashionTagConfig = LTConfig.FashionTagConfig
local InputButtonNameConfig = LTConfig.InputButtonNameConfig
local TextConfig = LTConfig.TextConfig
C_ShopPanelStore = DefClass("C_ShopPanelStore", C_ShopPanelStore, C_StoreGroup)
GroupName2Class.ShopPanelStore = C_ShopPanelStore
local M = C_ShopPanelStore
M.SubTypeCtrl = {
	["+M\\x90\\x9e\\x8cO"] = 1,
	j0rK = 3,
	["\\xadit"] = 2,
	["G\\x92\\x87\\x82M"] = 3,
	["\\xff\\xda+\\xff"] = 0
}
local CART_REDDOT_KEY = "MallCart"
local CART_TIP_ANIM_NAME = "S_Vx_S_ControllerKey_shoptips"
M.ListType = {
	["/M\\x90\\x9c\\x80I"] = 2,
	I7tO = 1,
	["T-s^"] = 0
}

M.ctor = function(self)
	self.TabType = nil
	self.currentTabType = 0
	self.currentSubTabType = 0
	self.targetSubTabId = 0
	self.targetCommodityId = 0
	self.subTabsData = {}
	self.currentSuitListData = {}
	self.selectedSuitItemId = 0
	self.searchResultListData = {}
	self.tabsData = {}
	self.commodityDataCache = nil
	self.isCurrentCommodityExclusive = false
	self.tagList = {}
	self.dressListData = {}
	self.searchNodeActive = false
	self.rootArea = nil
	self.currentActiveAreaCo = nil
	self.cachedSuitListBtns = {}
	self.cachedSearchListBtns = {}
	self.currentActiveListType = self.ListType.None
	self._preloadSceneTimer = nil
	self._preloadSceneList = nil
	self._preloadSceneIndex = 0
	self.shopFilterState = nil
end

M.DefineAllVariables = function(self)
	self.shopTipInit = false
	self.hasAnyTimeLimitedDiscount = false
	self.lastUpdateTime = 0
	self.buyNum = 1
	self._cartRedDotCount = 0
	self._addCartInCart = false
	self._addCartSpiritOwned = true
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)

	if self.bindData.inputField then
		self.bindData.inputField.onActivateAction = self.CreateAction(self, "OnInputFieldActivate")
		self.bindData.inputField.onDeActivateAction = self.CreateAction(self, "OnInputFieldDeActivate")
	end
end

M.OnEnable = function(self)
end

M.OnUpdate = function(self)
	if self.hasAnyTimeLimitedDiscount then
		local now = gLuaDataManager.serverTime

		if now == self.lastUpdateTime then
			self.lastUpdateTime = now

			self.UpdateDiscountCountdown(self)
		end
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, "OnPackItemChanged"),
		[gEventConstants.MALL_CART_CHANGE] = self.CreateAction(self, "OnCartChanged")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
	self.StopCartGamepadTipAnim(self)
	self.StopPreloadSubTabScenes(self)

	self._cartBuySuccessPending = false
	self.hasAnyTimeLimitedDiscount = false
	self.lastUpdateTime = 0
	self.currentSubTabType = 0
	self.targetSubTabId = 0
	self.targetCommodityId = 0
	self.subTabsData = {}

	self.RefreshCartRedDot(self, 0)

	self.currentActiveAreaCo = coroutine.stop(self.currentActiveAreaCo)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnActiveDeviceChange = function(self, device)
	if not gClientUtils.CheckIsGamePadMode() then
		return
	end

	if not self.selectedSuitItemId then
		return
	end

	self.bindData.showDetailCtrl = self.GetDefaultShowDetailCtrl(self)
end

M.GetDefaultShowDetailCtrl = function(self)
	if gClientUtils.CheckIsGamePadMode() and #self.dressListData <= 0 then
		return 0
	end

	return 1
end

M.OnShow = function(self, panelId, data)
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootGo:GetComponent("UNavigationArea")
	self.parentStore = data and data.parentStore or nil
	self.tabsData = data and data.tabsData or {}
	self.currentTabType = data and data.currentTab or 0
	self.currentSubTabType = 0
	self.targetSubTabId = data and data.subTabId or 0
	self.targetCommodityId = data and data.commodityId or 0

	if self.parentStore then
		self.TabType = self.parentStore.TabType
	end

	self.commodityDataCache = data and data.commodityDataCache or {}

	self:RefreshCommodityNames()

	self.bindData.showDetailCtrl = 0
	self.bindData.isFilteringCtrl = 1
	self.searchNodeActive = false
	self.listArea = self.bindData.suitList:GetComponent("SGUI.UNavigationArea")

	if self.listArea then
		self.listArea.luaAreaOut = self.CreateAction(self, "OnListAreaOut")
	end

	self.RefreshSubTabVisibility(self)
	self.RefreshTabContent(self)
	self.UpdateAvatarIcon(self)
	self.RefreshCartNum(self)
	self.StartPreloadSubTabScenes(self)
end

M.StartPreloadSubTabScenes = function(self)
	self.StopPreloadSubTabScenes(self)

	if not self.parentStore or not self.parentStore.MainTabToSubTabsMap then
		return
	end

	local subTabs = self.parentStore.MainTabToSubTabsMap[self.currentTabType]

	if not subTabs or #subTabs < 1 then
		return
	end

	local sceneIds = {}
	local seen = {}

	for i = 2, #subTabs do
		local mallId = subTabs[i].mallId
		local sceneId = gMallManager:GetMallFirstSceneIdByMallId(mallId)

		if sceneId and sceneId <= 0 and not seen[sceneId] then
			seen[sceneId] = true

			table.insert(sceneIds, sceneId)
		end
	end

	if #sceneIds ~= 0 then
		return
	end

	self._preloadSceneList = sceneIds
	self._preloadSceneIndex = 0
	self._preloadSceneTimer = Timer.New(self:CreateAction("_TickPreloadSubTabScene"), 0.05, -1):Start()
end

M.StopPreloadSubTabScenes = function(self)
	if self._preloadSceneTimer then
		self._preloadSceneTimer:Stop()

		self._preloadSceneTimer = nil
	end

	self._preloadSceneList = nil
	self._preloadSceneIndex = 0
end

M._TickPreloadSubTabScene = function(self)
	if not self._preloadSceneList then
		self.StopPreloadSubTabScenes(self)

		return
	end

	local list = self._preloadSceneList

	while self._preloadSceneIndex >= #list do
		self._preloadSceneIndex = self._preloadSceneIndex + 1
		local sceneId = list[self._preloadSceneIndex]

		if not gMallSceneManager:IsSceneWarmedUp(sceneId) then
			gMallSceneManager:WarmupSceneById(sceneId)

			return
		end
	end

	self.StopPreloadSubTabScenes(self)
end

M.WarmupNeighborCommodityScenes = function(self, commodityData)
	if not commodityData or not commodityData.id then
		return
	end

	local list = nil

	if self.currentActiveListType ~= self.ListType.Suit then
		list = self.currentSuitListData
	elseif self.currentActiveListType ~= self.ListType.Search then
		list = self.searchResultListData
	end

	if not list or #list ~= 0 then
		return
	end

	local centerIndex = -1

	for i, item in ipairs(list) do
		if item and item.id ~= commodityData.id then
			centerIndex = i

			break
		end
	end

	if centerIndex >= 1 then
		return
	end

	slot4 = gMallSceneManager

	slot4:ScheduleWarmupNeighborScenes(list, centerIndex, function (item)
		return gMallManager:GetCommoditySceneId(item and item.id)
	end)
end

M.OnPackItemChanged = function(self)
	if self.parentStore and self.parentStore.RefreshMoneyDisplay then
		self.parentStore:RefreshMoneyDisplay()
	end
end

M.OnCartChanged = function(self)
	self.RefreshCartNum(self)

	local commodityData = self.GetSelectedCommodityData(self)

	if commodityData then
		self.RefreshAddCartText(self, commodityData)
	end
end

M.RefreshCartNum = function(self)
	local cartList = gMallManager:GetCartCommodityList()
	local count = 0

	if cartList then
		for _, entry in ipairs(cartList) do
			count = count + (entry.count or 0)
		end
	end

	local cfg = InputButtonNameConfig.GetConfig(813)
	local text = cfg and cfg.Name or ""
	self.bindData.cartNum = string.format("%s(%d)", text, count)

	self:RefreshCartRedDot(count)
end

M.RefreshCartRedDot = function(self, count)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	local prevCount = self._cartRedDotCount or 0
	self._cartRedDotCount = count

	if prevCount >= count then
		for i = prevCount + 1, count do
			SGUI.RedDotMgr.LuaSetRedDot(true, CART_REDDOT_KEY .. "/" .. i)
		end
	elseif count >= prevCount then
		for i = count + 1, prevCount do
			SGUI.RedDotMgr.LuaSetRedDot(false, CART_REDDOT_KEY .. "/" .. i)
		end
	end
end

M.OnTabChanged = function(self, tabType)
	self.currentTabType = tabType

	if not self.STATE_Started then
		return
	end

	self.shopFilterState = nil
	self.bindData.isFilteringCtrl = 1

	self.ClearSearch(self)
	self.ClearSelection(self)
	self.RefreshSubTabVisibility(self)
	self.RefreshTabContent(self)
	self.StartPreloadSubTabScenes(self)
end

M.RefreshTabContent = function(self)
	if not self.TabType then
		return
	end

	local hasSubTabs = self.currentSubTabType and self.currentSubTabType >= 0
	local dataKey = hasSubTabs and self.currentSubTabType or self.currentTabType

	self:UpdateBgActiveByMainTab()
	self:UpdateModelViewerRawImageByMallId(dataKey)

	local commodityList = self.commodityDataCache[dataKey] or {}

	self:SortCommodityList(commodityList)

	self.hasAnyTimeLimitedDiscount = false

	for _, commodityData in ipairs(commodityList) do
		if commodityData.discountExpired then
			-- Nothing
		else
			local discountEndTime = gMallManager:GetCommodityDiscountEndTime(commodityData.id)

			if discountEndTime and discountEndTime <= 0 then
				self.hasAnyTimeLimitedDiscount = true
				self.lastUpdateTime = gLuaDataManager.serverTime

				break
			end
		end
	end

	local isPropList = self:IsPropListType(commodityList, dataKey)

	self:AssignCommodityTIndex(commodityList, isPropList)

	self.currentSuitListData = commodityList
	self.selectedSuitItemId = self.targetCommodityId or 0

	self:RefreshList()
end

M.RefreshSubTabVisibility = function(self)
	if not self.TabType then
		return
	end

	local subTabConfigs = nil

	if self.parentStore and self.parentStore.MainTabToSubTabsMap then
		subTabConfigs = self.parentStore.MainTabToSubTabsMap[self.currentTabType]
	end

	if subTabConfigs and #subTabConfigs <= 1 then
		self.subTabsData = {}

		for _, subTabCfg in ipairs(subTabConfigs) do
			local subTypeCtrl = self.GetSubTypeCtrlByMallId(self, subTabCfg.mallId)

			table.insert(self.subTabsData, {
				id = subTabCfg.mallId,
				name = subTabCfg.name,
				icon = subTabCfg.icon,
				subTypeCtrl = subTypeCtrl
			})
		end

		self.bindData.subTabList:SetSimpleList(#self.subTabsData)

		local targetIndex = 1

		if self.targetSubTabId and self.targetSubTabId <= 0 then
			for index, subTabData in ipairs(self.subTabsData) do
				if subTabData.id ~= self.targetSubTabId then
					targetIndex = index

					break
				end
			end

			if targetIndex ~= 1 and self.targetSubTabId < #self.subTabsData then
				targetIndex = self.targetSubTabId
			end

			self.targetSubTabId = 0
		elseif self.currentSubTabType and self.currentSubTabType <= 0 then
			for index, subTabData in ipairs(self.subTabsData) do
				if subTabData.id ~= self.currentSubTabType then
					targetIndex = index

					break
				end
			end
		end

		if #self.subTabsData <= 0 then
			if targetIndex <= 1 or targetIndex <= #self.subTabsData then
				targetIndex = 1
			end

			self.currentSubTabType = self.subTabsData[targetIndex].id
			self.bindData.goodsTypeCtrl = self.subTabsData[targetIndex].subTypeCtrl or 0

			self.bindData.subTabList:SelectItem(targetIndex - 1, false)

			if self.parentStore then
				self.parentStore.currentSubMallId = self.currentSubTabType or 0

				if self.parentStore.RefreshMoneyDisplay then
					self.parentStore:RefreshMoneyDisplay(nil, self.currentSubTabType)
				end
			end
		end
	else
		self.subTabsData = {}

		self.bindData.subTabList:SetSimpleList(0)

		self.currentSubTabType = 0
		self.targetSubTabId = 0

		if self.parentStore then
			self.parentStore.currentSubMallId = 0
		end
	end

	self.UpdateTypeText(self)
end

M.UpdateTypeText = function(self)
	local text = ""

	if self.currentSubTabType and self.currentSubTabType <= 0 then
		for _, subTabData in ipairs(self.subTabsData) do
			if subTabData.id ~= self.currentSubTabType then
				text = subTabData.name or ""

				break
			end
		end
	end

	if text ~= "" and self.tabsData then
		for _, tabData in ipairs(self.tabsData) do
			if tabData.id ~= self.currentTabType then
				text = tabData.title or ""

				break
			end
		end
	end

	self.bindData.typeText = text
end

M.OnSubTabChanged = function(self, uList)
	local selectedIndex = uList.selectedIndex

	if selectedIndex > 0 and selectedIndex >= #self.subTabsData then
		self.shopFilterState = nil
		self.bindData.isFilteringCtrl = 1

		self.ClearSearch(self)
		self.ClearSelection(self)

		local subTabData = self.subTabsData[selectedIndex + 1]
		self.currentSubTabType = subTabData.id

		if subTabData.subTypeCtrl then
			self.bindData.goodsTypeCtrl = subTabData.subTypeCtrl
		end

		self.UpdateTypeText(self)
		self.UpdateBgActiveByMainTab(self)
		self.UpdateModelViewerRawImageByMallId(self, self.currentSubTabType)

		if not self.TabType then
			return
		end

		local commodityList = self.commodityDataCache[self.currentSubTabType] or {}

		self:SortCommodityList(commodityList)

		local isPropList = self:IsPropListType(commodityList, self.currentSubTabType)

		self:AssignCommodityTIndex(commodityList, isPropList)

		self.currentSuitListData = commodityList

		self:RefreshList()
		self.bindData.suitList:GoToPos(Vector2.zero, true)

		if self.parentStore and self.parentStore.RefreshMoneyDisplay then
			self.parentStore.currentSubMallId = self.currentSubTabType or 0

			self.parentStore:RefreshMoneyDisplay(nil, self.currentSubTabType)
		end
	end
end

M.OnSubTabRender = function(self, btn, index)
	local subTabData = self.subTabsData[index + 1]

	if not subTabData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.name = subTabData.name

		if subTabData.icon and subTabData.icon <= 0 then
			store.icon = subTabData.icon
		else
			local cfg = LTConfig.MallConfig.GetConfig(subTabData.id)
			store.icon = cfg and cfg.SubTabIcon or 0
		end
	end
end

M.OnClickSubTabNavBtn = function(self, direction)
	if not self.subTabsData or #self.subTabsData ~= 0 then
		return
	end

	local currentIndex = -1

	for i, subTabData in ipairs(self.subTabsData) do
		if subTabData.id ~= self.currentSubTabType then
			currentIndex = i

			break
		end
	end

	if currentIndex < 0 then
		return
	end

	local targetIndex = currentIndex + direction

	if targetIndex >= 1 then
		targetIndex = #self.subTabsData
	elseif targetIndex <= #self.subTabsData then
		targetIndex = 1
	end

	if targetIndex > 1 and targetIndex < #self.subTabsData then
		self.bindData.subTabList:SelectItem(targetIndex - 1, true)
	end
end

M.GetSubTypeCtrlByMallId = function(self, mallId)
	if not self.commodityDataCache or not self.commodityDataCache[mallId] then
		return 0
	end

	local commodities = self.commodityDataCache[mallId]

	if #commodities ~= 0 then
		return 0
	end

	local firstCommodity = commodities[1]

	if firstCommodity.type ~= gMallManager.MallCommodityType.Fashion or firstCommodity.type ~= gMallManager.MallCommodityType.FashionEx then
		return self.SubTypeCtrl.Fashion
	elseif firstCommodity.type ~= gMallManager.MallCommodityType.Vehicle then
		return self.SubTypeCtrl.Car
	elseif firstCommodity.type ~= gMallManager.MallCommodityType.WeaponSkin then
		return self.SubTypeCtrl.Weapon
	elseif firstCommodity.type ~= gMallManager.MallCommodityType.Common or firstCommodity.type ~= gMallManager.MallCommodityType.CommonEx then
		return self.SubTypeCtrl.prop
	end

	return 0
end

M.UpdateBgActiveByMainTab = function(self)
	local mallId = self.currentSubTabType and self.currentSubTabType <= 0 and self.currentSubTabType or self.currentTabType
	local subTypeCtrl = self:GetSubTypeCtrlByMallId(mallId)
	local isFashionOrCar = subTypeCtrl ~= self.SubTypeCtrl.Fashion or subTypeCtrl ~= self.SubTypeCtrl.Car
	self.bindData.bgActive = not isFashionOrCar

	self:RefreshGiftBtnVisibility(subTypeCtrl)
end

M.RefreshGiftBtnVisibility = function(self, subTypeCtrl)
	if not self.bindData.giftBtn then
		return
	end

	if subTypeCtrl ~= nil then
		local mallId = self.currentSubTabType and self.currentSubTabType <= 0 and self.currentSubTabType or self.currentTabType
		subTypeCtrl = self:GetSubTypeCtrlByMallId(mallId)
	end

	local showGift = subTypeCtrl ~= self.SubTypeCtrl.Fashion or subTypeCtrl ~= self.SubTypeCtrl.Car

	self.bindData.giftBtn.gameObject:SetActive(showGift)
end

M.OnClickGiftBtn = function(self)
	local commodityData = self.GetSelectedCommodityData(self)

	if not commodityData or not commodityData.id then
		gDisplayMessageMgr:ShowMessageContentDebug("temp请先选择商品")

		return
	end

	local giftCtx = gMallGiftManager:BuildGiftContext("single", commodityData.id)

	if not giftCtx then
		return
	end

	gPanelManager:CheckShow(gPanelId.SHOP_GIFT_CHOOSE_PANEL, {
		giftCtx = giftCtx
	})
end

M.OnClickRerollPoseBtn = function(self)
	local commodityData = self.GetSelectedCommodityData(self)

	if not commodityData or not commodityData.id then
		return
	end

	gMallSceneManager:RerollPose(commodityData.id)
end

M.RefreshRerollPoseBtnVisibility = function(self)
	if not self.bindData.rerollPoseBtn then
		return
	end

	local show = false
	local mallId = self.currentSubTabType and self.currentSubTabType <= 0 and self.currentSubTabType or self.currentTabType

	if mallId ~= 2 or mallId ~= 14 then
		local commodityData = self.GetSelectedCommodityData(self)

		if commodityData and (commodityData.type ~= gMallManager.MallCommodityType.Fashion or commodityData.type ~= gMallManager.MallCommodityType.FashionEx) then
			local commodityCfg = commodityData.id and LTConfig.MallCommodityConfig.GetConfig(commodityData.id)
			local specifiedId = commodityCfg and commodityCfg.SpecifiedModelid or 0
			show = not specifiedId or specifiedId ~= 0
		end
	end

	self.bindData.rerollPoseBtn.gameObject:SetActive(show)
end

M.UpdateModelViewerRawImageByMallId = function(self, mallId)
	if not self.parentStore then
		return
	end

	local subTypeCtrl = self.GetSubTypeCtrlByMallId(self, mallId)

	if self.parentStore.SetModelBtnActive then
		local hasModel = subTypeCtrl ~= self.SubTypeCtrl.Fashion or subTypeCtrl ~= self.SubTypeCtrl.Car

		self.parentStore:SetModelBtnActive(hasModel)
	end
end

M.IsPropListType = function(self, commodityList, mallId)
	if not commodityList or #commodityList ~= 0 then
		return false
	end

	if mallId and self.GetSubTypeCtrlByMallId(self, mallId) ~= self.SubTypeCtrl.prop then
		return true
	end

	return commodityList[1].type ~= gMallManager.MallCommodityType.Common or commodityList[1].type ~= gMallManager.MallCommodityType.CommonEx
end

M.IsPropCommodity = function(self, commodityData)
	if not commodityData then
		return false
	end

	return commodityData.type ~= gMallManager.MallCommodityType.Common or commodityData.type ~= gMallManager.MallCommodityType.CommonEx
end

M.AssignCommodityTIndex = function(self, commodityList, listIsProp)
	if not commodityList then
		return
	end

	for _, commodityData in ipairs(commodityList) do
		if commodityData then
			local isProp = self.IsPropCommodity(self, commodityData)

			if listIsProp and isProp ~= false and commodityData.type ~= nil then
				isProp = true
			end

			commodityData.tIndex = isProp and 1 or 0
		end
	end
end

M.SortCommodityList = function(self, commodityList)
	local mallId = self.currentSubTabType and self.currentSubTabType <= 0 and self.currentSubTabType or self.currentTabType
	local subTypeCtrl = self:GetSubTypeCtrlByMallId(mallId)

	if subTypeCtrl ~= self.SubTypeCtrl.Fashion or subTypeCtrl ~= self.SubTypeCtrl.Car then
		gMallManager:SortMallCommodityListBy(commodityList, gMallManager.MallSortKey.ShelfTime, gMallManager.MallSortOrder.Asc)
	else
		gMallManager:SortMallCommodityListBy(commodityList, gMallManager.MallSortKey.None)
	end
end

M.RefreshList = function(self)
	self.currentActiveListType = self.ListType.Suit
	self.cachedSuitListBtns = {}
	self.cachedSearchListBtns = {}

	self.bindData.suitList:SetSimpleList(#self.currentSuitListData)

	if self.selectedSuitItemId <= 0 then
		for i = 1, #self.currentSuitListData do
			if self.currentSuitListData[i].id ~= self.selectedSuitItemId then
				self.bindData.suitList:SelectItem(i - 1, true)
				self:ShowCommodityDetail(self.currentSuitListData[i])

				break
			end
		end
	elseif #self.currentSuitListData <= 0 then
		self.bindData.suitList:SelectItem(0, true)
		self:ShowCommodityDetail(self.currentSuitListData[1])
	end
end

M.UpdateDiscountCountdown = function(self)
	local now = gLuaDataManager.serverTime
	local hasExpired = false
	local needUpdateBtns = {}
	local checkList, cachedBtns = nil

	if self.currentActiveListType ~= self.ListType.Suit and next(self.cachedSuitListBtns) then
		checkList = self.currentSuitListData
		cachedBtns = self.cachedSuitListBtns
	elseif self.currentActiveListType ~= self.ListType.Search and next(self.cachedSearchListBtns) then
		checkList = self.searchResultListData
		cachedBtns = self.cachedSearchListBtns
	end

	if not checkList or not cachedBtns then
		return
	end

	for _, commodityData in ipairs(checkList) do
		if commodityData.discountExpired then
			-- Nothing
		else
			local discountEndTime = gMallManager:GetCommodityDiscountEndTime(commodityData.id)

			if discountEndTime and discountEndTime <= 0 and discountEndTime < now then
				commodityData.discountExpired = true
				hasExpired = true

				table.insert(needUpdateBtns, commodityData.id)
			elseif discountEndTime and discountEndTime <= 0 then
				table.insert(needUpdateBtns, commodityData.id)
			end
		end
	end

	for _, commodityId in ipairs(needUpdateBtns) do
		local cachedBtn = cachedBtns[commodityId]

		if cachedBtn and cachedBtn.btn and cachedBtn.commodityData then
			local store = gStoreManager:GetStoreGroup(cachedBtn.btn.Store):GetStoreByWidget(cachedBtn.btn)

			if store then
				if cachedBtn.commodityData.tIndex ~= 1 then
					self.RenderPropCommodityItem(self, store, cachedBtn.commodityData)
				else
					self.RenderCommodityItem(self, store, cachedBtn.commodityData)
				end
			end
		end
	end

	if hasExpired and self.selectedSuitItemId and self.selectedSuitItemId <= 0 then
		local commodityData = self.GetSelectedCommodityData(self)

		if commodityData and commodityData.discountExpired then
			self.ShowCommodityDetail(self, commodityData)
		end
	end
end

M.TryOnFashion = function(self, commodityData)
	if not self.parentStore then
		return
	end

	local isExclusiveFashion = gMallManager:IsExclusiveFashionCommodity(commodityData)
	self.isCurrentCommodityExclusive = isExclusiveFashion

	self:UpdateSwitchRoleButtonVisibility(isExclusiveFashion)
	self.parentStore:TryOnFashion(commodityData)
end

M.TryOnCommodity = function(self, commodityData)
	if not commodityData or not self.parentStore then
		return
	end

	if commodityData.type ~= gMallManager.MallCommodityType.WeaponSkin then
		self.parentStore:TryOnWeapon(commodityData)

		return
	end

	if gMallManager.IsActionItemCommodity(commodityData) then
		self.isCurrentCommodityExclusive = false

		self:UpdateSwitchRoleButtonVisibility(true)
		self.parentStore:TryOnFashion(commodityData)

		return
	end

	self.TryOnFashion(self, commodityData)
end

M.UpdateSwitchRoleButtonVisibility = function(self, isExclusive)
	if self.bindData.switchRoleButton then
		self.bindData.switchRoleButton.gameObject:SetActive(not isExclusive)
	end
end

M.RegisterWidget = function(self)
	self.bindData.switchRoleButton.luaClick = self.CreateAction(self, "OnClickSwitchRoleButton")
	self.bindData.filterButton.luaClick = self.CreateAction(self, "OnClickFilterButton")
	self.bindData.suitList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderSuitListItem")
	self.bindData.suitList.onGetTIndex = self.CreateAction(self, "OnGetSuitListTIndex")
	self.bindData.searchList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderSearchListItem")
	self.bindData.suitList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickSuitList")
	self.bindData.searchList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickSearchList")
	self.bindData.subTabList.luaSelectedChanged = self.CreateAction(self, "OnSubTabChanged")
	self.bindData.subTabList.luaSimpleRenderItem = self.CreateAction(self, "OnSubTabRender")

	if self.bindData.carScoreList then
		self.bindData.carScoreList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderCarScoreListItem")
	end

	self.bindData.inputField.luaValueChanged = self.CreateAction(self, "OnInputValueChanged")
	self.bindData.searchCloseBtn.luaClick = self.CreateAction(self, "OnSearchCloseClick")

	if self.bindData.hideUIBtn then
		self.bindData.hideUIBtn.luaClick = self.CreateAction(self, "OnClickHideUIBtn")
	end

	if self.bindData.hideUIBtn2 then
		self.bindData.hideUIBtn2.luaClick = self.CreateAction(self, "OnClickHideUIBtn")
	end

	if self.bindData.leftTabBtn then
		self.bindData.leftTabBtn.luaClick = self.CreateActionWithArgs(self, "OnClickSubTabNavBtn", -1)
	end

	if self.bindData.rightTabBtn then
		self.bindData.rightTabBtn.luaClick = self.CreateActionWithArgs(self, "OnClickSubTabNavBtn", 1)
	end

	if self.bindData.cartBtn then
		self.bindData.cartBtn.luaClick = self.CreateAction(self, "OnClickCartBtn")

		if not gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.cartBtn.templateKey = "Number"
			self.bindData.cartBtn.redKey = CART_REDDOT_KEY
		end
	end

	if self.bindData.cartBtnPC then
		self.bindData.cartBtnPC.luaClick = self.CreateAction(self, "OnClickCartBtn")
	end

	if self.bindData.addCartBtn then
		self.bindData.addCartBtn.luaClick = self.CreateAction(self, "OnClickAddCartBtn")
	end

	if self.bindData.addCartBtnPC then
		self.bindData.addCartBtnPC.luaClick = self.CreateAction(self, "OnClickAddCartBtn")
	end

	if self.bindData.giftBtn then
		self.bindData.giftBtn.luaClick = self.CreateAction(self, "OnClickGiftBtn")
	end

	if self.bindData.rerollPoseBtn then
		self.bindData.rerollPoseBtn.luaClick = self.CreateAction(self, "OnClickRerollPoseBtn")
	end
end

M.OnClickCartBtn = function(self)
	gMallManager:OpenDoubleConfirmCart(self:CreateAction("OnCartBuySuccess"))
end

M.OnCartBuySuccess = function(self)
	self._cartBuySuccessPending = true

	gLuaTimeMgrUtils.Delay(function ()
		if not self._cartBuySuccessPending then
			return
		end

		self._cartBuySuccessPending = false

		if not self.STATE_Started then
			return
		end

		local selectedCommodityData = self:GetSelectedCommodityData()

		self:OnBuySuccess(selectedCommodityData)
	end, 0.1)
end

M.OnClickAddCartBtn = function(self)
	if not self.selectedSuitItemId or self.selectedSuitItemId ~= 0 then
		return
	end

	local commodityData = self.GetSelectedCommodityData(self)

	if not commodityData or not commodityData.id then
		return
	end

	local canAdd, reasonId = gMallManager:CanAddToCart(commodityData, 1)

	if not canAdd then
		gDisplayMessageMgr:DisplayServerMessageId(reasonId)

		return
	end

	self:PlayCartAnim()

	slot4 = gMallManager

	slot4:AddToCart(commodityData.id, 1, function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end)
end

M.PlayCartAnim = function(self)
	local shopTipStore = gStoreManager:GetStoreGroup(self.bindData.shopTip.Store):GetStoreByWidget(self.bindData.shopTip)

	if shopTipStore and shopTipStore.cartAnim then
		gCS.LuaUtils.PlayAnimationByName(shopTipStore.cartAnim, "S_Vx_S_ShopAppearancePanel_shoppingcart")
	end

	self.PlayCartGamepadTipAnim(self)
end

M.PlayCartGamepadTipAnim = function(self)
	if not gClientUtils.CheckIsGamePadMode() then
		return
	end

	if not self.listArea then
		return
	end

	local bar = self.listArea.gamePadBar

	if not bar then
		return
	end

	local tip = bar.GetGameBarTipByActionId(bar, 4)

	if not tip then
		return
	end

	self._cartTipAnim = tip.gameObject:GetComponent("Animation")

	if self._cartTipAnim then
		gCS.LuaUtils.PlayAnimationByName(self._cartTipAnim, CART_TIP_ANIM_NAME)
	end
end

M.StopCartGamepadTipAnim = function(self)
	if self._cartTipAnim then
		gClientUtils.FinishAnimation(self._cartTipAnim, CART_TIP_ANIM_NAME)

		self._cartTipAnim = nil
	end
end

M.OnListAreaOut = function(self)
	self.StopCartGamepadTipAnim(self)
end

M.OnClickFilterButton = function(self)
	if not self.TabType then
		return
	end

	local dataKey = self.currentSubTabType and self.currentSubTabType <= 0 and self.currentSubTabType or self.currentTabType
	local sourceList = self.commodityDataCache and self.commodityDataCache[dataKey] or {}

	if #sourceList ~= 0 then
		return
	end

	gPanelManager:CheckShow(286, {
		commodityList = sourceList,
		filterState = self.shopFilterState,
		callBack = self:CreateAction("OnShopFilterChanged")
	})
end

M.IsShopFilterStateDefault = function(self, state)
	if not state then
		return true
	end

	if state.priority == gMallManager.MallSortKey.ShelfTime then
		return false
	end

	if state.order == gMallManager.MallSortOrder.Asc then
		return false
	end

	if state.prices and next(state.prices) == nil then
		return false
	end

	if state.tags and next(state.tags) == nil then
		return false
	end

	return true
end

M.OnShopFilterChanged = function(self, resultList, filterState)
	self.shopFilterState = filterState
	self.bindData.isFilteringCtrl = self:IsShopFilterStateDefault(filterState) and 1 or 0

	if not resultList then
		return
	end

	self.currentSuitListData = resultList

	if self.selectedSuitItemId and self.selectedSuitItemId <= 0 then
		local stillExists = false

		for i = 1, #resultList do
			if resultList[i].id ~= self.selectedSuitItemId then
				stillExists = true

				break
			end
		end

		if not stillExists then
			self.selectedSuitItemId = 0
		end
	end

	self:RefreshList()
	self.bindData.suitList:GoToPos(Vector2.zero, true)
end

M.OnClickHideUIBtn = function(self)
	self.parentStore:OnClickShowUIBtn()
end

M.OnClickSwitchRoleButton = function(self)
	if not self.parentStore then
		return
	end

	local originalOnSelectCallback = function(selectedSpiritId)
		self:UpdateAvatarIcon(selectedSpiritId)

		local commodityData = self:GetSelectedCommodityData()

		if commodityData and commodityData.id and commodityData.id <= 0 and selectedSpiritId and selectedSpiritId <= 0 then
			gMallSceneManager:SaveCommoditySpiritMapping(commodityData.id, selectedSpiritId)
		end
	end

	self.parentStore:ShowCharacterSwitcherWithCallback(originalOnSelectCallback, true)
end

M.UpdateAvatarIcon = function(self, spiritId)
	local currentSpiritId = spiritId

	if not currentSpiritId or currentSpiritId ~= 0 then
		if self.parentStore and self.parentStore.selectedSpiritId then
			currentSpiritId = self.parentStore.selectedSpiritId
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

M.RenderCommodityItem = function(self, store, commodityData)
	if not store or not commodityData then
		return
	end

	store.icon = commodityData.icon == 0 and commodityData.icon or commodityData.iconId
	store.goodsName = commodityData.name
	store.quality = commodityData.quality
	local commodityId = commodityData.id
	local bgIconId = 0

	if commodityId then
		local commodityCfg = LTConfig.MallCommodityConfig.GetConfig(commodityId)

		if commodityCfg and commodityCfg.BannerBg and commodityCfg.BannerBg <= 0 then
			bgIconId = commodityCfg.BannerBg
		end
	end

	store.iconBg = bgIconId == 0 and bgIconId or commodityData.icon
	local cfg = ConsumableConfig.GetConfig(commodityData.moneyItemId)

	if cfg then
		store.moneyIcon = cfg.SMoneyIconId
	end

	store.isShowTask = 0
	store.isCollect = 0
	store.dyeType = 0
	store.isAvailable = 1
	local isOwned = gMallManager:CheckMallCommodityOwned(commodityData)
	store.isHave = isOwned and 1 or 0
	local commodityConfig = commodityId and LTConfig.MallCommodityConfig.GetConfig(commodityId) or nil

	if commodityConfig and commodityConfig.IsNew then
		store.isNew = 1
	else
		store.isNew = 0
	end

	if commodityData.type ~= gMallManager.MallCommodityType.Fashion or commodityData.type ~= gMallManager.MallCommodityType.FashionEx then
		store.typeCtrl = 0
	elseif commodityData.type ~= gMallManager.MallCommodityType.WeaponSkin then
		store.typeCtrl = 1
	elseif commodityData.type ~= gMallManager.MallCommodityType.Vehicle then
		store.typeCtrl = 2
	else
		store.typeCtrl = 0
	end

	if commodityData.discountExpired then
		store.isDiscount = 0
		store.price = commodityData.price
		store.isShowTime = 0
	else
		local discountPrice, originalPrice = gMallManager:GetCommodityDiscountInfo(commodityData.id)

		if discountPrice and originalPrice and originalPrice <= 0 then
			store.isDiscount = 1
			store.originPrice = originalPrice
			local discountPercent = math.floor((1 - discountPrice / originalPrice) * 100)
			store.discountNumber = string.format("-%d%%", discountPercent)
			store.price = discountPrice
		else
			store.isDiscount = 0
			store.price = commodityData.price
		end

		local discountEndTime = gMallManager:GetCommodityDiscountEndTime(commodityData.id)

		if discountEndTime and discountEndTime <= 0 then
			local now = gLuaDataManager.serverTime
			local remainingTime = discountEndTime - now

			if remainingTime <= 0 then
				store.isShowTime = 1
				store.timeText = gTimeUtils:GetCornerTimeStr(remainingTime)
			else
				store.isShowTime = 0
			end
		else
			store.isShowTime = 0
		end
	end
end

M.OnSimpleRenderSuitListItem = function(self, btn, index)
	local commodityData = self.currentSuitListData[index + 1]

	if not commodityData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local btnInstanceId = btn:GetInstanceID()

	for cachedCommodityId, cachedInfo in pairs(self.cachedSuitListBtns) do
		if cachedInfo.instanceId ~= btnInstanceId and cachedCommodityId == commodityData.id then
			self.cachedSuitListBtns[cachedCommodityId] = nil
		end
	end

	self.cachedSuitListBtns[commodityData.id] = {
		btn = btn,
		instanceId = btnInstanceId,
		commodityData = commodityData
	}

	if commodityData.tIndex ~= 1 then
		self.RenderPropCommodityItem(self, store, commodityData)
	else
		self.RenderCommodityItem(self, store, commodityData)
	end
end

M.OnGetSuitListTIndex = function(self, csIndex)
	local commodityData = self.currentSuitListData[csIndex + 1]

	return commodityData and commodityData.tIndex or 0
end

M.InitShopTip = function(self)
	if self.shopTipInit then
		return
	end

	local shopTipStore = gStoreManager:GetStoreGroup(self.bindData.shopTip.Store):GetStoreByWidget(self.bindData.shopTip)

	if shopTipStore then
		shopTipStore.buyBtn.luaClick = self.CreateAction(self, "OnClickBuyBtn")

		if shopTipStore.tagList then
			shopTipStore.tagList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderShopTipTagListItem")
		end

		if shopTipStore.dressList then
			shopTipStore.dressList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderDressListItem")
		end

		if shopTipStore.showDetailBtn then
			shopTipStore.showDetailBtn.luaClick = self.CreateAction(self, "OnClickShowDetailBtn")
		end
	end

	self.shopTipInit = true
end

M.ShowCommodityDetail = function(self, commodityData)
	if not commodityData then
		return
	end

	self:InitShopTip()

	self.selectedSuitItemId = commodityData.id

	self:WarmupNeighborCommodityScenes(commodityData)

	local commodityCfg = LTConfig.MallCommodityConfig.GetConfig(commodityData.id)
	self.bindData.itemIconId = commodityCfg and commodityCfg.BigPicture or 0
	self.bindData.bgIconId = commodityCfg and commodityCfg.Background or 0

	self:RefreshQualityBadge(commodityData)
	self:RefreshCarScore(commodityData)
	self:RefreshAddCartText(commodityData)

	local shopTipStore = gStoreManager:GetStoreGroup(self.bindData.shopTip.Store):GetStoreByWidget(self.bindData.shopTip)

	if shopTipStore then
		local importantTitles = nil
		self.tagList, importantTitles = self.GetCommodityTagList(self, commodityData)

		if shopTipStore.tagList then
			shopTipStore.tagList:SetSimpleList(#self.tagList)
		end

		local actualPrice = commodityData.price

		if commodityData.discountExpired then
			shopTipStore.isDiscountCtrl = 1
		else
			local discountPrice, originalPrice = gMallManager:GetCommodityDiscountInfo(commodityData.id)

			if discountPrice and originalPrice and originalPrice <= 0 then
				shopTipStore.isDiscountCtrl = 0
				shopTipStore.originPrice = originalPrice
				actualPrice = discountPrice
			else
				shopTipStore.isDiscountCtrl = 1
			end
		end

		shopTipStore.price = actualPrice

		self.bindData:Commit("showDetailCtrl", 0, COMMIT_IMMEDIATELY)

		shopTipStore.goodsName = commodityData.name

		if importantTitles and #importantTitles <= 0 then
			shopTipStore.subtitle = importantTitles[1]
		else
			shopTipStore.subtitle = ""
		end

		self:RefreshDressList(shopTipStore, commodityData)

		local moneyCfg = ConsumableConfig.GetConfig(commodityData.moneyItemId)
		shopTipStore.moneyIcon = moneyCfg and moneyCfg.SMoneyIconId or 0
		local num = gCommonItemManager:GetPackItemNum(commodityData.moneyItemId)
		local isOwned = gMallManager:CheckMallCommodityOwned(commodityData)

		if isOwned then
			shopTipStore.moneyEnoughCtrl = 2
		else
			shopTipStore.moneyEnoughCtrl = num >= actualPrice and 1 or 0
		end

		local content = shopTipStore.detailScrollRect.content
		local description = gMallManager:GetCommodityDescription(commodityData)
		content.text = description or ""

		if shopTipStore.isOwnedCtrl then
			shopTipStore.isOwnedCtrl = isOwned and 1 or 0
		end

		self._addCartSpiritOwned = self.IsCommoditySpiritOwned(self, commodityData)

		if shopTipStore.buyBtn then
			shopTipStore.buyBtn.interactable = self.IsCommodityBuyInteractable(self, commodityData)
		end

		if self._addCartSpiritOwned then
			shopTipStore.buyBtnText = LTConfig.TextCommonTextConfig.GetConfig(74000531).Text
		else
			shopTipStore.buyBtnText = LTConfig.TextScriptTextConfig.GetConfig(89901582).Text
		end

		self.UpdateAddCartInteractable(self)

		self.bindData.showDetailCtrl = self.GetDefaultShowDetailCtrl(self)
	end

	local isActionItem = gMallManager.IsActionItemCommodity(commodityData)

	if isActionItem then
		self.bindData.bgActive = false
	else
		self.UpdateBgActiveByMainTab(self)
	end

	self.TryOnCommodity(self, commodityData)

	if commodityData.SpiritId and commodityData.SpiritId <= 0 then
		self.UpdateAvatarIcon(self, commodityData.SpiritId)
	end

	self.RefreshBuyCounter(self, commodityData)
	self.RefreshShoppingCartCtrl(self, shopTipStore)
	self.RefreshRerollPoseBtnVisibility(self)

	if self.IsPropCommodity(self, commodityData) then
		local text = LTConfig.TextScriptTextConfig.GetConfig(89900931).Text
		self.bindData.ownNum = string.format(text, self.GetCommodityOwnNum(self, commodityData))
	end
end

M.IsCommoditySpiritOwned = function(self, commodityData)
	if not commodityData then
		return true
	end

	local t = commodityData.type

	if t == gMallManager.MallCommodityType.Fashion and t == gMallManager.MallCommodityType.FashionEx then
		return true
	end

	local belongSpiritId = 0
	local suitCfg = LTConfig.FashionSuitConfig.GetConfig(commodityData.bindId)

	if suitCfg and suitCfg.FashionIdList and #suitCfg.FashionIdList <= 0 then
		local fCfg = FashionConfig.GetConfig(suitCfg.FashionIdList[1])
		belongSpiritId = fCfg and fCfg.BelongSpiritId or 0
	end

	if belongSpiritId < 0 then
		return true
	end

	local FightSpiritConfig = LTConfig.FightSpiritConfig

	if belongSpiritId ~= FightSpiritConfig.DefaultMale or belongSpiritId ~= FightSpiritConfig.DefaultFemale then
		return true
	end

	return gSpiritManager:GetSpirit(belongSpiritId) and true or false
end

M.IsCommodityBuyInteractable = function(self, commodityData)
	return gMallManager:IsCommodityBuyable(commodityData) and self:IsCommoditySpiritOwned(commodityData)
end

M.GetCommodityOwnNum = function(self, commodityData)
	local bindId = commodityData.bindId or 0

	if bindId ~= 0 then
		return ""
	end

	local t = commodityData.type

	if t ~= gMallManager.MallCommodityType.Common or t ~= gMallManager.MallCommodityType.CommonEx then
		local packTab = gCommonItemManager:GetPackTabByTemplateId(bindId)

		if not packTab or packTab < 0 then
			return ""
		end

		return gCommonItemManager:GetPackItemNum(bindId)
	end

	return gMallManager:CheckMallCommodityOwned(commodityData) and 1 or 0
end

M.RefreshDressList = function(self, shopTipStore, commodityData)
	if not shopTipStore or not shopTipStore.dressList then
		return
	end

	self.dressListData = {}

	if commodityData and (commodityData.type ~= gMallManager.MallCommodityType.Fashion or commodityData.type ~= gMallManager.MallCommodityType.FashionEx) and commodityData.bindId and commodityData.bindId <= 0 then
		local suitCfg = LTConfig.FashionSuitConfig.GetConfig(commodityData.bindId)

		if suitCfg and suitCfg.FashionIdList then
			for _, fashionId in ipairs(suitCfg.FashionIdList) do
				if fashionId and fashionId <= 0 then
					table.insert(self.dressListData, gCommonItemManager:GetItemRenderData(fashionId))
				end
			end
		end
	end

	shopTipStore.dressList:SetSimpleList(#self.dressListData)
end

M.OnSimpleRenderDressListItem = function(self, btn, index)
	local data = self.dressListData[index + 1]

	if not data then
		return
	end

	gCommonItemManager:OnCommonItemRender(btn, index, data)
end

M.GetCommodityTagList = function(self, commodityData)
	if not commodityData then
		return {}, {}
	end

	local tagList = {}
	local importantTitles = {}
	local tagTitleSet = {}

	if (commodityData.type ~= gMallManager.MallCommodityType.Fashion or commodityData.type ~= gMallManager.MallCommodityType.FashionEx) and commodityData.bindId and commodityData.bindId <= 0 then
		local FashionSuitConfig = LTConfig.FashionSuitConfig
		local suitCfg = FashionSuitConfig.GetConfig(commodityData.bindId)

		if suitCfg and suitCfg.FashionIdList and #suitCfg.FashionIdList <= 0 then
			local firstFashionId = suitCfg.FashionIdList[1]
			local fashionCfg = FashionConfig.GetConfig(firstFashionId)

			if fashionCfg and fashionCfg.Tags then
				for i = 1, #fashionCfg.Tags do
					local tagId = fashionCfg.Tags[i]
					local tagCfg = FashionTagConfig.GetConfig(tagId)

					if tagCfg and not tagTitleSet[tagCfg.Name] then
						tagTitleSet[tagCfg.Name] = true
						local title = tagCfg.Name

						if tagId ~= 12 and fashionCfg.BelongSpiritId and fashionCfg.BelongSpiritId <= 0 then
							local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(fashionCfg.BelongSpiritId)

							if spiritCfg and spiritCfg.Name then
								title = title .. "·" .. spiritCfg.Name
							end
						end

						if tagCfg.ImportantTag then
							table.insert(importantTitles, title)
						else
							table.insert(tagList, {
								title = title,
								color = tagCfg.BackgroundColor
							})
						end
					end
				end
			end
		end
	end

	return tagList, importantTitles
end

M.RefreshQualityBadge = function(self, commodityData)
	local brandCfg = commodityData and gMallManager:GetBrandConfigFromBindId(commodityData.bindId)

	if brandCfg and brandCfg.IsShow then
		self.bindData.showQualityCtrl = 1
		self.bindData.qualityCtrl = brandCfg.FashionQuality or 0
	else
		self.bindData.showQualityCtrl = 0
	end
end

M.RefreshCarScore = function(self, commodityData)
	if not self.bindData.carScoreList then
		return
	end

	if not commodityData or commodityData.type == gMallManager.MallCommodityType.Vehicle then
		self.bindData.showCardetailCtrl = 0
		self.carScoreListData = {}

		self.bindData.carScoreList:SetSimpleList(0)

		return
	end

	local featureCfg = gCarStoreManager:GetFeatureByVehicleId(commodityData.bindId)
	local scoreList = {}

	if featureCfg then
		local VehicleConfig = LTConfig.VehicleConfig

		for i = 1, 5 do
			local name = VehicleConfig["Feature" .. i .. "Name"]
			local value = featureCfg["Feature" .. i]

			if name and value then
				table.insert(scoreList, {
					title = name,
					progress = value
				})
			end
		end
	end

	self.carScoreListData = scoreList

	if #scoreList <= 0 then
		self.bindData.showCardetailCtrl = 1
	else
		self.bindData.showCardetailCtrl = 0
	end

	self.bindData.carScoreList:SetSimpleList(#scoreList)
end

M.OnSimpleRenderCarScoreListItem = function(self, btn, index)
	local data = self.carScoreListData and self.carScoreListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = data.title
	store.des = data.title
	store.stateCtrl = 0
	store.progress.value = data.progress
end

M.OnSimpleClickSuitList = function(self, btn, index)
	local commodityData = self.currentSuitListData[index + 1]

	self.ShowCommodityDetail(self, commodityData)
end

M.OnSimpleRenderSearchListItem = function(self, btn, index)
	local commodityData = self.searchResultListData[index + 1]

	if not commodityData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local btnInstanceId = btn:GetInstanceID()

	for cachedCommodityId, cachedInfo in pairs(self.cachedSearchListBtns) do
		if cachedInfo.instanceId ~= btnInstanceId and cachedCommodityId == commodityData.id then
			self.cachedSearchListBtns[cachedCommodityId] = nil
		end
	end

	self.cachedSearchListBtns[commodityData.id] = {
		btn = btn,
		instanceId = btnInstanceId,
		commodityData = commodityData
	}

	self.RenderCommodityItem(self, store, commodityData)
end

M.OnSimpleClickSearchList = function(self, btn, index)
	local commodityData = self.searchResultListData[index + 1]

	self.ShowCommodityDetail(self, commodityData)
end

M.OnClickBuyBtn = function(self)
	if not self.selectedSuitItemId or self.selectedSuitItemId ~= 0 then
		gDisplayMessageMgr:ShowMessageContentDebug("temp请先选择商品")

		return
	end

	local commodityData = self.GetSelectedCommodityData(self)

	if not commodityData then
		gDisplayMessageMgr:ShowMessageContentDebug("temp商品数据异常")

		return
	end

	local count = gMallManager:IsCommodityCountChangeable(commodityData) and self.buyNum or 1

	gMallManager:OpenDoubleConfirmInstant(commodityData, count, function ()
		self:OnBuySuccess(commodityData)
	end)
end

M.OnClickShowDetailBtn = function(self)
	local shopTipStore = gStoreManager:GetStoreGroup(self.bindData.shopTip.Store):GetStoreByWidget(self.bindData.shopTip)

	if shopTipStore then
		self.bindData.showDetailCtrl = 1 - (self.bindData.showDetailCtrl or 0)
	end
end

M.OnSimpleRenderShopTipTagListItem = function(self, btn, index)
	local tagData = self.tagList[index + 1]

	if not tagData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.title = tagData.title

		if tagData.color and #tagData.color > 4 then
			local color = Color.New(tagData.color[1] / 255, tagData.color[2] / 255, tagData.color[3] / 255, tagData.color[4] / 255)
			store.color = color
		end
	end
end

M.ClearSearch = function(self)
	if not self.STATE_Started then
		return
	end

	self.bindData.inputField.text = ""
	self.bindData.searchCtrl = 0
	self.bindData.searchCloseBtnActive = false
	self.searchResultListData = {}

	self.bindData.searchList:SetSimpleList(0)

	self.cachedSearchListBtns = {}
	self.searchNodeActive = false
end

M.ClearShopTipDetail = function(self)
	if not self.shopTipInit then
		return
	end

	self.bindData.itemIconId = 0
	self.bindData.bgIconId = 0
	self.bindData.showQualityCtrl = 0
	self.bindData.showCardetailCtrl = 0

	if self.bindData.carScoreList then
		self.carScoreListData = {}

		self.bindData.carScoreList:SetSimpleList(0)
	end

	local shopTipStore = gStoreManager:GetStoreGroup(self.bindData.shopTip.Store):GetStoreByWidget(self.bindData.shopTip)

	if shopTipStore then
		if shopTipStore.tagList then
			shopTipStore.tagList:SetSimpleList(0)
		end

		if shopTipStore.dressList then
			shopTipStore.dressList:SetSimpleList(0)
		end

		self.dressListData = {}
		shopTipStore.price = ""
		shopTipStore.goodsName = ""
		shopTipStore.subtitle = ""
		shopTipStore.moneyIcon = 0
		shopTipStore.isDiscountCtrl = 1
		shopTipStore.originPrice = ""
		shopTipStore.moneyEnoughCtrl = 0
		local content = shopTipStore.detailScrollRect.content
		content.text = ""
	end

	if self.bindData.rerollPoseBtn then
		self.bindData.rerollPoseBtn.gameObject:SetActive(false)
	end
end

M.ClearSelection = function(self)
	self.selectedSuitItemId = 0
	self.isCurrentCommodityExclusive = false

	self.bindData.suitList:SelectItem(-1, false)
	self.bindData.searchList:SelectItem(-1, false)
	self:ClearShopTipDetail()
	self:UpdateSwitchRoleButtonVisibility(false)

	if self.parentStore then
		self.parentStore.tryOnFashionId = 0
	end
end

M.OnInputValueChanged = function(self)
	local searchText = self.bindData.inputField.text

	if string.is_null_or_empty(searchText) then
		self.bindData.searchCtrl = 0
		self.bindData.searchCloseBtnActive = false
		self.searchResultListData = {}

		self.bindData.searchList:SetSimpleList(0)

		self.cachedSearchListBtns = {}
		self.searchNodeActive = false

		return
	end

	self.bindData.searchCloseBtnActive = true
	self.bindData.searchCtrl = 1
	self.searchNodeActive = true
	local searchKey = self.currentSubTabType == 0 and self.currentSubTabType or self.currentTabType
	local searchResultList = {}

	if self.parentStore then
		searchResultList = self.parentStore:SearchCommodity(searchText, searchKey)
	end

	self:SortCommodityList(searchResultList)

	self.bindData.searchCtrl = #searchResultList ~= 0 and 2 or 1
	self.currentActiveListType = self.ListType.Search
	self.cachedSearchListBtns = {}
	self.searchResultListData = searchResultList

	self.bindData.searchList:SetSimpleList(#searchResultList)
end

M.OnInputFieldActivate = function(self)
	if self.bindData.searchNodeArea then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.searchNodeArea
	end
end

M.OnInputFieldDeActivate = function(self)
	if self.rootArea then
		self.currentActiveAreaCo = coroutine.stop(self.currentActiveAreaCo)
		self.currentActiveAreaCo = coroutine.start(function ()
			coroutine.step()

			if self.rootArea then
				SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
			end
		end)
	end
end

M.OnSearchCloseClick = function(self)
	self.ClearSearch(self)

	self.searchNodeActive = false

	if self.rootArea then
		self.currentActiveAreaCo = coroutine.stop(self.currentActiveAreaCo)
		self.currentActiveAreaCo = coroutine.start(function ()
			coroutine.step()

			if self.rootArea then
				SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
			end
		end)
	end
end

M.GetSelectedCommodityData = function(self)
	if not self.selectedSuitItemId or self.selectedSuitItemId ~= 0 then
		return nil
	end

	if self.bindData.searchCtrl ~= 1 or self.bindData.searchCtrl ~= 2 then
		for _, data in ipairs(self.searchResultListData) do
			if data.id ~= self.selectedSuitItemId then
				return data
			end
		end
	end

	for _, data in ipairs(self.currentSuitListData) do
		if data.id ~= self.selectedSuitItemId then
			return data
		end
	end

	return nil
end

M.OnBuySuccess = function(self, commodityData)
	if self.bindData.searchCtrl ~= 1 or self.bindData.searchCtrl ~= 2 then
		self.cachedSearchListBtns = {}

		self:SortCommodityList(self.searchResultListData)
		self.bindData.searchList:SetSimpleList(#self.searchResultListData)
	else
		self.cachedSuitListBtns = {}

		self:SortCommodityList(self.currentSuitListData)
		self.bindData.suitList:SetSimpleList(#self.currentSuitListData)
	end

	if commodityData and self.selectedSuitItemId ~= commodityData.id then
		local isOwned = gMallManager:CheckMallCommodityOwned(commodityData)
		local shopTipStore = gStoreManager:GetStoreGroup(self.bindData.shopTip.Store):GetStoreByWidget(self.bindData.shopTip)

		if shopTipStore then
			if shopTipStore.buyBtn then
				shopTipStore.buyBtn.interactable = self.IsCommodityBuyInteractable(self, commodityData)
			end

			if shopTipStore.isOwnedCtrl then
				shopTipStore.isOwnedCtrl = isOwned and 1 or 0
			end

			if isOwned then
				shopTipStore.moneyEnoughCtrl = 2
			else
				local actualPrice = commodityData.price

				if not commodityData.discountExpired then
					local discountPrice, originalPrice = gMallManager:GetCommodityDiscountInfo(commodityData.id)

					if discountPrice and originalPrice and originalPrice <= 0 then
						actualPrice = discountPrice
					end
				end

				local num = gCommonItemManager:GetPackItemNum(commodityData.moneyItemId)
				shopTipStore.moneyEnoughCtrl = num >= actualPrice and 1 or 0
			end
		end

		self.RefreshBuyCounter(self, commodityData)

		local text = LTConfig.TextScriptTextConfig.GetConfig(89900931).Text
		self.bindData.ownNum = string.format(text, self.GetCommodityOwnNum(self, commodityData))
	end

	gMessageManager:SendMessage(gEventConstants.PACK_ITEM_CHANGED)
end

M.RenderPropCommodityItem = function(self, store, propData)
	if not store or not propData then
		return
	end

	store.name = propData.name or ""
	store.iconId = propData.iconId
	store.quality = propData.quality
	store.qualityCtrl = propData.quality
	local moneyItemCfg = ConsumableConfig.GetConfig(propData.moneyItemId)
	local moneyIconId = moneyItemCfg and moneyItemCfg.SMoneyIconId or 0

	if moneyItemCfg then
		store.moneyIcon = moneyIconId
	end

	local hasOwned = gMallManager:CheckMallCommodityOwned(propData)
	store.isHaved = hasOwned and 1 or 0
	store.isAvailable = 1
	store.moneyColor = 0
	store.isShowTask = 0
	store.taskIcon = 0
	store.showTaskWarningCtrl = 0
	store.taskIconId = 0
	store.moneyIconId = moneyIconId
	local actualPrice = propData.price

	if propData.discountExpired then
		store.hasDiscountCtrl = 0
		store.discount = ""
		store.discountTypeCtrl = 0
		store.showRefreshTimeCtrl = 0
		store.refreshTime = ""
	else
		local discountPrice, originalPrice = gMallManager:GetCommodityDiscountInfo(propData.id)

		if discountPrice and originalPrice and originalPrice <= 0 then
			store.hasDiscountCtrl = 1
			local discountPercent = math.floor((1 - discountPrice / originalPrice) * 100)
			store.discount = string.format("-%d", discountPercent)
			store.discountTypeCtrl = 1
			actualPrice = discountPrice
		else
			store.hasDiscountCtrl = 0
			store.discount = ""
			store.discountTypeCtrl = 0
		end

		local discountEndTime = gMallManager:GetCommodityDiscountEndTime(propData.id)

		if discountEndTime and discountEndTime <= 0 then
			local now = gLuaDataManager.serverTime
			local remainingTime = discountEndTime - now

			if remainingTime <= 0 then
				store.showRefreshTimeCtrl = 1
				store.refreshTime = gTimeUtils:GetCornerTimeStr(remainingTime)
			else
				store.showRefreshTimeCtrl = 0
				store.refreshTime = ""
			end
		else
			store.showRefreshTimeCtrl = 0
			store.refreshTime = ""
		end
	end

	local priceText = tostring(actualPrice)
	store.priceCurrent = priceText
	store.moneyNum = priceText
	local hasEnoughMoney = actualPrice > gCommonItemManager:GetPackItemNum(propData.moneyItemId)
	store.singleMoneyLackCtrl = hasEnoughMoney and 0 or 1
	local canBuy = gMallManager:IsCommodityBuyable(propData)
	store.stateCtrl = canBuy and 0 or 1
end

M.RefreshCommodityNames = function(self)
	if not self.commodityDataCache then
		return
	end

	for mallId, commodityList in pairs(self.commodityDataCache) do
		if commodityList and type(commodityList) ~= "table" then
			for _, commodityData in ipairs(commodityList) do
				if commodityData and commodityData.id then
					local commodityCfg = LTConfig.MallCommodityConfig.GetConfig(commodityData.id)

					if commodityCfg then
						commodityData.name = gMallManager:GetCommodityName(commodityCfg, commodityData.consumeCfg)
						commodityData.description = commodityCfg.Desc or ""
					end
				end
			end
		end
	end
end

M.RefreshBuyCounter = function(self, commodityData)
	if not self.SubGroup or not self.SubGroup.CommonCounterStore then
		return
	end

	if not commodityData or not gMallManager:IsCommodityCountChangeable(commodityData) then
		self.buyNum = 1

		return
	end

	local maxNum = self:GetMaxBuyNum(commodityData)

	self.SubGroup.CommonCounterStore:SetData({
		["\\x8b528}\\x89w\\xd8;\\xbf\\xbc"] = 1,
		range = {
			1,
			maxNum
		},
		valChangeCallback = self:CreateAction("OnBuyNumChange")
	})
	self.SubGroup.CommonCounterStore:OnBuyNumChange(1)
end

M.GetMaxBuyNum = function(self, commodityData)
	if not commodityData then
		return 1
	end

	local maxByLimit = gMallManager:GetMaxBuyableCount(commodityData)
	local actualPrice = commodityData.price or 0

	if not commodityData.discountExpired then
		local discountPrice, originalPrice = gMallManager:GetCommodityDiscountInfo(commodityData.id)

		if discountPrice and originalPrice and originalPrice <= 0 then
			actualPrice = discountPrice
		end
	end

	local maxByMoney = nil

	if actualPrice <= 0 then
		local money = gMallManager:GetAffordableTotalByItemId(commodityData.moneyItemId)
		maxByMoney = math.floor(money / actualPrice)
	end

	local maxNum = maxByLimit

	if maxByMoney then
		maxNum = maxNum and math.min(maxNum, maxByMoney) or maxByMoney
	end

	maxNum = maxNum or 999

	return math.max(1, maxNum)
end

M.RefreshShoppingCartCtrl = function(self, shopTipStore)
	if not shopTipStore then
		return
	end

	local show = false
	local mallId = self.currentSubTabType and self.currentSubTabType <= 0 and self.currentSubTabType or self.currentTabType
	local mallCfg = mallId and mallId <= 0 and LTConfig.MallConfig.GetConfig(mallId) or nil
	show = mallCfg and mallCfg.IsShoppingCart or false
	shopTipStore.shopingcartCtrl = show and 1 or 0
end

M.RefreshAddCartText = function(self, commodityData)
	local text = ""
	local inCart = commodityData and commodityData.id and gMallManager:GetCartItemCount(commodityData.id) >= 0

	if inCart then
		local cfg = TextConfig.GetConfig(73970816)
		text = cfg and cfg.Text or "have added"
	else
		local cfg = InputButtonNameConfig.GetConfig(814)
		text = cfg and cfg.Name or ""
	end

	self.bindData.addCartText = text
	self._addCartInCart = inCart

	self.UpdateAddCartInteractable(self)
end

M.UpdateAddCartInteractable = function(self)
	local canInteract = not self._addCartInCart and self._addCartSpiritOwned

	if self.bindData.addCartBtn then
		self.bindData.addCartBtn.interactable = canInteract
	end

	if self.bindData.addCartBtnPC then
		self.bindData.addCartBtnPC.interactable = canInteract
	end
end

M.OnBuyNumChange = function(self, val)
	self.buyNum = val or 1
	local commodityData = self:GetSelectedCommodityData()

	if not commodityData then
		return
	end

	local shopTipStore = gStoreManager:GetStoreGroup(self.bindData.shopTip.Store):GetStoreByWidget(self.bindData.shopTip)

	if not shopTipStore then
		return
	end

	local actualPrice = commodityData.price or 0
	local hasDiscount = false

	if not commodityData.discountExpired then
		local discountPrice, originalPrice = gMallManager:GetCommodityDiscountInfo(commodityData.id)

		if discountPrice and originalPrice and originalPrice <= 0 then
			hasDiscount = true
			actualPrice = discountPrice
			shopTipStore.originPrice = originalPrice * self.buyNum
		end
	end

	local totalPrice = actualPrice * self.buyNum
	shopTipStore.price = totalPrice
	local isOwned = gMallManager:CheckMallCommodityOwned(commodityData)

	if isOwned then
		shopTipStore.moneyEnoughCtrl = 2
	else
		local num = gCommonItemManager:GetPackItemNum(commodityData.moneyItemId)
		shopTipStore.moneyEnoughCtrl = num >= totalPrice and 1 or 0
	end

	if shopTipStore.buyBtn then
		shopTipStore.buyBtn.interactable = self.IsCommodityBuyInteractable(self, commodityData)
	end
end
