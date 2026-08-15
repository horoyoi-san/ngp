C_AnnouncementPanelStore = DefClass("C_AnnouncementPanelStore", C_AnnouncementPanelStore, C_StoreGroup)
GroupName2Class.AnnouncementPanelStore = C_AnnouncementPanelStore
local M = C_AnnouncementPanelStore

function M:ctor()
	self.mgr = gAnnouncementMgr
end

function M:OnClose()
	self.mgr:OnExit()
end

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.contentList.onGetTIndex = self:CreateAction(self.OnGetTIndex)
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction(self.OnContentRenderItem)
	self.currentTab = 0
	self.currentSubTab = 0
	self.content = {}
end

function M:OnShow(_, content)
	self:RefreshPage()
end

function M:RefreshPage()
	local contentList = self.mgr.noticeList

	self.SubGroup.CommonTabSingleStore:SetData(contentList, nil, self.currentTab, nil, self:CreateAction(self.OnChangeTab), self:CreateAction(self.OnRenderTabItem))
end

function M:RefreshTab()
	self.SubGroup.CommonTabSingleStore:SetTabList(self.mgr.noticeList[self.currentTab + 1].content, true)
	self.SubGroup.CommonTabSingleStore:SetSelectedIndex(self.currentSubTab, true, true)
end

function M:RefreshContent()
	local content = self.mgr.noticeList[self.currentTab + 1].content

	if table.isNilOrEmpty(content) then
		return
	end

	self.content = content[self.currentSubTab + 1]

	self.bindData.contentList:SetSimpleList(#self.content.content)

	self.bindData.title = self.content.title

	self.mgr:ReadNotice(self.currentTab + 1, self.content.id)
end

function M:OnChangeTab(uList, isSub)
	if isSub then
		self.currentSubTab = uList.selectedIndex

		self:RefreshContent()
	else
		self.currentTab = uList.selectedIndex
		self.currentSubTab = 0

		self:RefreshTab()
	end
end

function M:OnRenderTabItem(btn, index, data, store, isSub, uList)
	if data.templateKey then
		btn.templateKey = data.templateKey
	end
end

function M:OnGetTIndex(index)
	return self.content.content[index + 1].tIndex
end

function M:OnContentRenderItem(btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.content.content[index + 1]
	store.title = data.text
	store.imageId = data.iconId
end

function M:OnExitClick()
	gPanelManager:Close(self.m_Id)
end
