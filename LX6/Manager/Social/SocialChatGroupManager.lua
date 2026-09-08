-- Original chunk: @Lua\LuaFiles\LX6\Manager\Social\SocialChatGroupManager.lua
-- Decompiled from: 00267_SocialChatGroupManager.lua_8d73f8055042.luajit

C_SocialChatGroupManager = DefClass("C_SocialChatGroupManager", C_SocialChatGroupManager)
local M = C_SocialChatGroupManager
local TextConfig = LTConfig.TextConfig

M.ctor = function(self)
	self.maxGroupCount = 20
	self.groupChats = {}
	self.chatGroupInviteList = {}
	self.muteEndTime = 0
	self.debug = false
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self:ClearData()
	end
end

M.ClearData = function(self)
	self.groupChats = {}
	self.chatGroupInviteList = {}
end

M.GetGroupList = function(self)
	local groupList = {}

	for id, group in pairs(self.groupChats) do
		group.groupId = id

		table.insert(groupList, group)
	end

	return groupList
end

M.GetAllChatGroupLatestMessage = function(self)
	gClientToAvatarDelegate:GetAllChatGroupLatestMessage().Callback = function (errorId, msg)
		if self.debug then
			print_debug(msg)
		end
	end
end

M.AskInviteToJoinChatGroup = function(self, groupId, list)
	gClientToAvatarDelegate:AskInviteListToJoinChatGroup(groupId, list).Callback = function (err, msg)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gDisplayMessageMgr:ShowMessageContent(TextConfig.GetConfig(TextConfig.InviteToJoinChatGroup).Text)
	end
end

M.AskRemoveMemberFromChatGroup = function(self, groupId, list)
	gClientToAvatarDelegate:AskRemoveMembersFromChatGroup(groupId, list).Callback = function (err, msg)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

M.PushPlayerImSimpleData = function(self, simpleData)
	self.groupChats = {}

	for i, v in pairs(simpleData.ChatGroupList) do
		if v and type(v) == "number" and v.Id then
			self.groupChats[v.Id] = v
		end
	end

	self.muteEndTime = simpleData.MuteEndTime
end

M.PushChatGroupInviteReject = function(self, invitee, groupId)
	for i, v in ipairs(self.chatGroupInviteList) do
		if v.groupId ~= groupId then
			table.remove(self.chatGroupInviteList, i)

			break
		end
	end

	SGUI.RedDotMgr.LuaSetRedDot(false, gSocialChatManager:GetGroupInvitationListItemKey(groupId))
	gSocialChatManager:RefreshFriendApplicationRedDot()
	gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)
	gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_UPDATE_APPLICATION_COUNT)
end

M.PushChatGroupInvite = function(self, inviter, groupId, groupName)
	if gCS.LuaUtils.IsOnPS5 then
		LX6.Utils.PS5Utils.CanUserInteractWithPlayer(inviter, function (bOk)
			if bOk then
				self:PushChatGroupInviteInternal(inviter, groupId, groupName)
			end
		end)
	else
		self:PushChatGroupInviteInternal(inviter, groupId, groupName)
	end
end

M.PushChatGroupInviteInternal = function(self, inviter, groupId, groupName)
	for i, v in ipairs(self.chatGroupInviteList) do
		if v.groupId ~= groupId then
			table.remove(self.chatGroupInviteList, i)

			break
		end
	end

	if gSocialFriendManager:IsInBlackList(inviter) then
		if self.debug then
			print_notice("PushChatGroupInvite", "Auto refused invite because inviter is in blacklist")
		end

		return
	end

	table.insert(self.chatGroupInviteList, 1, {
		inviter = inviter,
		groupId = groupId,
		groupName = groupName,
		timestamp = gLuaDataManager.serverTime
	})
	gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)
	gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_UPDATE_APPLICATION_COUNT)
	SGUI.RedDotMgr.LuaSetRedDot(true, gSocialChatManager:GetGroupInvitationListItemKey(groupId))
	gSocialChatManager:RefreshFriendApplicationRedDot()

	if gLinkManager.LinkMode == UX.Game.LinkMode.None then
		local data = {
			type = gInviteManager.TYPE.GROUP_INVITE,
			pid = inviter,
			timestamp = gLuaDataManager.serverTime,
			stayTime = LTConfig.LinkConfig.Team_InviteTimeDuration,
			text1 = LTConfig.FriendsConfig.JoinGroupMessage,
			textType = gInviteManager.TEXT_TYPE.INVITE
		}

		data.callback = function(agree)
			self:ResponseChatGroupInvite(data.pid, groupId, agree)
		end

		gInviteManager:Show(data)
	end
