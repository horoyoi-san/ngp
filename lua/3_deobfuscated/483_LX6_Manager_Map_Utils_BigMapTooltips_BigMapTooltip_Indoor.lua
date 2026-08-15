local GamePlayConfig = LTConfig.IndoorGameplayListConfig
C_BigMapTooltip_Indoor = DefClass("C_BigMapTooltip_Indoor", C_BigMapTooltip_Indoor, C_BigMapTooltipBase)
local M = C_BigMapTooltip_Indoor
local NO_COUNT = 1

function M:SetUpInfo()
	if not self:ValidateTooltipInfo("indoorInfo") then
		return
	end

	self:GetStore("MapIndoorTooltipStore")
	self:InitCompareFunc()

	local scrollStore = gStoreManager:GetStoreGroup("MapIndoorScrollStore"):GetStoreByWidget(self.store.indoorScroll.content)

	self.store.indoorScroll:GoToPos(Vector2.zero, true)

	local info = self.tooltipInfo.indoorInfo

	self:SetUpHeader()
	self:SetUpLocation()
	self:SetUpFaction(info)
	self:SetUpScroll(scrollStore, info)
end

function M:InitCompareFunc()
	if not self.CommodityCmp then
		function self.CommodityCmp(a, b)
			if a.displayWeight ~= b.displayWeight then
				return b.displayWeight < a.displayWeight
			end

			if a.quality ~= b.quality then
				return b.quality < a.quality
			end

			return a.sortOrder < b.sortOrder
		end
	end
end

local HAVE_FACTION = 0
local NO_FACTION = 1

function M:SetUpFaction(info)
	local factionId = info.factionId

	if factionId then
		self.store.haveFaction = HAVE_FACTION
		local factionCfg = LTConfig.FactionConfig.GetConfig(factionId)
		local factionInfo = gClientUtils.GetFactionInfo(factionId)
		self.store.factionName = factionCfg.name
		self.store.factionAttitude = factionInfo.DispositionLevel - 1
	else
		self.store.haveFaction = NO_FACTION
	end
end

local GAMEPLAY_LIST_TYPE = 0
local SALE_LIST_TYPE = 1
local NO_LIST = 2
local COMMON_SALES_TYPE = 0
local ALL_SUIT_SALES_TYPE = 1
local DROP_TINDEX = 0

function M:SetUpScroll(scrollStore, info)
	scrollStore.clickShowRewards = nil
	self.cachedSaleData = nil

	if info.indoorType == 0 then
		local indoorCfg = LTConfig.IndoorConfig.GetConfig(info.id)
		scrollStore.desc = indoorCfg.Information or ""

		if indoorCfg.ShopId == 0 then
			local gameplayList = indoorCfg.GameplayList
			local starList = indoorCfg.Score

			if #starList ~= #gameplayList * 2 then
				print_error("@chenhongyu04 Indoor表格Id" .. info.indoorId .. "数据错误, starList数量不等于gameplayList*2")

				return
			end

			self:SetupGameplayList(scrollStore, gameplayList, starList)
		else
			scrollStore.clickShowRewards = self.bigMap:CreateAction("OnClickShowShop", self)
			scrollStore.type = NO_LIST

			scrollStore.saleList:SetSimpleList(0)
			gShopManager:GetShopCommodityInfoMap(indoorCfg.ShopId, self:CreateActionWithArgs("OnGetShopCommodityInfo", scrollStore))
		end
	else
		local indoorCfg = LTConfig.IndoorMapFunctionPointConfig.GetConfig(info.id)
		scrollStore.desc = indoorCfg.Information or ""

		if indoorCfg.ShopId == 0 then
			local gameplayList = indoorCfg.GameplayList
			local starList = indoorCfg.Score

			if #starList ~= #gameplayList * 2 then
				print_error("@chenhongyu04 IndoorMapFunction表格Id" .. info.indoorId .. "数据错误, starList数量不等于gameplayList*2")

				return
			end

			self:SetupGameplayList(scrollStore, gameplayList, starList)
		else
			scrollStore.clickShowRewards = self.bigMap:CreateAction("OnClickShowShop", self)
			scrollStore.type = NO_LIST

			scrollStore.saleList:SetSimpleList(0)
			gShopManager:GetShopCommodityInfoMap(indoorCfg.ShopId, self:CreateActionWithArgs("OnGetShopCommodityInfo", scrollStore))
		end
	end
end

