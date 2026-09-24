using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal static class TaskEventCatalogRepository
{
    
    internal sealed record TaskEventRow(
        uint Id,
        string Name,
        string NameCn,
        uint StartTask,
        uint[] EndTasks,
        int Chapter,
        int SortOrder,
        int UrbanJob,
        int[] EventTag,
        int[] Tag);

    private static readonly object Sync = new();
    private static Dictionary<uint, TaskEventRow>? _rows;
    private static Dictionary<uint, uint[]>? _taskToEvents;
    private static Dictionary<uint, uint[]>? _eventTasks;

    
    internal static int Count
    {
        get { EnsureLoaded(); lock (Sync) return _rows!.Count; }
    }

    internal static bool TryGet(uint eventId, out TaskEventRow row)
    {
        EnsureLoaded();
        lock (Sync)
            return _rows!.TryGetValue(eventId, out row!);
    }

    
    internal static IReadOnlyList<uint> AllEventIds()
    {
        EnsureLoaded();
        lock (Sync)
            return _rows!.Values
                .OrderBy(x => x.SortOrder)
                .ThenBy(x => x.Id)
                .Select(x => x.Id)
                .ToArray();
    }

    
    internal static IReadOnlyList<uint> EventsForTask(uint taskId)
    {
        EnsureLoaded();
        lock (Sync)
            return _taskToEvents!.TryGetValue(taskId, out var v) ? v : [];
    }

    
    internal static IReadOnlyList<uint> TasksOf(uint eventId)
    {
        EnsureLoaded();
        lock (Sync)
            return _eventTasks!.TryGetValue(eventId, out var v) ? v : [];
    }

    
    internal static IEnumerable<TaskEventRow> Search(string? term, int limit = 200)
    {
        EnsureLoaded();
        lock (Sync)
        {
            var q = _rows!.Values.AsEnumerable();
            if (!string.IsNullOrWhiteSpace(term))
            {
                var needle = term.Trim();
                q = uint.TryParse(needle, out var exact)
                    ? q.Where(x => x.Id == exact
                        || x.Name.Contains(needle, StringComparison.OrdinalIgnoreCase)
                        || x.NameCn.Contains(needle, StringComparison.OrdinalIgnoreCase))
                    : q.Where(x => x.Name.Contains(needle, StringComparison.OrdinalIgnoreCase)
                        || x.NameCn.Contains(needle, StringComparison.OrdinalIgnoreCase));
            }
            return q.OrderBy(x => x.SortOrder).ThenBy(x => x.Id).Take(limit).ToArray();
        }
    }

    private static void EnsureLoaded()
    {
        if (_rows is not null)
            return;
        lock (Sync)
        {
            if (_rows is not null)
                return;

            _rows = [];
            _taskToEvents = [];
            _eventTasks = [];
            try
            {
                var config = PrivateServerConfigStore.Current;
                var root = PrivateServerConfigStore.ResolveProjectPath(config.Paths.ClientConfigs);
                var path = Path.Combine(root, "TaskEventConfig.json");
                if (!File.Exists(path))
                {
                    Console.WriteLine($"[TASKEVENT] 找不到 {path}；任务事件列表不可用"
                        + "（任务面板会一直是空的 —— 把客户端 TaskEventConfig.json 放到该目录）");
                    return;
                }

                using var document = JsonDocument.Parse(File.ReadAllText(path));
                if (!document.RootElement.TryGetProperty("records", out var records) ||
                    records.ValueKind != JsonValueKind.Array)
                {
                    Console.WriteLine($"[TASKEVENT] {path} 没有 records 数组");
                    return;
                }

                foreach (var row in records.EnumerateArray())
                {
                    if (!row.TryGetProperty("Id", out var idNode) || !idNode.TryGetUInt32(out var id) || id == 0)
                        continue;

                    var ends = ReadUIntArray(row, "EndTask");
                    var entry = new TaskEventRow(
                        id,
                        ReadString(row, "EventName") ?? string.Empty,
                        ReadString(row, "EventNameCN") ?? string.Empty,
                        ReadUInt32(row, "StartTask"),
                        ends,
                        ReadInt32(row, "Chapter"),
                        ReadInt32(row, "SortOrder"),
                        ReadInt32(row, "UrbanJob"),
                        ReadIntArray(row, "EventTag"),
                        ReadIntArray(row, "Tag"));
                    _rows[id] = entry;
                }

                
                foreach (var (id, row) in _rows)
                {
                    var chain = BuildChain(row);
                    _eventTasks![id] = chain;
                    foreach (var taskId in chain)
                    {
                        if (!_taskToEvents!.TryGetValue(taskId, out var list))
                            _taskToEvents[taskId] = list = [];
                        
                        if (Array.IndexOf(list, id) < 0)
                        {
                            var grown = new uint[list.Length + 1];
                            Array.Copy(list, grown, list.Length);
                            grown[^1] = id;
                            _taskToEvents[taskId] = grown;
                        }
                    }
                }

                Console.WriteLine($"[TASKEVENT] TaskEventConfig 已载入: {_rows.Count} 个事件, "
                    + $"{_taskToEvents.Count} 个任务能映射到事件, 来自 {path}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[TASKEVENT] 载入 TaskEventConfig 失败: {ex.Message}");
            }
        }
    }

    
    
    
    
    private static uint[] BuildChain(TaskEventRow row)
    {
        if (row.StartTask == 0)
            return [];

        var ends = new HashSet<uint>(row.EndTasks);
        var chain = new List<uint>();
        var seen = new HashSet<uint>();
        var current = row.StartTask;

        while (current != 0 && seen.Add(current) && chain.Count < 512)
        {
            chain.Add(current);
            if (ends.Contains(current))
                break;
            var next = TaskCatalogRepository.NextTasks(current);
            current = next.Length > 0 ? next[0] : 0u;
        }

        
        return [.. chain];
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

    private static int ReadInt32(JsonElement row, string name)
        => row.TryGetProperty(name, out var node) && node.TryGetInt32(out var v) ? v : 0;

    private static uint ReadUInt32(JsonElement row, string name)
        => row.TryGetProperty(name, out var node) && node.TryGetUInt32(out var v) ? v : 0u;

    private static uint[] ReadUIntArray(JsonElement row, string name)
    {
        if (!row.TryGetProperty(name, out var node) || node.ValueKind != JsonValueKind.Array)
            return [];
        return node.EnumerateArray()
            .Where(x => x.TryGetUInt32(out _))
            .Select(x => x.GetUInt32())
            .ToArray();
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
}
