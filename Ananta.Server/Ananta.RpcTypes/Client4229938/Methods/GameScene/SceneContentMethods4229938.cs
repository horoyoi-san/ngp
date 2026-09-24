using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

[UxContract(Inline = true)]
internal sealed class GridIndex4229938
{
    public int X;
    public int Z;
}

internal enum AoiAddAndRemoveReason4229938 : byte
{
    Init = 0,
    Loaded = 1,
    AOIMove = 2,
    SpecialCondition = 3,
    TargetCondition = 4,
    SectorChange = 5,
    BuildingChange = 6,
    Quality = 7,
}

[UxContract(Inline = true)]
internal sealed class GridAOIDecrease4229938
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<int> SectorIdList = [];

    
    
    
    
    public int BuildingId;

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<GridIndex4229938> StandardIndexList = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> ExceptIds = [];
}

[UxContract(Inline = true)]
internal sealed class GadgetExtraSyncInfo4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<GadgetClientDropLimitInfo4229938> DropLimit = [];
}

[UxContract]
internal sealed class GadgetClientDropLimitInfo4229938
{
    public ulong GadgetUid;

    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<uint, uint> DropLimitId2FinishTime = [];
}

[UxContract(Inline = true)]
internal sealed class GadgetGridAOIIncrease4229938
{
    public GridIndex4229938 PlayerStandardIndex = new();

    
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<GadgetEntityInfoStub4229938> AddInfos = [];

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<GridIndex4229938> IndexList = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> AddUniqueIds = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> RemoveIds = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> ActiveIds = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> InactiveIds = [];

    public AoiAddAndRemoveReason4229938 Reason;
}

[UxContract(Inline = true)]
internal sealed class DestructibleGridAOIIncrease4229938
{
    public GridIndex4229938 PlayerStandardIndex = new();

    
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<DestructibleInfoStub4229938> AddInfos = [];

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<GridIndex4229938> IndexList = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> AddUniqueIds = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> RemoveIds = [];

    public AoiAddAndRemoveReason4229938 Reason;
}

[UxContract]
internal sealed class GadgetEntityInfoStub4229938
{
    public ulong InstanceId;
}

[UxContract]
internal sealed class DestructibleInfoStub4229938
{
    public ulong InstanceId;
}

[UxContract(Inline = true)]
internal sealed class SyncDestructibleSceneAOIActive4229938
{
    public bool active;
}

[UxContract(Inline = true)]
internal sealed class SyncDestructibleGridAOIIncrease4229938
{
    public DestructibleGridAOIIncrease4229938 aoiInfo = new();
}

[UxContract(Inline = true)]
internal sealed class SyncDestructibleGridAOIDecrease4229938
{
    public DestructibleGridAOIIncrease4229938 aoiInfo = new();

    
    public GridAOIDecrease4229938 addGridInfo = new();

    
    public GridAOIDecrease4229938 removeGridInfo = new();
}

[UxContract(Inline = true)]
internal sealed class SyncGadgetGridAOIDecrease4229938
{
    public GadgetGridAOIIncrease4229938 aoiInfo = new();
    public GridAOIDecrease4229938 addGridInfo = new();
    public GridAOIDecrease4229938 removeGridInfo = new();
    public GadgetExtraSyncInfo4229938 extraInfo = new();
}
