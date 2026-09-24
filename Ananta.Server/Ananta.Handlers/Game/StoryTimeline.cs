using System.Text.Json;
using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;

namespace Ananta.Server.Handlers.Game;

internal static class StoryTimeline
{
    
    internal sealed record Entry(
        uint Id,
        string Name,
        string Group,
        bool BanSkip,
        bool BanPause,
        bool BanSpeed,
        byte PlayerControlType,
        bool ProcessBlackScreen,
        bool NeedPreload,
        bool PauseAI,
        byte LinkType,
        byte Standard,
        byte LoadAction)
    {
        
        
        
        
        internal bool IsCinematic => BanSkip && PlayerControlType == 0 && PauseAI;

        
        internal bool IsSwitchChar => string.Equals(Group, "SwitchChar", StringComparison.OrdinalIgnoreCase);

        
        internal bool IsLoading => string.Equals(Group, "Loading", StringComparison.OrdinalIgnoreCase);

        
        internal bool IsSystem => string.IsNullOrEmpty(Group);
    }

    private static readonly Lazy<IReadOnlyList<Entry>> Cache = new(Load);
    private static readonly Lazy<IReadOnlyDictionary<string, string>> GroupNames = new(LoadGroupNames);

    internal static IReadOnlyList<Entry> All => Cache.Value;

    
    internal static IReadOnlyDictionary<string, string> Groups => GroupNames.Value;

    private static string ConfigPath(string file)
    {
        var path = Path.Combine(AppContext.BaseDirectory, "ClientData", "4229938", "Configs", file);
        if (File.Exists(path)) return path;

        
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        for (var i = 0; i < 6 && dir is not null; i++, dir = dir.Parent)
        {
            var cand = Path.Combine(dir.FullName, "Ananta.Server", "ClientData", "4229938", "Configs", file);
            if (File.Exists(cand)) return cand;
        }
        return path;
    }

    private static IReadOnlyList<Entry> Load()
    {
        try
        {
            var path = ConfigPath("TimelineConfig.json");
            if (!File.Exists(path))
            {
                Console.WriteLine("[TIMELINE] 找不到 TimelineConfig.json —— 播片清单会是空的。");
                return [];
            }

            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            if (!doc.RootElement.TryGetProperty("records", out var arr) || arr.ValueKind != JsonValueKind.Array)
                return [];

            var list = new List<Entry>(arr.GetArrayLength());
            foreach (var r in arr.EnumerateArray())
            {
                list.Add(new Entry(
                    U32(r, "Id"),
                    Str(r, "TimelineName"),
                    Str(r, "Group"),
                    Bool(r, "BanSkip"),
                    Bool(r, "BanPause"),
                    Bool(r, "BanSpeed"),
                    Byte(r, "PlayerControlType"),
                    Bool(r, "ProcessBlackScreen"),
                    U32(r, "NeedPreload") != 0,
                    Bool(r, "PauseAI"),
                    Byte(r, "LinkType"),
                    Byte(r, "Standard"),
                    Byte(r, "LoadAction")));
            }

            var cinematics = list.Count(x => x.IsCinematic);
            var grouped = list.Count(x => !string.IsNullOrEmpty(x.Group));
            Console.WriteLine($"[TIMELINE] 播片清单已载入 {list.Count} 条"
                + $"（电影式播片 {cinematics} 条 · 有分组 {grouped} 条）");
            return list;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[TIMELINE] 载入 TimelineConfig 失败: {ex.GetType().Name}: {ex.Message}");
            return [];
        }
    }

