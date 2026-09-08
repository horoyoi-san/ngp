-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BaikeMoviePanelStore.lua
-- Decompiled from: 01574_BaikeMoviePanelStore.lua_1cfe35765216.luajit

C_BaikeMoviePanelStore = DefClass("C_BaikeMoviePanelStore", C_BaikeMoviePanelStore, C_StoreGroup)
GroupName2Class.BaikeMoviePanelStore = C_BaikeMoviePanelStore
local M = C_BaikeMoviePanelStore

M.ctor = function(self)
	self.contentListData = {}
	self.tagListData = {}
	self.infoTemplateStore = nil
	self.infoTemplateInit = false
	self.readSeenSet = {}
end

M.OnAwake = function(self)
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction("OnContentRenderItem")
	self.bindData.contentList.luaSelectedChanged = self:CreateAction("OnContentSelectedChange")
	self.bindData.contentList.onGetTIndex = self:CreateAction("OnGetContentListTIndex")

	self.bindData.contentList:RegisterToScrollEndEvent(self:CreateAction("CollectVisibleRedDotItems"))
	self:InitMessages()
end

M.ShowPanel = function(self, args)
	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.targetFirstCategoryId = args.targetFirstCategoryId
	self.targetItemId = args.targetItemId
	self.infoTemplateInit = false
	self.infoTemplateStore = nil
end

M.InitView = function(self)
	local viewDataList, contentSelectedIndex = self:GetContentViewDataList()
	self.contentListData = viewDataList
	local maxNum = self.bindData.contentList:GetMaxRowAndColCount(0)
	local visibleRow = math.max(maxNum.y - 1, 0)
	local col = math.max(math.ceil(#self.contentListData / maxNum.x), visibleRow)
	local totalCount = maxNum.x * col

	self.bindData.contentList:SetSimpleList(totalCount)
	self.bindData.contentList:SelectItem(contentSelectedIndex, true)

	self.targetItemId = self.targetItemId and self.bindData.contentList:GoToIndex(contentSelectedIndex, true)
end

M.SelectedTargetItem = function(self, targetId)
	self.targetItemId = targetId
	local _, contentSelectedIndex = self:GetContentViewDataList()

	self.bindData.contentList:SelectItem(contentSelectedIndex, true)
	self.bindData.contentList:SetNavSelectToSelect(true)
end

M.GetContentViewDataList = function(self)
	local selectedIndex = 0
	local viewDataList = {}
	local cityPediaIdList = gBaiKeArchiveManager.GetFirstClassCityPediaIdList(self.targetFirstCategoryId)

	for _, cityPediaId in ipairs(cityPediaIdList) do
		local hasUnlocked = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(cityPediaId)

		table.insert(viewDataList, {
			["a\\x9f\\x8a\\x86Y"] = 0,
			cfgId = cityPediaId,
			hasUnlocked = hasUnlocked
		})
	end

	table.sort(viewDataList, function (a, b)
		if a.hasUnlocked == b.hasUnlocked then
			return a.hasUnlocked
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

M.OnContentRenderItem = function(self, btn, index)
	local data = self.contentListData[index + 1]

	if not data then
		btn.interactable = false

		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local itemData = gBaiKeArchiveManager:GetCityPediaItem(data.cfgId)
	store.iconId = itemData.iconId
	store.isLockedCtrl = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(data.cfgId) and 0 or 1
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
			self.bindData.layoutCtrl = itemData.movieImageType ~= 1 and 0 or 1

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
	local luaIndex = index + 1

	if luaIndex < #self.contentListData then
		return self.contentListData[luaIndex].tIndex or 0
	end

	return 1
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
