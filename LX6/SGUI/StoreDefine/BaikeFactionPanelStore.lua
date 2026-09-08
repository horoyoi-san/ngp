-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BaikeFactionPanelStore.lua
-- Decompiled from: 01566_BaikeFactionPanelStore.lua_ba11f294d301.luajit

C_BaikeFactionPanelStore = DefClass("C_BaikeFactionPanelStore", C_BaikeFactionPanelStore, C_StoreGroup)
GroupName2Class.BaikeFactionPanelStore = C_BaikeFactionPanelStore
local M = C_BaikeFactionPanelStore

M.ctor = function(self)
	self.secondClassListData = {}
	self.factionSubListData = {}
	self.tagListData = {}
	self.infoTemplateStore = nil
	self.infoTemplateInit = false
	self.readSeenSet = {}
end

M.OnAwake = function(self)
	if not self.panelCloseListenerRegistered then
		self.panelCloseAction = self:CreateAction("OnPanelClose")

		gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, self.panelCloseAction)

		self.panelCloseListenerRegistered = true
	end
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
	local countryList, countrySelectedIndex = self:GetCountryTabList()
	self.secondClassListData = countryList

	self.SubGroup.CommonTabSingleStore:SetData(countryList, nil, countrySelectedIndex, nil, self:CreateAction("OnFactionTabChanged"), self:CreateAction("OnFactionTabRenderItem"), nil, , false)

	self.SubGroup.CommonTabSingleStore.bindData.isSingle = 0
	local hasFactionCountryNum = self:GetHasFactionCountryNum(countryList)
	local showTab = hasFactionCountryNum >= 1
	self.bindData.tabCtrl = showTab and 1 or 0

	self:UpdateMainTabStepBtnVisible(showTab)
end

M.GetHasFactionCountryNum = function(self, countryList)
	local num = 0

	for _, viewData in ipairs(countryList) do
		local cityPediaIdList = gBaiKeArchiveManager.GetSecondClassCityPediaIdList(viewData.id)

		if cityPediaIdList and #cityPediaIdList <= 0 then
			num = num + 1
		end
	end

	return num
end

M.UpdateMainTabStepBtnVisible = function(self, visible)
	local tabBindData = self.SubGroup.CommonTabSingleStore.bindData

	if tabBindData.leftBtn then
		tabBindData.leftBtn.gameObject:SetActive(visible)
	end

	if tabBindData.rightBtn then
		tabBindData.rightBtn.gameObject:SetActive(visible)
	end

	if tabBindData.controllerKey_psl1 then
		tabBindData.controllerKey_psl1.gameObject:SetActive(visible)
	end

	if tabBindData.controllerKey_psr1 then
		tabBindData.controllerKey_psr1.gameObject:SetActive(visible)
	end
end

M.SelectedTargetItem = function(self, targetId)
	self.targetItemId = targetId

	self.InitView(self)
end

M.GetCountryTabList = function(self)
	local selectedIndex = 0
	local viewDataList = {}
	local count = LTConfig.CityPediaSecondClassConfig.count

	for i = 0, count - 1 do
		local cityPediaSecondClassCfg = LTConfig.CityPediaSecondClassConfig.LoadAt(i)

		if cityPediaSecondClassCfg.FatherId ~= self.targetFirstCategoryId and gBaiKeArchiveManager.CheckCityPediaSecondClassHasUnlocked(cityPediaSecondClassCfg.Id) then
			table.insert(viewDataList, {
				id = cityPediaSecondClassCfg.Id,
				title = cityPediaSecondClassCfg.Name
			})
		end
	end

	local targetSecondClassId = nil

	if self.targetItemId then
		local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(self.targetItemId)
		targetSecondClassId = cityPediaCfg and cityPediaCfg.Class
	end

	if targetSecondClassId then
		for index, viewData in ipairs(viewDataList) do
			if viewData.id ~= targetSecondClassId then
				selectedIndex = index - 1

				break
			end
		end
	end

	return viewDataList, selectedIndex
end

