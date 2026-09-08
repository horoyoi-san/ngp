-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BlackMarketPanelStore.lua
-- Decompiled from: 02018_BlackMarketPanelStore.lua_9c19d395a772.luajit

C_BlackMarketPanelStore = DefClass("C_BlackMarketPanelStore", C_BlackMarketPanelStore, C_FullScreenShopStore)
GroupName2Class.BlackMarketPanelStore = C_BlackMarketPanelStore
local M = C_BlackMarketPanelStore

M.OnShow = function(self, panelId, data)
	data = data or {}
	self.panelId = panelId
	self.blackMarketChartDataDict = data.blackMarketChartDataDict or {
		sell = {},
		buyback = {}
	}

	M.base.OnShow(self, panelId, {
		shopId = data.shopId or data[1]
	})

	self.bindData.showSecondTabCtrl = 1
end

M.OnClose = function(self)
	local detailStore = self.SubGroup and self.SubGroup.FullScreenShopTooltipStore

	if detailStore then
		detailStore.ClearData(detailStore)
	end

	M.base.OnClose(self)

	self.panelId = nil
	self.blackMarketChartDataDict = nil
end

M.GenMessageEvents = function(self)
	M.base.GenMessageEvents(self)

	self.msgEvents[gEventConstants.SHOP_PRICE_HISTORY_CHANGE] = self.CreateAction(self, "OnPriceHistoryChange")
end

M.OnGroupEnable = function(self)
	M.base.OnGroupEnable(self)

	if self.SubGroup and self.SubGroup.FullScreenShopTooltipStore then
		self.InitTooltipWidget(self)
	end
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(self.panelId or gPanelId.FULL_SCREEN_STORE)
end

M.OnInfoBtnClick = function(self)
	gDisplayMessageMgr:ShowMessExplainSub(LTConfig.MessageExplainConfig.BlackMarketDesc)
end

M.RefreshControllerListCtrl = function(self)
	self.SetupGroupTabs(self)
end

M.InitMoneyInfo = function(self, moneys)
	self.moneys = moneys or {}
	local MoneyTemplateData = {}

	for consumableId, _ in pairs(self.moneys) do
		self.moneys[consumableId] = gCommonItemManager:GetPackItemNum(consumableId)

		table.insert(MoneyTemplateData, {
			Type = consumableId
		})
	end

	self.SubGroup.MoneyTemplateStore:SetData(MoneyTemplateData)
end

M.InitTooltipWidget = function(self)
	self.toolTipStore = self.SubGroup.FullScreenShopTooltipStore

	if not self.toolTipStore then
		return
	end

	self.toolTipStore:Init({
		onBuyBtnClick = self:CreateAction("OnBuyBtnClick"),
		onSaleBtnClick = self:CreateAction("OnSaleBtnClick")
	})
end

M.RefreshCommodityInfo = function(self)
	gShopManager:GetShopCommodityInfo(self.shopId, self:CreateAction("OnGetCommodityInfoCallback"), nil, true)
end

M.RefreshBuybackInfo = function(self)
	gShopManager:GetShopBuybackCommodityInfo(self.shopId, self:CreateAction("OnGetBuybackInfoCallback"), nil, true)
end

M.GetFullCommodityGroupResult = function(self)
	return gShopManager:BuildCommodityGroupResult(self.shopId, nil, true)
end

M.GetBlackMarketChartData = function(self, info)
	if not info then
		return nil
	end

	local dict = self.blackMarketChartDataDict

	if dict then
		local side = self.isSell and dict.buyback or dict.sell
		local chartData = side and side[info.CommodityId]

		if chartData then
			return chartData
		end
	end

	return info.BlackMarketChartData or info.ChartData
end

