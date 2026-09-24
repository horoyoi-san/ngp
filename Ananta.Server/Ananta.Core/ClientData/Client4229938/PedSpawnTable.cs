using System.Globalization;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal sealed record PedSpawnPoint(
    int WaitAreaIndex,
    int SlotIndex,
    float X, float Y, float Z,
    float ForwardX, float ForwardZ,
    uint UrbanDiversityConfigId)
{
    
    internal float FacingDeg
    {
        get
        {
            var len = MathF.Sqrt(ForwardX * ForwardX + ForwardZ * ForwardZ);
            return len < 1e-4f ? 0f : MathF.Atan2(ForwardX, ForwardZ) * (180f / MathF.PI);
        }
    }
}

internal static class PedSpawnTable
{
    private static readonly Lazy<IReadOnlyList<PedSpawnPoint>> Cache = new(Load);

    internal static IReadOnlyList<PedSpawnPoint> Points => Cache.Value;

    internal static int Count => Cache.Value.Count;

    
    
    
    
    
    
    internal static IReadOnlyList<PedSpawnPoint> Near(
        float x, float z, float radius, int max, Func<PedSpawnPoint, bool>? accept = null)
    {
        if (max <= 0)
            return [];

        var r2 = radius * radius;
        var hits = new List<(float Dist2, PedSpawnPoint Point)>();
        foreach (var p in Cache.Value)
        {
            if (accept is not null && !accept(p))
                continue;
            var d2 = (p.X - x) * (p.X - x) + (p.Z - z) * (p.Z - z);
            if (d2 <= r2)
                hits.Add((d2, p));
        }

        hits.Sort(static (a, b) => a.Dist2.CompareTo(b.Dist2));
        var take = Math.Min(max, hits.Count);
        var result = new List<PedSpawnPoint>(take);
        for (var i = 0; i < take; i++)
            result.Add(hits[i].Point);
        return result;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static IReadOnlyList<PedSpawnPoint> NearSpread(
        float x, float z, float radius, int max,
        Func<PedSpawnPoint, bool>? accept = null,
        int maxPerArea = 2)
    {
        if (max <= 0)
            return [];

        var r2 = radius * radius;
        var hits = new List<(float Dist2, PedSpawnPoint Point)>();
        foreach (var p in Cache.Value)
        {
            if (accept is not null && !accept(p))
                continue;
            var d2 = (p.X - x) * (p.X - x) + (p.Z - z) * (p.Z - z);
            if (d2 <= r2)
                hits.Add((d2, p));
        }

        hits.Sort(static (a, b) => a.Dist2.CompareTo(b.Dist2));

        
        var result = new List<PedSpawnPoint>(Math.Min(max, hits.Count));
        var perArea = new Dictionary<int, int>();
        foreach (var (_, p) in hits)
        {
            if (result.Count >= max)
                break;
            perArea.TryGetValue(p.WaitAreaIndex, out var n);
            if (n >= maxPerArea)
                continue;
            perArea[p.WaitAreaIndex] = n + 1;
            result.Add(p);
        }

        
        if (result.Count < max)
        {
            var taken = new HashSet<long>(result.Select(SlotKey));
            foreach (var (_, p) in hits)
            {
                if (result.Count >= max)
                    break;
                if (taken.Add(SlotKey(p)))
                    result.Add(p);
            }
        }
        return result;
    }

    
    internal static long SlotKey(PedSpawnPoint p)
        => ((long)p.WaitAreaIndex << 32) | (uint)p.SlotIndex;

    private static IReadOnlyList<PedSpawnPoint> Load()
    {
        var path = PrivateServerConfigStore.ResolveProjectPath(
            PrivateServerConfigStore.Current.Paths.PedSpawns);
        if (!File.Exists(path))
            throw new InvalidDataException(
                $"人群站位表不存在: {path}\n"
                + "请先运行 `python tools/gen_ped_spawns.py` 从 WorldDump 生成。");

        var points = new List<PedSpawnPoint>(8 * 1024);
        using var reader = new StreamReader(path);
        if (reader.ReadLine() is null)
            throw new InvalidDataException($"人群站位表为空: {path}");

        var lineNo = 1;
        while (reader.ReadLine() is { } line)
        {
            lineNo++;
            if (line.Length == 0)
                continue;
            var parts = line.Split(',');
            if (parts.Length < 8)
                throw new InvalidDataException($"人群站位表第 {lineNo} 行字段不足（{parts.Length} < 8）: {line}");

            int I(int i) => int.Parse(parts[i], CultureInfo.InvariantCulture);
            float F(int i) => float.Parse(parts[i], CultureInfo.InvariantCulture);

            points.Add(new PedSpawnPoint(
                I(0), I(1), F(2), F(3), F(4), F(5), F(6), uint.Parse(parts[7], CultureInfo.InvariantCulture)));
        }

        if (points.Count == 0)
            throw new InvalidDataException($"人群站位表只有表头、没有数据: {path}");

        return points;
    }
}
