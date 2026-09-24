using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal static class AgentCatalogRepository
{
    internal sealed record AgentEntry(
        uint Id,
        string Name,
        string Description,
        int SpeciesType,
        int AgentType,
        int AgentSecondaryType,
        int EnemyClassType,
        bool IsGiantEnemy,
        int ModelType,
        string SkillAction)
    {
        
        
        
        
        
        
        
        
        internal bool IsMonster => SkillAction.Contains("怪物技能", StringComparison.Ordinal);

        
        
        
        
        
        
        
        
        
        internal bool IsNpc => AgentType == 1;

        
        internal int SexType { get; init; }

        
        internal int Age { get; init; }

        
        internal bool IsEmptyAction { get; init; }

        
        internal int ActionGroup { get; init; }

        
        internal uint GeneralModelId { get; init; }

        
        internal int JobTag { get; init; }

        
        
        
        
        
        
        
        
        internal IReadOnlyList<int> LaunchProperty { get; init; } = [];

        
        internal int EconomicLevel { get; init; }
    }

    private static readonly object Sync = new();
    private static List<AgentEntry>? _agents;

    internal static int Count
    {
        get { EnsureLoaded(); lock (Sync) return _agents!.Count; }
    }

    internal static IReadOnlyList<AgentEntry> All
    {
        get { EnsureLoaded(); lock (Sync) return _agents!.ToArray(); }
    }

    internal static AgentEntry? Find(uint agentId)
    {
        EnsureLoaded();
        lock (Sync)
            return _agents!.FirstOrDefault(x => x.Id == agentId);
    }

    
    internal static IReadOnlyList<AgentEntry> Query(
        string? term = null,
        int? speciesType = null,
        int? agentType = null,
        int? enemyClassType = null,
        bool? monstersOnly = null,
        int limit = 500)
    {
        EnsureLoaded();
        lock (Sync)
        {
            IEnumerable<AgentEntry> query = _agents!;
            if (speciesType is not null)
                query = query.Where(x => x.SpeciesType == speciesType.Value);
            if (agentType is not null)
                query = query.Where(x => x.AgentType == agentType.Value);
            if (enemyClassType is not null)
                query = query.Where(x => x.EnemyClassType == enemyClassType.Value);
            if (monstersOnly is true)
                query = query.Where(x => x.IsMonster);
            else if (monstersOnly is false)
                query = query.Where(x => !x.IsMonster);

            if (!string.IsNullOrWhiteSpace(term))
            {
                var needle = term.Trim();
                query = uint.TryParse(needle, out var exact)
                    ? query.Where(x => x.Id == exact
                        || x.Name.Contains(needle, StringComparison.OrdinalIgnoreCase)
                        || x.Description.Contains(needle, StringComparison.OrdinalIgnoreCase))
                    : query.Where(x => x.Name.Contains(needle, StringComparison.OrdinalIgnoreCase)
                        || x.Description.Contains(needle, StringComparison.OrdinalIgnoreCase));
            }

            return query.OrderBy(x => x.Id).Take(limit).ToArray();
        }
    }

    internal static int MonsterCount
    {
        get { EnsureLoaded(); lock (Sync) return _agents!.Count(x => x.IsMonster); }
    }

    

    
    
    
    
    private static readonly string[] CitizenKeywords =
        ["普通居民", "普通男", "普通女", "居民", "路人", "市民", "社畜", "消费者"];

    private static IReadOnlyList<AgentEntry>? _citizens;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static IReadOnlyList<AgentEntry> Citizens
    {
        get
        {
            EnsureLoaded();
            lock (Sync)
            {
                if (_citizens is not null)
                    return _citizens;

                _citizens = _agents!
                    .Where(x => x.IsNpc
                                && x.SpeciesType == 2
                                && !x.IsEmptyAction
                                && CitizenKeywords.Any(k => x.Description.Contains(k, StringComparison.Ordinal)))
                    .ToArray();
                return _citizens;
            }
        }
    }

    
    
    
    
    
    
    
    
    
    
    internal static AgentEntry? PickCitizen(IReadOnlyList<int>? sexTypes, IReadOnlyList<int>? ageTags, Random rng)
    {
        var pool = Citizens;
        if (pool.Count == 0)
            return null;

        IEnumerable<AgentEntry> filtered = pool;
        if (sexTypes is { Count: > 0 })
            filtered = filtered.Where(x => sexTypes.Contains(x.SexType));

        if (ageTags is { Count: > 0 })
            filtered = filtered.Where(x => ageTags.Any(t => AgeTagContains(t, x.Age)));

        var list = filtered as IReadOnlyList<AgentEntry> ?? filtered.ToArray();
        if (list.Count == 0)
            list = pool;

        return list[rng.Next(list.Count)];
    }

    
    private static bool AgeTagContains(int tag, int age) => tag switch
    {
        1 => age is >= 18 and <= 26,
        2 => age is >= 27 and <= 39,
        3 => age is >= 40 and <= 55,
        _ => true,
    };

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static AgentEntry? PickForPersona(PersonaCatalog.PersonaEntry? persona, Random rng)
    {
        var pool = Citizens;
        if (pool.Count == 0)
            return null;
        if (persona is null)
            return pool[rng.Next(pool.Count)];

        static bool Has(IReadOnlyList<int> set, int v) => set.Count == 0 || set.Contains(v);
        static bool Overlaps(IReadOnlyList<int> set, IReadOnlyList<int> v) =>
            set.Count == 0 || v.Count == 0 || v.Any(set.Contains);

        bool Sex(AgentEntry x) => Has(persona.SexTypes, x.SexType);
        bool Age(AgentEntry x) => persona.AgeTags.Count == 0 || persona.AgeTags.Any(t => AgeTagContains(t, x.Age));
        bool Job(AgentEntry x) => Has(persona.JobTags, x.JobTag);
        bool Launch(AgentEntry x) => Overlaps(persona.LaunchProperties, x.LaunchProperty);
        bool Econ(AgentEntry x) => Has(persona.EconomicLevels, x.EconomicLevel);

        
        var tiers = new Func<AgentEntry, bool>[]
        {
            x => Sex(x) && Age(x) && Job(x) && Launch(x) && Econ(x),
            x => Sex(x) && Age(x) && Job(x) && Launch(x),
            x => Sex(x) && Age(x) && Job(x),
            x => Sex(x) && Age(x),
        };

        foreach (var tier in tiers)
        {
            var list = pool.Where(tier).ToArray();
            if (list.Length > 0)
                return list[rng.Next(list.Length)];
        }
        return pool[rng.Next(pool.Count)];
    }

    
    internal static (int Full, int NoEcon, int NoLaunch, int SexAge, string Sample)
        ProbePersonaMatch(PersonaCatalog.PersonaEntry? persona)
    {
        var pool = Citizens;
        if (persona is null || pool.Count == 0)
            return (0, 0, 0, 0, "(无)");

        static bool Has(IReadOnlyList<int> set, int v) => set.Count == 0 || set.Contains(v);
        static bool Overlaps(IReadOnlyList<int> set, IReadOnlyList<int> v) =>
            set.Count == 0 || v.Count == 0 || v.Any(set.Contains);

        bool Sex(AgentEntry x) => Has(persona.SexTypes, x.SexType);
        bool Age(AgentEntry x) => persona.AgeTags.Count == 0 || persona.AgeTags.Any(t => AgeTagContains(t, x.Age));
        bool Job(AgentEntry x) => Has(persona.JobTags, x.JobTag);
        bool Launch(AgentEntry x) => Overlaps(persona.LaunchProperties, x.LaunchProperty);
        bool Econ(AgentEntry x) => Has(persona.EconomicLevels, x.EconomicLevel);

        var full = pool.Where(x => Sex(x) && Age(x) && Job(x) && Launch(x) && Econ(x)).ToArray();
        var noEcon = pool.Where(x => Sex(x) && Age(x) && Job(x) && Launch(x)).ToArray();
        var noLaunch = pool.Where(x => Sex(x) && Age(x) && Job(x)).ToArray();
        var sexAge = pool.Where(x => Sex(x) && Age(x)).ToArray();
        var sample = full.Length > 0
            ? $"{full[0].Id} Launch=[{string.Join(",", full[0].LaunchProperty)}] {full[0].Description}"
            : "(全约束筛不出)";
        return (full.Length, noEcon.Length, noLaunch.Length, sexAge.Length, sample);
    }

    
    internal static (int Count, int DistinctModels, int DistinctSex, int MinAge, int MaxAge) ProbeCitizens()
    {
        var pool = Citizens;
        if (pool.Count == 0)
            return (0, 0, 0, 0, 0);
        return (pool.Count,
            pool.Select(x => x.GeneralModelId).Distinct().Count(),
            pool.Select(x => x.SexType).Distinct().Count(),
            pool.Min(x => x.Age),
            pool.Max(x => x.Age));
    }

    
    internal static IReadOnlyDictionary<string, int> Histogram(string field)
    {
        EnsureLoaded();
        lock (Sync)
        {
            Func<AgentEntry, int> selector = field switch
            {
                nameof(AgentEntry.SpeciesType) => x => x.SpeciesType,
                nameof(AgentEntry.AgentType) => x => x.AgentType,
                nameof(AgentEntry.AgentSecondaryType) => x => x.AgentSecondaryType,
                nameof(AgentEntry.EnemyClassType) => x => x.EnemyClassType,
                nameof(AgentEntry.ModelType) => x => x.ModelType,
                _ => x => x.AgentType,
            };
            return _agents!.GroupBy(selector)
                .OrderByDescending(g => g.Count())
                .ToDictionary(g => g.Key.ToString(), g => g.Count());
        }
    }

    private static void EnsureLoaded()
    {
        if (_agents is not null)
            return;
        lock (Sync)
        {
            if (_agents is not null)
                return;

            _agents = [];
            try
            {
                var config = PrivateServerConfigStore.Current;
                var root = PrivateServerConfigStore.ResolveProjectPath(config.Paths.ClientConfigs);
                var path = Path.Combine(root, "AgentCatalog.json");
                if (!File.Exists(path))
                    path = Path.Combine(root, "AgentConfig.json");
                if (!File.Exists(path))
                {
                    Console.WriteLine($"[AGENTS] {root} 下既没有 AgentCatalog.json 也没有 AgentConfig.json；生成目录只有可玩角色");
                    return;
                }

                using var document = JsonDocument.Parse(File.ReadAllText(path));
                if (!document.RootElement.TryGetProperty("records", out var records) ||
                    records.ValueKind != JsonValueKind.Array)
                {
                    Console.WriteLine($"[AGENTS] {path} 没有 records 数组");
                    return;
                }

                foreach (var row in records.EnumerateArray())
                {
                    if (!row.TryGetProperty("Id", out var idNode) || !idNode.TryGetUInt32(out var id) || id == 0)
                        continue;
                    
                    var name = ReadString(row, "Name");
                    var description = ReadString(row, "Desc") ?? ReadString(row, "Description");
                    if (string.IsNullOrWhiteSpace(name) && string.IsNullOrWhiteSpace(description))
                        continue;

                    _agents.Add(new AgentEntry(
                        id,
                        name ?? string.Empty,
                        description ?? string.Empty,
                        ReadInt(row, "SpeciesType"),
                        ReadInt(row, "AgentType"),
                        ReadInt(row, "AgentSecondaryType"),
                        ReadInt(row, "EnemyClassType"),
                        row.TryGetProperty("IsGaintEnemy", out var giant) && giant.ValueKind == JsonValueKind.True,
                        ReadInt(row, "ModelType"),
                        ReadString(row, "Skill") ?? ReadString(row, "AgentSkillAction") ?? string.Empty)
                    {
                        SexType = ReadInt(row, "SexType"),
                        Age = ReadInt(row, "Age"),
                        IsEmptyAction = ReadBool(row, "IsEmptyAction"),
                        ActionGroup = ReadInt(row, "ActionGroup"),
                        GeneralModelId = ReadUInt(row, "GeneralModelId"),
                        JobTag = ReadInt(row, "JobTag"),
                        LaunchProperty = ReadIntList(row, "LaunchProperty"),
                        EconomicLevel = ReadInt(row, "EconomicLevel"),
                    });
                }

                Console.WriteLine($"[AGENTS] {Path.GetFileName(path)} 已载入: {_agents.Count} 个 agent（{MonsterCount} 个带怪物技能集）");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AGENTS] 载入 AgentConfig 失败: {ex.Message}");
            }
        }
    }

    private static int ReadInt(JsonElement row, string name)
        => row.TryGetProperty(name, out var node) && node.TryGetInt32(out var value) ? value : 0;

    
    private static IReadOnlyList<int> ReadIntList(JsonElement row, string name)
    {
        if (!row.TryGetProperty(name, out var node))
            return [];
        if (node.ValueKind == JsonValueKind.Number)
            return node.TryGetInt32(out var single) ? [single] : [];
        if (node.ValueKind != JsonValueKind.Array)
            return [];
        var list = new List<int>(node.GetArrayLength());
        foreach (var item in node.EnumerateArray())
            if (item.ValueKind == JsonValueKind.Number && item.TryGetInt32(out var v))
                list.Add(v);
        return list;
    }

    private static uint ReadUInt(JsonElement row, string name)
        => row.TryGetProperty(name, out var node) && node.TryGetUInt32(out var value) ? value : 0;

    private static bool ReadBool(JsonElement row, string name)
        => row.TryGetProperty(name, out var node) && node.ValueKind == JsonValueKind.True;

    private static string? ReadString(JsonElement row, string name)
    {
        if (!row.TryGetProperty(name, out var node))
            return null;
        return node.ValueKind switch
        {
            JsonValueKind.String => node.GetString(),
            JsonValueKind.Number => node.ToString(),
            _ => null,
        };
    }
}
