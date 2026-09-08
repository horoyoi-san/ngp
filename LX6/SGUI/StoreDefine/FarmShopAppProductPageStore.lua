-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FarmShopAppProductPageStore.lua
-- Decompiled from: 01903_FarmShopAppProductPageStore.lua_fd2cad4c84cb.luajit

C_FarmShopAppProductPageStore = DefClass("C_FarmShopAppProductPageStore", C_FarmShopAppProductPageStore, C_StoreGroup)
GroupName2Class.FarmShopAppProductPageStore = C_FarmShopAppProductPageStore
local M = C_FarmShopAppProductPageStore
local ConsumableConfig = LTConfig.ConsumableConfig
local FarmFarmItemConfig = LTConfig.FarmFarmItemConfig
local DETAIL_STATE_CTRL = {
	["2g\\xa3\\xa3\\xa2m"] = 0,
	["\\xeb\\xfe')1\\xda"] = 1
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.selectedSlotIndex = nil
	self.displayList = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.isEmptyCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
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
end

M.ShowPanel = function(self)
	self.RefreshProductList(self)
	print_debug("[FarmShopApp] 打开商品页 slotCount=", gFarmerManager.shopSlotCount, " pendingSelect=", gFarmerManager.pendingSelectSlotIndex)

	local idx = gFarmerManager.pendingSelectSlotIndex

	if idx == nil then
		gFarmerManager.pendingSelectSlotIndex = nil

		if gFarmerManager.shopSlots[idx] then
			self.ShowSlotDetail(self, idx)
		end
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.FARMER_SHOP_CHANGED] = self.CreateAction(self, self.RefreshProductList),
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, self.OnPackItemChanged)
	}
end

M.OnPackItemChanged = function(self)
	if self.selectedSlotIndex ~= nil then
		return
	end

	local slot = gFarmerManager.shopSlots[self.selectedSlotIndex]

	if not slot then
		return
	end

	self.bindData.restockBtn.interactable = gFarmerManager:CalcAvailableRestockCount(slot) >= 0
end

M.RegisterWidget = function(self)
	self.bindData.restockBtn.luaClick = self.CreateAction(self, self.OnClickRestockBtn)
	self.bindData.unpublishBtn.luaClick = self.CreateAction(self, self.OnClickUnpublishBtn)
	self.bindData.publishCancelBtn.luaClick = self.CreateAction(self, self.OnClickPublishCancelBtn)
	self.bindData.publishConfirmBtn.luaClick = self.CreateAction(self, self.OnClickPublishConfirmBtn)
	self.bindData.marketTrendBtn.luaClick = self.CreateAction(self, self.OnClickMarketTrendBtn)
	self.bindData.productList.onGetTIndex = self.CreateAction(self, self.OnGetProductListTIndex)
	self.bindData.productList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderProductListItem)
	self.bindData.productList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickProductList)
end

M.BuildDisplayList = function(self)
	self.displayList = {}
	local slots = gFarmerManager.shopSlots
	local slotCount = gFarmerManager.shopSlotCount

	for i = 0, slotCount - 1 do
		if slots[i] == nil then
			table.insert(self.displayList, i)
		end
	end

	for i = 0, slotCount - 1 do
		if slots[i] ~= nil then
			table.insert(self.displayList, i)
		end
	end
end

M.RefreshProductList = function(self)
	self.BuildDisplayList(self)

	local slots = gFarmerManager.shopSlots
	local slotCount = gFarmerManager.shopSlotCount
	local currentCount = 0

	for i = 0, slotCount - 1 do
		if slots[i] == nil then
			currentCount = currentCount + 1
		end
	end

	self.bindData.isEmptyCtrl = currentCount <= 0 and self.isEmptyCtrlEnum._false or self.isEmptyCtrlEnum._true

	if currentCount ~= 0 then
		self.ClearSlotDetail(self)
	elseif self.selectedSlotIndex == nil and gFarmerManager.shopSlots[self.selectedSlotIndex] then
		self.ShowSlotDetail(self, self.selectedSlotIndex)
	else
		self.ShowSlotDetail(self, self.displayList[1])
	end

	self.bindData.currentCountText = tostring(currentCount)
	self.bindData.totalCountText = tostring(slotCount)

	self.bindData.productList:SetSimpleList(slotCount)
end

M.OnClickRestockBtn = function(self)
	if self.selectedSlotIndex ~= nil then
		return
	end

	local slot = gFarmerManager.shopSlots[self.selectedSlotIndex]

	if not slot then
		return
	end

	local availCount = gFarmerManager:CalcAvailableRestockCount(slot)

	if availCount < 0 then
		print_error("背包中没有可补货的同品质物品")

		return
	end

	local pkgStore = self.SubGroup.InventoryItemDetailInfoPackageTemplateStore

	pkgStore.SetSelectedItem(pkgStore, {
		["|b\\xa9ge\\xbc\\xe6Bxl@"] = 1,
		TemplateId = slot.ItemId,
		range = {
			1,
			availCount
		}
	}, nil, , , , false)

	self.bindData.farmStateCtrl = DETAIL_STATE_CTRL.RESTOCK
end

M.OnClickUnpublishBtn = function(self)
	if self.selectedSlotIndex ~= nil then
		return
	end

	print_debug("[FarmShopApp] 请求下架 slotIndex=", self.selectedSlotIndex, " itemId=", gFarmerManager.shopSlots[self.selectedSlotIndex] and gFarmerManager.shopSlots[self.selectedSlotIndex].ItemId)

	gClientToGameDelegate:AskFarmerShopRemoveItem(self.selectedSlotIndex).Callback = function (err, _)
		if err == LTConfig.MessageConfig.Ok then
			print_error("#NoCreateIssue 下架失败 errId=", err, " err=", gCS.Error.GetNameById(err))
		end
	end
