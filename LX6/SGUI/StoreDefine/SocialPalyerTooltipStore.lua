-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialPalyerTooltipStore.lua
-- Decompiled from: 01287_SocialPalyerTooltipStore.lua_e5d23a5eb974.luajit

C_SocialPalyerTooltipStore = DefClass("C_SocialPalyerTooltipStore", C_SocialPalyerTooltipStore, C_StoreGroup)
GroupName2Class.SocialPalyerTooltipStore = C_SocialPalyerTooltipStore
local M = C_SocialPalyerTooltipStore
M.OnlineStatus = {
	["3F\\x9d\\x87\\x8dD"] = 0,
	["\\xf6\\xdd*\\xf4"] = 1,
	["/A\\x9f\\x89\\x8fD"] = 2,
	X7nB = 3
}

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.btnList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderButtonItem")
	self.bindData.copyBtn.luaClick = self.CreateAction(self, "OnCopyButtonClick")
	self.bindData.psAccountBtn.luaClick = self.CreateAction(self, "OnPSAccountBtnClick")
	self.msgEvents = {
		[gEventConstants.PANEL_ON_SHOW] = self.CreateAction(self, "OnPanelShow"),
		[gEventConstants.TEAM_REFRESH_DATA] = self.CreateAction(self, "OnTeamRefreshData")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnEnable = function(self)
	self.SetBanButton(self)
end

M.OnDisable = function(self)
	self.ClearBanButton(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	self.headBtn = nil
end

M.OnPanelShow = function(self, _, panelId)
	local panelCfg = LTConfig.PanelConfig.GetConfig(panelId)

	if panelCfg.isFullScreen then
		self.CloseUI(self)

		return
	end

	self.HideThisUIiCfg = LTConfig.FriendsConfig.HideSocialPalyerTooltipList

	if table.contains(self.HideThisUIiCfg, panelId) then
		self.CloseUI(self)

		return
	end
end

M.OnTeamRefreshData = function(self)
	if self.pid then
		self.SetData(self, self.pid, self.headBtn)
	end
end

M.SetData = function(self, pid, headBtn, closeCallback)
	if not pid then
		print_error("SocialPalyerTooltipStore: pid is nil! Using default value: self")
	end

	self.partyLiveNpcInfo = nil
	self.pid = pid or gPlayerManager.infoLogin.bindData.pid
	self.headBtn = headBtn
	self.closeCallback = closeCallback
	self.bindData.playerId = ulong.tostring(pid)
	self.bindData.isShowUIDCtrl = 1

	self:SetPlayerData()
	self:GetBtnData(false)
	self:InitButtonList()
	self:QueryObjectTeamAndRefresh()
end

M.SetReportUseSystem = function(self, reportUseSystem)
	self.reportUseSystem = reportUseSystem
end

M.SetRobotData = function(self, headBtn, iconId, name, partyLiveNpcInfo)
	self.headBtn = headBtn
	self.partyLiveNpcInfo = partyLiveNpcInfo
	self.bindData.name = name
	self.bindData.icon = iconId
	self.bindData.playerId = ""
	self.bindData.onlineStatus = self.OnlineStatus.Offline
	self.bindData.isShowUIDCtrl = 0

	self.InitRobotButtonList(self)
end

M.InitRobotButtonList = function(self)
	self.buttonList = {}

	if self.partyLiveNpcInfo then
		local buttonId = gSocialPalyerTooltipManager.ButtonEnum.AddToBlacklist
		local cfg = LTConfig.FriendsMenuListConfig.GetConfig(buttonId)

		table.insert(self.buttonList, {
			title = cfg.MenuName,
			icon = cfg.MenuIcon,
			buttonId = buttonId,
			type = cfg.Type
		})
	end

	self.bindData.btnList:SetSimpleList(#self.buttonList)
end

M.SetPlayerData = function(self)
	self.bindData.userInfo.pid = self.pid
	slot1 = gFriendManager

	slot1:GetSimplePlayerInfo(self.pid, function (info)
		if info and info.OnlineState ~= UX.Game.PlayerState.Online then
			local mode = info.LinkMode

			if not mode or mode ~= UX.Game.LinkMode.None then
				self.bindData.onlineStatus = self.OnlineStatus.Single
			elseif mode ~= UX.Game.LinkMode.Match or info.InMatch then
				self.bindData.onlineStatus = self.OnlineStatus.Busy
			elseif mode ~= UX.Game.LinkMode.Public or mode ~= UX.Game.LinkMode.Private then
				self.bindData.onlineStatus = self.OnlineStatus.Online
			end
		else
			self.bindData.onlineStatus = self.OnlineStatus.Offline
		end
	end, true)

	if gCS.LuaUtils.IsPSPlatform() then
		local callback = function(onlineId)
			self.bindData.isShowOnlineIdCtrl = onlineId == nil and 1 or 0

			if onlineId then
				self.bindData.onlineId = onlineId
			end
		end

		LX6.Utils.PS5Utils.GetOnlineIdByPlayerId(self.pid, callback)
	end
end

M.QueryObjectTeamAndRefresh = function(self)
	local objectInSameTeam = gTeamManager:IsInTeamByPid(self.pid)

	if objectInSameTeam then
		return
	end

	slot2 = gClientToGameDelegate

	slot2:AskQueryTeamInfoByPid(self.pid).Callback = function (err, data)
		local objectHasTeam = err ~= LTConfig.MessageConfig.Ok and data and data.TeamId
		self.objectTeamId = objectHasTeam and data.TeamId or nil

		if objectHasTeam then
			self:GetBtnData(true)
			self:InitButtonList()
		end
	end
end

M.InitButtonList = function(self)
	local buttonList = {}

	if self.pid == gPlayerManager.infoLogin.bindData.pid then
		buttonList = gSocialPalyerTooltipManager:GetButtonList(self.conditions)
	end

	self.buttonList = {}

	for _, button in ipairs(buttonList) do
		table.insert(self.buttonList, {
			title = button.title,
			icon = button.icon,
			buttonId = button.id,
			type = button.type
		})
	end

	self.bindData.btnList:SetSimpleList(#self.buttonList)
end

M.GetBtnData = function(self, objectInTeam)
	local myPid = gPlayerManager.infoLogin.bindData.pid
	local selfInTeam = gTeamManager:IsInTeam()
	local objectInSameTeam = gTeamManager:IsInTeamByPid(self.pid)
	local isSameTeam = selfInTeam and objectInSameTeam
	local objectIsLeader = gTeamManager.leaderPid and ulong.equals(gTeamManager.leaderPid, self.pid)
	local isInLinkMode = gLinkManager.LinkMode == UX.Game.LinkMode.None
	local objectInLink = not table.isNilOrEmpty(gLinkManager.LinkMemberInfo[self.pid])
	local currentLinkGame = gLinkManager:GetCurrentLinkGame()
	local isCustomRoomOwner = currentLinkGame and currentLinkGame.uxData.StageId ~= LTConfig.LinkStageConfig.Room and currentLinkGame:IsLeader(myPid) and currentLinkGame:ContainsPlayer(self.pid) or false
	local memberInfo = gLinkManager.LinkMember[self.pid]
	local notInMatch = true

	if memberInfo then
		notInMatch = not memberInfo.InMatch
	end

	self.conditions = {
		isFriend = gSocialFriendManager:IsFriend(self.pid),
		inBlack = gSocialFriendManager:IsInBlackList(self.pid),
		isInPublic = gLinkManager.LinkMode ~= UX.Game.LinkMode.Public,
		isInPrivate = gLinkManager.LinkMode ~= UX.Game.LinkMode.Private,
		teamNotFull = selfInTeam and not gTeamManager:IsTeamFull(),
		selfInTeam = selfInTeam,
		objectInTeam = objectInTeam,
		objectInSameTeam = objectInSameTeam,
		isLeader = gTeamManager.leaderPid and ulong.equals(gTeamManager.leaderPid, myPid),
		isMember = isSameTeam and not objectIsLeader,
		objectIsLeader = isSameTeam and objectIsLeader,
		teamMateMicOn = isSameTeam and not gTeamManager:IsVoiceBlocked(self.pid),
		teamMateMicOff = isSameTeam and gTeamManager:IsVoiceBlocked(self.pid),
		inLinkMode = isInLinkMode,
		objectInLink = objectInLink,
		isCustomRoomOwner = isCustomRoomOwner,
		notInMatch = notInMatch
	}
end

M.OnRenderButtonItem = function(self, btn, index)
	local data = self.buttonList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store and data then
		store.title = data.title

		if data.icon then
			store.Commit(store, "icon", data.icon, COMMIT_FORCE)
		end

		btn.luaClick = self.CreateActionWithArgs(self, "OnButtonClick", data.type)
	end
end

M.OnButtonClick = function(self, btnType)
	local ButtonEnum = gSocialPalyerTooltipManager.ButtonEnum

	if self.partyLiveNpcInfo and btnType ~= ButtonEnum.AddToBlacklist then
		self.OnAddPartyLiveNpcToBlacklist(self)
		self.CloseUI(self)

		return
	end

	local buttonActions = {
		[ButtonEnum.AddFriend] = self.OnAddFriend,
		[ButtonEnum.RemoveFriend] = self.OnRemoveFriend,
		[ButtonEnum.SendMessage] = self.OnSendMessage,
		[ButtonEnum.InviteToGame] = self.OnInviteToGame,
		[ButtonEnum.InviteToTeam] = self.OnInviteToTeam,
		[ButtonEnum.KickFromTeam] = self.OnKickFromTeam,
		[ButtonEnum.TransferLeader] = self.OnTransferLeader,
		[ButtonEnum.ApplyToJoin] = self.OnApplyToJoin,
		[ButtonEnum.ApplyForLeader] = self.OnApplyForLeader,
		[ButtonEnum.MuteMic] = self.OnMuteMic,
		[ButtonEnum.UnmuteMic] = self.OnUnmuteMic,
		[ButtonEnum.AddToBlacklist] = self.OnAddToBlacklist,
		[ButtonEnum.RemoveFromBlacklist] = self.OnRemoveFromBlacklist,
		[ButtonEnum.Report] = self.OnReport,
		[ButtonEnum.PersonalHomepage] = self.OnPersonalHomepage,
		[ButtonEnum.KickFromRoom] = self.OnKickFromRoom
	}
	local action = buttonActions[btnType]

	if action then
		action(self)
	else
		print_error("Unknown button clicked:", btnType)
	end

	self.CloseUI(self)
end

M.CloseUI = function(self)
	if self.headBtn then
		self.headBtn:CloseTooltip()
	else
		gPanelManager:Close(gPanelId.SOCIAL_PLAYER_TOOLTIP)
	end

	if self.closeCallback then
		self.closeCallback()
	end
end

M.OnAddFriend = function(self)
	if gSocialFriendManager:IsInBlackList(self.pid) then
		slot1 = gDisplayMessageMgr

		slot1:ShowMessage(LTConfig.MessageConfig.SocialRemoveFromBlacklistAndAddFriend, function ()
			slot0 = gSocialFriendManager

			slot0:RemoveFromBlackList(self.pid, function ()
				gSocialFriendManager:ApplyFriend(self.pid)
			end)
		end)
	else
		gSocialFriendManager:ApplyFriend(self.pid)
	end
end

M.OnRemoveFriend = function(self)
	slot1 = gFriendManager

	slot1:GetSimplePlayerInfo(self.pid, function (info)
		self:DeleteFriend(self.pid, info)
	end, true, true)
end

M.DeleteFriend = function(self, pid, info)
	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.SocialDeleteFriend, function ()
		gSocialFriendManager:DeleteFriend(pid)
	end, nil, gSocialFriendManager:GetPlayerDisplayName(pid, info.Name))
end

M.OnSendMessage = function(self)
	if gPanelManager:IsPanelShowing(gPanelId.PLAYER_PROFILE_PANEL) then
		local profileStore = gStoreManager:GetStoreGroup("PlayerProfileStore")

		if profileStore and profileStore.TeardownScene then
			profileStore.TeardownScene(profileStore)
		end

		gPanelManager:Close(gPanelId.PLAYER_PROFILE_PANEL)
	end

	if gPanelManager:IsPanelShowing(gPanelId.PLAYER_LIKES_INFO) then
		gPanelManager:Close(gPanelId.PLAYER_LIKES_INFO)
	end

	gSocialChatManager:JumpToChat(gSocialChatManager.ChatTopChannel.Friend, self.pid)
end

M.OnInviteToGame = function(self)
	gLinkManager:InviteFriendToLink(self.pid, gLinkManager.LinkMode)
end

M.OnInviteToTeam = function(self)
	if not gTeamManager:IsInTeam() then
		gTeamManager:CreateAndInviteTeam(self.pid)

		return
	end

	gTeamManager:InviteToTeam(self.pid)
end

M.OnKickFromTeam = function(self)
	gTeamManager:AskKickTeamMember(self.pid)
end

M.OnKickFromRoom = function(self)
	local linkGame = gLinkManager:GetCurrentLinkGame()

	if linkGame and linkGame.uxData then
		slot2 = gClientToGameDelegate

		slot2:PrepareRoomKickMember(linkGame.uxData.Id, self.pid).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:ShowServerMessage(err)
			end
		end
	end
end

M.OnTransferLeader = function(self)
	gTeamManager:AskChangeTeamLeader(self.pid)
end

M.OnApplyToJoin = function(self)
	if self.objectTeamId then
		gTeamManager:AskApplyToTeam(self.objectTeamId)
	end
end

M.OnApplyForLeader = function(self)
	gTeamManager:AskChangeTeamLeaderApply()
end

M.OnMuteMic = function(self)
	gTeamManager:SetVoiceBlocked(self.pid, true)
end

M.OnUnmuteMic = function(self)
	gTeamManager:SetVoiceBlocked(self.pid, false)
end

M.OnAddToBlacklist = function(self)
	slot1 = gFriendManager

	slot1:GetSimplePlayerInfo(self.pid, function (info)
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.SocialAddToBlacklist, function ()
			gSocialFriendManager:AddToBlackList(self.pid)
		end, nil, gSocialFriendManager:GetPlayerDisplayName(self.pid, info.Name))
	end)
end

M.OnAddPartyLiveNpcToBlacklist = function(self)
	local npcInfo = self.partyLiveNpcInfo
	slot2 = gDisplayMessageMgr

	slot2:ShowMessage(LTConfig.MessageConfig.SocialAddToBlacklist, function ()
		gPartyManager:BlockPartyLiveNpc(npcInfo.npcId)
	end, nil, npcInfo.nickName)
end

M.OnRemoveFromBlacklist = function(self)
	slot1 = gFriendManager

	slot1:GetSimplePlayerInfo(self.pid, function (info)
		self:RemoveFromBlackList(self.pid, info)
	end)
end

M.RemoveFromBlackList = function(self, pid, info)
	slot3 = gDisplayMessageMgr

	slot3:ShowMessage(LTConfig.MessageConfig.SocialRemoveFromBlacklist, function ()
		gSocialFriendManager:RemoveFromBlackList(pid)
	end, nil, info.Name)
end

M.OnReport = function(self)
	if self.reportUseSystem then
		gReportManager:ShowReportDialogByUseSystemId(self.pid, self.reportUseSystem)
	else
		gReportManager:ShowDefaultReportDialog(self.pid)
	end
end

M.OnCopyButtonClick = function(self)
	gCS.LuaUtils.PasteText2Clipboard(ulong.tostring(self.pid))
	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.CopyIDComplete)
end

M.OnPSAccountBtnClick = function(self)
	if gCS.LuaUtils.IsPSPlatform() then
		self.pid = self.pid or gPlayerManager.infoLogin.bindData.pid

		LX6.Utils.PS5Utils.OpenPlayerProfileCard(self.pid)
	end
end

M.OnPersonalHomepage = function(self)
	gFriendManager:OpenPlayerProfile(self.pid)
end

M.SetBanButton = function(self)
	if not self.buttonBanId then
		self.buttonBanId = gStoreButtonMgr:RegisterOperation({
			["\\xca\\xcf\t\r\\xf5"] = 5,
			["\\xbb\\xa3\\xa4x7\\xea*"] = 0,
			groupId = LTConfig.HudDescGroupConfig.OnlineController
		})
	end
end

M.ClearBanButton = function(self)
	if self.buttonBanId then
		gStoreButtonMgr:UnRegisterOperation(self.buttonBanId)

		self.buttonBanId = nil
	end
end
