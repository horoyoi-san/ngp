-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BaikeItemInfoPanelStore.lua
-- Decompiled from: 01570_BaikeItemInfoPanelStore.lua_bb67448849da.luajit

C_BaikeItemInfoPanelStore = DefClass("C_BaikeItemInfoPanelStore", C_BaikeItemInfoPanelStore, C_StoreGroup)
GroupName2Class.BaikeItemInfoPanelStore = C_BaikeItemInfoPanelStore
local M = C_BaikeItemInfoPanelStore

M.ctor = function(self)
	self.typeListData = {}
	self.contentListData = {}
	self.tagListData = {}
	self.infoTemplateStore = nil
	self.infoTemplateInit = false
	self.readSeenSet = {}
end

M.IsMobileAdaptive = function(self)
	return not gCS.LuaUtils.IsNonMobileAdaptive()
end

M.OnAwake = function(self)
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction("OnContentRenderItem")
	self.bindData.contentList.luaSelectedChanged = self:CreateAction("OnContentSelectedChange")
	self.bindData.contentList.onGetTIndex = self:CreateAction("OnGetContentListTIndex")

	self.bindData.contentList:RegisterToScrollEndEvent(self:CreateAction("CollectVisibleRedDotItems"))
	self:InitMessages()

	if self:IsMobileAdaptive() then
		return
	end

	self.bindData.typeList.luaSimpleRenderItem = self.CreateAction(self, "OnTypeRenderItem")
	self.bindData.typeList.luaSelectedChanged = self.CreateAction(self, "OnTypeSelectedChange")
	self.bindData.typeList.onGetTIndex = self.CreateAction(self, "OnGetTypeListTIndex")
	self.bindData.leftButton.luaClick = self.CreateActionWithArgs(self, "OnStep", -1)
	self.bindData.leftButton.luaLongPress = self.CreateActionWithArgs(self, "OnLongPress", -1)
	self.bindData.leftButton.luaEndLongPress = self.CreateActionWithArgs(self, "OnEndLongPress", -1)
	self.bindData.rightButton.luaClick = self.CreateActionWithArgs(self, "OnStep", 1)
	self.bindData.rightButton.luaLongPress = self.CreateActionWithArgs(self, "OnLongPress", 1)
	self.bindData.rightButton.luaEndLongPress = self.CreateActionWithArgs(self, "OnEndLongPress", 1)
end

M.ShowPanel = function(self, args)
	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.targetFirstCategoryId = args.targetFirstCategoryId
	self.targetItemId = args.targetItemId
	self.step = 0
	self.infoTemplateInit = false
	self.infoTemplateStore = nil
end

M.InitView = function(self)
	self.InitDropMenu(self)

	if self.IsMobileAdaptive(self) then
		self.InitMobileTabView(self)
	else
		self.InitPCListView(self)
	end
end

M.InitPCListView = function(self)
	local typeViewDataList, selectedIndex = self:GetTypeViewDataList()
	self.typeListData = typeViewDataList

	self.bindData.typeList:SetSimpleList(#typeViewDataList)
	self.bindData.typeList:SelectItem(selectedIndex, true)

	local isShowArrowButton = #typeViewDataList >= 0
	self.bindData.sortControl = isShowArrowButton and 1 or 0
end

M.InitMobileTabView = function(self)
	local typeViewDataList, selectedIndex = self:GetTypeViewDataList()
	self.typeListData = typeViewDataList

	self.SubGroup.CommonTabSingleStore:SetData(typeViewDataList, nil, selectedIndex, nil, self:CreateAction("OnMobileTabChanged"), self:CreateAction("OnMobileTabRenderItem"), nil, false, false)

	local isShowArrowButton = #typeViewDataList >= 0
	self.bindData.sortControl = isShowArrowButton and 1 or 0
end

M.OnMobileTabChanged = function(self)
	self.RefreshMobileContentList(self)
end

M.RefreshMobileContentList = function(self)
	local selectedTypeItem = self.SubGroup.CommonTabSingleStore:GetSelectedItem()

	if not selectedTypeItem then
		return
	end

	self.RefreshContentListView(self, selectedTypeItem)
end

M.OnMobileTabRenderItem = function(self, _, _, itemData, store)
	if not itemData or not store then
		return
	end

	self.RenderTypeStore(self, store, itemData)
end

M.RenderTypeStore = function(self, store, data)
	local cityPediaSecondClassCfg = LTConfig.CityPediaSecondClassConfig.GetConfig(data.id)
	store.title = cityPediaSecondClassCfg.Name
	local hasRedDot = gBaiKeArchiveManager.CheckCityPediaSecondClassHasRedDot(data.id)
	local redDotKey = gBaiKeArchiveManager.GetCityPediaSecondClassRedDotKey(data.id)
	store.button.redKey = redDotKey

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)
end

