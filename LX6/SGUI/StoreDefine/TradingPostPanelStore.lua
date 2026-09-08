-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TradingPostPanelStore.lua
-- Decompiled from: 01376_TradingPostPanelStore.lua_21104368b997.luajit

C_TradingPostPanelStore = DefClass("C_TradingPostPanelStore", C_TradingPostPanelStore, C_StoreGroup)
GroupName2Class.TradingPostPanelStore = C_TradingPostPanelStore
local M = C_TradingPostPanelStore

M.ctor = function(self)
	self.mgr = gTradeManager
end

M.DefineAllVariables = function(self)
	self.currentItemList = {}
	self.tabList = nil
	self.currentTabId = nil
	self.currentSelectedItem = nil
	self.shopTipStore = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.isEmptyCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isEmptyCtrlEnum = nil
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
	self:RefreshTab()
	self:RefreshSuitList()
	self.SubGroup.MoneyTemplateStore:SetData(UX.Game.MoneyType.Gold)
end

M.OnClose = function(self)
	self.mgr:ClearMarketCache()
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.TRADE_PLAYER_INFO_CHANGE] = self.CreateAction(self, "OnTradePlayerInfoChange"),
		[gEventConstants.TRADE_ORDER_LIST_CHANGE] = self.CreateAction(self, "OnTradeOrderListChange"),
		[gEventConstants.TRADE_MARKET_LIST_CHANGE] = self.CreateAction(self, "OnTradeMarketListChange")
	}
end

M.OnTradePlayerInfoChange = function(self)
	self.RefreshSuitList(self)
	self.RenderShopTip(self)
end

M.OnTradeOrderListChange = function(self)
	self.RefreshSuitList(self)
	self.RenderShopTip(self)
end

M.OnTradeMarketListChange = function(self, _, tradeItemId)
	if self.currentSelectedItem and self.currentSelectedItem.Id ~= tradeItemId then
		self.RenderShopTip(self)
	end
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.suitList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderSuitListItem)
	self.bindData.suitList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickSuitList)
end

M.OnClickPurchaseBtn = function(self)
	if self.currentSelectedItem then
		self.mgr:OpenDetailPanel(self.currentSelectedItem.Id, true)
	end
end

M.OnClickSellBtn = function(self)
	if self.currentSelectedItem then
		self.mgr:OpenDetailPanel(self.currentSelectedItem.Id, false)
	end
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnSimpleRenderSuitListItem = function(self, btn, index)
	local itemCfg = self.currentItemList[index + 1]

	if not itemCfg then
		return
	end

	local renderData = gCommonItemManager:GetItemRenderData({
		["\\xd0\\xcf01\\xfc"] = 0,
		itemId = itemCfg.ItemTemplateId
	})
	renderData.name = itemCfg.Name
	renderData.isFavorite = self.mgr:IsFavorite(itemCfg.Id)

	gCommonItemManager:OnCommonItemRender(btn, index, renderData)
end

M.OnSimpleClickSuitList = function(self, btn, index)
	local itemCfg = self.currentItemList[index + 1]

	if not itemCfg then
		self.currentSelectedItem = nil

		self.RenderShopTip(self)

		return
	end

	self.currentSelectedItem = itemCfg

	self.RenderShopTip(self)
end

