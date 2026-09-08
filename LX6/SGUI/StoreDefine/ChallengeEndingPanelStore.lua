-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChallengeEndingPanelStore.lua
-- Decompiled from: 01648_ChallengeEndingPanelStore.lua_2632e46c34f5.luajit

local LinkConfig = LTConfig.LinkConfig
C_ChallengeEndingPanelStore = DefClass("C_ChallengeEndingPanelStore", C_ChallengeEndingPanelStore, C_StoreGroup)
GroupName2Class.ChallengeEndingPanelStore = C_ChallengeEndingPanelStore
local M = C_ChallengeEndingPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.taskId = -1
	self.friendInvited = {}
	self.likeInvited = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.medalCtrlEnum = {
		["H\\xa3\\xb2\\xbb\\xaf"] = 0,
		["A\\x9d\\x98\\x86S"] = 2,
		["}-q_"] = 3,
		["G\\x81\\x9e\\x86S"] = 1
	}
	self.goalNumEnum = {
		["\\xaf\\xb4\\xaa2\\xeac"] = 0,
		["\\xaf\\xb4\\xaa2\\xeaa"] = 2,
		["\\xaf\\xb4\\xaa2\\xeab"] = 1,
		["\\xaf\\xb4\\xaa2\\xea`"] = 3
	}
	self.jobEnum = {
		[".I\\x92\\x87\\x8dF"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
	self.showQualityCtrlEnum = {
		["R+y^"] = 0,
		["I*rL"] = 1
	}
	self.showRankCtrlEnum = {
		["R+y^"] = 0,
		["I*rL"] = 1
	}
	self.showAgainProgressCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showAgainBtnCtrlEnum = {
		["K\\x85\\x87\\x95D"] = 1,
		["G\\x83\\x83\\x82M"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.medalCtrlEnum = nil
	self.goalNumEnum = nil
	self.jobEnum = nil
	self.showQualityCtrlEnum = nil
	self.showRankCtrlEnum = nil
	self.showAgainProgressCtrlEnum = nil
	self.showAgainBtnCtrlEnum = nil
end

M.OnGroupEnable = function(self)
	gMainPhoneUtils.SetSGUIGlobalBarVisible(false)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_SHOW)
	self:RegisterMessageEvents(self.msgEvents)
end

M.OnGroupDisable = function(self)
	gMainPhoneUtils.SetSGUIGlobalBarVisible(true)
	gMessageManager:SendMessage(gEventConstants.ON_PHONE_APP_HOME_HIDE)
	self:ClearMessageEvents()
end

M.OnAwake = function(self)
	self.bindData.retryButton.luaClick = self.CreateAction(self, self.OnClickRetryButton)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnClickExitButton)
	self.bindData.exitBtn1.luaClick = self.CreateAction(self, self.OnClickExitButton)
	self.bindData.exitBtn2.luaClick = self.CreateAction(self, self.OnClickExitButton)
	self.bindData.againProgressCountDown.luaFinished = self.CreateAction(self, self.OnAgainCountDownFinished)
	self.challengeCfgData = {}

	self.GenMessageEvents(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.RACING_RANK_UPDATE] = self.CreateAction(self, self.OnRankUpdate),
		[gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE] = self.CreateAction(self, self.RefreshAgainInfo),
		[gEventConstants.ADD_CHAT_FRIEND] = self.CreateAction(self, self.OnLinkMemberInfoChange),
		[gEventConstants.LINK_MEMBER_CHANGE] = self.CreateAction(self, self.OnLinkMemberInfoChange)
	}
end

M.OnShow = function(self, panelId, data)
	if not data or not data.taskId then
		print_error("[ChallengeEndingPanelStore]挑战任务结束面板显示失败，data 为空")
		self.OnClickExitButton(self)

		return
	end

	self.data = data
	self.taskId = tonumber(data.taskId)
	self.friendInvited = {}
	self.likeInvited = {}
	self.isOnlineRacing = gLinkManager:CheckIsInRace() and gClientUtils:CheckIsLinkMode()

	if self.isOnlineRacing then
		self.RefreshAgainInfo(self)
	else
		local taskCfg = LTConfig.TaskConfig.GetConfig(self.taskId)
		local title = taskCfg and taskCfg.Title or 0
		local canRetry = title ~= 11 or title ~= 19
		self.bindData.showAgainBtnCtrl = BOOL2CTL[canRetry]
		self.bindData.showAgainProgressCtrl = BOOL2CTL[false]
	end

	self.jobType = gChallengeManager:GetChallengeJobType(self.taskId)
	self.bindData.job = self.jobType
	local challengeCfgData = gChallengeManager:GetChallengeConfigByTaskId(self.taskId)

	if challengeCfgData ~= nil then
		print_error("刷新页面失败，没有找到对应的挑战任务数据 , taskId = " .. self.taskId)

		return
	end

	if not gChallengeManager:IsInOnlineMode() then
		slot4 = gChallengeManager

		slot4:AskFinishNewChallenge(data.challengeId, data.taskId, function (challengeResult)
			self:RefreshPanelInfo(challengeResult)
		end)
	else
		self.RefreshPanelInfo(self, nil)
	end
end

M.OnClose = function(self)
end

M.OnClickRetryButton = function(self)
	if self.isOnlineRacing then
		self.bindData.retryButton.interactable = false

		gLinkManager:AskPlayGameAgain(self.againState)

		return
	end

	slot1 = gTaskManager

	slot1:SetCurrentTask(self.taskId, function ()
		self:OnClickExitButton()
	end)
end

M.OnClickExitButton = function(self)
	gChallengeManager:Log("退出挑战结算面板")
	gPanelManager:Close(gPanelId.S_CHALLENGE_ENDING_PANEL)

	if self.challengeCfgData.Id ~= 1006 then
		slot1 = gClientToGameDelegate

		slot1:AskEnterRaidByMapEntrance(202).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				print_error("#NoCreateIssue MA14 退出结算界面传送失败 errId=", err, " err=", gCS.Error.GetNameById(err))
			end
		end

		return
	end

	if gLinkManager:CheckIsInRace() and gClientUtils:CheckIsLinkMode() then
		gLinkManager:AskLeaveGame(false)
	end
end

M.RefreshAgainInfo = function(self)
	local againState = gLinkManager:CheckAgainState()

	if self.isOnlineRacing and againState ~= C_LinkManager.AGAIN_STATE.REPLAY then
		againState = C_LinkManager.AGAIN_STATE.None
	end

	self.againState = againState
	local showProgress = not table.isNilOrEmpty(gLinkManager.tryAgainDict) and againState == C_LinkManager.AGAIN_STATE.None

	if self.bindData.showAgainProgressCtrl == BOOL2CTL[showProgress] then
		self.bindData.againProgressCountDown:Play(LinkConfig.ClearingMaxTime)
	end

	self.bindData.showAgainProgressCtrl = BOOL2CTL[showProgress]
	self.bindData.againProgressDescText = gLinkManager:GetAgainLabel(againState)
	self.bindData.showAgainBtnCtrl = BOOL2CTL[againState == C_LinkManager.AGAIN_STATE.None]

	if againState ~= C_LinkManager.AGAIN_STATE.None then
		self.bindData.retryButton.interactable = false
	else
		self.bindData.retryButton.interactable = true
	end
end

M.OnAgainCountDownFinished = function(self)
	self.bindData.showAgainProgressCtrl = BOOL2CTL[false]
end

M.RefreshPanelInfo = function(self, challengeResult)
	self.challengeCfgData = gChallengeManager:GetChallengeConfigByTaskId(self.taskId)

	if self.challengeCfgData ~= nil then
		print_error("刷新页面失败，没有找到对应的挑战任务数据 , taskId = " .. self.taskId)

		return
	end

	self.bindData.challengeTitleText = self.challengeCfgData.Name or ""
	local counterResult = self.data and self.data.counterData or {}
	local goalNum = 0

	if not gChallengeManager:IsInOnlineMode() then
		for i = 1, 3 do
			if self:RefreshGoal(i, counterResult[i] or false) then
				goalNum = goalNum + 1
			end
		end
	end

	self.bindData.goalNum = goalNum

	self:RefreshRankPart()

	local mdalCtrl = challengeResult and challengeResult.CurrentRewardLevel or 3

	Timer.New(function ()
		self.bindData:Commit("medalCtrl", mdalCtrl, COMMIT_IMMEDIATELY)
	end, 3):Start()
end

M.RefreshGoal = function(self, index, isCheck)
	if string.is_null_or_empty(self.challengeCfgData.CountersDescription[index]) then
		return false
	end

	local btn = self.bindData["goal" .. index]

	if not btn then
		return false
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return false
	end

	store.isCheck = BOOL2CTL[isCheck]
	store.checkText = self.challengeCfgData.CountersDescription[index]

	return true
end

M.RefreshRankPart = function(self)
	if self.data and self.data.showRank ~= false then
		self.bindData.showRankCtrl = BOOL2CTL[false]

		return
	end

	if self.challengeCfgData.UrbanJobType ~= LTConfig.UrbanJobJobClassConfig.RacingDriver then
		self.bindData.showRankCtrl = BOOL2CTL[true]
		self.rankStore = gStoreManager:GetStoreGroup(self.bindData.rankWidget.Store):GetStoreByWidget(self.bindData.rankWidget)

		if self.rankStore then
			self.rankStore.titleText = self.challengeCfgData and self.challengeCfgData.Name or ""
			local rankData = gChallengeManager.carRaceChallengeData
			self.rankStore.rankList.luaSimpleRenderItem = self:CreateAction(self.OnRenderRankListItem)

			self.rankStore.rankList:SetSimpleList(rankData and #rankData or 0)
		end
	else
		self.bindData.showRankCtrl = BOOL2CTL[false]
	end
end

M.OnRankUpdate = function(self)
	if not self.rankStore then
		return
	end

	local rankData = gChallengeManager.carRaceChallengeData

	self.rankStore.rankList:SetSimpleList(rankData and #rankData or 0)
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

	gChallengeManager:RenderChallengeRankListTemplate(itemStore, data, index + 1)

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

M.OnClickAddFriendBtn = function(self, args)
	self.friendInvited[args.pid] = true

	if args.isRobot then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(LTConfig.TextScriptTextConfig.ApplicationSent).Text)
	else
		gSocialFriendManager:ApplyFriend(args.pid)
	end

	if self.rankStore then
		local rankData = gChallengeManager.carRaceChallengeData

		self.rankStore.rankList:SetSimpleList(rankData and #rankData or 0)
	end
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

M.OnLinkMemberInfoChange = function(self)
	self.OnRankUpdate(self)
	self.RefreshAgainInfo(self)
end
