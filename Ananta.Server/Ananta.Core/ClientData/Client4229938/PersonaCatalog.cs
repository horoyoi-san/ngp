using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal static class PersonaCatalog
{
    
    
    
    
    
    
    
    
    internal sealed record PersonaEntry(
        uint Id,
        string Name,
        IReadOnlyList<int> SexTypes,
        IReadOnlyList<int> AgeTags,
        IReadOnlyList<int> JobTags,
        IReadOnlyList<int> LaunchProperties,
        IReadOnlyList<int> EconomicLevels,
        IReadOnlyList<int> BelongingTypes);

    private static readonly Lazy<IReadOnlyDictionary<uint, PersonaEntry>> Cache = new(Load);

    internal static IReadOnlyDictionary<uint, PersonaEntry> All => Cache.Value;

    internal static int Count => Cache.Value.Count;

    internal static PersonaEntry? Find(uint personaId)
        => Cache.Value.TryGetValue(personaId, out var e) ? e : null;

    private static IReadOnlyDictionary<uint, PersonaEntry> Load()
    {
        var result = new Dictionary<uint, PersonaEntry>();
        try
        {
            var root = PrivateServerConfigStore.ResolveProjectPath(
                PrivateServerConfigStore.Current.Paths.ClientConfigs);
            var path = Path.Combine(root, "AgentPersonaConfig.json");
            if (!File.Exists(path))
                return result;

            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            if (!doc.RootElement.TryGetProperty("records", out var records)
                || records.ValueKind != JsonValueKind.Array)
                return result;

            foreach (var row in records.EnumerateArray())
            {
                if (!row.TryGetProperty("Id", out var idNode) || !idNode.TryGetUInt32(out var id) || id == 0)
                    continue;

                result[id] = new PersonaEntry(
                    id,
                    row.TryGetProperty("Name", out var n) ? n.GetString() ?? string.Empty : string.Empty,
                    ReadIntList(row, "SexType"),
                    ReadIntList(row, "Age"),
                    ReadIntList(row, "JobTag"),
                    
                    ReadIntList(row, "LaunchProprety"),
                    ReadIntList(row, "EconomicLevel"),
                    ReadIntList(row, "BelongingType"));
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[PERSONA] AgentPersonaConfig 载入失败: {ex.Message}");
        }

        return result;
    }

    private static IReadOnlyList<int> ReadIntList(JsonElement row, string name)
    {
        if (!row.TryGetProperty(name, out var node) || node.ValueKind != JsonValueKind.Array)
            return [];
        var list = new List<int>(node.GetArrayLength());
        foreach (var item in node.EnumerateArray())
        {
            if (item.ValueKind == JsonValueKind.Number && item.TryGetInt32(out var v))
                list.Add(v);
        }
        return list;
    }
}
