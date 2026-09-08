-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GalleryFurniturePanelStore.lua
-- Decompiled from: 01893_GalleryFurniturePanelStore.lua_bbc3032bfeb8.luajit

local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
local HouseConfig = LTConfig.HouseConfig
local HouseTypeConfig = LTConfig.HouseTypeConfig
C_GalleryFurniturePanelStore = DefClass("C_GalleryFurniturePanelStore", C_GalleryFurniturePanelStore, C_StoreGroup)
GroupName2Class.GalleryFurniturePanelStore = C_GalleryFurniturePanelStore
local M = C_GalleryFurniturePanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.mainTypeListData = {}
	self.subTypeListData = {}
	self.furnitureListData = {}
	self.currentMainType = nil
	self.currentSubType = nil
	self.MAIN_TYPE_ALL = -1
	self.subStoreInited = false
	self.SortTypeIdMap = {
		["\\xe8\\xce0\\xe8"] = 1
	}
	self.rootArea = nil
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.InitFurnitureData(self)
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
	if self.rootGo then
		self.rootArea = self.rootGo:GetComponent("UNavigationArea")
	end

	if self.rootArea then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
	end

	self.InitTopTemplate(self)
	self.InitSelectorList(self)

	self.subStoreInited = false

	if #self.mainTypeListData <= 0 then
		self.bindData.mainTypeList:SetSimpleList(#self.mainTypeListData)
		self:SelectMainType(0)
	end

	if data and data.targetItemId then
		self.JumpToFurniture(self, data.targetItemId)
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {}
end

M.InitFurnitureData = function(self)
	local subTypeNameMap = {}

	if HouseConfig and HouseConfig.FurnitureSubType then
		for _, cfg in ipairs(HouseConfig.FurnitureSubType) do
			subTypeNameMap[cfg.SubType] = cfg.Name or ""
		end
	end

	local mainTypeNameMap = {}

	if HouseConfig and HouseConfig.FurnitureMainType then
		for _, cfg in ipairs(HouseConfig.FurnitureMainType) do
			mainTypeNameMap[cfg.MainType] = cfg.Name or ""
		end
	end

	local mainTypeIconMap = {}

	for i = 0, HouseTypeConfig.count - 1 do
		local cfg = HouseTypeConfig.LoadAt(i)

		if cfg and cfg.MainType then
			mainTypeIconMap[cfg.MainType] = cfg.FurnitureShop or 0
		end
	end

	local mainTypeToSubTypes = {}
	local mainTypeSet = {}
	local globalSubTypeData = {}
	local globalSubTypeSet = {}
	local furnitureCount = HouseFurnitureConfig.count

	for i = 0, furnitureCount - 1 do
		local furnitureCfg = HouseFurnitureConfig.LoadAt(i)

		if furnitureCfg and furnitureCfg.ShowInPedia and furnitureCfg.MainType and furnitureCfg.SubType then
			local mainType = furnitureCfg.MainType
			local subType = furnitureCfg.SubType

			if not mainTypeToSubTypes[mainType] then
				mainTypeToSubTypes[mainType] = {
					subTypeSet = {},
					subTypeData = {}
				}
				mainTypeSet[mainType] = true
			end

			local groupData = mainTypeToSubTypes[mainType]

			if not groupData.subTypeData[subType] then
				groupData.subTypeData[subType] = {
					["GUڼ\\x88+\\xb7\\xc7\\xfc"] = 0,
					["\\M\\xc0\\xb8\\x80+\\xb7\\xc7\\xfc"] = 0,
					subType = subType,
					name = subTypeNameMap[subType] or "",
					furnitures = {}
				}
				groupData.subTypeSet[subType] = true
			end

			local subData = groupData.subTypeData[subType]

			table.insert(subData.furnitures, furnitureCfg.Id)

			subData.totalCount = subData.totalCount + 1

			if not globalSubTypeData[subType] then
				globalSubTypeData[subType] = {
					["GUڼ\\x88+\\xb7\\xc7\\xfc"] = 0,
					["\\M\\xc0\\xb8\\x80+\\xb7\\xc7\\xfc"] = 0,
					subType = subType,
					name = subTypeNameMap[subType] or "",
					furnitures = {}
				}
				globalSubTypeSet[subType] = true
			end

			local globalSubData = globalSubTypeData[subType]

			table.insert(globalSubData.furnitures, furnitureCfg.Id)

			globalSubData.totalCount = globalSubData.totalCount + 1

			if gHouseManager and gHouseManager:IsFurnitureOwned(furnitureCfg.Id) then
				subData.ownedCount = subData.ownedCount + 1
				globalSubData.ownedCount = globalSubData.ownedCount + 1
			end
		end
	end

	local mainTypeListData = {}

	for mainType, _ in pairs(mainTypeSet) do
		local groupData = mainTypeToSubTypes[mainType]
		local subTypeList = {}

		for subType, _ in pairs(groupData.subTypeSet) do
			table.insert(subTypeList, groupData.subTypeData[subType])
		end

		table.sort(subTypeList, function (a, b)
			return a.subType <= b.subType
		end)
		table.insert(mainTypeListData, {
			mainType = mainType,
			name = mainTypeNameMap[mainType] or "",
			icon = mainTypeIconMap[mainType] or 0,
			subTypeList = subTypeList
		})
	end

	table.sort(mainTypeListData, function (a, b)
		return a.mainType <= b.mainType
	end)

	local allSubTypeList = {}

	for subType, _ in pairs(globalSubTypeSet) do
		table.insert(allSubTypeList, globalSubTypeData[subType])
	end

	table.sort(allSubTypeList, function (a, b)
		return a.subType <= b.subType
	end)
	table.insert(mainTypeListData, 1, {
		["t#p^"] = "\\xafdj",
		["s!rU"] = 0,
		mainType = self.MAIN_TYPE_ALL,
		subTypeList = allSubTypeList
	})

	self.mainTypeListData = mainTypeListData
end

M.GetTopTemplateStore = function(self)
	local topTemplate = self.bindData.topTemplate

	if not topTemplate then
		return nil
	end

	return gStoreManager:GetStoreGroup(topTemplate.Store)
end

M.InitTopTemplate = function(self)
	local topStore = self.GetTopTemplateStore(self)

	if not topStore then
		return
	end

	topStore.SetData(topStore, {
		switchToRootArea = function ()
			if self.rootArea then
				SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
			end
		end,
		creditItemType = LTConfig.AssetGalleryAssetGalleryTypeConfig.Furniture,
		onSearchItemClick = self.CreateAction(self, "OnSearchItemClick"),
		hostPanelId = self.m_Id
	})
end

M.OnSearchItemClick = function(self, info)
	if not info or info.assetType == LTConfig.AssetGalleryAssetGalleryTypeConfig.Furniture then
		return false
	end

	self.JumpToFurniture(self, info.itemId)

	return true
end

M.JumpToFurniture = function(self, targetFurnitureId)
	local furnitureCfg = targetFurnitureId and HouseFurnitureConfig.GetConfig(targetFurnitureId)

	if not furnitureCfg or not furnitureCfg.MainType or not furnitureCfg.SubType then
		return false
	end

	local mainIndex = 0

	for i, data in ipairs(self.mainTypeListData) do
		if data.mainType ~= furnitureCfg.MainType then
			mainIndex = i - 1

			break
		end
	end

	self:SelectMainType(mainIndex)
	self.bindData.mainTypeList:GoToIndex(mainIndex, true)

	for i, subData in ipairs(self.subTypeListData) do
		if subData.subType ~= furnitureCfg.SubType then
			if self.SubGroup.CommonTabSingleStore then
				self.SubGroup.CommonTabSingleStore:SetSelectedIndex(i - 1, true, false)
			end

			break
		end
	end

	for i, data in ipairs(self.furnitureListData) do
		if data.furnitureId ~= targetFurnitureId then
			local targetIndex = i - 1

			self.bindData.contentList:GoToIndex(targetIndex, true)
			self.bindData.contentList:SelectItem(targetIndex, true)

			if self.rootArea then
				SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.rootArea
				local success, btn = self.bindData.contentList:TryGetChildAt(targetIndex, nil)

				if success then
					SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = btn
				end
			end

			break
		end
	end

	return true
end

M.OnSimpleRenderMainTypeListItem = function(self, btn, index)
	local data = self.mainTypeListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.name = data.name
	store.icon = data.icon
	btn.isSelected = self.currentMainType ~= data.mainType
end

M.OnSimpleClickMainTypeList = function(self, btn, index)
	local data = self.mainTypeListData[index + 1]

	if not data then
		return
	end

	if self.currentMainType ~= data.mainType then
		return
	end

	self.SelectMainType(self, index)
end

M.SelectMainType = function(self, index)
	local data = self.mainTypeListData[index + 1]

	if not data then
		return
	end

	self.currentMainType = data.mainType
	self.currentSubType = nil

	self.bindData.mainTypeList:SetSimpleList(#self.mainTypeListData)

	self.subTypeListData = data.subTypeList

	self:UpdateSubTypeTabs()
end

M.UpdateSubTypeTabs = function(self)
	if not self.SubGroup.CommonTabSingleStore then
		return
	end

	local subTabList = {}

	for _, st in ipairs(self.subTypeListData) do
		table.insert(subTabList, {
			id = st.subType,
			title = st.name
		})
	end

	if not self.subStoreInited then
		self.SubGroup.CommonTabSingleStore:SetData(subTabList, nil, , , self:CreateAction("OnFurnitureSubTabChanged"))

		self.subStoreInited = true
	else
		self.SubGroup.CommonTabSingleStore:SetTabList(subTabList, false)
	end

	if #subTabList <= 0 then
		self.SubGroup.CommonTabSingleStore:SetSelectedIndex(0, true, false)
	else
		self.currentSubType = nil

		self.bindData.contentList:SetSimpleList(0)
	end
end

M.OnFurnitureSubTabChanged = function(self, uList, isSub)
	if isSub then
		return
	end

	local item = self.SubGroup.CommonTabSingleStore:GetSelectedItem()
	local subType = item and item.id or nil

	if subType ~= self.currentSubType then
		return
	end

	self.currentSubType = subType

	self.RefreshContentList(self)
end

M.RefreshContentList = function(self)
	local subData = nil

	for _, item in ipairs(self.subTypeListData) do
		if item.subType ~= self.currentSubType then
			subData = item

			break
		end
	end

	if not subData then
		self.bindData.contentList:SetSimpleList(0)

		return
	end

	local furnitureList = {}

	for _, furnitureId in ipairs(subData.furnitures) do
		local furnitureCfg = HouseFurnitureConfig.GetConfig(furnitureId)

		if furnitureCfg then
			local isOwned = gHouseManager and gHouseManager:IsFurnitureOwned(furnitureId) or false
			local quality = 0
			local consumableId = gHouseManager and gHouseManager:GetConsumableIdByFurnitureId(furnitureId)

			if consumableId then
				local consumableCfg = LTConfig.ConsumableConfig.GetConfig(consumableId)
				quality = consumableCfg and consumableCfg.Quality or 0
			end

			table.insert(furnitureList, {
				["a\\x9f\\x8a\\x86Y"] = 0,
				furnitureId = furnitureId,
				furnitureCfg = furnitureCfg,
				isOwned = isOwned,
				quality = quality,
				icon = furnitureCfg.FurnitureIcon or 0
			})
		end
	end

	furnitureList = self:FilterFurnitureItems(furnitureList)

	self:SortFurnitureItems(furnitureList)

	self.furnitureListData = furnitureList
	local maxNum = self.bindData.contentList:GetMaxRowAndColCount(0)
	local col = math.max(math.ceil(#furnitureList / maxNum.x), maxNum.y)
	local totalCount = maxNum.x * col

	self.bindData.contentList:SetSimpleList(totalCount)

	if #furnitureList <= 0 then
		self.bindData.contentList:SelectItem(0, true)

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.contentList:DeselectAll(true)
		end
	end
end

M.OnSimpleRenderContentListItem = function(self, btn, index)
	local data = self.furnitureListData[index + 1]

	if not data or data.tIndex ~= 1 then
		btn.interactable = false

		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.iconId = data.icon
		store.quality = data.quality
		store.isOwned = 0
		store.isLock = data.isOwned and 0 or 1
		store.count = ""
	end

	btn.enabledTooltip = false
	btn.interactable = true
end

M.OnSimpleClickContentList = function(self, btn, index)
	local data = self.furnitureListData[index + 1]

	if not data or data.tIndex ~= 1 then
		return
	end

	local panelId = gPanelId.GALLERY_FURNITURE_PREVIEW_PANEL

	if not panelId then
		print_warn("[Gallery] GALLERY_FURNITURE_PREVIEW_PANEL 未注册，暂无法打开家具预览")

		return
	end

	gPanelManager:CheckShow(panelId, {
		furnitureId = data.furnitureId,
		furnitureListData = self.furnitureListData
	})
end

M.OnGetContentListTIndex = function(self, index)
	local luaIndex = index + 1

	if luaIndex < #self.furnitureListData then
		return self.furnitureListData[luaIndex].tIndex or 0
	else
		return 1
	end
end

M.InitSelectorList = function(self)
	local sorter = self.SubGroup.FilterSorterComponentStore

	if not sorter then
		return
	end

	self.selectorList = {
		{
			["Y\\xa7\\xb6\\xa3\\xb3"] = 553,
			id = self.SortTypeIdMap.Quality
		}
	}

	sorter.SetData(sorter, {
		["\\x96',{\\x98O\\xdd>\\xa4\\xbe"] = false,
		onSortChanged = self.CreateAction(self, "OnSortChanged"),
		sortList = self.selectorList
	})
	sorter.SelectOption(sorter, 0, true)

	sorter.bindData.showSorter = 0
end

M.OnSortChanged = function(self, _sortId, _isAscending)
	if self.currentSubType then
		self:RefreshContentList()
		self.bindData.contentList:GoToPos(Vector2.zero, true)
	end
end

M.FilterFurnitureItems = function(self, itemList)
	return itemList
end

M.SortFurnitureItems = function(self, itemList)
	if table.isNilOrEmpty(itemList) then
		return
	end

	local sorter = self.SubGroup.FilterSorterComponentStore
	local selectedSortItem = sorter and sorter:GetSelectedItem()
	local isAscending = sorter and sorter.isAscending
	local sortTypeId = selectedSortItem and selectedSortItem.id or self.SortTypeIdMap.Quality

	table.sort(itemList, function (a, b)
		if sortTypeId ~= self.SortTypeIdMap.Quality then
			if a.isOwned == b.isOwned then
				return a.isOwned
			end

			if a.quality == b.quality then
				if isAscending then
					return a.quality <= b.quality
				else
					return b.quality <= a.quality
				end
			end
		end

		return a.furnitureId <= b.furnitureId
	end)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.contentBackBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.mainTypeList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderMainTypeListItem)
	self.bindData.mainTypeList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickMainTypeList)
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderContentListItem)
	self.bindData.contentList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickContentList)
	self.bindData.contentList.onGetTIndex = self.CreateAction(self, "OnGetContentListTIndex")
end

M.OnClickBackBtn = function(self)
	local topStore = self.GetTopTemplateStore(self)

	if topStore and topStore.IsSearchActive(topStore) then
		topStore.ClearSearchText(topStore)

		return
	end

	gPanelManager:Close(self.m_Id)
end
