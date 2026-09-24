using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal sealed record NpcCatalogEntry4229938(
    uint Id,
    string Name,
    uint GeneralModelId,
    uint AgentPersonaId,
    uint AnimSetTag,
    uint BehaviorActionConfigId,
    uint ActionGroupId,
    uint AiSettingId,
    uint InteractSettingId);

internal static class NpcCatalog4229938
{
    
    
    
    
    private const uint GenericMonsterPersona = 45210000u;

    private static readonly Lazy<Dictionary<uint, NpcCatalogEntry4229938>> Cache = new(Load);

    internal static bool TryGet(uint id, out NpcCatalogEntry4229938 entry)
        => Cache.Value.TryGetValue(id, out entry!);

    internal static NpcCatalogEntry4229938? Find(uint id)
        => Cache.Value.TryGetValue(id, out var entry) ? entry : null;

    private static Dictionary<uint, NpcCatalogEntry4229938> Load()
    {
        var root = PrivateServerConfigStore.ResolveProjectPath(PrivateServerConfigStore.Current.Paths.ClientConfigs);

        var personas = LoadPersonas(root);

        var path = Path.Combine(root, "AgentConfig.json");
        using var doc = JsonDocument.Parse(File.ReadAllText(path));
        if (!doc.RootElement.TryGetProperty("records", out var records) || records.ValueKind != JsonValueKind.Array)
            throw new InvalidDataException($"AgentConfig does not contain records: {path}");

        var result = new Dictionary<uint, NpcCatalogEntry4229938>();
        foreach (var row in records.EnumerateArray())
        {
            if (!row.TryGetProperty("Id", out var idNode) || !idNode.TryGetUInt32(out var id) || id == 0)
                continue;

            static uint U32(JsonElement source, string propertyName)
                => source.TryGetProperty(propertyName, out var node) && node.TryGetUInt32(out var value) ? value : 0;

            var name = row.TryGetProperty("Name", out var n) && n.ValueKind == JsonValueKind.String
                ? n.GetString() ?? ""
                : "";

            var sex = U32(row, "SexType");
            var age = U32(row, "Age");
            var economicLevel = U32(row, "EconomicLevel");
            var faction = U32(row, "Faction");
            var jobTag = U32(row, "JobTag");
            var enemyRank = U32(row, "EnemyClassType");
            var skillAction = row.TryGetProperty("AgentSkillAction", out var sk) && sk.ValueKind == JsonValueKind.String
                ? sk.GetString() ?? ""
                : "";
            
            var isMonster = enemyRank != 0 || skillAction.Contains("怪物技能", StringComparison.Ordinal);

            var animSetTag = U32(row, "AnimStereotype");
            if (animSetTag == 0)
                animSetTag = U32(row, "BattleAnimType");

            result[id] = new(
                id,
                name,
                U32(row, "GeneralModelId"),
                ResolvePersona(personas, sex, age, economicLevel, faction, jobTag, enemyRank, isMonster),
                animSetTag,
                U32(row, "Action"),
                U32(row, "ActionGroupId"),
                U32(row, "AI"),
                U32(row, "InteractSetting"));
        }

        Console.WriteLine(
            $"[NPCCATALOG] AgentConfig 已载入 {result.Count} 条"
            + $"（persona 表 {personas.Count} 条 · 含 AI / InteractSetting）");
        return result;
    }

    
    
    
    
    
    
    
    
    
    private static uint ResolvePersona(
        IReadOnlyList<PersonaRow> personas,
        uint sex,
        uint age,
        uint economicLevel,
        uint faction,
        uint jobTag,
        uint enemyRank,
        bool isMonster)
    {
        var ageBand = AgeBand(age);

        PersonaRow? best = null;
        var bestScore = -1;
        foreach (var p in personas)
        {
            if (!p.Matches(sex, ageBand, economicLevel, faction, jobTag, enemyRank))
                continue;
            if (p.Specificity > bestScore || (p.Specificity == bestScore && best is not null && p.Id < best.Id))
            {
                best = p;
                bestScore = p.Specificity;
            }
        }
        if (best is not null)
            return best.Id;

        if (isMonster)
            return GenericMonsterPersona;

        
        var refined = economicLevel >= 3;
        return (sex, ageBand, refined) switch
        {
            (1, 1, false) => 45200003u,
            (2, 1, false) => 45200004u,
            (1, 2, false) => 45200007u,
            (2, 2, false) => 45200008u,
            (1, 2, true) => 45200009u,
            (2, 2, true) => 45200010u,
            (1, 3, false) => 45200011u,
            (2, 3, false) => 45200012u,
            (1, 3, true) => 45200013u,
            (2, 3, true) => 45200014u,
            _ => GenericMonsterPersona,
        };
    }

    
    private static uint AgeBand(uint age)
        => age < 18 ? 1u : age < 45 ? 2u : 3u;

    private static List<PersonaRow> LoadPersonas(string root)
    {
        var rows = new List<PersonaRow>();
        var path = Path.Combine(root, "AgentPersonaConfig.json");
        if (!File.Exists(path))
        {
            Console.WriteLine($"[NPCCATALOG] 缺少 AgentPersonaConfig.json（{path}），persona 只能走兜底");
            return rows;
        }

        using var doc = JsonDocument.Parse(File.ReadAllText(path));
        if (!doc.RootElement.TryGetProperty("records", out var records) || records.ValueKind != JsonValueKind.Array)
            return rows;

        foreach (var row in records.EnumerateArray())
        {
            if (!row.TryGetProperty("Id", out var idNode) || !idNode.TryGetUInt32(out var id) || id == 0)
                continue;

            static uint[] U32List(JsonElement source, string propertyName)
                => source.TryGetProperty(propertyName, out var node) && node.ValueKind == JsonValueKind.Array
                    ? node.EnumerateArray().Where(x => x.TryGetUInt32(out _)).Select(x => x.GetUInt32()).ToArray()
                    : [];

            rows.Add(new PersonaRow(
                id,
                U32List(row, "SexType"),
                U32List(row, "Age"),
                U32List(row, "JobTag"),
                U32List(row, "EconomicLevel"),
                U32List(row, "EnemyRank"),
                U32List(row, "Faction")));
        }
        return rows;
    }

    
    private sealed record PersonaRow(
        uint Id,
        uint[] SexType,
        uint[] Age,
        uint[] JobTag,
        uint[] EconomicLevel,
        uint[] EnemyRank,
        uint[] Faction)
    {
        
        internal int Specificity { get; } =
            (SexType.Length > 0 ? 1 : 0)
            + (Age.Length > 0 ? 1 : 0)
            + (JobTag.Length > 0 ? 1 : 0)
            + (EconomicLevel.Length > 0 ? 1 : 0)
            + (EnemyRank.Length > 0 ? 1 : 0)
            + (Faction.Length > 0 ? 1 : 0);

        internal bool Matches(
            uint sex, uint ageBand, uint economicLevel, uint faction, uint jobTag, uint enemyRank)
            => Fits(SexType, sex)
            && Fits(Age, ageBand)
            && Fits(EconomicLevel, economicLevel)
            && Fits(Faction, faction)
            && Fits(JobTag, jobTag)
            && Fits(EnemyRank, enemyRank);

        private static bool Fits(uint[] condition, uint value)
            => condition.Length == 0 || condition.Contains(value);
    }
}
