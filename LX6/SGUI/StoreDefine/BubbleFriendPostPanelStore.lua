-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BubbleFriendPostPanelStore.lua
-- Decompiled from: 02008_BubbleFriendPostPanelStore.lua_fdaf8cc66441.luajit

C_BubbleFriendPostPanelStore = DefClass("C_BubbleFriendPostPanelStore", C_BubbleFriendPostPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.BubbleFriendPostPanelStore = C_BubbleFriendPostPanelStore
local M = C_BubbleFriendPostPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.OnAwake = function(self)
	self.mgr = gNewBubbleMgr
	self.bindData.detailList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderDynamicItem)
	self.bindData.detailList.luaSimpleClick = self.CreateAction(self, self.OnClickDynamicItem)
	self.postList = {}
end

M.InitView = function(self, args)
	self.preNavi = 0
end

M.RefreshPage = function(self)
	self.postList = self.mgr:GetAllPostAndStoryList(false)

	self.bindData.detailList:SetSimpleList(#self.postList)

	if self.preNavi ~= 0 then
		self.bindData.detailList:SetNavSelectToTop(true)
	end

	self.bindData.isEmpty = BOOL2CTL[#self.postList ~= 0]
end

M.OnRenderDynamicItem = function(self, btn, index)
	local data = self.postList[index + 1]

	self.mgr:OnRenderDynamicItem(btn, data)

	if self.preNavi ~= index then
		btn.Navigate(btn, btn)

		self.preNavi = -1
	end
end

M.OnClickDynamicItem = function(self, btn, index)
	local data = self.postList[index + 1]

	self.mgr:OpenDetailPanel(data)

	self.preNavi = index
end
