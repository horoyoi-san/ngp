using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// Private-server vehicle surface (build 4229938): summon + owned fleet + drive-loop accepts.
/// Spawn uses the proven 3-notify sequence (SyncLogicVehicleEnter + SyncSpawnVehicle +
/// SyncChangeVehicleInteractable) with 5.5m-right/+0.15m offsets; driving itself is
/// simulated client-side.
/// </summary>
internal sealed partial class GameRouter
{
    private static long _vehicleEntitySeq = 300000000000L;
    private static long _vehicleTaskSeq;
    private static readonly Dictionary<ulong, SummonedVehicle> SummonedVehicles = new();
    private static readonly object SummonedVehiclesSync = new();

    internal sealed class SummonedVehicle
    {
        internal uint ConfigId;
        internal float X;
        internal float Y;
        internal float Z;
        internal float Yaw;
        internal bool HasFix;
        // Boarding state (S011 story flow): seat layout + occupancy.
        internal int SeatCount = 2;
        internal bool Interactable = true;
        internal ulong ControllerPid;
        internal readonly Dictionary<byte, ulong> SeatReservations = new();
        internal readonly Dictionary<byte, ulong> SeatOccupants = new();
    }

    private static ulong _lastSummonedEntity;

    internal static ulong LastSummonedEntity()
    {
        lock (SummonedVehiclesSync)
            return _lastSummonedEntity;
    }

    internal static bool TryGetSummoned(ulong entityId, out SummonedVehicle? vehicle)
    {
        lock (SummonedVehiclesSync)
            return SummonedVehicles.TryGetValue(entityId, out vehicle);
    }

    internal static List<(ulong EntityId, uint ConfigId, float X, float Y, float Z, float Yaw, bool HasFix)> SummonedSnapshot()
    {
        lock (SummonedVehiclesSync)
            return SummonedVehicles
                .Select(kv => (kv.Key, kv.Value.ConfigId, kv.Value.X, kv.Value.Y, kv.Value.Z, kv.Value.Yaw, kv.Value.HasFix))
                .ToList();
    }

    internal static void RegisterSummoned(ulong entityId, uint configId)
    {
        lock (SummonedVehiclesSync)
        {
            if (!SummonedVehicles.TryGetValue(entityId, out var existing))
                SummonedVehicles[entityId] = existing = new SummonedVehicle { ConfigId = configId };
            else
                existing.ConfigId = configId;
            existing.SeatCount = LookupSeatCount(configId);
            existing.Interactable = true;
            _lastSummonedEntity = entityId;
        }
    }

    internal static void RegisterSummoned(ulong entityId, uint configId, float x, float y, float z, float yaw)
    {
        lock (SummonedVehiclesSync)
        {
            SummonedVehicles[entityId] = new SummonedVehicle
            {
                ConfigId = configId,
                X = x,
                Y = y,
                Z = z,
                Yaw = yaw,
                HasFix = float.IsFinite(x) && float.IsFinite(y) && float.IsFinite(z),
                SeatCount = LookupSeatCount(configId),
                Interactable = true,
            };
            _lastSummonedEntity = entityId;
        }
    }

    private static int LookupSeatCount(uint configId)
    {
        try
        {
            if (VehicleCatalog4229938.TryGet(configId, out var config)
                && config.SeatCount is >= 1 and <= 16)
                return config.SeatCount;
        }
        catch
        {
        }
        return 2;
    }

    internal static void ForgetSummoned(ulong entityId)
    {
        lock (SummonedVehiclesSync)
            SummonedVehicles.Remove(entityId);
    }

    internal static void TrackVehicleMove(ulong entityId, float x, float y, float z, float yaw)
    {
        if (!float.IsFinite(x) || !float.IsFinite(y) || !float.IsFinite(z) || !float.IsFinite(yaw))
            return;
        lock (SummonedVehiclesSync)
        {
            // Only track server-summoned entities; traffic/AI vehicles stay untracked
            // so the registry cannot grow unbounded.
            if (SummonedVehicles.TryGetValue(entityId, out var existing))
            {
                existing.X = x;
                existing.Y = y;
                existing.Z = z;
                existing.Yaw = yaw;
                existing.HasFix = true;
            }
        }
    }

