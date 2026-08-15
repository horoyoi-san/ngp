local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToAvatarGMDelegate = invoker:New()

function ClientToAvatarGMDelegate.Sender()
	return NetworkManager.LuaGateRpcProcessor
end

function SerializerHelper.CaptureClient_Serializer(writer)
	return
end

function ClientToAvatarGMDelegate:CaptureClient()
	return self:Invoke(155146916, SerializerHelper.CaptureClient_Serializer)
end

function SerializerHelper.GmSetMoPai_Serializer(writer, pid, type, pai)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, type, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, pai, writer.WriteInt32, 0)
end

function ClientToAvatarGMDelegate:GmSetMoPai(pid, type, pai)
	return self:Invoke(155154548, SerializerHelper.GmSetMoPai_Serializer, pid, type, pai)
end

function SerializerHelper.HotPatchTestGm_Serializer(writer, para)
	SerializeBase.WritePrimitive(writer, para, writer.WriteInt32, 0)
end

function ClientToAvatarGMDelegate:HotPatchTestGm(para)
	return self:Invoke(155175329, SerializerHelper.HotPatchTestGm_Serializer, para)
end

function SerializerHelper.GmQueryPlayerMahjongRoomId_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToAvatarGMDelegate:GmQueryPlayerMahjongRoomId(pid)
	return self:Invoke(155178648, SerializerHelper.GmQueryPlayerMahjongRoomId_Serializer, pid)
end

function SerializerHelper.QueryClientCommands_Serializer(writer)
	return
end

function ClientToAvatarGMDelegate:QueryClientCommands()
	return self:Invoke(155502407, SerializerHelper.QueryClientCommands_Serializer)
end

function SerializerHelper.UploadCapture_Serializer(writer, data, token)
	SerializeBase.WriteBuffer(writer, data, "data", false, 0, nil)
	SerializeBase.WritePrimitive(writer, token, writer.WriteInt32, 0)
end

function ClientToAvatarGMDelegate:UploadCapture(data, token)
	return self:Invoke(155747440, SerializerHelper.UploadCapture_Serializer, data, token)
end

function SerializerHelper.GmTestBanUser_Serializer(writer, reason)
	SerializeBase.WritePrimitive(writer, reason, writer.WriteUInt32, 0)
end

function ClientToAvatarGMDelegate:GmTestBanUser(reason)
	return self:Invoke(155749147, SerializerHelper.GmTestBanUser_Serializer, reason)
end

function SerializerHelper.GmQueryMahjongRoomInfo_Serializer(writer, roomid)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteUInt64, 0)
end

function ClientToAvatarGMDelegate:GmQueryMahjongRoomInfo(roomid)
	return self:Invoke(155768142, SerializerHelper.GmQueryMahjongRoomInfo_Serializer, roomid)
end

function SerializerHelper.UploadClientCommands_Serializer(writer, commands, token)
	SerializeBase.WriteList(writer, commands, SerializeBase.WriteComplexWrap(SerializeAuto.WriteClientCommandData, "ClientCommandData", false), nil, "commands", false, 0, nil)
	SerializeBase.WritePrimitive(writer, token, writer.WriteInt32, 0)
end

function ClientToAvatarGMDelegate:UploadClientCommands(commands, token)
	return self:Invoke(155798062, SerializerHelper.UploadClientCommands_Serializer, commands, token)
end

function SerializerHelper.GmEndMahjongGame_Serializer(writer, roomid)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteUInt64, 0)
end

function ClientToAvatarGMDelegate:GmEndMahjongGame(roomid)
	return self:Invoke(155811103, SerializerHelper.GmEndMahjongGame_Serializer, roomid)
end

function SerializerHelper.KillYouKillMeKillUnityAndCrash_Serializer(writer)
	return
end

function ClientToAvatarGMDelegate:KillYouKillMeKillUnityAndCrash()
	return self:Invoke(155877507, SerializerHelper.KillYouKillMeKillUnityAndCrash_Serializer)
end

function SerializerHelper.GmKickMe_Serializer(writer)
	return
end

function ClientToAvatarGMDelegate:GmKickMe()
	return self:Invoke(155957368, SerializerHelper.GmKickMe_Serializer)
end

return ClientToAvatarGMDelegate
