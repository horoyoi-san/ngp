using System.Text.Json;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;

namespace Ananta.Server.Configuration;

public sealed class PrivateServerConfig
{
    public ClientSettings Client { get; init; } = new();
    public NetworkSettings Network { get; init; } = new();
    public PlayerSettings Player { get; init; } = new();
    public WorldSettings World { get; init; } = new();
    public ContentSettings Content { get; init; } = new();
    public GameplaySettings Gameplay { get; init; } = new();
    public UiSettings Ui { get; init; } = new();
    public LoggingSettings Logging { get; init; } = new();
    public PathSettings Paths { get; init; } = new();
    public DebugSettings Debug { get; init; } = new();

    internal void Validate()
    {
        static void Port(int value, string name)
        {
            if (value is < 1 or > 65535) throw new InvalidDataException($"{name} must be 1..65535, got {value}.");
        }

        if (Client.Version != ClientBuild.Version)
            throw new InvalidDataException($"client.version={Client.Version} is not supported by this source tree; expected {ClientBuild.Version}.");
        if (Client.ServerId <= 0) throw new InvalidDataException("client.serverId must be positive.");
        if (string.IsNullOrWhiteSpace(Client.RpcMd5)) throw new InvalidDataException("client.rpcMd5 must not be empty.");
        if (string.IsNullOrWhiteSpace(Network.BindHost) || string.IsNullOrWhiteSpace(Network.AdvertisedHost))
            throw new InvalidDataException("network.bindHost and network.advertisedHost must not be empty.");
        if (Player.Pid == 0) throw new InvalidDataException("player.pid must not be zero.");
        if (Player.InitialUnitId == 0) throw new InvalidDataException("player.initialUnitId must not be zero.");
        if (Player.InitialSpiritTemplateId == 0) throw new InvalidDataException("player.initialSpiritTemplateId must not be zero.");
        if (string.IsNullOrWhiteSpace(Player.AccountId) || string.IsNullOrWhiteSpace(Player.UserName) || string.IsNullOrWhiteSpace(Player.DisplayName))
            throw new InvalidDataException("player.accountId, player.userName and player.displayName must not be empty.");
        if (string.IsNullOrWhiteSpace(Player.LoginToken) || string.IsNullOrWhiteSpace(Player.GameToken) ||
            string.IsNullOrWhiteSpace(Player.ShareToken) || string.IsNullOrWhiteSpace(Player.FpPassToken) || string.IsNullOrWhiteSpace(Player.Skey))
            throw new InvalidDataException("player compatibility tokens must not be empty.");
        if (World.RaidId == 0 || World.SceneInstanceId == 0 || World.UniverseId == 0)
            throw new InvalidDataException("world.raidId, sceneInstanceId and universeId must not be zero.");
        if (World.Content.Enabled && string.IsNullOrWhiteSpace(Paths.WorldData))
            throw new InvalidDataException("paths.worldData must not be empty while world.content.enabled.");
        if (World.Content.Enabled && string.IsNullOrWhiteSpace(World.Content.Scene))
            throw new InvalidDataException("world.content.scene must not be empty.");
        ValidateStreamWindow(World.Content.SceneItems, "world.content.sceneItems");
        ValidateStreamWindow(World.Content.Gadgets, "world.content.gadgets");
        if (World.Content.DynamicGo.SeedAttempts is < 1 or > 60)
            throw new InvalidDataException($"world.content.dynamicGo.seedAttempts must be 1..60, got {World.Content.DynamicGo.SeedAttempts}.");

        static void ValidateStreamWindow<T>(T settings, string name) where T : class
        {
            var radius = (int)(typeof(T).GetProperty("RadiusCells")?.GetValue(settings) ?? 0);
            var unload = (int)(typeof(T).GetProperty("UnloadRadiusCells")?.GetValue(settings) ?? 0);
            var budget = (int)(typeof(T).GetProperty("LoadBudgetCells")?.GetValue(settings) ?? 0);
            if (radius is < 1 or > 8)
                throw new InvalidDataException($"{name}.radiusCells must be 1..8, got {radius}.");
            if (unload < radius || unload > radius + 8)
                throw new InvalidDataException($"{name}.unloadRadiusCells must be within radiusCells..radiusCells+8, got {unload}.");
            if (budget is < 1 or > 200)
                throw new InvalidDataException($"{name}.loadBudgetCells must be 1..200, got {budget}.");
        }
        if (Network.LoginPorts is null || Network.LoginPorts.Length != 2)
            throw new InvalidDataException("network.loginPorts must contain exactly two ports.");
        Port(Network.LoginPorts[0], "network.loginPorts[0]");
        Port(Network.LoginPorts[1], "network.loginPorts[1]");
        Port(Network.GamePort, "network.gamePort");
        Port(Network.Proxy.HttpsPort, "network.proxy.httpsPort");
        Port(Network.Proxy.HttpPort, "network.proxy.httpPort");
        Port(Network.Proxy.LoginListPort, "network.proxy.loginListPort");
        Port(Network.Proxy.LoginTcpPort, "network.proxy.loginTcpPort");
        Port(Network.Proxy.GameTcpPort, "network.proxy.gameTcpPort");
        Port(Network.Proxy.SceneSubPort, "network.proxy.sceneSubPort");
        if (string.IsNullOrWhiteSpace(Network.Proxy.UpdateHost) || string.IsNullOrWhiteSpace(Network.Proxy.CertificatePassphrase))
            throw new InvalidDataException("network.proxy.updateHost and certificatePassphrase must not be empty.");
        if (Content.Roster.UnitIdBase == 0) throw new InvalidDataException("content.roster.unitIdBase must not be zero.");
        if (Content.Roster.TemplateIdMin >= Content.Roster.TemplateIdMaxExclusive)
            throw new InvalidDataException("content.roster.templateIdMin must be less than templateIdMaxExclusive.");
        if (Gameplay.Combat.MaxHp <= 0) throw new InvalidDataException("gameplay.combat.maxHp must be positive.");
        if (Gameplay.Combat.Skills.All().Any(x => x == 0)) throw new InvalidDataException("gameplay.combat.skills contains id 0.");
        if (Gameplay.Combat.Charges.Length == 0) throw new InvalidDataException("gameplay.combat.charges must not be empty.");
        foreach (var charge in Gameplay.Combat.Charges)
        {
            _ = Gameplay.Combat.Skills.ByName(charge.Skill);
            if (charge.Max == 0 || charge.Current > charge.Max || charge.Period < 0)
                throw new InvalidDataException($"Invalid gameplay.combat.charges entry for '{charge.Skill}'.");
        }
        if (Gameplay.WebTraversal.SharedBuffIds.Length == 0)
            throw new InvalidDataException("gameplay.webTraversal.sharedBuffIds must not be empty.");
        if (!Gameplay.WebTraversal.SharedBuffIds.Contains(Gameplay.WebTraversal.PersistentGrappleBuffId))
            throw new InvalidDataException("persistentGrappleBuffId must also be present in sharedBuffIds.");
        if (Gameplay.WebTraversal.GrappleRearmDelayMs < 0)
            throw new InvalidDataException("gameplay.webTraversal.grappleRearmDelayMs must be >= 0.");
        if (Gameplay.Vehicles.Enabled)
        {
            if (Gameplay.Vehicles.FleetIds.Length == 0) throw new InvalidDataException("gameplay.vehicles.fleetIds must not be empty when vehicles are enabled.");
            if (Gameplay.Vehicles.MinimumApproachMeters <= 0 || Gameplay.Vehicles.DesiredApproachMeters < Gameplay.Vehicles.MinimumApproachMeters)
                throw new InvalidDataException("gameplay.vehicles approach distances are invalid.");
            if (Gameplay.Vehicles.SearchRadiusMeters < Gameplay.Vehicles.DesiredApproachMeters)
                throw new InvalidDataException("gameplay.vehicles.searchRadiusMeters must cover desiredApproachMeters.");
            if (string.IsNullOrWhiteSpace(Paths.ZoneGraphLanes)) throw new InvalidDataException("paths.zoneGraphLanes must not be empty while vehicles are enabled.");
            if (string.IsNullOrWhiteSpace(Paths.PedSpawns)) throw new InvalidDataException("paths.pedSpawns must not be empty while vehicles are enabled.");
        }
        if (Gameplay.Aether.FixedNpcEnabled)
        {
            if (string.IsNullOrWhiteSpace(Paths.StaticNpcSpawns))
                throw new InvalidDataException("paths.staticNpcSpawns must not be empty while gameplay.aether.fixedNpcEnabled=true.");
            if (Gameplay.Aether.FixedNpcCount < 0)
                throw new InvalidDataException("gameplay.aether.fixedNpcCount must be >= 0.");
            if (Gameplay.Aether.FixedNpcRadiusMeters <= 0)
                throw new InvalidDataException("gameplay.aether.fixedNpcRadiusMeters must be > 0.");

            
            
            var fixedLeash = Gameplay.Aether.FixedNpcLeashMeters > 0f
                ? Gameplay.Aether.FixedNpcLeashMeters
                : Math.Max(300f, Gameplay.Aether.FixedNpcRadiusMeters * 1.4f);
            if (fixedLeash <= Gameplay.Aether.FixedNpcRadiusMeters)
                throw new InvalidDataException(
                    $"gameplay.aether.fixedNpcLeashMeters ({Gameplay.Aether.FixedNpcLeashMeters}) 必须大于 "
                    + $"fixedNpcRadiusMeters ({Gameplay.Aether.FixedNpcRadiusMeters})，否则刚生成就会被回收。0 = 自动。");

            if (Gameplay.Aether.FixedNpcWander)
            {
                if (Gameplay.Aether.FixedNpcWanderMaxDis < Gameplay.Aether.FixedNpcWanderMinDis)
                    throw new InvalidDataException(
                        "gameplay.aether.fixedNpcWanderMaxDis 必须 >= fixedNpcWanderMinDis。");
                
                if (Gameplay.Aether.FixedNpcReWanderSeconds > 0f
                    && Gameplay.Aether.FixedNpcReWanderSeconds >= Gameplay.Aether.FixedNpcWanderOnceTime)
                    throw new InvalidDataException(
                        $"gameplay.aether.fixedNpcReWanderSeconds ({Gameplay.Aether.FixedNpcReWanderSeconds}) "
                        + $"必须小于 fixedNpcWanderOnceTime ({Gameplay.Aether.FixedNpcWanderOnceTime})，"
                        + "否则单段走完了才重发、中间会站着不动。0 = 关。");
            }
        }

        
        if (Gameplay.Aether.CrowdReWanderSeconds > 0f
            && Gameplay.Aether.CrowdReWanderSeconds >= Gameplay.Aether.CrowdWanderMaxTime)
            throw new InvalidDataException(
                $"gameplay.aether.crowdReWanderSeconds ({Gameplay.Aether.CrowdReWanderSeconds}) "
                + $"必须小于 crowdWanderMaxTime ({Gameplay.Aether.CrowdWanderMaxTime})。0 = 关。");
        if (Ui.UidLabel.Enabled && string.IsNullOrWhiteSpace(Ui.UidLabel.Text))
            throw new InvalidDataException("ui.uidLabel.text must not be empty when ui.uidLabel.enabled=true.");
        if (Ui.CutscenePanel.Enabled)
        {
            if (string.IsNullOrWhiteSpace(Ui.CutscenePanel.Host))
                throw new InvalidDataException("ui.cutscenePanel.host must not be empty when enabled.");
            Port(Ui.CutscenePanel.Port, "ui.cutscenePanel.port");
        }
        if (string.IsNullOrWhiteSpace(Logging.Directory))
            throw new InvalidDataException("logging.directory must not be empty.");
        if (Logging.Packets.MaxBodyBytes < 0)
            throw new InvalidDataException("logging.packets.maxBodyBytes must be >= 0 (0 means unlimited).");
        if (string.IsNullOrWhiteSpace(Paths.ClientConfigs))
            throw new InvalidDataException("paths.clientConfigs must not be empty.");
        if (string.IsNullOrWhiteSpace(Paths.RuntimeFastpatch))
            throw new InvalidDataException("paths.runtimeFastpatch must not be empty.");
        if (Debug.Enabled)
        {
            if (string.IsNullOrWhiteSpace(Debug.Host)) throw new InvalidDataException("debug.host must not be empty when debug is enabled.");
            Port(Debug.Port, "debug.port");
        }
    }
}

