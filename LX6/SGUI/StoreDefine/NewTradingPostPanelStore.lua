-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewTradingPostPanelStore.lua
-- Decompiled from: 00928_NewTradingPostPanelStore.lua_a72f9a8612dd.luajit

local TradeConfig = LTConfig.TradeConfig
C_NewTradingPostPanelStore = DefClass("C_NewTradingPostPanelStore", C_NewTradingPostPanelStore, C_StoreGroup)
GroupName2Class.NewTradingPostPanelStore = C_NewTradingPostPanelStore
local M = C_NewTradingPostPanelStore
local FILTER_ALL = 0
local DIRECTION_FIRST = 0
local SUB_TAB_MAIN = 0
local SUB_TAB_RECORDS = 1
local ITEM_TEMPLATE_BOX = 0
local ITEM_TEMPLATE_SHOP = 2
local SHOP_TEMPLATE_STORE_NAME = "NPCShopPanelStore"

M.ctor = function(self)
	self.mgr = gTradeManager
end

M.DefineAllVariables = function(self)
	self.tabList = {}
	self.currentTabId = nil
	self.currentTab = nil
	self.currentItemList = {}
	self.currentSelectedItem = nil
	self.onlyFavorite = false
	self.buyRecords = {}
	self.sellRecords = {}
	self.currentSubTab = SUB_TAB_MAIN
	self.prevMallVCamera = nil
	self.currentPreviewCommodityId = 0
	self.currentPreviewModelKind = nil
	self.ownsMallVCamera = false
	self.mallCameraEnabled = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.isEmptyCtrlEnum = {
		["k\\xaf\\xae\\xbc\\xb3"] = 0,
		["N0h^"] = 1
	}
	self.listCtrlEnum = {
		["0\\xe6\\#\\xd4\\xb8F\\x8d_\\xa3\\xa2"] = 2,
		["/A\\x9f\\x89\\x8fD"] = 0,
		["8G\\x84\\x8c\\x8fD"] = 1
	}
	self.showControlCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isEmptyCtrlEnum = nil
	self.listCtrlEnum = nil
	self.showControlCtrlEnum = nil
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
	self.CleanUpSceneItemPreview(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self:CleanUpSceneItemPreview()
	self.bindData.camera.transform:SetParent(nil, false)
	self.bindData.camera.transform:GetChild(0).gameObject:SetActive(true)

	self.bindData.camera.transform.position = gCS.CameraDataMgr.MainCamera.transform.position
	self.bindData.camera.transform.rotation = gCS.CameraDataMgr.MainCamera.transform.rotation
	self.prevMallVCamera = gMallSceneManager.mallVCamera

	gMallSceneManager:SetMallVCamera(self.bindData.VCamera)

	self.ownsMallVCamera = true
	self.shopTipStore = gStoreManager:GetStoreGroup(self.bindData.shopTip.Store):GetStoreByWidget(self.bindData.shopTip)
	self.onlyFavorite = data and data.onlyFavorite ~= true or false
	self.currentTabId = data and data.tradeTabId or self.currentTabId
	self.currentSubTab = SUB_TAB_MAIN

	self:RefreshTabs()
	self:RefreshProductList()
	self.mgr:AskTradeGetHistoryPage(DIRECTION_FIRST, FILTER_ALL)
	self.SubGroup.MoneyTemplateStore:SetData({
		{
			Type = LTConfig.ConsumableConfig.RewardGold
		},
		{
			Type = LTConfig.ConsumableConfig.RewardBindingGold
		}
	})
end

M.ApplyTabButtonVisibility = function(self)
	local tab = self.currentTab and self.currentTab.tab
	local showFollow = (not tab or tab.showFollowBtn == false) and 1 or 0
	local showRecycle = (not tab or tab.showRecycleBtn == false) and 1 or 0
	self.shopTipStore.showFollowBtnCtrl = showFollow
	self.shopTipStore.showRecycleBtnCtrl = showRecycle

	if showFollow ~= 1 then
		self.bindData.followBtn.interactable = true
	end
end

M.OnClose = function(self)
	self:CleanUpSceneItemPreview()
	self.mgr:ClearMarketCache()
end

M.CleanUpSceneItemPreview = function(self)
	if not self.ownsMallVCamera then
		return
	end

	self.DisableMallCameraControl(self)

	if self.bindData and self.bindData.camera and not gCS.LuaUtils.IsNull(self.bindData.camera.gameObject) then
		GameObject.Destroy(self.bindData.camera.gameObject)
	end

	self.ClearSceneItemPreview(self)

	if self.prevMallVCamera then
		gMallSceneManager:SetMallVCamera(self.prevMallVCamera)
	else
		gMallSceneManager:ReleaseMallScene()
		gMallSceneManager:ClearMallVCamera()
	end

	self.prevMallVCamera = nil
	self.ownsMallVCamera = false
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.TRADE_PLAYER_INFO_CHANGE] = self.CreateAction(self, "OnTradePlayerInfoChange"),
		[gEventConstants.TRADE_ORDER_LIST_CHANGE] = self.CreateAction(self, "OnTradeOrderListChange"),
		[gEventConstants.TRADE_MARKET_LIST_CHANGE] = self.CreateAction(self, "OnTradeMarketListChange"),
		[gEventConstants.TRADE_FAVORITE_LIST_CHANGE] = self.CreateAction(self, "OnTradeFavoriteListChange"),
		[gEventConstants.TRADE_HISTORY_PAGE_CHANGE] = self.CreateAction(self, "OnTradeHistoryPageChange")
	}
