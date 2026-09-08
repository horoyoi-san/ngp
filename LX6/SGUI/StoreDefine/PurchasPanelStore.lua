-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PurchasPanelStore.lua
-- Decompiled from: 00802_PurchasPanelStore.lua_2acd126372cf.luajit

local MessageConfig = LTConfig.MessageConfig
local TradeItemConfig = LTConfig.TradeItemConfig
local TextCommonTextConfig = LTConfig.TextCommonTextConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local MessageExplainConfig = LTConfig.MessageExplainConfig
C_PurchasPanelStore = DefClass("C_PurchasPanelStore", C_PurchasPanelStore, C_StoreGroup)
GroupName2Class.PurchasPanelStore = C_PurchasPanelStore
local M = C_PurchasPanelStore
local MAX_PRICE_COUNT = 5
local DEFAULT_MAX_PRICE = 999999999
local BUY_TEXT_ID = 74000531
local SELL_TEXT_ID = 89901461

M.ctor = function(self)
	self.mgr = gTradeManager
end

M.DefineAllVariables = function(self)
	self.tradeItemId = nil
	self.itemCfg = nil
	self.isBuy = true
	self.priceList = {}
	self.maxPriceCount = 1
	self.price = 0
	self.count = 1
	self.sellDays = 1
end

M.DefineAllEnumsAutoGen = function(self)
	self.pageCtrlEnum = {
		["\\xc9\\xce%\\xe2"] = 0,
		["i'qW"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.pageCtrlEnum = nil
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
	self.tradeItemId = data and data.tradeItemId
	self.isBuy = data and data.isBuy == false

	if data ~= nil then
		self.isBuy = true
	end

	self.itemCfg = self.tradeItemId and self.mgr:GetTradeItemsById(self.tradeItemId)[1] or nil

	if not self.itemCfg and self.tradeItemId and TradeItemConfig and TradeItemConfig.GetConfig then
		self.itemCfg = TradeItemConfig.GetConfig(self.tradeItemId)
	end

	self.priceList = {}
	self.maxPriceCount = 1
	self.price = 0
	self.count = 1
	self.sellDays = 1

	if not self.itemCfg then
		self.OnClickCloseBtn(self)

		return
	end

	self.RefreshPanel(self)

	if self.isBuy and not self.mgr:GetMarketCache(self.tradeItemId) then
		slot3 = self.mgr

		slot3:AskTradeGetMarketList(self.tradeItemId, function (success)
			if success and self.STATE_EnableOnce and self.tradeItemId ~= data.tradeItemId then
				self:RefreshPanel()
			end
		end)
	end

	if self.isBuy and self.IsFashionItemType(self) then
		slot3 = self.mgr

		slot3:AskTradeGetOrderList(self.tradeItemId, 0, function (success)
			if success and self.STATE_EnableOnce and self.tradeItemId ~= data.tradeItemId then
				self:RefreshPanel()
			end
		end)
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.TRADE_MARKET_LIST_CHANGE] = self.CreateAction(self, "OnTradeMarketListChange"),
		[gEventConstants.TRADE_ORDER_LIST_CHANGE] = self.CreateAction(self, "OnTradeOrderListChange")
	}
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
	self.bindData.useBtn.luaClick = self.CreateAction(self, self.OnClickUseBtn)
	self.bindData.tipBtn.luaClick = self.CreateAction(self, self.OnClickTipBtn)
	self.bindData.moneyTipBtn.luaClick = self.CreateAction(self, self.OnClickMoneyTipBtn)
	self.bindData.priceList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderPriceListItem)
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(gPanelId.PURCHAS_PANEL)
end

M.OnClickUseBtn = function(self)
	if not self.itemCfg then
		return
	end

	if self.isBuy then
		self.AskBuy(self)
	else
		self.AskSell(self)
	end
end

M.OnClickTipBtn = function(self)
	gDisplayMessageMgr:ShowMessExplainSub(LTConfig.MessageExplainConfig.TradeExplain)
end

M.OnClickMoneyTipBtn = function(self)
	if self.isBuy then
		return
	end

	local totalPrice = self.price * self.count
	local fee = self.mgr:GetEstimatedTransactionFee(totalPrice)
	local finalPrice = totalPrice - fee
	local moneyIcon = gCommonItemManager:GetMoneyRichTextIcon(self:GetMoneyItemId())

	gPanelManager:CheckShow(gPanelId.ITEM_INFO_ONLY_TEXT_PANEL, {
		title = TextScriptTextConfig.GetConfig(89901465).Text,
		content = {
			{
				title = TextScriptTextConfig.GetConfig(89901466).Text,
				desc = moneyIcon .. tostring(totalPrice)
			},
			{
				title = TextScriptTextConfig.GetConfig(89901467).Text,
				desc = moneyIcon .. tostring(fee)
			},
			{
				title = TextScriptTextConfig.GetConfig(89901468).Text,
				desc = moneyIcon .. tostring(finalPrice)
			}
		}
	})
