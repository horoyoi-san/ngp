local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToAvatarDelegate = invoker:New()

function ClientToAvatarDelegate.Sender()
	return NetworkManager.LuaGateRpcProcessor
end

function SerializerHelper.ResponseChatGroupInvite_Serializer(writer, inviterpid, groupid, accept)
	SerializeBase.WritePrimitive(writer, inviterpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

function ClientToAvatarDelegate:ResponseChatGroupInvite(inviterpid, groupid, accept)
	return self:Invoke(153013539, SerializerHelper.ResponseChatGroupInvite_Serializer, inviterpid, groupid, accept)
end

function SerializerHelper.AskChangeFriendRemark_Serializer(writer, friendpid, remark)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
	writer:WriteString(remark, true, "remark", 256)
end

function ClientToAvatarDelegate:AskChangeFriendRemark(friendpid, remark)
	return self:Invoke(153018191, SerializerHelper.AskChangeFriendRemark_Serializer, friendpid, remark)
end

function SerializerHelper.GetManyP2PMessages_Serializer(writer, targets)
	SerializeBase.WriteList(writer, targets, writer.WriteUInt64, 0, "targets", false, 200, nil)
end

function ClientToAvatarDelegate:GetManyP2PMessages(targets)
	return self:Invoke(153019981, SerializerHelper.GetManyP2PMessages_Serializer, targets)
end

function SerializerHelper.ForceStartFriendRoom_Serializer(writer, roomid)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteUInt64, 0)
end

function ClientToAvatarDelegate:ForceStartFriendRoom(roomid)
	return self:Invoke(153067403, SerializerHelper.ForceStartFriendRoom_Serializer, roomid)
end

function SerializerHelper.GetFriendApplicationCountToMe_Serializer(writer)
	return
end

function ClientToAvatarDelegate:GetFriendApplicationCountToMe()
	return self:Invoke(153073222, SerializerHelper.GetFriendApplicationCountToMe_Serializer)
end

function SerializerHelper.AskRemoveMemberFromChatGroup_Serializer(writer, groupid, memberid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, memberid, writer.WriteUInt64, 0)
end

function ClientToAvatarDelegate:AskRemoveMemberFromChatGroup(groupid, memberid)
	return self:Invoke(153077118, SerializerHelper.AskRemoveMemberFromChatGroup_Serializer, groupid, memberid)
end

function SerializerHelper.SyncQueryGameObjectFilter_Serializer(writer, id, list)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteList(writer, list, SerializeBase.WriteComplexWrap(SerializeAuto.WriteQueryGameObjectFilter, "QueryGameObjectFilter", false), nil, "list", false, 10240, nil)
end

function ClientToAvatarDelegate:SyncQueryGameObjectFilter(id, list)
	self:Notify(153103763, SerializerHelper.SyncQueryGameObjectFilter_Serializer, id, list)
end

function SerializerHelper.TuoGuan_Serializer(writer)
	return
end

function ClientToAvatarDelegate:TuoGuan()
	return self:Invoke(153120154, SerializerHelper.TuoGuan_Serializer)
end

function SerializerHelper.GetPlayerState_Serializer(writer, pidlist)
	SerializeBase.WriteList(writer, pidlist, writer.WriteUInt64, 0, "pidlist", false, 200, nil)
end

function ClientToAvatarDelegate:GetPlayerState(pidlist)
	return self:Invoke(153131069, SerializerHelper.GetPlayerState_Serializer, pidlist)
end

function SerializerHelper.GetFriendApplicationListToMe_Serializer(writer)
	return
end

function ClientToAvatarDelegate:GetFriendApplicationListToMe()
	return self:Invoke(153132259, SerializerHelper.GetFriendApplicationListToMe_Serializer)
end

function SerializerHelper.HuanPai_Serializer(writer, selectpais)
	SerializeBase.WriteList(writer, selectpais, SerializeBase.WriteStructWrap(SerializeAuto.WriteMjPaiInfo, "selectpais"), nil, "selectpais", false, 256, nil)
