-- Original chunk: @Lua\LuaGen\AutoGen\ClientToGameSceneGMDelegate.lua
-- Decompiled from: 00071_ClientToGameSceneGMDelegate.lua_1e169136f6fe.luajit

local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToGameSceneGMDelegate = invoker.New(invoker)

ClientToGameSceneGMDelegate.Sender = function()
	return NetworkManager.LuaGameRpcProcessor
end

SerializerHelper.GmQueryNpcDetailInfos_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmQueryNpcDetailInfos = function(self)
	return self.Invoke(self, 69002867, SerializerHelper.GmQueryNpcDetailInfos_Serializer)
end

SerializerHelper.GmAgentPlayDialog_Serializer = function(writer, instanceid, dialogid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, dialogid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAgentPlayDialog = function(self, instanceid, dialogid)
	return self.Invoke(self, 69013218, SerializerHelper.GmAgentPlayDialog_Serializer, instanceid, dialogid)
end

SerializerHelper.GmAllSwitchToBattle_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmAllSwitchToBattle = function(self)
	return self.Invoke(self, 69018541, SerializerHelper.GmAllSwitchToBattle_Serializer)
end

SerializerHelper.GmSimulateRingTossDisconnect_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmSimulateRingTossDisconnect = function(self, gadgetuid)
	return self.Invoke(self, 69019623, SerializerHelper.GmSimulateRingTossDisconnect_Serializer, gadgetuid)
end

SerializerHelper.GmEndSyncAIAction_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmEndSyncAIAction = function(self)
	return self.Invoke(self, 69026332, SerializerHelper.GmEndSyncAIAction_Serializer)
end

SerializerHelper.GmPauseBehaviorAI_Serializer = function(writer, id, value)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmPauseBehaviorAI = function(self, id, value)
	return self.Invoke(self, 69029151, SerializerHelper.GmPauseBehaviorAI_Serializer, id, value)
end

SerializerHelper.GmQueryBasketballForceResult_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmQueryBasketballForceResult = function(self)
	return self.Invoke(self, 69032477, SerializerHelper.GmQueryBasketballForceResult_Serializer)
end

SerializerHelper.GMEnableVehicleEscapeDebug_Serializer = function(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GMEnableVehicleEscapeDebug = function(self, enable)
	return self.Invoke(self, 69041898, SerializerHelper.GMEnableVehicleEscapeDebug_Serializer, enable)
end

SerializerHelper.GmAetherActivateNpcPrefab_Serializer = function(writer, prefabname, enable)
	writer.WriteString(writer, prefabname, false, "GmAetherActivateNpcPrefab.prefabName", 0)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmAetherActivateNpcPrefab = function(self, prefabname, enable)
	return self.Invoke(self, 69042690, SerializerHelper.GmAetherActivateNpcPrefab_Serializer, prefabname, enable)
end

SerializerHelper.GmAgentPlayPoiAction_Serializer = function(writer, pid, poiactionid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, poiactionid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAgentPlayPoiAction = function(self, pid, poiactionid)
	return self.Invoke(self, 69047942, SerializerHelper.GmAgentPlayPoiAction_Serializer, pid, poiactionid)
end

SerializerHelper.GmAgentGetOutVehicle_Serializer = function(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmAgentGetOutVehicle = function(self, agentid)
	return self.Invoke(self, 69049473, SerializerHelper.GmAgentGetOutVehicle_Serializer, agentid)
end

SerializerHelper.GmAgentFaceTo_Serializer = function(writer, agentid, targetunitid, tolerance)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetunitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, tolerance, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmAgentFaceTo = function(self, agentid, targetunitid, tolerance)
	return self.Invoke(self, 69051503, SerializerHelper.GmAgentFaceTo_Serializer, agentid, targetunitid, tolerance)
end

SerializerHelper.GmExtractionShooterRaidSplitItem_Serializer = function(writer, bagconfigid, containerinstanceid, splitcellx, splitcelly, splitcount, isrotated)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, splitcellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, splitcelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, splitcount, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isrotated, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmExtractionShooterRaidSplitItem = function(self, bagconfigid, containerinstanceid, splitcellx, splitcelly, splitcount, isrotated)
	return self.Invoke(self, 69051698, SerializerHelper.GmExtractionShooterRaidSplitItem_Serializer, bagconfigid, containerinstanceid, splitcellx, splitcelly, splitcount, isrotated)
end

SerializerHelper.GmAgentGetInVehicle_Serializer = function(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmAgentGetInVehicle = function(self, agentid)
	return self.Invoke(self, 69056843, SerializerHelper.GmAgentGetInVehicle_Serializer, agentid)
end

SerializerHelper.GmEndAIDebug_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmEndAIDebug = function(self)
	return self.Invoke(self, 69058863, SerializerHelper.GmEndAIDebug_Serializer)
end

SerializerHelper.GmEnterChineseChessZoneEndGame_Serializer = function(writer, gadgetuid, agentid, endgameid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, endgameid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmEnterChineseChessZoneEndGame = function(self, gadgetuid, agentid, endgameid)
	return self.Invoke(self, 69059997, SerializerHelper.GmEnterChineseChessZoneEndGame_Serializer, gadgetuid, agentid, endgameid)
end

SerializerHelper.GmTestDamage_Serializer = function(writer, id, rate, damage, hurtid, elementtype, elementassign, elementvalue, hurtimpact, hurtleftorrighthit)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, rate, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, damage, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, hurtid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, elementtype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, elementassign, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, elementvalue, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, hurtimpact, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, hurtleftorrighthit, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmTestDamage = function(self, id, rate, damage, hurtid, elementtype, elementassign, elementvalue, hurtimpact, hurtleftorrighthit)
	return self.Invoke(self, 69061923, SerializerHelper.GmTestDamage_Serializer, id, rate, damage, hurtid, elementtype, elementassign, elementvalue, hurtimpact, hurtleftorrighthit)
end

SerializerHelper.GmClearBotPlayer_Serializer = function(writer, botid)
	SerializeBase.WritePrimitive(writer, botid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmClearBotPlayer = function(self, botid)
	return self.Invoke(self, 69065846, SerializerHelper.GmClearBotPlayer_Serializer, botid)
end

SerializerHelper.GmLockEmotion_Serializer = function(writer, agentid, value)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmLockEmotion = function(self, agentid, value)
	return self.Invoke(self, 69067993, SerializerHelper.GmLockEmotion_Serializer, agentid, value)
end

SerializerHelper.GmSwitchToWeapon_Serializer = function(writer, weaponid)
	SerializeBase.WritePrimitive(writer, weaponid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmSwitchToWeapon = function(self, weaponid)
	return self.Invoke(self, 69071899, SerializerHelper.GmSwitchToWeapon_Serializer, weaponid)
end

SerializerHelper.GmTriggerPlotEvent2_Serializer = function(writer, ploteventid, agentid)
	SerializeBase.WritePrimitive(writer, ploteventid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmTriggerPlotEvent2 = function(self, ploteventid, agentid)
	return self.Invoke(self, 69072604, SerializerHelper.GmTriggerPlotEvent2_Serializer, ploteventid, agentid)
end

SerializerHelper.GmTeleportXYZ_Serializer = function(writer, x, y, z, facing)
	SerializeBase.WritePrimitive(writer, x, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, y, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, z, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmTeleportXYZ = function(self, x, y, z, facing)
	return self.Invoke(self, 69073332, SerializerHelper.GmTeleportXYZ_Serializer, x, y, z, facing)
end

SerializerHelper.GmExtractionShooterShiftContainerItem_Serializer = function(writer, containerinstanceid, fromcellx, fromcelly, tocellx, tocelly, isrotated)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, fromcellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromcelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tocellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tocelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isrotated, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmExtractionShooterShiftContainerItem = function(self, containerinstanceid, fromcellx, fromcelly, tocellx, tocelly, isrotated)
	return self.Invoke(self, 69073724, SerializerHelper.GmExtractionShooterShiftContainerItem_Serializer, containerinstanceid, fromcellx, fromcelly, tocellx, tocelly, isrotated)
end

SerializerHelper.GmAddDestructible_Serializer = function(writer, pathid, cfgid, position, facing, iscale)
	SerializeBase.WritePrimitive(writer, pathid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, cfgid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WriteStruct(writer, facing, SerializeAuto.WriteUXVector3, "facing")
	SerializeBase.WritePrimitive(writer, iscale, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmAddDestructible = function(self, pathid, cfgid, position, facing, iscale)
	return self.Invoke(self, 69075356, SerializerHelper.GmAddDestructible_Serializer, pathid, cfgid, position, facing, iscale)
end

SerializerHelper.GmAddOtherUnitStateByInstance_Serializer = function(writer, instanceid, state)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAddOtherUnitStateByInstance = function(self, instanceid, state)
	return self.Invoke(self, 69078971, SerializerHelper.GmAddOtherUnitStateByInstance_Serializer, instanceid, state)
end

SerializerHelper.GmBehaviorBreakContinue_Serializer = function(writer, id, type, treename)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	writer.WriteString(writer, treename, false, "GmBehaviorBreakContinue.treeName", 0)
end

ClientToGameSceneGMDelegate.GmBehaviorBreakContinue = function(self, id, type, treename)
	return self.Invoke(self, 69081885, SerializerHelper.GmBehaviorBreakContinue_Serializer, id, type, treename)
end

SerializerHelper.GMWinGomoku_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GMWinGomoku = function(self)
	return self.Invoke(self, 69084868, SerializerHelper.GMWinGomoku_Serializer)
end

SerializerHelper.GmChangeAgentBehaviorTree_Serializer = function(writer, id, treename)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	writer.WriteString(writer, treename, false, "GmChangeAgentBehaviorTree.treeName", 0)
end

ClientToGameSceneGMDelegate.GmChangeAgentBehaviorTree = function(self, id, treename)
	return self.Invoke(self, 69087504, SerializerHelper.GmChangeAgentBehaviorTree_Serializer, id, treename)
end

SerializerHelper.GmAddEnemyByPlayer_Serializer = function(writer, enemyid, camp)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(camp, 92, 0), writer.WriteByte, 0)
end

ClientToGameSceneGMDelegate.GmAddEnemyByPlayer = function(self, enemyid, camp)
	return self.Invoke(self, 69089286, SerializerHelper.GmAddEnemyByPlayer_Serializer, enemyid, camp)
end

SerializerHelper.GmRefreshRandomEvent_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmRefreshRandomEvent = function(self)
	return self.Invoke(self, 69090501, SerializerHelper.GmRefreshRandomEvent_Serializer)
end

SerializerHelper.GmAddCompanionWithTree_Serializer = function(writer, agentid, btname)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	writer.WriteString(writer, btname, false, "GmAddCompanionWithTree.BTName", 0)
end

ClientToGameSceneGMDelegate.GmAddCompanionWithTree = function(self, agentid, btname)
	return self.Invoke(self, 69092961, SerializerHelper.GmAddCompanionWithTree_Serializer, agentid, btname)
end

SerializerHelper.GmAetherNpcFirstSpawnOnly_Serializer = function(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmAetherNpcFirstSpawnOnly = function(self, enable)
	return self.Invoke(self, 69094155, SerializerHelper.GmAetherNpcFirstSpawnOnly_Serializer, enable)
end

SerializerHelper.GmAddWeaponToArmory_Serializer = function(writer, weaponid, count)
	SerializeBase.WritePrimitive(writer, weaponid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAddWeaponToArmory = function(self, weaponid, count)
	return self.Invoke(self, 69095593, SerializerHelper.GmAddWeaponToArmory_Serializer, weaponid, count)
end

SerializerHelper.GmAgentNavigationMove_Serializer = function(writer, agentid, targetunitid, arrivedistance, movemethod)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetunitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, arrivedistance, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, movemethod, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmAgentNavigationMove = function(self, agentid, targetunitid, arrivedistance, movemethod)
	return self.Invoke(self, 69097774, SerializerHelper.GmAgentNavigationMove_Serializer, agentid, targetunitid, arrivedistance, movemethod)
end

SerializerHelper.GmDebugAllGadget_Serializer = function(writer, distance)
	SerializeBase.WritePrimitive(writer, distance, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmDebugAllGadget = function(self, distance)
	return self.Invoke(self, 69099573, SerializerHelper.GmDebugAllGadget_Serializer, distance)
end

SerializerHelper.GmSetDgoNavSurfaceState_Serializer = function(writer, dgoid, enable)
	SerializeBase.WritePrimitive(writer, dgoid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmSetDgoNavSurfaceState = function(self, dgoid, enable)
	return self.Invoke(self, 69106413, SerializerHelper.GmSetDgoNavSurfaceState_Serializer, dgoid, enable)
end

SerializerHelper.GmSetTempCamp_Serializer = function(writer, id, camp)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(camp, 92, 0), writer.WriteByte, 0)
end

ClientToGameSceneGMDelegate.GmSetTempCamp = function(self, id, camp)
	return self.Invoke(self, 69107403, SerializerHelper.GmSetTempCamp_Serializer, id, camp)
end

SerializerHelper.GmStopAllEnemyAi_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmStopAllEnemyAi = function(self)
	return self.Invoke(self, 69109170, SerializerHelper.GmStopAllEnemyAi_Serializer)
end

SerializerHelper.GmSetIndoorSectorId_Serializer = function(writer, showid, hideid)
	SerializeBase.WritePrimitive(writer, showid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, hideid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmSetIndoorSectorId = function(self, showid, hideid)
	return self.Invoke(self, 69111982, SerializerHelper.GmSetIndoorSectorId_Serializer, showid, hideid)
end

SerializerHelper.GmSetWashCleaningInfo_Serializer = function(writer, progress, totalsecond, forceend)
	SerializeBase.WritePrimitive(writer, progress, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, totalsecond, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, forceend, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmSetWashCleaningInfo = function(self, progress, totalsecond, forceend)
	return self.Invoke(self, 69117020, SerializerHelper.GmSetWashCleaningInfo_Serializer, progress, totalsecond, forceend)
end

SerializerHelper.GmAetherResetAreaDensity_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmAetherResetAreaDensity = function(self)
	return self.Invoke(self, 69118617, SerializerHelper.GmAetherResetAreaDensity_Serializer)
end

SerializerHelper.GmAetherChangePedNumScale_Serializer = function(writer, scale, refreshnpc)
	SerializeBase.WritePrimitive(writer, scale, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, refreshnpc, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmAetherChangePedNumScale = function(self, scale, refreshnpc)
	return self.Invoke(self, 69119776, SerializerHelper.GmAetherChangePedNumScale_Serializer, scale, refreshnpc)
end

SerializerHelper.GmRaidEnemyForceLock_Serializer = function(writer, groupid, targetid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmRaidEnemyForceLock = function(self, groupid, targetid)
	return self.Invoke(self, 69123026, SerializerHelper.GmRaidEnemyForceLock_Serializer, groupid, targetid)
end

SerializerHelper.GmSurrenderChineseChess_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmSurrenderChineseChess = function(self, gadgetuid)
	return self.Invoke(self, 69133864, SerializerHelper.GmSurrenderChineseChess_Serializer, gadgetuid)
end

SerializerHelper.GmEndEnemyGroupDebug_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmEndEnemyGroupDebug = function(self)
	return self.Invoke(self, 69134617, SerializerHelper.GmEndEnemyGroupDebug_Serializer)
end

SerializerHelper.GmEnterBowlingZone_Serializer = function(writer, gadgetuid, gametype, agentid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, gametype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmEnterBowlingZone = function(self, gadgetuid, gametype, agentid)
	return self.Invoke(self, 69135013, SerializerHelper.GmEnterBowlingZone_Serializer, gadgetuid, gametype, agentid)
end

SerializerHelper.GmSpawnFlyerVehicle_Serializer = function(writer, aiconfigid, recordingname, position, facing, vehicleconfigweights, spawninterval, spawnintervalmin, spawnintervalmax, spawnlimit, initprefilldistancemin, initprefilldistancemax, spawnnpc, spawnnpcpersona, spawnnpcdmconfigid)
	SerializeBase.WritePrimitive(writer, aiconfigid, writer.WriteUInt32, 0)
	writer.WriteString(writer, recordingname, false, "GmSpawnFlyerVehicle.recordingName", 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
	SerializeBase.WriteList7Bit(writer, vehicleconfigweights, SerializeBase.WriteStructWrap(SerializeAuto.WriteWeightedRandomItemUInt, "vehicleconfigweights"), nil, "vehicleconfigweights", false, 0, nil)
	SerializeBase.WritePrimitive(writer, spawninterval, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, spawnintervalmin, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, spawnintervalmax, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, spawnlimit, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, initprefilldistancemin, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, initprefilldistancemax, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, spawnnpc, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, spawnnpcpersona, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, spawnnpcdmconfigid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmSpawnFlyerVehicle = function(self, aiconfigid, recordingname, position, facing, vehicleconfigweights, spawninterval, spawnintervalmin, spawnintervalmax, spawnlimit, initprefilldistancemin, initprefilldistancemax, spawnnpc, spawnnpcpersona, spawnnpcdmconfigid)
	return self.Invoke(self, 69137543, SerializerHelper.GmSpawnFlyerVehicle_Serializer, aiconfigid, recordingname, position, facing, vehicleconfigweights, spawninterval, spawnintervalmin, spawnintervalmax, spawnlimit, initprefilldistancemin, initprefilldistancemax, spawnnpc, spawnnpcpersona, spawnnpcdmconfigid)
end

SerializerHelper.GmWeaponDurabilityFree_Serializer = function(writer, isfree)
	SerializeBase.WritePrimitive(writer, isfree, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmWeaponDurabilityFree = function(self, isfree)
	return self.Invoke(self, 69138017, SerializerHelper.GmWeaponDurabilityFree_Serializer, isfree)
end

SerializerHelper.GmBusTeleportToVehicle_Serializer = function(writer, lineid)
	SerializeBase.WritePrimitive(writer, lineid, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmBusTeleportToVehicle = function(self, lineid)
	return self.Invoke(self, 69151196, SerializerHelper.GmBusTeleportToVehicle_Serializer, lineid)
end

SerializerHelper.GmLeaveChineseChess_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmLeaveChineseChess = function(self, gadgetuid)
	return self.Invoke(self, 69152206, SerializerHelper.GmLeaveChineseChess_Serializer, gadgetuid)
end

SerializerHelper.GmConvertSpoonNpcToBattleUnit_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmConvertSpoonNpcToBattleUnit = function(self, id)
	return self.Invoke(self, 69154887, SerializerHelper.GmConvertSpoonNpcToBattleUnit_Serializer, id)
end

SerializerHelper.GmAddUnitStateToOther_Serializer = function(writer, uid, state)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAddUnitStateToOther = function(self, uid, state)
	return self.Invoke(self, 69159031, SerializerHelper.GmAddUnitStateToOther_Serializer, uid, state)
end

SerializerHelper.GmSetAmbianceEnabled_Serializer = function(writer, enabled, type)
	SerializeBase.WritePrimitive(writer, enabled, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, type, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmSetAmbianceEnabled = function(self, enabled, type)
	return self.Invoke(self, 69166506, SerializerHelper.GmSetAmbianceEnabled_Serializer, enabled, type)
end

SerializerHelper.GmClearBattleStatisticsData_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmClearBattleStatisticsData = function(self)
	return self.Invoke(self, 69176212, SerializerHelper.GmClearBattleStatisticsData_Serializer)
end

SerializerHelper.GmStartPlotBehaviorWithParams_Serializer = function(writer, agentid, treename, priority, paramsjson)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	writer.WriteString(writer, treename, false, "GmStartPlotBehaviorWithParams.treeName", 0)
	SerializeBase.WritePrimitive(writer, priority, writer.WriteUInt32, 0)
	writer.WriteString(writer, paramsjson, false, "GmStartPlotBehaviorWithParams.paramsJson", 0)
end

ClientToGameSceneGMDelegate.GmStartPlotBehaviorWithParams = function(self, agentid, treename, priority, paramsjson)
	return self.Invoke(self, 69176989, SerializerHelper.GmStartPlotBehaviorWithParams_Serializer, agentid, treename, priority, paramsjson)
end

SerializerHelper.GmRemoveCompanion_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmRemoveCompanion = function(self)
	return self.Invoke(self, 69177877, SerializerHelper.GmRemoveCompanion_Serializer)
end

SerializerHelper.GmSetAttr_Serializer = function(writer, attr, value)
	SerializeBase.WritePrimitive(writer, attr, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmSetAttr = function(self, attr, value)
	return self.Invoke(self, 69185347, SerializerHelper.GmSetAttr_Serializer, attr, value)
end

SerializerHelper.GmExtractionShooterSearchContainer_Serializer = function(writer, containerinstanceid)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmExtractionShooterSearchContainer = function(self, containerinstanceid)
	return self.Invoke(self, 69185485, SerializerHelper.GmExtractionShooterSearchContainer_Serializer, containerinstanceid)
end

SerializerHelper.GmAetherChangeQuality_Serializer = function(writer, charactercountquality, vehiclecountquality)
	SerializeBase.WritePrimitive(writer, charactercountquality, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, vehiclecountquality, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmAetherChangeQuality = function(self, charactercountquality, vehiclecountquality)
	return self.Invoke(self, 69186381, SerializerHelper.GmAetherChangeQuality_Serializer, charactercountquality, vehiclecountquality)
end

SerializerHelper.GmRecoverAllSkillCooldown_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmRecoverAllSkillCooldown = function(self)
	return self.Invoke(self, 69187025, SerializerHelper.GmRecoverAllSkillCooldown_Serializer)
end

SerializerHelper.GmTeleportToLinkMember_Serializer = function(writer, index)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmTeleportToLinkMember = function(self, index)
	return self.Invoke(self, 69188197, SerializerHelper.GmTeleportToLinkMember_Serializer, index)
end

SerializerHelper.GmAetherEnsureRefreshStaticNpc_Serializer = function(writer, ensurerefresh)
	SerializeBase.WritePrimitive(writer, ensurerefresh, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmAetherEnsureRefreshStaticNpc = function(self, ensurerefresh)
	return self.Invoke(self, 69192168, SerializerHelper.GmAetherEnsureRefreshStaticNpc_Serializer, ensurerefresh)
end

SerializerHelper.GmDeathPartyClearPhaseTask_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmDeathPartyClearPhaseTask = function(self)
	return self.Invoke(self, 69192263, SerializerHelper.GmDeathPartyClearPhaseTask_Serializer)
end

SerializerHelper.GmChangeZoneGameTime_Serializer = function(writer, second)
	SerializeBase.WritePrimitive(writer, second, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmChangeZoneGameTime = function(self, second)
	return self.Invoke(self, 69194870, SerializerHelper.GmChangeZoneGameTime_Serializer, second)
end

SerializerHelper.GmStartEnemyDetectDebug_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmStartEnemyDetectDebug = function(self)
	return self.Invoke(self, 69199157, SerializerHelper.GmStartEnemyDetectDebug_Serializer)
end

SerializerHelper.GmStopFlyerVehicles_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmStopFlyerVehicles = function(self)
	return self.Invoke(self, 69200014, SerializerHelper.GmStopFlyerVehicles_Serializer)
end

SerializerHelper.GmAetherAddDangerZone_Serializer = function(writer, centerpos, radius)
	SerializeBase.WriteStruct(writer, centerpos, SerializeAuto.WriteUXVector3, "centerpos")
	SerializeBase.WritePrimitive(writer, radius, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmAetherAddDangerZone = function(self, centerpos, radius)
	return self.Invoke(self, 69203787, SerializerHelper.GmAetherAddDangerZone_Serializer, centerpos, radius)
end

SerializerHelper.GmDeathPartyForcePlayerWin_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmDeathPartyForcePlayerWin = function(self)
	return self.Invoke(self, 69208480, SerializerHelper.GmDeathPartyForcePlayerWin_Serializer)
end

SerializerHelper.GmUnlockGetOffBlockVehicles_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmUnlockGetOffBlockVehicles = function(self)
	return self.Invoke(self, 69209172, SerializerHelper.GmUnlockGetOffBlockVehicles_Serializer)
end

SerializerHelper.GmWatchOtherPlayer_Serializer = function(writer, towatchplayerid)
	SerializeBase.WritePrimitive(writer, towatchplayerid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmWatchOtherPlayer = function(self, towatchplayerid)
	return self.Invoke(self, 69221234, SerializerHelper.GmWatchOtherPlayer_Serializer, towatchplayerid)
end

SerializerHelper.GmClearBasketballForceResult_Serializer = function(writer, operatortype)
	SerializeBase.WritePrimitive(writer, operatortype, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmClearBasketballForceResult = function(self, operatortype)
	return self.Invoke(self, 69225604, SerializerHelper.GmClearBasketballForceResult_Serializer, operatortype)
end

SerializerHelper.GmAddOtherUnitState_Serializer = function(writer, templateid, state)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAddOtherUnitState = function(self, templateid, state)
	return self.Invoke(self, 69228232, SerializerHelper.GmAddOtherUnitState_Serializer, templateid, state)
end

SerializerHelper.GmExtractionShooterShiftBagItemToContainer_Serializer = function(writer, bagconfigid, fromcellx, fromcelly, containerinstanceid, tocellx, tocelly, isrotated)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromcellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromcelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, tocellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tocelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isrotated, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmExtractionShooterShiftBagItemToContainer = function(self, bagconfigid, fromcellx, fromcelly, containerinstanceid, tocellx, tocelly, isrotated)
	return self.Invoke(self, 69229661, SerializerHelper.GmExtractionShooterShiftBagItemToContainer_Serializer, bagconfigid, fromcellx, fromcelly, containerinstanceid, tocellx, tocelly, isrotated)
end

SerializerHelper.GmEndEnemyStrategyDebug_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmEndEnemyStrategyDebug = function(self)
	return self.Invoke(self, 69236550, SerializerHelper.GmEndEnemyStrategyDebug_Serializer)
end

SerializerHelper.GmGetDestructibleInfo_Serializer = function(writer, instanceid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmGetDestructibleInfo = function(self, instanceid)
	return self.Invoke(self, 69249562, SerializerHelper.GmGetDestructibleInfo_Serializer, instanceid)
end

SerializerHelper.GmCreateToiletSquatting_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmCreateToiletSquatting = function(self)
	return self.Invoke(self, 69250152, SerializerHelper.GmCreateToiletSquatting_Serializer)
end

SerializerHelper.GmAetherForceUseUsage_Serializer = function(writer, usageid)
	SerializeBase.WritePrimitive(writer, usageid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAetherForceUseUsage = function(self, usageid)
	return self.Invoke(self, 69256692, SerializerHelper.GmAetherForceUseUsage_Serializer, usageid)
end

SerializerHelper.GmAddBuffToAllSpirit_Serializer = function(writer, buffid, duration, releaserid)
	SerializeBase.WritePrimitive(writer, buffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, duration, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, releaserid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmAddBuffToAllSpirit = function(self, buffid, duration, releaserid)
	return self.Invoke(self, 69258100, SerializerHelper.GmAddBuffToAllSpirit_Serializer, buffid, duration, releaserid)
end

SerializerHelper.GmGetRacingCheckPointInfo_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmGetRacingCheckPointInfo = function(self)
	return self.Invoke(self, 69258829, SerializerHelper.GmGetRacingCheckPointInfo_Serializer)
end

SerializerHelper.GmClearAllLinkDuty_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmClearAllLinkDuty = function(self)
	return self.Invoke(self, 69262931, SerializerHelper.GmClearAllLinkDuty_Serializer)
end

SerializerHelper.GmAetherCreateNpc_Serializer = function(writer, type, position, facing, agentid, optiondata)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(type, 93, 0), writer.WriteByte, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, optiondata, SerializeAuto.WriteGmCreateNpcOptionData, "optiondata", true)
end

ClientToGameSceneGMDelegate.GmAetherCreateNpc = function(self, type, position, facing, agentid, optiondata)
	return self.Invoke(self, 69263101, SerializerHelper.GmAetherCreateNpc_Serializer, type, position, facing, agentid, optiondata)
end

SerializerHelper.GmDropEnemyWeapon_Serializer = function(writer, agentid, breakimmediately, yforce, zforce, gravity)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, breakimmediately, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, yforce, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, zforce, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, gravity, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmDropEnemyWeapon = function(self, agentid, breakimmediately, yforce, zforce, gravity)
	return self.Invoke(self, 69264817, SerializerHelper.GmDropEnemyWeapon_Serializer, agentid, breakimmediately, yforce, zforce, gravity)
end

SerializerHelper.GmSetHp_Serializer = function(writer, percent)
	SerializeBase.WritePrimitive(writer, percent, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmSetHp = function(self, percent)
	return self.Invoke(self, 69265896, SerializerHelper.GmSetHp_Serializer, percent)
end

SerializerHelper.GmIgnoreSpeedProtect_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmIgnoreSpeedProtect = function(self)
	return self.Invoke(self, 69275751, SerializerHelper.GmIgnoreSpeedProtect_Serializer)
end

SerializerHelper.GmClearBehaviorBreakPoint_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmClearBehaviorBreakPoint = function(self)
	return self.Invoke(self, 69276832, SerializerHelper.GmClearBehaviorBreakPoint_Serializer)
end

SerializerHelper.GmAddBasicAttr_Serializer = function(writer, attr, addvalue)
	SerializeBase.WritePrimitive(writer, attr, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, addvalue, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmAddBasicAttr = function(self, attr, addvalue)
	return self.Invoke(self, 69277785, SerializerHelper.GmAddBasicAttr_Serializer, attr, addvalue)
end

SerializerHelper.GmConvertSpoonNpcToPed_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmConvertSpoonNpcToPed = function(self, id)
	return self.Invoke(self, 69279192, SerializerHelper.GmConvertSpoonNpcToPed_Serializer, id)
end

SerializerHelper.GmPlayerUseSkillDebugOnly_Serializer = function(writer, skillid, targetid, checkcd, checknav, checknoskilltime, servercast, clientasdatasource, triggercd, useres)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, checkcd, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, checknav, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, checknoskilltime, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, servercast, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, clientasdatasource, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, triggercd, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, useres, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmPlayerUseSkillDebugOnly = function(self, skillid, targetid, checkcd, checknav, checknoskilltime, servercast, clientasdatasource, triggercd, useres)
	return self.Invoke(self, 69289312, SerializerHelper.GmPlayerUseSkillDebugOnly_Serializer, skillid, targetid, checkcd, checknav, checknoskilltime, servercast, clientasdatasource, triggercd, useres)
end

SerializerHelper.GmSetOtherAttr_Serializer = function(writer, id, attr, value)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, attr, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmSetOtherAttr = function(self, id, attr, value)
	return self.Invoke(self, 69299739, SerializerHelper.GmSetOtherAttr_Serializer, id, attr, value)
end

SerializerHelper.GmAgentEnterVision_Serializer = function(writer, uid, targetuid)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmAgentEnterVision = function(self, uid, targetuid)
	return self.Invoke(self, 69299941, SerializerHelper.GmAgentEnterVision_Serializer, uid, targetuid)
end

SerializerHelper.GmAgentGetInVehicle2_Serializer = function(writer, agentid, vehicleid, seatindex)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, seatindex, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmAgentGetInVehicle2 = function(self, agentid, vehicleid, seatindex)
	return self.Invoke(self, 69306257, SerializerHelper.GmAgentGetInVehicle2_Serializer, agentid, vehicleid, seatindex)
end

SerializerHelper.GmDumpStaticNpcSpawnLog_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmDumpStaticNpcSpawnLog = function(self)
	return self.Invoke(self, 69309957, SerializerHelper.GmDumpStaticNpcSpawnLog_Serializer)
end

SerializerHelper.GmStartEnemyDetectStateDebug_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmStartEnemyDetectStateDebug = function(self)
	return self.Invoke(self, 69310359, SerializerHelper.GmStartEnemyDetectStateDebug_Serializer)
end

SerializerHelper.GmAetherResetDensityCurve_Serializer = function(writer, urbandiversityconfigid, weathervariant)
	SerializeBase.WritePrimitive(writer, urbandiversityconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, weathervariant, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAetherResetDensityCurve = function(self, urbandiversityconfigid, weathervariant)
	return self.Invoke(self, 69319193, SerializerHelper.GmAetherResetDensityCurve_Serializer, urbandiversityconfigid, weathervariant)
end

SerializerHelper.GmBusTeleportBeforeStop_Serializer = function(writer, stopid, lineid, distancebefore)
	SerializeBase.WritePrimitive(writer, stopid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, lineid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, distancebefore, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmBusTeleportBeforeStop = function(self, stopid, lineid, distancebefore)
	return self.Invoke(self, 69321156, SerializerHelper.GmBusTeleportBeforeStop_Serializer, stopid, lineid, distancebefore)
end

SerializerHelper.GmDMEMOverride_Serializer = function(writer, subjectagentid, cfgid)
	SerializeBase.WritePrimitive(writer, subjectagentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, cfgid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmDMEMOverride = function(self, subjectagentid, cfgid)
	return self.Invoke(self, 69322100, SerializerHelper.GmDMEMOverride_Serializer, subjectagentid, cfgid)
end

SerializerHelper.GmGameGroundSurrender_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmGameGroundSurrender = function(self)
	return self.Invoke(self, 69322535, SerializerHelper.GmGameGroundSurrender_Serializer)
end

SerializerHelper.GmAddVehicleBuff_Serializer = function(writer, entityid, duration, buffid1, buffid2, buffid3)
	SerializeBase.WritePrimitive(writer, entityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, duration, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, buffid1, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, buffid2, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, buffid3, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAddVehicleBuff = function(self, entityid, duration, buffid1, buffid2, buffid3)
	return self.Invoke(self, 69325412, SerializerHelper.GmAddVehicleBuff_Serializer, entityid, duration, buffid1, buffid2, buffid3)
end

SerializerHelper.GmRevive_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmRevive = function(self)
	return self.Invoke(self, 69326361, SerializerHelper.GmRevive_Serializer)
end

SerializerHelper.GmAddCreationOnUnit_Serializer = function(writer, unitid, creationid, time)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, creationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, time, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmAddCreationOnUnit = function(self, unitid, creationid, time)
	return self.Invoke(self, 69326591, SerializerHelper.GmAddCreationOnUnit_Serializer, unitid, creationid, time)
end

SerializerHelper.GmBusSetEnabled_Serializer = function(writer, enabled)
	SerializeBase.WritePrimitive(writer, enabled, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmBusSetEnabled = function(self, enabled)
	return self.Invoke(self, 69332793, SerializerHelper.GmBusSetEnabled_Serializer, enabled)
end

SerializerHelper.GMWinChineseChess_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GMWinChineseChess = function(self)
	return self.Invoke(self, 69335873, SerializerHelper.GMWinChineseChess_Serializer)
end

SerializerHelper.GmStartSyncAIAction_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmStartSyncAIAction = function(self)
	return self.Invoke(self, 69345139, SerializerHelper.GmStartSyncAIAction_Serializer)
end

SerializerHelper.GmRefreshStaticVehicle_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmRefreshStaticVehicle = function(self)
	return self.Invoke(self, 69351567, SerializerHelper.GmRefreshStaticVehicle_Serializer)
end

SerializerHelper.GmRecordRingTossResult_Serializer = function(writer, gadgetuid, throwindex, rewarddropid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, throwindex, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, rewarddropid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmRecordRingTossResult = function(self, gadgetuid, throwindex, rewarddropid)
	return self.Invoke(self, 69353987, SerializerHelper.GmRecordRingTossResult_Serializer, gadgetuid, throwindex, rewarddropid)
end

SerializerHelper.GmSystemAddBuffToAll_Serializer = function(writer, buffid, duration)
	SerializeBase.WritePrimitive(writer, buffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, duration, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmSystemAddBuffToAll = function(self, buffid, duration)
	return self.Invoke(self, 69355324, SerializerHelper.GmSystemAddBuffToAll_Serializer, buffid, duration)
end

SerializerHelper.GmExtractionShooterRemoveContainerItem_Serializer = function(writer, containerinstanceid, cellx, celly)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, cellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, celly, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmExtractionShooterRemoveContainerItem = function(self, containerinstanceid, cellx, celly)
	return self.Invoke(self, 69356169, SerializerHelper.GmExtractionShooterRemoveContainerItem_Serializer, containerinstanceid, cellx, celly)
end

SerializerHelper.GmStopWatchOtherPlayer_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmStopWatchOtherPlayer = function(self)
	return self.Invoke(self, 69360144, SerializerHelper.GmStopWatchOtherPlayer_Serializer)
end

SerializerHelper.GmEnterBalloonZone_Serializer = function(writer, gadgetuid, gametype)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, gametype, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmEnterBalloonZone = function(self, gadgetuid, gametype)
	return self.Invoke(self, 69363970, SerializerHelper.GmEnterBalloonZone_Serializer, gadgetuid, gametype)
end

SerializerHelper.GmAgentFollow_Serializer = function(writer, agentid, targetunitid, arrivedistance, comfortrange, movemethod)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetunitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, arrivedistance, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, comfortrange, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, movemethod, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmAgentFollow = function(self, agentid, targetunitid, arrivedistance, comfortrange, movemethod)
	return self.Invoke(self, 69364273, SerializerHelper.GmAgentFollow_Serializer, agentid, targetunitid, arrivedistance, comfortrange, movemethod)
end

SerializerHelper.GmTeleportUnitXYZ_Serializer = function(writer, unitid, x, y, z)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, x, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, y, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, z, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmTeleportUnitXYZ = function(self, unitid, x, y, z)
	return self.Invoke(self, 69367128, SerializerHelper.GmTeleportUnitXYZ_Serializer, unitid, x, y, z)
end

SerializerHelper.GmQueryDamageSimulationResult_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmQueryDamageSimulationResult = function(self)
	return self.Invoke(self, 69374683, SerializerHelper.GmQueryDamageSimulationResult_Serializer)
end

SerializerHelper.GmResetVehiclePosition_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmResetVehiclePosition = function(self)
	return self.Invoke(self, 69374809, SerializerHelper.GmResetVehiclePosition_Serializer)
end

SerializerHelper.GmAgentStartVision_Serializer = function(writer, uid)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmAgentStartVision = function(self, uid)
	return self.Invoke(self, 69375396, SerializerHelper.GmAgentStartVision_Serializer, uid)
end

SerializerHelper.GmMoveChineseChessPiece_Serializer = function(writer, gadgetuid, srcx, srcy, tgtx, tgty)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, srcx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, srcy, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tgtx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tgty, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmMoveChineseChessPiece = function(self, gadgetuid, srcx, srcy, tgtx, tgty)
	return self.Invoke(self, 69375595, SerializerHelper.GmMoveChineseChessPiece_Serializer, gadgetuid, srcx, srcy, tgtx, tgty)
end

SerializerHelper.GmControlEnemyBattleMove_Serializer = function(writer, pid, targetid, actiontype, actionid, mintime, maxtime, reportonstop)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(actiontype, 94, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, actionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, mintime, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, maxtime, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, reportonstop, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmControlEnemyBattleMove = function(self, pid, targetid, actiontype, actionid, mintime, maxtime, reportonstop)
	return self.Invoke(self, 69376088, SerializerHelper.GmControlEnemyBattleMove_Serializer, pid, targetid, actiontype, actionid, mintime, maxtime, reportonstop)
end

SerializerHelper.GmBehaviorNextPoint_Serializer = function(writer, id, type, treename)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	writer.WriteString(writer, treename, false, "GmBehaviorNextPoint.treeName", 0)
end

ClientToGameSceneGMDelegate.GmBehaviorNextPoint = function(self, id, type, treename)
	return self.Invoke(self, 69378197, SerializerHelper.GmBehaviorNextPoint_Serializer, id, type, treename)
end

SerializerHelper.GmSetDgoNavVoxelSurface_Serializer = function(writer, surfaceid)
	SerializeBase.WritePrimitive(writer, surfaceid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmSetDgoNavVoxelSurface = function(self, surfaceid)
	return self.Invoke(self, 69381351, SerializerHelper.GmSetDgoNavVoxelSurface_Serializer, surfaceid)
end

SerializerHelper.GmGetAmbianceEnabled_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmGetAmbianceEnabled = function(self)
	return self.Invoke(self, 69384152, SerializerHelper.GmGetAmbianceEnabled_Serializer)
end

SerializerHelper.GmTryToLockUnit_Serializer = function(writer, selfunitid, tolockunitid)
	SerializeBase.WritePrimitive(writer, selfunitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, tolockunitid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmTryToLockUnit = function(self, selfunitid, tolockunitid)
	return self.Invoke(self, 69384902, SerializerHelper.GmTryToLockUnit_Serializer, selfunitid, tolockunitid)
end

SerializerHelper.GmGameEnd_Serializer = function(writer, iswin)
	SerializeBase.WritePrimitive(writer, iswin, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmGameEnd = function(self, iswin)
	return self.Invoke(self, 69386153, SerializerHelper.GmGameEnd_Serializer, iswin)
end

SerializerHelper.GmRemoveAgentGameplayTag_Serializer = function(writer, agentid, gameplaytagcfgid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, gameplaytagcfgid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmRemoveAgentGameplayTag = function(self, agentid, gameplaytagcfgid)
	return self.Invoke(self, 69388012, SerializerHelper.GmRemoveAgentGameplayTag_Serializer, agentid, gameplaytagcfgid)
end

SerializerHelper.GmAddEnemy_Serializer = function(writer, enemyid, camp, treename, navtagtype, outsideaoimove)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(camp, 92, 0), writer.WriteByte, 0)
	writer.WriteString(writer, treename, false, "GmAddEnemy.treeName", 0)
	SerializeBase.WritePrimitive(writer, navtagtype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, outsideaoimove, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmAddEnemy = function(self, enemyid, camp, treename, navtagtype, outsideaoimove)
	return self.Invoke(self, 69389265, SerializerHelper.GmAddEnemy_Serializer, enemyid, camp, treename, navtagtype, outsideaoimove)
end

SerializerHelper.GmReplyUndoChineseChess_Serializer = function(writer, gadgetuid, agree)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agree, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmReplyUndoChineseChess = function(self, gadgetuid, agree)
	return self.Invoke(self, 69398798, SerializerHelper.GmReplyUndoChineseChess_Serializer, gadgetuid, agree)
end

SerializerHelper.GmSetSectorNavVoxelSurface_Serializer = function(writer, surfaceid)
	SerializeBase.WritePrimitive(writer, surfaceid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmSetSectorNavVoxelSurface = function(self, surfaceid)
	return self.Invoke(self, 69400297, SerializerHelper.GmSetSectorNavVoxelSurface_Serializer, surfaceid)
end

SerializerHelper.GmAddTaskStaticNpc_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAddTaskStaticNpc = function(self, taskid)
	return self.Invoke(self, 69400501, SerializerHelper.GmAddTaskStaticNpc_Serializer, taskid)
end

SerializerHelper.GmRecordAgentBowlingScore_Serializer = function(writer, gadgetuid, npcid, throwindex, score)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, throwindex, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmRecordAgentBowlingScore = function(self, gadgetuid, npcid, throwindex, score)
	return self.Invoke(self, 69401558, SerializerHelper.GmRecordAgentBowlingScore_Serializer, gadgetuid, npcid, throwindex, score)
end

SerializerHelper.GmDumpNavLayerState_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmDumpNavLayerState = function(self)
	return self.Invoke(self, 69404376, SerializerHelper.GmDumpNavLayerState_Serializer)
end

SerializerHelper.GmRefreshAllDestructibles_Serializer = function(writer, distance)
	SerializeBase.WritePrimitive(writer, distance, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmRefreshAllDestructibles = function(self, distance)
	return self.Invoke(self, 69405892, SerializerHelper.GmRefreshAllDestructibles_Serializer, distance)
end

SerializerHelper.GmAgentLookAt_Serializer = function(writer, agentid, targetunitid, lookatiktype, ikpriority, duration, iskeep)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetunitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, lookatiktype, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, ikpriority, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, duration, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, iskeep, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmAgentLookAt = function(self, agentid, targetunitid, lookatiktype, ikpriority, duration, iskeep)
	return self.Invoke(self, 69407059, SerializerHelper.GmAgentLookAt_Serializer, agentid, targetunitid, lookatiktype, ikpriority, duration, iskeep)
end

SerializerHelper.GmExtractionShooterShiftContainerItemToSlot_Serializer = function(writer, containerinstanceid, fromcellx, fromcelly, slotgroupbagconfigid, toslotindex)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, fromcellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromcelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, slotgroupbagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, toslotindex, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmExtractionShooterShiftContainerItemToSlot = function(self, containerinstanceid, fromcellx, fromcelly, slotgroupbagconfigid, toslotindex)
	return self.Invoke(self, 69410242, SerializerHelper.GmExtractionShooterShiftContainerItemToSlot_Serializer, containerinstanceid, fromcellx, fromcelly, slotgroupbagconfigid, toslotindex)
end

SerializerHelper.AskCreateAetherBus_Serializer = function(writer, id, create)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, create, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.AskCreateAetherBus = function(self, id, create)
	return self.Invoke(self, 69413298, SerializerHelper.AskCreateAetherBus_Serializer, id, create)
end

SerializerHelper.GmAetherCreatePed_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmAetherCreatePed = function(self)
	return self.Invoke(self, 69415603, SerializerHelper.GmAetherCreatePed_Serializer)
end

SerializerHelper.GmAetherKillAllCrowd_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmAetherKillAllCrowd = function(self)
	return self.Invoke(self, 69424922, SerializerHelper.GmAetherKillAllCrowd_Serializer)
end

SerializerHelper.GmBusCreateBeforeStop_Serializer = function(writer, stopid, lineid, distancebefore)
	SerializeBase.WritePrimitive(writer, stopid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, lineid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, distancebefore, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmBusCreateBeforeStop = function(self, stopid, lineid, distancebefore)
	return self.Invoke(self, 69428679, SerializerHelper.GmBusCreateBeforeStop_Serializer, stopid, lineid, distancebefore)
end

SerializerHelper.GmSpawnVehicle_Serializer = function(writer, templateid, position, facing, suitid, loadownvehicle, spoonname)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, suitid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, loadownvehicle, writer.WriteBoolean, false)
	writer.WriteString(writer, spoonname, false, "GmSpawnVehicle.spoonName", 0)
end

ClientToGameSceneGMDelegate.GmSpawnVehicle = function(self, templateid, position, facing, suitid, loadownvehicle, spoonname)
	return self.Invoke(self, 69430883, SerializerHelper.GmSpawnVehicle_Serializer, templateid, position, facing, suitid, loadownvehicle, spoonname)
end

SerializerHelper.GmRequestTieChineseChess_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmRequestTieChineseChess = function(self, gadgetuid)
	return self.Invoke(self, 69434409, SerializerHelper.GmRequestTieChineseChess_Serializer, gadgetuid)
end

SerializerHelper.GmAetherChangeAreaDensity_Serializer = function(writer, density, radius)
	SerializeBase.WritePrimitive(writer, density, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, radius, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmAetherChangeAreaDensity = function(self, density, radius)
	return self.Invoke(self, 69435880, SerializerHelper.GmAetherChangeAreaDensity_Serializer, density, radius)
end

SerializerHelper.GmOutOfStuck_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmOutOfStuck = function(self)
	return self.Invoke(self, 69437160, SerializerHelper.GmOutOfStuck_Serializer)
end

SerializerHelper.GmQueryServerNavMeshDebug_Serializer = function(writer, centerx, centery, centerz, range)
	SerializeBase.WritePrimitive(writer, centerx, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, centery, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, centerz, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, range, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmQueryServerNavMeshDebug = function(self, centerx, centery, centerz, range)
	return self.Invoke(self, 69437237, SerializerHelper.GmQueryServerNavMeshDebug_Serializer, centerx, centery, centerz, range)
end

SerializerHelper.GmChangeSectorControl_Serializer = function(writer, sectorcontrolid, enable)
	SerializeBase.WritePrimitive(writer, sectorcontrolid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmChangeSectorControl = function(self, sectorcontrolid, enable)
	return self.Invoke(self, 69438154, SerializerHelper.GmChangeSectorControl_Serializer, sectorcontrolid, enable)
end

SerializerHelper.GmRemoveVehicleBuff_Serializer = function(writer, entityid, buffid1, buffid2, buffid3)
	SerializeBase.WritePrimitive(writer, entityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, buffid1, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, buffid2, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, buffid3, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmRemoveVehicleBuff = function(self, entityid, buffid1, buffid2, buffid3)
	return self.Invoke(self, 69439682, SerializerHelper.GmRemoveVehicleBuff_Serializer, entityid, buffid1, buffid2, buffid3)
end

SerializerHelper.GmUseEnemyStrategy_Serializer = function(writer, enemyid, skillid, checkcd, checknav, checknoskilltime, servercast, clientasdatasource, triggercd)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, checkcd, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, checknav, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, checknoskilltime, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, servercast, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, clientasdatasource, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, triggercd, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmUseEnemyStrategy = function(self, enemyid, skillid, checkcd, checknav, checknoskilltime, servercast, clientasdatasource, triggercd)
	return self.Invoke(self, 69441224, SerializerHelper.GmUseEnemyStrategy_Serializer, enemyid, skillid, checkcd, checknav, checknoskilltime, servercast, clientasdatasource, triggercd)
end

SerializerHelper.GmAgentCheckPointPathMove_Serializer = function(writer, agentid, waypointsjson, movemethod)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	writer.WriteString(writer, waypointsjson, false, "GmAgentCheckPointPathMove.waypointsJson", 0)
	SerializeBase.WritePrimitive(writer, movemethod, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmAgentCheckPointPathMove = function(self, agentid, waypointsjson, movemethod)
	return self.Invoke(self, 69441998, SerializerHelper.GmAgentCheckPointPathMove_Serializer, agentid, waypointsjson, movemethod)
end

SerializerHelper.GmReplyTieChineseChess_Serializer = function(writer, gadgetuid, agree)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agree, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmReplyTieChineseChess = function(self, gadgetuid, agree)
	return self.Invoke(self, 69450280, SerializerHelper.GmReplyTieChineseChess_Serializer, gadgetuid, agree)
end

SerializerHelper.GmTriggerAllSpoonDangerZones_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmTriggerAllSpoonDangerZones = function(self)
	return self.Invoke(self, 69455984, SerializerHelper.GmTriggerAllSpoonDangerZones_Serializer)
end

SerializerHelper.GMGrantAllDiceBadges_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GMGrantAllDiceBadges = function(self)
	return self.Invoke(self, 69471868, SerializerHelper.GMGrantAllDiceBadges_Serializer)
end

SerializerHelper.GmEnableOxygenSystem_Serializer = function(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmEnableOxygenSystem = function(self, enable)
	return self.Invoke(self, 69472774, SerializerHelper.GmEnableOxygenSystem_Serializer, enable)
end

SerializerHelper.GmRefreshPublicEvent_Serializer = function(writer, eventid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmRefreshPublicEvent = function(self, eventid)
	return self.Invoke(self, 69474350, SerializerHelper.GmRefreshPublicEvent_Serializer, eventid)
end

SerializerHelper.GmPidSetHp_Serializer = function(writer, pid, percent)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, percent, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmPidSetHp = function(self, pid, percent)
	return self.Invoke(self, 69474626, SerializerHelper.GmPidSetHp_Serializer, pid, percent)
end

SerializerHelper.GmClearTempSpirits_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmClearTempSpirits = function(self)
	return self.Invoke(self, 69476139, SerializerHelper.GmClearTempSpirits_Serializer)
end

SerializerHelper.GmFinishRacingBefore_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmFinishRacingBefore = function(self)
	return self.Invoke(self, 69477587, SerializerHelper.GmFinishRacingBefore_Serializer)
end

SerializerHelper.GmRequestUndoChineseChess_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmRequestUndoChineseChess = function(self, gadgetuid)
	return self.Invoke(self, 69484098, SerializerHelper.GmRequestUndoChineseChess_Serializer, gadgetuid)
end

SerializerHelper.GmAddCompanion_Serializer = function(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAddCompanion = function(self, agentid)
	return self.Invoke(self, 69484258, SerializerHelper.GmAddCompanion_Serializer, agentid)
end

SerializerHelper.GmTeleportToPlayer_Serializer = function(writer, pid, allrobot)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, allrobot, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmTeleportToPlayer = function(self, pid, allrobot)
	return self.Invoke(self, 69485406, SerializerHelper.GmTeleportToPlayer_Serializer, pid, allrobot)
end

SerializerHelper.GmGoToNextFrame_Serializer = function(writer, time)
	SerializeBase.WritePrimitive(writer, time, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmGoToNextFrame = function(self, time)
	return self.Invoke(self, 69487023, SerializerHelper.GmGoToNextFrame_Serializer, time)
end

SerializerHelper.GmRefreshCrimes_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmRefreshCrimes = function(self)
	return self.Invoke(self, 69488600, SerializerHelper.GmRefreshCrimes_Serializer)
end

SerializerHelper.GmExitUgcRacing_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmExitUgcRacing = function(self)
	return self.Invoke(self, 69489064, SerializerHelper.GmExitUgcRacing_Serializer)
end

SerializerHelper.GmAgentCompanionAIReactionEvent_Serializer = function(writer, instanceid, eventid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAgentCompanionAIReactionEvent = function(self, instanceid, eventid)
	return self.Invoke(self, 69490327, SerializerHelper.GmAgentCompanionAIReactionEvent_Serializer, instanceid, eventid)
end

SerializerHelper.GmRefreshAllGadget_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmRefreshAllGadget = function(self)
	return self.Invoke(self, 69491085, SerializerHelper.GmRefreshAllGadget_Serializer)
end

SerializerHelper.GmChangeAetherVehicleDensity_Serializer = function(writer, ratio, forcerefresh)
	SerializeBase.WritePrimitive(writer, ratio, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, forcerefresh, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmChangeAetherVehicleDensity = function(self, ratio, forcerefresh)
	return self.Invoke(self, 69493525, SerializerHelper.GmChangeAetherVehicleDensity_Serializer, ratio, forcerefresh)
end

SerializerHelper.GmResetTempCamp_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmResetTempCamp = function(self, pid)
	return self.Invoke(self, 69513265, SerializerHelper.GmResetTempCamp_Serializer, pid)
end

SerializerHelper.GmRemoveBehaviorBreakPoint_Serializer = function(writer, type, treename, id)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	writer.WriteString(writer, treename, false, "GmRemoveBehaviorBreakPoint.treeName", 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmRemoveBehaviorBreakPoint = function(self, type, treename, id)
	return self.Invoke(self, 69514419, SerializerHelper.GmRemoveBehaviorBreakPoint_Serializer, type, treename, id)
end

SerializerHelper.GmEnterChineseChessZoneDoubleAI_Serializer = function(writer, gadgetuid, agentid, useredpiece, difficulty)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, useredpiece, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, difficulty, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmEnterChineseChessZoneDoubleAI = function(self, gadgetuid, agentid, useredpiece, difficulty)
	return self.Invoke(self, 69528345, SerializerHelper.GmEnterChineseChessZoneDoubleAI_Serializer, gadgetuid, agentid, useredpiece, difficulty)
end

SerializerHelper.GmExtractionShooterShiftContainerItemToBag_Serializer = function(writer, containerinstanceid, fromcellx, fromcelly, bagconfigid, tocellx, tocelly, isrotated)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, fromcellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromcelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tocellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tocelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isrotated, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmExtractionShooterShiftContainerItemToBag = function(self, containerinstanceid, fromcellx, fromcelly, bagconfigid, tocellx, tocelly, isrotated)
	return self.Invoke(self, 69542216, SerializerHelper.GmExtractionShooterShiftContainerItemToBag_Serializer, containerinstanceid, fromcellx, fromcelly, bagconfigid, tocellx, tocelly, isrotated)
end

SerializerHelper.GmAetherRecoverAllCrowd_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmAetherRecoverAllCrowd = function(self)
	return self.Invoke(self, 69543448, SerializerHelper.GmAetherRecoverAllCrowd_Serializer)
end

SerializerHelper.GmGetScenePlayerCount_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmGetScenePlayerCount = function(self)
	return self.Invoke(self, 69544017, SerializerHelper.GmGetScenePlayerCount_Serializer)
end

SerializerHelper.GmStartAIDebug_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmStartAIDebug = function(self)
	return self.Invoke(self, 69545379, SerializerHelper.GmStartAIDebug_Serializer)
end

SerializerHelper.GmEnableRandomEvent_Serializer = function(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmEnableRandomEvent = function(self, enable)
	return self.Invoke(self, 69547090, SerializerHelper.GmEnableRandomEvent_Serializer, enable)
end

SerializerHelper.GmSetBasicAttr_Serializer = function(writer, attr, value)
	SerializeBase.WritePrimitive(writer, attr, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmSetBasicAttr = function(self, attr, value)
	return self.Invoke(self, 69552994, SerializerHelper.GmSetBasicAttr_Serializer, attr, value)
end

SerializerHelper.GmBusCreateAtStart_Serializer = function(writer, lineid)
	SerializeBase.WritePrimitive(writer, lineid, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmBusCreateAtStart = function(self, lineid)
	return self.Invoke(self, 69558577, SerializerHelper.GmBusCreateAtStart_Serializer, lineid)
end

SerializerHelper.GmRegenerateWildEnemy_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmRegenerateWildEnemy = function(self)
	return self.Invoke(self, 69561826, SerializerHelper.GmRegenerateWildEnemy_Serializer)
end

SerializerHelper.GmLeaveGomoku_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmLeaveGomoku = function(self, gadgetuid)
	return self.Invoke(self, 69562546, SerializerHelper.GmLeaveGomoku_Serializer, gadgetuid)
end

SerializerHelper.GmAetherChangeVehicleDynamicAOI_Serializer = function(writer, aoirange, maxaoirange, aoifactor)
	SerializeBase.WritePrimitive(writer, aoirange, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, maxaoirange, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, aoifactor, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmAetherChangeVehicleDynamicAOI = function(self, aoirange, maxaoirange, aoifactor)
	return self.Invoke(self, 69570820, SerializerHelper.GmAetherChangeVehicleDynamicAOI_Serializer, aoirange, maxaoirange, aoifactor)
end

SerializerHelper.CheckPlayerPosition_Serializer = function(writer, position, moveid)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, moveid, writer.WriteByte, 0)
end

ClientToGameSceneGMDelegate.CheckPlayerPosition = function(self, position, moveid)
	return self.Invoke(self, 69574222, SerializerHelper.CheckPlayerPosition_Serializer, position, moveid)
end

SerializerHelper.GmAskInterruptAgentStoryBTree_Serializer = function(writer, agentid, isinterrupt)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, isinterrupt, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmAskInterruptAgentStoryBTree = function(self, agentid, isinterrupt)
	return self.Invoke(self, 69577337, SerializerHelper.GmAskInterruptAgentStoryBTree_Serializer, agentid, isinterrupt)
end

SerializerHelper.GmCreateGadget_Serializer = function(writer, instanceid, pos, facing, graphid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
	SerializeBase.WriteStruct(writer, facing, SerializeAuto.WriteUXVector3, "facing")
	SerializeBase.WritePrimitive(writer, graphid, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmCreateGadget = function(self, instanceid, pos, facing, graphid)
	return self.Invoke(self, 69578959, SerializerHelper.GmCreateGadget_Serializer, instanceid, pos, facing, graphid)
end

SerializerHelper.GmOpenDebugPosition_Serializer = function(writer, value)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmOpenDebugPosition = function(self, value)
	return self.Invoke(self, 69580655, SerializerHelper.GmOpenDebugPosition_Serializer, value)
end

SerializerHelper.GmEnterGomokuZoneEndGame_Serializer = function(writer, gadgetuid, agentid, endgameid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, endgameid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmEnterGomokuZoneEndGame = function(self, gadgetuid, agentid, endgameid)
	return self.Invoke(self, 69582210, SerializerHelper.GmEnterGomokuZoneEndGame_Serializer, gadgetuid, agentid, endgameid)
end

SerializerHelper.GmAetherRefreshNpc_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmAetherRefreshNpc = function(self)
	return self.Invoke(self, 69587256, SerializerHelper.GmAetherRefreshNpc_Serializer)
end

SerializerHelper.GmAddAgentGameplayTag_Serializer = function(writer, agentid, gameplaytagcfgid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, gameplaytagcfgid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAddAgentGameplayTag = function(self, agentid, gameplaytagcfgid)
	return self.Invoke(self, 69588696, SerializerHelper.GmAddAgentGameplayTag_Serializer, agentid, gameplaytagcfgid)
end

SerializerHelper.GmForceSetSwitchSpiritConfig_Serializer = function(writer, switchspiritconfigid)
	SerializeBase.WritePrimitive(writer, switchspiritconfigid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmForceSetSwitchSpiritConfig = function(self, switchspiritconfigid)
	return self.Invoke(self, 69589696, SerializerHelper.GmForceSetSwitchSpiritConfig_Serializer, switchspiritconfigid)
end

SerializerHelper.GmAllSwitchToNpc_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmAllSwitchToNpc = function(self)
	return self.Invoke(self, 69594087, SerializerHelper.GmAllSwitchToNpc_Serializer)
end

SerializerHelper.AskDebugAetherVehicleUpdatePosition_Serializer = function(writer, debugraidvehicle, debugaethervehicle)
	SerializeBase.WritePrimitive(writer, debugraidvehicle, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, debugaethervehicle, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.AskDebugAetherVehicleUpdatePosition = function(self, debugraidvehicle, debugaethervehicle)
	return self.Invoke(self, 69594162, SerializerHelper.AskDebugAetherVehicleUpdatePosition_Serializer, debugraidvehicle, debugaethervehicle)
end

SerializerHelper.GmAddBasketBallNpc_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmAddBasketBallNpc = function(self)
	return self.Invoke(self, 69594389, SerializerHelper.GmAddBasketBallNpc_Serializer)
end

SerializerHelper.GmDebugAllDestructible_Serializer = function(writer, distance)
	SerializeBase.WritePrimitive(writer, distance, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmDebugAllDestructible = function(self, distance)
	return self.Invoke(self, 69594738, SerializerHelper.GmDebugAllDestructible_Serializer, distance)
end

SerializerHelper.GmEndEnemyDetectStateDebug_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmEndEnemyDetectStateDebug = function(self)
	return self.Invoke(self, 69597922, SerializerHelper.GmEndEnemyDetectStateDebug_Serializer)
end

SerializerHelper.GmStopFlyerVehicleGroup_Serializer = function(writer, groupid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmStopFlyerVehicleGroup = function(self, groupid)
	return self.Invoke(self, 69598816, SerializerHelper.GmStopFlyerVehicleGroup_Serializer, groupid)
end

SerializerHelper.SendCustomCommonDataClientToGameSceneGM_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

ClientToGameSceneGMDelegate.SendCustomCommonDataClientToGameSceneGM = function(self, data)
	return self.Invoke(self, 69608625, SerializerHelper.SendCustomCommonDataClientToGameSceneGM_Serializer, data)
end

SerializerHelper.GmDestroyYacht_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmDestroyYacht = function(self)
	return self.Invoke(self, 69608856, SerializerHelper.GmDestroyYacht_Serializer)
end

SerializerHelper.GmDeathPartySetPhaseTask_Serializer = function(writer, taskids)
	SerializeBase.WriteList7Bit(writer, taskids, writer.WriteUInt32, 0, "taskids", false, 0, nil)
end

ClientToGameSceneGMDelegate.GmDeathPartySetPhaseTask = function(self, taskids)
	return self.Invoke(self, 69610860, SerializerHelper.GmDeathPartySetPhaseTask_Serializer, taskids)
end

SerializerHelper.GmPrintfNowPosBoundInfo_Serializer = function(writer, op)
	SerializeBase.WritePrimitive(writer, op, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmPrintfNowPosBoundInfo = function(self, op)
	return self.Invoke(self, 69611180, SerializerHelper.GmPrintfNowPosBoundInfo_Serializer, op)
end

SerializerHelper.GmSetDebugInitializeUsages_Serializer = function(writer, usageid)
	SerializeBase.WritePrimitive(writer, usageid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmSetDebugInitializeUsages = function(self, usageid)
	return self.Invoke(self, 69615731, SerializerHelper.GmSetDebugInitializeUsages_Serializer, usageid)
end

SerializerHelper.GmChangeCustomVehicleIntervalRatio_Serializer = function(writer, ratio)
	SerializeBase.WritePrimitive(writer, ratio, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmChangeCustomVehicleIntervalRatio = function(self, ratio)
	return self.Invoke(self, 69615999, SerializerHelper.GmChangeCustomVehicleIntervalRatio_Serializer, ratio)
end

SerializerHelper.GmSpreadStealthFromAToB_Serializer = function(writer, ida, idb, value)
	SerializeBase.WritePrimitive(writer, ida, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, idb, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmSpreadStealthFromAToB = function(self, ida, idb, value)
	return self.Invoke(self, 69621231, SerializerHelper.GmSpreadStealthFromAToB_Serializer, ida, idb, value)
end

SerializerHelper.GmAddElement_Serializer = function(writer, id, element, value)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, element, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmAddElement = function(self, id, element, value)
	return self.Invoke(self, 69623498, SerializerHelper.GmAddElement_Serializer, id, element, value)
end

SerializerHelper.GMExtractionShooterSearchAllContainer_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GMExtractionShooterSearchAllContainer = function(self)
	return self.Invoke(self, 69625018, SerializerHelper.GMExtractionShooterSearchAllContainer_Serializer)
end

SerializerHelper.GmBuyFoods_Serializer = function(writer, restaurantid, companionnpcid, foodid)
	SerializeBase.WritePrimitive(writer, restaurantid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, companionnpcid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, foodid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmBuyFoods = function(self, restaurantid, companionnpcid, foodid)
	return self.Invoke(self, 69626482, SerializerHelper.GmBuyFoods_Serializer, restaurantid, companionnpcid, foodid)
end

SerializerHelper.GmRemoveSpoonNpc_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmRemoveSpoonNpc = function(self, id)
	return self.Invoke(self, 69633894, SerializerHelper.GmRemoveSpoonNpc_Serializer, id)
end

SerializerHelper.GmQueryBattleStatisticsData_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmQueryBattleStatisticsData = function(self)
	return self.Invoke(self, 69633950, SerializerHelper.GmQueryBattleStatisticsData_Serializer)
end

SerializerHelper.GmGenMassNpcIds_Serializer = function(writer, count)
	SerializeBase.WritePrimitive(writer, count, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmGenMassNpcIds = function(self, count)
	return self.Invoke(self, 69634350, SerializerHelper.GmGenMassNpcIds_Serializer, count)
end

SerializerHelper.GmExtractionShooterShiftSlotItemToContainer_Serializer = function(writer, slotgroupbagconfigid, fromslotindex, containerinstanceid, tocellx, tocelly, isrotated)
	SerializeBase.WritePrimitive(writer, slotgroupbagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromslotindex, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, tocellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tocelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isrotated, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmExtractionShooterShiftSlotItemToContainer = function(self, slotgroupbagconfigid, fromslotindex, containerinstanceid, tocellx, tocelly, isrotated)
	return self.Invoke(self, 69635593, SerializerHelper.GmExtractionShooterShiftSlotItemToContainer_Serializer, slotgroupbagconfigid, fromslotindex, containerinstanceid, tocellx, tocelly, isrotated)
end

SerializerHelper.GmTeleportToRacingCheckPoint_Serializer = function(writer, lap, checkpointindex)
	SerializeBase.WritePrimitive(writer, lap, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, checkpointindex, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmTeleportToRacingCheckPoint = function(self, lap, checkpointindex)
	return self.Invoke(self, 69636174, SerializerHelper.GmTeleportToRacingCheckPoint_Serializer, lap, checkpointindex)
end

SerializerHelper.GmDeathPartyForbidEliminatePlayer_Serializer = function(writer, isforbid)
	SerializeBase.WritePrimitive(writer, isforbid, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmDeathPartyForbidEliminatePlayer = function(self, isforbid)
	return self.Invoke(self, 69636267, SerializerHelper.GmDeathPartyForbidEliminatePlayer_Serializer, isforbid)
end

SerializerHelper.GmAddCreation_Serializer = function(writer, creationid, releaser, x, y, z, time)
	SerializeBase.WritePrimitive(writer, creationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, releaser, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, x, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, y, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, z, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, time, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmAddCreation = function(self, creationid, releaser, x, y, z, time)
	return self.Invoke(self, 69648023, SerializerHelper.GmAddCreation_Serializer, creationid, releaser, x, y, z, time)
end

SerializerHelper.GmSetPvpGroupId_Serializer = function(writer, groupid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmSetPvpGroupId = function(self, groupid)
	return self.Invoke(self, 69650770, SerializerHelper.GmSetPvpGroupId_Serializer, groupid)
end

SerializerHelper.GmRecoverPlayerAllSkillCharge_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmRecoverPlayerAllSkillCharge = function(self)
	return self.Invoke(self, 69651383, SerializerHelper.GmRecoverPlayerAllSkillCharge_Serializer)
end

SerializerHelper.GmAgentStartVaultableMove_Serializer = function(writer, agentid, targetpos)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, targetpos, SerializeAuto.WriteUXVector3, "targetpos")
end

ClientToGameSceneGMDelegate.GmAgentStartVaultableMove = function(self, agentid, targetpos)
	return self.Invoke(self, 69655591, SerializerHelper.GmAgentStartVaultableMove_Serializer, agentid, targetpos)
end

SerializerHelper.TestUpdateDaShenLogToken_Serializer = function(writer, logtoken)
	writer.WriteString(writer, logtoken, false, "TestUpdateDaShenLogToken.logToken", 0)
end

ClientToGameSceneGMDelegate.TestUpdateDaShenLogToken = function(self, logtoken)
	return self.Invoke(self, 69661567, SerializerHelper.TestUpdateDaShenLogToken_Serializer, logtoken)
end

SerializerHelper.GmTogglePlayerStoryDebug_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmTogglePlayerStoryDebug = function(self)
	return self.Invoke(self, 69664463, SerializerHelper.GmTogglePlayerStoryDebug_Serializer)
end

SerializerHelper.GmKillNearestGadget_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmKillNearestGadget = function(self)
	return self.Invoke(self, 69666338, SerializerHelper.GmKillNearestGadget_Serializer)
end

SerializerHelper.GmSetNavTileVersion_Serializer = function(writer, surfaceid, agenttype, x, z, tileversion)
	SerializeBase.WritePrimitive(writer, surfaceid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, agenttype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, x, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, z, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, tileversion, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmSetNavTileVersion = function(self, surfaceid, agenttype, x, z, tileversion)
	return self.Invoke(self, 69668600, SerializerHelper.GmSetNavTileVersion_Serializer, surfaceid, agenttype, x, z, tileversion)
end

SerializerHelper.GmAddBot_Serializer = function(writer, enemyid, perceptionid, camp)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, perceptionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, camp, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAddBot = function(self, enemyid, perceptionid, camp)
	return self.Invoke(self, 69669051, SerializerHelper.GmAddBot_Serializer, enemyid, perceptionid, camp)
end

SerializerHelper.GmSetLinkDuty_Serializer = function(writer, dutyid)
	SerializeBase.WritePrimitive(writer, dutyid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmSetLinkDuty = function(self, dutyid)
	return self.Invoke(self, 69669177, SerializerHelper.GmSetLinkDuty_Serializer, dutyid)
end

SerializerHelper.GMSetAIAgentInfo_Serializer = function(writer, spiritid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GMSetAIAgentInfo = function(self, spiritid)
	return self.Invoke(self, 69673301, SerializerHelper.GMSetAIAgentInfo_Serializer, spiritid)
end

SerializerHelper.GmWorldRefreshEnemyGroup_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmWorldRefreshEnemyGroup = function(self)
	return self.Invoke(self, 69676618, SerializerHelper.GmWorldRefreshEnemyGroup_Serializer)
end

SerializerHelper.GmUseSkill_Serializer = function(writer, location, facing, targetid, unitpartindex, targetdestructibleid, skillid, skillinstanceid)
	SerializeBase.WriteStruct(writer, location, SerializeAuto.WriteUXVector3, "location")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, unitpartindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, targetdestructibleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, skillinstanceid, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmUseSkill = function(self, location, facing, targetid, unitpartindex, targetdestructibleid, skillid, skillinstanceid)
	return self.Invoke(self, 69680808, SerializerHelper.GmUseSkill_Serializer, location, facing, targetid, unitpartindex, targetdestructibleid, skillid, skillinstanceid)
end

SerializerHelper.GmStartAvoidDanger_Serializer = function(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmStartAvoidDanger = function(self, agentid)
	return self.Invoke(self, 69680937, SerializerHelper.GmStartAvoidDanger_Serializer, agentid)
end

SerializerHelper.GmCreateToilet_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmCreateToilet = function(self)
	return self.Invoke(self, 69686776, SerializerHelper.GmCreateToilet_Serializer)
end

SerializerHelper.GmChangeAgentWeapon_Serializer = function(writer, agentid, weaponid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, weaponid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmChangeAgentWeapon = function(self, agentid, weaponid)
	return self.Invoke(self, 69686917, SerializerHelper.GmChangeAgentWeapon_Serializer, agentid, weaponid)
end

SerializerHelper.GmBusToggleOnlyBus_Serializer = function(writer, enabled)
	SerializeBase.WritePrimitive(writer, enabled, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmBusToggleOnlyBus = function(self, enabled)
	return self.Invoke(self, 69688494, SerializerHelper.GmBusToggleOnlyBus_Serializer, enabled)
end

SerializerHelper.SyncStoryCoreClientDebugInfo_Serializer = function(writer, info)
	writer.WriteString(writer, info, false, "SyncStoryCoreClientDebugInfo.info", 0)
end

ClientToGameSceneGMDelegate.SyncStoryCoreClientDebugInfo = function(self, info)
	return self.Invoke(self, 69691069, SerializerHelper.SyncStoryCoreClientDebugInfo_Serializer, info)
end

SerializerHelper.GmAgentDoPoiAction_Serializer = function(writer, agentid, poiactioncfgid, duration)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, poiactioncfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, duration, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmAgentDoPoiAction = function(self, agentid, poiactioncfgid, duration)
	return self.Invoke(self, 69698678, SerializerHelper.GmAgentDoPoiAction_Serializer, agentid, poiactioncfgid, duration)
end

SerializerHelper.GmTriggerECSEvent_Serializer = function(writer, eventid, agentid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmTriggerECSEvent = function(self, eventid, agentid)
	return self.Invoke(self, 69699207, SerializerHelper.GmTriggerECSEvent_Serializer, eventid, agentid)
end

SerializerHelper.GmSetEmotion_Serializer = function(writer, agentid, emotion, value)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, emotion, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmSetEmotion = function(self, agentid, emotion, value)
	return self.Invoke(self, 69701895, SerializerHelper.GmSetEmotion_Serializer, agentid, emotion, value)
end

SerializerHelper.GmEnableThreatDebug_Serializer = function(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmEnableThreatDebug = function(self, enable)
	return self.Invoke(self, 69702004, SerializerHelper.GmEnableThreatDebug_Serializer, enable)
end

SerializerHelper.GmRemoveBuff_Serializer = function(writer, buffid, targetid, releaserid)
	SerializeBase.WritePrimitive(writer, buffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, releaserid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmRemoveBuff = function(self, buffid, targetid, releaserid)
	return self.Invoke(self, 69704292, SerializerHelper.GmRemoveBuff_Serializer, buffid, targetid, releaserid)
end

SerializerHelper.GmSetAgentBuffEffectSuppress_Serializer = function(writer, agentid, issuppress)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, issuppress, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmSetAgentBuffEffectSuppress = function(self, agentid, issuppress)
	return self.Invoke(self, 69705754, SerializerHelper.GmSetAgentBuffEffectSuppress_Serializer, agentid, issuppress)
end

SerializerHelper.GmAgentFocusOn_Serializer = function(writer, agentid, targetunitid, tolerance)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetunitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, tolerance, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmAgentFocusOn = function(self, agentid, targetunitid, tolerance)
	return self.Invoke(self, 69722148, SerializerHelper.GmAgentFocusOn_Serializer, agentid, targetunitid, tolerance)
end

SerializerHelper.GmStartDart_Serializer = function(writer, gadgetuid, gametype, random)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(gametype, 95, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, random, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmStartDart = function(self, gadgetuid, gametype, random)
	return self.Invoke(self, 69725095, SerializerHelper.GmStartDart_Serializer, gadgetuid, gametype, random)
end

SerializerHelper.GmAddCreation2_Serializer = function(writer, creationid)
	SerializeBase.WritePrimitive(writer, creationid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAddCreation2 = function(self, creationid)
	return self.Invoke(self, 69725627, SerializerHelper.GmAddCreation2_Serializer, creationid)
end

SerializerHelper.GmHackVehicle_Serializer = function(writer, vehicleid, actiontype)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(actiontype, 61, 0), writer.WriteByte, 0)
end

ClientToGameSceneGMDelegate.GmHackVehicle = function(self, vehicleid, actiontype)
	return self.Invoke(self, 69728189, SerializerHelper.GmHackVehicle_Serializer, vehicleid, actiontype)
end

SerializerHelper.GmSetNavActiveVersionChain_Serializer = function(writer, chain)
	writer.WriteString(writer, chain, false, "GmSetNavActiveVersionChain.chain", 0)
end

ClientToGameSceneGMDelegate.GmSetNavActiveVersionChain = function(self, chain)
	return self.Invoke(self, 69728537, SerializerHelper.GmSetNavActiveVersionChain_Serializer, chain)
end

SerializerHelper.GmDestroyVehicle_Serializer = function(writer, vehicleid)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmDestroyVehicle = function(self, vehicleid)
	return self.Invoke(self, 69730145, SerializerHelper.GmDestroyVehicle_Serializer, vehicleid)
end

SerializerHelper.GmAgentWayPointMove_Serializer = function(writer, agentid, waypointsjson, movemethod)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	writer.WriteString(writer, waypointsjson, false, "GmAgentWayPointMove.waypointsJson", 0)
	SerializeBase.WritePrimitive(writer, movemethod, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmAgentWayPointMove = function(self, agentid, waypointsjson, movemethod)
	return self.Invoke(self, 69731785, SerializerHelper.GmAgentWayPointMove_Serializer, agentid, waypointsjson, movemethod)
end

SerializerHelper.GmSimulateRingTossReconnect_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmSimulateRingTossReconnect = function(self, gadgetuid)
	return self.Invoke(self, 69736245, SerializerHelper.GmSimulateRingTossReconnect_Serializer, gadgetuid)
end

SerializerHelper.GmPlaceGomokuPiece_Serializer = function(writer, gadgetuid, x, y)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, x, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, y, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmPlaceGomokuPiece = function(self, gadgetuid, x, y)
	return self.Invoke(self, 69748971, SerializerHelper.GmPlaceGomokuPiece_Serializer, gadgetuid, x, y)
end

SerializerHelper.GmSpawnDistinctedEventAgent_Serializer = function(writer, eventid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmSpawnDistinctedEventAgent = function(self, eventid)
	return self.Invoke(self, 69755488, SerializerHelper.GmSpawnDistinctedEventAgent_Serializer, eventid)
end

SerializerHelper.GmSetAgentBTParameter_Serializer = function(writer, agentid, btname, paramsjson)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	writer.WriteString(writer, btname, false, "GmSetAgentBTParameter.btName", 0)
	writer.WriteString(writer, paramsjson, false, "GmSetAgentBTParameter.paramsJson", 0)
end

ClientToGameSceneGMDelegate.GmSetAgentBTParameter = function(self, agentid, btname, paramsjson)
	return self.Invoke(self, 69756388, SerializerHelper.GmSetAgentBTParameter_Serializer, agentid, btname, paramsjson)
end

SerializerHelper.GmSwitchSpiritHere_Serializer = function(writer, spiritid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmSwitchSpiritHere = function(self, spiritid)
	return self.Invoke(self, 69758035, SerializerHelper.GmSwitchSpiritHere_Serializer, spiritid)
end

SerializerHelper.GmExtractionShooterEndSearchContainer_Serializer = function(writer, containerinstanceid)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmExtractionShooterEndSearchContainer = function(self, containerinstanceid)
	return self.Invoke(self, 69758066, SerializerHelper.GmExtractionShooterEndSearchContainer_Serializer, containerinstanceid)
end

SerializerHelper.GmLeaveRingTossZone_Serializer = function(writer, gadgetuid, abort)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, abort, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmLeaveRingTossZone = function(self, gadgetuid, abort)
	return self.Invoke(self, 69758955, SerializerHelper.GmLeaveRingTossZone_Serializer, gadgetuid, abort)
end

SerializerHelper.GmTeleportUnit_Serializer = function(writer, unitid, x, z)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, x, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, z, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmTeleportUnit = function(self, unitid, x, z)
	return self.Invoke(self, 69761184, SerializerHelper.GmTeleportUnit_Serializer, unitid, x, z)
end

SerializerHelper.GmEnterRingTossZone_Serializer = function(writer, gadgetuid, skipfeecheck)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skipfeecheck, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmEnterRingTossZone = function(self, gadgetuid, skipfeecheck)
	return self.Invoke(self, 69761367, SerializerHelper.GmEnterRingTossZone_Serializer, gadgetuid, skipfeecheck)
end

SerializerHelper.GmDeleteDMOverride_Serializer = function(writer, subjectagentid)
	SerializeBase.WritePrimitive(writer, subjectagentid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmDeleteDMOverride = function(self, subjectagentid)
	return self.Invoke(self, 69765001, SerializerHelper.GmDeleteDMOverride_Serializer, subjectagentid)
end

SerializerHelper.GmUseAISkill_Serializer = function(writer, skillid, targetid)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmUseAISkill = function(self, skillid, targetid)
	return self.Invoke(self, 69773789, SerializerHelper.GmUseAISkill_Serializer, skillid, targetid)
end

SerializerHelper.GmBusTeleportToStart_Serializer = function(writer, lineid)
	SerializeBase.WritePrimitive(writer, lineid, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmBusTeleportToStart = function(self, lineid)
	return self.Invoke(self, 69787493, SerializerHelper.GmBusTeleportToStart_Serializer, lineid)
end

SerializerHelper.GmAddEnemyWithPosition_Serializer = function(writer, enemyid, camp, position, navtagtype, outsideaoimove)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(camp, 92, 0), writer.WriteByte, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, navtagtype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, outsideaoimove, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmAddEnemyWithPosition = function(self, enemyid, camp, position, navtagtype, outsideaoimove)
	return self.Invoke(self, 69787740, SerializerHelper.GmAddEnemyWithPosition_Serializer, enemyid, camp, position, navtagtype, outsideaoimove)
end

SerializerHelper.GmQueryStaticNpcSpawnLog_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmQueryStaticNpcSpawnLog = function(self)
	return self.Invoke(self, 69790169, SerializerHelper.GmQueryStaticNpcSpawnLog_Serializer)
end

SerializerHelper.GmSetStealthValue_Serializer = function(writer, enemyid, value)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmSetStealthValue = function(self, enemyid, value)
	return self.Invoke(self, 69790485, SerializerHelper.GmSetStealthValue_Serializer, enemyid, value)
end

SerializerHelper.GmBlockPlayerStimSource_Serializer = function(writer, isblock)
	SerializeBase.WritePrimitive(writer, isblock, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmBlockPlayerStimSource = function(self, isblock)
	return self.Invoke(self, 69791362, SerializerHelper.GmBlockPlayerStimSource_Serializer, isblock)
end

SerializerHelper.GmSelectAllRandomEvent_Serializer = function(writer, flag)
	SerializeBase.WritePrimitive(writer, flag, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmSelectAllRandomEvent = function(self, flag)
	return self.Invoke(self, 69792702, SerializerHelper.GmSelectAllRandomEvent_Serializer, flag)
end

SerializerHelper.GmEndRingTossZone_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmEndRingTossZone = function(self, gadgetuid)
	return self.Invoke(self, 69793970, SerializerHelper.GmEndRingTossZone_Serializer, gadgetuid)
end

SerializerHelper.GmCancelAgentBehavior_Serializer = function(writer, agentid, priority)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, priority, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmCancelAgentBehavior = function(self, agentid, priority)
	return self.Invoke(self, 69798198, SerializerHelper.GmCancelAgentBehavior_Serializer, agentid, priority)
end

SerializerHelper.GmAgentTurn_Serializer = function(writer, agentid, targetx, targety, targetz, tolerance)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetx, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, targety, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, targetz, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, tolerance, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmAgentTurn = function(self, agentid, targetx, targety, targetz, tolerance)
	return self.Invoke(self, 69798917, SerializerHelper.GmAgentTurn_Serializer, agentid, targetx, targety, targetz, tolerance)
end

SerializerHelper.GmQueryLockTargetRadius_Serializer = function(writer, entity)
	SerializeBase.WritePrimitive(writer, entity, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmQueryLockTargetRadius = function(self, entity)
	return self.Invoke(self, 69800362, SerializerHelper.GmQueryLockTargetRadius_Serializer, entity)
end

SerializerHelper.GmAddWeapon_Serializer = function(writer, weaponid)
	SerializeBase.WritePrimitive(writer, weaponid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAddWeapon = function(self, weaponid)
	return self.Invoke(self, 69802168, SerializerHelper.GmAddWeapon_Serializer, weaponid)
end

SerializerHelper.GmAddOtherBuff_Serializer = function(writer, buffid, target, releaserid, time)
	SerializeBase.WritePrimitive(writer, buffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, target, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, releaserid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, time, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmAddOtherBuff = function(self, buffid, target, releaserid, time)
	return self.Invoke(self, 69805439, SerializerHelper.GmAddOtherBuff_Serializer, buffid, target, releaserid, time)
end

SerializerHelper.GmStartHackerAutonomousDriving_Serializer = function(writer, x, y, z)
	SerializeBase.WritePrimitive(writer, x, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, y, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, z, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmStartHackerAutonomousDriving = function(self, x, y, z)
	return self.Invoke(self, 69809057, SerializerHelper.GmStartHackerAutonomousDriving_Serializer, x, y, z)
end

SerializerHelper.GmSpawnAetherVehicle_Serializer = function(writer, vehicleconfigid, position, facing, npcid1, npcid2, npcid3, npcid4)
	SerializeBase.WritePrimitive(writer, vehicleconfigid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, npcid1, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npcid2, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npcid3, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npcid4, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmSpawnAetherVehicle = function(self, vehicleconfigid, position, facing, npcid1, npcid2, npcid3, npcid4)
	return self.Invoke(self, 69812849, SerializerHelper.GmSpawnAetherVehicle_Serializer, vehicleconfigid, position, facing, npcid1, npcid2, npcid3, npcid4)
end

SerializerHelper.GmRemoveUnitStateToOther_Serializer = function(writer, uid, state)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmRemoveUnitStateToOther = function(self, uid, state)
	return self.Invoke(self, 69820553, SerializerHelper.GmRemoveUnitStateToOther_Serializer, uid, state)
end

SerializerHelper.GmEndEnemyDetectDebug_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmEndEnemyDetectDebug = function(self)
	return self.Invoke(self, 69822545, SerializerHelper.GmEndEnemyDetectDebug_Serializer)
end

SerializerHelper.GmRemoveCreation_Serializer = function(writer, creations)
	SerializeBase.WriteList7Bit(writer, creations, writer.WriteUInt64, 0, "creations", true, 0, nil)
end

ClientToGameSceneGMDelegate.GmRemoveCreation = function(self, creations)
	return self.Invoke(self, 69824626, SerializerHelper.GmRemoveCreation_Serializer, creations)
end

SerializerHelper.GmSetDiceComplexValues_Serializer = function(writer, dicevalues)
	SerializeBase.WriteList7Bit(writer, dicevalues, writer.WriteInt32, 0, "dicevalues", false, 0, nil)
end

ClientToGameSceneGMDelegate.GmSetDiceComplexValues = function(self, dicevalues)
	return self.Invoke(self, 69827264, SerializerHelper.GmSetDiceComplexValues_Serializer, dicevalues)
end

SerializerHelper.GmEnemyAiStopFlagByCamp_Serializer = function(writer, isfriend, stopflag)
	SerializeBase.WritePrimitive(writer, isfriend, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, stopflag, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmEnemyAiStopFlagByCamp = function(self, isfriend, stopflag)
	return self.Invoke(self, 69827777, SerializerHelper.GmEnemyAiStopFlagByCamp_Serializer, isfriend, stopflag)
end

SerializerHelper.GmFreeSkill_Serializer = function(writer, isfree)
	SerializeBase.WritePrimitive(writer, isfree, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmFreeSkill = function(self, isfree)
	return self.Invoke(self, 69832285, SerializerHelper.GmFreeSkill_Serializer, isfree)
end

SerializerHelper.GmBlockSelfStim_Serializer = function(writer, isadd)
	SerializeBase.WritePrimitive(writer, isadd, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmBlockSelfStim = function(self, isadd)
	return self.Invoke(self, 69833494, SerializerHelper.GmBlockSelfStim_Serializer, isadd)
end

SerializerHelper.GmKillEnemy_Serializer = function(writer, enemyid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmKillEnemy = function(self, enemyid)
	return self.Invoke(self, 69834850, SerializerHelper.GmKillEnemy_Serializer, enemyid)
end

SerializerHelper.GmStartRaid_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmStartRaid = function(self)
	return self.Invoke(self, 69836681, SerializerHelper.GmStartRaid_Serializer)
end

SerializerHelper.GmCreateYacht_Serializer = function(writer, yachtcfgid)
	SerializeBase.WritePrimitive(writer, yachtcfgid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmCreateYacht = function(self, yachtcfgid)
	return self.Invoke(self, 69841467, SerializerHelper.GmCreateYacht_Serializer, yachtcfgid)
end

SerializerHelper.GmTeleportXYZWithDateNpc_Serializer = function(writer, x, y, z)
	SerializeBase.WritePrimitive(writer, x, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, y, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, z, writer.WriteSingle, 0)
end

ClientToGameSceneGMDelegate.GmTeleportXYZWithDateNpc = function(self, x, y, z)
	return self.Invoke(self, 69841676, SerializerHelper.GmTeleportXYZWithDateNpc_Serializer, x, y, z)
end

SerializerHelper.GmGetHashCodeInfo_Serializer = function(writer, uid, str)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
	writer.WriteString(writer, str, false, "GmGetHashCodeInfo.str", 0)
end

ClientToGameSceneGMDelegate.GmGetHashCodeInfo = function(self, uid, str)
	return self.Invoke(self, 69842643, SerializerHelper.GmGetHashCodeInfo_Serializer, uid, str)
end

SerializerHelper.GmRemoveOtherUnitState_Serializer = function(writer, templateid, state)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmRemoveOtherUnitState = function(self, templateid, state)
	return self.Invoke(self, 69843625, SerializerHelper.GmRemoveOtherUnitState_Serializer, templateid, state)
end

SerializerHelper.GmResumeAllEnemyAi_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmResumeAllEnemyAi = function(self)
	return self.Invoke(self, 69845201, SerializerHelper.GmResumeAllEnemyAi_Serializer)
end

SerializerHelper.GmUseGomokuSkill_Serializer = function(writer, gadgetuid, skillid, x, y)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, x, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, y, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmUseGomokuSkill = function(self, gadgetuid, skillid, x, y)
	return self.Invoke(self, 69846510, SerializerHelper.GmUseGomokuSkill_Serializer, gadgetuid, skillid, x, y)
end

SerializerHelper.GmUseSkillWithErrorCode_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillUseData, "data", false)
end

ClientToGameSceneGMDelegate.GmUseSkillWithErrorCode = function(self, data)
	return self.Invoke(self, 69848892, SerializerHelper.GmUseSkillWithErrorCode_Serializer, data)
end

SerializerHelper.GmDeathPartySetFirstTask_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmDeathPartySetFirstTask = function(self, taskid)
	return self.Invoke(self, 69853243, SerializerHelper.GmDeathPartySetFirstTask_Serializer, taskid)
end

SerializerHelper.GmSetWeaponDurability_Serializer = function(writer, durability)
	SerializeBase.WritePrimitive(writer, durability, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmSetWeaponDurability = function(self, durability)
	return self.Invoke(self, 69860858, SerializerHelper.GmSetWeaponDurability_Serializer, durability)
end

SerializerHelper.GmDaVinciCode_Serializer = function(writer, code)
	writer.WriteString(writer, code, false, "GmDaVinciCode.code", 0)
end

ClientToGameSceneGMDelegate.GmDaVinciCode = function(self, code)
	return self.Invoke(self, 69864720, SerializerHelper.GmDaVinciCode_Serializer, code)
end

SerializerHelper.GmAddPlate_Serializer = function(writer, graphid, position, rotation)
	SerializeBase.WritePrimitive(writer, graphid, writer.WriteInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WriteStruct(writer, rotation, SerializeAuto.WriteUXVector3, "rotation")
end

ClientToGameSceneGMDelegate.GmAddPlate = function(self, graphid, position, rotation)
	return self.Invoke(self, 69864773, SerializerHelper.GmAddPlate_Serializer, graphid, position, rotation)
end

SerializerHelper.GmSetUseForwardGroup_Serializer = function(writer, agentid, value)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmSetUseForwardGroup = function(self, agentid, value)
	return self.Invoke(self, 69867030, SerializerHelper.GmSetUseForwardGroup_Serializer, agentid, value)
end

SerializerHelper.GmAddNpc_Serializer = function(writer, npcid, plotid)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, plotid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAddNpc = function(self, npcid, plotid)
	return self.Invoke(self, 69871888, SerializerHelper.GmAddNpc_Serializer, npcid, plotid)
end

SerializerHelper.GmRecordBowlingScore_Serializer = function(writer, gadgetuid, throwindex, score)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, throwindex, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmRecordBowlingScore = function(self, gadgetuid, throwindex, score)
	return self.Invoke(self, 69872262, SerializerHelper.GmRecordBowlingScore_Serializer, gadgetuid, throwindex, score)
end

SerializerHelper.GmAddAgent_Serializer = function(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAddAgent = function(self, agentid)
	return self.Invoke(self, 69875939, SerializerHelper.GmAddAgent_Serializer, agentid)
end

SerializerHelper.GmAetherCreateCrowd_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteGmCreatePedData, "data", false)
end

ClientToGameSceneGMDelegate.GmAetherCreateCrowd = function(self, data)
	return self.Invoke(self, 69881630, SerializerHelper.GmAetherCreateCrowd_Serializer, data)
end

SerializerHelper.GmEnterGomokuZoneDoubleAI_Serializer = function(writer, gadgetuid, agentid, useblackpiece, difficulty, canuseskill)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, useblackpiece, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, difficulty, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, canuseskill, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmEnterGomokuZoneDoubleAI = function(self, gadgetuid, agentid, useblackpiece, difficulty, canuseskill)
	return self.Invoke(self, 69889134, SerializerHelper.GmEnterGomokuZoneDoubleAI_Serializer, gadgetuid, agentid, useblackpiece, difficulty, canuseskill)
end

SerializerHelper.GmSetBasketballForceResult_Serializer = function(writer, operatortype, forceresult)
	SerializeBase.WritePrimitive(writer, operatortype, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, forceresult, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmSetBasketballForceResult = function(self, operatortype, forceresult)
	return self.Invoke(self, 69895604, SerializerHelper.GmSetBasketballForceResult_Serializer, operatortype, forceresult)
end

SerializerHelper.GmSpawnAetherVehicleAtFront_Serializer = function(writer, vehicleconfigid, npcid1, npcid2, npcid3, npcid4)
	SerializeBase.WritePrimitive(writer, vehicleconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npcid1, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npcid2, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npcid3, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npcid4, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmSpawnAetherVehicleAtFront = function(self, vehicleconfigid, npcid1, npcid2, npcid3, npcid4)
	return self.Invoke(self, 69897522, SerializerHelper.GmSpawnAetherVehicleAtFront_Serializer, vehicleconfigid, npcid1, npcid2, npcid3, npcid4)
end

SerializerHelper.GmAetherOverrideDensityCurve_Serializer = function(writer, urbandiversityconfigid, keyframes, weathervariant)
	SerializeBase.WritePrimitive(writer, urbandiversityconfigid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, keyframes, SerializeBase.WriteStructWrap(SerializeAuto.WriteGmCurveKeyframe, "keyframes"), nil, "keyframes", false, 0, nil)
	SerializeBase.WritePrimitive(writer, weathervariant, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAetherOverrideDensityCurve = function(self, urbandiversityconfigid, keyframes, weathervariant)
	return self.Invoke(self, 69898133, SerializerHelper.GmAetherOverrideDensityCurve_Serializer, urbandiversityconfigid, keyframes, weathervariant)
end

SerializerHelper.GmAddBotPlayer_Serializer = function(writer, botid)
	SerializeBase.WritePrimitive(writer, botid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmAddBotPlayer = function(self, botid)
	return self.Invoke(self, 69899669, SerializerHelper.GmAddBotPlayer_Serializer, botid)
end

SerializerHelper.GmEnterChineseChessZoneDoublePlayer_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmEnterChineseChessZoneDoublePlayer = function(self, gadgetuid)
	return self.Invoke(self, 69907556, SerializerHelper.GmEnterChineseChessZoneDoublePlayer_Serializer, gadgetuid)
end

SerializerHelper.GmStopEnemyAiByCamp_Serializer = function(writer, camp)
	SerializeBase.WritePrimitive(writer, camp, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmStopEnemyAiByCamp = function(self, camp)
	return self.Invoke(self, 69909389, SerializerHelper.GmStopEnemyAiByCamp_Serializer, camp)
end

SerializerHelper.GmMarkAgentCompanionAI_Serializer = function(writer, instanceid, open)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, open, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmMarkAgentCompanionAI = function(self, instanceid, open)
	return self.Invoke(self, 69910678, SerializerHelper.GmMarkAgentCompanionAI_Serializer, instanceid, open)
end

SerializerHelper.GmFixFrame_Serializer = function(writer, value)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmFixFrame = function(self, value)
	return self.Invoke(self, 69919552, SerializerHelper.GmFixFrame_Serializer, value)
end

SerializerHelper.GmBusSetPaused_Serializer = function(writer, lineid, paused)
	SerializeBase.WritePrimitive(writer, lineid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, paused, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmBusSetPaused = function(self, lineid, paused)
	return self.Invoke(self, 69926047, SerializerHelper.GmBusSetPaused_Serializer, lineid, paused)
end

SerializerHelper.GmBusDestroyAll_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmBusDestroyAll = function(self)
	return self.Invoke(self, 69928288, SerializerHelper.GmBusDestroyAll_Serializer)
end

SerializerHelper.GmAddBehaviorBreakPoint_Serializer = function(writer, type, treename, id)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	writer.WriteString(writer, treename, false, "GmAddBehaviorBreakPoint.treeName", 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmAddBehaviorBreakPoint = function(self, type, treename, id)
	return self.Invoke(self, 69933218, SerializerHelper.GmAddBehaviorBreakPoint_Serializer, type, treename, id)
end

SerializerHelper.GmRemoveOtherUnitStateByInstance_Serializer = function(writer, instanceid, state)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmRemoveOtherUnitStateByInstance = function(self, instanceid, state)
	return self.Invoke(self, 69939475, SerializerHelper.GmRemoveOtherUnitStateByInstance_Serializer, instanceid, state)
end

SerializerHelper.GmSelectRandomEvent_Serializer = function(writer, eventid, taskid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmSelectRandomEvent = function(self, eventid, taskid)
	return self.Invoke(self, 69939893, SerializerHelper.GmSelectRandomEvent_Serializer, eventid, taskid)
end

SerializerHelper.GmStartPlotBehavior_Serializer = function(writer, agentid, name, procedure)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	writer.WriteString(writer, name, false, "GmStartPlotBehavior.name", 0)
	SerializeBase.WritePrimitive(writer, procedure, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmStartPlotBehavior = function(self, agentid, name, procedure)
	return self.Invoke(self, 69940408, SerializerHelper.GmStartPlotBehavior_Serializer, agentid, name, procedure)
end

SerializerHelper.GmSetTrustee_Serializer = function(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmSetTrustee = function(self, agentid)
	return self.Invoke(self, 69945063, SerializerHelper.GmSetTrustee_Serializer, agentid)
end

SerializerHelper.GmShowRoofPoint_Serializer = function(writer, show)
	SerializeBase.WritePrimitive(writer, show, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmShowRoofPoint = function(self, show)
	return self.Invoke(self, 69946568, SerializerHelper.GmShowRoofPoint_Serializer, show)
end

SerializerHelper.GmRemoveTaskStaticNpc_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmRemoveTaskStaticNpc = function(self, taskid)
	return self.Invoke(self, 69950817, SerializerHelper.GmRemoveTaskStaticNpc_Serializer, taskid)
end

SerializerHelper.GmStartEnemyGroupDebug_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmStartEnemyGroupDebug = function(self)
	return self.Invoke(self, 69953039, SerializerHelper.GmStartEnemyGroupDebug_Serializer)
end

SerializerHelper.GmWithdrawChineseChessMove_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmWithdrawChineseChessMove = function(self, gadgetuid)
	return self.Invoke(self, 69956317, SerializerHelper.GmWithdrawChineseChessMove_Serializer, gadgetuid)
end

SerializerHelper.GmClearAllBasketballForceResult_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmClearAllBasketballForceResult = function(self)
	return self.Invoke(self, 69957813, SerializerHelper.GmClearAllBasketballForceResult_Serializer)
end

SerializerHelper.GmNotifyDamageSimulationStart_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmNotifyDamageSimulationStart = function(self)
	return self.Invoke(self, 69958576, SerializerHelper.GmNotifyDamageSimulationStart_Serializer)
end

SerializerHelper.GmClientInviteOccupy_Serializer = function(writer, npccultivationid, gameplaytype, start)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, gameplaytype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, start, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmClientInviteOccupy = function(self, npccultivationid, gameplaytype, start)
	return self.Invoke(self, 69959170, SerializerHelper.GmClientInviteOccupy_Serializer, npccultivationid, gameplaytype, start)
end

SerializerHelper.GmTriggerPlotEvent_Serializer = function(writer, ploteventid)
	SerializeBase.WritePrimitive(writer, ploteventid, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmTriggerPlotEvent = function(self, ploteventid)
	return self.Invoke(self, 69959463, SerializerHelper.GmTriggerPlotEvent_Serializer, ploteventid)
end

SerializerHelper.GmFinishRacing_Serializer = function(writer, index, second)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, second, writer.WriteUInt32, 0)
end

ClientToGameSceneGMDelegate.GmFinishRacing = function(self, index, second)
	return self.Invoke(self, 69960337, SerializerHelper.GmFinishRacing_Serializer, index, second)
end

SerializerHelper.GmPrintStaticNpcPersonaError_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmPrintStaticNpcPersonaError = function(self)
	return self.Invoke(self, 69962481, SerializerHelper.GmPrintStaticNpcPersonaError_Serializer)
end

SerializerHelper.GmChangeWorldState_Serializer = function(writer, worldstateid, enable)
	SerializeBase.WritePrimitive(writer, worldstateid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmChangeWorldState = function(self, worldstateid, enable)
	return self.Invoke(self, 69966947, SerializerHelper.GmChangeWorldState_Serializer, worldstateid, enable)
end

SerializerHelper.GmStartEnemyStrategyDebug_Serializer = function(writer, enemyid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmStartEnemyStrategyDebug = function(self, enemyid)
	return self.Invoke(self, 69970596, SerializerHelper.GmStartEnemyStrategyDebug_Serializer, enemyid)
end

SerializerHelper.GmShiftVehicleSeat_Serializer = function(writer, toseatindex)
	SerializeBase.WritePrimitive(writer, toseatindex, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmShiftVehicleSeat = function(self, toseatindex)
	return self.Invoke(self, 69970642, SerializerHelper.GmShiftVehicleSeat_Serializer, toseatindex)
end

SerializerHelper.GmSpawnBasketballAI_Serializer = function(writer, spiritid, dutyid, isenemy)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, dutyid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isenemy, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmSpawnBasketballAI = function(self, spiritid, dutyid, isenemy)
	return self.Invoke(self, 69971512, SerializerHelper.GmSpawnBasketballAI_Serializer, spiritid, dutyid, isenemy)
end

SerializerHelper.GmFillBasketball3v3AI_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmFillBasketball3v3AI = function(self)
	return self.Invoke(self, 69976948, SerializerHelper.GmFillBasketball3v3AI_Serializer)
end

SerializerHelper.GmUnlockTarget_Serializer = function(writer, enemyid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmUnlockTarget = function(self, enemyid)
	return self.Invoke(self, 69987094, SerializerHelper.GmUnlockTarget_Serializer, enemyid)
end

SerializerHelper.GmPlotEnterVision_Serializer = function(writer, uid, targetuid)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneGMDelegate.GmPlotEnterVision = function(self, uid, targetuid)
	return self.Invoke(self, 69992938, SerializerHelper.GmPlotEnterVision_Serializer, uid, targetuid)
end

SerializerHelper.GmAgentTaskMove_Serializer = function(writer, agentid, x, y, z, arrivedistance, movemethod)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, x, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, y, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, z, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, arrivedistance, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, movemethod, writer.WriteInt32, 0)
end

ClientToGameSceneGMDelegate.GmAgentTaskMove = function(self, agentid, x, y, z, arrivedistance, movemethod)
	return self.Invoke(self, 69993575, SerializerHelper.GmAgentTaskMove_Serializer, agentid, x, y, z, arrivedistance, movemethod)
end

SerializerHelper.GmBlockAgentStimSource_Serializer = function(writer, agentid, isblock)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, isblock, writer.WriteBoolean, false)
end

ClientToGameSceneGMDelegate.GmBlockAgentStimSource = function(self, agentid, isblock)
	return self.Invoke(self, 69998217, SerializerHelper.GmBlockAgentStimSource_Serializer, agentid, isblock)
end

SerializerHelper.GmSpawnPoliceVehicle_Serializer = function(writer)
end

ClientToGameSceneGMDelegate.GmSpawnPoliceVehicle = function(self)
	return self.Invoke(self, 69998722, SerializerHelper.GmSpawnPoliceVehicle_Serializer)
end

return ClientToGameSceneGMDelegate
