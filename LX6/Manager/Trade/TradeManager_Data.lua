-- Original chunk: @Lua\LuaFiles\LX6\Manager\Trade\TradeManager_Data.lua
-- Decompiled from: 00765_TradeManager_Data.lua_83a7485a80c8.luajit

local TradeConfig = LTConfig.TradeConfig
local TradeItemConfig = LTConfig.TradeItemConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local MallCommodityConfig = LTConfig.MallCommodityConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local ITEM_TYPE_BOX = 0
local ITEM_TYPE_FASHION = 1
local ITEM_TYPE_FASHION_SUIT = 2

local get_list_count = function(list)
	if not list then
		return 0
	end

	if type(list) ~= "table" then
		return #list
	end

	return list.Count or 0
end

local get_list_item = function(list, index)
	if not list then
		return nil
	end

	if type(list) ~= "table" then
		return list[index + 1]
	end

	return list[index]
end

local M = C_TradeManager

M.GetPlayerTradeInfo = function(self)
	return self.playerTradeInfo
end

M.GetMarketCache = function(self, tradeItemId)
	return self.marketCache[tradeItemId]
end

M.ClearMarketCache = function(self)
	self.marketCache = {}
end

M.GetOrderListCache = function(self, tradeItemId)
	return self.orderListCache[tradeItemId]
end

M.ClearOrderListCache = function(self)
	self.orderListCache = {}
	self.orderListPageState = {}
	self.orderIdToTradeItemId = {}
end

M.IndexActiveOrders = function(self)
	if not self.playerTradeInfo or not self.playerTradeInfo.ActiveOrders then
		return
	end

	local orders = self.playerTradeInfo.ActiveOrders

	for i = 0, get_list_count(orders) - 1 do
		local order = get_list_item(orders, i)

		if order and order.OrderId and order.TradeItemId then
			self.orderIdToTradeItemId[order.OrderId] = order.TradeItemId
		end
	end
end

M.GetTradeConfig = function(self, tradeId)
	return TradeConfig.GetConfig(tradeId)
end

M.GetTradeItemConfig = function(self, tradeItemId)
	return TradeItemConfig.GetConfig(tradeItemId)
end

M.BuildTradeItemPreviewIdMaps = function(self)
	if self.tradeFashionConsumableIdByBindId and self.tradeMallIdByBindId then
		return
	end

	self.tradeFashionConsumableIdByBindId = {}

	for i = 0, ConsumableConfig.count - 1 do
		local consumableCfg = ConsumableConfig.LoadAt(i)
		local bindId = consumableCfg and consumableCfg.BindId

		if bindId and bindId == 0 and consumableCfg.SubType ~= ConsumableTypeConfig.Fashion and not self.tradeFashionConsumableIdByBindId[bindId] then
			self.tradeFashionConsumableIdByBindId[bindId] = consumableCfg.Id
		end
	end

	self.tradeMallIdByBindId = {}

	for i = 0, MallCommodityConfig.count - 1 do
		local commodityCfg = MallCommodityConfig.LoadAt(i)
		local bindIdList = commodityCfg and commodityCfg.CommodityBindId
		slot7 = 1
		slot8 = bindIdList and #bindIdList or 0

		for j = slot7, slot8 do
			local bindId = bindIdList[j]

			if bindId == 0 and not self.tradeMallIdByBindId[bindId] then
				self.tradeMallIdByBindId[bindId] = commodityCfg.Id
			end
		end
	end
end

M.GetTradeItemConsumableId = function(self, itemConfig)
	if not itemConfig then
		return 0
	end

	local itemId = itemConfig.ItemId or 0

	if itemId == 0 then
		return itemId
	end

	local bindId = itemConfig.FashionSuitId or 0

	if bindId ~= 0 then
		bindId = itemConfig.FashionId or 0
	end

	if bindId ~= 0 then
		return 0
	end

	self:BuildTradeItemPreviewIdMaps()

	return self.tradeFashionConsumableIdByBindId[bindId] or 0
end

