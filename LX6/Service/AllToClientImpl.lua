-- Original chunk: @Lua\LuaFiles\LX6\Service\AllToClientImpl.lua
-- Decompiled from: 02360_AllToClientImpl.lua_8e39c98e1c19.luajit

slot0 = gRpcChecker
local AllToClientImpl = slot0:CreateRpcImpl()
local LogUtils = LX6.Utils.LogUtilsLua

AllToClientImpl.SyncServerWarn = function(message)
	if gGameManager.Env.isEditor and LogUtils.LogSwitchOn then
		print_warn("服务端错误提示：" .. message)
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900056).Text .. message)
	end
end

AllToClientImpl.SyncServerDebug = function(message)
	if gGameManager.Env.isEditor and LogUtils.LogSwitchOn then
		print_debug("服务端消息：" .. message)
		gDisplayMessageMgr:ShowMessageContent(message)
	end
end

AllToClientImpl.SyncServerLog = function(log)
	if gGameManager.Env.isEditor and LogUtils.LogSwitchOn then
		print_debug(log)
	end
end

AllToClientImpl.SyncNewMail = function(mailHead)
	gNewMailsMgr:AddMailMailByServer(mailHead)
end

AllToClientImpl.SyncDeleteMail = function(mailId)
	gNewMailsMgr:DeleteMailByServer(mailId)
end

AllToClientImpl.SyncPlayerClubNameChanged = function(clubId, name)
	gClubManager:OnSyncPlayerClubNameChanged(clubId, name)
end

AllToClientImpl.SyncPlayerClubIconChanged = function(clubId, iconId)
	gClubManager:OnSyncPlayerClubIconChanged(clubId, iconId)
end

AllToClientImpl.SyncPlayerClubDeclarationChanged = function(clubId, declaration)
	gClubManager:OnSyncPlayerClubDeclarationChanged(clubId, declaration)
end

AllToClientImpl.SyncPlayerClubSettingChanged = function(clubId, setting)
	gClubManager:OnSyncPlayerClubSettingChanged(clubId, setting)
end

AllToClientImpl.SyncPlayerClubSettingsChanged = function(clubId, name, declaration, iconId, setting)
	gClubManager:OnSyncPlayerClubSettingsChanged(clubId, name, declaration, iconId, setting)
end

AllToClientImpl.SyncPlayerClubInfo = function(clubData)
	gClubManager:OnSyncPlayerClubInfo(clubData)
end

AllToClientImpl.SyncPlayerUpdateClubInfo = function(clubData)
	gClubManager:OnSyncPlayerUpdateClubInfo(clubData)
end

AllToClientImpl.SyncPlayerNewMemberJoinedClub = function(newMember)
	gClubManager:OnSyncPlayerNewMemberJoinedClub(newMember)
end

AllToClientImpl.SyncPlayerJoinedClub = function(clubData)
	gClubManager:OnSyncPlayerJoinedClub(clubData)
end

AllToClientImpl.SyncPlayerMemberLeaveClub = function(clubId, memberPid, isKick)
	gClubManager:OnSyncPlayerMemberLeaveClub(clubId, memberPid, isKick)
end

AllToClientImpl.SyncPlayerClubOwnerChanged = function(clubId, newOwner)
	gClubManager:OnSyncPlayerClubOwnerChanged(clubId, newOwner)
end

AllToClientImpl.SyncPlayerRemoveClubApplication = function(clubId, applicantPid)
	gClubManager:OnSyncPlayerRemoveClubApplication(clubId, applicantPid)
end

AllToClientImpl.SyncPlayerClubApplicationListChanged = function(clubId)
end

AllToClientImpl.SyncPlayerClubMemberJobChanged = function(clubId, memberPid, jobType, jobId)
	gClubManager:OnSyncPlayerClubMemberJobChanged(clubId, memberPid, jobType, jobId)
end

AllToClientImpl.SyncPlayerClubMemberInfo = function(clubId, member)
	gClubManager:OnSyncPlayerClubMemberInfo(clubId, member)
end

AllToClientImpl.SyncPlayerClubCustomJobListChanged = function(clubId, jobList)
	gClubManager:OnSyncPlayerClubCustomJobListChanged(clubId, jobList)
