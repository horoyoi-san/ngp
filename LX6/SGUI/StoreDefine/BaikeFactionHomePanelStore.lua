-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BaikeFactionHomePanelStore.lua
-- Decompiled from: 01565_BaikeFactionHomePanelStore.lua_bce4eea99cb7.luajit

C_BaikeFactionHomePanelStore = DefClass("C_BaikeFactionHomePanelStore", C_BaikeFactionHomePanelStore, C_StoreGroup)
GroupName2Class.BaikeFactionHomePanelStore = C_BaikeFactionHomePanelStore
local M = C_BaikeFactionHomePanelStore

M.ctor = function(self)
	self.secondClassListData = {}
	self.factionListData = {}
end

M.OnAwake = function(self)
	self.bindData.factionItemList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderFactionItemListItem")
	self.bindData.factionItemList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickFactionItemList")
	self.bindData.factionItemList.onGetTIndex = self.CreateAction(self, "OnGetFactionItemListTIndex")
end

M.OnEnable = function(self)
end

M.ShowPanel = function(self, args)
	self.InitModel(self, args)
	self.InitView(self, args)
end

M.InitModel = function(self, args)
	self.targetFirstCategoryId = args.targetFirstCategoryId
	self.targetItemId = args.targetItemId
end

M.InitView = function(self)
	local secondClassListData, selectedIndex = self:GetSecondClassListData()
	self.secondClassListData = secondClassListData

	self.SubGroup.CommonTabSingleStore:SetData(secondClassListData, nil, selectedIndex, nil, self:CreateAction("OnSecondClassTabChanged"), self:CreateAction("OnSecondClassTabRenderItem"), nil, false)

	self.SubGroup.CommonTabSingleStore.bindData.isSingle = 0
	local hasFactionCountryNum = self:GetHasFactionCountryNum(secondClassListData)
	local showTab = hasFactionCountryNum >= 1
	self.bindData.tabCtrl = showTab and 1 or 0

	self:UpdateMainTabStepBtnVisible(showTab)
end

M.GetHasFactionCountryNum = function(self, secondClassListData)
	local num = 0

	for _, viewData in ipairs(secondClassListData) do
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
	local _, selectedIndex = self:GetSecondClassListData()

	self.SubGroup.CommonTabSingleStore:SetSelectedIndex(selectedIndex, true, false)
end

M.GetSecondClassListData = function(self)
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

M.OnSecondClassTabChanged = function(self)
	self.RefreshFactionItemList(self)
end

M.OnSecondClassTabRenderItem = function(self, btn, _, itemData)
	if not itemData then
		return
	end

	btn.enabledTooltip = false
	local redDotKey = gBaiKeArchiveManager.GetCityPediaSecondClassRedDotKey(itemData.id)
	btn.redKey = redDotKey
	local hasRedDot = gBaiKeArchiveManager.CheckCityPediaSecondClassHasRedDot(itemData.id)

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)
end

M.RefreshFactionItemList = function(self)
	local selectedItem = self.SubGroup.CommonTabSingleStore:GetSelectedItem()

	if not selectedItem then
		return
	end

	self.factionListData = self:GetFactionItemListData(selectedItem.id)

	self.bindData.factionItemList:SetSimpleList(#self.factionListData)

	local targetIsLast = false

	if self.targetItemId then
		for index, viewData in ipairs(self.factionListData) do
			if viewData.cfgId ~= self.targetItemId then
				self.bindData.factionItemList:GoToIndex(index - 1, true)
				self.bindData.factionItemList:SetNavSelectToSelect(true)

				targetIsLast = index < #self.factionListData

				break
			end
		end

		self.targetItemId = nil
	end

	if self.bindData and self.bindData.factionItemList then
		self.bindData.factionItemList:RefreshList()
	end

	if targetIsLast then
		self.ScrollFactionItemListToBottom(self)
	end
end

M.ScrollFactionItemListToBottom = function(self)
	slot1 = gCoroutineManager

	slot1:StartCoroutine(function ()
		for _ = 1, 5 do
			coroutine.yield(nil)

			local list = self.bindData and self.bindData.factionItemList

			if not list or gCS.LuaUtils.IsNull(list) then
				return
			end

			list:GoToPos(Vector2.New(0, 99999), true)
		end
	end)
end

M.GetFactionItemListData = function(self, secondClassId)
	local viewDataList = {}
	local cityPediaIdList = gBaiKeArchiveManager.GetSecondClassCityPediaIdList(secondClassId)

	for _, cityPediaId in ipairs(cityPediaIdList) do
		local isUnlocked = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(cityPediaId)

		table.insert(viewDataList, {
			["a\\x9f\\x8a\\x86Y"] = 0,
			cfgId = cityPediaId,
			hasUnlocked = isUnlocked
		})
	end

	table.sort(viewDataList, function (a, b)
		if a.hasUnlocked == b.hasUnlocked then
			return a.hasUnlocked
		end

		return a.cfgId <= b.cfgId
	end)

	return viewDataList
end

M.OnSimpleRenderFactionItemListItem = function(self, btn, index)
	local data = self.factionListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local itemData = gBaiKeArchiveManager:GetCityPediaItem(data.cfgId)
	store.title = itemData.name
	store.iconId = itemData.iconId
	store.isLockedCtrl = gBaiKeArchiveManager.CheckCityPediaItemHasUnlocked(data.cfgId) and 0 or 1
	local bgColorStr = itemData.cityPediaCfg.BackgroundColor or ""

	if bgColorStr == "" then
		store.color = Color.NewByStr(bgColorStr.gsub(bgColorStr, "^#", ""))
	end

	local isDisposition = itemData.isDisposition
	local isInfluence = itemData.isInfluence

	if isDisposition ~= isInfluence then
		store.enemyCtrl = 2
	elseif isInfluence then
		store.enemyCtrl = 1
	else
		store.enemyCtrl = 0
	end

	local redDotKey = gBaiKeArchiveManager.GetCityPediaRedDotKey(data.cfgId)
	btn.redKey = redDotKey
	btn.enabledTooltip = false
	local hasRedDot = gBaiKeArchiveManager.CheckCityPediaItemHasRedDot(data.cfgId)

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)
end

M.OnSimpleClickFactionItemList = function(self, btn, index)
	local data = self.factionListData[index + 1]

	if not data then
		return
	end

	gBaiKeArchiveManager.SetCityPediaItemHasRead(data.cfgId)

	local itemPanelStore = gStoreManager:GetStoreGroup("BaikeItemPanelStore")

	if itemPanelStore then
		itemPanelStore.ShowFactionDetail(itemPanelStore, data.cfgId)
	end
end

M.OnGetFactionItemListTIndex = function(self, index)
	local luaIndex = index + 1

	if luaIndex < #self.factionListData then
		return self.factionListData[luaIndex].tIndex or 0
	end

	return 0
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end
