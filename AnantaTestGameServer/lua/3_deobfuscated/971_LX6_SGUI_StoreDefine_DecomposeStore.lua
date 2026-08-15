local GameDevice = SGUI.GameDevice
C_DecomposeStore = DefClass("C_DecomposeStore", C_DecomposeStore, C_StoreGroup)
GroupName2Class.DecomposeStore = C_DecomposeStore
local M = C_DecomposeStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}

function M:GetParent()
	return gStoreManager:GetStoreGroup("SynthesizePanelStore")
end

function M:ctor()
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self:CreateAction("OnRefreshPage")
	}
end

function M:DefineAllVariables()
	self.targetTab = 0
	self.breakList = {}
	self.selectedIndex = -1
	self.selectList = {}
	self.isAscending = true
	self.currentTab = C_ProduceManager.TAB_INDEX.BreakDown
	self.mgr = gProduceManager
	self.tabListData = {}
	self.itemListData = {}
	self.descListData = {}
	self.decomposeListData = {}
	self.targetItem = {}
end

function M:OnAwake()
	self:DefineAllVariables()

	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction(self.OnRenderItem)
	self.bindData.itemList.luaSimpleClick = self:CreateAction(self.OnItemListBtnClick)
	self.bindData.itemList.luaSelectedChanged = self:CreateAction(self.OnItemListSelectedChange)

	function self.bindData.itemList.onGetTIndex(index)
		local data = self.itemListData[index + 1]

		return data.tIndex or 0
	end

	self.bindData.decomposeList.luaSimpleRenderItem = self:CreateAction("OnRenderDecomposeListItem")

	function self.bindData.decomposeList.onGetTIndex(index)
		local data = self.decomposeListData[index + 1]

		return data.tIndex or 0
	end

	self.bindData.subTab.luaSimpleRenderItem = self:CreateAction("OnRenderSubTabList")
	self.bindData.subTab.luaSelectedChanged = self:CreateAction("OnSubTabSelectedChange")
	self.bindData.decomposeBtn.luaClick = self:CreateAction("OnDecomposeBtnClick")
	self.bindData.descList.luaSimpleRenderItem = self:CreateAction("OnRenderDescItem")
	self.bindData.descList.luaSimpleClick = self:CreateAction("OnDescItemClick")

	function self.bindData.descList.onGetTIndex(index)
		local data = self.descListData[index + 1]

		return data.tIndex or 0
	end
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = GameDevice.KeyboardMouse < device
end

function M:OnRenderItem(btn, index)
	local data = self.itemListData[index + 1]
	local store = gCommonItemManager:OnCommonItemRender(btn, index, self.breakList[data.id])

	if store and store.vBtn then
		function store.vBtn.luaClick()
			self:OnItemListBtnClick(_, index, true)
		end
	end

	if store then
		if data.isWeapon then
			store.durabilityCtrl = 1
			store.durabilityText = data.durability
		else
			store.durabilityCtrl = 0
		end
	end
end

