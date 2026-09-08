-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TradingPostSellWindowStore.lua
-- Decompiled from: 01345_TradingPostSellWindowStore.lua_1ac8666aab45.luajit

C_TradingPostSellWindowStore = DefClass("C_TradingPostSellWindowStore", C_TradingPostSellWindowStore, C_StoreGroup)
GroupName2Class.TradingPostSellWindowStore = C_TradingPostSellWindowStore
local M = C_TradingPostSellWindowStore
local DEFAULT_MAX_PRICE = 999999999

M.ctor = function(self)
	self.mgr = gTradeManager
end

M.DefineAllVariables = function(self)
	self.tradeItemId = nil
	self.itemCfg = nil
	self.priceRows = {}
	self.price = 0
	self.count = 1
	self.sellDays = 1
	self.maxCount = 1
	self.marketCount = 0
	self.instanceId = nil
	self.countSliderMax = 0
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
	self.instanceId = data and data.instanceId
	self.itemCfg = self.tradeItemId and self.mgr:GetTradeItemConfig(self.tradeItemId) or nil
	self.priceRows = {}
	self.price = 0
	self.count = 1
	self.sellDays = 1
	self.marketCount = 0

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

	if self.mgr:IsOrderTradeItem(self.itemCfg) then
		self.count = 1
		local instances = self.mgr:GetFashionSuitInstances(self.itemCfg)
		self.instanceId = self.instanceId or instances[1] and instances[1].InstanceId
	end

	self:RefreshPanel()
	self.mgr:AskTradeGetMarketList(self.tradeItemId)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.TRADE_MARKET_LIST_CHANGE] = self.CreateAction(self, "OnTradeMarketListChange"),
		[gEventConstants.TRADE_PLAYER_INFO_CHANGE] = self.CreateAction(self, "OnTradePlayerInfoChange")
	}
end

M.OnTradeMarketListChange = function(self, _, tradeItemId)
	if tradeItemId ~= self.tradeItemId then
		self.RefreshPanel(self)
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
	self.bindData.itemView.luaClick = self:CreateAction("OnClickItemView")
	self.bindData.useBtn.luaClick = self:CreateAction("OnClickUseBtn")
	self.bindData.tipBtn.luaRenderTooltip = self:CreateAction("OnRenderTipTooltip")

	self.bindData.tipBtn:SetEnabledTooltip(true)

	self.bindData.priceList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderPriceListItem")
	self.bindData.priceList.luaSimpleClick = self:CreateAction("OnSimpleClickPriceList")
	self.bindData.priceCountList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderPriceCountListItem")
	self.bindData.priceCountList.luaSimpleClick = self:CreateAction("OnSimpleClickPriceCountList")
	self.bindData.priceNumSelector.luaValueChanged = self:CreateAction("OnPriceChanged")
	self.bindData.timeSlider.luaValueChanged = self:CreateAction("OnSellDaysChanged")
	self.bindData.countSlider.luaValueChanged = self:CreateAction("OnCountChanged")
end

M.OnClickCloseBtn = function(self)
	self.Close(self)
end

M.OnClickBackBtn = function(self)
	self.Close(self)
end

M.OnClickItemView = function(self)
end

M.OnClickUseBtn = function(self)
	if not self.CanSell(self) then
		return
	end

	slot1 = self.mgr

	slot1:AskTradeListItem(self.tradeItemId, self.count, self.price, self.sellDays, function (success)
		if success and self.STATE_EnableOnce then
			self:Close()
		end
	end)
end

M.OnRenderTipTooltip = function(self, btn, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	local cfg = LTConfig.MessageExplainConfig.GetConfig(LTConfig.MessageExplainConfig.TradeExplain)
	store.descLabel = cfg and cfg.Content or ""
end

M.RefreshPanel = function(self)
	self.refreshing = true

	self.RefreshPriceRows(self)
	self.RefreshControls(self)
	self.RenderItem(self)

	self.refreshing = false
end

M.RenderItem = function(self)
	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = self.mgr:GetTradeItemConsumableId(self.itemCfg),
		itemNum = gCommonItemManager:GetMoneyRichTextIcon(UX.Game.MoneyType.BindingGold) .. tostring(gCommonItemManager:BuildLargeNum(self.price or 0))
	})
	local store = gCommonItemManager:OnCommonItemRender(self.bindData.itemView, 0, renderData)
	store.nameLabel = self.mgr:GetTradeItemName(self.itemCfg)
end

