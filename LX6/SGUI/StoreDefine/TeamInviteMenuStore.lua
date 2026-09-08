-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TeamInviteMenuStore.lua
-- Decompiled from: 01403_TeamInviteMenuStore.lua_d3d0422eb260.luajit

local TextCommonTextConfig = LTConfig.TextCommonTextConfig
C_TeamInviteMenuStore = DefClass("C_TeamInviteMenuStore", C_TeamInviteMenuStore, C_StoreGroup)
GroupName2Class.TeamInviteMenuStore = C_TeamInviteMenuStore
local M = C_TeamInviteMenuStore
local LinkModeConfig = LTConfig.LinkModeConfig
local FriendState = {
	["3F\\x9d\\x87\\x8dD"] = 0,
	["\\xf6\\xdd*\\xf4"] = 2,
	["\\xac=.8t\\x98v\\xd6%\\xa6\\xbd"] = 3,
	X7nB = 1
}

local CalcStateCtl = function(info)
	if not info then
		return FriendState.Offline
	end

	if info.OnlineState ~= UX.Game.PlayerState.Detached then
		return FriendState.Busy
	end

	if info.OnlineState == UX.Game.PlayerState.Online then
		return FriendState.Offline
	end

	if not info.LinkMode or info.LinkMode ~= UX.Game.LinkMode.None then
		return FriendState.SingleWorld
	end

	if info.InMatch then
		return FriendState.Busy
	end

	return FriendState.Online
end

local GetSortPriority = function(info)
	local s = CalcStateCtl(info)

	if s ~= FriendState.Online then
		return 0
	end

	if s ~= FriendState.SingleWorld then
		return 1
	end

	return 2
end

M.OnAwake = function(self)
	self.TabData = {
		{
			name = LTConfig.TextScriptTextConfig.GetConfig(89900110).Text
		},
		{
			name = LTConfig.TextScriptTextConfig.GetConfig(89900113).Text
		}
	}
	self.TabType = {
		["\\xfa\\xd3!\\xfd"] = 1,
		[":Z\\x98\\x8b\\x8dE"] = 0
	}
	self.InviteListType = {
		["%\\xf1P9\\xf4\\xb9Q\\x85Y\\xa7\\xb8"] = 3,
		["j\\xbc\\xad\\xba\\xa6"] = 2,
		["/M\\x90\\x9c\\x80I"] = 4,
		["\\xfa\\xd3!\\xfd"] = 0,
		["\\x8c\\xa3\n\\xbez\\xf74"] = 1
	}
	self.tick = 0
	self.searchKeyword = ""
	self.hasSearched = false
	self.filteredFriendList = nil
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnRenderTabItem")

	self.bindData.tabList.onGetTIndex = function(_)
		return 0
	end

	self.bindData.tabList.luaSelectedChanged = self:CreateAction("OnChangeTabSelect")
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.list.onGetTIndex = self:CreateAction("OnGetTIndex")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
	self.bindData.qBtn.luaClick = self:CreateAction("OnLeftBtnClick")
	self.bindData.eBtn.luaClick = self:CreateAction("OnRightBtnClick")
	self.bindData.fullScreenExitBtn.luaClick = self:CreateAction("OnCloseBtnClick")
	local msgEvents = {
		[gEventConstants.TEAM_REFRESH_DATA] = self:CreateAction("OnTeamRefreshData"),
		[gEventConstants.ON_CUSTOM_ROOM_INFO_CHANGE] = self:CreateAction("OnCustomRoomChange"),
		[gEventConstants.ON_CUSTOM_ROOM_MEMBER_CHANGE] = self:CreateAction("OnCustomRoomChange")
	}

	self:RegisterMessageEvents(msgEvents)

	self.groupList = {}
	self.groupSourceList = {}
	self.groupExpanded = true
	self.linkGame = nil
	self.closeCallback = nil
	self.watchIdSet = {}
	self.pidStoreMap = {}
	self.TabIcons = {
		Link = LTConfig.LinkConfig.InvitePanelChanelIcon[1] or 0,
		PrivateLink = LTConfig.LinkConfig.InvitePanelChanelIcon[2] or 0,
		Group = LTConfig.LinkConfig.InvitePanelChanelIcon[3] or 0,
		SubGroup = LTConfig.LinkConfig.InvitePanelChanelIcon[4] or 0
	}
	self.inviteMode = gInviteManager.TYPE.TEAM
	self.isPartyKickMode = false
