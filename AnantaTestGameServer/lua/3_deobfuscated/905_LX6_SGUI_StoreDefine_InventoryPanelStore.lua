local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local ImageConfig = LTConfig.SguiImageConfig
local RedDotMgr = SGUI.RedDotMgr
C_InventoryPanelStore = DefClass("C_InventoryPanelStore", C_InventoryPanelStore, C_StoreGroup)
GroupName2Class.InventoryPanelStore = C_InventoryPanelStore
local M = C_InventoryPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:ctor()
	self.targetTab = 1
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self:CreateAction("OnRefreshPage")
	}
	self.OnConfirmBtnCb = self:CreateAction("OnConfirmBtnClick")
	self.OnCheckUseBtnVisibleCb = self:CreateAction("OnCheckUseBtnVisible")
end

function M:OnActiveDeviceChange(device)
	self.device = device
end

function M:OnDisable()
	self:ClearMessageEvents()
end

function M:OnEnable()
	self:RegisterMessageEvents(self.msgEvents)

	self.bindData.ShowMainPageCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.S_INVENTORY_PANEL) and 1 or 0
end

function M:OnAwake()
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction("OnRenderPackageItem")
	self.bindData.itemList.luaSelectedChanged = self:CreateAction("OnPackageItemSelectedChange")
	self.bindData.itemList.onGetTIndex = self:CreateAction("OnGetTIndex")
	self.bindData.itemList.luaLayoutSet = self:CreateAction("OnLayoutSet")
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.infoTab.OnRenderTab = self:CreateAction("OnRenderInfoTab")
	self.tabInfos = {
		{
			isAscending = true,
			name = TextScriptTextConfig.GetConfig(89900253).Text,
			iconId = ImageConfig.PackageMatrixIcon,
			SubType = {
				ConsumableTypeConfig.Stone
			},
			isHide = function ()
				return true
			end
		},
		{
			isAscending = true,
			name = TextScriptTextConfig.GetConfig(89900252).Text,
			iconId = ImageConfig.PackageWeaponIcon,
			SubType = {
				ConsumableTypeConfig.Weapon
			},
			isHide = function ()
				return true
			end
		},
		{
			isAscending = true,
			name = TextScriptTextConfig.GetConfig(89900255).Text,
			isHide = function ()
				return true
			end
		},
		{
			isAscending = true,
			name = TextScriptTextConfig.GetConfig(89900123).Text,
			iconId = ImageConfig.PackageGrowthIcon,
			SubType = {},
			isHide = function ()
				return not gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.PackageMaterialsTabUnlock)
			end
		},
		{
			isAscending = true,
			name = TextScriptTextConfig.GetConfig(89900124).Text,
			iconId = ImageConfig.PackageConsumableIcon,
			SubType = {}
		},
		{
			isAscending = true,
			name = TextScriptTextConfig.GetConfig(89900125).Text,
			iconId = ImageConfig.PackagePreciousIcon,
			SubType = {}
		},
		{
			isAscending = true,
			name = TextScriptTextConfig.GetConfig(89900126).Text,
			iconId = ImageConfig.PackageTaskItemIcon,
			SubType = {}
		},
		{
			isAscending = true,
			name = TextScriptTextConfig.GetConfig(89901080).Text,
			iconId = ImageConfig.PackageMatrixIcon,
			SubType = {}
		}
	}

	self:OnInit()
end

function M:OnInit()
	self.subStore = nil
	self.usePrevPackageInfo = false
	self.targetTemplateId = 0
	self.selectedItem = {}
	self.sortList = {}
	self.hasInCD = false
	self.device = gCS.LuaUtils.GetActiveDevice()
	self.inHyperLink = false
	self.isDirty = false
end

function M:OnUpdate()
	if gPauseManager.isBreak or not self.hasInCD then
		return
	end

	self.hasInCD = false

	self.bindData.itemList:RefreshList()
end

function M:OnRenderPackageItem(btn, index)
	local data = self.currentItemList[index + 1]

	if data and data.tIndex == 0 then
		self.bindData.itemList:SetItemId(index, data.id)

		local itemInfo = gPlayerItemManager.packItemDict[data.UniqueId]
		local renderData = gCommonItemManager:GetItemRenderData({
			itemId = itemInfo.TemplateId,
			itemNum = itemInfo.Count
		})
		local store = gCommonItemManager:OnCommonItemRender(btn, index, renderData)

		if store then
			local finishTime = itemInfo.CDFinishTime or 0
			local inCD = finishTime > 0
			store.inCD = BOOL2CTL[inCD]

			if inCD then
				local curTime = gPauseManager.isBreak and gPackagePanelManager.packCurServerTime or gLuaDataManager.serverTime
				local CDTime = math.ceil(finishTime - curTime)
				inCD = CDTime > 0
				store.inCD = BOOL2CTL[inCD]
				store.cdTime = CDTime
				store.cdFillAmount = (finishTime - curTime) / gCommonItemManager:GetItemTotalCDTime(itemInfo.TemplateId)
			end

			if store.inCD == BOOL2CTL[true] then
				self.hasInCD = true
			end
		end

		RedDotMgr.LuaSetRedDot(itemInfo.IsNew, "InventoryPanelStore.itemList:" .. data.id)

		return
	end

	btn.interactable = data and data.tIndex == 0
