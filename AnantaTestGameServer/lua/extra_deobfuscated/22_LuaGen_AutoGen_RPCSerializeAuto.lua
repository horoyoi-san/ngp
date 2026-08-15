local Auto = {}
local SerializeObjectMarkNull = 0
local SerializeObjectMarkCommon = 255
local Base = require("LX6/Service/RPCSerializeBase")

function Auto.WriteAIDebugParameter(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	writer:WriteString(val.BtName, false, "BtName", 0)
	writer:WriteString(val.BtMD5, false, "BtMD5", 0)
	Base.WritePrimitive(writer, val.ForceDrive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Tick, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Paused, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EntityType, writer.WriteByte, 0)
	Base.WriteList(writer, val.Nodes, Base.WriteComplexWrap(Auto.WriteAINodeData, "AINodeData", false), nil, "Nodes", false, 0, nil)
	Base.WriteList(writer, val.Variables, Base.WriteStructWrap(Auto.WriteAISharedVariableInfo, "Variables"), nil, "Variables", false, 0, nil)
	Base.WriteStruct(writer, val.Event, Auto.WriteAINodeEvent, "Event")
end

function Auto.WriteAINodeData(writer, val)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TaskIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Reevaluate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Interrupted, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ExecutionStatus, writer.WriteByte, 0)
	writer:WriteString(val.ErrorMessage, true, "ErrorMessage", 0)
	writer:WriteString(val.InfoMessage, true, "InfoMessage", 0)
end

function Auto.WriteAINodeEvent(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteInt32, 0)
end

function Auto.WriteAISharedVariableInfo(writer, val)
	writer:WriteString(val.Key, false, "Key", 0)
	writer:WriteString(val.Value, false, "Value", 0)
end

function Auto.WriteAcceptedTruckOrderInfo(writer, val)
	Base.WriteList(writer, val.Orders, Base.WriteComplexWrap(Auto.WriteTruckJobOrderWrap, "TruckJobOrderWrap", false), nil, "Orders", false, 0, nil)
	Base.WriteDict(writer, val.EventToAgent, writer.WriteUInt32, writer.WriteUInt64, 0, "EventToAgent", false, 0)
end

function Auto.WriteAccumulateSignInActivityCommonInfo(writer, val)
	Base.WriteList(writer, val.Rewards, writer.WriteUInt32, 0, "Rewards", false, 0, nil)
	Base.WriteList(writer, val.DisplayReward, writer.WriteUInt32, 0, "DisplayReward", false, 0, nil)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
end

function Auto.WriteAccumulateSignInActivityData(writer, val)
	Base.WriteList(writer, val.SignInList, Base.WriteComplexWrap(Auto.WriteAccumulateSignInData, "AccumulateSignInData", false), nil, "SignInList", false, 0, nil)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowRedPoint, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsOutOfDate, writer.WriteBoolean, false)
end

function Auto.WriteAccumulateSignInData(writer, val)
	Base.WritePrimitive(writer, val.SignInTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsGot, writer.WriteBoolean, false)
end

function Auto.WriteAchievementCategory(writer, val)
	Base.WritePrimitive(writer, val.Progress, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HasEarnedCopper, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HasEarnedSilver, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HasEarnedGold, writer.WriteBoolean, false)
end

function Auto.WriteAchievementDetail(writer, val)
	Base.WritePrimitive(writer, val.AchieveTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.HasEarnedRewards, writer.WriteBoolean, false)
end

function Auto.WriteAchievementViewData(writer, val)
	Base.WriteDict(writer, val.Achievements, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteAchievementDetail, "AchievementDetail", false), nil, "Achievements", false, 0)
	Base.WriteDict(writer, val.Category, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteAchievementCategory, "AchievementCategory", false), nil, "Category", false, 0)
end

function Auto.WriteActivityDataBase(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowRedPoint, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsOutOfDate, writer.WriteBoolean, false)
end

function Auto.WriteAddPlacedFurnitureInfo(writer, val)
	Base.WritePrimitive(writer, val.ParentPlacedInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.FurnitureId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
end

function Auto.WriteAetherAIInitData(writer, val)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HasZoneGraph, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ZoneStorageDataHandle, writer.WriteInt32, 0)
	Base.WriteList(writer, val.Intersections, Base.WriteComplexWrap(Auto.WriteClientTrafficIntersectionInitInfo, "ClientTrafficIntersectionInitInfo", true), nil, "Intersections", true, 0, nil)
	Base.WriteList(writer, val.Crowds, Base.WriteComplexWrap(Auto.WriteClientCrowdInitData, "ClientCrowdInitData", true), nil, "Crowds", true, 0, nil)
	Base.WriteList(writer, val.StaticNpcs, Base.WriteComplexWrap(Auto.WriteClientStaticNpcInitData, "ClientStaticNpcInitData", true), nil, "StaticNpcs", true, 0, nil)
	Base.WriteList(writer, val.Vehicles, Base.WriteComplexWrap(Auto.WriteClientVehicleInitData, "ClientVehicleInitData", true), nil, "Vehicles", true, 0, nil)
	Base.WriteList(writer, val.StaticVehicles, Base.WriteComplexWrap(Auto.WriteClientStaticVehicleInitData, "ClientStaticVehicleInitData", true), nil, "StaticVehicles", true, 0, nil)
	Base.WriteList(writer, val.VehicleNpcs, Base.WriteComplexWrap(Auto.WriteClientVehicleNpcInitData, "ClientVehicleNpcInitData", true), nil, "VehicleNpcs", true, 0, nil)
	Base.WriteList(writer, val.MetroNpcs, Base.WriteComplexWrap(Auto.WriteClientMetroNpcInitData, "ClientMetroNpcInitData", true), nil, "MetroNpcs", true, 0, nil)
end

function Auto.WriteAgentCharacterComponent(writer, val)
	Base.WritePrimitive(writer, val.Portrait, writer.WriteUInt32, 0)
end

function Auto.WriteAgentCrimeData(writer, val)
	Base.WriteList(writer, val.CrimeRecord, writer.WriteUInt32, 0, "CrimeRecord", true, 0, nil)
	Base.WriteList(writer, val.DefaultItems, writer.WriteUInt32, 0, "DefaultItems", true, 0, nil)
	Base.WriteList(writer, val.DefaultDrugs, writer.WriteUInt32, 0, "DefaultDrugs", true, 0, nil)
	Base.WritePrimitive(writer, val.Alcohol, writer.WriteInt32, 0)
end

function Auto.WriteAgentDestructibleData(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.LivingTime, writer.WriteSingle, 0)
end

function Auto.WriteAgentFormationData(writer, val)
	Base.WritePrimitive(writer, val.row, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.col, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.colSpacing, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.rowSpacing, writer.WriteSingle, 0)
end

function Auto.WriteAgentPlotDestroyConfig(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
	Base.WriteList(writer, val.RunAwayPositionList, Base.WriteStructWrap(Auto.WriteUXVector3, "RunAwayPositionList"), nil, "RunAwayPositionList", true, 0, nil)
	Base.WritePrimitive(writer, val.Distance, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
end

function Auto.WriteAgentPoliceExamAOIData(writer, val)
	Base.WritePrimitive(writer, val.FineTimes, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.Fines, writer.WriteUInt32, writer.WriteBoolean, false, "Fines", false, 0)
end

function Auto.WriteAgentQueryDetailInfo(writer, val)
	writer:WriteString(val.AgentSpawnType, false, "AgentSpawnType", 0)
	Base.WritePrimitive(writer, val.UseForwardGroup, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ForceFullAoi, writer.WriteBoolean, false)
end

function Auto.WriteAgentSyncClientInfo(writer, val)
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
	writer:WriteString(val.petPerformData, true, "petPerformData", 0)
	Base.WriteList(writer, val.stimIDList, writer.WriteInt32, 0, "stimIDList", true, 0, nil)
	Base.WritePrimitive(writer, val.randomModelCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.layer, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.gpsOffsetY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.isTemp, writer.WriteBoolean, false)
	Base.WriteList(writer, val.spawnEffectId, writer.WriteUInt32, 0, "spawnEffectId", true, 0, nil)
	Base.WritePrimitive(writer, val.hideEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.actionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.actionGroupId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.metroLineId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.metroCarriageId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentDataSetsActivityCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GameplaySignalId, writer.WriteUInt32, 0)
	writer:WriteString(val.treeName, false, "treeName", 0)
	Base.WritePrimitive(writer, val.sitIndex, writer.WriteInt32, 0)
	Base.WriteList(writer, val.indoorList, writer.WriteUInt32, 0, "indoorList", false, 0, nil)
	Base.WriteList(writer, val.roomIds, writer.WriteInt32, 0, "roomIds", true, 0, nil)
	Base.WritePrimitive(writer, val.forbidStimulateType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.agentStimType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.beHitType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SpoonAgentId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.FeiSuo, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FashionSuitId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CanBeExaminedByPolice, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IgnoreWanted, writer.WriteBoolean, false)
end

function Auto.WriteAnimalClientInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Favor, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.FavorLevel, writer.WriteUInt32, 0)
	writer:WriteString(val.NickName, true, "NickName", 0)
	Base.WritePrimitive(writer, val.Unlock, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Interacted, writer.WriteBoolean, false)
end

function Auto.WriteAreaColliderParams(writer, val)
	Base.WriteStruct(writer, val.BoxAreaParams, Auto.WriteBoxAreaParams, "BoxAreaParams")
end

function Auto.WriteAttractPointSyncInfo(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.FacingDirection, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Priority, writer.WriteByte, 0)
	Base.WriteList(writer, val.BsIngAgents, writer.WriteUInt64, 0, "BsIngAgents", false, 0, nil)
end

function Auto.WriteBVBBattleAgentStatistics(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Damage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BeDamaged, writer.WriteSingle, 0)
end

function Auto.WriteBVBBonus(writer, val)
	Base.WritePrimitive(writer, val.Basic, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WinBonus, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StreakLength, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StreakBonus, writer.WriteUInt32, 0)
end

function Auto.WriteBVBBuffCandidate(writer, val)
	Base.WritePrimitive(writer, val.ChaosBuffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Cost, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Selected, writer.WriteBoolean, false)
end

function Auto.WriteBVBBuffData(writer, val)
	Base.WritePrimitive(writer, val.ChaosBuffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
end

function Auto.WriteBVBPlayerBasicInfo(writer, val)
	Base.WritePrimitive(writer, val.PlayerType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PlayerId, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.Pokemons, writer.WriteUInt32, 0, "Pokemons", false, 0, nil)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BVBCamp, writer.WriteByte, 0)
end

function Auto.WriteBVBPlayerData(writer, val)
	Base.WriteList(writer, val.Pokemons, Base.WriteComplexWrap(Auto.WriteFightPokemon, "FightPokemon", false), nil, "Pokemons", false, 0, nil)
	Base.WriteList(writer, val.TagInfos, Base.WriteComplexWrap(Auto.WriteChaosTagInfo, "ChaosTagInfo", false), nil, "TagInfos", false, 0, nil)
	Base.WriteList(writer, val.ChaosBuffs, Base.WriteComplexWrap(Auto.WriteBVBBuffData, "BVBBuffData", false), nil, "ChaosBuffs", false, 0, nil)
end

function Auto.WriteBVBSelectPokemonData(writer, val)
	Base.WritePrimitive(writer, val.q, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.r, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.s, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.pokemonId, writer.WriteUInt64, 0)
end

function Auto.WriteBadgeInfo(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Active, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DropSend, writer.WriteBoolean, false)
end

function Auto.WriteBartenderCustomerNormalInfo(writer, val)
	Base.WritePrimitive(writer, val.LastVisitTime, writer.WriteUInt32, 0)
end

function Auto.WriteBartenderCustomerSuperInfo(writer, val)
	Base.WritePrimitive(writer, val.VisitCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastVisitTime, writer.WriteUInt32, 0)
end

function Auto.WriteBartenderCustomerSyncInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
end

function Auto.WriteBartenderElementInfos(writer, val)
	Base.WriteDict(writer, val.ElementId2StockOzDict, writer.WriteUInt32, writer.WriteSingle, 0, "ElementId2StockOzDict", false, 0)
end

function Auto.WriteBartenderGameInfos(writer, val)
	Base.WriteDict(writer, val.CustomerSuperDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBartenderCustomerSuperInfo, "BartenderCustomerSuperInfo", false), nil, "CustomerSuperDict", false, 0)
	Base.WriteDict(writer, val.CustomerNormalDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBartenderCustomerNormalInfo, "BartenderCustomerNormalInfo", false), nil, "CustomerNormalDict", false, 0)
end

function Auto.WriteBasketballAskOperatorParam(writer, val)
	Base.WritePrimitive(writer, val.OperatorType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BallUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ActiveUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PassiveUid, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.DelayParam, Auto.WriteBasketballSyncDelayActionSpecialParam, "DelayParam", true)
	Base.WriteComplex(writer, val.ShootParam, Auto.WriteBasketballSyncShootSpecialParam, "ShootParam", true)
end

function Auto.WriteBasketballSyncDelayActionSpecialParam(writer, val)
	Base.WritePrimitive(writer, val.delay, writer.WriteSingle, 0)
end

function Auto.WriteBasketballSyncOperatorParam(writer, val)
	Base.WritePrimitive(writer, val.OperatorType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BallUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ActiveUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PassiveUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsSuccess, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.DelayParam, Auto.WriteBasketballSyncDelayActionSpecialParam, "DelayParam", true)
	Base.WriteComplex(writer, val.ShootParam, Auto.WriteBasketballSyncShootSpecialParam, "ShootParam", true)
end

function Auto.WriteBasketballSyncOwnerInfo(writer, val)
	Base.WriteDict(writer, val.full, writer.WriteUInt64, writer.WriteUInt64, 0, "full", true, 0)
	Base.WriteDict(writer, val.addOrUpdate, writer.WriteUInt64, writer.WriteUInt64, 0, "addOrUpdate", true, 0)
	Base.WriteList(writer, val.remove, writer.WriteUInt64, 0, "remove", true, 0, nil)
end

function Auto.WriteBasketballSyncShootSpecialParam(writer, val)
	Base.WriteStruct(writer, val.startPos, Auto.WriteUXVector3, "startPos")
	Base.WriteStruct(writer, val.shootVelocity, Auto.WriteUXVector3, "shootVelocity")
	Base.WritePrimitive(writer, val.moveTime, writer.WriteSingle, 0)
end

function Auto.WriteBegBehaviorData(writer, val)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PoseStartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PoseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Spot, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcGatherRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NpcGatherLimit, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DialogId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RewardMean, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RewardVariance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TotalReward, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalAttractedNpc, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TotalRewardFromPlayer, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.NpcIds, writer.WriteUInt32, 0, "NpcIds", false, 0, nil)
	Base.WritePrimitive(writer, val.IsPromoted, writer.WriteBoolean, false)
end

function Auto.WriteBehaviorSeqCommand(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CommandIndex, writer.WriteInt32, 0)
end

function Auto.WriteBelongItemInfo(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BelongingItemState, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.OwnerId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

function Auto.WriteBelongingDebugInfo(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt32, 0)
end

function Auto.WriteBestNpcInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Favor, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowFavorLevel, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ShowFavorTime, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InteractDays, writer.WriteUInt32, 0)
end

function Auto.WriteBillInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OrderTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShipTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ChargeId, writer.WriteUInt32, 0)
	writer:WriteString(val.GoodsId, false, "GoodsId", 0)
	writer:WriteString(val.SN, false, "SN", 0)
	writer:WriteString(val.ConsumeSN, false, "ConsumeSN", 0)
	writer:WriteString(val.PayChannel, false, "PayChannel", 0)
	writer:WriteString(val.AppChannel, false, "AppChannel", 0)
	writer:WriteString(val.PayMethod, false, "PayMethod", 0)
	writer:WriteString(val.Platform, false, "Platform", 0)
	writer:WriteString(val.Udid, false, "Udid", 0)
	Base.WritePrimitive(writer, val.GoodsCount, writer.WriteInt32, 0)
	writer:WriteString(val.PayMoney, false, "PayMoney", 0)
	writer:WriteString(val.FreeMoney, false, "FreeMoney", 0)
	writer:WriteString(val.PayCurrency, false, "PayCurrency", 0)
	Base.WritePrimitive(writer, val.Deduct, writer.WriteInt32, 0)
	writer:WriteString(val.DeductPercent, false, "DeductPercent", 0)
	Base.WritePrimitive(writer, val.FreeYuanBao, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PayYuanBao, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Status, writer.WriteInt32, 0)
end

function Auto.WriteBirdGroupData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.StateStartTime, writer.WriteUInt32, 0)
end

function Auto.WriteBowlingClientInfo(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt32, 0)
	writer:WriteString(val.Data, false, "Data", 1024)
end

function Auto.WriteBowlingParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteBowlingParticipantScoreInfo(writer, val)
	Base.WriteList(writer, val.ThrowScores, writer.WriteInt32, 0, "ThrowScores", false, 0, nil)
	Base.WriteList(writer, val.FrameScores, writer.WriteInt32, 0, "FrameScores", false, 0, nil)
end

function Auto.WriteBowlingScoreInfo(writer, val)
	Base.WriteDict(writer, val.BowlingScoreDict, writer.WriteInt32, Base.WriteComplexWrap(Auto.WriteBowlingParticipantScoreInfo, "BowlingParticipantScoreInfo", false), nil, "BowlingScoreDict", false, 0)
	Base.WritePrimitive(writer, val.Winner, writer.WriteInt32, 0)
end

