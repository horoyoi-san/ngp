-- Original chunk: @Lua\LuaFiles\LX6\Service\AvatarToClientImpl.lua
-- Decompiled from: 02361_AvatarToClientImpl.lua_60dc90e6605a.luajit

slot0 = gRpcChecker
local AvatarToClientImpl = slot0:CreateRpcImpl()

AvatarToClientImpl.UserBanned = function(expireTime, reason, reasonId, pid)
	gLoginManager:DoKickToLogin()

	gLuaUIMgr.shouldShowBanned = true
	gLuaUIMgr.bannedReason = reason

	gLoginManager:OnBeBanned(expireTime, reason, reasonId, pid)
end

AvatarToClientImpl.SendCustomHotPatchAvatarToClient = function(data)
end

AvatarToClientImpl.SyncLoginKick = function()
	gCS.GuiUtils.ShowOnlineOtherDevice()
end

AvatarToClientImpl.SyncSkey = function(skey, domain)
end

return AvatarToClientImpl