end

function M:OnPackageItemSelectedChange(uList)
	local selectIndex = uList.selectedIndex
	local data = self.currentItemList[selectIndex + 1]

	if data and data.UniqueId == self.selectedItem.UniqueId then
		return
	end

	if data.tIndex == 1 then
		self.selectedItem = {}

		self.bindData.infoTab:SelectIndexWithClose(-1)

		return
	end

	self.selectedItem = gPlayerItemManager.packItemDict[data.UniqueId]
	local tabIndex = self:CheckItemIsWeapon(self.selectedItem) and 1 or 0

	if self.selectedItem.IsNew then
		gPlayerItemManager:HideRedDot(self.selectedItem.UniqueId)
		self.bindData.itemList:RefreshElement(uList.selectedIndex)
	end

	self:OnInfoTabSelectedChange(tabIndex)
end

function M:OnRenderInfoTab(index, inst)
	self.subStore = gStoreManager:GetStoreGroup(inst.Store)

	self:OnSelectedItemChange()
end

function M:OnSelectedItemChange()
	self.subStore:SetSelectedItem(self.selectedItem, self.OnCheckUseBtnVisibleCb, self.OnConfirmBtnCb, nil, self.bindData.NavigationArea)
end

function M:OnCheckUseBtnVisible(data)
	local consumableTypeCfg = LTConfig.ConsumableTypeConfig.GetConfig(data.subType)

	return consumableTypeCfg.CanUse
end

function M:OnConfirmBtnClick(data, count)
	local cfg = ConsumableConfig.GetConfig(data.itemId)
	local callback = nil

	if cfg and cfg.UseCloseMenu then
		callback = self:CreateAction("OnBackBtnClick")
	end

	gPackagePanelManager:UseItem(data.itemId, true, callback)
end

function M:OnPackTabChanged(uList)
	local data = self.SubGroup.CommonTabSingleStore:GetSelectedItem()

	if data.id == self.targetTab then
		return
	end

	self.targetTab = data.id
	self.isDirty = true

	self:OnRefreshPage()
end

function M:OnShow(panelId, data)
	gPackagePanelManager:RefreshPackServerTime()

	if data and data.selectItemId then
		self.targetTemplateId = data.selectItemId
	end

	self.SubGroup.MoneyTemplateStore:SetData(UX.Game.MoneyType.Money)
	self:InitTabInfo()
	self:OnRefreshPage()
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnRefreshPage()
	self.bindData.subTitleLabel = self.SubGroup.CommonTabSingleStore:GetSelectedItem().title
	local currentTabInfo = self.tabInfos[self.targetTab]
	local hasSelectedItem = false
	local packTabItems = gPlayerItemManager.packTabItems[self.targetTab] or {}
	self.currentItemList = {}

	for i = 1, #packTabItems do
		local item = packTabItems[i]
		local cfg = ConsumableConfig.GetConfig(item.TemplateId)
		local ele = {
			selected = false,
			tIndex = 0,
			id = i,
			UniqueId = item.UniqueId,
			Quality = cfg.Quality,
			SubType = cfg.SubType
		}

		if item.TemplateId == self.targetTemplateId then
			self.selectedItem = item
			self.targetTemplateId = 0
		end

		if self.selectedItem and self.selectedItem.UniqueId == item.UniqueId then
			hasSelectedItem = true
		end

		table.insert(self.currentItemList, ele)
	end

	if not hasSelectedItem then
		self.selectedItem = {}
	end

	local sortType = currentTabInfo.sortType and currentTabInfo.sortType or gPackagePanelManager.SORT_TYPE.QUALITY_SORT
	currentTabInfo.sortType = sortType

	self.SubGroup.FilterSorterComponentStore:SetData({
		sortList = gPackagePanelManager:GetSortList(sortType),
		onSortChanged = self:CreateAction("OnSortChanged"),
		isAscending = currentTabInfo.isAscending
	})

	if self.isDirty then
		self.bindData.itemList:SetSimpleList(0)

		self.isDirty = false
	end

	FrameTimer.New(function ()
		self:RefreshItemInfoSort()
	end, 1):Start()

	if table.isNilOrEmpty(self.selectedItem) then
		self:OnInfoTabSelectedChange(-1)
	else
		self:OnInfoTabSelectedChange(self:CheckItemIsWeapon(self.selectedItem) and 1 or 0)
	end
