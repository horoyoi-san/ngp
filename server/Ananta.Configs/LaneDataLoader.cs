using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using AnantaTestGameServer.Game;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Configs
{
    /// <summary>
    /// Loads road and sidewalk lane data from zonegraph CSV and JSON files,
    /// then registers them with MassEntityManager so the client gets
    /// SyncAetherAIVehicleLaneDatas on scene load.
    /// </summary>
    public static class LaneDataLoader
    {
        private static bool _loaded = false;

        // Default paths relative to the server binary (same as other configs)
        static readonly string ConfigsDir = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "configs");
        public static string RoadLanesPath { get; set; } = Path.Combine(ConfigsDir, "road_lanes.json");
        public static string SidewalkLanesPath { get; set; } = Path.Combine(ConfigsDir, "sidewalk_lanes.json");
        public static string ZonegraphCsvPath { get; set; } = Path.Combine(ConfigsDir, "zonegraph_lanes.csv");

        // Limits to prevent sending too much data at once (causes client timeout)
        public static int MaxRoadLanes { get; set; } = 0;
        public static int MaxSidewalkLanes { get; set; } = 0;
        public static int MaxCsvLanes { get; set; } = 0;

        /// <summary>
        /// Loads all lane data and registers it with MassEntityManager for the given connection.
        /// Safe to call multiple times — subsequent calls are no-ops.
        /// </summary>
        public static void LoadAndRegister(Connection conn)
        {
            if (_loaded) return;
            _loaded = true;

            int roadCount = 0;
            int sidewalkCount = 0;
            int csvCount = 0;

            // ── 1. Load road_lanes.json ──────────────────────────────────────────
            if (File.Exists(RoadLanesPath))
            {
                try
                {
                    var json = File.ReadAllText(RoadLanesPath);
                    var doc = System.Text.Json.JsonDocument.Parse(json);
                    if (doc.RootElement.TryGetProperty("lanes", out var lanesArr))
                    {
                        uint laneId = 1;
                        int loadedCount = 0;
                        foreach (var lane in lanesArr.EnumerateArray())
                        {
                            if (loadedCount >= MaxRoadLanes) break;
                            var waypoints = ParseJsonWaypoints(lane);
                            if (waypoints.Count < 2) continue;

                            RegisterLane(conn, laneId++, waypoints, speedLimit: 15f, direction: 0);
                            roadCount++;
                            loadedCount++;
                        }
                    }
                    Console.WriteLine($"[LaneDataLoader] Loaded {roadCount} road lanes from {RoadLanesPath}");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[LaneDataLoader] ERROR loading road lanes: {ex.Message}");
                }
            }
            else
            {
                Console.WriteLine($"[LaneDataLoader] Road lanes file not found: {RoadLanesPath}");
            }

            // ── 2. Load sidewalk_lanes.json ─────────────────────────────────────
            if (File.Exists(SidewalkLanesPath))
            {
                try
                {
                    var json = File.ReadAllText(SidewalkLanesPath);
                    var doc = System.Text.Json.JsonDocument.Parse(json);
                    if (doc.RootElement.TryGetProperty("lanes", out var lanesArr))
                    {
                        uint laneId = 100000; // offset so IDs don't collide with road lanes
                        int loadedCount = 0;
                        foreach (var lane in lanesArr.EnumerateArray())
                        {
                            if (loadedCount >= MaxSidewalkLanes) break;
                            var waypoints = ParseJsonWaypoints(lane);
                            if (waypoints.Count < 2) continue;

                            RegisterLane(conn, laneId++, waypoints, speedLimit: 5f, direction: 0);
                            sidewalkCount++;
                            loadedCount++;
                        }
                    }
                    Console.WriteLine($"[LaneDataLoader] Loaded {sidewalkCount} sidewalk lanes from {SidewalkLanesPath}");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[LaneDataLoader] ERROR loading sidewalk lanes: {ex.Message}");
                }
            }
            else
            {
                Console.WriteLine($"[LaneDataLoader] Sidewalk lanes file not found: {SidewalkLanesPath}");
            }

            // ── 3. Load zonegraph_lanes.csv ──────────────────────────────────────
            // CSV format: id,x1,y1,z1,x2,y2,z2,...
            // Each row is a lane; groups of 2 rows are a bidirectional pair.
            if (File.Exists(ZonegraphCsvPath))
            {
                try
                {
                    var lines = File.ReadAllLines(ZonegraphCsvPath);
                    uint laneId = 200000; // offset from other sets
                    int loadedCount = 0;
                    foreach (var rawLine in lines)
                    {
                        if (loadedCount >= MaxCsvLanes) break;
                        if (string.IsNullOrWhiteSpace(rawLine)) continue;
                        var parts = rawLine.Split(',');
                        if (parts.Length < 7) continue;

                        var waypoints = new List<UXVector3>();
                        // parts[0] = id (unused for lane registration, lanes are identified by server-side laneId)
                        // Parse triplets: x,y,z, x,y,z, ...
                        for (int i = 1; i + 2 < parts.Length; i += 3)
                        {
                            if (float.TryParse(parts[i], out float x) &&
                                float.TryParse(parts[i + 1], out float y) &&
                                float.TryParse(parts[i + 2], out float z))
                            {
                                waypoints.Add(new UXVector3 { X = x, Y = y, Z = z });
                            }
                        }

                        if (waypoints.Count < 2) continue;
                        RegisterLane(conn, laneId++, waypoints, speedLimit: 10f, direction: 0);
                        csvCount++;
                        loadedCount++;
                    }
                    Console.WriteLine($"[LaneDataLoader] Loaded {csvCount} lanes from {ZonegraphCsvPath}");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[LaneDataLoader] ERROR loading zonegraph CSV: {ex.Message}");
                }
            }
            else
            {
                Console.WriteLine($"[LaneDataLoader] Zonegraph CSV not found: {ZonegraphCsvPath}");
            }

            int total = roadCount + sidewalkCount + csvCount;
            Console.WriteLine($"[LaneDataLoader] Total lanes registered: {total} (road={roadCount} sidewalk={sidewalkCount} csv={csvCount})");

            // ── 4. Push lane data to client ──────────────────────────────────────
            if (total > 0)
            {
                MassEntityManager.PushLaneData(conn);
            }
        }

        /// <summary>
        /// Resets the loaded state — useful for tests or hot-reload scenarios.
        /// </summary>
        public static void Reset()
        {
            _loaded = false;
        }

        // ── Internal helpers ─────────────────────────────────────────────────────

        static List<UXVector3> ParseJsonWaypoints(System.Text.Json.JsonElement lane)
        {
            var waypoints = new List<UXVector3>();
            // JSON lanes are flat arrays: [x1,y1,z1, x2,y2,z2, ...]
            var values = lane.EnumerateArray().ToList();
            for (int i = 0; i + 2 < values.Count; i += 3)
            {
                if (values[i].TryGetSingle(out float x) &&
                    values[i + 1].TryGetSingle(out float y) &&
                    values[i + 2].TryGetSingle(out float z))
                {
                    waypoints.Add(new UXVector3 { X = x, Y = y, Z = z });
                }
            }
            return waypoints;
        }

        static void RegisterLane(Connection conn, uint laneId, List<UXVector3> waypoints, float speedLimit, uint direction)
        {
            var lane = new MassEntityManager.TrafficLane
            {
                LaneId = laneId,
                Waypoints = waypoints,
                SpeedLimit = speedLimit,
                Direction = direction,
                IsActive = true,
            };
            MassEntityManager.RegisterLane(conn, lane);
        }
    }
}