    [Handler(MethodId.AskSummonVehicle, HandlerPacketKind.Invoke)]
    private async Task AskSummonVehicle(Connection conn, UxRpcMessage msg)
    {
        if (!PrivateServerConfigStore.Current.Gameplay.Vehicles.Enabled)
        {
            await conn.ReturnEmptyAsync(msg, 1);
            return;
        }
        if (!msg.TryGetArgs<SceneMethods.AskSummonVehicle>(out var args) || args is null
            || msg.Body.Length != 20 || args.VehicleConfigId == 0
            || !float.IsFinite(args.Position.X) || !float.IsFinite(args.Position.Y) || !float.IsFinite(args.Position.Z)
            || !float.IsFinite(args.FacingDirection))
        {
            conn.Log.Warn($"[VEHICLE] AskSummonVehicle bad args bytes={msg.Body.Length}");
            await conn.ReturnEmptyAsync(msg, 1);
            return;
        }

        var result = await SpawnDirectAsync(
            msg.Context.Session,
            args.VehicleConfigId,
            new Vec3(args.Position.X, args.Position.Y, args.Position.Z),
            args.FacingDirection,
            rightOffset: 5.5f,
            sourceType: 2,
            reason: "client-summon");
        if (!result.Ok)
        {
            conn.Log.Warn($"[VEHICLE] summon rejected: {result.Message}");
            await conn.ReturnEmptyAsync(msg, 2);
            return;
        }
        await conn.ReturnAsync(msg, new SceneMethods.SummonVehicleResult
        {
            VehicleEntityId = result.EntityId,
            TaskToken = result.Token,
        });
    }

    /// <summary>
    /// Direct scene spawn shared by client summon and the debug panel: SyncLogicVehicleEnter
    /// + SyncSpawnVehicle (interactable) + SyncChangeVehicleInteractable. Offsets proven by V2:
    /// rightOffset meters to the right of the facing, +0.15m up.
    /// </summary>
    internal static async Task<(bool Ok, string Message, ulong EntityId, ulong Token, Vec3 SpawnPos)> SpawnDirectAsync(
        TcpSession session, uint configId, Vec3 nearPos, float facing, float rightOffset, byte sourceType, string reason)
    {
        if (configId == 0)
            return (false, "vehicle 0 does not exist", 0, 0, default);

        // Unknown / model-less ids are allowed with a warning (newer client data may know
        // more vehicles than our dump); the client validates against its own configs.
        var seatCount = 2;
        if (VehicleCatalog4229938.TryGet(configId, out var config))
        {
            if (config.SeatCount is >= 1 and <= 16)
                seatCount = config.SeatCount;
            if (string.IsNullOrWhiteSpace(config.Model))
                session.Log.Warn($"[VEHICLE] config {configId} has no prefab model in dump, trying anyway");
        }
        else
        {
            session.Log.Warn($"[VEHICLE] config {configId} not in VehicleConfig dump, trying with {seatCount} seats");
        }

        var yaw = facing * (MathF.PI / 180f);
        var spawn = new Vec3(
            nearPos.X + MathF.Cos(yaw) * rightOffset,
            nearPos.Y + 0.15f,
            nearPos.Z - MathF.Sin(yaw) * rightOffset);
        var entityId = (ulong)Interlocked.Increment(ref _vehicleEntitySeq);
        var token = (ulong)Interlocked.Increment(ref _vehicleTaskSeq);
        RegisterSummoned(entityId, configId, spawn.X, spawn.Y, spawn.Z, facing);

        var euler = new SceneMethods.UxVector3(0f, facing, 0f);
        var pos = new SceneMethods.UxVector3(spawn.X, spawn.Y, spawn.Z);
        await session.NotifyAsync(MethodId.SyncLogicVehicleEnter, UxSerializer.Serialize(new SceneMethods.SyncLogicVehicleEnter
        {
            EntityId = entityId,
            VehicleConfigId = configId,
            CreateSourceType = sourceType,
            Parts = [],
            SuitId = 0,
            LicensePlate = string.Empty,
            Interactable = true,
            MoveToken = 0,
            Position = pos,
            EulerAngles = euler,
            VehicleSpoonName = null,
        }), CancellationToken.None);
        await session.NotifyAsync(MethodId.SyncSpawnVehicle, UxSerializer.Serialize(new SceneMethods.VehicleClientInfo
        {
            ControllerPid = 0,
            CreateSourceType = sourceType,
            EntityId = entityId,
            VehicleConfigId = configId,
            Parts = [],
            SuitId = 0,
            Position = pos,
            Facing = facing,
            EulerAngles = euler,
            Velocity = 0,
            IsStatic = false,
            DeformStatus = 0,
            SeatInfos = Enumerable.Range(0, seatCount).Select(i => new SceneMethods.RaidVehicleSeatInfo
            {
                EntityId = 0,
                SeatIndex = (byte)i,
                SeatState = 0,
                DestroyRelated = false,
            }).ToList(),
            SpoonId = 0,
            IsDynamicGo = false,
            VehicleEnemyId = 0,
            DisableNavigation = false,
            Interactable = true,
            MoveToken = 0,
            LicensePlate = string.Empty,
        }), CancellationToken.None);
        await session.NotifyAsync(MethodId.SyncChangeVehicleInteractable, UxSerializer.Serialize(
            new SceneMethods.SyncChangeVehicleInteractable { VehicleInstanceId = entityId, Interactable = true }),
            CancellationToken.None);
        session.Log.Info($"[VEHICLE] DIRECT_SPAWN reason={reason} config={configId} entity={entityId} token={token} seats={seatCount} spawn=({spawn.X:F1},{spawn.Y:F1},{spawn.Z:F1})");
        return (true, "spawned", entityId, token, spawn);
    }

