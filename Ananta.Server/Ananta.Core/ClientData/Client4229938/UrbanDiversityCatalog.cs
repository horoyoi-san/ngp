using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal static class UrbanDiversityCatalog
{
    private static readonly Lazy<Dictionary<uint, uint[]>> Cache = new(Load);

    
    internal static IReadOnlyDictionary<uint, uint[]> PersonaPools => Cache.Value;

    
    
    
    
    internal static uint? PickPersona(uint urbanDiversityConfigId, Random rng)
    {
        if (!Cache.Value.TryGetValue(urbanDiversityConfigId, out var pool) || pool.Length == 0)
            return null;
        return pool[rng.Next(pool.Length)];
    }

    internal static (int Areas, int DistinctPersonas) ProbePool()
    {
        var pools = Cache.Value;
        var distinct = new HashSet<uint>();
        foreach (var p in pools.Values)
            foreach (var v in p) distinct.Add(v);
        return (pools.Count, distinct.Count);
    }

    private static Dictionary<uint, uint[]> Load()
    {
        var root = PrivateServerConfigStore.ResolveProjectPath(
            PrivateServerConfigStore.Current.Paths.ClientConfigs);
        var path = Path.Combine(root, "UrbanDiversityConfig.json");
        if (!File.Exists(path))
            return [];

        using var doc = JsonDocument.Parse(File.ReadAllText(path));
        if (!doc.RootElement.TryGetProperty("records", out var records)
            || records.ValueKind != JsonValueKind.Array)
            return [];

        var result = new Dictionary<uint, uint[]>();
        foreach (var row in records.EnumerateArray())
        {
            if (!row.TryGetProperty("Id", out var idNode) || !idNode.TryGetUInt32(out var id) || id == 0)
                continue;
            if (!row.TryGetProperty("AgentNpcFilter", out var filter) || filter.ValueKind != JsonValueKind.Array)
                continue;

            
            var expanded = new List<uint>();
            foreach (var item in filter.EnumerateArray())
            {
                if (!item.TryGetProperty("agentPersonaId", out var pNode) || !pNode.TryGetUInt32(out var persona) || persona == 0)
                    continue;
                var weight = item.TryGetProperty("weight", out var wNode) && wNode.TryGetInt32(out var w)
                    ? Math.Clamp(w, 1, 100)
                    : 1;
                for (var i = 0; i < weight; i++)
                    expanded.Add(persona);
            }

            if (expanded.Count > 0)
                result[id] = [.. expanded];
        }

        return result;
    }
}
