using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// Vehicle ownership + direct summon (Phase 2). Ported from the proven newcityps
/// (4091149) direct-scene-spawn path, with 4229938 wire deltas applied
/// (LogicVehicleClientInfo.VehicleSpoonName, PlayerVehicleClientDetail.IsPersistent).
/// No road-planner/AI-task leg: the vehicle materializes beside the player,
/// already interactable, and the stock client seat/drive lifecycle takes over.
/// Enter/exit/move notifies are logged + tracked; pushes for those come after
/// live-traffic observation (see KNOWLEDGEBASE.md §4).
/// </summary>
internal sealed partial class GameRouter
{
    private const string VehicleRuntimeKey = "client4229938-vehicles";
    private static long s_nextVehicleEntity = 8_200_000_000_000_000_000L;
    private static long s_nextVehicleToken = 7_100_000_000_000_000_000L;

    internal sealed class VehicleRecord
    {
        public ulong EntityId;
        public uint ConfigId;
        public int SeatCount;
        public Vec3 Position;
        public float Facing;
        public ulong ControllerPid;
        public bool Interactable;
        public ulong TaskToken;
        public List<byte> LastBits = [];
        public bool MoveLogged;
        public double DistanceDriven;
        public bool IsDriving;
        public float LastNitroValue;
        public float TopSpeed;
        public bool HasTopSpeed;
        public Dictionary<byte, ulong> SeatReservations { get; } = new();
        public Dictionary<byte, ulong> SeatOccupants { get; } = new();
    }

    internal sealed class VehicleRuntimeState
    {
        public object SyncRoot { get; } = new();
        public HashSet<uint> Unlocked { get; } = new();
        public Dictionary<ulong, VehicleRecord> Vehicles { get; } = new();
        public ulong SummonedEntity;
        public ulong CurrentVehicleId;
        public int CurrentVehicleSeat = -1;
        public bool OwnershipSent;
        public bool AetherInitSent;

        // S011 story/boarding state (single-player: one active enter/exit transaction).
        public bool StoryRootSent;
        public bool StorySeenAnyRpc;
        public long StoryHighestConfirmedRpcId = -1;
        public SortedSet<long> StoryPendingRpcIds { get; } = new();
        public HashSet<long> StoryCommittedRpcIds { get; } = new();
        public ulong StoryEnterVehicleId;
        public byte StoryEnterSeat;
        public bool StoryExitInProgress;
        public ulong StoryBoardingUnitId;

        public void Clear()
        {
            lock (SyncRoot)
            {
                Vehicles.Clear();
                SummonedEntity = 0;
                CurrentVehicleId = 0;
                CurrentVehicleSeat = -1;
                StoryEnterVehicleId = 0;
                StoryEnterSeat = 0;
                StoryExitInProgress = false;
                StoryPendingRpcIds.Clear();
                StoryCommittedRpcIds.Clear();
            }
        }
    }

    internal static VehicleRuntimeState GetVehicleRuntimeState(TcpSession session)
    {
        if (session.Items.TryGetValue(VehicleRuntimeKey, out var raw) && raw is VehicleRuntimeState existing)
            return existing;
        var created = new VehicleRuntimeState();
        foreach (var vehicle in VehicleCatalog4229938.AllSummonable)
            created.Unlocked.Add(vehicle.Id);
        session.Items[VehicleRuntimeKey] = created;
        return created;
    }

    private static VehicleRuntimeState GetVehicleRuntime(RpcContext ctx) => GetVehicleRuntimeState(ctx.Session);

    private static List<GameMethods.PlayerVehicleClientDetail4229938> VehicleOwnershipSnapshot(VehicleRuntimeState runtime)
    {
        lock (runtime.SyncRoot)
        {
            return runtime.Unlocked.OrderBy(x => x).Take(512)
                .Select(id => new GameMethods.PlayerVehicleClientDetail4229938 { Id = id, Parts = [], SuitId = 0, IsPersistent = false })
                .ToList();
        }
    }

    internal static async Task PublishVehicleOwnership(RpcContext ctx)
    {
        if (!PrivateServerConfigStore.Current.Gameplay.Vehicles.Enabled)
            return;
        var runtime = GetVehicleRuntime(ctx);
        lock (runtime.SyncRoot)
        {
            if (runtime.OwnershipSent)
                return;
            runtime.OwnershipSent = true;
        }
        var snapshot = VehicleOwnershipSnapshot(runtime);
        await ctx.NotifyAsync(MethodId.SyncAllUnlockedVehicles, snapshot);
        ctx.Session.Log.Info($"[VEHICLE] ownership published count={snapshot.Count}");
    }

