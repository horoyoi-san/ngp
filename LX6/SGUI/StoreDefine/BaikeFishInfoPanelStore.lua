-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BaikeFishInfoPanelStore.lua
-- Decompiled from: 01568_BaikeFishInfoPanelStore.lua_83cbd7e24cf5.luajit

C_BaikeFishInfoPanelStore = DefClass("C_BaikeFishInfoPanelStore", C_BaikeFishInfoPanelStore, C_StoreGroup)
GroupName2Class.BaikeFishInfoPanelStore = C_BaikeFishInfoPanelStore
local M = C_BaikeFishInfoPanelStore
local INFO_SELECTOR_ITEMS = {
	{
		["JDcgh<"] = "\\xc3L\\x84\\xec-\\xaeZ\\xc2-8\\xc0Rʹ\\xb1p\\xadl\\\\x9e\\xc2"
	},
	{
		["JDcgh<"] = "\\xc3L\\x84\\xec-\\xaeZ\\xc2-8\\xc0Rʹ\\xb1p\\xadl\\\\x9e\\xc2"
	},
	{
		["JDcgh<"] = "\\xb7\\xc4Tg\\x897`P\\xa1nIe\\xadm\\xf2\\xbd\\x85\\xfe_g\\xa7"
	},
	{
		["JDcgh<"] = "R\\xf54\\xe4 9(\\xf0q/\\xc1b\\x8fL\\xef\\xe2"
	},
	{
		["JDcgh<"] = "R\\xf54\\xe4 9(\\xe1`)\\xc1b\\x8fL\\xef\\xe2"
	}
}
local FIRST_CATCH_TIME_PATTERN_TEXT_ID = 89900028

local JoinConfigNames = function(idList, config)
	if not idList then
		return ""
	end

	local names = {}

	for _, id in ipairs(idList) do
		local cfg = config.GetConfig(id)

		if cfg and cfg.Name then
			table.insert(names, cfg.Name)
		end
	end

	return table.concat(names, "、")
end

M.ctor = function(self)
	self.typeListData = {}
	self.contentListData = {}
	self.infoTemplateStore = nil
	self.infoTemplateInit = false
	self.curFishId = nil
	self.readSeenSet = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.openCtrlEnum = {
		u2xU = 1,
		["N\\xa2\\xad\\xbc\\xb3"] = 0
	}
	self.isLockedEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
	self.effectControlEnum = {
		["\\x9d"] = 0,
		["\\x9c"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.openCtrlEnum = nil
	self.isLockedEnum = nil
	self.effectControlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.InitMessages(self)
	self.RegisterWidget(self)
end

M.OnDestroy = function(self)
	self.FlushReadSeenSet(self)
	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.InitMessages = function(self)
	local messageEvents = {
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, self.OnPanelClose)
	}

	self.RegisterMessageEvents(self, messageEvents)
end

M.OnPanelClose = function(self, _, panelId)
	if panelId ~= gPanelId.BAIKE_ITEM_PANEL then
		self.CollectVisibleRedDotItems(self)
		self.FlushReadSeenSet(self)
	end
end

M.DefineAllVariables = function(self)
	self.step = 0
	self.preTime = 0
end

M.OnUpdate = function(self)
	if not self.preTime or LTConfig.GameConfig.TabLongPressTimeInterval >= gLogicTime.unscaledTime - self.preTime then
		self.RefreshStep(self)
	end
end

M.IsMobileAdaptive = function(self)
	return not gCS.LuaUtils.IsNonMobileAdaptive()
end

M.RegisterWidget = function(self)
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction(self.OnSimpleRenderContentListItem)
	self.bindData.contentList.luaSelectedChanged = self:CreateAction(self.OnContentSelectedChange)
	self.bindData.contentList.onGetTIndex = self:CreateAction(self.OnGetContentListTIndex)
	self.bindData.contentList.luaSimpleClick = self:CreateAction(self.OnSimpleClickContentList)

	self.bindData.contentList:RegisterToScrollEndEvent(self:CreateAction(self.CollectVisibleRedDotItems))

	if self.bindData.infoSelector then
		self.bindData.infoSelector.luaClick = self.CreateAction(self, self.OnClickInfoSelector)
	end

	if self.bindData.infoCloseBtn then
		self.bindData.infoCloseBtn.luaClick = self.CreateAction(self, self.OnClickInfoClose)
	end

	if self.bindData.dropMenuList then
		self.bindData.dropMenuList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderDropMenuItem)
	end

	if self.IsMobileAdaptive(self) then
		return
	end

	self.bindData.typeList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTypeListItem)
	self.bindData.typeList.luaSelectedChanged = self.CreateAction(self, self.OnTypeSelectedChange)
	self.bindData.typeList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickTypeList)

	if self.bindData.leftButton then
		self.bindData.leftButton.luaClick = self.CreateActionWithArgs(self, self.OnStep, -1)
		self.bindData.leftButton.luaLongPress = self.CreateActionWithArgs(self, self.OnLongPress, -1)
		self.bindData.leftButton.luaEndLongPress = self.CreateAction(self, self.OnEndLongPress)
	end

	if self.bindData.rightButton then
		self.bindData.rightButton.luaClick = self.CreateActionWithArgs(self, self.OnStep, 1)
		self.bindData.rightButton.luaLongPress = self.CreateActionWithArgs(self, self.OnLongPress, 1)
		self.bindData.rightButton.luaEndLongPress = self.CreateAction(self, self.OnEndLongPress)
	end
