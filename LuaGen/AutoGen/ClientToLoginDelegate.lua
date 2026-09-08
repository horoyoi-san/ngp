-- Original chunk: @Lua\LuaGen\AutoGen\ClientToLoginDelegate.lua
-- Decompiled from: 00073_ClientToLoginDelegate.lua_700d16c488b9.luajit

local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToLoginDelegate = invoker.New(invoker)

ClientToLoginDelegate.Sender = function()
	return NetworkManager.LuaLoginRpcProcessor
end

SerializerHelper.RequestPatchesFromLogin_Serializer = function(writer, versions, clientversion)
	SerializeBase.WriteList7Bit(writer, versions, writer.WriteInt32, 0, "versions", false, RpcLengthLimits.IClientToLogin_RequestPatchesFromLogin_versions, nil)
	SerializeBase.WritePrimitive(writer, clientversion, writer.WriteInt32, 0)
end

ClientToLoginDelegate.RequestPatchesFromLogin = function(self, versions, clientversion)
	return self.Invoke(self, 34022227, SerializerHelper.RequestPatchesFromLogin_Serializer, versions, clientversion)
end

SerializerHelper.CheckAccountPassBy_Serializer = function(writer, username)
	writer.WriteString(writer, username, false, "CheckAccountPassBy.userName", RpcLengthLimits.IClientToLogin_CheckAccountPassBy_userName)
end

ClientToLoginDelegate.CheckAccountPassBy = function(self, username)
	return self.Invoke(self, 34163006, SerializerHelper.CheckAccountPassBy_Serializer, username)
end

SerializerHelper.CheckAccount_Serializer = function(writer, sauthjason)
	writer.WriteString(writer, sauthjason, false, "CheckAccount.sauthJason", RpcLengthLimits.IClientToLogin_CheckAccount_sauthJason)
end

ClientToLoginDelegate.CheckAccount = function(self, sauthjason)
	return self.Invoke(self, 34339919, SerializerHelper.CheckAccount_Serializer, sauthjason)
end

SerializerHelper.RequestCreateRoleEx_Serializer = function(writer, roleinfo, deviceinfo)
	SerializeBase.WriteComplex(writer, roleinfo, SerializeAuto.WriteCreateRoleInitInfo, "roleinfo", false)
	SerializeBase.WriteComplex(writer, deviceinfo, SerializeAuto.WriteClientDeviceInfo, "deviceinfo", false)
end

ClientToLoginDelegate.RequestCreateRoleEx = function(self, roleinfo, deviceinfo)
	return self.Invoke(self, 34383517, SerializerHelper.RequestCreateRoleEx_Serializer, roleinfo, deviceinfo)
end

SerializerHelper.AskDeleteRole_Serializer = function(writer)
end

ClientToLoginDelegate.AskDeleteRole = function(self)
	return self.Invoke(self, 34427871, SerializerHelper.AskDeleteRole_Serializer)
end

SerializerHelper.DebugRequestEnterGame_Serializer = function(writer, pid, token)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	writer.WriteString(writer, token, false, "DebugRequestEnterGame.token", RpcLengthLimits.IClientToLogin_DebugRequestEnterGame_token)
end

ClientToLoginDelegate.DebugRequestEnterGame = function(self, pid, token)
	return self.Invoke(self, 34478273, SerializerHelper.DebugRequestEnterGame_Serializer, pid, token)
end

SerializerHelper.SendCustomCommonDataClientToLogin_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

ClientToLoginDelegate.SendCustomCommonDataClientToLogin = function(self, data)
	return self.Invoke(self, 34482880, SerializerHelper.SendCustomCommonDataClientToLogin_Serializer, data)
end

SerializerHelper.TryLogin_Serializer = function(writer, aid, token, updateaasinfo, kick, deviceid, strictonlinemode, confirmbinddevice)
	SerializeBase.WritePrimitive(writer, aid, writer.WriteInt32, 0)
	writer.WriteString(writer, token, false, "TryLogin.token", RpcLengthLimits.IClientToLogin_TryLogin_token)
	SerializeBase.WritePrimitive(writer, updateaasinfo, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, kick, writer.WriteBoolean, false)
	writer.WriteString(writer, deviceid, false, "TryLogin.deviceId", RpcLengthLimits.IClientToLogin_TryLogin_deviceId)
	SerializeBase.WritePrimitive(writer, strictonlinemode, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, confirmbinddevice, writer.WriteBoolean, false)