    internal static async Task EnsureAetherVehicleInit(RpcContext ctx)
    {
        if (!PrivateServerConfigStore.Current.Gameplay.Vehicles.Enabled)
            return;
        var runtime = GetVehicleRuntime(ctx);
        lock (runtime.SyncRoot)
        {
            if (runtime.AetherInitSent)
                return;
            runtime.AetherInitSent = true;
        }
        var settings = PrivateServerConfigStore.Current.Gameplay.Vehicles;
        var activeRaidId = GetStateIfExists(ctx.Session)?.ActiveRaidId ?? Profile.RaidId;
        var hasZoneGraph = activeRaidId == PrivateServerConfigStore.Current.World.RaidId;
        await ctx.NotifyAsync(MethodId.SyncAetherAIInitDatas, new GameMethods.AetherAIInitData4229938
        {
            RaidId = activeRaidId,
            HasZoneGraph = hasZoneGraph,
            ZoneStorageDataHandle = hasZoneGraph ? settings.ZoneStorageDataHandle : 0,
            Intersections = [],
            Vehicles = [],
            StaticVehicles = [],
        });
        ctx.Session.Log.Info($"[VEHICLE] aether-init raid={activeRaidId} zoneGraph={hasZoneGraph} lists=empty");
    }

    /// <summary>
    /// Interact heartbeat/sync channel. Decoded + logged so a future F-press via the
    /// interact system is visible; currently accepted without side effects.
    /// </summary>
    [Handler(MethodId.AskInteractCmd, HandlerPacketKind.Notify)]
    private Task AskInteractCmd(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.AskInteractCmdArgs4229938>(out var args) && args is not null)
        {
            // Heartbeat CmdType=19 from pid 666 arrives ~2x/sec; log only anything else.
            if (args.CmdType != 19)
                conn.Log.Info($"[INTERACT] cmd={args.CmdType} sender={args.sender} receiver={args.receiver} broadcast={args.broadCastType} data={args.CommandData?.Count ?? -1}b s1={args.stringParam1} s2={args.stringParam2}");
        }
        else
        {
            conn.Log.Warn($"[INTERACT] AskInteractCmd undecodable bytes={msg.Body.Length}");
        }
        return Task.CompletedTask;
    }

    [Handler(MethodId.AskGetUnlockedVehicles, HandlerPacketKind.Invoke)]
    private Task AskGetUnlockedVehicles(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, VehicleOwnershipSnapshot(GetVehicleRuntime(msg.Context)));

    [Handler(MethodId.AskSummonVehicle, HandlerPacketKind.Invoke)]
    private async Task AskSummonVehicle(Connection conn, UxRpcMessage msg)
    {
        if (!PrivateServerConfigStore.Current.Gameplay.Vehicles.Enabled)
        {
            await conn.ReturnEmptyAsync(msg, 1);
            return;
        }
        if (!msg.TryGetArgs<GameMethods.AskSummonVehicleArgs4229938>(out var args) || args is null
            || msg.Body.Length != 20 || args.vehicleconfigid == 0
            || !float.IsFinite(args.position.X) || !float.IsFinite(args.position.Y) || !float.IsFinite(args.position.Z)
            || !float.IsFinite(args.facingdirection))
        {
            conn.Log.Warn($"[VEHICLE] AskSummonVehicle bad args bytes={msg.Body.Length}");
            await conn.ReturnEmptyAsync(msg, 1);
            return;
        }
        if (!VehicleCatalog4229938.TryGet(args.vehicleconfigid, out var config)
            || string.IsNullOrWhiteSpace(config.Model) || config.SeatCount is < 1 or > 16)
        {
            conn.Log.Warn($"[VEHICLE] AskSummonVehicle unknown vehicle={args.vehicleconfigid}");
            await conn.ReturnEmptyAsync(msg, 2);
            return;
        }

        var playerPos = new Vec3(args.position.X, args.position.Y, args.position.Z);
        var result = await SpawnDirectAsync(msg.Context.Session, args.vehicleconfigid, playerPos, args.facingdirection, "client-summon");
        if (!result.Ok)
        {
            await conn.ReturnEmptyAsync(msg, 3);
            return;
        }
        await conn.ReturnAsync(msg, new GameMethods.SummonVehicleResult4229938
        {
            VehicleEntityId = result.EntityId,
            TaskToken = result.Token,
        });
    }

    /// <summary>
    /// Direct scene spawn shared by client summon and the admin panel:
    /// SyncLogicVehicleEnter + SyncSpawnVehicle (interactable) + SyncChangeVehicleInteractable.
    /// Returns the new entity id + task token. Replaces the previous summoned vehicle.
    /// </summary>
    internal static async Task<(bool Ok, string Message, ulong EntityId, ulong Token)> SpawnDirectAsync(
        TcpSession session, uint vehicleId, Vec3 nearPos, float facing, string reason)
    {
        if (!VehicleCatalog4229938.TryGet(vehicleId, out var config)
            || string.IsNullOrWhiteSpace(config.Model) || config.SeatCount is < 1 or > 16)
            return (false, $"vehicle {vehicleId} is not summonable (no prefab or bad seat count)", 0, 0);

        var runtime = GetVehicleRuntimeState(session);
        ulong oldEntity;
        lock (runtime.SyncRoot)
        {
            oldEntity = runtime.SummonedEntity;
            if (oldEntity != 0 && runtime.CurrentVehicleId == oldEntity)
                return (false, "current summoned vehicle is occupied (exit it first)", 0, 0);
        }
        if (oldEntity != 0)
            await DestroyVehicleAsync(session, runtime, oldEntity, "replacement");

        // Spawn beside the player: 5.5m to the right, +0.15m up (proven offsets).
        var yaw = facing * (MathF.PI / 180f);
        var spawn = new Vec3(nearPos.X + MathF.Cos(yaw) * 5.5f, nearPos.Y + 0.15f, nearPos.Z - MathF.Sin(yaw) * 5.5f);
        var entityId = unchecked((ulong)Interlocked.Increment(ref s_nextVehicleEntity));
        var token = unchecked((ulong)Interlocked.Increment(ref s_nextVehicleToken));
        var record = new VehicleRecord
        {
            EntityId = entityId, ConfigId = config.Id, SeatCount = config.SeatCount,
            Position = spawn, Facing = facing, ControllerPid = 0, Interactable = true, TaskToken = token,
        };
        lock (runtime.SyncRoot)
        {
            runtime.Vehicles[entityId] = record;
            runtime.SummonedEntity = entityId;
        }
        var state = GetStateIfExists(session);
        if (state is not null)
        {
            lock (state.SyncRoot)
            {
                state.LastAdminVehicleId = vehicleId;
                state.LastSpawnedVehicleUid = entityId;
            }
        }

        var euler = new SceneMethods.UxVector3(0f, facing, 0f);
        var pos = new SceneMethods.UxVector3(spawn.X, spawn.Y, spawn.Z);
        await session.NotifyAsync(MethodId.SyncLogicVehicleEnter, UxSerializer.Serialize(new GameMethods.LogicVehicleClientInfo4229938
        {
            EntityId = entityId, VehicleConfigId = config.Id, CreateSourceType = 2,
            Parts = [], SuitId = 0, LicensePlate = string.Empty, Interactable = true, MoveToken = 0,
            Position = pos, EulerAngles = euler, VehicleSpoonName = null,
        }), CancellationToken.None);
        await session.NotifyAsync(MethodId.SyncSpawnVehicle, UxSerializer.Serialize(new GameMethods.VehicleClientInfo4229938
        {
            ControllerPid = 0, CreateSourceType = 2, EntityId = entityId, VehicleConfigId = config.Id,
            Parts = [], SuitId = 0, Position = pos, Facing = facing, EulerAngles = euler, Velocity = 0,
            IsStatic = false, DeformStatus = 0,
            SeatInfos = Enumerable.Range(0, config.SeatCount).Select(i => new GameMethods.RaidVehicleSeatInfo4229938
                { EntityId = 0, SeatIndex = (byte)i, SeatState = 0, DestroyRelated = false }).ToList(),
            SpoonId = 0, IsDynamicGo = false, VehicleEnemyId = 0, DisableNavigation = false,
            Interactable = true, MoveToken = 0, LicensePlate = string.Empty,
        }), CancellationToken.None);
        await session.NotifyAsync(MethodId.SyncChangeVehicleInteractable, UxSerializer.Serialize(
            new GameMethods.SyncChangeVehicleInteractable4229938 { vehicleInstanceId = entityId, interactable = true }),
            CancellationToken.None);
        session.Log.Info($"[VEHICLE] DIRECT_SPAWN reason={reason} config={config.Id} entity={entityId} token={token} seats={config.SeatCount} spawn=({spawn.X:F1},{spawn.Y:F1},{spawn.Z:F1})");
        return (true, $"spawned vehicle {vehicleId} (entity={entityId}) beside you — walk up and press F", entityId, token);
    }

    internal static async Task DestroyVehicleAsync(TcpSession session, VehicleRuntimeState runtime, ulong entityId, string reason)
    {
        lock (runtime.SyncRoot)
        {
            runtime.Vehicles.Remove(entityId);
            if (runtime.SummonedEntity == entityId)
                runtime.SummonedEntity = 0;
            if (runtime.CurrentVehicleId == entityId)
            {
                runtime.CurrentVehicleId = 0;
                runtime.CurrentVehicleSeat = -1;
            }
        }
        await session.NotifyAsync(MethodId.SyncDestroyVehicle, UxSerializer.Serialize(
            new GameMethods.DestroyVehicle4229938 { VehicleEntityId = entityId, VehicleDestroyType = 0, Distance = 0, DynamicGoId = 0 }),
            CancellationToken.None);
        session.Log.Info($"[VEHICLE] destroy entity={entityId} reason={reason}");
    }

    // --- Enter / exit / move tracking (notifies; logged + recorded, no speculative pushes yet) ---

    [Handler(MethodId.AskPlayerStartEnterOrExitVehicle)]
    private Task AskPlayerStartEnterOrExitVehicle(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.PlayerVehicleDriveStateInfo4229938>(out var args) && args is not null)
        {
            var runtime = GetVehicleRuntime(msg.Context);
            lock (runtime.SyncRoot)
            {
                if (args.EnterOrLeave)
                {
                    runtime.CurrentVehicleId = args.VehicleEntityId;
                    runtime.CurrentVehicleSeat = args.SeatIndex;
                    if (runtime.Vehicles.TryGetValue(args.VehicleEntityId, out var record))
                        record.ControllerPid = args.Pid;
                }
                else if (runtime.CurrentVehicleId == args.VehicleEntityId)
                {
                    runtime.CurrentVehicleId = 0;
                    runtime.CurrentVehicleSeat = -1;
                }
            }
            conn.Log.Info($"[VEHICLE] {(args.EnterOrLeave ? "ENTER" : "EXIT")} pid={args.Pid} vehicle={args.VehicleEntityId} seat={args.SeatIndex} force={args.IfForce}");
        }
        else
        {
            conn.Log.Warn($"[VEHICLE] AskPlayerStartEnterOrExitVehicle undecodable bytes={msg.Body.Length}");
        }
        return Task.CompletedTask;
    }

    [Handler(MethodId.AskPlayerFinishEnterOrExitVehicle)]
    private Task AskPlayerFinishEnterOrExitVehicle(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.PlayerVehicleDriveStateInfo4229938>(out var args) && args is not null)
            conn.Log.Info($"[VEHICLE] FINISH {(args.EnterOrLeave ? "enter" : "exit")} vehicle={args.VehicleEntityId} seat={args.SeatIndex}");
        else
            conn.Log.Warn($"[VEHICLE] AskPlayerFinishEnterOrExitVehicle undecodable bytes={msg.Body.Length}");
        return Task.CompletedTask;
    }

    [Handler(MethodId.AskVehicleMove)]
    private Task AskVehicleMove(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.RaidVehicleSyncData4229938>(out var args) && args is not null)
        {
            var runtime = GetVehicleRuntime(msg.Context);
            bool firstLog = false;
            lock (runtime.SyncRoot)
            {
                if (runtime.Vehicles.TryGetValue(args.Id, out var record))
                {
                    record.Position = new Vec3(args.Position.X, args.Position.Y, args.Position.Z);
                    record.Facing = args.facingDirection;
                    record.LastBits = args.Bits ?? [];
                    firstLog = !record.MoveLogged;
                    record.MoveLogged = true;
                }
                // While driving, the vehicle IS the player position (admin panel follows).
                if (runtime.CurrentVehicleId == args.Id)
                {
                    var state = GetStateIfExists(msg.Context.Session);
                    if (state is not null)
                    {
                        state.LastReportedPlayerPosition = new Vec3(args.Position.X, args.Position.Y, args.Position.Z);
                        state.HasLastReportedPlayerTransform = true;
                    }
                }
            }
            if (firstLog)
                conn.Log.Info($"[VEHICLE] move-start entity={args.Id} pos=({args.Position.X:F1},{args.Position.Y:F1},{args.Position.Z:F1})");
        }
        return Task.CompletedTask;
    }

    // AskClaimVehicleSeat lives in GameRouter.VehicleStory.cs (story-aware seat re-pin).
}
