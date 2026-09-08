-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ShopDoubleConfirmPanelStore.lua
-- Decompiled from: 01315_ShopDoubleConfirmPanelStore.lua_fe9800aada8d.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local MessageConfig = LTConfig.MessageConfig
local FashionConfig = LTConfig.FashionConfig
local CART_FLUSH_DELAY = 0.5
local CART_DRAG_THRESHOLD = 100
C_ShopDoubleConfirmPanelStore = DefClass("C_ShopDoubleConfirmPanelStore", C_ShopDoubleConfirmPanelStore, C_StoreGroup)
GroupName2Class.ShopDoubleConfirmPanelStore = C_ShopDoubleConfirmPanelStore
local M = C_ShopDoubleConfirmPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.mode = self.pageCtrlEnum.ShoppingCart
	self.cartItems = {}
	self.confirmItems = {}
	self.pendingSetCart = {}
	self.flushTimer = nil
	self.onSuccess = nil
	self.cartTemplateStores = {}
	self.confirmTemplateStores = {}
	self.showingDeleteBtn = nil
	self.chargeData = nil
	self.hasShownEmptyStoreMsg = false
	self.preRechargeMode = nil
	self.quickChargeContext = nil
	self.waitingQuickCharge = false
	self.isQuickChargeBuying = false
	self.customConfirm = nil
	self.bundlePriceOverride = nil
	self.onChargeMore = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.pageCtrlEnum = {
		["\\xb2:\\xff\\xbf[)\\xd5^#\\xc7\\xe0%EQ\\xcb5\\xb5\\xc4\r"] = 2,
		["2\\x9f\\xfd\\xbb\\xae桙\\x89\\xcf\\xf6ǔ!\\x98\\xe7"] = 3,
		["\\xb0*δR:\\xc1^#\\xc7\\xe0%EQ\\xcb5\\xb5\\xc4\r"] = 1,
		["\\~\\xa3g\\\\xbb\\xfc@I{lX"] = 0
	}
	self.shoppingCartEmptyCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
	self.discountCtrlEnum = {
		["\\xa4\\xa3\\xacc0\\xff?"] = 1,
		["\\xaf\\xb8\\xa8e+\\xf0'"] = 0
	}
	self.lackMoneyCtrlEnum = {
		["\\xcb"] = 0,
		["\\xd9"] = 1
	}
	self.showDeleteCtrlEnum = {
		["\\xcb"] = 0,
		["\\xd9"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.pageCtrlEnum = nil
	self.shoppingCartEmptyCtrlEnum = nil
	self.discountCtrlEnum = nil
	self.lackMoneyCtrlEnum = nil
	self.showDeleteCtrlEnum = nil
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
	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self:DefineAllVariables()

	self.mode = data and data.mode or self.pageCtrlEnum.ShoppingCart
	self.onSuccess = data and data.onSuccess or nil
	self.onChargeMore = data and data.onChargeMore or nil

	if self.mode ~= self.pageCtrlEnum.ReChargeConfirmation and not gSwitchFunctionManager:CheckEnable(gSwitchFunctionId.MALL_QUICK_CHARGE) then
		gPanelManager:Close(self.m_Id)

		return
	end

	if self.mode ~= self.pageCtrlEnum.PurchaseConfirmation then
		self.confirmItems = self:CloneInstantItems(data and data.instantItems)
		self.customConfirm = data and data.customConfirm or nil
		self.bundlePriceOverride = data and data.bundlePriceOverride or nil
	elseif self.mode ~= self.pageCtrlEnum.ReChargeConfirmation then
		if data and data.quickChargeContext then
			self.SetQuickChargeContext(self, data.quickChargeContext)
		end

		self.InitRechargeConfirmationData(self)
	else
		self.LoadCartItemsFromServer(self)
	end

	self.RegisterMessageEvents(self, self.msgEvents)
	self.ApplyMode(self)
	self.RefreshAll(self)
end

M.OnClose = function(self)
	self.FlushCartChangesNow(self)
	self.ClearMessageEvents(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.MALL_CART_CHANGE] = self.CreateAction(self, self.OnMallCartChange),
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, self.OnPackItemChanged),
		[gEventConstants.MONEY_CHANGE] = self.CreateAction(self, self.OnQuickChargeMoneyChanged),
		[gEventConstants.SYNC_CHARGE_INFO] = self.CreateAction(self, self.OnQuickChargeInfoChanged)
	}
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.cartCheckAllBtn.luaClick = self.CreateAction(self, self.OnClickCartCheckAllBtn)
	self.bindData.confirmCheckAllBtn.luaClick = self.CreateAction(self, self.OnClickConfirmCheckAllBtn)
	self.bindData.chargeMoreBtn.luaClick = self.CreateAction(self, self.OnClickChargeMoreBtn)

	if self.bindData.chargeBtn then
		self.bindData.chargeBtn.luaClick = self.CreateAction(self, self.OnClickChargeBtn)
	end

	if self.bindData.settingBtn then
		self.bindData.settingBtn.luaClick = self.CreateAction(self, self.OnClickSettingBtn)
	end

	if self.bindData.cartList then
		self.bindData.cartList.luaDynamicRenderItem = self.CreateAction(self, self.OnDynamicRenderCartItem)
		self.bindData.cartList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderCartItem)

		self.bindData.cartList.onGetTIndex = function()
			return 2
		end
	end

	if self.bindData.confirmList then
		self.bindData.confirmList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderConfirmItem)
	end
end

M.CloneInstantItems = function(self, srcItems)
	local result = {}

	if not srcItems then
		return result
	end

	for _, e in ipairs(srcItems) do
		table.insert(result, {
			["\\xad\\xa3\n\\xa6I?\\xec'"] = false,
			commodityData = e.commodityData,
			count = e.count or 1,
			selected = e.selected == false
		})
	end

	return result
end