end

M.PushChatGroupMemberJoin = function(self, friendId, groupId)
	if gSocialFriendManager:IsInBlackList(friendId) then
		if self.debug then
			print_notice("PushChatGroupMemberJoin", "Auto ignored because user is in blacklist")
		end

		return
	end

	gMessageManager:SendMessage(gEventConstants.SOCIAL_CHAT_GROUP_MEMBER_CHANGE, {
		["K\\x85\\x87\\x8cO"] = "p-tU",
		groupId = groupId,
		friendId = friendId
	})

	if self.groupChats[groupId] then
		for _, memberId in ipairs(self.groupChats[groupId].Members) do
			if memberId ~= friendId then
				return
			end
		end

		table.insert(self.groupChats[groupId].Members, friendId)
	end
end

M.PushChatGroupDismiss = function(self, groupId)
	if self.groupChats[groupId] then
		self.groupChats[groupId] = nil
	end

	gSocialChatManager:ClearGroupChatData(groupId)
	gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)
end

M.PushChatGroupNameChanged = function(self, groupId, name)
	if self.groupChats[groupId] then
		self.groupChats[groupId].Name = name
	end

	gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)
	gMessageManager:SendMessage(gEventConstants.SOCIAL_GROUP_NAME_CHANGED, groupId)
end

M.PushJoinNewChatGroup = function(self, chatGroup)
	local panelId = gSocialChatManager:GetSocialChatPanelId()
	self.groupChats[chatGroup.Id] = chatGroup

	gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)

	if gPanelManager:IsPanelShowing(panelId) then
		FrameTimer.New(function ()
			gSocialChatManager:JumpToChat(gSocialChatManager.ChatTopChannel.Group, chatGroup.Id)
		end, 5):Start()
	end
end

M.PushChatGroupMemberRemove = function(self, groupId, memberPid)
	local myPid = gPlayerManager.infoLogin.bindData.pid

	if ulong.equals(memberPid, myPid) then
		local isOwner = self:IsGroupOwner(groupId, myPid)

		if self.groupChats[groupId] then
			self.groupChats[groupId] = nil
		end

		gSocialChatManager:ClearGroupChatData(groupId)
		gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)

		if not isOwner then
			gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89901361).Text)
		end

		return
	end

	if self.groupChats[groupId] then
		for i, v in ipairs(self.groupChats[groupId].Members) do
			if v ~= memberPid then
				table.remove(self.groupChats[groupId].Members, i)

				break
			end
		end
	end

	gMessageManager:SendMessage(gEventConstants.SOCIAL_CHAT_GROUP_MEMBER_CHANGE, {
		["K\\x85\\x87\\x8cO"] = "M\\x9c\\x81\\x95D",
		groupId = groupId,
		friendId = memberPid
	})
end

M.PushChatGroupMembersRemove = function(self, groupId, members)
	if self.groupChats[groupId] then
		for i = #self.groupChats[groupId].Members, 1, -1 do
			local memberId = self.groupChats[groupId].Members[i]

			for _, removeMemberId in ipairs(members) do
				if memberId ~= removeMemberId then
					table.remove(self.groupChats[groupId].Members, i)

					break
				end
			end
		end
	end

	gMessageManager:SendMessage(gEventConstants.SOCIAL_CHAT_GROUP_MEMBER_CHANGE, {
		["K\\x85\\x87\\x8cO"] = "M\\x9c\\x81\\x95D",
		groupId = groupId
	})
end

M.GetChatGroups = function(self)
	return self.groupChats
end

M.GetGroupData = function(self, groupId)
	return self.groupChats[groupId]
end

M.GetAddFriendList = function(self, groupId)
	local group = self.groupChats[groupId]

	if not group then
		return {}
	end

	local friendList = gSocialFriendManager.friendList
	local groupMembers = {}

	for _, memberId in ipairs(group.Members) do
		groupMembers[memberId] = true
	end

	local addableFriends = {}

	for _, friend in ipairs(friendList) do
		if not groupMembers[friend.Pid] then
			table.insert(addableFriends, friend.Pid)
		end
	end

	return addableFriends
