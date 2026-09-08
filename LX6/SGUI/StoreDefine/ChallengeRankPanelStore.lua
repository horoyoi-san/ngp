-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChallengeRankPanelStore.lua
-- Decompiled from: 01450_ChallengeRankPanelStore.lua_3d99c312f1da.luajit

local LinkConfig = LTConfig.LinkConfig
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
C_ChallengeRankPanelStore = DefClass("C_ChallengeRankPanelStore", C_ChallengeRankPanelStore, C_StoreGroup)
GroupName2Class.ChallengeRankPanelStore = C_ChallengeRankPanelStore
local M = C_ChallengeRankPanelStore

M.ctor = function(self)
	self.isOnline = false
	self.againState = nil
	self.friendInvited = {}
	self.likeInvited = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.showonlineCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showAgainBtnCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.showProgressCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showonlineCtrlEnum = nil
	self.showAgainBtnCtrlEnum = nil
	self.showProgressCtrlEnum = nil
end

M.OnAwake = function(self)
	self.bindData.fullscreenBtn.luaClick = self.CreateAction(self, self.OnClickFullscreenBtn)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnClickExitBtn)
	self.bindData.retryBtn.luaClick = self.CreateAction(self, self.OnClickRetryBtn)
	self.bindData.reportBtn.luaClick = self.CreateAction(self, self.OnClickReportBtn)
	self.bindData.singleMatchBtn.luaClick = self.CreateAction(self, self.OnClickSingleMatchBtn)
	self.bindData.againProgressCountDown.luaFinished = self.CreateAction(self, self.OnAgainCountDownFinished)

	self.GenMessageEvents(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ADD_CHAT_FRIEND] = self.CreateAction(self, self.OnLinkMemberInfoChange),
		[gEventConstants.LINK_MEMBER_CHANGE] = self.CreateAction(self, self.OnLinkMemberInfoChange),
		[gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE] = self.CreateAction(self, self.RefreshAgainInfo),
		[gEventConstants.RACING_RANK_UPDATE] = self.CreateAction(self, self.OnRankUpdate)
	}
end

M.OnShow = function(self, panelId, data)
	if not data then
		return
	end

	self.likeInvited = {}
	self.taskId = data.taskId
	self.challengeId = data.challengeId
	self.counterData = data.counterData
	self.isOnline = data.showonlineCtrl ~= 1
	self.title = data.title or ""
	self.bindData.showonlineCtrl = data.showonlineCtrl
	self.bindData.retryBtn.interactable = true

	if self.isOnline then
		self._memberChangeAction = self:CreateAction(self.RefreshAgainInfo)

		gMessageManager:AddMessageListener(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE, self._memberChangeAction)
		self:RefreshAgainInfo()
	else
		self.bindData.showAgainBtnCtrl = 0
		self.bindData.showProgressCtrl = 0
	end

	self.rankStore = gStoreManager:GetStoreGroup(self.bindData.rankWidget.Store):GetStoreByWidget(self.bindData.rankWidget)

	if self.rankStore then
		self.rankStore.titleText = data.title
	end

	self.RefreshRankList(self)
end

M.OnClose = function(self)
	if self._memberChangeAction then
		gMessageManager:RemoveMessageListener(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE, self._memberChangeAction)

		self._memberChangeAction = nil
	end
end

M.RefreshAgainInfo = function(self)
	if not gPanelManager:IsPanelShowing(gPanelId.S_CHALLENGE_RANK_PANEL) then
		return
	end

	if not self.isOnline then
		return
	end

	local againState = gLinkManager:CheckAgainState(true)

	if gGameManager.Env.isEditor then
		print_debug("RefreshAgainInfo", againState, gLinkManager.tryAgainDict)
	else
		print_notice("RefreshAgainInfo", againState, gLinkManager.tryAgainDict)
	end

	if againState ~= C_LinkManager.AGAIN_STATE.REPLAY then
		againState = C_LinkManager.AGAIN_STATE.None
	end

	self.againState = againState
	local showProgress = not table.isNilOrEmpty(gLinkManager.tryAgainDict) and againState == C_LinkManager.AGAIN_STATE.None

	if self.bindData.showProgressCtrl == BOOL2CTL[showProgress] then
		self.bindData.againProgressCountDown:Play(LinkConfig.ClearingMaxTime)
	end

	self.bindData.showProgressCtrl = BOOL2CTL[showProgress]
	self.bindData.againProgressDescText = gLinkManager:GetAgainLabel(againState)
	self.bindData.showAgainBtnCtrl = BOOL2CTL[againState == C_LinkManager.AGAIN_STATE.None]

	if againState ~= C_LinkManager.AGAIN_STATE.None then
		self.bindData.retryBtn.interactable = false
	end
