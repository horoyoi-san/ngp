using Ananta.Server.RpcTypes.Client4229938;
namespace Ananta.Server.Protocol.Client4229938;

internal sealed class WorldEntryState
{
    internal object SyncRoot { get; } = new();

    internal bool InitialStateSent { get; set; }
    internal bool EnterSceneSent { get; set; }
    internal bool SceneLoadAckSeen { get; set; }
    internal bool GameResourcesReadySeen { get; set; }
    internal bool ControlPublished { get; set; }
    internal bool SceneCompletionSent { get; set; }
    internal bool CurrentSpiritStateSent { get; set; }
    internal bool Ready { get; set; }
    internal bool LivePlayerProfilePublished { get; set; }
    internal bool SameSceneAckSeen { get; set; }
    internal bool MovementCapabilityPublished { get; set; }
    internal bool FreeRoamReleased { get; set; }
    internal bool FirstMovementSeen { get; set; }
    internal bool GaragePublished { get; set; }
    internal bool AetherVehicleInitSent { get; set; }

    
    
    
    
    
    
    
    
    internal bool SwitchAetherInitSent { get; set; }

    
    
    
    
    
    internal bool AetherRepushedAtLivePos { get; set; }
    internal bool InitialCapabilityBuffsPublished { get; set; }
    internal bool AllBuildBuffsPublished { get; set; }
    internal bool InitialActorPresentationPublished { get; set; }
    internal bool CombatProfilePublished { get; set; }
    internal bool AccountArmoryPublished { get; set; }

    
    
    internal uint ActiveRaidId { get; set; } = Profile.RaidId;
    internal ulong ActiveInstanceId { get; set; } = Profile.SceneInstanceId;
    internal uint ActiveUniverseId { get; set; } = Profile.UniverseId;
    internal string ActiveContentScene { get; set; } = "WorldMap_Release";
    internal bool WorldEntryIsAirportTravel { get; set; }

    
    
    
    
    internal ulong PendingTeleportId { get; set; }
    internal string PendingAirportRouteKey { get; set; } = string.Empty;
    internal bool PendingTeleportPreFinished { get; set; }
    internal bool PendingTeleportSyncSent { get; set; }

    
    
    internal bool WorldEntryControlPending { get; set; }
    internal bool WorldEntryControlFinalized { get; set; }
    internal ulong WorldEntryControlUnit { get; set; }
    internal uint WorldEntryControlTemplate { get; set; }
    internal int WorldEntryControlGeneration { get; set; }
    internal int WorldEntryLoadingCompletedGeneration { get; set; }
    internal int WorldEntryOpeningEndedGeneration { get; set; }
    internal int WorldEntryControlFinalizingGeneration { get; set; }
    internal int WorldEntryLogicProjectionPublishedGeneration { get; set; }
    internal int WorldEntryCurrentMetadataPublishedGeneration { get; set; }
    internal ulong WorldEntrySceneId4229938 { get; set; }
    internal ulong WorldEntrySessionId4229938 { get; set; }
    internal Vec3 WorldEntryCreateHeroPosition { get; set; } = Profile.WorldSpawn;
    internal float WorldEntryCreateHeroFacing { get; set; } = Profile.WorldFacing;
    internal Vec3 LastReportedPlayerPosition { get; set; } = Profile.WorldSpawn;
    internal Vec3 LastReportedPlayerRotation { get; set; } = new(0f, Profile.WorldFacing, 0f);
    internal bool HasLastReportedPlayerTransform { get; set; }

    internal uint ActiveSkillId { get; set; }
    internal bool RestoreResourcesAfterActiveSkill { get; set; }
    internal int ActiveClientSkillInstanceId { get; set; }
    internal long ActiveSkillStartedTicks { get; set; }
    internal ulong ActiveWeaponInstanceId { get; set; }
    internal uint ActiveFightStyleId { get; set; }
    internal Dictionary<uint, ulong> LastWeaponBySpirit { get; } = [];
    internal Dictionary<uint, List<ulong>> WeaponSlotsBySpirit { get; } = [];
    internal Dictionary<ulong, uint> WeaponStyleOverrides { get; } = [];
    
    
    internal Dictionary<ulong, int> WeaponMagazineAmmo { get; } = [];
    
    
    internal Dictionary<ulong, int> WeaponDurabilityAmmo { get; } = [];
    internal Dictionary<ulong, uint> WeaponBulletByInstance { get; } = [];
    internal Dictionary<uint, uint> BackpackItemCounts { get; } = [];

    
    
    
    
    
    
    
    internal ulong PendingReloadWeaponInstanceId { get; set; }

