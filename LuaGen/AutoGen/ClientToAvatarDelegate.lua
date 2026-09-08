-- Original chunk: @Lua\LuaGen\AutoGen\ClientToAvatarDelegate.lua
-- Decompiled from: 00059_ClientToAvatarDelegate.lua_0dbf4201510d.luajit

local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToAvatarDelegate = invoker.New(invoker)

ClientToAvatarDelegate.Sender = function()
	return NetworkManager.LuaGateRpcProcessor
end

SerializerHelper.AskDismissChatGroup_Serializer = function(writer, groupid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
end

ClientToAvatarDelegate.AskDismissChatGroup = function(self, groupid)
	return self.Invoke(self, 153002297, SerializerHelper.AskDismissChatGroup_Serializer, groupid)
end

SerializerHelper.GetManyP2PMessages_Serializer = function(writer, targets)
	SerializeBase.WriteList7Bit(writer, targets, writer.WriteUInt64, 0, "targets", false, RpcLengthLimits.IClientToAvatar_GetManyP2PMessages_targets, nil)
end

ClientToAvatarDelegate.GetManyP2PMessages = function(self, targets)
	return self.Invoke(self, 153021775, SerializerHelper.GetManyP2PMessages_Serializer, targets)
end

SerializerHelper.AskChangeFriendRemark_Serializer = function(writer, friendpid, remark)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
	writer.WriteString(writer, remark, true, "AskChangeFriendRemark.remark", RpcLengthLimits.IClientToAvatar_AskChangeFriendRemark_remark)
end

ClientToAvatarDelegate.AskChangeFriendRemark = function(self, friendpid, remark)
	return self.Invoke(self, 153033811, SerializerHelper.AskChangeFriendRemark_Serializer, friendpid, remark)
end

SerializerHelper.ApplyFriend_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToAvatarDelegate.ApplyFriend = function(self, pid)
	return self.Invoke(self, 153052702, SerializerHelper.ApplyFriend_Serializer, pid)
end

SerializerHelper.GetLinkMessageList_Serializer = function(writer, mode)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(mode, 8, 0), writer.WriteByte, 0)
end

ClientToAvatarDelegate.GetLinkMessageList = function(self, mode)
	return self.Invoke(self, 153053779, SerializerHelper.GetLinkMessageList_Serializer, mode)
end

SerializerHelper.QuerySkey_Serializer = function(writer, skey)
	SerializeBase.WritePrimitive(writer, skey, writer.WriteBoolean, false)
end

ClientToAvatarDelegate.QuerySkey = function(self, skey)
	return self.Invoke(self, 153090217, SerializerHelper.QuerySkey_Serializer, skey)
end

SerializerHelper.AskRemoveMembersFromChatGroup_Serializer = function(writer, groupid, members)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	SerializeBase.WriteList7Bit(writer, members, writer.WriteUInt64, 0, "members", false, RpcLengthLimits.IClientToAvatar_AskRemoveMembersFromChatGroup_members, nil)
end

ClientToAvatarDelegate.AskRemoveMembersFromChatGroup = function(self, groupid, members)
	return self.Invoke(self, 153131149, SerializerHelper.AskRemoveMembersFromChatGroup_Serializer, groupid, members)
end

SerializerHelper.AskAddFavoriteEmoji_Serializer = function(writer, url)
	writer.WriteString(writer, url, false, "AskAddFavoriteEmoji.url", RpcLengthLimits.IClientToAvatar_AskAddFavoriteEmoji_url)
end

ClientToAvatarDelegate.AskAddFavoriteEmoji = function(self, url)
	return self.Invoke(self, 153131661, SerializerHelper.AskAddFavoriteEmoji_Serializer, url)
end

SerializerHelper.AskFriendRemoveFromSpecialList_Serializer = function(writer, friend)
	SerializeBase.WritePrimitive(writer, friend, writer.WriteUInt64, 0)
end

ClientToAvatarDelegate.AskFriendRemoveFromSpecialList = function(self, friend)
	return self.Invoke(self, 153152165, SerializerHelper.AskFriendRemoveFromSpecialList_Serializer, friend)
