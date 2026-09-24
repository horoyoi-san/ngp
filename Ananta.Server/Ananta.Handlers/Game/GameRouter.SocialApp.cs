using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.State;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    
    internal const byte SocialPostTypePost = 1;

    
    internal const byte SocialPostTypeStory = 2;

    
    internal const byte SocialPostTypeShare = 3;

    

    
    
    
    
    
    
    
    
    [Handler(MethodId.AskMomentsPostSimpleInfos, HandlerPacketKind.Invoke)]
    private async Task OnMomentsPostSimpleInfos(Connection conn, UxRpcMessage msg)
    {
        var args = msg.TryGetArgs<GameMethods.AskMomentsPostSimpleInfos4229938>(out var a)
            ? a
            : new GameMethods.AskMomentsPostSimpleInfos4229938();
        var posts = BuildSocialPostList();
        await conn.ReturnAsync(msg, posts);
        conn.Log.Info($"[SOCIAL][BUBBLE] AskMomentsPostSimpleInfos lastId={args.lastId} "
            + $"postType={args.postType} → {posts.Count} 条动态");
    }

    
    [Handler(MethodId.AskMomentsPostInfos, HandlerPacketKind.Invoke)]
    private async Task OnMomentsPostInfos(Connection conn, UxRpcMessage msg)
    {
        
        
        List<uint>? ids = null;
        string framing;
        if (msg.TryGetArgs<GameMethods.AskMomentsPostInfos4229938>(out var int7))
        {
            ids = int7.postIds;
            framing = "Int7";
        }
        else if (msg.TryGetArgs<GameMethods.AskMomentsPostInfosInt324229938>(out var int32))
        {
            ids = int32.postIds;
            framing = "Int32(兜底)";
        }
        else
        {
            framing = "两种都失败";
        }

        var all = BuildSocialPostList();
        var posts = ids is { Count: > 0 }
            ? all.Where(p => ids.Contains(p.Id)).ToList()
            : all;
        await conn.ReturnAsync(msg, posts);
        conn.Log.Info($"[SOCIAL][BUBBLE] AskMomentsPostInfos [{framing}] "
            + $"requested={ids?.Count ?? 0} → {posts.Count} 条动态");
    }

    
    
    
    
    
    [Handler(MethodId.AskMomentsUnreadMessage, HandlerPacketKind.Invoke)]
    private async Task OnMomentsUnreadMessage(Connection conn, UxRpcMessage msg)
    {
        var state = SessionState.Current;
        var read = (state.SocialReadPosts ?? []).ToHashSet();
        var list = SocialCatalogRepository4229938.AllPosts
            .Where(p => p.WithMe && !read.Contains(p.Id))
            .Select(p => new GameMethods.SimpleUnreadMessage4229938
            {
                PostId = p.Id,
                CommentId = p.CommentIds.Count > 0 ? p.CommentIds[0] : 0,
                MessageType = 0,
            })
            .ToList();

        await conn.ReturnAsync(msg, list);
        conn.Log.Info($"[SOCIAL][BUBBLE] AskMomentsUnreadMessage → {list.Count} 条未读");
    }

    
    [Handler(MethodId.AskMomentsHaveUnreadMessage, HandlerPacketKind.Invoke)]
    private async Task OnMomentsHaveUnreadMessage(Connection conn, UxRpcMessage msg)
    {
        var read = (SessionState.Current.SocialReadPosts ?? []).ToHashSet();
        var any = SocialCatalogRepository4229938.AllPosts.Any(p => p.WithMe && !read.Contains(p.Id));
        await conn.ReturnAsync(msg, any);
        conn.Log.Info($"[SOCIAL][BUBBLE] AskMomentsHaveUnreadMessage → {any}");
    }

    

    
    [Handler(MethodId.AskMomentsMarkRead, HandlerPacketKind.Invoke)]
    private async Task OnMomentsMarkRead(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);

        
        
        List<uint>? ids = null;
        string framing;
        if (msg.TryGetArgs<GameMethods.AskMomentsMarkRead4229938>(out var int7))
        {
            ids = int7.postIds;
            framing = "Int7";
        }
        else if (msg.TryGetArgs<GameMethods.AskMomentsMarkReadInt324229938>(out var int32))
        {
            ids = int32.postIds;
            framing = "Int32(兜底)";
        }
        else
        {
            framing = "两种都失败";
        }

        if (ids is null || ids.Count == 0)
        {
            conn.Log.Warn($"[SOCIAL][BUBBLE] AskMomentsMarkRead 参数解析失败或为空（{framing}，"
                + $"body={msg.Body.Length}B）");
            return;
        }

        var added = 0;
        SessionState.Update(s =>
        {
            s.SocialReadPosts ??= [];
            foreach (var id in ids)
            {
                if (id == 0 || s.SocialReadPosts.Contains(id))
                    continue;
                s.SocialReadPosts.Add(id);
                added++;
            }
        });
        conn.Log.Info($"[SOCIAL][BUBBLE] AskMomentsMarkRead [{framing}] "
            + $"标记已读 {added} 条（请求 {ids.Count}）");
    }

    
    [Handler(MethodId.AskMomentsLikePost, HandlerPacketKind.Invoke)]
    private async Task OnMomentsLikePost(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);

        var parsed = msg.TryGetArgs<GameMethods.AskMomentsLikePost4229938>(out var args);
        if (!parsed || args.postId == 0)
        {
            conn.Log.Warn($"[SOCIAL][BUBBLE] AskMomentsLikePost 参数解析失败（parsed={parsed}）");
            return;
        }

        SessionState.Update(s =>
        {
            if (args.like)
            {
                if (!s.SocialLikedPosts.Contains(args.postId))
                    s.SocialLikedPosts.Add(args.postId);
            }
            else
            {
                s.SocialLikedPosts.Remove(args.postId);
            }
        });
        conn.Log.Info($"[SOCIAL][BUBBLE] AskMomentsLikePost post={args.postId} like={args.like}");
    }

    
    
    
    
    
    
    
    [Handler(MethodId.AskMomentsSendCommentWithId, HandlerPacketKind.Invoke)]
    private async Task OnMomentsSendCommentWithId(Connection conn, UxRpcMessage msg)
    {
        var parsed = msg.TryGetArgs<GameMethods.AskMomentsSendCommentWithId4229938>(out var args);
        if (!parsed)
        {
            await conn.ReturnAsync(msg, new GameMethods.PostPlayerCommentClientInfo4229938
            {
                Comment = string.Empty,
                CommentId = 0,
                IsFinish = true,
            });
            conn.Log.Warn("[SOCIAL][BUBBLE] AskMomentsSendCommentWithId 参数解析失败");
            return;
        }

        var row = SocialCatalogRepository4229938.Comment(args.commentId);
        SessionState.Update(s =>
        {
            if (!s.SocialPlayerComments.TryGetValue(args.postId, out var list))
            {
                list = [];
                s.SocialPlayerComments[args.postId] = list;
            }
            if (args.commentId != 0 && !list.Contains(args.commentId))
                list.Add(args.commentId);
        });

        await conn.ReturnAsync(msg, new GameMethods.PostPlayerCommentClientInfo4229938
        {
            Comment = row?.Txt ?? string.Empty,
            CommentId = args.commentId,
            IsFinish = true,
        });
        conn.Log.Info($"[SOCIAL][BUBBLE] AskMomentsSendCommentWithId post={args.postId} "
            + $"comment={args.commentId} 回复='{row?.Txt}'");
    }

    
    [Handler(MethodId.AskMomentsTapPostWithCount, HandlerPacketKind.Invoke)]
    private async Task OnMomentsTapPostWithCount(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);

        
        string framing;
        uint postId = 0;
        int emojiCount = 0;
        if (msg.TryGetArgs<GameMethods.AskMomentsTapPostWithCount4229938>(out var int7))
        {
            postId = int7.postId;
            emojiCount = int7.emojiList.Count;
            framing = "Int7";
        }
        else if (msg.TryGetArgs<GameMethods.AskMomentsTapPostWithCountInt324229938>(out var int32))
        {
            postId = int32.postId;
            emojiCount = int32.emojiList.Count;
            framing = "Int32(兜底)";
        }
        else
        {
            framing = "两种都失败";
        }

        conn.Log.Info($"[SOCIAL][BUBBLE] AskMomentsTapPostWithCount [{framing}] "
            + $"post={postId} emoji={emojiCount} body={msg.Body.Length}B");
    }

    

    
    
    
    
    internal static List<GameMethods.PostSimpleClientInfo4229938> BuildSocialPostList()
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SocialApp;
        if (!settings.Enabled)
            return [];

        
        
        
        
        
        var state = SessionState.Current;
        var read = (state.SocialReadPosts ?? []).ToHashSet();
        var liked = (state.SocialLikedPosts ?? []).ToHashSet();
        var playerCommentsOf = state.SocialPlayerComments ?? [];

        var rows = settings.IncludeAllPosts
            ? SocialCatalogRepository4229938.AllPosts
            : SocialCatalogRepository4229938.AllPosts.Where(x => x.WithMe).ToList();

        
        var step = settings.PostDateStepSeconds == 0 ? 7200u : settings.PostDateStepSeconds;
        var baseUnix = settings.PostDateBaseUnix != 0
            ? settings.PostDateBaseUnix
            : DateTimeOffset.UtcNow.ToUnixTimeSeconds() - (long)step * rows.Count;

        var result = new List<GameMethods.PostSimpleClientInfo4229938>(rows.Count);
        for (var i = 0; i < rows.Count; i++)
        {
            var row = rows[i];

            
            
            
            
            var postType = row.IfPinStory
                ? SocialPostTypeShare
                : row.IfStory
                    ? SocialPostTypeStory
                    : SocialPostTypePost;

            var playerComments = new List<GameMethods.PostPlayerCommentClientInfo4229938>();
            if (playerCommentsOf.TryGetValue(row.Id, out var mine) && mine is not null)
            {
                foreach (var commentId in mine)
                {
                    playerComments.Add(new GameMethods.PostPlayerCommentClientInfo4229938
                    {
                        Comment = SocialCatalogRepository4229938.Comment(commentId)?.Txt ?? string.Empty,
                        CommentId = commentId,
                        IsFinish = true,
                    });
                }
            }

            result.Add(new GameMethods.PostSimpleClientInfo4229938
            {
                Id = row.Id,
                PostType = postType,
                PostConfigId = row.Id,      
                Date = (uint)(baseUnix + (long)i * step),
                ImageUrl = string.Empty,    
                Approved = true,
                Title = string.Empty,       
                Likes = row.Likes,
                Liked = liked.Contains(row.Id),
                LikeNpcs = [],
                Comments = [.. row.CommentIds],
                PlayerComments = playerComments,
                IsRead = read.Contains(row.Id),
                HasNewLike = false,
                AcquireCfgId = 0,
                ActivityCfgId = 0,
                IsStory = row.IfStory,
                IsPinStory = row.IfPinStory,
            });
        }

        return result;
    }

    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    [Handler(MethodId.AskServerGraffitoUrl, HandlerPacketKind.Invoke)]
    private async Task OnAskServerGraffitoUrl(Connection conn, UxRpcMessage msg)
    {
        var url = PrivateServerConfigStore.Current.Gameplay.SocialApp.GraffitoUrl ?? string.Empty;
        await conn.ReturnAsync(msg, url);
        conn.Log.Info($"[SOCIAL][GRAFFITO] AskServerGraffitoUrl → '{url}'"
            + (string.IsNullOrEmpty(url)
                ? "（空 ⇒ 眼界/Scope 那类 REST 界面仍然是空的）"
                : "（眼界/Scope 走 HTTP REST，不实现 /social_media/api/* 的话仍然空）"));
    }

    
    internal static string SocialAppSummary()
        => SocialCatalogRepository4229938.Summary();

    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    internal static async Task<int> PushFavorNpcTimeTableAsync(
        TcpSession session, CancellationToken token = default)
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SocialApp;
        if (!settings.Enabled || !settings.SendNpcSchedule)
            return 0;

        var table = BuildNpcTimeTableInfos();
        if (table.Count == 0)
        {
            session.Log.Warn("[SOCIAL][SCHEDULE] 日程表为空（AgentDataSets*Config 没读到？）");
            return 0;
        }

        await session.NotifyAsync(MethodId.SyncFavorNpcTimeTableInfos,
            UxSerializer.Serialize(new GameMethods.SyncFavorNpcTimeTableInfos4229938
            {
                timeTableInfos = table,
            }), token);

        session.Log.Info($"[SOCIAL][SCHEDULE] SyncFavorNpcTimeTableInfos → {table.Count} 个角色"
            + $" × 5 段日程（邀约）");
        return table.Count;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static Dictionary<uint, GameMethods.NpcTimeTableInfo4229938> BuildNpcTimeTableInfos()
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SocialApp;
        var result = new Dictionary<uint, GameMethods.NpcTimeTableInfo4229938>();
        if (!settings.Enabled || !settings.SendNpcSchedule)
            return result;

        var day = DateTimeOffset.UtcNow.ToUnixTimeSeconds() / 86_400;

        foreach (var row in NpcScheduleCatalogRepository4229938.AllTimeTables)
        {
            var s1 = NpcScheduleCatalogRepository4229938.HhmmToDaySecond(row.Slot1);
            var s2 = NpcScheduleCatalogRepository4229938.HhmmToDaySecond(row.Slot2);
            var s3 = NpcScheduleCatalogRepository4229938.HhmmToDaySecond(row.Slot3);
            var s4 = NpcScheduleCatalogRepository4229938.HhmmToDaySecond(row.Slot4);

            
            
            if (s1 <= 0 || s2 <= s1 || s3 <= s2 || s4 <= s3)
                continue;

            result[row.AgentTag] = new GameMethods.NpcTimeTableInfo4229938
            {
                Schedule0 = BuildScheduleSlot(row.AgentTag, 4, s4 - 86_400, s1),
                Schedule1 = BuildScheduleSlot(row.AgentTag, 1, s1, s2),
                Schedule2 = BuildScheduleSlot(row.AgentTag, 2, s2, s3),
                Schedule3 = BuildScheduleSlot(row.AgentTag, 3, s3, s4),
                Schedule4 = BuildScheduleSlot(row.AgentTag, 4, s4, s1 + 86_400),
                
                
                CurrentSpoonAgentId = 0,
                SpoonPosition = new Auto.UXVector3(),
                TempSchedule = null,
                IsTempScheduleOnly = false,
                RefreshDay = day,
            };
        }

        return result;
    }

    
    private static GameMethods.NpcTimeTableScheduleInfo4229938 BuildScheduleSlot(
        uint agentTag, int slot, int startDaySecond, int endDaySecond)
    {
        var activity = NpcScheduleCatalogRepository4229938.ActivityForSlot(agentTag, slot);
        return new GameMethods.NpcTimeTableScheduleInfo4229938
        {
            ActivityId = activity?.Id ?? 0,
            StartDaySecond = startDaySecond,
            EndDaySecond = endDaySecond,
            Position = new Auto.UXVector3(),
            SpoonAgentId = 0,
            RaidId = activity?.Raid ?? 0,
        };
    }
}
