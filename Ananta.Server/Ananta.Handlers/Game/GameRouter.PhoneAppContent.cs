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
    

    
    
    
    
    
    
    
    [Handler(MethodId.AskChangeHackerName, HandlerPacketKind.Invoke)]
    private async Task OnChangeHackerName(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskChangeHackerName4229938>();
        var name = (args.name ?? string.Empty).Trim();
        if (name.Length == 0)
        {
            
            await conn.ReturnEmptyOkAsync(msg);
            conn.Log.Warn("[PHONEAPP][HACKER] 收到空的黑客代号，忽略（仍回 OK 以免客户端卡住）");
            return;
        }

        
        if (name.Length > 32)
            name = name[..32];

        SessionState.Update(s => s.HackerName = name);
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[PHONEAPP][HACKER] 黑客代号改为 '{name}'");

        await PushHackerJobInfoAsync(conn.Session);
    }

    
    [Handler(MethodId.AskReadHackerNewPost, HandlerPacketKind.Invoke)]
    private async Task OnReadHackerNewPost(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskReadHackerNewPost4229938>();
        await conn.ReturnEmptyOkAsync(msg);

        SessionState.Update(s =>
        {
            if (args.postId != 0 && !s.HackerReadPosts.Contains(args.postId))
                s.HackerReadPosts.Add(args.postId);
        });
        conn.Log.Info($"[PHONEAPP][HACKER] 已读帖子 {args.postId}");

        await PushHackerJobInfoAsync(conn.Session);
    }

    
    [Handler(MethodId.AskAcceptHackerPostTask, HandlerPacketKind.Invoke)]
    private async Task OnAcceptHackerPostTask(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskAcceptHackerPostTask4229938>();
        await conn.ReturnEmptyOkAsync(msg);

        if (args.postId != 0)
        {
            SessionState.Update(s => s.HackerPostStates[args.postId] = HackerPostStateAccepted);
            conn.Log.Info($"[PHONEAPP][HACKER] 接取帖子任务 {args.postId}");
        }

        await PushHackerJobInfoAsync(conn.Session);
    }

    
    internal const int HackerPostStateNew = 0;
    internal const int HackerPostStateAccepted = 1;
    internal const int HackerPostStateCompleted = 2;

    
    
    
    
    
    internal static async Task PushHackerJobInfoAsync(TcpSession session)
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        if (!settings.Enabled)
            return;

        var state = SessionState.Current;

        
        
        
        
        if (string.IsNullOrWhiteSpace(settings.HackerName)
            && !settings.UnlockHackerPosts
            && string.IsNullOrWhiteSpace(state.HackerName)
            && state.HackerPostStates.Count == 0)
        {
            session.Log.Info("[PHONEAPP][HACKER] hackerName 为空且 unlockHackerPosts=false，跳过 SyncHackerJobInfo");
            return;
        }

        var payload = new Auto.SpiritHackerJobInfo
        {
            HackerName = string.IsNullOrWhiteSpace(state.HackerName)
                ? settings.HackerName ?? string.Empty
                : state.HackerName,
            Rank = settings.HackerRank,
        };

        if (settings.UnlockHackerPosts)
        {
            foreach (var post in SpiritContentCatalogRepository.AllHackerPosts)
            {
                var postState = state.HackerPostStates.TryGetValue(post.Id, out var saved)
                    ? saved
                    : settings.HackerPostState;
                payload.PostInfos[post.Id] = new Auto.HackerPostInfo
                {
                    Id = post.Id,
                    State = postState,
                    HaveRead = settings.HackerPostsRead || state.HackerReadPosts.Contains(post.Id),
                };
            }
        }
        else
        {
            foreach (var (postId, postState) in state.HackerPostStates)
            {
                payload.PostInfos[postId] = new Auto.HackerPostInfo
                {
                    Id = postId,
                    State = postState,
                    HaveRead = state.HackerReadPosts.Contains(postId),
                };
            }
        }

        await session.NotifyAsync(MethodId.IGameToClient_SyncHackerJobInfo,
            UxSerializer.Serialize(new GameMethods.SyncHackerJobInfo4229938
            {
                hackerJobInfo = payload,
            }), CancellationToken.None);

        session.Log.Info($"[PHONEAPP][HACKER] 下发 SyncHackerJobInfo 代号='{payload.HackerName}' "
            + $"rank={payload.Rank} 帖子={payload.PostInfos.Count}");
    }

    

    
    
    
    
    
    
    
    
    
    internal static async Task PushPoliceFakeFilesAsync(TcpSession session)
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        if (!settings.Enabled || !settings.UnlockPoliceFakeFiles)
            return;

        var pushed = 0;
        foreach (var spiritId in SpiritContentCatalogRepository.FakeFileSpiritIds)
        {
            var rows = SpiritContentCatalogRepository.FakeFilesForSpirit(spiritId);
            if (rows.Count == 0)
                continue;

            var info = new Auto.PoliceFakeFileInfo();
            foreach (var row in rows)
            {
                info.UnlockFileInfoDict[row.Id] = new Auto.SinglePoliceFakeFileInfo
                {
                    State = PoliceFakeFileStateUnlock,
                    InterrogationTime = 0,
                };
            }

            await session.NotifyAsync(MethodId.SyncPoliceFakeFileInfo,
                UxSerializer.Serialize(new GameMethods.SyncPoliceFakeFileInfo4229938
                {
                    spiritId = spiritId,
                    policeFakeFileInfo = info,
                }), CancellationToken.None);

            pushed += rows.Count;
            session.Log.Info($"[PHONEAPP][POLICE] 下发伪人档案全解锁 spirit={spiritId} 条目={rows.Count}");
        }

        if (pushed > 0)
            SessionState.Update(s => s.PoliceFakeFilesUnlocked = true);
    }

    
    internal const byte PoliceFakeFileStateUnlock = 8;

    

    
    internal const uint NccaJobClassId = 11300003u;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static async Task PushPoliceAppContentAsync(TcpSession session)
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        if (!settings.Enabled || !settings.PoliceAppContentEnabled)
            return;

        var spirits = SpiritContentCatalogRepository.AllSpirits
            .Where(s => SpiritContentCatalogRepository.EffectiveJobClasses(s).Contains(NccaJobClassId))
            .Select(s => s.Id)
            .ToArray();
        if (spirits.Length == 0)
        {
            session.Log.Info("[PHONEAPP][POLICE] 名册里没有 NCCA 职业的角色，跳过 App 内容下发");
            return;
        }

        var dispatches = PoliceAppCatalog4229938.AppDispatches;
        var cases = BuildPoliceCases(settings);
        var now = NowUnix();

        foreach (var spiritId in spirits)
        {
            
            await session.NotifyAsync(MethodId.SyncSpiritPoliceCaseInfos,
                UxSerializer.Serialize(new GameMethods.SyncSpiritPoliceCaseInfos4229938
                {
                    spiritId = spiritId,
                    cases = cases,
                }), CancellationToken.None);

            
            await session.NotifyAsync(MethodId.SyncPoliceServiceData,
                UxSerializer.Serialize(new GameMethods.SyncPoliceServiceData4229938
                {
                    spiritId = spiritId,
                    serviceData = new GameMethods.PoliceServiceData4229938(),
                    weeklyServiceData = new GameMethods.PoliceServiceData4229938(),
                    stopPatrol = false,
                }), CancellationToken.None);

            
            var infos = new Dictionary<uint, GameMethods.PoliceDispatchInfo4229938>();
            foreach (var d in dispatches)
            {
                infos[d.Id] = new GameMethods.PoliceDispatchInfo4229938
                {
                    Id = d.Id,
                    NextAvailableTime = 0,          
                    IsTemp = false,
                    TempEventId = 0,
                    TodayArrestSupportTimes = 0,
                };
            }

            await session.NotifyAsync(MethodId.SyncPoliceDispatchInfos,
                UxSerializer.Serialize(new GameMethods.SyncPoliceDispatchInfos4229938
                {
                    spiritId = spiritId,
                    dispatchInfos = infos,
                }), CancellationToken.None);

            session.Log.Info($"[PHONEAPP][POLICE] 下发 NCCA App 内容 spirit={spiritId} "
                + $"案件={cases.Count} 支援={infos.Count} "
                + $"（支援={string.Join("/", dispatches.Select(d => $"{d.Id}:{d.Name}×{d.Number}"))}）");
        }

        session.Log.Info($"[PHONEAPP][POLICE] 案件明细："
            + string.Join(" | ", cases.Select(c =>
                $"id={c.Id} npc={c.NpcId} t={c.Time} fines=[{string.Join(",", c.Fines)}] "
                + $"drops=[{string.Join(",", c.BonusDrops)}] sentence={c.Sentence}")));
    }

    
    
    
    
    
    
    
    
    
    private static List<GameMethods.PoliceCaseInfo4229938> BuildPoliceCases(SpiritContentSettings settings)
        => BuildPoliceCasesCore(settings);

    
    internal static List<GameMethods.PoliceCaseInfo4229938> BuildPoliceCasesForProbe(
        SpiritContentSettings settings)
        => BuildPoliceCasesCore(settings);

    
    internal static uint FirstNccaSpiritId()
    {
        var id = SpiritContentCatalogRepository.AllSpirits
            .Where(s => SpiritContentCatalogRepository.EffectiveJobClasses(s).Contains(NccaJobClassId))
            .Select(s => s.Id)
            .FirstOrDefault();
        return id != 0 ? id : 15021021u;
    }

    private static List<GameMethods.PoliceCaseInfo4229938> BuildPoliceCasesCore(SpiritContentSettings settings)
    {
        var now = NowUnix();
        var result = new List<GameMethods.PoliceCaseInfo4229938>();
        var index = 0;

        foreach (var spec in settings.PoliceCaseSpecs)
        {
            var parts = spec.Split(':', 2);
            if (parts.Length != 2
                || !uint.TryParse(parts[0].Trim(), out var npcId)
                || npcId == 0)
            {
                continue;
            }

            var fines = new List<uint>();
            var drops = new List<uint>();
            foreach (var raw in parts[1].Split(',', StringSplitOptions.RemoveEmptyEntries))
            {
                if (!uint.TryParse(raw.Trim(), out var fineId) || fineId == 0)
                    continue;

                fines.Add(fineId);
                var fine = PoliceAppCatalog4229938.Fine(fineId);
                if (fine is not null && fine.Drop != 0 && !drops.Contains(fine.Drop))
                    drops.Add(fine.Drop);
            }

            if (fines.Count == 0)
                continue;

            result.Add(new GameMethods.PoliceCaseInfo4229938
            {
                Time = now - (uint)((index + Math.Max(0, settings.PoliceCaseDaysAgo)) * 86400),
                NpcId = npcId,
                Fines = fines,
                Sentence = 0,
                Drops = [],
                RewardTaken = false,
                BonusDrops = drops,
                Id = PoliceCaseIdBase + (ulong)index,
                IsFakePerson = false,
                InterrogationInfo = null,       
                NpcImprisonStatus = 0,
                FinedCrimes = [],
                NoCheckCrimeList = [],
                NoIssuedBonusDrops = [],
                HasUnlockClue = false,
                SourceType = 0,
                CrimeDefaultItems = [],
            });

            index++;
        }

        return result;
    }

    
    internal const ulong PoliceCaseIdBase = 930000000000UL;

    
    private static uint NowUnix()
        => (uint)DateTimeOffset.UtcNow.ToUnixTimeSeconds();

    

    
    
    
    
    internal static async Task PushAllPhoneAppContentAsync(TcpSession session)
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        if (!settings.Enabled)
            return;

        await PushHackerJobInfoAsync(session);
        await PushPoliceFakeFilesAsync(session);
        await PushPoliceAppContentAsync(session);
    }
}