end

function ClientToAvatarDelegate:HuanPai(selectpais)
	self:Notify(153167211, SerializerHelper.HuanPai_Serializer, selectpais)
end

function SerializerHelper.AskFriendAddToSpecialList_Serializer(writer, friend)
	SerializeBase.WritePrimitive(writer, friend, writer.WriteUInt64, 0)
end

function ClientToAvatarDelegate:AskFriendAddToSpecialList(friend)
	return self:Invoke(153169063, SerializerHelper.AskFriendAddToSpecialList_Serializer, friend)
end

function SerializerHelper.Guo_Serializer(writer)
	return
end

function ClientToAvatarDelegate:Guo()
	self:Notify(153187300, SerializerHelper.Guo_Serializer)
end

function SerializerHelper.NextGame_Serializer(writer, roomtype, basescore)
	SerializeBase.WritePrimitive(writer, roomtype, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, basescore, writer.WriteInt32, 0)
end

function ClientToAvatarDelegate:NextGame(roomtype, basescore)
	self:Notify(153224343, SerializerHelper.NextGame_Serializer, roomtype, basescore)
end

function SerializerHelper.UploadLogs_Serializer(writer, logs, token)
	SerializeBase.WriteList(writer, logs, SerializeBase.WriteStringWrap(false, "logs", 1048576), nil, "logs", false, 1048576, nil)
	SerializeBase.WritePrimitive(writer, token, writer.WriteInt32, 0)
end

function ClientToAvatarDelegate:UploadLogs(logs, token)
	self:Notify(153233684, SerializerHelper.UploadLogs_Serializer, logs, token)
end

function SerializerHelper.RequestPlayerStopHangup_Serializer(writer)
	return
end

function ClientToAvatarDelegate:RequestPlayerStopHangup()
	return self:Invoke(153234536, SerializerHelper.RequestPlayerStopHangup_Serializer)
end

function SerializerHelper.SyncQueryObjectRoot_Serializer(writer, id, info)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WriteGmQueryObjectRoot, "info", false)
end

function ClientToAvatarDelegate:SyncQueryObjectRoot(id, info)
	self:Notify(153243058, SerializerHelper.SyncQueryObjectRoot_Serializer, id, info)
end

function SerializerHelper.AskFriendAddToBlacklist_Serializer(writer, friendpid)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
end

function ClientToAvatarDelegate:AskFriendAddToBlacklist(friendpid)
	return self:Invoke(153244956, SerializerHelper.AskFriendAddToBlacklist_Serializer, friendpid)
end

function SerializerHelper.ReportLocation_Serializer(writer, longitude, latitude)
	SerializeBase.WritePrimitive(writer, longitude, writer.WriteDouble, 0)
	SerializeBase.WritePrimitive(writer, latitude, writer.WriteDouble, 0)
end

function ClientToAvatarDelegate:ReportLocation(longitude, latitude)
	self:Notify(153252786, SerializerHelper.ReportLocation_Serializer, longitude, latitude)
end

function SerializerHelper.AskNewHotFixPatch_Serializer(writer, version, md5, clientversion)
	SerializeBase.WritePrimitive(writer, version, writer.WriteInt32, 0)
	writer:WriteString(md5, true, "md5", 256)
	SerializeBase.WritePrimitive(writer, clientversion, writer.WriteInt32, 0)
end

function ClientToAvatarDelegate:AskNewHotFixPatch(version, md5, clientversion)
	return self:Invoke(153261934, SerializerHelper.AskNewHotFixPatch_Serializer, version, md5, clientversion)
end

function SerializerHelper.QueryFriendRecommendation_Serializer(writer)
	return
end

function ClientToAvatarDelegate:QueryFriendRecommendation()
	return self:Invoke(153268512, SerializerHelper.QueryFriendRecommendation_Serializer)
end

function SerializerHelper.AskJoinFriendModeRoom_Serializer(writer, mahjongserverid, roomid)
	SerializeBase.WritePrimitive(writer, mahjongserverid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteUInt64, 0)
