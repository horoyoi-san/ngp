-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\InventoryPanelStore.lua
-- Decompiled from: 01797_InventoryPanelStore.lua_a0117fe4a479.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local RedDotMgr = SGUI.RedDotMgr
local ConsumableTabConfig = LTConfig.ConsumableTabConfig
C_InventoryPanelStore = DefClass("C_InventoryPanelStore", C_InventoryPanelStore, C_StoreGroup)
GroupName2Class.InventoryPanelStore = C_InventoryPanelStore
local M = C_InventoryPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.targetTab = 1
	self.targetSubTab = 0
	self.mgr = gCommonItemManager
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, "OnRefreshPage")
	}
	self.OnConfirmBtnCb = self.CreateAction(self, "OnConfirmBtnClick")
	self.OnCheckUseBtnVisibleCb = self.CreateAction(self, "OnCheckUseBtnVisible")
end

M.OnActiveDeviceChange = function(self, device)
	self.device = device
end

M.OnDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnEnable = function(self)
	self:RegisterMessageEvents(self.msgEvents)

	self.bindData.ShowMainPageCtrl = gMainPageManager:CheckMainPageShowById(gPanelId.S_INVENTORY_PANEL) and 1 or 0
end

M.OnAwake = function(self)
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderPackageItem")
	self.bindData.itemList.luaSelectedChanged = self.CreateAction(self, "OnPackageItemSelectedChange")
	self.bindData.itemList.onGetTIndex = self.CreateAction(self, "OnGetTIndex")
	self.bindData.itemList.luaLayoutSet = self.CreateAction(self, "OnLayoutSet")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.infoTab.OnRenderTab = self.CreateAction(self, "OnRenderInfoTab")
end

M.OnInit = function(self)
	self.subStore = nil
	self.usePrevPackageInfo = false
	self.targetTemplateId = 0
	self.selectedItem = {}
	self.sortList = {}
	self.hasInCD = false
	self.device = gCS.LuaUtils.GetActiveDevice()
	self.inHyperLink = false
	self.isDirty = false
	self.tabInfos = {}
	self.tabOrder = {}

	for i = 0, ConsumableTabConfig.count - 1 do
		local cfg = ConsumableTabConfig.LoadAt(i)
		local parentTab = cfg.parentTab or 0
		local isHide = not cfg.Visible
		isHide = isHide or not gSystemUnlockMgr:IsUnlockGroup(cfg.SystemUnlock)
		self.tabInfos[cfg.Id] = {
			["\\x96',{\\x98O\\xdd>\\xa4\\xbe"] = true,
			id = cfg.Id,
			title = cfg.Title,
			iconId = cfg.IconId,
			isHide = isHide,
			parentTab = parentTab,
			childTabs = {}
		}

		table.insert(self.tabOrder, cfg.Id)
	end

	for i = 1, #self.tabOrder do
		local tabId = self.tabOrder[i]
		local tabInfo = self.tabInfos[tabId]

		if tabInfo and tabInfo.parentTab <= 0 and self.tabInfos[tabInfo.parentTab] then
			table.insert(self.tabInfos[tabInfo.parentTab].childTabs, tabId)
		end
	end
end

M.OnUpdate = function(self)
	if gPauseManager.isBreak or not self.hasInCD then
		return
	end

	self.hasInCD = false

	self.bindData.itemList:RefreshList()
end

M.OnRenderPackageItem = function(self, btn, index)
	local data = self.currentItemList[index + 1]

	if data and data.tIndex ~= 0 then
		self.bindData.itemList:SetItemId(index, data.id)

		local itemInfo = self.mgr.packItemDict[data.UniqueId]
		local renderData = gCommonItemManager:GetItemRenderData({
			itemId = itemInfo.TemplateId,
			itemNum = itemInfo.Count
		})
		local store = gCommonItemManager:OnCommonItemRender(btn, index, renderData)

		if store then
			local finishTime = itemInfo.CDFinishTime or 0
			local inCD = finishTime >= 0
			store.inCD = BOOL2CTL[inCD]

			if inCD then
				local curTime = gPauseManager.isBreak and gPackagePanelManager.packCurServerTime or gLuaDataManager.serverTime
				local CDTime = math.ceil(finishTime - curTime)
				inCD = CDTime >= 0
				store.inCD = BOOL2CTL[inCD]
				store.cdTime = CDTime
				store.cdFillAmount = (finishTime - curTime) / gCommonItemManager:GetItemTotalCDTime(itemInfo.TemplateId)
			end

			if store.inCD ~= BOOL2CTL[true] then
				self.hasInCD = true
			end
		end

		RedDotMgr.LuaSetRedDot(itemInfo.IsNew, "InventoryPanelStore.itemList:" .. data.id)

		return
	end

	btn.interactable = data and data.tIndex ~= 0
