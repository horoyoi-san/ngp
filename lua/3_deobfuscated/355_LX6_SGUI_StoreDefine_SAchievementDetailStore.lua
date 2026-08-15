local RedDotMgr = SGUI.RedDotMgr
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local AchievementConfig = LTConfig.AchievementConfig
local UNavigationMgr = SGUI.UNavigationMgr
C_SAchievementDetailStore = DefClass("C_SAchievementDetailStore", C_SAchievementDetailStore, C_StoreGroup)
GroupName2Class.SAchievementDetailStore = C_SAchievementDetailStore
local M = C_SAchievementDetailStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local SEARCH_STATE = {
	SEARCHED = 2,
	NORAML = 0,
	SEARCHING = 1
}

function M:ctor(name, id, isSub)
	self.tabIndex = 0
	self.tabId = 0
	self.msgEvents = {
		[gEventConstants.GAIN_ACHIEVEMENT] = self:CreateAction(self.RefreshPage)
	}
end

function M:OnAwake()
	self.bindData.achievementList.luaSimpleRenderItem = self:CreateAction("OnRenderAchievementItem")
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.inputField.luaValueChanged = self:CreateAction("OnInputFieldValueChanged")
	self.bindData.inputField.onActivateAction = self:CreateAction("OnInputFieldActivate")
	self.bindData.inputField.onDeActivateAction = self:CreateAction("OnInputFieldDeactivate")
	self.bindData.inputCloseBtn.luaClick = self:CreateAction("OnInputCloseBtnClick")
	self.bindData.inputField.luaEndEdit = self:CreateAction("OnInputFieldEndEdit")
	self.bindData.searchBtn.luaClick = self:CreateAction("OnSearchBtnClick")
	self.mgr = gNewAchievementMgr
	self.secTabId = 0
	self.inputFieldActive = false
	self.achList = {}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnInputFieldActivate()
	UNavigationMgr.Inst.CurrentActiveArea = self.bindData.inputNavigationArea
	self.inputFieldActive = true
end

function M:OnInputFieldDeactivate()
	UNavigationMgr.Inst.CurrentActiveArea = self.bindData.navigationArea
	self.inputFieldActive = false
end

function M:OnInputFieldEndEdit(text, enter)
	if enter then
		self:RefreshList()
	end
end

function M:OnSearchBtnClick()
	self:RefreshList()

	if SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() then
		self.bindData.inputField:DeactivateInputField()

		if self.bindData.hasResult == BOOL2CTL[true] then
			self.bindData.achievementList:SetNavSelectToTop()
		end
	end
end

function M:OnShow(panelId, data)
	local tabIndex = 0
	local tabList = self.mgr:GetAchievementFirstCover()
	self.tabId = data and data.id or tabList[1].id

	self.mgr:OnPanelOpen()

	for i = 1, #tabList do
		if tabList[i].id == self.tabId then
			tabIndex = i - 1

			break
		end
	end

	self.SubGroup.CommonTabSingleStore:SetData(tabList, nil, tabIndex, 0, self:CreateAction("OnChangeTab"), self:CreateAction("OnRenderTabItem"))
	self:RefreshTab()
end

function M:OnClose()
	self:ClearMessageEvents()
end

