using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

[UxContract(Inline = true)]
internal sealed class AskVehicleNavigationPathPoints4229938
{
    public uint NavReqId;
    public UxVector3 TargetPosition;
    public bool IgnoreDirection;
    public bool IgnoreAlley;
    public bool NeedCenterPoints;
    public bool UseNavMeshConnect;

    
    public byte NavigationProfile;
}

[UxContract(Inline = true)]
internal sealed class AskVehicleNavigationPathPointsFromPos4229938
{
    public uint NavReqId;
    public UxVector3 StartPosition;
    public UxVector3 TargetPosition;
    public bool IgnoreDirection;
    public bool IgnoreAlley;
    public bool NeedCenterPoints;
    public bool UseNavMeshConnect;
    public byte NavigationProfile;
    public float EulerY;
}

[UxContract]
internal sealed class VehicleNavResult4229938
{
    public uint NavReqId;

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<UxVector3> Points = [];

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<UxVector3> CenterPoints = [];
}

[UxContract(Inline = true)]
internal sealed class AskVehicleNavigationPathLength4229938
{
    public UxVector3 TargetPosition;
    public bool IgnoreDirection;
    public bool IgnoreAlley;
    public bool UseNavMeshConnect;
    public byte NavigationProfile;
}

[UxContract(Inline = true)]
internal sealed class AskVehicleNavigationPathLengthList4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<UxVector3> TargetPositionList = [];

    public bool IgnoreDirection;
    public bool IgnoreAlley;
    public bool UseNavMeshConnect;
    public byte NavigationProfile;
}

[UxContract(Inline = true)]
internal sealed class AskVehicleStartAutonomousDriving4229938
{
    public bool HasValidTargetPosition;
    public UxVector3 TargetPosition;
}

[UxContract(Inline = true)]
internal sealed class AskVehicleChangeAutonomousDrivingTarget4229938
{
    public UxVector3 TargetPosition;
}

[UxContract(Inline = true)]
internal sealed class SyncVehicleAutonomousDrivingState4229938
{
    public ulong VehicleEntityId;
    public bool IsStart;
}

[UxContract(Inline = true)]
internal sealed class SyncPlayerAutonomousDrivingState4229938
{
    public bool IsInOverrideMode;
    public bool IsAutoDrivingBlocked;
    public bool IsImmersiveModeBlocked;
}