end

function ClientToAvatarDelegate:AskJoinFriendModeRoom(mahjongserverid, roomid)
	return self:Invoke(153274842, SerializerHelper.AskJoinFriendModeRoom_Serializer, mahjongserverid, roomid)
end

function SerializerHelper.SyncReportFileSystemPath_Serializer(writer, rst, token)
	SerializeBase.WriteList(writer, rst, SerializeBase.WriteComplexWrap(SerializeAuto.WriteDebugFileDescription, "DebugFileDescription", false), nil, "rst", false, 10240, nil)
	SerializeBase.WritePrimitive(writer, token, writer.WriteInt32, 0)
end

function ClientToAvatarDelegate:SyncReportFileSystemPath(rst, token)
	self:Notify(153293805, SerializerHelper.SyncReportFileSystemPath_Serializer, rst, token)
end

function SerializerHelper.GetChatGroupMessages_Serializer(writer, groupid, timestamp)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, timestamp, writer.WriteUInt32, 0)
end

function ClientToAvatarDelegate:GetChatGroupMessages(groupid, timestamp)
	return self:Invoke(153294138, SerializerHelper.GetChatGroupMessages_Serializer, groupid, timestamp)
end

function SerializerHelper.GetLinkMessageList_Serializer(writer, mode)
	SerializeBase.WritePrimitive(writer, mode, writer.WriteByte, 0)
end

function ClientToAvatarDelegate:GetLinkMessageList(mode)
	return self:Invoke(153294956, SerializerHelper.GetLinkMessageList_Serializer, mode)
end

function SerializerHelper.SendMessageToLink_Serializer(writer, text, mode, isaudio)
	writer:WriteString(text, false, "text", 10240)
	SerializeBase.WritePrimitive(writer, mode, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, isaudio, writer.WriteBoolean, false)
end

function ClientToAvatarDelegate:SendMessageToLink(text, mode, isaudio)
	return self:Invoke(153297901, SerializerHelper.SendMessageToLink_Serializer, text, mode, isaudio)
end

function SerializerHelper.RequestPlayerStartHangup_Serializer(writer)
	return
end

function ClientToAvatarDelegate:RequestPlayerStartHangup()
	return self:Invoke(153313877, SerializerHelper.RequestPlayerStartHangup_Serializer)
end

function SerializerHelper.AskBanUser_Serializer(writer, banreasonid)
	SerializeBase.WritePrimitive(writer, banreasonid, writer.WriteUInt32, 0)
end

function ClientToAvatarDelegate:AskBanUser(banreasonid)
	return self:Invoke(153334455, SerializerHelper.AskBanUser_Serializer, banreasonid)
end

function SerializerHelper.GetP2PMessageList_Serializer(writer, friendpid, timestamp)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, timestamp, writer.WriteUInt32, 0)
end

function ClientToAvatarDelegate:GetP2PMessageList(friendpid, timestamp)
	return self:Invoke(153365803, SerializerHelper.GetP2PMessageList_Serializer, friendpid, timestamp)
end

function SerializerHelper.Gang_Serializer(writer, pai)
	SerializeBase.WriteStruct(writer, pai, SerializeAuto.WriteMjPaiInfo, "pai")
end

function ClientToAvatarDelegate:Gang(pai)
	return self:Invoke(153371609, SerializerHelper.Gang_Serializer, pai)
end

function SerializerHelper.SyncQueryScene_Serializer(writer, id, scene)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteComplex(writer, scene, SerializeAuto.WriteGmQuerySceneInfo, "scene", false)
end

function ClientToAvatarDelegate:SyncQueryScene(id, scene)
	self:Notify(153372316, SerializerHelper.SyncQueryScene_Serializer, id, scene)
end

function SerializerHelper.GetTeamLatestMessage_Serializer(writer)
	return
end

function ClientToAvatarDelegate:GetTeamLatestMessage()
	return self:Invoke(153378146, SerializerHelper.GetTeamLatestMessage_Serializer)
