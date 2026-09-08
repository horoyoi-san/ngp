-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FullScreenFurnitureShopStore.lua
-- Decompiled from: 01901_FullScreenFurnitureShopStore.lua_d31b326c9608.luajit

local ShopConfig = LTConfig.ShopConfig
local CommodityTypeConfig = LTConfig.ShopCommodityTypeConfig
local MessageConfig = LTConfig.MessageConfig
local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
local HouseConfig = LTConfig.HouseConfig
local HouseTypeConfig = LTConfig.HouseTypeConfig
local HouseTagConfig = LTConfig.HouseTagConfig
local TextCommonTextConfig = LTConfig.TextCommonTextConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local moneyIconText = "#C(jinyuebi_Text)"
local BUY_BTN_TEXT_ID = 74000531
local LOCKED_BTN_TEXT_ID = 89900122
local TINDEX_HOME_TAG = 12
local STATE_LOCK = 2
C_FullScreenFurnitureShopStore = DefClass("C_FullScreenFurnitureShopStore", C_FullScreenFurnitureShopStore, C_StoreGroup)
GroupName2Class.FullScreenFurnitureShopStore = C_FullScreenFurnitureShopStore
local M = C_FullScreenFurnitureShopStore
local SHOW = {
	["k\\x8f\\x8e\\x9c\\x93"] = 0,
	["NH~"] = 1
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.groupList = {}
	self.groupDict = {}
	self.commoditiesByType = {}
	self.mainTypeTabList = {}
	self.subTypeTabList = {}
	self.commodityRenderData = {}
	self.curMainType = nil
	self.curSubType = nil
	self.selectedInfo = nil
	self.selectedIndex = -1
	self.moneys = nil
	self.shopId = ShopConfig.HouseFurniture
	self.shopCfg = nil
	self.isInit = false
	self.toolTipStore = nil
	self.subTypeNameMap = nil
	self.tagRenderData = nil
	self.descRenderData = nil
	self.homeTagRenderData = nil
	self.isSelectedLocked = false
	self.unlockAction = nil
	self.buyNum = 1
	self.buyCb = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.showSecondTabCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.showRefreshTimeCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showSecondTabCtrlEnum = nil
	self.showRefreshTimeCtrlEnum = nil
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
	self.BuildSubTypeNameMap(self)
end

M.OnDisable = function(self)
end

M.OnUpdate = function(self)
end

M.OnDestroy = function(self)
	self.msgEvents = nil
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.toolTipStore = nil
end

M.OnShow = function(self, panelId, data)
	self.shopId = ShopConfig.HouseFurniture
	self.pendingFocusFurnitureId = data and data.focusFurnitureId or nil

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
	self.groupList = nil
	self.groupDict = nil
	self.commoditiesByType = nil
	self.mainTypeTabList = nil
	self.subTypeTabList = nil
	self.commodityRenderData = nil
	self.curMainType = nil
	self.curSubType = nil
	self.selectedInfo = nil
	self.selectedIndex = nil
	self.moneys = nil
	self.buyCb = nil
	self.tagRenderData = nil
	self.descRenderData = nil
	self.homeTagRenderData = nil
	self.isSelectedLocked = nil
	self.unlockAction = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.NPCSHOP_COMMODITYINFO_CHANGE] = self.CreateAction(self, "OnCommodityInfoChange"),
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, "OnPackItemChanged")
	}
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.lockBtn.luaClick = self.CreateAction(self, "OnLockBtnClick")
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderItemListItem")
	self.bindData.itemList.luaSelectedChanged = self.CreateAction(self, "OnItemSelectedChanged")
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderMainTypeTabItem")
	self.bindData.tabList.luaSelectedChanged = self.CreateAction(self, "OnMainTypeTabSelectedChanged")
	self.bindData.secTabList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderSubTypeTabItem")
	self.bindData.secTabList.luaSelectedChanged = self.CreateAction(self, "OnSubTypeTabSelectedChanged")
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnLockBtnClick = function(self)
	if self.unlockAction and self.unlockAction.callback then
		self.unlockAction.callback()
	end
