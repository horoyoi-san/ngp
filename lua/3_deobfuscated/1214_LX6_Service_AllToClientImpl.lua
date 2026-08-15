local AllToClientImpl = gRpcChecker:CreateRpcImpl()
local LogUtils = LX6.Utils.LogUtilsLua

function AllToClientImpl.SyncServerWarn(message)
	if gGameManager.Env.isEditor and LogUtils.LogSwitchOn then
		print_warn("服务端错误提示：" .. message)
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900056).Text .. message)
	end
end

function AllToClientImpl.SyncServerDebug(message)
	if gGameManager.Env.isEditor and LogUtils.LogSwitchOn then
		print_debug("服务端消息：" .. message)
		gDisplayMessageMgr:ShowMessageContent(message)
	end
end

function AllToClientImpl.SyncServerLog(log)
	if gGameManager.Env.isEditor and LogUtils.LogSwitchOn then
		print_debug(log)
	end
end

function AllToClientImpl.SyncNewMail(mailHead)
	gNewMailsMgr:AddMailMailByServer(mailHead)
end

function AllToClientImpl.SyncDeleteMail(mailId)
	gNewMailsMgr:DeleteMailByServer(mailId)
end

function AllToClientImpl.PushMuteEndTime(endTime)
	gChatManager.endMuteTime = endTime
	gChatManager.muteType = 0
end

function AllToClientImpl.PushSoftMuteEndTime(endTime)
	return
end

function AllToClientImpl.SendCustomHotPatchAllToClient(data)
	return
end

function AllToClientImpl.SyncSyncRateLevelUp(friendPid, oldLevel, newLevel)
	return
end

function AllToClientImpl.PushJoinNewChatGroup(chatGroup)
	gChatGroupManager:PushJoinNewChatGroup(chatGroup)
end

function AllToClientImpl.PushPlayerImSimpleData(simpleData)
	gChatGroupManager:PushPlayerImSimpleData(simpleData)
end

function AllToClientImpl.PushChatGroupMemberRemove(groupId, memberPid)
	gChatGroupManager:PushChatGroupMemberRemove(groupId, memberPid)
end

function AllToClientImpl.PushChatGroupMemberJoin(friendId, groupId)
	gChatGroupManager:PushChatGroupMemberJoin(friendId, groupId)
end

function AllToClientImpl.PushChatGroupInvite(inviter, groupId, groupName)
	gChatGroupManager:PushChatGroupInvite(inviter, groupId, groupName)
end

function AllToClientImpl.PushChatGroupDismiss(groupId)
	gChatGroupManager:PushChatGroupDismiss(groupId)
end

return AllToClientImpl
