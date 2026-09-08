-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieNewHomePagePanel.lua
-- Decompiled from: 01984_YanjieNewHomePagePanel.lua_1dbb83a63acb.luajit

local UNavigationMgr = SGUI.UNavigationMgr
C_YanjieNewHomePagePanel = DefClass("C_YanjieNewHomePagePanel", C_YanjieNewHomePagePanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieNewHomePagePanel = C_YanjieNewHomePagePanel
local M = C_YanjieNewHomePagePanel
local TabTypeMap = {
	["\\xfc\\xc36\\xf4"] = 1,
	["a\\xa1\\xa1\\xae\\xba"] = 2,
	["qBofC<"] = 0
}

M.OnAwake = function(self)
	self.bindData.searchButton.luaClick = self.CreateAction(self, "OnSearchClick")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.walletButton.luaClick = self.CreateAction(self, "OnWalletClick")
	self.bindData.switchViewButton.luaClick = self.CreateAction(self, "OnSwitchViewClick")
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_TREAD_LIST] = function (_, info)
			self.trendData = info
		end,
		[gEventConstants.ON_LEVEL_REWARD_UPDATE] = self.CreateAction(self, "RefreshAvatarView"),
		[gEventConstants.ON_PLAYER_FAN_CHANGE] = self.CreateAction(self, "RefreshAvatarView"),
		[gEventConstants.ON_YANJIE_TOTAL_LEFT_MONEY_CHANGE] = self.CreateAction(self, "RefreshAvatarView"),
		[gEventConstants.ON_YANJIE_NEW_SEARCH_PANEL_CLOSE] = self.CreateAction(self, "OnSearchClose"),
		[gEventConstants.ON_YAN_JIE_SEARCH_RESULT_SHOW] = self.CreateAction(self, "OnSearchResultShow"),
		[gEventConstants.ON_YANJIE_OPEN_TOPIC] = self.CreateAction(self, "OnOpenTopic"),
		[gEventConstants.ON_ENDORSEMENT_READ_UNLOCKED_STAGE_CHANGE] = self.CreateAction(self, "RefreshAvatarView")
	}
end

M.PlayPanelAnimation = function(self)
	if not self.SubGroup.YanjieNewSearchPanel.backToShowType then
		self.bindData.commonFansLevel:SetActive(true)
		self.bindData.playerAvatar:SetActive(true)
	end
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)
	gSocialNetworkUtils.AskTwitterPageOpen(UX.Game.TwitterPageType.HomePage)

	self.tabDataList = self.GetTabDataList(self)
	self.needRefreshFollowList = true
end

M.GetTabDataList = function(self)
	local tabDataList = {}

	table.insert(tabDataList, {
		tabId = TabTypeMap.Recommend,
		title = LTConfig.TextScriptTextConfig.GetConfig(89900983).Text
	})

	local exploreData = gSocialNetworkUtils.GetExploreTuiteList()

	if #exploreData.list <= 0 then
		table.insert(tabDataList, {
			tabId = TabTypeMap.Explore,
			title = LTConfig.TuiteConfig.Explore
		})
	end

	local localData = gSocialNetworkUtils.GetLocalTuiteList()

	if #localData.list <= 0 then
		local raidId = gRaidDataManager.RaidId
		local raidCfg = LTConfig.RaidConfig.GetConfig(raidId)

		table.insert(tabDataList, {
			tabId = TabTypeMap.Local,
			title = raidCfg.Name
		})
	end

	return tabDataList
end

M.InitView = function(self, _)
	self:InitList()
	self:RefreshAvatarView()

	self.bindData.newEndorsementTips = LTConfig.GrowthConfig.NewEndorsementNoticeText
	self.SubGroup.YanjieNewSearchPanel.backToShowType = nil
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

M.InitList = function(self)
	self.recommendList = self.SubGroup.CommonYanjieListTemplate_1
	self.recommendList.enableContentShowType = true
	self.recommendList.itemClickCallback = self:CreateAction("PlayToSearchOrDetailAnimation")
	self.recommendList.GetList = gSocialNetworkUtils.GetRecommendList

	self.recommendList:StartRequest()

	self.exploreList = self.SubGroup.CommonYanjieListTemplate_2
	self.exploreList.enableContentShowType = true
	self.exploreList.itemClickCallback = self:CreateAction("PlayToSearchOrDetailAnimation")
	self.exploreList.GetList = gSocialNetworkUtils.GetExploreTuiteList

	self.exploreList:StartRequest()

	self.localList = self.SubGroup.CommonYanjieListTemplate_3
	self.localList.enableContentShowType = true
	self.localList.itemClickCallback = self:CreateAction("PlayToSearchOrDetailAnimation")
	self.localList.GetList = gSocialNetworkUtils.GetLocalTuiteList

	self.localList:StartRequest()
	self.SubGroup.CommonTabSingleStore:SetData(self.tabDataList, nil, 0, 0, self:CreateAction("OnTabSelectedChanged"))
end

M.OnSearchClose = function(self, _, args)
	local backToShowType = args and args.backToShowType
	self.bindData.searchActive = false
	self.bindData.tabActive = true
	local uList = self.SubGroup.CommonTabSingleStore.bindData.tabList

	self:OnTabSelectedChanged(uList)

	UNavigationMgr.Inst.CurrentActiveArea = self.bindData.homeNavigationArea

	if backToShowType then
		gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_SHOW, {
			secondShowType = gClientConst.YanJieShowType.Mine
		})
	end
end