end

SerializerHelper.SendMessageToTeam_Serializer = function(writer, text, isaudio)
	writer.WriteString(writer, text, false, "SendMessageToTeam.text", RpcLengthLimits.IClientToAvatar_SendMessageToTeam_text)
	SerializeBase.WritePrimitive(writer, isaudio, writer.WriteBoolean, false)
end

ClientToAvatarDelegate.SendMessageToTeam = function(self, text, isaudio)
	return self.Invoke(self, 153153123, SerializerHelper.SendMessageToTeam_Serializer, text, isaudio)
end

SerializerHelper.AskFriendAddToSpecialList_Serializer = function(writer, friend)
	SerializeBase.WritePrimitive(writer, friend, writer.WriteUInt64, 0)
end

ClientToAvatarDelegate.AskFriendAddToSpecialList = function(self, friend)
	return self.Invoke(self, 153203030, SerializerHelper.AskFriendAddToSpecialList_Serializer, friend)
end

SerializerHelper.SendMessageToLink_Serializer = function(writer, text, mode, isaudio)
	writer.WriteString(writer, text, false, "SendMessageToLink.text", RpcLengthLimits.IClientToAvatar_SendMessageToLink_text)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(mode, 8, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, isaudio, writer.WriteBoolean, false)
end

ClientToAvatarDelegate.SendMessageToLink = function(self, text, mode, isaudio)
	return self.Invoke(self, 153206656, SerializerHelper.SendMessageToLink_Serializer, text, mode, isaudio)
end

SerializerHelper.SendMessageToPlayer_Serializer = function(writer, pid, text, isaudio)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	writer.WriteString(writer, text, false, "SendMessageToPlayer.text", RpcLengthLimits.IClientToAvatar_SendMessageToPlayer_text)
	SerializeBase.WritePrimitive(writer, isaudio, writer.WriteBoolean, false)
end

ClientToAvatarDelegate.SendMessageToPlayer = function(self, pid, text, isaudio)
	return self.Invoke(self, 153206753, SerializerHelper.SendMessageToPlayer_Serializer, pid, text, isaudio)
end

SerializerHelper.GetLinkMessages_Serializer = function(writer, timestamp, mode)
	SerializeBase.WritePrimitive(writer, timestamp, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(mode, 8, 0), writer.WriteByte, 0)
end

ClientToAvatarDelegate.GetLinkMessages = function(self, timestamp, mode)
	return self.Invoke(self, 153221360, SerializerHelper.GetLinkMessages_Serializer, timestamp, mode)
end

SerializerHelper.AskChangeChatGroupName_Serializer = function(writer, groupid, name)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	writer.WriteString(writer, name, false, "AskChangeChatGroupName.name", RpcLengthLimits.IClientToAvatar_AskChangeChatGroupName_name)
end

ClientToAvatarDelegate.AskChangeChatGroupName = function(self, groupid, name)
	return self.Invoke(self, 153268543, SerializerHelper.AskChangeChatGroupName_Serializer, groupid, name)
end

SerializerHelper.GetFriendApplicationCountToMe_Serializer = function(writer)
end

ClientToAvatarDelegate.GetFriendApplicationCountToMe = function(self)
	return self.Invoke(self, 153281043, SerializerHelper.GetFriendApplicationCountToMe_Serializer)
end

SerializerHelper.GetP2PLatestMessageList_Serializer = function(writer, targets)
	SerializeBase.WriteList7Bit(writer, targets, writer.WriteUInt64, 0, "targets", false, RpcLengthLimits.IClientToAvatar_GetP2PLatestMessageList_targets, nil)
end

ClientToAvatarDelegate.GetP2PLatestMessageList = function(self, targets)
	return self.Invoke(self, 153294064, SerializerHelper.GetP2PLatestMessageList_Serializer, targets)
end

SerializerHelper.ResponseFriendApplication_Serializer = function(writer, pid, accept)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