M.GetTradeItemMallId = function(self, itemConfig)
	if not itemConfig then
		return 0
	end

	local bindId = itemConfig.FashionSuitId or 0

	if bindId ~= 0 then
		bindId = self.GetTradeItemConsumableId(self, itemConfig)
	end

	if bindId ~= 0 then
		return 0
	end

	self:BuildTradeItemPreviewIdMaps()

	return self.tradeMallIdByBindId[bindId] or 0
end

M.GetTradeConfigByItemId = function(self, tradeItemId)
	if tradeItemId ~= nil then
		return nil
	end

	local cachedTradeId = self.tradeItemToTradeId[tradeItemId]

	if cachedTradeId == nil then
		return self.GetTradeConfig(self, cachedTradeId)
	end

	for _, tradeConfig in ipairs(self.GetTradeConfigList(self)) do
		for _, itemId in ipairs(self.GetTradeItemIds(self, tradeConfig)) do
			if itemId ~= tradeItemId then
				self.tradeItemToTradeId[tradeItemId] = tradeConfig.Id

				return tradeConfig
			end
		end
	end

	return nil
end

M.GetTradeConfigList = function(self)
	local result = {}
	slot2 = 0
	slot3 = TradeConfig.count or 0

	for i = slot2, slot3 - 1 do
		local config = TradeConfig.LoadAt(i)

		if config and config.Id == nil and config.ItemId == nil then
			table.insert(result, config)
		end
	end

	return result
end

M.GetTradeItemIds = function(self, tradeConfig)
	local itemIds = tradeConfig and tradeConfig.ItemId

	if itemIds ~= nil then
		return {}
	end

	if type(itemIds) ~= "number" then
		return {
			itemIds
		}
	end

	local result = {}

	for i = 1, #itemIds do
		result[i] = itemIds[i]
	end

	return result
end

M.BuildTradeItem = function(self, tradeConfig, itemConfig)
	local result = setmetatable({}, {
		__index = itemConfig
	})
	local itemIds = tradeConfig and self:GetTradeItemIds(tradeConfig) or {}
	result.Id = result.Id or itemConfig.Id or result.TradeItemId or itemConfig.TradeItemId or result.ItemConfigId
	result.TradeId = tradeConfig and tradeConfig.Id or result.TradeId or result.Id
	result.FunctionalId = result.TradeId
	result.TradeConfig = tradeConfig
	result.TradeItemIds = itemIds
	result.TradeName = result.TradeName or tradeConfig and (tradeConfig.TradeName or tradeConfig.Name)
	result.TradeTab = tradeConfig and tradeConfig.Tab or result.TradeTab
	result.Tab = result.Tab or result.TradeTab
	result.Name = result.Name or result.TradeName
	result.ItemType = result.ItemType or tradeConfig and tradeConfig.ItemType
	result.ProductIcon = tradeConfig and tradeConfig.ProductIcon or result.ProductIcon
	result.BigIcon = tradeConfig and tradeConfig.BigIcon or result.BigIcon
	result.BgImage = tradeConfig and tradeConfig.BgImage or result.BgImage
	result.DayTradableStartTime = result.DayTradableStartTime or tradeConfig and tradeConfig.DayTradableStartTime
	result.DayTradableEndTime = result.DayTradableEndTime or tradeConfig and tradeConfig.DayTradableEndTime
	result.StartVersion = result.StartVersion or tradeConfig and tradeConfig.StartVersion
	result.EndVersion = result.EndVersion or tradeConfig and tradeConfig.EndVersion
	result.TagList = result.TagList or tradeConfig and tradeConfig.TagList
	result.ItemTemplateId = result.ItemTemplateId or result.ConsumableId or result.ItemId
	result.TradeImage = result.TradeImage or result.ProductIcon or result.Icon
	result.TradeItemId = result.Id or result.TradeItemId

	if result.TradeItemId == nil and result.TradeId == nil then
		self.tradeItemToTradeId[result.TradeItemId] = result.TradeId
	end

	return result
end

