using Ananta.SDK.Logging;
using Ananta.Server.App;
using Ananta.Server.Configuration;
using Ananta.Server.Handlers.Game;
using Ananta.Server.Protocol.Client4229938;

var (config, configPath) = PrivateServerConfigLoader.Load();
PrivateServerConfigStore.Initialize(config, configPath);

if (args.Contains("--probe-aether"))
{
    var (bytes, intersections, head) = GameRouter.ProbeAetherInitBytes();
    
    
    
    var listHeader = intersections == 0 ? 2 : (intersections + 1 >= 0x80 ? 3 : 2);
    var expected = 10 + listHeader + 17 * intersections;
    var ok = bytes == expected;
    Console.WriteLine($"[probe] SyncAetherAIInitDatas body = {bytes} bytes (expected {expected}) -> {(ok ? "OK" : "FAIL")}");
    Console.WriteLine($"[probe] 路口 {intersections} 个；包头 {head}");
    Environment.ExitCode = ok ? 0 : 1;
    return;
}

if (args.Contains("--probe-jobability"))
{
    
    
    Ananta.Server.State.AccountStore.Initialize(Path.GetFullPath(Path.Combine(
        Ananta.Server.Configuration.PrivateServerConfigStore.ProjectRoot, "data", "accounts")));
    var rc = GameRouter.ProbeJobAbility();
    GameRouter.ProbeLoginSpiritContent();
    Environment.ExitCode = rc;
    return;
}

if (args.Contains("--probe-traffic"))
{
    var (n, periods, lanes, open0, multi, sample) = GameRouter.ProbeTraffic();
    Console.WriteLine($"[probe] 路口 {n} 个，周期合计 {periods} 个（多周期路口 {multi} 个）");
    Console.WriteLine($"[probe] 路口内部车道 {lanes} 条；第 0 周期共放行 {open0} 条");
    Console.WriteLine($"[probe] 样例：{sample}");
    var ok = n == 171 && lanes == 1262;
    Console.WriteLine(ok ? "[probe] -> OK" : "[probe] -> 期望 171 路口 / 1262 车道");
    Environment.ExitCode = ok ? 0 : 1;
    return;
}

if (args.Contains("--probe-behavior"))
{
    var (n, crowd, veh, detail) = Ananta.Server.ClientData.Client4229938.BehaviorTaskCatalog.Probe();
    Console.WriteLine($"[probe] AetherNpcBehaviorTaskDefineConfig 共 {n} 条");
    Console.WriteLine($"[probe] 自动挑选：人群(AnimState=Default) → {crowd}；司机(AnimState=Driving) → {veh}");
    Console.WriteLine(detail);
    Environment.ExitCode = n > 0 && crowd != 0 ? 0 : 1;
    return;
}

if (args.Contains("--probe-lanetags"))
{
    var (total, drivable, alley, guide, inter, freeway, oneway, sample) =
        Ananta.Server.ClientData.Client4229938.TrafficLaneTable.ProbeLaneTags();
    Console.WriteLine($"[probe] 车道 {total} 条；有后继（可开） {drivable} 条");
    Console.WriteLine($"[probe]   小巷(VehicleAlley/CapillaryRoad) {alley} 条（{100.0 * alley / Math.Max(1, total):F1}%）"
                      + " —— 只是统计，**不过滤**");
    Console.WriteLine($"[probe]   主路(CenterGuideRoad) {guide} 条");
    Console.WriteLine($"[probe]   路口(Intersection) {inter} 条 / 快速路(Freeway) {freeway} 条 / 单行道(OneWayStreet) {oneway} 条");
    Console.WriteLine($"[probe] 样例 lane0 tags = {sample}");
    Environment.ExitCode = drivable > 0 ? 0 : 1;
    return;
}

if (args.Contains("--probe-basketball"))
{
    Ananta.Server.Handlers.Game.GameRouter.ProbeBasketball();
    Environment.ExitCode = Ananta.Server.ClientData.Client4229938.BasketballCourtTable.Count > 0 ? 0 : 1;
    return;
}

if (args.Contains("--probe-driver"))
{
    var (personas, okFull, detail) = GameRouter.ProbeDriverFormworks();
    Console.WriteLine($"[probe] 司机人格 {personas} 个，全约束能筛出模板的 {okFull} 个");
    Console.WriteLine(detail);
    Environment.ExitCode = personas > 0 && okFull == personas ? 0 : 1;
    return;
}

