-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MeTubePanelStore.lua
-- Decompiled from: 00973_MeTubePanelStore.lua_219ba51a7f26.luajit

local WebPageConfig = LTConfig.WebpageConfig
local MeTubeConfig = LTConfig.WebpageYowoVideoConfig
C_MeTubePanelStore = DefClass("C_MeTubePanelStore", C_MeTubePanelStore, C_StoreGroup)
GroupName2Class.MeTubePanelStore = C_MeTubePanelStore
local M = C_MeTubePanelStore
local BOOL2CTL = gClientConst.BOOL2CTL

M.ctor = function(self)
	self.mgr = gWebManager
end

M.OnAwake = function(self)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTabListItem)
	self.bindData.tabList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnSimpleRenderTabListItem)
	self.bindData.tabList.luaSelectedChanged = self.CreateAction(self, self.OnSimpleClickTabList)
	self.bindData.contentList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderContentListItem)
	self.bindData.contentList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnRenderContentListItem)
	self.bindData.contentList.luaLayoutSet = self.CreateAction(self, self.OnContentListLayoutSet)
	self.cfg = nil
	self.resources = {}
	self.tabList = WebPageConfig.YowoVideoTabNames
end

M.OnShow = function(self, panelId, data)
	self.bindData.tabList:SetSimpleList(2)
	self:RefreshPage()
	self.bindData.tabList:SelectItem(0)
end

M.RefreshPage = function(self)
	local userpage = self.mgr:GetCurrentParam("userpage")

	if not userpage then
		print_error("[C_MeTubePanelStore:OnShRefreshPageow] userpage is nil")

		return
	end

	self.cfg = MeTubeConfig.GetConfig(userpage)

	if not self.cfg then
		print_error("[C_MeTubePanelStore:RefreshPage] cfg is nil")

		return
	end

	self:OnSimpleClickTabList(self.bindData.tabList)

	local resourceId = self.mgr:GetCurrentParam("ResourceId")

	gMessageManager:SendMessage(gEventConstants.WEBSITE_HOVER_CHANGE, resourceId == nil)
end

M.OnHoverChange = function(self, content)
	local resourceId = self.mgr:GetCurrentParam("ResourceId")

	if resourceId then
		content.resourceId = resourceId
	end
end

M.OnClose = function(self)
end

M.OnSimpleRenderTabListItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	store.label = self.tabList[index + 1]
end

M.OnSimpleClickTabList = function(self, list)
	local index = list.selectedIndex

	if index ~= 0 then
		self.resources = self.cfg.Resources
	else
		self.resources = self.cfg.StarResources
	end

	self.bindData.contentList:SetSimpleList(#self.resources)

	self.bindData.isEmpty = BOOL2CTL[#self.resources ~= 0]
end

M.OnRenderContentListItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	store.resourceId = self.resources[index + 1]
end

M.OnContentListLayoutSet = function(self)
	gMessageManager:SendMessage(gEventConstants.WEBSITE_LAYOUT_RESET)
end
