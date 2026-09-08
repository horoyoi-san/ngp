-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanJieHomePagePanelStore.lua
-- Decompiled from: 02060_YanJieHomePagePanelStore.lua_e89482304e29.luajit

C_YanJieHomePagePanelStore = DefClass("C_YanJieHomePagePanelStore", C_YanJieHomePagePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanJieHomePagePanelStore = C_YanJieHomePagePanelStore
local M = C_YanJieHomePagePanelStore
local TabControl = {
	["qBofC<"] = 0,
	[":G\\x9d\\x82\\x8cV"] = 1
}

M.OnAwake = function(self)
	self.bindData.recommendTab.luaClick = self.CreateActionWithArgs(self, self.OnTabChange, TabControl.Recommend)
	self.bindData.followTab.luaClick = self.CreateActionWithArgs(self, self.OnTabChange, TabControl.Follow)
	self.bindData.searchButton.luaClick = self.CreateAction(self, self.OnSearchClick)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, self.OnExitClick)
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_PLAYER_INFO] = function (_, args)
			self.playerInfo = args
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_TREAD_LIST] = function (_, info)
			self.trendData = info
		end,
		[gEventConstants.ON_LEVEL_REWARD_UPDATE] = self.CreateAction(self, "RefreshAvatarView"),
		[gEventConstants.ON_PLAYER_FAN_CHANGE] = self.CreateAction(self, "RefreshAvatarView")
	}
end

M.PlayPanelAnimation = function(self)
	if self.panelArgs then
		local lastShowType = self.panelArgs.lastShowType
		local animationName = nil

		if lastShowType ~= gClientConst.YanJieShowType.Mine then
			animationName = "S_Vx_S_YanjieHomePagePanel_open"
		elseif lastShowType ~= gClientConst.YanJieShowType.Search then
			animationName = "S_Vx_S_YanjieHomePagePanel_BackSearch"
		elseif lastShowType ~= gClientConst.YanJieShowType.Detail then
			animationName = "S_Vx_S_YanjieHomePagePanel_BackSearchAndDetail"
		end

		if animationName then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)
		end

		self.panelArgs.lastShowType = nil
	end
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)
	gSocialNetworkUtils.AskTwitterPageOpen(UX.Game.TwitterPageType.HomePage)

	self.needRefreshFollowList = true

	gSocialNetworkUtils.GetTrendList(1, 10)
end

M.InitView = function(self, args)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieHomePagePanel_open_first")

	local isHideFullScreenButton = args and args.isHideFullScreenButton

	self.bindData.fullScreenButton.gameObject:SetActive(not isHideFullScreenButton)

	self.recommendList = self.SubGroup.CommonYanjieListTemplate_1
	self.recommendList.itemClickCallback = self:CreateAction(self.PlayToSearchOrDetailAnimation)
	self.followList = self.SubGroup.CommonYanjieListTemplate_2
	self.followList.itemClickCallback = self:CreateAction(self.PlayToSearchOrDetailAnimation)
	self.recommendList.GetList = gSocialNetworkUtils.GetRecommendList
	self.followList.GetList = gSocialNetworkUtils.GetExploreTuiteList

	self:RefreshAvatarView()
	self.recommendList:StartRequest()
	self:OnTabChange(TabControl.Recommend)
end

M.RefreshAvatarView = function(self)
	local playerAvatar = self.bindData.playerAvatar
	local playerAvatarStore = gStoreManager:GetStoreGroup(playerAvatar.Store):GetStoreByWidget(playerAvatar)
	playerAvatarStore.headIcon = gSocialNetworkUtils.GetPlayerSGuiAvatarId()
	playerAvatarStore.button.luaClick = self:CreateAction("OnPlayerAvatarClick")
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end

M.OnTabChange = function(self, tabCtrl)
	if self.bindData.tabCtrl ~= tabCtrl then
		return
	end

	local nextNavigationContent = nil

	if tabCtrl ~= TabControl.Recommend then
		self.followList.nextNavigationContent = SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent
		nextNavigationContent = self.recommendList.nextNavigationContent
	else
		self.recommendList.nextNavigationContent = SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent
		nextNavigationContent = self.followList.nextNavigationContent
	end

	self.bindData.tabCtrl = tabCtrl

	if tabCtrl ~= TabControl.Follow and self.needRefreshFollowList then
		self.followList:ClearAndRefreshData()
	end

	if gClientUtils.NotNil(nextNavigationContent) then
		local frameTimerFunc = function()
			if gClientUtils.NotNil(nextNavigationContent) then
				SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = nextNavigationContent
			end
		end

		FrameTimer.New(frameTimerFunc, 1):Start()
	end
end

M.OnSearchClick = function(self)
	local animationName = "S_Vx_S_YanjieHomePagePanel_toSearch"

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)

	local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, animationName)
	self.bindData.rootWidget.activeCtrlDelay = clipTime

	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_SHOW, {
		secondShowType = gClientConst.YanJieShowType.Search,
		trendData = self.trendData
	})
end

M.PlayToSearchOrDetailAnimation = function(self)
	local animationName = "S_Vx_S_YanjieHomePagePanel_toSearchAndDetail"

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)

	local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, animationName)
	self.bindData.rootWidget.activeCtrlDelay = clipTime
end

M.OnPlayerAvatarClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_SHOW, {
		secondShowType = gClientConst.YanJieShowType.Mine,
		playerInfo = self.playerInfo
	})

	local animationName = "S_Vx_S_YanjieHomePagePanel_close"

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)
end

M.ClearData = function(self)
	self.trendData = nil
end
