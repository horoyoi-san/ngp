-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ShopRecommendPanelStore.lua
-- Decompiled from: 01325_ShopRecommendPanelStore.lua_b6be4a589c8b.luajit

local MallRecommendConfig = LTConfig.MallRecommendConfig
local MallCommodityConfig = LTConfig.MallCommodityConfig
local TextConfig = LTConfig.TextConfig
local Utils = SGUI.Utils
local OWNED_TAG_TEXT_ID = 73977029
C_ShopRecommendPanelStore = DefClass("C_ShopRecommendPanelStore", C_ShopRecommendPanelStore, C_StoreGroup)
GroupName2Class.ShopRecommendPanelStore = C_ShopRecommendPanelStore
local M = C_ShopRecommendPanelStore

M.ctor = function(self)
	self.recommendListData = {}
	self.selectedIndex = -1
	self.parentStore = nil
	self.currentRecommendItem = nil
	self.hasAnyTimeLimitedDiscount = false
	self.lastUpdateTime = 0
	self.scrollTemplateTimers = {}
	self.scrollTemplateStores = {}
	self.cachedRecommendListBtns = {}
	self.lastTabRectIndex = -1
end

M.DefineAllVariables = function(self)
	self.hasAnyTimeLimitedDiscount = false
	self.lastUpdateTime = 0
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self.RestartAllScrollTemplateTimers(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
	self.ClearAllScrollTemplateTimers(self)
end

M.OnDestroy = function(self)
	self.CleanupMonthlyStoreIcon(self)

	self.selectedIndex = -1
	self.currentRecommendItem = nil
	self.hasAnyTimeLimitedDiscount = false
	self.lastUpdateTime = 0

	self.ClearAllScrollTemplateTimers(self)

	self.scrollTemplateStores = {}
	self.cachedRecommendListBtns = {}
	self.lastTabRectIndex = -1
	self.lastWidget = nil
	self._scrollRegistered = false
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

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.parentStore = data and data.parentStore or nil
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootGo:GetComponent("UNavigationArea")

	self:InitRecommendListData()
	self:RefreshRecommendList()
	self:RegisterBaseUpdownScroll()

	local keepRecommendSelection = data and data.keepRecommendSelection or false

	if keepRecommendSelection then
		self.bindData.recommendList:SelectItem(self.selectedIndex, true)
	elseif #self.recommendListData <= 0 then
		self.bindData.recommendList:SelectItem(0, true)
		self:OnSelectRecommendItem(0)
		self.bindData.recommendList:SetNavSelectToTop()
	end
end

M.OnTabLeave = function(self)
	self.CleanupMonthlyStoreIcon(self)
end

M.CleanupMonthlyStoreIcon = function(self)
	if gCS.LuaUtils.IsOnPS5 and self.parentStore and self.lastTabRectIndex ~= 0 then
		local parentTabRectIndex = self.parentStore.lastTabRectIndex or 0
		local iconId = self.parentStore.m_Id * 1000 + parentTabRectIndex * 10 + self.lastTabRectIndex

		gPanelManager:RemovePS5StoreIconPanel(iconId)
	end
end

M.OnLanguageChange = function(self, lang)
	if not self.STATE_EnableOnce or not self.recommendListData or #self.recommendListData ~= 0 then
		return
	end

	local selectedIndex = self.selectedIndex > 0 and self.selectedIndex or 0
	local store = self.scrollTemplateStores and self.scrollTemplateStores[selectedIndex]
	local savedBarIndex = store and store.currentSelectedBarIndex or 0

	self:InitRecommendListData()
	self:RefreshRecommendList()

	selectedIndex = selectedIndex >= #self.recommendListData and selectedIndex or 0

	self.bindData.recommendList:SelectItem(selectedIndex, true)

	self.selectedIndex = selectedIndex
	local itemData = self.recommendListData[selectedIndex + 1]

	if not itemData then
		return
	end

	if itemData.tIndex ~= 0 and itemData.prebuiltMergedData and #itemData.prebuiltMergedData <= 0 then
		local barIdx = math.max(0, math.min(savedBarIndex, #itemData.prebuiltMergedData - 1))
		store = self.scrollTemplateStores[selectedIndex]

		if store then
			store.currentSelectedBarIndex = barIdx

			if store.barList then
				store.barList:SelectItem(barIdx, true)
			end

			if not itemData.mergedItems or #itemData.mergedItems > 0 or not itemData.mergedItems then
				local merged = {
					itemData
				}
			end

			self.UpdateWideScrollTemplateDisplay(self, store, merged[barIdx + 1])
		end

		self.currentRecommendItem = itemData.prebuiltMergedData[barIdx + 1]
	else
		self.currentRecommendItem = itemData
	end

	if self.lastWidget and self.currentRecommendItem then
		local tabStore = gStoreManager:GetStoreGroup(self.lastWidget.Store)

		if tabStore then
			tabStore.OnShow(tabStore, nil, {
				parentStore = self.parentStore,
				recommendItem = self.currentRecommendItem,
				recommendList = self.bindData.recommendList
			})
		end
	end
end

M.GetRecommendDesc = function(self, recommendCfg, firstCommodityCfg)
	local desc = recommendCfg and recommendCfg.Desc or ""

	if desc and desc == "" then
		return desc
	end

	if firstCommodityCfg and firstCommodityCfg.Desc then
		desc = firstCommodityCfg.Desc

		if desc and desc == "" then
			return desc
		end
	end

	return ""
end

M.InitRecommendListData = function(self)
	self.recommendListData = {}
	self.hasAnyTimeLimitedDiscount = false
	local allProcessedItems = gMallManager:BuildSortedRecommendCfgList()

	for _, processedItem in ipairs(allProcessedItems) do
		local cfg = processedItem.cfg
		local displayCommodities = processedItem.displayCommodities or {}
		local commodityDiscountEndTime = 0

		if #displayCommodities <= 0 then
			commodityDiscountEndTime = gMallManager:GetCommodityDiscountEndTime(displayCommodities[1]) or 0

			if commodityDiscountEndTime <= 0 then
				self.hasAnyTimeLimitedDiscount = true
				self.lastUpdateTime = gLuaDataManager.serverTime
			end
		end

		if processedItem.isDiscountGroup and processedItem.mergedItems then
			for _, commodityData in ipairs(processedItem.mergedItems) do
				if (gMallManager:GetCommodityDiscountEndTime(commodityData.id) or 0) <= 0 then
					self.hasAnyTimeLimitedDiscount = true
					self.lastUpdateTime = gLuaDataManager.serverTime

					break
				end
			end
		end

		local firstCommodityCfg = #displayCommodities <= 0 and MallCommodityConfig.GetConfig(displayCommodities[1]) or nil
		local bannerTitleCfg = cfg.BannerTitle and cfg.BannerTitle == 0 and TextConfig.GetConfig(cfg.BannerTitle) or nil
		local name = bannerTitleCfg and bannerTitleCfg.Text and bannerTitleCfg.Text == "" and bannerTitleCfg.Text or firstCommodityCfg and firstCommodityCfg.Name or ""
		local subTitle = cfg.SubTitle or ""
		local desc = self:GetRecommendDesc(cfg, firstCommodityCfg)
		local picture = cfg.Picture and cfg.Picture == 0 and cfg.Picture or firstCommodityCfg and firstCommodityCfg.Picture or 0
		local bigPicture = cfg.BigPicture and cfg.BigPicture == 0 and cfg.BigPicture or firstCommodityCfg and firstCommodityCfg.BigPicture or 0
		local prebuiltMergedData = nil

		if processedItem.tIndex ~= 0 and processedItem.mergedItems and #processedItem.mergedItems <= 0 then
			prebuiltMergedData = {}

			if processedItem.isDiscountGroup then
				for _, commodityData in ipairs(processedItem.mergedItems) do
					local commodityCfg = commodityData.mallCfg

					table.insert(prebuiltMergedData, {
						["*9\\xed`\\x9b\\xf8!\\xa6;\\xc1\\xe0\\xe9a\\xeb"] = true,
						tIndex = processedItem.tIndex,
						configId = cfg.Id,
						id = cfg.Id,
						commodityId = commodityData.id,
						name = commodityData.name or "",
						subTitle = commodityData.description or "",
						desc = commodityData.description or "",
						picture = commodityCfg and commodityCfg.Picture or commodityData.icon or 0,
						bigPicture = commodityCfg and commodityCfg.BigPicture or 0,
						lable = cfg.Lable or "",
						type = cfg.Type,
						subType = cfg.SubType,
						linkTo = cfg.LinkTo or {},
						displayCommodities = {
							commodityData.id
						},
						commodityDiscountEndTime = gMallManager:GetCommodityDiscountEndTime(commodityData.id) or 0,
						mergedItems = processedItem.mergedItems
					})
				end
			else
				for _, mergedCfg in ipairs(processedItem.mergedItems) do
					local mergedBannerTitleCfg = mergedCfg.BannerTitle and mergedCfg.BannerTitle == 0 and TextConfig.GetConfig(mergedCfg.BannerTitle) or nil
					local mergedName = mergedBannerTitleCfg and mergedBannerTitleCfg.Text and mergedBannerTitleCfg.Text == "" and mergedBannerTitleCfg.Text or firstCommodityCfg and firstCommodityCfg.Name or ""
					local mergedSubTitle = mergedCfg.SubTitle and mergedCfg.SubTitle == "" and mergedCfg.SubTitle or firstCommodityCfg and firstCommodityCfg.Desc or ""
					local mergedDesc = self:GetRecommendDesc(mergedCfg, firstCommodityCfg)
					local mergedPicture = mergedCfg.Picture and mergedCfg.Picture == 0 and mergedCfg.Picture or firstCommodityCfg and firstCommodityCfg.Picture or 0
					local mergedBigPicture = mergedCfg.BigPicture and mergedCfg.BigPicture == 0 and mergedCfg.BigPicture or firstCommodityCfg and firstCommodityCfg.BigPicture or 0

					table.insert(prebuiltMergedData, {
						tIndex = processedItem.tIndex,
						configId = mergedCfg.Id,
						id = mergedCfg.Id,
						name = mergedName,
						subTitle = mergedSubTitle,
						desc = mergedDesc,
						picture = mergedPicture,
						bigPicture = mergedBigPicture,
						lable = mergedCfg.Lable or "",
						type = mergedCfg.Type,
						subType = mergedCfg.SubType,
						linkTo = mergedCfg.LinkTo or {},
						displayCommodities = displayCommodities,
						mergedItems = processedItem.mergedItems
					})
				end
			end
		end

		table.insert(self.recommendListData, {
			tIndex = processedItem.tIndex,
			configId = cfg.Id,
			id = cfg.Id,
			name = name,
			subTitle = subTitle,
			desc = desc,
			picture = picture,
			bigPicture = bigPicture,
			lable = cfg.Lable or "",
			type = cfg.Type,
			subType = cfg.SubType,
			linkTo = cfg.LinkTo or {},
			displayCommodities = displayCommodities,
			commodityDiscountEndTime = commodityDiscountEndTime,
			mergedItems = processedItem.mergedItems,
			prebuiltMergedData = prebuiltMergedData,
			isDiscountGroup = processedItem.isDiscountGroup,
			isBundleAllOwned = processedItem.isBundleAllOwned
		})
	end
end

M.RefreshRecommendList = function(self)
	if #self.recommendListData <= 0 then
		self.bindData.recommendList:SetSimpleList(#self.recommendListData)

		self.cachedRecommendListBtns = {}
	end
end

M.UpdateDiscountCountdown = function(self)
	local now = gLuaDataManager.serverTime
	local needUpdateBtns = {}
	local hasExpired = false

	for index, itemData in ipairs(self.recommendListData) do
		if itemData.isDiscountGroup and itemData.mergedItems then
			for _, commodityData in ipairs(itemData.mergedItems) do
				local endTime = gMallManager:GetCommodityDiscountEndTime(commodityData.id) or 0

				if endTime <= 0 and endTime < now then
					hasExpired = true

					break
				end
			end

			if hasExpired then
				break
			end
		end

		if itemData.commodityDiscountEndTime and itemData.commodityDiscountEndTime <= 0 then
			if itemData.commodityDiscountEndTime < now then
				hasExpired = true

				break
			else
				table.insert(needUpdateBtns, {
					index = index - 1,
					itemData = itemData
				})
			end
		end
	end

	if hasExpired then
		self.InitRecommendListData(self)
		self.RefreshRecommendList(self)

		self.cachedRecommendListBtns = {}

		return
	end

	for _, updateInfo in ipairs(needUpdateBtns) do
		local cachedBtn = self.cachedRecommendListBtns[updateInfo.index]

		if cachedBtn and cachedBtn.btn and updateInfo.itemData then
			local store = gStoreManager:GetStoreGroup(cachedBtn.btn.Store):GetStoreByWidget(cachedBtn.btn)

			if store then
				cachedBtn.itemData = updateInfo.itemData

				if updateInfo.itemData.tIndex ~= 0 then
					self.RenderWideScrollTemplate(self, cachedBtn.btn, updateInfo.itemData, updateInfo.index)
				elseif updateInfo.itemData.tIndex ~= 1 then
					self.RenderShortTemplate(self, cachedBtn.btn, updateInfo.itemData)
				elseif updateInfo.itemData.tIndex ~= 2 then
					self.RenderWideTemplate(self, cachedBtn.btn, updateInfo.itemData)
				end
			end
		end
	end
end

M.GetFormattedLabel = function(self, lable, commodityId, discountEndTime)
	if not lable or lable ~= "" or not string.find(lable, "%%s") then
		return lable or ""
	end

	local endTime = discountEndTime or commodityId and gMallManager:GetCommodityDiscountEndTime(commodityId) or 0

	if endTime ~= 0 then
		return LTConfig.TextConfig.GetConfig(73970801).Text
	end

	if endTime <= 0 then
		local remainingTime = endTime - gLuaDataManager.serverTime

		if remainingTime <= 0 then
			return string.format(lable, gTimeUtils:GetLongTimeStrHaveDay(remainingTime))
		end
	end

	return lable
end

M.GetBannerTagText = function(self, itemData, commodityId)
	if itemData and itemData.isBundleAllOwned then
		local textCfg = TextConfig.GetConfig(OWNED_TAG_TEXT_ID)

		return textCfg and textCfg.Text or ""
	end

	return self:GetFormattedLabel(itemData and itemData.lable, commodityId, itemData and itemData.commodityDiscountEndTime)
end

M.OnSelectRecommendItem = function(self, index)
	local itemData = self.recommendListData[index + 1]

	if not itemData then
		return
	end

	local previousIndex = self.selectedIndex

	if previousIndex == index then
		if previousIndex > 0 then
			local previousStore = self.scrollTemplateStores[previousIndex]

			if previousStore then
				self.StopScrollTemplateTimer(self, previousStore)
			end
		end

		self.selectedIndex = index

		if itemData.tIndex ~= 0 then
			local newStore = self.scrollTemplateStores[index]

			if newStore then
				self.StopScrollTemplateTimer(self, newStore)
			end
		end

		if previousIndex > 0 then
			self.RestartPreviousScrollTemplateTimer(self, previousIndex)
		end
	elseif itemData.tIndex ~= 0 then
		local currentStore = self.scrollTemplateStores[index]

		if currentStore then
			self.StopScrollTemplateTimer(self, currentStore)
		end
	end

	if previousIndex ~= index and self.currentRecommendItem then
		itemData = self.currentRecommendItem
	else
		if itemData.tIndex ~= 0 and itemData.prebuiltMergedData then
			local scrollTemplateStore = self.scrollTemplateStores[index]

			if scrollTemplateStore and scrollTemplateStore.currentSelectedBarIndex then
				itemData = itemData.prebuiltMergedData[scrollTemplateStore.currentSelectedBarIndex + 1] or itemData
			end
		end

		self.currentRecommendItem = itemData
	end

	local tabRectIndex = self.GetTabRectIndexByType(self, itemData.type, itemData.subType)

	if self.bindData.tabRect.selectedIndex == tabRectIndex then
		self.bindData.tabRect.selectedIndex = tabRectIndex
	else
		self.RefreshCurrentTabContent(self, tabRectIndex)
	end
end

M.GetTabRectIndexByType = function(self, type, subType)
	local SubTypeType = MallRecommendConfig.SubTypeType

	if subType ~= SubTypeType.Monthly then
		return 0
	elseif subType ~= SubTypeType.Discount then
		return 2
	elseif subType ~= SubTypeType.BattlePass then
		return 1
	elseif type ~= 1 then
		return 1
	else
		return 2
	end
end

M.RefreshCurrentTabContent = function(self, tabIndex)
	if self.bindData.tabRect.selectedIndex ~= tabIndex and not gCS.LuaUtils.IsNull(self.lastWidget) then
		self.OnTabRectRender(self, tabIndex, self.lastWidget)
	end

	self.bindData.tabRect.selectedIndex = tabIndex
end

M.ClearAllScrollTemplateTimers = function(self)
	if not self.scrollTemplateTimers then
		return
	end

	for _, timer in pairs(self.scrollTemplateTimers) do
		if timer then
			timer.Stop(timer)
		end
	end

	self.scrollTemplateTimers = {}
end

M.RestartAllScrollTemplateTimers = function(self)
	for parentIndex, store in pairs(self.scrollTemplateStores) do
		if store and store.mergedItems and #store.mergedItems <= 1 and self.selectedIndex == parentIndex then
			self.StartScrollTemplateTimer(self, store, parentIndex)
		end
	end
end

M.RestartPreviousScrollTemplateTimer = function(self, previousIndex)
	if not previousIndex or previousIndex >= 0 then
		return
	end

	local store = self.scrollTemplateStores[previousIndex]

	if store and store.mergedItems and #store.mergedItems <= 1 then
		self.StartScrollTemplateTimer(self, store, previousIndex)
	end
end

M.StartScrollTemplateTimer = function(self, store, parentIndex)
	if not store then
		return
	end

	self.scrollTemplateTimers = self.scrollTemplateTimers or {}
	local storeId = tostring(store)

	if self.scrollTemplateTimers[storeId] then
		self.scrollTemplateTimers[storeId]:Stop()

		self.scrollTemplateTimers[storeId] = nil
	end

	local timer = Timer.New(function ()
		self:OnScrollTemplateAutoSwitch(store, parentIndex)
	end, 5, -1):Start()
	self.scrollTemplateTimers[storeId] = timer
	store.autoSwitchTimer = timer
	store.autoSwitchStoreId = storeId
end

M.StopScrollTemplateTimer = function(self, store)
	if not store or not store.autoSwitchStoreId then
		return
	end

	if self.scrollTemplateTimers[store.autoSwitchStoreId] then
		self.scrollTemplateTimers[store.autoSwitchStoreId]:Stop()

		self.scrollTemplateTimers[store.autoSwitchStoreId] = nil
	end
end

M.OnScrollTemplateAutoSwitch = function(self, store, parentIndex)
	if not store or not store.mergedItems or self.selectedIndex ~= parentIndex then
		return
	end

	local currentIndex = store.currentSelectedBarIndex or 0
	local nextIndex = (currentIndex + 1) % #store.mergedItems
	store.currentSelectedBarIndex = nextIndex
	local nextCfg = store.mergedItems[nextIndex + 1]

	if not nextCfg then
		return
	end

	if store.barList then
		store.barList:RefreshList()
	end

	self.UpdateWideScrollTemplateDisplay(self, store, nextCfg)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.SYNC_MONTHLY_PASS_INFO] = self.CreateAction(self, "OnPurchaseStateChanged"),
		[gEventConstants.BUY_BATTLEPASS] = self.CreateAction(self, "OnPurchaseStateChanged"),
		[gEventConstants.MALL_RECEIEVE_ITEM] = self.CreateAction(self, "OnPurchaseStateChanged"),
		[gEventConstants.GACHA_POOL_COUNT_CHANGE] = self.CreateAction(self, "OnPurchaseStateChanged")
	}
end

M.OnPurchaseStateChanged = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.RebuildListKeepSelection(self)
end

M.OnPanelRestore = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.RebuildListKeepSelection(self)
end

M.RebuildListKeepSelection = function(self)
	if not self.recommendListData or #self.recommendListData ~= 0 then
		return
	end

	local prevIndex = self.selectedIndex > 0 and self.selectedIndex or 0
	local prevData = self.recommendListData[prevIndex + 1]
	local prevConfigId = prevData and prevData.configId

	self:InitRecommendListData()
	self:RefreshRecommendList()

	self.cachedRecommendListBtns = {}

	if #self.recommendListData ~= 0 then
		return
	end

	local newIndex = 0

	if prevConfigId then
		for i, itemData in ipairs(self.recommendListData) do
			if itemData.configId ~= prevConfigId then
				newIndex = i - 1

				break
			end
		end
	end

	self.bindData.recommendList:SelectItem(newIndex, true)

	self.currentRecommendItem = nil

	self:OnSelectRecommendItem(newIndex)
end

M.RegisterWidget = function(self)
	self.bindData.recommendList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderRecommendListItem")
	self.bindData.recommendList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickRecommendList")
	self.bindData.recommendList.luaSelectedChanged = self.CreateAction(self, "OnRecommendListSelectChanged")
	self.bindData.recommendList.onGetTIndex = self.CreateAction(self, "OnGetRecommendListTIndex")
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnTabRectRender")
end

M.OnGetRecommendListTIndex = function(self, index)
	local data = self.recommendListData[index + 1]

	return data and data.tIndex or 0
end

M.OnSimpleRenderRecommendListItem = function(self, btn, index)
	local itemData = self.recommendListData[index + 1]

	if not itemData then
		return
	end

	local btnInstanceId = btn.GetInstanceID(btn)

	for cachedIndex, cachedInfo in pairs(self.cachedRecommendListBtns) do
		if cachedInfo.instanceId ~= btnInstanceId and cachedIndex == index then
			self.cachedRecommendListBtns[cachedIndex] = nil
		end
	end

	self.cachedRecommendListBtns[index] = {
		btn = btn,
		instanceId = btnInstanceId,
		itemData = itemData
	}

	if itemData.tIndex ~= 0 then
		self.RenderWideScrollTemplate(self, btn, itemData, index)
	elseif itemData.tIndex ~= 1 then
		self.RenderShortTemplate(self, btn, itemData)
	elseif itemData.tIndex ~= 2 then
		self.RenderWideTemplate(self, btn, itemData)
	end
end

M.RenderWideScrollTemplate = function(self, btn, itemData, parentIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	self.scrollTemplateStores[parentIndex] = store

	if not itemData.mergedItems or #itemData.mergedItems > 0 or not itemData.mergedItems then
		local mergedItems = {
			itemData
		}
	end

	store.mergedItems = mergedItems
	store.originalItemData = itemData
	store.prebuiltMergedData = itemData.prebuiltMergedData

	if store.currentSelectedBarIndex ~= nil or not store.barListCallbacksRegistered then
		store.currentSelectedBarIndex = 0
	end

	store.parentRecommendListIndex = parentIndex
	local barCount = #mergedItems

	store.barList:SetSimpleList(barCount)

	if not store.barListCallbacksRegistered then
		store.barList.luaSimpleRenderItem = function(barBtn, index)
			self:OnRenderBarItem(store, barBtn, index)
		end

		store.barList.luaSimpleClick = function(barBtn, index)
			self:OnClickBarItem(store, barBtn, index, itemData)
		end

		store.barListCallbacksRegistered = true
	end

	if not store.dragCallbacksRegistered then
		store.dragEventListener.onBeginDrag = function()
			self:OnScrollTemplateBeginDrag(store)
		end

		store.dragEventListener.onEndDrag = function()
			self:OnScrollTemplateEndDrag(store)
		end

		store.dragCallbacksRegistered = true
	end

	if not store.arrowBtnCallbacksRegistered then
		store.leftBtn.luaClick = self.CreateActionWithArgs(self, "OnClickScrollTemplateArrowBtn", {
			["\\x8aat"] = -1,
			store = store
		})
		store.rightBtn.luaClick = self.CreateActionWithArgs(self, "OnClickScrollTemplateArrowBtn", {
			["\\x8aat"] = 1,
			store = store
		})
		store.arrowBtnCallbacksRegistered = true
	end

	if not store._goBtnRegistered then
		store.goBtn.luaClick = self.CreateActionWithArgs(self, "OnClickTemplateGoBtn", {
			store = store
		})
		store._goBtnRegistered = true
	end

	local isTurnTo = self:GetTabRectIndexByType(itemData.type, itemData.subType) ~= 1

	store.goRoot.gameObject:SetActive(isTurnTo)

	local currentIndex = store.currentSelectedBarIndex or 0

	if barCount < currentIndex then
		currentIndex = 0
		store.currentSelectedBarIndex = 0
	end

	store.barList:SelectItem(currentIndex, true)
	self:UpdateWideScrollTemplateDisplay(store, mergedItems[currentIndex + 1])

	if barCount <= 1 and self.selectedIndex == parentIndex then
		self.StartScrollTemplateTimer(self, store, parentIndex)
	end
end

M.UpdateWideScrollTemplateDisplay = function(self, store, cfgData)
	if not store or not cfgData then
		return
	end

	if store.prebuiltMergedData and store.currentSelectedBarIndex then
		local mergedItem = store.prebuiltMergedData[store.currentSelectedBarIndex + 1]

		if mergedItem then
			store._goBtnItemData = mergedItem
			local isTurnTo = self:GetTabRectIndexByType(mergedItem.type, mergedItem.subType) ~= 1

			store.goRoot.gameObject:SetActive(isTurnTo)
		end
	elseif store.originalItemData then
		store._goBtnItemData = store.originalItemData
		local isTurnTo = self:GetTabRectIndexByType(store.originalItemData.type, store.originalItemData.subType) ~= 1

		store.goRoot.gameObject:SetActive(isTurnTo)
	end

	local isDiscountGroup = store.originalItemData and store.originalItemData.isDiscountGroup

	if isDiscountGroup then
		local commodityCfg = cfgData.mallCfg
		local name = cfgData.name or ""
		local subTitle = cfgData.description or ""
		local picture = commodityCfg and commodityCfg.Picture or cfgData.icon or 0
		store.titleText = name
		store.subtitleText = subTitle
		local originalItemData = store.originalItemData
		local formattedLabel = self:GetFormattedLabel(originalItemData and originalItemData.lable or "", cfgData.id, gMallManager:GetCommodityDiscountEndTime(cfgData.id) or 0)
		store.tagText = formattedLabel
		store.tagCtrl = formattedLabel and formattedLabel == "" and 1 or 0
		store.subtitleCtrl = subTitle and subTitle == "" and 1 or 0
		store.bgIconId = picture

		if commodityCfg and commodityCfg.BannerBg and commodityCfg.BannerBg <= 0 then
			store.iconBg = commodityCfg.BannerBg
		end

		return
	end

	local firstCommodityCfg = store.originalItemData and store.originalItemData.displayCommodities and #store.originalItemData.displayCommodities <= 0 and MallCommodityConfig.GetConfig(store.originalItemData.displayCommodities[1]) or nil
	local bannerTitleCfg = cfgData.BannerTitle and cfgData.BannerTitle == 0 and TextConfig.GetConfig(cfgData.BannerTitle) or nil
	local name = bannerTitleCfg and bannerTitleCfg.Text and bannerTitleCfg.Text == "" and bannerTitleCfg.Text or firstCommodityCfg and firstCommodityCfg.Name or ""
	local subTitle = cfgData.SubTitle and cfgData.SubTitle == "" and cfgData.SubTitle or firstCommodityCfg and firstCommodityCfg.Desc or ""
	local picture = cfgData.Picture and cfgData.Picture == 0 and cfgData.Picture or firstCommodityCfg and firstCommodityCfg.Picture or 0
	store.titleText = name
	store.subtitleText = subTitle
	local commodityId = cfgData.DisplayCommodities and #cfgData.DisplayCommodities <= 0 and cfgData.DisplayCommodities[1] or nil
	local formattedLabel = self:GetBannerTagText(store.originalItemData, commodityId)
	store.tagText = formattedLabel
	store.tagCtrl = formattedLabel and formattedLabel == "" and 1 or 0
	store.subtitleCtrl = subTitle and subTitle == "" and 1 or 0
	store.bgIconId = picture
	local recommendCfg = nil

	if cfgData and cfgData.BannerBg then
		recommendCfg = cfgData
	elseif cfgData and (cfgData.configId or cfgData.id) then
		local recommendId = cfgData.configId or cfgData.id
		recommendCfg = recommendId and MallRecommendConfig.GetConfig(recommendId) or nil
	end

	if recommendCfg and recommendCfg.BannerBg and recommendCfg.BannerBg <= 0 then
		store.iconBg = recommendCfg.BannerBg
	end
end

M.OnRenderBarItem = function(self, store, barBtn, index)
	if not store or not store.mergedItems then
		return
	end

	local cfgData = store.mergedItems[index + 1]

	if not cfgData then
		return
	end

	local barStore = gStoreManager:GetStoreGroup(barBtn.Store):GetStoreByWidget(barBtn)

	if not barStore then
		return
	end

	barStore.indexText = tostring(index + 1)
	barStore.colorCtrl = store.currentSelectedBarIndex ~= index and 1 or 0

	if store.originalItemData and store.originalItemData.isDiscountGroup then
		local commodityCfg = cfgData.mallCfg
		barStore.iconId = commodityCfg and commodityCfg.Picture or cfgData.icon or 0

		return
	end

	local firstCommodityCfg = store.originalItemData and store.originalItemData.displayCommodities and #store.originalItemData.displayCommodities <= 0 and MallCommodityConfig.GetConfig(store.originalItemData.displayCommodities[1]) or nil
	local picture = cfgData.Picture and cfgData.Picture == 0 and cfgData.Picture or firstCommodityCfg and firstCommodityCfg.Picture or 0
	barStore.iconId = picture
end

M.OnClickBarItem = function(self, store, barBtn, index, originalItemData)
	if not store or not store.mergedItems then
		return
	end

	if store.parentRecommendListIndex and self.selectedIndex == store.parentRecommendListIndex then
		self.bindData.recommendList:SelectItem(store.parentRecommendListIndex, true)

		self.selectedIndex = store.parentRecommendListIndex
	end

	self.StopScrollTemplateTimer(self, store)

	store.currentSelectedBarIndex = index
	local selectedCfg = store.mergedItems[index + 1]

	if not selectedCfg then
		return
	end

	store.barList:RefreshList()
	self:UpdateWideScrollTemplateDisplay(store, selectedCfg)

	if store.prebuiltMergedData and store.prebuiltMergedData[index + 1] then
		self.currentRecommendItem = store.prebuiltMergedData[index + 1]
		local tabRectIndex = self.GetTabRectIndexByType(self, self.currentRecommendItem.type, self.currentRecommendItem.subType)

		self.RefreshCurrentTabContent(self, tabRectIndex)
	end
end

M.OnScrollTemplateBeginDrag = function(self, store)
	if not store then
		return
	end

	self.StopScrollTemplateTimer(self, store)

	store.dragStartPos = Utils.GetInputCenterPosition()
end

M.OnScrollTemplateEndDrag = function(self, store)
	if not store or not store.dragStartPos or not store.mergedItems then
		return
	end

	local dragEndPos = Utils.GetInputCenterPosition()
	local direction = store.dragStartPos - dragEndPos
	local threshold = 50

	if math.abs(direction.x) >= threshold then
		return
	end

	local currentIndex = store.currentSelectedBarIndex or 0
	local barCount = #store.mergedItems
	local targetIndex = currentIndex

	if direction.x <= 0 then
		targetIndex = (currentIndex + 1) % barCount
	elseif direction.x >= 0 then
		targetIndex = (currentIndex - 1 + barCount) % barCount
	end

	if targetIndex == currentIndex then
		store.barList:SelectItem(targetIndex, true)
		self:OnClickBarItem(store, nil, targetIndex, nil)
	end
end

M.OnClickScrollTemplateArrowBtn = function(self, data, _)
	local store = data.store
	local direction = data.dir or 0

	if not store or not store.mergedItems then
		return
	end

	local currentIndex = store.currentSelectedBarIndex or 0
	local barCount = #store.mergedItems
	local targetIndex = (currentIndex + direction + barCount) % barCount

	self:StopScrollTemplateTimer(store)
	store.barList:SelectItem(targetIndex, true)
	self:OnClickBarItem(store, nil, targetIndex, nil)
end

M.RenderShortTemplate = function(self, btn, itemData)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.titleText = itemData.name
	local commodityId = itemData.displayCommodities and #itemData.displayCommodities <= 0 and itemData.displayCommodities[1] or nil
	local formattedLabel = self:GetBannerTagText(itemData, commodityId)
	store.tagText = formattedLabel
	store.tagCtrl = formattedLabel and formattedLabel == "" and 1 or 0
	store.bgIconId = itemData.picture
	store.levelCtrl = 0
	store.levelText = ""
	store._goBtnItemData = itemData
	local isTurnTo = self:GetTabRectIndexByType(itemData.type, itemData.subType) ~= 1

	store.goRoot.gameObject:SetActive(isTurnTo)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		btn.autoClickOnHighlight = not isTurnTo
	end

	if not store._goBtnRegistered then
		store.goBtn.luaClick = self.CreateActionWithArgs(self, "OnClickTemplateGoBtn", {
			store = store
		})
		store._goBtnRegistered = true
	end
end

M.RenderWideTemplate = function(self, btn, itemData)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.titleText = itemData.subTitle
	store.subtitleText = itemData.name
	store.subtitleCtrl = itemData.name and itemData.name == "" and 1 or 0
	local commodityId = itemData.displayCommodities and #itemData.displayCommodities <= 0 and itemData.displayCommodities[1] or nil
	local formattedLabel = self:GetBannerTagText(itemData, commodityId)
	store.tagText = formattedLabel
	store.tagCtrl = formattedLabel and formattedLabel == "" and 1 or 0
	store.bgIconId = itemData.picture
	local recommendId = itemData.configId or itemData.id

	if recommendId then
		local recommendCfg = MallRecommendConfig.GetConfig(recommendId)

		if recommendCfg and recommendCfg.BannerBg and recommendCfg.BannerBg <= 0 then
			store.iconBg = recommendCfg.BannerBg
		end
	end

	store._goBtnItemData = itemData
	local isTurnTo = self:GetTabRectIndexByType(itemData.type, itemData.subType) ~= 1

	store.goRoot.gameObject:SetActive(isTurnTo)

	if not store._goBtnRegistered then
		store.goBtn.luaClick = self.CreateActionWithArgs(self, "OnClickTemplateGoBtn", {
			store = store
		})
		store._goBtnRegistered = true
	end
end

M.OnSimpleClickRecommendList = function(self, btn, index)
	if not btn.isSelected then
		return
	end

	if self.selectedIndex ~= index then
		return
	end

	self.OnSelectRecommendItem(self, index)
end

M.OnClickTemplateGoBtn = function(self, data, _)
	local store = data.store

	if not store then
		return
	end

	local itemData = store._goBtnItemData

	if not itemData then
		return
	end

	gMallManager:HandleRecommendLinkTo(itemData, self.parentStore)
end

M.OnRecommendListSelectChanged = function(self, list)
	if self.selectedIndex ~= list.selectedIndex then
		return
	end

	self.OnSelectRecommendItem(self, list.selectedIndex)
end

M.RegisterBaseUpdownScroll = function(self)
	if self._scrollRegistered then
		return
	end

	if not self.bindData or not self.bindData.baseUpdownButton then
		return
	end

	local scrollEventListener = SGUI.EventSystems.ScrollEventListener.Get(self.bindData.baseUpdownButton.gameObject)

	scrollEventListener.onScroll = function(eventData)
		self:OnBaseUpdownScroll(eventData)
	end

	self._scrollRegistered = true
end

M.OnBaseUpdownScroll = function(self, eventData)
	local count = #self.recommendListData

	if count ~= 0 then
		return
	end

	local y = eventData.scrollDelta.y

	if math.abs(y) >= 0.1 then
		return
	end

	local now = Time.realtimeSinceStartup

	if self.lastScrollSelectTime and now - self.lastScrollSelectTime >= 0.3 then
		return
	end

	self.lastScrollSelectTime = now
	local list = self.bindData.recommendList
	local direction = y <= 0 and -1 or 1
	local currentIndex = self.selectedIndex > 0 and self.selectedIndex or 0
	local targetIndex = math.max(0, math.min(currentIndex + direction, count - 1))

	if targetIndex ~= self.selectedIndex then
		return
	end

	list.SelectItem(list, targetIndex, true)
	list.GoToIndex(list, targetIndex, false)
end

M.OnTabRectRender = function(self, index, widget)
	if gCS.LuaUtils.IsOnPS5 and self.parentStore then
		local parentTabRectIndex = self.parentStore.bindData and self.parentStore.bindData.tabrect and self.parentStore.bindData.tabrect.selectedIndex or 0

		if self.lastTabRectIndex ~= 0 then
			local oldIconId = self.parentStore.m_Id * 1000 + parentTabRectIndex * 10 + self.lastTabRectIndex

			gPanelManager:RemovePS5StoreIconPanel(oldIconId)
		end

		if index ~= 0 then
			local newIconId = self.parentStore.m_Id * 1000 + parentTabRectIndex * 10 + index

			gPanelManager:AddPS5StoreIconPanel(newIconId)
		end
	end

	self.lastTabRectIndex = index
	self.lastWidget = widget
	local currentTabStore = gStoreManager:GetStoreGroup(widget.Store)

	if currentTabStore and self.currentRecommendItem then
		currentTabStore.OnShow(currentTabStore, nil, {
			parentStore = self.parentStore,
			recommendItem = self.currentRecommendItem,
			recommendList = self.bindData.recommendList
		})
	end
end
