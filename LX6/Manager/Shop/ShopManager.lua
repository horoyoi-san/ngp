-- Original chunk: @Lua\LuaFiles\LX6\Manager\Shop\ShopManager.lua
-- Decompiled from: 00524_ShopManager.lua_c2d3234a3d7b.luajit

local ShopCommodityCfg = LTConfig.ShopCommodityConfig
local ShopBrandConfig = LTConfig.ShopBrandConfig
local ShopConfig = LTConfig.ShopConfig
local NpcShopCommodityCfg = LTConfig.ShopCommodityConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local ShopCommodityGroupConfig = LTConfig.ShopCommodityGroupConfig
local MessageConfig = LTConfig.MessageConfig
local UXTime = LTUtils.UXTime
local bit = require("bit")
local ModuleShopCommodityShow = UX.Game.EventConditionImplModule.ShopCommodityShow
local CommodityTypeConfig = LTConfig.ShopCommodityTypeConfig
local FashionConfig = LTConfig.FashionConfig
local VehicleConfig = LTConfig.VehicleConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local NpcShopCommodityStatus = UX.Game.NpcShopCommodityStatus
local MallExchangeConfig = LTConfig.MallExchangeConfig
local ExternalSourceType = LX6.Audio.ExternalSourceType
local ExtractionShooterItemConfig = LTConfig.ExtractionShooterItemConfig
local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
C_ShopManager = DefClass("C_ShopManager", C_ShopManager)
local M = C_ShopManager

M.ctor = function(self)
	self.brandMap = {}

	self.CommodityCmp = function(a, b)
		if a.tIndex == b.tIndex then
			return b.tIndex <= a.tIndex
		end

		if a.SortWeight == b.SortWeight then
			return a.SortWeight <= b.SortWeight
		end

		if a.TypeOrder == b.TypeOrder then
			return b.TypeOrder <= a.TypeOrder
		end

		if a.DisplayWeight == b.DisplayWeight then
			return b.DisplayWeight <= a.DisplayWeight
		end

		if a.Quality == b.Quality then
			return a.Quality <= b.Quality
		end

		if a.PriceCurrent == b.PriceCurrent then
			return a.PriceCurrent <= b.PriceCurrent
		end

		if a.SubTypeOrder == b.SubTypeOrder then
			return a.SubTypeOrder <= b.SubTypeOrder
		end

		return a.IndexOrder <= b.IndexOrder
	end

	self.CommodityCmpByWeight = function(a, b)
		if a.DisplayWeight == b.DisplayWeight then
			return b.DisplayWeight <= a.DisplayWeight
		end

		return a.IndexOrder <= b.IndexOrder
	end

	self.commodityTypeMap = {}

	self:ClearRuntimeShopData()
end

M.ClearRuntimeShopData = function(self)
	self.shopCommodityDataDict = {}
	self.shopCurrentDiscount = {}
	self.shopFactionDiscount = {}
	self.shopBadgeDiscountDict = {}
	self.shopNextDiscount = {}
	self.shopBuybackDataDict = {}
	self.shopRefreshStateDict = {}
	self.shopGeneralBuyBackDiscount = {}
	self.shopGeneralBuyBackFactionDiscount = {}
	self.shopGeneralBuyBackBadgeDiscountDict = {}
	self.shopIdEnterId = {}
	self.shopPriceHistoryDict = {}
end

M.OnInit = function(self)
	self:BuildBrandMap()
	self:BuildCommodityTypeMap()
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self:ClearRuntimeShopData()
	end
end

M.BuildBrandMap = function(self)
	self.brandMap = {}

	for i = 0, ShopBrandConfig.count - 1 do
		local brand = ShopBrandConfig.LoadAt(i)

		if brand then
			self.brandMap[brand.Id] = {}
		end
	end

	for i = 0, ShopCommodityCfg.count - 1 do
		local commodity = ShopCommodityCfg.LoadAt(i)

		if commodity and commodity.BelongBrand and self.brandMap[commodity.BelongBrand] then
			table.insert(self.brandMap[commodity.BelongBrand], commodity.Id)
		end
	end
end

M.BuildCommodityTypeMap = function(self)
	for i = 0, CommodityTypeConfig.count - 1 do
		local cfg = CommodityTypeConfig.LoadAt(i)

		if cfg then
			self.commodityTypeMap[cfg.Id] = cfg
		end
	end
end

