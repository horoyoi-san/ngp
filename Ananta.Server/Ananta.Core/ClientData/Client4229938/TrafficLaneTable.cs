using System.Globalization;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal sealed record TrafficLane(
    int LaneId,
    float StartX, float StartY, float StartZ,
    float EndX, float EndY, float EndZ,
    float Length,
    int ZoneIndex,
    float SpeedLimit,
    int[] NextLaneIds,
    int LeftLaneId,
    int RightLaneId)
{
    
    
    
    

    
    internal float Width { get; init; }

    
    
    
    
    
    
    
    
    
    
    
    internal IReadOnlySet<string> TagNames { get; init; } = new HashSet<string>();

    
    internal float AvgNextSpeed { get; init; }

    
    
    
    
    
    
    internal int NonAlleyNext { get; init; }

    
    internal int NonAlleyLast { get; init; }

    
    internal int Flags { get; init; }

    
    internal int[] MergingLaneIds { get; init; } = [];

    
    internal int[] SplittingLaneIds { get; init; } = [];

    
    internal int[] LastLaneIds { get; init; } = [];

    
    internal (float X, float Z) Direction
    {
        get
        {
            var dx = EndX - StartX;
            var dz = EndZ - StartZ;
            var len = MathF.Sqrt(dx * dx + dz * dz);
            return len < 1e-4f ? (0f, 1f) : (dx / len, dz / len);
        }
    }

    
    internal bool HasNext => NextLaneIds.Length > 0;

    
    internal bool IsCenterGuideRoad => TagNames.Contains("CenterGuideRoad");

    
    
    
    
    
    
    internal bool IsAlley => TagNames.Contains("VehicleAlley") || TagNames.Contains("CapillaryRoad");

    
    internal bool IsFreeway => TagNames.Contains("Freeway");

    
    internal bool IsIntersectionLane => TagNames.Contains("Intersection");

    
    
    
    
    
    internal (float X, float Y, float Z, float FacingDeg) AtDistance(float distance)
    {
        var len = Length > 1e-3f ? Length : 1e-3f;
        var t = Math.Clamp(distance / len, 0f, 1f);
        var x = StartX + (EndX - StartX) * t;
        var y = StartY + (EndY - StartY) * t;
        var z = StartZ + (EndZ - StartZ) * t;
        var (dx, dz) = Direction;
        
        var facing = MathF.Atan2(dx, dz) * (180f / MathF.PI);
        return (x, y, z, facing);
    }
}

internal static class TrafficLaneTable
{
    private static readonly Lazy<IReadOnlyList<TrafficLane>> Cache = new(Load);

    internal static IReadOnlyList<TrafficLane> Lanes => Cache.Value;

    internal static int Count => Cache.Value.Count;

    
    internal static int DrivableCount => Cache.Value.Count(static l => l.HasNext);

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static IReadOnlyList<TrafficLane> Near(
        float x, float z, float radius, int max,
        Func<TrafficLane, bool>? accept = null,
        float minDistance = 0f,
        bool preferInbound = false)
    {
        if (max <= 0)
            return [];

        var r2 = radius * radius;
        var min2 = minDistance * minDistance;
        var hits = new List<(float Key, TrafficLane Lane)>();
        foreach (var lane in Cache.Value)
        {
            if (!lane.HasNext)
                continue;
            if (accept is not null && !accept(lane))
                continue;
            
            var cx = (lane.StartX + lane.EndX) * 0.5f;
            var cz = (lane.StartZ + lane.EndZ) * 0.5f;
            var dx = cx - x;
            var dz = cz - z;
            var d2 = dx * dx + dz * dz;
            if (d2 > r2)
                continue;
            if (d2 < min2)
                continue;                       

            
            var key = d2;
            if (preferInbound)
            {
                var vx = lane.EndX - lane.StartX;
                var vz = lane.EndZ - lane.StartZ;
                var len = MathF.Sqrt(vx * vx + vz * vz);
                var inbound = len > 0.01f && ((-dx) * (vx / len) + (-dz) * (vz / len)) > 0.2f;
                if (!inbound)
                    key += 1e9f;                
            }
            hits.Add((key, lane));
        }

        hits.Sort(static (a, b) => a.Key.CompareTo(b.Key));
        var take = Math.Min(max, hits.Count);
        var result = new List<TrafficLane>(take);
        for (var i = 0; i < take; i++)
            result.Add(hits[i].Lane);
        return result;
    }

    
    
    
    
    
    
    
    internal static (int Total, int Drivable, int Alley, int CenterGuide, int IntersectionTag,
                     int Freeway, int OneWay, string Sample)
        ProbeLaneTags()
    {
        var all = Cache.Value;
        var sample = all.Count == 0 ? "(空)" : $"{all[0].LaneId}: {string.Join("|", all[0].TagNames)}";
        return (all.Count,
            all.Count(static l => l.HasNext),
            all.Count(static l => l.IsAlley),
            all.Count(static l => l.IsCenterGuideRoad),
            all.Count(static l => l.IsIntersectionLane),
            all.Count(static l => l.IsFreeway),
            all.Count(static l => l.TagNames.Contains("OneWayStreet")),
            sample);
    }

    
    internal static TrafficLane? TryGet(int laneId)
        => laneId >= 0 && laneId < Cache.Value.Count && Cache.Value[laneId].LaneId == laneId
            ? Cache.Value[laneId]
            : null;