function M:OnGetShopCommodityInfo(scrollStore, success, groupList, groupDict, otherShopInfo)
	if not self.container:CheckTooltipHandlerActive(self) then
		return
	end

	if not success then
		scrollStore.type = NO_LIST

		scrollStore.saleList:SetSimpleList(0)

		return
	end

	local commodityList = {}

	for _, group in pairs(groupList) do
		for _, commodityItem in ipairs(group) do
			table.insert(commodityList, commodityItem)
		end
	end

	if #commodityList == 0 then
		scrollStore.type = NO_LIST

		scrollStore.saleList:SetSimpleList(0)

		return
	end

	gShopManager:SortCommodityListByWeight(commodityList)

	local commonItems = {}
	local allSuit = #commodityList > 0

	for _, commodityItem in ipairs(commodityList) do
		local data = {
			interactable = true,
			tIndex = DROP_TINDEX,
			iconId = commodityItem.IconId,
			quality = commodityItem.Quality,
			displayWeight = commodityItem.DisplayWeight,
			sortOrder = #commonItems,
			itemId = commodityItem.Cfg and commodityItem.Cfg.Id,
			countCtl = NO_COUNT,
			subType = commodityItem.Type
		}

		if commodityItem.Type ~= LTConfig.ShopCommodityConfig.TypeType.FashionSuit then
			allSuit = false
		end

		table.insert(commonItems, data)
	end

	if allSuit then
		scrollStore.salesType = ALL_SUIT_SALES_TYPE
	else
		scrollStore.salesType = COMMON_SALES_TYPE
	end

	scrollStore.type = SALE_LIST_TYPE

	function scrollStore.saleList.luaSimpleRenderItem(btn, index)
		gCommonItemManager:OnCommonItemRender(btn, index, commonItems[index + 1])
	end

	scrollStore.saleList:SetSimpleList(#commonItems)
end

function M:SetupGameplayList(scrollStore, gameplayList, starList)
	local hasContent = false
	self.gameplayList = {}

	for i = 1, #gameplayList do
		table.insert(self.gameplayList, {
			gameplay = gameplayList[i],
			star = starList[i * 2 - 1],
			commentCnt = starList[i * 2]
		})

		hasContent = true
	end

	if not hasContent then
		scrollStore.type = NO_LIST
	else
		scrollStore.type = GAMEPLAY_LIST_TYPE

		function scrollStore.gameplayList.luaSimpleRenderItem(btn, index)
			self:OnRenderGameplayItem(btn, index)
		end

		scrollStore.gameplayList:SetSimpleList(#self.gameplayList)
	end
end

function M:OnRenderGameplayItem(btn, index)
	local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(btn)
	local data = self.gameplayList[index + 1]
	local cfg = GamePlayConfig.GetConfig(data.gameplay)

	if cfg then
		store.imageId = cfg.GameplayPic
		store.name = cfg.GameplayName

		if cfg.AddUrbanAbility and #cfg.AddUrbanAbility > 0 then
			store.type = 1

			self:SetUpAbilityList(store.abilityList, cfg.AddUrbanAbility)
		else
			store.type = 0
			store.starFill = data.star / 5
			store.starCount = string.format("%.1f", data.star)
			store.commentCount = data.commentCnt
		end
	end
end

function M:GetShopDataList(shopId)
	local shopCfg = LTConfig.ShopConfig.GetConfig(shopId)

	if not shopCfg then
		return nil
	end

	local dataList = {}

	for _, groupId in ipairs(shopCfg.CommodityGroupIdList) do
		local groupCfg = LTConfig.ShopCommodityGroupConfig.GetConfig(groupId)

		if groupCfg then
			for _, commodityId in ipairs(groupCfg.CommodityIDList) do
				local commodityCfg = LTConfig.ShopCommodityConfig.GetConfig(commodityId)

				if not commodityCfg then
					-- Nothing
				else
					local consumableCfg = LTConfig.ConsumableConfig.GetConfig(commodityCfg.ConsumableID)

					if consumableCfg then
						local data = {
							tIndex = DROP_TINDEX,
							iconId = consumableCfg.SItemIconId,
							quality = consumableCfg.Quality,
							displayWeight = commodityCfg.DisplayWeight,
							sortOrder = #dataList,
							itemId = commodityCfg.ConsumableID,
							countCtl = NO_COUNT
						}

						table.insert(dataList, data)
					end
				end
			end
		end
	end

	table.sort(dataList, self.CommodityCmp)

	if dataList and #dataList > 0 and dataList[1].tIndex == DROP_TINDEX then
		for i = 1, #dataList do
			dataList[i] = gCommonItemManager:GetItemRenderData(dataList[i])
		end
	end

	return dataList
end

function M:OnClickShowShop()
	gCommonItemManager:OnShowItemList(self.cachedSaleData, 0)
end
