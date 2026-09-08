-- Original chunk: @Lua\LuaFiles\LX6\Service\LoginToClientImpl.lua
-- Decompiled from: 02348_LoginToClientImpl.lua_f9bb75c3a995.luajit

local MessageConfig = LTConfig.MessageConfig
slot1 = gRpcChecker
local LoginToClientImpl = slot1:CreateRpcImpl()

LoginToClientImpl.SyncBannedReason = function(expireTime, reasonStr, reasonId, pid)
	if gCS.NetworkManager.IsReconnect then
		gLuaUIMgr.shouldShowBanned = true
		gLuaUIMgr.bannedReason = reasonStr
	end

	gLoginManager:OnBeBanned(expireTime, reasonStr, reasonId, pid)
end

LoginToClientImpl.SyncGameModeInfo = function(linkUnlocked, hasPrivateLink)
	gLinkManager:ChangeAccountLinkState(linkUnlocked, hasPrivateLink)
end

LoginToClientImpl.SyncLoginKick = function()
	gLoginManager:DoKickToLogin()
	gDisplayMessageMgr:ShowMessage(MessageConfig.OnlineOtherDevice, nil, )
end

LoginToClientImpl.SyncRoleList = function(roleId)
	gCS.LoginManager.HasGetRoleListInfo = true

	gMessageManager:SendMessage(gEventConstants.SYNC_ROLE_LIST, roleId)
end

LoginToClientImpl.SyncLoginServerQueue = function(queueCount, waitTime, queueIndex)
end

LoginToClientImpl.SendCustomHotPatchLoginToClient = function(data)
end

return LoginToClientImpl