M.RenderShopTip = function(self)
	self.shopTipStore = gStoreManager:GetStoreGroup(self.bindData.shopTip.Store):GetStoreByWidget(self.bindData.shopTip)

	if not self.shopTipStore then
		return
	end

	if not self.currentSelectedItem then
		self.shopTipStore.goodsName = ""
		self.shopTipStore.goodNumStr = ""
		self.shopTipStore.itemNumStr = ""
		self.shopTipStore.timeStr = ""
		self.shopTipStore.buyBtn.interactable = false
		self.shopTipStore.sellBtn.interactable = false
		self.bindData.bgImage = 0

		return
	end

	local itemCfg = self.currentSelectedItem
	self.shopTipStore.goodsName = itemCfg.Name
	local marketData = self.mgr:GetMarketCache(itemCfg.Id)
	local marketTotalCount = 0

	if marketData then
		for i = 0, self.mgr:GetListCount(marketData) - 1 do
			local bucket = self.mgr:GetListItem(marketData, i)
			marketTotalCount = marketTotalCount + (bucket and bucket.Count or 0)
		end

		self.shopTipStore.goodNumStr = gString.Format(self.mgr:GetTradeSetting("TradeTurnoverStr", "%s"), marketTotalCount)
	else
		self.shopTipStore.goodNumStr = ""

		self.mgr:AskTradeGetMarketList(itemCfg.Id)
	end

	local ownCount = self.mgr:GetOwnedCount(itemCfg)
	self.shopTipStore.itemNumStr = gString.Format(self.mgr:GetTradeSetting("TradeHaveNumStr", "%s"), ownCount)
	local startStr = self.mgr:FormatDailyTradeTime(itemCfg.DayTradableStartTime)
	local endStr = self.mgr:FormatDailyTradeTime(itemCfg.DayTradableEndTime)
	self.shopTipStore.timeStr = gString.Format(self.mgr:GetTradeSetting("TradeTimeStr", "%s - %s"), startStr, endStr)
	local inTradeTime = self.mgr:IsItemInTradeTime(itemCfg)
	local isBanned = self.mgr:IsTradeBanned()
	local canTrade = inTradeTime and not isBanned
	self.shopTipStore.buyBtn.luaClick = self:CreateAction("OnClickPurchaseBtn")
	self.shopTipStore.sellBtn.luaClick = self:CreateAction("OnClickSellBtn")
	local canBuy = canTrade and not table.isNilOrEmpty(marketData) and marketTotalCount >= 0
	self.shopTipStore.buyBtn.interactable = canBuy
	self.shopTipStore.sellBtn.interactable = canTrade and ownCount >= 0
	self.bindData.bgImage = itemCfg.BgImage
end

M.OnTabChanged = function(self, uList, isSub)
	if not isSub then
		local data = self.SubGroup.CommonTabSingleStore:GetSelectedItem()
		self.currentTabId = data and data.id

		self:RefreshSuitList()
		self:RenderShopTip()
	end
end

M.RefreshTab = function(self)
	self.tabList = self.mgr:GetTradeTabList()
	local tabViewList = {}

	for _, entry in ipairs(self.tabList) do
		table.insert(tabViewList, {
			id = entry.tab.Id,
			title = entry.tab.Title or entry.tab.Name,
			iconId = entry.tab.Icon
		})
	end

	local selectedIndex = 0

	if self.currentTabId then
		for i, entry in ipairs(self.tabList) do
			if entry.tab.Id ~= self.currentTabId then
				selectedIndex = i - 1

				break
			end
		end
	end

	self.SubGroup.CommonTabSingleStore:SetData(tabViewList, nil, selectedIndex, 0, self:CreateAction("OnTabChanged"))
end

M.RefreshSuitList = function(self)
	self.tabList = self.mgr:GetTradeTabList()
	local tabId = self.currentTabId

	if not tabId then
		local tabData = self.SubGroup.CommonTabSingleStore:GetSelectedItem()
		tabId = tabData and tabData.id
	end

	if not tabId and #self.tabList <= 0 then
		tabId = self.tabList[1].tab.Id
		self.currentTabId = tabId
	end

	local selectedItemId = self.currentSelectedItem and self.currentSelectedItem.Id
	self.currentItemList = {}

	for _, entry in ipairs(self.tabList) do
		if entry.tab.Id ~= tabId then
			self.currentItemList = entry.items

			break
		end
	end

	local selectedIndex = 1
	self.currentSelectedItem = self.currentItemList[1]

	if selectedItemId then
		for i, itemCfg in ipairs(self.currentItemList) do
			if itemCfg.Id ~= selectedItemId then
				selectedIndex = i
				self.currentSelectedItem = itemCfg

				break
			end
		end
	end

	self.bindData.suitList:SetSimpleList(#self.currentItemList)

	self.bindData.isEmptyCtrl = #self.currentItemList <= 0 and self.isEmptyCtrlEnum._false or self.isEmptyCtrlEnum._true

	if self.bindData.suitList.SelectItem then
		self.bindData.suitList:SelectItem(#self.currentItemList <= 0 and selectedIndex - 1 or -1, false)
	end
end