if (args.Contains("--probe-formwork"))
{
    try
    {
        var (citizens, models, sex, minAge, maxAge,
             cfgPool, cfgBad, pOk, pTotal, detail) = GameRouter.ProbeNpcFormworks();
        Console.WriteLine($"[probe] 市民池 {citizens} 个模板 / {models} 种模型 / {sex} 种性别 / 年龄 {minAge}..{maxAge}");
        Console.WriteLine($"[probe] 配置固定池 {cfgPool} 个（其中 AgentType!=1 或不存在 {cfgBad} 个）");
        if (pTotal > 0)
            Console.WriteLine($"[probe] 人格→模板 自动匹配 {pOk}/{pTotal} 成功：{detail}");
        else
            Console.WriteLine($"[probe] {detail}");
        var ok = citizens > 0 && cfgBad == 0 && (pTotal <= 0 || pOk == pTotal);
        Environment.ExitCode = ok ? 0 : 1;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[probe] NPC 模板检查失败: {ex.GetType().Name}: {ex.Message}");
        Environment.ExitCode = 1;
    }
    return;
}

if (args.Contains("--probe-aitask"))
{
    try
    {
        var body = GameRouter.ProbeAiTaskBody();
        Console.WriteLine($"[probe] SyncAssignVehicleAITask body = {body.Length} 字节");
        Console.WriteLine($"[probe] 头 {Convert.ToHexString(body.AsSpan(0, Math.Min(64, body.Length)))}");
        Console.WriteLine($"[probe] 尾 {Convert.ToHexString(body.AsSpan(Math.Max(0, body.Length - 8)))}");
        var tp = body.Length > 8 ? body[8] : (byte)0;
        var ok = tp == 6;
        Console.WriteLine($"[probe] 第 9 字节（vehicleUId 之后的多态 tp）= {tp} -> {(ok ? "OK(CruiseParameters)" : "FAIL")}");
        Environment.ExitCode = ok ? 0 : 1;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[probe] AI 任务序列化失败: {ex.GetType().Name}: {ex.Message}");
        Environment.ExitCode = 1;
    }
    return;
}

if (args.Contains("--probe-gameswitch"))
{
    try
    {
        foreach (var framing in new[]
                 {
                     GameSwitchFraming.Count7BitNoMark,
                     GameSwitchFraming.Count7Bit,
                     GameSwitchFraming.NullTerminated,
                     GameSwitchFraming.NullTerminatedMarked,
                     GameSwitchFraming.Count32,
                 })
        {
            var (bytes, switches, enabled, head, tail) = GameSwitchCodec.Probe(framing);
            var expected = GameSwitchCodec.ExpectedBytes(framing);
            var ok = bytes == expected;
            Console.WriteLine($"[probe] {framing,-22} = {bytes} bytes (expected {expected}) -> {(ok ? "OK" : "FAIL")}");
            Console.WriteLine($"[probe]   头 {head}");
            Console.WriteLine($"[probe]   尾 {tail}");
        }

        var (dBytes, dSwitches, dEnabled, _, _) = GameSwitchCodec.Probe();
        Console.WriteLine($"[probe] 开关 {dSwitches} 个：开启 {dEnabled} / 关闭 {dSwitches - dEnabled}");
        Console.WriteLine("[probe] 默认 Count7BitNoMark（反汇编确认）：Int7 计数 + {key, tp=02, bool}×n，无标记/无终止符");
        Environment.ExitCode = dBytes > 0 ? 0 : 1;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[probe] GameSwitch 序列化失败: {ex.GetType().Name}: {ex.Message}");
        Environment.ExitCode = 1;
    }
    return;
}

if (args.Contains("--probe-lanes"))
{
    try
    {
        var (lanes, zones, km, drivable, deadEnds) = GameRouter.ProbeLaneTable();
        Console.WriteLine($"[probe] 车道表 {lanes} 条 / {zones} zones / {km:F1} km");
        Console.WriteLine($"[probe] 有后继（可生成）{drivable} 条 / 死胡同 {deadEnds} 条");
        Console.WriteLine($"[probe] 车道 handle 0..{lanes - 1}（客户端按此下标索引本地路网）");
        Environment.ExitCode = lanes > 0 && drivable > 0 ? 0 : 1;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[probe] 车道表加载失败: {ex.GetType().Name}: {ex.Message}");
        Environment.ExitCode = 1;
    }
    return;
}

if (args.Contains("--probe-lanedrive"))
{
    try
    {
        var (starts, hops, minM, maxM, stuck, sample) = GameRouter.ProbeLaneDrive();
        Console.WriteLine($"[probe] 起跑 {starts} 条车道，各仿真 30s（600 帧 @20Hz）");
        Console.WriteLine($"[probe] 合计换道 {hops} 次；行驶 {minM:F0}..{maxM:F0} m；开进死胡同 {stuck} 条");
        Console.WriteLine($"[probe] 最长路径：{sample}");
        Environment.ExitCode = starts > 0 && hops > 0 ? 0 : 1;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[probe] 车流仿真失败: {ex.GetType().Name}: {ex.Message}");
        Environment.ExitCode = 1;
    }
    return;
}

