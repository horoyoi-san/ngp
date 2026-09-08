-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SaturnHomeWebpageStore.lua
-- Decompiled from: 01975_SaturnHomeWebpageStore.lua_7dc371aa4238.luajit

C_SaturnHomeWebpageStore = DefClass("C_SaturnHomeWebpageStore", C_SaturnHomeWebpageStore, C_SaturnWebpagePanelBase)
GroupName2Class.SaturnHomeWebpageStore = C_SaturnHomeWebpageStore
local M = C_SaturnHomeWebpageStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
M.NavBarCtl = {
	["R+y^"] = 0,
	["I*rL"] = 1
}
M.ShowScrollTipCtl = {
	["R+y^"] = 0,
	["I*rL"] = 1
}

M.ctor = function(self)
	self.positions = nil
	self.bAutoScrolling = false
	self.prevScrollPos = nil
end

M.OnAwake = function(self)
	self:InitNavBindData(self.bindData.nav, self.bindData.navbar)

	self.onScrollRectScrollCb = self:CreateAction(self.OnScrollRectScroll)
	self.onScrollRectScrollEndCb = self:CreateAction(self.OnScrollRectScrollEnd)

	self.bindData.scrollrect:RegisterToScrollEvent(self.onScrollRectScrollCb)
	self.bindData.scrollrect:RegisterToScrollEndEvent(self.onScrollRectScrollEndCb)

	self.bindData.btnGoHome.luaClick = self:CreateAction(self.OnGoHomeBtnClick)
end

M.RefreshPage = function(self)
	self:LoadNavData()

	local store = gStoreManager:GetStoreGroup(self.bindData.scrollrect.content.Store)

	if not store then
		return
	end

	store.RefreshPage(store)

	self.positions = store.GetPagePositions(store)

	self.SetNavPagePositions(self, self.positions)
	self.RenderNavList(self)

	self.bindData.showScrollTipCtrl = self.ShowScrollTipCtl.Show
	self.currIdx = 1
	self.bindData.showTopLogoCtrl = BOOL2CTL[false]
end

M.OnShow = function(self, panelId, data)
	self.RefreshPage(self)
end

M.OnScrollRectScroll = function(self, delta)
	local store = gStoreManager:GetStoreGroup(self.bindData.scrollrect.content.Store)
	local npos = 1 - delta.y

	if npos >= 0.0001 then
		npos = 0
	end

	if npos <= 0.99 then
		npos = 1
	end

	if self.showReturnTopBtnFunc then
		self.showReturnTopBtnFunc(npos == 0)
	end

	self.bindData.showScrollTipCtrl = npos ~= 1 and self.ShowScrollTipCtl.Hide or self.ShowScrollTipCtl.Show
	local pos_y = npos * store:GetPageSizeY()

	if not self.bAutoScrolling and self.prevScrollPos then
		local dpos = npos - self.prevScrollPos

		if dpos <= 0 then
			self.currIdx = self.currIdx + 1

			if self.currIdx <= #self.positions then
				self.currIdx = #self.positions
			end
		else
			self.currIdx = self.currIdx - 1

			if self.currIdx >= 1 then
				self.currIdx = 1
			end
		end

		self.bindData.scrollrect:GoToPos(Vector2.New(0, self.positions[self.currIdx]), false)

		self.bindData.scrollEventListener.enabled = false

		if self.parent then
			self.parent.bindData.scrollEventListener.enabled = false
		end

		self.bAutoScrolling = true
	end

	if self.positions and #self.positions <= 1 then
		self.bindData.showTopLogoCtrl = BOOL2CTL[self.positions[2] <= pos_y]
	end

	self.prevScrollPos = npos
end

M.OnScrollRectScrollEnd = function(self)
	if self.bAutoScrolling then
		self.bAutoScrolling = false
	end

	self.bindData.scrollEventListener.enabled = true

	if self.parent then
		self.parent.bindData.scrollEventListener.enabled = true
	end
end

M.OnScrollNavSection = function(self, idx, _)
end

M.OnClickNavSection = function(self, idx, url)
	if url then
		gWebManager:GoToTagetUrl(url)
	end
end

M.OnSetNavBarVisable = function(self, visable)
	self.bindData.navBarCtl = self.NavBarCtl.Hide
end

M.OnGoHomeBtnClick = function(self)
	self.bindData.scrollEventListener.enabled = false

	if self.parent then
		self.parent.bindData.scrollEventListener.enabled = false
	end

	self.bAutoScrolling = true

	self.bindData.scrollrect:GoToPos(Vector2.New(0, 0), true)
end

M.CanReturnTop = function(self, showFunc)
	self.showReturnTopBtnFunc = showFunc

	return false
end

M.OnReturnTop = function(self)
	self.OnGoHomeBtnClick(self)
end