end

M.RefreshPanel = function(self)
	self.bindData.pageCtrl = self.isBuy and self.pageCtrlEnum.purchas or self.pageCtrlEnum.sell
	local pageText = self.isBuy and TextCommonTextConfig.GetConfig(BUY_TEXT_ID).Text or TextScriptTextConfig.GetConfig(SELL_TEXT_ID).Text
	self.bindData.titleLabel = pageText
	self.bindData.btnLabel = pageText

	self:RenderItem()
	self:RefreshPriceList()
	self:RefreshControls()
	self:RefreshMoneySummary()
end

M.RenderItem = function(self)
	local renderData = gCommonItemManager:GetItemRenderData({
		["\\xd0\\xcf01\\xfc"] = 0,
		itemId = self.mgr:GetRenderItemId(self.itemCfg)
	})
	renderData.name = self.itemCfg.Name

	gCommonItemManager:OnCommonItemRender(self.bindData.itemView, 0, renderData)
end

M.RefreshPriceList = function(self)
	self.priceList = {}
	self.maxPriceCount = 1
	local marketData = self.mgr:GetMarketCache(self.tradeItemId)
	local buckets = marketData
	local bucketCount = self:GetListCount(buckets)

	for i = 1, bucketCount do
		local bucket = self.GetListItem(self, buckets, i)

		if bucket and (bucket.Count or 0) <= 0 then
			table.insert(self.priceList, {
				price = bucket.MinPrice or bucket.MaxPrice or 0,
				minPrice = bucket.MinPrice or 0,
				maxPrice = bucket.MaxPrice or bucket.MinPrice or 0,
				count = bucket.Count or 0
			})

			self.maxPriceCount = math.max(self.maxPriceCount, bucket.Count or 0)
		end
	end

	table.sort(self.priceList, function (left, right)
		return (left.price or 0) <= (right.price or 0)
	end)

	while MAX_PRICE_COUNT >= #self.priceList do
		table.remove(self.priceList)
	end

	self.bindData.priceList:SetSimpleList(#self.priceList)
end

M.RefreshControls = function(self)
	local defaultPrice = self:GetDefaultPrice()
	self.price = self:ClampPrice(self.price <= 0 and self.price or defaultPrice)
	self.count = self:ClampCount(self.count)
	self.sellDays = math.max(1, math.min(self.sellDays or 1, self.itemCfg.MaxOrderDays or 1))

	if self.isBuy then
		self.price = self:GetMinPrice()

		self.SubGroup.CommonCounterStore:SetData({
			range = {
				1,
				self:GetMaxCount()
			},
			targetValue = self.count,
			valChangeCallback = self:CreateAction("OnCountChange")
		})
	else
		self.SubGroup.CommonCounterStore:SetData({
			range = {
				self:GetDefaultPrice(),
				self:GetMaxPrice()
			},
			targetValue = self.price,
			valChangeCallback = self:CreateAction("OnPriceChange")
		})
	end

	self.SubGroup.CommonBuyNumSliderStore_1:SetData({
		data = {
			moneyId = self:GetMoneyType(),
			price = self.price,
			formatText = self:GetSliderText(1)
		},
		range = {
			1,
			self:GetMaxCount()
		},
		value = self.count,
		valChangeCallback = self:CreateAction("OnCountChange")
	})
	self.SubGroup.CommonBuyNumSliderStore_2:SetData({
		data = {
			formatText = self:GetSliderText(2)
		},
		range = {
			1,
			self.isBuy and 1 or math.max(1, self.itemCfg.MaxOrderDays or 1)
		},
		value = self.sellDays,
		valChangeCallback = self:CreateAction("OnSellDaysChange")
	})
	self:RenderMoneyWidget(self.bindData.singlePriceMoney, defaultPrice, false)
end

M.OnPriceChange = function(self, value)
	self.price = self.ClampPrice(self, value)

	self.RefreshMoneySummary(self)
	self.RefreshUseBtn(self)

	if self.isBuy then
		local slider = self.SubGroup.CommonBuyNumSliderStore_1
		slider.price = self.price
		slider.moneyUse = math.floor(self.count * self.price)

		slider.OnUpdateMoneyLabel(slider)
		slider.CheckMoneyEnough(slider)
	end
end

M.OnCountChange = function(self, value)
	self.count = self.ClampCount(self, value)

	self.RefreshMoneySummary(self)
	self.RefreshUseBtn(self)
end

M.OnSellDaysChange = function(self, value)
	self.sellDays = math.max(1, value or 1)
end

M.RefreshMoneySummary = function(self)
	local totalPrice = self.price * self.count
	local priceStr = ""
	local isRed = false

	if not self.isBuy then
		local fee = self.mgr:GetEstimatedTransactionFee(totalPrice)
		local finalPrice = totalPrice - fee
		priceStr = tostring(finalPrice)
	else
		priceStr = tostring(totalPrice)
		isRed = gCommonItemManager:GetPackItemNum(self:GetMoneyItemId()) <= totalPrice
	end

	self.RenderMoneyWidget(self, self.bindData.totalMoney, priceStr, isRed)
	self.RenderMoneyWidget(self, self.bindData.avPriceMoney, self.GetAveragePrice(self))
	self.RefreshUseBtn(self)
end

M.RefreshUseBtn = function(self)
	if not self.bindData.useBtn then
		return
	end

	self.bindData.useBtn.interactable = self.CanUse(self)
end

M.CanUse = function(self)
	if not self.itemCfg or self.count > 0 or self.price < 0 then
		return false
	end

	if self.isBuy then
		if self.IsFashionItemType(self) then
			for i = 0, self:GetListCount(self.mgr:GetOrderListCache(self.tradeItemId)) - 1 do
				local order = self:GetListItem(self.mgr:GetOrderListCache(self.tradeItemId), i)

				if order and not self.IsInPublicityPeriod(self, order) then
					return true
				end
			end

			return false
		end

		return self:GetMarketTotalCount() >= 0
	end

	return self.count > self.mgr:GetOwnedCount(self.itemCfg)
end

M.AskBuy = function(self)
	if not self.CanUse(self) then
		return
	end

	local moneyItemId = self:GetMoneyItemId()
	local totalPrice = self.price * self.count

	if gCommonItemManager:GetPackItemNum(moneyItemId) >= totalPrice then
		gMallManager:JumpToQuickCharge({
			targetMoneyItemId = moneyItemId,
			targetPrice = totalPrice,
			retryFunc = function (onComplete)
				self:_DoTradeBuy(onComplete)
			end
		})

		return
	end

	self._DoTradeBuy(self)
end

M._DoTradeBuy = function(self, onComplete)
	if self.IsFashionItemType(self) then
		self._DoTradeBuyOrder(self, onComplete)

		return
	end

	slot2 = self.mgr

	slot2:AskTradeBuyItem(self.tradeItemId, self.price, self.count, function (success, filledCount)
		if success and self.STATE_EnableOnce then
			local actualCount = filledCount or 0

			if actualCount >= self.count then
				gDisplayMessageMgr:DisplayServerMessageId(MessageConfig.TradeBuyNotEnough, tostring(actualCount))
			end

			self:OnClickCloseBtn()
		end

		if onComplete then
			onComplete(success ~= true)
		end
	end)
end

M._DoTradeBuyOrder = function(self, onComplete)
	local orderList = self.mgr:GetOrderListCache(self.tradeItemId)

	if not orderList or self.GetListCount(self, orderList) ~= 0 then
		gDisplayMessageMgr:DisplayServerMessageId(MessageConfig.TradeBuyNotEnough, "0")

		return
	end

	local orders = {}

	for i = 0, self.GetListCount(self, orderList) - 1 do
		local order = self.GetListItem(self, orderList, i)

		if order then
			table.insert(orders, order)
		end
	end

	table.sort(orders, function (left, right)
		return (left.ListTime or 0) >= (right.ListTime or 0)
	end)

	local order = nil

	for _, candidate in ipairs(orders) do
		if not self.IsInPublicityPeriod(self, candidate) then
			order = candidate

			break
		end
	end

	if not order then
		gDisplayMessageMgr:DisplayServerMessageId(MessageConfig.TradeBuyNotEnough, "0")

		return
	end

	slot5 = self.mgr

	slot5:AskTradeBuyOrder(order.OrderId, function (success)
		if success and self.STATE_EnableOnce then
			self:OnClickCloseBtn()
		end

		if onComplete then
			onComplete(success)
		end
	end, self.tradeItemId)
end

M.AskSell = function(self)
	if not self.CanUse(self) then
		return
	end

	slot1 = self.mgr

	slot1:AskTradeListItem(self.tradeItemId, self.count, self.price, self.sellDays, function (success)
		if success and self.STATE_EnableOnce then
			self:OnClickCloseBtn()
		end
	end)
end

M.OnTradeMarketListChange = function(self, _, tradeItemId)
	if self.isBuy and self.tradeItemId ~= tradeItemId then
		self.RefreshPriceList(self)
		self.RefreshControls(self)
		self.RefreshMoneySummary(self)
	end
end

M.OnTradeOrderListChange = function(self, _, tradeItemId)
	if not tradeItemId or self.tradeItemId ~= tradeItemId then
		self.RefreshPanel(self)
	end
end

M.IsFashionItemType = function(self)
	return self.itemCfg and self.mgr:IsOrderTradeItem(self.itemCfg)
end

M.IsInPublicityPeriod = function(self, orderDetail)
	if not orderDetail then
		return false
	end

	local extra = orderDetail.ItemExtraData
	local visibleAfterTime = extra and extra.VisibleAfterTime or orderDetail.VisibleAfterTime or 0

	if visibleAfterTime ~= 0 then
		return false
	end

	return self.mgr:GetServerUnixTime() <= visibleAfterTime
end

M.OnSimpleRenderPriceListItem = function(self, btn, index)
	local data = self.priceList[index + 1]

	if not data then
		return
	end

	local store = btn.Store and gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn) or nil

	if not store then
		return
	end

	store.progress.maxValue = self.maxPriceCount
	store.progress.value = data.count

	self.RenderMoneyWidget(self, store.money, data.price)