end

function SerializerHelper.RequestPatchesCheckDataFromAvatar_Serializer(writer, clientversion, patchversion)
	SerializeBase.WritePrimitive(writer, clientversion, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, patchversion, writer.WriteInt32, 0)
end

function ClientToAvatarDelegate:RequestPatchesCheckDataFromAvatar(clientversion, patchversion)
	return self:Invoke(153388718, SerializerHelper.RequestPatchesCheckDataFromAvatar_Serializer, clientversion, patchversion)
end

function SerializerHelper.GetChatGroupMessagesWithRange_Serializer(writer, groupid, starttimestamp, endtimestamp, count)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, starttimestamp, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, endtimestamp, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

function ClientToAvatarDelegate:GetChatGroupMessagesWithRange(groupid, starttimestamp, endtimestamp, count)
	return self:Invoke(153390391, SerializerHelper.GetChatGroupMessagesWithRange_Serializer, groupid, starttimestamp, endtimestamp, count)
end

function SerializerHelper.ResponseAllFriendApplication_Serializer(writer, pids, accept)
	SerializeBase.WriteList(writer, pids, writer.WriteUInt64, 0, "pids", false, 200, nil)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

function ClientToAvatarDelegate:ResponseAllFriendApplication(pids, accept)
	return self:Invoke(153401024, SerializerHelper.ResponseAllFriendApplication_Serializer, pids, accept)
end

function SerializerHelper.AskDismissChatGroup_Serializer(writer, groupid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
end

function ClientToAvatarDelegate:AskDismissChatGroup(groupid)
	return self:Invoke(153404376, SerializerHelper.AskDismissChatGroup_Serializer, groupid)
end

function SerializerHelper.SyncQueryObjectFields_Serializer(writer, id, fields)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteList(writer, fields, SerializeBase.WriteComplexWrap(SerializeAuto.WriteQueryFieldInfo, "QueryFieldInfo", false), nil, "fields", false, 10240, nil)
end

function ClientToAvatarDelegate:SyncQueryObjectFields(id, fields)
	self:Notify(153424635, SerializerHelper.SyncQueryObjectFields_Serializer, id, fields)
end

function SerializerHelper.ChuPai_Serializer(writer, pai, reach)
	SerializeBase.WriteStruct(writer, pai, SerializeAuto.WriteMjPaiInfo, "pai")
	SerializeBase.WritePrimitive(writer, reach, writer.WriteBoolean, false)
end

function ClientToAvatarDelegate:ChuPai(pai, reach)
	self:Notify(153427783, SerializerHelper.ChuPai_Serializer, pai, reach)
end

function SerializerHelper.SyncReportUploadClientFile_Serializer(writer, id, message)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	writer:WriteString(message, false, "message", 10240)
end

function ClientToAvatarDelegate:SyncReportUploadClientFile(id, message)
	self:Notify(153441261, SerializerHelper.SyncReportUploadClientFile_Serializer, id, message)
end

function SerializerHelper.AskChatGroupSetRecvMsg_Serializer(writer, groupid, reject)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, reject, writer.WriteBoolean, false)
end

function ClientToAvatarDelegate:AskChatGroupSetRecvMsg(groupid, reject)
	return self:Invoke(153472464, SerializerHelper.AskChatGroupSetRecvMsg_Serializer, groupid, reject)
end

function SerializerHelper.GetRoomMessages_Serializer(writer, timestamp)
	SerializeBase.WritePrimitive(writer, timestamp, writer.WriteUInt32, 0)
end

function ClientToAvatarDelegate:GetRoomMessages(timestamp)
	return self:Invoke(153475837, SerializerHelper.GetRoomMessages_Serializer, timestamp)
end

function SerializerHelper.SendMessageToPlayer_Serializer(writer, pid, text, isaudio)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	writer:WriteString(text, false, "text", 10240)
	SerializeBase.WritePrimitive(writer, isaudio, writer.WriteBoolean, false)
