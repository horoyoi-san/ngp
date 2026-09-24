using System.Diagnostics;
using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    private const long AetherVehicleIdBase = 700000000000L;
    private const long AetherVehicleNpcIdBase = 700500000000L;
    private const long AetherCrowdIdBase = 800000000000L;

    
    
    
    
    private const long AetherFixedNpcIdBase = 800500000000L;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private static async Task RemoveAmbientVehicleAsync(
        TcpSession session, AmbientVehicleState v, CancellationToken token)
    {
        if (v.DriverNpcId != 0)
        {
            await session.NotifyAsync(MethodId.SyncAetherAINpcRemove,
                UxSerializer.Serialize(new SceneMethods.SyncAetherAINpcRemove4229938
                {
                    pid = v.DriverNpcId,
                }), token);
        }
        await session.NotifyAsync(MethodId.SyncAetherAIVehicleRemove,
            UxSerializer.Serialize(new SceneMethods.SyncAetherAIVehicleRemove4229938 { pid = v.EntityId }),
            token);
    }

    
    
    
    
    private const string BehaviorTaskSeqKey = "Ananta.aether.behaviorTaskSeq";

    private static ulong NextBehaviorTaskInstanceId(TcpSession session)
    {
        lock (session.Items)
        {
            session.Items.TryGetValue(BehaviorTaskSeqKey, out var raw);
            var n = raw is ulong u ? u + 1UL : 1UL;
            session.Items[BehaviorTaskSeqKey] = n;
            return n;
        }
    }

    
    
    
    
    
    
    private static uint ResolveBehaviorTaskId(int configured, uint autoId)
        => configured == 0 ? autoId : configured < 0 ? 0u : (uint)configured;

    private const string AetherInitSentKey = "Ananta.aether.initSent";
    private const string AmbientVehiclesKey = "Ananta.ambient.vehicles";
    private const string CrowdKey = "Ananta.ambient.crowd";

    
    private const string FixedNpcKey = "Ananta.ambient.fixednpc";

    
    private const string FixedNpcBackoffKey = "Ananta.aether.fixednpcBackoff";

    private static long _ambientVehicleSeq;
    private static long _crowdSeq;
    private static long _fixedNpcSeq;

    
    
    
    
    
    
    private static bool FixedNpcTopUpAllowed(TcpSession session)
    {
        var now = Environment.TickCount64;
        lock (session.Items)
        {
            if (session.Items.TryGetValue(FixedNpcBackoffKey, out var raw)
                && raw is long until && now < until)
                return false;
        }
        return true;
    }

    
    private static void MarkFixedNpcTopUpFailed(TcpSession session)
    {
        var seconds = PrivateServerConfigStore.Current.Gameplay.Aether.FixedNpcTopUpBackoffSeconds;
        if (seconds <= 0f)
            return;
        lock (session.Items)
            session.Items[FixedNpcBackoffKey] = Environment.TickCount64 + (long)(seconds * 1000f);
    }

    
    private static void ClearFixedNpcTopUpBackoff(TcpSession session)
    {
        lock (session.Items)
            session.Items.Remove(FixedNpcBackoffKey);
    }

    
    
    
    
    
    
    private static byte[] BuildWanderBody(
        ulong id, float minDis, float maxDis, float maxTime, float onceTime, AetherSettings aether)
        => UxSerializer.Serialize(new SceneMethods.SyncMoveWandering4229938
        {
            data = new SceneMethods.MoveWanderingData4229938
            {
                
                
                pathTags = (uint)aether.CrowdWanderPathTags,
                CloseObstacleAvoidance = aether.CrowdWanderAvoidance,
                MinDis = Math.Max(0f, minDis),
                MaxDis = Math.Max(minDis, maxDis),
                InRangeAngle = aether.CrowdWanderLeftAngle,
                OutRangeAngle = aether.CrowdWanderRightAngle,
                MaxTime = Math.Max(1f, maxTime),
                MaxOnceWanderTime = Math.Max(1f, onceTime),
                UnitId = id,
                MoveType = aether.CrowdWanderMoveType,
                MoveId = 0,
                CloseIK = false,
                InstanceId = 0,
                BlockCloseCapsuleCollision = false,
            },
        });

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private static async Task<int> ReWanderAsync(
        TcpSession session, List<CrowdState> npcs, float seconds,
        float minDis, float maxDis, float maxTime, float onceTime,
        AetherSettings aether, CancellationToken token)
    {
        if (seconds <= 0f || npcs.Count == 0)
            return 0;

        var now = Environment.TickCount64;
        var dueMs = (long)(seconds * 1000f);
        List<ulong>? due = null;
        lock (session.Items)
        {
            foreach (var n in npcs)
            {
                if (!n.StaticChannel || now - n.LastWanderMs < dueMs)
                    continue;
                n.LastWanderMs = now;
                (due ??= []).Add(n.Id);
            }
        }
        if (due is null)
            return 0;

        foreach (var id in due)
            await session.NotifyAsync(MethodId.SyncMoveWandering,
                BuildWanderBody(id, minDis, maxDis, maxTime, onceTime, aether), token);
        return due.Count;
    }

    
    private static readonly Stopwatch Uptime = Stopwatch.StartNew();

    
    
    
    
    
    
    
    
    
    
    private static readonly double ClockAnchorUnix =
        DateTimeOffset.UtcNow.ToUnixTimeMilliseconds() / 1000.0;

    private static double ServerClockUnix() => ClockAnchorUnix + Uptime.Elapsed.TotalSeconds;

    
    
    
    
    
    
    internal sealed class AmbientVehicleState
    {
        internal ulong EntityId;
        internal uint ConfigId;
        internal uint ColorId;

        
        internal int LaneId;

        
        internal float Distance;

        
        
        
        
        
        
        
        
        
        
        
        
        internal float AnchorDistance;
        internal double AnchorTime;

        
        internal float Speed;

        
        internal float BaseSpeed;

        
        internal float RandomFraction;

        
        internal int NextCursor;

        
        internal float X;
        internal float Z;

        
        internal uint DriverPersonaId;

        
        
        
        
        
        
        internal uint DriverFormworkId;

        
        
        
        
        
        
        
        
        
        internal double SpawnedAt;

        
        
        
        
        
        
        
        
        internal ulong DriverNpcId;

        
        
        
        
        
        
        
        
        
        internal int DriverReAddCount;
    }

    
    internal sealed class CrowdState
    {
        internal ulong Id;

        
        internal long SlotKey;

        
        
        
        
        
        internal bool StaticChannel;

        internal float X;
        internal float Z;

        
        
        
        
        
        
        
        internal long LastWanderMs;
    }

    
    private static bool TryMarkAetherInitSent(TcpSession session, uint raidId)
    {
        lock (session.Items)
        {
            if (session.Items.ContainsKey(AetherInitSentKey))
                return false;
            session.Items[AetherInitSentKey] = raidId;
            return true;
        }
    }

    
    
    
    
    
    private static bool ShouldWarn(TcpSession session, string key, int seconds = 30)
    {
        var now = Environment.TickCount64;
        lock (session.Items)
        {
            if (session.Items.TryGetValue(key, out var raw) && raw is long last
                && now - last < seconds * 1000L)
                return false;
            session.Items[key] = now;
            return true;
        }
    }

    

    
    
    
    
    
    
    private static double LaneDataTimeStamp()
    {
        var aether = PrivateServerConfigStore.Current.Gameplay.Aether;
        return aether.LaneDataTimeBase?.Trim().ToLowerInvariant() switch
        {
            "monotonic" => Uptime.Elapsed.TotalSeconds,
            "uptime" => Environment.TickCount64 / 1000.0,
            
            _ => ServerClockUnix(),
        };
    }

    

    
    
    
    
    
    
    private static float SpeedFor(TrafficLane lane, float randomFraction, AetherSettings aether)
    {
        var variance = Math.Clamp(aether.SpeedVariance, 0f, 1f);
        var baseline = lane.SpeedLimit > 0.5f
            ? lane.SpeedLimit
            : (aether.VehicleSpeedMin + aether.VehicleSpeedMax) * 0.5f;
        var speed = baseline * (1f - variance * 0.5f + variance * randomFraction);
        var lo = Math.Min(aether.VehicleSpeedMin, aether.VehicleSpeedMax);
        var hi = Math.Max(aether.VehicleSpeedMin, aether.VehicleSpeedMax);
        return Math.Clamp(speed, lo, hi);
    }

    
    
    
    
    
    internal static async Task<int> PushAetherVehiclesAsync(
        TcpSession session,
        uint raidId,
        float originX, float originY, float originZ,
        float headingDeg,
        int vehicleCount,
        CancellationToken token = default,
        bool createEntities = true,
        double phase = 0.0)
    {
        _ = headingDeg;
        _ = phase;

        var settings = PrivateServerConfigStore.Current.Gameplay.Vehicles;
        var aether = PrivateServerConfigStore.Current.Gameplay.Aether;

        if (!settings.Enabled)
            return 0;

        
        if (createEntities && TryMarkAetherInitSent(session, raidId))
        {
            await session.NotifyAsync(MethodId.SyncAetherAIInitDatas, BuildAetherInit(raidId), token);

            
            
            if (aether.IntersectionUpdateEnabled)
                await PushIntersectionUpdatesAsync(session, token);

            var settle = aether.InitSettleMs;
            if (settle > 0)
                await Task.Delay(settle, token);
        }

        
        List<AmbientVehicleState> states;
        lock (session.Items)
        {
            if (!session.Items.TryGetValue(AmbientVehiclesKey, out var raw) || raw is not List<AmbientVehicleState> l)
            {
                l = [];
                session.Items[AmbientVehiclesKey] = l;
            }
            states = l;
        }

        
        
        int stateCount;
        lock (session.Items)
            stateCount = states.Count;
        var wantVehicleTotal = Math.Clamp(settings.AetherVehicleCount, 0, 64);
        var count = Math.Clamp(vehicleCount, 0, 64);
        count = Math.Min(count, Math.Max(0, wantVehicleTotal - stateCount));
        if (count == 0)
            return 0;

        var radius = Math.Max(60f, aether.VehicleSpawnRadiusMeters);

        HashSet<int> occupied;
        lock (session.Items)
            occupied = [.. states.Select(static s => s.LaneId)];

        
        
        
        
        
        
        
        var minSpawnDist = Math.Max(0f, aether.VehicleSpawnMinDistanceMeters);
        var lanes = TrafficLaneTable.Near(originX, originZ, radius, count,
            lane => !occupied.Contains(lane.LaneId),
            minSpawnDist, aether.VehiclePreferInbound);
        if (lanes.Count == 0 && minSpawnDist > 0f)
            lanes = TrafficLaneTable.Near(originX, originZ, radius, count,
                lane => !occupied.Contains(lane.LaneId), 0f, aether.VehiclePreferInbound);
        if (lanes.Count == 0)
        {
            if (ShouldWarn(session, "Ananta.aether.warn.nolane"))
                session.Log.Warn(
                    $"[AETHER] 玩家 ({originX:F0},{originZ:F0}) 半径 {radius:F0}m 内没有空闲车道"
                    + $"（表共 {TrafficLaneTable.Count} 条，有后继 {TrafficLaneTable.DrivableCount} 条，"
                    + $"已占用 {occupied.Count} 条）—— 车流不生成（同一条只每 30s 报一次）");
            return 0;
        }

        var spawns = VehicleSpawnCatalog.Ambient;
        if (spawns.Count == 0)
        {
            session.Log.Warn("[AETHER] VehicleSpawnConfig 里没有 InMass 条目 —— 车流不生成");
            return 0;
        }

        var rng = new Random(unchecked((int)(DateTime.UtcNow.Ticks ^ (long)raidId)));
        var stamp = LaneDataTimeStamp();

        var spawned = 0;
        foreach (var lane in lanes)
        {
            if (token.IsCancellationRequested)
                break;

            
            
            
            var seq = Interlocked.Increment(ref _ambientVehicleSeq) - 1;
            var entityId = (ulong)(AetherVehicleIdBase + seq);
            var spawn = spawns[rng.Next(spawns.Count)];
            var colorId = spawn.ColorMods.Length > 0 ? spawn.ColorMods[rng.Next(spawn.ColorMods.Length)] : 0u;
            var randomFraction = (float)rng.NextDouble();

            
            var d = lane.Length <= 2f
                ? 0f
                : (float)(rng.NextDouble() * lane.Length * 0.6 + lane.Length * 0.1);
            var (px, py, pz, facing) = lane.AtDistance(d);
            var speed = SpeedFor(lane, randomFraction, aether);

            
            
            
            
            
            
            
            if (aether.CreateBaseVehicle)
            {
                var pos0 = new SceneMethods.UxVector3(px, py, pz);
                var euler0 = new SceneMethods.UxVector3(0f, facing, 0f);
                await session.NotifyAsync(MethodId.SyncLogicVehicleEnter, UxSerializer.Serialize(
                    new SceneMethods.SyncLogicVehicleEnter
                    {
                        EntityId = entityId,
                        VehicleConfigId = spawn.VehicleId,
                        CreateSourceType = 0,
                        Parts = [],
                        SuitId = 0,
                        LicensePlate = string.Empty,
                        Interactable = false,
                        MoveToken = 0,
                        Position = pos0,
                        EulerAngles = euler0,
                        VehicleSpoonName = null,
                    }), token);
                await session.NotifyAsync(MethodId.SyncSpawnVehicle, UxSerializer.Serialize(
                    new SceneMethods.VehicleClientInfo
                    {
                        ControllerPid = 0,
                        CreateSourceType = 0,
                        EntityId = entityId,
                        VehicleConfigId = spawn.VehicleId,
                        Parts = [],
                        SuitId = 0,
                        Position = pos0,
                        Facing = facing,
                        EulerAngles = euler0,
                        Velocity = speed,
                        IsStatic = false,
                        DeformStatus = 0,
                        SeatInfos = [],
                        SpoonId = 0,
                        IsDynamicGo = false,
                        VehicleEnemyId = 0,
                        DisableNavigation = false,
                        Interactable = false,
                        MoveToken = 0,
                        LicensePlate = string.Empty,
                    }), token);
            }

            
            await session.NotifyAsync(MethodId.SyncAetherAIVehicleAddData, UxSerializer.Serialize(
                new SceneMethods.SyncAetherAIVehicleAddData4229938
                {
                    data = new SceneMethods.ClientVehicleInitData
                    {
                        VehicleConfigId = spawn.VehicleId,
                        VehicleColorId = colorId,
                        VehicleLightState = 0,
                        LaneHandle = lane.LaneId,
                        DistanceAlongLane = d,
                        NextVehicleId = 0,
                        Timestamp = stamp,
                        ControlType = (byte)aether.VehicleControlType,   
                        Speed = speed,
                        DustRatio = 0f,
                        Parts = [],
                        SuitId = 0,
                        RandomFraction = randomFraction,
                        Id = entityId,
                        Position = new RpcTypes.Client4229938.Auto.UXVector3 { X = px, Y = py, Z = pz },
                        Facing = facing,
                        EulerAngles = new RpcTypes.Client4229938.Auto.UXVector3 { X = 0f, Y = facing, Z = 0f },
                    },
                }), token);

            
            await session.NotifyAsync(MethodId.SyncAetherAIChangeVehicleControl,
                UxSerializer.Serialize(new SceneMethods.SyncAetherAIChangeVehicleControlType4229938
                {
                    vehicleId = entityId,
                    vehicleControlType = aether.VehicleControlType,
                }), token);

            if (aether.ForceGo)
            {
                await session.NotifyAsync(MethodId.SyncAetherAIVehicleForceGo,
                    UxSerializer.Serialize(new SceneMethods.SyncAetherAIVehicleForceGo4229938
                    {
                        instanceId = entityId,
                        forceGo = true,
                    }), token);
            }

            
            
            
            
            
            
            if (IsAiTaskDriveMode(aether))
            {
                var waypoints = BuildCruiseWaypoints(lane, d, Math.Clamp(aether.AiTaskWaypointCount, 2, 24));
                if (waypoints.Count > 0)
                {
                    var parameters = BuildCruiseParameters(waypoints, speed, aether, rng);
                    await session.NotifyAsync(MethodId.SyncAssignVehicleAITask, UxSerializer.Serialize(
                        new SceneMethods.SyncAssignVehicleAITask4229938
                        {
                            vehicleUId = entityId,
                            parameters = parameters,
                        }), token);

                    
                    
                    
                    await session.NotifyAsync(MethodId.SyncChangeVehicleAITaskState, UxSerializer.Serialize(
                        new SceneMethods.SyncChangeVehicleAITaskState4229938
                        {
                            vehicleUID = entityId,
                            taskToken = parameters.Token,
                            status = (byte)SceneMethods.VehicleAIStatus4229938.Running,
                        }), token);
                }
            }

            
            
            
            
            
            var driverFormwork = PickDriverFormwork(spawn.DriverNpcType, aether, rng);
            
            
            
            
            var driverNpcId = (ulong)(AetherVehicleNpcIdBase + seq);
            if (driverFormwork != 0)
            {
                await session.NotifyAsync(MethodId.SyncAetherAIVehicleNpcAdd, UxSerializer.Serialize(
                    new SceneMethods.SyncAetherAIVehicleNpcAdd4229938
                    {
                        initData = new SceneMethods.ClientVehicleNpcInitData4229938
                        {
                            Id = driverNpcId,
                            NpcFormworkId = driverFormwork,
                            BindVehicleId = entityId,
                            SeatIndex = 0,
                        },
                    }), token);

                
                
                
                
                var driverTask = ResolveBehaviorTaskId(
                    aether.VehicleNpcBehaviorTaskId, BehaviorTaskCatalog.VehicleNpcTaskId);
                if (driverTask != 0)
                {
                    await session.NotifyAsync(MethodId.SyncDoAetherAgentBehaviorTaskDef,
                        UxSerializer.Serialize(new SceneMethods.SyncDoAetherAgentBehaviorTaskDefine4229938
                        {
                            agentEntityId = driverNpcId,
                            taskId = NextBehaviorTaskInstanceId(session),
                            behaviorTaskId = driverTask,
                        }), token);
                }
            }

            lock (session.Items)
            {
                states.Add(new AmbientVehicleState
                {
                    EntityId = entityId,
                    ConfigId = spawn.VehicleId,
                    ColorId = colorId,
                    LaneId = lane.LaneId,
                    Distance = d,
                    
                    
                    AnchorDistance = d,
                    AnchorTime = stamp,
                    Speed = speed,
                    BaseSpeed = speed,
                    RandomFraction = randomFraction,
                    NextCursor = (int)(randomFraction * 7),
                    X = px,
                    Z = pz,
                    DriverPersonaId = spawn.DriverNpcType,
                    
                    DriverFormworkId = driverFormwork,
                    
                    DriverNpcId = driverFormwork != 0 ? driverNpcId : 0UL,
                    SpawnedAt = stamp,
                });
            }

            spawned++;
            if (aether.PacketGapMs > 0)
                await Task.Delay(aether.PacketGapMs, token);
        }

        
        
        
        
        
        
        if (PrivateServerConfigStore.Current.Gameplay.SpiritContent.MarkVehiclesHackable)
        {
            List<ulong> ambientIds;
            lock (session.Items)
            {
                ambientIds = session.Items.TryGetValue(AmbientVehiclesKey, out var rawV)
                    && rawV is List<AmbientVehicleState> allV
                        ? allV.Select(v => v.EntityId).Where(x => x != 0).Distinct().ToList()
                        : [];
            }

            foreach (var id in ambientIds)
                await MarkHackableAsync(session, id, token, rememberAsLastVehicle: false);

            session.Log.Info($"[AETHER] 氛围车已标可骇入 × {ambientIds.Count}（SyncUnitHackableState）");
        }

        session.Log.Info(
            $"[AETHER] 已生成 {spawned} 台氛围车（玩家 ({originX:F0},{originZ:F0}) 半径 {radius:F0}m，"
            + $"环境车配置 {spawns.Count} 种，"
            + $"司机模板池 {aether.VehicleNpcFormworkIds.Length} 个（AgentConfig，非 persona），"
            + $"baseVehicle={aether.CreateBaseVehicle}）；位置由 {aether.LaneTickMs}ms 仿真循环下发");
        return spawned;
    }

    

    
    
    
    
    
    
    
    
    
    
    internal static async Task<int> TickAmbientVehiclesAsync(
        TcpSession session, long tick, CancellationToken token, float? realDt = null)
    {
        var aether = PrivateServerConfigStore.Current.Gameplay.Aether;
        _ = realDt;   

        
        
        var now = LaneDataTimeStamp();

        List<AmbientVehicleState> vehicles;
        lock (session.Items)
        {
            if (session.Items.TryGetValue(AmbientVehiclesKey, out var raw) && raw is List<AmbientVehicleState> l)
                vehicles = l;
            else
                return 0;
        }

        var batch = new List<SceneMethods.ClientVehicleLaneData4229938>(vehicles.Count);
        
        List<AmbientVehicleState>? removed = null;

        
        
        
        var signals = IsLaneDataDriveMode(aether) ? SignalsOf(session) : null;
        var minGap = Math.Max(2f, aether.VehicleMinGapMeters);
        var stopOffset = Math.Max(0f, aether.IntersectionStopOffsetMeters);
        
        
        var follow = aether.VehicleFollowEnabled;
        var signalStop = aether.VehicleSignalStopEnabled;

        lock (session.Items)
        {
            
            for (var i = vehicles.Count - 1; i >= 0; i--)
            {
                var v = vehicles[i];
                var lane = TrafficLaneTable.TryGet(v.LaneId);
                if (lane is null)
                {
                    vehicles.RemoveAt(i);
                    (removed ??= []).Add(v);
                    continue;
                }

                
                if (v.AnchorTime <= 0.0)
                {
                    v.AnchorDistance = v.Distance;
                    v.AnchorTime = now;
                }

                
                
                var elapsed = now - v.AnchorTime;
                if (elapsed < 0.0)
                    elapsed = 0.0;                              
                v.Distance = v.AnchorDistance + v.Speed * (float)elapsed;

                
                var hops = 0;
                while (v.Distance >= lane.Length && hops++ < 8)
                {
                    var nextIds = lane.NextLaneIds;
                    if (nextIds.Length == 0)
                        break;                                  

                    var pick = nextIds[(int)((uint)v.NextCursor % (uint)nextIds.Length)];

                    
                    
                    
                    if (signalStop && !IsLaneOpen(signals, pick))
                        break;

                    v.NextCursor++;
                    v.Distance -= Math.Max(lane.Length, 0.5f);
                    var next = TrafficLaneTable.TryGet(pick);
                    if (next is null)
                        break;
                    v.LaneId = next.LaneId;
                    lane = next;
                    v.BaseSpeed = SpeedFor(lane, v.RandomFraction, aether);
                    v.Speed = v.BaseSpeed;
                    
                    v.AnchorDistance = v.Distance;
                    v.AnchorTime = now;
                }

                
                if (v.Distance >= lane.Length)
                {
                    var blockedBySignal = signalStop && lane.NextLaneIds.Length > 0;
                    if (blockedBySignal)
                    {
                        var hold = Math.Max(0f, lane.Length - stopOffset);
                        v.Distance = Math.Min(v.Distance, hold);
                        v.AnchorDistance = v.Distance;
                        v.AnchorTime = now;
                        v.Speed = 0f;
                    }
                    else
                    {
                        vehicles.RemoveAt(i);
                        (removed ??= []).Add(v);
                        continue;
                    }
                }
            }

            
            if (follow || signalStop)
            {
                var byLane = new Dictionary<int, List<AmbientVehicleState>>(vehicles.Count);
                foreach (var v in vehicles)
                {
                    if (!byLane.TryGetValue(v.LaneId, out var l))
                        byLane[v.LaneId] = l = [];
                    l.Add(v);
                }
                foreach (var l in byLane.Values)
                    l.Sort(static (a, b) => a.Distance.CompareTo(b.Distance));

                foreach (var v in vehicles)
                {
                    var lane = TrafficLaneTable.TryGet(v.LaneId);
                    if (lane is null)
                        continue;

                    var allowed = float.MaxValue;

                    
                    if (follow)
                    {
                        var list = byLane[v.LaneId];
                        var idx = list.IndexOf(v);
                        if (idx >= 0 && idx + 1 < list.Count)
                            allowed = Math.Min(allowed, list[idx + 1].Distance - minGap);
                    }

                    
                    var nextIds = lane.NextLaneIds;
                    if (signalStop)
                    {
                        var mustStop = false;
                        for (var k = 0; k < nextIds.Length; k++)
                        {
                            if (IsLaneOpen(signals, nextIds[k]))
                                continue;
                            mustStop = true;
                            break;
                        }
                        if (mustStop)
                            allowed = Math.Min(allowed, lane.Length - stopOffset);
                    }

                    
                    if (follow && nextIds.Length > 0)
                    {
                        var pick = nextIds[(int)((uint)v.NextCursor % (uint)nextIds.Length)];
                        if (byLane.TryGetValue(pick, out var ahead) && ahead.Count > 0)
                        {
                            var first = ahead[0];               
                            if (first.Distance < minGap)
                                allowed = Math.Min(allowed, lane.Length - (minGap - first.Distance));
                        }
                    }

                    if (allowed == float.MaxValue)
                        continue;

                    
                    if (v.Distance > allowed)
                    {
                        v.Distance = Math.Max(0f, allowed);
                        v.AnchorDistance = v.Distance;
                        v.AnchorTime = now;
                    }

                    
                    var gap = allowed - v.Distance;
                    float speed;
                    if (gap <= 0.05f)
                        speed = 0f;
                    else
                    {
                        var brakeDist = v.BaseSpeed * v.BaseSpeed / (2f * BrakeDecel);
                        speed = gap < brakeDist ? MathF.Sqrt(2f * BrakeDecel * gap) : v.BaseSpeed;
                    }
                    if (MathF.Abs(speed - v.Speed) > 0.05f)
                    {
                        v.AnchorDistance = v.Distance;
                        v.AnchorTime = now;
                        v.Speed = speed;
                    }
                }
            }

            
            foreach (var v in vehicles)
            {
                var lane = TrafficLaneTable.TryGet(v.LaneId);
                if (lane is null)
                    continue;
                var (px, _, pz, _) = lane.AtDistance(v.Distance);
                v.X = px;
                v.Z = pz;

                batch.Add(new SceneMethods.ClientVehicleLaneData4229938
                {
                    Id = v.EntityId,
                    LaneHandle = v.LaneId,
                    DistanceAlongLane = v.Distance,
                    
                    
                    
                    
                    Status = 0,
                });
            }
        }

        
        if (removed is not null)
        {
            foreach (var v in removed)
                await RemoveAmbientVehicleAsync(session, v, token);
            session.Log.Info($"[AETHER] 仿真中回收 {removed.Count} 台（车道失效 / 开到死胡同），待补充");
        }

        if (batch.Count == 0)
            return 0;

        
        
        
        
        if (batch.Count > 0 && IsLaneDataDriveMode(aether))
        {
            await session.NotifyAsync(MethodId.SyncAetherAIVehicleLaneDatas, UxSerializer.Serialize(
                new SceneMethods.SyncAetherAIVehicleLaneDatas4229938
                {
                    data = batch,
                    laneChangeData = [],
                    
                    timestamp = now,
                }), token);
        }

        
        
        
        
        
        
        
        
        
        
        
        
        var reAddEvery = aether.ReAddVehicleDataEveryTicks;
        var reAddWindow = aether.ReAddVehicleDataSeconds;
        if (reAddEvery > 0 && tick % reAddEvery == 0)
        {
            List<AmbientVehicleState> live;
            lock (session.Items)
                live = [.. vehicles];

            foreach (var v in live)
            {
                
                if (reAddWindow > 0 && now - v.SpawnedAt > reAddWindow)
                    continue;

                var lane = TrafficLaneTable.TryGet(v.LaneId);
                if (lane is null)
                    continue;
                var (px, py, pz, facing) = lane.AtDistance(v.Distance);

                
                
                await session.NotifyAsync(MethodId.SyncAetherAIVehicleAddData, UxSerializer.Serialize(
                    new SceneMethods.SyncAetherAIVehicleAddData4229938
                    {
                        data = new SceneMethods.ClientVehicleInitData
                        {
                            VehicleConfigId = v.ConfigId,
                            VehicleColorId = v.ColorId,
                            VehicleLightState = 0,
                            LaneHandle = v.LaneId,
                            DistanceAlongLane = v.Distance,
                            NextVehicleId = 0,
                            Timestamp = now,
                            ControlType = (byte)aether.VehicleControlType,
                            Speed = v.Speed,
                            DustRatio = 0f,
                            Parts = [],
                            SuitId = 0,
                            RandomFraction = v.RandomFraction,
                            Id = v.EntityId,
                            Position = new RpcTypes.Client4229938.Auto.UXVector3 { X = px, Y = py, Z = pz },
                            Facing = facing,
                            EulerAngles = new RpcTypes.Client4229938.Auto.UXVector3 { X = 0f, Y = facing, Z = 0f },
                        },
                    }), token);

                
                
                
                
                
                
                
                
                if (aether.CreateBaseVehicle && v.DriverNpcId != 0
                    && v.DriverReAddCount < aether.VehicleNpcReAddCount)
                {
                    v.DriverReAddCount++;
                    await session.NotifyAsync(MethodId.SyncAetherAIVehicleNpcAdd, UxSerializer.Serialize(
                        new SceneMethods.SyncAetherAIVehicleNpcAdd4229938
                        {
                            initData = new SceneMethods.ClientVehicleNpcInitData4229938
                            {
                                Id = v.DriverNpcId,
                                NpcFormworkId = v.DriverFormworkId,
                                BindVehicleId = v.EntityId,
                                SeatIndex = 0,
                            },
                        }), token);
                }
            }
        }

        return batch.Count;
    }

    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private static uint PickCrowdFormwork(uint personaId, AetherSettings aether, Random rng)
    {
        if (aether.NpcAgentConfigIds.Length > 0)
            return aether.NpcAgentConfigIds[rng.Next(aether.NpcAgentConfigIds.Length)];

        var persona = PersonaCatalog.Find(personaId);
        var pick = AgentCatalogRepository.PickForPersona(persona, rng);
        return pick?.Id ?? 0;
    }

    
    
    
    
    
    
    
    private static uint PickDriverFormwork(uint driverPersonaId, AetherSettings aether, Random rng)
    {
        if (aether.VehicleNpcFormworkIds.Length > 0)
            return aether.VehicleNpcFormworkIds[rng.Next(aether.VehicleNpcFormworkIds.Length)];

        
        
        
        
        var persona = PersonaCatalog.Find(driverPersonaId);
        var pick = AgentCatalogRepository.PickForPersona(persona, rng);
        return pick?.Id ?? 0;
    }

    
    
    
    
    internal static async Task<int> PushAetherCrowdAsync(
        TcpSession session,
        float originX, float originY, float originZ,
        int crowdCount,
        CancellationToken token = default)
    {
        var aether = PrivateServerConfigStore.Current.Gameplay.Aether;
        var radius = Math.Max(40f, aether.CrowdRadiusMeters);

        List<CrowdState> alive;
        lock (session.Items)
        {
            if (!session.Items.TryGetValue(CrowdKey, out var raw) || raw is not List<CrowdState> l)
            {
                l = [];
                session.Items[CrowdKey] = l;
            }
            alive = l;
        }

        
        
        
        
        
        int aliveCount;
        lock (session.Items)
            aliveCount = alive.Count;
        var wantTotal = Math.Clamp(aether.CrowdCount, 0, 256);
        var count = Math.Clamp(crowdCount, 0, 256);
        count = Math.Min(count, Math.Max(0, wantTotal - aliveCount));
        if (count == 0)
            return 0;

        HashSet<long> occupied;
        lock (session.Items)
            occupied = [.. alive.Select(static c => c.SlotKey)];

        
        
        
        var points = PedSpawnTable.NearSpread(originX, originZ, radius, count,
            p => !occupied.Contains(PedSpawnTable.SlotKey(p)),
            maxPerArea: Math.Max(1, aether.CrowdMaxPerWaitArea));
        if (points.Count == 0)
        {
            if (ShouldWarn(session, "Ananta.aether.warn.noped"))
                session.Log.Warn(
                    $"[AETHER] 玩家 ({originX:F0},{originZ:F0}) 半径 {radius:F0}m 内没有空闲行人站位"
                    + $"（表共 {PedSpawnTable.Count} 个，已占用 {occupied.Count} 个）"
                    + "—— 人群不生成（同一条只每 30s 报一次）");
            return 0;
        }

        var rng = new Random(unchecked((int)(DateTime.UtcNow.Ticks & 0x7FFFFFFF)));
        var spawned = 0;
        foreach (var p in points)
        {
            if (token.IsCancellationRequested)
                break;

            var id = (ulong)(AetherCrowdIdBase + _crowdSeq++);
            
            
            var persona = UrbanDiversityCatalog.PickPersona(p.UrbanDiversityConfigId, rng)
                          ?? aether.NpcPersonaIds[spawned % aether.NpcPersonaIds.Length];
            var formwork = PickCrowdFormwork(persona, aether, rng);
            if (formwork == 0)
            {
                
                
                continue;
            }
            var facing = p.FacingDeg;

            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if (aether.CrowdUseStaticNpcChannel)
            {
                NpcCatalog4229938.TryGet(formwork, out var npcEntry);
                await session.NotifyAsync(MethodId.SyncAetherAIStaticNpcAddData,
                    UxSerializer.Serialize(new SceneMethods.SyncAetherAIStaticNpcAddData4229938
                    {
                        data = new SceneMethods.ClientStaticNpcInitData4229938
                        {
                            StaticNpcInfoId = id,
                            NpcFormworkId = formwork,
                            AgentPersonaId = persona,
                            SPoiActionId = 0,
                            CPoiActionId = 0,
                            UrbanDiversityId = p.UrbanDiversityConfigId,
                            IgnoreAllStim = false,
                            TaskRelated = false,
                            
                            
                            
                            EnableHack = HackTargetsEnabled,
                            NpcPid = (int)formwork,
                            
                            AgentSyncClientInfo = new SceneMethods.AgentSyncClientInfo4229938
                            {
                                SpoonAgentId = (int)formwork,
                                
                                
                                
                                treeName = aether.CrowdBehaviorTreeName,
                                petPerformData = "",
                                spawnEffectId = [],
                                stimIDList = [],
                                indoorList = [],
                                roomIds = [],
                                LeaveDistance = 10000,
                                approachDistance = 10000,
                                FashionSuitId = aether.CrowdFashionSuitId,
                                actionId = 0,
                                actionGroupId = npcEntry?.ActionGroupId ?? 0,
                                initPoiActionId = 0,
                                useDefaultPoiOnReturn = false,
                                returnPoiActionIds = [],
                                AgentDataSetsActivityCfgId = 0,
                                beHitType = 1,
                                agentStimType = 0,
                                forbidStimulateType = 0,
                                isAttackInSafeMode = true,
                                CanBeExaminedByPolice = true,
                                InteractId = npcEntry?.InteractSettingId ?? 0,
                                AISetting = npcEntry?.AiSettingId ?? 0,
                            },
                            LookAtDecisionRulesId = 0,
                            ForceGo = true,
                            SourceType = 1,          
                            Id = id,
                            Position = new RpcTypes.Client4229938.Auto.UXVector3 { X = p.X, Y = p.Y, Z = p.Z },
                            Facing = facing,
                            EulerAngles = new RpcTypes.Client4229938.Auto.UXVector3 { X = 0f, Y = facing, Z = 0f },
                        },
                    }), token);

                
                await session.NotifyAsync(MethodId.SyncManagedLogicAgent,
                    UxSerializer.Serialize(WorldCodec.ManagedLogicAgent(id, Profile.PlayerPid, 0)), token);

                
                
                
                
                
                
                await session.NotifyAsync(MethodId.SyncChangeNpcMoveDesiredSpeed,
                    UxSerializer.Serialize(new SceneMethods.SyncChangeNpcMoveDesiredSpeed4229938
                    {
                        entityId = id,
                        desiredSpeed = (float)(aether.CrowdDesiredSpeedMin
                            + rng.NextDouble() * (aether.CrowdDesiredSpeedMax - aether.CrowdDesiredSpeedMin)),
                    }), token);

                
                
                
                
                
                
                
                
                
                if (aether.CrowdWanderEnabled)
                {
                    await session.NotifyAsync(MethodId.SyncMoveWandering,
                        BuildWanderBody(id,
                            aether.CrowdWanderMinDis, aether.CrowdWanderMaxDis,
                            aether.CrowdWanderMaxTime, aether.CrowdWanderOnceTime,
                            aether), token);
                }

                lock (session.Items)
                    alive.Add(new CrowdState
                    {
                        Id = id, SlotKey = PedSpawnTable.SlotKey(p), X = p.X, Z = p.Z,
                        StaticChannel = true,
                        LastWanderMs = aether.CrowdWanderEnabled ? Environment.TickCount64 : 0,
                    });

                spawned++;
                if (aether.PacketGapMs > 0)
                    await Task.Delay(aether.PacketGapMs, token);
                continue;
            }

            await session.NotifyAsync(MethodId.SyncAetherAICrowdAdd, UxSerializer.Serialize(
                new SceneMethods.SyncAetherAICrowdAdd4229938
                {
                    crowd = new SceneMethods.ClientCrowdInitData4229938
                    {
                        NpcFormworkId = formwork,
                        AgentPersonaId = persona,
                        UrbanDiversityConfigId = p.UrbanDiversityConfigId,
                        DesiredSpeed = (float)(1.1 + rng.NextDouble() * 0.6),
                        ActionId = 0,
                        
                        
                        TargetLocationReason = 1,
                        FashionSuitId = 0,
                        Id = id,
                        Position = new RpcTypes.Client4229938.Auto.UXVector3 { X = p.X, Y = p.Y, Z = p.Z },
                        Facing = facing,
                        EulerAngles = new RpcTypes.Client4229938.Auto.UXVector3 { X = 0f, Y = facing, Z = 0f },
                    },
                }), token);

            
            await session.NotifyAsync(MethodId.IGameSceneToClient_SyncAgentForceGo,
                UxSerializer.Serialize(new SceneMethods.SyncAgentForceGo4229938 { id = id, isForceGo = true }),
                token);

            
            
            
            
            
            
            
            
            
            
            
            var crowdTask = ResolveBehaviorTaskId(
                aether.CrowdBehaviorTaskId, BehaviorTaskCatalog.CrowdTaskId);
            if (crowdTask != 0)
            {
                await session.NotifyAsync(MethodId.SyncDoAetherAgentBehaviorTaskDef,
                    UxSerializer.Serialize(new SceneMethods.SyncDoAetherAgentBehaviorTaskDefine4229938
                    {
                        agentEntityId = id,
                        taskId = NextBehaviorTaskInstanceId(session),
                        behaviorTaskId = crowdTask,
                    }), token);
            }

            lock (session.Items)
                alive.Add(new CrowdState { Id = id, SlotKey = PedSpawnTable.SlotKey(p), X = p.X, Z = p.Z });

            spawned++;
            if (aether.PacketGapMs > 0)
                await Task.Delay(aether.PacketGapMs, token);
        }

        session.Log.Info(
            $"[AETHER] 已生成 {spawned} 个人群 NPC（玩家 ({originX:F0},{originZ:F0}) "
            + $"半径 {radius:F0}m，站位表 {PedSpawnTable.Count} 个，TargetLocationReason=Wander）");
        return spawned;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    internal static async Task<int> PushFixedStaticNpcsAsync(
        TcpSession session,
        float originX, float originY, float originZ,
        int count,
        CancellationToken token = default)
    {
        var aether = PrivateServerConfigStore.Current.Gameplay.Aether;
        if (!aether.FixedNpcEnabled)
            return 0;

        var radius = Math.Max(40f, aether.FixedNpcRadiusMeters);

        List<CrowdState> alive;
        lock (session.Items)
        {
            if (!session.Items.TryGetValue(FixedNpcKey, out var raw) || raw is not List<CrowdState> l)
            {
                l = [];
                session.Items[FixedNpcKey] = l;
            }
            alive = l;
        }

        int aliveCount;
        lock (session.Items)
            aliveCount = alive.Count;
        var wantTotal = Math.Clamp(aether.FixedNpcCount, 0, 512);
        var need = Math.Clamp(count, 0, 512);
        need = Math.Min(need, Math.Max(0, wantTotal - aliveCount));
        if (need == 0)
            return 0;

        HashSet<long> occupied;
        lock (session.Items)
            occupied = [.. alive.Select(static c => c.SlotKey)];

        
        var points = StaticNpcSpawnTable.Near(originX, originZ, radius, need,
            p => !occupied.Contains(StaticNpcSpawnTable.SlotKey(p)));
        if (points.Count == 0)
        {
            if (ShouldWarn(session, "Ananta.aether.warn.nofixed"))
                session.Log.Warn(
                    $"[AETHER] 玩家 ({originX:F0},{originZ:F0}) 半径 {radius:F0}m 内没有空闲固定站位"
                    + $"（表共 {StaticNpcSpawnTable.Count} 个，已占用 {occupied.Count} 个）"
                    + "—— 固定 NPC 不生成（同一条只每 30s 报一次）");
            MarkFixedNpcTopUpFailed(session);
            return 0;
        }

        var rng = new Random(unchecked((int)(DateTime.UtcNow.Ticks & 0x7FFFFFFF)));
        var spawned = 0;
        foreach (var p in points)
        {
            if (token.IsCancellationRequested)
                break;

            var id = (ulong)(AetherFixedNpcIdBase + _fixedNpcSeq++);
            
            
            var persona = UrbanDiversityCatalog.PickPersona(p.UrbanDiversityConfigId, rng)
                          ?? aether.NpcPersonaIds[spawned % aether.NpcPersonaIds.Length];
            var formwork = PickCrowdFormwork(persona, aether, rng);
            if (formwork == 0)
                continue;
            var facing = p.FacingDeg;

            NpcCatalog4229938.TryGet(formwork, out var npcEntry);
            await session.NotifyAsync(MethodId.SyncAetherAIStaticNpcAddData,
                UxSerializer.Serialize(new SceneMethods.SyncAetherAIStaticNpcAddData4229938
                {
                    data = new SceneMethods.ClientStaticNpcInitData4229938
                    {
                        StaticNpcInfoId = id,
                        NpcFormworkId = formwork,
                        AgentPersonaId = persona,
                        SPoiActionId = 0,
                        CPoiActionId = 0,
                        UrbanDiversityId = p.UrbanDiversityConfigId,
                        IgnoreAllStim = false,
                        TaskRelated = false,
                        EnableHack = HackTargetsEnabled,
                        NpcPid = (int)formwork,
                        AgentSyncClientInfo = new SceneMethods.AgentSyncClientInfo4229938
                        {
                            SpoonAgentId = (int)formwork,
                            
                            treeName = aether.FixedNpcBehaviorTreeName,
                            petPerformData = "",
                            spawnEffectId = [],
                            stimIDList = [],
                            indoorList = [],
                            roomIds = [],
                            LeaveDistance = 10000,
                            approachDistance = 10000,
                            FashionSuitId = aether.FixedNpcFashionSuitId,
                            actionId = 0,
                            actionGroupId = npcEntry?.ActionGroupId ?? 0,
                            initPoiActionId = 0,
                            useDefaultPoiOnReturn = false,
                            returnPoiActionIds = [],
                            AgentDataSetsActivityCfgId = 0,
                            beHitType = 1,
                            agentStimType = 0,
                            forbidStimulateType = 0,
                            isAttackInSafeMode = true,
                            CanBeExaminedByPolice = true,
                            InteractId = npcEntry?.InteractSettingId ?? 0,
                            AISetting = npcEntry?.AiSettingId ?? 0,
                        },
                        LookAtDecisionRulesId = 0,
                        ForceGo = true,
                        SourceType = (byte)Math.Clamp(aether.FixedNpcSourceType, 0, 255),
                        Id = id,
                        Position = new RpcTypes.Client4229938.Auto.UXVector3 { X = p.X, Y = p.Y, Z = p.Z },
                        Facing = facing,
                        EulerAngles = new RpcTypes.Client4229938.Auto.UXVector3 { X = 0f, Y = facing, Z = 0f },
                    },
                }), token);

            
            await session.NotifyAsync(MethodId.SyncManagedLogicAgent,
                UxSerializer.Serialize(WorldCodec.ManagedLogicAgent(id, Profile.PlayerPid, 0)), token);

            
            if (aether.FixedNpcDesiredSpeed > 0f)
            {
                await session.NotifyAsync(MethodId.SyncChangeNpcMoveDesiredSpeed,
                    UxSerializer.Serialize(new SceneMethods.SyncChangeNpcMoveDesiredSpeed4229938
                    {
                        entityId = id,
                        desiredSpeed = aether.FixedNpcDesiredSpeed,
                    }), token);
            }

            
            
            
            
            
            
            
            
            
            
            var wanderSent = false;
            if (aether.FixedNpcWander)
            {
                await session.NotifyAsync(MethodId.SyncMoveWandering,
                    BuildWanderBody(id,
                        aether.FixedNpcWanderMinDis, aether.FixedNpcWanderMaxDis,
                        aether.FixedNpcWanderMaxTime, aether.FixedNpcWanderOnceTime,
                        aether), token);
                wanderSent = true;
            }

            lock (session.Items)
                alive.Add(new CrowdState
                {
                    Id = id, SlotKey = StaticNpcSpawnTable.SlotKey(p), X = p.X, Z = p.Z,
                    StaticChannel = true,
                    LastWanderMs = wanderSent ? Environment.TickCount64 : 0,
                });

            spawned++;
            if (aether.PacketGapMs > 0)
                await Task.Delay(aether.PacketGapMs, token);
        }

        if (spawned > 0)
            ClearFixedNpcTopUpBackoff(session);

        session.Log.Info(
            $"[AETHER] 已生成 {spawned} 个固定 NPC（玩家 ({originX:F0},{originZ:F0}) "
            + $"半径 {radius:F0}m，固定站位表 {StaticNpcSpawnTable.Count} 个，"
            + $"SourceType={aether.FixedNpcSourceType}，树={aether.FixedNpcBehaviorTreeName}，"
            + $"速度={aether.FixedNpcDesiredSpeed:F1}，"
            + $"游荡={(aether.FixedNpcWander ? $"0..{aether.FixedNpcWanderMaxDis:F0}m" : "关")}）");
        return spawned;
    }

    

    
    
    
    
    internal static async Task MaintainAmbientAsync(
        TcpSession session, float playerX, float playerZ, CancellationToken token)
    {
        var aether = PrivateServerConfigStore.Current.Gameplay.Aether;

        
        
        
        
        var vehLeash = aether.VehicleLeashMeters > 0f
            ? aether.VehicleLeashMeters
            : Math.Max(300f, aether.VehicleSpawnRadiusMeters * 2.5f);
        var vehLeashSq = vehLeash * vehLeash;
        List<AmbientVehicleState> vehicles;
        lock (session.Items)
        {
            if (session.Items.TryGetValue(AmbientVehiclesKey, out var raw) && raw is List<AmbientVehicleState> l)
                vehicles = l;
            else
                vehicles = [];
        }

        var removedVehs = new List<AmbientVehicleState>();
        lock (session.Items)
        {
            for (var i = vehicles.Count - 1; i >= 0; i--)
            {
                var v = vehicles[i];
                if ((v.X - playerX) * (v.X - playerX) + (v.Z - playerZ) * (v.Z - playerZ) <= vehLeashSq)
                    continue;
                vehicles.RemoveAt(i);
                removedVehs.Add(v);
            }
        }
        foreach (var v in removedVehs)
            await RemoveAmbientVehicleAsync(session, v, token);
        var removedVeh = removedVehs.Count;

        var wantVeh = Math.Clamp(PrivateServerConfigStore.Current.Gameplay.Vehicles.AetherVehicleCount, 0, 64);
        if (wantVeh > vehicles.Count)
        {
            
            var need = Math.Min(wantVeh - vehicles.Count, 4);
            await PushAetherVehiclesAsync(session, PrivateServerConfigStore.Current.World.RaidId,
                playerX, 0f, playerZ, 0f, need, token, createEntities: false);
        }

        
        var crowdLeash = Math.Max(200f, aether.CrowdRadiusMeters * 2f);
        var crowdLeashSq = crowdLeash * crowdLeash;
        List<CrowdState> crowd;
        lock (session.Items)
        {
            if (session.Items.TryGetValue(CrowdKey, out var raw2) && raw2 is List<CrowdState> l2)
                crowd = l2;
            else
                crowd = [];
        }

        var removedCrowdIds = new List<(ulong Id, bool StaticChannel)>();
        lock (session.Items)
        {
            for (var i = crowd.Count - 1; i >= 0; i--)
            {
                var c = crowd[i];
                if ((c.X - playerX) * (c.X - playerX) + (c.Z - playerZ) * (c.Z - playerZ) <= crowdLeashSq)
                    continue;
                crowd.RemoveAt(i);
                removedCrowdIds.Add((c.Id, c.StaticChannel));
            }
        }
        foreach (var (id, staticChannel) in removedCrowdIds)
        {
            
            
            if (staticChannel)
                await session.NotifyAsync(MethodId.SyncLogicAgentLeave,
                    UxSerializer.Serialize(WorldCodec.LogicAgentLeave(id)), token);
            else
                await session.NotifyAsync(MethodId.SyncAetherAINpcRemove,
                    UxSerializer.Serialize(new SceneMethods.SyncAetherAINpcRemove4229938 { pid = id }), token);
        }
        var removedCrowd = removedCrowdIds.Count;

        var wantCrowd = Math.Clamp(aether.CrowdCount, 0, 256);
        if (wantCrowd > crowd.Count)
        {
            var need = Math.Min(wantCrowd - crowd.Count, 8);
            await PushAetherCrowdAsync(session, playerX, 0f, playerZ, need, token);
        }

        
        
        
        if (aether.CrowdWanderEnabled)
            await ReWanderAsync(session, crowd, aether.CrowdReWanderSeconds,
                aether.CrowdWanderMinDis, aether.CrowdWanderMaxDis,
                aether.CrowdWanderMaxTime, aether.CrowdWanderOnceTime, aether, token);

        
        
        
        var removedFixed = 0;
        if (aether.FixedNpcEnabled)
        {
            
            
            
            var fixedLeash = aether.FixedNpcLeashMeters > 0f
                ? aether.FixedNpcLeashMeters
                : Math.Max(300f, aether.FixedNpcRadiusMeters * 1.4f);
            var fixedLeashSq = fixedLeash * fixedLeash;
            List<CrowdState> fixedNpcs;
            lock (session.Items)
            {
                if (session.Items.TryGetValue(FixedNpcKey, out var raw3) && raw3 is List<CrowdState> l3)
                    fixedNpcs = l3;
                else
                    fixedNpcs = [];
            }

            var removedFixedIds = new List<ulong>();
            lock (session.Items)
            {
                for (var i = fixedNpcs.Count - 1; i >= 0; i--)
                {
                    var f = fixedNpcs[i];
                    if ((f.X - playerX) * (f.X - playerX) + (f.Z - playerZ) * (f.Z - playerZ) <= fixedLeashSq)
                        continue;
                    fixedNpcs.RemoveAt(i);
                    removedFixedIds.Add(f.Id);
                }
            }
            foreach (var id in removedFixedIds)
                await session.NotifyAsync(MethodId.SyncLogicAgentLeave,
                    UxSerializer.Serialize(WorldCodec.LogicAgentLeave(id)), token);
            removedFixed = removedFixedIds.Count;

            var wantFixed = Math.Clamp(aether.FixedNpcCount, 0, 512);
            if (wantFixed > fixedNpcs.Count && FixedNpcTopUpAllowed(session))
            {
                var need = Math.Min(wantFixed - fixedNpcs.Count, 8);
                await PushFixedStaticNpcsAsync(session, playerX, 0f, playerZ, need, token);
            }

            
            if (aether.FixedNpcWander)
                await ReWanderAsync(session, fixedNpcs, aether.FixedNpcReWanderSeconds,
                    aether.FixedNpcWanderMinDis, aether.FixedNpcWanderMaxDis,
                    aether.FixedNpcWanderMaxTime, aether.FixedNpcWanderOnceTime, aether, token);
        }

        if (removedVeh > 0 || removedCrowd > 0 || removedFixed > 0)
            session.Log.Info(
                $"[AETHER] 回收跑远的：车 {removedVeh} 台、人流 {removedCrowd} 个、固定NPC {removedFixed} 个，"
                + $"并在玩家 ({playerX:F0},{playerZ:F0}) 附近补充");
    }

    

    
    
    
    
    
    internal static (int Count, float MinX, float MaxX, float MinZ, float MaxZ, int Areas, int ZeroArea,
                     float Radius, int MedianWithin, int MinWithin)
        ProbeStaticNpcTable()
    {
        var pts = StaticNpcSpawnTable.Points;
        if (pts.Count == 0)
            return (0, 0f, 0f, 0f, 0f, 0, 0, 0f, 0, 0);

        float minX = float.MaxValue, maxX = float.MinValue, minZ = float.MaxValue, maxZ = float.MinValue;
        var areas = new HashSet<uint>();
        var zero = 0;
        foreach (var p in pts)
        {
            if (p.X < minX) minX = p.X;
            if (p.X > maxX) maxX = p.X;
            if (p.Z < minZ) minZ = p.Z;
            if (p.Z > maxZ) maxZ = p.Z;
            if (p.UrbanDiversityConfigId == 0) zero++;
            else areas.Add(p.UrbanDiversityConfigId);
        }

        
        
        var radius = Math.Max(1f, PrivateServerConfigStore.Current.Gameplay.Aether.FixedNpcRadiusMeters);
        var r2 = radius * radius;
        var cell = radius;
        var grid = new Dictionary<(int, int), List<StaticNpcSpawnPoint>>();
        foreach (var p in pts)
        {
            var key = ((int)(p.X / cell), (int)(p.Z / cell));
            if (!grid.TryGetValue(key, out var list))
                grid[key] = list = [];
            list.Add(p);
        }

        var counts = new List<int>(pts.Count);
        foreach (var p in pts)
        {
            var cx = (int)(p.X / cell);
            var cz = (int)(p.Z / cell);
            var n = 0;
            for (var gx = cx - 1; gx <= cx + 1; gx++)
            {
                for (var gz = cz - 1; gz <= cz + 1; gz++)
                {
                    if (!grid.TryGetValue((gx, gz), out var list))
                        continue;
                    foreach (var q in list)
                    {
                        var dx = q.X - p.X;
                        var dz = q.Z - p.Z;
                        if (dx * dx + dz * dz <= r2)
                            n++;
                    }
                }
            }
            counts.Add(n);
        }
        counts.Sort();
        return (pts.Count, minX, maxX, minZ, maxZ, areas.Count, zero,
            radius, counts[counts.Count / 2], counts[0]);
    }

    
    internal static (int Crowd, int StaticNpc) ProbeCrowdBytes()
    {
        var c = UxSerializer.Serialize(new SceneMethods.SyncAetherAICrowdAdd4229938
        {
            crowd = new SceneMethods.ClientCrowdInitData4229938
            {
                NpcFormworkId = 40100000, AgentPersonaId = 45200003,
                UrbanDiversityConfigId = 88888000, DesiredSpeed = 1.4f,
                ActionId = 0, TargetLocationReason = 1, FashionSuitId = 0,
                Id = 800000000000UL,
                Position = new RpcTypes.Client4229938.Auto.UXVector3 { X = 1f, Y = 2f, Z = 3f },
                Facing = 0f,
                EulerAngles = new RpcTypes.Client4229938.Auto.UXVector3 { X = 0f, Y = 0f, Z = 0f },
            },
        });
        var n = UxSerializer.Serialize(new SceneMethods.SyncAetherAIStaticNpcAddData4229938
        {
            data = new SceneMethods.ClientStaticNpcInitData4229938
            {
                StaticNpcInfoId = 900000000000UL, NpcFormworkId = 40100000,
                AgentPersonaId = 45200003, SPoiActionId = 0, CPoiActionId = 0,
                UrbanDiversityId = 88888000, IgnoreAllStim = false, TaskRelated = false,
                EnableHack = HackTargetsEnabled, NpcPid = 0,
                
                
                AgentSyncClientInfo = new SceneMethods.AgentSyncClientInfo4229938
                {
                    SpoonAgentId = 40100000, treeName = "PedBase", petPerformData = "",
                    spawnEffectId = [], stimIDList = [], indoorList = [], roomIds = [],
                    LeaveDistance = 10000, approachDistance = 10000,
                    FashionSuitId = 11190001, actionId = 0, actionGroupId = 35,
                    initPoiActionId = 0, useDefaultPoiOnReturn = false, returnPoiActionIds = [],
                    AgentDataSetsActivityCfgId = 0, beHitType = 1, agentStimType = 0,
                    forbidStimulateType = 0, isAttackInSafeMode = true, CanBeExaminedByPolice = true,
                    InteractId = 0, AISetting = 0,
                },
                LookAtDecisionRulesId = 0,
                ForceGo = false, SourceType = 0,
                Id = 900000000000UL,
                Position = new RpcTypes.Client4229938.Auto.UXVector3 { X = 1f, Y = 2f, Z = 3f },
                Facing = 0f,
                EulerAngles = new RpcTypes.Client4229938.Auto.UXVector3 { X = 0f, Y = 0f, Z = 0f },
            },
        });
        return (c.Length, n.Length);
    }

    
    internal static (int VehicleForceGo, int AgentForceGo, int ChangeControlType) ProbeForceGoBytes()
    {
        var v = UxSerializer.Serialize(new SceneMethods.SyncAetherAIVehicleForceGo4229938
        {
            instanceId = 700000000001UL, forceGo = true,
        });
        var a = UxSerializer.Serialize(new SceneMethods.SyncAgentForceGo4229938
        {
            id = 800000000001UL, isForceGo = true,
        });
        var c = UxSerializer.Serialize(new SceneMethods.SyncAetherAIChangeVehicleControlType4229938
        {
            vehicleId = 700000000001UL, vehicleControlType = 1,
        });
        return (v.Length, a.Length, c.Length);
    }

    
    internal static (int Bytes, string Hex) ProbeVehicleBytes()
    {
        var v = new SceneMethods.ClientVehicleInitData
        {
            VehicleConfigId = 81001001,
            VehicleColorId = 9994349,
            VehicleLightState = 0,
            LaneHandle = 1,
            DistanceAlongLane = 10f,
            NextVehicleId = 0,
            Timestamp = 1.0,
            ControlType = 1,
            Speed = 8f,
            DustRatio = 0f,
            Parts = [],
            SuitId = 0,
            RandomFraction = 0.5f,
            Id = 700000000001UL,
            Position = new RpcTypes.Client4229938.Auto.UXVector3 { X = 1f, Y = 2f, Z = 3f },
            Facing = 90f,
            EulerAngles = new RpcTypes.Client4229938.Auto.UXVector3 { X = 0f, Y = 90f, Z = 0f },
        };
        var body = UxSerializer.Serialize(new SceneMethods.SyncAetherAIVehicleAddData4229938 { data = v });
        return (body.Length, Convert.ToHexString(body));
    }

    
    
    
    
    
    
    
    internal static (int OneVehicle, int TwoVehicles, int Empty) ProbeLaneDataBytes()
    {
        static SceneMethods.SyncAetherAIVehicleLaneDatas4229938 Make(int n)
        {
            var data = new List<SceneMethods.ClientVehicleLaneData4229938>(n);
            for (var i = 0; i < n; i++)
            {
                data.Add(new SceneMethods.ClientVehicleLaneData4229938
                {
                    Id = 700000000000UL + (ulong)i,
                    LaneHandle = 100 + i,
                    DistanceAlongLane = 12.5f + i,
                    Status = 0,
                });
            }
            return new SceneMethods.SyncAetherAIVehicleLaneDatas4229938
            {
                data = data,
                laneChangeData = [],
                timestamp = 1700000000.5,
            };
        }

        return (UxSerializer.Serialize(Make(1)).Length,
                UxSerializer.Serialize(Make(2)).Length,
                UxSerializer.Serialize(Make(0)).Length);
    }

    
    internal static (int Bytes, int Intersections, string Hex) ProbeAetherInitBytes()
    {
        var body = BuildAetherInit(23300888u);
        var head = Convert.ToHexString(body.AsSpan(0, Math.Min(24, body.Length)));
        return (body.Length, IntersectionTable.Count, head + (body.Length > 24 ? "..." : ""));
    }

    
    internal static (int Lanes, int Zones, float TotalKm, int Drivable, int DeadEnds) ProbeLaneTable()
    {
        var lanes = TrafficLaneTable.Lanes;
        var zones = new HashSet<int>();
        var total = 0f;
        var drivable = 0;
        foreach (var l in lanes)
        {
            zones.Add(l.ZoneIndex);
            total += l.Length;
            if (l.HasNext)
                drivable++;
        }
        return (lanes.Count, zones.Count, total / 1000f, drivable, lanes.Count - drivable);
    }

    
    
    
    
    
    
    
    internal static (int Starts, int TotalHops, float MinMeters, float MaxMeters, int Stuck, string Sample)
        ProbeLaneDrive()
    {
        var cfg = PrivateServerConfigStore.Current.World;
        var aether = PrivateServerConfigStore.Current.Gameplay.Aether;

        
        
        var entry = Protocol.Client4229938.Profile.WorldSpawn;
        var seeds = TrafficLaneTable.Near(entry.X, entry.Z, 400f, 12);
        if (seeds.Count == 0)
            return (0, 0, 0, 0, 0, "(出生点 400m 内没有可生成车道)");

        var totalHops = 0;
        var stuck = 0;
        var minMeters = float.MaxValue;
        var maxMeters = 0f;
        string sample = string.Empty;

        foreach (var seed in seeds)
        {
            var lane = seed;
            var distance = lane.Length * 0.2f;
            var speed = SpeedFor(lane, 0.5f, aether);
            var meters = 0f;
            var hops = 0;
            var path = new System.Text.StringBuilder($"lane {lane.LaneId}");
            var hitDeadEnd = false;

            for (var step = 0; step < 600; step++)      
            {
                distance += speed * 0.05f;
                meters += speed * 0.05f;
                while (distance >= lane.Length)
                {
                    if (lane.NextLaneIds.Length == 0)
                    {
                        hitDeadEnd = true;
                        break;
                    }
                    distance -= lane.Length;
                    var next = TrafficLaneTable.TryGet(lane.NextLaneIds[hops % lane.NextLaneIds.Length]);
                    if (next is null)
                    {
                        hitDeadEnd = true;
                        break;
                    }
                    lane = next;
                    speed = SpeedFor(lane, 0.5f, aether);
                    hops++;
                    if (hops <= 10)
                        path.Append(" → ").Append(lane.LaneId);
                    else if (hops == 11)
                        path.Append(" → …");
                }
                if (hitDeadEnd)
                    break;
            }

            if (hitDeadEnd)
                stuck++;
            totalHops += hops;
            minMeters = Math.Min(minMeters, meters);
            if (meters > maxMeters)
            {
                maxMeters = meters;
                sample = path.ToString();
            }
        }

        return (seeds.Count, totalHops, minMeters == float.MaxValue ? 0f : minMeters, maxMeters, stuck, sample);
    }

    
    internal static (int Points, int ConfigIds, int Unassigned) ProbePedTable()
    {
        var pts = PedSpawnTable.Points;
        var ids = new HashSet<uint>();
        var none = 0;
        foreach (var p in pts)
        {
            if (p.UrbanDiversityConfigId == 0) none++;
            else ids.Add(p.UrbanDiversityConfigId);
        }
        return (pts.Count, ids.Count, none);
    }

    
    internal static (int Ambient, int WithDriver, int WithColor) ProbeVehicleSpawnTable()
    {
        var list = VehicleSpawnCatalog.Ambient;
        return (list.Count, list.Count(v => v.DriverNpcType != 0), list.Count(v => v.ColorMods.Length > 0));
    }

    
    
    private static bool IsAiTaskDriveMode(AetherSettings aether)
    {
        var m = aether.VehicleDriveMode?.Trim().ToLowerInvariant();
        
        return m is "aitask" or "both";
    }

    
    private static bool IsLaneDataDriveMode(AetherSettings aether)
    {
        var m = aether.VehicleDriveMode?.Trim().ToLowerInvariant();
        return m is "lanedata" or "both" or null;
    }

    
    private static readonly uint[] DefaultVehicleAiConfigIds = [16, 20, 21, 22, 23, 24, 26, 27, 28, 29, 30];

    private static uint _aiTaskTokenSeq;

    
    
    
    
    private static List<RpcTypes.Client4229938.Auto.UXVector3> BuildCruiseWaypoints(
        TrafficLane lane, float distance, int hops)
    {
        var pts = new List<RpcTypes.Client4229938.Auto.UXVector3>(hops);
        var cur = lane;

        
        for (var i = 0; i < hops; i++)
        {
            pts.Add(new RpcTypes.Client4229938.Auto.UXVector3
            {
                X = cur.EndX,
                Y = cur.EndY,
                Z = cur.EndZ,
            });

            if (cur.NextLaneIds.Length == 0)
                break;
            var next = TrafficLaneTable.TryGet(cur.NextLaneIds[0]);
            if (next is null)
                break;
            cur = next;
        }

        _ = distance;
        return pts;
    }

    
    
    
    
    private static SceneMethods.CruiseAITaskParameters4229938 BuildCruiseParameters(
        List<RpcTypes.Client4229938.Auto.UXVector3> waypoints, float speed, AetherSettings aether, Random rng)
    {
        var pool = aether.VehicleAiConfigIds.Length > 0 ? aether.VehicleAiConfigIds : DefaultVehicleAiConfigIds;
        var cfgId = pool[rng.Next(pool.Length)];

        return new SceneMethods.CruiseAITaskParameters4229938
        {
            TargetPointList = waypoints,
            CruiseType = (byte)SceneMethods.E_TaskVehicleCruiseType4229938.GoToTargetInOrderLoop,
            Count = 0,                     
            configFlags = (byte)(SceneMethods.TaskVehicleCruiseConfigFlags4229938.SlowDownWhenArriveTarget
                                 | SceneMethods.TaskVehicleCruiseConfigFlags4229938.DynamicSpeed),
            pathFindFlags = (byte)SceneMethods.TaskVehiclePathFindFlags4229938.None,
            TargetType = (byte)SceneMethods.E_AITargetType4229938.None,
            TargetUid = 0,
            checkClose = false,
            checkFar = false,
            closeRange = 0f,
            farawayRange = 0f,
            accelerateScale = 1f,
            decelerateScale = 1f,
            minSpeed = MathF.Max(1f, speed * 0.5f),
            maxSpeed = MathF.Max(2f, speed * 1.3f),
            ArrivalDistance = 6f,
            AdaptSpeedToTargetDistance = true,

            Token = (ulong)Interlocked.Increment(ref _aiTaskTokenSeq),
            taskAIConfigId = cfgId,
            defaultSpeed = speed,
            drivingFlags = (int)(SceneMethods.VehicleTaskDrivingFlags4229938.DFStopForCars
                                 | SceneMethods.VehicleTaskDrivingFlags4229938.DFStopForPeds
                                 | SceneMethods.VehicleTaskDrivingFlags4229938.DFStopAtLights
                                 | SceneMethods.VehicleTaskDrivingFlags4229938.DFSteerAroundObjects),
            initSpeed = speed,
            initTaskAIBuffList = [],
            commonParameters = new SceneMethods.VehicleAICommonParameters4229938
            {
                FollowPathCheckArrivePointDistance = 4f,
                TurnSlowSpeedTemplateId = 0,
                TurnMinAheadSpeed = 3f,
                TurnMinAheadDistance = 6f,
                TurnMaxAheadSpeed = 12f,
                TurnMaxAheadDistance = 20f,
                AheadDistanceNormalRatio = 1f,
                DummySpeedRatio = 1f,
                StuckCheckConfig = new SceneMethods.VehicleStuckCheckConfig4229938
                {
                    StuckLevel = (byte)SceneMethods.VehicleStuckLevel4229938.Relaxed,
                    RelaxedStuckCheckTime = 2f,
                    RelaxedStuckCheckCount = 3,
                    ModerateStuckCheckCount = 2,
                    StrictStuckCheckDistance = 6f,
                    CheckGoToNextPointStuckTime = 8f,
                    ResetWhenStuck = false,
                },
                VirtualGroundMoveType = (byte)SceneMethods.VirtualGroundMoveType4229938.ColliderNotLoaded,
            },
        };
    }

    
    internal static byte[] ProbeAiTaskBody()
    {
        var lane = TrafficLaneTable.Lanes.FirstOrDefault(l => l.HasNext) ?? TrafficLaneTable.Lanes[0];
        var wp = BuildCruiseWaypoints(lane, lane.Length * 0.3f, 3);
        var aether = PrivateServerConfigStore.Current.Gameplay.Aether;
        var p = BuildCruiseParameters(wp, 12f, aether, new Random(1));
        return UxSerializer.Serialize(new SceneMethods.SyncAssignVehicleAITask4229938
        {
            vehicleUId = 700000000000UL,
            parameters = p,
        });
    }

    
    
    
    
    
    
    
    
    
    
    internal static async Task<int> PushIntersectionUpdatesAsync(TcpSession session, CancellationToken token)
    {
        var list = IntersectionTable.All;
        if (list.Count == 0)
            return 0;

        var aether = PrivateServerConfigStore.Current.Gameplay.Aether;

        
        
        
        
        
        
        
        
        
        
        
        
        var useZoneIndex = !string.Equals(aether.IntersectionIndexSource?.Trim(),
            "listIndex", StringComparison.OrdinalIgnoreCase);

        var sent = 0;
        for (var i = 0; i < list.Count; i++)
        {
            var it = list[i];
            await session.NotifyAsync(MethodId.SyncAetherAIIntersectionUpdateDa, UxSerializer.Serialize(
                new SceneMethods.SyncAetherAIIntersectionUpdateData4229938
                {
                    data = new SceneMethods.ClientTrafficIntersectionPeriodUpdateInfo4229938
                    {
                        IntersectionIndex = useZoneIndex ? (ulong)it.ZoneIndex : (ulong)i,
                        CurrentState = (byte)SceneMethods.MassTrafficIntersectionState4229938.Start,
                        CurrentPeriodIndex = it.CurrentPeriodIndex,
                        NextPeriodIndex = it.NextPeriodIndex,
                        RailPeriodIndex = it.RailPeriodIndex,
                    },
                }), token);
            sent++;

            
            if (sent % 16 == 0)
                await Task.Delay(8, token);
        }

        session.Log.Info($"[AETHER] 已下发 {sent} 个路口的运行期周期/状态"
            + $"（SyncAetherAIIntersectionUpdateData 68819947，"
            + $"IntersectionIndex 取自 {(useZoneIndex ? "ZoneIndex(==InstanceId)" : "列表下标")}）");
        return sent;
    }

    
    internal static (int Areas, int DistinctPersonas) ProbeUrbanDiversityPool()
        => UrbanDiversityCatalog.ProbePool();

    
    
    
    
    
    
    
    
    
    internal static (int Citizens, int Models, int Sex, int MinAge, int MaxAge,
                     int ConfigPool, int ConfigBad, int PersonaOk, int PersonaTotal, string Detail)
        ProbeNpcFormworks()
    {
        var aether = PrivateServerConfigStore.Current.Gameplay.Aether;

        var (citizens, models, sex, minAge, maxAge) = AgentCatalogRepository.ProbeCitizens();

        static (int Count, int Bad) CheckPool(uint[] pool)
        {
            var bad = 0;
            foreach (var id in pool)
            {
                var e = AgentCatalogRepository.Find(id);
                if (e is null || !e.IsNpc)
                    bad++;
            }
            return (pool.Length, bad);
        }

        var crowdPool = CheckPool(aether.NpcAgentConfigIds);
        var driverPool = CheckPool(aether.VehicleNpcFormworkIds);

        
        if (aether.NpcAgentConfigIds.Length > 0)
        {
            return (citizens, models, sex, minAge, maxAge,
                crowdPool.Count + driverPool.Count, crowdPool.Bad + driverPool.Bad,
                -1, -1,
                $"配置固定池：人群 {crowdPool.Count}(坏 {crowdPool.Bad}) / 司机 {driverPool.Count}(坏 {driverPool.Bad})");
        }

        
        var rng = new Random(12345);
        var ok = 0;
        var total = 0;
        var detail = new System.Text.StringBuilder();
        foreach (var (personaId, pool) in UrbanDiversityCatalog.PersonaPools)
        {
            _ = personaId;
            foreach (var pid in pool.Take(3))
            {
                total++;
                var pe = PersonaCatalog.Find(pid);
                var pick = AgentCatalogRepository.PickCitizen(pe?.SexTypes, pe?.AgeTags, rng);
                if (pick is not null && pick.IsNpc)
                {
                    ok++;
                    if (detail.Length < 180)
                        detail.Append($"{pe?.Name ?? pid.ToString()}→{pick.Id}({pick.SexType}/{pick.Age}) ");
                }
            }
        }

        return (citizens, models, sex, minAge, maxAge,
            crowdPool.Count + driverPool.Count, crowdPool.Bad + driverPool.Bad,
            ok, total,
            detail.Length == 0 ? "（人格池为空）" : detail.ToString().TrimEnd());
    }
}