end

M.OnInitBefore = function(self)
	self.shopCfg = ShopConfig.GetConfig(self.shopId)
	self.isInit = false
	self.curMainType = nil
	self.curSubType = nil
	self.selectedIndex = -1
	self.selectedInfo = nil
	self.commodityRenderData = {}
	self.buyCb = self:CreateAction("OnBuyCallback")

	gShopManager:SetShopIdEnterTime(self.shopId)

	self.bindData.showSecondTabCtrl = self.showSecondTabCtrlEnum.show
	self.bindData.shopName = self.shopCfg and self.shopCfg.ShopName or ""
	self.bindData.showRefreshTimeCtrl = self.showRefreshTimeCtrlEnum.hide
end

M.InitTooltipWidget = function(self)
	self.toolTipStore = gStoreManager:GetStoreGroup(self.bindData.toolTip.Store):GetStoreByWidget(self.bindData.toolTip)
	self.toolTipStore.buyBtn.luaClick = self:CreateAction("OnBuyBtnClick")
	self.toolTipStore.tagList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderTagListItem")
	self.toolTipStore.descList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderDescListItem")
	self.toolTipStore.descList.luaSimpleClick = self:CreateAction("OnSimpleClickDescListItem")
	self.toolTipStore.descList.onGetTIndex = self:CreateAction("OnGetDescListTIndex")
	self.tagRenderData = {}
	self.descRenderData = {}
	self.homeTagRenderData = {}
end

M.BuildSubTypeNameMap = function(self)
	self.subTypeNameMap = {}

	if HouseConfig and HouseConfig.FurnitureSubType then
		for _, cfg in ipairs(HouseConfig.FurnitureSubType) do
			self.subTypeNameMap[cfg.SubType] = cfg.Name or ""
		end
	end
end

M.GetSubTypeName = function(self, subType)
	if not subType or not self.subTypeNameMap then
		return ""
	end

	return self.subTypeNameMap[subType] or ""
end

M.RefreshCommodityInfo = function(self)
	gShopManager:GetShopCommodityInfo(self.shopId, self:CreateAction("OnGetCommodityInfoCallback"))
end

M.OnGetCommodityInfoCallback = function(self, success, groupList, groupDict, data)
	if not success then
		return
	end

	self.groupList = self.FilterGroupListByVisible(self, groupList)
	self.groupDict = {}

	for _, dict in pairs(groupDict) do
		for k, v in pairs(dict) do
			local hfCfg = HouseFurnitureConfig.GetConfig(v.BindId)

			if not hfCfg or not hfCfg.IsHide then
				self.groupDict[k] = v
			end
		end
	end

	self.RebuildCommoditiesByType(self)

	if not self.isInit then
		self.isInit = true

		self.InitMoneyInfo(self, data.Moneys)
		self.SetupMainTypeTabs(self)

		if self.pendingFocusFurnitureId then
			self.NavigateToFurniture(self, self.pendingFocusFurnitureId)

			self.pendingFocusFurnitureId = nil
		end
	else
		self.RefreshCurrentItemList(self)
	end
end

M.RebuildCommoditiesByType = function(self)
	self.commoditiesByType = {}

	for _, list in pairs(self.groupList) do
		for _, item in ipairs(list) do
			local hfCfg = HouseFurnitureConfig.GetConfig(item.BindId)

			if hfCfg then
				local mt = hfCfg.MainType
				local st = hfCfg.SubType
				self.commoditiesByType[mt] = self.commoditiesByType[mt] or {}
				self.commoditiesByType[mt][st] = self.commoditiesByType[mt][st] or {}

				table.insert(self.commoditiesByType[mt][st], item)
			end
		end
	end