public sealed class ClientSettings
{
    public int Version { get; init; }
    public string ArtifactVersion { get; init; } = string.Empty;
    public int ServerId { get; init; }
    public int Aid { get; init; }
    public string RpcMd5 { get; init; } = string.Empty;
    public int NoMoreHotfixPatchError { get; init; }
}

public sealed class NetworkSettings
{
    public string BindHost { get; init; } = string.Empty;
    public string AdvertisedHost { get; init; } = string.Empty;
    public int[] LoginPorts { get; init; } = [];
    public int GamePort { get; init; }
    public ProxyNetworkSettings Proxy { get; init; } = new();
}

public sealed class ProxyNetworkSettings
{
    public int HttpsPort { get; init; }
    public int HttpPort { get; init; }
    public int LoginListPort { get; init; }
    public int LoginTcpPort { get; init; }
    public int GameTcpPort { get; init; }
    public int SceneSubPort { get; init; }
    public string UpdateHost { get; init; } = string.Empty;
    public string CertificatePassphrase { get; init; } = string.Empty;
}

public sealed class PlayerSettings
{
    public ulong Pid { get; init; }
    public ulong InitialUnitId { get; init; }
    public uint InitialSpiritTemplateId { get; init; }
    public string AccountId { get; init; } = string.Empty;
    public string UserName { get; init; } = string.Empty;
    public string DisplayName { get; init; } = string.Empty;
    public string LoginToken { get; init; } = string.Empty;
    public string GameToken { get; init; } = string.Empty;
    public string ShareToken { get; init; } = string.Empty;
    public string FpPassToken { get; init; } = string.Empty;
    public string Skey { get; init; } = string.Empty;
    public uint LoginUniverseId { get; init; }
}

