using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

[UxContract(Inline = true)]
internal sealed class SyncAssignVehicleAITask4229938
{
    
    public ulong vehicleUId;

    public CruiseAITaskParameters4229938 parameters = new();
}

[UxContract(Inline = true)]
internal sealed class SyncAetherAIIntersectionUpdateData4229938
{
    public ClientTrafficIntersectionPeriodUpdateInfo4229938 data = new();
}

[UxContract]
internal sealed class ClientTrafficIntersectionPeriodUpdateInfo4229938
{
    
    public ulong IntersectionIndex;

    
    public byte CurrentState;

    
    public byte CurrentPeriodIndex;
    public byte NextPeriodIndex;
    public byte RailPeriodIndex;
}

internal enum MassTrafficIntersectionState4229938 : byte
{
    Start = 0,
    Transition = 1,
    Finishing = 2,
}

[UxContract(Inline = true)]
internal sealed class SyncChangeVehicleAITaskState4229938
{
    public ulong vehicleUID;
    public ulong taskToken;

    
    public byte status;
}

internal enum VehicleAIStatus4229938 : byte
{
    Pending = 0,
    Running = 1,
    Success = 2,
    Pause = 3,
    Abort = 4,
    Override = 5,
}

internal enum E_TaskVehicleCruiseType4229938
{
    GoToOneTarget = 0,
    GoToTargetInOrderOnce = 1,
    GoToTargetInOrderLoop = 2,
    GoToTargetInOrderLoopInCount = 3,
    GoToTargetInRandomOnce = 4,
    GoToTargetInRandomOneByOne = 5,
    GoToTargetInRandomOneByOneInCount = 6,
    GoToTargetInRandomAlways = 7,
}

[Flags]
internal enum TaskVehicleCruiseConfigFlags4229938
{
    None = 0,
    BreakByPlayerWhenAtFront = 1,
    PauseByPlayerWhenAtFront = 2,
    SlowDownWhenArriveTarget = 4,
    DynamicSpeed = 8,
}

[Flags]
internal enum TaskVehiclePathFindFlags4229938
{
    None = 0,
    IgnoreAlley = 1,
    IgnoreDirection = 2,
}

internal enum E_AITargetType4229938
{
    None = 0,
    Vehicle = 1,
    Unit = 2,
}

[Flags]
internal enum VehicleTaskDrivingFlags4229938
{
    None = 0,
    DFStopForCars = 1,
    DFStopForPeds = 2,
    DFSwerveAroundAllCars = 4,
    DFSteerAroundStationaryCars = 8,
    DFSteerAroundPeds = 16,
    DFSteerAroundObjects = 32,
    DFStopAtLights = 128,
    DFGoOffRoadWhenAvoiding = 256,
}

[Flags]
internal enum VehicleStuckLevel4229938
{
    None = 0,
    Relaxed = 1,
    Moderate = 2,
    Strict = 4,
}

internal enum VirtualGroundMoveType4229938
{
    None = 0,
    ColliderNotLoaded = 1,
    Always = 2,
    ForceDummy = 3,
    ForcePhysics = 4,
}

[UxContract]
internal sealed class VehicleStuckCheckConfig4229938
{
    public byte StuckLevel = (byte)VehicleStuckLevel4229938.None;
    public float RelaxedStuckCheckTime = 2f;
    public int RelaxedStuckCheckCount = 2;
    public int ModerateStuckCheckCount = 2;
    public float StrictStuckCheckDistance = 6f;
    public float CheckGoToNextPointStuckTime;
    public bool ResetWhenStuck;
}

[UxContract(Inline = true)]
internal struct TaskVehicleBuffInitInfo4229938
{
    public uint configId;
    public float duration;
}

[UxContract(Inline = true)]
internal struct VehicleAICommonParameters4229938
{
    public float FollowPathCheckArrivePointDistance;
    public int TurnSlowSpeedTemplateId;
    public float TurnMinAheadSpeed;
    public float TurnMinAheadDistance;
    public float TurnMaxAheadSpeed;
    public float TurnMaxAheadDistance;
    public float AheadDistanceNormalRatio;
    public float DummySpeedRatio;
    public VehicleStuckCheckConfig4229938? StuckCheckConfig;
    public byte VirtualGroundMoveType;
}

[UxContract(TypeMark = 6)]
internal sealed class CruiseAITaskParameters4229938
{
    

    
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<Auto.UXVector3> TargetPointList = [];

    
    public byte CruiseType = (byte)E_TaskVehicleCruiseType4229938.GoToTargetInOrderLoop;

    public int Count;

    public byte configFlags = (byte)TaskVehicleCruiseConfigFlags4229938.SlowDownWhenArriveTarget;

    public byte pathFindFlags = (byte)TaskVehiclePathFindFlags4229938.None;

    public byte TargetType = (byte)E_AITargetType4229938.None;

    public ulong TargetUid;

    public bool checkClose;
    public bool checkFar;

    public float closeRange;
    public float farawayRange;
    public float accelerateScale = 1f;
    public float decelerateScale = 1f;
    public float minSpeed;
    public float maxSpeed;
    public float ArrivalDistance = 4f;
    public bool AdaptSpeedToTargetDistance = true;

    

    
    public ulong Token;

    
    public uint taskAIConfigId;

    public float defaultSpeed;
    public int drivingFlags = (int)(VehicleTaskDrivingFlags4229938.DFStopForCars
                                    | VehicleTaskDrivingFlags4229938.DFStopForPeds
                                    | VehicleTaskDrivingFlags4229938.DFStopAtLights);

    public float initSpeed;

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<TaskVehicleBuffInitInfo4229938> initTaskAIBuffList = [];

    public VehicleAICommonParameters4229938 commonParameters;
}
