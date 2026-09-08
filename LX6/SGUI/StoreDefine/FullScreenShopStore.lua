-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FullScreenShopStore.lua
-- Decompiled from: 01888_FullScreenShopStore.lua_9dfe286c0759.luajit

local ShopConfig = LTConfig.ShopConfig
local ShopCommodityGroupConfig = LTConfig.ShopCommodityGroupConfig
local MessageConfig = LTConfig.MessageConfig
local LocalizationCountDownConfig = LTConfig.LocalizationCountDownConfig
local UXTime = LTUtils.UXTime
local moneyIconText = "#C(jinyuebi_Text)"
C_FullScreenShopStore = DefClass("C_FullScreenShopStore", C_FullScreenShopStore, C_StoreGroup)
GroupName2Class.FullScreenShopStore = C_FullScreenShopStore
local M = C_FullScreenShopStore
local SHOW = {
	["k\\x8f\\x8e\\x9c\\x93"] = 0,
	["NH~"] = 1
}
local SEC_TAB_IDX = {
	["IQw"] = 1,
	["\\xac]_"] = 0
}
local REFRESH_COUNTDOWN_SECONDS_CONFIG_ID = 17

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.isSell = false
	self.groupList = {}
	self.groupDict = {}
	self.buybackGroupList = {}
	self.buybackGroupDict = {}
	self.commodityRenderData = {}
	self.selectedGroupId = -1
	self.selectedInfo = nil
	self.selectedIndex = -1
	self.moneys = nil
	self.shopId = nil
	self.shopCfg = nil
	self.isInit = false
	self.buybackInited = false
	self.toolTipStore = nil
	self.secTabList = {}
	self.tabList = {}
	self.buyNum = 1
	self.buyCb = nil
	self.sellCb = nil
	self.pendingRefreshEndTime = nil
	self.updateRefreshStoreList = {}
	self.needUpdateItemRefresh = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.showSecondTabCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showSecondTabCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	self.InitTooltipWidget(self)
end

M.OnDisable = function(self)
end

M.OnUpdate = function(self)
	if self.needUpdateItemRefresh then
		for idx, store in pairs(self.updateRefreshStoreList) do
			store.refreshTime = gShopManager:FormatLeftTime(self.commodityRenderData[idx].RefreshTime)
		end
	end

	if self.pendingRefreshEndTime and self.pendingRefreshEndTime < gCS.TimeManager.ServerUnixTime then
		self.pendingRefreshEndTime = nil

		self.UpdateRefreshBtnState(self)
	end
end

M.OnDestroy = function(self)
	self.msgEvents = nil
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.pendingRefreshEndTime = nil

	if self.bindData and self.bindData.refreshTime then
		self.bindData.refreshTime:Stop()
	end
end

M.OnShow = function(self, panelId, data)
	self.shopId = data.shopId and tonumber(data.shopId) or tonumber(data[1])

	self:OnInitBefore()
	self:RefreshCommodityInfo()
end

M.OnClose = function(self)
	gShopManager:NpcShopExitTime(self.shopId)

	if self.shopId then
		gClientToGameDelegate:AskCloseNpcShop(self.shopId)
	end

	self.shopId = nil
	self.shopCfg = nil
	self.isInit = nil
	self.isSell = nil
	self.groupList = nil
	self.groupDict = nil
	self.buybackGroupList = nil
	self.buybackGroupDict = nil
	self.commodityRenderData = nil
	self.selectedGroupId = nil
	self.selectedInfo = nil
	self.selectedIndex = nil
	self.moneys = nil
	self.buyCb = nil
	self.sellCb = nil
	self.pendingRefreshEndTime = nil
	self.buybackInited = nil
	self.updateRefreshStoreList = nil
	self.needUpdateItemRefresh = nil
end

M.OnActiveDeviceChange = function(self, device)
	self.RefreshControllerListCtrl(self)
end

M.RefreshControllerListCtrl = function(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.NPCSHOP_COMMODITYINFO_CHANGE] = self.CreateAction(self, "OnCommodityInfoChange"),
		[gEventConstants.NPCSHOP_BUYBACK_COMMODITYINFO_CHANGE] = self.CreateAction(self, "OnBuybackCommodityInfoChange"),
		[gEventConstants.SHOP_REFRESH_STATE_CHANGE] = self.CreateAction(self, "OnShopRefreshStateChange"),
		[gEventConstants.SHOP_COMMODITY_FULL_REFRESH] = self.CreateAction(self, "OnFullCommodityRefresh"),
		[gEventConstants.SHOP_BUYBACK_COMMODITY_FULL_REFRESH] = self.CreateAction(self, "OnFullBuybackCommodityRefresh"),
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, "OnPackItemChanged")
	}