function Auto.WriteBowlingZoneInfo(writer, val)
	Base.WritePrimitive(writer, val.GameType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentSubRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurn, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.ScoreInfo, Auto.WriteBowlingScoreInfo, "ScoreInfo", false)
	Base.WriteList(writer, val.BowlingPinSceneItemIdList, writer.WriteUInt64, 0, "BowlingPinSceneItemIdList", false, 0, nil)
	Base.WriteList(writer, val.BowlingBallSceneItemIdList, writer.WriteUInt64, 0, "BowlingBallSceneItemIdList", false, 0, nil)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StartReason, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SyncReason, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ZoneType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ZoneState, writer.WriteByte, 0)
	Base.WriteList(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
end

function Auto.WriteBoxAreaParams(writer, val)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WriteStruct(writer, val.Extents, Auto.WriteUXVector3, "Extents")
	Base.WriteStruct(writer, val.InversedRotation, Auto.WriteSerializeQuaternion, "InversedRotation")
end

function Auto.WriteBuffViewData(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Tier, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Permanent, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DestructibleId, writer.WriteUInt64, 0)
end

function Auto.WriteBuyFoodInfo(writer, val)
	Base.WritePrimitive(writer, val.RestaurantId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.FoodIdList, writer.WriteUInt32, 0, "FoodIdList", false, 256, nil)
	Base.WritePrimitive(writer, val.CompanionNpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Date, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NPCTreat, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MealTime, writer.WriteUInt32, 0)
end

function Auto.WriteByteAngle(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteByte, 0)
end

function Auto.WriteCargoInfo(writer, val)
	Base.WritePrimitive(writer, val.CargoId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.StartPos, Auto.WriteTruckPosInfo, "StartPos", false)
	Base.WritePrimitive(writer, val.Integrity, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsCargoNear, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
end

function Auto.WriteCentripetalVelocityData(writer, val)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
end

function Auto.WriteChallengeRecord(writer, val)
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

function Auto.WriteChallengeResult(writer, val)
	Base.WriteComplex(writer, val.ChallengeRecord, Auto.WriteNewChallengeRecord, "ChallengeRecord", false)
	Base.WritePrimitive(writer, val.CurrentRewardLevel, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.RewardInfo, Auto.WriteRewardInfo, "RewardInfo", false)
end

function Auto.WriteChangePlacedFurnitureInfo(writer, val)
	Base.WritePrimitive(writer, val.PlacedInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsChangeParentNode, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ParentPlacedInstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
end

function Auto.WriteChaosTagInfo(writer, val)
	Base.WritePrimitive(writer, val.TagId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TagLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TagExp, writer.WriteUInt32, 0)
end

function Auto.WriteCharacterBelongingItem(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Hp, writer.WriteSingle, 0)
end

function Auto.WriteChargeActivityClientInfo(writer, val)
	Base.WritePrimitive(writer, val.HasFirstCharge, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HasFirstChargeReward, writer.WriteBoolean, false)
end

function Auto.WriteChargeData(writer, val)
	Base.WritePrimitive(writer, val.CurrentCharges, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentPercentage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ChargePeriod, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxCharges, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Timestamp, writer.WriteDouble, 0)
end

function Auto.WriteChargeDeliveryResult(writer, val)
	writer:WriteString(val.SN, false, "SN", 0)
	writer:WriteString(val.PayChannel, false, "PayChannel", 0)
	writer:WriteString(val.ConsumeSN, false, "ConsumeSN", 0)
	Base.WritePrimitive(writer, val.ChargeId, writer.WriteUInt32, 0)
	writer:WriteString(val.GoodsId, false, "GoodsId", 0)
	Base.WritePrimitive(writer, val.Gold, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FreeGold, writer.WriteUInt32, 0)
end

function Auto.WriteChaseParameters(writer, val)
	Base.WritePrimitive(writer, val.TargetType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxSpeed, writer.WriteSingle, 0)
	writer:WriteString(val.chaseFormationName, false, "chaseFormationName", 0)
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
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteChatGroupClient(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Owner, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.Members, writer.WriteUInt64, 0, "Members", false, 0, nil)
	writer:WriteString(val.Name, true, "Name", 0)
	Base.WritePrimitive(writer, val.RejectMsg, writer.WriteBoolean, false)
end

function Auto.WriteChatHint(writer, val)
	Base.WriteComplex(writer, val.NameCard, Auto.WriteNameCard, "NameCard", false)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
end

function Auto.WriteChatInfoList(writer, val)
	Base.WriteList(writer, val.ChatList, Base.WriteComplexWrap(Auto.WriteNpcChatItem, "NpcChatItem", false), nil, "ChatList", false, 0, nil)
end

function Auto.WriteChatMessage(writer, val)
	Base.WritePrimitive(writer, val.MessageId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Channel, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Receiver, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsAudio, writer.WriteBoolean, false)
	writer:WriteString(val.Content, true, "Content", 0)
	Base.WritePrimitive(writer, val.SystemMessageId, writer.WriteInt32, 0)
end

function Auto.WriteChatMessagesBlob(writer, val)
	Base.WriteList(writer, val.Messages, Base.WriteComplexWrap(Auto.WriteChatMessage, "ChatMessage", false), nil, "Messages", false, 0, nil)
end

function Auto.WriteCheckAccountResult(writer, val)
	writer:WriteString(val.unisdk_login_json, true, "unisdk_login_json", 0)
	writer:WriteString(val.Token, false, "Token", 0)
	writer:WriteString(val.UserName, true, "UserName", 0)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NeedRealNameTip, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NeedRoleEnter, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RealNameVerified, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HostId, writer.WriteInt32, 0)
	writer:WriteString(val.OpenIdUrl, true, "OpenIdUrl", 0)
	Base.WritePrimitive(writer, val.code, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.subcode, writer.WriteInt32, 0)
	writer:WriteString(val.msg, true, "msg", 0)
end

function Auto.WriteCheckAgentDistanceInfo(writer, val)
	Base.WriteList(writer, val.Distance, writer.WriteInt32, 0, "Distance", false, 0, nil)
end

function Auto.WriteCheckPointAction(writer, val)
	Base.WritePrimitive(writer, val.wayPointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.opType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.duration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.aetherActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.conversationId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.dialogueSpeakers, Base.WriteStringWrap(true, "dialogueSpeakers", 0), nil, "dialogueSpeakers", true, 0, nil)
	Base.WriteList(writer, val.dialogueBindUnits, writer.WriteUInt64, 0, "dialogueBindUnits", true, 0, nil)
	Base.WritePrimitive(writer, val.wayLeaderDontWait, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.targetPace, writer.WriteByte, 0)
end

function Auto.WriteChefParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteChefZoneInfo(writer, val)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StartReason, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SyncReason, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ZoneType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ZoneState, writer.WriteByte, 0)
	Base.WriteList(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
end

function Auto.WriteCinemaMultiTicketInfo(writer, val)
	Base.WritePrimitive(writer, val.LocationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CinemaId, writer.WriteUInt32, 0)
end

function Auto.WriteCinemaTicketInfo(writer, val)
	Base.WritePrimitive(writer, val.LocationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CinemaId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MovieId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CompanionNpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CinemaNpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InviteNpcId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsDate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CommentType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.IsTask, writer.WriteBoolean, false)
end

function Auto.WriteClawDateClientInfo(writer, val)
	Base.WritePrimitive(writer, val.HideNpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FailTimes, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.FavorToyId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DateNpcId, writer.WriteUInt32, 0)
end

function Auto.WriteClawSettlementInfo(writer, val)
	Base.WritePrimitive(writer, val.ClawToyId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Date, writer.WriteBoolean, false)
end

function Auto.WriteClientActionAgentAnimation(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.animId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.selectedActionIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentAvoidDangerMove(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.dangerRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.dangerDuration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.updatePosTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.dangerDirRefreshLaneTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.dangerDirHalfAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.specificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.runChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentAvoidVehicleMove(writer, val)
	Base.WritePrimitive(writer, val.Vehicle, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.exitWaitTime, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.arriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.directionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.tryMatchStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.keepUpdateTargetPosition, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.runChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.moveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.moveActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.notTowardToTarget, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentCanSeeTarget(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.halfAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.useHead, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
end

function Auto.WriteClientActionAgentCheckVehicleCollisionImpulse(writer, val)
	Base.WritePrimitive(writer, val.vehicle, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.operation, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.rightFloat, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
end

function Auto.WriteClientActionAgentFaceTo(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.tolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentFavorInteract(writer, val)
	Base.WritePrimitive(writer, val.PlayerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SingleInteractType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MultiInteractType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentFocusOn(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.focusLevel, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.focusTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.tolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentFollow(writer, val)
	Base.WritePrimitive(writer, val.comfortRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.towardTarget, writer.WriteBoolean, false)
	Base.WriteList(writer, val.distances, Base.WriteStructWrap(Auto.WriteRangeMoveType, "distances"), nil, "distances", true, 0, nil)
	Base.WritePrimitive(writer, val.navigationTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.selfNavigationTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.failedWhenNavigationFailed, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.arriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.directionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.tryMatchStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.keepUpdateTargetPosition, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.runChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.moveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.moveActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.notTowardToTarget, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentGetInVehicle(writer, val)
	Base.WritePrimitive(writer, val.vehicle, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.seatIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.HasDoorInteract, writer.WriteBoolean, false)
	Base.WriteList(writer, val.distances, Base.WriteStructWrap(Auto.WriteRangeMoveType, "distances"), nil, "distances", true, 0, nil)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentGetSitUp(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentHitSomething(writer, val)
	Base.WritePrimitive(writer, val.hitForce, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.hitRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.hitPart, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.secondHitPart, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.hitLayer, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.hitTiming, Auto.WritePlotMinMaxRange, "hitTiming")
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.animId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.selectedActionIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentIKMotion(writer, val)
	Base.WritePrimitive(writer, val.IKTargetBone, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.animId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.selectedActionIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentInteract2(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.InteractType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentIsVehicleBlockedByPlayer(writer, val)
	Base.WritePrimitive(writer, val.vehicle, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
end

function Auto.WriteClientActionAgentLookAt(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.isOn, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.targetType, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.targetPosition, Auto.WriteUXVector3, "targetPosition")
	Base.WritePrimitive(writer, val.isKeep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.isFinishOnEnd, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.duration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ikPriority, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.lookAtIKType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.agentTargetPart, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentMove(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.arriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.directionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.tryMatchStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.keepUpdateTargetPosition, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.runChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.moveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.moveActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.notTowardToTarget, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentMoveToVehicle(writer, val)
	Base.WritePrimitive(writer, val.vehicle, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.seatIndex, writer.WriteInt32, 0)
	Base.WriteList(writer, val.distances, Base.WriteStructWrap(Auto.WriteRangeMoveType, "distances"), nil, "distances", true, 0, nil)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentNavigationMove(writer, val)
	Base.WritePrimitive(writer, val.navigationTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.selfNavigationTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.failedWhenNavigationFailed, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.arriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.directionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.tryMatchStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.keepUpdateTargetPosition, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.runChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.moveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.moveActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.notTowardToTarget, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentOstrichMove(writer, val)
	Base.WriteList(writer, val.Positions, Base.WriteStructWrap(Auto.WriteUXVector3, "Positions"), nil, "Positions", false, 0, nil)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentSelectedActionAnimation(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WriteList(writer, val.animationIds, writer.WriteUInt32, 0, "animationIds", false, 0, nil)
	Base.WritePrimitive(writer, val.baseObject, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.baseVehicle, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.targetType, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.reverse, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.selectAngleType, writer.WriteInt32, 0)
	Base.WriteList(writer, val.angleRange, writer.WriteSingle, 0, "angleRange", false, 0, nil)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentTargetIsRunning(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
end

function Auto.WriteClientActionAgentTaskMove(writer, val)
	Base.WriteStruct(writer, val.targetObject, Auto.WriteClientActionTarget, "targetObject")
	Base.WritePrimitive(writer, val.arriveDistance, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.targetPosition, Auto.WriteUXVector3, "targetPosition")
	Base.WriteStruct(writer, val.targetDirection, Auto.WriteUXVector3, "targetDirection")
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.directionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.tryMatchStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.runChasingDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.moveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.moveActionGroup, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.noRootMotion, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.towardTarget, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentTaskWayPointMove(writer, val)
	Base.WritePrimitive(writer, val.SpecificMethod, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.moveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.noRootMotion, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.moveActionGroup, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.wayPoints, Base.WriteStructWrap(Auto.WriteUXVector3, "wayPoints"), nil, "wayPoints", true, 0, nil)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentTurn(writer, val)
	Base.WriteStruct(writer, val.Target, Auto.WriteClientActionTarget, "Target")
	Base.WritePrimitive(writer, val.directionTolerance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionAgentXAgentMultiInteract(writer, val)
	Base.WritePrimitive(writer, val.AnotherAgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MultiInteractType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionBehaviorTree(writer, val)
	writer:WriteString(val.BehaviorTree, false, "BehaviorTree", 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionBreak(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionCheckNpcAnimState(writer, val)
	Base.WritePrimitive(writer, val.npcAnimState, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
end

function Auto.WriteClientActionCheckPointPathMove(writer, val)
	Base.WriteList(writer, val.wayPoints, Base.WriteStructWrap(Auto.WriteUXVector3, "wayPoints"), nil, "wayPoints", true, 0, nil)
	Base.WriteList(writer, val.checkPointActions, Base.WriteComplexWrap(Auto.WriteCheckPointAction, "CheckPointAction", true), nil, "checkPointActions", true, 0, nil)
	Base.WritePrimitive(writer, val.specificMethod, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.startPace, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.startPaceDuration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.animationSetId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.moveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.moveActionGroupId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.notOnGround, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.tryUseRootMotion, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionGetOutVehicle(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionLeadingWayMove(writer, val)
	Base.WritePrimitive(writer, val.partner, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.isDirector, writer.WriteBoolean, false)
	Base.WriteList(writer, val.wayPoints, Base.WriteStructWrap(Auto.WriteUXVector3, "wayPoints"), nil, "wayPoints", true, 0, nil)
	Base.WriteList(writer, val.checkPointActions, Base.WriteComplexWrap(Auto.WriteCheckPointAction, "CheckPointAction", true), nil, "checkPointActions", true, 0, nil)
	Base.WritePrimitive(writer, val.moveMethod, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.startPace, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.startPaceDuration, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.animationSetId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.moveActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.moveActionGroupId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.notOnGround, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.tryUseRootMotion, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.leadingBreakTurn, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.isLeadingWay, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.dontLimitExtraMove, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.dontLimitBasicMove, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.waitingDialogId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.minDialogDuration, writer.WriteSingle, 0)
	Base.WriteList(writer, val.leadingWayUrgings, Base.WriteStructWrap(Auto.WriteLeadingWayUrging, "leadingWayUrgings"), nil, "leadingWayUrgings", true, 0, nil)
	Base.WritePrimitive(writer, val.leadingWayCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionParameter(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionPoliceAssistCloseVehicleDoor(writer, val)
	Base.WritePrimitive(writer, val.vehicle, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.seatIndex, writer.WriteByte, 0)
	Base.WriteList(writer, val.distances, Base.WriteStructWrap(Auto.WriteRangeMoveType, "distances"), nil, "distances", true, 0, nil)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionPoliceAssistOpenVehicleDoor(writer, val)
	Base.WritePrimitive(writer, val.vehicle, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.seatIndex, writer.WriteByte, 0)
	Base.WriteList(writer, val.distances, Base.WriteStructWrap(Auto.WriteRangeMoveType, "distances"), nil, "distances", true, 0, nil)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionReactTraitFree(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
end

function Auto.WriteClientActionShowConversation(writer, val)
	Base.WritePrimitive(writer, val.dialogueId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.lookTarget, writer.WriteBoolean, false)
	Base.WriteList(writer, val.dialogueSpeakers, Base.WriteStringWrap(false, "dialogueSpeakers", 0), nil, "dialogueSpeakers", false, 0, nil)
	Base.WriteList(writer, val.dialogueBindUnits, writer.WriteUInt64, 0, "dialogueBindUnits", false, 0, nil)
	Base.WritePrimitive(writer, val.isRestart, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.resumeDelay, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.isGeneralDialog, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.clearPreDialogueTasks, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.yawAngleLimit, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.pitchAngleLimit, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionTarget(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
end

function Auto.WriteClientActionTruckUAVAutoDrive(writer, val)
	Base.WriteStruct(writer, val.Destination, Auto.WriteUXVector3, "Destination")
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionTruckUAVPutDown(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionTruckUAVPutUp(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionUAVFollow(writer, val)
	Base.WritePrimitive(writer, val.Target, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ArriveDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActionVehicleRequisition(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.BorrowedSeatIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NpcSeatIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	writer:WriteString(val.Debug, true, "Debug", 0)
end

function Auto.WriteClientActivityInfo(writer, val)
	Base.WriteComplex(writer, val.BaseActivityInfo, Auto.WriteCommonActivityInfo, "BaseActivityInfo", false)
	Base.WriteComplex(writer, val.ActivityData, Auto.WriteActivityDataBase, "ActivityData", false)
end

function Auto.WriteClientAgentBubbleConfig(writer, val)
	Base.WritePrimitive(writer, val.BubbleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TriggerPolicy, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Priority, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Cooldown, writer.WriteSingle, 0)
end

function Auto.WriteClientAgentBubbleConfigs(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.SensorRange, Auto.WriteClientAgentBubbleSensorRange, "SensorRange")
	Base.WriteList(writer, val.Configs, Base.WriteStructWrap(Auto.WriteClientAgentBubbleConfig, "Configs"), nil, "Configs", false, 0, nil)
end

function Auto.WriteClientAgentBubbleSensorRange(writer, val)
	Base.WritePrimitive(writer, val.HeightDiff, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RadiusSq, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ExpandRadiusSq, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LeftAngleBorder, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RightAngleBorder, writer.WriteSingle, 0)
end

function Auto.WriteClientBoardingInfo(writer, val)
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

function Auto.WriteClientCommandData(writer, val)
	writer:WriteString(val.Name, false, "Name", 0)
	writer:WriteString(val.Sign, false, "Sign", 0)
	writer:WriteString(val.Comment, true, "Comment", 0)
end

function Auto.WriteClientCompetitionSeasonInfo(writer, val)
	Base.WriteComplex(writer, val.CommonSeasonInfo, Auto.WriteCommonCompetitionSeasonInfo, "CommonSeasonInfo", false)
	Base.WriteComplex(writer, val.SeasonInfo, Auto.WriteCompetitionSeasonInfo, "SeasonInfo", true)
end

function Auto.WriteClientConditionalParameter(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
end

function Auto.WriteClientCrowdInitData(writer, val)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentPersonaId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UrbanDiversityConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DesiredSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt16, 0)
	Base.WritePrimitive(writer, val.TargetLocationReason, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.FashionSuitId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.Points, Base.WriteStructWrap(Auto.WriteClientZoneGraphPathPoint, "Points"), nil, "Points", false, 0, nil)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

function Auto.WriteClientCustomData(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt32, 0)
	Base.WriteList(writer, val.ParametersDouble, writer.WriteDouble, 0, "ParametersDouble", true, 0, nil)
	Base.WriteList(writer, val.ParametersULong, writer.WriteUInt64, 0, "ParametersULong", true, 0, nil)
	Base.WriteList(writer, val.ParametersUInt, writer.WriteUInt32, 0, "ParametersUInt", true, 0, nil)
	Base.WriteList(writer, val.ParametersVector3, Base.WriteStructWrap(Auto.WriteUXVector3, "ParametersVector3"), nil, "ParametersVector3", true, 0, nil)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteDouble, 0)
end

function Auto.WriteClientDangerAreaData(writer, val)
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

function Auto.WriteClientDetectEventData(writer, val)
	Base.WritePrimitive(writer, val.detectorPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.detectedPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.detectValue, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

function Auto.WriteClientDeviceInfo(writer, val)
	writer:WriteString(val.DeviceModel, true, "DeviceModel", 256)
	writer:WriteString(val.OsName, true, "OsName", 256)
	writer:WriteString(val.OsVersion, true, "OsVersion", 256)
	writer:WriteString(val.Udid, true, "Udid", 256)
	writer:WriteString(val.AppVersion, true, "AppVersion", 256)
	Base.WritePrimitive(writer, val.DeviceHeight, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DeviceWidth, writer.WriteInt32, 0)
	writer:WriteString(val.Network, true, "Network", 32)
	writer:WriteString(val.Ipv6, true, "Ipv6", 256)
	writer:WriteString(val.AppChannel, true, "AppChannel", 256)
	writer:WriteString(val.Transid, true, "Transid", 256)
	writer:WriteString(val.UnisdkDeviceId, true, "UnisdkDeviceId", 256)
	Base.WritePrimitive(writer, val.IsEmulator, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsRoot, writer.WriteBoolean, false)
	writer:WriteString(val.Imei, true, "Imei", 256)
	writer:WriteString(val.Location, true, "Location", 256)
	writer:WriteString(val.CountryCode, true, "CountryCode", 32)
	writer:WriteString(val.LocalIp, true, "LocalIp", 256)
	writer:WriteString(val.OldAccountId, true, "OldAccountId", 256)
	writer:WriteString(val.MacAddr, true, "MacAddr", 256)
	writer:WriteString(val.GpuName, true, "GpuName", 256)
	writer:WriteString(val.CpuName, true, "CpuName", 256)
	writer:WriteString(val.HardDriveSn, true, "HardDriveSn", 256)
	Base.WritePrimitive(writer, val.TotalMemory, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.ResolutionHeight, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ResolutionWidth, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.FullScreen, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DeviceLevel, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DisplayLevel, writer.WriteInt32, 0)
	writer:WriteString(val.Joystick, true, "Joystick", 256)
	Base.WritePrimitive(writer, val.characterQualityLevel, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.vehicleQualityLevel, writer.WriteInt32, 0)
end

function Auto.WriteClientFinishedTruckOrderView(writer, val)
	Base.WritePrimitive(writer, val.TodayTotalIncome, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TodayRewardPoint, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TotalActivityPointRewards, writer.WriteInt32, 0)
	Base.WriteList(writer, val.FinishedOrders, Base.WriteComplexWrap(Auto.WriteTruckJobOrderWrap, "TruckJobOrderWrap", false), nil, "FinishedOrders", false, 0, nil)
end

function Auto.WriteClientFormationMember(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Offset, Auto.WriteUXVector3, "Offset")
end

function Auto.WriteClientFormationStructureUpdate(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TraceType, writer.WriteByte, 0)
	Base.WriteList(writer, val.Members, Base.WriteComplexWrap(Auto.WriteClientFormationMember, "ClientFormationMember", false), nil, "Members", false, 0, nil)
end

function Auto.WriteClientFpsInfo(writer, val)
	writer:WriteString(val.fps_list, false, "fps_list", 1024)
	writer:WriteString(val.fps3_list, false, "fps3_list", 1024)
	writer:WriteString(val.fps99_list, false, "fps99_list", 1024)
	writer:WriteString(val.list_item_format, false, "list_item_format", 256)
end

function Auto.WriteClientIntersectionDebugData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ZoneIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PeriodCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CurrentPeriodIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NextPeriodIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CurrentState, writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteList(writer, val.LaneHandlesOpen, writer.WriteInt32, 0, "LaneHandlesOpen", false, 0, nil)
	Base.WriteList(writer, val.LaneVehicleCountDebugData, Base.WriteComplexWrap(Auto.WriteClientLaneVehicleCountDebugData, "ClientLaneVehicleCountDebugData", false), nil, "LaneVehicleCountDebugData", false, 0, nil)
end

function Auto.WriteClientLaneVehicleCountDebugData(writer, val)
	Base.WritePrimitive(writer, val.PedLane, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
end

function Auto.WriteClientMetroNpcInitData(writer, val)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MetroInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MetroCarriageIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

function Auto.WriteClientNpcChatData(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.InviteChatList, Base.WriteComplexWrap(Auto.WriteNpcChatItem, "NpcChatItem", false), nil, "InviteChatList", false, 0, nil)
	Base.WriteList(writer, val.DialogChatList, Base.WriteComplexWrap(Auto.WriteNpcChatItem, "NpcChatItem", false), nil, "DialogChatList", false, 0, nil)
	Base.WriteDict(writer, val.NpcChatListDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChatInfoList, "ChatInfoList", false), nil, "NpcChatListDict", false, 0)
	Base.WriteDict(writer, val.DialogChatListDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChatInfoList, "ChatInfoList", false), nil, "DialogChatListDict", false, 0)
end

function Auto.WriteClientNpcDebugDensityStatistics(writer, val)
	Base.WritePrimitive(writer, val.PedArea, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NonScaleExceptedPedNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ExceptedPedNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActualPedNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ExceptedStaticNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActualStaticNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActualVehicleNpcNum, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActualMetroNpcNum, writer.WriteSingle, 0)
end

function Auto.WriteClientNpcGroupChatData(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.InviteChatList, Base.WriteComplexWrap(Auto.WriteNpcChatItem, "NpcChatItem", false), nil, "InviteChatList", false, 0, nil)
	Base.WriteList(writer, val.DialogChatList, Base.WriteComplexWrap(Auto.WriteNpcChatItem, "NpcChatItem", false), nil, "DialogChatList", false, 0, nil)
	Base.WriteList(writer, val.Members, writer.WriteUInt32, 0, "Members", false, 0, nil)
	Base.WriteDict(writer, val.NpcChatListDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChatInfoList, "ChatInfoList", false), nil, "NpcChatListDict", false, 0)
	Base.WriteDict(writer, val.DialogChatListDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChatInfoList, "ChatInfoList", false), nil, "DialogChatListDict", false, 0)
end

function Auto.WriteClientNpcMoveData(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

function Auto.WriteClientNpcPlayAnimationData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteDouble, 0)
end

function Auto.WriteClientPedData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.ActionId, writer.WriteInt32, 0)
end

function Auto.WriteClientQualitySetting(writer, val)
	writer:WriteString(val.setting, false, "setting", 1024)
end

function Auto.WriteClientStaticNpcInitData(writer, val)
	Base.WritePrimitive(writer, val.StaticNpcInfoId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentPersonaId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PoiActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UrbanDiversityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IgnoreAllStim, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TaskRelated, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.EnableHack, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NpcPid, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.AgentSyncClientInfo, Auto.WriteAgentSyncClientInfo, "AgentSyncClientInfo", true)
	Base.WritePrimitive(writer, val.LookAtDecisionRulesId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ForceGo, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SourceType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

function Auto.WriteClientStaticVehicleInitData(writer, val)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ColorConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DamageStatusId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Timestamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.NotDrive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RotationX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationW, writer.WriteSingle, 0)
	Base.WriteList(writer, val.Parts, Base.WriteStructWrap(Auto.WriteVehicleClientPart, "Parts"), nil, "Parts", true, 0, nil)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

function Auto.WriteClientTeamInfo(writer, val)
	Base.WritePrimitive(writer, val.TeamId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LeaderPid, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.Members, Base.WriteComplexWrap(Auto.WritePlayerBasicInfoVO, "PlayerBasicInfoVO", false), nil, "Members", false, 0, nil)
	Base.WriteComplex(writer, val.Setting, Auto.WriteTeamSetting, "Setting", false)
end

function Auto.WriteClientTrafficIntersectionInitInfo(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ZoneIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteList(writer, val.TrafficLightInfos, Base.WriteStructWrap(Auto.WriteTrafficLightInfo, "TrafficLightInfos"), nil, "TrafficLightInfos", false, 0, nil)
	Base.WriteList(writer, val.PeriodControlInfos, Base.WriteStructWrap(Auto.WriteTrafficLightPeriodControlInfo, "PeriodControlInfos"), nil, "PeriodControlInfos", false, 0, nil)
	Base.WritePrimitive(writer, val.CurrentPeriodIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NextPeriodIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.RailPeriodIndex, writer.WriteByte, 0)
end

function Auto.WriteClientTrafficIntersectionPeriodUpdateInfo(writer, val)
	Base.WritePrimitive(writer, val.IntersectionIndex, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CurrentState, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentPeriodIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NextPeriodIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.RailPeriodIndex, writer.WriteByte, 0)
end

function Auto.WriteClientTruckOrderView(writer, val)
	Base.WriteList(writer, val.Orders, Base.WriteComplexWrap(Auto.WriteTruckJobOrderWrap, "TruckJobOrderWrap", false), nil, "Orders", false, 0, nil)
	Base.WritePrimitive(writer, val.RewardPointSum, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CustomerSatisfactionAverage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CurrentOrderId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TruckGuideClicked, writer.WriteBoolean, false)
	Base.WriteDict(writer, val.EventIdToAgent, writer.WriteUInt32, writer.WriteUInt64, 0, "EventIdToAgent", false, 0)
	Base.WritePrimitive(writer, val.AutoAccept, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DefaultVehicleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalIncome, writer.WriteInt32, 0)
end

function Auto.WriteClientVehicleBuffData(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.BuffConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EffectChangeEndTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteDouble, 0)
end

function Auto.WriteClientVehicleData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.ActionId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DistanceAlongLane, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NextLaneHandle, writer.WriteInt32, 0)
end

function Auto.WriteClientVehicleDebugData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	writer:WriteString(val.VehicleLogicType, false, "VehicleLogicType", 0)
	writer:WriteString(val.CurrentVehicleStatus, false, "CurrentVehicleStatus", 0)
	Base.WritePrimitive(writer, val.CurrentLaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NextLaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DistanceToAvoid, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NextVehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NextMergingVehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NextSplittingVehicleId, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.FindIdList, writer.WriteUInt32, 0, "FindIdList", false, 0, nil)
end

function Auto.WriteClientVehicleInitData(writer, val)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleColorId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleLightState, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DistanceAlongLane, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NextVehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Timestamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.ControlType, writer.WriteByte, 0)
	Base.WriteList(writer, val.Parts, Base.WriteStructWrap(Auto.WriteVehicleClientPart, "Parts"), nil, "Parts", true, 0, nil)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

function Auto.WriteClientVehicleLaneChangeData(writer, val)
	Base.WriteStruct(writer, val.VehicleLaneData, Auto.WriteClientVehicleLaneData, "VehicleLaneData")
	Base.WritePrimitive(writer, val.LaneHandleInitial, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LaneHandleFinal, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BeginDistanceAloneLaneInitial, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BeginDistanceAloneLaneFinal, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EndDistanceAlongLaneFinal, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DistanceBetweenLanes, writer.WriteSingle, 0)
end

function Auto.WriteClientVehicleLaneData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DistanceAlongLane, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Status, writer.WriteByte, 0)
end

function Auto.WriteClientVehicleLaneDebugData(writer, val)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.LaneLength, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SpaceAvailable, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NumVehicleOnLane, writer.WriteInt32, 0)
end

function Auto.WriteClientVehicleNpcInitData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BindVehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
end

function Auto.WriteClientVehiclePartStatus(writer, val)
	Base.WritePrimitive(writer, val.PartType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.OpenOrClose, writer.WriteBoolean, false)
end

function Auto.WriteClientZoneGraphPath(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetLocationReason, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt16, 0)
	Base.WriteList(writer, val.Points, Base.WriteStructWrap(Auto.WriteClientZoneGraphPathPoint, "Points"), nil, "Points", false, 0, nil)
end

function Auto.WriteClientZoneGraphPathFollowDown(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt16, 0)
end

function Auto.WriteClientZoneGraphPathPoint(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteByteAngle, "Facing")
end

function Auto.WriteCommonActivityInfo(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
end

function Auto.WriteCommonCompetitionSeasonInfo(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
end

function Auto.WriteCompetitionSeasonChallengeInfo(writer, val)
	Base.WritePrimitive(writer, val.ChallengeCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HistoryHighestStars, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LastStars, writer.WriteInt32, 0)
end

function Auto.WriteCompetitionSeasonGamePlayInfo(writer, val)
	Base.WritePrimitive(writer, val.GamePlayCfgId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ChallengeDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteCompetitionSeasonChallengeInfo, "CompetitionSeasonChallengeInfo", false), nil, "ChallengeDict", false, 0)
	Base.WritePrimitive(writer, val.Stars, writer.WriteInt32, 0)
end

function Auto.WriteCompetitionSeasonInfo(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.GameplayDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteCompetitionSeasonGamePlayInfo, "CompetitionSeasonGamePlayInfo", false), nil, "GameplayDict", false, 0)
	Base.WriteList(writer, val.AwardList, writer.WriteUInt32, 0, "AwardList", false, 0, nil)
	Base.WritePrimitive(writer, val.IsFinish, writer.WriteBoolean, false)
end

function Auto.WriteComputerDetailInfo(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FirstOpenTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.DeleteFiles, writer.WriteUInt32, 0, "DeleteFiles", false, 0, nil)
	Base.WriteList(writer, val.DeleteEmails, writer.WriteUInt32, 0, "DeleteEmails", false, 0, nil)
end

function Auto.WriteComputerEmail(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRead, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
end

function Auto.WriteComputerFile(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRead, writer.WriteBoolean, false)
end

function Auto.WriteComputerUnlockInfo(writer, val)
	Base.WriteDict(writer, val.UnlockEmails, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteComputerEmail, "ComputerEmail", false), nil, "UnlockEmails", true, 0)
	Base.WriteDict(writer, val.UnlockFiles, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteComputerFile, "ComputerFile", false), nil, "UnlockFiles", true, 0)
	Base.WriteDict(writer, val.ComputerInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteComputerDetailInfo, "ComputerDetailInfo", false), nil, "ComputerInfos", true, 0)
end

function Auto.WriteControlFlowData(writer, val)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataBoolean(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataCustom(writer, val)
	writer:WriteString(val.V, false, "V", 0)
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataDebug(writer, val)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WriteList(writer, val.CurrentNodeIds, writer.WriteInt32, 0, "CurrentNodeIds", false, 0, nil)
	Base.WriteList(writer, val.CompleteNodeIds, writer.WriteInt32, 0, "CompleteNodeIds", false, 0, nil)
	Base.WriteList(writer, val.ErrorNodeIds, writer.WriteInt32, 0, "ErrorNodeIds", false, 0, nil)
	Base.WriteDict(writer, val.ResultNodeIds, writer.WriteInt32, Base.WriteStringWrap(false, "ResultNodeIds", 0), nil, "ResultNodeIds", false, 0)
end

function Auto.WriteControlFlowDataDouble(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataInteger(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataString(writer, val)
	writer:WriteString(val.V, false, "V", 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataUInteger(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataUlong(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataUnit(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataVector(writer, val)
	Base.WriteStruct(writer, val.V, Auto.WriteUXVector3, "V")
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteControlFlowDataVehicle(writer, val)
	Base.WritePrimitive(writer, val.V, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PortId, writer.WriteInt32, 0)
end

function Auto.WriteCreateRoleInitInfo(writer, val)
	Base.WritePrimitive(writer, val.Sex, writer.WriteByte, 0)
	writer:WriteString(val.Name, false, "Name", 256)
	Base.WriteList(writer, val.Config, writer.WriteByte, 0, "Config", false, 1024, nil)
end

function Auto.WriteCreationEnterLeave(writer, val)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CreationId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.EventType, writer.WriteByte, 0)
end

function Auto.WriteCreationHitData(writer, val)
	Base.WritePrimitive(writer, val.CreationId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetDestructible, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ShieldDefendIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HurtStiffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StiffTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HurtEffectId, writer.WriteUInt32, 0)
end

function Auto.WriteCreationMoveData(writer, val)
	Base.WritePrimitive(writer, val.CreationId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
end

function Auto.WriteCreditInfo(writer, val)
	Base.WritePrimitive(writer, val.Credit, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ClaimedLevelRewards, writer.WriteUInt32, writer.WriteBoolean, false, "ClaimedLevelRewards", false, 0)
end

function Auto.WriteCruiseParameters(writer, val)
	Base.WriteList(writer, val.TargetPointList, Base.WriteStructWrap(Auto.WriteUXVector3, "TargetPointList"), nil, "TargetPointList", false, 0, nil)
	Base.WritePrimitive(writer, val.CruiseType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.configFlags, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.pathFindFlags, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetType, writer.WriteByte, 0)
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
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteCubeCoord(writer, val)
	Base.WritePrimitive(writer, val.q, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.r, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.s, writer.WriteInt32, 0)
end

function Auto.WriteCurveMoveData(writer, val)
	Base.WritePrimitive(writer, val.CurveType, writer.WriteByte, 0)
	Base.WriteStruct(writer, val.StartPoint, Auto.WriteUXVector3, "StartPoint")
	Base.WriteStruct(writer, val.AuxiliaryPoint, Auto.WriteUXVector3, "AuxiliaryPoint")
	Base.WriteStruct(writer, val.EndPoint, Auto.WriteUXVector3, "EndPoint")
	Base.WritePrimitive(writer, val.CircleMoveRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
end

function Auto.WriteCustomCommonData(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt32, 0)
	writer:WriteString(val.StringData, false, "StringData", 10240)
	Base.WriteBuffer(writer, val.BinaryData, "BinaryData", false, 10240, nil)
end

function Auto.WriteDSBuffData(writer, val)
	Base.WritePrimitive(writer, val.BuffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteDouble, 0)
end

function Auto.WriteDSDamageData(writer, val)
	Base.WriteList(writer, val.SpiritDatas, Base.WriteComplexWrap(Auto.WriteDSSpiritDamageData, "DSSpiritDamageData", false), nil, "SpiritDatas", false, 0, nil)
	Base.WriteList(writer, val.ElementDatas, Base.WriteComplexWrap(Auto.WriteDSElementDamageData, "DSElementDamageData", false), nil, "ElementDatas", false, 0, nil)
end

function Auto.WriteDSElementDamageData(writer, val)
	Base.WritePrimitive(writer, val.ElementId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Damage, writer.WriteSingle, 0)
end

function Auto.WriteDSSkillHitDamageData(writer, val)
	Base.WritePrimitive(writer, val.HitTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Damage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsCritical, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Error, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.Attrs, writer.WriteSingle, 0, "Attrs", false, 0, nil)
	Base.WriteList(writer, val.Buffs, writer.WriteUInt32, 0, "Buffs", false, 0, nil)
end

function Auto.WriteDSSkillHitDataList(writer, val)
	Base.WritePrimitive(writer, val.SKillId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.SkillDamageList, Base.WriteComplexWrap(Auto.WriteDSSkillHitDamageData, "DSSkillHitDamageData", false), nil, "SkillDamageList", false, 0, nil)
end

function Auto.WriteDSSpiritDamageData(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalDamage, writer.WriteSingle, 0)
	Base.WriteDict(writer, val.SkillDamageRecords, writer.WriteInt32, Base.WriteComplexWrap(Auto.WriteDSSkillHitDataList, "DSSkillHitDataList", false), nil, "SkillDamageRecords", false, 0)
	Base.WriteDict(writer, val.BuffRecords, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteDSBuffData, "DSBuffData", false), nil, "BuffRecords", false, 0)
end

function Auto.WriteDailyHackerCounts(writer, val)
	Base.WritePrimitive(writer, val.Money, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Fan, writer.WriteInt32, 0)
end

function Auto.WriteDamageData(writer, val)
	Base.WritePrimitive(writer, val.SourceAmount, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FromType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SourceTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CreationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BuffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpecialEffects, writer.WriteByte, 0)
	Base.WriteStruct(writer, val.ClientHitPosition, Auto.WriteUXVector3, "ClientHitPosition")
	Base.WritePrimitive(writer, val.ElementType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HitIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HpDecreased, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Amount, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ShieldDecreased, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ShieldIndex, writer.WriteInt32, 0)
end

function Auto.WriteDancePlayResult(writer, val)
	Base.WritePrimitive(writer, val.StayElapsedTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlayElapsedTime, writer.WriteUInt32, 0)
end

function Auto.WriteDartParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.DartId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteDartScoreInfo(writer, val)
	Base.WriteDict(writer, val.ParticipantScoreDic, writer.WriteInt32, writer.WriteInt32, 0, "ParticipantScoreDic", true, 0)
	Base.WritePrimitive(writer, val.CurrentScoreIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CurrentScore, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.CurrentScorePos, Auto.WriteUXVector3, "CurrentScorePos")
	Base.WritePrimitive(writer, val.Winner, writer.WriteInt32, 0)
end

function Auto.WriteDartZoneInfo(writer, val)
	Base.WritePrimitive(writer, val.GameType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurn, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.ScoreInfo, Auto.WriteDartScoreInfo, "ScoreInfo", false)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StartReason, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SyncReason, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ZoneType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ZoneState, writer.WriteByte, 0)
	Base.WriteList(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
end

function Auto.WriteDebugBattleElementData(writer, val)
	Base.WritePrimitive(writer, val.ElementId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Damage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DamageMin, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DamageMax, writer.WriteSingle, 0)
end

function Auto.WriteDebugBattleSpiritData(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalDamage, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FightStateTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.FightBeginTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.ActiveTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.ActiveBeginTime, writer.WriteDouble, 0)
	Base.WriteDict(writer, val.SkillDamages, writer.WriteUInt32, writer.WriteSingle, 0, "SkillDamages", false, 0)
	Base.WriteDict(writer, val.SkillCounts, writer.WriteUInt32, writer.WriteInt32, 0, "SkillCounts", false, 0)
	Base.WriteDict(writer, val.SkillDamageCounts, writer.WriteUInt32, writer.WriteInt32, 0, "SkillDamageCounts", false, 0)
	Base.WriteDict(writer, val.SkillDamagesMin, writer.WriteUInt32, writer.WriteSingle, 0, "SkillDamagesMin", false, 0)
	Base.WriteDict(writer, val.SkillDamagesMax, writer.WriteUInt32, writer.WriteSingle, 0, "SkillDamagesMax", false, 0)
	Base.WriteDict(writer, val.ExtraBuffDamages, writer.WriteUInt32, writer.WriteSingle, 0, "ExtraBuffDamages", false, 0)
	Base.WriteDict(writer, val.BuffTimes, writer.WriteUInt32, writer.WriteDouble, 0, "BuffTimes", false, 0)
	Base.WriteDict(writer, val.BuffBeginTimes, writer.WriteUInt32, writer.WriteDouble, 0, "BuffBeginTimes", false, 0)
	Base.WriteDict(writer, val.BuffRefCounts, writer.WriteUInt32, writer.WriteInt32, 0, "BuffRefCounts", false, 0)
end

function Auto.WriteDebugBattleStatistics(writer, val)
	Base.WritePrimitive(writer, val.Now, writer.WriteDouble, 0)
	Base.WriteList(writer, val.Spirits, Base.WriteComplexWrap(Auto.WriteDebugBattleSpiritData, "DebugBattleSpiritData", false), nil, "Spirits", false, 0, nil)
	Base.WriteList(writer, val.Elements, Base.WriteComplexWrap(Auto.WriteDebugBattleElementData, "DebugBattleElementData", false), nil, "Elements", false, 0, nil)
end

function Auto.WriteDebugFileDescription(writer, val)
	writer:WriteString(val.FullPath, true, "FullPath", 1024)
	writer:WriteString(val.Name, true, "Name", 256)
	Base.WritePrimitive(writer, val.IsDirectory, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Size, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WriteTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AccessTime, writer.WriteUInt32, 0)
end

function Auto.WriteDebugFileResult(writer, val)
	Base.WriteComplex(writer, val.PersistentDataPath, Auto.WriteDebugFileDescription, "PersistentDataPath", false)
	Base.WriteComplex(writer, val.TemporaryCachePath, Auto.WriteDebugFileDescription, "TemporaryCachePath", false)
	Base.WriteComplex(writer, val.StreamingAssetsPath, Auto.WriteDebugFileDescription, "StreamingAssetsPath", false)
	Base.WriteComplex(writer, val.DataPath, Auto.WriteDebugFileDescription, "DataPath", false)
	Base.WriteComplex(writer, val.ConsoleLogPath, Auto.WriteDebugFileDescription, "ConsoleLogPath", false)
	Base.WriteComplex(writer, val.VirtualFileSystem, Auto.WriteDebugFileDescription, "VirtualFileSystem", false)
end

function Auto.WriteDebugNpcBvbSelectPokemonData(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.q, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.r, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.s, writer.WriteInt32, 0)
end

function Auto.WriteDeriveCreationData(writer, val)
	Base.WritePrimitive(writer, val.CreationId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DeriveId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

function Auto.WriteDestructibleBrokenInfo(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Stage, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BrokenType, writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
end

function Auto.WriteDestructibleGridAOIIncrease(writer, val)
	Base.WriteStruct(writer, val.PlayerStandardIndex, Auto.WriteGridIndex, "PlayerStandardIndex")
	Base.WriteList(writer, val.addInfos, Base.WriteComplexWrap(Auto.WriteDestructibleInfo, "DestructibleInfo", true), nil, "addInfos", true, 0, nil)
	Base.WriteList(writer, val.indexList, Base.WriteStructWrap(Auto.WriteGridIndex, "indexList"), nil, "indexList", true, 0, nil)
	Base.WriteList(writer, val.addUniqueIds, writer.WriteUInt64, 0, "addUniqueIds", true, 0, nil)
	Base.WriteList(writer, val.removeIds, writer.WriteUInt64, 0, "removeIds", true, 0, nil)
	Base.WritePrimitive(writer, val.reason, writer.WriteByte, 0)
end

function Auto.WriteDestructibleInfo(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Hp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NavId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BreakStage, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.OccupantInfos, Base.WriteStructWrap(Auto.WriteSceneItemOccupantInfo, "OccupantInfos"), nil, "OccupantInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.DropWeaponId, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.EffectIds, writer.WriteInt32, 0, "EffectIds", true, 0, nil)
end

function Auto.WriteDestructibleSyncInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Frame, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WriteStruct(writer, val.Speed, Auto.WriteUXVector3, "Speed")
	Base.WritePrimitive(writer, val.Hp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.mindState, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.HookUnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SceneItemType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HostPlayerID, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ClientLocalTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.CompressSceneItemData, writer.WriteByte, 0, "CompressSceneItemData", true, 1024, val.CompressSceneItemDataLength)
	Base.WritePrimitive(writer, val.CompressSceneItemDataLength, writer.WriteInt32, 0)
end

function Auto.WriteDialogAreaInfo(writer, val)
	Base.WriteList(writer, val.VertexPoints, Base.WriteStructWrap(Auto.WriteUXVector3, "VertexPoints"), nil, "VertexPoints", true, 0, nil)
	Base.WriteStruct(writer, val.CenterPos, Auto.WriteUXVector3, "CenterPos")
	Base.WritePrimitive(writer, val.SphereRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.XMagnitude, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.YMagnitude, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ZMagnitude, writer.WriteSingle, 0)
end

function Auto.WriteDialogParameter(writer, val)
	Base.WritePrimitive(writer, val.Reason, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NpcTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcInstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.AgentPosition, Auto.WriteUXVector3, "AgentPosition")
	Base.WritePrimitive(writer, val.BlackContinue, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FromTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FromEventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FromClient, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DialogCameraSpawnId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpoonNodeId, writer.WriteInt32, 0)
end

function Auto.WriteDisableBadgeInfo(writer, val)
	Base.WriteDict(writer, val.BadgeId2CountDict, writer.WriteUInt32, writer.WriteInt32, 0, "BadgeId2CountDict", false, 0)
end

function Auto.WriteDivinerCustomerInfo(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AgentCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DemandId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PersonalityId, writer.WriteUInt32, 0)
	writer:WriteString(val.SessionId, false, "SessionId", 0)
	Base.WritePrimitive(writer, val.Attitude, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BranchId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Persuasion, writer.WriteUInt32, 0)
	writer:WriteString(val.Target, false, "Target", 0)
	Base.WritePrimitive(writer, val.Success_Persuasion, writer.WriteUInt32, 0)
	writer:WriteString(val.Endings, false, "Endings", 0)
	Base.WritePrimitive(writer, val.Stage, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsInGame, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Faction, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AppealTimeEnd, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PersuadeTimeEnd, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndReason, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Result, writer.WriteInt32, 0)
	Base.WriteList(writer, val.Clues, writer.WriteUInt32, 0, "Clues", false, 0, nil)
end

function Auto.WriteDivinerPersuasionResult(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Stage, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Result, writer.WriteInt32, 0)
	writer:WriteString(val.Msg, false, "Msg", 0)
	Base.WritePrimitive(writer, val.ClueId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Attitude, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Persuasion, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndReason, writer.WriteInt32, 0)
end

function Auto.WriteDoctorCheckCureData(writer, val)
	Base.WriteList(writer, val.CureList, writer.WriteUInt32, 0, "CureList", false, 0, nil)
end

function Auto.WriteDoctorCheckData(writer, val)
	Base.WritePrimitive(writer, val.CureLimit, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.DiseaseList, writer.WriteUInt32, 0, "DiseaseList", false, 0, nil)
	Base.WriteList(writer, val.DialogList, writer.WriteUInt32, 0, "DialogList", false, 0, nil)
	Base.WriteList(writer, val.CureInfo, Base.WriteComplexWrap(Auto.WriteDoctorCheckCureData, "DoctorCheckCureData", false), nil, "CureInfo", false, 0, nil)
end

function Auto.WriteDrivingBehaviorRecord(writer, val)
	Base.WritePrimitive(writer, val.TimeStamp, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.RotationX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RotationW, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Velocity, Auto.WriteUXVector3, "Velocity")
	Base.WriteStruct(writer, val.AngVelocity, Auto.WriteUXVector3, "AngVelocity")
	Base.WritePrimitive(writer, val.SteerInput, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ThrottleInput, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BrakeInput, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HandbrakeInput, writer.WriteSingle, 0)
end

function Auto.WriteDrivingBehaviorRecords(writer, val)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ControlType, writer.WriteByte, 0)
	Base.WriteList(writer, val.Records, Base.WriteComplexWrap(Auto.WriteDrivingBehaviorRecord, "DrivingBehaviorRecord", false), nil, "Records", false, 256, nil)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
end

function Auto.WriteDropBelongingData(writer, val)
	Base.WritePrimitive(writer, val.BelongingId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OwnerId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

function Auto.WriteDropLimitInfo(writer, val)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FinishTime, writer.WriteUInt32, 0)
end

function Auto.WriteDynamicDestructibleData(writer, val)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.LivingTime, writer.WriteSingle, 0)
end

function Auto.WriteDynamicDestructibleInfo(writer, val)
	Base.WriteComplex(writer, val.Pack, Auto.WritePackedDestructibleInfo, "Pack", true)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CreateAgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CreateSkillInstanceId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CreateIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MergeAgentInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NoSleep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Hp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NavId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BreakStage, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.OccupantInfos, Base.WriteStructWrap(Auto.WriteSceneItemOccupantInfo, "OccupantInfos"), nil, "OccupantInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.DropWeaponId, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.EffectIds, writer.WriteInt32, 0, "EffectIds", true, 0, nil)
end

function Auto.WriteEdictDebugInfo(writer, val)
	Base.WritePrimitive(writer, val.isShort, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ownerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.giveTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.canGiveTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.needRemove, writer.WriteBoolean, false)
end

function Auto.WriteEffectSyncData(writer, val)
	Base.WriteList(writer, val.Bytes, writer.WriteByte, 0, "Bytes", false, 1024, nil)
end

function Auto.WriteEmojiData(writer, val)
	writer:WriteString(val.Id, false, "Id", 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

function Auto.WriteEndItemDropInfo(writer, val)
	Base.WritePrimitive(writer, val.enemyInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.bindItemsIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.itemRotation, Auto.WriteUXVector3, "itemRotation")
	Base.WriteStruct(writer, val.itemPosition, Auto.WriteUXVector3, "itemPosition")
end

function Auto.WriteEnemyDieInfo(writer, val)
	Base.WritePrimitive(writer, val.HasDieAnimation, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HasDieEffect, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DieEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DelayDestroyDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LastHitHurtEffect, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DeadlySkillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Killer, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.HasPlayedDeathSkill, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.WeaponDropDestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DieType, writer.WriteByte, 0)
end

function Auto.WriteEnemyItemDropInfo(writer, val)
	Base.WritePrimitive(writer, val.BindItemsIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.DropState, writer.WriteByte, 0)
end

function Auto.WriteEnemyMoveFinishData(writer, val)
	Base.WritePrimitive(writer, val.EnemyId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsFailure, writer.WriteBoolean, false)
end

function Auto.WriteEnemyWeaponState(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsHoldingWeapon, writer.WriteBoolean, false)
end

function Auto.WriteEnterGameData(writer, val)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.Token, Auto.WriteTokenInfo, "Token", false)
end

function Auto.WriteEnterSceneInfo(writer, val)
	Base.WritePrimitive(writer, val.PlayerSessionId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WriteList(writer, val.SpoonLevels, Base.WriteStringWrap(false, "SpoonLevels", 0), nil, "SpoonLevels", false, 0, nil)
	Base.WriteList(writer, val.SpoonMd5s, Base.WriteStringWrap(false, "SpoonMd5s", 0), nil, "SpoonMd5s", false, 0, nil)
	Base.WriteList(writer, val.Spirits, Base.WriteStructWrap(Auto.WriteSpiritInitData, "Spirits"), nil, "Spirits", false, 0, nil)
	Base.WriteStruct(writer, val.GridInfo, Auto.WriteServerSimpleGridInfo, "GridInfo")
	Base.WritePrimitive(writer, val.MatchGameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SwitchShowId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsSwitchSpiritShow, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SectorControlId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.LoadingType, Auto.WriteLoadingTypeInfo, "LoadingType", false)
end

function Auto.WriteEventIdInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventType, writer.WriteByte, 0)
end

function Auto.WriteEventPanelInfo(writer, val)
	Base.WriteList(writer, val.EventsInfo, Base.WriteComplexWrap(Auto.WriteTaskEventInfo, "TaskEventInfo", false), nil, "EventsInfo", false, 0, nil)
end

function Auto.WriteEventProgress(writer, val)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ProgressDict, writer.WriteUInt32, writer.WriteUInt32, 0, "ProgressDict", true, 0)
end

function Auto.WriteEventProgressInfo(writer, val)
	Base.WriteDict(writer, val.EventProgressDict, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteEventProgress, "EventProgress", false), nil, "EventProgressDict", false, 0)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt32, 0)
end

function Auto.WriteEventSpoonViewInfo(writer, val)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	writer:WriteString(val.SpoonMd5, false, "SpoonMd5", 0)
end

function Auto.WriteFactionChangeInfo(writer, val)
	Base.WritePrimitive(writer, val.FactionId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.NewInfo, Auto.WriteFactionInfo, "NewInfo", false)
	Base.WriteComplex(writer, val.OldInfo, Auto.WriteFactionInfo, "OldInfo", false)
end

function Auto.WriteFactionInfo(writer, val)
	Base.WritePrimitive(writer, val.Disposition, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DispositionLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Influence, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.InteractionCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GreetCount, writer.WriteUInt32, 0)
end

function Auto.WriteFansAutoGiveHistory(writer, val)
	Base.WritePrimitive(writer, val.GiveTime, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.GiveCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Reason, writer.WriteByte, 0)
end

function Auto.WriteFashionColoringInfo(writer, val)
	Base.WriteDict(writer, val.ColoringType2ColorIdDict, writer.WriteByte, writer.WriteUInt32, 0, "ColoringType2ColorIdDict", false, 0)
end

function Auto.WriteFashionColoringSchemeInfo(writer, val)
	Base.WritePrimitive(writer, val.FashionId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.FashionColoringSchemeInfoDict, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteFashionColoringInfo, "FashionColoringInfo", false), nil, "FashionColoringSchemeInfoDict", false, 0)
end

function Auto.WriteFashionCustomSuitSchemeInfo(writer, val)
	writer:WriteString(val.SchemeName, true, "SchemeName", 6)
	Base.WritePrimitive(writer, val.JoinRandomPool, writer.WriteBoolean, false)
	Base.WriteList(writer, val.WearFashionInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionInfo, "WearFashionInfo", false), nil, "WearFashionInfoList", false, 32, nil)
	Base.WriteList(writer, val.WearFashionEditInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "WearFashionEditInfoList", true, 32, nil)
	Base.WritePrimitive(writer, val.HiddenParts, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EditedHiddenParts, writer.WriteByte, 0)
end

function Auto.WriteFashionFunctionSuitSchemeInfo(writer, val)
	Base.WriteList(writer, val.WearFashionInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionInfo, "WearFashionInfo", false), nil, "WearFashionInfoList", false, 32, nil)
	Base.WriteList(writer, val.WearFashionEditInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "WearFashionEditInfoList", true, 32, nil)
	Base.WritePrimitive(writer, val.HiddenParts, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EditedHiddenParts, writer.WriteByte, 0)
end

function Auto.WriteFashionInfo(writer, val)
	Base.WritePrimitive(writer, val.FashionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpiredTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.GainTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Status, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ApplyColoringSchemeId, writer.WriteByte, 0)
	Base.WriteDict(writer, val.ColoringSchemeInfoDict, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteFashionColoringInfo, "FashionColoringInfo", false), nil, "ColoringSchemeInfoDict", false, 0)
end

function Auto.WriteFightGamePlayerSimpleInfo(writer, val)
	Base.WritePrimitive(writer, val.WithAi, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsObserver, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Is1P, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsMaster, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.PlayerUnitInfo, Auto.WriteFightGameUnitInfo, "PlayerUnitInfo", true)
	Base.WriteComplex(writer, val.AiUnitInfo, Auto.WriteFightGameUnitInfo, "AiUnitInfo", true)
end

function Auto.WriteFightGameResult(writer, val)
	Base.WritePrimitive(writer, val.WinnerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RoundLeft, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.WaitEndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsWithAi, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsAiWin, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayerWin, writer.WriteBoolean, false)
end

function Auto.WriteFightGameStateInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PosX, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PosY, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Face, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Hp, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.AngryValue, writer.WriteInt32, 0)
end

function Auto.WriteFightGameUnitInfo(writer, val)
	Base.WritePrimitive(writer, val.IsAi, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RoleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DeadCount, writer.WriteInt32, 0)
	writer:WriteString(val.CurrentAction, false, "CurrentAction", 0)
	Base.WriteComplex(writer, val.State, Auto.WriteFightGameStateInfo, "State", false)
end

function Auto.WriteFightGroupDebugInfo(writer, val)
	Base.WritePrimitive(writer, val.configId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.uIds, writer.WriteUInt64, 0, "uIds", false, 0, nil)
	Base.WriteList(writer, val.normalEdicts, Base.WriteStructWrap(Auto.WriteEdictDebugInfo, "normalEdicts"), nil, "normalEdicts", false, 0, nil)
	Base.WriteList(writer, val.extraEdicts, Base.WriteStructWrap(Auto.WriteEdictDebugInfo, "extraEdicts"), nil, "extraEdicts", false, 0, nil)
end

function Auto.WriteFightPokemon(writer, val)
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

function Auto.WriteFireworkBuyInfo(writer, val)
	Base.WritePrimitive(writer, val.FireworkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlanId, writer.WriteUInt32, 0)
end

function Auto.WriteFireworkPlanInfo(writer, val)
	Base.WritePrimitive(writer, val.PlanId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NewUnlock, writer.WriteBoolean, false)
end

function Auto.WriteFireworkStoreInfo(writer, val)
	Base.WriteList(writer, val.PlanInfos, Base.WriteComplexWrap(Auto.WriteFireworkPlanInfo, "FireworkPlanInfo", false), nil, "PlanInfos", false, 256, nil)
end

function Auto.WriteFishDestructibleData(writer, val)
	Base.WritePrimitive(writer, val.FishGroupId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.LivingTime, writer.WriteSingle, 0)
end

function Auto.WriteFloat3(writer, val)
	Base.WritePrimitive(writer, val.x, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.y, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.z, writer.WriteSingle, 0)
end

function Auto.WriteFloatingMoveData(writer, val)
	Base.WritePrimitive(writer, val.unitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.moveTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.speed, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.targetPos, Auto.WriteUXVector3, "targetPos")
	Base.WritePrimitive(writer, val.moveId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.speedCurveId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.targetId, writer.WriteUInt64, 0)
end

function Auto.WriteFollowRecordingParameters(writer, val)
	Base.WritePrimitive(writer, val.PathId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FollowType, writer.WriteByte, 0)
	writer:WriteString(val.recordingFileName, false, "recordingFileName", 0)
	Base.WritePrimitive(writer, val.TargetType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Step, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MinSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.FarAwayCheck, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.FarAwayThrehold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CloseToCheck, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CloseToThrehold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AdjustTime, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.PathOffset, Auto.WriteUXVector3, "PathOffset")
	Base.WritePrimitive(writer, val.guideMinDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.guideMaxDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.guideMinSpeedThreshold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.guideMaxSpeedThreshold, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CheckStuckTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteFormationPlayerSlot(writer, val)
	Base.WritePrimitive(writer, val.Row, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Col, writer.WriteInt32, 0)
end

function Auto.WriteFriendSimpleData(writer, val)
	Base.WritePrimitive(writer, val.IsRejectAllFriendApply, writer.WriteBoolean, false)
	Base.WriteList(writer, val.BlackList, writer.WriteUInt64, 0, "BlackList", false, 0, nil)
	Base.WriteList(writer, val.FriendRelationList, Base.WriteComplexWrap(Auto.WriteRelationVO, "RelationVO", false), nil, "FriendRelationList", false, 0, nil)
	Base.WriteList(writer, val.SpecialList, writer.WriteUInt64, 0, "SpecialList", false, 0, nil)
end

function Auto.WriteFurnitureInfo(writer, val)
	Base.WritePrimitive(writer, val.FurnitureId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PlacedCount, writer.WriteUInt32, 0)
end

function Auto.WriteGadgetDestructibleInfo(writer, val)
	Base.WritePrimitive(writer, val.GadgetInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Hp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NavId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BreakStage, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.OccupantInfos, Base.WriteStructWrap(Auto.WriteSceneItemOccupantInfo, "OccupantInfos"), nil, "OccupantInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.DropWeaponId, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.EffectIds, writer.WriteInt32, 0, "EffectIds", true, 0, nil)
end

function Auto.WriteGadgetEntityInfo(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WriteDict(writer, val.StateIndexDic, writer.WriteInt32, writer.WriteInt32, 0, "StateIndexDic", true, 0)
	Base.WriteDict(writer, val.ValueIndexDic, writer.WriteInt32, Base.WriteStringWrap(false, "ValueIndexDic", 0), nil, "ValueIndexDic", true, 0)
	Base.WriteList(writer, val.Occupants, writer.WriteUInt64, 0, "Occupants", true, 0, nil)
	Base.WriteList(writer, val.OccupantInfos, Base.WriteStructWrap(Auto.WriteSceneItemOccupantInfo, "OccupantInfos"), nil, "OccupantInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.LinkOccupiedId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MetroLineId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MetroCarriageId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NavId, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.MetroLineCarriageInfo, Auto.WriteMetroLineCarriageInfo, "MetroLineCarriageInfo", true)
	Base.WriteDict(writer, val.SymbiosisGadgets, writer.WriteUInt64, writer.WriteUInt64, 0, "SymbiosisGadgets", true, 0)
	Base.WriteDict(writer, val.SymbiosisDestructibles, writer.WriteUInt64, writer.WriteUInt64, 0, "SymbiosisDestructibles", true, 0)
	Base.WriteComplex(writer, val.Pack, Auto.WritePackedGadgetInfo, "Pack", false)
	Base.WriteComplex(writer, val.MobilePlatformInfo, Auto.WriteMobilePlatformSyncInfo, "MobilePlatformInfo", true)
end

function Auto.WriteGadgetGridAOIIncrease(writer, val)
	Base.WriteList(writer, val.addInfos, Base.WriteComplexWrap(Auto.WriteGadgetEntityInfo, "GadgetEntityInfo", false), nil, "addInfos", false, 0, nil)
	Base.WriteList(writer, val.indexList, Base.WriteStructWrap(Auto.WriteGridIndex, "indexList"), nil, "indexList", false, 0, nil)
	Base.WriteList(writer, val.addUniqueIds, writer.WriteUInt64, 0, "addUniqueIds", false, 0, nil)
	Base.WriteList(writer, val.removeIds, writer.WriteUInt64, 0, "removeIds", false, 0, nil)
	Base.WriteList(writer, val.activeIds, writer.WriteUInt64, 0, "activeIds", false, 0, nil)
	Base.WriteList(writer, val.inactiveIds, writer.WriteUInt64, 0, "inactiveIds", false, 0, nil)
	Base.WritePrimitive(writer, val.reason, writer.WriteByte, 0)
end

function Auto.WriteGadgetPackSyncInfo(writer, val)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.PackedInfo, Auto.WritePackedGadgetInfo, "PackedInfo", false)
	Base.WriteDict(writer, val.SymbiosisDestructibles, writer.WriteUInt64, writer.WriteUInt64, 0, "SymbiosisDestructibles", true, 0)
end

function Auto.WriteGameGroundParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteGameGroundZoneInfo(writer, val)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StartReason, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SyncReason, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ZoneType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ZoneState, writer.WriteByte, 0)
	Base.WriteList(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
end

function Auto.WriteGameServerInfo(writer, val)
	writer:WriteString(val.ClientListenIp, false, "ClientListenIp", 0)
	Base.WritePrimitive(writer, val.ClientListenPort, writer.WriteInt32, 0)
	writer:WriteString(val.Token, false, "Token", 0)
end

function Auto.WriteGangBossFullDetails(writer, val)
	Base.WriteComplex(writer, val.full, Auto.WritePlayerInfoJobGangBoss, "full", false)
	Base.WritePrimitive(writer, val.CurrentBattleAgentCount, writer.WriteInt32, 0)
end

function Auto.WriteGangMembersInfos(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsUnlock, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.NextReviveTimeStamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.HpPercent, writer.WriteSingle, 0)
end

function Auto.WriteGmBehaviorKV(writer, val)
	writer:WriteString(val.Key, false, "Key", 0)
	writer:WriteString(val.Value, false, "Value", 0)
end

function Auto.WriteGmCreateNpcOptionData(writer, val)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
end

function Auto.WriteGmCreatePedData(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UrbanDiversityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Personality, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SexType, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.Usages, writer.WriteUInt32, 0, "Usages", true, 0, nil)
	Base.WriteList(writer, val.Crimes, writer.WriteUInt32, 0, "Crimes", true, 0, nil)
end

function Auto.WriteGmEnemyStrategyInfo(writer, val)
	Base.WriteList(writer, val.SkillIds, writer.WriteUInt32, 0, "SkillIds", false, 0, nil)
end

function Auto.WriteGmLockTargetRadius(writer, val)
	writer:WriteString(val.AiName, false, "AiName", 0)
	Base.WritePrimitive(writer, val.Radius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.BackRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LookUpAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LookDownAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EyeHeight, writer.WriteSingle, 0)
end

function Auto.WriteGmQueryObjectRoot(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	writer:WriteString(val.Name, true, "Name", 256)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsStatic, writer.WriteBoolean, false)
	writer:WriteString(val.Position, true, "Position", 256)
	writer:WriteString(val.LocalPosition, true, "LocalPosition", 256)
	writer:WriteString(val.Rotation, true, "Rotation", 256)
	writer:WriteString(val.LocalRotation, true, "LocalRotation", 256)
	writer:WriteString(val.Scale, true, "Scale", 256)
	writer:WriteString(val.LocalScale, true, "LocalScale", 256)
	writer:WriteString(val.Path, true, "Path", 1024)
	writer:WriteString(val.Layer, true, "Layer", 256)
	Base.WriteList(writer, val.Components, Base.WriteComplexWrap(Auto.WriteQueryComponentInfo, "QueryComponentInfo", true), nil, "Components", true, 10240, nil)
end

function Auto.WriteGmQuerySceneInfo(writer, val)
	writer:WriteString(val.Name, true, "Name", 256)
	Base.WriteList(writer, val.Objects, Base.WriteComplexWrap(Auto.WriteGmQuerySceneObjectInfo, "GmQuerySceneObjectInfo", false), nil, "Objects", false, 10240, nil)
end

function Auto.WriteGmQuerySceneObjectInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	writer:WriteString(val.Name, true, "Name", 256)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Leaf, writer.WriteBoolean, false)
end

function Auto.WriteGomokuParticipantInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AgentUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsReady, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPlayAgain, writer.WriteBoolean, false)
end

function Auto.WriteGomokuParticipantScoreInfo(writer, val)
	Base.WriteList(writer, val.RecordInfo, Base.WriteComplexWrap(Auto.WriteGomokuPiece, "GomokuPiece", false), nil, "RecordInfo", false, 0, nil)
end

function Auto.WriteGomokuPiece(writer, val)
	Base.WritePrimitive(writer, val.X, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Y, writer.WriteUInt32, 0)
end

function Auto.WriteGomokuScoreInfo(writer, val)
	Base.WriteDict(writer, val.GomokuParticipantDict, writer.WriteInt32, Base.WriteComplexWrap(Auto.WriteGomokuParticipantScoreInfo, "GomokuParticipantScoreInfo", false), nil, "GomokuParticipantDict", false, 0)
	Base.WritePrimitive(writer, val.Winner, writer.WriteInt32, 0)
end

function Auto.WriteGomokuZoneInfo(writer, val)
	Base.WritePrimitive(writer, val.GameType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurrentRound, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentTurn, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.ScoreInfo, Auto.WriteGomokuScoreInfo, "ScoreInfo", false)
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StartReason, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SyncReason, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ZoneType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ZoneState, writer.WriteByte, 0)
	Base.WriteList(writer, val.ParticipantInfos, Base.WriteComplexWrap(Auto.WriteGameGroundParticipantInfo, "GameGroundParticipantInfo", true), nil, "ParticipantInfos", true, 0, nil)
end

function Auto.WriteGridAOIDecrease(writer, val)
	Base.WriteList(writer, val.SectorIdList, writer.WriteInt32, 0, "SectorIdList", true, 0, nil)
	Base.WriteList(writer, val.StandardIndexList, Base.WriteStructWrap(Auto.WriteGridIndex, "StandardIndexList"), nil, "StandardIndexList", false, 0, nil)
	Base.WriteList(writer, val.ExceptIds, writer.WriteUInt64, 0, "ExceptIds", false, 0, nil)
end

function Auto.WriteGridIndex(writer, val)
	Base.WritePrimitive(writer, val.X, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Z, writer.WriteInt32, 0)
end

function Auto.WriteGymPlayResult(writer, val)
	Base.WritePrimitive(writer, val.Level, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.ExerciseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteSingle, 0)
end

function Auto.WriteHackerBatteryCurrentAndTotalCount(writer, val)
	Base.WritePrimitive(writer, val.BatteryTotalCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BatteryCurrentCount, writer.WriteUInt32, 0)
end

function Auto.WriteHackerPostInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.HaveRead, writer.WriteBoolean, false)
end

function Auto.WriteHitPredictData(writer, val)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.HitPredictId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PredictorId, writer.WriteUInt64, 0)
end

function Auto.WriteHouseInfo(writer, val)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ParkingSpaceVehicleIdDict, writer.WriteInt32, writer.WriteUInt32, 0, "ParkingSpaceVehicleIdDict", false, 0)
	Base.WriteDict(writer, val.FloorBuildInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteIndoorBuildInfo, "IndoorBuildInfo", false), nil, "FloorBuildInfoDict", false, 0)
	Base.WritePrimitive(writer, val.CurPlacedFurnitureInstanceId, writer.WriteUInt64, 0)
end

function Auto.WriteHouseMoveParkingSpaceInfo(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ParkingSpaceIndex, writer.WriteInt32, 0)
end

function Auto.WriteHouseParkingInfo(writer, val)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
end

function Auto.WriteHouseVehicleParkingInfo(writer, val)
	Base.WritePrimitive(writer, val.HouseId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ParkingSpaceIndex, writer.WriteInt32, 0)
end

function Auto.WriteHousesInfo(writer, val)
	Base.WriteList(writer, val.HouseInfoList, Base.WriteComplexWrap(Auto.WriteHouseInfo, "HouseInfo", false), nil, "HouseInfoList", false, 0, nil)
	Base.WriteList(writer, val.NotParkingSpaceVehicleIdList, writer.WriteUInt32, 0, "NotParkingSpaceVehicleIdList", false, 0, nil)
	Base.WriteDict(writer, val.FurnitureInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFurnitureInfo, "FurnitureInfo", false), nil, "FurnitureInfoDict", false, 0)
end

function Auto.WriteImSimpleData(writer, val)
	Base.WriteList(writer, val.ChatGroupList, Base.WriteComplexWrap(Auto.WriteChatGroupClient, "ChatGroupClient", false), nil, "ChatGroupList", false, 0, nil)
	Base.WritePrimitive(writer, val.MuteEndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SoftMuteEndTime, writer.WriteUInt32, 0)
end

function Auto.WriteIndoorBuildInfo(writer, val)
	Base.WriteComplex(writer, val.Root, Auto.WritePlacedFurnitureInfo, "Root", false)
end

function Auto.WriteInteractCmdData(writer, val)
	Base.WritePrimitive(writer, val.CmdType, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.sender, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.receiver, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.CommandData, writer.WriteByte, 0, "CommandData", true, 1024, val.CommandDataLen)
	Base.WritePrimitive(writer, val.CommandDataLen, writer.WriteInt32, 0)
end

function Auto.WriteItemCountInfo(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

function Auto.WriteItemCountLimitInfo(writer, val)
	Base.WritePrimitive(writer, val.ItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextRefreshTime, writer.WriteUInt32, 0)
end

function Auto.WriteItemDestructibleData(writer, val)
	Base.WritePrimitive(writer, val.DesTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.LivingTime, writer.WriteSingle, 0)
end

function Auto.WriteItemShortcutInfo(writer, val)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
end

function Auto.WriteLeadingWayUrging(writer, val)
	Base.WritePrimitive(writer, val.dialogId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.distance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.minDuration, writer.WriteSingle, 0)
end

function Auto.WriteLinkInfoClient(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Mode, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.DeviceLevel, writer.WriteByte, 0)
	Base.WriteList(writer, val.Members, Base.WriteComplexWrap(Auto.WritePlayerBasicInfoVO, "PlayerBasicInfoVO", false), nil, "Members", false, 0, nil)
end

function Auto.WriteLinkMemberInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.InTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OutTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TempLeave, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.IsPSNPlayer, writer.WriteBoolean, false)
end

function Auto.WriteLoadingTextInfo(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeftTimes, writer.WriteUInt32, 0)
end

function Auto.WriteLoadingTypeInfo(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
	Base.WriteList(writer, val.Members, writer.WriteUInt64, 0, "Members", true, 0, nil)
end

function Auto.WriteLogicVehicleUnitDebugData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.FineId, writer.WriteUInt32, 0, "FineId", false, 0, nil)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

function Auto.WriteLookAtPositionData(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsImmediate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionUid, writer.WriteUInt32, 0)
end

function Auto.WriteLookAtTargetData(writer, val)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsImmediate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionUid, writer.WriteUInt32, 0)
end

function Auto.WriteMahjongGameInfo(writer, val)
	Base.WritePrimitive(writer, val.GameState, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Round, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Remainders, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Banker, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Turn, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LastTurn, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LastMoPaiSeatIndex, writer.WriteInt32, 0)
	Base.WriteList(writer, val.SeatInfos, Base.WriteComplexWrap(Auto.WriteSeatInfo, "SeatInfo", true), nil, "SeatInfos", true, 0, nil)
	Base.WriteList(writer, val.HuPais, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "HuPais"), nil, "HuPais", true, 0, nil)
	Base.WriteList(writer, val.DoraIndicatorLs, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "DoraIndicatorLs"), nil, "DoraIndicatorLs", true, 0, nil)
	Base.WriteList(writer, val.DoraLs, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "DoraLs"), nil, "DoraLs", true, 0, nil)
	Base.WriteList(writer, val.UraDoraIndicatorLs, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "UraDoraIndicatorLs"), nil, "UraDoraIndicatorLs", true, 0, nil)
	Base.WriteList(writer, val.UraDoraLs, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "UraDoraLs"), nil, "UraDoraLs", true, 0, nil)
end

function Auto.WriteMahjongPlayerInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	writer:WriteString(val.Name, false, "Name", 0)
	Base.WriteComplex(writer, val.PzHeadInfo, Auto.WritePersonalZoneHeadInfo, "PzHeadInfo", true)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NpcMahjongId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
end

function Auto.WriteMahjongRoomInfo(writer, val)
	Base.WritePrimitive(writer, val.MahjongServerId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RoomId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.RoomType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteByte, 0)
	Base.WriteList(writer, val.PlayerInfos, Base.WriteComplexWrap(Auto.WriteMahjongPlayerInfo, "MahjongPlayerInfo", true), nil, "PlayerInfos", true, 0, nil)
	Base.WriteList(writer, val.HasReady, writer.WriteBoolean, false, "HasReady", false, 0, nil)
	Base.WritePrimitive(writer, val.RoomOwnerSeatIndex, writer.WriteInt32, 0)
end

function Auto.WriteMaidTeaChoiceInfo(writer, val)
	Base.WriteList(writer, val.Choices, writer.WriteInt32, 0, "Choices", false, 32, nil)
end

function Auto.WriteMaidTeaMemeberInfo(writer, val)
	Base.WritePrimitive(writer, val.VisitTimes, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.UnlockDrinks, writer.WriteUInt32, 0, "UnlockDrinks", false, 0, nil)
end

function Auto.WriteMailAttachment(writer, val)
	Base.WriteList(writer, val.Items, Base.WriteComplexWrap(Auto.WriteItemCountInfo, "ItemCountInfo", true), nil, "Items", true, 0, nil)
	Base.WritePrimitive(writer, val.UnbindMoney, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BindGold, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PayGold, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FreeGold, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Popularity, writer.WriteSingle, 0)
	Base.WriteDict(writer, val.JobExpInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "JobExpInfo", true, 0)
	Base.WriteDict(writer, val.FanInfo, writer.WriteUInt32, writer.WriteInt32, 0, "FanInfo", true, 0)
	Base.WriteDict(writer, val.FactionDispositionInfo, writer.WriteUInt32, writer.WriteInt32, 0, "FactionDispositionInfo", true, 0)
	Base.WriteDict(writer, val.FactionInfluenceInfo, writer.WriteUInt32, writer.WriteInt32, 0, "FactionInfluenceInfo", true, 0)
	Base.WriteDict(writer, val.AbilityExpInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "AbilityExpInfo", true, 0)
	Base.WriteComplex(writer, val.SpiritTalentExpInfo, Auto.WriteSpiritTalentExpInfo, "SpiritTalentExpInfo", true)
	Base.WritePrimitive(writer, val.CommonSpiritTalentExp, writer.WriteUInt32, 0)
end

function Auto.WriteMailHead(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MailId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExpireTime, writer.WriteUInt32, 0)
	writer:WriteString(val.Title, true, "Title", 0)
	Base.WriteList(writer, val.TitleParams, Base.WriteComplexWrap(Auto.WriteMailParameter, "MailParameter", true), nil, "TitleParams", true, 0, nil)
	writer:WriteString(val.SenderName, true, "SenderName", 0)
	Base.WritePrimitive(writer, val.IsGlobal, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HasItem, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.Attachment, Auto.WriteSimpleMailAttchment, "Attachment", true)
	Base.WritePrimitive(writer, val.IsFavorite, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsRetrieved, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Tab, writer.WriteInt32, 0)
end

function Auto.WriteMailInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Reason, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsGlobal, writer.WriteBoolean, false)
	writer:WriteString(val.SenderName, true, "SenderName", 0)
	writer:WriteString(val.Title, true, "Title", 0)
	Base.WriteList(writer, val.TitleParams, Base.WriteComplexWrap(Auto.WriteMailParameter, "MailParameter", true), nil, "TitleParams", true, 0, nil)
	writer:WriteString(val.Content, true, "Content", 0)
	Base.WriteList(writer, val.ContentParams, Base.WriteComplexWrap(Auto.WriteMailParameter, "MailParameter", true), nil, "ContentParams", true, 0, nil)
	Base.WritePrimitive(writer, val.RewardTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MailId, writer.WriteUInt32, 0)
	writer:WriteString(val.JsonAttachment, true, "JsonAttachment", 0)
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
end

function Auto.WriteMailParameter(writer, val)
	Base.WritePrimitive(writer, val.ParamType, writer.WriteByte, 0)
	writer:WriteString(val.Data, false, "Data", 0)
end

function Auto.WriteMallCommodityInfo(writer, val)
	Base.WritePrimitive(writer, val.BoughtCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextRefreshTime, writer.WriteUInt32, 0)
end

function Auto.WriteMallInfo(writer, val)
	Base.WriteDict(writer, val.CommodityInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteMallCommodityInfo, "MallCommodityInfo", false), nil, "CommodityInfoDict", false, 0)
	Base.WriteComplex(writer, val.MonthCardInfo, Auto.WritePlayerMonthCardInfo, "MonthCardInfo", false)
	Base.WriteList(writer, val.CommoditySpiritDisplayPreferencesList, writer.WriteUInt32, 0, "CommoditySpiritDisplayPreferencesList", false, 0, nil)
end

function Auto.WriteMapPin(writer, val)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
end

function Auto.WriteMassCustomArea(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Hide, writer.WriteBoolean, false)
	Base.WriteList(writer, val.Points, Base.WriteStructWrap(Auto.WriteUXVector3, "Points"), nil, "Points", true, 0, nil)
	Base.WritePrimitive(writer, val.HideType, writer.WriteInt32, 0)
end

function Auto.WriteMassTrafficLightControl(writer, val)
	Base.WritePrimitive(writer, val.TrafficLightStateFlags, writer.WriteByte, 0)
end

function Auto.WriteMassTrafficSpawnArea(writer, val)
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

function Auto.WriteMassTrafficSpawnAreaManager(writer, val)
	Base.WritePrimitive(writer, val.ClearAllNormalVehicles, writer.WriteBoolean, false)
	Base.WriteList(writer, val.TrafficSpawnAreas, Base.WriteStructWrap(Auto.WriteSpawnAreaSelector, "TrafficSpawnAreas"), nil, "TrafficSpawnAreas", false, 0, nil)
end

function Auto.WriteMatchPlayerSettleData(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer:WriteString(val.Name, false, "Name", 0)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ElapsedTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Result, writer.WriteByte, 0)
end

function Auto.WriteMatchPrepareInfo(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.Fashion, Auto.WriteOtherPlayerSpiritWearFashionsInfo, "Fashion", true)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PoseId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.LinkPlanningBoardPutInKeys, Base.WriteComplexWrap(Auto.WriteItemCountInfo, "ItemCountInfo", true), nil, "LinkPlanningBoardPutInKeys", true, 32, nil)
end

function Auto.WriteMatchPrepareRoom(writer, val)
	Base.WriteList(writer, val.TeamRooms, writer.WriteUInt64, 0, "TeamRooms", false, 0, nil)
	Base.WriteList(writer, val.PlayAgainMembers, writer.WriteUInt64, 0, "PlayAgainMembers", false, 0, nil)
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
	Base.WritePrimitive(writer, val.LeaveToTeam, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LeaveToTeamLeader, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeaderPid, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.Members, Base.WriteComplexWrap(Auto.WriteMatchRoomMemberInfo, "MatchRoomMemberInfo", false), nil, "Members", false, 0, nil)
	Base.WritePrimitive(writer, val.LastMemberUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ByMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PSNOnly, writer.WriteBoolean, false)
end

function Auto.WriteMatchPrepareRoomDutySwapInfo(writer, val)
	Base.WritePrimitive(writer, val.SourcePid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SourceDuty, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TargetPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetDuty, writer.WriteUInt32, 0)
end

function Auto.WriteMatchPrepareRoomPlayerSwapInfo(writer, val)
	Base.WriteDict(writer, val.SwapInfos, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteMatchPrepareRoomDutySwapInfo, "MatchPrepareRoomDutySwapInfo", false), nil, "SwapInfos", false, 0)
end

function Auto.WriteMatchRoom(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeaderPid, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.Members, Base.WriteComplexWrap(Auto.WriteMatchRoomMemberInfo, "MatchRoomMemberInfo", false), nil, "Members", false, 0, nil)
	Base.WritePrimitive(writer, val.LastMemberUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ByMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PSNOnly, writer.WriteBoolean, false)
end

function Auto.WriteMatchRoomMemberInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MatchForbidDueTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Duty, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FromMode, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.DeviceLevel, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.FromRaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FromSceneInstanceId, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.Blacklist, writer.WriteUInt64, 0, "Blacklist", false, 0, nil)
end

function Auto.WriteMatchRoomSetting(writer, val)
	Base.WritePrimitive(writer, val.AllowNonLeaderInvite, writer.WriteBoolean, false)
end

function Auto.WriteMatchTeamRoom(writer, val)
	Base.WritePrimitive(writer, val.MatchStartTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.matchingFactor, Auto.WriteMatchingFactor, "matchingFactor", false)
	Base.WritePrimitive(writer, val.InMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Single, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.Setting, Auto.WriteMatchRoomSetting, "Setting", false)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GameId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeaderPid, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.Members, Base.WriteComplexWrap(Auto.WriteMatchRoomMemberInfo, "MatchRoomMemberInfo", false), nil, "Members", false, 0, nil)
	Base.WritePrimitive(writer, val.LastMemberUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ByMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.PSNOnly, writer.WriteBoolean, false)
end

function Auto.WriteMatchingFactor(writer, val)
	Base.WriteList(writer, val.Blacklist, writer.WriteUInt64, 0, "Blacklist", false, 0, nil)
	Base.WritePrimitive(writer, val.deviceLevelWeight, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.Score, writer.WriteDouble, 0)
end

function Auto.WriteMessageCallbackParameter(writer, val)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
end

function Auto.WriteMetroCarriageGadgetInfos(writer, val)
	Base.WriteList(writer, val.InnerGadgetIds, writer.WriteUInt64, 0, "InnerGadgetIds", false, 0, nil)
	Base.WriteList(writer, val.OuterGadgetIds, writer.WriteUInt64, 0, "OuterGadgetIds", false, 0, nil)
end

function Auto.WriteMetroClientInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LineId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ElapsedTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsFinalTrain, writer.WriteBoolean, false)
end

function Auto.WriteMetroHideArea(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Hide, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WritePrimitive(writer, val.Radius, writer.WriteSingle, 0)
end

function Auto.WriteMetroHitData(writer, val)
	Base.WritePrimitive(writer, val.MetroId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HurtEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HurtStiffId, writer.WriteUInt32, 0)
end

function Auto.WriteMetroLineCarriageInfo(writer, val)
	Base.WritePrimitive(writer, val.MetroLineId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MetroCarriageId, writer.WriteUInt32, 0)
end

function Auto.WriteMilkTopicInfo(writer, val)
	Base.WriteList(writer, val.Topics, writer.WriteUInt32, 0, "Topics", false, 0, nil)
	Base.WritePrimitive(writer, val.FinishedFlag, writer.WriteInt32, 0)
end

function Auto.WriteMiniGameData(writer, val)
	Base.WriteList(writer, val.MiniGame_Bee, writer.WriteUInt32, 0, "MiniGame_Bee", false, 0, nil)
end

function Auto.WriteMjAction(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Owner, writer.WriteInt32, 0)
	Base.WriteList(writer, val.Targets, writer.WriteInt32, 0, "Targets", false, 0, nil)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsZhuanYi, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BaseFan, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Pattern, writer.WriteByte, 0)
	Base.WriteList(writer, val.Patterns, writer.WriteByte, 0, "Patterns", true, 0, nil)
	Base.WriteStruct(writer, val.Pai, Auto.WriteMjPaiInfo, "Pai")
	Base.WritePrimitive(writer, val.NumOfGen, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HuAction, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Fan, writer.WriteInt32, 0)
end

function Auto.WriteMjCanActionInfo(writer, val)
	Base.WriteStruct(writer, val.Pai, Auto.WriteMjPaiInfo, "Pai")
	Base.WritePrimitive(writer, val.CanHu, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CanReach, writer.WriteBoolean, false)
	Base.WriteList(writer, val.CanPeng, Base.WriteComplexWrap(Auto.WriteMjPCGActionInfo, "MjPCGActionInfo", false), nil, "CanPeng", false, 0, nil)
	Base.WriteList(writer, val.CanChi, Base.WriteComplexWrap(Auto.WriteMjPCGActionInfo, "MjPCGActionInfo", false), nil, "CanChi", false, 0, nil)
	Base.WriteList(writer, val.CanGang, Base.WriteComplexWrap(Auto.WriteMjPCGActionInfo, "MjPCGActionInfo", false), nil, "CanGang", false, 0, nil)
	Base.WritePrimitive(writer, val.CanChuPai, writer.WriteBoolean, false)
end

function Auto.WriteMjPCGActionInfo(writer, val)
	Base.WritePrimitive(writer, val.Source, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Pai, Auto.WriteMjPaiInfo, "Pai")
	Base.WriteList(writer, val.SelectPais, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "SelectPais"), nil, "SelectPais", false, 0, nil)
	Base.WritePrimitive(writer, val.PCGType, writer.WriteByte, 0)
end

function Auto.WriteMjPaiInfo(writer, val)
	Base.WritePrimitive(writer, val.Pai, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Red, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
end

function Auto.WriteMjPlayerResult(writer, val)
	Base.WriteList(writer, val.Holds, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "Holds"), nil, "Holds", false, 0, nil)
end

function Auto.WriteMjResult(writer, val)
	Base.WriteList(writer, val.MJActions, Base.WriteComplexWrap(Auto.WriteMjAction, "MjAction", true), nil, "MJActions", true, 0, nil)
	Base.WriteList(writer, val.MjPlayerResultList, Base.WriteComplexWrap(Auto.WriteMjPlayerResult, "MjPlayerResult", true), nil, "MjPlayerResultList", true, 0, nil)
end

function Auto.WriteMobilePlatformSyncInfo(writer, val)
	Base.WritePrimitive(writer, val.CurLevel, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TgtLevel, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.Players, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteUXVector3, "UXVector3", false), nil, "Players", false, 0)
	Base.WriteStruct(writer, val.CurLevelPos, Auto.WriteUXVector3, "CurLevelPos")
	Base.WriteStruct(writer, val.TgtLevelPos, Auto.WriteUXVector3, "TgtLevelPos")
end

function Auto.WriteModifySpiritWearFashionResult(writer, val)
	Base.WriteList(writer, val.R0, writer.WriteUInt32, 0, "R0", false, 0, nil)
	Base.WriteList(writer, val.R1, Base.WriteComplexWrap(Auto.WriteWearFashionInfo, "WearFashionInfo", false), nil, "R1", false, 0, nil)
	Base.WriteList(writer, val.R2, writer.WriteUInt32, 0, "R2", false, 0, nil)
	Base.WriteList(writer, val.R3, Base.WriteComplexWrap(Auto.WriteWearFashionEditInfo, "WearFashionEditInfo", false), nil, "R3", false, 0, nil)
end

function Auto.WriteModuleEventProgressInfo(writer, val)
	Base.WriteDict(writer, val.ProgressInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteModuleEventProgressInfoBySpirit, "ModuleEventProgressInfoBySpirit", false), nil, "ProgressInfoDict", false, 0)
end

function Auto.WriteModuleEventProgressInfoBySpirit(writer, val)
	Base.WriteDict(writer, val.EventProgressInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteEventProgressInfo, "EventProgressInfo", false), nil, "EventProgressInfoDict", false, 0)
	Base.WriteList(writer, val.FinishedTemplateIdList, writer.WriteUInt32, 0, "FinishedTemplateIdList", false, 0, nil)
end

function Auto.WriteMomentsNotifyClientInfo(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.LikeCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PostCount, writer.WriteInt32, 0)
	Base.WriteList(writer, val.NpcIds, writer.WriteUInt32, 0, "NpcIds", true, 0, nil)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HasNewLike, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AcquireCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActivityCfgId, writer.WriteUInt32, 0)
	writer:WriteString(val.Url, true, "Url", 0)
	Base.WritePrimitive(writer, val.IsStory, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPinStory, writer.WriteBoolean, false)
end

function Auto.WriteMonitorTwitterBehavior(writer, val)
	Base.WritePrimitive(writer, val.Behavior, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
end

function Auto.WriteMoveActionData(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rot, Auto.WriteUXVector3, "Rot")
	Base.WritePrimitive(writer, val.MoveId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MoveTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ClientLocalTime, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.GroundData, Auto.WriteMoveActionGroundData, "GroundData")
	Base.WriteList(writer, val.ActionData, writer.WriteByte, 0, "ActionData", true, 1024, val.ActionDataLength)
	Base.WritePrimitive(writer, val.ActionDataLength, writer.WriteInt32, 0)
	Base.WriteList(writer, val.EffectData, writer.WriteByte, 0, "EffectData", true, 10240, val.EffectDataLength)
	Base.WritePrimitive(writer, val.EffectDataLength, writer.WriteInt32, 0)
	Base.WriteList(writer, val.InteractableData, writer.WriteByte, 0, "InteractableData", true, 10240, val.InteractableDataLength)
	Base.WritePrimitive(writer, val.InteractableDataLength, writer.WriteInt32, 0)
end

function Auto.WriteMoveActionGroundData(writer, val)
	Base.WritePrimitive(writer, val.MoveGroundType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.MoveGroundId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.LocalPos, Auto.WriteUXVector3, "LocalPos")
end

function Auto.WriteMoveToBorderData(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MoveType, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MaxDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
end

function Auto.WriteMoveToCanShootPosData(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MoveType, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.AngleSpace, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DistanceSpace, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
end

function Auto.WriteMoveToEQSData(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	writer:WriteString(val.EqsName, false, "EqsName", 0)
	writer:WriteString(val.CheckerName, false, "CheckerName", 0)
	Base.WritePrimitive(writer, val.PathTags, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MoveType, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CloseObstacleAvoidance, writer.WriteBoolean, false)
end

function Auto.WriteMoveToPosData(writer, val)
	Base.WritePrimitive(writer, val.pid, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.path, Base.WriteStructWrap(Auto.WriteUXVector3, "path"), nil, "path", false, 0, nil)
	Base.WritePrimitive(writer, val.pathTags, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.moveId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StopDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.type, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.reportOnFinish, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.closeIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UseServerPath, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CloseObstacleAvoidance, writer.WriteBoolean, false)
	Base.WriteList(writer, val.pathFlags, writer.WriteByte, 0, "pathFlags", false, 0, nil)
end

function Auto.WriteMoveTowardUnitData(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MoveId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NearDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ReportOnFinish, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CloseObstacleAvoidance, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CloseIngterStep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsMoveAround, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CloseIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt64, 0)
end

function Auto.WriteMoveWanderingData(writer, val)
	Base.WritePrimitive(writer, val.pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.pathTags, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.moveId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.type, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.closeIK, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CloseObstacleAvoidance, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MinDis, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxDis, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.InRangeAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OutRangeAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxOnceWanderTime, writer.WriteSingle, 0)
end

function Auto.WriteMusicClientInfo(writer, val)
	Base.WritePrimitive(writer, val.MusicId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.RecordInfo, writer.WriteUInt32, 0, "RecordInfo", true, 0, nil)
	Base.WritePrimitive(writer, val.AlreadyReward, writer.WriteBoolean, false)
end

function Auto.WriteNameCard(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer:WriteString(val.Name, false, "Name", 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
end

function Auto.WriteNewChallengeRecord(writer, val)
	Base.WritePrimitive(writer, val.ChallengeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HighestLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReceivedRewardLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurrentIsNewRewardLevel, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BestScore, writer.WriteSingle, 0)
	Base.WriteDict(writer, val.ParamData, writer.WriteUInt32, writer.WriteBoolean, false, "ParamData", false, 0)
end

function Auto.WriteNewClientBoardingInfo(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Status, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.VehicleUId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
end

function Auto.WriteNewHotFixPatchData(writer, val)
	Base.WritePrimitive(writer, val.Version, writer.WriteInt32, 0)
	Base.WriteList(writer, val.Content, writer.WriteByte, 0, "Content", false, 0, nil)
	writer:WriteString(val.Md5, false, "Md5", 0)
end

function Auto.WriteNgpushSetting(writer, val)
	Base.WritePrimitive(writer, val.DoNotDisturb, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.DoNotDisturbBegin, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DoNotDisturbEnd, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TagSetting, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastSetTagTime, writer.WriteUInt32, 0)
end

function Auto.WriteNodeSpoonOutputLinks(writer, val)
	Base.WriteList(writer, val.Links, Base.WriteComplexWrap(Auto.WriteSpoonOutputLink, "SpoonOutputLink", false), nil, "Links", false, 0, nil)
end

function Auto.WriteNpcCardInfo(writer, val)
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

function Auto.WriteNpcChatContext(writer, val)
	Base.WritePrimitive(writer, val.BubbleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AcquireCfgId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.EmojiList, Base.WriteComplexWrap(Auto.WriteEmojiData, "EmojiData", false), nil, "EmojiList", false, 0, nil)
	writer:WriteString(val.Url, true, "Url", 0)
	Base.WritePrimitive(writer, val.ActivityCfgId, writer.WriteUInt32, 0)
end

function Auto.WriteNpcChatItem(writer, val)
	Base.WritePrimitive(writer, val.Timestamp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ChatId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextChatId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.ChatContext, Auto.WriteNpcChatContext, "ChatContext", true)
	Base.WritePrimitive(writer, val.IsRead, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.BelongNpc, writer.WriteUInt32, 0)
end

function Auto.WriteNpcEventQueue(writer, val)
	Base.WritePrimitive(writer, val.TodayTriggeredCount, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.EventIds, writer.WriteUInt32, 0, "EventIds", false, 0, nil)
end

function Auto.WriteNpcEventQueueList(writer, val)
	Base.WriteDict(writer, val.NpcQueues, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteNpcEventQueue, "NpcEventQueue", false), nil, "NpcQueues", false, 0)
	Base.WritePrimitive(writer, val.TodayTriggeredCount, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.IdToNpcDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteEventIdInfo, "EventIdInfo", false), nil, "IdToNpcDict", false, 0)
	Base.WritePrimitive(writer, val.LastTriggerTime, writer.WriteUInt32, 0)
end

function Auto.WriteNpcScheduleInfo(writer, val)
	Base.WritePrimitive(writer, val.ActivityId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartDaySecond, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.SpoonAgentId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EndDaySecond, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
end

function Auto.WriteNpcShareTimeInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FightShareDuration, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SwitchInTime, writer.WriteUInt32, 0)
end

function Auto.WriteNpcShopCommodityInfo(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RefreshTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Status, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BuyTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Discount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DiscountPrice, writer.WriteUInt32, 0)
end

function Auto.WriteNpcShopInfo(writer, val)
	Base.WritePrimitive(writer, val.CurrentDiscount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextDiscount, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.CommodityInfoList, Base.WriteComplexWrap(Auto.WriteNpcShopCommodityInfo, "NpcShopCommodityInfo", false), nil, "CommodityInfoList", false, 0, nil)
end

function Auto.WriteNpcTimeTableInfo(writer, val)
	Base.WriteComplex(writer, val.Schedule0, Auto.WriteNpcScheduleInfo, "Schedule0", false)
	Base.WriteComplex(writer, val.Schedule1, Auto.WriteNpcScheduleInfo, "Schedule1", false)
	Base.WriteComplex(writer, val.Schedule2, Auto.WriteNpcScheduleInfo, "Schedule2", false)
	Base.WriteComplex(writer, val.Schedule3, Auto.WriteNpcScheduleInfo, "Schedule3", false)
	Base.WriteComplex(writer, val.Schedule4, Auto.WriteNpcScheduleInfo, "Schedule4", false)
	Base.WritePrimitive(writer, val.CurrentSpoonAgentId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.SpoonPosition, Auto.WriteUXVector3, "SpoonPosition")
end

function Auto.WriteNpcTrustValueInfo(writer, val)
	Base.WritePrimitive(writer, val.ProfileId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TrustValue, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Reason, writer.WriteInt32, 0)
end

function Auto.WriteNpcVehicleDriveStateInfo(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.EnterOrLeave, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.VehicleEntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
end

function Auto.WriteOccupyDebugInfo(writer, val)
	Base.WritePrimitive(writer, val.OccupyId, writer.WriteUInt32, 0)
	writer:WriteString(val.Reason, true, "Reason", 0)
end

function Auto.WriteOtherPlayerSpiritWearFashionsInfo(writer, val)
	Base.WriteDict(writer, val.WearFashionColoringInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFashionColoringInfo, "FashionColoringInfo", false), nil, "WearFashionColoringInfoDict", true, 32)
	Base.WriteList(writer, val.WearFashionInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionInfo, "WearFashionInfo", false), nil, "WearFashionInfoList", false, 32, nil)
	Base.WriteList(writer, val.WearFashionEditInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "WearFashionEditInfoList", true, 32, nil)
	Base.WritePrimitive(writer, val.HiddenParts, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EditedHiddenParts, writer.WriteByte, 0)
end

function Auto.WriteOwnerSyncData(writer, val)
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

function Auto.WritePSNPlayerInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.IsPSNPlayer, writer.WriteByte, 0)
	writer:WriteString(val.Openid, false, "Openid", 0)
end

function Auto.WritePackedDestructibleInfo(writer, val)
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WriteList(writer, val.linkType, writer.WriteByte, 0, "linkType", true, 0, nil)
	Base.WriteList(writer, val.linkPath, writer.WriteInt32, 0, "linkPath", true, 0, nil)
end

function Auto.WritePackedGadgetInfo(writer, val)
	Base.WritePrimitive(writer, val.posX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.posY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.posZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.eulerX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.eulerY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.eulerZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.uniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.pathId, writer.WriteInt32, 0)
	Base.WriteList(writer, val.spoonSpecialList, Base.WriteStructWrap(Auto.WritePackedGadgetSpecialParam, "spoonSpecialList"), nil, "spoonSpecialList", true, 0, nil)
	Base.WritePrimitive(writer, val.delayDestroy, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.startTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.endTaskId, writer.WriteUInt32, 0)
end

function Auto.WritePackedGadgetSpecialParam(writer, val)
	Base.WritePrimitive(writer, val.markId, writer.WriteInt32, 0)
	writer:WriteString(val.value, true, "value", 0)
end

function Auto.WritePartyNPCMessage(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	writer:WriteString(val.Message, false, "Message", 0)
end

function Auto.WritePartyResponse(writer, val)
	Base.WriteList(writer, val.likeList, writer.WriteInt32, 0, "likeList", false, 0, nil)
	Base.WriteList(writer, val.giftList, writer.WriteInt32, 0, "giftList", false, 0, nil)
	Base.WritePrimitive(writer, val.Popularity, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.NPCMessage, Base.WriteComplexWrap(Auto.WritePartyNPCMessage, "PartyNPCMessage", false), nil, "NPCMessage", false, 0, nil)
end

function Auto.WritePartySettleData(writer, val)
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
	Base.WriteList(writer, val.InviteNPCList, writer.WriteUInt32, 0, "InviteNPCList", false, 0, nil)
end

function Auto.WritePatchEntry(writer, val)
	Base.WritePrimitive(writer, val.Version, writer.WriteInt32, 0)
	Base.WriteList(writer, val.Content, writer.WriteByte, 0, "Content", false, 0, nil)
	writer:WriteString(val.Md5, false, "Md5", 0)
end

function Auto.WritePauseFrameData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Releaser, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Time, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteUInt32, 0)
end

function Auto.WritePersonalTeamSetting(writer, val)
	Base.WritePrimitive(writer, val.DisableTeamInviteInPersonalMode, writer.WriteBoolean, false)
end

function Auto.WritePersonalTimeSetting(writer, val)
	writer:WriteString(val.Label, false, "Label", 32)
	Base.WritePrimitive(writer, val.Hour, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Minute, writer.WriteUInt32, 0)
end

function Auto.WritePersonalZoneAchievement(writer, val)
	Base.WritePrimitive(writer, val.AchieveId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CountryId, writer.WriteUInt32, 0)
end

function Auto.WritePersonalZoneFightSpiritInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FavorLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcCultivationId, writer.WriteUInt32, 0)
end

function Auto.WritePersonalZoneHeadExtendInfo(writer, val)
	Base.WriteComplex(writer, val.PzHeadInfo, Auto.WritePersonalZoneHeadInfo, "PzHeadInfo", false)
	Base.WriteList(writer, val.UnlockedSystemHeadList, Base.WriteComplexWrap(Auto.WritePersonalZoneItemInfo, "PersonalZoneItemInfo", false), nil, "UnlockedSystemHeadList", false, 0, nil)
end

function Auto.WritePersonalZoneHeadInfo(writer, val)
	Base.WritePrimitive(writer, val.HeadType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SystemHeadId, writer.WriteUInt32, 0)
end

function Auto.WritePersonalZoneItemInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HadInteracted, writer.WriteBoolean, false)
end

function Auto.WritePersonalZoneUnlockBackgroundInfo(writer, val)
	Base.WritePrimitive(writer, val.BackgroundId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HadInteracted, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsUnlock, writer.WriteBoolean, false)
end

function Auto.WritePhoneContact(writer, val)
	writer:WriteString(val.Remark, false, "Remark", 0)
	writer:WriteString(val.PhoneNumber, false, "PhoneNumber", 0)
end

function Auto.WritePhoneContactCallRecord(writer, val)
	Base.WritePrimitive(writer, val.CallTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CallType, writer.WriteByte, 0)
	writer:WriteString(val.PhoneNumber, false, "PhoneNumber", 0)
end

function Auto.WritePhoneContactGroup(writer, val)
	writer:WriteString(val.Name, false, "Name", 0)
	Base.WriteList(writer, val.PhoneNumberList, Base.WriteStringWrap(false, "PhoneNumberList", 0), nil, "PhoneNumberList", false, 0, nil)
end

function Auto.WritePhoneInfos(writer, val)
	Base.WriteList(writer, val.ContactList, Base.WriteComplexWrap(Auto.WritePhoneContact, "PhoneContact", false), nil, "ContactList", false, 0, nil)
	Base.WriteList(writer, val.ContactGroupList, Base.WriteComplexWrap(Auto.WritePhoneContactGroup, "PhoneContactGroup", false), nil, "ContactGroupList", false, 0, nil)
	Base.WriteList(writer, val.CallRecordList, Base.WriteComplexWrap(Auto.WritePhoneContactCallRecord, "PhoneContactCallRecord", false), nil, "CallRecordList", false, 0, nil)
	Base.WriteDict(writer, val.ContactOutgoingCallTimesDict, Base.WriteStringWrap(false, "ContactOutgoingCallTimesDict", 0), writer.WriteUInt32, 0, "ContactOutgoingCallTimesDict", false, 0)
end

function Auto.WritePlacedFurnitureInfo(writer, val)
	Base.WritePrimitive(writer, val.FurnitureId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WritePrimitive(writer, val.GadgetInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PlacedInstanceId, writer.WriteUInt64, 0)
	Base.WriteDict(writer, val.ChildrenDict, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WritePlacedFurnitureInfo, "PlacedFurnitureInfo", false), nil, "ChildrenDict", false, 0)
end

function Auto.WritePlanningBoardInfo(writer, val)
	Base.WriteDict(writer, val.StepId2OptionIndexDict, writer.WriteUInt32, writer.WriteByte, 0, "StepId2OptionIndexDict", false, 0)
end

function Auto.WritePlateGridAOIInfo(writer, val)
	Base.WriteList(writer, val.addInfos, Base.WriteComplexWrap(Auto.WritePlateInfo, "PlateInfo", true), nil, "addInfos", true, 0, nil)
	Base.WriteList(writer, val.removeIds, writer.WriteUInt64, 0, "removeIds", true, 0, nil)
	Base.WritePrimitive(writer, val.reason, writer.WriteByte, 0)
end

function Auto.WritePlateInfo(writer, val)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.GraphId, writer.WriteInt32, 0)
	Base.WriteDict(writer, val.GadgetDic, writer.WriteInt32, writer.WriteUInt64, 0, "GadgetDic", true, 0)
	Base.WriteDict(writer, val.DestructibleDic, writer.WriteInt32, writer.WriteUInt64, 0, "DestructibleDic", true, 0)
	Base.WriteDict(writer, val.AgentDic, writer.WriteInt32, writer.WriteInt32, 0, "AgentDic", true, 0)
	Base.WriteDict(writer, val.VehicleDic, writer.WriteInt32, writer.WriteInt32, 0, "VehicleDic", true, 0)
end

function Auto.WritePlayActionData(writer, val)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionUid, writer.WriteUInt32, 0)
end

function Auto.WritePlayActionWithLayerData(writer, val)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionUid, writer.WriteUInt32, 0)
end

function Auto.WritePlayerBasicInfoVO(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer:WriteString(val.Name, false, "Name", 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Sex, writer.WriteByte, 0)
	Base.WriteComplex(writer, val.PzHeadInfo, Auto.WritePersonalZoneHeadInfo, "PzHeadInfo", false)
	Base.WritePrimitive(writer, val.LastLogoutTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastDetachTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OnlineState, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.LinkMode, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.LinkIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SyncRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.InRoom, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.InMatch, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TeamId, writer.WriteUInt64, 0)
	writer:WriteString(val.AppChannel, false, "AppChannel", 0)
end

function Auto.WritePlayerBattlePassInfo(writer, val)
	Base.WritePrimitive(writer, val.CurrentBattlePassId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ClaimedLevelRewards, writer.WriteUInt32, writer.WriteByte, 0, "ClaimedLevelRewards", false, 0)
	Base.WritePrimitive(writer, val.CurrentPassType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.LastWeeklyRefresherTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnClaimedExp, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ChallengeTaskStates, writer.WriteUInt32, writer.WriteByte, 0, "ChallengeTaskStates", false, 0)
end

function Auto.WritePlayerCityPediaInfos(writer, val)
	Base.WriteDict(writer, val.CityPedia2IsReadDict, writer.WriteUInt32, writer.WriteBoolean, false, "CityPedia2IsReadDict", false, 0)
	Base.WriteComplex(writer, val.CreditInfo, Auto.WriteCreditInfo, "CreditInfo", false)
end

function Auto.WritePlayerClientInfo(writer, val)
	Base.WriteBuffer(writer, val.Config, "Config", false, 0, nil)
	Base.WriteComplex(writer, val.InfoLogin, Auto.WritePlayerClientInfoLogin, "InfoLogin", false)
	Base.WriteComplex(writer, val.InfoItem, Auto.WritePlayerClientInfoItem, "InfoItem", false)
	Base.WriteComplex(writer, val.InfoSpirit, Auto.WritePlayerClientInfoSpirit, "InfoSpirit", false)
	Base.WriteComplex(writer, val.InfoMinor, Auto.WritePlayerClientInfoMinor, "InfoMinor", false)
	Base.WriteComplex(writer, val.InfoAchievement, Auto.WritePlayerClientInfoAchievement, "InfoAchievement", false)
end

function Auto.WritePlayerClientInfoAchievement(writer, val)
	Base.WriteDict(writer, val.SceneFogMaps, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSceneFogMap, "SceneFogMap", false), nil, "SceneFogMaps", true, 0)
	Base.WriteList(writer, val.SceneFogMapPoiIds, writer.WriteUInt32, 0, "SceneFogMapPoiIds", false, 0, nil)
	Base.WriteList(writer, val.UnlockedCountryList, writer.WriteUInt32, 0, "UnlockedCountryList", false, 0, nil)
	Base.WriteList(writer, val.UnlockedQuestList, writer.WriteUInt32, 0, "UnlockedQuestList", false, 0, nil)
	Base.WriteDict(writer, val.CompletedSubQuestCnt, writer.WriteUInt32, writer.WriteUInt32, 0, "CompletedSubQuestCnt", false, 0)
	Base.WriteDict(writer, val.ChallengeRecordInfo, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteChallengeRecord, "ChallengeRecord", false), nil, "ChallengeRecordInfo", false, 0)
	Base.WriteDict(writer, val.NewChallengeRecordInfo, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteNewChallengeRecord, "NewChallengeRecord", false), nil, "NewChallengeRecordInfo", false, 0)
	Base.WriteList(writer, val.FirstKillEnemyRecord, writer.WriteInt32, 0, "FirstKillEnemyRecord", false, 0, nil)
	Base.WriteList(writer, val.UnlockInvestigateGalleryList, writer.WriteUInt32, 0, "UnlockInvestigateGalleryList", false, 0, nil)
	Base.WritePrimitive(writer, val.InvestigateGalleryRedCnt, writer.WriteInt32, 0)
	Base.WriteDict(writer, val.CountryReputationInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "CountryReputationInfo", false, 0)
	Base.WriteDict(writer, val.FactionInfoDic, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFactionInfo, "FactionInfo", false), nil, "FactionInfoDic", false, 0)
	Base.WriteList(writer, val.OccupiedInfluenceArea, writer.WriteUInt32, 0, "OccupiedInfluenceArea", false, 0, nil)
