local RedDotMgr = SGUI.RedDotMgr
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

function M:OnAwake()
	self.mgr = gNewBubbleMgr
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
	self.bindData.backGround.luaClick = self:CreateAction(self.OnExit)
	self.bindData.backBtn.luaClick = self:CreateAction(self.OnBackBtnClick)
	self.bindData.innerBackBtn.luaClick = self:CreateAction(self.OnBackBtnClick)
	self.bindData.homeBtn.luaClick = self:CreateActionWithArgs(self.OnSelectedTab, SocialMediaTabConfig.Home)
	self.bindData.postBtn.luaClick = self:CreateActionWithArgs(self.OnSelectedTab, SocialMediaTabConfig.Post)
	self.bindData.mineBtn.luaClick = self:CreateActionWithArgs(self.OnSelectedTab, SocialMediaTabConfig.Personal)
	self.bindData.vNaviBtn.luaClick = self:CreateAction(self.OnStep)
	self.currentTabStore = nil
	self.currentTab = 0
	self.currentWidget = nil
end

function M:InitModel(args)
	M.base.InitModel(self, args)
	gHunLunManager:InitPersonalInfo()
	self.mgr:AskPostList()
end

function M:GetMessageEvents()
	return {
		[gEventConstants.BUBBLE_REFRESH_PAGE] = self:CreateAction(self.RefreshPage),
		[gEventConstants.BUBBLE_REFRESH_SUB_CONTENT] = self:CreateAction(self.RefreshSubContent),
		[gEventConstants.NPC_FAVOR_CHANGE] = self:CreateAction(self.OnFavorChange)
	}
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_CONTENT_CLOSE)
end

function M:GetShowTypeField()
	return gClientConst.PhoneAppShowTypeLevel.SecondLevel
end

function M:OnRenderTab(index, widget)
	local showType = index
	local stackInfo = self.stackPanel:Peek()

	if self:GetShowType(stackInfo) == showType then
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

function M:OnExit()
	M.base.PlayCloseAnimation(self)
	self:OnExecuteExitAction()
	self:ClearStoreGroupData()
end

function M:CloseAll()
	self.stackPanel:Clear()
	self:OnExit()
end

function M:RefreshPage()
	if not self.STATE_EnableOnce then
		return
	end

	if self.currentTabStore and self.currentTabStore.RefreshPage then
		self.currentTabStore:RefreshPage()
	end

	self:RefreshBottom()
end

function M:RefreshSubContent(_, data)
	if not self.STATE_EnableOnce then
		return
	end

	if self.currentTabStore and self.currentTabStore.RefreshSubContent then
		self.currentTabStore:RefreshSubContent(data)
	end
end

function M:RefreshBottom()
	local hasBottom = false

	for i = 0, SocialMediaTabConfig.count - 1 do
		local cfg = SocialMediaTabConfig.LoadAt(i)

		if string.is_null_or_empty(cfg.bottomBtn) then
			-- Nothing
		end

		local btn = self.bindData[cfg.bottomBtn]

		if btn then
			btn.isSelected = self.currentTab == cfg.Id

			if btn.isSelected then
				hasBottom = true
			end
		end
	end

	self.bindData.showBottom = BOOL2CTL[hasBottom]
	local cfg = SocialMediaTabConfig.GetConfig(self.currentTab)
	local showBackBtn = false

	if cfg and cfg.showBackBtn ~= showBackBtnType.None then
		self.bindData.backBtnColor = cfg.showBackBtn
		showBackBtn = true
	end

	self.bindData.showBackBtn = BOOL2CTL[showBackBtn]
end

function M:OnSelectedTab(index)
	self.mgr:SwitchCurrentPanel({
		secondShowType = index
	})
end

function M:OnStep()
	local cfg = SocialMediaTabConfig.GetConfig(self.currentTab)

	if not cfg then
		return
	end

	self:OnSelectedTab(cfg.NextTab)
end

function M:OnFavorChange(_, faverInfo)
	self.popupStore = gStoreManager:GetStoreGroup(self.bindData.popup.Store):GetStoreByWidget(self.bindData.popup)

	gPopupAreaFiveDataRefresh:RefreshFriendShipChange(self.popupStore, {
		Param = faverInfo
	})

	self.bindData.showFavorChange = BOOL2CTL[true]

	Timer.New(function ()
		self.bindData.showFavorChange = BOOL2CTL[false]
	end, PopupConfig.PoiAreaPopUpShowTime):Start()
end

function M:OnBackBtnClick()
	if self.bindData.showBackBtn == BOOL2CTL[true] then
		self.mgr:ExitCurrentPanel()
	else
		self:OnExit()
	end
end
