using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Gameplay;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using Ananta.Server.State;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    
    
    
    
    
    
    private static bool HackTargetsEnabled
        => PrivateServerConfigStore.Current.Gameplay.SpiritContent.HackTargetsEnabled;

    

    
    
    
    
    
    
    
    [Handler(MethodId.AskHack, HandlerPacketKind.Invoke)]
    private async Task OnAskHack(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskHack4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        await PushHackableUnitsAsync(conn.Session);
        conn.Log.Info($"[JOBABILITY][HACK] AskHack hackType={args.hackType} "
            + $"→ 可骇入单位 = 街边 NPC {StreetNpcs().Count} 个 + 召唤车辆");
    }

    
    
    
    
    
    
    [Handler(MethodId.AskHackingNpcPress, HandlerPacketKind.Invoke)]
    private async Task OnAskHackingNpcPress(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskHackingNpcPress4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][HACK] AskHackingNpcPress instanceid={args.instanceid}");
    }

    
    
    
    
    
    
    
    
    
    
    [Handler(MethodId.AskHackingNpc, HandlerPacketKind.Invoke)]
    private async Task OnAskHackingNpc(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskHackingNpc4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][HACK] AskHackingNpc instanceid={args.instanceid} index={args.index}");
    }

    
    [Handler(MethodId.AskFinishHackingKeyFrame, HandlerPacketKind.Invoke)]
    private async Task OnAskFinishHackingKeyFrame(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskFinishHackingKeyFrame4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][HACK] AskFinishHackingKeyFrame id={args.id}");
    }

    
    
    
    
    
    
    
    
    
    
    
    
    [Handler(MethodId.AskInteractCmd, HandlerPacketKind.Notify)]
    private Task OnAskInteractCmd(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info($"[JOBABILITY][INTERACT] AskInteractCmd {msg.Body.Length}b");
        return Task.CompletedTask;
    }

    
    [Handler(MethodId.AskInteractCmds, HandlerPacketKind.Notify)]
    private Task OnAskInteractCmds(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info($"[JOBABILITY][INTERACT] AskInteractCmds {msg.Body.Length}b");
        return Task.CompletedTask;
    }

    
    [Handler(MethodId.AskHackVehicle, HandlerPacketKind.Invoke)]
    private async Task OnAskHackVehicle(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskHackVehicle4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][HACK] AskHackVehicle vehicle={args.vehicleId} "
            + $"action={(GameMethods.VehicleHackActionType)args.actionType}");
    }

    
    
    
    
    
    
    
    [Handler(MethodId.AskVehicleStartHackerAutonomousDriving, HandlerPacketKind.Invoke)]
    private async Task OnAskVehicleStartHackerAutonomousDriving(Connection conn, UxRpcMessage msg)
    {
        
        
        
        
        
        
        var entityId = LastHackableVehicleId();
        if (entityId == 0)
            entityId = LastSummonedEntity();

        await conn.ReturnAsync(msg, entityId);
        conn.Log.Info($"[JOBABILITY][HACK] AskVehicleStartHackerAutonomousDriving "
            + $"→ 接管车辆 entity={entityId}"
            + (LastHackableVehicleId() != 0 ? "（最近被标可骇入的车）" : "（回退：最后召唤的车）"));
    }

    
    [Handler(MethodId.AskVehicleStopHackerAutonomousDriving, HandlerPacketKind.Notify)]
    private Task OnAskVehicleStopHackerAutonomousDriving(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info("[JOBABILITY][HACK] AskVehicleStopHackerAutonomousDriving");
        return Task.CompletedTask;
    }

    
    [Handler(MethodId.AskHackerBetray, HandlerPacketKind.Notify)]
    private Task OnAskHackerBetray(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskHackerBetray4229938>();
        conn.Log.Info($"[JOBABILITY][HACK] AskHackerBetray target={args.targetId}");
        return Task.CompletedTask;
    }

    
    [Handler(MethodId.ReportBeHacked, HandlerPacketKind.Notify)]
    private Task OnReportBeHacked(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.ReportBeHacked4229938>();
        conn.Log.Info($"[JOBABILITY][HACK] ReportBeHacked uids=[{string.Join(",", args.uids)}]");
        return Task.CompletedTask;
    }

    
    [Handler(MethodId.ReportHackerTetrisCreation, HandlerPacketKind.Notify)]
    private Task OnReportHackerTetrisCreation(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info("[JOBABILITY][HACK] ReportHackerTetrisCreation");
        return Task.CompletedTask;
    }

    
    
    
    
    
    
    [Handler(MethodId.AskStartHackerTetris, HandlerPacketKind.Invoke)]
    private async Task OnAskStartHackerTetris(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnAsync(msg, 1u);
        conn.Log.Info("[JOBABILITY][HACK] AskStartHackerTetris → 1");
    }

    
    [Handler(MethodId.AskFinishHackerTetris, HandlerPacketKind.Invoke)]
    private async Task OnAskFinishHackerTetris(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskFinishHackerTetris4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][HACK] AskFinishHackerTetris score={args.score}");
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static Task MarkHackableAsync(
        TcpSession session, ulong entityId, CancellationToken token = default, bool rememberAsLastVehicle = true)
    {
        if (entityId == 0)
            return Task.CompletedTask;

        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        if (!settings.Enabled)
            return Task.CompletedTask;

        
        
        
        
        
        
        
        if (rememberAsLastVehicle && entityId >= VehicleEntityIdFloor)
            Volatile.Write(ref _lastHackableVehicleId, entityId);

        return session.NotifyAsync(MethodId.SyncUnitHackableState, UxSerializer.Serialize(
            new GameMethods.SyncUnitHackableState4229938
            {
                unitId = entityId,
                isHackable = true,
            }), token);
    }

    
    private const ulong VehicleEntityIdFloor = 300000000000UL;

    private static ulong _lastHackableVehicleId;

    
    internal static ulong LastHackableVehicleId() => Volatile.Read(ref _lastHackableVehicleId);

    
    
    
    
    
    
    
    internal static async Task<int> RemarkAllVehiclesHackableAsync(
        TcpSession session, CancellationToken token = default)
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        if (!settings.Enabled || !settings.MarkVehiclesHackable)
            return 0;

        var marked = 0;
        foreach (var (entityId, _, _, _, _, _, _) in SummonedSnapshot())
        {
            await MarkHackableAsync(session, entityId, token);
            marked++;
        }

        foreach (var entityId in SpawnedPoliceVehicleIds())
        {
            await MarkHackableAsync(session, entityId, token);
            marked++;
        }

        session.Log.Info($"[JOBABILITY][HACK] 重标可骇入车辆 × {marked}"
            + $"（召唤 {SummonedSnapshot().Count} + 警车 {SpawnedPoliceVehicleIds().Count}）");
        return marked;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal const uint HackingAbilityBuffId = 52606133u;

    
    internal const uint HackingAtmosphereNpcBuffId = 52606134u;

    
    internal const uint HackerSpiderBotBuffId = 52606149u;

    
    internal const uint HackerDroneBuffId = 52606150u;

    
    
    
    
    internal static IReadOnlyList<uint> HackingBuffIds => WebTraversal.HackerCapabilityBuffIds;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static async Task GrantHackingAbilityBuffAsync(TcpSession session, CancellationToken token = default)
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        if (!settings.Enabled || !settings.GrantHackingAbilityBuff)
            return;

        if (!session.Items.TryGetValue(WorldStateKey, out var raw)
            || raw is not WorldEntryState state
            || state.ActiveSpiritUnitId == 0)
        {
            return;
        }

        
        if (!WebTraversal.IsHacker(state.ActiveSpiritTemplateId))
        {
            lock (state.SyncRoot)
            {
                state.ActiveHackingBuffInstances.Clear();
                state.HackingBuffsUnitId = 0;
            }
            return;
        }

        var unitId = state.ActiveSpiritUnitId;

        
        var coveredBySnapshot = WebTraversal.CapabilityBuffIds(state.ActiveSpiritTemplateId).ToHashSet();

        List<(uint BuffId, uint InstanceId)> toSend = [];

        lock (state.SyncRoot)
        {
            
            if (state.HackingBuffsUnitId != unitId)
            {
                state.ActiveHackingBuffInstances.Clear();
                state.HackingBuffsUnitId = unitId;
            }

            foreach (var buffId in HackingBuffIds)
            {
                if (coveredBySnapshot.Contains(buffId))
                    continue;
                if (state.ActiveHackingBuffInstances.ContainsKey(buffId))
                    continue;
                var instanceId = state.NextBuffInstanceId++;
                state.ActiveHackingBuffInstances[buffId] = instanceId;
                toSend.Add((buffId, instanceId));
            }
        }

        if (toSend.Count == 0)
            return;

        foreach (var (buffId, instanceId) in toSend)
        {
            await session.NotifyAsync(MethodId.SyncUnitAddBuff,
                UxSerializer.Serialize(WorldCodec.UnitAddBuff(unitId, buffId, instanceId)), token);
        }

        session.Log.Info($"[JOBABILITY][HACK] 兜底补发黑客能力 buff unit={unitId} "
            + $"× {toSend.Count}：{string.Join(", ", toSend.Select(x => $"{x.BuffId}(instance={x.InstanceId})"))}"
            + $"（主路径 SyncUnitBuffList 已覆盖 {coveredBySnapshot.Count} 条）");
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static async Task PushHackableUnitsAsync(TcpSession session, CancellationToken token = default)
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        if (!settings.Enabled)
            return;

        var sent = 0;
        foreach (var npc in StreetNpcs())
        {
            await session.NotifyAsync(MethodId.SyncUnitHackableState, UxSerializer.Serialize(
                new GameMethods.SyncUnitHackableState4229938
                {
                    unitId = npc.Id,
                    isHackable = true,
                }), token);
            sent++;
        }

        if (settings.MarkVehiclesHackable)
        {
            foreach (var (entityId, _, _, _, _, _, _) in SummonedSnapshot())
            {
                await session.NotifyAsync(MethodId.SyncUnitHackableState, UxSerializer.Serialize(
                    new GameMethods.SyncUnitHackableState4229938
                    {
                        unitId = entityId,
                        isHackable = true,
                    }), token);
                sent++;
            }
        }

        session.Log.Info($"[JOBABILITY][HACK] SyncUnitHackableState × {sent}"
            + $"（街边 NPC {StreetNpcs().Count} 个 + 召唤车辆）");
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    internal const uint SpiderStartBuffId = 52800100u;

    
    internal const uint DroneStartBuffId = 52800102u;

    
    internal const uint SpiderBotSkillId = 51938181u;

    
    internal const uint HackerDroneSkillId = 51938183u;

    
    internal static readonly (string Action, string Label, string Trigger, string Note)[] HackerAppTools =
    [
        ("spider", "Spider Bot 蜂形机器人",
            "HackerMenuConfig.Id=2（MenuType=1，BuffID=52606149）→ HackScriptFunc:SpiderSkill() "
            + "→ UseSkillByPid(pid, 51938181)",
            "入口 buff 52606149 是**显示门控**（HackerAppMainPanelStore.appList）；"
            + "技能 51938181 来自 FightSpiritConfig[15021023].TempSkill。"),
        ("drone", "Hacker Drone 黑客无人机",
            "HackerMenuConfig.Id=3（MenuType=1，BuffID=52606150）→ HackScriptFunc:DroneSkill() "
            + "→ UseSkillByPid(pid, 51938183)",
            "同上；技能 51938183。"),
        ("blackout", "大停电",
            "HackerMenuConfig.Id=4 的 FuncAction 是**空字符串** ⇒ App 里点它什么都不做",
            "真实实现 = 黑客天赋 TalentTreeTalentConfig.Id=99906106（JobRequest=401、NeedActive）"
            + " + CreationConfig.Id=56860922『【黑客】大停电-范围干扰』"
            + "（= HackerConfig.HackerTetris_CreationId，即俄罗斯方块小游戏的产物）。"),
        ("forum", "EonBug Forum 黑客论坛",
            "HackerMenuConfig.Id=1（MenuType=0，FuncAction=CheckShowPanel()）→ gPanelManager:CheckShow(703)",
            "面板内容 = SyncHackerJobInfo(64189208).PostInfos（已下发 HackerPostConfig 的 20 条帖子）。"),
    ];

    
    
    
    
    
    
    
    internal static async Task<(int Sent, ulong UnitId, uint TemplateId, bool IsHacker)>
        ForceGrantHackerBuffsAsync(TcpSession session, CancellationToken token = default)
    {
        if (!session.Items.TryGetValue(WorldStateKey, out var raw)
            || raw is not WorldEntryState state
            || state.ActiveSpiritUnitId == 0)
        {
            return (0, 0, 0, false);
        }

        var unitId = state.ActiveSpiritUnitId;
        var templateId = state.ActiveSpiritTemplateId;
        var isHacker = WebTraversal.IsHacker(templateId);

        List<(uint BuffId, uint InstanceId)> toSend = [];
        lock (state.SyncRoot)
        {
            state.ActiveHackingBuffInstances.Clear();
            state.HackingBuffsUnitId = unitId;
            foreach (var buffId in HackingBuffIds)
            {
                var instanceId = state.NextBuffInstanceId++;
                state.ActiveHackingBuffInstances[buffId] = instanceId;
                toSend.Add((buffId, instanceId));
            }
        }

        foreach (var (buffId, instanceId) in toSend)
        {
            await session.NotifyAsync(MethodId.SyncUnitAddBuff,
                UxSerializer.Serialize(WorldCodec.UnitAddBuff(unitId, buffId, instanceId)), token);
        }

        session.Log.Info($"[JOBABILITY][HACK] 调试强推黑客能力 buff unit={unitId} "
            + $"template={templateId} isHacker={isHacker} × {toSend.Count}");

        return (toSend.Count, unitId, templateId, isHacker);
    }

    
    
    
    
    
    
    
    internal static async Task<(bool Ok, ulong UnitId, uint InstanceId)> TriggerBuffAsync(
        TcpSession session, uint buffId, CancellationToken token = default)
    {
        if (!session.Items.TryGetValue(WorldStateKey, out var raw)
            || raw is not WorldEntryState state
            || state.ActiveSpiritUnitId == 0
            || buffId == 0)
        {
            return (false, 0, 0);
        }

        var unitId = state.ActiveSpiritUnitId;
        uint instanceId;
        lock (state.SyncRoot)
            instanceId = state.NextBuffInstanceId++;

        await session.NotifyAsync(MethodId.SyncUnitAddBuff,
            UxSerializer.Serialize(WorldCodec.UnitAddBuff(unitId, buffId, instanceId)), token);

        session.Log.Info($"[JOBABILITY][HACK] 调试触发 buff unit={unitId} buff={buffId} instance={instanceId}");
        return (true, unitId, instanceId);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static async Task PushHackerBatteryAsync(TcpSession session, CancellationToken token = default)
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        if (!settings.Enabled)
            return;

        await session.NotifyAsync(
            MethodId.SyncHackerBatteryCurrentAndTotalCount,
            BuildHackerBatteryBytes(settings.HackerBatteryTotal, settings.HackerBatteryCurrent),
            token);

        session.Log.Info($"[JOBABILITY][HACK] SyncHackerBatteryCurrentAndTotalCount "
            + $"{settings.HackerBatteryCurrent}/{settings.HackerBatteryTotal}"
            + "（缺这条 ⇒ hackInfo=nil ⇒ 点骇入被客户端本地拦下）");

        if (settings.SendHackerBatteryCostInfo)
        {
            
            
            await session.NotifyAsync(MethodId.SyncHackerBatteryCostInfo, new byte[] { 0xFF, 0x01 }, token);
            session.Log.Info("[JOBABILITY][HACK] SyncHackerBatteryCostInfo 空字典");
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static byte[] BuildHackerBatteryBytes(uint total, uint current)
    {
        var buf = new byte[9];
        buf[0] = 0xFF;                                      
        BitConverter.TryWriteBytes(buf.AsSpan(1, 4), total);
        BitConverter.TryWriteBytes(buf.AsSpan(5, 4), current);
        return buf;
    }

    

    
    
    
    
    
    
    
    [Handler(MethodId.AskPoliceDispatch, HandlerPacketKind.Invoke)]
    private async Task OnAskPoliceDispatch(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskPoliceDispatch4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        await SpawnPoliceVehiclesAsync(conn.Session, args.dispatchId);
    }

    
    [Handler(MethodId.AskPoliceStopHelicopterDispatch, HandlerPacketKind.Invoke)]
    private async Task OnAskPoliceStopHelicopterDispatch(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);
        await DespawnPoliceVehiclesAsync(conn.Session);
    }

    
    [Handler(MethodId.AskPoliceVehicleHorn, HandlerPacketKind.Notify)]
    private Task OnAskPoliceVehicleHorn(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskPoliceVehicleHorn4229938>();
        conn.Log.Info($"[JOBABILITY][POLICE] AskPoliceVehicleHorn entity={args.entityId} play={args.play}");
        return Task.CompletedTask;
    }

    
    [Handler(MethodId.AskPoliceDistanceMonitorTrigger, HandlerPacketKind.Notify)]
    private Task OnAskPoliceDistanceMonitorTrigger(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskPoliceDistanceMonitorTrigger4229938>();
        conn.Log.Info($"[JOBABILITY][POLICE] AskPoliceDistanceMonitorTrigger distance={args.distance:F1}");
        return Task.CompletedTask;
    }

    
    
    
    
    
    
    [Handler(MethodId.AskTeleportToPoliceStation, HandlerPacketKind.Invoke)]
    private async Task OnAskTeleportToPoliceStation(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info("[JOBABILITY][POLICE] AskTeleportToPoliceStation");
    }

    
    [Handler(MethodId.AskAcceptPoliceTask, HandlerPacketKind.Invoke)]
    private Task OnAskAcceptPoliceTask(Connection conn, UxRpcMessage msg)
    {
        SessionState.Update(s => s.PoliceTaskAccepted = true);
        conn.Log.Info("[JOBABILITY][POLICE] AskAcceptPoliceTask");
        return conn.ReturnEmptyOkAsync(msg);
    }

    
    [Handler(MethodId.AskSkipPoliceTask, HandlerPacketKind.Invoke)]
    private Task OnAskSkipPoliceTask(Connection conn, UxRpcMessage msg)
    {
        conn.Log.Info("[JOBABILITY][POLICE] AskSkipPoliceTask");
        return conn.ReturnEmptyOkAsync(msg);
    }

    
    [Handler(MethodId.AskGiveUpPoliceTask, HandlerPacketKind.Invoke)]
    private Task OnAskGiveUpPoliceTask(Connection conn, UxRpcMessage msg)
    {
        SessionState.Update(s => s.PoliceTaskAccepted = false);
        conn.Log.Info("[JOBABILITY][POLICE] AskGiveUpPoliceTask");
        return conn.ReturnEmptyOkAsync(msg);
    }

    
    [Handler(MethodId.AskAbandonPoliceTask, HandlerPacketKind.Invoke)]
    private Task OnAskAbandonPoliceTask(Connection conn, UxRpcMessage msg)
    {
        SessionState.Update(s => s.PoliceTaskAccepted = false);
        conn.Log.Info("[JOBABILITY][POLICE] AskAbandonPoliceTask");
        return conn.ReturnEmptyOkAsync(msg);
    }

    
    [Handler(MethodId.AddPoliceChargingProgress, HandlerPacketKind.Invoke)]
    private async Task OnAddPoliceChargingProgress(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AddPoliceChargingProgress4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][POLICE] AddPoliceChargingProgress event={args.chargingEventId}");
    }

    
    [Handler(MethodId.UsePoliceChargingProgress, HandlerPacketKind.Invoke)]
    private async Task OnUsePoliceChargingProgress(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.UsePoliceChargingProgress4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][POLICE] UsePoliceChargingProgress skill={args.info.ChargingSkillId}");
    }

    
    [Handler(MethodId.AskPoliceTrailTeleport, HandlerPacketKind.Invoke)]
    private async Task OnAskPoliceTrailTeleport(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskPoliceTrailTeleport4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][POLICE] AskPoliceTrailTeleport case={args.caseId}");
    }

    
    
    
    
    [Handler(MethodId.AskRPSInterrogationSelectOption, HandlerPacketKind.Invoke)]
    private async Task OnAskRPSInterrogationSelectOption(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskRPSInterrogationSelectOption4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][POLICE] AskRPSInterrogationSelectOption case={args.caseId} "
            + $"card={args.Card.CardType}/{args.Card.StarLevel}");
    }

    
    [Handler(MethodId.AskPoliceEffectiveExam, HandlerPacketKind.Invoke)]
    private async Task OnAskPoliceEffectiveExam(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info("[JOBABILITY][POLICE] AskPoliceEffectiveExam（检查路人）");
    }

    
    [Handler(MethodId.AskPoliceTakeCaseReward, HandlerPacketKind.Invoke)]
    private async Task OnAskPoliceTakeCaseReward(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskPoliceTakeCaseReward4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][POLICE] AskPoliceTakeCaseReward case={args.caseId}");
    }

    
    [Handler(MethodId.AskReadPoliceFakeClueAgentInfoList, HandlerPacketKind.Invoke)]
    private async Task OnAskReadPoliceFakeClueAgentInfoList(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskReadPoliceFakeClueAgentInfoList4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][POLICE] AskReadPoliceFakeClueAgentInfoList "
            + $"indexes=[{string.Join(",", args.clueAgentInfoIndexList)}]");
    }

    
    [Handler(MethodId.AskPoliceFakeFileAcceptTaskEvent, HandlerPacketKind.Invoke)]
    private async Task OnAskPoliceFakeFileAcceptTaskEvent(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskPoliceFakeFileAcceptTaskEvent4229938>();
        SessionState.Update(s => s.PoliceFakeFileAccepted.Add(args.fakeFileId));
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][POLICE] AskPoliceFakeFileAcceptTaskEvent file={args.fakeFileId}");
    }

    
    [Handler(MethodId.AskPoliceFakeFileTakeReward, HandlerPacketKind.Invoke)]
    private async Task OnAskPoliceFakeFileTakeReward(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskPoliceFakeFileTakeReward4229938>();
        SessionState.Update(s => s.PoliceFakeFileRewarded.Add(args.fakeFileId));
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][POLICE] AskPoliceFakeFileTakeReward file={args.fakeFileId}");
    }

    
    
    
    
    
    
    
    internal static async Task SpawnPoliceVehiclesAsync(
        TcpSession session, uint dispatchId, CancellationToken token = default)
    {
        var state = SessionState.Current;
        var config = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        if (!config.Enabled)
            return;

        var vehicleConfigId = PoliceVehicleConfigId();
        if (vehicleConfigId == 0)
        {
            session.Log.Warn("[JOBABILITY][POLICE] 找不到可用警车 config，跳过 SyncSpawnPoliceVehicles");
            return;
        }

        var entityId = (ulong)Interlocked.Increment(ref _policeVehicleSeq);
        lock (PoliceVehiclesSync)
            _policeVehicles.Add(entityId);

        
        var x = (float)state.PositionX;
        var y = (float)state.PositionY;
        var z = (float)state.PositionZ;
        var facing = (float)state.Facing;

        
        var spawnZ = z + 6f * MathF.Cos(facing);
        var spawnX = x + 6f * MathF.Sin(facing);

        var info = new GameMethods.PoliceVehicleSpawnClientInfo
        {
            Id = entityId,
            VehicleId = vehicleConfigId,
            Position = new Auto.UXVector3 { X = spawnX, Y = y, Z = spawnZ },
            Facing = facing,
            EulerAngles = new Auto.UXVector3 { X = 0f, Y = facing, Z = 0f },
        };

        
        
        var spawnConfig = new GameMethods.PoliceVehicleSpawnConfigInfo
        {
            ChaseRange = 60f,
            ChaseDirectlyRange = 25f,
            ApprehendRange = 6f,
            NavConfigId = 0,
            ChaseDirectlyConfigId = 0,
            PatrolSpeed = 8f,
            ChaseSpeed = 16f,
            ChaseDirectlySpeed = 22f,
        };

        await session.NotifyAsync(MethodId.SyncSpawnPoliceVehicles, UxSerializer.Serialize(
            new GameMethods.SyncSpawnPoliceVehicles4229938
            {
                spawnInfos = [info],
                configInfo = spawnConfig,
            }), token);

        session.Log.Info($"[JOBABILITY][POLICE] SyncSpawnPoliceVehicles dispatch={dispatchId} "
            + $"entity={entityId} vehicle={vehicleConfigId} "
            + $"pos=({spawnX:F1},{y:F1},{spawnZ:F1}) facing={facing:F2}");

        
        
        
        
        
        if (config.MarkVehiclesHackable)
        {
            await MarkHackableAsync(session, entityId, token);
            session.Log.Info($"[JOBABILITY][HACK] 警车已标可骇入 entity={entityId}"
                + "（不标 ⇒ 客户端不发 AskHackVehicle ⇒ 骇不进去）");
        }
    }

    
    internal static async Task DespawnPoliceVehiclesAsync(TcpSession session, CancellationToken token = default)
    {
        ulong[] ids;
        lock (PoliceVehiclesSync)
        {
            ids = [.. _policeVehicles];
            _policeVehicles.Clear();
        }

        if (ids.Length == 0)
            return;

        await session.NotifyAsync(MethodId.SyncDestroyPoliceVehicles, UxSerializer.Serialize(
            new GameMethods.SyncDestroyPoliceVehicles4229938 { entityIds = [.. ids] }), token);
        session.Log.Info($"[JOBABILITY][POLICE] SyncDestroyPoliceVehicles [{string.Join(",", ids)}]");
    }

    
    private static long _policeVehicleSeq = 700000000000L;

    private static readonly List<ulong> _policeVehicles = [];
    private static readonly object PoliceVehiclesSync = new();

    
    internal static IReadOnlyList<ulong> SpawnedPoliceVehicleIds()
    {
        lock (PoliceVehiclesSync)
            return [.. _policeVehicles];
    }

    
    
    
    
    
    private static uint PoliceVehicleConfigId()
    {
        foreach (var id in VehicleCatalog4229938.PoliceVehicleIds)
            if (id != 0)
                return id;

        var last = LastSummonedEntity();
        if (last != 0 && TryGetSummoned(last, out var vehicle) && vehicle is not null)
            return vehicle.ConfigId;

        return 0;
    }

    
    
    
    
    
    
    private static Task ReturnNeutralAsync(Connection conn, UxRpcMessage msg)
        => DefaultReturnCatalog4229938.TryGet(msg.MethodId, out var body, out _)
            ? conn.ReturnAsync(msg, body)
            : conn.ReturnEmptyOkAsync(msg);

    

    
    
    
    
    
    
    
    
    
    [Handler(MethodId.AskGetJobBoardInfo, HandlerPacketKind.Invoke)]
    private async Task OnAskGetJobBoardInfo(Connection conn, UxRpcMessage msg)
    {
        var state = SessionState.Current;
        var rows = SpiritContentCatalogRepository.JobBoard;

        var joinedClasses = new HashSet<uint>();
        foreach (var (spiritId, jobs) in state.SpiritJobs)
        {
            _ = spiritId;
            foreach (var jobId in jobs)
            {
                var cls = SpiritContentCatalogRepository.JobLevel(jobId)?.JobClass ?? 0u;
                if (cls != 0)
                    joinedClasses.Add(cls);
            }
        }

        var info = new GameMethods.JobBoardInfo
        {
            JoinedJobCount = (uint)joinedClasses.Count,
            MaxJobCount = (uint)rows.Count,
        };

        
        foreach (var group in rows.GroupBy(x => CountryOfBoard(x.Id)))
        {
            var list = new GameMethods.JobBoardEntryList();
            foreach (var row in group)
            {
                list.Entries.Add(new GameMethods.JobBoardEntry
                {
                    BoardId = row.Id,
                    JobId = row.JobClassId,
                    JobClassId = row.JobClassId,
                    State = joinedClasses.Contains(row.JobClassId)
                        ? GameMethods.JobBoardJobState.Joined
                        : GameMethods.JobBoardJobState.Available,
                    UnlockProgress = row.UnlockProgress,
                    UnlockTarget = row.UnlockProgress,
                    CanResign = row.CanResign,
                });
            }
            info.CountryJobEntries[group.Key] = list;
        }

        await conn.ReturnAsync(msg, info);
        conn.Log.Info($"[JOBABILITY][BOARD] AskGetJobBoardInfo → {rows.Count} 条职位 "
            + $"已接职业大类={joinedClasses.Count}");
    }

    
    private static uint CountryOfBoard(uint boardId) => (boardId % 3) + 1;

    

    
    
    
    
    
    
    
    
    
    
    [Handler(MethodId.AskGetTruckJobOrders, HandlerPacketKind.Invoke)]
    private Task OnAskGetTruckJobOrders(Connection conn, UxRpcMessage msg)
        => conn.ReturnAsync(msg, BuildTruckOrderViewBytes(conn));

    
    [Handler(MethodId.AskRefreshTruckOrder, HandlerPacketKind.Invoke)]
    private Task OnAskRefreshTruckOrder(Connection conn, UxRpcMessage msg)
    {
        SessionState.Update(s => s.TruckOrdersRefreshed++);
        
        SessionState.Update(s => s.TruckOrderSeed += 17);
        return conn.ReturnAsync(msg, BuildTruckOrderViewBytes(conn));
    }

    
    
    
    
    
    
    [Handler(MethodId.AskAcceptTruckJobOrder, HandlerPacketKind.Invoke)]
    private async Task OnAskAcceptTruckJobOrder(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskAcceptTruckJobOrder4229938>();
        SessionState.Update(s =>
        {
            s.TruckCurrentOrderId = args.id;
            if (!s.TruckAcceptedOrders.Contains(args.id))
                s.TruckAcceptedOrders.Add(args.id);
        });

        await conn.ReturnAsync(msg, BuildAcceptedOrderBytes(args.id));
        conn.Log.Info($"[JOBABILITY][TRUCK] AskAcceptTruckJobOrder order={args.id} → 已接单");
    }

    
    [Handler(MethodId.AskPreSettleTruckOrder, HandlerPacketKind.Invoke)]
    private async Task OnAskPreSettleTruckOrder(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskPreSettleTruckOrder4229938>();
        await conn.ReturnAsync(msg, BuildAcceptedOrderBytes(args.uniqueId));
        conn.Log.Info($"[JOBABILITY][TRUCK] AskPreSettleTruckOrder order={args.uniqueId} "
            + $"cargo={args.cargoSettleList.Count} → 已预结算");
    }

    
    [Handler(MethodId.AskSettleTruckOrder, HandlerPacketKind.Invoke)]
    private async Task OnAskSettleTruckOrder(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskSettleTruckOrder4229938>();
        SessionState.Update(s => s.TruckOrdersSettled++);
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][TRUCK] AskSettleTruckOrder order={args.uniqueId}");
    }

    
    [Handler(MethodId.AskObsoleteTruckJobOrder, HandlerPacketKind.Invoke)]
    private async Task OnAskObsoleteTruckJobOrder(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskObsoleteTruckJobOrder4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][TRUCK] AskObsoleteTruckJobOrder order={args.orderId}");
    }

    
    [Handler(MethodId.AskAutoAcceptTruckJobOrder, HandlerPacketKind.Invoke)]
    private async Task OnAskAutoAcceptTruckJobOrder(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskAutoAcceptTruckJobOrder4229938>();
        SessionState.Update(s => s.TruckAutoAccept = args.bAutoAccept);
        await conn.ReturnAsync(msg, args.bAutoAccept);
        conn.Log.Info($"[JOBABILITY][TRUCK] AskAutoAcceptTruckJobOrder auto={args.bAutoAccept}");
    }

    
    [Handler(MethodId.AskSetTruckJobDefaultVehicleId, HandlerPacketKind.Invoke)]
    private async Task OnAskSetTruckJobDefaultVehicleId(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskSetTruckJobDefaultVehicleId4229938>();
        SessionState.Update(s => s.TruckDefaultVehicleId = args.defaultVehicleId);
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][TRUCK] AskSetTruckJobDefaultVehicleId vehicle={args.defaultVehicleId}");
    }

    
    [Handler(MethodId.AskResetTruckOrderGoods, HandlerPacketKind.Invoke)]
    private async Task OnAskResetTruckOrderGoods(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskResetTruckOrderGoods4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][TRUCK] AskResetTruckOrderGoods order={args.orderId}");
    }

    
    [Handler(MethodId.AskStartTruckOrderGuide, HandlerPacketKind.Invoke)]
    private async Task OnAskStartTruckOrderGuide(Connection conn, UxRpcMessage msg)
    {
        SessionState.Update(s => s.TruckGuideClicked = true);
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info("[JOBABILITY][TRUCK] AskStartTruckOrderGuide");
    }

    
    [Handler(MethodId.AskGetTruckSatisfactionAverage, HandlerPacketKind.Invoke)]
    private async Task OnAskGetTruckSatisfactionAverage(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnAsync(msg, 100f);
        conn.Log.Info("[JOBABILITY][TRUCK] AskGetTruckSatisfactionAverage → 100");
    }

    
    [Handler(MethodId.AskGetAcceptedOrderWraps, HandlerPacketKind.Invoke)]
    private async Task OnAskGetAcceptedOrderWraps(Connection conn, UxRpcMessage msg)
    {
        var state = SessionState.Current;
        var orders = new List<byte[]>();
        foreach (var orderId in state.TruckAcceptedOrders.Take(8))
            orders.Add(BuildAcceptedOrderBytes(orderId));
        await conn.ReturnAsync(msg, TruckOrderCodec4229938.BuildOrderListBytes(orders));
        conn.Log.Info($"[JOBABILITY][TRUCK] AskGetAcceptedOrderWraps → {orders.Count} 张");
    }

    
    
    
    
    
    
    [Handler(MethodId.AskGetFinishedOrderWraps, HandlerPacketKind.Invoke)]
    private async Task OnAskGetFinishedOrderWraps(Connection conn, UxRpcMessage msg)
    {
        var view = new GameMethods.ClientFinishedTruckOrderView();
        await conn.ReturnAsync(msg, view);
        conn.Log.Info("[JOBABILITY][TRUCK] AskGetFinishedOrderWraps → 空");
    }

    
    
    
    
    [Handler(MethodId.AskQueryTruckPosInfo, HandlerPacketKind.Invoke)]
    private async Task OnAskQueryTruckPosInfo(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskQueryTruckPosInfo4229938>();
        var empty = new List<GameMethods.TruckPosInfo>();
        await conn.ReturnAsync(msg,
            UxSerializer.Serialize(new GameMethods.AskQueryTruckPosInfoResult
            {
                pickup = empty,
                delivery = empty,
            }));
        conn.Log.Info($"[JOBABILITY][TRUCK] AskQueryTruckPosInfo pickup={args.pickupIds.Count} "
            + $"delivery={args.deliveryIds.Count} → 空");
    }

    
    [Handler(MethodId.AskDoTruckNpcAction, HandlerPacketKind.Invoke)]
    private async Task OnAskDoTruckNpcAction(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskDoTruckNpcAction4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][TRUCK] AskDoTruckNpcAction instance={args.instanceId} event={args.eventId}");
    }

    
    [Handler(MethodId.AskAddTruckOrderSpecialPointReward, HandlerPacketKind.Invoke)]
    private async Task OnAskAddTruckOrderSpecialPointReward(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskAddTruckOrderSpecialPointReward4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][TRUCK] AskAddTruckOrderSpecialPointReward "
            + $"order={args.orderId} point={args.pointId}");
    }

    
    [Handler(MethodId.AskAddTruckOrderSpecialPointRewards, HandlerPacketKind.Invoke)]
    private async Task OnAskAddTruckOrderSpecialPointRewards(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskAddTruckOrderSpecialPointRewards4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[JOBABILITY][TRUCK] AskAddTruckOrderSpecialPointRewards "
            + $"orders=[{string.Join(",", args.orderIds)}] point={args.pointId}");
    }

    
    
    
    
    
    
    private static byte[] BuildTruckOrderViewBytes(Connection conn)
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        var state = SessionState.Current;

        var orders = settings.TruckOrdersEnabled
            ? BuildTruckOrders(state, Math.Clamp(settings.TruckOrderCount, 0, 8))
            : [];

        return TruckOrderCodec4229938.BuildOrderViewBytes(
            orders,
            rewardPointSum: 0,
            customerSatisfactionAverage: 100f,
            currentOrderId: state.TruckCurrentOrderId,
            truckGuideClicked: state.TruckGuideClicked,
            autoAccept: state.TruckAutoAccept,
            defaultVehicleId: state.TruckDefaultVehicleId,
            totalIncome: 0);
    }

    
    
    
    
    
    private static List<byte[]> BuildTruckOrders(PlayerState state, int count)
    {
        var result = new List<byte[]>(count);
        if (count <= 0)
            return result;

        var px = (float)state.PositionX;
        var py = (float)state.PositionY;
        var pz = (float)state.PositionZ;

        
        var seed = state.TruckOrderSeed == 0 ? 1001u : state.TruckOrderSeed;
        var now = (uint)DateTimeOffset.UtcNow.ToUnixTimeSeconds();

        for (var i = 0; i < count; i++)
        {
            var orderId = seed + (uint)i;
            
            var angle = i * 2.1f;
            var startX = px + MathF.Cos(angle) * 60f;
            var startZ = pz + MathF.Sin(angle) * 60f;
            var endX = px + MathF.Cos(angle + 1.2f) * 240f;
            var endZ = pz + MathF.Sin(angle + 1.2f) * 240f;

            result.Add(TruckOrderCodec4229938.BuildOrder(
                orderId,
                startX, py, startZ,
                endX, py, endZ,
                cargoId: 10004u + (uint)(i % 3),   
                npcId: 141879094u,                 
                consigneeId: 141879100u + (uint)i,
                rudeId: 1u,
                characterId: 301u,
                limitAcceptSeconds: 300,
                limitFinishSeconds: 600,
                estimatedFinishSeconds: 300,
                basePointReward: 10 + i * 5,
                dropCoefficient: 1f,
                dropMoney: 100 + i * 50,
                isEmergency: i == 2,
                isDailyOrder: true,
                orderType: 1u));
        }

        _ = now;
        return result;
    }

    
    
    
    
    
    private static byte[] BuildAcceptedOrderBytes(uint orderId)
    {
        var state = SessionState.Current;
        
        var existing = BuildTruckOrders(state, Math.Clamp(
            PrivateServerConfigStore.Current.Gameplay.SpiritContent.TruckOrderCount, 0, 8))
            .FirstOrDefault(o => TruckOrderCodec4229938.ReadU32(o, 179) == orderId);

        var now = TruckOrderCodec4229938.NowUnix();
        if (existing is not null)
            return TruckOrderCodec4229938.MarkAccepted(existing, orderId, now);

        
        var order = TruckOrderCodec4229938.BuildOrder(
            orderId,
            0f, 0f, 0f,
            0f, 0f, 0f,
            cargoId: 0u,
            npcId: 0u,
            consigneeId: 0u,
            rudeId: 0u,
            characterId: 0u,
            limitAcceptSeconds: 0,
            limitFinishSeconds: 0,
            estimatedFinishSeconds: 0,
            basePointReward: 0,
            dropCoefficient: 0f,
            dropMoney: 0,
            isDailyOrder: false,
            orderType: 0u);
        return TruckOrderCodec4229938.MarkAccepted(order, orderId, now);
    }

    

    
    
    
    
    
    
    internal static int ProbeJobAbility()
    {
        var ok = true;

        Console.WriteLine($"[probe] 配置载入: {SpiritContentCatalogRepository.Summary()}");
        Console.WriteLine();

        Console.WriteLine("[probe] ── 职业等级（UrbanJobLevelConfig 的上限 vs UrbanJobConfig 的档位） ──");
        foreach (var cls in SpiritContentCatalogRepository.AllJobClasses)
        {
            var max = SpiritContentCatalogRepository.MaxJobLevelOf(cls.Id);
            var top = SpiritContentCatalogRepository.TopJobLevelOf(cls.Id);
            var topName = SpiritContentCatalogRepository.JobLevel(top)?.Name ?? "-";
            var chain = string.Join(" → ", SpiritContentCatalogRepository.JobLevelChain(cls.Id)
                .Select(x => $"{x.Id}({x.Name},Lv{x.Level})"));
            Console.WriteLine($"[probe]   {cls.Id} {cls.ClassName,-20} maxLv={max,-3} top={top}({topName})  {chain}");
        }
        Console.WriteLine();

        Console.WriteLine("[probe] ── 六维属性 / 都市能力 ──");
        Console.WriteLine($"[probe]   六维项数={SpiritContentCatalogRepository.UrbanAttributeCount} "
            + $"满值={SpiritContentCatalogRepository.UrbanAttributeMaxValue} "
            + $"都市能力={SpiritContentCatalogRepository.AllUrbanAbilities.Count} 条");
        Console.WriteLine();

        Console.WriteLine("[probe] ── 天赋 ──");
        Console.WriteLine($"[probe]   TalentTreeTalentConfig 总节点={SpiritContentCatalogRepository.AllTalentNodes.Count}");
        foreach (var tree in SpiritContentCatalogRepository.AllTalentTrees)
        {
            var nodes = SpiritContentCatalogRepository.TalentNodes(tree.Id);
            Console.WriteLine($"[probe]   树 {tree.Id} {tree.Name,-20} jobClass={tree.JobClassId,-9} "
                + $"gameplay={tree.GameplayId} spirits=[{string.Join(",", tree.SpiritIds)}] 节点={nodes.Count}");
        }
        Console.WriteLine();

        Console.WriteLine("[probe] ── 求职板（UrbanJobBoardConfig） ──");
        foreach (var b in SpiritContentCatalogRepository.JobBoard)
            Console.WriteLine($"[probe]   board={b.Id} jobClass={b.JobClassId} '{b.JobTitle}' 薪资={b.Salary} 可辞职={b.CanResign}");
        Console.WriteLine();

        Console.WriteLine("[probe] ── 警车 config（VehicleConfig 里名字含 Patrol/NCCA） ──");
        foreach (var id in VehicleCatalog4229938.PoliceVehicleIds)
            Console.WriteLine($"[probe]   {id} "
                + (VehicleCatalog4229938.TryGet(id, out var e) ? $"{e.Name} / {e.Model}" : "?"));
        Console.WriteLine();

        Console.WriteLine("[probe] ── S2C 字节探针（长度必须等于手算值） ──");
        ok &= Check("SyncUnitHackableState", ProbeUnitHackableBytes(), 9,
            "08×unitId + 01×bool");
        ok &= Check("SyncDestroyPoliceVehicles(1)", ProbeDestroyPoliceBytes(), 10,
            "FF + 01 + 08×id");
        ok &= Check("SyncSpawnPoliceVehicles(1)", ProbeSpawnPoliceBytes(), 76,
            "FF(list)+02(count)+FF(item)+08(id)+04(vehicleId)+0C(pos)+04(facing)+0C(euler)+FF(cfg)+32(8×float) = 76");
        ok &= Check("JobBoardInfo(1 条)", ProbeJobBoardBytes(), -1,
            "见 hex（字段顺序：u32/u32/dict7/dict7）");
        ok &= Check("ClientTruckOrderView(空)", ProbeTruckOrderBytes(), 27,
            "FF + FF01 + 4 + 4 + 4 + 1 + FF01 + 1 + 4 + 4 = 27");

        Console.WriteLine();
        Console.WriteLine("[probe] ── 骇入（西摩）：能力 buff 全集 + 可骇目标开关 + 电量包 ──");
        Console.WriteLine($"[probe]   GrantHackingAbilityBuff = "
            + $"{PrivateServerConfigStore.Current.Gameplay.SpiritContent.GrantHackingAbilityBuff}");
        Console.WriteLine($"[probe]   黑客角色模板 = {WebTraversal.HackerSpiritTemplateId}"
            + "（FightSpiritConfig.DefaultUrbanJob = 401 ⇒ Seymour 15021023）");
        Console.WriteLine("[probe]   ★★★ 骇入门控是**逐技能**的，不是一个总开关（2026-09-23 第 12 轮反汇编定案）：");
        Console.WriteLine("[probe]     HackManager.OnUpdate(0x1332E2D0):  cmp [this+0xE0],0 ; je <ret>");
        Console.WriteLine("[probe]         ⇒ HasGlobalHackAble==0 时目标选择器整个不跑（中键选项恒无）");
        Console.WriteLine("[probe]     HackTargetSelector.SelectUnitTarget(0x133425AB):");
        Console.WriteLine("[probe]         HasBuff(52606133 HackingAbility) || HasBuff(52899024 TempHackingAbility)");
        Console.WriteLine("[probe]         && HasBuff(52606134 HackingAtmosphereNPC)");
        Console.WriteLine("[probe]     NpcHackSkillBase.CanUse(0x13339E90):");
        Console.WriteLine("[probe]         HasBuff(HackerConfig.HackNPCAbilityBuff[this.NpcHackType])");
        Console.WriteLine("[probe]     BuffUtils.HasBuff → UnitsManager.GetUnit(pid).BuffModule.hasBuff(buffId)（按 buffId 集合查表）");
        Console.WriteLine("[probe]     ⇒ 缺任意一条，HackManager.GetUnitHackBtns(0x1332EC00) 返回**空列表**");
        Console.WriteLine("[probe]       ⇒ 骇入面板一个按钮都没有 ⇒ 表现仍然是「没有骇入选项」");
        Console.WriteLine("[probe]   下发方式 = 随单位的**初始 buff 列表**（SyncUnitBuffList 68118081）：");
        Console.WriteLine("[probe]     WebTraversal.CapabilityBuffIds(15021023) —— 登录 / 直切 / 时间线换人三条路都会走到");
        Console.WriteLine("[probe]     SyncUnitAddBuff(68596304) 只是兜底（GameRouter.GrantHackingAbilityBuffAsync）");
        var hackWhy = new Dictionary<uint, string>
        {
            [HackingAbilityBuffId] = "HackingAbility 骇入总开关 ⇒ 缺它完全没有骇入 UI，一个请求都不发",
            [HackingAtmosphereNpcBuffId] = "HackingAtmosphereNPC ⇒ SelectUnitTarget 第二道判定",
            [52606135u] = "PeekMessage 偷看短信（HackNPCAbilityBuff[0]）",
            [52606136u] = "ListenCall 偷听电话（[1]）",
            [52606137u] = "PhoneRinging 分心（[2]）",
            [52606138u] = "PhoneMusic 外放音乐（[3]）",
            [52606161u] = "StealMoney 偷钱（[4]）",
            [52606162u] = "StealFans 偷粉丝（[5]）",
            [52606178u] = "EnemyDistract 干扰（[6]）",
            [52606179u] = "EnemyRebel 叛变（[7]）",
            [52606167u] = "HackVehicleAbilityBuff 骇入车流载具",
            [52606168u] = "HackVehicleSkillBuff[1] 骇入载具-加速技能",
            [HackerSpiderBotBuffId] = "HackerMenuConfig.Id=2 显示门控 ⇒ 缺它「Spider Bot」不显示",
            [HackerDroneBuffId] = "HackerMenuConfig.Id=3 显示门控 ⇒ 缺它「Hacker Drone」不显示",
        };
        var configuredHackBuffs = PrivateServerConfigStore.Current.Gameplay.SpiritContent.HackerAbilityBuffIds;
        Console.WriteLine($"[probe]   黑客能力 buff 组 = {configuredHackBuffs.Length} 条：");
        foreach (var bid in configuredHackBuffs)
        {
            Console.WriteLine($"[probe]     {bid} ← "
                + (hackWhy.TryGetValue(bid, out var why) ? why : "（未登记说明）"));
        }
        Console.WriteLine("[probe]   正式版来源 = UrbanBadgeConfig.JobId=401 的职业徽章");
        Console.WriteLine("[probe]     19001102 Hacking 101 → [52606133]");
        Console.WriteLine("[probe]     19001103 Nowhere to Hide → [52606134,52606135,52606137,52606161]");
        Console.WriteLine("[probe]     19001108 Watch Your Step → [52606149]");
        Console.WriteLine("[probe]     19001109 Eyes on the Sky → [52606150]");
        Console.WriteLine("[probe]     19001110 骇入载具能力 → [52606167,52606168]");
        Console.WriteLine("[probe]     （徽章走 SyncUrbanBadgeInfo 64600925，**LuaOnly**；私服不发 ⇒ 一条 buff 都没有）");
        Console.WriteLine("[probe]   HackerConfig.static.json: HackNPCDistance=30 HackNPCAngel=90 HackVehicleDistance=30");
        var sc = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        Console.WriteLine($"[probe]   HackTargetsEnabled(EnableHack) = {sc.HackTargetsEnabled}"
            + "  ← false 会让街上每个 NPC 都不可骇入");
        Console.WriteLine($"[probe]   电量 = {sc.HackerBatteryCurrent}/{sc.HackerBatteryTotal}"
            + "  ← 缺 SyncHackerBatteryCurrentAndTotalCount ⇒ 客户端本地拦下 AskHack");
        Console.WriteLine($"[probe]   SendHackerBatteryCostInfo = {sc.SendHackerBatteryCostInfo}");
        Console.WriteLine("[probe]   黑客 App 四条菜单的触发链路（HackerMenuConfig，客户端配置）：");
        foreach (var tool in HackerAppTools)
        {
            Console.WriteLine($"[probe]     [{tool.Action}] {tool.Label}");
            Console.WriteLine($"[probe]        {tool.Trigger}");
        }
        
        
        
        
        
        Console.WriteLine("[probe]   客户端技能（Spider Bot / Hacker Drone）服务端放行检查：");
        foreach (var (skillId, label) in new (uint, string)[]
        {
            (SpiderBotSkillId, "召唤蜘蛛机器人"),
            (HackerDroneSkillId, "召唤送货无人机"),
        })
        {
            var known = CombatCatalogRepository.IsKnownSkill(skillId);
            ok &= known;
            Console.WriteLine($"[probe]   {(known ? "OK  " : "FAIL")} {label} skill={skillId} IsKnownSkill={known}"
                + (known
                    ? " ⇒ AllowsSkill 的兜底分支放行（SkillCastTags 里有它）"
                    : " ⇒ ☠️ OnClientUseSkill 会拒掉这个技能"));
        }
        ok &= Check("HackerBattery(6/6)", BuildHackerBatteryBytes(6, 6), 9,
            "FF + TotalCount(u32) + CurrentCount(u32)，reader=Auto.Reader[362]");
        var bat = BuildHackerBatteryBytes(6, 6);
        ok &= CheckMarker(bat, 0, 0xFF, "Battery 非空标记 @0");
        ok &= CheckU32(bat, 1, 6, "BatteryTotalCount @1");
        ok &= CheckU32(bat, 5, 6, "BatteryCurrentCount @5");
        Console.WriteLine($"[probe]   方法 id: AskHackingNpc={MethodId.AskHackingNpc} "
            + $"AskHackingNpcPress={MethodId.AskHackingNpcPress} "
            + $"AskFinishHackingKeyFrame={MethodId.AskFinishHackingKeyFrame} "
            + $"SyncHackerBatteryCurrentAndTotalCount={MethodId.SyncHackerBatteryCurrentAndTotalCount}");

        Console.WriteLine();
        Console.WriteLine("[probe] ── NCCA App（里希）：拘捕记录 / 执勤数据 / 派遣支援 ──");
        Console.WriteLine($"[probe]   {PoliceAppCatalog4229938.Summary()}");
        var policeSettings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        var policeCases = BuildPoliceCases(policeSettings);
        var nccaSpirits = SpiritContentCatalogRepository.AllSpirits
            .Where(s => SpiritContentCatalogRepository.EffectiveJobClasses(s).Contains(NccaJobClassId))
            .Select(s => s.Id).ToArray();
        Console.WriteLine($"[probe]   NCCA 角色 = [{string.Join(",", nccaSpirits)}]"
            + "（App 的 JobClassIdList=[11300003] 只对这些角色可见）");
        Console.WriteLine($"[probe]   案件 {policeCases.Count} 条:");
        foreach (var c in policeCases)
        {
            Console.WriteLine($"[probe]     id={c.Id} npc={c.NpcId} t={c.Time} "
                + $"fines=[{string.Join(",", c.Fines)}] drops=[{string.Join(",", c.BonusDrops)}] "
                + $"sentence={c.Sentence} interrogation={(c.InterrogationInfo is null ? "null" : "obj")}");
        }
        var dispatchRows = PoliceAppCatalog4229938.AppDispatches;
        Console.WriteLine($"[probe]   App 显示的支援 = "
            + string.Join("/", dispatchRows.Select(d => $"{d.Id}:{d.Name}×{d.Number}")));
        var caseBytes = UxSerializer.Serialize(
            new GameMethods.SyncSpiritPoliceCaseInfos4229938
            {
                spiritId = nccaSpirits.Length > 0 ? nccaSpirits[0] : 15021021u,
                cases = policeCases,
            });
        ok &= Check("SyncSpiritPoliceCaseInfos", caseBytes, -1,
            "04×spiritId + FF(list7) + varint(n+1) + 每条 FF + 17 字段");
        
        ok &= CheckU32(caseBytes, 0, nccaSpirits.Length > 0 ? nccaSpirits[0] : 15021021u, "spiritId");
        ok &= CheckMarker(caseBytes, 4, 0xFF, "cases list7 非空标记");
        ok &= CheckMarker(caseBytes, 6, 0xFF, "case[0] 非空标记");
        ok &= CheckU32(caseBytes, 11, policeCases[0].NpcId, "case[0].NpcId @11");
        ok &= CheckU32(caseBytes, 39, policeCases[0].BonusDrops.Count > 0
            ? policeCases[0].BonusDrops[0] : 0u, "case[0].BonusDrops[0] @39");
        ok &= CheckMarker(caseBytes, 51, 0x00, "case[0].InterrogationInfo=null @51（跳过整棵子树）");

        var svcBytes = UxSerializer.Serialize(
            new GameMethods.SyncPoliceServiceData4229938
            {
                spiritId = 15021021u,
                serviceData = new GameMethods.PoliceServiceData4229938(),
                weeklyServiceData = new GameMethods.PoliceServiceData4229938(),
                stopPatrol = false,
            });
        
        
        ok &= Check("SyncPoliceServiceData", svcBytes, 65,
            "04×spiritId + 30×serviceData + 30×weeklyServiceData + 01×stopPatrol");
        ok &= CheckMarker(svcBytes, 4, 0xFF, "serviceData 非空标记 @4");
        ok &= CheckMarker(svcBytes, 21, 0xFF, "TotalDrops 空 list 标记 @21（int32 计数 ⇒ 5 字节）");
        ok &= CheckMarker(svcBytes, 34, 0xFF, "weeklyServiceData 非空标记 @34");

        var dispatchBytes = UxSerializer.Serialize(
            new GameMethods.SyncPoliceDispatchInfos4229938
            {
                spiritId = 15021021u,
                dispatchInfos = dispatchRows.ToDictionary(
                    d => d.Id,
                    d => new GameMethods.PoliceDispatchInfo4229938 { Id = d.Id }),
            });
        ok &= Check("SyncPoliceDispatchInfos", dispatchBytes, -1,
            "04×spiritId + FF(dict7) + varint(n+1) + (04×key + FF + 5 字段) ×n");
        ok &= CheckMarker(dispatchBytes, 4, 0xFF, "dispatchInfos dict7 非空标记");
        ok &= CheckMarker(dispatchBytes, 5, (byte)(dispatchRows.Count + 1), "dict7 计数偏置 @5 = n+1（varint）");
        ok &= CheckU32(dispatchBytes, 6, dispatchRows.Count > 0 ? dispatchRows[0].Id : 0u, "dict 第 1 个 key @6");

        Console.WriteLine();
        Console.WriteLine("[probe] ── 货运订单（中性模板打补丁） ──");
        ok &= ProbeTruckOrders();

        Console.WriteLine();
        Console.WriteLine("[probe] ── 物流入职培训事件（SubmitEventList） ──");
        var qs = PrivateServerConfigStore.Current.Gameplay.Quests;
        Console.WriteLine($"[probe]   QuestSettings.SubmitEventIds = [{string.Join(",", qs.SubmitEventIds)}]");
        foreach (var ev in qs.SubmitEventIds)
        {
            var has = TaskEventCatalogRepository.TryGet(ev, out var evRow);
            Console.WriteLine($"[probe]   event {ev} → {(has ? $"'{evRow!.Name}' 中文名='{evRow.NameCn}' StartTask={evRow.StartTask}" : "配置里没有这个事件！")}");
        }
        ok &= qs.SubmitEventIds.Contains(1234u);
        Console.WriteLine($"[probe]   含 1234（UberSimConfig.TeachEventId）: {qs.SubmitEventIds.Contains(1234u)}");

        Console.WriteLine();
        Console.WriteLine(ok ? "[probe] -> OK" : "[probe] -> 有不符合预期的项，见上面 FAIL");
        return ok ? 0 : 1;

        static bool Check(string name, byte[] bytes, int expect, string note)
        {
            var pass = expect < 0 || bytes.Length == expect;
            Console.WriteLine($"[probe]   {(pass ? "OK  " : "FAIL")} {name,-32} {bytes.Length,4}B "
                + (expect < 0 ? "" : $"(expect {expect}) ")
                + $"| {note}");
            Console.WriteLine($"[probe]        hex: {Convert.ToHexString(bytes.AsSpan(0, Math.Min(48, bytes.Length)))}"
                + (bytes.Length > 48 ? "…" : ""));
            return pass;
        }

        static bool CheckU32(byte[] buf, int off, uint value, string label)
        {
            var got = off >= 0 && off + 4 <= buf.Length ? BitConverter.ToUInt32(buf, off) : 0u;
            var pass = got == value;
            Console.WriteLine($"[probe]   {(pass ? "OK  " : "FAIL")} 字段 {label} @{off} "
                + $"expect {value} got {got}");
            return pass;
        }

        static bool CheckMarker(byte[] buf, int off, byte value, string label)
        {
            var got = off >= 0 && off < buf.Length ? buf[off] : (byte)0;
            var pass = got == value;
            Console.WriteLine($"[probe]   {(pass ? "OK  " : "FAIL")} {label} expect 0x{value:X2} got 0x{got:X2}");
            return pass;
        }
    }

    
    
    
    
    
    private static bool ProbeTruckOrders()
    {
        var ok = true;
        var expectAccepted = TruckOrderCodec4229938.ExpectedMarkerOffsets;
        var expectUnaccepted = TruckOrderCodec4229938.ExpectedMarkerOffsetsUnaccepted;
        Console.WriteLine($"[probe]   中性模板 {TruckOrderCodec4229938.TemplateLength}B，"
            + $"已接单标记偏移 [{string.Join(",", expectAccepted)}]");
        Console.WriteLine($"[probe]   未接单标记偏移 [{string.Join(",", expectUnaccepted)}]"
            + "（AcceptInfo=null ⇒ 后面整体前移 8）");

        
        var order = TruckOrderCodec4229938.BuildOrder(
            2001u,
            100f, 5f, 200f,
            300f, 5f, 400f,
            cargoId: 10004u, npcId: 141879094u, consigneeId: 141879100u,
            rudeId: 1u, characterId: 301u,
            limitAcceptSeconds: 300, limitFinishSeconds: 600, estimatedFinishSeconds: 300,
            basePointReward: 25, dropCoefficient: 1f, dropMoney: 250);
        ok &= CheckLen("订单(未接单)", order, 251, "模板 259 − 8");
        ok &= CheckMarkers("订单(未接单)", order, expectUnaccepted);
        ok &= CheckU32(order, 102, 10004u, "CargoId");
        ok &= CheckU32(order, 107, 141879094u, "DeliveryNpc.NpcId");
        ok &= CheckU32(order, 179, 2001u, "UniqueId");
        ok &= CheckF32(order, 11, 100f, "StartPos.X");
        ok &= CheckF32(order, 61, 300f, "EndPos.X");
        ok &= CheckI32(order, 124, 300, "LimitAcceptSeconds");
        ok &= CheckI32(order, 141, 25, "BasePointReward");
        
        ok &= CheckByte(order, 187, 0x00, "AcceptInfo 标记 = null");
        
        var start = TruckOrderCodec4229938.ReadI32(order, 183);
        var now = TruckOrderCodec4229938.NowUnix();
        var startOk = start > 0 && Math.Abs((long)start - now) < 3600;
        Console.WriteLine($"[probe]   {(startOk ? "OK  " : "FAIL")} 字段 OrderInfoStartTime           @183 "
            + $"expect ≈{now} got {start}（必须 > 0，否则订单列表永远空白）");
        ok &= startOk;

        
        var accepted = TruckOrderCodec4229938.MarkAccepted(order, 2001u, now);
        ok &= CheckLen("订单(已接单)", accepted, 259, "回到模板长度");
        ok &= CheckMarkers("订单(已接单)", accepted, expectAccepted);
        ok &= CheckByte(accepted, 187, 0xFF, "AcceptInfo 标记 = 存在");
        ok &= CheckU32(accepted, 188, 2001u, "AcceptedEventId");
        ok &= CheckU32(accepted, 179, 2001u, "UniqueId（位移后仍在 179）");

        
        var orders = new List<byte[]>();
        for (var i = 0; i < 3; i++)
            orders.Add(TruckOrderCodec4229938.BuildOrder(
                3000u + (uint)i, i * 10f, 0, i * 20f, i * 30f, 0, i * 40f,
                10004u, 141879094u, 141879100u, 1u, 301u, 300, 600, 300, 10, 1f, 100));
        var per = 251;
        var view = TruckOrderCodec4229938.BuildOrderViewBytes(orders, 0, 100f, 0, true, false, 0, 0);
        
        var expectLen = 1 + 1 + 1 + 3 * per + (4 + 4 + 4 + 1 + 2 + 1 + 4 + 4);
        ok &= CheckLen("ClientTruckOrderView(3 单)", view, expectLen,
            $"FF+FF+varint(4)+3×{per}+24");
        ok &= CheckLen("List<TruckJobOrderWrap>(3)",
            TruckOrderCodec4229938.BuildOrderListBytes(orders), 2 + 3 * per, $"FF + 04 + 3×{per}");

        return ok;

        static bool CheckLen(string name, byte[] body, int expect, string note)
        {
            var pass = body.Length == expect;
            Console.WriteLine($"[probe]   {(pass ? "OK  " : "FAIL")} {name,-32} {body.Length,4}B "
                + $"(expect {expect}) | {note}");
            return pass;
        }

        static bool CheckMarkers(string name, byte[] body, int[] expect)
        {
            var got = TruckOrderCodec4229938.FindMarkerOffsets(body);
            var pass = got.SequenceEqual(expect);
            Console.WriteLine($"[probe]   {(pass ? "OK  " : "FAIL")} {name,-32} 标记偏移 "
                + (pass ? "与期望一致" : $"不一致！got [{string.Join(",", got)}]"));
            return pass;
        }

        static bool CheckByte(byte[] buf, int off, byte value, string label)
        {
            var pass = buf[off] == value;
            Console.WriteLine($"[probe]   {(pass ? "OK  " : "FAIL")} 字段 {label,-26} @{off} "
                + $"expect 0x{value:X2} got 0x{buf[off]:X2}");
            return pass;
        }

        static bool CheckU32(byte[] buf, int off, uint value, string label)
            => CheckInt(buf, off, (long)value, (long)TruckOrderCodec4229938.ReadU32(buf, off), label);

        static bool CheckI32(byte[] buf, int off, int value, string label)
            => CheckInt(buf, off, value, TruckOrderCodec4229938.ReadI32(buf, off), label);

        static bool CheckF32(byte[] buf, int off, float value, string label)
        {
            var got = BitConverter.ToSingle(buf, off);
            var pass = MathF.Abs(got - value) < 1e-4f;
            Console.WriteLine($"[probe]   {(pass ? "OK  " : "FAIL")} 字段 {label,-26} @{off} "
                + $"expect {value} got {got}");
            return pass;
        }

        static bool CheckInt(byte[] buf, int off, long expect, long got, string label)
        {
            var pass = expect == got;
            Console.WriteLine($"[probe]   {(pass ? "OK  " : "FAIL")} 字段 {label,-26} @{off} "
                + $"expect {expect} got {got}");
            return pass;
        }
    }

    
    
    
    
    
    
    
    internal static void ProbeLoginSpiritContent()
    {
        var payload = RuntimePayloadFactory.MinimalPlayerInfo4229938();
        Console.WriteLine();
        Console.WriteLine("[probe] ── 登录包里的职业 / 天赋（每个角色） ──");

        foreach (var spirit in payload.InfoSpirit.Spirits)
        {
            var jobInfo = spirit.SpiritJobInfo;
            if (jobInfo.AvailableJobs.Count == 0)
                continue;

            var jobs = string.Join(" ", jobInfo.AvailableJobs
                .OrderBy(kv => kv.Key)
                .Select(kv =>
                {
                    var j = kv.Value;
                    return $"{kv.Key}(Lv{j.Level},reg={j.RegisterTime},exp={j.Exp},pt={j.TalentInfo.TalentPoint},"
                        + $"nodes={j.TalentInfo.UnlockTalentInfoDict.Count},"
                        + $"trees={j.TalentInfo.TalentTreeRecordDict.Count})";
                }));

            var urban = string.Join(",", spirit.SpiritUrbanSkill.UrbanAbilities);
            var spiritTalents = $"{spirit.TalentInfo.UnlockTalentInfoDict.Count}节点/"
                + $"{spirit.TalentInfo.TalentTreeRecordDict.Count}树/Lv{spirit.TalentInfo.Level}"
                + $"/pt{spirit.TalentInfo.TalentPoint}";

            Console.WriteLine($"[probe]   {spirit.TemplateId} "
                + $"({SpiritContentCatalogRepository.Spirit(spirit.TemplateId)?.Name}) "
                + $"current={jobInfo.CurrentJob} | {jobs}");
            Console.WriteLine($"[probe]        角色天赋={spiritTalents} 六维=[{urban}]");
        }

        var gameplay = payload.InfoMinor.GameplayTalentInfos;
        Console.WriteLine($"[probe]   玩法天赋 GameplayTalentInfos: {gameplay.Count} 项 "
            + $"[{string.Join(",", gameplay.Select(kv => $"gameplay{kv.Key}:{kv.Value.UnlockTalentInfoDict.Count}节点"))}]");
    }

    private static byte[] ProbeUnitHackableBytes()
        => UxSerializer.Serialize(new GameMethods.SyncUnitHackableState4229938
        {
            unitId = 500000000001UL,
            isHackable = true,
        });

    private static byte[] ProbeDestroyPoliceBytes()
        => UxSerializer.Serialize(new GameMethods.SyncDestroyPoliceVehicles4229938
        {
            entityIds = [700000000001UL],
        });

    private static byte[] ProbeSpawnPoliceBytes()
        => UxSerializer.Serialize(new GameMethods.SyncSpawnPoliceVehicles4229938
        {
            spawnInfos =
            [
                new GameMethods.PoliceVehicleSpawnClientInfo
                {
                    Id = 700000000001UL,
                    VehicleId = 81004016,
                    Position = new Auto.UXVector3 { X = 1f, Y = 2f, Z = 3f },
                    Facing = 0.5f,
                    EulerAngles = new Auto.UXVector3 { X = 0f, Y = 0.5f, Z = 0f },
                },
            ],
            configInfo = new GameMethods.PoliceVehicleSpawnConfigInfo
            {
                ChaseRange = 60f,
                ChaseDirectlyRange = 25f,
                ApprehendRange = 6f,
                PatrolSpeed = 8f,
                ChaseSpeed = 16f,
                ChaseDirectlySpeed = 22f,
            },
        });

    private static byte[] ProbeJobBoardBytes()
        => UxSerializer.Serialize(new GameMethods.JobBoardInfo
        {
            JoinedJobCount = 1,
            MaxJobCount = 11,
            CountryJobEntries = new Dictionary<uint, GameMethods.JobBoardEntryList>
            {
                [1] = new GameMethods.JobBoardEntryList
                {
                    Entries =
                    [
                        new GameMethods.JobBoardEntry
                        {
                            BoardId = 1,
                            JobId = 11300008,
                            JobClassId = 11300008,
                            State = GameMethods.JobBoardJobState.Available,
                            CanResign = true,
                        },
                    ],
                },
            },
        });

    private static byte[] ProbeTruckOrderBytes()
        => UxSerializer.Serialize(new GameMethods.ClientTruckOrderView
        {
            Orders = [],
            CustomerSatisfactionAverage = 100f,
            TruckGuideClicked = true,
        });
}