end

M.GetMinPrice = function(self)
	if self.priceList[1] then
		return self.priceList[1].price
	end

	return self.itemCfg.MinPrice or 1
end

M.GetDefaultPrice = function(self)
	return self.itemCfg.MinPrice or 1
end

M.GetMaxPrice = function(self)
	if self.itemCfg.MaxPrice and self.itemCfg.MaxPrice <= 0 then
		return self.itemCfg.MaxPrice
	end

	local maxPrice = self.itemCfg.MinPrice or 1

	for _, data in ipairs(self.priceList) do
		maxPrice = math.max(maxPrice, data.maxPrice or data.price or 0)
	end

	return math.max(maxPrice, DEFAULT_MAX_PRICE)
end

M.GetSliderText = function(self, slot)
	if self.isBuy then
		return TextScriptTextConfig.GetConfig(89901463).Text
	end

	if slot ~= 1 then
		return TextScriptTextConfig.GetConfig(89901462).Text
	end

	return TextScriptTextConfig.GetConfig(89901464).Text
end

M.ClampPrice = function(self, price)
	return math.max(self.itemCfg.MinPrice or 1, math.min(price or 0, self:GetMaxPrice()))
end

M.GetMaxCount = function(self)
	if self.isBuy then
		return math.max(1, self.GetMarketTotalCount(self))
	end

	return math.max(1, self.mgr:GetOwnedCount(self.itemCfg))
