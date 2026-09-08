-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FarmInventoryTooltipStore.lua
-- Decompiled from: 02077_FarmInventoryTooltipStore.lua_7fbdbd98c77d.luajit

C_FarmInventoryTooltipStore = DefClass("C_FarmInventoryTooltipStore", C_FarmInventoryTooltipStore, C_InventoryItemDetailInfoTemplateStore)
GroupName2Class.FarmInventoryTooltipStore = C_FarmInventoryTooltipStore
local M = C_FarmInventoryTooltipStore
local DEFAULT_SELL_RATE = 0.2

M.InitFarmItem = function(self, item, farmCfg)
	self.farmCfg = farmCfg
	local basePrice = farmCfg and farmCfg.BasePrice or 0
	local quality = item.Quality or 0
	local minPrice, recommended, maxPrice = gFarmerManager:GetPriceRange(basePrice, quality)
	self.currentCount = 1
	self.currentPrice = recommended

	M.base.SetSelectedItem(self, {
		["|b\\xa9ge\\xbc\\xe6Bxl@"] = 1,
		TemplateId = item.TemplateId,
		range = {
			1,
			item.Count
		}
	}, nil, , function (count)
		self:OnCountChange(count)
	end, nil, false)
	self.SubGroup.FarmBuyNumSliderStore:SetFarmData({
		range = {
			minPrice,
			maxPrice
		},
		value = recommended,
		data = {
			["]\\xbc\\xab\\xac\\xb3"] = 1,
			["\\xd4\\xd4\r\\xf5"] = 0
		},
		valChangeCallback = function (price)
			self:OnPriceChange(price)
		end
	}, recommended)

	self.bindData.showBtn = 1
	self.bindData.stateCtrl = 0
	self.bindData.btnNameLabel = "确认上架"
end

M.OnRefreshInfo = function(self)
	M.base.OnRefreshInfo(self)

	if self.farmCfg then
		self.bindData.iconId = self.farmCfg.SItemIconId
	end
end

M.OnCountChange = function(self, count)
	self.currentCount = count

	self.RefreshExpectInfo(self)
end

M.OnPriceChange = function(self, price)
	self.currentPrice = price

	self.RefreshExpectInfo(self)
end

M.RefreshExpectInfo = function(self)
	local count = self.currentCount or 1
	local price = self.currentPrice or self.farmCfg and self.farmCfg.BasePrice or 0
	local sellRate = self.farmCfg and self.farmCfg.BaseSellRate and self.farmCfg.BaseSellRate <= 0 and self.farmCfg.BaseSellRate or DEFAULT_SELL_RATE
	self.bindData.expectProfitsText = tostring(price * count)
	self.bindData.expectSaleTimeText = gTimeUtils:GetLongTimeStrWithoutSec(count / sellRate * 60)
end

M.GetCurrentPrice = function(self)
	return self.SubGroup.FarmBuyNumSliderStore.moneyUse
end
