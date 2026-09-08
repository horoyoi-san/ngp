-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AnantarkovDexMainPanelStore.lua
-- Decompiled from: 01611_AnantarkovDexMainPanelStore.lua_0ea02656b6a1.luajit

C_AnantarkovDexMainPanelStore = DefClass("C_AnantarkovDexMainPanelStore", C_AnantarkovDexMainPanelStore, C_StoreGroup)
GroupName2Class.AnantarkovDexMainPanelStore = C_AnantarkovDexMainPanelStore
local M = C_AnantarkovDexMainPanelStore
local CollectionBookConfig = LTConfig.CollectionBookConfig
local CollectionConfig = LTConfig.CollectionBookCollectionConfig
local SpColorGroupConfig = LTConfig.CollectionBookSpColorGroupConfig
local BagConfig = LTConfig.ExtractionShooterBagConfig
local InventoryBagIds = {
	BagConfig.Inventory,
	BagConfig.Inventory2,
	BagConfig.Inventory3,
	BagConfig.Inventory4,
	BagConfig.Inventory5
}
local UseFakeServerData = false
local TestPrefix = "[TEST] "
local FakeServerOwnedCountList = {
	4,
	3,
	2,
	0
}
local TestCollectionItemIds = {
	36792042,
	36792043,
	36792041,
	36792039,
	36792040
}

M.DefineAllVariables = function(self)
	self.collectionViewDataList = {}
	self.obtainedCount = 0
	self.collectionScore = 0
	self.isUsingTestData = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.RegisterMessageEvents(self, self.msgEvents)
	self.RegisterDataSetEvents(self, self.dataSetEvents)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
	self.ClearDataSetEvents(self)

	self.collectionViewDataList = nil
	self.obtainedCount = nil
	self.collectionScore = nil
	self.isUsingTestData = nil
	self.dataSetEvents = nil
end

M.OnShow = function(self)
	self.bindData.showInfoCtrl = 0
	self.bindData.detailTitle = TestPrefix .. "收藏评分说明"
	self.bindData.detailDescription = TestPrefix .. "已获得的收藏品会计入收藏数量与收藏评分；点击已获得收藏品可查看详情并进行升级。"

	self.RefreshView(self)
end

M.RegisterWidget = function(self)
	self.bindData.closeButton.luaClick = self.CreateAction(self, "OnClickCloseButton")
	self.bindData.detailButton.luaClick = self.CreateAction(self, "OnClickDetailButton")
	self.bindData.detailCloseButton.luaClick = self.CreateAction(self, "OnClickDetailCloseButton")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderCollectionItem")
end

M.GenMessageEvents = function(self)
	local refreshAction = self.CreateAction(self, "RefreshView")
	self.msgEvents = {
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_UPDATE] = refreshAction,
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_REMOVE] = refreshAction,
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_CLEAR] = refreshAction,
		[gEventConstants.ON_EXTRACTION_SHOOTER_SORT_BAG_RESULT] = refreshAction,
		[gEventConstants.ON_COLLECTION_BOOK_TOTAL_SCORE_UPDATE] = refreshAction
	}
	self.dataSetEvents = {
		{
			gPlayerManager.infoMinor.bindData,
			"\n.\\xa0\\xf2>z1\\xa5<&\\x90!\\xb0\\x99ρ",
			refreshAction,
			nil,
			false
		}
	}
end