M.SyncCommodityInfos = function(self, shopId, infos, noMessage)
	local shopDataDict = self.shopCommodityDataDict[shopId]

	if not shopDataDict then
		shopDataDict = {}
		self.shopCommodityDataDict[shopId] = shopDataDict
	end

	for i = 1, infos.Length do
		local info = infos[i]
		shopDataDict[info.TemplateId] = info
	end

	if not noMessage then
		gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.NPCSHOP_COMMODITYINFO_CHANGE, shopId, infos)
	end
end

M.SyncShopDiscount = function(self, shopId, currentDiscount, factionDiscount, badgeDiscountDict)
	self.shopCurrentDiscount[shopId] = currentDiscount
	self.shopFactionDiscount[shopId] = factionDiscount
	self.shopBadgeDiscountDict[shopId] = badgeDiscountDict
end

M.SyncShopGeneralBuyBackDiscount = function(self, shopId, currentDiscount, factionDiscount, badgeDiscountDict)
	self.shopGeneralBuyBackDiscount[shopId] = currentDiscount
	self.shopGeneralBuyBackFactionDiscount[shopId] = factionDiscount
	self.shopGeneralBuyBackBadgeDiscountDict[shopId] = badgeDiscountDict
end

M.GetShopGeneralBuyBackDiscount = function(self, shopId)
	return self.shopGeneralBuyBackDiscount[shopId] or 100
end

M.SyncBuybackCommodityInfos = function(self, shopId, infos, noMessage)
	local shopDataDict = self.shopBuybackDataDict[shopId]

	if not shopDataDict then
		shopDataDict = {}
		self.shopBuybackDataDict[shopId] = shopDataDict
	end

	for i = 1, infos.Length do
		local info = infos[i]
		shopDataDict[info.TemplateId] = info
	end

	if not noMessage then
		gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.NPCSHOP_BUYBACK_COMMODITYINFO_CHANGE, shopId, infos)
	end
end

M.SyncFullCommodityInfos = function(self, shopId, infos)
	local shopDataDict = {}

	for i = 1, infos.Length do
		shopDataDict[infos[i].TemplateId] = infos[i]
	end

	self.shopCommodityDataDict[shopId] = shopDataDict

	gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.SHOP_COMMODITY_FULL_REFRESH, shopId)
end

M.SyncFullBuybackCommodityInfos = function(self, shopId, infos)
	local shopDataDict = {}

	for i = 1, infos.Length do
		shopDataDict[infos[i].TemplateId] = infos[i]
	end

	self.shopBuybackDataDict[shopId] = shopDataDict

	gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.SHOP_BUYBACK_COMMODITY_FULL_REFRESH, shopId)
end

M.BuildCommodityGroupResult = function(self, shopId, noSort, blackMarket)
	local shopCfg = ShopConfig.GetConfig(shopId)

	if not shopCfg or not shopCfg.CommodityGroupIdList or #shopCfg.CommodityGroupIdList ~= 0 then
		return nil
	end

	local shopCommodityData = self.shopCommodityDataDict[shopId]

	if not shopCommodityData then
		return nil
	end

	local idx = 1
	local groupDict = {}
	local moneyDict = {}

	for _, groupId in ipairs(shopCfg.CommodityGroupIdList) do
		local groupCfg = ShopCommodityGroupConfig.GetConfig(groupId)

		if groupCfg then
			groupDict[groupId] = {}

			for _, commodityId in ipairs(groupCfg.CommodityIDList) do
				local item = self:GenCommodityItem(commodityId, idx)

				if item then
					item.GroupId = groupId
					groupDict[groupId][commodityId] = item
					moneyDict[item.Money] = true
					idx = idx + 1
				end
			end
		end
	end

	local groupList = {}

	for groupId, commodityList in pairs(groupDict) do
		groupList[groupId] = self:MergeSortDictToList(commodityList, shopCommodityData, noSort, blackMarket)
	end

	return groupList, groupDict, {
		Moneys = moneyDict
	}
end

M.SyncShopRefreshState = function(self, shopId, refreshState, noMessage)
	self.shopRefreshStateDict[shopId] = refreshState

	if not noMessage then
		gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.SHOP_REFRESH_STATE_CHANGE, shopId, refreshState)
	end
end

M.GetShopRefreshState = function(self, shopId)
	return self.shopRefreshStateDict[shopId]
end

