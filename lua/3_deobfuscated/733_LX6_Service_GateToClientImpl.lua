local MessageConfig = LTConfig.MessageConfig
local GateToClientImpl = gRpcChecker:CreateRpcImpl()

function GateToClientImpl.SendCustomHotPatchGateToClient(data)
	return
end

function GateToClientImpl.SyncOnlineKick()
	gLoginManager:DoKickToLogin()
	gDisplayMessageMgr:ShowMessage(MessageConfig.Disconnect, nil, nil)
end

return GateToClientImpl
