using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

[UxContract(Inline = true)]
internal sealed class AetherFloat3
{
    public float x;
    public float y;
    public float z;

    public static AetherFloat3 Of(float x, float y, float z) => new() { x = x, y = y, z = z };
}

[UxContract(Inline = true)]
internal sealed class AetherMinMaxAabb
{
    public AetherFloat3 Min = new();
    public AetherFloat3 Max = new();
}

[UxContract(Inline = true)]
internal sealed class AetherZoneGraphBvNode
{
    public float MinX;
    public float MinY;
    public float MinZ;
    public float MaxX;
    public float MaxY;
    public float MaxZ;
    public int Index;
}

[UxContract(Inline = true)]
internal sealed class AetherZoneGraphBvTree
{
    public AetherFloat3 Origin = new();

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<AetherZoneGraphBvNode> Nodes = [];
}

[UxContract(Inline = true)]
internal sealed class AetherZoneLaneData
{
    public float Width;
    public uint Tags;
    public int PointsBegin;
    public int PointsEnd;
    public int LinksBegin;
    public int LinksEnd;
    public int ZoneIndex;
    public int StartEntryId;
    public int EndEntryId;
    public int CenterLaneId;
    public byte TurnDirection;
    public byte ConnectionType;
    public float SourceExtendDistance;
    public float DestExtendDistance;
}

[UxContract(Inline = true)]
internal sealed class AetherZoneDataV2
{
    public int BoundaryPointsBegin;
    public int BoundaryPointsEnd;
    public int LanesBegin;
    public int LanesEnd;
    public AetherMinMaxAabb Bounds = new();
    public uint Tags;

    
    
    public uint UrbanDiversity;
    public int StationId;
    public long ZoneGroupHandle;
    public int ZoneGroupInternalNumber;

    public int PointsCount;
    public float DensityFactor;
    public float RoadWidth;
}

[UxContract(Inline = true)]
internal sealed class AetherZoneGraphLinkedLane
{
    public int DestLaneIndex;
    public byte Type;
    public byte Flags;
}

[UxContract(Inline = true)]
internal sealed class AetherZoneGraphStorageV2
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<AetherZoneDataV2> Zones = [];

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<AetherZoneLaneData> Lanes = [];

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<AetherFloat3> BoundaryPoints = [];

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<AetherFloat3> LanePoints = [];

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<AetherFloat3> LaneUpVectors = [];

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<AetherFloat3> LaneTangentVectors = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<float> LanePointProgressions = [];

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<AetherZoneGraphLinkedLane> LaneLinks = [];

    public AetherMinMaxAabb Bounds = new();
    public AetherZoneGraphBvTree ZoneBvTree = new();
    public long DataHandle;
    public bool Empty;
}

[UxContract(Inline = true)]
internal sealed class AetherSpawnLaneSelector
{
    public byte SpawnLaneType;
    public int FirstArea;
    public int SecondArea;
}

[UxContract(Inline = true)]
internal sealed class AetherMassTrafficSpawnArea
{
    public AetherSpawnLaneSelector SpawnLaneSelector = new();
    public long Uid;
    public bool UseCustomizedSeed;
    public int Seed;
    public bool UseIntervalBetweenLanes;
    public float MinSpawnInterval;
    public float MaxSpawnInterval;
    public bool SpawnVehicleContinuously;
    public bool FilledWithVehicleAtStart;
    public bool RemoveVehicleWhenOutOfArea;
    public bool UseSameVelocityConfig;
    public float MinVehicleSpeed;
    public float MaxVehicleSpeed;
    public bool UseCustomizedVehicle;
}

[UxContract(Inline = true)]
internal sealed class AetherMassTrafficSpawnAreaManager
{
    public bool ClearAllNormalVehicles;

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<AetherMassTrafficSpawnArea> TrafficSpawnAreas = [];
}

[UxContract(Inline = true)]
internal sealed class ClientVehicleLaneData4229938
{
    public ulong Id;
    public int LaneHandle;
    public float DistanceAlongLane;
    public byte Status;
}

[UxContract(Inline = true)]
internal sealed class SyncAetherAIVehicleLaneData4229938
{
    public ClientVehicleLaneData4229938 data = new();
    public double timeStamp;
}

[UxContract(Inline = true)]
internal sealed class ClientVehicleLaneChangeData4229938
{
    
    public ClientVehicleLaneData4229938 VehicleLaneData = new();

    public int LaneHandleInitial;
    public int LaneHandleFinal;
    public float BeginDistanceAloneLaneInitial;
    public float BeginDistanceAloneLaneFinal;
    public float EndDistanceAlongLaneFinal;
    public float DistanceBetweenLanes;
}

[UxContract(Inline = true)]
internal sealed class SyncAetherAIVehicleLaneDatas4229938
{
    
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<ClientVehicleLaneData4229938> data = [];

    
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<ClientVehicleLaneChangeData4229938> laneChangeData = [];

    public double timestamp;
}

[UxContract(Inline = true)]
internal sealed class SyncAetherAIVehicleAddData4229938
{
    public ClientVehicleInitData data = new();
}

[UxContract(Inline = true)]
internal sealed class SyncAetherAIVehicleAddDatas4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<ClientVehicleInitData> data = [];
}
