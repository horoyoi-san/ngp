-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TradingPostPurchaseWindowStore.lua
-- Decompiled from: 01377_TradingPostPurchaseWindowStore.lua_29ec4be4588a.luajit

C_TradingPostPurchaseWindowStore = DefClass("C_TradingPostPurchaseWindowStore", C_TradingPostPurchaseWindowStore, C_StoreGroup)
GroupName2Class.TradingPostPurchaseWindowStore = C_TradingPostPurchaseWindowStore
local M = C_TradingPostPurchaseWindowStore
local DIRECTION_FIRST = 0
local DEFAULT_MAX_PRICE = 999999999

M.ctor = function(self)
	self.mgr = gTradeManager
end

M.DefineAllVariables = function(self)
	self.tradeItemId = nil
	self.itemCfg = nil
	self.priceRows = {}
	self.orderList = {}
	self.selectedOrder = nil
	self.price = 0
	self.count = 1
	self.maxCount = 1
	self.marketCount = 0
	self.countSliderMax = 0
	self.freePriceMode = false
	self.refreshing = false
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.tradeItemId = data and (data.tradeItemId or data.itemId)
	self.itemCfg = self.tradeItemId and self.mgr:GetTradeItemsById(self.tradeItemId)[1] or nil
	self.priceRows = {}
	self.orderList = {}
	self.selectedOrder = nil
	self.price = 0
	self.count = 1
	self.marketCount = 0
	self.freePriceMode = false

	self.bindData.priceToggle:SetSelected(false)

	if not self.itemCfg then
		self.Close(self)

		return
	end

	self.SubGroup.MoneyTemplateStore:SetData({
		{
			Type = LTConfig.ConsumableConfig.RewardGold
		},
		{
			Type = LTConfig.ConsumableConfig.RewardBindingGold
		}
	})
	self:RefreshPanel()

	if not self.mgr:GetMarketCache(self.tradeItemId) then
		self.mgr:AskTradeGetMarketList(self.tradeItemId)
	end

	if self.mgr:IsOrderTradeItem(self.itemCfg) then
		self.mgr:AskTradeGetOrderList(self.tradeItemId, DIRECTION_FIRST)
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.TRADE_MARKET_LIST_CHANGE] = self.CreateAction(self, "OnTradeMarketListChange"),
		[gEventConstants.TRADE_ORDER_LIST_CHANGE] = self.CreateAction(self, "OnTradeOrderListChange"),
		[gEventConstants.TRADE_PLAYER_INFO_CHANGE] = self.CreateAction(self, "OnTradePlayerInfoChange")
	}
end

M.OnTradeMarketListChange = function(self, _, tradeItemId)
	if tradeItemId ~= self.tradeItemId then
		self.RefreshPanel(self)
	end
end

M.OnTradeOrderListChange = function(self, _, tradeItemId)
	if tradeItemId ~= self.tradeItemId then
		self.RefreshOrderList(self)
		self.RefreshControls(self)
		self.RenderItem(self)
	end
end

M.OnTradePlayerInfoChange = function(self)
	if self.STATE_EnableOnce then
		self.RefreshControls(self)
	end
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self:CreateAction("OnClickCloseBtn")
	self.bindData.backBtn.luaClick = self:CreateAction("OnClickCloseBtn")
	self.bindData.useBtn.luaClick = self:CreateAction("OnClickUseBtn")
	self.bindData.tipBtn.luaRenderTooltip = self:CreateAction("OnRenderTipTooltip")

	self.bindData.tipBtn:SetEnabledTooltip(true)

	self.bindData.priceToggle.luaSelectChanged = self:CreateAction("OnPriceToggleSelectChanged")
	self.bindData.priceList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderPriceListItem")
	self.bindData.priceCountList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderPriceCountListItem")
	self.bindData.priceCountList.luaSimpleClick = self:CreateAction("OnSimpleClickPriceCountList")
	self.OnCountChangeCb = self:CreateAction("OnCountChanged")
	self.OnPriceChangeCb = self:CreateAction("OnPriceChanged")
	self.bindData.numSlider.luaValueChanged = self.OnCountChangeCb
	self.bindData.priceSlider.luaValueChanged = self.OnPriceChangeCb
end

M.OnClickCloseBtn = function(self)
	self.Close(self)
end

M.OnClickUseBtn = function(self)
	if not self.CanBuy(self) then
		return
	end

	if self.mgr:IsOrderTradeItem(self.itemCfg) and not self.freePriceMode then
		self.BuyOrder(self)
	else
		self.BuyItem(self)
	end
end