public sealed class WorldSettings
{
    public uint RaidId { get; init; }
    public ulong SceneInstanceId { get; init; }
    public uint UniverseId { get; init; }
    public Vector3Settings Spawn { get; init; } = new();
    public float Facing { get; init; }
    public bool EntryOpeningEnabled { get; init; }
    public WorldContentSettings Content { get; init; } = new();
    
    public SceneContentAoiSettings SceneContentAoi { get; init; } = new();

}

public sealed class SceneContentAoiSettings
{
    
    public bool Enabled { get; init; } = true;

    
    
    
    
    public bool ActivateSceneAoi { get; init; } = true;

    
    public float CellSizeMeters { get; init; } = 40f;

    
    public int RadiusCells { get; init; } = 3;

    
    public bool RepublishOnCellChange { get; init; } = true;

    
    public bool Gadgets { get; init; } = true;

    
    public bool Destructibles { get; init; } = true;

    
    
    
    
    
    
    
    
    public bool UseSectorFilter { get; init; } = true;
}

public sealed class WorldContentSettings
{
    
    public bool Enabled { get; init; } = true;

    
    public string Scene { get; init; } = "WorldMap_Release";

    
    
    
    
    
    public string[] ProductionScenes { get; init; } = ["WorldMap_Release"];

    public SceneItemStreamSettings SceneItems { get; init; } = new();
    public GadgetStreamSettings Gadgets { get; init; } = new();
    public DynamicGoStreamSettings DynamicGo { get; init; } = new();
}

public sealed class SceneItemStreamSettings
{
    public bool Enabled { get; init; } = true;

    
    public int RadiusCells { get; init; } = 3;

    
    public int UnloadRadiusCells { get; init; } = 6;

    
    public bool RetainVisitedCells { get; init; } = true;

    
    public bool LoadAllSectors { get; init; } = false;

    
    public bool ExcludeTestItems { get; init; } = true;

    
    public int LoadBudgetCells { get; init; } = 49;
}

public sealed class GadgetStreamSettings
{
    public bool Enabled { get; init; } = true;

    public int RadiusCells { get; init; } = 3;
    public int UnloadRadiusCells { get; init; } = 6;
    public bool RetainVisitedCells { get; init; } = true;

    
    public bool LoadAllSectors { get; init; } = false;

    
    public int LoadBudgetCells { get; init; } = 49;
}

