using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using Ananta.Server.State;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    [Handler(MethodId.AskPhoneAppDownload, HandlerPacketKind.Invoke)]
    private async Task OnPhoneAppDownload(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskPhoneAppDownload4229938>();
        await conn.ReturnEmptyOkAsync(msg);

        var app = SpiritContentCatalogRepository.App(args.appId);
        SessionState.Update(s =>
        {
            if (!s.InstalledApps.Contains(args.appId))
                s.InstalledApps.Add(args.appId);
        });

        conn.Log.Info($"[SPIRITCONTENT][APP] 下载应用 {args.appId}"
            + (app is null
                ? "（配置里没有这个 app）"
                : $" '{app.Name}' 商店={app.IsInAppStore} 角色向=[{string.Join(",", app.NpcCultivationIds)}]"
                    + $" 职业向=[{string.Join(",", app.JobClassIds)}]"));
    }

    

    
    
    
    
    
    
    
    
    
    [Handler(MethodId.AskTakeJob, HandlerPacketKind.Invoke)]
    private async Task OnTakeJob(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskTakeJob4229938>();
        var result = TakeJob(conn, args.jobClassId);
        await conn.ReturnAsync(msg, result ?? new Auto.SpiritJob());
    }

    
    [Handler(MethodId.AskStartJob, HandlerPacketKind.Invoke)]
    private async Task OnStartJob(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskStartJob4229938>();
        var result = TakeJob(conn, args.jobClassId);
        await conn.ReturnAsync(msg, result ?? new Auto.SpiritJob());
    }

    
    [Handler(MethodId.AskFinishJob, HandlerPacketKind.Invoke)]
    private async Task OnFinishJob(Connection conn, UxRpcMessage msg)
    {
        var state = SessionState.Current;
        var spiritId = state.ActiveSpiritTemplateId != 0
            ? state.ActiveSpiritTemplateId
            : PrivateServerConfigStore.Current.Player.InitialSpiritTemplateId;
        var jobId = CurrentJobIdOf(state, spiritId);

        await conn.ReturnAsync(msg, BuildJobOrEmpty(spiritId, jobId));
        conn.Log.Info($"[SPIRITCONTENT][JOB] 完成班次 spirit={spiritId} job={jobId}");
    }

    
    [Handler(MethodId.AskQuitJob, HandlerPacketKind.Invoke)]
    private async Task OnQuitJob(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskQuitJob4229938>();
        var state = SessionState.Current;
        var spiritId = state.ActiveSpiritTemplateId != 0
            ? state.ActiveSpiritTemplateId
            : PrivateServerConfigStore.Current.Player.InitialSpiritTemplateId;

        
        var jobId = ResolveJobLevelId(state, spiritId, args.jobClassId);

        await conn.ReturnAsync(msg, BuildJobOrEmpty(spiritId, jobId));

        if (jobId == 0)
            return;

        SessionState.Update(s =>
        {
            if (s.SpiritJobs.TryGetValue(spiritId, out var list))
                list.RemoveAll(x => x == jobId);
            if (s.CurrentSpiritJob.GetValueOrDefault(spiritId) == jobId)
                s.CurrentSpiritJob[spiritId] = 0;
        });
        conn.Log.Info($"[SPIRITCONTENT][JOB] 辞职 spirit={spiritId} job={jobId}（class={args.jobClassId}）");
    }

    
    
    
    
    
    
    private Auto.SpiritJob? TakeJob(Connection conn, uint jobClassId)
    {
        var state = SessionState.Current;
        var spiritId = state.ActiveSpiritTemplateId != 0
            ? state.ActiveSpiritTemplateId
            : PrivateServerConfigStore.Current.Player.InitialSpiritTemplateId;

        var jobId = ResolveJobLevelId(state, spiritId, jobClassId);
        if (jobId == 0)
        {
            conn.Log.Warn($"[SPIRITCONTENT][JOB] 找不到职业大类 {jobClassId} 的等级 1 配置，忽略");
            return null;
        }

        SessionState.Update(s =>
        {
            if (!s.SpiritJobs.TryGetValue(spiritId, out var list))
                s.SpiritJobs[spiritId] = list = [];
            if (!list.Contains(jobId))
                list.Add(jobId);
            s.CurrentSpiritJob[spiritId] = jobId;
        });

        var job = RuntimePayloadFactory.BuildSpiritJob4229938(spiritId, jobId);
        conn.Log.Info($"[SPIRITCONTENT][JOB] 接取职业 spirit={spiritId} class={jobClassId} job={jobId}"
            + $" '{SpiritContentCatalogRepository.JobLevel(jobId)?.Name}'");

        _ = PushJobInfoAsync(conn.Session, spiritId);
        _ = PushJobSystemsAsync(conn.Session, jobClassId);
        return job;
    }

    
    private static uint ResolveJobLevelId(PlayerState state, uint spiritId, uint jobClassId)
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        var wantTop = settings.MaxJobLevel && settings.JobTopTier;

        
        if (state.SpiritJobs.TryGetValue(spiritId, out var owned))
        {
            foreach (var ownedId in owned)
                if (SpiritContentCatalogRepository.JobLevel(ownedId)?.JobClass == jobClassId)
                    return ownedId;
        }

        
        var row = SpiritContentCatalogRepository.Spirit(spiritId);
        if (row is not null)
        {
            var defaultJob = SpiritContentCatalogRepository.DefaultJobId(row);
            if (defaultJob != 0 &&
                SpiritContentCatalogRepository.JobLevel(defaultJob)?.JobClass == jobClassId)
                return defaultJob;

            
            foreach (var avatarJob in SpiritContentCatalogRepository.AvatarJobIds(spiritId))
                if (SpiritContentCatalogRepository.JobLevel(avatarJob)?.JobClass == jobClassId)
                    return avatarJob;
        }

        
        if (wantTop)
        {
            var top = SpiritContentCatalogRepository.TopJobLevelOf(jobClassId);
            if (top != 0)
                return top;
        }

        return SpiritContentCatalogRepository.EntryJobLevelOf(jobClassId);
    }

    private static uint CurrentJobIdOf(PlayerState state, uint spiritId)
    {
        if (state.CurrentSpiritJob.TryGetValue(spiritId, out var id) && id != 0)
            return id;
        var row = SpiritContentCatalogRepository.Spirit(spiritId);
        return row is null ? 0u : SpiritContentCatalogRepository.DefaultJobId(row);
    }

    private static Auto.SpiritJob BuildJobOrEmpty(uint spiritId, uint jobId)
    {
        if (jobId == 0)
            return new Auto.SpiritJob();
        return RuntimePayloadFactory.BuildSpiritJob4229938(spiritId, jobId) ?? new Auto.SpiritJob();
    }

    

    
    
    
    
    [Handler(MethodId.AskActiveSpiritJobTalentLayer, HandlerPacketKind.Invoke)]
    private async Task OnActiveSpiritJobTalentLayer(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskActiveSpiritJobTalentLayer4229938>();
        await conn.ReturnEmptyOkAsync(msg);

        var add = args.addLayer == 0 ? 1u : args.addLayer;
        var layer = 0u;
        SessionState.Update(s =>
        {
            if (!s.SpiritJobTalents.TryGetValue(args.spiritId, out var dict))
                s.SpiritJobTalents[args.spiritId] = dict = new Dictionary<uint, uint>();
            layer = dict.GetValueOrDefault(args.talentId) + add;
            dict[args.talentId] = layer;
        });

        await conn.NotifyAsync(MethodId.SyncActiveSpiritJobTalentLayer,
            new GameMethods.SyncActiveSpiritJobTalentLayer4229938
            {
                spiritId = args.spiritId,
                jobClassId = args.jobClassId,
                talentId = args.talentId,
                layer = layer,
            });

        conn.Log.Info($"[SPIRITCONTENT][TALENT] 激活职业天赋 spirit={args.spiritId} "
            + $"class={args.jobClassId} talent={args.talentId} -> layer {layer}");
    }

    
    [Handler(MethodId.AskResetSpiritJobTalent, HandlerPacketKind.Invoke)]
    private async Task OnResetSpiritJobTalent(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskResetSpiritJobTalent4229938>();
        await conn.ReturnEmptyOkAsync(msg);

        SessionState.Update(s => s.SpiritJobTalents.Remove(args.spiritId));

        await conn.NotifyAsync(MethodId.SyncSpiritJobTalentPoint,
            new GameMethods.SyncSpiritJobTalentPoint4229938
            {
                spiritId = args.spiritId,
                jobClassId = args.jobClassId,
                talentPoint = 0,
                reason = 0,
            });

        conn.Log.Info($"[SPIRITCONTENT][TALENT] 重置职业天赋 spirit={args.spiritId} class={args.jobClassId}");
    }

    
    
    
    
    [Handler(MethodId.AskConvertCommonSpiritTalentExp, HandlerPacketKind.Invoke)]
    private async Task OnConvertCommonSpiritTalentExp(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskConvertCommonSpiritTalentExp4229938>();
        await conn.ReturnEmptyOkAsync(msg);

        var remaining = 0u;
        SessionState.Update(s =>
        {
            var spend = Math.Min(args.convertExp, s.CommonSpiritTalentExp);
            s.CommonSpiritTalentExp -= spend;
            remaining = s.CommonSpiritTalentExp;
        });

        await conn.NotifyAsync(MethodId.SyncCommonSpiritTalentExp,
            new GameMethods.SyncCommonSpiritTalentExp4229938
            {
                changeExp = args.convertExp,
                isAdd = false,
                exp = remaining,
            });
        await conn.NotifyAsync(MethodId.SyncSpiritTalentExpAndLevel,
            new GameMethods.SyncSpiritTalentExpAndLevel4229938
            {
                spiritId = args.spiritId,
                addExp = args.convertExp,
                exp = args.convertExp,
                level = PrivateServerConfigStore.Current.Gameplay.SpiritContent.SpiritTalentLevel,
            });

        conn.Log.Info($"[SPIRITCONTENT][TALENT] 通用天赋经验转给角色 spirit={args.spiritId} "
            + $"amount={args.convertExp} 剩余={remaining}");
    }

    

    
    internal static async Task PushJobInfoAsync(TcpSession session, uint spiritId)
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        var state = SessionState.Current;
        var jobs = new Dictionary<uint, Auto.SpiritJob>();

        var row = SpiritContentCatalogRepository.Spirit(spiritId);
        if (row is not null && settings.GrantDefaultJobs)
        {
            
            
            
            
            var ids = settings.GrantAvatarJobs
                ? SpiritContentCatalogRepository.EffectiveJobIds(row)
                : [];
            foreach (var jobId in ids)
            {
                var job = RuntimePayloadFactory.BuildSpiritJob4229938(spiritId, jobId);
                if (job is not null)
                    jobs[jobId] = job;
            }

            
            
            
            var jobless = RuntimePayloadFactory.BuildSpiritJob4229938(
                spiritId, RuntimePayloadFactory.UrbanJobConfigJobless);
            if (jobless is not null)
                jobs[RuntimePayloadFactory.UrbanJobConfigJobless] = jobless;

            
            
            
            
            if (settings.MaxJobLevel && settings.JobTopTier)
            {
                foreach (var cls in SpiritContentCatalogRepository.EffectiveJobClasses(row))
                {
                    var top = SpiritContentCatalogRepository.TopJobLevelOf(cls);
                    if (top == 0 || jobs.ContainsKey(top))
                        continue;
                    var topJob = RuntimePayloadFactory.BuildSpiritJob4229938(spiritId, top);
                    if (topJob is null)
                        continue;
                    jobs[top] = topJob;
                }

                
                
                var keep = SpiritContentCatalogRepository.EffectiveJobClasses(row)
                    .Select(SpiritContentCatalogRepository.TopJobLevelOf)
                    .Where(x => x != 0)
                    .ToHashSet();
                foreach (var jobId in jobs.Keys.ToArray())
                {
                    if (jobId == RuntimePayloadFactory.UrbanJobConfigJobless || keep.Contains(jobId))
                        continue;
                    if (state.SpiritJobs.TryGetValue(spiritId, out var owned) && owned.Contains(jobId))
                        continue;
                    jobs.Remove(jobId);
                }
            }
        }

        if (state.SpiritJobs.TryGetValue(spiritId, out var extra))
        {
            foreach (var jobId in extra)
            {
                if (jobId == 0 || jobs.ContainsKey(jobId))
                    continue;
                jobs[jobId] = RuntimePayloadFactory.BuildSpiritJob4229938(spiritId, jobId)
                    ?? new Auto.SpiritJob();
            }
        }

        var defaultJobId = row is null ? 0u : SpiritContentCatalogRepository.DefaultJobId(row);
        var current = defaultJobId != 0 ? defaultJobId : RuntimePayloadFactory.UrbanJobConfigJobless;
        if (state.CurrentSpiritJob.TryGetValue(spiritId, out var picked) && picked != 0)
            current = picked;

        
        if (row is not null && settings.MaxJobLevel && settings.JobTopTier)
        {
            var cls = SpiritContentCatalogRepository.DefaultJobClass(row);
            var top = cls == 0 ? 0u : SpiritContentCatalogRepository.TopJobLevelOf(cls);
            if (top != 0 && jobs.ContainsKey(top))
                current = top;
        }

        await session.NotifyAsync(MethodId.SyncSpiritJobInfo, UxSerializer.Serialize(
            new GameMethods.SyncSpiritJobInfo4229938
            {
                spiritId = spiritId,
                spiritJobs = jobs,
                currentJob = current,
            }), CancellationToken.None);
    }

    
    internal static async Task PushJobSystemsAsync(TcpSession session, uint jobClassId)
    {
        if (!PrivateServerConfigStore.Current.Gameplay.SpiritContent.UnlockJobSystems)
            return;

        var cls = SpiritContentCatalogRepository.JobClass(jobClassId);
        if (cls is null || cls.SystemUnlock == 0)
            return;

        await session.NotifyAsync(MethodId.SyncUnlockSystems, UxSerializer.Serialize(
            new GameMethods.SyncUnlockSystems4229938 { unlockSystems = [cls.SystemUnlock] }),
            CancellationToken.None);
        session.Log.Info($"[SPIRITCONTENT][JOB] 解锁职业系统 {cls.SystemUnlock}（{cls.ClassName}）");
    }

    
    
    
    
    internal static async Task PushAllSpiritJobsAsync(TcpSession session)
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        if (!settings.Enabled || !settings.GrantDefaultJobs)
            return;

        var count = 0;
        foreach (var character in ClientConfigRepository.Characters())
        {
            await PushJobInfoAsync(session, character.TemplateId);
            count++;
        }
        session.Log.Info($"[SPIRITCONTENT][JOB] 下发 {count} 个角色的职业（SyncSpiritJobInfo）");
    }

    
    
    
    
    
    
    
    internal static void LogSpiritContent()
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        if (!settings.Enabled || !settings.LogPerSpirit)
            return;

        
        
        Console.WriteLine($"[SPIRITCONTENT] {SpiritContentCatalogRepository.Summary()}");

        foreach (var character in ClientConfigRepository.Characters())
        {
            var spiritId = character.TemplateId;
            var row = SpiritContentCatalogRepository.Spirit(spiritId);
            if (row is null)
                continue;

            var jobId = SpiritContentCatalogRepository.DefaultJobId(row);
            var jobClass = SpiritContentCatalogRepository.DefaultJobClass(row);
            var avatarJobs = SpiritContentCatalogRepository.AvatarJobIds(spiritId);
            var styles = SpiritContentCatalogRepository.ExclusiveFightStyles(spiritId).Select(x => x.Id).ToArray();
            var apps = SpiritContentCatalogRepository.AppsForSpirit(spiritId).Select(x => x.Id).ToArray();
            var traits = SpiritContentCatalogRepository.Characteristics(spiritId).Select(x => x.Id).ToArray();
            var trees = SpiritContentCatalogRepository.TalentTreesFor(spiritId).Select(x => x.Id).ToArray();
            var fakeFiles = SpiritContentCatalogRepository.FakeFilesForSpirit(spiritId).Count;

            if (jobId == 0 && avatarJobs.Count == 0 && styles.Length == 0 && apps.Length == 0
                && traits.Length == 0 && trees.Length == 0 && fakeFiles == 0)
                continue;

            Console.WriteLine($"[SPIRITCONTENT][SPIRIT] {spiritId} {row.Name} "
                + $"job={jobId}({SpiritContentCatalogRepository.JobLevel(jobId)?.Name}/{jobClass}) "
                + $"avatarJobs=[{string.Join(",", avatarJobs)}] "
                + $"styles=[{string.Join(",", styles)}] apps=[{string.Join(",", apps)}] "
                + $"traits=[{string.Join(",", traits)}] trees=[{string.Join(",", trees)}] "
                + $"fakeFiles={fakeFiles}");
        }
    }

    
    internal static object SpiritContentReport(uint spiritId)
    {
        var row = SpiritContentCatalogRepository.Spirit(spiritId);
        if (row is null)
            return new { error = $"配置里没有角色 {spiritId}" };

        var jobId = SpiritContentCatalogRepository.DefaultJobId(row);
        var jobClass = SpiritContentCatalogRepository.DefaultJobClass(row);
        return new
        {
            spiritId,
            name = row.Name,
            npcCultivationId = row.NpcCultivationId,
            defaultJobId = row.DefaultUrbanJob,
            defaultJobName = SpiritContentCatalogRepository.JobLevel(row.DefaultUrbanJob)?.Name,
            jobClassId = jobClass,
            jobClassName = SpiritContentCatalogRepository.JobClass(jobClass)?.ClassName,
            jobSystemUnlock = SpiritContentCatalogRepository.JobClass(jobClass)?.SystemUnlock,
            avatarJobIds = SpiritContentCatalogRepository.AvatarJobIds(spiritId).ToArray(),
            effectiveJobIds = SpiritContentCatalogRepository.EffectiveJobIds(row).ToArray(),
            effectiveJobClasses = SpiritContentCatalogRepository.EffectiveJobClasses(row).ToArray(),
            fakeFiles = SpiritContentCatalogRepository.FakeFilesForSpirit(spiritId)
                .Select(x => new { x.Id, x.AgentId, x.Desc, x.ClueValue }).ToArray(),
            fightStyles = SpiritContentCatalogRepository.ExclusiveFightStyles(spiritId)
                .Select(x => new { x.Id, x.Name, x.SourceDesc, x.IsLocked }).ToArray(),
            apps = SpiritContentCatalogRepository.AppsForSpirit(spiritId)
                .Select(x => new { x.Id, x.Name, x.IsInAppStore, x.NpcCultivationIds, x.JobClassIds }).ToArray(),
            characteristics = SpiritContentCatalogRepository.Characteristics(spiritId)
                .Select(x => new { x.Id, x.Name, x.Description, x.Quality }).ToArray(),
            spiritTalents = SpiritContentCatalogRepository.SpiritTalents(spiritId)
                .SelectMany(g => g.TalentIds)
                .Select(id => new
                {
                    talentId = id,
                    title = SpiritContentCatalogRepository.SpiritTalentEffect(id)?.Title,
                    buffs = SpiritContentCatalogRepository.SpiritTalentEffect(id)?.BuffIds,
                    unlockWorldLevel = SpiritContentCatalogRepository.SpiritTalentUnlock(id)?.UnlockWorldLevel,
                }).ToArray(),
            talentTrees = SpiritContentCatalogRepository.TalentTreesFor(spiritId)
                .Select(t => new
                {
                    t.Id,
                    t.Name,
                    t.TabIndex,
                    t.JobClassId,
                    t.SpiritIds,
                    nodes = SpiritContentCatalogRepository.TalentNodes(t.Id).Count,
                }).ToArray(),
        };
    }
}