if (args.Contains("--probe-lanedata"))
{
    try
    {
        var (one, two, empty) = GameRouter.ProbeLaneDataBytes();
        var ok = one == 29 && two == 46 && empty == 12;
        Console.WriteLine($"[probe] SyncAetherAIVehicleLaneDatas: 空 = {empty}（期望 12）/ "
                          + $"1 台 = {one}（期望 29）/ 2 台 = {two}（期望 46） -> {(ok ? "OK" : "FAIL")}");
        Console.WriteLine("[probe] 每台车 17 字节 = Id(8) + LaneHandle(4) + DistanceAlongLane(4) + Status(1)");
        Environment.ExitCode = ok ? 0 : 1;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[probe] 车道位置包序列化失败: {ex.GetType().Name}: {ex.Message}");
        Environment.ExitCode = 1;
    }
    return;
}

if (args.Contains("--probe-forcego"))
{
    try
    {
        var (vf, af, ct) = GameRouter.ProbeForceGoBytes();
        var (areas, personas) = GameRouter.ProbeUrbanDiversityPool();
        Console.WriteLine($"[probe] SyncAetherAIVehicleForceGo = {vf} 字节（期望 9）");
        Console.WriteLine($"[probe] SyncAgentForceGo = {af} 字节（期望 9）");
        Console.WriteLine($"[probe] SyncAetherAIChangeVehicleControlType = {ct} 字节（期望 9）");
        Console.WriteLine($"[probe] 区域人格池 {areas} 个区域 / {personas} 种人格");
        Environment.ExitCode = vf == 9 && af == 9 ? 0 : 1;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[probe] 交权包序列化失败: {ex.GetType().Name}: {ex.Message}");
        Environment.ExitCode = 1;
    }
    return;
}

if (args.Contains("--probe-staticnpc"))
{
    try
    {
        var (count, minX, maxX, minZ, maxZ, areas, zero, radius, medWithin, minWithin) =
            GameRouter.ProbeStaticNpcTable();
        var aether = Ananta.Server.Configuration.PrivateServerConfigStore.Current.Gameplay.Aether;
        Console.WriteLine($"[probe] 固定 NPC 布点 {count} 个");
        Console.WriteLine($"[probe] X {minX:F0}..{maxX:F0}  Z {minZ:F0}..{maxZ:F0}");
        Console.WriteLine($"[probe] 覆盖区域 {areas} 个（区域 id=0 的 {zero} 个）");
        Console.WriteLine($"[probe] 半径 {radius:F0}m 内点数：中位 {medWithin}  最小 {minWithin}"
                          + $"（fixedNpcCount={aether.FixedNpcCount}"
                          + (medWithin >= aether.FixedNpcCount ? "，够用）" : "，⚠️ 中位不够，补不满！）"));
        Console.WriteLine($"[probe] 回收距离 {(aether.FixedNpcLeashMeters > 0f ? aether.FixedNpcLeashMeters : Math.Max(300f, radius * 1.4f)):F0}m"
                          + $"；树={aether.FixedNpcBehaviorTreeName}；速度={aether.FixedNpcDesiredSpeed:F1}"
                          + $"；游荡={(aether.FixedNpcWander ? $"0..{aether.FixedNpcWanderMaxDis:F0}m" : "关")}");
        Environment.ExitCode = count > 0 ? 0 : 1;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[probe] 固定 NPC 布点表加载失败: {ex.GetType().Name}: {ex.Message}");
        Environment.ExitCode = 1;
    }
    return;
}

if (args.Contains("--probe-vspawn"))
{
    try
    {
        var (ambient, withDriver, withColor) = GameRouter.ProbeVehicleSpawnTable();
        Console.WriteLine($"[probe] 环境车 {ambient} 种 / 带司机类型 {withDriver} / 带颜色 {withColor}");
        Environment.ExitCode = ambient > 0 ? 0 : 1;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[probe] 环境车配置加载失败: {ex.GetType().Name}: {ex.Message}");
        Environment.ExitCode = 1;
    }
    return;
}

if (args.Contains("--probe-sceneaoi"))
{
    try
    {
        var (act, dest, gad, sectors) = GameRouter.ProbeSceneContentBytes();
        var radius = PrivateServerConfigStore.Current.World.SceneContentAoi.RadiusCells;
        var cells = (radius * 2 + 1) * (radius * 2 + 1);
        Console.WriteLine($"[probe] SyncDestructibleSceneAOIActive = {act} 字节");
        Console.WriteLine($"[probe] SyncDestructibleGridAOIDecrease = {dest} 字节（{cells} 格，sector 过滤表 {sectors} 项）");
        Console.WriteLine($"[probe] SyncGadgetGridAOIDecrease        = {gad} 字节（{cells} 格）");
        Environment.ExitCode = dest > 0 && gad > 0 ? 0 : 1;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[probe] 场景内容 AOI 序列化失败: {ex.GetType().Name}: {ex.Message}");
        Environment.ExitCode = 1;
    }
    return;
}