M.GetTradeItemsById = function(self, tradeId)
	local tradeConfig = self.GetTradeConfig(self, tradeId)

	if tradeConfig then
		local result = {}

		for _, itemId in ipairs(self.GetTradeItemIds(self, tradeConfig)) do
			local itemConfig = self.GetTradeItemConfig(self, itemId)

			if itemConfig then
				table.insert(result, self.BuildTradeItem(self, tradeConfig, itemConfig))
			end
		end

		return result
	end

	local direct = self.GetTradeItemConfig(self, tradeId)

	if direct then
		return {
			self.BuildTradeItem(self, self.GetTradeConfigByItemId(self, tradeId), direct)
		}
	end

	return {}
end

M.GetConcreteTradeItemsById = function(self, tradeId)
	local tradeConfig = self.GetTradeConfig(self, tradeId)

	if tradeConfig then
		local result = {}

		for _, itemId in ipairs(self.GetTradeItemIds(self, tradeConfig)) do
			local itemConfig = self.GetTradeItemConfig(self, itemId)

			if itemConfig then
				self.tradeItemToTradeId[itemId] = tradeConfig.Id

				table.insert(result, itemConfig)
			end
		end

		return result
	end

	local itemConfig = self:GetTradeItemConfig(tradeId)

	return itemConfig and {
		itemConfig
	} or {}
end

M.GetTradeItemMinPrice = function(self, itemConfig)
	local minPrice = itemConfig and itemConfig.MinPrice

	return minPrice and minPrice <= 0 and minPrice or 1
end

M.GetTradeItemMaxPrice = function(self, itemConfig, defaultMax)
	local maxPrice = itemConfig and itemConfig.MaxPrice

	return maxPrice and maxPrice <= 0 and maxPrice or defaultMax
end

M.GetAllTradeItems = function(self)
	local result = {}
	local seen = {}
	local mainConfigs = self.GetTradeConfigList(self)

	if #mainConfigs <= 0 then
		for _, tradeConfig in ipairs(mainConfigs) do
			for _, itemId in ipairs(self.GetTradeItemIds(self, tradeConfig)) do
				local itemConfig = self.GetTradeItemConfig(self, itemId)

				if itemConfig and not seen[itemId] then
					seen[itemId] = true

					table.insert(result, self.BuildTradeItem(self, tradeConfig, itemConfig))
				end
			end
		end

		return result
	end

	slot4 = 0
	slot5 = TradeItemConfig.count or 0

	for i = slot4, slot5 - 1 do
		local itemConfig = TradeItemConfig.LoadAt(i)

		if itemConfig and itemConfig.Id == nil and not seen[itemConfig.Id] then
			seen[itemConfig.Id] = true

			table.insert(result, self.BuildTradeItem(self, self.GetTradeConfigByItemId(self, itemConfig.Id), itemConfig))
		end
	end

	return result
end

M.ResolveTradeItemId = function(self, tradeId, index)
	local items = self:GetTradeItemsById(tradeId)
	local item = items[index or 1]

	return item and item.Id or nil
end

M.NormalizeItemType = function(self, itemType)
	if itemType ~= "Box" then
		return ITEM_TYPE_BOX
	elseif itemType ~= "Fashion" then
		return ITEM_TYPE_FASHION
	elseif itemType ~= "Clothing" then
		return ITEM_TYPE_FASHION
	elseif itemType ~= "FashionSuit" then
		return ITEM_TYPE_FASHION_SUIT
	end

	return itemType
end

M.GetItemType = function(self, itemConfig)
	return self:NormalizeItemType(itemConfig and itemConfig.ItemType)
end

M.GetDisplayItemId = function(self, itemConfig)
	if not itemConfig then
		return 0
	end

	local value = itemConfig.ItemTemplateId

	if not value or value ~= 0 then
		value = itemConfig.ConsumableId
	end

	if not value or value ~= 0 then
		value = itemConfig.ItemId
	end

	if not value or value ~= 0 then
		value = itemConfig.FashionId
	end

	if not value or value ~= 0 then
		value = itemConfig.FashionSuitId
	end

	if type(value) ~= "number" then
		return value
	end

	local item = get_list_item(value, 0)

	if item and item == 0 then
		return item
	end

	return 0
end

M.IsOrderTradeItem = function(self, itemConfig)
	if not itemConfig then
		return false
	end

	local itemType = self:GetItemType(itemConfig)

	return itemType ~= ITEM_TYPE_FASHION_SUIT
