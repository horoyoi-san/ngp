using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    private static VehicleNavigationSettings VehicleNavCfg
        => PrivateServerConfigStore.Current.Gameplay.VehicleNavigation;

    

    [Handler(MethodId.AskVehicleNavigationPathPoints, HandlerPacketKind.Invoke)]
    private Task AskVehicleNavigationPathPoints(Connection conn, UxRpcMessage msg)
    {
        AskVehicleNavigationPathPoints4229938 args;
        try
        {
            args = msg.GetArgs<AskVehicleNavigationPathPoints4229938>();
        }
        catch (Exception ex)
        {
            conn.Log.Warn($"[VEHNAV] AskVehicleNavigationPathPoints 参数解析失败: {ex.Message}");
            return conn.ReturnAsync(msg, EmptyNavResult(0));
        }

        
        var origin = PlayerOrigin(conn);
        return ReplyPathAsync(conn, msg, args.NavReqId,
            origin.X, origin.Y, origin.Z, 0f,
            args.TargetPosition.X, args.TargetPosition.Y, args.TargetPosition.Z,
            args.NavigationProfile, args.IgnoreAlley,
            "AskVehicleNavigationPathPoints");
    }

    [Handler(MethodId.AskVehicleNavigationPathPointsFromPos, HandlerPacketKind.Invoke)]
    private Task AskVehicleNavigationPathPointsFromPos(Connection conn, UxRpcMessage msg)
    {
        AskVehicleNavigationPathPointsFromPos4229938 args;
        try
        {
            args = msg.GetArgs<AskVehicleNavigationPathPointsFromPos4229938>();
        }
        catch (Exception ex)
        {
            conn.Log.Warn($"[VEHNAV] AskVehicleNavigationPathPointsFromPos 参数解析失败: {ex.Message}");
            return conn.ReturnAsync(msg, EmptyNavResult(0));
        }

        
        RememberNavStart(conn.Session,
            args.StartPosition.X, args.StartPosition.Y, args.StartPosition.Z);

        
        return ReplyPathAsync(conn, msg, args.NavReqId,
            args.StartPosition.X, args.StartPosition.Y, args.StartPosition.Z, args.EulerY,
            args.TargetPosition.X, args.TargetPosition.Y, args.TargetPosition.Z,
            args.NavigationProfile, args.IgnoreAlley,
            "AskVehicleNavigationPathPointsFromPos");
    }

    private async Task ReplyPathAsync(
        Connection conn, UxRpcMessage msg, uint navReqId,
        float startX, float startY, float startZ, float yaw,
        float targetX, float targetY, float targetZ,
        byte navigationProfile, bool ignoreAlley, string tag)
    {
        var cfg = VehicleNavCfg;
        var result = EmptyNavResult(navReqId);

        if (cfg.Enabled && VehicleNavGraph.IsLoaded)
        {
            
            var preferMainRoad = cfg.ForcePreferMainRoad || navigationProfile == 1;

            
            
            
            var preferred = conn.Session.Items.TryGetValue(LastStartLaneKey, out var raw)
                            && raw is int prev ? prev : -1;

            
            
            var previousRoute = conn.Session.Items.TryGetValue(RouteStateKey, out var routeRaw)
                ? routeRaw as VehicleNavGraph.NavRouteState
                : null;

            var request = new VehicleNavGraph.NavRequest(
                startX, startY, startZ, yaw, targetX, targetY, targetZ, preferMainRoad, ignoreAlley,
                preferred, previousRoute);

            var solution = VehicleNavGraph.Solve(request);
            if (solution is not null && solution.Points.Count > 0)
            {
                if (solution.StartLane >= 0)
                    conn.Session.Items[LastStartLaneKey] = solution.StartLane;

                
                if (solution.RouteLanes.Length > 0)
                {
                    conn.Session.Items[RouteStateKey] = new VehicleNavGraph.NavRouteState
                    {
                        Lanes = solution.RouteLanes,
                        TargetX = targetX,
                        TargetZ = targetZ,
                        StartLaneIndex = 0,
                    };
                }

                var limit = Math.Max(2, cfg.MaxPathPoints);

                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                CopyPoints(solution.Points, result.Points, limit, reverse: true);

                
                
                CopyPoints(solution.CenterPoints, result.CenterPoints, limit);

                if (cfg.LogEveryRequest)
                {
                    conn.Log.Info($"[VEHNAV] {tag} req={navReqId} profile={navigationProfile}"
                                  + $" ignoreAlley={ignoreAlley} yaw={yaw:F0}"
                                  + $" 起点({startX:F0},{startZ:F0})→车道{solution.StartLane}(吸附{solution.StartSnapDistance:F1}m)"
                                  + $" 目标({targetX:F0},{targetZ:F0})→车道{solution.TargetLane}(吸附{solution.TargetSnapDistance:F1}m)"
                                  + $" 跳数={solution.HopCount} 走通={solution.Routed} 长度={solution.Length:F1}m"
                                  + $" Points={result.Points.Count} Center={result.CenterPoints.Count}"
                                  + $" 截断前车道间隙={solution.MaxRawLaneGap:F0}m");
                }
            }
        }
        else if (!cfg.Enabled)
        {
            conn.Log.Info($"[VEHNAV] {tag} 已被 gameplay.vehicleNavigation.enabled=false 关闭，回空结果");
        }

        await conn.ReturnAsync(msg, result);
    }

    private static void CopyPoints(
        List<(float X, float Y, float Z)> source, List<UxVector3> destination, int limit,
        bool reverse = false)
    {
        var count = Math.Min(source.Count, limit);
        if (!reverse)
        {
            for (var i = 0; i < count; i++)
            {
                var p = source[i];
                destination.Add(new UxVector3(p.X, p.Y, p.Z));
            }
            return;
        }

        
        
        
        var begin = source.Count - count;
        for (var i = source.Count - 1; i >= begin; i--)
        {
            var p = source[i];
            destination.Add(new UxVector3(p.X, p.Y, p.Z));
        }
    }

    private static VehicleNavResult4229938 EmptyNavResult(uint navReqId)
        => new() { NavReqId = navReqId, Points = [], CenterPoints = [] };

    

    [Handler(MethodId.AskVehicleNavigationPathLength, HandlerPacketKind.Invoke)]
    private Task AskVehicleNavigationPathLength(Connection conn, UxRpcMessage msg)
    {
        var length = 0f;
        try
        {
            var args = msg.GetArgs<AskVehicleNavigationPathLength4229938>();
            var origin = PlayerOrigin(conn);
            length = MeasureLength(conn, origin.X, origin.Y, origin.Z,
                args.TargetPosition.X, args.TargetPosition.Y, args.TargetPosition.Z,
                args.NavigationProfile, args.IgnoreAlley);
        }
        catch (Exception ex)
        {
            conn.Log.Warn($"[VEHNAV] AskVehicleNavigationPathLength 参数解析失败: {ex.Message}");
        }
        
        return conn.ReturnAsync(msg, BitConverter.GetBytes(length));
    }

    [Handler(MethodId.AskVehicleNavigationPathLengthList, HandlerPacketKind.Invoke)]
    private Task AskVehicleNavigationPathLengthList(Connection conn, UxRpcMessage msg)
    {
        AskVehicleNavigationPathLengthList4229938 args;
        try
        {
            args = msg.GetArgs<AskVehicleNavigationPathLengthList4229938>();
        }
        catch (Exception ex)
        {
            conn.Log.Warn($"[VEHNAV] AskVehicleNavigationPathLengthList 参数解析失败: {ex.Message}");
            return conn.ReturnAsync(msg, [0xFF, 0x01]);   
        }

        var origin = PlayerOrigin(conn);
        var lengths = new List<float>(args.TargetPositionList.Count);
        foreach (var target in args.TargetPositionList)
        {
            lengths.Add(MeasureLength(conn, origin.X, origin.Y, origin.Z,
                target.X, target.Y, target.Z, args.NavigationProfile, args.IgnoreAlley));
        }

        
        var body = new byte[2 + lengths.Count * 4];
        body[0] = 0xFF;
        body[1] = (byte)(lengths.Count + 1);
        for (var i = 0; i < lengths.Count; i++)
            BitConverter.GetBytes(lengths[i]).CopyTo(body, 2 + i * 4);
        return conn.ReturnAsync(msg, body);
    }

    private static float MeasureLength(
        Connection conn, float sx, float sy, float sz, float tx, float ty, float tz,
        byte navigationProfile, bool ignoreAlley)
    {
        if (!VehicleNavCfg.Enabled || !VehicleNavGraph.IsLoaded)
            return 0f;
        var preferMainRoad = VehicleNavCfg.ForcePreferMainRoad || navigationProfile == 1;
        var solution = VehicleNavGraph.Solve(new VehicleNavGraph.NavRequest(
            sx, sy, sz, 0f, tx, ty, tz, preferMainRoad, ignoreAlley));
        return solution?.Length ?? 0f;
    }

    

    
    
    
    
    
    [Handler(MethodId.AskVehicleStartAutonomousDriving, HandlerPacketKind.Invoke)]
    private async Task AskVehicleStartAutonomousDriving(Connection conn, UxRpcMessage msg)
    {
        var hasTarget = false;
        var target = default(UxVector3);
        try
        {
            var args = msg.GetArgs<AskVehicleStartAutonomousDriving4229938>();
            hasTarget = args.HasValidTargetPosition;
            target = args.TargetPosition;
        }
        catch (Exception ex)
        {
            conn.Log.Warn($"[VEHNAV] AskVehicleStartAutonomousDriving 参数解析失败: {ex.Message}");
        }

        await conn.ReturnEmptyOkAsync(msg);
        await PushAutonomousDrivingStateAsync(conn, true, "start");

        conn.Log.Info($"[VEHNAV] 自动驾驶开启 hasValidTarget={hasTarget}"
                      + $" target=({target.X:F1},{target.Y:F1},{target.Z:F1})"
                      + $" vehicle={CurrentDrivenVehicleId(conn)}");
    }

    
    [Handler(MethodId.AskVehicleChangeAutonomousDrivingTarget, HandlerPacketKind.Invoke)]
    private async Task AskVehicleChangeAutonomousDrivingTarget(Connection conn, UxRpcMessage msg)
    {
        var target = default(UxVector3);
        try
        {
            target = msg.GetArgs<AskVehicleChangeAutonomousDrivingTarget4229938>().TargetPosition;
        }
        catch (Exception ex)
        {
            conn.Log.Warn($"[VEHNAV] AskVehicleChangeAutonomousDrivingTarget 参数解析失败: {ex.Message}");
        }

        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[VEHNAV] 自动驾驶换目标 ({target.X:F1},{target.Y:F1},{target.Z:F1})");
    }

    
    [Handler(MethodId.AskVehicleCancelAutonomousDrivingTarget, HandlerPacketKind.Invoke)]
    private Task AskVehicleCancelAutonomousDrivingTarget(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info("[VEHNAV] 取消自动驾驶目标");
        return conn.ReturnEmptyOkAsync(msg);
    }

    
    [Handler(MethodId.AskVehicleStopAutonomousDriving, HandlerPacketKind.Invoke)]
    private async Task AskVehicleStopAutonomousDriving(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);
        await PushAutonomousDrivingStateAsync(conn, false, "stop");
        conn.Log.Info($"[VEHNAV] 自动驾驶关闭 vehicle={CurrentDrivenVehicleId(conn)}");
    }

    private async Task PushAutonomousDrivingStateAsync(Connection conn, bool isStart, string reason)
    {
        if (!VehicleNavCfg.SendAutonomousDrivingState)
            return;
        var vehicleId = CurrentDrivenVehicleId(conn);
        if (vehicleId == 0)
        {
            conn.Log.Info($"[VEHNAV] {reason}：还没识别出当前载具，跳过 SyncVehicleAutonomousDrivingState");
            return;
        }
        await conn.NotifyAsync(MethodId.IGameSceneToClient_SyncVehicleAutonomousDrivingState,
            UxSerializer.Serialize(new SyncVehicleAutonomousDrivingState4229938
            {
                VehicleEntityId = vehicleId,
                IsStart = isStart,
            }));
    }

    

    
    
    
    
    
    
    
    private static ulong CurrentDrivenVehicleId(Connection conn)
    {
        var state = GetVehicleStoryState(conn.Session);
        lock (state.SyncRoot)
        {
            if (state.CurrentVehicleId != 0)
                return state.CurrentVehicleId;
        }
        return LastSummonedEntity();
    }

    
    
    
    
    
    
    
    
    
    
    
    private static (float X, float Y, float Z) PlayerOrigin(Connection conn)
    {
        if (conn.Session.Items.TryGetValue(LastNavStartKey, out var raw)
            && raw is NavStartSnapshot nav)
            return (nav.X, nav.Y, nav.Z);

        if (conn.Session.Items.TryGetValue(WorldStateKey, out var worldRaw)
            && worldRaw is WorldEntryState state
            && state.HasLastReportedPlayerTransform)
        {
            var p = state.LastReportedPlayerPosition;
            return (p.X, p.Y, p.Z);
        }

        var spawn = Protocol.Client4229938.Profile.WorldSpawn;
        return (spawn.X, spawn.Y, spawn.Z);
    }

    private readonly record struct NavStartSnapshot(float X, float Y, float Z);

    private const string LastNavStartKey = "vehnav.lastStart";

    
    private const string LastStartLaneKey = "vehnav.lastStartLane";

    
    
    
    
    
    private const string RouteStateKey = "vehnav.route";

    private static void RememberNavStart(TcpSession session, float x, float y, float z)
    {
        if (!float.IsFinite(x) || !float.IsFinite(y) || !float.IsFinite(z))
            return;
        if (x == 0f && y == 0f && z == 0f)
            return;   
        session.Items[LastNavStartKey] = new NavStartSnapshot(x, y, z);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    [Handler(MethodId.AskPlayerStartEnterOrExitVehicle, HandlerPacketKind.Notify)]
    [Handler(MethodId.AskPlayerFinishEnterOrExitVehicle, HandlerPacketKind.Notify)]
    private Task AskPlayerEnterOrExitVehicle(Connection conn, UxRpcMessage msg)
    {
        try
        {
            var data = msg.GetArgs<PlayerVehicleDriveStateInfoClientArg4229938>();
            var state = GetVehicleStoryState(conn.Session);
            lock (state.SyncRoot)
            {
                if (data.EnterOrLeave)
                {
                    state.CurrentVehicleId = data.VehicleEntityId;
                    state.CurrentSeat = data.SeatIndex;
                }
                else if (state.CurrentVehicleId == data.VehicleEntityId)
                {
                    state.CurrentVehicleId = 0;
                    state.CurrentSeat = -1;
                }
            }

            conn.Log.Info($"[VEHNAV] 进出载具 enter={data.EnterOrLeave}"
                          + $" vehicle={data.VehicleEntityId} seat={data.SeatIndex}");
        }
        catch (Exception ex)
        {
            conn.Log.Warn($"[VEHNAV] 进出载具通知解析失败（已忽略）: {ex.Message}");
        }
        return Task.CompletedTask;
    }

    
    internal static void ProbeVehicleNav(float targetX, float targetZ)
    {
        var spawn = Protocol.Client4229938.Profile.WorldSpawn;
        VehicleNavGraph.Probe(spawn.X, spawn.Z, targetX, targetZ);
        ProbeTail();
    }

    
    internal static void ProbeVehicleNavFrom(float startX, float startZ, float targetX, float targetZ,
        float yaw = 0f)
    {
        VehicleNavGraph.Probe(startX, startZ, targetX, targetZ, yaw);
        ProbeTail();
    }

    
    
    
    
    internal static void ProbeVehicleNavDump(float startX, float startZ, float targetX, float targetZ,
        float yaw, string path)
    {
        VehicleNavGraph.EnsureLoaded();
        var solution = VehicleNavGraph.Solve(new VehicleNavGraph.NavRequest(
            startX, 0f, startZ, yaw, targetX, 0f, targetZ, false, false));
        if (solution is null)
        {
            Console.WriteLine("[VEHNAV] 寻路失败，未写 dump");
            return;
        }

        static string Points(List<(float X, float Y, float Z)> pts)
            => "[" + string.Join(",", pts.Select(p =>
                $"[{p.X.ToString("F2", System.Globalization.CultureInfo.InvariantCulture)},"
                + $"{p.Y.ToString("F2", System.Globalization.CultureInfo.InvariantCulture)},"
                + $"{p.Z.ToString("F2", System.Globalization.CultureInfo.InvariantCulture)}]")) + "]";

        var json = "{"
                   + $"\"start\":[{startX},{startZ}],\"target\":[{targetX},{targetZ}],\"yaw\":{yaw},"
                   + $"\"routed\":{(solution.Routed ? "true" : "false")},"
                   + $"\"length\":{solution.Length.ToString("F1", System.Globalization.CultureInfo.InvariantCulture)},"
                   + $"\"points\":{Points(solution.Points)},"
                   + $"\"wirePoints\":{Points(WireOrder(solution.Points))},"
                   + $"\"centerPoints\":{Points(solution.CenterPoints)},"
                   + $"\"lanes\":[{string.Join(",", solution.RouteLanes)}]"
                   + "}";
        File.WriteAllText(path, json);
        Console.WriteLine($"[VEHNAV] dump -> {path}"
                          + $"（Points {solution.Points.Count} / CenterPoints {solution.CenterPoints.Count}）");

        
        
        
        
        
        var wire = WireOrder(solution.Points);
        var dHead = MathF.Sqrt(Sq(wire[0].X - targetX) + Sq(wire[0].Z - targetZ));
        var dTail = MathF.Sqrt(Sq(wire[^1].X - startX) + Sq(wire[^1].Z - startZ));
        var orderOk = dHead < 1f && dTail < 1f;
        Console.WriteLine($"[VEHNAV] 线顺序自检：Points[0] 距目标 {dHead:F2}m，"
                          + $"Points[last] 距车 {dTail:F2}m => {(orderOk ? "目标→车 ✅" : "顺序不对 ⚠️")}");
        Console.WriteLine($"[VEHNAV]   Points[0]  = ({wire[0].X:F1},{wire[0].Z:F1})   "
                          + $"Points[last] = ({wire[^1].X:F1},{wire[^1].Z:F1})");

    }

    private static float Sq(float v) => v * v;

    
    private static List<(float X, float Y, float Z)> WireOrder(List<(float X, float Y, float Z)> src)
    {
        var boxed = new List<UxVector3>(src.Count);
        CopyPoints(src, boxed, int.MaxValue, reverse: true);
        var dst = new List<(float X, float Y, float Z)>(boxed.Count);
        foreach (var p in boxed) dst.Add((p.X, p.Y, p.Z));
        return dst;
    }

    
    internal static void ProbeVehicleNavHysteresis(float startX, float startZ,
        float targetX, float targetZ, float yaw)
    {
        VehicleNavGraph.ProbeHysteresis(startX, startZ, targetX, targetZ, yaw);
    }

    
    internal static void ProbeVehicleNavReplay(string path)
    {
        VehicleNavGraph.ProbeReplay(path);
    }

    
    internal static void ProbeVehicleNavTrace(string path)
    {
        VehicleNavGraph.ProbeTrace(path);
    }

    private static void ProbeTail()
    {        Console.WriteLine($"[VEHNAV] 开关 enabled={VehicleNavCfg.Enabled}"
                          + $" forcePreferMainRoad={VehicleNavCfg.ForcePreferMainRoad}"
                          + $" maxTargetSnap={VehicleNavCfg.MaxTargetSnapMeters}m"
                          + $" sendState={VehicleNavCfg.SendAutonomousDrivingState}");

        
        
        
        
        var empty = UxSerializer.Serialize(new VehicleNavResult4229938
        {
            NavReqId = 0,
            Points = [],
            CenterPoints = [],
        });
        var expectedEmpty = new byte[] { 0xFF, 0, 0, 0, 0, 0xFF, 0x01, 0xFF, 0x01 };
        var emptyOk = empty.AsSpan().SequenceEqual(expectedEmpty);
        Console.WriteLine($"[VEHNAV] 空结果 {empty.Length}B = {Convert.ToHexString(empty)}"
                          + $"（期望 9B / 与旧默认值一致：{(emptyOk ? "是" : "否 ⚠️")}）");

        var one = UxSerializer.Serialize(new VehicleNavResult4229938
        {
            NavReqId = 7,
            Points = [new UxVector3(1f, 2f, 3f)],
            CenterPoints = [],
        });
        Console.WriteLine($"[VEHNAV] 1 点结果 {one.Length}B = {Convert.ToHexString(one)}"
                          + "（期望 21B：FF | 07000000 | FF 02 | 3×f32 | FF 01）");
    }
}