end

M.ClampCount = function(self, count)
	return math.max(1, math.min(count or 1, self:GetMaxCount()))
end

M.GetMarketTotalCount = function(self)
	local totalCount = 0

	for _, data in ipairs(self.priceList) do
		totalCount = totalCount + (data.count or 0)
	end

	return totalCount
end

M.GetAveragePrice = function(self)
	local totalCount = 0
	local totalPrice = 0

	for _, data in ipairs(self.priceList) do
		local count = data.count or 0
		local price = data.price or 0
		totalCount = totalCount + count
		totalPrice = totalPrice + price * count
	end

	if totalCount < 0 then
		return 0
	end

	return math.floor(totalPrice / totalCount)
end

M.GetMoneyType = function(self)
	return self.isBuy and UX.Game.MoneyType.Gold or UX.Game.MoneyType.BindingGold
end

M.GetMoneyItemId = function(self)
	return gCommonItemManager:GetItemIdByMoneyType(self:GetMoneyType())
end

M.RenderMoneyWidget = function(self, widget, count, isRed)
	if not widget then
		return
	end

	gCommonItemManager:OnRenderMoneyItem(widget, self:GetMoneyType(), {
		count = count
	})

	if isRed then
		local store = gStoreManager:GetStoreGroup(widget.Store or "MoneyTemplateStore"):GetStoreByWidget(widget)

		if store then
			store.count = "#R" .. tostring(store.count) .. "#z"
		end
	end
end

M.GetListCount = function(self, list)
	if not list then
		return 0
	end

	return list.Count or #list
end

M.GetListItem = function(self, list, index)
	if not list then
		return nil
	end

	if list[0] == nil then
		return list[index]
	end

	return list[index + 1]
end