end

M.OnStep = function(self, step)
	self.preTime = gLogicTime.unscaledTime
	local itemCount = self.bindData.typeList.itemData.Count

	if itemCount < 0 then
		return
	end

	local index = self.bindData.typeList.selectedIndex + step

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

M.ShowPanel = function(self, args)
	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.targetFirstCategoryId = args and args.targetFirstCategoryId
	self.targetItemId = args and args.targetItemId
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
	local typeViewDataList, typeSelectedIndex = self:GetTypeViewDataList()
	self.typeListData = typeViewDataList

	self.bindData.typeList:SetSimpleList(#typeViewDataList)

	if #typeViewDataList <= 0 then
		self.bindData.typeList:SelectItem(typeSelectedIndex, true)
	else
		self.contentListData = {}

		self.bindData.contentList:SetSimpleList(0)
	end
end

M.InitMobileTabView = function(self)
	local typeViewDataList, typeSelectedIndex = self.GetTypeViewDataList(self)
	self.typeListData = typeViewDataList

	if #typeViewDataList <= 0 then
		self.SubGroup.CommonTabSingleStore:SetData(typeViewDataList, nil, typeSelectedIndex, nil, self:CreateAction(self.OnMobileTabChanged), self:CreateAction(self.OnMobileTabRenderItem), nil, false)
	else
		self.contentListData = {}

		self.bindData.contentList:SetSimpleList(0)
	end
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
	store.title = cityPediaSecondClassCfg and cityPediaSecondClassCfg.Name or ""
	local hasRedDot = gBaiKeArchiveManager.CheckCityPediaSecondClassHasRedDot(data.id)
	local redDotKey = gBaiKeArchiveManager.GetCityPediaSecondClassRedDotKey(data.id)
	store.button.redKey = redDotKey

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)
end

M.InitDropMenu = function(self)
	self.SortTypeIdMap = {
		["pH˼\\x90\r\\x8c\r\\xc4\\xed"] = 1
	}
	self.selectorList = {
		{
			["Y\\xa7\\xb6\\xa3\\xb3"] = 560,
			id = self.SortTypeIdMap.CreateTime
		}
	}

	self.SubGroup.FilterSorterComponentStore:SetData({
		onSortChanged = self:CreateAction(self.OnSortBtnClick),
		sortList = self.selectorList
	})
	self.SubGroup.FilterSorterComponentStore:SelectOption(0, true)

	self.SubGroup.FilterSorterComponentStore.bindData.showSorter = 0
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

