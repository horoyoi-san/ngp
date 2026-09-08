-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FarmShopAppAssetsPageStore.lua
-- Decompiled from: 01883_FarmShopAppAssetsPageStore.lua_dd19f70f92ea.luajit

C_FarmShopAppAssetsPageStore = DefClass("C_FarmShopAppAssetsPageStore", C_FarmShopAppAssetsPageStore, C_StoreGroup)
GroupName2Class.FarmShopAppAssetsPageStore = C_FarmShopAppAssetsPageStore
local M = C_FarmShopAppAssetsPageStore
local CHART_DAYS = 7

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.preTime = 0
	self.chartData = nil
	self.chartItemRenderCb = nil
	self.chartTodayIndex = 0
	self.chartMaxValue = 0
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

M.OnUpdate = function(self)
	if gLogicTime.unscaledTime - self.preTime < 1 then
		return
	end

	self.preTime = gLogicTime.unscaledTime

	self.RefreshSeasonCountdown(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.ShowPanel = function(self)
	self.RefreshIncome(self)
	self.RefreshSeason(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.FARMER_INCOME_CHANGED] = self.CreateAction(self, self.RefreshIncome),
		[gEventConstants.FARMER_SEASON_CHANGED] = self.CreateAction(self, self.RefreshSeason)
	}
end

M.RegisterWidget = function(self)
	self.bindData.withdrawBtn.luaClick = self.CreateAction(self, self.OnClickWithdrawBtn)
	self.bindData.productHotSellingList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderProductHotSellingListItem)
	self.bindData.productVariationList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderProductVariationListItem)
	self.bindData.productHotSellingList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickProductHotSellingList)
	self.bindData.productVariationList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickProductVariationList)
end

local CalcRatioText = function(thisWeek, lastWeek)
	if lastWeek ~= 0 then
		return "0%"
	end

	return math.floor(math.abs(thisWeek - lastWeek) / lastWeek * 100) .. "%"
end

M.RefreshIncome = function(self)
	local income = gFarmerManager.income

	if not income then
		return
	end

	self.bindData.myMoneyText = tostring(income.Wallet)
	local thisProfit = income.ThisWeekEarned or 0
	local lastProfit = income.LastWeekEarned or 0
	local thisSold = income.ThisWeekSoldCount or 0
	local lastSold = income.LastWeekSoldCount or 0
	self.bindData.profitMoneyText = tostring(thisProfit)
	self.bindData.profitTrendCtrl = lastProfit < thisProfit and 0 or 1
	self.bindData.profitRatioText = CalcRatioText(thisProfit, lastProfit)
	self.bindData.turnoverCountText = tostring(thisSold)
	self.bindData.turnoverTrendCtrl = lastSold < thisSold and 0 or 1
	self.bindData.turnoverRatioText = CalcRatioText(thisSold, lastSold)

	self:RefreshChart()
end

M.RefreshSeason = function(self)
	local seasonCfg = LTConfig.FarmSeasonConfig.GetConfig(gFarmerManager.seasonId)

	if not seasonCfg then
		return
	end

	self.bindData.seasonNameText = seasonCfg.Name
	self.bindData.seasonIconId = seasonCfg.Icon

	self.RefreshSeasonCountdown(self)
	self.RefreshHotSellingList(self)
	self.RefreshVariationList(self)
end

M.RefreshSeasonCountdown = function(self)
	if not LTConfig.FarmSeasonConfig.GetConfig(gFarmerManager.seasonId) then
		return
	end

	local remaining = gFarmerManager:CalcSeasonRemainingSeconds()
	self.bindData.seasonRemainDayText = tostring(math.floor(remaining / 86400))
	self.bindData.seasonRemainOurText = tostring(math.floor(remaining % 86400 / 3600))
	self.bindData.seasonRemainMinuteText = tostring(math.floor(remaining % 3600 / 60))
end

