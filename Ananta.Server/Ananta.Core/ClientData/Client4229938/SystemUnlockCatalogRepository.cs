using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal static class SystemUnlockCatalogRepository
{
    private static readonly object Sync = new();
    private static uint[]? _ids;
    private static Dictionary<uint, string>? _names;

    
    internal static uint[] AllIds()
    {
        EnsureLoaded();
        lock (Sync)
            return _ids!;
    }

    internal static string? Name(uint id)
    {
        EnsureLoaded();
        lock (Sync)
            return _names!.TryGetValue(id, out var v) ? v : null;
    }

    
    internal static uint[] FindByDescription(string keyword)
    {
        EnsureLoaded();
        lock (Sync)
            return _names!
                .Where(x => x.Value.Contains(keyword, StringComparison.OrdinalIgnoreCase))
                .Select(x => x.Key)
                .OrderBy(x => x)
                .ToArray();
    }

    private static void EnsureLoaded()
    {
        if (_ids is not null)
            return;
        lock (Sync)
        {
            if (_ids is not null)
                return;

            _ids = [];
            _names = [];
            try
            {
                var config = PrivateServerConfigStore.Current;
                var root = PrivateServerConfigStore.ResolveProjectPath(config.Paths.ClientConfigs);
                var path = Path.Combine(root, "SystemUnlockConfig.json");
                if (!File.Exists(path))
                {
                    Console.WriteLine($"[SYSTEMS] 找不到 SystemUnlockConfig: {path}");
                    return;
                }

                using var doc = JsonDocument.Parse(File.ReadAllText(path));
                if (!doc.RootElement.TryGetProperty("records", out var records)
                    || records.ValueKind != JsonValueKind.Array)
                {
                    Console.WriteLine("[SYSTEMS] SystemUnlockConfig 没有 records 数组");
                    return;
                }

                var ids = new List<uint>();
                foreach (var row in records.EnumerateArray())
                {
                    if (!row.TryGetProperty("Id", out var idNode) || !idNode.TryGetUInt32(out var id) || id == 0)
                        continue;
                    ids.Add(id);
                    if (row.TryGetProperty("Description", out var desc) && desc.ValueKind == JsonValueKind.String)
                        _names[id] = desc.GetString() ?? string.Empty;
                }

                _ids = [.. ids.Distinct().OrderBy(x => x)];
                Console.WriteLine($"[SYSTEMS] SystemUnlockConfig 已载入: {_ids.Length} 个系统");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SYSTEMS] 载入 SystemUnlockConfig 失败: {ex.Message}");
            }
        }
    }
}
