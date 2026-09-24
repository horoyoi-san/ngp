using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal static class TaskCatalogRepository
{
    private static readonly object Sync = new();
    private static Dictionary<uint, string>? _names;
    private static Dictionary<uint, string>? _titles;
    private static Dictionary<uint, string>? _descriptions;
    private static Dictionary<uint, int[]>? _counters;
    private static Dictionary<uint, string[]>? _objectives;
    private static Dictionary<uint, uint[]>? _nextTasks;
    private static Dictionary<uint, int>? _titleIds;
    private static Dictionary<uint, uint>? _relatedRaids;

    
    
    
    
    
    
    
    
    internal static uint[] NextTasks(uint taskId)
    {
        EnsureLoaded();
        lock (Sync)
            return _nextTasks!.TryGetValue(taskId, out var value) ? value : [];
    }

    
    internal static int TitleId(uint taskId)
    {
        EnsureLoaded();
        lock (Sync)
            return _titleIds!.TryGetValue(taskId, out var value) ? value : 0;
    }

    
    
    
    
    
    
    
    internal static uint RelatedRaid(uint taskId)
    {
        EnsureLoaded();
        lock (Sync)
            return _relatedRaids!.TryGetValue(taskId, out var value) ? value : 0u;
    }

    
    
    
    internal static IReadOnlyList<uint> ChainFrom(uint rootId, int maxLength = 200)
    {
        EnsureLoaded();
        var chain = new List<uint>();
        var seen = new HashSet<uint>();
        var current = rootId;
        while (current != 0 && seen.Add(current) && chain.Count < maxLength)
        {
            chain.Add(current);
            var next = NextTasks(current);
            current = next.Length > 0 ? next[0] : 0u;
        }
        return chain;
    }

    
    
    
    
    
    
    
    
    internal static int[] Counters(uint taskId)
    {
        EnsureLoaded();
        lock (Sync)
            return _counters!.TryGetValue(taskId, out var value) ? value : [];
    }

    
    internal static string[] Objectives(uint taskId)
    {
        EnsureLoaded();
        lock (Sync)
            return _objectives!.TryGetValue(taskId, out var value) ? value : [];
    }

    internal static IReadOnlyDictionary<uint, string> Names
    {
        get { EnsureLoaded(); lock (Sync) return new Dictionary<uint, string>(_names!); }
    }

    internal static int Count
    {
        get { EnsureLoaded(); lock (Sync) return _names!.Count; }
    }

    internal static string? Name(uint taskId)
    {
        EnsureLoaded();
        lock (Sync)
            return _names!.TryGetValue(taskId, out var value) ? value : null;
    }

    internal static string? Title(uint taskId)
    {
        EnsureLoaded();
        lock (Sync)
            return _titles!.TryGetValue(taskId, out var value) ? value : null;
    }

    internal static string? Description(uint taskId)
    {
        EnsureLoaded();
        lock (Sync)
            return _descriptions!.TryGetValue(taskId, out var value) ? value : null;
    }

    
    internal static IEnumerable<(uint Id, string Name)> Search(string? term, int limit = 200)
    {
        EnsureLoaded();
        lock (Sync)
        {
            var query = _names!.AsEnumerable();
            if (!string.IsNullOrWhiteSpace(term))
            {
                var needle = term.Trim();
                query = uint.TryParse(needle, out var exact)
                    ? query.Where(x => x.Key == exact || x.Value.Contains(needle, StringComparison.OrdinalIgnoreCase))
                    : query.Where(x => x.Value.Contains(needle, StringComparison.OrdinalIgnoreCase));
            }

            return query.OrderBy(x => x.Key).Take(limit).Select(x => (x.Key, x.Value)).ToArray();
        }
    }

    private static void EnsureLoaded()
    {
        if (_names is not null)
            return;
        lock (Sync)
        {
            if (_names is not null)
                return;

            _names = [];
            _titles = [];
            _descriptions = [];
            _counters = [];
            _objectives = [];
            _nextTasks = [];
            _titleIds = [];
            _relatedRaids = [];
            try
            {
                var config = PrivateServerConfigStore.Current;
                var root = PrivateServerConfigStore.ResolveProjectPath(config.Paths.ClientConfigs);
                var path = Path.Combine(root, "TaskConfig.json");
                if (!File.Exists(path))
                {
                    Console.WriteLine($"[TASKS] 找不到 {path}；任务名不可用");
                    return;
                }

                using var document = JsonDocument.Parse(File.ReadAllText(path));
                if (!document.RootElement.TryGetProperty("records", out var records) ||
                    records.ValueKind != JsonValueKind.Array)
                {
                    Console.WriteLine($"[TASKS] {path} 没有 records 数组");
                    return;
                }

                foreach (var row in records.EnumerateArray())
                {
                    if (!row.TryGetProperty("Id", out var idNode) || !idNode.TryGetUInt32(out var id) || id == 0)
                        continue;
                    var name = ReadString(row, "Name");
                    if (!string.IsNullOrWhiteSpace(name))
                        _names[id] = name!;
                    var title = ReadString(row, "Title");
                    if (!string.IsNullOrWhiteSpace(title))
                        _titles[id] = title!;
                    var description = ReadString(row, "WorkDescription");
                    if (!string.IsNullOrWhiteSpace(description))
                        _descriptions[id] = description!;

                    var counters = ReadIntArray(row, "Counter");
                    if (counters.Length > 0)
                        _counters[id] = counters;
                    var objectives = ReadStringArray(row, "EventObjective");
                    if (objectives.Length > 0)
                        _objectives[id] = objectives;

                    var next = ReadUIntArray(row, "NextTasks");
                    if (next.Length > 0)
                        _nextTasks[id] = next;
                    _titleIds[id] = ReadInt32(row, "Title");
                    _relatedRaids[id] = ReadUInt32(row, "RelatedRaid");
                }

                Console.WriteLine($"[TASKS] TaskConfig 已载入: {_names.Count} 个具名任务, {_counters.Count} 个带计数, 来自 {path}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[TASKS] 载入 TaskConfig 失败: {ex.Message}");
            }
        }
    }

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

    private static int[] ReadIntArray(JsonElement row, string name)
    {
        if (!row.TryGetProperty(name, out var node) || node.ValueKind != JsonValueKind.Array)
            return [];
        return node.EnumerateArray()
            .Where(x => x.TryGetInt32(out _))
            .Select(x => x.GetInt32())
            .ToArray();
    }

    private static int ReadInt32(JsonElement row, string name)
        => row.TryGetProperty(name, out var node) && node.TryGetInt32(out var value) ? value : 0;

    private static uint ReadUInt32(JsonElement row, string name)
        => row.TryGetProperty(name, out var node) && node.TryGetUInt32(out var value) ? value : 0u;

    private static uint[] ReadUIntArray(JsonElement row, string name)
    {
        if (!row.TryGetProperty(name, out var node) || node.ValueKind != JsonValueKind.Array)
            return [];
        return node.EnumerateArray()
            .Where(x => x.TryGetUInt32(out _))
            .Select(x => x.GetUInt32())
            .ToArray();
    }

    private static string[] ReadStringArray(JsonElement row, string name)
    {
        if (!row.TryGetProperty(name, out var node) || node.ValueKind != JsonValueKind.Array)
            return [];
        return node.EnumerateArray()
            .Where(x => x.ValueKind == JsonValueKind.String)
            .Select(x => x.GetString() ?? string.Empty)
            .ToArray();
    }
}
