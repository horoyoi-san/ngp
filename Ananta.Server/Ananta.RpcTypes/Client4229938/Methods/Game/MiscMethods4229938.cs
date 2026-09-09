using Ananta.SDK.Serialization;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

/// <summary>Destructible / discard / hangup wire contracts (fresh unhandled-log batch).</summary>
[UxContract]
internal sealed class DestructibleHitTypeList4229938
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<byte> HitTypes = [];
}

/// <summary>Client invoke: AskNotifyDestructibleHits (67043150).</summary>
[UxContract(Inline = true)]
internal sealed class AskNotifyDestructibleHitsArgs4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ValueObjectEncoding = UxObjectEncoding.Complex)]
    public Dictionary<ulong, DestructibleHitTypeList4229938> hits = [];
}

/// <summary>Client invoke: AskOperateDestructibleObject (67351604).</summary>
[UxContract(Inline = true)]
internal sealed class AskOperateDestructibleObjectArgs4229938
{
    public ulong id;
    public byte operation;
}

/// <summary>Client notify: AskMoveDestructibleObjects (67341910).</summary>
[UxContract(Inline = true)]
internal sealed class AskMoveDestructibleObjectsArgs4229938
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> ids = [];
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<SceneMethods.UxVector3> positions = [];
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<SceneMethods.UxVector3> facings = [];
}

/// <summary>WriteDestructibleBrokenInfo order.</summary>
[UxContract]
internal sealed class DestructibleBrokenInfo4229938
{
    public ulong InstanceId;
    public uint Stage;
    public byte BrokenType;
    public SceneMethods.UxVector3 Position;
    public SceneMethods.UxVector3 Facing;
}

/// <summary>Client notify: AskBreakDestructibleObjects (67891964).</summary>
[UxContract(Inline = true)]
internal sealed class AskBreakDestructibleObjectsArgs4229938
{
    public ulong breaker;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<DestructibleBrokenInfo4229938> brokenInfos = [];
}

/// <summary>Client notify: AskReadWeaponRedDots (67449888).</summary>
[UxContract(Inline = true)]
internal sealed class AskReadWeaponRedDotsArgs4229938
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> weaponInstanceIds = [];
}

/// <summary>Client invoke: AskDiscardWeaponByInstanceId (67892019).</summary>
[UxContract(Inline = true)]
internal sealed class AskDiscardWeaponByInstanceIdArgs4229938
{
    public ulong weaponInstanceId;
    public uint spiritId;
    public bool isDropOut;
}

/// <summary>Client notify: AskDiscardWeapon (67155190).</summary>
[UxContract(Inline = true)]
internal sealed class AskDiscardWeaponArgs4229938
{
    public int index;
}

/// <summary>Client notify: AskBreakSkillTimeCurve (67425306).</summary>
[UxContract(Inline = true)]
internal sealed class AskBreakSkillTimeCurveArgs4229938
{
    public ulong releaser;
    public int id;
    public int index;
}
