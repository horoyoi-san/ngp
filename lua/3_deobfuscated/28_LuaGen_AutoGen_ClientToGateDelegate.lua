local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToGateDelegate = invoker:New()

function ClientToGateDelegate.Sender()
	return NetworkManager.LuaGateRpcProcessor
end

function SerializerHelper.SendCustomCommonDataClientToGate_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

function ClientToGateDelegate:SendCustomCommonDataClientToGate(data)
	return self:Invoke(52095352, SerializerHelper.SendCustomCommonDataClientToGate_Serializer, data)
end

function SerializerHelper.AskUniSdkShareToken_Gate_Serializer(writer)
	return
end

function ClientToGateDelegate:AskUniSdkShareToken_Gate()
	return self:Invoke(52191467, SerializerHelper.AskUniSdkShareToken_Gate_Serializer)
end

function SerializerHelper.AskCloseConnectionToGate_Serializer(writer, msg)
	writer:WriteString(msg, false, "msg", 256)
end

function ClientToGateDelegate:AskCloseConnectionToGate(msg)
	return self:Invoke(52226781, SerializerHelper.AskCloseConnectionToGate_Serializer, msg)
end

function SerializerHelper.GetServerTime_Serializer(writer, clientunixtime)
	SerializeBase.WritePrimitive(writer, clientunixtime, writer.WriteDouble, 0)
end

function ClientToGateDelegate:GetServerTime(clientunixtime)
	self:Notify(52794815, SerializerHelper.GetServerTime_Serializer, clientunixtime)
end

function SerializerHelper.Login_Serializer(writer, pid, token, isreconnect, deviceinfo, debug)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	writer:WriteString(token, false, "token", 256)
	SerializeBase.WritePrimitive(writer, isreconnect, writer.WriteBoolean, false)
	SerializeBase.WriteComplex(writer, deviceinfo, SerializeAuto.WriteClientDeviceInfo, "deviceinfo", false)
	SerializeBase.WriteComplex(writer, debug, SerializeAuto.WritePlayerLoginOption, "debug", false)
end

function ClientToGateDelegate:Login(pid, token, isreconnect, deviceinfo, debug)
	return self:Invoke(52848583, SerializerHelper.Login_Serializer, pid, token, isreconnect, deviceinfo, debug)
end

function SerializerHelper.SendCustomHotPatchClientToGate_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

function ClientToGateDelegate:SendCustomHotPatchClientToGate(data)
	return self:Invoke(52917173, SerializerHelper.SendCustomHotPatchClientToGate_Serializer, data)
end

return ClientToGateDelegate