M.SyncCommodityPriceHistory = function(self, shopId, sellHistories, buybackHistories)
	local entry = {
		sell = {},
		buyback = {}
	}

	if sellHistories then
		for i = 1, #sellHistories do
			local view = sellHistories[i]
			entry.sell[view.CommodityId] = view
		end
	end

	if buybackHistories then
		for i = 1, #buybackHistories do
			local view = buybackHistories[i]
			entry.buyback[view.CommodityId] = view
		end
	end

	self.shopPriceHistoryDict[shopId] = entry

	gMessageManager:SendMessageMultiParamLuaOnly(gEventConstants.SHOP_PRICE_HISTORY_CHANGE, shopId, sellHistories, buybackHistories)
end

M.GetCommodityPriceHistory = function(self, shopId, isSell)
	local entry = self.shopPriceHistoryDict[shopId]

	if not entry then
		return nil
	end

	return isSell and entry.buyback or entry.sell
end

M.GetManualRefreshCost = function(self, refreshCount, refreshItems)
	if not refreshItems or #refreshItems ~= 0 then
		return nil
	end

	local nextCount = refreshCount + 1
	local result = nil

	for i = 1, #refreshItems do
		local item = refreshItems[i]

		if item.time < nextCount then
			result = item
		end
	end

	return result
end

M.GetShopCommodityInfo = function(self, shopId, callback, noSort, blackMarket)
	if type(shopId) == "number" then
		print_error("传入id类型必须为number！")

		return
	end

	local shopCfg = ShopConfig.GetConfig(shopId)

	if not shopCfg then
		print_error("ShopConfig表里找不到对应的商店信息，商店id=", shopId, " 请找策划解决。")

		if callback then
			callback(false)
		end

		return
	end

	if shopCfg.CommodityGroupIdList and #shopCfg.CommodityGroupIdList <= 0 then
		gClientToGameDelegate:AskNpcShop(shopId).Callback = function (err)
			if err ~= MessageConfig.Ok then
				local shopCommodityData = self.shopCommodityDataDict[shopId]

				if shopCommodityData then
					local CurrentDiscount = self.shopCurrentDiscount[shopId] or 100
					local NextDiscount = self.shopNextDiscount[shopId] or 100
					local idx = 1
					local groupDict = {}
					local moneyDict = {}

					for _, groupId in ipairs(shopCfg.CommodityGroupIdList) do
						local groupCfg = ShopCommodityGroupConfig.GetConfig(groupId)

						if groupCfg then
							groupDict[groupId] = {}

							for _, commodityId in ipairs(groupCfg.CommodityIDList) do
								local item = self:GenCommodityItem(commodityId, idx)

								if item then
									item.GroupId = groupId
									groupDict[groupId][commodityId] = item
									moneyDict[item.Money] = true
									idx = idx + 1
								end
							end
						end
					end

					local groupList = {}

					for groupId, commodityList in pairs(groupDict) do
						groupList[groupId] = self:MergeSortDictToList(commodityList, shopCommodityData, noSort, blackMarket)
					end

					if callback then
						callback(true, groupList, groupDict, {
							CurrentDiscount = CurrentDiscount,
							NextDiscount = NextDiscount,
							Moneys = moneyDict
						})
					end
				else
					print_notice("商店id=", shopId, "获取不到服务端的商品数据，有可能服务端没法或退回登录清理掉了")

					if callback then
						callback(false)
					end
				end
			else
				gDisplayMessageMgr:DisplayServerMessageId(err)

				if callback then
					callback(false)
				end
			end
		end
	elseif shopCfg.SellBrands and #shopCfg.SellBrands <= 0 then
		gClientToGameDelegate:AskNpcShop(shopId).Callback = function (err)
			if err ~= MessageConfig.Ok then
				local shopCommodityData = self.shopCommodityDataDict[shopId]

				if shopCommodityData then
					local CurrentDiscount = self.shopCurrentDiscount[shopId] or 100
					local NextDiscount = self.shopNextDiscount[shopId] or 100
					local idx = 1
					local brandDict = {}
					local moneyDict = {}

					for _, brandId in ipairs(shopCfg.SellBrands) do
						local list = self.brandMap[brandId]

						if list then
							brandDict[brandId] = {}

							for _, commodityId in ipairs(list) do
								local item = self:GenCommodityItem(commodityId, idx)

								if item then
									item.BrandId = brandId
									brandDict[brandId][commodityId] = item
									moneyDict[item.Money] = true
									idx = idx + 1
								end
							end
						end
					end

					local brandList = {}

					for brandId, commodityList in pairs(brandDict) do
						brandList[brandId] = self:MergeSortDictToList(commodityList, shopCommodityData)
					end

					if callback then
						callback(true, brandList, brandDict, {
							CurrentDiscount = CurrentDiscount or 100,
							NextDiscount = NextDiscount or 100,
							Moneys = moneyDict
						})
					end
				else
					print_notice("商店id=", shopId, "获取不到服务端的商品数据，有可能服务端没法或退回登录清理掉了")

					if callback then
						callback(false)
					end
				end
			else
				gDisplayMessageMgr:DisplayServerMessageId(err)

				if callback then
					callback(false)
				end
			end
		end
	else
		print_error("商店id=", shopId, "配置错误,groupList 和 brandList 都为空, 取不到数据, 请找策划（zhouxingduan@corp.netease.com）解决!")

		if callback then
			callback(false)
		end
	end
