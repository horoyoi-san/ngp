-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AnantarkovShopMainPanelStore.lua
-- Decompiled from: 01976_AnantarkovShopMainPanelStore.lua_b221363c85da.luajit

C_AnantarkovShopMainPanelStore = DefClass("C_AnantarkovShopMainPanelStore", C_AnantarkovShopMainPanelStore, C_AnantarkovBagStoreBase)
GroupName2Class.AnantarkovShopMainPanelStore = C_AnantarkovShopMainPanelStore
local M = C_AnantarkovShopMainPanelStore
local CommodityTypeConfig = LTConfig.ShopCommodityTypeConfig
local MessageConfig = LTConfig.MessageConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.typeCtrlEnum = {
		["I'qW"] = 1,
		["\\xac}"] = 0
	}
	self.showStorageListCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.moneyEmptyCtrlEnum = {
		["\\x9cmb"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.showInfoCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.typeCtrlEnum = nil
	self.showStorageListCtrlEnum = nil
	self.moneyEmptyCtrlEnum = nil
	self.showInfoCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self._dragCanPlaceCtx = nil

	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, args)
	self.InitModel(self, args)
	self.InitView(self)
end

M.InitModel = function(self, args)
	self.BAG_LIST_WIDTH_EXTRA = 20
	self.MAX_SELL_ITEM_COUNT = 12
	self.sellItemInfoList = {}
	self.shopId = args.shopId
	self.gameTypeId = self.GetGameTypeId(self)
	self.bagStoreSet = gExtractionShooterManager.GetBagStoreSet(self.gameTypeId)
	self.currentInventoryBagId = self.bagStoreSet.inventory
	self.TabTypeMap = {
		["I'qW"] = 1,
		["\\xac}"] = 0
	}
end

M.GetGameTypeId = function(self)
	local count = LTConfig.ExtractionShooterGamePlayTypeConfig.count

	for i = 0, count - 1 do
		local gamePlayTypeCfg = LTConfig.ExtractionShooterGamePlayTypeConfig.LoadAt(i)
		local shopIdList = gamePlayTypeCfg.SellableShops

		if table.find(shopIdList, self.shopId) then
			return gamePlayTypeCfg.Id
		end
	end
end

M.InitView = function(self)
	self.bindData.detailButton.enabledTooltip = false
	local shopCfg = LTConfig.ShopConfig.GetConfig(self.shopId)
	self.bindData.shopName = shopCfg.ShopName

	self.InitTabList(self)
	self.RefreshPanelView(self)

	self.bindData.detailButton.enabledTooltip = false
end

M.RefreshPanelView = function(self)
	self:RefreshBagExpansionView()
	self:RefreshBagListView(nil, self.currentInventoryBagId)
	self:RefreshMoneyTemplateView()
	self.bindData.gridList:RefreshList()

	local totalMoney = self:GetSellTotalMoney()
	self.bindData.sellTotalPrice = totalMoney

	self.bindData.sellList:SetSimpleList(#self.sellItemInfoList)

	self.bindData.sellCountTips = LTConfig.ExtractionShooterConfig.ShopSellCountFormat:format(#self.sellItemInfoList, self.MAX_SELL_ITEM_COUNT)
	local amount = self:GetShopAmount()
	self.bindData.sellButton.interactable = #self.sellItemInfoList <= 0 and self:GetSellTotalMoney() > amount
	self.bindData.clearButton.interactable = #self.sellItemInfoList >= 0

	self.bindData.emptyNode:SetActive(#self.sellItemInfoList ~= 0)
	self:InitMoneyInfo()
	self.bindData.progress:SetActive(false)

	if self.moneys then
		local gamePlayTypeCfg = LTConfig.ExtractionShooterGamePlayTypeConfig.GetConfig(self.gameTypeId)
		local fundNumber = gamePlayTypeCfg and gamePlayTypeCfg.FundPoolSet.fundNumber or 0
		local _, shopMoney = next(self.moneys)
		self.bindData.sellTypeCtrl = shopMoney >= totalMoney and 1 or 0

		if fundNumber <= 0 then
			self.bindData.progress:SetActive(true)

			self.bindData.progress.value = amount / fundNumber
		end
	end
end

M.GetShopAmount = function(self)
	local fund = gExtractionShooterManager.GetBringOutFund(self.gameTypeId)

	return fund and fund.Amount or 0
end

M.GetSellTotalMoney = function(self)
	local totalMoney = 0

	for _, sellItemInfo in ipairs(self.sellItemInfoList) do
		local itemInfo = sellItemInfo.itemInfo
		local itemTotalPrice = gExtractionShooterManager.GetItemTotalPrice(itemInfo)
		totalMoney = totalMoney + itemTotalPrice
	end

	return totalMoney
end

M.RefreshBagListView = function(self, _, bagConfigId)
	local sellItemCount = #self.sellItemInfoList

	for i = sellItemCount, 1, -1 do
		local sellItemInfo = self.sellItemInfoList[i]
		local itemInfo = sellItemInfo.itemInfo
		local bagId = sellItemInfo.bagId
		local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagId)
		local itemInfoList = bagInfo.ItemInfoList

		if not table.find(itemInfoList, itemInfo) then
			table.remove(self.sellItemInfoList, i)
		end
	end

	self:RefreshCommonBagListView(bagConfigId)
	self:RefreshBagExpansionView()
	self.bindData.sellList:SetSimpleList(#self.sellItemInfoList)
end

M.GetBagListWidget = function(self, bagConfigId)
	return self.bindData.gridList
end

M.OnBeforeRefreshCommonBagListView = function(self, bagConfigId)
	self.bindData.bagName = self.GetBagName(self, bagConfigId)
end

M.SetupBagListDragOut = function(self, bagList, bagConfigId, itemInfoList)
	bagList.luaButtonEndDrag = function(index, _, pointerEnterGameObject)
		if not pointerEnterGameObject then
			return
		end

		if pointerEnterGameObject ~= self.bindData.sellList or pointerEnterGameObject.GetComponentInParent(pointerEnterGameObject, typeof(SGUI.UList)) ~= self.bindData.sellList then
			local itemInfo = itemInfoList[index + 1]

			if not self:CheckItemInSellList(itemInfo) then
				self:AddSellItemInfoList(itemInfo)
				self:RefreshPanelView()
			end
		end
	end
end

M.CheckCanPlaceOverlapBlocked = function(self, overlaps)
	return self.CheckAnyOverlapInSellList(self, overlaps)
end

M.CheckAnyOverlapInSellList = function(self, overlaps)
	if not overlaps then
		return false
	end

	for _, overlap in ipairs(overlaps) do
		if self.CheckItemInSellList(self, overlap.itemInfo) then
			return true
		end
	end

	return false
end

M.OnCanTransfer = function(self, srcList, srcIndex, dstList, targetIndex, dstPos)
	local srcItemInfo = self.GetCanPlaceSrcItemInfo(self, srcList, srcIndex)

	if not srcItemInfo then
		return true
	end

	local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(srcItemInfo.Id)

	if not itemCfg then
		return true
	end

	local dstCtx = self.GetOrBuildCanPlaceCtx(self, dstList)

	if not dstCtx then
		return true
	end

	local cellX = math.floor(dstPos.x + 0.5)
	local cellY = math.floor(dstPos.y + 0.5)
	local _, overlaps = gExtractionShooterUtils.TryGetOverlapItemsByShiftItem(dstCtx, cellX, cellY, itemCfg, srcItemInfo.IsRotated, srcItemInfo)

	if self.CheckAnyOverlapInSellList(self, overlaps) then
		return false
	end

	return true
end

M.GetBagGamePlayTypeId = function(self)
	return self.gameTypeId
end

M.OnSelectInventoryBag = function(self, bagId)
	self.currentInventoryBagId = bagId

	self:RefreshCommonBagListView(self.currentInventoryBagId)
	self.bindData.extraStoreBagList:RefreshList()
end

M.CheckCanAddExpansionBag = function(self)
	local count = LTConfig.ExtractionShooterBagExpansionConfig.count
	local extractionShooterInfo = gExtractionShooterManager.GetExtractionShooterInfo()
	local unlockedExpansionIds = extractionShooterInfo and extractionShooterInfo.UnlockedExpansionIds or {}

	for i = 0, count - 1 do
		local bagExpansionCfg = LTConfig.ExtractionShooterBagExpansionConfig.LoadAt(i)

		if bagExpansionCfg.BelongBagId <= 0 and not unlockedExpansionIds[bagExpansionCfg.Id] then
			return bagExpansionCfg.Id
		end
	end
end

M.InitTabList = function(self)
	local commonTabSingleStore1 = self.SubGroup.CommonTabSingleStore_1
	self.tabTypeDataList = {
		{
			type = self.TabTypeMap.Buy,
			title = LTConfig.ExtractionShooterConfig.ShopBuy
		},
		{
			type = self.TabTypeMap.Sell,
			title = LTConfig.ExtractionShooterConfig.ShopSell
		}
	}

	commonTabSingleStore1:SetData(self.tabTypeDataList, nil, 0, nil, self:CreateAction("OnTabTypeSelectedChange"))
	gShopManager:GetShopCommodityInfo(self.shopId, self:CreateAction("OnRefreshCommodityInfo"))
end

M.OnRefreshCommodityInfo = function(self, isSuccess, groupList, groupDict, data)
	if not isSuccess then
		return
	end

	self.InitMoneyInfo(self)

	self.groupList = groupList
	self.groupDict = groupDict
	local shopCfg = LTConfig.ShopConfig.GetConfig(self.shopId)
	self.commodityGroupDataList = {}

	for _, commodityGroupId in ipairs(shopCfg.CommodityGroupIdList) do
		local commodityGroupCfg = LTConfig.ShopCommodityGroupConfig.GetConfig(commodityGroupId)

		table.insert(self.commodityGroupDataList, {
			id = commodityGroupId,
			title = commodityGroupCfg.GroupName,
			iconId = commodityGroupCfg.Icon
		})
	end

	local commonTabSingleStore2 = self.SubGroup.CommonTabSingleStore_2

	commonTabSingleStore2.SetData(commonTabSingleStore2, self.commodityGroupDataList, nil, 0, nil, self.CreateAction(self, "OnCommodityGroupSelectedChange"))
end

M.InitMoneyInfo = function(self)
	local fund = gExtractionShooterManager.GetBringOutFund(self.gameTypeId)

	if not fund then
		return
	end

	local gamePlayTypeCfg = LTConfig.ExtractionShooterGamePlayTypeConfig.GetConfig(self.gameTypeId)
	local consumableId = gamePlayTypeCfg and gamePlayTypeCfg.FundPoolSet.fundType or 0
	local moneys = {
		[consumableId] = gCommonItemManager:GetPackItemNum(consumableId)
	}
	self.moneys = moneys
	local shopMoneyWidget = self.bindData.shopMoneyWidget
	local shopMoneyStore = gStoreManager:GetStoreGroup(shopMoneyWidget.Store):GetStoreByWidget(shopMoneyWidget)
	shopMoneyStore.count = fund.Amount
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_UPDATE] = self.CreateAction(self, "RefreshBagListView"),
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_REMOVE] = self.CreateAction(self, "RefreshBagListView"),
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_CLEAR] = self.CreateAction(self, "RefreshBagListView"),
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_SPLIT_ITEM] = self.CreateAction(self, "RefreshBagListView"),
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_SELL_ITEM] = self.CreateAction(self, "RefreshBagListView"),
		[gEventConstants.ON_EXTRACTION_SHOOTER_BAG_CAPACITY_CHANGE] = self.CreateAction(self, "RefreshBagListView"),
		[gEventConstants.ON_EXTRACTION_SHOOTER_BAG_EXPANSION_SUCCESS] = self.CreateAction(self, "RefreshBagListView"),
		[gEventConstants.ON_EXTRACTION_SHOOTER_SORT_BAG_RESULT] = self.CreateAction(self, "RefreshBagListView"),
		[gEventConstants.ON_EXTRACTION_SHOOTER_SELL_ITEM_TO_SHOP] = self.CreateAction(self, "ClearSellItemListView"),
		[gEventConstants.ON_EXTRACTION_SHOOTER_BRING_OUT_CHANGE] = self.CreateAction(self, "RefreshPanelView"),
		[gEventConstants.NPCSHOP_COMMODITYINFO_CHANGE] = self.CreateAction(self, "OnCommodityInfoChange")
	}
