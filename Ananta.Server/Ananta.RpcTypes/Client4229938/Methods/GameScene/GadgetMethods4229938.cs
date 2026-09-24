using Ananta.SDK.Serialization;
using Ananta.Server.RpcTypes.Client4229938.Auto;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

[UxContract]
internal sealed class PackedGadgetSpecialParam4229938
{
    public int markId;
    public string? value;
}

[UxContract]
internal sealed class PackedGadgetInfo4229938
{
    public float posX;
    public float posY;
    public float posZ;
    public float eulerX;
    public float eulerY;
    public float eulerZ;
    public int iScale;
    public ulong uniqueId;
    public int pathId;

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<PackedGadgetSpecialParam4229938> spoonSpecialList = [];

    public bool delayDestroy;
    public uint startTaskId;
    public uint endTaskId;
    public uint extractionItemContainerId;
    public bool isStatic;
}

[UxContract]
internal sealed class ReplaceGadgetInfo4229938 { }

[UxContract]
internal sealed class SceneDevicePersonalValueInfo4229938 { }

[UxContract]
internal sealed class SceneDeviceOccupantInfo4229938 { }

[UxContract]
internal sealed class MobilePlatformSyncInfo4229938 { }

[UxContract]
internal sealed class AdhereMovingPlatformInfo4229938 { }

[UxContract]
internal sealed class DoorModuleSyncInfo4229938 { }

[UxContract]
internal sealed class DrillShelfSyncInfo4229938 { }

[UxContract]
internal sealed class SceneDeviceHangingInfo4229938 { }

[UxContract]
internal sealed class GadgetEntityInfo4229938
{
    public ulong InstanceId;

    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public UXVector3 Position = new();

    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public UXVector3 Facing = new();

    public int NavId;

    [UxCollection(Count = UxCountEncoding.Int7)]
    public int[] ChildNavIds = [];

    public bool ForceLod0;
    public bool IsTask;

    
    public PackedGadgetInfo4229938? Pack;

    public ReplaceGadgetInfo4229938? ReplaceInfo;

    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<int, int> CommonStateInfoDic = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<int, string> CommonValueInfoDic = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<ulong, SceneDevicePersonalValueInfo4229938> PersonalValueInfoDic = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<int, int> StateCheckIndexDic = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<int, int> ValueCheckIndexDic = [];

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<SceneDeviceOccupantInfo4229938> OccupantInfos = [];

    public uint LinkOccupiedId;

    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<ulong, ulong> SymbiosisGadgets = [];

    public MobilePlatformSyncInfo4229938? MobilePlatformInfo;
    public AdhereMovingPlatformInfo4229938? AdherePlatformInfo;
    public DoorModuleSyncInfo4229938? DoorModuleInfo;
    public DrillShelfSyncInfo4229938? DrillShelfInfo;
    public SceneDeviceHangingInfo4229938? HangingInfo;
}

[UxContract]
internal sealed class GadgetPackSyncInfo4229938
{
    public ulong InstanceId;
    public PackedGadgetInfo4229938? PackedInfo;
}

[UxContract(Inline = true)]
internal sealed class SyncGadgetAOIAddAndRemove4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<GadgetEntityInfo4229938> addInfos = [];

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<GadgetPackSyncInfo4229938> addPackSyncInfos = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> removeIds = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> activeIds = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> inactiveIds = [];

    public SceneMethods.AoiAddAndRemoveReason4229938 reason;
}