if (args.Contains("--probe-worldcells"))
{
    var sp = PrivateServerConfigStore.Current.World.Spawn;
    GameRouter.ProbeWorldCells(sp.X, sp.Z);
    Environment.ExitCode = Ananta.Server.ClientData.Client4229938.WorldCellTable.Count > 0 ? 0 : 1;
    return;
}

if (args.Contains("--probe-vehnav-replay"))
{
    var idx = Array.IndexOf(args, "--probe-vehnav-replay");
    var replayPath = idx + 1 < args.Length && !args[idx + 1].StartsWith("--", StringComparison.Ordinal)
        ? args[idx + 1]
        : "vehnav_replay.txt";
    GameRouter.ProbeVehicleNavReplay(replayPath);
    Environment.ExitCode = 0;
    return;
}

if (args.Contains("--probe-vehnav-trace"))
{
    var idx = Array.IndexOf(args, "--probe-vehnav-trace");
    var tracePath = idx + 1 < args.Length && !args[idx + 1].StartsWith("--", StringComparison.Ordinal)
        ? args[idx + 1]
        : "vehnav_trace.txt";
    GameRouter.ProbeVehicleNavTrace(tracePath);
    Environment.ExitCode = 0;
    return;
}

if (args.Contains("--probe-vehiclenav"))
{
    var flagIndex = Array.IndexOf(args, "--probe-vehiclenav");
    var numbers = new List<float>();
    for (var i = flagIndex + 1; i < args.Length && numbers.Count < 5; i++)
    {
        if (args[i].StartsWith("--", StringComparison.Ordinal))
            continue;   
        if (!float.TryParse(args[i], out var v))
            break;
        numbers.Add(v);
    }

    var probeStart = (X: 0f, Z: 0f, Yaw: 0f, Explicit: false);
    var probeTarget = (X: 2087f, Z: 1469f);   
    if (numbers.Count >= 4)
    {
        probeStart = (numbers[0], numbers[1], numbers.Count >= 5 ? numbers[4] : 0f, true);
        probeTarget = (numbers[2], numbers[3]);
    }
    else if (numbers.Count >= 2)
    {
        probeTarget = (numbers[0], numbers[1]);
    }

    if (args.Contains("--probe-vehnav-dump"))
    {
        GameRouter.ProbeVehicleNavDump(probeStart.X, probeStart.Z, probeTarget.X, probeTarget.Z,
            probeStart.Yaw, "nav_probe_dump.json");
        return;
    }

    if (args.Contains("--probe-vehnav-hysteresis"))
    {
        GameRouter.ProbeVehicleNavHysteresis(probeStart.X, probeStart.Z,
            probeTarget.X, probeTarget.Z, probeStart.Yaw);
        return;
    }

    if (probeStart.Explicit)
        GameRouter.ProbeVehicleNavFrom(probeStart.X, probeStart.Z, probeTarget.X, probeTarget.Z, probeStart.Yaw);
    else
        GameRouter.ProbeVehicleNav(probeTarget.X, probeTarget.Z);

    Environment.ExitCode = Ananta.Server.ClientData.Client4229938.VehicleNavGraph.IsLoaded ? 0 : 1;
    return;
}

if (args.Contains("--probe-peds"))
{
    try
    {
        var (points, configIds, unassigned) = GameRouter.ProbePedTable();
        Console.WriteLine($"[probe] 人群刷新点 {points} 个 / 真实区域 ConfigId {configIds} 种 / 未分配 {unassigned} 个");
        Environment.ExitCode = points > 0 ? 0 : 1;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[probe] 人群刷新点表加载失败: {ex.GetType().Name}: {ex.Message}");
        Environment.ExitCode = 1;
    }
    return;
}

RuntimeLogs.Initialize(
    PrivateServerConfigStore.ResolveProjectPath(config.Logging.Directory),
    Environment.GetEnvironmentVariable("Ananta_RUN_ID"),
    config.Logging.Console.Enabled,
    config.Logging.Packets.Enabled,
    config.Logging.Packets.IncludeHex,
    config.Logging.Packets.IncludeDecoded,
    config.Logging.Packets.MaxBodyBytes);

using var shutdown = new CancellationTokenSource();
Console.CancelKeyPress += (_, e) =>
{
    e.Cancel = true;
    shutdown.Cancel();
};

await new PrivateServerApplication(config).RunAsync(shutdown.Token);
