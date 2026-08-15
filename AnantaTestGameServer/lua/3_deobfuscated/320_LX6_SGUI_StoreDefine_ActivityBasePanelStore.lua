C_ActivityBasePanelStore = DefClass("C_ActivityBasePanelStore", C_ActivityBasePanelStore, C_StoreGroup)
GroupName2Class.ActivityBasePanelStore = C_ActivityBasePanelStore
local M = C_ActivityBasePanelStore

function M:ctor()
	self.mgr = gAwardActivityManager
	self.closeAniName = "S_Vx_ActivityBasePanel_close"
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction(self.OnBackBtnClick)
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
	self.currentStore = nil
	self.currentTab = 1
	self.tabList = {}
end

function M:OnShow(panelId, data)
	self.tabList = self.mgr:GetActivityList()

	if table.isNilOrEmpty(self.tabList) then
		return
	end

	self.SubGroup.CommonTabSingleStore:SetData(self.tabList, nil, self.currentTab - 1, nil, self:CreateAction(self.OnChangeTab), self:CreateAction(self.OnRenderTabItem))
end

function M:OnClose()
	return
end

function M:OnBackBtnClick()
	gUIUtils:PlayAniClosePanel(self.bindData.closeAni, self.closeAniName, self.m_Id)
end

function M:OnChangeTab(uList, isSub)
	self.currentTab = uList.selectedIndex + 1
	self.bindData.tabRect.selectedIndex = self.mgr:GetActivityTemplateIndex(self.tabList[self.currentTab].id)
end

function M:OnRenderTabItem(btn, index, data, store, isSub, uList)
	btn.redId = self.mgr:GetRedId(self.tabList[index + 1].id)
end

function M:OnRenderTab(index, widget)
	if self.currentStore and self.currentStore.OnClose then
		self.currentStore:OnClose()
	end

	local store = gStoreManager:GetStoreGroup(widget.Store)

	self.mgr:AskCancelRedPoint(self.tabList[self.currentTab].id)
	store:OnShow(self.m_Id, self.tabList[self.currentTab].id)

	self.currentStore = store
end
