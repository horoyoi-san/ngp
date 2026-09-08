-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Club\ClubShopStore.lua
-- Decompiled from: 01258_ClubShopStore.lua_6c5265226cd6.luajit

C_ClubShopStore = DefClass("C_ClubShopStore", C_ClubShopStore, C_StoreGroup)
GroupName2Class.ClubShopStore = C_ClubShopStore
local M = C_ClubShopStore
local SHOW = {
	["k\\x8f\\x8e\\x9c\\x93"] = 0,
	["NH~"] = 1
}

M.OnAwake = function(self)
	self.Init(self)
	self.GenMessageEvents(self)
end

M.OnStart = function(self)
	self.bindData.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderListItem)
	self.bindData.list.luaSimpleClick = self:CreateAction(self.OnClickListItem)
	self.toolTipStore = gStoreManager:GetStoreGroup("ClubShopStore.InventoryItemDetailInfoTemplateStore")

	self:BindTooltipEvents()
	gStoreManager:GetStoreGroup("ClubShopStore.MoneyTemplateStore"):SetData(LTConfig.ConsumableConfig.ClubMoney)

	self.hasStarted = true

	self:RefreshCommodityInfo()
end

M.OnEnable = function(self)
	if self.hasStarted then
		self.RefreshCommodityInfo(self)
	end
end

M.OnUpdate = function(self)
	if self.needUpdateRefresh then
		for index, store in pairs(self.updateRefreshStoreList) do
			local info = self.commodityRenderData[index]

			if info then
				store.refreshTime = gShopManager:FormatLeftTime(info.RefreshTime)
			end
		end
	end
end

M.OnGroupEnable = function(self)
	self.BindTooltipEvents(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.Init = function(self)
	self.shopId = LTConfig.ShopConfig.Club
	self.shopCfg = LTConfig.ShopConfig.GetConfig(self.shopId)
	self.groupDict = {}
	self.moneys = {}
	self.commodityRenderData = {}
	self.tagRenderData = {}
	self.updateRefreshStoreList = {}
	self.selectedInfo = nil
	self.buyNum = 1
	self.buyCb = self.CreateAction(self, "BuyCallback")
	self.needUpdateRefresh = false
	self.hasStarted = false
end

M.OnDestroy = function(self)
	self.msgEvents = nil
	self.toolTipStore = nil
end

M.BindTooltipEvents = function(self)
	if not self.toolTipStore or not self.toolTipStore.bindData then
		return
	end

	self.toolTipStore.bindData.tagList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderTagListItem")
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.NPCSHOP_COMMODITYINFO_CHANGE] = self.CreateAction(self, self.OnCommodityInfoChange),
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, self.OnPackItemChanged)
	}
end

M.RefreshCommodityInfo = function(self)
	gShopManager:GetShopCommodityInfo(self.shopId, self:CreateAction(self.OnGetCommodityInfoCallback))
end

M.OnGetCommodityInfoCallback = function(self, success, groupList, groupDict, data)
	if not success then
		return
	end

	self.BuildGroupDict(self, groupDict)
	self.InitMoneyInfo(self, data.Moneys)
	self.BuildCommodityRenderData(self, groupList)
	self.RefreshList(self)
end

M.BuildGroupDict = function(self, groupDict)
	self.groupDict = {}

	for _, dict in pairs(groupDict) do
		for key, value in pairs(dict) do
			self.groupDict[key] = value
		end
	end
end

M.BuildCommodityRenderData = function(self, groupList)
	table.clear(self.commodityRenderData)

	if not self.shopCfg or not self.shopCfg.CommodityGroupIdList then
		return
	end

	for _, groupId in ipairs(self.shopCfg.CommodityGroupIdList) do
		local groupCommodityList = groupList[groupId]

		if groupCommodityList then
			for index = 1, #groupCommodityList do
				table.insert(self.commodityRenderData, groupCommodityList[index])
			end
		end
	end

	gShopManager:SortCommodityList(self.commodityRenderData)
end

M.InitMoneyInfo = function(self, moneys)
	self.moneys = moneys or {}

	self:RefreshMoneyInfo()
end

M.RefreshMoneyInfo = function(self)
	if not self.moneys then
		return
	end

	for consumableId, _ in pairs(self.moneys) do
		self.moneys[consumableId] = gCommonItemManager:GetPackItemNum(consumableId)
	end
end