end

M.GetShopBuybackCommodityInfo = function(self, shopId, callback, noSort, blackMarket)
	if type(shopId) == "number" then
		print_error("传入id类型必须为number！")

		return
	end

	local shopCfg = ShopConfig.GetConfig(shopId)

	if not shopCfg then
		print_error("ShopConfig表里找不到对应的商店信息，商店id=", shopId, " 请找策划解决。")

		if callback then
			callback(false)
		end

		return
	end

	if not shopCfg.BuybackCommodityGroupIdList or #shopCfg.BuybackCommodityGroupIdList ~= 0 then
		print_error("商店id=", shopId, "没有配置出售侧商品组（BuyBackGroup），请找策划解决。")

		if callback then
			callback(false)
		end

		return
	end

	local shopBuybackData = self.shopBuybackDataDict[shopId]

	if not shopBuybackData then
		print_notice("商店id=", shopId, "获取不到服务端的商品数据，有可能服务端没法或退回登录清理掉了")

		if callback then
			callback(false)
		end

		return
	end

	local idx = 1
	local groupDict = {}
	local moneyDict = {}

	for _, groupId in ipairs(shopCfg.BuybackCommodityGroupIdList) do
		local groupCfg = ShopCommodityGroupConfig.GetConfig(groupId)

		if groupCfg then
			groupDict[groupId] = {}

			for _, commodityId in ipairs(groupCfg.CommodityIDList) do
				local item = self:GenCommodityItem(commodityId, idx)

				if item then
					item.GroupId = groupId
					groupDict[groupId][commodityId] = item
					moneyDict[item.Money] = true
					idx = idx + 1
				end
			end
		end
	end

	local groupList = {}

	for groupId, commodityList in pairs(groupDict) do
		groupList[groupId] = self:MergeSortDictToList(commodityList, shopBuybackData, noSort, blackMarket)
	end

	if callback then
		callback(true, groupList, groupDict, {
			Moneys = moneyDict
		})
	end
end

