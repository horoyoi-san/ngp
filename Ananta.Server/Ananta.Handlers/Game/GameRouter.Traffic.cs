using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    
    internal sealed class IntersectionSignal
    {
        internal int TableIndex;
        internal int PeriodIndex;
        internal double NextSwitchAt;      
        internal int[] OpenLanes = [];
    }

    private const string SignalsKey = "Ananta.traffic.signals";

    
    private const float BrakeDecel = 4.0f;

    

    
    private static bool TryGetLaneIntersection(int laneId, out int tableIndex)
        => IntersectionTable.TryGetLaneOwner(laneId, out tableIndex);

    

    
    private static List<IntersectionSignal> SignalsOf(TcpSession session)
    {
        lock (session.Items)
        {
            if (session.Items.TryGetValue(SignalsKey, out var raw) && raw is List<IntersectionSignal> l)
                return l;

            var list = new List<IntersectionSignal>(IntersectionTable.Count);
            var all = IntersectionTable.All;
            for (var i = 0; i < all.Count; i++)
            {
                var it = all[i];
                var pi = Math.Clamp((int)it.CurrentPeriodIndex, 0, Math.Max(0, it.PeriodCount - 1));
                list.Add(new IntersectionSignal
                {
                    TableIndex = i,
                    PeriodIndex = pi,
                    NextSwitchAt = 0.0,        
                    OpenLanes = pi < it.PeriodOpenLanes.Count ? it.PeriodOpenLanes[pi] : [],
                });
            }
            session.Items[SignalsKey] = list;
            return list;
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    internal static async Task<int> TickIntersectionSignalsAsync(
        TcpSession session, CancellationToken token = default)
    {
        var aether = PrivateServerConfigStore.Current.Gameplay.Aether;
        if (!aether.IntersectionUpdateEnabled)
            return 0;

        var periodSeconds = Math.Clamp(aether.IntersectionPeriodSeconds, 1.0, 120.0);
        var signals = SignalsOf(session);
        if (signals.Count == 0)
            return 0;

        var now = LaneDataTimeStamp();
        var all = IntersectionTable.All;
        var sent = 0;

        foreach (var s in signals)
        {
            if (s.NextSwitchAt <= 0.0)
            {
                s.NextSwitchAt = now + periodSeconds;
                continue;
            }
            if (now < s.NextSwitchAt)
                continue;

            var it = all[s.TableIndex];
            var count = Math.Max(1, it.PeriodCount);
            s.PeriodIndex = (s.PeriodIndex + 1) % count;
            s.NextSwitchAt = now + periodSeconds;
            s.OpenLanes = s.PeriodIndex < it.PeriodOpenLanes.Count
                ? it.PeriodOpenLanes[s.PeriodIndex]
                : [];

            var next = (s.PeriodIndex + 1) % count;
            await session.NotifyAsync(MethodId.SyncAetherAIIntersectionUpdateDa, UxSerializer.Serialize(
                new SceneMethods.SyncAetherAIIntersectionUpdateData4229938
                {
                    data = new SceneMethods.ClientTrafficIntersectionPeriodUpdateInfo4229938
                    {
                        IntersectionIndex = (ulong)it.ZoneIndex,
                        CurrentState = (byte)SceneMethods.MassTrafficIntersectionState4229938.Start,
                        CurrentPeriodIndex = (byte)s.PeriodIndex,
                        NextPeriodIndex = (byte)next,
                        RailPeriodIndex = it.RailPeriodIndex,
                    },
                }), token);
            sent++;
        }

        if (sent > 0)
            session.Log.Info($"[TRAFFIC] 信号周期切换 {sent} 个路口（每 {periodSeconds:F0}s 一档）");
        return sent;
    }

    
    private static bool IsLaneOpen(List<IntersectionSignal>? signals, int laneId)
    {
        if (signals is null || signals.Count == 0)
            return true;
        if (!TryGetLaneIntersection(laneId, out var idx) || idx < 0 || idx >= signals.Count)
            return true;
        var open = signals[idx].OpenLanes;
        for (var i = 0; i < open.Length; i++)
            if (open[i] == laneId)
                return true;
        return false;
    }

    

    
    
    
    
    
    internal static (int Intersections, int Periods, int IntersectionLanes, int OpenInPeriod0,
                     int MultiPeriod, string Sample)
        ProbeTraffic()
    {
        var all = IntersectionTable.All;
        var periods = 0;
        var multi = 0;
        var lanes = new HashSet<int>();
        var open0 = 0;
        foreach (var it in all)
        {
            periods += it.PeriodCount;
            if (it.PeriodCount > 1)
                multi++;
            foreach (var l in it.AllLanes)
                lanes.Add(l);
            if (it.PeriodOpenLanes.Count > 0)
                open0 += it.PeriodOpenLanes[0].Length;
        }

        var sample = all.Count == 0
            ? "(空)"
            : $"zone={all[0].ZoneIndex} 周期={all[0].PeriodCount} "
              + $"p0 放行 {all[0].PeriodOpenLanes[0].Length} 条 / "
              + $"p1 放行 {(all[0].PeriodOpenLanes.Count > 1 ? all[0].PeriodOpenLanes[1].Length : 0)} 条";

        return (all.Count, periods, lanes.Count, open0, multi, sample);
    }

    
    
    
    
    
    
    
    
    
    internal static (int Personas, int OkFull, string Detail) ProbeDriverFormworks()
    {
        var spawns = VehicleSpawnCatalog.Ambient;
        var personas = spawns.Select(static s => s.DriverNpcType).Distinct().ToArray();
        var lines = new List<string>();
        var ok = 0;
        foreach (var pid in personas)
        {
            var p = PersonaCatalog.Find(pid);
            var (full, noEcon, noLaunch, sexAge, sample) = AgentCatalogRepository.ProbePersonaMatch(p);
            if (full > 0)
                ok++;
            lines.Add($"  persona {pid} {p?.Name ?? "(不存在)"} "
                      + $"JobTag=[{string.Join(",", p?.JobTags ?? [])}] "
                      + $"Launch=[{string.Join(",", p?.LaunchProperties ?? [])}] "
                      + $"Econ=[{string.Join(",", p?.EconomicLevels ?? [])}] "
                      + $"→ 全约束 {full} / 去Econ {noEcon} / 去Launch {noLaunch} / 仅性别年龄 {sexAge} | {sample}");
        }
        return (personas.Length, ok, string.Join('\n', lines));
    }
}