end

M.OnTradePlayerInfoChange = function(self)
	self.RefreshProductList(self)
	self.RefreshRecords(self)
end

M.OnTradeOrderListChange = function(self, _, tradeItemId)
	if not tradeItemId or self.IsCurrentItem(self, tradeItemId) then
		self.RenderShopTip(self)
	end

	self.RefreshRecords(self)
end

M.OnTradeMarketListChange = function(self, _, tradeItemId)
	if not tradeItemId or self.IsCurrentItem(self, tradeItemId) then
		self.RenderShopTip(self)
	end
end

M.OnTradeFavoriteListChange = function(self)
	self.RefreshProductList(self)
	self.RenderShopTip(self)
end

M.OnTradeHistoryPageChange = function(self, _, filter)
	if filter ~= FILTER_ALL then
		self.RefreshRecords(self)
	end
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.followBtn.luaClick = self.CreateAction(self, "OnClickFollowBtn")
	self.bindData.recycleBtn.luaClick = self.CreateAction(self, "OnClickRecycleBtn")
	self.bindData.doubleList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderItem")
	self.bindData.doubleList.luaSelectedChanged = self.CreateAction(self, "OnItemSelectedChanged")
	self.bindData.doubleList.onGetTIndex = self.CreateAction(self, "OnGetItemTIndex")
	self.bindData.singleList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderItem")
	self.bindData.singleList.luaSelectedChanged = self.CreateAction(self, "OnItemSelectedChanged")
	self.bindData.singleList.onGetTIndex = self.CreateAction(self, "OnGetItemTIndex")
	self.bindData.buyRecordList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderBuyRecordListItem")
	self.bindData.sellRecordList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderSellRecordListItem")
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickFollowBtn = function(self)
	gPanelManager:CheckShow(gPanelId.NEW_TRADING_POST_SELLING_LIST_PANEL, {
		["iw\\xbax^\\xbb\\xe6BGuzI"] = true,
		tradeTabId = self.currentTabId
	})
end

M.OnClickRecycleBtn = function(self)
	local item = self.currentSelectedItem

	if not item then
		return
	end

	gPanelManager:CheckShow(gPanelId.TRADING_POST_RECYCLE_WINDOW_PANEL, {
		boxId = item.Id,
		tradeItemId = item.Id
	})
end

