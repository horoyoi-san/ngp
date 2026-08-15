local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToGameSceneDelegate = invoker:New()

function ClientToGameSceneDelegate.Sender()
	return NetworkManager.LuaGameRpcProcessor
end

function SerializerHelper.AskCheckSpoonCondition_Serializer(writer, id, nodeid, graphid, param)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, graphid, writer.WriteInt32, 0)
	SerializeBase.WriteComplex(writer, param, SerializeAuto.WriteSpoonActionParam, "param", true)
end

function ClientToGameSceneDelegate:AskCheckSpoonCondition(id, nodeid, graphid, param)
	return self:Invoke(67007044, SerializerHelper.AskCheckSpoonCondition_Serializer, id, nodeid, graphid, param)
end

function SerializerHelper.AskItemDestructibleCreate_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteItemDestructibleData, "data", false)
end

function ClientToGameSceneDelegate:AskItemDestructibleCreate(data)
	return self:Invoke(67008359, SerializerHelper.AskItemDestructibleCreate_Serializer, data)
end

function SerializerHelper.ReportUnitExitPuppet_Serializer(writer, unitid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:ReportUnitExitPuppet(unitid)
	self:Notify(67008909, SerializerHelper.ReportUnitExitPuppet_Serializer, unitid)
end

function SerializerHelper.AskLoadingFinished_Serializer(writer, sceneid, sessionid)
	SerializeBase.WritePrimitive(writer, sceneid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, sessionid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskLoadingFinished(sceneid, sessionid)
	self:Notify(67011962, SerializerHelper.AskLoadingFinished_Serializer, sceneid, sessionid)
end

function SerializerHelper.AskLeaveHoldDestructibleObject_Serializer(writer, id, isthrow)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, isthrow, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskLeaveHoldDestructibleObject(id, isthrow)
	self:Notify(67013375, SerializerHelper.AskLeaveHoldDestructibleObject_Serializer, id, isthrow)
end

function SerializerHelper.AskEnemyStartFall_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskEnemyStartFall(pid)
	self:Notify(67016528, SerializerHelper.AskEnemyStartFall_Serializer, pid)
end

function SerializerHelper.ReportUnitFallGround_Serializer(writer, unitid, moveid, stiffid, stifftime, speed)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, moveid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, stiffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, stifftime, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, speed, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:ReportUnitFallGround(unitid, moveid, stiffid, stifftime, speed)
	self:Notify(67016630, SerializerHelper.ReportUnitFallGround_Serializer, unitid, moveid, stiffid, stifftime, speed)
end

function SerializerHelper.AskRemoveDestructibleHook_Serializer(writer, targetid, instanceid, hookcfgid)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, hookcfgid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskRemoveDestructibleHook(targetid, instanceid, hookcfgid)
	self:Notify(67026625, SerializerHelper.AskRemoveDestructibleHook_Serializer, targetid, instanceid, hookcfgid)
end

function SerializerHelper.AskEnemyInteraction_Serializer(writer, enemyid, index)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskEnemyInteraction(enemyid, index)
	self:Notify(67034686, SerializerHelper.AskEnemyInteraction_Serializer, enemyid, index)
end

function SerializerHelper.ReleaseOccupySceneItem_Serializer(writer, type, id, index)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:ReleaseOccupySceneItem(type, id, index)
	self:Notify(67035855, SerializerHelper.ReleaseOccupySceneItem_Serializer, type, id, index)
end

function SerializerHelper.AskPlotControlEnemy_Serializer(writer, taskid, nodeid, enemyid, notstopai)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, notstopai, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskPlotControlEnemy(taskid, nodeid, enemyid, notstopai)
	self:Notify(67037073, SerializerHelper.AskPlotControlEnemy_Serializer, taskid, nodeid, enemyid, notstopai)
end

function SerializerHelper.RecordDartScore_Serializer(writer, score, pos)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
end

function ClientToGameSceneDelegate:RecordDartScore(score, pos)
	return self:Invoke(67041455, SerializerHelper.RecordDartScore_Serializer, score, pos)
end

function SerializerHelper.AskPlayerOnMetro_Serializer(writer, metroid, ison)
	SerializeBase.WritePrimitive(writer, metroid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, ison, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskPlayerOnMetro(metroid, ison)
	return self:Invoke(67045516, SerializerHelper.AskPlayerOnMetro_Serializer, metroid, ison)
end

function SerializerHelper.AskAgentStartNpcDialog_Serializer(writer, agententityid, npcdialogid, dialogduration)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, npcdialogid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, dialogduration, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskAgentStartNpcDialog(agententityid, npcdialogid, dialogduration)
	self:Notify(67053679, SerializerHelper.AskAgentStartNpcDialog_Serializer, agententityid, npcdialogid, dialogduration)
end

function SerializerHelper.AskBroadcastNpcSignal_Serializer(writer, signalid)
	SerializeBase.WritePrimitive(writer, signalid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskBroadcastNpcSignal(signalid)
	self:Notify(67056182, SerializerHelper.AskBroadcastNpcSignal_Serializer, signalid)
end

function SerializerHelper.ReportSkillAnimationEnd_Serializer(writer, unitid, skillid, newskillid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, newskillid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:ReportSkillAnimationEnd(unitid, skillid, newskillid)
	self:Notify(67061586, SerializerHelper.ReportSkillAnimationEnd_Serializer, unitid, skillid, newskillid)
end

function SerializerHelper.AskAddDestructibleHook_Serializer(writer, hooktype, instanceid, hookcfgid, targettype, targetid)
	SerializeBase.WritePrimitive(writer, hooktype, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, hookcfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, targettype, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskAddDestructibleHook(hooktype, instanceid, hookcfgid, targettype, targetid)
	self:Notify(67062095, SerializerHelper.AskAddDestructibleHook_Serializer, hooktype, instanceid, hookcfgid, targettype, targetid)
end

function SerializerHelper.AskPickUpWeapon_Serializer(writer, destructibleid, notdirectlyequip)
	SerializeBase.WritePrimitive(writer, destructibleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, notdirectlyequip, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskPickUpWeapon(destructibleid, notdirectlyequip)
	return self:Invoke(67064074, SerializerHelper.AskPickUpWeapon_Serializer, destructibleid, notdirectlyequip)
end

function SerializerHelper.ReportUnitHitFly_Serializer(writer, defenderid, attackerid, hitflystiffid, stifftime)
	SerializeBase.WritePrimitive(writer, defenderid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, attackerid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, hitflystiffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, stifftime, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:ReportUnitHitFly(defenderid, attackerid, hitflystiffid, stifftime)
	self:Notify(67068254, SerializerHelper.ReportUnitHitFly_Serializer, defenderid, attackerid, hitflystiffid, stifftime)
end

function SerializerHelper.AskEnemyExistSceneRoom_Serializer(writer, sceneroomid, enemyid)
	SerializeBase.WritePrimitive(writer, sceneroomid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskEnemyExistSceneRoom(sceneroomid, enemyid)
	self:Notify(67072580, SerializerHelper.AskEnemyExistSceneRoom_Serializer, sceneroomid, enemyid)
end

function SerializerHelper.AskVehiclePlayAnimation_Serializer(writer, animation, specialanimation)
	SerializeBase.WriteComplex(writer, animation, SerializeAuto.WriteVehiclePartAnimation, "animation", false)
	SerializeBase.WriteComplex(writer, specialanimation, SerializeAuto.WriteVehicleSpecialPartAnimation, "specialanimation", false)
end

function ClientToGameSceneDelegate:AskVehiclePlayAnimation(animation, specialanimation)
	self:Notify(67072975, SerializerHelper.AskVehiclePlayAnimation_Serializer, animation, specialanimation)
end

function SerializerHelper.SetGameGroundPlayerPlayAgain_Serializer(writer, value)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:SetGameGroundPlayerPlayAgain(value)
	return self:Invoke(67074515, SerializerHelper.SetGameGroundPlayerPlayAgain_Serializer, value)
end

function SerializerHelper.AskCinemaInviteNpc_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskCinemaInviteNpc()
	return self:Invoke(67083392, SerializerHelper.AskCinemaInviteNpc_Serializer)
end

function SerializerHelper.AskLoadedInSameScene_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskLoadedInSameScene()
	self:Notify(67094232, SerializerHelper.AskLoadedInSameScene_Serializer)
end

function SerializerHelper.AskEnterHoldDestructibleObject_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskEnterHoldDestructibleObject(id)
	self:Notify(67095465, SerializerHelper.AskEnterHoldDestructibleObject_Serializer, id)
end

function SerializerHelper.AskGetTaskValue_Serializer(writer, id, key)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	writer:WriteString(key, false, "key", 256)
end

function ClientToGameSceneDelegate:AskGetTaskValue(id, key)
	return self:Invoke(67095977, SerializerHelper.AskGetTaskValue_Serializer, id, key)
end

function SerializerHelper.AskSpawnEnemyInNoNavRaid_Serializer(writer, taskid, position, facing, spoonenemyid, movingluaslot, bindrefname, ignoreaoi)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, spoonenemyid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, movingluaslot, writer.WriteUInt64, 0)
	writer:WriteString(bindrefname, false, "bindrefname", 256)
	SerializeBase.WritePrimitive(writer, ignoreaoi, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskSpawnEnemyInNoNavRaid(taskid, position, facing, spoonenemyid, movingluaslot, bindrefname, ignoreaoi)
	return self:Invoke(67098231, SerializerHelper.AskSpawnEnemyInNoNavRaid_Serializer, taskid, position, facing, spoonenemyid, movingluaslot, bindrefname, ignoreaoi)
end

function SerializerHelper.AskRideAgent_Serializer(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskRideAgent(agentid)
	return self:Invoke(67098432, SerializerHelper.AskRideAgent_Serializer, agentid)
end

function SerializerHelper.AskSpoonConditionComplete_Serializer(writer, flowindex, nodeindex, res)
	SerializeBase.WritePrimitive(writer, flowindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, nodeindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, res, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskSpoonConditionComplete(flowindex, nodeindex, res)
	return self:Invoke(67099069, SerializerHelper.AskSpoonConditionComplete_Serializer, flowindex, nodeindex, res)
end

function SerializerHelper.AskMassHideAreas_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskMassHideAreas()
	return self:Invoke(67099743, SerializerHelper.AskMassHideAreas_Serializer)
end

function SerializerHelper.AskLoadGameResCompleted_Serializer(writer, sceneid)
	SerializeBase.WritePrimitive(writer, sceneid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskLoadGameResCompleted(sceneid)
	self:Notify(67100352, SerializerHelper.AskLoadGameResCompleted_Serializer, sceneid)
end

function SerializerHelper.AskOnMetroEnterStation_Serializer(writer, metroids)
	SerializeBase.WriteList(writer, metroids, writer.WriteInt32, 0, "metroids", false, 32, nil)
end

function ClientToGameSceneDelegate:AskOnMetroEnterStation(metroids)
	self:Notify(67102043, SerializerHelper.AskOnMetroEnterStation_Serializer, metroids)
end

function SerializerHelper.AskEnemyUseClientSkillFail_Serializer(writer, enemyid, skillid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskEnemyUseClientSkillFail(enemyid, skillid)
	self:Notify(67102284, SerializerHelper.AskEnemyUseClientSkillFail_Serializer, enemyid, skillid)
end

function SerializerHelper.AskTaskGadgetsListLoadComplete_Serializer(writer, gadgetids)
	SerializeBase.WriteList(writer, gadgetids, writer.WriteUInt64, 0, "gadgetids", false, 256, nil)
end

function ClientToGameSceneDelegate:AskTaskGadgetsListLoadComplete(gadgetids)
	self:Notify(67105008, SerializerHelper.AskTaskGadgetsListLoadComplete_Serializer, gadgetids)
end

function SerializerHelper.AskInterruptSkillExecuteStiff_Serializer(writer, targetuid)
	SerializeBase.WritePrimitive(writer, targetuid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskInterruptSkillExecuteStiff(targetuid)
	return self:Invoke(67105495, SerializerHelper.AskInterruptSkillExecuteStiff_Serializer, targetuid)
end

function SerializerHelper.AskExistSceneRoom_Serializer(writer, sceneroomid, isvehicle, moveid)
	SerializeBase.WritePrimitive(writer, sceneroomid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, isvehicle, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, moveid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskExistSceneRoom(sceneroomid, isvehicle, moveid)
	return self:Invoke(67109434, SerializerHelper.AskExistSceneRoom_Serializer, sceneroomid, isvehicle, moveid)
end

function SerializerHelper.AskSetDgoVoxelSurface_Serializer(writer, surfaceid)
	SerializeBase.WritePrimitive(writer, surfaceid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskSetDgoVoxelSurface(surfaceid)
	self:Notify(67116023, SerializerHelper.AskSetDgoVoxelSurface_Serializer, surfaceid)
end

function SerializerHelper.AskVehicleCrashEnemy_Serializer(writer, enemyid, vehicleid, impulsedata)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, impulsedata, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskVehicleCrashEnemy(enemyid, vehicleid, impulsedata)
	self:Notify(67119411, SerializerHelper.AskVehicleCrashEnemy_Serializer, enemyid, vehicleid, impulsedata)
end

function SerializerHelper.AskStartBVBGame_Serializer(writer, chaosbattlenpcid, gamemode, enterfightposition)
	SerializeBase.WritePrimitive(writer, chaosbattlenpcid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, gamemode, writer.WriteByte, 0)
	SerializeBase.WriteStruct(writer, enterfightposition, SerializeAuto.WriteUXVector3, "enterfightposition")
end

function ClientToGameSceneDelegate:AskStartBVBGame(chaosbattlenpcid, gamemode, enterfightposition)
	return self:Invoke(67123939, SerializerHelper.AskStartBVBGame_Serializer, chaosbattlenpcid, gamemode, enterfightposition)
end

function SerializerHelper.AskSetClientLockTarget_Serializer(writer, targetid)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskSetClientLockTarget(targetid)
	self:Notify(67124539, SerializerHelper.AskSetClientLockTarget_Serializer, targetid)
end

function SerializerHelper.AskDoTruckNpcAction_Serializer(writer, instanceid, eventid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskDoTruckNpcAction(instanceid, eventid)
	return self:Invoke(67124809, SerializerHelper.AskDoTruckNpcAction_Serializer, instanceid, eventid)
end

function SerializerHelper.AskNpcStartEnterOrExitVehicle_Serializer(writer, syncdata)
	SerializeBase.WriteComplex(writer, syncdata, SerializeAuto.WriteNpcVehicleDriveStateInfo, "syncdata", false)
end

function ClientToGameSceneDelegate:AskNpcStartEnterOrExitVehicle(syncdata)
	self:Notify(67128345, SerializerHelper.AskNpcStartEnterOrExitVehicle_Serializer, syncdata)
end

function SerializerHelper.AskRemoveClientGameplayTag_Serializer(writer, agententityid, tagid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, tagid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskRemoveClientGameplayTag(agententityid, tagid)
	self:Notify(67131794, SerializerHelper.AskRemoveClientGameplayTag_Serializer, agententityid, tagid)
end

function SerializerHelper.ReportAgentDeathPerformanceFinished_Serializer(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:ReportAgentDeathPerformanceFinished(agententityid)
	self:Notify(67132720, SerializerHelper.ReportAgentDeathPerformanceFinished_Serializer, agententityid)
end

function SerializerHelper.AskSkillExecuteEnd_Serializer(writer, targetid, skillinstanceid)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skillinstanceid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskSkillExecuteEnd(targetid, skillinstanceid)
	return self:Invoke(67139214, SerializerHelper.AskSkillExecuteEnd_Serializer, targetid, skillinstanceid)
end

function SerializerHelper.AskBirdsGroupAlert_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskBirdsGroupAlert(id)
	self:Notify(67141159, SerializerHelper.AskBirdsGroupAlert_Serializer, id)
end

function SerializerHelper.AskSceneItemChangeState_Serializer(writer, type, id, statetype, state, totask)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, statetype, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, totask, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskSceneItemChangeState(type, id, statetype, state, totask)
	return self:Invoke(67142474, SerializerHelper.AskSceneItemChangeState_Serializer, type, id, statetype, state, totask)
end

function SerializerHelper.AskInterruptSkillExecute_Serializer(writer, targetuid)
	SerializeBase.WritePrimitive(writer, targetuid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskInterruptSkillExecute(targetuid)
	return self:Invoke(67143321, SerializerHelper.AskInterruptSkillExecute_Serializer, targetuid)
end

function SerializerHelper.AskSkillOpenShield_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillShieldData, "data", false)
end

function ClientToGameSceneDelegate:AskSkillOpenShield(data)
	self:Notify(67146706, SerializerHelper.AskSkillOpenShield_Serializer, data)
end

function SerializerHelper.ReportPoliceCrimeEvent_Serializer(writer, eid, agentid)
	SerializeBase.WritePrimitive(writer, eid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:ReportPoliceCrimeEvent(eid, agentid)
	self:Notify(67146776, SerializerHelper.ReportPoliceCrimeEvent_Serializer, eid, agentid)
end

function SerializerHelper.RecordDartEnd_Serializer(writer, scoreindex)
	SerializeBase.WritePrimitive(writer, scoreindex, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:RecordDartEnd(scoreindex)
	return self:Invoke(67146828, SerializerHelper.RecordDartEnd_Serializer, scoreindex)
end

function SerializerHelper.AskDoPosAction_Serializer(writer, nodeid)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskDoPosAction(nodeid)
	return self:Invoke(67147023, SerializerHelper.AskDoPosAction_Serializer, nodeid)
end

function SerializerHelper.ReportUnitFallGroundEnd_Serializer(writer, unitid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:ReportUnitFallGroundEnd(unitid)
	self:Notify(67151420, SerializerHelper.ReportUnitFallGroundEnd_Serializer, unitid)
end

function SerializerHelper.AskSwitchVehicleRadio_Serializer(writer, radioid)
	SerializeBase.WritePrimitive(writer, radioid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskSwitchVehicleRadio(radioid)
	self:Notify(67152077, SerializerHelper.AskSwitchVehicleRadio_Serializer, radioid)
end

function SerializerHelper.AskPlayerEnterWater_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskPlayerEnterWater()
	return self:Invoke(67152886, SerializerHelper.AskPlayerEnterWater_Serializer)
end

function SerializerHelper.ReportEnemyBattleMoveEnd_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:ReportEnemyBattleMoveEnd(pid)
	self:Notify(67154416, SerializerHelper.ReportEnemyBattleMoveEnd_Serializer, pid)
end

function SerializerHelper.AskEndPreparePlotEvent_Serializer(writer, eventid, agententityid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskEndPreparePlotEvent(eventid, agententityid)
	self:Notify(67155027, SerializerHelper.AskEndPreparePlotEvent_Serializer, eventid, agententityid)
end

function SerializerHelper.AskSceneItemSendSignal_Serializer(writer, type, id, signalname)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	writer:WriteString(signalname, false, "signalname", 256)
end

function ClientToGameSceneDelegate:AskSceneItemSendSignal(type, id, signalname)
	return self:Invoke(67159064, SerializerHelper.AskSceneItemSendSignal_Serializer, type, id, signalname)
end

function SerializerHelper.ReceivedNpcStim_Serializer(writer, templateid, instanceid, stimid)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, stimid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:ReceivedNpcStim(templateid, instanceid, stimid)
	return self:Invoke(67159283, SerializerHelper.ReceivedNpcStim_Serializer, templateid, instanceid, stimid)
end

function SerializerHelper.AskEnterVehicleIndoor_Serializer(writer, vehicleentityid)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskEnterVehicleIndoor(vehicleentityid)
	self:Notify(67159454, SerializerHelper.AskEnterVehicleIndoor_Serializer, vehicleentityid)
end

function SerializerHelper.AskFightGameSyncPlayerState_Serializer(writer, state, isai)
	SerializeBase.WriteComplex(writer, state, SerializeAuto.WriteFightGameStateInfo, "state", false)
	SerializeBase.WritePrimitive(writer, isai, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskFightGameSyncPlayerState(state, isai)
	self:Notify(67162524, SerializerHelper.AskFightGameSyncPlayerState_Serializer, state, isai)
end

function SerializerHelper.AakAetherAINpcUpdateMoveDatas_Serializer(writer, datas)
	SerializeBase.WriteList(writer, datas, SerializeBase.WriteComplexWrap(SerializeAuto.WriteClientNpcMoveData, "ClientNpcMoveData", false), nil, "datas", false, 1024, nil)
end

function ClientToGameSceneDelegate:AakAetherAINpcUpdateMoveDatas(datas)
	self:Notify(67173050, SerializerHelper.AakAetherAINpcUpdateMoveDatas_Serializer, datas)
end

function SerializerHelper.AskDiscardWeapon_Serializer(writer, index)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskDiscardWeapon(index)
	self:Notify(67174340, SerializerHelper.AskDiscardWeapon_Serializer, index)
end

function SerializerHelper.AskPutDownDestructibleObject_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskPutDownDestructibleObject(id)
	self:Notify(67175569, SerializerHelper.AskPutDownDestructibleObject_Serializer, id)
end

function SerializerHelper.AskBreakDestructibleObject_Serializer(writer, breaker, brokeninfos)
	SerializeBase.WritePrimitive(writer, breaker, writer.WriteUInt64, 0)
	SerializeBase.WriteComplex(writer, brokeninfos, SerializeAuto.WriteDestructibleBrokenInfo, "brokeninfos", false)
end

function ClientToGameSceneDelegate:AskBreakDestructibleObject(breaker, brokeninfos)
	return self:Invoke(67176799, SerializerHelper.AskBreakDestructibleObject_Serializer, breaker, brokeninfos)
end

function SerializerHelper.ReportLookAtTargetFinish_Serializer(writer, enemyid, actionid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, actionid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:ReportLookAtTargetFinish(enemyid, actionid)
	self:Notify(67182132, SerializerHelper.ReportLookAtTargetFinish_Serializer, enemyid, actionid)
end

function SerializerHelper.SetGameGroundPlayerReady_Serializer(writer, value)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:SetGameGroundPlayerReady(value)
	return self:Invoke(67184998, SerializerHelper.SetGameGroundPlayerReady_Serializer, value)
end

function SerializerHelper.AskSpoonClientActionComplete_Serializer(writer, flowindex, nodeindex, success, pos, portid, port)
	SerializeBase.WritePrimitive(writer, flowindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, nodeindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, success, writer.WriteBoolean, false)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
	SerializeBase.WritePrimitive(writer, portid, writer.WriteInt32, 0)
	SerializeBase.WriteList(writer, port, SerializeBase.WriteComplexWrap(SerializeAuto.WriteControlFlowDataCustom, "ControlFlowDataCustom", true), nil, "port", true, 256, nil)
end

function ClientToGameSceneDelegate:AskSpoonClientActionComplete(flowindex, nodeindex, success, pos, portid, port)
	return self:Invoke(67186828, SerializerHelper.AskSpoonClientActionComplete_Serializer, flowindex, nodeindex, success, pos, portid, port)
end

function SerializerHelper.ReportClientActionFinish_Serializer(writer, agententityid, token, success, failedreason)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, token, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, success, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, failedreason, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:ReportClientActionFinish(agententityid, token, success, failedreason)
	self:Notify(67189324, SerializerHelper.ReportClientActionFinish_Serializer, agententityid, token, success, failedreason)
end

function SerializerHelper.ReportEnemyMoveFinish_Serializer(writer, datas)
	SerializeBase.WriteList(writer, datas, SerializeBase.WriteStructWrap(SerializeAuto.WriteEnemyMoveFinishData, "datas"), nil, "datas", false, 1024, nil)
end

function ClientToGameSceneDelegate:ReportEnemyMoveFinish(datas)
	self:Notify(67190833, SerializerHelper.ReportEnemyMoveFinish_Serializer, datas)
end

function SerializerHelper.ActiveNpcStim_Serializer(writer, templateid, instanceid, stimid)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, stimid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:ActiveNpcStim(templateid, instanceid, stimid)
	return self:Invoke(67192821, SerializerHelper.ActiveNpcStim_Serializer, templateid, instanceid, stimid)
end

function SerializerHelper.AskAetherAISetVehicleStatus_Serializer(writer, vehicleinstanceid, status, reason)
	SerializeBase.WritePrimitive(writer, vehicleinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, status, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, reason, writer.WriteInt16, 0)
end

function ClientToGameSceneDelegate:AskAetherAISetVehicleStatus(vehicleinstanceid, status, reason)
	self:Notify(67196980, SerializerHelper.AskAetherAISetVehicleStatus_Serializer, vehicleinstanceid, status, reason)
end

function SerializerHelper.AskStopRideAgent_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskStopRideAgent()
	return self:Invoke(67197884, SerializerHelper.AskStopRideAgent_Serializer)
end

function SerializerHelper.AskBVBLockChaosBuffCandidates_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskBVBLockChaosBuffCandidates()
	return self:Invoke(67198041, SerializerHelper.AskBVBLockChaosBuffCandidates_Serializer)
end

function SerializerHelper.AskSetDgoNavSurface_Serializer(writer, surfaceid)
	SerializeBase.WritePrimitive(writer, surfaceid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskSetDgoNavSurface(surfaceid)
	self:Notify(67200742, SerializerHelper.AskSetDgoNavSurface_Serializer, surfaceid)
end

function SerializerHelper.AskDoNpcAction_Serializer(writer, templateid, instanceid, spoonid, taskid, eventid, index)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, spoonid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskDoNpcAction(templateid, instanceid, spoonid, taskid, eventid, index)
	return self:Invoke(67201021, SerializerHelper.AskDoNpcAction_Serializer, templateid, instanceid, spoonid, taskid, eventid, index)
end

function SerializerHelper.AskFinishHackingKeyFrame_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskFinishHackingKeyFrame(id)
	return self:Invoke(67202028, SerializerHelper.AskFinishHackingKeyFrame_Serializer, id)
end

function SerializerHelper.AskRaidVehicleConvertToAether_Serializer(writer, vehicleinstanceid)
	SerializeBase.WritePrimitive(writer, vehicleinstanceid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskRaidVehicleConvertToAether(vehicleinstanceid)
	return self:Invoke(67204636, SerializerHelper.AskRaidVehicleConvertToAether_Serializer, vehicleinstanceid)
end

function SerializerHelper.AskMultiCinemaQueryInfo_Serializer(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskMultiCinemaQueryInfo(locationid)
	return self:Invoke(67205756, SerializerHelper.AskMultiCinemaQueryInfo_Serializer, locationid)
end

function SerializerHelper.ReportUnitStandUp_Serializer(writer, unitid, stiffid, stifftime)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, stiffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, stifftime, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:ReportUnitStandUp(unitid, stiffid, stifftime)
	self:Notify(67206046, SerializerHelper.ReportUnitStandUp_Serializer, unitid, stiffid, stifftime)
end

function SerializerHelper.AskVehicleStuck_Serializer(writer, vehicleid)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskVehicleStuck(vehicleid)
	return self:Invoke(67208511, SerializerHelper.AskVehicleStuck_Serializer, vehicleid)
end

function SerializerHelper.AskTrailerHitchStateChanged_Serializer(writer, trailerentityid, targetentityid, targetdestructibleuniqueid, state)
	SerializeBase.WritePrimitive(writer, trailerentityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetentityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetdestructibleuniqueid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteByte, 0)
end

function ClientToGameSceneDelegate:AskTrailerHitchStateChanged(trailerentityid, targetentityid, targetdestructibleuniqueid, state)
	return self:Invoke(67209016, SerializerHelper.AskTrailerHitchStateChanged_Serializer, trailerentityid, targetentityid, targetdestructibleuniqueid, state)
end

function SerializerHelper.AskLeaveFeiSuoCrouch_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskLeaveFeiSuoCrouch()
	self:Notify(67211040, SerializerHelper.AskLeaveFeiSuoCrouch_Serializer)
end

function SerializerHelper.ReportBehaviorSeqStart_Serializer(writer, enemyid, pointindex, commandindex, type, cmd)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, pointindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, commandindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WriteStruct(writer, cmd, SerializeAuto.WriteBehaviorSeqCommand, "cmd")
end

function ClientToGameSceneDelegate:ReportBehaviorSeqStart(enemyid, pointindex, commandindex, type, cmd)
	self:Notify(67213664, SerializerHelper.ReportBehaviorSeqStart_Serializer, enemyid, pointindex, commandindex, type, cmd)
end

function SerializerHelper.AskPlayerChangePositionByScenePortal_Serializer(writer, bonfireuniqueid)
	SerializeBase.WritePrimitive(writer, bonfireuniqueid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskPlayerChangePositionByScenePortal(bonfireuniqueid)
	return self:Invoke(67214775, SerializerHelper.AskPlayerChangePositionByScenePortal_Serializer, bonfireuniqueid)
end

function SerializerHelper.AskVehicleStopMove_Serializer(writer, vehicleentityid)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskVehicleStopMove(vehicleentityid)
	self:Notify(67215811, SerializerHelper.AskVehicleStopMove_Serializer, vehicleentityid)
end

function SerializerHelper.ReleaseLinkOccupySceneItem_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:ReleaseLinkOccupySceneItem(id)
	return self:Invoke(67218323, SerializerHelper.ReleaseLinkOccupySceneItem_Serializer, id)
end

function SerializerHelper.AskDropBelonging_Serializer(writer, agententityid, belongings)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WriteList(writer, belongings, SerializeBase.WriteComplexWrap(SerializeAuto.WriteDropBelongingData, "DropBelongingData", false), nil, "belongings", false, 256, nil)
end

function ClientToGameSceneDelegate:AskDropBelonging(agententityid, belongings)
	self:Notify(67223056, SerializerHelper.AskDropBelonging_Serializer, agententityid, belongings)
end

function SerializerHelper.AskCancelTrackWildEnemyGroupInfo_Serializer(writer, groupspoonid)
	SerializeBase.WritePrimitive(writer, groupspoonid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskCancelTrackWildEnemyGroupInfo(groupspoonid)
	return self:Invoke(67223780, SerializerHelper.AskCancelTrackWildEnemyGroupInfo_Serializer, groupspoonid)
end

function SerializerHelper.TriggerDartTiming_Serializer(writer, timing)
	SerializeBase.WritePrimitive(writer, timing, writer.WriteByte, 0)
end

function ClientToGameSceneDelegate:TriggerDartTiming(timing)
	return self:Invoke(67226682, SerializerHelper.TriggerDartTiming_Serializer, timing)
end

function SerializerHelper.RecordDartId_Serializer(writer, dartid)
	SerializeBase.WritePrimitive(writer, dartid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:RecordDartId(dartid)
	return self:Invoke(67227348, SerializerHelper.RecordDartId_Serializer, dartid)
end

function SerializerHelper.AskReleaseUnitHookBoneSignal_Serializer(writer, hooker, hookee)
	SerializeBase.WritePrimitive(writer, hooker, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, hookee, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskReleaseUnitHookBoneSignal(hooker, hookee)
	self:Notify(67228763, SerializerHelper.AskReleaseUnitHookBoneSignal_Serializer, hooker, hookee)
end

function SerializerHelper.ReportEQSPos_Serializer(writer, uid, position)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
end

function ClientToGameSceneDelegate:ReportEQSPos(uid, position)
	self:Notify(67230336, SerializerHelper.ReportEQSPos_Serializer, uid, position)
end

function SerializerHelper.SyncStoryCoreClientDebugInfo_Serializer(writer, info)
	writer:WriteString(info, false, "info", 10240)
end

function ClientToGameSceneDelegate:SyncStoryCoreClientDebugInfo(info)
	self:Notify(67231041, SerializerHelper.SyncStoryCoreClientDebugInfo_Serializer, info)
end

function SerializerHelper.ReportSetActionGroup_Serializer(writer, uid, actiongroup)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, actiongroup, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:ReportSetActionGroup(uid, actiongroup)
	self:Notify(67231508, SerializerHelper.ReportSetActionGroup_Serializer, uid, actiongroup)
end

function SerializerHelper.ReportAddDestructibleHookFail_Serializer(writer, targetid, instanceid)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:ReportAddDestructibleHookFail(targetid, instanceid)
	self:Notify(67232925, SerializerHelper.ReportAddDestructibleHookFail_Serializer, targetid, instanceid)
end

function SerializerHelper.RefreshCleaningWashMaskInfo_Serializer(writer, uid, info)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt32, 0)
	SerializeBase.WriteList(writer, info, writer.WriteByte, 0, "info", false, 1048576, nil)
end

function ClientToGameSceneDelegate:RefreshCleaningWashMaskInfo(uid, info)
	self:Notify(67235713, SerializerHelper.RefreshCleaningWashMaskInfo_Serializer, uid, info)
end

function SerializerHelper.AskInteractCmd_Serializer(writer, data)
	SerializeBase.WriteStruct(writer, data, SerializeAuto.WriteInteractCmdData, "data")
end

function ClientToGameSceneDelegate:AskInteractCmd(data)
	self:Notify(67237255, SerializerHelper.AskInteractCmd_Serializer, data)
end

function SerializerHelper.AskHackingNpc_Serializer(writer, instanceid, index)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskHackingNpc(instanceid, index)
	return self:Invoke(67239192, SerializerHelper.AskHackingNpc_Serializer, instanceid, index)
end

function SerializerHelper.AskClientUseCommonSkill_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillUseData, "data", false)
end

function ClientToGameSceneDelegate:AskClientUseCommonSkill(data)
	return self:Invoke(67244103, SerializerHelper.AskClientUseCommonSkill_Serializer, data)
end

function SerializerHelper.AskPlotStopControlEnemy_Serializer(writer, taskid, nodeid, enemyid, pos, facing)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskPlotStopControlEnemy(taskid, nodeid, enemyid, pos, facing)
	self:Notify(67244598, SerializerHelper.AskPlotStopControlEnemy_Serializer, taskid, nodeid, enemyid, pos, facing)
end

function SerializerHelper.AskTriggerPlotEvent_Serializer(writer, eventid, agententityid, parameter)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, parameter, SerializeAuto.WriteStimEventParameter, "parameter")
end

function ClientToGameSceneDelegate:AskTriggerPlotEvent(eventid, agententityid, parameter)
	self:Notify(67247399, SerializerHelper.AskTriggerPlotEvent_Serializer, eventid, agententityid, parameter)
end

function SerializerHelper.AskRaiseDestructibleObject_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskRaiseDestructibleObject(id)
	self:Notify(67250946, SerializerHelper.AskRaiseDestructibleObject_Serializer, id)
end

function SerializerHelper.AskAddClientGameplayTag_Serializer(writer, agententityid, tagid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, tagid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskAddClientGameplayTag(agententityid, tagid)
	self:Notify(67253302, SerializerHelper.AskAddClientGameplayTag_Serializer, agententityid, tagid)
end

function SerializerHelper.AskAetherChangeQuality_Serializer(writer, charactercountquality, vehiclecountquality)
	SerializeBase.WritePrimitive(writer, charactercountquality, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, vehiclecountquality, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskAetherChangeQuality(charactercountquality, vehiclecountquality)
	self:Notify(67263253, SerializerHelper.AskAetherChangeQuality_Serializer, charactercountquality, vehiclecountquality)
end

function SerializerHelper.AskSkillCreationCreate_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillCreationData, "data", false)
end

function ClientToGameSceneDelegate:AskSkillCreationCreate(data)
	self:Notify(67263990, SerializerHelper.AskSkillCreationCreate_Serializer, data)
end

function SerializerHelper.AskSkillExecute_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillExecuteData, "data", false)
end

function ClientToGameSceneDelegate:AskSkillExecute(data)
	return self:Invoke(67267019, SerializerHelper.AskSkillExecute_Serializer, data)
end

function SerializerHelper.AskBVBLinkGameSelectTeam_Serializer(writer, pokemonids)
	SerializeBase.WriteList(writer, pokemonids, writer.WriteUInt64, 0, "pokemonids", false, 256, nil)
end

function ClientToGameSceneDelegate:AskBVBLinkGameSelectTeam(pokemonids)
	return self:Invoke(67270847, SerializerHelper.AskBVBLinkGameSelectTeam_Serializer, pokemonids)
end

function SerializerHelper.ChangeFoodIngredient_Serializer(writer, info, add)
	SerializeBase.WriteDict(writer, info, writer.WriteUInt32, writer.WriteUInt32, 0, "info", false, 32)
	SerializeBase.WritePrimitive(writer, add, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:ChangeFoodIngredient(info, add)
	return self:Invoke(67271577, SerializerHelper.ChangeFoodIngredient_Serializer, info, add)
end

function SerializerHelper.AskNpcBeKnockedDown_Serializer(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskNpcBeKnockedDown(agententityid)
	self:Notify(67272174, SerializerHelper.AskNpcBeKnockedDown_Serializer, agententityid)
end

function SerializerHelper.AskTeleportToParkingWaypoint_Serializer(writer, carshopid)
	SerializeBase.WritePrimitive(writer, carshopid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskTeleportToParkingWaypoint(carshopid)
	return self:Invoke(67273088, SerializerHelper.AskTeleportToParkingWaypoint_Serializer, carshopid)
end

function SerializerHelper.AskQDestructible_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskQDestructible(id)
	self:Notify(67274570, SerializerHelper.AskQDestructible_Serializer, id)
end

function SerializerHelper.AskNpcMovePositionRequest_Serializer(writer, npcid, position, facing, fail)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, fail, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskNpcMovePositionRequest(npcid, position, facing, fail)
	self:Notify(67277513, SerializerHelper.AskNpcMovePositionRequest_Serializer, npcid, position, facing, fail)
end

function SerializerHelper.AskBreakDestructibleObjects_Serializer(writer, breaker, brokeninfos)
	SerializeBase.WritePrimitive(writer, breaker, writer.WriteUInt64, 0)
	SerializeBase.WriteList(writer, brokeninfos, SerializeBase.WriteComplexWrap(SerializeAuto.WriteDestructibleBrokenInfo, "DestructibleBrokenInfo", false), nil, "brokeninfos", false, 1024, nil)
end

function ClientToGameSceneDelegate:AskBreakDestructibleObjects(breaker, brokeninfos)
	self:Notify(67282077, SerializerHelper.AskBreakDestructibleObjects_Serializer, breaker, brokeninfos)
end

function SerializerHelper.AskVehicleTriggerAiPathEvent_Serializer(writer, vehicleid, eventname)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	writer:WriteString(eventname, false, "eventname", 256)
end

function ClientToGameSceneDelegate:AskVehicleTriggerAiPathEvent(vehicleid, eventname)
	self:Notify(67288855, SerializerHelper.AskVehicleTriggerAiPathEvent_Serializer, vehicleid, eventname)
end

function SerializerHelper.AskGravityLand_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskGravityLand(pid)
	self:Notify(67291308, SerializerHelper.AskGravityLand_Serializer, pid)
end

function SerializerHelper.NpcInteractAction_Serializer(writer, instanceid, index, taskid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:NpcInteractAction(instanceid, index, taskid)
	return self:Invoke(67291360, SerializerHelper.NpcInteractAction_Serializer, instanceid, index, taskid)
end

function SerializerHelper.AskVehicleLeaveArea_Serializer(writer, identifyareaid, vehicleid)
	SerializeBase.WritePrimitive(writer, identifyareaid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskVehicleLeaveArea(identifyareaid, vehicleid)
	return self:Invoke(67292667, SerializerHelper.AskVehicleLeaveArea_Serializer, identifyareaid, vehicleid)
end

function SerializerHelper.AskDoPetAction_Serializer(writer, spoonid, index, isstart)
	SerializeBase.WritePrimitive(writer, spoonid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, isstart, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskDoPetAction(spoonid, index, isstart)
	return self:Invoke(67292698, SerializerHelper.AskDoPetAction_Serializer, spoonid, index, isstart)
end

function SerializerHelper.AskVehicleEnterArea_Serializer(writer, identifyareaid, vehicleid)
	SerializeBase.WritePrimitive(writer, identifyareaid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskVehicleEnterArea(identifyareaid, vehicleid)
	return self:Invoke(67293311, SerializerHelper.AskVehicleEnterArea_Serializer, identifyareaid, vehicleid)
end

function SerializerHelper.AskChaosNpcBeAttacked_Serializer(writer, instanceid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskChaosNpcBeAttacked(instanceid)
	self:Notify(67293753, SerializerHelper.AskChaosNpcBeAttacked_Serializer, instanceid)
end

function SerializerHelper.ReportVisibleUnitList_Serializer(writer, datas)
	SerializeBase.WriteList(writer, datas, SerializeBase.WriteStructWrap(SerializeAuto.WriteVisibilityReportData, "datas"), nil, "datas", false, 1024, nil)
end

function ClientToGameSceneDelegate:ReportVisibleUnitList(datas)
	self:Notify(67294052, SerializerHelper.ReportVisibleUnitList_Serializer, datas)
end

function SerializerHelper.AskChangeGoVehicleDriveState_Serializer(writer, vehicleentityid, drive, seatindex, gpsinfo)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, drive, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, seatindex, writer.WriteByte, 0)
	SerializeBase.WriteComplex(writer, gpsinfo, SerializeAuto.WriteRaidVehicleGpsInfo, "gpsinfo", true)
end

function ClientToGameSceneDelegate:AskChangeGoVehicleDriveState(vehicleentityid, drive, seatindex, gpsinfo)
	return self:Invoke(67297099, SerializerHelper.AskChangeGoVehicleDriveState_Serializer, vehicleentityid, drive, seatindex, gpsinfo)
end

function SerializerHelper.AskPlayersLoadRate_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskPlayersLoadRate()
	self:Notify(67297365, SerializerHelper.AskPlayersLoadRate_Serializer)
end

function SerializerHelper.AskAetherAIBorrowVehicle_Serializer(writer, vehicleinstanceid)
	SerializeBase.WritePrimitive(writer, vehicleinstanceid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskAetherAIBorrowVehicle(vehicleinstanceid)
	return self:Invoke(67297986, SerializerHelper.AskAetherAIBorrowVehicle_Serializer, vehicleinstanceid)
end

function SerializerHelper.AskVehicleHit_Serializer(writer, hitdata)
	SerializeBase.WriteComplex(writer, hitdata, SerializeAuto.WriteVehicleHitData, "hitdata", false)
end

function ClientToGameSceneDelegate:AskVehicleHit(hitdata)
	return self:Invoke(67298863, SerializerHelper.AskVehicleHit_Serializer, hitdata)
end

function SerializerHelper.ReportLookAtPositionFinish_Serializer(writer, enemyid, actionid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, actionid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:ReportLookAtPositionFinish(enemyid, actionid)
	self:Notify(67306679, SerializerHelper.ReportLookAtPositionFinish_Serializer, enemyid, actionid)
end

function SerializerHelper.AskCinemaSpawnNpc_Serializer(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskCinemaSpawnNpc(locationid)
	return self:Invoke(67308174, SerializerHelper.AskCinemaSpawnNpc_Serializer, locationid)
end

function SerializerHelper.AskVehicleSkillDamage_Serializer(writer, vehicleid, data)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, data, SerializeAuto.WriteVehicleSkillDamageData, "data")
end

function ClientToGameSceneDelegate:AskVehicleSkillDamage(vehicleid, data)
	self:Notify(67309947, SerializerHelper.AskVehicleSkillDamage_Serializer, vehicleid, data)
end

function SerializerHelper.ReportEnemyDetectEvent_Serializer(writer, detecteventid)
	SerializeBase.WritePrimitive(writer, detecteventid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:ReportEnemyDetectEvent(detecteventid)
	self:Notify(67311256, SerializerHelper.ReportEnemyDetectEvent_Serializer, detecteventid)
end

function SerializerHelper.AskFightGameReady_Serializer(writer, isai)
	SerializeBase.WritePrimitive(writer, isai, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskFightGameReady(isai)
	return self:Invoke(67316543, SerializerHelper.AskFightGameReady_Serializer, isai)
end

function SerializerHelper.RaceSpeedFinish_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:RaceSpeedFinish()
	return self:Invoke(67318577, SerializerHelper.RaceSpeedFinish_Serializer)
end

function SerializerHelper.AskRemoveTimelineDangerArea_Serializer(writer, center, extends, rotation)
	SerializeBase.WriteStruct(writer, center, SerializeAuto.WriteUXVector3, "center")
	SerializeBase.WriteStruct(writer, extends, SerializeAuto.WriteUXVector3, "extends")
	SerializeBase.WriteStruct(writer, rotation, SerializeAuto.WriteUXVector3, "rotation")
end

function ClientToGameSceneDelegate:AskRemoveTimelineDangerArea(center, extends, rotation)
	self:Notify(67318752, SerializerHelper.AskRemoveTimelineDangerArea_Serializer, center, extends, rotation)
end

function SerializerHelper.AskPlayerFinishEnterOrExitVehicle_Serializer(writer, syncdata)
	SerializeBase.WriteComplex(writer, syncdata, SerializeAuto.WritePlayerVehicleDriveStateInfo, "syncdata", false)
end

function ClientToGameSceneDelegate:AskPlayerFinishEnterOrExitVehicle(syncdata)
	self:Notify(67322523, SerializerHelper.AskPlayerFinishEnterOrExitVehicle_Serializer, syncdata)
end

function SerializerHelper.AskFightGameEnterRoleStage_Serializer(writer, initroleid, isai, aiinitroleid)
	SerializeBase.WritePrimitive(writer, initroleid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isai, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, aiinitroleid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskFightGameEnterRoleStage(initroleid, isai, aiinitroleid)
	return self:Invoke(67323381, SerializerHelper.AskFightGameEnterRoleStage_Serializer, initroleid, isai, aiinitroleid)
end

function SerializerHelper.ReportCreationReachMaxRange_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:ReportCreationReachMaxRange(id)
	self:Notify(67329901, SerializerHelper.ReportCreationReachMaxRange_Serializer, id)
end

function SerializerHelper.AskCinemaBuyTicket_Serializer(writer, locationid, movieid, cinemanpcid, companionnpcid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, movieid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, cinemanpcid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, companionnpcid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskCinemaBuyTicket(locationid, movieid, cinemanpcid, companionnpcid)
	return self:Invoke(67330715, SerializerHelper.AskCinemaBuyTicket_Serializer, locationid, movieid, cinemanpcid, companionnpcid)
end

function SerializerHelper.AskCreationTouchMultiPlayer_Serializer(writer, data)
	SerializeBase.WriteList(writer, data, SerializeBase.WriteStructWrap(SerializeAuto.WriteCreationHitData, "data"), nil, "data", false, 256, nil)
end

function ClientToGameSceneDelegate:AskCreationTouchMultiPlayer(data)
	self:Notify(67336582, SerializerHelper.AskCreationTouchMultiPlayer_Serializer, data)
end

function SerializerHelper.AskBVBDebugSelectNpcFightPokemonList_Serializer(writer, selectpokemondatas)
	SerializeBase.WriteList(writer, selectpokemondatas, SerializeBase.WriteComplexWrap(SerializeAuto.WriteDebugNpcBvbSelectPokemonData, "DebugNpcBvbSelectPokemonData", false), nil, "selectpokemondatas", false, 256, nil)
end

function ClientToGameSceneDelegate:AskBVBDebugSelectNpcFightPokemonList(selectpokemondatas)
	return self:Invoke(67341642, SerializerHelper.AskBVBDebugSelectNpcFightPokemonList_Serializer, selectpokemondatas)
end

function SerializerHelper.AskEndTaxiTeleport_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskEndTaxiTeleport()
	return self:Invoke(67346577, SerializerHelper.AskEndTaxiTeleport_Serializer)
end

function SerializerHelper.AskVehicleHorn_Serializer(writer, entityid, play)
	SerializeBase.WritePrimitive(writer, entityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, play, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskVehicleHorn(entityid, play)
	self:Notify(67348179, SerializerHelper.AskVehicleHorn_Serializer, entityid, play)
end

function SerializerHelper.AskThrowWeaponInHand_Serializer(writer, position, face)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, face, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskThrowWeaponInHand(position, face)
	return self:Invoke(67348887, SerializerHelper.AskThrowWeaponInHand_Serializer, position, face)
end

function SerializerHelper.AskClearVehicleSpawnArea_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskClearVehicleSpawnArea()
	self:Notify(67351418, SerializerHelper.AskClearVehicleSpawnArea_Serializer)
end

function SerializerHelper.AskPickDelayDrop_Serializer(writer, delaydropid)
	SerializeBase.WritePrimitive(writer, delaydropid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskPickDelayDrop(delaydropid)
	self:Notify(67351745, SerializerHelper.AskPickDelayDrop_Serializer, delaydropid)
end

function SerializerHelper.AskSkillTimeCurve_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillTimeCurveData, "data", false)
end

function ClientToGameSceneDelegate:AskSkillTimeCurve(data)
	self:Notify(67355864, SerializerHelper.AskSkillTimeCurve_Serializer, data)
end

function SerializerHelper.AskFishDestructibleRemove_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskFishDestructibleRemove(id)
	self:Notify(67355975, SerializerHelper.AskFishDestructibleRemove_Serializer, id)
end

function SerializerHelper.DebugClientNpcDebugDensityStatistics_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:DebugClientNpcDebugDensityStatistics()
	return self:Invoke(67360553, SerializerHelper.DebugClientNpcDebugDensityStatistics_Serializer)
end

function SerializerHelper.AskTaxiAccelerate_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskTaxiAccelerate()
	return self:Invoke(67360678, SerializerHelper.AskTaxiAccelerate_Serializer)
end

function SerializerHelper.AskEnemyEndItemDropList_Serializer(writer, infos)
	SerializeBase.WriteList(writer, infos, SerializeBase.WriteStructWrap(SerializeAuto.WriteEndItemDropInfo, "infos"), nil, "infos", false, 256, nil)
end

function ClientToGameSceneDelegate:AskEnemyEndItemDropList(infos)
	self:Notify(67362408, SerializerHelper.AskEnemyEndItemDropList_Serializer, infos)
end

function SerializerHelper.EnterBowlingZone_Serializer(writer, gadgetuid, gametype, agentid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, gametype, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:EnterBowlingZone(gadgetuid, gametype, agentid)
	return self:Invoke(67363519, SerializerHelper.EnterBowlingZone_Serializer, gadgetuid, gametype, agentid)
end

function SerializerHelper.AskCinemaEndMovie_Serializer(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskCinemaEndMovie(locationid)
	return self:Invoke(67363678, SerializerHelper.AskCinemaEndMovie_Serializer, locationid)
end

function SerializerHelper.AskMetroHitEnd_Serializer(writer, targetid)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskMetroHitEnd(targetid)
	return self:Invoke(67373222, SerializerHelper.AskMetroHitEnd_Serializer, targetid)
end

function SerializerHelper.AskSkillUseWeaponDurability_Serializer(writer, skillid, triggerindex)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, triggerindex, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskSkillUseWeaponDurability(skillid, triggerindex)
	self:Notify(67374688, SerializerHelper.AskSkillUseWeaponDurability_Serializer, skillid, triggerindex)
end

function SerializerHelper.AskSwitchSpirit_Serializer(writer, spiritid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskSwitchSpirit(spiritid)
	return self:Invoke(67375035, SerializerHelper.AskSwitchSpirit_Serializer, spiritid)
end

function SerializerHelper.AskSelectChaosObject_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskSelectChaosObject(id)
	return self:Invoke(67376535, SerializerHelper.AskSelectChaosObject_Serializer, id)
end

function SerializerHelper.AskGetAllMetroInfos_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskGetAllMetroInfos()
	return self:Invoke(67377199, SerializerHelper.AskGetAllMetroInfos_Serializer)
end

function SerializerHelper.AskCaptureAgentFinished_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskCaptureAgentFinished(pid)
	self:Notify(67377605, SerializerHelper.AskCaptureAgentFinished_Serializer, pid)
end

function SerializerHelper.RecordAgentBehavior_Serializer(writer, id, agenttype, behavior)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agenttype, writer.WriteByte, 0)
	writer:WriteString(behavior, false, "behavior", 256)
end

function ClientToGameSceneDelegate:RecordAgentBehavior(id, agenttype, behavior)
	return self:Invoke(67377834, SerializerHelper.RecordAgentBehavior_Serializer, id, agenttype, behavior)
end

function SerializerHelper.AskLoadSceneCompleted_Serializer(writer, sceneid, sessionid)
	SerializeBase.WritePrimitive(writer, sceneid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, sessionid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskLoadSceneCompleted(sceneid, sessionid)
	self:Notify(67378136, SerializerHelper.AskLoadSceneCompleted_Serializer, sceneid, sessionid)
end

function SerializerHelper.AskSwitchSpiritComplete_Serializer(writer, switchspiritid)
	SerializeBase.WritePrimitive(writer, switchspiritid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskSwitchSpiritComplete(switchspiritid)
	return self:Invoke(67379649, SerializerHelper.AskSwitchSpiritComplete_Serializer, switchspiritid)
end

function SerializerHelper.AskAetherAICreateRaidVehicleAndClaimSeatByAether_Serializer(writer, vehicleinstanceid, seatindices)
	SerializeBase.WritePrimitive(writer, vehicleinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WriteList(writer, seatindices, writer.WriteByte, 0, "seatindices", false, 32, nil)
end

function ClientToGameSceneDelegate:AskAetherAICreateRaidVehicleAndClaimSeatByAether(vehicleinstanceid, seatindices)
	return self:Invoke(67382522, SerializerHelper.AskAetherAICreateRaidVehicleAndClaimSeatByAether_Serializer, vehicleinstanceid, seatindices)
end

function SerializerHelper.AskUpdateVehiclesArchive_Serializer(writer, datas)
	SerializeBase.WriteList(writer, datas, SerializeBase.WriteComplexWrap(SerializeAuto.WriteSimpleVehicleSyncData, "SimpleVehicleSyncData", false), nil, "datas", false, 256, nil)
end

function ClientToGameSceneDelegate:AskUpdateVehiclesArchive(datas)
	self:Notify(67384649, SerializerHelper.AskUpdateVehiclesArchive_Serializer, datas)
end

function SerializerHelper.AskFightGameChangeRole_Serializer(writer, roleid, isai)
	SerializeBase.WritePrimitive(writer, roleid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isai, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskFightGameChangeRole(roleid, isai)
	return self:Invoke(67387168, SerializerHelper.AskFightGameChangeRole_Serializer, roleid, isai)
end

function SerializerHelper.AskCreateDynamicGadget_Serializer(writer, pathid, position, facing)
	SerializeBase.WritePrimitive(writer, pathid, writer.WriteInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WriteStruct(writer, facing, SerializeAuto.WriteUXVector3, "facing")
end

function ClientToGameSceneDelegate:AskCreateDynamicGadget(pathid, position, facing)
	return self:Invoke(67389088, SerializerHelper.AskCreateDynamicGadget_Serializer, pathid, position, facing)
end

function SerializerHelper.ReportPreSwitchSpiritFinish_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:ReportPreSwitchSpiritFinish()
	return self:Invoke(67393372, SerializerHelper.ReportPreSwitchSpiritFinish_Serializer)
end

function SerializerHelper.AskPredictHitPerformance_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteHitPredictData, "data", false)
end

function ClientToGameSceneDelegate:AskPredictHitPerformance(data)
	return self:Invoke(67394158, SerializerHelper.AskPredictHitPerformance_Serializer, data)
end

function SerializerHelper.ReportCanAssassinateEnemies_Serializer(writer, enemyids)
	SerializeBase.WriteList(writer, enemyids, writer.WriteUInt64, 0, "enemyids", false, 256, nil)
end

function ClientToGameSceneDelegate:ReportCanAssassinateEnemies(enemyids)
	self:Notify(67396883, SerializerHelper.ReportCanAssassinateEnemies_Serializer, enemyids)
end

function SerializerHelper.AskChangeCustomVehicleIntervalRatio_Serializer(writer, ratio)
	SerializeBase.WritePrimitive(writer, ratio, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskChangeCustomVehicleIntervalRatio(ratio)
	self:Notify(67397497, SerializerHelper.AskChangeCustomVehicleIntervalRatio_Serializer, ratio)
end

function SerializerHelper.AskEnemyFallGround_Serializer(writer, pid, speed)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, speed, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskEnemyFallGround(pid, speed)
	self:Notify(67399598, SerializerHelper.AskEnemyFallGround_Serializer, pid, speed)
end

function SerializerHelper.AskVehicleHitEnd_Serializer(writer, targetid)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskVehicleHitEnd(targetid)
	return self:Invoke(67406281, SerializerHelper.AskVehicleHitEnd_Serializer, targetid)
end

function SerializerHelper.AskChangeAetherVehicleDensity_Serializer(writer, ratio, forcerefresh)
	SerializeBase.WritePrimitive(writer, ratio, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, forcerefresh, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskChangeAetherVehicleDensity(ratio, forcerefresh)
	self:Notify(67406557, SerializerHelper.AskChangeAetherVehicleDensity_Serializer, ratio, forcerefresh)
end

function SerializerHelper.AskResetGlobalTimeSlow_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskResetGlobalTimeSlow()
	return self:Invoke(67407557, SerializerHelper.AskResetGlobalTimeSlow_Serializer)
end

function SerializerHelper.ReportBehaviorSeqFinish_Serializer(writer, enemyid, type)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
end

function ClientToGameSceneDelegate:ReportBehaviorSeqFinish(enemyid, type)
	self:Notify(67412839, SerializerHelper.ReportBehaviorSeqFinish_Serializer, enemyid, type)
end

function SerializerHelper.AskSyncDestructibleSyncInfos_Serializer(writer, syncinfos)
	SerializeBase.WriteList(writer, syncinfos, SerializeBase.WriteComplexWrap(SerializeAuto.WriteDestructibleSyncInfo, "DestructibleSyncInfo", false), nil, "syncinfos", false, 1024, nil)
end

function ClientToGameSceneDelegate:AskSyncDestructibleSyncInfos(syncinfos)
	self:Notify(67413737, SerializerHelper.AskSyncDestructibleSyncInfos_Serializer, syncinfos)
end

function SerializerHelper.AskVehicleEnterGetOffArea_Serializer(writer, areaid, vehicleid)
	SerializeBase.WritePrimitive(writer, areaid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskVehicleEnterGetOffArea(areaid, vehicleid)
	self:Notify(67415413, SerializerHelper.AskVehicleEnterGetOffArea_Serializer, areaid, vehicleid)
end

function SerializerHelper.ReportBehaviorSeqStartList_Serializer(writer, infos)
	SerializeBase.WriteList(writer, infos, SerializeBase.WriteStructWrap(SerializeAuto.WriteReportBehaviorSeqStartInfo, "infos"), nil, "infos", false, 1024, nil)
end

function ClientToGameSceneDelegate:ReportBehaviorSeqStartList(infos)
	self:Notify(67416095, SerializerHelper.ReportBehaviorSeqStartList_Serializer, infos)
end

function SerializerHelper.AskCinemaQueryInfo_Serializer(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskCinemaQueryInfo(locationid)
	return self:Invoke(67416493, SerializerHelper.AskCinemaQueryInfo_Serializer, locationid)
end

function SerializerHelper.AskControlPowerHoldEnemyFallGround_Serializer(writer, enemyid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskControlPowerHoldEnemyFallGround(enemyid)
	return self:Invoke(67419674, SerializerHelper.AskControlPowerHoldEnemyFallGround_Serializer, enemyid)
end

function SerializerHelper.AskFinishBelongingUsage_Serializer(writer, instanceid, usageid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, usageid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskFinishBelongingUsage(instanceid, usageid)
	self:Notify(67420190, SerializerHelper.AskFinishBelongingUsage_Serializer, instanceid, usageid)
end

function SerializerHelper.AskPlayerOnBVBFinish_Serializer(writer, isreply)
	SerializeBase.WritePrimitive(writer, isreply, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskPlayerOnBVBFinish(isreply)
	return self:Invoke(67422219, SerializerHelper.AskPlayerOnBVBFinish_Serializer, isreply)
end

function SerializerHelper.AskFixPosOnPlatform_Serializer(writer, pos, facing)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskFixPosOnPlatform(pos, facing)
	self:Notify(67422525, SerializerHelper.AskFixPosOnPlatform_Serializer, pos, facing)
end

function SerializerHelper.BroadcastBowlingClientInfo_Serializer(writer, gadgetuid, syncinfo)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WriteComplex(writer, syncinfo, SerializeAuto.WriteBowlingClientInfo, "syncinfo", false)
end

function ClientToGameSceneDelegate:BroadcastBowlingClientInfo(gadgetuid, syncinfo)
	return self:Invoke(67423021, SerializerHelper.BroadcastBowlingClientInfo_Serializer, gadgetuid, syncinfo)
end

function SerializerHelper.AskMoveDestructibleObjects_Serializer(writer, ids, positions, facings)
	SerializeBase.WriteList(writer, ids, writer.WriteUInt64, 0, "ids", false, 1024, nil)
	SerializeBase.WriteList(writer, positions, SerializeBase.WriteStructWrap(SerializeAuto.WriteUXVector3, "positions"), nil, "positions", false, 1024, nil)
	SerializeBase.WriteList(writer, facings, SerializeBase.WriteStructWrap(SerializeAuto.WriteUXVector3, "facings"), nil, "facings", false, 1024, nil)
end

function ClientToGameSceneDelegate:AskMoveDestructibleObjects(ids, positions, facings)
	self:Notify(67423338, SerializerHelper.AskMoveDestructibleObjects_Serializer, ids, positions, facings)
end

function SerializerHelper.AskSceneItemRecordValue_Serializer(writer, type, id, valuename, value, totask, setonceonly)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, valuename, writer.WriteInt32, 0)
	writer:WriteString(value, false, "value", 1024)
	SerializeBase.WritePrimitive(writer, totask, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, setonceonly, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskSceneItemRecordValue(type, id, valuename, value, totask, setonceonly)
	return self:Invoke(67427170, SerializerHelper.AskSceneItemRecordValue_Serializer, type, id, valuename, value, totask, setonceonly)
end

function SerializerHelper.AskVehicleDeadEnd_Serializer(writer, vehicleentityid, deadposition)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, deadposition, SerializeAuto.WriteUXVector3, "deadposition")
end

function ClientToGameSceneDelegate:AskVehicleDeadEnd(vehicleentityid, deadposition)
	self:Notify(67430855, SerializerHelper.AskVehicleDeadEnd_Serializer, vehicleentityid, deadposition)
end

function SerializerHelper.AskDrinkMilk_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskDrinkMilk()
	return self:Invoke(67435111, SerializerHelper.AskDrinkMilk_Serializer)
end

function SerializerHelper.AskBuyCinemaTicket_Serializer(writer, cinemaid, movieid, cinemanpcid, companionnpcid)
	SerializeBase.WritePrimitive(writer, cinemaid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, movieid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, cinemanpcid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, companionnpcid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskBuyCinemaTicket(cinemaid, movieid, cinemanpcid, companionnpcid)
	return self:Invoke(67435562, SerializerHelper.AskBuyCinemaTicket_Serializer, cinemaid, movieid, cinemanpcid, companionnpcid)
end

function SerializerHelper.AskAgentStopVehicle_Serializer(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskAgentStopVehicle(agententityid)
	self:Notify(67436711, SerializerHelper.AskAgentStopVehicle_Serializer, agententityid)
end

function SerializerHelper.AskPickupBasketball_Serializer(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskPickupBasketball(gadgetuid)
	return self:Invoke(67437976, SerializerHelper.AskPickupBasketball_Serializer, gadgetuid)
end

function SerializerHelper.AskSkipSpoonPlot_Serializer(writer, flowindex, nodeid, pos)
	SerializeBase.WritePrimitive(writer, flowindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
end

function ClientToGameSceneDelegate:AskSkipSpoonPlot(flowindex, nodeid, pos)
	return self:Invoke(67439089, SerializerHelper.AskSkipSpoonPlot_Serializer, flowindex, nodeid, pos)
end

function SerializerHelper.AskLeaveMoveGround_Serializer(writer, pid, movegroundid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, movegroundid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskLeaveMoveGround(pid, movegroundid)
	return self:Invoke(67441479, SerializerHelper.AskLeaveMoveGround_Serializer, pid, movegroundid)
end

function SerializerHelper.ReportPlayActionWithLayerFinish_Serializer(writer, enemyid, actionid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, actionid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:ReportPlayActionWithLayerFinish(enemyid, actionid)
	self:Notify(67445983, SerializerHelper.ReportPlayActionWithLayerFinish_Serializer, enemyid, actionid)
end

function SerializerHelper.AskSpoonClientAttack_Serializer(writer, taskid, hurthp)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, hurthp, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskSpoonClientAttack(taskid, hurthp)
	self:Notify(67452648, SerializerHelper.AskSpoonClientAttack_Serializer, taskid, hurthp)
end

function SerializerHelper.AskNpcMovePosition_Serializer(writer, npcid, position, facing)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskNpcMovePosition(npcid, position, facing)
	self:Notify(67457031, SerializerHelper.AskNpcMovePosition_Serializer, npcid, position, facing)
end

function SerializerHelper.AskGadgetDoorTransfer_Serializer(writer, id, from, to, position)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, from, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, to, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
end

function ClientToGameSceneDelegate:AskGadgetDoorTransfer(id, from, to, position)
	self:Notify(67458333, SerializerHelper.AskGadgetDoorTransfer_Serializer, id, from, to, position)
end

function SerializerHelper.AskDoInteractBindPerformance_Serializer(writer, gadgetid, bindid, interactactiontype, index, dynamicbinditem, starttime, delaytime)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, bindid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, interactactiontype, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, dynamicbinditem, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, starttime, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, delaytime, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskDoInteractBindPerformance(gadgetid, bindid, interactactiontype, index, dynamicbinditem, starttime, delaytime)
	self:Notify(67459809, SerializerHelper.AskDoInteractBindPerformance_Serializer, gadgetid, bindid, interactactiontype, index, dynamicbinditem, starttime, delaytime)
end

function SerializerHelper.AskBVBGetReady_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskBVBGetReady()
	return self:Invoke(67459847, SerializerHelper.AskBVBGetReady_Serializer)
end

function SerializerHelper.AskSaveActionGroup_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskSaveActionGroup(id)
	self:Notify(67459886, SerializerHelper.AskSaveActionGroup_Serializer, id)
end

function SerializerHelper.AskSetEmotionByStateTree_Serializer(writer, agententityid, emotion, state)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, emotion, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskSetEmotionByStateTree(agententityid, emotion, state)
	self:Notify(67460661, SerializerHelper.AskSetEmotionByStateTree_Serializer, agententityid, emotion, state)
end

function SerializerHelper.AskAgentStartNpcSound_Serializer(writer, agententityid, libraryid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, libraryid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskAgentStartNpcSound(agententityid, libraryid)
	self:Notify(67461875, SerializerHelper.AskAgentStartNpcSound_Serializer, agententityid, libraryid)
end

function SerializerHelper.AskFreeEmotionByStateTree_Serializer(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskFreeEmotionByStateTree(agententityid)
	self:Notify(67462082, SerializerHelper.AskFreeEmotionByStateTree_Serializer, agententityid)
end

function SerializerHelper.AskRestaurantInviteNpc_Serializer(writer, restaurantid)
	SerializeBase.WritePrimitive(writer, restaurantid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskRestaurantInviteNpc(restaurantid)
	self:Notify(67463377, SerializerHelper.AskRestaurantInviteNpc_Serializer, restaurantid)
end

function SerializerHelper.ReportTurnToPositionFinish_Serializer(writer, enemyid, actionid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, actionid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:ReportTurnToPositionFinish(enemyid, actionid)
	self:Notify(67467776, SerializerHelper.ReportTurnToPositionFinish_Serializer, enemyid, actionid)
end

function SerializerHelper.AskDestroyDestructibleObject_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskDestroyDestructibleObject(id)
	self:Notify(67470644, SerializerHelper.AskDestroyDestructibleObject_Serializer, id)
end

function SerializerHelper.AskMoveDestructibleObject_Serializer(writer, id, position, facing)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WriteStruct(writer, facing, SerializeAuto.WriteUXVector3, "facing")
end

function ClientToGameSceneDelegate:AskMoveDestructibleObject(id, position, facing)
	self:Notify(67473946, SerializerHelper.AskMoveDestructibleObject_Serializer, id, position, facing)
end

function SerializerHelper.AskControlAgent_Serializer(writer, agententityid, reason)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, reason, writer.WriteByte, 0)
end

function ClientToGameSceneDelegate:AskControlAgent(agententityid, reason)
	self:Notify(67477777, SerializerHelper.AskControlAgent_Serializer, agententityid, reason)
end

function SerializerHelper.CheckCanOccupySceneItem_Serializer(writer, type, id, index, onlycheck)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, onlycheck, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:CheckCanOccupySceneItem(type, id, index, onlycheck)
	return self:Invoke(67478318, SerializerHelper.CheckCanOccupySceneItem_Serializer, type, id, index, onlycheck)
end

function SerializerHelper.ReportCreationVehicleEnterOrLeaves_Serializer(writer, datas)
	SerializeBase.WriteList(writer, datas, SerializeBase.WriteStructWrap(SerializeAuto.WriteCreationEnterLeave, "datas"), nil, "datas", false, 256, nil)
end

function ClientToGameSceneDelegate:ReportCreationVehicleEnterOrLeaves(datas)
	self:Notify(67481829, SerializerHelper.ReportCreationVehicleEnterOrLeaves_Serializer, datas)
end

function SerializerHelper.AskEndTaxiNavigate_Serializer(writer, teleport, skipped, totaldis)
	SerializeBase.WritePrimitive(writer, teleport, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, skipped, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, totaldis, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskEndTaxiNavigate(teleport, skipped, totaldis)
	return self:Invoke(67485381, SerializerHelper.AskEndTaxiNavigate_Serializer, teleport, skipped, totaldis)
end

function SerializerHelper.ReportAgentPlatformValidateInfo_Serializer(writer, agentid, mobileplatformid, pos, forward)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, mobileplatformid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
	SerializeBase.WriteStruct(writer, forward, SerializeAuto.WriteUXVector3, "forward")
end

function ClientToGameSceneDelegate:ReportAgentPlatformValidateInfo(agentid, mobileplatformid, pos, forward)
	self:Notify(67486642, SerializerHelper.ReportAgentPlatformValidateInfo_Serializer, agentid, mobileplatformid, pos, forward)
end

function SerializerHelper.DebugForceSyncAetherVehicleDebugInfo_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:DebugForceSyncAetherVehicleDebugInfo()
	self:Notify(67486797, SerializerHelper.DebugForceSyncAetherVehicleDebugInfo_Serializer)
end

function SerializerHelper.AskStealBasketball_Serializer(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskStealBasketball(gadgetuid)
	return self:Invoke(67490320, SerializerHelper.AskStealBasketball_Serializer, gadgetuid)
end

function SerializerHelper.ReportUnitFallEnd_Serializer(writer, unitid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:ReportUnitFallEnd(unitid)
	self:Notify(67492751, SerializerHelper.ReportUnitFallEnd_Serializer, unitid)
end

function SerializerHelper.AskEnterMoveGround_Serializer(writer, pid, movegroundid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, movegroundid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskEnterMoveGround(pid, movegroundid)
	return self:Invoke(67493272, SerializerHelper.AskEnterMoveGround_Serializer, pid, movegroundid)
end

function SerializerHelper.ReportUnitHitFlyEnd_Serializer(writer, defenderid, speed)
	SerializeBase.WritePrimitive(writer, defenderid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, speed, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:ReportUnitHitFlyEnd(defenderid, speed)
	self:Notify(67494406, SerializerHelper.ReportUnitHitFlyEnd_Serializer, defenderid, speed)
end

function SerializerHelper.ReportDoctorCureReactionCommandFinish_Serializer(writer, agentid, succeed)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, succeed, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:ReportDoctorCureReactionCommandFinish(agentid, succeed)
	self:Notify(67499754, SerializerHelper.ReportDoctorCureReactionCommandFinish_Serializer, agentid, succeed)
end

function SerializerHelper.ReportUnitEnterPuppet_Serializer(writer, unitid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:ReportUnitEnterPuppet(unitid)
	self:Notify(67499818, SerializerHelper.ReportUnitEnterPuppet_Serializer, unitid)
end

function SerializerHelper.AskBlockBasketball_Serializer(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskBlockBasketball(gadgetuid)
	return self:Invoke(67500700, SerializerHelper.AskBlockBasketball_Serializer, gadgetuid)
end

function SerializerHelper.AskPlayerOutOfStuck_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskPlayerOutOfStuck()
	self:Notify(67501662, SerializerHelper.AskPlayerOutOfStuck_Serializer)
end

function SerializerHelper.AskAetherAIRaidVehicleRegressAether_Serializer(writer, vehicleinstanceid)
	SerializeBase.WritePrimitive(writer, vehicleinstanceid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskAetherAIRaidVehicleRegressAether(vehicleinstanceid)
	return self:Invoke(67502597, SerializerHelper.AskAetherAIRaidVehicleRegressAether_Serializer, vehicleinstanceid)
end

function SerializerHelper.AskMoveCreations_Serializer(writer, list)
	SerializeBase.WriteList(writer, list, SerializeBase.WriteStructWrap(SerializeAuto.WriteCreationMoveData, "list"), nil, "list", false, 256, nil)
end

function ClientToGameSceneDelegate:AskMoveCreations(list)
	self:Notify(67505891, SerializerHelper.AskMoveCreations_Serializer, list)
end

function SerializerHelper.AskVehicleNavigationPathLength_Serializer(writer, targetposition, ignoredirection, ignorealley)
	SerializeBase.WriteStruct(writer, targetposition, SerializeAuto.WriteUXVector3, "targetposition")
	SerializeBase.WritePrimitive(writer, ignoredirection, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, ignorealley, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskVehicleNavigationPathLength(targetposition, ignoredirection, ignorealley)
	return self:Invoke(67509512, SerializerHelper.AskVehicleNavigationPathLength_Serializer, targetposition, ignoredirection, ignorealley)
end

function SerializerHelper.AskPuppetGetup_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskPuppetGetup(id)
	return self:Invoke(67511914, SerializerHelper.AskPuppetGetup_Serializer, id)
end

function SerializerHelper.AskAddRaidGamePlayRecordDoubleValue_Serializer(writer, recordid, paramid, addvalue)
	SerializeBase.WritePrimitive(writer, recordid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, paramid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, addvalue, writer.WriteDouble, 0)
end

function ClientToGameSceneDelegate:AskAddRaidGamePlayRecordDoubleValue(recordid, paramid, addvalue)
	return self:Invoke(67513965, SerializerHelper.AskAddRaidGamePlayRecordDoubleValue_Serializer, recordid, paramid, addvalue)
end

function SerializerHelper.AskPickUpAgentAsWeapon_Serializer(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskPickUpAgentAsWeapon(agententityid)
	return self:Invoke(67516697, SerializerHelper.AskPickUpAgentAsWeapon_Serializer, agententityid)
end

function SerializerHelper.AskCreateTimelineDangerArea_Serializer(writer, center, extends, rotation, dangerareatype)
	SerializeBase.WriteStruct(writer, center, SerializeAuto.WriteUXVector3, "center")
	SerializeBase.WriteStruct(writer, extends, SerializeAuto.WriteUXVector3, "extends")
	SerializeBase.WriteStruct(writer, rotation, SerializeAuto.WriteUXVector3, "rotation")
	SerializeBase.WritePrimitive(writer, dangerareatype, writer.WriteByte, 0)
end

function ClientToGameSceneDelegate:AskCreateTimelineDangerArea(center, extends, rotation, dangerareatype)
	self:Notify(67517952, SerializerHelper.AskCreateTimelineDangerArea_Serializer, center, extends, rotation, dangerareatype)
end

function SerializerHelper.AskHackingNpcPress_Serializer(writer, instanceid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskHackingNpcPress(instanceid)
	return self:Invoke(67527445, SerializerHelper.AskHackingNpcPress_Serializer, instanceid)
end

function SerializerHelper.ReportBlockCounterSuccess_Serializer(writer, defenderid, attackerid)
	SerializeBase.WritePrimitive(writer, defenderid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, attackerid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:ReportBlockCounterSuccess(defenderid, attackerid)
	self:Notify(67529956, SerializerHelper.ReportBlockCounterSuccess_Serializer, defenderid, attackerid)
end

function SerializerHelper.AskReleaseVehicleSeat_Serializer(writer, vehicleentityid, seatindex)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, seatindex, writer.WriteByte, 0)
end

function ClientToGameSceneDelegate:AskReleaseVehicleSeat(vehicleentityid, seatindex)
	self:Notify(67532019, SerializerHelper.AskReleaseVehicleSeat_Serializer, vehicleentityid, seatindex)
end

function SerializerHelper.AskStopControlAgent_Serializer(writer, clearagent)
	SerializeBase.WritePrimitive(writer, clearagent, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskStopControlAgent(clearagent)
	self:Notify(67534647, SerializerHelper.AskStopControlAgent_Serializer, clearagent)
end

function SerializerHelper.AskRemoveClientBuff_Serializer(writer, unitid, buffid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, buffid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskRemoveClientBuff(unitid, buffid)
	self:Notify(67536736, SerializerHelper.AskRemoveClientBuff_Serializer, unitid, buffid)
end

function SerializerHelper.AskTeleportToPoliceStation_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskTeleportToPoliceStation()
	return self:Invoke(67540798, SerializerHelper.AskTeleportToPoliceStation_Serializer)
end

function SerializerHelper.AskFinishGeneralTeleport_Serializer(writer, taskid, nodeid, flowid, type)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, flowid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
end

function ClientToGameSceneDelegate:AskFinishGeneralTeleport(taskid, nodeid, flowid, type)
	self:Notify(67542362, SerializerHelper.AskFinishGeneralTeleport_Serializer, taskid, nodeid, flowid, type)
end

function SerializerHelper.AskEnemyEndFall_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskEnemyEndFall(pid)
	self:Notify(67542575, SerializerHelper.AskEnemyEndFall_Serializer, pid)
end

function SerializerHelper.AskAetherStaticNpcReturnToSpawnPoint_Serializer(writer, entityid)
	SerializeBase.WritePrimitive(writer, entityid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskAetherStaticNpcReturnToSpawnPoint(entityid)
	self:Notify(67544416, SerializerHelper.AskAetherStaticNpcReturnToSpawnPoint_Serializer, entityid)
end

function SerializerHelper.ReportPlayerStartCommonInteract_Serializer(writer, interactposition, moveid)
	SerializeBase.WriteStruct(writer, interactposition, SerializeAuto.WriteUXVector3, "interactposition")
	SerializeBase.WritePrimitive(writer, moveid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:ReportPlayerStartCommonInteract(interactposition, moveid)
	return self:Invoke(67547275, SerializerHelper.ReportPlayerStartCommonInteract_Serializer, interactposition, moveid)
end

function SerializerHelper.AskEndPredictHit_Serializer(writer, targetid)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskEndPredictHit(targetid)
	self:Notify(67548067, SerializerHelper.AskEndPredictHit_Serializer, targetid)
end

function SerializerHelper.CheckCanLinkOccupySceneItem_Serializer(writer, id, linkid, onlycheck)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, linkid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, onlycheck, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:CheckCanLinkOccupySceneItem(id, linkid, onlycheck)
	return self:Invoke(67550410, SerializerHelper.CheckCanLinkOccupySceneItem_Serializer, id, linkid, onlycheck)
end

function SerializerHelper.AskFishDestructibleCreate_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteFishDestructibleData, "data", false)
end

function ClientToGameSceneDelegate:AskFishDestructibleCreate(data)
	return self:Invoke(67550827, SerializerHelper.AskFishDestructibleCreate_Serializer, data)
end

function SerializerHelper.AskDiscardWeaponByInstanceId_Serializer(writer, weaponinstanceid, spiritid, isdropout)
	SerializeBase.WritePrimitive(writer, weaponinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isdropout, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskDiscardWeaponByInstanceId(weaponinstanceid, spiritid, isdropout)
	return self:Invoke(67551715, SerializerHelper.AskDiscardWeaponByInstanceId_Serializer, weaponinstanceid, spiritid, isdropout)
end

function SerializerHelper.AskCheckWildEnemyGroup_Serializer(writer, groupid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskCheckWildEnemyGroup(groupid)
	self:Notify(67560787, SerializerHelper.AskCheckWildEnemyGroup_Serializer, groupid)
end

function SerializerHelper.AskReleaseClientEvent_Serializer(writer, name)
	writer:WriteString(name, false, "name", 32)
end

function ClientToGameSceneDelegate:AskReleaseClientEvent(name)
	return self:Invoke(67564631, SerializerHelper.AskReleaseClientEvent_Serializer, name)
end

function SerializerHelper.AskSwitchSpiritByTaskRole_Serializer(writer, roleid)
	SerializeBase.WritePrimitive(writer, roleid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskSwitchSpiritByTaskRole(roleid)
	return self:Invoke(67564989, SerializerHelper.AskSwitchSpiritByTaskRole_Serializer, roleid)
end

function SerializerHelper.AskSwitchWeapon_Serializer(writer, index)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskSwitchWeapon(index)
	self:Notify(67565349, SerializerHelper.AskSwitchWeapon_Serializer, index)
end

function SerializerHelper.AskRemoveEnemyStiff_Serializer(writer, pid, stiffid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, stiffid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskRemoveEnemyStiff(pid, stiffid)
	self:Notify(67565802, SerializerHelper.AskRemoveEnemyStiff_Serializer, pid, stiffid)
end

function SerializerHelper.AskUpdateVehicleAITaskStatus_Serializer(writer, vehicleuid, token, newstatus)
	SerializeBase.WritePrimitive(writer, vehicleuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, token, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, newstatus, writer.WriteByte, 0)
end

function ClientToGameSceneDelegate:AskUpdateVehicleAITaskStatus(vehicleuid, token, newstatus)
	self:Notify(67566081, SerializerHelper.AskUpdateVehicleAITaskStatus_Serializer, vehicleuid, token, newstatus)
end

function SerializerHelper.AskVehicleSendStateSignal_Serializer(writer, id, signal)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, signal, writer.WriteByte, 0)
end

function ClientToGameSceneDelegate:AskVehicleSendStateSignal(id, signal)
	self:Notify(67568804, SerializerHelper.AskVehicleSendStateSignal_Serializer, id, signal)
end

function SerializerHelper.AskAgentRegressVehicle_Serializer(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskAgentRegressVehicle(agententityid)
	self:Notify(67570052, SerializerHelper.AskAgentRegressVehicle_Serializer, agententityid)
end

function SerializerHelper.AskStartClimb_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskStartClimb()
	self:Notify(67570093, SerializerHelper.AskStartClimb_Serializer)
end

function SerializerHelper.AskSetGlobalTimeSlow_Serializer(writer, pauseid)
	SerializeBase.WritePrimitive(writer, pauseid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskSetGlobalTimeSlow(pauseid)
	return self:Invoke(67570847, SerializerHelper.AskSetGlobalTimeSlow_Serializer, pauseid)
end

function SerializerHelper.AskDroneHitchStateChanged_Serializer(writer, droneentityid, targetdestructibleuniqueid, state)
	SerializeBase.WritePrimitive(writer, droneentityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetdestructibleuniqueid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteByte, 0)
end

function ClientToGameSceneDelegate:AskDroneHitchStateChanged(droneentityid, targetdestructibleuniqueid, state)
	return self:Invoke(67573380, SerializerHelper.AskDroneHitchStateChanged_Serializer, droneentityid, targetdestructibleuniqueid, state)
end

function SerializerHelper.AskChangeDestructibleHp_Serializer(writer, id, hp)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, hp, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskChangeDestructibleHp(id, hp)
	self:Notify(67573926, SerializerHelper.AskChangeDestructibleHp_Serializer, id, hp)
end

function SerializerHelper.AskMindInteractEnemy_Serializer(writer, enemyid, interactid, createdestructibledata)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, interactid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, createdestructibledata, SerializeAuto.WriteSkillDestructibleData, "createdestructibledata", true)
end

function ClientToGameSceneDelegate:AskMindInteractEnemy(enemyid, interactid, createdestructibledata)
	return self:Invoke(67575414, SerializerHelper.AskMindInteractEnemy_Serializer, enemyid, interactid, createdestructibledata)
end

function SerializerHelper.AskAetherNpcUpdatePathForObstacle_Serializer(writer, entityid, obstacleposition, obstacleradius)
	SerializeBase.WritePrimitive(writer, entityid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, obstacleposition, SerializeAuto.WriteUXVector3, "obstacleposition")
	SerializeBase.WritePrimitive(writer, obstacleradius, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskAetherNpcUpdatePathForObstacle(entityid, obstacleposition, obstacleradius)
	self:Notify(67575476, SerializerHelper.AskAetherNpcUpdatePathForObstacle_Serializer, entityid, obstacleposition, obstacleradius)
end

function SerializerHelper.AskClickPlayerTwitterButton_Serializer(writer, twitterid)
	SerializeBase.WritePrimitive(writer, twitterid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskClickPlayerTwitterButton(twitterid)
	return self:Invoke(67575770, SerializerHelper.AskClickPlayerTwitterButton_Serializer, twitterid)
end

function SerializerHelper.AskRecordDrivingBehavior_Serializer(writer, records)
	SerializeBase.WriteComplex(writer, records, SerializeAuto.WriteDrivingBehaviorRecords, "records", false)
end

function ClientToGameSceneDelegate:AskRecordDrivingBehavior(records)
	self:Notify(67580502, SerializerHelper.AskRecordDrivingBehavior_Serializer, records)
end

function SerializerHelper.AskOnMetroExitStation_Serializer(writer, metroids)
	SerializeBase.WriteList(writer, metroids, writer.WriteInt32, 0, "metroids", false, 32, nil)
end

function ClientToGameSceneDelegate:AskOnMetroExitStation(metroids)
	self:Notify(67581196, SerializerHelper.AskOnMetroExitStation_Serializer, metroids)
end

function SerializerHelper.AskAgentVehicleEscape_Serializer(writer, agententityid, targetposition, mintargetdistance, jsonconfigid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, targetposition, SerializeAuto.WriteUXVector3, "targetposition")
	SerializeBase.WritePrimitive(writer, mintargetdistance, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, jsonconfigid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskAgentVehicleEscape(agententityid, targetposition, mintargetdistance, jsonconfigid)
	return self:Invoke(67582286, SerializerHelper.AskAgentVehicleEscape_Serializer, agententityid, targetposition, mintargetdistance, jsonconfigid)
end

function SerializerHelper.AskVehicleStartHackerAutonomousDriving_Serializer(writer, targetposition)
	SerializeBase.WriteStruct(writer, targetposition, SerializeAuto.WriteUXVector3, "targetposition")
end

function ClientToGameSceneDelegate:AskVehicleStartHackerAutonomousDriving(targetposition)
	return self:Invoke(67582912, SerializerHelper.AskVehicleStartHackerAutonomousDriving_Serializer, targetposition)
end

function SerializerHelper.AskSetAetherVehicleTimeScale_Serializer(writer, vehicleid, timescale)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, timescale, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskSetAetherVehicleTimeScale(vehicleid, timescale)
	return self:Invoke(67586560, SerializerHelper.AskSetAetherVehicleTimeScale_Serializer, vehicleid, timescale)
end

function SerializerHelper.AskAgentDestructibleCreate_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteAgentDestructibleData, "data", false)
end

function ClientToGameSceneDelegate:AskAgentDestructibleCreate(data)
	return self:Invoke(67589596, SerializerHelper.AskAgentDestructibleCreate_Serializer, data)
end

function SerializerHelper.AskSkillAddState_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillStateData, "data", false)
end

function ClientToGameSceneDelegate:AskSkillAddState(data)
	self:Notify(67589844, SerializerHelper.AskSkillAddState_Serializer, data)
end

function SerializerHelper.AskSetEmotionsByStateTree_Serializer(writer, set, unlock)
	SerializeBase.WriteList(writer, set, SerializeBase.WriteStructWrap(SerializeAuto.WriteSetEmotionData, "set"), nil, "set", false, 32, nil)
	SerializeBase.WriteList(writer, unlock, writer.WriteUInt64, 0, "unlock", false, 64, nil)
end

function ClientToGameSceneDelegate:AskSetEmotionsByStateTree(set, unlock)
	self:Notify(67590392, SerializerHelper.AskSetEmotionsByStateTree_Serializer, set, unlock)
end

function SerializerHelper.EnterGomokuZoneDoubleAI_Serializer(writer, gadgetuid, agentid, useblackpiece, difficulty)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, useblackpiece, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, difficulty, writer.WriteByte, 0)
end

function ClientToGameSceneDelegate:EnterGomokuZoneDoubleAI(gadgetuid, agentid, useblackpiece, difficulty)
	return self:Invoke(67592111, SerializerHelper.EnterGomokuZoneDoubleAI_Serializer, gadgetuid, agentid, useblackpiece, difficulty)
end

function SerializerHelper.AskSwitchDefaultWeapon_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskSwitchDefaultWeapon()
	self:Notify(67593270, SerializerHelper.AskSwitchDefaultWeapon_Serializer)
end

function SerializerHelper.AskSetGamePause_Serializer(writer, value, reason)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, reason, writer.WriteByte, 0)
end

function ClientToGameSceneDelegate:AskSetGamePause(value, reason)
	return self:Invoke(67594337, SerializerHelper.AskSetGamePause_Serializer, value, reason)
end

function SerializerHelper.AskHaveSeenCinema_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskHaveSeenCinema()
	return self:Invoke(67596088, SerializerHelper.AskHaveSeenCinema_Serializer)
end

function SerializerHelper.AskPlayerLeaveWater_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskPlayerLeaveWater()
	return self:Invoke(67598658, SerializerHelper.AskPlayerLeaveWater_Serializer)
end

function SerializerHelper.AskCreateSymbiosisDestructible_Serializer(writer, id, destructibleid)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, destructibleid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskCreateSymbiosisDestructible(id, destructibleid)
	return self:Invoke(67599769, SerializerHelper.AskCreateSymbiosisDestructible_Serializer, id, destructibleid)
end

function SerializerHelper.SendCustomCommonDataClientToGameScene_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

function ClientToGameSceneDelegate:SendCustomCommonDataClientToGameScene(data)
	return self:Invoke(67599974, SerializerHelper.SendCustomCommonDataClientToGameScene_Serializer, data)
end

function SerializerHelper.AskEnterShootModeOnCannon_Serializer(writer, cannontemplateid)
	SerializeBase.WritePrimitive(writer, cannontemplateid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskEnterShootModeOnCannon(cannontemplateid)
	return self:Invoke(67600709, SerializerHelper.AskEnterShootModeOnCannon_Serializer, cannontemplateid)
end

function SerializerHelper.AskBasketballOperatorAction_Serializer(writer, askoperatorparam)
	SerializeBase.WriteComplex(writer, askoperatorparam, SerializeAuto.WriteBasketballAskOperatorParam, "askoperatorparam", false)
end

function ClientToGameSceneDelegate:AskBasketballOperatorAction(askoperatorparam)
	return self:Invoke(67602964, SerializerHelper.AskBasketballOperatorAction_Serializer, askoperatorparam)
end

function SerializerHelper.AskSpoonButtonClickEvent_Serializer(writer, nodeid)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskSpoonButtonClickEvent(nodeid)
	self:Notify(67608860, SerializerHelper.AskSpoonButtonClickEvent_Serializer, nodeid)
end

function SerializerHelper.AskSkillDestructibleCreate_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillDestructibleData, "data", false)
end

function ClientToGameSceneDelegate:AskSkillDestructibleCreate(data)
	return self:Invoke(67610605, SerializerHelper.AskSkillDestructibleCreate_Serializer, data)
end

function SerializerHelper.AskVehicleDisMonitorTrigger_Serializer(writer, vehicleentityid, distance, isawayorapproach)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, distance, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, isawayorapproach, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskVehicleDisMonitorTrigger(vehicleentityid, distance, isawayorapproach)
	self:Notify(67619905, SerializerHelper.AskVehicleDisMonitorTrigger_Serializer, vehicleentityid, distance, isawayorapproach)
end

function SerializerHelper.AskUnitMoveAction_Serializer(writer, actions, ping)
	SerializeBase.WriteList(writer, actions, SerializeBase.WriteStructWrap(SerializeAuto.WriteMoveActionData, "actions"), nil, "actions", false, 1024, nil)
	SerializeBase.WritePrimitive(writer, ping, writer.WriteDouble, 0)
end

function ClientToGameSceneDelegate:AskUnitMoveAction(actions, ping)
	self:Notify(67622465, SerializerHelper.AskUnitMoveAction_Serializer, actions, ping)
end

function SerializerHelper.AskMaidTeaSettlement_Serializer(writer, info)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WriteMaidTeaChoiceInfo, "info", false)
end

function ClientToGameSceneDelegate:AskMaidTeaSettlement(info)
	return self:Invoke(67633578, SerializerHelper.AskMaidTeaSettlement_Serializer, info)
end

function SerializerHelper.AskVehicleStartMove_Serializer(writer, vehicleentityid)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskVehicleStartMove(vehicleentityid)
	self:Notify(67635470, SerializerHelper.AskVehicleStartMove_Serializer, vehicleentityid)
end

function SerializerHelper.AskFallOffCliff_Serializer(writer, position, moveid)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, moveid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskFallOffCliff(position, moveid)
	self:Notify(67640839, SerializerHelper.AskFallOffCliff_Serializer, position, moveid)
end

function SerializerHelper.AskReadWeaponRedDots_Serializer(writer, weaponinstanceids)
	SerializeBase.WriteList(writer, weaponinstanceids, writer.WriteUInt64, 0, "weaponinstanceids", false, 1024, nil)
end

function ClientToGameSceneDelegate:AskReadWeaponRedDots(weaponinstanceids)
	self:Notify(67641674, SerializerHelper.AskReadWeaponRedDots_Serializer, weaponinstanceids)
end

function SerializerHelper.AskSkillCloseShield_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillShieldData, "data", false)
end

function ClientToGameSceneDelegate:AskSkillCloseShield(data)
	self:Notify(67644587, SerializerHelper.AskSkillCloseShield_Serializer, data)
end

function SerializerHelper.AskUpdatePlayerCameraDirection_Serializer(writer, cameradirection)
	SerializeBase.WritePrimitive(writer, cameradirection, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskUpdatePlayerCameraDirection(cameradirection)
	self:Notify(67646330, SerializerHelper.AskUpdatePlayerCameraDirection_Serializer, cameradirection)
end

function SerializerHelper.ReportRayCast4DRes_Serializer(writer, uid, resultfront, resultback, resultleft, resultright)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, resultfront, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, resultback, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, resultleft, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, resultright, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:ReportRayCast4DRes(uid, resultfront, resultback, resultleft, resultright)
	self:Notify(67646726, SerializerHelper.ReportRayCast4DRes_Serializer, uid, resultfront, resultback, resultleft, resultright)
end

function SerializerHelper.ReportAgentInteract2F_Serializer(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:ReportAgentInteract2F(agententityid)
	self:Notify(67647820, SerializerHelper.ReportAgentInteract2F_Serializer, agententityid)
end

function SerializerHelper.AskEnterSceneRoom_Serializer(writer, sceneroomid, isvehicle, moveid)
	SerializeBase.WritePrimitive(writer, sceneroomid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, isvehicle, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, moveid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskEnterSceneRoom(sceneroomid, isvehicle, moveid)
	return self:Invoke(67655478, SerializerHelper.AskEnterSceneRoom_Serializer, sceneroomid, isvehicle, moveid)
end

function SerializerHelper.AskResetVehicleToNearestLane_Serializer(writer, currentpos, targetpos, targetfacing)
	SerializeBase.WriteStruct(writer, currentpos, SerializeAuto.WriteUXVector3, "currentpos")
	SerializeBase.WriteStruct(writer, targetpos, SerializeAuto.WriteUXVector3, "targetpos")
	SerializeBase.WritePrimitive(writer, targetfacing, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskResetVehicleToNearestLane(currentpos, targetpos, targetfacing)
	return self:Invoke(67656882, SerializerHelper.AskResetVehicleToNearestLane_Serializer, currentpos, targetpos, targetfacing)
end

function SerializerHelper.AskSetEffectData_Serializer(writer, data, includeme)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteEffectSyncData, "data", false)
	SerializeBase.WritePrimitive(writer, includeme, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskSetEffectData(data, includeme)
	self:Notify(67660438, SerializerHelper.AskSetEffectData_Serializer, data, includeme)
end

function SerializerHelper.AskVehicleSendSignal_Serializer(writer, id, signalname)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	writer:WriteString(signalname, false, "signalname", 256)
end

function ClientToGameSceneDelegate:AskVehicleSendSignal(id, signalname)
	return self:Invoke(67662900, SerializerHelper.AskVehicleSendSignal_Serializer, id, signalname)
end

function SerializerHelper.AskVehicleContactDamage_Serializer(writer, vehicleid, data)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, data, SerializeAuto.WriteVehicleContactDamageData, "data")
end

function ClientToGameSceneDelegate:AskVehicleContactDamage(vehicleid, data)
	self:Notify(67665002, SerializerHelper.AskVehicleContactDamage_Serializer, vehicleid, data)
end

function SerializerHelper.AskBVBUnlockChaosBuffCandidates_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskBVBUnlockChaosBuffCandidates()
	return self:Invoke(67666820, SerializerHelper.AskBVBUnlockChaosBuffCandidates_Serializer)
end

function SerializerHelper.AskChangeCanMoveToDriveSeat_Serializer(writer, vehicleid, canmovetodriveseat)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, canmovetodriveseat, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskChangeCanMoveToDriveSeat(vehicleid, canmovetodriveseat)
	self:Notify(67669829, SerializerHelper.AskChangeCanMoveToDriveSeat_Serializer, vehicleid, canmovetodriveseat)
end

function SerializerHelper.AskMetroGadgetIds_Serializer(writer, metroid)
	SerializeBase.WritePrimitive(writer, metroid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskMetroGadgetIds(metroid)
	return self:Invoke(67670049, SerializerHelper.AskMetroGadgetIds_Serializer, metroid)
end

function SerializerHelper.AskVehicleEnterWater_Serializer(writer, vehicleentityid)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskVehicleEnterWater(vehicleentityid)
	self:Notify(67671089, SerializerHelper.AskVehicleEnterWater_Serializer, vehicleentityid)
end

function SerializerHelper.AskVehicleComponentStateUpdate_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteVehicleComponentStateUpdateInfo, "data", false)
end

function ClientToGameSceneDelegate:AskVehicleComponentStateUpdate(data)
	self:Notify(67678967, SerializerHelper.AskVehicleComponentStateUpdate_Serializer, data)
end

function SerializerHelper.AskPlateDestructibleCreate_Serializer(writer, instanceid, inlineid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, inlineid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskPlateDestructibleCreate(instanceid, inlineid)
	return self:Invoke(67682439, SerializerHelper.AskPlateDestructibleCreate_Serializer, instanceid, inlineid)
end

function SerializerHelper.ReportDrivingVehicle_Serializer(writer, vehicleid, isdriving)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, isdriving, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:ReportDrivingVehicle(vehicleid, isdriving)
	self:Notify(67683881, SerializerHelper.ReportDrivingVehicle_Serializer, vehicleid, isdriving)
end

function SerializerHelper.AskExitShootModeOnCannon_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskExitShootModeOnCannon()
	return self:Invoke(67686149, SerializerHelper.AskExitShootModeOnCannon_Serializer)
end

function SerializerHelper.AskPlayHurtEffect_Serializer(writer, defenderid, attackerid, hurteffectid, stiffid, skillid)
	SerializeBase.WritePrimitive(writer, defenderid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, attackerid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, hurteffectid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, stiffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskPlayHurtEffect(defenderid, attackerid, hurteffectid, stiffid, skillid)
	self:Notify(67693229, SerializerHelper.AskPlayHurtEffect_Serializer, defenderid, attackerid, hurteffectid, stiffid, skillid)
end

function SerializerHelper.LeaveDart_Serializer(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:LeaveDart(gadgetuid)
	return self:Invoke(67696163, SerializerHelper.LeaveDart_Serializer, gadgetuid)
end

function SerializerHelper.AskBVBSelectFightPokemonList_Serializer(writer, selectpokemondatas)
	SerializeBase.WriteList(writer, selectpokemondatas, SerializeBase.WriteComplexWrap(SerializeAuto.WriteBVBSelectPokemonData, "BVBSelectPokemonData", false), nil, "selectpokemondatas", false, 256, nil)
end

function ClientToGameSceneDelegate:AskBVBSelectFightPokemonList(selectpokemondatas)
	return self:Invoke(67698208, SerializerHelper.AskBVBSelectFightPokemonList_Serializer, selectpokemondatas)
end

function SerializerHelper.AskMaidTeaMemberInfo_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskMaidTeaMemberInfo()
	return self:Invoke(67698680, SerializerHelper.AskMaidTeaMemberInfo_Serializer)
end

function SerializerHelper.AskAddCurrentWeaponSceneItemHp_Serializer(writer, hp)
	SerializeBase.WritePrimitive(writer, hp, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskAddCurrentWeaponSceneItemHp(hp)
	self:Notify(67699615, SerializerHelper.AskAddCurrentWeaponSceneItemHp_Serializer, hp)
end

function SerializerHelper.AskDoorTransfer_Serializer(writer, id, from, to, position)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, from, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, to, writer.WriteInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
end

function ClientToGameSceneDelegate:AskDoorTransfer(id, from, to, position)
	self:Notify(67706034, SerializerHelper.AskDoorTransfer_Serializer, id, from, to, position)
end

function SerializerHelper.AskSwitchPrivateWeapon_Serializer(writer, index)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskSwitchPrivateWeapon(index)
	self:Notify(67706325, SerializerHelper.AskSwitchPrivateWeapon_Serializer, index)
end

function SerializerHelper.AskChangeSceneItemExtraIndex_Serializer(writer, position, range, add)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, range, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, add, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskChangeSceneItemExtraIndex(position, range, add)
	return self:Invoke(67706483, SerializerHelper.AskChangeSceneItemExtraIndex_Serializer, position, range, add)
end

function SerializerHelper.AskCreationsTriggerDisappear_Serializer(writer, creations)
	SerializeBase.WriteList(writer, creations, writer.WriteUInt64, 0, "creations", false, 256, nil)
end

function ClientToGameSceneDelegate:AskCreationsTriggerDisappear(creations)
	return self:Invoke(67708360, SerializerHelper.AskCreationsTriggerDisappear_Serializer, creations)
end

function SerializerHelper.AskTrackWildEnemyGroupInfo_Serializer(writer, groupspoonid)
	SerializeBase.WritePrimitive(writer, groupspoonid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskTrackWildEnemyGroupInfo(groupspoonid)
	return self:Invoke(67709377, SerializerHelper.AskTrackWildEnemyGroupInfo_Serializer, groupspoonid)
end

function SerializerHelper.AskPickupDestructible_Serializer(writer, destructibleentityid)
	SerializeBase.WritePrimitive(writer, destructibleentityid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskPickupDestructible(destructibleentityid)
	return self:Invoke(67716433, SerializerHelper.AskPickupDestructible_Serializer, destructibleentityid)
end

function SerializerHelper.AskCreationMultiEnterOrLeaves_Serializer(writer, datas)
	SerializeBase.WriteList(writer, datas, SerializeBase.WriteStructWrap(SerializeAuto.WriteCreationEnterLeave, "datas"), nil, "datas", false, 256, nil)
end

function ClientToGameSceneDelegate:AskCreationMultiEnterOrLeaves(datas)
	self:Notify(67717000, SerializerHelper.AskCreationMultiEnterOrLeaves_Serializer, datas)
end

function SerializerHelper.AskAddClientBuff_Serializer(writer, unitid, buffid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, buffid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskAddClientBuff(unitid, buffid)
	self:Notify(67720841, SerializerHelper.AskAddClientBuff_Serializer, unitid, buffid)
end

function SerializerHelper.AskUseSkill_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillUseData, "data", false)
end

function ClientToGameSceneDelegate:AskUseSkill(data)
	return self:Invoke(67721106, SerializerHelper.AskUseSkill_Serializer, data)
end

function SerializerHelper.ChangeVehicleDoorState_Serializer(writer, doorindex, vehicleid, reason)
	SerializeBase.WritePrimitive(writer, doorindex, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, reason, writer.WriteByte, 0)
end

function ClientToGameSceneDelegate:ChangeVehicleDoorState(doorindex, vehicleid, reason)
	return self:Invoke(67723554, SerializerHelper.ChangeVehicleDoorState_Serializer, doorindex, vehicleid, reason)
end

function SerializerHelper.AskVehicleNavigationPathPoints_Serializer(writer, navreqid, targetposition, ignoredirection, ignorealley, needcenterpoints)
	SerializeBase.WritePrimitive(writer, navreqid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, targetposition, SerializeAuto.WriteUXVector3, "targetposition")
	SerializeBase.WritePrimitive(writer, ignoredirection, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, ignorealley, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, needcenterpoints, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskVehicleNavigationPathPoints(navreqid, targetposition, ignoredirection, ignorealley, needcenterpoints)
	return self:Invoke(67724888, SerializerHelper.AskVehicleNavigationPathPoints_Serializer, navreqid, targetposition, ignoredirection, ignorealley, needcenterpoints)
end

function SerializerHelper.AskSetTaskValue_Serializer(writer, id, key, value, persistinevent)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	writer:WriteString(key, false, "key", 256)
	SerializeBase.WritePrimitive(writer, value, writer.WriteDouble, 0)
	SerializeBase.WritePrimitive(writer, persistinevent, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskSetTaskValue(id, key, value, persistinevent)
	return self:Invoke(67729767, SerializerHelper.AskSetTaskValue_Serializer, id, key, value, persistinevent)
end

function SerializerHelper.AskFightGameLeave_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskFightGameLeave()
	return self:Invoke(67729893, SerializerHelper.AskFightGameLeave_Serializer)
end

function SerializerHelper.AskPlayerStartEnterOrExitVehicle_Serializer(writer, syncdata)
	SerializeBase.WriteComplex(writer, syncdata, SerializeAuto.WritePlayerVehicleDriveStateInfo, "syncdata", false)
end

function ClientToGameSceneDelegate:AskPlayerStartEnterOrExitVehicle(syncdata)
	self:Notify(67730387, SerializerHelper.AskPlayerStartEnterOrExitVehicle_Serializer, syncdata)
end

function SerializerHelper.AskAgentFinishNpcDialog_Serializer(writer, agententityid, npcdialogid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, npcdialogid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskAgentFinishNpcDialog(agententityid, npcdialogid)
	self:Notify(67731141, SerializerHelper.AskAgentFinishNpcDialog_Serializer, agententityid, npcdialogid)
end

function SerializerHelper.AskBreakSkillTimeCurve_Serializer(writer, releaser, id, index)
	SerializeBase.WritePrimitive(writer, releaser, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskBreakSkillTimeCurve(releaser, id, index)
	self:Notify(67733500, SerializerHelper.AskBreakSkillTimeCurve_Serializer, releaser, id, index)
end

function SerializerHelper.AskFeiSuoSuccess_Serializer(writer, feisuoid)
	SerializeBase.WritePrimitive(writer, feisuoid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskFeiSuoSuccess(feisuoid)
	self:Notify(67734813, SerializerHelper.AskFeiSuoSuccess_Serializer, feisuoid)
end

function SerializerHelper.AskMergeDestructibleObjects_Serializer(writer, ids, agentinstanceid, mergepos)
	SerializeBase.WriteList(writer, ids, writer.WriteUInt64, 0, "ids", false, 32, nil)
	SerializeBase.WritePrimitive(writer, agentinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, mergepos, SerializeAuto.WriteUXVector3, "mergepos")
end

function ClientToGameSceneDelegate:AskMergeDestructibleObjects(ids, agentinstanceid, mergepos)
	self:Notify(67736455, SerializerHelper.AskMergeDestructibleObjects_Serializer, ids, agentinstanceid, mergepos)
end

function SerializerHelper.AskRestaurantBuyFoods_Serializer(writer, buyfoodinfo)
	SerializeBase.WriteComplex(writer, buyfoodinfo, SerializeAuto.WriteBuyFoodInfo, "buyfoodinfo", false)
end

function ClientToGameSceneDelegate:AskRestaurantBuyFoods(buyfoodinfo)
	return self:Invoke(67736468, SerializerHelper.AskRestaurantBuyFoods_Serializer, buyfoodinfo)
end

function SerializerHelper.AskMetroHit_Serializer(writer, hitdata)
	SerializeBase.WriteComplex(writer, hitdata, SerializeAuto.WriteMetroHitData, "hitdata", false)
end

function ClientToGameSceneDelegate:AskMetroHit(hitdata)
	return self:Invoke(67744578, SerializerHelper.AskMetroHit_Serializer, hitdata)
end

function SerializerHelper.AskPipeGameEnd_Serializer(writer, pipegamegraphid)
	SerializeBase.WritePrimitive(writer, pipegamegraphid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskPipeGameEnd(pipegamegraphid)
	self:Notify(67746253, SerializerHelper.AskPipeGameEnd_Serializer, pipegamegraphid)
end

function SerializerHelper.HoldLetterSignal_Serializer(writer, instanceid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:HoldLetterSignal(instanceid)
	return self:Invoke(67751744, SerializerHelper.HoldLetterSignal_Serializer, instanceid)
end

function SerializerHelper.TriggerChefZone_Serializer(writer, gadgetuid, enter)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, enter, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:TriggerChefZone(gadgetuid, enter)
	return self:Invoke(67753718, SerializerHelper.TriggerChefZone_Serializer, gadgetuid, enter)
end

function SerializerHelper.AskChangeSceneItemQuality_Serializer(writer, newrange)
	SerializeBase.WritePrimitive(writer, newrange, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskChangeSceneItemQuality(newrange)
	return self:Invoke(67753833, SerializerHelper.AskChangeSceneItemQuality_Serializer, newrange)
end

function SerializerHelper.ReportAgentLeavePuppet_Serializer(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:ReportAgentLeavePuppet(agententityid)
	self:Notify(67754503, SerializerHelper.ReportAgentLeavePuppet_Serializer, agententityid)
end

function SerializerHelper.ReportEnemyHitWall_Serializer(writer, enemyid, beforehitstiffid, hitpos, hitwallstiff, stifftime)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, beforehitstiffid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, hitpos, SerializeAuto.WriteUXVector3, "hitpos")
	SerializeBase.WritePrimitive(writer, hitwallstiff, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, stifftime, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:ReportEnemyHitWall(enemyid, beforehitstiffid, hitpos, hitwallstiff, stifftime)
	self:Notify(67769444, SerializerHelper.ReportEnemyHitWall_Serializer, enemyid, beforehitstiffid, hitpos, hitwallstiff, stifftime)
end

function SerializerHelper.AskReleaseEnemySignal_Serializer(writer, enemyid, signal)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	writer:WriteString(signal, false, "signal", 32)
end

function ClientToGameSceneDelegate:AskReleaseEnemySignal(enemyid, signal)
	self:Notify(67772099, SerializerHelper.AskReleaseEnemySignal_Serializer, enemyid, signal)
end

function SerializerHelper.ReportPlayActionFinish_Serializer(writer, enemyid, actionid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, actionid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:ReportPlayActionFinish(enemyid, actionid)
	self:Notify(67775844, SerializerHelper.ReportPlayActionFinish_Serializer, enemyid, actionid)
end

function SerializerHelper.AskGetOffMotor_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskGetOffMotor()
	self:Notify(67780772, SerializerHelper.AskGetOffMotor_Serializer)
end

function SerializerHelper.AskExitBVBGame_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskExitBVBGame()
	return self:Invoke(67782549, SerializerHelper.AskExitBVBGame_Serializer)
end

function SerializerHelper.ReportClientDetectEventDatas_Serializer(writer, datas)
	SerializeBase.WriteList(writer, datas, SerializeBase.WriteStructWrap(SerializeAuto.WriteClientDetectEventData, "datas"), nil, "datas", false, 1024, nil)
end

function ClientToGameSceneDelegate:ReportClientDetectEventDatas(datas)
	self:Notify(67783237, SerializerHelper.ReportClientDetectEventDatas_Serializer, datas)
end

function SerializerHelper.AskMultiCinemaBuyTicket_Serializer(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskMultiCinemaBuyTicket(locationid)
	return self:Invoke(67784355, SerializerHelper.AskMultiCinemaBuyTicket_Serializer, locationid)
end

function SerializerHelper.AskVehicleMove_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteRaidVehicleSyncData, "data", false)
end

function ClientToGameSceneDelegate:AskVehicleMove(data)
	self:Notify(67785917, SerializerHelper.AskVehicleMove_Serializer, data)
end

function SerializerHelper.AskFightGameSyncPlayerAction_Serializer(writer, action, isai)
	writer:WriteString(action, false, "action", 256)
	SerializeBase.WritePrimitive(writer, isai, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskFightGameSyncPlayerAction(action, isai)
	self:Notify(67786180, SerializerHelper.AskFightGameSyncPlayerAction_Serializer, action, isai)
end

function SerializerHelper.AskVehicleLeaveStuck_Serializer(writer, vehicleid)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskVehicleLeaveStuck(vehicleid)
	return self:Invoke(67788013, SerializerHelper.AskVehicleLeaveStuck_Serializer, vehicleid)
end

function SerializerHelper.AskCinemaRemoveNpc_Serializer(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskCinemaRemoveNpc(locationid)
	return self:Invoke(67790322, SerializerHelper.AskCinemaRemoveNpc_Serializer, locationid)
end

function SerializerHelper.AskCreateAttractPoint_Serializer(writer, uid, templateid, maxcount, range, position)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, maxcount, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, range, writer.WriteSingle, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
end

function ClientToGameSceneDelegate:AskCreateAttractPoint(uid, templateid, maxcount, range, position)
	self:Notify(67790561, SerializerHelper.AskCreateAttractPoint_Serializer, uid, templateid, maxcount, range, position)
end

function SerializerHelper.AskPlateLoadComplete_Serializer(writer, uid)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskPlateLoadComplete(uid)
	return self:Invoke(67793028, SerializerHelper.AskPlateLoadComplete_Serializer, uid)
end

function SerializerHelper.AskReleaseLuaSlotEntityEvent_Serializer(writer, name, id, isdynamic)
	writer:WriteString(name, false, "name", 256)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, isdynamic, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskReleaseLuaSlotEntityEvent(name, id, isdynamic)
	return self:Invoke(67795266, SerializerHelper.AskReleaseLuaSlotEntityEvent_Serializer, name, id, isdynamic)
end

function SerializerHelper.EnterGomokuZoneDoublePlayer_Serializer(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:EnterGomokuZoneDoublePlayer(gadgetuid)
	return self:Invoke(67796172, SerializerHelper.EnterGomokuZoneDoublePlayer_Serializer, gadgetuid)
end

function SerializerHelper.RecordAgentBowlingScore_Serializer(writer, gadgetuid, npcid, throwindex, score)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, throwindex, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:RecordAgentBowlingScore(gadgetuid, npcid, throwindex, score)
	return self:Invoke(67796491, SerializerHelper.RecordAgentBowlingScore_Serializer, gadgetuid, npcid, throwindex, score)
end

function SerializerHelper.RefreshSceneDestructible_Serializer(writer, center, distance)
	SerializeBase.WriteStruct(writer, center, SerializeAuto.WriteUXVector3, "center")
	SerializeBase.WritePrimitive(writer, distance, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:RefreshSceneDestructible(center, distance)
	self:Notify(67797409, SerializerHelper.RefreshSceneDestructible_Serializer, center, distance)
end

function SerializerHelper.AskSwitchSceneByTask_Serializer(writer, taskid, counter)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, counter, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskSwitchSceneByTask(taskid, counter)
	return self:Invoke(67797896, SerializerHelper.AskSwitchSceneByTask_Serializer, taskid, counter)
end

function SerializerHelper.RefreshCleaningProgress_Serializer(writer, cleaningprogress)
	SerializeBase.WritePrimitive(writer, cleaningprogress, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:RefreshCleaningProgress(cleaningprogress)
	return self:Invoke(67799173, SerializerHelper.RefreshCleaningProgress_Serializer, cleaningprogress)
end

function SerializerHelper.AskBVBRefreshChaosBuffCandidates_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskBVBRefreshChaosBuffCandidates()
	return self:Invoke(67801269, SerializerHelper.AskBVBRefreshChaosBuffCandidates_Serializer)
end

function SerializerHelper.AskCinemaPlayMovie_Serializer(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskCinemaPlayMovie(locationid)
	return self:Invoke(67803180, SerializerHelper.AskCinemaPlayMovie_Serializer, locationid)
end

function SerializerHelper.AskEnemyItemPickUp_Serializer(writer, enemyinstanceid, binditemsindex)
	SerializeBase.WritePrimitive(writer, enemyinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, binditemsindex, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskEnemyItemPickUp(enemyinstanceid, binditemsindex)
	return self:Invoke(67803481, SerializerHelper.AskEnemyItemPickUp_Serializer, enemyinstanceid, binditemsindex)
end

function SerializerHelper.AskTaskPlateLoadComplete_Serializer(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskTaskPlateLoadComplete(taskid)
	return self:Invoke(67803808, SerializerHelper.AskTaskPlateLoadComplete_Serializer, taskid)
end

function SerializerHelper.AskMultipleSkillHit2_Serializer(writer, skillhitdata)
	SerializeBase.WriteComplex(writer, skillhitdata, SerializeAuto.WriteSkillHitData, "skillhitdata", false)
end

function ClientToGameSceneDelegate:AskMultipleSkillHit2(skillhitdata)
	self:Notify(67803963, SerializerHelper.AskMultipleSkillHit2_Serializer, skillhitdata)
end

function SerializerHelper.AskRouletteDiscardPublicWeapon_Serializer(writer, index)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskRouletteDiscardPublicWeapon(index)
	self:Notify(67811819, SerializerHelper.AskRouletteDiscardPublicWeapon_Serializer, index)
end

function SerializerHelper.AskSkillSummon_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillSummonData, "data", false)
end

function ClientToGameSceneDelegate:AskSkillSummon(data)
	self:Notify(67813751, SerializerHelper.AskSkillSummon_Serializer, data)
end

function SerializerHelper.AskGetWorldEnemyReward_Serializer(writer, triggerenemyid)
	SerializeBase.WritePrimitive(writer, triggerenemyid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskGetWorldEnemyReward(triggerenemyid)
	return self:Invoke(67816059, SerializerHelper.AskGetWorldEnemyReward_Serializer, triggerenemyid)
end

function SerializerHelper.RecordSceneItemBehavior_Serializer(writer, type, id, label, behavior, extrainfo)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	writer:WriteString(label, false, "label", 256)
	writer:WriteString(behavior, false, "behavior", 256)
	writer:WriteString(extrainfo, false, "extrainfo", 256)
end

function ClientToGameSceneDelegate:RecordSceneItemBehavior(type, id, label, behavior, extrainfo)
	return self:Invoke(67820583, SerializerHelper.RecordSceneItemBehavior_Serializer, type, id, label, behavior, extrainfo)
end

function SerializerHelper.AskMultiCinemaLeave_Serializer(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskMultiCinemaLeave(locationid)
	return self:Invoke(67824055, SerializerHelper.AskMultiCinemaLeave_Serializer, locationid)
end

function SerializerHelper.AskBreakAction_Serializer(writer, skillinstanceid)
	SerializeBase.WritePrimitive(writer, skillinstanceid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskBreakAction(skillinstanceid)
	self:Notify(67841873, SerializerHelper.AskBreakAction_Serializer, skillinstanceid)
end

function SerializerHelper.AskSwitchSpiritByTaskEvent_Serializer(writer, spiritid, eventid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskSwitchSpiritByTaskEvent(spiritid, eventid)
	self:Notify(67842541, SerializerHelper.AskSwitchSpiritByTaskEvent_Serializer, spiritid, eventid)
end

function SerializerHelper.AskVehicleNavigationPathPointsFromPos_Serializer(writer, navreqid, startposition, targetposition, ignoredirection, ignorealley)
	SerializeBase.WritePrimitive(writer, navreqid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, startposition, SerializeAuto.WriteUXVector3, "startposition")
	SerializeBase.WriteStruct(writer, targetposition, SerializeAuto.WriteUXVector3, "targetposition")
	SerializeBase.WritePrimitive(writer, ignoredirection, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, ignorealley, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskVehicleNavigationPathPointsFromPos(navreqid, startposition, targetposition, ignoredirection, ignorealley)
	return self:Invoke(67843924, SerializerHelper.AskVehicleNavigationPathPointsFromPos_Serializer, navreqid, startposition, targetposition, ignoredirection, ignorealley)
end

function SerializerHelper.AskRepairWeaponDurability_Serializer(writer, weaponinstanceid)
	SerializeBase.WritePrimitive(writer, weaponinstanceid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskRepairWeaponDurability(weaponinstanceid)
	self:Notify(67845859, SerializerHelper.AskRepairWeaponDurability_Serializer, weaponinstanceid)
end

function SerializerHelper.LeaveGomoku_Serializer(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:LeaveGomoku(gadgetuid)
	return self:Invoke(67847807, SerializerHelper.LeaveGomoku_Serializer, gadgetuid)
end

function SerializerHelper.AskCreationDerivedCreate_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteDeriveCreationData, "data", false)
end

function ClientToGameSceneDelegate:AskCreationDerivedCreate(data)
	self:Notify(67852467, SerializerHelper.AskCreationDerivedCreate_Serializer, data)
end

function SerializerHelper.ReportSpecialTargetPosition_Serializer(writer, enemyid, position)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
end

function ClientToGameSceneDelegate:ReportSpecialTargetPosition(enemyid, position)
	self:Notify(67852877, SerializerHelper.ReportSpecialTargetPosition_Serializer, enemyid, position)
end

function SerializerHelper.AskAddDestructibleHp_Serializer(writer, id, hp)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, hp, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskAddDestructibleHp(id, hp)
	self:Notify(67855798, SerializerHelper.AskAddDestructibleHp_Serializer, id, hp)
end

function SerializerHelper.AskBreakStimReaction_Serializer(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskBreakStimReaction(agentid)
	self:Notify(67857491, SerializerHelper.AskBreakStimReaction_Serializer, agentid)
end

function SerializerHelper.AskClientNpcFindPath_Serializer(writer, from, to)
	SerializeBase.WriteStruct(writer, from, SerializeAuto.WriteUXVector3, "from")
	SerializeBase.WriteStruct(writer, to, SerializeAuto.WriteUXVector3, "to")
end

function ClientToGameSceneDelegate:AskClientNpcFindPath(from, to)
	return self:Invoke(67857546, SerializerHelper.AskClientNpcFindPath_Serializer, from, to)
end

function SerializerHelper.AskPreRaidTeleport_Serializer(writer, pos, facing)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskPreRaidTeleport(pos, facing)
	self:Notify(67859841, SerializerHelper.AskPreRaidTeleport_Serializer, pos, facing)
end

function SerializerHelper.AskPreparePlotEvent_Serializer(writer, eventid, agententityid, responseid, source)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, responseid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, source, SerializeAuto.WriteClientActionTarget, "source")
end

function ClientToGameSceneDelegate:AskPreparePlotEvent(eventid, agententityid, responseid, source)
	self:Notify(67861907, SerializerHelper.AskPreparePlotEvent_Serializer, eventid, agententityid, responseid, source)
end

function SerializerHelper.AskFinishNpcStun_Serializer(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskFinishNpcStun(agentid)
	self:Notify(67862774, SerializerHelper.AskFinishNpcStun_Serializer, agentid)
end

function SerializerHelper.EnterGomokuZoneEndGame_Serializer(writer, gadgetuid, agentid, endgameid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, endgameid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:EnterGomokuZoneEndGame(gadgetuid, agentid, endgameid)
	return self:Invoke(67865936, SerializerHelper.EnterGomokuZoneEndGame_Serializer, gadgetuid, agentid, endgameid)
end

function SerializerHelper.AskEnemyUseClientSkill_Serializer(writer, enemyid, skillid, destructibleid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, destructibleid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskEnemyUseClientSkill(enemyid, skillid, destructibleid)
	self:Notify(67865957, SerializerHelper.AskEnemyUseClientSkill_Serializer, enemyid, skillid, destructibleid)
end

function SerializerHelper.AskChangePedToVehicleNpc_Serializer(writer, npcinstanceid, bindvehicleinstanceid, seatindex)
	SerializeBase.WritePrimitive(writer, npcinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, bindvehicleinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, seatindex, writer.WriteByte, 0)
end

function ClientToGameSceneDelegate:AskChangePedToVehicleNpc(npcinstanceid, bindvehicleinstanceid, seatindex)
	return self:Invoke(67866416, SerializerHelper.AskChangePedToVehicleNpc_Serializer, npcinstanceid, bindvehicleinstanceid, seatindex)
end

function SerializerHelper.AskVehicleNavigationPathLengthList_Serializer(writer, targetpositionlist, ignoredirection, ignorealley)
	SerializeBase.WriteList(writer, targetpositionlist, SerializeBase.WriteStructWrap(SerializeAuto.WriteUXVector3, "targetpositionlist"), nil, "targetpositionlist", false, 1024, nil)
	SerializeBase.WritePrimitive(writer, ignoredirection, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, ignorealley, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskVehicleNavigationPathLengthList(targetpositionlist, ignoredirection, ignorealley)
	return self:Invoke(67870425, SerializerHelper.AskVehicleNavigationPathLengthList_Serializer, targetpositionlist, ignoredirection, ignorealley)
end

function SerializerHelper.AskStartTaxiNavigate_Serializer(writer, taxiid, totaldis)
	SerializeBase.WritePrimitive(writer, taxiid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, totaldis, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskStartTaxiNavigate(taxiid, totaldis)
	return self:Invoke(67870867, SerializerHelper.AskStartTaxiNavigate_Serializer, taxiid, totaldis)
end

function SerializerHelper.AskRemoveAttractPoint_Serializer(writer, uid)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskRemoveAttractPoint(uid)
	self:Notify(67873154, SerializerHelper.AskRemoveAttractPoint_Serializer, uid)
end

function SerializerHelper.LeaveBowling_Serializer(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:LeaveBowling(gadgetuid)
	return self:Invoke(67873377, SerializerHelper.LeaveBowling_Serializer, gadgetuid)
end

function SerializerHelper.ApproachAgent_Serializer(writer, instanceid, spoonagentid, distance)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, spoonagentid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, distance, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:ApproachAgent(instanceid, spoonagentid, distance)
	return self:Invoke(67877988, SerializerHelper.ApproachAgent_Serializer, instanceid, spoonagentid, distance)
end

function SerializerHelper.SendCustomHotPatchClientToGameScene_Serializer(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

function ClientToGameSceneDelegate:SendCustomHotPatchClientToGameScene(data)
	return self:Invoke(67882363, SerializerHelper.SendCustomHotPatchClientToGameScene_Serializer, data)
end

function SerializerHelper.PlaceGomokuPiece_Serializer(writer, gadgetuid, x, y)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, x, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, y, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:PlaceGomokuPiece(gadgetuid, x, y)
	return self:Invoke(67882560, SerializerHelper.PlaceGomokuPiece_Serializer, gadgetuid, x, y)
end

function SerializerHelper.AskPreprocessVehicleSpawnArea_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskPreprocessVehicleSpawnArea()
	self:Notify(67884766, SerializerHelper.AskPreprocessVehicleSpawnArea_Serializer)
end

function SerializerHelper.AskSpawnSubAgent_Serializer(writer, unitid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskSpawnSubAgent(unitid)
	self:Notify(67889338, SerializerHelper.AskSpawnSubAgent_Serializer, unitid)
end

function SerializerHelper.AskGravitySuspend_Serializer(writer, pid, stiffid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, stiffid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskGravitySuspend(pid, stiffid)
	self:Notify(67889984, SerializerHelper.AskGravitySuspend_Serializer, pid, stiffid)
end

function SerializerHelper.AskSetDataToOwner_Serializer(writer, datas)
	SerializeBase.WriteList(writer, datas, SerializeBase.WriteComplexWrap(SerializeAuto.WriteOwnerSyncData, "OwnerSyncData", false), nil, "datas", false, 1024, nil)
end

function ClientToGameSceneDelegate:AskSetDataToOwner(datas)
	self:Notify(67891924, SerializerHelper.AskSetDataToOwner_Serializer, datas)
end

function SerializerHelper.AskEnterFeiSuoCrouch_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskEnterFeiSuoCrouch()
	self:Notify(67901094, SerializerHelper.AskEnterFeiSuoCrouch_Serializer)
end

function SerializerHelper.AskDestroyDestructibleObjects_Serializer(writer, ids)
	SerializeBase.WriteList(writer, ids, writer.WriteUInt64, 0, "ids", false, 256, nil)
end

function ClientToGameSceneDelegate:AskDestroyDestructibleObjects(ids)
	self:Notify(67901188, SerializerHelper.AskDestroyDestructibleObjects_Serializer, ids)
end

function SerializerHelper.AskHandHoldDestructibleObject_Serializer(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskHandHoldDestructibleObject(id)
	self:Notify(67905199, SerializerHelper.AskHandHoldDestructibleObject_Serializer, id)
end

function SerializerHelper.AskRouletteSwitchPublicWeapon_Serializer(writer, index)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskRouletteSwitchPublicWeapon(index)
	self:Notify(67908822, SerializerHelper.AskRouletteSwitchPublicWeapon_Serializer, index)
end

function SerializerHelper.AskClaimVehicleSeat_Serializer(writer, vehicleentityid, seatindices)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
	SerializeBase.WriteList(writer, seatindices, writer.WriteByte, 0, "seatindices", false, 32, nil)
end

function ClientToGameSceneDelegate:AskClaimVehicleSeat(vehicleentityid, seatindices)
	return self:Invoke(67911371, SerializerHelper.AskClaimVehicleSeat_Serializer, vehicleentityid, seatindices)
end

function SerializerHelper.AskDoSpoonServerAction_Serializer(writer, id, nodeid, index, graphid, param)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, graphid, writer.WriteInt32, 0)
	SerializeBase.WriteComplex(writer, param, SerializeAuto.WriteSpoonActionParam, "param", true)
end

function ClientToGameSceneDelegate:AskDoSpoonServerAction(id, nodeid, index, graphid, param)
	return self:Invoke(67913564, SerializerHelper.AskDoSpoonServerAction_Serializer, id, nodeid, index, graphid, param)
end

function SerializerHelper.AskKillVehicle_Serializer(writer, vehicleid, reason)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, reason, writer.WriteByte, 0)
end

function ClientToGameSceneDelegate:AskKillVehicle(vehicleid, reason)
	self:Notify(67916588, SerializerHelper.AskKillVehicle_Serializer, vehicleid, reason)
end

function SerializerHelper.AskNpcFinishEnterOrExitVehicle_Serializer(writer, syncdata)
	SerializeBase.WriteComplex(writer, syncdata, SerializeAuto.WriteNpcVehicleDriveStateInfo, "syncdata", false)
end

function ClientToGameSceneDelegate:AskNpcFinishEnterOrExitVehicle(syncdata)
	self:Notify(67924130, SerializerHelper.AskNpcFinishEnterOrExitVehicle_Serializer, syncdata)
end

function SerializerHelper.AskControlPowerHoldEnemyUp_Serializer(writer, enemyid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskControlPowerHoldEnemyUp(enemyid)
	return self:Invoke(67924447, SerializerHelper.AskControlPowerHoldEnemyUp_Serializer, enemyid)
end

function SerializerHelper.AskAetherAIHandleVehicleCollision_Serializer(writer, vehicleinstanceid)
	SerializeBase.WritePrimitive(writer, vehicleinstanceid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskAetherAIHandleVehicleCollision(vehicleinstanceid)
	self:Notify(67928569, SerializerHelper.AskAetherAIHandleVehicleCollision_Serializer, vehicleinstanceid)
end

function SerializerHelper.AskSummonVehicle_Serializer(writer, vehicleconfigid, position, facingdirection)
	SerializeBase.WritePrimitive(writer, vehicleconfigid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, facingdirection, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskSummonVehicle(vehicleconfigid, position, facingdirection)
	return self:Invoke(67928941, SerializerHelper.AskSummonVehicle_Serializer, vehicleconfigid, position, facingdirection)
end

function SerializerHelper.AskCreateSymbiosisGadget_Serializer(writer, id, index)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskCreateSymbiosisGadget(id, index)
	return self:Invoke(67936712, SerializerHelper.AskCreateSymbiosisGadget_Serializer, id, index)
end

function SerializerHelper.ReportEnemyWeaponState_Serializer(writer, enemyweaponstates)
	SerializeBase.WriteList(writer, enemyweaponstates, SerializeBase.WriteStructWrap(SerializeAuto.WriteEnemyWeaponState, "enemyweaponstates"), nil, "enemyweaponstates", false, 256, nil)
end

function ClientToGameSceneDelegate:ReportEnemyWeaponState(enemyweaponstates)
	self:Notify(67940659, SerializerHelper.ReportEnemyWeaponState_Serializer, enemyweaponstates)
end

function SerializerHelper.AskExitVehicleIndoor_Serializer(writer, vehicleentityid)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskExitVehicleIndoor(vehicleentityid)
	self:Notify(67944190, SerializerHelper.AskExitVehicleIndoor_Serializer, vehicleentityid)
end

function SerializerHelper.ReportBattleMoveOneActionLoopEnd_Serializer(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:ReportBattleMoveOneActionLoopEnd(pid)
	self:Notify(67944861, SerializerHelper.ReportBattleMoveOneActionLoopEnd_Serializer, pid)
end

function SerializerHelper.RecordBowlingScore_Serializer(writer, gadgetuid, throwindex, score)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, throwindex, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:RecordBowlingScore(gadgetuid, throwindex, score)
	return self:Invoke(67945135, SerializerHelper.RecordBowlingScore_Serializer, gadgetuid, throwindex, score)
end

function SerializerHelper.AskSetRaidVehicleGpsInfo_Serializer(writer, vehicleentityid, gpsinfo)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
	SerializeBase.WriteComplex(writer, gpsinfo, SerializeAuto.WriteRaidVehicleGpsInfo, "gpsinfo", true)
end

function ClientToGameSceneDelegate:AskSetRaidVehicleGpsInfo(vehicleentityid, gpsinfo)
	self:Notify(67949331, SerializerHelper.AskSetRaidVehicleGpsInfo_Serializer, vehicleentityid, gpsinfo)
end

function SerializerHelper.AskVehicleStopHackerAutonomousDriving_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskVehicleStopHackerAutonomousDriving()
	self:Notify(67950207, SerializerHelper.AskVehicleStopHackerAutonomousDriving_Serializer)
end

function SerializerHelper.AskPoliceDistanceMonitorTrigger_Serializer(writer, distance)
	SerializeBase.WritePrimitive(writer, distance, writer.WriteSingle, 0)
end

function ClientToGameSceneDelegate:AskPoliceDistanceMonitorTrigger(distance)
	self:Notify(67950690, SerializerHelper.AskPoliceDistanceMonitorTrigger_Serializer, distance)
end

function SerializerHelper.AskTeleportToLeavingWaypoint_Serializer(writer, carshopid)
	SerializeBase.WritePrimitive(writer, carshopid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskTeleportToLeavingWaypoint(carshopid)
	return self:Invoke(67953229, SerializerHelper.AskTeleportToLeavingWaypoint_Serializer, carshopid)
end

function SerializerHelper.LeaveAgent_Serializer(writer, instanceid, spoonagentid, distance)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, spoonagentid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, distance, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:LeaveAgent(instanceid, spoonagentid, distance)
	return self:Invoke(67955196, SerializerHelper.LeaveAgent_Serializer, instanceid, spoonagentid, distance)
end

function SerializerHelper.AskAetherAICrowdFollowPointPathDone_Serializer(writer, datalist)
	SerializeBase.WriteList(writer, datalist, SerializeBase.WriteStructWrap(SerializeAuto.WriteClientZoneGraphPathFollowDown, "datalist"), nil, "datalist", false, 10240, nil)
end

function ClientToGameSceneDelegate:AskAetherAICrowdFollowPointPathDone(datalist)
	self:Notify(67955459, SerializerHelper.AskAetherAICrowdFollowPointPathDone_Serializer, datalist)
end

function SerializerHelper.ReportEnemyPrepareFinish_Serializer(writer, enemyid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:ReportEnemyPrepareFinish(enemyid)
	self:Notify(67956663, SerializerHelper.ReportEnemyPrepareFinish_Serializer, enemyid)
end

function SerializerHelper.AskReleaseAIEvent_Serializer(writer, eventname)
	writer:WriteString(eventname, false, "eventname", 32)
end

function ClientToGameSceneDelegate:AskReleaseAIEvent(eventname)
	self:Notify(67958588, SerializerHelper.AskReleaseAIEvent_Serializer, eventname)
end

function SerializerHelper.AskStopVehicleAhead_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskStopVehicleAhead()
	self:Notify(67960111, SerializerHelper.AskStopVehicleAhead_Serializer)
end

function SerializerHelper.AskSkillPauseFrame_Serializer(writer, data)
	SerializeBase.WriteList(writer, data, SerializeBase.WriteComplexWrap(SerializeAuto.WritePauseFrameData, "PauseFrameData", false), nil, "data", false, 256, nil)
end

function ClientToGameSceneDelegate:AskSkillPauseFrame(data)
	return self:Invoke(67961513, SerializerHelper.AskSkillPauseFrame_Serializer, data)
end

function SerializerHelper.ChangeSceneItemEffect_Serializer(writer, type, id, effectid, add)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, effectid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, add, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:ChangeSceneItemEffect(type, id, effectid, add)
	return self:Invoke(67965115, SerializerHelper.ChangeSceneItemEffect_Serializer, type, id, effectid, add)
end

function SerializerHelper.AskBVBSelectChaosBuff_Serializer(writer, buffid)
	SerializeBase.WritePrimitive(writer, buffid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskBVBSelectChaosBuff(buffid)
	return self:Invoke(67965971, SerializerHelper.AskBVBSelectChaosBuff_Serializer, buffid)
end

function SerializerHelper.AskPlayerLeaveMetro_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskPlayerLeaveMetro()
	return self:Invoke(67968069, SerializerHelper.AskPlayerLeaveMetro_Serializer)
end

function SerializerHelper.AskAgentSceneRoomTrigger_Serializer(writer, sceneroomid, spoonagentid, isenter)
	SerializeBase.WritePrimitive(writer, sceneroomid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, spoonagentid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, isenter, writer.WriteBoolean, false)
end

function ClientToGameSceneDelegate:AskAgentSceneRoomTrigger(sceneroomid, spoonagentid, isenter)
	return self:Invoke(67972470, SerializerHelper.AskAgentSceneRoomTrigger_Serializer, sceneroomid, spoonagentid, isenter)
end

function SerializerHelper.RequestRevive_Serializer(writer, type)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
end

function ClientToGameSceneDelegate:RequestRevive(type)
	return self:Invoke(67972627, SerializerHelper.RequestRevive_Serializer, type)
end

function SerializerHelper.AskEndClimb_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskEndClimb()
	self:Notify(67972840, SerializerHelper.AskEndClimb_Serializer)
end

function SerializerHelper.AskTriggerVehicleSpawnArea_Serializer(writer, vehicleconfigid)
	SerializeBase.WritePrimitive(writer, vehicleconfigid, writer.WriteInt32, 0)
end

function ClientToGameSceneDelegate:AskTriggerVehicleSpawnArea(vehicleconfigid)
	self:Notify(67981714, SerializerHelper.AskTriggerVehicleSpawnArea_Serializer, vehicleconfigid)
end

function SerializerHelper.AskCinemaLeave_Serializer(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

function ClientToGameSceneDelegate:AskCinemaLeave(locationid)
	return self:Invoke(67983665, SerializerHelper.AskCinemaLeave_Serializer, locationid)
end

function SerializerHelper.AskRemoveSubAgent_Serializer(writer, unitid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskRemoveSubAgent(unitid)
	self:Notify(67985382, SerializerHelper.AskRemoveSubAgent_Serializer, unitid)
end

function SerializerHelper.SyncStoryCoreClientInfo_Serializer(writer, info)
	writer:WriteString(info, false, "info", 256)
end

function ClientToGameSceneDelegate:SyncStoryCoreClientInfo(info)
	self:Notify(67990771, SerializerHelper.SyncStoryCoreClientInfo_Serializer, info)
end

function SerializerHelper.AskFightGameGetPlayers_Serializer(writer)
	return
end

function ClientToGameSceneDelegate:AskFightGameGetPlayers()
	return self:Invoke(67992584, SerializerHelper.AskFightGameGetPlayers_Serializer)
end

function SerializerHelper.AskChaosNpcDestoryed_Serializer(writer, instanceid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
end

function ClientToGameSceneDelegate:AskChaosNpcDestoryed(instanceid)
	self:Notify(67997961, SerializerHelper.AskChaosNpcDestoryed_Serializer, instanceid)
end

return ClientToGameSceneDelegate
