-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ShopFilterPanelStore.lua
-- Decompiled from: 01318_ShopFilterPanelStore.lua_622c5390a60d.luajit

local FashionConfig = LTConfig.FashionConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local FashionTagConfig = LTConfig.FashionTagConfig
C_ShopFilterPanelStore = DefClass("C_ShopFilterPanelStore", C_ShopFilterPanelStore, C_StoreGroup)
GroupName2Class.ShopFilterPanelStore = C_ShopFilterPanelStore
local M = C_ShopFilterPanelStore
local PRIORITY = {
	["}\\xbc\\xab\\xac\\xb3"] = 1,
	["pOieH*="] = 0
}
local ORDER = {
	["\\xaf{e"] = 0,
	["^'nX"] = 1
}

M.ctor = function(self)
	self.contentStore = nil
end

M.DefineAllVariables = function(self)
	self.panelId = nil
	self.callBack = nil
	self.commodityList = nil
	self.priceList = nil
	self.tagList = nil
	self.selectedPrices = nil
	self.selectedTags = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.blurCtrlEnum = {
		["^\\xad\\xa7\\xa1\\xb3"] = 0,
		["O\\xaf\\xab\\xa4\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.blurCtrlEnum = nil
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
	self.callBack = nil
	self.commodityList = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.callBack = data and data.callBack
	self.commodityList = data and data.commodityList or {}
	self.bindData.blurCtrl = self.blurCtrlEnum.scene
	self.selectedPrices = {}
	self.selectedTags = {}
	local state = data and data.filterState

	if state then
		slot4 = pairs
		slot6 = state.prices or {}

		for price in slot4(slot6) do
			self.selectedPrices[price] = true
		end

		slot4 = pairs
		slot6 = state.tags or {}

		for tagId in slot4(slot6) do
			self.selectedTags[tagId] = true
		end
	end

	self.InitInfo(self, state)
end

M.OnClose = function(self)
	if self.callBack then
		self.callBack(self.BuildFilteredList(self), self.ExportFilterState(self))
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.InitInfo = function(self, state)
	self.contentStore = gStoreManager:GetStoreGroup("ShopFilterContent"):GetStoreByWidget(self.bindData.scroll.content)

	if not self.contentStore then
		return
	end

	self.contentStore.priceList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderPriceItem")
	self.contentStore.priceList.luaSimpleClick = self.CreateAction(self, "OnClickPriceItem")
	self.contentStore.tagList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderTagItem")
	self.contentStore.tagList.luaSimpleClick = self.CreateAction(self, "OnClickTagItem")

	self.InitSelectors(self, state)
	self.InitPriceList(self)
	self.InitTagList(self)
end

local getText = function(key)
	local cfg = LTConfig.TextConfig.GetConfig(key)

	return cfg and cfg.Text or ""
end

M.InitSelectors = function(self, state)
	local prioritySel = self.contentStore.prioritySelector

	prioritySel:SetSimpleOptions(2)
	prioritySel:SetItemLabel(PRIORITY.ShelfTime, getText(73970822))
	prioritySel:SetItemLabel(PRIORITY.Price, getText(73970823))
	prioritySel:SelectOption(state and state.priority or PRIORITY.ShelfTime, false)

	local orderSel = self.contentStore.orderSelector

	orderSel:SetSimpleOptions(2)
	orderSel:SetItemLabel(ORDER.Asc, getText(73970825))
	orderSel:SetItemLabel(ORDER.Desc, getText(73970826))
	orderSel:SelectOption(state and state.order or ORDER.Asc, false)

	self.contentStore.sortTitle1 = getText(73970821)
	self.contentStore.sortTitle2 = getText(73970824)
	self.contentStore.mainTitle1 = getText(73970818)
	self.contentStore.mainTitle2 = getText(73970819)
	self.contentStore.mainTitle3 = getText(73970820)
end

M.InitPriceList = function(self)
	local seen = {}
	local prices = {}

	for _, commodityData in ipairs(self.commodityList) do
		local price = gMallManager:GetCommodityActualPrice(commodityData)

		if not seen[price] then
			seen[price] = true

			table.insert(prices, price)
		end
	end

	table.sort(prices)

	self.priceList = {}

	for _, price in ipairs(prices) do
		table.insert(self.priceList, {
			price = price
		})
	end

	self.contentStore.priceList:SetSimpleList(#self.priceList)
end

M.InitTagList = function(self)
	local seen = {}
	self.tagList = {}

	for _, commodityData in ipairs(self.commodityList) do
		local tagIds = self.GetCommodityTagIds(self, commodityData)

		for _, tagId in ipairs(tagIds) do
			if not seen[tagId] then
				local tagCfg = FashionTagConfig.GetConfig(tagId)

				if tagCfg then
					seen[tagId] = true
					local view = {
						tagId = tagId,
						title = tagCfg.Name,
						color = tagCfg.BackgroundColor
					}

					table.insert(self.tagList, view)
				end
			end
		end
	end

	self.contentStore.tagList:SetSimpleList(#self.tagList)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickBackBtn")
	self.bindData.clearBtn.luaClick = self.CreateAction(self, "OnClickClearBtn")
	self.bindData.baseButton.luaClick = self.CreateAction(self, "OnClickBaseButton")
end

M.OnClickBackBtn = function(self)
	gUIUtils:PlayAniClosePanel(self.bindData.anim, "S_Vx_DressFilterPanel_close", self.panelId)
end

M.OnClickBaseButton = function(self)
	self.OnClickBackBtn(self)
end

M.OnClickClearBtn = function(self)
	self.selectedPrices = {}
	self.selectedTags = {}

	self.contentStore.priceList:SetSimpleList(#self.priceList)
	self.contentStore.tagList:SetSimpleList(#self.tagList)
	self.contentStore.prioritySelector:SelectOption(PRIORITY.ShelfTime, false)
	self.contentStore.orderSelector:SelectOption(ORDER.Asc, false)
end

M.OnRenderPriceItem = function(self, btn, index)
	local data = self.priceList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("FilterTxtTemplateStore"):GetStoreByWidget(btn)

	if store then
		store.title = tostring(data.price)
		btn.isSelected = self.selectedPrices[data.price] ~= true
	end
end

M.OnClickPriceItem = function(self, btn, index)
	local data = self.priceList[index + 1]

	if not data then
		return
	end

	if btn.isSelected then
		self.selectedPrices[data.price] = true
	else
		self.selectedPrices[data.price] = nil
	end
end

M.OnRenderTagItem = function(self, btn, index)
	local data = self.tagList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("DressTagFilterStore"):GetStoreByWidget(btn)

	if store then
		local color = Color.New(data.color[1] / 255, data.color[2] / 255, data.color[3] / 255, data.color[4] / 255)
		store.title = data.title
		store.selectTitle = data.title
		store.titleColor = color
		store.frameColor = color
		store.selectFrameColor = color
		btn.isSelected = self.selectedTags[data.tagId] ~= true
	end
end

M.OnClickTagItem = function(self, btn, index)
	local data = self.tagList[index + 1]

	if not data then
		return
	end

	if btn.isSelected then
		self.selectedTags[data.tagId] = true
	else
		self.selectedTags[data.tagId] = nil
	end
end

M.GetCommodityTagIds = function(self, commodityData)
	local result = {}

	if not commodityData then
		return result
	end

	local t = commodityData.type

	if (t ~= gMallManager.MallCommodityType.Fashion or t ~= gMallManager.MallCommodityType.FashionEx) and commodityData.bindId and commodityData.bindId <= 0 then
		local suitCfg = FashionSuitConfig.GetConfig(commodityData.bindId)

		if suitCfg and suitCfg.FashionIdList and #suitCfg.FashionIdList <= 0 then
			local firstFashionCfg = FashionConfig.GetConfig(suitCfg.FashionIdList[1])

			if firstFashionCfg and firstFashionCfg.Tags then
				for i = 1, #firstFashionCfg.Tags do
					local tagId = firstFashionCfg.Tags[i]
					local tagCfg = FashionTagConfig.GetConfig(tagId)

					if tagCfg and tagCfg.ImportantTag then
						table.insert(result, tagId)
					end
				end
			end
		end
	end

	return result
end

M.MatchAnyTag = function(self, commodityData)
	local tagIds = self.GetCommodityTagIds(self, commodityData)

	for _, tagId in ipairs(tagIds) do
		if self.selectedTags[tagId] then
			return true
		end
	end

	return false
end

M.BuildFilteredList = function(self)
	local priority = self.contentStore and self.contentStore.prioritySelector.selectedIndex or PRIORITY.ShelfTime
	local order = self.contentStore and self.contentStore.orderSelector.selectedIndex or ORDER.Asc
	local hasPriceFilter = next(self.selectedPrices) == nil
	local hasTagFilter = next(self.selectedTags) == nil
	local result = {}

	for _, commodityData in ipairs(self.commodityList) do
		local pass = true

		if hasPriceFilter and not self.selectedPrices[gMallManager:GetCommodityActualPrice(commodityData)] then
			pass = false
		end

		if pass and hasTagFilter and not self.MatchAnyTag(self, commodityData) then
			pass = false
		end

		if pass then
			table.insert(result, commodityData)
		end
	end

	gMallManager:SortMallCommodityListBy(result, priority, order)

	return result
end

M.ExportFilterState = function(self)
	local prices = {}

	for price in pairs(self.selectedPrices) do
		prices[price] = true
	end

	local tags = {}

	for tagId in pairs(self.selectedTags) do
		tags[tagId] = true
	end

	return {
		priority = self.contentStore and self.contentStore.prioritySelector.selectedIndex or PRIORITY.ShelfTime,
		order = self.contentStore and self.contentStore.orderSelector.selectedIndex or ORDER.Asc,
		prices = prices,
		tags = tags
	}
end
