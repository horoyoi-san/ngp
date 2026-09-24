using Ananta.SDK.Serialization;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

[UxContract]
internal sealed class PoliceVehicleSpawnClientInfo
{
    
    public ulong Id;

    
    public uint VehicleId;

    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public Auto.UXVector3 Position = new();

    public float Facing;

    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public Auto.UXVector3 EulerAngles = new();
}

[UxContract]
internal sealed class PoliceVehicleSpawnConfigInfo
{
    public float ChaseRange;
    public float ChaseDirectlyRange;
    public float ApprehendRange;
    public uint NavConfigId;
    public uint ChaseDirectlyConfigId;
    public float PatrolSpeed;
    public float ChaseSpeed;
    public float ChaseDirectlySpeed;
}

[UxContract]
internal sealed class PoliceDispatchExtraInfo
{
}

[UxContract(Inline = true)]
internal sealed class PoliceChargingSkillInfo
{
    public uint ChargingSkillId;

    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public Auto.UXVector3 Position = new();

    public float Facing;
}

[UxContract(Inline = true)]
internal sealed class PoliceRPSCardInfo
{
    public byte CardType;
    public byte StarLevel;
}

[UxContract(Inline = true)]
internal sealed class PoliceRPSCardExpInfo
{
    public byte CardType;
    public uint Exp;
}

[UxContract]
internal sealed class TruckCargoSettleInfo
{
}

[UxContract]
internal sealed class VehicleHackActionParameter
{
}

internal enum VehicleHackActionType
{
    None = 0,
    RushForward = 1,
    RushLeft = 2,
    RushRight = 3,
    RushBackward = 4,
    ChaseTarget = 5,
    Drift = 6,
    Custom = 7,
}

[UxContract(Inline = true)]
internal sealed class AskHack4229938
{
    public uint hackType;
}

[UxContract(Inline = true)]
internal sealed class AskHackVehicle4229938
{
    public ulong vehicleId;
    public int actionType;
    public VehicleHackActionParameter parameter = new();
}

[UxContract(Inline = true)]
internal sealed class AskVehicleStartHackerAutonomousDriving4229938
{
    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public Auto.UXVector3 targetPosition = new();
}

[UxContract(Inline = true)]
internal sealed class AskHackerBetray4229938
{
    public ulong targetId;
}

[UxContract(Inline = true)]
internal sealed class ReportBeHacked4229938
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> uids = new();
}

[UxContract(Inline = true)]
internal sealed class AskFinishHackerTetris4229938
{
    public uint score;
}

[UxContract(Inline = true)]
internal sealed class AskHackingNpc4229938
{
    public ulong instanceid;
    public int index;
}

[UxContract(Inline = true)]
internal sealed class AskHackingNpcPress4229938
{
    public ulong instanceid;
}

[UxContract(Inline = true)]
internal sealed class AskFinishHackingKeyFrame4229938
{
    public uint id;
}

[UxContract(Inline = true)]
internal sealed class SyncUnitHackableState4229938
{
    public ulong unitId;
    public bool isHackable;
}

[UxContract(Inline = true)]
internal sealed class SyncVehicleHackableState4229938
{
    public ulong vehicleEntityId;
    public bool isHackable;
}

[UxContract(Inline = true)]
internal sealed class AskPoliceDispatch4229938
{
    public uint dispatchId;
    public PoliceDispatchExtraInfo extraInfo = new();
}

[UxContract(Inline = true)]
internal sealed class AskPoliceVehicleHorn4229938
{
    public ulong entityId;
    public bool play;
}

[UxContract(Inline = true)]
internal sealed class AskPoliceDistanceMonitorTrigger4229938
{
    public float distance;
}

[UxContract(Inline = true)]
internal sealed class AddPoliceChargingProgress4229938
{
    public uint chargingEventId;
}

[UxContract(Inline = true)]
internal sealed class UsePoliceChargingProgress4229938
{
    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public PoliceChargingSkillInfo info = new();
}

[UxContract(Inline = true)]
internal sealed class AskPoliceTrailTeleport4229938
{
    public ulong caseId;
}

[UxContract(Inline = true)]
internal sealed class AskRPSInterrogationSelectOption4229938
{
    public ulong caseId;

    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public PoliceRPSCardInfo Card = new();
}

[UxContract(Inline = true)]
internal sealed class AskPoliceTakeCaseReward4229938
{
    public ulong caseId;
}

[UxContract(Inline = true)]
internal sealed class AskReadPoliceFakeClueAgentInfoList4229938
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<int> clueAgentInfoIndexList = new();
}

[UxContract(Inline = true)]
internal sealed class AskPoliceFakeFileAcceptTaskEvent4229938
{
    public uint fakeFileId;
}

[UxContract(Inline = true)]
internal sealed class AskPoliceFakeFileTakeReward4229938
{
    public uint fakeFileId;
}

[UxContract(Inline = true)]
internal sealed class SyncSpawnPoliceVehicles4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<PoliceVehicleSpawnClientInfo> spawnInfos = new();

    public PoliceVehicleSpawnConfigInfo configInfo = new();
}

