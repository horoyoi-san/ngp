using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Gameplay;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

internal enum SwitchTeleportTiming
{
    
    
    
    
    Immediate = 0,

    
    
    
    
    Apex = 1,
}

internal sealed partial class GameRouter
{
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static async Task<SwitchTimelineResult> PlaySwitchTimelineAsync(
        TcpSession session,
        uint switchConfigId,
        uint templateId,
        bool teleportToAnchor = true,
        bool skipPreSwitch = false,
        SwitchTeleportTiming? teleportTiming = null,
        int? apexDelayMs = null,
        CancellationToken token = default)
    {
        if (!TryGetWorldState(session, out var state))
            return new SwitchTimelineResult(false, null, "会话还没进世界（WorldEntryState 不存在）。");

        if (!state.Ready)
            return new SwitchTimelineResult(false, null, "世界尚未就绪。");

        
        var switchSettings = PrivateServerConfigStore.Current.Gameplay.SwitchAnimations;
        var timing = teleportTiming ?? ParseTeleportTiming(switchSettings.TeleportTiming);
        var apexWaitMs = apexDelayMs ?? switchSettings.ApexDelayMs;
        if (apexWaitMs < 0) apexWaitMs = 0;

        var target = ClientConfigRepository.Characters().FirstOrDefault(x => x.TemplateId == templateId);
        if (target is null)
            return new SwitchTimelineResult(false, null, $"模板 {templateId} 不在可玩角色表里。");

        
        var playerPosition = state.HasLastReportedPlayerTransform
            ? state.LastReportedPlayerPosition
            : Profile.WorldSpawn;

        
        uint selectedId = switchConfigId;
        bool autoPicked = false;

        if (selectedId == 0)
        {
            
            
            try
            {
                var choice = ClientConfigRepository.RandomSwitchAnimation(
                    templateId, state.LastSwitchShowId, playerPosition);
                selectedId = choice.Id;
                autoPicked = true;
                session.Log.Info(
                    $"[SWITCH-TL] 自动选行（原版算法） id={choice.Id} tl={choice.Timeline} "
                    + $"weight={choice.Weight:0.###} anchorDistance={choice.AnchorDistance:0.##}m "
                    + $"timelinePool={choice.TimelinePool} rowPool={choice.RowPool} "
                    + $"prevTl={choice.PreviousTimeline ?? "(无)"}");
            }
            catch (InvalidOperationException ex)
            {
                return new SwitchTimelineResult(false, null,
                    $"原版算法找不到模板 {templateId} 可用的换人动画行：{ex.Message}");
            }
        }

        var row = StorySwitchConfig.Find(selectedId);
        if (row is null)
            return new SwitchTimelineResult(false, null, $"SwitchSpiritConfig 里没有 Id={selectedId}。");
        if (string.IsNullOrWhiteSpace(row.Timeline))
            return new SwitchTimelineResult(false, null, $"配置 Id={selectedId} 的 TimeLine 为空。");

        
        var authoredAnchor = row.Anchor;
        var hasAuthoredAnchor = authoredAnchor.X != 0f || authoredAnchor.Y != 0f || authoredAnchor.Z != 0f;

        
        var anchor = teleportToAnchor && hasAuthoredAnchor ? authoredAnchor : playerPosition;

        
        
        var facing = row.Facing != 0f && float.IsFinite(row.Facing)
            ? row.Facing
            : state.HasLastReportedPlayerTransform && float.IsFinite(state.LastReportedPlayerRotation.Y)
                ? state.LastReportedPlayerRotation.Y
                : Profile.WorldFacing;

        var dx = (double)anchor.X - playerPosition.X;
        var dz = (double)anchor.Z - playerPosition.Z;
        var distance = Math.Sqrt(dx * dx + dz * dz);

        session.Log.Info(
            $"[SWITCH-TL] ⓞ 演出 place=「{row.Description}」show=「{row.TimelineDescription}」"
            + $" id={selectedId} tl={row.Timeline} autoPicked={autoPicked} "
            + $"player=({playerPosition.X:0.##},{playerPosition.Y:0.##},{playerPosition.Z:0.##}) "
            + $"anchor=({anchor.X:0.##},{anchor.Y:0.##},{anchor.Z:0.##}) "
            + $"distance={distance:0.##}m facing={facing:0.##} teleport={teleportToAnchor} "
            + $"timing={DescribeTiming(timing)}"
            + (timing == SwitchTeleportTiming.Apex && teleportToAnchor
                ? $" apexDelay={apexWaitMs}ms（等上升段播完、镜头到高空将降时才传送）"
                : string.Empty));

        await SwitchTimelineCore4229938(
            session, state, selectedId, target.TemplateId, target.UnitId,
            anchor, facing, row.Timeline, row.Description, row.TimelineDescription,
            row.AgentIds, skipPreSwitch, timing, apexWaitMs, playerPosition, token);

        return new SwitchTimelineResult(true, row.Timeline, null)
        {
            SwitchConfigId = selectedId,
            AutoPicked = autoPicked,
            Teleported = teleportToAnchor && hasAuthoredAnchor,
            SkippedPreSwitch = skipPreSwitch,
            Distance = distance,
            Anchor = anchor,
            Origin = playerPosition,
            Place = row.Description,
            Show = row.TimelineDescription,
            AgentTemplateIds = row.AgentIds,
            TeleportTiming = DescribeTiming(timing),
            ApexDelayMs = timing == SwitchTeleportTiming.Apex ? apexWaitMs : 0,
        };
    }

    
    private static SwitchTeleportTiming ParseTeleportTiming(string? raw)
        => string.Equals(raw?.Trim(), "immediate", StringComparison.OrdinalIgnoreCase)
            ? SwitchTeleportTiming.Immediate
            : SwitchTeleportTiming.Apex;

    
    private static string DescribeTiming(SwitchTeleportTiming timing)
        => timing == SwitchTeleportTiming.Immediate ? "immediate" : "apex";

    
    
    
    
    
    