M.OnRenderTipTooltip = function(self, btn, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	local cfg = LTConfig.MessageExplainConfig.GetConfig(LTConfig.MessageExplainConfig.TradeExplain)
	store.descLabel = cfg and cfg.Content or ""
end

M.OnPriceToggleSelectChanged = function(self, isSelected)
	self.freePriceMode = isSelected ~= true

	if not self.freePriceMode then
		self.price = self.GetMinPrice(self)
	end

	self.RefreshControls(self)
	self.RenderItem(self)
end

M.RefreshPanel = function(self)
	self.refreshing = true

	self.RefreshPriceRows(self)
	self.RefreshOrderList(self)
	self.RefreshControls(self)
	self.RenderItem(self)

	self.refreshing = false
end

M.RenderItem = function(self)
	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = self.mgr:GetRenderItemId(self.itemCfg),
		itemNum = gCommonItemManager:GetMoneyRichTextIcon(UX.Game.MoneyType.Gold) .. tostring(gCommonItemManager:BuildLargeNum(self.price or 0))
	})
	local store = gCommonItemManager:OnCommonItemRender(self.bindData.itemView, 0, renderData)
	store.nameLabel = self.mgr:GetTradeItemName(self.itemCfg)
end

M.RefreshPriceRows = function(self)
	self.priceRows, self.marketCount, self.countSliderMax = self.mgr:BuildPriceRowData(self.tradeItemId)
	self.maxCount = math.max(1, self.marketCount)

	self.bindData.priceList:SetSimpleList(#self.priceRows)
	self.bindData.priceCountList:SetSimpleList(#self.priceRows)

	self.price = self.price <= 0 and self.price or self:GetMinPrice()
end

M.RefreshOrderList = function(self)
	self.orderList = {}

	if self.mgr:IsOrderTradeItem(self.itemCfg) then
		local cache = self.mgr:GetOrderListCache(self.tradeItemId)

		for i = 0, self.mgr:GetListCount(cache) - 1 do
			local order = self.mgr:GetListItem(cache, i)

			if order then
				table.insert(self.orderList, order)
			end
		end

		table.sort(self.orderList, function (left, right)
			return (left.ListTime or 0) >= (right.ListTime or 0)
		end)

		self.selectedOrder = self.selectedOrder and self:FindOrder(self.selectedOrder.OrderId) or nil

		if not self.selectedOrder then
			for _, order in ipairs(self.orderList) do
				if not self.IsInPublicityPeriod(self, order) then
					self.selectedOrder = order

					break
				end
			end
		end
	end
end

M.FindOrder = function(self, orderId)
	for _, order in ipairs(self.orderList) do
		if order.OrderId ~= orderId then
			return order
		end
	end

	return nil
end

M.RefreshControls = function(self)
	local priceMin, priceMax = nil

	if self.freePriceMode then
		local cfgMax = self.itemCfg.MaxPrice
		priceMax = cfgMax and cfgMax <= 0 and cfgMax or DEFAULT_MAX_PRICE
		priceMin = 1

		self.mgr:SetNumSelector(self.bindData.numSlider, 1, DEFAULT_MAX_PRICE, self.count, self.OnCountChangeCb)
	else
		local orderMode = self.mgr:IsOrderTradeItem(self.itemCfg)

		if orderMode and not self.freePriceMode then
			self.count = 1
			self.maxCount = 1

			if self.selectedOrder then
				self.price = self.selectedOrder.Price or 0
			end
		else
			self.count = math.max(1, math.min(self.count, self.maxCount))
		end

		priceMax = self.mgr:GetMaxPrice(self.itemCfg, self.priceRows)
		priceMin = self:GetMinPrice()

		self.mgr:SetNumSelector(self.bindData.numSlider, 1, self.maxCount, self.count, self.OnCountChangeCb)
	end

	self.mgr:SetNumSelector(self.bindData.priceSlider, priceMin, priceMax, self.price, self.OnPriceChangeCb)

	self.bindData.avPriceMoneyLabel = self.mgr:BuildTradeMoneyText(UX.Game.MoneyType.Gold, self.mgr:GetAveragePrice(self.priceRows))
	self.bindData.totalMoneyLabel = self.mgr:BuildTradeMoneyText(UX.Game.MoneyType.Gold, self:GetTotalPrice(), self:IsMoneyInsufficient())
	self.bindData.useBtn.interactable = self:CanBuy()

	self:RefreshSumTime()
end

M.RefreshSumTime = function(self)
	local duration = self.mgr:GetDailyTradeDuration(self.itemCfg)

	if duration and duration <= 0 then
		self.bindData.countDown:Play(duration)
	end
end

M.OnCountChanged = function(self, value)
	if self.refreshing then
		return
	end

	self.count = self.freePriceMode and math.floor(value or 1) or math.max(1, math.min(math.floor(value or 1), self.maxCount))

	self:RefreshControls()
end

M.OnPriceChanged = function(self, value)
	if self.refreshing then
		return
	end

	self.price = math.floor(value or self.price or 0)

	self:RefreshControls()
	self:RenderItem()
end

M.CanBuy = function(self)
	if self.mgr:IsTradeBanned() or not self.mgr:IsItemInTradeTime(self.itemCfg) then
		return false
	end

	if self.mgr:IsOrderTradeItem(self.itemCfg) and not self.freePriceMode then
		return self.selectedOrder == nil and not self:IsInPublicityPeriod(self.selectedOrder) and not self:IsMoneyInsufficient()
	end

	return self.marketCount <= 0 and self.maxCount <= 0 and self.price <= 0 and not self:IsMoneyInsufficient()
end

M.IsMoneyInsufficient = function(self)
	local total = self:GetTotalPrice()
	local moneyId = gCommonItemManager:GetItemIdByMoneyType(UX.Game.MoneyType.Gold)

	return moneyId and gCommonItemManager:GetPackItemNum(moneyId) <= total or false
end

M.BuyItem = function(self)
	local maxPrice = self.price

	if not self.freePriceMode then
		local _, autoMaxPrice = self.GetAutoBuyInfo(self, self.count)

		if autoMaxPrice <= 0 then
			maxPrice = autoMaxPrice or maxPrice
		end
	end

	slot2 = self.mgr

	slot2:AskTradeBuyItem(self.tradeItemId, maxPrice, self.count, function (success)
		if success and self.STATE_EnableOnce then
			self:Close()
		end
	end)
end

M.GetAutoBuyInfo = function(self, count)
	local remainingCount = math.max(0, math.floor(count or self.count or 0))
	local totalPrice = 0
	local maxPrice = 0

	for _, row in ipairs(self.priceRows) do
		if remainingCount < 0 then
			break
		end

		local availableCount = math.max(0, math.floor(row.count or 0))
		local price = row.price or 0
		local buyCount = math.min(remainingCount, availableCount)

		if buyCount <= 0 and price <= 0 then
			totalPrice = totalPrice + price * buyCount
			maxPrice = price
			remainingCount = remainingCount - buyCount
		end
	end

	return totalPrice, maxPrice
end

M.BuyOrder = function(self)
	if not self.selectedOrder or self.IsInPublicityPeriod(self, self.selectedOrder) then
		return
	end

	slot1 = self.mgr

	slot1:AskTradeBuyOrder(self.selectedOrder.OrderId, function (success)
		if success and self.STATE_EnableOnce then
			self:Close()
		end
	end, self.tradeItemId)
end

M.GetMinPrice = function(self)
	return self.priceRows[1] and self.priceRows[1].price or self.itemCfg.MinPrice or 1
end

M.GetMaxPrice = function(self)
	return self.mgr:GetMaxPrice(self.itemCfg, self.priceRows)
end

M.GetTotalPrice = function(self)
	if self.selectedOrder and not self.freePriceMode then
		return (self.selectedOrder.Price or 0) * self.count
	end

	if not self.freePriceMode then
		local totalPrice = self.GetAutoBuyInfo(self, self.count)

		return totalPrice
	end

	return (self.price or 0) * (self.count or 1)
end

M.GetAveragePrice = function(self)
	return self.mgr:GetAveragePrice(self.priceRows)
end

M.OnSimpleRenderPriceListItem = function(self, btn, index)
	self.mgr:RenderPriceListItem(btn, self.priceRows, index, UX.Game.MoneyType.Gold)
end

M.OnSimpleRenderPriceCountListItem = function(self, btn, index)
	self.mgr:RenderPriceCountListItem(btn, self.priceRows, index, self.countSliderMax)
end

M.OnSimpleClickPriceCountList = function(self, btn, index)
	local row = self.priceRows[index + 1]

	if not row then
		return
	end

	self.count = math.min(self.maxCount, row.count or 1)
	self.price = row.price or self.price

	self:RefreshControls()
	self:RenderItem()
end

M.IsInPublicityPeriod = function(self, order)
	if not order then
		return false
	end

	local extra = order.ItemExtraData
	local visibleAfterTime = extra and extra.VisibleAfterTime or order.VisibleAfterTime or 0

	return visibleAfterTime >= (self.mgr:GetServerUnixTime() or 0)
end

M.Close = function(self)
	gPanelManager:Close(self.m_Id)
end