end

function Auto.WritePlayerClientInfoAtmosphereGameplay(writer, val)
	Base.WritePrimitive(writer, val.PartTimeJobDailyRewardTimes, writer.WriteInt32, 0)
	Base.WriteList(writer, val.PartTimeJobUnlockStore, writer.WriteUInt32, 0, "PartTimeJobUnlockStore", true, 0, nil)
end

function Auto.WritePlayerClientInfoGuide(writer, val)
	Base.WriteList(writer, val.FinishedGuides, writer.WriteUInt32, 0, "FinishedGuides", false, 0, nil)
	Base.WriteList(writer, val.NewGuideTeachInfos, writer.WriteUInt32, 0, "NewGuideTeachInfos", false, 0, nil)
	Base.WriteList(writer, val.RewardedGuideTeachInfos, writer.WriteUInt32, 0, "RewardedGuideTeachInfos", false, 0, nil)
	Base.WriteList(writer, val.UnlockSystems, writer.WriteUInt32, 0, "UnlockSystems", false, 0, nil)
	Base.WriteList(writer, val.TaskTitleGuideUnlockList, writer.WriteUInt16, 0, "TaskTitleGuideUnlockList", true, 0, nil)
end

function Auto.WritePlayerClientInfoItem(writer, val)
	Base.WritePrimitive(writer, val.Money, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Gold, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BindingGold, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FreeGold, writer.WriteInt32, 0)
	Base.WriteList(writer, val.ItemDayCounts, Base.WriteComplexWrap(Auto.WritePlayerItemDayCount, "PlayerItemDayCount", false), nil, "ItemDayCounts", false, 0, nil)
	Base.WriteList(writer, val.PackItems, Base.WriteComplexWrap(Auto.WritePlayerPackItem, "PlayerPackItem", false), nil, "PackItems", false, 0, nil)
	Base.WriteDict(writer, val.ItemShortcutDic, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteItemShortcutInfo, "ItemShortcutInfo", false), nil, "ItemShortcutDic", false, 0)
	Base.WritePrimitive(writer, val.DestructibleShortcut, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TodayGachaCount, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.GachaPoolCount, writer.WriteUInt32, writer.WriteInt32, 0, "GachaPoolCount", false, 0)
	Base.WriteList(writer, val.ItemCountLimitInfoList, Base.WriteComplexWrap(Auto.WriteItemCountLimitInfo, "ItemCountLimitInfo", false), nil, "ItemCountLimitInfoList", false, 0, nil)
	Base.WritePrimitive(writer, val.QuantumWalletStartTime, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.PortalPosition, Auto.WriteUXVector3, "PortalPosition")
	Base.WritePrimitive(writer, val.PortalRaidId, writer.WriteUInt32, 0)
