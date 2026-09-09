using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// Teleport: inbound client/GM requests plus server-push primitives used by the admin panel.
/// Lua (RPCSerializeAuto WriteTeleportOption/WritePreTeleportOption) is the wire truth;
/// dump.cs TeleportOption/PreTeleportOption field order is mirrored 1:1 in TeleportMethods.
/// </summary>
internal sealed partial class GameRouter
{
    internal static WorldEntryState? GetStateIfExists(TcpSession session)
        => session.Items.TryGetValue(WorldStateKey, out var raw) && raw is WorldEntryState existing
            ? existing
            : null;

    // Client -> server: native loading-flow request. Accept it, remember the correlation
    // ids, and let the client drive its own flow; admin pushes use the outbound path below.
    [Handler(MethodId.AskTeleport)]
    private async Task AskTeleport(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.AskTeleportArgs>(out var args) && args?.option is not null)
        {
            var state = GetWorldState(msg.Context);
            lock (state.SyncRoot)
            {
                state.PendingTeleportId = args.option.teleportId;
                state.PendingTeleportPreFinished = false;
                state.PendingTeleportSyncSent = false;
            }
            conn.Log.Info($"[TELEPORT] AskTeleport config={args.option.configId} teleportId={args.option.teleportId} pos=({args.option.position.X:F1},{args.option.position.Y:F1},{args.option.position.Z:F1}) facing={args.option.facing:F2}");
        }
        else
        {
            conn.Log.Warn($"[TELEPORT] AskTeleport undecodable bytes={msg.Body.Length} hex={Convert.ToHexString(msg.Body, 0, Math.Min(msg.Body.Length, 64))}");
        }
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.ReportPreTeleportFinish)]
    private async Task ReportPreTeleportFinish(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.ReportPreTeleportFinishArgs>(out var args) && args is not null)
        {
            var state = GetWorldState(msg.Context);
            lock (state.SyncRoot)
            {
                if (args.teleportId == state.PendingTeleportId)
                    state.PendingTeleportPreFinished = true;
            }
            conn.Log.Info($"[TELEPORT] ReportPreTeleportFinish teleportId={args.teleportId} pending={state.PendingTeleportId}");
        }
        else
        {
            conn.Log.Warn($"[TELEPORT] ReportPreTeleportFinish undecodable bytes={msg.Body.Length}");
        }
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.ReportPostTeleportFinish, HandlerPacketKind.Notify)]
    private Task ReportPostTeleportFinish(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.ReportPostTeleportFinishArgs>(out var args) && args is not null)
            conn.Log.Info($"[TELEPORT] ReportPostTeleportFinish teleportId={args.teleportId} result={args.result}");
        else
            conn.Log.Warn($"[TELEPORT] ReportPostTeleportFinish undecodable bytes={msg.Body.Length}");
        return Task.CompletedTask;
    }

    // GM service Teleport(x, z): UXRPCMethodArgs62733679. Log it and treat it as a
    // same-map XZ jump hint (Y stays at the last reported height).
    [Handler(MethodId.Teleport)]
    private async Task GmTeleportXZ(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.GmTeleportXZArgs>(out var args) && args is not null)
        {
            conn.Log.Info($"[TELEPORT] GM Teleport x={args.x:F1} z={args.z:F1}");
            var state = GetWorldState(msg.Context);
            float y;
            lock (state.SyncRoot)
                y = state.HasLastReportedPlayerTransform ? state.LastReportedPlayerPosition.Y : 0f;
            await TeleportPlayerInstantAsync(msg.Context, args.x, y, args.z, null, "gm-Teleport-xz");
        }
        else
        {
            conn.Log.Warn($"[TELEPORT] GM Teleport undecodable bytes={msg.Body.Length}");
        }
        await conn.ReturnEmptyOkAsync(msg);
    }

    /// <summary>
    /// Instant move without a loading screen: SyncUnitPosition_P (68233969) with
    /// SetPositionTypeForClient.Teleport (6). Updates the tracked transform optimistically.
    /// </summary>
    internal static async Task TeleportPlayerInstantAsync(
        RpcContext ctx, float x, float y, float z, float? facing, string reason)
    {
        var state = GetWorldStateStatic(ctx);
        ulong unitId;
        float face;
        lock (state.SyncRoot)
        {
            unitId = state.ActiveSpiritUnitId != 0 ? state.ActiveSpiritUnitId : Profile.InitialUnitId;
            face = facing ?? (state.HasLastReportedPlayerTransform ? state.LastReportedPlayerRotation.Y : Profile.WorldFacing);
            state.LastReportedPlayerPosition = new Vec3(x, y, z);
            state.LastReportedPlayerRotation = new Vec3(0f, face, 0f);
            state.HasLastReportedPlayerTransform = true;
        }
        await ctx.NotifyAsync(MethodId.SyncUnitPosition_P, WorldCodec.PositionP(unitId, new Vec3(x, y, z), face, setPositionType: 6));
        ctx.Session.Log.Info($"[TELEPORT] instant reason={reason} unit={unitId} pos=({x:F2},{y:F2},{z:F2}) facing={face:F2}");
    }

    /// <summary>
    /// Loading-flow move: SyncPreTeleportOption (64167855) + SyncTeleport (64030755)
    /// with a fresh teleport id. The client is expected to answer with
    /// ReportPreTeleportFinish / ReportPostTeleportFinish (logged by handlers above).
    /// </summary>
    internal static async Task<ulong> TeleportPlayerWithLoadingAsync(
        RpcContext ctx, float x, float y, float z, float facing, string reason)
    {
        var state = GetWorldStateStatic(ctx);
        ulong unitId;
        ulong teleportId;
        lock (state.SyncRoot)
        {
            unitId = state.ActiveSpiritUnitId != 0 ? state.ActiveSpiritUnitId : Profile.InitialUnitId;
            teleportId = (ulong)Interlocked.Increment(ref s_teleportIdCounter);
            state.PendingTeleportId = teleportId;
            state.PendingTeleportPreFinished = false;
            state.PendingTeleportSyncSent = true;
            state.LastReportedPlayerPosition = new Vec3(x, y, z);
            state.LastReportedPlayerRotation = new Vec3(0f, facing, 0f);
            state.HasLastReportedPlayerTransform = true;
        }

        var pre = new GameMethods.PreTeleportOption
        {
            configId = 0,
            teleportId = teleportId,
            ForceClear = false,
            TimeLineDration = 0,
            position = new GameMethods.TeleportVec3(x, y, z),
            facing = facing,
            beforeResName = string.Empty,
            customBeforeTrans = false,
            beforePosition = new GameMethods.TeleportVec3(x, y, z),
            beforeRot = new GameMethods.TeleportVec3(0f, facing, 0f),
            loadingResName = string.Empty,
            afterResName = string.Empty,
            customAfterTrans = false,
            afterPosition = new GameMethods.TeleportVec3(x, y, z),
            afterRot = new GameMethods.TeleportVec3(0f, facing, 0f),
            extParams = string.Empty,
        };
        await ctx.NotifyAsync(MethodId.SyncPreTeleportOption, pre);
        await ctx.NotifyAsync(MethodId.SyncTeleport, new GameMethods.TeleportOption
        {
            teleportId = teleportId,
            Position = new GameMethods.TeleportVec3(x, y, z),
            Facing = facing,
            IsSwitchScene = false,
            WaitTaskResource = false,
            MapEntranceId = 0,
        });
        ctx.Session.Log.Info($"[TELEPORT] loading-flow reason={reason} unit={unitId} teleportId={teleportId} pos=({x:F2},{y:F2},{z:F2}) facing={facing:F2}");
        return teleportId;
    }

    private static long s_teleportIdCounter = 900_000;

    private static WorldEntryState GetWorldStateStatic(RpcContext ctx)
    {
        if (ctx.Session.Items.TryGetValue(WorldStateKey, out var raw) && raw is WorldEntryState existing)
            return existing;
        var created = new WorldEntryState();
        ctx.Session.Items[WorldStateKey] = created;
        return created;
    }
}
