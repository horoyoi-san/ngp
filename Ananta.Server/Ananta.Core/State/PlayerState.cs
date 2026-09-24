using System.Text.Json;
using System.Text.Json.Serialization;

namespace Ananta.Server.State;

public sealed class PlayerState
{
    public string AccountId { get; set; } = "default";
    public string DisplayName { get; set; } = "AnantaPS";
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.Now;
    public DateTimeOffset UpdatedAt { get; set; } = DateTimeOffset.Now;

    
    public uint ActiveSpiritTemplateId { get; set; }
    public double PositionX { get; set; }
    public double PositionY { get; set; }
    public double PositionZ { get; set; }
    public double Facing { get; set; }

    
    public double Money { get; set; }
    public double Gold { get; set; }
    public double BindingGold { get; set; }

    
    public Dictionary<uint, uint> Backpack { get; set; } = new();

    
    public List<WeaponRecord> Weapons { get; set; } = [];

    
    public List<uint> OwnedFashions { get; set; } = [];

    
    public Dictionary<uint, List<uint>> WornFashions { get; set; } = new();

    
    public List<uint> InstalledApps { get; set; } = [];
    public uint[] MobileSkinParts { get; set; } = [];

    
    
    
    
    

    
    public Dictionary<uint, List<uint>> SpiritJobs { get; set; } = new();

    
    public Dictionary<uint, uint> CurrentSpiritJob { get; set; } = new();

    
    public Dictionary<uint, Dictionary<uint, uint>> SpiritJobTalents { get; set; } = new();

    
    public Dictionary<uint, uint> SpiritJobTalentPoints { get; set; } = new();

    
    public Dictionary<uint, Dictionary<uint, uint>> SpiritTalents { get; set; } = new();

    
    public uint CommonSpiritTalentExp { get; set; }

    

    
    
    
    
    
    
    public string HackerName { get; set; } = string.Empty;

    
    public List<uint> HackerReadPosts { get; set; } = [];

    
    public Dictionary<uint, int> HackerPostStates { get; set; } = new();

    
    public bool PoliceFakeFilesUnlocked { get; set; }

    

    
    
    
    
    
    
    public List<uint> SocialReadPosts { get; set; } = [];

    
    public List<uint> SocialLikedPosts { get; set; } = [];

    
    
    
    
    
    public Dictionary<uint, List<uint>> SocialPlayerComments { get; set; } = new();

    

    
    public bool PoliceTaskAccepted { get; set; }

    
    public List<uint> PoliceFakeFileAccepted { get; set; } = [];

    
    public List<uint> PoliceFakeFileRewarded { get; set; } = [];

    
    public int TruckOrdersRefreshed { get; set; }

    
    public int TruckOrdersSettled { get; set; }

    
    public bool TruckAutoAccept { get; set; }

    
    public uint TruckDefaultVehicleId { get; set; }

    
    public bool TruckGuideClicked { get; set; }

    
    public uint TruckOrderSeed { get; set; }

    
    public uint TruckCurrentOrderId { get; set; }

    
    public List<uint> TruckAcceptedOrders { get; set; } = [];

    
    
    
    
    
    
    
    public Dictionary<uint, Dictionary<uint, uint>> SpiritJobRegisterTime { get; set; } = new();

    
    public List<TaskRecord> Tasks { get; set; } = [];
    public uint CurrentTaskId { get; set; }

    
    public List<uint> UnlockedMapEntrances { get; set; } = [];

    
    public bool MapFullyRevealed { get; set; }

    public bool NewPlayerFlowDone { get; set; }

    
    
    
    
    public List<StreetNpcRecord> StreetNpcs { get; set; } = [];
}

public sealed class StreetNpcRecord
{
    public ulong Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public uint TemplateId { get; set; }
    public float X { get; set; }
    public float Y { get; set; }
    public float Z { get; set; }
    public float Facing { get; set; }
    
    public List<uint> FashionIds { get; set; } = [];
}