end

function Auto.WritePlayerClientInfoLogin(writer, val)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer:WriteString(val.AccountId, false, "AccountId", 0)
	writer:WriteString(val.Name, false, "Name", 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Sex, writer.WriteByte, 0)
	Base.WriteComplex(writer, val.PzHeadInfo, Auto.WritePersonalZoneHeadInfo, "PzHeadInfo", false)
end

function Auto.WritePlayerClientInfoMinor(writer, val)
	Base.WritePrimitive(writer, val.Exp, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.Fan, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.Fan12, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Fan123, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.YesterdayFan, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.LevelRewards, writer.WriteUInt32, 0, "LevelRewards", false, 0, nil)
	Base.WritePrimitive(writer, val.Questionnaire, writer.WriteInt32, 0)
	Base.WriteDict(writer, val.DropLimitCount, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteDropLimitInfo, "DropLimitInfo", false), nil, "DropLimitCount", false, 0)
	Base.WriteComplex(writer, val.ChargeInfo, Auto.WriteChargeActivityClientInfo, "ChargeInfo", false)
	Base.WriteDict(writer, val.MapPins, writer.WriteUInt64, Base.WriteComplexWrap(Auto.WriteMapPin, "MapPin", false), nil, "MapPins", false, 0)
	Base.WriteComplex(writer, val.MiniGame, Auto.WriteMiniGameData, "MiniGame", false)
	Base.WriteComplex(writer, val.PlayerInfoGuide, Auto.WritePlayerClientInfoGuide, "PlayerInfoGuide", false)
	Base.WriteComplex(writer, val.InfoNpcCultivation, Auto.WritePlayerClientInfoNpcCultivation, "InfoNpcCultivation", false)
	Base.WriteComplex(writer, val.InfoNpcProfile, Auto.WritePlayerClientInfoNpcProfile, "InfoNpcProfile", false)
	Base.WriteComplex(writer, val.PlayerInfoAtmosphereGameplay, Auto.WritePlayerClientInfoAtmosphereGameplay, "PlayerInfoAtmosphereGameplay", false)
	Base.WriteComplex(writer, val.PlayerFashionsInfo, Auto.WritePlayerFashionsInfo, "PlayerFashionsInfo", false)
	Base.WriteComplex(writer, val.housesInfo, Auto.WriteHousesInfo, "housesInfo", false)
	Base.WriteComplex(writer, val.PlayerPhoneInfo, Auto.WritePlayerPhoneInfo, "PlayerPhoneInfo", false)
	Base.WriteDict(writer, val.ModuleEventProgressInfoDict, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteModuleEventProgressInfo, "ModuleEventProgressInfo", false), nil, "ModuleEventProgressInfoDict", false, 0)
	Base.WriteDict(writer, val.LoadingTexts, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteLoadingTextInfo, "LoadingTextInfo", false), nil, "LoadingTexts", false, 0)
	Base.WriteDict(writer, val.Badges, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBadgeInfo, "BadgeInfo", false), nil, "Badges", false, 0)
	Base.WriteList(writer, val.GroupChats, Base.WriteComplexWrap(Auto.WriteSpiritGroupChatInfo, "SpiritGroupChatInfo", false), nil, "GroupChats", false, 0, nil)
	Base.WriteComplex(writer, val.VehicleInfo, Auto.WritePlayerVehicleInfo, "VehicleInfo", false)
	Base.WriteComplex(writer, val.MatchInfo, Auto.WritePlayerMatchInfo, "MatchInfo", false)
	Base.WriteComplex(writer, val.PopularityInfoNew, Auto.WritePlayerInfoPopularity, "PopularityInfoNew", false)
	Base.WriteComplex(writer, val.ComputerUnlockInfo, Auto.WriteComputerUnlockInfo, "ComputerUnlockInfo", false)
	Base.WriteComplex(writer, val.PlayerInteractionActionInfo, Auto.WritePlayerInteractionActionInfo, "PlayerInteractionActionInfo", false)
	Base.WriteComplex(writer, val.PlayerCityPediaInfos, Auto.WritePlayerCityPediaInfos, "PlayerCityPediaInfos", false)
	Base.WritePrimitive(writer, val.DebugReserveGpuDumps, writer.WriteBoolean, false)
	Base.WriteDict(writer, val.FavorNpcDailyScheduleInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteNpcTimeTableInfo, "NpcTimeTableInfo", false), nil, "FavorNpcDailyScheduleInfos", true, 0)
	Base.WriteDict(writer, val.PlayerInterActionInfo, writer.WriteUInt32, Base.WriteStringWrap(false, "PlayerInterActionInfo", 0), nil, "PlayerInterActionInfo", false, 0)
	Base.WriteComplex(writer, val.PlanningBoardInfo, Auto.WritePlanningBoardInfo, "PlanningBoardInfo", false)
	Base.WriteComplex(writer, val.MallInfo, Auto.WriteMallInfo, "MallInfo", false)
	Base.WriteComplex(writer, val.PlayerBattlePassInfo, Auto.WritePlayerBattlePassInfo, "PlayerBattlePassInfo", false)
	Base.WriteComplex(writer, val.PlayerLinkPlanningBoardInfo, Auto.WritePlayerLinkPlanningBoardInfo, "PlayerLinkPlanningBoardInfo", false)
	Base.WriteComplex(writer, val.PlayerGachaInfos, Auto.WritePlayerGachaInfos, "PlayerGachaInfos", false)
	Base.WriteComplex(writer, val.PlayerInspireHubInfo, Auto.WritePlayerClientInspireHubInfo, "PlayerInspireHubInfo", false)
