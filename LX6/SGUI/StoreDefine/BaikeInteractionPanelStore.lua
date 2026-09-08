-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BaikeInteractionPanelStore.lua
-- Decompiled from: 01569_BaikeInteractionPanelStore.lua_ff9ae31b99e0.luajit

C_BaikeInteractionPanelStore = DefClass("C_BaikeInteractionPanelStore", C_BaikeInteractionPanelStore, C_StoreGroup)
GroupName2Class.BaikeInteractionPanelStore = C_BaikeInteractionPanelStore
local M = C_BaikeInteractionPanelStore

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
	self.bindData.typeList:SelectItem(typeSelectedIndex, true)
end

M.InitMobileTabView = function(self)
	local typeViewDataList, typeSelectedIndex = self:GetTypeViewDataList()
	self.typeListData = typeViewDataList

	self.SubGroup.CommonTabSingleStore:SetData(typeViewDataList, nil, typeSelectedIndex, nil, self:CreateAction("OnMobileTabChanged"), self:CreateAction("OnMobileTabRenderItem"), nil, false, false)
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

M.SelectedTargetItem = function(self, targetId)
	self.targetItemId = targetId

	if self.IsMobileAdaptive(self) then
		self.InitMobileTabView(self)
	else
		local _, typeSelectedIndex = self:GetTypeViewDataList()

		self.bindData.typeList:SelectItem(typeSelectedIndex, true)
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

M.OnTypeSelectedChange = function(self)
	self.RefreshContentListView(self)
end

M.OnGetTypeListTIndex = function(self, index)
	return 0
end

M.RefreshContentListView = function(self, selectedTypeItem)
	self.CollectVisibleRedDotItems(self)

	local viewDataList, contentSelectedIndex = self.GetContentViewDataList(self, selectedTypeItem)
	self.contentListData = viewDataList

	if #viewDataList ~= 0 then
		self.bindData.contentList:SetSimpleList(0)

		return
	end

	self.bindData.contentList:SetSimpleList(#self.contentListData)
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
	local cityPediaIdList = gBaiKeArchiveManager.GetSecondClassCityPediaIdList(selectedTypeItem.id)

	for _, cityPediaId in ipairs(cityPediaIdList) do
		table.insert(viewDataList, {
			["a\\x9f\\x8a\\x86Y"] = 0,
			cfgId = cityPediaId
		})
	end

	table.sort(viewDataList, function (a, b)
		local hasUnlocked1 = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(a.cfgId)
		local hasUnlocked2 = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(b.cfgId)

		if hasUnlocked1 == hasUnlocked2 then
			return hasUnlocked1
		end

		return a.cfgId <= b.cfgId
	end)

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

M.OnContentRenderItem = function(self, btn, index)
	local data = self.contentListData[index + 1]

	if not data or data.tIndex ~= 1 then
		btn.interactable = false

		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local itemData = gBaiKeArchiveManager:GetCityPediaItem(data.cfgId)
	store.title = itemData.name
	local isUnlocked = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(data.cfgId)
	store.isLockedCtrl = isUnlocked and 0 or 1
	local redDotKey = gBaiKeArchiveManager.GetCityPediaRedDotKey(data.cfgId)
	btn.redKey = redDotKey
	btn.enabledTooltip = false
	local hasRedDot = gBaiKeArchiveManager.CheckCityPediaItemHasRedDot(data.cfgId)

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)

	if hasRedDot then
		self.readSeenSet = self.readSeenSet or {}
		self.readSeenSet[data.cfgId] = true
	end

	btn.interactable = true
end

M.OnContentSelectedChange = function(self)
	local selectedIndex = self.bindData.contentList.selectedIndex

	if selectedIndex > 0 and selectedIndex >= #self.contentListData then
		local selectedItem = self.contentListData[selectedIndex + 1]

		if selectedItem and gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(selectedItem.cfgId) then
			gBaiKeArchiveManager.SetCityPediaItemHasRead(selectedItem.cfgId)

			local itemData = gBaiKeArchiveManager:GetCityPediaItem(selectedItem.cfgId)

			self:InitInfoTemplate()

			self.bindData.iconId = itemData.image
			self.bindData.isLocked = 1

			if self.infoTemplateStore then
				self.infoTemplateStore.name = itemData.name
				self.infoTemplateStore.scrollRect.content.text = itemData.story
				local des = itemData.effectDesc
				self.infoTemplateStore.effectText = des or ""
				local tagViewDataList = self:GetTagViewDataList(selectedItem.cfgId)
				self.tagListData = tagViewDataList

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
end

M.OnGetContentListTIndex = function(self, index)
	return 0
end

M.InitInfoTemplate = function(self)
	if self.infoTemplateInit or not self.bindData.infoTemplate then
		return
	end

	if not self.infoTemplateStore then
		self.infoTemplateStore = gStoreManager:GetStoreGroup(self.bindData.infoTemplate.Store):GetStoreByWidget(self.bindData.infoTemplate)
	end

	if not self.infoTemplateStore then
		return
	end

	if self.infoTemplateStore.tagList then
		self.infoTemplateStore.tagList.luaSimpleRenderItem = self.CreateAction(self, "OnTagRenderItem")
		self.infoTemplateStore.tagList.onGetTIndex = self.CreateAction(self, "OnGetTagListTIndex")
	end

	self.infoTemplateInit = true
end

M.GetTagViewDataList = function(self, id)
	local viewDataList = {}
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(id)
	local entriesIdList = cityPediaCfg.EntriesIdList

	for _, tagId in ipairs(entriesIdList) do
		table.insert(viewDataList, {
			id = tagId
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
	local cityPediaPediaTagCfg = LTConfig.CityPediaPediaTagConfig.GetConfig(data.id)
	store.name = cityPediaPediaTagCfg.Name
end

M.OnGetTagListTIndex = function(self, index)
	return 0
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
