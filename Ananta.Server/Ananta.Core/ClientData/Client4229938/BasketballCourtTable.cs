using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal sealed record BasketballCourt(
    ulong UniqueId,
    int PathId,
    string Prefab,
    string Scene,
    float X, float Y, float Z,
    float EulerY)
{
    
    internal const int PathScene = 2101575199;

    
    internal const int PathRaid = 165664243;

    
    
    
    
    
    
    
    
    
    internal bool Playable { get; init; }

    
    internal uint BasketballId { get; init; }

    
    internal int ConfigId { get; init; }

    internal float DistanceTo(float x, float z)
    {
        var dx = X - x;
        var dz = Z - z;
        return MathF.Sqrt(dx * dx + dz * dz);
    }
}

internal static class BasketballCourtTable
{
    private static readonly Lazy<IReadOnlyList<BasketballCourt>> Cache = new(Load);

    internal static IReadOnlyList<BasketballCourt> All => Cache.Value;

    internal static int Count => Cache.Value.Count;

    
    internal static IReadOnlyList<BasketballCourt> Playable
        => Cache.Value.Where(static c => c.Playable).ToArray();

    
    internal static BasketballCourt? Nearest(float x, float z, bool playableOnly = false)
    {
        BasketballCourt? best = null;
        var bestD = float.MaxValue;
        foreach (var c in Cache.Value)
        {
            if (playableOnly && !c.Playable)
                continue;
            var d = c.DistanceTo(x, z);
            if (d < bestD)
            {
                bestD = d;
                best = c;
            }
        }
        return best;
    }

    internal static BasketballCourt? TryGetPlayable(int configId)
        => Cache.Value.FirstOrDefault(c => c.Playable && c.ConfigId == configId);

    private static IReadOnlyList<BasketballCourt> Load()
    {
        var result = new List<BasketballCourt>(64);
        try
        {
            var cfg = PrivateServerConfigStore.Current;
            var path = PrivateServerConfigStore.ResolveProjectPath(cfg.Paths.BasketballCourts);
            if (!File.Exists(path))
            {
                Console.WriteLine($"[BASKETBALL] 找不到球场表 {path}"
                                  + "（跑 tools/gen_basketball_courts.py 生成）");
                return result;
            }

            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            var root = doc.RootElement;
            if (!root.TryGetProperty("courts", out var courts)
                || courts.ValueKind != JsonValueKind.Array)
                return result;

            foreach (var c in courts.EnumerateArray())
            {
                if (!c.TryGetProperty("uniqueId", out var uidNode) || !uidNode.TryGetUInt64(out var uid))
                    continue;

                var court = new BasketballCourt(
                    uid,
                    c.TryGetProperty("pathId", out var p) && p.TryGetInt32(out var pv) ? pv : 0,
                    c.TryGetProperty("prefab", out var pf) ? pf.GetString() ?? "" : "",
                    c.TryGetProperty("scene", out var sc) ? sc.GetString() ?? "" : "",
                    c.TryGetProperty("x", out var x) && x.TryGetSingle(out var xv) ? xv : 0f,
                    c.TryGetProperty("y", out var y) && y.TryGetSingle(out var yv) ? yv : 0f,
                    c.TryGetProperty("z", out var z) && z.TryGetSingle(out var zv) ? zv : 0f,
                    c.TryGetProperty("eulerY", out var ey) && ey.TryGetSingle(out var eyv) ? eyv : 0f)
                {
                    Playable = c.TryGetProperty("playable", out var pl) && pl.ValueKind == JsonValueKind.True,
                    BasketballId = c.TryGetProperty("basketballId", out var bid) && bid.TryGetUInt32(out var bv) ? bv : 0u,
                    ConfigId = c.TryGetProperty("configId", out var cid) && cid.TryGetInt32(out var cv) ? cv : 0,
                };
                result.Add(court);
            }

            Console.WriteLine($"[BASKETBALL] 球场表已载入 {result.Count} 个"
                              + $"（可对局 {result.Count(static c => c.Playable)} 个，"
                              + $"世界 {result.Count(static c => c.PathId == BasketballCourt.PathScene)} 个，"
                              + $"raid {result.Count(static c => c.PathId == BasketballCourt.PathRaid)} 个）");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[BASKETBALL] 球场表载入失败: {ex.GetType().Name}: {ex.Message}");
        }

        return result;
    }
}