ClientToAvatarDelegate.ResponseFriendApplication = function(self, pid, accept)
	return self.Invoke(self, 153299628, SerializerHelper.ResponseFriendApplication_Serializer, pid, accept)
end

SerializerHelper.GetPlayerPublicInfo_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToAvatarDelegate.GetPlayerPublicInfo = function(self, pid)
	return self.Invoke(self, 153302145, SerializerHelper.GetPlayerPublicInfo_Serializer, pid)
end

SerializerHelper.AskRemoveMemberFromChatGroup_Serializer = function(writer, groupid, memberid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, memberid, writer.WriteUInt64, 0)
end

ClientToAvatarDelegate.AskRemoveMemberFromChatGroup = function(self, groupid, memberid)
	return self.Invoke(self, 153319273, SerializerHelper.AskRemoveMemberFromChatGroup_Serializer, groupid, memberid)
end

SerializerHelper.DeleteFriend_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToAvatarDelegate.DeleteFriend = function(self, pid)
	return self.Invoke(self, 153322775, SerializerHelper.DeleteFriend_Serializer, pid)
end

SerializerHelper.GetChatGroupMessagesWithRange_Serializer = function(writer, groupid, starttimestamp, endtimestamp, count)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, starttimestamp, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, endtimestamp, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToAvatarDelegate.GetChatGroupMessagesWithRange = function(self, groupid, starttimestamp, endtimestamp, count)
	return self.Invoke(self, 153337480, SerializerHelper.GetChatGroupMessagesWithRange_Serializer, groupid, starttimestamp, endtimestamp, count)
end

SerializerHelper.RemoveLocation_Serializer = function(writer)
end

ClientToAvatarDelegate.RemoveLocation = function(self)
	self.Notify(self, 153352641, SerializerHelper.RemoveLocation_Serializer)
end

SerializerHelper.AskBanUser_Serializer = function(writer, banreasonid)
	SerializeBase.WritePrimitive(writer, banreasonid, writer.WriteUInt32, 0)
end

ClientToAvatarDelegate.AskBanUser = function(self, banreasonid)
	return self.Invoke(self, 153357159, SerializerHelper.AskBanUser_Serializer, banreasonid)
end

SerializerHelper.SendMessageToClub_Serializer = function(writer, text, isaudio)
	writer.WriteString(writer, text, false, "SendMessageToClub.text", RpcLengthLimits.IClientToAvatar_SendMessageToClub_text)
	SerializeBase.WritePrimitive(writer, isaudio, writer.WriteBoolean, false)
end

ClientToAvatarDelegate.SendMessageToClub = function(self, text, isaudio)
	return self.Invoke(self, 153384512, SerializerHelper.SendMessageToClub_Serializer, text, isaudio)
end

SerializerHelper.SendMessageToRoom_Serializer = function(writer, text, isaudio)
	writer.WriteString(writer, text, false, "SendMessageToRoom.text", RpcLengthLimits.IClientToAvatar_SendMessageToRoom_text)
	SerializeBase.WritePrimitive(writer, isaudio, writer.WriteBoolean, false)
end

ClientToAvatarDelegate.SendMessageToRoom = function(self, text, isaudio)
	return self.Invoke(self, 153392657, SerializerHelper.SendMessageToRoom_Serializer, text, isaudio)
end

SerializerHelper.AskNewHotFixPatch_Serializer = function(writer, version, md5, clientversion)
	SerializeBase.WritePrimitive(writer, version, writer.WriteInt32, 0)
	writer.WriteString(writer, md5, true, "AskNewHotFixPatch.md5", RpcLengthLimits.IClientToAvatar_AskNewHotFixPatch_md5)
	SerializeBase.WritePrimitive(writer, clientversion, writer.WriteInt32, 0)
end

ClientToAvatarDelegate.AskNewHotFixPatch = function(self, version, md5, clientversion)
	return self.Invoke(self, 153412615, SerializerHelper.AskNewHotFixPatch_Serializer, version, md5, clientversion)
end

