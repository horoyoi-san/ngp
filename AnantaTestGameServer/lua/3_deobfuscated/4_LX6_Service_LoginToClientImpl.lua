local MessageConfig = LTConfig.MessageConfig
local LoginToClientImpl = gRpcChecker:CreateRpcImpl()

function LoginToClientImpl.SyncBannedReason(expireTime, reasonStr, reasonId, pid)
	if gCS.NetworkManager.IsReconnect then
		gLuaUIMgr.shouldShowBanned = true
		gLuaUIMgr.bannedReason = reasonStr
	end

	gLoginManager:OnBeBanned(expireTime, reasonStr, reasonId, pid)
end

function LoginToClientImpl.SyncGameModeInfo(linkUnlocked, hasPrivateLink)
	gLinkManager:ChangeAccountLinkState(linkUnlocked, hasPrivateLink)
end

function LoginToClientImpl.SyncLoginKick()
	gLoginManager:DoKickToLogin()
	gDisplayMessageMgr:ShowMessage(MessageConfig.OnlineOtherDevice, nil, nil)
end

function LoginToClientImpl.SyncRoleList(roleId)
	gCS.LoginManager.HasGetRoleListInfo = true

	gMessageManager:SendMessage(gEventConstants.SYNC_ROLE_LIST, roleId)
end

function LoginToClientImpl.SyncLoginServerQueue(queueCount, waitTime, queueIndex)
	return
end

function LoginToClientImpl.SendCustomHotPatchLoginToClient(data)
	return
end

return LoginToClientImpl
