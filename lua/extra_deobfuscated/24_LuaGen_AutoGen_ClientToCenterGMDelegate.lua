local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToCenterGMDelegate = invoker:New()

function ClientToCenterGMDelegate.Sender()
	return NetworkManager.LuaGateRpcProcessor
end

function SerializerHelper.AskSimplePatchConfig_Serializer(writer, configname, configid, content)
	writer:WriteString(configname, false, "configname", 0)
	SerializeBase.WritePrimitive(writer, configid, writer.WriteUInt32, 0)
	writer:WriteString(content, false, "content", 0)
end

function ClientToCenterGMDelegate:AskSimplePatchConfig(configname, configid, content)
	return self:Invoke(13064867, SerializerHelper.AskSimplePatchConfig_Serializer, configname, configid, content)
end

function SerializerHelper.GmUpdateAccountActivation_Serializer(writer, aid, account)
	SerializeBase.WritePrimitive(writer, aid, writer.WriteInt32, 0)
	writer:WriteString(account, false, "account", 0)
end

function ClientToCenterGMDelegate:GmUpdateAccountActivation(aid, account)
	return self:Invoke(13095952, SerializerHelper.GmUpdateAccountActivation_Serializer, aid, account)
end

function SerializerHelper.AskHotPatch_Serializer(writer)
	return
end

function ClientToCenterGMDelegate:AskHotPatch()
	return self:Invoke(13177164, SerializerHelper.AskHotPatch_Serializer)
end

function SerializerHelper.GmSyncLogicTickTime_Serializer(writer, year, month, day, hour, minute, second)
	SerializeBase.WritePrimitive(writer, year, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, month, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, day, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, hour, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, minute, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, second, writer.WriteInt32, 0)
end

function ClientToCenterGMDelegate:GmSyncLogicTickTime(year, month, day, hour, minute, second)
	return self:Invoke(13190420, SerializerHelper.GmSyncLogicTickTime_Serializer, year, month, day, hour, minute, second)
end

function SerializerHelper.GmReloadAllSpoonGraph_Serializer(writer)
	return
end

function ClientToCenterGMDelegate:GmReloadAllSpoonGraph()
	return self:Invoke(13190945, SerializerHelper.GmReloadAllSpoonGraph_Serializer)
end

function SerializerHelper.AskToggleGameSwitchAetherVehicleGO_Serializer(writer)
	return
end

function ClientToCenterGMDelegate:AskToggleGameSwitchAetherVehicleGO()
	return self:Invoke(13245047, SerializerHelper.AskToggleGameSwitchAetherVehicleGO_Serializer)
end

function SerializerHelper.AskHotConfigData_Serializer(writer)
	return
end

function ClientToCenterGMDelegate:AskHotConfigData()
	return self:Invoke(13248254, SerializerHelper.AskHotConfigData_Serializer)
end

function SerializerHelper.AskToggleGameSwitchDebugDangerZone_Serializer(writer)
	return
end

function ClientToCenterGMDelegate:AskToggleGameSwitchDebugDangerZone()
	return self:Invoke(13270993, SerializerHelper.AskToggleGameSwitchDebugDangerZone_Serializer)
end

function SerializerHelper.AskToggleDebugLogicVehicle_Serializer(writer)
	return
end

function ClientToCenterGMDelegate:AskToggleDebugLogicVehicle()
	return self:Invoke(13332623, SerializerHelper.AskToggleDebugLogicVehicle_Serializer)
end

function SerializerHelper.TestReCallback_Serializer(writer, url, body, headers)
	writer:WriteString(url, false, "url", 0)
	writer:WriteString(body, false, "body", 0)
	SerializeBase.WriteDict(writer, headers, SerializeBase.WriteStringWrap(false, "headers", 0), SerializeBase.WriteStringWrap(false, "headers", 0), nil, "headers", false, 0)
end

function ClientToCenterGMDelegate:TestReCallback(url, body, headers)
	return self:Invoke(13335141, SerializerHelper.TestReCallback_Serializer, url, body, headers)
end

function SerializerHelper.AskDuoKaiHotPatch_Serializer(writer)
	return
end

function ClientToCenterGMDelegate:AskDuoKaiHotPatch()
	return self:Invoke(13358496, SerializerHelper.AskDuoKaiHotPatch_Serializer)
end

