-- Original chunk: @Lua\LuaGen\AutoGen\ClientToCenterGMDelegate.lua
-- Decompiled from: 00068_ClientToCenterGMDelegate.lua_a24b4fdce569.luajit

local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToCenterGMDelegate = invoker.New(invoker)

ClientToCenterGMDelegate.Sender = function()
	return NetworkManager.LuaGateRpcProcessor
end

SerializerHelper.SetUIInvisible_Serializer = function(writer)
end

ClientToCenterGMDelegate.SetUIInvisible = function(self)
	return self.Invoke(self, 13015436, SerializerHelper.SetUIInvisible_Serializer)
end

SerializerHelper.GmUpdateAccountActivation_Serializer = function(writer, aid, account)
	SerializeBase.WritePrimitive(writer, aid, writer.WriteInt32, 0)
	writer.WriteString(writer, account, false, "GmUpdateAccountActivation.account", 0)
end

ClientToCenterGMDelegate.GmUpdateAccountActivation = function(self, aid, account)
	return self.Invoke(self, 13029680, SerializerHelper.GmUpdateAccountActivation_Serializer, aid, account)
end

SerializerHelper.AskToggleGameSwitchDebugDangerZone_Serializer = function(writer)
end

ClientToCenterGMDelegate.AskToggleGameSwitchDebugDangerZone = function(self)
	return self.Invoke(self, 13072862, SerializerHelper.AskToggleGameSwitchDebugDangerZone_Serializer)
end

SerializerHelper.AskToggleGameSwitchDebugHiddenArea_Serializer = function(writer)
end

ClientToCenterGMDelegate.AskToggleGameSwitchDebugHiddenArea = function(self)
	return self.Invoke(self, 13146897, SerializerHelper.AskToggleGameSwitchDebugHiddenArea_Serializer)
end

SerializerHelper.GetSVNVersion_Serializer = function(writer)
end

ClientToCenterGMDelegate.GetSVNVersion = function(self)
	return self.Invoke(self, 13224129, SerializerHelper.GetSVNVersion_Serializer)
end

SerializerHelper.AskToggleDebugIntersection_Serializer = function(writer)
end

ClientToCenterGMDelegate.AskToggleDebugIntersection = function(self)
	return self.Invoke(self, 13234760, SerializerHelper.AskToggleDebugIntersection_Serializer)
end

SerializerHelper.AskDuoKaiHotPatch_Serializer = function(writer)
end

ClientToCenterGMDelegate.AskDuoKaiHotPatch = function(self)
	return self.Invoke(self, 13264474, SerializerHelper.AskDuoKaiHotPatch_Serializer)
end

SerializerHelper.NgpushTest_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToCenterGMDelegate.NgpushTest = function(self, pid)
	return self.Invoke(self, 13332006, SerializerHelper.NgpushTest_Serializer, pid)
end

SerializerHelper.AskToggleDebugLogicVehicle_Serializer = function(writer)
end

ClientToCenterGMDelegate.AskToggleDebugLogicVehicle = function(self)
	return self.Invoke(self, 13474815, SerializerHelper.AskToggleDebugLogicVehicle_Serializer)
end

SerializerHelper.GmSyncLogicTickTime_Serializer = function(writer, year, month, day, hour, minute, second)
	SerializeBase.WritePrimitive(writer, year, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, month, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, day, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, hour, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, minute, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, second, writer.WriteInt32, 0)
end

ClientToCenterGMDelegate.GmSyncLogicTickTime = function(self, year, month, day, hour, minute, second)
	return self.Invoke(self, 13548387, SerializerHelper.GmSyncLogicTickTime_Serializer, year, month, day, hour, minute, second)
end

SerializerHelper.GmReloadAllSpoonGraph_Serializer = function(writer)
end

ClientToCenterGMDelegate.GmReloadAllSpoonGraph = function(self)
	return self.Invoke(self, 13587548, SerializerHelper.GmReloadAllSpoonGraph_Serializer)
end

SerializerHelper.AskToggleGameSwitchAetherVehicleGO_Serializer = function(writer)
end

ClientToCenterGMDelegate.AskToggleGameSwitchAetherVehicleGO = function(self)
	return self.Invoke(self, 13596548, SerializerHelper.AskToggleGameSwitchAetherVehicleGO_Serializer)
end

SerializerHelper.GmGetServerTime_Serializer = function(writer)
end

ClientToCenterGMDelegate.GmGetServerTime = function(self)
	return self.Invoke(self, 13656722, SerializerHelper.GmGetServerTime_Serializer)
end