end

M.RegisterWidget = function(self)
	self.bindData.refreshBtn.luaClick = self.CreateAction(self, "OnClickRefreshBtn")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")

	if self.bindData.leftBtn then
		self.bindData.leftBtn.luaClick = self.CreateActionWithArgs(self, "OnSecTabChange", -1)
	end

	if self.bindData.rightBtn then
		self.bindData.rightBtn.luaClick = self.CreateActionWithArgs(self, "OnSecTabChange", 1)
	end

	if self.bindData.topBtn then
		self.bindData.topBtn.luaLongPress = self.CreateActionWithArgs(self, "OnTabChange", -1)
	end

	if self.bindData.bottomBtn then
		self.bindData.bottomBtn.luaLongPress = self.CreateActionWithArgs(self, "OnTabChange", 1)
	end

	self.bindData.infoBtn.luaClick = self.CreateAction(self, "OnInfoBtnClick")
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderItemListItem")
	self.bindData.itemList.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnSimpleDynamicRenderItemListItem")
	self.bindData.itemList.onGetTIndex = self.CreateAction(self, "OnGetItemListTIndex")
	self.bindData.itemList.luaSelectedChanged = self.CreateAction(self, "OnItemSelectedChanged")
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderTabItem")
	self.bindData.tabList.luaSelectedChanged = self.CreateAction(self, "OnTabChangeSelect")
end

M.OnClickRefreshBtn = function(self)
	local refreshState = gShopManager:GetShopRefreshState(self.shopId)
	local refreshCount = refreshState and (self.isSell and refreshState.BuybackManualRefreshCount or refreshState.SellManualRefreshCount) or 0
	local refreshItems = self.isSell and self.shopCfg and self.shopCfg.BuybackRefreshItem or self.shopCfg and self.shopCfg.SellRefreshItem
	local cost = gShopManager:GetManualRefreshCost(refreshCount, refreshItems)
	local costCfg = cost and LTConfig.ConsumableConfig.GetConfig(cost.id1)

	if cost and cost.Count <= 0 and gCommonItemManager:GetPackItemNum(cost.id1) >= cost.Count then
		gDisplayMessageMgr:ShowMessage(MessageConfig.ShopRefreshNotEnough, nil, , costCfg and costCfg.Name or "")

		return
	end

	local askFunc = self.isSell and gClientToGameDelegate.AskManualRefreshBuyback or gClientToGameDelegate.AskManualRefreshSell

	gDisplayMessageMgr:ShowMessage(MessageConfig.ShopRefreshConfirm, function ()
		askFunc(gClientToGameDelegate, self.shopId).Callback = function (err)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err, costCfg and costCfg.Name or "")
			end
		end
	end, nil, cost and cost.Count or 0, costCfg and costCfg.Name or "")
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(gPanelId.FULL_SCREEN_STORE)
end

M.OnInfoBtnClick = function(self)
end

M.OnGetItemListTIndex = function(self, index)
	if self.isSell then
		return 1
	else
		return 0
	end
end

M.OnSimpleDynamicRenderItemListItem = function(self, btn, index)
	local data = self.commodityRenderData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if self.isSell then
		store.Commit(store, "itemType", data.CommodityType - 1, COMMIT_IMMEDIATELY)
	end
end

