-- Original chunk: @Lua\LuaGen\AutoGen\RPCSerializeAuto.lua
-- Decompiled from: 00066_RPCSerializeAuto.lua_fddf7b7e77f7.luajit

local Auto = {}
local SerializeObjectMarkNull = 0
local SerializeObjectMarkCommon = 255
local Base = require("LX6/Service/RPCSerializeBase")

Auto.WriteAIAgentInfo_Race = function(writer, val)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RacingDriverRacingAIId, writer.WriteUInt32, 0)
end

Auto.WriteAICallContext = function(writer, val)
end

Auto.WriteAIDebugParameter = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.BtName, false, "AIDebugParameter.BtName", 0)
	writer.WriteString(writer, val.BtMD5, false, "AIDebugParameter.BtMD5", 0)
	Base.WritePrimitive(writer, val.ForceDrive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Tick, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Paused, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EntityType, writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Nodes, Base.WriteComplexWrap(Auto.WriteAINodeData, "AINodeData", false), nil, "Nodes", false, 0, nil)
	Base.WriteList7Bit(writer, val.Variables, Base.WriteStructWrap(Auto.WriteAISharedVariableInfo, "Variables"), nil, "Variables", false, 0, nil)
	Base.WriteStruct(writer, val.Event, Auto.WriteAINodeEvent, "Event")
end

Auto.WriteAIInterrogationFinishOptions = function(writer, val)
	writer.WriteString(writer, val.SessionID, false, "AIInterrogationFinishOptions.SessionID", RpcLengthLimits.AIInterrogationFinishOptions_SessionID)
end

Auto.WriteAIInterrogationSettlement = function(writer, val)
	Base.WritePrimitive(writer, val.CaseId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 47, 0), writer.WriteByte, 0)
end

Auto.WriteAIInterrogationStartInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CaseId, writer.WriteUInt64, 0)
end

Auto.WriteAINodeData = function(writer, val)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TaskIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Reevaluate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Interrupted, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ExecutionStatus, 99, 0), writer.WriteByte, 0)
	writer.WriteString(writer, val.ErrorMessage, true, "AINodeData.ErrorMessage", 0)
	writer.WriteString(writer, val.InfoMessage, true, "AINodeData.InfoMessage", 0)
end

Auto.WriteAINodeEvent = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 100, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteInt32, 0)
end

Auto.WriteAISessionBasicInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.ConstData, false, "AISessionBasicInfo.ConstData", RpcLengthLimits.AISessionBasicInfo_ConstData)
	writer.WriteString(writer, val.MutableData, false, "AISessionBasicInfo.MutableData", RpcLengthLimits.AISessionBasicInfo_MutableData)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxMessageId, writer.WriteUInt32, 0)
end

Auto.WriteAISessionMessageInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.ConstData, false, "AISessionMessageInfo.ConstData", RpcLengthLimits.AISessionMessageInfo_ConstData)
	writer.WriteString(writer, val.MutableData, false, "AISessionMessageInfo.MutableData", RpcLengthLimits.AISessionMessageInfo_MutableData)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
end

Auto.WriteAISharedVariableInfo = function(writer, val)
	writer.WriteString(writer, val.Key, false, "AISharedVariableInfo.Key", 0)
	writer.WriteString(writer, val.Value, false, "AISharedVariableInfo.Value", 0)
end

Auto.WriteAbortDialogInfo = function(writer, val)
	Base.WritePrimitive(writer, val.dialog_id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.type, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.task_id, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.task_type, false, "AbortDialogInfo.task_type", RpcLengthLimits.AbortDialogInfo_task_type)
	Base.WritePrimitive(writer, val.break_dialog_id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.break_type, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.break_task_id, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.break_task_type, false, "AbortDialogInfo.break_task_type", RpcLengthLimits.AbortDialogInfo_break_task_type)
	writer.WriteString(writer, val.note, false, "AbortDialogInfo.note", RpcLengthLimits.AbortDialogInfo_note)
end

Auto.WriteAcceptedTruckOrderInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.Orders, Base.WriteComplexWrap(Auto.WriteTruckJobOrderWrap, "TruckJobOrderWrap", false), nil, "Orders", false, 0, nil)
	Base.WriteDict7Bit(writer, val.EventToAgent, writer.WriteUInt32, writer.WriteUInt64, 0, "EventToAgent", false, 0)
end

Auto.WriteAccumulateSignInActivityCommonInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.Rewards, writer.WriteUInt32, 0, "Rewards", false, 0, nil)
	Base.WriteList7Bit(writer, val.FocusRewards, writer.WriteBoolean, false, "FocusRewards", false, 0, nil)
	Base.WriteList7Bit(writer, val.DisplayReward, writer.WriteUInt32, 0, "DisplayReward", false, 0, nil)
	Base.WriteList7Bit(writer, val.BgImage, writer.WriteUInt32, 0, "BgImage", false, 0, nil)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
end

Auto.WriteAccumulateSignInActivityData = function(writer, val)
	Base.WriteList(writer, val.SignInList, Base.WriteComplexWrap(Auto.WriteAccumulateSignInData, "AccumulateSignInData", false), nil, "SignInList", false, 0, nil)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowRedPoint, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsOutOfDate, writer.WriteBoolean, false)
end

Auto.WriteAccumulateSignInData = function(writer, val)
	Base.WritePrimitive(writer, val.SignInTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsGot, writer.WriteBoolean, false)
end

Auto.WriteAchievementDetail = function(writer, val)
	Base.WritePrimitive(writer, val.AchieveTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Status, writer.WriteByte, 0)
end

Auto.WriteActivityDataBase = function(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowRedPoint, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsOutOfDate, writer.WriteBoolean, false)
end

Auto.WriteAddPlacedFurnitureInfo = function(writer, val)
	Base.WritePrimitive(writer, val.ParentPlacedInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.FurnitureId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
end

Auto.WriteAdhereMovingPlatformInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PlatformType, 101, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.IsScene, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PlatformId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PartId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlatformEid, writer.WriteUInt64, 0)
end

Auto.WriteAdvancedAvoidanceParams = function(writer, val)
	Base.WritePrimitive(writer, val.AvoidAethers, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidNpcs, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidEnemies, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidGoVehicles, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidEcsVehicles, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidRoadBoundary, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidStaticObstacle, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidSwitchLane, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidAllowStayBetweenLanes, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TargetArriveMaxAvoidRadius, writer.WriteSingle, 0)
end

Auto.WriteAdvancedChaseParameters = function(writer, val)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TargetType, 102, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.AvoidEcsVehicles, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidGoVehicles, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidAethers, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidNpcs, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RamRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RamMinOffsetZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RamMaxOffsetZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RamProbability, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RamDecisionInterval, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CruiseSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DummySpeedRatio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Ratio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpeedOverrideType, 103, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

Auto.WriteAdvancedCruiseAdaptorParams = function(writer, val)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.checkClose, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.checkFar, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.closeRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.farawayRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.accelerateScale, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.decelerateScale, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.minSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.maxSpeed, writer.WriteSingle, 0)
end

Auto.WriteAdvancedCruiseParameters = function(writer, val)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CruiseType, 104, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.TargetPointList, Base.WriteStructWrap(Auto.WriteUXVector3, "TargetPointList"), nil, "TargetPointList", false, 0, nil)
	Base.WritePrimitive(writer, val.SummonVehicle, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ConfigFlags, writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.AdaptSpeedToTargetDistance, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.MissionParams, Auto.WriteAdvancedMissionParams, "MissionParams", false)
	Base.WriteComplex(writer, val.AvoidanceParams, Auto.WriteAdvancedAvoidanceParams, "AvoidanceParams", false)
	Base.WriteComplex(writer, val.CruiseAdaptorParams, Auto.WriteAdvancedCruiseAdaptorParams, "CruiseAdaptorParams", false)
	Base.WriteComplex(writer, val.OtherCruiseParams, Auto.WriteAdvancedOtherCruiseParams, "OtherCruiseParams", false)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

Auto.WriteAdvancedDrivingParams = function(writer, val)
	Base.WritePrimitive(writer, val.DriveReverse, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NotAllowThreePointTurn, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AdjustCruiseSpeedBasedOnRoadSpeed, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ObeyTrafficLights, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TrafficLightGreenChannel, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NotAllowMoveReverse, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ArriveNearestRoadToDestination, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NotAllowTurnSlowdown, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TurnSlowSpeedTemplateId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EnableHybridAIControl, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HybridInputDeadZone, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HybridReturnToAIDelay, writer.WriteSingle, 0)
end

Auto.WriteAdvancedFollowRecordingDynamicSpeedParams = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.FollowType, 105, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TargetType, 102, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Step, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MinSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FarAwayCheck, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FarAwayThrehold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CloseToCheck, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CloseToThrehold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AdjustTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.PathOffsetX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.PathOffsetY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.PathOffsetZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.GuideMinDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.GuideMaxDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.GuideMinSpeedThreshold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.GuideMaxSpeedThreshold, writer.WriteSingle, 0)
end

Auto.WriteAdvancedFollowRecordingParameters = function(writer, val)
	Base.WriteList7Bit(writer, val.RecordingSegments, Base.WriteStructWrap(Auto.WriteAdvancedFollowRecordingSegment, "RecordingSegments"), nil, "RecordingSegments", false, 0, nil)
	Base.WriteComplex(writer, val.RouteParams, Auto.WriteAdvancedFollowRouteParams, "RouteParams", false)
	Base.WriteComplex(writer, val.DynamicSpeedParams, Auto.WriteAdvancedFollowRecordingDynamicSpeedParams, "DynamicSpeedParams", false)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

Auto.WriteAdvancedFollowRecordingSegment = function(writer, val)
	writer.WriteString(writer, val.RecordingName, false, "AdvancedFollowRecordingSegment.RecordingName", 0)
	Base.WritePrimitive(writer, val.Progress, writer.WriteSingle, 0)
end

Auto.WriteAdvancedFollowRouteParams = function(writer, val)
	Base.WritePrimitive(writer, val.Mode, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TargetSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TargetArriveDist, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TargetArriveMaxAccel, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.VirtualGroundMoveType, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.DummySpeedRatio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DummyLookAheadDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DefaultWidth, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LeftBoundary, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RightBoundary, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NotAllowThreePointTurn, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidGoVehicles, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidEcsVehicles, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidAethers, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidNpcs, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidRoadBoundary, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidStaticObstacle, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TargetArriveMaxAvoidRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EnableChaosRacing, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ChaosSteerDeadZoneDeg, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NotAllowTurnSlowdown, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TurnSlowSpeedTemplateId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StartFromNextAndNearestPoint, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Ratio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.StopForObstacle, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpeedOverrideType, 103, 0), writer.WriteByte, 0)
end

Auto.WriteAdvancedMissionParams = function(writer, val)
	Base.WritePrimitive(writer, val.Ratio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CruiseSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpeedOverrideType, 103, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetArriveDist, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TargetArriveMaxAccel, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NavMeshFallbackDist, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.VirtualGroundMoveType, 106, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.DummySpeedRatio, writer.WriteSingle, 0)
	Base.WriteComplex(writer, val.DrivingParams, Auto.WriteAdvancedDrivingParams, "DrivingParams", false)
end

Auto.WriteAdvancedOtherCruiseParams = function(writer, val)
	Base.WritePrimitive(writer, val.UseNewSpeedController, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UseNewAvoidance, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TrafficLightQueueWait, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NarrowRoadFollow, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TurnLaneChange, writer.WriteBoolean, false)
end

Auto.WriteAetherAIInitData = function(writer, val)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HasZoneGraph, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ZoneStorageDataHandle, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Intersections, Base.WriteComplexWrap(Auto.WriteClientTrafficIntersectionInitInfo, "ClientTrafficIntersectionInitInfo", true), nil, "Intersections", true, 0, nil)
end

Auto.WriteAgentBeHitTypeData = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.type, 107, 0), writer.WriteByte, 0)
end

Auto.WriteAgentCharacterComponent = function(writer, val)
	Base.WritePrimitive(writer, val.Portrait, writer.WriteUInt32, 0)
end

Auto.WriteAgentCommandData = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteAgentConditionData = function(writer, val)
end

Auto.WriteAgentCrimeData = function(writer, val)
	Base.WriteList7Bit(writer, val.CrimeRecord, writer.WriteUInt32, 0, "CrimeRecord", true, 0, nil)
	Base.WriteList7Bit(writer, val.DefaultItems, writer.WriteUInt32, 0, "DefaultItems", true, 0, nil)
	Base.WriteList7Bit(writer, val.DefaultDrugs, writer.WriteUInt32, 0, "DefaultDrugs", true, 0, nil)
	Base.WritePrimitive(writer, val.Alcohol, writer.WriteInt32, 0)
end

Auto.WriteAgentDestructibleData = function(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SceneItemCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.LivingTime, writer.WriteSingle, 0)
end

Auto.WriteAgentFormationData = function(writer, val)
	Base.WritePrimitive(writer, val.row, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.col, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.colSpacing, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.rowSpacing, writer.WriteSingle, 0)
end

Auto.WriteAgentPlotDestroyConfig = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 109, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.RunAwayPositionList, Base.WriteStructWrap(Auto.WriteUXVector3, "RunAwayPositionList"), nil, "RunAwayPositionList", true, 0, nil)
	Base.WritePrimitive(writer, val.Distance, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
end

Auto.WriteAgentPoliceExamAOIData = function(writer, val)
	Base.WritePrimitive(writer, val.FineTimes, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.Fines, writer.WriteUInt32, writer.WriteBoolean, false, "Fines", false, 0)
end

Auto.WriteAgentPropertyData = function(writer, val)
end

Auto.WriteAgentPropertyDataAiRegion = function(writer, val)
	Base.WritePrimitive(writer, val.CubeAreaId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsEnable, writer.WriteBoolean, false)
end

Auto.WriteAgentPropertyDataAttachNpcToGadgetState = function(writer, val)
	Base.WritePrimitive(writer, val.IsAttach, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.GadgetUniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetGadgetComponentId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ResetPos, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NodeId, writer.WriteInt32, 0)
end

Auto.WriteAgentPropertyDataAttachedGadget = function(writer, val)
	Base.WriteList7Bit(writer, val.AttachedGadgetList, Base.WriteComplexWrap(Auto.WriteAttachedGadgetInfo, "AttachedGadgetInfo", false), nil, "AttachedGadgetList", false, 0, nil)
end

Auto.WriteAgentPropertyDataBool = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteBoolean, false)
end

Auto.WriteAgentPropertyDataCurIdleAction = function(writer, val)
	Base.WritePrimitive(writer, val.GroupId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
end

Auto.WriteAgentPropertyDataEnableInteract = function(writer, val)
	Base.WritePrimitive(writer, val.IsAllBan, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.BanInteractList, writer.WriteInt32, 0, "BanInteractList", false, 0, nil)
end

Auto.WriteAgentPropertyDataGadgetFollowNpcState = function(writer, val)
	Base.WritePrimitive(writer, val.CreatorUniqueId, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.NpcBoneName, false, "AgentPropertyDataGadgetFollowNpcState.NpcBoneName", 0)
end

Auto.WriteAgentPropertyDataInteractIcon = function(writer, val)
	Base.WriteList7Bit(writer, val.Items, Base.WriteComplexWrap(Auto.WriteInteractIconItem, "InteractIconItem", false), nil, "Items", false, 0, nil)
end

Auto.WriteAgentPropertyDataInviteRideNpcInteract = function(writer, val)
	Base.WriteList7Bit(writer, val.InviteRideNpcInteractList, Base.WriteComplexWrap(Auto.WriteInviteRideNpcInteractItem, "InviteRideNpcInteractItem", false), nil, "InviteRideNpcInteractList", false, 0, nil)
end

Auto.WriteAgentPropertyDataMakeNPCRagdollState = function(writer, val)
	Base.WritePrimitive(writer, val.CanGetup, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Mode, 110, 0), writer.WriteByte, 0)
end

Auto.WriteAgentPropertyDataNpcABPVarState = function(writer, val)
	Base.WritePrimitive(writer, val.IsPlayer, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AgentSpoonId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsRagDoll, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Magnitude, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DirectionX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DirectionY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DirectionZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsCanUp, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ForceBone, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsUseConfig, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.VariableType, 111, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.IntValue, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BoolValue, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FloatValue, writer.WriteSingle, 0)
end

Auto.WriteAgentPropertyDataNpcPlayEffectState = function(writer, val)
	Base.WriteList7Bit(writer, val.Effects, Base.WriteComplexWrap(Auto.WriteNpcEffectEntry, "NpcEffectEntry", false), nil, "Effects", false, 0, nil)
	Base.WritePrimitive(writer, val.IsPlayEvent, writer.WriteBoolean, false)
end

Auto.WriteAgentPropertyDataNpcRemoveEffectState = function(writer, val)
	Base.WritePrimitive(writer, val.isImmediately, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.EffectIds, Base.WriteComplexWrap(Auto.WriteNpcEffectEntry, "NpcEffectEntry", false), nil, "EffectIds", false, 0, nil)
end

Auto.WriteAgentPropertyDataNpcSuit = function(writer, val)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.FashionIdList, writer.WriteUInt32, 0, "FashionIdList", true, 0, nil)
end

Auto.WriteAgentPropertyDataOperateSoundState = function(writer, val)
	Base.WritePrimitive(writer, val.SoundId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OperateType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NodeId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.operateNodeId, writer.WriteInt32, 0)
end

Auto.WriteAgentPropertyDataRecoverNpcStimulateState = function(writer, val)
	Base.WritePrimitive(writer, val.IsAll, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.StimulateIds, writer.WriteUInt32, 0, "StimulateIds", false, 0, nil)
end

Auto.WriteAgentPropertyDataSendPhotoNpcChangeMessageState = function(writer, val)
	Base.WritePrimitive(writer, val.AgentSpoonId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WritePrimitive(writer, val.Height, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Radius, writer.WriteSingle, 0)
end

Auto.WriteAgentPropertyDataSlimeChangeState = function(writer, val)
	Base.WritePrimitive(writer, val.SlimeTargetState, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SimulateAgentId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ParticleSize, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Alpha, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TransitionTime, writer.WriteSingle, 0)
end

Auto.WriteAgentPropertyDataString = function(writer, val)
	writer.WriteString(writer, val.V, false, "AgentPropertyDataString.V", 0)
end

Auto.WriteAgentPropertyDataTargetNpcColliderLayerState = function(writer, val)
	Base.WritePrimitive(writer, val.IncludeColliderLayer, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ExcludeColliderLayer, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.AutoRevertAfterDestroy, writer.WriteBoolean, false)
end

Auto.WriteAgentPropertyDataTaskNpcTagState = function(writer, val)
	writer.WriteString(writer, val.NpcTag, false, "AgentPropertyDataTaskNpcTagState.NpcTag", 0)
	Base.WritePrimitive(writer, val.IsAdd, writer.WriteBoolean, false)
end

Auto.WriteAgentPropertyDataTaskShortcutOpenState = function(writer, val)
	writer.WriteString(writer, val.KeyId, false, "AgentPropertyDataTaskShortcutOpenState.KeyId", 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
end

Auto.WriteAgentPropertyDataUint = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt32, 0)
end

Auto.WriteAgentPropertyDataUlong = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt64, 0)
end

Auto.WriteAgentQueryDetailInfo = function(writer, val)
	writer.WriteString(writer, val.AgentSpawnType, false, "AgentQueryDetailInfo.AgentSpawnType", 0)
	writer.WriteString(writer, val.AgentActiveBehavior, true, "AgentQueryDetailInfo.AgentActiveBehavior", 0)
	Base.WritePrimitive(writer, val.UseForwardGroup, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ForceFullAoi, writer.WriteBoolean, false)
end

Auto.WriteAgentSyncClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.NeedFTF180DegreeInteract, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PlayerFTF180DegreeInteract, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IndoorId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.chairId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.gadgetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.forbidAetherAI, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.isApproachNpc, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TriggerLeaveEvent, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.approachDistance, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LeaveDistance, writer.WriteInt32, 0)
	writer.WriteString(writer, val.petPerformData, true, "AgentSyncClientInfo.petPerformData", 0)
	Base.WriteList7Bit(writer, val.stimIDList, writer.WriteInt32, 0, "stimIDList", true, 0, nil)
	Base.WritePrimitive(writer, val.randomModelCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.layer, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.gpsOffsetY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.isTemp, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.spawnEffectId, writer.WriteUInt32, 0, "spawnEffectId", true, 0, nil)
	Base.WritePrimitive(writer, val.hideEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.actionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.actionGroupId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.initPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.useDefaultPoiOnReturn, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.returnPoiActionIds, writer.WriteUInt32, 0, "returnPoiActionIds", true, 0, nil)
	Base.WriteComplex(writer, val.AdherePlatformInfo, Auto.WriteAdhereMovingPlatformInfo, "AdherePlatformInfo", true)
	Base.WritePrimitive(writer, val.AgentDataSetsActivityCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameplaySignalId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.treeName, false, "AgentSyncClientInfo.treeName", 0)
	Base.WritePrimitive(writer, val.sitIndex, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.indoorList, writer.WriteUInt32, 0, "indoorList", true, 0, nil)
	Base.WriteList7Bit(writer, val.roomIds, writer.WriteInt32, 0, "roomIds", true, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.forbidStimulateType, 112, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.agentStimType, 113, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.beHitType, 107, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SpoonAgentId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.isAttackInSafeMode, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FeiSuo, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FashionSuitId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CanBeExaminedByPolice, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IgnoreWanted, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BeAttackIgnorePolicePunish, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InteractId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AISetting, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", false)
	Base.WritePrimitive(writer, val.HackerBetray, writer.WriteBoolean, false)
end

Auto.WriteAllCountryDailyGamePlayRankData = function(writer, val)
	Base.WriteDict7Bit(writer, val.CountryRankDataDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteDailyGamePlayRankData, "DailyGamePlayRankData", false), nil, "CountryRankDataDict", false, 0)
end

Auto.WriteAllCountryDailyGamePlayRecommendData = function(writer, val)
	Base.WriteDict7Bit(writer, val.CountryRecommendDataDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteDailyGamePlayRecommendData, "DailyGamePlayRecommendData", false), nil, "CountryRecommendDataDict", false, 0)
end

Auto.WriteAnimalClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Favor, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.FavorLevel, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.NickName, true, "AnimalClientInfo.NickName", 0)
	Base.WritePrimitive(writer, val.Unlock, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Interacted, writer.WriteBoolean, false)
end

Auto.WriteAnimationCommandData = function(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.AnimId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SelectedActionIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UseRemapping, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CycleNum, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.RemappingLeg, 114, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.StartPosition, Auto.WriteUXVector3, "StartPosition")
	Base.WriteStruct(writer, val.StartDirection, Auto.WriteUXVector3, "StartDirection")
	Base.WritePrimitive(writer, val.AutoRemapping, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.AutoRemappingMoveType, 115, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteApexGrantedRewards = function(writer, val)
	Base.WriteList(writer, val.Entries, Base.WriteComplexWrap(Auto.WriteApexRewardEntry, "ApexRewardEntry", true), nil, "Entries", true, 0, nil)
end

Auto.WriteApexRewardEntry = function(writer, val)
	Base.WritePrimitive(writer, val.RewardInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.RewardCfgId, writer.WriteUInt32, 0)
end

Auto.WriteArcadeGameInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Id, 116, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.MaxScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxStage, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Cleared, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OneCoinBestClearTimeMs, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MultiCoinBestClearTimeMs, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CoinCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameTimeS, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameCount, writer.WriteUInt32, 0)
end

Auto.WriteArcadeGameInfoBee = function(writer, val)
	Base.WritePrimitive(writer, val.MaxScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameTimeS, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameCount, writer.WriteUInt32, 0)
end

Auto.WriteArcadeGameInfoMUGEN = function(writer, val)
	Base.WriteComplex(writer, val.Info, Auto.WriteArcadeGameInfoMUGENDetail, "Info", false)
	Base.WriteDict(writer, val.CharactersInfo, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteArcadeGameInfoMUGENDetail, "ArcadeGameInfoMUGENDetail", false), nil, "CharactersInfo", false, 0)
end

Auto.WriteArcadeGameInfoMUGENDetail = function(writer, val)
	Base.WritePrimitive(writer, val.GameWinCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MinWinGameTimeMs, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameTimeS, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameCount, writer.WriteUInt32, 0)
end

Auto.WriteArcadeGameResult = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Id, 116, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.Score, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Stage, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Cleared, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OneCoinMode, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CoinCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameTimeMs, writer.WriteUInt32, 0)
end

Auto.WriteArcadeGameResultBee = function(writer, val)
	Base.WritePrimitive(writer, val.Score, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameTimeMs, writer.WriteUInt32, 0)
end

Auto.WriteArcadeGameResultMUGEN = function(writer, val)
	Base.WritePrimitive(writer, val.Character, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Win, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.GameTimeMs, writer.WriteUInt32, 0)
end

Auto.WriteAreaColliderParams = function(writer, val)
	Base.WriteStruct(writer, val.BoxAreaParams, Auto.WriteBoxAreaParams, "BoxAreaParams")
end

Auto.WriteAttachedGadgetInfo = function(writer, val)
	Base.WritePrimitive(writer, val.GadgetId, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.NpcBoneName, false, "AttachedGadgetInfo.NpcBoneName", 0)
end

Auto.WriteAttachmentEntrySyncInfo = function(writer, val)
	Base.WritePrimitive(writer, val.EntryId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SceneItemUid, writer.WriteUInt64, 0)
end

Auto.WriteAttachmentFullSyncInfo = function(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Slots, Base.WriteComplexWrap(Auto.WriteAttachmentSlotSyncInfo, "AttachmentSlotSyncInfo", false), nil, "Slots", false, 0, nil)
end

Auto.WriteAttachmentSlotSyncInfo = function(writer, val)
	Base.WritePrimitive(writer, val.SlotId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Entries, Base.WriteComplexWrap(Auto.WriteAttachmentEntrySyncInfo, "AttachmentEntrySyncInfo", false), nil, "Entries", false, 0, nil)
end

Auto.WriteAvoidDangerMoveCommandData = function(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.DangerRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DangerDuration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UpdatePosTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DangerDirRefreshLaneTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DangerDirHalfAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RunChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LookBackType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StopOnCrosswalk, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableOffLaneAttach, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OffLaneAttachSearchRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OffLaneMaxAttachPathLength, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OffLaneMaxAttachPathRatio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OffLaneDirectAttachHeightTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OffLaneAttachArriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteAvoidDangerMoveViaTrafficLaneCommandData = function(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.DangerRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DangerDuration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UpdatePosTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RunChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TrafficSearchRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.PedFallbackSearchRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FallbackToPed, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LaneCommitDuration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RepathCooldown, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteAvoidVehicleMoveCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.Vehicle, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ExitWaitTime, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.ArriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DirectionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TryMatchStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.KeepUpdateTargetPosition, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RunChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.KeepMovingAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteBBQChopstickState = function(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.HoldingMeatId, writer.WriteUInt32, 0)
end

Auto.WriteBBQGameEndInfo = function(writer, val)
	Base.WriteDict7Bit(writer, val.FinalScores, writer.WriteInt32, writer.WriteInt32, 0, "FinalScores", false, 0)
	Base.WritePrimitive(writer, val.WinnerSeatIndex, writer.WriteInt32, 0)
end

Auto.WriteBBQMeatInfo = function(writer, val)
	Base.WritePrimitive(writer, val.MeatId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MeatType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsOnGrill, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.GrillPosition, Auto.WriteUXVector3, "GrillPosition")
	Base.WritePrimitive(writer, val.CurrentSideUp, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HoldingSeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Side0CookTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Side1CookTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Side0CookedLevel, 117, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Side1CookedLevel, 117, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Side0Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Side1Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsBurnt, writer.WriteBoolean, false)
end

Auto.WriteBBQMeatScoreResult = function(writer, val)
	Base.WritePrimitive(writer, val.MeatId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Side0Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Side1Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TotalMeatScore, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Side0CookedLevel, 117, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Side1CookedLevel, 117, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.IsBurnt, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PlayerNewTotalScore, writer.WriteInt32, 0)
end

Auto.WriteBBQParticipantInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HoldingMeatId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

Auto.WriteBBQZoneInfo = function(writer, val)
	Base.WritePrimitive(writer, val.GameDurationSeconds, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameEndTime, writer.WriteDouble, 0)
	Base.WriteList7Bit(writer, val.Meats, Base.WriteComplexWrap(Auto.WriteBBQMeatInfo, "BBQMeatInfo", false), nil, "Meats", false, 0, nil)
	Base.WriteDict7Bit(writer, val.PlayerScores, writer.WriteInt32, writer.WriteInt32, 0, "PlayerScores", false, 0)
	writer.WriteString(writer, val.ZoneSessionId, false, "BBQZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WriteBBehaviorSeqParamInfo = function(writer, val)
	writer.WriteString(writer, val.SmartObjectTemplate, true, "BBehaviorSeqParamInfo.SmartObjectTemplate", 0)
	Base.WritePrimitive(writer, val.BsId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Angle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BindJiGuanId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SitIndex, writer.WriteInt32, 0)
end

Auto.WriteBVBBattleAgentStatistics = function(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Damage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BeDamaged, writer.WriteSingle, 0)
end

Auto.WriteBVBBonus = function(writer, val)
	Base.WritePrimitive(writer, val.Basic, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WinBonus, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StreakLength, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StreakBonus, writer.WriteUInt32, 0)
end

Auto.WriteBVBBuffCandidate = function(writer, val)
	Base.WritePrimitive(writer, val.ChaosBuffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Cost, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Selected, writer.WriteBoolean, false)
end

Auto.WriteBVBBuffData = function(writer, val)
	Base.WritePrimitive(writer, val.ChaosBuffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
end

Auto.WriteBVBPlayerBasicInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PlayerType, 122, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PlayerId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Pokemons, writer.WriteUInt32, 0, "Pokemons", false, 0, nil)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.BVBCamp, 92, 0), writer.WriteByte, 0)
end

Auto.WriteBVBPlayerData = function(writer, val)
	Base.WriteList7Bit(writer, val.Pokemons, Base.WriteComplexWrap(Auto.WriteFightPokemon, "FightPokemon", false), nil, "Pokemons", false, 0, nil)
	Base.WriteList7Bit(writer, val.TagInfos, Base.WriteComplexWrap(Auto.WriteChaosTagInfo, "ChaosTagInfo", false), nil, "TagInfos", false, 0, nil)
	Base.WriteList7Bit(writer, val.ChaosBuffs, Base.WriteComplexWrap(Auto.WriteBVBBuffData, "BVBBuffData", false), nil, "ChaosBuffs", false, 0, nil)
end

Auto.WriteBadgeInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Active, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DropSend, writer.WriteBoolean, false)
end

Auto.WriteBalloonParticipantInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

Auto.WriteBalloonZoneInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TargetModelId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TargetSceneItemCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.BalloonInstanceIdList, writer.WriteUInt64, 0, "BalloonInstanceIdList", false, 0, nil)
	writer.WriteString(writer, val.ZoneSessionId, false, "BalloonZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WriteBartenderCustomerNormalInfo = function(writer, val)
	Base.WritePrimitive(writer, val.LastVisitTime, writer.WriteUInt32, 0)
end

Auto.WriteBartenderCustomerSuperInfo = function(writer, val)
	Base.WritePrimitive(writer, val.VisitCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastVisitTime, writer.WriteUInt32, 0)
end

Auto.WriteBartenderCustomerSyncInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 123, 1), writer.WriteByte, 1)
end

Auto.WriteBartenderElementInfos = function(writer, val)
	Base.WriteDict(writer, val.ElementId2StockOzDict, writer.WriteUInt32, writer.WriteSingle, 0, "ElementId2StockOzDict", false, 0)
end

Auto.WriteBartenderGameInfos = function(writer, val)
	Base.WriteDict(writer, val.CustomerSuperDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBartenderCustomerSuperInfo, "BartenderCustomerSuperInfo", false), nil, "CustomerSuperDict", false, 0)
	Base.WriteDict(writer, val.CustomerNormalDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBartenderCustomerNormalInfo, "BartenderCustomerNormalInfo", false), nil, "CustomerNormalDict", false, 0)
end

Auto.WriteBasicClubInfo = function(writer, val)
	Base.WritePrimitive(writer, val.ClubId, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.Name, false, "BasicClubInfo.Name", 0)
	Base.WritePrimitive(writer, val.IconCfgId, writer.WriteUInt32, 0)
end

Auto.WriteBasketBallEnergyEventInfo = function(writer, val)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Energy, writer.WriteUInt32, 0)
end

Auto.WriteBasketBallEventInfo = function(writer, val)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.OffensePids, writer.WriteUInt64, 0, "OffensePids", false, 0, nil)
	Base.WriteList7Bit(writer, val.DefensePids, writer.WriteUInt64, 0, "DefensePids", false, 0, nil)
	Base.WritePrimitive(writer, val.TimeStamp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NewTimeStamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.CurRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AiOwnerPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.robotAIAgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ExitStatus, 124, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.robotUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.EndReason, 125, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.FreeShotBasketballSceneItemId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.FreeShotBasketballSceneItemIds, writer.WriteUInt64, 0, "FreeShotBasketballSceneItemIds", false, 0, nil)
	Base.WritePrimitive(writer, val.IsOffenseHoldingBall, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ReconnectPlayerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsPrePickupExchange, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NeedExitThreePointPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TotalRoundDuration, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsClockStopped, writer.WriteBoolean, false)
end

Auto.WriteBasketBallFoulEventInfo = function(writer, val)
	Base.WritePrimitive(writer, val.FoulType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShooterUid, writer.WriteUInt64, 0)
end

Auto.WriteBasketBallScoreInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Score, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StealCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BlockCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Hit3Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HitCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShootCount, writer.WriteUInt32, 0)
end

Auto.WriteBasketBallStateEventInfo = function(writer, val)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
end

Auto.WriteBasketBallZoneInfo = function(writer, val)
	Base.WriteDict7Bit(writer, val.ScoreInfoDic, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteBasketBallScoreInfo, "BasketBallScoreInfo", false), nil, "ScoreInfoDic", false, 0)
	Base.WritePrimitive(writer, val.BasketballSceneItemId, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.ZoneSessionId, false, "BasketBallZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WriteBasketballAskOperatorParam = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.OperatorType, 126, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BallUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ActiveUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PassiveUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.BallState, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BallOwnerID, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.DelayParam, Auto.WriteBasketballSyncDelayActionSpecialParam, "DelayParam", true)
	Base.WriteComplex(writer, val.ShootParam, Auto.WriteBasketballSyncShootSpecialParam, "ShootParam", true)
	Base.WriteComplex(writer, val.ConfrontationParam, Auto.WriteBasketballConfrontationParam, "ConfrontationParam", true)
	Base.WriteComplex(writer, val.ScoreEventParam, Auto.WriteBasketballScoreEventParam, "ScoreEventParam", true)
	Base.WriteComplex(writer, val.BlockEventParam, Auto.WriteBasketballBlockEventParam, "BlockEventParam", true)
	Base.WriteComplex(writer, val.StealEventParam, Auto.WriteBasketballStealEventParam, "StealEventParam", true)
	Base.WriteComplex(writer, val.FreeStyleParam, Auto.WriteBasketballFreeStyleParam, "FreeStyleParam", true)
	Base.WriteComplex(writer, val.PassParam, Auto.WriteBasketballPassParam, "PassParam", true)
	Base.WriteComplex(writer, val.InterceptParam, Auto.WriteBasketballInterceptParam, "InterceptParam", true)
	Base.WriteComplex(writer, val.PickupEventParam, Auto.WriteBasketballPickupEventParam, "PickupEventParam", true)
	Base.WriteComplex(writer, val.ReboundEventParam, Auto.WriteBasketballReboundEventParam, "ReboundEventParam", true)
end

Auto.WriteBasketballBlockEventParam = function(writer, val)
	Base.WritePrimitive(writer, val.inPerfectZone, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.changeTrusteeToMe, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.extraParam, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.angle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.distanceToRim, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.progress, writer.WriteSingle, 0)
end

Auto.WriteBasketballConfrontationParam = function(writer, val)
	Base.WritePrimitive(writer, val.param1, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.param2, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.param3, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.confrontationResult, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.angle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.distanceToRim, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.pid1, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.pos1, Auto.WriteUXVector3, "pos1")
	Base.WriteStruct(writer, val.forward1, Auto.WriteUXVector3, "forward1")
	Base.WritePrimitive(writer, val.pid2, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.pos2, Auto.WriteUXVector3, "pos2")
	Base.WriteStruct(writer, val.forward2, Auto.WriteUXVector3, "forward2")
end

Auto.WriteBasketballDefenderSnapshot = function(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Forward, Auto.WriteUXVector3, "Forward")
	Base.WritePrimitive(writer, val.Distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Angle, writer.WriteSingle, 0)
end

Auto.WriteBasketballFreeStyleParam = function(writer, val)
	Base.WritePrimitive(writer, val.distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.angle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.distanceToRim, writer.WriteSingle, 0)
end

Auto.WriteBasketballInterceptParam = function(writer, val)
	Base.WritePrimitive(writer, val.changeTrusteeToMe, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.InterceptorPos, Auto.WriteUXVector3, "InterceptorPos")
	Base.WriteStruct(writer, val.InterceptorForward, Auto.WriteUXVector3, "InterceptorForward")
	Base.WriteStruct(writer, val.BallStartPos, Auto.WriteUXVector3, "BallStartPos")
	Base.WriteStruct(writer, val.BallEndPos, Auto.WriteUXVector3, "BallEndPos")
	Base.WriteStruct(writer, val.BallCurrentPos, Auto.WriteUXVector3, "BallCurrentPos")
	Base.WriteStruct(writer, val.BallVelocity, Auto.WriteUXVector3, "BallVelocity")
	Base.WritePrimitive(writer, val.distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.angle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.PassToken, writer.WriteUInt64, 0)
end

Auto.WriteBasketballMatchContext = function(writer, val)
	Base.WritePrimitive(writer, val.MyTeamAvgMMR, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OpponentAvgMMR, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsBotMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TotalPlayers, writer.WriteInt32, 0)
end

Auto.WriteBasketballPassParam = function(writer, val)
	Base.WriteStruct(writer, val.PasserPos, Auto.WriteUXVector3, "PasserPos")
	Base.WriteStruct(writer, val.PasserForward, Auto.WriteUXVector3, "PasserForward")
	Base.WriteStruct(writer, val.ReceiverPos, Auto.WriteUXVector3, "ReceiverPos")
	Base.WriteStruct(writer, val.ReceiverForward, Auto.WriteUXVector3, "ReceiverForward")
	Base.WritePrimitive(writer, val.PasserToReceiverDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.PasserToReceiverAngle, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.PasserDefenders, Base.WriteComplexWrap(Auto.WriteBasketballDefenderSnapshot, "BasketballDefenderSnapshot", false), nil, "PasserDefenders", false, RpcLengthLimits.BasketballPassParam_PasserDefenders, nil)
	Base.WriteList7Bit(writer, val.ReceiverDefenders, Base.WriteComplexWrap(Auto.WriteBasketballDefenderSnapshot, "BasketballDefenderSnapshot", false), nil, "ReceiverDefenders", false, RpcLengthLimits.BasketballPassParam_ReceiverDefenders, nil)
	Base.WritePrimitive(writer, val.PassToken, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PassPerformTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.PassType, writer.WriteInt32, 0)
end

Auto.WriteBasketballPickupEventParam = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 127, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PickBackboardZoneClip, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.RebounderPos, Auto.WriteUXVector3, "RebounderPos")
	Base.WriteStruct(writer, val.RebounderForward, Auto.WriteUXVector3, "RebounderForward")
	Base.WriteStruct(writer, val.BallPos, Auto.WriteUXVector3, "BallPos")
	Base.WriteStruct(writer, val.BallLandingPos, Auto.WriteUXVector3, "BallLandingPos")
	Base.WriteStruct(writer, val.BallVelocity, Auto.WriteUXVector3, "BallVelocity")
	Base.WritePrimitive(writer, val.ShootTokenForRebound, writer.WriteUInt64, 0)
end

Auto.WriteBasketballReboundEventParam = function(writer, val)
	Base.WritePrimitive(writer, val.PickBackboardZoneClip, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.RebounderPos, Auto.WriteUXVector3, "RebounderPos")
	Base.WriteStruct(writer, val.RebounderForward, Auto.WriteUXVector3, "RebounderForward")
	Base.WriteStruct(writer, val.BallPos, Auto.WriteUXVector3, "BallPos")
	Base.WriteStruct(writer, val.BallLandingPos, Auto.WriteUXVector3, "BallLandingPos")
	Base.WriteStruct(writer, val.BallVelocity, Auto.WriteUXVector3, "BallVelocity")
	Base.WritePrimitive(writer, val.ShootTokenForRebound, writer.WriteUInt64, 0)
end

Auto.WriteBasketballScoreEventParam = function(writer, val)
	Base.WritePrimitive(writer, val.param1, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.param2, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.param3, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ShootToken, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.isAIUnit, writer.WriteBoolean, false)
end

Auto.WriteBasketballStealEventParam = function(writer, val)
	Base.WritePrimitive(writer, val.changeTrusteeToMe, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.extraParam, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.angle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.distanceToRim, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.InterceptorPos, Auto.WriteUXVector3, "InterceptorPos")
	Base.WriteStruct(writer, val.InterceptorForward, Auto.WriteUXVector3, "InterceptorForward")
	Base.WriteStruct(writer, val.BallStartPos, Auto.WriteUXVector3, "BallStartPos")
	Base.WriteStruct(writer, val.BallEndPos, Auto.WriteUXVector3, "BallEndPos")
	Base.WriteStruct(writer, val.BallCurrentPos, Auto.WriteUXVector3, "BallCurrentPos")
	Base.WriteStruct(writer, val.BallVelocity, Auto.WriteUXVector3, "BallVelocity")
	Base.WriteList7Bit(writer, val.BallTrajectory, Base.WriteStructWrap(Auto.WriteUXVector3, "BallTrajectory"), nil, "BallTrajectory", false, RpcLengthLimits.BasketballStealEventParam_BallTrajectory, nil)
	Base.WritePrimitive(writer, val.PassToken, writer.WriteUInt64, 0)
end

Auto.WriteBasketballSyncDelayActionSpecialParam = function(writer, val)
	Base.WritePrimitive(writer, val.delay, writer.WriteSingle, 0)
end

Auto.WriteBasketballSyncOperatorParam = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.OperatorType, 126, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BallUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ActiveUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PassiveUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.BallState, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsSuccess, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.DelayParam, Auto.WriteBasketballSyncDelayActionSpecialParam, "DelayParam", true)
	Base.WriteComplex(writer, val.ShootParam, Auto.WriteBasketballSyncShootSpecialParam, "ShootParam", true)
	Base.WriteComplex(writer, val.ConfrontationParam, Auto.WriteBasketballConfrontationParam, "ConfrontationParam", true)
	Base.WriteComplex(writer, val.ScoreEventParam, Auto.WriteBasketballScoreEventParam, "ScoreEventParam", true)
	Base.WriteComplex(writer, val.BlockEventParam, Auto.WriteBasketballBlockEventParam, "BlockEventParam", true)
	Base.WriteComplex(writer, val.StealEventParam, Auto.WriteBasketballStealEventParam, "StealEventParam", true)
	Base.WriteComplex(writer, val.FreeStyleParam, Auto.WriteBasketballFreeStyleParam, "FreeStyleParam", true)
	Base.WriteComplex(writer, val.PassParam, Auto.WriteBasketballPassParam, "PassParam", true)
	Base.WriteComplex(writer, val.InterceptParam, Auto.WriteBasketballInterceptParam, "InterceptParam", true)
	Base.WriteComplex(writer, val.PickupEventParam, Auto.WriteBasketballPickupEventParam, "PickupEventParam", true)
	Base.WriteComplex(writer, val.ReboundEventParam, Auto.WriteBasketballReboundEventParam, "ReboundEventParam", true)
	Base.WritePrimitive(writer, val.token, writer.WriteUInt64, 0)
end

Auto.WriteBasketballSyncOwnerInfo = function(writer, val)
	Base.WriteDict7Bit(writer, val.full, writer.WriteUInt64, writer.WriteUInt64, 0, "full", true, 0)
	Base.WriteDict7Bit(writer, val.addOrUpdate, writer.WriteUInt64, writer.WriteUInt64, 0, "addOrUpdate", true, 0)
	Base.WriteList7Bit(writer, val.remove, writer.WriteUInt64, 0, "remove", true, 0, nil)
end

Auto.WriteBasketballSyncShootSpecialParam = function(writer, val)
	Base.WriteStruct(writer, val.startPos, Auto.WriteUXVector3, "startPos")
	Base.WriteStruct(writer, val.finalPos, Auto.WriteUXVector3, "finalPos")
	Base.WriteStruct(writer, val.shootVelocity, Auto.WriteUXVector3, "shootVelocity")
	Base.WritePrimitive(writer, val.moveTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsInGreenBox, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ShootType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Defender, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DefenderDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DefenderAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ScoreNum, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ShootToken, writer.WriteUInt64, 0)
end

Auto.WriteBasketballTierSettleData = function(writer, val)
	Base.WritePrimitive(writer, val.Won, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MultiPlayerId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GMScore, writer.WriteUInt32, 0)
end

Auto.WriteBattleMoveDataBase = function(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveType, 128, 0), writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BlockCloseCapsuleCollision, writer.WriteBoolean, false)
end

Auto.WriteBattleMoveTowardPointData = function(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WritePrimitive(writer, Base.CheckEnum(val.BattleMoveActionType, 94, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.MoveRotateSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MinMoveTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ReportOnStop, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
end

Auto.WriteBattleMoveTowardUnitData = function(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.BattleMoveActionType, 94, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.MoveRotateSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MinMoveTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ReportOnStop, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
end

Auto.WriteBattleStatisticInfos = function(writer, val)
	Base.WritePrimitive(writer, val.KillCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DeadCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HeadShotCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Damage, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.BeDamaged, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Heal, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.BeHealed, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.VehicleDistance, writer.WriteDouble, 0)
end

Auto.WriteBegBehaviorData = function(writer, val)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PoseStartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Spot, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.begStyle, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcGatherRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NpcGatherLimit, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DialogId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RewardMean, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RewardVariance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TotalReward, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalAttractedNpc, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TotalRewardFromPlayer, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.NpcIds, writer.WriteUInt32, 0, "NpcIds", false, 0, nil)
	Base.WritePrimitive(writer, val.IsPromoted, writer.WriteBoolean, false)
end

Auto.WriteBeggarAiPaintingClientInfo = function(writer, val)
	writer.WriteString(writer, val.ObjectKey, false, "BeggarAiPaintingClientInfo.ObjectKey", 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Name, false, "BeggarAiPaintingClientInfo.Name", 0)
	Base.WritePrimitive(writer, val.IsAiPolished, writer.WriteBoolean, false)
end

Auto.WriteBeggarAiPaintingUploadUrl = function(writer, val)
	writer.WriteString(writer, val.PresignedUrl, false, "BeggarAiPaintingUploadUrl.PresignedUrl", 0)
	writer.WriteString(writer, val.ObjectKey, false, "BeggarAiPaintingUploadUrl.ObjectKey", 0)
	Base.WritePrimitive(writer, val.ExpireTimeStamp, writer.WriteUInt32, 0)
end

Auto.WriteBehaviorSeqCommand = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 129, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CommandIndex, writer.WriteInt32, 0)
end

Auto.WriteBehaviorSequenceBehaviorCommandPayload = function(writer, val)
	Base.WritePrimitive(writer, val.BehaviorId, writer.WriteUInt32, 0)
end

Auto.WriteBehaviorSequenceMoveCommandPayload = function(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Angle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Kind, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OverrideActionGroup, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ActionGroupId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CircleMoveRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.useEndRotate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.rotateSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.moveSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Timeout, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ArrivalOverried, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ArrivalRangeType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ArrivalRange, writer.WriteSingle, 0)
end

Auto.WriteBehaviorTaskCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.BehaviorId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteBehaviorTreeCommandData = function(writer, val)
	writer.WriteString(writer, val.BehaviorTree, false, "BehaviorTreeCommandData.BehaviorTree", 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteBeiDoraInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BeiDoraPlayerIndex, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.BeiDoras, writer.WriteInt32, 0, "BeiDoras", false, 0, nil)
	Base.WriteStruct(writer, val.HandData, Auto.WritePlayerHandData, "HandData")
	Base.WritePrimitive(writer, val.RemainTurnTime, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Operations, Base.WriteStructWrap(Auto.WriteOutTurnOperation, "Operations"), nil, "Operations", false, 0, nil)
	Base.WriteStruct(writer, val.MahjongSetData, Auto.WriteMahjongSetData, "MahjongSetData")
end

Auto.WriteBelongItemInfo = function(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.BelongingItemState, 130, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.OwnerId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

Auto.WriteBelongingDebugInfo = function(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt32, 0)
end

Auto.WriteBelongingItemStateChangeData = function(writer, val)
	Base.WritePrimitive(writer, val.AgentEntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.BelongingId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteUInt32, 0)
end

Auto.WriteBelongingUsageFinishData = function(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UsageId, writer.WriteUInt32, 0)
end

Auto.WriteBestNpcInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Favor, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowFavorLevel, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ShowFavorTime, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InteractDays, writer.WriteUInt32, 0)
end

Auto.WriteBestRankResult = function(writer, val)
	Base.WritePrimitive(writer, val.RankConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteInt32, 0)
end

Auto.WriteBillInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	writer.WriteString(writer, val.UserName, false, "BillInfo.UserName", 0)
	Base.WritePrimitive(writer, val.OrderTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShipTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ChargeId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.GoodsId, false, "BillInfo.GoodsId", 0)
	writer.WriteString(writer, val.SN, false, "BillInfo.SN", 0)
	writer.WriteString(writer, val.ConsumeSN, false, "BillInfo.ConsumeSN", 0)
	writer.WriteString(writer, val.PayChannel, false, "BillInfo.PayChannel", 0)
	writer.WriteString(writer, val.AppChannel, false, "BillInfo.AppChannel", 0)
	writer.WriteString(writer, val.PayMethod, false, "BillInfo.PayMethod", 0)
	writer.WriteString(writer, val.Platform, false, "BillInfo.Platform", 0)
	writer.WriteString(writer, val.Udid, false, "BillInfo.Udid", 0)
	Base.WritePrimitive(writer, val.GoodsCount, writer.WriteInt32, 0)
	writer.WriteString(writer, val.PayMoney, false, "BillInfo.PayMoney", 0)
	writer.WriteString(writer, val.FreeMoney, false, "BillInfo.FreeMoney", 0)
	writer.WriteString(writer, val.PayCurrency, false, "BillInfo.PayCurrency", 0)
	Base.WritePrimitive(writer, val.Deduct, writer.WriteInt32, 0)
	writer.WriteString(writer, val.DeductPercent, false, "BillInfo.DeductPercent", 0)
	Base.WritePrimitive(writer, val.FreeYuanBao, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PayYuanBao, writer.WriteInt32, 0)
end

Auto.WriteBirdGroupData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 131, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.StateStartTime, writer.WriteUInt32, 0)
end

Auto.WriteBoardingExtInfo = function(writer, val)
	Base.WriteStruct(writer, val.PositionOffset, Auto.WriteUXVector3, "PositionOffset")
	Base.WriteStruct(writer, val.RotationOffset, Auto.WriteUXVector3, "RotationOffset")
	Base.WritePrimitive(writer, val.CanBeEjected, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UseSpecificAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
end

Auto.WriteBoatAddData = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleColorPartId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StartPointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StartDistanceAlongSegment, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TargetPointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TargetSegDist, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CruiseSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Timestamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
end

Auto.WriteBoatCommand = function(writer, val)
	Base.WritePrimitive(writer, val.BoatId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CommandType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TargetPointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TargetSegDist, writer.WriteSingle, 0)
end

Auto.WriteBoatEvent = function(writer, val)
	Base.WritePrimitive(writer, val.BoatId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.EventType, writer.WriteByte, 0)
	Base.WriteStruct(writer, val.CurrentPosition, Auto.WriteUXVector3, "CurrentPosition")
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReachedPointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DistanceAlongSegment, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Reason, writer.WriteByte, 0)
end

Auto.WriteBoolPayload = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteBoolean, false)
end

Auto.WriteBotInfo = function(writer, val)
	Base.WritePrimitive(writer, val.BotId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Mmr, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Tier, writer.WriteInt32, 0)
end

Auto.WriteBotMatchMemberResult = function(writer, val)
	Base.WritePrimitive(writer, val.BotId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Mmr, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Tier, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Duty, writer.WriteUInt32, 0)
end

Auto.WriteBotMatchResult = function(writer, val)
	Base.WritePrimitive(writer, val.RoomId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 132, 0), writer.WriteByte, 0)
	Base.WriteList(writer, val.MatchedRooms, Base.WriteComplexWrap(Auto.WriteBotMatchRoomResult, "BotMatchRoomResult", false), nil, "MatchedRooms", false, 0, nil)
end

Auto.WriteBotMatchRoomResult = function(writer, val)
	Base.WritePrimitive(writer, val.RoomId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.OwnerPid, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.Members, Base.WriteComplexWrap(Auto.WriteBotMatchMemberResult, "BotMatchMemberResult", false), nil, "Members", false, 0, nil)
end

Auto.WriteBotPerceptionReportData = function(writer, val)
	Base.WritePrimitive(writer, val.botId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.targetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.isSeen, writer.WriteBoolean, false)
end

Auto.WriteBowlingClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt32, 0)
	writer.WriteString(writer, val.Data, false, "BowlingClientInfo.Data", RpcLengthLimits.BowlingClientInfo_Data)
end

Auto.WriteBowlingParticipantInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

Auto.WriteBowlingParticipantScoreInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.ThrowScores, writer.WriteInt32, 0, "ThrowScores", false, 0, nil)
	Base.WriteList7Bit(writer, val.FrameScores, writer.WriteInt32, 0, "FrameScores", false, 0, nil)
end

Auto.WriteBowlingRoomSyncInfo = function(writer, val)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Participants, Base.WriteComplexWrap(Auto.WriteBowlingParticipantInfo, "BowlingParticipantInfo", false), nil, "Participants", false, 0, nil)
end

Auto.WriteBowlingScoreInfo = function(writer, val)
	Base.WriteDict7Bit(writer, val.BowlingScoreDict, writer.WriteInt32, Base.WriteComplexWrap(Auto.WriteBowlingParticipantScoreInfo, "BowlingParticipantScoreInfo", false), nil, "BowlingScoreDict", false, 0)
	Base.WritePrimitive(writer, val.Winner, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SurrenderPid, writer.WriteUInt64, 0)
end

Auto.WriteBowlingSettleData = function(writer, val)
	Base.WritePrimitive(writer, val.Score, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteUInt32, 0)
end

Auto.WriteBowlingZoneInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 72, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentSubRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurn, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.ScoreInfo, Auto.WriteBowlingScoreInfo, "ScoreInfo", false)
	Base.WriteList7Bit(writer, val.BowlingPinSceneItemIdList, writer.WriteUInt64, 0, "BowlingPinSceneItemIdList", false, 0, nil)
	Base.WriteList7Bit(writer, val.BowlingBallSceneItemIdList, writer.WriteUInt64, 0, "BowlingBallSceneItemIdList", false, 0, nil)
	writer.WriteString(writer, val.ZoneSessionId, false, "BowlingZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WriteBoxAreaParams = function(writer, val)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WriteStruct(writer, val.Extents, Auto.WriteUXVector3, "Extents")
	Base.WriteStruct(writer, val.InversedRotation, Auto.WriteSerializeQuaternion, "InversedRotation")
end

Auto.WriteBuffLibraryEntryInfo = function(writer, val)
	Base.WritePrimitive(writer, val.EntryId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LibraryCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalDurationMs, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.ConsumedMs, writer.WriteInt64, 0)
	writer.WriteString(writer, val.SourceTag, true, "BuffLibraryEntryInfo.SourceTag", 0)
end

Auto.WriteBuffViewData = function(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Tier, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Permanent, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DestructibleId, writer.WriteUInt64, 0)
end

Auto.WriteBulletinInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt64, 0)
	writer.WriteString(writer, val.DefaultContent, false, "BulletinInfo.DefaultContent", 0)
	Base.WriteDict(writer, val.LocalizedContent, Base.WriteStringWrap(false, "LocalizedContent", 0), Base.WriteStringWrap(false, "LocalizedContent", 0), nil, "LocalizedContent", false, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StopTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Interval, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
end

Auto.WriteBuyFoodInfo = function(writer, val)
	Base.WritePrimitive(writer, val.RestaurantId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.FoodIdList, writer.WriteUInt32, 0, "FoodIdList", false, RpcLengthLimits.BuyFoodInfo_FoodIdList, nil)
	Base.WritePrimitive(writer, val.CompanionNpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Date, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NPCTreat, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MealTime, writer.WriteUInt32, 0)
end

Auto.WriteByteAngle = function(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteByte, 0)
end

Auto.WriteBytePayload = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteByte, 0)
end

Auto.WriteBytesPayload = function(writer, val)
	Base.WriteList7Bit(writer, val.V, writer.WriteByte, 0, "V", false, RpcLengthLimits.BytesPayload_V, nil)
end

Auto.WriteCanSeeTargetConditionData = function(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.Distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HalfAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UseHead, writer.WriteBoolean, false)
end

Auto.WriteCarShopParkingInfo = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleEntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CarshopId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
end

Auto.WriteCargoInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CargoId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.StartPos, Auto.WriteTruckPosInfo, "StartPos", false)
	Base.WritePrimitive(writer, val.Integrity, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsCargoNear, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
end

Auto.WriteCentripetalVelocityData = function(writer, val)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
end

Auto.WriteChallengeRecord = function(writer, val)
	Base.WritePrimitive(writer, val.ChallengeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HighestLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReceivedRewardLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BestScore, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CurrentScore, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CurrentRewardLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentIsNewRewardLevel, writer.WriteBoolean, false)
	Base.WriteDict(writer, val.BestStatisticalData, writer.WriteInt32, writer.WriteDouble, 0, "BestStatisticalData", false, 0)
	Base.WriteDict(writer, val.CurrentStatisticalData, writer.WriteInt32, writer.WriteDouble, 0, "CurrentStatisticalData", false, 0)
end

Auto.WriteChallengeResult = function(writer, val)
	Base.WriteComplex(writer, val.ChallengeRecord, Auto.WriteNewChallengeRecord, "ChallengeRecord", false)
	Base.WritePrimitive(writer, val.CurrentRewardLevel, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.RewardInfo, Auto.WriteRewardInfo, "RewardInfo", false)
end

Auto.WriteChangePlacedFurnitureInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PlacedInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsChangeParentNode, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ParentPlacedInstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
end

Auto.WriteChaosTagInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TagId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TagLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TagExp, writer.WriteUInt32, 0)
end

Auto.WriteCharacterBelongingItem = function(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Hp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteUInt32, 0)
end

Auto.WriteChargeClientInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.ChargedIds, writer.WriteUInt32, 0, "ChargedIds", false, 0, nil)
end

Auto.WriteChargeData = function(writer, val)
	Base.WritePrimitive(writer, val.CurrentCharges, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentPercentage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ChargePeriod, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxCharges, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Timestamp, writer.WriteDouble, 0)
end

Auto.WriteChargeDeliveryResult = function(writer, val)
	writer.WriteString(writer, val.SN, false, "ChargeDeliveryResult.SN", 0)
	writer.WriteString(writer, val.PayChannel, false, "ChargeDeliveryResult.PayChannel", 0)
	writer.WriteString(writer, val.ConsumeSN, false, "ChargeDeliveryResult.ConsumeSN", 0)
	Base.WritePrimitive(writer, val.ChargeId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.GoodsId, false, "ChargeDeliveryResult.GoodsId", 0)
	Base.WritePrimitive(writer, val.Gold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.FreeGold, writer.WriteDouble, 0)
	Base.WriteComplex(writer, val.FirstExtraRewardInfo, Auto.WriteRewardInfo, "FirstExtraRewardInfo", true)
end

Auto.WriteChaseParameters = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TargetType, 102, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxSpeed, writer.WriteSingle, 0)
	writer.WriteString(writer, val.chaseFormationName, false, "ChaseParameters.chaseFormationName", 0)
	Base.WritePrimitive(writer, val.enterChaseFormationDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.exitChaseFormationDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.targetSlowdownDistanceMaxThreshold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.targetSlowdownDistanceMinThreshold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.targetSlowdownSpeedThreshold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.throttleRatioWhenTargetSlowDown, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.vehicleRamMove, Auto.WriteVehicleRamMove, "vehicleRamMove")
	Base.WriteStruct(writer, val.vehicleBlockMove, Auto.WriteVehicleBlockMove, "vehicleBlockMove")
	Base.WritePrimitive(writer, val.enableDelayTarget, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.minClosetDistanceUpdateTargetTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.maxClosetDistanceUpdateTargetTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.straightLineDistanceInCloseDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.straightLineDistanceInPursue, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.useWatchDogLikeChase, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

Auto.WriteChatBubbleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GetTime, writer.WriteUInt32, 0)
end

Auto.WriteChatGroupClient = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Owner, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Members, writer.WriteUInt64, 0, "Members", false, 0, nil)
	writer.WriteString(writer, val.Name, true, "ChatGroupClient.Name", 0)
	Base.WritePrimitive(writer, val.RejectMsg, writer.WriteBoolean, false)
end

Auto.WriteChatHint = function(writer, val)
	Base.WritePrimitive(writer, val.FriendPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
end

Auto.WriteChatInfoList = function(writer, val)
	Base.WriteList(writer, val.ChatList, Base.WriteComplexWrap(Auto.WriteNpcChatItem, "NpcChatItem", false), nil, "ChatList", false, 0, nil)
	Base.WritePrimitive(writer, val.Gameplay, writer.WriteUInt32, 0)
end

Auto.WriteChatMessage = function(writer, val)
	Base.WritePrimitive(writer, val.MessageId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Channel, 10, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Receiver, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsAudio, writer.WriteBoolean, false)
	writer.WriteString(writer, val.Content, true, "ChatMessage.Content", 0)
	Base.WritePrimitive(writer, val.SystemMessageId, writer.WriteInt32, 0)
end

Auto.WriteChatMessagesBlob = function(writer, val)
	Base.WriteList7Bit(writer, val.Messages, Base.WriteComplexWrap(Auto.WriteChatMessage, "ChatMessage", false), nil, "Messages", false, 0, nil)
end

Auto.WriteChatWheelItem = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 133, 0), writer.WriteByte, 0)
end

Auto.WriteCheckAccountResult = function(writer, val)
	writer.WriteString(writer, val.unisdk_login_json, true, "CheckAccountResult.unisdk_login_json", 0)
	writer.WriteString(writer, val.Token, false, "CheckAccountResult.Token", 0)
	writer.WriteString(writer, val.UserName, true, "CheckAccountResult.UserName", 0)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NeedRealNameTip, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NeedRoleEnter, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RealNameVerified, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HostId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.code, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.subcode, writer.WriteInt32, 0)
	writer.WriteString(writer, val.msg, true, "CheckAccountResult.msg", 0)
end

Auto.WriteCheckAgentDistanceInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.Distance, writer.WriteInt32, 0, "Distance", false, 0, nil)
end

Auto.WriteCheckAnimStateConditionData = function(writer, val)
	Base.WritePrimitive(writer, val.NpcAnimState, writer.WriteInt32, 0)
end

Auto.WriteCheckPointAction = function(writer, val)
	Base.WritePrimitive(writer, val.wayPointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.opType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.duration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.aetherActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.conversationId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.dialogueSpeakers, Base.WriteStringWrap(true, "dialogueSpeakers", 0), nil, "dialogueSpeakers", true, 0, nil)
	Base.WriteList7Bit(writer, val.dialogueBindUnits, writer.WriteUInt64, 0, "dialogueBindUnits", true, 0, nil)
	Base.WritePrimitive(writer, val.wayLeaderDontWait, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.targetPace, 115, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.finalDirection, Auto.WriteUXVector3, "finalDirection")
	Base.WritePrimitive(writer, val.wayPointFacing, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.facingToUnit, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.gameplaySignal, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.actionSetStateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.startAnimTagId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.stopAnimTagId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.idlePOIId, writer.WriteUInt32, 0)
end

Auto.WriteCheckPointPathMoveCommandData = function(writer, val)
	Base.WriteList7Bit(writer, val.WayPoints, Base.WriteStructWrap(Auto.WriteUXVector3, "WayPoints"), nil, "WayPoints", false, 0, nil)
	Base.WriteList7Bit(writer, val.CheckPointActions, Base.WriteComplexWrap(Auto.WriteCheckPointAction, "CheckPointAction", false), nil, "CheckPointActions", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpecificMethod, 115, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartPace, 115, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.StartPaceDuration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AnimationSetId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.KeepMovingAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveActionGroupId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NotOnGround, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TryUseRootMotion, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteCheckerEQSResInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Res, writer.WriteBoolean, false)
end

Auto.WriteChefDimensionValue = function(writer, val)
	Base.WritePrimitive(writer, val.LastTickValue, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LastTickTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Rate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Limit, writer.WriteSingle, 0)
end

Auto.WriteChefDishScoreInfo = function(writer, val)
	Base.WritePrimitive(writer, val.StoveId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.RecipeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ProgressScore, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FireScore, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SeasoningScore, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IngredientScore, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FinalScore, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.NewUnlockedDimensions, writer.WriteInt32, 0, "NewUnlockedDimensions", false, 0, nil)
end

Auto.WriteChefGenerateOrderResult = function(writer, val)
	Base.WritePrimitive(writer, val.ItemSufficient, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.PredictRecipeSequence, writer.WriteUInt32, 0, "PredictRecipeSequence", false, 0, nil)
end

Auto.WriteChefIngredientProgress = function(writer, val)
	Base.WritePrimitive(writer, val.Progress, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LastTickTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PutTime, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.FireLevelDurations, writer.WriteByte, writer.WriteUInt32, 0, "FireLevelDurations", false, 0)
	Base.WriteComplex(writer, val.ProgressDimension, Auto.WriteChefDimensionValue, "ProgressDimension", false)
end

Auto.WriteChefManagementZoneInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.PredictRecipeSequence, writer.WriteUInt32, 0, "PredictRecipeSequence", false, 0, nil)
	Base.WriteList7Bit(writer, val.ChefInventory, Base.WriteComplexWrap(Auto.WritePlayerPackItem, "PlayerPackItem", false), nil, "ChefInventory", false, 0, nil)
	Base.WriteList7Bit(writer, val.RealOrders, Base.WriteComplexWrap(Auto.WriteChefRealOrderInfo, "ChefRealOrderInfo", true), nil, "RealOrders", true, 0, nil)
	Base.WriteComplex(writer, val.FinalSettlement, Auto.WriteChefOrderSettlement, "FinalSettlement", true)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 134, 0), writer.WriteByte, 0)
	Base.WriteDict7Bit(writer, val.Stove2Info, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteChefStoveInfo, "ChefStoveInfo", false), nil, "Stove2Info", false, 0)
	Base.WriteDict7Bit(writer, val.ChefNpcInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChefNpcInfo, "ChefNpcInfo", false), nil, "ChefNpcInfos", false, 0)
	writer.WriteString(writer, val.ZoneSessionId, false, "ChefManagementZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WriteChefNpcInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.WorkInfos, Base.WriteComplexWrap(Auto.WriteChefNpcWorkInfo, "ChefNpcWorkInfo", false), nil, "WorkInfos", false, 0, nil)
end

Auto.WriteChefNpcWorkInfo = function(writer, val)
	Base.WritePrimitive(writer, val.WorkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WorkTime, writer.WriteUInt32, 0)
end

Auto.WriteChefOrderRecipe = function(writer, val)
	Base.WritePrimitive(writer, val.RecipeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 135, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.FinalScore, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ServeTime, writer.WriteUInt32, 0)
end

Auto.WriteChefOrderSettlement = function(writer, val)
	Base.WritePrimitive(writer, val.Cost, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Income, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Profit, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
end

Auto.WriteChefParticipantInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.FoodPrepareQueue, writer.WriteUInt32, 0, "FoodPrepareQueue", true, 0, nil)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

Auto.WriteChefRealOrderInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.RecipeUniqueIds, writer.WriteUInt64, 0, "RecipeUniqueIds", false, 0, nil)
	Base.WriteDict7Bit(writer, val.Recipes, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteChefOrderRecipe, "ChefOrderRecipe", false), nil, "Recipes", false, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Satisfaction, writer.WriteSingle, 0)
end

Auto.WriteChefRecipeInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Unlock, writer.WriteBoolean, false)
end

Auto.WriteChefStoveInfo = function(writer, val)
	Base.WritePrimitive(writer, val.RecipeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.FireLevel, 68, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Leave, writer.WriteBoolean, false)
	Base.WriteDict7Bit(writer, val.Ingredient2Progress, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChefIngredientProgress, "ChefIngredientProgress", false), nil, "Ingredient2Progress", false, 0)
	Base.WriteDict7Bit(writer, val.Seasonings, writer.WriteUInt32, writer.WriteUInt32, 0, "Seasonings", false, 0)
	Base.WritePrimitive(writer, val.Temperature, writer.WriteSingle, 0)
	Base.WriteDict7Bit(writer, val.Dimensions, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteChefDimensionValue, "ChefDimensionValue", false), nil, "Dimensions", false, 0)
	Base.WriteDict7Bit(writer, val.DimensionOpCounts, writer.WriteByte, writer.WriteInt32, 0, "DimensionOpCounts", false, 0)
	Base.WritePrimitive(writer, val.TriggeringQte, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.QteStarted, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsOvercookFailed, writer.WriteBoolean, false)
end

Auto.WriteChefSubRecipeInfo = function(writer, val)
	Base.WriteList(writer, val.UnlockedDimensions, writer.WriteInt32, 0, "UnlockedDimensions", false, 0, nil)
	Base.WritePrimitive(writer, val.UnlockFailCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PityTriggerCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BestRank, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BestScore, writer.WriteSingle, 0)
	Base.WriteList(writer, val.ReceivedRewards, writer.WriteUInt32, 0, "ReceivedRewards", false, 0, nil)
end

Auto.WriteChefUnlockInfo = function(writer, val)
	Base.WriteDict7Bit(writer, val.RecipeDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChefRecipeInfo, "ChefRecipeInfo", false), nil, "RecipeDict", true, 0)
	Base.WriteDict7Bit(writer, val.SubRecipeDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChefSubRecipeInfo, "ChefSubRecipeInfo", false), nil, "SubRecipeDict", true, 0)
	Base.WritePrimitive(writer, val.ChefCollectionProgress, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.ReceivedCollectionRewards, writer.WriteInt32, 0, "ReceivedCollectionRewards", true, 0, nil)
end

Auto.WriteChefZoneInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 134, 0), writer.WriteByte, 0)
	Base.WriteDict7Bit(writer, val.Stove2Info, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteChefStoveInfo, "ChefStoveInfo", false), nil, "Stove2Info", false, 0)
	Base.WriteDict7Bit(writer, val.ChefNpcInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChefNpcInfo, "ChefNpcInfo", false), nil, "ChefNpcInfos", false, 0)
	writer.WriteString(writer, val.ZoneSessionId, false, "ChefZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WriteChineseChessFlipMove = function(writer, val)
	Base.WritePrimitive(writer, val.MoveIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlayerPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsFlip, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Col, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Row, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FromCol, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FromRow, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ToCol, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ToRow, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FlippedChessId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CapturedChessId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CapturedScore, writer.WriteInt32, 0)
end

Auto.WriteChineseChessFlipParticipantInfo = function(writer, val)
	Base.WritePrimitive(writer, val.IsRed, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

Auto.WriteChineseChessFlipScoreInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.Moves, Base.WriteComplexWrap(Auto.WriteChineseChessFlipMove, "ChineseChessFlipMove", false), nil, "Moves", false, 0, nil)
	Base.WritePrimitive(writer, val.CurrentMoveIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Winner, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.OverReason, 136, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PendingUndoFromPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PendingTieFromPid, writer.WriteUInt64, 0)
	Base.WriteDict7Bit(writer, val.UndoCountByPid, writer.WriteUInt64, writer.WriteUInt32, 0, "UndoCountByPid", false, 0)
	Base.WritePrimitive(writer, val.RedHP, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BlackHP, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.ChessIds, writer.WriteInt32, 0, "ChessIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.FlipIds, writer.WriteInt32, 0, "FlipIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.RevealedMask, writer.WriteBoolean, false, "RevealedMask", false, 0, nil)
end

Auto.WriteChineseChessFlipZoneInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 137, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurn, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.ScoreInfo, Auto.WriteChineseChessFlipScoreInfo, "ScoreInfo", false)
	writer.WriteString(writer, val.ZoneSessionId, false, "ChineseChessFlipZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WriteChineseChessMove = function(writer, val)
	Base.WritePrimitive(writer, val.MoveIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlayerPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.FromX, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FromY, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ToX, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ToY, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CapturedChessId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsCheck, writer.WriteBoolean, false)
end

Auto.WriteChineseChessParticipantInfo = function(writer, val)
	Base.WritePrimitive(writer, val.IsRed, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

Auto.WriteChineseChessScoreInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.Moves, Base.WriteComplexWrap(Auto.WriteChineseChessMove, "ChineseChessMove", false), nil, "Moves", false, 0, nil)
	Base.WritePrimitive(writer, val.CurrentMoveIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Winner, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.OverReason, 136, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PendingUndoFromPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PendingTieFromPid, writer.WriteUInt64, 0)
	Base.WriteDict7Bit(writer, val.UndoCountByPid, writer.WriteUInt64, writer.WriteUInt32, 0, "UndoCountByPid", false, 0)
end

Auto.WriteChineseChessZoneInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 137, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurn, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EndGameId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.ScoreInfo, Auto.WriteChineseChessScoreInfo, "ScoreInfo", false)
	writer.WriteString(writer, val.ZoneSessionId, false, "ChineseChessZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WriteCinemaMultiTicketInfo = function(writer, val)
	Base.WritePrimitive(writer, val.LocationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CinemaId, writer.WriteUInt32, 0)
end

Auto.WriteCinemaTicketInfo = function(writer, val)
	Base.WritePrimitive(writer, val.LocationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CinemaId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MovieId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CompanionNpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CinemaNpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InviteNpcId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsDate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CommentType, 138, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 139, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.IsTask, writer.WriteBoolean, false)
end

Auto.WriteClawDateClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.HideNpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FailTimes, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.FavorToyId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DateNpcId, writer.WriteUInt32, 0)
end

Auto.WriteClawSettlementInfo = function(writer, val)
	Base.WritePrimitive(writer, val.ClawToyId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Date, writer.WriteBoolean, false)
end

Auto.WriteClearWorldBattleOtherPlayer = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

Auto.WriteClientActionTarget = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 140, 0), writer.WriteByte, 0)
end

Auto.WriteClientActivityInfo = function(writer, val)
	Base.WriteComplex(writer, val.BaseActivityInfo, Auto.WriteCommonActivityInfo, "BaseActivityInfo", false)
	Base.WriteComplex(writer, val.ActivityData, Auto.WriteActivityDataBase, "ActivityData", false)
end

Auto.WriteClientAetherBusStopEvent = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LineId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StopId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.EventType, 141, 0), writer.WriteByte, 0)
end

Auto.WriteClientAgentBubbleConfig = function(writer, val)
	Base.WritePrimitive(writer, val.BubbleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TriggerPolicy, 142, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Priority, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Cooldown, writer.WriteSingle, 0)
end

Auto.WriteClientAgentBubbleConfigs = function(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.SensorRange, Auto.WriteClientAgentBubbleSensorRange, "SensorRange")
	Base.WriteList7Bit(writer, val.Configs, Base.WriteStructWrap(Auto.WriteClientAgentBubbleConfig, "Configs"), nil, "Configs", false, 0, nil)
end

Auto.WriteClientAgentBubbleSensorRange = function(writer, val)
	Base.WritePrimitive(writer, val.HeightDiff, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RadiusSq, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ExpandRadiusSq, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LeftAngleBorder, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RightAngleBorder, writer.WriteSingle, 0)
end

Auto.WriteClientAreaCounterAttackInfo = function(writer, val)
	Base.WritePrimitive(writer, val.FactionId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.AreaIds, writer.WriteUInt32, 0, "AreaIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.EventIds, writer.WriteUInt32, 0, "EventIds", false, 0, nil)
end

Auto.WriteClientAreaEncroachmentInfo = function(writer, val)
	Base.WritePrimitive(writer, val.AreaId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AttackerFactionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DefenderFactionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 143, 0), writer.WriteByte, 0)
end

Auto.WriteClientBoardingInfo = function(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
	Base.WriteStruct(writer, val.PositionOffset, Auto.WriteUXVector3, "PositionOffset")
	Base.WriteStruct(writer, val.RotationOffset, Auto.WriteUXVector3, "RotationOffset")
	Base.WritePrimitive(writer, val.CanBeEjected, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UseSpecificAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
end

Auto.WriteClientClubTaskInfo = function(writer, val)
	Base.WritePrimitive(writer, val.WeeklyTime, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.TaskDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteClubTaskInfo, "ClubTaskInfo", false), nil, "TaskDict", false, 0)
end

Auto.WriteClientCommandData = function(writer, val)
	writer.WriteString(writer, val.Name, false, "ClientCommandData.Name", 0)
	writer.WriteString(writer, val.Sign, false, "ClientCommandData.Sign", 0)
	writer.WriteString(writer, val.Comment, true, "ClientCommandData.Comment", 0)
end

Auto.WriteClientCompetitionSeasonInfo = function(writer, val)
	Base.WriteComplex(writer, val.CommonSeasonInfo, Auto.WriteCommonCompetitionSeasonInfo, "CommonSeasonInfo", false)
	Base.WriteComplex(writer, val.SeasonInfo, Auto.WriteCompetitionSeasonInfo, "SeasonInfo", true)
end

Auto.WriteClientCrowdInitData = function(writer, val)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentPersonaId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UrbanDiversityConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DesiredSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt16, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TargetLocationReason, 144, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.FashionSuitId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
end

Auto.WriteClientCustomData = function(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.ParametersDouble, writer.WriteDouble, 0, "ParametersDouble", true, 0, nil)
	Base.WriteList7Bit(writer, val.ParametersULong, writer.WriteUInt64, 0, "ParametersULong", true, 0, nil)
	Base.WriteList7Bit(writer, val.ParametersUInt, writer.WriteUInt32, 0, "ParametersUInt", true, 0, nil)
	Base.WriteList7Bit(writer, val.ParametersVector3, Base.WriteStructWrap(Auto.WriteUXVector3, "ParametersVector3"), nil, "ParametersVector3", true, 0, nil)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteDouble, 0)
end

Auto.WriteClientCustomRoomBriefInfo = function(writer, val)
	Base.WritePrimitive(writer, val.RoomId, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.Name, false, "ClientCustomRoomBriefInfo.Name", RpcLengthLimits.ClientCustomRoomBriefInfo_Name)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 145, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Status, 146, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.HasPassword, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OwnerPid, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.OwnerName, false, "ClientCustomRoomBriefInfo.OwnerName", RpcLengthLimits.ClientCustomRoomBriefInfo_OwnerName)
	Base.WritePrimitive(writer, val.CurrentMembers, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MaxMembers, writer.WriteInt32, 0)
	Base.WriteDict7Bit(writer, val.Tags, writer.WriteInt16, writer.WriteUInt32, 0, "Tags", false, RpcLengthLimits.ClientCustomRoomBriefInfo_Tags)
	Base.WritePrimitive(writer, val.CurrentStatusOverTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FriendOnly, writer.WriteBoolean, false)
end

Auto.WriteClientCustomRoomInfo = function(writer, val)
	Base.WritePrimitive(writer, val.RoomId, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.Name, false, "ClientCustomRoomInfo.Name", 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 145, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Status, 146, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentStatusOverTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HasPassword, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OwnerPid, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.Members, Base.WriteComplexWrap(Auto.WriteClientCustomRoomMemberInfo, "ClientCustomRoomMemberInfo", false), nil, "Members", false, 0, nil)
	Base.WritePrimitive(writer, val.MaxMembers, writer.WriteInt32, 0)
	Base.WriteDict(writer, val.Tags, writer.WriteInt16, writer.WriteUInt32, 0, "Tags", false, 0)
	Base.WritePrimitive(writer, val.OwnerLeaveDisband, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.PartyInfo, Auto.WritePartyRoomInfo, "PartyInfo", true)
end

Auto.WriteClientCustomRoomMemberInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.PlayerInfo, Auto.WritePlayerBasicInfoVO, "PlayerInfo", false)
end

Auto.WriteClientDangerAreaData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WriteStruct(writer, val.Extents, Auto.WriteUXVector3, "Extents")
	Base.WritePrimitive(writer, val.Duration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RemoveRadiusSq, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsOBB, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.OBBExtents, Auto.WriteUXVector3, "OBBExtents")
	Base.WriteStruct(writer, val.InverseRotation, Auto.WriteUXVector3, "InverseRotation")
	Base.WritePrimitive(writer, val.Radius, writer.WriteSingle, 0)
end

Auto.WriteClientDetectEventData = function(writer, val)
	Base.WritePrimitive(writer, val.detectorPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.detectedPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.detectValue, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

Auto.WriteClientDeviceInfo = function(writer, val)
	writer.WriteString(writer, val.DeviceModel, true, "ClientDeviceInfo.DeviceModel", RpcLengthLimits.ClientDeviceInfo_DeviceModel)
	writer.WriteString(writer, val.OsName, true, "ClientDeviceInfo.OsName", RpcLengthLimits.ClientDeviceInfo_OsName)
	writer.WriteString(writer, val.OsVersion, true, "ClientDeviceInfo.OsVersion", RpcLengthLimits.ClientDeviceInfo_OsVersion)
	writer.WriteString(writer, val.Udid, true, "ClientDeviceInfo.Udid", RpcLengthLimits.ClientDeviceInfo_Udid)
	writer.WriteString(writer, val.AppVersion, true, "ClientDeviceInfo.AppVersion", RpcLengthLimits.ClientDeviceInfo_AppVersion)
	Base.WritePrimitive(writer, val.DeviceHeight, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DeviceWidth, writer.WriteInt32, 0)
	writer.WriteString(writer, val.Network, true, "ClientDeviceInfo.Network", RpcLengthLimits.ClientDeviceInfo_Network)
	writer.WriteString(writer, val.Ipv6, true, "ClientDeviceInfo.Ipv6", RpcLengthLimits.ClientDeviceInfo_Ipv6)
	writer.WriteString(writer, val.AppChannel, true, "ClientDeviceInfo.AppChannel", RpcLengthLimits.ClientDeviceInfo_AppChannel)
	writer.WriteString(writer, val.Transid, true, "ClientDeviceInfo.Transid", RpcLengthLimits.ClientDeviceInfo_Transid)
	writer.WriteString(writer, val.UnisdkDeviceId, true, "ClientDeviceInfo.UnisdkDeviceId", RpcLengthLimits.ClientDeviceInfo_UnisdkDeviceId)
	Base.WritePrimitive(writer, val.IsEmulator, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsRoot, writer.WriteBoolean, false)
	writer.WriteString(writer, val.Imei, true, "ClientDeviceInfo.Imei", RpcLengthLimits.ClientDeviceInfo_Imei)
	writer.WriteString(writer, val.Location, true, "ClientDeviceInfo.Location", RpcLengthLimits.ClientDeviceInfo_Location)
	writer.WriteString(writer, val.CountryCode, true, "ClientDeviceInfo.CountryCode", RpcLengthLimits.ClientDeviceInfo_CountryCode)
	writer.WriteString(writer, val.LocalIp, true, "ClientDeviceInfo.LocalIp", RpcLengthLimits.ClientDeviceInfo_LocalIp)
	writer.WriteString(writer, val.OldAccountId, true, "ClientDeviceInfo.OldAccountId", RpcLengthLimits.ClientDeviceInfo_OldAccountId)
	writer.WriteString(writer, val.MacAddr, true, "ClientDeviceInfo.MacAddr", RpcLengthLimits.ClientDeviceInfo_MacAddr)
	writer.WriteString(writer, val.GpuName, true, "ClientDeviceInfo.GpuName", RpcLengthLimits.ClientDeviceInfo_GpuName)
	writer.WriteString(writer, val.CpuName, true, "ClientDeviceInfo.CpuName", RpcLengthLimits.ClientDeviceInfo_CpuName)
	writer.WriteString(writer, val.HardDriveSn, true, "ClientDeviceInfo.HardDriveSn", RpcLengthLimits.ClientDeviceInfo_HardDriveSn)
	Base.WritePrimitive(writer, val.TotalMemory, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.ResolutionHeight, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ResolutionWidth, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.FullScreen, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DeviceLevel, 48, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.DisplayLevel, writer.WriteInt32, 0)
	writer.WriteString(writer, val.Joystick, true, "ClientDeviceInfo.Joystick", RpcLengthLimits.ClientDeviceInfo_Joystick)
	Base.WritePrimitive(writer, val.characterQualityLevel, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.vehicleQualityLevel, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.link_device_level, writer.WriteInt32, 0)
	Base.WriteList(writer, val.bundles, writer.WriteUInt32, 0, "bundles", false, RpcLengthLimits.ClientDeviceInfo_bundles, nil)
end

Auto.WriteClientFactionInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.EncroachmentInfos, Base.WriteComplexWrap(Auto.WriteClientAreaEncroachmentInfo, "ClientAreaEncroachmentInfo", false), nil, "EncroachmentInfos", false, 0, nil)
	Base.WriteList7Bit(writer, val.FilledFactionArea, writer.WriteUInt32, 0, "FilledFactionArea", false, 0, nil)
end

Auto.WriteClientFinishedTruckOrderView = function(writer, val)
	Base.WritePrimitive(writer, val.TodayTotalIncome, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TodayRewardPoint, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TotalActivityPointRewards, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.FinishedOrders, Base.WriteComplexWrap(Auto.WriteTruckJobOrderWrap, "TruckJobOrderWrap", false), nil, "FinishedOrders", false, 0, nil)
end

Auto.WriteClientFormationMember = function(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Offset, Auto.WriteUXVector3, "Offset")
end

Auto.WriteClientFormationStructureUpdate = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
	Base.WritePrimitive(writer, Base.CheckEnum(val.TraceType, 115, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Members, Base.WriteComplexWrap(Auto.WriteClientFormationMember, "ClientFormationMember", false), nil, "Members", false, 0, nil)
end

Auto.WriteClientIntersectionDebugData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ZoneIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PeriodCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CurrentPeriodIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NextPeriodIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CurrentState, 147, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteList7Bit(writer, val.LaneHandlesOpen, writer.WriteInt32, 0, "LaneHandlesOpen", false, 0, nil)
	Base.WriteList7Bit(writer, val.LaneVehicleCountDebugData, Base.WriteComplexWrap(Auto.WriteClientLaneVehicleCountDebugData, "ClientLaneVehicleCountDebugData", false), nil, "LaneVehicleCountDebugData", false, 0, nil)
end

Auto.WriteClientLaneVehicleCountDebugData = function(writer, val)
	Base.WritePrimitive(writer, val.PedLane, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
end

Auto.WriteClientMetroNpcInitData = function(writer, val)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MetroInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MetroCarriageIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
end

Auto.WriteClientNpcChatData = function(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.InviteChatList, Base.WriteComplexWrap(Auto.WriteNpcChatItem, "NpcChatItem", false), nil, "InviteChatList", false, 0, nil)
	Base.WriteList7Bit(writer, val.DialogChatList, Base.WriteComplexWrap(Auto.WriteNpcChatItem, "NpcChatItem", false), nil, "DialogChatList", false, 0, nil)
	Base.WriteDict7Bit(writer, val.NpcChatListDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChatInfoList, "ChatInfoList", false), nil, "NpcChatListDict", false, 0)
	Base.WriteDict7Bit(writer, val.DialogChatListDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChatInfoList, "ChatInfoList", false), nil, "DialogChatListDict", false, 0)
end

Auto.WriteClientNpcDebugDensityStatistics = function(writer, val)
	Base.WritePrimitive(writer, val.PedArea, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NonScaleExceptedPedNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ExceptedPedNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActualPedNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ExceptedStaticNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActualStaticNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActualVehicleNpcNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActualMetroNpcNum, writer.WriteSingle, 0)
end

Auto.WriteClientNpcGroupChatData = function(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.InviteChatList, Base.WriteComplexWrap(Auto.WriteNpcChatItem, "NpcChatItem", false), nil, "InviteChatList", false, 0, nil)
	Base.WriteList7Bit(writer, val.DialogChatList, Base.WriteComplexWrap(Auto.WriteNpcChatItem, "NpcChatItem", false), nil, "DialogChatList", false, 0, nil)
	Base.WriteList7Bit(writer, val.Members, writer.WriteUInt32, 0, "Members", false, 0, nil)
	Base.WriteDict7Bit(writer, val.NpcChatListDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChatInfoList, "ChatInfoList", false), nil, "NpcChatListDict", false, 0)
	Base.WriteDict7Bit(writer, val.DialogChatListDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChatInfoList, "ChatInfoList", false), nil, "DialogChatListDict", false, 0)
end

Auto.WriteClientNpcPlayAnimationData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteDouble, 0)
end

Auto.WriteClientNpcPoiActionData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PlayPoiSpeed, writer.WriteSingle, 0)
end

Auto.WriteClientNpcTeleportData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteClientPedData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.ActionId, writer.WriteInt32, 0)
end

Auto.WriteClientPlayerRankingSummary = function(writer, val)
	Base.WritePrimitive(writer, val.RankConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.TierDetail, Auto.WriteTierDetail, "TierDetail")
end

Auto.WriteClientQualitySetting = function(writer, val)
	writer.WriteString(writer, val.setting, false, "ClientQualitySetting.setting", RpcLengthLimits.ClientQualitySetting_setting)
end

Auto.WriteClientRankWarZoneInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CurrentZoneId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PendingZoneId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PendingEffectCycle, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SwitchedCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxSwitch, writer.WriteUInt32, 0)
end

Auto.WriteClientRankingEntry = function(writer, val)
	Base.WritePrimitive(writer, val.PlayerId, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.Name, false, "ClientRankingEntry.Name", 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.TierDetail, Auto.WriteTierDetail, "TierDetail")
	Base.WritePrimitive(writer, val.IsRobot, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
end

Auto.WriteClientRankingTopResult = function(writer, val)
	Base.WritePrimitive(writer, val.RankConfigId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Slot, Auto.WriteClientSubRankSlot, "Slot")
	Base.WriteList7Bit(writer, val.Entries, Base.WriteComplexWrap(Auto.WriteClientRankingEntry, "ClientRankingEntry", false), nil, "Entries", false, RpcLengthLimits.ClientRankingTopResult_Entries, nil)
	Base.WritePrimitive(writer, val.NextCycleTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MyZoneId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SeasonEndTime, writer.WriteUInt32, 0)
end

Auto.WriteClientStaticNpcInitData = function(writer, val)
	Base.WritePrimitive(writer, val.StaticNpcInfoId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentPersonaId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UrbanDiversityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IgnoreAllStim, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TaskRelated, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableHack, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NpcPid, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.AgentSyncClientInfo, Auto.WriteAgentSyncClientInfo, "AgentSyncClientInfo", true)
	Base.WritePrimitive(writer, val.LookAtDecisionRulesId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ForceGo, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SourceType, 148, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.MartialArtistGossipConfigID, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
end

Auto.WriteClientStaticVehicleDebugData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SourceType, 149, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ColorPartId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsResident, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ForceShow, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SpawnNpc, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.VehicleSpoonId, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.FineIdList, writer.WriteUInt32, 0, "FineIdList", false, 0, nil)
	Base.WritePrimitive(writer, val.GridIndexX, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.GridIndexY, writer.WriteInt32, 0)
end

Auto.WriteClientStaticVehicleInitData = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ColorPartId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DamageStatusId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Timestamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.NotDrive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RotationX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationW, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.Parts, Base.WriteStructWrap(Auto.WriteVehicleClientPart, "Parts"), nil, "Parts", true, 0, nil)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DustRatio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
end

Auto.WriteClientSubRankSlot = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Dim, 150, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt32, 0)
end

Auto.WriteClientTeamInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TeamId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LeaderPid, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Members, Base.WriteComplexWrap(Auto.WritePlayerBasicInfoVO, "PlayerBasicInfoVO", false), nil, "Members", false, 0, nil)
	Base.WriteComplex(writer, val.Setting, Auto.WriteTeamSetting, "Setting", false)
	Base.WriteList7Bit(writer, val.MemberOrder, writer.WriteUInt64, 0, "MemberOrder", false, 0, nil)
end

Auto.WriteClientTeamMemberSyncInfo = function(writer, val)
	Base.WritePrimitive(writer, val.MemberOrder, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.VehicleTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.PlayerBasicInfo, Auto.WritePlayerBasicInfoVO, "PlayerBasicInfo", true)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.SpiritWearFashionInfo, Auto.WriteOtherPlayerSpiritWearFashionsInfo, "SpiritWearFashionInfo", true)
	Base.WriteComplex(writer, val.LinkPlanningBoardMemberInfo, Auto.WriteLinkPlanningBoardMemberInfo, "LinkPlanningBoardMemberInfo", true)
	Base.WritePrimitive(writer, val.InMatchGame, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.TrackGPS, Auto.WriteTeamTrackGPS, "TrackGPS", true)
end

Auto.WriteClientTierDetailInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TierConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentBigTierId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentSmallTierId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteUInt32, 0)
end

Auto.WriteClientTrafficIntersectionInitInfo = function(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ZoneIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CurrentState, 147, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentPeriodIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NextPeriodIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.RailPeriodIndex, writer.WriteByte, 0)
end

Auto.WriteClientTrafficIntersectionPeriodUpdateInfo = function(writer, val)
	Base.WritePrimitive(writer, val.IntersectionIndex, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CurrentState, 147, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentPeriodIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NextPeriodIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.RailPeriodIndex, writer.WriteByte, 0)
end

Auto.WriteClientTruckOrderView = function(writer, val)
	Base.WriteList7Bit(writer, val.Orders, Base.WriteComplexWrap(Auto.WriteTruckJobOrderWrap, "TruckJobOrderWrap", false), nil, "Orders", false, 0, nil)
	Base.WritePrimitive(writer, val.RewardPointSum, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CustomerSatisfactionAverage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CurrentOrderId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TruckGuideClicked, writer.WriteBoolean, false)
	Base.WriteDict7Bit(writer, val.EventIdToAgent, writer.WriteUInt32, writer.WriteUInt64, 0, "EventIdToAgent", false, 0)
	Base.WritePrimitive(writer, val.AutoAccept, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DefaultVehicleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalIncome, writer.WriteInt32, 0)
end

Auto.WriteClientTuiteComment = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PublishTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsCollect, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsLike, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LikeCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ViewCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CommentCount, writer.WriteInt32, 0)
	writer.WriteString(writer, val.Content, true, "ClientTuiteComment.Content", 0)
	Base.WriteStruct(writer, val.RoleInfo, Auto.WriteClientTuiteRoleInfo, "RoleInfo")
end

Auto.WriteClientTuiteInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PublishTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsCollect, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsLike, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsFollow, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HasTimeline, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.TimelineData, Auto.WriteTuiteTimelineData, "TimelineData", true)
	Base.WritePrimitive(writer, val.LikeCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ViewCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CommentCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DropId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.OssKey, true, "ClientTuiteInfo.OssKey", 0)
end

Auto.WriteClientTuiteRoleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ShortPid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RoleId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Name, true, "ClientTuiteRoleInfo.Name", 0)
	Base.WritePrimitive(writer, val.AvatarId, writer.WriteUInt32, 0)
end

Auto.WriteClientVehicleBuffData = function(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.BuffConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EffectChangeEndTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteDouble, 0)
end

Auto.WriteClientVehicleData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.ActionId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DistanceAlongLane, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NextLaneHandle, writer.WriteInt32, 0)
end

Auto.WriteClientVehicleDebugData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.VehicleLogicType, false, "ClientVehicleDebugData.VehicleLogicType", 0)
	writer.WriteString(writer, val.CurrentVehicleStatus, false, "ClientVehicleDebugData.CurrentVehicleStatus", 0)
	Base.WritePrimitive(writer, val.CurrentLaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NextLaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DistanceToAvoid, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NextVehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NextMergingVehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NextSplittingVehicleId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.FindIdList, writer.WriteUInt32, 0, "FindIdList", false, 0, nil)
end

Auto.WriteClientVehicleInitData = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleColorPartId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleLightState, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DistanceAlongLane, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NextVehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Timestamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ControlType, 151, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DustRatio, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.Parts, Base.WriteStructWrap(Auto.WriteVehicleClientPart, "Parts"), nil, "Parts", true, 0, nil)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RandomFraction, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
end

Auto.WriteClientVehicleLaneChangeData = function(writer, val)
	Base.WriteStruct(writer, val.VehicleLaneData, Auto.WriteClientVehicleLaneData, "VehicleLaneData")
	Base.WritePrimitive(writer, val.LaneHandleInitial, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LaneHandleFinal, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BeginDistanceAloneLaneInitial, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BeginDistanceAloneLaneFinal, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EndDistanceAlongLaneFinal, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DistanceBetweenLanes, writer.WriteSingle, 0)
end

Auto.WriteClientVehicleLaneData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DistanceAlongLane, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Status, writer.WriteByte, 0)
end

Auto.WriteClientVehicleLaneDebugData = function(writer, val)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.LaneLength, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpaceAvailable, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NumVehicleOnLane, writer.WriteInt32, 0)
end

Auto.WriteClientVehicleNpcInitData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BindVehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
end

Auto.WriteClientVehiclePartStatus = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PartType, 86, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.OpenOrClose, writer.WriteBoolean, false)
end

Auto.WriteClientZoneGraphPathPoint = function(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteByteAngle, "Facing")
end

Auto.WriteCloseVehicleDoorCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Distances, Base.WriteStructWrap(Auto.WriteRangeMoveType, "Distances"), nil, "Distances", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteClubCustomJob = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Name, true, "ClubCustomJob.Name", 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.JobType, 26, 0), writer.WriteByte, 0)
end

Auto.WriteClubHonor = function(writer, val)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Param1, writer.WriteDouble, 0)
end

Auto.WriteClubHonorEvent = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.EventType, 152, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Parameters, Base.WriteComplexWrap(Auto.WriteMailParameter, "MailParameter", false), nil, "Parameters", false, 0, nil)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
end

Auto.WriteClubInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.Name, true, "ClubInfo.Name", 0)
	Base.WritePrimitive(writer, val.IconCfgId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Declaration, true, "ClubInfo.Declaration", 0)
	Base.WritePrimitive(writer, val.Activity, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Owner, writer.WriteUInt64, 0)
	Base.WriteDict7Bit(writer, val.ClubHonors, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteClubHonor, "ClubHonor", false), nil, "ClubHonors", false, 0)
	Base.WriteList7Bit(writer, val.Members, Base.WriteComplexWrap(Auto.WriteClubMember, "ClubMember", false), nil, "Members", false, 0, nil)
	Base.WriteComplex(writer, val.Setting, Auto.WriteClubSetting, "Setting", false)
	Base.WriteList7Bit(writer, val.WeeklyContributionList, Base.WriteComplexWrap(Auto.WriteClubWeeklyContribution, "ClubWeeklyContribution", false), nil, "WeeklyContributionList", false, 0, nil)
	Base.WriteList7Bit(writer, val.SeasonalContributionList, Base.WriteComplexWrap(Auto.WriteClubSeasonalContribution, "ClubSeasonalContribution", false), nil, "SeasonalContributionList", false, 0, nil)
	Base.WriteList7Bit(writer, val.CustomJobList, Base.WriteComplexWrap(Auto.WriteClubCustomJob, "ClubCustomJob", false), nil, "CustomJobList", false, 0, nil)
	Base.WriteList7Bit(writer, val.SystemJobList, Base.WriteComplexWrap(Auto.WriteClubCustomJob, "ClubCustomJob", false), nil, "SystemJobList", false, 0, nil)
end

Auto.WriteClubMember = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LastLoginTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastLogoutTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ClubJob, 26, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.JoinTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Activity, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.JobId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.JobChangeCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastJobChangeTime, writer.WriteUInt32, 0)
end

Auto.WriteClubMemberContribution = function(writer, val)
	Base.WritePrimitive(writer, val.Activity, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.TaskDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteClubTaskInfo, "ClubTaskInfo", false), nil, "TaskDict", false, 0)
	Base.WriteList7Bit(writer, val.RewardGotIds, writer.WriteUInt32, 0, "RewardGotIds", false, 0, nil)
end

Auto.WriteClubMemberStarData = function(writer, val)
	Base.WriteDict7Bit(writer, val.StarDataDict, writer.WriteUInt32, writer.WriteDouble, 0, "StarDataDict", false, 0)
end

Auto.WriteClubSeasonalContribution = function(writer, val)
	Base.WritePrimitive(writer, val.SeasonId, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.MemberContributions, writer.WriteUInt64, writer.WriteInt32, 0, "MemberContributions", false, 0)
	Base.WritePrimitive(writer, val.SeasonlyActivity, writer.WriteUInt32, 0)
end

Auto.WriteClubSetting = function(writer, val)
	Base.WritePrimitive(writer, val.AutoJoin, writer.WriteBoolean, false)
end

Auto.WriteClubTaskInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

Auto.WriteClubWeeklyContribution = function(writer, val)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.MemberContributions, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteClubMemberContribution, "ClubMemberContribution", false), nil, "MemberContributions", false, 0)
	Base.WritePrimitive(writer, val.SettledTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WeeklyActivity, writer.WriteUInt32, 0)
end

Auto.WriteCollectibleGadgetData = function(writer, val)
	Base.WritePrimitive(writer, val.LootConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ItemUniqueId, writer.WriteUInt64, 0)
end

Auto.WriteCollectiblePlacedComponent = function(writer, val)
	Base.WriteComplex(writer, val.PlacedInfo, Auto.WriteCollectiblePlacedInfo, "PlacedInfo", true)
end

Auto.WriteCollectiblePlacedInfo = function(writer, val)
	Base.WriteComplex(writer, val.Furniture, Auto.WriteFurniturePlacedInfo, "Furniture", true)
end

Auto.WriteCollectionBookData = function(writer, val)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.AffixList, writer.WriteUInt32, 0, "AffixList", false, 0, nil)
	Base.WritePrimitive(writer, val.DyeColorCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DyeEffectCount, writer.WriteUInt32, 0)
end

Auto.WriteCommonActivityInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
end

Auto.WriteCommonCommandData = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteCommonCompetitionSeasonInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
end

Auto.WriteCompetitionSeasonChallengeInfo = function(writer, val)
	Base.WritePrimitive(writer, val.ChallengeCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HistoryHighestStars, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LastStars, writer.WriteInt32, 0)
end

Auto.WriteCompetitionSeasonGamePlayInfo = function(writer, val)
	Base.WritePrimitive(writer, val.GamePlayCfgId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ChallengeDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteCompetitionSeasonChallengeInfo, "CompetitionSeasonChallengeInfo", false), nil, "ChallengeDict", false, 0)
	Base.WritePrimitive(writer, val.Stars, writer.WriteInt32, 0)
end

Auto.WriteCompetitionSeasonInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.GameplayDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteCompetitionSeasonGamePlayInfo, "CompetitionSeasonGamePlayInfo", false), nil, "GameplayDict", false, 0)
	Base.WriteList(writer, val.AwardList, writer.WriteUInt32, 0, "AwardList", false, 0, nil)
	Base.WritePrimitive(writer, val.IsFinish, writer.WriteBoolean, false)
end

Auto.WriteCompoundResultInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CompoundId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.Rewards, Auto.WriteRewardInfo, "Rewards", false)
	Base.WritePrimitive(writer, val.RemainingCount, writer.WriteInt32, 0)
end

Auto.WriteCompoundStationClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
end

Auto.WriteCompoundUseClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.UsedCount, writer.WriteUInt32, 0)
end

Auto.WriteComputerDetailInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FirstOpenTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.DeleteFiles, writer.WriteUInt32, 0, "DeleteFiles", false, 0, nil)
	Base.WriteList(writer, val.DeleteEmails, writer.WriteUInt32, 0, "DeleteEmails", false, 0, nil)
end

Auto.WriteComputerEmail = function(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRead, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
end

Auto.WriteComputerFile = function(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRead, writer.WriteBoolean, false)
end

Auto.WriteComputerUnlockInfo = function(writer, val)
	Base.WriteDict7Bit(writer, val.UnlockEmails, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteComputerEmail, "ComputerEmail", false), nil, "UnlockEmails", true, 0)
	Base.WriteDict7Bit(writer, val.UnlockFiles, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteComputerFile, "ComputerFile", false), nil, "UnlockFiles", true, 0)
	Base.WriteDict7Bit(writer, val.ComputerInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteComputerDetailInfo, "ComputerDetailInfo", false), nil, "ComputerInfos", true, 0)
end

Auto.WriteConfirmRpcCommand = function(writer, val)
	Base.WritePrimitive(writer, val.ConfirmRpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

Auto.WriteConfirmRpcServerCommand = function(writer, val)
	Base.WritePrimitive(writer, val.ConfirmRpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

Auto.WriteControlFlowData = function(writer, val)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

Auto.WriteControlFlowDataBoolean = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

Auto.WriteControlFlowDataCustom = function(writer, val)
	Base.WriteComplex(writer, val.V, Auto.WriteControlFlowData, "V", false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 153, 0), writer.WriteByte, 0)
end

Auto.WriteControlFlowDataDebug = function(writer, val)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.CurrentNodeIds, writer.WriteInt32, 0, "CurrentNodeIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.CompleteNodeIds, writer.WriteInt32, 0, "CompleteNodeIds", false, 0, nil)
	Base.WriteDict7Bit(writer, val.ErrorNodeIds, writer.WriteInt32, Base.WriteStringWrap(false, "ErrorNodeIds", 0), nil, "ErrorNodeIds", false, 0)
	Base.WriteDict7Bit(writer, val.ResultNodeIds, writer.WriteInt32, Base.WriteStringWrap(false, "ResultNodeIds", 0), nil, "ResultNodeIds", false, 0)
end

Auto.WriteControlFlowDataDouble = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

Auto.WriteControlFlowDataEnemyGroup = function(writer, val)
	Base.WriteList7Bit(writer, val.EnemyIds, writer.WriteUInt64, 0, "EnemyIds", false, RpcLengthLimits.ControlFlowDataEnemyGroup_EnemyIds, nil)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

Auto.WriteControlFlowDataFloat = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

Auto.WriteControlFlowDataInteger = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

Auto.WriteControlFlowDataString = function(writer, val)
	writer.WriteString(writer, val.V, false, "ControlFlowDataString.V", RpcLengthLimits.ControlFlowDataString_V)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

Auto.WriteControlFlowDataUInteger = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

Auto.WriteControlFlowDataUlong = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

Auto.WriteControlFlowDataUnit = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

Auto.WriteControlFlowDataVector = function(writer, val)
	Base.WriteStruct(writer, val.V, Auto.WriteUXVector3, "V")
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

Auto.WriteControlFlowDataVehicle = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

Auto.WriteControlFlowDataWayPoint = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

Auto.WriteControlFlowDebugSpoonData = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpoonType, 154, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.taskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.eventId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.raidMd5, Base.WriteStringWrap(false, "raidMd5", 0), nil, "raidMd5", false, 0, nil)
	writer.WriteString(writer, val.md5, true, "ControlFlowDebugSpoonData.md5", 0)
	writer.WriteString(writer, val.eventMd5, true, "ControlFlowDebugSpoonData.eventMd5", 0)
	Base.WritePrimitive(writer, val.plateUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.instanceId, writer.WriteUInt64, 0)
end

Auto.WriteControlFlowDestructible = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

Auto.WriteCreateClientNodeServerCommand = function(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Type, false, "CreateClientNodeServerCommand.Type", 0)
	writer.WriteString(writer, val.StoryboardGuid, false, "CreateClientNodeServerCommand.StoryboardGuid", 0)
	Base.WritePrimitive(writer, val.Sync, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

Auto.WriteCreateRoleInitInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Sex, 155, 0), writer.WriteByte, 0)
	writer.WriteString(writer, val.Name, false, "CreateRoleInitInfo.Name", RpcLengthLimits.CreateRoleInitInfo_Name)
	Base.WriteList7Bit(writer, val.Config, writer.WriteByte, 0, "Config", false, RpcLengthLimits.CreateRoleInitInfo_Config, nil)
	Base.WritePrimitive(writer, val.UseSystemName, writer.WriteBoolean, false)
end

Auto.WriteCreationEnterLeave = function(writer, val)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CreationId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.EventType, 156, 0), writer.WriteByte, 0)
end

Auto.WriteCreationHitData = function(writer, val)
	Base.WritePrimitive(writer, val.CreationId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetDestructible, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ShieldDefendIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HurtStiffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StiffTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HurtEffectId, writer.WriteUInt32, 0)
end

Auto.WriteCreationMoveData = function(writer, val)
	Base.WritePrimitive(writer, val.CreationId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
end

Auto.WriteCreditInfo = function(writer, val)
	Base.WriteDict(writer, val.CreditByType, writer.WriteUInt32, writer.WriteUInt32, 0, "CreditByType", false, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ClaimedLevelRewards, writer.WriteUInt32, writer.WriteBoolean, false, "ClaimedLevelRewards", false, 0)
end

Auto.WriteCruiseParameters = function(writer, val)
	Base.WriteList7Bit(writer, val.TargetPointList, Base.WriteStructWrap(Auto.WriteUXVector3, "TargetPointList"), nil, "TargetPointList", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CruiseType, 104, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.configFlags, writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.pathFindFlags, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TargetType, 102, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.checkClose, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.checkFar, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.closeRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.farawayRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.accelerateScale, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.decelerateScale, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.minSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.maxSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ArrivalDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AdaptSpeedToTargetDistance, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

Auto.WriteCubeAreaInfo = function(writer, val)
	Base.WriteStruct(writer, val.CenterPos, Auto.WriteUXVector3, "CenterPos")
	Base.WritePrimitive(writer, val.XMagnitude, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ZMagnitude, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.YSize, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.XNormalized, Auto.WriteUXVector3, "XNormalized")
	Base.WriteStruct(writer, val.ZNormalized, Auto.WriteUXVector3, "ZNormalized")
end

Auto.WriteCubeCoord = function(writer, val)
	Base.WritePrimitive(writer, val.q, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.r, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.s, writer.WriteInt32, 0)
end

Auto.WriteCustomCommonData = function(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt32, 0)
	writer.WriteString(writer, val.StringData, false, "CustomCommonData.StringData", RpcLengthLimits.CustomCommonData_StringData)
	Base.WriteBuffer(writer, val.BinaryData, "BinaryData", false, RpcLengthLimits.CustomCommonData_BinaryData, nil)
end

Auto.WriteCustomLinkCreateParam = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Tag, 22, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.HouseOwnerPid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ColletionRoomId, writer.WriteUInt32, 0)
end

Auto.WriteCustomRoomCreateParam = function(writer, val)
	writer.WriteString(writer, val.Name, false, "CustomRoomCreateParam.Name", RpcLengthLimits.CustomRoomCreateParam_Name)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 145, 1), writer.WriteByte, 1)
	writer.WriteString(writer, val.Password, true, "CustomRoomCreateParam.Password", RpcLengthLimits.CustomRoomCreateParam_Password)
	Base.WritePrimitive(writer, val.MaxMembers, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OwnerLeaveDisband, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FriendOnly, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.PartyInfo, Auto.WritePartySettingInfo, "PartyInfo", true)
end

Auto.WriteCustomRoomSearchParam = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 145, 1), writer.WriteByte, 1)
	Base.WriteDict7Bit(writer, val.TagFilters, writer.WriteInt16, writer.WriteUInt32, 0, "TagFilters", false, RpcLengthLimits.CustomRoomSearchParam_TagFilters)
	Base.WritePrimitive(writer, val.Page, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PageSize, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RequestAll, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FriendOnly, writer.WriteBoolean, false)
end

Auto.WriteCustomRoomSettingParam = function(writer, val)
	writer.WriteString(writer, val.Name, true, "CustomRoomSettingParam.Name", RpcLengthLimits.CustomRoomSettingParam_Name)
	writer.WriteString(writer, val.Password, true, "CustomRoomSettingParam.Password", RpcLengthLimits.CustomRoomSettingParam_Password)
	Base.WriteComplex(writer, val.PartySetting, Auto.WritePartyRoomSettingParam, "PartySetting", true)
end

Auto.WriteDSBuffData = function(writer, val)
	Base.WritePrimitive(writer, val.BuffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteDouble, 0)
end

Auto.WriteDSDamageData = function(writer, val)
	Base.WriteList7Bit(writer, val.SpiritDatas, Base.WriteComplexWrap(Auto.WriteDSSpiritDamageData, "DSSpiritDamageData", false), nil, "SpiritDatas", false, 0, nil)
	Base.WriteList7Bit(writer, val.ElementDatas, Base.WriteComplexWrap(Auto.WriteDSElementDamageData, "DSElementDamageData", false), nil, "ElementDatas", false, 0, nil)
end

Auto.WriteDSElementDamageData = function(writer, val)
	Base.WritePrimitive(writer, val.ElementId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Damage, writer.WriteSingle, 0)
end

Auto.WriteDSSkillHitDamageData = function(writer, val)
	Base.WritePrimitive(writer, val.HitTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Damage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsCritical, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Error, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Attrs, writer.WriteSingle, 0, "Attrs", false, 0, nil)
	Base.WriteList7Bit(writer, val.Buffs, writer.WriteUInt32, 0, "Buffs", false, 0, nil)
end

Auto.WriteDSSkillHitDataList = function(writer, val)
	Base.WritePrimitive(writer, val.SKillId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.SkillDamageList, Base.WriteComplexWrap(Auto.WriteDSSkillHitDamageData, "DSSkillHitDamageData", false), nil, "SkillDamageList", false, 0, nil)
end

Auto.WriteDSSpiritDamageData = function(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalDamage, writer.WriteSingle, 0)
	Base.WriteDict7Bit(writer, val.SkillDamageRecords, writer.WriteInt32, Base.WriteComplexWrap(Auto.WriteDSSkillHitDataList, "DSSkillHitDataList", false), nil, "SkillDamageRecords", false, 0)
	Base.WriteDict7Bit(writer, val.BuffRecords, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteDSBuffData, "DSBuffData", false), nil, "BuffRecords", false, 0)
end

Auto.WriteDailyGamePlayRankData = function(writer, val)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.GamePlayRankListDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteInspireHubGamePlayRankList, "InspireHubGamePlayRankList", false), nil, "GamePlayRankListDict", false, 0)
end

Auto.WriteDailyGamePlayRecommendData = function(writer, val)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.GamePlayList, Base.WriteComplexWrap(Auto.WriteInspireHubGamePlayInfo, "InspireHubGamePlayInfo", false), nil, "GamePlayList", false, 0, nil)
end

Auto.WriteDamageData = function(writer, val)
	Base.WritePrimitive(writer, val.SourceAmount, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.FromType, 157, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.SourceTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CreationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BuffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpecialEffects, writer.WriteInt16, 0)
	Base.WriteStruct(writer, val.ClientHitPosition, Auto.WriteUXVector3, "ClientHitPosition")
	Base.WritePrimitive(writer, val.ElementType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HitIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PoiseBasicValue, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HpDecreased, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Amount, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ShieldDecreased, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ShieldIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ShieldId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsHeadShoot, writer.WriteBoolean, false)
end

Auto.WriteDancePlayResult = function(writer, val)
	Base.WritePrimitive(writer, val.StayElapsedTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlayElapsedTime, writer.WriteUInt32, 0)
end

Auto.WriteDartParticipantInfo = function(writer, val)
	Base.WritePrimitive(writer, val.DartId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

Auto.WriteDartScoreInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurn, writer.WriteInt32, 0)
	Base.WriteDict7Bit(writer, val.ParticipantScoreDic, writer.WriteInt32, writer.WriteInt32, 0, "ParticipantScoreDic", true, 0)
	Base.WriteDict7Bit(writer, val.ParticipantRoundTotalScoreDic, writer.WriteInt32, writer.WriteInt32, 0, "ParticipantRoundTotalScoreDic", true, 0)
	Base.WritePrimitive(writer, val.CurrentTurnTotalScore, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.CurrentTurnTotalPos, Base.WriteStructWrap(Auto.WriteUXVector3, "CurrentTurnTotalPos"), nil, "CurrentTurnTotalPos", false, 0, nil)
	Base.WriteList7Bit(writer, val.CurrentTurnTotalScoreLs, writer.WriteInt32, 0, "CurrentTurnTotalScoreLs", false, 0, nil)
	Base.WritePrimitive(writer, val.CurrentScoreIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CurrentScore, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.CurrentScorePos, Auto.WriteUXVector3, "CurrentScorePos")
	Base.WritePrimitive(writer, val.Winner, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsPlayerLeave, writer.WriteBoolean, false)
end

Auto.WriteDartSettleData = function(writer, val)
	Base.WritePrimitive(writer, val.Score, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 95, 0), writer.WriteByte, 0)
end

Auto.WriteDartZoneInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 95, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurn, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.ScoreInfo, Auto.WriteDartScoreInfo, "ScoreInfo", false)
	writer.WriteString(writer, val.ZoneSessionId, false, "DartZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WriteDataLayerIndic = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Mode, 158, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SceneBaseIndic, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.UniverseBaseIndic, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RaidBaseIndic, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.ResourceIndices, writer.WriteInt32, 0, "ResourceIndices", true, 0, nil)
end

Auto.WriteDebugBattleElementData = function(writer, val)
	Base.WritePrimitive(writer, val.ElementId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Damage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DamageMin, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DamageMax, writer.WriteSingle, 0)
end

Auto.WriteDebugBattleSpiritData = function(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalDamage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FightStateTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.FightBeginTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.ActiveTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.ActiveBeginTime, writer.WriteDouble, 0)
	Base.WriteDict7Bit(writer, val.SkillDamages, writer.WriteUInt32, writer.WriteSingle, 0, "SkillDamages", false, 0)
	Base.WriteDict7Bit(writer, val.SkillCounts, writer.WriteUInt32, writer.WriteInt32, 0, "SkillCounts", false, 0)
	Base.WriteDict7Bit(writer, val.SkillDamageCounts, writer.WriteUInt32, writer.WriteInt32, 0, "SkillDamageCounts", false, 0)
	Base.WriteDict7Bit(writer, val.SkillDamagesMin, writer.WriteUInt32, writer.WriteSingle, 0, "SkillDamagesMin", false, 0)
	Base.WriteDict7Bit(writer, val.SkillDamagesMax, writer.WriteUInt32, writer.WriteSingle, 0, "SkillDamagesMax", false, 0)
	Base.WriteDict7Bit(writer, val.ExtraBuffDamages, writer.WriteUInt32, writer.WriteSingle, 0, "ExtraBuffDamages", false, 0)
	Base.WriteDict7Bit(writer, val.BuffTimes, writer.WriteUInt32, writer.WriteDouble, 0, "BuffTimes", false, 0)
	Base.WriteDict7Bit(writer, val.BuffBeginTimes, writer.WriteUInt32, writer.WriteDouble, 0, "BuffBeginTimes", false, 0)
	Base.WriteDict7Bit(writer, val.BuffRefCounts, writer.WriteUInt32, writer.WriteInt32, 0, "BuffRefCounts", false, 0)
end

Auto.WriteDebugBattleStatistics = function(writer, val)
	Base.WritePrimitive(writer, val.Now, writer.WriteDouble, 0)
	Base.WriteList7Bit(writer, val.Spirits, Base.WriteComplexWrap(Auto.WriteDebugBattleSpiritData, "DebugBattleSpiritData", false), nil, "Spirits", false, 0, nil)
	Base.WriteList7Bit(writer, val.Elements, Base.WriteComplexWrap(Auto.WriteDebugBattleElementData, "DebugBattleElementData", false), nil, "Elements", false, 0, nil)
end

Auto.WriteDebugFileDescription = function(writer, val)
	writer.WriteString(writer, val.FullPath, true, "DebugFileDescription.FullPath", 0)
	writer.WriteString(writer, val.Name, true, "DebugFileDescription.Name", 0)
	Base.WritePrimitive(writer, val.IsDirectory, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Size, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WriteTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AccessTime, writer.WriteUInt32, 0)
end

Auto.WriteDebugFileResult = function(writer, val)
	Base.WriteComplex(writer, val.PersistentDataPath, Auto.WriteDebugFileDescription, "PersistentDataPath", false)
	Base.WriteComplex(writer, val.TemporaryCachePath, Auto.WriteDebugFileDescription, "TemporaryCachePath", false)
	Base.WriteComplex(writer, val.StreamingAssetsPath, Auto.WriteDebugFileDescription, "StreamingAssetsPath", false)
	Base.WriteComplex(writer, val.DataPath, Auto.WriteDebugFileDescription, "DataPath", false)
	Base.WriteComplex(writer, val.ConsoleLogPath, Auto.WriteDebugFileDescription, "ConsoleLogPath", false)
	Base.WriteComplex(writer, val.VirtualFileSystem, Auto.WriteDebugFileDescription, "VirtualFileSystem", false)
end

Auto.WriteDebugNpcBvbSelectPokemonData = function(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.q, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.r, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.s, writer.WriteInt32, 0)
end

Auto.WriteDeleteClientNodeCommand = function(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

Auto.WriteDeliveryGadgetInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rot, Auto.WriteUXVector3, "Rot")
end

Auto.WriteDeriveCreationData = function(writer, val)
	Base.WritePrimitive(writer, val.CreationId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DeriveId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

Auto.WriteDestructibleBrokenInfo = function(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Stage, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.BrokenType, 159, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
end

Auto.WriteDestructibleGridAOIIncrease = function(writer, val)
	Base.WriteStruct(writer, val.PlayerStandardIndex, Auto.WriteGridIndex, "PlayerStandardIndex")
	Base.WriteList7Bit(writer, val.addInfos, Base.WriteComplexWrap(Auto.WriteDestructibleInfo, "DestructibleInfo", true), nil, "addInfos", true, 0, nil)
	Base.WriteList7Bit(writer, val.indexList, Base.WriteStructWrap(Auto.WriteGridIndex, "indexList"), nil, "indexList", true, 0, nil)
	Base.WriteList7Bit(writer, val.addUniqueIds, writer.WriteUInt64, 0, "addUniqueIds", true, 0, nil)
	Base.WriteList7Bit(writer, val.removeIds, writer.WriteUInt64, 0, "removeIds", true, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.reason, 160, 0), writer.WriteByte, 0)
end

Auto.WriteDestructibleHitTypeList = function(writer, val)
	Base.WriteList7Bit(writer, val.HitTypes, writer.WriteByte, 0, "HitTypes", false, RpcLengthLimits.DestructibleHitTypeList_HitTypes, nil)
end

Auto.WriteDestructibleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NavId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ForceLod0, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Hp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 161, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BreakStage, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.OccupantInfos, Base.WriteStructWrap(Auto.WriteSceneDeviceOccupantInfo, "OccupantInfos"), nil, "OccupantInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.DropWeaponId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.EffectIds, writer.WriteInt32, 0, "EffectIds", true, 0, nil)
	Base.WritePrimitive(writer, val.NoSleep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.SkillInfo, Auto.WriteSkillDestructibleInfo, "SkillInfo", true)
end

Auto.WriteDestructibleSyncBinInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.HostPlayerID, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LocalTime, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.CompressSceneItemData, writer.WriteByte, 0, "CompressSceneItemData", true, RpcLengthLimits.DestructibleSyncBinInfo_CompressSceneItemData, val.CompressSceneItemDataLength)
end

Auto.WriteDestructionBindCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.SceneItemInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MovementMethod, 115, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteDestructionUnBindCommandData = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteDialogAreaInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.VertexPoints, Base.WriteStructWrap(Auto.WriteUXVector3, "VertexPoints"), nil, "VertexPoints", true, 0, nil)
	Base.WriteStruct(writer, val.CenterPos, Auto.WriteUXVector3, "CenterPos")
	Base.WritePrimitive(writer, val.SphereRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.XMagnitude, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.YMagnitude, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ZMagnitude, writer.WriteSingle, 0)
end

Auto.WriteDialogParameter = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 162, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NpcTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcInstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.AgentPosition, Auto.WriteUXVector3, "AgentPosition")
	Base.WritePrimitive(writer, val.BlackContinue, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FromTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FromEventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FromClient, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DialogCameraSpawnId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpoonNodeId, writer.WriteInt32, 0)
	Base.WriteDict7Bit(writer, val.Speaker2NpcInstanceId, Base.WriteStringWrap(false, "Speaker2NpcInstanceId", RpcLengthLimits.DialogParameter_Speaker2NpcInstanceId_String), writer.WriteUInt64, 0, "Speaker2NpcInstanceId", false, RpcLengthLimits.DialogParameter_Speaker2NpcInstanceId)
	Base.WritePrimitive(writer, val.DialogPriority, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StopWhenTaskEnd, writer.WriteBoolean, false)
end

Auto.WriteDiceAction = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Command, 163, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.IntParams, writer.WriteInt32, 0, "IntParams", false, 0, nil)
	Base.WritePrimitive(writer, val.BadgeId, writer.WriteUInt32, 0)
end

Auto.WriteDiceGameEndInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Winner, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Drops, writer.WriteUInt32, 0, "Drops", true, 0, nil)
	Base.WritePrimitive(writer, val.PlayerAFinalScore, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PlayerBFinalScore, writer.WriteInt32, 0)
end

Auto.WriteDiceParticipantInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.BadgeIds, writer.WriteUInt32, 0, "BadgeIds", true, 0, nil)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

Auto.WriteDiceRoundActions = function(writer, val)
	Base.WritePrimitive(writer, val.TargetPlayer, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Actions, Base.WriteStructWrap(Auto.WriteDiceAction, "Actions"), nil, "Actions", true, 0, nil)
end

Auto.WriteDiceRoundSettleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Round, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PlayerAScore, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PlayerBScore, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RoundScore, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsGameEnd, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Winner, writer.WriteInt32, 0)
end

Auto.WriteDiceScoreInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurn, writer.WriteInt32, 0)
	Base.WriteDict7Bit(writer, val.ParticipantScoreDic, writer.WriteInt32, writer.WriteInt32, 0, "ParticipantScoreDic", true, 0)
	Base.WritePrimitive(writer, val.CurrentTurnScore, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Winner, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.CurrentDiceValues, writer.WriteInt32, 0, "CurrentDiceValues", true, 0, nil)
	Base.WriteList7Bit(writer, val.SettledDiceValues, writer.WriteInt32, 0, "SettledDiceValues", true, 0, nil)
	Base.WritePrimitive(writer, val.IsBust, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CurrentThrowTimes, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HasExtraRound, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OnExtraRound, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Phase, 164, 0), writer.WriteByte, 0)
end

Auto.WriteDiceZoneInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameMode, 165, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 89, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Difficulty, 166, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurn, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TargetScore, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MaxRound, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.ScoreInfo, Auto.WriteDiceScoreInfo, "ScoreInfo", false)
	writer.WriteString(writer, val.ZoneSessionId, false, "DiceZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WriteDirectLocationDetectEventData = function(writer, val)
	Base.WritePrimitive(writer, val.EnemyId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DetectEventId, writer.WriteUInt32, 0)
end

Auto.WriteDisableBadgeInfos = function(writer, val)
	Base.WriteDict(writer, val.DisableBadgeInfoList, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteDisableBadgeReasons, "DisableBadgeReasons", false), nil, "DisableBadgeInfoList", false, 0)
end

Auto.WriteDisableBadgeReasons = function(writer, val)
	Base.WriteList(writer, val.ReasonList, writer.WriteInt32, 0, "ReasonList", false, 0, nil)
end

Auto.WriteDisableClientNodeCommand = function(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

Auto.WriteDiscardOperationInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurnPlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsRichiing, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DiscardingLastDraw, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.Tile, Auto.WriteTile, "Tile")
	Base.WritePrimitive(writer, val.RemainTurnTime, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Zhenting, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.Operations, Base.WriteStructWrap(Auto.WriteOutTurnOperation, "Operations"), nil, "Operations", false, 0, nil)
	Base.WriteList7Bit(writer, val.HandTiles, Base.WriteStructWrap(Auto.WriteTile, "HandTiles"), nil, "HandTiles", false, 0, nil)
	Base.WriteList7Bit(writer, val.Rivers, Base.WriteStructWrap(Auto.WriteRiverData, "Rivers"), nil, "Rivers", false, 0, nil)
end

Auto.WriteDiscardTileInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsRichiing, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DiscardingLastDraw, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.Tile, Auto.WriteTile, "Tile")
	Base.WritePrimitive(writer, val.RemainTurnTime, writer.WriteInt32, 0)
end

Auto.WriteDivinerChatRecord = function(writer, val)
	writer.WriteString(writer, val.PlayerMsg, false, "DivinerChatRecord.PlayerMsg", 0)
	writer.WriteString(writer, val.CustomerMsg, false, "DivinerChatRecord.CustomerMsg", 0)
end

Auto.WriteDivinerCustomerInfo = function(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AgentCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DemandId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PersonalityId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.AgentName, false, "DivinerCustomerInfo.AgentName", 0)
	writer.WriteString(writer, val.SessionId, false, "DivinerCustomerInfo.SessionId", 0)
	Base.WritePrimitive(writer, val.Attitude, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BranchId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Persuasion, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Target, false, "DivinerCustomerInfo.Target", 0)
	Base.WritePrimitive(writer, val.Success_Persuasion, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Endings, false, "DivinerCustomerInfo.Endings", 0)
	Base.WritePrimitive(writer, val.Stage, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsInGame, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Faction, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AppealTimeEnd, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PersuadeTimeEnd, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndReason, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Result, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Clues, writer.WriteUInt32, 0, "Clues", false, 0, nil)
	Base.WritePrimitive(writer, val.EventType, writer.WriteInt32, 0)
	writer.WriteString(writer, val.EventDesc, false, "DivinerCustomerInfo.EventDesc", 0)
	Base.WritePrimitive(writer, val.Patience, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.TriggeredMilestones, Base.WriteStringWrap(false, "TriggeredMilestones", 0), nil, "TriggeredMilestones", false, 0, nil)
	Base.WriteList7Bit(writer, val.ChatRecords, Base.WriteStructWrap(Auto.WriteDivinerChatRecord, "ChatRecords"), nil, "ChatRecords", false, 0, nil)
	Base.WritePrimitive(writer, val.ChatRecordsBytes, writer.WriteInt32, 0)
end

Auto.WriteDivinerLiveChatNpcChatInfo = function(writer, val)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.NpcNickname, true, "DivinerLiveChatNpcChatInfo.NpcNickname", 0)
	Base.WritePrimitive(writer, val.NpcType, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Message, true, "DivinerLiveChatNpcChatInfo.Message", 0)
	Base.WritePrimitive(writer, val.ActionType, writer.WriteUInt32, 0)
end

Auto.WriteDivinerPersuasionResult = function(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Stage, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Result, writer.WriteInt32, 0)
	writer.WriteString(writer, val.Msg, false, "DivinerPersuasionResult.Msg", 0)
	Base.WriteList7Bit(writer, val.MsgSegments, Base.WriteStringWrap(true, "MsgSegments", 0), nil, "MsgSegments", true, 0, nil)
	Base.WritePrimitive(writer, val.ClueId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Attitude, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Persuasion, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndReason, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EventType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Patience, writer.WriteInt32, 0)
end

Auto.WriteDoorClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.OpenAngle, writer.WriteSingle, 0)
end

Auto.WriteDoorModuleSyncInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.LockState, 167, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ProximityState, 168, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ProximityStartTime, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.ClientInfos, Base.WriteComplexWrap(Auto.WriteDoorClientInfo, "DoorClientInfo", false), nil, "ClientInfos", false, 0, nil)
end

Auto.WriteDoublePayload = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteDouble, 0)
end

Auto.WriteDrawTileInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DrawPlayerIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Tile, Auto.WriteTile, "Tile")
	Base.WritePrimitive(writer, val.RemainTurnTime, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Zhenting, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.Operations, Base.WriteStructWrap(Auto.WriteInTurnOperation, "Operations"), nil, "Operations", false, 0, nil)
	Base.WriteStruct(writer, val.MahjongSetData, Auto.WriteMahjongSetData, "MahjongSetData")
end

Auto.WriteDrillShelfCell = function(writer, val)
	Base.WritePrimitive(writer, val.Row, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Col, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reward, 169, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Drilled, writer.WriteBoolean, false)
end

Auto.WriteDrillShelfSyncInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Row, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Col, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DrillTimes, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Cells, Base.WriteComplexWrap(Auto.WriteDrillShelfCell, "DrillShelfCell", false), nil, "Cells", false, 0, nil)
end

Auto.WriteDrivingBehaviorRecord = function(writer, val)
	Base.WritePrimitive(writer, val.TimeStamp, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.RotationX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationW, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
	Base.WriteStruct(writer, val.Velocity, Auto.WriteUXVector3, "Velocity")
	Base.WriteStruct(writer, val.AngVelocity, Auto.WriteUXVector3, "AngVelocity")
	Base.WritePrimitive(writer, val.SteerInput, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ThrottleInput, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BrakeInput, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HandbrakeInput, writer.WriteSingle, 0)
end

Auto.WriteDrivingBehaviorRecords = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ControlType, 170, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Records, Base.WriteComplexWrap(Auto.WriteDrivingBehaviorRecord, "DrivingBehaviorRecord", false), nil, "Records", false, RpcLengthLimits.DrivingBehaviorRecords_Records, nil)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
end

Auto.WriteDropBelongingData = function(writer, val)
	Base.WritePrimitive(writer, val.BelongingId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OwnerId, writer.WriteUInt64, 0)
end

Auto.WriteDropLimitInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FinishTime, writer.WriteUInt32, 0)
end

Auto.WriteDynamicDestructibleData = function(writer, val)
	Base.WritePrimitive(writer, val.SceneItemCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.LivingTime, writer.WriteSingle, 0)
end

Auto.WriteDynamicDestructibleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CreateAgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MergeAgentInstanceId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.VehicleInfo, Auto.WriteVehicleDestructibleInfo, "VehicleInfo", true)
	Base.WriteComplex(writer, val.AdherePlatformInfo, Auto.WriteAdhereMovingPlatformInfo, "AdherePlatformInfo", true)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NavId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ForceLod0, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Hp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 161, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BreakStage, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.OccupantInfos, Base.WriteStructWrap(Auto.WriteSceneDeviceOccupantInfo, "OccupantInfos"), nil, "OccupantInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.DropWeaponId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.EffectIds, writer.WriteInt32, 0, "EffectIds", true, 0, nil)
	Base.WritePrimitive(writer, val.NoSleep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.SkillInfo, Auto.WriteSkillDestructibleInfo, "SkillInfo", true)
end

Auto.WriteDynamicGoFullInfo = function(writer, val)
	Base.WritePrimitive(writer, val.id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.navIndex, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.position, Auto.WriteUXVector3, "position")
	Base.WriteStruct(writer, val.angles, Auto.WriteUXVector3, "angles")
	Base.WritePrimitive(writer, val.isRegular, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.scale, Auto.WriteUXVector3, "scale")
	writer.WriteString(writer, val.prefabPath, false, "DynamicGoFullInfo.prefabPath", 0)
	Base.WritePrimitive(writer, val.isStatic, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.blockSize, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.isDefaultInactive, writer.WriteBoolean, false)
end

Auto.WriteDynamicPlateInfo = function(writer, val)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GraphId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WriteDict7Bit(writer, val.GadgetDic, writer.WriteInt32, writer.WriteUInt64, 0, "GadgetDic", true, 0)
	Base.WriteDict7Bit(writer, val.DestructibleDic, writer.WriteInt32, writer.WriteUInt64, 0, "DestructibleDic", true, 0)
	Base.WriteDict7Bit(writer, val.AgentDic, writer.WriteInt32, writer.WriteInt32, 0, "AgentDic", true, 0)
	Base.WriteDict7Bit(writer, val.VehicleDic, writer.WriteInt32, writer.WriteInt32, 0, "VehicleDic", true, 0)
	Base.WriteDict7Bit(writer, val.DynamicAgentDic, writer.WriteInt32, writer.WriteUInt64, 0, "DynamicAgentDic", true, 0)
	Base.WriteDict7Bit(writer, val.DynamicVehicleDic, writer.WriteInt32, writer.WriteUInt64, 0, "DynamicVehicleDic", true, 0)
	Base.WriteDict7Bit(writer, val.StaticNpcDic, writer.WriteInt32, writer.WriteInt32, 0, "StaticNpcDic", true, 0)
	Base.WriteDict7Bit(writer, val.RoomDic, writer.WriteInt32, writer.WriteInt32, 0, "RoomDic", true, 0)
	Base.WritePrimitive(writer, val.FavorNpcActivityId, writer.WriteUInt32, 0)
end

Auto.WriteECSStimInfo = function(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DMOverrideId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ECSResponseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StimDirectionId, writer.WriteInt32, 0)
end

Auto.WriteEQSPosInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

Auto.WriteEcsArchetypeInfo = function(writer, val)
	writer.WriteString(writer, val.Key, true, "EcsArchetypeInfo.Key", 0)
	Base.WritePrimitive(writer, val.EntityCount, writer.WriteInt32, 0)
	Base.WriteList(writer, val.ComponentTypes, Base.WriteStringWrap(true, "ComponentTypes", 0), nil, "ComponentTypes", true, 0, nil)
end

Auto.WriteEcsComponentInfo = function(writer, val)
	writer.WriteString(writer, val.TypeName, true, "EcsComponentInfo.TypeName", 0)
	Base.WritePrimitive(writer, val.Category, writer.WriteInt32, 0)
end

Auto.WriteEcsEntityDetail = function(writer, val)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Version, writer.WriteInt32, 0)
	Base.WriteList(writer, val.Components, Base.WriteComplexWrap(Auto.WriteEcsComponentInfo, "EcsComponentInfo", true), nil, "Components", true, 0, nil)
end

Auto.WriteEcsEntityInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Version, writer.WriteInt32, 0)
end

Auto.WriteEcsWorldInfo = function(writer, val)
	writer.WriteString(writer, val.Name, true, "EcsWorldInfo.Name", 0)
	Base.WritePrimitive(writer, val.EntityCount, writer.WriteInt32, 0)
end

Auto.WriteEdictDebugInfo = function(writer, val)
	Base.WritePrimitive(writer, val.isShort, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ownerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.giveTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.canGiveTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.needRemove, writer.WriteBoolean, false)
end

Auto.WriteEffectSyncData = function(writer, val)
	Base.WriteList7Bit(writer, val.Bytes, writer.WriteByte, 0, "Bytes", false, RpcLengthLimits.EffectSyncData_Bytes, nil)
end

Auto.WriteEggGameSettleData = function(writer, val)
	Base.WritePrimitive(writer, val.PassCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsInGame, writer.WriteBoolean, false)
end

Auto.WriteEmojiData = function(writer, val)
	writer.WriteString(writer, val.Id, false, "EmojiData.Id", RpcLengthLimits.EmojiData_Id)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

Auto.WriteEmptyPayload = function(writer, val)
end

Auto.WriteEnableClientNodeCommand = function(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Observables, Base.WriteComplexWrap(Auto.WriteNamedPayload, "NamedPayload", true), nil, "Observables", true, 0, nil)
	Base.WriteList7Bit(writer, val.Replicables, Base.WriteComplexWrap(Auto.WriteNamedPayload, "NamedPayload", true), nil, "Replicables", true, 0, nil)
	Base.WriteList7Bit(writer, val.SyncReplicables, Base.WriteComplexWrap(Auto.WriteNamedPayload, "NamedPayload", true), nil, "SyncReplicables", true, 0, nil)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

Auto.WriteEnchantPreviewInfo = function(writer, val)
	Base.WritePrimitive(writer, val.WeaponInstanceId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.NewSlots, Base.WriteComplexWrap(Auto.WriteWeaponEnchantSlotData, "WeaponEnchantSlotData", false), nil, "NewSlots", false, 0, nil)
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SlotIndex, writer.WriteInt32, 0)
end

Auto.WriteEndItemDropInfo = function(writer, val)
	Base.WritePrimitive(writer, val.enemyInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.bindItemsIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.itemRotation, Auto.WriteUXVector3, "itemRotation")
	Base.WriteStruct(writer, val.itemPosition, Auto.WriteUXVector3, "itemPosition")
end

Auto.WriteEnemyDieInfo = function(writer, val)
	Base.WritePrimitive(writer, val.HasDieAnimation, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HasDieEffect, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DieEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DelayDestroyDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LastHitHurtEffect, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DeadlySkillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Killer, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.HasPlayedDeathSkill, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.WeaponDropDestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DieType, 171, 0), writer.WriteInt16, 0)
	Base.WritePrimitive(writer, val.WeaponId, writer.WriteUInt32, 0)
end

Auto.WriteEnemyItemDropInfo = function(writer, val)
	Base.WritePrimitive(writer, val.BindItemsIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, Base.CheckEnum(val.DropState, 172, 0), writer.WriteByte, 0)
end

Auto.WriteEnemyMoveFinishData = function(writer, val)
	Base.WritePrimitive(writer, val.EnemyId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.IsFailure, writer.WriteBoolean, false)
end

Auto.WriteEnemyStandInfo = function(writer, val)
	Base.WritePrimitive(writer, val.EnemyId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CircleNum, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsArrived, writer.WriteBoolean, false)
end

Auto.WriteEnemyWeaponState = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsHoldingWeapon, writer.WriteBoolean, false)
end

Auto.WriteEnterGameData = function(writer, val)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.Token, Auto.WriteTokenInfo, "Token", false)
end

Auto.WriteEnterSceneInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PlayerSessionId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.SceneSpoonNames, Base.WriteStringWrap(true, "SceneSpoonNames", 0), nil, "SceneSpoonNames", true, 0, nil)
	Base.WriteList7Bit(writer, val.SceneSpoonMd5s, Base.WriteStringWrap(true, "SceneSpoonMd5s", 0), nil, "SceneSpoonMd5s", true, 0, nil)
	Base.WriteList7Bit(writer, val.Spirits, Base.WriteStructWrap(Auto.WriteSpiritInitData, "Spirits"), nil, "Spirits", false, 0, nil)
	Base.WriteStruct(writer, val.GridInfo, Auto.WriteServerSimpleGridInfo, "GridInfo")
	Base.WritePrimitive(writer, val.MatchGameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SwitchShowId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsSwitchSpiritShow, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UniverseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SectorControlId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.SectorControlIds, writer.WriteUInt32, 0, "SectorControlIds", true, 0, nil)
	Base.WritePrimitive(writer, val.DynamicLayerId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.LoadingType, Auto.WriteLoadingTypeInfo, "LoadingType", false)
	Base.WriteComplex(writer, val.LinkSimpleInfo, Auto.WriteLinkSimpleInfo, "LinkSimpleInfo", false)
	Base.WriteList7Bit(writer, val.DataLayerIndices, Base.WriteComplexWrap(Auto.WriteDataLayerIndic, "DataLayerIndic", false), nil, "DataLayerIndices", false, 0, nil)
	Base.WritePrimitive(writer, val.Seamless, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.CollectionRoomLoadData, Auto.WritePlayerCollectionRoomInfo, "CollectionRoomLoadData", true)
	Base.WriteComplex(writer, val.HouseLoadData, Auto.WritePlayerHouseLoadData, "HouseLoadData", true)
	Base.WriteList7Bit(writer, val.TombIslandIds, writer.WriteInt32, 0, "TombIslandIds", true, 0, nil)
end

Auto.WriteEventIdInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.EventType, 173, 1), writer.WriteByte, 1)
end

Auto.WriteEventPanelInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.EventsInfo, Base.WriteComplexWrap(Auto.WriteTaskEventInfo, "TaskEventInfo", false), nil, "EventsInfo", false, 0, nil)
	Base.WriteList7Bit(writer, val.SubmitEventList, writer.WriteUInt32, 0, "SubmitEventList", false, 0, nil)
	Base.WriteList7Bit(writer, val.SubmitReplayEventList, writer.WriteUInt32, 0, "SubmitReplayEventList", false, 0, nil)
	Base.WriteList7Bit(writer, val.EventViewInfoList, Base.WriteComplexWrap(Auto.WriteEventSpoonViewInfo, "EventSpoonViewInfo", false), nil, "EventViewInfoList", false, 0, nil)
end

Auto.WriteEventProgress = function(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt32, 0)
end

Auto.WriteEventProgressInfo = function(writer, val)
	Base.WriteList(writer, val.EventProgressDict, Base.WriteStructWrap(Auto.WriteEventProgress, "EventProgressDict"), nil, "EventProgressDict", false, 0, nil)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt32, 0)
end

Auto.WriteEventSpoonViewInfo = function(writer, val)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.SpoonMd5, false, "EventSpoonViewInfo.SpoonMd5", 0)
end

Auto.WriteExternalControlParamDto = function(writer, val)
	Base.WritePrimitive(writer, val.EnableStimResponse, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableInteractionUi, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableStationaryPointReturning, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AnimLookAtIkType, writer.WriteInt32, 0)
end

Auto.WriteExtraStateConfirmInfo = function(writer, val)
	Base.WritePrimitive(writer, val.stageId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.confirm, writer.WriteBoolean, false)
end

Auto.WriteExtractionGpsInfo = function(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

Auto.WriteExtractionGpsList = function(writer, val)
	Base.WriteList7Bit(writer, val.Infos, Base.WriteComplexWrap(Auto.WriteExtractionGpsInfo, "ExtractionGpsInfo", false), nil, "Infos", false, 0, nil)
end

Auto.WriteExtractionMark = function(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

Auto.WriteExtractionSettleData = function(writer, val)
	Base.WritePrimitive(writer, val.BringOutItemTotalPrice, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 174, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ExtractionPointId, writer.WriteUInt32, 0)
end

Auto.WriteExtractionShooterBagInfo = function(writer, val)
	Base.WritePrimitive(writer, val.BagId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.ItemInfoList, Base.WriteComplexWrap(Auto.WriteExtractionShooterItemInfo, "ExtractionShooterItemInfo", false), nil, "ItemInfoList", false, 0, nil)
end

Auto.WriteExtractionShooterBringOutFund = function(writer, val)
	Base.WritePrimitive(writer, val.Amount, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.SetTracks, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteExtractionShooterBringOutFundSetTrack, "ExtractionShooterBringOutFundSetTrack", false), nil, "SetTracks", false, 0)
end

Auto.WriteExtractionShooterBringOutFundSetTrack = function(writer, val)
	Base.WritePrimitive(writer, val.LastAddTime, writer.WriteUInt32, 0)
end

Auto.WriteExtractionShooterCellPos = function(writer, val)
	Base.WritePrimitive(writer, val.BagId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellX, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellY, writer.WriteUInt32, 0)
end

Auto.WriteExtractionShooterContainerGMInfo = function(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.Info, Auto.WriteExtractionShooterContainerInfo, "Info", true)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
end

Auto.WriteExtractionShooterContainerInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.ItemList, Base.WriteComplexWrap(Auto.WriteExtractionShooterContainerItemInfo, "ExtractionShooterContainerItemInfo", true), nil, "ItemList", true, 0, nil)
end

Auto.WriteExtractionShooterContainerItemInfo = function(writer, val)
	Base.WriteDict(writer, val.Pid2SearchFinishTimeDict, writer.WriteUInt64, writer.WriteUInt32, 0, "Pid2SearchFinishTimeDict", false, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellX, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellY, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRotated, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsLocked, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ShieldValue, writer.WriteSingle, 0)
	Base.WriteComplex(writer, val.WeaponData, Auto.WriteWeaponData, "WeaponData", true)
	Base.WriteComplex(writer, val.CollectionBook, Auto.WriteCollectionBookData, "CollectionBook", true)
end

Auto.WriteExtractionShooterEvacuationPlaceInfo = function(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 175, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ShowAtTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DisappearAtTime, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.InnerRoomShape, Auto.WriteExtractionShooterRoomShapeInfo, "InnerRoomShape")
end

Auto.WriteExtractionShooterItemComponent = function(writer, val)
end

Auto.WriteExtractionShooterItemInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellX, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellY, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRotated, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsLocked, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ShieldValue, writer.WriteSingle, 0)
	Base.WriteComplex(writer, val.WeaponData, Auto.WriteWeaponData, "WeaponData", true)
	Base.WriteComplex(writer, val.CollectionBook, Auto.WriteCollectionBookData, "CollectionBook", true)
end

Auto.WriteExtractionShooterRoomShapeInfo = function(writer, val)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WriteStruct(writer, val.HalfExtents, Auto.WriteUXVector3, "HalfExtents")
	Base.WriteStruct(writer, val.XDir, Auto.WriteUXVector3, "XDir")
	Base.WriteStruct(writer, val.ZDir, Auto.WriteUXVector3, "ZDir")
	Base.WritePrimitive(writer, val.roomId, writer.WriteInt32, 0)
end

Auto.WriteExtractionShooterSellItemInfo = function(writer, val)
	Base.WritePrimitive(writer, val.BagConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellX, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CellY, writer.WriteUInt32, 0)
end

Auto.WriteExtractionShooterSlotGroupInfo = function(writer, val)
	Base.WritePrimitive(writer, val.BagId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.ItemInfoList, Base.WriteComplexWrap(Auto.WriteExtractionShooterItemInfo, "ExtractionShooterItemInfo", false), nil, "ItemInfoList", false, 0, nil)
	Base.WritePrimitive(writer, val.AddUnlockedCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AddMaxCapacity, writer.WriteUInt32, 0)
end

Auto.WriteFaceToCommandData = function(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.Tolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteFactionChangeInfo = function(writer, val)
	Base.WritePrimitive(writer, val.FactionId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.NewInfo, Auto.WriteFactionInfo, "NewInfo", false)
	Base.WriteComplex(writer, val.OldInfo, Auto.WriteFactionInfo, "OldInfo", false)
end

Auto.WriteFactionCounterAttackData = function(writer, val)
	Base.WritePrimitive(writer, val.CurValue, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RemainingTickTimeSec, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BossFailCount, writer.WriteUInt32, 0)
end

Auto.WriteFactionInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Disposition, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DispositionLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Influence, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.InteractionCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GreetCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsUnlock, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.CounterAttackData, Auto.WriteFactionCounterAttackData, "CounterAttackData", false)
end

Auto.WriteFanBoxDropInfo = function(writer, val)
	Base.WritePrimitive(writer, val.AwardScore, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LastUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WeekDropCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DropCount, writer.WriteUInt32, 0)
end

Auto.WriteFarmerDailyRecord = function(writer, val)
	Base.WritePrimitive(writer, val.Income, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Transactions, writer.WriteUInt32, 0)
end

Auto.WriteFarmerIncomeView = function(writer, val)
	Base.WritePrimitive(writer, val.Wallet, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalEarned, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ThisWeekSoldCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastWithdrawAmount, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.ThisWeekDailyRecords, Base.WriteComplexWrap(Auto.WriteFarmerDailyRecord, "FarmerDailyRecord", false), nil, "ThisWeekDailyRecords", false, 0, nil)
	Base.WritePrimitive(writer, val.ThisWeekEarned, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastWeekEarned, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastWeekSoldCount, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.LastWeekDailyRecords, Base.WriteComplexWrap(Auto.WriteFarmerDailyRecord, "FarmerDailyRecord", false), nil, "LastWeekDailyRecords", false, 0, nil)
end

Auto.WriteFarmerOrderInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 176, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.EndReason, 177, 0), writer.WriteByte, 0)
end

Auto.WriteFarmerShopSlot = function(writer, val)
	Base.WritePrimitive(writer, val.ItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Price, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlacedTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastSettleTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Quality, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Tags, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SoldCount, writer.WriteUInt32, 0)
end

Auto.WriteFarmerSowInfo = function(writer, val)
	Base.WritePrimitive(writer, val.LandId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CorpId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ConsumableId, writer.WriteUInt32, 0)
end

Auto.WriteFashionColoringInfo = function(writer, val)
	Base.WriteDict(writer, val.ColoringType2ColorIdDict, writer.WriteByte, writer.WriteUInt32, 0, "ColoringType2ColorIdDict", false, RpcLengthLimits.FashionColoringInfo_ColoringType2ColorIdDict)
end

Auto.WriteFashionColoringSchemeInfo = function(writer, val)
	Base.WritePrimitive(writer, val.FashionId, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.FashionColoringSchemeInfoDict, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteFashionColoringInfo, "FashionColoringInfo", false), nil, "FashionColoringSchemeInfoDict", false, RpcLengthLimits.FashionColoringSchemeInfo_FashionColoringSchemeInfoDict)
end

Auto.WriteFashionCustomSuitSchemeInfo = function(writer, val)
	writer.WriteString(writer, val.SchemeName, true, "FashionCustomSuitSchemeInfo.SchemeName", RpcLengthLimits.FashionCustomSuitSchemeInfo_SchemeName)
	Base.WritePrimitive(writer, val.JoinRandomPool, writer.WriteBoolean, false)
	Base.WriteList(writer, val.WearFashionInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionInfo, "WearFashionInfo", false), nil, "WearFashionInfoList", false, RpcLengthLimits.BaseWearFashionsInfo_WearFashionInfoList, nil)
	Base.WriteList(writer, val.WearFashionEditInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "WearFashionEditInfoList", true, RpcLengthLimits.BaseWearFashionsInfo_WearFashionEditInfoList, nil)
	Base.WritePrimitive(writer, val.HiddenParts, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EditedHiddenParts, writer.WriteByte, 0)
end

Auto.WriteFashionFunctionSuitSchemeInfo = function(writer, val)
	Base.WriteList(writer, val.WearFashionInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionInfo, "WearFashionInfo", false), nil, "WearFashionInfoList", false, RpcLengthLimits.BaseWearFashionsInfo_WearFashionInfoList, nil)
	Base.WriteList(writer, val.WearFashionEditInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "WearFashionEditInfoList", true, RpcLengthLimits.BaseWearFashionsInfo_WearFashionEditInfoList, nil)
	Base.WritePrimitive(writer, val.HiddenParts, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EditedHiddenParts, writer.WriteByte, 0)
end

Auto.WriteFashionInfo = function(writer, val)
	Base.WritePrimitive(writer, val.FashionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpiredTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GainTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Status, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ApplyColoringSchemeId, writer.WriteByte, 0)
	Base.WriteDict(writer, val.ColoringSchemeInfoDict, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteFashionColoringInfo, "FashionColoringInfo", false), nil, "ColoringSchemeInfoDict", false, 0)
	Base.WritePrimitive(writer, val.UnlockColoringSlotCount, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ColoringSchemeTopNMaxCollectionScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OwnedCount, writer.WriteInt32, 0)
end

Auto.WriteFashionSuitInstanceInfo = function(writer, val)
	Base.WriteList(writer, val.SuitInstanceIdList, writer.WriteUInt64, 0, "SuitInstanceIdList", false, 0, nil)
	Base.WritePrimitive(writer, val.GainTime, writer.WriteUInt32, 0)
end

Auto.WriteFavorInteractCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.MainAgentPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CoAgentPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SingleInteractType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MultiInteractType, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.MainPos, Auto.WriteUXVector3, "MainPos")
	Base.WriteStruct(writer, val.MainDir, Auto.WriteUXVector3, "MainDir")
	Base.WriteStruct(writer, val.CoPos, Auto.WriteUXVector3, "CoPos")
	Base.WriteStruct(writer, val.CoDir, Auto.WriteUXVector3, "CoDir")
	Base.WritePrimitive(writer, val.IsHold, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteFavorNpcBusyInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpawnType, 178, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
end

Auto.WriteFavorNpcPosInfo = function(writer, val)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

Auto.WriteFerrisWheelCabinDoorData = function(writer, val)
	Base.WritePrimitive(writer, val.CabinIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DoorState, 67, 0), writer.WriteByte, 0)
end

Auto.WriteFerrisWheelStateData = function(writer, val)
	Base.WritePrimitive(writer, val.CabinOneAngle, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.StateStartTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpeedState, 179, 0), writer.WriteByte, 0)
end

Auto.WriteFightGamePlayerSimpleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.WithAi, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsObserver, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Is1P, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsMaster, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.PlayerUnitInfo, Auto.WriteFightGameUnitInfo, "PlayerUnitInfo", true)
	Base.WriteComplex(writer, val.AiUnitInfo, Auto.WriteFightGameUnitInfo, "AiUnitInfo", true)
end

Auto.WriteFightGameResult = function(writer, val)
	Base.WritePrimitive(writer, val.WinnerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RoundLeft, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.WaitEndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsWithAi, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsAiWin, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayerWin, writer.WriteBoolean, false)
end

Auto.WriteFightGameStateInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PosX, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PosY, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Face, 180, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.Hp, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.AngryValue, writer.WriteInt32, 0)
end

Auto.WriteFightGameUnitInfo = function(writer, val)
	Base.WritePrimitive(writer, val.IsAi, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RoleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DeadCount, writer.WriteInt32, 0)
	writer.WriteString(writer, val.CurrentAction, false, "FightGameUnitInfo.CurrentAction", 0)
	Base.WriteComplex(writer, val.State, Auto.WriteFightGameStateInfo, "State", false)
end

Auto.WriteFightGroupDebugInfo = function(writer, val)
	Base.WritePrimitive(writer, val.configId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.uIds, writer.WriteUInt64, 0, "uIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.normalEdicts, Base.WriteStructWrap(Auto.WriteEdictDebugInfo, "normalEdicts"), nil, "normalEdicts", false, 0, nil)
	Base.WriteList7Bit(writer, val.extraEdicts, Base.WriteStructWrap(Auto.WriteEdictDebugInfo, "extraEdicts"), nil, "extraEdicts", false, 0, nil)
end

Auto.WriteFightPokemon = function(writer, val)
	Base.WritePrimitive(writer, val.IsIllusory, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PokemonId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Body, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Camp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weapon, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsAlive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MaxHp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Dam, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Def, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BlockRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecialAttRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AttackSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EnergyRecovery, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.CubeCoord, Auto.WriteCubeCoord, "CubeCoord")
	Base.WritePrimitive(writer, val.BornFacing, writer.WriteSingle, 0)
end

Auto.WriteFindPathResult = function(writer, val)
	Base.WriteList7Bit(writer, val.Points, Base.WriteStructWrap(Auto.WriteUXVector3, "Points"), nil, "Points", false, 0, nil)
	Base.WriteList7Bit(writer, val.Flags, writer.WriteByte, 0, "Flags", false, 0, nil)
end

Auto.WriteFireworkBuyInfo = function(writer, val)
	Base.WritePrimitive(writer, val.FireworkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlanId, writer.WriteUInt32, 0)
end

Auto.WriteFireworkPlanInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PlanId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NewUnlock, writer.WriteBoolean, false)
end

Auto.WriteFireworkStoreInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.PlanInfos, Base.WriteComplexWrap(Auto.WriteFireworkPlanInfo, "FireworkPlanInfo", false), nil, "PlanInfos", false, RpcLengthLimits.FireworkStoreInfo_PlanInfos, nil)
end

Auto.WriteFishInfo = function(writer, val)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Length, writer.WriteSingle, 0)
	Base.WriteComplex(writer, val.PlacedInfo, Auto.WriteFishPlacedInfo, "PlacedInfo", true)
end

Auto.WriteFishPlacedInfo = function(writer, val)
	Base.WriteComplex(writer, val.Furniture, Auto.WriteFurniturePlacedInfo, "Furniture", true)
end

Auto.WriteFishRecordInfo = function(writer, val)
	Base.WritePrimitive(writer, val.FirstCatchTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FirstCatchSpot, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BestWeight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BestLength, writer.WriteSingle, 0)
end

Auto.WriteFishTankGadgetData = function(writer, val)
	Base.WriteDict7Bit(writer, val.SlotFish, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteHouseFishInfo, "HouseFishInfo", false), nil, "SlotFish", false, 0)
end

Auto.WriteFishingFishRewardInfo = function(writer, val)
	Base.WritePrimitive(writer, val.FishConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Length, writer.WriteSingle, 0)
end

Auto.WriteFishingGearInfo = function(writer, val)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RemainingDurability, writer.WriteUInt32, 0)
end

Auto.WriteFishingSpotFishClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FishConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Length, writer.WriteSingle, 0)
end

Auto.WriteFishingSpotFullSyncInfo = function(writer, val)
	Base.WritePrimitive(writer, val.FishGroupId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Fishes, Base.WriteComplexWrap(Auto.WriteFishingSpotFishClientInfo, "FishingSpotFishClientInfo", false), nil, "Fishes", false, 0, nil)
	Base.WritePrimitive(writer, val.LastRefreshTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastResetTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxCount, writer.WriteUInt32, 0)
end

Auto.WriteFloat3 = function(writer, val)
	Base.WritePrimitive(writer, val.x, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.y, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.z, writer.WriteSingle, 0)
end

Auto.WriteFloatPayload = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteSingle, 0)
end

Auto.WriteFloatingMoveData = function(writer, val)
	Base.WritePrimitive(writer, val.moveTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.speed, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.targetPos, Auto.WriteUXVector3, "targetPos")
	Base.WritePrimitive(writer, val.speedCurveId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.targetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveType, 128, 0), writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BlockCloseCapsuleCollision, writer.WriteBoolean, false)
end

Auto.WriteFocusOnCommandData = function(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.FocusLevel, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.FocusTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Tolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TurnToleranceTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TurnToleranceLerp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteFollowCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.ComfortRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TowardTarget, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.Distances, Base.WriteStructWrap(Auto.WriteRangeMoveType, "Distances"), nil, "Distances", false, 0, nil)
	Base.WriteStruct(writer, val.FollowEqs, Auto.WriteFollowEQS, "FollowEqs")
	Base.WritePrimitive(writer, val.TurnToleranceAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TurnToleranceTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TurnToleranceLerp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NavigationTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SelfNavigationTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FailedWhenNavigationFailed, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.ArriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DirectionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TryMatchStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.KeepUpdateTargetPosition, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RunChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.KeepMovingAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteFollowEQS = function(writer, val)
	writer.WriteString(writer, val.checker, true, "FollowEQS.checker", 0)
	writer.WriteString(writer, val.preQuery, true, "FollowEQS.preQuery", 0)
	writer.WriteString(writer, val.query, true, "FollowEQS.query", 0)
end

Auto.WriteFollowRecordingParameters = function(writer, val)
	Base.WritePrimitive(writer, val.PathId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.FollowType, 105, 0), writer.WriteByte, 0)
	writer.WriteString(writer, val.recordingFileName, false, "FollowRecordingParameters.recordingFileName", 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TargetType, 102, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Step, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MinSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FarAwayCheck, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FarAwayThrehold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CloseToCheck, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CloseToThrehold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.StartFromNextAndNearestPoint, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AdjustTime, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.PathOffset, Auto.WriteUXVector3, "PathOffset")
	Base.WritePrimitive(writer, val.guideMinDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.guideMaxDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.guideMinSpeedThreshold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.guideMaxSpeedThreshold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.StopForObstacle, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

Auto.WriteFormationPlayerSlot = function(writer, val)
	Base.WritePrimitive(writer, val.Row, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Col, writer.WriteInt32, 0)
end

Auto.WriteFortuneResultData = function(writer, val)
	Base.WritePrimitive(writer, val.RequestId, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.FortuneLevel, false, "FortuneResultData.FortuneLevel", 0)
	Base.WriteList7Bit(writer, val.Poem, Base.WriteStringWrap(false, "Poem", 0), nil, "Poem", false, 0, nil)
	writer.WriteString(writer, val.Interpretation, false, "FortuneResultData.Interpretation", 0)
	Base.WriteList7Bit(writer, val.TodayGood, Base.WriteStringWrap(false, "TodayGood", 0), nil, "TodayGood", false, 0, nil)
	Base.WriteList7Bit(writer, val.TodayBad, Base.WriteStringWrap(false, "TodayBad", 0), nil, "TodayBad", false, 0, nil)
	Base.WritePrimitive(writer, val.FakeFortuneId, writer.WriteUInt32, 0)
end

Auto.WriteFortuneStartParams = function(writer, val)
	writer.WriteString(writer, val.PlayerName, false, "FortuneStartParams.PlayerName", RpcLengthLimits.FortuneStartParams_PlayerName)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Gender, 181, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Year, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Month, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Day, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Hour, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.WishType, 182, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.InputMode, 183, 0), writer.WriteByte, 0)
	writer.WriteString(writer, val.Language, false, "FortuneStartParams.Language", RpcLengthLimits.FortuneStartParams_Language)
end

Auto.WriteFriendSimpleData = function(writer, val)
	Base.WritePrimitive(writer, val.IsRejectAllFriendApply, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.BlackList, writer.WriteUInt64, 0, "BlackList", false, 0, nil)
	Base.WriteList7Bit(writer, val.FriendRelationList, Base.WriteComplexWrap(Auto.WriteRelationVO, "RelationVO", false), nil, "FriendRelationList", false, 0, nil)
	Base.WriteList7Bit(writer, val.SpecialList, writer.WriteUInt64, 0, "SpecialList", false, 0, nil)
end

Auto.WriteFryChestnutParticipantInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

Auto.WriteFunplayHudDataValue = function(writer, val)
end

Auto.WriteFunplayHudDataValueFloat = function(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteSingle, 0)
end

Auto.WriteFunplayHudDataValueUInt = function(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt32, 0)
end

Auto.WriteFurnitureGadgetData = function(writer, val)
	Base.WriteComplex(writer, val.FishTank, Auto.WriteFishTankGadgetData, "FishTank", true)
	Base.WriteComplex(writer, val.Collectible, Auto.WriteCollectibleGadgetData, "Collectible", true)
end

Auto.WriteFurnitureInfo = function(writer, val)
	Base.WritePrimitive(writer, val.FurnitureId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlacedCount, writer.WriteUInt32, 0)
end

Auto.WriteFurniturePlacedInfo = function(writer, val)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FurniturePlacedId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.FurnitureSlotId, writer.WriteUInt32, 0)
end

Auto.WriteGachaDrawItemDetail = function(writer, val)
	Base.WritePrimitive(writer, val.PoolContentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsGrandPrize, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsConverted, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsNew, writer.WriteBoolean, false)
end

Auto.WriteGachaDrawRecordItem = function(writer, val)
	Base.WritePrimitive(writer, val.GachaId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PoolContentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DropId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DrawTimeUnix, writer.WriteInt64, 0)
end

Auto.WriteGachaDrawRecordPage = function(writer, val)
	Base.WriteList7Bit(writer, val.Records, Base.WriteComplexWrap(Auto.WriteGachaDrawRecordItem, "GachaDrawRecordItem", false), nil, "Records", false, 0, nil)
	Base.WritePrimitive(writer, val.TotalCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PageIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PageSize, writer.WriteUInt32, 0)
end

Auto.WriteGachaGrandPrizeComponent = function(writer, val)
	Base.WritePrimitive(writer, val.Number, writer.WriteUInt32, 0)
end

Auto.WriteGadgetClientDropLimitInfo = function(writer, val)
	Base.WritePrimitive(writer, val.GadgetUid, writer.WriteUInt64, 0)
	Base.WriteDict7Bit(writer, val.DropLimitId2FinishTime, writer.WriteUInt32, writer.WriteUInt32, 0, "DropLimitId2FinishTime", false, 0)
end

Auto.WriteGadgetDropLimitIdList = function(writer, val)
	Base.WriteList7Bit(writer, val.DropLimitIds, writer.WriteUInt32, 0, "DropLimitIds", false, 0, nil)
end

Auto.WriteGadgetEntityInfo = function(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.NavId, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.ChildNavIds, writer.WriteInt32, 0, "ChildNavIds", true, 0, nil)
	Base.WritePrimitive(writer, val.ForceLod0, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsTask, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.Pack, Auto.WritePackedGadgetInfo, "Pack", false)
	Base.WriteComplex(writer, val.ReplaceInfo, Auto.WriteReplaceGadgetInfo, "ReplaceInfo", true)
	Base.WriteDict7Bit(writer, val.CommonStateInfoDic, writer.WriteInt32, writer.WriteInt32, 0, "CommonStateInfoDic", true, 0)
	Base.WriteDict7Bit(writer, val.CommonValueInfoDic, writer.WriteInt32, Base.WriteStringWrap(false, "CommonValueInfoDic", 0), nil, "CommonValueInfoDic", true, 0)
	Base.WriteDict7Bit(writer, val.PersonalValueInfoDic, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteSceneDevicePersonalValueInfo, "SceneDevicePersonalValueInfo", false), nil, "PersonalValueInfoDic", true, 0)
	Base.WriteDict7Bit(writer, val.StateCheckIndexDic, writer.WriteInt32, writer.WriteInt32, 0, "StateCheckIndexDic", true, 0)
	Base.WriteDict7Bit(writer, val.ValueCheckIndexDic, writer.WriteInt32, writer.WriteInt32, 0, "ValueCheckIndexDic", true, 0)
	Base.WriteList7Bit(writer, val.OccupantInfos, Base.WriteStructWrap(Auto.WriteSceneDeviceOccupantInfo, "OccupantInfos"), nil, "OccupantInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.LinkOccupiedId, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.SymbiosisGadgets, writer.WriteUInt64, writer.WriteUInt64, 0, "SymbiosisGadgets", true, 0)
	Base.WriteComplex(writer, val.MobilePlatformInfo, Auto.WriteMobilePlatformSyncInfo, "MobilePlatformInfo", true)
	Base.WriteComplex(writer, val.AdherePlatformInfo, Auto.WriteAdhereMovingPlatformInfo, "AdherePlatformInfo", true)
	Base.WriteComplex(writer, val.DoorModuleInfo, Auto.WriteDoorModuleSyncInfo, "DoorModuleInfo", true)
	Base.WriteComplex(writer, val.DrillShelfInfo, Auto.WriteDrillShelfSyncInfo, "DrillShelfInfo", true)
	Base.WriteComplex(writer, val.HangingInfo, Auto.WriteSceneDeviceHangingInfo, "HangingInfo", true)
end

Auto.WriteGadgetExtraSyncInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.DropLimit, Base.WriteComplexWrap(Auto.WriteGadgetClientDropLimitInfo, "GadgetClientDropLimitInfo", true), nil, "DropLimit", true, 0, nil)
end

Auto.WriteGadgetGridAOIIncrease = function(writer, val)
	Base.WriteStruct(writer, val.PlayerStandardIndex, Auto.WriteGridIndex, "PlayerStandardIndex")
	Base.WriteList7Bit(writer, val.addInfos, Base.WriteComplexWrap(Auto.WriteGadgetEntityInfo, "GadgetEntityInfo", true), nil, "addInfos", true, 0, nil)
	Base.WriteList7Bit(writer, val.indexList, Base.WriteStructWrap(Auto.WriteGridIndex, "indexList"), nil, "indexList", true, 0, nil)
	Base.WriteList7Bit(writer, val.addUniqueIds, writer.WriteUInt64, 0, "addUniqueIds", true, 0, nil)
	Base.WriteList7Bit(writer, val.removeIds, writer.WriteUInt64, 0, "removeIds", true, 0, nil)
	Base.WriteList7Bit(writer, val.activeIds, writer.WriteUInt64, 0, "activeIds", true, 0, nil)
	Base.WriteList7Bit(writer, val.inactiveIds, writer.WriteUInt64, 0, "inactiveIds", true, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.reason, 160, 0), writer.WriteByte, 0)
end

Auto.WriteGadgetPackSyncInfo = function(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.PackedInfo, Auto.WritePackedGadgetInfo, "PackedInfo", false)
end

Auto.WriteGadgetRecordItemStuntJump = function(writer, val)
	Base.WritePrimitive(writer, val.FightSpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BestStuntJumpDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BestStuntJumpHeight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RemainingCount, writer.WriteInt32, 0)
end

Auto.WriteGadgetSyncInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
end

Auto.WriteGameColorInfo = function(writer, val)
	Base.WritePrimitive(writer, val.gameId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.playersDuty, Base.WriteComplexWrap(Auto.WriteGameDutyInfo, "GameDutyInfo", false), nil, "playersDuty", false, 0, nil)
end

Auto.WriteGameDutyInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DutyId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteUInt32, 0)
end

Auto.WriteGameEndInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.PlayerNames, Base.WriteStringWrap(false, "PlayerNames", 0), nil, "PlayerNames", false, 0, nil)
	Base.WriteList7Bit(writer, val.Points, writer.WriteInt32, 0, "Points", false, 0, nil)
	Base.WriteList7Bit(writer, val.Places, writer.WriteInt32, 0, "Places", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 184, 0), writer.WriteByte, 0)
end

Auto.WriteGameFeatureValue = function(writer, val)
	Base.WritePrimitive(writer, val.Enabled, writer.WriteBoolean, false)
	Base.WriteList(writer, val.Ids, writer.WriteUInt64, 0, "Ids", false, 0, nil)
end

Auto.WriteGameGroundParticipantInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

Auto.WriteGameGroundZoneCountDownInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PrepareCountDownEndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DisplayCountDownEndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameTimeCountDownStartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameTimeCountDownEndTime, writer.WriteUInt32, 0)
end

Auto.WriteGameGroundZoneIdentifier = function(writer, val)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
end

Auto.WriteGameGroundZoneInfo = function(writer, val)
	writer.WriteString(writer, val.ZoneSessionId, false, "GameGroundZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WriteGamePrepareInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Points, writer.WriteInt32, 0, "Points", false, 0, nil)
	Base.WriteList7Bit(writer, val.PlayerNames, Base.WriteStringWrap(false, "PlayerNames", 0), nil, "PlayerNames", false, 0, nil)
	Base.WriteList7Bit(writer, val.NpcMahjongIds, writer.WriteUInt32, 0, "NpcMahjongIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.NpcCultivationIds, writer.WriteUInt32, 0, "NpcCultivationIds", false, 0, nil)
	Base.WriteStruct(writer, val.GameSetting, Auto.WriteSimpleGameSetting, "GameSetting")
end

Auto.WriteGameServerInfo = function(writer, val)
	writer.WriteString(writer, val.ClientListenIp, false, "GameServerInfo.ClientListenIp", 0)
	Base.WritePrimitive(writer, val.ClientListenPort, writer.WriteInt32, 0)
	writer.WriteString(writer, val.Token, false, "GameServerInfo.Token", 0)
end

Auto.WriteGangBossFullDetails = function(writer, val)
	Base.WriteComplex(writer, val.full, Auto.WritePlayerInfoJobGangBoss, "full", false)
	Base.WritePrimitive(writer, val.CurrentBattleAgentCount, writer.WriteInt32, 0)
end

Auto.WriteGangMembersInfos = function(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsUnlock, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NextReviveTimeStamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.HpPercent, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsDead, writer.WriteBoolean, false)
end

Auto.WriteGetInVehicleCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.HasDoorInteract, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.Distances, Base.WriteStructWrap(Auto.WriteRangeMoveType, "Distances"), nil, "Distances", true, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteGetOutVehicleCommandData = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteGetSitUpCommandData = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteGiftEntry = function(writer, val)
	Base.WritePrimitive(writer, val.GiftId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SenderPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CommodityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BundleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SendTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.GiftMessage, false, "GiftEntry.GiftMessage", 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.HandleStatus, 185, 0), writer.WriteByte, 0)
	Base.WriteList(writer, val.PaidItems, Base.WriteComplexWrap(Auto.WriteItemCountInfo, "ItemCountInfo", false), nil, "PaidItems", false, 0, nil)
end

Auto.WriteGlueParticipantInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

Auto.WriteGlueZoneInfo = function(writer, val)
	writer.WriteString(writer, val.ZoneSessionId, false, "GlueZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WriteGmBehaviorKV = function(writer, val)
	writer.WriteString(writer, val.Key, false, "GmBehaviorKV.Key", 0)
	writer.WriteString(writer, val.Value, false, "GmBehaviorKV.Value", 0)
end

Auto.WriteGmCreateNpcOptionData = function(writer, val)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
end

Auto.WriteGmCreatePedData = function(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UrbanDiversityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Personality, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SexType, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Usages, writer.WriteUInt32, 0, "Usages", true, 0, nil)
	Base.WriteList7Bit(writer, val.Crimes, writer.WriteUInt32, 0, "Crimes", true, 0, nil)
end

Auto.WriteGmCurveKeyframe = function(writer, val)
	Base.WritePrimitive(writer, val.Time, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Value, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.InTangent, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OutTangent, writer.WriteSingle, 0)
end

Auto.WriteGmEnemyStrategyInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.SkillIds, writer.WriteUInt32, 0, "SkillIds", false, 0, nil)
end

Auto.WriteGmLockTargetRadius = function(writer, val)
	writer.WriteString(writer, val.AiName, false, "GmLockTargetRadius.AiName", 0)
	Base.WritePrimitive(writer, val.Radius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BackRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LookUpAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LookDownAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EyeHeight, writer.WriteSingle, 0)
end

Auto.WriteGmQueryObjectRoot = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	writer.WriteString(writer, val.Name, true, "GmQueryObjectRoot.Name", 0)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsStatic, writer.WriteBoolean, false)
	writer.WriteString(writer, val.Position, true, "GmQueryObjectRoot.Position", 0)
	writer.WriteString(writer, val.LocalPosition, true, "GmQueryObjectRoot.LocalPosition", 0)
	writer.WriteString(writer, val.Rotation, true, "GmQueryObjectRoot.Rotation", 0)
	writer.WriteString(writer, val.LocalRotation, true, "GmQueryObjectRoot.LocalRotation", 0)
	writer.WriteString(writer, val.Scale, true, "GmQueryObjectRoot.Scale", 0)
	writer.WriteString(writer, val.LocalScale, true, "GmQueryObjectRoot.LocalScale", 0)
	writer.WriteString(writer, val.Path, true, "GmQueryObjectRoot.Path", 0)
	writer.WriteString(writer, val.Layer, true, "GmQueryObjectRoot.Layer", 0)
	Base.WriteList(writer, val.Components, Base.WriteComplexWrap(Auto.WriteQueryComponentInfo, "QueryComponentInfo", true), nil, "Components", true, 0, nil)
end

Auto.WriteGmQuerySceneInfo = function(writer, val)
	writer.WriteString(writer, val.Name, true, "GmQuerySceneInfo.Name", 0)
	Base.WriteList(writer, val.Objects, Base.WriteComplexWrap(Auto.WriteGmQuerySceneObjectInfo, "GmQuerySceneObjectInfo", false), nil, "Objects", false, 0, nil)
end

Auto.WriteGmQuerySceneObjectInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	writer.WriteString(writer, val.Name, true, "GmQuerySceneObjectInfo.Name", 0)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Leaf, writer.WriteBoolean, false)
end

Auto.WriteGomokuBoardCap = function(writer, val)
	Base.WritePrimitive(writer, val.x, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.y, writer.WriteUInt32, 0)
end

Auto.WriteGomokuBoardRow = function(writer, val)
	Base.WriteList7Bit(writer, val.PieceBoardRow, writer.WriteByte, 0, "PieceBoardRow", false, 0, nil)
end

Auto.WriteGomokuParticipantInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

Auto.WriteGomokuParticipantScoreInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.RecordInfo, Base.WriteComplexWrap(Auto.WriteGomokuPiece, "GomokuPiece", false), nil, "RecordInfo", false, 0, nil)
	Base.WriteDict7Bit(writer, val.GomokuSkillInfo, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteGomokuSkill, "GomokuSkill", false), nil, "GomokuSkillInfo", false, 0)
end

Auto.WriteGomokuPiece = function(writer, val)
	Base.WritePrimitive(writer, val.X, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Y, writer.WriteUInt32, 0)
end

Auto.WriteGomokuScoreInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.PieceBoard, Base.WriteComplexWrap(Auto.WriteGomokuBoardRow, "GomokuBoardRow", false), nil, "PieceBoard", false, 0, nil)
	Base.WriteList7Bit(writer, val.CapList, Base.WriteComplexWrap(Auto.WriteGomokuBoardCap, "GomokuBoardCap", false), nil, "CapList", false, 0, nil)
	Base.WriteDict7Bit(writer, val.GomokuParticipantDict, writer.WriteInt32, Base.WriteComplexWrap(Auto.WriteGomokuParticipantScoreInfo, "GomokuParticipantScoreInfo", false), nil, "GomokuParticipantDict", false, 0)
	Base.WritePrimitive(writer, val.Winner, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CanUseSkill, writer.WriteBoolean, false)
end

Auto.WriteGomokuSettleData = function(writer, val)
	Base.WritePrimitive(writer, val.Rank, writer.WriteUInt32, 0)
end

Auto.WriteGomokuSkill = function(writer, val)
	Base.WritePrimitive(writer, val.LastestCastRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsCasting, writer.WriteBoolean, false)
end

Auto.WriteGomokuSkillExtraParam = function(writer, val)
	Base.WritePrimitive(writer, val.x, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.y, writer.WriteUInt32, 0)
end

Auto.WriteGomokuZoneInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 186, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurn, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.ScoreInfo, Auto.WriteGomokuScoreInfo, "ScoreInfo", false)
	writer.WriteString(writer, val.ZoneSessionId, false, "GomokuZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WriteGridAOIDecrease = function(writer, val)
	Base.WriteList7Bit(writer, val.SectorIdList, writer.WriteInt32, 0, "SectorIdList", true, 0, nil)
	Base.WritePrimitive(writer, val.BuildingId, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.StandardIndexList, Base.WriteStructWrap(Auto.WriteGridIndex, "StandardIndexList"), nil, "StandardIndexList", false, 0, nil)
	Base.WriteList7Bit(writer, val.ExceptIds, writer.WriteUInt64, 0, "ExceptIds", false, 0, nil)
end

Auto.WriteGridIndex = function(writer, val)
	Base.WritePrimitive(writer, val.X, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Z, writer.WriteInt32, 0)
end

Auto.WriteGymPlayResult = function(writer, val)
	Base.WritePrimitive(writer, val.Level, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ExerciseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteSingle, 0)
end

Auto.WriteHUDRecommendInfo = function(writer, val)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Read, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OfflineRemaining, writer.WriteUInt32, 0)
end

Auto.WriteHackerBatteryCurrentAndTotalCount = function(writer, val)
	Base.WritePrimitive(writer, val.BatteryTotalCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BatteryCurrentCount, writer.WriteUInt32, 0)
end

Auto.WriteHackerPostInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 187, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.HaveRead, writer.WriteBoolean, false)
end

Auto.WriteHideAndSeekSettleData = function(writer, val)
	Base.WritePrimitive(writer, val.SurvivalDuration, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CaptureCount, writer.WriteUInt32, 0)
end

Auto.WriteHitPredictData = function(writer, val)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.HitPredictId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PredictorId, writer.WriteUInt64, 0)
end

Auto.WriteHitSomethingCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.HitForce, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HitRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HitPart, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SecondHitPart, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HitLayer, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.HitTiming, Auto.WritePlotMinMaxRange, "HitTiming")
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.AnimId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SelectedActionIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UseRemapping, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CycleNum, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.RemappingLeg, 114, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.StartPosition, Auto.WriteUXVector3, "StartPosition")
	Base.WriteStruct(writer, val.StartDirection, Auto.WriteUXVector3, "StartDirection")
	Base.WritePrimitive(writer, val.AutoRemapping, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.AutoRemappingMoveType, 115, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteHouseAddFurnitureResult = function(writer, val)
	Base.WriteComplex(writer, val.PlacedFurnitureInfo, Auto.WritePlacedFurnitureInfo, "PlacedFurnitureInfo", true)
	Base.WriteComplex(writer, val.ShowcaseData, Auto.WriteHouseFashionShowcaseData, "ShowcaseData", true)
end

Auto.WriteHouseBaseInfo = function(writer, val)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ParkingSpaceVehicleIdDict, writer.WriteInt32, writer.WriteUInt32, 0, "ParkingSpaceVehicleIdDict", false, 0)
	Base.WritePrimitive(writer, val.Version, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.SocialInfo, Auto.WriteHouseSocialInfo, "SocialInfo", false)
	Base.WritePrimitive(writer, val.FurnitureIndex, writer.WriteUInt32, 0)
end

Auto.WriteHouseBuildingClientData = function(writer, val)
	Base.WritePrimitive(writer, val.OwnerPid, writer.WriteUInt64, 0)
	Base.WriteDict7Bit(writer, val.FloorBuildInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteIndoorBuildInfo, "IndoorBuildInfo", false), nil, "FloorBuildInfoDict", false, 0)
	Base.WriteComplex(writer, val.WallInfo, Auto.WriteHouseWallInfo, "WallInfo", false)
	Base.WriteDict7Bit(writer, val.FashionShowcaseDict, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteHouseFashionShowcaseData, "HouseFashionShowcaseData", false), nil, "FashionShowcaseDict", false, 0)
	Base.WriteComplex(writer, val.Configuration, Auto.WritePlayerSingleHouseConfiguration, "Configuration", false)
	Base.WriteDict7Bit(writer, val.FurnitureGadgetDataDict, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteFurnitureGadgetData, "FurnitureGadgetData", false), nil, "FurnitureGadgetDataDict", false, 0)
	Base.WriteList7Bit(writer, val.DisabledFurniturePlacedIds, writer.WriteUInt64, 0, "DisabledFurniturePlacedIds", false, RpcLengthLimits.HouseBuildingClientData_DisabledFurniturePlacedIds, nil)
end

Auto.WriteHouseFashionShowcaseData = function(writer, val)
	Base.WritePrimitive(writer, val.FurnitureId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.Models, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteHouseFashionShowcaseModel, "HouseFashionShowcaseModel", false), nil, "Models", false, 0)
end

Auto.WriteHouseFashionShowcaseModel = function(writer, val)
	Base.WritePrimitive(writer, val.FashionInstanceId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowcaseId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.FashionData, Auto.WriteSpiritWearFashionsInfo, "FashionData", false)
end

Auto.WriteHouseFenestrationData = function(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.CenterWS, Auto.WriteUXVector3, "CenterWS")
	Base.WriteStruct(writer, val.DirectionWS, Auto.WriteUXVector3, "DirectionWS")
	Base.WritePrimitive(writer, val.PrefabID, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlacedInstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Edge, Auto.WriteUXVector2Int, "Edge")
	Base.WritePrimitive(writer, val.GadgetInstanceId, writer.WriteUInt64, 0)
end

Auto.WriteHouseFishInfo = function(writer, val)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Length, writer.WriteSingle, 0)
	Base.WriteComplex(writer, val.PlacedInfo, Auto.WriteFishPlacedInfo, "PlacedInfo", true)
end

Auto.WriteHouseFloorsData = function(writer, val)
	Base.WriteDict(writer, val.Floors, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteHouseWallFloorValue, "HouseWallFloorValue", false), nil, "Floors", false, 0)
end

Auto.WriteHouseFurnitureGadgetMapping = function(writer, val)
	Base.WriteDict7Bit(writer, val.placedID2GadgetInstanceID, writer.WriteUInt64, writer.WriteUInt64, 0, "placedID2GadgetInstanceID", false, RpcLengthLimits.HouseFurnitureGadgetMapping_placedID2GadgetInstanceID)
end

Auto.WriteHouseFurnitureModification = function(writer, val)
	Base.WritePrimitive(writer, val.floor, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.AddPlacedFurnitureInfos, Base.WriteStructWrap(Auto.WriteAddPlacedFurnitureInfo, "AddPlacedFurnitureInfos"), nil, "AddPlacedFurnitureInfos", true, RpcLengthLimits.HouseFurnitureModification_AddPlacedFurnitureInfos, nil)
	Base.WriteList7Bit(writer, val.ChangePlacedFurnitureInfos, Base.WriteStructWrap(Auto.WriteChangePlacedFurnitureInfo, "ChangePlacedFurnitureInfos"), nil, "ChangePlacedFurnitureInfos", true, RpcLengthLimits.HouseFurnitureModification_ChangePlacedFurnitureInfos, nil)
	Base.WriteList7Bit(writer, val.RemovePlacedInstanceIds, writer.WriteUInt64, 0, "RemovePlacedInstanceIds", true, RpcLengthLimits.HouseFurnitureModification_RemovePlacedInstanceIds, nil)
end

Auto.WriteHouseFurnitureModificationResult = function(writer, val)
	Base.WriteList7Bit(writer, val.PlacedFurnitureInfos, Base.WriteComplexWrap(Auto.WritePlacedFurnitureInfo, "PlacedFurnitureInfo", true), nil, "PlacedFurnitureInfos", true, 0, nil)
	Base.WriteDict7Bit(writer, val.ShowcaseDict, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteHouseFashionShowcaseData, "HouseFashionShowcaseData", false), nil, "ShowcaseDict", true, RpcLengthLimits.HouseFurnitureModificationResult_ShowcaseDict)
end

Auto.WriteHouseFurniturePlacementStatistics = function(writer, val)
	Base.WriteDict(writer, val.FurniturePlacedCountDict, writer.WriteUInt32, writer.WriteUInt32, 0, "FurniturePlacedCountDict", false, 0)
	Base.WriteDict(writer, val.SubTypePlacedCountDict, writer.WriteUInt32, writer.WriteUInt32, 0, "SubTypePlacedCountDict", false, 0)
end

Auto.WriteHouseInfo = function(writer, val)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ParkingSpaceVehicleIdDict, writer.WriteInt32, writer.WriteUInt32, 0, "ParkingSpaceVehicleIdDict", false, 0)
	Base.WriteDict(writer, val.FloorBuildInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteIndoorBuildInfo, "IndoorBuildInfo", false), nil, "FloorBuildInfoDict", false, 0)
	Base.WritePrimitive(writer, val.CurPlacedFurnitureInstanceId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.WallInfo, Auto.WriteHouseWallInfo, "WallInfo", false)
	Base.WriteComplex(writer, val.Configuration, Auto.WritePlayerSingleHouseConfiguration, "Configuration", false)
	Base.WriteDict(writer, val.FashionShowcaseDict, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteHouseFashionShowcaseData, "HouseFashionShowcaseData", false), nil, "FashionShowcaseDict", false, 0)
	Base.WriteComplex(writer, val.PlacementStatistics, Auto.WriteHouseFurniturePlacementStatistics, "PlacementStatistics", false)
end

Auto.WriteHouseMetadata = function(writer, val)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.Flags, writer.WriteInt32, writer.WriteInt32, 0, "Flags", false, 0)
end

Auto.WriteHouseModification = function(writer, val)
	Base.WriteList7Bit(writer, val.FurnitureModification, Base.WriteStructWrap(Auto.WriteHouseFurnitureModification, "FurnitureModification"), nil, "FurnitureModification", true, RpcLengthLimits.HouseModification_FurnitureModification, nil)
	Base.WriteComplex(writer, val.WallModification, Auto.WriteHouseWallModification, "WallModification", true)
end

Auto.WriteHouseModificationResult = function(writer, val)
	Base.WriteComplex(writer, val.Wall, Auto.WriteHouseWallModificationResult, "Wall", true)
	Base.WriteComplex(writer, val.Furniture, Auto.WriteHouseFurnitureModificationResult, "Furniture", true)
end

Auto.WriteHouseMoveParkingSpaceInfo = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ParkingSpaceIndex, writer.WriteInt32, 0)
end

Auto.WriteHouseParkingEntityBinding = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ParkingSpaceIndex, writer.WriteInt32, 0)
end

Auto.WriteHouseParkingInfo = function(writer, val)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
end

Auto.WriteHouseShowcaseSwitchResult = function(writer, val)
	Base.WritePrimitive(writer, val.ModelIndex, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.FashionInfo, Auto.WriteSpiritWearFashionsInfo, "FashionInfo", false)
end

Auto.WriteHouseSocialClientInfo = function(writer, val)
	writer.WriteString(writer, val.PromoImageUrl, false, "HouseSocialClientInfo.PromoImageUrl", 0)
	writer.WriteString(writer, val.WelcomeText, false, "HouseSocialClientInfo.WelcomeText", 0)
	Base.WritePrimitive(writer, val.LikeCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BanExpireTime, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CanVisit, writer.WriteBoolean, false)
end

Auto.WriteHouseSocialInfo = function(writer, val)
	writer.WriteString(writer, val.PromoImageUrl, true, "HouseSocialInfo.PromoImageUrl", 0)
	writer.WriteString(writer, val.WelcomeText, true, "HouseSocialInfo.WelcomeText", 0)
end

Auto.WriteHouseSocialInfoSaveData = function(writer, val)
	writer.WriteString(writer, val.WelcomeText, true, "HouseSocialInfoSaveData.WelcomeText", RpcLengthLimits.HouseSocialInfoSaveData_WelcomeText)
end

Auto.WriteHouseVehicleParkingInfo = function(writer, val)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ParkingSpaceIndex, writer.WriteInt32, 0)
end

Auto.WriteHouseVisitInfo = function(writer, val)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsHost, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OwnerPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsTour, writer.WriteBoolean, false)
end

Auto.WriteHouseWallEdgeEntry = function(writer, val)
	Base.WritePrimitive(writer, val.From, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.To, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Data, Auto.WriteHouseWallEdgeValue, "Data")
end

Auto.WriteHouseWallEdgeTexData = function(writer, val)
	Base.WritePrimitive(writer, val.Left, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Right, writer.WriteUInt32, 0)
end

Auto.WriteHouseWallEdgeValue = function(writer, val)
	Base.WritePrimitive(writer, val.Tag, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.Tex, Auto.WriteHouseWallEdgeTexData, "Tex", true)
end

Auto.WriteHouseWallFloorKey = function(writer, val)
	Base.WritePrimitive(writer, val.X, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Y, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.FloorLevel, writer.WriteUInt32, 0)
end

Auto.WriteHouseWallFloorMaskData = function(writer, val)
	Base.WritePrimitive(writer, val.HypoTenuseMaskA, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HypoTenuseMaskB, writer.WriteUInt32, 0)
end

Auto.WriteHouseWallFloorModEntry = function(writer, val)
	Base.WriteStruct(writer, val.Key, Auto.WriteHouseWallFloorKey, "Key")
	Base.WriteStruct(writer, val.Value, Auto.WriteHouseWallFloorValue, "Value")
end

Auto.WriteHouseWallFloorTexData = function(writer, val)
	Base.WritePrimitive(writer, val.Top, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Bottom, writer.WriteUInt32, 0)
end

Auto.WriteHouseWallFloorValue = function(writer, val)
	Base.WriteComplex(writer, val.Mask, Auto.WriteHouseWallFloorMaskData, "Mask", true)
	Base.WriteComplex(writer, val.Tex, Auto.WriteHouseWallFloorTexData, "Tex", true)
end

Auto.WriteHouseWallInfo = function(writer, val)
	Base.WriteDict(writer, val.Nodes, writer.WriteInt32, Base.WriteComplexWrap(Auto.WriteUXVector3, "UXVector3", false), nil, "Nodes", false, 0)
	Base.WriteDict(writer, val.Edges, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteHouseWallEdgeValue, "HouseWallEdgeValue", false), nil, "Edges", false, 0)
	Base.WriteDict(writer, val.Floors, Base.WriteStringWrap(false, "Floors", 0), Base.WriteComplexWrap(Auto.WriteHouseWallFloorValue, "HouseWallFloorValue", false), nil, "Floors", false, 0)
	Base.WriteDict(writer, val.FenestrationDict, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteHouseFenestrationData, "HouseFenestrationData", false), nil, "FenestrationDict", false, 0)
	Base.WriteDict(writer, val.FloorsByLevel, writer.WriteInt32, Base.WriteComplexWrap(Auto.WriteHouseFloorsData, "HouseFloorsData", false), nil, "FloorsByLevel", false, 0)
end

Auto.WriteHouseWallModification = function(writer, val)
	Base.WriteList7Bit(writer, val.DelNodeList, writer.WriteInt32, 0, "DelNodeList", true, RpcLengthLimits.HouseWallModification_DelNodeList, nil)
	Base.WriteList7Bit(writer, val.AddNodeList, Base.WriteStructWrap(Auto.WriteHouseWallNodeEntry, "AddNodeList"), nil, "AddNodeList", true, RpcLengthLimits.HouseWallModification_AddNodeList, nil)
	Base.WriteList7Bit(writer, val.ModNodeList, Base.WriteStructWrap(Auto.WriteHouseWallNodeEntry, "ModNodeList"), nil, "ModNodeList", true, RpcLengthLimits.HouseWallModification_ModNodeList, nil)
	Base.WriteList7Bit(writer, val.DelEdgeList, writer.WriteUInt64, 0, "DelEdgeList", true, RpcLengthLimits.HouseWallModification_DelEdgeList, nil)
	Base.WriteList7Bit(writer, val.AddEdgeList, Base.WriteStructWrap(Auto.WriteHouseWallEdgeEntry, "AddEdgeList"), nil, "AddEdgeList", true, RpcLengthLimits.HouseWallModification_AddEdgeList, nil)
	Base.WriteList7Bit(writer, val.ModEdgeList, Base.WriteStructWrap(Auto.WriteHouseWallEdgeEntry, "ModEdgeList"), nil, "ModEdgeList", true, RpcLengthLimits.HouseWallModification_ModEdgeList, nil)
	Base.WriteList7Bit(writer, val.DelFloorList, Base.WriteStructWrap(Auto.WriteHouseWallFloorKey, "DelFloorList"), nil, "DelFloorList", true, RpcLengthLimits.HouseWallModification_DelFloorList, nil)
	Base.WriteList7Bit(writer, val.AddFloorList, Base.WriteStructWrap(Auto.WriteHouseWallFloorModEntry, "AddFloorList"), nil, "AddFloorList", true, RpcLengthLimits.HouseWallModification_AddFloorList, nil)
	Base.WriteList7Bit(writer, val.ModFloorList, Base.WriteStructWrap(Auto.WriteHouseWallFloorModEntry, "ModFloorList"), nil, "ModFloorList", true, RpcLengthLimits.HouseWallModification_ModFloorList, nil)
	Base.WriteList7Bit(writer, val.DelFenestrationList, writer.WriteUInt64, 0, "DelFenestrationList", true, RpcLengthLimits.HouseWallModification_DelFenestrationList, nil)
	Base.WriteList7Bit(writer, val.AddFenestrationList, Base.WriteComplexWrap(Auto.WriteHouseFenestrationData, "HouseFenestrationData", true), nil, "AddFenestrationList", true, RpcLengthLimits.HouseWallModification_AddFenestrationList, nil)
	Base.WriteList7Bit(writer, val.ModFenestrationList, Base.WriteComplexWrap(Auto.WriteHouseFenestrationData, "HouseFenestrationData", true), nil, "ModFenestrationList", true, RpcLengthLimits.HouseWallModification_ModFenestrationList, nil)
end

Auto.WriteHouseWallModificationResult = function(writer, val)
	Base.WriteList7Bit(writer, val.AddedFenestrations, Base.WriteComplexWrap(Auto.WriteHouseFenestrationData, "HouseFenestrationData", true), nil, "AddedFenestrations", true, 0, nil)
end

Auto.WriteHouseWallNodeEntry = function(writer, val)
	Base.WritePrimitive(writer, val.NodeId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

Auto.WriteHousesInfo = function(writer, val)
	Base.WriteList(writer, val.OutdatedHouses, Base.WriteComplexWrap(Auto.WriteHouseInfo, "HouseInfo", false), nil, "OutdatedHouses", false, 0, nil)
	Base.WriteList(writer, val.NotParkingSpaceVehicleIdList, writer.WriteUInt32, 0, "NotParkingSpaceVehicleIdList", false, 0, nil)
	Base.WriteDict(writer, val.FurnitureInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFurnitureInfo, "FurnitureInfo", false), nil, "FurnitureInfoDict", false, 0)
	Base.WriteComplex(writer, val.Configuration, Auto.WritePlayerHouseConfiguration, "Configuration", false)
	Base.WritePrimitive(writer, val.NextFashionInstanceId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.HouseMetadataList, Base.WriteComplexWrap(Auto.WriteHouseMetadata, "HouseMetadata", false), nil, "HouseMetadataList", false, 0, nil)
	Base.WriteList(writer, val.HouseInfoList, Base.WriteComplexWrap(Auto.WriteHouseBaseInfo, "HouseBaseInfo", false), nil, "HouseInfoList", false, 0, nil)
	Base.WritePrimitive(writer, val.LastOrphanScanTime, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.HouseLikesToday, writer.WriteUInt64, writer.WriteBoolean, false, "HouseLikesToday", false, 0)
	Base.WritePrimitive(writer, val.LastLikeResetTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextFurnitureIndex, writer.WriteUInt32, 0)
end

Auto.WriteIKMotionCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.IKTargetBone, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.AnimId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SelectedActionIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UseRemapping, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CycleNum, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.RemappingLeg, 114, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.StartPosition, Auto.WriteUXVector3, "StartPosition")
	Base.WriteStruct(writer, val.StartDirection, Auto.WriteUXVector3, "StartDirection")
	Base.WritePrimitive(writer, val.AutoRemapping, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.AutoRemappingMoveType, 115, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteImSimpleData = function(writer, val)
	Base.WriteList7Bit(writer, val.ChatGroupList, Base.WriteComplexWrap(Auto.WriteChatGroupClient, "ChatGroupClient", false), nil, "ChatGroupList", false, 0, nil)
	Base.WritePrimitive(writer, val.MuteEndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SoftMuteEndTime, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.FavoriteEmojiList, Base.WriteStringWrap(false, "FavoriteEmojiList", 0), nil, "FavoriteEmojiList", false, 0, nil)
end

Auto.WriteImageModerationResult = function(writer, val)
	writer.WriteString(writer, val.ObjectKey, false, "ImageModerationResult.ObjectKey", 0)
	Base.WritePrimitive(writer, val.Pass, writer.WriteBoolean, false)
end

Auto.WriteInTurnOperation = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 188, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Tile, Auto.WriteTile, "Tile")
	Base.WriteStruct(writer, val.Meld, Auto.WriteOpenMeld, "Meld")
	Base.WriteList7Bit(writer, val.RichiAvailableTiles, Base.WriteStructWrap(Auto.WriteTile, "RichiAvailableTiles"), nil, "RichiAvailableTiles", false, 0, nil)
end

Auto.WriteIndoorBuildInfo = function(writer, val)
	Base.WriteComplex(writer, val.Root, Auto.WritePlacedFurnitureInfo, "Root", false)
end

Auto.WriteIndoorLimitChangeInfo = function(writer, val)
	Base.WritePrimitive(writer, val.IndoorId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BoundId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.LimitIds, writer.WriteUInt32, 0, "LimitIds", false, 0, nil)
	Base.WritePrimitive(writer, val.Ignore, writer.WriteBoolean, false)
end

Auto.WriteInspireHubGamePlayInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weight, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Category, writer.WriteUInt32, 0)
end

Auto.WriteInspireHubGamePlayRankData = function(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BaseScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AdditionalScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Category, writer.WriteUInt32, 0)
end

Auto.WriteInspireHubGamePlayRankList = function(writer, val)
	Base.WritePrimitive(writer, val.RankType, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.RankList, Base.WriteComplexWrap(Auto.WriteInspireHubGamePlayRankData, "InspireHubGamePlayRankData", false), nil, "RankList", false, 0, nil)
end

Auto.WriteIntList = function(writer, val)
	Base.WriteList(writer, val.Value, writer.WriteInt32, 0, "Value", false, 0, nil)
end

Auto.WriteIntPayload = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteInt32, 0)
end

Auto.WriteInteractCmdData = function(writer, val)
	Base.WritePrimitive(writer, val.CmdType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.sender, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.receiver, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.broadCastType, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.CommandData, writer.WriteByte, 0, "CommandData", true, RpcLengthLimits.InteractCmdData_CommandData, val.CommandDataLen)
	writer.WriteString(writer, val.stringParam1, true, "InteractCmdData.stringParam1", RpcLengthLimits.InteractCmdData_stringParam1)
	writer.WriteString(writer, val.stringParam2, true, "InteractCmdData.stringParam2", RpcLengthLimits.InteractCmdData_stringParam2)
end

Auto.WriteInteractCommandData = function(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.InteractType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteInteractIconItem = function(writer, val)
	Base.WritePrimitive(writer, val.InteractingId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
end

Auto.WriteInterrogationAICallContext = function(writer, val)
	Base.WritePrimitive(writer, val.CaseId, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.Sid, false, "InterrogationAICallContext.Sid", RpcLengthLimits.InterrogationAICallContext_Sid)
end

Auto.WriteInterrogationInterruptInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CaseId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.InterruptReason, writer.WriteUInt32, 0)
end

Auto.WriteInterrogationResults = function(writer, val)
	Base.WriteComplex(writer, val.aiResult, Auto.WriteAIInterrogationSettlement, "aiResult", true)
end

Auto.WriteInviteRideNpcInteractItem = function(writer, val)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Sprite, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LabelId, writer.WriteUInt32, 0)
end

Auto.WriteItemCountInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Quality, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Tags, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsBind, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.Components, Auto.WritePackItemComponents, "Components", true)
end

Auto.WriteItemCountLimitInfo = function(writer, val)
	Base.WritePrimitive(writer, val.ItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextRefreshTime, writer.WriteUInt32, 0)
end

Auto.WriteItemDestructibleData = function(writer, val)
	Base.WritePrimitive(writer, val.WorldLifeGameInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.FishGroupId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SceneItemCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.LivingTime, writer.WriteSingle, 0)
end

Auto.WriteItemShortcutInfo = function(writer, val)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
end

Auto.WriteJobBoardEntry = function(writer, val)
	Base.WritePrimitive(writer, val.BoardId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.JobId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.JobClassId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 189, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.UnlockProgress, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnlockTarget, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CanResign, writer.WriteBoolean, false)
end

Auto.WriteJobBoardEntryList = function(writer, val)
	Base.WriteList7Bit(writer, val.Entries, Base.WriteComplexWrap(Auto.WriteJobBoardEntry, "JobBoardEntry", false), nil, "Entries", false, 0, nil)
end

Auto.WriteJobBoardInfo = function(writer, val)
	Base.WritePrimitive(writer, val.JoinedJobCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxJobCount, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.CountryJobEntries, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteJobBoardEntryList, "JobBoardEntryList", false), nil, "CountryJobEntries", false, 0)
	Base.WriteDict7Bit(writer, val.HiddenCountPerCity, writer.WriteUInt32, writer.WriteUInt32, 0, "HiddenCountPerCity", false, 0)
end

Auto.WriteKTVMusicClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.MusicId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HighScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxCombo, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HighScorePercent, writer.WriteDouble, 0)
end

Auto.WriteKTVMusicInfoListResult = function(writer, val)
	Base.WriteList7Bit(writer, val.MusicInfos, Base.WriteComplexWrap(Auto.WriteKTVMusicClientInfo, "KTVMusicClientInfo", false), nil, "MusicInfos", false, 0, nil)
end

Auto.WriteKTVMusicResultInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TicketId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MusicId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.RecordInfo, writer.WriteUInt32, 0, "RecordInfo", false, RpcLengthLimits.KTVMusicResultInfo_RecordInfo, nil)
	Base.WritePrimitive(writer, val.HoldBeats, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxCombo, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalPossible, writer.WriteUInt32, 0)
end

Auto.WriteKTVPackageTicket = function(writer, val)
	Base.WritePrimitive(writer, val.TicketId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RemainCount, writer.WriteUInt32, 0)
end

Auto.WriteKongInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.KongPlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MeldIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.HandData, Auto.WritePlayerHandData, "HandData")
	Base.WritePrimitive(writer, val.RemainTurnTime, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Operations, Base.WriteStructWrap(Auto.WriteOutTurnOperation, "Operations"), nil, "Operations", false, 0, nil)
	Base.WriteStruct(writer, val.MahjongSetData, Auto.WriteMahjongSetData, "MahjongSetData")
end

Auto.WriteLandInfo = function(writer, val)
	Base.WritePrimitive(writer, val.LandId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CorpId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SourceGrowState, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TargetGrowState, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LastWaterTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.CurrentProductCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastReapTime, writer.WriteDouble, 0)
end

Auto.WriteLeadingWayMoveCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.PartnerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsDirector, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.WayPoints, Base.WriteStructWrap(Auto.WriteUXVector3, "WayPoints"), nil, "WayPoints", false, 0, nil)
	Base.WriteList7Bit(writer, val.CheckPointActions, Base.WriteComplexWrap(Auto.WriteCheckPointAction, "CheckPointAction", false), nil, "CheckPointActions", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveMethod, 115, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartPace, 115, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.StartPaceDuration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AnimationSetId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.KeepMovingAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveActionGroupId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NotOnGround, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TryUseRootMotion, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LeadingBreakTurn, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsLeadingWay, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DontLimitExtraMove, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DontLimitBasicMove, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.WaitingDialogId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MinDialogDuration, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.LeadingWayUrgings, Base.WriteStructWrap(Auto.WriteLeadingWayUrging, "LeadingWayUrgings"), nil, "LeadingWayUrgings", true, 0, nil)
	Base.WritePrimitive(writer, val.LeadingWayCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteLeadingWayUrging = function(writer, val)
	Base.WritePrimitive(writer, val.dialogId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.minDuration, writer.WriteSingle, 0)
end

Auto.WriteLevelLandmarkActivityData = function(writer, val)
	Base.WriteDict(writer, val.AwardGotInfo, writer.WriteUInt32, writer.WriteBoolean, false, "AwardGotInfo", false, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowRedPoint, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsOutOfDate, writer.WriteBoolean, false)
end

Auto.WriteLifeScheduleClientMessage = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Op, 190, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Event, 191, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PlayerId, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.Reason, true, "LifeScheduleClientMessage.Reason", RpcLengthLimits.LifeScheduleClientMessage_Reason)
	Base.WritePrimitive(writer, val.ActivityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WorldEventType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CorrelationId, writer.WriteUInt64, 0)
end

Auto.WriteLifeScheduleDebugEventDto = function(writer, val)
	Base.WritePrimitive(writer, val.RecordId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TimestampMs, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Side, 192, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.AgentTag, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActivityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Category, 193, 1), writer.WriteByte, 1)
	writer.WriteString(writer, val.Summary, false, "LifeScheduleDebugEventDto.Summary", RpcLengthLimits.LifeScheduleDebugEventDto_Summary)
	writer.WriteString(writer, val.PayloadJson, false, "LifeScheduleDebugEventDto.PayloadJson", RpcLengthLimits.LifeScheduleDebugEventDto_PayloadJson)
	Base.WritePrimitive(writer, val.Sequence, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Frame, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PrevState, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CauseEvent, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CauseId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OwnerId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Severity, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TraceId, writer.WriteUInt32, 0)
end

Auto.WriteLifeScheduleHostEventMessage = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Event, 194, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ActivityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CorrelationId, writer.WriteUInt64, 0)
end

Auto.WriteLifeScheduleNpcHistoryDto = function(writer, val)
	Base.WritePrimitive(writer, val.AgentTag, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Events, Base.WriteComplexWrap(Auto.WriteLifeScheduleDebugEventDto, "LifeScheduleDebugEventDto", false), nil, "Events", false, RpcLengthLimits.LifeScheduleNpcHistoryDto_Events, nil)
	Base.WritePrimitive(writer, val.EarlierEventsOverwritten, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HasMore, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DroppedCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ServerSampleTimeMs, writer.WriteInt64, 0)
end

Auto.WriteLifeScheduleNpcSnapshotEntry = function(writer, val)
	Base.WritePrimitive(writer, val.AgentTag, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ActivityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ServerState, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.IsLent, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RingEventCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LastEventTimeMs, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.PreviousServerState, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.IsCommuting, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CommuteHasData, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CommuteSegmentIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CommuteSegmentCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CommuteRemainingDistanceXZ, writer.WriteSingle, 0)
end

Auto.WriteLifeScheduleNpcsSnapshotDto = function(writer, val)
	Base.WriteList7Bit(writer, val.Entries, Base.WriteComplexWrap(Auto.WriteLifeScheduleNpcSnapshotEntry, "LifeScheduleNpcSnapshotEntry", false), nil, "Entries", false, RpcLengthLimits.LifeScheduleNpcsSnapshotDto_Entries, nil)
	Base.WritePrimitive(writer, val.ServerSampleTimeMs, writer.WriteInt64, 0)
end

Auto.WriteLifeScheduleServerMessage = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.NewState, 195, 0), writer.WriteInt16, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CauseEvent, 191, 0), writer.WriteByte, 0)
	writer.WriteString(writer, val.Reason, true, "LifeScheduleServerMessage.Reason", RpcLengthLimits.LifeScheduleServerMessage_Reason)
	Base.WriteComplex(writer, val.ExtCtrlParam, Auto.WriteExternalControlParamDto, "ExtCtrlParam", true)
	Base.WritePrimitive(writer, val.CorrelationId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.EntryPos, Auto.WriteUXVector3, "EntryPos")
	Base.WritePrimitive(writer, val.EntryFacing, writer.WriteSingle, 0)
end

Auto.WriteLiftInteractBanInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 196, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.SpecificLevelList, writer.WriteInt32, 0, "SpecificLevelList", true, 0, nil)
end

Auto.WriteLinkAIAgentInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.FightSpiritId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.Fashion, Auto.WriteLinkAIFashionInfo, "Fashion", true)
	writer.WriteString(writer, val.Nickname, true, "LinkAIAgentInfo.Nickname", 0)
	Base.WritePrimitive(writer, val.NameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AvatarImageId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
end

Auto.WriteLinkAIFashionInfo = function(writer, val)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.WearInfo, Auto.WriteOtherPlayerSpiritWearFashionsInfo, "WearInfo", false)
end

Auto.WriteLinkInfoClient = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Mode, 8, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DeviceLevel, 45, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Tag, 22, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Members, Base.WriteComplexWrap(Auto.WritePlayerBasicInfoVO, "PlayerBasicInfoVO", false), nil, "Members", false, 0, nil)
	Base.WriteList7Bit(writer, val.ReservePids, writer.WriteUInt64, 0, "ReservePids", false, 0, nil)
	Base.WritePrimitive(writer, val.TeamReservedCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Capacity, writer.WriteUInt32, 0)
end

Auto.WriteLinkMemberInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.JoinTime, writer.WriteUInt32, 0)
end

Auto.WriteLinkPlanningBoardMemberInfo = function(writer, val)
	Base.WriteDict(writer, val.MemberKeyCounts, writer.WriteUInt32, writer.WriteUInt32, 0, "MemberKeyCounts", true, 0)
	Base.WriteComplex(writer, val.TeamSettingsInfo, Auto.WriteLinkPlanningBoardTeamSettingsInfo, "TeamSettingsInfo", true)
	Base.WriteDict(writer, val.MultiPlayerIdStates, writer.WriteUInt32, writer.WriteByte, 0, "MultiPlayerIdStates", true, 0)
end

Auto.WriteLinkPlanningBoardTeamSettingsInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TeamLeaderSelectMultiPlayerId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ClientCustomDatas, writer.WriteByte, writer.WriteUInt32, 0, "ClientCustomDatas", true, RpcLengthLimits.LinkPlanningBoardTeamSettingsInfo_ClientCustomDatas)
end

Auto.WriteLinkSimpleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Mode, 8, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DeviceLevel, 45, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Tag, 22, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PublicEventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastPublicEventTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HostPid, writer.WriteUInt64, 0)
end

Auto.WriteLinkedTimelineInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TimelineId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 197, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.PlayType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Progress, writer.WriteDouble, 0)
end

Auto.WriteLiveHouseQueryInfo = function(writer, val)
	Base.WritePrimitive(writer, val.FirstPlay, writer.WriteBoolean, false)
end

Auto.WriteLoadingTextInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeftTimes, writer.WriteUInt32, 0)
end

Auto.WriteLoadingTypeInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 198, 0), writer.WriteByte, 0)
	Base.WriteList(writer, val.Members, writer.WriteUInt64, 0, "Members", true, 0, nil)
	Base.WritePrimitive(writer, val.Ripple, writer.WriteBoolean, false)
end

Auto.WriteLogicAgentCommandReportData = function(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Data, writer.WriteByte, 0, "Data", true, RpcLengthLimits.LogicAgentCommandReportData_Data, val.Length)
	Base.WritePrimitive(writer, val.Layer, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StateLayer, 199, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt32, 0)
end

Auto.WriteLogicAgentCommandSuccessData = function(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CommandId, writer.WriteInt32, 0)
end

Auto.WriteLogicAgentSyncData = function(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
end

Auto.WriteLogicItemInfo = function(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SceneItemCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EntityType, writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.EffectIds, writer.WriteInt32, 0, "EffectIds", true, 0, nil)
	Base.WriteComplex(writer, val.SpecialState, Auto.WriteLogicItemSpecialStateInfo, "SpecialState", true)
	Base.WriteComplex(writer, val.HangingInfo, Auto.WriteSceneDeviceHangingInfo, "HangingInfo", true)
	Base.WriteComplex(writer, val.NpcPhone, Auto.WriteNpcPhoneInfo, "NpcPhone", true)
end

Auto.WriteLogicItemSpecialStateInfo = function(writer, val)
	Base.WritePrimitive(writer, val.UmbrellaOpen, writer.WriteBoolean, false)
end

Auto.WriteLogicVehicleClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CreateSourceType, 200, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Parts, Base.WriteStructWrap(Auto.WriteVehicleClientPart, "Parts"), nil, "Parts", true, 0, nil)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.LicensePlate, true, "LogicVehicleClientInfo.LicensePlate", 0)
	Base.WritePrimitive(writer, val.Interactable, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MoveToken, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
	writer.WriteString(writer, val.VehicleSpoonName, true, "LogicVehicleClientInfo.VehicleSpoonName", 0)
end

Auto.WriteLogicVehicleUnitDebugData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.FineId, writer.WriteUInt32, 0, "FineId", false, 0, nil)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

Auto.WriteLoginPartyInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PartyId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.InviteNPCIds, writer.WriteUInt32, 0, "InviteNPCIds", true, 0, nil)
	Base.WritePrimitive(writer, val.Popularity, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LikeCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GiftCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Duration, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PrepareOverTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PartyOverTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LotteryStartTime, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.LotteryResults, Base.WriteComplexWrap(Auto.WriteLotteryDrawResult, "LotteryDrawResult", true), nil, "LotteryResults", true, 0, nil)
end

Auto.WriteLongPayload = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteInt64, 0)
end

Auto.WriteLookAtCommandData = function(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.IsOn, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TargetType, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.TargetPosition, Auto.WriteUXVector3, "TargetPosition")
	Base.WritePrimitive(writer, val.IsKeep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsFinishOnEnd, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Duration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IKPriority, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LookAtIKType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.AgentTargetPart, writer.WriteInt32, 0)
	writer.WriteString(writer, val.LookAtProfileKey, false, "LookAtCommandData.LookAtProfileKey", 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteLookAtPositionData = function(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsImmediate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionUid, writer.WriteUInt32, 0)
end

Auto.WriteLookAtTargetData = function(writer, val)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsImmediate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionUid, writer.WriteUInt32, 0)
end

Auto.WriteLotteryDrawResult = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

Auto.WriteMahjongGameInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameState, 201, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Round, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Remainders, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Banker, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Turn, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LastTurn, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LastMoPaiSeatIndex, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.SeatInfos, Base.WriteComplexWrap(Auto.WriteSeatInfo, "SeatInfo", true), nil, "SeatInfos", true, 0, nil)
	Base.WriteList7Bit(writer, val.HuPais, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "HuPais"), nil, "HuPais", true, 0, nil)
	Base.WriteList7Bit(writer, val.DoraIndicatorLs, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "DoraIndicatorLs"), nil, "DoraIndicatorLs", true, 0, nil)
	Base.WriteList7Bit(writer, val.DoraLs, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "DoraLs"), nil, "DoraLs", true, 0, nil)
	Base.WriteList7Bit(writer, val.UraDoraIndicatorLs, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "UraDoraIndicatorLs"), nil, "UraDoraIndicatorLs", true, 0, nil)
	Base.WriteList7Bit(writer, val.UraDoraLs, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "UraDoraLs"), nil, "UraDoraLs", true, 0, nil)
end

Auto.WriteMahjongPlayerInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Name, false, "MahjongPlayerInfo.Name", 0)
	Base.WriteComplex(writer, val.PzHeadInfo, Auto.WritePersonalZoneHeadInfo, "PzHeadInfo", true)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NpcMahjongId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
end

Auto.WriteMahjongRoomInfo = function(writer, val)
	Base.WritePrimitive(writer, val.MahjongServerId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RoomId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.RoomType, 12, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 202, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.PlayerInfos, Base.WriteComplexWrap(Auto.WriteMahjongPlayerInfo, "MahjongPlayerInfo", true), nil, "PlayerInfos", true, 0, nil)
	Base.WriteList7Bit(writer, val.HasReady, writer.WriteBoolean, false, "HasReady", false, 0, nil)
	Base.WritePrimitive(writer, val.RoomOwnerSeatIndex, writer.WriteInt32, 0)
end

Auto.WriteMahjongSetData = function(writer, val)
	Base.WritePrimitive(writer, val.TilesDrawn, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DoraTurned, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LingShangDrawn, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TilesRemain, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.DoraIndicators, Base.WriteStructWrap(Auto.WriteTile, "DoraIndicators"), nil, "DoraIndicators", false, 0, nil)
	Base.WritePrimitive(writer, val.TotalTiles, writer.WriteInt32, 0)
end

Auto.WriteMahjongWorldBattleRoomInfo = function(writer, val)
	Base.WritePrimitive(writer, val.GadgetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.OwnerPid, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Players, Base.WriteComplexWrap(Auto.WriteMahjongWorldBattleRoomPlayerInfo, "MahjongWorldBattleRoomPlayerInfo", false), nil, "Players", false, 0, nil)
end

Auto.WriteMahjongWorldBattleRoomPlayerInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Duty, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Ready, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsOwner, writer.WriteBoolean, false)
end

Auto.WriteMaidTeaChoiceInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.Choices, writer.WriteInt32, 0, "Choices", false, RpcLengthLimits.MaidTeaChoiceInfo_Choices, nil)
end

Auto.WriteMaidTeaMemeberInfo = function(writer, val)
	Base.WritePrimitive(writer, val.VisitTimes, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.UnlockDrinks, writer.WriteUInt32, 0, "UnlockDrinks", false, 0, nil)
end

Auto.WriteMailAttachment = function(writer, val)
	Base.WriteList(writer, val.Items, Base.WriteComplexWrap(Auto.WriteItemCountInfo, "ItemCountInfo", true), nil, "Items", true, 0, nil)
	Base.WritePrimitive(writer, val.UnbindMoney, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.BindGold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.PayGold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.FreeGold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Popularity, writer.WriteSingle, 0)
	Base.WriteDict(writer, val.JobExpInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "JobExpInfo", true, 0)
	Base.WriteDict(writer, val.FanInfo, writer.WriteUInt32, writer.WriteInt32, 0, "FanInfo", true, 0)
	Base.WriteDict(writer, val.FactionDispositionInfo, writer.WriteUInt32, writer.WriteInt32, 0, "FactionDispositionInfo", true, 0)
	Base.WriteDict(writer, val.FactionInfluenceInfo, writer.WriteUInt32, writer.WriteInt32, 0, "FactionInfluenceInfo", true, 0)
	Base.WriteDict(writer, val.AbilityExpInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "AbilityExpInfo", true, 0)
	Base.WriteComplex(writer, val.SpiritTalentExpInfo, Auto.WriteSpiritTalentExpInfo, "SpiritTalentExpInfo", true)
	Base.WritePrimitive(writer, val.CommonSpiritTalentExp, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.WeaponList, writer.WriteUInt32, 0, "WeaponList", true, 0, nil)
	Base.WriteDict(writer, val.BattlePassExpInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "BattlePassExpInfo", true, 0)
	Base.WriteDict(writer, val.ExtractionShooterInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "ExtractionShooterInfo", true, 0)
	Base.WriteList(writer, val.RumorIds, writer.WriteUInt32, 0, "RumorIds", true, 0, nil)
	Base.WriteDict(writer, val.SeasonProgressInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "SeasonProgressInfo", true, 0)
	Base.WriteList(writer, val.FishingFishRewards, Base.WriteComplexWrap(Auto.WriteFishingFishRewardInfo, "FishingFishRewardInfo", true), nil, "FishingFishRewards", true, 0, nil)
	Base.WriteList(writer, val.FishingGearRewards, writer.WriteUInt32, 0, "FishingGearRewards", true, 0, nil)
	Base.WriteList(writer, val.WeaponDataList, Base.WriteComplexWrap(Auto.WriteWeaponData, "WeaponData", true), nil, "WeaponDataList", true, 0, nil)
end

Auto.WriteMailHead = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MailId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Title, true, "MailHead.Title", 0)
	Base.WriteList7Bit(writer, val.TitleParams, Base.WriteComplexWrap(Auto.WriteMailParameter, "MailParameter", true), nil, "TitleParams", true, 0, nil)
	writer.WriteString(writer, val.SenderName, true, "MailHead.SenderName", 0)
	Base.WritePrimitive(writer, val.IsGlobal, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HasItem, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.Attachment, Auto.WriteSimpleMailAttchment, "Attachment", true)
	Base.WritePrimitive(writer, val.IsFavorite, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsRetrieved, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Tab, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsRead, writer.WriteBoolean, false)
end

Auto.WriteMailInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 25, 0), writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsGlobal, writer.WriteBoolean, false)
	writer.WriteString(writer, val.SenderName, true, "MailInfo.SenderName", 0)
	writer.WriteString(writer, val.Title, true, "MailInfo.Title", 0)
	Base.WriteList(writer, val.TitleParams, Base.WriteComplexWrap(Auto.WriteMailParameter, "MailParameter", true), nil, "TitleParams", true, 0, nil)
	writer.WriteString(writer, val.Content, true, "MailInfo.Content", 0)
	Base.WriteList(writer, val.ContentParams, Base.WriteComplexWrap(Auto.WriteMailParameter, "MailParameter", true), nil, "ContentParams", true, 0, nil)
	Base.WritePrimitive(writer, val.RewardTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MailId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.JsonAttachment, true, "MailInfo.JsonAttachment", 0)
	Base.WriteComplex(writer, val.Attachment, Auto.WriteMailAttachment, "Attachment", true)
	Base.WritePrimitive(writer, val.HasAttachment, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Tag, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsRetrieved, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsFavorite, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.GlobalMailVersion, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ReceiveTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsExpireTimeAt, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ExpireTimeOffline, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IncludePlayerAfterSend, writer.WriteBoolean, false)
	Base.WriteList(writer, val.Platforms, writer.WriteInt32, 0, "Platforms", true, 0, nil)
	Base.WritePrimitive(writer, val.IsRead, writer.WriteBoolean, false)
end

Auto.WriteMailParameter = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ParamType, 203, 0), writer.WriteByte, 0)
	writer.WriteString(writer, val.Data, false, "MailParameter.Data", 0)
end

Auto.WriteMallCartBuyItem = function(writer, val)
	Base.WritePrimitive(writer, val.CommodityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

Auto.WriteMallCartItemInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CommodityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AddTime, writer.WriteUInt32, 0)
end

Auto.WriteMallCommodityInfo = function(writer, val)
	Base.WritePrimitive(writer, val.BoughtCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextRefreshTime, writer.WriteUInt32, 0)
end

Auto.WriteMallInfo = function(writer, val)
	Base.WriteDict(writer, val.CommodityInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteMallCommodityInfo, "MallCommodityInfo", false), nil, "CommodityInfoDict", false, 0)
	Base.WriteComplex(writer, val.PlayerMonthlyPassInfo, Auto.WritePlayerMonthlyPassInfo, "PlayerMonthlyPassInfo", false)
	Base.WriteList(writer, val.CartItemList, Base.WriteComplexWrap(Auto.WriteMallCartItemInfo, "MallCartItemInfo", false), nil, "CartItemList", false, 0, nil)
end

Auto.WriteMapPin = function(writer, val)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PosAdjusted, writer.WriteBoolean, false)
end

Auto.WriteMartialArtistSlotInfo = function(writer, val)
	Base.WriteDict(writer, val.Slots, writer.WriteUInt32, writer.WriteUInt32, 0, "Slots", false, 0)
end

Auto.WriteMassCustomArea = function(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Hide, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.Points, Base.WriteStructWrap(Auto.WriteUXVector3, "Points"), nil, "Points", true, 0, nil)
	Base.WritePrimitive(writer, val.HideType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EntityType, writer.WriteInt64, 0)
end

Auto.WriteMassTrafficSpawnArea = function(writer, val)
	Base.WriteList(writer, val.SpawnLaneSelector, Base.WriteStructWrap(Auto.WriteSpawnLaneSelector, "SpawnLaneSelector"), nil, "SpawnLaneSelector", false, 0, nil)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UseCustomizedSeed, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Seed, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UseIntervalBetweenLanes, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MinSpawnInterval, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxSpawnInterval, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpawnVehicleContinuously, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FilledWithVehicleAtStart, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RemoveVehicleWhenOutOfArea, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UseSameVelocityConfig, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MinVehicleSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxVehicleSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UseCustomizedVehicle, writer.WriteBoolean, false)
end

Auto.WriteMassTrafficSpawnAreaManager = function(writer, val)
	Base.WritePrimitive(writer, val.ClearAllNormalVehicles, writer.WriteBoolean, false)
	Base.WriteList(writer, val.TrafficSpawnAreas, Base.WriteStructWrap(Auto.WriteSpawnAreaSelector, "TrafficSpawnAreas"), nil, "TrafficSpawnAreas", false, 0, nil)
end

Auto.WriteMatchContext = function(writer, val)
	Base.WritePrimitive(writer, val.MyTeamAvgMMR, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OpponentAvgMMR, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsBotMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TotalPlayers, writer.WriteInt32, 0)
end

Auto.WriteMatchGameBestRecord = function(writer, val)
	Base.WritePrimitive(writer, val.MaxScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxCombo, writer.WriteUInt32, 0)
end

Auto.WriteMatchGameFlipResult = function(writer, val)
	Base.WritePrimitive(writer, val.IsMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CurrentScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentCombo, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RemainingSec, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsCleared, writer.WriteBoolean, false)
end

Auto.WriteMatchGameSettleResult = function(writer, val)
	Base.WritePrimitive(writer, val.IsWin, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BaseScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ComboBonusTotal, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TimeBonus, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FinalScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NewMaxScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NewMaxCombo, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RewardTier, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.RewardDropAmounts, writer.WriteUInt32, writer.WriteUInt32, 0, "RewardDropAmounts", false, 0)
end

Auto.WriteMatchGameStartInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.IconIds, writer.WriteUInt32, 0, "IconIds", false, 0, nil)
	Base.WritePrimitive(writer, val.TotalTimeSec, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Rows, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Cols, writer.WriteUInt32, 0)
end

Auto.WriteMatchPlayerSettleData = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.Name, false, "MatchPlayerSettleData.Name", 0)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ElapsedTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.AutoLeaveTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Result, 204, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.gameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ForceQuit, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TotalAddMoney, writer.WriteInt64, 0)
	Base.WriteComplex(writer, val.rewardSettleData, Auto.WriteRewardSettleData, "rewardSettleData", true)
	Base.WriteComplex(writer, val.raidSettleData, Auto.WriteRaidSettleData, "raidSettleData", true)
	Base.WriteComplex(writer, val.raceSettleData, Auto.WriteRaceSettleData, "raceSettleData", true)
	Base.WriteComplex(writer, val.extractionSettleData, Auto.WriteExtractionSettleData, "extractionSettleData", true)
	Base.WriteComplex(writer, val.BattleStatisticInfos, Auto.WriteBattleStatisticInfos, "BattleStatisticInfos", true)
	Base.WriteComplex(writer, val.DartSettleData, Auto.WriteDartSettleData, "DartSettleData", true)
	Base.WriteComplex(writer, val.BowlingSettleData, Auto.WriteBowlingSettleData, "BowlingSettleData", true)
	Base.WriteComplex(writer, val.GomokuSettleData, Auto.WriteGomokuSettleData, "GomokuSettleData", true)
	Base.WriteComplex(writer, val.TierDetailSettleData, Auto.WriteTierDetailSettleData, "TierDetailSettleData", true)
	Base.WriteComplex(writer, val.EggGameSettleData, Auto.WriteEggGameSettleData, "EggGameSettleData", true)
	Base.WriteComplex(writer, val.HideAndSeekSettleData, Auto.WriteHideAndSeekSettleData, "HideAndSeekSettleData", true)
end

Auto.WriteMatchPrepareInfo = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.Fashion, Auto.WriteOtherPlayerSpiritWearFashionsInfo, "Fashion", true)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PoseId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.VehicleParts, Base.WriteStructWrap(Auto.WriteVehicleClientPart, "VehicleParts"), nil, "VehicleParts", true, RpcLengthLimits.MatchPrepareInfo_VehicleParts, nil)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.MemberKeyCounts, writer.WriteUInt32, writer.WriteUInt32, 0, "MemberKeyCounts", true, RpcLengthLimits.MatchPrepareInfo_MemberKeyCounts)
	Base.WriteDict(writer, val.LinkPlanningBoardPutInKeys, writer.WriteUInt32, writer.WriteUInt32, 0, "LinkPlanningBoardPutInKeys", true, RpcLengthLimits.MatchPrepareInfo_LinkPlanningBoardPutInKeys)
	Base.WritePrimitive(writer, val.SelectedGameplayAttributeId, writer.WriteUInt32, 0)
end

Auto.WriteMatchPrepareRoom = function(writer, val)
	Base.WriteList(writer, val.MatchRooms, writer.WriteUInt64, 0, "MatchRooms", false, 0, nil)
	Base.WriteList(writer, val.StageConfirmMembers, writer.WriteUInt64, 0, "StageConfirmMembers", false, 0, nil)
	Base.WriteList(writer, val.ConfirmMembers, writer.WriteUInt64, 0, "ConfirmMembers", false, 0, nil)
	Base.WriteList(writer, val.ReadyMembers, writer.WriteUInt64, 0, "ReadyMembers", false, 0, nil)
	Base.WritePrimitive(writer, val.ConfirmStartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PrepareStartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameStartTime, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.PrepareInfos, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteMatchPrepareInfo, "MatchPrepareInfo", false), nil, "PrepareInfos", false, 0)
	Base.WritePrimitive(writer, val.MemberLeave, writer.WriteBoolean, false)
	Base.WriteDict(writer, val.PlayerSwapInfos, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteMatchPrepareRoomPlayerSwapInfo, "MatchPrepareRoomPlayerSwapInfo", false), nil, "PlayerSwapInfos", false, 0)
	Base.WritePrimitive(writer, val.IsFreeWorldBattle, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.GadgetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SceneId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 205, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.StageId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StageStartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StageIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PlayCount, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.Setting, Auto.WritePrepareRoomSetting, "Setting", false)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeaderPid, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.Members, Base.WriteComplexWrap(Auto.WriteMatchRoomMemberInfo, "MatchRoomMemberInfo", false), nil, "Members", false, 0, nil)
	Base.WriteList(writer, val.AIAgentMembers, Base.WriteComplexWrap(Auto.WriteMatchRoomAIAgentInfo, "MatchRoomAIAgentInfo", false), nil, "AIAgentMembers", false, 0, nil)
	Base.WritePrimitive(writer, val.LastMemberUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ByMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PSNOnly, writer.WriteBoolean, false)
end

Auto.WriteMatchPrepareRoomDutySwapInfo = function(writer, val)
	Base.WritePrimitive(writer, val.SourcePid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SourceDuty, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TargetPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetDuty, writer.WriteUInt32, 0)
end

Auto.WriteMatchPrepareRoomPlayerSwapInfo = function(writer, val)
	Base.WriteDict(writer, val.SwapInfos, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteMatchPrepareRoomDutySwapInfo, "MatchPrepareRoomDutySwapInfo", false), nil, "SwapInfos", false, 0)
end

Auto.WriteMatchRoom = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeaderPid, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.Members, Base.WriteComplexWrap(Auto.WriteMatchRoomMemberInfo, "MatchRoomMemberInfo", false), nil, "Members", false, 0, nil)
	Base.WriteList(writer, val.AIAgentMembers, Base.WriteComplexWrap(Auto.WriteMatchRoomAIAgentInfo, "MatchRoomAIAgentInfo", false), nil, "AIAgentMembers", false, 0, nil)
	Base.WritePrimitive(writer, val.LastMemberUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ByMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PSNOnly, writer.WriteBoolean, false)
end

Auto.WriteMatchRoomAIAgentInfo = function(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.AgentInfo, Auto.WriteLinkAIAgentInfo, "AgentInfo", false)
	Base.WriteComplex(writer, val.RaceInfo, Auto.WriteAIAgentInfo_Race, "RaceInfo", true)
end

Auto.WriteMatchRoomMemberInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MatchForbidDueTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Duty, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRobot, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsAIAgent, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.FromMode, 8, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DeviceLevel, 45, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.FromRaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FromSceneInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PSNOnly, writer.WriteBoolean, false)
	Base.WriteDict(writer, val.Blacklist, writer.WriteUInt64, writer.WriteBoolean, false, "Blacklist", false, 0)
	Base.WriteList(writer, val.AvaliableGameIds, writer.WriteUInt32, 0, "AvaliableGameIds", false, 0, nil)
	Base.WritePrimitive(writer, val.LinkScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Mmr, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Tier, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.LinkInfo, Auto.WritePlayerLinkInfo, "LinkInfo", false)
end

Auto.WriteMatchTeamRoom = function(writer, val)
	Base.WritePrimitive(writer, val.MatchStartTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.matchingFactor, Auto.WriteMatchingFactor, "matchingFactor", false)
	Base.WritePrimitive(writer, val.InMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ByTeam, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AllowAI, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Started, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MatchBucketId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Tag, 206, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Difficulty, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.MatchPoolTags, writer.WriteByte, 32, "MatchPoolTags", false, 0, nil)
	Base.WritePrimitive(writer, val.IsQaBotTest, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeaderPid, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.Members, Base.WriteComplexWrap(Auto.WriteMatchRoomMemberInfo, "MatchRoomMemberInfo", false), nil, "Members", false, 0, nil)
	Base.WriteList(writer, val.AIAgentMembers, Base.WriteComplexWrap(Auto.WriteMatchRoomAIAgentInfo, "MatchRoomAIAgentInfo", false), nil, "AIAgentMembers", false, 0, nil)
	Base.WritePrimitive(writer, val.LastMemberUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ByMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PSNOnly, writer.WriteBoolean, false)
end

Auto.WriteMatchingFactor = function(writer, val)
	Base.WritePrimitive(writer, val.Mmr, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Tier, writer.WriteInt32, 0)
end

Auto.WriteMeccaGrandpaBuildInfo = function(writer, val)
	Base.WriteList(writer, val.Slots, Base.WriteComplexWrap(Auto.WriteMeccaGrandpaSlotInfo, "MeccaGrandpaSlotInfo", false), nil, "Slots", false, 0, nil)
	Base.WritePrimitive(writer, val.IsBuilt, writer.WriteBoolean, false)
end

Auto.WriteMeccaGrandpaPartInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PartId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

Auto.WriteMeccaGrandpaSlotInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PartType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PartId, writer.WriteUInt32, 0)
end

Auto.WriteMeld = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 207, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Tiles, Base.WriteStructWrap(Auto.WriteTile, "Tiles"), nil, "Tiles", false, 0, nil)
	Base.WritePrimitive(writer, val.Revealed, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsKong, writer.WriteBoolean, false)
end

Auto.WriteMergeToTrafficParameters = function(writer, val)
	Base.WritePrimitive(writer, val.ExcludeAlley, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CruiseSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LateralThreshold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HeadingThreshold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

Auto.WriteMessageCallbackParameter = function(writer, val)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
end

Auto.WriteMetroCarriageGadgetInfos = function(writer, val)
	Base.WriteList7Bit(writer, val.InnerGadgetIds, writer.WriteUInt64, 0, "InnerGadgetIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.OuterGadgetIds, writer.WriteUInt64, 0, "OuterGadgetIds", false, 0, nil)
end

Auto.WriteMetroClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LineId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ElapsedTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsFinalTrain, writer.WriteBoolean, false)
end

Auto.WriteMetroHideArea = function(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Hide, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WritePrimitive(writer, val.Radius, writer.WriteSingle, 0)
end

Auto.WriteMetroHitData = function(writer, val)
	Base.WritePrimitive(writer, val.MetroId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HurtEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HurtStiffId, writer.WriteUInt32, 0)
end

Auto.WriteMiniGameData = function(writer, val)
	Base.WriteList(writer, val.MiniGame_Bee, writer.WriteUInt32, 0, "MiniGame_Bee", false, 0, nil)
end

Auto.WriteMjAction = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 208, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Owner, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Targets, writer.WriteInt32, 0, "Targets", false, 0, nil)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsZhuanYi, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BaseFan, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Pattern, 209, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Patterns, writer.WriteByte, 0, "Patterns", true, 0, nil)
	Base.WriteStruct(writer, val.Pai, Auto.WriteMjPaiInfo, "Pai")
	Base.WritePrimitive(writer, val.NumOfGen, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HuAction, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Fan, writer.WriteInt32, 0)
end

Auto.WriteMjCanActionInfo = function(writer, val)
	Base.WriteStruct(writer, val.Pai, Auto.WriteMjPaiInfo, "Pai")
	Base.WritePrimitive(writer, val.CanHu, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CanReach, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.CanPeng, Base.WriteComplexWrap(Auto.WriteMjPCGActionInfo, "MjPCGActionInfo", false), nil, "CanPeng", false, 0, nil)
	Base.WriteList7Bit(writer, val.CanChi, Base.WriteComplexWrap(Auto.WriteMjPCGActionInfo, "MjPCGActionInfo", false), nil, "CanChi", false, 0, nil)
	Base.WriteList7Bit(writer, val.CanGang, Base.WriteComplexWrap(Auto.WriteMjPCGActionInfo, "MjPCGActionInfo", false), nil, "CanGang", false, 0, nil)
	Base.WritePrimitive(writer, val.CanChuPai, writer.WriteBoolean, false)
end

Auto.WriteMjHand = function(writer, val)
	Base.WriteList7Bit(writer, val.Tiles, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "Tiles"), nil, "Tiles", false, 0, nil)
end

Auto.WriteMjPCGActionInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Source, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Pai, Auto.WriteMjPaiInfo, "Pai")
	Base.WriteList7Bit(writer, val.SelectPais, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "SelectPais"), nil, "SelectPais", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PCGType, 210, 0), writer.WriteByte, 0)
end

Auto.WriteMjPaiInfo = function(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Pai, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MType, 31, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Red, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
end

Auto.WriteMjPlayerResult = function(writer, val)
	Base.WriteList7Bit(writer, val.Holds, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "Holds"), nil, "Holds", false, 0, nil)
end

Auto.WriteMjResult = function(writer, val)
	Base.WriteList7Bit(writer, val.MJActions, Base.WriteComplexWrap(Auto.WriteMjAction, "MjAction", true), nil, "MJActions", true, 0, nil)
	Base.WriteList7Bit(writer, val.MjPlayerResultList, Base.WriteComplexWrap(Auto.WriteMjPlayerResult, "MjPlayerResult", true), nil, "MjPlayerResultList", true, 0, nil)
end

Auto.WriteMobilePlatformSyncInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CurLevel, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TgtLevel, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.Players, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteUXVector3, "UXVector3", false), nil, "Players", false, 0)
	Base.WriteStruct(writer, val.CurLevelPos, Auto.WriteUXVector3, "CurLevelPos")
	Base.WriteStruct(writer, val.TgtLevelPos, Auto.WriteUXVector3, "TgtLevelPos")
	Base.WriteComplex(writer, val.InteractBanInfo, Auto.WriteLiftInteractBanInfo, "InteractBanInfo", true)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DoorMode, 211, 0), writer.WriteByte, 0)
end

Auto.WriteModifySpiritWearFashionResult = function(writer, val)
	Base.WriteList7Bit(writer, val.R0, writer.WriteUInt32, 0, "R0", false, 0, nil)
	Base.WriteList7Bit(writer, val.R1, Base.WriteComplexWrap(Auto.WriteWearFashionInfo, "WearFashionInfo", false), nil, "R1", false, 0, nil)
	Base.WriteList7Bit(writer, val.R2, writer.WriteUInt32, 0, "R2", false, 0, nil)
	Base.WriteList7Bit(writer, val.R3, Base.WriteComplexWrap(Auto.WriteWearFashionEditInfo, "WearFashionEditInfo", false), nil, "R3", false, 0, nil)
end

Auto.WriteModuleEventProgressInfo = function(writer, val)
	Base.WriteDict(writer, val.ProgressInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteModuleEventProgressInfoBySpirit, "ModuleEventProgressInfoBySpirit", false), nil, "ProgressInfoDict", false, 0)
end

Auto.WriteModuleEventProgressInfoBySpirit = function(writer, val)
	Base.WriteDict(writer, val.EventProgressInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteEventProgressInfo, "EventProgressInfo", false), nil, "EventProgressInfoDict", false, 0)
	Base.WriteList(writer, val.FinishedTemplateIdList, writer.WriteUInt32, 0, "FinishedTemplateIdList", false, 0, nil)
end

Auto.WriteMomentsNotifyClientInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 212, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.LikeCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PostCount, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.NpcIds, writer.WriteUInt32, 0, "NpcIds", true, 0, nil)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HasNewLike, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AcquireCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActivityCfgId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Url, true, "MomentsNotifyClientInfo.Url", 0)
	Base.WritePrimitive(writer, val.IsStory, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPinStory, writer.WriteBoolean, false)
end

Auto.WriteMonitorTwitterBehavior = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Behavior, 77, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
end

Auto.WriteMonthlyPassInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpiredTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastDailyRewardTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsAutoPopup, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CumulativeLoginDays, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SwitchOffDays, writer.WriteUInt32, 0)
end

Auto.WriteMonthlyPassRewardInfo = function(writer, val)
	Base.WriteComplex(writer, val.BuyRewardInfo, Auto.WriteRewardInfo, "BuyRewardInfo", true)
	Base.WriteComplex(writer, val.DailyRewardInfo, Auto.WriteRewardInfo, "DailyRewardInfo", true)
	Base.WriteComplex(writer, val.CumulativeRewardInfo, Auto.WriteRewardInfo, "CumulativeRewardInfo", true)
end

Auto.WriteMotionLookAtCommandData = function(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.LookAtIKType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CheckQuery, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UseMultipleIKData, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.LookAtIKTypes, writer.WriteInt32, 0, "LookAtIKTypes", false, 0, nil)
	Base.WriteList7Bit(writer, val.CheckQueries, writer.WriteUInt32, 0, "CheckQueries", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteMoveActionData = function(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rot, Auto.WriteUXVector3, "Rot")
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.MoveTime, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.IsCritical, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.ActionData, writer.WriteByte, 0, "ActionData", true, RpcLengthLimits.MoveActionData_ActionData, val.ActionDataLength)
	Base.WriteList7Bit(writer, val.EffectData, writer.WriteByte, 0, "EffectData", true, RpcLengthLimits.MoveActionData_EffectData, val.EffectDataLength)
end

Auto.WriteMoveActionDataWithGround = function(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rot, Auto.WriteUXVector3, "Rot")
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.MoveTime, writer.WriteByte, 0)
	Base.WriteComplex(writer, val.GroundData, Auto.WriteMoveActionGroundData, "GroundData", false)
	Base.WritePrimitive(writer, val.IsCritical, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.ActionData, writer.WriteByte, 0, "ActionData", true, RpcLengthLimits.MoveActionDataWithGround_ActionData, val.ActionDataLength)
	Base.WriteList7Bit(writer, val.EffectData, writer.WriteByte, 0, "EffectData", true, RpcLengthLimits.MoveActionDataWithGround_EffectData, val.EffectDataLength)
end

Auto.WriteMoveActionGroundData = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveGroundType, 213, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.MoveGroundId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MetaInfo, writer.WriteByte, 0)
	Base.WriteStruct(writer, val.LocalPos, Auto.WriteUXVector3, "LocalPos")
end

Auto.WriteMoveCommandData = function(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.ArriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DirectionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TryMatchStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.KeepUpdateTargetPosition, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RunChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.KeepMovingAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteMoveGhostParameter = function(writer, val)
	Base.WritePrimitive(writer, val.DoPreload, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SectorRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MipMapCoeff, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NeedCollider, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsMainTarget, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CollideRadius, writer.WriteSingle, 0)
end

Auto.WriteMoveToBorderData = function(writer, val)
	Base.WritePrimitive(writer, val.MaxDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveType, 128, 0), writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BlockCloseCapsuleCollision, writer.WriteBoolean, false)
end

Auto.WriteMoveToCanShootPosData = function(writer, val)
	Base.WritePrimitive(writer, val.AngleSpace, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DistanceSpace, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveType, 128, 0), writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BlockCloseCapsuleCollision, writer.WriteBoolean, false)
end

Auto.WriteMoveToEQSData = function(writer, val)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.EqsName, false, "MoveToEQSData.EqsName", 0)
	writer.WriteString(writer, val.ShelterName, false, "MoveToEQSData.ShelterName", 0)
	writer.WriteString(writer, val.CheckerName, false, "MoveToEQSData.CheckerName", 0)
	Base.WritePrimitive(writer, val.PathTags, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CloseObstacleAvoidance, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.StopDistance, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.AvoidanceId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveType, 128, 0), writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BlockCloseCapsuleCollision, writer.WriteBoolean, false)
end

Auto.WriteMoveToPosData = function(writer, val)
	Base.WriteList7Bit(writer, val.path, Base.WriteStructWrap(Auto.WriteUXVector3, "path"), nil, "path", false, 0, nil)
	Base.WritePrimitive(writer, val.pathTags, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StopDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.reportOnFinish, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UseServerPath, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CloseObstacleAvoidance, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.pathFlags, writer.WriteByte, 0, "pathFlags", false, 0, nil)
	Base.WritePrimitive(writer, val.IsOnWall, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidanceId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveType, 128, 0), writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BlockCloseCapsuleCollision, writer.WriteBoolean, false)
end

Auto.WriteMoveToVehicleCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Distances, Base.WriteStructWrap(Auto.WriteRangeMoveType, "Distances"), nil, "Distances", true, 0, nil)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteMoveTowardUnitData = function(writer, val)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NearDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ReportOnFinish, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CloseObstacleAvoidance, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CloseIngterStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsMoveAround, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AvoidanceId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveType, 128, 0), writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BlockCloseCapsuleCollision, writer.WriteBoolean, false)
end

Auto.WriteMoveWanderingData = function(writer, val)
	Base.WritePrimitive(writer, val.pathTags, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CloseObstacleAvoidance, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MinDis, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxDis, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.InRangeAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OutRangeAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxOnceWanderTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveType, 128, 0), writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BlockCloseCapsuleCollision, writer.WriteBoolean, false)
end

Auto.WriteMovingDirResInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Dir, 214, 0), writer.WriteByte, 0)
end

Auto.WriteMultiInteractCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.AnotherAgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MultiInteractType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteMultiverseStatusInfo = function(writer, val)
	Base.WriteDict(writer, val.MultiverseStatusDict, writer.WriteUInt32, writer.WriteByte, 0, "MultiverseStatusDict", false, 0)
	Base.WritePrimitive(writer, val.ShowLastMutiId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.MainPageTabStatusDict, writer.WriteUInt32, writer.WriteByte, 0, "MainPageTabStatusDict", false, 0)
	Base.WriteDict(writer, val.ActivityStatusDict, writer.WriteUInt32, writer.WriteByte, 0, "ActivityStatusDict", false, 0)
	Base.WritePrimitive(writer, val.CurMutiPanelId, writer.WriteUInt32, 0)
end

Auto.WriteMusicClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.MusicId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.RecordInfo, writer.WriteUInt32, 0, "RecordInfo", true, 0, nil)
	Base.WritePrimitive(writer, val.AlreadyReward, writer.WriteBoolean, false)
end

Auto.WriteNamedPayload = function(writer, val)
	writer.WriteString(writer, val.Name, false, "NamedPayload.Name", 0)
	Base.WriteComplex(writer, val.Value, Auto.WriteStoryNetPayload, "Value", false)
end

Auto.WriteNavMeshDebugData = function(writer, val)
	Base.WritePrimitive(writer, val.PolyCount, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Verts, writer.WriteSingle, 0, "Verts", false, 0, nil)
	Base.WriteList7Bit(writer, val.VertCounts, writer.WriteInt32, 0, "VertCounts", false, 0, nil)
	Base.WriteList7Bit(writer, val.TileLocX, writer.WriteInt32, 0, "TileLocX", false, 0, nil)
	Base.WriteList7Bit(writer, val.TileLocZ, writer.WriteInt32, 0, "TileLocZ", false, 0, nil)
	Base.WriteList7Bit(writer, val.DestructibleIds, writer.WriteInt32, 0, "DestructibleIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.DestructibleStats, writer.WriteInt32, 0, "DestructibleStats", false, 0, nil)
	Base.WriteList7Bit(writer, val.PolyRefs, writer.WriteUInt64, 0, "PolyRefs", false, 0, nil)
	Base.WriteList7Bit(writer, val.ConnRegionIds, writer.WriteInt32, 0, "ConnRegionIds", false, 0, nil)
end

Auto.WriteNavigationMoveCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.NavigationTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SelfNavigationTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FailedWhenNavigationFailed, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.ArriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DirectionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TryMatchStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.KeepUpdateTargetPosition, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RunChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.KeepMovingAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteNetworkPointInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Fu, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.YakuValues, Base.WriteStructWrap(Auto.WriteYakuValue, "YakuValues"), nil, "YakuValues", false, 0, nil)
	Base.WritePrimitive(writer, val.Dora, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.UraDora, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RedDora, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BeiDora, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsQTJ, writer.WriteBoolean, false)
end

Auto.WriteNewChallengeRecord = function(writer, val)
	Base.WritePrimitive(writer, val.ChallengeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HighestLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReceivedRewardLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentIsNewRewardLevel, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BestScore, writer.WriteSingle, 0)
	Base.WriteDict(writer, val.ParamData, writer.WriteUInt32, writer.WriteBoolean, false, "ParamData", false, 0)
end

Auto.WriteNewClientBoardingInfo = function(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Status, 215, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.VehicleUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
	Base.WriteComplex(writer, val.ExtInfo, Auto.WriteBoardingExtInfo, "ExtInfo", true)
end

Auto.WriteNewHotFixPatchData = function(writer, val)
	Base.WritePrimitive(writer, val.Version, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Content, writer.WriteByte, 0, "Content", false, 0, nil)
	writer.WriteString(writer, val.Md5, false, "NewHotFixPatchData.Md5", 0)
end

Auto.WriteNgpushSetting = function(writer, val)
	Base.WritePrimitive(writer, val.DoNotDisturb, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DoNotDisturbBegin, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DoNotDisturbEnd, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TagSetting, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastSetTagTime, writer.WriteUInt32, 0)
end

Auto.WriteNodeSpoonOutputLinks = function(writer, val)
	Base.WriteList7Bit(writer, val.Links, Base.WriteComplexWrap(Auto.WriteSpoonOutputLink, "SpoonOutputLink", false), nil, "Links", false, 0, nil)
end

Auto.WriteNoticeActivityData = function(writer, val)
	Base.WriteList(writer, val.UnlockList, writer.WriteUInt32, 0, "UnlockList", false, 0, nil)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowRedPoint, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsOutOfDate, writer.WriteBoolean, false)
end

Auto.WriteNpcCardInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.UnlockedVoice, writer.WriteUInt32, 0, "UnlockedVoice", true, 0, nil)
	Base.WritePrimitive(writer, val.ActivateTimestamp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Favor, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.InteractDays, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastInteractTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.GroupNpcPhotoPosList, writer.WriteUInt32, 0, "GroupNpcPhotoPosList", false, 0, nil)
	Base.WriteList(writer, val.SingleNpcPhotoPosList, writer.WriteUInt32, 0, "SingleNpcPhotoPosList", false, 0, nil)
	Base.WriteList(writer, val.TodayChatPosList, writer.WriteUInt32, 0, "TodayChatPosList", false, 0, nil)
	Base.WriteList(writer, val.FirstChatPosList, writer.WriteUInt32, 0, "FirstChatPosList", false, 0, nil)
	Base.WritePrimitive(writer, val.PreferCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AcquireDropReward, writer.WriteBoolean, false)
	Base.WriteList(writer, val.ActiveGiftTags, writer.WriteUInt32, 0, "ActiveGiftTags", false, 0, nil)
	Base.WritePrimitive(writer, val.MaxFavorInHistory, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.TodayFavorDialogCount, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.InteractedStories, writer.WriteUInt32, 0, "InteractedStories", false, 0, nil)
	Base.WritePrimitive(writer, val.HasUninteractedNpcVoice, writer.WriteBoolean, false)
	Base.WriteList(writer, val.InteractedVoices, writer.WriteUInt32, 0, "InteractedVoices", false, 0, nil)
	Base.WritePrimitive(writer, val.FavorLevelReward, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HasNoInteractedStory, writer.WriteBoolean, false)
	Base.WriteDict(writer, val.UnlockedStoryDict, writer.WriteUInt32, writer.WriteUInt32, 0, "UnlockedStoryDict", true, 0)
end

Auto.WriteNpcChatContext = function(writer, val)
	Base.WritePrimitive(writer, val.BubbleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AcquireCfgId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.EmojiList, Base.WriteComplexWrap(Auto.WriteEmojiData, "EmojiData", false), nil, "EmojiList", false, 0, nil)
	writer.WriteString(writer, val.Url, true, "NpcChatContext.Url", 0)
	Base.WritePrimitive(writer, val.ActivityCfgId, writer.WriteUInt32, 0)
end

Auto.WriteNpcChatItem = function(writer, val)
	Base.WritePrimitive(writer, val.Timestamp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ChatId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextChatId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.ChatContext, Auto.WriteNpcChatContext, "ChatContext", true)
	Base.WritePrimitive(writer, val.IsRead, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BelongNpc, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ChatActionTriggeredTime, writer.WriteUInt32, 0)
end

Auto.WriteNpcDetailInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentPersonaId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.NpcType, 216, 0), writer.WriteByte, 0)
end

Auto.WriteNpcEffectEntry = function(writer, val)
	Base.WritePrimitive(writer, val.EffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EffectKey, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteDouble, 0)
end

Auto.WriteNpcEventQueue = function(writer, val)
	Base.WritePrimitive(writer, val.TodayTriggeredCount, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.EventIds, writer.WriteUInt32, 0, "EventIds", false, 0, nil)
end

Auto.WriteNpcEventQueueList = function(writer, val)
	Base.WriteDict(writer, val.NpcQueues, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteNpcEventQueue, "NpcEventQueue", false), nil, "NpcQueues", false, 0)
	Base.WritePrimitive(writer, val.TodayTriggeredCount, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.IdToNpcDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteEventIdInfo, "EventIdInfo", false), nil, "IdToNpcDict", false, 0)
	Base.WritePrimitive(writer, val.LastTriggerTime, writer.WriteUInt32, 0)
end

Auto.WriteNpcPhoneInfo = function(writer, val)
	Base.WritePrimitive(writer, val.NpcChatConfigId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NpcPhoneId, writer.WriteUInt32, 0)
end

Auto.WriteNpcScheduleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.ActivityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartDaySecond, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.SpoonAgentId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EndDaySecond, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
end

Auto.WriteNpcShareTimeInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FightShareDuration, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SwitchInTime, writer.WriteUInt32, 0)
end

Auto.WriteNpcShopCommodityView = function(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RefreshTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Status, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Discount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DiscountPrice, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxBuyCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DailyDiscount, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.CommodityBadgeDiscountDict, writer.WriteUInt32, writer.WriteUInt32, 0, "CommodityBadgeDiscountDict", false, 0)
	Base.WritePrimitive(writer, val.BlackMarketPriceModifier, writer.WriteInt32, 0)
end

Auto.WriteNpcShopInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CurrentDiscount, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.CommodityInfoList, Base.WriteComplexWrap(Auto.WriteNpcShopCommodityView, "NpcShopCommodityView", false), nil, "CommodityInfoList", false, 0, nil)
	Base.WriteList7Bit(writer, val.BuybackCommodityInfoList, Base.WriteComplexWrap(Auto.WriteNpcShopCommodityView, "NpcShopCommodityView", true), nil, "BuybackCommodityInfoList", true, 0, nil)
	Base.WriteComplex(writer, val.RefreshState, Auto.WriteNpcShopRefreshState, "RefreshState", true)
end

Auto.WriteNpcShopPriceHistoryEntry = function(writer, val)
	Base.WritePrimitive(writer, val.UnitPrice, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
end

Auto.WriteNpcShopPriceHistoryView = function(writer, val)
	Base.WritePrimitive(writer, val.CommodityId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Entries, Base.WriteComplexWrap(Auto.WriteNpcShopPriceHistoryEntry, "NpcShopPriceHistoryEntry", false), nil, "Entries", false, 0, nil)
end

Auto.WriteNpcShopRefreshState = function(writer, val)
	Base.WritePrimitive(writer, val.SellRefreshTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BuybackRefreshTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ManualRefreshCountResetTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SellManualRefreshCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BuybackManualRefreshCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SellRotationIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BuybackRotationIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SellRefreshPlusCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BuybackRefreshPlusCount, writer.WriteUInt32, 0)
end

Auto.WriteNpcTimeTableInfo = function(writer, val)
	Base.WriteComplex(writer, val.Schedule0, Auto.WriteNpcScheduleInfo, "Schedule0", false)
	Base.WriteComplex(writer, val.Schedule1, Auto.WriteNpcScheduleInfo, "Schedule1", false)
	Base.WriteComplex(writer, val.Schedule2, Auto.WriteNpcScheduleInfo, "Schedule2", false)
	Base.WriteComplex(writer, val.Schedule3, Auto.WriteNpcScheduleInfo, "Schedule3", false)
	Base.WriteComplex(writer, val.Schedule4, Auto.WriteNpcScheduleInfo, "Schedule4", false)
	Base.WritePrimitive(writer, val.CurrentSpoonAgentId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.SpoonPosition, Auto.WriteUXVector3, "SpoonPosition")
	Base.WriteComplex(writer, val.TempSchedule, Auto.WriteNpcScheduleInfo, "TempSchedule", true)
	Base.WritePrimitive(writer, val.IsTempScheduleOnly, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RefreshDay, writer.WriteInt64, 0)
end

Auto.WriteNpcTrustValueInfo = function(writer, val)
	Base.WritePrimitive(writer, val.ProfileId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TrustValue, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 25, 0), writer.WriteInt32, 0)
end

Auto.WriteNpcVehicleDriveStateInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.EnterOrLeave, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.VehicleEntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
end

Auto.WriteNpcVoiceDebugInfo = function(writer, val)
	Base.WritePrimitive(writer, val.NpcInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VoiceLibraryId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VoiceInstanceId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SoundId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DialogInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Success, writer.WriteBoolean, false)
	writer.WriteString(writer, val.FailureReason, false, "NpcVoiceDebugInfo.FailureReason", 0)
end

Auto.WriteOCControllerByte9Value = function(writer, val)
	Base.WritePrimitive(writer, val.Value1, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value2, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value3, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value4, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value5, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value6, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value7, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value8, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value9, writer.WriteByte, 0)
end

Auto.WriteOCGenerateInfo = function(writer, val)
	Base.WritePrimitive(writer, val.OCId, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.name, false, "OCGenerateInfo.name", RpcLengthLimits.OCGenerateInfo_name)
	writer.WriteString(writer, val.gender, false, "OCGenerateInfo.gender", RpcLengthLimits.OCGenerateInfo_gender)
	writer.WriteString(writer, val.age, true, "OCGenerateInfo.age", RpcLengthLimits.OCGenerateInfo_age)
	Base.WriteList(writer, val.labels, Base.WriteStringWrap(false, "labels", RpcLengthLimits.OCGenerateInfo_labels_String), nil, "labels", false, RpcLengthLimits.OCGenerateInfo_labels, nil)
	writer.WriteString(writer, val.description, false, "OCGenerateInfo.description", RpcLengthLimits.OCGenerateInfo_description)
	writer.WriteString(writer, val.story, false, "OCGenerateInfo.story", RpcLengthLimits.OCGenerateInfo_story)
	writer.WriteString(writer, val.identity, false, "OCGenerateInfo.identity", RpcLengthLimits.OCGenerateInfo_identity)
	writer.WriteString(writer, val.SpeechName, false, "OCGenerateInfo.SpeechName", RpcLengthLimits.OCGenerateInfo_SpeechName)
	Base.WritePrimitive(writer, val.SelectBodyTypeId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.SpeakingStyle, true, "OCGenerateInfo.SpeakingStyle", RpcLengthLimits.OCGenerateInfo_SpeakingStyle)
	writer.WriteString(writer, val.Relationship, true, "OCGenerateInfo.Relationship", RpcLengthLimits.OCGenerateInfo_Relationship)
	writer.WriteString(writer, val.DialogSample, true, "OCGenerateInfo.DialogSample", RpcLengthLimits.OCGenerateInfo_DialogSample)
end

Auto.WriteOCInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ControllerByteValues, writer.WriteUInt16, writer.WriteByte, 0, "ControllerByteValues", false, RpcLengthLimits.OCInfo_ControllerByteValues)
	Base.WriteDict(writer, val.ControllerByte9Values, writer.WriteUInt16, Base.WriteComplexWrap(Auto.WriteOCControllerByte9Value, "OCControllerByte9Value", false), nil, "ControllerByte9Values", false, RpcLengthLimits.OCInfo_ControllerByte9Values)
	writer.WriteString(writer, val.speech_id, false, "OCInfo.speech_id", RpcLengthLimits.OCInfo_speech_id)
	Base.WritePrimitive(writer, val.FashionOCId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.SpiritWearFashionsInfo, Auto.WriteSpiritWearFashionsInfo, "SpiritWearFashionsInfo", true)
	Base.WritePrimitive(writer, val.OCId, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.name, false, "OCInfo.name", RpcLengthLimits.OCGenerateInfo_name)
	writer.WriteString(writer, val.gender, false, "OCInfo.gender", RpcLengthLimits.OCGenerateInfo_gender)
	writer.WriteString(writer, val.age, true, "OCInfo.age", RpcLengthLimits.OCGenerateInfo_age)
	Base.WriteList(writer, val.labels, Base.WriteStringWrap(false, "labels", RpcLengthLimits.OCGenerateInfo_labels_String), nil, "labels", false, RpcLengthLimits.OCGenerateInfo_labels, nil)
	writer.WriteString(writer, val.description, false, "OCInfo.description", RpcLengthLimits.OCGenerateInfo_description)
	writer.WriteString(writer, val.story, false, "OCInfo.story", RpcLengthLimits.OCGenerateInfo_story)
	writer.WriteString(writer, val.identity, false, "OCInfo.identity", RpcLengthLimits.OCGenerateInfo_identity)
	writer.WriteString(writer, val.SpeechName, false, "OCInfo.SpeechName", RpcLengthLimits.OCGenerateInfo_SpeechName)
	Base.WritePrimitive(writer, val.SelectBodyTypeId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.SpeakingStyle, true, "OCInfo.SpeakingStyle", RpcLengthLimits.OCGenerateInfo_SpeakingStyle)
	writer.WriteString(writer, val.Relationship, true, "OCInfo.Relationship", RpcLengthLimits.OCGenerateInfo_Relationship)
	writer.WriteString(writer, val.DialogSample, true, "OCInfo.DialogSample", RpcLengthLimits.OCGenerateInfo_DialogSample)
end

Auto.WriteOCMeccaGrandpaInfo = function(writer, val)
	Base.WritePrimitive(writer, val.RefOCId, writer.WriteUInt64, 0)
end

Auto.WriteOCMemoryChange = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MemorySetId, 15, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.NewEntries, Base.WriteComplexWrap(Auto.WriteOCMemoryEntry, "OCMemoryEntry", false), nil, "NewEntries", false, 0, nil)
	Base.WritePrimitive(writer, val.ProgressPercent, writer.WriteUInt32, 0)
end

Auto.WriteOCMemoryEntry = function(writer, val)
	Base.WritePrimitive(writer, val.MemoryId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ParamsDict, writer.WriteUInt32, Base.WriteStringWrap(false, "ParamsDict", 0), nil, "ParamsDict", false, 0)
end

Auto.WriteOCMemoryInfo = function(writer, val)
	Base.WriteDict(writer, val.MemorySetDataDict, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteOCMemorySetData, "OCMemorySetData", false), nil, "MemorySetDataDict", false, 0)
end

Auto.WriteOCMemorySetData = function(writer, val)
	Base.WriteDict(writer, val.MemoryEntryDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteOCMemoryEntry, "OCMemoryEntry", false), nil, "MemoryEntryDict", false, 0)
	Base.WritePrimitive(writer, val.RecoveredMemoryWeight, writer.WriteUInt32, 0)
end

Auto.WriteOCSpeechInfo = function(writer, val)
	writer.WriteString(writer, val.SpeechName, false, "OCSpeechInfo.SpeechName", 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.ExternalSpeechId, false, "OCSpeechInfo.ExternalSpeechId", 0)
	Base.WriteComplex(writer, val.SoundEffectConfig, Auto.WriteSoundEffectConfig, "SoundEffectConfig", true)
end

Auto.WriteOccupyDebugInfo = function(writer, val)
	Base.WritePrimitive(writer, val.OccupyId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Reason, true, "OccupyDebugInfo.Reason", 0)
end

Auto.WriteOnlineSeasonChangedNotifyInfo = function(writer, val)
	Base.WritePrimitive(writer, val.SeasonId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SchemeId, writer.WriteUInt32, 0)
end

Auto.WriteOpenMeld = function(writer, val)
	Base.WriteStruct(writer, val.Meld, Auto.WriteMeld, "Meld")
	Base.WriteStruct(writer, val.Tile, Auto.WriteTile, "Tile")
	Base.WritePrimitive(writer, Base.CheckEnum(val.Side, 217, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Extra, Auto.WriteTile, "Extra")
	Base.WritePrimitive(writer, val.IsAdded, writer.WriteBoolean, false)
end

Auto.WriteOpenVehicleDoorCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Distances, Base.WriteStructWrap(Auto.WriteRangeMoveType, "Distances"), nil, "Distances", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteOperationPerformInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OperationPlayerIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Operation, Auto.WriteOutTurnOperation, "Operation")
	Base.WriteStruct(writer, val.HandData, Auto.WritePlayerHandData, "HandData")
	Base.WritePrimitive(writer, val.RemainTurnTime, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Rivers, Base.WriteStructWrap(Auto.WriteRiverData, "Rivers"), nil, "Rivers", false, 0, nil)
	Base.WriteStruct(writer, val.MahjongSetData, Auto.WriteMahjongSetData, "MahjongSetData")
end

Auto.WriteOssBucketInfo = function(writer, val)
	writer.WriteString(writer, val.Region, false, "OssBucketInfo.Region", 0)
	writer.WriteString(writer, val.Endpoint, false, "OssBucketInfo.Endpoint", 0)
	writer.WriteString(writer, val.Bucket, false, "OssBucketInfo.Bucket", 0)
end

Auto.WriteOstrichMoveCommandData = function(writer, val)
	Base.WriteList7Bit(writer, val.Positions, Base.WriteStructWrap(Auto.WriteUXVector3, "Positions"), nil, "Positions", false, 0, nil)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteOtherPlayerSpiritWearFashionsInfo = function(writer, val)
	Base.WriteDict(writer, val.WearFashionColoringInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFashionColoringInfo, "FashionColoringInfo", false), nil, "WearFashionColoringInfoDict", true, RpcLengthLimits.OtherPlayerSpiritWearFashionsInfo_WearFashionColoringInfoDict)
	Base.WriteList(writer, val.WearFashionInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionInfo, "WearFashionInfo", false), nil, "WearFashionInfoList", false, RpcLengthLimits.BaseWearFashionsInfo_WearFashionInfoList, nil)
	Base.WriteList(writer, val.WearFashionEditInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "WearFashionEditInfoList", true, RpcLengthLimits.BaseWearFashionsInfo_WearFashionEditInfoList, nil)
	Base.WritePrimitive(writer, val.HiddenParts, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EditedHiddenParts, writer.WriteByte, 0)
end

Auto.WriteOutTurnOperation = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 218, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Tile, Auto.WriteTile, "Tile")
	Base.WriteStruct(writer, val.Meld, Auto.WriteOpenMeld, "Meld")
	Base.WriteList7Bit(writer, val.ForbiddenTiles, Base.WriteStructWrap(Auto.WriteTile, "ForbiddenTiles"), nil, "ForbiddenTiles", false, 0, nil)
	Base.WriteStruct(writer, val.HandData, Auto.WritePlayerHandData, "HandData")
	Base.WritePrimitive(writer, Base.CheckEnum(val.RoundDrawType, 219, 0), writer.WriteByte, 0)
end

Auto.WriteOwnerSyncData = function(writer, val)
	Base.WritePrimitive(writer, val.NetworkTick, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.attackPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.hurtPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.hurtId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.hitPoint, Auto.WriteUXVector3, "hitPoint")
	Base.WriteStruct(writer, val.hitCenter, Auto.WriteUXVector3, "hitCenter")
	Base.WriteStruct(writer, val.hitDirection, Auto.WriteUXVector3, "hitDirection")
	Base.WriteStruct(writer, val.colliderPos, Auto.WriteUXVector3, "colliderPos")
	Base.WriteStruct(writer, val.colliderForward, Auto.WriteUXVector3, "colliderForward")
	Base.WriteStruct(writer, val.colliderVelocity, Auto.WriteUXVector3, "colliderVelocity")
	Base.WriteStruct(writer, val.attackColliderPos, Auto.WriteUXVector3, "attackColliderPos")
	Base.WriteStruct(writer, val.attackColliderForward, Auto.WriteUXVector3, "attackColliderForward")
	Base.WriteStruct(writer, val.attackColliderVelocity, Auto.WriteUXVector3, "attackColliderVelocity")
	Base.WritePrimitive(writer, val.skillUUID, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.skillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.triggerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.materialIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.hitColliderIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.creationId, writer.WriteUInt32, 0)
end

Auto.WritePackItemComponents = function(writer, val)
	Base.WriteComplex(writer, val.ExtractionShooterItem, Auto.WriteExtractionShooterItemComponent, "ExtractionShooterItem", true)
	Base.WriteComplex(writer, val.CollectiblePlaced, Auto.WriteCollectiblePlacedComponent, "CollectiblePlaced", true)
	Base.WriteComplex(writer, val.GachaGrandPrize, Auto.WriteGachaGrandPrizeComponent, "GachaGrandPrize", true)
end

Auto.WritePackedDestructibleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.linkPath, writer.WriteInt32, 0, "linkPath", true, 0, nil)
	Base.WriteList7Bit(writer, val.linkType, writer.WriteByte, 0, "linkType", true, 0, nil)
end

Auto.WritePackedGadgetInfo = function(writer, val)
	Base.WritePrimitive(writer, val.posX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.posY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.posZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.eulerX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.eulerY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.eulerZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.uniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.pathId, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.spoonSpecialList, Base.WriteStructWrap(Auto.WritePackedGadgetSpecialParam, "spoonSpecialList"), nil, "spoonSpecialList", true, 0, nil)
	Base.WritePrimitive(writer, val.delayDestroy, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.startTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.endTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.extractionItemContainerId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.isStatic, writer.WriteBoolean, false)
end

Auto.WritePackedGadgetSpecialParam = function(writer, val)
	Base.WritePrimitive(writer, val.markId, writer.WriteInt32, 0)
	writer.WriteString(writer, val.value, true, "PackedGadgetSpecialParam.value", 0)
end

Auto.WriteParryCounterData = function(writer, val)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SkillInstanceId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
end

Auto.WritePartyDanceFloorState = function(writer, val)
	Base.WritePrimitive(writer, val.ZoneGadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Status, 220, 0), writer.WriteByte, 0)
	Base.WriteComplex(writer, val.Slot1, Auto.WritePartyDanceSlotInfo, "Slot1", false)
	Base.WriteComplex(writer, val.Slot2, Auto.WritePartyDanceSlotInfo, "Slot2", false)
end

Auto.WritePartyDanceInviteInfo = function(writer, val)
	Base.WritePrimitive(writer, val.InviterPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.InviteePid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GadgetId, writer.WriteUInt64, 0)
end

Auto.WritePartyDanceParticipantInfo = function(writer, val)
	Base.WritePrimitive(writer, val.NpcInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Mode, 40, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

Auto.WritePartyDanceSettleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.ZoneGadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MySelfScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PartnerScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MySelfMusicScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PartnerMusicScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PartyScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BestPartyScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsNewBest, writer.WriteBoolean, false)
end

Auto.WritePartyDanceSlotInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Status, 221, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MusicId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Mode, 40, 0), writer.WriteByte, 0)
end

Auto.WritePartyDanceStartInfo = function(writer, val)
	Base.WritePrimitive(writer, val.ZoneGadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MusicId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Mode, 40, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.StartTimestamp, writer.WriteUInt32, 0)
end

Auto.WritePartyDanceZoneInfo = function(writer, val)
	Base.WritePrimitive(writer, val.MusicId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.ZoneSessionId, false, "PartyDanceZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WritePartyMemberInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.Name, false, "PartyMemberInfo.Name", 0)
end

Auto.WritePartyNPCInfo = function(writer, val)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.NickName, false, "PartyNPCInfo.NickName", 0)
	Base.WritePrimitive(writer, val.NPCType, writer.WriteUInt32, 0)
end

Auto.WritePartyNPCMessage = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	writer.WriteString(writer, val.Message, false, "PartyNPCMessage.Message", 0)
end

Auto.WritePartyNpcFashionsInfo = function(writer, val)
	Base.WriteDict7Bit(writer, val.Rents, writer.WriteUInt32, writer.WriteUInt32, 0, "Rents", false, RpcLengthLimits.PartyNpcFashionsInfo_Rents)
	Base.WritePrimitive(writer, val.UseDefaultFashion, writer.WriteBoolean, false)
end

Auto.WritePartyOnlineSettleResult = function(writer, val)
	Base.WritePrimitive(writer, val.TotalScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FashionScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActivityScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LiveScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FashionStarPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SuperGamerPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PopularityKingPid, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.SettleList, Base.WriteComplexWrap(Auto.WritePartyPlayerSettleData, "PartyPlayerSettleData", false), nil, "SettleList", false, 0, nil)
end

Auto.WritePartyPlayerSettleData = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.FashionScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TaskScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GamePlayScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LiveScore, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LikeCount, writer.WriteUInt32, 0)
end

Auto.WritePartyResponse = function(writer, val)
	Base.WriteList7Bit(writer, val.likeList, writer.WriteInt32, 0, "likeList", false, 0, nil)
	Base.WriteList7Bit(writer, val.giftList, writer.WriteInt32, 0, "giftList", false, 0, nil)
	Base.WritePrimitive(writer, val.Popularity, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.NPCMessage, Base.WriteComplexWrap(Auto.WritePartyNPCMessage, "PartyNPCMessage", false), nil, "NPCMessage", false, 0, nil)
end

Auto.WritePartyRoomInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PartyConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Lottery, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MatchLinkId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.HasGift, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.GiftItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LotteryItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LotteryItemCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OwnerJoinLottery, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableLiveBarrage, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableRoomAudio, writer.WriteBoolean, false)
end

Auto.WritePartyRoomSettingParam = function(writer, val)
	Base.WritePrimitive(writer, val.SetLottery, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LotteryItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LotteryItemCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SetGift, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.GiftItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GiftItemCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OwnerJoinLottery, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableLiveBarrage, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableRoomAudio, writer.WriteBoolean, false)
end

Auto.WritePartySettingInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PartyConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MatchLinkId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Lottery, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LotteryItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LotteryItemCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HasGift, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.GiftItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GiftItemCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OwnerJoinLottery, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableLiveBarrage, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableRoomAudio, writer.WriteBoolean, false)
end

Auto.WritePartySettleData = function(writer, val)
	Base.WritePrimitive(writer, val.HostPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PartyId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Popularity, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LikeCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GiftCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CommentCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AudienceCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WinGameCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TaskCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InviteFriendCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Drop, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.LikeList, writer.WriteInt32, 0, "LikeList", false, 0, nil)
	Base.WriteList7Bit(writer, val.GiftList, writer.WriteInt32, 0, "GiftList", false, 0, nil)
	Base.WriteList7Bit(writer, val.InviteNPCList, writer.WriteUInt32, 0, "InviteNPCList", false, 0, nil)
	Base.WriteComplex(writer, val.OnlineSettleResult, Auto.WritePartyOnlineSettleResult, "OnlineSettleResult", true)
end

Auto.WritePartyStatusInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PartyId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RoomId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsOnlineParty, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Status, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HostPid, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Members, Base.WriteComplexWrap(Auto.WritePartyMemberInfo, "PartyMemberInfo", true), nil, "Members", true, 0, nil)
end

Auto.WritePatchEntry = function(writer, val)
	Base.WritePrimitive(writer, val.Version, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Content, writer.WriteByte, 0, "Content", false, 0, nil)
	writer.WriteString(writer, val.Md5, false, "PatchEntry.Md5", 0)
end

Auto.WritePendingSeasonReward = function(writer, val)
	Base.WritePrimitive(writer, val.SeasonId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.TaskRewardDropIds, writer.WriteUInt32, 0, "TaskRewardDropIds", false, 0, nil)
	Base.WritePrimitive(writer, val.TaskRewardProgress, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.LevelRewardDropIds, writer.WriteUInt32, 0, "LevelRewardDropIds", false, 0, nil)
end

Auto.WritePersonalTeamSetting = function(writer, val)
	Base.WritePrimitive(writer, val.DisableTeamInviteInPersonalMode, writer.WriteBoolean, false)
end

Auto.WritePersonalTimeSetting = function(writer, val)
	writer.WriteString(writer, val.Label, false, "PersonalTimeSetting.Label", RpcLengthLimits.PersonalTimeSetting_Label)
	Base.WritePrimitive(writer, val.Hour, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Minute, writer.WriteUInt32, 0)
end

Auto.WritePersonalZoneAchievement = function(writer, val)
	Base.WritePrimitive(writer, val.AchieveId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CountryId, writer.WriteUInt32, 0)
end

Auto.WritePersonalZoneFightSpiritInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FavorLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
end

Auto.WritePersonalZoneHeadExtendInfo = function(writer, val)
	Base.WriteComplex(writer, val.PzHeadInfo, Auto.WritePersonalZoneHeadInfo, "PzHeadInfo", false)
	Base.WriteComplex(writer, val.LinkPzHeadInfo, Auto.WritePersonalZoneHeadInfo, "LinkPzHeadInfo", false)
	Base.WriteList7Bit(writer, val.UnlockedSystemHeadList, Base.WriteComplexWrap(Auto.WritePersonalZoneItemInfo, "PersonalZoneItemInfo", false), nil, "UnlockedSystemHeadList", false, 0, nil)
end

Auto.WritePersonalZoneHeadInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.HeadType, 30, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SystemHeadId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AvatarFrame, writer.WriteUInt32, 0)
end

Auto.WritePersonalZoneItemInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HadInteracted, writer.WriteBoolean, false)
end

Auto.WritePersonalZoneSpiritInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Favor, writer.WriteInt32, 0)
end

Auto.WritePhoneContact = function(writer, val)
	writer.WriteString(writer, val.Remark, false, "PhoneContact.Remark", 0)
	writer.WriteString(writer, val.PhoneNumber, false, "PhoneContact.PhoneNumber", 0)
end

Auto.WritePhoneContactCallRecord = function(writer, val)
	Base.WritePrimitive(writer, val.CallTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CallType, 28, 0), writer.WriteByte, 0)
	writer.WriteString(writer, val.PhoneNumber, false, "PhoneContactCallRecord.PhoneNumber", 0)
end

Auto.WritePhoneContactGroup = function(writer, val)
	writer.WriteString(writer, val.Name, false, "PhoneContactGroup.Name", 0)
	Base.WriteList(writer, val.PhoneNumberList, Base.WriteStringWrap(false, "PhoneNumberList", 0), nil, "PhoneNumberList", false, 0, nil)
end

Auto.WritePhoneInfos = function(writer, val)
	Base.WriteList(writer, val.ContactList, Base.WriteComplexWrap(Auto.WritePhoneContact, "PhoneContact", false), nil, "ContactList", false, 0, nil)
	Base.WriteList(writer, val.ContactGroupList, Base.WriteComplexWrap(Auto.WritePhoneContactGroup, "PhoneContactGroup", false), nil, "ContactGroupList", false, 0, nil)
	Base.WriteList(writer, val.CallRecordList, Base.WriteComplexWrap(Auto.WritePhoneContactCallRecord, "PhoneContactCallRecord", false), nil, "CallRecordList", false, 0, nil)
	Base.WriteDict(writer, val.ContactOutgoingCallTimesDict, Base.WriteStringWrap(false, "ContactOutgoingCallTimesDict", 0), writer.WriteUInt32, 0, "ContactOutgoingCallTimesDict", false, 0)
end

Auto.WritePinData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.PinPos, Auto.WriteUXVector3, "PinPos")
end

Auto.WritePlaceFishResult = function(writer, val)
	Base.WritePrimitive(writer, val.SlotId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.FishData, Auto.WriteFishInfo, "FishData", false)
end

Auto.WritePlacedFurnitureInfo = function(writer, val)
	Base.WritePrimitive(writer, val.FurnitureId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WritePrimitive(writer, val.GadgetInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PlacedInstanceId, writer.WriteUInt64, 0)
	Base.WriteDict(writer, val.ChildrenDict, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WritePlacedFurnitureInfo, "PlacedFurnitureInfo", false), nil, "ChildrenDict", false, 0)
end

Auto.WritePlanningBoardInfo = function(writer, val)
	Base.WriteDict(writer, val.StepId2OptionIndexDict, writer.WriteUInt32, writer.WriteByte, 0, "StepId2OptionIndexDict", false, 0)
end

Auto.WritePlateGridAOIInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.addInfos, Base.WriteComplexWrap(Auto.WritePlateInfo, "PlateInfo", true), nil, "addInfos", true, 0, nil)
	Base.WriteList7Bit(writer, val.removeIds, writer.WriteUInt64, 0, "removeIds", true, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.reason, 160, 0), writer.WriteByte, 0)
end

Auto.WritePlateInfo = function(writer, val)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GraphId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WriteDict7Bit(writer, val.GadgetDic, writer.WriteInt32, writer.WriteUInt64, 0, "GadgetDic", true, 0)
	Base.WriteDict7Bit(writer, val.DestructibleDic, writer.WriteInt32, writer.WriteUInt64, 0, "DestructibleDic", true, 0)
	Base.WriteDict7Bit(writer, val.AgentDic, writer.WriteInt32, writer.WriteInt32, 0, "AgentDic", true, 0)
	Base.WriteDict7Bit(writer, val.VehicleDic, writer.WriteInt32, writer.WriteInt32, 0, "VehicleDic", true, 0)
	Base.WriteDict7Bit(writer, val.DynamicAgentDic, writer.WriteInt32, writer.WriteUInt64, 0, "DynamicAgentDic", true, 0)
	Base.WriteDict7Bit(writer, val.DynamicVehicleDic, writer.WriteInt32, writer.WriteUInt64, 0, "DynamicVehicleDic", true, 0)
	Base.WriteDict7Bit(writer, val.StaticNpcDic, writer.WriteInt32, writer.WriteInt32, 0, "StaticNpcDic", true, 0)
	Base.WriteDict7Bit(writer, val.RoomDic, writer.WriteInt32, writer.WriteInt32, 0, "RoomDic", true, 0)
	Base.WritePrimitive(writer, val.FavorNpcActivityId, writer.WriteUInt32, 0)
end

Auto.WritePlayActionData = function(writer, val)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionUid, writer.WriteUInt32, 0)
end

Auto.WritePlayActionWithLayerData = function(writer, val)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionUid, writer.WriteUInt32, 0)
end

Auto.WritePlayPoiCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.SPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CPoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PlayPoiSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WritePlayerBasicInfoVO = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.Name, false, "PlayerBasicInfoVO.Name", 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Sex, 155, 0), writer.WriteByte, 0)
	Base.WriteComplex(writer, val.PzHeadInfo, Auto.WritePersonalZoneHeadInfo, "PzHeadInfo", false)
	Base.WriteComplex(writer, val.LinkPzHeadInfo, Auto.WritePersonalZoneHeadInfo, "LinkPzHeadInfo", false)
	Base.WritePrimitive(writer, val.LastLogoutTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastDetachTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.OnlineState, 222, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.LinkMode, 8, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.LinkIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SyncRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.InRoom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TeamId, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.AppChannel, false, "PlayerBasicInfoVO.AppChannel", 0)
	writer.WriteString(writer, val.Signature, true, "PlayerBasicInfoVO.Signature", 0)
	Base.WritePrimitive(writer, val.Birthday, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Background, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Credit, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.TierInfo, Auto.WritePlayerTierInfo, "TierInfo", true)
	Base.WritePrimitive(writer, val.PopUp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NameEffect, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRobot, writer.WriteBoolean, false)
end

Auto.WritePlayerBasketballAppearanceInfo = function(writer, val)
	Base.WriteDict(writer, val.EquippedDict, writer.WriteUInt32, writer.WriteUInt32, 0, "EquippedDict", false, 0)
	Base.WriteDict(writer, val.ExpiryDict, writer.WriteUInt32, writer.WriteUInt32, 0, "ExpiryDict", false, 0)
	Base.WriteDict(writer, val.PendingRemoveDict, writer.WriteUInt32, writer.WriteUInt32, 0, "PendingRemoveDict", false, 0)
end

Auto.WritePlayerBattlePassInfo = function(writer, val)
	Base.WritePrimitive(writer, val.BattlePassId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ClaimedLevelRewards, writer.WriteUInt32, writer.WriteByte, 0, "ClaimedLevelRewards", false, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PassType, 223, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.UnClaimedWeeklyExp, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ChallengeTaskStates, writer.WriteUInt32, writer.WriteByte, 1, "ChallengeTaskStates", false, 0)
	Base.WritePrimitive(writer, val.WeeklyExpGained, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.WeeklyTaskCompletionCounts, writer.WriteUInt32, writer.WriteUInt32, 0, "WeeklyTaskCompletionCounts", false, 0)
end

Auto.WritePlayerBattlePassInfos = function(writer, val)
	Base.WritePrimitive(writer, val.CurrentSeasonalBattlePassId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.BattlePassInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerBattlePassInfo, "PlayerBattlePassInfo", false), nil, "BattlePassInfoDict", false, 0)
	Base.WritePrimitive(writer, val.LastWeeklyRefresherTime, writer.WriteUInt32, 0)
end

Auto.WritePlayerBeLikeInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TimeStamp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.LikeType, 17, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.MultiPlayerId, writer.WriteUInt32, 0)
end

Auto.WritePlayerBeggarPaintScore = function(writer, val)
	Base.WritePrimitive(writer, val.SubjectRecognition, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StrokeDedication, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ColorExpression, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CreativityBonus, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TotalScore, writer.WriteSingle, 0)
end

Auto.WritePlayerBuffLibraryEntry = function(writer, val)
	Base.WritePrimitive(writer, val.EntryId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LibraryCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTimeMs, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.TotalDurationMs, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.ConsumedMs, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.LastTickAnchorMs, writer.WriteInt64, 0)
	writer.WriteString(writer, val.SourceTag, true, "PlayerBuffLibraryEntry.SourceTag", 0)
end

Auto.WritePlayerCityPediaInfos = function(writer, val)
	Base.WriteDict(writer, val.CityPediaStatusDict, writer.WriteUInt32, writer.WriteByte, 0, "CityPediaStatusDict", false, 0)
	Base.WriteComplex(writer, val.CreditInfo, Auto.WriteCreditInfo, "CreditInfo", false)
	Base.WriteDict(writer, val.FishRecordDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFishRecordInfo, "FishRecordInfo", false), nil, "FishRecordDict", false, 0)
	Base.WriteDict(writer, val.CreditedFurnitureDict, writer.WriteUInt32, writer.WriteBoolean, false, "CreditedFurnitureDict", false, 0)
	Base.WriteDict(writer, val.CreditedLootDict, writer.WriteUInt32, writer.WriteBoolean, false, "CreditedLootDict", false, 0)
end

Auto.WritePlayerClientChatInfo = function(writer, val)
	Base.WriteDict7Bit(writer, val.UnlockBubbles, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChatBubbleInfo, "ChatBubbleInfo", false), nil, "UnlockBubbles", false, 0)
	Base.WritePrimitive(writer, val.SelectedBubble, writer.WriteUInt32, 0)
end

Auto.WritePlayerClientInfo = function(writer, val)
	Base.WriteBuffer7Bit(writer, val.Config, "Config", false, 0, nil)
	Base.WriteComplex(writer, val.InfoLogin, Auto.WritePlayerClientInfoLogin, "InfoLogin", false)
	Base.WriteComplex(writer, val.InfoItem, Auto.WritePlayerClientInfoItem, "InfoItem", false)
	Base.WriteComplex(writer, val.InfoSpirit, Auto.WritePlayerClientInfoSpirit, "InfoSpirit", false)
	Base.WriteComplex(writer, val.InfoMinor, Auto.WritePlayerClientInfoMinor, "InfoMinor", false)
	Base.WriteComplex(writer, val.InfoAchievement, Auto.WritePlayerClientInfoAchievement, "InfoAchievement", false)
end

Auto.WritePlayerClientInfoAchievement = function(writer, val)
	Base.WriteDict7Bit(writer, val.SceneFogMaps, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSceneFogMap, "SceneFogMap", false), nil, "SceneFogMaps", true, 0)
	Base.WriteList7Bit(writer, val.SceneFogMapPoiIds, writer.WriteUInt32, 0, "SceneFogMapPoiIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.UnlockedCountryList, writer.WriteUInt32, 0, "UnlockedCountryList", false, 0, nil)
	Base.WriteList7Bit(writer, val.UnlockedQuestList, writer.WriteUInt32, 0, "UnlockedQuestList", false, 0, nil)
	Base.WriteDict7Bit(writer, val.CompletedSubQuestCnt, writer.WriteUInt32, writer.WriteUInt32, 0, "CompletedSubQuestCnt", false, 0)
	Base.WriteDict7Bit(writer, val.ChallengeRecordInfo, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChallengeRecord, "ChallengeRecord", false), nil, "ChallengeRecordInfo", false, 0)
	Base.WriteDict7Bit(writer, val.NewChallengeRecordInfo, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteNewChallengeRecord, "NewChallengeRecord", false), nil, "NewChallengeRecordInfo", false, 0)
	Base.WriteList7Bit(writer, val.FirstKillEnemyRecord, writer.WriteInt32, 0, "FirstKillEnemyRecord", false, 0, nil)
	Base.WriteList7Bit(writer, val.UnlockInvestigateGalleryList, writer.WriteUInt32, 0, "UnlockInvestigateGalleryList", false, 0, nil)
	Base.WritePrimitive(writer, val.InvestigateGalleryRedCnt, writer.WriteInt32, 0)
	Base.WriteDict7Bit(writer, val.CountryReputationInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "CountryReputationInfo", false, 0)
	Base.WriteDict7Bit(writer, val.FactionInfoDic, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFactionInfo, "FactionInfo", false), nil, "FactionInfoDic", false, 0)
	Base.WriteList7Bit(writer, val.OccupiedInfluenceArea, writer.WriteUInt32, 0, "OccupiedInfluenceArea", false, 0, nil)
	Base.WriteComplex(writer, val.ClientFactionInfo, Auto.WriteClientFactionInfo, "ClientFactionInfo", false)
	Base.WriteDict7Bit(writer, val.AchievementInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteAchievementDetail, "AchievementDetail", false), nil, "AchievementInfos", false, 0)
end

Auto.WritePlayerClientInfoAtmosphereGameplay = function(writer, val)
	Base.WritePrimitive(writer, val.PartTimeJobDailyRewardTimes, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.PartTimeJobUnlockStore, writer.WriteUInt32, 0, "PartTimeJobUnlockStore", true, 0, nil)
	Base.WriteDict7Bit(writer, val.WorldLifeDropLimit, writer.WriteUInt32, writer.WriteUInt32, 0, "WorldLifeDropLimit", false, 0)
end

Auto.WritePlayerClientInfoGuide = function(writer, val)
	Base.WriteList7Bit(writer, val.FinishedGuides, writer.WriteUInt32, 0, "FinishedGuides", false, 0, nil)
	Base.WriteList7Bit(writer, val.NewGuideTeachInfos, writer.WriteUInt32, 0, "NewGuideTeachInfos", false, 0, nil)
	Base.WriteList7Bit(writer, val.RewardedGuideTeachInfos, writer.WriteUInt32, 0, "RewardedGuideTeachInfos", false, 0, nil)
	Base.WriteList7Bit(writer, val.UnlockSystems, writer.WriteUInt32, 0, "UnlockSystems", false, 0, nil)
	Base.WriteList7Bit(writer, val.TaskTitleGuideUnlockList, writer.WriteUInt16, 0, "TaskTitleGuideUnlockList", true, 0, nil)
end

Auto.WritePlayerClientInfoItem = function(writer, val)
	Base.WritePrimitive(writer, val.Money, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Gold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.BindingGold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.FreeGold, writer.WriteDouble, 0)
	Base.WriteList7Bit(writer, val.ItemDayCounts, Base.WriteComplexWrap(Auto.WritePlayerItemDayCount, "PlayerItemDayCount", false), nil, "ItemDayCounts", false, 0, nil)
	Base.WriteList7Bit(writer, val.PackItems, Base.WriteComplexWrap(Auto.WritePlayerPackItem, "PlayerPackItem", false), nil, "PackItems", false, 0, nil)
	Base.WriteDict7Bit(writer, val.ItemShortcutDic, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteItemShortcutInfo, "ItemShortcutInfo", false), nil, "ItemShortcutDic", false, 0)
	Base.WritePrimitive(writer, val.DestructibleShortcut, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TodayGachaCount, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.GachaPoolCount, writer.WriteUInt32, writer.WriteInt32, 0, "GachaPoolCount", false, 0)
	Base.WriteList7Bit(writer, val.ItemCountLimitInfoList, Base.WriteComplexWrap(Auto.WriteItemCountLimitInfo, "ItemCountLimitInfo", false), nil, "ItemCountLimitInfoList", false, 0, nil)
	Base.WritePrimitive(writer, val.QuantumWalletStartTime, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.PortalPosition, Auto.WriteUXVector3, "PortalPosition")
	Base.WritePrimitive(writer, val.PortalRaidId, writer.WriteUInt32, 0)
end

Auto.WritePlayerClientInfoLogin = function(writer, val)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.AccountId, false, "PlayerClientInfoLogin.AccountId", 0)
	writer.WriteString(writer, val.Name, false, "PlayerClientInfoLogin.Name", 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Sex, 155, 0), writer.WriteByte, 0)
	Base.WriteComplex(writer, val.PzHeadInfo, Auto.WritePersonalZoneHeadInfo, "PzHeadInfo", false)
	Base.WriteComplex(writer, val.LinkPzHeadInfo, Auto.WritePersonalZoneHeadInfo, "LinkPzHeadInfo", false)
	Base.WritePrimitive(writer, val.UseSystemName, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LastLeaveClubTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UniverseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastChangeNameTime, writer.WriteUInt32, 0)
end

Auto.WritePlayerClientInfoMinor = function(writer, val)
	Base.WritePrimitive(writer, val.Exp, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.Fan, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.Fan12, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Fan123, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.YesterdayFan, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.WeeklyFanGrowth, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.LevelRewards, writer.WriteUInt32, 0, "LevelRewards", false, 0, nil)
	Base.WritePrimitive(writer, val.StageLv, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.ReceivedStageLvRewards, writer.WriteUInt32, writer.WriteUInt32, 0, "ReceivedStageLvRewards", false, 0)
	Base.WritePrimitive(writer, val.Questionnaire, writer.WriteInt32, 0)
	Base.WriteDict7Bit(writer, val.DropLimitCount, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteDropLimitInfo, "DropLimitInfo", false), nil, "DropLimitCount", false, 0)
	Base.WriteComplex(writer, val.ChargeInfo, Auto.WriteChargeClientInfo, "ChargeInfo", false)
	Base.WriteDict7Bit(writer, val.MapPins, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteMapPin, "MapPin", false), nil, "MapPins", false, 0)
	Base.WriteComplex(writer, val.MiniGame, Auto.WriteMiniGameData, "MiniGame", false)
	Base.WriteComplex(writer, val.PlayerInfoGuide, Auto.WritePlayerClientInfoGuide, "PlayerInfoGuide", false)
	Base.WriteComplex(writer, val.InfoNpcCultivation, Auto.WritePlayerClientInfoNpcCultivation, "InfoNpcCultivation", false)
	Base.WriteComplex(writer, val.InfoNpcProfile, Auto.WritePlayerClientInfoNpcProfile, "InfoNpcProfile", false)
	Base.WriteComplex(writer, val.PlayerInfoAtmosphereGameplay, Auto.WritePlayerClientInfoAtmosphereGameplay, "PlayerInfoAtmosphereGameplay", false)
	Base.WriteComplex(writer, val.PlayerFashionsInfo, Auto.WritePlayerFashionsInfo, "PlayerFashionsInfo", false)
	Base.WriteComplex(writer, val.PlayerRadioSongsData, Auto.WritePlayerRadioSongsData, "PlayerRadioSongsData", false)
	Base.WriteComplex(writer, val.housesInfo, Auto.WriteHousesInfo, "housesInfo", false)
	Base.WriteComplex(writer, val.PlayerPhoneInfo, Auto.WritePlayerPhoneClientInfo, "PlayerPhoneInfo", false)
	Base.WriteDict7Bit(writer, val.ModuleEventProgressInfoDict, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteModuleEventProgressInfo, "ModuleEventProgressInfo", false), nil, "ModuleEventProgressInfoDict", false, 0)
	Base.WriteDict7Bit(writer, val.UniverseModuleEventProgressInfoDict, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteModuleEventProgressInfo, "ModuleEventProgressInfo", false), nil, "UniverseModuleEventProgressInfoDict", false, 0)
	Base.WriteDict7Bit(writer, val.LoadingTexts, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteLoadingTextInfo, "LoadingTextInfo", false), nil, "LoadingTexts", false, 0)
	Base.WriteDict7Bit(writer, val.Badges, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBadgeInfo, "BadgeInfo", false), nil, "Badges", false, 0)
	Base.WriteList7Bit(writer, val.GroupChats, Base.WriteComplexWrap(Auto.WriteSpiritGroupChatInfo, "SpiritGroupChatInfo", false), nil, "GroupChats", false, 0, nil)
	Base.WriteComplex(writer, val.VehicleInfo, Auto.WritePlayerVehicleInfo, "VehicleInfo", false)
	Base.WriteComplex(writer, val.MatchInfo, Auto.WritePlayerMatchInfo, "MatchInfo", false)
	Base.WriteComplex(writer, val.PopularityInfoNew, Auto.WritePlayerInfoPopularity, "PopularityInfoNew", false)
	Base.WriteComplex(writer, val.ComputerUnlockInfo, Auto.WriteComputerUnlockInfo, "ComputerUnlockInfo", false)
	Base.WriteComplex(writer, val.PlayerInteractionActionInfo, Auto.WritePlayerInteractionActionInfo, "PlayerInteractionActionInfo", false)
	Base.WriteComplex(writer, val.PlayerCityPediaInfos, Auto.WritePlayerCityPediaInfos, "PlayerCityPediaInfos", false)
	Base.WritePrimitive(writer, val.DebugReserveGpuDumps, writer.WriteBoolean, false)
	Base.WriteDict7Bit(writer, val.FavorNpcDailyScheduleInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteNpcTimeTableInfo, "NpcTimeTableInfo", false), nil, "FavorNpcDailyScheduleInfos", true, 0)
	Base.WriteDict7Bit(writer, val.PlayerInterActionInfo, writer.WriteUInt32, Base.WriteStringWrap(false, "PlayerInterActionInfo", 0), nil, "PlayerInterActionInfo", false, 0)
	Base.WriteComplex(writer, val.PlanningBoardInfo, Auto.WritePlanningBoardInfo, "PlanningBoardInfo", false)
	Base.WriteComplex(writer, val.MallInfo, Auto.WriteMallInfo, "MallInfo", false)
	Base.WriteComplex(writer, val.PlayerLinkPlanningBoardInfo, Auto.WritePlayerLinkPlanningBoardInfo, "PlayerLinkPlanningBoardInfo", false)
	Base.WriteComplex(writer, val.PlayerGachaInfos, Auto.WritePlayerGachaInfos, "PlayerGachaInfos", false)
	Base.WriteComplex(writer, val.PlayerInspireHubInfo, Auto.WritePlayerClientInspireHubInfo, "PlayerInspireHubInfo", false)
	Base.WriteComplex(writer, val.PlayerExtractionShooterInfo, Auto.WritePlayerExtractionShooterInfo, "PlayerExtractionShooterInfo", false)
	Base.WriteComplex(writer, val.PlayerOCInfo, Auto.WritePlayerOCInfo, "PlayerOCInfo", false)
	Base.WriteComplex(writer, val.PlayerTuiteInfo, Auto.WritePlayerTuiteClientInfo, "PlayerTuiteInfo", false)
	Base.WriteComplex(writer, val.playerMartialArtistInfo, Auto.WritePlayerInfoMartialArtist, "playerMartialArtistInfo", false)
	Base.WriteDict7Bit(writer, val.GameplayTalentInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritTalentInfo, "SpiritTalentInfo", false), nil, "GameplayTalentInfos", false, 0)
	Base.WriteComplex(writer, val.InfoSubmitItem, Auto.WritePlayerClientInfoSubmitItem, "InfoSubmitItem", false)
	Base.WriteComplex(writer, val.InfoCompound, Auto.WritePlayerCompoundClientInfo, "InfoCompound", false)
	Base.WriteComplex(writer, val.InfoOnlineSeasonProgress, Auto.WritePlayerOnlineSeasonProgressClientInfo, "InfoOnlineSeasonProgress", false)
	Base.WriteComplex(writer, val.PlayerTradeInfo, Auto.WritePlayerTradeInfo, "PlayerTradeInfo", false)
	Base.WriteComplex(writer, val.PlayerGiftInfo, Auto.WritePlayerGiftInfo, "PlayerGiftInfo", false)
	Base.WriteComplex(writer, val.PlayerClubTaskInfo, Auto.WriteClientClubTaskInfo, "PlayerClubTaskInfo", false)
	Base.WriteDict7Bit(writer, val.HUDRecommendDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteHUDRecommendInfo, "HUDRecommendInfo", false), nil, "HUDRecommendDict", false, 0)
	Base.WriteComplex(writer, val.ChefUnlockInfo, Auto.WriteChefUnlockInfo, "ChefUnlockInfo", false)
	Base.WriteComplex(writer, val.FishingInfo, Auto.WritePlayerFishingInfo, "FishingInfo", false)
	Base.WriteComplex(writer, val.SettingInfo, Auto.WritePlayerSettingInfo, "SettingInfo", false)
	Base.WriteComplex(writer, val.InstrumentInfo, Auto.WritePlayerInstrumentInfo, "InstrumentInfo", false)
	Base.WriteComplex(writer, val.PlayerMeccaGrandpaPartsInfo, Auto.WritePlayerMeccaGrandpaPartsInfo, "PlayerMeccaGrandpaPartsInfo", false)
	Base.WriteComplex(writer, val.PlayerWeaponSkinInfo, Auto.WritePlayerWeaponSkinInfo, "PlayerWeaponSkinInfo", false)
	Base.WriteDict7Bit(writer, val.GadgetDropLimitInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "GadgetDropLimitInfo", false, 0)
	Base.WriteComplex(writer, val.PlayerScenarioInfos, Auto.WritePlayerScenarioInfos, "PlayerScenarioInfos", false)
	Base.WriteComplex(writer, val.PlayerLikeInfo, Auto.WritePlayerLikeInfo, "PlayerLikeInfo", false)
	Base.WriteComplex(writer, val.PlayerBasketballAppearanceInfo, Auto.WritePlayerBasketballAppearanceInfo, "PlayerBasketballAppearanceInfo", false)
	Base.WriteDict7Bit(writer, val.DropControlCountDict, writer.WriteUInt32, writer.WriteUInt32, 0, "DropControlCountDict", false, 0)
	Base.WriteList7Bit(writer, val.BeggarAiPaintings, Base.WriteComplexWrap(Auto.WriteBeggarAiPaintingClientInfo, "BeggarAiPaintingClientInfo", false), nil, "BeggarAiPaintings", false, 0, nil)
	Base.WriteComplex(writer, val.ChatInfo, Auto.WritePlayerClientChatInfo, "ChatInfo", false)
end

Auto.WritePlayerClientInfoNpcCultivation = function(writer, val)
	Base.WriteList7Bit(writer, val.NpcCardInfos, Base.WriteComplexWrap(Auto.WriteNpcCardInfo, "NpcCardInfo", false), nil, "NpcCardInfos", false, 0, nil)
	Base.WriteList7Bit(writer, val.LockedCardInfos, Base.WriteComplexWrap(Auto.WriteNpcCardInfo, "NpcCardInfo", false), nil, "LockedCardInfos", false, 0, nil)
	Base.WriteList7Bit(writer, val.NpcChats, Base.WriteComplexWrap(Auto.WriteClientNpcChatData, "ClientNpcChatData", false), nil, "NpcChats", false, 0, nil)
	Base.WriteList7Bit(writer, val.NpcGroupChats, Base.WriteComplexWrap(Auto.WriteClientNpcGroupChatData, "ClientNpcGroupChatData", false), nil, "NpcGroupChats", false, 0, nil)
	Base.WritePrimitive(writer, val.AvailableGiftSendCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InteractPoint, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.NpcEventQueueList, Auto.WriteNpcEventQueueList, "NpcEventQueueList", false)
	Base.WriteDict7Bit(writer, val.ChatGroupRenameDict, writer.WriteUInt32, writer.WriteUInt32, 0, "ChatGroupRenameDict", false, 0)
end

Auto.WritePlayerClientInfoNpcProfile = function(writer, val)
	Base.WriteDict7Bit(writer, val.NpcProfiles, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteTrustNpcInfo, "TrustNpcInfo", false), nil, "NpcProfiles", false, 0)
	Base.WriteList7Bit(writer, val.ProgressRewards, writer.WriteUInt32, 0, "ProgressRewards", false, 0, nil)
	Base.WriteDict7Bit(writer, val.ProgressRewardsWithWeb, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteProfileWebGotProgressList, "ProfileWebGotProgressList", false), nil, "ProgressRewardsWithWeb", false, 0)
end

Auto.WritePlayerClientInfoPolice = function(writer, val)
	Base.WritePrimitive(writer, val.TodayCompleteMissionCnt, writer.WriteUInt32, 0)
end

Auto.WritePlayerClientInfoSpirit = function(writer, val)
	Base.WriteList7Bit(writer, val.Spirits, Base.WriteComplexWrap(Auto.WriteSpiritInfo, "SpiritInfo", false), nil, "Spirits", false, 0, nil)
	Base.WriteComplex(writer, val.InfoPokemon, Auto.WritePlayerInfoPokemon, "InfoPokemon", false)
	Base.WriteList7Bit(writer, val.AvailableSkinParts, writer.WriteUInt32, 0, "AvailableSkinParts", false, 0, nil)
	Base.WriteComplex(writer, val.InfoArmory, Auto.WritePlayerInfoArmory, "InfoArmory", false)
	Base.WritePrimitive(writer, val.ActiveSpirit, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.DisableBadgeInfosDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteDisableBadgeInfos, "DisableBadgeInfos", false), nil, "DisableBadgeInfosDict", false, 0)
	Base.WriteComplex(writer, val.InfoFightStyle, Auto.WritePlayerInfoFightStyle, "InfoFightStyle", false)
	Base.WritePrimitive(writer, val.CommonSpiritTalentExp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritInitTalentPointAdd, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.InfoPolice, Auto.WritePlayerClientInfoPolice, "InfoPolice", false)
	Base.WritePrimitive(writer, val.SexTransitionLastTime, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.InstalledApps, writer.WriteUInt32, 0, "InstalledApps", false, 0, nil)
end

Auto.WritePlayerClientInfoSubmitItem = function(writer, val)
	Base.WriteDict7Bit(writer, val.SubmitItemDataDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSubmitItemData, "SubmitItemData", false), nil, "SubmitItemDataDict", false, 0)
end

Auto.WritePlayerClientInspireHubInfo = function(writer, val)
	Base.WriteDict7Bit(writer, val.TodayGamePlayJoinCountDict, writer.WriteUInt32, writer.WriteInt32, 0, "TodayGamePlayJoinCountDict", false, 0)
end

Auto.WritePlayerClientTempleInfo = function(writer, val)
	Base.WriteDict7Bit(writer, val.IncenseRecords, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteUintList, "UintList", false), nil, "IncenseRecords", false, 0)
end

Auto.WritePlayerClientYachtInfo = function(writer, val)
	Base.WritePrimitive(writer, val.YachtId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Heat, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.SelectedOptionIds, writer.WriteUInt32, 0, "SelectedOptionIds", false, 0, nil)
	writer.WriteString(writer, val.CustomName, false, "PlayerClientYachtInfo.CustomName", 0)
	Base.WritePrimitive(writer, val.LastChangeNameTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.AccessMode, 14, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.IsLocked, writer.WriteBoolean, false)
end

Auto.WritePlayerCollectionBoothInfo = function(writer, val)
	Base.WriteDict(writer, val.SlotInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerCollectionBoothSlotInfo, "PlayerCollectionBoothSlotInfo", false), nil, "SlotInfos", false, 0)
end

Auto.WritePlayerCollectionBoothSlotInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.ItemInfo, Auto.WritePlayerCollectionItemInfo, "ItemInfo", true)
	Base.WritePrimitive(writer, val.ActiveLevel, writer.WriteUInt32, 0)
end

Auto.WritePlayerCollectionItemInfo = function(writer, val)
	Base.WritePrimitive(writer, val.ItemId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.WeaponInfo, Auto.WritePlayerCollectionWeaponPartial, "WeaponInfo", true)
	Base.WriteComplex(writer, val.VehicleInfo, Auto.WritePlayerCollectionVehiclePartial, "VehicleInfo", true)
end

Auto.WritePlayerCollectionRoomInfo = function(writer, val)
	Base.WriteDict(writer, val.BoothInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerCollectionBoothInfo, "PlayerCollectionBoothInfo", false), nil, "BoothInfos", false, 0)
	Base.WritePrimitive(writer, val.Collectibility, writer.WriteUInt32, 0)
end

Auto.WritePlayerCollectionVehiclePartial = function(writer, val)
	Base.WriteComplex(writer, val.VehicleInfo, Auto.WritePlayerVehicleDetail, "VehicleInfo", false)
end

Auto.WritePlayerCollectionWeaponPartial = function(writer, val)
	Base.WritePrimitive(writer, val.SkinId, writer.WriteUInt32, 0)
end

Auto.WritePlayerCompoundClientInfo = function(writer, val)
	Base.WriteDict7Bit(writer, val.StationDataDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteCompoundStationClientInfo, "CompoundStationClientInfo", false), nil, "StationDataDict", false, 0)
	Base.WriteDict7Bit(writer, val.UseRecords, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteCompoundUseClientInfo, "CompoundUseClientInfo", false), nil, "UseRecords", false, 0)
end

Auto.WritePlayerDieInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 171, 0), writer.WriteInt16, 0)
	Base.WritePrimitive(writer, val.SourceTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SourceCreationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsMatchGameComplete, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.KillerSpawnTaskId, writer.WriteUInt32, 0)
end

Auto.WritePlayerExtractionShooterInfo = function(writer, val)
	Base.WriteDict(writer, val.Bags, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteExtractionShooterBagInfo, "ExtractionShooterBagInfo", false), nil, "Bags", false, 0)
	Base.WriteDict(writer, val.BringOutFunds, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteExtractionShooterBringOutFund, "ExtractionShooterBringOutFund", false), nil, "BringOutFunds", false, 0)
	Base.WritePrimitive(writer, val.TokenCount, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.SlotGroups, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteExtractionShooterSlotGroupInfo, "ExtractionShooterSlotGroupInfo", false), nil, "SlotGroups", false, 0)
	Base.WriteDict(writer, val.UnlockedExpansionIds, writer.WriteUInt32, writer.WriteBoolean, false, "UnlockedExpansionIds", false, 0)
	Base.WriteDict(writer, val.UnlockedBagIds, writer.WriteUInt32, writer.WriteBoolean, false, "UnlockedBagIds", false, 0)
	Base.WriteDict(writer, val.GamePlayTypeTotalBringOutIncome, writer.WriteUInt32, writer.WriteUInt32, 0, "GamePlayTypeTotalBringOutIncome", false, 0)
end

Auto.WritePlayerFashionsInfo = function(writer, val)
	Base.WriteDict(writer, val.SpiritFashionsInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritFashionsInfo, "SpiritFashionsInfo", false), nil, "SpiritFashionsInfoDict", false, 0)
	Base.WriteDict(writer, val.FashionInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFashionInfo, "FashionInfo", false), nil, "FashionInfoDict", false, 0)
	Base.WriteList(writer, val.FavoriteFashionIdList, writer.WriteUInt32, 0, "FavoriteFashionIdList", false, 0, nil)
	Base.WriteList(writer, val.FavoriteFashionSuitIdList, writer.WriteUInt32, 0, "FavoriteFashionSuitIdList", false, 0, nil)
	Base.WritePrimitive(writer, val.DefaultSpiritIsInitDefaultFashion, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ColoringCollectionScore, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.FashionSuitInstanceDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFashionSuitInstanceInfo, "FashionSuitInstanceInfo", false), nil, "FashionSuitInstanceDict", false, 0)
end

Auto.WritePlayerFightStyleUnLockChangeInfo = function(writer, val)
	Base.WriteComplex(writer, val.playerInfoFightStyle, Auto.WritePlayerInfoFightStyle, "playerInfoFightStyle", true)
	Base.WriteDict7Bit(writer, val.addOrUpdateUnlockInfo, writer.WriteUInt32, writer.WriteBoolean, false, "addOrUpdateUnlockInfo", true, 0)
	Base.WriteDict7Bit(writer, val.addOrUpdateUnlockTimeInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "addOrUpdateUnlockTimeInfo", true, 0)
end

Auto.WritePlayerFishingGameplayInfo = function(writer, val)
	Base.WriteDict(writer, val.SpotPools, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerFishingSpotPool, "PlayerFishingSpotPool", false), nil, "SpotPools", false, 0)
	Base.WriteDict(writer, val.SpotLastRefreshTime, writer.WriteUInt32, writer.WriteUInt32, 0, "SpotLastRefreshTime", false, 0)
	Base.WriteDict(writer, val.SpotLastResetTime, writer.WriteUInt32, writer.WriteUInt32, 0, "SpotLastResetTime", false, 0)
end

Auto.WritePlayerFishingInfo = function(writer, val)
	Base.WriteDict(writer, val.GearDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFishingGearInfo, "FishingGearInfo", false), nil, "GearDict", false, 0)
	Base.WriteDict(writer, val.ConsumableFishDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFishInfo, "FishInfo", false), nil, "ConsumableFishDict", false, 0)
	Base.WriteDict(writer, val.OrnamentalFishDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFishInfo, "FishInfo", false), nil, "OrnamentalFishDict", false, 0)
	Base.WritePrimitive(writer, val.NextUniqueId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.GameplayInfo, Auto.WritePlayerFishingGameplayInfo, "GameplayInfo", false)
end

Auto.WritePlayerFishingSpotFish = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FishConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpawnTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Weight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Length, writer.WriteSingle, 0)
end

Auto.WritePlayerFishingSpotPool = function(writer, val)
	Base.WriteDict(writer, val.Fishes, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerFishingSpotFish, "PlayerFishingSpotFish", false), nil, "Fishes", false, 0)
end

Auto.WritePlayerGachaDrawRecord = function(writer, val)
	Base.WritePrimitive(writer, val.GachaId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PoolContentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DropId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DrawTimeUnix, writer.WriteInt64, 0)
end

Auto.WritePlayerGachaGroupInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TotalDrawCount, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ClaimedMilestoneCounts, writer.WriteUInt32, writer.WriteBoolean, false, "ClaimedMilestoneCounts", false, 0)
end

Auto.WritePlayerGachaInfos = function(writer, val)
	Base.WriteDict(writer, val.PoolInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerGachaPoolInfo, "PlayerGachaPoolInfo", false), nil, "PoolInfos", false, 0)
	Base.WriteDict(writer, val.GroupInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerGachaGroupInfo, "PlayerGachaGroupInfo", false), nil, "GroupInfos", false, 0)
	Base.WriteDict(writer, val.PityInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerGachaPityInfo, "PlayerGachaPityInfo", false), nil, "PityInfos", false, 0)
end

Auto.WritePlayerGachaPityInfo = function(writer, val)
	Base.WritePrimitive(writer, val.DrawsSinceLastReset, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalDrawCount, writer.WriteUInt32, 0)
end

Auto.WritePlayerGachaPoolInfo = function(writer, val)
	Base.WritePrimitive(writer, val.DrawCount, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.WonItemIds, writer.WriteUInt32, writer.WriteBoolean, false, "WonItemIds", false, 0)
	Base.WriteList(writer, val.DrawRecords, Base.WriteComplexWrap(Auto.WritePlayerGachaDrawRecord, "PlayerGachaDrawRecord", false), nil, "DrawRecords", false, 0, nil)
end

Auto.WritePlayerGameInfo = function(writer, val)
	Base.WritePrimitive(writer, val.MultiPlayerId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 224, 0), writer.WriteByte, 0)
end

Auto.WritePlayerGiftInfo = function(writer, val)
	Base.WriteList(writer, val.UnclaimedGifts, Base.WriteComplexWrap(Auto.WriteGiftEntry, "GiftEntry", false), nil, "UnclaimedGifts", false, 0, nil)
	Base.WritePrimitive(writer, val.IsGiftOwnedInitialized, writer.WriteBoolean, false)
	Base.WriteList(writer, val.HandledGifts, Base.WriteComplexWrap(Auto.WriteGiftEntry, "GiftEntry", false), nil, "HandledGifts", false, 0, nil)
	Base.WriteList(writer, val.RefundedGiftIds, writer.WriteUInt64, 0, "RefundedGiftIds", false, 0, nil)
end

Auto.WritePlayerGuitarInfo = function(writer, val)
	Base.WriteList(writer, val.ChordIds, writer.WriteInt32, 0, "ChordIds", false, RpcLengthLimits.PlayerGuitarInfo_ChordIds, nil)
	Base.WritePrimitive(writer, val.rhythmA, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.rhythmB, writer.WriteInt32, 0)
end

Auto.WritePlayerHandData = function(writer, val)
	Base.WriteList7Bit(writer, val.HandTiles, Base.WriteStructWrap(Auto.WriteTile, "HandTiles"), nil, "HandTiles", false, 0, nil)
	Base.WriteList7Bit(writer, val.OpenMelds, Base.WriteStructWrap(Auto.WriteOpenMeld, "OpenMelds"), nil, "OpenMelds", false, 0, nil)
end

Auto.WritePlayerHotSpringInfo = function(writer, val)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CompanionNpc, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Used, writer.WriteBoolean, false)
end

Auto.WritePlayerHouseCameraConfiguration = function(writer, val)
	Base.WritePrimitive(writer, val.MoveSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpinSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ZoomSpeed, writer.WriteSingle, 0)
end

Auto.WritePlayerHouseConfiguration = function(writer, val)
	Base.WriteComplex(writer, val.Camera, Auto.WritePlayerHouseCameraConfiguration, "Camera", false)
end

Auto.WritePlayerHouseLoadData = function(writer, val)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
end

Auto.WritePlayerInfoArmory = function(writer, val)
	Base.WriteList(writer, val.Weapons, Base.WriteComplexWrap(Auto.WriteWeaponData, "WeaponData", false), nil, "Weapons", false, 0, nil)
	Base.WriteDict(writer, val.WeaponFirstObtainTimes, writer.WriteUInt32, writer.WriteUInt32, 0, "WeaponFirstObtainTimes", false, 0)
end

Auto.WritePlayerInfoBadge = function(writer, val)
	Base.WriteDict(writer, val.Badges, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBadgeInfo, "BadgeInfo", false), nil, "Badges", false, 0)
	Base.WriteDict(writer, val.HistoryBadges, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBadgeInfo, "BadgeInfo", false), nil, "HistoryBadges", false, 0)
end

Auto.WritePlayerInfoFightStyle = function(writer, val)
	Base.WriteDict(writer, val.FightStyleIsUnLocked, writer.WriteUInt32, writer.WriteBoolean, false, "FightStyleIsUnLocked", false, 0)
	Base.WriteDict(writer, val.FightStyleFirstUnlockTimes, writer.WriteUInt32, writer.WriteUInt32, 0, "FightStyleFirstUnlockTimes", false, 0)
end

Auto.WritePlayerInfoGameGroundChineseChess = function(writer, val)
	Base.WriteDict(writer, val.DroppedEndGameIdSet, writer.WriteUInt32, writer.WriteBoolean, false, "DroppedEndGameIdSet", false, 0)
	Base.WriteDict(writer, val.DroppedDoubleAIDifficultySet, writer.WriteUInt32, writer.WriteBoolean, false, "DroppedDoubleAIDifficultySet", false, 0)
	Base.WritePrimitive(writer, val.DoubleAINormalWinCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DoubleAINormalTotalCount, writer.WriteUInt32, 0)
end

Auto.WritePlayerInfoGameGroundGomoku = function(writer, val)
	Base.WriteDict(writer, val.DroppedEndGameIdSet, writer.WriteUInt32, writer.WriteBoolean, false, "DroppedEndGameIdSet", false, 0)
	Base.WriteDict(writer, val.DroppedDoubleAIDifficultySet, writer.WriteUInt32, writer.WriteBoolean, false, "DroppedDoubleAIDifficultySet", false, 0)
	Base.WriteDict(writer, val.DroppedDoubleAISkillDifficultySet, writer.WriteUInt32, writer.WriteBoolean, false, "DroppedDoubleAISkillDifficultySet", false, 0)
	Base.WritePrimitive(writer, val.DoubleAINormalWinCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DoubleAISkillWinCount, writer.WriteUInt32, 0)
end

Auto.WritePlayerInfoJobGangBoss = function(writer, val)
	Base.WriteDict(writer, val.GangMembers, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteGangMembersInfos, "GangMembersInfos", false), nil, "GangMembers", false, 0)
end

Auto.WritePlayerInfoJobWasher = function(writer, val)
	Base.WritePrimitive(writer, val.LastRefreshMissionTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurMissionIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurMissionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurMissionEventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurMissionProgress, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CurMissionStartTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.HistoryMissionResults, Base.WriteComplexWrap(Auto.WriteWasherMissionResult, "WasherMissionResult", false), nil, "HistoryMissionResults", false, 0, nil)
	Base.WriteComplex(writer, val.CurMissionResult, Auto.WriteWasherMissionResult, "CurMissionResult", true)
	Base.WriteList(writer, val.RandomMissionHistory, Base.WriteComplexWrap(Auto.WriteWasherMissionHistoryItem, "WasherMissionHistoryItem", false), nil, "RandomMissionHistory", false, 0, nil)
	Base.WriteDict(writer, val.Spirit2HistoryMissionInfo, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteWasherMissionHistoryInfo, "WasherMissionHistoryInfo", false), nil, "Spirit2HistoryMissionInfo", false, 0)
	Base.WritePrimitive(writer, val.HistoryMissionCnt, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HistoryMissionMoney, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TodayMissionMoney, writer.WriteInt32, 0)
	Base.WriteDict(writer, val.MissionDic, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteWasherMissionHistoryItem, "WasherMissionHistoryItem", false), nil, "MissionDic", false, 0)
	Base.WritePrimitive(writer, val.CurRandomCfgId, writer.WriteUInt32, 0)
end

Auto.WritePlayerInfoMartialArtist = function(writer, val)
	Base.WriteDict(writer, val.RumorBackpack, writer.WriteUInt32, writer.WriteBoolean, false, "RumorBackpack", false, 0)
	Base.WriteDict(writer, val.SlottedRumors, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteMartialArtistSlotInfo, "MartialArtistSlotInfo", false), nil, "SlottedRumors", false, 0)
	Base.WriteDict(writer, val.FinishedWuxueId, writer.WriteUInt32, writer.WriteBoolean, false, "FinishedWuxueId", false, 0)
	Base.WriteDict(writer, val.CompletedQuests, writer.WriteUInt32, writer.WriteBoolean, false, "CompletedQuests", false, 0)
	Base.WriteDict(writer, val.UnlockedQuests, writer.WriteUInt32, writer.WriteBoolean, false, "UnlockedQuests", false, 0)
	Base.WriteDict(writer, val.PendingGossipRumors, writer.WriteUInt32, writer.WriteBoolean, false, "PendingGossipRumors", false, 0)
end

Auto.WritePlayerInfoPokemon = function(writer, val)
	Base.WriteList(writer, val.AllPokemons, Base.WriteComplexWrap(Auto.WritePokemonEnemy, "PokemonEnemy", false), nil, "AllPokemons", false, 0, nil)
	Base.WriteList(writer, val.FastFightSquad, writer.WriteUInt64, 0, "FastFightSquad", false, 0, nil)
end

Auto.WritePlayerInfoPopularity = function(writer, val)
	Base.WritePrimitive(writer, val.Popularity, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NextPopularityUpdateTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.HistoryPopularityList, Base.WriteComplexWrap(Auto.WritePopularityData, "PopularityData", false), nil, "HistoryPopularityList", false, 0, nil)
	Base.WriteList(writer, val.PastDaysPopularityList, Base.WriteComplexWrap(Auto.WritePopularityData, "PopularityData", false), nil, "PastDaysPopularityList", false, 0, nil)
	Base.WritePrimitive(writer, val.TotalLeftMoney, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastPopularityUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextYesterdayAvgPopularityUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TodayCoinGet, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.PastHoursCoinRewards, Base.WriteComplexWrap(Auto.WritePopularityWalletRewardData, "PopularityWalletRewardData", false), nil, "PastHoursCoinRewards", false, 0, nil)
	Base.WriteComplex(writer, val.FanBoxDropInfo, Auto.WriteFanBoxDropInfo, "FanBoxDropInfo", false)
	Base.WritePrimitive(writer, val.YesterdayCoinGet, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.YesterdayAvgPopularity, writer.WriteInt32, 0)
	Base.WriteList(writer, val.DropRecordList, Base.WriteComplexWrap(Auto.WritePopularityDropData, "PopularityDropData", false), nil, "DropRecordList", false, 0, nil)
	Base.WritePrimitive(writer, val.LastSettlementTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.DayRewardList, Base.WriteComplexWrap(Auto.WritePopularityDayRewardInfo, "PopularityDayRewardInfo", false), nil, "DayRewardList", false, 0, nil)
	Base.WriteList(writer, val.PastDaysHighestPopularityList, Base.WriteComplexWrap(Auto.WritePopularityData, "PopularityData", false), nil, "PastDaysHighestPopularityList", false, 0, nil)
	Base.WritePrimitive(writer, val.IsFirstTriggered, writer.WriteBoolean, false)
	Base.WriteList(writer, val.HotGainEventList, Base.WriteComplexWrap(Auto.WritePopularityHotGainEventInfo, "PopularityHotGainEventInfo", false), nil, "HotGainEventList", false, 0, nil)
	Base.WritePrimitive(writer, val.IsFirstPhoneOpened, writer.WriteBoolean, false)
end

Auto.WritePlayerInstrumentInfo = function(writer, val)
	Base.WriteDict(writer, val.GuitarInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerGuitarInfo, "PlayerGuitarInfo", false), nil, "GuitarInfos", false, 0)
end

Auto.WritePlayerInteractionActionInfo = function(writer, val)
	Base.WriteDict(writer, val.UnlockActionItemDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerInteractionActionItem, "PlayerInteractionActionItem", false), nil, "UnlockActionItemDict", false, 0)
	Base.WritePrimitive(writer, val.InvitedNotDisturb, writer.WriteBoolean, false)
end

Auto.WritePlayerInteractionActionItem = function(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowRedPoint, writer.WriteBoolean, false)
end

Auto.WritePlayerInvestigateCountryInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CountryId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Reputation, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsShow, writer.WriteBoolean, false)
	Base.WriteList(writer, val.GalleryInfos, Base.WriteComplexWrap(Auto.WritePlayerInvestigateGalleryInfo, "PlayerInvestigateGalleryInfo", false), nil, "GalleryInfos", false, 0, nil)
end

Auto.WritePlayerInvestigateGalleryInfo = function(writer, val)
	Base.WritePrimitive(writer, val.GalleryId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsArchived, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CountryId, writer.WriteUInt32, 0)
end

Auto.WritePlayerItemDayCount = function(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

Auto.WritePlayerLikeInfo = function(writer, val)
	Base.WritePrimitive(writer, val.LastResetTime, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.HomepageLikes, writer.WriteUInt64, writer.WriteBoolean, false, "HomepageLikes", false, 0)
end

Auto.WritePlayerLinkInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PlayMode, 8, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.LinkId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PublicLinkId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PrivateLinkId, writer.WriteUInt64, 0)
end

Auto.WritePlayerLinkPlanningBoardInfo = function(writer, val)
	Base.WritePrimitive(writer, val.SelectedGameplayAttributeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastRaidMultiPlayerId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.MultiPlayerIdStates, writer.WriteUInt32, writer.WriteByte, 0, "MultiPlayerIdStates", false, 0)
end

Auto.WritePlayerLoginOption = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Mode, 8, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 225, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.FastPlayRaidId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.FastPlayPosition, Auto.WriteUXVector3, "FastPlayPosition")
	Base.WritePrimitive(writer, Base.CheckEnum(val.FromWhere, 226, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SkipLifeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.JumpToMainEvent, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DeviceLevel, 48, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.DisplayLevel, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SceneItemQuality, writer.WriteInt32, 0)
	Base.WriteList(writer, val.ClientBundles, writer.WriteUInt32, 0, "ClientBundles", false, RpcLengthLimits.PlayerLoginOption_ClientBundles, nil)
	writer.WriteString(writer, val.SubEmail, false, "PlayerLoginOption.SubEmail", RpcLengthLimits.PlayerLoginOption_SubEmail)
end

Auto.WritePlayerMahjongInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxRank, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.RewardRank, writer.WriteUInt32, 0, "RewardRank", false, 0, nil)
	Base.WritePrimitive(writer, val.GameCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WinningStreakCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LosingStreakCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcMahjongId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcRefreshTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcAddFavorNum, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.XlchAITotalCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.XlchAIWinCount, writer.WriteUInt32, 0)
end

Auto.WritePlayerMatchInfo = function(writer, val)
	Base.WriteDict(writer, val.GameId2LastPlayTime, writer.WriteUInt32, writer.WriteUInt32, 0, "GameId2LastPlayTime", false, 0)
	Base.WritePrimitive(writer, val.LastInviteAllTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.AvailablePrepareActions, writer.WriteUInt32, 0, "AvailablePrepareActions", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DeviceLevel, 45, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CurLinkDeviceLevel, 45, 1), writer.WriteByte, 1)
	Base.WriteComplex(writer, val.playerGameInfo, Auto.WritePlayerGameInfo, "playerGameInfo", false)
	Base.WriteDict(writer, val.RememberPrepareInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteRememberPrepareInfo, "RememberPrepareInfo", false), nil, "RememberPrepareInfos", false, 0)
end

Auto.WritePlayerMeccaGrandpaPartsInfo = function(writer, val)
	Base.WriteDict(writer, val.Parts, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteMeccaGrandpaPartInfo, "MeccaGrandpaPartInfo", false), nil, "Parts", false, 0)
	Base.WriteComplex(writer, val.BuildInfo, Auto.WriteMeccaGrandpaBuildInfo, "BuildInfo", false)
end

Auto.WritePlayerMonthlyPassInfo = function(writer, val)
	Base.WriteDict(writer, val.MonthlyPassInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteMonthlyPassInfo, "MonthlyPassInfo", false), nil, "MonthlyPassInfos", false, 0)
end

Auto.WritePlayerOCInfo = function(writer, val)
	Base.WriteDict(writer, val.OCInfoDict, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteOCInfo, "OCInfo", false), nil, "OCInfoDict", false, 0)
	Base.WriteDict(writer, val.SpeechInfosDict, Base.WriteStringWrap(false, "SpeechInfosDict", 0), Base.WriteComplexWrap(Auto.WriteOCSpeechInfo, "OCSpeechInfo", false), nil, "SpeechInfosDict", false, 0)
	Base.WritePrimitive(writer, val.PreGenerateOCId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.MemoryInfo, Auto.WriteOCMemoryInfo, "MemoryInfo", false)
	Base.WriteComplex(writer, val.OCMeccaGrandpaInfo, Auto.WriteOCMeccaGrandpaInfo, "OCMeccaGrandpaInfo", false)
	Base.WritePrimitive(writer, val.NextFashionOCId, writer.WriteUInt32, 0)
end

Auto.WritePlayerOnlineSeasonProgressChangeInfo = function(writer, val)
	Base.WriteDict7Bit(writer, val.ChangedTaskStates, writer.WriteUInt32, writer.WriteByte, 0, "ChangedTaskStates", true, 0)
	Base.WriteDict7Bit(writer, val.ChangedExtraTaskStates, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerOnlineSessonTaskExtraState, "PlayerOnlineSessonTaskExtraState", false), nil, "ChangedExtraTaskStates", true, 0)
	Base.WritePrimitive(writer, val.SeasonId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SeasonProgress, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SeasonLevel, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.ClaimedLevelRewards, writer.WriteUInt32, 0, "ClaimedLevelRewards", true, 0, nil)
	Base.WriteList7Bit(writer, val.PendingSeasonRewards, Base.WriteComplexWrap(Auto.WritePendingSeasonReward, "PendingSeasonReward", true), nil, "PendingSeasonRewards", true, 0, nil)
	Base.WritePrimitive(writer, val.IsSeasonUnlocked, writer.WriteBoolean, false)
end

Auto.WritePlayerOnlineSeasonProgressClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CurrentSeasonId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsSeasonUnlocked, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SeasonProgress, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SeasonLevel, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.ClaimedLevelRewards, writer.WriteUInt32, 0, "ClaimedLevelRewards", false, 0, nil)
	Base.WriteDict7Bit(writer, val.TaskStates, writer.WriteUInt32, writer.WriteByte, 0, "TaskStates", false, 0)
	Base.WriteDict7Bit(writer, val.ExtraTaskStates, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerOnlineSessonTaskExtraState, "PlayerOnlineSessonTaskExtraState", false), nil, "ExtraTaskStates", false, 0)
	Base.WriteList7Bit(writer, val.PendingSeasonRewards, Base.WriteComplexWrap(Auto.WritePendingSeasonReward, "PendingSeasonReward", false), nil, "PendingSeasonRewards", false, 0, nil)
end

Auto.WritePlayerOnlineSessonTaskExtraState = function(writer, val)
	Base.WritePrimitive(writer, val.CompleteCount, writer.WriteUInt32, 0)
end

Auto.WritePlayerPackItem = function(writer, val)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsNew, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ExpiryTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.RemindState, 227, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Quality, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Tags, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsBind, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.Components, Auto.WritePackItemComponents, "Components", true)
	Base.WritePrimitive(writer, val.CDFinishTime, writer.WriteUInt32, 0)
end

Auto.WritePlayerPackItemComponent = function(writer, val)
end

Auto.WritePlayerPartyInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PartyTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ContinuousPartyTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.lastPartyTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.PartyNPC, writer.WriteUInt32, 0, "PartyNPC", false, 0, nil)
	Base.WritePrimitive(writer, val.useDefaultFashion, writer.WriteBoolean, false)
end

Auto.WritePlayerPersonalZoneInfo = function(writer, val)
	writer.WriteString(writer, val.RoleName, false, "PlayerPersonalZoneInfo.RoleName", 0)
	writer.WriteString(writer, val.Signature, true, "PlayerPersonalZoneInfo.Signature", 0)
	Base.WritePrimitive(writer, val.Birthday, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.BestNpcFriends, Base.WriteComplexWrap(Auto.WritePersonalZoneSpiritInfo, "PersonalZoneSpiritInfo", false), nil, "BestNpcFriends", false, 0, nil)
	Base.WritePrimitive(writer, val.Background, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AvatarFrame, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PopUp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NameEffect, writer.WriteUInt32, 0)
end

Auto.WritePlayerPhoneClientInfo = function(writer, val)
	Base.WriteDict7Bit(writer, val.SpiritPhoneInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePhoneInfos, "PhoneInfos", false), nil, "SpiritPhoneInfos", false, 0)
	Base.WriteList7Bit(writer, val.DownLoadAppIds, writer.WriteUInt32, 0, "DownLoadAppIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.TempDisabledContactIds, writer.WriteUInt32, 0, "TempDisabledContactIds", false, 0, nil)
end

Auto.WritePlayerPublicInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.ScenarioInfo, Auto.WritePlayerScenarioPublicInfo, "ScenarioInfo", true)
end

Auto.WritePlayerRacingCompetitionGroupInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.UnlockCompetitionTypes, writer.WriteUInt32, 0, "UnlockCompetitionTypes", true, 0, nil)
	Base.WriteDict7Bit(writer, val.CompetitionGroupInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteRacingCompetitionGroupInfo, "RacingCompetitionGroupInfo", false), nil, "CompetitionGroupInfos", true, 0)
	Base.WriteDict7Bit(writer, val.CompetitionHistoryInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteRacingCompetitionInfo, "RacingCompetitionInfo", false), nil, "CompetitionHistoryInfos", true, 0)
	Base.WritePrimitive(writer, val.CompetitionPoint, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CompetitionStar, writer.WriteInt32, 0)
	Base.WriteDict7Bit(writer, val.MemberCompetitionPoint, writer.WriteUInt32, writer.WriteUInt32, 0, "MemberCompetitionPoint", true, 0)
end

Auto.WritePlayerRadioSongsData = function(writer, val)
	Base.WriteDict(writer, val.SongInfoDict, writer.WriteUInt32, writer.WriteBoolean, false, "SongInfoDict", false, 0)
end

Auto.WritePlayerScenarioInfo = function(writer, val)
	writer.WriteString(writer, val.SceneName, false, "PlayerScenarioInfo.SceneName", RpcLengthLimits.PlayerScenarioInfo_SceneName)
	Base.WriteComplex(writer, val.PublicInfo, Auto.WritePlayerScenarioPublicInfo, "PublicInfo", true)
end

Auto.WritePlayerScenarioInfos = function(writer, val)
	Base.WritePrimitive(writer, val.CurSlot, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.PlayerScenarioInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerScenarioInfo, "PlayerScenarioInfo", false), nil, "PlayerScenarioInfoDict", false, 0)
end

Auto.WritePlayerScenarioPublicInfo = function(writer, val)
	Base.WritePrimitive(writer, val.SceneId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Thumbnail, false, "PlayerScenarioPublicInfo.Thumbnail", RpcLengthLimits.PlayerScenarioPublicInfo_Thumbnail)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WritePrimitive(writer, val.FieldOfView, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.Vehicles, Base.WriteComplexWrap(Auto.WritePlayerScenarioVehicle, "PlayerScenarioVehicle", false), nil, "Vehicles", false, RpcLengthLimits.PlayerScenarioPublicInfo_Vehicles, nil)
	Base.WriteList(writer, val.Spirits, Base.WriteComplexWrap(Auto.WritePlayerScenarioSpirit, "PlayerScenarioSpirit", false), nil, "Spirits", false, RpcLengthLimits.PlayerScenarioPublicInfo_Spirits, nil)
	Base.WriteList(writer, val.Stickers, Base.WriteComplexWrap(Auto.WritePlayerScenarioSticker, "PlayerScenarioSticker", false), nil, "Stickers", false, RpcLengthLimits.PlayerScenarioPublicInfo_Stickers, nil)
	Base.WritePrimitive(writer, val.FilterId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FilterStrength, writer.WriteInt32, 0)
end

Auto.WritePlayerScenarioSpirit = function(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SchemeIndex, writer.WriteByte, 0)
	Base.WriteComplex(writer, val.CustomFashionInfo, Auto.WriteFashionCustomSuitSchemeInfo, "CustomFashionInfo", true)
	Base.WritePrimitive(writer, val.ActionType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActionGroup, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.IKType, false, "PlayerScenarioSpirit.IKType", RpcLengthLimits.PlayerScenarioSpirit_IKType)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WriteComplex(writer, val.FashionInfo, Auto.WriteSpiritWearFashionsInfo, "FashionInfo", true)
	Base.WritePrimitive(writer, val.Expression, writer.WriteUInt32, 0)
end

Auto.WritePlayerScenarioSticker = function(writer, val)
	Base.WritePrimitive(writer, val.StickerId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WritePrimitive(writer, val.ScaleX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ScaleY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Mode, writer.WriteUInt32, 0)
end

Auto.WritePlayerScenarioVehicle = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WriteComplex(writer, val.VehicleInfo, Auto.WritePlayerVehicleDetail, "VehicleInfo", true)
end

Auto.WritePlayerSettingInfo = function(writer, val)
	Base.WriteDict(writer, val.SettingDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerSettingValue, "PlayerSettingValue", false), nil, "SettingDict", false, 0)
end

Auto.WritePlayerSettingValue = function(writer, val)
	Base.WritePrimitive(writer, val.NumberValue, writer.WriteDouble, 0)
	writer.WriteString(writer, val.StringValue, true, "PlayerSettingValue.StringValue", RpcLengthLimits.PlayerSettingValue_StringValue)
end

Auto.WritePlayerSingleHouseConfiguration = function(writer, val)
	Base.WriteComplex(writer, val.Camera, Auto.WritePlayerHouseCameraConfiguration, "Camera", false)
end

Auto.WritePlayerTierInfo = function(writer, val)
	Base.WriteDict(writer, val.Tiers, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteTierDetail, "TierDetail", false), nil, "Tiers", false, 0)
	Base.WritePrimitive(writer, val.SeasonId, writer.WriteUInt32, 0)
end

Auto.WritePlayerTradeInfo = function(writer, val)
	Base.WriteList(writer, val.ActiveOrders, Base.WriteComplexWrap(Auto.WriteTradeOrderRef, "TradeOrderRef", false), nil, "ActiveOrders", false, 0, nil)
	Base.WritePrimitive(writer, val.TradeBanExpireTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastListTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastCancelTime, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.BoxCompositeProgressDict, writer.WriteUInt32, writer.WriteUInt32, 0, "BoxCompositeProgressDict", false, 0)
	Base.WriteList(writer, val.FavoriteTradeItemIds, writer.WriteUInt32, 0, "FavoriteTradeItemIds", false, 0, nil)
end

Auto.WritePlayerTuiteClientInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.TuiteList, Base.WriteStructWrap(Auto.WriteClientTuiteInfo, "TuiteList"), nil, "TuiteList", false, 0, nil)
end

Auto.WritePlayerVehicleClientDetail = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Parts, Base.WriteStructWrap(Auto.WriteVehicleClientPart, "Parts"), nil, "Parts", true, 0, nil)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsPersistent, writer.WriteBoolean, false)
end

Auto.WritePlayerVehicleDetail = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.Parts, Base.WriteComplexWrap(Auto.WritePlayerVehiclePartInfo, "PlayerVehiclePartInfo", false), nil, "Parts", false, RpcLengthLimits.PlayerVehicleDetail_Parts, nil)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
end

Auto.WritePlayerVehicleDriveStateInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.EnterOrLeave, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.VehicleEntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IfForce, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OpenDoorTypeId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OpenDoorActionSpeed, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OpenDoorActionClipLength, writer.WriteInt32, 0)
end

Auto.WritePlayerVehicleInfo = function(writer, val)
	Base.WriteList(writer, val.UnlockedVehicles, Base.WriteComplexWrap(Auto.WritePlayerVehicleDetail, "PlayerVehicleDetail", false), nil, "UnlockedVehicles", false, 0, nil)
	Base.WritePrimitive(writer, val.RequisitionVehicleCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ParkingVehicleId, writer.WriteUInt32, 0)
end

Auto.WritePlayerVehiclePartInfo = function(writer, val)
	Base.WritePrimitive(writer, val.VehiclePartId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehiclePartTag, writer.WriteUInt32, 0)
end

Auto.WritePlayerWeaponSkinInfo = function(writer, val)
	Base.WriteDict(writer, val.SpiritWeaponSkinDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritWeaponSkinInfo, "SpiritWeaponSkinInfo", false), nil, "SpiritWeaponSkinDict", false, 0)
	Base.WriteDict(writer, val.OwnedSkinIds, writer.WriteUInt32, writer.WriteUInt32, 0, "OwnedSkinIds", false, 0)
end

Auto.WritePlotMinMaxRange = function(writer, val)
	Base.WritePrimitive(writer, val.min, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.max, writer.WriteSingle, 0)
end

Auto.WritePointInteractInfo = function(writer, val)
	Base.WritePrimitive(writer, val.NodeId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Sprite, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LabelId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UseIndicate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DoNotFocusCamera, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.PlayerAction, Auto.WritePointInteractPlayerAction, "PlayerAction")
end

Auto.WritePointInteractPlayerAction = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CommonInteractType, 228, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.InteractPosType, 229, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.InteractPos, Auto.WriteUXVector3, "InteractPos")
	Base.WriteStruct(writer, val.InteractPosForward, Auto.WriteUXVector3, "InteractPosForward")
	Base.WritePrimitive(writer, val.InteractRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.InteractLoopTime, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.InteractIkPos, Auto.WriteUXVector3, "InteractIkPos")
	Base.WriteStruct(writer, val.InteractIkPosForward, Auto.WriteUXVector3, "InteractIkPosForward")
	Base.WritePrimitive(writer, val.ChairType, writer.WriteInt32, 0)
end

Auto.WritePointTransfer = function(writer, val)
	Base.WritePrimitive(writer, val.From, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.To, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Amount, writer.WriteInt32, 0)
end

Auto.WritePointTransferInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.PlayerNames, Base.WriteStringWrap(false, "PlayerNames", 0), nil, "PlayerNames", false, 0, nil)
	Base.WriteList7Bit(writer, val.Points, writer.WriteInt32, 0, "Points", false, 0, nil)
	Base.WriteList7Bit(writer, val.PointTransfers, Base.WriteStructWrap(Auto.WritePointTransfer, "PointTransfers"), nil, "PointTransfers", false, 0, nil)
end

Auto.WritePokemonEnemy = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Body, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Camp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weapon, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LimboChaId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AcquireTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsLocked, writer.WriteBoolean, false)
end

Auto.WritePoliceCaseInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.Fines, writer.WriteUInt32, 0, "Fines", false, 0, nil)
	Base.WritePrimitive(writer, val.Sentence, writer.WriteInt32, 0)
	Base.WriteList(writer, val.Drops, writer.WriteUInt32, 0, "Drops", false, 0, nil)
	Base.WritePrimitive(writer, val.RewardTaken, writer.WriteBoolean, false)
	Base.WriteList(writer, val.BonusDrops, writer.WriteUInt32, 0, "BonusDrops", false, 0, nil)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsFakePerson, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.InterrogationInfo, Auto.WritePoliceCaseInterrogationInfo, "InterrogationInfo", false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.NpcImprisonStatus, 230, 0), writer.WriteByte, 0)
	Base.WriteList(writer, val.FinedCrimes, writer.WriteUInt32, 0, "FinedCrimes", false, 0, nil)
	Base.WriteList(writer, val.NoCheckCrimeList, writer.WriteUInt32, 0, "NoCheckCrimeList", false, 0, nil)
	Base.WriteList(writer, val.NoIssuedBonusDrops, writer.WriteUInt32, 0, "NoIssuedBonusDrops", false, 0, nil)
	Base.WritePrimitive(writer, val.HasUnlockClue, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SourceType, 231, 0), writer.WriteByte, 0)
	Base.WriteList(writer, val.CrimeDefaultItems, writer.WriteUInt32, 0, "CrimeDefaultItems", false, 0, nil)
end

Auto.WritePoliceCaseInterrogationInfo = function(writer, val)
	Base.WritePrimitive(writer, val.State, writer.WriteByte, 0)
	Base.WriteComplex(writer, val.NpcInfo, Auto.WritePoliceCaseNpcInterrogationInfo, "NpcInfo", false)
end

Auto.WritePoliceCaseInterrogationRPSCardsInfo = function(writer, val)
	Base.WriteList(writer, val.Cards, Base.WriteStructWrap(Auto.WritePoliceRPSCardInfo, "Cards"), nil, "Cards", false, 0, nil)
end

Auto.WritePoliceCaseNpcInterrogationInfo = function(writer, val)
	Base.WriteComplex(writer, val.RPSInfo, Auto.WritePoliceCaseNpcInterrogationRPS, "RPSInfo", true)
end

Auto.WritePoliceCaseNpcInterrogationRPS = function(writer, val)
	Base.WriteComplex(writer, val.Cards, Auto.WritePoliceCaseInterrogationRPSCardsInfo, "Cards", false)
end

Auto.WritePoliceChargingSkillInfo = function(writer, val)
	Base.WritePrimitive(writer, val.ChargingSkillId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

Auto.WritePoliceDispatchExtraInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PrisonerId, writer.WriteUInt64, 0)
end

Auto.WritePoliceDispatchInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextAvailableTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsTemp, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TempEventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TodayArrestSupportTimes, writer.WriteUInt32, 0)
end

Auto.WritePoliceDutyBasicInfo = function(writer, val)
	Base.WritePrimitive(writer, val.DailyViolationCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeaveDueTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastViolationUpdateTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.ServiceData, Auto.WritePoliceServiceData, "ServiceData", false)
	Base.WriteComplex(writer, val.WeeklyServiceData, Auto.WritePoliceServiceData, "WeeklyServiceData", false)
	Base.WriteDict(writer, val.ViolationCdInfos, writer.WriteUInt32, writer.WriteUInt32, 0, "ViolationCdInfos", false, 0)
end

Auto.WritePoliceFakeClueAgentInfo = function(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRead, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ProvideClueTime, writer.WriteUInt32, 0)
end

Auto.WritePoliceFakeFileInfo = function(writer, val)
	Base.WriteDict(writer, val.UnlockFileInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSinglePoliceFakeFileInfo, "SinglePoliceFakeFileInfo", false), nil, "UnlockFileInfoDict", false, 0)
	Base.WriteList(writer, val.HistoryClueAgentInfoList, Base.WriteComplexWrap(Auto.WritePoliceFakeClueAgentInfo, "PoliceFakeClueAgentInfo", false), nil, "HistoryClueAgentInfoList", false, 0, nil)
end

Auto.WritePoliceRPSBattleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Round, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.Player, Auto.WritePoliceRPSUnitBattleInfo, "Player", false)
	Base.WriteComplex(writer, val.Npc, Auto.WritePoliceRPSUnitBattleInfo, "Npc", false)
end

Auto.WritePoliceRPSCardExpInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CardType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
end

Auto.WritePoliceRPSCardInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CardType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.StarLevel, writer.WriteByte, 0)
end

Auto.WritePoliceRPSUnitBattleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.HP, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Cards, Base.WriteStructWrap(Auto.WritePoliceRPSCardInfo, "Cards"), nil, "Cards", false, 0, nil)
end

Auto.WritePoliceServiceData = function(writer, val)
	Base.WritePrimitive(writer, val.DispatchTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PatrolTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ArrestTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FineCount, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.TotalDrops, writer.WriteUInt32, 0, "TotalDrops", false, 0, nil)
	Base.WritePrimitive(writer, val.LastUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CarFineCount, writer.WriteUInt32, 0)
end

Auto.WritePoliceVehicleSpawnClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
end

Auto.WritePoliceVehicleSpawnConfigInfo = function(writer, val)
	Base.WritePrimitive(writer, val.ChaseRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ChaseDirectlyRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ApprehendRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NavConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ChaseDirectlyConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PatrolSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ChaseSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ChaseDirectlySpeed, writer.WriteSingle, 0)
end

Auto.WritePoliceViolationInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeaveDueTime, writer.WriteUInt32, 0)
end

Auto.WritePopularityData = function(writer, val)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Value, writer.WriteInt32, 0)
end

Auto.WritePopularityDayRewardInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.RewardList, Base.WriteComplexWrap(Auto.WritePopularityRewardInfo, "PopularityRewardInfo", false), nil, "RewardList", false, 0, nil)
end

Auto.WritePopularityDropData = function(writer, val)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DropId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Popularity, writer.WriteInt32, 0)
end

Auto.WritePopularityHotGainEventInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.TaskCompleteCountDict, writer.WriteUInt32, writer.WriteInt32, 0, "TaskCompleteCountDict", false, 0)
end

Auto.WritePopularityRewardInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FanCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CoinCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsReward, writer.WriteBoolean, false)
end

Auto.WritePopularityWalletRewardData = function(writer, val)
	Base.WritePrimitive(writer, val.Date, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Reward, writer.WriteUInt32, 0)
end

Auto.WritePosServerEffectData = function(writer, val)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WriteStruct(writer, val.Scale, Auto.WriteUXVector3, "Scale")
	Base.WritePrimitive(writer, val.EffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LogicEndTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ClientDestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Duration, writer.WriteSingle, 0)
end

Auto.WritePossiblePlayerData = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.Name, false, "PossiblePlayerData.Name", 0)
	writer.WriteString(writer, val.RaidName, true, "PossiblePlayerData.RaidName", 0)
end

Auto.WritePostPlayerCommentClientInfo = function(writer, val)
	writer.WriteString(writer, val.Comment, false, "PostPlayerCommentClientInfo.Comment", 0)
	Base.WritePrimitive(writer, val.CommentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsFinish, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CommentTime, writer.WriteUInt32, 0)
end

Auto.WritePostSimpleClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PostType, 232, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PostConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Date, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.ImageUrl, true, "PostSimpleClientInfo.ImageUrl", 0)
	Base.WritePrimitive(writer, val.Approved, writer.WriteBoolean, false)
	writer.WriteString(writer, val.Title, true, "PostSimpleClientInfo.Title", 0)
	Base.WritePrimitive(writer, val.Likes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Liked, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.LikeNpcs, writer.WriteUInt32, 0, "LikeNpcs", true, 0, nil)
	Base.WriteList7Bit(writer, val.Comments, writer.WriteUInt32, 0, "Comments", true, 0, nil)
	Base.WriteList7Bit(writer, val.PlayerComments, Base.WriteComplexWrap(Auto.WritePostPlayerCommentClientInfo, "PostPlayerCommentClientInfo", true), nil, "PlayerComments", true, 0, nil)
	Base.WritePrimitive(writer, val.IsRead, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HasNewLike, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AcquireCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActivityCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsStory, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPinStory, writer.WriteBoolean, false)
end

Auto.WritePreSwitchSpiritData = function(writer, val)
	Base.WritePrimitive(writer, val.SwitchSpiritConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NewSpiritConfigId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

Auto.WritePreTeleportOption = function(writer, val)
	Base.WritePrimitive(writer, val.configId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.teleportId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ForceClear, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TimeLineDration, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.position, Auto.WriteUXVector3, "position")
	Base.WritePrimitive(writer, val.facing, writer.WriteSingle, 0)
	writer.WriteString(writer, val.beforeResName, false, "PreTeleportOption.beforeResName", RpcLengthLimits.PreTeleportOption_beforeResName)
	Base.WritePrimitive(writer, val.customBeforeTrans, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.beforePosition, Auto.WriteUXVector3, "beforePosition")
	Base.WriteStruct(writer, val.beforeRot, Auto.WriteUXVector3, "beforeRot")
	writer.WriteString(writer, val.loadingResName, false, "PreTeleportOption.loadingResName", RpcLengthLimits.PreTeleportOption_loadingResName)
	writer.WriteString(writer, val.afterResName, false, "PreTeleportOption.afterResName", RpcLengthLimits.PreTeleportOption_afterResName)
	Base.WritePrimitive(writer, val.customAfterTrans, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.afterPosition, Auto.WriteUXVector3, "afterPosition")
	Base.WriteStruct(writer, val.afterRot, Auto.WriteUXVector3, "afterRot")
	writer.WriteString(writer, val.extParams, false, "PreTeleportOption.extParams", RpcLengthLimits.PreTeleportOption_extParams)
end

Auto.WritePrepareRoomClient = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeaderPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PSNOnly, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.Members, Base.WriteComplexWrap(Auto.WriteMatchRoomMemberInfo, "MatchRoomMemberInfo", false), nil, "Members", false, 0, nil)
	Base.WriteList7Bit(writer, val.AIAgentMembers, Base.WriteComplexWrap(Auto.WriteMatchRoomAIAgentInfo, "MatchRoomAIAgentInfo", false), nil, "AIAgentMembers", false, 0, nil)
	Base.WriteList7Bit(writer, val.StageConfirmMembers, writer.WriteUInt64, 0, "StageConfirmMembers", false, 0, nil)
	Base.WriteDict7Bit(writer, val.PrepareInfos, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteMatchPrepareInfo, "MatchPrepareInfo", false), nil, "PrepareInfos", false, 0)
	Base.WriteDict7Bit(writer, val.PlayerSwapInfos, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteMatchPrepareRoomPlayerSwapInfo, "MatchPrepareRoomPlayerSwapInfo", false), nil, "PlayerSwapInfos", false, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 205, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.StageId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StageStartTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.Setting, Auto.WritePrepareRoomSetting, "Setting", false)
end

Auto.WritePrepareRoomSetting = function(writer, val)
	Base.WritePrimitive(writer, val.AllowNonLeaderInvite, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.UGCRaceSeting, Auto.WriteUGCRaceSetting, "UGCRaceSeting", true)
end

Auto.WriteProfileWebGotProgressList = function(writer, val)
	Base.WriteList(writer, val.GotProgressRewardList, writer.WriteUInt32, 0, "GotProgressRewardList", false, 0, nil)
end

Auto.WritePublicEventInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
end

Auto.WriteQueryComponentInfo = function(writer, val)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	writer.WriteString(writer, val.Name, false, "QueryComponentInfo.Name", 0)
	Base.WritePrimitive(writer, val.Script, writer.WriteBoolean, false)
end

Auto.WriteQueryFieldInfo = function(writer, val)
	writer.WriteString(writer, val.Name, true, "QueryFieldInfo.Name", 0)
	writer.WriteString(writer, val.Value, true, "QueryFieldInfo.Value", 0)
	writer.WriteString(writer, val.FieldType, true, "QueryFieldInfo.FieldType", 0)
	writer.WriteString(writer, val.SelfType, true, "QueryFieldInfo.SelfType", 0)
	writer.WriteString(writer, val.Exception, true, "QueryFieldInfo.Exception", 0)
	Base.WritePrimitive(writer, val.CanWrite, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Leaf, writer.WriteBoolean, false)
end

Auto.WriteQueryGameObjectFilter = function(writer, val)
	Base.WriteList(writer, val.Path, writer.WriteInt32, 0, "Path", true, 0, nil)
	writer.WriteString(writer, val.Name, true, "QueryGameObjectFilter.Name", 0)
end

Auto.WriteRPSInterrogationSelectResult = function(writer, val)
	Base.WriteStruct(writer, val.PlayerCard, Auto.WritePoliceRPSCardInfo, "PlayerCard")
	Base.WriteStruct(writer, val.NpcCard, Auto.WritePoliceRPSCardInfo, "NpcCard")
	Base.WritePrimitive(writer, Base.CheckEnum(val.RoundResult, 233, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.PlayerHP, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NpcHP, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.Settlement, Auto.WriteRPSInterrogationSettlementInfo, "Settlement", true)
	Base.WriteList7Bit(writer, val.RefreshedCards, Base.WriteStructWrap(Auto.WritePoliceRPSCardInfo, "RefreshedCards"), nil, "RefreshedCards", true, 0, nil)
end

Auto.WriteRPSInterrogationSettlementInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CaseId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 47, 0), writer.WriteByte, 0)
end

Auto.WriteRPSInterrogationStartInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CaseId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.BattleInfo, Auto.WritePoliceRPSBattleInfo, "BattleInfo", false)
end

Auto.WriteRaceMatchContext = function(writer, val)
	Base.WritePrimitive(writer, val.MyTeamAvgMMR, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OpponentAvgMMR, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsBotMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TotalPlayers, writer.WriteInt32, 0)
end

Auto.WriteRaceSettleData = function(writer, val)
end

Auto.WriteRaceTierSettleData = function(writer, val)
	Base.WritePrimitive(writer, val.Index, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.ResultData, Auto.WriteRacingResultData, "ResultData", false)
	Base.WritePrimitive(writer, val.TotalCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MultiPlayerId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GMScore, writer.WriteUInt32, 0)
end

Auto.WriteRacingCompetitionGroupInfo = function(writer, val)
	Base.WriteList(writer, val.CompetitionTrackInfos, Base.WriteComplexWrap(Auto.WriteRacingCompetitionInfo, "RacingCompetitionInfo", false), nil, "CompetitionTrackInfos", false, 0, nil)
end

Auto.WriteRacingCompetitionInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TrackId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CostTime, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteUInt16, 0)
	Base.WritePrimitive(writer, val.Star, writer.WriteUInt16, 0)
	Base.WritePrimitive(writer, val.BestRank, writer.WriteUInt16, 0)
	Base.WritePrimitive(writer, val.BestLapTime, writer.WriteUInt64, 0)
end

Auto.WriteRacingParameters = function(writer, val)
	writer.WriteString(writer, val.raceName, false, "RacingParameters.raceName", 0)
	Base.WritePrimitive(writer, val.routeId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.discourageRatio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.discourageCD, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.checkDiscourageLength, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.checkDiscourageWidth, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.checkDiscourageMinDeltaSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.checkDiscourageMaxDeltaSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.swayUnitTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.swayTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

Auto.WriteRacingParticipantInfo = function(writer, val)
	Base.WritePrimitive(writer, val.AiVehicleCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CheckPointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Lap, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RacingTotalTimeMilli, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CurrentVehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

Auto.WriteRacingResultData = function(writer, val)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AIVehicle, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.FinishTime, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TotalTime, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.BestLapTime, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsBest, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Rank, writer.WriteInt32, 0)
end

Auto.WriteRacingZoneInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.AIVehicleInfos, writer.WriteUInt64, writer.WriteUInt32, 0, "AIVehicleInfos", true, 0)
	Base.WriteList7Bit(writer, val.ResultData, Base.WriteComplexWrap(Auto.WriteRacingResultData, "RacingResultData", true), nil, "ResultData", true, 0, nil)
	writer.WriteString(writer, val.ZoneSessionId, false, "RacingZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WriteRadioRandomContent = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ContentType, 234, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ContentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartContentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndContentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MarkType, 235, 1), writer.WriteByte, 1)
end

Auto.WriteRadioSyncInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.EventType, 236, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.RadioIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SongIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SoundId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.CloudSongId, false, "RadioSyncInfo.CloudSongId", RpcLengthLimits.RadioSyncInfo_CloudSongId)
	Base.WritePrimitive(writer, val.Volume, writer.WriteSingle, 0)
	Base.WriteComplex(writer, val.RandomContent, Auto.WriteRadioRandomContent, "RandomContent", true)
end

Auto.WriteRaidBattleData = function(writer, val)
	Base.WritePrimitive(writer, val.EnterRaidTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BattleTime, writer.WriteDouble, 0)
	Base.WriteList7Bit(writer, val.SpiritBattleDatas, Base.WriteComplexWrap(Auto.WriteSpiritBattleData, "SpiritBattleData", false), nil, "SpiritBattleDatas", false, 0, nil)
	Base.WritePrimitive(writer, val.ElementEffectCount, writer.WriteUInt32, 0)
end

Auto.WriteRaidBattleUnitAgent = function(writer, val)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HSummonIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SpoonAgentId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.FashionIdList, writer.WriteUInt32, 0, "FashionIdList", true, 0, nil)
	Base.WritePrimitive(writer, val.ParentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SpoonIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AutoBackIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SourceWeaponId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsBorn, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BattleAiS, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.agentSyncClientInfo, Auto.WriteAgentSyncClientInfo, "agentSyncClientInfo", true)
	Base.WritePrimitive(writer, val.WeaponId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpawnType, 178, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.AnimateCullingMode, 237, 0), writer.WriteByte, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.FacingDirection, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OwnerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ManagedPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NavTags, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.GroundData, Auto.WriteMoveActionGroundData, "GroundData", true)
end

Auto.WriteRaidBattleUnitBase = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.FacingDirection, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OwnerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ManagedPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NavTags, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.GroundData, Auto.WriteMoveActionGroundData, "GroundData", true)
end

Auto.WriteRaidBattleUnitSpirit = function(writer, val)
	Base.WriteComplex(writer, val.SpiritWearFashionsInfo, Auto.WriteOtherPlayerSpiritWearFashionsInfo, "SpiritWearFashionsInfo", true)
	Base.WritePrimitive(writer, val.Begging, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsBot, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.FacingDirection, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OwnerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ManagedPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NavTags, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.GroundData, Auto.WriteMoveActionGroundData, "GroundData", true)
end

Auto.WriteRaidCleaningInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CleaningProcess, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalSecond, writer.WriteUInt32, 0)
end

Auto.WriteRaidGamePlayInfo = function(writer, val)
	Base.WriteDict7Bit(writer, val.RecordValueInfo, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteRaidGamePlayRecordValueInfo, "RaidGamePlayRecordValueInfo", false), nil, "RecordValueInfo", true, 0)
end

Auto.WriteRaidGamePlayRecordValueInfo = function(writer, val)
	Base.WriteDict7Bit(writer, val.DoubleValueDic, writer.WriteUInt32, writer.WriteDouble, 0, "DoubleValueDic", false, 0)
end

Auto.WriteRaidSettleData = function(writer, val)
	Base.WritePrimitive(writer, val.CanNextGame, writer.WriteBoolean, false)
	Base.WriteList(writer, val.AchievedEventIds, writer.WriteUInt32, 0, "AchievedEventIds", false, 0, nil)
	Base.WriteDict(writer, val.WeaponKillCounts, writer.WriteUInt32, writer.WriteUInt32, 0, "WeaponKillCounts", false, 0)
end

Auto.WriteRaidVehicleGpsInfo = function(writer, val)
	Base.WritePrimitive(writer, val.BelongPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetRaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 238, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetInstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.TargetPosition, Auto.WriteUXVector3, "TargetPosition")
end

Auto.WriteRaidVehicleSeatInfo = function(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SeatState, 239, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.DestroyRelated, writer.WriteBoolean, false)
end

Auto.WriteRaidVehicleSyncData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.facingDirection, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
	Base.WriteStruct(writer, val.Velocity, Auto.WriteUXVector3, "Velocity")
	Base.WriteList7Bit(writer, val.Bits, writer.WriteByte, 0, "Bits", false, RpcLengthLimits.RaidVehicleSyncData_Bits, nil)
	Base.WritePrimitive(writer, val.MoveToken, writer.WriteInt32, 0)
end

Auto.WriteRamParameters = function(writer, val)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StraightLineDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UseContinuousRam, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

Auto.WriteRandomEventTaskInfo = function(writer, val)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
end

Auto.WriteRandomEventTaskInfoList = function(writer, val)
	Base.WriteList7Bit(writer, val.Values, Base.WriteStructWrap(Auto.WriteRandomEventTaskInfo, "Values"), nil, "Values", true, 0, nil)
end

Auto.WriteRangeMoveType = function(writer, val)
	Base.WritePrimitive(writer, val.MinDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Method, 115, 0), writer.WriteByte, 0)
end

Auto.WriteRankQueryOptions = function(writer, val)
	Base.WritePrimitive(writer, val.CycleId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Slot, Auto.WriteClientSubRankSlot, "Slot")
	Base.WritePrimitive(writer, val.Start, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Limit, writer.WriteUInt32, 0)
end

Auto.WriteRayCast4DResInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ResultFront, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ResultBack, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ResultLeft, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ResultRight, writer.WriteBoolean, false)
end

Auto.WriteReactTraitFreeConditionData = function(writer, val)
end

Auto.WriteRecommendClubInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MemberCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MaxCount, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Name, false, "RecommendClubInfo.Name", 0)
	Base.WritePrimitive(writer, val.IconCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Applied, writer.WriteBoolean, false)
end

Auto.WriteReconnectCommand = function(writer, val)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

Auto.WriteRefundRecord = function(writer, val)
	writer.WriteString(writer, val.sdkuid, false, "RefundRecord.sdkuid", 0)
	Base.WritePrimitive(writer, val.gold, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.battlePassItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.monthlyPassItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.monthlyPassCount, writer.WriteUInt32, 0)
end

Auto.WriteRelationVO = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Both, writer.WriteBoolean, false)
	writer.WriteString(writer, val.RemarkName, true, "RelationVO.RemarkName", 0)
	Base.WritePrimitive(writer, val.AddFriendTime, writer.WriteUInt32, 0)
end

Auto.WriteRememberPrepareInfo = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
end

Auto.WriteRemoveFishResult = function(writer, val)
	Base.WritePrimitive(writer, val.SlotId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FishUniqueId, writer.WriteUInt32, 0)
end

Auto.WriteReplaceGadgetInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ReplaceType, 240, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ReplaceCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReplateFrameIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReplateTLIndex, writer.WriteInt32, 0)
end

Auto.WriteReportBehaviorSeqCommandEndInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.SmartObjectTemplate, true, "ReportBehaviorSeqCommandEndInfo.SmartObjectTemplate", RpcLengthLimits.ReportBehaviorSeqCommandEndInfo_SmartObjectTemplate)
	Base.WritePrimitive(writer, val.PointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CommandIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 79, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Cmd, Auto.WriteBehaviorSeqCommand, "Cmd")
end

Auto.WriteReportBehaviorSeqStartInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.SmartObjectTemplate, true, "ReportBehaviorSeqStartInfo.SmartObjectTemplate", RpcLengthLimits.ReportBehaviorSeqStartInfo_SmartObjectTemplate)
	Base.WritePrimitive(writer, val.PointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CommandIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 79, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Cmd, Auto.WriteBehaviorSeqCommand, "Cmd")
end

Auto.WriteResetFashionColoringInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.resetColoringTypeList, writer.WriteByte, 0, "resetColoringTypeList", true, 0, nil)
end

Auto.WriteResetFashionColoringSchemeInfo = function(writer, val)
	Base.WritePrimitive(writer, val.FashionId, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.resetFashionColoringSchemeInfoDict, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteResetFashionColoringInfo, "ResetFashionColoringInfo", false), nil, "resetFashionColoringSchemeInfoDict", true, 0)
end

Auto.WriteRestaurantResult = function(writer, val)
	Base.WritePrimitive(writer, val.RestaurantId, writer.WriteUInt32, 0)
end

Auto.WriteRewardCollectionInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CountryId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BlockId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SubQuestId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TotalCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.InvestigatorGalleryId, writer.WriteUInt32, 0)
end

Auto.WriteRewardDetail = function(writer, val)
	Base.WriteDict(writer, val.DropIdCnt, writer.WriteUInt32, writer.WriteUInt32, 0, "DropIdCnt", false, 0)
	Base.WritePrimitive(writer, val.ReasonTextId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FactionMerge, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Money, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Gold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.BindingGold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.FreeGold, writer.WriteDouble, 0)
	Base.WriteList(writer, val.Items, Base.WriteComplexWrap(Auto.WriteItemCountInfo, "ItemCountInfo", false), nil, "Items", false, 0, nil)
	Base.WriteList(writer, val.UrbanAbilityInfo, Base.WriteComplexWrap(Auto.WriteRewardUrbanAbilityInfo, "RewardUrbanAbilityInfo", false), nil, "UrbanAbilityInfo", false, 0, nil)
	Base.WriteList(writer, val.UrbanAbilities, writer.WriteInt32, 0, "UrbanAbilities", false, 0, nil)
	Base.WriteDict(writer, val.AbilityExpInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "AbilityExpInfo", false, 0)
	Base.WriteDict(writer, val.FanInfo, writer.WriteUInt32, writer.WriteInt32, 0, "FanInfo", false, 0)
	Base.WriteDict(writer, val.FactionDispositionInfo, writer.WriteUInt32, writer.WriteInt32, 0, "FactionDispositionInfo", false, 0)
	Base.WriteDict(writer, val.FactionInfluenceInfo, writer.WriteUInt32, writer.WriteInt32, 0, "FactionInfluenceInfo", false, 0)
	Base.WriteDict(writer, val.JobExpInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "JobExpInfo", false, 0)
	Base.WriteDict(writer, val.NpcFavors, writer.WriteUInt32, writer.WriteUInt32, 0, "NpcFavors", true, 0)
	Base.WriteDict(writer, val.OriginalNpcFavors, writer.WriteUInt32, writer.WriteUInt32, 0, "OriginalNpcFavors", true, 0)
	Base.WritePrimitive(writer, val.Popularity, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EyeCoinRewardCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CommonSpiritTalentExp, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.SpiritTalentExpInfo, Auto.WriteSpiritTalentExpInfo, "SpiritTalentExpInfo", true)
	Base.WriteList(writer, val.WeaponList, writer.WriteUInt32, 0, "WeaponList", true, 0, nil)
	Base.WriteList(writer, val.RumorIds, writer.WriteUInt32, 0, "RumorIds", true, 0, nil)
	Base.WriteDict(writer, val.BattlePassExpInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "BattlePassExpInfo", false, 0)
	Base.WriteDict(writer, val.ExtractionShooterInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "ExtractionShooterInfo", false, 0)
	Base.WriteDict(writer, val.SeasonProgressInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "SeasonProgressInfo", false, 0)
	Base.WriteList(writer, val.FishingFishRewards, Base.WriteComplexWrap(Auto.WriteFishingFishRewardInfo, "FishingFishRewardInfo", false), nil, "FishingFishRewards", false, 0, nil)
	Base.WriteList(writer, val.FishingGearRewards, writer.WriteUInt32, 0, "FishingGearRewards", false, 0, nil)
end

Auto.WriteRewardExtraInfo = function(writer, val)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ChallengeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DropPct, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteList(writer, val.AchievementInfo, writer.WriteUInt32, 0, "AchievementInfo", false, 0, nil)
	Base.WriteList(writer, val.BadgeIdList, writer.WriteUInt32, 0, "BadgeIdList", false, 0, nil)
	Base.WriteComplex(writer, val.CollectionInfo, Auto.WriteRewardCollectionInfo, "CollectionInfo", false)
	Base.WriteDict(writer, val.FactionIdChange, writer.WriteUInt32, writer.WriteUInt32, 0, "FactionIdChange", true, 0)
	Base.WritePrimitive(writer, val.InspireHubGameplayId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ForceItemBind, 241, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.FishConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FishWeight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FishLength, writer.WriteSingle, 0)
end

Auto.WriteRewardInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 25, 0), writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RewardTemplate, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.FirstItemInfo, writer.WriteUInt32, 0, "FirstItemInfo", false, 0, nil)
	Base.WriteComplex(writer, val.ExtraInfo, Auto.WriteRewardExtraInfo, "ExtraInfo", true)
	Base.WriteDict(writer, val.Reward, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteRewardDetail, "RewardDetail", false), nil, "Reward", false, 0)
end

Auto.WriteRewardSettleData = function(writer, val)
	Base.WriteComplex(writer, val.rewardInfo, Auto.WriteRewardInfo, "rewardInfo", true)
	Base.WriteComplex(writer, val.keyRewardInfo, Auto.WriteRewardInfo, "keyRewardInfo", true)
	Base.WriteComplex(writer, val.floatingRewardInfo, Auto.WriteRewardInfo, "floatingRewardInfo", true)
end

Auto.WriteRewardUrbanAbilityInfo = function(writer, val)
	Base.WritePrimitive(writer, val.SpiritTemplateId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.OriginalUrbanAbilities, writer.WriteInt32, 0, "OriginalUrbanAbilities", false, 0, nil)
	Base.WriteList(writer, val.UrbanAbilities, writer.WriteInt32, 0, "UrbanAbilities", false, 0, nil)
end

Auto.WriteRingTossParticipantInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

Auto.WriteRingTossThrowResult = function(writer, val)
	Base.WritePrimitive(writer, val.ThrowIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RewardDropId, writer.WriteUInt32, 0)
end

Auto.WriteRingTossZoneInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GameType, 242, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ThrowResults, Base.WriteStructWrap(Auto.WriteRingTossThrowResult, "ThrowResults"), nil, "ThrowResults", false, 0, nil)
	writer.WriteString(writer, val.ZoneSessionId, false, "RingTossZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WriteRiverData = function(writer, val)
	Base.WriteList7Bit(writer, val.River, Base.WriteStructWrap(Auto.WriteRiverTile, "River"), nil, "River", false, 0, nil)
end

Auto.WriteRiverTile = function(writer, val)
	Base.WriteStruct(writer, val.Tile, Auto.WriteTile, "Tile")
	Base.WritePrimitive(writer, val.IsRichi, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsGone, writer.WriteBoolean, false)
end

Auto.WriteRongInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.RongPlayerIndices, writer.WriteInt32, 0, "RongPlayerIndices", false, 0, nil)
	Base.WriteList7Bit(writer, val.RongPlayerNames, Base.WriteStringWrap(false, "RongPlayerNames", 0), nil, "RongPlayerNames", false, 0, nil)
	Base.WriteList7Bit(writer, val.HandData, Base.WriteStructWrap(Auto.WritePlayerHandData, "HandData"), nil, "HandData", false, 0, nil)
	Base.WriteList7Bit(writer, val.AllHandData, Base.WriteStructWrap(Auto.WritePlayerHandData, "AllHandData"), nil, "AllHandData", false, 0, nil)
	Base.WriteStruct(writer, val.WinningTile, Auto.WriteTile, "WinningTile")
	Base.WriteList7Bit(writer, val.DoraIndicators, Base.WriteStructWrap(Auto.WriteTile, "DoraIndicators"), nil, "DoraIndicators", false, 0, nil)
	Base.WriteList7Bit(writer, val.UraDoraIndicators, Base.WriteStructWrap(Auto.WriteTile, "UraDoraIndicators"), nil, "UraDoraIndicators", false, 0, nil)
	Base.WriteList7Bit(writer, val.RongPlayerRichiStatus, writer.WriteBoolean, false, "RongPlayerRichiStatus", false, 0, nil)
	Base.WriteList7Bit(writer, val.RongPointInfos, Base.WriteStructWrap(Auto.WriteNetworkPointInfo, "RongPointInfos"), nil, "RongPointInfos", false, 0, nil)
	Base.WriteList7Bit(writer, val.TotalPoints, writer.WriteInt32, 0, "TotalPoints", false, 0, nil)
end

Auto.WriteRoundDrawInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.RoundDrawType, 219, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.WaitingData, Base.WriteStructWrap(Auto.WriteWaitingData, "WaitingData"), nil, "WaitingData", false, 0, nil)
	Base.WriteList7Bit(writer, val.AllHandData, Base.WriteStructWrap(Auto.WritePlayerHandData, "AllHandData"), nil, "AllHandData", false, 0, nil)
end

Auto.WriteRoundStartInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Field, 243, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Dice, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Extra, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RichiSticks, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OyaPlayerIndex, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Points, writer.WriteInt32, 0, "Points", false, 0, nil)
	Base.WriteList7Bit(writer, val.InitialHandTiles, Base.WriteStructWrap(Auto.WriteTile, "InitialHandTiles"), nil, "InitialHandTiles", false, 0, nil)
	Base.WriteList7Bit(writer, val.AllHandData, Base.WriteStructWrap(Auto.WritePlayerHandData, "AllHandData"), nil, "AllHandData", false, 0, nil)
	Base.WriteStruct(writer, val.MahjongSetData, Auto.WriteMahjongSetData, "MahjongSetData")
end

Auto.WriteS001CommitCrimePayload = function(writer, val)
	Base.WritePrimitive(writer, val.CrimeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VictimId, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.Source, true, "S001CommitCrimePayload.Source", RpcLengthLimits.S001CommitCrimePayload_Source)
end

Auto.WriteS002ArrestVehicleRequestPayload = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
end

Auto.WriteS002EnterExamRequestPayload = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StartInteract, writer.WriteBoolean, false)
end

Auto.WriteS002EscortFromRequestPayload = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
end

Auto.WriteS002EscortRequestPayload = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
end

Auto.WriteS002EscortVehicleParamsPayload = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
end

Auto.WriteS002ExamVehicleNpcRequestPayload = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
end

Auto.WriteS002ExamVehicleRequestPayload = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
end

Auto.WriteS002InteractParamsPayload = function(writer, val)
end

Auto.WriteS002InteractRequestPayload = function(writer, val)
	Base.WritePrimitive(writer, val.InteractionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SectionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsStandUp, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.Params, Auto.WriteS002InteractParamsPayload, "Params", true)
end

Auto.WriteS002IssueTicketParamsPayload = function(writer, val)
	Base.WriteList7Bit(writer, val.FineList, writer.WriteInt32, 0, "FineList", true, RpcLengthLimits.S002IssueTicketParamsPayload_FineList, nil)
end

Auto.WriteS002ReactionResponsePayload = function(writer, val)
	Base.WritePrimitive(writer, val.SectionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReactionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EscortToWardIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EscortToHearCaseId, writer.WriteUInt64, 0)
end

Auto.WriteS002VehicleFineClosePayload = function(writer, val)
	Base.WriteList7Bit(writer, val.FineList, writer.WriteUInt32, 0, "FineList", true, RpcLengthLimits.S002VehicleFineClosePayload_FineList, nil)
end

Auto.WriteS002VehicleFineDropPayload = function(writer, val)
end

Auto.WriteS002VehicleFineEndPayload = function(writer, val)
end

Auto.WriteS002VehicleFineNonePayload = function(writer, val)
end

Auto.WriteS002VehicleFineOpenPayload = function(writer, val)
	Base.WriteList7Bit(writer, val.FineIds, writer.WriteUInt32, 0, "FineIds", true, RpcLengthLimits.S002VehicleFineOpenPayload_FineIds, nil)
	Base.WriteList7Bit(writer, val.FineFlags, writer.WriteBoolean, false, "FineFlags", true, RpcLengthLimits.S002VehicleFineOpenPayload_FineFlags, nil)
end

Auto.WriteS002VehicleFineResultPayload = function(writer, val)
	Base.WritePrimitive(writer, val.Success, writer.WriteBoolean, false)
end

Auto.WriteS002VehicleNpcReactionPayload = function(writer, val)
	Base.WritePrimitive(writer, val.ReactionId, writer.WriteUInt32, 0)
end

Auto.WriteS011EnterVehicleRequestPayload = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.SeatIndices, writer.WriteByte, 0, "SeatIndices", true, RpcLengthLimits.S011EnterVehicleRequestPayload_SeatIndices, nil)
end

Auto.WriteS011VehicleAndSeatPayload = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
end

Auto.WriteS011VehicleRequisitionResult = function(writer, val)
	Base.WritePrimitive(writer, val.Failed, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AnimVariantType, writer.WriteUInt32, 0)
end

Auto.WriteS021AnimalInteractRequestPayload = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SpoonId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SubType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InteractType, writer.WriteUInt32, 0)
end

Auto.WriteS021InteractRequestPayload = function(writer, val)
	Base.WritePrimitive(writer, val.InteractId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsStop, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Favor, writer.WriteInt32, 0)
end

Auto.WriteS021ReactionResponsePayload = function(writer, val)
end

Auto.WriteSceneCreationInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ParentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CreationId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.ParentPosition, Auto.WriteUXVector3, "ParentPosition")
	Base.WritePrimitive(writer, val.Rotate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ClientEnterOrLeave, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SourceSkillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SourceDestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GadgetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GadgetTransformId, writer.WriteInt32, 0)
end

Auto.WriteSceneDeviceCheckIndexCallback = function(writer, val)
	Base.WritePrimitive(writer, val.CheckIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Error, writer.WriteUInt32, 0)
end

Auto.WriteSceneDeviceHangingInfo = function(writer, val)
	Base.WritePrimitive(writer, val.HangingType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
end

Auto.WriteSceneDeviceOccupantInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.FightSpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AttractNpcPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsState, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SourceType, 244, 0), writer.WriteByte, 0)
end

Auto.WriteSceneDevicePersonalValueInfo = function(writer, val)
	Base.WriteDict(writer, val.PersonalValueDic, writer.WriteInt32, Base.WriteStringWrap(false, "PersonalValueDic", 0), nil, "PersonalValueDic", false, 0)
end

Auto.WriteSceneDeviceStateChangeInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StateType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StateCheckIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ToTask, writer.WriteBoolean, false)
end

Auto.WriteSceneDeviceValueChangeInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ValueName, writer.WriteInt32, 0)
	writer.WriteString(writer, val.Value, false, "SceneDeviceValueChangeInfo.Value", RpcLengthLimits.SceneDeviceValueChangeInfo_Value)
	Base.WritePrimitive(writer, val.ValueCheckIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ToTask, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SetOnceOnly, writer.WriteBoolean, false)
end

Auto.WriteSceneFogMap = function(writer, val)
	Base.WriteList(writer, val.FogValue, writer.WriteByte, 0, "FogValue", true, 0, nil)
	Base.WritePrimitive(writer, val.All, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LockCnt, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.XSize, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ZSize, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TileSize, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.XMin, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ZMin, writer.WriteInt32, 0)
end

Auto.WriteSceneItemDropActionInfo = function(writer, val)
	Base.WritePrimitive(writer, val.hosterInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.sceneItemInstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.hosterPosition, Auto.WriteUXVector3, "hosterPosition")
	Base.WritePrimitive(writer, val.isDestroyImmediately, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.yForce, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.zForce, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.gravity, writer.WriteSingle, 0)
end

Auto.WriteSceneRoomChangeData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Enable, writer.WriteBoolean, false)
end

Auto.WriteScientistFactorMachineSyncInfo = function(writer, val)
	Base.WritePrimitive(writer, val.IsActivated, writer.WriteBoolean, false)
	Base.WriteDict7Bit(writer, val.FactorDict, writer.WriteUInt32, writer.WriteUInt32, 0, "FactorDict", false, 0)
	Base.WriteDict7Bit(writer, val.MatchGameBestRecords, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteMatchGameBestRecord, "MatchGameBestRecord", false), nil, "MatchGameBestRecords", false, 0)
end

Auto.WriteScratchLevelOneCellData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Multiple, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BaseScore, writer.WriteUInt32, 0)
end

Auto.WriteScratchLevelOneStartResult = function(writer, val)
	Base.WriteList7Bit(writer, val.CellDataList, Base.WriteComplexWrap(Auto.WriteScratchLevelOneCellData, "ScratchLevelOneCellData", false), nil, "CellDataList", false, 0, nil)
	Base.WritePrimitive(writer, val.TotalReward, writer.WriteUInt32, 0)
end

Auto.WriteScratchLevelThreeStartResult = function(writer, val)
	Base.WriteList7Bit(writer, val.CellDataList, Base.WriteComplexWrap(Auto.WriteScratchLevelOneCellData, "ScratchLevelOneCellData", false), nil, "CellDataList", false, 0, nil)
	Base.WritePrimitive(writer, val.TotalReward, writer.WriteUInt32, 0)
end

Auto.WriteScratchLevelTwoCellData = function(writer, val)
	Base.WriteList7Bit(writer, val.NumberList, writer.WriteInt32, 0, "NumberList", false, 0, nil)
	Base.WritePrimitive(writer, val.Score, writer.WriteUInt32, 0)
end

Auto.WriteScratchLevelTwoStartResult = function(writer, val)
	Base.WriteList7Bit(writer, val.CellDataList, Base.WriteComplexWrap(Auto.WriteScratchLevelTwoCellData, "ScratchLevelTwoCellData", false), nil, "CellDataList", false, 0, nil)
	Base.WritePrimitive(writer, val.TotalReward, writer.WriteUInt32, 0)
end

Auto.WriteScratchParticipantInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

Auto.WriteScratchStartResult = function(writer, val)
	Base.WritePrimitive(writer, val.TotalReward, writer.WriteUInt32, 0)
end

Auto.WriteScratchZoneInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ScratchSubType, 52, 1), writer.WriteByte, 1)
	Base.WriteComplex(writer, val.ScratchStartResult, Auto.WriteScratchStartResult, "ScratchStartResult", true)
	writer.WriteString(writer, val.ZoneSessionId, false, "ScratchZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WriteSeatInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HoldsCount, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Holds, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "Holds"), nil, "Holds", true, 0, nil)
	Base.WriteList7Bit(writer, val.Folds, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "Folds"), nil, "Folds", false, 0, nil)
	Base.WriteList7Bit(writer, val.Sequence, Base.WriteComplexWrap(Auto.WriteMjPCGActionInfo, "MjPCGActionInfo", false), nil, "Sequence", false, 0, nil)
	Base.WritePrimitive(writer, val.ReachFoldCnt, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Que, 31, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.HuanPais, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "HuanPais"), nil, "HuanPais", true, 0, nil)
	Base.WriteList7Bit(writer, val.HuPais, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "HuPais"), nil, "HuPais", false, 0, nil)
end

Auto.WriteSeatInteractCommandData = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Op, 245, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SitIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.PlayerRot, Auto.WriteUXVector3, "PlayerRot")
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteSelectedAnimationCommandData = function(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WriteList7Bit(writer, val.AnimationIds, writer.WriteUInt32, 0, "AnimationIds", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.BaseObject, 246, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BaseVehicle, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Reverse, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SelectAngleType, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.AngleRange, writer.WriteSingle, 0, "AngleRange", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteSerializeMinMaxAABB = function(writer, val)
	Base.WriteStruct(writer, val.Min, Auto.WriteFloat3, "Min")
	Base.WriteStruct(writer, val.Max, Auto.WriteFloat3, "Max")
end

Auto.WriteSerializeQuaternion = function(writer, val)
	Base.WritePrimitive(writer, val.x, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.y, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.z, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.w, writer.WriteSingle, 0)
end

Auto.WriteServerEffectData = function(writer, val)
	Base.WritePrimitive(writer, val.EffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LogicEndTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ClientDestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Duration, writer.WriteSingle, 0)
end

Auto.WriteServerSimpleGridInfo = function(writer, val)
	Base.WritePrimitive(writer, val.MinX, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MinZ, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MaxX, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MaxZ, writer.WriteInt32, 0)
end

Auto.WriteSetEmotionData = function(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Emotion, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteUInt32, 0)
end

Auto.WriteSetMessageCommand = function(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Name, false, "SetMessageCommand.Name", RpcLengthLimits.SetMessageCommand_Name)
	Base.WriteComplex(writer, val.Value, Auto.WriteStoryNetPayload, "Value", false)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

Auto.WriteSetMessageServerCommand = function(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Name, false, "SetMessageServerCommand.Name", 0)
	Base.WriteComplex(writer, val.Value, Auto.WriteStoryNetPayload, "Value", false)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

Auto.WriteSetObservableCommand = function(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Name, false, "SetObservableCommand.Name", RpcLengthLimits.SetObservableCommand_Name)
	Base.WriteComplex(writer, val.Value, Auto.WriteStoryNetPayload, "Value", false)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

Auto.WriteSetObservableServerCommand = function(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Name, false, "SetObservableServerCommand.Name", 0)
	Base.WriteComplex(writer, val.Value, Auto.WriteStoryNetPayload, "Value", false)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

Auto.WriteSevenDaysActivityCommonInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.ProgressList, writer.WriteUInt32, 0, "ProgressList", false, 0, nil)
	Base.WriteList7Bit(writer, val.TabList, Base.WriteComplexWrap(Auto.WriteSevenDaysTabInfo, "SevenDaysTabInfo", false), nil, "TabList", false, 0, nil)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
end

Auto.WriteSevenDaysActivityData = function(writer, val)
	Base.WriteList(writer, val.ProgressAwardGotList, writer.WriteUInt32, 0, "ProgressAwardGotList", false, 0, nil)
	Base.WriteList(writer, val.TaskInfoList, Base.WriteComplexWrap(Auto.WriteSevenDaysTaskInfo, "SevenDaysTaskInfo", false), nil, "TaskInfoList", false, 0, nil)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowRedPoint, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsOutOfDate, writer.WriteBoolean, false)
end

Auto.WriteSevenDaysTabInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TabCfgId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.TaskList, writer.WriteUInt32, 0, "TaskList", false, 0, nil)
end

Auto.WriteSevenDaysTaskInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsAwardGot, writer.WriteBoolean, false)
end

Auto.WriteShelterMoveFinishInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsFailure, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 247, 0), writer.WriteByte, 0)
end

Auto.WriteShelterPosInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 247, 0), writer.WriteByte, 0)
end

Auto.WriteShortChat = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.mark, Auto.WriteShortChatMark, "mark", true)
end

Auto.WriteShortChatMark = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 248, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

Auto.WriteShortPayload = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteInt16, 0)
end

Auto.WriteShowConversationCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.DialogueId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LookTarget, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.DialogueSpeakers, Base.WriteStringWrap(false, "DialogueSpeakers", 0), nil, "DialogueSpeakers", false, 0, nil)
	Base.WriteList7Bit(writer, val.DialogueBindUnits, writer.WriteUInt64, 0, "DialogueBindUnits", false, 0, nil)
	Base.WritePrimitive(writer, val.IsRestart, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ResumeDelay, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsGeneralDialog, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ClearPreDialogueTasks, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.YawAngleLimit, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.PitchAngleLimit, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteShowUIEffectNotifyParam = function(writer, val)
	Base.WritePrimitive(writer, val.OperatorType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.uParam1, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ulParam1, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.bParam1, writer.WriteBoolean, false)
end

Auto.WriteSimpleGameSetting = function(writer, val)
end

Auto.WriteSimpleMailAttchment = function(writer, val)
	Base.WritePrimitive(writer, val.ItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnbindMoney, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.BindGold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.PayGold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.FreeGold, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WeaponId, writer.WriteUInt32, 0)
end

Auto.WriteSimpleMoveActionData = function(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rot, Auto.WriteUXVector3, "Rot")
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
end

Auto.WriteSimpleMoveActionDataWithGround = function(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rot, Auto.WriteUXVector3, "Rot")
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WriteComplex(writer, val.GroundData, Auto.WriteMoveActionGroundData, "GroundData", false)
end

Auto.WriteSimpleUnreadMessage = function(writer, val)
	Base.WritePrimitive(writer, val.PostId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CommentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MessageType, writer.WriteInt32, 0)
end

Auto.WriteSinglePoliceFakeFileInfo = function(writer, val)
	Base.WritePrimitive(writer, val.State, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.InterrogationTime, writer.WriteUInt32, 0)
end

Auto.WriteSkillCreationData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

Auto.WriteSkillDestructibleData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SceneItemCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
end

Auto.WriteSkillDestructibleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CreateSkillInstanceId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CreateIndex, writer.WriteInt32, 0)
end

Auto.WriteSkillExecuteData = function(writer, val)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ParentTriggerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StiffId, writer.WriteUInt32, 0)
end

Auto.WriteSkillExecuteEndData = function(writer, val)
	Base.WritePrimitive(writer, val.ExecutorId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SkillInstanceId, writer.WriteInt32, 0)
end

Auto.WriteSkillHitData = function(writer, val)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TriggerInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Stage, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HitTarget, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AttachedDestructibleId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.ClientHitPosition, Auto.WriteUXVector3, "ClientHitPosition")
	Base.WriteStruct(writer, val.ClientHitPosNormalDir, Auto.WriteUXVector3, "ClientHitPosNormalDir")
	Base.WritePrimitive(writer, Base.CheckEnum(val.SkillHitType, 249, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.HitMaterial, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.HitCenter, Auto.WriteUXVector3, "HitCenter")
	Base.WritePrimitive(writer, val.StiffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StiffTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HurtEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FirmHurt, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ShieldDefendIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ShieldId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsBackHit, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsReflected, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HitDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsBehindBarrier, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.ParryCounterData, Auto.WriteParryCounterData, "ParryCounterData", true)
end

Auto.WriteSkillParam = function(writer, val)
	Base.WritePrimitive(writer, val.entityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.targetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.moveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.instanceId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.select, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.targetDestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.skillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.unitPartIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.rotate, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.unitPosition, Auto.WriteUXVector3, "unitPosition")
	Base.WriteStruct(writer, val.location, Auto.WriteUXVector3, "location")
	Base.WriteStruct(writer, val.faceToPos, Auto.WriteUXVector3, "faceToPos")
	Base.WritePrimitive(writer, val.destructibleTemplateId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.DesignerPosList, Base.WriteStructWrap(Auto.WriteUXVector3, "DesignerPosList"), nil, "DesignerPosList", true, 0, nil)
	Base.WritePrimitive(writer, val.SectionRepeatTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SeqConfigID, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.SelfMobilityPos, Auto.WriteUXVector3, "SelfMobilityPos")
	Base.WriteStruct(writer, val.TarMobilityPos, Auto.WriteUXVector3, "TarMobilityPos")
	Base.WritePrimitive(writer, val.NotInterruptMove, writer.WriteBoolean, false)
end

Auto.WriteSkillShieldData = function(writer, val)
	Base.WritePrimitive(writer, val.SkillInstanceId, writer.WriteInt32, 0)
end

Auto.WriteSkillStateData = function(writer, val)
	Base.WritePrimitive(writer, val.SkillInstanceId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.StateIds, writer.WriteUInt32, 0, "StateIds", false, RpcLengthLimits.SkillStateData_StateIds, nil)
end

Auto.WriteSkillTimeCurveData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
end

Auto.WriteSkillUseData = function(writer, val)
	Base.WritePrimitive(writer, val.Releaser, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Location, Auto.WriteUXVector3, "Location")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UnitPartIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TargetDestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AttachDestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SkillInstanceId, writer.WriteInt32, 0)
end

Auto.WriteSoundEffectConfig = function(writer, val)
	Base.WritePrimitive(writer, val.tempo, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.pitch, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.power, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.richness, writer.WriteSingle, 0)
	writer.WriteString(writer, val.template, true, "SoundEffectConfig.template", RpcLengthLimits.SoundEffectConfig_template)
end

Auto.WriteSpawnAreaSelector = function(writer, val)
	Base.WriteComplex(writer, val.SpawnArea, Auto.WriteMassTrafficSpawnArea, "SpawnArea", false)
	Base.WritePrimitive(writer, val.Selected, writer.WriteBoolean, false)
end

Auto.WriteSpawnLaneSelector = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpawnLaneType, 250, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.FirstArea, Auto.WriteAreaColliderParams, "FirstArea")
	Base.WriteStruct(writer, val.SecondArea, Auto.WriteAreaColliderParams, "SecondArea")
end

Auto.WriteSpinOutParameters = function(writer, val)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

Auto.WriteSpiritAbilityInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NewLevel, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ConfirmedLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
end

Auto.WriteSpiritAddWeaponAction = function(writer, val)
	Base.WritePrimitive(writer, val.SpiritTid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SlotIndex, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.Weapon, Auto.WriteWeaponDetail, "Weapon", false)
end

Auto.WriteSpiritBartenderInfo = function(writer, val)
	Base.WriteDict(writer, val.BartenderId2ElementInfosDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBartenderElementInfos, "BartenderElementInfos", false), nil, "BartenderId2ElementInfosDict", false, 0)
	Base.WriteDict(writer, val.BartenderId2GameInfosDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBartenderGameInfos, "BartenderGameInfos", false), nil, "BartenderId2GameInfosDict", false, 0)
end

Auto.WriteSpiritBattleData = function(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StoneLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalDamage, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HighestDamage, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalHeal, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalDamaged, writer.WriteUInt32, 0)
end

Auto.WriteSpiritBattleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.IsUniqueSkillLocked, writer.WriteBoolean, false)
	Base.WriteDict(writer, val.ConsumableCounters, writer.WriteInt32, writer.WriteSingle, 0, "ConsumableCounters", false, 0)
end

Auto.WriteSpiritDrawViewData = function(writer, val)
	Base.WriteComplex(writer, val.SpiritInfo, Auto.WriteSpiritInfo, "SpiritInfo", false)
end

Auto.WriteSpiritFashionsInfo = function(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.FashionCustomSuitSchemeInfos, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteFashionCustomSuitSchemeInfo, "FashionCustomSuitSchemeInfo", false), nil, "FashionCustomSuitSchemeInfos", false, 0)
	Base.WriteDict(writer, val.FashionFunctionSuitSchemeInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFashionFunctionSuitSchemeInfo, "FashionFunctionSuitSchemeInfo", false), nil, "FashionFunctionSuitSchemeInfoDict", false, 0)
	Base.WriteComplex(writer, val.SpiritWearFashionsInfo, Auto.WriteSpiritWearFashionsInfo, "SpiritWearFashionsInfo", false)
	Base.WriteComplex(writer, val.SpiritPrevWearFashionsInfo, Auto.WriteSpiritWearFashionsInfo, "SpiritPrevWearFashionsInfo", true)
	Base.WriteList(writer, val.FirstGainSuitIdList, writer.WriteUInt32, 0, "FirstGainSuitIdList", true, 0, nil)
	Base.WritePrimitive(writer, val.ActiveClientTryWearSource, writer.WriteInt16, 0)
	Base.WritePrimitive(writer, val.UnlockSuitSlotCount, writer.WriteByte, 0)
	Base.WriteDict(writer, val.MainFashionId2VariantFashionIdDict, writer.WriteUInt32, writer.WriteUInt32, 0, "MainFashionId2VariantFashionIdDict", false, 0)
end

Auto.WriteSpiritFightStyleInfo = function(writer, val)
	Base.WriteDict(writer, val.FightStyleInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "FightStyleInfo", false, 0)
end

Auto.WriteSpiritFightTypeChangeAction = function(writer, val)
	Base.WritePrimitive(writer, val.spiritId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.fullInfo, Auto.WriteSpiritFightStyleInfo, "fullInfo", true)
	Base.WriteDict7Bit(writer, val.addOrUpdateInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "addOrUpdateInfo", true, 0)
end

Auto.WriteSpiritGroupChatInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
end

Auto.WriteSpiritHackerJobInfo = function(writer, val)
	writer.WriteString(writer, val.HackerName, true, "SpiritHackerJobInfo.HackerName", 0)
	Base.WriteDict(writer, val.PostInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteHackerPostInfo, "HackerPostInfo", false), nil, "PostInfos", false, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteUInt32, 0)
end

Auto.WriteSpiritInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PossessTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HpRate, writer.WriteSingle, 0)
	Base.WriteComplex(writer, val.SpiritUrbanSkill, Auto.WriteSpiritUrbanSkill, "SpiritUrbanSkill", false)
	Base.WriteDict(writer, val.SpiritAbilities, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritAbilityInfo, "SpiritAbilityInfo", false), nil, "SpiritAbilities", false, 0)
	Base.WriteComplex(writer, val.SpiritJobInfo, Auto.WriteSpiritJobInfo, "SpiritJobInfo", false)
	Base.WriteDict(writer, val.PermanentAddAttributes, writer.WriteUInt32, writer.WriteSingle, 0, "PermanentAddAttributes", false, 0)
	Base.WriteComplex(writer, val.InfoBadge, Auto.WritePlayerInfoBadge, "InfoBadge", false)
	Base.WriteComplex(writer, val.MobileSkinInfo, Auto.WriteSpiritMobileSkinInfo, "MobileSkinInfo", false)
	Base.WriteList(writer, val.WeaponSlots, Base.WriteComplexWrap(Auto.WriteWeaponData, "WeaponData", false), nil, "WeaponSlots", false, 0, nil)
	Base.WritePrimitive(writer, val.EverSwitched, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.SpiritBattleInfo, Auto.WriteSpiritBattleInfo, "SpiritBattleInfo", false)
	Base.WriteComplex(writer, val.TalentInfo, Auto.WriteSpiritTalentInfo, "TalentInfo", false)
	Base.WriteComplex(writer, val.SpiritFightStyle, Auto.WriteSpiritFightStyleInfo, "SpiritFightStyle", false)
	Base.WritePrimitive(writer, val.Blocked, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.SummonAgentWheelWeaponInfo, Auto.WriteSpiritSummonAgentWheelWeaponInfo, "SummonAgentWheelWeaponInfo", false)
	Base.WriteList(writer, val.BuffLibraryEntries, Base.WriteComplexWrap(Auto.WritePlayerBuffLibraryEntry, "PlayerBuffLibraryEntry", false), nil, "BuffLibraryEntries", false, 0, nil)
	Base.WritePrimitive(writer, val.LastUsedWeaponInstanceId, writer.WriteUInt64, 0)
end

Auto.WriteSpiritInitData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.WeaponTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WeaponSkinId, writer.WriteUInt32, 0)
end

Auto.WriteSpiritJob = function(writer, val)
	Base.WritePrimitive(writer, val.Job, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.RegisterTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnregisterTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.TalentInfo, Auto.WriteSpiritJobTalentInfo, "TalentInfo", false)
end

Auto.WriteSpiritJobInfo = function(writer, val)
	Base.WritePrimitive(writer, val.CurrentJob, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.AvailableJobs, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritJob, "SpiritJob", false), nil, "AvailableJobs", false, 0)
	Base.WriteDict(writer, val.HistoryJobs, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritJob, "SpiritJob", false), nil, "HistoryJobs", false, 0)
end

Auto.WriteSpiritJobTalentInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TalentPoint, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.UnlockTalentInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritOrJobTalentNodeInfo, "SpiritOrJobTalentNodeInfo", false), nil, "UnlockTalentInfoDict", false, 0)
	Base.WriteDict(writer, val.TalentTreeRecordDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteTalentTreeRecord, "TalentTreeRecord", false), nil, "TalentTreeRecordDict", false, 0)
end

Auto.WriteSpiritMobileSkinInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Wallpaper, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Decoration, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Pendant, writer.WriteUInt32, 0)
end

Auto.WriteSpiritOrJobTalentNodeInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TalentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Layer, writer.WriteUInt32, 0)
end

Auto.WriteSpiritPanelData = function(writer, val)
	Base.WritePrimitive(writer, val.FightSpiritId, writer.WriteUInt32, 0)
	Base.WriteDict7Bit(writer, val.UrbanAttrs, writer.WriteUInt32, writer.WriteSingle, 0, "UrbanAttrs", false, 0)
	Base.WritePrimitive(writer, val.MaxHp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Dam, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DefDeduct, writer.WriteSingle, 0)
	Base.WriteDict7Bit(writer, val.Attrs, writer.WriteUInt32, writer.WriteSingle, 0, "Attrs", false, 0)
	Base.WriteDict7Bit(writer, val.NakedAttrs, writer.WriteUInt32, writer.WriteSingle, 0, "NakedAttrs", false, 0)
	Base.WriteDict7Bit(writer, val.ConsumableAttrs, writer.WriteUInt32, writer.WriteSingle, 0, "ConsumableAttrs", false, 0)
end

Auto.WriteSpiritPoliceJobInfo = function(writer, val)
	Base.WriteDict(writer, val.DispatchInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePoliceDispatchInfo, "PoliceDispatchInfo", false), nil, "DispatchInfos", false, 0)
	Base.WriteList(writer, val.ViolationInfos, Base.WriteComplexWrap(Auto.WritePoliceViolationInfo, "PoliceViolationInfo", false), nil, "ViolationInfos", false, 0, nil)
	Base.WriteList(writer, val.CaseInfos, Base.WriteComplexWrap(Auto.WritePoliceCaseInfo, "PoliceCaseInfo", false), nil, "CaseInfos", false, 0, nil)
	Base.WriteComplex(writer, val.DutyBasicInfo, Auto.WritePoliceDutyBasicInfo, "DutyBasicInfo", false)
	Base.WriteList(writer, val.EscortedNpcs, writer.WriteUInt64, 0, "EscortedNpcs", false, 0, nil)
	Base.WriteComplex(writer, val.PoliceFakeFileInfo, Auto.WritePoliceFakeFileInfo, "PoliceFakeFileInfo", true)
	Base.WriteDict(writer, val.PeriodInvalidVehicleFine2CountDict, writer.WriteUInt32, writer.WriteUInt32, 0, "PeriodInvalidVehicleFine2CountDict", false, 0)
	Base.WritePrimitive(writer, val.NextPeriodUpdateTime, writer.WriteUInt32, 0)
end

Auto.WriteSpiritRemoveWeaponAction = function(writer, val)
	Base.WritePrimitive(writer, val.SpiritTid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.WeaponUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 251, 0), writer.WriteByte, 0)
end

Auto.WriteSpiritReplaceFightStyleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OriginalFightStyleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReplaceFightStyleId, writer.WriteUInt32, 0)
end

Auto.WriteSpiritSummonAgentWheelWeaponInfo = function(writer, val)
	Base.WriteDict(writer, val.WheelWeaponInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSummonAgentWheelWeaponInfo, "SummonAgentWheelWeaponInfo", false), nil, "WheelWeaponInfos", false, 0)
end

Auto.WriteSpiritSwitchWeaponAction = function(writer, val)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.WeaponInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 252, 0), writer.WriteByte, 0)
end

Auto.WriteSpiritTalentExpInfo = function(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TalentExp, writer.WriteUInt32, 0)
end

Auto.WriteSpiritTalentInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TalentPoint, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.UnlockTalentInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritOrJobTalentNodeInfo, "SpiritOrJobTalentNodeInfo", false), nil, "UnlockTalentInfoDict", false, 0)
	Base.WriteDict(writer, val.TalentTreeRecordDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteTalentTreeRecord, "TalentTreeRecord", false), nil, "TalentTreeRecordDict", false, 0)
end

Auto.WriteSpiritUpdateWeaponAction = function(writer, val)
	Base.WritePrimitive(writer, val.SpiritTid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.Weapon, Auto.WriteWeaponDetail, "Weapon", false)
end

Auto.WriteSpiritUrbanSkill = function(writer, val)
	Base.WriteList(writer, val.UrbanAbilities, writer.WriteInt32, 0, "UrbanAbilities", false, 0, nil)
end

Auto.WriteSpiritVirtualFightStyleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FightStyleTypeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FightStyleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
end

Auto.WriteSpiritWeaponDetail = function(writer, val)
	Base.WritePrimitive(writer, val.SpiritTid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CurrentWeaponUid, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.WeaponSlots, Base.WriteComplexWrap(Auto.WriteWeaponDetail, "WeaponDetail", false), nil, "WeaponSlots", false, 0, nil)
	Base.WriteComplex(writer, val.CurrentTempWeapon, Auto.WriteWeaponDetail, "CurrentTempWeapon", true)
	Base.WriteComplex(writer, val.TempWeaponSlots, Auto.WriteWeaponWheelData, "TempWeaponSlots", true)
	Base.WriteDict7Bit(writer, val.VirtualWeaponSlots, writer.WriteInt32, Base.WriteComplexWrap(Auto.WriteWeaponDetail, "WeaponDetail", false), nil, "VirtualWeaponSlots", false, 0)
end

Auto.WriteSpiritWeaponDurabilityChangedAction = function(writer, val)
	Base.WritePrimitive(writer, val.SpiritTid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.WeaponInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Durability, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MagazineAmmo, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CurrentBulletId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteInt32, 0)
end

Auto.WriteSpiritWeaponSkinInfo = function(writer, val)
	Base.WriteDict(writer, val.SkinDict, writer.WriteUInt32, writer.WriteUInt32, 0, "SkinDict", false, 0)
end

Auto.WriteSpiritWeaponSkinSyncData = function(writer, val)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.WeaponId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SkinId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 252, 0), writer.WriteByte, 0)
end

Auto.WriteSpiritWearFashionsInfo = function(writer, val)
	Base.WritePrimitive(writer, val.FunctionSuitId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.WearSourceInfo, Auto.WriteWearSourceInfo, "WearSourceInfo")
	Base.WritePrimitive(writer, val.IsTryWear, writer.WriteBoolean, false)
	Base.WriteList(writer, val.WearFashionInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionInfo, "WearFashionInfo", false), nil, "WearFashionInfoList", false, RpcLengthLimits.BaseWearFashionsInfo_WearFashionInfoList, nil)
	Base.WriteList(writer, val.WearFashionEditInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "WearFashionEditInfoList", true, RpcLengthLimits.BaseWearFashionsInfo_WearFashionEditInfoList, nil)
	Base.WritePrimitive(writer, val.HiddenParts, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EditedHiddenParts, writer.WriteByte, 0)
end

Auto.WriteSpoonActionParam = function(writer, val)
	Base.WriteDict7Bit(writer, val.PortToValue, writer.WriteInt32, Base.WriteStringWrap(false, "PortToValue", RpcLengthLimits.SpoonActionParam_PortToValue_String), nil, "PortToValue", true, RpcLengthLimits.SpoonActionParam_PortToValue)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
end

Auto.WriteSpoonClientActionPlayerExtraInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.PartyTags, writer.WriteByte, 0, "PartyTags", true, 0, nil)
end

Auto.WriteSpoonClientActionTriggerInfo = function(writer, val)
	Base.WritePrimitive(writer, val.NodeTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ContextTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlateInstanceId, writer.WriteUInt64, 0)
	Base.WriteDict7Bit(writer, val.Pid2Index, writer.WriteUInt64, writer.WriteInt32, 0, "Pid2Index", true, 0)
	Base.WriteDict7Bit(writer, val.Pid2ExtraInfo, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteSpoonClientActionPlayerExtraInfo, "SpoonClientActionPlayerExtraInfo", false), nil, "Pid2ExtraInfo", true, 0)
end

Auto.WriteSpoonClientData = function(writer, val)
	Base.WriteDict7Bit(writer, val.Enemies, writer.WriteInt32, writer.WriteUInt64, 0, "Enemies", false, 0)
	Base.WriteDict7Bit(writer, val.Npcs, writer.WriteInt32, writer.WriteUInt64, 0, "Npcs", false, 0)
	Base.WriteList7Bit(writer, val.TriggerInfos, Base.WriteComplexWrap(Auto.WriteSpoonTriggerInfo, "SpoonTriggerInfo", false), nil, "TriggerInfos", false, 0, nil)
	Base.WriteList7Bit(writer, val.SpoonRooms, Base.WriteComplexWrap(Auto.WriteSceneRoomChangeData, "SceneRoomChangeData", false), nil, "SpoonRooms", false, 0, nil)
	Base.WriteDict7Bit(writer, val.InteractiveNpcs, writer.WriteUInt32, writer.WriteBoolean, false, "InteractiveNpcs", false, 0)
end

Auto.WriteSpoonNpcData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.FacingDirection, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EnterBattle, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FashionSuitId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
end

Auto.WriteSpoonOutputLink = function(writer, val)
	writer.WriteString(writer, val.Name, false, "SpoonOutputLink.Name", 0)
	Base.WriteList7Bit(writer, val.NextNodes, writer.WriteInt32, 0, "NextNodes", false, 0, nil)
end

Auto.WriteSpoonPlateClientData = function(writer, val)
	Base.WritePrimitive(writer, val.PlateUId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.TriggerInfos, Base.WriteComplexWrap(Auto.WriteSpoonTriggerInfo, "SpoonTriggerInfo", false), nil, "TriggerInfos", false, 0, nil)
end

Auto.WriteSpoonServerActionParam = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ActionType, 253, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NodeId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.GraphId, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.Param, Auto.WriteSpoonActionParam, "Param", true)
	Base.WritePrimitive(writer, val.GadgetInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
end

Auto.WriteSpoonTaskClientData = function(writer, val)
	Base.WriteList7Bit(writer, val.TriggerInfos, Base.WriteComplexWrap(Auto.WriteSpoonTriggerInfo, "SpoonTriggerInfo", false), nil, "TriggerInfos", false, 0, nil)
	Base.WriteDict7Bit(writer, val.Enemies, writer.WriteInt32, writer.WriteUInt64, 0, "Enemies", false, 0)
	Base.WriteList7Bit(writer, val.SpoonRooms, Base.WriteComplexWrap(Auto.WriteSceneRoomChangeData, "SceneRoomChangeData", false), nil, "SpoonRooms", false, 0, nil)
	Base.WriteList7Bit(writer, val.RemovedNpcList, writer.WriteInt32, 0, "RemovedNpcList", false, 0, nil)
	Base.WriteDict7Bit(writer, val.VehicleIdDict, writer.WriteInt32, writer.WriteInt32, 0, "VehicleIdDict", false, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
end

Auto.WriteSpoonTriggerInfo = function(writer, val)
	Base.WritePrimitive(writer, val.FlowIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NodeId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NeedComplete, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MemoryTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsCondition, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.Ports, Base.WriteComplexWrap(Auto.WriteControlFlowData, "ControlFlowData", true), nil, "Ports", true, 0, nil)
	Base.WriteDict7Bit(writer, val.pid2Index, writer.WriteUInt64, writer.WriteInt32, 0, "pid2Index", true, 0)
	Base.WriteDict7Bit(writer, val.Pid2ExtraInfo, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteSpoonClientActionPlayerExtraInfo, "SpoonClientActionPlayerExtraInfo", false), nil, "Pid2ExtraInfo", true, 0)
end

Auto.WriteSpriteToken = function(writer, val)
	writer.WriteString(writer, val.Token, false, "SpriteToken.Token", 0)
	Base.WritePrimitive(writer, val.ExpireTimeStamp, writer.WriteUInt64, 0)
end

Auto.WriteStartPatrolInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.FileName, false, "StartPatrolInfo.FileName", 0)
	Base.WritePrimitive(writer, val.HashCode, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SeqIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.GroupIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CommandIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Loop, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Return, writer.WriteBoolean, false)
end

Auto.WriteStaticDestructibleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.GroupId, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.Pack, Auto.WritePackedDestructibleInfo, "Pack", true)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NavId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ForceLod0, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Hp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 161, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BreakStage, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.OccupantInfos, Base.WriteStructWrap(Auto.WriteSceneDeviceOccupantInfo, "OccupantInfos"), nil, "OccupantInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.DropWeaponId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.EffectIds, writer.WriteInt32, 0, "EffectIds", true, 0, nil)
	Base.WritePrimitive(writer, val.NoSleep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.SkillInfo, Auto.WriteSkillDestructibleInfo, "SkillInfo", true)
end

Auto.WriteStaticNpcGridSpawnLogDto = function(writer, val)
	Base.WritePrimitive(writer, val.GridX, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.GridZ, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.WasTriggered, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.GridBlockReason, 254, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TriggerGameTime, writer.WriteDouble, 0)
	Base.WriteList7Bit(writer, val.Entries, Base.WriteComplexWrap(Auto.WriteStaticNpcSpawnLogDto, "StaticNpcSpawnLogDto", false), nil, "Entries", false, 0, nil)
end

Auto.WriteStaticNpcSpawnLogDto = function(writer, val)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SourceType, 148, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PrefabCreateType, 255, 0), writer.WriteByte, 0)
	writer.WriteString(writer, val.PrefabSource, false, "StaticNpcSpawnLogDto.PrefabSource", 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, Base.CheckEnum(val.Status, 256, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.BlockReason, 257, 0), writer.WriteByte, 0)
	writer.WriteString(writer, val.BlockDetail, false, "StaticNpcSpawnLogDto.BlockDetail", 0)
	writer.WriteString(writer, val.SpawnPath, false, "StaticNpcSpawnLogDto.SpawnPath", 0)
	Base.WritePrimitive(writer, val.LiveNpcInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CdRemainingGameHours, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CdRemainingRealSecs, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ProbabilityValue, writer.WriteSingle, 0)
end

Auto.WriteStimEventParameter = function(writer, val)
	Base.WriteStruct(writer, val.Source, Auto.WriteClientActionTarget, "Source")
	Base.WriteStruct(writer, val.Source2, Auto.WriteClientActionTarget, "Source2")
end

Auto.WriteStopParameters = function(writer, val)
	Base.WritePrimitive(writer, val.StopRatio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.useThrottleStop, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.StopHandBrake, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.StopDelayTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

Auto.WriteStoryClientCommand = function(writer, val)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

Auto.WriteStoryNetPayload = function(writer, val)
end

Auto.WriteStoryServerCommand = function(writer, val)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

Auto.WriteStringPayload = function(writer, val)
	writer.WriteString(writer, val.V, false, "StringPayload.V", RpcLengthLimits.StringPayload_V)
end

Auto.WriteStsAssumeRole = function(writer, val)
	writer.WriteString(writer, val.AccessKeyId, false, "StsAssumeRole.AccessKeyId", 0)
	writer.WriteString(writer, val.AccessKeySecret, false, "StsAssumeRole.AccessKeySecret", 0)
	writer.WriteString(writer, val.SecurityToken, false, "StsAssumeRole.SecurityToken", 0)
	Base.WritePrimitive(writer, val.ExpireTimeStamp, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Region, false, "StsAssumeRole.Region", 0)
	writer.WriteString(writer, val.Endpoint, false, "StsAssumeRole.Endpoint", 0)
	writer.WriteString(writer, val.Prefix, false, "StsAssumeRole.Prefix", 0)
	writer.WriteString(writer, val.Buket, false, "StsAssumeRole.Buket", 0)
end

Auto.WriteSubmitItemData = function(writer, val)
	Base.WritePrimitive(writer, val.SubmittedCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastSubmitTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextResetTime, writer.WriteUInt32, 0)
end

Auto.WriteSubmitItemES = function(writer, val)
	Base.WritePrimitive(writer, val.bagId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.cellX, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.cellY, writer.WriteUInt32, 0)
end

Auto.WriteSubmitItemIdentity = function(writer, val)
	Base.WriteComplex(writer, val.Uid, Auto.WriteSubmitItemUlong, "Uid", true)
	Base.WriteComplex(writer, val.EsId, Auto.WriteSubmitItemES, "EsId", true)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

Auto.WriteSubmitItemInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.Items, Base.WriteComplexWrap(Auto.WriteSubmitSingleItemInfo, "SubmitSingleItemInfo", true), nil, "Items", true, RpcLengthLimits.SubmitItemInfo_Items, nil)
end

Auto.WriteSubmitItemKey = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ItemType, 258, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ConfigID, writer.WriteUInt32, 0)
end

Auto.WriteSubmitItemUlong = function(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt64, 0)
end

Auto.WriteSubmitSingleItemInfo = function(writer, val)
	Base.WriteStruct(writer, val.Key, Auto.WriteSubmitItemKey, "Key")
	Base.WriteList7Bit(writer, val.Identities, Base.WriteStructWrap(Auto.WriteSubmitItemIdentity, "Identities"), nil, "Identities", true, RpcLengthLimits.SubmitSingleItemInfo_Identities, nil)
end

Auto.WriteSummonAgentWheelWeaponInfo = function(writer, val)
	Base.WriteList(writer, val.Weapons, writer.WriteUInt32, 0, "Weapons", false, 0, nil)
end

Auto.WriteSummonVehicleResult = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleEntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskToken, writer.WriteUInt64, 0)
end

Auto.WriteSurroundNpcSpawnInfo = function(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
end

Auto.WriteSyncAgentProperty = function(writer, val)
	Base.WriteComplex(writer, val.V, Auto.WriteAgentPropertyData, "V", false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 259, 0), writer.WriteByte, 0)
end

Auto.WriteSyncCinemaQueryInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.HaveSeenList, writer.WriteUInt32, 0, "HaveSeenList", false, 0, nil)
	Base.WriteComplex(writer, val.TicketInfo, Auto.WriteCinemaTicketInfo, "TicketInfo", true)
	Base.WritePrimitive(writer, val.InviteNpcId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.UnlockMovies, writer.WriteUInt32, 0, "UnlockMovies", false, 0, nil)
end

Auto.WriteSyncClientNodeCommand = function(writer, val)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

Auto.WriteSyncMoveActionData = function(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MoveTime, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ClientLocalTime, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.ActionData, writer.WriteByte, 0, "ActionData", true, 0, nil)
	Base.WriteList7Bit(writer, val.EffectData, writer.WriteByte, 0, "EffectData", true, 0, nil)
end

Auto.WriteSyncMoveActionDataWithGround = function(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MoveTime, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ClientLocalTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.GroundData, Auto.WriteMoveActionGroundData, "GroundData", false)
	Base.WriteList7Bit(writer, val.ActionData, writer.WriteByte, 0, "ActionData", true, 0, nil)
	Base.WriteList7Bit(writer, val.EffectData, writer.WriteByte, 0, "EffectData", true, 0, nil)
end

Auto.WriteSyncMultiCinemaQueryInfo = function(writer, val)
	Base.WritePrimitive(writer, val.LastestMovieId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastestMovieStartTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.TicketInfo, Auto.WriteCinemaMultiTicketInfo, "TicketInfo", true)
end

Auto.WriteSyncWorldBattlePlayersExtraInfo = function(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteList7Bit(writer, val.Positions, Base.WriteStructWrap(Auto.WriteUXVector3, "Positions"), nil, "Positions", false, RpcLengthLimits.SyncWorldBattlePlayersExtraInfo_Positions, nil)
end

Auto.WriteTalentTreeRecord = function(writer, val)
	Base.WritePrimitive(writer, val.SpentTalentPoint, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActivatedNodeCount, writer.WriteUInt32, 0)
end

Auto.WriteTamagotchiInfo = function(writer, val)
	Base.WriteComplex(writer, val.PetState, Auto.WriteTamagotchiPetState, "PetState", false)
	Base.WriteDict(writer, val.SignInFirstTimes, writer.WriteUInt32, writer.WriteUInt32, 0, "SignInFirstTimes", false, 0)
	Base.WriteDict(writer, val.PetFirstGetTimes, writer.WriteUInt32, writer.WriteUInt32, 0, "PetFirstGetTimes", false, 0)
	Base.WriteDict(writer, val.ItemCounts, writer.WriteUInt32, writer.WriteUInt32, 0, "ItemCounts", false, 0)
	Base.WriteDict(writer, val.Favorabilities, writer.WriteUInt64, writer.WriteUInt32, 0, "Favorabilities", false, 0)
end

Auto.WriteTamagotchiPetState = function(writer, val)
	Base.WritePrimitive(writer, val.PetId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoodValue, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HungerValue, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsDead, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsSick, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsSleeping, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsOutside, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UpdateTime, writer.WriteUInt32, 0)
end

Auto.WriteTargetIsRunningConditionData = function(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
end

Auto.WriteTargetRayCastListResItem = function(writer, val)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Res, writer.WriteBoolean, false)
end

Auto.WriteTargetRayCastResInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.Results, Base.WriteStructWrap(Auto.WriteTargetRayCastListResItem, "Results"), nil, "Results", false, RpcLengthLimits.TargetRayCastResInfo_Results, nil)
	Base.WritePrimitive(writer, val.Source, writer.WriteInt32, 0)
end

Auto.WriteTaskDestructibleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PlateInlineId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.GroupId, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.TriggerTag, true, "TaskDestructibleInfo.TriggerTag", 0)
	Base.WritePrimitive(writer, val.NpcPhoneId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExternalSystemLinkId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AdherePlatformInfo, Auto.WriteAdhereMovingPlatformInfo, "AdherePlatformInfo", true)
	Base.WriteDict7Bit(writer, val.ExposeParams, writer.WriteInt32, Base.WriteStringWrap(false, "ExposeParams", 0), nil, "ExposeParams", true, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NavId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ForceLod0, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Hp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 161, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BreakStage, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.OccupantInfos, Base.WriteStructWrap(Auto.WriteSceneDeviceOccupantInfo, "OccupantInfos"), nil, "OccupantInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.DropWeaponId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.EffectIds, writer.WriteInt32, 0, "EffectIds", true, 0, nil)
	Base.WritePrimitive(writer, val.NoSleep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.SkillInfo, Auto.WriteSkillDestructibleInfo, "SkillInfo", true)
end

Auto.WriteTaskEventInfo = function(writer, val)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.FinishedChoiceLs, writer.WriteUInt32, 0, "FinishedChoiceLs", true, 0, nil)
	Base.WritePrimitive(writer, val.StatusData, writer.WriteByte, 0)
end

Auto.WriteTaskMoveCommandData = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TargetType, 260, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.TargetObject, Auto.WriteClientActionTarget, "TargetObject")
	Base.WriteStruct(writer, val.TargetPosition, Auto.WriteUXVector3, "TargetPosition")
	Base.WritePrimitive(writer, Base.CheckEnum(val.MoveTowardType, 261, 0), writer.WriteByte, 0)
	Base.WriteStruct(writer, val.TargetDirection, Auto.WriteUXVector3, "TargetDirection")
	Base.WritePrimitive(writer, val.ArriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DirectionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TryMatchStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RunChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.KeepMovingAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NoRootMotion, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ObstacleAvoidanceSwitch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteTaskRaidRuleShowDialogParam = function(writer, val)
	Base.WritePrimitive(writer, val.DialogId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StopWhenTaskEnd, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.StopWhenAgentDie, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.StopWhenTeleport, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AttachDialog, writer.WriteBoolean, false)
end

Auto.WriteTaskSpoonViewInfo = function(writer, val)
	writer.WriteString(writer, val.SpoonMd5, false, "TaskSpoonViewInfo.SpoonMd5", 0)
	Base.WritePrimitive(writer, val.SpRaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTaskId, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.Alias, true, "TaskSpoonViewInfo.Alias", 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventStartTaskId, writer.WriteUInt32, 0)
end

Auto.WriteTaskStateData = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 262, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Reason, 263, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.FailTextId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CanSkip, writer.WriteBoolean, false)
end

Auto.WriteTaskVehicleBuffInitInfo = function(writer, val)
	Base.WritePrimitive(writer, val.configId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.duration, writer.WriteSingle, 0)
end

Auto.WriteTaskViewCounter = function(writer, val)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Value, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ConfigValue, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Parent, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.Child, Base.WriteComplexWrap(Auto.WriteTaskViewCounter, "TaskViewCounter", true), nil, "Child", true, 0, nil)
end

Auto.WriteTaskViewData = function(writer, val)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.CounterValues, writer.WriteInt32, 0, "CounterValues", false, 0, nil)
	Base.WriteList7Bit(writer, val.Counters, Base.WriteComplexWrap(Auto.WriteTaskViewCounter, "TaskViewCounter", false), nil, "Counters", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 262, 0), writer.WriteByte, 0)
	Base.WriteDict7Bit(writer, val.ActiveFunctionValue, writer.WriteByte, writer.WriteInt32, 0, "ActiveFunctionValue", true, 0)
	Base.WriteDict7Bit(writer, val.ActiveFunctionIds, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteIntList, "IntList", false), nil, "ActiveFunctionIds", true, 0)
	Base.WritePrimitive(writer, val.RecoverResource, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.SpoonViewInfo, Auto.WriteTaskSpoonViewInfo, "SpoonViewInfo", true)
end

Auto.WriteTaskWaitLoadResource = function(writer, val)
	Base.WriteList7Bit(writer, val.AgentSpoonIds, writer.WriteInt32, 0, "AgentSpoonIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.Gadgets, writer.WriteUInt64, 0, "Gadgets", false, 0, nil)
	Base.WriteList7Bit(writer, val.SceneItems, writer.WriteUInt64, 0, "SceneItems", false, 0, nil)
	Base.WriteList7Bit(writer, val.VehicleSpoonIds, writer.WriteInt32, 0, "VehicleSpoonIds", false, 0, nil)
	Base.WriteList7Bit(writer, val.DynamicGoIds, writer.WriteInt32, 0, "DynamicGoIds", false, 0, nil)
	Base.WritePrimitive(writer, val.EntryAgentViewpointSpoonId, writer.WriteInt32, 0)
end

Auto.WriteTaskWayPointMoveCommandData = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SpecificMethod, 115, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.KeepMovingAction, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NoRootMotion, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MoveActionGroup, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.WayPoints, Base.WriteStructWrap(Auto.WriteUXVector3, "WayPoints"), nil, "WayPoints", false, 0, nil)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteTeamSetting = function(writer, val)
	Base.WritePrimitive(writer, val.AllowMemberInvite, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AutoApplyJoin, writer.WriteBoolean, false)
end

Auto.WriteTeamTrackGPS = function(writer, val)
	Base.WriteStruct(writer, val.TrackPosition, Auto.WriteUXVector3, "TrackPosition")
	writer.WriteString(writer, val.TrackGPSId, false, "TeamTrackGPS.TrackGPSId", RpcLengthLimits.TeamTrackGPS_TrackGPSId)
	Base.WritePrimitive(writer, val.TrackGPSType, writer.WriteUInt32, 0)
end

Auto.WriteTeleportOption = function(writer, val)
	Base.WritePrimitive(writer, val.teleportId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsSwitchScene, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.WaitTaskResource, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MapEntranceId, writer.WriteUInt32, 0)
end

Auto.WriteThreatDebugValue = function(writer, val)
	Base.WritePrimitive(writer, val.BaseThreat, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FinalThreat, writer.WriteSingle, 0)
end

Auto.WriteTierDetail = function(writer, val)
	Base.WritePrimitive(writer, val.TierConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentBigTierId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentSmallTierId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Points, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MMR, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.WinStreak, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LoseStreak, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlacementPlayed, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastRankTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InactiveBoostCount, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.MatchHistory, Base.WriteComplexWrap(Auto.WriteTierMatchRecord, "TierMatchRecord", true), nil, "MatchHistory", true, 0, nil)
	Base.WriteComplex(writer, val.ApexGrantedRewards, Auto.WriteApexGrantedRewards, "ApexGrantedRewards", true)
end

Auto.WriteTierDetailSettleData = function(writer, val)
	Base.WritePrimitive(writer, val.Delta, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.OldTierDetailInfo, Auto.WriteClientTierDetailInfo, "OldTierDetailInfo", false)
	Base.WriteComplex(writer, val.NewTierDetailInfo, Auto.WriteClientTierDetailInfo, "NewTierDetailInfo", false)
end

Auto.WriteTierMatchRecord = function(writer, val)
	Base.WritePrimitive(writer, val.SettleTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TotalCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OldMMR, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NewMMR, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OldPoints, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NewPoints, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OldSmallTierId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NewSmallTierId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LPDelta, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Outcome, 264, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.PlacementDone, writer.WriteBoolean, false)
end

Auto.WriteTierSettleDataBase = function(writer, val)
	Base.WritePrimitive(writer, val.MultiPlayerId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GMScore, writer.WriteUInt32, 0)
end

Auto.WriteTile = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Suit, 265, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsRed, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteInt32, 0)
end

Auto.WriteTimePanelInfo = function(writer, val)
	Base.WriteList7Bit(writer, val.PersonalTimeSettings, Base.WriteComplexWrap(Auto.WritePersonalTimeSetting, "PersonalTimeSetting", true), nil, "PersonalTimeSettings", true, 0, nil)
end

Auto.WriteTokenInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.Ip, false, "TokenInfo.Ip", 0)
	Base.WritePrimitive(writer, val.Port, writer.WriteInt32, 0)
	writer.WriteString(writer, val.Token, false, "TokenInfo.Token", 0)
	Base.WritePrimitive(writer, val.GateServerId, writer.WriteInt32, 0)
	writer.WriteString(writer, val.AccountId, false, "TokenInfo.AccountId", 0)
end

Auto.WriteTombEnterMapData = function(writer, val)
	Base.WriteList7Bit(writer, val.SlotConnections, Base.WriteComplexWrap(Auto.WriteTombSlotConnectionInfo, "TombSlotConnectionInfo", false), nil, "SlotConnections", false, 0, nil)
end

Auto.WriteTombSlotConnectionInfo = function(writer, val)
	Base.WritePrimitive(writer, val.IslandId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SlotId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Dir, writer.WriteInt32, 0)
end

Auto.WriteTradeBucketInfo = function(writer, val)
	Base.WritePrimitive(writer, val.BucketId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OrderCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MinPrice, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxPrice, writer.WriteUInt32, 0)
end

Auto.WriteTradeHistoryRecord = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TradeItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Direction, 34, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Price, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CounterpartyPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.OrderId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
end

Auto.WriteTradeItemExtraData = function(writer, val)
	Base.WritePrimitive(writer, val.VisibleAfterTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FashionSuitInstanceId, writer.WriteUInt64, 0)
end

Auto.WriteTradeOrderDetail = function(writer, val)
	Base.WritePrimitive(writer, val.SellerId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.ItemExtraData, Auto.WriteTradeItemExtraData, "ItemExtraData", true)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ListTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OrderId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TradeItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Price, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PageIndex, writer.WriteUInt32, 0)
end

Auto.WriteTradeOrderIdQuadruple = function(writer, val)
	Base.WritePrimitive(writer, val.OrderId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TradeItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Price, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PageIndex, writer.WriteUInt32, 0)
end

Auto.WriteTradeOrderItem = function(writer, val)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ListTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OrderId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TradeItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Price, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PageIndex, writer.WriteUInt32, 0)
end

Auto.WriteTradeOrderRef = function(writer, val)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.State, 266, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ListTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.ItemExtraData, Auto.WriteTradeItemExtraData, "ItemExtraData", true)
	Base.WritePrimitive(writer, val.OrderId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TradeItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Price, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PageIndex, writer.WriteUInt32, 0)
end

Auto.WriteTruckCargoSettleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Completeness, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsInGadget, writer.WriteBoolean, false)
end

Auto.WriteTruckJobOrderAccept = function(writer, val)
	Base.WritePrimitive(writer, val.AcceptedEventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AcceptTime, writer.WriteUInt32, 0)
end

Auto.WriteTruckJobOrderInfo = function(writer, val)
	Base.WriteComplex(writer, val.StartPos, Auto.WriteTruckPosInfo, "StartPos", false)
	Base.WriteComplex(writer, val.EndPos, Auto.WriteTruckPosInfo, "EndPos", false)
	Base.WritePrimitive(writer, val.CargoId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.DeliveryNpc, Auto.WriteTruckNpcInfo, "DeliveryNpc", false)
	Base.WritePrimitive(writer, val.IsEmergency, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LimitAcceptSeconds, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LimitFinishSeconds, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EstimatedFinishSeconds, writer.WriteInt32, 0)
	Base.WriteList(writer, val.CargoInfoList, Base.WriteComplexWrap(Auto.WriteCargoInfo, "CargoInfo", false), nil, "CargoInfoList", false, 0, nil)
	Base.WritePrimitive(writer, val.BasePointReward, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DropCoefficient, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DropMoney, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SpecialOrderId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpecialPointReward, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.AddDropCoefficient, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActivityIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsHighValue, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RandomOrderId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsDailyOrder, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OrderType, writer.WriteUInt32, 0)
end

Auto.WriteTruckJobOrderResult = function(writer, val)
	Base.WritePrimitive(writer, val.FinishTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CargoIntegrity, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DropId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DropCoefficient, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RewardPoint, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Evaluation, 267, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CustomerSatisfaction, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DropMoney, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Dropped, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsCargoNear, writer.WriteBoolean, false)
	Base.WriteList(writer, val.AddBuffList, writer.WriteUInt32, 0, "AddBuffList", false, 0, nil)
	Base.WriteList(writer, val.RemoveBuffList, writer.WriteUInt32, 0, "RemoveBuffList", false, 0, nil)
	Base.WritePrimitive(writer, val.OrderDeliverUpSetId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DeliverUpset, writer.WriteUInt32, 0)
end

Auto.WriteTruckJobOrderWrap = function(writer, val)
	Base.WriteComplex(writer, val.OrderInfo, Auto.WriteTruckJobOrderInfo, "OrderInfo", false)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OrderInfoStartTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AcceptInfo, Auto.WriteTruckJobOrderAccept, "AcceptInfo", true)
	Base.WriteComplex(writer, val.ResultInfo, Auto.WriteTruckJobOrderResult, "ResultInfo", true)
	Base.WritePrimitive(writer, val.CargoPickedUp, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CargoIntegrity, writer.WriteSingle, 0)
end

Auto.WriteTruckNpcInfo = function(writer, val)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ConsigneeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RudeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CharacterId, writer.WriteUInt32, 0)
end

Auto.WriteTruckPosInfo = function(writer, val)
	Base.WritePrimitive(writer, val.WpId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rot, Auto.WriteUXVector3, "Rot")
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.DeliveryGadgetInfoList, Base.WriteComplexWrap(Auto.WriteDeliveryGadgetInfo, "DeliveryGadgetInfo", false), nil, "DeliveryGadgetInfoList", false, 0, nil)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
end

Auto.WriteTrustNpcInfo = function(writer, val)
	Base.WritePrimitive(writer, val.ProfileId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TrustValue, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActivateTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.GotRewardList, writer.WriteUInt32, 0, "GotRewardList", false, 0, nil)
	Base.WriteList(writer, val.FinishTargetList, writer.WriteUInt32, 0, "FinishTargetList", false, 0, nil)
	Base.WritePrimitive(writer, val.IsNew, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsMaxTrustReward, writer.WriteBoolean, false)
	Base.WriteList(writer, val.TargetStateList, Base.WriteComplexWrap(Auto.WriteTrustNpcTargetState, "TrustNpcTargetState", false), nil, "TargetStateList", false, 0, nil)
end

Auto.WriteTrustNpcTargetState = function(writer, val)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsNew, writer.WriteBoolean, false)
end

Auto.WriteTsumoInfo = function(writer, val)
	Base.WritePrimitive(writer, val.TsumoPlayerIndex, writer.WriteInt32, 0)
	writer.WriteString(writer, val.TsumoPlayerName, false, "TsumoInfo.TsumoPlayerName", 0)
	Base.WriteStruct(writer, val.TsumoHandData, Auto.WritePlayerHandData, "TsumoHandData")
	Base.WriteList7Bit(writer, val.AllHandData, Base.WriteStructWrap(Auto.WritePlayerHandData, "AllHandData"), nil, "AllHandData", false, 0, nil)
	Base.WriteStruct(writer, val.WinningTile, Auto.WriteTile, "WinningTile")
	Base.WriteList7Bit(writer, val.DoraIndicators, Base.WriteStructWrap(Auto.WriteTile, "DoraIndicators"), nil, "DoraIndicators", false, 0, nil)
	Base.WriteList7Bit(writer, val.UraDoraIndicators, Base.WriteStructWrap(Auto.WriteTile, "UraDoraIndicators"), nil, "UraDoraIndicators", false, 0, nil)
	Base.WritePrimitive(writer, val.IsRichi, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.TsumoPointInfo, Auto.WriteNetworkPointInfo, "TsumoPointInfo")
	Base.WritePrimitive(writer, val.TotalPoints, writer.WriteInt32, 0)
end

Auto.WriteTuiteCommentListData = function(writer, val)
	Base.WritePrimitive(writer, val.Total, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.CommentList, Base.WriteStructWrap(Auto.WriteClientTuiteComment, "CommentList"), nil, "CommentList", false, 0, nil)
end

Auto.WriteTuiteTimelineData = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.TimelineData, false, "TuiteTimelineData.TimelineData", 0)
end

Auto.WriteTurnCommandData = function(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.DirectionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteTurnEndInfo = function(writer, val)
	Base.WritePrimitive(writer, val.PlayerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ChosenOperationType, 218, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Operations, Base.WriteStructWrap(Auto.WriteOutTurnOperation, "Operations"), nil, "Operations", false, 0, nil)
	Base.WriteList7Bit(writer, val.Points, writer.WriteInt32, 0, "Points", false, 0, nil)
	Base.WriteList7Bit(writer, val.RichiStatus, writer.WriteBoolean, false, "RichiStatus", false, 0, nil)
	Base.WritePrimitive(writer, val.RichiSticks, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Zhenting, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.MahjongSetData, Auto.WriteMahjongSetData, "MahjongSetData")
end

Auto.WriteTurnToPositionData = function(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsImmediate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionUid, writer.WriteUInt32, 0)
end

Auto.WriteUAVAutoDriveCommandData = function(writer, val)
	Base.WriteStruct(writer, val.Destination, Auto.WriteUXVector3, "Destination")
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteUAVFollowCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ArriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteUAVPutDownCommandData = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteUAVPutUpCommandData = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteUGCRaceSetting = function(writer, val)
	Base.WritePrimitive(writer, val.MapId, writer.WriteUInt64, 0)
end

Auto.WriteUIntPayload = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt32, 0)
end

Auto.WriteULongPayload = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt64, 0)
end

Auto.WriteUShortPayload = function(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt16, 0)
end

Auto.WriteUXBoolObject = function(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteBoolean, false)
end

Auto.WriteUXDoubleObject = function(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteDouble, 0)
end

Auto.WriteUXIntObject = function(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteInt32, 0)
end

Auto.WriteUXLongObject = function(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteInt64, 0)
end

Auto.WriteUXMassHideArea = function(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Hide, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HideType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EntityType, writer.WriteInt64, 0)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WriteStruct(writer, val.Extends, Auto.WriteUXVector3, "Extends")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
end

Auto.WriteUXObject = function(writer, val)
end

Auto.WriteUXStringObject = function(writer, val)
	writer.WriteString(writer, val.Value, false, "UXStringObject.Value", 0)
end

Auto.WriteUXUintObject = function(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt32, 0)
end

Auto.WriteUXUlongObject = function(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt64, 0)
end

Auto.WriteUXVector2Int = function(writer, val)
	Base.WritePrimitive(writer, val.X, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Y, writer.WriteInt32, 0)
end

Auto.WriteUXVector3List = function(writer, val)
	Base.WriteList7Bit(writer, val.Value, Base.WriteStructWrap(Auto.WriteUXVector3, "Value"), nil, "Value", false, 0, nil)
end

Auto.WriteUXVector3Payload = function(writer, val)
	Base.WriteStruct(writer, val.V, Auto.WriteUXVector3, "V")
end

Auto.WriteUgcComponentPointInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ComponentCfgId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WriteStruct(writer, val.Scale, Auto.WriteUXVector3, "Scale")
	Base.WritePrimitive(writer, val.Order, writer.WriteInt32, 0)
end

Auto.WriteUgcMapBasicInfo = function(writer, val)
	Base.WritePrimitive(writer, val.MapId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.OwnerPid, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.MapName, false, "UgcMapBasicInfo.MapName", 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MinPlayerCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxPlayerCount, writer.WriteUInt32, 0)
end

Auto.WriteUgcMapComponentInfo = function(writer, val)
	Base.WriteDict(writer, val.ComponentPoints, writer.WriteInt32, Base.WriteComplexWrap(Auto.WriteUgcComponentPointInfo, "UgcComponentPointInfo", false), nil, "ComponentPoints", false, 0)
	Base.WritePrimitive(writer, val.MaxComponentId, writer.WriteInt32, 0)
end

Auto.WriteUgcMapDefinitionInfo = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.MapType, 268, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SettlementType, 269, 1), writer.WriteByte, 1)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LevelTime, writer.WriteUInt32, 0)
end

Auto.WriteUgcMapPlayerSyncInfo = function(writer, val)
	Base.WriteComplex(writer, val.PublishSyncInfo, Auto.WriteUgcMapPublishSyncInfo, "PublishSyncInfo", false)
	Base.WriteComplex(writer, val.EditingDefinitionInfo, Auto.WriteUgcMapDefinitionInfo, "EditingDefinitionInfo", true)
	Base.WritePrimitive(writer, val.EditingUpdateTime, writer.WriteUInt32, 0)
end

Auto.WriteUgcMapPublishSyncInfo = function(writer, val)
	Base.WriteComplex(writer, val.BasicInfo, Auto.WriteUgcMapBasicInfo, "BasicInfo", false)
	Base.WritePrimitive(writer, val.Heat, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LikeCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalPlayerNumber, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.DefinitionInfo, Auto.WriteUgcMapDefinitionInfo, "DefinitionInfo", true)
end

Auto.WriteUintList = function(writer, val)
	Base.WriteList(writer, val.Value, writer.WriteUInt32, 0, "Value", false, 0, nil)
end

Auto.WriteUploadObjectUrl = function(writer, val)
	writer.WriteString(writer, val.Url, false, "UploadObjectUrl.Url", 0)
	Base.WritePrimitive(writer, val.ExpireTimeStamp, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.ObjectKey, false, "UploadObjectUrl.ObjectKey", 0)
end

Auto.WriteUrbanGamePlayResult = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PlayType, 270, 0), writer.WriteByte, 0)
	Base.WriteComplex(writer, val.GymPlayResult, Auto.WriteGymPlayResult, "GymPlayResult", true)
	Base.WriteComplex(writer, val.DancePlayResult, Auto.WriteDancePlayResult, "DancePlayResult", true)
	Base.WriteComplex(writer, val.RestaurantResult, Auto.WriteRestaurantResult, "RestaurantResult", true)
end

Auto.WriteValidateClientNodeServerCommand = function(writer, val)
	Base.WritePrimitive(writer, val.Nid, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Observables, Base.WriteStringWrap(true, "Observables", 0), nil, "Observables", true, 0, nil)
	Base.WriteList7Bit(writer, val.Replicables, Base.WriteStringWrap(true, "Replicables", 0), nil, "Replicables", true, 0, nil)
	Base.WriteList7Bit(writer, val.Messengers, Base.WriteStringWrap(true, "Messengers", 0), nil, "Messengers", true, 0, nil)
	Base.WriteList7Bit(writer, val.SyncReplicables, Base.WriteStringWrap(true, "SyncReplicables", 0), nil, "SyncReplicables", true, 0, nil)
	Base.WritePrimitive(writer, val.RpcId, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.HasRpcId, writer.WriteBoolean, false)
end

Auto.WriteVehicleAICommonParameters = function(writer, val)
	Base.WritePrimitive(writer, val.FollowPathCheckArrivePointDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TurnSlowSpeedTemplateId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TurnMinAheadSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TurnMinAheadDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TurnMaxAheadSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TurnMaxAheadDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AheadDistanceNormalRatio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DummySpeedRatio, writer.WriteSingle, 0)
	Base.WriteComplex(writer, val.StuckCheckConfig, Auto.WriteVehicleStuckCheckConfig, "StuckCheckConfig", false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.VirtualGroundMoveType, 106, 0), writer.WriteByte, 0)
end

Auto.WriteVehicleAITaskParameters = function(writer, val)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

Auto.WriteVehicleAnimationBase = function(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
end

Auto.WriteVehicleBlockMove = function(writer, val)
	Base.WritePrimitive(writer, val.weight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.blockSpeedMultiplier, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.blockDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.blockCD, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.blockWaitTime, writer.WriteSingle, 0)
end

Auto.WriteVehicleBlockedByPlayerConditionData = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
end

Auto.WriteVehicleBrokenCollisionInfo = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleEntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CurrentHp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxHp, writer.WriteSingle, 0)
end

Auto.WriteVehicleClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.ControllerPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.CreateSourceType, 200, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Parts, Base.WriteStructWrap(Auto.WriteVehicleClientPart, "Parts"), nil, "Parts", true, 0, nil)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.EulerAngles, Auto.WriteUXVector3, "EulerAngles")
	Base.WritePrimitive(writer, val.Velocity, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsStatic, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DeformStatus, writer.WriteInt32, 0)
	Base.WriteList7Bit(writer, val.SeatInfos, Base.WriteComplexWrap(Auto.WriteRaidVehicleSeatInfo, "RaidVehicleSeatInfo", true), nil, "SeatInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.SpoonId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsDynamicGo, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.VehicleEnemyId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DisableNavigation, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Interactable, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MoveToken, writer.WriteInt32, 0)
	writer.WriteString(writer, val.LicensePlate, true, "VehicleClientInfo.LicensePlate", 0)
end

Auto.WriteVehicleClientPart = function(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
end

Auto.WriteVehicleCollisionImpulseConditionData = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Operation, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RightFloat, writer.WriteSingle, 0)
end

Auto.WriteVehicleCollisionRecord = function(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rot, Auto.WriteUXVector3, "Rot")
end

Auto.WriteVehicleCollisionUploadData = function(writer, val)
	Base.WriteStruct(writer, val.SelfRecord, Auto.WriteVehicleCollisionRecord, "SelfRecord")
	Base.WriteStruct(writer, val.OtherRecord, Auto.WriteVehicleCollisionRecord, "OtherRecord")
	Base.WriteStruct(writer, val.CollisionPoint, Auto.WriteUXVector3, "CollisionPoint")
end

Auto.WriteVehicleComponentStateUpdateInfo = function(writer, val)
	Base.WritePrimitive(writer, val.UId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ComponentType, 271, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.NewStatus, 272, 0), writer.WriteByte, 0)
end

Auto.WriteVehicleContactDamageData = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleMass, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.VehicleVelocities, Base.WriteStructWrap(Auto.WriteUXVector3, "VehicleVelocities"), nil, "VehicleVelocities", false, RpcLengthLimits.VehicleContactDamageData_VehicleVelocities, nil)
	Base.WriteStruct(writer, val.VehicleRelativeVelocity, Auto.WriteUXVector3, "VehicleRelativeVelocity")
	Base.WritePrimitive(writer, val.Layer, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TouchMass, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EnemyWeight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EnemyRank, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DisableThreshold, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OtherVehicleEntityId, writer.WriteUInt64, 0)
end

Auto.WriteVehicleDangerZone = function(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AreaInstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WriteStruct(writer, val.Extends, Auto.WriteUXVector3, "Extends")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WritePrimitive(writer, val.Radius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Add, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ObstacleOnly, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RemoveRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HideType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EntityType, writer.WriteInt64, 0)
end

Auto.WriteVehicleDestructibleData = function(writer, val)
	Base.WriteComplex(writer, val.VehicleInfo, Auto.WriteVehicleDestructibleInfo, "VehicleInfo", false)
	Base.WritePrimitive(writer, val.SceneItemCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.LivingTime, writer.WriteSingle, 0)
end

Auto.WriteVehicleDestructibleInfo = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Front, writer.WriteBoolean, false)
end

Auto.WriteVehicleDestructiblePartStatus = function(writer, val)
	Base.WritePrimitive(writer, val.partID, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.dmgStatus, 272, 0), writer.WriteByte, 0)
end

Auto.WriteVehicleDestructiblePartsDamageInfo = function(writer, val)
	Base.WritePrimitive(writer, val.vehicleUId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.damagedGlassList, Base.WriteComplexWrap(Auto.WriteVehicleDestructiblePartStatus, "VehicleDestructiblePartStatus", false), nil, "damagedGlassList", false, RpcLengthLimits.VehicleDestructiblePartsDamageInfo_damagedGlassList, nil)
	Base.WriteList7Bit(writer, val.damagedLightList, Base.WriteComplexWrap(Auto.WriteVehicleDestructiblePartStatus, "VehicleDestructiblePartStatus", false), nil, "damagedLightList", false, RpcLengthLimits.VehicleDestructiblePartsDamageInfo_damagedLightList, nil)
	Base.WriteList7Bit(writer, val.damagedDoorList, Base.WriteComplexWrap(Auto.WriteVehicleDestructiblePartStatus, "VehicleDestructiblePartStatus", false), nil, "damagedDoorList", false, RpcLengthLimits.VehicleDestructiblePartsDamageInfo_damagedDoorList, nil)
end

Auto.WriteVehicleDriftParameters = function(writer, val)
	Base.WritePrimitive(writer, val.TotalDuration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DriftAction, 273, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.HandBrakeDuration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

Auto.WriteVehicleEscapeDebugData = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleUid, writer.WriteUInt64, 0)
	writer.WriteString(writer, val.Status, false, "VehicleEscapeDebugData.Status", 0)
end

Auto.WriteVehicleForwardEventData = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UnitPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PlayerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.EventType, 274, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.Bits, writer.WriteByte, 0, "Bits", false, RpcLengthLimits.VehicleForwardEventData_Bits, nil)
end

Auto.WriteVehicleGoStraightParameters = function(writer, val)
	Base.WritePrimitive(writer, val.Duration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AutoStop, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

Auto.WriteVehicleHackActionParameter = function(writer, val)
end

Auto.WriteVehicleHackChaseTargetParameter = function(writer, val)
	Base.WritePrimitive(writer, val.TargetVehicleEntityId, writer.WriteUInt64, 0)
	Base.WriteList7Bit(writer, val.BuffIdArray, writer.WriteUInt32, 0, "BuffIdArray", true, RpcLengthLimits.VehicleHackChaseTargetParameter_BuffIdArray, nil)
end

Auto.WriteVehicleHitData = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DriverId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HurtEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HurtStiffId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.VehicleSpeed, Auto.WriteUXVector3, "VehicleSpeed")
	Base.WriteStruct(writer, val.AgentSpeed, Auto.WriteUXVector3, "AgentSpeed")
end

Auto.WriteVehicleNavResult = function(writer, val)
	Base.WritePrimitive(writer, val.NavReqId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.Points, Base.WriteStructWrap(Auto.WriteUXVector3, "Points"), nil, "Points", false, 0, nil)
	Base.WriteList7Bit(writer, val.CenterPoints, Base.WriteStructWrap(Auto.WriteUXVector3, "CenterPoints"), nil, "CenterPoints", false, 0, nil)
end

Auto.WriteVehicleNitroData = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NitrogenValue, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BeginOrEnd, writer.WriteBoolean, false)
end

Auto.WriteVehiclePartAnimation = function(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PartIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Events, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Priority, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
end

Auto.WriteVehiclePoliceChaseParameters = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TargetType, 102, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

Auto.WriteVehicleRamMove = function(writer, val)
	Base.WritePrimitive(writer, val.weight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.coldDownForOwn, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.coldDownForGroup, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.suitableAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.exitDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.turnTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.extrusionTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.extrusionMoveDisAtFront, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.regressTime, writer.WriteSingle, 0)
end

Auto.WriteVehicleRequisitionCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.BorrowedSeatIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NpcSeatIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.AnimVariantType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteVehicleRequisitionFailedCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.BorrowedSeatIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NpcSeatIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteVehicleSkillDamageData = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleMass, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.VehicleVelocity, Auto.WriteUXVector3, "VehicleVelocity")
	Base.WritePrimitive(writer, val.HurtEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.HitPoint, Auto.WriteUXVector3, "HitPoint")
end

Auto.WriteVehicleSpecialPartAnimation = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.PartType, 275, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
end

Auto.WriteVehicleStuckCheckConfig = function(writer, val)
	Base.WritePrimitive(writer, val.StuckLevel, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.RelaxedStuckCheckTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RelaxedStuckCheckCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ModerateStuckCheckCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StrictStuckCheckDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CheckGoToNextPointStuckTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ResetWhenStuck, writer.WriteBoolean, false)
end

Auto.WriteVehicleTurnParameters = function(writer, val)
	Base.WritePrimitive(writer, val.Duration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TurnAction, 276, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.AutoStop, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 1)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

Auto.WriteVehicleWeaponEquipInfo = function(writer, val)
	Base.WritePrimitive(writer, val.VehicleUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.WeaponDetail, Auto.WriteWeaponDetail, "WeaponDetail", true)
	Base.WritePrimitive(writer, val.ShouldEquip, writer.WriteBoolean, false)
end

Auto.WriteVisibilityReportData = function(writer, val)
	Base.WritePrimitive(writer, val.detectorPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.detectedPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.isVisible, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.isFront, writer.WriteBoolean, false)
end

Auto.WriteVoteInitData = function(writer, val)
	Base.WritePrimitive(writer, val.CreaterPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StartTimeMS, writer.WriteUInt32, 0)
end

Auto.WriteWaitingData = function(writer, val)
	Base.WriteList7Bit(writer, val.HandTiles, Base.WriteStructWrap(Auto.WriteTile, "HandTiles"), nil, "HandTiles", false, 0, nil)
	Base.WriteList7Bit(writer, val.WaitingTiles, Base.WriteStructWrap(Auto.WriteTile, "WaitingTiles"), nil, "WaitingTiles", false, 0, nil)
end

Auto.WriteWasherMissionHistoryInfo = function(writer, val)
	Base.WritePrimitive(writer, val.HistoryMissionCnt, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HistoryMissionMoney, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TodayMissionMoney, writer.WriteInt32, 0)
	Base.WriteList(writer, val.HistoryMissionResults, Base.WriteComplexWrap(Auto.WriteWasherMissionResult, "WasherMissionResult", false), nil, "HistoryMissionResults", false, 0, nil)
end

Auto.WriteWasherMissionHistoryItem = function(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RandomCfgId, writer.WriteUInt32, 0)
end

Auto.WriteWasherMissionResult = function(writer, val)
	Base.WritePrimitive(writer, val.MissionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Progress, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RewardRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ProficiencyRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UsingTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AddMoney, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TalentPointRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RandomCfgId, writer.WriteUInt32, 0)
end

Auto.WriteWasherParticipantInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AIAgentInfo, Auto.WriteLinkAIAgentInfo, "AIAgentInfo", true)
	Base.WritePrimitive(writer, val.AgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

Auto.WriteWasherZoneInfo = function(writer, val)
	writer.WriteString(writer, val.ZoneSessionId, false, "WasherZoneInfo.ZoneSessionId", 0)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.StartReason, 118, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.GameTypeRandom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, Base.CheckEnum(val.SyncReason, 119, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneType, 120, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.ZoneState, 121, 0), writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
	Base.WriteStruct(writer, val.CountDownInfo, Auto.WriteGameGroundZoneCountDownInfo, "CountDownInfo")
end

Auto.WriteWatchingInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.TaskInfo, Auto.WriteTaskViewData, "TaskInfo", true)
	Base.WriteComplex(writer, val.TaskSpoonViewInfo, Auto.WriteTaskSpoonViewInfo, "TaskSpoonViewInfo", true)
end

Auto.WriteWeaponBulletDatas = function(writer, val)
	Base.WritePrimitive(writer, val.BulletId, writer.WriteUInt32, 0)
end

Auto.WriteWeaponData = function(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Durability, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReceivedTimeStamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.OperatorFlags, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.SpecialLabel, true, "WeaponData.SpecialLabel", 0)
	Base.WriteComplex(writer, val.WeaponFlags, Auto.WriteWeaponDataFlags, "WeaponFlags", false)
	Base.WritePrimitive(writer, val.SceneItemHp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.BulletDatas, Auto.WriteWeaponBulletDatas, "BulletDatas", false)
	Base.WriteList(writer, val.Decorations, Base.WriteComplexWrap(Auto.WriteWeaponDecorationDatas, "WeaponDecorationDatas", false), nil, "Decorations", false, 0, nil)
	Base.WritePrimitive(writer, val.FightStyleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MagazineAmmo, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsPlayerLocked, writer.WriteBoolean, false)
	Base.WriteList(writer, val.EnchantSlots, Base.WriteComplexWrap(Auto.WriteWeaponEnchantSlotData, "WeaponEnchantSlotData", false), nil, "EnchantSlots", false, 0, nil)
	Base.WritePrimitive(writer, val.NonDirectionalEnchantCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DirectionalEnchantCountSinceLastNonDir, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LockedDirectionalEnhancementId, writer.WriteUInt32, 0)
end

Auto.WriteWeaponDataFlags = function(writer, val)
	Base.WritePrimitive(writer, val.IsTaskWheelWeapon, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ShowRedDot, writer.WriteBoolean, false)
	Base.WriteList(writer, val.AdditionalEffectIds, writer.WriteInt32, 0, "AdditionalEffectIds", true, 0, nil)
end

Auto.WriteWeaponDecorationDatas = function(writer, val)
	Base.WritePrimitive(writer, val.ItemId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DecorationId, writer.WriteUInt32, 0)
end

Auto.WriteWeaponDetail = function(writer, val)
	Base.WritePrimitive(writer, val.SourceAgentSpoonId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SourceAgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SourceSceneItemId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsLocked, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SourceSceneItemTaskUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Durability, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReceivedTimeStamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.OperatorFlags, writer.WriteUInt32, 0)
	writer.WriteString(writer, val.SpecialLabel, true, "WeaponDetail.SpecialLabel", 0)
	Base.WriteComplex(writer, val.WeaponFlags, Auto.WriteWeaponDataFlags, "WeaponFlags", false)
	Base.WritePrimitive(writer, val.SceneItemHp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.StackCount, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.BulletDatas, Auto.WriteWeaponBulletDatas, "BulletDatas", false)
	Base.WriteList(writer, val.Decorations, Base.WriteComplexWrap(Auto.WriteWeaponDecorationDatas, "WeaponDecorationDatas", false), nil, "Decorations", false, 0, nil)
	Base.WritePrimitive(writer, val.FightStyleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MagazineAmmo, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BindPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsPlayerLocked, writer.WriteBoolean, false)
	Base.WriteList(writer, val.EnchantSlots, Base.WriteComplexWrap(Auto.WriteWeaponEnchantSlotData, "WeaponEnchantSlotData", false), nil, "EnchantSlots", false, 0, nil)
	Base.WritePrimitive(writer, val.NonDirectionalEnchantCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DirectionalEnchantCountSinceLastNonDir, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LockedDirectionalEnhancementId, writer.WriteUInt32, 0)
end

Auto.WriteWeaponEnchantSlotData = function(writer, val)
	Base.WritePrimitive(writer, val.EnchantConfigId, writer.WriteUInt32, 0)
end

Auto.WriteWeaponWheelData = function(writer, val)
	Base.WritePrimitive(writer, val.WheelId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.WeaponSlots, Base.WriteComplexWrap(Auto.WriteWeaponDetail, "WeaponDetail", false), nil, "WeaponSlots", false, 0, nil)
	Base.WritePrimitive(writer, val.LockMaxSlotCounts, writer.WriteInt32, 0)
end

Auto.WriteWearFashionEditInfo = function(writer, val)
	Base.WritePrimitive(writer, val.FashionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Scale, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WriteStruct(writer, val.Offset, Auto.WriteUXVector3, "Offset")
end

Auto.WriteWearFashionInfo = function(writer, val)
	Base.WritePrimitive(writer, val.FashionId, writer.WriteUInt32, 0)
end

Auto.WriteWearSourceInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Source, writer.WriteInt16, 0)
	Base.WritePrimitive(writer, val.SourceId, writer.WriteUInt32, 0)
end

Auto.WriteWebviewLoginTokenInfo = function(writer, val)
	writer.WriteString(writer, val.Aid, false, "WebviewLoginTokenInfo.Aid", RpcLengthLimits.WebviewLoginTokenInfo_Aid)
	writer.WriteString(writer, val.Username, false, "WebviewLoginTokenInfo.Username", RpcLengthLimits.WebviewLoginTokenInfo_Username)
	writer.WriteString(writer, val.RoleId, false, "WebviewLoginTokenInfo.RoleId", RpcLengthLimits.WebviewLoginTokenInfo_RoleId)
	writer.WriteString(writer, val.RoleName, false, "WebviewLoginTokenInfo.RoleName", RpcLengthLimits.WebviewLoginTokenInfo_RoleName)
	Base.WritePrimitive(writer, val.ServerId, writer.WriteInt32, 0)
	writer.WriteString(writer, val.RoleIcon, false, "WebviewLoginTokenInfo.RoleIcon", RpcLengthLimits.WebviewLoginTokenInfo_RoleIcon)
	Base.WritePrimitive(writer, val.Time, writer.WriteInt32, 0)
	writer.WriteString(writer, val.ActivityName, false, "WebviewLoginTokenInfo.ActivityName", RpcLengthLimits.WebviewLoginTokenInfo_ActivityName)
	writer.WriteString(writer, val.PayloadJson, false, "WebviewLoginTokenInfo.PayloadJson", RpcLengthLimits.WebviewLoginTokenInfo_PayloadJson)
end

Auto.WriteWeightedRandomItemUInt = function(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weight, writer.WriteUInt32, 0)
end

Auto.WriteWildEnemyGroupInitSyncInfo = function(writer, val)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsFirst, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.EnemyInstanceIds, writer.WriteUInt64, 0, "EnemyInstanceIds", false, 0, nil)
end

Auto.WriteWorkActionNodeInfo = function(writer, val)
	Base.WritePrimitive(writer, val.NodeId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.WorkActionIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Value, writer.WriteInt32, 0)
end

Auto.WriteWushuTournamentOpponentBestClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.OpponentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BestStars, writer.WriteUInt32, 0)
end

Auto.WriteWushuTournamentRoundClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.RoundId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BestStars, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Choice, writer.WriteUInt32, 0)
	Base.WriteList7Bit(writer, val.OpponentBestStars, Base.WriteComplexWrap(Auto.WriteWushuTournamentOpponentBestClientInfo, "WushuTournamentOpponentBestClientInfo", false), nil, "OpponentBestStars", false, 0, nil)
end

Auto.WriteWushuTournamentRoundSettlementInfo = function(writer, val)
	Base.WritePrimitive(writer, val.RoundId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Star, writer.WriteByte, 0)
	Base.WriteList7Bit(writer, val.RewardList, writer.WriteUInt32, 0, "RewardList", false, 0, nil)
end

Auto.WriteWushuTournamentSeasonClientInfo = function(writer, val)
	Base.WritePrimitive(writer, val.SeasonId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsSeasonCleared, writer.WriteBoolean, false)
	Base.WriteList7Bit(writer, val.Rounds, Base.WriteComplexWrap(Auto.WriteWushuTournamentRoundClientInfo, "WushuTournamentRoundClientInfo", false), nil, "Rounds", false, 0, nil)
	Base.WritePrimitive(writer, val.LastChallengeRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastChallengeChoice, writer.WriteUInt32, 0)
end

Auto.WriteYachtAttachedEntityInfo = function(writer, val)
	Base.WriteDict7Bit(writer, val.YachtGadgetHoldersByUniqueId, writer.WriteUInt64, writer.WriteUInt64, 0, "YachtGadgetHoldersByUniqueId", true, 0)
	Base.WriteDict7Bit(writer, val.GadgetsByUniqueId, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteGadgetEntityInfo, "GadgetEntityInfo", false), nil, "GadgetsByUniqueId", true, 0)
	Base.WriteDict7Bit(writer, val.YachtDestructibleHoldersByUniqueId, writer.WriteUInt64, writer.WriteUInt64, 0, "YachtDestructibleHoldersByUniqueId", true, 0)
	Base.WriteDict7Bit(writer, val.DestructiblesByUniqueId, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteDestructibleInfo, "DestructibleInfo", false), nil, "DestructiblesByUniqueId", true, 0)
end

Auto.WriteYachtMoveData = function(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

Auto.WriteYachtSpawnData = function(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.OwnerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteDouble, 0)
	Base.WriteComplex(writer, val.AttachedEntities, Auto.WriteYachtAttachedEntityInfo, "AttachedEntities", true)
end

Auto.WriteYakuValue = function(writer, val)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Name, 277, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Value, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.Type, 278, 0), writer.WriteByte, 0)
end

Auto.WriteZoneData = function(writer, val)
	Base.WritePrimitive(writer, val.BoundaryPointsBegin, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BoundaryPointsEnd, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LanesBegin, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LanesEnd, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Bounds, Auto.WriteSerializeMinMaxAABB, "Bounds")
	Base.WritePrimitive(writer, val.Tags, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.UrbanDiversity, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StationId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ZoneGroupHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ZoneGroupInternalNumber, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PointsCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DensityFactor, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RoadWidth, writer.WriteSingle, 0)
end

Auto.WriteZoneDataV2 = function(writer, val)
	Base.WritePrimitive(writer, val.BoundaryPointsBegin, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BoundaryPointsEnd, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LanesBegin, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LanesEnd, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Bounds, Auto.WriteSerializeMinMaxAABB, "Bounds")
	Base.WritePrimitive(writer, val.Tags, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.PointsCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DensityFactor, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RoadWidth, writer.WriteSingle, 0)
end

Auto.WriteZoneGraphBVNode = function(writer, val)
	Base.WritePrimitive(writer, val.MinX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MinY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MinZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
end

Auto.WriteZoneGraphBVTree = function(writer, val)
	Base.WriteStruct(writer, val.Origin, Auto.WriteFloat3, "Origin")
	Base.WriteList(writer, val.Nodes, Base.WriteStructWrap(Auto.WriteZoneGraphBVNode, "Nodes"), nil, "Nodes", false, 0, nil)
end

Auto.WriteZoneGraphLaneLocation = function(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteFloat3, "Position")
	Base.WriteStruct(writer, val.LanePosition, Auto.WriteFloat3, "LanePosition")
	Base.WriteStruct(writer, val.Direction, Auto.WriteFloat3, "Direction")
	Base.WriteStruct(writer, val.Tangent, Auto.WriteFloat3, "Tangent")
	Base.WriteStruct(writer, val.Up, Auto.WriteFloat3, "Up")
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LaneSegment, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DistanceAlongLane, writer.WriteSingle, 0)
	Base.WriteList7Bit(writer, val.ZoneIndexs, writer.WriteInt32, 0, "ZoneIndexs", true, 0, nil)
	Base.WritePrimitive(writer, val.LaneZoneIndex, writer.WriteInt32, 0)
end

Auto.WriteZoneGraphLaneSection = function(writer, val)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StartDistanceAlongLane, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EndDistanceAlongLane, writer.WriteSingle, 0)
end

Auto.WriteZoneGraphLinkedLane = function(writer, val)
	Base.WritePrimitive(writer, val.DestLane, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.Flags, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weight, writer.WriteSingle, 0)
end

Auto.WriteZoneGraphPathCommandData = function(writer, val)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt16, 0)
	Base.WriteList7Bit(writer, val.Points, Base.WriteStructWrap(Auto.WriteClientZoneGraphPathPoint, "Points"), nil, "Points", false, 0, nil)
	Base.WritePrimitive(writer, Base.CheckEnum(val.TargetLocationReason, 144, 0), writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteByte, 0)
	Base.WritePrimitive(writer, Base.CheckEnum(val.DataSource, 108, 0), writer.WriteInt16, 0)
end

Auto.WriteZoneGraphStorage = function(writer, val)
	Base.WriteList(writer, val.Zones, Base.WriteComplexWrap(Auto.WriteZoneData, "ZoneData", false), nil, "Zones", false, 0, nil)
	Base.WriteList(writer, val.Lanes, Base.WriteStructWrap(Auto.WriteZoneLaneData, "Lanes"), nil, "Lanes", false, 0, nil)
	Base.WriteList(writer, val.BoundaryPoints, Base.WriteStructWrap(Auto.WriteFloat3, "BoundaryPoints"), nil, "BoundaryPoints", false, 0, nil)
	Base.WriteList(writer, val.LanePoints, Base.WriteStructWrap(Auto.WriteFloat3, "LanePoints"), nil, "LanePoints", false, 0, nil)
	Base.WriteList(writer, val.LaneUpVectors, Base.WriteStructWrap(Auto.WriteFloat3, "LaneUpVectors"), nil, "LaneUpVectors", false, 0, nil)
	Base.WriteList(writer, val.LaneTangentVectors, Base.WriteStructWrap(Auto.WriteFloat3, "LaneTangentVectors"), nil, "LaneTangentVectors", false, 0, nil)
	Base.WriteList(writer, val.LanePointProgressions, writer.WriteSingle, 0, "LanePointProgressions", false, 0, nil)
	Base.WriteList(writer, val.LaneLinks, Base.WriteStructWrap(Auto.WriteZoneLaneLinkData, "LaneLinks"), nil, "LaneLinks", false, 0, nil)
	Base.WriteStruct(writer, val.Bounds, Auto.WriteSerializeMinMaxAABB, "Bounds")
	Base.WriteStruct(writer, val.ZoneBVTree, Auto.WriteZoneGraphBVTree, "ZoneBVTree")
	Base.WritePrimitive(writer, val.DataHandle, writer.WriteInt32, 0)
end

Auto.WriteZoneGraphStorageV2 = function(writer, val)
	Base.WriteList7Bit(writer, val.Zones, Base.WriteComplexWrap(Auto.WriteZoneDataV2, "ZoneDataV2", false), nil, "Zones", false, 0, nil)
	Base.WriteList7Bit(writer, val.Lanes, Base.WriteStructWrap(Auto.WriteZoneLaneData, "Lanes"), nil, "Lanes", false, 0, nil)
	Base.WriteList7Bit(writer, val.BoundaryPoints, Base.WriteStructWrap(Auto.WriteFloat3, "BoundaryPoints"), nil, "BoundaryPoints", false, 0, nil)
	Base.WriteList7Bit(writer, val.LanePoints, Base.WriteStructWrap(Auto.WriteFloat3, "LanePoints"), nil, "LanePoints", false, 0, nil)
	Base.WriteList7Bit(writer, val.LaneUpVectors, Base.WriteStructWrap(Auto.WriteFloat3, "LaneUpVectors"), nil, "LaneUpVectors", false, 0, nil)
	Base.WriteList7Bit(writer, val.LaneTangentVectors, Base.WriteStructWrap(Auto.WriteFloat3, "LaneTangentVectors"), nil, "LaneTangentVectors", false, 0, nil)
	Base.WriteList7Bit(writer, val.LanePointProgressions, writer.WriteSingle, 0, "LanePointProgressions", false, 0, nil)
	Base.WriteList7Bit(writer, val.LaneLinks, Base.WriteStructWrap(Auto.WriteZoneLaneLinkData, "LaneLinks"), nil, "LaneLinks", false, 0, nil)
	Base.WriteStruct(writer, val.Bounds, Auto.WriteSerializeMinMaxAABB, "Bounds")
	Base.WriteStruct(writer, val.ZoneBVTree, Auto.WriteZoneGraphBVTree, "ZoneBVTree")
	Base.WritePrimitive(writer, val.DataHandle, writer.WriteInt32, 0)
end

Auto.WriteZoneGraphTagFilter = function(writer, val)
	Base.WriteStruct(writer, val.AnyTags, Auto.WriteZoneGraphTags, "AnyTags")
	Base.WriteStruct(writer, val.AllTags, Auto.WriteZoneGraphTags, "AllTags")
	Base.WriteStruct(writer, val.NotTags, Auto.WriteZoneGraphTags, "NotTags")
end

Auto.WriteZoneGraphTags = function(writer, val)
	Base.WritePrimitive(writer, val.StaticTags, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.DynamicTags, writer.WriteInt64, 0)
end

Auto.WriteZoneLaneData = function(writer, val)
	Base.WritePrimitive(writer, val.Width, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Tags, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.PointsBegin, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PointsEnd, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LinksBegin, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LinksEnd, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ZoneIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StartEntryId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndEntryId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CenterLaneId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TurnDirection, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ConnectionType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SourceExtendDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DestExtendDistance, writer.WriteSingle, 0)
end

Auto.WriteZoneLaneLinkData = function(writer, val)
	Base.WritePrimitive(writer, val.DestLaneIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.Flags, writer.WriteUInt32, 0)
end

Auto.WriteUXVector3 = function(writer, val)
	if val.X ~= nil then
		print_error("[RPC] WriteUXVector3 X = nil")

		val.X = 0
	end

	if val.Y ~= nil then
		print_error("[RPC] WriteUXVector3 Y = nil")

		val.Y = 0
	end

	if val.Z ~= nil then
		print_error("[RPC] WriteUXVector3 Z = nil")

		val.Z = 0
	end

	Base.WritePrimitive(writer, val.X, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Y, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Z, writer.WriteSingle, 0)
end

return Auto
