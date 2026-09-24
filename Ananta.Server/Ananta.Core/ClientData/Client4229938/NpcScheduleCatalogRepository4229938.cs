using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal static class NpcScheduleCatalogRepository4229938
{
    
    internal sealed record TimeTableRow(uint AgentTag, int Slot1, int Slot2, int Slot3, int Slot4, uint LifeScheduleType);

    
    internal sealed record ActivityRow(
        uint Id,
        uint AgentTag,
        uint Raid,
        string Performance,
        string Info,
        uint Icon,
        string MapName,
        IReadOnlyDictionary<int, int> SlotPriority);

    private static readonly object Sync = new();
    private static List<TimeTableRow>? _timeTables;
    private static Dictionary<uint, ActivityRow>? _activities;

    private static string Root => PrivateServerConfigStore.ResolveProjectPath(
        PrivateServerConfigStore.Current.Paths.ClientConfigs);

    
    internal static IReadOnlyList<TimeTableRow> AllTimeTables
    {
        get { EnsureLoaded(); lock (Sync) return _timeTables!; }
    }

    
    internal static TimeTableRow? TimeTable(uint agentTag)
    {
        EnsureLoaded();
        lock (Sync)
            return _timeTables!.FirstOrDefault(x => x.AgentTag == agentTag);
    }

    
    internal static ActivityRow? ActivityForSlot(uint agentTag, int slot)
    {
        EnsureLoaded();
        lock (Sync)
            return _activities!.Values
                .Where(x => x.AgentTag == agentTag && x.SlotPriority.ContainsKey(slot))
                .OrderByDescending(x => x.SlotPriority[slot])
                .ThenBy(x => x.Id)
                .FirstOrDefault();
    }

    internal static string Summary()
    {
        EnsureLoaded();
        lock (Sync)
            return $"AgentDataSetsTimeTableConfig={_timeTables!.Count} 个角色"
                + $" / AgentDataSetsActivityConfig={_activities!.Count} 条活动";
    }

    private static void EnsureLoaded()
    {
        if (_timeTables is not null)
            return;

        lock (Sync)
        {
            if (_timeTables is not null)
                return;

            var tables = new List<TimeTableRow>();
            var activities = new Dictionary<uint, ActivityRow>();
            var root = Root;

            ForEachRecord(root, "AgentDataSetsTimeTableConfig.json", row =>
            {
                var tag = U32(row, "AgentTag");
                if (tag == 0)
                    return;
                tables.Add(new TimeTableRow(
                    tag,
                    (int)U32(row, "Schedule1"),
                    (int)U32(row, "Schedule2"),
                    (int)U32(row, "Schedule3"),
                    (int)U32(row, "Schedule4"),
                    U32(row, "LifeScheduleType")));
            });

            ForEachRecord(root, "AgentDataSetsActivityConfig.json", row =>
            {
                var id = U32(row, "Id");
                if (id == 0)
                    return;
                activities[id] = new ActivityRow(
                    id,
                    U32(row, "AgentTag"),
                    U32(row, "Raid"),
                    Str(row, "ActivityPerformance") ?? string.Empty,
                    Str(row, "Info") ?? string.Empty,
                    U32(row, "Icon"),
                    Str(row, "MapName") ?? string.Empty,
                    ReadSlotPriority(row, "Schedule"));
            });

            _timeTables = [.. tables.OrderBy(x => x.AgentTag)];
            _activities = activities;

            Console.WriteLine($"[NPCSCHED] {Summary()}");
        }
    }

    
    private static IReadOnlyDictionary<int, int> ReadSlotPriority(JsonElement row, string name)
    {
        var map = new Dictionary<int, int>();
        if (!row.TryGetProperty(name, out var arr) || arr.ValueKind != JsonValueKind.Array)
            return map;

        foreach (var item in arr.EnumerateArray())
        {
            if (item.ValueKind != JsonValueKind.Object)
                continue;
            if (!item.TryGetProperty("Index", out var idx) || idx.ValueKind != JsonValueKind.Number)
                continue;
            var index = idx.GetInt32();
            var priority = item.TryGetProperty("Priority", out var p) && p.ValueKind == JsonValueKind.Number
                ? p.GetInt32()
                : 0;
            map[index] = priority;
        }
        return map;
    }

    
    
    
    
    
    
    
    internal static int HhmmToDaySecond(int hhmm)
    {
        if (hhmm <= 0)
            return 0;
        var hour = hhmm / 100;
        var minute = hhmm % 100;
        if (hour > 23 || minute > 59)
            return 0;
        return hour * 3600 + minute * 60;
    }

    

    private static void ForEachRecord(string root, string fileName, Action<JsonElement> visit)
    {
        var path = Path.Combine(root, fileName);
        if (!File.Exists(path))
        {
            Console.WriteLine($"[NPCSCHED] 缺少配置 {fileName}（角色邀约内容会不完整）");
            return;
        }

        try
        {
            using var document = JsonDocument.Parse(File.ReadAllText(path));
            if (!document.RootElement.TryGetProperty("records", out var records)
                || records.ValueKind != JsonValueKind.Array)
            {
                Console.WriteLine($"[NPCSCHED] {fileName} 没有 records 数组");
                return;
            }

            foreach (var row in records.EnumerateArray())
            {
                if (row.ValueKind == JsonValueKind.Object)
                    visit(row);
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[NPCSCHED] 读取 {fileName} 失败: {ex.Message}");
        }
    }

    private static uint U32(JsonElement row, string name)
        => row.TryGetProperty(name, out var v) && v.ValueKind == JsonValueKind.Number
            ? v.GetUInt32()
            : 0u;

    private static string? Str(JsonElement row, string name)
        => row.TryGetProperty(name, out var v) && v.ValueKind == JsonValueKind.String
            ? v.GetString()
            : null;
}
