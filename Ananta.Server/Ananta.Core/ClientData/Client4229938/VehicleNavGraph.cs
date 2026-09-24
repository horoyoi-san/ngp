using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal static class VehicleNavGraph
{
    
    internal const uint FlagAlley = 1u << 0;
    internal const uint FlagOneWay = 1u << 1;
    internal const uint FlagMainRoad = 1u << 2;
    internal const uint FlagIntersection = 1u << 3;
    internal const uint FlagShoulder = 1u << 4;
    internal const uint FlagCenterGuide = 1u << 5;

    
    internal const uint LinkFlagOpposite = 1u << 0;
    internal const uint LinkFlagLeft = 1u << 1;
    internal const uint LinkFlagRight = 1u << 2;
    internal const uint LinkFlagSplitting = 1u << 3;
    internal const uint LinkFlagMerging = 1u << 4;

    
    private const float AlleyGlobalDistanceScale = 2f;
    private const float AlleyFixedPenalty = 35f;
    private const float ReverseSwitchPenalty = 35f;

    
    private const float SrcLaneSearchRadius = 5f;

    
    private const float SrcLaneFallbackRadius = 40f;

    
    private const float HeadingWeight = 12f;

    private const uint Magic = 0x47564E41;   
    private const int SupportedVersion = 2;
    private const int LaneRecordSize = 40;
    private const int LinkRecordSize = 8;
    private const int HeaderSize = 24;

    private const int MaxExpansions = 200_000;
    private const float MinPointSpacing = 0.25f;

    private static readonly object LoadGate = new();
    private static bool _loaded;
    private static string _status = "未载入";

    private static int[] _pointsBegin = [];
    private static int[] _pointsEnd = [];
    private static int[] _succBegin = [];
    private static int[] _succEnd = [];
    private static float[] _length = [];
    private static uint[] _flags = [];
    private static int[] _centerLane = [];
    private static float[] _px = [];
    private static float[] _py = [];
    private static float[] _pz = [];
    private static int[] _succ = [];
    private static uint[] _linkFlags = [];

    internal static bool IsLoaded { get { EnsureLoaded(); return _pointsBegin.Length > 0; } }
    internal static int LaneCount { get { EnsureLoaded(); return _pointsBegin.Length; } }
    internal static int PointCount { get { EnsureLoaded(); return _px.Length; } }
    internal static int EdgeCount { get { EnsureLoaded(); return _succ.Length; } }
    internal static string Status { get { EnsureLoaded(); return _status; } }

    internal static void EnsureLoaded()
    {
        if (_loaded)
            return;
        lock (LoadGate)
        {
            if (_loaded)
                return;
            _loaded = true;
            Load();
        }
    }

    private static void Load()
    {
        try
        {
            var cfg = PrivateServerConfigStore.Current;
            var path = PrivateServerConfigStore.ResolveProjectPath(cfg.Paths.VehicleNavGraph);
            if (!File.Exists(path))
            {
                _status = $"找不到 {path}（跑 tools/gen_vehicle_nav_graph.py 生成）";
                Console.WriteLine($"[VEHNAV] {_status}");
                return;
            }

            var raw = File.ReadAllBytes(path);
            if (raw.Length < HeaderSize)
            {
                _status = "文件长度不足头部";
                Console.WriteLine($"[VEHNAV] {_status}");
                return;
            }

            var magic = BitConverter.ToUInt32(raw, 0);
            var version = BitConverter.ToInt32(raw, 4);
            var laneCount = BitConverter.ToInt32(raw, 8);
            var pointCount = BitConverter.ToInt32(raw, 12);
            var linkCount = BitConverter.ToInt32(raw, 16);

            if (magic != Magic || version != SupportedVersion || laneCount <= 0 || pointCount <= 0)
            {
                _status = $"头部非法 magic=0x{magic:X8} ver={version}（期望 {SupportedVersion}）"
                          + $" lanes={laneCount} points={pointCount}"
                          + " —— 旧版文件请重跑 tools/gen_vehicle_nav_graph.py";
                Console.WriteLine($"[VEHNAV] {_status}");
                return;
            }

            var expected = HeaderSize
                           + (long)laneCount * LaneRecordSize
                           + (long)pointCount * 12
                           + (long)linkCount * LinkRecordSize;
            if (raw.LongLength != expected)
            {
                _status = $"长度不符 期望 {expected} 实际 {raw.LongLength}";
                Console.WriteLine($"[VEHNAV] {_status}");
                return;
            }

            var pointsBegin = new int[laneCount];
            var pointsEnd = new int[laneCount];
            var succBegin = new int[laneCount];
            var succEnd = new int[laneCount];
            var length = new float[laneCount];
            var flags = new uint[laneCount];
            var centerLane = new int[laneCount];

            var off = HeaderSize;
            for (var i = 0; i < laneCount; i++, off += LaneRecordSize)
            {
                var laneId = BitConverter.ToInt32(raw, off);
                if (laneId != i)
                {
                    _status = $"laneId[{i}]={laneId} 与下标不符";
                    Console.WriteLine($"[VEHNAV] {_status}");
                    return;
                }
                pointsBegin[i] = BitConverter.ToInt32(raw, off + 4);
                pointsEnd[i] = BitConverter.ToInt32(raw, off + 8);
                succBegin[i] = BitConverter.ToInt32(raw, off + 12);
                succEnd[i] = BitConverter.ToInt32(raw, off + 16);
                length[i] = BitConverter.ToSingle(raw, off + 20);
                flags[i] = BitConverter.ToUInt32(raw, off + 24);
                centerLane[i] = BitConverter.ToInt32(raw, off + 32);
            }

            var px = new float[pointCount];
            var py = new float[pointCount];
            var pz = new float[pointCount];
            for (var i = 0; i < pointCount; i++, off += 12)
            {
                px[i] = BitConverter.ToSingle(raw, off);
                py[i] = BitConverter.ToSingle(raw, off + 4);
                pz[i] = BitConverter.ToSingle(raw, off + 8);
            }

            var succ = new int[linkCount];
            var linkFlags = new uint[linkCount];
            for (var i = 0; i < linkCount; i++, off += LinkRecordSize)
            {
                succ[i] = BitConverter.ToInt32(raw, off);
                linkFlags[i] = BitConverter.ToUInt32(raw, off + 4);
            }

            _pointsBegin = pointsBegin;
            _pointsEnd = pointsEnd;
            _succBegin = succBegin;
            _succEnd = succEnd;
            _length = length;
            _flags = flags;
            _centerLane = centerLane;
            _px = px;
            _py = py;
            _pz = pz;
            _succ = succ;
            _linkFlags = linkFlags;

            var drivable = 0;
            var withCenter = 0;
            var dead = 0;
            for (var i = 0; i < laneCount; i++)
            {
                if (IsDrivable(i))
                    drivable++;
                if (centerLane[i] != 0)
                    withCenter++;
                if (succBegin[i] == succEnd[i])
                    dead++;
            }

            _status = $"已载入 v{version} {laneCount} 车道 / {pointCount} 点 / {linkCount} 边"
                      + $"（可行驶 {drivable}，有中心线 {withCenter}，死胡同 {dead}）";
            Console.WriteLine($"[VEHNAV] {_status}");
        }
        catch (Exception ex)
        {
            _status = $"载入失败 {ex.GetType().Name}: {ex.Message}";
            Console.WriteLine($"[VEHNAV] {_status}");
        }
    }

    

    
    
    
    
    private static bool IsDrivable(int lane) => (_flags[lane] & FlagCenterGuide) == 0;

    private static bool HasOutgoing(int lane) => _succBegin[lane] < _succEnd[lane];

    private static int PointCountOfLane(int lane) => _pointsEnd[lane] - _pointsBegin[lane];

    
    private static float DistanceToLaneXZ(int lane, float x, float z)
    {
        var best = float.MaxValue;
        for (var i = _pointsBegin[lane]; i < _pointsEnd[lane] - 1; i++)
        {
            var ax = _px[i];
            var az = _pz[i];
            var vx = _px[i + 1] - ax;
            var vz = _pz[i + 1] - az;
            var wx = x - ax;
            var wz = z - az;
            var len2 = vx * vx + vz * vz;
            var t = len2 <= 1e-6f ? 0f : Math.Clamp((wx * vx + wz * vz) / len2, 0f, 1f);
            var dx = x - (ax + t * vx);
            var dz = z - (az + t * vz);
            var d = dx * dx + dz * dz;
            if (d < best)
                best = d;
        }
        return best >= float.MaxValue ? float.MaxValue : MathF.Sqrt(best);
    }

    
    private static (float X, float Z) LaneDirection(int lane)
    {
        var b = _pointsBegin[lane];
        var e = _pointsEnd[lane] - 1;
        var dx = _px[e] - _px[b];
        var dz = _pz[e] - _pz[b];
        var m = MathF.Sqrt(dx * dx + dz * dz);
        return m <= 1e-4f ? (0f, 0f) : (dx / m, dz / m);
    }

    
    private static int NearestPointIndex(int lane, float x, float z)
    {
        var b = _pointsBegin[lane];
        var e = _pointsEnd[lane];
        var best = b;
        var bestD = float.MaxValue;
        for (var i = b; i < e; i++)
        {
            var dx = _px[i] - x;
            var dz = _pz[i] - z;
            var d = dx * dx + dz * dz;
            if (d < bestD)
            {
                bestD = d;
                best = i;
            }
        }
        return best;
    }

    

    
    internal static bool TrySnapTarget(float x, float z, out int lane, out float distance,
        IReadOnlyList<int>? candidates = null)
    {
        EnsureLoaded();
        lane = -1;
        distance = float.MaxValue;
        if (_pointsBegin.Length == 0)
            return false;

        if (candidates is null)
        {
            for (var i = 0; i < _pointsBegin.Length; i++)
            {
                if (!IsDrivable(i))
                    continue;
                var d = DistanceToLaneXZ(i, x, z);
                if (d < distance)
                {
                    distance = d;
                    lane = i;
                }
            }
        }
        else
        {
            foreach (var i in candidates)
            {
                if (!IsDrivable(i))
                    continue;
                var d = DistanceToLaneXZ(i, x, z);
                if (d < distance)
                {
                    distance = d;
                    lane = i;
                }
            }
        }
        return lane >= 0;
    }

    
    
    
    
    
    
    
    
    
    
    
    internal static bool TrySnapStart(float x, float z, float yawDegrees, int preferredLane,
        out int lane, out float distance)
    {
        EnsureLoaded();
        lane = -1;
        distance = float.MaxValue;
        if (_pointsBegin.Length == 0)
            return false;

        if (preferredLane >= 0 && preferredLane < _pointsBegin.Length
            && IsDrivable(preferredLane))
        {
            var pd = DistanceToLaneXZ(preferredLane, x, z);
            if (pd <= StartHysteresisMeters)
            {
                lane = preferredLane;
                distance = pd;
                return true;
            }
        }

        var yaw = yawDegrees * (MathF.PI / 180f);
        var hx = MathF.Sin(yaw);
        var hz = MathF.Cos(yaw);

        
        
        
        if (TryPickStart(x, z, hx, hz, SrcLaneFallbackRadius, requireOutgoing: true,
                out lane, out distance))
            return true;
        if (TryPickStart(x, z, hx, hz, SrcLaneFallbackRadius, requireOutgoing: false,
                out lane, out distance))
            return true;
        return TrySnapTarget(x, z, out lane, out distance);
    }

    
    private const float StartHysteresisMeters = 20f;

    private static bool TryPickStart(float x, float z, float hx, float hz, float radius,
        bool requireOutgoing, out int lane, out float distance)
    {
        lane = -1;
        distance = float.MaxValue;
        var bestScore = float.MaxValue;
        var r2 = radius * radius;

        for (var i = 0; i < _pointsBegin.Length; i++)
        {
            if (!IsDrivable(i))
                continue;
            if (requireOutgoing && !HasOutgoing(i))
                continue;

            var d = DistanceToLaneXZ(i, x, z);
            if (d * d > r2)
                continue;

            var (dx, dz) = LaneDirection(i);
            var dot = dx * hx + dz * hz;      
            var score = d + (1f - dot) * HeadingWeight;

            if (score < bestScore)
            {
                bestScore = score;
                lane = i;
                distance = d;
            }
        }
        return lane >= 0;
    }

    
    internal static int[] ForwardReachable(int startLane)
    {
        EnsureLoaded();
        var seen = new bool[_pointsBegin.Length];
        var order = new List<int>(_pointsBegin.Length / 2);
        var stack = new Stack<int>();
        seen[startLane] = true;
        stack.Push(startLane);
        order.Add(startLane);
        while (stack.Count > 0)
        {
            var u = stack.Pop();
            for (var k = _succBegin[u]; k < _succEnd[u]; k++)
            {
                var v = _succ[k];
                if (v == u || v < 0 || v >= seen.Length || seen[v])
                    continue;
                seen[v] = true;
                stack.Push(v);
                order.Add(v);
            }
        }
        return order.ToArray();
    }

    

    private sealed class PathResult
    {
        internal PathResult(int[] lanes, float length)
        {
            Lanes = lanes;
            Length = length;
        }

        internal int[] Lanes { get; }
        internal float Length { get; }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private static float CostOf(int lane, int prevLane, uint linkFlags, bool penalizeAlley)
    {
        var cost = _length[lane];
        if (cost <= 0f)
            cost = 0.5f;
        if (penalizeAlley && (_flags[lane] & FlagAlley) != 0)
            cost = cost * AlleyGlobalDistanceScale + AlleyFixedPenalty;
        if ((linkFlags & LinkFlagOpposite) != 0)
            cost += ReverseSwitchPenalty;

        if (prevLane >= 0)
        {
            var (px, pz) = LaneDirection(prevLane);
            var (cx, cz) = LaneDirection(lane);
            var dot = px * cx + pz * cz;
            if (dot < 0f)
                cost += ReverseSwitchPenalty;                 
            else if (dot < 0.5f)
                cost += ReverseSwitchPenalty * 0.3f;          
        }
        return cost;
    }

    private static PathResult? AStar(int startLane, int goalLane, bool penalizeAlley, float startArc)
    {
        if (startLane == goalLane)
            return new PathResult([startLane], _length[startLane]);

        var n = _pointsBegin.Length;
        var g = new float[n];
        var parent = new int[n];
        Array.Fill(g, float.MaxValue);
        Array.Fill(parent, -1);

        var goalX = _px[_pointsBegin[goalLane]];
        var goalZ = _pz[_pointsBegin[goalLane]];

        var open = new PriorityQueue<int, float>();
        g[startLane] = 0f;
        open.Enqueue(startLane, Heuristic(startLane, goalX, goalZ));

        var expansions = 0;
        while (open.TryDequeue(out var cur, out _))
        {
            if (cur == goalLane)
            {
                var stack = new List<int>();
                for (var c = goalLane; c >= 0; c = parent[c])
                    stack.Add(c);
                stack.Reverse();

                var total = 0f;
                for (var i = 0; i < stack.Count; i++)
                {
                    var lf = i == 0 ? 0u : LinkFlagsOf(stack[i - 1], stack[i]);
                    var prev = i == 0 ? -1 : stack[i - 1];
                    total += CostOf(stack[i], prev, lf, penalizeAlley);
                }
                return new PathResult(stack.ToArray(), total);
            }

            if (++expansions > MaxExpansions)
                return null;

            var curG = g[cur];
            for (var k = _succBegin[cur]; k < _succEnd[cur]; k++)
            {
                var v = _succ[k];
                if (v < 0 || v >= n || v == cur)
                    continue;

                
                
                
                
                
                if (cur == startLane && startArc > 1f && !_startSuccessorFiltered)
                {
                    var jb = _pointsBegin[v];
                    var (_, _, junctionArc) = ProjectOntoPolylineArc(cur, _px[jb], _pz[jb]);
                    if (junctionArc < startArc - 1f)
                        continue;
                }

                var tentative = curG + CostOf(v, cur, _linkFlags[k], penalizeAlley);
                if (tentative >= g[v])
                    continue;
                g[v] = tentative;
                parent[v] = cur;
                open.Enqueue(v, tentative + Heuristic(v, goalX, goalZ));
            }
        }
        return null;
    }

    
    
    
    
    [ThreadStatic]
    private static bool _startSuccessorFiltered;

    private static uint LinkFlagsOf(int from, int to)
    {
        for (var k = _succBegin[from]; k < _succEnd[from]; k++)
            if (_succ[k] == to)
                return _linkFlags[k];
        return 0;
    }

    
    private static float Heuristic(int lane, float goalX, float goalZ)
    {
        var last = _pointsEnd[lane] - 1;
        if (last < _pointsBegin[lane])
            last = _pointsBegin[lane];
        var dx = _px[last] - goalX;
        var dz = _pz[last] - goalZ;
        return MathF.Sqrt(dx * dx + dz * dz);
    }

    

    
    internal readonly struct NavRequest
    {
        internal NavRequest(float startX, float startY, float startZ, float yaw,
            float targetX, float targetY, float targetZ,
            bool preferMainRoad, bool ignoreAlley, int preferredStartLane = -1,
            NavRouteState? previous = null)
        {
            StartX = startX;
            StartY = startY;
            StartZ = startZ;
            Yaw = yaw;
            TargetX = targetX;
            TargetY = targetY;
            TargetZ = targetZ;
            PreferMainRoad = preferMainRoad;
            IgnoreAlley = ignoreAlley;
            PreferredStartLane = preferredStartLane;
            Previous = previous;
        }

        internal float StartX { get; }
        internal float StartY { get; }
        internal float StartZ { get; }

        
        internal float Yaw { get; }

        internal float TargetX { get; }
        internal float TargetY { get; }
        internal float TargetZ { get; }

        
        internal bool PreferMainRoad { get; }

        
        internal bool IgnoreAlley { get; }

        
        internal int PreferredStartLane { get; }

        
        
        
        
        internal NavRouteState? Previous { get; init; }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    internal sealed class NavRouteState
    {
        internal int[] Lanes { get; init; } = [];

        internal float TargetX { get; init; }
        internal float TargetZ { get; init; }

        
        internal int StartLaneIndex { get; set; }
    }

    
    internal sealed class NavSolution
    {
        
        internal List<(float X, float Y, float Z)> Points { get; } = [];

        
        internal List<(float X, float Y, float Z)> CenterPoints { get; } = [];

        internal float Length { get; set; }
        internal int StartLane { get; set; } = -1;
        internal int TargetLane { get; set; } = -1;
        internal float StartSnapDistance { get; set; }
        internal float TargetSnapDistance { get; set; }
        internal int HopCount { get; set; }
        internal bool Routed { get; set; }

        
        internal bool ReusedRoute { get; set; }

        
        internal int ReusedLaneIndex { get; set; } = -1;

        
        internal float MaxRawLaneGap { get; set; }

        
        internal float MaxLaneSegment { get; set; }

        
        internal int[] RouteLanes { get; set; } = [];
    }

    
    
    
    
    internal static NavSolution? Solve(in NavRequest req)
    {
        EnsureLoaded();
        if (_pointsBegin.Length == 0)
            return null;

        var penalizeAlley = req.PreferMainRoad || req.IgnoreAlley;

        var solution = new NavSolution();
        if (!TrySnapStart(req.StartX, req.StartZ, req.Yaw, req.PreferredStartLane,
                out var startLane, out var startDist))
            return null;
        solution.StartLane = startLane;
        solution.StartSnapDistance = startDist;

        
        
        
        
        
        
        
        
        
        
        if (TryReuseRoute(req, startLane, out var reusedLanes, out var reusedIndex, out var reusedLane))
        {
            
            
            
            var trial = new NavSolution
            {
                StartLane = startLane,
                StartSnapDistance = startDist,
                Routed = true,
                ReusedRoute = true,
                ReusedLaneIndex = reusedIndex,
                TargetLane = reusedLanes![^1],
                TargetSnapDistance = DistanceToPolyline(reusedLanes[^1], req.TargetX, req.TargetZ),
            };
            trial.Points.Add((req.StartX, req.StartY, req.StartZ));
            FillFromLanes(trial, reusedLanes, req);
            AppendPoint(trial.Points, req.TargetX, req.TargetY, req.TargetZ);
            AppendPoint(trial.CenterPoints, req.TargetX, req.TargetY, req.TargetZ);

            if (MaxBacktrack(trial.Points, out _) <= 5f)
            {
                solution.Routed = true;
                solution.ReusedRoute = true;
                solution.ReusedLaneIndex = reusedIndex;
                solution.TargetLane = trial.TargetLane;
                solution.TargetSnapDistance = trial.TargetSnapDistance;
                solution.Points.AddRange(trial.Points);
                solution.CenterPoints.AddRange(trial.CenterPoints);
                solution.HopCount = reusedLanes.Length;
                solution.RouteLanes = reusedLanes;
                solution.MaxRawLaneGap = MaxRawGap(reusedLanes);
                solution.MaxLaneSegment = MaxLaneSegmentOf(reusedLanes);
                if (solution.Length <= 0f)
                    solution.Length = PolylineLength(solution.Points);
                return solution;
            }
        }

        var reachable = ForwardReachable(startLane);

        
        var targetLane = -1;
        var targetDist = float.MaxValue;
        if (TrySnapTarget(req.TargetX, req.TargetZ, out var reachLane, out var reachDist, reachable))
        {
            targetLane = reachLane;
            targetDist = reachDist;
        }

        
        if (targetLane < 0 || targetDist > MaxTargetSnapMeters)
        {
            if (TrySnapTarget(req.TargetX, req.TargetZ, out var anyLane, out var anyDist)
                && (targetLane < 0 || anyDist < targetDist))
            {
                targetLane = anyLane;
                targetDist = anyDist;
            }
        }

        if (targetLane < 0)
            return null;
        solution.TargetLane = targetLane;
        solution.TargetSnapDistance = targetDist;

        
        var (_, _, startArc) = ProjectOntoPolylineArc(startLane, req.StartX, req.StartZ);

        _startSuccessorFiltered = false;
        var path = AStar(startLane, targetLane, penalizeAlley, startArc);
        if (path is null)
        {
            
            _startSuccessorFiltered = true;
            path = AStar(startLane, targetLane, penalizeAlley, startArc);
        }

        solution.Points.Add((req.StartX, req.StartY, req.StartZ));

        if (path is not null)
        {
            FillFromLanes(solution, path.Lanes, req, path.Length);
        }
        else
        {
            
            var fallback = NearestReachableTo(reachable, req.TargetX, req.TargetZ);
            if (fallback >= 0)
            {
                var last = _pointsEnd[fallback] - 1;
                AppendPoint(solution.Points, _px[last], _py[last], _pz[last]);
                solution.HopCount = 1;
            }
        }

        AppendPoint(solution.Points, req.TargetX, req.TargetY, req.TargetZ);
        AppendPoint(solution.CenterPoints, req.TargetX, req.TargetY, req.TargetZ);

        if (solution.Length <= 0f)
            solution.Length = PolylineLength(solution.Points);
        return solution;
    }

    
    
    
    
    private static void FillFromLanes(NavSolution solution, int[] lanes, in NavRequest req, float length = 0f)
    {
        solution.Routed = true;
        solution.HopCount = lanes.Length;
        solution.Length = length;
        solution.RouteLanes = lanes;
        solution.MaxRawLaneGap = MaxRawGap(lanes);
        solution.MaxLaneSegment = MaxLaneSegmentOf(lanes);

        var hy = req.Yaw * (MathF.PI / 180f);
        var headingX = MathF.Sin(hy);
        var headingZ = MathF.Cos(hy);
        AppendRoutePolyline(solution.Points, lanes, useCenterLane: false,
            req.StartX, req.StartZ, req.TargetX, req.TargetZ, headingX, headingZ);
        AppendRoutePolyline(solution.CenterPoints, lanes, useCenterLane: true,
            req.StartX, req.StartZ, req.TargetX, req.TargetZ, headingX, headingZ);
    }

    
    private const float RouteReuseMaxOffsetMeters = 15f;

    
    private const float RouteReuseTargetEpsilonMeters = 2f;

    
    private const float RouteReuseLaneJitterMeters = 5f;

    
    private const int RouteReuseMaxAdvance = 8;

    
    
    
    
    
    
    
    
    
    
    
    
    private static bool TryReuseRoute(in NavRequest req, int snappedStartLane,
        out int[]? lanes, out int index, out int lane)
    {
        lanes = null;
        index = -1;
        lane = -1;

        var prev = req.Previous;
        if (prev is null || prev.Lanes.Length == 0)
            return false;
        if (MathF.Abs(prev.TargetX - req.TargetX) > RouteReuseTargetEpsilonMeters
            || MathF.Abs(prev.TargetZ - req.TargetZ) > RouteReuseTargetEpsilonMeters)
            return false;

        var from = Math.Clamp(prev.StartLaneIndex, 0, prev.Lanes.Length - 1);
        var to = Math.Min(prev.Lanes.Length - 1, from + RouteReuseMaxAdvance);

        
        
        
        var bestI = -1;
        for (var i = from; i <= to; i++)
        {
            if (prev.Lanes[i] == snappedStartLane)
            {
                bestI = i;
                break;
            }
        }

        
        
        
        if (bestI < 0)
        {
            var bestD = float.MaxValue;
            for (var i = from; i <= to; i++)
            {
                var d = DistanceToPolyline(prev.Lanes[i], req.StartX, req.StartZ);
                if (d < bestD)
                {
                    bestD = d;
                    bestI = i;
                }
            }
            if (bestI < 0 || bestD > RouteReuseLaneJitterMeters)
                return false;
        }

        
        if (DistanceToPolyline(prev.Lanes[bestI], req.StartX, req.StartZ) > RouteReuseMaxOffsetMeters)
            return false;

        
        
        while (bestI + 1 <= to && ProjectionAtLaneEnd(prev.Lanes[bestI], req.StartX, req.StartZ))
            bestI++;

        lanes = prev.Lanes[bestI..];
        index = bestI;
        lane = prev.Lanes[bestI];
        return lanes.Length > 0;
    }

    
    private static bool ProjectionAtLaneEnd(int lane, float x, float z)
    {
        if (lane < 0 || lane >= _pointsBegin.Length)
            return false;
        var (_, _, arc) = ProjectOntoPolylineArc(lane, x, z);
        
        
        return arc >= _length[lane] * 0.98f;
    }

    
    private static float DistanceToPolyline(int poly, float x, float z)
    {
        if (poly < 0 || poly >= _pointsBegin.Length)
            return float.MaxValue;
        var (seg, t, _) = ProjectOntoPolylineArc(poly, x, z);
        var p = Interp(seg, t);
        var dx = p.X - x;
        var dz = p.Z - z;
        return MathF.Sqrt(dx * dx + dz * dz);
    }

    
    
    
    
    private const float MaxTargetSnapMeters = 250f;

    private static float MaxRawGap(int[] lanes)
    {
        var worst = 0f;
        for (var i = 1; i < lanes.Length; i++)
        {
            var a = _pointsEnd[lanes[i - 1]] - 1;
            var b = _pointsBegin[lanes[i]];
            var dx = _px[a] - _px[b];
            var dz = _pz[a] - _pz[b];
            var d = MathF.Sqrt(dx * dx + dz * dz);
            if (d > worst)
                worst = d;
        }
        return worst;
    }

    
    
    
    
    private static float MaxLaneSegmentOf(int[] lanes)
    {
        var worst = 0f;
        foreach (var lane in lanes)
        {
            worst = MathF.Max(worst, MaxSegmentOfPoly(lane));
            var c = PolyFor(lane, true);
            if (c != lane)
                worst = MathF.Max(worst, MaxSegmentOfPoly(c));
        }
        return worst;
    }

    private static float MaxSegmentOfPoly(int poly)
    {
        var worst = 0f;
        for (var i = _pointsBegin[poly]; i < _pointsEnd[poly] - 1; i++)
        {
            var dx = _px[i + 1] - _px[i];
            var dy = _py[i + 1] - _py[i];
            var dz = _pz[i + 1] - _pz[i];
            var d = MathF.Sqrt(dx * dx + dy * dy + dz * dz);
            if (d > worst)
                worst = d;
        }
        return worst;
    }

    private static int NearestReachableTo(int[] reachable, float x, float z)
    {
        var best = -1;
        var bestD = float.MaxValue;
        foreach (var lane in reachable)
        {
            var d = DistanceToLaneXZ(lane, x, z);
            if (d < bestD)
            {
                bestD = d;
                best = lane;
            }
        }
        return best;
    }

    
    private static (int SegIdx, float T) ProjectOntoPolyline(int poly, float x, float z)
    {
        var (seg, t, _) = ProjectOntoPolylineArc(poly, x, z);
        return (seg, t);
    }

    
    
    
    
    private static (int SegIdx, float T, float Arc) ProjectOntoPolylineArc(int poly, float x, float z)
    {
        var b = _pointsBegin[poly];
        var e = _pointsEnd[poly];
        var bestD = float.MaxValue;
        var bestSeg = b;
        var bestT = 0f;
        for (var i = b; i < e - 1; i++)
        {
            var ax = _px[i];
            var az = _pz[i];
            var vx = _px[i + 1] - ax;
            var vz = _pz[i + 1] - az;
            var len2 = vx * vx + vz * vz;
            var t = len2 <= 1e-6f ? 0f : Math.Clamp(((x - ax) * vx + (z - az) * vz) / len2, 0f, 1f);
            var dx = x - (ax + t * vx);
            var dz = z - (az + t * vz);
            var d = dx * dx + dz * dz;
            if (d < bestD)
            {
                bestD = d;
                bestSeg = i;
                bestT = t;
            }
        }

        var arc = 0f;
        for (var i = b; i < bestSeg; i++)
        {
            var dx = _px[i + 1] - _px[i];
            var dz = _pz[i + 1] - _pz[i];
            arc += MathF.Sqrt(dx * dx + dz * dz);
        }
        if (bestSeg + 1 < e)
        {
            var dx = _px[bestSeg + 1] - _px[bestSeg];
            var dz = _pz[bestSeg + 1] - _pz[bestSeg];
            arc += MathF.Sqrt(dx * dx + dz * dz) * bestT;
        }
        return (bestSeg, bestT, arc);
    }

    
    
    
    
    
    
    
    private static int PolyFor(int lane, bool useCenterLane)
    {
        if (!useCenterLane)
            return lane;
        var c = _centerLane[lane];
        if (c <= 0 || c >= _pointsBegin.Length)
            return lane;
        if (DistanceToLaneXZ(lane, _px[_pointsBegin[c]], _pz[_pointsBegin[c]]) > 25f)
            return lane;
        return c;
    }

    
    private static (float X, float Y, float Z) Interp(int seg, float t)
        => (_px[seg] + (_px[seg + 1] - _px[seg]) * t,
            _py[seg] + (_py[seg + 1] - _py[seg]) * t,
            _pz[seg] + (_pz[seg + 1] - _pz[seg]) * t);

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private static void AppendRoutePolyline(
        List<(float X, float Y, float Z)> points, int[] lanes, bool useCenterLane,
        float startX, float startZ, float targetX, float targetZ,
        float headingX, float headingZ)
    {
        for (var idx = 0; idx < lanes.Length; idx++)
        {
            var lane = lanes[idx];
            var poly = PolyFor(lane, useCenterLane);
            if (poly < 0 || poly >= _pointsBegin.Length)
                continue;

            var b = _pointsBegin[poly];
            var e = _pointsEnd[poly];
            if (e - b < 2)
                continue;

            var reversed = useCenterLane && poly != lane && IsReversed(lane, poly);

            var refX = points.Count > 0 ? points[^1].X : startX;
            var refZ = points.Count > 0 ? points[^1].Z : startZ;

            
            
            if (useCenterLane && poly != lane)
            {
                var (s2, t2, _) = ProjectOntoPolylineArc(poly, refX, refZ);
                var e2 = Interp(s2, t2);
                var dx2 = e2.X - refX;
                var dz2 = e2.Z - refZ;
                if (dx2 * dx2 + dz2 * dz2 > 30f * 30f)
                {
                    poly = lane;
                    reversed = false;
                    b = _pointsBegin[poly];
                    e = _pointsEnd[poly];
                    if (e - b < 2)
                        continue;
                }
            }

            var (inSeg, inT, inArc) = ProjectOntoPolylineArc(poly, refX, refZ);

            float ref2X, ref2Z;
            var nextPoly = idx + 1 < lanes.Length
                ? PolyFor(lanes[idx + 1], useCenterLane)
                : -1;
            if (nextPoly >= 0 && nextPoly < _pointsBegin.Length)
            {
                var nb = _pointsBegin[nextPoly];
                var ne = _pointsEnd[nextPoly] - 1;
                var nReversed = useCenterLane && IsReversed(lanes[idx + 1], nextPoly);
                ref2X = nReversed ? _px[ne] : _px[nb];
                ref2Z = nReversed ? _pz[ne] : _pz[nb];
            }
            else
            {
                ref2X = targetX;
                ref2Z = targetZ;
            }

            var (exSeg, exT, exArc) = ProjectOntoPolylineArc(poly, ref2X, ref2Z);

            
            if (reversed)
            {
                if (exArc > inArc)
                {
                    exArc = inArc;
                    exSeg = inSeg;
                    exT = inT;
                }
            }
            else
            {
                if (exArc < inArc)
                {
                    exArc = inArc;
                    exSeg = inSeg;
                    exT = inT;
                }
            }

            
            
            
            var entryPt = Interp(inSeg, inT);
            var emitEntry = true;
            if (idx == 0 && points.Count == 1)
            {
                var dx = entryPt.X - refX;
                var dz = entryPt.Z - refZ;
                var m = MathF.Sqrt(dx * dx + dz * dz);
                if (m > 2f && (dx * headingX + dz * headingZ) / m < -0.3f)
                    emitEntry = false;
            }
            if (emitEntry)
                AppendPoint(points, entryPt.X, entryPt.Y, entryPt.Z);

            
            if (exArc <= inArc + 0.01f)
                continue;

            if (!reversed)
            {
                for (var k = inSeg + 1; k <= exSeg && k < e; k++)
                    AppendPoint(points, _px[k], _py[k], _pz[k]);
            }
            else
            {
                for (var k = inSeg; k >= exSeg + 1 && k >= b; k--)
                    AppendPoint(points, _px[k], _py[k], _pz[k]);
            }

            var exitPt = Interp(exSeg, exT);
            AppendPoint(points, exitPt.X, exitPt.Y, exitPt.Z);
        }
    }

    
    private static bool IsReversed(int lane, int centerLane)
    {
        var (ax, az) = LaneDirection(lane);
        var (bx, bz) = LaneDirection(centerLane);
        return ax * bx + az * bz < 0f;
    }

    private static void AppendPoint(List<(float X, float Y, float Z)> points, float x, float y, float z)
    {
        if (points.Count > 0)
        {
            var last = points[^1];
            var dx = last.X - x;
            var dy = last.Y - y;
            var dz = last.Z - z;
            if (dx * dx + dy * dy + dz * dz < MinPointSpacing * MinPointSpacing)
                return;
        }
        points.Add((x, y, z));
    }

    private static float PolylineLength(List<(float X, float Y, float Z)> points)
    {
        var total = 0f;
        for (var i = 1; i < points.Count; i++)
        {
            var a = points[i - 1];
            var b = points[i];
            var dx = b.X - a.X;
            var dy = b.Y - a.Y;
            var dz = b.Z - a.Z;
            total += MathF.Sqrt(dx * dx + dy * dy + dz * dz);
        }
        return total;
    }

    
    
    
    
    
    
    
    internal static void ProbeHysteresis(float startX, float startZ, float targetX, float targetZ,
        float yaw)
    {
        EnsureLoaded();
        Console.WriteLine("[VEHNAV] 稳定性自检（每步前进 3m，共 12 步）：");
        Console.WriteLine("[VEHNAV]   步  车位置            不滞回:车道/点数      带滞回:车道/点数");

        int hystLane = -1;
        var prevNo = -1;
        var prevH = -1;
        for (var step = 0; step < 12; step++)
        {
            var px = startX + step * 3f;
            var pz = startZ;

            var a = Solve(new NavRequest(px, 0f, pz, yaw, targetX, 0f, targetZ, false, false, -1));
            var b = Solve(new NavRequest(px, 0f, pz, yaw, targetX, 0f, targetZ, false, false, hystLane));

            var laneNo = a?.StartLane ?? -1;
            var ptsNo = a?.Points.Count ?? 0;
            if (b is not null && b.StartLane >= 0)
                hystLane = b.StartLane;
            var laneH = b?.StartLane ?? -1;
            var ptsH = b?.Points.Count ?? 0;

            var flagNo = laneNo != prevNo ? " ←换车道" : "";
            var flagH = laneH != prevH ? " ←换车道" : "";
            Console.WriteLine($"[VEHNAV]   {step,-4} ({px:F0},{pz:F0})       "
                              + $"车道{laneNo,-6} 点数{ptsNo,-6}{flagNo,-12}"
                              + $"车道{laneH,-6} 点数{ptsH,-6}{flagH}");
            prevNo = laneNo;
            prevH = laneH;
        }
        Console.WriteLine("[VEHNAV]  （不滞回那一列换车道越频繁，客户端上就越是闪）");
    }

    
    
    
    
    internal static void ProbeReplay(string path)
    {
        EnsureLoaded();
        var lines = File.ReadAllLines(path);
        var total = 0;
        var failed = 0;
        var backtrack = 0;
        var discontinuity = 0;
        var worstBack = 0f;
        var worstBackAt = "";
        var worstDisc = 0f;
        var worstDiscAt = "";
        var centerWorst = 0f;
        var preferred = -1;
        NavRouteState? route = null;

        foreach (var raw in lines)
        {
            var s = raw.Trim();
            if (s.Length == 0 || s.StartsWith('#'))
                continue;
            var parts = s.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length < 4)
                continue;
            if (!float.TryParse(parts[0], out var sx) || !float.TryParse(parts[1], out var sz)
                || !float.TryParse(parts[2], out var tx) || !float.TryParse(parts[3], out var tz))
                continue;
            var yaw = parts.Length >= 5 && float.TryParse(parts[4], out var y) ? y : 0f;

            total++;
            var solution = Solve(new NavRequest(sx, 0f, sz, yaw, tx, 0f, tz, false, false, preferred, route));
            if (solution is null || !solution.Routed)
            {
                failed++;
                continue;
            }
            preferred = solution.StartLane;
            if (solution.RouteLanes.Length > 0)
                route = new NavRouteState
                {
                    Lanes = solution.RouteLanes, TargetX = tx, TargetZ = tz, StartLaneIndex = 0,
                };

            var back = MaxBacktrack(solution.Points, out _);
            if (back > 5f)
            {
                backtrack++;
                if (back > worstBack)
                {
                    worstBack = back;
                    worstBackAt = $"({sx:F0},{sz:F0}) yaw={yaw:F0}";
                }
            }
            
            
            
            
            
            
            var stepMain = MaxStep(solution.Points, true);
            var limit = MathF.Max(solution.MaxLaneSegment, 10f) + 20f;
            if (stepMain > limit)
            {
                discontinuity++;
                var over = stepMain - limit;
                if (over > worstDisc)
                {
                    worstDisc = over;
                    worstDiscAt = $"({sx:F0},{sz:F0}) yaw={yaw:F0}"
                                  + $" 地面线最大间距 {stepMain:F1}m vs 最长车道单段 {solution.MaxLaneSegment:F1}m";
                }
            }
            var stepCenter = MaxStep(solution.CenterPoints, true);
            if (stepCenter > centerWorst)
                centerWorst = stepCenter;
        }

        Console.WriteLine($"[VEHNAV] 回放 {total} 条：走通失败 {failed}，"
                          + $"折回>5m {backtrack}（最差 {worstBack:F1}m {worstBackAt}），"
                          + $"地面线不连续 {discontinuity}（最差超出 {worstDisc:F1}m {worstDiscAt}）");
        Console.WriteLine($"[VEHNAV]   CenterPoints（小地图线）最大间距 {centerWorst:F1}m —— 中心线本身又长又直，单独统计不参与判定");
        Console.WriteLine($"[VEHNAV] => {(failed == 0 && backtrack == 0 && discontinuity == 0 ? "全部通过 ✅" : "仍有问题 ❌")}");
    }

    
    
    
    
    
    
    
    internal static void ProbeTrace(string path)
    {
        EnsureLoaded();
        var preferred = -1;
        NavRouteState? route = null;
        var prev = (List<(float X, float Y, float Z)>?)null;
        var prevInfo = "";
        var flips = new List<string>();
        var hs = new List<float>();
        var hfs = new List<float>();
        var reusedCount = 0;
        var k = -1;

        foreach (var raw in File.ReadAllLines(path))
        {
            var s = raw.Trim();
            if (s.Length == 0 || s.StartsWith('#'))
                continue;
            var parts = s.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length < 4)
                continue;
            if (!float.TryParse(parts[0], out var sx) || !float.TryParse(parts[1], out var sz)
                || !float.TryParse(parts[2], out var tx) || !float.TryParse(parts[3], out var tz))
                continue;
            var yaw = parts.Length >= 5 && float.TryParse(parts[4], out var y) ? y : 0f;
            k++;

            var sol = Solve(new NavRequest(sx, 0f, sz, yaw, tx, 0f, tz, false, false, preferred, route));
            if (sol is null)
            {
                Console.WriteLine($"[trace] {k,3} 寻路 null");
                continue;
            }
            preferred = sol.StartLane;
            if (sol.ReusedRoute)
                reusedCount++;
            if (sol.RouteLanes.Length > 0)
                route = new NavRouteState
                {
                    Lanes = sol.RouteLanes, TargetX = tx, TargetZ = tz, StartLaneIndex = 0,
                };

            string h = "-";
            var hf = -1f;
            if (prev is not null && prev.Count > 1 && sol.Points.Count > 1)
            {
                
                
                
                var hv = HausdorffXz(prev, sol.Points);
                hf = FarEndDeviation(prev, sol.Points, 40);
                hs.Add(hv);
                if (hf >= 0f)
                    hfs.Add(hf);
                h = $"{hv:F1}/{hf:F1}";
                if (hf > 10f)
                    flips.Add($"k={k} 远端Δ={hf:F1}m(整体{hv:F1}m)  [{prevInfo}] -> [startLane={sol.StartLane} "
                              + $"targetLane={sol.TargetLane} hops={sol.HopCount} len={sol.Length:F0}m]");
            }

            var info = $"startLane={sol.StartLane}(snap {sol.StartSnapDistance:F1}m) "
                       + $"targetLane={sol.TargetLane}(snap {sol.TargetSnapDistance:F1}m) "
                       + $"hops={sol.HopCount} len={sol.Length:F0}m n={sol.Points.Count}"
                       + (sol.ReusedRoute ? $" [复用旧链@{sol.ReusedLaneIndex}]" : " [A*]");

            if (k < 40 || hf > 10f)
                Console.WriteLine($"[trace] {k,3} 车({sx,8:F1},{sz,8:F1}) yaw={yaw,7:F2}  "
                                  + $"目标({tx:F1},{tz:F1})  {info}  Hausdorff(整体/远端)={h}");

            prevInfo = $"startLane={sol.StartLane} targetLane={sol.TargetLane} len={sol.Length:F0}m";
            prev = sol.Points;
        }

        Console.WriteLine($"[VEHNAV] 共 {k + 1} 条；复用旧链 {reusedCount} 条，重新规划 {k + 1 - reusedCount} 条；"
                          + $"折线跳变(>10m) {flips.Count} 次");
        if (hs.Count > 0)
        {
            var sorted = hs.OrderBy(v => v).ToArray();
            Console.WriteLine($"[VEHNAV] 相邻折线 Hausdorff(整体)：平均 {hs.Average():F1}m，"
                              + $"中位 {sorted[sorted.Length / 2]:F1}m，最大 {sorted[^1]:F1}m，"
                              + $">10m {hs.Count(v => v > 10f)}/{hs.Count}");
        }
        if (hfs.Count > 0)
        {
            var sf = hfs.OrderBy(v => v).ToArray();
            Console.WriteLine($"[VEHNAV] 相邻折线 远端(目标那侧40点)偏差："
                              + $"平均 {hfs.Average():F1}m，中位 {sf[sf.Length / 2]:F1}m，最大 {sf[^1]:F1}m，"
                              + $">10m {hfs.Count(v => v > 10f)}/{hfs.Count}");
        }
        foreach (var f in flips.Take(20))
            Console.WriteLine($"[VEHNAV]   {f}");
    }

    
    
    
    
    
    
    
    
    private static float FarEndDeviation(
        List<(float X, float Y, float Z)> a, List<(float X, float Y, float Z)> b, int count)
    {
        var n = Math.Min(count, (Math.Min(a.Count, b.Count) - 1) / 2);
        if (n <= 0)
            return -1f;
        var worst = 0f;
        for (var i = 0; i < n; i++)
        {
            var p = a[a.Count - 1 - i];
            var q = b[b.Count - 1 - i];
            var d = MathF.Sqrt((p.X - q.X) * (p.X - q.X) + (p.Z - q.Z) * (p.Z - q.Z));
            if (d > worst)
                worst = d;
        }
        return worst;
    }

    
    private static List<(float X, float Y, float Z)> FarFrom(
        List<(float X, float Y, float Z)> pts, float x, float z, float radius)
    {
        var r2 = radius * radius;
        var outp = new List<(float X, float Y, float Z)>(pts.Count);
        foreach (var p in pts)
        {
            var dx = p.X - x;
            var dz = p.Z - z;
            if (dx * dx + dz * dz > r2)
                outp.Add(p);
        }
        return outp;
    }

    
    private static float HausdorffXz(
        List<(float X, float Y, float Z)> a, List<(float X, float Y, float Z)> b)
    {
        if (a.Count < 2 || b.Count < 2)
            return -1f;
        static float SegDist((float X, float Z) p, (float X, float Z) q, (float X, float Z) r)
        {
            var dx = q.X - p.X;
            var dz = q.Z - p.Z;
            var l2 = dx * dx + dz * dz;
            if (l2 < 1e-9f)
                return MathF.Sqrt((r.X - p.X) * (r.X - p.X) + (r.Z - p.Z) * (r.Z - p.Z));
            var t = ((r.X - p.X) * dx + (r.Z - p.Z) * dz) / l2;
            t = Math.Clamp(t, 0f, 1f);
            var cx = p.X + t * dx;
            var cz = p.Z + t * dz;
            return MathF.Sqrt((r.X - cx) * (r.X - cx) + (r.Z - cz) * (r.Z - cz));
        }

        static float ToPoly(List<(float X, float Y, float Z)> poly, (float X, float Z) r)
        {
            var best = float.MaxValue;
            for (var i = 0; i + 1 < poly.Count; i++)
            {
                var d = SegDist((poly[i].X, poly[i].Z), (poly[i + 1].X, poly[i + 1].Z), r);
                if (d < best)
                    best = d;
            }
            return best;
        }

        var m1 = 0f;
        foreach (var p in a)
        {
            var d = ToPoly(b, (p.X, p.Z));
            if (d > m1)
                m1 = d;
        }
        var m2 = 0f;
        foreach (var p in b)
        {
            var d = ToPoly(a, (p.X, p.Z));
            if (d > m2)
                m2 = d;
        }
        return MathF.Max(m1, m2);
    }

    
    internal static void Probe(float spawnX, float spawnZ, float targetX, float targetZ, float yaw = 0f)
    {
        EnsureLoaded();
        Console.WriteLine($"[VEHNAV] {_status}");
        if (_pointsBegin.Length == 0)
            return;

        if (!TrySnapStart(spawnX, spawnZ, yaw, -1, out var startLane, out var startDist))
            return;
        Console.WriteLine($"[VEHNAV] 出生点 ({spawnX:F1},{spawnZ:F1}) yaw={yaw:F1} -> 车道 {startLane}"
                          + $" 距离 {startDist:F2}m flags=0x{_flags[startLane]:X}"
                          + $" len={_length[startLane]:F1} 出边={_succEnd[startLane] - _succBegin[startLane]}"
                          + $" 中心线={_centerLane[startLane]}");

        var reachable = ForwardReachable(startLane);
        Console.WriteLine($"[VEHNAV] 前向可达 {reachable.Length}/{_pointsBegin.Length}"
                          + $" = {100.0 * reachable.Length / _pointsBegin.Length:F1}%");

        var sw = System.Diagnostics.Stopwatch.StartNew();
        var solution = Solve(new NavRequest(spawnX, 0f, spawnZ, yaw, targetX, 0f, targetZ, false, false));
        sw.Stop();
        if (solution is null)
        {
            Console.WriteLine("[VEHNAV] 示例寻路失败（图为空）");
            return;
        }
        Console.WriteLine($"[VEHNAV] 示例 ({spawnX:F0},{spawnZ:F0}) -> ({targetX:F0},{targetZ:F0})"
                          + $" 起点车道={solution.StartLane}(吸附 {solution.StartSnapDistance:F1}m)"
                          + $" 目标车道={solution.TargetLane}(吸附 {solution.TargetSnapDistance:F1}m)"
                          + $" 跳数={solution.HopCount} 走通={solution.Routed} 长度={solution.Length:F1}m"
                          + $" 耗时={sw.Elapsed.TotalMilliseconds:F2}ms");
        Console.WriteLine($"[VEHNAV]   Points={solution.Points.Count} 点"
                          + $"（相邻点最大间距 {MaxStep(solution.Points):F1}m）"
                          + $"  CenterPoints={solution.CenterPoints.Count} 点"
                          + $"（相邻点最大间距 {MaxStep(solution.CenterPoints):F1}m）");

        
        
        var maxLaneSeg = solution.MaxLaneSegment;
        var stepMain = MaxStep(solution.Points, true);
        var ok = stepMain <= MathF.Max(maxLaneSeg, 10f) + 20f;
        Console.WriteLine($"[VEHNAV]  地面线连续性：最大间距 {stepMain:F1}m vs 最长车道单段 {maxLaneSeg:F1}m"
                          + $"  => {(ok ? "通过 ✅" : "失败 ❌（有跳变）")}"
                          + $"；截断前原始车道间隙 {solution.MaxRawLaneGap:F1}m");
        Console.WriteLine($"[VEHNAV]  CenterPoints（小地图线）最大间距 {MaxStep(solution.CenterPoints, true):F1}m"
                          + " —— 中心线本身又长又直，不参与判定");

        
        
        
        
        var backP = MaxBacktrack(solution.Points, out var detailP);
        var backC = MaxBacktrack(solution.CenterPoints, out var detailC);
        var okBack = backP <= 5f && backC <= 5f;
        Console.WriteLine($"[VEHNAV]  回头路自检：最大折回 Points {backP:F1}m{detailP}"
                          + $"，CenterPoints {backC:F1}m{detailC}"
                          + $"  => {(okBack ? "通过 ✅" : "有回头路 ❌")}");
    }

    
    
    
    private static float MaxBacktrack(List<(float X, float Y, float Z)> points, out string detail)
    {
        var worst = 0f;
        var worstAt = -1;
        for (var i = 2; i < points.Count; i++)
        {
            var a = points[i - 1];
            var b = points[i - 2];
            var c = points[i];
            var ax = a.X - b.X;
            var az = a.Z - b.Z;
            var bx = c.X - a.X;
            var bz = c.Z - a.Z;
            var na = MathF.Sqrt(ax * ax + az * az);
            var nb = MathF.Sqrt(bx * bx + bz * bz);
            if (na < 0.5f || nb < 0.5f)
                continue;
            if ((ax * bx + az * bz) / (na * nb) >= -0.3f)
                continue;
            if (na > worst)
            {
                worst = na;
                worstAt = i;
            }
        }
        detail = worstAt < 0
            ? ""
            : $"(@{worstAt} ({points[worstAt - 1].X:F1},{points[worstAt - 1].Z:F1}))";
        return worst;
    }

    private static float MaxStep(List<(float X, float Y, float Z)> points, bool skipLast = false)
    {
        var worst = 0f;
        var last = skipLast ? points.Count - 1 : points.Count;
        for (var i = 1; i < last; i++)
        {
            var a = points[i - 1];
            var b = points[i];
            var dx = b.X - a.X;
            var dy = b.Y - a.Y;
            var dz = b.Z - a.Z;
            var d = MathF.Sqrt(dx * dx + dy * dy + dz * dz);
            if (d > worst)
                worst = d;
        }
        return worst;
    }
}