end

function Auto.WritePlayerClientInfoNpcCultivation(writer, val)
	Base.WriteList(writer, val.NpcCardInfos, Base.WriteComplexWrap(Auto.WriteNpcCardInfo, "NpcCardInfo", false), nil, "NpcCardInfos", false, 0, nil)
	Base.WriteList(writer, val.LockedCardInfos, Base.WriteComplexWrap(Auto.WriteNpcCardInfo, "NpcCardInfo", false), nil, "LockedCardInfos", false, 0, nil)
	Base.WriteList(writer, val.NpcChats, Base.WriteComplexWrap(Auto.WriteClientNpcChatData, "ClientNpcChatData", false), nil, "NpcChats", false, 0, nil)
	Base.WriteList(writer, val.NpcGroupChats, Base.WriteComplexWrap(Auto.WriteClientNpcGroupChatData, "ClientNpcGroupChatData", false), nil, "NpcGroupChats", false, 0, nil)
	Base.WritePrimitive(writer, val.AvailableGiftSendCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InteractPoint, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.NpcEventQueueList, Auto.WriteNpcEventQueueList, "NpcEventQueueList", false)
end

function Auto.WritePlayerClientInfoNpcProfile(writer, val)
	Base.WriteDict(writer, val.NpcProfiles, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteTrustNpcInfo, "TrustNpcInfo", false), nil, "NpcProfiles", false, 0)
	Base.WriteList(writer, val.ProgressRewards, writer.WriteUInt32, 0, "ProgressRewards", false, 0, nil)
