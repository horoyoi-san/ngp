using System.Globalization;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal sealed record TrafficIntersection(
    int ZoneIndex,
    float X, float Y, float Z,
    int PeriodCount,
    byte CurrentPeriodIndex,
    byte NextPeriodIndex,
    byte RailPeriodIndex,
    IReadOnlyList<int[]> PeriodOpenLanes)
{
    
    public IReadOnlySet<int> AllLanes { get; } =
        PeriodOpenLanes.SelectMany(static a => a).ToHashSet();
}

internal static class IntersectionTable
{
    private static readonly Lazy<IReadOnlyList<TrafficIntersection>> Cache = new(Load);

    internal static IReadOnlyList<TrafficIntersection> All => Cache.Value;

    internal static int Count => Cache.Value.Count;

    private static readonly Lazy<IReadOnlyDictionary<int, int>> LaneOwner = new(() =>
    {
        var d = new Dictionary<int, int>();
        var all = Cache.Value;
        for (var i = 0; i < all.Count; i++)
            foreach (var lane in all[i].AllLanes)
                d[lane] = i;
        return d;
    });

    
    
    
    
    
    
    internal static bool TryGetLaneOwner(int laneId, out int intersectionIndex)
        => LaneOwner.Value.TryGetValue(laneId, out intersectionIndex);

    private static IReadOnlyList<TrafficIntersection> Load()
    {
        var path = PrivateServerConfigStore.ResolveProjectPath(
            PrivateServerConfigStore.Current.Paths.Intersections);

        
        if (!File.Exists(path))
            return [];

        var list = new List<TrafficIntersection>(512);
        using var reader = new StreamReader(path);
        if (reader.ReadLine() is null)
            return [];

        while (reader.ReadLine() is { } line)
        {
            if (line.Length == 0)
                continue;
            var parts = line.Split(',');
            if (parts.Length < 8)
                continue;

            float F(int i) => float.Parse(parts[i], CultureInfo.InvariantCulture);
            int I(int i) => int.Parse(parts[i], CultureInfo.InvariantCulture);

            var periodCount = I(4);
            
            var perPeriod = new int[Math.Max(periodCount, 0)][];
            for (var i = 0; i < perPeriod.Length; i++)
                perPeriod[i] = [];

            if (parts.Length > 9 && parts[9].Length > 0)
            {
                foreach (var chunk in parts[9].Split('|', StringSplitOptions.RemoveEmptyEntries))
                {
                    var colon = chunk.IndexOf(':');
                    if (colon <= 0)
                        continue;
                    if (!int.TryParse(chunk.AsSpan(0, colon), NumberStyles.Integer,
                            CultureInfo.InvariantCulture, out var pi))
                        continue;
                    if ((uint)pi >= (uint)perPeriod.Length)
                        continue;
                    var body = chunk[(colon + 1)..];
                    perPeriod[pi] = body.Length == 0
                        ? []
                        : body.Split(';', StringSplitOptions.RemoveEmptyEntries)
                            .Select(static s => int.Parse(s, CultureInfo.InvariantCulture))
                            .ToArray();
                }
            }

            list.Add(new TrafficIntersection(
                I(0), F(1), F(2), F(3),
                periodCount,
                (byte)I(5), (byte)I(6), (byte)I(7),
                perPeriod));
        }

        return list;
    }
}