end

M.RefreshMoneyTemplateView = function(self)
	self.SubGroup.MoneyTemplateStore_1:SetData(UX.Game.MoneyType.Money)
end

M.RegisterWidget = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnClickExitButton")
	self.bindData.sortButton.luaClick = self.CreateAction(self, "OnClickSortButton")
	self.bindData.clearButton.luaClick = self.CreateAction(self, "OnClickClearButton")
	self.bindData.sellButton.luaClick = self.CreateAction(self, "OnClickSellButton")
	self.bindData.gridList.luaRenderItem = self.CreateAction(self, "OnRenderBagItem")
	self.bindData.sellList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderSellBagItem")
	self.bindData.extraStoreBagList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderExtraStoreBagItem")
	self.bindData.detailButton.luaClick = self.CreateAction(self, "OnDetailClick")
	self.bindData.detailCloseButton.luaClick = self.CreateAction(self, "OnDetailCloseClick")
end

M.OnTabTypeSelectedChange = function(self, uList)
	local selectedIndex = uList.selectedIndex
	local tabTypeData = self.tabTypeDataList[selectedIndex + 1]

	if tabTypeData.type ~= self.TabTypeMap.Buy then
		self.bindData.typeCtrl = self.typeCtrlEnum.Buy
	elseif tabTypeData.type ~= self.TabTypeMap.Sell then
		self.bindData.typeCtrl = self.typeCtrlEnum.Sell
	end

	if self.bindData.typeCtrl == self.typeCtrlEnum.Sell then
		self.ClearSellItemListView(self)
	end
