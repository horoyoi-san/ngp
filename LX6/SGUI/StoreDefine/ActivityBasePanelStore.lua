-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ActivityBasePanelStore.lua
-- Decompiled from: 01593_ActivityBasePanelStore.lua_a85b3a0d5536.luajit

local AwardActivityTemplateConfig = LTConfig.AwardActivityTemplateConfig
local AwardActivityConfig = LTConfig.AwardActivityConfig
C_ActivityBasePanelStore = DefClass("C_ActivityBasePanelStore", C_ActivityBasePanelStore, C_StoreGroup)
GroupName2Class.ActivityBasePanelStore = C_ActivityBasePanelStore
local M = C_ActivityBasePanelStore
local ACTIVITY_BASE_TEMPLATE_INDEX = {
	[AwardActivityTemplateConfig.SignIn] = 0,
	[AwardActivityTemplateConfig.SevenDays] = 1,
	[AwardActivityTemplateConfig.Notice] = 2,
	[AwardActivityTemplateConfig.LevelLandmark] = 3
}

M.ctor = function(self)
	self.mgr = gAwardActivityManager
	self.closeAniName = "S_Vx_ActivityBasePanel_close"
end

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnRenderTab)
	self.bindData.tabList.luaSelectedChanged = self.CreateAction(self, self.OnChangeTab)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTabItem)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnBackBtnClick)
	self.currentStore = nil
	self.currentTab = 1
	self.tabList = {}
end

M.OnShow = function(self, panelId, data)
	self.tabList = self.mgr:GetActivityList()

	if table.isNilOrEmpty(self.tabList) then
		return
	end

	self.currentTab = 1

	self.bindData.tabList:SetSimpleList(#self.tabList)
	self.bindData.tabList:SelectItem(self.currentTab - 1, true)
end

M.OnClose = function(self)
end

M.OnBackBtnClick = function(self)
	gUIUtils:PlayAniClosePanel(self.bindData.closeAni, self.closeAniName, self.m_Id)
end

M.OnChangeTab = function(self, uList)
	local index = uList.selectedIndex

	if index <= 0 or not self.tabList[index + 1] then
		return
	end

	self.currentTab = index + 1

	self.ApplyCurrentTab(self)
end

M.OnRenderTabItem = function(self, btn, index)
	local data = self.tabList[index + 1]

	if not data then
		return
	end

	local store = self.GetStoreByWidget(self, btn)

	if store then
		store.titleText = data.title
		store.bgImageId = data.iconId
	end

	btn.redId = self.mgr:GetRedId(self.tabList[index + 1].id)
end

M.OnRenderTab = function(self, index, widget)
	if self.currentStore and self.currentStore.OnClose then
		self.currentStore:OnClose()
	end

	local store = gStoreManager:GetStoreGroup(widget.Store)

	self.mgr:AskCancelRedPoint(self.tabList[self.currentTab].id)

	store.parent = self

	store:OnShow(self.m_Id, self.tabList[self.currentTab].id)

	self.currentStore = store
end

M.GetActivityTabSelectedIndex = function(self, activityCfgId)
	local templateId = self.mgr:GetActivityTemplateId(activityCfgId)
	local index = ACTIVITY_BASE_TEMPLATE_INDEX[templateId]

	if index ~= nil then
		print_error("[ActivityBase]: template not in TabUrlList", templateId)

		return 0
	end

	return index
end

M.ApplyCurrentTab = function(self)
	local data = self.tabList[self.currentTab]

	if not data then
		return
	end

	self.bindData.tabRect.selectedIndex = self.GetActivityTabSelectedIndex(self, data.id)
	self.bindData.titleText = self.tabList[self.currentTab].title
end