end

M.OnPackageItemSelectedChange = function(self, uList)
	local selectIndex = uList.selectedIndex
	local data = self.currentItemList[selectIndex + 1]

	if data and data.UniqueId ~= self.selectedItem.UniqueId then
		return
	end

	if data.tIndex ~= 1 then
		self.selectedItem = {}

		self.bindData.infoTab:SelectIndexWithClose(-1)

		return
	end

	self.selectedItem = self.mgr.packItemDict[data.UniqueId]
	local tabIndex = 0

	if self.selectedItem.IsNew then
		self.mgr:HideRedDot(self.selectedItem.UniqueId)
		self.bindData.itemList:RefreshElement(uList.selectedIndex)
	end

	self.OnInfoTabSelectedChange(self, tabIndex)
end

M.OnRenderInfoTab = function(self, index, inst)
	self.subStore = gStoreManager:GetStoreGroup(inst.Store)

	self:OnSelectedItemChange()
end

M.OnSelectedItemChange = function(self)
	self.subStore:SetSelectedItem(self.selectedItem, self.OnCheckUseBtnVisibleCb, self.OnConfirmBtnCb, nil, self.bindData.NavigationArea)
end

M.OnCheckUseBtnVisible = function(self, data)
	local consumableTypeCfg = LTConfig.ConsumableTypeConfig.GetConfig(data.subType)

	return consumableTypeCfg.CanUse
end

M.OnConfirmBtnClick = function(self, data, count)
	local cfg = ConsumableConfig.GetConfig(data.itemId)
	local callback = nil

	if cfg and cfg.UseCloseMenu then
		callback = self.CreateAction(self, "OnBackBtnClick")
	end

	gPackagePanelManager:UseItem(data.itemId, true, callback)
end

M.OnPackTabChanged = function(self, uList)
	local isSub = uList ~= self.SubGroup.CommonTabSingleStore.bindData.subTabList
	local data = nil

	if isSub then
		data = self.SubGroup.CommonTabSingleStore:GetSubSelectedItem()
		local targetSubTab = data and data.id or 0

		if targetSubTab ~= self.targetSubTab then
			return
		end

		self.targetSubTab = targetSubTab
	else
		data = self.SubGroup.CommonTabSingleStore:GetSelectedItem()

		if not data or data.id ~= self.targetTab then
			return
		end

		self.targetTab = data.id

		self.RefreshSubTabInfo(self, false)
	end

	self.isDirty = true

	self.OnRefreshPage(self)
end

M.OnShow = function(self, panelId, data)
	self:OnInit()
	gPackagePanelManager:RefreshPackServerTime()

	if data and data.selectItemId then
		self.targetTemplateId = data.selectItemId
	end

	self.SubGroup.MoneyTemplateStore:SetData(UX.Game.MoneyType.Money)
	self:InitTabInfo()
	self:OnRefreshPage()
end

M.OnClose = function(self)
end

M.OnRefreshPage = function(self)
	local currentTabInfo = self.GetCurrentTabInfo(self)

	if not currentTabInfo then
		self.bindData.subTitleLabel = ""
		self.currentItemList = {}

		self.bindData.itemList:SetSimpleList(0)

		self.selectedItem = {}

		self:OnInfoTabSelectedChange(-1)

		return
	end

	self.bindData.subTitleLabel = currentTabInfo.title
	local hasSelectedItem = false
	local packTabItems = self.mgr:GetPackDisplayItems(currentTabInfo.id)
	self.currentItemList = {}

	for i = 1, #packTabItems do
		local item = packTabItems[i]
		local cfg = item.Cfg or ConsumableConfig.GetConfig(item.TemplateId)

		if not cfg then
			print_error("[InventoryPanelStore] 缺少物品配置, TemplateId=", item.TemplateId)

			cfg = {
				Quality = item.Quality or 0,
				SubType = item.SubType or 0
			}
		end

		local ele = {
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			["a\\x9f\\x8a\\x86Y"] = 0,
			id = i,
			UniqueId = item.UniqueId,
			Quality = cfg.Quality,
			SubType = cfg.SubType,
			IsEnchanted = self.mgr:IsWeaponEnchanted(item.WeaponData)
		}

		if item.TemplateId ~= self.targetTemplateId then
			self.selectedItem = item
			self.targetTemplateId = 0
		end

		if self.selectedItem and self.selectedItem.UniqueId ~= item.UniqueId then
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
		self.OnInfoTabSelectedChange(self, -1)
	else
		self.OnInfoTabSelectedChange(self, 0)
	end