M.RefreshView = function(self)
	self:BuildCollectionViewData()
	self.bindData.list:SetSimpleList(#self.collectionViewDataList)

	local titleBindData = self.SubGroup.MainTitleTemplateStore.bindData

	titleBindData:Commit("obtainedCount", string.format("%d/%d", self.obtainedCount, #self.collectionViewDataList), COMMIT_FORCE)
	titleBindData:Commit("collectionScore", (self.isUsingTestData and TestPrefix or "") .. tostring(self.collectionScore), COMMIT_FORCE)
	self.SubGroup.MoneyTemplateStore:SetData(UX.Game.MoneyType.Money)
end

M.BuildCollectionViewData = function(self)
	local ownedItemData = UseFakeServerData and {} or self:BuildOwnedItemData()
	local obtainedCount = 0
	local collectionScore = 0
	local bookCfg = CollectionBookConfig.count <= 0 and CollectionBookConfig.LoadAt(0)
	local useTestData = not bookCfg or #bookCfg.CollectibleGroup ~= 0
	local collectionIds = useTestData and TestCollectionItemIds or bookCfg.CollectibleGroup
	local ownedList = {}
	local unownedList = {}

	for index, collectionId in ipairs(collectionIds) do
		local collectionCfg, itemId = nil

		if useTestData then
			itemId = collectionId
		else
			collectionCfg = CollectionConfig.GetConfig(collectionId)
			itemId = collectionCfg.InitialConsumable
		end

		local maxLevel = useTestData and 3 or #collectionCfg.LevelInclude
		local count = nil

		if UseFakeServerData then
			count = FakeServerOwnedCountList[(index - 1) % #FakeServerOwnedCountList + 1]
		elseif useTestData then
			count = math.max(3 - index, 0)
		else
			count = self.GetOwnedCollectionData(self, collectionCfg, ownedItemData)
		end

		if count <= 0 then
			obtainedCount = obtainedCount + 1

			if UseFakeServerData or useTestData then
				collectionScore = collectionScore + maxLevel * 100
			end
		end

		local itemName = gExtractionShooterManager.GetItemName(itemId)
		local data = {
			collectionId = collectionId,
			itemId = itemId,
			name = (UseFakeServerData or useTestData) and TestPrefix .. itemName or itemName,
			iconId = gExtractionShooterManager.GetItemIconId(itemId),
			quality = gExtractionShooterManager.GetItemQuality(itemId),
			price = gExtractionShooterManager.GetItemSystemPrice(itemId),
			count = count,
			isOwned = count >= 0,
			isTestData = useTestData,
			useFakeServerData = UseFakeServerData
		}
		local targetList = data.isOwned and ownedList or unownedList
		targetList[#targetList + 1] = data
	end

	for _, data in ipairs(unownedList) do
		ownedList[#ownedList + 1] = data
	end

	self.collectionViewDataList = ownedList
	self.obtainedCount = obtainedCount
	self.isUsingTestData = UseFakeServerData or useTestData
	self.collectionScore = self.isUsingTestData and collectionScore or gExtractionShooterManager.GetCollectionBookTotalScore()
end

M.GetOwnedCollectionData = function(self, collectionCfg, ownedItemData)
	local itemIds = {
		[collectionCfg.InitialConsumable] = true
	}

	if collectionCfg.SpColorGroup == 0 then
		local colorGroupCfg = SpColorGroupConfig.GetConfig(collectionCfg.SpColorGroup)

		for _, colorInfo in ipairs(colorGroupCfg.ColorInclude) do
			itemIds[colorInfo.id] = true
		end
	end

	local count = 0

	for itemId in pairs(itemIds) do
		count = count + (ownedItemData[itemId] or 0)
	end

	return count
end

M.BuildOwnedItemData = function(self)
	local ownedItemData = {}

	for _, bagId in ipairs(InventoryBagIds) do
		local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagId)
		slot8 = ipairs
		slot10 = bagInfo.ItemInfoList or {}

		for _, itemInfo in slot8(slot10) do
			ownedItemData[itemInfo.Id] = (ownedItemData[itemInfo.Id] or 0) + itemInfo.StackCount
		end
	end

	return ownedItemData
end

M.OnRenderCollectionItem = function(self, btn, index)
	local data = self.collectionViewDataList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.name = data.name
	store.price = data.price
	store.count = tostring(data.count)
	store.qualityCtrl = data.quality
	store.showLockCtrl = 0
	store.showSelectCtrl = 0
	store.showSelectboxCtrl = 0
	store.showUncollectedCtrl = data.isOwned and 0 or 1

	store:Commit("iconId", data.iconId, COMMIT_FORCE)

	if data.isOwned then
		btn.luaClick = function()
			self:OnClickCollectionItem(data)
		end
	else
		btn.luaClick = nil
	end
end

M.OnClickCollectionItem = function(self, data)
	gPanelManager:CheckShow(gPanelId.ANANTARKOV_DEX_INNER_PANEL, {
		collectionId = data.collectionId,
		itemId = data.itemId,
		count = data.count,
		isTestData = data.isTestData,
		useFakeServerData = data.useFakeServerData
	})
end

M.OnClickCloseButton = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickDetailButton = function(self)
	self.bindData.showInfoCtrl = 1
end

M.OnClickDetailCloseButton = function(self)
	self.bindData.showInfoCtrl = 0
end