end

function ClientToAvatarDelegate:SendMessageToPlayer(pid, text, isaudio)
	return self:Invoke(153491425, SerializerHelper.SendMessageToPlayer_Serializer, pid, text, isaudio)
end

function SerializerHelper.ApplyFriend_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToAvatarDelegate:ApplyFriend(pid)
	return self:Invoke(153504625, SerializerHelper.ApplyFriend_Serializer, pid)
end

function SerializerHelper.AskCreateChatGroup_Serializer(writer, groupname)
	writer:WriteString(groupname, false, "groupname", 256)
end

function ClientToAvatarDelegate:AskCreateChatGroup(groupname)
	return self:Invoke(153506352, SerializerHelper.AskCreateChatGroup_Serializer, groupname)
end

function SerializerHelper.SendMessageToRoom_Serializer(writer, text, isaudio)
	writer:WriteString(text, false, "text", 10240)
	SerializeBase.WritePrimitive(writer, isaudio, writer.WriteBoolean, false)
end

function ClientToAvatarDelegate:SendMessageToRoom(text, isaudio)
	return self:Invoke(153518692, SerializerHelper.SendMessageToRoom_Serializer, text, isaudio)
end

function SerializerHelper.GetAllChatGroupLatestMessage_Serializer(writer)
	return
end

function ClientToAvatarDelegate:GetAllChatGroupLatestMessage()
	return self:Invoke(153521086, SerializerHelper.GetAllChatGroupLatestMessage_Serializer)
end

function SerializerHelper.ReconnectGame_Serializer(writer)
	return
end

function ClientToAvatarDelegate:ReconnectGame()
	self:Notify(153530147, SerializerHelper.ReconnectGame_Serializer)
end

function SerializerHelper.AskFriendRemoveFromSpecialList_Serializer(writer, friend)
	SerializeBase.WritePrimitive(writer, friend, writer.WriteUInt64, 0)
end

function ClientToAvatarDelegate:AskFriendRemoveFromSpecialList(friend)
	return self:Invoke(153546746, SerializerHelper.AskFriendRemoveFromSpecialList_Serializer, friend)
end

function SerializerHelper.BackToMahjong_Serializer(writer)
	return
end

function ClientToAvatarDelegate:BackToMahjong()
	return self:Invoke(153551913, SerializerHelper.BackToMahjong_Serializer)
end

function SerializerHelper.SyncAllQueryScene_Serializer(writer, id, scene)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteList(writer, scene, SerializeBase.WriteComplexWrap(SerializeAuto.WriteGmQuerySceneInfo, "GmQuerySceneInfo", false), nil, "scene", false, 32, nil)
end

function ClientToAvatarDelegate:SyncAllQueryScene(id, scene)
	self:Notify(153564882, SerializerHelper.SyncAllQueryScene_Serializer, id, scene)
end

function SerializerHelper.SyncQueryObject_Serializer(writer, id, list)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WriteList(writer, list, SerializeBase.WriteComplexWrap(SerializeAuto.WriteGmQuerySceneObjectInfo, "GmQuerySceneObjectInfo", false), nil, "list", false, 10240, nil)
end

function ClientToAvatarDelegate:SyncQueryObject(id, list)
	self:Notify(153569705, SerializerHelper.SyncQueryObject_Serializer, id, list)
end

function SerializerHelper.Peng_Serializer(writer, selectpais)
	SerializeBase.WriteList(writer, selectpais, SerializeBase.WriteStructWrap(SerializeAuto.WriteMjPaiInfo, "selectpais"), nil, "selectpais", false, 256, nil)
end

function ClientToAvatarDelegate:Peng(selectpais)
	self:Notify(153581001, SerializerHelper.Peng_Serializer, selectpais)
end

function SerializerHelper.SyncSetObjectValue_Serializer(writer, id, exception)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	writer:WriteString(exception, true, "exception", 10240)
end