M.SetBlackMarketChartData = function(self, commodityId, chartData, isSell)
	if isSell ~= nil then
		isSell = self.isSell
	end

	self.blackMarketChartDataDict = self.blackMarketChartDataDict or {
		sell = {},
		buyback = {}
	}
	local side = isSell and self.blackMarketChartDataDict.buyback or self.blackMarketChartDataDict.sell
	side[commodityId] = chartData

	if self.selectedInfo and self.selectedInfo.CommodityId ~= commodityId and self.isSell ~= isSell and self.toolTipStore then
		self.toolTipStore:SetChartData(chartData)
	end
end

M.OnPriceHistoryChange = function(self, eventId, shopId, sellHistories, buybackHistories)
	if self.shopId == shopId then
		return
	end

	self.ApplyPriceHistory(self, false, sellHistories)
	self.ApplyPriceHistory(self, true, buybackHistories)
end

M.ApplyPriceHistory = function(self, isSell, histories)
	if not histories then
		return
	end

	for i = 1, #histories do
		local view = histories[i]

		self.SetBlackMarketChartData(self, view.CommodityId, self.BuildChartData(self, view), isSell)
	end
end

M.BuildChartData = function(self, view)
	local points = {}
	local entries = view.Entries

	if entries then
		for i = 1, #entries do
			local entry = entries[i]
			points[i] = {
				Time = entry.Time,
				Value = entry.UnitPrice
			}
		end
	end

	return {
		points = points
	}
end

M.EnsurePriceHistoryLoaded = function(self)
	if not self.shopId then
		return
	end

	local historyDict = gShopManager:GetCommodityPriceHistory(self.shopId, self.isSell)

	if not historyDict then
		return
	end

	for commodityId, view in pairs(historyDict) do
		self.SetBlackMarketChartData(self, commodityId, self.BuildChartData(self, view), self.isSell)
	end
end

M.RefreshTooltip = function(self)
	if not self.toolTipStore and self.SubGroup and self.SubGroup.FullScreenShopTooltipStore then
		self.InitTooltipWidget(self)
	end

	if not self.toolTipStore or not self.selectedInfo then
		return
	end

	self:EnsurePriceHistoryLoaded()

	self.bindData.curWeaponImg = self.selectedInfo and self.selectedInfo.ShopIconId or 0

	self.toolTipStore:RefreshTooltip(self.selectedInfo, {
		["69%\\xcdg\\x9d\\xfa\\xad<\\xe5\\xde\\xefg\\xef"] = true,
		isSell = self.isSell,
		getSellPackNum = self:CreateAction("GetSellItemPackNum"),
		getSellMaxNum = self:CreateAction("GetSellMaxNum"),
		isTarkov = self.isTarkov,
		chartData = self:GetBlackMarketChartData(self.selectedInfo)
	})

	local counterStore = self.SubGroup.CommonCounterStore

	counterStore:SetData({
		["\\x8b528}\\x89w\\xd8;\\xbf\\xbc"] = 1,
		range = {
			1,
			self:GetMaxNum()
		},
		valChangeCallback = self:CreateAction("OnBuyNumChange")
	})
	counterStore:OnBuyNumChange(1)
end

M.OnBuyNumChange = function(self, val)
	if not self.selectedInfo or not self.toolTipStore then
		return
	end

	self.buyNum = math.max(1, val or 1)
	local info = self.selectedInfo
	local totalPrice = self.buyNum * (info.PriceCurrent or 0)
	local canConfirm = nil
	local moneyNotEnough = false

	if self.isSell then
		canConfirm = self.buyNum > self:GetSellMaxNum(info)
	else
		local money = self.moneys and self.moneys[info.Money] or 0
		moneyNotEnough = totalPrice >= money
		canConfirm = not moneyNotEnough and not info.SoldOut and info.Unlocked == false and (info.NoLimit or self.buyNum > info.RemainNum)
	end

	self.toolTipStore:UpdateBuyInfo(self.buyNum, info, {
		priceText = (info.MoneyRichTextIcon or "") .. tostring(totalPrice),
		moneyNotEnough = moneyNotEnough,
		buyBtnActive = not self.isSell and canConfirm,
		saleBtnActive = self.isSell and canConfirm
	})
end