    private static IReadOnlyDictionary<string, string> LoadGroupNames()
    {
        var map = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        try
        {
            var path = ConfigPath("TimelineGroupConfig.json");
            if (!File.Exists(path)) return map;

            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            if (!doc.RootElement.TryGetProperty("records", out var arr) || arr.ValueKind != JsonValueKind.Array)
                return map;

            foreach (var r in arr.EnumerateArray())
            {
                var name = Str(r, "GroupName");
                if (!string.IsNullOrEmpty(name)) map[name] = name;
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[TIMELINE] 载入 TimelineGroupConfig 失败: {ex.Message}");
        }
        return map;
    }

    
    
    
    
    
    
    
    internal static IReadOnlyList<Entry> Search(string? keyword, string? kind, string? group, int limit)
    {
        IEnumerable<Entry> q = All;

        if (!string.IsNullOrWhiteSpace(kind))
        {
            q = kind.Trim().ToLowerInvariant() switch
            {
                "cinematic" => q.Where(x => x.IsCinematic),
                "switch" => q.Where(x => x.IsSwitchChar),
                "loading" => q.Where(x => x.IsLoading),
                "system" => q.Where(x => x.IsSystem),
                "noskip" => q.Where(x => x.BanSkip),
                "preload" => q.Where(x => x.NeedPreload),
                _ => q,
            };
        }

        if (!string.IsNullOrWhiteSpace(group))
            q = q.Where(x => x.Group.Contains(group.Trim(), StringComparison.OrdinalIgnoreCase));

        if (!string.IsNullOrWhiteSpace(keyword))
        {
            var k = keyword.Trim();
            q = q.Where(x =>
                x.Name.Contains(k, StringComparison.OrdinalIgnoreCase)
                || x.Group.Contains(k, StringComparison.OrdinalIgnoreCase)
                || x.Id.ToString().Contains(k, StringComparison.Ordinal));
        }

        return q.Take(Math.Clamp(limit, 1, 2000)).ToList();
    }

    internal static Entry? Find(uint id) => All.FirstOrDefault(x => x.Id == id);
    internal static Entry? FindByName(string name) =>
        All.FirstOrDefault(x => string.Equals(x.Name, name, StringComparison.OrdinalIgnoreCase));

    
    internal static IReadOnlyList<object> GroupSummary()
    {
        
        
        return All
            .GroupBy(x => x.Group)
            .Select(g => (
                Group: string.IsNullOrEmpty(g.Key) ? "(通用/系统)" : g.Key,
                Raw: g.Key,
                Count: g.Count(),
                Cinematics: g.Count(x => x.IsCinematic)))
            .OrderByDescending(x => x.Count)
            .Select(x => (object)new
            {
                group = x.Group,
                raw = x.Raw,
                count = x.Count,
                cinematics = x.Cinematics,
            })
            .ToList();
    }

    

    private static uint U32(JsonElement e, string n) =>
        e.TryGetProperty(n, out var v) && v.TryGetUInt32(out var x) ? x : 0u;

    private static byte Byte(JsonElement e, string n) =>
        e.TryGetProperty(n, out var v) && v.TryGetByte(out var x) ? x : (byte)0;

    private static bool Bool(JsonElement e, string n) =>
        e.TryGetProperty(n, out var v) && v.ValueKind == JsonValueKind.True;

    private static string Str(JsonElement e, string n) =>
        e.TryGetProperty(n, out var v) && v.ValueKind == JsonValueKind.String ? v.GetString() ?? string.Empty : string.Empty;
}

internal static class StoryTimelinePusher
{
    
    
    
    
    
    
    internal static bool ChannelReady => true;

    
    internal const string ChannelNote =
        "走原版『换人传送』协议链：服务端下发 SyncPreSwitchSpirit(68193507) + "
        + "SyncSwitchSpiritConfigId(68713896)，客户端按 configId 查 SwitchSpiritConfig 拿 timeline 名字再播。";

    
    
    
    
    internal enum TimelineState : int
    {
        
