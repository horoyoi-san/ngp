local MallCommodityConfig = LTConfig.MallCommodityConfig
local MallBundleConfig = LTConfig.MallBundleConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local MoneyType = UX.Game.MoneyType
C_ShopBundlePanelStore = DefClass("C_ShopBundlePanelStore", C_ShopBundlePanelStore, C_StoreGroup)
GroupName2Class.ShopBundlePanelStore = C_ShopBundlePanelStore
local M = C_ShopBundlePanelStore

function M:ctor()
	self.bundleId = 0
	self.bundleCfg = nil
	self.itemListData = {}
	self.selectedIndex = -1
	self.rawPrice = 0
	self.nowPrice = 0
	self.moneyItemId = 0
end

function M:DefineAllVariables()
	self.panelId = nil
	self.endTimestamp = 0
	self.lastUpdateTime = 0
end

function M:DefineAllEnumsAutoGen()
	self.typeCtrlEnum = {
		weapon = 1,
		car = 2,
		suit = 0
	}
end

function M:ClearAllEnumsAutoGen()
	self.typeCtrlEnum = nil
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self.endTimestamp = 0
	self.lastUpdateTime = 0
end

function M:OnUpdate()
	if self.endTimestamp > 0 then
		local now = os.time()

		if now ~= self.lastUpdateTime then
			self.lastUpdateTime = now

			self:UpdateCountDown()
		end
	end
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.panelId = panelId

	if not data or not data.bundleId then
		data = {
			bundleId = 1
		}
	end

	self.bundleId = data.bundleId
	self.bundleCfg = MallBundleConfig.GetConfig(self.bundleId)

	if not self.bundleCfg then
		gDisplayMessageMgr:ShowMessageContentDebug("礼包配置不存在: " .. tostring(self.bundleId))
		gPanelManager:Close(panelId)

		return
	end

	self:InitBundleData()
	self:RefreshBundleInfo()
	self:InitMoneyDisplay()
end

function M:OnClose()
	self.selectedIndex = -1
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:InitBundleData()
	self.itemListData = {}
	self.rawPrice = 0
	self.moneyItemId = 0
	local moneyItemSet = {}

	if not self.bundleCfg.Commodities or #self.bundleCfg.Commodities == 0 then
		return
	end

	for _, commodityId in ipairs(self.bundleCfg.Commodities) do
		local commodityCfg = MallCommodityConfig.GetConfig(commodityId)

		if commodityCfg then
			local dropCfg = LTConfig.DropConfig.GetConfig(commodityCfg.DropId)
			local itemId = dropCfg and dropCfg.Item1 and dropCfg.Item1[1] and dropCfg.Item1[1].id1 or 0
			local consumeCfg = itemId ~= 0 and ConsumableConfig.GetConfig(itemId) or nil
			local itemData = {
				id = commodityCfg.Id,
				name = commodityCfg.Name or "",
				icon = commodityCfg.Picture or 0,
				iconId = consumeCfg and consumeCfg.SItemIconId or 0,
				price = commodityCfg.Price or 0,
				quality = consumeCfg and consumeCfg.Quality or 1,
				dropId = commodityCfg.DropId or 0,
				itemId = itemId,
				moneyItemId = commodityCfg.ConsumeItemId,
				description = commodityCfg.Desc or "",
				consumeCfg = consumeCfg,
				commodityCfg = commodityCfg
			}

			if consumeCfg then
				itemData.tIndex = 1
			else
				itemData.tIndex = 0
			end

			table.insert(self.itemListData, itemData)

			self.rawPrice = self.rawPrice + itemData.price

			if itemData.moneyItemId and itemData.moneyItemId > 0 then
				moneyItemSet[itemData.moneyItemId] = true
			end
		end
	end

	local moneyItemIds = {}

	for id, _ in pairs(moneyItemSet) do
		table.insert(moneyItemIds, id)
	end

	if #moneyItemIds > 0 then
		self.moneyItemId = moneyItemIds[1]
	end

	local discountRate = self.bundleCfg.DiscountRate or 1
	self.nowPrice = math.floor(self.rawPrice * discountRate)
end