end

M.OnShow = function(self, _, data)
	gPSNOnlineInviteManager:RefreshSafetySnapshot()

	self.inviteMode = data and data.inviteMode or gInviteManager.TYPE.TEAM
	self.isPartyKickMode = data and data.isPartyKickMode ~= true
	self.linkGame = data and data.linkGame or nil
	self.closeCallback = data and data.closeCallback or nil
	self.selectedTabIndex = self.TabType.Friend
	self.searchKeyword = ""
	self.hasSearched = false
	self.filteredFriendList = nil

	self:RefreshModeView()
	self:SetTabData()

	if not self.isPartyKickMode and self.inviteMode == gInviteManager.TYPE.LINK then
		self.groupExpanded = true

		self.InitGroupList(self)
	end

	self.InitFriendList(self)
end

M.RefreshModeView = function(self)
	if self.isPartyKickMode then
		self.bindData.showTabCtrl = 1
		self.bindData.title = LTConfig.TextScriptTextConfig.GetConfig(89901541).Text
		self.selectedTabIndex = self.TabType.Friend
	else
		self.bindData.showTabCtrl = 0
	end
end

M.OnTeamRefreshData = function(self)
end

M.OnCustomRoomChange = function(self)
	if self.isPartyKickMode then
		self.InitFriendList(self)
	elseif self.inviteMode ~= gInviteManager.TYPE.GAMEPLAY or self.inviteMode ~= gInviteManager.TYPE.LINK then
		self.InitFriendList(self)
	else
		self.InitGroupList(self)
		self.SetList(self)
	end
end

M.OnGetTIndex = function(self, index)
	if self.selectedTabIndex ~= self.TabType.Friend then
		if index ~= 0 then
			return self.InviteListType.Search
		else
			return self.TabType.Friend
		end
	end

	local node = self.groupList[index + 1]

	if not node then
		return self.InviteListType.GroupBig
	end

	return node.type ~= self.InviteListType.Channel and self.InviteListType.GroupBig or node.type
end