SerializerHelper.TestToGameServer_Serializer = function(writer, senddatalength, recvdatalength, count, isboradcast)
	SerializeBase.WritePrimitive(writer, senddatalength, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, recvdatalength, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isboradcast, writer.WriteBoolean, false)
end

ClientToAvatarDelegate.TestToGameServer = function(self, senddatalength, recvdatalength, count, isboradcast)
	return self.Invoke(self, 153483607, SerializerHelper.TestToGameServer_Serializer, senddatalength, recvdatalength, count, isboradcast)
end

SerializerHelper.AskRemoveFavoriteEmojiBatch_Serializer = function(writer, urls)
	SerializeBase.WriteList7Bit(writer, urls, SerializeBase.WriteStringWrap(false, "urls", RpcLengthLimits.IClientToAvatar_AskRemoveFavoriteEmojiBatch_urls_String), nil, "urls", false, RpcLengthLimits.IClientToAvatar_AskRemoveFavoriteEmojiBatch_urls, nil)
end

ClientToAvatarDelegate.AskRemoveFavoriteEmojiBatch = function(self, urls)
	return self.Invoke(self, 153494992, SerializerHelper.AskRemoveFavoriteEmojiBatch_Serializer, urls)
end

SerializerHelper.ResponseChatGroupInvite_Serializer = function(writer, inviterpid, groupid, accept)
	SerializeBase.WritePrimitive(writer, inviterpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

ClientToAvatarDelegate.ResponseChatGroupInvite = function(self, inviterpid, groupid, accept)
	return self.Invoke(self, 153496857, SerializerHelper.ResponseChatGroupInvite_Serializer, inviterpid, groupid, accept)
end

SerializerHelper.AskSetFavoriteEmojiAsFirst_Serializer = function(writer, url)
	writer.WriteString(writer, url, false, "AskSetFavoriteEmojiAsFirst.url", RpcLengthLimits.IClientToAvatar_AskSetFavoriteEmojiAsFirst_url)
end

ClientToAvatarDelegate.AskSetFavoriteEmojiAsFirst = function(self, url)
	return self.Invoke(self, 153500365, SerializerHelper.AskSetFavoriteEmojiAsFirst_Serializer, url)
end

SerializerHelper.AskInviteToJoinChatGroup_Serializer = function(writer, groupid, inviteepid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, inviteepid, writer.WriteUInt64, 0)
end

ClientToAvatarDelegate.AskInviteToJoinChatGroup = function(self, groupid, inviteepid)
	return self.Invoke(self, 153517540, SerializerHelper.AskInviteToJoinChatGroup_Serializer, groupid, inviteepid)
end

SerializerHelper.GetTeamLatestMessage_Serializer = function(writer)
end

ClientToAvatarDelegate.GetTeamLatestMessage = function(self)
	return self.Invoke(self, 153526642, SerializerHelper.GetTeamLatestMessage_Serializer)
end

SerializerHelper.ReportLocation_Serializer = function(writer, longitude, latitude)
	SerializeBase.WritePrimitive(writer, longitude, writer.WriteDouble, 0)
	SerializeBase.WritePrimitive(writer, latitude, writer.WriteDouble, 0)
end

ClientToAvatarDelegate.ReportLocation = function(self, longitude, latitude)
	self.Notify(self, 153529199, SerializerHelper.ReportLocation_Serializer, longitude, latitude)
end

SerializerHelper.GetRoomMessages_Serializer = function(writer, timestamp)
	SerializeBase.WritePrimitive(writer, timestamp, writer.WriteUInt32, 0)
end

ClientToAvatarDelegate.GetRoomMessages = function(self, timestamp)
	return self.Invoke(self, 153550766, SerializerHelper.GetRoomMessages_Serializer, timestamp)
end

SerializerHelper.RequestPatchesCheckDataFromAvatar_Serializer = function(writer, clientversion, patchversion)
	SerializeBase.WritePrimitive(writer, clientversion, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, patchversion, writer.WriteInt32, 0)
end

ClientToAvatarDelegate.RequestPatchesCheckDataFromAvatar = function(self, clientversion, patchversion)
	return self.Invoke(self, 153556145, SerializerHelper.RequestPatchesCheckDataFromAvatar_Serializer, clientversion, patchversion)
end

SerializerHelper.AskFriendRemoveFromBlacklist_Serializer = function(writer, friendpid)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
end

ClientToAvatarDelegate.AskFriendRemoveFromBlacklist = function(self, friendpid)
	return self.Invoke(self, 153558231, SerializerHelper.AskFriendRemoveFromBlacklist_Serializer, friendpid)
end

SerializerHelper.GetLinkLatestMessage_Serializer = function(writer, mode)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(mode, 8, 0), writer.WriteByte, 0)
end

