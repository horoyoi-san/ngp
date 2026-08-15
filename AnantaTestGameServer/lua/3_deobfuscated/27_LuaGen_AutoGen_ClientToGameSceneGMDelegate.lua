local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToGameSceneGMDelegate = invoker:New()

function ClientToGameSceneGMDelegate.Sender()
	return NetworkManager.LuaGameRpcProcessor
end

function SerializerHelper.GmStartRaid_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmStartRaid()
	return self:Invoke(69005334, SerializerHelper.GmStartRaid_Serializer)
end

function SerializerHelper.GmControlEnemyBattleMove_Serializer(writer, pid, targetid, actiontype, actionid, mintime, maxtime, reportonstop)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, actiontype, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, actionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, mintime, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, maxtime, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, reportonstop, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmControlEnemyBattleMove(pid, targetid, actiontype, actionid, mintime, maxtime, reportonstop)
	return self:Invoke(69006194, SerializerHelper.GmControlEnemyBattleMove_Serializer, pid, targetid, actiontype, actionid, mintime, maxtime, reportonstop)
end

function SerializerHelper.GmEndEnemyDetectDebug_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmEndEnemyDetectDebug()
	return self:Invoke(69013530, SerializerHelper.GmEndEnemyDetectDebug_Serializer)
end

function SerializerHelper.GmAddCreationOnUnit_Serializer(writer, unitid, creationid, time)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, creationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, time, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmAddCreationOnUnit(unitid, creationid, time)
	return self:Invoke(69017721, SerializerHelper.GmAddCreationOnUnit_Serializer, unitid, creationid, time)
end

function SerializerHelper.GmOutOfStuck_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmOutOfStuck()
	return self:Invoke(69025080, SerializerHelper.GmOutOfStuck_Serializer)
end

