-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieMinePanelStore.lua
-- Decompiled from: 02064_YanjieMinePanelStore.lua_4d307a5a02da.luajit

C_YanjieMinePanelStore = DefClass("C_YanjieMinePanelStore", C_YanjieMinePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieMinePanelStore = C_YanjieMinePanelStore
local M = C_YanjieMinePanelStore

M.OnAwake = function(self)
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.homeButton.luaClick = self.CreateAction(self, self.OnHomeClick)
	self.bindData.collectionButton.luaClick = self.CreateAction(self, self.OnCollectionClick)
	self.bindData.noticeButton.luaClick = self.CreateAction(self, self.OnNoticeClick)
	self.bindData.memberCenterButton.luaClick = self.CreateAction(self, self.OnMemberCenterClick)
	self.bindData.levelRewardButton.luaClick = self.CreateAction(self, self.OnLevelRewardClick)
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_PLAYER_INFO] = function (_, args)
			self:RefreshView(args)
		end,
		[gEventConstants.ON_PLAYER_FAN_CHANGE] = self.CreateAction(self, "RefreshFansView"),
		[gEventConstants.ON_LEVEL_REWARD_UPDATE] = self.CreateAction(self, "RefreshFansView")
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)
	gSocialNetworkUtils.AskTwitterPageOpen(UX.Game.TwitterPageType.MinePage)
end

M.InitView = function(self, args)
	local isFromMain = args and args.isFromMain
	local animationName = isFromMain and "S_Vx_S_YanjieMinePanel_open_first" or "S_Vx_S_YanjieMinePanel_open"

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)

	local avatarWidget = self.bindData.avatar
	local playerAvatarStore = gStoreManager:GetStoreGroup(avatarWidget.Store):GetStoreByWidget(avatarWidget)
	playerAvatarStore.headIcon = gSocialNetworkUtils.GetPlayerSGuiAvatarId()
	self.bindData.name = LTConfig.TuiteConfig.PlayerAccountName
	self.bindData.popularityValue = gSocialNetworkUtils.GetCurrentPopularityValue()

	self:RefreshView(args)
end

M.GetNextLevelReward = function(self)
	local currentLevel = gPlayerManager.infoMinor.bindData.level
	local count = LTConfig.GrowthConfig.count

	for i = 0, count - 1 do
		local growthCfg = LTConfig.GrowthConfig.LoadAt(i)

		if currentLevel >= growthCfg.Lv and growthCfg.Drop <= 0 then
			return growthCfg.Lv
		end
	end
end

M.PlayPanelAnimation = function(self)
	if self.panelArgs then
		if self.panelArgs.lastShowType ~= gClientConst.YanJieShowType.Collect then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieMinePanel_open")
		end

		self.panelArgs.lastShowType = nil
	end
end

M.RefreshView = function(self, args)
	self.bindData.followCount = args and args.followingCount or 0

	self:RefreshFansView()
	gSocialNetworkUtils.RefreshPopularityView(self.bindData.popularityWidget)
end

M.RefreshFansView = function(self)
	local fansWidget = self.bindData.commonFansLevel

	gSocialNetworkUtils.RefreshPlayerExpProgressView(fansWidget)

	local fansStore = gStoreManager:GetStoreGroup(fansWidget.Store):GetStoreByWidget(fansWidget)
	fansStore.progressText = gPlayerManager.infoMinor.bindData.fan123

	if gClientUtils.CheckHasLevelReward() then
		self.bindData.levelRewardText = LTConfig.TextScriptTextConfig.GetConfig(89901178).Text
	else
		local nextLevelReward = self.GetNextLevelReward(self)

		if nextLevelReward then
			self.bindData.levelRewardText = LTConfig.TextScriptTextConfig.GetConfig(89901176).Text:format(nextLevelReward)
		else
			self.bindData.levelRewardText = LTConfig.TextScriptTextConfig.GetConfig(89901177).Text
		end
	end

	local hasRedDot = gClientUtils.CheckHasLevelReward()

	self.bindData.levelRewardButton:SetActive(hasRedDot)
end

M.OnHomeClick = function(self)
	gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900581).Text)
end

M.OnCollectionClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_SHOW, {
		secondShowType = gClientConst.YanJieShowType.Collect
	})
end

M.OnNoticeClick = function(self)
	gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900581).Text)
end

M.OnMemberCenterClick = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_SHOW, {
		secondShowType = gClientConst.YanJieShowType.MemberCenter
	})
end

M.OnLevelRewardClick = function(self)
	local targetLevel = gClientUtils.GetPlayerLevel()
	local rootGo = nil
	slot3 = gClientToGameDelegate

	slot3:AskTakeLevelReward(targetLevel).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gPlayerManager.infoMinor.bindData.levelRewardList = {}

		gMessageManager:SendMessage(gEventConstants.ON_LEVEL_REWARD_UPDATE)

		if gClientUtils.IsNil(rootGo) then
			return
		end
	end
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end