M.OnSimpleRenderTypeListItem = function(self, btn, index)
	local data = self.typeListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cityPediaSecondClassCfg = LTConfig.CityPediaSecondClassConfig.GetConfig(data.id)
	store.name = cityPediaSecondClassCfg and cityPediaSecondClassCfg.Name or ""
	local hasRedDot = gBaiKeArchiveManager.CheckCityPediaSecondClassHasRedDot(data.id)
	local redDotKey = gBaiKeArchiveManager.GetCityPediaSecondClassRedDotKey(data.id)
	store.button.redKey = redDotKey

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)
end

M.OnSimpleClickTypeList = function(self, btn, index)
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

		if cityPediaCfg.Class ~= selectedTypeItem.id and (cityPediaCfg.FishId or 0) <= 0 then
			local fishCfg = LTConfig.FishingFishConfig.GetConfig(cityPediaCfg.FishId)
			local hasUnlock = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(cityPediaCfg.Id)

			table.insert(viewDataList, {
				["a\\x9f\\x8a\\x86Y"] = 0,
				cfgId = cityPediaCfg.Id,
				fishId = cityPediaCfg.FishId,
				Quality = fishCfg and fishCfg.Quality or 0,
				hasUnlock = hasUnlock
			})
		end
	end

	local isAscending = self.SubGroup.FilterSorterComponentStore.isAscending
	local sortTypeId = dropSelectedItem and dropSelectedItem.id

	if sortTypeId ~= self.SortTypeIdMap.CreateTime then
		table.sort(viewDataList, function (a, b)
			if a.hasUnlock == b.hasUnlock then
				return a.hasUnlock
			end

			if isAscending then
				return a.cfgId <= b.cfgId
			else
				return b.cfgId <= a.cfgId
			end
		end)
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

M.OnSimpleRenderContentListItem = function(self, btn, index)
	local data = self.contentListData[index + 1]

	if not data or data.tIndex ~= 1 then
		btn.interactable = false

		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local fishCfg = LTConfig.FishingFishConfig.GetConfig(data.fishId)

	if not fishCfg then
		return
	end

	store.iconId = fishCfg.IconRes
	store.count = fishCfg.Name
	store.quality = data.Quality
	local redDotKey = gBaiKeArchiveManager.GetCityPediaRedDotKey(data.cfgId)
	btn.redKey = redDotKey
	local hasRedDot = gBaiKeArchiveManager.CheckCityPediaItemHasRedDot(data.cfgId)

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)

	if hasRedDot then
		self.readSeenSet = self.readSeenSet or {}
		self.readSeenSet[data.cfgId] = true
	end

	local isLock = not gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(data.cfgId)
	store.isLock = isLock and 1 or 0
	btn.enabledTooltip = false
	btn.interactable = true
end

M.OnSimpleClickContentList = function(self, btn, index)
	local data = self.contentListData[index + 1]

	if not data or data.fishId == self.curFishId then
		return
	end
end

M.OnContentSelectedChange = function(self)
	local selectedIndex = self.bindData.contentList.selectedIndex

	if selectedIndex <= 0 or selectedIndex > #self.contentListData then
		return
	end

	if self.IsMobileAdaptive(self) then
		self.bindData.openCtrl = self.openCtrlEnum.close
	end

	self.ShowItemInfo(self, self.contentListData[selectedIndex + 1])
end

M.OnGetContentListTIndex = function(self, index)
	local luaIndex = index + 1

	if luaIndex < #self.contentListData then
		return self.contentListData[luaIndex].tIndex or 0
	else
		return 1
	end
end

