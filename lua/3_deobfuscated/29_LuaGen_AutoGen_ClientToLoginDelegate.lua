local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToLoginDelegate = invoker:New()

function ClientToLoginDelegate.Sender()
	return NetworkManager.LuaLoginRpcProcessor
end

function SerializerHelper.AskDeleteRole_Serializer(writer)
	return
end

function ClientToLoginDelegate:AskDeleteRole()
	return self:Invoke(34089392, SerializerHelper.AskDeleteRole_Serializer)
end

function SerializerHelper.RequestCreateRoleEx_Serializer(writer, roleinfo, deviceinfo)
	SerializeBase.WriteComplex(writer, roleinfo, SerializeAuto.WriteCreateRoleInitInfo, "roleinfo", false)
	SerializeBase.WriteComplex(writer, deviceinfo, SerializeAuto.WriteClientDeviceInfo, "deviceinfo", false)
end

function ClientToLoginDelegate:RequestCreateRoleEx(roleinfo, deviceinfo)
	return self:Invoke(34270770, SerializerHelper.RequestCreateRoleEx_Serializer, roleinfo, deviceinfo)
end

function SerializerHelper.CheckVersion_Serializer(writer, codemd5, clientversion)
	writer:WriteString(codemd5, false, "codemd5", 256)
	SerializeBase.WritePrimitive(writer, clientversion, writer.WriteInt32, 0)
end

function ClientToLoginDelegate:CheckVersion(codemd5, clientversion)
	return self:Invoke(34316894, SerializerHelper.CheckVersion_Serializer, codemd5, clientversion)
end

function SerializerHelper.AskNewHotFixPatchLogin_Serializer(writer, version, md5, clientversion)
	SerializeBase.WritePrimitive(writer, version, writer.WriteInt32, 0)
	writer:WriteString(md5, true, "md5", 256)
	SerializeBase.WritePrimitive(writer, clientversion, writer.WriteInt32, 0)
end

function ClientToLoginDelegate:AskNewHotFixPatchLogin(version, md5, clientversion)
	return self:Invoke(34326564, SerializerHelper.AskNewHotFixPatchLogin_Serializer, version, md5, clientversion)
end

function SerializerHelper.RequestPatchesCheckDataFromLogin_Serializer(writer, clientversion, patchversion)
	SerializeBase.WritePrimitive(writer, clientversion, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, patchversion, writer.WriteInt32, 0)
end

function ClientToLoginDelegate:RequestPatchesCheckDataFromLogin(clientversion, patchversion)
	return self:Invoke(34328811, SerializerHelper.RequestPatchesCheckDataFromLogin_Serializer, clientversion, patchversion)
end

function SerializerHelper.SendCustomCommonDataClientToLogin_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

function ClientToLoginDelegate:SendCustomCommonDataClientToLogin(data)
	return self:Invoke(34333379, SerializerHelper.SendCustomCommonDataClientToLogin_Serializer, data)
end

function SerializerHelper.AskUniSdkShareToken_Login_Serializer(writer)
	return
end

function ClientToLoginDelegate:AskUniSdkShareToken_Login()
	return self:Invoke(34405957, SerializerHelper.AskUniSdkShareToken_Login_Serializer)
end

function SerializerHelper.CheckAccount_Serializer(writer, sauthjason)
	writer:WriteString(sauthjason, false, "sauthjason", 10240)
end

function ClientToLoginDelegate:CheckAccount(sauthjason)
	return self:Invoke(34491280, SerializerHelper.CheckAccount_Serializer, sauthjason)
end

function SerializerHelper.TryLogin_Serializer(writer, aid, token, updateaasinfo, kick, deviceid, strictonlinemode, confirmbinddevice)
	SerializeBase.WritePrimitive(writer, aid, writer.WriteInt32, 0)
	writer:WriteString(token, false, "token", 256)
	SerializeBase.WritePrimitive(writer, updateaasinfo, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, kick, writer.WriteBoolean, false)
	writer:WriteString(deviceid, false, "deviceid", 32)
	SerializeBase.WritePrimitive(writer, strictonlinemode, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, confirmbinddevice, writer.WriteBoolean, false)