public sealed class WeaponRecord
{
    public ulong InstanceId { get; set; }
    public uint TemplateId { get; set; }
    public uint SpiritId { get; set; }
}

public sealed class TaskRecord
{
    public uint TaskId { get; set; }
    public byte State { get; set; }
    public List<int> CounterValues { get; set; } = [];
}

public static class AccountStore
{
    public sealed class AccountEntry
    {
        public string Id { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Uid { get; set; } = string.Empty;
        public ulong Pid { get; set; }
        public string Username { get; set; } = string.Empty;
        public bool Active { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
    }

    private static string _root = string.Empty;

    public static string Root => _root;

    public static void Initialize(string root)
    {
        _root = root;
        Directory.CreateDirectory(root);
        AccountDatabase.Initialize(root);
        SeedFromConfig();
        MirrorForProxy();
    }

    
    private static void SeedFromConfig()
    {
        if (AccountDatabase.List().Count > 0)
            return;

        var cfg = Ananta.Server.Configuration.PrivateServerConfigStore.Current.Player;
        try
        {
            var account = AccountDatabase.Create(
                id: "default",
                username: cfg.UserName,
                password: cfg.LoginToken,
                nickname: cfg.DisplayName,
                uid: cfg.AccountId,
                pid: cfg.Pid);
            AccountDatabase.SetActive(account.Id);
            Console.WriteLine($"[DB] 已从配置初始化账号 uid={account.Uid} pid={account.Pid} 用户={account.Username}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DB] 初始化账号失败: {ex.Message}");
        }
    }

    
    private static void MirrorForProxy()
    {
        try
        {
            var accounts = AccountDatabase.List();
            var active = accounts.FirstOrDefault(a => a.IsActive) ?? accounts.FirstOrDefault();
            var payload = new Dictionary<string, object?>
            {
                ["activeAccountId"] = active?.Id ?? "default",
                ["accounts"] = accounts.Select(a => new Dictionary<string, object?>
                {
                    ["id"] = a.Id, ["uid"] = a.Uid, ["pid"] = a.Pid,
                    ["username"] = a.Username, ["name"] = a.Nickname,
                    ["active"] = a.IsActive,
                }).ToList(),
            };
            File.WriteAllText(
                System.IO.Path.Combine(_root, "accounts.json"),
                System.Text.Json.JsonSerializer.Serialize(payload, new System.Text.Json.JsonSerializerOptions { WriteIndented = true }));
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[DB] 镜像 accounts.json 失败: {ex.Message}");
        }
    }

    public static IReadOnlyList<AccountEntry> Accounts
        => AccountDatabase.List().Select(a => new AccountEntry
        {
            Id = a.Id, Name = a.Nickname, Uid = a.Uid, Pid = a.Pid,
            Username = a.Username, Active = a.IsActive, CreatedAt = a.CreatedAt,
        }).ToArray();

    public static string ActiveAccountId
    {
        get => AccountDatabase.Active()?.Id ?? "default";
        set { AccountDatabase.SetActive(value); MirrorForProxy(); }
    }

    public static PlayerState Load(string accountId) => AccountDatabase.LoadState(accountId);

    public static PlayerState LoadActive() => AccountDatabase.LoadState(ActiveAccountId);

    public static void Save(PlayerState state) => AccountDatabase.SaveState(state);

    public static PlayerState CreateAccount(string id, string name)
        => CreateAccount(id, name, null, null, null, 0);

    public static PlayerState CreateAccount(string id, string name, string? username, string? password, string? uid, ulong pid)
    {
        var account = AccountDatabase.Create(id, username ?? string.Empty, password ?? string.Empty, name, uid, pid);
        MirrorForProxy();
        var state = AccountDatabase.LoadState(account.Id);
        state.DisplayName = account.Nickname;
        AccountDatabase.SaveState(state);
        return state;
    }

    public static bool DeleteAccount(string id)
    {
        var ok = AccountDatabase.Delete(id);
        MirrorForProxy();
        return ok;
    }
}