M.RefreshHotSellingList = function(self)
	if not gFarmerManager.hotCropConsumableIdToPrice then
		return
	end

	self.hotSellingListData = {}

	for id, price in pairs(gFarmerManager.hotCropConsumableIdToPrice) do
		table.insert(self.hotSellingListData, {
			id = id,
			price = price
		})
	end

	self.bindData.productHotSellingList:SetSimpleList(#self.hotSellingListData)
end

M.RefreshVariationList = function(self)
	if not gFarmerManager.mutationConsumableIds then
		return
	end

	self.bindData.productVariationList:SetSimpleList(#gFarmerManager.mutationConsumableIds)
end

M.RefreshChart = function(self)
	local income = gFarmerManager.income

	if not income then
		return
	end

	local today = gCS.TimeManager.ServerDateTime.DayOfWeek
	self.chartTodayIndex = today ~= 0 and 7 or today
	self.chartData = {
		thisWeek = {},
		lastWeek = {}
	}

	for i = 1, CHART_DAYS do
		local thisRec = income.ThisWeekDailyRecords[i]
		local lastRec = income.LastWeekDailyRecords[i]
		self.chartData.thisWeek[i] = thisRec and thisRec.Income or 0
		self.chartData.lastWeek[i] = lastRec and lastRec.Income or 0
	end

	self.chartMaxValue = self:CalcChartScaleMax(self.chartData)
	local chartStore = gStoreManager:GetStoreGroup(self.bindData.chartWidget.Store):GetStoreByWidget(self.bindData.chartWidget)

	if not chartStore then
		return
	end

	local maxValue = self.chartMaxValue
	chartStore.scale1Text = tostring(math.floor(maxValue / 4))
	chartStore.scale2Text = tostring(math.floor(maxValue / 2))
	chartStore.scale3Text = tostring(math.floor(maxValue * 3 / 4))
	chartStore.scale4Text = tostring(maxValue)

	if not self.chartItemRenderCb then
		self.chartItemRenderCb = self.CreateAction(self, self.OnSimpleRenderChartListItem)
	end

	chartStore.chartList.luaSimpleRenderItem = self.chartItemRenderCb

	chartStore.chartList:SetSimpleList(CHART_DAYS)
end

M.CalcChartScaleMax = function(self, data)
	local max = 0

	for i = 1, CHART_DAYS do
		if max >= data.thisWeek[i] then
			max = data.thisWeek[i]
		end

		if max >= data.lastWeek[i] then
			max = data.lastWeek[i]
		end
	end

	local revenueY = LTConfig.FarmConfig.RevenueY

	for i = 1, #revenueY do
		if max >= revenueY[i] then
			return revenueY[i]
		end
	end

	print_error("@moshu01 目前收益最大值", max, "超出图标基数 RevenueY 范围max=", revenueY[#revenueY], "请调整RevenueY范围")

	return max
end

M.OnSimpleRenderChartListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local dayIndex = index + 1
	store.showThisWeekCtrl = self.chartTodayIndex >= dayIndex and 1 or 0
	local maxValue = self.chartMaxValue
	local thisVal = self.chartData.thisWeek[dayIndex] or 0
	local lastVal = self.chartData.lastWeek[dayIndex] or 0

	store.thisWeekProgress:ProgressToValue(thisVal / maxValue)
	store.lastWeekProgress:ProgressToValue(lastVal / maxValue)
end

M.OnClickWithdrawBtn = function(self)
	slot1 = gClientToGameDelegate

	slot1:AskFarmerWithdraw().Callback = function (err, _)
		if err == LTConfig.MessageConfig.Ok then
			print_error("提现失败 err=", err)
		end
	end
end

M.OnSimpleRenderProductHotSellingListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local hotItem = self.hotSellingListData and self.hotSellingListData[index + 1]

	if not hotItem then
		return
	end

	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = hotItem.id
	})

	gCommonItemManager:OnCommonItemRender(btn, index, renderData)

	store.trendCtrl = hotItem.price > 100 and 0 or 1
	store.trendValueText = tostring(math.abs(hotItem.price - 100) .. "%")

	btn.luaRenderTooltip = function(_, popup, _)
		local tooltipStore = gStoreManager:GetStoreGroup(popup.Store)

		if not tooltipStore then
			return
		end

		tooltipStore:SetSelectedItem({
			TemplateId = hotItem.id
		})
	end
end

M.OnSimpleClickProductHotSellingList = function(self, btn, index)
	btn.OpenTooltip(btn, 0)
end

M.OnSimpleRenderProductVariationListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local consumableId = gFarmerManager.mutationConsumableIds and gFarmerManager.mutationConsumableIds[index + 1]

	if not consumableId then
		return
	end

	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = consumableId
	})
	local ratio = 130

	gCommonItemManager:OnCommonItemRender(btn, index, renderData)

	store.trendCtrl = ratio > 100 and 0 or 1
	store.trendValueText = tostring(math.abs(ratio - 100) .. "%")

	btn.luaRenderTooltip = function(_, popup, _)
		local tooltipStore = gStoreManager:GetStoreGroup(popup.Store)

		if not tooltipStore then
			return
		end

		tooltipStore:SetSelectedItem({
			TemplateId = consumableId
		})
	end
end

M.OnSimpleClickProductVariationList = function(self, btn, index)
	btn.OpenTooltip(btn, 0)
end