function M:RefreshBundleInfo()
	self.bindData.bundleName = self.bundleCfg.Name or ""
	self.bindData.bundleDes = self.bundleCfg.Des or self.bundleCfg.Name
	self.bindData.bundleNumDes = string.format("%d", #self.itemListData)
	self.bindData.rawPrice = tostring(self.rawPrice)
	self.bindData.nowPrice = tostring(self.nowPrice)
	self.bindData.typeCtrl = self.typeCtrlEnum.suit

	self.bindData.itemList:SetSimpleList(#self.itemListData)
	self:InitCountDown()
	self:ClearSingleItemInfo()
end

function M:InitCountDown()
	local now = os.time()
	self.endTimestamp = now + 243
	self.lastUpdateTime = now

	self:UpdateCountDown()
end

function M:UpdateCountDown()
	local now = os.time()
	local remainingTime = self.endTimestamp - now

	if remainingTime <= 0 then
		self.bindData.bundleTime = "end"
		self.endTimestamp = 0

		return
	end

	self.bindData.bundleTime = gTimeUtils:GetLongTimeStrHaveDay(remainingTime)
end

function M:ClearSingleItemInfo()
	self.bindData.singleItemName = ""
	self.bindData.singleItemDes = ""
	self.bindData.singleItemPrice = ""
	self.selectedIndex = -1
end

function M:RefreshSingleItemInfo(index)
	local itemData = self.itemListData[index + 1]

	if not itemData then
		self:ClearSingleItemInfo()

		return
	end

	self.selectedIndex = index
	self.bindData.singleItemName = itemData.name
	self.bindData.singleItemDes = itemData.description
	self.bindData.singleItemPrice = tostring(itemData.price)
end

function M:InitMoneyDisplay()
	if not self.moneyItemId or self.moneyItemId == 0 then
		return
	end

	local consumeCfg = ConsumableConfig.GetConfig(self.moneyItemId)

	if not consumeCfg then
		return
	end

	local moneyType = MoneyType.Money

	if consumeCfg.SMoneyIconId then
		if consumeCfg.SMoneyIconId == 9000014 then
			moneyType = MoneyType.Gold
		elseif consumeCfg.SMoneyIconId == 9000015 then
			moneyType = MoneyType.BindingGold
		end
	end

	local moneyTemplateData = {
		{
			Type = moneyType
		}
	}

	self.SubGroup.MoneyTemplateStore:SetData(moneyTemplateData)
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.buySingleBtn.luaClick = self:CreateAction("OnClickBuySingleBtn")
	self.bindData.buyBundleBtn.luaClick = self:CreateAction("OnClickBuyBundleBtn")
	self.bindData.changeRoleBtn.luaClick = self:CreateAction("OnClickChangeRoleBtn")
	self.bindData.settingBtn.luaClick = self:CreateAction("OnClickSettingBtn")
	self.bindData.hideUIBtn.luaClick = self:CreateAction("OnClickHideUIBtn")
	self.bindData.backBtn.luaClick = self:CreateAction("OnClickBackBtn")
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderItemListItem")
	self.bindData.itemList.luaSimpleClick = self:CreateAction("OnSimpleClickItemList")
	self.bindData.itemList.onGetTIndex = self:CreateAction("OnGetItemListTIndex")
end

function M:OnClickBuySingleBtn()
	if self.selectedIndex < 0 then
		gDisplayMessageMgr:ShowMessageContentDebug("请先选择一个商品")

		return
	end

	gDisplayMessageMgr:ShowMessageContentDebug("购买单个商品 - 待实现")
end

function M:OnClickBuyBundleBtn()
	gDisplayMessageMgr:ShowMessageContentDebug("购买整个礼包 - 待实现")
end

function M:OnClickChangeRoleBtn()
	gDisplayMessageMgr:ShowMessageContentDebug("切换角色 - 待实现")
end

function M:OnClickSettingBtn()
	gDisplayMessageMgr:ShowMessageContentDebug("设置 - 待实现")
end

function M:OnClickHideUIBtn()
	gDisplayMessageMgr:ShowMessageContentDebug("隐藏UI - 待实现")
end

function M:OnClickBackBtn()
	if self.panelId then
		gPanelManager:Close(self.panelId)
	end
end

function M:OnGetItemListTIndex(index)
	local data = self.itemListData[index + 1]

	return data and data.tIndex or 0
end

function M:OnSimpleRenderItemListItem(btn, index)
	local itemData = self.itemListData[index + 1]

	if not itemData then
		return
	end

	if itemData.tIndex == 0 then
		self:RenderCommonItem(btn, itemData)
	elseif itemData.tIndex == 1 then
		self:RenderSuitItem(btn, itemData)
	end
end

function M:RenderCommonItem(btn, itemData)
	local store = gStoreManager:GetStoreGroup("NewCommonItemStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = itemData.iconId
	store.quality = itemData.quality - 1
	store.countCtl = 0
	store.isOwned = 0
	store.isLock = 0
	store.showUnselect = 0
end

function M:RenderSuitItem(btn, itemData)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.icon = itemData.icon ~= 0 and itemData.icon or itemData.iconId
	store.iconBg = itemData.icon
	store.goodsName = itemData.name
	store.price = itemData.price
	store.quality = itemData.quality
	local cfg = ConsumableConfig.GetConfig(itemData.moneyItemId)

	if cfg then
		store.moneyIcon = cfg.SMoneyIconId
	end

	store.isShowTask = 0
	store.isCollect = 0
	store.dyeType = 0
	store.isAvailable = 1
	store.isHave = 0
	store.isNew = 0
	store.isDiscount = 0
	store.isShowTime = 0
end

function M:OnSimpleClickItemList(btn, index)
	if not btn.isSelected then
		self:ClearSingleItemInfo()
		self.bindData.itemList:SelectItem(-1, false)

		return
	end

	self:RefreshSingleItemInfo(index)
end