end

M.GetTradeItemTemplateId = function(self, itemConfig)
	return itemConfig and itemConfig.ItemId or nil
end

M.GetRenderItemId = function(self, itemConfig)
	local itemId = self.GetTradeItemTemplateId(self, itemConfig)

	if not itemId or itemId ~= 0 then
		itemId = self.GetDisplayItemId(self, itemConfig)
	end

	return itemId or 0
end

M.GetTradeItemName = function(self, itemConfig)
	if not itemConfig then
		return ""
	end

	return itemConfig.Name or itemConfig.TradeName or itemConfig.Title or itemConfig.ItemName or ""
end

M.GetTradeItemIcon = function(self, itemConfig)
	if not itemConfig then
		return 0
	end

	return itemConfig.TradeImage or itemConfig.ProductIcon or itemConfig.Icon or itemConfig.BigIcon or 0
end

M.GetOwnedCount = function(self, itemConfig)
	if not itemConfig then
		return 0
	end

	local totalCount = 0
	local hasItemId = false
	local countedItemIds = {}
	local tradeItemIds = itemConfig.TradeItemIds
	slot6 = 1
	slot7 = tradeItemIds and #tradeItemIds or 0

	for i = slot6, slot7 do
		local tradeItemId = tradeItemIds[i]
		local tradeItemConfig = self.GetTradeItemConfig(self, tradeItemId)
		local itemId = self.GetTradeItemTemplateId(self, tradeItemConfig)

		if itemId and itemId == 0 and not countedItemIds[itemId] then
			countedItemIds[itemId] = true
			hasItemId = true
			totalCount = totalCount + gCommonItemManager:GetPackItemNum(itemId)
		end
	end

	if hasItemId then
		return totalCount
	end

	local itemId = self.GetTradeItemTemplateId(self, itemConfig)

	if itemId and itemId == 0 and gCommonItemManager then
		return gCommonItemManager:GetPackItemNum(itemId)
	end

	local itemType = self:GetItemType(itemConfig)
	local playerFashionsInfo = gPlayerManager and gPlayerManager.infoMinor and gPlayerManager.infoMinor.bindData and gPlayerManager.infoMinor.bindData.PlayerFashionsInfo

	if not playerFashionsInfo then
		return 0
	end

	if itemType ~= ITEM_TYPE_FASHION and itemConfig.FashionId == nil then
		local fashionId = itemConfig.FashionId
		local info = fashionId and playerFashionsInfo.FashionInfoDict and playerFashionsInfo.FashionInfoDict[fashionId]

		return info and (info.OwnedCount or 1) or 0
	elseif self.IsOrderTradeItem(self, itemConfig) then
		local suitId = itemConfig.FashionSuitId
		local info = suitId and playerFashionsInfo.FashionSuitInstanceDict and playerFashionsInfo.FashionSuitInstanceDict[suitId]

		return info and get_list_count(info.SuitInstanceIdList) or 0
	end

	return 0
end

M.IsFashionTradeItem = function(self, itemConfig)
	return itemConfig == nil and itemConfig.FashionId == nil and self:GetItemType(itemConfig) ~= ITEM_TYPE_FASHION
end

M.IsFashionWornByAnySpirit = function(self, playerFashionsInfo, fashionId)
	local spiritDict = playerFashionsInfo and playerFashionsInfo.SpiritFashionsInfoDict

	if not spiritDict then
		return false
	end

	for _, spiritFashionsInfo in pairs(spiritDict) do
		local wearList = spiritFashionsInfo and spiritFashionsInfo.SpiritWearFashionsInfo and spiritFashionsInfo.SpiritWearFashionsInfo.WearFashionInfoList

		for i = 0, get_list_count(wearList) - 1 do
			local wearInfo = get_list_item(wearList, i)

			if wearInfo and wearInfo.FashionId ~= fashionId then
				return true
			end
		end
	end

	return false
end