end

ClientToLoginDelegate.TryLogin = function(self, aid, token, updateaasinfo, kick, deviceid, strictonlinemode, confirmbinddevice)
	return self.Invoke(self, 34529582, SerializerHelper.TryLogin_Serializer, aid, token, updateaasinfo, kick, deviceid, strictonlinemode, confirmbinddevice)
end

SerializerHelper.RequestEnterGame_Serializer = function(writer)
end

ClientToLoginDelegate.RequestEnterGame = function(self)
	return self.Invoke(self, 34566515, SerializerHelper.RequestEnterGame_Serializer)
end

SerializerHelper.RequestPatchesCheckDataFromLogin_Serializer = function(writer, clientversion, patchversion)
	SerializeBase.WritePrimitive(writer, clientversion, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, patchversion, writer.WriteInt32, 0)
end

ClientToLoginDelegate.RequestPatchesCheckDataFromLogin = function(self, clientversion, patchversion)
	return self.Invoke(self, 34601301, SerializerHelper.RequestPatchesCheckDataFromLogin_Serializer, clientversion, patchversion)
end

SerializerHelper.UpdateLoginNgPushRegid_Serializer = function(writer, regid)
	writer.WriteString(writer, regid, false, "UpdateLoginNgPushRegid.regid", RpcLengthLimits.IClientToLogin_UpdateLoginNgPushRegid_regid)
end

ClientToLoginDelegate.UpdateLoginNgPushRegid = function(self, regid)
	self.Notify(self, 34637586, SerializerHelper.UpdateLoginNgPushRegid_Serializer, regid)
end

SerializerHelper.AskNewHotFixPatchLogin_Serializer = function(writer, version, md5, clientversion)
	SerializeBase.WritePrimitive(writer, version, writer.WriteInt32, 0)
	writer.WriteString(writer, md5, true, "AskNewHotFixPatchLogin.md5", RpcLengthLimits.IClientToLogin_AskNewHotFixPatchLogin_md5)
	SerializeBase.WritePrimitive(writer, clientversion, writer.WriteInt32, 0)
end

ClientToLoginDelegate.AskNewHotFixPatchLogin = function(self, version, md5, clientversion)
	return self.Invoke(self, 34692559, SerializerHelper.AskNewHotFixPatchLogin_Serializer, version, md5, clientversion)
end

SerializerHelper.CheckVersion_Serializer = function(writer, codemd5, clientversion)
	writer.WriteString(writer, codemd5, false, "CheckVersion.codeMd5", RpcLengthLimits.IClientToLogin_CheckVersion_codeMd5)
	SerializeBase.WritePrimitive(writer, clientversion, writer.WriteInt32, 0)
end

ClientToLoginDelegate.CheckVersion = function(self, codemd5, clientversion)
	return self.Invoke(self, 34700853, SerializerHelper.CheckVersion_Serializer, codemd5, clientversion)
end

SerializerHelper.HasOnlinePlayer_Serializer = function(writer, aid, token, strictonlinemode)
	SerializeBase.WritePrimitive(writer, aid, writer.WriteInt32, 0)
	writer.WriteString(writer, token, false, "HasOnlinePlayer.token", RpcLengthLimits.IClientToLogin_HasOnlinePlayer_token)
	SerializeBase.WritePrimitive(writer, strictonlinemode, writer.WriteBoolean, false)
end

ClientToLoginDelegate.HasOnlinePlayer = function(self, aid, token, strictonlinemode)
	return self.Invoke(self, 34822236, SerializerHelper.HasOnlinePlayer_Serializer, aid, token, strictonlinemode)
end

SerializerHelper.RequestFpPassToken_Serializer = function(writer, time)
	SerializeBase.WritePrimitive(writer, time, writer.WriteUInt32, 0)
end

ClientToLoginDelegate.RequestFpPassToken = function(self, time)
	return self.Invoke(self, 34828770, SerializerHelper.RequestFpPassToken_Serializer, time)
end

SerializerHelper.SendCustomHotPatchClientToLogin_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

ClientToLoginDelegate.SendCustomHotPatchClientToLogin = function(self, data)
	return self.Invoke(self, 34884306, SerializerHelper.SendCustomHotPatchClientToLogin_Serializer, data)
end

return ClientToLoginDelegate