    internal static async Task DestroyDirectAsync(TcpSession session, ulong entityId, string reason)
    {
        ForgetSummoned(entityId);
        ResetVehicleStoryForEntity(session, entityId);
        await session.NotifyAsync(MethodId.SyncDestroyVehicle, UxSerializer.Serialize(
            new SceneMethods.DestroyVehicle { VehicleEntityId = entityId, VehicleDestroyType = 0, Distance = 0, DynamicGoId = 0 }),
            CancellationToken.None);
        session.Log.Info($"[VEHICLE] destroy entity={entityId} reason={reason}");
    }

    internal static SceneMethods.AskGetUnlockedVehiclesResult BuildUnlockedResult()
    {
        var fleet = PrivateServerConfigStore.Current.Gameplay.Vehicles.FleetIds;
        return new SceneMethods.AskGetUnlockedVehiclesResult
        {
            Vehicles = fleet.Select(id => new SceneMethods.PlayerVehicleClientDetail
            {
                Id = id,
                Parts = [],
                SuitId = 0,
                IsPersistent = true,
            }).ToList(),
        };
    }

    /// <summary>
    /// Push the owned fleet right after world entry finalization (first gameplay movement),
    /// so the phone/garage UI is populated without a manual resync. Once per entry.
    /// </summary>
    internal static async Task PublishGarageAsync(RpcContext ctx)
    {
        if (!PrivateServerConfigStore.Current.Gameplay.Vehicles.Enabled)
            return;
        if (!(ctx.Session.Items.TryGetValue(WorldStateKey, out var raw) && raw is WorldEntryState world))
            return;
        bool first;
        lock (world.SyncRoot)
        {
            first = !world.GaragePublished;
            if (first)
                world.GaragePublished = true;
        }
        if (!first)
            return;
        var result = BuildUnlockedResult();
        await ctx.NotifyAsync(MethodId.SyncAllUnlockedVehicles, result);
        ctx.Session.Log.Info($"[VEHICLE] garage auto-published count={result.Vehicles.Count}");
    }