end

M.OnAgainCountDownFinished = function(self)
	self.bindData.showProgressCtrl = BOOL2CTL[false]
end

M.OnClickFullscreenBtn = function(self)
	gPanelManager:Close(gPanelId.S_CHALLENGE_RANK_PANEL)
	gChallengeManager:ShowEndingPanel(self.taskId, self.challengeId, self.counterData, false)
end

M.OnClickExitBtn = function(self)
	gPanelManager:Close(gPanelId.S_CHALLENGE_RANK_PANEL)

	if gLinkManager:CheckIsInRace() and gClientUtils:CheckIsLinkMode() then
		gLinkManager:AskLeaveGame(false)
	end
end

M.OnClickRetryBtn = function(self)
	if gGameManager.Env.isEditor then
		print_debug("点击重玩按钮", self.againState)
	else
		print_notice("点击重玩按钮", self.againState)
	end

	if not self.isOnline then
		return
	end

	self.bindData.retryBtn.interactable = false
	slot1 = gLinkManager

	slot1:AskPlayGameAgain(self.againState, function (isSuccess)
	end)
end

M.OnClickAddFriendBtn = function(self, args)
	self.friendInvited[args.pid] = true

	if args.isRobot then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(LTConfig.TextScriptTextConfig.ApplicationSent).Text)
	else
		gSocialFriendManager:ApplyFriend(args.pid)
	end

	self.RefreshRankList(self)
end

M.SetupLikeBtn = function(self, store, pid)
	if not store or not store.likeBtn or not pid then
		return
	end

	store.likeBtn.interactable = true

	store.likeBtn.luaClick = function()
		if self.likeInvited[pid] then
			gDisplayMessageMgr:ShowMessage(75109966)

			return
		end

		store.likeBtn.interactable = false
		slot0 = gClientToGameDelegate

		slot0:AskLikePlayer(pid, UX.Game.LikeType.Game).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok or err ~= LTConfig.MessageConfig.TappedDailyLimitReached then
				self.likeInvited[pid] = true
			else
				gDisplayMessageMgr:ShowMessage(err)

				store.likeBtn.interactable = true
			end
		end
	end
end

M.OnClickReportBtn = function(self)
	gReportManager:ShowRacingGameReportDialog(self.title, gChallengeManager.racingZoneSessionId)
end

M.OnClickSingleMatchBtn = function(self)
	gPanelManager:Close(gPanelId.S_CHALLENGE_RANK_PANEL)

	if gLinkManager:CheckIsInRace() and gClientUtils:CheckIsLinkMode() then
		gLinkManager:AskSingleMatch()
	else
		print_error("在错误的模式或者玩法中使用了ChallengeRankPanel的单人匹配按钮", self.isOnline)
	end
end

M.OnRankUpdate = function(self)
	self.RefreshRankList(self)
end

M.OnRenderRankListItem = function(self, btn, index)
	local rankData = gChallengeManager.carRaceChallengeData
	local data = rankData and rankData[index + 1]

	if not data then
		return
	end

	local itemStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not itemStore then
		return
	end

	local rank = index + 1

	gChallengeManager:RenderChallengeRankListTemplate(itemStore, data, rank)

	local pid = data.pid
	local isSelf = data.isSelf
	local isAI = data.isAI
	local isFriend = gFriendManager:IsFriend(pid)
	itemStore.beFriendCtrl = not self.friendInvited[pid] and not isSelf and not isFriend and 0 or 1
	itemStore.addFriendBtn.luaClick = self:CreateActionWithArgs(self.OnClickAddFriendBtn, {
		isRobot = isAI,
		pid = pid
	})

	self:SetupLikeBtn(itemStore, pid)
end

M.RefreshRankList = function(self)
	if self.rankStore then
		local rankData = gChallengeManager.carRaceChallengeData
		self.rankStore.rankList.luaSimpleRenderItem = self:CreateAction(self.OnRenderRankListItem)

		self.rankStore.rankList:SetSimpleList(rankData and #rankData or 0)
	end
end

M.OnLinkMemberInfoChange = function(self)
	self.RefreshRankList(self)
	self.RefreshAgainInfo(self)
end