function M:OnRenderAchievementItem(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local id = self.achList[index + 1]

	self.bindData.achievementList:SetItemId(index, id)

	local detail = self.mgr.achievementData[id]
	local info = self.mgr:GetAchievementDetail(id)
	local progress, maxProgress = self.mgr:GetProgressById(id)
	store.rarity = info.quality - 1
	store.nameLabel = info.name
	store.descLabel = info.desc
	store.progressLabel = progress .. "/" .. maxProgress
	store.inSearch = self.bindData.inSearch
	store.tabLabel = info.parentName

	if not table.isNilOrEmpty(detail) then
		store.dateLabel = gTimeUtils:DateFormat("%d/%02d/%02d", detail.AchieveTime)
	end

	function store.getBtn.luaClick()
		self.mgr:AskReceiveReward(id, self:CreateActionWithArgs(self.RefreshPage))
	end

	if info.reward then
		local itemData = gCommonItemManager:GetItemRenderData({
			itemId = info.reward[1].Id,
			itemNum = info.reward[1].Count
		})

		gCommonItemManager:OnCommonItemRender(store.itemBtn, 0, itemData)

		store.showItemBtn.luaClick = self:CreateActionWithArgs("OnShowFakeItemList", info.reward, gCommonItemManager)
	end

	function store.backVBtn.luaClick()
		self:RefreshTab()
	end

	self:OnRefreshBtnState({
		store = store,
		id = id
	})
end

function M:OnRefreshBtnState(data)
	if not self.STATE_EnableOnce then
		return
	end

	local isFinished = self.mgr.achievementFinishState[data.id]
	local cfg = AchievementConfig.GetConfig(data.id)

	if cfg.Hide and not isFinished then
		data.store.state = 3

		return
	end

	local red = self.mgr:GetRedCountById(data.id)

	if red > 0 then
		data.store.state = 2

		return
	end

	data.store.state = isFinished and 0 or 1
end

function M:OnChangeTab(uList, isSub)
	if not isSub then
		local item = self.SubGroup.CommonTabSingleStore:GetSelectedItem()
		local tabId = item and item.id or 0
		self.tabId = tabId

		self:RefreshTab()
	else
		local item = self.SubGroup.CommonTabSingleStore:GetSubSelectedItem()
		local secTabId = item and item.id or 0
		self.secTabId = secTabId

		self:RefreshList()
	end

	self:OnClearInputField()
end

function M:OnInputCloseBtnClick()
	self:OnClearInputField()

	self.bindData.searchState = SEARCH_STATE.SEARCHED
end

function M:OnClearInputField()
	if self.bindData.inSearch ~= BOOL2CTL[true] then
		return
	end

	self.bindData.inputField.text = ""
	self.bindData.inSearch = BOOL2CTL[false]

	self:RefreshList()
end

function M:OnInputFieldValueChanged()
	self.bindData.searchState = SEARCH_STATE.NORAML
end

function M:OnRenderTabItem(btn, index, data, store, isSub)
	if isSub then
		local progress, maxProgress = self.mgr:GetProgressById(data.id)
		local isFinish = progress == maxProgress
		store.IsCompleteCollection = BOOL2CTL[isFinish]
		store.desc = isFinish and TextScriptTextConfig.GetConfig(89901224).Text or math.ceil(progress / maxProgress * 100) .. "%"
	end

	if store.enterVBtn then
		function store.enterVBtn.luaClick()
			self.bindData.achievementList:SetNavSelectToTop()
		end
	end
end

function M:OnBackBtnClick()
	gPanelManager:Close(self.m_Id)
	gPanelManager:CheckShow(gPanelId.S_ACHIEVEMENT_COVER)
end

function M:RefreshTab()
	local secTabList = self.mgr:GetSecTabList(self.tabId)

	self.SubGroup.CommonTabSingleStore:SetTabList(secTabList, true)

	if self.secTabId == 0 then
		self.SubGroup.CommonTabSingleStore:SetSelectedIndex(0, true, true)
		self.SubGroup.CommonTabSingleStore:NavigateToTop(true)

		self.secTabId = not table.isNilOrEmpty(secTabList) and secTabList[1].id or 0
	else
		local exist = false

		for i = 1, #secTabList do
			if secTabList[i].id == self.secTabId then
				exist = true

				self.SubGroup.CommonTabSingleStore:SetSelectedIndex(i - 1, true, true)

				break
			end
		end

		if not exist then
			self.secTabId = not table.isNilOrEmpty(secTabList) and secTabList[1].id or 0

			self.SubGroup.CommonTabSingleStore:SetSelectedIndex(0, true, true)
			self.SubGroup.CommonTabSingleStore:NavigateToTop(true)
		end
	end
end

function M:RefreshList()
	local filter = string.lower(self.bindData.inputField.text)
	local notInSearch = string.is_null_or_empty(filter)
	self.bindData.inSearch = BOOL2CTL[not notInSearch]
	self.achList = self.mgr:GetAchievementList(notInSearch and self.secTabId or nil, filter)
	self.bindData.hasResult = BOOL2CTL[not table.isNilOrEmpty(self.achList)]
	self.bindData.searchState = notInSearch and SEARCH_STATE.SEARCHED or SEARCH_STATE.SEARCHING

	self.bindData.achievementList:SetSimpleList(#self.achList)
end

function M:RefreshPage()
	self.SubGroup.CommonTabSingleStore:RefreshItems()
	self.SubGroup.CommonTabSingleStore:RefreshSubItems()
	self:RefreshTab()
end
