-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BubbleBasePanelStore.lua
-- Decompiled from: 02106_BubbleBasePanelStore.lua_bf62174fca63.luajit

local SocialMediaTabConfig = LTConfig.SocialMediaTabConfig
local showBackBtnType = LTConfig.SocialMediaTabConfig.showBackBtnType
local PopupConfig = LTConfig.PopupConfig
C_BubbleBasePanelStore = DefClass("C_BubbleBasePanelStore", C_BubbleBasePanelStore, C_PhoneAppBaseStackStoreGroup)
GroupName2Class.BubbleBasePanelStore = C_BubbleBasePanelStore
local M = C_BubbleBasePanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.OnAwake = function(self)
	self.mgr = gNewBubbleMgr
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnRenderTab)
	self.bindData.backGround.luaClick = self.CreateAction(self, self.OnExit)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnBackBtnClick)
	self.bindData.innerBackBtn.luaClick = self.CreateAction(self, self.OnBackBtnClick)
	self.bindData.homeBtn.luaClick = self.CreateActionWithArgs(self, self.OnSelectedTab, SocialMediaTabConfig.Home)
	self.bindData.postBtn.luaClick = self.CreateActionWithArgs(self, self.OnSelectedTab, SocialMediaTabConfig.Post)
	self.bindData.vNaviBtn.luaClick = self.CreateAction(self, self.OnStep)
	self.currentTabStore = nil
	self.currentTab = 0
	self.currentWidget = nil
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)
	gHunLunManager:InitPersonalInfo()
	self.mgr:AskPostList()
end

M.OnGroupEnable = function(self)
	self.RefreshPage(self)
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.BUBBLE_REFRESH_PAGE] = self.CreateAction(self, self.RefreshPage),
		[gEventConstants.BUBBLE_REFRESH_SUB_CONTENT] = self.CreateAction(self, self.RefreshSubContent),
		[gEventConstants.NPC_FAVOR_CHANGE] = self.CreateAction(self, self.OnFavorChange)
	}
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

M.GetShowTypeField = function(self)
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end

M.OnRenderTab = function(self, index, widget)
	local showType = index
	local stackInfo = self.stackPanel:Peek()

	if self:GetShowType(stackInfo) ~= showType then
		if self.currentTabStore and self.currentTabStore.OnClose then
			self.currentTabStore:OnClose()
		end

		local store = gStoreManager:GetStoreGroup(widget.Store)
		self.currentTabStore = store

		store:ShowPanel(stackInfo)

		self.currentWidget = widget
		self.currentTab = stackInfo.secondShowType + 1 or 1

		self:RefreshPage()
	end
end

M.OnExit = function(self)
	M.base.PlayCloseAnimation(self)
	self.OnExecuteExitAction(self)
	self.ClearStoreGroupData(self)
end

M.CloseAll = function(self)
	self.stackPanel:Clear()
	self:OnExit()
end

M.RefreshPage = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	if self.currentTabStore and self.currentTabStore.RefreshPage then
		self.currentTabStore:RefreshPage()
	end

	self.RefreshBottom(self)
end

M.RefreshSubContent = function(self, _, data)
	if not self.STATE_EnableOnce then
		return
	end

	if self.currentTabStore and self.currentTabStore.RefreshSubContent then
		self.currentTabStore:RefreshSubContent(data)
	end
end

M.RefreshBottom = function(self)
	local hasBottom = false

	for i = 0, SocialMediaTabConfig.count - 1 do
		local cfg = SocialMediaTabConfig.LoadAt(i)

		if string.is_null_or_empty(cfg.bottomBtn) then
			-- Nothing
		end

		local btn = self.bindData[cfg.bottomBtn]

		if btn then
			btn.isSelected = self.currentTab ~= cfg.Id

			if btn.isSelected then
				hasBottom = true
			end
		end
	end

	self.bindData.showBottom = BOOL2CTL[hasBottom]
	local cfg = SocialMediaTabConfig.GetConfig(self.currentTab)
	local showBackBtn = false

	if cfg and cfg.showBackBtn == showBackBtnType.None then
		self.bindData.backBtnColor = cfg.showBackBtn
		showBackBtn = true
	end

	self.bindData.showBackBtn = BOOL2CTL[showBackBtn]
end

M.OnSelectedTab = function(self, index)
	self.mgr:SwitchCurrentPanel({
		secondShowType = index
	})
end

M.OnStep = function(self)
	local cfg = SocialMediaTabConfig.GetConfig(self.currentTab)

	if not cfg then
		return
	end

	self.OnSelectedTab(self, cfg.NextTab)
end

M.OnFavorChange = function(self, _, faverInfo)
	self.popupStore = gStoreManager:GetStoreGroup(self.bindData.popup.Store):GetStoreByWidget(self.bindData.popup)

	gPopupAreaFiveDataRefresh:RefreshFriendShipChange(self.popupStore, {
		Param = faverInfo
	})

	self.bindData.showFavorChange = BOOL2CTL[true]

	Timer.New(function ()
		self.bindData.showFavorChange = BOOL2CTL[false]
	end, PopupConfig.PoiAreaPopUpShowTime):Start()
end

M.OnBackBtnClick = function(self)
	if self.currentTabStore and self.currentTabStore.OnBackBtnClick then
		self.currentTabStore:OnBackBtnClick()

		return
	end

	if self.bindData.showBackBtn ~= BOOL2CTL[true] then
		self.mgr:ExitCurrentPanel()
	else
		self.OnExit(self)
	end
end