M.InitDropMenu = function(self)
	self.SortTypeIdMap = {
		["\\xe8\\xce0\\xe8"] = 2,
		["pH˼\\x90\r\\x8c\r\\xc4\\xed"] = 1,
		["\\x88\\xb0\\xaem1\\xec*"] = 3
	}
	self.selectorList = {
		{
			["Y\\xa7\\xb6\\xa3\\xb3"] = 560,
			id = self.SortTypeIdMap.CreateTime
		},
		{
			["Y\\xa7\\xb6\\xa3\\xb3"] = 553,
			id = self.SortTypeIdMap.Quality
		},
		{
			["Y\\xa7\\xb6\\xa3\\xb3"] = 554,
			id = self.SortTypeIdMap.Category
		}
	}

	self.SubGroup.FilterSorterComponentStore:SetData({
		onSortChanged = self:CreateAction("OnSortBtnClick"),
		sortList = self.selectorList
	})
	self.SubGroup.FilterSorterComponentStore:SelectOption(0, true)
end

M.OnSortBtnClick = function(self, _, _)
	if self.IsMobileAdaptive(self) then
		self.RefreshMobileContentList(self)
	else
		self.RefreshContentListView(self)
	end
end

M.SelectedTargetItem = function(self, targetId)
	self.targetItemId = targetId

	if self.IsMobileAdaptive(self) then
		self.InitMobileTabView(self)
	else
		local _, selectedIndex = self:GetTypeViewDataList()

		self.bindData.typeList:SelectItem(selectedIndex, true)
		self.bindData.typeList:SetNavSelectToSelect(true)
	end
end

M.GetTypeViewDataList = function(self)
	local selectedIndex = 0
	local viewDataList = {}
	local count = LTConfig.CityPediaSecondClassConfig.count

	for i = 0, count - 1 do
		local cityPediaSecondClassCfg = LTConfig.CityPediaSecondClassConfig.LoadAt(i)

		if cityPediaSecondClassCfg.FatherId ~= self.targetFirstCategoryId and gBaiKeArchiveManager.CheckCityPediaSecondClassHasUnlocked(cityPediaSecondClassCfg.Id) then
			table.insert(viewDataList, {
				id = cityPediaSecondClassCfg.Id
			})
		end
	end

	local targetSecondCategoryId = nil

	if self.targetItemId then
		local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(self.targetItemId)
		targetSecondCategoryId = cityPediaCfg and cityPediaCfg.Class
	else
		targetSecondCategoryId = #viewDataList <= 0 and viewDataList[1].id or nil
	end

	for index, viewData in ipairs(viewDataList) do
		if viewData.id ~= targetSecondCategoryId then
			viewData.selected = true
			selectedIndex = index - 1

			break
		end
	end

	return viewDataList, selectedIndex
end

M.OnTypeRenderItem = function(self, btn, index)
	local data = self.typeListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local cityPediaSecondClassCfg = LTConfig.CityPediaSecondClassConfig.GetConfig(data.id)
	store.name = cityPediaSecondClassCfg.Name
	local hasRedDot = gBaiKeArchiveManager.CheckCityPediaSecondClassHasRedDot(data.id)
	local redDotKey = gBaiKeArchiveManager.GetCityPediaSecondClassRedDotKey(data.id)
	store.button.redKey = redDotKey

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)
end

M.OnContentRenderItem = function(self, btn, index)
	local data = self.contentListData[index + 1]

	if not data or data.tIndex ~= 1 then
		btn.interactable = false

		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local itemData = gBaiKeArchiveManager:GetCityPediaItem(data.cfgId)
	store.iconId = itemData.iconId
	store.count = itemData.name
	local redDotKey = gBaiKeArchiveManager.GetCityPediaRedDotKey(data.cfgId)
	btn.redKey = redDotKey
	btn.enabledTooltip = false
	store.quality = data.Quality
	local hasRedDot = gBaiKeArchiveManager.CheckCityPediaItemHasRedDot(data.cfgId)
	local isLock = not gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(data.cfgId)

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)

	if hasRedDot then
		self.readSeenSet = self.readSeenSet or {}
		self.readSeenSet[data.cfgId] = true
	end

	store.isLock = isLock and 1 or 0
	btn.enabledTooltip = false
	btn.interactable = true
end

M.InitInfoTemplate = function(self)
	if self.infoTemplateInit then
		return
	end

	self.infoTemplateStore = gStoreManager:GetStoreGroup(self.bindData.infoTemplate.Store):GetStoreByWidget(self.bindData.infoTemplate)

	if self.infoTemplateStore.tagList then
		self.infoTemplateStore.tagList.luaSimpleRenderItem = self.CreateAction(self, "OnTagRenderItem")
		self.infoTemplateStore.tagList.onGetTIndex = self.CreateAction(self, "OnGetTagListTIndex")
	end

	self.infoTemplateInit = true
