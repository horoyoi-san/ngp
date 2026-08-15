local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToMinorDelegate = invoker:New()

function ClientToMinorDelegate.Sender()
	return NetworkManager.LuaGateRpcProcessor
end

function SerializerHelper.SendCustomHotPatchClientToMinor_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

function ClientToMinorDelegate:SendCustomHotPatchClientToMinor(data)
	return self:Invoke(126708607, SerializerHelper.SendCustomHotPatchClientToMinor_Serializer, data)
end

return ClientToMinorDelegate
