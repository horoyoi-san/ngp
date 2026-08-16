using System;
using System.IO;
using System.Linq;
using System.Text.Json;
using AnantaTestGameServer.Game;

namespace AnantaTestGameServer.Configs
{
    /// <summary>
    /// Loads server-specific configs (ports, NPC IDs, spawn settings, etc.)
    /// from JSON files in the configs/ directory.
    /// Falls back to hardcoded defaults if files are missing.
    /// </summary>
    public static class GameConfig
    {
        private static readonly JsonSerializerOptions JsonOptions = new()
        {
            PropertyNameCaseInsensitive = true,
            AllowTrailingCommas = true,
            ReadCommentHandling = JsonCommentHandling.Skip,
        };

        private static readonly JsonDocumentOptions DocOptions = new()
        {
            CommentHandling = JsonCommentHandling.Skip,
            AllowTrailingCommas = true,
        };

        // ── Server ──
        public static int[] GamePorts { get; private set; } = { 5200, 5201, 5202 };
        public static int GmToolPort { get; private set; } = 17666;
        public static int LoginTcpPort { get; private set; } = 5802;
        public static int TickIntervalMs { get; private set; } = 2000;
        public static int MetroNpcTickIntervalMs { get; private set; } = 15000;

        // ── NPCs ──
        public static uint[] AllNpcFormworks { get; private set; } = Array.Empty<uint>();
        public static uint[] AutoSpawnNpcIds { get; private set; } = Array.Empty<uint>();
        public static uint[] GmOnlyNpcIds { get; private set; } = Array.Empty<uint>();
        public static uint[] FashionSuits { get; private set; } = { 11190001, 11190002, 11190003, 11190004, 11190005, 11190006 };
        public static uint AgentPersonaId { get; private set; } = 45200058;
        public static uint UrbanDiversityId { get; private set; } = 88888000;

        // ── World / Vehicles ──
        public static uint[] VehicleConfigs { get; private set; } = VehicleIds.AllVehicleIds;

        // ── NPC Spawn ──
        public static bool NpcSpawnEnabled { get; private set; } = true;
        public static int SpawnRadius { get; private set; } = 5;
        public static int DespawnRadius { get; private set; } = 8;
        public static int MaxAliveNpcs { get; private set; } = 50;
        public static int MinNpcsPerCell { get; private set; } = 1;
        public static int MaxNpcsPerCell { get; private set; } = 3;

        // ── AOI Grid ──
        public static float GridCellSize { get; private set; } = 40f;
        public static float GridOffsetX { get; private set; } = 2010f;
        public static float GridOffsetZ { get; private set; } = -379f;
        public static int DestructibleRange { get; private set; } = 120;
        public static int SceneItemRange { get; private set; } = 40;

        // ── Metro ──
        public static float MetroSyncIntervalSeconds { get; private set; } = 5f;
        public static int MetroDefaultTrainsPerLine { get; private set; } = 1;
        public static float[] MetroCycleSeconds { get; private set; } = { 300f, 300f, 240f, 240f };

        public static void Load(string configDir)
        {
            if (!Directory.Exists(configDir))
            {
                Console.WriteLine("[GameConfig] Config directory not found, using defaults");
                return;
            }

            LoadServerConfig(Path.Combine(configDir, "server_config.json"));
            LoadNpcConfig(Path.Combine(configDir, "npc_config.json"));
            LoadWorldConfig(Path.Combine(configDir, "world_config.json"));

            Console.WriteLine($"[GameConfig] Loaded: ports={string.Join("/", GamePorts)}, gmPort={GmToolPort}, " +
                $"tick={TickIntervalMs}ms, spawnRadius={SpawnRadius}, maxNpcs={MaxAliveNpcs}, " +
                $"gridSize={GridCellSize}, npcFormworks={AllNpcFormworks.Length}, vehicles={VehicleConfigs.Length}");
        }

        private static void LoadServerConfig(string path)
        {
            if (!File.Exists(path)) return;
            try
            {
                using var doc = JsonDocument.Parse(File.ReadAllText(path), DocOptions);
                var root = doc.RootElement;

                if (root.TryGetProperty("gamePorts", out var ports))
                    GamePorts = ports.EnumerateArray().Select(p => p.GetInt32()).ToArray();
                if (root.TryGetProperty("gmToolPort", out var gm))
                    GmToolPort = gm.GetInt32();
                if (root.TryGetProperty("loginTcpPort", out var login))
                    LoginTcpPort = login.GetInt32();
                if (root.TryGetProperty("tickIntervalMs", out var tick))
                    TickIntervalMs = tick.GetInt32();
                if (root.TryGetProperty("metroNpcTickIntervalMs", out var metroTick))
                    MetroNpcTickIntervalMs = metroTick.GetInt32();

                Console.WriteLine("[GameConfig] Loaded server_config.json");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[GameConfig] Failed to load server_config.json: {ex.Message}");
            }
        }