function ClientToAvatarDelegate:SyncSetObjectValue(id, exception)
	self:Notify(153632189, SerializerHelper.SyncSetObjectValue_Serializer, id, exception)
end

function SerializerHelper.DeleteFriend_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToAvatarDelegate:DeleteFriend(pid)
	return self:Invoke(153632737, SerializerHelper.DeleteFriend_Serializer, pid)
end

function SerializerHelper.SendCustomHotPatchClientToAvatar_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

function ClientToAvatarDelegate:SendCustomHotPatchClientToAvatar(data)
	return self:Invoke(153646828, SerializerHelper.SendCustomHotPatchClientToAvatar_Serializer, data)
end

function SerializerHelper.SyncReportDeleteClientFile_Serializer(writer, id, message)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	writer:WriteString(message, false, "message", 10240)
end

function ClientToAvatarDelegate:SyncReportDeleteClientFile(id, message)
	self:Notify(153646920, SerializerHelper.SyncReportDeleteClientFile_Serializer, id, message)
end

function SerializerHelper.GetP2PMessageListWithRange_Serializer(writer, friendpid, starttimestamp, endtimestamp, count)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, starttimestamp, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, endtimestamp, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

function ClientToAvatarDelegate:GetP2PMessageListWithRange(friendpid, starttimestamp, endtimestamp, count)
	return self:Invoke(153669103, SerializerHelper.GetP2PMessageListWithRange_Serializer, friendpid, starttimestamp, endtimestamp, count)
end

function SerializerHelper.SendMessageToTeam_Serializer(writer, text, isaudio)
	writer:WriteString(text, false, "text", 10240)
	SerializeBase.WritePrimitive(writer, isaudio, writer.WriteBoolean, false)
end

function ClientToAvatarDelegate:SendMessageToTeam(text, isaudio)
	return self:Invoke(153720671, SerializerHelper.SendMessageToTeam_Serializer, text, isaudio)
end

function SerializerHelper.CancelTuoGuan_Serializer(writer)
	return
end

function ClientToAvatarDelegate:CancelTuoGuan()
	return self:Invoke(153721013, SerializerHelper.CancelTuoGuan_Serializer)
end

function SerializerHelper.Exit_Serializer(writer)
	return
end

function ClientToAvatarDelegate:Exit()
	self:Notify(153728048, SerializerHelper.Exit_Serializer)
end

function SerializerHelper.AskFriendRemoveFromBlacklist_Serializer(writer, friendpid)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
end

function ClientToAvatarDelegate:AskFriendRemoveFromBlacklist(friendpid)
	return self:Invoke(153733960, SerializerHelper.AskFriendRemoveFromBlacklist_Serializer, friendpid)
end

function SerializerHelper.AskChangeChatGroupName_Serializer(writer, groupid, name)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	writer:WriteString(name, false, "name", 256)
end

function ClientToAvatarDelegate:AskChangeChatGroupName(groupid, name)
	return self:Invoke(153739755, SerializerHelper.AskChangeChatGroupName_Serializer, groupid, name)
end

function SerializerHelper.GetP2PLatestMessageList_Serializer(writer, targets)
	SerializeBase.WriteList(writer, targets, writer.WriteUInt64, 0, "targets", false, 200, nil)
end

function ClientToAvatarDelegate:GetP2PLatestMessageList(targets)
	return self:Invoke(153758934, SerializerHelper.GetP2PLatestMessageList_Serializer, targets)
end

function SerializerHelper.SyncReportFileSystemDownload_Serializer(writer, file, token, error)
	SerializeBase.WriteList(writer, file, writer.WriteByte, 0, "file", true, 1048576, nil)
	SerializeBase.WritePrimitive(writer, token, writer.WriteInt32, 0)
	writer:WriteString(error, true, "error", 10240)
end

function ClientToAvatarDelegate:SyncReportFileSystemDownload(file, token, error)
	self:Notify(153766736, SerializerHelper.SyncReportFileSystemDownload_Serializer, file, token, error)
end

