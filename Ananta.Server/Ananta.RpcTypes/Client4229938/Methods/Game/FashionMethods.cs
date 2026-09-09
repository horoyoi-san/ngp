using Ananta.SDK.Serialization;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

[UxContract(Inline = true)]
internal sealed class AskSetSpiritFashionsWithSource
{
    public uint spiritOrInstanceId;
    public short source;
    public SpiritWearFashionsInfo spiritWearFashionsInfo = new();
}

[UxContract(Inline = true)]
internal sealed class SyncSetSpiritFashions
{
    public uint spiritId;
    public short source;
    public SpiritWearFashionsInfo spiritWearFashionsInfo = new();
}

[UxContract]
internal sealed class SpiritWearFashionsInfo
{
    public uint FunctionSuitId;
    public WearSourceInfo WearSourceInfo;
    public bool IsTryWear;

    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<WearFashionInfo> WearFashionInfoList = [];

    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<WearFashionEditInfo>? WearFashionEditInfoList = [];

    public byte HiddenParts;
    public byte EditedHiddenParts;
}

[UxContract(Inline = true)]
internal struct WearSourceInfo
{
    public short Source;
    public uint SourceId;
}

[UxContract]
internal sealed class WearFashionInfo
{
    public uint FashionId;
}

[UxContract]
internal sealed class WearFashionEditInfo
{
    public uint FashionId;
    public float Scale;
    public SceneMethods.UxVector3 Rotation;
    public SceneMethods.UxVector3 Offset;
}

/// <summary>Server -> client SyncPlayerAllSpirits: top-level List7Bit&lt;SpiritInfo&gt;.</summary>
[UxContract(Inline = true)]
internal sealed class SyncPlayerAllSpirits
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<Auto.SpiritInfo> spirits = [];
}

[UxContract]
internal sealed class SpiritViewData
{
    public Auto.SpiritInfo SpiritInfo = new();
}

/// <summary>
/// Incremental roster hydration. The build's handler ignores reason and adds/replaces one view entry,
/// avoiding a single oversized SyncPlayerAllSpirits payload with every character loadout embedded.
/// </summary>
[UxContract(Inline = true)]
internal sealed class SyncPlayerAddNewSpirit
{
    public SpiritViewData spirit = new();
    public int reason;
}

/// <summary>Return body of AskAllSpiritPanelData: top-level List7Bit&lt;SpiritPanelData&gt;.</summary>
[UxContract(Inline = true)]
internal sealed class AskAllSpiritPanelDataResult
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<Auto.SpiritPanelData> spirits = [];
}