function SerializerHelper.AskToggleDebugIntersection_Serializer(writer)
	return
end

function ClientToCenterGMDelegate:AskToggleDebugIntersection()
	return self:Invoke(13359941, SerializerHelper.AskToggleDebugIntersection_Serializer)
end

function SerializerHelper.AskToggleGameSwitchDebugHiddenArea_Serializer(writer)
	return
end

function ClientToCenterGMDelegate:AskToggleGameSwitchDebugHiddenArea()
	return self:Invoke(13370624, SerializerHelper.AskToggleGameSwitchDebugHiddenArea_Serializer)
end

function SerializerHelper.GmEnableAllFileWatch_Serializer(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

function ClientToCenterGMDelegate:GmEnableAllFileWatch(enable)
	return self:Invoke(13371434, SerializerHelper.GmEnableAllFileWatch_Serializer, enable)
end

function SerializerHelper.AskToggleGameSwitchAetherVehicle_Serializer(writer)
	return
end

function ClientToCenterGMDelegate:AskToggleGameSwitchAetherVehicle()
	return self:Invoke(13391743, SerializerHelper.AskToggleGameSwitchAetherVehicle_Serializer)
end

function SerializerHelper.SetUseWhiteList_Serializer(writer, use)
	SerializeBase.WritePrimitive(writer, use, writer.WriteBoolean, false)
end

function ClientToCenterGMDelegate:SetUseWhiteList(use)
	return self:Invoke(13414325, SerializerHelper.SetUseWhiteList_Serializer, use)
end

function SerializerHelper.GetSVNVersion_Serializer(writer)
	return
end

function ClientToCenterGMDelegate:GetSVNVersion()
	return self:Invoke(13458899, SerializerHelper.GetSVNVersion_Serializer)
end

function SerializerHelper.GmTeleportAllToEntity_Serializer(writer, scene, entityid)
	SerializeBase.WritePrimitive(writer, scene, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, entityid, writer.WriteUInt64, 0)
end

function ClientToCenterGMDelegate:GmTeleportAllToEntity(scene, entityid)
	return self:Invoke(13467299, SerializerHelper.GmTeleportAllToEntity_Serializer, scene, entityid)
end

function SerializerHelper.AskToggleGameSwitchDebugAetherVehicle_Serializer(writer)
	return
end

function ClientToCenterGMDelegate:AskToggleGameSwitchDebugAetherVehicle()
	return self:Invoke(13663496, SerializerHelper.AskToggleGameSwitchDebugAetherVehicle_Serializer)
end

function SerializerHelper.SetUIInvisible_Serializer(writer)
	return
end

function ClientToCenterGMDelegate:SetUIInvisible()
	return self:Invoke(13666860, SerializerHelper.SetUIInvisible_Serializer)
end

function SerializerHelper.GmGetServerTime_Serializer(writer)
	return
end

function ClientToCenterGMDelegate:GmGetServerTime()
	return self:Invoke(13714743, SerializerHelper.GmGetServerTime_Serializer)
end

function SerializerHelper.GmTeleportAllToPosition_Serializer(writer, scene, pos)
	SerializeBase.WritePrimitive(writer, scene, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
end

function ClientToCenterGMDelegate:GmTeleportAllToPosition(scene, pos)
	return self:Invoke(13727744, SerializerHelper.GmTeleportAllToPosition_Serializer, scene, pos)
end

function SerializerHelper.NgpushTest_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToCenterGMDelegate:NgpushTest(pid)
	return self:Invoke(13753963, SerializerHelper.NgpushTest_Serializer, pid)
end

function SerializerHelper.GmForwardILFixPatch_Serializer(writer, pid, patch)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WriteList(writer, patch, writer.WriteByte, 0, "patch", false, 0, nil)
end

function ClientToCenterGMDelegate:GmForwardILFixPatch(pid, patch)
	return self:Invoke(13831025, SerializerHelper.GmForwardILFixPatch_Serializer, pid, patch)
end

function SerializerHelper.SetGameServerOpen_Serializer(writer, appid, v)
	SerializeBase.WritePrimitive(writer, appid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, v, writer.WriteBoolean, false)
end

function ClientToCenterGMDelegate:SetGameServerOpen(appid, v)
	return self:Invoke(13902467, SerializerHelper.SetGameServerOpen_Serializer, appid, v)
end

return ClientToCenterGMDelegate