M.GenCommodityItem = function(self, commodityId, index)
	local commodityCfg = NpcShopCommodityCfg.GetConfig(commodityId)

	if not commodityCfg then
		print_error("NpcShopCommodityCfg找不到配置，commodityId=", commodityId, " 请找策划解决!")

		return
	end

	local needExchangeRate = commodityCfg.ConsumeConsumableId ~= ConsumableConfig.RewardMoney
	local consumableCfg = nil

	if needExchangeRate then
		consumableCfg = ConsumableConfig.GetConfig(commodityCfg.ConsumableID)

		if not consumableCfg then
			print_error("NpcShopCommodityCfg找不对应的道具配置，commodityId=", commodityId, "consumableId=", commodityCfg.ConsumableID, " 请找策划解决!")

			return
		end
	end

	local show = gEventConditionUtils.CheckHasUnlocked(commodityCfg, ModuleShopCommodityShow, "ShowMaxProgress")

	if not show then
		return nil
	end

	local item = {}
	local unlockDesc = commodityCfg.UnlockConditionsDes
	local universeUnlockList = commodityCfg.UniverseUnlockConditionsDes

	if universeUnlockList and #universeUnlockList <= 0 then
		local curUniverseId = gMultiverseMgr.curVerseMetaId

		for _, entry in ipairs(universeUnlockList) do
			if entry.universeId ~= curUniverseId then
				unlockDesc = entry.des

				break
			end
		end
	end

	item.UnlockDesc = unlockDesc
	item.Type = commodityCfg.Type
	item.CommodityType = commodityCfg.CommodityType
	item.CD = commodityCfg.CD
	item.IsTop = commodityCfg.IsTop
	item.SubTypeOrder = 0
	local cfg = nil
	local cfgMap = self.commodityTypeMap[item.CommodityType]

	if cfgMap then
		if item.CommodityType ~= CommodityTypeConfig.Consumable then
			cfg = ConsumableConfig.GetConfig(commodityCfg.BindId)

			if not cfg then
				print_error("商店取不到商品数据,Type = Consumable, commodityId=", commodityId, "BindId = ", commodityCfg.BindId, " 请找策划（zhouxingduan@corp.netease.com）解决!")
			end

			item.Quality = cfg and cfg[cfgMap.QualityField] or 0
		elseif item.CommodityType ~= CommodityTypeConfig.Weapon then
			cfg = LTConfig.SceneitemConfig.GetConfig(commodityCfg.BindId)

			if not cfg then
				print_error("商店取不到商品数据,Type = Weapon, commodityId=", commodityId, "BindId = ", commodityCfg.BindId, " 请找策划（zhouxingduan@corp.netease.com）解决!")
			end

			item.Quality = cfg and cfg[cfgMap.QualityField] or 0
		elseif item.CommodityType ~= CommodityTypeConfig.Fashion then
			cfg = FashionConfig.GetConfig(commodityCfg.BindId)

			if not cfg then
				print_error("商店取不到商品数据,Type = Fashion, commodityId=", commodityId, "BindId = ", commodityCfg.BindId, " 请找策划（zhouxingduan@corp.netease.com）解决!")
			end

			item.Quality = cfg and cfg[cfgMap.QualityField] or 0
		elseif item.CommodityType ~= CommodityTypeConfig.Vehicle then
			cfg = VehicleConfig.GetConfig(commodityCfg.BindId)

			if not cfg then
				print_error("商店取不到商品数据,Type = Vehicle, commodityId=", commodityId, "BindId = ", commodityCfg.BindId, " 请找策划（zhouxingduan@corp.netease.com）解决!")
			end

			item.Quality = cfg and cfg[cfgMap.QualityField] or 0
		elseif item.CommodityType ~= CommodityTypeConfig.FashionSuit then
			cfg = FashionSuitConfig.GetConfig(commodityCfg.BindId)

			if not cfg then
				print_error("商店取不到商品数据,Type = FashionSuit, commodityId=", commodityId, "BindId = ", commodityCfg.BindId, " 请找策划（zhouxingduan@corp.netease.com）解决!")
			end

			local fashionId = cfg and cfg.FashionIdList and cfg.FashionIdList[1] or 0
			local fashionCfg = FashionConfig.GetConfig(fashionId)

			if not fashionCfg then
				print_error("时装套装取不到时装数据,Type = FashionSuit, commodityId=", commodityId, " BindId = ", commodityCfg.BindId, "fashionId = ", fashionId, " 请找策划（zhouxingduan@corp.netease.com）解决!")
			end

			item.Quality = fashionCfg and fashionCfg[cfgMap.QualityField] or 0
		elseif item.CommodityType ~= CommodityTypeConfig.ExtractionShooter then
			cfg = ExtractionShooterItemConfig.GetConfig(commodityCfg.BindId)

			if not cfg then
				print_error("商店取不到商品数据,Type = ExtractionShooter, commodityId=", commodityId, "BindId = ", commodityCfg.BindId, " 请找策划（zhouxingduan@corp.netease.com）解决!")
			end

			item.Quality = cfg and cfg[cfgMap.QualityField] or 0
		elseif item.CommodityType ~= CommodityTypeConfig.Furniture then
			cfg = HouseFurnitureConfig.GetConfig(commodityCfg.BindId)

			if not cfg then
				print_error("商店取不到商品数据,Type = Furniture, commodityId=", commodityId, "BindId = ", commodityCfg.BindId, " 请找策划（zhouxingduan@corp.netease.com）解决!")
			end

			item.Quality = cfg and cfg[cfgMap.QualityField] or 0
		end

		item.IconId = cfg and cfg[cfgMap.ShopIconField] or 0
		item.Name = cfg and cfg[cfgMap.NameField] or ""
		item.Description = cfg and cfg[cfgMap.DesField] or ""
		item.Story = cfg and cfg[cfgMap.StoryField] or ""
		item.SubTypeOrder = cfg and cfg[cfgMap.SubOrderField] or 0
		item.ShopIconId = cfg and cfg[cfgMap.ShopIconField] or 0
		item.MiniMapIconId = cfg and cfg[cfgMap.MiniMapIconField] or 0
		item.MapIconId = cfg and cfg[cfgMap.MapIconField] or 0
	end

	item.TypeOrder = cfgMap and cfgMap.Order or 0
	item.Cfg = cfg
	item.tIndex = (item.CommodityType ~= CommodityTypeConfig.Vehicle or item.CommodityType ~= CommodityTypeConfig.FashionSuit) and 1 or 0
	item.ShowNum = item.CommodityType ~= CommodityTypeConfig.Consumable and commodityCfg.IsShowItemNum
	item.CommodityId = commodityId
	item.ConsumableID = commodityCfg.ConsumableID
	item.BindId = commodityCfg.BindId
	item.PriceCurrentWithLabel = ""
	item.LimitNum = commodityCfg.LimitNum
	item.RemainNum = commodityCfg.LimitNum
	item.BuybackLimitNum = commodityCfg.BuybackLimitNum
	item.RemainByLimit = ""
	item.LimitOnceNum = commodityCfg.LimitOnceNum >= 0 and ShopConfig.BuyLimitOnceMaxNum or math.min(commodityCfg.LimitOnceNum, ShopConfig.BuyLimitOnceMaxNum)
	item.LimitHaveNum = commodityCfg.LimitHaveNum
	item.SoldOut = false
	item.Unlocked = false
	item.State = 2
	item.ShowCount = false
	item.NoLimit = commodityCfg.LimitNum ~= -1
	item.IndexOrder = index
	item.DisplayWeight = commodityCfg.DisplayWeight
	local basePrice = commodityCfg.Price

	if needExchangeRate then
		basePrice = consumableCfg.CommodityPrice
		item.PriceOriginal = gCommonItemManager:GetExchangeRate(basePrice)
		item.PriceCurrent = item.PriceOriginal
	else
		item.PriceOriginal = basePrice
		item.PriceCurrent = basePrice
	end

	local normalizedMoneyId = gCommonItemManager:NormalizeMoneyItemId(commodityCfg.ConsumeConsumableId)
	local moneyCfg = ConsumableConfig.GetConfig(normalizedMoneyId)
	item.MoneyIconId = moneyCfg.SMoneyIconId
	item.Money = normalizedMoneyId
	item.MoneyName = moneyCfg.Name
	item.MoneyRichTextIcon = moneyCfg.MoneyRichTextIcon or ""
	item.Discount = 100
	item.HasDiscount = false
	item.DiscountDesc = "100%"
	item.Status = 0
	item.RedDot = false
	item.RefreshTime = 0
	item.IsTask = false
	item.TaskIconId = 0
	item.SortWeight = 0

	return item