end

M.OnClickPublishCancelBtn = function(self)
	local slot = self.selectedSlotIndex and gFarmerManager.shopSlots[self.selectedSlotIndex]

	if slot then
		local pkgStore = self.SubGroup.InventoryItemDetailInfoPackageTemplateStore

		pkgStore.SetSelectedItem(pkgStore, {
			TemplateId = slot.ItemId
		}, nil, , , , false)
	end

	self.bindData.farmStateCtrl = DETAIL_STATE_CTRL.NORMAL
end

M.OnClickPublishConfirmBtn = function(self)
	if self.selectedSlotIndex ~= nil then
		return
	end

	local slot = gFarmerManager.shopSlots[self.selectedSlotIndex]

	if not slot then
		return
	end

	local pkgStore = self.SubGroup.InventoryItemDetailInfoPackageTemplateStore
	local count = pkgStore.GetCurrentVal(pkgStore)

	if not count or count < 0 then
		return
	end

	pkgStore:SetSelectedItem({
		TemplateId = slot.ItemId
	}, nil, , , , false)

	self.bindData.farmStateCtrl = DETAIL_STATE_CTRL.NORMAL

	print_debug("[FarmShopApp] 请求补货 slotIndex=", self.selectedSlotIndex, " itemId=", slot.ItemId, " count=", count)

	slot4 = gClientToGameDelegate

	slot4:AskFarmerShopRestockItem(self.selectedSlotIndex, count).Callback = function (err, _)
		if err == LTConfig.MessageConfig.Ok then
			print_error("#NoCreateIssue 补货失败 errId=", err, " err=", gCS.Error.GetNameById(err))
		end
	end
end

M.OnClickMarketTrendBtn = function(self)
	gFarmerManager:SwitchToPage(gFarmerManager.APP_PAGE.ASSETS)
end

M.OnGetProductListTIndex = function(self, index)
	local serverIndex = self.displayList[index + 1]

	if serverIndex ~= nil then
		return 1
	end

	return gFarmerManager.shopSlots[serverIndex] == nil and 0 or 1
end

M.OnSimpleRenderProductListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local serverIndex = self.displayList[index + 1]

	if serverIndex ~= nil then
		return
	end

	local slot = gFarmerManager.shopSlots[serverIndex]

	if slot then
		store.stateCtrl = slot.Count ~= 0 and 3 or 0
		local consumableCfg = ConsumableConfig.GetConfig(slot.ItemId)
		local farmCfg = consumableCfg and FarmFarmItemConfig.GetConfig(consumableCfg.BindId)

		if farmCfg then
			store.name = farmCfg.Name
			store.iconId = farmCfg.SItemIconId
		end

		store.priceCurrent = "收益：" .. slot.Price * slot.SoldCount
		store.countLimit = tostring(slot.Count - slot.SoldCount)
		store.qualityCtrl = slot.Quality
	else
		store.stateCtrl = 0
	end
end

M.OnSimpleClickProductList = function(self, btn, index)
	local serverIndex = self.displayList[index + 1]

	if serverIndex ~= nil then
		return
	end

	local slot = gFarmerManager.shopSlots[serverIndex]

	if slot == nil then
		self.ShowSlotDetail(self, serverIndex)

		return
	end

	if gPanelManager:IsPanelShowing(gPanelId.FARM_INVENTORY_PANEL) then
		local inventoryStore = gStoreManager:GetStoreGroup("FarmInventoryPanelStore")

		if inventoryStore then
			inventoryStore.targetSlotIndex = serverIndex
			inventoryStore.pendingAutoSelectFirst = true

			inventoryStore.RefreshItemList(inventoryStore)
		end
	else
		gPanelManager:CheckShow(gPanelId.FARM_INVENTORY_PANEL, {
			["\"?4\\xeb@\\x9d\\xfb1\\xab;\\xc0\\xfb\\xf4g\\xef"] = true,
			slotIndex = serverIndex
		})
	end
end

M.ShowSlotDetail = function(self, serverIndex)
	local slot = gFarmerManager.shopSlots[serverIndex]

	if not slot then
		return
	end

	print_debug("[FarmShopApp] 选中槽位 slotIndex=", serverIndex, " itemId=", slot.ItemId, " count=", slot.Count, " price=", slot.Price)

	self.selectedSlotIndex = serverIndex
	self.bindData.farmStateCtrl = DETAIL_STATE_CTRL.NORMAL
	self.bindData.detailCurrentPriceText = tostring(slot.Price)
	self.bindData.detailLeftCountText = tostring(slot.Count - slot.SoldCount)
	self.bindData.detialSelledCountText = tostring(slot.SoldCount)
	self.bindData.detailProfitText = tostring(slot.Price * slot.Count)
	self.bindData.restockBtn.interactable = gFarmerManager:CalcAvailableRestockCount(slot) >= 0
	local pkgStore = self.SubGroup.InventoryItemDetailInfoPackageTemplateStore

	pkgStore:SetSelectedItem({
		TemplateId = slot.ItemId
	}, nil, , , , , true)
end

M.ClearSlotDetail = function(self)
	self.selectedSlotIndex = nil
	self.bindData.farmStateCtrl = DETAIL_STATE_CTRL.NORMAL
	self.bindData.restockBtn.interactable = false
	self.SubGroup.InventoryItemDetailInfoPackageTemplateStore.selectedItem = {}
end
