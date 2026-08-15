local WebPageConfig = LTConfig.WebpageConfig
local MeTubeConfig = LTConfig.WebpageYowoVideoConfig
C_MeTubePanelStore = DefClass("C_MeTubePanelStore", C_MeTubePanelStore, C_StoreGroup)
GroupName2Class.MeTubePanelStore = C_MeTubePanelStore
local M = C_MeTubePanelStore
local BOOL2CTL = gClientConst.BOOL2CTL

function M:ctor()
	self.mgr = gWebManager
end

function M:OnAwake()
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction(self.OnSimpleRenderTabListItem)
	self.bindData.tabList.luaSimpleDynamicRenderItem = self:CreateAction(self.OnSimpleRenderTabListItem)
	self.bindData.tabList.luaSelectedChanged = self:CreateAction(self.OnSimpleClickTabList)
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction(self.OnRenderContentListItem)
	self.bindData.contentList.luaSimpleDynamicRenderItem = self:CreateAction(self.OnRenderContentListItem)
	self.bindData.contentList.luaLayoutSet = self:CreateAction(self.OnContentListLayoutSet)
	self.cfg = nil
	self.resources = {}
	self.tabList = WebPageConfig.YowoVideoTabNames
end

function M:OnShow(panelId, data)
	self.bindData.tabList:SetSimpleList(2)
	self:RefreshPage()
	self.bindData.tabList:SelectItem(0)
end

function M:RefreshPage()
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

	gMessageManager:SendMessage(gEventConstants.WEBSITE_HOVER_CHANGE, resourceId ~= nil)
end

function M:OnHoverChange(content)
	local resourceId = self.mgr:GetCurrentParam("ResourceId")

	if resourceId then
		content.resourceId = resourceId
	end
end

function M:OnClose()
	return
end

function M:OnSimpleRenderTabListItem(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	store.label = self.tabList[index + 1]
end

function M:OnSimpleClickTabList(list)
	local index = list.selectedIndex

	if index == 0 then
		self.resources = self.cfg.Resources
	else
		self.resources = self.cfg.StarResources
	end

	self.bindData.contentList:SetSimpleList(#self.resources)

	self.bindData.isEmpty = BOOL2CTL[#self.resources == 0]
end

function M:OnRenderContentListItem(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	store.resourceId = self.resources[index + 1]
end

function M:OnContentListLayoutSet()
	gMessageManager:SendMessage(gEventConstants.WEBSITE_LAYOUT_RESET)
end
