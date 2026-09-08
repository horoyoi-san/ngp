-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewTradingPostSellingListPanelStore.lua
-- Decompiled from: 00929_NewTradingPostSellingListPanelStore.lua_d44ff7246ea4.luajit

C_NewTradingPostSellingListPanelStore = DefClass("C_NewTradingPostSellingListPanelStore", C_NewTradingPostSellingListPanelStore, C_StoreGroup)
GroupName2Class.NewTradingPostSellingListPanelStore = C_NewTradingPostSellingListPanelStore
local M = C_NewTradingPostSellingListPanelStore
local DIRECTION_FIRST = 0
local INFO_LABEL_UID_ID = 89901845
local INFO_LABEL_RARITY_ID = 89901846
local INFO_UID_TIP_MSG_ID = 65920019
local INFO_GRADE_TIP_MSG_ID = 65920020

M.ctor = function(self)
	self.mgr = gTradeManager
end

M.DefineAllVariables = function(self)
	self.tradeId = nil
	self.tradeTabId = nil
	self.favoriteMode = false
	self.isBuy = true
	self.items = {}
	self.infoList = {}
	self.selectedItem = nil
	self.tradeItemIds = {}
	self.orderRequesting = {}
	self.orderRequested = {}
	self.orderRefreshTimer = nil
	self.showVersion = 0
	self.itemConfigCache = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.isEmptyCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.modeCtrlEnum = {
		["i'qW"] = 1,
		["\\x8c}"] = 0,
		["iw\\xbax^\\xbb\\xe6BGuzI"] = 2
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isEmptyCtrlEnum = nil
	self.modeCtrlEnum = nil
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
	self.showVersion = (self.showVersion or 0) + 1

	if self.orderRefreshTimer then
		self.orderRefreshTimer:Stop()

		self.orderRefreshTimer = nil
	end

	self.favoriteMode = data and data.favoriteMode ~= true or false
	self.tradeTabId = data and data.tradeTabId or nil
	self.tradeId = not self.favoriteMode and data and (data.tradeId or data.itemId or data.tradeItemId) or nil
	self.isBuy = not data or data.isBuy == false
	self.selectedItem = nil
	self.tradeItemIds = {}
	self.orderRequested = {}
	self.itemConfigCache = {}

	self:RefreshItems()
end

M.OnClose = function(self)
	self.showVersion = (self.showVersion or 0) + 1

	if self.orderRefreshTimer then
		self.orderRefreshTimer:Stop()

		self.orderRefreshTimer = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.TRADE_PLAYER_INFO_CHANGE] = self.CreateAction(self, "OnTradePlayerInfoChange"),
		[gEventConstants.TRADE_ORDER_LIST_CHANGE] = self.CreateAction(self, "OnTradeOrderListChange"),
		[gEventConstants.TRADE_MARKET_LIST_CHANGE] = self.CreateAction(self, "OnTradeMarketListChange"),
		[gEventConstants.TRADE_FAVORITE_LIST_CHANGE] = self.CreateAction(self, "OnTradeFavoriteListChange")
	}
end

M.OnTradePlayerInfoChange = function(self)
	self.RefreshItems(self)
end

M.OnTradeOrderListChange = function(self, _, tradeItemId)
	if self.favoriteMode then
		return
	end

	local clearedInFlight = false

	if tradeItemId then
		clearedInFlight = self.orderRequesting[tradeItemId] == nil
		self.orderRequesting[tradeItemId] = nil
	end

	if not tradeItemId or self.tradeItemIds[tradeItemId] or clearedInFlight then
		self.RefreshItems(self)
	end
end

M.OnTradeMarketListChange = function(self, _, tradeItemId)
	if tradeItemId and not self.IsCurrentItem(self, tradeItemId) then
		return
	end

	self.RenderSelectedItem(self)
end

