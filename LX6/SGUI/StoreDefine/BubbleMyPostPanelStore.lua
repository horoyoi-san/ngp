-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BubbleMyPostPanelStore.lua
-- Decompiled from: 02007_BubbleMyPostPanelStore.lua_7dd7b963ad9a.luajit

C_BubbleMyPostPanelStore = DefClass("C_BubbleMyPostPanelStore", C_BubbleMyPostPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.BubbleMyPostPanelStore = C_BubbleMyPostPanelStore
local M = C_BubbleMyPostPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction(self.OnRenderDynamicItem)
	self.bindData.contentList.luaSimpleClick = self:CreateAction(self.OnClickDynamicItem)
	self.bindData.contentList.luaLayoutSet = self:CreateAction(self.OnLayoutSet)
	self.post = {}
	self.layoutSet = false
	self.mgr = self.mgr or gNewBubbleMgr
end

M.InitView = function(self, data)
	self.mgr:OnRenderBubbleCommonAvatar(self.bindData.headAvatar, 0)

	if data and data.panelId then
		self.RefreshPage(self)
	end
end

M.OnGroupEnable = function(self)
end

M.RefreshPage = function(self)
	self.postList = self.mgr:GetAllPostList(true)

	self.bindData.contentList:SetSimpleList(#self.postList)

	self.layoutSet = false
	self.bindData.isEmpty = BOOL2CTL[#self.postList ~= 0]
end

M.OnRenderDynamicItem = function(self, btn, index)
	local data = self.postList[index + 1]

	self.mgr:OnRenderDynamicItem(btn, data)
end

M.OnClickDynamicItem = function(self, btn, index)
	local data = self.postList[index + 1]

	self.mgr:OpenDetailPanel(data)
end

M.OnLayoutSet = function(self)
	if self.layoutSet then
		return
	end

	self.layoutSet = true

	self.bindData.contentList:SetNavSelectToTop()
end