        private static void LoadNpcConfig(string path)
        {
            if (!File.Exists(path)) return;
            try
            {
                using var doc = JsonDocument.Parse(File.ReadAllText(path), DocOptions);
                var root = doc.RootElement;

                if (root.TryGetProperty("allNpcFormworks", out var formworks))
                {
                    var allList = new System.Collections.Generic.List<uint>();
                    var autoList = new System.Collections.Generic.List<uint>();
                    var gmList = new System.Collections.Generic.List<uint>();

                    foreach (var entry in formworks.EnumerateArray())
                    {
                        uint id = entry.GetProperty("id").GetUInt32();
                        string category = entry.TryGetProperty("category", out var cat) ? cat.GetString() ?? "" : "";
                        allList.Add(id);
                        if (category == "auto_spawn") autoList.Add(id);
                        else gmList.Add(id);
                    }

                    AllNpcFormworks = allList.ToArray();
                    AutoSpawnNpcIds = autoList.ToArray();
                    GmOnlyNpcIds = gmList.ToArray();
                }

                if (root.TryGetProperty("fashionSuits", out var fashion))
                    FashionSuits = fashion.EnumerateArray().Select(f => f.GetUInt32()).ToArray();
                if (root.TryGetProperty("agentPersonaId", out var persona))
                    AgentPersonaId = persona.GetUInt32();
                if (root.TryGetProperty("urbanDiversityId", out var diversity))
                    UrbanDiversityId = diversity.GetUInt32();

                Console.WriteLine("[GameConfig] Loaded npc_config.json");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[GameConfig] Failed to load npc_config.json: {ex.Message}");
            }
        }

        private static void LoadWorldConfig(string path)
        {
            if (!File.Exists(path)) return;
            try
            {
                using var doc = JsonDocument.Parse(File.ReadAllText(path), DocOptions);
                var root = doc.RootElement;

                if (root.TryGetProperty("vehicleConfigs", out var vehicles))
                    VehicleConfigs = vehicles.EnumerateArray().Select(v => v.GetUInt32()).ToArray();

                if (root.TryGetProperty("npcSpawn", out var spawn))
                {
                    if (spawn.TryGetProperty("enabled", out var en)) NpcSpawnEnabled = en.GetBoolean();
                    if (spawn.TryGetProperty("spawnRadius", out var sr)) SpawnRadius = sr.GetInt32();
                    if (spawn.TryGetProperty("despawnRadius", out var dr)) DespawnRadius = dr.GetInt32();
                    if (spawn.TryGetProperty("maxAliveNpcs", out var ma)) MaxAliveNpcs = ma.GetInt32();
                    if (spawn.TryGetProperty("minNpcsPerCell", out var min)) MinNpcsPerCell = min.GetInt32();
                    if (spawn.TryGetProperty("maxNpcsPerCell", out var max)) MaxNpcsPerCell = max.GetInt32();
                }

                if (root.TryGetProperty("aoi", out var aoi))
                {
                    if (aoi.TryGetProperty("gridCellSize", out var cs)) GridCellSize = cs.GetSingle();
                    if (aoi.TryGetProperty("gridOffsetX", out var ox)) GridOffsetX = ox.GetSingle();
                    if (aoi.TryGetProperty("gridOffsetZ", out var oz)) GridOffsetZ = oz.GetSingle();
                    if (aoi.TryGetProperty("destructibleRange", out var dr)) DestructibleRange = dr.GetInt32();
                    if (aoi.TryGetProperty("sceneItemRange", out var si)) SceneItemRange = si.GetInt32();
                }

                if (root.TryGetProperty("metro", out var metro))
                {
                    if (metro.TryGetProperty("syncIntervalSeconds", out var sync))
                        MetroSyncIntervalSeconds = sync.GetSingle();
                    if (metro.TryGetProperty("defaultTrainsPerLine", out var trains))
                        MetroDefaultTrainsPerLine = trains.GetInt32();
                    if (metro.TryGetProperty("defaultCycleSeconds", out var cycles))
                    {
                        var list = new System.Collections.Generic.List<float>();
                        foreach (var line in cycles.EnumerateObject())
                            list.Add(line.Value.GetSingle());
                        MetroCycleSeconds = list.ToArray();
                    }
                }

                Console.WriteLine("[GameConfig] Loaded world_config.json");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[GameConfig] Failed to load world_config.json: {ex.Message}");
            }
        }
    }
}