public sealed class DynamicGoStreamSettings
{
    public bool Enabled { get; init; } = true;

    
    public int SeedAttempts { get; init; } = 12;

    
    public bool ActivateAllKnown { get; init; } = true;

    
    public bool ExcludeTestPlaceholders { get; init; } = true;
}

public sealed class Vector3Settings
{
    public float X { get; init; }
    public float Y { get; init; }
    public float Z { get; init; }
    internal Vec3 ToVec3() => new(X, Y, Z);
}

public sealed class ContentSettings
{
    public RosterSettings Roster { get; init; } = new();
    public uint[] ExcludedUnlockSystems { get; init; } = [];
    public bool IncludePhoneBottomApps { get; init; }
}

public sealed class RosterSettings
{
    public uint TemplateIdMin { get; init; }
    public uint TemplateIdMaxExclusive { get; init; }
    public uint[] ExcludedTemplateIds { get; init; } = [];
    public uint GenericPlaceholderIconId { get; init; }
    public ulong UnitIdBase { get; init; }
    public int DefaultUrbanJob { get; init; }
}

public sealed class GameplaySettings
{
    public SwitchAnimationSettings SwitchAnimations { get; init; } = new();
    public CombatSettings Combat { get; init; } = new();
    public WebTraversalSettings WebTraversal { get; init; } = new();
    public VehicleSettings Vehicles { get; init; } = new();
    public EconomySettings Economy { get; init; } = new();
    public FashionSettings Fashions { get; init; } = new();
    public QuestSettings Quests { get; init; } = new();
    public TransitSettings Transit { get; init; } = new();
    public AetherSettings Aether { get; init; } = new();
    public ActionSettings Actions { get; init; } = new();
    public SystemUnlockSettings Systems { get; init; } = new();
    public PhoneSettings Phone { get; init; } = new();
    public GameSwitchSettings GameSwitch { get; init; } = new();
    public BasketballSettings Basketball { get; init; } = new();
    public VehicleNavigationSettings VehicleNavigation { get; init; } = new();
    public SpiritContentSettings SpiritContent { get; init; } = new();
    public SocialAppSettings SocialApp { get; init; } = new();
    public HackerBlackoutSettings HackerBlackout { get; init; } = new();
}

public sealed class HackerBlackoutSettings
{
    
    public bool Enabled { get; init; } = true;

    
    public uint CreationId { get; init; } = 56860922;

    
    public uint Range { get; init; } = 100;

    
    public uint TalentId { get; init; } = 99906106;

    
    public uint CapabilityBuffId { get; init; } = 52606170;

    
    public uint JobClassId { get; init; } = 401;
}

public sealed class SocialAppSettings
{
    
    public bool Enabled { get; init; } = true;

    
    
    
    
    public long PostDateBaseUnix { get; init; }

    
    
    
    
    
    
    public bool IncludeAllPosts { get; init; } = true;

    
    
    
    public uint PostDateStepSeconds { get; init; } = 7200;

    
    
    
    
    
    
    
    
    
    
    
    public string GraffitoUrl { get; init; } = "http://127.0.0.1:5809";

    
    
    
    
    
    
    
    
    
    
    
    public bool SendNpcSchedule { get; init; } = true;
}

public sealed class SpiritContentSettings
{
    
    public bool Enabled { get; init; } = true;

    
    
    
    
    public bool UnlockExclusiveFightStyles { get; init; } = true;

    
    
    
    
    
    public bool UnlockAllFightStyles { get; init; } = true;

    
    
    
    
    public uint FightStyleUnlockTime { get; init; } = 1;

    
    
    
    
    public bool InstallExclusiveApps { get; init; } = true;

    
    
    
    
    public bool InstallAutoDownloadApps { get; init; } = true;

    
    
    
    
    public bool GrantDefaultJobs { get; init; } = true;

    
    
    
    
    public bool UnlockJobSystems { get; init; } = true;

    
    
    
    
    
    
    
    public uint JobTalentPoint { get; init; } = 999;

    
    
    
    
    public bool GrantSpiritTalents { get; init; } = true;

    
    
    
    
    public uint SpiritTalentLayer { get; init; } = 1;

    
    
    
    public uint SpiritTalentPoint { get; init; } = 999;

    
    
    
    
    public uint SpiritTalentLevel { get; init; } = 35;

    
    
    
    public uint CommonSpiritTalentExp { get; init; }

    
    
    
    public uint SpiritInitTalentPointAdd { get; init; }

    
    
    
    
    
    public bool GrantUrbanAbilities { get; init; } = true;

    

    
    
    
    
    
    
    
    
    public bool MaxJobLevel { get; init; } = true;

    
    
    
    
    
    
    
    public uint JobMaxExp { get; init; }

    
    
    
    
    
    
    
    
    public bool JobTopTier { get; init; } = true;

    
    
    
    
    
    
    
    
    public bool UnlockAllJobTalents { get; init; } = true;

    
    
    
    
    public bool UnlockAllSpiritTalents { get; init; } = true;

    
    
    
    
    
    public bool UnlockAllGameplayTalents { get; init; } = true;

    
    
    
    
    
    
    
    
    
    
    public bool MaxUrbanAttribute { get; init; } = true;

    
    
    
    
    
    
    
    
    
    
    
    
    public bool TruckOrdersEnabled { get; init; } = true;

    
    public int TruckOrderCount { get; init; } = 3;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public uint TruckTeachingEventId { get; init; } = 1234;

    

    
    
    
    
    
    