ClientToAvatarDelegate.GetLinkLatestMessage = function(self, mode)
	return self.Invoke(self, 153579016, SerializerHelper.GetLinkLatestMessage_Serializer, mode)
end

SerializerHelper.RequestPatchesFromAvatar_Serializer = function(writer, versions, clientversion)
	SerializeBase.WriteList7Bit(writer, versions, writer.WriteInt32, 0, "versions", false, RpcLengthLimits.IClientToAvatar_RequestPatchesFromAvatar_versions, nil)
	SerializeBase.WritePrimitive(writer, clientversion, writer.WriteInt32, 0)
end

ClientToAvatarDelegate.RequestPatchesFromAvatar = function(self, versions, clientversion)
	return self.Invoke(self, 153582205, SerializerHelper.RequestPatchesFromAvatar_Serializer, versions, clientversion)
end

SerializerHelper.GetSimplePlayerInfoByPidList_Serializer = function(writer, pids)
	SerializeBase.WriteList7Bit(writer, pids, writer.WriteUInt64, 0, "pids", false, RpcLengthLimits.IClientToAvatar_GetSimplePlayerInfoByPidList_pids, nil)
end

ClientToAvatarDelegate.GetSimplePlayerInfoByPidList = function(self, pids)
	return self.Invoke(self, 153582555, SerializerHelper.GetSimplePlayerInfoByPidList_Serializer, pids)
end

SerializerHelper.GetTeamMessages_Serializer = function(writer, timestamp)
	SerializeBase.WritePrimitive(writer, timestamp, writer.WriteUInt32, 0)
end

ClientToAvatarDelegate.GetTeamMessages = function(self, timestamp)
	return self.Invoke(self, 153622327, SerializerHelper.GetTeamMessages_Serializer, timestamp)
end

SerializerHelper.SendMessageToLocation_Serializer = function(writer, text, isaudio)
	writer.WriteString(writer, text, false, "SendMessageToLocation.text", RpcLengthLimits.IClientToAvatar_SendMessageToLocation_text)
	SerializeBase.WritePrimitive(writer, isaudio, writer.WriteBoolean, false)
end

ClientToAvatarDelegate.SendMessageToLocation = function(self, text, isaudio)
	return self.Invoke(self, 153650198, SerializerHelper.SendMessageToLocation_Serializer, text, isaudio)
end

SerializerHelper.GetClubMessages_Serializer = function(writer, timestamp)
	SerializeBase.WritePrimitive(writer, timestamp, writer.WriteUInt32, 0)
end

ClientToAvatarDelegate.GetClubMessages = function(self, timestamp)
	return self.Invoke(self, 153658691, SerializerHelper.GetClubMessages_Serializer, timestamp)
end

SerializerHelper.MarkAsReadPrivateMessage_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToAvatarDelegate.MarkAsReadPrivateMessage = function(self, pid)
	return self.Invoke(self, 153680669, SerializerHelper.MarkAsReadPrivateMessage_Serializer, pid)
end

SerializerHelper.AskCreateChatGroup_Serializer = function(writer, groupname)
	writer.WriteString(writer, groupname, false, "AskCreateChatGroup.groupName", RpcLengthLimits.IClientToAvatar_AskCreateChatGroup_groupName)
end

