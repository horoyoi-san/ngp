using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal static class SpiritContentCatalogRepository
{
    

    
    internal sealed record SpiritRow(
        uint Id,
        string Name,
        uint NpcCultivationId,
        uint DefaultUrbanJob,
        uint[] InitFightSkillSetting,
        bool UnlockUniqueSkill,
        uint TalentId,
        uint CommonTalentLevel,
        uint CommonTalentPoint,
        uint PassiveSkill,
        (uint AbilityId, int Value)[] DefaultUrbanAbility,
        uint[] UrbanBuff,
        string[] UrbanBuffTag,
        bool CanJoin,
        bool Invisible,
        
        
        
        
        
        
        
        
        int[] UrbanAttribute);

    
    internal sealed record FightStyleRow(
        uint Id,
        string Name,
        uint FightSkillType,
        int Quality,
        uint[] SpiritIds,
        bool IsLocked,
        bool ShowInArmory,
        string SourceDesc,
        string SimpleDesc,
        string DetailDesc,
        uint UniqueSkill,
        uint ActiveSkill,
        uint CommonSkill);

    
    internal sealed record CharacteristicRow(
        uint Id,
        uint[] SpiritIds,
        string Name,
        string Description,
        int Quality,
        uint Image,
        string Notes);

    
    internal sealed record MobileAppRow(
        uint Id,
        string Name,
        bool IsInAppStore,
        bool IsShow,
        bool IsLoading,
        uint[] SystemIds,
        string GuideId,
        uint[] NpcCultivationIds,
        uint[] LockNpcCultivationIds,
        uint[] RelatedTaskIds,
        uint[] JobClassIds,
        uint RedDotId,
        bool TeleportHide,
        string Slogen,
        string Description)
    {
        
        internal bool IsExclusive => NpcCultivationIds.Length > 0 || JobClassIds.Length > 0;
    }

    
    internal sealed record JobLevelRow(
        uint Id,
        string Name,
        uint PreJob,
        uint Level,
        uint JobClass,
        uint PromoteTask,
        uint Cost);

    
    
    
    
    
    
    
    
    
    
    
    internal sealed record JobLevelConfigRow(uint Id, uint JobClassId, uint Level, uint Exp);

    
    internal sealed record JobClassRow(uint Id, string ClassName, uint SystemUnlock, bool ActiveTask);

    
    internal sealed record SpiritTalentRow(uint Id, uint SpiritId, uint[] TalentIds);

    
    internal sealed record SpiritTalentEffectRow(
        uint Id,
        int TalentType,
        string Title,
        uint[] BuffIds,
        string BuffDescribe,
        float SpecialBuffValue,
        int AttributeRollInt,
        uint[] AttributeRollPool);

    
    internal sealed record SpiritTalentUnlockRow(uint Id, uint CostMoney, uint UnlockWorldLevel);

    
    internal sealed record TalentTreeRow(
        uint Id,
        string Name,
        int TabIndex,
        uint[] SpiritIds,
        uint JobClassId,
        uint GameplayId,
        uint[] SystemIds,
        int TreeType,
        bool EnableReset,
        string Tag);

    
    internal sealed record TalentNodeRow(
        uint Id,
        string Name,
        uint[] TreeIds,
        uint[] PreTalentIds,
        uint CostPoint,
        uint JobRequest,
        bool IsOrigin,
        int LayerNum,
        uint[] SpiritIds,
        uint[] Buffs);

    
    internal sealed record TalentLevelRow(uint Id, uint Exp, uint GainTalentPoint, uint Fan);

    
    internal sealed record FakeFileRow(
        uint Id,
        uint FightSpiritId,
        uint AgentId,
        string Desc,
        string Group,
        uint ClueValue,
        uint NeedActive);

    
    internal sealed record HackerPostRow(uint Id, uint PostType, string Title, string Name);

    
    internal sealed record UrbanAbilityRow(
        uint Id,
        string Name,
        uint Type,
        uint AbilityType,
        uint MaxLevel,
        uint InitBuffId);

    
    
    
    
    
    
    internal sealed record JobBoardRow(
        uint Id,
        uint JobClassId,
        string JobTitle,
        string JobDescription,
        uint Salary,
        uint[] JobTags,
        uint RelatedTask,
        bool CanResign,
        uint UnlockProgress,
        int SortOrder);

    

    private static readonly object Sync = new();
    private static bool _loaded;

    private static Dictionary<uint, SpiritRow> _spirits = [];
    private static Dictionary<uint, List<FightStyleRow>> _stylesBySpirit = [];
    private static List<FightStyleRow> _allStyles = [];
    private static Dictionary<uint, List<CharacteristicRow>> _charsBySpirit = [];
    private static List<CharacteristicRow> _allChars = [];
    private static Dictionary<uint, MobileAppRow> _apps = [];
    private static List<uint> _autoDownloadApps = [];
    private static Dictionary<uint, JobLevelRow> _jobLevels = [];
    private static Dictionary<uint, JobClassRow> _jobClasses = [];
    private static Dictionary<uint, List<SpiritTalentRow>> _spiritTalents = [];
    private static Dictionary<uint, SpiritTalentEffectRow> _talentEffects = [];
    private static Dictionary<uint, SpiritTalentUnlockRow> _talentUnlocks = [];
    private static List<TalentTreeRow> _talentTrees = [];
    private static Dictionary<uint, List<TalentNodeRow>> _talentNodesByTree = [];
    private static Dictionary<uint, TalentLevelRow> _talentLevels = [];
    private static Dictionary<uint, List<uint>> _avatarJobsBySpirit = [];
    private static Dictionary<uint, List<FakeFileRow>> _fakeFilesBySpirit = [];
    private static List<HackerPostRow> _hackerPosts = [];

    
    private static Dictionary<uint, List<JobLevelConfigRow>> _jobLevelConfigs = [];

    
    private static List<TalentNodeRow> _allTalentNodes = [];

    
    private static List<UrbanAbilityRow> _urbanAbilities = [];

    
    private static int _urbanAttributeCount;
    private static int _urbanAttributeMax;

    
    private static List<JobBoardRow> _jobBoard = [];

    internal static bool Loaded
    {
        get { EnsureLoaded(); lock (Sync) return _loaded; }
    }

    

    internal static SpiritRow? Spirit(uint spiritId)
    {
        EnsureLoaded();
        lock (Sync)
            return _spirits.TryGetValue(spiritId, out var v) ? v : null;
    }

    internal static IReadOnlyList<SpiritRow> AllSpirits
    {
        get { EnsureLoaded(); lock (Sync) return _spirits.Values.OrderBy(x => x.Id).ToArray(); }
    }

    private static uint[]? _orphanAppJobClasses;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static IReadOnlyList<uint> OrphanPhoneAppJobClasses
    {
        get
        {
            EnsureLoaded();
            lock (Sync)
            {
                if (_orphanAppJobClasses is not null)
                    return _orphanAppJobClasses;

                var held = new HashSet<uint>();
                foreach (var spirit in _spirits.Values)
                    foreach (var cls in EffectiveJobClasses(spirit))
                        held.Add(cls);

                var referenced = new SortedSet<uint>();
                foreach (var app in _apps.Values)
                    foreach (var cls in app.JobClassIds)
                        if (!held.Contains(cls))
                            referenced.Add(cls);

                _orphanAppJobClasses = [.. referenced];
                return _orphanAppJobClasses;
            }
        }
    }

    
    internal static IReadOnlyList<FightStyleRow> ExclusiveFightStyles(uint spiritId)
    {
        EnsureLoaded();
        lock (Sync)
            return _stylesBySpirit.TryGetValue(spiritId, out var v) ? v : [];
    }

    internal static IReadOnlyList<FightStyleRow> AllFightStyles
    {
        get { EnsureLoaded(); lock (Sync) return _allStyles; }
    }

    
    internal static IReadOnlyList<CharacteristicRow> Characteristics(uint spiritId)
    {
        EnsureLoaded();
        lock (Sync)
            return _charsBySpirit.TryGetValue(spiritId, out var v) ? v : [];
    }

    internal static IReadOnlyList<CharacteristicRow> AllCharacteristics
    {
        get { EnsureLoaded(); lock (Sync) return _allChars; }
    }

    internal static IReadOnlyList<MobileAppRow> AllApps
    {
        get { EnsureLoaded(); lock (Sync) return _apps.Values.OrderBy(x => x.Id).ToArray(); }
    }

    internal static MobileAppRow? App(uint appId)
    {
        EnsureLoaded();
        lock (Sync)
            return _apps.TryGetValue(appId, out var v) ? v : null;
    }

    
    internal static IReadOnlyList<uint> AutoDownloadAppIds
    {
        get { EnsureLoaded(); lock (Sync) return _autoDownloadApps; }
    }

    
    
    
    
    internal static IReadOnlyList<MobileAppRow> AppsForSpirit(uint spiritId)
    {
        EnsureLoaded();
        var spirit = Spirit(spiritId);
        if (spirit is null)
            return [];

        var jobClasses = EffectiveJobClasses(spirit);
        lock (Sync)
            return _apps.Values
                .Where(a => a.IsExclusive
                    && ((spirit.NpcCultivationId != 0 && a.NpcCultivationIds.Contains(spirit.NpcCultivationId))
                        || (jobClasses.Count > 0 && a.JobClassIds.Any(jobClasses.Contains))))
                .OrderBy(a => a.Id)
                .ToArray();
    }

    internal static JobLevelRow? JobLevel(uint jobId)
    {
        EnsureLoaded();
        lock (Sync)
            return _jobLevels.TryGetValue(jobId, out var v) ? v : null;
    }

    internal static JobClassRow? JobClass(uint classId)
    {
        EnsureLoaded();
        lock (Sync)
            return _jobClasses.TryGetValue(classId, out var v) ? v : null;
    }

    internal static IReadOnlyList<JobClassRow> AllJobClasses
    {
        get { EnsureLoaded(); lock (Sync) return _jobClasses.Values.OrderBy(x => x.Id).ToArray(); }
    }

    
    internal static IReadOnlyList<JobLevelRow> AllJobLevels
    {
        get { EnsureLoaded(); lock (Sync) return _jobLevels.Values.OrderBy(x => x.Id).ToArray(); }
    }

    
    internal static uint EntryJobLevelOf(uint jobClassId)
    {
        EnsureLoaded();
        lock (Sync)
            return _jobLevels.Values
                .Where(x => x.JobClass == jobClassId && x.PreJob == 0)
                .OrderBy(x => x.Level)
                .ThenBy(x => x.Id)
                .Select(x => x.Id)
                .FirstOrDefault();
    }

    
    internal static uint DefaultJobId(SpiritRow spirit)
        => spirit.DefaultUrbanJob is 0 or 100 ? 0u : spirit.DefaultUrbanJob;

    

    
    internal static IReadOnlyList<JobLevelConfigRow> JobLevelConfigs(uint jobClassId)
    {
        EnsureLoaded();
        lock (Sync)
            return _jobLevelConfigs.TryGetValue(jobClassId, out var v) ? v : [];
    }

    
    
    
    
    
    
    
    
    internal static uint MaxJobLevelOf(uint jobClassId)
    {
        EnsureLoaded();
        lock (Sync)
        {
            if (_jobLevelConfigs.TryGetValue(jobClassId, out var rows) && rows.Count > 0)
                return rows.Max(x => x.Level);

            var tiers = _jobLevels.Values.Where(x => x.JobClass == jobClassId).ToArray();
            return tiers.Length == 0 ? 0u : tiers.Max(x => x.Level);
        }
    }

    
    internal static uint JobLevelExpOf(uint jobClassId, uint level)
    {
        EnsureLoaded();
        lock (Sync)
        {
            if (!_jobLevelConfigs.TryGetValue(jobClassId, out var rows))
                return 0;
            foreach (var row in rows)
                if (row.Level == level)
                    return row.Exp;
            return 0;
        }
    }

    
    
    
    
    
    
    
    internal static uint TopJobLevelOf(uint jobClassId)
    {
        EnsureLoaded();
        lock (Sync)
            return _jobLevels.Values
                .Where(x => x.JobClass == jobClassId)
                .OrderBy(x => x.Level)
                .ThenBy(x => x.Id)
                .Select(x => x.Id)
                .LastOrDefault();
    }

    
    
    
    internal static IReadOnlyList<JobLevelRow> JobLevelChain(uint jobClassId)
    {
        EnsureLoaded();
        lock (Sync)
            return [.. _jobLevels.Values
                .Where(x => x.JobClass == jobClassId)
                .OrderBy(x => x.Level)
                .ThenBy(x => x.Id)];
    }

    

    
    internal static IReadOnlyList<TalentNodeRow> AllTalentNodes
    {
        get { EnsureLoaded(); lock (Sync) return _allTalentNodes; }
    }

    
    internal static IReadOnlyList<UrbanAbilityRow> AllUrbanAbilities
    {
        get { EnsureLoaded(); lock (Sync) return _urbanAbilities; }
    }

    
    
    
    
    internal static int UrbanAttributeCount
    {
        get { EnsureLoaded(); lock (Sync) return _urbanAttributeCount; }
    }

    
    
    
    internal static int UrbanAttributeMaxValue
    {
        get { EnsureLoaded(); lock (Sync) return _urbanAttributeMax; }
    }

    
    internal static IReadOnlyList<JobBoardRow> JobBoard
    {
        get { EnsureLoaded(); lock (Sync) return _jobBoard; }
    }

    internal static IReadOnlyList<SpiritTalentRow> SpiritTalents(uint spiritId)
    {
        EnsureLoaded();
        lock (Sync)
            return _spiritTalents.TryGetValue(spiritId, out var v) ? v : [];
    }

    internal static SpiritTalentEffectRow? SpiritTalentEffect(uint talentId)
    {
        EnsureLoaded();
        lock (Sync)
            return _talentEffects.TryGetValue(talentId, out var v) ? v : null;
    }

    internal static SpiritTalentUnlockRow? SpiritTalentUnlock(uint talentId)
    {
        EnsureLoaded();
        lock (Sync)
            return _talentUnlocks.TryGetValue(talentId, out var v) ? v : null;
    }

    internal static IReadOnlyList<TalentTreeRow> AllTalentTrees
    {
        get { EnsureLoaded(); lock (Sync) return _talentTrees; }
    }

    
    internal static IReadOnlyList<TalentTreeRow> TalentTreesFor(uint spiritId)
    {
        EnsureLoaded();
        var spirit = Spirit(spiritId);
        var jobClass = spirit is null ? 0u : DefaultJobClass(spirit);
        lock (Sync)
            return _talentTrees
                .Where(t => t.SpiritIds.Contains(spiritId) || (jobClass != 0 && t.JobClassId == jobClass))
                .OrderBy(t => t.TabIndex)
                .ThenBy(t => t.Id)
                .ToArray();
    }

    internal static IReadOnlyList<TalentNodeRow> TalentNodes(uint treeId)
    {
        EnsureLoaded();
        lock (Sync)
            return _talentNodesByTree.TryGetValue(treeId, out var v) ? v : [];
    }

    internal static IReadOnlyList<TalentLevelRow> AllTalentLevels
    {
        get { EnsureLoaded(); lock (Sync) return _talentLevels.Values.OrderBy(x => x.Id).ToArray(); }
    }

    

    
    
    
    
    
    
    
    
    
    
    
    
    internal static IReadOnlyList<uint> AvatarJobIds(uint spiritId)
    {
        EnsureLoaded();
        lock (Sync)
            return _avatarJobsBySpirit.TryGetValue(spiritId, out var v) ? v : [];
    }

    
    
    
    internal static IReadOnlyList<uint> EffectiveJobIds(SpiritRow spirit)
    {
        var ids = new SortedSet<uint>();
        var defaultJob = DefaultJobId(spirit);
        if (defaultJob != 0)
            ids.Add(defaultJob);
        foreach (var jobId in AvatarJobIds(spirit.Id))
            if (JobLevel(jobId) is not null)
                ids.Add(jobId);
        return [.. ids];
    }

    
    internal static IReadOnlyList<uint> EffectiveJobClasses(SpiritRow spirit)
    {
        var classes = new SortedSet<uint>();
        foreach (var jobId in EffectiveJobIds(spirit))
        {
            var cls = JobLevel(jobId)?.JobClass ?? 0u;
            if (cls != 0)
                classes.Add(cls);
        }
        return [.. classes];
    }

    
    
    
    
    internal static uint DefaultJobClass(SpiritRow spirit)
    {
        var byDefault = JobLevel(spirit.DefaultUrbanJob)?.JobClass ?? 0u;
        if (byDefault != 0)
            return byDefault;
        var classes = EffectiveJobClasses(spirit);
        return classes.Count > 0 ? classes[0] : 0u;
    }

    

    
    internal static IReadOnlyList<FakeFileRow> FakeFilesForSpirit(uint spiritId)
    {
        EnsureLoaded();
        lock (Sync)
            return _fakeFilesBySpirit.TryGetValue(spiritId, out var v) ? v : [];
    }

    
    internal static IReadOnlyList<uint> FakeFileSpiritIds
    {
        get { EnsureLoaded(); lock (Sync) return _fakeFilesBySpirit.Keys.OrderBy(x => x).ToArray(); }
    }

    
    internal static IReadOnlyList<HackerPostRow> AllHackerPosts
    {
        get { EnsureLoaded(); lock (Sync) return _hackerPosts; }
    }

    
    internal static string Summary()
    {
        EnsureLoaded();
        lock (Sync)
            return $"spirits={_spirits.Count} styles={_allStyles.Count} "
                + $"characteristics={_allChars.Count} apps={_apps.Count}(auto={_autoDownloadApps.Count}) "
                + $"jobLevels={_jobLevels.Count} jobClasses={_jobClasses.Count} "
                + $"spiritTalents={_spiritTalents.Count} talentEffects={_talentEffects.Count} "
                + $"talentTrees={_talentTrees.Count} talentNodes={_talentNodesByTree.Sum(kv => kv.Value.Count)} "
                + $"avatarJobs={_avatarJobsBySpirit.Count} fakeFiles={_fakeFilesBySpirit.Values.Sum(v => v.Count)}"
                + $"({_fakeFilesBySpirit.Count}角色) hackerPosts={_hackerPosts.Count} "
                + $"jobLevelConfigs={_jobLevelConfigs.Values.Sum(v => v.Count)}({_jobLevelConfigs.Count}类) "
                + $"allTalentNodes={_allTalentNodes.Count} urbanAbilities={_urbanAbilities.Count} "
                + $"urbanAttr={_urbanAttributeCount}(max={_urbanAttributeMax}) jobBoard={_jobBoard.Count}";
    }

    

    private static void EnsureLoaded()
    {
        if (_loaded)
            return;
        lock (Sync)
        {
            if (_loaded)
                return;
            try
            {
                var config = PrivateServerConfigStore.Current;
                var root = PrivateServerConfigStore.ResolveProjectPath(config.Paths.ClientConfigs);

                LoadSpirits(root);
                LoadFightStyles(root);
                LoadCharacteristics(root);
                LoadApps(root);
                LoadJobs(root);
                LoadSpiritTalents(root);
                LoadTalentTrees(root);
                LoadAvatarJobs(root);
                LoadFakeFiles(root);
                LoadHackerPosts(root);
                LoadUrbanAbilities(root);

                _loaded = true;
                Console.WriteLine($"[SPIRITCONTENT] 角色专属内容已载入: {Summary()} 来自 {root}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SPIRITCONTENT] 载入角色专属内容失败: {ex.Message}");
            }
        }
    }

    private static void LoadSpirits(string root)
    {
        ForEachRecord(root, "FightSpiritConfig.json", row =>
        {
            var id = ReadUInt32(row, "Id");
            if (id == 0)
                return;
            _spirits[id] = new SpiritRow(
                id,
                ReadString(row, "Name") ?? string.Empty,
                ReadUInt32(row, "NpcCultivationRelatedId"),
                ReadUInt32(row, "DefaultUrbanJob"),
                ReadUIntArray(row, "InitFightSkillSetting"),
                ReadBool(row, "UnlockUniqueSkill"),
                ReadUInt32(row, "TalentId"),
                ReadUInt32(row, "CommonTalentLevel"),
                ReadUInt32(row, "CommonTalentPoint"),
                ReadUInt32(row, "PassiveSkill"),
                ReadAbilityArray(row, "DefaultUrbanAbility"),
                ReadUIntArray(row, "UrbanBuff"),
                ReadStringArray(row, "UrbanBuffTag"),
                ReadBool(row, "CanJoin", true),
                ReadBool(row, "Invisible"),
                ReadIntArray(row, "UrbanAttribute"));
        });
    }

    private static void LoadFightStyles(string root)
    {
        ForEachRecord(root, "FightSkillConfig.json", row =>
        {
            var id = ReadUInt32(row, "Id");
            if (id == 0)
                return;
            var entry = new FightStyleRow(
                id,
                ReadString(row, "Name") ?? string.Empty,
                ReadUInt32(row, "FightSkillType"),
                ReadInt32(row, "Quality"),
                ReadUIntArray(row, "SpiritId"),
                ReadBool(row, "IsLocked"),
                ReadBool(row, "IsShowInArmony"),
                ReadString(row, "SourceDesc") ?? string.Empty,
                ReadString(row, "SimpleDesc") ?? string.Empty,
                ReadString(row, "DetailDesc") ?? string.Empty,
                ReadUInt32(row, "UniqueSkill"),
                ReadUInt32(row, "ActiveSkill"),
                ReadUInt32(row, "CommonSkill"));
            _allStyles.Add(entry);
            foreach (var spiritId in entry.SpiritIds)
            {
                if (!_stylesBySpirit.TryGetValue(spiritId, out var list))
                    _stylesBySpirit[spiritId] = list = [];
                list.Add(entry);
            }
        });
        _allStyles = [.. _allStyles.OrderBy(x => x.Id)];
    }

    private static void LoadCharacteristics(string root)
    {
        ForEachRecord(root, "FightSpiritCharacteristicConfig.json", row =>
        {
            var id = ReadUInt32(row, "Id");
            if (id == 0)
                return;
            var entry = new CharacteristicRow(
                id,
                ReadUIntArray(row, "FightSpiritId"),
                ReadString(row, "Name") ?? string.Empty,
                ReadString(row, "Description") ?? string.Empty,
                ReadInt32(row, "Quality"),
                ReadUInt32(row, "Image"),
                ReadString(row, "Notes") ?? string.Empty);
            _allChars.Add(entry);
            foreach (var spiritId in entry.SpiritIds)
            {
                if (!_charsBySpirit.TryGetValue(spiritId, out var list))
                    _charsBySpirit[spiritId] = list = [];
                list.Add(entry);
            }
        });
        _allChars = [.. _allChars.OrderBy(x => x.Id)];
    }

    private static void LoadApps(string root)
    {
        ForEachRecord(root, "MobileMenuSGuiConfig.json", row =>
        {
            var id = ReadUInt32(row, "Id");
            if (id == 0)
                return;
            _apps[id] = new MobileAppRow(
                id,
                ReadString(row, "Name") ?? string.Empty,
                ReadBool(row, "IsInAppStore"),
                ReadBool(row, "IsShow"),
                ReadBool(row, "IsLoading"),
                ReadUIntArray(row, "SystemIdList"),
                ReadString(row, "GuideId") ?? string.Empty,
                ReadUIntArray(row, "NpcCultivationIdList"),
                ReadUIntArray(row, "LockNpcCultivationIdList"),
                ReadUIntArray(row, "RelatedTaskIdList"),
                ReadUIntArray(row, "JobClassIdList"),
                ReadUInt32(row, "RedDotId"),
                ReadBool(row, "TeleportHide"),
                ReadString(row, "Slogen") ?? string.Empty,
                ReadString(row, "Description") ?? string.Empty);
        });

        var auto = new List<uint>();
        ForEachRecord(root, "MobileMenuAppStoreMainConfig.json", row =>
        {
            if (!ReadBool(row, "IsAutoDownload"))
                return;
            var appId = ReadUInt32(row, "AppId");
            if (appId != 0 && !auto.Contains(appId))
                auto.Add(appId);
        });
        _autoDownloadApps = [.. auto.OrderBy(x => x)];
    }

    
    
    
    
    
    
    private static void LoadAvatarJobs(string root)
    {
        ForEachRecord(root, "UrbanJobAvatarConfig.json", row =>
        {
            var spiritId = ReadUInt32(row, "SpiritId");
            if (spiritId == 0)
                return;

            var jobs = new List<uint>();
            foreach (var prop in row.EnumerateObject())
            {
                if (!prop.Name.StartsWith("Avatar", StringComparison.Ordinal))
                    continue;
                var suffix = prop.Name["Avatar".Length..];
                if (!uint.TryParse(suffix, out var jobId) || jobId == 0)
                    continue;
                if (prop.Value.ValueKind != JsonValueKind.Number || !prop.Value.TryGetUInt32(out var avatarId))
                    continue;
                if (avatarId != 0 && !jobs.Contains(jobId))
                    jobs.Add(jobId);
            }

            if (jobs.Count > 0)
                _avatarJobsBySpirit[spiritId] = [.. jobs.OrderBy(x => x)];
        });
    }

    
    
    
    
    private static void LoadFakeFiles(string root)
    {
        ForEachRecord(root, "PoliceFakeFileConfig.json", row =>
        {
            var id = ReadUInt32(row, "Id");
            var spiritId = ReadUInt32(row, "FightSpiritId");
            if (id == 0 || spiritId == 0)
                return;

            if (!_fakeFilesBySpirit.TryGetValue(spiritId, out var list))
                _fakeFilesBySpirit[spiritId] = list = [];

            list.Add(new FakeFileRow(
                id,
                spiritId,
                ReadUInt32(row, "AgentId"),
                ReadString(row, "Desc") ?? string.Empty,
                ReadString(row, "Group") ?? string.Empty,
                
                ReadUInt32(row, "MaxProgress"),
                
                
                ReadBool(row, "NeedActive") ? 1u : 0u));
        });

        foreach (var (spiritId, list) in _fakeFilesBySpirit.ToArray())
            _fakeFilesBySpirit[spiritId] = [.. list.OrderBy(x => x.Id)];
    }

    
    private static void LoadHackerPosts(string root)
    {
        var posts = new List<HackerPostRow>();
        ForEachRecord(root, "HackerPostConfig.json", row =>
        {
            var id = ReadUInt32(row, "Id");
            if (id == 0)
                return;
            posts.Add(new HackerPostRow(
                id,
                ReadUInt32(row, "PostType"),
                ReadString(row, "Title") ?? string.Empty,
                ReadString(row, "Name") ?? string.Empty));
        });
        _hackerPosts = [.. posts.OrderBy(x => x.Id)];
    }

    private static void LoadJobs(string root)
    {
        ForEachRecord(root, "UrbanJobConfig.json", row =>
        {
            var id = ReadUInt32(row, "Id");
            if (id == 0)
                return;
            _jobLevels[id] = new JobLevelRow(
                id,
                ReadString(row, "Name") ?? string.Empty,
                ReadUInt32(row, "PreJob"),
                ReadUInt32(row, "Level"),
                ReadUInt32(row, "JobClass"),
                ReadUInt32(row, "PromoteTask"),
                ReadUInt32(row, "Cost"));
        });

        ForEachRecord(root, "UrbanJobJobClassConfig.json", row =>
        {
            var id = ReadUInt32(row, "Id");
            if (id == 0)
                return;
            _jobClasses[id] = new JobClassRow(
                id,
                ReadString(row, "ClassName") ?? string.Empty,
                ReadUInt32(row, "SystemUnlock"),
                ReadBool(row, "ActiveTask"));
        });

        
        
        
        ForEachRecord(root, "UrbanJobLevelConfig.json", row =>
        {
            var classId = ReadUInt32(row, "JobClassId");
            if (classId == 0)
                return;
            if (!_jobLevelConfigs.TryGetValue(classId, out var list))
                _jobLevelConfigs[classId] = list = [];
            list.Add(new JobLevelConfigRow(
                ReadUInt32(row, "Id"),
                classId,
                ReadUInt32(row, "Level"),
                ReadUInt32(row, "Exp")));
        });

        foreach (var (classId, list) in _jobLevelConfigs.ToArray())
            _jobLevelConfigs[classId] = [.. list.OrderBy(x => x.Level).ThenBy(x => x.Id)];
    }

    
    private static void LoadUrbanAbilities(string root)
    {
        var list = new List<UrbanAbilityRow>();
        ForEachRecord(root, "UrbanAbilityConfig.json", row =>
        {
            var id = ReadUInt32(row, "Id");
            if (id == 0)
                return;
            list.Add(new UrbanAbilityRow(
                id,
                ReadString(row, "Name") ?? string.Empty,
                ReadUInt32(row, "Type"),
                ReadUInt32(row, "AbilityType"),
                ReadUInt32(row, "MaxLevel"),
                ReadUInt32(row, "InitBuffId")));
        });
        _urbanAbilities = [.. list.OrderBy(x => x.Id)];

        
        var attrCount = 0;
        var attrMax = 0;
        ForEachRecord(root, "UrbanAttributeConfig.json", row =>
        {
            if (ReadUInt32(row, "Id") == 0)
                return;
            attrCount++;
            attrMax = Math.Max(attrMax, ReadInt32(row, "MaxValue"));
        });
        _urbanAttributeCount = attrCount;
        _urbanAttributeMax = attrMax > 0 ? attrMax : 100;

        
        var board = new List<JobBoardRow>();
        ForEachRecord(root, "UrbanJobJobBoardConfig.json", row =>
        {
            var id = ReadUInt32(row, "Id");
            if (id == 0)
                return;
            board.Add(new JobBoardRow(
                id,
                ReadUInt32(row, "JobId"),
                ReadString(row, "JobTitle") ?? string.Empty,
                ReadString(row, "JobDescription") ?? string.Empty,
                ReadUInt32(row, "Salary"),
                ReadUIntArray(row, "JobTags"),
                ReadUInt32(row, "RelatedTask"),
                ReadBool(row, "CanResign"),
                ReadUInt32(row, "UnlockProgress"),
                ReadInt32(row, "SortOrder")));
        });
        _jobBoard = [.. board.OrderBy(x => x.SortOrder).ThenBy(x => x.Id)];
    }

    private static void LoadSpiritTalents(string root)
    {
        ForEachRecord(root, "SpiritTalentConfig.json", row =>
        {
            var spiritId = ReadUInt32(row, "SpiritId");
            if (spiritId == 0)
                return;
            var entry = new SpiritTalentRow(ReadUInt32(row, "Id"), spiritId, ReadUIntArray(row, "TalentId"));
            if (!_spiritTalents.TryGetValue(spiritId, out var list))
                _spiritTalents[spiritId] = list = [];
            list.Add(entry);
        });

        ForEachRecord(root, "SpiritTalentEffectConfig.json", row =>
        {
            var id = ReadUInt32(row, "Id");
            if (id == 0)
                return;
            _talentEffects[id] = new SpiritTalentEffectRow(
                id,
                ReadInt32(row, "TalentType"),
                ReadString(row, "Title") ?? string.Empty,
                ReadUIntArray(row, "BuffId"),
                ReadString(row, "BuffDescribe") ?? string.Empty,
                ReadSingle(row, "SpecialBuffValue"),
                ReadInt32(row, "AttributeRollInt"),
                ReadUIntArray(row, "AttributeRollPool"));
        });

        ForEachRecord(root, "SpiritTalentUnlockIdConfig.json", row =>
        {
            var id = ReadUInt32(row, "Id");
            if (id == 0)
                return;
            _talentUnlocks[id] = new SpiritTalentUnlockRow(
                id,
                ReadUInt32(row, "CostMoney"),
                ReadUInt32(row, "UnlockWorldLevel"));
        });
    }

    private static void LoadTalentTrees(string root)
    {
        ForEachRecord(root, "TalentTreeConfig.json", row =>
        {
            var id = ReadUInt32(row, "Id");
            if (id == 0)
                return;
            _talentTrees.Add(new TalentTreeRow(
                id,
                ReadString(row, "Name") ?? string.Empty,
                ReadInt32(row, "TabIndex"),
                ReadUIntArray(row, "SpiritId"),
                ReadUInt32(row, "JobClassId"),
                ReadUInt32(row, "GameplayId"),
                ReadUIntArray(row, "SystemIdList"),
                ReadInt32(row, "TreeType"),
                ReadBool(row, "EnableReset"),
                ReadString(row, "Tag") ?? string.Empty));
        });
        _talentTrees = [.. _talentTrees.OrderBy(x => x.TabIndex).ThenBy(x => x.Id)];

        ForEachRecord(root, "TalentTreeTalentConfig.json", row =>
        {
            var id = ReadUInt32(row, "Id");
            if (id == 0)
                return;
            var entry = new TalentNodeRow(
                id,
                ReadString(row, "Name") ?? string.Empty,
                ReadUIntArray(row, "TalentTreeid"),
                ReadUIntArray(row, "PreTalentIds"),
                ReadUInt32(row, "CostPoint"),
                ReadUInt32(row, "JobRequest"),
                ReadBool(row, "IsOrigin"),
                ReadInt32(row, "LayerNum"),
                ReadUIntArray(row, "SpiritIdList"),
                ReadUIntArray(row, "Buff"));
            foreach (var treeId in entry.TreeIds)
            {
                if (!_talentNodesByTree.TryGetValue(treeId, out var list))
                    _talentNodesByTree[treeId] = list = [];
                list.Add(entry);
            }
            _allTalentNodes.Add(entry);
        });
        _allTalentNodes = [.. _allTalentNodes.OrderBy(x => x.Id)];

        ForEachRecord(root, "TalentTreeLevelConfig.json", row =>
        {
            var id = ReadUInt32(row, "Id");
            if (id == 0)
                return;
            _talentLevels[id] = new TalentLevelRow(
                id,
                ReadUInt32(row, "Exp"),
                ReadUInt32(row, "GainTalentPoint"),
                ReadUInt32(row, "Fan"));
        });
    }

    

    
    
    
    
    
    
    
    private static void ForEachRecord(string root, string fileName, Action<JsonElement> visit)
    {
        var path = Path.Combine(root, fileName);
        if (!File.Exists(path))
        {
            Console.WriteLine($"[SPIRITCONTENT] 缺少配置 {fileName}（角色专属内容会不完整）");
            return;
        }

        try
        {
            using var document = JsonDocument.Parse(File.ReadAllText(path));
            if (!document.RootElement.TryGetProperty("records", out var records) ||
                records.ValueKind != JsonValueKind.Array)
            {
                Console.WriteLine($"[SPIRITCONTENT] {fileName} 没有 records 数组");
                return;
            }

            foreach (var row in records.EnumerateArray())
            {
                if (row.ValueKind != JsonValueKind.Object)
                    continue;
                visit(row);
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[SPIRITCONTENT] 读取 {fileName} 失败: {ex.Message}");
        }
    }

    private static string? ReadString(JsonElement row, string name)
    {
        if (!row.TryGetProperty(name, out var node))
            return null;
        return node.ValueKind switch
        {
            JsonValueKind.String => node.GetString(),
            JsonValueKind.Number => node.ToString(),
            _ => null,
        };
    }

    private static string[] ReadStringArray(JsonElement row, string name)
    {
        if (!row.TryGetProperty(name, out var node) || node.ValueKind != JsonValueKind.Array)
            return [];
        return node.EnumerateArray()
            .Where(x => x.ValueKind == JsonValueKind.String)
            .Select(x => x.GetString() ?? string.Empty)
            .ToArray();
    }

    private static int ReadInt32(JsonElement row, string name)
        => row.TryGetProperty(name, out var node) && node.TryGetInt32(out var v) ? v : 0;

    
    
    
    
    private static int[] ReadIntArray(JsonElement row, string name)
    {
        if (!row.TryGetProperty(name, out var node) || node.ValueKind != JsonValueKind.Array)
            return [];
        var list = new List<int>();
        foreach (var item in node.EnumerateArray())
            if (item.ValueKind == JsonValueKind.Number && item.TryGetInt32(out var v))
                list.Add(v);
        return [.. list];
    }

    private static uint ReadUInt32(JsonElement row, string name)
        => row.TryGetProperty(name, out var node) && node.TryGetUInt32(out var v) ? v : 0u;

    private static float ReadSingle(JsonElement row, string name)
        => row.TryGetProperty(name, out var node) && node.TryGetSingle(out var v) ? v : 0f;

    private static bool ReadBool(JsonElement row, string name, bool fallback = false)
        => row.TryGetProperty(name, out var node) && node.ValueKind is JsonValueKind.True or JsonValueKind.False
            ? node.GetBoolean()
            : fallback;

    private static uint[] ReadUIntArray(JsonElement row, string name)
    {
        if (!row.TryGetProperty(name, out var node) || node.ValueKind != JsonValueKind.Array)
            return [];
        return node.EnumerateArray()
            .Where(x => x.TryGetUInt32(out _))
            .Select(x => x.GetUInt32())
            .ToArray();
    }

    
    private static (uint AbilityId, int Value)[] ReadAbilityArray(JsonElement row, string name)
    {
        if (!row.TryGetProperty(name, out var node) || node.ValueKind != JsonValueKind.Array)
            return [];
        var list = new List<(uint, int)>();
        foreach (var item in node.EnumerateArray())
        {
            if (item.ValueKind != JsonValueKind.Object)
                continue;
            var abilityId = item.TryGetProperty("urbanAbilityId", out var a) && a.TryGetUInt32(out var av) ? av : 0u;
            var value = item.TryGetProperty("value", out var v) && v.TryGetInt32(out var vv) ? vv : 0;
            if (abilityId != 0)
                list.Add((abilityId, value));
        }
        return [.. list];
    }
}
