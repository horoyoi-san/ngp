-- Original chunk: @Lua\LuaGen\AutoGen\ClientToMinorDelegate.lua
-- Decompiled from: 00074_ClientToMinorDelegate.lua_65be14aa9968.luajit

local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToMinorDelegate = invoker.New(invoker)

ClientToMinorDelegate.Sender = function()
	return NetworkManager.LuaGateRpcProcessor
end

SerializerHelper.SendCustomHotPatchClientToMinor_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

ClientToMinorDelegate.SendCustomHotPatchClientToMinor = function(self, data)
	return self.Invoke(self, 126050327, SerializerHelper.SendCustomHotPatchClientToMinor_Serializer, data)
end

return ClientToMinorDelegate
