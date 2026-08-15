local UNavigationMgr = SGUI.UNavigationMgr
C_YanjieNewHomePagePanel = DefClass("C_YanjieNewHomePagePanel", C_YanjieNewHomePagePanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieNewHomePagePanel = C_YanjieNewHomePagePanel
local M = C_YanjieNewHomePagePanel
local TabControl = {
	Recommend = 0,
	Follow = 1
}

function M:OnAwake()
	self.bindData.recommendTab.luaClick = self:CreateActionWithArgs(self.OnTabChange, TabControl.Recommend)
	self.bindData.followTab.luaClick = self:CreateActionWithArgs(self.OnTabChange, TabControl.Follow)
	self.bindData.searchButton.luaClick = self:CreateAction(self.OnSearchClick)
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.walletButton.luaClick = self:CreateAction(self.OnWalletClick)
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_PLAYER_INFO] = function (_, args)
			self.playerInfo = args
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_TREAD_LIST] = function (_, info)
			self.trendData = info
		end,
		[gEventConstants.ON_LEVEL_REWARD_UPDATE] = self:CreateAction("RefreshAvatarView"),
		[gEventConstants.ON_PLAYER_FAN_CHANGE] = self:CreateAction("RefreshAvatarView"),
		[gEventConstants.ON_YANJIE_TOTAL_LEFT_MONEY_CHANGE] = self:CreateAction("RefreshAvatarView"),
		[gEventConstants.ON_YANJIE_NEW_SEARCH_PANEL_CLOSE] = self:CreateAction("OnSearchClose"),
		[gEventConstants.ON_YAN_JIE_SEARCH_RESULT_SHOW] = self:CreateAction("OnSearchResultShow"),
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_FOLLOW] = function ()
			self.needRefreshFollowList = true
		end
	}
end

function M:PlayPanelAnimation()
	return
end

function M:InitModel(args)
	M.base.InitModel(self, args)
	gSocialNetworkUtils.AskTwitterPageOpen(UX.Game.TwitterPageType.HomePage)

	self.needRefreshFollowList = true

	gSocialNetworkUtils.GetPlayerInfo()
	gSocialNetworkUtils.GetTrendList(1, 10)
end

function M:InitView(_)
	self.recommendList = self.SubGroup.CommonYanjieListTemplate_1
	self.recommendList.itemClickCallback = self:CreateAction(self.PlayToSearchOrDetailAnimation)
	self.followList = self.SubGroup.CommonYanjieListTemplate_2
	self.followList.itemClickCallback = self:CreateAction(self.PlayToSearchOrDetailAnimation)
	self.recommendList.GetList = gSocialNetworkUtils.GetRecommendList
	self.followList.GetList = gSocialNetworkUtils.GetFollowList

	self:RefreshAvatarView()
	self.recommendList:StartRequest()
	self:OnTabChange(TabControl.Recommend)

	self.bindData.searchActive = false
	local fansSystemUnlocked = gMainPhoneUtils.CheckFansSystemUnlocked()
	self.bindData.headAvatarControl = fansSystemUnlocked and 1 or 0
	local recordPreFan = gSocialNetworkUtils.recordPreFan
	local fansCount = gClientUtils.GetPlayerCurrentExp()

	if recordPreFan then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.scrollAnimation, "S_Vx_YanjieHomePagePanel_ShowFansChange")
		gClientUtils.ShowCommonScrollNumber(self.bindData.scrollNumberWidget, recordPreFan, fansCount)
		gSocialNetworkUtils:ClearFansChangeRecord()
	else
		gClientUtils.ShowCommonScrollNumber(self.bindData.scrollNumberWidget, fansCount, fansCount)
	end
end

function M:OnSearchClose()
	self.bindData.searchActive = false
	self.bindData.tabActive = true
	self.bindData.followActive = self.bindData.tabCtrl == TabControl.Follow
	self.bindData.recommendActive = self.bindData.tabCtrl == TabControl.Recommend
	UNavigationMgr.Inst.CurrentActiveArea = self.bindData.homeNavigationArea
