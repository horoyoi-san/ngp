using System.Globalization;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal sealed record StaticNpcSpawnPoint(
    int Index,
    float X, float Y, float Z,
    float ForwardX, float ForwardZ,
    uint UrbanDiversityConfigId,
    int LaneIndex)
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

internal static class StaticNpcSpawnTable
{
    private static readonly Lazy<IReadOnlyList<StaticNpcSpawnPoint>> Cache = new(Load);

    internal static IReadOnlyList<StaticNpcSpawnPoint> Points => Cache.Value;

    internal static int Count => Cache.Value.Count;

    
    
    
    
    
    
    internal static IReadOnlyList<StaticNpcSpawnPoint> Near(
        float x, float z, float radius, int max, Func<StaticNpcSpawnPoint, bool>? accept = null)
    {
        if (max <= 0)
            return [];

        var r2 = radius * radius;
        var hits = new List<(float Dist2, StaticNpcSpawnPoint Point)>();
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
        var result = new List<StaticNpcSpawnPoint>(take);
        for (var i = 0; i < take; i++)
            result.Add(hits[i].Point);
        return result;
    }

    
    internal static long SlotKey(StaticNpcSpawnPoint p) => p.Index;

    private static IReadOnlyList<StaticNpcSpawnPoint> Load()
    {
        var path = PrivateServerConfigStore.ResolveProjectPath(
            PrivateServerConfigStore.Current.Paths.StaticNpcSpawns);
        if (!File.Exists(path))
            throw new InvalidDataException(
                $"固定 NPC 站位表不存在: {path}\n"
                + "请先运行 `python tools/gen_static_npc_points.py` 从 WorldDump 生成。");

        var points = new List<StaticNpcSpawnPoint>(1024);
        using var reader = new StreamReader(path);
        if (reader.ReadLine() is null)
            throw new InvalidDataException($"固定 NPC 站位表为空: {path}");

        var lineNo = 1;
        while (reader.ReadLine() is { } line)
        {
            lineNo++;
            if (line.Length == 0)
                continue;
            var parts = line.Split(',');
            if (parts.Length < 8)
                throw new InvalidDataException(
                    $"固定 NPC 站位表第 {lineNo} 行字段不足（{parts.Length} < 8）: {line}");

            int I(int i) => int.Parse(parts[i], CultureInfo.InvariantCulture);
            float F(int i) => float.Parse(parts[i], CultureInfo.InvariantCulture);

            points.Add(new StaticNpcSpawnPoint(
                I(0), F(1), F(2), F(3), F(4), F(5),
                uint.Parse(parts[6], CultureInfo.InvariantCulture), I(7)));
        }

        if (points.Count == 0)
            throw new InvalidDataException($"固定 NPC 站位表只有表头、没有数据: {path}");

        return points;
    }
}