M.GetFactionSubList = function(self, secondClassId, targetFactionId)
	local selectedIndex = 0
	local viewDataList = {}

	if not secondClassId then
		return viewDataList, selectedIndex
	end

	local cityPediaIdList = gBaiKeArchiveManager.GetSecondClassCityPediaIdList(secondClassId)

	for _, cityPediaId in ipairs(cityPediaIdList) do
		local itemData = gBaiKeArchiveManager:GetCityPediaItem(cityPediaId)
		local isUnlocked = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(cityPediaId)

		table.insert(viewDataList, {
			id = cityPediaId,
			cfgId = cityPediaId,
			title = itemData and itemData.name or "",
			iconId = itemData and itemData.iconId or 0,
			hasUnlocked = isUnlocked
		})
	end

	table.sort(viewDataList, function (a, b)
		if a.hasUnlocked == b.hasUnlocked then
			return a.hasUnlocked
		end

		return a.cfgId <= b.cfgId
	end)

	if targetFactionId then
		for index, viewData in ipairs(viewDataList) do
			if viewData.cfgId ~= targetFactionId then
				selectedIndex = index - 1

				break
			end
		end
	end

	return viewDataList, selectedIndex
end

M.RefreshFactionSubList = function(self)
	local commonTabStore = self.SubGroup.CommonTabSingleStore
	local country = commonTabStore.GetSelectedItem(commonTabStore)

	if not country then
		return
	end

	local subList, subSelectedIndex = self.GetFactionSubList(self, country.id, self.targetItemId)
	self.factionSubListData = subList

	commonTabStore.SetTabList(commonTabStore, subList, true)

	if #subList <= 0 then
		local subTabList = commonTabStore.bindData.subTabList
		local isLastItem = subSelectedIndex < #subList - 1

		if subTabList then
			local goToIndex = isLastItem and subSelectedIndex or math.max(subSelectedIndex - 1, 0)

			subTabList:GoToIndex(goToIndex, true)
			subTabList:SetNavSelectToSelect(true)
		end

		commonTabStore.SetSelectedIndex(commonTabStore, subSelectedIndex, true, true)

		if isLastItem and subTabList then
			self.ScrollSubTabListToBottom(self)
		end
	else
		self.bindData.isLockedCtrl = 0
	end

	self.targetItemId = nil
end

M.ScrollSubTabListToBottom = function(self)
	slot1 = gCoroutineManager

	slot1:StartCoroutine(function ()
		for _ = 1, 5 do
			coroutine.yield(nil)

			local subTabList = self.SubGroup and self.SubGroup.CommonTabSingleStore and self.SubGroup.CommonTabSingleStore.bindData.subTabList

			if not subTabList or gCS.LuaUtils.IsNull(subTabList) then
				return
			end

			subTabList:GoToPos(Vector2.New(0, 99999), true)
		end
	end)
end