[UxContract(Inline = true)]
internal sealed class SyncDestroyPoliceVehicles4229938
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> entityIds = new();
}

[UxContract(Inline = true)]
internal sealed class SyncPoliceDispatchVehicleChase4229938
{
    public ulong myVehicleEntityId;
    public ulong targetVehicleEntityId;
}

[UxContract(Inline = true)]
internal sealed class SyncPoliceDispatchVehicleChaseStop4229938
{
    public ulong myVehicleEntityId;
}

[UxContract(Inline = true)]
internal sealed class SyncPoliceDailyIncidentInfo4229938
{
    public uint NowEffctIncidentConfigId;
    public bool HasGetTodaysIncidentReward;
}

[UxContract(Inline = true)]
internal sealed class SyncPoliceRPSCardInfo4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<PoliceRPSCardExpInfo> cards = new();
}

[UxContract]
internal sealed class JobBoardInfo
{
    public uint JoinedJobCount;
    public uint MaxJobCount;

    [UxCollection(Count = UxCountEncoding.Int7, ValueObjectEncoding = UxObjectEncoding.Complex)]
    public Dictionary<uint, JobBoardEntryList> CountryJobEntries = new();

    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<uint, uint> HiddenCountPerCity = new();
}

[UxContract]
internal sealed class JobBoardEntryList
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<JobBoardEntry> Entries = new();
}

[UxContract]
internal sealed class JobBoardEntry
{
    public uint BoardId;
    public uint JobId;
    public uint JobClassId;
    public byte State;
    public uint UnlockProgress;
    public uint UnlockTarget;
    public bool CanResign;
}

internal static class JobBoardJobState
{
    internal const byte Locked = 0;
    internal const byte Available = 1;
    internal const byte Applying = 2;
    internal const byte Joined = 3;
    internal const byte Full = 4;
}

[UxContract(Inline = true)]
internal sealed class AskAcceptTruckJobOrder4229938
{
    public uint id;
}

[UxContract(Inline = true)]
internal sealed class AskObsoleteTruckJobOrder4229938
{
    public uint orderId;
}

[UxContract(Inline = true)]
internal sealed class AskPreSettleTruckOrder4229938
{
    public uint uniqueId;

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<TruckCargoSettleInfo> cargoSettleList = new();
}

[UxContract(Inline = true)]
internal sealed class AskSettleTruckOrder4229938
{
    public uint uniqueId;
}

[UxContract(Inline = true)]
internal sealed class AskAutoAcceptTruckJobOrder4229938
{
    public bool bAutoAccept;
}

[UxContract(Inline = true)]
internal sealed class AskSetTruckJobDefaultVehicleId4229938
{
    public uint defaultVehicleId;
}

[UxContract(Inline = true)]
internal sealed class AskResetTruckOrderGoods4229938
{
    public uint orderId;
}

[UxContract(Inline = true)]
internal sealed class AskQueryTruckPosInfo4229938
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<uint> pickupIds = new();

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<uint> deliveryIds = new();
}

[UxContract(Inline = true)]
internal sealed class AskAddTruckOrderSpecialPointReward4229938
{
    public uint orderId;
    public int pointId;
}

[UxContract(Inline = true)]
internal sealed class AskAddTruckOrderSpecialPointRewards4229938
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<uint> orderIds = new();

    public int pointId;
}

[UxContract(Inline = true)]
internal sealed class AskDoTruckNpcAction4229938
{
    public ulong instanceId;
    public uint eventId;
}

[UxContract]
internal sealed class ClientTruckOrderView
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<TruckJobOrderWrap> Orders = new();

    public int RewardPointSum;
    public float CustomerSatisfactionAverage;
    public uint CurrentOrderId;
    public bool TruckGuideClicked;

    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<uint, ulong> EventIdToAgent = new();

    public bool AutoAccept;
    public uint DefaultVehicleId;
    public int TotalIncome;
}

[UxContract]
internal sealed class TruckJobOrderWrap
{
}

[UxContract]
internal sealed class TruckPosInfo
{
}

[UxContract(Inline = true)]
internal sealed class AskQueryTruckPosInfoResult
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<TruckPosInfo> pickup = new();

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<TruckPosInfo> delivery = new();
}

[UxContract]
internal sealed class ClientFinishedTruckOrderView
{
    public int TotalIncome;
    public int FinishedOrderCount;
    public int TotalRewardPoint;

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<int> FinishedOrders = new();
}

[UxContract(Inline = true)]
internal sealed class CreationInfo4229938
{
    public ulong Id;
    public ulong ParentId;
    public ulong TargetId;
    public ulong DestructibleId;

    
    public uint CreationId;

    
    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public Auto.UXVector3 ParentPosition = new();

    
    public float Rotate;

    public bool ClientEnterOrLeave;
    public uint SourceSkillId;
    public ulong SourceDestructibleId;
    public ulong GadgetId;
    public int GadgetTransformId;
}

internal static class SyncActiveSpiritJobTalentLayer4229938Notes
{
    
}

