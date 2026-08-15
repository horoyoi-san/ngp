local MasterToClientImpl = gRpcChecker:CreateRpcImpl()

function MasterToClientImpl.SyncNotice(content)
	gDisplayMessageMgr:ShowMessageContent(content, gDisplayMessageId.QUEUE)
end

function MasterToClientImpl.SyncRollIntervalMessage(message)
	gLuaDataManager:ShowLoopMessage(message)
end

function MasterToClientImpl.SyncRollIntervalMessageStop(messageId)
	gLuaDataManager:CloseLoopMessage(messageId)
end

function MasterToClientImpl.SendCustomHotPatchMasterToClient(data)
	return
end

return MasterToClientImpl
