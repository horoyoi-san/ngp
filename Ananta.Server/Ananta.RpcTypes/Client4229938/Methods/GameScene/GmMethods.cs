using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

[UxContract(Inline = true)]
internal sealed class GmSpawnVehicle
{
    public uint TemplateId;
    public UxVector3 Position;
    public float Facing;
    public uint SuitId;
    public bool LoadOwnVehicle;
    public string SpoonName = string.Empty;
}

[UxContract(Inline = true)]
internal sealed class GmAddEnemyWithPosition
{
    public uint EnemyId;
    public byte Camp;
    public UxVector3 Position;
    public uint NavTagType;
    public bool OutsideAoiMove;
}

[UxContract(Inline = true)]
internal sealed class GmAddEnemy
{
    public uint EnemyId;
    public byte Camp;
    public string TreeName = string.Empty;
    public uint NavTagType;
    public bool OutsideAoiMove;
}

[UxContract(Inline = true)]
internal sealed class GmAddEnemyByPlayer
{
    public uint EnemyId;
    public byte Camp;
}

[UxContract(Inline = true)]
internal sealed class GmTeleportXYZ
{
    public float X;
    public float Y;
    public float Z;
    public float Facing;
}
