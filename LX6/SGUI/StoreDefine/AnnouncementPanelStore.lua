-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AnnouncementPanelStore.lua
-- Decompiled from: 01554_AnnouncementPanelStore.lua_64f65dbb28cd.luajit

C_AnnouncementPanelStore = DefClass("C_AnnouncementPanelStore", C_AnnouncementPanelStore, C_StoreGroup)
GroupName2Class.AnnouncementPanelStore = C_AnnouncementPanelStore
local M = C_AnnouncementPanelStore

M.ctor = function(self)
	self.mgr = gAnnouncementMgr
end

M.OnClose = function(self)
	self.mgr:OnExit()
end

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.contentList.onGetTIndex = self.CreateAction(self, self.OnGetTIndex)
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, self.OnContentRenderItem)
	self.bindData.contentList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnContentRenderItem)
	self.currentTab = 0
	self.currentSubTab = 0
	self.content = {}
end

M.OnShow = function(self, _, content)
	self.RefreshPage(self)
end

M.RefreshPage = function(self)
	local contentList = self.mgr.noticeList

	self.SubGroup.CommonTabSingleStore:SetData(contentList, nil, self.currentTab, nil, self:CreateAction(self.OnChangeTab), self:CreateAction(self.OnRenderTabItem))
end

M.RefreshTab = function(self)
	self.SubGroup.CommonTabSingleStore:SetTabList(self.mgr.noticeList[self.currentTab + 1].content, true)
	self.SubGroup.CommonTabSingleStore:SetSelectedIndex(self.currentSubTab, true, true)
end

M.RefreshContent = function(self)
	local content = self.mgr.noticeList[self.currentTab + 1].content

	if table.isNilOrEmpty(content) then
		return
	end

	self.content = content[self.currentSubTab + 1]

	self.bindData.contentList:SetSimpleList(#self.content.content)

	self.bindData.title = self.content.title

	self.mgr:ReadNotice(self.currentTab + 1, self.content.id)
end

M.OnChangeTab = function(self, uList, isSub)
	if isSub then
		self.currentSubTab = uList.selectedIndex

		self.RefreshContent(self)
	else
		self.currentTab = uList.selectedIndex
		self.currentSubTab = 0

		self.RefreshTab(self)
	end
end

M.OnRenderTabItem = function(self, btn, index, data, store, isSub, uList)
	if data.templateKey then
		btn.templateKey = data.templateKey
	end
end

M.OnGetTIndex = function(self, index)
	return self.content.content[index + 1].tIndex
end

M.OnContentRenderItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.content.content[index + 1]

	store:Commit("title", data.text, COMMIT_IMMEDIATELY)

	store.imageId = data.iconId
end

M.OnExitClick = function(self)
	gPanelManager:Close(self.m_Id)
end
