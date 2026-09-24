using System.Text.Json;

namespace Ananta.Server.State;

public static class SessionState
{
    private static readonly object Sync = new();
    private static PlayerState? _current;

    public static PlayerState Current
    {
        get
        {
            lock (Sync)
            {
                if (_current is null)
                {
                    _current = AccountStore.LoadActive();
                    Console.WriteLine($"[STATE] 已载入账号 {_current.AccountId}（{_current.DisplayName}）");
                }
                return _current;
            }
        }
    }

    
    public static PlayerState SwitchTo(string accountId)
    {
        lock (Sync)
        {
            Save();
            AccountStore.ActiveAccountId = accountId;
            _current = AccountStore.Load(accountId);
            Console.WriteLine($"[STATE] 已切换账号 -> {accountId}");
            return _current;
        }
    }

    public static void Save()
    {
        PlayerState? snapshot;
        lock (Sync) snapshot = _current;
        if (snapshot is not null)
            AccountStore.Save(snapshot);
    }

    
    public static void Update(Action<PlayerState> mutate)
    {
        lock (Sync)
        {
            var state = Current;
            mutate(state);
            state.UpdatedAt = DateTimeOffset.Now;
            AccountStore.Save(state);
        }
    }

    public static void Reset()
    {
        lock (Sync) _current = null;
    }
}

public static class ExtraCatalog
{
    private static readonly object Sync = new();
    private static bool _loaded;
    private static List<uint> _radioSongs = [];
    private static List<uint> _achievements = [];
    private static List<uint> _cityPedia = [];
    private static List<uint> _factions = [];
    private static List<uint> _sceneIds = [];
    private static List<WeatherRow> _weathers = [];
    private static List<RaidRow> _raids = [];
    private static List<MapEntranceRow> _mapEntrances = [];
    private static List<uint> _metroLines = [];
    private static List<AgentProfileRow> _agentProfiles = [];
    private static List<CityPediaRow> _cityPediaRows = [];
    private static List<uint> _npcProfileTargets = [];
    private static List<BadgeRow> _badges = [];

    
    
    
    
    
    private static List<MetroLineRow> _railLines = [];
    private static List<MapRouteRow> _mapRoutes = [];

    public sealed record MapEntranceRow(uint Id, string Name, uint RaidId, int Type, float X, float Y, float Z);

    
    public sealed record RaidRow(uint Id, string Name, uint SceneId, int CountryId, int RaidType);

    
    public sealed record WeatherRow(uint Id, string Name);

    
    public sealed record MetroLineRow(uint Id, string Name, bool RingLine, int StationCount, float DepartureInterval, float TotalTravelDuration);

    
    
    
    
    
    
    
    
    
    
    
    
    public sealed record MapRouteRow(uint Id, string Name, string Color, uint RouteIcon);

    
    
    
    
    public sealed record AgentProfileRow(uint Id, string Name, uint AgentId, uint MaxTrust);

    
    public sealed record CityPediaRow(uint Id, int MaxProgress);

    
    
    
    
    public sealed record BadgeRow(uint Id, uint FightspiritId, string Name);

    public static IReadOnlyList<uint> RadioSongs { get { EnsureLoaded(); return _radioSongs; } }
    public static IReadOnlyList<MapEntranceRow> MapEntrances { get { EnsureLoaded(); return _mapEntrances; } }
    public static IReadOnlyList<uint> MetroLines { get { EnsureLoaded(); return _metroLines; } }

    
    public static IReadOnlyList<MetroLineRow> RailLines { get { EnsureLoaded(); return _railLines; } }

    
    
    
    
    public static IReadOnlyList<MapRouteRow> MapRoutes { get { EnsureLoaded(); return _mapRoutes; } }

    
    public static IReadOnlyList<AgentProfileRow> AgentProfiles { get { EnsureLoaded(); return _agentProfiles; } }

    
    public static IReadOnlyList<uint> NpcProfileTargets { get { EnsureLoaded(); return _npcProfileTargets; } }

    
    public static IReadOnlyList<CityPediaRow> CityPediaRows { get { EnsureLoaded(); return _cityPediaRows; } }

    
    public static IReadOnlyList<BadgeRow> Badges { get { EnsureLoaded(); return _badges; } }
    public static IReadOnlyList<uint> Achievements { get { EnsureLoaded(); return _achievements; } }
    public static IReadOnlyList<uint> CityPedia { get { EnsureLoaded(); return _cityPedia; } }
    public static IReadOnlyList<uint> Factions { get { EnsureLoaded(); return _factions; } }

    
    
    
    
    
    public static IReadOnlyList<uint> SceneIds { get { EnsureLoaded(); return _sceneIds; } }
    public static IReadOnlyList<RaidRow> Raids { get { EnsureLoaded(); return _raids; } }

    
    
    
    