end

M.CalcSortWeight = function(self, item)
	local weight = 0

	if item.SoldOut then
		weight = weight + bit.lshift(1, 4)
	end

	if not item.Unlocked then
		weight = weight + bit.lshift(1, 3)
	end

	if not item.IsTask then
		weight = weight + bit.lshift(1, 2)
	end

	if not item.IsTop then
		weight = weight + bit.lshift(1, 1)
	end

	return weight
end

M.MergeSortDictToList = function(self, commodityDict, serverInfos, noSort, blackMarketOnly)
	self:UpdateCommodityInfoBatch(commodityDict, serverInfos)

	local commodityList = {}

	for _, cInfo in pairs(commodityDict) do
		if not blackMarketOnly or serverInfos[cInfo.CommodityId] then
			table.insert(commodityList, cInfo)
		end
	end

	if not noSort then
		table.sort(commodityList, self.CommodityCmp)
	end

	return commodityList
end

M.SortCommodityList = function(self, list)
	table.sort(list, self.CommodityCmp)
end

M.FormatLeftTime = function(self, refreshTime, nowTime)
	if not refreshTime then
		return nil, false
	end

	local now = nowTime or UXTime.GetNowUnixTime()
	local remainSecond = refreshTime - now

	if remainSecond < 0 then
		return gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901019).Text, 0, 0), true
	elseif remainSecond >= 3600 then
		return gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900064).Text, math.floor(remainSecond / 60), math.floor(remainSecond % 60)), true
	elseif remainSecond >= 86400 then
		return gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901019).Text, math.floor(remainSecond / 3600), math.floor(remainSecond / 60 % 60)), true
	else
		return gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901020).Text, math.floor(remainSecond / 86400), math.floor(remainSecond / 3600 % 24)), false
	end