M.RefreshTabs = function(self)
	self.tabList = self.mgr:GetTradeTabList()
	local tabViewList = {}
	local selectedIndex = 0

	for i, entry in ipairs(self.tabList) do
		tabViewList[i] = {
			id = entry.tab.Id,
			title = entry.tab.Title or entry.tab.Name or "",
			iconId = entry.tab.Icon or 0
		}

		if entry.tab.Id ~= self.currentTabId then
			selectedIndex = i - 1
		end
	end

	local selected = self.tabList[selectedIndex + 1]
	self.currentTabId = selected and selected.tab.Id or nil
	local subTabViewList = {
		{
			id = SUB_TAB_MAIN,
			title = TradeConfig.TradeSubTitle1,
			iconId = TradeConfig.TradeSubIcon1
		},
		{
			id = SUB_TAB_RECORDS,
			title = TradeConfig.TradeSubTitle2,
			iconId = TradeConfig.TradeSubIcon2
		}
	}

	self.SubGroup.CommonTabSingleStore_Main:SetData(tabViewList, nil, selectedIndex, 0, self:CreateAction("OnTabChanged"))
	self.SubGroup.CommonTabSingleStore_Sub:SetData(subTabViewList, nil, self.currentSubTab, 0, self:CreateAction("OnSubTabChanged"))
end

M.OnTabChanged = function(self, uList)
	local entry = self.tabList[(uList and uList.selectedIndex or -1) + 1]

	if not entry then
		return
	end

	self.currentTabId = entry.tab.Id

	if self.currentSubTab ~= SUB_TAB_RECORDS then
		self.SubGroup.CommonTabSingleStore_Sub:SetSelectedIndex(SUB_TAB_MAIN, true, false)
	end

	self.RefreshProductList(self)
end

M.OnSubTabChanged = function(self, uList)
	self.currentSubTab = uList and uList.selectedIndex or SUB_TAB_MAIN

	if self.currentSubTab ~= SUB_TAB_RECORDS then
		self.ClearSceneItemPreview(self)

		self.bindData.listCtrl = self.listCtrlEnum.RecordingList

		self.RefreshRecords(self)
	else
		self.ApplyListCtrl(self, self.IsDoubleList(self))
		self.ApplyEmptyCtrl(self)
		self.RenderShopTip(self)
	end
end

