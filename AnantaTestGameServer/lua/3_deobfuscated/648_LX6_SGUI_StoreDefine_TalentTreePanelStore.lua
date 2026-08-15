local TalentTreeConfig = LTConfig.TalentTreeConfig
C_TalentTreePanelStore = DefClass("C_TalentTreePanelStore", C_TalentTreePanelStore, C_StoreGroup)
GroupName2Class.TalentTreePanelStore = C_TalentTreePanelStore
local M = C_TalentTreePanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:ctor()
	self.mgr = gTalentTreeMgr
end

function M:DefineAllVariables()
	self.showData = {}
	self.displayStore = nil
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	self:RegisterMessageEvents(self.msgEvents)

	self.bindData.ShowMainPage = BOOL2CTL[gMainPageManager:CheckMainPageShowById(self.m_Id)]
end

function M:OnDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	gNewGuideMgr:NotifySignal(EGuideSignal.TalentTreeOpen)
	self.mgr:OnStartCurrent()
	self:RefreshTab(data and data.jobClassId)
end

function M:RefreshTab(jobClass)
	local jobTab = self.mgr:GetJobClassTab(jobClass)
	local currentIndex = 0

	for i = 1, #jobTab do
		if jobTab[i].current then
			currentIndex = i - 1

			break
		end
	end

	self.SubGroup.CommonTabSingleStore:SetData(jobTab, nil, currentIndex, 0, self:CreateAction(self.OnChangeTab), self:CreateAction(self.OnRenderTabItem))
end

function M:OnChangeTab(uList, isSub)
	local item = self.SubGroup.CommonTabSingleStore:GetSelectedItem()
	local id = item and item.id or 0
	local cfg = TalentTreeConfig.GetConfig(id)

	if not cfg then
		return
	end

	self.showData = {
		jobClass = cfg.JobClassId,
		treeId = cfg.Id,
		itemId = cfg.ConsumableId
	}
	local tabIndex = cfg.TabIndex

	if self.bindData.tabRect.selectedIndex == tabIndex then
		self:ShowStore(self.displayStore)
	else
		self.bindData.tabRect.selectedIndex = tabIndex
	end
end

function M:OnRenderTabItem(btn, index, data, store, isSub, uList)
	local id = data and data.id or 0
	local cfg = TalentTreeConfig.GetConfig(id)

	if not cfg then
		return
	end

	btn.redId = cfg.RedDotId
	btn.templateKey = "Base"
end

function M:OnClose()
	if self.displayStore then
		self.displayStore:OnClose()

		self.displayStore = nil
	end

	self.bindData.tabRect.selectedIndex = -1

	self.mgr:OnExit()
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.SPIRIT_TALENT_CHANGE] = self:CreateAction("OnSpiritJobInfoChange")
	}
end

function M:RegisterWidget()
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnTabRectRender")
	self.bindData.backBtn.luaClick = self:CreateAction(self.OnCloseBtnClick)
end

function M:OnTabRectRender(index, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)

	self:ShowStore(store)
end

function M:ShowStore(store)
	if self.displayStore then
		self.displayStore:OnClose()
	end

	if store then
		store:OnShow(self.m_Id, self.showData)

		self.displayStore = store
	end
end

function M:OnCloseBtnClick()
	if gCommonItemManager.itemToolTipRefBtn then
		gCommonItemManager:CloseItemToolTips()

		return
	end

	gPanelManager:Close(self.m_Id)
end

function M:OnSpiritJobInfoChange(evnetId, param)
	if self.displayStore and self.displayStore.OnSpiritJobInfoChange then
		self.displayStore:OnSpiritJobInfoChange(param)
	end
end