M.OnClickInfoSelector = function(self)
	if self.bindData.openCtrl ~= self.openCtrlEnum.open then
		self.bindData.openCtrl = self.openCtrlEnum.close
	else
		self.bindData.openCtrl = self.openCtrlEnum.open

		self.bindData.dropMenuList:SetSimpleList(#INFO_SELECTOR_ITEMS)
	end
end

M.OnClickInfoClose = function(self)
	self.bindData.openCtrl = self.openCtrlEnum.close
end

M.ReopenInfoSelector = function(self)
	if self.IsMobileAdaptive(self) then
		return
	end

	if self.bindData.openCtrl ~= self.openCtrlEnum.open then
		return
	end

	self.bindData.openCtrl = self.openCtrlEnum.open

	self.bindData.dropMenuList:SetSimpleList(#INFO_SELECTOR_ITEMS)
end

M.RefreshInfoSelector = function(self)
	if not self.bindData.dropMenuList then
		return
	end

	self.bindData.dropMenuList:SetSimpleList(#INFO_SELECTOR_ITEMS)
end

M.OnRenderDropMenuItem = function(self, btn, index)
	local itemDef = INFO_SELECTOR_ITEMS[index + 1]

	if not itemDef then
		return
	end

	local store = gStoreManager:GetStoreGroup("DropMenuBtn"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = LTConfig.CityPediaConfig[itemDef.iconField] or 0
	store.title = self:GetInfoSelectorItemTitle(index + 1)
end

M.GetInfoSelectorItemTitle = function(self, itemIndex)
	local fishCfg = self.curFishId and LTConfig.FishingFishConfig.GetConfig(self.curFishId)

	if itemIndex ~= 4 then
		return fishCfg and JoinConfigNames(fishCfg.SpawnInfo, LTConfig.FishingSpotConfig) or ""
	elseif itemIndex ~= 5 then
		return fishCfg and JoinConfigNames(fishCfg.BaitCompatibility, LTConfig.FishingGearConfig) or ""
	end

	local record = self.curFishId and gBaiKeArchiveManager.GetFishRecordInfo(self.curFishId)

	if not record then
		return ""
	end

	if itemIndex ~= 1 then
		if not record.FirstCatchTime or record.FirstCatchTime ~= 0 then
			return ""
		end

		local pattern = LTConfig.TextScriptTextConfig.GetConfig(FIRST_CATCH_TIME_PATTERN_TEXT_ID).Text

		return gTimeUtils:DateFormatByPattern(pattern, record.FirstCatchTime)
	elseif itemIndex ~= 2 then
		local spotCfg = record.FirstCatchSpot and record.FirstCatchSpot <= 0 and LTConfig.FishingSpotConfig.GetConfig(record.FirstCatchSpot)

		return spotCfg and spotCfg.Name or ""
	elseif itemIndex ~= 3 then
		return string.format("%.0fg  %.0fcm", record.BestWeight or 0, record.BestLength or 0)
	end

	return ""
end

M.InitInfoTemplate = function(self)
	if self.infoTemplateInit then
		return
	end

	if not self.bindData.infoTemplate then
		return
	end

	self.infoTemplateStore = gStoreManager:GetStoreGroup(self.bindData.infoTemplate.Store):GetStoreByWidget(self.bindData.infoTemplate)
	self.infoTemplateInit = true
end

M.ShowItemInfo = function(self, selectedItem)
	if not selectedItem then
		return
	end

	if not gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(selectedItem.cfgId) then
		self.curFishId = nil

		self.RefreshInfoSelector(self)

		self.bindData.isLocked = 0
		self.bindData.unLockTip = gBaiKeArchiveManager.GetCityPediaUnlockTipText(selectedItem.cfgId)

		return
	end

	local fishCfg = LTConfig.FishingFishConfig.GetConfig(selectedItem.fishId)

	if not fishCfg then
		return
	end

	self.curFishId = selectedItem.fishId

	self:RefreshInfoSelector()
	gBaiKeArchiveManager.SetCityPediaItemHasRead(selectedItem.cfgId)
	self:InitInfoTemplate()

	self.bindData.iconId = fishCfg.IconRes
	self.bindData.isLocked = 1
	local des = ""
	self.bindData.effectControl = string.is_null_or_empty(des) and 0 or 1

	if self.infoTemplateStore then
		self.infoTemplateStore.name = fishCfg.Name or ""

		if self.infoTemplateStore.scrollRect and self.infoTemplateStore.scrollRect.content then
			self.infoTemplateStore.scrollRect.content.text = fishCfg.Description or ""
		end

		self.infoTemplateStore.effectText = des
		self.infoTemplateStore.tagCtrl = 0
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
