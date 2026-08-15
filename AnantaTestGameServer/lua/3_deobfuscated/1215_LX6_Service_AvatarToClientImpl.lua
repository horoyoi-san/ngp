local AvatarToClientImpl = gRpcChecker:CreateRpcImpl()

function AvatarToClientImpl.UserBanned(expireTime, reason, reasonId, pid)
	gLoginManager:DoKickToLogin()

	gLuaUIMgr.shouldShowBanned = true
	gLuaUIMgr.bannedReason = reason

	gLoginManager:OnBeBanned(expireTime, reason, reasonId, pid)
end

function AvatarToClientImpl.SendCustomHotPatchAvatarToClient(data)
	return
end

function AvatarToClientImpl.SyncLoginKick()
	gCS.GuiUtils.ShowOnlineOtherDevice()
end

return AvatarToClientImpl