end

M.OnContentSelectedChange = function(self)
	local selectedIndex = self.bindData.contentList.selectedIndex

	if selectedIndex > 0 and selectedIndex >= #self.contentListData then
		self.ShowItemInfo(self, self.contentListData[selectedIndex + 1])
	end
end

M.ShowItemInfo = function(self, selectedItem)
	if not selectedItem then
		return
	end

	if gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(selectedItem.cfgId) then
		gBaiKeArchiveManager.SetCityPediaItemHasRead(selectedItem.cfgId)

		local itemData = gBaiKeArchiveManager:GetCityPediaItem(selectedItem.cfgId)

		self:InitInfoTemplate()

		self.bindData.iconId = itemData.image
		self.bindData.isLocked = 1

		if self.infoTemplateStore then
			self.infoTemplateStore.name = itemData.name
			self.infoTemplateStore.scrollRect.content.text = itemData.story
			local des = itemData.effectDesc
			self.bindData.effectControl = string.is_null_or_empty(des) and 0 or 1
			self.infoTemplateStore.effectText = des or ""
			local tagViewDataList = self:GetTagViewDataList(selectedItem.cfgId)
			self.tagListData = tagViewDataList
			self.infoTemplateStore.tagCtrl = #tagViewDataList <= 0 and 1 or 0

			self.infoTemplateStore.tagList:SetSimpleList(#tagViewDataList)

			if self.bindData.tagNavigation then
				self.bindData.tagNavigation.gameObject:SetActive(#tagViewDataList >= 0)
			end
		end
	else
		self.bindData.isLocked = 0
		self.bindData.unLockTip = gBaiKeArchiveManager.GetCityPediaUnlockTipText(selectedItem.cfgId)
	end
end

M.GetTagViewDataList = function(self, id)
	local viewDataList = {}
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(id)

	if not cityPediaCfg then
		return viewDataList
	end

	local consumableCfg = LTConfig.ConsumableConfig.GetConfig(cityPediaCfg.ConsumableId)

	if not consumableCfg then
		return viewDataList
	end

	local consumableTypeCfg = LTConfig.ConsumableTypeConfig.GetConfig(consumableCfg.SubType)

	if consumableTypeCfg and not string.is_null_or_empty(consumableTypeCfg.Description) then
		table.insert(viewDataList, {
			name = consumableTypeCfg.Description
		})
	end

	return viewDataList
end

M.OnTagRenderItem = function(self, btn, index)
	local data = self.tagListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.name = data.name or ""
end

M.OnGetTypeListTIndex = function(self, index)
	return 0
end

M.OnGetContentListTIndex = function(self, index)
	local luaIndex = index + 1

	if luaIndex < #self.contentListData then
		return self.contentListData[luaIndex].tIndex or 0
	else
		return 1
	end
end

M.OnGetTagListTIndex = function(self, index)
	return 0
end

M.OnTypeSelectedChange = function(self)
	self.RefreshContentListView(self)
end

M.RefreshContentListView = function(self, selectedTypeItem)
	self.CollectVisibleRedDotItems(self)

	local viewDataList, contentSelectedIndex = self.GetContentViewDataList(self, selectedTypeItem)
	self.contentListData = viewDataList

	if #viewDataList ~= 0 then
		self.bindData.contentList:SetSimpleList(0)

		return
	end

	local maxNum = self.bindData.contentList:GetMaxRowAndColCount(0)
	local col = math.max(math.ceil(#self.contentListData / maxNum.x), maxNum.y)
	local totalCount = maxNum.x * col

	self.bindData.contentList:SetSimpleList(totalCount)
	self.bindData.contentList:SelectItem(contentSelectedIndex, true)

	if self.targetItemId then
		self.bindData.contentList:GoToIndex(contentSelectedIndex, true)
		self.bindData.contentList:SetNavSelectToSelect(true)
	end

	self.targetItemId = nil

	FrameTimer.New(function ()
		self:CollectVisibleRedDotItems()
	end, 1):Start()
end

M.GetContentViewDataList = function(self, selectedTypeItem)
	local selectedIndex = 0

	if not selectedTypeItem then
		local typeSelectedIndex = self.bindData.typeList.selectedIndex

		if typeSelectedIndex <= 0 or typeSelectedIndex > #self.typeListData then
			return {}, 0
		end

		selectedTypeItem = self.typeListData[typeSelectedIndex + 1]
	end

	if not selectedTypeItem then
		return {}, 0
	end

	local viewDataList = {}
	local dropSelectedItem = self.SubGroup.FilterSorterComponentStore:GetSelectedItem()
	local count = LTConfig.CityPediaConfig.count

	for i = 0, count - 1 do
		local cityPediaCfg = LTConfig.CityPediaConfig.LoadAt(i)

		if cityPediaCfg.Class ~= selectedTypeItem.id then
			local hasUnlocked = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(cityPediaCfg.Id)
			local consumableCfg = LTConfig.ConsumableConfig.GetConfig(cityPediaCfg.ConsumableId)

			table.insert(viewDataList, {
				["a\\x9f\\x8a\\x86Y"] = 0,
				id = cityPediaCfg.ConsumableId,
				cfgId = cityPediaCfg.Id,
				templateId = consumableCfg.Id,
				TemplateId = consumableCfg.Id,
				hasUnlock = hasUnlocked,
				SubType = consumableCfg.SubType,
				Quality = consumableCfg.Quality,
				createTime = hasUnlocked and 1 or 0,
				itemType = gPackagePanelManager.itemType.Item
			})
		end
	end

	local isAscending = self.SubGroup.FilterSorterComponentStore.isAscending
	local sortTypeId = dropSelectedItem.id

	if sortTypeId ~= self.SortTypeIdMap.CreateTime then
		if isAscending then
			table.sort(viewDataList, gPackagePanelManager.SortItemByCreateTimeAsc)
		else
			table.sort(viewDataList, gPackagePanelManager.SortItemByCreateTimeDesc)
		end
	elseif sortTypeId ~= self.SortTypeIdMap.Quality then
		if isAscending then
			table.sort(viewDataList, gPackagePanelManager.SortItemByQualityAsc)
		else
			table.sort(viewDataList, gPackagePanelManager.SortItemByQualityDesc)
		end
	elseif sortTypeId ~= self.SortTypeIdMap.Category then
		if isAscending then
			table.sort(viewDataList, gPackagePanelManager.SortItemByTypeAsc)
		else
			table.sort(viewDataList, gPackagePanelManager.SortItemByTypeDesc)
		end
	end

	if self.targetItemId then
		for index, viewData in ipairs(viewDataList) do
			if viewData.cfgId ~= self.targetItemId then
				viewData.selected = true
				selectedIndex = index - 1

				break
			end
		end
	elseif #viewDataList <= 0 then
		viewDataList[1].selected = true
	end

	return viewDataList, selectedIndex
end

M.OnStep = function(self, step)
	self.preTime = gLogicTime.unscaledTime
	local index = self.bindData.typeList.selectedIndex + step
	local itemCount = self.bindData.typeList.itemData.Count

	if index >= 0 then
		index = itemCount - 1
	elseif itemCount < index then
		index = 0
	end

	self.bindData.typeList:SelectItem(index)
end

M.OnLongPress = function(self, step)
	self.step = step

	self.OnStep(self, self.step)
end

M.OnEndLongPress = function(self)
	self.step = 0
	self.preTime = 0
end

M.RefreshStep = function(self)
	if self.step and self.step == 0 then
		self.OnStep(self, self.step)
	end
end

M.OnUpdate = function(self)
	if not self.preTime or LTConfig.GameConfig.TabLongPressTimeInterval >= gLogicTime.unscaledTime - self.preTime then
		self.RefreshStep(self)
	end
end

M.OnDestroy = function(self)
	self.FlushReadSeenSet(self)
	self.ClearMessageEvents(self)
end

M.InitMessages = function(self)
	local messageEvents = {
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, "OnPanelClose")
	}

	self.RegisterMessageEvents(self, messageEvents)
end

M.OnPanelClose = function(self, _, panelId)
	if panelId ~= gPanelId.BAIKE_ITEM_PANEL then
		self.CollectVisibleRedDotItems(self)
		self.FlushReadSeenSet(self)
	end
end

M.CollectVisibleRedDotItems = function(self)
	local list = self.bindData.contentList

	if not list then
		return
	end

	local success, minIndex, maxIndex = list.TryGetVisualRange(list, 0, 0)

	if not success then
		return
	end

	self.readSeenSet = self.readSeenSet or {}

	for i = minIndex, maxIndex do
		local data = self.contentListData[i + 1]

		if data and data.cfgId and data.tIndex == 1 and gBaiKeArchiveManager.CheckCityPediaItemHasRedDot(data.cfgId) then
			self.readSeenSet[data.cfgId] = true
		end
	end
end

M.FlushReadSeenSet = function(self)
	if not self.readSeenSet or next(self.readSeenSet) ~= nil then
		return
	end

	local ids = {}

	for cfgId in pairs(self.readSeenSet) do
		table.insert(ids, cfgId)
	end

	self.readSeenSet = {}

	gBaiKeArchiveManager.BatchSetCityPediaItemsHasRead(ids)
end