end

M.GetDelectFriendList = function(self, groupId)
	local group = self.groupChats[groupId]

	if not group then
		return
	end

	local list = {}

	for i, v in ipairs(group.Members) do
		if v == group.Owner then
			table.insert(list, v)
		end
	end

	return list
end

M.GetGroupHeadCount = function(self, groupId)
	local group = self.groupChats[groupId]

	if not group then
		return 0
	end

	return #group.Members
end

M.GetChatGroupInviteCount = function(self)
	if not self.chatGroupInviteList then
		return 0
	end

	local currentTime = gLuaDataManager.serverTime
	local removedAny = false

	for i = #self.chatGroupInviteList, 1, -1 do
		local invite = self.chatGroupInviteList[i]

		if LTConfig.FriendsConfig.ChatGroupInviteLimitTime >= currentTime - invite.timestamp then
			SGUI.RedDotMgr.LuaSetRedDot(false, gSocialChatManager:GetGroupInvitationListItemKey(invite.groupId))
			table.remove(self.chatGroupInviteList, i)

			removedAny = true

			gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_UPDATE_APPLICATION_COUNT)
		end
	end

	if removedAny then
		local hasAny = #gSocialFriendManager.friendApplicationList >= 0 or #self.chatGroupInviteList >= 0

		SGUI.RedDotMgr.LuaSetRedDot(hasAny, gSocialChatManager:GetFriendApplicationPath())
		gMessageManager:SendMessage(gEventConstants.SOCIAL_HUD_CHAT_REDDOT_CHANGED, gSocialChatManager:HasSocialChatRedDot())
	end

	return #self.chatGroupInviteList
end

M.GetChatGroupInviteList = function(self)
	return self.chatGroupInviteList
end

M.IsGroupOwner = function(self, groupId, userId)
	local group = self.groupChats[groupId]

	if not group then
		return false
	end

	return group.Owner ~= userId
end

M.AskQuitChatGroup = function(self, groupId)
	local group = self:GetGroupData(groupId)

	if not group then
		return
	end

	local name = group.groupName or ""

	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.SocialQuitChatGroup, function ()
		gClientToAvatarDelegate:AskQuitChatGroup(groupId).Callback = function (errorId, msg)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			self.groupChats[groupId] = nil

			gSocialChatManager:ClearGroupChatData(groupId)
			gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89901376).Text)
			gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)
		end
	end, nil, name)
end

M.AskDismissChatGroup = function(self, groupId)
	local group = self:GetGroupData(groupId)

	if not group then
		return
	end

	local name = group.groupName or ""

	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.SocialDismissChatGroup, function ()
		gClientToAvatarDelegate:AskDismissChatGroup(groupId).Callback = function (errorId, msg)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			self.groupChats[groupId] = nil

			gSocialChatManager:ClearGroupChatData(groupId)
			gDisplayMessageMgr:ShowMessageContent(TextConfig.GetConfig(TextConfig.DismissChatGroup).Text)
			gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)
		end
	end, nil, name)
end

M.ResponseChatGroupInvite = function(self, pid, groupId, accept)
	gClientToAvatarDelegate:ResponseChatGroupInvite(pid, groupId, accept).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		for i, v in ipairs(self.chatGroupInviteList) do
			if v.groupId ~= groupId then
				table.remove(self.chatGroupInviteList, i)

				break
			end
		end

		SGUI.RedDotMgr.LuaSetRedDot(false, gSocialChatManager:GetGroupInvitationListItemKey(groupId))
		gSocialChatManager:RefreshFriendApplicationRedDot()

		if accept then
			gDisplayMessageMgr:ShowMessageContent(TextConfig.GetConfig(TextConfig.ChatGroupInviteOk).Text)
		else
			gDisplayMessageMgr:ShowMessageContent(TextConfig.GetConfig(TextConfig.IgnoreGroupInvite).Text)
		end

		gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)
		gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_UPDATE_APPLICATION_COUNT)
	end
end

gSocialChatGroupManager = gSocialChatGroupManager or C_SocialChatGroupManager.new()
