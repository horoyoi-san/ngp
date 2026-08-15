C_BubbleFriendPostPanelStore = DefClass("C_BubbleFriendPostPanelStore", C_BubbleFriendPostPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.BubbleFriendPostPanelStore = C_BubbleFriendPostPanelStore
local M = C_BubbleFriendPostPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:OnAwake()
	self.mgr = gNewBubbleMgr
	self.bindData.detailList.luaSimpleRenderItem = self:CreateAction(self.OnRenderDynamicItem)
	self.bindData.detailList.luaSimpleClick = self:CreateAction(self.OnClickDynamicItem)
	self.postList = {}
end

function M:InitView(args)
	self.preNavi = 0
end

function M:RefreshPage()
	self.postList = self.mgr:GetAllPostList(false)

	self.bindData.detailList:SetSimpleList(#self.postList)

	if self.preNavi == 0 then
		self.bindData.detailList:SetNavSelectToTop(true)
	end

	self.bindData.isEmpty = BOOL2CTL[#self.postList == 0]
end

function M:OnRenderDynamicItem(btn, index)
	local data = self.postList[index + 1]

	self.mgr:OnRenderDynamicItem(btn, data)

	if self.preNavi == index then
		btn:Navigate(btn)

		self.preNavi = -1
	end
end

function M:OnClickDynamicItem(btn, index)
	local data = self.postList[index + 1]

	self.mgr:OpenDetailPanel(data)

	self.preNavi = index
end