M.OnSearchResultShow = function(self)
	self.bindData.tabActive = false
	self.bindData.followActive = false
	self.bindData.recommendActive = false
end

M.RefreshAvatarView = function(self)
	local playerAvatar = self.bindData.playerAvatar
	local playerAvatarStore = gStoreManager:GetStoreGroup(playerAvatar.Store):GetStoreByWidget(playerAvatar)
	playerAvatarStore.headIcon = gSocialNetworkUtils.GetPlayerSGuiAvatarId()
	playerAvatarStore.button.luaClick = self:CreateAction("OnPlayerAvatarClick")
	local commonFansLevelWidget = self.bindData.commonFansLevel
	local commonFansLevelStore = gStoreManager:GetStoreGroup(commonFansLevelWidget.Store):GetStoreByWidget(commonFansLevelWidget)
	local targetLevel = gPlayerManager.infoMinor.bindData.level
	commonFansLevelStore.level = ("VIP.%d"):format(targetLevel)
	local hasRedDot = gClientUtils.CheckHasLevelReward()
	self.bindData.showTipCtrl = gSocialNetworkUtils.CheckHasNewUnlockedEndorsementStage() and 1 or 0

	SGUI.RedDotMgr.LuaSetRedDot(hasRedDot, "YanJieApp.FansReward")
	self:RefreshMoneyView()
end

M.RefreshMoneyView = function(self)
	local moneyShowWidget = self.bindData.moneyShowWidget
	local moneyShowStore = gStoreManager:GetStoreGroup(moneyShowWidget.Store):GetStoreByWidget(moneyShowWidget)
	moneyShowStore.count = gSocialNetworkUtils.GetTotalLeftMoney()
	local templateId = LTConfig.TuiteConfig.EyeCoinConsumableId
	local consumableCfg = LTConfig.ConsumableConfig.GetConfig(templateId)

	if consumableCfg then
		moneyShowStore.imageIcon = consumableCfg.SMoneyIconId
		moneyShowStore.iconButton.luaRenderTooltip = self.CreateActionWithArgs(self, "OnRenderToolTips", {
			TemplateId = templateId
		}, gCommonItemManager)
	end
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end

M.OnSearchClick = function(self)
	local playAnimation = not self.bindData.searchActive
	self.bindData.searchActive = true

	self.SubGroup.YanjieNewSearchPanel:ShowPanel({
		secondShowType = gClientConst.YanJieShowType.Search,
		trendData = self.trendData,
		momentList = self.SubGroup.CommonYanjieListTemplate_4,
		recommendTuiteIdList = self.recommendList:GetIdList(),
		playAnimation = playAnimation
	})
end

M.OnOpenTopic = function(self, _, args)
	local playAnimation = not self.bindData.searchActive
	self.bindData.searchActive = true

	self.bindData.commonFansLevel:SetActive(false)
	self.bindData.playerAvatar:SetActive(false)
	self.SubGroup.YanjieNewSearchPanel:ShowPanel({
		secondShowType = gClientConst.YanJieShowType.Search,
		trendData = self.trendData,
		momentList = self.SubGroup.CommonYanjieListTemplate_4,
		recommendTuiteIdList = self.recommendList:GetIdList(),
		openTopicId = args.topicId,
		openTopicName = args.name,
		playAnimation = playAnimation,
		backToShowType = args.backToShowType
	})
end

M.PlayToSearchOrDetailAnimation = function(self)
end

M.OnPlayerAvatarClick = function(self)
	local newUnlockedStageId = gSocialNetworkUtils.GetNewUnlockedEndorsementStageId()

	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_SHOW, {
		secondShowType = gClientConst.YanJieShowType.Mine,
		playerInfo = self.playerInfo,
		newUnlockedStageId = newUnlockedStageId
	})
end

M.OnWalletClick = function(self)
	gPanelManager:CheckShow(gPanelId.YANJIE_WITHDRAW_CASH)
end

M.OnSwitchViewClick = function(self)
	local switchViewValue = gClientUtils.GetBool(gClientConst.YanJieSearchViewPrefsKey, false)

	gClientUtils.SetBool(gClientConst.YanJieSearchViewPrefsKey, not switchViewValue)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_SWITCH_VIEW_CHANGE)
end

M.OnExitClick = function(self)
	if self.bindData.searchActive then
		self.SubGroup.YanjieNewSearchPanel:OnExitClick()

		self.bindData.searchActive = false
		self.bindData.tabActive = true

		return
	end

	M.base.OnExitClick(self)
end

M.OnRenderTabItem = function(self, btn, index)
	local data = self.tabDataList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.title = data.title
end

M.OnTabSelectedChanged = function(self, uList, _)
	local selectedIndex = uList.selectedIndex
	local data = self.tabDataList[selectedIndex + 1]
	self.bindData.recommendActive = data.tabId ~= TabTypeMap.Recommend
	self.bindData.followActive = data.tabId ~= TabTypeMap.Explore
	self.bindData.localActive = data.tabId ~= TabTypeMap.Local
	local targetSubGroup = nil

	if data.tabId ~= TabTypeMap.Recommend then
		targetSubGroup = self.recommendList
	elseif data.tabId ~= TabTypeMap.Explore then
		targetSubGroup = self.exploreList
	elseif data.tabId ~= TabTypeMap.Local then
		targetSubGroup = self.localList
	end

	if targetSubGroup then
		targetSubGroup.bindData.list:SetNavSelectToTop()
	end
end

M.ClearData = function(self)
	self.trendData = nil
end
