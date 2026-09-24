using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal static class BehaviorTaskCatalog
{
    internal sealed record BehaviorTask(
        uint Id,
        int AnimState,
        int BehaviorLayer,
        int ActionSelector,
        int PostureTag,
        IReadOnlyList<int> MainActionIds);

    private static readonly Lazy<IReadOnlyList<BehaviorTask>> Cache = new(Load);

    internal static IReadOnlyList<BehaviorTask> All => Cache.Value;

    internal static int Count => Cache.Value.Count;

    
    
    
    
    
    
    
    internal static BehaviorTask? FirstByAnimState(int animState)
        => Cache.Value.FirstOrDefault(t => t.AnimState == animState && t.MainActionIds.Count > 0);

    
    
    
    
    internal static uint CrowdTaskId => FirstByAnimState(1)?.Id ?? 0;

    
    
    
    
    internal static uint VehicleNpcTaskId => FirstByAnimState(3)?.Id ?? 0;

    private static IReadOnlyList<BehaviorTask> Load()
    {
        var result = new List<BehaviorTask>(512);
        try
        {
            var root = PrivateServerConfigStore.ResolveProjectPath(
                PrivateServerConfigStore.Current.Paths.ClientConfigs);
            var path = Path.Combine(root, "AetherNpcBehaviorTaskDefineConfig.json");
            if (!File.Exists(path))
            {
                Console.WriteLine($"[BEHAVIOR] 找不到 {path}（行为任务自动挑选将不可用）");
                return result;
            }

            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            if (!doc.RootElement.TryGetProperty("records", out var recs)
                || recs.ValueKind != JsonValueKind.Array)
                return result;

            foreach (var r in recs.EnumerateArray())
            {
                if (!r.TryGetProperty("Id", out var idNode) || !idNode.TryGetUInt32(out var id) || id == 0)
                    continue;

                var mains = new List<int>(8);
                if (r.TryGetProperty("MainActionIds", out var m)
                    && m.ValueKind == JsonValueKind.Array)
                {
                    foreach (var x in m.EnumerateArray())
                        if (x.ValueKind == JsonValueKind.Number && x.TryGetInt32(out var v))
                            mains.Add(v);
                }

                result.Add(new BehaviorTask(
                    id,
                    r.TryGetProperty("AnimState", out var a) && a.TryGetInt32(out var av) ? av : -1,
                    r.TryGetProperty("BehaviorLayer", out var l) && l.TryGetInt32(out var lv) ? lv : -1,
                    r.TryGetProperty("ActionSelector", out var s) && s.TryGetInt32(out var sv) ? sv : -1,
                    r.TryGetProperty("BehaviorPostureGameplayTag", out var p) && p.TryGetInt32(out var pv) ? pv : -1,
                    mains));
            }

            result.Sort(static (a, b) => a.Id.CompareTo(b.Id));
            
            
            
            Console.WriteLine($"[BEHAVIOR] AetherNpcBehaviorTaskDefineConfig 已载入 {result.Count} 条"
                              + $"（带动作 {result.Count(static t => t.MainActionIds.Count > 0)} 条）");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[BEHAVIOR] 载入失败: {ex.Message}");
        }
        return result;
    }

    
    internal static (int Count, uint Crowd, uint Vehicle, string Detail) Probe()
    {
        var all = All;
        var byState = all.GroupBy(static t => t.AnimState)
            .OrderBy(static g => g.Key)
            .Select(static g => $"{g.Key}:{g.Count()}");
        var lines = new List<string>
        {
            "  AnimState 分布(None0/Default1/Sitting2/Driving3/Riding4/Impacted5/Interacting6/Sick7) = "
            + string.Join(" ", byState),
        };
        foreach (var st in new[] { 1, 3, 5, 6 })
        {
            var t = FirstByAnimState(st);
            if (t is null) { lines.Add($"  AnimState={st} → (无)"); continue; }
            lines.Add($"  AnimState={st} → Id={t.Id} Layer={t.BehaviorLayer} "
                      + $"Selector={t.ActionSelector} Posture={t.PostureTag} "
                      + $"MainActionIds=[{string.Join(",", t.MainActionIds.Take(4))}]");
        }
        return (all.Count, CrowdTaskId, VehicleNpcTaskId, string.Join('\n', lines));
    }
}