SerializerHelper.AskSimplePatchConfig_Serializer = function(writer, configname, configid, content)
	writer.WriteString(writer, configname, false, "AskSimplePatchConfig.configName", 0)
	SerializeBase.WritePrimitive(writer, configid, writer.WriteUInt32, 0)
	writer.WriteString(writer, content, false, "AskSimplePatchConfig.content", 0)
end

ClientToCenterGMDelegate.AskSimplePatchConfig = function(self, configname, configid, content)
	return self.Invoke(self, 13681595, SerializerHelper.AskSimplePatchConfig_Serializer, configname, configid, content)
end

SerializerHelper.GmForwardILFixPatch_Serializer = function(writer, pid, patch)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WriteList7Bit(writer, patch, writer.WriteByte, 0, "patch", false, 0, nil)
end

ClientToCenterGMDelegate.GmForwardILFixPatch = function(self, pid, patch)
	return self.Invoke(self, 13688649, SerializerHelper.GmForwardILFixPatch_Serializer, pid, patch)
end

SerializerHelper.AskToggleGameSwitchAetherVehicle_Serializer = function(writer)
end

ClientToCenterGMDelegate.AskToggleGameSwitchAetherVehicle = function(self)
	return self.Invoke(self, 13754119, SerializerHelper.AskToggleGameSwitchAetherVehicle_Serializer)
end

SerializerHelper.GmTeleportAllToEntity_Serializer = function(writer, scene, entityid)
	SerializeBase.WritePrimitive(writer, scene, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, entityid, writer.WriteUInt64, 0)
end

ClientToCenterGMDelegate.GmTeleportAllToEntity = function(self, scene, entityid)
	return self.Invoke(self, 13757634, SerializerHelper.GmTeleportAllToEntity_Serializer, scene, entityid)
end

SerializerHelper.AskHotConfigData_Serializer = function(writer)
end

ClientToCenterGMDelegate.AskHotConfigData = function(self)
	return self.Invoke(self, 13757740, SerializerHelper.AskHotConfigData_Serializer)
end

SerializerHelper.TestReCallback_Serializer = function(writer, url, body, headers)
	writer.WriteString(writer, url, false, "TestReCallback.url", 0)
	writer.WriteString(writer, body, false, "TestReCallback.body", 0)
	SerializeBase.WriteDict7Bit(writer, headers, SerializeBase.WriteStringWrap(false, "headers", 0), SerializeBase.WriteStringWrap(false, "headers", 0), nil, "headers", false, 0)
end

ClientToCenterGMDelegate.TestReCallback = function(self, url, body, headers)
	return self.Invoke(self, 13760602, SerializerHelper.TestReCallback_Serializer, url, body, headers)
end

SerializerHelper.GmEnableAllFileWatch_Serializer = function(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

ClientToCenterGMDelegate.GmEnableAllFileWatch = function(self, enable)
	return self.Invoke(self, 13769911, SerializerHelper.GmEnableAllFileWatch_Serializer, enable)
end

SerializerHelper.SetGameServerOpen_Serializer = function(writer, appid, v)
	SerializeBase.WritePrimitive(writer, appid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, v, writer.WriteBoolean, false)
end

ClientToCenterGMDelegate.SetGameServerOpen = function(self, appid, v)
	return self.Invoke(self, 13781558, SerializerHelper.SetGameServerOpen_Serializer, appid, v)
end

SerializerHelper.AskHotPatch_Serializer = function(writer)
end

ClientToCenterGMDelegate.AskHotPatch = function(self)
	return self.Invoke(self, 13783771, SerializerHelper.AskHotPatch_Serializer)
end

SerializerHelper.GmTeleportAllToPosition_Serializer = function(writer, scene, pos)
	SerializeBase.WritePrimitive(writer, scene, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
end

ClientToCenterGMDelegate.GmTeleportAllToPosition = function(self, scene, pos)
	return self.Invoke(self, 13850894, SerializerHelper.GmTeleportAllToPosition_Serializer, scene, pos)
end

SerializerHelper.SetUseWhiteList_Serializer = function(writer, use)
	SerializeBase.WritePrimitive(writer, use, writer.WriteBoolean, false)
end

ClientToCenterGMDelegate.SetUseWhiteList = function(self, use)
	return self.Invoke(self, 13879767, SerializerHelper.SetUseWhiteList_Serializer, use)
end

SerializerHelper.AskToggleGameSwitchDebugAetherVehicle_Serializer = function(writer)
end

ClientToCenterGMDelegate.AskToggleGameSwitchDebugAetherVehicle = function(self)
	return self.Invoke(self, 13951104, SerializerHelper.AskToggleGameSwitchDebugAetherVehicle_Serializer)
end

return ClientToCenterGMDelegate
