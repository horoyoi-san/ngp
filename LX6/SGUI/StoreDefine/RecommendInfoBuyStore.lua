-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RecommendInfoBuyStore.lua
-- Decompiled from: 00900_RecommendInfoBuyStore.lua_ba2917309d3e.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local MallCommodityConfig = LTConfig.MallCommodityConfig
local MallRecommendConfig = LTConfig.MallRecommendConfig
local MallConfig = LTConfig.MallConfig
C_RecommendInfoBuyStore = DefClass("C_RecommendInfoBuyStore", C_RecommendInfoBuyStore, C_StoreGroup)
GroupName2Class.RecommendInfoBuyStore = C_RecommendInfoBuyStore
local M = C_RecommendInfoBuyStore

M.ctor = function(self)
	self.parentStore = nil
	self.recommendItem = nil
	self.currentCommodityData = nil
	self.shopTipInit = false
	self.tagList = {}
	self.shopTipStore = nil
end

M.DefineAllVariables = function(self)
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
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.shopTipInit = false
	self.shopTipStore = nil
	self.parentStore = data and data.parentStore or nil
	self.recommendItem = data and data.recommendItem or nil

	self:RefreshInfo()
end

M.OnLanguageChange = function(self, lang)
	self.RefreshInfo(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.RefreshInfo = function(self)
	if not self.recommendItem then
		return
	end

	local bgIconId = self.recommendItem.bigPicture

	if not bgIconId or bgIconId ~= 0 then
		bgIconId = self.recommendItem.picture or 0
	end

	self.bindData.bgIconId = bgIconId

	self:RefreshScene()

	if self.bindData.shopTip then
		local displayCommodities = self.recommendItem.displayCommodities

		if displayCommodities and #displayCommodities <= 0 then
			local commodityId = displayCommodities[1]
			local commodityData = self.GetCommodityData(self, commodityId)

			if commodityData then
				self.ShowCommodityDetail(self, commodityData)
			end
		end
	end
end

M.RefreshScene = function(self)
	if not self.recommendItem or not self.recommendItem.isDiscountGroup then
		return
	end

	local sceneId = gMallManager:GetRecommendSceneId(self.recommendItem)

	if not sceneId or sceneId > 0 or not self.parentStore then
		return
	end

	local commodityId = self.recommendItem.displayCommodities and self.recommendItem.displayCommodities[1] or 0
	local commodityData = commodityId <= 0 and gMallManager:GenMallCommodityItem(MallCommodityConfig.GetConfig(commodityId)) or nil

	if self.parentStore.TryOnFashion and commodityData then
		self.parentStore:TryOnFashion(commodityData)
	elseif self.parentStore.ApplyMallSceneById then
		self.parentStore:ApplyMallSceneById(sceneId)
		self.parentStore:SetModelBtnActive(false)
	end

	self.bindData.bgIconId = 0
end

M.GetCommodityData = function(self, commodityId)
	if not commodityId or commodityId ~= 0 then
		return nil
	end

	local commodityCfg = MallCommodityConfig.GetConfig(commodityId)

	if not commodityCfg then
		return nil
	end

	return gMallManager:GenMallCommodityItem(commodityCfg)
end

M.GetCommodityDescription = function(self, commodityData)
	if not commodityData then
		return ""
	end

	local recommendDesc = nil

	if self.recommendItem and self.recommendItem.configId then
		local recommendCfg = MallRecommendConfig.GetConfig(self.recommendItem.configId)
		recommendDesc = recommendCfg.Name
	end

	if not recommendDesc and self.recommendItem and self.recommendItem.desc and self.recommendItem.desc == "" then
		recommendDesc = self.recommendItem.desc
	end

	return gMallManager:GetCommodityDescription(commodityData, recommendDesc)
end

M.InitShopTip = function(self)
	if self.shopTipInit or not self.bindData.shopTip then
		return
	end

	if not self.shopTipStore then
		self.shopTipStore = gStoreManager:GetStoreGroup(self.bindData.shopTip.Store):GetStoreByWidget(self.bindData.shopTip)
	end

	if not self.shopTipStore then
		return
	end

	if self.shopTipStore.buyBtn then
		self.shopTipStore.buyBtn.luaClick = self.CreateAction(self, "OnClickBuyBtn")
	end

	if self.shopTipStore.tagList then
		self.shopTipStore.tagList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderTagListItem")
	end

	self.shopTipInit = true
end

M.ShowCommodityDetail = function(self, commodityData)
	if not commodityData then
		return
	end

	self.InitShopTip(self)

	self.currentCommodityData = commodityData

	if not self.shopTipStore then
		return
	end

	self.shopTipStore.goodsName = commodityData.name
	local moneyCfg = ConsumableConfig.GetConfig(commodityData.moneyItemId)
	self.shopTipStore.moneyIcon = moneyCfg and moneyCfg.SMoneyIconId or 0
	local discountPrice, originalPrice = gMallManager:GetCommodityDiscountInfo(commodityData.id)
	local actualPrice = commodityData.price

	if discountPrice and originalPrice and originalPrice <= 0 then
		self.shopTipStore.isDiscountCtrl = 0
		self.shopTipStore.originPrice = originalPrice
		actualPrice = discountPrice
	else
		self.shopTipStore.isDiscountCtrl = 1
	end

	self.shopTipStore.price = actualPrice
	local num = gCommonItemManager:GetPackItemNum(commodityData.moneyItemId)
	local isOwned = gMallManager:CheckMallCommodityOwned(commodityData)

	if isOwned then
		self.shopTipStore.moneyEnoughCtrl = 2
	else
		self.shopTipStore.moneyEnoughCtrl = num >= actualPrice and 1 or 0
	end

	if self.shopTipStore.detailScrollRect and self.shopTipStore.detailScrollRect.content then
		local description = self:GetCommodityDescription(commodityData)
		self.shopTipStore.detailScrollRect.content.text = description or ""
	end

	if self.shopTipStore.isOwnedCtrl == nil then
		self.shopTipStore.isOwnedCtrl = isOwned and 1 or 0
	end

	if self.shopTipStore.buyBtn then
		self.shopTipStore.buyBtn.interactable = gMallManager:IsCommodityBuyable(commodityData)
	end

	self.tagList = self.GetCommodityTagList(self, commodityData)

	if self.shopTipStore.tagList then
		self.shopTipStore.tagList:SetSimpleList(#self.tagList)
	end

	self.shopTipStore.showDetailCtrl = 1

	if self.shopTipStore.showDetailBtn then
		self.shopTipStore.showDetailBtn.interactable = false
	end
end

M.GetCommodityTagList = function(self, commodityData)
	if not commodityData then
		return {}
	end

	local tagList = {}
	local tagTitleSet = {}

	if commodityData.type ~= 0 and commodityData.bindId and commodityData.bindId <= 0 then
		local FashionSuitConfig = LTConfig.FashionSuitConfig
		local suitCfg = FashionSuitConfig.GetConfig(commodityData.bindId)

		if suitCfg and suitCfg.FashionIdList and #suitCfg.FashionIdList <= 0 then
			local firstFashionId = suitCfg.FashionIdList[1]
			local fashionTagList = gDressManager:GetTagList(firstFashionId)

			for _, tagData in ipairs(fashionTagList) do
				if not tagTitleSet[tagData.title] then
					tagTitleSet[tagData.title] = true

					table.insert(tagList, tagData)
				end
			end
		end
	end

	return tagList
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end

M.OnClickBuyBtn = function(self)
	if not self.currentCommodityData then
		gDisplayMessageMgr:ShowMessageContentDebug("temp请先选择商品")

		return
	end

	local commodityData = self.currentCommodityData

	if self.recommendItem and self.recommendItem.isDiscountGroup then
		self.JumpToSaleTab(self, commodityData)

		return
	end

	slot2 = gMallManager

	slot2:OpenDoubleConfirmInstant(commodityData, 1, function ()
		self:OnBuySuccess(commodityData)
	end)
end

M.JumpToSaleTab = function(self, commodityData)
	if not commodityData then
		return
	end

	local commodityCfg = commodityData.mallCfg or MallCommodityConfig.GetConfig(commodityData.id)
	local mallId = commodityCfg and commodityCfg.BelongMallId or 0

	if mallId ~= 0 then
		return
	end

	local mallCfg = MallConfig.GetConfig(mallId)

	if not mallCfg or not mallCfg.Tab then
		print_error("RecommendInfoBuyStore:JumpToSaleTab 取不到 MallConfig, mallId=", mallId)

		return
	end

	local targetMainTabId = mallCfg.Tab.Main
	local targetSubTabId = mallCfg.Tab.Second or 0

	if not targetMainTabId or targetMainTabId ~= 0 then
		return
	end

	if self.parentStore and self.parentStore.JumpToTab then
		self.parentStore.pendingSubTabId = targetSubTabId
		self.parentStore.pendingCommodityId = commodityData.id

		self.parentStore:JumpToTab(targetMainTabId, true)

		return
	end

	gPanelManager:CheckShow(gPanelId.SHOP_HOME_PAGE, {
		tabId = targetMainTabId,
		subTabId = targetSubTabId,
		commodityId = commodityData.id
	})
end

M.OnClickShowDetailBtn = function(self)
	if not self.bindData.shopTip then
		return
	end

	if not self.shopTipStore then
		self.shopTipStore = gStoreManager:GetStoreGroup(self.bindData.shopTip.Store):GetStoreByWidget(self.bindData.shopTip)
	end

	if not self.shopTipStore then
		return
	end

	if self.shopTipStore.showDetailCtrl == nil then
		self.shopTipStore.showDetailCtrl = 1 - (self.shopTipStore.showDetailCtrl or 0)
	end
end

M.OnSimpleRenderTagListItem = function(self, btn, index)
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

M.OnBuySuccess = function(self, commodityData)
	self.RefreshInfo(self)

	if commodityData and self.shopTipStore then
		local isOwned = gMallManager:CheckMallCommodityOwned(commodityData)

		if self.shopTipStore.buyBtn then
			self.shopTipStore.buyBtn.interactable = gMallManager:IsCommodityBuyable(commodityData)
		end

		if self.shopTipStore.isOwnedCtrl == nil then
			self.shopTipStore.isOwnedCtrl = isOwned and 1 or 0
		end
	end

	gMessageManager:SendMessage(gEventConstants.PACK_ITEM_CHANGED)
end
