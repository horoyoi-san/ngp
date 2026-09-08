-- Original chunk: @Lua\LuaGen\AutoGen\ClientToGameSceneDelegate.lua
-- Decompiled from: 00075_ClientToGameSceneDelegate.lua_072bb317bbce.luajit

local invoker = require("LX6/Service/LuaRPCInvoker")
local SerializeBase = require("LX6/Service/RPCSerializeBase")
local SerializeAuto = require("LuaGen/AutoGen/RPCSerializeAuto")
local NetworkManager = LX6.Engine.NetworkManager.Instance
local SerializerHelper = {}
local ClientToGameSceneDelegate = invoker.New(invoker)

ClientToGameSceneDelegate.Sender = function()
	return NetworkManager.LuaGameRpcProcessor
end

SerializerHelper.ReportPlayActionWithLayerFinish_Serializer = function(writer, enemyid, actionid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, actionid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.ReportPlayActionWithLayerFinish = function(self, enemyid, actionid)
	self.Notify(self, 67000146, SerializerHelper.ReportPlayActionWithLayerFinish_Serializer, enemyid, actionid)
end

SerializerHelper.AskExitVehicleIndoor_Serializer = function(writer, vehicleentityid)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskExitVehicleIndoor = function(self, vehicleentityid)
	self.Notify(self, 67000629, SerializerHelper.AskExitVehicleIndoor_Serializer, vehicleentityid)
end

SerializerHelper.AskAddClientBuffWithReleaser_Serializer = function(writer, unitid, buffid, releaserid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, buffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, releaserid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskAddClientBuffWithReleaser = function(self, unitid, buffid, releaserid)
	self.Notify(self, 67002230, SerializerHelper.AskAddClientBuffWithReleaser_Serializer, unitid, buffid, releaserid)
end

SerializerHelper.AskAgentStartNpcSound_Serializer = function(writer, agententityid, libraryid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, libraryid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskAgentStartNpcSound = function(self, agententityid, libraryid)
	return self.Invoke(self, 67003057, SerializerHelper.AskAgentStartNpcSound_Serializer, agententityid, libraryid)
end

SerializerHelper.ReportCreationVehicleEnterOrLeaves_Serializer = function(writer, datas)
	SerializeBase.WriteList7Bit(writer, datas, SerializeBase.WriteStructWrap(SerializeAuto.WriteCreationEnterLeave, "datas"), nil, "datas", false, RpcLengthLimits.IClientToGameScene_ReportCreationVehicleEnterOrLeaves_datas, nil)
end

ClientToGameSceneDelegate.ReportCreationVehicleEnterOrLeaves = function(self, datas)
	self.Notify(self, 67004409, SerializerHelper.ReportCreationVehicleEnterOrLeaves_Serializer, datas)
end

SerializerHelper.SetGameGroundPlayerSurrender_Serializer = function(writer, value)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.SetGameGroundPlayerSurrender = function(self, value)
	return self.Invoke(self, 67004521, SerializerHelper.SetGameGroundPlayerSurrender_Serializer, value)
end

SerializerHelper.AskWeaponEquipBullets_Serializer = function(writer, weaponinstanceid, bulletid)
	SerializeBase.WritePrimitive(writer, weaponinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, bulletid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskWeaponEquipBullets = function(self, weaponinstanceid, bulletid)
	return self.Invoke(self, 67004979, SerializerHelper.AskWeaponEquipBullets_Serializer, weaponinstanceid, bulletid)
end

SerializerHelper.AskVehicleStuck_Serializer = function(writer, vehicleid)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskVehicleStuck = function(self, vehicleid)
	return self.Invoke(self, 67006072, SerializerHelper.AskVehicleStuck_Serializer, vehicleid)
end

SerializerHelper.AskPlayerChangePositionByScenePortal_Serializer = function(writer, bonfireuniqueid)
	SerializeBase.WritePrimitive(writer, bonfireuniqueid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskPlayerChangePositionByScenePortal = function(self, bonfireuniqueid)
	return self.Invoke(self, 67006840, SerializerHelper.AskPlayerChangePositionByScenePortal_Serializer, bonfireuniqueid)
end

SerializerHelper.AskExtractionShooterShiftContainerItem_Serializer = function(writer, containerinstanceid, fromcellx, fromcelly, tocellx, tocelly, isrotated)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, fromcellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromcelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tocellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tocelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isrotated, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskExtractionShooterShiftContainerItem = function(self, containerinstanceid, fromcellx, fromcelly, tocellx, tocelly, isrotated)
	return self.Invoke(self, 67007990, SerializerHelper.AskExtractionShooterShiftContainerItem_Serializer, containerinstanceid, fromcellx, fromcelly, tocellx, tocelly, isrotated)
end

SerializerHelper.AskStartBVBGame_Serializer = function(writer, chaosbattlenpcid, gamemode, enterfightposition)
	SerializeBase.WritePrimitive(writer, chaosbattlenpcid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(gamemode, 49, 0), writer.WriteByte, 0)
	SerializeBase.WriteStruct(writer, enterfightposition, SerializeAuto.WriteUXVector3, "enterfightposition")
end

ClientToGameSceneDelegate.AskStartBVBGame = function(self, chaosbattlenpcid, gamemode, enterfightposition)
	return self.Invoke(self, 67008434, SerializerHelper.AskStartBVBGame_Serializer, chaosbattlenpcid, gamemode, enterfightposition)
end

SerializerHelper.ReportBehaviorSeqStartList_Serializer = function(writer, infos)
	SerializeBase.WriteList7Bit(writer, infos, SerializeBase.WriteStructWrap(SerializeAuto.WriteReportBehaviorSeqStartInfo, "infos"), nil, "infos", false, RpcLengthLimits.IClientToGameScene_ReportBehaviorSeqStartList_infos, nil)
end

ClientToGameSceneDelegate.ReportBehaviorSeqStartList = function(self, infos)
	self.Notify(self, 67008858, SerializerHelper.ReportBehaviorSeqStartList_Serializer, infos)
end

SerializerHelper.AskSkillCloseShield_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillShieldData, "data", false)
end

ClientToGameSceneDelegate.AskSkillCloseShield = function(self, data)
	self.Notify(self, 67010885, SerializerHelper.AskSkillCloseShield_Serializer, data)
end

SerializerHelper.ChooseGomokuSkill_Serializer = function(writer, gadgetuid, skillid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.ChooseGomokuSkill = function(self, gadgetuid, skillid)
	return self.Invoke(self, 67011276, SerializerHelper.ChooseGomokuSkill_Serializer, gadgetuid, skillid)
end

SerializerHelper.AskOnMetroExitStation_Serializer = function(writer, metroids)
	SerializeBase.WriteList7Bit(writer, metroids, writer.WriteInt32, 0, "metroids", false, RpcLengthLimits.IClientToGameScene_AskOnMetroExitStation_metroIds, nil)
end

ClientToGameSceneDelegate.AskOnMetroExitStation = function(self, metroids)
	self.Notify(self, 67011284, SerializerHelper.AskOnMetroExitStation_Serializer, metroids)
end

SerializerHelper.AskSummonVehicle_Serializer = function(writer, vehicleconfigid, position, facingdirection)
	SerializeBase.WritePrimitive(writer, vehicleconfigid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, facingdirection, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskSummonVehicle = function(self, vehicleconfigid, position, facingdirection)
	return self.Invoke(self, 67012447, SerializerHelper.AskSummonVehicle_Serializer, vehicleconfigid, position, facingdirection)
end

SerializerHelper.ReportUnitHitFlyEnd_Serializer = function(writer, defenderid, speed)
	SerializeBase.WritePrimitive(writer, defenderid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, speed, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.ReportUnitHitFlyEnd = function(self, defenderid, speed)
	return self.Invoke(self, 67015647, SerializerHelper.ReportUnitHitFlyEnd_Serializer, defenderid, speed)
end

SerializerHelper.AskAgentPoiActionDone_Serializer = function(writer, instanceid, nowpoiactionid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, nowpoiactionid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskAgentPoiActionDone = function(self, instanceid, nowpoiactionid)
	self.Notify(self, 67016793, SerializerHelper.AskAgentPoiActionDone_Serializer, instanceid, nowpoiactionid)
end

SerializerHelper.ChangeVehicleDoorState_Serializer = function(writer, doorindex, vehicleid, reason)
	SerializeBase.WritePrimitive(writer, doorindex, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(reason, 50, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.ChangeVehicleDoorState = function(self, doorindex, vehicleid, reason)
	return self.Invoke(self, 67018217, SerializerHelper.ChangeVehicleDoorState_Serializer, doorindex, vehicleid, reason)
end

SerializerHelper.AskBVBGetReady_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskBVBGetReady = function(self)
	return self.Invoke(self, 67022021, SerializerHelper.AskBVBGetReady_Serializer)
end

SerializerHelper.AskOperateDestructibleObjects_Serializer = function(writer, ids, operation)
	SerializeBase.WriteList7Bit(writer, ids, writer.WriteUInt64, 0, "ids", false, RpcLengthLimits.IClientToGameScene_AskOperateDestructibleObjects_ids, nil)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(operation, 51, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskOperateDestructibleObjects = function(self, ids, operation)
	self.Notify(self, 67025330, SerializerHelper.AskOperateDestructibleObjects_Serializer, ids, operation)
end

SerializerHelper.RecordAgentBowlingScore_Serializer = function(writer, gadgetuid, npcid, throwindex, score)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, throwindex, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.RecordAgentBowlingScore = function(self, gadgetuid, npcid, throwindex, score)
	return self.Invoke(self, 67025901, SerializerHelper.RecordAgentBowlingScore_Serializer, gadgetuid, npcid, throwindex, score)
end

SerializerHelper.AskEndPreparePlotEvent_Serializer = function(writer, eventid, agententityid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskEndPreparePlotEvent = function(self, eventid, agententityid)
	self.Notify(self, 67025961, SerializerHelper.AskEndPreparePlotEvent_Serializer, eventid, agententityid)
end

SerializerHelper.ReportRayCast4DRes_Serializer = function(writer, infos)
	SerializeBase.WriteList7Bit(writer, infos, SerializeBase.WriteStructWrap(SerializeAuto.WriteRayCast4DResInfo, "infos"), nil, "infos", false, RpcLengthLimits.IClientToGameScene_ReportRayCast4DRes_infos, nil)
end

ClientToGameSceneDelegate.ReportRayCast4DRes = function(self, infos)
	self.Notify(self, 67026404, SerializerHelper.ReportRayCast4DRes_Serializer, infos)
end

SerializerHelper.AskBasketballOperatorAction_Serializer = function(writer, askoperatorparam)
	SerializeBase.WriteComplex(writer, askoperatorparam, SerializeAuto.WriteBasketballAskOperatorParam, "askoperatorparam", false)
end

ClientToGameSceneDelegate.AskBasketballOperatorAction = function(self, askoperatorparam)
	return self.Invoke(self, 67028937, SerializerHelper.AskBasketballOperatorAction_Serializer, askoperatorparam)
end

SerializerHelper.AskReportVehicleCollideCount_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskReportVehicleCollideCount = function(self)
	self.Notify(self, 67030531, SerializerHelper.AskReportVehicleCollideCount_Serializer)
end

SerializerHelper.SendCustomHotPatchClientToGameScene_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

ClientToGameSceneDelegate.SendCustomHotPatchClientToGameScene = function(self, data)
	return self.Invoke(self, 67031245, SerializerHelper.SendCustomHotPatchClientToGameScene_Serializer, data)
end

SerializerHelper.AskCinemaRemoveNpc_Serializer = function(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskCinemaRemoveNpc = function(self, locationid)
	return self.Invoke(self, 67033191, SerializerHelper.AskCinemaRemoveNpc_Serializer, locationid)
end

SerializerHelper.AskVehicleTriggerAiPathEvent_Serializer = function(writer, vehicleid, eventname)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	writer.WriteString(writer, eventname, false, "AskVehicleTriggerAiPathEvent.eventName", RpcLengthLimits.IClientToGameScene_AskVehicleTriggerAiPathEvent_eventName)
end

ClientToGameSceneDelegate.AskVehicleTriggerAiPathEvent = function(self, vehicleid, eventname)
	self.Notify(self, 67035939, SerializerHelper.AskVehicleTriggerAiPathEvent_Serializer, vehicleid, eventname)
end

SerializerHelper.AskDetachAttachment_Serializer = function(writer, targetunitid, slotid, entryid)
	SerializeBase.WritePrimitive(writer, targetunitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, slotid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, entryid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskDetachAttachment = function(self, targetunitid, slotid, entryid)
	return self.Invoke(self, 67036716, SerializerHelper.AskDetachAttachment_Serializer, targetunitid, slotid, entryid)
end

SerializerHelper.AskClientUseCommonSkill_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillUseData, "data", false)
end

ClientToGameSceneDelegate.AskClientUseCommonSkill = function(self, data)
	return self.Invoke(self, 67037025, SerializerHelper.AskClientUseCommonSkill_Serializer, data)
end

SerializerHelper.AskVehicleNitro_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteVehicleNitroData, "data", false)
end

ClientToGameSceneDelegate.AskVehicleNitro = function(self, data)
	return self.Invoke(self, 67037029, SerializerHelper.AskVehicleNitro_Serializer, data)
end

SerializerHelper.LeaveDart_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.LeaveDart = function(self, gadgetuid)
	return self.Invoke(self, 67039599, SerializerHelper.LeaveDart_Serializer, gadgetuid)
end

SerializerHelper.AskInterruptSkillExecute2_Serializer = function(writer, executorid, targetuid, requestdelayholdtrustee)
	SerializeBase.WritePrimitive(writer, executorid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, requestdelayholdtrustee, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskInterruptSkillExecute2 = function(self, executorid, targetuid, requestdelayholdtrustee)
	return self.Invoke(self, 67041011, SerializerHelper.AskInterruptSkillExecute2_Serializer, executorid, targetuid, requestdelayholdtrustee)
end

SerializerHelper.AskNotifyDestructibleHits_Serializer = function(writer, hits)
	SerializeBase.WriteDict7Bit(writer, hits, writer.WriteUInt64, SerializeBase.WriteComplexWrap(SerializeAuto.WriteDestructibleHitTypeList, "DestructibleHitTypeList", false), nil, "hits", false, RpcLengthLimits.IClientToGameScene_AskNotifyDestructibleHits_hits)
end

ClientToGameSceneDelegate.AskNotifyDestructibleHits = function(self, hits)
	return self.Invoke(self, 67043150, SerializerHelper.AskNotifyDestructibleHits_Serializer, hits)
end

SerializerHelper.AskControlPowerHoldEnemyFallGround_Serializer = function(writer, enemyid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskControlPowerHoldEnemyFallGround = function(self, enemyid)
	return self.Invoke(self, 67043294, SerializerHelper.AskControlPowerHoldEnemyFallGround_Serializer, enemyid)
end

SerializerHelper.AskStopControlAgent_Serializer = function(writer, clearagent)
	SerializeBase.WritePrimitive(writer, clearagent, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskStopControlAgent = function(self, clearagent)
	return self.Invoke(self, 67046103, SerializerHelper.AskStopControlAgent_Serializer, clearagent)
end

SerializerHelper.LeaveRingToss_Serializer = function(writer, gadgetuid, abort)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, abort, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.LeaveRingToss = function(self, gadgetuid, abort)
	return self.Invoke(self, 67046402, SerializerHelper.LeaveRingToss_Serializer, gadgetuid, abort)
end

SerializerHelper.AskVehicleHit_Serializer = function(writer, hitdata)
	SerializeBase.WriteComplex(writer, hitdata, SerializeAuto.WriteVehicleHitData, "hitdata", false)
end

ClientToGameSceneDelegate.AskVehicleHit = function(self, hitdata)
	return self.Invoke(self, 67054018, SerializerHelper.AskVehicleHit_Serializer, hitdata)
end

SerializerHelper.AskExtractionShooterShiftSlotItemToContainer_Serializer = function(writer, slotgroupbagconfigid, fromslotindex, containerinstanceid, tocellx, tocelly, isrotated)
	SerializeBase.WritePrimitive(writer, slotgroupbagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromslotindex, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, tocellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tocelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isrotated, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskExtractionShooterShiftSlotItemToContainer = function(self, slotgroupbagconfigid, fromslotindex, containerinstanceid, tocellx, tocelly, isrotated)
	return self.Invoke(self, 67054596, SerializerHelper.AskExtractionShooterShiftSlotItemToContainer_Serializer, slotgroupbagconfigid, fromslotindex, containerinstanceid, tocellx, tocelly, isrotated)
end

SerializerHelper.AskSkillExecute3_Serializer = function(writer, seconddata, firstenddata)
	SerializeBase.WriteComplex(writer, seconddata, SerializeAuto.WriteSkillExecuteData, "seconddata", false)
	SerializeBase.WriteComplex(writer, firstenddata, SerializeAuto.WriteSkillExecuteEndData, "firstenddata", false)
end

ClientToGameSceneDelegate.AskSkillExecute3 = function(self, seconddata, firstenddata)
	return self.Invoke(self, 67056172, SerializerHelper.AskSkillExecute3_Serializer, seconddata, firstenddata)
end

SerializerHelper.AskVehicleChangeAutonomousDrivingTarget_Serializer = function(writer, targetposition)
	SerializeBase.WriteStruct(writer, targetposition, SerializeAuto.WriteUXVector3, "targetposition")
end

ClientToGameSceneDelegate.AskVehicleChangeAutonomousDrivingTarget = function(self, targetposition)
	return self.Invoke(self, 67057156, SerializerHelper.AskVehicleChangeAutonomousDrivingTarget_Serializer, targetposition)
end

SerializerHelper.AskRestaurantInviteNpc_Serializer = function(writer, restaurantid)
	SerializeBase.WritePrimitive(writer, restaurantid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskRestaurantInviteNpc = function(self, restaurantid)
	self.Notify(self, 67057178, SerializerHelper.AskRestaurantInviteNpc_Serializer, restaurantid)
end

SerializerHelper.AskReportLogicAgentCommandSuccess2_Serializer = function(writer, data)
	SerializeBase.WriteList7Bit(writer, data, SerializeBase.WriteStructWrap(SerializeAuto.WriteLogicAgentCommandSuccessData, "data"), nil, "data", false, RpcLengthLimits.IClientToGameScene_AskReportLogicAgentCommandSuccess2_data, nil)
end

ClientToGameSceneDelegate.AskReportLogicAgentCommandSuccess2 = function(self, data)
	self.Notify(self, 67057559, SerializerHelper.AskReportLogicAgentCommandSuccess2_Serializer, data)
end

SerializerHelper.AskSkillAddState_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillStateData, "data", false)
end

ClientToGameSceneDelegate.AskSkillAddState = function(self, data)
	self.Notify(self, 67059542, SerializerHelper.AskSkillAddState_Serializer, data)
end

SerializerHelper.TriggerBasketballFinish_Serializer = function(writer, success)
	SerializeBase.WritePrimitive(writer, success, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.TriggerBasketballFinish = function(self, success)
	return self.Invoke(self, 67060117, SerializerHelper.TriggerBasketballFinish_Serializer, success)
end

SerializerHelper.AskCreationTouchMultiPlayer_Serializer = function(writer, data)
	SerializeBase.WriteList7Bit(writer, data, SerializeBase.WriteStructWrap(SerializeAuto.WriteCreationHitData, "data"), nil, "data", false, RpcLengthLimits.IClientToGameScene_AskCreationTouchMultiPlayer_data, nil)
end

ClientToGameSceneDelegate.AskCreationTouchMultiPlayer = function(self, data)
	self.Notify(self, 67060477, SerializerHelper.AskCreationTouchMultiPlayer_Serializer, data)
end

SerializerHelper.AskCreationDerivedCreate_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteDeriveCreationData, "data", false)
end

ClientToGameSceneDelegate.AskCreationDerivedCreate = function(self, data)
	self.Notify(self, 67060857, SerializerHelper.AskCreationDerivedCreate_Serializer, data)
end

SerializerHelper.AskStartScratchGame_Serializer = function(writer, gadgetid, scratchsubtype)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(scratchsubtype, 52, 1), writer.WriteByte, 1)
end

ClientToGameSceneDelegate.AskStartScratchGame = function(self, gadgetid, scratchsubtype)
	return self.Invoke(self, 67062589, SerializerHelper.AskStartScratchGame_Serializer, gadgetid, scratchsubtype)
end

SerializerHelper.CheckCanOccupySceneDevice_Serializer = function(writer, type, id, index, onlycheck, executor)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, onlycheck, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, executor, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.CheckCanOccupySceneDevice = function(self, type, id, index, onlycheck, executor)
	return self.Invoke(self, 67063877, SerializerHelper.CheckCanOccupySceneDevice_Serializer, type, id, index, onlycheck, executor)
end

SerializerHelper.AskUseChefSkill_Serializer = function(writer, stoveid, skillid)
	SerializeBase.WritePrimitive(writer, stoveid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskUseChefSkill = function(self, stoveid, skillid)
	return self.Invoke(self, 67064491, SerializerHelper.AskUseChefSkill_Serializer, stoveid, skillid)
end

SerializerHelper.AskChineseChessFlipEnterZoneDoubleAI_Serializer = function(writer, gadgetuid, agentid, useredpiece, difficulty)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, useredpiece, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(difficulty, 53, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskChineseChessFlipEnterZoneDoubleAI = function(self, gadgetuid, agentid, useredpiece, difficulty)
	return self.Invoke(self, 67066928, SerializerHelper.AskChineseChessFlipEnterZoneDoubleAI_Serializer, gadgetuid, agentid, useredpiece, difficulty)
end

SerializerHelper.AskSpoonClientAttack_Serializer = function(writer, taskid, hurthp)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, hurthp, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskSpoonClientAttack = function(self, taskid, hurthp)
	self.Notify(self, 67067896, SerializerHelper.AskSpoonClientAttack_Serializer, taskid, hurthp)
end

SerializerHelper.AskHackingNpc_Serializer = function(writer, instanceid, index)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskHackingNpc = function(self, instanceid, index)
	return self.Invoke(self, 67070057, SerializerHelper.AskHackingNpc_Serializer, instanceid, index)
end

SerializerHelper.AskAetherAIHandleVehicleCollision_Serializer = function(writer, vehicleinstanceid)
	SerializeBase.WritePrimitive(writer, vehicleinstanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskAetherAIHandleVehicleCollision = function(self, vehicleinstanceid)
	self.Notify(self, 67074855, SerializerHelper.AskAetherAIHandleVehicleCollision_Serializer, vehicleinstanceid)
end

SerializerHelper.LeaveBalloon_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.LeaveBalloon = function(self, gadgetuid)
	return self.Invoke(self, 67075062, SerializerHelper.LeaveBalloon_Serializer, gadgetuid)
end

SerializerHelper.CheckCanLinkOccupyGadget_Serializer = function(writer, id, linkid, onlycheck)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, linkid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, onlycheck, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.CheckCanLinkOccupyGadget = function(self, id, linkid, onlycheck)
	return self.Invoke(self, 67075505, SerializerHelper.CheckCanLinkOccupyGadget_Serializer, id, linkid, onlycheck)
end

SerializerHelper.BBQPutMeatToBowl_Serializer = function(writer, gadgetuid, meatid, targetseatindex)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, meatid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, targetseatindex, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.BBQPutMeatToBowl = function(self, gadgetuid, meatid, targetseatindex)
	return self.Invoke(self, 67075600, SerializerHelper.BBQPutMeatToBowl_Serializer, gadgetuid, meatid, targetseatindex)
end

SerializerHelper.AskRemoveClientCreatedWeapons_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskRemoveClientCreatedWeapons = function(self)
	self.Notify(self, 67078406, SerializerHelper.AskRemoveClientCreatedWeapons_Serializer)
end

SerializerHelper.ReportAgentInteract2F_Serializer = function(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportAgentInteract2F = function(self, agententityid)
	self.Notify(self, 67080058, SerializerHelper.ReportAgentInteract2F_Serializer, agententityid)
end

SerializerHelper.AskLeaveMoveGround_Serializer = function(writer, pid, movegroundid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, movegroundid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskLeaveMoveGround = function(self, pid, movegroundid)
	return self.Invoke(self, 67083087, SerializerHelper.AskLeaveMoveGround_Serializer, pid, movegroundid)
end

SerializerHelper.AskInteractCmds_Serializer = function(writer, data)
	SerializeBase.WriteList7Bit(writer, data, SerializeBase.WriteStructWrap(SerializeAuto.WriteInteractCmdData, "data"), nil, "data", false, RpcLengthLimits.IClientToGameScene_AskInteractCmds_data, nil)
end

ClientToGameSceneDelegate.AskInteractCmds = function(self, data)
	self.Notify(self, 67088502, SerializerHelper.AskInteractCmds_Serializer, data)
end

SerializerHelper.AskFinishNpcStun_Serializer = function(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskFinishNpcStun = function(self, agentid)
	self.Notify(self, 67089118, SerializerHelper.AskFinishNpcStun_Serializer, agentid)
end

SerializerHelper.AskFinishChefFoodPrepare_Serializer = function(writer, foodprepareid, issuccess)
	SerializeBase.WritePrimitive(writer, foodprepareid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, issuccess, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskFinishChefFoodPrepare = function(self, foodprepareid, issuccess)
	return self.Invoke(self, 67090441, SerializerHelper.AskFinishChefFoodPrepare_Serializer, foodprepareid, issuccess)
end

SerializerHelper.AskInterruptSkillExecuteStiff_Serializer = function(writer, targetuid)
	SerializeBase.WritePrimitive(writer, targetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskInterruptSkillExecuteStiff = function(self, targetuid)
	return self.Invoke(self, 67092235, SerializerHelper.AskInterruptSkillExecuteStiff_Serializer, targetuid)
end

SerializerHelper.AskVehicleDisMonitorTrigger_Serializer = function(writer, vehicleentityid, distance, isawayorapproach)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, distance, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, isawayorapproach, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskVehicleDisMonitorTrigger = function(self, vehicleentityid, distance, isawayorapproach)
	self.Notify(self, 67093585, SerializerHelper.AskVehicleDisMonitorTrigger_Serializer, vehicleentityid, distance, isawayorapproach)
end

SerializerHelper.ReportBeHacked_Serializer = function(writer, uids)
	SerializeBase.WriteList7Bit(writer, uids, writer.WriteUInt64, 0, "uids", false, RpcLengthLimits.IClientToGameScene_ReportBeHacked_uids, nil)
end

ClientToGameSceneDelegate.ReportBeHacked = function(self, uids)
	self.Notify(self, 67093669, SerializerHelper.ReportBeHacked_Serializer, uids)
end

SerializerHelper.SyncSpoonPlayerObstacleTurn_Serializer = function(writer, obstacleturnover)
	SerializeBase.WritePrimitive(writer, obstacleturnover, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.SyncSpoonPlayerObstacleTurn = function(self, obstacleturnover)
	return self.Invoke(self, 67094360, SerializerHelper.SyncSpoonPlayerObstacleTurn_Serializer, obstacleturnover)
end

SerializerHelper.AskFightGameLeave_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskFightGameLeave = function(self)
	return self.Invoke(self, 67095901, SerializerHelper.AskFightGameLeave_Serializer)
end

SerializerHelper.RecordDartEnd_Serializer = function(writer, scoreindex)
	SerializeBase.WritePrimitive(writer, scoreindex, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.RecordDartEnd = function(self, scoreindex)
	return self.Invoke(self, 67097646, SerializerHelper.RecordDartEnd_Serializer, scoreindex)
end

SerializerHelper.AskClearSwitchInFashionCache_Serializer = function(writer, spiritid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskClearSwitchInFashionCache = function(self, spiritid)
	return self.Invoke(self, 67098371, SerializerHelper.AskClearSwitchInFashionCache_Serializer, spiritid)
end

SerializerHelper.AskReleaseEnemySignal_Serializer = function(writer, enemyid, signal)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	writer.WriteString(writer, signal, false, "AskReleaseEnemySignal.signal", RpcLengthLimits.IClientToGameScene_AskReleaseEnemySignal_signal)
end

ClientToGameSceneDelegate.AskReleaseEnemySignal = function(self, enemyid, signal)
	self.Notify(self, 67100912, SerializerHelper.AskReleaseEnemySignal_Serializer, enemyid, signal)
end

SerializerHelper.SyncTriggerRaceTiming_Serializer = function(writer, timing)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(timing, 54, 1), writer.WriteByte, 1)
end

ClientToGameSceneDelegate.SyncTriggerRaceTiming = function(self, timing)
	return self.Invoke(self, 67104723, SerializerHelper.SyncTriggerRaceTiming_Serializer, timing)
end

SerializerHelper.UseGomokuSkill_Serializer = function(writer, gadgetuid, skillid, param)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, param, SerializeAuto.WriteGomokuSkillExtraParam, "param", false)
end

ClientToGameSceneDelegate.UseGomokuSkill = function(self, gadgetuid, skillid, param)
	return self.Invoke(self, 67105185, SerializerHelper.UseGomokuSkill_Serializer, gadgetuid, skillid, param)
end

SerializerHelper.AskSkillOpenShield_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillShieldData, "data", false)
end

ClientToGameSceneDelegate.AskSkillOpenShield = function(self, data)
	self.Notify(self, 67105658, SerializerHelper.AskSkillOpenShield_Serializer, data)
end

SerializerHelper.StartGadgetWeaponGame_Serializer = function(writer, gadgetuid, wheelid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, wheelid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.StartGadgetWeaponGame = function(self, gadgetuid, wheelid)
	return self.Invoke(self, 67106658, SerializerHelper.StartGadgetWeaponGame_Serializer, gadgetuid, wheelid)
end

SerializerHelper.LeaveBBQ_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.LeaveBBQ = function(self, gadgetuid)
	return self.Invoke(self, 67107805, SerializerHelper.LeaveBBQ_Serializer, gadgetuid)
end

SerializerHelper.EnterRingTossZone_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.EnterRingTossZone = function(self, gadgetuid)
	return self.Invoke(self, 67108425, SerializerHelper.EnterRingTossZone_Serializer, gadgetuid)
end

SerializerHelper.AskAttachSceneItemMulti_Serializer = function(writer, targetunitid, slotids, sceneiteminstanceid)
	SerializeBase.WritePrimitive(writer, targetunitid, writer.WriteUInt64, 0)
	SerializeBase.WriteList7Bit(writer, slotids, writer.WriteUInt32, 0, "slotids", false, RpcLengthLimits.IClientToGameScene_AskAttachSceneItemMulti_slotIds, nil)
	SerializeBase.WritePrimitive(writer, sceneiteminstanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskAttachSceneItemMulti = function(self, targetunitid, slotids, sceneiteminstanceid)
	return self.Invoke(self, 67112394, SerializerHelper.AskAttachSceneItemMulti_Serializer, targetunitid, slotids, sceneiteminstanceid)
end

SerializerHelper.AskHelicopterNpc_Serializer = function(writer, instanceid, optype)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(optype, 55, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskHelicopterNpc = function(self, instanceid, optype)
	return self.Invoke(self, 67113443, SerializerHelper.AskHelicopterNpc_Serializer, instanceid, optype)
end

SerializerHelper.AskDoInteractBindPerformance_Serializer = function(writer, gadgetid, bindid, interactactiontype, index, dynamicbinditem, starttime, delaytime)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, bindid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, interactactiontype, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, dynamicbinditem, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, starttime, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, delaytime, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskDoInteractBindPerformance = function(self, gadgetid, bindid, interactactiontype, index, dynamicbinditem, starttime, delaytime)
	self.Notify(self, 67116979, SerializerHelper.AskDoInteractBindPerformance_Serializer, gadgetid, bindid, interactactiontype, index, dynamicbinditem, starttime, delaytime)
end

SerializerHelper.AskSetDataToOwner_Serializer = function(writer, datas)
	SerializeBase.WriteList7Bit(writer, datas, SerializeBase.WriteStructWrap(SerializeAuto.WriteOwnerSyncData, "datas"), nil, "datas", false, RpcLengthLimits.IClientToGameScene_AskSetDataToOwner_datas, nil)
end

ClientToGameSceneDelegate.AskSetDataToOwner = function(self, datas)
	self.Notify(self, 67118243, SerializerHelper.AskSetDataToOwner_Serializer, datas)
end

SerializerHelper.AskAetherChangeQuality_Serializer = function(writer, charactercountquality, vehiclecountquality)
	SerializeBase.WritePrimitive(writer, charactercountquality, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, vehiclecountquality, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskAetherChangeQuality = function(self, charactercountquality, vehiclecountquality)
	self.Notify(self, 67118927, SerializerHelper.AskAetherChangeQuality_Serializer, charactercountquality, vehiclecountquality)
end

SerializerHelper.AskPlayerOutOfStuck_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskPlayerOutOfStuck = function(self)
	self.Notify(self, 67120336, SerializerHelper.AskPlayerOutOfStuck_Serializer)
end

SerializerHelper.AskSwitchSpiritByTaskEvent_Serializer = function(writer, spiritid, eventid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskSwitchSpiritByTaskEvent = function(self, spiritid, eventid)
	self.Notify(self, 67121462, SerializerHelper.AskSwitchSpiritByTaskEvent_Serializer, spiritid, eventid)
end

SerializerHelper.AskAetherAIBorrowVehicle_Serializer = function(writer, vehicleinstanceid)
	SerializeBase.WritePrimitive(writer, vehicleinstanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskAetherAIBorrowVehicle = function(self, vehicleinstanceid)
	return self.Invoke(self, 67122370, SerializerHelper.AskAetherAIBorrowVehicle_Serializer, vehicleinstanceid)
end

SerializerHelper.AskAgentUpdateBackTransform_Serializer = function(writer, npcinstanceid, autobackindex, pos, facing)
	SerializeBase.WritePrimitive(writer, npcinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, autobackindex, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskAgentUpdateBackTransform = function(self, npcinstanceid, autobackindex, pos, facing)
	self.Notify(self, 67123736, SerializerHelper.AskAgentUpdateBackTransform_Serializer, npcinstanceid, autobackindex, pos, facing)
end

SerializerHelper.SetBasketballPlayerBallId_Serializer = function(writer, ballid)
	SerializeBase.WritePrimitive(writer, ballid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.SetBasketballPlayerBallId = function(self, ballid)
	return self.Invoke(self, 67125711, SerializerHelper.SetBasketballPlayerBallId_Serializer, ballid)
end

SerializerHelper.AskEnterFeiSuoCrouch_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskEnterFeiSuoCrouch = function(self)
	self.Notify(self, 67125746, SerializerHelper.AskEnterFeiSuoCrouch_Serializer)
end

SerializerHelper.AskStartChefQTE_Serializer = function(writer, stoveid)
	SerializeBase.WritePrimitive(writer, stoveid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskStartChefQTE = function(self, stoveid)
	return self.Invoke(self, 67126249, SerializerHelper.AskStartChefQTE_Serializer, stoveid)
end

SerializerHelper.AskMoveCreations_Serializer = function(writer, list)
	SerializeBase.WriteList7Bit(writer, list, SerializeBase.WriteStructWrap(SerializeAuto.WriteCreationMoveData, "list"), nil, "list", false, RpcLengthLimits.IClientToGameScene_AskMoveCreations_list, nil)
end

ClientToGameSceneDelegate.AskMoveCreations = function(self, list)
	self.Notify(self, 67127555, SerializerHelper.AskMoveCreations_Serializer, list)
end

SerializerHelper.SyncStoryCoreClientInfo_Serializer = function(writer, commands)
	SerializeBase.WriteList7Bit(writer, commands, SerializeBase.WriteComplexWrap(SerializeAuto.WriteStoryClientCommand, "StoryClientCommand", false), nil, "commands", false, RpcLengthLimits.IClientToGameScene_SyncStoryCoreClientInfo_commands, nil)
end

ClientToGameSceneDelegate.SyncStoryCoreClientInfo = function(self, commands)
	self.Notify(self, 67130745, SerializerHelper.SyncStoryCoreClientInfo_Serializer, commands)
end

SerializerHelper.AskDoPetAction_Serializer = function(writer, pid, spoonid, index, isstart)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, spoonid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, isstart, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskDoPetAction = function(self, pid, spoonid, index, isstart)
	return self.Invoke(self, 67130838, SerializerHelper.AskDoPetAction_Serializer, pid, spoonid, index, isstart)
end

SerializerHelper.AskCreateAndAttachDynamicBind_Serializer = function(writer, cfgid, targetunitid, slotid)
	SerializeBase.WritePrimitive(writer, cfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, targetunitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, slotid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskCreateAndAttachDynamicBind = function(self, cfgid, targetunitid, slotid)
	return self.Invoke(self, 67131963, SerializerHelper.AskCreateAndAttachDynamicBind_Serializer, cfgid, targetunitid, slotid)
end

SerializerHelper.AskVehicleCrashEnemy_Serializer = function(writer, enemyid, vehicleid, impulsedata)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, impulsedata, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskVehicleCrashEnemy = function(self, enemyid, vehicleid, impulsedata)
	return self.Invoke(self, 67135955, SerializerHelper.AskVehicleCrashEnemy_Serializer, enemyid, vehicleid, impulsedata)
end

SerializerHelper.AskStartChefManagementRound_Serializer = function(writer, chefnpcid)
	SerializeBase.WriteList7Bit(writer, chefnpcid, writer.WriteUInt32, 0, "chefnpcid", false, RpcLengthLimits.IClientToGameScene_AskStartChefManagementRound_chefNpcId, nil)
end

ClientToGameSceneDelegate.AskStartChefManagementRound = function(self, chefnpcid)
	return self.Invoke(self, 67136224, SerializerHelper.AskStartChefManagementRound_Serializer, chefnpcid)
end

SerializerHelper.AskFeiSuoSuccess_Serializer = function(writer, feisuoid)
	SerializeBase.WritePrimitive(writer, feisuoid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskFeiSuoSuccess = function(self, feisuoid)
	return self.Invoke(self, 67138761, SerializerHelper.AskFeiSuoSuccess_Serializer, feisuoid)
end

SerializerHelper.AskFightGameSyncPlayerState_Serializer = function(writer, state, isai)
	SerializeBase.WriteComplex(writer, state, SerializeAuto.WriteFightGameStateInfo, "state", false)
	SerializeBase.WritePrimitive(writer, isai, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskFightGameSyncPlayerState = function(self, state, isai)
	self.Notify(self, 67141007, SerializerHelper.AskFightGameSyncPlayerState_Serializer, state, isai)
end

SerializerHelper.AskVehicleCargoOperation_Serializer = function(writer, vehicleuid, sceneitemuid, isload)
	SerializeBase.WritePrimitive(writer, vehicleuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, sceneitemuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, isload, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskVehicleCargoOperation = function(self, vehicleuid, sceneitemuid, isload)
	return self.Invoke(self, 67141570, SerializerHelper.AskVehicleCargoOperation_Serializer, vehicleuid, sceneitemuid, isload)
end

SerializerHelper.ReportEnemyStandInfo_Serializer = function(writer, infos)
	SerializeBase.WriteList7Bit(writer, infos, SerializeBase.WriteStructWrap(SerializeAuto.WriteEnemyStandInfo, "infos"), nil, "infos", false, RpcLengthLimits.IClientToGameScene_ReportEnemyStandInfo_infos, nil)
end

ClientToGameSceneDelegate.ReportEnemyStandInfo = function(self, infos)
	self.Notify(self, 67143081, SerializerHelper.ReportEnemyStandInfo_Serializer, infos)
end

SerializerHelper.AskSceneDeviceSendSignal_Serializer = function(writer, type, id, signalname)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	writer.WriteString(writer, signalname, false, "AskSceneDeviceSendSignal.signalName", RpcLengthLimits.IClientToGameScene_AskSceneDeviceSendSignal_signalName)
end

ClientToGameSceneDelegate.AskSceneDeviceSendSignal = function(self, type, id, signalname)
	return self.Invoke(self, 67144566, SerializerHelper.AskSceneDeviceSendSignal_Serializer, type, id, signalname)
end

SerializerHelper.AskHackerBetray_Serializer = function(writer, targetid)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskHackerBetray = function(self, targetid)
	self.Notify(self, 67145924, SerializerHelper.AskHackerBetray_Serializer, targetid)
end

SerializerHelper.AskRemoveExtractionShooterWeaponDecoration_Serializer = function(writer, gunbagconfigid, guncellx, guncelly, decorationslotindex, returnbagconfigid)
	SerializeBase.WritePrimitive(writer, gunbagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, guncellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, guncelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, decorationslotindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, returnbagconfigid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskRemoveExtractionShooterWeaponDecoration = function(self, gunbagconfigid, guncellx, guncelly, decorationslotindex, returnbagconfigid)
	return self.Invoke(self, 67146877, SerializerHelper.AskRemoveExtractionShooterWeaponDecoration_Serializer, gunbagconfigid, guncellx, guncelly, decorationslotindex, returnbagconfigid)
end

SerializerHelper.MahjongPlayerReady_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.MahjongPlayerReady = function(self, gadgetuid)
	return self.Invoke(self, 67147098, SerializerHelper.MahjongPlayerReady_Serializer, gadgetuid)
end

SerializerHelper.AskPlayerOnBVBFinish_Serializer = function(writer, isreply)
	SerializeBase.WritePrimitive(writer, isreply, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskPlayerOnBVBFinish = function(self, isreply)
	return self.Invoke(self, 67147759, SerializerHelper.AskPlayerOnBVBFinish_Serializer, isreply)
end

SerializerHelper.AskVehicleHornPress_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskVehicleHornPress = function(self)
	self.Notify(self, 67150147, SerializerHelper.AskVehicleHornPress_Serializer)
end

SerializerHelper.AskToiletOstrichFlee_Serializer = function(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskToiletOstrichFlee = function(self, agentid)
	self.Notify(self, 67154315, SerializerHelper.AskToiletOstrichFlee_Serializer, agentid)
end

SerializerHelper.AskDiscardWeapon_Serializer = function(writer, index)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskDiscardWeapon = function(self, index)
	self.Notify(self, 67155190, SerializerHelper.AskDiscardWeapon_Serializer, index)
end

SerializerHelper.AskCinemaEndMovie_Serializer = function(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskCinemaEndMovie = function(self, locationid)
	return self.Invoke(self, 67155526, SerializerHelper.AskCinemaEndMovie_Serializer, locationid)
end

SerializerHelper.AskSetGamePause_Serializer = function(writer, value, reason)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(reason, 56, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskSetGamePause = function(self, value, reason)
	return self.Invoke(self, 67155875, SerializerHelper.AskSetGamePause_Serializer, value, reason)
end

SerializerHelper.AskDoPosAction_Serializer = function(writer, nodeid)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskDoPosAction = function(self, nodeid)
	return self.Invoke(self, 67156079, SerializerHelper.AskDoPosAction_Serializer, nodeid)
end

SerializerHelper.ReportBattleMoveOneActionLoopEnd_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportBattleMoveOneActionLoopEnd = function(self, pid)
	self.Notify(self, 67156838, SerializerHelper.ReportBattleMoveOneActionLoopEnd_Serializer, pid)
end

SerializerHelper.AskReleaseAIEvent_Serializer = function(writer, eventname)
	writer.WriteString(writer, eventname, false, "AskReleaseAIEvent.eventName", RpcLengthLimits.IClientToGameScene_AskReleaseAIEvent_eventName)
end

ClientToGameSceneDelegate.AskReleaseAIEvent = function(self, eventname)
	self.Notify(self, 67157780, SerializerHelper.AskReleaseAIEvent_Serializer, eventname)
end

SerializerHelper.AskUnitMoveActionSimple_Serializer = function(writer, actions)
	SerializeBase.WriteList7Bit(writer, actions, SerializeBase.WriteStructWrap(SerializeAuto.WriteSimpleMoveActionData, "actions"), nil, "actions", false, RpcLengthLimits.IClientToGameScene_AskUnitMoveActionSimple_actions, nil)
end

ClientToGameSceneDelegate.AskUnitMoveActionSimple = function(self, actions)
	self.Notify(self, 67158757, SerializerHelper.AskUnitMoveActionSimple_Serializer, actions)
end

SerializerHelper.AskFinishHackingKeyFrame_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskFinishHackingKeyFrame = function(self, id)
	return self.Invoke(self, 67159381, SerializerHelper.AskFinishHackingKeyFrame_Serializer, id)
end

SerializerHelper.AskVehicleGraphChangeState_Serializer = function(writer, statechangeinfo)
	SerializeBase.WriteStruct(writer, statechangeinfo, SerializeAuto.WriteSceneDeviceStateChangeInfo, "statechangeinfo")
end

ClientToGameSceneDelegate.AskVehicleGraphChangeState = function(self, statechangeinfo)
	return self.Invoke(self, 67160647, SerializerHelper.AskVehicleGraphChangeState_Serializer, statechangeinfo)
end

SerializerHelper.ReportCanAssassinateEnemies_Serializer = function(writer, enemyids)
	SerializeBase.WriteList7Bit(writer, enemyids, writer.WriteUInt64, 0, "enemyids", false, RpcLengthLimits.IClientToGameScene_ReportCanAssassinateEnemies_enemyIds, nil)
end

ClientToGameSceneDelegate.ReportCanAssassinateEnemies = function(self, enemyids)
	self.Notify(self, 67161256, SerializerHelper.ReportCanAssassinateEnemies_Serializer, enemyids)
end

SerializerHelper.SendExtractionMark_Serializer = function(writer, mark)
	SerializeBase.WriteComplex(writer, mark, SerializeAuto.WriteExtractionMark, "mark", false)
end

ClientToGameSceneDelegate.SendExtractionMark = function(self, mark)
	return self.Invoke(self, 67161561, SerializerHelper.SendExtractionMark_Serializer, mark)
end

SerializerHelper.AskPlateAgentCreateConfirmed_Serializer = function(writer, plateuid, plateinlineid, agentinstanceid)
	SerializeBase.WritePrimitive(writer, plateuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, plateinlineid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, agentinstanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskPlateAgentCreateConfirmed = function(self, plateuid, plateinlineid, agentinstanceid)
	return self.Invoke(self, 67163577, SerializerHelper.AskPlateAgentCreateConfirmed_Serializer, plateuid, plateinlineid, agentinstanceid)
end

SerializerHelper.AskMultiCinemaPlayMovie_Serializer = function(writer, locationid, movieid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, movieid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskMultiCinemaPlayMovie = function(self, locationid, movieid)
	return self.Invoke(self, 67164341, SerializerHelper.AskMultiCinemaPlayMovie_Serializer, locationid, movieid)
end

SerializerHelper.ReportCheckerEQSRes_Serializer = function(writer, infos)
	SerializeBase.WriteList7Bit(writer, infos, SerializeBase.WriteStructWrap(SerializeAuto.WriteCheckerEQSResInfo, "infos"), nil, "infos", false, RpcLengthLimits.IClientToGameScene_ReportCheckerEQSRes_infos, nil)
end

ClientToGameSceneDelegate.ReportCheckerEQSRes = function(self, infos)
	self.Notify(self, 67167605, SerializerHelper.ReportCheckerEQSRes_Serializer, infos)
end

SerializerHelper.ReportPlayActionFinish_Serializer = function(writer, enemyid, actionid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, actionid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.ReportPlayActionFinish = function(self, enemyid, actionid)
	self.Notify(self, 67172352, SerializerHelper.ReportPlayActionFinish_Serializer, enemyid, actionid)
end

SerializerHelper.AskAgentStartBack_Serializer = function(writer, npcinstanceid)
	SerializeBase.WritePrimitive(writer, npcinstanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskAgentStartBack = function(self, npcinstanceid)
	return self.Invoke(self, 67174325, SerializerHelper.AskAgentStartBack_Serializer, npcinstanceid)
end

SerializerHelper.AskSpawnSubAgent_Serializer = function(writer, unitid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskSpawnSubAgent = function(self, unitid)
	self.Notify(self, 67174462, SerializerHelper.AskSpawnSubAgent_Serializer, unitid)
end

SerializerHelper.AskInterruptSkillExecute_Serializer = function(writer, targetuid)
	SerializeBase.WritePrimitive(writer, targetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskInterruptSkillExecute = function(self, targetuid)
	return self.Invoke(self, 67176777, SerializerHelper.AskInterruptSkillExecute_Serializer, targetuid)
end

SerializerHelper.AskChineseChessPlayAgainEndGame_Serializer = function(writer, gadgetuid, endgameid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, endgameid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskChineseChessPlayAgainEndGame = function(self, gadgetuid, endgameid)
	return self.Invoke(self, 67179081, SerializerHelper.AskChineseChessPlayAgainEndGame_Serializer, gadgetuid, endgameid)
end

SerializerHelper.AskAddBasketBallExclusiveTag_Serializer = function(writer, agentid, tag)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, tag, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskAddBasketBallExclusiveTag = function(self, agentid, tag)
	self.Notify(self, 67181041, SerializerHelper.AskAddBasketBallExclusiveTag_Serializer, agentid, tag)
end

SerializerHelper.AskCinemaTriggerGazeNpc_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskCinemaTriggerGazeNpc = function(self)
	return self.Invoke(self, 67181754, SerializerHelper.AskCinemaTriggerGazeNpc_Serializer)
end

SerializerHelper.AskStopRescueFallingDownPlayer_Serializer = function(writer, uid)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskStopRescueFallingDownPlayer = function(self, uid)
	return self.Invoke(self, 67182576, SerializerHelper.AskStopRescueFallingDownPlayer_Serializer, uid)
end

SerializerHelper.ReportExitTaskStop_Serializer = function(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportExitTaskStop = function(self, agententityid)
	self.Notify(self, 67183517, SerializerHelper.ReportExitTaskStop_Serializer, agententityid)
end

SerializerHelper.AskServeChefDishes_Serializer = function(writer, stoveid, pos, facing)
	SerializeBase.WritePrimitive(writer, stoveid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
	SerializeBase.WriteStruct(writer, facing, SerializeAuto.WriteUXVector3, "facing")
end

ClientToGameSceneDelegate.AskServeChefDishes = function(self, stoveid, pos, facing)
	return self.Invoke(self, 67183960, SerializerHelper.AskServeChefDishes_Serializer, stoveid, pos, facing)
end

SerializerHelper.AskFinishBelongingUsage_Serializer = function(writer, instanceid, usageid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, usageid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskFinishBelongingUsage = function(self, instanceid, usageid)
	self.Notify(self, 67184154, SerializerHelper.AskFinishBelongingUsage_Serializer, instanceid, usageid)
end

SerializerHelper.AskAddDestructibleHp_Serializer = function(writer, id, hp)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, hp, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskAddDestructibleHp = function(self, id, hp)
	self.Notify(self, 67184647, SerializerHelper.AskAddDestructibleHp_Serializer, id, hp)
end

SerializerHelper.AskReportDoublePose_Serializer = function(writer, actionid, type, npcinstanceid)
	SerializeBase.WritePrimitive(writer, actionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(type, 57, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, npcinstanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskReportDoublePose = function(self, actionid, type, npcinstanceid)
	self.Notify(self, 67185519, SerializerHelper.AskReportDoublePose_Serializer, actionid, type, npcinstanceid)
end

SerializerHelper.AskReportBoatValidPosition_Serializer = function(writer, position, facing)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskReportBoatValidPosition = function(self, position, facing)
	self.Notify(self, 67188752, SerializerHelper.AskReportBoatValidPosition_Serializer, position, facing)
end

SerializerHelper.AskRemovePaokuRoomLimit_Serializer = function(writer, roomid)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskRemovePaokuRoomLimit = function(self, roomid)
	return self.Invoke(self, 67189932, SerializerHelper.AskRemovePaokuRoomLimit_Serializer, roomid)
end

SerializerHelper.AskReportLogicAgentCommandFail_Serializer = function(writer, agentid, commandid, reason)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, commandid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, reason, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskReportLogicAgentCommandFail = function(self, agentid, commandid, reason)
	self.Notify(self, 67193144, SerializerHelper.AskReportLogicAgentCommandFail_Serializer, agentid, commandid, reason)
end

SerializerHelper.AskClearChefFoodPrepare_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskClearChefFoodPrepare = function(self)
	return self.Invoke(self, 67195449, SerializerHelper.AskClearChefFoodPrepare_Serializer)
end

SerializerHelper.QueryBasketballInfo_Serializer = function(writer)
end

ClientToGameSceneDelegate.QueryBasketballInfo = function(self)
	return self.Invoke(self, 67196402, SerializerHelper.QueryBasketballInfo_Serializer)
end

SerializerHelper.AskSetClientLockTarget_Serializer = function(writer, targetid)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskSetClientLockTarget = function(self, targetid)
	self.Notify(self, 67197587, SerializerHelper.AskSetClientLockTarget_Serializer, targetid)
end

SerializerHelper.AskCreateTimelineDangerArea_Serializer = function(writer, center, extends, rotation, dangerareatype)
	SerializeBase.WriteStruct(writer, center, SerializeAuto.WriteUXVector3, "center")
	SerializeBase.WriteStruct(writer, extends, SerializeAuto.WriteUXVector3, "extends")
	SerializeBase.WriteStruct(writer, rotation, SerializeAuto.WriteUXVector3, "rotation")
	SerializeBase.WritePrimitive(writer, dangerareatype, writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskCreateTimelineDangerArea = function(self, center, extends, rotation, dangerareatype)
	self.Notify(self, 67198414, SerializerHelper.AskCreateTimelineDangerArea_Serializer, center, extends, rotation, dangerareatype)
end

SerializerHelper.AskCreationsTriggerDisappear_Serializer = function(writer, creations)
	SerializeBase.WriteList7Bit(writer, creations, writer.WriteUInt64, 0, "creations", false, RpcLengthLimits.IClientToGameScene_AskCreationsTriggerDisappear_creations, nil)
end

ClientToGameSceneDelegate.AskCreationsTriggerDisappear = function(self, creations)
	return self.Invoke(self, 67198722, SerializerHelper.AskCreationsTriggerDisappear_Serializer, creations)
end

SerializerHelper.AskTriggerVehicleSpawnArea_Serializer = function(writer, vehicleconfigid)
	SerializeBase.WritePrimitive(writer, vehicleconfigid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskTriggerVehicleSpawnArea = function(self, vehicleconfigid)
	self.Notify(self, 67200236, SerializerHelper.AskTriggerVehicleSpawnArea_Serializer, vehicleconfigid)
end

SerializerHelper.AskEnterMoveGround_Serializer = function(writer, pid, movegroundid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, movegroundid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskEnterMoveGround = function(self, pid, movegroundid)
	return self.Invoke(self, 67200298, SerializerHelper.AskEnterMoveGround_Serializer, pid, movegroundid)
end

SerializerHelper.AskVehicleComponentStateUpdate_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteVehicleComponentStateUpdateInfo, "data", false)
end

ClientToGameSceneDelegate.AskVehicleComponentStateUpdate = function(self, data)
	self.Notify(self, 67202519, SerializerHelper.AskVehicleComponentStateUpdate_Serializer, data)
end

SerializerHelper.ReportShelterPos_Serializer = function(writer, infos)
	SerializeBase.WriteList7Bit(writer, infos, SerializeBase.WriteStructWrap(SerializeAuto.WriteShelterPosInfo, "infos"), nil, "infos", false, RpcLengthLimits.IClientToGameScene_ReportShelterPos_infos, nil)
end

ClientToGameSceneDelegate.ReportShelterPos = function(self, infos)
	self.Notify(self, 67203361, SerializerHelper.ReportShelterPos_Serializer, infos)
end

SerializerHelper.ReportTurnToPositionFinish_Serializer = function(writer, enemyid, actionid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, actionid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.ReportTurnToPositionFinish = function(self, enemyid, actionid)
	self.Notify(self, 67205287, SerializerHelper.ReportTurnToPositionFinish_Serializer, enemyid, actionid)
end

SerializerHelper.AskFallOffCliff_Serializer = function(writer, position, moveid)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, moveid, writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskFallOffCliff = function(self, position, moveid)
	self.Notify(self, 67206202, SerializerHelper.AskFallOffCliff_Serializer, position, moveid)
end

SerializerHelper.ReportVisibleUnitList_Serializer = function(writer, datas)
	SerializeBase.WriteList7Bit(writer, datas, SerializeBase.WriteStructWrap(SerializeAuto.WriteVisibilityReportData, "datas"), nil, "datas", false, RpcLengthLimits.IClientToGameScene_ReportVisibleUnitList_datas, nil)
end

ClientToGameSceneDelegate.ReportVisibleUnitList = function(self, datas)
	self.Notify(self, 67206634, SerializerHelper.ReportVisibleUnitList_Serializer, datas)
end

SerializerHelper.AskLoadGameResCompleted_Serializer = function(writer, sceneid)
	SerializeBase.WritePrimitive(writer, sceneid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskLoadGameResCompleted = function(self, sceneid)
	self.Notify(self, 67211227, SerializerHelper.AskLoadGameResCompleted_Serializer, sceneid)
end

SerializerHelper.AskPlayerFinishEnterOrExitVehicle_Serializer = function(writer, syncdata)
	SerializeBase.WriteComplex(writer, syncdata, SerializeAuto.WritePlayerVehicleDriveStateInfo, "syncdata", false)
end

ClientToGameSceneDelegate.AskPlayerFinishEnterOrExitVehicle = function(self, syncdata)
	self.Notify(self, 67211905, SerializerHelper.AskPlayerFinishEnterOrExitVehicle_Serializer, syncdata)
end

SerializerHelper.AskChineseChessReplyTie_Serializer = function(writer, gadgetuid, agree)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agree, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskChineseChessReplyTie = function(self, gadgetuid, agree)
	return self.Invoke(self, 67212265, SerializerHelper.AskChineseChessReplyTie_Serializer, gadgetuid, agree)
end

SerializerHelper.AskFightGameEnterRoleStage_Serializer = function(writer, initroleid, isai, aiinitroleid)
	SerializeBase.WritePrimitive(writer, initroleid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isai, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, aiinitroleid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskFightGameEnterRoleStage = function(self, initroleid, isai, aiinitroleid)
	return self.Invoke(self, 67213349, SerializerHelper.AskFightGameEnterRoleStage_Serializer, initroleid, isai, aiinitroleid)
end

SerializerHelper.AskMultipleSkillHit2_Serializer = function(writer, skillhitdata)
	SerializeBase.WriteComplex(writer, skillhitdata, SerializeAuto.WriteSkillHitData, "skillhitdata", false)
end

ClientToGameSceneDelegate.AskMultipleSkillHit2 = function(self, skillhitdata)
	self.Notify(self, 67218758, SerializerHelper.AskMultipleSkillHit2_Serializer, skillhitdata)
end

SerializerHelper.AskPlayerStartEnterOrExitVehicle_Serializer = function(writer, syncdata)
	SerializeBase.WriteComplex(writer, syncdata, SerializeAuto.WritePlayerVehicleDriveStateInfo, "syncdata", false)
end

ClientToGameSceneDelegate.AskPlayerStartEnterOrExitVehicle = function(self, syncdata)
	self.Notify(self, 67225310, SerializerHelper.AskPlayerStartEnterOrExitVehicle_Serializer, syncdata)
end

SerializerHelper.QueryGomokuPlayerInfo_Serializer = function(writer)
end

ClientToGameSceneDelegate.QueryGomokuPlayerInfo = function(self)
	return self.Invoke(self, 67225667, SerializerHelper.QueryGomokuPlayerInfo_Serializer)
end

SerializerHelper.AskSceneDeviceChangeState_Serializer = function(writer, type, statechangeinfo)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WriteStruct(writer, statechangeinfo, SerializeAuto.WriteSceneDeviceStateChangeInfo, "statechangeinfo")
end

ClientToGameSceneDelegate.AskSceneDeviceChangeState = function(self, type, statechangeinfo)
	return self.Invoke(self, 67226162, SerializerHelper.AskSceneDeviceChangeState_Serializer, type, statechangeinfo)
end

SerializerHelper.AskAetherNpcUpdatePathForObstacle_Serializer = function(writer, entityid, obstacleposition, obstacleradius)
	SerializeBase.WritePrimitive(writer, entityid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, obstacleposition, SerializeAuto.WriteUXVector3, "obstacleposition")
	SerializeBase.WritePrimitive(writer, obstacleradius, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskAetherNpcUpdatePathForObstacle = function(self, entityid, obstacleposition, obstacleradius)
	self.Notify(self, 67228857, SerializerHelper.AskAetherNpcUpdatePathForObstacle_Serializer, entityid, obstacleposition, obstacleradius)
end

SerializerHelper.AskSkillSpawnItem_Serializer = function(writer, casterunitid, sceneitemtemplateid)
	SerializeBase.WritePrimitive(writer, casterunitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, sceneitemtemplateid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskSkillSpawnItem = function(self, casterunitid, sceneitemtemplateid)
	self.Notify(self, 67229215, SerializerHelper.AskSkillSpawnItem_Serializer, casterunitid, sceneitemtemplateid)
end

SerializerHelper.ReportUnitEnterPuppet_Serializer = function(writer, unitid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportUnitEnterPuppet = function(self, unitid)
	return self.Invoke(self, 67231666, SerializerHelper.ReportUnitEnterPuppet_Serializer, unitid)
end

SerializerHelper.ReportMoveSwing_Serializer = function(writer, time, distance)
	SerializeBase.WritePrimitive(writer, time, writer.WriteDouble, 0)
	SerializeBase.WritePrimitive(writer, distance, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.ReportMoveSwing = function(self, time, distance)
	self.Notify(self, 67234122, SerializerHelper.ReportMoveSwing_Serializer, time, distance)
end

SerializerHelper.AskChineseChessWithdrawMovePiece_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskChineseChessWithdrawMovePiece = function(self, gadgetuid)
	return self.Invoke(self, 67241177, SerializerHelper.AskChineseChessWithdrawMovePiece_Serializer, gadgetuid)
end

SerializerHelper.SetGameGroundPlayerPlayAgain_Serializer = function(writer, value)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.SetGameGroundPlayerPlayAgain = function(self, value)
	return self.Invoke(self, 67242155, SerializerHelper.SetGameGroundPlayerPlayAgain_Serializer, value)
end

SerializerHelper.ReleaseOccupySceneDevice_Serializer = function(writer, type, id, index, executor)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, executor, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReleaseOccupySceneDevice = function(self, type, id, index, executor)
	return self.Invoke(self, 67244136, SerializerHelper.ReleaseOccupySceneDevice_Serializer, type, id, index, executor)
end

SerializerHelper.LeaveBowling_Serializer = function(writer, gadgetuid, abort)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, abort, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.LeaveBowling = function(self, gadgetuid, abort)
	return self.Invoke(self, 67245027, SerializerHelper.LeaveBowling_Serializer, gadgetuid, abort)
end

SerializerHelper.ReportMovingDirectionRes_Serializer = function(writer, infos)
	SerializeBase.WriteList7Bit(writer, infos, SerializeBase.WriteStructWrap(SerializeAuto.WriteMovingDirResInfo, "infos"), nil, "infos", false, RpcLengthLimits.IClientToGameScene_ReportMovingDirectionRes_infos, nil)
end

ClientToGameSceneDelegate.ReportMovingDirectionRes = function(self, infos)
	self.Notify(self, 67246011, SerializerHelper.ReportMovingDirectionRes_Serializer, infos)
end

SerializerHelper.AskRaidVehicleConvertToAether_Serializer = function(writer, vehicleinstanceid)
	SerializeBase.WritePrimitive(writer, vehicleinstanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskRaidVehicleConvertToAether = function(self, vehicleinstanceid)
	return self.Invoke(self, 67251059, SerializerHelper.AskRaidVehicleConvertToAether_Serializer, vehicleinstanceid)
end

SerializerHelper.AskVehicleNavigationPathLengthList_Serializer = function(writer, targetpositionlist, ignoredirection, ignorealley, usenavmeshconnect, navigationprofile)
	SerializeBase.WriteList7Bit(writer, targetpositionlist, SerializeBase.WriteStructWrap(SerializeAuto.WriteUXVector3, "targetpositionlist"), nil, "targetpositionlist", false, RpcLengthLimits.IClientToGameScene_AskVehicleNavigationPathLengthList_targetPositionList, nil)
	SerializeBase.WritePrimitive(writer, ignoredirection, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, ignorealley, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, usenavmeshconnect, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(navigationprofile, 58, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskVehicleNavigationPathLengthList = function(self, targetpositionlist, ignoredirection, ignorealley, usenavmeshconnect, navigationprofile)
	return self.Invoke(self, 67251681, SerializerHelper.AskVehicleNavigationPathLengthList_Serializer, targetpositionlist, ignoredirection, ignorealley, usenavmeshconnect, navigationprofile)
end

SerializerHelper.ReportJumpStakeGameEnd_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportJumpStakeGameEnd = function(self, gadgetuid)
	return self.Invoke(self, 67251682, SerializerHelper.ReportJumpStakeGameEnd_Serializer, gadgetuid)
end

SerializerHelper.AskPlayerLeaveWater_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskPlayerLeaveWater = function(self)
	return self.Invoke(self, 67252339, SerializerHelper.AskPlayerLeaveWater_Serializer)
end

SerializerHelper.AskTriggerXSBStaticVehicle_Serializer = function(writer, enable)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskTriggerXSBStaticVehicle = function(self, enable)
	self.Notify(self, 67252898, SerializerHelper.AskTriggerXSBStaticVehicle_Serializer, enable)
end

SerializerHelper.ApproachAgent_Serializer = function(writer, instanceid, spoonagentid, distance)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, spoonagentid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, distance, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.ApproachAgent = function(self, instanceid, spoonagentid, distance)
	return self.Invoke(self, 67254409, SerializerHelper.ApproachAgent_Serializer, instanceid, spoonagentid, distance)
end

SerializerHelper.ReportClientCanMindInteract_Serializer = function(writer, canmindinteract)
	SerializeBase.WritePrimitive(writer, canmindinteract, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.ReportClientCanMindInteract = function(self, canmindinteract)
	self.Notify(self, 67256231, SerializerHelper.ReportClientCanMindInteract_Serializer, canmindinteract)
end

SerializerHelper.TriggerChefZone_Serializer = function(writer, gadgetuid, enter)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, enter, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.TriggerChefZone = function(self, gadgetuid, enter)
	return self.Invoke(self, 67256696, SerializerHelper.TriggerChefZone_Serializer, gadgetuid, enter)
end

SerializerHelper.AskDoNpcAction_Serializer = function(writer, templateid, instanceid, spoonid, taskid, eventid, index)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, spoonid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskDoNpcAction = function(self, templateid, instanceid, spoonid, taskid, eventid, index)
	return self.Invoke(self, 67257034, SerializerHelper.AskDoNpcAction_Serializer, templateid, instanceid, spoonid, taskid, eventid, index)
end

SerializerHelper.AskExtractionShooterShiftContainerItemToBag_Serializer = function(writer, containerinstanceid, fromcellx, fromcelly, bagconfigid, tocellx, tocelly, isrotated)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, fromcellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromcelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tocellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tocelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isrotated, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskExtractionShooterShiftContainerItemToBag = function(self, containerinstanceid, fromcellx, fromcelly, bagconfigid, tocellx, tocelly, isrotated)
	return self.Invoke(self, 67257572, SerializerHelper.AskExtractionShooterShiftContainerItemToBag_Serializer, containerinstanceid, fromcellx, fromcelly, bagconfigid, tocellx, tocelly, isrotated)
end

SerializerHelper.AskUnitMoveActionSimpleWithGround_Serializer = function(writer, actions)
	SerializeBase.WriteList7Bit(writer, actions, SerializeBase.WriteStructWrap(SerializeAuto.WriteSimpleMoveActionDataWithGround, "actions"), nil, "actions", false, RpcLengthLimits.IClientToGameScene_AskUnitMoveActionSimpleWithGround_actions, nil)
end

ClientToGameSceneDelegate.AskUnitMoveActionSimpleWithGround = function(self, actions)
	self.Notify(self, 67258085, SerializerHelper.AskUnitMoveActionSimpleWithGround_Serializer, actions)
end

SerializerHelper.AskExitBVBGame_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskExitBVBGame = function(self)
	return self.Invoke(self, 67259295, SerializerHelper.AskExitBVBGame_Serializer)
end

SerializerHelper.ReportSelectTempBuff_Serializer = function(writer, index)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.ReportSelectTempBuff = function(self, index)
	self.Notify(self, 67261848, SerializerHelper.ReportSelectTempBuff_Serializer, index)
end

SerializerHelper.AskPickUpWeapon_Serializer = function(writer, destructibleid, notdirectlyequip)
	SerializeBase.WritePrimitive(writer, destructibleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, notdirectlyequip, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskPickUpWeapon = function(self, destructibleid, notdirectlyequip)
	return self.Invoke(self, 67264037, SerializerHelper.AskPickUpWeapon_Serializer, destructibleid, notdirectlyequip)
end

SerializerHelper.AskAddOrRemoveChefAgent_Serializer = function(writer, cooknpcid, isadd)
	SerializeBase.WritePrimitive(writer, cooknpcid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isadd, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskAddOrRemoveChefAgent = function(self, cooknpcid, isadd)
	return self.Invoke(self, 67266859, SerializerHelper.AskAddOrRemoveChefAgent_Serializer, cooknpcid, isadd)
end

SerializerHelper.AskVehiclePlayAnimation_Serializer = function(writer, animation, specialanimation)
	SerializeBase.WriteComplex(writer, animation, SerializeAuto.WriteVehiclePartAnimation, "animation", false)
	SerializeBase.WriteComplex(writer, specialanimation, SerializeAuto.WriteVehicleSpecialPartAnimation, "specialanimation", false)
end

ClientToGameSceneDelegate.AskVehiclePlayAnimation = function(self, animation, specialanimation)
	self.Notify(self, 67267517, SerializerHelper.AskVehiclePlayAnimation_Serializer, animation, specialanimation)
end

SerializerHelper.ReportLookAtPositionFinish_Serializer = function(writer, enemyid, actionid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, actionid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.ReportLookAtPositionFinish = function(self, enemyid, actionid)
	self.Notify(self, 67268650, SerializerHelper.ReportLookAtPositionFinish_Serializer, enemyid, actionid)
end

SerializerHelper.AskStopVehicleAhead_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskStopVehicleAhead = function(self)
	self.Notify(self, 67270156, SerializerHelper.AskStopVehicleAhead_Serializer)
end

SerializerHelper.AskEnemyUseClientSkill_Serializer = function(writer, enemyid, skillid, destructibleid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, destructibleid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskEnemyUseClientSkill = function(self, enemyid, skillid, destructibleid)
	self.Notify(self, 67270596, SerializerHelper.AskEnemyUseClientSkill_Serializer, enemyid, skillid, destructibleid)
end

SerializerHelper.AskSkillDestructibleCreate_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillDestructibleData, "data", false)
end

ClientToGameSceneDelegate.AskSkillDestructibleCreate = function(self, data)
	return self.Invoke(self, 67271458, SerializerHelper.AskSkillDestructibleCreate_Serializer, data)
end

SerializerHelper.ReportTLFinish_Serializer = function(writer, tlid)
	SerializeBase.WritePrimitive(writer, tlid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.ReportTLFinish = function(self, tlid)
	self.Notify(self, 67271629, SerializerHelper.ReportTLFinish_Serializer, tlid)
end

SerializerHelper.AskSwitchSpiritComplete_Serializer = function(writer, switchspiritid)
	SerializeBase.WritePrimitive(writer, switchspiritid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskSwitchSpiritComplete = function(self, switchspiritid)
	return self.Invoke(self, 67272187, SerializerHelper.AskSwitchSpiritComplete_Serializer, switchspiritid)
end

SerializerHelper.AskRemoveClientBuff_Serializer = function(writer, unitid, buffid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, buffid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskRemoveClientBuff = function(self, unitid, buffid)
	self.Notify(self, 67273633, SerializerHelper.AskRemoveClientBuff_Serializer, unitid, buffid)
end

SerializerHelper.AskVehicleRadioEvent_Serializer = function(writer, info)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WriteRadioSyncInfo, "info", false)
end

ClientToGameSceneDelegate.AskVehicleRadioEvent = function(self, info)
	self.Notify(self, 67278746, SerializerHelper.AskVehicleRadioEvent_Serializer, info)
end

SerializerHelper.AskRemovePaokuLimit_Serializer = function(writer, limitids, sourcetype, sourceid)
	SerializeBase.WriteList7Bit(writer, limitids, writer.WriteUInt32, 0, "limitids", false, RpcLengthLimits.IClientToGameScene_AskRemovePaokuLimit_limitIds, nil)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(sourcetype, 44, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, sourceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskRemovePaokuLimit = function(self, limitids, sourcetype, sourceid)
	return self.Invoke(self, 67281330, SerializerHelper.AskRemovePaokuLimit_Serializer, limitids, sourcetype, sourceid)
end

SerializerHelper.AskVehicleEnterArea_Serializer = function(writer, identifyareaid, vehicleid)
	SerializeBase.WritePrimitive(writer, identifyareaid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskVehicleEnterArea = function(self, identifyareaid, vehicleid)
	return self.Invoke(self, 67283857, SerializerHelper.AskVehicleEnterArea_Serializer, identifyareaid, vehicleid)
end

SerializerHelper.AskVehicleSendStateSignal_Serializer = function(writer, id, signal)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(signal, 59, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskVehicleSendStateSignal = function(self, id, signal)
	self.Notify(self, 67288019, SerializerHelper.AskVehicleSendStateSignal_Serializer, id, signal)
end

SerializerHelper.AskSwitchSpiritByTaskRole_Serializer = function(writer, roleid)
	SerializeBase.WritePrimitive(writer, roleid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskSwitchSpiritByTaskRole = function(self, roleid)
	return self.Invoke(self, 67290457, SerializerHelper.AskSwitchSpiritByTaskRole_Serializer, roleid)
end

SerializerHelper.AskCinemaTaskEndMovie_Serializer = function(writer, locationid, movieid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, movieid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskCinemaTaskEndMovie = function(self, locationid, movieid)
	return self.Invoke(self, 67290612, SerializerHelper.AskCinemaTaskEndMovie_Serializer, locationid, movieid)
end

SerializerHelper.AskControlAgent_Serializer = function(writer, agententityid, reason)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(reason, 60, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskControlAgent = function(self, agententityid, reason)
	self.Notify(self, 67291468, SerializerHelper.AskControlAgent_Serializer, agententityid, reason)
end

SerializerHelper.AskCheckSpoonCondition_Serializer = function(writer, id, nodeid, graphid, param)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, graphid, writer.WriteInt32, 0)
	SerializeBase.WriteComplex(writer, param, SerializeAuto.WriteSpoonActionParam, "param", true)
end

ClientToGameSceneDelegate.AskCheckSpoonCondition = function(self, id, nodeid, graphid, param)
	return self.Invoke(self, 67292037, SerializerHelper.AskCheckSpoonCondition_Serializer, id, nodeid, graphid, param)
end

SerializerHelper.AskDrillShelfCell_Serializer = function(writer, gadgetid, row, col)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, row, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, col, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskDrillShelfCell = function(self, gadgetid, row, col)
	return self.Invoke(self, 67292528, SerializerHelper.AskDrillShelfCell_Serializer, gadgetid, row, col)
end

SerializerHelper.AskPickUpSceneItemTransferToItem_Serializer = function(writer, sceneitemuid)
	SerializeBase.WritePrimitive(writer, sceneitemuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskPickUpSceneItemTransferToItem = function(self, sceneitemuid)
	return self.Invoke(self, 67297154, SerializerHelper.AskPickUpSceneItemTransferToItem_Serializer, sceneitemuid)
end

SerializerHelper.AskPlotStopControlEnemy_Serializer = function(writer, taskid, nodeid, enemyid, pos, facing)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskPlotStopControlEnemy = function(self, taskid, nodeid, enemyid, pos, facing)
	self.Notify(self, 67298257, SerializerHelper.AskPlotStopControlEnemy_Serializer, taskid, nodeid, enemyid, pos, facing)
end

SerializerHelper.AskCinemaOutdoorEndMovie_Serializer = function(writer, locationid, movieid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, movieid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskCinemaOutdoorEndMovie = function(self, locationid, movieid)
	return self.Invoke(self, 67301381, SerializerHelper.AskCinemaOutdoorEndMovie_Serializer, locationid, movieid)
end

SerializerHelper.AskUnitMoveActionWithGround_Serializer = function(writer, actions, clientlocaltime)
	SerializeBase.WriteList7Bit(writer, actions, SerializeBase.WriteStructWrap(SerializeAuto.WriteMoveActionDataWithGround, "actions"), nil, "actions", false, RpcLengthLimits.IClientToGameScene_AskUnitMoveActionWithGround_actions, nil)
	SerializeBase.WritePrimitive(writer, clientlocaltime, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskUnitMoveActionWithGround = function(self, actions, clientlocaltime)
	self.Notify(self, 67305768, SerializerHelper.AskUnitMoveActionWithGround_Serializer, actions, clientlocaltime)
end

SerializerHelper.ReportEnemyWeaponState_Serializer = function(writer, enemyweaponstates)
	SerializeBase.WriteList7Bit(writer, enemyweaponstates, SerializeBase.WriteStructWrap(SerializeAuto.WriteEnemyWeaponState, "enemyweaponstates"), nil, "enemyweaponstates", false, RpcLengthLimits.IClientToGameScene_ReportEnemyWeaponState_enemyWeaponStates, nil)
end

ClientToGameSceneDelegate.ReportEnemyWeaponState = function(self, enemyweaponstates)
	self.Notify(self, 67307274, SerializerHelper.ReportEnemyWeaponState_Serializer, enemyweaponstates)
end

SerializerHelper.AskChineseChessEnterZoneDoubleAI_Serializer = function(writer, gadgetuid, agentid, useredpiece, difficulty)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, useredpiece, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(difficulty, 53, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskChineseChessEnterZoneDoubleAI = function(self, gadgetuid, agentid, useredpiece, difficulty)
	return self.Invoke(self, 67307903, SerializerHelper.AskChineseChessEnterZoneDoubleAI_Serializer, gadgetuid, agentid, useredpiece, difficulty)
end

SerializerHelper.AskChineseChessRequestUndo_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskChineseChessRequestUndo = function(self, gadgetuid)
	return self.Invoke(self, 67311528, SerializerHelper.AskChineseChessRequestUndo_Serializer, gadgetuid)
end

SerializerHelper.ActiveGadgetId_Serializer = function(writer, gadgetid)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ActiveGadgetId = function(self, gadgetid)
	return self.Invoke(self, 67312027, SerializerHelper.ActiveGadgetId_Serializer, gadgetid)
end

SerializerHelper.AskPlayerLeaveMetro_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskPlayerLeaveMetro = function(self)
	return self.Invoke(self, 67313946, SerializerHelper.AskPlayerLeaveMetro_Serializer)
end

SerializerHelper.AskReleaseLuaSlotEntityEvent_Serializer = function(writer, name, id, isdynamic)
	writer.WriteString(writer, name, false, "AskReleaseLuaSlotEntityEvent.name", RpcLengthLimits.IClientToGameScene_AskReleaseLuaSlotEntityEvent_name)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, isdynamic, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskReleaseLuaSlotEntityEvent = function(self, name, id, isdynamic)
	return self.Invoke(self, 67314956, SerializerHelper.AskReleaseLuaSlotEntityEvent_Serializer, name, id, isdynamic)
end

SerializerHelper.AskVehicleStopHackerAutonomousDriving_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskVehicleStopHackerAutonomousDriving = function(self)
	self.Notify(self, 67315681, SerializerHelper.AskVehicleStopHackerAutonomousDriving_Serializer)
end

SerializerHelper.AskHackVehicle_Serializer = function(writer, vehicleid, actiontype, parameter)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(actiontype, 61, 0), writer.WriteByte, 0)
	SerializeBase.WriteComplex(writer, parameter, SerializeAuto.WriteVehicleHackActionParameter, "parameter", true)
end

ClientToGameSceneDelegate.AskHackVehicle = function(self, vehicleid, actiontype, parameter)
	return self.Invoke(self, 67316453, SerializerHelper.AskHackVehicle_Serializer, vehicleid, actiontype, parameter)
end

SerializerHelper.AskVehicleNavigationPathPoints_Serializer = function(writer, navreqid, targetposition, ignoredirection, ignorealley, needcenterpoints, usenavmeshconnect, navigationprofile)
	SerializeBase.WritePrimitive(writer, navreqid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, targetposition, SerializeAuto.WriteUXVector3, "targetposition")
	SerializeBase.WritePrimitive(writer, ignoredirection, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, ignorealley, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, needcenterpoints, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, usenavmeshconnect, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(navigationprofile, 58, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskVehicleNavigationPathPoints = function(self, navreqid, targetposition, ignoredirection, ignorealley, needcenterpoints, usenavmeshconnect, navigationprofile)
	return self.Invoke(self, 67317431, SerializerHelper.AskVehicleNavigationPathPoints_Serializer, navreqid, targetposition, ignoredirection, ignorealley, needcenterpoints, usenavmeshconnect, navigationprofile)
end

SerializerHelper.AskRemoveEnemyStiff_Serializer = function(writer, pid, stiffid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, stiffid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskRemoveEnemyStiff = function(self, pid, stiffid)
	self.Notify(self, 67319001, SerializerHelper.AskRemoveEnemyStiff_Serializer, pid, stiffid)
end

SerializerHelper.AskStateTreeTrigger_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskStateTreeTrigger = function(self, id)
	return self.Invoke(self, 67320885, SerializerHelper.AskStateTreeTrigger_Serializer, id)
end

SerializerHelper.AskCinemaQueryInfo_Serializer = function(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskCinemaQueryInfo = function(self, locationid)
	return self.Invoke(self, 67327708, SerializerHelper.AskCinemaQueryInfo_Serializer, locationid)
end

SerializerHelper.ReportUnitStandUp_Serializer = function(writer, unitid, stiffid, stifftime)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, stiffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, stifftime, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.ReportUnitStandUp = function(self, unitid, stiffid, stifftime)
	return self.Invoke(self, 67329238, SerializerHelper.ReportUnitStandUp_Serializer, unitid, stiffid, stifftime)
end

SerializerHelper.AskUpdatePlayerCameraRotation_Serializer = function(writer, forward, up)
	SerializeBase.WriteStruct(writer, forward, SerializeAuto.WriteUXVector3, "forward")
	SerializeBase.WriteStruct(writer, up, SerializeAuto.WriteUXVector3, "up")
end

ClientToGameSceneDelegate.AskUpdatePlayerCameraRotation = function(self, forward, up)
	self.Notify(self, 67333742, SerializerHelper.AskUpdatePlayerCameraRotation_Serializer, forward, up)
end

SerializerHelper.AskAetherAIRaidVehicleRegressAether_Serializer = function(writer, vehicleinstanceid)
	SerializeBase.WritePrimitive(writer, vehicleinstanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskAetherAIRaidVehicleRegressAether = function(self, vehicleinstanceid)
	return self.Invoke(self, 67334266, SerializerHelper.AskAetherAIRaidVehicleRegressAether_Serializer, vehicleinstanceid)
end

SerializerHelper.AskTwitterPageClose_Serializer = function(writer, closetype)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(closetype, 62, 1), writer.WriteByte, 1)
end

ClientToGameSceneDelegate.AskTwitterPageClose = function(self, closetype)
	self.Notify(self, 67336871, SerializerHelper.AskTwitterPageClose_Serializer, closetype)
end

SerializerHelper.AskActiveDynamicGo_Serializer = function(writer, dyid, active, reason)
	SerializeBase.WritePrimitive(writer, dyid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, active, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(reason, 63, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskActiveDynamicGo = function(self, dyid, active, reason)
	return self.Invoke(self, 67339530, SerializerHelper.AskActiveDynamicGo_Serializer, dyid, active, reason)
end

SerializerHelper.AskSkillDestructibleCreateVehicle_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillDestructibleData, "data", false)
end

ClientToGameSceneDelegate.AskSkillDestructibleCreateVehicle = function(self, data)
	return self.Invoke(self, 67339871, SerializerHelper.AskSkillDestructibleCreateVehicle_Serializer, data)
end

SerializerHelper.EnterGomokuZoneEndGame_Serializer = function(writer, gadgetuid, agentid, endgameid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, endgameid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.EnterGomokuZoneEndGame = function(self, gadgetuid, agentid, endgameid)
	return self.Invoke(self, 67341006, SerializerHelper.EnterGomokuZoneEndGame_Serializer, gadgetuid, agentid, endgameid)
end

SerializerHelper.AskMoveDestructibleObjects_Serializer = function(writer, ids, positions, facings)
	SerializeBase.WriteList7Bit(writer, ids, writer.WriteUInt64, 0, "ids", false, RpcLengthLimits.IClientToGameScene_AskMoveDestructibleObjects_ids, nil)
	SerializeBase.WriteList7Bit(writer, positions, SerializeBase.WriteStructWrap(SerializeAuto.WriteUXVector3, "positions"), nil, "positions", false, RpcLengthLimits.IClientToGameScene_AskMoveDestructibleObjects_positions, nil)
	SerializeBase.WriteList7Bit(writer, facings, SerializeBase.WriteStructWrap(SerializeAuto.WriteUXVector3, "facings"), nil, "facings", false, RpcLengthLimits.IClientToGameScene_AskMoveDestructibleObjects_facings, nil)
end

ClientToGameSceneDelegate.AskMoveDestructibleObjects = function(self, ids, positions, facings)
	self.Notify(self, 67341910, SerializerHelper.AskMoveDestructibleObjects_Serializer, ids, positions, facings)
end

SerializerHelper.ReportEnemyMoveFinish_Serializer = function(writer, datas)
	SerializeBase.WriteList7Bit(writer, datas, SerializeBase.WriteStructWrap(SerializeAuto.WriteEnemyMoveFinishData, "datas"), nil, "datas", false, RpcLengthLimits.IClientToGameScene_ReportEnemyMoveFinish_datas, nil)
end

ClientToGameSceneDelegate.ReportEnemyMoveFinish = function(self, datas)
	self.Notify(self, 67343667, SerializerHelper.ReportEnemyMoveFinish_Serializer, datas)
end

SerializerHelper.AskVehicleForwardEvent_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteVehicleForwardEventData, "data", false)
end

ClientToGameSceneDelegate.AskVehicleForwardEvent = function(self, data)
	self.Notify(self, 67344120, SerializerHelper.AskVehicleForwardEvent_Serializer, data)
end

SerializerHelper.AskGetSpoonServerOutputPortIndexByType_Serializer = function(writer, param)
	SerializeBase.WriteComplex(writer, param, SerializeAuto.WriteSpoonServerActionParam, "param", false)
end

ClientToGameSceneDelegate.AskGetSpoonServerOutputPortIndexByType = function(self, param)
	return self.Invoke(self, 67346473, SerializerHelper.AskGetSpoonServerOutputPortIndexByType_Serializer, param)
end

SerializerHelper.AskUpdatePlayerCameraAspectRatio_Serializer = function(writer, ratio)
	SerializeBase.WritePrimitive(writer, ratio, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskUpdatePlayerCameraAspectRatio = function(self, ratio)
	self.Notify(self, 67346857, SerializerHelper.AskUpdatePlayerCameraAspectRatio_Serializer, ratio)
end

SerializerHelper.AskClientInviteOccupy_Serializer = function(writer, npccultivationid, gameplaytype, start, position)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, gameplaytype, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, start, writer.WriteBoolean, false)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
end

ClientToGameSceneDelegate.AskClientInviteOccupy = function(self, npccultivationid, gameplaytype, start, position)
	return self.Invoke(self, 67349129, SerializerHelper.AskClientInviteOccupy_Serializer, npccultivationid, gameplaytype, start, position)
end

SerializerHelper.AskTeleportToLeavingWaypoint_Serializer = function(writer, carshopid)
	SerializeBase.WritePrimitive(writer, carshopid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskTeleportToLeavingWaypoint = function(self, carshopid)
	return self.Invoke(self, 67349910, SerializerHelper.AskTeleportToLeavingWaypoint_Serializer, carshopid)
end

SerializerHelper.AskOperateDestructibleObject_Serializer = function(writer, id, operation)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(operation, 51, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskOperateDestructibleObject = function(self, id, operation)
	return self.Invoke(self, 67351604, SerializerHelper.AskOperateDestructibleObject_Serializer, id, operation)
end

SerializerHelper.ReportInteractionEnd_Serializer = function(writer)
end

ClientToGameSceneDelegate.ReportInteractionEnd = function(self)
	return self.Invoke(self, 67352174, SerializerHelper.ReportInteractionEnd_Serializer)
end

SerializerHelper.AskAgentEnterStiff_Serializer = function(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskAgentEnterStiff = function(self, agentid)
	self.Notify(self, 67352229, SerializerHelper.AskAgentEnterStiff_Serializer, agentid)
end

SerializerHelper.AskSkillUseWeaponDurability_Serializer = function(writer, skillid, triggerindex)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, triggerindex, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskSkillUseWeaponDurability = function(self, skillid, triggerindex)
	self.Notify(self, 67352644, SerializerHelper.AskSkillUseWeaponDurability_Serializer, skillid, triggerindex)
end

SerializerHelper.LeaveGameGroundZone_Serializer = function(writer)
end

ClientToGameSceneDelegate.LeaveGameGroundZone = function(self)
	return self.Invoke(self, 67354354, SerializerHelper.LeaveGameGroundZone_Serializer)
end

SerializerHelper.AskMaidTeaSettlement_Serializer = function(writer, info)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WriteMaidTeaChoiceInfo, "info", false)
end

ClientToGameSceneDelegate.AskMaidTeaSettlement = function(self, info)
	return self.Invoke(self, 67354737, SerializerHelper.AskMaidTeaSettlement_Serializer, info)
end

SerializerHelper.AskRemoveBasketBallExclusiveTag_Serializer = function(writer, agentid, tag)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, tag, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskRemoveBasketBallExclusiveTag = function(self, agentid, tag)
	self.Notify(self, 67356653, SerializerHelper.AskRemoveBasketBallExclusiveTag_Serializer, agentid, tag)
end

SerializerHelper.AskVehicleStartHackerAutonomousDriving_Serializer = function(writer, targetposition)
	SerializeBase.WriteStruct(writer, targetposition, SerializeAuto.WriteUXVector3, "targetposition")
end

ClientToGameSceneDelegate.AskVehicleStartHackerAutonomousDriving = function(self, targetposition)
	return self.Invoke(self, 67358979, SerializerHelper.AskVehicleStartHackerAutonomousDriving_Serializer, targetposition)
end

SerializerHelper.AskTaskGadgetsListLoadComplete_Serializer = function(writer, gadgetids)
	SerializeBase.WriteList7Bit(writer, gadgetids, writer.WriteUInt64, 0, "gadgetids", false, RpcLengthLimits.IClientToGameScene_AskTaskGadgetsListLoadComplete_gadgetIds, nil)
end

ClientToGameSceneDelegate.AskTaskGadgetsListLoadComplete = function(self, gadgetids)
	return self.Invoke(self, 67359333, SerializerHelper.AskTaskGadgetsListLoadComplete_Serializer, gadgetids)
end

SerializerHelper.CancelShortChatMark_Serializer = function(writer)
end

ClientToGameSceneDelegate.CancelShortChatMark = function(self)
	return self.Invoke(self, 67359673, SerializerHelper.CancelShortChatMark_Serializer)
end

SerializerHelper.AskSyncGadgetSyncInfo_Serializer = function(writer, syncinfo)
	SerializeBase.WriteComplex(writer, syncinfo, SerializeAuto.WriteGadgetSyncInfo, "syncinfo", false)
end

ClientToGameSceneDelegate.AskSyncGadgetSyncInfo = function(self, syncinfo)
	self.Notify(self, 67362406, SerializerHelper.AskSyncGadgetSyncInfo_Serializer, syncinfo)
end

SerializerHelper.ReportUnitFreezeActionOver_Serializer = function(writer, unitid, stateid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, stateid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.ReportUnitFreezeActionOver = function(self, unitid, stateid)
	self.Notify(self, 67362487, SerializerHelper.ReportUnitFreezeActionOver_Serializer, unitid, stateid)
end

SerializerHelper.AskItemDestructibleCreate_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteItemDestructibleData, "data", false)
end

ClientToGameSceneDelegate.AskItemDestructibleCreate = function(self, data)
	return self.Invoke(self, 67362514, SerializerHelper.AskItemDestructibleCreate_Serializer, data)
end

SerializerHelper.AskStartTaxiNavigate_Serializer = function(writer, taxiid, totaldis)
	SerializeBase.WritePrimitive(writer, taxiid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, totaldis, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskStartTaxiNavigate = function(self, taxiid, totaldis)
	return self.Invoke(self, 67363555, SerializerHelper.AskStartTaxiNavigate_Serializer, taxiid, totaldis)
end

SerializerHelper.AskPickUpAgentAsWeapon_Serializer = function(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskPickUpAgentAsWeapon = function(self, agententityid)
	return self.Invoke(self, 67368854, SerializerHelper.AskPickUpAgentAsWeapon_Serializer, agententityid)
end

SerializerHelper.AskSetEmotionByStateTree_Serializer = function(writer, agententityid, emotion, state)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, emotion, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, state, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskSetEmotionByStateTree = function(self, agententityid, emotion, state)
	self.Notify(self, 67372155, SerializerHelper.AskSetEmotionByStateTree_Serializer, agententityid, emotion, state)
end

SerializerHelper.AskSwitchDefaultWeapon_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskSwitchDefaultWeapon = function(self)
	self.Notify(self, 67372797, SerializerHelper.AskSwitchDefaultWeapon_Serializer)
end

SerializerHelper.AskUpdateVehicleAITaskStatus_Serializer = function(writer, vehicleuid, token, newstatus)
	SerializeBase.WritePrimitive(writer, vehicleuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, token, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(newstatus, 64, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskUpdateVehicleAITaskStatus = function(self, vehicleuid, token, newstatus)
	self.Notify(self, 67376985, SerializerHelper.AskUpdateVehicleAITaskStatus_Serializer, vehicleuid, token, newstatus)
end

SerializerHelper.AskStartRescueFallingDownPlayer_Serializer = function(writer, uid)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskStartRescueFallingDownPlayer = function(self, uid)
	return self.Invoke(self, 67377190, SerializerHelper.AskStartRescueFallingDownPlayer_Serializer, uid)
end

SerializerHelper.EnterGomokuZoneDoublePlayer_Serializer = function(writer, gadgetuid, canuseskill)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, canuseskill, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.EnterGomokuZoneDoublePlayer = function(self, gadgetuid, canuseskill)
	return self.Invoke(self, 67377693, SerializerHelper.EnterGomokuZoneDoublePlayer_Serializer, gadgetuid, canuseskill)
end

SerializerHelper.AskAddPaokuRoomLimit_Serializer = function(writer, roomid)
	SerializeBase.WritePrimitive(writer, roomid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskAddPaokuRoomLimit = function(self, roomid)
	return self.Invoke(self, 67378162, SerializerHelper.AskAddPaokuRoomLimit_Serializer, roomid)
end

SerializerHelper.AskFishDestructibleRemove_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskFishDestructibleRemove = function(self, id)
	self.Notify(self, 67380129, SerializerHelper.AskFishDestructibleRemove_Serializer, id)
end

SerializerHelper.AskUnequipParagliderWheel_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskUnequipParagliderWheel = function(self)
	self.Notify(self, 67382552, SerializerHelper.AskUnequipParagliderWheel_Serializer)
end

SerializerHelper.AskBreakStimReaction_Serializer = function(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskBreakStimReaction = function(self, agentid)
	self.Notify(self, 67383056, SerializerHelper.AskBreakStimReaction_Serializer, agentid)
end

SerializerHelper.AskTeleportOnCrossBoundary_Serializer = function(writer, teleportpos, facingdirection)
	SerializeBase.WriteStruct(writer, teleportpos, SerializeAuto.WriteUXVector3, "teleportpos")
	SerializeBase.WritePrimitive(writer, facingdirection, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskTeleportOnCrossBoundary = function(self, teleportpos, facingdirection)
	return self.Invoke(self, 67386879, SerializerHelper.AskTeleportOnCrossBoundary_Serializer, teleportpos, facingdirection)
end

SerializerHelper.ReportBlockCounterSuccess_Serializer = function(writer, defenderid, attackerid, beblocktype)
	SerializeBase.WritePrimitive(writer, defenderid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, attackerid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(beblocktype, 65, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.ReportBlockCounterSuccess = function(self, defenderid, attackerid, beblocktype)
	self.Notify(self, 67389599, SerializerHelper.ReportBlockCounterSuccess_Serializer, defenderid, attackerid, beblocktype)
end

SerializerHelper.AskInteractCmd_Serializer = function(writer, data)
	SerializeBase.WriteStruct(writer, data, SerializeAuto.WriteInteractCmdData, "data")
end

ClientToGameSceneDelegate.AskInteractCmd = function(self, data)
	self.Notify(self, 67390408, SerializerHelper.AskInteractCmd_Serializer, data)
end

SerializerHelper.AskBirdsGroupAlert_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskBirdsGroupAlert = function(self, id)
	self.Notify(self, 67392371, SerializerHelper.AskBirdsGroupAlert_Serializer, id)
end

SerializerHelper.AskCreateDestructibleAndHang_Serializer = function(writer, sceneitemcfgid, hosttype, hostinstanceid, index, position, facing)
	SerializeBase.WritePrimitive(writer, sceneitemcfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, hosttype, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, hostinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WriteStruct(writer, facing, SerializeAuto.WriteUXVector3, "facing")
end

ClientToGameSceneDelegate.AskCreateDestructibleAndHang = function(self, sceneitemcfgid, hosttype, hostinstanceid, index, position, facing)
	return self.Invoke(self, 67393101, SerializerHelper.AskCreateDestructibleAndHang_Serializer, sceneitemcfgid, hosttype, hostinstanceid, index, position, facing)
end

SerializerHelper.AskEndPredictHit_Serializer = function(writer, targetid)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskEndPredictHit = function(self, targetid)
	self.Notify(self, 67394086, SerializerHelper.AskEndPredictHit_Serializer, targetid)
end

SerializerHelper.AskTriggerECSEvent_Serializer = function(writer, eventid, agentinfos, parameter)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
	SerializeBase.WriteList7Bit(writer, agentinfos, SerializeBase.WriteStructWrap(SerializeAuto.WriteECSStimInfo, "agentinfos"), nil, "agentinfos", false, RpcLengthLimits.IClientToGameScene_AskTriggerECSEvent_agentInfos, nil)
	SerializeBase.WriteStruct(writer, parameter, SerializeAuto.WriteStimEventParameter, "parameter")
end

ClientToGameSceneDelegate.AskTriggerECSEvent = function(self, eventid, agentinfos, parameter)
	self.Notify(self, 67402686, SerializerHelper.AskTriggerECSEvent_Serializer, eventid, agentinfos, parameter)
end

SerializerHelper.RefreshSceneDestructible_Serializer = function(writer, center, distance)
	SerializeBase.WriteStruct(writer, center, SerializeAuto.WriteUXVector3, "center")
	SerializeBase.WritePrimitive(writer, distance, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.RefreshSceneDestructible = function(self, center, distance)
	self.Notify(self, 67404266, SerializerHelper.RefreshSceneDestructible_Serializer, center, distance)
end

SerializerHelper.AskMultiCinemaBuyTicket_Serializer = function(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskMultiCinemaBuyTicket = function(self, locationid)
	return self.Invoke(self, 67406140, SerializerHelper.AskMultiCinemaBuyTicket_Serializer, locationid)
end

SerializerHelper.AskChangeBelongingItemStates_Serializer = function(writer, list)
	SerializeBase.WriteList7Bit(writer, list, SerializeBase.WriteStructWrap(SerializeAuto.WriteBelongingItemStateChangeData, "list"), nil, "list", false, RpcLengthLimits.IClientToGameScene_AskChangeBelongingItemStates_list, nil)
end

ClientToGameSceneDelegate.AskChangeBelongingItemStates = function(self, list)
	self.Notify(self, 67406341, SerializerHelper.AskChangeBelongingItemStates_Serializer, list)
end

SerializerHelper.ReportInteractionStart_Serializer = function(writer, interactiontype)
	SerializeBase.WritePrimitive(writer, interactiontype, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.ReportInteractionStart = function(self, interactiontype)
	return self.Invoke(self, 67408095, SerializerHelper.ReportInteractionStart_Serializer, interactiontype)
end

SerializerHelper.AskExtractionShooterSearchContainer_Serializer = function(writer, containerinstanceid)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskExtractionShooterSearchContainer = function(self, containerinstanceid)
	return self.Invoke(self, 67410186, SerializerHelper.AskExtractionShooterSearchContainer_Serializer, containerinstanceid)
end

SerializerHelper.ReportEnemyReturnEdict_Serializer = function(writer, uid)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportEnemyReturnEdict = function(self, uid)
	self.Notify(self, 67413872, SerializerHelper.ReportEnemyReturnEdict_Serializer, uid)
end

SerializerHelper.AskGadgetSceneRoomTrigger_Serializer = function(writer, sceneroomid, gadgetuniqueid, isenter)
	SerializeBase.WritePrimitive(writer, sceneroomid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, gadgetuniqueid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, isenter, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskGadgetSceneRoomTrigger = function(self, sceneroomid, gadgetuniqueid, isenter)
	return self.Invoke(self, 67413973, SerializerHelper.AskGadgetSceneRoomTrigger_Serializer, sceneroomid, gadgetuniqueid, isenter)
end

SerializerHelper.AskVehicleSkillDamage_Serializer = function(writer, vehicleid, data)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, data, SerializeAuto.WriteVehicleSkillDamageData, "data")
end

ClientToGameSceneDelegate.AskVehicleSkillDamage = function(self, vehicleid, data)
	self.Notify(self, 67415233, SerializerHelper.AskVehicleSkillDamage_Serializer, vehicleid, data)
end

SerializerHelper.SyncSetCheckPointIndex_Serializer = function(writer, index)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.SyncSetCheckPointIndex = function(self, index)
	return self.Invoke(self, 67416557, SerializerHelper.SyncSetCheckPointIndex_Serializer, index)
end

SerializerHelper.AskGenerateChefOrder_Serializer = function(writer, recipeids)
	SerializeBase.WriteList7Bit(writer, recipeids, writer.WriteUInt32, 0, "recipeids", false, RpcLengthLimits.IClientToGameScene_AskGenerateChefOrder_recipeIds, nil)
end

ClientToGameSceneDelegate.AskGenerateChefOrder = function(self, recipeids)
	return self.Invoke(self, 67417729, SerializerHelper.AskGenerateChefOrder_Serializer, recipeids)
end

SerializerHelper.EnterBalloonZone_Serializer = function(writer, gadgetuid, gametype)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(gametype, 66, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.EnterBalloonZone = function(self, gadgetuid, gametype)
	return self.Invoke(self, 67417935, SerializerHelper.EnterBalloonZone_Serializer, gadgetuid, gametype)
end

SerializerHelper.BroadcastBowlingClientInfo_Serializer = function(writer, gadgetuid, syncinfo)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WriteComplex(writer, syncinfo, SerializeAuto.WriteBowlingClientInfo, "syncinfo", false)
end

ClientToGameSceneDelegate.BroadcastBowlingClientInfo = function(self, gadgetuid, syncinfo)
	return self.Invoke(self, 67421355, SerializerHelper.BroadcastBowlingClientInfo_Serializer, gadgetuid, syncinfo)
end

SerializerHelper.AskAetherStaticNpcReturnToSpawnPoint_Serializer = function(writer, entityid)
	SerializeBase.WritePrimitive(writer, entityid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskAetherStaticNpcReturnToSpawnPoint = function(self, entityid)
	self.Notify(self, 67421376, SerializerHelper.AskAetherStaticNpcReturnToSpawnPoint_Serializer, entityid)
end

SerializerHelper.AskBowlingBuyTicket_Serializer = function(writer, issingle)
	SerializeBase.WritePrimitive(writer, issingle, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskBowlingBuyTicket = function(self, issingle)
	return self.Invoke(self, 67421670, SerializerHelper.AskBowlingBuyTicket_Serializer, issingle)
end

SerializerHelper.SendShortChat_Serializer = function(writer, id, mark)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, mark, SerializeAuto.WriteShortChatMark, "mark", true)
end

ClientToGameSceneDelegate.SendShortChat = function(self, id, mark)
	return self.Invoke(self, 67422114, SerializerHelper.SendShortChat_Serializer, id, mark)
end

SerializerHelper.ReportTargetRayCastRes_Serializer = function(writer, infos)
	SerializeBase.WriteList7Bit(writer, infos, SerializeBase.WriteStructWrap(SerializeAuto.WriteTargetRayCastResInfo, "infos"), nil, "infos", false, RpcLengthLimits.IClientToGameScene_ReportTargetRayCastRes_infos, nil)
end

ClientToGameSceneDelegate.ReportTargetRayCastRes = function(self, infos)
	self.Notify(self, 67423198, SerializerHelper.ReportTargetRayCastRes_Serializer, infos)
end

SerializerHelper.AskBreakSkillTimeCurve_Serializer = function(writer, releaser, id, index)
	SerializeBase.WritePrimitive(writer, releaser, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskBreakSkillTimeCurve = function(self, releaser, id, index)
	self.Notify(self, 67425306, SerializerHelper.AskBreakSkillTimeCurve_Serializer, releaser, id, index)
end

SerializerHelper.ReportEnemyPrepareFinish_Serializer = function(writer, enemyids)
	SerializeBase.WriteList7Bit(writer, enemyids, writer.WriteUInt64, 0, "enemyids", false, RpcLengthLimits.IClientToGameScene_ReportEnemyPrepareFinish_enemyIds, nil)
end

ClientToGameSceneDelegate.ReportEnemyPrepareFinish = function(self, enemyids)
	self.Notify(self, 67427299, SerializerHelper.ReportEnemyPrepareFinish_Serializer, enemyids)
end

SerializerHelper.ReportUnitHitFly_Serializer = function(writer, defenderid, attackerid, hitflystiffid, stifftime)
	SerializeBase.WritePrimitive(writer, defenderid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, attackerid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, hitflystiffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, stifftime, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.ReportUnitHitFly = function(self, defenderid, attackerid, hitflystiffid, stifftime)
	return self.Invoke(self, 67430580, SerializerHelper.ReportUnitHitFly_Serializer, defenderid, attackerid, hitflystiffid, stifftime)
end

SerializerHelper.AskPlotControlEnemy_Serializer = function(writer, taskid, nodeid, enemyid, notstopai)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, notstopai, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskPlotControlEnemy = function(self, taskid, nodeid, enemyid, notstopai)
	self.Notify(self, 67431313, SerializerHelper.AskPlotControlEnemy_Serializer, taskid, nodeid, enemyid, notstopai)
end

SerializerHelper.AskResetVehicleOutsideToNearestLane_Serializer = function(writer, vehicleid, currentpos, targetpos, targetfacing)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, currentpos, SerializeAuto.WriteUXVector3, "currentpos")
	SerializeBase.WriteStruct(writer, targetpos, SerializeAuto.WriteUXVector3, "targetpos")
	SerializeBase.WritePrimitive(writer, targetfacing, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskResetVehicleOutsideToNearestLane = function(self, vehicleid, currentpos, targetpos, targetfacing)
	return self.Invoke(self, 67434793, SerializerHelper.AskResetVehicleOutsideToNearestLane_Serializer, vehicleid, currentpos, targetpos, targetfacing)
end

SerializerHelper.AskFerrisWheelCabinDoor_Serializer = function(writer, cabinindex, doorstate)
	SerializeBase.WritePrimitive(writer, cabinindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(doorstate, 67, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskFerrisWheelCabinDoor = function(self, cabinindex, doorstate)
	self.Notify(self, 67437195, SerializerHelper.AskFerrisWheelCabinDoor_Serializer, cabinindex, doorstate)
end

SerializerHelper.AskGravityLand_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskGravityLand = function(self, pid)
	self.Notify(self, 67438155, SerializerHelper.AskGravityLand_Serializer, pid)
end

SerializerHelper.AskAgentStartNpcDialog_Serializer = function(writer, agententityid, npcdialogid, dialogduration)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, npcdialogid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, dialogduration, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskAgentStartNpcDialog = function(self, agententityid, npcdialogid, dialogduration)
	self.Notify(self, 67438669, SerializerHelper.AskAgentStartNpcDialog_Serializer, agententityid, npcdialogid, dialogduration)
end

SerializerHelper.AskVehicleDeadEnd_Serializer = function(writer, vehicleentityid, deadposition)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, deadposition, SerializeAuto.WriteUXVector3, "deadposition")
end

ClientToGameSceneDelegate.AskVehicleDeadEnd = function(self, vehicleentityid, deadposition)
	return self.Invoke(self, 67439230, SerializerHelper.AskVehicleDeadEnd_Serializer, vehicleentityid, deadposition)
end

SerializerHelper.AskVehicleEnterWater_Serializer = function(writer, vehicleentityid)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskVehicleEnterWater = function(self, vehicleentityid)
	self.Notify(self, 67440090, SerializerHelper.AskVehicleEnterWater_Serializer, vehicleentityid)
end

SerializerHelper.AskEnemyStartFall_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskEnemyStartFall = function(self, pid)
	self.Notify(self, 67445303, SerializerHelper.AskEnemyStartFall_Serializer, pid)
end

SerializerHelper.AskPlayerIsInFerrisWheel_Serializer = function(writer, index, isin)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, isin, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskPlayerIsInFerrisWheel = function(self, index, isin)
	return self.Invoke(self, 67445844, SerializerHelper.AskPlayerIsInFerrisWheel_Serializer, index, isin)
end

SerializerHelper.AskStopRideAgent_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskStopRideAgent = function(self)
	return self.Invoke(self, 67449345, SerializerHelper.AskStopRideAgent_Serializer)
end

SerializerHelper.NpcInteractAction_Serializer = function(writer, instanceid, index, taskid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.NpcInteractAction = function(self, instanceid, index, taskid)
	return self.Invoke(self, 67449433, SerializerHelper.NpcInteractAction_Serializer, instanceid, index, taskid)
end

SerializerHelper.AskReadWeaponRedDots_Serializer = function(writer, weaponinstanceids)
	SerializeBase.WriteList7Bit(writer, weaponinstanceids, writer.WriteUInt64, 0, "weaponinstanceids", false, RpcLengthLimits.IClientToGameScene_AskReadWeaponRedDots_weaponInstanceIds, nil)
end

ClientToGameSceneDelegate.AskReadWeaponRedDots = function(self, weaponinstanceids)
	self.Notify(self, 67449888, SerializerHelper.AskReadWeaponRedDots_Serializer, weaponinstanceids)
end

SerializerHelper.AskChineseChessSurrender_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskChineseChessSurrender = function(self, gadgetuid)
	return self.Invoke(self, 67452562, SerializerHelper.AskChineseChessSurrender_Serializer, gadgetuid)
end

SerializerHelper.AskEnemyItemPickUp_Serializer = function(writer, enemyinstanceid, binditemsindex)
	SerializeBase.WritePrimitive(writer, enemyinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, binditemsindex, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskEnemyItemPickUp = function(self, enemyinstanceid, binditemsindex)
	return self.Invoke(self, 67453017, SerializerHelper.AskEnemyItemPickUp_Serializer, enemyinstanceid, binditemsindex)
end

SerializerHelper.ReportGameplayTagQueryResult_Serializer = function(writer, requestid, entityid, gameplaytagid, hastag)
	SerializeBase.WritePrimitive(writer, requestid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, entityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, gameplaytagid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, hastag, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.ReportGameplayTagQueryResult = function(self, requestid, entityid, gameplaytagid, hastag)
	self.Notify(self, 67455156, SerializerHelper.ReportGameplayTagQueryResult_Serializer, requestid, entityid, gameplaytagid, hastag)
end

SerializerHelper.AskResetGlobalTimeSlow_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskResetGlobalTimeSlow = function(self)
	return self.Invoke(self, 67455497, SerializerHelper.AskResetGlobalTimeSlow_Serializer)
end

SerializerHelper.ReportBeAimed_Serializer = function(writer, uid)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportBeAimed = function(self, uid)
	self.Notify(self, 67461087, SerializerHelper.ReportBeAimed_Serializer, uid)
end

SerializerHelper.AskRepairWeaponDurability_Serializer = function(writer, weaponinstanceid)
	SerializeBase.WritePrimitive(writer, weaponinstanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskRepairWeaponDurability = function(self, weaponinstanceid)
	self.Notify(self, 67461644, SerializerHelper.AskRepairWeaponDurability_Serializer, weaponinstanceid)
end

SerializerHelper.AskFightGameReady_Serializer = function(writer, isai)
	SerializeBase.WritePrimitive(writer, isai, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskFightGameReady = function(self, isai)
	return self.Invoke(self, 67462609, SerializerHelper.AskFightGameReady_Serializer, isai)
end

SerializerHelper.AskChineseChessMovePiece_Serializer = function(writer, gadgetuid, srcx, srcy, tgtx, tgty)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, srcx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, srcy, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tgtx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tgty, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskChineseChessMovePiece = function(self, gadgetuid, srcx, srcy, tgtx, tgty)
	return self.Invoke(self, 67463405, SerializerHelper.AskChineseChessMovePiece_Serializer, gadgetuid, srcx, srcy, tgtx, tgty)
end

SerializerHelper.AskBreakDestructibleObject_Serializer = function(writer, breaker, brokeninfos)
	SerializeBase.WritePrimitive(writer, breaker, writer.WriteUInt64, 0)
	SerializeBase.WriteComplex(writer, brokeninfos, SerializeAuto.WriteDestructibleBrokenInfo, "brokeninfos", false)
end

ClientToGameSceneDelegate.AskBreakDestructibleObject = function(self, breaker, brokeninfos)
	return self.Invoke(self, 67463592, SerializerHelper.AskBreakDestructibleObject_Serializer, breaker, brokeninfos)
end

SerializerHelper.ReportEnemyHitWall_Serializer = function(writer, enemyid, beforehitstiffid, hitpos, hitwallstiff, stifftime)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, beforehitstiffid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, hitpos, SerializeAuto.WriteUXVector3, "hitpos")
	SerializeBase.WritePrimitive(writer, hitwallstiff, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, stifftime, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.ReportEnemyHitWall = function(self, enemyid, beforehitstiffid, hitpos, hitwallstiff, stifftime)
	self.Notify(self, 67468232, SerializerHelper.ReportEnemyHitWall_Serializer, enemyid, beforehitstiffid, hitpos, hitwallstiff, stifftime)
end

SerializerHelper.AskAgentCompanionAI_Serializer = function(writer, unitid, iscompanionai)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, iscompanionai, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskAgentCompanionAI = function(self, unitid, iscompanionai)
	self.Notify(self, 67470246, SerializerHelper.AskAgentCompanionAI_Serializer, unitid, iscompanionai)
end

SerializerHelper.AskNpcFinishEnterOrExitVehicle_Serializer = function(writer, syncdata)
	SerializeBase.WriteComplex(writer, syncdata, SerializeAuto.WriteNpcVehicleDriveStateInfo, "syncdata", false)
end

ClientToGameSceneDelegate.AskNpcFinishEnterOrExitVehicle = function(self, syncdata)
	return self.Invoke(self, 67470490, SerializerHelper.AskNpcFinishEnterOrExitVehicle_Serializer, syncdata)
end

SerializerHelper.AskUnitMoveAction_Serializer = function(writer, actions, clientlocaltime)
	SerializeBase.WriteList7Bit(writer, actions, SerializeBase.WriteStructWrap(SerializeAuto.WriteMoveActionData, "actions"), nil, "actions", false, RpcLengthLimits.IClientToGameScene_AskUnitMoveAction_actions, nil)
	SerializeBase.WritePrimitive(writer, clientlocaltime, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskUnitMoveAction = function(self, actions, clientlocaltime)
	self.Notify(self, 67471618, SerializerHelper.AskUnitMoveAction_Serializer, actions, clientlocaltime)
end

SerializerHelper.AskSyncDestructibleSyncBinInfos_Serializer = function(writer, syncinfos)
	SerializeBase.WriteList7Bit(writer, syncinfos, SerializeBase.WriteComplexWrap(SerializeAuto.WriteDestructibleSyncBinInfo, "DestructibleSyncBinInfo", false), nil, "syncinfos", false, RpcLengthLimits.IClientToGameScene_AskSyncDestructibleSyncBinInfos_syncInfos, nil)
end

ClientToGameSceneDelegate.AskSyncDestructibleSyncBinInfos = function(self, syncinfos)
	self.Notify(self, 67475269, SerializerHelper.AskSyncDestructibleSyncBinInfos_Serializer, syncinfos)
end

SerializerHelper.AskStartCommand_Serializer = function(writer, agentid, data)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCommonCommandData, "data", false)
end

ClientToGameSceneDelegate.AskStartCommand = function(self, agentid, data)
	self.Notify(self, 67476028, SerializerHelper.AskStartCommand_Serializer, agentid, data)
end

SerializerHelper.StartJumpStakeGame_Serializer = function(writer, gadgetuid, sceneitemcfgid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, sceneitemcfgid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.StartJumpStakeGame = function(self, gadgetuid, sceneitemcfgid)
	return self.Invoke(self, 67476780, SerializerHelper.StartJumpStakeGame_Serializer, gadgetuid, sceneitemcfgid)
end

SerializerHelper.ReportBackwardRayCastResult_Serializer = function(writer, uid, hascollision)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, hascollision, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.ReportBackwardRayCastResult = function(self, uid, hascollision)
	self.Notify(self, 67476906, SerializerHelper.ReportBackwardRayCastResult_Serializer, uid, hascollision)
end

SerializerHelper.AskGetRaidGamePlayRecordDoubleValue_Serializer = function(writer, recordid)
	SerializeBase.WritePrimitive(writer, recordid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskGetRaidGamePlayRecordDoubleValue = function(self, recordid)
	return self.Invoke(self, 67476993, SerializerHelper.AskGetRaidGamePlayRecordDoubleValue_Serializer, recordid)
end

SerializerHelper.AskStopInteractChefStove_Serializer = function(writer, stoveid, level)
	SerializeBase.WritePrimitive(writer, stoveid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(level, 68, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskStopInteractChefStove = function(self, stoveid, level)
	return self.Invoke(self, 67477188, SerializerHelper.AskStopInteractChefStove_Serializer, stoveid, level)
end

SerializerHelper.SyncGadgetNavMeshState_Serializer = function(writer, navmeshid, passable)
	SerializeBase.WritePrimitive(writer, navmeshid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, passable, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.SyncGadgetNavMeshState = function(self, navmeshid, passable)
	self.Notify(self, 67477468, SerializerHelper.SyncGadgetNavMeshState_Serializer, navmeshid, passable)
end

SerializerHelper.AskSwitchSpirit_Serializer = function(writer, spiritid)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskSwitchSpirit = function(self, spiritid)
	return self.Invoke(self, 67482531, SerializerHelper.AskSwitchSpirit_Serializer, spiritid)
end

SerializerHelper.RecordDartScore_Serializer = function(writer, score, pos)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
end

ClientToGameSceneDelegate.RecordDartScore = function(self, score, pos)
	return self.Invoke(self, 67483394, SerializerHelper.RecordDartScore_Serializer, score, pos)
end

SerializerHelper.AskAddDestructibleHook_Serializer = function(writer, hooktype, instanceid, hookcfgid, targettype, targetid)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(hooktype, 69, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, hookcfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(targettype, 70, 1), writer.WriteByte, 1)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskAddDestructibleHook = function(self, hooktype, instanceid, hookcfgid, targettype, targetid)
	self.Notify(self, 67483468, SerializerHelper.AskAddDestructibleHook_Serializer, hooktype, instanceid, hookcfgid, targettype, targetid)
end

SerializerHelper.AskAgentRegressVehicle_Serializer = function(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskAgentRegressVehicle = function(self, agententityid)
	self.Notify(self, 67484718, SerializerHelper.AskAgentRegressVehicle_Serializer, agententityid)
end

SerializerHelper.AskBVBLockChaosBuffCandidates_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskBVBLockChaosBuffCandidates = function(self)
	return self.Invoke(self, 67484802, SerializerHelper.AskBVBLockChaosBuffCandidates_Serializer)
end

SerializerHelper.AskDroneHitchStateChanged_Serializer = function(writer, droneentityid, targetdestructibleuniqueid, state)
	SerializeBase.WritePrimitive(writer, droneentityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetdestructibleuniqueid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(state, 71, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskDroneHitchStateChanged = function(self, droneentityid, targetdestructibleuniqueid, state)
	return self.Invoke(self, 67485341, SerializerHelper.AskDroneHitchStateChanged_Serializer, droneentityid, targetdestructibleuniqueid, state)
end

SerializerHelper.AskRepairWeaponWithMaterials_Serializer = function(writer, weaponinstanceid, materials)
	SerializeBase.WritePrimitive(writer, weaponinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WriteDict7Bit(writer, materials, writer.WriteUInt32, writer.WriteUInt32, 0, "materials", false, RpcLengthLimits.IClientToGameScene_AskRepairWeaponWithMaterials_materials)
end

ClientToGameSceneDelegate.AskRepairWeaponWithMaterials = function(self, weaponinstanceid, materials)
	return self.Invoke(self, 67486102, SerializerHelper.AskRepairWeaponWithMaterials_Serializer, weaponinstanceid, materials)
end

SerializerHelper.AskGetTaskValue_Serializer = function(writer, id, key)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	writer.WriteString(writer, key, false, "AskGetTaskValue.key", RpcLengthLimits.IClientToGameScene_AskGetTaskValue_key)
end

ClientToGameSceneDelegate.AskGetTaskValue = function(self, id, key)
	return self.Invoke(self, 67488567, SerializerHelper.AskGetTaskValue_Serializer, id, key)
end

SerializerHelper.SendCustomCommonDataClientToGameScene_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteCustomCommonData, "data", false)
end

ClientToGameSceneDelegate.SendCustomCommonDataClientToGameScene = function(self, data)
	return self.Invoke(self, 67489490, SerializerHelper.SendCustomCommonDataClientToGameScene_Serializer, data)
end

SerializerHelper.QueryChineseChessPlayerInfo_Serializer = function(writer)
end

ClientToGameSceneDelegate.QueryChineseChessPlayerInfo = function(self)
	return self.Invoke(self, 67492072, SerializerHelper.QueryChineseChessPlayerInfo_Serializer)
end

SerializerHelper.AskPlayersLoadRate_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskPlayersLoadRate = function(self)
	self.Notify(self, 67493120, SerializerHelper.AskPlayersLoadRate_Serializer)
end

SerializerHelper.ReportSkillEnd_Serializer = function(writer, unitid, skillid, newskillid, isbreak)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, newskillid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isbreak, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.ReportSkillEnd = function(self, unitid, skillid, newskillid, isbreak)
	self.Notify(self, 67494914, SerializerHelper.ReportSkillEnd_Serializer, unitid, skillid, newskillid, isbreak)
end

SerializerHelper.AskPredictHitPerformance_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteHitPredictData, "data", false)
end

ClientToGameSceneDelegate.AskPredictHitPerformance = function(self, data)
	return self.Invoke(self, 67495947, SerializerHelper.AskPredictHitPerformance_Serializer, data)
end

SerializerHelper.PlaceGomokuPiece_Serializer = function(writer, gadgetuid, x, y)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, x, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, y, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.PlaceGomokuPiece = function(self, gadgetuid, x, y)
	return self.Invoke(self, 67496058, SerializerHelper.PlaceGomokuPiece_Serializer, gadgetuid, x, y)
end

SerializerHelper.AskTrackWildEnemyGroupInfo_Serializer = function(writer, groupspoonid)
	SerializeBase.WritePrimitive(writer, groupspoonid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskTrackWildEnemyGroupInfo = function(self, groupspoonid)
	return self.Invoke(self, 67499219, SerializerHelper.AskTrackWildEnemyGroupInfo_Serializer, groupspoonid)
end

SerializerHelper.BBQFlipMeat_Serializer = function(writer, gadgetuid, meatid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, meatid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.BBQFlipMeat = function(self, gadgetuid, meatid)
	return self.Invoke(self, 67501214, SerializerHelper.BBQFlipMeat_Serializer, gadgetuid, meatid)
end

SerializerHelper.AskAssignChefAgentWork_Serializer = function(writer, cooknpcid, workid)
	SerializeBase.WritePrimitive(writer, cooknpcid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, workid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskAssignChefAgentWork = function(self, cooknpcid, workid)
	return self.Invoke(self, 67502417, SerializerHelper.AskAssignChefAgentWork_Serializer, cooknpcid, workid)
end

SerializerHelper.RecordAllBowlingScoreAndDrop_Serializer = function(writer, gametype, npccultivationid, myscore, npcscore)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(gametype, 72, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, npccultivationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, myscore, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, npcscore, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.RecordAllBowlingScoreAndDrop = function(self, gametype, npccultivationid, myscore, npcscore)
	return self.Invoke(self, 67503674, SerializerHelper.RecordAllBowlingScoreAndDrop_Serializer, gametype, npccultivationid, myscore, npcscore)
end

SerializerHelper.AskCinemaTaskPlayMovie_Serializer = function(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskCinemaTaskPlayMovie = function(self, locationid)
	return self.Invoke(self, 67503845, SerializerHelper.AskCinemaTaskPlayMovie_Serializer, locationid)
end

SerializerHelper.AskQuitExtractionShooter_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskQuitExtractionShooter = function(self)
	return self.Invoke(self, 67504722, SerializerHelper.AskQuitExtractionShooter_Serializer)
end

SerializerHelper.AskSetEmotionsByStateTree_Serializer = function(writer, set, unlock)
	SerializeBase.WriteList7Bit(writer, set, SerializeBase.WriteStructWrap(SerializeAuto.WriteSetEmotionData, "set"), nil, "set", false, RpcLengthLimits.IClientToGameScene_AskSetEmotionsByStateTree_set, nil)
	SerializeBase.WriteList7Bit(writer, unlock, writer.WriteUInt64, 0, "unlock", false, RpcLengthLimits.IClientToGameScene_AskSetEmotionsByStateTree_unlock, nil)
end

ClientToGameSceneDelegate.AskSetEmotionsByStateTree = function(self, set, unlock)
	self.Notify(self, 67507320, SerializerHelper.AskSetEmotionsByStateTree_Serializer, set, unlock)
end

SerializerHelper.LeaveAgent_Serializer = function(writer, instanceid, spoonagentid, distance)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, spoonagentid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, distance, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.LeaveAgent = function(self, instanceid, spoonagentid, distance)
	return self.Invoke(self, 67507483, SerializerHelper.LeaveAgent_Serializer, instanceid, spoonagentid, distance)
end

SerializerHelper.AskInitChefFoodPrepare_Serializer = function(writer, foodprepareids)
	SerializeBase.WriteList7Bit(writer, foodprepareids, writer.WriteUInt32, 0, "foodprepareids", false, RpcLengthLimits.IClientToGameScene_AskInitChefFoodPrepare_foodPrepareIds, nil)
end

ClientToGameSceneDelegate.AskInitChefFoodPrepare = function(self, foodprepareids)
	return self.Invoke(self, 67507812, SerializerHelper.AskInitChefFoodPrepare_Serializer, foodprepareids)
end

SerializerHelper.AskAddRaidGamePlayRecordDoubleValue_Serializer = function(writer, recordid, paramid, addvalue)
	SerializeBase.WritePrimitive(writer, recordid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, paramid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, addvalue, writer.WriteDouble, 0)
end

ClientToGameSceneDelegate.AskAddRaidGamePlayRecordDoubleValue = function(self, recordid, paramid, addvalue)
	return self.Invoke(self, 67508658, SerializerHelper.AskAddRaidGamePlayRecordDoubleValue_Serializer, recordid, paramid, addvalue)
end

SerializerHelper.AskSetTaskValue_Serializer = function(writer, id, key, value, persistinevent)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	writer.WriteString(writer, key, false, "AskSetTaskValue.key", RpcLengthLimits.IClientToGameScene_AskSetTaskValue_key)
	SerializeBase.WritePrimitive(writer, value, writer.WriteDouble, 0)
	SerializeBase.WritePrimitive(writer, persistinevent, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskSetTaskValue = function(self, id, key, value, persistinevent)
	return self.Invoke(self, 67508882, SerializerHelper.AskSetTaskValue_Serializer, id, key, value, persistinevent)
end

SerializerHelper.AskRecordDrivingBehavior_Serializer = function(writer, records)
	SerializeBase.WriteComplex(writer, records, SerializeAuto.WriteDrivingBehaviorRecords, "records", false)
end

ClientToGameSceneDelegate.AskRecordDrivingBehavior = function(self, records)
	self.Notify(self, 67511504, SerializerHelper.AskRecordDrivingBehavior_Serializer, records)
end

SerializerHelper.AskExtractionShooterShiftBagItemToContainer_Serializer = function(writer, bagconfigid, fromcellx, fromcelly, containerinstanceid, tocellx, tocelly, isrotated)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromcellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromcelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, tocellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tocelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isrotated, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskExtractionShooterShiftBagItemToContainer = function(self, bagconfigid, fromcellx, fromcelly, containerinstanceid, tocellx, tocelly, isrotated)
	return self.Invoke(self, 67512840, SerializerHelper.AskExtractionShooterShiftBagItemToContainer_Serializer, bagconfigid, fromcellx, fromcelly, containerinstanceid, tocellx, tocelly, isrotated)
end

SerializerHelper.ReportClientDetectEventDatas_Serializer = function(writer, datas)
	SerializeBase.WriteList7Bit(writer, datas, SerializeBase.WriteStructWrap(SerializeAuto.WriteClientDetectEventData, "datas"), nil, "datas", false, RpcLengthLimits.IClientToGameScene_ReportClientDetectEventDatas_datas, nil)
end

ClientToGameSceneDelegate.ReportClientDetectEventDatas = function(self, datas)
	self.Notify(self, 67515634, SerializerHelper.ReportClientDetectEventDatas_Serializer, datas)
end

SerializerHelper.ReportUnitFallGroundEnd_Serializer = function(writer, unitid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportUnitFallGroundEnd = function(self, unitid)
	return self.Invoke(self, 67516089, SerializerHelper.ReportUnitFallGroundEnd_Serializer, unitid)
end

SerializerHelper.AskVehicleDestructibleCreate_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteVehicleDestructibleData, "data", false)
end

ClientToGameSceneDelegate.AskVehicleDestructibleCreate = function(self, data)
	return self.Invoke(self, 67517826, SerializerHelper.AskVehicleDestructibleCreate_Serializer, data)
end

SerializerHelper.AskVehicleNavigationPathLength_Serializer = function(writer, targetposition, ignoredirection, ignorealley, usenavmeshconnect, navigationprofile)
	SerializeBase.WriteStruct(writer, targetposition, SerializeAuto.WriteUXVector3, "targetposition")
	SerializeBase.WritePrimitive(writer, ignoredirection, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, ignorealley, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, usenavmeshconnect, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(navigationprofile, 58, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskVehicleNavigationPathLength = function(self, targetposition, ignoredirection, ignorealley, usenavmeshconnect, navigationprofile)
	return self.Invoke(self, 67519267, SerializerHelper.AskVehicleNavigationPathLength_Serializer, targetposition, ignoredirection, ignorealley, usenavmeshconnect, navigationprofile)
end

SerializerHelper.ReportUnitFallEnd_Serializer = function(writer, unitid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportUnitFallEnd = function(self, unitid)
	self.Notify(self, 67519876, SerializerHelper.ReportUnitFallEnd_Serializer, unitid)
end

SerializerHelper.AskBVBSelectChaosBuff_Serializer = function(writer, buffid)
	SerializeBase.WritePrimitive(writer, buffid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskBVBSelectChaosBuff = function(self, buffid)
	return self.Invoke(self, 67525105, SerializerHelper.AskBVBSelectChaosBuff_Serializer, buffid)
end

SerializerHelper.AskSkillCreationCreate_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillCreationData, "data", false)
end

ClientToGameSceneDelegate.AskSkillCreationCreate = function(self, data)
	self.Notify(self, 67525128, SerializerHelper.AskSkillCreationCreate_Serializer, data)
end

SerializerHelper.PlayerLeaveBasketball_Serializer = function(writer)
end

ClientToGameSceneDelegate.PlayerLeaveBasketball = function(self)
	return self.Invoke(self, 67525958, SerializerHelper.PlayerLeaveBasketball_Serializer)
end

SerializerHelper.AskTriggerNightVision_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskTriggerNightVision = function(self)
	self.Notify(self, 67527924, SerializerHelper.AskTriggerNightVision_Serializer)
end

SerializerHelper.ReportDrivingVehicle_Serializer = function(writer, vehicleid, isdriving, deltadistance)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, isdriving, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, deltadistance, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.ReportDrivingVehicle = function(self, vehicleid, isdriving, deltadistance)
	self.Notify(self, 67528706, SerializerHelper.ReportDrivingVehicle_Serializer, vehicleid, isdriving, deltadistance)
end

SerializerHelper.AskFightGameChangeRole_Serializer = function(writer, roleid, isai)
	SerializeBase.WritePrimitive(writer, roleid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isai, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskFightGameChangeRole = function(self, roleid, isai)
	return self.Invoke(self, 67528751, SerializerHelper.AskFightGameChangeRole_Serializer, roleid, isai)
end

SerializerHelper.AskVehicleNitroValue_Serializer = function(writer, vehicleid, value)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, value, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskVehicleNitroValue = function(self, vehicleid, value)
	self.Notify(self, 67533682, SerializerHelper.AskVehicleNitroValue_Serializer, vehicleid, value)
end

SerializerHelper.AskMultiCinemaRemoveTicket_Serializer = function(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskMultiCinemaRemoveTicket = function(self, locationid)
	return self.Invoke(self, 67534475, SerializerHelper.AskMultiCinemaRemoveTicket_Serializer, locationid)
end

SerializerHelper.AskCreateSymbiosisGadget_Serializer = function(writer, id, index, pathid)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, pathid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskCreateSymbiosisGadget = function(self, id, index, pathid)
	return self.Invoke(self, 67536839, SerializerHelper.AskCreateSymbiosisGadget_Serializer, id, index, pathid)
end

SerializerHelper.AskCinemaBuyTicket_Serializer = function(writer, locationid, movieid, cinemanpcid, companionnpcid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, movieid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, cinemanpcid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, companionnpcid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskCinemaBuyTicket = function(self, locationid, movieid, cinemanpcid, companionnpcid)
	return self.Invoke(self, 67539514, SerializerHelper.AskCinemaBuyTicket_Serializer, locationid, movieid, cinemanpcid, companionnpcid)
end

SerializerHelper.AskAetherAISetVehicleStatus_Serializer = function(writer, vehicleinstanceid, status, reason)
	SerializeBase.WritePrimitive(writer, vehicleinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(status, 73, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, reason, writer.WriteInt16, 1)
end

ClientToGameSceneDelegate.AskAetherAISetVehicleStatus = function(self, vehicleinstanceid, status, reason)
	self.Notify(self, 67541089, SerializerHelper.AskAetherAISetVehicleStatus_Serializer, vehicleinstanceid, status, reason)
end

SerializerHelper.AskReportLogicAgentSyncData_Serializer = function(writer, list)
	SerializeBase.WriteList7Bit(writer, list, SerializeBase.WriteStructWrap(SerializeAuto.WriteLogicAgentSyncData, "list"), nil, "list", false, RpcLengthLimits.IClientToGameScene_AskReportLogicAgentSyncData_list, nil)
end

ClientToGameSceneDelegate.AskReportLogicAgentSyncData = function(self, list)
	self.Notify(self, 67543012, SerializerHelper.AskReportLogicAgentSyncData_Serializer, list)
end

SerializerHelper.AskUpdateVehicleDestructibleParts_Serializer = function(writer, info)
	SerializeBase.WriteComplex(writer, info, SerializeAuto.WriteVehicleDestructiblePartsDamageInfo, "info", false)
end

ClientToGameSceneDelegate.AskUpdateVehicleDestructibleParts = function(self, info)
	self.Notify(self, 67543028, SerializerHelper.AskUpdateVehicleDestructibleParts_Serializer, info)
end

SerializerHelper.AskFinishChestnutGame_Serializer = function(writer, gadgetid, fryscore)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, fryscore, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskFinishChestnutGame = function(self, gadgetid, fryscore)
	return self.Invoke(self, 67543164, SerializerHelper.AskFinishChestnutGame_Serializer, gadgetid, fryscore)
end

SerializerHelper.AskSkillExecuteEnd_Serializer = function(writer, targetid, skillinstanceid)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skillinstanceid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskSkillExecuteEnd = function(self, targetid, skillinstanceid)
	return self.Invoke(self, 67546227, SerializerHelper.AskSkillExecuteEnd_Serializer, targetid, skillinstanceid)
end

SerializerHelper.AskSetRaidVehicleGpsInfo_Serializer = function(writer, vehicleentityid, gpsinfo)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
	SerializeBase.WriteComplex(writer, gpsinfo, SerializeAuto.WriteRaidVehicleGpsInfo, "gpsinfo", true)
end

ClientToGameSceneDelegate.AskSetRaidVehicleGpsInfo = function(self, vehicleentityid, gpsinfo)
	self.Notify(self, 67546760, SerializerHelper.AskSetRaidVehicleGpsInfo_Serializer, vehicleentityid, gpsinfo)
end

SerializerHelper.ReportCreationReachMaxRange_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportCreationReachMaxRange = function(self, id)
	self.Notify(self, 67547371, SerializerHelper.ReportCreationReachMaxRange_Serializer, id)
end

SerializerHelper.AskPuppetGetup_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskPuppetGetup = function(self, id)
	return self.Invoke(self, 67548192, SerializerHelper.AskPuppetGetup_Serializer, id)
end

SerializerHelper.AskExitFallingDownToDeath_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskExitFallingDownToDeath = function(self)
	return self.Invoke(self, 67548314, SerializerHelper.AskExitFallingDownToDeath_Serializer)
end

SerializerHelper.AskUseSkill_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillUseData, "data", false)
end

ClientToGameSceneDelegate.AskUseSkill = function(self, data)
	return self.Invoke(self, 67550144, SerializerHelper.AskUseSkill_Serializer, data)
end

SerializerHelper.AskSetMusicPlayNpc_Serializer = function(writer, entityid, isstart)
	SerializeBase.WritePrimitive(writer, entityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, isstart, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskSetMusicPlayNpc = function(self, entityid, isstart)
	return self.Invoke(self, 67551206, SerializerHelper.AskSetMusicPlayNpc_Serializer, entityid, isstart)
end

SerializerHelper.AskAutonomousVehicleLaneDataChange_Serializer = function(writer, currentlanehandle, nextlanehandle)
	SerializeBase.WritePrimitive(writer, currentlanehandle, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, nextlanehandle, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskAutonomousVehicleLaneDataChange = function(self, currentlanehandle, nextlanehandle)
	self.Notify(self, 67554557, SerializerHelper.AskAutonomousVehicleLaneDataChange_Serializer, currentlanehandle, nextlanehandle)
end

SerializerHelper.AskReportSinglePose_Serializer = function(writer, actionid, type)
	SerializeBase.WritePrimitive(writer, actionid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(type, 57, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskReportSinglePose = function(self, actionid, type)
	self.Notify(self, 67554754, SerializerHelper.AskReportSinglePose_Serializer, actionid, type)
end

SerializerHelper.BBQSyncChopstickState_Serializer = function(writer, gadgetuid, state)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WriteComplex(writer, state, SerializeAuto.WriteBBQChopstickState, "state", false)
end

ClientToGameSceneDelegate.BBQSyncChopstickState = function(self, gadgetuid, state)
	self.Notify(self, 67556754, SerializerHelper.BBQSyncChopstickState_Serializer, gadgetuid, state)
end

SerializerHelper.AskInterruptAgentStoryBTree_Serializer = function(writer, agentid, isinterrupt)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, isinterrupt, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskInterruptAgentStoryBTree = function(self, agentid, isinterrupt)
	self.Notify(self, 67557601, SerializerHelper.AskInterruptAgentStoryBTree_Serializer, agentid, isinterrupt)
end

SerializerHelper.TriggerBasketballTiming_Serializer = function(writer, timing)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(timing, 74, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.TriggerBasketballTiming = function(self, timing)
	return self.Invoke(self, 67560493, SerializerHelper.TriggerBasketballTiming_Serializer, timing)
end

SerializerHelper.AskNpcBeKnockedDown_Serializer = function(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskNpcBeKnockedDown = function(self, agententityid)
	self.Notify(self, 67564193, SerializerHelper.AskNpcBeKnockedDown_Serializer, agententityid)
end

SerializerHelper.ReportEnemyDetectEvent_Serializer = function(writer, detecteventid)
	SerializeBase.WritePrimitive(writer, detecteventid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.ReportEnemyDetectEvent = function(self, detecteventid)
	self.Notify(self, 67564406, SerializerHelper.ReportEnemyDetectEvent_Serializer, detecteventid)
end

SerializerHelper.RecordDartId_Serializer = function(writer, dartid)
	SerializeBase.WritePrimitive(writer, dartid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.RecordDartId = function(self, dartid)
	return self.Invoke(self, 67567529, SerializerHelper.RecordDartId_Serializer, dartid)
end

SerializerHelper.AskBVBDebugSelectNpcFightPokemonList_Serializer = function(writer, selectpokemondatas)
	SerializeBase.WriteList7Bit(writer, selectpokemondatas, SerializeBase.WriteComplexWrap(SerializeAuto.WriteDebugNpcBvbSelectPokemonData, "DebugNpcBvbSelectPokemonData", false), nil, "selectpokemondatas", false, RpcLengthLimits.IClientToGameScene_AskBVBDebugSelectNpcFightPokemonList_selectPokemonDatas, nil)
end

ClientToGameSceneDelegate.AskBVBDebugSelectNpcFightPokemonList = function(self, selectpokemondatas)
	return self.Invoke(self, 67567580, SerializerHelper.AskBVBDebugSelectNpcFightPokemonList_Serializer, selectpokemondatas)
end

SerializerHelper.AskPlayerCameraMove_Serializer = function(writer, pos)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
end

ClientToGameSceneDelegate.AskPlayerCameraMove = function(self, pos)
	self.Notify(self, 67568507, SerializerHelper.AskPlayerCameraMove_Serializer, pos)
end

SerializerHelper.ReceivedNpcStim_Serializer = function(writer, templateid, instanceid, stimid)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, stimid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.ReceivedNpcStim = function(self, templateid, instanceid, stimid)
	return self.Invoke(self, 67569687, SerializerHelper.ReceivedNpcStim_Serializer, templateid, instanceid, stimid)
end

SerializerHelper.AskRemoveDestructibleHook_Serializer = function(writer, targetid, instanceid, hookcfgid)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, hookcfgid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskRemoveDestructibleHook = function(self, targetid, instanceid, hookcfgid)
	self.Notify(self, 67571651, SerializerHelper.AskRemoveDestructibleHook_Serializer, targetid, instanceid, hookcfgid)
end

SerializerHelper.AskReportWebpageResource_Serializer = function(writer, resourceid)
	SerializeBase.WritePrimitive(writer, resourceid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskReportWebpageResource = function(self, resourceid)
	self.Notify(self, 67573327, SerializerHelper.AskReportWebpageResource_Serializer, resourceid)
end

SerializerHelper.AskRideAgent_Serializer = function(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskRideAgent = function(self, agentid)
	return self.Invoke(self, 67575069, SerializerHelper.AskRideAgent_Serializer, agentid)
end

SerializerHelper.ActiveNpcStim_Serializer = function(writer, templateid, instanceid, stimid)
	SerializeBase.WritePrimitive(writer, templateid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, stimid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.ActiveNpcStim = function(self, templateid, instanceid, stimid)
	return self.Invoke(self, 67577250, SerializerHelper.ActiveNpcStim_Serializer, templateid, instanceid, stimid)
end

SerializerHelper.AskWeaponFirstObtainTimes_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskWeaponFirstObtainTimes = function(self)
	return self.Invoke(self, 67578770, SerializerHelper.AskWeaponFirstObtainTimes_Serializer)
end

SerializerHelper.AskDrinkMilk_Serializer = function(writer, instanceid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskDrinkMilk = function(self, instanceid)
	return self.Invoke(self, 67579042, SerializerHelper.AskDrinkMilk_Serializer, instanceid)
end

SerializerHelper.AskSetGhostTarget_Serializer = function(writer, position, notifyclient, markid, sectorradius, mipmapcoeff, needcollider, tobemaintarget)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, notifyclient, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(markid, 75, 1), writer.WriteByte, 1)
	SerializeBase.WritePrimitive(writer, sectorradius, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, mipmapcoeff, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, needcollider, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, tobemaintarget, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskSetGhostTarget = function(self, position, notifyclient, markid, sectorradius, mipmapcoeff, needcollider, tobemaintarget)
	self.Notify(self, 67581068, SerializerHelper.AskSetGhostTarget_Serializer, position, notifyclient, markid, sectorradius, mipmapcoeff, needcollider, tobemaintarget)
end

SerializerHelper.AskAgentExitStiff_Serializer = function(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskAgentExitStiff = function(self, agentid)
	self.Notify(self, 67581079, SerializerHelper.AskAgentExitStiff_Serializer, agentid)
end

SerializerHelper.ReportAgentPlatformValidateInfo_Serializer = function(writer, agentid, mobileplatformid, pos, forward)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, mobileplatformid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
	SerializeBase.WriteStruct(writer, forward, SerializeAuto.WriteUXVector3, "forward")
end

ClientToGameSceneDelegate.ReportAgentPlatformValidateInfo = function(self, agentid, mobileplatformid, pos, forward)
	self.Notify(self, 67585923, SerializerHelper.ReportAgentPlatformValidateInfo_Serializer, agentid, mobileplatformid, pos, forward)
end

SerializerHelper.AskFightGameGetPlayers_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskFightGameGetPlayers = function(self)
	return self.Invoke(self, 67587184, SerializerHelper.AskFightGameGetPlayers_Serializer)
end

SerializerHelper.ReportEnemyReturnCoAttackEdict_Serializer = function(writer, uid)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportEnemyReturnCoAttackEdict = function(self, uid)
	self.Notify(self, 67587301, SerializerHelper.ReportEnemyReturnCoAttackEdict_Serializer, uid)
end

SerializerHelper.ActiveTaskCounter_Serializer = function(writer, taskid, counterindex, isonfoot)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, counterindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, isonfoot, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.ActiveTaskCounter = function(self, taskid, counterindex, isonfoot)
	return self.Invoke(self, 67589684, SerializerHelper.ActiveTaskCounter_Serializer, taskid, counterindex, isonfoot)
end

SerializerHelper.AskVehicleContactDamage_Serializer = function(writer, vehicleid, data)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, data, SerializeAuto.WriteVehicleContactDamageData, "data")
end

ClientToGameSceneDelegate.AskVehicleContactDamage = function(self, vehicleid, data)
	self.Notify(self, 67589692, SerializerHelper.AskVehicleContactDamage_Serializer, vehicleid, data)
end

SerializerHelper.AskChineseChessFlipMovePiece_Serializer = function(writer, gadgetuid, srccol, srcrow, tgtcol, tgtrow)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, srccol, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, srcrow, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tgtcol, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, tgtrow, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskChineseChessFlipMovePiece = function(self, gadgetuid, srccol, srcrow, tgtcol, tgtrow)
	return self.Invoke(self, 67590059, SerializerHelper.AskChineseChessFlipMovePiece_Serializer, gadgetuid, srccol, srcrow, tgtcol, tgtrow)
end

SerializerHelper.AskReleaseClientEvent_Serializer = function(writer, name)
	writer.WriteString(writer, name, false, "AskReleaseClientEvent.name", RpcLengthLimits.IClientToGameScene_AskReleaseClientEvent_name)
end

ClientToGameSceneDelegate.AskReleaseClientEvent = function(self, name)
	return self.Invoke(self, 67591672, SerializerHelper.AskReleaseClientEvent_Serializer, name)
end

SerializerHelper.AskAgentChangeIndoor_Serializer = function(writer, npcinstanceid, indoorid, enter)
	SerializeBase.WritePrimitive(writer, npcinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, indoorid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enter, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskAgentChangeIndoor = function(self, npcinstanceid, indoorid, enter)
	self.Notify(self, 67593336, SerializerHelper.AskAgentChangeIndoor_Serializer, npcinstanceid, indoorid, enter)
end

SerializerHelper.AskRemoveSubAgent_Serializer = function(writer, unitid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskRemoveSubAgent = function(self, unitid)
	self.Notify(self, 67593429, SerializerHelper.AskRemoveSubAgent_Serializer, unitid)
end

SerializerHelper.AskAgentBowlingRelease_Serializer = function(writer, gadgetuid, npcid, throwindex)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, npcid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, throwindex, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskAgentBowlingRelease = function(self, gadgetuid, npcid, throwindex)
	return self.Invoke(self, 67595427, SerializerHelper.AskAgentBowlingRelease_Serializer, gadgetuid, npcid, throwindex)
end

SerializerHelper.AskLeaveFeiSuoCrouch_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskLeaveFeiSuoCrouch = function(self)
	self.Notify(self, 67596424, SerializerHelper.AskLeaveFeiSuoCrouch_Serializer)
end

SerializerHelper.AskExtractionShooterRaidSplitItem_Serializer = function(writer, bagconfigid, containerinstanceid, splitcellx, splitcelly, splitcount, isrotated)
	SerializeBase.WritePrimitive(writer, bagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, splitcellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, splitcelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, splitcount, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isrotated, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskExtractionShooterRaidSplitItem = function(self, bagconfigid, containerinstanceid, splitcellx, splitcelly, splitcount, isrotated)
	return self.Invoke(self, 67597775, SerializerHelper.AskExtractionShooterRaidSplitItem_Serializer, bagconfigid, containerinstanceid, splitcellx, splitcelly, splitcount, isrotated)
end

SerializerHelper.AskDoWireSwingAction_Serializer = function(writer, actionid)
	SerializeBase.WritePrimitive(writer, actionid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskDoWireSwingAction = function(self, actionid)
	return self.Invoke(self, 67598207, SerializerHelper.AskDoWireSwingAction_Serializer, actionid)
end

SerializerHelper.AskVehicleStartAutonomousDriving_Serializer = function(writer, hasvalidtargetposition, targetposition)
	SerializeBase.WritePrimitive(writer, hasvalidtargetposition, writer.WriteBoolean, false)
	SerializeBase.WriteStruct(writer, targetposition, SerializeAuto.WriteUXVector3, "targetposition")
end

ClientToGameSceneDelegate.AskVehicleStartAutonomousDriving = function(self, hasvalidtargetposition, targetposition)
	return self.Invoke(self, 67600663, SerializerHelper.AskVehicleStartAutonomousDriving_Serializer, hasvalidtargetposition, targetposition)
end

SerializerHelper.AskPipeGameEnd_Serializer = function(writer, pipegamegraphid)
	SerializeBase.WritePrimitive(writer, pipegamegraphid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskPipeGameEnd = function(self, pipegamegraphid)
	self.Notify(self, 67604590, SerializerHelper.AskPipeGameEnd_Serializer, pipegamegraphid)
end

SerializerHelper.AskEnemyFallGround_Serializer = function(writer, pid, speed)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, speed, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskEnemyFallGround = function(self, pid, speed)
	self.Notify(self, 67605841, SerializerHelper.AskEnemyFallGround_Serializer, pid, speed)
end

SerializerHelper.AskEquipParagliderWheel_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskEquipParagliderWheel = function(self)
	self.Notify(self, 67607385, SerializerHelper.AskEquipParagliderWheel_Serializer)
end

SerializerHelper.AskChangeCanMoveToDriveSeat_Serializer = function(writer, vehicleid, canmovetodriveseat)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, canmovetodriveseat, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskChangeCanMoveToDriveSeat = function(self, vehicleid, canmovetodriveseat)
	self.Notify(self, 67607811, SerializerHelper.AskChangeCanMoveToDriveSeat_Serializer, vehicleid, canmovetodriveseat)
end

SerializerHelper.AskTombTeleportIsland_Serializer = function(writer, currentislandid, slotid)
	SerializeBase.WritePrimitive(writer, currentislandid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, slotid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskTombTeleportIsland = function(self, currentislandid, slotid)
	return self.Invoke(self, 67609525, SerializerHelper.AskTombTeleportIsland_Serializer, currentislandid, slotid)
end

SerializerHelper.AskAttachSceneItem_Serializer = function(writer, targetunitid, slotid, sceneiteminstanceid)
	SerializeBase.WritePrimitive(writer, targetunitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, slotid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, sceneiteminstanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskAttachSceneItem = function(self, targetunitid, slotid, sceneiteminstanceid)
	return self.Invoke(self, 67612600, SerializerHelper.AskAttachSceneItem_Serializer, targetunitid, slotid, sceneiteminstanceid)
end

SerializerHelper.EnterGomokuZoneDoubleAI_Serializer = function(writer, gadgetuid, agentid, useblackpiece, difficulty, canuseskill)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, useblackpiece, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(difficulty, 76, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, canuseskill, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.EnterGomokuZoneDoubleAI = function(self, gadgetuid, agentid, useblackpiece, difficulty, canuseskill)
	return self.Invoke(self, 67614971, SerializerHelper.EnterGomokuZoneDoubleAI_Serializer, gadgetuid, agentid, useblackpiece, difficulty, canuseskill)
end

SerializerHelper.AskChineseChessEnterZoneEndGame_Serializer = function(writer, gadgetuid, agentid, endgameid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, endgameid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskChineseChessEnterZoneEndGame = function(self, gadgetuid, agentid, endgameid)
	return self.Invoke(self, 67616104, SerializerHelper.AskChineseChessEnterZoneEndGame_Serializer, gadgetuid, agentid, endgameid)
end

SerializerHelper.AskTeleportToParkingWaypoint_Serializer = function(writer, carshopid)
	SerializeBase.WritePrimitive(writer, carshopid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskTeleportToParkingWaypoint = function(self, carshopid)
	return self.Invoke(self, 67618512, SerializerHelper.AskTeleportToParkingWaypoint_Serializer, carshopid)
end

SerializerHelper.ReportSpecialTargetPosition_Serializer = function(writer, enemyid, position)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
end

ClientToGameSceneDelegate.ReportSpecialTargetPosition = function(self, enemyid, position)
	self.Notify(self, 67628911, SerializerHelper.ReportSpecialTargetPosition_Serializer, enemyid, position)
end

SerializerHelper.AskChineseChessReplyUndo_Serializer = function(writer, gadgetuid, agree)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, agree, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskChineseChessReplyUndo = function(self, gadgetuid, agree)
	return self.Invoke(self, 67629805, SerializerHelper.AskChineseChessReplyUndo_Serializer, gadgetuid, agree)
end

SerializerHelper.AskReportLogicAgentConditionResult_Serializer = function(writer, agentid, conditionid, success)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, conditionid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, success, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskReportLogicAgentConditionResult = function(self, agentid, conditionid, success)
	self.Notify(self, 67630170, SerializerHelper.AskReportLogicAgentConditionResult_Serializer, agentid, conditionid, success)
end

SerializerHelper.AskYachtMove_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteYachtMoveData, "data", false)
end

ClientToGameSceneDelegate.AskYachtMove = function(self, data)
	self.Notify(self, 67633384, SerializerHelper.AskYachtMove_Serializer, data)
end

SerializerHelper.RefreshCleaningProgress_Serializer = function(writer, cleaningprogress)
	SerializeBase.WritePrimitive(writer, cleaningprogress, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.RefreshCleaningProgress = function(self, cleaningprogress)
	return self.Invoke(self, 67635234, SerializerHelper.RefreshCleaningProgress_Serializer, cleaningprogress)
end

SerializerHelper.ReportBehaviorSeqCommandEndList_Serializer = function(writer, infos)
	SerializeBase.WriteList7Bit(writer, infos, SerializeBase.WriteStructWrap(SerializeAuto.WriteReportBehaviorSeqCommandEndInfo, "infos"), nil, "infos", false, RpcLengthLimits.IClientToGameScene_ReportBehaviorSeqCommandEndList_infos, nil)
end

ClientToGameSceneDelegate.ReportBehaviorSeqCommandEndList = function(self, infos)
	self.Notify(self, 67637298, SerializerHelper.ReportBehaviorSeqCommandEndList_Serializer, infos)
end

SerializerHelper.ReportAgentDiePerfEnd_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportAgentDiePerfEnd = function(self, id)
	return self.Invoke(self, 67638502, SerializerHelper.ReportAgentDiePerfEnd_Serializer, id)
end

SerializerHelper.AskChaosNpcBeAttacked_Serializer = function(writer, instanceid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskChaosNpcBeAttacked = function(self, instanceid)
	self.Notify(self, 67638664, SerializerHelper.AskChaosNpcBeAttacked_Serializer, instanceid)
end

SerializerHelper.AskResetVehicleToNearestLane_Serializer = function(writer, currentpos, targetpos, targetfacing)
	SerializeBase.WriteStruct(writer, currentpos, SerializeAuto.WriteUXVector3, "currentpos")
	SerializeBase.WriteStruct(writer, targetpos, SerializeAuto.WriteUXVector3, "targetpos")
	SerializeBase.WritePrimitive(writer, targetfacing, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskResetVehicleToNearestLane = function(self, currentpos, targetpos, targetfacing)
	return self.Invoke(self, 67641149, SerializerHelper.AskResetVehicleToNearestLane_Serializer, currentpos, targetpos, targetfacing)
end

SerializerHelper.AskMultipleSkillHitByAgent_Serializer = function(writer, skillhitdata)
	SerializeBase.WriteComplex(writer, skillhitdata, SerializeAuto.WriteSkillHitData, "skillhitdata", false)
end

ClientToGameSceneDelegate.AskMultipleSkillHitByAgent = function(self, skillhitdata)
	self.Notify(self, 67641178, SerializerHelper.AskMultipleSkillHitByAgent_Serializer, skillhitdata)
end

SerializerHelper.AskReviveAndReAcceptTask_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskReviveAndReAcceptTask = function(self, taskid)
	return self.Invoke(self, 67642195, SerializerHelper.AskReviveAndReAcceptTask_Serializer, taskid)
end

SerializerHelper.AskStartInteractChefStove_Serializer = function(writer, stoveid, cookid)
	SerializeBase.WritePrimitive(writer, stoveid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, cookid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskStartInteractChefStove = function(self, stoveid, cookid)
	return self.Invoke(self, 67642769, SerializerHelper.AskStartInteractChefStove_Serializer, stoveid, cookid)
end

SerializerHelper.AskEnterShootModeOnCannon_Serializer = function(writer, cannontemplateid)
	SerializeBase.WritePrimitive(writer, cannontemplateid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskEnterShootModeOnCannon = function(self, cannontemplateid)
	return self.Invoke(self, 67642921, SerializerHelper.AskEnterShootModeOnCannon_Serializer, cannontemplateid)
end

SerializerHelper.ReportJumpOutOnVehicleBroken_Serializer = function(writer, agentid)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportJumpOutOnVehicleBroken = function(self, agentid)
	self.Notify(self, 67643077, SerializerHelper.ReportJumpOutOnVehicleBroken_Serializer, agentid)
end

SerializerHelper.AskEndTaxiTeleport_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskEndTaxiTeleport = function(self)
	return self.Invoke(self, 67643399, SerializerHelper.AskEndTaxiTeleport_Serializer)
end

SerializerHelper.AskStartClimb_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskStartClimb = function(self)
	self.Notify(self, 67646893, SerializerHelper.AskStartClimb_Serializer)
end

SerializerHelper.AskThrowWeaponInHand_Serializer = function(writer, position, face)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, face, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskThrowWeaponInHand = function(self, position, face)
	return self.Invoke(self, 67647545, SerializerHelper.AskThrowWeaponInHand_Serializer, position, face)
end

SerializerHelper.AskEndClimb_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskEndClimb = function(self)
	self.Notify(self, 67647726, SerializerHelper.AskEndClimb_Serializer)
end

SerializerHelper.AskGravitySuspend_Serializer = function(writer, pid, stiffid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, stiffid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskGravitySuspend = function(self, pid, stiffid)
	self.Notify(self, 67648468, SerializerHelper.AskGravitySuspend_Serializer, pid, stiffid)
end

SerializerHelper.RecordRingTossResult_Serializer = function(writer, gadgetuid, throwresult)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, throwresult, SerializeAuto.WriteRingTossThrowResult, "throwresult")
end

ClientToGameSceneDelegate.RecordRingTossResult = function(self, gadgetuid, throwresult)
	return self.Invoke(self, 67649660, SerializerHelper.RecordRingTossResult_Serializer, gadgetuid, throwresult)
end

SerializerHelper.AskVehicleNavigationPathPointsFromPos_Serializer = function(writer, navreqid, startposition, targetposition, ignoredirection, ignorealley, needcenterpoints, usenavmeshconnect, navigationprofile, eulery)
	SerializeBase.WritePrimitive(writer, navreqid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, startposition, SerializeAuto.WriteUXVector3, "startposition")
	SerializeBase.WriteStruct(writer, targetposition, SerializeAuto.WriteUXVector3, "targetposition")
	SerializeBase.WritePrimitive(writer, ignoredirection, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, ignorealley, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, needcenterpoints, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, usenavmeshconnect, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(navigationprofile, 58, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, eulery, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskVehicleNavigationPathPointsFromPos = function(self, navreqid, startposition, targetposition, ignoredirection, ignorealley, needcenterpoints, usenavmeshconnect, navigationprofile, eulery)
	return self.Invoke(self, 67650626, SerializerHelper.AskVehicleNavigationPathPointsFromPos_Serializer, navreqid, startposition, targetposition, ignoredirection, ignorealley, needcenterpoints, usenavmeshconnect, navigationprofile, eulery)
end

SerializerHelper.ReportHackerTetrisCreation_Serializer = function(writer)
end

ClientToGameSceneDelegate.ReportHackerTetrisCreation = function(self)
	self.Notify(self, 67652382, SerializerHelper.ReportHackerTetrisCreation_Serializer)
end

SerializerHelper.ReportPreSwitchSpiritFinish_Serializer = function(writer)
end

ClientToGameSceneDelegate.ReportPreSwitchSpiritFinish = function(self)
	return self.Invoke(self, 67654364, SerializerHelper.ReportPreSwitchSpiritFinish_Serializer)
end

SerializerHelper.AskRemoveTimelineDangerArea_Serializer = function(writer, center, extends, rotation)
	SerializeBase.WriteStruct(writer, center, SerializeAuto.WriteUXVector3, "center")
	SerializeBase.WriteStruct(writer, extends, SerializeAuto.WriteUXVector3, "extends")
	SerializeBase.WriteStruct(writer, rotation, SerializeAuto.WriteUXVector3, "rotation")
end

ClientToGameSceneDelegate.AskRemoveTimelineDangerArea = function(self, center, extends, rotation)
	self.Notify(self, 67657468, SerializerHelper.AskRemoveTimelineDangerArea_Serializer, center, extends, rotation)
end

SerializerHelper.AskPlateLoadComplete_Serializer = function(writer, uid)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskPlateLoadComplete = function(self, uid)
	return self.Invoke(self, 67658390, SerializerHelper.AskPlateLoadComplete_Serializer, uid)
end

SerializerHelper.AskFreeEmotionByStateTree_Serializer = function(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskFreeEmotionByStateTree = function(self, agententityid)
	self.Notify(self, 67660531, SerializerHelper.AskFreeEmotionByStateTree_Serializer, agententityid)
end

SerializerHelper.ReportEnemyBattleMoveEnd_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportEnemyBattleMoveEnd = function(self, pid)
	self.Notify(self, 67663940, SerializerHelper.ReportEnemyBattleMoveEnd_Serializer, pid)
end

SerializerHelper.AskBVBRefreshChaosBuffCandidates_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskBVBRefreshChaosBuffCandidates = function(self)
	return self.Invoke(self, 67664352, SerializerHelper.AskBVBRefreshChaosBuffCandidates_Serializer)
end

SerializerHelper.Ping_Serializer = function(writer, time)
	SerializeBase.WritePrimitive(writer, time, writer.WriteDouble, 0)
end

ClientToGameSceneDelegate.Ping = function(self, time)
	self.Notify(self, 67665225, SerializerHelper.Ping_Serializer, time)
end

SerializerHelper.AskAgentBackSuccess_Serializer = function(writer, npcinstanceid)
	SerializeBase.WritePrimitive(writer, npcinstanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskAgentBackSuccess = function(self, npcinstanceid)
	return self.Invoke(self, 67665590, SerializerHelper.AskAgentBackSuccess_Serializer, npcinstanceid)
end

SerializerHelper.AskAgentCompanionAIReactionEvent_Serializer = function(writer, unitid, reactionid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, reactionid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskAgentCompanionAIReactionEvent = function(self, unitid, reactionid)
	self.Notify(self, 67666462, SerializerHelper.AskAgentCompanionAIReactionEvent_Serializer, unitid, reactionid)
end

SerializerHelper.AskChaosNpcDestoryed_Serializer = function(writer, instanceid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskChaosNpcDestoryed = function(self, instanceid)
	self.Notify(self, 67666954, SerializerHelper.AskChaosNpcDestoryed_Serializer, instanceid)
end

SerializerHelper.AskChineseChessLeaveZone_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskChineseChessLeaveZone = function(self, gadgetuid)
	return self.Invoke(self, 67667163, SerializerHelper.AskChineseChessLeaveZone_Serializer, gadgetuid)
end

SerializerHelper.AskRefreshGlueProgress_Serializer = function(writer, glueprogress)
	SerializeBase.WritePrimitive(writer, glueprogress, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskRefreshGlueProgress = function(self, glueprogress)
	return self.Invoke(self, 67670415, SerializerHelper.AskRefreshGlueProgress_Serializer, glueprogress)
end

SerializerHelper.AskPoliceDistanceMonitorTrigger_Serializer = function(writer, distance)
	SerializeBase.WritePrimitive(writer, distance, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskPoliceDistanceMonitorTrigger = function(self, distance)
	self.Notify(self, 67670906, SerializerHelper.AskPoliceDistanceMonitorTrigger_Serializer, distance)
end

SerializerHelper.AskTriggerClientDetonatorAction_Serializer = function(writer, unitid, targetactionid, clientdetonatorconfigid, buffconfigid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetactionid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, clientdetonatorconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, buffconfigid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskTriggerClientDetonatorAction = function(self, unitid, targetactionid, clientdetonatorconfigid, buffconfigid)
	self.Notify(self, 67671531, SerializerHelper.AskTriggerClientDetonatorAction_Serializer, unitid, targetactionid, clientdetonatorconfigid, buffconfigid)
end

SerializerHelper.AskPlayerEnterWater_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskPlayerEnterWater = function(self)
	return self.Invoke(self, 67675748, SerializerHelper.AskPlayerEnterWater_Serializer)
end

SerializerHelper.AskPreprocessVehicleSpawnArea_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskPreprocessVehicleSpawnArea = function(self)
	self.Notify(self, 67676546, SerializerHelper.AskPreprocessVehicleSpawnArea_Serializer)
end

SerializerHelper.AskExitShootModeOnCannon_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskExitShootModeOnCannon = function(self)
	return self.Invoke(self, 67677333, SerializerHelper.AskExitShootModeOnCannon_Serializer)
end

SerializerHelper.BBQPickupMeatFromPlate_Serializer = function(writer, gadgetuid, meattype)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, meattype, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.BBQPickupMeatFromPlate = function(self, gadgetuid, meattype)
	return self.Invoke(self, 67677362, SerializerHelper.BBQPickupMeatFromPlate_Serializer, gadgetuid, meattype)
end

SerializerHelper.AskCinemaLeave_Serializer = function(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskCinemaLeave = function(self, locationid)
	return self.Invoke(self, 67678435, SerializerHelper.AskCinemaLeave_Serializer, locationid)
end

SerializerHelper.AskTwitterBehaviorFinish_Serializer = function(writer, behavior, id)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(behavior, 77, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskTwitterBehaviorFinish = function(self, behavior, id)
	return self.Invoke(self, 67680128, SerializerHelper.AskTwitterBehaviorFinish_Serializer, behavior, id)
end

SerializerHelper.ReportBasketballFinisher_Serializer = function(writer)
end

ClientToGameSceneDelegate.ReportBasketballFinisher = function(self)
	return self.Invoke(self, 67680357, SerializerHelper.ReportBasketballFinisher_Serializer)
end

SerializerHelper.AskExtractionShooterShiftContainerItemToSlot_Serializer = function(writer, containerinstanceid, fromcellx, fromcelly, slotgroupbagconfigid, toslotindex)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, fromcellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, fromcelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, slotgroupbagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, toslotindex, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskExtractionShooterShiftContainerItemToSlot = function(self, containerinstanceid, fromcellx, fromcelly, slotgroupbagconfigid, toslotindex)
	return self.Invoke(self, 67688819, SerializerHelper.AskExtractionShooterShiftContainerItemToSlot_Serializer, containerinstanceid, fromcellx, fromcelly, slotgroupbagconfigid, toslotindex)
end

SerializerHelper.AskEnemyExistSceneRoom_Serializer = function(writer, sceneroomid, enemyid)
	SerializeBase.WritePrimitive(writer, sceneroomid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskEnemyExistSceneRoom = function(self, sceneroomid, enemyid)
	return self.Invoke(self, 67690892, SerializerHelper.AskEnemyExistSceneRoom_Serializer, sceneroomid, enemyid)
end

SerializerHelper.AskTwitterPageOpen_Serializer = function(writer, pagetype, key, value)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(pagetype, 78, 1), writer.WriteByte, 1)
	writer.WriteString(writer, key, false, "AskTwitterPageOpen.key", RpcLengthLimits.IClientToGameScene_AskTwitterPageOpen_key)
	SerializeBase.WritePrimitive(writer, value, writer.WriteDouble, 0)
end

ClientToGameSceneDelegate.AskTwitterPageOpen = function(self, pagetype, key, value)
	self.Notify(self, 67691213, SerializerHelper.AskTwitterPageOpen_Serializer, pagetype, key, value)
end

SerializerHelper.AskAetherAICreateRaidVehicleAndClaimSeatByAether_Serializer = function(writer, vehicleinstanceid, seatindices)
	SerializeBase.WritePrimitive(writer, vehicleinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WriteList7Bit(writer, seatindices, writer.WriteByte, 0, "seatindices", false, RpcLengthLimits.IClientToGameScene_AskAetherAICreateRaidVehicleAndClaimSeatByAether_seatIndices, nil)
end

ClientToGameSceneDelegate.AskAetherAICreateRaidVehicleAndClaimSeatByAether = function(self, vehicleinstanceid, seatindices)
	return self.Invoke(self, 67691241, SerializerHelper.AskAetherAICreateRaidVehicleAndClaimSeatByAether_Serializer, vehicleinstanceid, seatindices)
end

SerializerHelper.AskAgentPatrolFinish_Serializer = function(writer, npcinstanceid, groupindex, success)
	SerializeBase.WritePrimitive(writer, npcinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, groupindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, success, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskAgentPatrolFinish = function(self, npcinstanceid, groupindex, success)
	return self.Invoke(self, 67691372, SerializerHelper.AskAgentPatrolFinish_Serializer, npcinstanceid, groupindex, success)
end

SerializerHelper.GetBasketballPlayerBallId_Serializer = function(writer)
end

ClientToGameSceneDelegate.GetBasketballPlayerBallId = function(self)
	return self.Invoke(self, 67694389, SerializerHelper.GetBasketballPlayerBallId_Serializer)
end

SerializerHelper.AskSyncInteractChefStove_Serializer = function(writer, stoveid, level)
	SerializeBase.WritePrimitive(writer, stoveid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(level, 68, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskSyncInteractChefStove = function(self, stoveid, level)
	return self.Invoke(self, 67697602, SerializerHelper.AskSyncInteractChefStove_Serializer, stoveid, level)
end

SerializerHelper.ReportBasketballNeedExitThreePoint_Serializer = function(writer, needexit)
	SerializeBase.WritePrimitive(writer, needexit, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.ReportBasketballNeedExitThreePoint = function(self, needexit)
	return self.Invoke(self, 67697724, SerializerHelper.ReportBasketballNeedExitThreePoint_Serializer, needexit)
end

SerializerHelper.AskTaffyMotoEnterRush_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskTaffyMotoEnterRush = function(self)
	self.Notify(self, 67698281, SerializerHelper.AskTaffyMotoEnterRush_Serializer)
end

SerializerHelper.AskDestroyDynamicGadget_Serializer = function(writer, uid)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskDestroyDynamicGadget = function(self, uid)
	return self.Invoke(self, 67698654, SerializerHelper.AskDestroyDynamicGadget_Serializer, uid)
end

SerializerHelper.AskCheckWildEnemyGroup_Serializer = function(writer, groupid)
	SerializeBase.WritePrimitive(writer, groupid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskCheckWildEnemyGroup = function(self, groupid)
	self.Notify(self, 67698974, SerializerHelper.AskCheckWildEnemyGroup_Serializer, groupid)
end

SerializerHelper.AskSocketWeaponDecoration_Serializer = function(writer, weaponinstanceid, slotindex, decorationid)
	SerializeBase.WritePrimitive(writer, weaponinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, slotindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, decorationid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskSocketWeaponDecoration = function(self, weaponinstanceid, slotindex, decorationid)
	return self.Invoke(self, 67699819, SerializerHelper.AskSocketWeaponDecoration_Serializer, weaponinstanceid, slotindex, decorationid)
end

SerializerHelper.ReportBehaviorSeqFinish_Serializer = function(writer, enemyid, type)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(type, 79, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.ReportBehaviorSeqFinish = function(self, enemyid, type)
	self.Notify(self, 67700663, SerializerHelper.ReportBehaviorSeqFinish_Serializer, enemyid, type)
end

SerializerHelper.AskClearGhostTarget_Serializer = function(writer, markid)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(markid, 75, 1), writer.WriteByte, 1)
end

ClientToGameSceneDelegate.AskClearGhostTarget = function(self, markid)
	self.Notify(self, 67701076, SerializerHelper.AskClearGhostTarget_Serializer, markid)
end

SerializerHelper.AskExtractionShooterEndSearchContainer_Serializer = function(writer, containerinstanceid)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskExtractionShooterEndSearchContainer = function(self, containerinstanceid)
	return self.Invoke(self, 67701506, SerializerHelper.AskExtractionShooterEndSearchContainer_Serializer, containerinstanceid)
end

SerializerHelper.AskSceneDeviceRecordValue_Serializer = function(writer, type, valuechangeinfo)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WriteStruct(writer, valuechangeinfo, SerializeAuto.WriteSceneDeviceValueChangeInfo, "valuechangeinfo")
end

ClientToGameSceneDelegate.AskSceneDeviceRecordValue = function(self, type, valuechangeinfo)
	return self.Invoke(self, 67703474, SerializerHelper.AskSceneDeviceRecordValue_Serializer, type, valuechangeinfo)
end

SerializerHelper.AskMindInteractEnemy_Serializer = function(writer, enemyid, interactid, createdestructibledata)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, interactid, writer.WriteUInt32, 0)
	SerializeBase.WriteComplex(writer, createdestructibledata, SerializeAuto.WriteSkillDestructibleData, "createdestructibledata", true)
end

ClientToGameSceneDelegate.AskMindInteractEnemy = function(self, enemyid, interactid, createdestructibledata)
	return self.Invoke(self, 67704086, SerializerHelper.AskMindInteractEnemy_Serializer, enemyid, interactid, createdestructibledata)
end

SerializerHelper.RecordSceneDeviceBehavior_Serializer = function(writer, type, id, label, behavior, extrainfo)
	SerializeBase.WritePrimitive(writer, type, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	writer.WriteString(writer, label, false, "RecordSceneDeviceBehavior.label", RpcLengthLimits.IClientToGameScene_RecordSceneDeviceBehavior_label)
	writer.WriteString(writer, behavior, false, "RecordSceneDeviceBehavior.behavior", RpcLengthLimits.IClientToGameScene_RecordSceneDeviceBehavior_behavior)
	writer.WriteString(writer, extrainfo, false, "RecordSceneDeviceBehavior.extraInfo", RpcLengthLimits.IClientToGameScene_RecordSceneDeviceBehavior_extraInfo)
end

ClientToGameSceneDelegate.RecordSceneDeviceBehavior = function(self, type, id, label, behavior, extrainfo)
	return self.Invoke(self, 67705881, SerializerHelper.RecordSceneDeviceBehavior_Serializer, type, id, label, behavior, extrainfo)
end

SerializerHelper.AskCheckSpoonConditionByType_Serializer = function(writer, param)
	SerializeBase.WriteComplex(writer, param, SerializeAuto.WriteSpoonServerActionParam, "param", false)
end

ClientToGameSceneDelegate.AskCheckSpoonConditionByType = function(self, param)
	return self.Invoke(self, 67709054, SerializerHelper.AskCheckSpoonConditionByType_Serializer, param)
end

SerializerHelper.AskReportSlipstream_Serializer = function(writer, vehicleentityid, beginorend)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, beginorend, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskReportSlipstream = function(self, vehicleentityid, beginorend)
	self.Notify(self, 67711002, SerializerHelper.AskReportSlipstream_Serializer, vehicleentityid, beginorend)
end

SerializerHelper.AskAddChefSeasoning_Serializer = function(writer, stoveid, seasoningid, issuccess)
	SerializeBase.WritePrimitive(writer, stoveid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, seasoningid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, issuccess, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskAddChefSeasoning = function(self, stoveid, seasoningid, issuccess)
	return self.Invoke(self, 67711409, SerializerHelper.AskAddChefSeasoning_Serializer, stoveid, seasoningid, issuccess)
end

SerializerHelper.AskBreakAction_Serializer = function(writer, skillinstanceid)
	SerializeBase.WritePrimitive(writer, skillinstanceid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskBreakAction = function(self, skillinstanceid)
	self.Notify(self, 67714446, SerializerHelper.AskBreakAction_Serializer, skillinstanceid)
end

SerializerHelper.AskEnterSceneRoom_Serializer = function(writer, sceneroomid, isvehicle, moveid)
	SerializeBase.WritePrimitive(writer, sceneroomid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, isvehicle, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, moveid, writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskEnterSceneRoom = function(self, sceneroomid, isvehicle, moveid)
	return self.Invoke(self, 67714973, SerializerHelper.AskEnterSceneRoom_Serializer, sceneroomid, isvehicle, moveid)
end

SerializerHelper.EndWorldLifeGame_Serializer = function(writer, worldlifeinstanceid)
	SerializeBase.WritePrimitive(writer, worldlifeinstanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.EndWorldLifeGame = function(self, worldlifeinstanceid)
	return self.Invoke(self, 67715566, SerializerHelper.EndWorldLifeGame_Serializer, worldlifeinstanceid)
end

SerializerHelper.AskVehicleLeaveStuck_Serializer = function(writer, vehicleid)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskVehicleLeaveStuck = function(self, vehicleid)
	return self.Invoke(self, 67716151, SerializerHelper.AskVehicleLeaveStuck_Serializer, vehicleid)
end

SerializerHelper.ReportUnitFallGround_Serializer = function(writer, unitid, moveid, stiffid, stifftime, speed)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, moveid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, stiffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, stifftime, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, speed, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.ReportUnitFallGround = function(self, unitid, moveid, stiffid, stifftime, speed)
	return self.Invoke(self, 67719880, SerializerHelper.ReportUnitFallGround_Serializer, unitid, moveid, stiffid, stifftime, speed)
end

SerializerHelper.AskVehicleLeaveArea_Serializer = function(writer, identifyareaid, vehicleid)
	SerializeBase.WritePrimitive(writer, identifyareaid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskVehicleLeaveArea = function(self, identifyareaid, vehicleid)
	return self.Invoke(self, 67719905, SerializerHelper.AskVehicleLeaveArea_Serializer, identifyareaid, vehicleid)
end

SerializerHelper.AskVehicleSendSignal_Serializer = function(writer, id, signalname)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	writer.WriteString(writer, signalname, false, "AskVehicleSendSignal.signalName", RpcLengthLimits.IClientToGameScene_AskVehicleSendSignal_signalName)
end

ClientToGameSceneDelegate.AskVehicleSendSignal = function(self, id, signalname)
	return self.Invoke(self, 67722597, SerializerHelper.AskVehicleSendSignal_Serializer, id, signalname)
end

SerializerHelper.AskLoadingFinished_Serializer = function(writer, sceneid, sessionid)
	SerializeBase.WritePrimitive(writer, sceneid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, sessionid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskLoadingFinished = function(self, sceneid, sessionid)
	return self.Invoke(self, 67722670, SerializerHelper.AskLoadingFinished_Serializer, sceneid, sessionid)
end

SerializerHelper.AskFinishChefManagementRound_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskFinishChefManagementRound = function(self)
	return self.Invoke(self, 67723032, SerializerHelper.AskFinishChefManagementRound_Serializer)
end

SerializerHelper.ReportSelectTempWeapon_Serializer = function(writer, index)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.ReportSelectTempWeapon = function(self, index)
	self.Notify(self, 67724377, SerializerHelper.ReportSelectTempWeapon_Serializer, index)
end

SerializerHelper.SetBasketballPlayerRoundReady_Serializer = function(writer)
end

ClientToGameSceneDelegate.SetBasketballPlayerRoundReady = function(self)
	return self.Invoke(self, 67725138, SerializerHelper.SetBasketballPlayerRoundReady_Serializer)
end

SerializerHelper.AskGetVehicleRadioContent_Serializer = function(writer, radioid, songidx)
	SerializeBase.WritePrimitive(writer, radioid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, songidx, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskGetVehicleRadioContent = function(self, radioid, songidx)
	return self.Invoke(self, 67725622, SerializerHelper.AskGetVehicleRadioContent_Serializer, radioid, songidx)
end

SerializerHelper.AskSkillDestructibleCreateGadget_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillDestructibleData, "data", false)
end

ClientToGameSceneDelegate.AskSkillDestructibleCreateGadget = function(self, data)
	return self.Invoke(self, 67726019, SerializerHelper.AskSkillDestructibleCreateGadget_Serializer, data)
end

SerializerHelper.AskAgentVehicleEscape_Serializer = function(writer, agententityid, targetposition, mintargetdistance, jsonconfigid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, targetposition, SerializeAuto.WriteUXVector3, "targetposition")
	SerializeBase.WritePrimitive(writer, mintargetdistance, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, jsonconfigid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskAgentVehicleEscape = function(self, agententityid, targetposition, mintargetdistance, jsonconfigid)
	return self.Invoke(self, 67726962, SerializerHelper.AskAgentVehicleEscape_Serializer, agententityid, targetposition, mintargetdistance, jsonconfigid)
end

SerializerHelper.AskReachNpcGateway_Serializer = function(writer, npcinstanceid)
	SerializeBase.WritePrimitive(writer, npcinstanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskReachNpcGateway = function(self, npcinstanceid)
	self.Notify(self, 67730483, SerializerHelper.AskReachNpcGateway_Serializer, npcinstanceid)
end

SerializerHelper.AskRemoveWeaponDecoration_Serializer = function(writer, weaponinstanceid, slotindex)
	SerializeBase.WritePrimitive(writer, weaponinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, slotindex, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskRemoveWeaponDecoration = function(self, weaponinstanceid, slotindex)
	return self.Invoke(self, 67730623, SerializerHelper.AskRemoveWeaponDecoration_Serializer, weaponinstanceid, slotindex)
end

SerializerHelper.AskEnterVehicleIndoor_Serializer = function(writer, vehicleentityid)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskEnterVehicleIndoor = function(self, vehicleentityid)
	self.Notify(self, 67733426, SerializerHelper.AskEnterVehicleIndoor_Serializer, vehicleentityid)
end

SerializerHelper.AskNotifyPlateGameStallEvent_Serializer = function(writer, plateinstanceid, eventtype)
	SerializeBase.WritePrimitive(writer, plateinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(eventtype, 80, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskNotifyPlateGameStallEvent = function(self, plateinstanceid, eventtype)
	return self.Invoke(self, 67733503, SerializerHelper.AskNotifyPlateGameStallEvent_Serializer, plateinstanceid, eventtype)
end

SerializerHelper.AskFinishGeneralTeleport_Serializer = function(writer, taskid, nodeid, flowid, type)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, flowid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(type, 81, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskFinishGeneralTeleport = function(self, taskid, nodeid, flowid, type)
	return self.Invoke(self, 67736277, SerializerHelper.AskFinishGeneralTeleport_Serializer, taskid, nodeid, flowid, type)
end

SerializerHelper.AskMaidTeaMemberInfo_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskMaidTeaMemberInfo = function(self)
	return self.Invoke(self, 67736356, SerializerHelper.AskMaidTeaMemberInfo_Serializer)
end

SerializerHelper.AskMetroHitEnd_Serializer = function(writer, targetid)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskMetroHitEnd = function(self, targetid)
	return self.Invoke(self, 67737840, SerializerHelper.AskMetroHitEnd_Serializer, targetid)
end

SerializerHelper.AskSetAICheckPointIndex_Serializer = function(writer, agentinstanceid, index)
	SerializeBase.WritePrimitive(writer, agentinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskSetAICheckPointIndex = function(self, agentinstanceid, index)
	return self.Invoke(self, 67738777, SerializerHelper.AskSetAICheckPointIndex_Serializer, agentinstanceid, index)
end

SerializerHelper.BBQPutMeatOnGrill_Serializer = function(writer, gadgetuid, meatid, grillposition)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, meatid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, grillposition, SerializeAuto.WriteUXVector3, "grillposition")
end

ClientToGameSceneDelegate.BBQPutMeatOnGrill = function(self, gadgetuid, meatid, grillposition)
	return self.Invoke(self, 67738820, SerializerHelper.BBQPutMeatOnGrill_Serializer, gadgetuid, meatid, grillposition)
end

SerializerHelper.AskSpoonButtonClickEvent_Serializer = function(writer, id, nodeid)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskSpoonButtonClickEvent = function(self, id, nodeid)
	self.Notify(self, 67740160, SerializerHelper.AskSpoonButtonClickEvent_Serializer, id, nodeid)
end

SerializerHelper.ReportLookAtTargetFinish_Serializer = function(writer, enemyid, actionid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, actionid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.ReportLookAtTargetFinish = function(self, enemyid, actionid)
	self.Notify(self, 67740248, SerializerHelper.ReportLookAtTargetFinish_Serializer, enemyid, actionid)
end

SerializerHelper.AskLoadedInSameScene_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskLoadedInSameScene = function(self)
	self.Notify(self, 67741470, SerializerHelper.AskLoadedInSameScene_Serializer)
end

SerializerHelper.AskUnHangingDestructible_Serializer = function(writer, id, hosttype)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, hosttype, writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskUnHangingDestructible = function(self, id, hosttype)
	return self.Invoke(self, 67741879, SerializerHelper.AskUnHangingDestructible_Serializer, id, hosttype)
end

SerializerHelper.AskAddClientBuff_Serializer = function(writer, unitid, buffid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, buffid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskAddClientBuff = function(self, unitid, buffid)
	self.Notify(self, 67742140, SerializerHelper.AskAddClientBuff_Serializer, unitid, buffid)
end

SerializerHelper.AskCaptureAgentFinished_Serializer = function(writer, pid)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskCaptureAgentFinished = function(self, pid)
	self.Notify(self, 67743132, SerializerHelper.AskCaptureAgentFinished_Serializer, pid)
end

SerializerHelper.AskVehicleMove_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteRaidVehicleSyncData, "data", false)
end

ClientToGameSceneDelegate.AskVehicleMove = function(self, data)
	self.Notify(self, 67743393, SerializerHelper.AskVehicleMove_Serializer, data)
end

SerializerHelper.AskSkillTimeCurve_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillTimeCurveData, "data", false)
end

ClientToGameSceneDelegate.AskSkillTimeCurve = function(self, data)
	self.Notify(self, 67743582, SerializerHelper.AskSkillTimeCurve_Serializer, data)
end

SerializerHelper.AskSelectedTempBuffs_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskSelectedTempBuffs = function(self)
	return self.Invoke(self, 67744397, SerializerHelper.AskSelectedTempBuffs_Serializer)
end

SerializerHelper.AskHackingNpcPress_Serializer = function(writer, instanceid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskHackingNpcPress = function(self, instanceid)
	return self.Invoke(self, 67747341, SerializerHelper.AskHackingNpcPress_Serializer, instanceid)
end

SerializerHelper.AskDicePlayerAction_Serializer = function(writer, gadgetuid, action, intparams, badgeid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(action, 82, 0), writer.WriteByte, 0)
	SerializeBase.WriteList7Bit(writer, intparams, writer.WriteInt32, 0, "intparams", false, RpcLengthLimits.IClientToGameScene_AskDicePlayerAction_intParams, nil)
	SerializeBase.WritePrimitive(writer, badgeid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskDicePlayerAction = function(self, gadgetuid, action, intparams, badgeid)
	return self.Invoke(self, 67747541, SerializerHelper.AskDicePlayerAction_Serializer, gadgetuid, action, intparams, badgeid)
end

SerializerHelper.AskKillVehicle_Serializer = function(writer, vehicleid, reason)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, reason, writer.WriteByte, 1)
end

ClientToGameSceneDelegate.AskKillVehicle = function(self, vehicleid, reason)
	self.Notify(self, 67747687, SerializerHelper.AskKillVehicle_Serializer, vehicleid, reason)
end

SerializerHelper.AskReportAetherLeaflet_Serializer = function(writer, taskid, id, type)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(type, 83, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskReportAetherLeaflet = function(self, taskid, id, type)
	return self.Invoke(self, 67749630, SerializerHelper.AskReportAetherLeaflet_Serializer, taskid, id, type)
end

SerializerHelper.AskVehicleHitEnd_Serializer = function(writer, targetid)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskVehicleHitEnd = function(self, targetid)
	return self.Invoke(self, 67750498, SerializerHelper.AskVehicleHitEnd_Serializer, targetid)
end

SerializerHelper.AskReleaseUnitHookBoneSignal_Serializer = function(writer, hooker, hookee)
	SerializeBase.WritePrimitive(writer, hooker, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, hookee, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskReleaseUnitHookBoneSignal = function(self, hooker, hookee)
	self.Notify(self, 67751038, SerializerHelper.AskReleaseUnitHookBoneSignal_Serializer, hooker, hookee)
end

SerializerHelper.AskTaxiAccelerate_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskTaxiAccelerate = function(self)
	return self.Invoke(self, 67753061, SerializerHelper.AskTaxiAccelerate_Serializer)
end

SerializerHelper.AskCreationMultiEnterOrLeaves_Serializer = function(writer, datas)
	SerializeBase.WriteList7Bit(writer, datas, SerializeBase.WriteStructWrap(SerializeAuto.WriteCreationEnterLeave, "datas"), nil, "datas", false, RpcLengthLimits.IClientToGameScene_AskCreationMultiEnterOrLeaves_datas, nil)
end

ClientToGameSceneDelegate.AskCreationMultiEnterOrLeaves = function(self, datas)
	self.Notify(self, 67753256, SerializerHelper.AskCreationMultiEnterOrLeaves_Serializer, datas)
end

SerializerHelper.AskSkillExecuteEnd2_Serializer = function(writer, executorid, targetid, skillinstanceid, requestdelayholdtrustee)
	SerializeBase.WritePrimitive(writer, executorid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skillinstanceid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, requestdelayholdtrustee, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskSkillExecuteEnd2 = function(self, executorid, targetid, skillinstanceid, requestdelayholdtrustee)
	return self.Invoke(self, 67756196, SerializerHelper.AskSkillExecuteEnd2_Serializer, executorid, targetid, skillinstanceid, requestdelayholdtrustee)
end

SerializerHelper.AskCreateAndAttachDynamicBindMulti_Serializer = function(writer, cfgid, targetunitid, slotids)
	SerializeBase.WritePrimitive(writer, cfgid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, targetunitid, writer.WriteUInt64, 0)
	SerializeBase.WriteList7Bit(writer, slotids, writer.WriteUInt32, 0, "slotids", false, RpcLengthLimits.IClientToGameScene_AskCreateAndAttachDynamicBindMulti_slotIds, nil)
end

ClientToGameSceneDelegate.AskCreateAndAttachDynamicBindMulti = function(self, cfgid, targetunitid, slotids)
	return self.Invoke(self, 67756723, SerializerHelper.AskCreateAndAttachDynamicBindMulti_Serializer, cfgid, targetunitid, slotids)
end

SerializerHelper.AskReleaseVehicleSeat_Serializer = function(writer, vehicleentityid, seatindex)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, seatindex, writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskReleaseVehicleSeat = function(self, vehicleentityid, seatindex)
	self.Notify(self, 67757798, SerializerHelper.AskReleaseVehicleSeat_Serializer, vehicleentityid, seatindex)
end

SerializerHelper.AskGadgetDoorTransfer_Serializer = function(writer, id, from, to, position)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, from, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, to, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
end

ClientToGameSceneDelegate.AskGadgetDoorTransfer = function(self, id, from, to, position)
	self.Notify(self, 67759279, SerializerHelper.AskGadgetDoorTransfer_Serializer, id, from, to, position)
end

SerializerHelper.AskFinishNpcChatRegistration_Serializer = function(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskFinishNpcChatRegistration = function(self, chatid)
	self.Notify(self, 67763002, SerializerHelper.AskFinishNpcChatRegistration_Serializer, chatid)
end

SerializerHelper.AskAddPaokuLimit_Serializer = function(writer, limitids, sourcetype, sourceid)
	SerializeBase.WriteList7Bit(writer, limitids, writer.WriteUInt32, 0, "limitids", false, RpcLengthLimits.IClientToGameScene_AskAddPaokuLimit_limitIds, nil)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(sourcetype, 44, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, sourceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskAddPaokuLimit = function(self, limitids, sourcetype, sourceid)
	return self.Invoke(self, 67763540, SerializerHelper.AskAddPaokuLimit_Serializer, limitids, sourcetype, sourceid)
end

SerializerHelper.AskCinemaSpawnNpc_Serializer = function(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskCinemaSpawnNpc = function(self, locationid)
	return self.Invoke(self, 67769560, SerializerHelper.AskCinemaSpawnNpc_Serializer, locationid)
end

SerializerHelper.AskChineseChessFlipEnterZoneDoublePlayer_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskChineseChessFlipEnterZoneDoublePlayer = function(self, gadgetuid)
	return self.Invoke(self, 67770882, SerializerHelper.AskChineseChessFlipEnterZoneDoublePlayer_Serializer, gadgetuid)
end

SerializerHelper.ReportBotPerceptionTarget_Serializer = function(writer, datas)
	SerializeBase.WriteList7Bit(writer, datas, SerializeBase.WriteStructWrap(SerializeAuto.WriteBotPerceptionReportData, "datas"), nil, "datas", false, RpcLengthLimits.IClientToGameScene_ReportBotPerceptionTarget_datas, nil)
end

ClientToGameSceneDelegate.ReportBotPerceptionTarget = function(self, datas)
	self.Notify(self, 67772531, SerializerHelper.ReportBotPerceptionTarget_Serializer, datas)
end

SerializerHelper.AskSwitchSceneByTask_Serializer = function(writer, taskid, counter)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, counter, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskSwitchSceneByTask = function(self, taskid, counter)
	return self.Invoke(self, 67772729, SerializerHelper.AskSwitchSceneByTask_Serializer, taskid, counter)
end

SerializerHelper.AskVehicleInteractConfig_Serializer = function(writer, data, isclearcache)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteVehicleForwardEventData, "data", false)
	SerializeBase.WritePrimitive(writer, isclearcache, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskVehicleInteractConfig = function(self, data, isclearcache)
	self.Notify(self, 67774383, SerializerHelper.AskVehicleInteractConfig_Serializer, data, isclearcache)
end

SerializerHelper.AskTaffyMotoLeaveRush_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskTaffyMotoLeaveRush = function(self)
	self.Notify(self, 67774637, SerializerHelper.AskTaffyMotoLeaveRush_Serializer)
end

SerializerHelper.ReportAddDestructibleHookFail_Serializer = function(writer, targetid, instanceid)
	SerializeBase.WritePrimitive(writer, targetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportAddDestructibleHookFail = function(self, targetid, instanceid)
	self.Notify(self, 67774704, SerializerHelper.ReportAddDestructibleHookFail_Serializer, targetid, instanceid)
end

SerializerHelper.AskPoliceVehicleHorn_Serializer = function(writer, entityid, play)
	SerializeBase.WritePrimitive(writer, entityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, play, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskPoliceVehicleHorn = function(self, entityid, play)
	self.Notify(self, 67777650, SerializerHelper.AskPoliceVehicleHorn_Serializer, entityid, play)
end

SerializerHelper.AskSpoonConditionComplete_Serializer = function(writer, flowindex, nodeindex, res, port)
	SerializeBase.WritePrimitive(writer, flowindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, nodeindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, res, writer.WriteBoolean, false)
	SerializeBase.WriteList7Bit(writer, port, SerializeBase.WriteComplexWrap(SerializeAuto.WriteControlFlowDataCustom, "ControlFlowDataCustom", true), nil, "port", true, RpcLengthLimits.IClientToGameScene_AskSpoonConditionComplete_port, nil)
end

ClientToGameSceneDelegate.AskSpoonConditionComplete = function(self, flowindex, nodeindex, res, port)
	return self.Invoke(self, 67777751, SerializerHelper.AskSpoonConditionComplete_Serializer, flowindex, nodeindex, res, port)
end

SerializerHelper.AskReportLogicAgentCommandData2_Serializer = function(writer, list)
	SerializeBase.WriteList7Bit(writer, list, SerializeBase.WriteStructWrap(SerializeAuto.WriteLogicAgentCommandReportData, "list"), nil, "list", false, RpcLengthLimits.IClientToGameScene_AskReportLogicAgentCommandData2_list, nil)
end

ClientToGameSceneDelegate.AskReportLogicAgentCommandData2 = function(self, list)
	self.Notify(self, 67780469, SerializerHelper.AskReportLogicAgentCommandData2_Serializer, list)
end

SerializerHelper.AskDoSpoonServerAction_Serializer = function(writer, id, nodeid, index, graphid, param)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, graphid, writer.WriteInt32, 0)
	SerializeBase.WriteComplex(writer, param, SerializeAuto.WriteSpoonActionParam, "param", true)
end

ClientToGameSceneDelegate.AskDoSpoonServerAction = function(self, id, nodeid, index, graphid, param)
	return self.Invoke(self, 67780644, SerializerHelper.AskDoSpoonServerAction_Serializer, id, nodeid, index, graphid, param)
end

SerializerHelper.AskChineseChessFlipPiece_Serializer = function(writer, gadgetuid, col, row)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, col, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, row, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskChineseChessFlipPiece = function(self, gadgetuid, col, row)
	return self.Invoke(self, 67782884, SerializerHelper.AskChineseChessFlipPiece_Serializer, gadgetuid, col, row)
end

SerializerHelper.AskAgentDestructibleCreate_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteAgentDestructibleData, "data", false)
end

ClientToGameSceneDelegate.AskAgentDestructibleCreate = function(self, data)
	return self.Invoke(self, 67783307, SerializerHelper.AskAgentDestructibleCreate_Serializer, data)
end

SerializerHelper.ReportUnitExitPuppet_Serializer = function(writer, unitid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportUnitExitPuppet = function(self, unitid)
	return self.Invoke(self, 67784321, SerializerHelper.ReportUnitExitPuppet_Serializer, unitid)
end

SerializerHelper.ReportSetActionGroup_Serializer = function(writer, uid, actiongroup)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, actiongroup, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.ReportSetActionGroup = function(self, uid, actiongroup)
	self.Notify(self, 67785845, SerializerHelper.ReportSetActionGroup_Serializer, uid, actiongroup)
end

SerializerHelper.ReportPlayerStartCommonInteract_Serializer = function(writer, interactposition, moveid)
	SerializeBase.WriteStruct(writer, interactposition, SerializeAuto.WriteUXVector3, "interactposition")
	SerializeBase.WritePrimitive(writer, moveid, writer.WriteByte, 0)
end

ClientToGameSceneDelegate.ReportPlayerStartCommonInteract = function(self, interactposition, moveid)
	return self.Invoke(self, 67786209, SerializerHelper.ReportPlayerStartCommonInteract_Serializer, interactposition, moveid)
end

SerializerHelper.AskPutChefIngredient_Serializer = function(writer, stoveid, ingredientid)
	SerializeBase.WritePrimitive(writer, stoveid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, ingredientid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskPutChefIngredient = function(self, stoveid, ingredientid)
	return self.Invoke(self, 67791032, SerializerHelper.AskPutChefIngredient_Serializer, stoveid, ingredientid)
end

SerializerHelper.AskCinemaPlayMovie_Serializer = function(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskCinemaPlayMovie = function(self, locationid)
	return self.Invoke(self, 67792208, SerializerHelper.AskCinemaPlayMovie_Serializer, locationid)
end

SerializerHelper.AskHangDestructible_Serializer = function(writer, id, hosttype, hostinstanceid, index)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, hosttype, writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, hostinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskHangDestructible = function(self, id, hosttype, hostinstanceid, index)
	return self.Invoke(self, 67792281, SerializerHelper.AskHangDestructible_Serializer, id, hosttype, hostinstanceid, index)
end

SerializerHelper.AskBVBLinkGameSelectTeam_Serializer = function(writer, pokemonids)
	SerializeBase.WriteList7Bit(writer, pokemonids, writer.WriteUInt64, 0, "pokemonids", false, RpcLengthLimits.IClientToGameScene_AskBVBLinkGameSelectTeam_pokemonIds, nil)
end

ClientToGameSceneDelegate.AskBVBLinkGameSelectTeam = function(self, pokemonids)
	return self.Invoke(self, 67793372, SerializerHelper.AskBVBLinkGameSelectTeam_Serializer, pokemonids)
end

SerializerHelper.AskClaimVehicleSeat_Serializer = function(writer, vehicleentityid, seatindices)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
	SerializeBase.WriteList7Bit(writer, seatindices, writer.WriteByte, 0, "seatindices", false, RpcLengthLimits.IClientToGameScene_AskClaimVehicleSeat_seatIndices, nil)
end

ClientToGameSceneDelegate.AskClaimVehicleSeat = function(self, vehicleentityid, seatindices)
	return self.Invoke(self, 67793830, SerializerHelper.AskClaimVehicleSeat_Serializer, vehicleentityid, seatindices)
end

SerializerHelper.AskTaskPlateLoadComplete_Serializer = function(writer, taskid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskTaskPlateLoadComplete = function(self, taskid)
	return self.Invoke(self, 67794218, SerializerHelper.AskTaskPlateLoadComplete_Serializer, taskid)
end

SerializerHelper.AskBowlingRelease_Serializer = function(writer, gadgetuid, throwindex)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, throwindex, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskBowlingRelease = function(self, gadgetuid, throwindex)
	return self.Invoke(self, 67795293, SerializerHelper.AskBowlingRelease_Serializer, gadgetuid, throwindex)
end

SerializerHelper.AskGetSpoonServerOutputPortIndex_Serializer = function(writer, id, nodeid, graphid, param)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, graphid, writer.WriteInt32, 0)
	SerializeBase.WriteComplex(writer, param, SerializeAuto.WriteSpoonActionParam, "param", true)
end

ClientToGameSceneDelegate.AskGetSpoonServerOutputPortIndex = function(self, id, nodeid, graphid, param)
	return self.Invoke(self, 67797146, SerializerHelper.AskGetSpoonServerOutputPortIndex_Serializer, id, nodeid, graphid, param)
end

SerializerHelper.AskTriggerLeafletSingleFinish_Serializer = function(writer, taskid, personaid)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, personaid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskTriggerLeafletSingleFinish = function(self, taskid, personaid)
	return self.Invoke(self, 67797606, SerializerHelper.AskTriggerLeafletSingleFinish_Serializer, taskid, personaid)
end

SerializerHelper.SetGameGroundPlayerReady_Serializer = function(writer, value)
	SerializeBase.WritePrimitive(writer, value, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.SetGameGroundPlayerReady = function(self, value)
	return self.Invoke(self, 67797980, SerializerHelper.SetGameGroundPlayerReady_Serializer, value)
end

SerializerHelper.AskSkillExecute_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteSkillExecuteData, "data", false)
end

ClientToGameSceneDelegate.AskSkillExecute = function(self, data)
	return self.Invoke(self, 67801037, SerializerHelper.AskSkillExecute_Serializer, data)
end

SerializerHelper.AskControlPowerHoldEnemyUp_Serializer = function(writer, enemyid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskControlPowerHoldEnemyUp = function(self, enemyid)
	return self.Invoke(self, 67802701, SerializerHelper.AskControlPowerHoldEnemyUp_Serializer, enemyid)
end

SerializerHelper.CancelExtractionMark_Serializer = function(writer)
end

ClientToGameSceneDelegate.CancelExtractionMark = function(self)
	return self.Invoke(self, 67805046, SerializerHelper.CancelExtractionMark_Serializer)
end

SerializerHelper.AskPlayerEnsembleActionItem_Serializer = function(writer, nodeid)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskPlayerEnsembleActionItem = function(self, nodeid)
	return self.Invoke(self, 67805058, SerializerHelper.AskPlayerEnsembleActionItem_Serializer, nodeid)
end

SerializerHelper.ProgressStateChange_Serializer = function(writer, state, markid)
	SerializeBase.WritePrimitive(writer, state, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, markid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.ProgressStateChange = function(self, state, markid)
	return self.Invoke(self, 67807297, SerializerHelper.ProgressStateChange_Serializer, state, markid)
end

SerializerHelper.AskCancelTrackWildEnemyGroupInfo_Serializer = function(writer, groupspoonid)
	SerializeBase.WritePrimitive(writer, groupspoonid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskCancelTrackWildEnemyGroupInfo = function(self, groupspoonid)
	return self.Invoke(self, 67807726, SerializerHelper.AskCancelTrackWildEnemyGroupInfo_Serializer, groupspoonid)
end

SerializerHelper.AskSetDgoNavSurfaceState_Serializer = function(writer, dgoid, enable)
	SerializeBase.WritePrimitive(writer, dgoid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, enable, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskSetDgoNavSurfaceState = function(self, dgoid, enable)
	self.Notify(self, 67808904, SerializerHelper.AskSetDgoNavSurfaceState_Serializer, dgoid, enable)
end

SerializerHelper.AskMetroGadgetIds_Serializer = function(writer, metroid)
	SerializeBase.WritePrimitive(writer, metroid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskMetroGadgetIds = function(self, metroid)
	return self.Invoke(self, 67809129, SerializerHelper.AskMetroGadgetIds_Serializer, metroid)
end

SerializerHelper.AskAddClientCreatedWeapon_Serializer = function(writer, sceneitemtemplateid)
	SerializeBase.WritePrimitive(writer, sceneitemtemplateid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskAddClientCreatedWeapon = function(self, sceneitemtemplateid)
	return self.Invoke(self, 67810481, SerializerHelper.AskAddClientCreatedWeapon_Serializer, sceneitemtemplateid)
end

SerializerHelper.AskDoTruckNpcAction_Serializer = function(writer, instanceid, eventid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskDoTruckNpcAction = function(self, instanceid, eventid)
	return self.Invoke(self, 67814053, SerializerHelper.AskDoTruckNpcAction_Serializer, instanceid, eventid)
end

SerializerHelper.AskPlayerOnMetro_Serializer = function(writer, metroid, ison)
	SerializeBase.WritePrimitive(writer, metroid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, ison, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskPlayerOnMetro = function(self, metroid, ison)
	return self.Invoke(self, 67818411, SerializerHelper.AskPlayerOnMetro_Serializer, metroid, ison)
end

SerializerHelper.ReportShelterMoveFinish_Serializer = function(writer, infos)
	SerializeBase.WriteList7Bit(writer, infos, SerializeBase.WriteStructWrap(SerializeAuto.WriteShelterMoveFinishInfo, "infos"), nil, "infos", false, RpcLengthLimits.IClientToGameScene_ReportShelterMoveFinish_infos, nil)
end

ClientToGameSceneDelegate.ReportShelterMoveFinish = function(self, infos)
	self.Notify(self, 67819819, SerializerHelper.ReportShelterMoveFinish_Serializer, infos)
end

SerializerHelper.AskChangePedToVehicleNpc_Serializer = function(writer, npcinstanceid, bindvehicleinstanceid, seatindex)
	SerializeBase.WritePrimitive(writer, npcinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, bindvehicleinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, seatindex, writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskChangePedToVehicleNpc = function(self, npcinstanceid, bindvehicleinstanceid, seatindex)
	return self.Invoke(self, 67821729, SerializerHelper.AskChangePedToVehicleNpc_Serializer, npcinstanceid, bindvehicleinstanceid, seatindex)
end

SerializerHelper.RecordAgentBehavior_Serializer = function(writer, id, agenttype, behavior)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(agenttype, 84, 0), writer.WriteByte, 0)
	writer.WriteString(writer, behavior, false, "RecordAgentBehavior.behavior", RpcLengthLimits.IClientToGameScene_RecordAgentBehavior_behavior)
end

ClientToGameSceneDelegate.RecordAgentBehavior = function(self, id, agenttype, behavior)
	return self.Invoke(self, 67825318, SerializerHelper.RecordAgentBehavior_Serializer, id, agenttype, behavior)
end

SerializerHelper.AskExtractionShooterRemoveContainerItem_Serializer = function(writer, containerinstanceid, cellx, celly)
	SerializeBase.WritePrimitive(writer, containerinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, cellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, celly, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskExtractionShooterRemoveContainerItem = function(self, containerinstanceid, cellx, celly)
	return self.Invoke(self, 67825663, SerializerHelper.AskExtractionShooterRemoveContainerItem_Serializer, containerinstanceid, cellx, celly)
end

SerializerHelper.AskTrailerHitchStateChanged_Serializer = function(writer, trailerentityid, targetentityid, targetdestructibleuniqueid, state)
	SerializeBase.WritePrimitive(writer, trailerentityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetentityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, targetdestructibleuniqueid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(state, 85, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskTrailerHitchStateChanged = function(self, trailerentityid, targetentityid, targetdestructibleuniqueid, state)
	return self.Invoke(self, 67827024, SerializerHelper.AskTrailerHitchStateChanged_Serializer, trailerentityid, targetentityid, targetdestructibleuniqueid, state)
end

SerializerHelper.AskFinishChefPrepareCountDown_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskFinishChefPrepareCountDown = function(self)
	return self.Invoke(self, 67828902, SerializerHelper.AskFinishChefPrepareCountDown_Serializer)
end

SerializerHelper.AskLoseScratchGame_Serializer = function(writer, gadgetid)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskLoseScratchGame = function(self, gadgetid)
	return self.Invoke(self, 67829420, SerializerHelper.AskLoseScratchGame_Serializer, gadgetid)
end

SerializerHelper.LeaveGomoku_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.LeaveGomoku = function(self, gadgetuid)
	return self.Invoke(self, 67832026, SerializerHelper.LeaveGomoku_Serializer, gadgetuid)
end

SerializerHelper.ReportBeBulletAttacked_Serializer = function(writer, uid)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportBeBulletAttacked = function(self, uid)
	self.Notify(self, 67832528, SerializerHelper.ReportBeBulletAttacked_Serializer, uid)
end

SerializerHelper.EnterBowlingZone_Serializer = function(writer, gadgetuid, gametype, agentid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(gametype, 72, 0), writer.WriteByte, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.EnterBowlingZone = function(self, gadgetuid, gametype, agentid)
	return self.Invoke(self, 67832701, SerializerHelper.EnterBowlingZone_Serializer, gadgetuid, gametype, agentid)
end

SerializerHelper.ReportAgentLeavePuppet_Serializer = function(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportAgentLeavePuppet = function(self, agententityid)
	return self.Invoke(self, 67834258, SerializerHelper.ReportAgentLeavePuppet_Serializer, agententityid)
end

SerializerHelper.AskVehicleCancelAutonomousDrivingTarget_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskVehicleCancelAutonomousDrivingTarget = function(self)
	return self.Invoke(self, 67836393, SerializerHelper.AskVehicleCancelAutonomousDrivingTarget_Serializer)
end

SerializerHelper.AskTriggerVehiclePartChange_Serializer = function(writer, signalkey, vehiclepart, isopen)
	writer.WriteString(writer, signalkey, false, "AskTriggerVehiclePartChange.signalKey", RpcLengthLimits.IClientToGameScene_AskTriggerVehiclePartChange_signalKey)
	SerializeBase.WritePrimitive(writer, vehiclepart, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, isopen, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskTriggerVehiclePartChange = function(self, signalkey, vehiclepart, isopen)
	return self.Invoke(self, 67838797, SerializerHelper.AskTriggerVehiclePartChange_Serializer, signalkey, vehiclepart, isopen)
end

SerializerHelper.AskLeaveDiceZone_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskLeaveDiceZone = function(self, gadgetuid)
	return self.Invoke(self, 67842855, SerializerHelper.AskLeaveDiceZone_Serializer, gadgetuid)
end

SerializerHelper.BBQDropMeat_Serializer = function(writer, gadgetuid, meatid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, meatid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.BBQDropMeat = function(self, gadgetuid, meatid)
	return self.Invoke(self, 67846375, SerializerHelper.BBQDropMeat_Serializer, gadgetuid, meatid)
end

SerializerHelper.ReportDirectLocationDetectEvent_Serializer = function(writer, pos, datas)
	SerializeBase.WriteStruct(writer, pos, SerializeAuto.WriteUXVector3, "pos")
	SerializeBase.WriteList7Bit(writer, datas, SerializeBase.WriteStructWrap(SerializeAuto.WriteDirectLocationDetectEventData, "datas"), nil, "datas", false, RpcLengthLimits.IClientToGameScene_ReportDirectLocationDetectEvent_datas, nil)
end

ClientToGameSceneDelegate.ReportDirectLocationDetectEvent = function(self, pos, datas)
	return self.Invoke(self, 67847515, SerializerHelper.ReportDirectLocationDetectEvent_Serializer, pos, datas)
end

SerializerHelper.AskVehicleStopAutonomousDriving_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskVehicleStopAutonomousDriving = function(self)
	return self.Invoke(self, 67849307, SerializerHelper.AskVehicleStopAutonomousDriving_Serializer)
end

SerializerHelper.AskTeleportToPoliceStation_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskTeleportToPoliceStation = function(self)
	return self.Invoke(self, 67850440, SerializerHelper.AskTeleportToPoliceStation_Serializer)
end

SerializerHelper.AskDropBelonging_Serializer = function(writer, agententityid, belongings)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WriteList7Bit(writer, belongings, SerializeBase.WriteComplexWrap(SerializeAuto.WriteDropBelongingData, "DropBelongingData", false), nil, "belongings", false, RpcLengthLimits.IClientToGameScene_AskDropBelonging_belongings, nil)
end

ClientToGameSceneDelegate.AskDropBelonging = function(self, agententityid, belongings)
	self.Notify(self, 67851371, SerializerHelper.AskDropBelonging_Serializer, agententityid, belongings)
end

SerializerHelper.AskSetVehiclePartStatus_Serializer = function(writer, vehicleid, parttype, openorclose)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(parttype, 86, 1), writer.WriteByte, 1)
	SerializeBase.WritePrimitive(writer, openorclose, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskSetVehiclePartStatus = function(self, vehicleid, parttype, openorclose)
	self.Notify(self, 67851415, SerializerHelper.AskSetVehiclePartStatus_Serializer, vehicleid, parttype, openorclose)
end

SerializerHelper.AskSaveActionGroup_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskSaveActionGroup = function(self, id)
	self.Notify(self, 67852042, SerializerHelper.AskSaveActionGroup_Serializer, id)
end

SerializerHelper.RequestRevive_Serializer = function(writer, type)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(type, 87, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.RequestRevive = function(self, type)
	return self.Invoke(self, 67856952, SerializerHelper.RequestRevive_Serializer, type)
end

SerializerHelper.AskSetEffectData_Serializer = function(writer, data, includeme)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteEffectSyncData, "data", false)
	SerializeBase.WritePrimitive(writer, includeme, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskSetEffectData = function(self, data, includeme)
	self.Notify(self, 67857254, SerializerHelper.AskSetEffectData_Serializer, data, includeme)
end

SerializerHelper.AskDoSpoonServerActionByType_Serializer = function(writer, param)
	SerializeBase.WriteComplex(writer, param, SerializeAuto.WriteSpoonServerActionParam, "param", false)
end

ClientToGameSceneDelegate.AskDoSpoonServerActionByType = function(self, param)
	return self.Invoke(self, 67863523, SerializerHelper.AskDoSpoonServerActionByType_Serializer, param)
end

SerializerHelper.StartWorldLifeGame_Serializer = function(writer, typeid)
	SerializeBase.WritePrimitive(writer, typeid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.StartWorldLifeGame = function(self, typeid)
	return self.Invoke(self, 67864009, SerializerHelper.StartWorldLifeGame_Serializer, typeid)
end

SerializerHelper.AskAddCurrentWeaponSceneItemHp_Serializer = function(writer, hp)
	SerializeBase.WritePrimitive(writer, hp, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskAddCurrentWeaponSceneItemHp = function(self, hp)
	self.Notify(self, 67868359, SerializerHelper.AskAddCurrentWeaponSceneItemHp_Serializer, hp)
end

SerializerHelper.AskEnemyUseClientSkillFail_Serializer = function(writer, enemyid, skillid)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskEnemyUseClientSkillFail = function(self, enemyid, skillid)
	self.Notify(self, 67869941, SerializerHelper.AskEnemyUseClientSkillFail_Serializer, enemyid, skillid)
end

SerializerHelper.AskChineseChessRequestTie_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskChineseChessRequestTie = function(self, gadgetuid)
	return self.Invoke(self, 67874447, SerializerHelper.AskChineseChessRequestTie_Serializer, gadgetuid)
end

SerializerHelper.ReportPlayerDetectEvent_Serializer = function(writer, detectevent, uids)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(detectevent, 88, 0), writer.WriteByte, 0)
	SerializeBase.WriteList7Bit(writer, uids, writer.WriteUInt64, 0, "uids", false, RpcLengthLimits.IClientToGameScene_ReportPlayerDetectEvent_uids, nil)
end

ClientToGameSceneDelegate.ReportPlayerDetectEvent = function(self, detectevent, uids)
	self.Notify(self, 67880671, SerializerHelper.ReportPlayerDetectEvent_Serializer, detectevent, uids)
end

SerializerHelper.AskFinishChefQTE_Serializer = function(writer, stoveid)
	SerializeBase.WritePrimitive(writer, stoveid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskFinishChefQTE = function(self, stoveid)
	return self.Invoke(self, 67882761, SerializerHelper.AskFinishChefQTE_Serializer, stoveid)
end

SerializerHelper.RecordBowlingScore_Serializer = function(writer, gadgetuid, throwindex, score)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, throwindex, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, score, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.RecordBowlingScore = function(self, gadgetuid, throwindex, score)
	return self.Invoke(self, 67885738, SerializerHelper.RecordBowlingScore_Serializer, gadgetuid, throwindex, score)
end

SerializerHelper.AskBreakDestructibleObjects_Serializer = function(writer, breaker, brokeninfos)
	SerializeBase.WritePrimitive(writer, breaker, writer.WriteUInt64, 0)
	SerializeBase.WriteList7Bit(writer, brokeninfos, SerializeBase.WriteComplexWrap(SerializeAuto.WriteDestructibleBrokenInfo, "DestructibleBrokenInfo", false), nil, "brokeninfos", false, RpcLengthLimits.IClientToGameScene_AskBreakDestructibleObjects_brokenInfos, nil)
end

ClientToGameSceneDelegate.AskBreakDestructibleObjects = function(self, breaker, brokeninfos)
	self.Notify(self, 67891964, SerializerHelper.AskBreakDestructibleObjects_Serializer, breaker, brokeninfos)
end

SerializerHelper.AskDiscardWeaponByInstanceId_Serializer = function(writer, weaponinstanceid, spiritid, isdropout)
	SerializeBase.WritePrimitive(writer, weaponinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, spiritid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, isdropout, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskDiscardWeaponByInstanceId = function(self, weaponinstanceid, spiritid, isdropout)
	return self.Invoke(self, 67892019, SerializerHelper.AskDiscardWeaponByInstanceId_Serializer, weaponinstanceid, spiritid, isdropout)
end

SerializerHelper.AskFinishBelongingUsages_Serializer = function(writer, list)
	SerializeBase.WriteList7Bit(writer, list, SerializeBase.WriteStructWrap(SerializeAuto.WriteBelongingUsageFinishData, "list"), nil, "list", false, RpcLengthLimits.IClientToGameScene_AskFinishBelongingUsages_list, nil)
end

ClientToGameSceneDelegate.AskFinishBelongingUsages = function(self, list)
	self.Notify(self, 67893840, SerializerHelper.AskFinishBelongingUsages_Serializer, list)
end

SerializerHelper.AskRemoveClientBuffWithReleaser_Serializer = function(writer, unitid, buffid, releaserid)
	SerializeBase.WritePrimitive(writer, unitid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, buffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, releaserid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskRemoveClientBuffWithReleaser = function(self, unitid, buffid, releaserid)
	self.Notify(self, 67895004, SerializerHelper.AskRemoveClientBuffWithReleaser_Serializer, unitid, buffid, releaserid)
end

SerializerHelper.AskVehicleStartMove_Serializer = function(writer, vehicleentityid)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskVehicleStartMove = function(self, vehicleentityid)
	self.Notify(self, 67895057, SerializerHelper.AskVehicleStartMove_Serializer, vehicleentityid)
end

SerializerHelper.AskTriggerPlotEvent_Serializer = function(writer, eventid, agententityid, parameter, clientdmemoverridecfgid)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, parameter, SerializeAuto.WriteStimEventParameter, "parameter")
	SerializeBase.WritePrimitive(writer, clientdmemoverridecfgid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskTriggerPlotEvent = function(self, eventid, agententityid, parameter, clientdmemoverridecfgid)
	self.Notify(self, 67895788, SerializerHelper.AskTriggerPlotEvent_Serializer, eventid, agententityid, parameter, clientdmemoverridecfgid)
end

SerializerHelper.AskAgentStopVehicle_Serializer = function(writer, agententityid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskAgentStopVehicle = function(self, agententityid)
	self.Notify(self, 67897036, SerializerHelper.AskAgentStopVehicle_Serializer, agententityid)
end

SerializerHelper.OnParkourStateChange_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.OnParkourStateChange = function(self, id)
	return self.Invoke(self, 67897801, SerializerHelper.OnParkourStateChange_Serializer, id)
end

SerializerHelper.AskHelicopterScanChange_Serializer = function(writer, open)
	SerializeBase.WritePrimitive(writer, open, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskHelicopterScanChange = function(self, open)
	self.Notify(self, 67898923, SerializerHelper.AskHelicopterScanChange_Serializer, open)
end

SerializerHelper.AskEnterDiceZoneDoubleAI_Serializer = function(writer, gadgetuid, ailevel, gametype, badges)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, ailevel, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(gametype, 89, 0), writer.WriteByte, 0)
	SerializeBase.WriteList7Bit(writer, badges, writer.WriteUInt32, 0, "badges", false, RpcLengthLimits.IClientToGameScene_AskEnterDiceZoneDoubleAI_badges, nil)
end

ClientToGameSceneDelegate.AskEnterDiceZoneDoubleAI = function(self, gadgetuid, ailevel, gametype, badges)
	return self.Invoke(self, 67898934, SerializerHelper.AskEnterDiceZoneDoubleAI_Serializer, gadgetuid, ailevel, gametype, badges)
end

SerializerHelper.AskUpdatePlayerCameraFOV_Serializer = function(writer, fov)
	SerializeBase.WritePrimitive(writer, fov, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskUpdatePlayerCameraFOV = function(self, fov)
	self.Notify(self, 67902252, SerializerHelper.AskUpdatePlayerCameraFOV_Serializer, fov)
end

SerializerHelper.AskClearVehicleSpawnArea_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskClearVehicleSpawnArea = function(self)
	self.Notify(self, 67905541, SerializerHelper.AskClearVehicleSpawnArea_Serializer)
end

SerializerHelper.AskMetroHit_Serializer = function(writer, hitdata)
	SerializeBase.WriteComplex(writer, hitdata, SerializeAuto.WriteMetroHitData, "hitdata", false)
end

ClientToGameSceneDelegate.AskMetroHit = function(self, hitdata)
	return self.Invoke(self, 67907276, SerializerHelper.AskMetroHit_Serializer, hitdata)
end

SerializerHelper.AskGetOffMotor_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskGetOffMotor = function(self)
	self.Notify(self, 67908958, SerializerHelper.AskGetOffMotor_Serializer)
end

SerializerHelper.AskEnemyFallIntoDeepWater_Serializer = function(writer, agentid, enterpos)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, enterpos, SerializeAuto.WriteUXVector3, "enterpos")
end

ClientToGameSceneDelegate.AskEnemyFallIntoDeepWater = function(self, agentid, enterpos)
	return self.Invoke(self, 67910318, SerializerHelper.AskEnemyFallIntoDeepWater_Serializer, agentid, enterpos)
end

SerializerHelper.AskReceivePlayControlSignal_Serializer = function(writer, nodeid, flowindex)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, flowindex, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskReceivePlayControlSignal = function(self, nodeid, flowindex)
	return self.Invoke(self, 67911575, SerializerHelper.AskReceivePlayControlSignal_Serializer, nodeid, flowindex)
end

SerializerHelper.ReportAgentIsOnWall_Serializer = function(writer, uid, isonwall)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, isonwall, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.ReportAgentIsOnWall = function(self, uid, isonwall)
	self.Notify(self, 67913907, SerializerHelper.ReportAgentIsOnWall_Serializer, uid, isonwall)
end

SerializerHelper.AskFightGameSyncPlayerAction_Serializer = function(writer, action, isai)
	writer.WriteString(writer, action, false, "AskFightGameSyncPlayerAction.action", RpcLengthLimits.IClientToGameScene_AskFightGameSyncPlayerAction_action)
	SerializeBase.WritePrimitive(writer, isai, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskFightGameSyncPlayerAction = function(self, action, isai)
	self.Notify(self, 67914561, SerializerHelper.AskFightGameSyncPlayerAction_Serializer, action, isai)
end

SerializerHelper.AskPlateResourceReady_Serializer = function(writer, uid)
	SerializeBase.WritePrimitive(writer, uid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskPlateResourceReady = function(self, uid)
	return self.Invoke(self, 67916920, SerializerHelper.AskPlateResourceReady_Serializer, uid)
end

SerializerHelper.AskClickPlayerTwitterButton_Serializer = function(writer, twitterid)
	SerializeBase.WritePrimitive(writer, twitterid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskClickPlayerTwitterButton = function(self, twitterid)
	return self.Invoke(self, 67918121, SerializerHelper.AskClickPlayerTwitterButton_Serializer, twitterid)
end

SerializerHelper.AskSkipSpoonPlot_Serializer = function(writer, flowindex, nodeid)
	SerializeBase.WritePrimitive(writer, flowindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskSkipSpoonPlot = function(self, flowindex, nodeid)
	return self.Invoke(self, 67919496, SerializerHelper.AskSkipSpoonPlot_Serializer, flowindex, nodeid)
end

SerializerHelper.AskModifyVehicleTopSpeed_Serializer = function(writer, vehicleid, topspeed, beginorend)
	SerializeBase.WritePrimitive(writer, vehicleid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, topspeed, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, beginorend, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskModifyVehicleTopSpeed = function(self, vehicleid, topspeed, beginorend)
	self.Notify(self, 67920147, SerializerHelper.AskModifyVehicleTopSpeed_Serializer, vehicleid, topspeed, beginorend)
end

SerializerHelper.RecordDartPerformEnd_Serializer = function(writer)
end

ClientToGameSceneDelegate.RecordDartPerformEnd = function(self)
	return self.Invoke(self, 67921918, SerializerHelper.RecordDartPerformEnd_Serializer)
end

SerializerHelper.AskAgentSceneRoomTrigger_Serializer = function(writer, sceneroomid, spoonagentid, isenter)
	SerializeBase.WritePrimitive(writer, sceneroomid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, spoonagentid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, isenter, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskAgentSceneRoomTrigger = function(self, sceneroomid, spoonagentid, isenter)
	return self.Invoke(self, 67923734, SerializerHelper.AskAgentSceneRoomTrigger_Serializer, sceneroomid, spoonagentid, isenter)
end

SerializerHelper.AskPlayHurtEffect_Serializer = function(writer, defenderid, attackerid, hurteffectid, stiffid, skillid)
	SerializeBase.WritePrimitive(writer, defenderid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, attackerid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, hurteffectid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, stiffid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, skillid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskPlayHurtEffect = function(self, defenderid, attackerid, hurteffectid, stiffid, skillid)
	self.Notify(self, 67924484, SerializerHelper.AskPlayHurtEffect_Serializer, defenderid, attackerid, hurteffectid, stiffid, skillid)
end

SerializerHelper.TriggerDartTiming_Serializer = function(writer, timing)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(timing, 90, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.TriggerDartTiming = function(self, timing)
	return self.Invoke(self, 67926798, SerializerHelper.TriggerDartTiming_Serializer, timing)
end

SerializerHelper.AskBVBUnlockChaosBuffCandidates_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskBVBUnlockChaosBuffCandidates = function(self)
	return self.Invoke(self, 67927774, SerializerHelper.AskBVBUnlockChaosBuffCandidates_Serializer)
end

SerializerHelper.AskMergeDestructibleObjects_Serializer = function(writer, ids, agentinstanceid, mergepos)
	SerializeBase.WriteList7Bit(writer, ids, writer.WriteUInt64, 0, "ids", false, RpcLengthLimits.IClientToGameScene_AskMergeDestructibleObjects_ids, nil)
	SerializeBase.WritePrimitive(writer, agentinstanceid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, mergepos, SerializeAuto.WriteUXVector3, "mergepos")
end

ClientToGameSceneDelegate.AskMergeDestructibleObjects = function(self, ids, agentinstanceid, mergepos)
	self.Notify(self, 67928151, SerializerHelper.AskMergeDestructibleObjects_Serializer, ids, agentinstanceid, mergepos)
end

SerializerHelper.AskReleaseJoyrideSignal_Serializer = function(writer, signalname)
	writer.WriteString(writer, signalname, false, "AskReleaseJoyrideSignal.signalName", RpcLengthLimits.IClientToGameScene_AskReleaseJoyrideSignal_signalName)
end

ClientToGameSceneDelegate.AskReleaseJoyrideSignal = function(self, signalname)
	return self.Invoke(self, 67929106, SerializerHelper.AskReleaseJoyrideSignal_Serializer, signalname)
end

SerializerHelper.AskLoadSceneCompleted_Serializer = function(writer, sceneid, sessionid)
	SerializeBase.WritePrimitive(writer, sceneid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, sessionid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskLoadSceneCompleted = function(self, sceneid, sessionid)
	self.Notify(self, 67933251, SerializerHelper.AskLoadSceneCompleted_Serializer, sceneid, sessionid)
end

SerializerHelper.DebugClientNpcDebugDensityStatistics_Serializer = function(writer)
end

ClientToGameSceneDelegate.DebugClientNpcDebugDensityStatistics = function(self)
	return self.Invoke(self, 67935122, SerializerHelper.DebugClientNpcDebugDensityStatistics_Serializer)
end

SerializerHelper.AskNpcStartEnterOrExitVehicle_Serializer = function(writer, syncdata)
	SerializeBase.WriteComplex(writer, syncdata, SerializeAuto.WriteNpcVehicleDriveStateInfo, "syncdata", false)
end

ClientToGameSceneDelegate.AskNpcStartEnterOrExitVehicle = function(self, syncdata)
	return self.Invoke(self, 67936257, SerializerHelper.AskNpcStartEnterOrExitVehicle_Serializer, syncdata)
end

SerializerHelper.AskMassHideAreas_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskMassHideAreas = function(self)
	return self.Invoke(self, 67937263, SerializerHelper.AskMassHideAreas_Serializer)
end

SerializerHelper.HoldLetterSignal_Serializer = function(writer, instanceid)
	SerializeBase.WritePrimitive(writer, instanceid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.HoldLetterSignal = function(self, instanceid)
	return self.Invoke(self, 67938182, SerializerHelper.HoldLetterSignal_Serializer, instanceid)
end

SerializerHelper.AskAgentFinishNpcDialog_Serializer = function(writer, agententityid, npcdialogid)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, npcdialogid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskAgentFinishNpcDialog = function(self, agententityid, npcdialogid)
	self.Notify(self, 67940690, SerializerHelper.AskAgentFinishNpcDialog_Serializer, agententityid, npcdialogid)
end

SerializerHelper.AskGetAllMetroInfos_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskGetAllMetroInfos = function(self)
	return self.Invoke(self, 67942203, SerializerHelper.AskGetAllMetroInfos_Serializer)
end

SerializerHelper.ReportBehaviorSeqStart_Serializer = function(writer, enemyid, pointindex, commandindex, type, cmd)
	SerializeBase.WritePrimitive(writer, enemyid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, pointindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, commandindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(type, 79, 0), writer.WriteByte, 0)
	SerializeBase.WriteStruct(writer, cmd, SerializeAuto.WriteBehaviorSeqCommand, "cmd")
end

ClientToGameSceneDelegate.ReportBehaviorSeqStart = function(self, enemyid, pointindex, commandindex, type, cmd)
	self.Notify(self, 67949005, SerializerHelper.ReportBehaviorSeqStart_Serializer, enemyid, pointindex, commandindex, type, cmd)
end

SerializerHelper.AskStartFryChestnutGame_Serializer = function(writer, gadgetid, frytype)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, SerializeBase.CheckEnum(frytype, 91, 0), writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskStartFryChestnutGame = function(self, gadgetid, frytype)
	return self.Invoke(self, 67949200, SerializerHelper.AskStartFryChestnutGame_Serializer, gadgetid, frytype)
end

SerializerHelper.AskSetDgoNavSurface_Serializer = function(writer, surfaceid)
	SerializeBase.WritePrimitive(writer, surfaceid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskSetDgoNavSurface = function(self, surfaceid)
	self.Notify(self, 67949203, SerializerHelper.AskSetDgoNavSurface_Serializer, surfaceid)
end

SerializerHelper.AskRestaurantBuyFoods_Serializer = function(writer, buyfoodinfo)
	SerializeBase.WriteComplex(writer, buyfoodinfo, SerializeAuto.WriteBuyFoodInfo, "buyfoodinfo", false)
end

ClientToGameSceneDelegate.AskRestaurantBuyFoods = function(self, buyfoodinfo)
	return self.Invoke(self, 67951984, SerializerHelper.AskRestaurantBuyFoods_Serializer, buyfoodinfo)
end

SerializerHelper.AskEnemyEndItemDropList_Serializer = function(writer, infos)
	SerializeBase.WriteList7Bit(writer, infos, SerializeBase.WriteStructWrap(SerializeAuto.WriteEndItemDropInfo, "infos"), nil, "infos", false, RpcLengthLimits.IClientToGameScene_AskEnemyEndItemDropList_infos, nil)
end

ClientToGameSceneDelegate.AskEnemyEndItemDropList = function(self, infos)
	self.Notify(self, 67952621, SerializerHelper.AskEnemyEndItemDropList_Serializer, infos)
end

SerializerHelper.AskWebpageOpenOrClose_Serializer = function(writer, webpageid, open)
	SerializeBase.WritePrimitive(writer, webpageid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, open, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskWebpageOpenOrClose = function(self, webpageid, open)
	self.Notify(self, 67953465, SerializerHelper.AskWebpageOpenOrClose_Serializer, webpageid, open)
end

SerializerHelper.AskChineseChessEnterZoneDoublePlayer_Serializer = function(writer, gadgetuid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskChineseChessEnterZoneDoublePlayer = function(self, gadgetuid)
	return self.Invoke(self, 67953601, SerializerHelper.AskChineseChessEnterZoneDoublePlayer_Serializer, gadgetuid)
end

SerializerHelper.ReleaseLinkOccupyGadget_Serializer = function(writer, id)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReleaseLinkOccupyGadget = function(self, id)
	return self.Invoke(self, 67954708, SerializerHelper.ReleaseLinkOccupyGadget_Serializer, id)
end

SerializerHelper.AskSocketExtractionShooterWeaponDecoration_Serializer = function(writer, gunbagconfigid, guncellx, guncelly, decorationslotindex, decorationbagconfigid, decorationcellx, decorationcelly)
	SerializeBase.WritePrimitive(writer, gunbagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, guncellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, guncelly, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, decorationslotindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, decorationbagconfigid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, decorationcellx, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, decorationcelly, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskSocketExtractionShooterWeaponDecoration = function(self, gunbagconfigid, guncellx, guncelly, decorationslotindex, decorationbagconfigid, decorationcellx, decorationcelly)
	return self.Invoke(self, 67955535, SerializerHelper.AskSocketExtractionShooterWeaponDecoration_Serializer, gunbagconfigid, guncellx, guncelly, decorationslotindex, decorationbagconfigid, decorationcellx, decorationcelly)
end

SerializerHelper.AskTeleportAgentByEQS_Serializer = function(writer, taskid, nodeid, agentid, position)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, agentid, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
end

ClientToGameSceneDelegate.AskTeleportAgentByEQS = function(self, taskid, nodeid, agentid, position)
	return self.Invoke(self, 67955864, SerializerHelper.AskTeleportAgentByEQS_Serializer, taskid, nodeid, agentid, position)
end

SerializerHelper.AskSwitchVehicleRadio_Serializer = function(writer, radioid)
	SerializeBase.WritePrimitive(writer, radioid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskSwitchVehicleRadio = function(self, radioid)
	self.Notify(self, 67959772, SerializerHelper.AskSwitchVehicleRadio_Serializer, radioid)
end

SerializerHelper.AskStartChefCook_Serializer = function(writer, stoveid, recipeid)
	SerializeBase.WritePrimitive(writer, stoveid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, recipeid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskStartChefCook = function(self, stoveid, recipeid)
	return self.Invoke(self, 67960255, SerializerHelper.AskStartChefCook_Serializer, stoveid, recipeid)
end

SerializerHelper.AskEndTaxiNavigate_Serializer = function(writer, teleport, skipped, totaldis)
	SerializeBase.WritePrimitive(writer, teleport, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, skipped, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, totaldis, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskEndTaxiNavigate = function(self, teleport, skipped, totaldis)
	return self.Invoke(self, 67960304, SerializerHelper.AskEndTaxiNavigate_Serializer, teleport, skipped, totaldis)
end

SerializerHelper.AskMoveDestructibleObject_Serializer = function(writer, id, position, facing)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WriteStruct(writer, facing, SerializeAuto.WriteUXVector3, "facing")
end

ClientToGameSceneDelegate.AskMoveDestructibleObject = function(self, id, position, facing)
	self.Notify(self, 67962399, SerializerHelper.AskMoveDestructibleObject_Serializer, id, position, facing)
end

SerializerHelper.AskSpawnEnemyInNoNavRaid_Serializer = function(writer, taskid, nodeid, position, facing, movingluaslot, bindrefname, ignoreaoi)
	SerializeBase.WritePrimitive(writer, taskid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, nodeid, writer.WriteInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WritePrimitive(writer, facing, writer.WriteSingle, 0)
	SerializeBase.WritePrimitive(writer, movingluaslot, writer.WriteUInt64, 0)
	writer.WriteString(writer, bindrefname, false, "AskSpawnEnemyInNoNavRaid.bindRefName", RpcLengthLimits.IClientToGameScene_AskSpawnEnemyInNoNavRaid_bindRefName)
	SerializeBase.WritePrimitive(writer, ignoreaoi, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskSpawnEnemyInNoNavRaid = function(self, taskid, nodeid, position, facing, movingluaslot, bindrefname, ignoreaoi)
	return self.Invoke(self, 67963354, SerializerHelper.AskSpawnEnemyInNoNavRaid_Serializer, taskid, nodeid, position, facing, movingluaslot, bindrefname, ignoreaoi)
end

SerializerHelper.AskPreparePlotEvent_Serializer = function(writer, eventid, agententityid, responseid, source)
	SerializeBase.WritePrimitive(writer, eventid, writer.WriteUInt32, 0)
	SerializeBase.WritePrimitive(writer, agententityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, responseid, writer.WriteUInt32, 0)
	SerializeBase.WriteStruct(writer, source, SerializeAuto.WriteStimEventParameter, "source")
end

ClientToGameSceneDelegate.AskPreparePlotEvent = function(self, eventid, agententityid, responseid, source)
	self.Notify(self, 67966346, SerializerHelper.AskPreparePlotEvent_Serializer, eventid, agententityid, responseid, source)
end

SerializerHelper.BBQPickupMeatFromGrill_Serializer = function(writer, gadgetuid, meatid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, meatid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.BBQPickupMeatFromGrill = function(self, gadgetuid, meatid)
	return self.Invoke(self, 67967235, SerializerHelper.BBQPickupMeatFromGrill_Serializer, gadgetuid, meatid)
end

SerializerHelper.AskSetDgoVoxelSurface_Serializer = function(writer, surfaceid)
	SerializeBase.WritePrimitive(writer, surfaceid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskSetDgoVoxelSurface = function(self, surfaceid)
	self.Notify(self, 67969202, SerializerHelper.AskSetDgoVoxelSurface_Serializer, surfaceid)
end

SerializerHelper.AskChangeGoVehicleDriveState_Serializer = function(writer, vehicleentityid, drive, seatindex, gpsinfo)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, drive, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, seatindex, writer.WriteByte, 0)
	SerializeBase.WriteComplex(writer, gpsinfo, SerializeAuto.WriteRaidVehicleGpsInfo, "gpsinfo", true)
end

ClientToGameSceneDelegate.AskChangeGoVehicleDriveState = function(self, vehicleentityid, drive, seatindex, gpsinfo)
	return self.Invoke(self, 67973438, SerializerHelper.AskChangeGoVehicleDriveState_Serializer, vehicleentityid, drive, seatindex, gpsinfo)
end

SerializerHelper.AskClientNpcFindPath_Serializer = function(writer, id, from, to)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WriteStruct(writer, from, SerializeAuto.WriteUXVector3, "from")
	SerializeBase.WriteStruct(writer, to, SerializeAuto.WriteUXVector3, "to")
end

ClientToGameSceneDelegate.AskClientNpcFindPath = function(self, id, from, to)
	return self.Invoke(self, 67974714, SerializerHelper.AskClientNpcFindPath_Serializer, id, from, to)
end

SerializerHelper.AskChangeDestructibleHp_Serializer = function(writer, id, hp)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, hp, writer.WriteSingle, 0)
end

ClientToGameSceneDelegate.AskChangeDestructibleHp = function(self, id, hp)
	self.Notify(self, 67977029, SerializerHelper.AskChangeDestructibleHp_Serializer, id, hp)
end

SerializerHelper.DebugForceSyncAetherVehicleDebugInfo_Serializer = function(writer)
end

ClientToGameSceneDelegate.DebugForceSyncAetherVehicleDebugInfo = function(self)
	self.Notify(self, 67977094, SerializerHelper.DebugForceSyncAetherVehicleDebugInfo_Serializer)
end

SerializerHelper.AskSwitchToLastUsedWeapon_Serializer = function(writer)
end

ClientToGameSceneDelegate.AskSwitchToLastUsedWeapon = function(self)
	return self.Invoke(self, 67977981, SerializerHelper.AskSwitchToLastUsedWeapon_Serializer)
end

SerializerHelper.AskSpoonClientActionComplete_Serializer = function(writer, flowindex, nodeindex, success, portid, port)
	SerializeBase.WritePrimitive(writer, flowindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, nodeindex, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, success, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, portid, writer.WriteInt32, 0)
	SerializeBase.WriteList7Bit(writer, port, SerializeBase.WriteComplexWrap(SerializeAuto.WriteControlFlowDataCustom, "ControlFlowDataCustom", true), nil, "port", true, RpcLengthLimits.IClientToGameScene_AskSpoonClientActionComplete_port, nil)
end

ClientToGameSceneDelegate.AskSpoonClientActionComplete = function(self, flowindex, nodeindex, success, portid, port)
	return self.Invoke(self, 67979824, SerializerHelper.AskSpoonClientActionComplete_Serializer, flowindex, nodeindex, success, portid, port)
end

SerializerHelper.ReportEQSPos_Serializer = function(writer, infos)
	SerializeBase.WriteList7Bit(writer, infos, SerializeBase.WriteStructWrap(SerializeAuto.WriteEQSPosInfo, "infos"), nil, "infos", false, RpcLengthLimits.IClientToGameScene_ReportEQSPos_infos, nil)
end

ClientToGameSceneDelegate.ReportEQSPos = function(self, infos)
	self.Notify(self, 67980296, SerializerHelper.ReportEQSPos_Serializer, infos)
end

SerializerHelper.AskMultiCinemaQueryInfo_Serializer = function(writer, locationid)
	SerializeBase.WritePrimitive(writer, locationid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskMultiCinemaQueryInfo = function(self, locationid)
	return self.Invoke(self, 67980850, SerializerHelper.AskMultiCinemaQueryInfo_Serializer, locationid)
end

SerializerHelper.ChangeDestructibleEffect_Serializer = function(writer, id, effectid, add)
	SerializeBase.WritePrimitive(writer, id, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, effectid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, add, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.ChangeDestructibleEffect = function(self, id, effectid, add)
	return self.Invoke(self, 67981079, SerializerHelper.ChangeDestructibleEffect_Serializer, id, effectid, add)
end

SerializerHelper.AskExistSceneRoom_Serializer = function(writer, sceneroomid, isvehicle, moveid)
	SerializeBase.WritePrimitive(writer, sceneroomid, writer.WriteInt32, 0)
	SerializeBase.WritePrimitive(writer, isvehicle, writer.WriteBoolean, false)
	SerializeBase.WritePrimitive(writer, moveid, writer.WriteByte, 0)
end

ClientToGameSceneDelegate.AskExistSceneRoom = function(self, sceneroomid, isvehicle, moveid)
	return self.Invoke(self, 67982277, SerializerHelper.AskExistSceneRoom_Serializer, sceneroomid, isvehicle, moveid)
end

SerializerHelper.AskVehicleHorn_Serializer = function(writer, entityid, play)
	SerializeBase.WritePrimitive(writer, entityid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, play, writer.WriteBoolean, false)
end

ClientToGameSceneDelegate.AskVehicleHorn = function(self, entityid, play)
	self.Notify(self, 67983272, SerializerHelper.AskVehicleHorn_Serializer, entityid, play)
end

SerializerHelper.ReportEnemyAfterFightFirstSeePlayer_Serializer = function(writer, enemyuid, pid)
	SerializeBase.WritePrimitive(writer, enemyuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, pid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.ReportEnemyAfterFightFirstSeePlayer = function(self, enemyuid, pid)
	self.Notify(self, 67983756, SerializerHelper.ReportEnemyAfterFightFirstSeePlayer_Serializer, enemyuid, pid)
end

SerializerHelper.AskChangeSceneItemQuality_Serializer = function(writer, newrange)
	SerializeBase.WritePrimitive(writer, newrange, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskChangeSceneItemQuality = function(self, newrange)
	return self.Invoke(self, 67983820, SerializerHelper.AskChangeSceneItemQuality_Serializer, newrange)
end

SerializerHelper.AskSwitchWeapon_Serializer = function(writer, index)
	SerializeBase.WritePrimitive(writer, index, writer.WriteInt32, 0)
end

ClientToGameSceneDelegate.AskSwitchWeapon = function(self, index)
	self.Notify(self, 67986128, SerializerHelper.AskSwitchWeapon_Serializer, index)
end

SerializerHelper.RaceSpeedFinish_Serializer = function(writer)
end

ClientToGameSceneDelegate.RaceSpeedFinish = function(self)
	return self.Invoke(self, 67986525, SerializerHelper.RaceSpeedFinish_Serializer)
end

SerializerHelper.AskSetGlobalTimeSlow_Serializer = function(writer, pauseid)
	SerializeBase.WritePrimitive(writer, pauseid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskSetGlobalTimeSlow = function(self, pauseid)
	return self.Invoke(self, 67988110, SerializerHelper.AskSetGlobalTimeSlow_Serializer, pauseid)
end

SerializerHelper.ReportGadgetWeaponGameEnd_Serializer = function(writer, gadgetuid, wheelid)
	SerializeBase.WritePrimitive(writer, gadgetuid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, wheelid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.ReportGadgetWeaponGameEnd = function(self, gadgetuid, wheelid)
	return self.Invoke(self, 67988425, SerializerHelper.ReportGadgetWeaponGameEnd_Serializer, gadgetuid, wheelid)
end

SerializerHelper.AskVehicleStopMove_Serializer = function(writer, vehicleentityid)
	SerializeBase.WritePrimitive(writer, vehicleentityid, writer.WriteUInt64, 0)
end

ClientToGameSceneDelegate.AskVehicleStopMove = function(self, vehicleentityid)
	self.Notify(self, 67988788, SerializerHelper.AskVehicleStopMove_Serializer, vehicleentityid)
end

SerializerHelper.AskCreateDynamicGadget_Serializer = function(writer, pathid, position, facing)
	SerializeBase.WritePrimitive(writer, pathid, writer.WriteInt32, 0)
	SerializeBase.WriteStruct(writer, position, SerializeAuto.WriteUXVector3, "position")
	SerializeBase.WriteStruct(writer, facing, SerializeAuto.WriteUXVector3, "facing")
end

ClientToGameSceneDelegate.AskCreateDynamicGadget = function(self, pathid, position, facing)
	return self.Invoke(self, 67990820, SerializerHelper.AskCreateDynamicGadget_Serializer, pathid, position, facing)
end

SerializerHelper.AskOnMetroEnterStation_Serializer = function(writer, metroids)
	SerializeBase.WriteList7Bit(writer, metroids, writer.WriteInt32, 0, "metroids", false, RpcLengthLimits.IClientToGameScene_AskOnMetroEnterStation_metroIds, nil)
end

ClientToGameSceneDelegate.AskOnMetroEnterStation = function(self, metroids)
	self.Notify(self, 67992485, SerializerHelper.AskOnMetroEnterStation_Serializer, metroids)
end

SerializerHelper.AskCloseNpcChatWnd_Serializer = function(writer, chatid)
	SerializeBase.WritePrimitive(writer, chatid, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskCloseNpcChatWnd = function(self, chatid)
	self.Notify(self, 67994672, SerializerHelper.AskCloseNpcChatWnd_Serializer, chatid)
end

SerializerHelper.AskFinishScratchGame_Serializer = function(writer, gadgetid, rewardmoney)
	SerializeBase.WritePrimitive(writer, gadgetid, writer.WriteUInt64, 0)
	SerializeBase.WritePrimitive(writer, rewardmoney, writer.WriteUInt32, 0)
end

ClientToGameSceneDelegate.AskFinishScratchGame = function(self, gadgetid, rewardmoney)
	return self.Invoke(self, 67996302, SerializerHelper.AskFinishScratchGame_Serializer, gadgetid, rewardmoney)
end

SerializerHelper.AskAetherAIBoatEvent_Serializer = function(writer, data)
	SerializeBase.WriteComplex(writer, data, SerializeAuto.WriteBoatEvent, "data", false)
end

ClientToGameSceneDelegate.AskAetherAIBoatEvent = function(self, data)
	self.Notify(self, 67998810, SerializerHelper.AskAetherAIBoatEvent_Serializer, data)
end

return ClientToGameSceneDelegate