    public bool MarkVehiclesHackable { get; init; } = true;

    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public bool HackTargetsEnabled { get; init; } = true;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public uint HackerBatteryTotal { get; init; } = 6;

    
    public uint HackerBatteryCurrent { get; init; } = 6;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public bool SendHackerBatteryCostInfo { get; init; }

    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public bool PoliceAppContentEnabled { get; init; } = true;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public string[] PoliceCaseSpecs { get; init; } =
    [
        "40650550:1",
        "4065053:4,5",
    ];

    
    public int PoliceCaseDaysAgo { get; init; } = 3;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public bool UnlockPhoneAppJobs { get; init; } = true;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public bool GrantHackingAbilityBuff { get; init; } = true;

    

    
    
    
    
    
    
    public uint HackerSpiritTemplateId { get; init; } = 15_021_023;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public uint[] HackerAbilityBuffIds { get; init; } = DefaultHackerAbilityBuffIds;

    
    public static readonly uint[] DefaultHackerAbilityBuffIds =
    [
        52_606_133, 
        52_606_134, 
        52_606_135, 
        52_606_136, 
        52_606_137, 
        52_606_138, 
        52_606_161, 
        52_606_162, 
        52_606_178, 
        52_606_179, 
        52_606_167, 
        52_606_168, 
        52_606_149, 
        52_606_150, 
    ];

    
    
    
    
    public bool UnlockUniqueSkill { get; init; } = true;

    
    
    
    
    
    
    
    
    
    
    
    
    public bool GrantAvatarJobs { get; init; } = true;

    
    
    
    
    
    
    
    public string HackerName { get; init; } = "ZeroCool";

    
    
    
    public uint HackerRank { get; init; } = 1;

    
    
    
    
    public bool UnlockHackerPosts { get; init; } = true;

    
    public int HackerPostState { get; init; }

    
    public bool HackerPostsRead { get; init; }

    
    
    
    
    
    
    
    
    public bool UnlockPoliceFakeFiles { get; init; } = true;

    
    
    
    
    
    public bool LogPerSpirit { get; init; } = true;
}

public sealed class VehicleNavigationSettings
{
    
    public bool Enabled { get; init; } = true;

    
    
    
    
    
    public bool ForcePreferMainRoad { get; init; }

    
    
    
    
    
    public float MaxTargetSnapMeters { get; init; } = 250f;

    
    
    
    
    public int MaxPathPoints { get; init; } = 4096;

    
    public bool LogEveryRequest { get; init; }

    
    
    
    
    
    
    
    
    public bool SendAutonomousDrivingState { get; init; } = true;
}

public sealed class BasketballSettings
{
    
    public bool Enabled { get; init; } = true;

    
    
    
    
    
    
    
    
    public bool SpawnAtCourt { get; init; }

    
    
    
    
    public int SpawnCourtId { get; init; }

    
    
    
    
    public bool LogNearestOnWorldEntry { get; init; } = true;

    
    
    
    
    
    
    
    
    public bool ExplicitSpawnEnabled { get; init; }

    
    public int ExplicitSpawnCourtId { get; init; } = 1;

    
    public float ExplicitSpawnOffsetX { get; init; } = 20f;

    public float ExplicitSpawnOffsetZ { get; init; } = 20f;
}

public sealed class GameSwitchSettings
{
    public bool Enabled { get; init; } = true;

    
    
    
    
    public Dictionary<string, bool> Overrides { get; init; } = new(StringComparer.Ordinal);

    
    
    
    
    
    
    
    
    
    
    public string Framing { get; init; } = "nullTerminated";
}

public sealed class PhoneSettings
{
    public bool Enabled { get; init; } = true;

    
    public bool UnlockAllSkinParts { get; init; } = true;
}

public sealed class SystemUnlockSettings
{
    public bool Enabled { get; init; } = true;

    
    public bool UnlockAll { get; init; } = true;

    
    public uint[] UnlockIds { get; init; } = [];
}

public sealed class ActionSettings
{
    public bool Enabled { get; init; } = true;

    
    public bool UnlockAll { get; init; } = true;

    
    public uint[] UnlockIds { get; init; } = [];
}

public sealed class VehicleSettings
{
    public bool Enabled { get; init; } = true;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public bool HasZoneGraph { get; init; } = true;
    public uint[] FleetIds { get; init; } = [];
    public float DesiredApproachMeters { get; init; } = 32f;
    public float MinimumApproachMeters { get; init; } = 24f;
    public float SearchRadiusMeters { get; init; } = 80f;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public int ZoneStorageDataHandle { get; init; }

    
    
    
    
    
    
    public int AetherVehicleCount { get; init; }
}

public sealed class SwitchAnimationSettings
{
    public int SwitchType { get; init; }
    public string CommonTimelinePrefix { get; init; } = string.Empty;
    public bool AvoidImmediateRepeat { get; init; }

    
    
    
    
    
    
    
    public string TeleportTiming { get; init; } = "apex";

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public int ApexDelayMs { get; init; } = 3600;
}

public sealed class CombatSettings
{
    public float MaxHp { get; init; }
    public float Attack { get; init; }
    public float Defense { get; init; }
    public float MoveSpeedMultiplier { get; init; }
    public float PanelDamage { get; init; }
    public float PanelDefenseDeduct { get; init; }
    public uint FightStyleTypeId { get; init; }
    public uint FightStyleId { get; init; }
    public int[] DefaultUrbanAbilities { get; init; } = [];
    public WeaponSettings Weapon { get; init; } = new();
    public ResourceSettings Resource { get; init; } = new();

    
    
    
    
    
    
    public bool InfiniteAmmo { get; init; } = true;
    public SkillSettings Skills { get; init; } = new();
    public SkillChargeSettings[] Charges { get; init; } = [];
}

