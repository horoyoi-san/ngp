using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal sealed record FashionCatalogEntry(
    uint Id, string Name, uint BelongSpiritId, bool IsDefault, bool IsShow, bool IsGet);

internal static class FashionCatalogRepository
{
    private static readonly Lazy<Dictionary<uint, FashionCatalogEntry>> Cache = new(Load);

    internal static IReadOnlyList<FashionCatalogEntry> All
        => Cache.Value.Values.OrderBy(x => x.BelongSpiritId).ThenBy(x => x.Id).ToArray();

    internal static IReadOnlyList<uint> AllIds => Cache.Value.Keys.OrderBy(x => x).ToArray();

    internal static IReadOnlyList<FashionCatalogEntry> ForSpirit(uint templateId)
        => Cache.Value.Values.Where(x => x.BelongSpiritId == templateId).OrderBy(x => x.Id).ToArray();

    internal static bool TryGet(uint id, out FashionCatalogEntry entry)
        => Cache.Value.TryGetValue(id, out entry!);

    private static Dictionary<uint, FashionCatalogEntry> Load()
    {
        var result = new Dictionary<uint, FashionCatalogEntry>();
        try
        {
            var root = PrivateServerConfigStore.ResolveProjectPath(PrivateServerConfigStore.Current.Paths.ClientConfigs);
            var path = Path.Combine(root, "FashionConfig.json");
            if (!File.Exists(path))
            {
                Console.WriteLine($"[FASHION-CATALOG] 找不到 {path}；衣橱只能列默认时装");
                return result;
            }

            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            if (!doc.RootElement.TryGetProperty("records", out var records) || records.ValueKind != JsonValueKind.Array)
            {
                Console.WriteLine($"[FASHION-CATALOG] {path} 没有 records 数组");
                return result;
            }

            static string Str(JsonElement row, string name)
                => row.TryGetProperty(name, out var n) && n.ValueKind == JsonValueKind.String ? n.GetString() ?? string.Empty : string.Empty;
            static bool Flag(JsonElement row, string name)
                => row.TryGetProperty(name, out var n) && n.ValueKind == JsonValueKind.True;

            foreach (var row in records.EnumerateArray())
            {
                if (!row.TryGetProperty("Id", out var idNode) || !idNode.TryGetUInt32(out var id) || id == 0)
                    continue;
                var spiritId = row.TryGetProperty("BelongSpiritId", out var s) && s.TryGetUInt32(out var sid) ? sid : 0u;
                var name = Str(row, "Name");
                result[id] = new FashionCatalogEntry(
                    id,
                    string.IsNullOrWhiteSpace(name) ? $"Fashion {id}" : name,
                    spiritId,
                    Flag(row, "IsDefault"), Flag(row, "IsShow"), Flag(row, "IsGet"));
            }

            Console.WriteLine($"[FASHION-CATALOG] FashionConfig 已载入: {result.Count} 件时装");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[FASHION-CATALOG] 载入失败: {ex.Message}");
        }
        return result;
    }
}