end

M.ItemIsTask = function(self, id)
	local tasks = NpcShopCommodityCfg.GetConfig(id).TaskIcon

	if not tasks or #tasks ~= 0 then
		return false, nil
	end

	for i, taskId in ipairs(tasks) do
		if gTaskManager:IsCurrentTask(taskId) then
			local cfg = gTaskManager:GetTaskConfigInfo(taskId)

			return true, gTaskManager.TaskSIconId[cfg.Title]
		end
	end

	return false, nil
end

M.GetExchangeRate = function(self, FromMoneyType, ToMoneyType)
	local FromMoneyId = gUIUtils:GetMoneyTypeId(FromMoneyType)
	local ToMoneyId = gUIUtils:GetMoneyTypeId(ToMoneyType)

	for i = 0, MallExchangeConfig.count - 1 do
		local cfg = MallExchangeConfig.LoadAt(i)

		if cfg.FromItemId ~= FromMoneyId and cfg.ToItemId ~= ToMoneyId then
			return cfg.Rate
		end
	end

	print_error("找不到moneyType:" .. FromMoneyType .. "到" .. ToMoneyType .. "的兑换比例，请敲liuyf检查传入类型和MallExchangeConfig表")

	return 0
end

M.UpdateCommodityInfoBatch = function(self, commodityDict, serverInfos)
	for _, sInfo in pairs(serverInfos) do
		local cInfo = commodityDict[sInfo.TemplateId]

		if cInfo then
			self:UpdateCommodityInfoSingle(cInfo, sInfo)
		end
	end
end

M.UpdateCommodityInfoSingle = function(self, cInfo, sInfo)
	local count = sInfo.Count

	if sInfo.MaxBuyCount == 0 then
		count = math.min(cInfo.LimitOnceNum, sInfo.MaxBuyCount)
	end

	cInfo.RemainNum = count
	cInfo.RefreshTime = sInfo.RefreshTime
	cInfo.SoldOut = cInfo.RemainNum ~= 0 and not cInfo.NoLimit
	cInfo.RemainByLimit = gString.Format("%d/%d", cInfo.RemainNum, cInfo.LimitNum)
	cInfo.Discount = sInfo.Discount
	cInfo.HasDiscount = cInfo.Discount == 100

	if cInfo.Discount >= 100 then
		cInfo.DiscountDesc = "-" .. 100 - cInfo.Discount
	elseif cInfo.Discount <= 100 then
		cInfo.DiscountDesc = "+" .. cInfo.Discount - 100
	end

	cInfo.PriceCurrent = sInfo.DiscountPrice
	cInfo.Status = sInfo.Status
	cInfo.Unlocked = bit.band(cInfo.Status, NpcShopCommodityStatus.Locked) ~= 0
	cInfo.RedDot = bit.band(cInfo.Status, NpcShopCommodityStatus.Readable) == 0 and cInfo.Unlocked
	cInfo.PriceCurrentWithLabel = "x" .. tostring(cInfo.PriceCurrent)

	if cInfo.SoldOut then
		cInfo.IsTask = false
	else
		cInfo.IsTask, cInfo.TaskIconId = self:ItemIsTask(sInfo.TemplateId)
	end

	cInfo.State = 0
	cInfo.ShowCount = true

	if cInfo.SoldOut then
		cInfo.State = 1
		cInfo.ShowCount = false
	elseif not cInfo.Unlocked then
		cInfo.State = 2
		cInfo.ShowCount = false
	end

	if not cInfo.NoLimit and cInfo.RemainNum ~= 1 then
		cInfo.ShowCount = false
	end

	if cInfo.LimitOnceNum ~= 1 then
		cInfo.ShowCount = false
	end

	cInfo.SortWeight = self:CalcSortWeight(cInfo)
end

M.SetShopIdEnterTime = function(self, shopId)
	if self.shopIdEnterId ~= nil then
		self.shopIdEnterId = {}
	end

	self.shopIdEnterId[shopId] = UXTime.GetNowUnixTime()
end

M.NpcShopExitTime = function(self, shopId)
	if self.shopIdEnterId[shopId] then
		local time = UXTime.GetNowUnixTime() - self.shopIdEnterId[shopId]
		self.shopIdEnterId[shopId] = nil

		gClientToGameDelegate:AskPanelBrowsingTime(gPanelId.S_NPC_SHOP_PANEL, shopId, time)
	end
