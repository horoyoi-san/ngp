using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal static class SocialCatalogRepository4229938
{
    
    internal sealed record PostRow(
        uint Id,
        uint Publisher,
        string Txt,
        uint Likes,
        uint LikeDrop,
        bool IfShowTips,
        bool IfStory,
        bool IfPinStory,
        bool WithMe,
        IReadOnlyList<uint> CommentIds);

    
    internal sealed record PublisherRow(
        uint Id,
        string Name,
        uint Simage,
        uint NpcCultivation,
        IReadOnlyList<uint> SamePublishers);

    
    internal sealed record CommentRow(uint Id, uint Publisher, uint NextId, string Txt);

    private static readonly object Sync = new();
    private static List<PostRow>? _posts;
    private static Dictionary<uint, PublisherRow>? _publishers;
    private static Dictionary<uint, CommentRow>? _comments;

    private static string Root => PrivateServerConfigStore.ResolveProjectPath(
        PrivateServerConfigStore.Current.Paths.ClientConfigs);

    
    internal static IReadOnlyList<PostRow> AllPosts
    {
        get { EnsureLoaded(); lock (Sync) return _posts!; }
    }

    
    internal static PostRow? Post(uint id)
    {
        EnsureLoaded();
        lock (Sync)
            return _posts!.FirstOrDefault(x => x.Id == id);
    }

    
    internal static PublisherRow? Publisher(uint id)
    {
        EnsureLoaded();
        lock (Sync)
            return _publishers!.TryGetValue(id, out var v) ? v : null;
    }

    
    internal static CommentRow? Comment(uint id)
    {
        EnsureLoaded();
        lock (Sync)
            return _comments!.TryGetValue(id, out var v) ? v : null;
    }

    internal static string Summary()
    {
        EnsureLoaded();
        lock (Sync)
            return $"SocialMediaConfig={_posts!.Count} 条动态"
                + $" / SocialMediaNPCConfig={_publishers!.Count} 个发布者"
                + $" / SocialMediaCommentConfig={_comments!.Count} 条评论"
                + $"（WithMe={_posts.Count(x => x.WithMe)}）";
    }

    private static void EnsureLoaded()
    {
        if (_posts is not null)
            return;

        lock (Sync)
        {
            if (_posts is not null)
                return;

            var posts = new List<PostRow>();
            var publishers = new Dictionary<uint, PublisherRow>();
            var comments = new Dictionary<uint, CommentRow>();
            var root = Root;

            ForEachRecord(root, "SocialMediaConfig.json", row =>
            {
                var id = U32(row, "Id");
                if (id == 0)
                    return;
                posts.Add(new PostRow(
                    id,
                    U32(row, "Publisher"),
                    Str(row, "Txt") ?? string.Empty,
                    U32(row, "Likes"),
                    U32(row, "LikeDrop"),
                    Bool(row, "IfShowTips"),
                    Bool(row, "IfStory"),
                    Bool(row, "IfPinStory"),
                    Bool(row, "WithMe"),
                    U32List(row, "Comment")));
            });

            ForEachRecord(root, "SocialMediaNPCConfig.json", row =>
            {
                var id = U32(row, "Id");
                if (id == 0)
                    return;
                publishers[id] = new PublisherRow(
                    id,
                    Str(row, "Name") ?? string.Empty,
                    U32(row, "Simage"),
                    U32(row, "NpcCultivation"),
                    U32List(row, "SamePublishers"));
            });

            ForEachRecord(root, "SocialMediaCommentConfig.json", row =>
            {
                var id = U32(row, "Id");
                if (id == 0)
                    return;
                comments[id] = new CommentRow(
                    id,
                    U32(row, "Publisher"),
                    U32(row, "NextId"),
                    Str(row, "Txt") ?? string.Empty);
            });

            _posts = [.. posts.OrderBy(x => x.Id)];
            _publishers = publishers;
            _comments = comments;

            Console.WriteLine($"[SOCIAL] {Summary()}");
        }
    }

    
    
    
    

    private static void ForEachRecord(string root, string fileName, Action<JsonElement> visit)
    {
        var path = Path.Combine(root, fileName);
        if (!File.Exists(path))
        {
            Console.WriteLine($"[SOCIAL] 缺少配置 {fileName}（叭叭 App 内容会不完整）");
            return;
        }

        try
        {
            using var document = JsonDocument.Parse(File.ReadAllText(path));
            if (!document.RootElement.TryGetProperty("records", out var records)
                || records.ValueKind != JsonValueKind.Array)
            {
                Console.WriteLine($"[SOCIAL] {fileName} 没有 records 数组");
                return;
            }

            foreach (var row in records.EnumerateArray())
            {
                if (row.ValueKind == JsonValueKind.Object)
                    visit(row);
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[SOCIAL] 读取 {fileName} 失败: {ex.Message}");
        }
    }

    private static uint U32(JsonElement row, string name)
        => row.TryGetProperty(name, out var v) && v.ValueKind == JsonValueKind.Number
            ? v.GetUInt32()
            : 0u;

    private static string? Str(JsonElement row, string name)
        => row.TryGetProperty(name, out var v) && v.ValueKind == JsonValueKind.String
            ? v.GetString()
            : null;

    private static bool Bool(JsonElement row, string name)
        => row.TryGetProperty(name, out var v) && v.ValueKind == JsonValueKind.True;

    private static IReadOnlyList<uint> U32List(JsonElement row, string name)
    {
        if (!row.TryGetProperty(name, out var v) || v.ValueKind != JsonValueKind.Array)
            return [];
        var list = new List<uint>();
        foreach (var item in v.EnumerateArray())
        {
            if (item.ValueKind == JsonValueKind.Number)
                list.Add(item.GetUInt32());
        }
        return list;
    }
}
