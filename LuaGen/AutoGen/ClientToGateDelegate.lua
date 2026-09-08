-- Original chunk: @Lua\LuaGen\AutoGen\ClientToGateDelegate.lua
-- Decompiled from: 00072_ClientToGateDelegate.lua_1bd13bf6d9a5.luajit

local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToGateDelegate = invoker.New(invoker)

ClientToGateDelegate.Sender = function()
	return NetworkManager.LuaGateRpcProcessor
end

SerializerHelper.Login_Serializer = function(writer, pid, token, isreconnect, deviceinfo, debug)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	writer.WriteString(writer, token, false, "Login.token", RpcLengthLimits.IClientToGate_Login_token)
	SerializeBase.WritePrimitive(writer, isreconnect, writer.WriteBoolean, false)
	SerializeBase.WriteComplex(writer, deviceinfo, SerializeAuto.WriteClientDeviceInfo, "deviceinfo", false)
	SerializeBase.WriteComplex(writer, debug, SerializeAuto.WritePlayerLoginOption, "debug", false)
end

ClientToGateDelegate.Login = function(self, pid, token, isreconnect, deviceinfo, debug)
	return self.Invoke(self, 52023760, SerializerHelper.Login_Serializer, pid, token, isreconnect, deviceinfo, debug)
end

SerializerHelper.AskCloseConnectionToGate_Serializer = function(writer, msg)
	writer.WriteString(writer, msg, false, "AskCloseConnectionToGate.msg", RpcLengthLimits.IClientToGate_AskCloseConnectionToGate_msg)
end

ClientToGateDelegate.AskCloseConnectionToGate = function(self, msg)
	return self.Invoke(self, 52140059, SerializerHelper.AskCloseConnectionToGate_Serializer, msg)
end

SerializerHelper.ReportNetworkQuality_Serializer = function(writer, rtt, rttmax, jitter)
	SerializeBase.WritePrimitive(writer, rtt, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, rttmax, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, jitter, writer.WriteSingle, 0)
end

ClientToGateDelegate.ReportNetworkQuality = function(self, rtt, rttmax, jitter)
	self.Notify(self, 52443839, SerializerHelper.ReportNetworkQuality_Serializer, rtt, rttmax, jitter)
end

SerializerHelper.SendCustomHotPatchClientToGate_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

ClientToGateDelegate.SendCustomHotPatchClientToGate = function(self, data)
	return self.Invoke(self, 52729638, SerializerHelper.SendCustomHotPatchClientToGate_Serializer, data)
end

SerializerHelper.SendCustomCommonDataClientToGate_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

ClientToGateDelegate.SendCustomCommonDataClientToGate = function(self, data)
	return self.Invoke(self, 52874867, SerializerHelper.SendCustomCommonDataClientToGate_Serializer, data)
end

SerializerHelper.GetServerTime_Serializer = function(writer, clientunixtime)
	SerializeBase.WritePrimitive(writer, clientunixtime, writer.WriteDouble, 0)
end

ClientToGateDelegate.GetServerTime = function(self, clientunixtime)
	self.Notify(self, 52951195, SerializerHelper.GetServerTime_Serializer, clientunixtime)
end

return ClientToGateDelegate
