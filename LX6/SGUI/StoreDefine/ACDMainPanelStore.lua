-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ACDMainPanelStore.lua
-- Decompiled from: 01589_ACDMainPanelStore.lua_d8a47725b28c.luajit

local AnimMgr = SGUI.AnimMgr
C_ACDMainPanelStore = DefClass("C_ACDMainPanelStore", C_ACDMainPanelStore, C_StoreGroup)
GroupName2Class.ACDMainPanelStore = C_ACDMainPanelStore
local M = C_ACDMainPanelStore

M.ctor = function(self)
	self.mgr = gWebManager
	self.currentScrollRect = nil
	self.sections = {}
	self.newsId = nil
	self.TAB_ANI_NAME = "ACD_MAIN_TAB_ANIM"
	self.TOTAL_ANI_TIME = 0.5
	self.tabBtnList = nil
end

M.OnAwake = function(self)
	self.currentScrollRect = self.bindData.ScrollRect
	self.bindData.TopBarNavigationList.luaSimpleRenderItem = self:CreateAction(self.OnSimpleRenderTopBarNavigationListItem)
	self.bindData.TopBarNavigationList.luaSimpleClick = self:CreateAction(self.OnSimpleClickTopBarNavigationList)
	self.onScrollRectScrollCb = self:CreateAction(self.OnScrollRectScroll)

	self.bindData.ScrollRect:RegisterToScrollEvent(self.onScrollRectScrollCb)
	self.bindData.ScrollRect2:RegisterToScrollEvent(self.onScrollRectScrollCb)

	self.currentSectionIdx = 1
end

M.RefreshPage = function(self)
	local newsId = self.mgr:GetCurrentParam("news")

	if not newsId then
		self.currentScrollRect = self.bindData.ScrollRect
		self.bindData.topBarCtl = 0
		self.newsId = nil
	else
		self.currentScrollRect = self.bindData.ScrollRect2
		self.bindData.topBarCtl = 1
		self.newsId = newsId
	end

	local store = gStoreManager:GetStoreGroup(self.currentScrollRect.content.Store)

	if not store then
		return
	end

	store.RefreshPage(store, newsId)

	if not self.newsId and store.GetSections then
		self.sections = store.GetSections(store)
	end

	self.tabBtnList = {}

	self.bindData.TopBarNavigationList:SetSimpleList(#self.sections)
end

M.OnShow = function(self, panelId, data)
	self.RefreshPage(self)
end

M.OnClose = function(self)
end

M.OnSimpleRenderTopBarNavigationListItem = function(self, btn, index)
	if self.newsId then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.name = self.sections[index + 1].name
	self.tabBtnList[index + 1] = btn
end

M.OnSimpleClickTopBarNavigationList = function(self, btn, index)
	if self.newsId then
		return
	end

	self.GoToSection(self, index + 1)
end

M.OnScrollRectScroll = function(self, delta)
	local npos = 1 - delta.y

	if npos >= 0.0001 then
		npos = 0
	end

	if self.showReturnTopBtnFunc then
		self.showReturnTopBtnFunc(npos == 0)
	end

	if self.newsId then
		return
	end

	local store = gStoreManager:GetStoreGroup(self.currentScrollRect.content.Store)
	local pos_y = npos * store:GetPageSizeY()
	local sectionIdx = self:GetSectionIdxByPos(pos_y)

	if sectionIdx == self.currentSectionIdx then
		self.currentSectionIdx = sectionIdx

		self.PlayTabAnim(self, sectionIdx)
	end
end

M.GoToSection = function(self, index)
	if not self.currentScrollRect then
		return
	end

	self.bindData.TopBarNavigationList:SelectItem(index, false)

	self.currentSectionIdx = index

	self.currentScrollRect:GoToPos(Vector2.New(0, self.sections[index].pos), true)
	self:PlayTabAnim(index)
end

M.GetSectionIdxByPos = function(self, pos)
	for i, v in ipairs(self.sections) do
		if pos >= v.pos then
			if i < 1 then
				return 1
			else
				return i - 1
			end
		end
	end

	return #self.sections
end

M.PlayTabAnim = function(self, idx)
	local targetBtn = self.tabBtnList[idx]

	if not targetBtn then
		return
	end

	AnimMgr.Kill(self.bindData.selectedMoveBar, self.TAB_ANI_NAME)
	AnimMgr.Move(self.bindData.selectedMoveBar, self.TAB_ANI_NAME, self.GetTargetPosition(self, targetBtn), self.TOTAL_ANI_TIME, 0, DG.Tweening.Ease.OutCubic, nil)
end

M.GetTargetPosition = function(self, targetBtn)
	local targetPos = self.bindData.TopBarNavigationList.rectTransform:InverseTransformPoint(targetBtn.position)
	targetPos.y = self.bindData.selectedMoveBar.anchoredPosition.y

	return targetPos
end

M.CanReturnTop = function(self, showFunc)
	self.showReturnTopBtnFunc = showFunc

	return false
end

M.OnReturnTop = function(self)
	local TopIndex = 1

	self:GoToSection(TopIndex)
	self.currentScrollRect:GoToPos(Vector2.zero, true)
end
