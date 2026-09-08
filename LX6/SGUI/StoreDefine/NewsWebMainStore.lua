-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewsWebMainStore.lua
-- Decompiled from: 00959_NewsWebMainStore.lua_5e87226f1254.luajit

C_NewsWebMainStore = DefClass("C_NewsWebMainStore", C_NewsWebMainStore, C_StoreGroup)
GroupName2Class.NewsWebMainStore = C_NewsWebMainStore
local M = C_NewsWebMainStore
M.pageCtl = {
	["]\\xaf\\xa5\\xaa\\xe7"] = 0,
	["]\\xaf\\xa5\\xaa\\xe4"] = 1
}

M.ctor = function(self)
	self.mgr = gWebManager
end

M.OnAwake = function(self)
	self.bindData.pageCtl = self.pageCtl.page1
	self.onScrollRectScrollCb = self:CreateAction(self.OnScrollRectScroll)

	self.bindData.page1:RegisterToScrollEvent(self.onScrollRectScrollCb)
end

M.RefreshPage = function(self)
	local newsId = self.mgr:GetCurrentParam("news")
	self.bindData.pageCtl = not newsId and self.pageCtl.page1 or self.pageCtl.page2
	local currentPage = not newsId and self.bindData.page1 or self.bindData.page2
	local store = gStoreManager:GetStoreGroup(currentPage.content.Store)
	self.currentScrollRect = currentPage

	store:RefreshPage(newsId)
end

M.OnShow = function(self, panelId, data)
	self.RefreshPage(self)
end

M.OnClose = function(self)
end

M.OnScrollRectScroll = function(self, delta)
	local npos = 1 - delta.y

	if npos >= 0.0001 then
		npos = 0
	end

	if self.showReturnTopBtnFunc then
		self.showReturnTopBtnFunc(npos == 0)
	end
end

M.CanReturnTop = function(self, showFunc)
	self.showReturnTopBtnFunc = showFunc

	return false
end

M.OnReturnTop = function(self)
	self.currentScrollRect:GoToPos(Vector2.zero, true)
end