M.OnTradeFavoriteListChange = function(self)
	if self.favoriteMode then
		self.RefreshItems(self)

		return
	end

	self.RenderSelectedItem(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.infoBtn.luaClick = self.CreateAction(self, "OnClickInfoBtn")
	self.bindData.collectBtn.luaClick = self.CreateAction(self, "OnClickCollectBtn")
	self.bindData.refreshBtn.luaClick = self.CreateAction(self, "OnClickRefreshBtn")
	self.bindData.infoList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderInfoListItem")
	self.bindData.sellItemList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderSellItemListItem")
	self.bindData.sellItemList.luaSelectedChanged = self.CreateAction(self, "OnSellItemListSelectedChanged")
	self.bindData.purchaseBtn.luaClick = self.CreateAction(self, "OnClickPurchaseBtn")
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickInfoBtn = function(self)
	if self.selectedItem then
		self.OpenSelectedDetail(self)
	end
end

M.OnClickCollectBtn = function(self)
	local tradeItemId = self.GetSelectedTradeItemId(self)

	if not tradeItemId then
		return
	end

	if self.mgr:IsFavorite(tradeItemId) then
		self.mgr:AskTradeFavoriteItems({
			tradeItemId
		}, nil)
	else
		self.mgr:AskTradeFavoriteItems(nil, {
			tradeItemId
		})
	end
end

M.OnClickRefreshBtn = function(self)
	local tradeItemId = self.GetSelectedTradeItemId(self)

	if not tradeItemId then
		return
	end

	if self.isBuy then
		self.mgr:AskTradeGetOrderList(tradeItemId, DIRECTION_FIRST)
	end

	self.mgr:AskTradeGetMarketList(tradeItemId)
end

M.RefreshItems = function(self)
	if self.favoriteMode then
		self.items = self.GetFavoriteItems(self)
	elseif self.isBuy then
		self.items = self.GetPurchasableItems(self)
	else
		self.items = self.GetSellableItems(self)
	end

	self.selectedItem = self.items[1]

	self.bindData.sellItemList:SetSimpleList(#self.items)
	self.bindData.sellItemList:SelectItem(0, true)
	self:ApplyEmptyCtrl()
	self:ApplyPurchaseCtrl()
	self:RenderHeader()
	self:RenderSelectedItem()
end

M.ScheduleOrderRefresh = function(self, showVersion)
	if showVersion == self.showVersion or self.orderRefreshTimer then
		return
	end

	self.orderRefreshTimer = FrameTimer.New(function ()
		self.orderRefreshTimer = nil

		if showVersion ~= self.showVersion then
			self:RefreshItems()
		end
	end, 1):Start()
end

M.GetPurchasableItems = function(self)
	local result = {}
	local requestTradeItemId = nil
	self.tradeItemIds = {}

	if not self.tradeId then
		return result
	end

	for _, item in ipairs(self.mgr:GetTradeItemsById(self.tradeId)) do
		local tradeItemId = item.Id
		self.tradeItemIds[tradeItemId] = true
		self.itemConfigCache[tradeItemId] = item
		local orderList = self.mgr:GetOrderListCache(tradeItemId)

		if orderList then
			for i = 0, self.GetListCount(self, orderList) - 1 do
				local order = self.GetListItem(self, orderList, i)

				if self.IsPurchasableOrder(self, order) then
					table.insert(result, order)
				end
			end
		elseif not self.orderRequested[tradeItemId] then
			requestTradeItemId = requestTradeItemId or tradeItemId
		end
	end

	if requestTradeItemId and not next(self.orderRequesting) then
		local showVersion = self.showVersion
		self.orderRequested[requestTradeItemId] = true
		self.orderRequesting[requestTradeItemId] = showVersion
		slot4 = self.mgr

		slot4:AskTradeGetOrderList(requestTradeItemId, DIRECTION_FIRST, function ()
			if self.orderRequesting[requestTradeItemId] == showVersion then
				return
			end

			self.orderRequesting[requestTradeItemId] = nil

			if self.STATE_OnShowOnce then
				self:ScheduleOrderRefresh(self.showVersion)
			end
		end)
	end

	table.sort(result, function (left, right)
		local leftPrice = left.Price or 0
		local rightPrice = right.Price or 0

		if leftPrice == rightPrice then
			return leftPrice <= rightPrice
		end

		return (left.ListTime or 0) >= (right.ListTime or 0)
	end)

	return result
end

M.GetSellableItems = function(self)
	local result = {}
	self.tradeItemIds = {}

	if not self.tradeId then
		return result
	end

	local handledSuitId = {}

	for _, itemConfig in ipairs(self.mgr:GetConcreteTradeItemsById(self.tradeId)) do
		local tradeItemId = itemConfig.Id
		self.tradeItemIds[tradeItemId] = true
		self.itemConfigCache[tradeItemId] = itemConfig

		if self.mgr:IsOrderTradeItem(itemConfig) then
			local suitId = itemConfig.FashionSuitId
			local alreadyHandled = suitId == nil and handledSuitId[suitId] ~= true

			if not alreadyHandled then
				if suitId == nil then
					handledSuitId[suitId] = true
				end

				local instances = self.mgr:GetFashionSuitInstances(itemConfig)

				for _, inst in ipairs(instances) do
					table.insert(result, inst)
				end
			end
		elseif self.GetSellableCount(self, itemConfig) <= 0 then
			table.insert(result, itemConfig)
		end
	end

	return result
end

M.GetSellableCount = function(self, itemConfig)
	if not itemConfig then
		return 0
	end

	if self.mgr:IsOrderTradeItem(itemConfig) then
		return #self.mgr:GetFashionSuitInstances(itemConfig)
	end

	if self.mgr:IsFashionTradeItem(itemConfig) then
		return self.mgr:GetFashionSellableRemainCount(itemConfig)
	end

	return self.mgr:GetOwnedCount(itemConfig)
end

M.IsPurchasableOrder = function(self, order)
	if not order or not order.OrderId or order.OrderId ~= 0 or (order.Count or 0) < 0 then
		return false
	end

	local now = self.mgr:GetServerUnixTime() or 0

	if (order.ExpireTime or 0) <= 0 and order.ExpireTime < now then
		return false
	end

	local extra = order.ItemExtraData

	if extra and now >= (extra.VisibleAfterTime or 0) then
		return false
	end

	local playerInfo = gPlayerManager and gPlayerManager.infoLogin
	local playerPid = playerInfo and playerInfo.bindData and playerInfo.bindData.pid

	if playerPid and order.SellerId ~= playerPid then
		return false
	end

	return true
end

M.ApplyEmptyCtrl = function(self)
	self.bindData.isEmptyCtrl = #self.items <= 0 and self.isEmptyCtrlEnum._false or self.isEmptyCtrlEnum._true
end

M.ApplyPurchaseCtrl = function(self)
	if self.favoriteMode then
		self.bindData.modeCtrl = self.modeCtrlEnum.favoriteMode
	elseif self.isBuy then
		self.bindData.modeCtrl = self.modeCtrlEnum.buy
	else
		self.bindData.modeCtrl = self.modeCtrlEnum.sell
	end
end

M.OnClickPurchaseBtn = function(self)
	if not self.isBuy then
		self.OpenSelectedDetail(self)

		return
	end

	if not self.CanPurchaseSelectedItem(self) then
		return
	end

	if self.favoriteMode then
		self.OpenSelectedDetail(self)

		return
	end

	self.mgr:AskTradeBuyOrder(self.selectedItem.OrderId, nil, self.selectedItem.TradeItemId)
end

M.CanPurchaseSelectedItem = function(self)
	local item = self.selectedItem

	if not self.isBuy or not item then
		return false
	end

	if self.favoriteMode then
		if self.mgr:IsTradeBanned() or not self.mgr:IsItemInTradeTime(self:GetItemConfig(item)) then
			return false
		end

		return self.HasMarketSupply(self, item)
	end

	if not item.OrderId or item.OrderId ~= 0 then
		return false
	end

	if self.mgr:IsTradeBanned() or not self.mgr:IsItemInTradeTime(self:GetItemConfig(item)) then
		return false
	end

	return self.IsPurchasableOrder(self, item)
end

M.CanSellSelectedItem = function(self)
	local item = self.selectedItem

	if self.isBuy or not item then
		return false
	end

	local itemConfig = self.GetItemConfig(self, item)

	if not itemConfig then
		return false
	end

	if self.mgr:IsTradeBanned() or not self.mgr:IsItemInTradeTime(itemConfig) then
		return false
	end

	return self:GetSellableCount(itemConfig) >= 0
end

M.GetFavoriteItems = function(self)
	local result = {}
	local favoriteIds = {}
	local favoriteSet = {}
	self.tradeItemIds = {}

	for _, entry in ipairs(self.mgr:GetTradeTabList()) do
		if entry.tab.Id ~= self.tradeTabId then
			slot9 = ipairs
			slot11 = entry.items or {}

			for _, tradeEntry in slot9(slot11) do
				local itemIds = tradeEntry.TradeItemIds

				if itemIds and #itemIds <= 0 then
					for _, itemId in ipairs(itemIds) do
						if self.mgr:IsFavorite(itemId) and not favoriteSet[itemId] then
							favoriteSet[itemId] = true

							table.insert(favoriteIds, itemId)
						end
					end
				elseif self.mgr:IsFavorite(tradeEntry.Id) and not favoriteSet[tradeEntry.Id] then
					favoriteSet[tradeEntry.Id] = true

					table.insert(favoriteIds, tradeEntry.Id)
				end
			end

			break
		end
	end

	local requestTradeItemId = nil

	for _, tradeItemId in ipairs(favoriteIds) do
		self.tradeItemIds[tradeItemId] = true
		local item = self.mgr:GetTradeItemsById(tradeItemId)[1]

		if item then
			self.itemConfigCache[tradeItemId] = item
			local orderList = self.mgr:GetOrderListCache(tradeItemId)

			if orderList then
				for i = 0, self.GetListCount(self, orderList) - 1 do
					local order = self.GetListItem(self, orderList, i)

					if self.IsPurchasableOrder(self, order) then
						table.insert(result, order)
					end
				end
			elseif not self.orderRequested[tradeItemId] then
				requestTradeItemId = requestTradeItemId or tradeItemId
			end
		end
	end

	if requestTradeItemId and not next(self.orderRequesting) then
		local showVersion = self.showVersion
		self.orderRequested[requestTradeItemId] = true
		self.orderRequesting[requestTradeItemId] = showVersion
		slot6 = self.mgr

		slot6:AskTradeGetOrderList(requestTradeItemId, DIRECTION_FIRST, function ()
			if self.orderRequesting[requestTradeItemId] == showVersion then
				return
			end

			self.orderRequesting[requestTradeItemId] = nil

			if self.STATE_OnShowOnce then
				self:ScheduleOrderRefresh(self.showVersion)
			end
		end)
	end

	table.sort(result, function (left, right)
		local leftPrice = left.Price or 0
		local rightPrice = right.Price or 0

		if leftPrice == rightPrice then
			return leftPrice <= rightPrice
		end

		return (left.ListTime or 0) >= (right.ListTime or 0)
	end)

	return result
end

M.GetItemIdentity = function(self, item)
	return item and (item.OrderId or item.InstanceId or item.Id) or nil
end

M.GetItemTradeItemId = function(self, item)
	return item and (item.TradeItemId or item.Id) or nil
end

M.GetItemConfig = function(self, item)
	if not item then
		return nil
	end

	if item.Config then
		return item.Config
	end

	if not item.OrderId then
		return item
	end

	local tradeItemId = item.TradeItemId
	local itemConfig = self.itemConfigCache[tradeItemId]

	if not itemConfig then
		itemConfig = self.mgr:GetTradeItemsById(tradeItemId)[1]
		self.itemConfigCache[tradeItemId] = itemConfig
	end

	return itemConfig
end

M.GetSelectedTradeItemId = function(self)
	return self.GetItemTradeItemId(self, self.selectedItem)
end

M.FindItem = function(self, identity)
	for _, item in ipairs(self.items) do
		if self.GetItemIdentity(self, item) ~= identity then
			return item
		end
	end

	return nil
end

M.GetItemIndex = function(self, identity)
	for index, item in ipairs(self.items) do
		if self.GetItemIdentity(self, item) ~= identity then
			return index - 1
		end
	end

	return nil
end

M.IsCurrentItem = function(self, tradeItemId)
	return self:GetSelectedTradeItemId() ~= tradeItemId
end

M.GetItem = function(self, index)
	return self.items[index + 1]
end

M.RenderHeader = function(self)
	local item = self.selectedItem or self.items[1]
	local itemConfig = self:GetItemConfig(item)

	if not itemConfig then
		self.bindData.nameLabel = ""

		self.RenderTradingItemView(self, nil)

		return
	end

	self.bindData.nameLabel = itemConfig.TradeName or self.mgr:GetTradeItemName(itemConfig)

	self:RenderTradingItemView(itemConfig)
end

M.RenderTradingItemView = function(self, itemConfig)
	local view = self.bindData.TradingItemView

	if not view then
		return
	end

	local store = gStoreManager:GetStoreGroup(view.Store):GetStoreByWidget(view)

	if not store then
		return
	end

	if not itemConfig then
		store.nameLabel = ""
		store.itemIcon = 0
		store.itemNum = ""
		store.tagLabel = ""
		store.qualityCtrl = 0

		return
	end

	store.nameLabel = itemConfig.TradeName or self.mgr:GetTradeItemName(itemConfig)
	store.itemIcon = itemConfig.ProductIcon or self.mgr:GetTradeItemIcon(itemConfig)
	store.itemNum = ""
	store.tagLabel = ""
	store.qualityCtrl = 0
end

M.BuildItemInfoList = function(self, item, itemConfig)
	local uid = self:GetItemUid(item)

	table.insert(self.infoList, {
		label = self:GetScriptText(INFO_LABEL_UID_ID),
		value = ulong.check(uid) and ulong.tostring(uid) or tostring(uid),
		tipMsgId = INFO_UID_TIP_MSG_ID
	})
	table.insert(self.infoList, {
		label = self:GetScriptText(INFO_LABEL_RARITY_ID),
		value = self:GetFashionSuitGradeText(itemConfig),
		tipMsgId = INFO_GRADE_TIP_MSG_ID
	})
end

M.GetScriptText = function(self, textId)
	local cfg = LTConfig.TextScriptTextConfig.GetConfig(textId)

	return cfg and cfg.Text or ""
end

M.GetItemUid = function(self, item)
	if not item then
		return 0
	end

	if item.InstanceId then
		return item.InstanceId
	end

	local extra = item.ItemExtraData

	if extra and extra.FashionSuitInstanceId then
		return extra.FashionSuitInstanceId
	end

	return item.OrderId or item.Id or 0
end

M.GetFashionSuitGradeText = function(self, itemConfig)
	if not itemConfig then
		return ""
	end

	local suitId = itemConfig.FashionSuitId

	if not suitId or suitId ~= 0 then
		return ""
	end

	local suitCfg = LTConfig.FashionSuitConfig.GetConfig(suitId)
	local gradeId = suitCfg and suitCfg.FashionGrade or 0

	if gradeId ~= 0 then
		return ""
	end

	local gradeCfg = LTConfig.FashionGradeConfig.GetConfig(gradeId)

	return gradeCfg and gradeCfg.Name or ""
end

M.RenderSelectedItem = function(self)
	local item = self.selectedItem
	local itemConfig = self.GetItemConfig(self, item)
	self.infoList = {}

	if itemConfig then
		self.BuildItemInfoList(self, item, itemConfig)
	end

	self.bindData.infoList:SetSimpleList(#self.infoList)

	if not itemConfig then
		self.bindData.collectBtn.interactable = false
		self.bindData.collectBtn.isSelected = false
		self.bindData.purchaseBtn.interactable = false

		self.RefreshCountDown(self, nil)

		return
	end

	self:RenderHeader()

	self.bindData.collectBtn.interactable = true
	self.bindData.purchaseBtn.interactable = self.isBuy and self:CanPurchaseSelectedItem() or self:CanSellSelectedItem()
	local tradeItemId = self:GetItemTradeItemId(item)
	self.bindData.collectBtn.isSelected = self.mgr:IsFavorite(tradeItemId)
	local market = self.mgr:GetMarketCache(tradeItemId)
	local price = item.OrderId and (item.Price or 0) or self:GetMarketMinPrice(market) or self.mgr:GetTradeItemMinPrice(itemConfig)

	gCommonItemManager:OnRenderMoneyItem(self.bindData.singlePrice, UX.Game.MoneyType.Gold, {
		count = price
	})
	self:RefreshCountDown(item)

	if not market then
		self.mgr:AskTradeGetMarketList(tradeItemId)
	end
end

M.RefreshCountDown = function(self, item)
	local countDown = self.bindData.timeCountDown

	if not countDown then
		return
	end

	local expireTime = item and item.ExpireTime or 0
	local now = self.mgr:GetServerUnixTime() or 0
	local remain = expireTime - now

	if expireTime <= 0 and remain <= 0 then
		countDown.Play(countDown, remain)
	else
		countDown.Stop(countDown)
	end
end

M.GetMarketMinPrice = function(self, market)
	local minPrice = nil

	for i = 0, self.GetListCount(self, market) - 1 do
		local bucket = self.GetListItem(self, market, i)

		if bucket and (bucket.Count or 0) <= 0 then
			local price = bucket.MinPrice or bucket.MaxPrice or 0

			if not minPrice or price >= minPrice then
				minPrice = price
			end
		end
	end

	return minPrice
end

M.HasMarketSupply = function(self, item)
	local tradeItemId = self.GetItemTradeItemId(self, item)

	if not tradeItemId then
		return false
	end

	local market = self.mgr:GetMarketCache(tradeItemId)

	if not market then
		return true
	end

	for i = 0, self.GetListCount(self, market) - 1 do
		local bucket = self.GetListItem(self, market, i)

		if bucket and (bucket.Count or 0) <= 0 then
			return true
		end
	end

	return false
end

M.OnSimpleRenderInfoListItem = function(self, btn, index)
	local data = self.infoList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.descLabel = data.value
	store.nameLabel = data.label

	if store.detailBtn then
		store.detailBtn.luaRenderTooltip = self.CreateActionWithArgs(self, "OnRenderInfoDetailTooltip", data.tipMsgId)
		store.detailBtn.luaTooltipPopup = self.CreateAction(self, "OnInfoDetailTooltipClose")
	end
end

M.OnRenderInfoDetailTooltip = function(self, msgId, btn, popup, index)
	local store = gStoreManager:GetStoreGroup(popup.Store):GetStoreByWidget(popup)

	if not store then
		return
	end

	local cfg = LTConfig.MessageExplainConfig.GetConfig(msgId)
	store.descLabel = cfg and cfg.Content or ""
end

M.OnInfoDetailTooltipClose = function(self, btn, popup, index)
	if not popup then
		btn.SetSelected(btn, false)
	end
end

M.OnSimpleRenderSellItemListItem = function(self, btn, index)
	local item = self.GetItem(self, index)
	local itemConfig = self.GetItemConfig(self, item)

	if not itemConfig then
		return
	end

	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = self.mgr:GetTradeItemConsumableId(itemConfig),
		itemNum = self:GetSellItemNum(item, itemConfig)
	})
	local store = gCommonItemManager:OnCommonItemRender(btn, index, renderData)

	if not store then
		return
	end

	btn.enabledTooltip = false
	store.nameLabel = self.mgr:GetTradeItemName(itemConfig)
	local market = self.mgr:GetMarketCache(self:GetItemTradeItemId(item))
	local price = item.OrderId and (item.Price or 0) or self:GetMarketMinPrice(market) or self.mgr:GetTradeItemMinPrice(itemConfig)
	store.priceText = gCommonItemManager:GetMoneyRichTextIcon(UX.Game.MoneyType.Gold) .. tostring(gCommonItemManager:BuildLargeNum(price))
end

M.GetSellItemNum = function(self, item, itemConfig)
	if item and item.Count == nil then
		return item.Count
	end

	if item and item.InstanceId then
		return 1
	end

	return self.GetSellableCount(self, itemConfig)
end

M.OnSellItemListSelectedChanged = function(self, list)
	local item = self.GetItem(self, list.selectedIndex)

	if not item or item ~= self.selectedItem then
		return
	end

	self.selectedItem = item

	self.RenderSelectedItem(self)
end

M.OpenSelectedDetail = function(self)
	local item = self.selectedItem
	local itemConfig = self.GetItemConfig(self, item)

	if not itemConfig then
		return
	end

	if not self.isBuy and self.mgr:IsOrderTradeItem(itemConfig) then
		local instanceId = item and item.InstanceId

		if not instanceId then
			local instances = self.mgr:GetFashionSuitInstances(itemConfig)
			instanceId = instances[1] and instances[1].InstanceId
		end

		if instanceId then
			local panelId = gPanelId.TRADING_POST_SELL_WINDOW or gPanelId.PURCHAS_PANEL

			gPanelManager:CheckShow(panelId, {
				["D\\xbd\\x80\\xba\\xaf"] = false,
				tradeItemId = itemConfig.Id,
				instanceId = instanceId
			})

			return
		end
	end

	self.mgr:OpenDetailPanel(itemConfig.Id, self.isBuy)
end

M.GetListCount = function(self, list)
	if not list then
		return 0
	end

	if type(list) ~= "table" then
		return #list
	end

	return list.Count
end

M.GetListItem = function(self, list, index)
	if not list then
		return nil
	end

	if type(list) ~= "table" then
		return list[index + 1]
	end

	return list[index]
end