    private static async Task SwitchTimelineCore4229938(
        TcpSession session,
        WorldEntryState state,
        uint switchConfigId,
        uint templateId,
        ulong unitId,
        Vec3 anchor,
        float facing,
        string timelineName,
        string place,
        string show,
        IReadOnlyList<uint> agentTemplateIds,
        bool skipPreSwitch,
        SwitchTeleportTiming timing,
        int apexDelayMs,
        Vec3 originPosition,
        CancellationToken token)
    {
        var oldUnitId = state.ActiveSpiritUnitId;

        
        
        var apexDeferred = timing == SwitchTeleportTiming.Apex;
        var handoffPosition = apexDeferred ? originPosition : anchor;

        state.PendingSwitchTemplateId = templateId;
        state.PendingSwitchUnitId = unitId;
        state.PendingSwitchOldUnitId = oldUnitId;
        state.PendingSwitchShowId = switchConfigId;
        state.PendingSwitchPosition = anchor;
        state.PendingSwitchFacing = facing;
        state.PendingSwitchControlTransferred = false;
        state.PendingSwitchLandingStarted = false;

        
        
        state.LastReportedPlayerPosition = handoffPosition;
        state.LastReportedPlayerRotation = new Vec3(0f, facing, 0f);
        state.HasLastReportedPlayerTransform = true;

        
        
        
        
        
        
        
        
        if (apexDeferred)
        {
            session.Log.Info(
                $"[SWITCH-TL] ⓪ apex 模式：**不在 SyncPreSwitchSpirit 时刻传送**"
                + $"（旧单位留在原位 ({originPosition.X:0.##},{originPosition.Y:0.##},{originPosition.Z:0.##})，"
                + $"等 {apexDelayMs}ms 后的顶点再送到锚点）oldUnit={oldUnitId}");
        }
        else if (oldUnitId != 0)
        {
            await session.NotifyAsync(MethodId.SyncUnitPositionAndFacing,
                Ananta.SDK.Serialization.UxSerializer.Serialize(
                    WorldCodec.PositionAndFacing(oldUnitId, anchor, facing)), token);
            session.Log.Info($"[SWITCH-TL] ⓪ 传送旧单位 oldUnit={oldUnitId} → 锚点（immediate 模式）");
        }

        
        
        
        
        
        
        
        
        
        
        
        
        var spawnedAgents = await SpawnSwitchAgentsAsync(
            session, state, agentTemplateIds, handoffPosition, facing, token);

        
        
        if (skipPreSwitch)
        {
            session.Log.Warn("[SWITCH-TL] ① 诊断模式：**跳过** SyncPreSwitchSpirit（客户端不进入 Prepare）");
        }
        else
        {
            await session.NotifyAsync(
                MethodId.SyncPreSwitchSpirit,
                Ananta.SDK.Serialization.UxSerializer.Serialize(
                    WorldCodec.PreSwitchSpirit(switchConfigId, templateId, anchor)),
                token);

            session.Log.Info(
                $"[SWITCH-TL] ① SyncPreSwitchSpirit configId={switchConfigId} "
                + $"newTemplate={templateId} tl={timelineName}");
        }

        
        
        
        
        
        
        
        
        
        
        
        
        
        var pending = new PendingSwitchTimeline4229938
        {
            ConfigId = switchConfigId,
            TemplateId = templateId,
            UnitId = unitId,
            OldUnitId = oldUnitId,
            Anchor = anchor,
            Facing = facing,
            Timeline = timelineName,
            Place = place,
            Show = show,
            SpawnedAgents = spawnedAgents,
            TeleportTiming = DescribeTiming(timing),
            ApexDelayMs = apexDelayMs,
            OriginPosition = handoffPosition,
        };
        state.PendingSwitchTimeline = pending;

        
        if (skipPreSwitch)
        {
            session.Log.Warn("[SWITCH-TL] 诊断模式：跳过预切换 ⇒ 直接做身份交接 + SyncSwitchSpiritConfigId");
            await ContinueSwitchTimelineAsync(session, state, pending, token);
            return;
        }

        ScheduleSwitchReportTimeout(session, state, pending);

        session.Log.Info(
            $"[SWITCH-TL] ① 已下发 SyncPreSwitchSpirit，等客户端上报 ReportPreSwitchSpiritFinish"
            + $"（{SwitchReportTimeoutMs}ms 超时兜底）configId={switchConfigId} tl={timelineName}");
    }

    
    
    
    
    
    
    
    
    
    
    
    private const int SwitchReportTimeoutMs = 10_000;

    
    
    
    
