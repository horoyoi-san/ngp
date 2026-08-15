local MoneyType = UX.Game.MoneyType
C_MakeStore = DefClass("C_MakeStore", C_MakeStore, C_StoreGroup)
GroupName2Class.MakeStore = C_MakeStore
local M = C_MakeStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}
local BTN_STATE = {
	Unique = 3,
	MoneyLack = 4,
	NotEnough = 1,
	IsLocked = 2,
	Normal = 0
}

function M:GetParent()
	if not self.parent then
		self.parent = gStoreManager:GetStoreGroup("SynthesizePanelStore")
	end

	return self.parent
end

function M:ctor()
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self:CreateAction("RefreshItemNum"),
		[gEventConstants.PRODUCE_AVAILABLE_CHANGE] = self:CreateAction("OnRefreshPage")
	}
end

function M:DefineAllVariables()
	self.data = {}
	self.targetItem = {}
	self.targetTab = 0
	self.targetCount = 1
	self.isAscending = true
	self.availableProduces = {}
	self.parent = nil
	self.tabListData = {}
	self.itemListData = {}
	self.descListData = {}
	self.consumeListData = {}
	self.mgr = gProduceManager
	self.currentTab = C_ProduceManager.TAB_INDEX.Produce
end

function M:OnAwake()
	self:DefineAllVariables()

	self.bindData.descList.luaSimpleRenderItem = self:CreateAction("OnRenderDescItem")
	self.bindData.descList.luaSimpleClick = self:CreateAction("OnDescItemClick")

	function self.bindData.descList.onGetTIndex(index)
		local data = self.descListData[index + 1]

		return data.tIndex or 0
	end

	self.bindData.consumeList.luaSimpleRenderItem = self:CreateAction("OnRenderConsumeListItem")

	function self.bindData.consumeList.onGetTIndex(index)
		local data = self.consumeListData[index + 1]

		return data.tIndex or 0
	end

	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction("OnCommonItemRender")
	self.bindData.itemList.luaSelectedChanged = self:CreateAction("OnItemListSelectedChange")

	function self.bindData.itemList.onGetTIndex(index)
		local data = self.itemListData[index + 1]

		return data.tIndex or 0
	end

	self.bindData.makeBtn.luaClick = self:CreateAction("OnMakeBtnClick")
	self.bindData.subTab.luaSimpleRenderItem = self:CreateAction("OnRenderSubTabList")
	self.bindData.subTab.luaSelectedChanged = self:CreateAction("OnSubTabSelectedChange")
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnStart()
	self:InitTabList()
end

function M:OnClose()
	return
end

