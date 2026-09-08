-- Original chunk: @Lua\LuaFiles\LX6\Service\GateToClientImpl.lua
-- Decompiled from: 02351_GateToClientImpl.lua_99b3d579f2e2.luajit

local MessageConfig = LTConfig.MessageConfig
slot1 = gRpcChecker
local GateToClientImpl = slot1:CreateRpcImpl()

GateToClientImpl.SendCustomHotPatchGateToClient = function(data)
end

GateToClientImpl.SyncOnlineKick = function()
	gLoginManager:DoKickToLogin()
	gDisplayMessageMgr:ShowMessage(MessageConfig.Disconnect, nil, )
end

return GateToClientImpl