    /// <summary>
    /// Push Aether vehicle-AI init once per world entry (mirrors V2): RaidId +
    /// zone-graph handle + empty lists. The client DriveManager gates vehicle
    /// materialization on this init; without it spawns stay invisible.
    /// </summary>
    internal static async Task PublishAetherInitAsync(RpcContext ctx)
    {
        if (!PrivateServerConfigStore.Current.Gameplay.Vehicles.Enabled)
            return;
        if (!(ctx.Session.Items.TryGetValue(WorldStateKey, out var raw) && raw is WorldEntryState world))
            return;
        bool first;
        uint raidId;
        lock (world.SyncRoot)
        {
            first = !world.AetherVehicleInitSent;
            if (first)
                world.AetherVehicleInitSent = true;
            raidId = world.ActiveRaidId;
        }
        if (!first)
            return;
        var settings = PrivateServerConfigStore.Current.Gameplay.Vehicles;
        var hasZoneGraph = raidId == PrivateServerConfigStore.Current.World.RaidId;
        await ctx.NotifyAsync(MethodId.SyncAetherAIInitDatas, new SceneMethods.AetherAIInitData
        {
            RaidId = raidId,
            HasZoneGraph = hasZoneGraph,
            ZoneStorageDataHandle = hasZoneGraph ? settings.ZoneStorageDataHandle : 0,
            Intersections = [],
            Vehicles = [],
            StaticVehicles = [],
        });
        ctx.Session.Log.Info($"[VEHICLE] aether-init raid={raidId} zoneGraph={hasZoneGraph} lists=empty");
    }

    [Handler(MethodId.AskGetUnlockedVehicles, HandlerPacketKind.Invoke)]
    private Task AskGetUnlockedVehicles(Connection conn, UxRpcMessage msg)
    {
        var result = BuildUnlockedResult();
        conn.Log.Info($"[VEHICLE] unlocked list -> {result.Vehicles.Count} vehicles");
        return conn.ReturnAsync(msg, result);
    }

    // Client-driven enter/exit + movement reports. The client owns the simulation;
    // the server accepts them so the drive loop never stalls waiting for a reply.
    // AskVehicleMove additionally feeds the debug panel's live coordinates.
    [Handler(MethodId.AskVehicleMove, HandlerPacketKind.Notify)]
    private Task AskVehicleMove(Connection conn, UxRpcMessage msg)
    {
        try
        {
            var data = msg.GetArgs<SceneMethods.RaidVehicleSyncData>();
            TrackVehicleMove(data.Id, data.Position.X, data.Position.Y, data.Position.Z, data.FacingDirection);
        }
        catch (Exception ex)
        {
            conn.Log.Warn($"[VEHICLE] move parse failed, accepted anyway: {ex.Message}");
        }
        return Task.CompletedTask;
    }

    [Handler(MethodId.AskPlayerStartEnterOrExitVehicle, HandlerPacketKind.Notify)]
    [Handler(MethodId.AskPlayerFinishEnterOrExitVehicle, HandlerPacketKind.Notify)]
    [Handler(MethodId.AskVehicleStartMove, HandlerPacketKind.Notify)]
    [Handler(MethodId.AskVehicleStopMove, HandlerPacketKind.Notify)]
    [Handler(MethodId.AskVehicleHorn, HandlerPacketKind.Notify)]
    [Handler(MethodId.AskEnterVehicleIndoor, HandlerPacketKind.Notify)]
    [Handler(MethodId.AskExitVehicleIndoor, HandlerPacketKind.Notify)]
    [Handler(MethodId.ReportDrivingVehicle, HandlerPacketKind.Notify)]
    [Handler(MethodId.AskKillVehicle, HandlerPacketKind.Notify)]
    private Task VehicleNotifyAccept(Connection conn, UxRpcMessage msg) => Task.CompletedTask;

    // Drive-loop invokes with void returns (combat/contact/horn-nitro/state signals).
    [Handler(MethodId.VehicleDriveStateChange, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskChangeGoVehicleDriveState, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskVehicleDeadEnd, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskVehicleNitro, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskVehicleStuck, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskVehicleHit, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskVehicleHitEnd, HandlerPacketKind.Invoke)]
    private Task VehicleInvokeAccept(Connection conn, UxRpcMessage msg)
        => conn.ReturnEmptyOkAsync(msg);
}