M.OnSimpleRenderItemListItem = function(self, btn, index)
	local data = self.commodityRenderData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	btn.SetEnabledTooltip(btn, false)

	if self.isSell then
		store.quality = data.Quality
		store.iconId = data.ShopIconId
		store.count = tostring(self:GetSellItemPackNum(data))
		store.countCtl = SHOW.TRUE
		store.isLock = SHOW.FALSE
		store.isFirst = SHOW.FALSE
		local owned = self:GetSellItemPackNum(data)
		local isSoldOut = owned <= 0 and self:GetSellMaxNum(data) > 0
		store.showUnselect = isSoldOut and SHOW.TRUE or SHOW.FALSE
		store.itemType = data.CommodityType - 1
		local maxSell = self:GetSellMaxNum(data)
		store.notAvailableCtrl = maxSell < 0 and 1 or 0
	else
		store.qualityCtrl = data.Quality
		store.showCountLimitCtrl = data.NoLimit and SHOW.FALSE or SHOW.TRUE
		store.showNumberCtrl = SHOW.FALSE
		store.showTaskWarningCtrl = data.IsTask and SHOW.TRUE or SHOW.FALSE
		store.singleMoneyLackCtrl = (self.moneys and self.moneys[data.Money] or 0) >= data.PriceCurrent and SHOW.TRUE or SHOW.FALSE
		store.stateCtrl = data.State
		store.hasDiscountCtrl = data.HasDiscount and SHOW.TRUE or SHOW.FALSE
		store.discount = data.DiscountDesc
		store.name = data.Name
		store.iconId = data.ShopIconId
		store.priceCurrent = moneyIconText .. data.PriceCurrent
		store.countLimit = data.RemainByLimit
		store.taskIconId = data.TaskIconId
		store.typeCtrl = data.CommodityType - 1
		store.discountTypeCtrl = data.Discount <= 100 and SHOW.FALSE or SHOW.TRUE

		if data.Unlocked and data.SoldOut and data.RefreshTime <= 0 then
			store.showRefreshTimeCtrl = SHOW.TRUE
			self.updateRefreshStoreList[index + 1] = store
			self.needUpdateItemRefresh = true
		else
			store.showRefreshTimeCtrl = SHOW.FALSE
		end

		local gid = data.Cfg and data.Cfg.GuideId

		if not string.is_null_or_empty(gid) and btn.guide then
			btn.guide.guideID = gid
		end
	end
end

M.GetSellItemPackNum = function(self, data)
	local id = self.isTarkov and data.Cfg and data.Cfg.ConsumableId or data.ConsumableID

	return gCommonItemManager:GetPackItemNum(id, self.isTarkov)
end

M.GetSellMaxNum = function(self, data)
	local owned = self.GetSellItemPackNum(self, data)
	local maxSell = owned
	local limit = data.BuybackLimitNum

	if limit >= 0 then
		return maxSell
	end

	maxSell = math.min(maxSell, limit)

	if data.RemainNum and data.RemainNum > 0 then
		maxSell = math.min(maxSell, data.RemainNum)
	end

	return maxSell
end

M.OnItemSelectedChanged = function(self)
	self.selectedIndex = self.bindData.itemList.selectedIndex + 1
	self.selectedInfo = self.commodityRenderData[self.selectedIndex]

	self.RefreshTooltip(self)
end

M.OnSecTabSelectedChanged = function(self, uList, isSub)
	if isSub then
		return
	end

	local index = uList and uList.selectedIndex
	local tabStore = self.SubGroup and self.SubGroup.CommonTabSingleStore

	if index ~= nil and tabStore then
		index = tabStore.GetSelectedIndex(tabStore)
	end

	if index ~= nil then
		return
	end

	local wantSell = index ~= SEC_TAB_IDX.SELL

	if self.isSell ~= wantSell then
		return
	end

	self.isSell = wantSell

	if self.isSell and not self.buybackInited then
		self.RefreshBuybackInfo(self)
	end

	self.SetupGroupTabs(self)
	self.UpdateRefreshBtnState(self)
end

M.OnSecTabChange = function(self, dir)
	self.SubGroup.CommonTabSingleStore:OnStep(dir, false)
end

