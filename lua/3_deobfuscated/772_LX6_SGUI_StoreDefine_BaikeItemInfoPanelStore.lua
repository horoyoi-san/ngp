C_BaikeItemInfoPanelStore = DefClass("C_BaikeItemInfoPanelStore", C_BaikeItemInfoPanelStore, C_StoreGroup)
GroupName2Class.BaikeItemInfoPanelStore = C_BaikeItemInfoPanelStore
local M = C_BaikeItemInfoPanelStore

function M:ctor()
	self.typeListData = {}
	self.contentListData = {}
	self.tagListData = {}
	self.textTagListData = {}
end

function M:OnAwake()
	self.bindData.typeList.luaSimpleRenderItem = self:CreateAction("OnTypeRenderItem")
	self.bindData.typeList.luaSelectedChanged = self:CreateAction("OnTypeSelectedChange")
	self.bindData.typeList.onGetTIndex = self:CreateAction("OnGetTypeListTIndex")
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction("OnContentRenderItem")
	self.bindData.contentList.luaSelectedChanged = self:CreateAction("OnContentSelectedChange")
	self.bindData.contentList.onGetTIndex = self:CreateAction("OnGetContentListTIndex")
	self.bindData.tagList.luaSimpleRenderItem = self:CreateAction("OnTagRenderItem")
	self.bindData.tagList.luaSimpleClick = self:CreateAction("OnTagItemClick")
	self.bindData.tagList.onGetTIndex = self:CreateAction("OnGetTagListTIndex")
	self.bindData.textTagList.luaSimpleRenderItem = self:CreateAction("OnTextTagRenderItem")
	self.bindData.textTagList.onGetTIndex = self:CreateAction("OnGetTextTagListTIndex")
	self.bindData.leftButton.luaClick = self:CreateActionWithArgs("OnStep", -1)
	self.bindData.leftButton.luaLongPress = self:CreateActionWithArgs("OnLongPress", -1)
	self.bindData.leftButton.luaEndLongPress = self:CreateActionWithArgs("OnEndLongPress", -1)
	self.bindData.rightButton.luaClick = self:CreateActionWithArgs("OnStep", 1)
	self.bindData.rightButton.luaLongPress = self:CreateActionWithArgs("OnLongPress", 1)
	self.bindData.rightButton.luaEndLongPress = self:CreateActionWithArgs("OnEndLongPress", 1)
end

function M:ShowPanel(args)
	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(args)
	self.targetFirstCategoryId = args.targetFirstCategoryId
	self.targetItemId = args.targetItemId
	self.step = 0
end

function M:InitView()
	self:InitDropMenu()

	local typeViewDataList, selectedIndex = self:GetTypeViewDataList()
	self.typeListData = typeViewDataList

	self.bindData.typeList:SetSimpleList(#typeViewDataList)
	self.bindData.typeList:SelectItem(selectedIndex, true)

	local isShowArrowButton = #typeViewDataList > 0
	self.bindData.sortControl = isShowArrowButton and 1 or 0
	local current, total = gBaiKeArchiveManager.GetCityPediaFisrtClassPorgress(self.targetFirstCategoryId)
	self.bindData.current = current
	self.bindData.total = total
end

function M:InitDropMenu()
	self.SortTypeIdMap = {
		Quality = 2,
		CreateTime = 1,
		Category = 3
	}
	self.selectorList = {
		{
			title = 560,
			id = self.SortTypeIdMap.CreateTime
		},
		{
			title = 553,
			id = self.SortTypeIdMap.Quality
		},
		{
			title = 554,
			id = self.SortTypeIdMap.Category
		}
	}

	self.SubGroup.FilterSorterComponentStore:SetData({
		onSortChanged = self:CreateAction("OnSortBtnClick"),
		sortList = self.selectorList
	})
	self.SubGroup.FilterSorterComponentStore:SelectOption(0, true)
end

function M:OnSortBtnClick(_, _)
	self:RefreshContentListView()
end

function M:SelectedTargetItem(targetId)
	self.targetItemId = targetId
	local _, selectedIndex = self:GetTypeViewDataList()

	self.bindData.typeList:SelectItem(selectedIndex, true)
end

function M:GetTypeViewDataList()
	local selectedIndex = 0
	local viewDataList = {}
	local count = LTConfig.CityPediaSecondClassConfig.count

	for i = 0, count - 1 do
		local cityPediaSecondClassCfg = LTConfig.CityPediaSecondClassConfig.LoadAt(i)

		if cityPediaSecondClassCfg.FatherId == self.targetFirstCategoryId and gBaiKeArchiveManager.CheckCityPediaSecondClassHasUnlocked(cityPediaSecondClassCfg.Id) then
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
		targetSecondCategoryId = #viewDataList > 0 and viewDataList[1].id or nil
	end

	for index, viewData in ipairs(viewDataList) do
		if viewData.id == targetSecondCategoryId then
			viewData.selected = true
			selectedIndex = index - 1

			break
		end
	end

	return viewDataList, selectedIndex
end

function M:OnTypeRenderItem(btn, index)
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

function M:OnContentRenderItem(btn, index)
	local data = self.contentListData[index + 1]

	if not data or data.tIndex == 1 then
		btn.interactable = false

		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(data.cfgId)
	store.iconId = cityPediaCfg.Image
	store.count = cityPediaCfg.Name
	local redDotKey = gBaiKeArchiveManager.GetCityPediaRedDotKey(data.cfgId)
	store.button.redKey = redDotKey
	store.button.enabledTooltip = false
	store.quality = data.Quality
	local hasRedDot = gBaiKeArchiveManager.CheckCityPediaItemHasRedDot(data.cfgId)
	local isLock = not gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(data.cfgId)

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)

	store.isLock = isLock and 1 or 0
	btn.enabledTooltip = false
	btn.interactable = true
