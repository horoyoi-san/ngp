using System.Text.Json;
using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.SDK.Serialization;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;

namespace Ananta.Server.Handlers.Game;

internal static class StoryDialogue
{
    
    internal sealed record Entry(uint Id, string Message, string Speaker, uint CameraId, int Type)
    {
        
        internal bool IsCutscene => CameraId != 0;
    }

    private static readonly Lazy<IReadOnlyList<Entry>> Cache = new(Load);

    internal static IReadOnlyList<Entry> All => Cache.Value;

    private static IReadOnlyList<Entry> Load()
    {
        try
        {
            var path = Path.Combine(AppContext.BaseDirectory, "ClientData", "4229938", "Configs", "DialogIndex.json");
            if (!File.Exists(path))
            {
                
                var dir = new DirectoryInfo(AppContext.BaseDirectory);
                for (var i = 0; i < 6 && dir is not null && !File.Exists(path); i++, dir = dir.Parent)
                    path = Path.Combine(dir.FullName, "Ananta.Server", "ClientData", "4229938", "Configs", "DialogIndex.json");
            }

            if (!File.Exists(path))
            {
                Console.WriteLine("[STORY] 找不到 DialogIndex.json —— 过场/台词列表会是空的。"
                    + "（用 tools 里的脚本从 DialogConfig.json 生成）");
                return [];
            }

            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            if (!doc.RootElement.TryGetProperty("dialogs", out var arr) || arr.ValueKind != JsonValueKind.Array)
                return [];

            var list = new List<Entry>(arr.GetArrayLength());
            foreach (var item in arr.EnumerateArray())
            {
                list.Add(new Entry(
                    item.TryGetProperty("id", out var pi) ? pi.GetUInt32() : 0u,
                    item.TryGetProperty("msg", out var pm) ? pm.GetString() ?? string.Empty : string.Empty,
                    item.TryGetProperty("spk", out var ps) ? ps.GetString() ?? string.Empty : string.Empty,
                    item.TryGetProperty("cam", out var pc) ? pc.GetUInt32() : 0u,
                    item.TryGetProperty("type", out var pt) && pt.TryGetInt32(out var tv) ? tv : 0));
            }

            Console.WriteLine($"[STORY] 台词索引已载入 {list.Count} 条（其中带镜头过场 {list.Count(x => x.IsCutscene)} 条）");
            return list;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[STORY] 载入台词索引失败: {ex.GetType().Name}: {ex.Message}");
            return [];
        }
    }

    
    internal static IReadOnlyList<Entry> Search(string? keyword, bool? cutsceneOnly, int limit)
    {
        IEnumerable<Entry> q = All;

        if (cutsceneOnly is { } wantCut)
            q = q.Where(x => x.IsCutscene == wantCut);

        if (!string.IsNullOrWhiteSpace(keyword))
        {
            var k = keyword.Trim();
            q = q.Where(x =>
                x.Message.Contains(k, StringComparison.OrdinalIgnoreCase)
                || x.Speaker.Contains(k, StringComparison.OrdinalIgnoreCase)
                || x.Id.ToString().Contains(k, StringComparison.Ordinal));
        }

        return q.Take(Math.Clamp(limit, 1, 3000)).ToList();
    }

    internal static Entry? Find(uint id) => All.FirstOrDefault(x => x.Id == id);
}

[UxContract]
internal sealed class DialogParam4229938
{
    public byte Reason;
    public uint NpcTemplateId;
    public ulong NpcInstanceId;

    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public Auto.UXVector3 AgentPosition = new();

    public bool BlackContinue;
    public uint FromTaskId;
    public uint FromEventId;
    public bool FromClient;
    public uint DialogCameraSpawnId;
    public int SpoonNodeId;

    
    
    
    
    
    
    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<string, ulong> Speaker2NpcInstanceId = new();

    public uint DialogPriority;
    public bool StopWhenTaskEnd;
}

[UxContract(Inline = true)]
internal sealed class SyncShowDialog4229938
{
    public uint dialogId;
    public uint beginDialog;

    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public DialogParam4229938 param = new();
}

[UxContract(Inline = true)]
internal sealed class SyncShowDialogVoice4229938
{
    public ulong pid;
    public uint dialogId;
}

internal static class StoryDialoguePusher
{
    
    internal static async Task PushDialogAsync(TcpSession session, uint dialogId)
    {
        await session.NotifyAsync(MethodId.SyncShowDialog, UxSerializer.Serialize(new SyncShowDialog4229938
        {
            dialogId = dialogId,

            
            
            
            
            
            
            
            
            beginDialog = dialogId,
            param = new DialogParam4229938
            {
                Reason = 0,
                NpcTemplateId = 0,
                NpcInstanceId = 0,
                AgentPosition = new Auto.UXVector3(),
                BlackContinue = false,
                FromTaskId = 0,
                FromEventId = 0,
                
                FromClient = false,
                DialogCameraSpawnId = 0,
                SpoonNodeId = 0,
            },
        }), CancellationToken.None);

        session.Log.Info($"[STORY] 已下发 SyncShowDialog dialogId={dialogId}");
    }

    
    internal static async Task PushDialogVoiceAsync(TcpSession session, uint dialogId)
    {
        await session.NotifyAsync(MethodId.SyncShowDialogVoice, UxSerializer.Serialize(new SyncShowDialogVoice4229938
        {
            pid = Profile.PlayerPid,
            dialogId = dialogId,
        }), CancellationToken.None);

        session.Log.Info($"[STORY] 已下发 SyncShowDialogVoice dialogId={dialogId}");
    }
}