function M:OnStart()
	self:InitTabList()
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
	self:OnActiveDeviceChange(gCS.LuaUtils.GetActiveDevice())
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnRenderSubTabList(btn, index)
	local data = self.tabListData[index + 1]
	local store = gStoreManager:GetStoreGroup("SynthesizeSubTabTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.iconId
end

function M:OnRenderDecomposeListItem(btn, index)
	local data = self.decomposeListData[index + 1]

	gCommonItemManager:OnCommonItemRender(btn, index, data)
end

function M:OnRenderDescItem(btn, index)
	local data = self.descListData[index + 1]

	gCommonItemManager:OnRenderDescItem(btn, index, data)
end

function M:OnDescItemClick(btn, index)
	local data = self.descListData[index + 1]

	gCommonItemManager:OnDescItemClick(btn, data)
end

function M:OnSortChanged(sortId, isAscending)
	self.isAscending = isAscending

	self:RefreshItemList()
end

function M:OnSubTabSelectedChange(uList)
	local ele = uList.selectedIndex

	if not ele then
		return
	end

	self.targetTab = ele

	self:OnRefreshPage()
end

function M:InitTabList()
	self.tabListData = self.mgr:GetBreakDownTab(self.targetTab)

	self.bindData.subTab:SetSimpleList(#self.tabListData)
	self.bindData.subTab:SetItemSelected(0, true)
end

function M:RefreshItemList()
	local isEmpty = table.isNilOrEmpty(self.breakList)

	if isEmpty then
		self.bindData.itemList:SetSimpleList(0)

		self.bindData.IsEmpty = BOOL2CTL[isEmpty]

		return
	end

	table.sort(self.breakList, function (a, b)
		if a.quality ~= b.quality then
			if self.isAscending then
				return b.quality < a.quality
			else
				return a.quality < b.quality
			end
		end

		return a.itemId < b.itemId
	end)

	for i = 1, #self.breakList do
		self.breakList[i].id = i
	end

	self.itemListData = table.clone(self.breakList)
	local maxNum = self.bindData.itemList:GetMaxRowAndColCount(0)
	local col = math.max(math.ceil(#self.itemListData / maxNum.x), maxNum.y)

	while #self.itemListData < maxNum.x * col do
		table.insert(self.itemListData, {
			tIndex = 1
		})
	end

	self.bindData.itemList:SetSimpleList(#self.itemListData)
	gCoroutineManager:StartCoroutine(function ()
		coroutine.yield(nil)
		coroutine.yield(nil)

		self.bindData.IsEmpty = BOOL2CTL[isEmpty]
	end)
end

function M:OnRefreshPage()
	self.selectedIndex = -1
	self.selectList = {}

	self.bindData.decomposeList:SetSimpleList(0)

	self.breakList = self.mgr:GetBreakDownLists(self.targetTab)

	self:RefreshItemList()

	self.bindData.showInfo = BOOL2CTL[false]
	self.bindData.showSlider = BOOL2CTL[false]
	self.bindData.titleLabel = self.mgr:GetPanelSubTitle(self.currentTab, self.targetTab + 1)
end

function M:OnItemListSelectedChange(uList)
	local selectedIndex = uList.selectedIndex

	if not selectedIndex or selectedIndex == -1 then
		return
	end

	self.targetItem = self.itemListData[selectedIndex + 1]

	self:OnRefreshInfo()
end

function M:OnItemListBtnClick(btn, index, fromVBtn)
	local data = self.itemListData[index + 1]

	if self.gamepadMode and not fromVBtn then
		return
	end

	self.bindData.itemList:SetItemSelected(index, true)

	local count = self.selectList[data.instanceId]

	if not count or count == 0 then
		count = data.count
	else
		count = 0
	end

	self:ChangeSelectListCount(data, count)

	if count > 0 then
		self.SubGroup.CommonBuyNumSliderStore:ChangeValue(count)
	end
end

function M:OnDecomposeBtnClick()
	self.bindData.vxCtrl = 0

	FrameTimer.New(function ()
		self:PlayAniChain(self.bindData.decomposeAni, "S_vx_Decompose_fenjie", nil, gPanelId.S_SYNTHESIZE_PANEL):OnComplete(function ()
			self.bindData.vxCtrl = 1

			self.mgr:AskItemBreakDown(self.selectList, self:CreateAction("OnRefreshPage"))
		end)
	end, 0):Start()
end

function M:OnRefreshInfo()
	local hasItem = not table.isNilOrEmpty(self.targetItem)
	self.bindData.showInfo = BOOL2CTL[hasItem]
	self.bindData.showSlider = BOOL2CTL[hasItem]

	if not hasItem then
		return
	end

	self.data = gCommonItemManager:TryGetItemInfo({
		showSource = false,
		itemId = self.targetItem.itemId
	})

	if table.isNilOrEmpty(self.data) then
		print_error("RefreshPage data is nil")

		return
	end

	self.bindData.nameLabel = self.data.name
	self.bindData.quality = self.data.quality
	self.bindData.iconId = self.data.iconId
	self.descListData = {}
	local hasSource = gCommonItemManager:GetItemDescList(self.data, self.descListData)

	if not hasSource and #self.descListData > 0 then
		table.remove(self.descListData, 1)
	end

	self.bindData.descList:SetSimpleList(#self.descListData)
	self.SubGroup.CommonBuyNumSliderStore:SetData({
		range = {
			1,
			self.targetItem.count
		},
		value = self.selectList[self.targetItem.instanceId] or 0,
		valChangeCallback = self:CreateAction("OnBuyNumChange")
	})
end

function M:OnRewardChange()
	local rewardDict = {}
	self.decomposeListData = {}

	for i = 1, #self.breakList do
		if self.selectList[self.breakList[i].instanceId] then
			local reward = self.breakList[i].reward

			for j = 1, #reward do
				local currentCount = rewardDict[reward[j].Id] or 0
				rewardDict[reward[j].Id] = currentCount + reward[j].Count * self.selectList[self.breakList[i].instanceId]
			end
		end
	end

	for k, v in pairs(rewardDict) do
		if v > 0 then
			local ele = {
				itemId = k,
				itemNum = v,
				countCtl = C_CommonItemManager.CommonItemRenderCountCtl.UP
			}

			table.insert(self.decomposeListData, gCommonItemManager:GetItemRenderData(ele))
		end
	end

	table.sort(self.decomposeListData, self:CreateAction("SortRenderItem", gCommonItemManager))

	if #self.decomposeListData <= 0 then
		self.bindData.listNavi:SetActive(false)

		self.bindData.decomposeBtn.interactable = false
	else
		self.bindData.listNavi:SetActive(true)

		self.bindData.decomposeBtn.interactable = true
	end

	local maxNum = self.bindData.decomposeList:GetMaxRowAndColCount(0)
	local col = math.max(math.ceil(#self.decomposeListData / maxNum.x), maxNum.y)

	while #self.decomposeListData < maxNum.x * col do
		table.insert(self.decomposeListData, {
			tIndex = 1
		})
	end

	self.bindData.btnState = BOOL2CTL[#self.decomposeListData > 0]

	self.bindData.decomposeList:SetSimpleList(#self.decomposeListData)
end

function M:OnBuyNumChange(num)
	self:ChangeSelectListCount(self.targetItem, num)
end

function M:ChangeSelectListCount(data, count)
	self.bindData.showSlider = BOOL2CTL[count > 0]
	self.selectList[data.instanceId] = count

	if self.selectList[data.instanceId] ~= 0 then
		self.breakList[data.id].itemNum = self.selectList[data.instanceId] .. "/" .. data.count
	else
		self.breakList[data.id].itemNum = data.count
	end

	self.breakList[data.id].showUnselect = self.selectList[data.instanceId] > 0

	self.bindData.itemList:RefreshLogicList()
	self:OnRewardChange()
end