function SerializerHelper.GmDeleteDMOverride_Serializer(writer, subjectagentid)
	SerializeBase.WritePrimitive(writer, subjectagentid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmDeleteDMOverride(subjectagentid)
	return self:Invoke(69035203, SerializerHelper.GmDeleteDMOverride_Serializer, subjectagentid)
end

function SerializerHelper.GmSetUseForwardGroup_Serializer(writer, agentid, value)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmSetUseForwardGroup(agentid, value)
	return self:Invoke(69036846, SerializerHelper.GmSetUseForwardGroup_Serializer, agentid, value)
end

function SerializerHelper.GmAddSceneItem_Serializer(writer, pathid, position, facing, iscale)
	SerializeBase.WritePrimitive(writer, pathid, writer.WriteInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WriteStruct(writer, facing, SerializeAuto.WriteUXVector3, "facing")
	SerializeBase.WritePrimitive(writer, iscale, writer.WriteInt32, 0)
end

function ClientToGameSceneGMDelegate:GmAddSceneItem(pathid, position, facing, iscale)
	return self:Invoke(69041527, SerializerHelper.GmAddSceneItem_Serializer, pathid, position, facing, iscale)
end

function SerializerHelper.GmAllSwitchToNpc_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmAllSwitchToNpc()
	return self:Invoke(69052894, SerializerHelper.GmAllSwitchToNpc_Serializer)
end

function SerializerHelper.GmDebugAllDestructible_Serializer(writer, distance)
	SerializeBase.WritePrimitive(writer, distance, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmDebugAllDestructible(distance)
	return self:Invoke(69057989, SerializerHelper.GmDebugAllDestructible_Serializer, distance)
end

function SerializerHelper.GmRemoveBuff_Serializer(writer, buffid, targetid, releaserid)
	SerializeBase.WritePrimitive(writer, buffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, releaserid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmRemoveBuff(buffid, targetid, releaserid)
	return self:Invoke(69060993, SerializerHelper.GmRemoveBuff_Serializer, buffid, targetid, releaserid)
end

function SerializerHelper.GmEnterGomokuZoneEndGame_Serializer(writer, gadgetuid, agentid, endgameid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, endgameid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmEnterGomokuZoneEndGame(gadgetuid, agentid, endgameid)
	return self:Invoke(69066069, SerializerHelper.GmEnterGomokuZoneEndGame_Serializer, gadgetuid, agentid, endgameid)
end

function SerializerHelper.GmGetScenePlayerCount_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmGetScenePlayerCount()
	return self:Invoke(69070187, SerializerHelper.GmGetScenePlayerCount_Serializer)
end

function SerializerHelper.GmStartEnemyStrategyDebug_Serializer(writer, enemyid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmStartEnemyStrategyDebug(enemyid)
	return self:Invoke(69080214, SerializerHelper.GmStartEnemyStrategyDebug_Serializer, enemyid)
end

function SerializerHelper.GmResumeAllEnemyAi_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmResumeAllEnemyAi()
	return self:Invoke(69080368, SerializerHelper.GmResumeAllEnemyAi_Serializer)
end

function SerializerHelper.GmSwitchToWeapon_Serializer(writer, weaponid)
	SerializeBase.WritePrimitive(writer, weaponid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmSwitchToWeapon(weaponid)
	return self:Invoke(69081995, SerializerHelper.GmSwitchToWeapon_Serializer, weaponid)
end

function SerializerHelper.GmWatchOtherPlayer_Serializer(writer, towatchplayerid)
	SerializeBase.WritePrimitive(writer, towatchplayerid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmWatchOtherPlayer(towatchplayerid)
	return self:Invoke(69090248, SerializerHelper.GmWatchOtherPlayer_Serializer, towatchplayerid)
end

function SerializerHelper.GmAetherChangeQuality_Serializer(writer, charactercountquality, vehiclecountquality)
	SerializeBase.WritePrimitive(writer, charactercountquality, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, vehiclecountquality, writer.WriteInt32, 0)
end

function ClientToGameSceneGMDelegate:GmAetherChangeQuality(charactercountquality, vehiclecountquality)
	return self:Invoke(69090708, SerializerHelper.GmAetherChangeQuality_Serializer, charactercountquality, vehiclecountquality)
end

function SerializerHelper.GmClearGmAttractPoint_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmClearGmAttractPoint()
	return self:Invoke(69093606, SerializerHelper.GmClearGmAttractPoint_Serializer)
end

function SerializerHelper.GmLeaveGomoku_Serializer(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmLeaveGomoku(gadgetuid)
	return self:Invoke(69095145, SerializerHelper.GmLeaveGomoku_Serializer, gadgetuid)
end

function SerializerHelper.GmRecordAgentBowlingScore_Serializer(writer, gadgetuid, npcid, throwindex, score)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, throwindex, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmRecordAgentBowlingScore(gadgetuid, npcid, throwindex, score)
	return self:Invoke(69097153, SerializerHelper.GmRecordAgentBowlingScore_Serializer, gadgetuid, npcid, throwindex, score)
end

function SerializerHelper.GmGetDestructibleInfo_Serializer(writer, instanceid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmGetDestructibleInfo(instanceid)
	return self:Invoke(69099263, SerializerHelper.GmGetDestructibleInfo_Serializer, instanceid)
end

function SerializerHelper.GmRemoveOtherUnitState_Serializer(writer, templateid, state)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmRemoveOtherUnitState(templateid, state)
	return self:Invoke(69102417, SerializerHelper.GmRemoveOtherUnitState_Serializer, templateid, state)
end

function SerializerHelper.GmSetIndoorSectorId_Serializer(writer, showid, hideid)
	SerializeBase.WritePrimitive(writer, showid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, hideid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmSetIndoorSectorId(showid, hideid)
	return self:Invoke(69102646, SerializerHelper.GmSetIndoorSectorId_Serializer, showid, hideid)
end

function SerializerHelper.GMEnableVehicleEscapeDebug_Serializer(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GMEnableVehicleEscapeDebug(enable)
	return self:Invoke(69110259, SerializerHelper.GMEnableVehicleEscapeDebug_Serializer, enable)
end

function SerializerHelper.GmEnableOxygenSystem_Serializer(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmEnableOxygenSystem(enable)
	return self:Invoke(69111473, SerializerHelper.GmEnableOxygenSystem_Serializer, enable)
end

function SerializerHelper.GmEndEnemyDetectStateDebug_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmEndEnemyDetectStateDebug()
	return self:Invoke(69122610, SerializerHelper.GmEndEnemyDetectStateDebug_Serializer)
end

function SerializerHelper.GmStartDart_Serializer(writer, gadgetuid, gametype)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, gametype, writer.WriteByte, 0)
end

function ClientToGameSceneGMDelegate:GmStartDart(gadgetuid, gametype)
	return self:Invoke(69127481, SerializerHelper.GmStartDart_Serializer, gadgetuid, gametype)
end

function SerializerHelper.GmEnableThreatDebug_Serializer(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmEnableThreatDebug(enable)
	return self:Invoke(69139588, SerializerHelper.GmEnableThreatDebug_Serializer, enable)
end

function SerializerHelper.GmOpenDebugPosition_Serializer(writer, value)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmOpenDebugPosition(value)
	return self:Invoke(69154474, SerializerHelper.GmOpenDebugPosition_Serializer, value)
end

function SerializerHelper.GmTestDamage_Serializer(writer, id, rate, damage, hurtid, elementtype, elementassign, elementvalue)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, rate, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, damage, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, hurtid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, elementtype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, elementassign, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, elementvalue, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmTestDamage(id, rate, damage, hurtid, elementtype, elementassign, elementvalue)
	return self:Invoke(69154555, SerializerHelper.GmTestDamage_Serializer, id, rate, damage, hurtid, elementtype, elementassign, elementvalue)
end

function SerializerHelper.GmSystemAddBuffToAll_Serializer(writer, buffid, duration)
	SerializeBase.WritePrimitive(writer, buffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, duration, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmSystemAddBuffToAll(buffid, duration)
	return self:Invoke(69157046, SerializerHelper.GmSystemAddBuffToAll_Serializer, buffid, duration)
end

function SerializerHelper.GmSelectAllRandomEvent_Serializer(writer, flag)
	SerializeBase.WritePrimitive(writer, flag, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmSelectAllRandomEvent(flag)
	return self:Invoke(69164442, SerializerHelper.GmSelectAllRandomEvent_Serializer, flag)
end

function SerializerHelper.GmEndEnemyStrategyDebug_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmEndEnemyStrategyDebug()
	return self:Invoke(69167882, SerializerHelper.GmEndEnemyStrategyDebug_Serializer)
end

function SerializerHelper.GmSetAttr_Serializer(writer, attr, value)
	SerializeBase.WritePrimitive(writer, attr, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmSetAttr(attr, value)
	return self:Invoke(69172064, SerializerHelper.GmSetAttr_Serializer, attr, value)
end

function SerializerHelper.GmSetWashCleaningInfo_Serializer(writer, progress, totalsecond, forceend)
	SerializeBase.WritePrimitive(writer, progress, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, totalsecond, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, forceend, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmSetWashCleaningInfo(progress, totalsecond, forceend)
	return self:Invoke(69174690, SerializerHelper.GmSetWashCleaningInfo_Serializer, progress, totalsecond, forceend)
end

function SerializerHelper.GmRemoveBehaviorBreakPoint_Serializer(writer, type, treename, id)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	writer:WriteString(treename, false, "treename", 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
end

function ClientToGameSceneGMDelegate:GmRemoveBehaviorBreakPoint(type, treename, id)
	return self:Invoke(69177494, SerializerHelper.GmRemoveBehaviorBreakPoint_Serializer, type, treename, id)
end

function SerializerHelper.GmSpawnPoliceVehicle_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmSpawnPoliceVehicle()
	return self:Invoke(69182657, SerializerHelper.GmSpawnPoliceVehicle_Serializer)
end

function SerializerHelper.GmRecoverAllSkillCooldown_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmRecoverAllSkillCooldown()
	return self:Invoke(69186022, SerializerHelper.GmRecoverAllSkillCooldown_Serializer)
end

function SerializerHelper.GmAddBuffToAllSpirit_Serializer(writer, buffid, duration, releaserid)
	SerializeBase.WritePrimitive(writer, buffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, duration, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, releaserid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmAddBuffToAllSpirit(buffid, duration, releaserid)
	return self:Invoke(69187036, SerializerHelper.GmAddBuffToAllSpirit_Serializer, buffid, duration, releaserid)
end

function SerializerHelper.GmAetherNpcFirstSpawnOnly_Serializer(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmAetherNpcFirstSpawnOnly(enable)
	return self:Invoke(69188937, SerializerHelper.GmAetherNpcFirstSpawnOnly_Serializer, enable)
end

function SerializerHelper.GmRemoveOtherUnitStateByInstance_Serializer(writer, instanceid, state)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmRemoveOtherUnitStateByInstance(instanceid, state)
	return self:Invoke(69196510, SerializerHelper.GmRemoveOtherUnitStateByInstance_Serializer, instanceid, state)
end

function SerializerHelper.GmDMEMOverride_Serializer(writer, subjectagentid, cfgid)
	SerializeBase.WritePrimitive(writer, subjectagentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, cfgid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmDMEMOverride(subjectagentid, cfgid)
	return self:Invoke(69209273, SerializerHelper.GmDMEMOverride_Serializer, subjectagentid, cfgid)
end

function SerializerHelper.GmTryToLockUnit_Serializer(writer, selfunitid, tolockunitid)
	SerializeBase.WritePrimitive(writer, selfunitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, tolockunitid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmTryToLockUnit(selfunitid, tolockunitid)
	return self:Invoke(69210324, SerializerHelper.GmTryToLockUnit_Serializer, selfunitid, tolockunitid)
end

function SerializerHelper.GmSetTrustee_Serializer(writer, trusterid, trusteeid)
	SerializeBase.WritePrimitive(writer, trusterid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, trusteeid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmSetTrustee(trusterid, trusteeid)
	return self:Invoke(69213330, SerializerHelper.GmSetTrustee_Serializer, trusterid, trusteeid)
end

function SerializerHelper.GmStopWatchOtherPlayer_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmStopWatchOtherPlayer()
	return self:Invoke(69224316, SerializerHelper.GmStopWatchOtherPlayer_Serializer)
end

function SerializerHelper.GmQueryLockTargetRadius_Serializer(writer, entity)
	SerializeBase.WritePrimitive(writer, entity, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmQueryLockTargetRadius(entity)
	return self:Invoke(69224470, SerializerHelper.GmQueryLockTargetRadius_Serializer, entity)
end

function SerializerHelper.GmAddEnemyByPlayer_Serializer(writer, enemyid, camp)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, camp, writer.WriteByte, 0)
end

function ClientToGameSceneGMDelegate:GmAddEnemyByPlayer(enemyid, camp)
	return self:Invoke(69229240, SerializerHelper.GmAddEnemyByPlayer_Serializer, enemyid, camp)
end

function SerializerHelper.GmWeaponDurabilityFree_Serializer(writer, isfree)
	SerializeBase.WritePrimitive(writer, isfree, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmWeaponDurabilityFree(isfree)
	return self:Invoke(69242189, SerializerHelper.GmWeaponDurabilityFree_Serializer, isfree)
end

function SerializerHelper.GmForceSetSwitchSpiritConfig_Serializer(writer, switchspiritconfigid)
	SerializeBase.WritePrimitive(writer, switchspiritconfigid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmForceSetSwitchSpiritConfig(switchspiritconfigid)
	return self:Invoke(69248402, SerializerHelper.GmForceSetSwitchSpiritConfig_Serializer, switchspiritconfigid)
end

function SerializerHelper.GmEnemyAiStopFlagByCamp_Serializer(writer, isfriend, stopflag)
	SerializeBase.WritePrimitive(writer, isfriend, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, stopflag, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmEnemyAiStopFlagByCamp(isfriend, stopflag)
	return self:Invoke(69249142, SerializerHelper.GmEnemyAiStopFlagByCamp_Serializer, isfriend, stopflag)
end

function SerializerHelper.GmFreeSkill_Serializer(writer, isfree)
	SerializeBase.WritePrimitive(writer, isfree, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmFreeSkill(isfree)
	return self:Invoke(69252846, SerializerHelper.GmFreeSkill_Serializer, isfree)
end

function SerializerHelper.GmBehaviorBreakContinue_Serializer(writer, id, type, treename)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	writer:WriteString(treename, false, "treename", 0)
end

function ClientToGameSceneGMDelegate:GmBehaviorBreakContinue(id, type, treename)
	return self:Invoke(69257869, SerializerHelper.GmBehaviorBreakContinue_Serializer, id, type, treename)
end

function SerializerHelper.GmUnlockTarget_Serializer(writer, enemyid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmUnlockTarget(enemyid)
	return self:Invoke(69262166, SerializerHelper.GmUnlockTarget_Serializer, enemyid)
end

function SerializerHelper.GmRemoveVehicleBuff_Serializer(writer, entityid, buffid1, buffid2, buffid3)
	SerializeBase.WritePrimitive(writer, entityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, buffid1, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, buffid2, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, buffid3, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmRemoveVehicleBuff(entityid, buffid1, buffid2, buffid3)
	return self:Invoke(69262594, SerializerHelper.GmRemoveVehicleBuff_Serializer, entityid, buffid1, buffid2, buffid3)
end

function SerializerHelper.GmResetTempCamp_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmResetTempCamp(pid)
	return self:Invoke(69272665, SerializerHelper.GmResetTempCamp_Serializer, pid)
end

function SerializerHelper.GmUseEnemyStrategy_Serializer(writer, enemyid, skillid, checkcd, checknav, checknoskilltime, servercast, clientasdatasource, triggercd)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, checkcd, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, checknav, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, checknoskilltime, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, servercast, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, clientasdatasource, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, triggercd, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmUseEnemyStrategy(enemyid, skillid, checkcd, checknav, checknoskilltime, servercast, clientasdatasource, triggercd)
	return self:Invoke(69283996, SerializerHelper.GmUseEnemyStrategy_Serializer, enemyid, skillid, checkcd, checknav, checknoskilltime, servercast, clientasdatasource, triggercd)
end

function SerializerHelper.GmAddEnemyWithPosition_Serializer(writer, enemyid, camp, position, navtagtype)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, camp, writer.WriteByte, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, navtagtype, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmAddEnemyWithPosition(enemyid, camp, position, navtagtype)
	return self:Invoke(69292406, SerializerHelper.GmAddEnemyWithPosition_Serializer, enemyid, camp, position, navtagtype)
end

function SerializerHelper.GmAetherCreateCrowd_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteGmCreatePedData, "data", false)
end

function ClientToGameSceneGMDelegate:GmAetherCreateCrowd(data)
	return self:Invoke(69292441, SerializerHelper.GmAetherCreateCrowd_Serializer, data)
end

function SerializerHelper.GmAddVehicleBuff_Serializer(writer, entityid, duration, buffid1, buffid2, buffid3)
	SerializeBase.WritePrimitive(writer, entityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, duration, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, buffid1, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, buffid2, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, buffid3, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmAddVehicleBuff(entityid, duration, buffid1, buffid2, buffid3)
	return self:Invoke(69305197, SerializerHelper.GmAddVehicleBuff_Serializer, entityid, duration, buffid1, buffid2, buffid3)
end

function SerializerHelper.GmQueryBattleStatisticsData_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmQueryBattleStatisticsData()
	return self:Invoke(69312503, SerializerHelper.GmQueryBattleStatisticsData_Serializer)
end

function SerializerHelper.GmAllSwitchToBattle_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmAllSwitchToBattle()
	return self:Invoke(69323141, SerializerHelper.GmAllSwitchToBattle_Serializer)
end

function SerializerHelper.GmAddElement_Serializer(writer, id, element, value)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, element, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmAddElement(id, element, value)
	return self:Invoke(69327275, SerializerHelper.GmAddElement_Serializer, id, element, value)
end

function SerializerHelper.GmRecoverPlayerAllSkillCharge_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmRecoverPlayerAllSkillCharge()
	return self:Invoke(69336692, SerializerHelper.GmRecoverPlayerAllSkillCharge_Serializer)
end

function SerializerHelper.GmSpawnAetherVehicleAtFront_Serializer(writer, vehicleconfigid, npcid1, npcid2)
	SerializeBase.WritePrimitive(writer, vehicleconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npcid1, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npcid2, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmSpawnAetherVehicleAtFront(vehicleconfigid, npcid1, npcid2)
	return self:Invoke(69338186, SerializerHelper.GmSpawnAetherVehicleAtFront_Serializer, vehicleconfigid, npcid1, npcid2)
end

function SerializerHelper.GmAgentGetInVehicle_Serializer(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmAgentGetInVehicle(agentid)
	return self:Invoke(69339388, SerializerHelper.GmAgentGetInVehicle_Serializer, agentid)
end

function SerializerHelper.GmGenMassNpcIds_Serializer(writer, count)
	SerializeBase.WritePrimitive(writer, count, writer.WriteInt32, 0)
end

function ClientToGameSceneGMDelegate:GmGenMassNpcIds(count)
	return self:Invoke(69340240, SerializerHelper.GmGenMassNpcIds_Serializer, count)
end

function SerializerHelper.GmClearBattleStatisticsData_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmClearBattleStatisticsData()
	return self:Invoke(69341375, SerializerHelper.GmClearBattleStatisticsData_Serializer)
end

function SerializerHelper.GmSelectRandomEvent_Serializer(writer, eventid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmSelectRandomEvent(eventid)
	return self:Invoke(69344043, SerializerHelper.GmSelectRandomEvent_Serializer, eventid)
end

function SerializerHelper.GmStopAllEnemyAi_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmStopAllEnemyAi()
	return self:Invoke(69346331, SerializerHelper.GmStopAllEnemyAi_Serializer)
end

function SerializerHelper.GmRemoveCreation_Serializer(writer, creations)
	SerializeBase.WriteList(writer, creations, writer.WriteUInt64, 0, "creations", true, 0, nil)
end

function ClientToGameSceneGMDelegate:GmRemoveCreation(creations)
	return self:Invoke(69352884, SerializerHelper.GmRemoveCreation_Serializer, creations)
end

function SerializerHelper.GmBuyFoods_Serializer(writer, restaurantid, companionnpcid, foodid)
	SerializeBase.WritePrimitive(writer, restaurantid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, companionnpcid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, foodid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmBuyFoods(restaurantid, companionnpcid, foodid)
	return self:Invoke(69360551, SerializerHelper.GmBuyFoods_Serializer, restaurantid, companionnpcid, foodid)
end

function SerializerHelper.GmTeleportUnitXYZ_Serializer(writer, unitid, x, y, z)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, x, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, y, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, z, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmTeleportUnitXYZ(unitid, x, y, z)
	return self:Invoke(69363476, SerializerHelper.GmTeleportUnitXYZ_Serializer, unitid, x, y, z)
end

function SerializerHelper.GmCreateGadget_Serializer(writer, instanceid, pos, facing, graphid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
	SerializeBase.WriteStruct(writer, facing, SerializeAuto.WriteUXVector3, "facing")
	SerializeBase.WritePrimitive(writer, graphid, writer.WriteInt32, 0)
end

function ClientToGameSceneGMDelegate:GmCreateGadget(instanceid, pos, facing, graphid)
	return self:Invoke(69370162, SerializerHelper.GmCreateGadget_Serializer, instanceid, pos, facing, graphid)
end

function SerializerHelper.GmPrintClientTargetRayVisibilityDirection_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmPrintClientTargetRayVisibilityDirection()
	return self:Invoke(69383316, SerializerHelper.GmPrintClientTargetRayVisibilityDirection_Serializer)
end

function SerializerHelper.GmClearAllLinkDuty_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmClearAllLinkDuty()
	return self:Invoke(69384019, SerializerHelper.GmClearAllLinkDuty_Serializer)
end

function SerializerHelper.GmSetDebugInitializeUsages_Serializer(writer, usageid)
	SerializeBase.WritePrimitive(writer, usageid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmSetDebugInitializeUsages(usageid)
	return self:Invoke(69385902, SerializerHelper.GmSetDebugInitializeUsages_Serializer, usageid)
end

function SerializerHelper.GmStartEnemyGroupDebug_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmStartEnemyGroupDebug()
	return self:Invoke(69395665, SerializerHelper.GmStartEnemyGroupDebug_Serializer)
end

function SerializerHelper.GmSetLinkDuty_Serializer(writer, dutyid)
	SerializeBase.WritePrimitive(writer, dutyid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmSetLinkDuty(dutyid)
	return self:Invoke(69400919, SerializerHelper.GmSetLinkDuty_Serializer, dutyid)
end

function SerializerHelper.GmPlaceGomokuPiece_Serializer(writer, gadgetuid, x, y)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, x, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, y, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmPlaceGomokuPiece(gadgetuid, x, y)
	return self:Invoke(69407519, SerializerHelper.GmPlaceGomokuPiece_Serializer, gadgetuid, x, y)
end

function SerializerHelper.SyncStoryCoreClientDebugInfoGM_Serializer(writer, info)
	writer:WriteString(info, false, "info", 0)
end

function ClientToGameSceneGMDelegate:SyncStoryCoreClientDebugInfoGM(info)
	return self:Invoke(69425561, SerializerHelper.SyncStoryCoreClientDebugInfoGM_Serializer, info)
end

function SerializerHelper.GmAddEnemy_Serializer(writer, enemyid, camp, treename, navtagtype)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, camp, writer.WriteByte, 0)
	writer:WriteString(treename, false, "treename", 0)
	SerializeBase.WritePrimitive(writer, navtagtype, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmAddEnemy(enemyid, camp, treename, navtagtype)
	return self:Invoke(69425644, SerializerHelper.GmAddEnemy_Serializer, enemyid, camp, treename, navtagtype)
end

function SerializerHelper.GmAetherKillAllCrowd_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmAetherKillAllCrowd()
	return self:Invoke(69435013, SerializerHelper.GmAetherKillAllCrowd_Serializer)
end

function SerializerHelper.GmNotifyDamageSimulationStart_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmNotifyDamageSimulationStart()
	return self:Invoke(69448764, SerializerHelper.GmNotifyDamageSimulationStart_Serializer)
end

function SerializerHelper.GmAgentGetOutVehicle_Serializer(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmAgentGetOutVehicle(agentid)
	return self:Invoke(69449002, SerializerHelper.GmAgentGetOutVehicle_Serializer, agentid)
end

function SerializerHelper.GmRegenerateWildEnemy_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmRegenerateWildEnemy()
	return self:Invoke(69450263, SerializerHelper.GmRegenerateWildEnemy_Serializer)
end

function SerializerHelper.GmAetherChangeAreaDensity_Serializer(writer, density, radius)
	SerializeBase.WritePrimitive(writer, density, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, radius, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmAetherChangeAreaDensity(density, radius)
	return self:Invoke(69452998, SerializerHelper.GmAetherChangeAreaDensity_Serializer, density, radius)
end

function SerializerHelper.GmConvertAetherNpcToPureAgent_Serializer(writer, entityid)
	SerializeBase.WritePrimitive(writer, entityid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmConvertAetherNpcToPureAgent(entityid)
	return self:Invoke(69453720, SerializerHelper.GmConvertAetherNpcToPureAgent_Serializer, entityid)
end

function SerializerHelper.GmFixFrame_Serializer(writer, value)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmFixFrame(value)
	return self:Invoke(69457570, SerializerHelper.GmFixFrame_Serializer, value)
end

function SerializerHelper.SendCustomCommonDataClientToGameSceneGM_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

function ClientToGameSceneGMDelegate:SendCustomCommonDataClientToGameSceneGM(data)
	return self:Invoke(69464393, SerializerHelper.SendCustomCommonDataClientToGameSceneGM_Serializer, data)
end

function SerializerHelper.GmRevive_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmRevive()
	return self:Invoke(69465016, SerializerHelper.GmRevive_Serializer)
end

function SerializerHelper.GmDestroyVehicle_Serializer(writer, vehicleid)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmDestroyVehicle(vehicleid)
	return self:Invoke(69466457, SerializerHelper.GmDestroyVehicle_Serializer, vehicleid)
end

function SerializerHelper.GmToggleStoryDebug_Serializer(writer, flag)
	SerializeBase.WritePrimitive(writer, flag, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmToggleStoryDebug(flag)
	return self:Invoke(69468125, SerializerHelper.GmToggleStoryDebug_Serializer, flag)
end

function SerializerHelper.GmTeleportToLinkMember_Serializer(writer, index)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

function ClientToGameSceneGMDelegate:GmTeleportToLinkMember(index)
	return self:Invoke(69471236, SerializerHelper.GmTeleportToLinkMember_Serializer, index)
end

function SerializerHelper.GmTestTeamControlPowerSkill_Serializer(writer, valid)
	SerializeBase.WritePrimitive(writer, valid, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmTestTeamControlPowerSkill(valid)
	return self:Invoke(69472213, SerializerHelper.GmTestTeamControlPowerSkill_Serializer, valid)
end

function SerializerHelper.GmClearStoryCache_Serializer(writer, name)
	writer:WriteString(name, false, "name", 0)
end

function ClientToGameSceneGMDelegate:GmClearStoryCache(name)
	return self:Invoke(69475317, SerializerHelper.GmClearStoryCache_Serializer, name)
end

function SerializerHelper.GmSetHp_Serializer(writer, percent)
	SerializeBase.WritePrimitive(writer, percent, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmSetHp(percent)
	return self:Invoke(69478654, SerializerHelper.GmSetHp_Serializer, percent)
end

function SerializerHelper.GmStartAIDebug_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmStartAIDebug()
	return self:Invoke(69482400, SerializerHelper.GmStartAIDebug_Serializer)
end

function SerializerHelper.GmAddOtherBuff_Serializer(writer, buffid, target, releaserid, time)
	SerializeBase.WritePrimitive(writer, buffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, target, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, releaserid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, time, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmAddOtherBuff(buffid, target, releaserid, time)
	return self:Invoke(69484174, SerializerHelper.GmAddOtherBuff_Serializer, buffid, target, releaserid, time)
end

function SerializerHelper.TestSyncAiBeginSkillAccumulate_Serializer(writer, skillid)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:TestSyncAiBeginSkillAccumulate(skillid)
	return self:Invoke(69492919, SerializerHelper.TestSyncAiBeginSkillAccumulate_Serializer, skillid)
end

function SerializerHelper.GmTeleportXYZ_Serializer(writer, x, y, z, facing)
	SerializeBase.WritePrimitive(writer, x, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, y, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, z, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmTeleportXYZ(x, y, z, facing)
	return self:Invoke(69494703, SerializerHelper.GmTeleportXYZ_Serializer, x, y, z, facing)
end

function SerializerHelper.GmSetDgoNavVoxelSurface_Serializer(writer, surfaceid)
	SerializeBase.WritePrimitive(writer, surfaceid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmSetDgoNavVoxelSurface(surfaceid)
	return self:Invoke(69499085, SerializerHelper.GmSetDgoNavVoxelSurface_Serializer, surfaceid)
end

function SerializerHelper.GmEnableRandomEvent_Serializer(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmEnableRandomEvent(enable)
	return self:Invoke(69500068, SerializerHelper.GmEnableRandomEvent_Serializer, enable)
end

function SerializerHelper.GmAetherCreatePedWithDisease_Serializer(writer, diseaseids)
	writer:WriteString(diseaseids, false, "diseaseids", 0)
end

function ClientToGameSceneGMDelegate:GmAetherCreatePedWithDisease(diseaseids)
	return self:Invoke(69500444, SerializerHelper.GmAetherCreatePedWithDisease_Serializer, diseaseids)
end

function SerializerHelper.GmSpawnVehicleOnlineAtFront_Serializer(writer, vehicleid)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmSpawnVehicleOnlineAtFront(vehicleid)
	return self:Invoke(69504167, SerializerHelper.GmSpawnVehicleOnlineAtFront_Serializer, vehicleid)
end

function SerializerHelper.GmSetStoryValue_Serializer(writer, path, value)
	writer:WriteString(path, false, "path", 0)
	writer:WriteString(value, false, "value", 0)
end

function ClientToGameSceneGMDelegate:GmSetStoryValue(path, value)
	return self:Invoke(69504267, SerializerHelper.GmSetStoryValue_Serializer, path, value)
end

function SerializerHelper.GmClearTempSpirits_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmClearTempSpirits()
	return self:Invoke(69507148, SerializerHelper.GmClearTempSpirits_Serializer)
end

function SerializerHelper.GmStartSyncAIAction_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmStartSyncAIAction()
	return self:Invoke(69508457, SerializerHelper.GmStartSyncAIAction_Serializer)
end

function SerializerHelper.GmEndSyncAIAction_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmEndSyncAIAction()
	return self:Invoke(69516811, SerializerHelper.GmEndSyncAIAction_Serializer)
end

function SerializerHelper.GmSetEmotion_Serializer(writer, agentid, emotion, value)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, emotion, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmSetEmotion(agentid, emotion, value)
	return self:Invoke(69524018, SerializerHelper.GmSetEmotion_Serializer, agentid, emotion, value)
end

function SerializerHelper.GmQueryDamageSimulationResult_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmQueryDamageSimulationResult()
	return self:Invoke(69543371, SerializerHelper.GmQueryDamageSimulationResult_Serializer)
end

function SerializerHelper.GmPrintRecentMove_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmPrintRecentMove()
	return self:Invoke(69547508, SerializerHelper.GmPrintRecentMove_Serializer)
end

function SerializerHelper.GmAddStory_Serializer(writer, storyname)
	writer:WriteString(storyname, false, "storyname", 0)
end

function ClientToGameSceneGMDelegate:GmAddStory(storyname)
	return self:Invoke(69553056, SerializerHelper.GmAddStory_Serializer, storyname)
end

function SerializerHelper.GmAetherEnsureRefreshStaticNpc_Serializer(writer, ensurerefresh)
	SerializeBase.WritePrimitive(writer, ensurerefresh, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmAetherEnsureRefreshStaticNpc(ensurerefresh)
	return self:Invoke(69557913, SerializerHelper.GmAetherEnsureRefreshStaticNpc_Serializer, ensurerefresh)
end

function SerializerHelper.GmAddBasicAttr_Serializer(writer, attr, addvalue)
	SerializeBase.WritePrimitive(writer, attr, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, addvalue, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmAddBasicAttr(attr, addvalue)
	return self:Invoke(69558895, SerializerHelper.GmAddBasicAttr_Serializer, attr, addvalue)
end

function SerializerHelper.GmAetherActivateNpcPrefab_Serializer(writer, prefabname, enable)
	writer:WriteString(prefabname, false, "prefabname", 0)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmAetherActivateNpcPrefab(prefabname, enable)
	return self:Invoke(69562847, SerializerHelper.GmAetherActivateNpcPrefab_Serializer, prefabname, enable)
end

function SerializerHelper.GmSetSectorNavVoxelSurface_Serializer(writer, surfaceid)
	SerializeBase.WritePrimitive(writer, surfaceid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmSetSectorNavVoxelSurface(surfaceid)
	return self:Invoke(69567020, SerializerHelper.GmSetSectorNavVoxelSurface_Serializer, surfaceid)
end

function SerializerHelper.GmRecordBowlingScore_Serializer(writer, gadgetuid, throwindex, score)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, throwindex, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmRecordBowlingScore(gadgetuid, throwindex, score)
	return self:Invoke(69570080, SerializerHelper.GmRecordBowlingScore_Serializer, gadgetuid, throwindex, score)
end

function SerializerHelper.GmEndAIDebug_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmEndAIDebug()
	return self:Invoke(69581093, SerializerHelper.GmEndAIDebug_Serializer)
end

function SerializerHelper.GmSwitchSpiritHere_Serializer(writer, spiritid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmSwitchSpiritHere(spiritid)
	return self:Invoke(69593130, SerializerHelper.GmSwitchSpiritHere_Serializer, spiritid)
end

function SerializerHelper.GmUseAISkill_Serializer(writer, skillid, targetid)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmUseAISkill(skillid, targetid)
	return self:Invoke(69594078, SerializerHelper.GmUseAISkill_Serializer, skillid, targetid)
end

function SerializerHelper.GmSetStealthValue_Serializer(writer, enemyid, value)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmSetStealthValue(enemyid, value)
	return self:Invoke(69602697, SerializerHelper.GmSetStealthValue_Serializer, enemyid, value)
end

function SerializerHelper.GmBuyCinemaTicket_Serializer(writer, cinemaid, movieid, companionnpcid)
	SerializeBase.WritePrimitive(writer, cinemaid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, movieid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, companionnpcid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmBuyCinemaTicket(cinemaid, movieid, companionnpcid)
	return self:Invoke(69607166, SerializerHelper.GmBuyCinemaTicket_Serializer, cinemaid, movieid, companionnpcid)
end

function SerializerHelper.GmAetherAddDangerZone_Serializer(writer, centerpos, radius)
	SerializeBase.WriteStruct(writer, centerpos, SerializeAuto.WriteUXVector3, "centerpos")
	SerializeBase.WritePrimitive(writer, radius, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmAetherAddDangerZone(centerpos, radius)
	return self:Invoke(69608267, SerializerHelper.GmAetherAddDangerZone_Serializer, centerpos, radius)
end

function SerializerHelper.GmLockEmotion_Serializer(writer, agentid, value)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmLockEmotion(agentid, value)
	return self:Invoke(69609599, SerializerHelper.GmLockEmotion_Serializer, agentid, value)
end

function SerializerHelper.GmAddNpc_Serializer(writer, npcid, plotid)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, plotid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmAddNpc(npcid, plotid)
	return self:Invoke(69611563, SerializerHelper.GmAddNpc_Serializer, npcid, plotid)
end

function SerializerHelper.GmTeleportUnit_Serializer(writer, unitid, x, z)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, x, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, z, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmTeleportUnit(unitid, x, z)
	return self:Invoke(69613713, SerializerHelper.GmTeleportUnit_Serializer, unitid, x, z)
end

function SerializerHelper.GmClientInputSpoonTest_Serializer(writer, p1, p2, p3)
	SerializeBase.WritePrimitive(writer, p1, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, p2, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, p3, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmClientInputSpoonTest(p1, p2, p3)
	return self:Invoke(69624822, SerializerHelper.GmClientInputSpoonTest_Serializer, p1, p2, p3)
end

function SerializerHelper.GmChangeAgentWeapon_Serializer(writer, agentid, weaponid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, weaponid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmChangeAgentWeapon(agentid, weaponid)
	return self:Invoke(69629956, SerializerHelper.GmChangeAgentWeapon_Serializer, agentid, weaponid)
end

function SerializerHelper.GmAetherResetAreaDensity_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmAetherResetAreaDensity()
	return self:Invoke(69638347, SerializerHelper.GmAetherResetAreaDensity_Serializer)
end

function SerializerHelper.GmLeaveBowling_Serializer(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmLeaveBowling(gadgetuid)
	return self:Invoke(69644865, SerializerHelper.GmLeaveBowling_Serializer, gadgetuid)
end

function SerializerHelper.GmBehaviorNextPoint_Serializer(writer, id, type, treename)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	writer:WriteString(treename, false, "treename", 0)
end

function ClientToGameSceneGMDelegate:GmBehaviorNextPoint(id, type, treename)
	return self:Invoke(69646600, SerializerHelper.GmBehaviorNextPoint_Serializer, id, type, treename)
end

function SerializerHelper.GmAetherCreatePed_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmAetherCreatePed()
	return self:Invoke(69649680, SerializerHelper.GmAetherCreatePed_Serializer)
end

function SerializerHelper.GmAetherChangePedNumScale_Serializer(writer, scale, refreshnpc)
	SerializeBase.WritePrimitive(writer, scale, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, refreshnpc, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmAetherChangePedNumScale(scale, refreshnpc)
	return self:Invoke(69651030, SerializerHelper.GmAetherChangePedNumScale_Serializer, scale, refreshnpc)
end

function SerializerHelper.GmDropEnemyWeapon_Serializer(writer, agentid, breakimmediately, yforce, zforce, gravity)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, breakimmediately, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, yforce, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, zforce, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, gravity, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmDropEnemyWeapon(agentid, breakimmediately, yforce, zforce, gravity)
	return self:Invoke(69651537, SerializerHelper.GmDropEnemyWeapon_Serializer, agentid, breakimmediately, yforce, zforce, gravity)
end

function SerializerHelper.GmRefreshCrimes_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmRefreshCrimes()
	return self:Invoke(69651936, SerializerHelper.GmRefreshCrimes_Serializer)
end

function SerializerHelper.GmRemoveCompanion_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmRemoveCompanion()
	return self:Invoke(69656494, SerializerHelper.GmRemoveCompanion_Serializer)
end

function SerializerHelper.GmKillEnemy_Serializer(writer, enemyid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmKillEnemy(enemyid)
	return self:Invoke(69665529, SerializerHelper.GmKillEnemy_Serializer, enemyid)
end

function SerializerHelper.GmPidSetHp_Serializer(writer, pid, percent)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, percent, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmPidSetHp(pid, percent)
	return self:Invoke(69673206, SerializerHelper.GmPidSetHp_Serializer, pid, percent)
end

function SerializerHelper.GmSetDebugBehaviorNode_Serializer(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmSetDebugBehaviorNode(enable)
	return self:Invoke(69675433, SerializerHelper.GmSetDebugBehaviorNode_Serializer, enable)
end

function SerializerHelper.GmAetherCreateNpc_Serializer(writer, type, position, facing, agentid, optiondata)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, optiondata, SerializeAuto.WriteGmCreateNpcOptionData, "optiondata", true)
end

function ClientToGameSceneGMDelegate:GmAetherCreateNpc(type, position, facing, agentid, optiondata)
	return self:Invoke(69692322, SerializerHelper.GmAetherCreateNpc_Serializer, type, position, facing, agentid, optiondata)
end

function SerializerHelper.GmGameEnd_Serializer(writer, iswin)
	SerializeBase.WritePrimitive(writer, iswin, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmGameEnd(iswin)
	return self:Invoke(69704549, SerializerHelper.GmGameEnd_Serializer, iswin)
end

function SerializerHelper.GmAetherRefreshNpc_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmAetherRefreshNpc()
	return self:Invoke(69705586, SerializerHelper.GmAetherRefreshNpc_Serializer)
end

function SerializerHelper.GmAddOtherUnitState_Serializer(writer, templateid, state)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmAddOtherUnitState(templateid, state)
	return self:Invoke(69729538, SerializerHelper.GmAddOtherUnitState_Serializer, templateid, state)
end

function SerializerHelper.GmStartPlotBehavior_Serializer(writer, agentid, name, procedure)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	writer:WriteString(name, false, "name", 0)
	SerializeBase.WritePrimitive(writer, procedure, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmStartPlotBehavior(agentid, name, procedure)
	return self:Invoke(69730573, SerializerHelper.GmStartPlotBehavior_Serializer, agentid, name, procedure)
end

function SerializerHelper.GmPlayerUseSkillDebugOnly_Serializer(writer, skillid, targetid, checkcd, checknav, checknoskilltime, servercast, clientasdatasource, triggercd, useres)
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

function ClientToGameSceneGMDelegate:GmPlayerUseSkillDebugOnly(skillid, targetid, checkcd, checknav, checknoskilltime, servercast, clientasdatasource, triggercd, useres)
	return self:Invoke(69736041, SerializerHelper.GmPlayerUseSkillDebugOnly_Serializer, skillid, targetid, checkcd, checknav, checknoskilltime, servercast, clientasdatasource, triggercd, useres)
end

function SerializerHelper.GmStartEnemyDetectStateDebug_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmStartEnemyDetectStateDebug()
	return self:Invoke(69740071, SerializerHelper.GmStartEnemyDetectStateDebug_Serializer)
end

function SerializerHelper.GmEndEnemyGroupDebug_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmEndEnemyGroupDebug()
	return self:Invoke(69745251, SerializerHelper.GmEndEnemyGroupDebug_Serializer)
end

function SerializerHelper.GmPoliceEnableCrimeValue_Serializer(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmPoliceEnableCrimeValue(enable)
	return self:Invoke(69749315, SerializerHelper.GmPoliceEnableCrimeValue_Serializer, enable)
end

function SerializerHelper.GmChangeSectorControl_Serializer(writer, sectorcontrolid, enable)
	SerializeBase.WritePrimitive(writer, sectorcontrolid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmChangeSectorControl(sectorcontrolid, enable)
	return self:Invoke(69762504, SerializerHelper.GmChangeSectorControl_Serializer, sectorcontrolid, enable)
end

function SerializerHelper.GmTriggerPlotEvent2_Serializer(writer, ploteventid, agentid)
	SerializeBase.WritePrimitive(writer, ploteventid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

function ClientToGameSceneGMDelegate:GmTriggerPlotEvent2(ploteventid, agentid)
	return self:Invoke(69762606, SerializerHelper.GmTriggerPlotEvent2_Serializer, ploteventid, agentid)
end

function SerializerHelper.GmDebugAllGadget_Serializer(writer, distance)
	SerializeBase.WritePrimitive(writer, distance, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmDebugAllGadget(distance)
	return self:Invoke(69771567, SerializerHelper.GmDebugAllGadget_Serializer, distance)
end

function SerializerHelper.GmEnterGomokuZoneDoubleAI_Serializer(writer, gadgetuid, agentid, useblackpiece, difficulty)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, useblackpiece, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, difficulty, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmEnterGomokuZoneDoubleAI(gadgetuid, agentid, useblackpiece, difficulty)
	return self:Invoke(69772229, SerializerHelper.GmEnterGomokuZoneDoubleAI_Serializer, gadgetuid, agentid, useblackpiece, difficulty)
end

function SerializerHelper.GmClearBehaviorBreakPoint_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmClearBehaviorBreakPoint()
	return self:Invoke(69776735, SerializerHelper.GmClearBehaviorBreakPoint_Serializer)
end

function SerializerHelper.GmKillNearestGadget_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmKillNearestGadget()
	return self:Invoke(69779695, SerializerHelper.GmKillNearestGadget_Serializer)
end

function SerializerHelper.GmStopEnemyAiByCamp_Serializer(writer, camp)
	SerializeBase.WritePrimitive(writer, camp, writer.WriteInt32, 0)
end

function ClientToGameSceneGMDelegate:GmStopEnemyAiByCamp(camp)
	return self:Invoke(69780427, SerializerHelper.GmStopEnemyAiByCamp_Serializer, camp)
end

function SerializerHelper.GmSpawnVehicleOnline_Serializer(writer, vehicleid, position, facing)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmSpawnVehicleOnline(vehicleid, position, facing)
	return self:Invoke(69799762, SerializerHelper.GmSpawnVehicleOnline_Serializer, vehicleid, position, facing)
end

function SerializerHelper.GmAddChaosObject_Serializer(writer, chaosid)
	SerializeBase.WritePrimitive(writer, chaosid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmAddChaosObject(chaosid)
	return self:Invoke(69800655, SerializerHelper.GmAddChaosObject_Serializer, chaosid)
end

function SerializerHelper.GmCreateStaticNpcOnChair_Serializer(writer, gadgetid, gadgetconfigid, slotindex, agentid)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, gadgetconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, slotindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmCreateStaticNpcOnChair(gadgetid, gadgetconfigid, slotindex, agentid)
	return self:Invoke(69801946, SerializerHelper.GmCreateStaticNpcOnChair_Serializer, gadgetid, gadgetconfigid, slotindex, agentid)
end

function SerializerHelper.GmAetherChangeVehicleDynamicAOI_Serializer(writer, aoirange, maxaoirange, aoifactor)
	SerializeBase.WritePrimitive(writer, aoirange, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, maxaoirange, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, aoifactor, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmAetherChangeVehicleDynamicAOI(aoirange, maxaoirange, aoifactor)
	return self:Invoke(69803787, SerializerHelper.GmAetherChangeVehicleDynamicAOI_Serializer, aoirange, maxaoirange, aoifactor)
end

function SerializerHelper.GmSpawnAetherVehicle_Serializer(writer, vehicleconfigid, position, facing, npcid1, npcid2)
	SerializeBase.WritePrimitive(writer, vehicleconfigid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, npcid1, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npcid2, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmSpawnAetherVehicle(vehicleconfigid, position, facing, npcid1, npcid2)
	return self:Invoke(69808290, SerializerHelper.GmSpawnAetherVehicle_Serializer, vehicleconfigid, position, facing, npcid1, npcid2)
end

function SerializerHelper.GmRefreshRandomEvent_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmRefreshRandomEvent()
	return self:Invoke(69813788, SerializerHelper.GmRefreshRandomEvent_Serializer)
end

function SerializerHelper.GmChangeAgentBehaviorTree_Serializer(writer, id, treename)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	writer:WriteString(treename, false, "treename", 0)
end

function ClientToGameSceneGMDelegate:GmChangeAgentBehaviorTree(id, treename)
	return self:Invoke(69819237, SerializerHelper.GmChangeAgentBehaviorTree_Serializer, id, treename)
end

function SerializerHelper.GmAddOtherUnitStateByInstance_Serializer(writer, instanceid, state)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmAddOtherUnitStateByInstance(instanceid, state)
	return self:Invoke(69820095, SerializerHelper.GmAddOtherUnitStateByInstance_Serializer, instanceid, state)
end

function SerializerHelper.GmStartHackerAutonomousDriving_Serializer(writer, x, y, z)
	SerializeBase.WritePrimitive(writer, x, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, y, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, z, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmStartHackerAutonomousDriving(x, y, z)
	return self:Invoke(69824839, SerializerHelper.GmStartHackerAutonomousDriving_Serializer, x, y, z)
end

function SerializerHelper.GmStartEnemyDetectDebug_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmStartEnemyDetectDebug()
	return self:Invoke(69828700, SerializerHelper.GmStartEnemyDetectDebug_Serializer)
end

function SerializerHelper.GmEnterBowlingZone_Serializer(writer, gadgetuid, gametype, agentid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, gametype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmEnterBowlingZone(gadgetuid, gametype, agentid)
	return self:Invoke(69829299, SerializerHelper.GmEnterBowlingZone_Serializer, gadgetuid, gametype, agentid)
end

function SerializerHelper.GmSetTempCamp_Serializer(writer, id, camp)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, camp, writer.WriteByte, 0)
end

function ClientToGameSceneGMDelegate:GmSetTempCamp(id, camp)
	return self:Invoke(69836221, SerializerHelper.GmSetTempCamp_Serializer, id, camp)
end

function SerializerHelper.TestUpdateDaShenLogToken_Serializer(writer, logtoken)
	writer:WriteString(logtoken, false, "logtoken", 0)
end

function ClientToGameSceneGMDelegate:TestUpdateDaShenLogToken(logtoken)
	return self:Invoke(69838809, SerializerHelper.TestUpdateDaShenLogToken_Serializer, logtoken)
end

function SerializerHelper.GmAetherRecoverAllCrowd_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmAetherRecoverAllCrowd()
	return self:Invoke(69843269, SerializerHelper.GmAetherRecoverAllCrowd_Serializer)
end

function SerializerHelper.GmGetSceneNpcInfo4AutoQA_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmGetSceneNpcInfo4AutoQA()
	return self:Invoke(69851223, SerializerHelper.GmGetSceneNpcInfo4AutoQA_Serializer)
end

function SerializerHelper.GmAddCompanion_Serializer(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmAddCompanion(agentid)
	return self:Invoke(69853559, SerializerHelper.GmAddCompanion_Serializer, agentid)
end

function SerializerHelper.GmPauseBehaviorAI_Serializer(writer, id, value)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmPauseBehaviorAI(id, value)
	return self:Invoke(69857941, SerializerHelper.GmPauseBehaviorAI_Serializer, id, value)
end

function SerializerHelper.GmAetherForceUseUsage_Serializer(writer, usageid)
	SerializeBase.WritePrimitive(writer, usageid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmAetherForceUseUsage(usageid)
	return self:Invoke(69860355, SerializerHelper.GmAetherForceUseUsage_Serializer, usageid)
end

function SerializerHelper.GmAddAgent_Serializer(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmAddAgent(agentid)
	return self:Invoke(69861538, SerializerHelper.GmAddAgent_Serializer, agentid)
end

function SerializerHelper.GmTriggerPlotEvent_Serializer(writer, ploteventid)
	SerializeBase.WritePrimitive(writer, ploteventid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmTriggerPlotEvent(ploteventid)
	return self:Invoke(69863556, SerializerHelper.GmTriggerPlotEvent_Serializer, ploteventid)
end

function SerializerHelper.GmUseSkillWithErrorCode_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillUseData, "data", false)
end

function ClientToGameSceneGMDelegate:GmUseSkillWithErrorCode(data)
	return self:Invoke(69868438, SerializerHelper.GmUseSkillWithErrorCode_Serializer, data)
end

function SerializerHelper.GmGoToNextFrame_Serializer(writer, time)
	SerializeBase.WritePrimitive(writer, time, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmGoToNextFrame(time)
	return self:Invoke(69871291, SerializerHelper.GmGoToNextFrame_Serializer, time)
end

function SerializerHelper.GmDaVinciCode_Serializer(writer, code)
	writer:WriteString(code, false, "code", 0)
end

function ClientToGameSceneGMDelegate:GmDaVinciCode(code)
	return self:Invoke(69871965, SerializerHelper.GmDaVinciCode_Serializer, code)
end

function SerializerHelper.GmAddBehaviorBreakPoint_Serializer(writer, type, treename, id)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	writer:WriteString(treename, false, "treename", 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
end

function ClientToGameSceneGMDelegate:GmAddBehaviorBreakPoint(type, treename, id)
	return self:Invoke(69886296, SerializerHelper.GmAddBehaviorBreakPoint_Serializer, type, treename, id)
end

function SerializerHelper.GmSpreadStealthFromAToB_Serializer(writer, ida, idb, value)
	SerializeBase.WritePrimitive(writer, ida, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, idb, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmSpreadStealthFromAToB(ida, idb, value)
	return self:Invoke(69899081, SerializerHelper.GmSpreadStealthFromAToB_Serializer, ida, idb, value)
end

function SerializerHelper.GmWorldRefreshEnemyGroup_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmWorldRefreshEnemyGroup()
	return self:Invoke(69900663, SerializerHelper.GmWorldRefreshEnemyGroup_Serializer)
end

function SerializerHelper.CheckPlayerPosition_Serializer(writer, position, moveid)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, moveid, writer.WriteInt32, 0)
end

function ClientToGameSceneGMDelegate:CheckPlayerPosition(position, moveid)
	return self:Invoke(69911024, SerializerHelper.CheckPlayerPosition_Serializer, position, moveid)
end

function SerializerHelper.GmRefreshAllDestructibles_Serializer(writer, distance)
	SerializeBase.WritePrimitive(writer, distance, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmRefreshAllDestructibles(distance)
	return self:Invoke(69935255, SerializerHelper.GmRefreshAllDestructibles_Serializer, distance)
end

function SerializerHelper.GmAddDestructible_Serializer(writer, pathid, templateid, position, facing, iscale, path)
	SerializeBase.WritePrimitive(writer, pathid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WriteStruct(writer, facing, SerializeAuto.WriteUXVector3, "facing")
	SerializeBase.WritePrimitive(writer, iscale, writer.WriteInt32, 0)
	writer:WriteString(path, false, "path", 0)
end

function ClientToGameSceneGMDelegate:GmAddDestructible(pathid, templateid, position, facing, iscale, path)
	return self:Invoke(69936257, SerializerHelper.GmAddDestructible_Serializer, pathid, templateid, position, facing, iscale, path)
end

function SerializerHelper.GmAddCrimeValue_Serializer(writer, value)
	SerializeBase.WritePrimitive(writer, value, writer.WriteInt32, 0)
end

function ClientToGameSceneGMDelegate:GmAddCrimeValue(value)
	return self:Invoke(69946581, SerializerHelper.GmAddCrimeValue_Serializer, value)
end

function SerializerHelper.GmAddAttractPoint_Serializer(writer, id, count, radius)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, count, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, radius, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmAddAttractPoint(id, count, radius)
	return self:Invoke(69946815, SerializerHelper.GmAddAttractPoint_Serializer, id, count, radius)
end

function SerializerHelper.TestRpcMethods_Serializer(writer, count, count1)
	SerializeBase.WritePrimitive(writer, count, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, count1, writer.WriteInt32, 0)
end

function ClientToGameSceneGMDelegate:TestRpcMethods(count, count1)
	return self:Invoke(69949423, SerializerHelper.TestRpcMethods_Serializer, count, count1)
end

function SerializerHelper.GmChangeWorldState_Serializer(writer, worldstateid, enable)
	SerializeBase.WritePrimitive(writer, worldstateid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

function ClientToGameSceneGMDelegate:GmChangeWorldState(worldstateid, enable)
	return self:Invoke(69954028, SerializerHelper.GmChangeWorldState_Serializer, worldstateid, enable)
end

function SerializerHelper.GmAddWeapon_Serializer(writer, weaponid)
	SerializeBase.WritePrimitive(writer, weaponid, writer.WriteUInt32, 0)
end

function ClientToGameSceneGMDelegate:GmAddWeapon(weaponid)
	return self:Invoke(69954706, SerializerHelper.GmAddWeapon_Serializer, weaponid)
end

function SerializerHelper.GmUseSkill_Serializer(writer, location, facing, targetid, unitpartindex, targetdestructibleid, skillid, skillinstanceid)
	SerializeBase.WriteStruct(writer, location, SerializeAuto.WriteUXVector3, "location")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, unitpartindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, targetdestructibleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, skillinstanceid, writer.WriteInt32, 0)
end

function ClientToGameSceneGMDelegate:GmUseSkill(location, facing, targetid, unitpartindex, targetdestructibleid, skillid, skillinstanceid)
	return self:Invoke(69963078, SerializerHelper.GmUseSkill_Serializer, location, facing, targetid, unitpartindex, targetdestructibleid, skillid, skillinstanceid)
end

function SerializerHelper.GmSpawnServerCrowd_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmSpawnServerCrowd()
	return self:Invoke(69964650, SerializerHelper.GmSpawnServerCrowd_Serializer)
end

function SerializerHelper.GmSetBasicAttr_Serializer(writer, attr, value)
	SerializeBase.WritePrimitive(writer, attr, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmSetBasicAttr(attr, value)
	return self:Invoke(69968876, SerializerHelper.GmSetBasicAttr_Serializer, attr, value)
end

function SerializerHelper.GmRefreshAllGadget_Serializer(writer)
	return
end

function ClientToGameSceneGMDelegate:GmRefreshAllGadget()
	return self:Invoke(69969545, SerializerHelper.GmRefreshAllGadget_Serializer)
end

function SerializerHelper.GmAddCreation_Serializer(writer, creationid, releaser, x, y, z, time)
	SerializeBase.WritePrimitive(writer, creationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, releaser, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, x, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, y, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, z, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, time, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmAddCreation(creationid, releaser, x, y, z, time)
	return self:Invoke(69982160, SerializerHelper.GmAddCreation_Serializer, creationid, releaser, x, y, z, time)
end

function SerializerHelper.GmSetOtherAttr_Serializer(writer, id, attr, value)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, attr, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmSetOtherAttr(id, attr, value)
	return self:Invoke(69988224, SerializerHelper.GmSetOtherAttr_Serializer, id, attr, value)
end

function SerializerHelper.GmSpawnVehicle_Serializer(writer, templateid, position, facing)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
end

function ClientToGameSceneGMDelegate:GmSpawnVehicle(templateid, position, facing)
	return self:Invoke(69996208, SerializerHelper.GmSpawnVehicle_Serializer, templateid, position, facing)
end

return ClientToGameSceneGMDelegate