function M:InitTabList()
	self.tabListData = self.mgr:GetProduceTab(self.targetTab)

	self.bindData.subTab:SetSimpleList(#self.tabListData)
	self.bindData.subTab:SetItemSelected(0, true)
end

function M:OnMakeBtnClick()
	self.mgr:MakeProduce(self.targetItem.produceId, self.targetCount)
	gPanelManager:Close(gPanelId.S_SYNTHESIZE_PANEL)
end

function M:OnCommonItemRender(btn, index)
	local data = self.itemListData[index + 1]

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

function M:OnRenderConsumeListItem(btn, index)
	local data = self.consumeListData[index + 1]

	gCommonItemManager:OnCommonItemRender(btn, index, data)
end

function M:OnRenderSubTabList(btn, index)
	local data = self.tabListData[index + 1]
	local store = gStoreManager:GetStoreGroup("SynthesizeSubTabTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.iconId
end

function M:OnItemListSelectedChange(uList)
	local ele = uList.selectedIndex

	if not ele then
		return
	end

	self.targetItem = self.itemListData[ele + 1]

	self:OnRefreshInfo()
end

function M:OnSubTabSelectedChange(uList)
	local ele = uList.selectedIndex

	if not ele then
		return
	end

	self.targetTab = ele

	self:OnRefreshPage()
end

function M:OnSortChanged(sortId, isAscending)
	self.isAscending = isAscending

	self:RefreshItemList()
end

function M:RefreshItemList()
	self.bindData.showRight = BOOL2CTL[#self.availableProduces > 0]

	table.sort(self.availableProduces, function (a, b)
		if a.isLock ~= b.isLock then
			return not a.isLock
		end

		if a.isBan ~= b.isBan then
			return not a.isBan
		end

		if a.quality ~= b.quality then
			if self.isAscending then
				return b.quality < a.quality
			else
				return a.quality < b.quality
			end
		end

		return a.itemId < b.itemId
	end)

	self.itemListData = table.clone(self.availableProduces)
	local maxNum = self.bindData.itemList:GetMaxRowAndColCount(0)
	local col = math.max(math.ceil(#self.itemListData / maxNum.x), maxNum.y)

	while #self.itemListData < maxNum.x * col do
		table.insert(self.itemListData, {
			tIndex = 1
		})
	end

	self.bindData.itemList:SetSimpleList(#self.itemListData)
	self.bindData.itemList:SelectItem(0)
end

function M:OnRefreshPage()
	if self:GetParent().formulaId ~= 0 then
		self.targetItem = {
			produceId = self:GetParent().formulaId
		}
		self.targetTab = self.mgr:GetTabIndexByFormula(self:GetParent().formulaId)
		self:GetParent().formulaId = 0
	end

	self.availableProduces = self.mgr:GetAvailableProduces(self.targetTab, self.targetItem)

	self:RefreshItemList()

	if self.bindData.showRight == BOOL2CTL[true] then
		self:OnRefreshInfo()
	end

	self.bindData.titleLabel = self.mgr:GetPanelSubTitle(self.currentTab, self.targetTab + 1)
end

function M:OnBuyNumChange(num)
	if self.targetCount == num then
		return
	end

	self.targetCount = num

	self:RefreshMat()
end

function M:OnRefreshInfo()
	self.targetCount = 1
	local hasItem = not table.isNilOrEmpty(self.targetItem)
	self.bindData.showRight = BOOL2CTL[hasItem]

	if not hasItem then
		return
	end

	self.data = gCommonItemManager:TryGetItemInfo({
		showSource = false,
		itemId = self.targetItem.itemId
	})

	if table.isNilOrEmpty(self.data) then
		print_error("[MakeStore] RefreshPage data is nil")

		return
	end

	self.bindData.nameLabel = self.data.name
	self.bindData.quality = self.data.quality
	self.bindData.iconId = self.data.iconId
	self.bindData.difficulty = self.mgr:CheckProduceHard(self.targetItem.produceId) and 1 or 0
	self.descListData = {}
	local hasSource = gCommonItemManager:GetItemDescList(self.data, self.descListData)

	if not hasSource and #self.descListData > 0 then
		table.remove(self.descListData, 1)
	end

	self.bindData.descList:SetSimpleList(#self.descListData)

	local maxMatCost = self:RefreshMat()
	local maxMoneyCost = math.floor(gUIUtils:GetMoneyByType(MoneyType.Money) / self.targetItem.cost)
	local maxCost = math.min(maxMatCost, maxMoneyCost)

	if self.targetItem.unique > 0 then
		maxCost = math.min(maxCost, self.targetItem.unique)
	end

	self.bindData.btnState = BTN_STATE.Normal

	if maxMatCost < 1 then
		self.bindData.btnState = BTN_STATE.NotEnough
	end

	if maxMoneyCost < 1 then
		self.bindData.btnState = BTN_STATE.MoneyLack
	end

	self.bindData.btnState = self.targetItem.isBan and BTN_STATE.Unique or self.bindData.btnState
	self.bindData.btnState = self.targetItem.isLock and BTN_STATE.IsLocked or self.bindData.btnState

	if self.targetItem.isLock then
		self.bindData.unlockLabel = self.targetItem.unlockStr
	end

	self.bindData.showSilder = BOOL2CTL[false]

	self.SubGroup.CommonBuyNumSliderStore:SetData({
		range = {
			1,
			math.max(maxCost, 1)
		},
		data = {
			moneyId = MoneyType.Money,
			price = self.targetItem.cost
		},
		valChangeCallback = self:CreateAction("OnBuyNumChange")
	})
end

function M:RefreshMat()
	self.consumeListData = {}
	local isEnough = true
	local count = math.huge

	for i = 1, #self.targetItem.material do
		local mat = self.targetItem.material[i]
		local currentNum = gCommonItemManager:GetItemNum(mat.itemId)
		local targetNum = mat.num * self.targetCount
		local numStr = nil

		if currentNum < targetNum then
			isEnough = false
			numStr = "#R" .. currentNum .. "#z/" .. targetNum
		else
			numStr = currentNum .. "/" .. targetNum
		end

		local ele = {
			tIndex = 0,
			itemId = mat.itemId,
			itemNum = numStr
		}
		count = math.min(count, math.floor(currentNum / mat.num))

		table.insert(self.consumeListData, gCommonItemManager:GetItemRenderData(ele))
	end

	table.sort(self.consumeListData, function (a, b)
		if a.quality ~= b.quality then
			return b.quality < a.quality
		end

		return b.itemId < a.itemId
	end)

	local maxNum = self.bindData.consumeList:GetMaxRowAndColCount(0)
	local col = math.max(math.ceil(#self.consumeListData / maxNum.x), maxNum.y)

	while #self.consumeListData < maxNum.x * col do
		table.insert(self.consumeListData, {
			tIndex = 1
		})
	end

	self.bindData.consumeList:SetSimpleList(#self.consumeListData)

	return count
end

function M:RefreshItemNum()
	self:OnRefreshInfo()
end
