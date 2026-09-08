-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FarmShopAppHomePageStore.lua
-- Decompiled from: 01881_FarmShopAppHomePageStore.lua_91a05b0a976e.luajit

local OrderType = LTConfig.FarmOrderConfig.IsSpecialType
C_FarmShopAppHomePageStore = DefClass("C_FarmShopAppHomePageStore", C_FarmShopAppHomePageStore, C_StoreGroup)
GroupName2Class.FarmShopAppHomePageStore = C_FarmShopAppHomePageStore
local M = C_FarmShopAppHomePageStore
local ConsumableConfig = LTConfig.ConsumableConfig
local FarmFarmItemConfig = LTConfig.FarmFarmItemConfig
local FarmTypeConfig = LTConfig.FarmTypeConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.displaySlotList = {}
	self.displayOrderDataList = {}
	self.carouselTimer = 0
	self.carouselInterval = 3
	self.carouselPageCount = 0
end

M.DefineAllEnumsAutoGen = function(self)
	self.shelfManageStateCtrlEnum = {
		["\\xa5\\xbe\\x8eg.\\xea*"] = 0,
		["H\\xa3\\xb2\\xbb\\xaf"] = 1
	}
	self.orderStateCtrlEnum = {
		["H\\xa3\\xb2\\xbb\\xaf"] = 1,
		["A\\x9f\\x87\\x90I"] = 2,
		["G\\x83\\x83\\x82M"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.shelfManageStateCtrlEnum = nil
	self.orderStateCtrlEnum = nil
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
	self.bindData.orderList:UnRegisterToPageEvent(self.orderPageChangeCb)

	self.orderPageChangeCb = nil
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.ShowPanel = function(self)
	self.RefreshHomePage(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.FARMER_SHOP_CHANGED] = self.CreateAction(self, self.RefreshHomePage),
		[gEventConstants.FARMER_ORDER_CHANGED] = self.CreateAction(self, self.RefreshHomePage),
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, self.RefreshHomePage),
		[gEventConstants.On_SYNC_SPIRIT_JOBINFO] = self.CreateAction(self, self.RefreshHomePage)
	}
end

M.RegisterWidget = function(self)
	self.bindData.enterProductBtn.luaClick = self:CreateAction(self.OnClickEnterProductBtn)
	self.bindData.enterProductBtn1.luaClick = self:CreateAction(self.OnClickEnterProductBtn)
	self.bindData.enterOrderBtn.luaClick = self:CreateAction(self.OnClickEnterOrderBtn)
	self.bindData.enterOrderBtn1.luaClick = self:CreateAction(self.OnClickEnterOrderBtn)
	self.bindData.enterAssetsBtn.luaClick = self:CreateAction(self.OnClickEnterAssetsBtn)
	self.bindData.farmInventoryBtn.luaClick = self:CreateAction(self.OnClickFarmInventoryBtn)
	self.bindData.productList.luaSimpleRenderItem = self:CreateAction(self.OnSimpleRenderProductListItem)
	self.bindData.orderList.luaSimpleRenderItem = self:CreateAction(self.OnSimpleRenderOrderListItem)
	self.bindData.productList.luaSimpleClick = self:CreateAction(self.OnSimpleClickProductList)
	self.bindData.orderList.luaSimpleClick = self:CreateAction(self.OnSimpleClickOrderList)
	self.orderPageChangeCb = self:CreateAction(self.OnOrderListPageChanged)

	self.bindData.orderList:RegisterToPageEvent(self.orderPageChangeCb)

	self.bindData.orderLocatorList.luaSimpleClick = self:CreateAction(self.OnClickOrderLocator)
end

