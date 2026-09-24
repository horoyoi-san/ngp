using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal static class ActionItemCatalogRepository
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

    internal static int Count
    {
        get
        {
            EnsureLoaded();
            lock (Sync)
                return _ids!.Length;
        }
    }

    
    internal static string? Name(uint id)
    {
        EnsureLoaded();
        lock (Sync)
            return _names!.TryGetValue(id, out var v) ? v : null;
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
                var path = Path.Combine(root, "ActionItemConfig.json");
                if (!File.Exists(path))
                {
                    Console.WriteLine($"[ACTIONS] 找不到 ActionItemConfig: {path}");
                    return;
                }

                using var doc = JsonDocument.Parse(File.ReadAllText(path));
                if (!doc.RootElement.TryGetProperty("records", out var records)
                    || records.ValueKind != JsonValueKind.Array)
                {
                    Console.WriteLine("[ACTIONS] ActionItemConfig 没有 records 数组");
                    return;
                }

                var ids = new List<uint>();
                foreach (var row in records.EnumerateArray())
                {
                    if (!row.TryGetProperty("Id", out var idNode) || !idNode.TryGetUInt32(out var id) || id == 0)
                        continue;
                    ids.Add(id);
                    if (row.TryGetProperty("Name", out var nameNode) && nameNode.ValueKind == JsonValueKind.String)
                        _names[id] = nameNode.GetString() ?? string.Empty;
                }

                _ids = [.. ids.Distinct().OrderBy(x => x)];
                Console.WriteLine($"[ACTIONS] ActionItemConfig 已载入: {_ids.Length} 个动作");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ACTIONS] 载入 ActionItemConfig 失败: {ex.Message}");
            }
        }
    }
}