        Start = 0,

        
        Playing = 1,

        
        End = 2,
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static async Task<PlayResult> PlayWithSwitchAsync(
        TcpSession session,
        uint switchConfigId,
        uint targetTemplateId,
        Func<uint, byte[], Task> notify,
        int warmupMs = 600)
    {
        var row = StorySwitchConfig.Find(switchConfigId);
        if (row is null)
            return new PlayResult(false, switchConfigId, null, null, $"SwitchSpiritConfig 里没有 Id={switchConfigId}。");
        if (string.IsNullOrWhiteSpace(row.Timeline))
            return new PlayResult(false, switchConfigId, null, null, $"配置 Id={switchConfigId} 的 TimeLine 为空。");

        var position = new Vec3(row.PositionX, row.PositionY, row.PositionZ);

        
        await notify(
            MethodId.SyncPreSwitchSpirit,
            UxSerializer.Serialize(WorldCodec.PreSwitchSpirit(switchConfigId, targetTemplateId, position)));

        session.Log.Info(
            $"[TIMELINE] ① SyncPreSwitchSpirit configId={switchConfigId} "
            + $"newTemplate={targetTemplateId} tl={row.Timeline}");

        
        if (targetTemplateId != 0)
        {
            var character = ClientConfigRepository.Characters()
                .FirstOrDefault(x => x.TemplateId == targetTemplateId);
            if (character is not null)
            {
                var unitId = character.UnitId;
                await notify(MethodId.SyncLogicAgentEnter, UxSerializer.Serialize(WorldCodec.LogicAgentEnter(unitId)));
                await notify(MethodId.SyncManagedLogicAgent,
                    UxSerializer.Serialize(WorldCodec.ManagedLogicAgent(unitId, Profile.PlayerPid, 0)));
                await notify(MethodId.SyncRaidBattleUnitSpirit,
                    UxSerializer.Serialize(RuntimePayloadFactory.CharacterUnitProjection(targetTemplateId, position, row.Facing)));
                await notify(MethodId.SyncUnitPositionAndFacing,
                    UxSerializer.Serialize(WorldCodec.PositionAndFacing(unitId, position, row.Facing)));
                await notify(MethodId.SyncPlayerCurrentSpirit,
                    UxSerializer.Serialize(WorldCodec.CurrentSpirit(Profile.PlayerPid, targetTemplateId, unitId, false)));

                session.Log.Info(
                    $"[TIMELINE] ①b 身份交接 template={targetTemplateId} unit={unitId} "
                    + $"name={character.Name}");
            }
            else
            {
                session.Log.Warn($"[TIMELINE] 模板 {targetTemplateId} 不在可玩角色表里，跳过身份交接（只会播动画）。");
            }
        }

        
        if (warmupMs > 0)
            await Task.Delay(warmupMs);

        
        await notify(
            MethodId.SyncSwitchSpiritConfigId,
            UxSerializer.Serialize(WorldCodec.SwitchSpiritConfigId(switchConfigId, position)));

        session.Log.Info($"[TIMELINE] ② SyncSwitchSpiritConfigId configId={switchConfigId} tl={row.Timeline}");

        return new PlayResult(true, switchConfigId, row.Timeline, row.Description, null);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static async Task<CinematicResult> PlayCinematicAsync(
        TcpSession session,
        StoryTimeline.Entry entry,
        Func<uint, byte[], Task> notify,
        Vec3? position = null,
        IReadOnlyCollection<ulong>? agentIds = null,
        IReadOnlyCollection<string>? slots = null,
        bool preload = true,
        int preloadDelayMs = 350)
    {
        if (string.IsNullOrWhiteSpace(entry.Name))
            return new CinematicResult(false, entry.Id, null, "timeline 名字为空。");

        
        var pos = position ?? (GameRouter.TryGetWorldState(session, out var st) && st.HasLastReportedPlayerTransform
            ? st.LastReportedPlayerPosition
            : Profile.WorldSpawn);

        
        
        
        
        
        
        
        
        
        if (agentIds is null && GameRouter.TryGetWorldState(session, out var world) && world.ActiveSpiritUnitId != 0)
            agentIds = [world.ActiveSpiritUnitId];

        
        var didPreload = preload && entry.NeedPreload;
        if (didPreload)
        {
            await notify(
                MethodId.IGameSceneToClient_SyncPreLoadTL,
                UxSerializer.Serialize(WorldCodec.PreLoadTL(entry.Name)));

            session.Log.Info($"[TIMELINE] ① SyncPreLoadTL name={entry.Name} id={entry.Id}");

            if (preloadDelayMs > 0)
                await Task.Delay(preloadDelayMs);
        }

        
        await notify(
            MethodId.IGameSceneToClient_SyncPlayTL,
            UxSerializer.Serialize(WorldCodec.PlayTL(entry.Name, entry.Id, pos, agentIds, slots)));

        session.Log.Info(
            $"[TIMELINE] ② SyncPlayTL name={entry.Name} id={entry.Id} group={entry.Group} "
            + $"banSkip={entry.BanSkip} needPreload={entry.NeedPreload} "
            + $"agents=[{string.Join(",", agentIds ?? [])}] pos=({pos.X:0.##},{pos.Y:0.##},{pos.Z:0.##})");

        return new CinematicResult(true, entry.Id, entry.Name, null);
    }

    
    internal sealed record CinematicResult(bool Ok, uint TimelineId, string? TimelineName, string? Error);

    
    
    
    
    
    
    internal static async Task<PlayResult> PlayAsync(TcpSession session, uint switchConfigId, int warmupMs = 400)
        => await PlayWithSwitchAsync(session, switchConfigId, 0, async (mid, body) =>
            await session.NotifyAsync(mid, body, CancellationToken.None), warmupMs);

    
    internal sealed record PlayResult(
        bool Ok,
        uint SwitchConfigId,
        string? Timeline,
        string? Description,
        string? Error);
}

internal static class StorySwitchConfig
{
    