ClientToAvatarDelegate.AskCreateChatGroup = function(self, groupname)
	return self.Invoke(self, 153682685, SerializerHelper.AskCreateChatGroup_Serializer, groupname)
end

SerializerHelper.AskQuitChatGroup_Serializer = function(writer, groupid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
end

ClientToAvatarDelegate.AskQuitChatGroup = function(self, groupid)
	return self.Invoke(self, 153689105, SerializerHelper.AskQuitChatGroup_Serializer, groupid)
end

SerializerHelper.AskInviteListToJoinChatGroup_Serializer = function(writer, groupid, invitees)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	SerializeBase.WriteList7Bit(writer, invitees, writer.WriteUInt64, 0, "invitees", false, RpcLengthLimits.IClientToAvatar_AskInviteListToJoinChatGroup_invitees, nil)
end

ClientToAvatarDelegate.AskInviteListToJoinChatGroup = function(self, groupid, invitees)
	return self.Invoke(self, 153691184, SerializerHelper.AskInviteListToJoinChatGroup_Serializer, groupid, invitees)
end

SerializerHelper.AskRemoveFavoriteEmoji_Serializer = function(writer, url)
	writer.WriteString(writer, url, false, "AskRemoveFavoriteEmoji.url", RpcLengthLimits.IClientToAvatar_AskRemoveFavoriteEmoji_url)
end

ClientToAvatarDelegate.AskRemoveFavoriteEmoji = function(self, url)
	return self.Invoke(self, 153715200, SerializerHelper.AskRemoveFavoriteEmoji_Serializer, url)
end

SerializerHelper.GetFriendApplicationListToMe_Serializer = function(writer)
end

ClientToAvatarDelegate.GetFriendApplicationListToMe = function(self)
	return self.Invoke(self, 153718831, SerializerHelper.GetFriendApplicationListToMe_Serializer)
end

SerializerHelper.AskFriendAddToBlacklist_Serializer = function(writer, friendpid)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
end

ClientToAvatarDelegate.AskFriendAddToBlacklist = function(self, friendpid)
	return self.Invoke(self, 153751082, SerializerHelper.AskFriendAddToBlacklist_Serializer, friendpid)
end

SerializerHelper.GetGmSdkToken_Serializer = function(writer, lang)
	writer.WriteString(writer, lang, false, "GetGmSdkToken.lang", RpcLengthLimits.IClientToAvatar_GetGmSdkToken_lang)
end

ClientToAvatarDelegate.GetGmSdkToken = function(self, lang)
	return self.Invoke(self, 153753706, SerializerHelper.GetGmSdkToken_Serializer, lang)
end

SerializerHelper.HasFriendApplicationToOther_Serializer = function(writer, friendpid)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
end

ClientToAvatarDelegate.HasFriendApplicationToOther = function(self, friendpid)
	return self.Invoke(self, 153773758, SerializerHelper.HasFriendApplicationToOther_Serializer, friendpid)
end

SerializerHelper.GetRoomLatestMessage_Serializer = function(writer)
end

ClientToAvatarDelegate.GetRoomLatestMessage = function(self)
	return self.Invoke(self, 153774205, SerializerHelper.GetRoomLatestMessage_Serializer)
end

SerializerHelper.DavinciCode_Serializer = function(writer, code)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(code, 96, 0), writer.WriteByte, 0)
end

ClientToAvatarDelegate.DavinciCode = function(self, code)
	self.Notify(self, 153804824, SerializerHelper.DavinciCode_Serializer, code)
end

SerializerHelper.AskChatGroupSetRecvMsg_Serializer = function(writer, groupid, reject)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, reject, writer.WriteBoolean, false)
end

ClientToAvatarDelegate.AskChatGroupSetRecvMsg = function(self, groupid, reject)
	return self.Invoke(self, 153819459, SerializerHelper.AskChatGroupSetRecvMsg_Serializer, groupid, reject)
end

