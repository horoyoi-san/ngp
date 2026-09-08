-- Original chunk: @Lua\LuaFiles\LX6\Manager\Chat\ChatGroupManager.lua
-- Decompiled from: 00290_ChatGroupManager.lua_6274fd9a762a.luajit

local TextConfig = LTConfig.TextConfig
local M = {
	OnInit = function (self)
		self.maxGroupCount = 10
		self.groupChats = {}
		self.chatGroupInviteList = {}
		self.muteEndTime = 0
	end,
	ClearData = function (self)
		self.groupChats = {}
	end,
	GetAllChatGroupLatestMessage = function (self)
		slot1 = gClientToAvatarDelegate

		slot1:GetAllChatGroupLatestMessage().Callback = function (errorId, msg)
			print_debug(msg)
		end
	end,
	AskInviteToJoinChatGroup = function (self, groupId, list)
		for i, v in ipairs(list) do
			slot8 = gClientToAvatarDelegate

			slot8:AskInviteToJoinChatGroup(groupId, v).Callback = function (err, msg)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end

				gDisplayMessageMgr:ShowMessageContent(TextConfig.GetConfig(TextConfig.InviteToJoinChatGroup).Text)
			end
		end
	end,
	AskRemoveMemberFromChatGroup = function (self, groupId, list)
		for i, v in ipairs(list) do
			slot8 = gClientToAvatarDelegate

			slot8:AskRemoveMemberFromChatGroup(groupId, v).Callback = function (err, msg)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end
			end
		end
	end
}

M.PushPlayerImSimpleData = function(self, simpleData)
	self.groupChats = {}

	for i, v in pairs(simpleData.ChatGroupList) do
		if v and type(v) == "number" and v.Id then
			self.groupChats[v.Id] = v

			gChatManager:GetOrAddSubChannel(gChatTopChannel.Group, v.Id)
		end
	end

	self.muteEndTime = simpleData.MuteEndTime
end

M.PushChatGroupInviteReject = function(self, invitee, groupId)
	if self.chatGroupInviteList[groupId] then
		self.chatGroupInviteList[groupId] = nil
	end

	gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)
end

M.PushChatGroupInvite = function(self, inviter, groupId, groupName)
	self.chatGroupInviteList[groupId] = {
		inviter = inviter,
		groupId = groupId,
		groupName = groupName,
		groupName = groupName,
		timestamp = gLuaDataManager.serverTime
	}

	gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)
end

M.PushChatGroupMemberJoin = function(self, friendId, groupId)
	if self.groupChats[groupId] then
		table.insert(self.groupChats[groupId].Members, friendId)
	end
end

M.PushChatGroupDismiss = function(self, groupId)
	if self.groupChats[groupId] then
		self.groupChats[groupId] = nil
	end

	gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)
end

M.PushChatGroupNameChanged = function(self, groupId, name)
	if self.groupChats[groupId] then
		self.groupChats[groupId].Name = name
	end

	gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)
end

M.PushJoinNewChatGroup = function(self, chatGroup)
	self.groupChats[chatGroup.Id] = chatGroup

	print_debug(chatGroup)
	gMessageManager:SendMessage(gEventConstants.CHAT_REFRESH_GROUP_DATA)
end

M.PushChatGroupMemberRemove = function(self, groupId, memberPid)
	if not self.groupChats then
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
		return
	end

	local friendList = gFriendManager:GetFriendPidList()
	local groupList = group.Members
	local list = {}

	for i, v in ipairs(friendList) do
		local isInGroup = false

		for j, k in ipairs(groupList) do
			if v ~= k then
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

	for groupId, invite in pairs(self.chatGroupInviteList) do
		if LTConfig.FriendsConfig.ChatGroupInviteLimitTime >= currentTime - invite.timestamp then
			self.chatGroupInviteList[groupId] = nil
		end
	end

	local count = 0

	for _, _ in pairs(self.chatGroupInviteList) do
		count = count + 1
	end

	return count
end

M.GetChatGroupInviteList = function(self)
	return self.chatGroupInviteList
end

gChatGroupManager = M
