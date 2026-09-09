using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

/// <summary>
/// Teleport wire contracts for client 4229938. Field order is the wire order,
/// verified against lua/LuaGen/AutoGen/RPCSerializeAuto.lua (WriteTeleportOption,
/// WritePreTeleportOption, WriteUXVector3) and dump.cs TeleportOption (33016) /
/// PreTeleportOption (33015).
/// </summary>
[UxContract(Inline = true)]
internal struct TeleportVec3
{
    public float X;
    public float Y;
    public float Z;

    public TeleportVec3(float x, float y, float z) { X = x; Y = y; Z = z; }
}

/// <summary>Server -&gt; client SyncTeleport (64030755) / SyncPreTeleportOption (64167855) payload.</summary>
[UxContract(Inline = true)]
internal sealed class TeleportOption
{
    public ulong teleportId;
    public TeleportVec3 Position;
    public float Facing;
    public bool IsSwitchScene;
    public bool WaitTaskResource;
    public uint MapEntranceId;
}

/// <summary>Server -&gt; client SyncPreTeleportOption (64167855) payload. Same layout as the client arg.</summary>
[UxContract(Inline = true)]
internal sealed class PreTeleportOption
{
    public uint configId;
    public ulong teleportId;
    public bool ForceClear;
    public uint TimeLineDration;
    public TeleportVec3 position;
    public float facing;
    public string beforeResName = string.Empty;
    public bool customBeforeTrans;
    public TeleportVec3 beforePosition;
    public TeleportVec3 beforeRot;
    public string loadingResName = string.Empty;
    public string afterResName = string.Empty;
    public bool customAfterTrans;
    public TeleportVec3 afterPosition;
    public TeleportVec3 afterRot;
    public string extParams = string.Empty;
}

/// <summary>Client -&gt; server AskTeleport (63175104) invoke arg. Parsed with TryGetArgs (best-effort).</summary>
[UxContract(Inline = true)]
internal sealed class AskTeleportArgs
{
    public PreTeleportOption option = new();
}

/// <summary>Client -&gt; server ReportPreTeleportFinish (63032762) invoke arg.</summary>
[UxContract(Inline = true)]
internal sealed class ReportPreTeleportFinishArgs
{
    public ulong teleportId;
}

/// <summary>Client -&gt; server ReportPostTeleportFinish (63682240) notify args.</summary>
[UxContract(Inline = true)]
internal sealed class ReportPostTeleportFinishArgs
{
    public ulong teleportId;
    public uint result;
}

/// <summary>Client -&gt; server GM Teleport (62733679): UXRPCMethodArgs62733679 = (x, z) floats.</summary>
[UxContract(Inline = true)]
internal sealed class GmTeleportXZArgs
{
    public float x;
    public float z;
}