    internal Dictionary<(uint SpiritId, uint FightStyleTypeId), uint> SpiritStyleOverrides { get; } = [];
    internal int CombatUseCount { get; set; }
    internal int CombatEndCount { get; set; }
    internal int CombatHitCount { get; set; }
    internal uint NextBuffInstanceId { get; set; } = 1200000u;
    internal uint ActiveFeiSuoBuffInstanceId { get; set; }
    internal ulong ActiveFeiSuoBuffUnitId { get; set; }

    
    
    
    
    
    
    
    
    internal uint ActiveHackingAbilityInstanceId { get; set; }

    
    internal ulong HackingAbilityBuffUnitId { get; set; }

    
    
    
    
    
    
    
    
    
    
    
    internal Dictionary<uint, uint> ActiveHackingBuffInstances { get; } = [];

    
    internal ulong HackingBuffsUnitId { get; set; }

    
    
    internal Dictionary<(ulong UnitId, uint BuffId), uint> ActiveClientWebBuffInstances { get; } = [];
    internal ulong SceneId { get; set; }
    
    internal Dictionary<uint, uint> GachaDrawsSinceGrand { get; } = new();

    internal ulong ActiveSpiritUnitId { get; set; } = Profile.InitialUnitId;
    internal uint ActiveSpiritTemplateId { get; set; } = Profile.InitialSpiritTemplateId;
    internal uint WorldEntrySwitchShowId { get; set; }
    internal uint LastSwitchShowId { get; set; }
    internal int SwitchCount { get; set; }

    
    
    
    internal uint PendingSwitchTemplateId { get; set; }
    internal ulong PendingSwitchUnitId { get; set; }
    internal ulong PendingSwitchOldUnitId { get; set; }
    internal uint PendingSwitchShowId { get; set; }
    internal Vec3 PendingSwitchPosition { get; set; } = Profile.WorldSpawn;
    internal float PendingSwitchFacing { get; set; } = Profile.WorldFacing;
    internal bool PendingSwitchControlTransferred { get; set; }
    internal bool PendingSwitchLandingStarted { get; set; }

    
    
    
    
    
    
    
    
    
    
    internal PendingSwitchTimeline4229938? PendingSwitchTimeline { get; set; }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal PendingSwitchTimeline4229938? ActiveSwitchTimeline { get; set; }

    
    internal uint TimeHour { get; set; }
    internal uint TimeMinute { get; set; }
    internal bool TimeFixed { get; set; }
    internal uint TimeTransitionSeconds { get; set; }
    internal bool HasExplicitTime { get; set; }
    internal uint WeatherId { get; set; }
    internal uint WeatherTransitionSeconds { get; set; }
    internal bool HasExplicitWeather { get; set; }

    
    
    
    
    
    
    
    
    internal Dictionary<uint, int[]> QuestCounterValues { get; } = [];

    
    internal List<uint> StoryChain { get; } = [];

    
    internal Dictionary<uint, byte> QuestStates { get; } = [];
    internal uint CurrentQuestTaskId { get; set; }
    internal bool QuestContainerSent { get; set; }

    
    internal HashSet<uint> UnlockedQuestIds { get; } = [];
    internal HashSet<uint> CompletedSubQuestIds { get; } = [];
}

internal sealed class PendingSwitchTimeline4229938
{
    internal uint ConfigId { get; init; }
    internal uint TemplateId { get; init; }
    internal ulong UnitId { get; init; }
    internal ulong OldUnitId { get; init; }
    internal Vec3 Anchor { get; init; }
    internal float Facing { get; init; }
    internal string Timeline { get; init; } = string.Empty;
    internal string Place { get; init; } = string.Empty;
    internal string Show { get; init; } = string.Empty;
    internal List<ulong> SpawnedAgents { get; init; } = [];

    

    
    
    
    
    internal string TeleportTiming { get; init; } = "immediate";

    
    internal int ApexDelayMs { get; init; }

    
    internal Vec3 OriginPosition { get; init; }

    
    private int _apexTeleportDone;

    
    internal bool TryBeginApexTeleport()
        => Interlocked.CompareExchange(ref _apexTeleportDone, 1, 0) == 0;

    
    internal bool ApexTeleportDone => Volatile.Read(ref _apexTeleportDone) != 0;

    
    private int _continuationStarted;

    
    internal bool TryBeginContinuation()
        => Interlocked.CompareExchange(ref _continuationStarted, 1, 0) == 0;
}