function SerializerHelper.GetRoomLatestMessage_Serializer(writer)
	return
end

function ClientToAvatarDelegate:GetRoomLatestMessage()
	return self:Invoke(153769269, SerializerHelper.GetRoomLatestMessage_Serializer)
end

function SerializerHelper.GetGmSdkToken_Serializer(writer, lang)
	writer:WriteString(lang, false, "lang", 10)
end

function ClientToAvatarDelegate:GetGmSdkToken(lang)
	return self:Invoke(153770579, SerializerHelper.GetGmSdkToken_Serializer, lang)
end

function SerializerHelper.SyncReportFileSystemRoot_Serializer(writer, rst, token)
	SerializeBase.WriteComplex(writer, rst, SerializeAuto.WriteDebugFileResult, "rst", false)
	SerializeBase.WritePrimitive(writer, token, writer.WriteInt32, 0)
end

function ClientToAvatarDelegate:SyncReportFileSystemRoot(rst, token)
	self:Notify(153773859, SerializerHelper.SyncReportFileSystemRoot_Serializer, rst, token)
end

function SerializerHelper.SendMessageToChatGroup_Serializer(writer, groupid, text, isaudio)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	writer:WriteString(text, false, "text", 10240)
	SerializeBase.WritePrimitive(writer, isaudio, writer.WriteBoolean, false)
end

function ClientToAvatarDelegate:SendMessageToChatGroup(groupid, text, isaudio)
	return self:Invoke(153794588, SerializerHelper.SendMessageToChatGroup_Serializer, groupid, text, isaudio)
end

function SerializerHelper.GetLinkLatestMessage_Serializer(writer, mode)
	SerializeBase.WritePrimitive(writer, mode, writer.WriteByte, 0)
end

function ClientToAvatarDelegate:GetLinkLatestMessage(mode)
	return self:Invoke(153820508, SerializerHelper.GetLinkLatestMessage_Serializer, mode)
end

function SerializerHelper.Hu_Serializer(writer)
	return
end

function ClientToAvatarDelegate:Hu()
	self:Notify(153824534, SerializerHelper.Hu_Serializer)
end

function SerializerHelper.Chi_Serializer(writer, selectpais)
	SerializeBase.WriteList(writer, selectpais, SerializeBase.WriteStructWrap(SerializeAuto.WriteMjPaiInfo, "selectpais"), nil, "selectpais", false, 256, nil)
end

function ClientToAvatarDelegate:Chi(selectpais)
	self:Notify(153831521, SerializerHelper.Chi_Serializer, selectpais)
end

function SerializerHelper.MahjongChat_Serializer(writer, chattype, msgid)
	SerializeBase.WritePrimitive(writer, chattype, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, msgid, writer.WriteInt32, 0)
end

function ClientToAvatarDelegate:MahjongChat(chattype, msgid)
	return self:Invoke(153837034, SerializerHelper.MahjongChat_Serializer, chattype, msgid)
end

function SerializerHelper.AskSetRejectAllFriendApply_Serializer(writer, reject)
	SerializeBase.WritePrimitive(writer, reject, writer.WriteBoolean, false)
end

function ClientToAvatarDelegate:AskSetRejectAllFriendApply(reject)
	return self:Invoke(153855822, SerializerHelper.AskSetRejectAllFriendApply_Serializer, reject)
end

function SerializerHelper.GetTeamMessages_Serializer(writer, timestamp)
	SerializeBase.WritePrimitive(writer, timestamp, writer.WriteUInt32, 0)
end

function ClientToAvatarDelegate:GetTeamMessages(timestamp)
	return self:Invoke(153882895, SerializerHelper.GetTeamMessages_Serializer, timestamp)
end

function SerializerHelper.RequestPatchesFromAvatar_Serializer(writer, versions, clientversion)
	SerializeBase.WriteList(writer, versions, writer.WriteInt32, 0, "versions", false, 10240, nil)
	SerializeBase.WritePrimitive(writer, clientversion, writer.WriteInt32, 0)
