C_BubbleMyPostPanelStore = DefClass("C_BubbleMyPostPanelStore", C_BubbleMyPostPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.BubbleMyPostPanelStore = C_BubbleMyPostPanelStore
local M = C_BubbleMyPostPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction(self.OnRenderDynamicItem)
	self.bindData.contentList.luaSimpleClick = self:CreateAction(self.OnClickDynamicItem)
	self.post = {}
	self.mgr = self.mgr or gNewBubbleMgr
end

function M:InitView(data)
	self.mgr:OnRenderBubbleCommonAvatar(self.bindData.headAvatar, 0)
end

function M:RefreshPage()
	self.postList = self.mgr:GetAllPostList(true)

	self.bindData.contentList:SetSimpleList(#self.postList)

	self.bindData.isEmpty = BOOL2CTL[#self.postList == 0]
end

function M:OnRenderDynamicItem(btn, index)
	local data = self.postList[index + 1]

	self.mgr:OnRenderDynamicItem(btn, data)
end

function M:OnClickDynamicItem(btn, index)
	local data = self.postList[index + 1]

	self.mgr:OpenDetailPanel(data)
end