    private static async Task ContinueSwitchTimelineAsync(
        TcpSession session,
        WorldEntryState state,
        PendingSwitchTimeline4229938 p,
        CancellationToken token)
    {
        var switchConfigId = p.ConfigId;
        var templateId = p.TemplateId;
        var unitId = p.UnitId;
        var oldUnitId = p.OldUnitId;
        var anchor = p.Anchor;
        var facing = p.Facing;
        var spawnedAgents = p.SpawnedAgents;

        
        
        var apexDeferred = !string.Equals(p.TeleportTiming, "immediate", StringComparison.OrdinalIgnoreCase);
        var handoffPosition = apexDeferred ? p.OriginPosition : anchor;

        
        
        state.ActiveSwitchTimeline = p;

        
        
        
        
        await session.NotifyAsync(MethodId.SyncLogicAgentEnter,
            Ananta.SDK.Serialization.UxSerializer.Serialize(WorldCodec.LogicAgentEnter(unitId)), token);
        await session.NotifyAsync(MethodId.SyncManagedLogicAgent,
            Ananta.SDK.Serialization.UxSerializer.Serialize(WorldCodec.ManagedLogicAgent(unitId, Profile.PlayerPid, 0)), token);
        await session.NotifyAsync(MethodId.SyncRaidBattleUnitSpirit,
            Ananta.SDK.Serialization.UxSerializer.Serialize(
                RuntimePayloadFactory.CharacterUnitProjection(templateId, handoffPosition, facing)), token);
        await session.NotifyAsync(MethodId.SyncUnitPositionAndFacing,
            Ananta.SDK.Serialization.UxSerializer.Serialize(WorldCodec.PositionAndFacing(unitId, handoffPosition, facing)), token);
        await session.NotifyAsync(MethodId.SyncPlayerCurrentSpirit,
            Ananta.SDK.Serialization.UxSerializer.Serialize(
                WorldCodec.CurrentSpirit(Profile.PlayerPid, templateId, unitId, isAgentSwitch: false)), token);

        
        await session.NotifyAsync(MethodId.SyncUnitPositionAndFacing,
            Ananta.SDK.Serialization.UxSerializer.Serialize(WorldCodec.PositionAndFacing(unitId, handoffPosition, facing)), token);

        
        
        await PublishActorPresentation4229938(session, state, unitId, templateId, token);

        
        if (state.ActiveFeiSuoBuffInstanceId != 0)
        {
            var transientUnitId = state.ActiveFeiSuoBuffUnitId != 0 ? state.ActiveFeiSuoBuffUnitId : oldUnitId;
            await session.NotifyAsync(MethodId.SyncUnitRemoveBuff,
                Ananta.SDK.Serialization.UxSerializer.Serialize(
                    WorldCodec.UnitRemoveBuff(transientUnitId, state.ActiveFeiSuoBuffInstanceId)), token);
            state.ActiveFeiSuoBuffInstanceId = 0;
            state.ActiveFeiSuoBuffUnitId = 0;
        }

        
        await ClearClientWebLifecycleBuffsSessionAsync(session, state, oldUnitId, "switch-timeline");

        
        await PublishSafeRuntimeBuffSnapshotSessionAsync(session, state, unitId, templateId, "switch-timeline");
        state.AllBuildBuffsPublished = true;

        
        
        if (oldUnitId != 0 && oldUnitId != unitId)
            await session.NotifyAsync(MethodId.SyncLogicAgentLeave,
                Ananta.SDK.Serialization.UxSerializer.Serialize(WorldCodec.LogicAgentLeave(oldUnitId)), token);

        state.ActiveSpiritTemplateId = templateId;
        state.ActiveSpiritUnitId = unitId;
        state.PendingSwitchControlTransferred = true;
        state.ActiveSkillId = 0;
        state.RestoreResourcesAfterActiveSkill = false;
        state.ActiveClientSkillInstanceId = 0;
        state.ActiveSkillStartedTicks = 0;

        session.Log.Info(
            $"[SWITCH-TL] ③ 身份交接完成 oldUnit={oldUnitId} → template={templateId}/{unitId} "
            + $"name={TargetProfileName(templateId)} "
            + $"handoff=({handoffPosition.X:0.##},{handoffPosition.Y:0.##},{handoffPosition.Z:0.##}) "
            + $"anchor=({anchor.X:0.##},{anchor.Y:0.##},{anchor.Z:0.##}) "
            + $"timing={p.TeleportTiming}");

        
        
        
        
        
        
        
        await session.NotifyAsync(
            MethodId.SyncSwitchSpiritConfigId,
            Ananta.SDK.Serialization.UxSerializer.Serialize(
                WorldCodec.SwitchSpiritConfigId(switchConfigId, anchor, spawnedAgents)), token);

        
        await session.NotifyAsync(MethodId.SyncGamePause,
            Ananta.SDK.Serialization.UxSerializer.Serialize(WorldCodec.GamePause(false)), token);

        state.SwitchCount++;
        state.LastSwitchShowId = switchConfigId;
        state.PendingSwitchTemplateId = 0;
        state.PendingSwitchUnitId = 0;
        state.PendingSwitchOldUnitId = 0;
        state.PendingSwitchShowId = 0;
        state.PendingSwitchFacing = state.WorldEntryCreateHeroFacing;
        state.PendingSwitchControlTransferred = false;
        state.PendingSwitchLandingStarted = false;

        session.Log.Info(
            $"[SWITCH-TL] ④ SyncSwitchSpiritConfigId configId={switchConfigId} tl={p.Timeline} "
            + $"place=「{p.Place}」show=「{p.Show}」spawnedAgents=[{string.Join(",", spawnedAgents)}]");

        
        
        
        if (apexDeferred)
        {
            ScheduleApexTeleport(session, state, p, CancellationToken.None);
        }
        else
        {
            session.Log.Info("[SWITCH-TL] ④.5 immediate 模式：已在 SyncPreSwitchSpirit 时刻传送，无后续动作");
        }

        
        
        if (spawnedAgents.Count > 0)
            ScheduleSwitchAgentCleanup(session, spawnedAgents, CancellationToken.None);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private static void ScheduleApexTeleport(
        TcpSession session,
        WorldEntryState state,
        PendingSwitchTimeline4229938 p,
        CancellationToken token)
    {
        var delay = p.ApexDelayMs > 0 ? p.ApexDelayMs : 3600;
        var from = p.OriginPosition;
        var to = p.Anchor;

        session.Log.Info(
            $"[SWITCH-TL] ④.5 apex 传送已排程：{delay}ms 后把 unit={p.UnitId}"
            + $"（+companion×{p.SpawnedAgents.Count}）"
            + $" 从 ({from.X:0.##},{from.Y:0.##},{from.Z:0.##})"
            + $" 送到锚点 ({to.X:0.##},{to.Y:0.##},{to.Z:0.##})"
            + $" —— 对应「镜头已爬到高空、刚准备下降」的时刻");

        _ = Task.Run(async () =>
        {
            try
            {
                await Task.Delay(delay, CancellationToken.None);
                await TeleportToAnchorIfPendingAsync(session, state, p, "定时器（apex 顶点）");
            }
            catch (Exception ex)
            {
                try { session.Log.Warn($"[SWITCH-TL] ④.5 apex 传送失败: {ex.Message}"); }
                catch {  }
            }
        }, CancellationToken.None);
    }

    
    
    
    
    
    
    
    internal static async Task TeleportToAnchorIfPendingAsync(
        TcpSession session,
        WorldEntryState state,
        PendingSwitchTimeline4229938 p,
        string reason)
    {
        if (!p.TryBeginApexTeleport())
            return;     

        var anchor = p.Anchor;
        var facing = p.Facing;

        
        await session.NotifyAsync(MethodId.SyncUnitPositionAndFacing,
            Ananta.SDK.Serialization.UxSerializer.Serialize(
                WorldCodec.PositionAndFacing(p.UnitId, anchor, facing)), CancellationToken.None);

        
        foreach (var agentId in p.SpawnedAgents)
        {
            await session.NotifyAsync(MethodId.SyncUnitPositionAndFacing,
                Ananta.SDK.Serialization.UxSerializer.Serialize(
                    WorldCodec.PositionAndFacing(agentId, anchor, facing)), CancellationToken.None);
        }

        
        
        
        
        
        await Task.Delay(180, CancellationToken.None);
        await session.NotifyAsync(MethodId.SyncUnitPositionAndFacing,
            Ananta.SDK.Serialization.UxSerializer.Serialize(
                WorldCodec.PositionAndFacing(p.UnitId, anchor, facing)), CancellationToken.None);

        
        state.LastReportedPlayerPosition = anchor;
        state.LastReportedPlayerRotation = new Vec3(0f, facing, 0f);
        state.HasLastReportedPlayerTransform = true;

        var from = p.OriginPosition;
        var dx = (double)anchor.X - from.X;
        var dz = (double)anchor.Z - from.Z;
        session.Log.Info(
            $"[SWITCH-TL] ④.5 ★ apex 传送执行（{reason}）：unit={p.UnitId}"
            + $"（+companion×{p.SpawnedAgents.Count}）"
            + $" ({from.X:0.##},{from.Y:0.##},{from.Z:0.##})"
            + $" → ({anchor.X:0.##},{anchor.Y:0.##},{anchor.Z:0.##})"
            + $" 平面距离={Math.Sqrt(dx * dx + dz * dz):0.##}m facing={facing:0.##}");
    }

    
    
    
    
    private static void ScheduleSwitchReportTimeout(
        TcpSession session, WorldEntryState state, PendingSwitchTimeline4229938 pending)
    {
        _ = Task.Run(async () =>
        {
            try
            {
                await Task.Delay(SwitchReportTimeoutMs, CancellationToken.None);

                
                if (!ReferenceEquals(state.PendingSwitchTimeline, pending))
                    return;
                if (!pending.TryBeginContinuation())
                    return;

                state.PendingSwitchTimeline = null;
                session.Log.Warn(
                    $"[SWITCH-TL] 客户端 {SwitchReportTimeoutMs}ms 未上报 ReportPreSwitchSpiritFinish，"
                    + "走超时兜底继续（timeline 可能播不出来）");
                await ContinueSwitchTimelineAsync(session, state, pending, CancellationToken.None);
            }
            catch (Exception ex)
            {
                try { session.Log.Warn($"[SWITCH-TL] 超时兜底失败: {ex.Message}"); } catch {  }
            }
        }, CancellationToken.None);
    }

    
    
    
    
    
    
    [Handler(MethodId.ReportPreSwitchSpiritFinish, HandlerPacketKind.Invoke)]
    private async Task OnReportPreSwitchSpiritFinish(Connection conn, UxRpcMessage msg)
    {
        var ctx = msg.Context;
        var state = GetWorldState(ctx);

        
        await conn.ReturnEmptyOkAsync(msg);

        var pending = state.PendingSwitchTimeline;
        if (pending is null || !pending.TryBeginContinuation())
            return;

        state.PendingSwitchTimeline = null;
        conn.Log.Info("[SWITCH-TL] ③ 客户端上报 ReportPreSwitchSpiritFinish → 继续流程");
        await ContinueSwitchTimelineAsync(ctx.Session, state, pending, CancellationToken.None);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    [Handler(MethodId.ReportPreTeleportFinish, HandlerPacketKind.Invoke)]
    private async Task OnReportPreTeleportFinish(Connection conn, UxRpcMessage msg)
    {
        var ctx = msg.Context;
        var state = GetWorldState(ctx);

        
        await conn.ReturnEmptyOkAsync(msg);

        
        var pending = state.ActiveSwitchTimeline;
        if (pending is null)
            return;     

        if (pending.ApexTeleportDone)
            return;

        conn.Log.Info("[SWITCH-TL] ④.5 客户端上报 ReportPreTeleportFinish → 上升段播完，立即触发 apex 传送");
        await TeleportToAnchorIfPendingAsync(ctx.Session, state, pending, "客户端上报 ReportPreTeleportFinish");
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    [Handler(MethodId.AskSwitchSpiritComplete, HandlerPacketKind.Invoke)]
    private async Task OnAskSwitchSpiritComplete(Connection conn, UxRpcMessage msg)
    {
        var ctx = msg.Context;
        var state = GetWorldState(ctx);

        await conn.ReturnEmptyOkAsync(msg);

        
        
        
        
        await PushHackerBatteryAsync(conn.Session);

        
        
        
        await GrantHackingAbilityBuffAsync(conn.Session);

        var pending = state.ActiveSwitchTimeline;
        if (pending is null)
            return;

        var elapsed = pending.ApexTeleportDone
            ? "已传送"
            : "**未传送**（apex 定时器还没到？）";

        conn.Log.Info(
            $"[SWITCH-TL] ⑦ 客户端上报 AskSwitchSpiritComplete —— 整条换人演出播完 "
            + $"tl={pending.Timeline} apex={pending.TeleportTiming} "
            + $"apexDelay={pending.ApexDelayMs}ms apexTeleport={elapsed} "
            + $"（用这条日志里的时间差可以标定 ApexDelayMs）");

        
        if (ReferenceEquals(state.ActiveSwitchTimeline, pending))
            state.ActiveSwitchTimeline = null;
    }

    
    
    
    
    private static long _switchAgentSeq = 610000000000L;

    
    
    
    
    
    
    
    
    
    
    
    
    private static async Task EnsureAetherInitializedAsync(
        TcpSession session, WorldEntryState state, CancellationToken token)
    {
        lock (state.SyncRoot)
        {
            
            if (state.AetherVehicleInitSent)
                return;
            
            if (state.SwitchAetherInitSent)
                return;
            state.SwitchAetherInitSent = true;
        }

        var raidId = state.ActiveRaidId;
        await session.NotifyAsync(MethodId.SyncAetherAIInitDatas, BuildAetherInit(raidId), token);

        session.Log.Info(
            $"[SWITCH-TL] ⓪.4 兜底下发 SyncAetherAIInitDatas raid={raidId} "
            + $"{DescribeAetherInit()}（缺它同伴 agent 会因 AgentWorld=null 建不出来）");
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private static async Task<List<ulong>> SpawnSwitchAgentsAsync(
        TcpSession session,
        WorldEntryState state,
        IReadOnlyList<uint> agentTemplateIds,
        Vec3 anchor,
        float facing,
        CancellationToken token)
    {
        var spawned = new List<ulong>(agentTemplateIds.Count);
        if (agentTemplateIds.Count == 0)
            return spawned;

        
        
        
        
        
        
        
        
        
        await EnsureAetherInitializedAsync(session, state, token);

        
        var yawRad = facing * (float)Math.PI / 180f;
        var fwdX = (float)Math.Sin(yawRad);
        var fwdZ = (float)Math.Cos(yawRad);
        var rightX = fwdZ;
        var rightZ = -fwdX;

        for (var i = 0; i < agentTemplateIds.Count; i++)
        {
            var templateId = agentTemplateIds[i];

            
            
            
            if (!NpcCatalog4229938.TryGet(templateId, out var npc))
            {
                session.Log.Warn($"[SWITCH-TL] ⓪.5 跳过同伴 agent template={templateId} —— 不在 AgentConfig 里");
                continue;
            }

            var id = (ulong)Interlocked.Increment(ref _switchAgentSeq);

            var lateral = (i % 2 == 0 ? 1f : -1f) * (1.6f + 0.8f * (i / 2));
            var forward = 2.6f + 0.5f * (i / 2);
            var pos = new Vec3(
                anchor.X + fwdX * forward + rightX * lateral,
                anchor.Y,
                anchor.Z + fwdZ * forward + rightZ * lateral);

            
            var npcFacing = facing + 180f;
            if (npcFacing > 180f) npcFacing -= 360f;

            
            
            
            await session.NotifyAsync(MethodId.SyncAetherAIStaticNpcAddData,
                Ananta.SDK.Serialization.UxSerializer.Serialize(
                    new SceneMethods.SyncAetherAIStaticNpcAddData4229938
                    {
                        data = new SceneMethods.ClientStaticNpcInitData4229938
                        {
                            StaticNpcInfoId = id,
                            NpcFormworkId = templateId,
                            AgentPersonaId = npc.AgentPersonaId,
                            SPoiActionId = 0,
                            CPoiActionId = 0,
                            UrbanDiversityId = 88888000,
                            IgnoreAllStim = false,
                            TaskRelated = false,
                            
                            
                            
                            
                            
                            EnableHack = false,
                            NpcPid = (int)templateId,
                            
                            AgentSyncClientInfo = new SceneMethods.AgentSyncClientInfo4229938
                            {
                                SpoonAgentId = (int)templateId,
                                treeName = "PedBase",
                                petPerformData = "",
                                spawnEffectId = [],
                                stimIDList = [],
                                indoorList = [],
                                roomIds = [],
                                LeaveDistance = 10000,
                                approachDistance = 10000,
                                FashionSuitId = 11190001,
                                actionId = 0,
                                actionGroupId = npc.ActionGroupId,
                                initPoiActionId = 0,
                                useDefaultPoiOnReturn = false,
                                returnPoiActionIds = [],
                                AgentDataSetsActivityCfgId = 0,
                                beHitType = 1,          
                                agentStimType = 0,
                                forbidStimulateType = 0,
                                isAttackInSafeMode = true,
                                CanBeExaminedByPolice = true,
                                InteractId = npc.InteractSettingId,
                                AISetting = npc.AiSettingId,
                            },
                            LookAtDecisionRulesId = 0,
                            ForceGo = true,
                            SourceType = 1,             
                            Id = id,
                            Position = new Auto.UXVector3 { X = pos.X, Y = pos.Y, Z = pos.Z },
                            Facing = npcFacing,
                            EulerAngles = new Auto.UXVector3 { X = 0f, Y = npcFacing, Z = 0f },
                        },
                    }), token);

            
            await session.NotifyAsync(MethodId.SyncManagedLogicAgent,
                Ananta.SDK.Serialization.UxSerializer.Serialize(
                    WorldCodec.ManagedLogicAgent(id, Profile.PlayerPid, 0)), token);

            spawned.Add(id);

            session.Log.Info(
                $"[SWITCH-TL] ⓪.5 生成同伴 agent {i + 1}/{agentTemplateIds.Count} unit={id} "
                + $"template={templateId} name=「{npc.Name}」persona={npc.AgentPersonaId} "
                + $"model={npc.GeneralModelId} ai={npc.AiSettingId} interact={npc.InteractSettingId} "
                + $"at=({pos.X:0.#},{pos.Y:0.#},{pos.Z:0.#}) facing={npcFacing:0.#} "
                + $"managedPid={Profile.PlayerPid} channel=StaticNpc+ManagedLogicAgent");
        }

        return spawned;
    }

    
    private static async Task DespawnSwitchAgentsAsync(
        TcpSession session, IReadOnlyList<ulong> agentUnitIds, CancellationToken token)
    {
        foreach (var id in agentUnitIds)
        {
            await session.NotifyAsync(MethodId.SyncLogicAgentLeave,
                Ananta.SDK.Serialization.UxSerializer.Serialize(WorldCodec.LogicAgentLeave(id)), token);
        }
        session.Log.Info($"[SWITCH-TL] ⑥ 回收同伴 agent ×{agentUnitIds.Count} [{string.Join(",", agentUnitIds)}]");
    }

    
    
    
    private static void ScheduleSwitchAgentCleanup(
        TcpSession session, IReadOnlyList<ulong> agentUnitIds, CancellationToken token)
    {
        _ = Task.Run(async () =>
        {
            try
            {
                await Task.Delay(SwitchAgentLifetimeMs, token);
                await DespawnSwitchAgentsAsync(session, agentUnitIds, token);
            }
            catch (OperationCanceledException) { }
            catch (Exception ex)
            {
                try { session.Log.Warn($"[SWITCH-TL] 回收同伴 agent 失败: {ex.Message}"); }
                catch {  }
            }
        }, CancellationToken.None);
    }

    
    private const int SwitchAgentLifetimeMs = 40_000;

    
    
    
    internal static bool TryGetWorldState(TcpSession session, out WorldEntryState state)
    {
        if (session.Items.TryGetValue(WorldStateKey, out var raw) && raw is WorldEntryState existing)
        {
            state = existing;
            return true;
        }
        state = new WorldEntryState();
        return false;
    }

    
    private static string TargetProfileName(uint templateId)
        => ClientConfigRepository.Characters().FirstOrDefault(x => x.TemplateId == templateId)?.Name ?? "(未知)";

    
    
    
    
    
    
    
    private static async Task PublishActorPresentation4229938(
        TcpSession session, WorldEntryState state, ulong unitId, uint templateId, CancellationToken token)
    {
        var weapon = CombatCodec.DefaultWeapon(templateId);
        var style = ResolveWeaponStyle(state, weapon);

        state.ActiveWeaponInstanceId = weapon.InstanceId;
        state.ActiveFightStyleId = style.Id;
        state.LastWeaponBySpirit[templateId] = weapon.InstanceId;

        await session.NotifyAsync(MethodId.SyncSetSpiritFashions,
            Ananta.SDK.Serialization.UxSerializer.Serialize(RuntimePayloadFactory.CharacterFashions(templateId)), token);
        await PublishWeaponSnapshotSessionAsync(session, state, unitId, templateId, weapon.InstanceId, token);
        await session.NotifyAsync(MethodId.SyncSpiritLastUsedWeapon,
            Ananta.SDK.Serialization.UxSerializer.Serialize(CombatCodec.SpiritLastUsedWeapon(templateId, weapon.InstanceId)), token);
        await session.NotifyAsync(MethodId.SyncSpiritSwitchWeaponAction,
            Ananta.SDK.Serialization.UxSerializer.Serialize(CombatCodec.SpiritSwitchWeapon(unitId, weapon.InstanceId)), token);

        
        foreach (var stateId in TransientHudStateIds)
            await session.NotifyAsync(MethodId.SyncRemoveUnitState,
                Ananta.SDK.Serialization.UxSerializer.Serialize(WorldCodec.RemoveUnitState(unitId, stateId)), token);

        session.Log.Info(
            $"[SWITCH-TL] ③ 角色呈现 unit={unitId} template={templateId} "
            + $"weapon={weapon.TemplateId}/{weapon.InstanceId} style={style.Id}");
    }

    
    private static async Task PublishWeaponSnapshotSessionAsync(
        TcpSession session, WorldEntryState state, ulong unitId, uint templateId,
        ulong currentWeaponInstanceId, CancellationToken token)
    {
        var snapshot = CombatCodec.SpiritWeaponSnapshot(
            unitId, templateId, currentWeaponInstanceId, WeaponSlotDefinitions(state, templateId));

        foreach (var weapon in snapshot.WeaponSlots)
        {
            if (weapon is null) continue;
            if (CombatCodec.Weapon(templateId, weapon.InstanceId) is { } definition)
            {
                weapon.FightStyleId = PublishedWeaponFightStyleId(state, definition);
                weapon.MagazineAmmo = EnsureMagazine4229938(state, definition);
                weapon.Durability = CurrentDurability4229938(state, definition, weapon.MagazineAmmo);
                weapon.BulletDatas.BulletId = EnsureBullet4229938(state, definition);
                if (definition.SeparateBullets && weapon.BulletDatas.BulletId != 0)
                    _ = EnsureReserve4229938(state, weapon.BulletDatas.BulletId);
            }
        }

        await session.NotifyAsync(MethodId.SyncSpiritWeaponDetail,
            Ananta.SDK.Serialization.UxSerializer.Serialize(snapshot), token);

        foreach (var detail in snapshot.WeaponSlots.Where(x => x is not null).Select(x => x!))
        {
            await session.NotifyAsync(MethodId.SyncWeaponFightStyleChange,
                Ananta.SDK.Serialization.UxSerializer.Serialize(new GameMethods.SyncWeaponFightStyleChange
                {
                    weaponInstanceId = detail.InstanceId,
                    fightStyleId = detail.FightStyleId
                }), token);
        }
    }

    
    
    
    
    private static async Task ClearClientWebLifecycleBuffsSessionAsync(
        TcpSession session, WorldEntryState state, ulong unitId, string phase)
    {
        var active = state.ActiveClientWebBuffInstances
            .Where(x => x.Key.UnitId == unitId)
            .ToArray();
        foreach (var item in active)
        {
            state.ActiveClientWebBuffInstances.Remove(item.Key);
            await session.NotifyAsync(MethodId.SyncUnitRemoveBuff,
                Ananta.SDK.Serialization.UxSerializer.Serialize(
                    WorldCodec.UnitRemoveBuff(unitId, item.Value)), default);
        }
        if (active.Length > 0)
            session.Log.Info($"[SWITCH-TL] WEB lifecycle-clear phase={phase} unit={unitId} count={active.Length}");
    }

    
    
    
    
    
    
    private static async Task PublishSafeRuntimeBuffSnapshotSessionAsync(
        TcpSession session, WorldEntryState state, ulong unitId, uint templateId, string phase)
    {
        var buffs = WebTraversal.CapabilityBuffIds(templateId);
        var firstInstanceId = state.NextBuffInstanceId;
        await session.NotifyAsync(MethodId.SyncUnitBuffList,
            Ananta.SDK.Serialization.UxSerializer.Serialize(
                WorldCodec.UnitBuffList(unitId, buffs, firstInstanceId)), default);
        state.NextBuffInstanceId += (uint)buffs.Count;

        session.Log.Info(
            $"[SWITCH-TL] BUFFS {phase} unit={unitId} template={templateId} "
            + $"count={buffs.Count} firstInstance={firstInstanceId} bulk=false safeWebOnly=true");
    }

    
    internal sealed record SwitchTimelineResult(bool Ok, string? Timeline, string? Error)
    {
        
        internal uint SwitchConfigId { get; init; }

        
        internal bool AutoPicked { get; init; }

        
        internal bool Teleported { get; init; }

        
        internal string TeleportTiming { get; init; } = "immediate";

        
        
        
        
        internal int ApexDelayMs { get; init; }

        
        internal bool SkippedPreSwitch { get; init; }

        
        internal double Distance { get; init; }

        
        internal Vec3? Anchor { get; init; }

        
        internal Vec3? Origin { get; init; }

        
        internal string? Place { get; init; }

        
        internal string? Show { get; init; }

        
        
        
        
        internal IReadOnlyList<uint> AgentTemplateIds { get; init; } = [];
    }
}