end

function M:OnContentSelectedChange()
	local selectedIndex = self.bindData.contentList.selectedIndex

	if selectedIndex >= 0 and selectedIndex < #self.contentListData then
		local selectedItem = self.contentListData[selectedIndex + 1]

		if selectedItem and gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(selectedItem.cfgId) then
			gBaiKeArchiveManager.SetCityPediaItemHasRead(selectedItem.cfgId)

			local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(selectedItem.cfgId)
			self.bindData.name = cityPediaCfg.Name
			self.bindData.iconId = cityPediaCfg.Image
			self.bindData.description = cityPediaCfg.Story
			local des = cityPediaCfg.Des
			self.bindData.effectControl = string.is_null_or_empty(des) and 0 or 1
			self.bindData.effectDescription = des or ""
			self.bindData.isLocked = 1
			local tagViewDataList = self:GetTagViewDataList(selectedItem.cfgId)
			self.tagListData = tagViewDataList

			self.bindData.tagList:SetSimpleList(#tagViewDataList)

			local textTagViewDataList = self:GetTextTagViewDataList(selectedItem.cfgId)
			self.textTagListData = textTagViewDataList

			self.bindData.textTagList:SetSimpleList(#textTagViewDataList)

			if self.bindData.tagNavigation then
				self.bindData.tagNavigation.gameObject:SetActive(#tagViewDataList > 0)
			end
		else
			self.bindData.isLocked = 0
		end
	end
end

function M:GetTagViewDataList(id)
	local viewDataList = {}
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(id)
	local entriesIdList = cityPediaCfg.EntriesIdList

	for _, tagId in ipairs(entriesIdList) do
		local cityPediaPediaTagCfg = LTConfig.CityPediaPediaTagConfig.GetConfig(tagId)

		if cityPediaPediaTagCfg.CityPediaId > 0 then
			table.insert(viewDataList, {
				id = tagId
			})
		end
	end

	return viewDataList
end

function M:GetTextTagViewDataList(id)
	local viewDataList = {}
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(id)
	local entriesIdList = cityPediaCfg.EntriesIdList

	for _, tagId in ipairs(entriesIdList) do
		local cityPediaPediaTagCfg = LTConfig.CityPediaPediaTagConfig.GetConfig(tagId)

		if cityPediaPediaTagCfg.CityPediaId == 0 then
			table.insert(viewDataList, {
				id = tagId
			})
		end
	end

	return viewDataList
end

function M:OnTagRenderItem(btn, index)
	local data = self.tagListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local cityPediaPediaTagCfg = LTConfig.CityPediaPediaTagConfig.GetConfig(data.id)
	store.name = cityPediaPediaTagCfg.Name
end

function M:OnTagItemClick(btn, index)
	local data = self.tagListData[index + 1]

	if not data then
		return
	end

	local cityPediaPediaTagCfg = LTConfig.CityPediaPediaTagConfig.GetConfig(data.id)

	gMessageManager:SendMessage(gEventConstants.ON_BAIKE_TAG_SELECTED, cityPediaPediaTagCfg.CityPediaId)
end

function M:OnTextTagRenderItem(btn, index)
	local data = self.textTagListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local cityPediaPediaTagCfg = LTConfig.CityPediaPediaTagConfig.GetConfig(data.id)
	store.name = cityPediaPediaTagCfg.Name
end

function M:OnGetTypeListTIndex(index)
	return 0
end

function M:OnGetContentListTIndex(index)
	local luaIndex = index + 1

	if luaIndex <= #self.contentListData then
		return self.contentListData[luaIndex].tIndex or 0
	else
		return 1
	end
end

function M:OnGetTagListTIndex(index)
	return 0
end

function M:OnGetTextTagListTIndex(index)
	return 0
end

function M:OnTypeSelectedChange()
	self:RefreshContentListView()
end

function M:RefreshContentListView()
	local selectedIndex = self.bindData.typeList.selectedIndex

	if selectedIndex >= 0 and selectedIndex < #self.typeListData then
		local viewDataList, contentSelectedIndex = self:GetContentViewDataList()
		self.contentListData = viewDataList
		local maxNum = self.bindData.contentList:GetMaxRowAndColCount(0)
		local col = math.max(math.ceil(#self.contentListData / maxNum.x), maxNum.y)
		local totalCount = maxNum.x * col

		self.bindData.contentList:SetSimpleList(totalCount)
		self.bindData.contentList:SelectItem(contentSelectedIndex, true)

		self.targetItemId = self.targetItemId and self.bindData.contentList:GoToIndex(contentSelectedIndex, true)
	end
end

function M:GetContentViewDataList()
	local selectedIndex = 0
	local typeSelectedIndex = self.bindData.typeList.selectedIndex

	if typeSelectedIndex < 0 or typeSelectedIndex >= #self.typeListData then
		return {}, 0
	end

	local selectedTypeItem = self.typeListData[typeSelectedIndex + 1]
	local viewDataList = {}
	local dropSelectedItem = self.SubGroup.FilterSorterComponentStore:GetSelectedItem()
	local count = LTConfig.CityPediaConfig.count

	for i = 0, count - 1 do
		local cityPediaCfg = LTConfig.CityPediaConfig.LoadAt(i)

		if cityPediaCfg.Class == selectedTypeItem.id then
			local hasUnlocked = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(cityPediaCfg.Id)
			local consumableCfg = LTConfig.ConsumableConfig.GetConfig(cityPediaCfg.ConsumableId)

			table.insert(viewDataList, {
				tIndex = 0,
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

	if sortTypeId == self.SortTypeIdMap.CreateTime then
		if isAscending then
			table.sort(viewDataList, gPackagePanelManager.SortItemByCreateTimeAsc)
		else
			table.sort(viewDataList, gPackagePanelManager.SortItemByCreateTimeDesc)
		end
	elseif sortTypeId == self.SortTypeIdMap.Quality then
		if isAscending then
			table.sort(viewDataList, gPackagePanelManager.SortItemByQualityAsc)
		else
			table.sort(viewDataList, gPackagePanelManager.SortItemByQualityDesc)
		end
	elseif sortTypeId == self.SortTypeIdMap.Category then
		if isAscending then
			table.sort(viewDataList, gPackagePanelManager.SortItemByTypeAsc)
		else
			table.sort(viewDataList, gPackagePanelManager.SortItemByTypeDesc)
		end
	end

	if self.targetItemId then
		for index, viewData in ipairs(viewDataList) do
			if viewData.cfgId == self.targetItemId then
				viewData.selected = true
				selectedIndex = index - 1

				break
			end
		end
	elseif #viewDataList > 0 then
		viewDataList[1].selected = true
	end

	return viewDataList, selectedIndex
end

function M:OnStep(step)
	self.preTime = gLogicTime.unscaledTime
	local index = self.bindData.typeList.selectedIndex + step
	local itemCount = self.bindData.typeList.itemData.Count

	if index < 0 then
		index = itemCount - 1
	elseif itemCount <= index then
		index = 0
	end

	self.bindData.typeList:SelectItem(index)
end

function M:OnLongPress(step)
	self.step = step

	self:OnStep(self.step)
end

function M:OnEndLongPress()
	self.step = 0
	self.preTime = 0
end

function M:RefreshStep()
	if self.step and self.step ~= 0 then
		self:OnStep(self.step)
	end
end

function M:OnUpdate()
	if not self.preTime or LTConfig.GameConfig.TabLongPressTimeInterval < gLogicTime.unscaledTime - self.preTime then
		self:RefreshStep()
	end
end

function M:OnDestroy()
	return
end