end

function ClientToAvatarDelegate:RequestPatchesFromAvatar(versions, clientversion)
	return self:Invoke(153892154, SerializerHelper.RequestPatchesFromAvatar_Serializer, versions, clientversion)
end

function SerializerHelper.RemoveLocation_Serializer(writer)
	return
end

function ClientToAvatarDelegate:RemoveLocation()
	self:Notify(153915896, SerializerHelper.RemoveLocation_Serializer)
end

function SerializerHelper.SendMessageToLocation_Serializer(writer, text, isaudio)
	writer:WriteString(text, false, "text", 10240)
	SerializeBase.WritePrimitive(writer, isaudio, writer.WriteBoolean, false)
end

function ClientToAvatarDelegate:SendMessageToLocation(text, isaudio)
	return self:Invoke(153917750, SerializerHelper.SendMessageToLocation_Serializer, text, isaudio)
end

function SerializerHelper.GetLinkMessages_Serializer(writer, timestamp, mode)
	SerializeBase.WritePrimitive(writer, timestamp, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, mode, writer.WriteByte, 0)
end

function ClientToAvatarDelegate:GetLinkMessages(timestamp, mode)
	return self:Invoke(153919532, SerializerHelper.GetLinkMessages_Serializer, timestamp, mode)
end

function SerializerHelper.MarkAsReadPrivateMessage_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToAvatarDelegate:MarkAsReadPrivateMessage(pid)
	return self:Invoke(153950906, SerializerHelper.MarkAsReadPrivateMessage_Serializer, pid)
end

function SerializerHelper.GetSimplePlayerInfoByPidList_Serializer(writer, pids)
	SerializeBase.WriteList(writer, pids, writer.WriteUInt64, 0, "pids", false, 200, nil)
end

function ClientToAvatarDelegate:GetSimplePlayerInfoByPidList(pids)
	return self:Invoke(153957668, SerializerHelper.GetSimplePlayerInfoByPidList_Serializer, pids)
end

function SerializerHelper.ResponseFriendApplication_Serializer(writer, pid, accept)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, accept, writer.WriteBoolean, false)
end

function ClientToAvatarDelegate:ResponseFriendApplication(pid, accept)
	return self:Invoke(153960953, SerializerHelper.ResponseFriendApplication_Serializer, pid, accept)
end

function SerializerHelper.QuerySkey_Serializer(writer, skey)
	SerializeBase.WritePrimitive(writer, skey, writer.WriteBoolean, false)
end

function ClientToAvatarDelegate:QuerySkey(skey)
	return self:Invoke(153965146, SerializerHelper.QuerySkey_Serializer, skey)
end

function SerializerHelper.HasFriendApplicationToOther_Serializer(writer, friendpid)
	SerializeBase.WritePrimitive(writer, friendpid, writer.WriteUInt64, 0)
end

function ClientToAvatarDelegate:HasFriendApplicationToOther(friendpid)
	return self:Invoke(153971076, SerializerHelper.HasFriendApplicationToOther_Serializer, friendpid)
end

function SerializerHelper.AskQuitChatGroup_Serializer(writer, groupid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
end

function ClientToAvatarDelegate:AskQuitChatGroup(groupid)
	return self:Invoke(153979783, SerializerHelper.AskQuitChatGroup_Serializer, groupid)
end

function SerializerHelper.AskInviteToJoinChatGroup_Serializer(writer, groupid, inviteepid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, inviteepid, writer.WriteUInt64, 0)
end

function ClientToAvatarDelegate:AskInviteToJoinChatGroup(groupid, inviteepid)
	return self:Invoke(153986841, SerializerHelper.AskInviteToJoinChatGroup_Serializer, groupid, inviteepid)
end

function SerializerHelper.DingQue_Serializer(writer, type)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
end

function ClientToAvatarDelegate:DingQue(type)
	return self:Invoke(153992257, SerializerHelper.DingQue_Serializer, type)
end

return ClientToAvatarDelegate