end

function Auto.WritePlayerClientInfoSpirit(writer, val)
	Base.WriteList(writer, val.Spirits, Base.WriteComplexWrap(Auto.WriteSpiritInfo, "SpiritInfo", false), nil, "Spirits", false, 0, nil)
	Base.WriteComplex(writer, val.InfoPokemon, Auto.WritePlayerInfoPokemon, "InfoPokemon", false)
	Base.WriteList(writer, val.AvailableSkinParts, writer.WriteUInt32, 0, "AvailableSkinParts", false, 0, nil)
	Base.WriteComplex(writer, val.InfoArmory, Auto.WritePlayerInfoArmory, "InfoArmory", false)
	Base.WritePrimitive(writer, val.ActiveSpirit, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.DisableBadgeInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteDisableBadgeInfo, "DisableBadgeInfo", false), nil, "DisableBadgeInfoDict", false, 0)
	Base.WriteComplex(writer, val.InfoFightStyle, Auto.WritePlayerInfoFightStyle, "InfoFightStyle", false)
	Base.WritePrimitive(writer, val.CommonSpiritTalentExp, writer.WriteUInt32, 0)
end

function Auto.WritePlayerClientInspireHubInfo(writer, val)
	Base.WriteDict(writer, val.TodayGamePlayJoinCountDict, writer.WriteUInt32, writer.WriteInt32, 0, "TodayGamePlayJoinCountDict", false, 0)
end

function Auto.WritePlayerDieInfo(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SourceTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SourceCreationId, writer.WriteUInt32, 0)
end

function Auto.WritePlayerFashionsInfo(writer, val)
	Base.WriteDict(writer, val.SpiritFashionsInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritFashionsInfo, "SpiritFashionsInfo", false), nil, "SpiritFashionsInfoDict", false, 0)
	Base.WriteDict(writer, val.FashionInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFashionInfo, "FashionInfo", false), nil, "FashionInfoDict", false, 0)
	Base.WriteList(writer, val.FavoriteFashionIdList, writer.WriteUInt32, 0, "FavoriteFashionIdList", false, 0, nil)
	Base.WriteList(writer, val.FavoriteFashionSuitIdList, writer.WriteUInt32, 0, "FavoriteFashionSuitIdList", false, 0, nil)
	Base.WritePrimitive(writer, val.DefaultSpiritIsInitDefaultFashion, writer.WriteBoolean, false)
	Base.WriteDict(writer, val.SpiritId2TaskTryWearInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteTaskTryFashionInfo, "TaskTryFashionInfo", false), nil, "SpiritId2TaskTryWearInfoDict", false, 0)
end

function Auto.WritePlayerFightStyleUnLockChangeInfo(writer, val)
	Base.WriteComplex(writer, val.playerInfoFightStyle, Auto.WritePlayerInfoFightStyle, "playerInfoFightStyle", true)
	Base.WriteDict(writer, val.addOrUpdateUnlockInfo, writer.WriteUInt32, writer.WriteBoolean, false, "addOrUpdateUnlockInfo", true, 0)
end

function Auto.WritePlayerGachaGroupInfo(writer, val)
	Base.WritePrimitive(writer, val.TotalDrawCount, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.ClaimedMilestoneCounts, writer.WriteUInt32, writer.WriteBoolean, false, "ClaimedMilestoneCounts", false, 0)
end

function Auto.WritePlayerGachaInfos(writer, val)
	Base.WriteDict(writer, val.PoolInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerGachaPoolInfo, "PlayerGachaPoolInfo", false), nil, "PoolInfos", false, 0)
	Base.WriteDict(writer, val.GroupInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerGachaGroupInfo, "PlayerGachaGroupInfo", false), nil, "GroupInfos", false, 0)
	Base.WriteDict(writer, val.PityInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerGachaPityInfo, "PlayerGachaPityInfo", false), nil, "PityInfos", false, 0)
end

function Auto.WritePlayerGachaPityInfo(writer, val)
	Base.WritePrimitive(writer, val.DrawCountSinceLastGrandPrize, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalDrawCount, writer.WriteUInt32, 0)
end

function Auto.WritePlayerGachaPoolInfo(writer, val)
	Base.WritePrimitive(writer, val.DrawCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HasWonGrandPrize, writer.WriteBoolean, false)
	Base.WriteDict(writer, val.WonFillerPrizeIds, writer.WriteUInt32, writer.WriteBoolean, false, "WonFillerPrizeIds", false, 0)
end

function Auto.WritePlayerHotSpringInfo(writer, val)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CompanionNpc, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Used, writer.WriteBoolean, false)
end

function Auto.WritePlayerInfoArmory(writer, val)
	Base.WriteList(writer, val.Weapons, Base.WriteComplexWrap(Auto.WriteWeaponData, "WeaponData", false), nil, "Weapons", false, 0, nil)
end

function Auto.WritePlayerInfoBadge(writer, val)
	Base.WriteDict(writer, val.Badges, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBadgeInfo, "BadgeInfo", false), nil, "Badges", false, 0)
	Base.WriteDict(writer, val.HistoryBadges, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBadgeInfo, "BadgeInfo", false), nil, "HistoryBadges", false, 0)
end

function Auto.WritePlayerInfoFightStyle(writer, val)
	Base.WriteDict(writer, val.FightStyleIsUnLocked, writer.WriteUInt32, writer.WriteBoolean, false, "FightStyleIsUnLocked", false, 0)
end

function Auto.WritePlayerInfoJobGangBoss(writer, val)
	Base.WriteDict(writer, val.GangMembers, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteGangMembersInfos, "GangMembersInfos", false), nil, "GangMembers", false, 0)
end

function Auto.WritePlayerInfoJobWasher(writer, val)
	Base.WriteDict(writer, val.MissionDic, writer.WriteUInt32, writer.WriteUInt32, 0, "MissionDic", false, 0)
	Base.WritePrimitive(writer, val.LastRefreshMissionTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurMissionIndex, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurMissionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurMissionEventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CurMissionProgress, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CurMissionStartTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.HistoryMissionResults, Base.WriteComplexWrap(Auto.WriteWasherMissionResult, "WasherMissionResult", false), nil, "HistoryMissionResults", false, 0, nil)
	Base.WriteComplex(writer, val.CurMissionResult, Auto.WriteWasherMissionResult, "CurMissionResult", true)
	Base.WriteList(writer, val.RandomMissionHistory, writer.WriteUInt32, 0, "RandomMissionHistory", false, 0, nil)
	Base.WriteDict(writer, val.Spirit2HistoryMissionInfo, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteWasherMissionHistoryInfo, "WasherMissionHistoryInfo", false), nil, "Spirit2HistoryMissionInfo", false, 0)
	Base.WritePrimitive(writer, val.HistoryMissionCnt, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HistoryMissionMoney, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TodayMissionMoney, writer.WriteInt32, 0)
end

function Auto.WritePlayerInfoPokemon(writer, val)
	Base.WriteList(writer, val.AllPokemons, Base.WriteComplexWrap(Auto.WritePokemonEnemy, "PokemonEnemy", false), nil, "AllPokemons", false, 0, nil)
	Base.WriteList(writer, val.FastFightSquad, writer.WriteUInt64, 0, "FastFightSquad", false, 0, nil)
	Base.WriteList(writer, val.EnabledBodyIds, writer.WriteUInt32, 0, "EnabledBodyIds", false, 0, nil)
	Base.WriteList(writer, val.EnabledCampIds, writer.WriteUInt32, 0, "EnabledCampIds", false, 0, nil)
	Base.WriteList(writer, val.EnabledWeaponIds, writer.WriteUInt32, 0, "EnabledWeaponIds", false, 0, nil)
end

function Auto.WritePlayerInfoPopularity(writer, val)
	Base.WritePrimitive(writer, val.Popularity, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UnderflowPopularity, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Version, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NextPopularityUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextUnderflowPopularityUpdateTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.HistoryPopularityList, Base.WriteComplexWrap(Auto.WritePopularityData, "PopularityData", false), nil, "HistoryPopularityList", false, 0, nil)
	Base.WritePrimitive(writer, val.LastUnderflowPopularitySpeed, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.WalletRewards, Base.WriteComplexWrap(Auto.WritePopularityWalletRewardData, "PopularityWalletRewardData", false), nil, "WalletRewards", false, 0, nil)
	Base.WritePrimitive(writer, val.TotalLeftMoney, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.DropList, Base.WriteComplexWrap(Auto.WritePopularityDropData, "PopularityDropData", false), nil, "DropList", false, 0, nil)
	Base.WriteList(writer, val.ChangeList, Base.WriteComplexWrap(Auto.WritePopularityChangeInfo, "PopularityChangeInfo", false), nil, "ChangeList", false, 0, nil)
	Base.WritePrimitive(writer, val.LastDiff, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.LastPopularityUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextYesterdayAvgPopularityUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.YesterdayAvgPopularity, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TodayCoinGet, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.PastHoursCoinRewards, Base.WriteComplexWrap(Auto.WritePopularityWalletRewardData, "PopularityWalletRewardData", false), nil, "PastHoursCoinRewards", false, 0, nil)
end

function Auto.WritePlayerInteractionActionInfo(writer, val)
	Base.WriteDict(writer, val.UnlockActionItemDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePlayerInteractionActionItem, "PlayerInteractionActionItem", false), nil, "UnlockActionItemDict", false, 0)
	Base.WritePrimitive(writer, val.InvitedNotDisturb, writer.WriteBoolean, false)
end

function Auto.WritePlayerInteractionActionItem(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ShowRedPoint, writer.WriteBoolean, false)
end

function Auto.WritePlayerInvestigateCountryInfo(writer, val)
	Base.WritePrimitive(writer, val.CountryId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Reputation, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsShow, writer.WriteBoolean, false)
	Base.WriteList(writer, val.GalleryInfos, Base.WriteComplexWrap(Auto.WritePlayerInvestigateGalleryInfo, "PlayerInvestigateGalleryInfo", false), nil, "GalleryInfos", false, 0, nil)
end

function Auto.WritePlayerInvestigateGalleryInfo(writer, val)
	Base.WritePrimitive(writer, val.GalleryId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsArchived, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

function Auto.WritePlayerItemDayCount(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

function Auto.WritePlayerLinkPlanningBoardInfo(writer, val)
	Base.WritePrimitive(writer, val.EnableMaxMultiPlayerId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsSingleGame, writer.WriteBoolean, false)
	Base.WriteList(writer, val.MultiGamePutInKeyCountInfoList, Base.WriteComplexWrap(Auto.WriteItemCountInfo, "ItemCountInfo", true), nil, "MultiGamePutInKeyCountInfoList", true, 0, nil)
end

function Auto.WritePlayerLoginOption(writer, val)
	Base.WritePrimitive(writer, val.Mode, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Reason, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.FastPlayRaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.JumpToMainEvent, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SceneItemQuality, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.FastPlayPosition, Auto.WriteUXVector3, "FastPlayPosition")
	Base.WritePrimitive(writer, val.FromWhere, writer.WriteByte, 0)
end

function Auto.WritePlayerMahjongInfo(writer, val)
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
end

function Auto.WritePlayerMatchInfo(writer, val)
	Base.WriteDict(writer, val.GameId2LastPlayTime, writer.WriteUInt32, writer.WriteUInt32, 0, "GameId2LastPlayTime", false, 0)
	Base.WritePrimitive(writer, val.LastInviteAllTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.AvailablePrepareActions, writer.WriteUInt32, 0, "AvailablePrepareActions", false, 0, nil)
	Base.WritePrimitive(writer, val.InWorldBattle, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.LoadingTypeInfo, Auto.WriteLoadingTypeInfo, "LoadingTypeInfo", false)
	Base.WritePrimitive(writer, val.DeviceLevel, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CurLinkDeviceLevel, writer.WriteByte, 0)
end

function Auto.WritePlayerMonthCardInfo(writer, val)
	Base.WritePrimitive(writer, val.LastReceiveTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
end

function Auto.WritePlayerPackItem(writer, val)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsNew, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ExpiryTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RemindState, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CDFinishTime, writer.WriteUInt32, 0)
end

function Auto.WritePlayerPartyInfo(writer, val)
	Base.WritePrimitive(writer, val.PartyTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.lastPartyTime, writer.WriteUInt64, 0)
end

function Auto.WritePlayerPhoneInfo(writer, val)
	Base.WriteDict(writer, val.SpiritPhoneInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePhoneInfos, "PhoneInfos", false), nil, "SpiritPhoneInfos", false, 0)
	Base.WriteList(writer, val.DownLoadAppIds, writer.WriteUInt32, 0, "DownLoadAppIds", false, 0, nil)
end

function Auto.WritePlayerVehicleClientDetail(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
end

function Auto.WritePlayerVehicleDetail(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.Parts, Base.WriteComplexWrap(Auto.WritePlayerVehiclePartInfo, "PlayerVehiclePartInfo", false), nil, "Parts", false, 0, nil)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
end

function Auto.WritePlayerVehicleDriveStateInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.EnterOrLeave, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.VehicleEntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IfForce, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OpenDoorTypeId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OpenDoorActionSpeed, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.OpenDoorActionClipLength, writer.WriteInt32, 0)
end

function Auto.WritePlayerVehicleInfo(writer, val)
	Base.WriteList(writer, val.UnlockedVehicles, Base.WriteComplexWrap(Auto.WritePlayerVehicleDetail, "PlayerVehicleDetail", false), nil, "UnlockedVehicles", false, 0, nil)
	Base.WritePrimitive(writer, val.RequisitionVehicleCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ParkingVehicleId, writer.WriteUInt32, 0)
end

function Auto.WritePlayerVehiclePartInfo(writer, val)
	Base.WritePrimitive(writer, val.VehiclePartId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.VehiclePartTag, writer.WriteUInt32, 0)
end

function Auto.WritePlotMinMaxRange(writer, val)
	Base.WritePrimitive(writer, val.min, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.max, writer.WriteSingle, 0)
end

function Auto.WritePointInteractInfo(writer, val)
	Base.WritePrimitive(writer, val.NodeId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Sprite, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LabelId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DoNotFocusCamera, writer.WriteBoolean, false)
	Base.WriteStruct(writer, val.PlayerAction, Auto.WritePointInteractPlayerAction, "PlayerAction")
end

function Auto.WritePointInteractPlayerAction(writer, val)
	Base.WritePrimitive(writer, val.CommonInteractType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.InteractPosType, writer.WriteByte, 0)
	Base.WriteStruct(writer, val.InteractPos, Auto.WriteUXVector3, "InteractPos")
	Base.WriteStruct(writer, val.InteractPosForward, Auto.WriteUXVector3, "InteractPosForward")
	Base.WritePrimitive(writer, val.InteractRadius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.InteractLoopTime, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.InteractIkPos, Auto.WriteUXVector3, "InteractIkPos")
	Base.WriteStruct(writer, val.InteractIkPosForward, Auto.WriteUXVector3, "InteractIkPosForward")
	Base.WritePrimitive(writer, val.ChairType, writer.WriteInt32, 0)
end

function Auto.WritePokemonEnemy(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Body, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Camp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weapon, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LimboChaId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AcquireTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsLocked, writer.WriteBoolean, false)
end

function Auto.WritePoliceCaseInfo(writer, val)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.Fines, writer.WriteUInt32, 0, "Fines", false, 0, nil)
	Base.WritePrimitive(writer, val.Sentence, writer.WriteInt32, 0)
	Base.WriteList(writer, val.Drops, writer.WriteUInt32, 0, "Drops", false, 0, nil)
	Base.WritePrimitive(writer, val.RewardTaken, writer.WriteBoolean, false)
	Base.WriteList(writer, val.BonusDrops, writer.WriteUInt32, 0, "BonusDrops", false, 0, nil)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
end

function Auto.WritePoliceChargingSkillInfo(writer, val)
	Base.WritePrimitive(writer, val.ChargingSkillId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

function Auto.WritePoliceDispatchExtraInfo(writer, val)
	Base.WritePrimitive(writer, val.PrisonerId, writer.WriteUInt64, 0)
end

function Auto.WritePoliceDispatchInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NextAvailableTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsTemp, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.TempEventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TodayArrestSupportTimes, writer.WriteUInt32, 0)
end

function Auto.WritePoliceDutyBasicInfo(writer, val)
	Base.WritePrimitive(writer, val.DailyViolationCount, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeaveDueTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastViolationUpdateTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.ServiceData, Auto.WritePoliceServiceData, "ServiceData", false)
	Base.WriteComplex(writer, val.WeeklyServiceData, Auto.WritePoliceServiceData, "WeeklyServiceData", false)
	Base.WriteDict(writer, val.ViolationCdInfos, writer.WriteUInt32, writer.WriteUInt32, 0, "ViolationCdInfos", false, 0)
end

function Auto.WritePoliceFakeClueAgentInfo(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsRead, writer.WriteBoolean, false)
end

function Auto.WritePoliceFakeFileInfo(writer, val)
	Base.WritePrimitive(writer, val.CurFakeFileId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ClueValue, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.UnlockFileInfoDict, writer.WriteUInt32, writer.WriteByte, 0, "UnlockFileInfoDict", false, 0)
	Base.WriteList(writer, val.HistoryClueAgentInfoList, Base.WriteComplexWrap(Auto.WritePoliceFakeClueAgentInfo, "PoliceFakeClueAgentInfo", false), nil, "HistoryClueAgentInfoList", false, 256, nil)
end

function Auto.WritePoliceServiceData(writer, val)
	Base.WritePrimitive(writer, val.DispatchTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PatrolTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ArrestTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FineCount, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.TotalDrops, writer.WriteUInt32, 0, "TotalDrops", false, 0, nil)
	Base.WritePrimitive(writer, val.LastUpdateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CarFineCount, writer.WriteUInt32, 0)
end

function Auto.WritePoliceVehicleSpawnClientInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

function Auto.WritePoliceVehicleSpawnConfigInfo(writer, val)
	Base.WritePrimitive(writer, val.ChaseRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ChaseDirectlyRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ApprehendRange, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NavConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ChaseDirectlyConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PatrolSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ChaseSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ChaseDirectlySpeed, writer.WriteSingle, 0)
end

function Auto.WritePoliceViolationInfo(writer, val)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LeaveDueTime, writer.WriteUInt32, 0)
end

function Auto.WritePopularityChangeInfo(writer, val)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MaxValue, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Duration, writer.WriteUInt32, 0)
end

function Auto.WritePopularityData(writer, val)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Value, writer.WriteSingle, 0)
end

function Auto.WritePopularityDropData(writer, val)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DropId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteUInt32, 0)
end

function Auto.WritePopularityWalletRewardData(writer, val)
	Base.WritePrimitive(writer, val.Date, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Reward, writer.WriteUInt32, 0)
end

function Auto.WritePosServerEffectData(writer, val)
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

function Auto.WritePossiblePlayerData(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer:WriteString(val.Name, false, "Name", 0)
	writer:WriteString(val.RaidName, true, "RaidName", 0)
end

function Auto.WritePostPlayerCommentClientInfo(writer, val)
	writer:WriteString(val.Comment, false, "Comment", 0)
	Base.WritePrimitive(writer, val.CommentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsFinish, writer.WriteBoolean, false)
end

function Auto.WritePostSimpleClientInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PostType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PostConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Date, writer.WriteUInt32, 0)
	writer:WriteString(val.ImageUrl, true, "ImageUrl", 0)
	Base.WritePrimitive(writer, val.Approved, writer.WriteBoolean, false)
	writer:WriteString(val.Title, true, "Title", 0)
	Base.WritePrimitive(writer, val.Likes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Liked, writer.WriteBoolean, false)
	Base.WriteList(writer, val.LikeNpcs, writer.WriteUInt32, 0, "LikeNpcs", true, 0, nil)
	Base.WriteList(writer, val.Comments, writer.WriteUInt32, 0, "Comments", true, 0, nil)
	Base.WriteList(writer, val.PlayerComments, Base.WriteComplexWrap(Auto.WritePostPlayerCommentClientInfo, "PostPlayerCommentClientInfo", true), nil, "PlayerComments", true, 0, nil)
	Base.WritePrimitive(writer, val.IsRead, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HasNewLike, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AcquireCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActivityCfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsStory, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsPinStory, writer.WriteBoolean, false)
end

function Auto.WritePreSwitchSpiritData(writer, val)
	Base.WritePrimitive(writer, val.SwitchSpiritConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PreSwitchSpiritType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.DestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NewSpiritConfigId, writer.WriteUInt32, 0)
end

function Auto.WriteQueryComponentInfo(writer, val)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	writer:WriteString(val.Name, false, "Name", 1024)
	Base.WritePrimitive(writer, val.Script, writer.WriteBoolean, false)
end

function Auto.WriteQueryFieldInfo(writer, val)
	writer:WriteString(val.Name, true, "Name", 0)
	writer:WriteString(val.Value, true, "Value", 0)
	writer:WriteString(val.FieldType, true, "FieldType", 0)
	writer:WriteString(val.SelfType, true, "SelfType", 0)
	writer:WriteString(val.Exception, true, "Exception", 0)
	Base.WritePrimitive(writer, val.CanWrite, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Leaf, writer.WriteBoolean, false)
end

function Auto.WriteQueryGameObjectFilter(writer, val)
	Base.WriteList(writer, val.Path, writer.WriteInt32, 0, "Path", true, 0, nil)
	writer:WriteString(val.Name, true, "Name", 0)
end

function Auto.WriteRacingInfo(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.AIVehicleInfos, writer.WriteUInt64, writer.WriteUInt32, 0, "AIVehicleInfos", false, 0)
end