M.LoadCartItemsFromServer = function(self)
	self.cartItems = {}
	local list = gMallManager:GetCartCommodityList()

	for _, e in ipairs(list) do
		table.insert(self.cartItems, {
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			["\\xad\\xa3\n\\xa6I?\\xec'"] = true,
			commodityData = e.commodityData,
			count = e.count or 1
		})
	end
end

M.ApplyMode = function(self)
	self.bindData.pageCtrl = self.mode
end

M.IsRechargeConfirmationMode = function(self)
	return self.mode ~= self.pageCtrlEnum.ReChargeConfirmation
end

M.SwitchMode = function(self, newMode)
	self.mode = newMode

	self.ApplyMode(self)
	self.RefreshAll(self)
end

M.SwitchToRechargeConfirmation = function(self)
	if not gSwitchFunctionManager:CheckEnable(gSwitchFunctionId.MALL_QUICK_CHARGE) then
		return
	end

	if self.mode == self.pageCtrlEnum.ReChargeConfirmation then
		self.preRechargeMode = self.mode
	end

	self.InitRechargeConfirmationData(self)
	self.SwitchMode(self, self.pageCtrlEnum.ReChargeConfirmation)
end

M.RefreshAll = function(self)
	self.RefreshList(self)
	self.RefreshCartNumber(self)
	self.RefreshAllCheckButtons(self)
	self.RefreshMoneyDisplay(self)
	self.RefreshChargeBtn(self)
	self.RefreshSettingBtn(self)
end