M.OnEnable = function(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnDisable = function(self)
	self.UnwatchAll(self)
end

M.OnGroupEnable = function(self)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", true)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "openCommonHalf", true)
end

M.OnGroupDisable = function(self)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", false)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "openCommonHalf", false)
end

M.InitGroupList = function(self)
	self.groupSourceList = {}
	slot1 = pairs
	slot3 = gChatGroupManager:GetChatGroups() or {}

	for _, groupData in slot1(slot3) do
		table.insert(self.groupSourceList, groupData)
	end

	self.RebuildGroupList(self)
end

M.RebuildGroupList = function(self)
	self.groupList = {
		{
			type = self.InviteListType.Channel,
			data = {
				["[\\xbd\\x87\\x8dJ"] = true
			}
		}
	}

	if gClubManager and gClubManager:HasClub() then
		table.insert(self.groupList, {
			type = self.InviteListType.GroupBig,
			data = {
				["[\\xb2\\x82\\x96C"] = true
			}
		})
	end

	if #self.groupSourceList < 0 then
		return
	end

	table.insert(self.groupList, {
		type = self.InviteListType.GroupDropDown,
		expanded = self.groupExpanded
	})

	if self.groupExpanded then
		for _, groupData in ipairs(self.groupSourceList) do
			table.insert(self.groupList, {
				type = self.InviteListType.Group,
				data = groupData
			})
		end
	end
end

M.InitFriendList = function(self)
	self.searchKeyword = ""
	self.hasSearched = false
	self.filteredFriendList = nil
	self.friendList = nil

	if self.isPartyKickMode then
		self.friendList = gPartyManager:GetPartyKickPlayerInfoList()

		self:WatchAll()
		self:SetList()

		return
	end

	slot1 = gFriendManager

	slot1:GetOrderedFriendSimpleInfoList(function (data)
		self.friendList = {}

		for _, v in ipairs(data) do
			local canAdd = not v.InRoom

			if self.inviteMode ~= gInviteManager.TYPE.GAMEPLAY then
				canAdd = self.linkGame and not self.linkGame:ContainsPlayer(v.Pid)
			elseif self.inviteMode ~= gInviteManager.TYPE.LINK then
				local alreadyInCurrentLink = gLinkManager:GetPlayerInLink(v.Pid, gLinkManager.LinkMode)
				canAdd = canAdd and not alreadyInCurrentLink
			end

			canAdd = canAdd and not gPSNOnlineInviteManager:IsInviteBlockedByPSN(v.Pid)

			if canAdd then
				table.insert(self.friendList, v)
			end
		end

		self:FilterAndSortFriendList()
		self:WatchAll()
	end)
end

M.OnClose = function(self)
	local closeCallback = self.closeCallback
	self.closeCallback = nil
	self.linkGame = nil

	if closeCallback then
		closeCallback()
	end
end

local TICK_RATE = 10

M.OnUpdate = function(self)
	self.tick = self.tick + 1

	if TICK_RATE < self.tick then
		self.tick = 0

		self.SetList(self)
	end
end

M.SetTabData = function(self)
	if not self.bindData.tabList then
		return
	end

	if self.isPartyKickMode then
		self.bindData.tabList:SetSimpleList(0)

		return
	end

	local tabCount = self.inviteMode ~= gInviteManager.TYPE.LINK and 1 or #self.TabData

	self.bindData.tabList:SetSimpleList(tabCount)
	Timer.New(function ()
		self.bindData.tabList:SetItemSelected(0, true)
	end, 0.2):Start()
end

M.OnChangeTabSelect = function(self)
	self.selectedTabIndex = self.isPartyKickMode and self.TabType.Friend or self.bindData.tabList.selectedIndex

	self:SetList()
	self.bindData.list:SetNavSelectToTop(true)
end

M.SetList = function(self)
	local count = 0

	if self.selectedTabIndex ~= self.TabType.Friend then
		local currentList = self.filteredFriendList or self.friendList

		if currentList then
			count = #currentList + 1
		else
			count = 1
		end
	elseif self.groupList then
		count = #self.groupList
	end

	self.bindData.list:SetSimpleList(count)

	self.bindData.isEmptyCtrl = count ~= 0 and 1 or 0
end

M.OnRenderTabItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("TeamInviteMenuTabTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local itemData = self.TabData[index + 1]
	store.nameLabel = itemData.name
end

M.OnRenderItem = function(self, btn, index)
	local store, data = nil
	local isFriendTab = self.selectedTabIndex ~= self.TabType.Friend
	local list = nil

	if isFriendTab then
		if index ~= 0 then
			store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

			if not store then
				return
			end

			store.searchInput.luaValueChanged = self.CreateAction(self, "OnSearchInputValueChanged")
			store.searchBtn.luaClick = self.CreateAction(self, "OnSearchBtnClick")

			return
		end

		store = gStoreManager:GetStoreGroup("TeamInviteMenuFriendTemplateStore"):GetStoreByWidget(btn)
		local currentList = self.filteredFriendList or self.friendList
		data = currentList and currentList[index]

		if not store or not data then
			return
		end

		store.userInfo.pid = data.Pid
		store.headBtn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderTooltips", data.Pid)
		local state = CalcStateCtl(data)
		store.inviteBtn.luaClick = self:CreateActionWithArgs("OnInviteBtnClick", data.Pid)
		local inviteType = self.inviteMode
		list = gInviteManager:GetInviteFriendList(inviteType)
		store.stateCtl = state
		self.pidStoreMap[data.Pid] = store
		local checkTeamMember = self.inviteMode ~= gInviteManager.TYPE.TEAM or self.inviteMode ~= gInviteManager.TYPE.LINK

		if checkTeamMember and gTeamManager:GetMember(data.Pid) then
			store.isInCD = 1
			store.cdTimeLabel = TextCommonTextConfig.GetConfig(TextCommonTextConfig.InTeam).Text

			return
		end

		if self.inviteMode ~= gInviteManager.TYPE.PARTY and self.isPartyKickMode then
			store.showInviteTeamBtnCtrl = 0
			store.showKickBtnCtrl = 1
			store.kickBtn.luaClick = self.CreateActionWithArgs(self, "OnKickBtnClick", data.Pid)
		else
			store.showKickBtnCtrl = 0

			if state ~= FriendState.Offline or state ~= FriendState.Busy or state ~= FriendState.SingleWorld and self.inviteMode ~= gInviteManager.TYPE.GAMEPLAY then
				store.showInviteTeamBtnCtrl = 0
			else
				store.showInviteTeamBtnCtrl = 1
			end
		end
	else
		if not index or not btn then
			return
		end

		local node = self.groupList[index + 1]

		if not node then
			return
		end

		if node.type ~= self.InviteListType.GroupDropDown then
			local dropGroup = gStoreManager:GetStoreGroup(btn.Store)
			local dropStore = dropGroup and dropGroup:GetStoreByWidget(btn)

			if dropStore then
				dropStore.expand = self.groupExpanded and 1 or 0
			end

			btn.luaClick = self.CreateAction(self, "OnGroupDropDownClick")

			return
		end

		local sg = gStoreManager:GetStoreGroup("TeamGroupInviteTemplateStore")
		store = sg and sg:GetStoreByWidget(btn)
		data = node.data

		if not store or not data then
			return
		end

		store.inviteBtn.interactable = true
		local iconId = nil

		if data.isLink then
			local modeCfg = nil

			if gLinkManager.LinkMode ~= UX.Game.LinkMode.Private then
				iconId = self.TabIcons.PrivateLink
				modeCfg = LTConfig.LinkModeConfig.LoadAt(2)
			else
				iconId = self.TabIcons.Link
				modeCfg = LTConfig.LinkModeConfig.LoadAt(1)
			end

			data.Name = modeCfg and modeCfg.Name or LTConfig.TextScriptTextConfig.GetConfig(89900115).Text
		elseif data.isClub then
			local clubInfo = gClubManager:GetClubInfo()
			iconId = clubInfo and gClubUIUtils:GetIconIdByIconCfgId(clubInfo.IconCfgId) or 0
			data.Name = clubInfo and gSocialFriendManager:GetClubDisplayName(clubInfo) or ""
		else
			iconId = self.TabIcons.SubGroup
		end

		store.name = data.Name

		if iconId then
			store.Commit(store, "iconId", iconId, COMMIT_FORCE)
		end

		store.inviteBtn.luaClick = self:CreateActionWithArgs("OnSendBtnClick", data)
		local groupInviteType = self.inviteMode ~= gInviteManager.TYPE.GAMEPLAY and gInviteManager.TYPE.GAMEPLAY or gInviteManager.TYPE.TEAM
		list = gInviteManager:GetInviteGroupList(groupInviteType)
	end

	if list then
		local inviteKey = isFriendTab and data.Pid or data.isLink and "LINK" or data.isClub and "CLUB" or data.Id
		local inviteInfo = list[inviteKey]

		if inviteInfo then
			store.isInCD = 1
			local countdown = inviteInfo.stayTime - (gLuaDataManager.serverTime - inviteInfo.timestamp)

			if countdown < inviteInfo.stayTime and countdown <= 0 then
				store.cdTimeLabel = math.floor(countdown) .. "s   "
			end
		else
			store.isInCD = 0
		end
	else
		store.isInCD = 0
	end
end

M.OnGroupDropDownClick = function(self)
	self.groupExpanded = not self.groupExpanded

	self.RebuildGroupList(self)
	self.SetList(self)
end

M.OnRenderTooltips = function(self, pid, btn, popup, _)
	local group = gStoreManager:GetStoreGroup("SocialPalyerTooltipStore")

	if not group then
		return
	end

	local store = group.GetStoreByWidget(group, popup)

	if not store then
		return
	end

	gSocialPalyerTooltipManager:OnRenderToolTips(pid, btn, popup, _)
end

M.OnInviteBtnClick = function(self, pid)
	local friendData = nil

	if self.friendList then
		for _, v in ipairs(self.friendList) do
			if v.Pid ~= pid then
				friendData = v

				break
			end
		end
	end

	local state = CalcStateCtl(friendData)

	if state ~= FriendState.Busy then
		return
	end

	if state ~= FriendState.SingleWorld and self.inviteMode ~= gInviteManager.TYPE.GAMEPLAY then
		return
	end

	if self.inviteMode ~= gInviteManager.TYPE.GAMEPLAY then
		if not self.linkGame or self.linkGame:ContainsPlayer(pid) or not self.CheckCanInviteGameplay(self) then
			return
		end

		if gInviteManager:IsInviteFriendCD(self.inviteMode, pid) then
			return
		end

		gLinkManager:InvitePlayerToPrepareRoom(pid)
		gInviteManager:AddInviteFriend(self.inviteMode, LTConfig.LinkConfig.LinkInviteCountDownTime, pid)
	elseif self.inviteMode ~= gInviteManager.TYPE.LINK then
		if gInviteManager:IsInviteFriendCD(self.inviteMode, pid) then
			return
		end

		gLinkManager:InviteFriendToLink(pid, gLinkManager.LinkMode)
		gInviteManager:AddInviteFriend(self.inviteMode, LTConfig.LinkConfig.LinkInviteCountDownTime, pid)
	elseif self.inviteMode ~= gInviteManager.TYPE.PARTY then
		if gInviteManager:IsInviteFriendCD(self.inviteMode, pid) then
			return
		end

		gCustomRoomMgr:InviteToPartyRoom(pid)
		gInviteManager:AddInviteFriend(self.inviteMode, LTConfig.LinkConfig.LinkInviteCountDownTime, pid)
	else
		gTeamManager:InviteToTeam(pid)
	end

	self.bindData.list:RefreshList()
end

M.CheckCanInviteGameplay = function(self)
	local setting = self.linkGame and self.linkGame.uxData and self.linkGame.uxData.Setting

	if setting and not setting.AllowNonLeaderInvite and not self.linkGame:IsLeader(gPlayerManager.infoLogin.bindData.pid) then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_HasNoPermissions)

		return false
	end

	return true
end

M.OnKickBtnClick = function(self, pid)
	slot2 = gClientToGameDelegate

	slot2:AskKickPartyMember(pid).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		self.bindData.list:RefreshList()
	end
end

M.SendPartyCustomInvite = function(self, data, inviteId)
	local stayTime = LTConfig.LinkConfig.LinkInviteCountDownTime
	local roomInfo = gCustomRoomMgr:GetRoomInfo()
	local partyInfo = roomInfo and roomInfo.PartyInfo

	if not partyInfo then
		return
	end

	local topChannelId = (data.isClub or data.isLink) and gChatTopChannel.Channels or gChatTopChannel.Group
	local subChannelId = data.isClub and UX.Game.MessageChannel.Club or data.isLink and gChatManager:GetLinkChannel() or data.Id

	gInviteManager:AddInviteGroup(gInviteManager.TYPE.TEAM, stayTime, inviteId)
	gSocialChatManager:SendCustomInvite(topChannelId, subChannelId, partyInfo.PartyConfigId, {
		roomId = ulong.tostring(roomInfo.RoomId),
		roomName = roomInfo.Name,
		memberCount = #roomInfo.Members,
		maxMembers = roomInfo.MaxMembers
	})
	self.bindData.list:RefreshList()
end

M.SendGameplayCustomInvite = function(self, data)
	if not self.linkGame then
		return
	end

	if not self.CheckCanInviteGameplay(self) then
		return
	end

	local inviteId = data.isLink and "LINK" or data.isClub and "CLUB" or data.Id

	if gInviteManager:IsInviteGroupCD(gInviteManager.TYPE.GAMEPLAY, inviteId) then
		return
	end

	local cfg = self.linkGame:GetConfig()

	if not cfg then
		return
	end

	local members = self.linkGame:GetMembers()
	local memberCount = members and #members or 1
	local maxMembers = cfg.PlayerNum and cfg.PlayerNum[#cfg.PlayerNum] or 4
	local stayTime = LTConfig.LinkConfig.LinkInviteCountDownTime
	local topChannelId = (data.isClub or data.isLink) and gChatTopChannel.Channels or gChatTopChannel.Group
	local subChannelId = data.isClub and UX.Game.MessageChannel.Club or data.isLink and gChatManager:GetLinkChannel() or data.Id

	gInviteManager:AddInviteGroup(gInviteManager.TYPE.GAMEPLAY, stayTime, inviteId)
	gSocialChatManager:SendCustomInvite(topChannelId, subChannelId, self.linkGame.uxData.GameId, {
		roomId = ulong.tostring(self.linkGame.uxData.Id),
		roomName = cfg.Name or "",
		memberCount = memberCount,
		maxMembers = maxMembers
	})
	self.bindData.list:RefreshList()
end

M.OnSendBtnClick = function(self, data)
	if self.inviteMode ~= gInviteManager.TYPE.GAMEPLAY then
		self.SendGameplayCustomInvite(self, data)

		return
	end

	if self.inviteMode == gInviteManager.TYPE.PARTY and not gTeamManager.allowMemberInvite and not gTeamManager:IsTeamLeader() then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_HasNoPermissions)

		return
	end

	local inviteId = data.isLink and "LINK" or data.isClub and "CLUB" or data.Id

	if gInviteManager:IsInviteGroupCD(gInviteManager.TYPE.TEAM, inviteId) then
		return
	end

	if self.inviteMode ~= gInviteManager.TYPE.PARTY then
		self.SendPartyCustomInvite(self, data, inviteId)

		return
	end

	if data.isClub then
		local stayTime = LTConfig.LinkConfig.LinkInviteCountDownTime

		gInviteManager:AddInviteGroup(gInviteManager.TYPE.TEAM, stayTime, inviteId)
		gCS.IMManager:SendInviteTeam(gChatTopChannel.Channels, UX.Game.MessageChannel.Club, gTeamManager.teamId, gTeamManager:GetTeamNumber())
	elseif data.isLink then
		local stayTime = LTConfig.LinkConfig.LinkInviteCountDownTime

		gInviteManager:AddInviteGroup(gInviteManager.TYPE.TEAM, stayTime, inviteId)
		gCS.IMManager:SendInviteTeam(gChatTopChannel.Channels, gChatManager:GetLinkChannel(), gTeamManager.teamId, gTeamManager:GetTeamNumber())
	else
		gTeamManager:InviteGroupFriendToTeam(data.Id)
		gCS.IMManager:SendInviteTeam(gChatTopChannel.Group, data.Id, gTeamManager.teamId, gTeamManager:GetTeamNumber())
	end

	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_InviteSendGroup, nil, , data.Name)
	self.bindData.list:RefreshList()