M.OnFactionTabRenderItem = function(self, btn, _, itemData, store, isSub)
	if not itemData then
		return
	end

	btn.enabledTooltip = false

	if not isSub then
		local redDotKey = gBaiKeArchiveManager.GetCityPediaSecondClassRedDotKey(itemData.id)
		btn.redKey = redDotKey
		local hasRedDot = gBaiKeArchiveManager.CheckCityPediaSecondClassHasRedDot(itemData.id)

		SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)

		return
	end

	if not store then
		return
	end

	store.isLockedCtrl = itemData.hasUnlocked and 0 or 1
	store.iconId = itemData.iconId or 0
	local cityPediaCfg = LTConfig.CityPediaConfig.GetConfig(itemData.cfgId)
	local bgColorStr = cityPediaCfg and cityPediaCfg.BackgroundColor or ""

	if bgColorStr == "" then
		store.color = Color.NewByStr(bgColorStr.gsub(bgColorStr, "^#", ""))
	end

	local redDotKey = gBaiKeArchiveManager.GetCityPediaRedDotKey(itemData.cfgId)
	btn.redKey = redDotKey
	local hasRedDot = gBaiKeArchiveManager.CheckCityPediaItemHasRedDot(itemData.cfgId)

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)

	if hasRedDot then
		self.readSeenSet = self.readSeenSet or {}
		self.readSeenSet[itemData.cfgId] = true
	end

	local subItemData = gBaiKeArchiveManager:GetCityPediaItem(itemData.cfgId)
	local isDisposition = subItemData and subItemData.isDisposition
	local isInfluence = subItemData and subItemData.isInfluence

	if isDisposition ~= isInfluence then
		store.isEnemyCtrl = 2
	elseif isInfluence then
		store.isEnemyCtrl = 1
	else
		store.isEnemyCtrl = 0
	end

	if store.factionTagList then
		local tagCtrlList = nil

		if isDisposition ~= isInfluence then
			tagCtrlList = {
				0,
				1
			}
		elseif isInfluence then
			tagCtrlList = {
				1
			}
		else
			tagCtrlList = {
				0
			}
		end

		store.factionTagList.luaSimpleRenderItem = function(tagBtn, tagIndex)
			local tagStore = gStoreManager:GetStoreGroup(tagBtn.Store):GetStoreByWidget(tagBtn)

			if tagStore then
				tagStore.ememyCtrl = tagCtrlList[tagIndex + 1] or 0
			end
		end

		store.factionTagList:SetSimpleList(#tagCtrlList)
	end
end

M.OnFactionTabChanged = function(self, _, isSub)
	if isSub then
		local selectedItem = self.SubGroup.CommonTabSingleStore:GetSubSelectedItem()

		if selectedItem then
			self.RefreshFactionInfo(self, selectedItem.cfgId)
		end
	else
		self.RefreshFactionSubList(self)
	end
end

M.RefreshFactionInfo = function(self, cityPediaId)
	local isUnlocked = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(cityPediaId)
	self.bindData.isLockedCtrl = isUnlocked and 1 or 0

	if not isUnlocked then
		self.bindData.unLockTip = gBaiKeArchiveManager.GetCityPediaUnlockTipText(cityPediaId)

		return
	end

	gBaiKeArchiveManager.SetCityPediaItemHasRead(cityPediaId)

	local itemData = gBaiKeArchiveManager:GetCityPediaItem(cityPediaId)
	self.bindData.iconId = itemData.image

	self:InitInfoTemplate()

	if self.infoTemplateStore then
		self.infoTemplateStore.name = itemData.name
		self.infoTemplateStore.scrollRect.content.text = itemData.story
		local des = itemData.effectDesc
		self.infoTemplateStore.effectText = des or ""
		self.infoTemplateStore.tagCtrl = 1
		local tagViewDataList = self:GetTagViewDataList(itemData)
		self.tagListData = tagViewDataList

		self.infoTemplateStore.tagList:SetSimpleList(#tagViewDataList)

		if self.bindData.tagNavigation then
			self.bindData.tagNavigation.gameObject:SetActive(#tagViewDataList >= 0)
		end
	end
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

M.GetTagViewDataList = function(self, itemData)
	local list = {}

	if itemData.isDisposition then
		table.insert(list, {
			["a\\x9f\\x8a\\x86Y"] = 1,
			itemData = itemData
		})
		table.insert(list, {
			["FIidW= 4"] = 0,
			["a\\x9f\\x8a\\x86Y"] = 2,
			itemData = itemData
		})
	end

	if itemData.isInfluence then
		table.insert(list, {
			["a\\x9f\\x8a\\x86Y"] = 3,
			itemData = itemData
		})
		table.insert(list, {
			["FIidW= 4"] = 1,
			["a\\x9f\\x8a\\x86Y"] = 2,
			itemData = itemData
		})
	end

	return list
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

	local itemData = data.itemData

	if data.tIndex ~= 1 then
		store.iconId = itemData.attitudeIconId or 0
		store.name = itemData.attitudeName or ""
		store.enemyCtrl = 0
	elseif data.tIndex ~= 2 then
		store.ememyCtrl = data.enemyCtrl or 0
	elseif data.tIndex ~= 3 then
		store.percentText = string.format("%d%%", itemData.influencePercent or 0)
	end
end

M.OnGetTagListTIndex = function(self, index)
	local data = self.tagListData[index + 1]

	return data and data.tIndex or 0
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
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

M.OnPanelClose = function(self, _, panelId)
	if panelId == gPanelId.BAIKE_ITEM_PANEL then
		return
	end

	self.FlushReadSeenSet(self)
end