M.RefreshList = function(self)
	if self.IsRechargeConfirmationMode(self) then
		return
	end

	if self.mode ~= self.pageCtrlEnum.ShoppingCart or self.mode ~= self.pageCtrlEnum.shoppingCartManage then
		if self.bindData.cartList then
			self.bindData.cartList:SetSimpleList(#self.cartItems)
		end

		self.bindData.shoppingCartEmptyCtrl = #self.cartItems ~= 0 and 0 or 1
	elseif self.mode ~= self.pageCtrlEnum.PurchaseConfirmation and self.bindData.confirmList then
		local alignment = #self.confirmItems ~= 1 and 1 or 0
		self.bindData.confirmList.horizontalAlignment = alignment
		self.bindData.confirmList.verticalAlignment = alignment

		self.bindData.confirmList:SetSimpleList(#self.confirmItems)
	end
end

M.SetSelectedCtrl = function(self, btn, selected)
	if not btn or not btn.Store then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.selectedCtrl = selected and 1 or 0
	end
end

M.BindCartTemplateExtras = function(self, store, entry, isCart, luaIndex, btn)
	local cd = entry.commodityData
	local actualPrice = gMallManager:GetCommodityActualPrice(cd)
	local moneyCfg = cd.moneyItemId and ConsumableConfig.GetConfig(cd.moneyItemId)

	if store then
		store.icon = cd.iconId == 0 and cd.iconId or cd.icon
		store.quality = cd.quality or 1
		store.iconBg = cd.Background or 0
		store.goodsName = cd.name or ""
		store.price = tostring(actualPrice)
		store.moneyIcon = moneyCfg and moneyCfg.SMoneyIconId or 0
		store.typeCtrl = gMallManager:GetCartTypeCtrl(cd)
		store.numText = tostring(entry.count or 1)
		store.pageCtrl = self.pageCtrlEnum.shoppingCartManage
		store.discountCtrl = cd.price and actualPrice >= cd.price and 0 or 1
		store.deleteCtrl = 1
	end

	self:SetSelectedCtrl(store.checkBox, entry.selected)

	local checkClickName = isCart and "OnCartCheckBoxClick" or "OnConfirmCheckBoxClick"
	local addClickName = isCart and "OnCartAddClick" or "OnConfirmAddClick"
	local reduceClickName = isCart and "OnCartReduceClick" or "OnConfirmReduceClick"
	local deleteClickName = isCart and "OnCartDeleteClick" or "OnConfirmDeleteClick"

	if store.checkBox then
		store.checkBox.luaClick = self.CreateActionWithArgs(self, checkClickName, luaIndex)
	end

	local changeable = gMallManager:IsCommodityCountChangeable(cd)

	if store.addBtn then
		store.addBtn.gameObject:SetActive(changeable)

		store.addBtn.luaClick = self:CreateActionWithArgs(addClickName, luaIndex)
	end

	if store.reduceBtn then
		store.reduceBtn.gameObject:SetActive(changeable)

		store.reduceBtn.luaClick = self:CreateActionWithArgs(reduceClickName, luaIndex)
	end

	if store.deleteBtn then
		store.deleteBtn.luaClick = self.CreateActionWithArgs(self, deleteClickName, luaIndex)
		store.deleteBtn.transform.localScale = Vector3.New(0, 1, 1)
	end

	self:BindCartDragEvents(btn, store)
	self:RefreshCountButtonInteractable(store, cd, entry.count or 1)
	self:BindCartItemSubList(store, cd)
end

M.HideShowingDeleteBtn = function(self)
	if self.showingDeleteBtn then
		self.showingDeleteBtn.transform.localScale = Vector3.New(0, 1, 1)
		self.showingDeleteBtn = nil
	end
end

M.BindCartDragEvents = function(self, btn, store)
	if not store or not store.deleteBtn then
		return
	end

	local deleteBtn = store.deleteBtn
	local dragAccum = 0
	local curScale = 0
	local self_ = self

	local onBeginDrag = function()
		dragAccum = 0

		if self_.showingDeleteBtn and self_.showingDeleteBtn == deleteBtn then
			self_:HideShowingDeleteBtn()
		end
	end

	local onDrag = function(eventData)
		dragAccum = dragAccum + eventData.delta.x
		local t = math.max(0, math.min(1, curScale - dragAccum / CART_DRAG_THRESHOLD))
		deleteBtn.transform.localScale = Vector3.New(t, 1, 1)
	end

	local onEndDrag = function()
		local t = math.max(0, math.min(1, curScale - dragAccum / CART_DRAG_THRESHOLD))
		curScale = t > 0.5 and 1 or 0
		deleteBtn.transform.localScale = Vector3.New(curScale, 1, 1)

		if curScale ~= 1 then
			self_.showingDeleteBtn = deleteBtn
		elseif self_.showingDeleteBtn ~= deleteBtn then
			self_.showingDeleteBtn = nil
		end

		dragAccum = 0
	end

	if btn then
		local btnDrag = SGUI.EventSystems.DragEventListener.Get(btn.gameObject)
		btnDrag.onBeginDrag = onBeginDrag
		btnDrag.onDrag = onDrag
		btnDrag.onEndDrag = onEndDrag
	end

	local deleteBtnDrag = SGUI.EventSystems.DragEventListener.Get(deleteBtn.gameObject)
	deleteBtnDrag.onBeginDrag = onBeginDrag
	deleteBtnDrag.onDrag = onDrag
	deleteBtnDrag.onEndDrag = onEndDrag
end

M.RefreshCountButtonInteractable = function(self, store, commodityData, count)
	if not store then
		return
	end

	local changeable = gMallManager:IsCommodityCountChangeable(commodityData)
	local maxBuyable = gMallManager:GetMaxBuyableCount(commodityData)

	if store.addBtn then
		local canIncrease = changeable and (maxBuyable ~= nil or count <= maxBuyable)
		store.addBtn.interactable = canIncrease
	end

	if store.reduceBtn then
		store.reduceBtn.interactable = changeable and count >= 1
	end
end

M.BindCartItemSubList = function(self, store, commodityData)
	if not store.itemList then
		return
	end

	local fashionIdList = gMallManager:GetSuitFashionIdList(commodityData)

	if fashionIdList and #fashionIdList <= 0 then
		store.itemList.gameObject:SetActive(true)

		store.itemList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderFashionSubItem", fashionIdList)

		store.itemList:SetSimpleList(#fashionIdList)
	else
		store.itemList:SetSimpleList(0)
		store.itemList.gameObject:SetActive(false)
	end
end

M.OnRenderFashionSubItem = function(self, fashionIdList, btn, index)
	if not fashionIdList then
		return
	end

	local fashionId = fashionIdList[index + 1]

	if not fashionId or fashionId ~= 0 then
		return
	end

	local fashionCfg = FashionConfig.GetConfig(fashionId)
	local subStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not subStore then
		return
	end

	if subStore then
		subStore.iconId = fashionCfg and fashionCfg.Icon or 0
		subStore.quality = fashionCfg and fashionCfg.Quality or 1
		subStore.count = ""
		subStore.isOwned = fashionCfg and gDressManager:IsFashionHad(fashionId) and 1 or 0
	end

	btn.enabledTooltip = false
end

M.OnDynamicRenderCartItem = function(self, btn, index)
	self.OnSimpleRenderCartItem(self, btn, index)
end

M.OnSimpleRenderCartItem = function(self, btn, index)
	local luaIndex = index + 1
	local entry = self.cartItems[luaIndex]

	if not entry then
		return
	end

	btn.enabledTooltip = nil
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	self.cartTemplateStores[luaIndex] = store

	self.BindCartTemplateExtras(self, store, entry, true, luaIndex, btn)
end

M.OnSimpleRenderConfirmItem = function(self, btn, index)
	local luaIndex = index + 1
	local entry = self.confirmItems[luaIndex]

	if not entry then
		return
	end

	btn.enabledTooltip = nil
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	self.confirmTemplateStores[luaIndex] = store

	self.BindCartTemplateExtras(self, store, entry, false, luaIndex, btn)
end

M.OnCartCheckBoxClick = function(self, luaIndex)
	self.HideShowingDeleteBtn(self)

	local entry = self.cartItems[luaIndex]

	if not entry then
		return
	end

	entry.selected = not entry.selected
	local store = self.cartTemplateStores[luaIndex]

	if store then
		self.SetSelectedCtrl(self, store.checkBox, entry.selected)
	end

	self.RefreshCartCheckAllButton(self)
	self.RefreshMoneyDisplay(self)
	self.RefreshSettingBtn(self)
end

M.OnCartAddClick = function(self, luaIndex)
	self.HideShowingDeleteBtn(self)

	local entry = self.cartItems[luaIndex]

	if not entry then
		return
	end

	if not gMallManager:IsCommodityCountChangeable(entry.commodityData) then
		return
	end

	local maxBuyable = gMallManager:GetMaxBuyableCount(entry.commodityData)

	if maxBuyable == nil and maxBuyable < (entry.count or 1) then
		return
	end

	entry.count = (entry.count or 1) + 1
	local store = self.cartTemplateStores[luaIndex]

	if store then
		store.numText = tostring(entry.count)

		self.RefreshCountButtonInteractable(self, store, entry.commodityData, entry.count)
	end

	if entry.commodityData.id then
		self.pendingSetCart[entry.commodityData.id] = entry.count

		self.ScheduleFlush(self)
	end

	if entry.selected then
		self.RefreshMoneyDisplay(self)
	end
end

M.OnCartReduceClick = function(self, luaIndex)
	self.HideShowingDeleteBtn(self)

	local entry = self.cartItems[luaIndex]

	if not entry then
		return
	end

	if not gMallManager:IsCommodityCountChangeable(entry.commodityData) then
		return
	end

	if (entry.count or 1) < 1 then
		return
	end

	entry.count = entry.count - 1
	local store = self.cartTemplateStores[luaIndex]

	if store then
		store.numText = tostring(entry.count)

		self.RefreshCountButtonInteractable(self, store, entry.commodityData, entry.count)
	end

	if entry.commodityData.id then
		self.pendingSetCart[entry.commodityData.id] = entry.count

		self.ScheduleFlush(self)
	end

	if entry.selected then
		self.RefreshMoneyDisplay(self)
	end
end

M.OnCartDeleteClick = function(self, luaIndex)
	self.showingDeleteBtn = nil
	local entry = self.cartItems[luaIndex]

	if not entry or not entry.commodityData or not entry.commodityData.id then
		return
	end

	self:FlushCartChangesNow()
	gMallManager:RemoveFromCart({
		entry.commodityData.id
	})
	table.remove(self.cartItems, luaIndex)
	self:RefreshAll()
end

M.OnConfirmCheckBoxClick = function(self, luaIndex)
	self.HideShowingDeleteBtn(self)

	local entry = self.confirmItems[luaIndex]

	if not entry then
		return
	end

	entry.selected = not entry.selected
	local store = self.confirmTemplateStores[luaIndex]

	if store then
		self.SetSelectedCtrl(self, store.checkBox, entry.selected)
	end

	self.RefreshConfirmCheckAllButton(self)
	self.RefreshMoneyDisplay(self)
end

M.OnConfirmAddClick = function(self, luaIndex)
	self.HideShowingDeleteBtn(self)

	local entry = self.confirmItems[luaIndex]

	if not entry then
		return
	end

	if not gMallManager:IsCommodityCountChangeable(entry.commodityData) then
		return
	end

	local maxBuyable = gMallManager:GetMaxBuyableCount(entry.commodityData)

	if maxBuyable == nil and maxBuyable < (entry.count or 1) then
		return
	end

	entry.count = (entry.count or 1) + 1
	local store = self.confirmTemplateStores[luaIndex]

	if store then
		store.numText = tostring(entry.count)

		self.RefreshCountButtonInteractable(self, store, entry.commodityData, entry.count)
	end

	if entry.fromCart and entry.commodityData.id then
		self.pendingSetCart[entry.commodityData.id] = entry.count

		self.ScheduleFlush(self)
	end

	if entry.selected then
		self.RefreshMoneyDisplay(self)
	end
end

M.OnConfirmReduceClick = function(self, luaIndex)
	self.HideShowingDeleteBtn(self)

	local entry = self.confirmItems[luaIndex]

	if not entry then
		return
	end

	if not gMallManager:IsCommodityCountChangeable(entry.commodityData) then
		return
	end

	if (entry.count or 1) < 1 then
		return
	end

	entry.count = entry.count - 1
	local store = self.confirmTemplateStores[luaIndex]

	if store then
		store.numText = tostring(entry.count)

		self.RefreshCountButtonInteractable(self, store, entry.commodityData, entry.count)
	end

	if entry.fromCart and entry.commodityData.id then
		self.pendingSetCart[entry.commodityData.id] = entry.count

		self.ScheduleFlush(self)
	end

	if entry.selected then
		self.RefreshMoneyDisplay(self)
	end
end

M.OnConfirmDeleteClick = function(self, luaIndex)
	self.showingDeleteBtn = nil

	table.remove(self.confirmItems, luaIndex)

	if #self.confirmItems ~= 0 then
		gPanelManager:Close(self.m_Id)

		return
	end

	self.RefreshAll(self)
end

M.GetCurrentList = function(self)
	if self.mode ~= self.pageCtrlEnum.PurchaseConfirmation then
		return self.confirmItems
	end

	return self.cartItems
end

M.GetAllChecked = function(self, list)
	if not list or #list ~= 0 then
		return false
	end

	for _, e in ipairs(list) do
		if not e.selected then
			return false
		end
	end

	return true
end

M.SetAllChecked = function(self, list, checked)
	for _, e in ipairs(list) do
		e.selected = checked
	end

	local stores = list ~= self.cartItems and self.cartTemplateStores or self.confirmTemplateStores

	for i, _ in ipairs(list) do
		local store = stores[i]

		if store then
			self.SetSelectedCtrl(self, store.checkBox, checked)
		end
	end
end

M.RefreshCheckAllButton = function(self, btn, list)
	if not btn then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.selectedCtrl = self:GetAllChecked(list) and 1 or 0
end

M.RefreshCartCheckAllButton = function(self)
	self.RefreshCheckAllButton(self, self.bindData.cartCheckAllBtn, self.cartItems)
end

M.RefreshConfirmCheckAllButton = function(self)
	self.RefreshCheckAllButton(self, self.bindData.confirmCheckAllBtn, self.confirmItems)
end

M.RefreshAllCheckButtons = function(self)
	self.RefreshCartCheckAllButton(self)
	self.RefreshConfirmCheckAllButton(self)
end

M.OnClickCartCheckAllBtn = function(self)
	self.HideShowingDeleteBtn(self)

	local checked = not self.GetAllChecked(self, self.cartItems)

	self.SetAllChecked(self, self.cartItems, checked)
	self.RefreshCartCheckAllButton(self)
	self.RefreshMoneyDisplay(self)
	self.RefreshSettingBtn(self)
end

M.OnClickConfirmCheckAllBtn = function(self)
	self.HideShowingDeleteBtn(self)

	local checked = not self.GetAllChecked(self, self.confirmItems)

	self.SetAllChecked(self, self.confirmItems, checked)
	self.RefreshConfirmCheckAllButton(self)
	self.RefreshMoneyDisplay(self)
end

M.RefreshCartNumber = function(self)
	self.bindData.cartNumberText = string.format("(%d)", #self.cartItems)
end

M.RefreshMoneyDisplay = function(self)
	self.RefreshHaveNumList(self)

	if self.IsRechargeConfirmationMode(self) then
		self.RefreshQuickChargeMoneyDisplay(self)

		return
	end

	if self.bundlePriceOverride then
		local bp = self.bundlePriceOverride
		local moneyCfg = ConsumableConfig.GetConfig(bp.moneyItemId)
		self.bindData.moneyIconId = moneyCfg and moneyCfg.SMoneyIconId or 0
		self.bindData.nowPriceText = tostring(bp.totalPrice)
		self.bindData.originPriceText = tostring(bp.originPrice)
		self.bindData.discountCtrl = bp.totalPrice >= bp.originPrice and 0 or 1
		local have = gCommonItemManager:GetPackItemNum(bp.moneyItemId) or 0
		local lack = math.max(0, bp.totalPrice - have)
		self.bindData.lackMoneyNumText = tostring(lack)
		self.bindData.lackMoneyCtrl = lack <= 0 and 1 or 0

		gCommonItemManager:OnRenderMoneyItem(self.bindData.lackMoney, bp.moneyItemId, {
			count = lack
		})

		return
	end

	local list = self:GetCurrentList()
	local groups = gMallManager:AggregateMoneyByItemId(list)

	if #groups ~= 0 then
		local defaultMoneyId = ConsumableConfig.RewardBindingGold
		local moneyCfg = ConsumableConfig.GetConfig(defaultMoneyId)
		self.bindData.moneyIconId = moneyCfg and moneyCfg.SMoneyIconId or 0
		self.bindData.nowPriceText = "0"
		self.bindData.originPriceText = "0"
		self.bindData.lackMoneyNumText = "0"
		self.bindData.lackMoneyCtrl = 0
		self.bindData.discountCtrl = 1

		gCommonItemManager:OnRenderMoneyItem(self.bindData.lackMoney, defaultMoneyId, {
			["N\\xa1\\xb7\\xa1\\xa2"] = 0
		})

		return
	end

	local g = groups[1]
	local moneyCfg = ConsumableConfig.GetConfig(g.moneyItemId)
	self.bindData.moneyIconId = moneyCfg and moneyCfg.SMoneyIconId or 0
	self.bindData.nowPriceText = tostring(g.totalPrice)
	self.bindData.originPriceText = tostring(g.totalOriginPrice)
	self.bindData.discountCtrl = g.totalOriginPrice and g.totalPrice >= g.totalOriginPrice and 0 or 1
	self.bindData.lackMoneyNumText = tostring(g.lack or 0)
	self.bindData.lackMoneyCtrl = g.lack and g.lack <= 0 and 1 or 0

	gCommonItemManager:OnRenderMoneyItem(self.bindData.lackMoney, g.moneyItemId, {
		count = g.lack or 0
	})
end

M.RefreshHaveNumList = function(self)
	if not self.SubGroup or not self.SubGroup.MoneyTemplateStore then
		return
	end

	if self.IsRechargeConfirmationMode(self) then
		self.SubGroup.MoneyTemplateStore:SetData({
			{
				Type = ConsumableConfig.RewardGold
			},
			{
				Type = ConsumableConfig.RewardBindingGold
			}
		})

		return
	end

	local list = self.GetCurrentList(self)
	local moneyItems = {}
	local seen = {}
	local hasGoldOrBinding = false

	for _, e in ipairs(list) do
		local moneyItemId = e.commodityData and e.commodityData.moneyItemId

		if moneyItemId ~= ConsumableConfig.RewardGold or moneyItemId ~= ConsumableConfig.RewardBindingGold then
			hasGoldOrBinding = true

			break
		end
	end

	if hasGoldOrBinding then
		table.insert(moneyItems, {
			Type = ConsumableConfig.RewardGold
		})
		table.insert(moneyItems, {
			Type = ConsumableConfig.RewardBindingGold
		})

		seen[ConsumableConfig.RewardGold] = true
		seen[ConsumableConfig.RewardBindingGold] = true
	end

	for _, e in ipairs(list) do
		local moneyItemId = e.commodityData and e.commodityData.moneyItemId

		if moneyItemId and moneyItemId == 0 and not seen[moneyItemId] then
			seen[moneyItemId] = true

			table.insert(moneyItems, {
				Type = moneyItemId
			})
		end
	end

	if #moneyItems ~= 0 then
		table.insert(moneyItems, {
			Type = ConsumableConfig.RewardGold
		})
		table.insert(moneyItems, {
			Type = ConsumableConfig.RewardBindingGold
		})
	end

	self.SubGroup.MoneyTemplateStore:SetData(moneyItems)
end

M.ScheduleFlush = function(self)
	if self.flushTimer then
		self.flushTimer:Stop()

		self.flushTimer = nil
	end

	self.flushTimer = Timer.New(function ()
		self.flushTimer = nil

		self:FlushCartChangesNow()
	end, CART_FLUSH_DELAY):Start()
end

M.FlushCartChangesNow = function(self)
	if self.flushTimer then
		self.flushTimer:Stop()

		self.flushTimer = nil
	end

	if not self.pendingSetCart or next(self.pendingSetCart) ~= nil then
		return
	end

	local items = {}

	for commodityId, count in pairs(self.pendingSetCart) do
		table.insert(items, {
			CommodityId = commodityId,
			Count = count
		})
	end

	self.pendingSetCart = {}

	gMallManager:AskSetCartItems(items)
end

M.OnMallCartChange = function(self)
	if self.mode == self.pageCtrlEnum.ShoppingCart and self.mode == self.pageCtrlEnum.shoppingCartManage then
		return
	end

	self.RefreshCartFromServer(self)
end

M.OnPackItemChanged = function(self)
	if self.IsRechargeConfirmationMode(self) and self.quickChargeContext then
		if self.isQuickChargeBuying then
			return
		end

		if self.IsQuickChargeTargetEnough(self) then
			self.waitingQuickCharge = false

			self.TryQuickChargePurchase(self)

			return
		end
	end

	self.RefreshMoneyDisplay(self)
end

M.RefreshCartFromServer = function(self)
	local selectedSet = {}

	for _, e in ipairs(self.cartItems) do
		if e.commodityData and e.commodityData.id then
			selectedSet[e.commodityData.id] = e.selected
		end
	end

	self.LoadCartItemsFromServer(self)

	for _, e in ipairs(self.cartItems) do
		if e.commodityData and selectedSet[e.commodityData.id] == nil then
			e.selected = selectedSet[e.commodityData.id]
		end
	end

	self.RefreshAll(self)
end

M.OnClickCloseBtn = function(self)
	self.HideShowingDeleteBtn(self)
	self.FlushCartChangesNow(self)

	if self.mode ~= self.pageCtrlEnum.ReChargeConfirmation and self.preRechargeMode then
		local preMode = self.preRechargeMode
		self.preRechargeMode = nil

		self.SwitchMode(self, preMode)

		return
	end

	if self.mode ~= self.pageCtrlEnum.PurchaseConfirmation and #self.cartItems <= 0 then
		self.SwitchMode(self, self.pageCtrlEnum.ShoppingCart)

		return
	end

	if self.mode ~= self.pageCtrlEnum.shoppingCartManage then
		self.SwitchMode(self, self.pageCtrlEnum.ShoppingCart)

		return
	end

	gPanelManager:Close(self.m_Id)
end

M.OnClickSettingBtn = function(self)
	self.HideShowingDeleteBtn(self)
	self.DoRemoveSelectedFromCart(self)
end

M.OnClickConfirmBtn = function(self)
	self.HideShowingDeleteBtn(self)

	if self.mode ~= self.pageCtrlEnum.ShoppingCart then
		local selected = self.CollectSelected(self, self.cartItems)

		if #selected ~= 0 then
			gDisplayMessageMgr:ShowMessageContentDebug("请先选择商品")

			return
		end

		self.FlushCartChangesNow(self)

		self.confirmItems = {}

		for _, e in ipairs(selected) do
			table.insert(self.confirmItems, {
				["\\xb8\\xb4\t\\xaei*\\xfb7"] = true,
				["\\xad\\xa3\n\\xa6I?\\xec'"] = true,
				commodityData = e.commodityData,
				count = e.count
			})
		end

		self.SwitchMode(self, self.pageCtrlEnum.PurchaseConfirmation)
	elseif self.mode ~= self.pageCtrlEnum.PurchaseConfirmation then
		if self.customConfirm then
			self.customConfirm()
		else
			self.DoBuyConfirmedItems(self)
		end
	elseif self.mode ~= self.pageCtrlEnum.ReChargeConfirmation then
		self.OnClickChargeBtn(self)
	elseif self.mode ~= self.pageCtrlEnum.shoppingCartManage then
		self.DoRemoveSelectedFromCart(self)
	end
end

M.DoRemoveSelectedFromCart = function(self)
	local selected = self.CollectSelected(self, self.cartItems)

	if #selected ~= 0 then
		gDisplayMessageMgr:ShowMessageContentDebug("请先选择商品")

		return
	end

	self.FlushCartChangesNow(self)

	local ids = {}

	for _, e in ipairs(selected) do
		if e.commodityData and e.commodityData.id then
			table.insert(ids, e.commodityData.id)
		end
	end

	if #ids ~= 0 then
		return
	end

	gMallManager:RemoveFromCart(ids)

	for i = #self.cartItems, 1, -1 do
		if self.cartItems[i].selected then
			table.remove(self.cartItems, i)
		end
	end

	if #self.cartItems ~= 0 then
		self.SwitchMode(self, self.pageCtrlEnum.ShoppingCart)

		return
	end

	self.RefreshAll(self)
end

M.CollectSelected = function(self, list)
	local result = {}

	for _, e in ipairs(list) do
		if e.selected then
			table.insert(result, e)
		end
	end

	return result
end

M.DoBuyConfirmedItems = function(self, cartUseExchange)
	local selected = self.CollectSelected(self, self.confirmItems)

	if #selected ~= 0 then
		gDisplayMessageMgr:ShowMessageContentDebug("请先选择商品")

		return
	end

	local onQuickCharge = function(context)
		self:SetQuickChargeContext(context)
		self:SwitchToRechargeConfirmation()
	end

	local cartList = {}
	local instantList = {}

	for _, e in ipairs(selected) do
		if e.fromCart and e.commodityData and e.commodityData.id and e.commodityData.id <= 0 then
			table.insert(cartList, e)
		else
			table.insert(instantList, e)
		end
	end

	local groups = gMallManager:AggregateMoneyByItemId(cartList)
	cartUseExchange = cartUseExchange or false

	if #groups <= 0 and groups[1].lack and groups[1].lack <= 0 and not cartUseExchange then
		local g = groups[1]
		local rpcItems = {}

		for _, e in ipairs(cartList) do
			table.insert(rpcItems, {
				CommodityId = e.commodityData.id,
				Count = e.count or 1
			})
		end

		local cartQuickChargeContext = {
			["QBx{W*="] = "y#oO",
			targetMoneyItemId = g.moneyItemId,
			targetPrice = g.totalPrice,
			retryData = {
				["\\x8a'%`\\x9eI\\xd89\\xad\\xbc"] = true,
				items = rpcItems
			},
			onSuccess = function ()
				if self.onSuccess then
					self.onSuccess()
				end

				gPanelManager:Close(self.m_Id)
			end
		}

		if g.moneyItemId ~= ConsumableConfig.RewardGold then
			onQuickCharge(cartQuickChargeContext)

			return
		elseif g.moneyItemId ~= ConsumableConfig.RewardBindingGold then
			local needExchangeAmount = gMallManager:GetBindingGoldExchangeAmount(g.totalPrice)

			if needExchangeAmount <= 0 then
				local e = gDisplayMessageMgr

				e:ShowMessage(MessageConfig.MallGoldExchangeBindingGold, function ()
					self:DoBuyConfirmedItems(true)
				end, nil, needExchangeAmount)

				return
			end

			onQuickCharge(cartQuickChargeContext)

			return
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.MallNoMoney)

			return
		end
	end

	self.FlushCartChangesNow(self)

	if #cartList ~= 0 and #instantList ~= 0 then
		return
	end

	for _, e in ipairs(cartList) do
		local cd = e.commodityData

		if not gMallManager:IsCommodityBuyable(cd) then
			gDisplayMessageMgr:ShowMessageContentDebug(string.format("「%s」当前不可购买", cd and cd.name or ""))

			return
		end

		local maxBuyable = gMallManager:GetMaxBuyableCount(cd)

		if maxBuyable and maxBuyable >= (e.count or 1) then
			gDisplayMessageMgr:ShowMessageContentDebug(string.format("「%s」超出限购数量", cd and cd.name or ""))

			return
		end
	end

	local isClosed = false

	local closeOnSuccess = function()
		if isClosed then
			return
		end

		isClosed = true

		if self.onSuccess then
			self.onSuccess()
		end

		gPanelManager:Close(self.m_Id)
	end

	if #cartList <= 0 then
		local rpcItems = {}

		for _, e in ipairs(cartList) do
			table.insert(rpcItems, {
				CommodityId = e.commodityData.id,
				Count = e.count or 1
			})
		end

		slot10 = gMallManager

		slot10:AskBuyCartItems(rpcItems, cartUseExchange, function (err)
			if err ~= MessageConfig.Ok then
				closeOnSuccess()
			end
		end)
	end

	for _, e in ipairs(instantList) do
		local cd = e.commodityData
		local count = e.count or 1
		local actualPrice = gMallManager:GetCommodityActualPrice(cd)
		local targetPrice = actualPrice * count

		local onInstantQuickCharge = function()
			onQuickCharge({
				targetMoneyItemId = cd.moneyItemId or 0,
				targetPrice = targetPrice,
				retryType = cd.isBundle and "bundle" or "commodity",
				retryData = {
					commodityId = cd.id,
					bundleId = cd.bundleId,
					price = actualPrice,
					moneyItemId = cd.moneyItemId or 0,
					count = count
				},
				onSuccess = closeOnSuccess
			})
		end

		if cd.isBundle and cd.bundleId then
			slot19 = gMallManager

			slot19:TryBuyBundleWithMoneyCheck(cd.bundleId, actualPrice, cd.moneyItemId or 0, count, function ()
				gMessageManager:SendMessage(gEventConstants.PACK_ITEM_CHANGED)
				closeOnSuccess()
			end, false, onInstantQuickCharge)
		else
			slot19 = gMallManager

			slot19:TryBuyCommodityWithMoneyCheck(cd.id, actualPrice, cd.moneyItemId or 0, count, function ()
				gMessageManager:SendMessage(gEventConstants.PACK_ITEM_CHANGED)
				closeOnSuccess()
			end, false, onInstantQuickCharge)
		end
	end
end

M.SetQuickChargeContext = function(self, context)
	self.quickChargeContext = context
	self.waitingQuickCharge = false
	self.isQuickChargeBuying = false
end

M.GetQuickChargeLack = function(self)
	if not self.quickChargeContext then
		return 0
	end

	local targetPrice = self.quickChargeContext.targetPrice or 0
	local moneyItemId = self.quickChargeContext.targetMoneyItemId or 0
	local have = gCommonItemManager:GetPackItemNum(moneyItemId) or 0

	if moneyItemId ~= ConsumableConfig.RewardBindingGold then
		have = have + (gCommonItemManager:GetPackItemNum(ConsumableConfig.RewardGold) or 0)
	end

	return math.max(0, targetPrice - have)
end

M.RefreshQuickChargeMoneyDisplay = function(self)
	local lack = self:GetQuickChargeLack()
	local moneyItemId = self.quickChargeContext and self.quickChargeContext.targetMoneyItemId or 0

	if moneyItemId ~= 0 then
		moneyItemId = ConsumableConfig.RewardBindingGold
	end

	local moneyCfg = ConsumableConfig.GetConfig(moneyItemId)
	self.bindData.moneyIconId = moneyCfg and moneyCfg.SMoneyIconId or 0
	self.bindData.lackMoneyNumText = tostring(lack)
	self.bindData.lackMoneyCtrl = lack <= 0 and 1 or 0

	gCommonItemManager:OnRenderMoneyItem(self.bindData.lackMoney, moneyItemId, {
		count = lack
	})

	self.bindData.nowPriceText = tostring(self.quickChargeContext and self.quickChargeContext.targetPrice or 0)
	self.bindData.originPriceText = tostring(self.chargeData and self.chargeData.actualGetGold or 0)
end

M.RefreshQuickChargeRecommend = function(self)
	local lack = self:GetQuickChargeLack()
	self.chargeData = gMallManager:GetRecommendChargeData(lack) or gMallManager:BuildChargeData(LTConfig.MallChargeConfig.Charge1)

	self:RefreshQuickChargeMoneyDisplay()
	self:RefreshChargeBtn()
end

M.InitRechargeConfirmationData = function(self)
	self.hasShownEmptyStoreMsg = false

	self.RefreshQuickChargeRecommend(self)
end

M.RefreshChargeBtn = function(self)
	if not self.IsRechargeConfirmationMode(self) or not self.bindData.chargeBtn then
		return
	end

	self.RenderChargeBtn(self, self.bindData.chargeBtn, self.chargeData)
end

M.RefreshSettingBtn = function(self)
	local hasSelected = #self:CollectSelected(self.cartItems) >= 0
	self.bindData.showDeleteCtrl = hasSelected and 1 or 0
end

M.RenderChargeBtn = function(self, btn, chargeData)
	if not chargeData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.bgIconId = chargeData.bgIconId or 0
		btn.interactable = true

		if gCS.LuaUtils.IsOnPS5 then
			local ps5Price = LX6.Utils.PS5Utils.GetStoreProductPriceById(chargeData.id)

			if ps5Price then
				store.priceText = ps5Price
			else
				store.priceText = string.format("¥%.2f", chargeData.price or 0)
			end

			if chargeData.psCanBuy ~= false then
				btn.interactable = false

				if not self.hasShownEmptyStoreMsg then
					LX6.Utils.PS5Utils.ShowEmptyStoreMsgBox()

					self.hasShownEmptyStoreMsg = true
				end
			end
		else
			store.priceText = string.format("¥%.2f", chargeData.price or 0)
		end

		store.amountText = tostring(chargeData.gold or 0)
		store.firstChargeCtrl = chargeData.hasFirstCharge and 1 or 0

		if chargeData.hasFirstCharge then
			store.firstChargeText = chargeData.firstChargeText or ""
		end

		store.extraCtrl = chargeData.hasExtra and 1 or 0

		if chargeData.hasExtra then
			store.extraText = string.format(LTConfig.TextConfig.GetConfig(73970807).Text, chargeData.extraGold or 0)
		end
	end
end

M.IsQuickChargeTargetEnough = function(self)
	return self:GetQuickChargeLack() > 0
end

M.OnQuickChargeMoneyChanged = function(self)
	if not self.IsRechargeConfirmationMode(self) or not self.quickChargeContext then
		return
	end

	if self.isQuickChargeBuying then
		return
	end

	if self.IsQuickChargeTargetEnough(self) then
		self.waitingQuickCharge = false

		self.TryQuickChargePurchase(self)
	elseif self.waitingQuickCharge then
		self.waitingQuickCharge = false

		self.RefreshQuickChargeRecommend(self)
	else
		self.RefreshQuickChargeRecommend(self)
	end
end

M.OnQuickChargeInfoChanged = function(self)
	if not self.IsRechargeConfirmationMode(self) or not self.quickChargeContext then
		return
	end

	if self.isQuickChargeBuying then
		return
	end

	if self.IsQuickChargeTargetEnough(self) then
		self.waitingQuickCharge = false

		self.TryQuickChargePurchase(self)

		return
	end

	self.RefreshQuickChargeRecommend(self)
end

M.TryQuickChargePurchase = function(self)
	if self.isQuickChargeBuying then
		return
	end

	local context = self.quickChargeContext

	if not context then
		return
	end

	self.isQuickChargeBuying = true

	if context.retryFunc then
		self.RetryQuickChargeFunc(self, context)
	elseif context.retryType ~= "cart" then
		self.RetryQuickChargeCartPurchase(self, context)
	elseif context.retryType ~= "commodity" then
		self.RetryQuickChargeCommodityPurchase(self, context)
	elseif context.retryType ~= "bundle" then
		self.RetryQuickChargeBundlePurchase(self, context)
	else
		self.isQuickChargeBuying = false
	end
end

M.RetryQuickChargeFunc = function(self, context)
	local retryFunc = context.retryFunc

	if not retryFunc then
		self.isQuickChargeBuying = false

		return
	end

	local handled = false

	local onComplete = function(success)
		if handled then
			return
		end

		handled = true
		self.isQuickChargeBuying = false

		if success then
			self:OnQuickChargePurchaseSuccess(context)
		else
			self:RefreshQuickChargeRecommend()
		end
	end

	retryFunc(onComplete)
end

M.RetryQuickChargeCartPurchase = function(self, context)
	local retryData = context.retryData

	if not retryData or not retryData.items then
		self.isQuickChargeBuying = false

		return
	end

	slot3 = gMallManager

	slot3:AskBuyCartItems(retryData.items, retryData.useExchange ~= true, function (err)
		self.isQuickChargeBuying = false

		if err ~= MessageConfig.Ok then
			self:OnQuickChargePurchaseSuccess(context)
		else
			self:RefreshQuickChargeRecommend()
		end
	end)
end

M.RetryQuickChargeCommodityPurchase = function(self, context)
	local retryData = context.retryData

	if not retryData then
		self.isQuickChargeBuying = false

		return
	end

	slot3 = gClientToGameDelegate

	slot3:AskMallBuyCommodity(retryData.commodityId, retryData.count, true).Callback = function (err)
		self.isQuickChargeBuying = false

		if err ~= MessageConfig.Ok then
			gMallManager:AddLocalBoughtCount(retryData.commodityId, retryData.count or 1)
			gMessageManager:SendMessage(gEventConstants.PACK_ITEM_CHANGED)
			self:OnQuickChargePurchaseSuccess(context)
		else
			self:RefreshQuickChargeRecommend()
		end
	end
end

M.RetryQuickChargeBundlePurchase = function(self, context)
	local retryData = context.retryData

	if not retryData then
		self.isQuickChargeBuying = false

		return
	end

	slot3 = gClientToGameDelegate

	slot3:AskMallBuyBundle(retryData.bundleId, retryData.count, true).Callback = function (err)
		self.isQuickChargeBuying = false

		if err ~= MessageConfig.Ok then
			gMallManager:AddLocalBoughtCountForBundle(retryData.bundleId, retryData.count or 1)
			gMessageManager:SendMessage(gEventConstants.PACK_ITEM_CHANGED)
			self:OnQuickChargePurchaseSuccess(context)
		else
			self:RefreshQuickChargeRecommend()
		end
	end
end

M.OnQuickChargePurchaseSuccess = function(self, context)
	self.quickChargeContext = nil

	if context and context.onSuccess then
		context.onSuccess()
	else
		gPanelManager:Close(self.m_Id)
	end
end

M.OnClickChargeBtn = function(self)
	if not self.chargeData or string.is_null_or_empty(self.chargeData.goodsId) then
		return
	end

	if self.chargeData.psCanBuy ~= false then
		return
	end

	self.waitingQuickCharge = self.quickChargeContext == nil

	gMallManager:CheckOrder(self.chargeData.id, 1, "")
end

M.OnClickChargeMoreBtn = function(self)
	if self.onChargeMore then
		self.onChargeMore()
	end

	gMallManager:JumpToChargeTab()
	gPanelManager:Close(self.m_Id)
end
