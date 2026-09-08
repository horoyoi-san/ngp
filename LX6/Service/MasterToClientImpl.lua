-- Original chunk: @Lua\LuaFiles\LX6\Service\MasterToClientImpl.lua
-- Decompiled from: 02349_MasterToClientImpl.lua_68c24f6c7f4a.luajit

slot0 = gRpcChecker
local MasterToClientImpl = slot0:CreateRpcImpl()

MasterToClientImpl.SyncNotice = function(content)
	gDisplayMessageMgr:ShowMessageContent(content, gDisplayMessageId.QUEUE)
end

MasterToClientImpl.SyncRollIntervalMessage = function(message)
	gLuaDataManager:ShowLoopMessage(message)
end

MasterToClientImpl.SyncRollIntervalMessageStop = function(messageId)
	gLuaDataManager:CloseLoopMessage(messageId)
end

MasterToClientImpl.SendCustomHotPatchMasterToClient = function(data)
end

return MasterToClientImpl