public sealed class WeaponSettings
{
    public uint TemplateId { get; init; }
    public ulong InstanceId { get; init; }
}

public sealed class ResourceSettings
{
    public uint Id { get; init; }
    public float Max { get; init; }
}

public sealed class SkillSettings
{
    public uint Common { get; init; }
    public uint PressCommon { get; init; }
    public uint HeavyCommon { get; init; }
    public uint Dodge { get; init; }
    public uint DodgeAttack { get; init; }
    public uint GrappleAttack { get; init; }
    public uint Active { get; init; }
    public uint Unique { get; init; }

    internal IEnumerable<uint> All()
    {
        yield return Common;
        yield return PressCommon;
        yield return HeavyCommon;
        yield return Dodge;
        yield return DodgeAttack;
        yield return GrappleAttack;
        yield return Active;
        yield return Unique;
    }

    internal uint ByName(string name) => name.ToLowerInvariant() switch
    {
        "common" => Common,
        "presscommon" => PressCommon,
        "heavycommon" => HeavyCommon,
        "dodge" => Dodge,
        "dodgeattack" => DodgeAttack,
        "grappleattack" => GrappleAttack,
        "active" => Active,
        "unique" => Unique,
        _ => throw new InvalidDataException($"Unknown gameplay.combat.charges skill name '{name}'.")
    };
}

public sealed class SkillChargeSettings
{
    public string Skill { get; init; } = string.Empty;
    public uint Current { get; init; }
    public uint Max { get; init; }
    public float Period { get; init; }
}

public sealed class WebTraversalSettings
{
    public uint MaleProtagonistId { get; init; }
    public uint FemaleProtagonistId { get; init; }
    public uint PersistentGrappleBuffId { get; init; }
    public int GrappleRearmDelayMs { get; init; }
    public uint[] SharedBuffIds { get; init; } = [];
    public uint[] MaleExtraBuffIds { get; init; } = [];
    public uint[] FemaleExtraBuffIds { get; init; } = [];
    public uint[] ForbidStateIds { get; init; } = [];
}

public sealed class UiSettings
{
    
    public UidLabelSettings UidLabel { get; init; } = new();
    public bool RemoveStockConfidentialLabel { get; init; }
    public CutscenePanelSettings CutscenePanel { get; init; } = new();
}

public sealed class CutscenePanelSettings
{
    public bool Enabled { get; init; } = true;
    public string Host { get; init; } = "127.0.0.1";
    public int Port { get; init; } = 17666;
}

public sealed class UidLabelSettings
{
    public bool Enabled { get; init; }
    public string Text { get; init; } = string.Empty;
}

public sealed class EconomySettings
{
    public bool Enabled { get; init; } = true;
    public double Money { get; init; }
    public double Gold { get; init; }
    public double BindingGold { get; init; }
    public double FreeGold { get; init; }

    
    public List<StartingItem> StartingItems { get; init; } = [];

    
    public bool GrantAllArmoryWeapons { get; init; }

    
    
    
    
    public bool GrantAllAmmo { get; init; }

    
    public uint[] ExtraWeaponTemplateIds { get; init; } = [];

    public sealed class StartingItem
    {
        public uint TemplateId { get; init; }
        public uint Count { get; init; }
    }
}

public sealed class FashionSettings
{
    public bool Enabled { get; init; } = true;

    
    
    
    
    public bool UnlockAllFashions { get; init; } = true;

    
    public uint[] UnlockedFashionIds { get; init; } = [];

    
    public uint[] WearFashionIds { get; init; } = [];
}

public sealed class TransitSettings
{
    
    public int SubwayFare { get; init; }
}

public sealed class QuestSettings
{
    public bool Enabled { get; init; } = true;
    public bool SendLoginBootstrap { get; init; } = true;

    
    
    
    
    
    
    
    
    
    public bool SendSpoonViewInfo { get; init; } = true;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public string SpoonAlias { get; init; } = "Xinshouben";

    
    
    
    
    
    
    
    
    
    
    
    
    public string[] SpoonAliasProbe { get; init; } = [];

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public string[] SceneSpoonNames { get; init; } = [];

    
    public string[] SceneSpoonMd5s { get; init; } = [];

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public uint[] EventIds { get; init; } = [];

    
    
    
    
    
    
    public bool AutoDeriveEvents { get; init; } = true;

    
    
    
    
    
    
    
    
    
    
    public byte EventStatusFlags { get; init; } = 21;

    
    
    
    
    public bool EventTaskIdFollowsContainer { get; init; } = true;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public uint[] SubmitEventIds { get; init; } = [1234];

    public uint[] StartingTaskIds { get; init; } = [];
    public uint[] UnlockedQuestIds { get; init; } = [];
    public uint[] CompletedSubQuestIds { get; init; } = [];
    public uint[] FinishedGuideIds { get; init; } = [];
    public byte StartingTaskState { get; init; } = 1;
    public byte CurrentTaskReason { get; init; }
    public bool AutoStartStoryChain { get; init; } = true;
}

public sealed class AetherSettings
{
    
    
    
    
    public int WorldEntryDelayMs { get; init; } = 5000;

    
    
    
    
    public int InitSettleMs { get; init; } = 1500;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public string VehicleDriveMode { get; init; } = "laneData";

    
    
    
    
    public byte VehicleControlType { get; init; } = 1;

    
    
    
    
    public uint[] VehicleAiConfigIds { get; init; } = [];

    
    public int AiTaskWaypointCount { get; init; } = 6;

    
    
    
    
    
    
    
    public double ReAddVehicleDataSeconds { get; init; } = 10.0;

    
    
    
    