end

function M:OnInfoTabSelectedChange(index)
	if self.bindData.infoTab.selectedIndex ~= index then
		self.bindData.infoTab.selectedIndex = index
	end

	if self.subStore and not table.isNilOrEmpty(self.selectedItem) then
		self:OnSelectedItemChange()
	end
end

function M:OnSortChanged(sortId, isAscending)
	local currentTabInfo = self.tabInfos[self.targetTab]
	currentTabInfo.sortType = sortId
	currentTabInfo.isAscending = isAscending
	self.selectedItem = {}

	self:RefreshItemInfoSort()
end

function M:InitTabInfo()
	local subType2Tab = {}
	local targetIndex = 0

	for i = 4, #gPlayerItemManager.subTypes do
		local subTypes = gPlayerItemManager.subTypes[i]
		local list = {}

		for j = 1, #subTypes do
			local type = ConsumableTypeConfig[subTypes[j]]

			if type then
				table.insert(list, type)

				subType2Tab[type] = i
			end
		end

		self.tabInfos[i].SubType = list
	end

	if self.targetTemplateId then
		for i = 1, #gPlayerItemManager.packItems do
			if gPlayerItemManager.packItems[i].TemplateId == self.targetTemplateId then
				local cfg = ConsumableConfig.GetConfig(gPlayerItemManager.packItems[i].TemplateId)
				local subType = cfg and cfg.SubType or -1

				if subType2Tab[subType] then
					self.targetTab = subType2Tab[subType]

					break
				end
			end
		end
	end

	local showTabInfos = {}

	for index, tabInfo in ipairs(self.tabInfos) do
		local isHide = tabInfo.isHide and tabInfo.isHide() or false

		if not isHide then
			local ele = {
				title = tabInfo.name,
				id = index
			}

			if self.targetTab == index then
				targetIndex = #showTabInfos
			end

			table.insert(showTabInfos, ele)
		end
	end

	self.SubGroup.CommonTabSingleStore:SetData(showTabInfos, nil, targetIndex, nil, self:CreateAction("OnPackTabChanged"))
end

function M:CheckItemIsWeapon(item)
	return false
end

function M:RefreshItemInfoSort()
	if not self.STATE_OnShowOnce then
		return
	end

	local isEmpty = #self.currentItemList == 0
	self.bindData.isEmpty = BOOL2CTL[isEmpty]

	if isEmpty then
		return
	end

	local currentTabInfo = self.tabInfos[self.targetTab]

	if currentTabInfo.sortType == gPackagePanelManager.SORT_TYPE.QUALITY_SORT then
		if currentTabInfo.isAscending then
			table.sort(self.currentItemList, function (a, b)
				if a.Quality == b.Quality then
					return a.UniqueId < b.UniqueId
				else
					return a.Quality < b.Quality
				end
			end)
		else
			table.sort(self.currentItemList, function (a, b)
				if a.Quality == b.Quality then
					return b.UniqueId < a.UniqueId
				else
					return b.Quality < a.Quality
				end
			end)
		end
	elseif currentTabInfo.isAscending then
		table.sort(self.currentItemList, function (a, b)
			if a.SubType == b.SubType then
				return a.UniqueId < b.UniqueId
			else
				return a.SubType < b.SubType
			end
		end)
	else
		table.sort(self.currentItemList, function (a, b)
			if a.SubType == b.SubType then
				return b.UniqueId < a.UniqueId
			else
				return b.SubType < a.SubType
			end
		end)
	end

	local ret = table.clone(self.currentItemList)
	local maxNum = self.bindData.itemList:GetMaxRowAndColCount(0)
	local col = math.max(math.ceil(#self.currentItemList / maxNum.x), maxNum.y)

	while #ret < maxNum.x * col do
		table.insert(ret, {
			tIndex = 1
		})
	end

	self.bindData.itemList:SetSimpleList(#ret)
	self.bindData.itemList:SetItemSelected(0, true)

	local index = 0

	if not table.isNilOrEmpty(self.selectedItem) then
		for i = 1, #self.currentItemList do
			local data = self.currentItemList[i]

			if data.UniqueId == self.selectedItem.UniqueId then
				index = i - 1

				break
			end
		end
	end

	self.bindData.itemList:SelectItem(index)
end

function M:OnGetTIndex(index)
	local luaIndex = index + 1

	if luaIndex <= #self.currentItemList then
		return self.currentItemList[luaIndex].tIndex
	else
		return 1
	end
end

function M:OnLayoutSet()
	self.bindData.itemList:SetNavSelectToTop()
end

function M:OnBackBtnClick()
	gPanelManager:Close(gPanelId.S_INVENTORY_PANEL)
end