M.RefreshList = function(self)
	table.clear(self.updateRefreshStoreList)

	self.needUpdateRefresh = false
	self.selectedInfo = nil

	self.bindData.list:SetSimpleList(#self.commodityRenderData)

	if #self.commodityRenderData < 0 then
		return
	end

	self.selectedInfo = self.commodityRenderData[1]

	self.bindData.list:SetItemSelected(0, true)
	self:RefreshTooltip()
end

M.OnRenderListItem = function(self, btn, index)
	local data = self.commodityRenderData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.name = data.Name
	store.iconId = data.ShopIconId
	store.qualityCtrl = data.Quality
	store.stateCtrl = data.State
	store.priceCurrent = data.PriceCurrent
	store.priceIconId = data.MoneyIconId
	store.hasDiscountCtrl = data.HasDiscount and SHOW.TRUE or SHOW.FALSE
	store.discount = data.DiscountDesc
	store.discountTypeCtrl = data.Discount <= 100 and SHOW.FALSE or SHOW.TRUE
	store.showCounterCtrl = data.NoLimit and SHOW.FALSE or SHOW.TRUE
	store.countLimit = data.RemainByLimit
	store.showTaskWarningCtrl = data.IsTask and SHOW.TRUE or SHOW.FALSE
	store.taskIconId = data.TaskIconId
	store.MoneyNotEnoughCtrl = (self.moneys[data.Money] or 0) >= data.PriceCurrent and SHOW.TRUE or SHOW.FALSE
	store.showNumCtrl = data.ShowNum and SHOW.TRUE or SHOW.FALSE

	if data.ShowNum then
		store.haveNum = tostring(gCommonItemManager:GetItemNum(data.BindId))
	end

	if data.Unlocked and data.SoldOut and data.RefreshTime <= 0 then
		store.showRefreshTimeCtrl = SHOW.TRUE
		store.refreshTime = gShopManager:FormatLeftTime(data.RefreshTime)
		self.updateRefreshStoreList[index + 1] = store
		self.needUpdateRefresh = true
	else
		store.showRefreshTimeCtrl = SHOW.FALSE
	end
end

M.OnClickListItem = function(self, btn, index)
	self.selectedInfo = self.commodityRenderData[index + 1]

	self.RefreshTooltip(self)
end

M.OnSimpleRenderTagListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("CoreHudCircleStore"):GetStoreByWidget(btn)
	local data = self.tagRenderData[index + 1]

	if store and data then
		store.TypeCtrl = data.TagType
	end
end

M.RefreshTooltip = function(self)
	if not self.toolTipStore or not self.selectedInfo then
		return
	end

	local moneyIconText = ""

	self.toolTipStore:SetSelectedNpcShopItem(self.selectedInfo, self.moneys, self:CreateAction(self.OnBuyBtnClick), moneyIconText)
end

M.OnBuyBtnClick = function(self)
	if not self.selectedInfo then
		return
	end

	self.buyNum = self.toolTipStore and self.toolTipStore.val or 1

	if self.selectedInfo.SoldOut or self.buyNum < 0 then
		return
	end

	local totalPrice = self.buyNum * self.selectedInfo.PriceCurrent

	if totalPrice <= (self.moneys[self.selectedInfo.Money] or 0) then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.ShopCommodityBuyNotEnoughMoney)

		return
	end

	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.ShopCommodityBuyDoubleCheck, self.buyCb, nil, self.selectedInfo.MoneyRichTextIcon, totalPrice, string.format(" %s x %s ", self.selectedInfo.Name, self.buyNum))
end

M.BuyCallback = function(self)
	if not self.selectedInfo or self.buyNum < 0 then
		return
	end

	local info = self.selectedInfo

	if self.buyNum * info.PriceCurrent <= (self.moneys[info.Money] or 0) then
		return
	end

	slot2 = gClientToGameDelegate

	slot2:AskBuyCommodity(self.shopId, info.CommodityId, self.buyNum).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			if self.STATE_EnableOnce then
				self:RefreshMoneyInfo()
				self.bindData.list:RefreshList()
				self:RefreshTooltip()
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.OnCommodityInfoChange = function(self, eventId, shopId, infos)
	if not self.STATE_EnableOnce or self.shopId == shopId then
		return
	end

	local dirty = false

	for index = 1, infos.Length do
		local info = infos[index]

		if self.groupDict[info.TemplateId] then
			dirty = true

			gShopManager:UpdateCommodityInfoSingle(self.groupDict[info.TemplateId], info)
		end
	end

	if dirty then
		self.bindData.list:RefreshList()
		self:RefreshTooltip()
	end
end

M.OnPackItemChanged = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self:RefreshMoneyInfo()
	self.bindData.list:RefreshList()

	if self.selectedInfo then
		self.RefreshTooltip(self)
	end
end
