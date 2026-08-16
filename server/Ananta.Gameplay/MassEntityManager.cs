using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using System;
using System.Collections.Generic;
using System.Linq;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// Mass Entity Manager — server-side crowd/traffic orchestration.
    ///
    /// Mirrors the client's MassAI ECS system at a high level:
    /// - Dynamic crowd density management (SyncSetCrowdDensity)
    /// - Crowd zone management (SyncCrowdClearZone, SyncCrowdDangerZone, SyncCrowdSurroundZone)
    /// - Traffic intersection control (SyncAetherAIIntersectionUpdateDa)
    /// - Traffic lane data (SyncAetherAIVehicleLaneDatas)
    /// - Dynamic crowd add/remove (SyncAetherAICrowdAdd, SyncAetherAINpcRemove)
    /// - Crowd specification refresh (SyncCrowdSpecifiedDensityRefresh)
    ///
    /// The server acts as the authoritative director: it decides crowd density,
    /// danger zones, and traffic patterns. The client's MassAI handles the
    /// detailed locomotion, animation, and rendering.
    /// </summary>
    public static class MassEntityManager
    {
        // ======================== CROWD DENSITY ========================

        /// <summary>
        /// Density configuration for a crowd zone.
        /// Mirrors client's crowd density parameters.
        /// </summary>
        public class CrowdDensityConfig
        {
            public uint ZoneId;
            public float Density;          // 0.0 (empty) to 1.0 (max density)
            public UXVector3 Center;
            public float Radius;
            public bool IsActive = true;
        }

        /// <summary>
        /// Danger zone — area where NPCs should flee or avoid.
        /// Sent via SyncCrowdDangerZone.
        /// </summary>
        public class DangerZone
        {
            public uint ZoneId;
            public UXVector3 Center;
            public float Radius;
            public float Duration;         // seconds the zone persists
            public long CreatedAt;         // TickCount64
        }

        /// <summary>
        /// Clear zone — area where crowd NPCs should be removed.
        /// Sent via SyncCrowdClearZone.
        /// </summary>
        public class ClearZone
        {
            public uint ZoneId;
            public UXVector3 Center;
            public float Radius;
        }

        /// <summary>
        /// Surround zone — area around the player for crowd proximity.
        /// Sent via SyncCrowdSurroundZone.
        /// </summary>
        public class SurroundZone
        {
            public UXVector3 Center;
            public float InnerRadius;
            public float OuterRadius;
            public float Density;
        }

        // ======================== TRAFFIC ========================

        /// <summary>
        /// Traffic intersection state.
        /// Mirrors client's AetherAI intersection management.
        /// </summary>
        public class IntersectionState
        {
            public uint IntersectionId;
            public UXVector3 Position;
            public float Radius;
            public int CurrentPhase;        // 0=green NS, 1=green EW, 2=all-red
            public float PhaseDuration;     // seconds per phase
            public long LastPhaseChange;    // TickCount64
            public bool IsActive = true;
            public List<ulong> WaitingVehicleIds = new();
            public List<ulong> WaitingNpcIds = new();
        }

        /// <summary>
        /// Traffic lane definition.
        /// Mirrors client's vehicle lane data.
        /// </summary>
        public class TrafficLane
        {
            public uint LaneId;
            public List<UXVector3> Waypoints;
            public float SpeedLimit;       // m/s
            public uint Direction;         // 0=forward, 1=reverse
            public bool IsActive = true;
        }

        // ======================== PER-CONNECTION STATE ========================

        // Crowd density zones per connection
        static readonly Dictionary<ulong, List<CrowdDensityConfig>> _connDensityZones = new();
        // Danger zones per connection
        static readonly Dictionary<ulong, List<DangerZone>> _connDangerZones = new();
        // Clear zones per connection
        static readonly Dictionary<ulong, List<ClearZone>> _connClearZones = new();
        // Surround zones per connection
        static readonly Dictionary<ulong, SurroundZone> _connSurroundZones = new();
        // Intersections per connection
        static readonly Dictionary<ulong, Dictionary<uint, IntersectionState>> _connIntersections = new();
        // Lanes per connection
        static readonly Dictionary<ulong, List<TrafficLane>> _connLanes = new();
        // Dynamic crowd NPCs (added mid-session) per connection
        static readonly Dictionary<ulong, List<ulong>> _connDynamicCrowdIds = new();
        // Track last surround zone sync per connection
        static readonly Dictionary<ulong, long> _connLastSurroundSync = new();

        // Constants
        const int SurroundZoneSyncIntervalMs = 10000;  // update surround zone every 10s
        const int DangerZoneTimeoutMs = 30000;          // danger zones expire after 30s
        const float DefaultSurroundInnerRadius = 30f;
        const float DefaultSurroundOuterRadius = 80f;
        const float DefaultSurroundDensity = 0.6f;
        const int MaxDynamicCrowdNpcs = 20;            // max dynamically spawned crowd per conn
        const uint DynamicCrowdFormworkBase = 40968601u;

        // ======================== PUBLIC API — CROWD DENSITY ========================

        /// <summary>
        /// Set crowd density for a zone. Sends SyncSetCrowdDensity to client.
        /// </summary>
        public static void SetCrowdDensity(Connection conn, uint zoneId, float density,
            UXVector3 center, float radius)
        {
            var zones = GetOrCreateDensityZones(conn.Pid);
            var existing = zones.FirstOrDefault(z => z.ZoneId == zoneId);
            if (existing != null)
            {
                existing.Density = density;
                existing.Center = center;
                existing.Radius = radius;
            }
            else
            {
                zones.Add(new CrowdDensityConfig
                {
                    ZoneId = zoneId,
                    Density = density,
                    Center = center,
                    Radius = radius,
                });
            }

            SendNotify(conn, MethodId.SyncSetCrowdDensity, new SyncSetCrowdDensityArgs
            {
                zoneId = zoneId,
                density = density,
                center = center,
                radius = radius,
            });
        }

        /// <summary>
        /// Refresh crowd density for a specific zone.
        /// </summary>
        public static void RefreshCrowdDensity(Connection conn, uint zoneId)
        {
            SendNotify(conn, MethodId.SyncCrowdSpecifiedDensityRefresh, new SyncCrowdSpecifiedDensityRefreshArgs
            {
                zoneId = zoneId,
            });
        }

        // ======================== PUBLIC API — ZONES ========================

        /// <summary>
        /// Create a danger zone — NPCs will flee from this area.
        /// Sent via SyncCrowdDangerZone.
        /// </summary>
        public static void AddDangerZone(Connection conn, uint zoneId, UXVector3 center,
            float radius, float duration = 30f)
        {
            var zones = GetOrCreateDangerZones(conn.Pid);
            zones.RemoveAll(z => z.ZoneId == zoneId);
            zones.Add(new DangerZone
            {
                ZoneId = zoneId,
                Center = center,
                Radius = radius,
                Duration = duration,
                CreatedAt = Environment.TickCount64,
            });

            SendNotify(conn, MethodId.SyncCrowdDangerZone, new SyncCrowdDangerZoneArgs
            {
                center = center,
                radius = radius,
            });
        }

        /// <summary>
        /// Create a clear zone — crowd NPCs will be removed from this area.
        /// </summary>
        public static void AddClearZone(Connection conn, uint zoneId, UXVector3 center, float radius)
        {
            var zones = GetOrCreateClearZones(conn.Pid);
            zones.RemoveAll(z => z.ZoneId == zoneId);
            zones.Add(new ClearZone
            {
                ZoneId = zoneId,
                Center = center,
                Radius = radius,
            });

            SendNotify(conn, MethodId.SyncCrowdClearZone, new SyncCrowdClearZoneArgs
            {
                center = center,
                radius = radius,
            });
        }

        /// <summary>
        /// Remove a clear zone.
        /// </summary>
        public static void RemoveClearZone(Connection conn, uint zoneId)
        {
            if (_connClearZones.TryGetValue(conn.Pid, out var zones))
                zones.RemoveAll(z => z.ZoneId == zoneId);
        }

        /// <summary>
        /// Update the surround zone (area around the player for crowd proximity).
        /// Called periodically or when player moves significantly.
        /// </summary>
        public static void UpdateSurroundZone(Connection conn)
        {
            var pos = conn.LastKnownPlayerPosition;
            var zone = new SurroundZone
            {
                Center = pos,
                InnerRadius = DefaultSurroundInnerRadius,
                OuterRadius = DefaultSurroundOuterRadius,
                Density = DefaultSurroundDensity,
            };
            _connSurroundZones[conn.Pid] = zone;

            SendNotify(conn, MethodId.SyncCrowdSurroundZone, new SyncCrowdSurroundZoneArgs
            {
                center = pos,
                innerRadius = zone.InnerRadius,
                outerRadius = zone.OuterRadius,
                density = zone.Density,
            });
        }

        // ======================== PUBLIC API — DYNAMIC CROWD ========================

        /// <summary>
        /// Dynamically add a crowd NPC mid-session.
        /// Sent via SyncAetherAICrowdAdd.
        /// </summary>
        public static ulong AddCrowdNpc(Connection conn, uint formworkId, UXVector3 position,
            float facing, List<ClientZoneGraphPathPoint> path = null, float desiredSpeed = 1.5f)
        {
            ulong npcId = GenerateDynamicCrowdId(conn.Pid);

            var pathPoints = path ?? GenerateSimplePath(position, facing);

            SendNotify(conn, MethodId.SyncAetherAICrowdAdd, new SyncAetherAICrowdAddArgs
            {
                npcId = npcId,
                formworkId = formworkId,
                position = position,
                facing = facing,
                path = pathPoints,
                desiredSpeed = desiredSpeed,
            });

            // Track the dynamic NPC
            var dynamicIds = GetOrCreateDynamicCrowdIds(conn.Pid);
            dynamicIds.Add(npcId);
            if (dynamicIds.Count > MaxDynamicCrowdNpcs)
            {
                ulong oldest = dynamicIds[0];
                dynamicIds.RemoveAt(0);
                RemoveCrowdNpc(conn, oldest);
            }

            return npcId;
        }

        /// <summary>
        /// Remove a crowd NPC. Sent via SyncAetherAINpcRemove.
        /// </summary>
        public static void RemoveCrowdNpc(Connection conn, ulong npcId)
        {
            SendNotify(conn, MethodId.SyncAetherAINpcRemove, new SyncAetherAINpcRemoveArgs
            {
                npcId = npcId,
            });

            if (_connDynamicCrowdIds.TryGetValue(conn.Pid, out var ids))
                ids.Remove(npcId);
        }

        /// <summary>
        /// Remove all dynamic crowd NPCs for a connection.
        /// </summary>
        public static void RemoveAllDynamicCrowd(Connection conn)
        {
            if (_connDynamicCrowdIds.TryGetValue(conn.Pid, out var ids))
            {
                foreach (var id in ids.ToList())
                    RemoveCrowdNpc(conn, id);
                ids.Clear();
            }
        }

        // ======================== PUBLIC API — INTERSECTIONS ========================

        /// <summary>
        /// Register a traffic intersection.
        /// </summary>
        public static void RegisterIntersection(Connection conn, uint intersectionId,
            UXVector3 position, float radius, float phaseDuration = 15f)
        {
            var intersections = GetOrCreateIntersections(conn.Pid);
            intersections[intersectionId] = new IntersectionState
            {
                IntersectionId = intersectionId,
                Position = position,
                Radius = radius,
                PhaseDuration = phaseDuration,
                LastPhaseChange = Environment.TickCount64,
            };
        }

        /// <summary>
        /// Force a specific intersection phase. Sends update to client.
        /// </summary>
        public static void SetIntersectionPhase(Connection conn, uint intersectionId, int phase)
        {
            if (!_connIntersections.TryGetValue(conn.Pid, out var intersections)) return;
            if (!intersections.TryGetValue(intersectionId, out var state)) return;

            state.CurrentPhase = phase;
            state.LastPhaseChange = Environment.TickCount64;

            SendIntersectionUpdate(conn, state);
        }

        // ======================== PUBLIC API — LANES ========================

        /// <summary>
        /// Register a traffic lane.
        /// </summary>
        public static void RegisterLane(Connection conn, TrafficLane lane)
        {
            var lanes = GetOrCreateLanes(conn.Pid);
            lanes.RemoveAll(l => l.LaneId == lane.LaneId);
            lanes.Add(lane);
        }

        /// <summary>
        /// Send all registered lane data to the client.
        /// </summary>
        public static void PushLaneData(Connection conn)
        {
            if (!_connLanes.TryGetValue(conn.Pid, out var lanes)) return;
            if (lanes.Count == 0) return;

            var laneDataList = lanes.Where(l => l.IsActive).Select(l => new VehicleLaneData
            {
                laneId = l.LaneId,
                waypoints = l.Waypoints,
                speedLimit = l.SpeedLimit,
                direction = l.Direction,
            }).ToList();

            SendNotify(conn, MethodId.SyncAetherAIVehicleLaneDatas, new SyncAetherAIVehicleLaneDatasArgs
            {
                lanes = laneDataList,
            });
        }

        // ======================== TICK (called by GameTickService) ========================

        public static void Tick(Connection conn)
        {
            long now = Environment.TickCount64;

            // 1. Expire old danger zones
            ExpireDangerZones(conn, now);

            // 2. Update intersection phases (limit to 4 per tick)
            UpdateIntersectionPhases(conn, now);

            // 3. Update surround zone periodically (follows player)
            if (!_connLastSurroundSync.TryGetValue(conn.Pid, out var lastSync) ||
                now - lastSync > SurroundZoneSyncIntervalMs)
            {
                _connLastSurroundSync[conn.Pid] = now;
                UpdateSurroundZone(conn);
            }
        }

        /// <summary>
        /// Called after scene load to initialize default zones and send initial data.
        /// </summary>
        public static void OnSceneLoad(Connection conn)
        {
            // Set up default surround zone around player
            UpdateSurroundZone(conn);

            // Set up a default density zone around the player spawn area
            var spawnPos = conn.LastKnownPlayerPosition;
            SetCrowdDensity(conn, 1, DefaultSurroundDensity, spawnPos, DefaultSurroundOuterRadius);

            // Register default intersections around spawn
            RegisterDefaultIntersections(conn, spawnPos);

            // Push lane data if any lanes are registered
            PushLaneData(conn);
        }

        /// <summary>
        /// Clean up all state for a connection (on disconnect).
        /// </summary>
        public static void CleanupConnection(Connection conn)
        {
            _connDensityZones.Remove(conn.Pid);
            _connDangerZones.Remove(conn.Pid);
            _connClearZones.Remove(conn.Pid);
            _connSurroundZones.Remove(conn.Pid);
            _connIntersections.Remove(conn.Pid);
            _connLanes.Remove(conn.Pid);
            _connDynamicCrowdIds.Remove(conn.Pid);
            _connLastSurroundSync.Remove(conn.Pid);
        }

        // ======================== INTERNAL ========================

        static void ExpireDangerZones(Connection conn, long now)
        {
            if (!_connDangerZones.TryGetValue(conn.Pid, out var zones)) return;

            var expired = zones.Where(z => now - z.CreatedAt > (long)(z.Duration * 1000)).ToList();
            foreach (var z in expired)
                zones.Remove(z);
        }

        static void UpdateIntersectionPhases(Connection conn, long now)
        {
            if (!_connIntersections.TryGetValue(conn.Pid, out var intersections)) return;

            foreach (var state in intersections.Values)
            {
                if (!state.IsActive) continue;

                long elapsed = now - state.LastPhaseChange;
                if (elapsed > (long)(state.PhaseDuration * 1000))
                {
                    // Advance to next phase
                    state.CurrentPhase = (state.CurrentPhase + 1) % 3;
                    state.LastPhaseChange = now;
                    SendIntersectionUpdate(conn, state);
                }
            }
        }

        static void SendIntersectionUpdate(Connection conn, IntersectionState state)
        {
            SendNotify(conn, MethodId.SyncAetherAIIntersectionUpdateDa, new SyncAetherAIIntersectionUpdateArgs
            {
                intersectionId = state.IntersectionId,
                position = state.Position,
                phase = state.CurrentPhase,
                waitingVehicleIds = state.WaitingVehicleIds,
                waitingNpcIds = state.WaitingNpcIds,
            });
        }

        static void RegisterDefaultIntersections(Connection conn, UXVector3 center)
        {
            // Register 4 default intersections in a cross pattern around spawn
            float offset = 60f;
            RegisterIntersection(conn, 1, new UXVector3 { X = center.X + offset, Y = center.Y, Z = center.Z }, 15f);
            RegisterIntersection(conn, 2, new UXVector3 { X = center.X - offset, Y = center.Y, Z = center.Z }, 15f);
            RegisterIntersection(conn, 3, new UXVector3 { X = center.X, Y = center.Y, Z = center.Z + offset }, 15f);
            RegisterIntersection(conn, 4, new UXVector3 { X = center.X, Y = center.Y, Z = center.Z - offset }, 15f);
        }

        static List<ClientZoneGraphPathPoint> GenerateSimplePath(UXVector3 start, float facingDeg)
        {
            var path = new List<ClientZoneGraphPathPoint>();
            float facingRad = facingDeg * MathF.PI / 180f;
            float stepDist = 15f;

            for (int i = 0; i < 5; i++)
            {
                float dist = stepDist * (i + 1);
                path.Add(new ClientZoneGraphPathPoint
                {
                    Position = new UXVector3
                    {
                        X = start.X + MathF.Sin(facingRad) * dist,
                        Y = start.Y,
                        Z = start.Z + MathF.Cos(facingRad) * dist,
                    },
                    Facing = (byte)(facingDeg * 255f / 360f),
                });
            }
            return path;
        }

        static ulong _dynamicIdCounter = 5000000000000ul;
        static ulong GenerateDynamicCrowdId(ulong pid)
        {
            return System.Threading.Interlocked.Increment(ref _dynamicIdCounter);
        }

        // ======================== GET-OR-CREATE HELPERS ========================

        static List<CrowdDensityConfig> GetOrCreateDensityZones(ulong pid)
        {
            if (!_connDensityZones.TryGetValue(pid, out var zones))
            {
                zones = new List<CrowdDensityConfig>();
                _connDensityZones[pid] = zones;
            }
            return zones;
        }

        static List<DangerZone> GetOrCreateDangerZones(ulong pid)
        {
            if (!_connDangerZones.TryGetValue(pid, out var zones))
            {
                zones = new List<DangerZone>();
                _connDangerZones[pid] = zones;
            }
            return zones;
        }

        static List<ClearZone> GetOrCreateClearZones(ulong pid)
        {
            if (!_connClearZones.TryGetValue(pid, out var zones))
            {
                zones = new List<ClearZone>();
                _connClearZones[pid] = zones;
            }
            return zones;
        }

        static Dictionary<uint, IntersectionState> GetOrCreateIntersections(ulong pid)
        {
            if (!_connIntersections.TryGetValue(pid, out var dict))
            {
                dict = new Dictionary<uint, IntersectionState>();
                _connIntersections[pid] = dict;
            }
            return dict;
        }

        static List<TrafficLane> GetOrCreateLanes(ulong pid)
        {
            if (!_connLanes.TryGetValue(pid, out var lanes))
            {
                lanes = new List<TrafficLane>();
                _connLanes[pid] = lanes;
            }
            return lanes;
        }

        static List<ulong> GetOrCreateDynamicCrowdIds(ulong pid)
        {
            if (!_connDynamicCrowdIds.TryGetValue(pid, out var ids))
            {
                ids = new List<ulong>();
                _connDynamicCrowdIds[pid] = ids;
            }
            return ids;
        }

        // ======================== SYNC HELPERS ========================

        static void SendNotify(Connection conn, MethodId methodId, SerializedClass args)
        {
            var msg = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)methodId,
            };
            msg.SetArgs(methodId, args);
            conn.SendPacket(msg);
        }
    }

    // ======================== SYNC DATA TYPES ========================

    // SyncSetCrowdDensity — adjust crowd density in a zone
    public class SyncSetCrowdDensityArgs : SerializedClass
    {
        public uint zoneId;
        public float density;
        public UXVector3 center;
        public float radius;

        public SyncSetCrowdDensityArgs() { onlyFields = true; }
    }

    // SyncCrowdSpecifiedDensityRefresh — refresh density for a specific zone
    public class SyncCrowdSpecifiedDensityRefreshArgs : SerializedClass
    {
        public uint zoneId;

        public SyncCrowdSpecifiedDensityRefreshArgs() { onlyFields = true; }
    }

    // SyncCrowdDangerZone — define a danger area NPCs should flee from
    public class SyncCrowdDangerZoneArgs : SerializedClass
    {
        public UXVector3 center;
        public float radius;

        public SyncCrowdDangerZoneArgs() { onlyFields = true; }
    }

    // SyncCrowdClearZone — clear crowd from an area
    public class SyncCrowdClearZoneArgs : SerializedClass
    {
        public UXVector3 center;
        public float radius;

        public SyncCrowdClearZoneArgs() { onlyFields = true; }
    }

    // SyncCrowdSurroundZone — define the crowd proximity zone around player
    public class SyncCrowdSurroundZoneArgs : SerializedClass
    {
        public UXVector3 center;
        public float innerRadius;
        public float outerRadius;
        public float density;

        public SyncCrowdSurroundZoneArgs() { onlyFields = true; }
    }

    // SyncAetherAICrowdAdd — dynamically add a crowd NPC
    public class SyncAetherAICrowdAddArgs : SerializedClass
    {
        public ulong npcId;
        public uint formworkId;
        public UXVector3 position;
        public float facing;
        public List<ClientZoneGraphPathPoint> path;
        public float desiredSpeed;

        public SyncAetherAICrowdAddArgs() { onlyFields = true; }
    }

    // SyncAetherAINpcRemove — remove an NPC
    public class SyncAetherAINpcRemoveArgs : SerializedClass
    {
        public ulong npcId;

        public SyncAetherAINpcRemoveArgs() { onlyFields = true; }
    }

    // SyncAetherAIIntersectionUpdateDa — intersection phase update
    public class SyncAetherAIIntersectionUpdateArgs : SerializedClass
    {
        public uint intersectionId;
        public UXVector3 position;
        public int phase;
        public List<ulong> waitingVehicleIds;
        public List<ulong> waitingNpcIds;

        public SyncAetherAIIntersectionUpdateArgs() { onlyFields = true; }
    }

    // SyncAetherAIVehicleLaneDatas — traffic lane definitions
    public class SyncAetherAIVehicleLaneDatasArgs : SerializedClass
    {
        public List<VehicleLaneData> lanes;

        public SyncAetherAIVehicleLaneDatasArgs() { onlyFields = true; }
    }

    public class VehicleLaneData : SerializedClass
    {
        public uint laneId;
        public List<UXVector3> waypoints;
        public float speedLimit;
        public uint direction;

        public VehicleLaneData() { onlyFields = true; }
    }
}