function Auto.WriteRacingParameters(writer, val)
	writer:WriteString(val.raceName, false, "raceName", 0)
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
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteRaidBattleData(writer, val)
	Base.WritePrimitive(writer, val.EnterRaidTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BattleTime, writer.WriteDouble, 0)
	Base.WriteList(writer, val.SpiritBattleDatas, Base.WriteComplexWrap(Auto.WriteSpiritBattleData, "SpiritBattleData", false), nil, "SpiritBattleDatas", false, 0, nil)
	Base.WritePrimitive(writer, val.ElementEffectCount, writer.WriteUInt32, 0)
end

function Auto.WriteRaidBattleUnitAgent(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.FacingDirection, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OwnerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ManagedPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NavTags, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.GroundData, Auto.WriteMoveActionGroundData, "GroundData")
	Base.WritePrimitive(writer, val.ModelId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HSummonIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SpoonAgentId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SuitId, writer.WriteUInt32, 0)
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
	Base.WritePrimitive(writer, val.TransformAgentId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.SpiritWearFashionsInfo, Auto.WriteOtherPlayerSpiritWearFashionsInfo, "SpiritWearFashionsInfo", true)
	Base.WritePrimitive(writer, val.Begging, writer.WriteBoolean, false)
end

function Auto.WriteRaidBattleUnitSpirit(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.FacingDirection, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.OwnerId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ManagedPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NavTags, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.GroundData, Auto.WriteMoveActionGroundData, "GroundData")
	Base.WritePrimitive(writer, val.TransformAgentId, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.SpiritWearFashionsInfo, Auto.WriteOtherPlayerSpiritWearFashionsInfo, "SpiritWearFashionsInfo", true)
	Base.WritePrimitive(writer, val.Begging, writer.WriteBoolean, false)
end

function Auto.WriteRaidCleaningInfo(writer, val)
	Base.WritePrimitive(writer, val.CleaningProcess, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DropId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalSecond, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RewardRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ProficiencyRate, writer.WriteSingle, 0)
end

function Auto.WriteRaidGamePlayInfo(writer, val)
	Base.WriteDict(writer, val.RecordValueInfo, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteRaidGamePlayRecordValueInfo, "RaidGamePlayRecordValueInfo", false), nil, "RecordValueInfo", true, 0)
end

function Auto.WriteRaidGamePlayRecordValueInfo(writer, val)
	Base.WriteDict(writer, val.DoubleValueDic, writer.WriteUInt32, writer.WriteDouble, 0, "DoubleValueDic", false, 0)
end

function Auto.WriteRaidVehicleGpsInfo(writer, val)
	Base.WritePrimitive(writer, val.BelongPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetRaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetInstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.TargetPosition, Auto.WriteUXVector3, "TargetPosition")
end

function Auto.WriteRaidVehicleSeatInfo(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SeatIndex, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.SeatState, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.DestroyRelated, writer.WriteBoolean, false)
end

function Auto.WriteRaidVehicleSyncData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.facingDirection, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Velocity, Auto.WriteUXVector3, "Velocity")
	Base.WriteList(writer, val.Bits, writer.WriteByte, 0, "Bits", false, 1024, nil)
end

function Auto.WriteRamParameters(writer, val)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StraightLineDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UseContinuousRam, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteRangeMoveType(writer, val)
	Base.WritePrimitive(writer, val.MinDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Method, writer.WriteByte, 0)
end

function Auto.WriteRelationVO(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Both, writer.WriteBoolean, false)
	writer:WriteString(val.RemarkName, true, "RemarkName", 0)
end

function Auto.WriteReportBehaviorSeqStartInfo(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.PointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CommandIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Cmd, Auto.WriteBehaviorSeqCommand, "Cmd")
end

function Auto.WriteResetFashionColoringInfo(writer, val)
	Base.WriteList(writer, val.resetColoringTypeList, writer.WriteByte, 0, "resetColoringTypeList", true, 0, nil)
end

function Auto.WriteResetFashionColoringSchemeInfo(writer, val)
	Base.WritePrimitive(writer, val.FashionId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.resetFashionColoringSchemeInfoDict, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteResetFashionColoringInfo, "ResetFashionColoringInfo", false), nil, "resetFashionColoringSchemeInfoDict", true, 0)
end

function Auto.WriteRestaurantResult(writer, val)
	Base.WritePrimitive(writer, val.RestaurantId, writer.WriteUInt32, 0)
end

function Auto.WriteRewardCollectionInfo(writer, val)
	Base.WritePrimitive(writer, val.CountryId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BlockId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SubQuestId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Count, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TotalCount, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.InvestigatorGalleryId, writer.WriteUInt32, 0)
end

function Auto.WriteRewardDetail(writer, val)
	Base.WriteDict(writer, val.DropIdCnt, writer.WriteUInt32, writer.WriteUInt32, 0, "DropIdCnt", false, 0)
	Base.WritePrimitive(writer, val.ReasonTextId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FactionMerge, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Money, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Gold, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.BindingGold, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FreeGold, writer.WriteUInt32, 0)
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
end

function Auto.WriteRewardExtraInfo(writer, val)
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
end

function Auto.WriteRewardInfo(writer, val)
	Base.WritePrimitive(writer, val.Reason, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.RewardTemplate, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.FirstItemInfo, writer.WriteUInt32, 0, "FirstItemInfo", false, 0, nil)
	Base.WriteComplex(writer, val.ExtraInfo, Auto.WriteRewardExtraInfo, "ExtraInfo", true)
	Base.WriteDict(writer, val.Reward, writer.WriteByte, Base.WriteComplexWrap(Auto.WriteRewardDetail, "RewardDetail", false), nil, "Reward", false, 0)
end

function Auto.WriteRewardUrbanAbilityInfo(writer, val)
	Base.WritePrimitive(writer, val.SpiritTemplateId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.OriginalUrbanAbilities, writer.WriteInt32, 0, "OriginalUrbanAbilities", false, 0, nil)
	Base.WriteList(writer, val.UrbanAbilities, writer.WriteInt32, 0, "UrbanAbilities", false, 0, nil)
end

function Auto.WriteRollIntervalMessage(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	writer:WriteString(val.Content, false, "Content", 0)
	Base.WritePrimitive(writer, val.Interval, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTime, writer.WriteUInt32, 0)
end

function Auto.WriteSceneCreationInfo(writer, val)
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

function Auto.WriteSceneFogMap(writer, val)
	Base.WriteList(writer, val.FogValue, writer.WriteByte, 0, "FogValue", true, 0, nil)
	Base.WritePrimitive(writer, val.All, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.LockCnt, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.XSize, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ZSize, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TileSize, writer.WriteInt32, 0)
end

function Auto.WriteSceneItemDropActionInfo(writer, val)
	Base.WritePrimitive(writer, val.hosterInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.sceneItemInstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.hosterPosition, Auto.WriteUXVector3, "hosterPosition")
	Base.WritePrimitive(writer, val.isDestroyImmediately, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.yForce, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.zForce, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.gravity, writer.WriteSingle, 0)
end

function Auto.WriteSceneItemOccupantInfo(writer, val)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.FightSpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AttractNpcPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsState, writer.WriteBoolean, false)
end

function Auto.WriteSceneRoomChangeData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Enable, writer.WriteBoolean, false)
end

function Auto.WriteSeatInfo(writer, val)
	Base.WritePrimitive(writer, val.Score, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HoldsCount, writer.WriteInt32, 0)
	Base.WriteList(writer, val.Holds, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "Holds"), nil, "Holds", true, 0, nil)
	Base.WriteList(writer, val.Folds, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "Folds"), nil, "Folds", false, 0, nil)
	Base.WriteList(writer, val.Sequence, Base.WriteComplexWrap(Auto.WriteMjPCGActionInfo, "MjPCGActionInfo", false), nil, "Sequence", false, 0, nil)
	Base.WritePrimitive(writer, val.ReachFoldCnt, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Que, writer.WriteByte, 0)
	Base.WriteList(writer, val.HuanPais, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "HuanPais"), nil, "HuanPais", true, 0, nil)
	Base.WriteList(writer, val.HuPais, Base.WriteStructWrap(Auto.WriteMjPaiInfo, "HuPais"), nil, "HuPais", false, 0, nil)
end

function Auto.WriteSerializeMinMaxAABB(writer, val)
	Base.WriteStruct(writer, val.Min, Auto.WriteFloat3, "Min")
	Base.WriteStruct(writer, val.Max, Auto.WriteFloat3, "Max")
end

function Auto.WriteSerializeQuaternion(writer, val)
	Base.WritePrimitive(writer, val.x, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.y, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.z, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.w, writer.WriteSingle, 0)
end

function Auto.WriteServerEffectData(writer, val)
	Base.WritePrimitive(writer, val.EffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.LogicEndTime, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ClientDestructibleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Duration, writer.WriteSingle, 0)
end

function Auto.WriteServerSimpleGridInfo(writer, val)
	Base.WritePrimitive(writer, val.MinX, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MinZ, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MaxX, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MaxZ, writer.WriteInt32, 0)
end

function Auto.WriteSetEmotionData(writer, val)
	Base.WritePrimitive(writer, val.AgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Emotion, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteUInt32, 0)
end

function Auto.WriteSimpleMailAttchment(writer, val)
	Base.WritePrimitive(writer, val.ItemId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnbindMoney, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.BindGold, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PayGold, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FreeGold, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WeaponId, writer.WriteUInt32, 0)
end

function Auto.WriteSimpleUnreadMessage(writer, val)
	Base.WritePrimitive(writer, val.PostId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CommentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MessageType, writer.WriteInt32, 0)
end

function Auto.WriteSimpleVehicleSyncData(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TimeStamp, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.facingDirection, writer.WriteSingle, 0)
end

function Auto.WriteSkillCreationData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

function Auto.WriteSkillDestructibleData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
end

function Auto.WriteSkillExecuteData(writer, val)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ParentTriggerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.StiffId, writer.WriteUInt32, 0)
end

function Auto.WriteSkillHitData(writer, val)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SkillId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TriggerInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Stage, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.HitTarget, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.HitDestructible, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AttachedDestructibleId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.ClientHitPosition, Auto.WriteUXVector3, "ClientHitPosition")
	Base.WriteStruct(writer, val.ClientHitPosNormalDir, Auto.WriteUXVector3, "ClientHitPosNormalDir")
	Base.WritePrimitive(writer, val.SkillHitType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.HitMaterial, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.HitCenter, Auto.WriteUXVector3, "HitCenter")
	Base.WritePrimitive(writer, val.StiffId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StiffTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HurtEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FirmHurt, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ShieldDefendIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsBackHit, writer.WriteBoolean, false)
end

function Auto.WriteSkillParam(writer, val)
	Base.WritePrimitive(writer, val.entityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.targetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.moveId, writer.WriteInt32, 0)
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
	Base.WriteList(writer, val.DesignerPosList, Base.WriteStructWrap(Auto.WriteUXVector3, "DesignerPosList"), nil, "DesignerPosList", true, 0, nil)
	Base.WritePrimitive(writer, val.SectionRepeatTimes, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SeqConfigID, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.SelfMobilityPos, Auto.WriteUXVector3, "SelfMobilityPos")
	Base.WriteStruct(writer, val.TarMobilityPos, Auto.WriteUXVector3, "TarMobilityPos")
end

function Auto.WriteSkillShieldData(writer, val)
	Base.WritePrimitive(writer, val.SkillInstanceId, writer.WriteInt32, 0)
end

function Auto.WriteSkillStateData(writer, val)
	Base.WritePrimitive(writer, val.SkillInstanceId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.StateIds, writer.WriteUInt32, 0, "StateIds", false, 32, nil)
end

function Auto.WriteSkillSummonData(writer, val)
	Base.WritePrimitive(writer, val.SkillInstanceId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
end

function Auto.WriteSkillTimeCurveData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TriggerIndex, writer.WriteInt32, 0)
end

function Auto.WriteSkillUseData(writer, val)
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

function Auto.WriteSpawnAreaSelector(writer, val)
	Base.WriteComplex(writer, val.SpawnArea, Auto.WriteMassTrafficSpawnArea, "SpawnArea", false)
	Base.WritePrimitive(writer, val.Selected, writer.WriteBoolean, false)
end

function Auto.WriteSpawnLaneSelector(writer, val)
	Base.WritePrimitive(writer, val.SpawnLaneType, writer.WriteByte, 0)
	Base.WriteStruct(writer, val.FirstArea, Auto.WriteAreaColliderParams, "FirstArea")
	Base.WriteStruct(writer, val.SecondArea, Auto.WriteAreaColliderParams, "SecondArea")
end

function Auto.WriteSpinOutParameters(writer, val)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteSpiritAbilityInfo(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NewLevel, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ConfirmedLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.BuffList, writer.WriteUInt32, 0, "BuffList", false, 0, nil)
	Base.WriteList(writer, val.AbilityBuffConfigIdList, writer.WriteUInt32, 0, "AbilityBuffConfigIdList", false, 0, nil)
end

function Auto.WriteSpiritAddWeaponAction(writer, val)
	Base.WritePrimitive(writer, val.SpiritTid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SlotIndex, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.Weapon, Auto.WriteWeaponDetail, "Weapon", false)
end

function Auto.WriteSpiritBartenderInfo(writer, val)
	Base.WriteDict(writer, val.BartenderId2ElementInfosDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBartenderElementInfos, "BartenderElementInfos", false), nil, "BartenderId2ElementInfosDict", false, 0)
	Base.WriteDict(writer, val.BartenderId2GameInfosDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteBartenderGameInfos, "BartenderGameInfos", false), nil, "BartenderId2GameInfosDict", false, 0)
end

function Auto.WriteSpiritBattleData(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StoneLevel, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalDamage, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HighestDamage, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalHeal, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TotalDamaged, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritBattleInfo(writer, val)
	Base.WritePrimitive(writer, val.IsUniqueSkillLocked, writer.WriteBoolean, false)
end

function Auto.WriteSpiritDrawViewData(writer, val)
	Base.WriteComplex(writer, val.SpiritInfo, Auto.WriteSpiritInfo, "SpiritInfo", false)
end

function Auto.WriteSpiritFashionsInfo(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.FashionCustomSuitSchemeInfos, Base.WriteComplexWrap(Auto.WriteFashionCustomSuitSchemeInfo, "FashionCustomSuitSchemeInfo", false), nil, "FashionCustomSuitSchemeInfos", false, 0, nil)
	Base.WriteDict(writer, val.FashionFunctionSuitSchemeInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteFashionFunctionSuitSchemeInfo, "FashionFunctionSuitSchemeInfo", false), nil, "FashionFunctionSuitSchemeInfoDict", false, 0)
	Base.WriteComplex(writer, val.SpiritWearFashionsInfo, Auto.WriteSpiritWearFashionsInfo, "SpiritWearFashionsInfo", false)
	Base.WriteComplex(writer, val.SpiritPrevWearFashionsInfo, Auto.WriteSpiritWearFashionsInfo, "SpiritPrevWearFashionsInfo", true)
	Base.WriteList(writer, val.FirstGainSuitIdList, writer.WriteUInt32, 0, "FirstGainSuitIdList", true, 0, nil)
	Base.WritePrimitive(writer, val.EnableClientTryWearCount, writer.WriteByte, 0)
end

function Auto.WriteSpiritFightStyleInfo(writer, val)
	Base.WriteDict(writer, val.FightStyleInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "FightStyleInfo", false, 0)
end

function Auto.WriteSpiritFightTypeChangeAction(writer, val)
	Base.WritePrimitive(writer, val.spiritId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.fullInfo, Auto.WriteSpiritFightStyleInfo, "fullInfo", true)
	Base.WriteDict(writer, val.addOrUpdateInfo, writer.WriteUInt32, writer.WriteUInt32, 0, "addOrUpdateInfo", true, 0)
end

function Auto.WriteSpiritGroupChatInfo(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CreateTime, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritHackerJobInfo(writer, val)
	writer:WriteString(val.HackerName, true, "HackerName", 0)
	Base.WriteDict(writer, val.PostInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteHackerPostInfo, "HackerPostInfo", false), nil, "PostInfos", false, 0)
	Base.WritePrimitive(writer, val.Rank, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.DailyCounts, Auto.WriteDailyHackerCounts, "DailyCounts", false)
end

function Auto.WriteSpiritInfo(writer, val)
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
	Base.WritePrimitive(writer, val.CurrentJobId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.SpiritBattleInfo, Auto.WriteSpiritBattleInfo, "SpiritBattleInfo", false)
	Base.WriteComplex(writer, val.TalentInfo, Auto.WriteSpiritTalentInfo, "TalentInfo", false)
	Base.WriteComplex(writer, val.SpiritFightStyle, Auto.WriteSpiritFightStyleInfo, "SpiritFightStyle", false)
	Base.WritePrimitive(writer, val.Blocked, writer.WriteBoolean, false)
end

function Auto.WriteSpiritInitData(writer, val)
	Base.WritePrimitive(writer, val.Id, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsActive, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.WeaponTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.WeaponSkinId, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritJob(writer, val)
	Base.WritePrimitive(writer, val.Job, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.RegisterTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.UnregisterTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.TalentInfo, Auto.WriteSpiritJobTalentInfo, "TalentInfo", false)
end

function Auto.WriteSpiritJobInfo(writer, val)
	Base.WritePrimitive(writer, val.CurrentJob, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.AvailableJobs, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritJob, "SpiritJob", false), nil, "AvailableJobs", false, 0)
	Base.WriteDict(writer, val.HistoryJobs, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritJob, "SpiritJob", false), nil, "HistoryJobs", false, 0)
end

