using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using Newtonsoft.Json;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Game
{
    // City pedestrian crowd. Loads UrbanDiversity areas + per-area persona filters, spawns weighted
    // civilian agents on sidewalk lanes near the player via SyncAetherAICrowdAdd, drives them with
    // destination-directed follow-paths, and maintains density by AOI (despawn far, top up near).
    // MEMORY-OPTIMIZED VERSION: Reduced limits and disabled logging by default to prevent memory issues.
    public static class UrbanCrowdSpawner
    {
        public static bool Enabled { get; set; } = false;  // Disabled by default to prevent memory issues

        // false = send the AetherAI init only, push none of our own crowd.
        public static bool PushPeds { get; set; } = true;

        // Spawn/despawn AOI radii (world units) + density caps.
        // REDUCED LIMITS for memory optimization:
        public const float SpawnRadius = 200f;
        public const float DespawnRadius = 300f;
        public const int MaxPedsPerArea = 2;  // Reduced from 4
        public const int MaxAreasPerTick = 6;  // Reduced from 8
        public const int MaxLivePeds = 50;     // Reduced from 140
        public const float MinRestreamDist = 8f;   // min player move before re-streaming
        public const uint DefaultPersona = 45200058u;
        public static bool EnableWander = true;
        public static bool EnableClientBrain = true;
        public static bool NoFedPath = false;
        // GoNative=true releases peds to the client agent brain (SendClientControl) instead of the
        // server follow-path; a no-op for crowd peds, so kept false.
        public static bool GoNative = false;

        public static bool Continuous = true;
        private const float SpawnRouteLen = 700f;   // initial directional route length (units)
        private const float RepathLen = 700f;       // re-path leg length (units)
        private const long RepathEveryMs = 15000;   // Increased from 6000ms to reduce CPU/memory pressure
        private sealed class PedWalk { public float ex, ez, hx, hz, destX, destZ, jx, jz; public long spawnMs, jMs; public int asks, area; public long nextMs; }
        private static readonly Dictionary<ulong, PedWalk> s_pedWalks = new();
        private static long NowMs() => DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        private static int s_tickLog = 0;

        // Per-stream route point-count diagnostics.
        private static int s_psMin, s_psMax, s_psN, s_psFallback;
        private static long s_psSum;

        // Logging disabled by default to prevent I/O issues
        private const bool EnableLogging = false;
        private const string CrowdLogPath = @"C:\datamine nd shit\Ananta\_re\crowd_spawn.log";
        private static void CrowdLog(string s)
        {
            if (!EnableLogging) return;
            try { System.IO.File.AppendAllText(CrowdLogPath, $"{DateTime.Now:HH:mm:ss} {s}\n"); } catch { }
        }

        private static readonly Random s_rng = new();
        private static ulong s_nextId = 7_000_000_000_000ul;

        private sealed class Pt { public float x; public float y; public float z; }
        private sealed class Area
        {
            public int Index;      // position in s_areas (CrowdAreas key)
            public uint AreaId;
            public uint ConfigId;
            public List<Pt> Points;
            public float Cx, Cz;   // centroid
            public float Radius;   // centroid->vertex max
        }
        private sealed class NpcFilter { public uint agentPersonaId; public int weight; }
        private sealed class UrbanCfg { public uint Id; public List<NpcFilter> AgentNpcFilter; }

        private static List<Area> s_areas;                       // AreaType 0 (pedestrian)
        private static Dictionary<uint, NpcFilter[]> s_filters;  // ConfigId -> weighted personas
        private static uint[] s_formworks;
        private static Dictionary<uint, uint[]> s_personaAgents; // persona -> civilian agent ids
        private sealed class SpawnData { public Dictionary<string, List<uint>> personaAgents; }

        public static int AreaCount => s_areas?.Count ?? 0;

        public static void Load()
        {
            if (s_areas != null) return;
            s_areas = new List<Area>();
            s_filters = new Dictionary<uint, NpcFilter[]>();
            try
            {
                string dir = Path.Combine(AppContext.BaseDirectory, "data");
                if (!Directory.Exists(dir))
                {
                    Console.WriteLine("[Crowd] data directory not found, skipping UrbanCrowdSpawner load");
                    return;
                }

                string settingsPath = Path.Combine(dir, "UrbanDiversitySettings.json");
                if (!File.Exists(settingsPath))
                {
                    Console.WriteLine("[Crowd] UrbanDiversitySettings.json not found, skipping crowd load");
                    return;
                }

                var settings = JsonConvert.DeserializeObject<SettingsRoot>(File.ReadAllText(settingsPath));
                if (settings?.Infos == null)
                {
                    Console.WriteLine("[Crowd] UrbanDiversitySettings.json is empty or invalid");
                    return;
                }

                foreach (var info in settings.Infos)
                {
                    if (info.AreaType != 0) continue;
                    foreach (var a in info.Areas)
                    {
                        if (a.Points == null || a.Points.Count == 0) continue;
                        float cx = a.Points.Average(p => p.x);
                        float cz = a.Points.Average(p => p.z);
                        float rad = a.Points.Max(p => MathF.Sqrt((p.x - cx) * (p.x - cx) + (p.z - cz) * (p.z - cz)));
                        s_areas.Add(new Area { Index = s_areas.Count, AreaId = a.AreaId, ConfigId = a.ConfigId, Points = a.Points, Cx = cx, Cz = cz, Radius = rad });
                    }
                }

                string configPath = Path.Combine(dir, "UrbanDiversityConfig.json");
                if (File.Exists(configPath))
                {
                    var cfgs = JsonConvert.DeserializeObject<List<UrbanCfg>>(File.ReadAllText(configPath));
                    if (cfgs != null)
                    {
                        foreach (var c in cfgs)
                        {
                            if (c.AgentNpcFilter != null && c.AgentNpcFilter.Count > 0)
                                s_filters[c.Id] = c.AgentNpcFilter.ToArray();
                        }
                    }
                }

                s_formworks = State.NpcStateFactory.BuildAutoSpawnNpcIds();
                if (s_formworks == null || s_formworks.Length == 0)
                    s_formworks = new uint[] { 40968615u, 40968618u, 40968628u, 40968659u };

                s_personaAgents = new Dictionary<uint, uint[]>();
                try
                {
                    string spawnDataPath = Path.Combine(dir, "npc_spawn_data.json");
                    if (File.Exists(spawnDataPath))
                    {
                        var sd = JsonConvert.DeserializeObject<SpawnData>(File.ReadAllText(spawnDataPath));
                        if (sd?.personaAgents != null)
                            foreach (var kv in sd.personaAgents)
                                if (uint.TryParse(kv.Key, out var pid) && kv.Value != null && kv.Value.Count > 0)
                                    s_personaAgents[pid] = kv.Value.ToArray();
                    }
                }
                catch (Exception e) { Console.WriteLine($"[Crowd] npc_spawn_data.json load failed: {e.Message}"); }

                SidewalkLanes.Load();

                Console.WriteLine($"[Crowd] Loaded {s_areas.Count} pedestrian areas, {s_filters.Count} diversity configs, {s_personaAgents.Count} persona->agent pools, {SidewalkLanes.LaneCount} sidewalk lanes.");
                CrowdLog($"=== server start: {s_areas.Count} areas, {SidewalkLanes.LaneCount} lanes ===");
            }
            catch (Exception e)
            {
                Console.WriteLine($"[Crowd] FAILED to load UrbanDiversity data: {e.Message}");
                Console.WriteLine($"[Crowd] Stack trace: {e.StackTrace}");
            }
        }

        private sealed class SettingsRoot { public List<Info> Infos; }
        private sealed class Info { public int AreaType; public List<RawArea> Areas; }
        private sealed class RawArea { public uint AreaId; public uint ConfigId; public int DataType; public List<Pt> Points; }

        public static void OnEnterWorld(Connection conn)
        {
            if (!Enabled) return;
            Load();
            EnsureAetherInit(conn);
            if (!PushPeds) return;
            var p = conn.LastKnownPlayerPosition;
            Stream(conn, p.X, p.Z);
        }

        public static void OnPlayerMoved(Connection conn, float worldX, float worldZ)
        {
            if (!Enabled) return;
            if (!PushPeds) return;
            if (!float.IsNaN(conn.LastCrowdStreamX))
            {
                if (Dist(worldX, worldZ, conn.LastCrowdStreamX, conn.LastCrowdStreamZ) < MinRestreamDist)
                    return;
            }
            Load();
            EnsureAetherInit(conn);
            Stream(conn, worldX, worldZ);
        }

        // One-time AetherAI city init so crowd-adds are accepted.
        private static void EnsureAetherInit(Connection conn)
        {
            if (conn.CrowdAetherInited) return;
            var msg = new UxRpcMessage
            {
                Mode = UxRpcPacketMode.Notify, RpcInvokeId = 0, RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIInitDatas,
            };
            msg.SetArgs(MethodId.SyncAetherAIInitDatas, new AetherAIInitData
            {
                RaidId = 23300888,
                HasZoneGraph = true,
                ZoneStorageDataHandle = 0,
                Intersections = new(),
                Crowds = new(),
                StaticNpcs = new(),
                Vehicles = new(),
                StaticVehicles = new(),
                VehicleNpcs = new(),
                MetroNpcs = new(),
            });
            conn.SendPacket(msg);
            conn.CrowdAetherInited = true;
            Console.WriteLine("[Crowd] AetherAI init sent.");
        }

        // Maintain density around the player: despawn peds estimated past DespawnRadius, top up nearby
        // areas to MaxPedsPerArea up to MaxLivePeds. Called on move and on the tick.
        private static void Stream(Connection conn, float px, float pz)
        {
            if (s_areas == null) return;
            conn.LastCrowdStreamX = px;
            conn.LastCrowdStreamZ = pz;
            long now = NowMs();

            List<ulong> dead = null;
            foreach (var kv in s_pedWalks)
            {
                EstPos(kv.Value, now, out float ex, out float ez);
                if (Dist(px, pz, ex, ez) > DespawnRadius) (dead ??= new()).Add(kv.Key);
            }
            if (dead != null)
            {
                foreach (var id in dead)
                {
                    SendDestroy(conn, id);
                    if (s_pedWalks.TryGetValue(id, out var w) && conn.CrowdAreas.TryGetValue((uint)w.area, out var al)) al.Remove(id);
                    s_pedWalks.Remove(id);
                }
                var empties = conn.CrowdAreas.Where(kv => kv.Value.Count == 0).Select(kv => kv.Key).ToList();
                foreach (var e in empties) conn.CrowdAreas.Remove(e);
            }

            int livePeds = s_pedWalks.Count;
            int spawnedPeds = 0, spawnedAreas = 0;
            s_psMin = int.MaxValue; s_psMax = 0; s_psN = 0; s_psSum = 0; s_psFallback = 0;
            if (livePeds < MaxLivePeds)
            {
                var candidates = new List<(int idx, float d)>();
                for (int i = 0; i < s_areas.Count; i++)
                {
                    float d = Dist(px, pz, s_areas[i].Cx, s_areas[i].Cz);
                    if (d <= SpawnRadius) candidates.Add((i, d));
                }
                candidates.Sort((c1, c2) => c1.d.CompareTo(c2.d));

                foreach (var (idx, _) in candidates)
                {
                    if (spawnedAreas >= MaxAreasPerTick || livePeds >= MaxLivePeds) break;
                    int cur = conn.CrowdAreas.TryGetValue((uint)idx, out var lst0) ? lst0.Count : 0;
                    int want = Math.Min(MaxPedsPerArea - cur, MaxLivePeds - livePeds);
                    if (want <= 0) continue;
                    var ids = SpawnArea(conn, s_areas[idx], want);
                    if (ids.Count > 0)
                    {
                        if (!conn.CrowdAreas.TryGetValue((uint)idx, out var lst)) { lst = new(); conn.CrowdAreas[(uint)idx] = lst; }
                        lst.AddRange(ids);
                        spawnedAreas++; spawnedPeds += ids.Count; livePeds += ids.Count;
                    }
                }
            }

            if (spawnedPeds > 0 || (dead?.Count ?? 0) > 0)
            {
                int avg = s_psN > 0 ? (int)(s_psSum / s_psN) : 0;
                int min = s_psN > 0 ? s_psMin : 0;
                CrowdLog($"+{spawnedPeds}/{spawnedAreas}a -{dead?.Count ?? 0} @({px:0},{pz:0}) live={livePeds} | routePts min={min} avg={avg} max={s_psMax} fallback={s_psFallback}");
            }
        }

        // Estimated position along the straight line start->dest by elapsed time. 0.75 compensates for
        // sidewalk path winding (~1.3x straight line) so far-despawn won't trigger while still in view.
        private static void EstPos(PedWalk w, long now, out float ex, out float ez)
        {
            float dx = w.destX - w.jx, dz = w.destZ - w.jz;
            float jlen = MathF.Sqrt(dx * dx + dz * dz);
            if (jlen < 1f) { ex = w.ex; ez = w.ez; return; }
            float traveled = (now - w.jMs) / 1000f * MovementScheduler.WalkSpeed * 0.75f;
            float t = Math.Clamp(traveled / jlen, 0f, 1f);
            ex = w.jx + dx * t; ez = w.jz + dz * t;
        }

        private static List<ulong> SpawnArea(Connection conn, Area a, int budget)
        {
            var ids = new List<ulong>();
            int count = Math.Min(MaxPedsPerArea, Math.Max(1, a.Points.Count));
            count = Math.Min(count, budget);
            if (count <= 0) return ids;
            s_filters.TryGetValue(a.ConfigId, out var filter);

            // Spawn on real sidewalk lanes near the area; fall back to polygon interior points if none.
            var lanes = SidewalkLanes.LanesNear(a.Cx, a.Cz, a.Radius + 12f);

            for (int i = 0; i < count; i++)
            {
                uint persona = PickPersona(filter);
                uint formwork = PickAgentForPersona(persona);
                ulong id = unchecked(s_nextId++);

                UXVector3 pos;
                List<ClientZoneGraphPathPoint> path;
                float destX, destZ;
                if (lanes.Count > 0)
                {
                    int lane = lanes[s_rng.Next(lanes.Count)];
                    pos = SidewalkLanes.LaneStart(lane);
                    (destX, destZ) = PickDestination(pos.X, pos.Z);
                    path = SidewalkLanes.BuildPathToward(pos.X, pos.Z, destX, destZ, SpawnRouteLen);
                }
                else
                {
                    var pt = a.Points[s_rng.Next(a.Points.Count)];
                    float x = pt.x + (a.Cx - pt.x) * 0.55f + (float)(s_rng.NextDouble() * 3 - 1.5);
                    float z = pt.z + (a.Cz - pt.z) * 0.55f + (float)(s_rng.NextDouble() * 3 - 1.5);
                    pos = new UXVector3 { X = x, Y = pt.y, Z = z };
                    path = DynamicPathGenerator.GeneratePath(x, z, x, z, DynamicPathGenerator.PathType.WanderLoop);
                    destX = x; destZ = z;
                }

                int pc = path?.Count ?? 0;
                s_psN++; s_psSum += pc;
                if (pc < s_psMin) s_psMin = pc;
                if (pc > s_psMax) s_psMax = pc;
                if (lanes.Count == 0) s_psFallback++;

                var crowd = new ClientCrowdInitData
                {
                    NpcFormworkId = formwork,
                    AgentPersonaId = persona,
                    UrbanDiversityConfigId = a.ConfigId,
                    DesiredSpeed = MovementScheduler.WalkSpeed,
                    ActionId = 0,
                    TargetLocationReason = ZoneGraphTargetLocationReason.Wander,
                    FashionSuitId = 0,   // 0 = agent's native appearance
                    Points = (GoNative && NoFedPath) ? new List<ClientZoneGraphPathPoint>() : path,
                    Id = id,
                    Position = pos,
                    Facing = 0,
                };
                SendCrowdAdd(conn, crowd);
                if (!GoNative && path != null && path.Count > 1)
                    SendFollowPathPoints(conn, id, path);
                else if (GoNative && EnableClientBrain)
                    SendClientControl(conn, id);
                ids.Add(id);

                if (Continuous && path != null && path.Count > 0)
                {
                    var e = path[path.Count - 1].Position;
                    float ph = 0f, pz2 = 0f;
                    if (path.Count >= 2) { var pp = path[path.Count - 2].Position; ph = e.X - pp.X; pz2 = e.Z - pp.Z; float pl = MathF.Sqrt(ph * ph + pz2 * pz2); if (pl > 1e-4f) { ph /= pl; pz2 /= pl; } }
                    s_pedWalks[id] = new PedWalk { ex = e.X, ez = e.Z, hx = ph, hz = pz2, destX = destX, destZ = destZ, jx = pos.X, jz = pos.Z, jMs = NowMs(), area = a.Index, spawnMs = NowMs(), asks = 0, nextMs = NowMs() + RepathEveryMs };
                }
            }
            return ids;
        }

        private static int s_asksHandled = 0, s_repathed = 0, s_noLane = 0, s_untracked = 0;

        // Client-driven re-path: on AskAetherAICrowdFollowPointPathDone the client reports a finished ped;
        // feed it the next leg toward its destination (and pick a new destination once arrived).
        public static void OnPedPathDone(Connection conn, ulong id)
        {
            s_asksHandled++;
            if (!Continuous) return;
            if (!s_pedWalks.TryGetValue(id, out var w)) { s_untracked++; return; }
            w.asks++;
            if (Dist(w.ex, w.ez, w.destX, w.destZ) < 30f)
            {
                var (nx, nz) = PickDestination(w.ex, w.ez);
                w.destX = nx; w.destZ = nz;
                w.jx = w.ex; w.jz = w.ez; w.jMs = NowMs();
            }
            var np = SidewalkLanes.BuildPathToward(w.ex, w.ez, w.destX, w.destZ, RepathLen);
            if (np == null || np.Count < 2) { s_noLane++; return; }
            np.Insert(0, new ClientZoneGraphPathPoint { Position = new UXVector3 { X = w.ex, Y = np[0].Position.Y, Z = w.ez }, Facing = 0 });
            SendFollowPathPoints(conn, id, np);
            var e = np[np.Count - 1].Position;
            w.ex = e.X; w.ez = e.Z;
            s_repathed++; s_lastPts = np.Count;
        }
        private static int s_lastPts = 0;

        public static void Tick(Connection conn)
        {
            if (!Enabled || !PushPeds) return;
            // Density maintenance also runs on the tick so a stationary player keeps getting foot traffic.
            var p = conn.LastKnownPlayerPosition;
            Stream(conn, p.X, p.Z);

            if (s_tickLog++ % 16 != 0) return;  // Reduced from 8 to 16 to reduce log frequency
            CrowdLog($"CENSUS alive={s_pedWalks.Count}/{MaxLivePeds} liveAreas={conn.CrowdAreas.Count} | asks={s_asksHandled} repathed={s_repathed} noLane={s_noLane}");
        }

        public class AskCrowdPathDoneArg : SerializedClass
        {
            public List<ClientZoneGraphPathFollowDown> dataList;
            public AskCrowdPathDoneArg() { onlyFields = true; }
        }

        private static void SendFollowPathPoints(Connection conn, ulong npcId, List<ClientZoneGraphPathPoint> pts)
        {
            var path = new ClientZoneGraphPath
            {
                Id = npcId,
                TargetLocationReason = ZoneGraphTargetLocationReason.Wander,
                ActionId = 0,
                Points = pts,
            };
            var msg = new UxRpcMessage
            {
                Mode = UxRpcPacketMode.Notify, RpcInvokeId = 0, RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAICrowdFollowPath,
            };
            msg.SetArgs(MethodId.SyncAetherAICrowdFollowPath, path);
            conn.SendPacket(msg);
        }

        private sealed class PauseUnitControlArgs : SerializedClass
        {
            public ulong instanceId;
            public bool serverControl;
            public AgentControlReason reason;
            public PauseUnitControlArgs() { onlyFields = true; }
        }

        // serverControl=false hands the unit to the client agent brain.
        private static void SendClientControl(Connection conn, ulong npcId)
        {
            var msg = new UxRpcMessage
            {
                Mode = UxRpcPacketMode.Notify, RpcInvokeId = 0, RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIPauseUnitControl,
            };
            msg.SetArgs(MethodId.SyncAetherAIPauseUnitControl, new PauseUnitControlArgs
            {
                instanceId = npcId,
                serverControl = false,
                reason = AgentControlReason.ConvertToPed,
            });
            conn.SendPacket(msg);
        }

        private static void SendFollowPath(Connection conn, ulong npcId, float ax, float az, float ay, float radius)
        {
            float r = Math.Clamp(radius, 4f, 14f);
            var pts = new List<ClientZoneGraphPathPoint>();
            const int n = 6;
            for (int i = 0; i < n; i++)
            {
                double ang = (Math.PI * 2.0 * i) / n + (s_rng.NextDouble() - 0.5);
                float rr = r * (0.4f + 0.6f * (float)s_rng.NextDouble());
                float px = ax + (float)(Math.Cos(ang) * rr);
                float pz = az + (float)(Math.Sin(ang) * rr);
                pts.Add(new ClientZoneGraphPathPoint { Position = new UXVector3 { X = px, Y = ay, Z = pz }, Facing = 0 });
            }
            var path = new ClientZoneGraphPath
            {
                Id = npcId,
                TargetLocationReason = ZoneGraphTargetLocationReason.Wander,
                ActionId = 0,
                Points = pts,
            };
            var msg = new UxRpcMessage
            {
                Mode = UxRpcPacketMode.Notify, RpcInvokeId = 0, RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAICrowdFollowPath,
            };
            msg.SetArgs(MethodId.SyncAetherAICrowdFollowPath, path);
            conn.SendPacket(msg);
        }

        // persona -> real civilian agent id (correct model); falls back to the roster if no pool.
        private static uint PickAgentForPersona(uint persona)
        {
            if (s_personaAgents != null && s_personaAgents.TryGetValue(persona, out var ids) && ids.Length > 0)
                return ids[s_rng.Next(ids.Length)];
            return s_formworks[s_rng.Next(s_formworks.Length)];
        }

        private static uint PickPersona(NpcFilter[] filter)
        {
            if (filter == null || filter.Length == 0) return DefaultPersona;
            int total = filter.Sum(f => Math.Max(1, f.weight));
            int r = s_rng.Next(total);
            foreach (var f in filter)
            {
                r -= Math.Max(1, f.weight);
                if (r < 0) return f.agentPersonaId;
            }
            return filter[0].agentPersonaId;
        }

        private static void SendCrowdAdd(Connection conn, ClientCrowdInitData crowd)
        {
            var msg = new UxRpcMessage
            {
                Mode = UxRpcPacketMode.Notify, RpcInvokeId = 0, RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAICrowdAdd,
            };
            msg.SetArgs(MethodId.SyncAetherAICrowdAdd, crowd);
            conn.SendPacket(msg);
        }

        // SyncAetherAINpcRemove frees a crowd entity (SyncDestroySurroundNpc does not free crowds).
        private static void SendDestroy(Connection conn, ulong npcId)
        {
            var msg = new UxRpcMessage
            {
                Mode = UxRpcPacketMode.Notify, RpcInvokeId = 0, RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAINpcRemove,
            };
            msg.SetArgs(MethodId.SyncAetherAINpcRemove, new SyncAetherAINpcRemoveArgs { npcId = npcId });
            conn.SendPacket(msg);
        }

        // Random UrbanDiversity area center 300-1500u away, else a far random point.
        private static (float x, float z) PickDestination(float fromX, float fromZ)
        {
            if (s_areas != null && s_areas.Count > 0)
                for (int t = 0; t < 8; t++)
                {
                    var a = s_areas[s_rng.Next(s_areas.Count)];
                    float d = Dist(fromX, fromZ, a.Cx, a.Cz);
                    if (d >= 300f && d <= 1500f) return (a.Cx, a.Cz);
                }
            double ang = s_rng.NextDouble() * Math.PI * 2;
            return (fromX + (float)(Math.Cos(ang) * 900), fromZ + (float)(Math.Sin(ang) * 900));
        }

        private static float Dist(float x1, float z1, float x2, float z2)
        {
            float dx = x1 - x2, dz = z1 - z2;
            return MathF.Sqrt(dx * dx + dz * dz);
        }

        // Clean up all crowd entities for a connection (on disconnect).
        public static void CleanupConnection(Connection conn)
        {
            if (!conn.CrowdAetherInited) return;

            // Destroy all crowd NPCs for this connection
            var idsToRemove = new List<ulong>();
            foreach (var kv in s_pedWalks)
            {
                if (kv.Value.area >= 0 && conn.CrowdAreas.TryGetValue((uint)kv.Value.area, out var areaList))
                {
                    if (areaList.Contains(kv.Key))
                    {
                        idsToRemove.Add(kv.Key);
                    }
                }
            }

            foreach (var id in idsToRemove)
            {
                SendDestroy(conn, id);
                if (s_pedWalks.TryGetValue(id, out var w) && conn.CrowdAreas.TryGetValue((uint)w.area, out var al))
                {
                    al.Remove(id);
                }
                s_pedWalks.Remove(id);
            }

            // Clear all crowd areas for this connection
            conn.CrowdAreas.Clear();
            conn.CrowdAetherInited = false;
            conn.LastCrowdStreamX = float.NaN;
            conn.LastCrowdStreamZ = float.NaN;

            Console.WriteLine($"[Crowd] Cleaned up {idsToRemove.Count} crowd NPCs for connection {conn.Pid}");
        }
    }
}