M.RefreshProductList = function(self)
	self.currentTab = nil

	for _, entry in ipairs(self.tabList) do
		if entry.tab.Id ~= self.currentTabId then
			self.currentTab = entry

			break
		end
	end

	if not self.currentTab then
		self.currentTab = self.tabList[1]
		self.currentTabId = self.currentTab and self.currentTab.tab.Id or nil
	end

	self:ApplyTabButtonVisibility()

	local items = self.currentTab and self.currentTab.items or {}

	if self.onlyFavorite then
		local filtered = {}

		for _, item in ipairs(items) do
			if self.IsEntryFavorite(self, item) then
				table.insert(filtered, item)
			end
		end

		items = filtered
	end

	self.currentItemList = items
	local selectedId = self.currentSelectedItem and self.currentSelectedItem.Id
	local selectIndex = 0

	for i, item in ipairs(items) do
		if item.Id ~= selectedId then
			selectIndex = i - 1

			break
		end
	end

	local isDouble = self:IsDoubleList()

	self.bindData.doubleList:SetSimpleList(isDouble and #items or 0)
	self.bindData.singleList:SetSimpleList(isDouble and 0 or #items)
	self:ApplyListCtrl(isDouble)
	self:ApplyEmptyCtrl()

	if #items <= 0 then
		local activeList = isDouble and self.bindData.doubleList or self.bindData.singleList

		activeList:SelectItem(selectIndex, true)
	else
		self.currentSelectedItem = nil

		self.RenderShopTip(self)
	end
end

M.IsDoubleList = function(self)
	return self.currentTab == nil and self.currentTab.tab.IsDoubleList ~= true
end

M.OnGetItemTIndex = function(self)
	local tab = self.currentTab and self.currentTab.tab

	return tab and tab.ListTemplate or ITEM_TEMPLATE_BOX
end

M.IsEntryFavorite = function(self, item)
	if not item then
		return false
	end

	if self.mgr:IsFavorite(item.Id) then
		return true
	end

	slot2 = ipairs
	slot4 = item.TradeItemIds or {}

	for _, itemId in slot2(slot4) do
		if self.mgr:IsFavorite(itemId) then
			return true
		end
	end

	return false
end

M.IsCurrentItem = function(self, tradeItemId)
	local item = self.currentSelectedItem

	if not item then
		return false
	end

	if item.Id ~= tradeItemId then
		return true
	end

	slot3 = ipairs
	slot5 = item.TradeItemIds or {}

	for _, itemId in slot3(slot5) do
		if itemId ~= tradeItemId then
			return true
		end
	end

	return false
end

M.ApplyListCtrl = function(self, isDouble)
	if self.currentSubTab ~= SUB_TAB_RECORDS then
		self.bindData.listCtrl = self.listCtrlEnum.RecordingList

		return
	end

	self.bindData.listCtrl = isDouble and self.listCtrlEnum.Double or self.listCtrlEnum.Single
end

M.ApplyEmptyCtrl = function(self)
	local hasContent = nil

	if self.currentSubTab ~= SUB_TAB_RECORDS then
		hasContent = #self.buyRecords >= 0 or #self.sellRecords >= 0
	else
		hasContent = #self.currentItemList >= 0
	end

	self.bindData.isEmptyCtrl = hasContent and self.isEmptyCtrlEnum.False or self.isEmptyCtrlEnum.True
end

M.OnSimpleRenderItem = function(self, btn, index)
	local item = self.currentItemList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if btn.Store ~= SHOP_TEMPLATE_STORE_NAME then
		self.RenderShopStyleItem(self, store, item)

		return
	end

	local favorite = item == nil and self:IsEntryFavorite(item)
	store.nameLabel = item and self.mgr:GetTradeItemName(item) or ""
	store.tagLabel = favorite and "★" or ""
	store.itemIcon = item and self.mgr:GetTradeItemIcon(item) or 0
	store.qualityCtrl = favorite and 1 or 0
	store.rewardTypeCtrl = self:GetCurrentRewardType()
end

M.RenderShopStyleItem = function(self, store, item)
	if not store then
		return
	end

	store.qualityCtrl = item == nil and self:IsEntryFavorite(item) and 1 or 0
	store.showCountLimitCtrl = 0
	store.showNumberCtrl = 0
	store.showTaskWarningCtrl = 0
	store.singleMoneyLackCtrl = 0
	store.stateCtrl = 0
	store.hasDiscountCtrl = 0
	store.discountTypeCtrl = 0
	store.discount = ""
	store.name = item and self.mgr:GetTradeItemName(item) or ""
	store.iconId = item and self.mgr:GetTradeItemIcon(item) or 0
	store.priceCurrent = ""
	store.countLimit = ""
	store.countNumber = ""
	store.taskIconId = 0
	store.moneyIconId = 0
	store.refreshTime = ""
	store.showRefreshTimeCtrl = 0
	store.typeCtrl = 0
end

M.OnItemSelectedChanged = function(self, uList)
	local index = uList and uList.selectedIndex or -1
	self.currentSelectedItem = self.currentItemList[index + 1]

	self:RenderShopTip()
end

M.ClearSceneItemPreview = function(self)
	self.DisableMallCameraControl(self)

	if self.currentPreviewCommodityId == 0 then
		gMallSceneManager:ClearCharacterModel()
		gMallSceneManager:ClearVehicle()
		gMallSceneManager:ClearWeapon()

		self.currentPreviewCommodityId = 0
		self.currentPreviewModelKind = nil
	end
end

M.RenderSceneItemPreview = function(self, item)
	local commodityId = self.mgr:GetTradeItemMallId(item)

	if commodityId ~= 0 then
		self.ClearSceneItemPreview(self)

		return false
	end

	if self.currentPreviewCommodityId ~= commodityId and self.currentPreviewModelKind == gMallSceneManager.LoadingType.None then
		return true
	end

	self:ClearSceneItemPreview()

	self.currentPreviewCommodityId = commodityId
	self.currentPreviewModelKind = gMallSceneManager:PreviewCommodityById(commodityId, {
		onLoaded = function ()
			if self.currentPreviewCommodityId ~= commodityId then
				gMallSceneManager:ApplyMallSceneCamera(self.currentPreviewModelKind ~= gMallSceneManager.LoadingType.Vehicle)
				self:UpdateMallCameraControl()
			end
		end
	})

	if self.currentPreviewModelKind ~= gMallSceneManager.LoadingType.None then
		self.currentPreviewCommodityId = 0
		self.currentPreviewModelKind = nil

		return false
	end

	self:UpdateMallCameraControl()

	return self.currentPreviewModelKind == nil
end

M.GetCurrentModelRoot = function(self)
	local mgr = gMallSceneManager
	local LoadingType = mgr.LoadingType
	local target = nil

	if self.currentPreviewModelKind ~= LoadingType.Weapon then
		target = mgr.currentWeaponGo
	elseif self.currentPreviewModelKind ~= LoadingType.Vehicle then
		target = mgr.currentVehicle and mgr.currentVehicle.gameObject
	else
		target = mgr.currentModelUnit and mgr.currentModelUnit.PlayerObj
	end

	if target and not gCS.LuaUtils.IsNull(target) then
		return target.transform
	end

	return nil
end

M.UpdateMallCameraControl = function(self)
	local modelRoot = self.GetCurrentModelRoot(self)

	if not modelRoot or not self.bindData or not self.bindData.VCamera then
		self.DisableMallCameraControl(self)

		return
	end

	local rotateCenter, autoRotateRecenter = nil
	local allowRotateModelAroundAllAxis = false

	if self.currentPreviewModelKind ~= gMallSceneManager.LoadingType.Weapon then
		rotateCenter = gCS.LuaUtils.CalcMeshModelCenterGo(gMallSceneManager.currentWeaponGo)
		autoRotateRecenter = true
		allowRotateModelAroundAllAxis = true
	end

	local basePanel = self.bindData.basePanel or self.bindData.baseUpdownButton and self.bindData.baseUpdownButton.transform
	local cameraControlConfig = gMallCameraManager:BuildMallCameraControlConfig(self.currentPreviewModelKind)

	gMallCameraManager:SetMallPanelCamera(self.m_Id, true, {
		["AFb[A\n="] = false,
		verticalButton = self.bindData.baseUpdownButton,
		dragTarget = self.bindData.baseUpdownButton,
		basePanel = basePanel,
		rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
		L2CustomNavRespond = self.bindData.L2CustomNavRespond,
		R2CustomNavRespond = self.bindData.R2CustomNavRespond,
		camera = self.bindData.VCamera,
		modelRoot = modelRoot,
		cameraOffsetRange = cameraControlConfig.yOffsetRange,
		cameraOffset = Vector3.New(0, 0, 0),
		cameraControlConfig = cameraControlConfig,
		rotateCenter = rotateCenter,
		autoRotateRecenter = autoRotateRecenter,
		allowRotateModelAroundAllAxis = allowRotateModelAroundAllAxis
	})

	self.mallCameraEnabled = true
end

M.DisableMallCameraControl = function(self)
	if not self.mallCameraEnabled then
		return
	end

	gMallCameraManager:SetMallPanelCamera(self.m_Id, false)

	self.mallCameraEnabled = false
end

M.GetCurrentRewardType = function(self)
	local tabStore = self.SubGroup and self.SubGroup.CommonTabSingleStore_Main

	if tabStore and tabStore.GetSelectedIndex then
		return tabStore.GetSelectedIndex(tabStore)
	end

	return 0
end

M.RenderShopTip = function(self)
	local store = self.shopTipStore
	store.rewardTypeCtrl = self.GetCurrentRewardType(self)
	local item = self.currentSelectedItem

	if not item then
		store.goodsName = ""
		store.goodNumStr = ""
		store.itemNumStr = ""
		store.timeStr = ""
		store.buyBtn.interactable = false
		store.sellBtn.interactable = false
		self.bindData.bigIcon = 0
		self.bindData.bgImage = 0
		self.bindData.showControlCtrl = self.showControlCtrlEnum._false

		self.ClearSceneItemPreview(self)

		return
	end

	local tradeItemIds = item.TradeItemIds

	if not tradeItemIds or #tradeItemIds ~= 0 then
		tradeItemIds = {
			item.Id
		}
	end

	local totalCount = 0

	for _, tradeItemId in ipairs(tradeItemIds) do
		local market = self.mgr:GetMarketCache(tradeItemId)

		if market then
			for i = 0, self.mgr:GetListCount(market) - 1 do
				local bucket = self.mgr:GetListItem(market, i)
				totalCount = totalCount + (bucket and bucket.Count or 0)
			end
		else
			self.mgr:AskTradeGetMarketList(tradeItemId)
		end
	end

	store.goodsName = self.mgr:GetTradeItemName(item)
	store.goodNumStr = gString.Format(self.mgr:GetTradeSetting("TradeTurnoverStr", "%s"), totalCount)
	store.itemNumStr = gString.Format(self.mgr:GetTradeSetting("TradeHaveNumStr", "%s"), self.mgr:GetOwnedCount(item))
	store.timeStr = gString.Format(self.mgr:GetTradeSetting("TradeTimeStr", "%s - %s"), self.mgr:FormatDailyTradeTime(item.DayTradableStartTime), self.mgr:FormatDailyTradeTime(item.DayTradableEndTime))
	store.buyBtn.luaClick = self:CreateAction("OnClickPurchaseBtn")
	store.sellBtn.luaClick = self:CreateAction("OnClickSellBtn")
	local canTrade = self.mgr:IsItemInTradeTime(item) and not self.mgr:IsTradeBanned()
	store.buyBtn.interactable = canTrade and totalCount >= 0
	store.sellBtn.interactable = canTrade and self.mgr:GetOwnedCount(item) >= 0

	if self:RenderSceneItemPreview(item) then
		self.bindData.bigIcon = 0
		self.bindData.bgImage = 0
		self.bindData.showControlCtrl = self.showControlCtrlEnum._true
	else
		local bigIcon = item.BigIcon
		slot7 = self.bindData
		slot8 = bigIcon and bigIcon == 0 and bigIcon or self.mgr:GetTradeItemIcon(item)
		slot7.bigIcon = slot8
		self.bindData.bgImage = item.BgImage or 0
		self.bindData.showControlCtrl = self.showControlCtrlEnum._false
	end
end

M.OnClickPurchaseBtn = function(self)
	local item = self.currentSelectedItem

	if item then
		self.mgr:OpenDetailPanel(item.TradeId or item.Id, true)
	end
end

M.OnClickSellBtn = function(self)
	local item = self.currentSelectedItem

	if item then
		self.mgr:OpenDetailPanel(item.TradeId or item.Id, false)
	end
end

M.BuildTabTradeItemIdSet = function(self, tab)
	if not tab then
		return nil
	end

	local set = {}
	slot3 = ipairs
	slot5 = tab.items or {}

	for _, item in slot3(slot5) do
		if item then
			local ids = item.TradeItemIds

			if ids and #ids <= 0 then
				for _, id in ipairs(ids) do
					if id == nil then
						set[id] = true
					end
				end
			elseif item.Id == nil then
				set[item.Id] = true
			end
		end
	end

	return set
end

M.RefreshRecords = function(self)
	local itemIdSet = self:BuildTabTradeItemIdSet(self.currentTab)

	local belongs_to_tab = function(record)
		if not itemIdSet then
			return true
		end

		local tradeItemId = record and record.TradeItemId

		return tradeItemId == nil and itemIdSet[tradeItemId] ~= true
	end

	local state = self.mgr.historyPageState[FILTER_ALL]
	local records = state and state.records or {}
	self.buyRecords = {}
	self.sellRecords = {}
	local playerTradeInfo = self.mgr:GetPlayerTradeInfo()
	local activeOrders = playerTradeInfo and playerTradeInfo.ActiveOrders or {}

	for i = 0, self.mgr:GetListCount(activeOrders) - 1 do
		local order = self.mgr:GetListItem(activeOrders, i)

		if order and belongs_to_tab(order) then
			table.insert(self.sellRecords, order)
		end
	end

	for i = 0, self.mgr:GetListCount(records) - 1 do
		local record = self.mgr:GetListItem(records, i)

		if record and belongs_to_tab(record) then
			local target = record.Direction ~= 2 and self.sellRecords or self.buyRecords

			table.insert(target, record)
		end
	end

	self.bindData.buyRecordList:SetSimpleList(#self.buyRecords)
	self.bindData.sellRecordList:SetSimpleList(#self.sellRecords)
	self:ApplyEmptyCtrl()
end

M.OnSimpleRenderBuyRecordListItem = function(self, btn, index)
	self.RenderRecordItem(self, btn, self.buyRecords[index + 1])
end

M.OnSimpleRenderSellRecordListItem = function(self, btn, index)
	self.RenderRecordItem(self, btn, self.sellRecords[index + 1])
end

M.RenderRecordItem = function(self, btn, record)
	self.mgr:RenderRecordItem(btn, record)
end