M.RefreshHomePage = function(self)
	local slots = gFarmerManager.shopSlots
	local slotCount = gFarmerManager.shopSlotCount
	self.displaySlotList = {}

	for i = 0, slotCount - 1 do
		if slots[i] == nil then
			table.insert(self.displaySlotList, {
				slot = slots[i],
				serverIndex = i
			})
		end
	end

	self.bindData.productCurrentCountText = tostring(#self.displaySlotList)
	self.bindData.productTotalCountText = tostring(slotCount)
	self.bindData.shelfManageStateCtrl = #self.displaySlotList ~= 0 and self.shelfManageStateCtrlEnum.empty or self.shelfManageStateCtrlEnum.notEmpty

	self.bindData.productList:SetSimpleList(#self.displaySlotList)

	self.bindData.myMoneyText = tostring(gFarmerManager.income and gFarmerManager.income.Wallet or 0)
	local jobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Farm)
	local jobInfo = gSpiritJobManager.GetCurSpiritJob(jobId)
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(jobId)
	local levelCfg = gSpiritJobManager:GetLevelConfig(urbanJobCfg)

	if urbanJobCfg and levelCfg and jobInfo then
		self.bindData.professionNameText = urbanJobCfg.Name
		self.bindData.professionLevelText = jobInfo.Level
		self.bindData.professionCurrentExpText = tostring(jobInfo.Exp)
		self.bindData.professionTotalExpText = tostring(levelCfg.Exp)

		self.bindData.professionExpProgress:ProgressToValue(jobInfo.Exp / levelCfg.Exp)
	end

	local farmItemCount = 0

	for _, item in ipairs(gCommonItemManager.packItems) do
		local consumableCfg = ConsumableConfig.GetConfig(item.TemplateId)
		local farmCfg = consumableCfg and FarmFarmItemConfig.GetConfig(consumableCfg.BindId)
		local typeCfg = farmCfg and FarmTypeConfig.GetConfig(farmCfg.Type)

		if typeCfg and typeCfg.CanDirectSell then
			farmItemCount = farmItemCount + 1
		end
	end

	self.bindData.myInventoryText = string.format("%d/%d", farmItemCount, gFarmerManager:GetMaxInventoryCountByJobLevel(jobInfo and jobInfo.Level))
	self.displayOrderDataList = gFarmerManager:BuildOrderDataList()
	self.bindData.orderStatusText = string.format("%d个订单进行中", #self.displayOrderDataList)
	self.bindData.orderStateCtrl = gFarmerManager:GetOrderAreaState()

	self.bindData.orderList:SetSimpleList(#self.displayOrderDataList)

	local pageCount = self.bindData.orderList.pageMax
	self.carouselPageCount = pageCount
	self.carouselTimer = 0

	self.bindData.orderLocatorList:SetSimpleList(pageCount)
	self.bindData.orderLocatorList:SetItemSelected(0, true)
end

M.OnClickEnterProductBtn = function(self)
	gFarmerManager:SwitchToPage(gFarmerManager.APP_PAGE.PRODUCT)
end

M.OnClickEnterOrderBtn = function(self)
	gFarmerManager:SwitchToPage(gFarmerManager.APP_PAGE.ORDER)
end

M.OnClickEnterAssetsBtn = function(self)
	gFarmerManager:SwitchToPage(gFarmerManager.APP_PAGE.ASSETS)
end

M.OnClickFarmInventoryBtn = function(self)
	local slots = gFarmerManager.shopSlots
	local slotCount = gFarmerManager.shopSlotCount

	for i = 0, slotCount - 1 do
		if slots[i] ~= nil then
			gPanelManager:CheckShow(gPanelId.FARM_INVENTORY_PANEL, {
				slotIndex = i
			})

			return
		end
	end

	print_error("[FarmShopAppHomePageStore] 货架已满，无空槽可上架")
end

M.OnSimpleRenderProductListItem = function(self, btn, index)
	local entry = self.displaySlotList[index + 1]

	if not entry then
		return
	end

	local slot = entry.slot
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.stateCtrl = slot.Count ~= 0 and 3 or 0
	store.qualityCtrl = slot.Quality
	local consumableCfg = ConsumableConfig.GetConfig(slot.ItemId)
	local farmCfg = consumableCfg and FarmFarmItemConfig.GetConfig(consumableCfg.BindId)

	if farmCfg then
		store.name = farmCfg.Name
		store.iconId = farmCfg.SItemIconId
	end
end

M.OnSimpleClickProductList = function(self, btn, index)
	local entry = self.displaySlotList[index + 1]

	if not entry then
		return
	end

	gFarmerManager:SwitchToProductPageWithSlot(entry.serverIndex)
end

M.OnSimpleRenderOrderListItem = function(self, btn, index)
	local orderData = self.displayOrderDataList[index + 1]

	if not orderData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = orderData.cfg
	store.nameText = orderData.itemCfg and orderData.itemCfg.Name or ""
	store.requireCountText = tostring(cfg.RequireCount)
	store.moneyText = tostring(cfg.Reward)
	store.refreshTimeText = gFarmerManager:FormatOrderRemainingTime(orderData.expireTime)
	store.orderTypeCtrl = cfg.IsSpecial ~= OrderType.Monsterfram and 1 or 0
	store.deliveryTypeCtrl = gFarmerManager:GetDeliveryTypeByOrderType(cfg.DeliveryOrder)
	local invCount = gFarmerManager:CountOrderInventory(cfg.RequireItemId, cfg.RequireQuality)
	store.inventoryCountText = tostring(invCount)
	store.takeOrderBtn.interactable = gFarmerManager:CanTakeOrder(orderData)
	store.takeOrderBtn.luaClick = self:CreateAction(self.OnClickOrderListEnter)
	local renderData = gCommonItemManager:GetItemRenderData({
		itemId = cfg.RequireItemId,
		itemNum = cfg.RequireCount
	})
	renderData.iconId = orderData.farmCfg and orderData.farmCfg.SItemIconId or renderData.iconId

	gCommonItemManager:OnCommonItemRender(store.commonItemWidget, 0, renderData)
end

M.OnSimpleClickOrderList = function(self, btn, index)
	gFarmerManager:SwitchToPage(gFarmerManager.APP_PAGE.ORDER)
end

M.OnClickOrderLocator = function(self, btn, index)
	self.carouselTimer = 0

	self.bindData.orderList:GoToPage(index, false)
end

M.OnOrderListPageChanged = function(self, pageIndex)
	local count = self.bindData.orderLocatorList:GetListCount()

	for i = 0, count - 1 do
		self.bindData.orderLocatorList:SetItemSelected(i, i ~= pageIndex)
	end
end

M.OnUpdate = function(self)
	if self.carouselPageCount < 1 then
		return
	end

	self.carouselTimer = self.carouselTimer + Time.deltaTime

	if self.carouselTimer >= self.carouselInterval then
		return
	end

	self.carouselTimer = 0
	local cur = self.bindData.orderList:GetTargetPage()
	local next = (cur + 1) % self.carouselPageCount

	self.bindData.orderList:GoToPage(next, false)
end

M.OnClickOrderListEnter = function(self)
	gFarmerManager:SwitchToPage(gFarmerManager.APP_PAGE.ORDER)
end