SerializerHelper.SendMessageToChatGroup_Serializer = function(writer, groupid, text, isaudio)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	writer.WriteString(writer, text, false, "SendMessageToChatGroup.text", RpcLengthLimits.IClientToAvatar_SendMessageToChatGroup_text)
	SerializeBase.WritePrimitive(writer, isaudio, writer.WriteBoolean, false)
end

ClientToAvatarDelegate.SendMessageToChatGroup = function(self, groupid, text, isaudio)
	return self.Invoke(self, 153822735, SerializerHelper.SendMessageToChatGroup_Serializer, groupid, text, isaudio)
end

SerializerHelper.AskSetRejectAllFriendApply_Serializer = function(writer, reject)
	SerializeBase.WritePrimitive(writer, reject, writer.WriteBoolean, false)
end

ClientToAvatarDelegate.AskSetRejectAllFriendApply = function(self, reject)
	return self.Invoke(self, 153843735, SerializerHelper.AskSetRejectAllFriendApply_Serializer, reject)
end

SerializerHelper.GetChatGroupMessages_Serializer = function(writer, groupid, timestamp)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, timestamp, writer.WriteUInt32, 0)
end

ClientToAvatarDelegate.GetChatGroupMessages = function(self, groupid, timestamp)
	return self.Invoke(self, 153890358, SerializerHelper.GetChatGroupMessages_Serializer, groupid, timestamp)
end

SerializerHelper.GetPlayerBeLikeCount_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToAvatarDelegate.GetPlayerBeLikeCount = function(self, pid)
	return self.Invoke(self, 153892703, SerializerHelper.GetPlayerBeLikeCount_Serializer, pid)
end

SerializerHelper.GetAllChatGroupLatestMessage_Serializer = function(writer)
end

ClientToAvatarDelegate.GetAllChatGroupLatestMessage = function(self)
	return self.Invoke(self, 153934570, SerializerHelper.GetAllChatGroupLatestMessage_Serializer)
end

SerializerHelper.GetP2PMessageList_Serializer = function(writer, friendpid, timestamp)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, timestamp, writer.WriteUInt32, 0)
end

ClientToAvatarDelegate.GetP2PMessageList = function(self, friendpid, timestamp)
	return self.Invoke(self, 153934870, SerializerHelper.GetP2PMessageList_Serializer, friendpid, timestamp)
end

SerializerHelper.AskGetFavoriteEmojiList_Serializer = function(writer)
end

ClientToAvatarDelegate.AskGetFavoriteEmojiList = function(self)
	return self.Invoke(self, 153961855, SerializerHelper.AskGetFavoriteEmojiList_Serializer)
end

SerializerHelper.ResponseAllFriendApplication_Serializer = function(writer, pids, accept)
	SerializeBase.WriteList7Bit(writer, pids, writer.WriteUInt64, 0, "pids", false, RpcLengthLimits.IClientToAvatar_ResponseAllFriendApplication_pids, nil)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

ClientToAvatarDelegate.ResponseAllFriendApplication = function(self, pids, accept)
	return self.Invoke(self, 153977689, SerializerHelper.ResponseAllFriendApplication_Serializer, pids, accept)
end

SerializerHelper.GetP2PMessageListWithRange_Serializer = function(writer, friendpid, starttimestamp, endtimestamp, count)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, starttimestamp, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, endtimestamp, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToAvatarDelegate.GetP2PMessageListWithRange = function(self, friendpid, starttimestamp, endtimestamp, count)
	return self.Invoke(self, 153992960, SerializerHelper.GetP2PMessageListWithRange_Serializer, friendpid, starttimestamp, endtimestamp, count)
end

SerializerHelper.GetPlayerState_Serializer = function(writer, pidlist)
	SerializeBase.WriteList7Bit(writer, pidlist, writer.WriteUInt64, 0, "pidlist", false, RpcLengthLimits.IClientToAvatar_GetPlayerState_pidList, nil)
end

ClientToAvatarDelegate.GetPlayerState = function(self, pidlist)
	return self.Invoke(self, 153995909, SerializerHelper.GetPlayerState_Serializer, pidlist)
end

return ClientToAvatarDelegate