    public bool IntersectionUpdateEnabled { get; init; } = true;

    
    
    
    
    
    
    
    
    
    public string IntersectionIndexSource { get; init; } = "zoneIndex";

    
    
    
    
    
    
    
    
    
    
    
    public double IntersectionPeriodSeconds { get; init; } = 12.0;

    
    
    
    
    
    
    
    
    
    public float VehicleMinGapMeters { get; init; } = 7.0f;

    
    
    
    
    
    public bool VehicleFollowEnabled { get; init; }

    
    
    
    
    
    
    public bool VehicleSignalStopEnabled { get; init; }

    
    
    
    
    
    
    
    
    
    
    public int VehicleNpcReAddCount { get; init; } = 2;

    
    
    
    public float IntersectionStopOffsetMeters { get; init; } = 3.0f;

    
    
    
    
    
    
    
    
    
    
    
    
    public bool CrowdUseStaticNpcChannel { get; init; } = true;

    
    
    
    
    
    
    
    
    
    
    public string CrowdBehaviorTreeName { get; init; } = "PedBase";

    
    
    
    
    public uint CrowdFashionSuitId { get; init; } = 11190001;

    

    
    
    
    
    
    
    public bool CrowdWanderEnabled { get; init; } = true;

    
    public float CrowdWanderMinDis { get; init; } = 8f;

    
    public float CrowdWanderMaxDis { get; init; } = 35f;

    
    public float CrowdWanderMaxTime { get; init; } = 180f;

    
    public float CrowdWanderOnceTime { get; init; } = 25f;

    
    
    
    
    public int CrowdWanderMoveType { get; init; }

    
    public bool CrowdWanderAvoidance { get; init; } = true;

    
    
    
    
    
    
    
    
    public float CrowdDesiredSpeedMin { get; init; } = 1.1f;

    
    public float CrowdDesiredSpeedMax { get; init; } = 1.7f;

    
    
    
    
    
    
    
    
    public int CrowdWanderPathTags { get; init; } = 6;

    
    
    
    
    public float CrowdWanderLeftAngle { get; init; } = -180f;

    
    
    
    
    public float CrowdWanderRightAngle { get; init; } = 180f;

    
    
    
    
    
    
    
    
    
    
    public float CrowdReWanderSeconds { get; init; } = 150f;

    
    
    
    
    
    
    
    public int CrowdMaxPerWaitArea { get; init; } = 2;

    
    
    
    
    
    
    
    public int CrowdBehaviorTaskId { get; init; }

    
    
    
    
    
    public int VehicleNpcBehaviorTaskId { get; init; }

    
    public float VehicleSpawnRadiusMeters { get; init; } = 160f;

    
    
    
    
    public float VehicleLeashMeters { get; init; }

    
    
    
    
    
    
    
    public float VehicleSpawnMinDistanceMeters { get; init; } = 90f;

    
    
    
    
    public bool VehiclePreferInbound { get; init; } = true;

    
    public float VehicleSpeedMin { get; init; } = 8f;

    
    public float VehicleSpeedMax { get; init; } = 16f;

    
    public int PacketGapMs { get; init; } = 6;

    
    
    
    
    public uint[] AmbientVehicleIds { get; init; } = [];

    
    
    
    
    
    
    
    
    
    
    
    public uint[] VehicleNpcFormworkIds { get; init; } = [];

    
    
    
    
    public bool IntersectionsEnabled { get; init; } = true;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public bool CreateBaseVehicle { get; init; } = true;

    
    
    
    
    public int LaneTickMs { get; init; } = 50;

    
    
    
    
    
    
    
    
    
    public string LaneDataTimeBase { get; init; } = "unix";

    
    
    
    
    
    public bool ForceGo { get; init; } = true;

    
    
    
    
    public float SpeedVariance { get; init; } = 0.3f;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public int ReAddVehicleDataEveryTicks { get; init; } = 20;

    
    public int CrowdCount { get; init; } = 30;

    
    public float CrowdRadiusMeters { get; init; } = 120f;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    public uint[] NpcAgentConfigIds { get; init; } = [];

    
    
    
    public uint[] NpcPersonaIds { get; init; } = [45200003, 45200004, 45200007, 45200008];

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    public bool FixedNpcEnabled { get; init; } = true;

    
    public int FixedNpcCount { get; init; } = 40;

    
    
    
    
    
    
    
    
    public float FixedNpcRadiusMeters { get; init; } = 250f;

    
    
    
    
    
    
    
    public float FixedNpcLeashMeters { get; init; }

    
    
    
    
    
    
    public float FixedNpcTopUpBackoffSeconds { get; init; } = 5f;

    
    
    
    
    
    public int FixedNpcSourceType { get; init; } = 10;

    
    
    
    
    
    
    
    
    public string FixedNpcBehaviorTreeName { get; init; } = "PedBase";

    
    
    
    
    
    
    
    
    public float FixedNpcDesiredSpeed { get; init; } = 1.3f;

    
    
    
    
    
    
    
    
    
    
    
    
    public bool FixedNpcWander { get; init; } = true;

    
    public float FixedNpcWanderMinDis { get; init; }

    
    
    
    
    public float FixedNpcWanderMaxDis { get; init; } = 15f;

    
    public float FixedNpcWanderMaxTime { get; init; } = 3600f;

    
    public float FixedNpcWanderOnceTime { get; init; } = 60f;

    
    
    
    
    
    
    
    
    
    
    public float FixedNpcReWanderSeconds { get; init; } = 50f;

    
    public uint FixedNpcFashionSuitId { get; init; }
}