    public static IReadOnlyList<WeatherRow> Weathers { get { EnsureLoaded(); return _weathers; } }

    private static void EnsureLoaded()
    {
        lock (Sync)
        {
            if (_loaded)
                return;
            _loaded = true;
            try
            {
                var root = FindDumpRoot();
                if (root is null)
                {
                    Console.WriteLine("[EXTRA] 未找到 ConfigDump_v3，电台 / 地图入口目录为空");
                    return;
                }

                
                
                
                _radioSongs = ReadRecords(root, "SoundOnlineUrlConfig.json")
                    .Select(r => TryUInt(r, "Id"))
                    .Where(id => id != 0)
                    .Distinct()
                    .OrderBy(id => id)
                    .ToList();

                _achievements = ReadRecords(root, "AchievementConfig.json")
                    .Select(r => TryUInt(r, "Id"))
                    .Where(id => id != 0)
                    .Distinct()
                    .OrderBy(id => id)
                    .ToList();

                _cityPedia = ReadRecords(root, "CityPediaConfig.json")
                    .Select(r => TryUInt(r, "Id"))
                    .Where(id => id != 0)
                    .Distinct()
                    .OrderBy(id => id)
                    .ToList();

                _weathers = ReadRecords(root, "WeatherConfig.json")
                    .Select(r => new WeatherRow(TryUInt(r, "Id"), TryString(r, "Name") ?? string.Empty))
                    .Where(w => w.Id != 0)
                    .OrderBy(w => w.Id)
                    .ToList();

                _factions = ReadRecords(root, "FactionConfig.json")
                    .Select(r => TryUInt(r, "Id"))
                    .Where(id => id != 0)
                    .Distinct()
                    .OrderBy(id => id)
                    .ToList();

                _mapEntrances = ReadRecords(root, "MapentranceConfig.json")
                    .Select(r =>
                    {
                        var pos = ReadVec3(r, "Coordinate");
                        return new MapEntranceRow(
                            TryUInt(r, "Id"),
                            TryString(r, "Name") ?? string.Empty,
                            TryUInt(r, "RaidId"),
                            TryInt(r, "Type"),
                            pos.x, pos.y, pos.z);
                    })
                    .Where(e => e.Id != 0)
                    .ToList();

                _raids = ReadRecords(root, "RaidConfig.json")
                    .Select(r => new RaidRow(
                        TryUInt(r, "Id"),
                        TryString(r, "Name") ?? string.Empty,
                        TryUInt(r, "SceneId"),
                        TryInt(r, "CountryId"),
                        TryInt(r, "RaidType")))
                    .Where(r => r.Id != 0)
                    .ToList();

                _sceneIds = _raids
                    .Select(r => r.SceneId)
                    .Where(x => x != 0)
                    .Distinct()
                    .OrderBy(x => x)
                    .ToList();

                _metroLines = _mapEntrances
                    .Where(e => e.Type == 11)
                    .Select(e => e.Id)
                    .Distinct()
                    .ToList();

                
                
                _railLines = ReadRecords(root, "RailLineConfig.json")
                    .Select(r => new MetroLineRow(
                        TryUInt(r, "Id"),
                        TryString(r, "LineName") ?? string.Empty,
                        TryBool(r, "RingLine"),
                        TryListCount(r, "Stations"),
                        TryFloat(r, "DepartureInterval"),
                        TryFloat(r, "TotalTravelDuration")))
                    .Where(x => x.Id != 0)
                    .OrderBy(x => x.Id)
                    .ToList();

                
                
                _mapRoutes = ReadRecords(root, "MapentranceRouteConfig.json")
                    .Select(r => new MapRouteRow(
                        TryUInt(r, "Id"),
                        TryString(r, "RouteName") ?? string.Empty,
                        TryString(r, "Color") ?? string.Empty,
                        TryUInt(r, "RouteIcon")))
                    .Where(x => x.Id != 0)
                    .OrderBy(x => x.Id)
                    .ToList();

                
                
                
                _agentProfiles = ReadRecords(root, "ProfileAgentProfileConfig.json")
                    .Select(r => new AgentProfileRow(
                        TryUInt(r, "Id"),
                        TryString(r, "Name") ?? string.Empty,
                        TryUInt(r, "AgentId"),
                        TryUInt(r, "MaxTrust")))
                    .Where(x => x.Id != 0)
                    .OrderBy(x => x.Id)
                    .ToList();

                _npcProfileTargets = ReadRecords(root, "ProfileTargetConfig.json")
                    .Select(r => TryUInt(r, "Id"))
                    .Where(x => x != 0)
                    .Distinct()
                    .OrderBy(x => x)
                    .ToList();

                
                
                _cityPediaRows = ReadRecords(root, "CityPediaConfig.json")
                    .Select(r => new CityPediaRow(TryUInt(r, "Id"), TryInt(r, "MaxProgress")))
                    .Where(x => x.Id != 0)
                    .OrderBy(x => x.Id)
                    .ToList();

                
                
                _badges = ReadRecords(root, "UrbanBadgeConfig.json")
                    .Select(r => new BadgeRow(TryUInt(r, "Id"), TryUInt(r, "FightspiritId"), TryString(r, "Name") ?? string.Empty))
                    .Where(x => x.Id != 0)
                    .ToList();

                Console.WriteLine($"[EXTRA] 电台 {_radioSongs.Count} · 地图入口 {_mapEntrances.Count} · 场景 {_sceneIds.Count} · raid {_raids.Count} · 地铁线 {_metroLines.Count} · 地铁线路 {_railLines.Count} · 地图交通线路 {_mapRoutes.Count} · 成就 {_achievements.Count} · 百科 {_cityPediaRows.Count} · 阵营 {_factions.Count} · 角色档案 {_agentProfiles.Count} · 档案目标 {_npcProfileTargets.Count} · 徽章 {_badges.Count}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[EXTRA] 加载失败: {ex.Message}");
            }
        }
    }