end

M.OnCloseBtnClick = function(self)
	gPanelManager:Close(gPanelId.S_TEAM_INVITE_MENU)
end

M.OnSearchInputValueChanged = function(self, inputText)
	self.searchKeyword = inputText or ""
end

M.OnSearchBtnClick = function(self)
	self.hasSearched = true

	if string.is_null_or_empty(self.searchKeyword) then
		self.FilterAndSortFriendList(self)
	else
		self.filteredFriendList = {}
		local sourceList = self.friendList

		if sourceList then
			for _, v in ipairs(sourceList) do
				if v.Name and string.find(string.lower(v.Name), string.lower(self.searchKeyword), 1, true) then
					table.insert(self.filteredFriendList, v)
				end
			end

			table.sort(self.filteredFriendList, function (a, b)
				return GetSortPriority(a) <= GetSortPriority(b)
			end)
		end
	end

	self.SetList(self)
end

M.WatchAll = function(self)
	self.UnwatchAll(self)

	if not self.friendList then
		return
	end

	for _, v in ipairs(self.friendList) do
		local pid = v.Pid
		slot7 = gLinkPlayerHub.cs
		local watchId = slot7:Watch(pid, function (info)
			self:OnPlayerStateChanged(pid, info)
		end)
		self.watchIdSet[pid] = watchId
	end