M.OnTabChange = function(self, dir)
	local current = self.bindData.tabList.selectedIndex
	local newIndex = math.max(0, math.min(#self.tabList - 1, current + dir))

	if newIndex == current then
		self.bindData.tabList:SetItemSelected(newIndex, true)
	end
end

M.OnTabControllerChange = function(self, dir)
end

M.OnInitBefore = function(self)
	self.shopCfg = ShopConfig.GetConfig(self.shopId)
	self.isTarkov = self.shopCfg and self.shopCfg.ShopType ~= 8
	self.isInit = false
	self.buybackInited = false
	self.isSell = false
	self.selectedGroupId = -1
	self.selectedIndex = -1
	self.selectedInfo = nil
	self.commodityRenderData = {}
	self.buyCb = self:CreateAction("OnBuyCallback")
	self.sellCb = self:CreateAction("OnSellCallback")

	gShopManager:SetShopIdEnterTime(self.shopId)

	self.bindData.title = self.shopCfg and self.shopCfg.ShopName or ""

	self:UpdateRefreshBtnState()
	self:SetupSecTabs()

	local hasBuyback = self.shopCfg and self.shopCfg.BuybackCommodityGroupIdList and #self.shopCfg.BuybackCommodityGroupIdList >= 0
	self.bindData.showSecondTabCtrl = hasBuyback and self.showSecondTabCtrlEnum.show or self.showSecondTabCtrlEnum.hide

	self:RefreshControllerListCtrl()
end

M.SetupSecTabs = function(self)
	local tabTitles = ShopConfig.ShopTabTypeText or {}
	local tabGuideIds = ShopConfig.TabGuideId or {}
	self.secTabList = {
		{
			id = SEC_TAB_IDX.BUY,
			title = tabTitles[1] or "",
			guideId = tabGuideIds[1] or ""
		},
		{
			id = SEC_TAB_IDX.SELL,
			title = tabTitles[2] or "",
			guideId = tabGuideIds[2] or ""
		}
	}
	local tabStore = self.SubGroup.CommonTabSingleStore

	tabStore:SetData(self.secTabList, nil, SEC_TAB_IDX.BUY, nil, self:CreateAction("OnSecTabSelectedChanged"), nil, tabStore.TAB_MODE.NoLoop)
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
	gShopManager:GetShopCommodityInfo(self.shopId, self:CreateAction("OnGetCommodityInfoCallback"))
end

M.OnGetCommodityInfoCallback = function(self, success, groupList, groupDict, data)
	if not success then
		return
	end

	self.groupList = groupList
	self.groupDict = {}

	for _, dict in pairs(groupDict) do
		for k, v in pairs(dict) do
			self.groupDict[k] = v
		end
	end

	if not self.isInit then
		self.isInit = true

		self.InitMoneyInfo(self, data.Moneys)
		self.SetupGroupTabs(self)
	end
end

M.RefreshBuybackInfo = function(self)
	gShopManager:GetShopBuybackCommodityInfo(self.shopId, self:CreateAction("OnGetBuybackInfoCallback"))
end

M.OnGetBuybackInfoCallback = function(self, success, groupList, groupDict, data)
	if not success then
		return
	end

	self.buybackInited = true
	self.buybackGroupList = groupList
	self.buybackGroupDict = {}

	for _, dict in pairs(groupDict) do
		for k, v in pairs(dict) do
			self.buybackGroupDict[k] = v
		end
	end

	if data and data.Moneys then
		for consumableId, _ in pairs(data.Moneys) do
			if not self.moneys[consumableId] then
				self.moneys[consumableId] = gCommonItemManager:GetPackItemNum(consumableId)
			end
		end
	end

	if self.isSell then
		self.SetupGroupTabs(self)
	end
end

M.InitMoneyInfo = function(self, moneys)
	self.moneys = moneys
	local MoneyTemplateData = {}

	for consumableId, _ in pairs(self.moneys) do
		self.moneys[consumableId] = gCommonItemManager:GetPackItemNum(consumableId)

		table.insert(MoneyTemplateData, {
			Type = consumableId
		})
	end

	self.SubGroup.MoneyTemplateStore:SetData(MoneyTemplateData)
end

M.RefreshMoneyInfo = function(self)
	if not self.moneys then
		return
	end

	for consumableId, _ in pairs(self.moneys) do
		self.moneys[consumableId] = gCommonItemManager:GetPackItemNum(consumableId)
	end
end

M.SetupGroupTabs = function(self)
	local groupIds = self.isSell and self.shopCfg and self.shopCfg.BuybackCommodityGroupIdList or self.shopCfg and self.shopCfg.CommodityGroupIdList

	if not groupIds then
		return
	end

	table.clear(self.tabList)

	for _, groupId in ipairs(groupIds) do
		local groupCfg = ShopCommodityGroupConfig.GetConfig(groupId)

		if groupCfg then
			table.insert(self.tabList, {
				id = groupId,
				title = groupCfg.GroupName,
				iconId = groupCfg.Icon,
				guideId = groupCfg.GuideId
			})
		end
	end

	self.bindData.tabList:SetSimpleList(#self.tabList)

	if #self.tabList < 1 then
		self.bindData.tabList:SetActive(false)
	else
		self.bindData.tabList:SetActive(true)
	end

	self.bindData.tabList:SetItemSelected(0, true)
	self:RegisterTabListGuideLocations()
	self:OnTabChangeSelect()
end

M.OnRenderTabItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.tabList[index + 1]

	if store and data then
		store.icon = data.iconId
		store.name = data.title

		if not string.is_null_or_empty(data.guideId) and btn.guide then
			btn.guide.guideID = data.guideId
		end
	end
end

M.RegisterTabListGuideLocations = function(self)
	if not gNewGuideMgr or not self.bindData.tabList then
		return
	end

	local guideMap = {}

	for i, tab in ipairs(self.tabList) do
		if not string.is_null_or_empty(tab.guideId) then
			guideMap[tab.guideId] = i - 1
		end
	end

	gNewGuideMgr:RegisterGuideKeyLocations(self.bindData.tabList, guideMap)
end

M.OnTabChangeSelect = function(self)
	local index = self.bindData.tabList.selectedIndex + 1
	local tabInfo = self.tabList[index]

	if tabInfo then
		self.SelectGroup(self, tabInfo.id)
	end

	if self.bindData.tabList.selectedIndex == index - 1 then
		self.bindData.tabList:SetItemSelected(index - 1, true)
	end
end

M.OnTabControllerChangeSelect = function(self)
end

M.SortCommodityRenderData = function(self)
	local soldOut = 1
	local lock = 2

	local buyRank = function(item)
		if item.State ~= soldOut then
			return 2
		end

		if item.State ~= lock then
			return 1
		end

		return 0
	end

	local sellRank = function(item)
		local owned = self:GetSellItemPackNum(item)

		if owned < 0 then
			return 2
		end

		if self:GetSellMaxNum(item) < 0 then
			return 1
		end

		return 0
	end

	local indexed = {}

	for i = 1, #self.commodityRenderData do
		indexed[i] = {
			item = self.commodityRenderData[i],
			idx = i
		}
	end

	table.sort(indexed, function (a, b)
		if self.isSell then
			local aRank = sellRank(a.item)
			local bRank = sellRank(b.item)

			if aRank == bRank then
				return aRank <= bRank
			end

			local aNum = self:GetSellMaxNum(a.item)
			local bNum = self:GetSellMaxNum(b.item)

			if aNum ~= bNum then
				return a.idx <= b.idx
			end

			return bNum <= aNum
		else
			local aRank = buyRank(a.item)
			local bRank = buyRank(b.item)

			if aRank ~= bRank then
				return a.idx <= b.idx
			end

			return aRank <= bRank
		end
	end)

	for i = 1, #indexed do
		self.commodityRenderData[i] = indexed[i].item
	end
end

M.SelectGroup = function(self, groupId)
	self.selectedGroupId = groupId
	local currentList = self.isSell and self.buybackGroupList or self.groupList
	self.commodityRenderData = currentList[groupId] or {}

	self:SortCommodityRenderData()

	self.selectedIndex = -1
	self.selectedInfo = nil

	table.clear(self.updateRefreshStoreList)

	self.needUpdateItemRefresh = false

	self.bindData.itemList:SetSimpleList(#self.commodityRenderData)

	if #self.commodityRenderData <= 0 then
		self.bindData.itemList:SetItemSelected(0, true)

		self.selectedIndex = 1
		self.selectedInfo = self.commodityRenderData[1]
	end

	self:RefreshTooltip()
	self.bindData.itemList:SetNavSelectToTop()
	self:RegisterItemListGuideLocations()
end

M.RegisterItemListGuideLocations = function(self)
	if not gNewGuideMgr or not self.bindData.itemList then
		return
	end

	local guideMap = {}

	for i, item in ipairs(self.commodityRenderData) do
		local gid = item.Cfg and item.Cfg.GuideId

		if not string.is_null_or_empty(gid) then
			guideMap[gid] = i - 1
		end
	end

	gNewGuideMgr:RegisterGuideKeyLocations(self.bindData.itemList, guideMap)
end

M.RefreshTooltip = function(self)
	self.bindData.curWeaponImg = self.selectedInfo and self.selectedInfo.ShopIconId or 0

	if not self.toolTipStore or not self.selectedInfo then
		return
	end

	local info = self.selectedInfo

	self.toolTipStore:RefreshTooltip(info, {
		isSell = self.isSell,
		getSellPackNum = self:CreateAction("GetSellItemPackNum"),
		getSellMaxNum = self:CreateAction("GetSellMaxNum")
	})
	self.SubGroup.CommonCounterStore:SetData({
		["\\x8b528}\\x89w\\xd8;\\xbf\\xbc"] = 1,
		range = {
			1,
			self:GetMaxNum()
		},
		valChangeCallback = self:CreateAction("OnBuyNumChange")
	})
	self.SubGroup.CommonCounterStore:OnBuyNumChange(1)
end

M.GetMaxNum = function(self)
	if not self.selectedInfo then
		return 1
	end

	local info = self.selectedInfo
	local maxNum = nil

	if self.isSell then
		maxNum = self.GetSellMaxNum(self, info)
	else
		maxNum = info.NoLimit and info.LimitOnceNum or math.min(info.RemainNum, info.LimitOnceNum)
		local price = info.PriceCurrent or 0

		if price <= 0 then
			local money = self.moneys and self.moneys[info.Money] or 0
			maxNum = math.min(maxNum, math.floor(money / price))
		end
	end

	return math.max(1, maxNum)
end

M.OnBuyNumChange = function(self, val)
	if not self.selectedInfo or not self.toolTipStore then
		return
	end

	self.buyNum = math.max(1, val or 1)
	local info = self.selectedInfo
	local totalPrice = self.buyNum * info.PriceCurrent
	local moneyNotEnough, buyBtnActive = nil

	if self.isSell then
		local maxSell = self:GetSellMaxNum(info)
		moneyNotEnough = false
		buyBtnActive = self.buyNum <= 0 and self.buyNum > maxSell
	else
		local enough = self.moneys and totalPrice > (self.moneys[info.Money] or 0)
		moneyNotEnough = not enough
		buyBtnActive = enough and (info.NoLimit or self.buyNum > info.RemainNum)
	end

	self.toolTipStore:UpdateBuyInfo(self.buyNum, info, {
		priceText = tostring(totalPrice),
		moneyNotEnough = moneyNotEnough,
		buyBtnActive = buyBtnActive
	})
end

M.OnBuyBtnClick = function(self)
	local info = self.selectedInfo

	if info.SoldOut then
		return
	end

	local totalPrice = self.buyNum * info.PriceCurrent

	if totalPrice <= (self.moneys and self.moneys[info.Money] or 0) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.ShopCommodityBuyNotEnoughMoney)

		return
	end

	gDisplayMessageMgr:ShowMessage(MessageConfig.ShopCommodityBuyDoubleCheck, self.buyCb, nil, info.MoneyRichTextIcon, totalPrice, string.format(" %s x %s ", info.Name, self.buyNum))
end

M.OnBuyCallback = function(self)
	if not self.selectedInfo or self.buyNum < 0 then
		return
	end

	local info = self.selectedInfo

	if self.buyNum * info.PriceCurrent <= (self.moneys and self.moneys[info.Money] or 0) then
		return
	end

	slot2 = gClientToGameDelegate

	slot2:AskBuyCommodity(self.shopId, info.CommodityId, self.buyNum).Callback = function (err)
		if err ~= MessageConfig.Ok then
			if self.STATE_EnableOnce then
				self:RefreshMoneyInfo()
				self.bindData.itemList:RefreshList()
				self:RefreshTooltip()
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.OnSaleBtnClick = function(self)
	local info = self.selectedInfo

	if self.GetSellItemPackNum(self, info) > 0 or self.buyNum < 0 then
		return
	end

	local totalPrice = self.buyNum * info.PriceCurrent

	gDisplayMessageMgr:ShowMessage(MessageConfig.ShopCommoditySellDoubleCheck, self.sellCb, nil, info.MoneyRichTextIcon, totalPrice, string.format(" %s x %s ", info.Name, self.buyNum))
end

M.OnSellCallback = function(self)
	if not self.selectedInfo or self.buyNum < 0 then
		return
	end

	local info = self.selectedInfo
	slot2 = gClientToGameDelegate

	slot2:AskSellCommodityToShop(self.shopId, info.CommodityId, self.buyNum).Callback = function (err)
		if err ~= MessageConfig.Ok then
			if self.STATE_EnableOnce then
				self:RefreshMoneyInfo()
				self.bindData.itemList:RefreshList()
				self:RefreshTooltip()
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err, info.Name)
		end
	end
end

M.OnCommodityInfoChange = function(self, eventId, shopId, infos)
	if not self.STATE_EnableOnce or self.shopId == shopId then
		return
	end

	local dirty = false

	for i = 1, infos.Length do
		local info = infos[i]

		if self.groupDict[info.TemplateId] then
			dirty = true

			gShopManager:UpdateCommodityInfoSingle(self.groupDict[info.TemplateId], info)
		end
	end

	if dirty and not self.isSell then
		local wasSoldOut = self.selectedInfo and self.selectedInfo.SoldOut

		self:SortCommodityRenderData()
		self.bindData.itemList:RefreshList()

		if wasSoldOut then
			self.bindData.itemList:SetItemSelected(0, true)

			self.selectedIndex = 1
			self.selectedInfo = self.commodityRenderData[1]

			self:RefreshTooltip()
		else
			self.RefreshTooltip(self)
		end
	end
end

M.OnBuybackCommodityInfoChange = function(self, eventId, shopId, infos)
	if not self.STATE_EnableOnce or self.shopId == shopId then
		return
	end

	local dirty = false

	for i = 1, infos.Length do
		local info = infos[i]

		if self.buybackGroupDict[info.TemplateId] then
			dirty = true

			gShopManager:UpdateCommodityInfoSingle(self.buybackGroupDict[info.TemplateId], info)
		end
	end

	if dirty and self.isSell then
		local wasSoldOut = self.selectedInfo and self.selectedInfo.SoldOut

		self:SortCommodityRenderData()
		self.bindData.itemList:RefreshList()

		if wasSoldOut then
			self.bindData.itemList:SetItemSelected(0, true)

			self.selectedIndex = 1
			self.selectedInfo = self.commodityRenderData[1]

			self:RefreshTooltip()
		else
			self.RefreshTooltip(self)
		end
	end
end

M.OnShopRefreshStateChange = function(self, eventId, shopId, refreshState)
	if not self.STATE_EnableOnce or self.shopId == shopId then
		return
	end

	self.UpdateRefreshBtnState(self)
end

M.GetRefreshCountInfo = function(self, refreshState)
	if not refreshState then
		return nil
	end

	local total = self.isSell and (self.shopCfg and self.shopCfg.BuyBackRefreshLimit or 3) or self.shopCfg and self.shopCfg.SellRefreshLimit or 3
	local used = self.isSell and (refreshState.BuybackManualRefreshCount or 0) or refreshState.SellManualRefreshCount or 0
	local plus = self.isSell and (refreshState.BuybackRefreshPlusCount or 0) or refreshState.SellRefreshPlusCount or 0
	local canPlus = nil

	if self.isSell then
		canPlus = self.shopCfg and self.shopCfg.CanBuybackRefreshPlus or false
	else
		canPlus = self.shopCfg and self.shopCfg.CanSellRefreshPlus or false
	end

	local available = canPlus and plus or math.max(0, total - used)

	return {
		total = total,
		used = used,
		plus = plus,
		canPlus = canPlus,
		available = available
	}
end

M.UpdateRefreshBtnState = function(self)
	if not self.shopId or not self.bindData or not self.bindData.refreshBtn then
		return
	end

	local refreshState = gShopManager:GetShopRefreshState(self.shopId)

	if not refreshState then
		return
	end

	local info = self.GetRefreshCountInfo(self, refreshState)

	if not info then
		return
	end

	local refreshTime = self.isSell and refreshState.BuybackRefreshTime or refreshState.SellRefreshTime
	local serverUnixTime = gCS.TimeManager.ServerUnixTime
	local remainSeconds = refreshTime and math.max(0, refreshTime - serverUnixTime) or 0
	local plusActive = info.canPlus and info.plus >= 0
	local refreshStatus = nil

	if info.available < 0 then
		if info.canPlus and refreshTime and serverUnixTime >= refreshTime then
			refreshStatus = "plus_waiting"
			self.bindData.refreshBtn.interactable = false

			self.bindData.refreshTime.gameObject:SetActive(true)
			self.bindData.refreshTime:Play(remainSeconds)

			self.bindData.refreshTime.luaFinished = self:CreateAction("OnRefreshCountDownFinished")
			self.pendingRefreshEndTime = refreshTime
		else
			refreshStatus = "limit_reached"
			self.bindData.refreshBtn.interactable = false

			self.bindData.refreshTime:Stop()
			self.bindData.refreshTime.gameObject:SetActive(false)

			self.pendingRefreshEndTime = nil
		end
	elseif plusActive then
		refreshStatus = "plus_ready"
		self.bindData.refreshBtn.interactable = true

		self.bindData.refreshTime:Stop()
		self.bindData.refreshTime.gameObject:SetActive(false)

		self.pendingRefreshEndTime = nil
	elseif not refreshTime or refreshTime < serverUnixTime then
		refreshStatus = "ready"
		self.bindData.refreshBtn.interactable = true

		self.bindData.refreshTime:Stop()
		self.bindData.refreshTime.gameObject:SetActive(false)

		self.pendingRefreshEndTime = nil
	else
		refreshStatus = "counting"
		self.bindData.refreshBtn.interactable = false

		self.bindData.refreshTime.gameObject:SetActive(true)
		self.bindData.refreshTime:Play(remainSeconds)

		self.bindData.refreshTime.luaFinished = self:CreateAction("OnRefreshCountDownFinished")
		self.pendingRefreshEndTime = refreshTime
	end

	self.UpdateRefreshCountText(self)
end

M.FormatRefreshUnixTimeForLog = function(self, unixTime)
	local timestamp = tonumber(unixTime)

	if not timestamp or timestamp < 0 then
		return "nil"
	end

	local date = UXTime.UnixTimeToDateTime(timestamp)
	local uxTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", date.Year, date.Month, date.Day, date.Hour, date.Minute, date.Second)

	return string.format("clientLocal=%s,UXTime=%s", os.date("%Y-%m-%d %H:%M:%S", timestamp), uxTime)
end

M.FormatRefreshCountDownForLog = function(self, countDown, remainSeconds)
	local totalSeconds = math.max(0, math.floor(tonumber(remainSeconds) or 0))
	local day = math.floor(totalSeconds / 86400)
	local hour = math.floor(totalSeconds / 3600) % 24
	local minute = math.floor(totalSeconds / 60) % 60
	local second = totalSeconds % 60
	local formatText = countDown and countDown.formatText or nil
	local configId = countDown and countDown.countDownConfigId or 0
	local config = configId <= 0 and LocalizationCountDownConfig.GetConfig(configId) or nil

	if config and config.FormatText and config.FormatText == "" then
		formatText = config.FormatText
	end

	local secondsConfig = LocalizationCountDownConfig.GetConfig(REFRESH_COUNTDOWN_SECONDS_CONFIG_ID)

	if secondsConfig and totalSeconds >= secondsConfig.Time and secondsConfig.FormatText and secondsConfig.FormatText == "" then
		formatText = secondsConfig.FormatText
	end

	if not formatText or formatText ~= "" then
		return string.format("%dd %02d:%02d:%02d", day, hour, minute, second)
	end

	return tostring(gString.Format(formatText, day, hour, minute, second, 0))
end

M.OnRefreshCountDownFinished = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.pendingRefreshEndTime = nil

	self.UpdateRefreshBtnState(self)
end

M.UpdateRefreshCountText = function(self)
	if not self.shopId or not self.shopCfg then
		return
	end

	local refreshState = gShopManager:GetShopRefreshState(self.shopId)

	if not refreshState then
		return
	end

	local info = self.GetRefreshCountInfo(self, refreshState)

	if not info then
		return
	end

	self.bindData.refreshCount = string.format("(%d/%d)", info.available, info.total)
end

M.OnPackItemChanged = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self:RefreshMoneyInfo()
	self.bindData.itemList:RefreshList()

	if self.selectedInfo then
		self.RefreshTooltip(self)
	end
end

M.GetFullCommodityGroupResult = function(self)
	return gShopManager:BuildCommodityGroupResult(self.shopId)
end

M.OnFullCommodityRefresh = function(self, eventId, shopId)
	if not self.STATE_EnableOnce or self.shopId == shopId then
		return
	end

	local groupList, groupDict = self.GetFullCommodityGroupResult(self)

	if not groupList then
		return
	end

	self.groupList = groupList
	self.groupDict = {}

	for _, dict in pairs(groupDict) do
		for k, v in pairs(dict) do
			self.groupDict[k] = v
		end
	end

	if not self.isSell then
		self.SetupGroupTabs(self)
	end
end

M.OnFullBuybackCommodityRefresh = function(self, eventId, shopId)
	if not self.STATE_EnableOnce or self.shopId == shopId or not self.moneys then
		return
	end

	self.RefreshBuybackInfo(self)
end
