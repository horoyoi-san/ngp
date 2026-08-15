local TextConfig = LTConfig.TextConfig
local M = {
	OnInit = function (self)
		self.maxGroupCount = 10
		self.groupChats = {}
		self.chatGroupInviteList = {}
		self.muteEndTime = 0

		self:InitEvent()
	end,
	ClearData = function (self)
		self.groupChats = {}
	end,
	InitEvent = function (self)
		self.eventHandlers = {
			[gEventConstants.LINK_MODE_CHANGE] = function ()
				self:OnLinkModeChange()
			end
		}

		gMessageManager:RegisterEventHandlers(self.eventHandlers)
	end,
	OnLinkModeChange = function (self, _, data)
		if gLinkManager:CheckInLinkMode() then
			gPanelManager:CheckShow(gPanelId.ONLINE_IN_GAME_HUD_CHAT)
		else
			gPanelManager:Close(gPanelId.ONLINE_IN_GAME_HUD_CHAT)
		end
	end,
	GetAllChatGroupLatestMessage = function (self)
		gClientToAvatarDelegate:GetAllChatGroupLatestMessage().Callback = function (errorId, msg)
			print_debug(msg)
		end
	end,
	AskInviteToJoinChatGroup = function (self, groupId, list)
		for i, v in ipairs(list) do
			gClientToAvatarDelegate:AskInviteToJoinChatGroup(groupId, v).Callback = function (err, msg)
				if err ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end

				gChatUtils.ShowPhoneAppTip(TextConfig.GetConfig(TextConfig.InviteToJoinChatGroup).Text)
			end
		end
	end,
	AskRemoveMemberFromChatGroup = function (self, groupId, list)
		for i, v in ipairs(list) do
			gClientToAvatarDelegate:AskRemoveMemberFromChatGroup(groupId, v).Callback = function (err, msg)
				if err ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end
			end
		end
	end
}

function M:PushPlayerImSimpleData(simpleData)
	self.groupChats = {}

	for i, v in pairs(simpleData.ChatGroupList) do
		if v and type(v) ~= "number" and v.Id then
			self.groupChats[v.Id] = v

			gChatManager:GetOrAddSubChannel(gChatTopChannel.Group, v.Id)
		end
	end

	self.muteEndTime = simpleData.MuteEndTime
end

function M:PushChatGroupInviteReject(invitee, groupId)
	if self.chatGroupInviteList[groupId] then
		self.chatGroupInviteList[groupId] = nil
	end

	gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)
end

function M:PushChatGroupInvite(inviter, groupId, groupName)
	self.chatGroupInviteList[groupId] = {
		inviter = inviter,
		groupId = groupId,
		groupName = groupName,
		groupName = groupName,
		timestamp = gLuaDataManager.serverTime
	}

	gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)
end

function M:PushChatGroupMemberJoin(friendId, groupId)
	if self.groupChats[groupId] then
		table.insert(self.groupChats[groupId].Members, friendId)
	end
end

function M:PushChatGroupDismiss(groupId)
	if self.groupChats[groupId] then
		self.groupChats[groupId] = nil
	end

	gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)
end

function M:PushChatGroupNameChanged(groupId, name)
	if self.groupChats[groupId] then
		self.chatGroups[groupId].Name = name
	end

	gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)
end

function M:PushJoinNewChatGroup(chatGroup)
	self.groupChats[chatGroup.Id] = chatGroup

	print_debug(chatGroup)
	gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)
end

function M:PushChatGroupMemberRemove(groupId, memberPid)
	if self.chatGroups[groupId] then
		for i, v in ipairs(self.chatGroups[groupId].Members) do
			if v == memberPid then
				table.remove(self.chatGroups[groupId].Members, i)

				break
			end
		end
	end
end

function M:GetChatGroups()
	return self.groupChats
end

function M:GetGroupData(groupId)
	return self.groupChats[groupId]
end

function M:GetAddFriendList(groupId)
	local group = self.groupChats[groupId]

	if not group then
		return
	end

	local friendList = gFriendManager:GetFriendPidList()
	local groupList = group.Members
	local list = {}

	for i, v in ipairs(friendList) do
		local isInGroup = false

		for j, k in ipairs(groupList) do
			if v == k then
				isInGroup = true

				break
			end
		end

		if not isInGroup then
			table.insert(list, v)
		end
	end

	return list
end

function M:GetDelectFriendList(groupId)
	local group = self.groupChats[groupId]

	if not group then
		return
	end

	local list = {}

	for i, v in ipairs(group.Members) do
		if v ~= group.Owner then
			table.insert(list, v)
		end
	end

	return list
end

function M:GetGroupHeadCount(groupId)
	local group = self.groupChats[groupId]

	if not group then
		return 0
	end

	return #group.Members
end

function M:GetChatGroupInviteCount()
	if not self.chatGroupInviteList then
		return 0
	end

	local currentTime = gLuaDataManager.serverTime

	for groupId, invite in pairs(self.chatGroupInviteList) do
		if LTConfig.FriendsConfig.ChatGroupInviteLimitTime < currentTime - invite.timestamp then
			self.chatGroupInviteList[groupId] = nil
		end
	end

	local count = 0

	for _, _ in pairs(self.chatGroupInviteList) do
		count = count + 1
	end

	return count
end

function M:GetChatGroupInviteList()
	return self.chatGroupInviteList
end

gChatGroupManager = M