end

M.PlayVoice = function(self, externalVoiceId)
	self:StopVoice()

	if externalVoiceId and externalVoiceId == 0 then
		self.currentVoiceNid = gSoundMgr:PlaySoundByExternalSourceId(externalVoiceId, ExternalSourceType.Voice, nil, function (uuid, soundData)
			if uuid < 0 then
				self:EndVoiceCb()
			end
		end, nil, function (uuid, soundData)
			self:EndVoiceCb()
		end)
	end
end

M.EndVoiceCb = function(self)
	self.currentVoiceNid = nil
end

M.StopVoice = function(self)
	if self.currentVoiceNid and self.currentVoiceNid == 0 then
		gSoundMgr:StopSoundByNid(self.currentVoiceNid)

		self.currentVoiceNid = nil
	end
end

M.GetFactionDiscountStr = function(self, value, isForSell)
	if not value then
		print_error("GetFactionDiscountStr value is nil")

		return ""
	end

	if not tonumber(value) then
		print_error("GetFactionDiscountStr value is not number:", value)

		return ""
	end

	local str = nil

	if value >= ShopConfig.ShopFactionDiscountTextSeparatedValue then
		str = gString.Format(isForSell and ShopConfig.SellFactionDiscountText[1] or ShopConfig.FactionDiscountText[1], ShopConfig.ShopFactionDiscountTextSeparatedValue - value)
	elseif value ~= ShopConfig.ShopFactionDiscountTextSeparatedValue then
		str = isForSell and ShopConfig.SellFactionDiscountText[2] or ShopConfig.FactionDiscountText[2]
	else
		str = gString.Format(isForSell and ShopConfig.SellFactionDiscountText[3] or ShopConfig.FactionDiscountText[3], value - ShopConfig.ShopFactionDiscountTextSeparatedValue)
	end

	return str
end

M.GetDiscountSourceList = function(self, shopId)
	local list = {}
	local factionDiscount = self.shopFactionDiscount[shopId]

	if factionDiscount and factionDiscount == 100 then
		local shopCfg = ShopConfig.GetConfig(shopId)

		table.insert(list, {
			["\\xd0\\xc86#\\xf4"] = false,
			cfgId = shopCfg and shopCfg.BelongFactionId or 0,
			discountValue = factionDiscount
		})
	end

	local badgeDict = self.shopBadgeDiscountDict[shopId]

	if badgeDict then
		for badgeId, discountVal in pairs(badgeDict) do
			table.insert(list, {
				["\\xd0\\xc86#\\xf4"] = true,
				cfgId = badgeId,
				discountValue = discountVal
			})
		end
	end

	return list
end

M.GetShopCurrentDiscountTextAndIcon = function(self, shopId, callback)
	local discount = self.shopCurrentDiscount[shopId]
	local ret = ""
	local icon = 0

	if not discount then
		gClientToGameDelegate:AskNpcShop(shopId).Callback = function (err)
			if err ~= MessageConfig.Ok then
				discount = self.self.shopCurrentDiscount[shopId] or 100
				ret, icon = self:GetDiscountTextAndIcon(discount, shopId)

				if callback then
					callback(ret, icon)
				end
			else
				print_error("商店id=", shopId, "配置错误,groupList 和 brandList 都为空, 取不到数据, 请找策划（zhouxingduan@corp.netease.com）解决!")

				if callback then
					callback(ret, icon)
				end
			end
		end
	else
		ret, icon = self:GetDiscountTextAndIcon(discount, shopId)

		if callback then
			callback(ret, icon)
		end
	end
end

M.GetDiscountTextAndIcon = function(self, discount, shopId)
	local ret = ""
	local icon = 0

	if discount >= 100 then
		ret = "-" .. 100 - discount .. "%"
		icon = ShopConfig.DiscountIcon
	elseif discount <= 100 then
		ret = "+" .. discount - 100 .. "%"
		icon = ShopConfig.MarkupIcon
	else
		ret = ShopConfig.NoneDiscountText
		local list = self:GetDiscountSourceList(shopId)

		if #list ~= 0 then
			icon = ShopConfig.NoDiscountIcon
		else
			icon = ShopConfig.OffsetOriginalPriceIcon
		end
	end

	return ret, icon
end

gShopManager = gShopManager or C_ShopManager.new()