end

M.OnCommodityGroupSelectedChange = function(self, uList)
	local selectedIndex = uList.selectedIndex
	local commodityGroupData = self.commodityGroupDataList[selectedIndex + 1]
	local commodityGroupId = commodityGroupData.id
	self.commodityRenderDataList = self.groupList[commodityGroupId] or {}

	gShopManager:SortCommodityList(self.commodityRenderDataList)

	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")

	self.bindData.list:SetSimpleList(#self.commodityRenderDataList)
end

M.OnRenderItem = function(self, btn, index)
	btn.draggable = false
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.commodityRenderDataList[index + 1]
	store.name = data.Name
	store.iconId = data.ShopIconId
	store.qualityCtrl = data.Quality
	store.price = data.MoneyRichTextIcon .. data.PriceCurrent
	store.showCountCtrl = data.NoLimit and 0 or 1
	store.count = data.RemainByLimit
	store.typeCtrl = not data.NoLimit and data.RemainNum < 0 and 1 or 0
	btn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderCommodityToolTips", data)
end

M.OnRenderCommodityToolTips = function(self, selectedInfo, btn, popup, popupIndex)
	popup.transform.localScale = Vector3.Fetch(0.72, 0.72, 1)
	local store = gStoreManager:GetStoreGroup(popup.Store)
	selectedInfo.isTarkov = true
	local commodityId = selectedInfo.CommodityId
	local commodityCfg = LTConfig.ShopCommodityConfig.GetConfig(commodityId)
	local dropId = commodityCfg.DropId
	local dropCfg = LTConfig.DropConfig.GetConfig(dropId)
	local extractionShooterItemId = dropCfg.ExtractionShooterItem[1].id
	local perBuyCount = dropCfg.ExtractionShooterItem[1].count

	store:SetSelectedNpcShopItem(selectedInfo, self.moneys, function (data, buyNum)
		self:OnBuyClick(btn, selectedInfo, buyNum)
	end, selectedInfo.MoneyRichTextIcon, function (buyNum)
		self:RefreshCommodityCanPlaceView(store, extractionShooterItemId, buyNum * perBuyCount)
	end)

	store.bindData.haveLabel = gExtractionShooterManager.GetInventoryBagItemCount(extractionShooterItemId)

	self:RefreshCommodityCanPlaceView(store, extractionShooterItemId, math.max(1, store.val or 1) * perBuyCount)
end

M.GetPlaceableBagConfigIds = function(self)
	local bagIds = {}

	for _, data in ipairs(self.BuildUnlockedExpansionBagViewDataList(self)) do
		if data.bagId then
			table.insert(bagIds, data.bagId)
		end
	end

	return bagIds
end

M.CheckCanPlaceCommodity = function(self, extractionShooterItemId, addCount)
	addCount = math.max(1, addCount or 1)
	local extractionItemCfg = gExtractionShooterUtils.GetItemCfgByConsumableId(extractionShooterItemId)

	if not extractionItemCfg then
		return true
	end

	local ctxList = {}

	for _, bagId in ipairs(self.GetPlaceableBagConfigIds(self)) do
		table.insert(ctxList, gExtractionShooterUtils.BuildBagContextByConfigId(bagId))
	end

	local itemsToAdd = {
		[extractionShooterItemId] = addCount
	}

	return gExtractionShooterUtils.CheckCanAddItems(ctxList, itemsToAdd) ~= MessageConfig.Ok
end

M.RefreshCommodityCanPlaceView = function(self, store, extractionShooterItemId, addCount)
	local canPlace = self.CheckCanPlaceCommodity(self, extractionShooterItemId, addCount)

	if store.bindData.confirmBtn then
		store.bindData.confirmBtn.interactable = canPlace
	end

	store.bindData.btnNameLabel = canPlace and store.bindData.buyText or LTConfig.ExtractionShooterConfig.ShopInventoryFullTips
end

M.OnBuyClick = function(self, btn, selectedInfo, buyNum)
	if buyNum <= 0 then
		btn.CloseTooltip(btn, true)

		local totalBuy = buyNum * selectedInfo.PriceCurrent

		if self.moneys[selectedInfo.Money] >= totalBuy then
			gDisplayMessageMgr:ShowMessage(MessageConfig.ShopCommodityBuyNotEnoughMoney)
		else
			slot5 = gDisplayMessageMgr

			slot5:ShowMessage(MessageConfig.ShopCommodityBuyDoubleCheck, function ()
				self:BuyCallback(selectedInfo, buyNum)
			end, nil, selectedInfo.MoneyRichTextIcon, totalBuy, string.format(" %s x %s ", selectedInfo.Name, buyNum))
		end
	end
end

M.OnCommodityInfoChange = function(self, _, shopId, infoList)
	if table.isNilOrEmpty(infoList) or self.shopId == shopId or not self.groupDict then
		return
	end

	local dirty = false

	for _, info in ipairs(infoList) do
		for _, group in pairs(self.groupDict) do
			for templateId, commondityInfo in pairs(group) do
				if templateId ~= info.TemplateId then
					dirty = true

					gShopManager:UpdateCommodityInfoSingle(commondityInfo, info)
				end
			end
		end
	end

	if dirty then
		gShopManager:SortCommodityList(self.commodityRenderDataList)
		self.bindData.list:SetSimpleList(#self.commodityRenderDataList)
	end
end

M.BuyCallback = function(self, selectedInfo, buyNum)
	if selectedInfo and buyNum <= 0 and buyNum * selectedInfo.PriceCurrent < self.moneys[selectedInfo.Money] then
		local num = buyNum
		local commodityId = selectedInfo.CommodityId
		slot5 = gClientToGameDelegate

		slot5:AskBuyCommodityToBag(self.shopId, commodityId, num, {
			self.currentInventoryBagId
		}).Callback = function (err)
			if err ~= MessageConfig.Ok then
				self:RefreshPanelView()
			else
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end
end

M.OnClickSortButton = function(self)
	local rootGo = self.rootGo
	slot2 = gExtractionShooterManager

	slot2:AskExtractionShooterSortBag(self.currentInventoryBagId, function ()
		if gClientUtils.NotNil(rootGo) then
			self:ClearSellItemListView()
		end
	end)
end

M.OnClickClearButton = function(self)
	gDisplayMessageMgr:ShowBomb({
		["\\xd0\\xc8=1\\xe5"] = false,
		tips1Text = LTConfig.ExtractionShooterConfig.ShopClearConfirmText,
		btnConfirmCallback = function ()
			self.sellItemInfoList = {}

			self:RefreshPanelView()
		end
	})
end

M.OnClickSellButton = function(self)
	local firstItemInfo = self.sellItemInfoList[1].itemInfo
	local normalizedMoneyId = gCommonItemManager:NormalizeMoneyItemId(firstItemInfo.Id)
	local moneyCfg = LTConfig.ConsumableConfig.GetConfig(normalizedMoneyId)
	local moneyIconText = moneyCfg.MoneyRichTextIcon or ""
	local itemList = {}

	for _, sellItemInfo in ipairs(self.sellItemInfoList) do
		local itemInfo = sellItemInfo.itemInfo

		table.insert(itemList, {
			itemId = itemInfo.Id,
			itemNum = itemInfo.StackCount
		})
	end

	local sellTotalMoney = self:GetSellTotalMoney()

	gDisplayMessageMgr:ShowBomb({
		["\\xd0\\xc8=1\\xe5"] = false,
		msgType = gDisplayMessageId.SELECT,
		costText = LTConfig.ExtractionShooterConfig.ShopSellConfirmText:format(moneyIconText .. sellTotalMoney),
		costItemList = itemList,
		btnConfirmCallback = self:CreateAction("AskGeneralBuyBackExtractionShooterItemToShop")
	})
end

M.AskGeneralBuyBackExtractionShooterItemToShop = function(self)
	local slotList = {}

	for _, sellItemInfo in ipairs(self.sellItemInfoList) do
		local itemInfo = sellItemInfo.itemInfo

		table.insert(slotList, {
			BagConfigId = sellItemInfo.bagId,
			CellX = itemInfo.CellX,
			CellY = itemInfo.CellY
		})
	end

	gExtractionShooterManager:AskGeneralBuyBackExtractionShooterItemToShop(self.shopId, slotList)
end

M.OnRenderSellBagItem = function(self, btn, index)
	btn.draggable = false
	local sellItemInfo = self.sellItemInfoList[index + 1]
	local itemInfo = sellItemInfo.itemInfo
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	gExtractionShooterManager:RefreshCommonItemInfoView(btn, itemInfo)

	btn.luaHover = function()
		if not self.isPopupIndex or self.isPopupIndex ~= 0 then
			btn:CloseTooltip(true)
		end
	end

	local itemName = gExtractionShooterManager.GetItemName(itemInfo.Id)
	local systemPrice = gExtractionShooterManager.GetItemSystemPrice(itemInfo.Id)
	store.name = itemName
	btn.enabledTooltip = false
	store.statusCtrl = 0
	local normalizedMoneyId = gCommonItemManager:NormalizeMoneyItemId(itemInfo.Id)
	local moneyCfg = LTConfig.ConsumableConfig.GetConfig(normalizedMoneyId)
	local moneyIconText = moneyCfg.MoneyRichTextIcon or ""
	store.price = moneyIconText .. systemPrice

	btn.luaClick = function()
		table.remove(self.sellItemInfoList, index + 1)
		self:RefreshPanelView()
	end
end

M.OnRenderBagItem = function(self, btn, index)
	btn.gameObject.name = ("BagItem:%d"):format(index)
	local bagConfigId = self.currentInventoryBagId
	local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagConfigId)
	local itemInfoList = bagInfo.ItemInfoList
	local itemInfo = itemInfoList[index + 1]
	btn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTips", {
		bagConfigId = bagConfigId,
		itemInfo = itemInfo
	})
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.titleTypeCtrl = 1

	if itemInfo then
		gExtractionShooterManager:RefreshCommonItemInfoView(btn, itemInfo)

		local itemId = itemInfo.Id
		local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemId)
		local itemX, itemY = gExtractionShooterUtils.GetRotatedVolume(itemCfg, itemInfo.IsRotated)

		self:RefreshBagItemImage(store, bagConfigId, itemInfo, itemX, itemY)

		btn.luaRightClick = nil

		btn.luaHover = function()
			if not self.isPopupIndex or self.isPopupIndex ~= 0 then
				btn:CloseTooltip(true)
				btn:OpenTooltip(0)
			end
		end

		store.statusCtrl = 0
		store.waitForClick = nil
		store.waitForClickCo = coroutine.stop(store.waitForClickCo)
		btn.luaTooltipPopup = self:CreateAction("OnToolTipPopup")
		store.typeCtrl = self:CheckItemInSellList(itemInfo) and 1 or 0

		btn.luaClick = function()
			if self.bindData.typeCtrl == self.typeCtrlEnum.Sell then
				return
			end

			if self:CheckItemInSellList(itemInfo) then
				for sellItemIndex, sellItemInfo in ipairs(self.sellItemInfoList) do
					if sellItemInfo.itemInfo ~= itemInfo then
						table.remove(self.sellItemInfoList, sellItemIndex)

						break
					end
				end
			else
				self:AddSellItemInfoList(itemInfo)
			end

			self:RefreshPanelView()
		end

		btn.luaBeginDrag = function()
			btn:CloseTooltip(true)

			local replicaWidget = btn.replicaWidget

			if replicaWidget then
				local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemInfo.Id)
				local itemX, itemY = gExtractionShooterUtils.GetRotatedVolume(itemCfg, itemInfo.IsRotated)
				local gridList = self.bindData.gridList
				local cellSizeX = gridList.gridSize.x
				local cellSizeY = gridList.gridSize.y
				replicaWidget.transform.sizeDelta = Vector2.Fetch(itemX * cellSizeX, itemY * cellSizeY)
				replicaWidget.transform.localScale = Vector2.Fetch(0.72, 0.72)
				local replicaStore = gStoreManager:GetStoreGroup(replicaWidget.Store):GetStoreByWidget(replicaWidget)
				replicaStore.showSelectboxCtrl = 0
			end
		end
	else
		store.typeCtrl = 0
		store.statusCtrl = 1
	end