public sealed class LoggingSettings
{
    
    public string Directory { get; init; } = string.Empty;
    public ConsoleLoggingSettings Console { get; init; } = new();
    public PacketLoggingSettings Packets { get; init; } = new();
    
    
}

public sealed class ConsoleLoggingSettings
{
    public bool Enabled { get; init; }
}

public sealed class PacketLoggingSettings
{
    public bool Enabled { get; init; }
    public bool IncludeHex { get; init; }
    public bool IncludeDecoded { get; init; }
    
    public int MaxBodyBytes { get; init; }
}

public sealed class PathSettings
{
    
    public string ClientConfigs { get; init; } = string.Empty;
    public string ZoneGraphLanes { get; init; } = string.Empty;

    
    
    
    
    public string PedSpawns { get; init; } = string.Empty;

    
    
    
    
    
    
    
    
    
    
    public string StaticNpcSpawns { get; init; }
        = "Ananta.Server/Ananta.App/data/zonegraph_static_npc_spawns.csv";

    
    
    
    
    
    public string Intersections { get; init; } = string.Empty;

    
    
    public string WorldData { get; init; } = string.Empty;

    
    
    
    
    public string BasketballCourts { get; init; } = "Ananta.Server/Ananta.App/data/basketball_courts.json";

    
    
    
    
    public string WorldCells { get; init; } = "Ananta.Server/Ananta.App/data/world_cells.json";

    
    
    
    
    
    
    
    
    public string VehicleNavGraph { get; init; } = "Ananta.Server/Ananta.App/data/vehicle_nav_graph.bin";

    
    public string RuntimeFastpatch { get; init; } = ".runtime/fastpatch";
}

public sealed class DebugSettings
{
    public bool Enabled { get; init; } = true;
    public string Host { get; init; } = "127.0.0.1";
    public int Port { get; init; } = 5809;
}

internal static class PrivateServerConfigStore
{
    private static PrivateServerConfig? _current;
    private static string? _configPath;

    internal static PrivateServerConfig Current => _current
        ?? throw new InvalidOperationException("PrivateServerConfigStore.Initialize must run before protocol/gameplay code.");

    internal static string ConfigPath => _configPath
        ?? throw new InvalidOperationException("PrivateServerConfigStore.Initialize must run before path resolution.");

    private static string? _projectRoot;

    internal static string ProjectRoot => _projectRoot
        ?? throw new InvalidOperationException("PrivateServerConfigStore.Initialize must run before path resolution.");

    internal static void Initialize(PrivateServerConfig config, string configPath)
    {
        _current = config;
        _configPath = Path.GetFullPath(configPath);
        _projectRoot = FindProjectRoot(_configPath);
    }

    private static string FindProjectRoot(string configPath)
    {
        var explicitRoot = Environment.GetEnvironmentVariable("Ananta_ROOT");
        if (!string.IsNullOrWhiteSpace(explicitRoot))
            return Path.GetFullPath(explicitRoot);

        static string? SearchUp(string? start)
        {
            if (string.IsNullOrWhiteSpace(start)) return null;
            var first = new DirectoryInfo(Path.GetFullPath(start));

            
            
            for (var current = first; current is not null; current = current.Parent)
                if (File.Exists(Path.Combine(current.FullName, "AnantaPS.sln")))
                    return current.FullName;

            
            
            for (var current = first; current is not null; current = current.Parent)
                if (File.Exists(Path.Combine(current.FullName, "config", "private-server.json")))
                    return current.FullName;

            return null;
        }

        var fromConfig = SearchUp(Path.GetDirectoryName(configPath));
        if (fromConfig is not null) return fromConfig;
        var fromBase = SearchUp(AppContext.BaseDirectory);
        if (fromBase is not null) return fromBase;
        var fromCurrent = SearchUp(Directory.GetCurrentDirectory());
        if (fromCurrent is not null) return fromCurrent;

        throw new DirectoryNotFoundException(
            "Cannot locate the Ananta project root. Set Ananta_ROOT or launch from the project directory.");
    }

    internal static string ResolveProjectPath(string configuredPath)
        => Path.IsPathRooted(configuredPath)
            ? Path.GetFullPath(configuredPath)
            : Path.GetFullPath(Path.Combine(ProjectRoot, configuredPath));
}

internal static class PrivateServerConfigLoader
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        ReadCommentHandling = JsonCommentHandling.Skip,
        AllowTrailingCommas = true,
        Converters = { new System.Text.Json.Serialization.JsonStringEnumConverter(System.Text.Json.JsonNamingPolicy.CamelCase) },
    };

    internal static (PrivateServerConfig Config, string Path) Load()
    {
        var explicitPath = Environment.GetEnvironmentVariable("Ananta_CONFIG");
        var candidates = new List<string>();
        if (!string.IsNullOrWhiteSpace(explicitPath)) candidates.Add(explicitPath);
        candidates.Add(Path.Combine(Directory.GetCurrentDirectory(), "config", "private-server.json"));
        candidates.Add(Path.Combine(AppContext.BaseDirectory, "config", "private-server.json"));

        var path = candidates.Select(Path.GetFullPath).FirstOrDefault(File.Exists)
            ?? throw new FileNotFoundException("Cannot find config/private-server.json. Set Ananta_CONFIG to an explicit path if needed.");

        var json = File.ReadAllText(path);
        var config = JsonSerializer.Deserialize<PrivateServerConfig>(json, JsonOptions)
            ?? throw new InvalidDataException($"Configuration file is empty: {path}");
        config.Validate();
        return (config, path);
    }
}