end

M.FilterGroupListByVisible = function(self, groupList)
	local result = {}

	for groupId, list in pairs(groupList) do
		local filtered = {}

		for _, item in ipairs(list) do
			local hfCfg = HouseFurnitureConfig.GetConfig(item.BindId)

			if not hfCfg or not hfCfg.IsHide then
				table.insert(filtered, item)
			end
		end

		result[groupId] = filtered
	end

	return result
end

M.InitMoneyInfo = function(self, moneys)
	self.moneys = moneys or {}
	local MoneyTemplateData = {}

	for consumableId, _ in pairs(self.moneys) do
		self.moneys[consumableId] = gCommonItemManager:GetPackItemNum(consumableId)

		table.insert(MoneyTemplateData, {
			Type = consumableId
		})
	end

	if self.SubGroup and self.SubGroup.MoneyTemplateStore then
		self.SubGroup.MoneyTemplateStore:SetData(MoneyTemplateData)
	end
end

M.RefreshMoneyInfo = function(self)
	if not self.moneys then
		return
	end

	for consumableId, _ in pairs(self.moneys) do
		self.moneys[consumableId] = gCommonItemManager:GetPackItemNum(consumableId)
	end
end

M.SetupMainTypeTabs = function(self)
	table.clear(self.mainTypeTabList)

	local mainTypeSubTypes = {}
	local mainTypeOrder = {}

	if HouseTypeConfig and HouseTypeConfig.count then
		for i = 0, HouseTypeConfig.count - 1 do
			local typeCfg = HouseTypeConfig.LoadAt(i)

			if typeCfg and typeCfg.MainType then
				local mt = typeCfg.MainType

				if not mainTypeSubTypes[mt] then
					mainTypeSubTypes[mt] = {}

					table.insert(mainTypeOrder, mt)
				end

				if typeCfg.SubType then
					for _, st in ipairs(typeCfg.SubType) do
						table.insert(mainTypeSubTypes[mt], st)
					end
				end
			end
		end
	end

	table.sort(mainTypeOrder)

	local mainTypeNameList = HouseConfig.FurnitureMainType

	for _, mt in ipairs(mainTypeOrder) do
		local subTypes = mainTypeSubTypes[mt] or {}
		local visibleSubTypes = {}

		for _, st in ipairs(subTypes) do
			if self.commoditiesByType[mt] and self.commoditiesByType[mt][st] and #self.commoditiesByType[mt][st] <= 0 then
				table.insert(visibleSubTypes, st)
			end
		end

		if #visibleSubTypes <= 0 then
			local mainCfg = mainTypeNameList and mainTypeNameList[mt]

			table.insert(self.mainTypeTabList, {
				mainType = mt,
				name = mainCfg and mainCfg.Name or "",
				subTypes = visibleSubTypes
			})
		end
	end

	self.bindData.tabList:SetSimpleList(#self.mainTypeTabList)

	if #self.mainTypeTabList <= 0 and not self.pendingFocusFurnitureId then
		self.bindData.tabList:SelectItem(0, true)
	end
end

M.OnRenderMainTypeTabItem = function(self, btn, index)
	local data = self.mainTypeTabList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.name = data.name
	store.icon = 0
end

M.OnMainTypeTabSelectedChanged = function(self)
	if self.isNavigating then
		return
	end

	local index = self.bindData.tabList.selectedIndex + 1
	local data = self.mainTypeTabList[index]

	if not data then
		return
	end

	self.curMainType = data.mainType

	self.SetupSubTypeTabs(self, data.subTypes)
end

M.SetupSubTypeTabs = function(self, visibleSubTypes)
	self.subTypeTabList = visibleSubTypes or {}

	self.bindData.secTabList:SetSimpleList(#self.subTypeTabList)

	if #self.subTypeTabList <= 0 then
		self.bindData.secTabList:SelectItem(0, true)
	else
		self.curSubType = nil
		self.commodityRenderData = {}

		self.bindData.itemList:SetSimpleList(0)
	end

	self.OnSubTypeTabSelectedChanged(self)
end

M.OnRenderSubTypeTabItem = function(self, btn, index)
	local subType = self.subTypeTabList[index + 1]

	if not subType then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local subTypeName = self.GetSubTypeName(self, subType)
	store.title = subTypeName
end

M.OnSubTypeTabSelectedChanged = function(self)
	if self.isNavigating then
		return
	end

	local index = self.bindData.secTabList.selectedIndex + 1
	local subType = self.subTypeTabList[index]

	if not subType then
		return
	end

	self.curSubType = subType

	self.RefreshCurrentItemList(self)
end

M.RefreshCurrentItemList = function(self)
	local list = self.commoditiesByType[self.curMainType] and self.commoditiesByType[self.curMainType][self.curSubType] or {}
	self.commodityRenderData = list
	self.selectedIndex = -1
	self.selectedInfo = nil

	self.bindData.itemList:SetSimpleList(#self.commodityRenderData)

	if #self.commodityRenderData <= 0 then
		self.bindData.itemList:SelectItem(0, true)

		self.selectedIndex = 1
		self.selectedInfo = self.commodityRenderData[1]

		self:RefreshTooltip()
	end
end

M.NavigateToFurniture = function(self, furnitureId)
	if not furnitureId or not self.commoditiesByType then
		return
	end

	self.isNavigating = true
	local targetMainType, targetSubType, targetItemIndex = nil

	for mt, subTypeMap in pairs(self.commoditiesByType) do
		for st, items in pairs(subTypeMap) do
			for idx, item in ipairs(items) do
				if item.BindId ~= furnitureId then
					targetMainType = mt
					targetSubType = st
					targetItemIndex = idx

					break
				end
			end

			if targetMainType then
				break
			end
		end

		if targetMainType then
			break
		end
	end

	if not targetMainType then
		self.isNavigating = false

		return
	end

	local mainTabIndex, mainTabData = nil

	for i, tabData in ipairs(self.mainTypeTabList) do
		if tabData.mainType ~= targetMainType then
			mainTabIndex = i - 1
			mainTabData = tabData

			break
		end
	end

	if not mainTabIndex or not mainTabData then
		self.isNavigating = false

		return
	end

	self.bindData.tabList:SetItemSelected(mainTabIndex, true)

	self.curMainType = targetMainType
	local visibleSubTypes = mainTabData.subTypes or {}
	self.subTypeTabList = visibleSubTypes

	self.bindData.secTabList:SetSimpleList(#self.subTypeTabList)

	local subTabIndex = nil

	for i, st in ipairs(self.subTypeTabList) do
		if st ~= targetSubType then
			subTabIndex = i - 1

			break
		end
	end

	if not subTabIndex then
		self.isNavigating = false

		return
	end

	self.bindData.secTabList:SetItemSelected(subTabIndex, true)

	self.curSubType = targetSubType
	local list = self.commoditiesByType[targetMainType] and self.commoditiesByType[targetMainType][targetSubType] or {}
	self.commodityRenderData = list
	self.selectedIndex = -1
	self.selectedInfo = nil

	self.bindData.itemList:SetSimpleList(#self.commodityRenderData)

	local itemListIndex = targetItemIndex - 1

	if itemListIndex > 0 and itemListIndex >= #self.commodityRenderData then
		self.bindData.itemList:SelectItem(itemListIndex, true)

		self.selectedIndex = targetItemIndex
		self.selectedInfo = self.commodityRenderData[targetItemIndex]

		self:RefreshTooltip()
	elseif #self.commodityRenderData <= 0 then
		self.bindData.itemList:SelectItem(0, true)

		self.selectedIndex = 1
		self.selectedInfo = self.commodityRenderData[1]

		self:RefreshTooltip()
	end

	self.isNavigating = false
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

	btn.enabledTooltip = false
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
	store.showRefreshTimeCtrl = SHOW.FALSE
end

M.OnItemSelectedChanged = function(self)
	self.selectedIndex = self.bindData.itemList.selectedIndex + 1
	self.selectedInfo = self.commodityRenderData[self.selectedIndex]

	self.RefreshTooltip(self)
end

M.GetFurnitureState = function(self, info)
	if info.LimitNum ~= 1 and info.RemainNum ~= 0 then
		return 5
	end

	return info.State
end

M.GetFurnitureOwnedNum = function(self, furnitureId)
	if not furnitureId then
		return 0
	end

	local infoMinor = gPlayerManager and gPlayerManager.infoMinor
	local housesInfo = infoMinor and infoMinor.bindData and infoMinor.bindData.housesInfo
	local dict = housesInfo and housesInfo.FurnitureInfoDict
	local info = dict and dict[furnitureId]

	return info and info.Count or 0
end

M.RefreshTooltip = function(self)
	if not self.toolTipStore or not self.selectedInfo then
		return
	end

	local info = self.selectedInfo
	local hfCfg = HouseFurnitureConfig.GetConfig(info.BindId)
	local itemData = gCommonItemManager:TryGetItemInfo({
		TemplateId = info.BindId
	})
	self.toolTipStore.typeQuality = hfCfg and self:GetSubTypeName(hfCfg.SubType) or gCommonItemManager:GetItemQualityLabel(itemData)
	self.toolTipStore.qualityCtrl = info.Quality

	if CommodityTypeConfig and CommodityTypeConfig.Fashion and (info.CommodityType ~= CommodityTypeConfig.Fashion or info.CommodityType ~= CommodityTypeConfig.FashionSuit) then
		self.toolTipStore.itemType = 1
	else
		self.toolTipStore.itemType = 0
	end

	self.toolTipStore.name = info.Name
	self.toolTipStore.stateCtrl = self:GetFurnitureState(info)
	self.toolTipStore.showCounterCtrl = info.ShowCount and 1 or 0
	self.toolTipStore.unlockDescription = info.UnlockDesc
	self.toolTipStore.showNumCtrl = 1
	local owned = self:GetFurnitureOwnedNum(info.BindId)

	if info.LimitNum and info.LimitNum <= 0 then
		self.toolTipStore.haveNum = string.format("%d/%d", owned, info.LimitNum)
	else
		self.toolTipStore.haveNum = string.format("%d", owned)
	end

	self.toolTipStore.TypeCtrl = 0
	self.bindData.iconId = info.ShopIconId
	self.homeTagRenderData = self:BuildFurnitureTagList(hfCfg)
	self.descRenderData = {}

	table.insert(self.descRenderData, {
		tIndex = TINDEX_HOME_TAG,
		num = tostring(hfCfg and hfCfg.OccupyCapacity or 0)
	})

	if not string.is_null_or_empty(info.Description) then
		table.insert(self.descRenderData, {
			tIndex = gCommonItemManager.Template2Index.SEC_TEXT,
			text = info.Description
		})
	end

	self.isSelectedLocked = self:GetFurnitureState(info) ~= STATE_LOCK
	self.unlockAction = nil

	if self.isSelectedLocked then
		local hyperLinkId = hfCfg and hfCfg.HypeLinkID or 0

		if hyperLinkId <= 0 then
			self.unlockAction = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(hyperLinkId, info.BindId)
		end
	end

	if self.unlockAction then
		table.insert(self.descRenderData, self.unlockAction)
	end

	self.toolTipStore.hasHyperLink = self.unlockAction and 1 or 0
	self.bindData.lockBtn.interactable = self.unlockAction == nil

	self:RefreshBuyBtnText()
	self.toolTipStore.descList:SetSimpleList(#self.descRenderData)
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

M.RefreshBuyBtnText = function(self)
	if self.isSelectedLocked then
		if self.unlockAction and not string.is_null_or_empty(self.unlockAction.text) then
			self.bindData.buyBtnText = self.unlockAction.text

			return
		end

		local lockCfg = TextScriptTextConfig.GetConfig(LOCKED_BTN_TEXT_ID)
		self.bindData.buyBtnText = lockCfg and lockCfg.Text or ""

		return
	end

	local textCfg = TextCommonTextConfig.GetConfig(BUY_BTN_TEXT_ID)
	self.bindData.buyBtnText = textCfg and textCfg.Text or ""
end

M.BuildFurnitureTagList = function(self, hfCfg)
	local ret = {}
	local tagIds = hfCfg and hfCfg.Tag

	if not tagIds then
		return ret
	end

	for _, tagId in ipairs(tagIds) do
		local tagCfg = HouseTagConfig.GetConfig(tagId)

		if tagCfg then
			table.insert(ret, {
				title = tagCfg.TagName or "",
				color = tagCfg.TagColor
			})
		end
	end

	return ret
end

M.OnSimpleRenderTagListItem = function(self, btn, index)
end

M.OnSimpleRenderDescListItem = function(self, btn, index)
	local data = self.descRenderData[index + 1]

	if not data then
		return
	end

	if data.tIndex ~= TINDEX_HOME_TAG then
		self.RenderHomeTagItem(self, btn, data)

		return
	end

	gCommonItemManager:OnRenderDescItem(btn, index, data)
end

M.RenderHomeTagItem = function(self, btn, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store:EnableImmediatelyCommit(true)

	store.num = data.num or "0"
	store.tagList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderHomeTagItem")

	store.tagList:SetSimpleList(#self.homeTagRenderData)
end

M.OnSimpleRenderHomeTagItem = function(self, btn, index)
	local data = self.homeTagRenderData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = data.title
	local c = data.color

	if c and #c > 4 then
		store.color = Color.New(c[1] / 255, c[2] / 255, c[3] / 255, c[4] / 255)
	end
end

M.OnSimpleClickDescListItem = function(self, btn, index)
	local data = self.descRenderData[index + 1]

	if not data then
		return
	end

	gCommonItemManager:OnDescItemClick(btn, data)
end

M.OnGetDescListTIndex = function(self, index)
	local data = self.descRenderData[index + 1]

	return data and data.tIndex or 0
end

M.GetMaxNum = function(self)
	if not self.selectedInfo then
		return 1
	end

	local info = self.selectedInfo
	local maxNum = info.NoLimit and info.LimitOnceNum or math.min(info.RemainNum, info.LimitOnceNum)
	local price = info.PriceCurrent or 0

	if price <= 0 then
		local money = self.moneys and self.moneys[info.Money] or 0
		maxNum = math.min(maxNum, math.floor(money / price))
	end

	return math.max(1, maxNum)
end

M.OnBuyNumChange = function(self, val)
	if not self.selectedInfo or not self.toolTipStore then
		return
	end

	self.buyNum = val or 1
	local totalPrice = self.buyNum * self.selectedInfo.PriceCurrent
	self.toolTipStore.price = tostring(totalPrice)
	self.toolTipStore.priceIconId = self.selectedInfo.MoneyIconId
	local enough = self.moneys and totalPrice > (self.moneys[self.selectedInfo.Money] or 0)
	self.toolTipStore.MoneyNotEnoughCtrl = enough and 0 or 1
	self.toolTipStore.buyBtn.interactable = enough and (self.selectedInfo.NoLimit or self.buyNum > self.selectedInfo.RemainNum)
end

M.OnBuyBtnClick = function(self)
	local info = self.selectedInfo

	if not info or info.SoldOut then
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

	if dirty then
		self.bindData.itemList:RefreshList()
		self:RefreshTooltip()
	end
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