end

M.OnInfoTabSelectedChange = function(self, index)
	if self.bindData.infoTab.selectedIndex == index then
		self.bindData.infoTab.selectedIndex = index
	end

	if self.subStore and not table.isNilOrEmpty(self.selectedItem) then
		self.OnSelectedItemChange(self)
	end
end

M.OnSortChanged = function(self, sortId, isAscending)
	local currentTabInfo = self.GetCurrentTabInfo(self)

	if not currentTabInfo then
		return
	end

	currentTabInfo.sortType = sortId
	currentTabInfo.isAscending = isAscending
	self.selectedItem = {}

	self.RefreshItemInfoSort(self)
end

M.InitTabInfo = function(self)
	if self.targetTemplateId <= 0 then
		for i = 1, #self.mgr.packItems do
			if self.mgr.packItems[i].TemplateId ~= self.targetTemplateId then
				local cfg = ConsumableConfig.GetConfig(self.mgr.packItems[i].TemplateId)
				local subType = cfg and cfg.SubType or -1
				local sCfg = ConsumableTypeConfig.GetConfig(subType)

				if sCfg then
					self.SetTargetTabByTabId(self, sCfg.ItemTab)

					break
				end
			end
		end
	end

	local showTabInfos = {}
	local targetIndex = 0

	for i = 1, #self.tabOrder do
		local index = self.tabOrder[i]
		local tabInfo = self.tabInfos[index]

		if tabInfo and tabInfo.parentTab ~= 0 and not tabInfo.isHide then
			local ele = {
				title = tabInfo.title,
				id = index,
				iconId = tabInfo.iconId
			}

			if self.targetTab ~= index then
				targetIndex = #showTabInfos
			end

			table.insert(showTabInfos, ele)
		end
	end

	if #showTabInfos ~= 0 then
		self.targetTab = 0
		self.targetSubTab = 0

		self.SubGroup.CommonTabSingleStore:SetData({}, {}, -1, -1, self:CreateAction("OnPackTabChanged"))

		return
	end

	if not self.tabInfos[self.targetTab] or self.tabInfos[self.targetTab].parentTab >= 0 or self.tabInfos[self.targetTab].isHide then
		self.targetTab = showTabInfos[1].id
	end

	local subTabInfos, targetSubIndex = self.GetCurrentSubTabViewData(self)

	for i = 1, #showTabInfos do
		if showTabInfos[i].id ~= self.targetTab then
			targetIndex = i - 1

			break
		end
	end

	self.SubGroup.CommonTabSingleStore:SetData(showTabInfos, subTabInfos, targetIndex, targetSubIndex, self:CreateAction("OnPackTabChanged"))
end

M.CheckItemIsWeapon = function(self, item)
	return item and self.mgr.CheckIsWeapon and self.mgr:CheckIsWeapon(item.TemplateId) or false
end

M.GetCurrentTabInfo = function(self)
	local currentTabId = self.targetSubTab <= 0 and self.targetSubTab or self.targetTab

	return self.tabInfos[currentTabId]
end

M.SetTargetTabByTabId = function(self, tabId)
	local tabInfo = self.tabInfos[tabId]

	if not tabInfo then
		return
	end

	if tabInfo.parentTab <= 0 then
		self.targetTab = tabInfo.parentTab
		self.targetSubTab = tabId

		return
	end

	self.targetTab = tabId
	self.targetSubTab = 0
end