    private static IReadOnlyList<TrafficLane> Load()
    {
        var root = PrivateServerConfigStore.ResolveProjectPath(PrivateServerConfigStore.Current.Paths.ZoneGraphLanes);
        if (!File.Exists(root))
            throw new InvalidDataException(
                $"车道表不存在: {root}\n"
                + "请先运行 `python tools/gen_zonegraph_lanes.py` 从 WorldDump 生成。"
                + "没有这张表就无法给出合法的 LaneHandle，氛围车流不可能显示。");

        var lanes = new List<TrafficLane>(16 * 1024);
        using var reader = new StreamReader(root);
        var header = reader.ReadLine();
        if (header is null)
            throw new InvalidDataException($"车道表为空: {root}");

        
        
        var columns = header.Split(',');
        int Col(string name) => Array.FindIndex(columns, c => c.Trim() == name);
        var iLen = Col("length");
        var iZone = Col("zone_index");
        var iSpeed = Col("speed_limit");
        var iNext = Col("next_lanes");
        var iLeft = Col("left_lane");
        var iRight = Col("right_lane");

        
        static int[] ParseIds(string s)
        {
            if (string.IsNullOrEmpty(s))
                return [];
            var tokens = s.Split(';', StringSplitOptions.RemoveEmptyEntries);
            var outIds = new int[tokens.Length];
            for (var k = 0; k < tokens.Length; k++)
                outIds[k] = int.Parse(tokens[k], CultureInfo.InvariantCulture);
            return outIds;
        }

        static IReadOnlySet<string> ParseTags(string s)
        {
            if (string.IsNullOrEmpty(s))
                return new HashSet<string>();
            return s.Split('|', StringSplitOptions.RemoveEmptyEntries).ToHashSet();
        }

        var lineNo = 1;
        while (reader.ReadLine() is { } line)
        {
            lineNo++;
            if (line.Length == 0)
                continue;
            var parts = line.Split(',');
            if (parts.Length < 7)
                throw new InvalidDataException($"车道表第 {lineNo} 行字段不足（{parts.Length} < 7）: {line}");

            float F(int i) => i >= 0 && i < parts.Length ? float.Parse(parts[i], CultureInfo.InvariantCulture) : 0f;
            int I(int i) => i >= 0 && i < parts.Length ? int.Parse(parts[i], CultureInfo.InvariantCulture) : 0;
            string S(int i) => i >= 0 && i < parts.Length ? parts[i] : string.Empty;

            var id = I(0);
            var length = F(iLen);
            var zone = I(iZone);
            var speed = F(iSpeed);
            var left = iLeft >= 0 ? I(iLeft) : -1;
            var right = iRight >= 0 ? I(iRight) : -1;

            int[] next = [];
            if (iNext >= 0 && iNext < parts.Length && parts[iNext].Length > 0)
                next = ParseIds(parts[iNext]);

            lanes.Add(new TrafficLane(id,
                F(1), F(2), F(3), F(4), F(5), F(6),
                length, zone, speed, next, left, right)
            {
                Width = F(Col("width")),
                TagNames = ParseTags(S(Col("tag_names"))),
                AvgNextSpeed = F(Col("avg_next_speed")),
                NonAlleyNext = I(Col("non_alley_next")),
                NonAlleyLast = I(Col("non_alley_last")),
                Flags = I(Col("flags")),
                MergingLaneIds = ParseIds(S(Col("merging_lanes"))),
                SplittingLaneIds = ParseIds(S(Col("splitting_lanes"))),
                LastLaneIds = ParseIds(S(Col("last_lanes"))),
            });
        }

        if (lanes.Count == 0)
            throw new InvalidDataException($"车道表只有表头、没有数据: {root}");

        
        for (var i = 0; i < lanes.Count; i++)
        {
            if (lanes[i].LaneId != i)
                throw new InvalidDataException(
                    $"车道表 LaneHandle 不是连续下标：第 {i} 行是 {lanes[i].LaneId}。"
                    + "客户端按 handle 直接索引车道数组，错位会导致车辆落到错误位置。");
        }

        return lanes;
    }
}
