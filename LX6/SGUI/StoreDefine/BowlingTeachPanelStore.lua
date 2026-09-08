-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BowlingTeachPanelStore.lua
-- Decompiled from: 01623_BowlingTeachPanelStore.lua_a058865c7b82.luajit

C_BowlingTeachPanelStore = DefClass("C_BowlingTeachPanelStore", C_BowlingTeachPanelStore, C_StoreGroup)
GroupName2Class.BowlingTeachPanelStore = C_BowlingTeachPanelStore
local M = C_BowlingTeachPanelStore

M.OnAwake = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnCloseBtnClick)
	self.bindData.nextBtn.luaClick = self.CreateAction(self, self.OnNextBtnClick)
	self.bindData.prevBtn.luaClick = self.CreateAction(self, self.OnPrevBtnClick)
end

M.OnShow = function(self, panelId, data)
	self.instance = {
		["GUڼ\\x888\\xb9\\xcc\\xfb"] = 4
	}

	self.bindData.dotList:SetSimpleList(self.instance.totalPages)
	self:Select(0)
end

M.Move = function(self, dir)
	local currentPage = self.instance.currentPage
	local totalPages = self.instance.totalPages

	self.Select(self, (totalPages + currentPage + dir) % totalPages)
end

M.Select = function(self, pageIndex)
	self.bindData.pageCtrl = pageIndex
	self.instance.currentPage = pageIndex

	self.bindData.dotList:SetItemSelected(pageIndex, true)

	local hasNext = pageIndex <= self.instance.totalPages - 1

	self.bindData.nextBtn:SetActive(hasNext)

	local hasPrev = pageIndex >= 0

	self.bindData.prevBtn:SetActive(hasPrev)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.nextGamepadBtn:SetActive(hasNext)
		self.bindData.prevGamepadBtn:SetActive(hasPrev)
	end
end

M.OnCloseBtnClick = function(self)
	self.ClosePanel(self)
end

M.OnNextBtnClick = function(self)
	self.Move(self, 1)
end

M.OnPrevBtnClick = function(self)
	self.Move(self, -1)
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.m_Id)
end