end

function ClientToLoginDelegate:TryLogin(aid, token, updateaasinfo, kick, deviceid, strictonlinemode, confirmbinddevice)
	return self:Invoke(34504681, SerializerHelper.TryLogin_Serializer, aid, token, updateaasinfo, kick, deviceid, strictonlinemode, confirmbinddevice)
end

function SerializerHelper.CheckAccountPassBy_Serializer(writer, username)
	writer:WriteString(username, false, "username", 256)
end

function ClientToLoginDelegate:CheckAccountPassBy(username)
	return self:Invoke(34515409, SerializerHelper.CheckAccountPassBy_Serializer, username)
end

function SerializerHelper.UpdateLoginNgPushRegid_Serializer(writer, regid)
	writer:WriteString(regid, false, "regid", 32)
end

function ClientToLoginDelegate:UpdateLoginNgPushRegid(regid)
	self:Notify(34566697, SerializerHelper.UpdateLoginNgPushRegid_Serializer, regid)
end

function SerializerHelper.RequestPatchesFromLogin_Serializer(writer, versions, clientversion)
	SerializeBase.WriteList(writer, versions, writer.WriteInt32, 0, "versions", false, 10240, nil)
	SerializeBase.WritePrimitive(writer, clientversion, writer.WriteInt32, 0)
end

function ClientToLoginDelegate:RequestPatchesFromLogin(versions, clientversion)
	return self:Invoke(34570630, SerializerHelper.RequestPatchesFromLogin_Serializer, versions, clientversion)
end

function SerializerHelper.RequestFpPassToken_Serializer(writer, time)
	SerializeBase.WritePrimitive(writer, time, writer.WriteUInt32, 0)
end

function ClientToLoginDelegate:RequestFpPassToken(time)
	return self:Invoke(34634993, SerializerHelper.RequestFpPassToken_Serializer, time)
end

function SerializerHelper.SendCustomHotPatchClientToLogin_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

function ClientToLoginDelegate:SendCustomHotPatchClientToLogin(data)
	return self:Invoke(34793928, SerializerHelper.SendCustomHotPatchClientToLogin_Serializer, data)
end

function SerializerHelper.RequestEnterGame_Serializer(writer)
	return
end

function ClientToLoginDelegate:RequestEnterGame()
	return self:Invoke(34808618, SerializerHelper.RequestEnterGame_Serializer)
end

function SerializerHelper.DebugRequestEnterGame_Serializer(writer, pid, token)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	writer:WriteString(token, false, "token", 256)
end

function ClientToLoginDelegate:DebugRequestEnterGame(pid, token)
	return self:Invoke(34892583, SerializerHelper.DebugRequestEnterGame_Serializer, pid, token)
end

function SerializerHelper.CheckAccountOpenId_Serializer(writer, token)
	writer:WriteString(token, false, "token", 256)
end

function ClientToLoginDelegate:CheckAccountOpenId(token)
	return self:Invoke(34896088, SerializerHelper.CheckAccountOpenId_Serializer, token)
end

function SerializerHelper.HasOnlinePlayer_Serializer(writer, aid, token, strictonlinemode)
	SerializeBase.WritePrimitive(writer, aid, writer.WriteInt32, 0)
	writer:WriteString(token, false, "token", 256)
	SerializeBase.WritePrimitive(writer, strictonlinemode, writer.WriteBoolean, false)
end

function ClientToLoginDelegate:HasOnlinePlayer(aid, token, strictonlinemode)
	return self:Invoke(34910838, SerializerHelper.HasOnlinePlayer_Serializer, aid, token, strictonlinemode)
end

return ClientToLoginDelegate