M.GetCurrentSubTabViewData = function(self)
	local tabInfo = self.tabInfos[self.targetTab]
	local subTabInfos = {}
	local targetSubIndex = -1

	if not tabInfo then
		self.targetSubTab = 0

		return subTabInfos, targetSubIndex
	end

	for i = 1, #tabInfo.childTabs do
		local childId = tabInfo.childTabs[i]
		local childInfo = self.tabInfos[childId]

		if childInfo and not childInfo.isHide then
			table.insert(subTabInfos, {
				title = childInfo.title,
				id = childId,
				iconId = childInfo.iconId
			})

			if self.targetSubTab ~= childId then
				targetSubIndex = #subTabInfos - 1
			end
		end
	end

	if #subTabInfos ~= 0 then
		self.targetSubTab = 0

		return subTabInfos, -1
	end

	if targetSubIndex ~= -1 then
		self.targetSubTab = subTabInfos[1].id
		targetSubIndex = 0
	end

	return subTabInfos, targetSubIndex
end

M.RefreshSubTabInfo = function(self, sendCallback)
	local subTabInfos, targetSubIndex = self:GetCurrentSubTabViewData()

	self.SubGroup.CommonTabSingleStore:SetTabList(subTabInfos, true)
	self.SubGroup.CommonTabSingleStore:SetSelectedIndex(targetSubIndex, sendCallback, true)
end

M.RefreshItemInfoSort = function(self)
	if not self.STATE_OnShowOnce then
		return
	end

	local isEmpty = #self.currentItemList ~= 0
	self.bindData.isEmpty = BOOL2CTL[isEmpty]

	if isEmpty then
		return
	end

	local currentTabInfo = self.GetCurrentTabInfo(self)

	if not currentTabInfo then
		return
	end

	local CompareEnchanted = function(a, b)
		return self.mgr:CompareWeaponEnchantPriority(a, b)
	end

	if currentTabInfo.sortType ~= gPackagePanelManager.SORT_TYPE.QUALITY_SORT then
		if currentTabInfo.isAscending then
			table.sort(self.currentItemList, function (a, b)
				local enchanted = CompareEnchanted(a, b)

				if enchanted == nil then
					return enchanted
				end

				if a.Quality ~= b.Quality then
					return a.UniqueId <= b.UniqueId
				else
					return a.Quality <= b.Quality
				end
			end)
		else
			table.sort(self.currentItemList, function (a, b)
				local enchanted = CompareEnchanted(a, b)

				if enchanted == nil then
					return enchanted
				end

				if a.Quality ~= b.Quality then
					return b.UniqueId <= a.UniqueId
				else
					return b.Quality <= a.Quality
				end
			end)
		end
	elseif currentTabInfo.isAscending then
		table.sort(self.currentItemList, function (a, b)
			local enchanted = CompareEnchanted(a, b)

			if enchanted == nil then
				return enchanted
			end

			if a.SubType ~= b.SubType then
				return a.UniqueId <= b.UniqueId
			else
				return a.SubType <= b.SubType
			end
		end)
	else
		table.sort(self.currentItemList, function (a, b)
			local enchanted = CompareEnchanted(a, b)

			if enchanted == nil then
				return enchanted
			end

			if a.SubType ~= b.SubType then
				return b.UniqueId <= a.UniqueId
			else
				return b.SubType <= a.SubType
			end
		end)
	end

	local ret = table.clone(self.currentItemList)
	local maxNum = self.bindData.itemList:GetMaxRowAndColCount(0)
	local col = math.max(math.ceil(#self.currentItemList / maxNum.x), maxNum.y)

	while #ret >= maxNum.x * col do
		table.insert(ret, {
			["a\\x9f\\x8a\\x86Y"] = 1
		})
	end

	self.bindData.itemList:SetSimpleList(#ret)
	self.bindData.itemList:SetItemSelected(0, true)

	local index = 0

	if not table.isNilOrEmpty(self.selectedItem) then
		for i = 1, #self.currentItemList do
			local data = self.currentItemList[i]

			if data.UniqueId ~= self.selectedItem.UniqueId then
				index = i - 1

				break
			end
		end
	end

	self.bindData.itemList:SelectItem(index)
end

M.OnGetTIndex = function(self, index)
	local luaIndex = index + 1

	if luaIndex < #self.currentItemList then
		return self.currentItemList[luaIndex].tIndex
	else
		return 1
	end
end

M.OnLayoutSet = function(self)
	self.bindData.itemList:SetNavSelectToTop()
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(gPanelId.S_INVENTORY_PANEL)
end