M.RefreshPriceRows = function(self)
	self.priceRows, self.marketCount, self.countSliderMax = self.mgr:BuildPriceRowData(self.tradeItemId)

	self.bindData.priceList:SetSimpleList(#self.priceRows)
	self.bindData.priceCountList:SetSimpleList(#self.priceRows)

	self.price = self.price <= 0 and self.price or self:GetDefaultPrice()
end

M.RefreshControls = function(self)
	if self.mgr:IsOrderTradeItem(self.itemCfg) then
		self.maxCount = self.mgr:GetFashionSuitInstances(self.itemCfg)[1] and 1 or 0
	elseif self.mgr:IsFashionTradeItem(self.itemCfg) then
		self.maxCount = self.mgr:GetFashionSellableRemainCount(self.itemCfg)
	else
		self.maxCount = self.mgr:GetOwnedCount(self.itemCfg)
	end

	self.maxCount = math.max(0, self.maxCount)
	self.count = math.max(1, math.min(self.count, math.max(1, self.maxCount)))
	local maxDays = math.max(1, self.itemCfg.MaxOrderDays or 1)
	self.sellDays = math.max(1, math.min(self.sellDays, maxDays))
	local priceMin = self.mgr:GetTradeItemMinPrice(self.itemCfg)
	local priceMax = self.mgr:GetTradeItemMaxPrice(self.itemCfg, DEFAULT_MAX_PRICE)

	self.mgr:SetNumSelector(self.bindData.priceNumSelector, priceMin, priceMax, self.price, self:CreateAction("OnPriceChanged"))
	self.mgr:SetNumSelector(self.bindData.countSlider, 1, math.max(1, self.maxCount), self.count, self:CreateAction("OnCountChanged"))
	self.mgr:SetNumSelector(self.bindData.timeSlider, 1, maxDays, self.sellDays, self:CreateAction("OnSellDaysChanged"))

	self.bindData.countLabel = self.count .. "/" .. self.maxCount
	local activeOrderCount = self.mgr:GetActiveOrderCount()
	local maxOrderCount = self.mgr:GetTradeSetting("TradeMaxOrdersPerPlayer", 0)
	local pendingOrderCount = self.count <= 0 and self.maxCount <= 0 and 1 or 0
	local usedOrderCount = math.min(activeOrderCount + pendingOrderCount, maxOrderCount)
	self.bindData.capacityLabel = usedOrderCount .. "/" .. maxOrderCount
	self.bindData.sellTimeLabel = self.sellDays .. "/" .. maxDays
	self.bindData.avPriceMoneyLabel = self.mgr:BuildTradeMoneyText(UX.Game.MoneyType.BindingGold, self.mgr:GetAveragePrice(self.priceRows))
	self.bindData.totalMoneyLabel = self.mgr:BuildTradeMoneyText(UX.Game.MoneyType.BindingGold, self:GetSellerIncome())
	self.bindData.useBtn.interactable = self:CanSell()
end

M.OnPriceChanged = function(self, value)
	if self.refreshing then
		return
	end

	self.price = math.floor(value or self.price or 0)

	self:RefreshControls()
	self:RenderItem()
end

M.OnCountChanged = function(self, value)
	if self.refreshing then
		return
	end

	self.count = math.max(1, math.floor(value or 1))

	self:RefreshControls()
end

M.OnSellDaysChanged = function(self, value)
	if self.refreshing then
		return
	end

	self.sellDays = math.max(1, math.floor(value or 1))

	self:RefreshControls()
end

M.CanSell = function(self)
	return self.price <= 0 and self.count < self.maxCount and not self.mgr:IsTradeBanned() and self.mgr:IsItemInTradeTime(self.itemCfg)
end

M.GetDefaultPrice = function(self)
	return self.mgr:GetTradeItemMinPrice(self.itemCfg)
end

M.GetMaxPrice = function(self)
	return self.mgr:GetTradeItemMaxPrice(self.itemCfg, DEFAULT_MAX_PRICE)
end

M.GetSellerIncome = function(self)
	local total = (self.price or 0) * (self.count or 0)
	local fee = self.mgr:GetEstimatedTransactionFee(total)

	return math.max(0, math.floor(total - fee))
end

M.OnSimpleRenderPriceListItem = function(self, btn, index)
	self.mgr:RenderPriceListItem(btn, self.priceRows, index, UX.Game.MoneyType.BindingGold)
end

M.OnSimpleClickPriceList = function(self, btn, index)
	local row = self.priceRows[index + 1]
	self.price = row.price

	self.RefreshControls(self)
	self.RenderItem(self)
end

M.OnSimpleRenderPriceCountListItem = function(self, btn, index)
	self.mgr:RenderPriceCountListItem(btn, self.priceRows, index, self.countSliderMax)
end

M.OnSimpleClickPriceCountList = function(self, btn, index)
	local row = self.priceRows[index + 1]
	self.price = row.price or self.price

	self:RefreshControls()
	self:RenderItem()
end

M.Close = function(self)
	gPanelManager:Close(self.m_Id)
end