    private static bool TryBool(JsonElement row, string key)
    {
        if (!row.TryGetProperty(key, out var v)) return false;
        return v.ValueKind switch
        {
            JsonValueKind.True => true,
            JsonValueKind.False => false,
            JsonValueKind.Number => v.TryGetInt32(out var n) && n != 0,
            JsonValueKind.String => bool.TryParse(v.GetString(), out var b) && b,
            _ => false,
        };
    }

    private static float TryFloat(JsonElement row, string key)
    {
        if (!row.TryGetProperty(key, out var v)) return 0f;
        if (v.ValueKind == JsonValueKind.Number && v.TryGetSingle(out var f)) return f;
        if (v.ValueKind == JsonValueKind.String && float.TryParse(v.GetString(), out var s2)) return s2;
        return 0f;
    }

    private static int TryListCount(JsonElement row, string key)
    {
        if (!row.TryGetProperty(key, out var v)) return 0;
        return v.ValueKind == JsonValueKind.Array ? v.GetArrayLength() : 0;
    }

    private static string? FindDumpRoot()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        for (var i = 0; i < 8 && dir is not null; i++, dir = dir.Parent)
        {
            var candidate = Path.Combine(dir.FullName, "ConfigDump_v3");
            if (Directory.Exists(candidate))
                return candidate;
        }
        return null;
    }

    private static JsonElement[] ReadRecords(string root, string file)
    {
        var path = Path.Combine(root, file);
        if (!File.Exists(path))
            return [];
        using var doc = JsonDocument.Parse(File.ReadAllText(path));
        if (!doc.RootElement.TryGetProperty("records", out var records) || records.ValueKind != JsonValueKind.Array)
            return [];
        return records.EnumerateArray().Select(x => x.Clone()).ToArray();
    }

    private static uint TryUInt(JsonElement e, string name)
        => e.TryGetProperty(name, out var v) && v.TryGetUInt32(out var n) ? n : 0u;

    private static int TryInt(JsonElement e, string name)
        => e.TryGetProperty(name, out var v) && v.TryGetInt32(out var n) ? n : 0;

    private static string? TryString(JsonElement e, string name)
        => e.TryGetProperty(name, out var v) && v.ValueKind == JsonValueKind.String ? v.GetString() : null;

    private static (float x, float y, float z) ReadVec3(JsonElement e, string name)
    {
        if (!e.TryGetProperty(name, out var arr) || arr.ValueKind != JsonValueKind.Array)
            return (0f, 0f, 0f);
        var values = arr.EnumerateArray().Take(3).Select(x => x.TryGetSingle(out var n) ? n : 0f).ToArray();
        return values.Length == 3 ? (values[0], values[1], values[2]) : (0f, 0f, 0f);
    }
}