end

M.UnwatchAll = function(self)
	for pid, watchId in pairs(self.watchIdSet) do
		gLinkPlayerHub.cs:Unwatch(pid, watchId)
	end

	self.watchIdSet = {}
	self.pidStoreMap = {}
end

M.FilterAndSortFriendList = function(self)
	if not self.friendList then
		self.filteredFriendList = nil

		return
	end

	local onlineList = {}

	for _, v in ipairs(self.friendList) do
		if CalcStateCtl(v) == FriendState.Offline then
			table.insert(onlineList, v)
		end
	end

	table.sort(onlineList, function (a, b)
		return GetSortPriority(a) <= GetSortPriority(b)
	end)

	self.filteredFriendList = onlineList
end

M.OnPlayerStateChanged = function(self, pid, info)
	if not self.friendList then
		return
	end

	for _, v in ipairs(self.friendList) do
		if v.Pid ~= pid then
			v.OnlineState = info.OnlineState
			v.LinkMode = info.LinkMode
			v.InMatch = info.InMatch

			break
		end
	end

	if not self.hasSearched then
		self.FilterAndSortFriendList(self)
	else
		self.OnSearchBtnClick(self)
	end

	self.SetList(self)
end

M.OnLeftBtnClick = function(self)
	self.bindData.tabList:SelectItem(0)
end

M.OnRightBtnClick = function(self)
	if self.inviteMode ~= gInviteManager.TYPE.LINK then
		return
	end

	self.bindData.tabList:SelectItem(1)
end
