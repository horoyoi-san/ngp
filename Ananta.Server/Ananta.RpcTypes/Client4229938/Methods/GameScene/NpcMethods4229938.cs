using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

[UxContract(Inline = true)]
internal sealed class SyncActiveWildEnemyGroup4229938
{
    public int groupId;
    public uint campId;
    public bool first;

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> enemyInstanceIds = [];
}

[UxContract(Inline = true)]
internal sealed class SyncDoAetherAgentBehaviorTaskDefine4229938
{
    public ulong agentEntityId;
    public ulong taskId;
    public uint behaviorTaskId;
}

[UxContract(Inline = true)]
internal sealed class ClientNpcPlayAnimationData4229938
{
    public ulong Id;
    public uint PoiActionId;
    public double StartTime;
}

[UxContract(Inline = true)]
internal sealed class SyncAetherAINpcPlayAnimation4229938
{
    public ClientNpcPlayAnimationData4229938 data = new();
}

[UxContract(Inline = true)]
internal sealed class MoveWanderingData4229938
{
    public uint pathTags;
    public bool CloseObstacleAvoidance;
    public float MinDis;
    public float MaxDis;
    public float InRangeAngle;
    public float OutRangeAngle;
    public float MaxTime;
    public float MaxOnceWanderTime;

    
    public ulong UnitId;
    public long MoveType;          
    public byte MoveId;
    public bool CloseIK;
    public byte InstanceId;
    public bool BlockCloseCapsuleCollision;
}

[UxContract(Inline = true)]
internal sealed class SyncMoveWandering4229938
{
    public MoveWanderingData4229938 data = new();
}

[UxContract(Inline = true)]
internal sealed class SyncChangeNpcMoveDesiredSpeed4229938
{
    public ulong entityId;
    public float desiredSpeed;
}