function Auto.WriteSpiritJobTalentInfo(writer, val)
	Base.WritePrimitive(writer, val.TalentPoint, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.UnlockTalentInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritOrJobTalentNodeInfo, "SpiritOrJobTalentNodeInfo", false), nil, "UnlockTalentInfoDict", false, 0)
	Base.WritePrimitive(writer, val.SpentTalentPoint, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritMobileSkinInfo(writer, val)
	Base.WritePrimitive(writer, val.Wallpaper, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Decoration, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Pendant, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritOrJobTalentNodeInfo(writer, val)
	Base.WritePrimitive(writer, val.TalentId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Layer, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritPanelData(writer, val)
	Base.WritePrimitive(writer, val.FightSpiritId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.UrbanAttrs, writer.WriteUInt32, writer.WriteSingle, 0, "UrbanAttrs", false, 0)
	Base.WritePrimitive(writer, val.MaxHp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Dam, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DefDeduct, writer.WriteSingle, 0)
end

function Auto.WriteSpiritPoliceJobInfo(writer, val)
	Base.WriteDict(writer, val.DispatchInfos, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WritePoliceDispatchInfo, "PoliceDispatchInfo", false), nil, "DispatchInfos", false, 0)
	Base.WriteList(writer, val.ViolationInfos, Base.WriteComplexWrap(Auto.WritePoliceViolationInfo, "PoliceViolationInfo", false), nil, "ViolationInfos", false, 0, nil)
	Base.WriteList(writer, val.CaseInfos, Base.WriteComplexWrap(Auto.WritePoliceCaseInfo, "PoliceCaseInfo", false), nil, "CaseInfos", false, 0, nil)
	Base.WriteComplex(writer, val.DutyBasicInfo, Auto.WritePoliceDutyBasicInfo, "DutyBasicInfo", false)
	Base.WriteList(writer, val.EscortedNpcs, writer.WriteUInt64, 0, "EscortedNpcs", false, 0, nil)
	Base.WriteComplex(writer, val.PoliceFakeFileInfo, Auto.WritePoliceFakeFileInfo, "PoliceFakeFileInfo", true)
	Base.WriteDict(writer, val.PeriodInvalidVehicleFine2CountDict, writer.WriteUInt32, writer.WriteUInt32, 0, "PeriodInvalidVehicleFine2CountDict", false, 0)
	Base.WritePrimitive(writer, val.NextPeriodUpdateTime, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritRemoveWeaponAction(writer, val)
	Base.WritePrimitive(writer, val.SpiritTid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.WeaponUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Reason, writer.WriteByte, 0)
end

function Auto.WriteSpiritSwitchWeaponAction(writer, val)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.WeaponInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Reason, writer.WriteByte, 0)
end

function Auto.WriteSpiritTalentExpInfo(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TalentExp, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritTalentInfo(writer, val)
	Base.WritePrimitive(writer, val.Exp, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Level, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TalentPoint, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.UnlockTalentInfoDict, writer.WriteUInt32, Base.WriteComplexWrap(Auto.WriteSpiritOrJobTalentNodeInfo, "SpiritOrJobTalentNodeInfo", false), nil, "UnlockTalentInfoDict", false, 0)
	Base.WritePrimitive(writer, val.SpentTalentPoint, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritUpdateWeaponAction(writer, val)
	Base.WritePrimitive(writer, val.SpiritTid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WriteComplex(writer, val.Weapon, Auto.WriteWeaponDetail, "Weapon", false)
end

function Auto.WriteSpiritUrbanSkill(writer, val)
	Base.WriteList(writer, val.UrbanAbilities, writer.WriteInt32, 0, "UrbanAbilities", false, 0, nil)
end

function Auto.WriteSpiritVirtualFightStyleInfo(writer, val)
	Base.WritePrimitive(writer, val.SpiritId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FightStyleTypeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.FightStyleId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
end

function Auto.WriteSpiritWeaponDetail(writer, val)
	Base.WritePrimitive(writer, val.SpiritTid, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpiritUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CurrentWeaponUid, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.WeaponSlots, Base.WriteComplexWrap(Auto.WriteWeaponDetail, "WeaponDetail", false), nil, "WeaponSlots", false, 0, nil)
	Base.WriteComplex(writer, val.CurrentTempWeapon, Auto.WriteWeaponDetail, "CurrentTempWeapon", true)
	Base.WriteComplex(writer, val.TempWeaponSlots, Auto.WriteWeaponWheelData, "TempWeaponSlots", true)
end

function Auto.WriteSpiritWearFashionsInfo(writer, val)
	Base.WritePrimitive(writer, val.FunctionSuitId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsTryWear, writer.WriteBoolean, false)
	Base.WriteList(writer, val.WearFashionInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionInfo, "WearFashionInfo", false), nil, "WearFashionInfoList", false, 32, nil)
	Base.WriteList(writer, val.WearFashionEditInfoList, Base.WriteComplexWrap(Auto.WriteWearFashionEditInfo, "WearFashionEditInfo", true), nil, "WearFashionEditInfoList", true, 32, nil)
	Base.WritePrimitive(writer, val.HiddenParts, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EditedHiddenParts, writer.WriteByte, 0)
end

function Auto.WriteSpoonActionParam(writer, val)
	Base.WriteDict(writer, val.PortToValue, writer.WriteInt32, Base.WriteStringWrap(false, "PortToValue", 1024), nil, "PortToValue", true, 1024)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
end

function Auto.WriteSpoonClientActionTaskInfo(writer, val)
	Base.WritePrimitive(writer, val.NodeTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ContextTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WriteDict(writer, val.Pid2Index, writer.WriteUInt64, writer.WriteInt32, 0, "Pid2Index", true, 0)
end

function Auto.WriteSpoonClientData(writer, val)
	Base.WriteDict(writer, val.Enemies, writer.WriteInt32, writer.WriteUInt64, 0, "Enemies", false, 0)
	Base.WriteDict(writer, val.Npcs, writer.WriteInt32, writer.WriteUInt64, 0, "Npcs", false, 0)
	Base.WriteList(writer, val.TriggerInfos, Base.WriteComplexWrap(Auto.WriteSpoonTriggerInfo, "SpoonTriggerInfo", false), nil, "TriggerInfos", false, 0, nil)
	Base.WriteList(writer, val.SpoonRooms, Base.WriteComplexWrap(Auto.WriteSceneRoomChangeData, "SceneRoomChangeData", false), nil, "SpoonRooms", false, 0, nil)
	Base.WriteDict(writer, val.InteractiveNpcs, writer.WriteUInt32, writer.WriteBoolean, false, "InteractiveNpcs", false, 0)
end

function Auto.WriteSpoonOutputLink(writer, val)
	writer:WriteString(val.Name, false, "Name", 0)
	Base.WriteList(writer, val.NextNodes, writer.WriteInt32, 0, "NextNodes", false, 0, nil)
end

function Auto.WriteSpoonTaskClientData(writer, val)
	Base.WriteList(writer, val.TriggerInfos, Base.WriteComplexWrap(Auto.WriteSpoonTriggerInfo, "SpoonTriggerInfo", false), nil, "TriggerInfos", false, 0, nil)
	Base.WriteDict(writer, val.Enemies, writer.WriteInt32, writer.WriteUInt64, 0, "Enemies", false, 0)
	Base.WriteList(writer, val.SpoonRooms, Base.WriteComplexWrap(Auto.WriteSceneRoomChangeData, "SceneRoomChangeData", false), nil, "SpoonRooms", false, 0, nil)
	Base.WriteList(writer, val.RemovedNpcList, writer.WriteInt32, 0, "RemovedNpcList", false, 0, nil)
	Base.WriteDict(writer, val.VehicleIdDict, writer.WriteInt32, writer.WriteInt32, 0, "VehicleIdDict", false, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
end

function Auto.WriteSpoonTriggerInfo(writer, val)
	Base.WritePrimitive(writer, val.FlowIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NodeId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StartTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NeedComplete, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MemoryTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsCondition, writer.WriteBoolean, false)
	Base.WriteList(writer, val.Ports, Base.WriteComplexWrap(Auto.WriteControlFlowData, "ControlFlowData", true), nil, "Ports", true, 0, nil)
end

function Auto.WriteStartAttractInfo(writer, val)
	Base.WritePrimitive(writer, val.UnitUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AttractPointUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AttractPointId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.CenterPosition, Auto.WriteUXVector3, "CenterPosition")
	Base.WritePrimitive(writer, val.CenterAngle, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.GroupIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CommandIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.MetroId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CarriageIndex, writer.WriteInt32, 0)
end

function Auto.WriteStartPatrolInfo(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	writer:WriteString(val.FileName, false, "FileName", 0)
	Base.WritePrimitive(writer, val.HashCode, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SeqIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.GroupIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PointIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CommandIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Loop, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Return, writer.WriteBoolean, false)
end

function Auto.WriteStaticDestructibleInfo(writer, val)
	Base.WritePrimitive(writer, val.GroupId, writer.WriteInt32, 0)
	Base.WriteComplex(writer, val.Pack, Auto.WritePackedDestructibleInfo, "Pack", true)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Hp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NavId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BreakStage, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.OccupantInfos, Base.WriteStructWrap(Auto.WriteSceneItemOccupantInfo, "OccupantInfos"), nil, "OccupantInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.DropWeaponId, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.EffectIds, writer.WriteInt32, 0, "EffectIds", true, 0, nil)
end

function Auto.WriteStimEventParameter(writer, val)
	Base.WriteStruct(writer, val.Source, Auto.WriteClientActionTarget, "Source")
	Base.WriteStruct(writer, val.Source2, Auto.WriteClientActionTarget, "Source2")
end

function Auto.WriteStopParameters(writer, val)
	Base.WritePrimitive(writer, val.StopRatio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.useThrottleStop, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteSummonVehicleResult(writer, val)
	Base.WritePrimitive(writer, val.VehicleEntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TaskToken, writer.WriteUInt64, 0)
end

function Auto.WriteSurroundNpcSpawnInfo(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NpcFormworkId, writer.WriteUInt32, 0)
end

function Auto.WriteSyncCinemaQueryInfo(writer, val)
	Base.WriteList(writer, val.HaveSeenList, writer.WriteUInt32, 0, "HaveSeenList", false, 0, nil)
	Base.WriteComplex(writer, val.TicketInfo, Auto.WriteCinemaTicketInfo, "TicketInfo", true)
	Base.WritePrimitive(writer, val.InviteNpcId, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.UnlockMovies, writer.WriteUInt32, 0, "UnlockMovies", false, 0, nil)
end

function Auto.WriteSyncMultiCinemaQueryInfo(writer, val)
	Base.WritePrimitive(writer, val.LastestMovieId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.LastestMovieStartTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.TicketInfo, Auto.WriteCinemaMultiTicketInfo, "TicketInfo", true)
end

function Auto.WriteTaskDestructibleInfo(writer, val)
	Base.WritePrimitive(writer, val.PlateInlineId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.GroupId, writer.WriteUInt64, 0)
	writer:WriteString(val.TriggerTag, true, "TriggerTag", 0)
	Base.WritePrimitive(writer, val.NpcPhoneId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ExternalSystemLinkId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.NoSleep, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.MetroLineId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.MetroCarriageId, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.MetroLineCarriageInfo, Auto.WriteMetroLineCarriageInfo, "MetroLineCarriageInfo", true)
	Base.WriteDict(writer, val.ExposeParams, writer.WriteInt32, Base.WriteStringWrap(false, "ExposeParams", 0), nil, "ExposeParams", true, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PathId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WriteStruct(writer, val.Facing, Auto.WriteUXVector3, "Facing")
	Base.WritePrimitive(writer, val.iScale, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Hp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.NavId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.State, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.BreakStage, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.OccupantInfos, Base.WriteStructWrap(Auto.WriteSceneItemOccupantInfo, "OccupantInfos"), nil, "OccupantInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.DropWeaponId, writer.WriteUInt64, 0)
	Base.WriteList(writer, val.EffectIds, writer.WriteInt32, 0, "EffectIds", true, 0, nil)
end

function Auto.WriteTaskEventInfo(writer, val)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Visible, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsRiskControl, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Acceptable, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HasAccepted, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RedPoint, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.UnlockTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsUnderway, writer.WriteBoolean, false)
	Base.WriteList(writer, val.FinishedChoiceLs, writer.WriteUInt32, 0, "FinishedChoiceLs", true, 0, nil)
	Base.WritePrimitive(writer, val.Conflict, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsRepeat, writer.WriteBoolean, false)
end

function Auto.WriteTaskGps(writer, val)
	Base.WritePrimitive(writer, val.BelongTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.EnemyId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.NpcSpoonId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt64, 0)
end

function Auto.WriteTaskSpoonViewInfo(writer, val)
	writer:WriteString(val.SpoonMd5, false, "SpoonMd5", 0)
	Base.WritePrimitive(writer, val.SpRaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.StartTaskId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EndTaskId, writer.WriteUInt32, 0)
	writer:WriteString(val.Alias, true, "Alias", 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventStartTaskId, writer.WriteUInt32, 0)
end

function Auto.WriteTaskStateData(writer, val)
	Base.WritePrimitive(writer, val.State, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Reason, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.FailTextId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CanSkip, writer.WriteBoolean, false)
end

function Auto.WriteTaskTryFashionInfo(writer, val)
	Base.WritePrimitive(writer, val.TaskEventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
end

function Auto.WriteTaskVehicleBuffInitInfo(writer, val)
	Base.WritePrimitive(writer, val.configId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.duration, writer.WriteSingle, 0)
end

function Auto.WriteTaskViewCounter(writer, val)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Value, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ConfigValue, writer.WriteInt32, 0)
	Base.WriteList(writer, val.Duty, writer.WriteUInt32, 0, "Duty", true, 0, nil)
	Base.WritePrimitive(writer, val.WaitOtherCounter, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.WaitOtherTask, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Parent, writer.WriteInt32, 0)
	Base.WriteList(writer, val.Child, Base.WriteComplexWrap(Auto.WriteTaskViewCounter, "TaskViewCounter", true), nil, "Child", true, 0, nil)
end

function Auto.WriteTaskViewData(writer, val)
	Base.WritePrimitive(writer, val.TaskId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.CounterValues, writer.WriteInt32, 0, "CounterValues", false, 0, nil)
	Base.WriteList(writer, val.Counters, Base.WriteComplexWrap(Auto.WriteTaskViewCounter, "TaskViewCounter", false), nil, "Counters", false, 0, nil)
	Base.WritePrimitive(writer, val.State, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.RecoverResource, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.SpoonViewInfo, Auto.WriteTaskSpoonViewInfo, "SpoonViewInfo", true)
end

function Auto.WriteTaskWaitLoadResource(writer, val)
	Base.WriteList(writer, val.AgentSpoonIds, writer.WriteInt32, 0, "AgentSpoonIds", false, 0, nil)
	Base.WriteList(writer, val.Gadgets, writer.WriteUInt64, 0, "Gadgets", false, 0, nil)
	Base.WriteList(writer, val.SceneItems, writer.WriteUInt64, 0, "SceneItems", false, 0, nil)
	Base.WriteList(writer, val.VehicleSpoonIds, writer.WriteInt32, 0, "VehicleSpoonIds", false, 0, nil)
	Base.WriteList(writer, val.DynamicGoIds, writer.WriteInt32, 0, "DynamicGoIds", false, 0, nil)
end

function Auto.WriteTeamSetting(writer, val)
	Base.WritePrimitive(writer, val.AllowMemberInvite, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.AutoApplyJoin, writer.WriteBoolean, false)
end

function Auto.WriteTimePanelInfo(writer, val)
	Base.WriteList(writer, val.PersonalTimeSettings, Base.WriteComplexWrap(Auto.WritePersonalTimeSetting, "PersonalTimeSetting", true), nil, "PersonalTimeSettings", true, 0, nil)
end

function Auto.WriteTokenInfo(writer, val)
	Base.WritePrimitive(writer, val.Aid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
	writer:WriteString(val.Ip, false, "Ip", 0)
	Base.WritePrimitive(writer, val.Port, writer.WriteInt32, 0)
	writer:WriteString(val.Token, false, "Token", 0)
	writer:WriteString(val.RC4Key, false, "RC4Key", 0)
	Base.WritePrimitive(writer, val.GateServerId, writer.WriteInt32, 0)
	writer:WriteString(val.AccountId, false, "AccountId", 0)
end

function Auto.WriteTraceGps(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.RaidId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.SpoonId, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.MapEntranceId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.PosId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.EnemyInstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.RefreshConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EnemyTemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TriggerEnemyState, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.IndoorId, writer.WriteUInt32, 0)
end

function Auto.WriteTrafficLightInfo(writer, val)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CrosswalkControlIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.VehicleControlIndex, writer.WriteInt32, 0)
end

function Auto.WriteTrafficLightPeriodControlInfo(writer, val)
	Base.WriteList(writer, val.TrafficLightControls, Base.WriteStructWrap(Auto.WriteMassTrafficLightControl, "TrafficLightControls"), nil, "TrafficLightControls", false, 0, nil)
	Base.WriteList(writer, val.VehicleLanesOpen, writer.WriteInt32, 0, "VehicleLanesOpen", false, 0, nil)
end

function Auto.WriteTruckJobOrderAccept(writer, val)
	Base.WritePrimitive(writer, val.AcceptedEventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AcceptTime, writer.WriteUInt32, 0)
end

function Auto.WriteTruckJobOrderInfo(writer, val)
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

function Auto.WriteTruckJobOrderResult(writer, val)
	Base.WritePrimitive(writer, val.FinishTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CargoIntegrity, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DropId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DropCoefficient, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RewardPoint, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Evaluation, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.CustomerSatisfaction, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.DropMoney, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Dropped, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsCargoNear, writer.WriteBoolean, false)
	Base.WriteList(writer, val.AddBuffList, writer.WriteUInt32, 0, "AddBuffList", false, 0, nil)
	Base.WriteList(writer, val.RemoveBuffList, writer.WriteUInt32, 0, "RemoveBuffList", false, 0, nil)
	Base.WritePrimitive(writer, val.OrderDeliverUpSetId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DeliverUpset, writer.WriteUInt32, 0)
end

function Auto.WriteTruckJobOrderWrap(writer, val)
	Base.WriteComplex(writer, val.OrderInfo, Auto.WriteTruckJobOrderInfo, "OrderInfo", false)
	Base.WritePrimitive(writer, val.UniqueId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.OrderInfoStartTime, writer.WriteUInt32, 0)
	Base.WriteComplex(writer, val.AcceptInfo, Auto.WriteTruckJobOrderAccept, "AcceptInfo", true)
	Base.WriteComplex(writer, val.ResultInfo, Auto.WriteTruckJobOrderResult, "ResultInfo", true)
	Base.WritePrimitive(writer, val.CargoPickedUp, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.CargoIntegrity, writer.WriteSingle, 0)
end

function Auto.WriteTruckNpcInfo(writer, val)
	Base.WritePrimitive(writer, val.NpcId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ConsigneeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RudeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.CharacterId, writer.WriteUInt32, 0)
end

function Auto.WriteTruckPosInfo(writer, val)
	Base.WritePrimitive(writer, val.WpId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Pos, Auto.WriteUXVector3, "Pos")
	Base.WriteStruct(writer, val.Rot, Auto.WriteUXVector3, "Rot")
	Base.WritePrimitive(writer, val.GadgetUId, writer.WriteUInt64, 0)
end

function Auto.WriteTrustNpcInfo(writer, val)
	Base.WritePrimitive(writer, val.ProfileId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TrustValue, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ActivateTime, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.GotRewardList, writer.WriteUInt32, 0, "GotRewardList", false, 0, nil)
	Base.WriteList(writer, val.FinishTargetList, writer.WriteUInt32, 0, "FinishTargetList", false, 0, nil)
	Base.WritePrimitive(writer, val.IsNew, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsMaxTrustReward, writer.WriteBoolean, false)
	Base.WriteList(writer, val.TargetStateList, Base.WriteComplexWrap(Auto.WriteTrustNpcTargetState, "TrustNpcTargetState", false), nil, "TargetStateList", false, 0, nil)
end

function Auto.WriteTrustNpcTargetState(writer, val)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsNew, writer.WriteBoolean, false)
end

function Auto.WriteTuiteInfo(writer, val)
	Base.WritePrimitive(writer, val.CfgId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TuiteState, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.PublishTime, writer.WriteUInt32, 0)
end

function Auto.WriteTurnToPositionData(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.IsImmediate, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.MaxTime, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ActionUid, writer.WriteUInt32, 0)
end

function Auto.WriteUXBoolObject(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteBoolean, false)
end

function Auto.WriteUXDoubleObject(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteDouble, 0)
end

function Auto.WriteUXIntObject(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteInt32, 0)
end

function Auto.WriteUXLongObject(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteInt64, 0)
end

function Auto.WriteUXMassHideArea(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Hide, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.HideType, writer.WriteInt32, 0)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WriteStruct(writer, val.Extends, Auto.WriteUXVector3, "Extends")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
end

function Auto.WriteUXObject(writer, val)
	return
end

function Auto.WriteUXStringObject(writer, val)
	writer:WriteString(val.Value, false, "Value", 0)
end

function Auto.WriteUXUintObject(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt32, 0)
end

function Auto.WriteUXUlongObject(writer, val)
	Base.WritePrimitive(writer, val.Value, writer.WriteUInt64, 0)
end

function Auto.WriteUintList(writer, val)
	Base.WriteList(writer, val.Value, writer.WriteUInt32, 0, "Value", false, 0, nil)
end

function Auto.WriteUnitInfoOnMoveGround(writer, val)
	Base.WritePrimitive(writer, val.MoveGroundType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.MoveGroundId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.LocalPos, Auto.WriteUXVector3, "LocalPos")
	Base.WriteStruct(writer, val.LocalRot, Auto.WriteUXVector3, "LocalRot")
end

function Auto.WriteUrbanGamePlayResult(writer, val)
	Base.WritePrimitive(writer, val.PlayType, writer.WriteByte, 0)
	Base.WriteComplex(writer, val.GymPlayResult, Auto.WriteGymPlayResult, "GymPlayResult", true)
	Base.WriteComplex(writer, val.DancePlayResult, Auto.WriteDancePlayResult, "DancePlayResult", true)
	Base.WriteComplex(writer, val.RestaurantResult, Auto.WriteRestaurantResult, "RestaurantResult", true)
end

function Auto.WriteVehicleAICommonParameters(writer, val)
	Base.WritePrimitive(writer, val.FollowPathCheckArrivePointDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TurnSlowSpeedTemplateId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TurnMinAheadSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TurnMinAheadDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TurnMaxAheadSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.TurnMaxAheadDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.AheadDistanceNormalRatio, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ArriveRoadDistance, writer.WriteSingle, 0)
end

function Auto.WriteVehicleAITaskParameters(writer, val)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteVehicleAnimationBase(writer, val)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
end

function Auto.WriteVehicleBlockMove(writer, val)
	Base.WritePrimitive(writer, val.weight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.blockSpeedMultiplier, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.blockDistance, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.blockCD, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.blockWaitTime, writer.WriteSingle, 0)
end

function Auto.WriteVehicleBrokenCollisionInfo(writer, val)
	Base.WritePrimitive(writer, val.VehicleEntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CurrentHp, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxHp, writer.WriteSingle, 0)
end

function Auto.WriteVehicleClientInfo(writer, val)
	Base.WritePrimitive(writer, val.ControllerPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.CreateSourceType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.VehicleConfigId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.Parts, Base.WriteStructWrap(Auto.WriteVehicleClientPart, "Parts"), nil, "Parts", true, 0, nil)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.Facing, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Velocity, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.IsStatic, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ColorConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DeformStatus, writer.WriteInt32, 0)
	Base.WriteList(writer, val.SeatInfos, Base.WriteComplexWrap(Auto.WriteRaidVehicleSeatInfo, "RaidVehicleSeatInfo", true), nil, "SeatInfos", true, 0, nil)
	Base.WritePrimitive(writer, val.SpoonId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.IsDynamicGo, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SummonType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.VehicleEnemyId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DisableNavigation, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Interactable, writer.WriteBoolean, false)
	Base.WriteComplex(writer, val.GpsInfo, Auto.WriteRaidVehicleGpsInfo, "GpsInfo", true)
end

function Auto.WriteVehicleClientPart(writer, val)
	Base.WritePrimitive(writer, val.Type, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteUInt32, 0)
end

function Auto.WriteVehicleComponentStateUpdateInfo(writer, val)
	Base.WritePrimitive(writer, val.UId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ComponentType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.NewStatus, writer.WriteByte, 0)
end

function Auto.WriteVehicleContactDamageData(writer, val)
	Base.WritePrimitive(writer, val.VehicleMass, writer.WriteSingle, 0)
	Base.WriteList(writer, val.VehicleVelocities, Base.WriteStructWrap(Auto.WriteUXVector3, "VehicleVelocities"), nil, "VehicleVelocities", false, 256, nil)
	Base.WriteStruct(writer, val.VehicleRelativeVelocity, Auto.WriteUXVector3, "VehicleRelativeVelocity")
	Base.WritePrimitive(writer, val.Layer, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.TouchMass, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EnemyWeight, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EnemyRank, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.DisableThreshold, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.OtherVehicleEntityId, writer.WriteUInt64, 0)
end

function Auto.WriteVehicleDangerZone(writer, val)
	Base.WritePrimitive(writer, val.Uid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.AreaInstanceId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.Center, Auto.WriteUXVector3, "Center")
	Base.WriteStruct(writer, val.Extends, Auto.WriteUXVector3, "Extends")
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WritePrimitive(writer, val.Radius, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Add, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ObstacleOnly, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.RemoveRadius, writer.WriteSingle, 0)
end

function Auto.WriteVehicleEscapeDebugData(writer, val)
	Base.WritePrimitive(writer, val.VehicleUid, writer.WriteUInt64, 0)
	writer:WriteString(val.Status, false, "Status", 0)
end

function Auto.WriteVehicleHitData(writer, val)
	Base.WritePrimitive(writer, val.VehicleId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.DriverId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TargetId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Speed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.HurtEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HurtStiffId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.VehicleSpeed, Auto.WriteUXVector3, "VehicleSpeed")
	Base.WriteStruct(writer, val.AgentSpeed, Auto.WriteUXVector3, "AgentSpeed")
end

function Auto.WriteVehicleNavResult(writer, val)
	Base.WritePrimitive(writer, val.NavReqId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.Points, Base.WriteStructWrap(Auto.WriteUXVector3, "Points"), nil, "Points", false, 0, nil)
	Base.WriteList(writer, val.CenterPoints, Base.WriteStructWrap(Auto.WriteUXVector3, "CenterPoints"), nil, "CenterPoints", false, 0, nil)
end

function Auto.WriteVehiclePartAnimation(writer, val)
	Base.WritePrimitive(writer, val.UnitId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.ConfigId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.PartIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Events, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.Priority, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
end

function Auto.WriteVehiclePoliceChaseParameters(writer, val)
	Base.WritePrimitive(writer, val.TargetType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.TargetUid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Token, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.taskAIConfigId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.defaultSpeed, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.drivingFlags, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.initSpeed, writer.WriteSingle, 0)
	Base.WriteList(writer, val.initTaskAIBuffList, Base.WriteStructWrap(Auto.WriteTaskVehicleBuffInitInfo, "initTaskAIBuffList"), nil, "initTaskAIBuffList", true, 0, nil)
	Base.WriteStruct(writer, val.commonParameters, Auto.WriteVehicleAICommonParameters, "commonParameters")
end

function Auto.WriteVehicleRamMove(writer, val)
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

function Auto.WriteVehicleSkillDamageData(writer, val)
	Base.WritePrimitive(writer, val.VehicleMass, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.VehicleVelocity, Auto.WriteUXVector3, "VehicleVelocity")
	Base.WritePrimitive(writer, val.HurtEffectId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReleaserId, writer.WriteUInt64, 0)
	Base.WriteStruct(writer, val.HitPoint, Auto.WriteUXVector3, "HitPoint")
end

function Auto.WriteVehicleSpecialPartAnimation(writer, val)
	Base.WritePrimitive(writer, val.PartType, writer.WriteByte, 0)
	Base.WritePrimitive(writer, val.EntityId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.Pid, writer.WriteUInt64, 0)
end

function Auto.WriteVisibilityReportData(writer, val)
	Base.WritePrimitive(writer, val.detectorPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.detectedPid, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.isVisible, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.isFront, writer.WriteBoolean, false)
end

function Auto.WriteWasherMissionHistoryInfo(writer, val)
	Base.WritePrimitive(writer, val.HistoryMissionCnt, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.HistoryMissionMoney, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TodayMissionMoney, writer.WriteInt32, 0)
	Base.WriteList(writer, val.HistoryMissionResults, Base.WriteComplexWrap(Auto.WriteWasherMissionResult, "WasherMissionResult", false), nil, "HistoryMissionResults", false, 0, nil)
end

function Auto.WriteWasherMissionResult(writer, val)
	Base.WritePrimitive(writer, val.MissionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Progress, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.RewardRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.ProficiencyRate, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.UsingTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.AddMoney, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.TalentPoint, writer.WriteUInt32, 0)
end

function Auto.WriteWeaponData(writer, val)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Durability, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReceivedTimeStamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.OperatorFlags, writer.WriteUInt32, 0)
	writer:WriteString(val.SpecialLabel, true, "SpecialLabel", 0)
	Base.WriteComplex(writer, val.WeaponFlags, Auto.WriteWeaponDataFlags, "WeaponFlags", false)
	Base.WritePrimitive(writer, val.SceneItemHp, writer.WriteSingle, 0)
end

function Auto.WriteWeaponDataFlags(writer, val)
	Base.WritePrimitive(writer, val.IsTaskWheelWeapon, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.ShowRedDot, writer.WriteBoolean, false)
	Base.WriteList(writer, val.AdditionalEffectIds, writer.WriteInt32, 0, "AdditionalEffectIds", true, 0, nil)
end

function Auto.WriteWeaponDetail(writer, val)
	Base.WritePrimitive(writer, val.MagazineAmmo, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SourceAgentSpoonId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.SourceAgentId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.SourceSceneItemId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Durability, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.ReceivedTimeStamp, writer.WriteDouble, 0)
	Base.WritePrimitive(writer, val.OperatorFlags, writer.WriteUInt32, 0)
	writer:WriteString(val.SpecialLabel, true, "SpecialLabel", 0)
	Base.WriteComplex(writer, val.WeaponFlags, Auto.WriteWeaponDataFlags, "WeaponFlags", false)
	Base.WritePrimitive(writer, val.SceneItemHp, writer.WriteSingle, 0)
end

function Auto.WriteWeaponWheelData(writer, val)
	Base.WritePrimitive(writer, val.WheelId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EventId, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.WeaponSlots, Base.WriteComplexWrap(Auto.WriteWeaponDetail, "WeaponDetail", false), nil, "WeaponSlots", false, 0, nil)
end

function Auto.WriteWearFashionEditInfo(writer, val)
	Base.WritePrimitive(writer, val.FashionId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Scale, writer.WriteSingle, 0)
	Base.WriteStruct(writer, val.Rotation, Auto.WriteUXVector3, "Rotation")
	Base.WriteStruct(writer, val.Offset, Auto.WriteUXVector3, "Offset")
end

function Auto.WriteWearFashionInfo(writer, val)
	Base.WritePrimitive(writer, val.FashionId, writer.WriteUInt32, 0)
end

function Auto.WriteWebviewLoginTokenInfo(writer, val)
	writer:WriteString(val.Aid, false, "Aid", 256)
	writer:WriteString(val.Username, false, "Username", 256)
	writer:WriteString(val.RoleId, false, "RoleId", 256)
	writer:WriteString(val.RoleName, false, "RoleName", 256)
	Base.WritePrimitive(writer, val.ServerId, writer.WriteInt32, 0)
	writer:WriteString(val.RoleIcon, false, "RoleIcon", 256)
	Base.WritePrimitive(writer, val.Time, writer.WriteInt32, 0)
	writer:WriteString(val.ActivityName, false, "ActivityName", 256)
	writer:WriteString(val.PayloadJson, false, "PayloadJson", 256)
end

function Auto.WriteWildEnemyClientInfo(writer, val)
	Base.WritePrimitive(writer, val.SpoonId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.InstanceId, writer.WriteUInt64, 0)
	Base.WritePrimitive(writer, val.TemplateId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.EnemyTemplateId, writer.WriteUInt32, 0)
	Base.WriteStruct(writer, val.Position, Auto.WriteUXVector3, "Position")
	Base.WritePrimitive(writer, val.RebornTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Unlocked, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.GetRewardTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Unrewarded, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.IsReward, writer.WriteBoolean, false)
end

function Auto.WriteWildEnemyGroupClientInfo(writer, val)
	Base.WritePrimitive(writer, val.SpoonId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.CampTypeId, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.RebornTime, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Unrewarded, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.Unlocked, writer.WriteBoolean, false)
	Base.WritePrimitive(writer, val.SubQuestId, writer.WriteUInt32, 0)
end

function Auto.WriteWildEnemyGroupInitSyncInfo(writer, val)
	Base.WritePrimitive(writer, val.Time, writer.WriteUInt32, 0)
	Base.WriteList(writer, val.EnemyInstanceIds, writer.WriteUInt64, 0, "EnemyInstanceIds", false, 0, nil)
end

function Auto.WriteWorkActionNodeInfo(writer, val)
	Base.WritePrimitive(writer, val.NodeId, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.WorkActionIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Value, writer.WriteInt32, 0)
end

function Auto.WriteZoneData(writer, val)
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

function Auto.WriteZoneGraphBVNode(writer, val)
	Base.WritePrimitive(writer, val.MinX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MinY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MinZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxX, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxY, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.MaxZ, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Index, writer.WriteInt32, 0)
end

function Auto.WriteZoneGraphBVTree(writer, val)
	Base.WriteStruct(writer, val.Origin, Auto.WriteFloat3, "Origin")
	Base.WriteList(writer, val.Nodes, Base.WriteStructWrap(Auto.WriteZoneGraphBVNode, "Nodes"), nil, "Nodes", false, 0, nil)
end

function Auto.WriteZoneGraphLaneLocation(writer, val)
	Base.WriteStruct(writer, val.Position, Auto.WriteFloat3, "Position")
	Base.WriteStruct(writer, val.LanePosition, Auto.WriteFloat3, "LanePosition")
	Base.WriteStruct(writer, val.Direction, Auto.WriteFloat3, "Direction")
	Base.WriteStruct(writer, val.Tangent, Auto.WriteFloat3, "Tangent")
	Base.WriteStruct(writer, val.Up, Auto.WriteFloat3, "Up")
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.LaneSegment, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.DistanceAlongLane, writer.WriteSingle, 0)
	Base.WriteList(writer, val.ZoneIndexs, writer.WriteInt32, 0, "ZoneIndexs", true, 0, nil)
	Base.WritePrimitive(writer, val.LaneZoneIndex, writer.WriteInt32, 0)
end

function Auto.WriteZoneGraphLaneSection(writer, val)
	Base.WritePrimitive(writer, val.LaneHandle, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.StartDistanceAlongLane, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.EndDistanceAlongLane, writer.WriteSingle, 0)
end

function Auto.WriteZoneGraphLinkedLane(writer, val)
	Base.WritePrimitive(writer, val.DestLane, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.Flags, writer.WriteUInt32, 0)
	Base.WritePrimitive(writer, val.Weight, writer.WriteSingle, 0)
end

function Auto.WriteZoneGraphStorage(writer, val)
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

function Auto.WriteZoneGraphTagFilter(writer, val)
	Base.WritePrimitive(writer, val.AnyTags, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.AllTags, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.NotTags, writer.WriteInt64, 0)
end

function Auto.WriteZoneLaneData(writer, val)
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

function Auto.WriteZoneLaneLinkData(writer, val)
	Base.WritePrimitive(writer, val.DestLaneIndex, writer.WriteInt32, 0)
	Base.WritePrimitive(writer, val.Type, writer.WriteInt64, 0)
	Base.WritePrimitive(writer, val.Flags, writer.WriteUInt32, 0)
end

function Auto.WriteUXVector3(writer, val)
	if val.X == nil then
		print_error("[RPC] WriteUXVector3 X = nil")

		val.X = 0
	end

	if val.Y == nil then
		print_error("[RPC] WriteUXVector3 Y = nil")

		val.Y = 0
	end

	if val.Z == nil then
		print_error("[RPC] WriteUXVector3 Z = nil")

		val.Z = 0
	end

	Base.WritePrimitive(writer, val.X, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Y, writer.WriteSingle, 0)
	Base.WritePrimitive(writer, val.Z, writer.WriteSingle, 0)
end

return Auto