end

AllToClientImpl.SyncPlayerClubSystemJobListChanged = function(clubId, jobList)
	gClubManager:OnSyncPlayerClubSystemJobListChanged(clubId, jobList)
end

AllToClientImpl.SyncPlayerClubEvent = function(honorEvent)
	gClubManager:OnSyncPlayerClubEvent(honorEvent)
end

AllToClientImpl.SyncPlayerLastLeaveClubTime = function(lastLeaveTime)
	gClubManager:OnSyncPlayerLastLeaveClubTime(lastLeaveTime)
end

AllToClientImpl.PushMuteEndTime = function(endTime)
	gSocialChatManager:SetHardMuted(endTime)
end

AllToClientImpl.PushSoftMuteEndTime = function(endTime)
	gSocialChatManager:SetSoftMuted(endTime)
end

AllToClientImpl.SendCustomHotPatchAllToClient = function(data)
end

AllToClientImpl.SyncSyncRateLevelUp = function(friendPid, oldLevel, newLevel)
end

AllToClientImpl.PushJoinNewChatGroup = function(chatGroup)
	gChatGroupManager:PushJoinNewChatGroup(chatGroup)
	gSocialChatGroupManager:PushJoinNewChatGroup(chatGroup)
end

AllToClientImpl.PushPlayerImSimpleData = function(simpleData)
	gChatGroupManager:PushPlayerImSimpleData(simpleData)
	gSocialChatGroupManager:PushPlayerImSimpleData(simpleData)
	gSocialChatManager:PushPlayerImSimpleData(simpleData)
end

AllToClientImpl.PushPlayerFavoriteEmojiList = function(urls)
	gSocialChatManager:LoadPersonalEmojiData(urls)
end

AllToClientImpl.PushChatGroupMemberRemove = function(groupId, memberPid)
	gChatGroupManager:PushChatGroupMemberRemove(groupId, memberPid)
	gSocialChatGroupManager:PushChatGroupMemberRemove(groupId, memberPid)
end

AllToClientImpl.PushChatGroupMembersRemove = function(groupId, members)
	gSocialChatGroupManager:PushChatGroupMembersRemove(groupId, members)
end

AllToClientImpl.PushChatGroupMemberJoin = function(friendId, groupId)
	gChatGroupManager:PushChatGroupMemberJoin(friendId, groupId)
	gSocialChatGroupManager:PushChatGroupMemberJoin(friendId, groupId)
end

AllToClientImpl.PushChatGroupInvite = function(inviter, groupId, groupName)
	gChatGroupManager:PushChatGroupInvite(inviter, groupId, groupName)
	gSocialChatGroupManager:PushChatGroupInvite(inviter, groupId, groupName)
end

AllToClientImpl.PushChatGroupDismiss = function(groupId)
	gChatGroupManager:PushChatGroupDismiss(groupId)
	gSocialChatGroupManager:PushChatGroupDismiss(groupId)
end

AllToClientImpl.PushChatGroupNameChanged = function(groupId, name)
	gChatGroupManager:PushChatGroupNameChanged(groupId, name)
	gSocialChatGroupManager:PushChatGroupNameChanged(groupId, name)
end

AllToClientImpl.PushPlayerFriendRelation = function(friendRelation)
	gSocialFriendManager:PushPlayerFriendRelation(friendRelation)
end

AllToClientImpl.PushPlayerFriendSimpleData = function(simpleData)
	gSocialFriendManager:PushPlayerFriendSimpleData(simpleData)
end

AllToClientImpl.PushFriendApplication = function(applicantPid)
	gSocialFriendManager:PushFriendApplication(applicantPid)
end

AllToClientImpl.PushPlayerRemoveFriend = function(targetPid)
	gSocialFriendManager:PushPlayerRemoveFriend(targetPid)
end

AllToClientImpl.PushFriendApplicationReject = function(friendId)
	gSocialFriendManager:PushFriendApplicationReject(friendId)
end

AllToClientImpl.PushChatMessageToClient = function(message)
	gSocialChatManager:OnMessageReceive(message, false, gSocialChatManager.ChatMessageSource.SingleSync)
end

return AllToClientImpl
