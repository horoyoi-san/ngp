using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal static class PoliceAppCatalog4229938
{
    
    internal sealed record DispatchRow(uint Id, string Name, uint Number, bool ShowInApp, uint JobId);

    
    internal sealed record FineRow(uint Id, string Title, uint Drop, bool IsShow, uint Type);

    private static readonly object Sync = new();
    private static List<DispatchRow>? _dispatch;
    private static Dictionary<uint, FineRow>? _fines;

    private static string Root => PrivateServerConfigStore.ResolveProjectPath(
        PrivateServerConfigStore.Current.Paths.ClientConfigs);

    
    internal static IReadOnlyList<DispatchRow> AllDispatches
    {
        get { EnsureLoaded(); lock (Sync) return _dispatch!; }
    }

    
    
    
    
    
    
    
    
    internal static IReadOnlyList<DispatchRow> AppDispatches
    {
        get { EnsureLoaded(); lock (Sync) return _dispatch!.Where(x => x.ShowInApp).ToArray(); }
    }

    
    internal static FineRow? Fine(uint fineId)
    {
        EnsureLoaded();
        lock (Sync)
            return _fines!.TryGetValue(fineId, out var v) ? v : null;
    }

    
    internal static IReadOnlyList<FineRow> AllFines
    {
        get { EnsureLoaded(); lock (Sync) return _fines!.Values.OrderBy(x => x.Id).ToArray(); }
    }

    internal static string Summary()
    {
        EnsureLoaded();
        lock (Sync)
            return $"PoliceDispatchConfig={_dispatch!.Count}（App 显示 {_dispatch.Count(x => x.ShowInApp)}）"
                + $" / PoliceFineConfig={_fines!.Count}";
    }

    private static void EnsureLoaded()
    {
        if (_dispatch is not null)
            return;

        lock (Sync)
        {
            if (_dispatch is not null)
                return;

            var dispatches = new List<DispatchRow>();
            var fines = new Dictionary<uint, FineRow>();
            var root = Root;

            ForEachRecord(root, "PoliceDispatchConfig.json", row =>
            {
                var id = U32(row, "Id");
                if (id == 0)
                    return;
                dispatches.Add(new DispatchRow(
                    id,
                    Str(row, "Name") ?? string.Empty,
                    U32(row, "Number"),
                    Bool(row, "ShowInApp"),
                    U32(row, "JobId")));
            });

            ForEachRecord(root, "PoliceFineConfig.json", row =>
            {
                var id = U32(row, "Id");
                if (id == 0)
                    return;
                fines[id] = new FineRow(
                    id,
                    Str(row, "Title") ?? string.Empty,
                    U32(row, "Drop"),
                    Bool(row, "IsShow"),
                    U32(row, "Type"));
            });

            _dispatch = [.. dispatches.OrderBy(x => x.Id)];
            _fines = fines;

            Console.WriteLine($"[POLICEAPP] {Summary()}");
        }
    }

    
    
    
    

    private static void ForEachRecord(string root, string fileName, Action<JsonElement> visit)
    {
        var path = Path.Combine(root, fileName);
        if (!File.Exists(path))
        {
            Console.WriteLine($"[POLICEAPP] 缺少配置 {fileName}（NCCA App 内容会不完整）");
            return;
        }

        try
        {
            using var document = JsonDocument.Parse(File.ReadAllText(path));
            if (!document.RootElement.TryGetProperty("records", out var records)
                || records.ValueKind != JsonValueKind.Array)
            {
                Console.WriteLine($"[POLICEAPP] {fileName} 没有 records 数组");
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
            Console.WriteLine($"[POLICEAPP] 读取 {fileName} 失败: {ex.Message}");
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

    
    private static bool Bool(JsonElement row, string name)
        => row.TryGetProperty(name, out var v) && v.ValueKind == JsonValueKind.True;
}