end

function M:OnSearchResultShow()
	self.bindData.followActive = false
	self.bindData.recommendActive = false
end

function M:RefreshAvatarView()
	local playerAvatar = self.bindData.playerAvatar
	local playerAvatarStore = gStoreManager:GetStoreGroup(playerAvatar.Store):GetStoreByWidget(playerAvatar)
	playerAvatarStore.headIcon = gSocialNetworkUtils.GetPlayerSGuiAvatarId()
	playerAvatarStore.button.luaClick = self:CreateAction("OnPlayerAvatarClick")
	local redDotKey = "YanJieHomePageLevelReward"
	playerAvatarStore.button.redKey = redDotKey
	local hasRedDot = gClientUtils.CheckHasLevelReward()

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)
	self:RefreshMoneyView()
end

function M:RefreshMoneyView()
	local moneyShowWidget = self.bindData.moneyShowWidget
	local moneyShowStore = gStoreManager:GetStoreGroup(moneyShowWidget.Store):GetStoreByWidget(moneyShowWidget)
	moneyShowStore.count = gSocialNetworkUtils.GetTotalLeftMoney()
	local templateId = LTConfig.TuiteConfig.EyeCoinConsumableId
	local consumableCfg = LTConfig.ConsumableConfig.GetConfig(templateId)
	moneyShowStore.imageIcon = consumableCfg.SMoneyIconId
	moneyShowStore.iconButton.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTips", {
		TemplateId = templateId
	}, gCommonItemManager)
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end

function M:OnTabChange(tabCtrl)
	if self.bindData.tabCtrl == tabCtrl then
		return
	end

	local nextNavigationContent = nil

	if tabCtrl == TabControl.Recommend then
		self.bindData.selectAnimation:Play("S_Vx_Yanjie_Tab2")

		self.bindData.followActive = false
		self.bindData.recommendActive = true
		self.followList.nextNavigationContent = SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent
		nextNavigationContent = self.recommendList.nextNavigationContent
	else
		self.bindData.selectAnimation:Play("S_Vx_Yanjie_Tab1")

		self.bindData.recommendActive = false
		self.bindData.followActive = true
		self.recommendList.nextNavigationContent = SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent
		nextNavigationContent = self.followList.nextNavigationContent
	end

	self.bindData.tabCtrl = tabCtrl
	self.bindData.recommendTab.isSelected = tabCtrl == TabControl.Recommend
	self.bindData.followTab.isSelected = tabCtrl == TabControl.Follow

	if tabCtrl == TabControl.Follow and self.needRefreshFollowList then
		self.needRefreshFollowList = nil

		self.followList:ClearAndRefreshData()
	end

	if gClientUtils.NotNil(nextNavigationContent) then
		local function frameTimerFunc()
			if gClientUtils.NotNil(nextNavigationContent) then
				SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = nextNavigationContent
			end
		end

		FrameTimer.New(frameTimerFunc, 1):Start()
	end
end

function M:OnSearchClick()
	self.bindData.searchActive = true
	self.bindData.tabActive = false

	self.SubGroup.YanjieNewSearchPanel:ShowPanel({
		secondShowType = gClientConst.YanJieShowType.Search,
		trendData = self.trendData,
		momentList = self.SubGroup.CommonYanjieListTemplate_3
	})
end

function M:PlayToSearchOrDetailAnimation()
	return
end

function M:OnPlayerAvatarClick()
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_SHOW, {
		secondShowType = gClientConst.YanJieShowType.Mine,
		playerInfo = self.playerInfo
	})
end

function M:OnWalletClick()
	gPanelManager:CheckShow(gPanelId.YANJIE_WITHDRAW_CASH)
end

function M:OnExitClick()
	if self.bindData.searchActive then
		self.SubGroup.YanjieNewSearchPanel:OnExitClick()

		self.bindData.searchActive = false
		self.bindData.tabActive = true

		return
	end

	M.base.OnExitClick(self)
end

function M:ClearData()
	self.trendData = nil
end