    internal sealed record Entry(
        uint Id,
        string Timeline,
        string Description,
        string TimelineDescription,
        int SwitchType,
        uint RaidId,
        float Weight,
        bool Invalid,
        float PositionX,
        float PositionY,
        float PositionZ,
        float Facing,
        float TransitionX,
        float TransitionY,
        float TransitionZ,
        bool UseZeroPosAndAngle,
        bool CanPlayAfterTL,
        IReadOnlyList<uint> FightSpiritIds,
        IReadOnlyList<uint> AgentIds)
    {
        
        internal bool Playable => !Invalid && !string.IsNullOrWhiteSpace(Timeline);

        
        internal uint FirstFightSpiritId => FightSpiritIds.Count > 0 ? FightSpiritIds[0] : 0;

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        internal bool NeedsCompanionAgents => AgentIds.Count > 0;

        
        
        
        
        
        
        
        
        
        
        
        internal Vec3 Anchor => new(PositionX, PositionY, PositionZ);

        
        internal Vec3 TransitionAnchor => new(TransitionX, TransitionY, TransitionZ);
    }

    private static readonly Lazy<IReadOnlyList<Entry>> Cache = new(Load);

    internal static IReadOnlyList<Entry> All => Cache.Value;

    
    internal static IReadOnlyList<Entry> Playable => All.Where(x => x.Playable).ToList();

    internal static Entry? Find(uint id) => All.FirstOrDefault(x => x.Id == id);

    internal static Entry? FindByTimeline(string timeline) =>
        Playable.FirstOrDefault(x => string.Equals(x.Timeline, timeline, StringComparison.OrdinalIgnoreCase));

    
    internal static IReadOnlyList<Entry> Search(string? keyword, bool playableOnly, int limit)
    {
        IEnumerable<Entry> q = All;
        if (playableOnly) q = q.Where(x => x.Playable);

        if (!string.IsNullOrWhiteSpace(keyword))
        {
            var k = keyword.Trim();
            q = q.Where(x =>
                x.Timeline.Contains(k, StringComparison.OrdinalIgnoreCase)
                || x.Description.Contains(k, StringComparison.Ordinal)
                || x.TimelineDescription.Contains(k, StringComparison.Ordinal)
                || x.Id.ToString().Contains(k, StringComparison.Ordinal));
        }

        return q.Take(Math.Clamp(limit, 1, 2000)).ToList();
    }

    private static string ConfigPath(string file)
    {
        var path = Path.Combine(AppContext.BaseDirectory, "ClientData", "4229938", "Configs", file);
        if (File.Exists(path)) return path;

        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        for (var i = 0; i < 6 && dir is not null; i++, dir = dir.Parent)
        {
            var cand = Path.Combine(dir.FullName, "Ananta.Server", "ClientData", "4229938", "Configs", file);
            if (File.Exists(cand)) return cand;
        }
        return path;
    }