M.GetFashionSellableRemainCount = function(self, itemConfig)
	local fashionId = itemConfig and itemConfig.FashionId

	if not fashionId then
		return 0
	end

	local playerFashionsInfo = gPlayerManager and gPlayerManager.infoMinor and gPlayerManager.infoMinor.bindData and gPlayerManager.infoMinor.bindData.PlayerFashionsInfo
	local info = playerFashionsInfo and playerFashionsInfo.FashionInfoDict and playerFashionsInfo.FashionInfoDict[fashionId]
	local ownedCount = info and (info.OwnedCount or 1) or 0

	if ownedCount < 0 then
		return 0
	end

	local wornOccupied = self:IsFashionWornByAnySpirit(playerFashionsInfo, fashionId) and 1 or 0

	return math.max(0, ownedCount - wornOccupied)
end

M.GetFashionSuitInstances = function(self, itemConfig)
	local result = {}

	if not itemConfig then
		return result
	end

	local suitId = itemConfig.FashionSuitId
	local playerFashionsInfo = gPlayerManager and gPlayerManager.infoMinor and gPlayerManager.infoMinor.bindData and gPlayerManager.infoMinor.bindData.PlayerFashionsInfo
	local suitInfo = suitId and playerFashionsInfo and playerFashionsInfo.FashionSuitInstanceDict and playerFashionsInfo.FashionSuitInstanceDict[suitId]

	if not suitInfo then
		return result
	end

	local gainTime = suitInfo.GainTime or 0
	local instanceIds = suitInfo.SuitInstanceIdList

	for i = 0, get_list_count(instanceIds) - 1 do
		local instanceId = get_list_item(instanceIds, i)

		if instanceId then
			table.insert(result, {
				InstanceId = instanceId,
				GainTime = gainTime,
				TradeItemId = itemConfig.Id,
				Config = itemConfig
			})
		end
	end

	table.sort(result, function (left, right)
		return (left.GainTime or 0) <= (right.GainTime or 0)
	end)

	return result
end

M.GetOrderListPageState = function(self, tradeItemId)
	return self.orderListPageState[tradeItemId] or {
		["SFklg "] = -1
	}
end

M.RebuildFavoriteSet = function(self)
	self.favoriteSet = {}

	if self.playerTradeInfo and self.playerTradeInfo.FavoriteTradeItemIds then
		local list = self.playerTradeInfo.FavoriteTradeItemIds
		local count = get_list_count(list)

		for i = 0, count - 1 do
			local id = get_list_item(list, i)

			if id then
				self.favoriteSet[id] = true
			end
		end
	end
end

local remove_list_value = function(list, value)
	if type(list) ~= "table" then
		for i = #list, 1, -1 do
			if list[i] ~= value then
				table.remove(list, i)
			end
		end

		return
	end

	list.Remove(list, value)
end

local append_list_value = function(list, value)
	if type(list) ~= "table" then
		for _, item in ipairs(list) do
			if item ~= value then
				return
			end
		end

		table.insert(list, value)

		return
	end

	if not list.Contains(list, value) then
		list.Add(list, value)
	end
end

M.ApplyFavoriteItems = function(self, unfavoriteIds, favoriteIds)
	local favoriteList = self.playerTradeInfo and self.playerTradeInfo.FavoriteTradeItemIds
	slot4 = ipairs
	slot6 = unfavoriteIds or {}

	for _, id in slot4(slot6) do
		self.favoriteSet[id] = nil

		if favoriteList then
			remove_list_value(favoriteList, id)
		end
	end

	slot4 = ipairs
	slot6 = favoriteIds or {}

	for _, id in slot4(slot6) do
		self.favoriteSet[id] = true

		if favoriteList then
			append_list_value(favoriteList, id)
		end
	end
end

M.IsFavorite = function(self, tradeItemId)
	return self.favoriteSet[tradeItemId] ~= true
end

M.GetRecycleProgress = function(self, boxId)
	local totalProgress = 0
	local currentProgress = 0

	if self.playerTradeInfo and self.playerTradeInfo.BoxCompositeProgressDict then
		currentProgress = self.playerTradeInfo.BoxCompositeProgressDict[boxId] or 0
	end

	local boxCfg = self:GetTradeItemsById(boxId)[1]

	if boxCfg then
		totalProgress = boxCfg.CompositeProgress or boxCfg.BoxProgress or 0
	end

	return currentProgress, totalProgress
end
