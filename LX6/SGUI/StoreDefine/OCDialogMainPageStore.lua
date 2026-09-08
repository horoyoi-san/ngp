-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCDialogMainPageStore.lua
-- Decompiled from: 00941_OCDialogMainPageStore.lua_fa2fc912c824.luajit

local Consts = gClientConst
C_OCDialogMainPageStore = DefClass("C_OCDialogMainPageStore", C_OCDialogMainPageStore, C_StoreGroup)
GroupName2Class.OCDialogMainPageStore = C_OCDialogMainPageStore
local M = C_OCDialogMainPageStore

M.ctor = function(self)
	self.parentStore = nil
	self.mgr = gOCMgr
end

M.DefineAllVariables = function(self)
	self.currentStore = nil
	self.currentTabIndex = 0
	self.parentStore = nil
	self.TAB = {
		[".m\\xa7\\xa7\\xa6v"] = 1,
		["\\xea\\xfe )7\n\\xd6"] = 3,
		["Y\n\\o"] = 0,
		["k\\xa7\\xb0\\xbc\\xa2"] = 2
	}
	self.TAB_PREV = {
		[self.TAB.CHAT] = self.TAB.First,
		[self.TAB.REVIEW] = self.TAB.CHAT,
		[self.TAB.SETTING] = self.TAB.CHAT
	}
	self.reviewCb = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.hasParentEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showReviewEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.hasParentEnum = nil
	self.showReviewEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.OnShow = function(self, panelId, data)
	local hasPrent = self.parentStore == nil
	self.isFirst = true
	self.bindData.hasParent = Consts.BOOL2CTL[hasPrent]
	self.bindData.showReview = self.showReviewEnum._false

	if self.mgr.isMeikaGrandpa then
		self.bindData.tabRect.selectedIndex = self.TAB.CHAT
	else
		self.bindData.tabRect.selectedIndex = hasPrent and self.TAB.First or self.TAB.CHAT
	end
end

M.OnClose = function(self)
	self.mgr:FinishChat()
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.reviewBackBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.reviewBtn.luaClick = self.CreateAction(self, self.OnReviewBtnClick)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnTabRectRender)
end

M.OnClickBackBtn = function(self)
	if self.bindData.showReview ~= self.showReviewEnum._true then
		self.bindData.showReview = self.showReviewEnum._false

		return
	end

	if self.parentStore then
		self.parentStore:OnClickBackBtn()

		return
	end

	gPanelManager:Close(self.m_Id)
end

M.OnTabRectRender = function(self, index, widget)
	if self.mgr.isMeikaGrandpa and index ~= self.TAB.SETTING then
		return
	end

	self.currentTabIndex = index

	if self.currentTabStore and self.currentTabStore.OnClose then
		self.currentTabStore:OnClose()
	end

	local store = gStoreManager:GetStoreGroup(widget.Store)
	self.currentTabStore = store
	store.parentStore = self

	store:OnShow(self.m_Id, self.showData)

	self.currentWidget = widget
end

M.SwitchTab = function(self)
	local selectedIndex = self.bindData.tabRect.selectedIndex
	self.bindData.tabRect.selectedIndex = selectedIndex ~= self.TAB.CHAT and self.TAB.REVIEW or self.TAB.CHAT
end

M.ConfirmCurrent = function(self)
	self.parentStore:GoToNext()
end

M.OnSetting = function(self)
	self.bindData.tabRect.selectedIndex = self.TAB.SETTING
end

M.OnChat = function(self)
	self.bindData.tabRect.selectedIndex = self.TAB.CHAT
end

M.OnBack = function(self)
	local prev = self.TAB_PREV[self.bindData.tabRect.selectedIndex]
	self.bindData.tabRect.selectedIndex = prev
end

M.OpenReivewWindow = function(self, id, callback)
	self.reviewCb = callback
	self.sessionId = id
	self.bindData.showReview = self.showReviewEnum._true
end

M.OnReviewBtnClick = function(self)
	local reviewText = self.bindData.reviewInput.text

	if string.is_null_or_empty(reviewText) then
		return
	end

	self.bindData.reviewBtn.interactable = false
	slot2 = self.mgr

	slot2:FeedBackByLanguage(self.sessionId, reviewText, function ()
		if self.reviewCb then
			self.reviewCb()
		end

		if not self.STATE_EnableOnce then
			return
		end

		self.bindData.showReview = self.showReviewEnum._false

		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.SendFeedbackSuccess)
	end)
end