    private static IReadOnlyList<Entry> Load()
    {
        try
        {
            var path = ConfigPath("SwitchSpiritConfig.json");
            if (!File.Exists(path))
            {
                Console.WriteLine("[TIMELINE] 找不到 SwitchSpiritConfig.json —— 播片清单会是空的。");
                return [];
            }

            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            if (!doc.RootElement.TryGetProperty("records", out var arr) || arr.ValueKind != JsonValueKind.Array)
                return [];

            var list = new List<Entry>(arr.GetArrayLength());
            foreach (var r in arr.EnumerateArray())
            {
                if (!r.TryGetProperty("Id", out var idProp) || !idProp.TryGetUInt32(out var id)) continue;

                var pos = ReadVec3(r, "Position");
                var trans = ReadVec3(r, "TransitionPosition");
                
                if (trans is (0f, 0f, 0f) && pos is not (0f, 0f, 0f)) trans = pos;
                list.Add(new Entry(
                    id,
                    Str(r, "TimeLine"),
                    Str(r, "Description"),
                    Str(r, "TimeLineDescription"),
                    Int(r, "SwitchType"),
                    U32(r, "RaidId"),
                    Float(r, "Weight"),
                    Bool(r, "Invalid"),
                    pos.X, pos.Y, pos.Z,
                    Float(r, "TimeLineAngleY"),
                    trans.X, trans.Y, trans.Z,
                    Bool(r, "UseZeroPosAndAngle"),
                    Bool(r, "CanPlayAfterTL"),
                    ReadUInt32List(r, "FightSpiritId"),
                    ReadUInt32List(r, "AgentId")));
            }

            var playable = list.Count(x => x.Playable);
            var timelines = list.Where(x => x.Playable).Select(x => x.Timeline).Distinct(StringComparer.Ordinal).Count();
            Console.WriteLine($"[TIMELINE] 换人演出清单已载入 {list.Count} 条"
                + $"（可播 {playable} 条 · 覆盖 {timelines} 个 timeline）");
            return list;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[TIMELINE] 载入 SwitchSpiritConfig 失败: {ex.GetType().Name}: {ex.Message}");
            return [];
        }
    }

    private static (float X, float Y, float Z) ReadVec3(JsonElement e, string n)
    {
        if (!e.TryGetProperty(n, out var arr) || arr.ValueKind != JsonValueKind.Array) return (0f, 0f, 0f);
        var v = arr.EnumerateArray().Take(3).Select(x => x.TryGetSingle(out var f) ? f : 0f).ToArray();
        return v.Length == 3 ? (v[0], v[1], v[2]) : (0f, 0f, 0f);
    }

    private static IReadOnlyList<uint> ReadUInt32List(JsonElement e, string n)
    {
        if (!e.TryGetProperty(n, out var arr) || arr.ValueKind != JsonValueKind.Array) return [];
        return arr.EnumerateArray().Where(x => x.TryGetUInt32(out _)).Select(x => x.GetUInt32()).ToList();
    }

    private static uint U32(JsonElement e, string n) =>
        e.TryGetProperty(n, out var v) && v.TryGetUInt32(out var x) ? x : 0u;

    private static int Int(JsonElement e, string n) =>
        e.TryGetProperty(n, out var v) && v.TryGetInt32(out var x) ? x : 0;

    private static float Float(JsonElement e, string n) =>
        e.TryGetProperty(n, out var v) && v.TryGetSingle(out var x) ? x : 0f;

    private static bool Bool(JsonElement e, string n) =>
        e.TryGetProperty(n, out var v) && v.ValueKind == JsonValueKind.True;

    private static string Str(JsonElement e, string n) =>
        e.TryGetProperty(n, out var v) && v.ValueKind == JsonValueKind.String ? v.GetString() ?? string.Empty : string.Empty;
}