end

M.AddSellItemInfoList = function(self, itemInfo)
	if self.MAX_SELL_ITEM_COUNT < #self.sellItemInfoList then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.ExtractionShooterConfig.ShopAddToSellLimitTips)

		return
	end

	if not self.CheckItemInSellList(self, itemInfo) then
		table.insert(self.sellItemInfoList, {
			bagId = self.currentInventoryBagId,
			itemInfo = itemInfo
		})
	end
end

M.CheckItemInSellList = function(self, itemInfo)
	for _, sellItemInfo in ipairs(self.sellItemInfoList) do
		if sellItemInfo.itemInfo ~= itemInfo then
			return true, sellItemInfo
		end
	end

	return false
end

M.OnRenderToolTips = function(self, args, btn, popup, popupIndex)
	local store = gStoreManager:GetStoreGroup(popup.Store):GetStoreByWidget(popup)

	if popupIndex ~= 0 then
		self.OnRenderPopupItemInfo(self, store, args)
	end
end

M.ClearSellItemListView = function(self)
	self.sellItemInfoList = {}

	self.RefreshPanelView(self)
end

M.OnDetailClick = function(self)
	local shopCfg = LTConfig.ShopConfig.GetConfig(self.shopId)

	gDisplayMessageMgr:ShowMessExplainSub(shopCfg.ShopDescription)
end

M.OnDetailCloseClick = function(self)
end
