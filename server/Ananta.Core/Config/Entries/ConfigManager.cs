using System.IO;
using System.Text;
using System.Text.Json;

namespace AnantaTestGameServer.Configs
{
    public static class ConfigManager
    {
        private static string _configDir = "";
        public static bool IsLoaded { get; private set; }

        // Diagnostics properties (moved from ClientToGameserver to avoid cross-project dependency)
        public static string _lastDiagConfigDir = "";
        public static string LastVehicleLoadError = "";

        private static readonly JsonSerializerOptions JsonOptions = new()
        {
            PropertyNameCaseInsensitive = true,
            AllowTrailingCommas = true,
            ReadCommentHandling = JsonCommentHandling.Skip,
            NumberHandling = System.Text.Json.Serialization.JsonNumberHandling.AllowReadingFromString,
            UnknownTypeHandling = System.Text.Json.Serialization.JsonUnknownTypeHandling.JsonNode,
        };

        static ConfigManager()
        {
            JsonOptions.Converters.Add(new TolerantJsonConverterFactory());
        }

        private static Dictionary<uint, VehicleConfigEntry>? _vehicles;
        private static Dictionary<uint, WeaponConfigEntry>? _weapons;
        private static Dictionary<uint, FightSkillConfigEntry>? _fightSkills;
        private static Dictionary<uint, BuffConfigEntry>? _buffs;
        private static Dictionary<uint, AgentConfigEntry>? _agents;
        private static Dictionary<uint, FashionConfigEntry>? _fashions;
        private static Dictionary<uint, FactionConfigEntry>? _factions;
        private static Dictionary<uint, TaskConfigEntry>? _tasks;
        private static Dictionary<uint, DropConfigEntry>? _drops;
        private static Dictionary<uint, ConsumableConfigEntry>? _consumables;
        private static Dictionary<uint, GachaConfigEntry>? _gachas;
        private static Dictionary<uint, FightSpiritConfigEntry>? _fightSpirits;
        private static Dictionary<uint, HouseConfigEntry>? _houses;
        private static Dictionary<uint, AgentPersonaConfigEntry>? _agentPersonas;
        private static Dictionary<uint, AttributeNameConfigEntry>? _attributeNames;
        private static Dictionary<uint, AttributeNameSpiritAbilityConfigEntry>? _attributeNameSpiritAbilities;
        private static Dictionary<uint, SwitchSpiritConfigEntry>? _switchSpirits;
        private static Dictionary<uint, SpiritTalentConfigEntry>? _spiritTalents;
        private static Dictionary<uint, SpiritCaseConfigEntry>? _spiritCases;
        private static Dictionary<uint, UrbanAbilityConfigEntry>? _urbanAbilities;
        private static Dictionary<uint, FightSkillFightSkillTypeConfigEntry>? _fightSkillFightSkillTypes;
        private static Dictionary<uint, NpcInformationNpcConfigEntry>? _npcInformationNpcs;
        private static Dictionary<uint, ImageAvatarConfigEntry>? _imageAvatars;
        private static Dictionary<uint, SkillConfigEntry>? _skills;
        private static Dictionary<uint, UberSimOrderConfigEntry>? _uberSimOrders;
        private static Dictionary<uint, VehiclePartConfigEntry>? _vehicleParts;
        private static Dictionary<uint, VehicleBuffConfigEntry>? _vehicleBuffs;
        private static Dictionary<uint, UrbanAttributeConfigEntry>? _urbanAttributes;
        private static Dictionary<uint, WeaponFightStyleConfigEntry>? _weaponFightStyles;
        private static Dictionary<uint, FashionSuitConfigEntry>? _fashionSuits;
        private static Dictionary<uint, BattlePassConfigEntry>? _battlePasses;
        private static Dictionary<uint, TaskEventConfigEntry>? _taskEvents;

        private static readonly Dictionary<string, Dictionary<uint, JsonElement>> _genericConfigs = new();
        private static readonly HashSet<string> _loadedGeneric = new();

        private static readonly (string Name, Func<List<uint>> Loader)[] _allTypedConfigs = new (string, Func<List<uint>>)[]
        {
            ("Agent",                   GetAllAgentIds),
            ("Vehicle",                 GetAllVehicleIds),
            ("Weapon",                  GetAllWeaponIds),
            ("FightSkill",              GetAllFightSkillIds),
            ("Buff",                    GetAllBuffIds),
            ("Fashion",                 GetAllFashionIds),
            ("Faction",                 GetAllFactionIds),
            ("Task",                    GetAllTaskIds),
            ("Drop",                    GetAllDropIds),
            ("Consumable",              GetAllConsumableIds),
            ("Gacha",                   GetAllGachaIds),
            ("FightSpirit",             GetAllFightSpiritIds),
            ("House",                   GetAllHouseIds),
            ("AgentPersona",            GetAllAgentPersonaIds),
            ("AttributeName",           GetAllAttributeNameIds),
            ("AttributeNameSpiritAbility", GetAllAttributeNameSpiritAbilityIds),
            ("SwitchSpirit",            GetAllSwitchSpiritIds),
            ("SpiritTalent",            GetAllSpiritTalentIds),
            ("SpiritCase",              GetAllSpiritCaseIds),
            ("UrbanAbility",            GetAllUrbanAbilityIds),
            ("FightSkillFightSkillType",GetAllFightSkillFightSkillTypeIds),
            ("NpcInformationNpc",       GetAllNpcInformationNpcIds),
            ("ImageAvatar",             GetAllImageAvatarIds),
            ("Skill",                   GetAllSkillIds),
            ("UberSimOrder",            GetAllUberSimOrderIds),
            ("VehiclePart",             GetAllVehiclePartIds),
            ("VehicleBuff",             GetAllVehicleBuffIds),
            ("UrbanAttribute",          GetAllUrbanAttributeIds),
            ("WeaponFightStyle",        GetAllWeaponFightStyleIds),
            ("FashionSuit",             GetAllFashionSuitIds),
            ("BattlePass",              GetAllBattlePassIds),
            ("TaskEvent",               GetAllTaskEventIds),
        };

        public static (int ok, int fail) ValidateAll()
        {
            Console.WriteLine("[Config] ===== VALIDATING ALL CONFIGS =====");
            int ok = 0, fail = 0;
            int totalEntries = 0;

            foreach (var cfg in _allTypedConfigs)
            {
                try
                {
                    var ids = cfg.Loader();
                    totalEntries += ids.Count;
                    Console.WriteLine($"[Config]   {cfg.Name,32}: {ids.Count,4} entries");
                    ok++;
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[Config]   {cfg.Name,32}: FAILED - {ex.GetType().Name}: {ex.Message}");
                    fail++;
                }
            }

            Console.WriteLine($"[Config] ===== {ok}/{ok + fail} configs OK, {totalEntries} total entries =====");
            return (ok, fail);
        }

        public static void LoadAll(string configDir)
        {
            _configDir = configDir;

            if (!Directory.Exists(configDir))
            {
                string fallbackDir = Path.Combine(Environment.CurrentDirectory, "AnantaTestGameServer", "Configs");
                if (Directory.Exists(fallbackDir))
                {
                    configDir = fallbackDir;
                    _configDir = fallbackDir;
                }
                else
                {
                    fallbackDir = Path.Combine(Environment.CurrentDirectory, "Configs");
                    if (Directory.Exists(fallbackDir))
                    {
                        configDir = fallbackDir;
                        _configDir = fallbackDir;
                    }
                }
            }

            // Expose the dir for diagnostics endpoints.
            _lastDiagConfigDir = configDir;

            if (!Directory.Exists(configDir))
            {
                Console.WriteLine($"[Config] WARNING: Config directory not found: {configDir}");
                Console.WriteLine("[Config] Server will run with hardcoded values only");
                return;
            }

            string[] jsonFiles = Directory.GetFiles(configDir, "*.json");
            Console.WriteLine($"[Config] Found {jsonFiles.Length} config files in {configDir}");

            int loaded = 0;
            int failed = 0;

            foreach (string file in jsonFiles)
            {
                string fileName = Path.GetFileNameWithoutExtension(file);
                try
                {
                    _loadedGeneric.Add(fileName);
                    loaded++;
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[Config] Failed to mark {fileName}: {ex.Message}");
                    failed++;
                }
            }

            Console.WriteLine($"[Config] Marked {loaded} config files ({failed} failed)");

            ValidateAll();

            IsLoaded = true;
        }

        private static Dictionary<uint, T> LoadTyped<T>(string fileName) where T : IConfigEntry
        {
            string path = Path.Combine(_configDir, fileName);
            if (!File.Exists(path))
            {
                Console.WriteLine($"[Config] File not found: {fileName}");
                return new Dictionary<uint, T>();
            }

            try
            {
                string json = File.ReadAllText(path);
                var list = JsonSerializer.Deserialize<List<T>>(json, JsonOptions);
                if (list == null)
                {
                    Console.WriteLine($"[Config] Empty config: {fileName}");
                    return new Dictionary<uint, T>();
                }

                var dict = new Dictionary<uint, T>(list.Count);
                foreach (var item in list)
                {
                    if (!dict.TryAdd(item.Id, item))
                    {
                        Console.WriteLine($"[Config] WARNING: Duplicate Id {item.Id} in {fileName}, skipping");
                    }
                }

                Console.WriteLine($"[Config] Loaded {dict.Count} entries from {fileName}");
                return dict;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Config] Strict deserialization failed for {fileName}: {ex.GetType().Name}");
                Console.WriteLine($"[Config] Falling back to tolerant deserialization for {fileName}");
                return LoadTypedTolerant<T>(fileName, ex);
            }
        }

        private static Dictionary<uint, T> LoadTypedTolerant<T>(string fileName, Exception originalError) where T : IConfigEntry
        {
            string path = Path.Combine(_configDir, fileName);
            try
            {
                string json = File.ReadAllText(path);
                using var doc = JsonDocument.Parse(json, new JsonDocumentOptions
                {
                    CommentHandling = JsonCommentHandling.Skip,
                    AllowTrailingCommas = true,
                });

                if (doc.RootElement.ValueKind != JsonValueKind.Array)
                {
                    Console.WriteLine($"[Config] {fileName} root is not an array");
                    return new Dictionary<uint, T>();
                }

                var dict = new Dictionary<uint, T>();
                int skipped = 0;
                int loaded = 0;

                foreach (var elem in doc.RootElement.EnumerateArray())
                {
                    try
                    {
                        var rawText = elem.ToString();
                        var item = JsonSerializer.Deserialize<T>(rawText, JsonOptions);
                        if (item != null && dict.TryAdd(item.Id, item))
                            loaded++;
                        else
                            skipped++;
                    }
                    catch
                    {
                        skipped++;
                    }
                }

                Console.WriteLine($"[Config] Loaded {loaded} entries from {fileName} (tolerant, {skipped} skipped)");
                return dict;
            }
            catch (Exception ex2)
            {
                Console.WriteLine($"[Config] Failed to load {fileName}: {originalError.Message}");
                return new Dictionary<uint, T>();
            }
        }

        private static void LoadGeneric(string configName)
        {
            string path = Path.Combine(_configDir, configName + ".json");
            if (!File.Exists(path))
            {
                Console.WriteLine($"[Config] Generic file not found: {configName}");
                return;
            }

            try
            {
                using FileStream fs = File.OpenRead(path);
                var list = JsonSerializer.Deserialize<List<JsonElement>>(fs, JsonOptions);
                var dict = new Dictionary<uint, JsonElement>();

                if (list != null)
                {
                    foreach (var elem in list)
                    {
                        if (elem.TryGetProperty("Id", out var idProp) && idProp.GetUInt32() is uint id)
                            dict[id] = elem;
                    }
                }

                _genericConfigs[configName] = dict;
                Console.WriteLine($"[Config] Loaded {dict.Count} generic entries from {configName}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Config] Failed to load generic {configName}: {ex.Message}");
                _genericConfigs[configName] = new Dictionary<uint, JsonElement>();
            }
        }

        public static VehicleConfigEntry? GetVehicle(uint id)
        {
            if (_vehicles == null)
                _vehicles = LoadTyped<VehicleConfigEntry>("VehicleConfig.json");
            return _vehicles.TryGetValue(id, out var v) ? v : null;
        }

        public static WeaponConfigEntry? GetWeapon(uint id)
        {
            if (_weapons == null)
                _weapons = LoadTyped<WeaponConfigEntry>("WeaponConfig.json");
            return _weapons.TryGetValue(id, out var v) ? v : null;
        }

        public static FightSkillConfigEntry? GetFightSkill(uint id)
        {
            if (_fightSkills == null)
                _fightSkills = LoadTyped<FightSkillConfigEntry>("FightSkillConfig.json");
            return _fightSkills.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllFightSkillIds()
        {
            if (_fightSkills == null)
                _fightSkills = LoadTyped<FightSkillConfigEntry>("FightSkillConfig.json");
            return _fightSkills.Keys.OrderBy(id => id).ToList();
        }

        public static BuffConfigEntry? GetBuff(uint id)
        {
            if (_buffs == null)
                _buffs = LoadTyped<BuffConfigEntry>("BuffConfig.json");
            return _buffs.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllBuffIds()
        {
            if (_buffs == null)
                _buffs = LoadTyped<BuffConfigEntry>("BuffConfig.json");
            return _buffs.Keys.OrderBy(id => id).ToList();
        }

        public static AgentConfigEntry? GetAgent(uint id)
        {
            if (_agents == null)
                _agents = LoadTyped<AgentConfigEntry>("AgentConfig.json");
            return _agents.TryGetValue(id, out var v) ? v : null;
        }

        public static FashionConfigEntry? GetFashion(uint id)
        {
            if (_fashions == null)
                _fashions = LoadTyped<FashionConfigEntry>("FashionConfig.json");
            return _fashions.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllFashionIds()
        {
            if (_fashions == null)
                _fashions = LoadTyped<FashionConfigEntry>("FashionConfig.json");
            return _fashions.Keys.OrderBy(id => id).ToList();
        }

        public static FactionConfigEntry? GetFaction(uint id)
        {
            if (_factions == null)
                _factions = LoadTyped<FactionConfigEntry>("FactionConfig.json");
            return _factions.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllFactionIds()
        {
            if (_factions == null)
                _factions = LoadTyped<FactionConfigEntry>("FactionConfig.json");
            return _factions.Keys.OrderBy(id => id).ToList();
        }

        public static TaskConfigEntry? GetTask(uint id)
        {
            if (_tasks == null)
                _tasks = LoadTyped<TaskConfigEntry>("TaskConfig.json");
            return _tasks.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllTaskIds()
        {
            if (_tasks == null)
                _tasks = LoadTyped<TaskConfigEntry>("TaskConfig.json");
            return _tasks.Keys.OrderBy(id => id).ToList();
        }

        public static DropConfigEntry? GetDrop(uint id)
        {
            if (_drops == null)
                _drops = LoadTyped<DropConfigEntry>("DropConfig.json");
            return _drops.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllDropIds()
        {
            if (_drops == null)
                _drops = LoadTyped<DropConfigEntry>("DropConfig.json");
            return _drops.Keys.OrderBy(id => id).ToList();
        }

        public static ConsumableConfigEntry? GetConsumable(uint id)
        {
            if (_consumables == null)
                _consumables = LoadTyped<ConsumableConfigEntry>("ConsumableConfig.json");
            return _consumables.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllConsumableIds()
        {
            if (_consumables == null)
                _consumables = LoadTyped<ConsumableConfigEntry>("ConsumableConfig.json");
            return _consumables.Keys.OrderBy(id => id).ToList();
        }

        public static GachaConfigEntry? GetGacha(uint id)
        {
            if (_gachas == null)
                _gachas = LoadTyped<GachaConfigEntry>("GachaConfig.json");
            return _gachas.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllGachaIds()
        {
            if (_gachas == null)
                _gachas = LoadTyped<GachaConfigEntry>("GachaConfig.json");
            return _gachas.Keys.OrderBy(id => id).ToList();
        }

        public static FightSpiritConfigEntry? GetFightSpirit(uint id)
        {
            if (_fightSpirits == null)
                _fightSpirits = LoadTyped<FightSpiritConfigEntry>("FightSpiritConfig.json");
            return _fightSpirits.TryGetValue(id, out var v) ? v : null;
        }

        public static HouseConfigEntry? GetHouse(uint id)
        {
            if (_houses == null)
                _houses = LoadTyped<HouseConfigEntry>("HouseConfig.json");
            return _houses.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllHouseIds()
        {
            if (_houses == null)
                _houses = LoadTyped<HouseConfigEntry>("HouseConfig.json");
            return _houses.Keys.OrderBy(id => id).ToList();
        }

        public static AgentPersonaConfigEntry? GetAgentPersona(uint id)
        {
            if (_agentPersonas == null)
                _agentPersonas = LoadTyped<AgentPersonaConfigEntry>("AgentPersonaConfig.json");
            return _agentPersonas.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllAgentPersonaIds()
        {
            if (_agentPersonas == null)
                _agentPersonas = LoadTyped<AgentPersonaConfigEntry>("AgentPersonaConfig.json");
            return _agentPersonas.Keys.OrderBy(id => id).ToList();
        }

        public static AttributeNameConfigEntry? GetAttributeName(uint id)
        {
            if (_attributeNames == null)
                _attributeNames = LoadTyped<AttributeNameConfigEntry>("AttributeNameConfig.json");
            return _attributeNames.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllAttributeNameIds()
        {
            if (_attributeNames == null)
                _attributeNames = LoadTyped<AttributeNameConfigEntry>("AttributeNameConfig.json");
            return _attributeNames.Keys.OrderBy(id => id).ToList();
        }

        public static AttributeNameSpiritAbilityConfigEntry? GetAttributeNameSpiritAbility(uint id)
        {
            if (_attributeNameSpiritAbilities == null)
                _attributeNameSpiritAbilities = LoadTyped<AttributeNameSpiritAbilityConfigEntry>("AttributeNameSpiritAbilityConfig.json");
            return _attributeNameSpiritAbilities.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllAttributeNameSpiritAbilityIds()
        {
            if (_attributeNameSpiritAbilities == null)
                _attributeNameSpiritAbilities = LoadTyped<AttributeNameSpiritAbilityConfigEntry>("AttributeNameSpiritAbilityConfig.json");
            return _attributeNameSpiritAbilities.Keys.OrderBy(id => id).ToList();
        }

        public static SwitchSpiritConfigEntry? GetSwitchSpirit(uint id)
        {
            if (_switchSpirits == null)
                _switchSpirits = LoadTyped<SwitchSpiritConfigEntry>("SwitchSpiritConfig.json");
            return _switchSpirits.TryGetValue(id, out var v) ? v : null;
        }

        public static SpiritTalentConfigEntry? GetSpiritTalent(uint id)
        {
            if (_spiritTalents == null)
                _spiritTalents = LoadTyped<SpiritTalentConfigEntry>("SpiritTalentConfig.json");
            return _spiritTalents.TryGetValue(id, out var v) ? v : null;
        }

        public static SpiritCaseConfigEntry? GetSpiritCase(uint id)
        {
            if (_spiritCases == null)
                _spiritCases = LoadTyped<SpiritCaseConfigEntry>("SpiritCaseConfig.json");
            return _spiritCases.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllSpiritCaseIds()
        {
            if (_spiritCases == null)
                _spiritCases = LoadTyped<SpiritCaseConfigEntry>("SpiritCaseConfig.json");
            return _spiritCases.Keys.OrderBy(id => id).ToList();
        }

        public static UrbanAbilityConfigEntry? GetUrbanAbility(uint id)
        {
            if (_urbanAbilities == null)
                _urbanAbilities = LoadTyped<UrbanAbilityConfigEntry>("UrbanAbilityConfig.json");
            return _urbanAbilities.TryGetValue(id, out var v) ? v : null;
        }

        public static FightSkillFightSkillTypeConfigEntry? GetFightSkillFightSkillType(uint id)
        {
            if (_fightSkillFightSkillTypes == null)
                _fightSkillFightSkillTypes = LoadTyped<FightSkillFightSkillTypeConfigEntry>("FightSkillFightSkillTypeConfig.json");
            return _fightSkillFightSkillTypes.TryGetValue(id, out var v) ? v : null;
        }

        public static NpcInformationNpcConfigEntry? GetNpcInformationNpc(uint id)
        {
            if (_npcInformationNpcs == null)
                _npcInformationNpcs = LoadTyped<NpcInformationNpcConfigEntry>("NpcInformationNpcConfig.json");
            return _npcInformationNpcs.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllNpcInformationNpcIds()
        {
            if (_npcInformationNpcs == null)
                _npcInformationNpcs = LoadTyped<NpcInformationNpcConfigEntry>("NpcInformationNpcConfig.json");
            return _npcInformationNpcs.Keys.OrderBy(id => id).ToList();
        }

        public static ImageAvatarConfigEntry? GetImageAvatar(uint id)
        {
            if (_imageAvatars == null)
                _imageAvatars = LoadTyped<ImageAvatarConfigEntry>("ImageAvatarConfig.json");
            return _imageAvatars.TryGetValue(id, out var v) ? v : null;
        }

        public static JsonElement? GetConfig(string configName, uint id)
        {
            if (!_loadedGeneric.Contains(configName))
            {
                if (!File.Exists(Path.Combine(_configDir, configName + ".json")))
                    return null;
                LoadGeneric(configName);
            }

            if (_genericConfigs.TryGetValue(configName, out var dict) && dict.TryGetValue(id, out var elem))
                return elem;

            return null;
        }

        public static List<uint> GetAllVehicleIds()
        {
            bool freshlyLoaded = false;
            if (_vehicles == null)
            {
                _vehicles = LoadTyped<VehicleConfigEntry>("VehicleConfig.json");
                freshlyLoaded = true;
            }
            var keys = _vehicles.Keys.OrderBy(id => id).ToList();
            Console.WriteLine($"[Config] GetAllVehicleIds: count={keys.Count}, cached={!freshlyLoaded}");
            return keys;
        }

        public static List<uint> GetAllWeaponIds()
        {
            if (_weapons == null)
                _weapons = LoadTyped<WeaponConfigEntry>("WeaponConfig.json");
            return _weapons.Keys.OrderBy(id => id).ToList();
        }

        public static List<uint> GetAllAgentIds()
        {
            if (_agents == null)
                _agents = LoadTyped<AgentConfigEntry>("AgentConfig.json");
            return _agents.Keys.OrderBy(id => id).ToList();
        }

        public static List<uint> GetAllFightSpiritIds()
        {
            if (_fightSpirits == null)
                _fightSpirits = LoadTyped<FightSpiritConfigEntry>("FightSpiritConfig.json");
            return _fightSpirits.Keys.OrderBy(id => id).ToList();
        }

        public static List<uint> GetAllSwitchSpiritIds()
        {
            if (_switchSpirits == null)
                _switchSpirits = LoadTyped<SwitchSpiritConfigEntry>("SwitchSpiritConfig.json");
            return _switchSpirits.Keys.OrderBy(id => id).ToList();
        }

        public static List<uint> GetAllSpiritTalentIds()
        {
            if (_spiritTalents == null)
                _spiritTalents = LoadTyped<SpiritTalentConfigEntry>("SpiritTalentConfig.json");
            return _spiritTalents.Keys.OrderBy(id => id).ToList();
        }

        public static List<uint> GetAllUrbanAbilityIds()
        {
            if (_urbanAbilities == null)
                _urbanAbilities = LoadTyped<UrbanAbilityConfigEntry>("UrbanAbilityConfig.json");
            return _urbanAbilities.Keys.OrderBy(id => id).ToList();
        }

        public static List<uint> GetAllFightSkillFightSkillTypeIds()
        {
            if (_fightSkillFightSkillTypes == null)
                _fightSkillFightSkillTypes = LoadTyped<FightSkillFightSkillTypeConfigEntry>("FightSkillFightSkillTypeConfig.json");
            return _fightSkillFightSkillTypes.Keys.OrderBy(id => id).ToList();
        }

        public static List<uint> GetAllImageAvatarIds()
        {
            if (_imageAvatars == null)
                _imageAvatars = LoadTyped<ImageAvatarConfigEntry>("ImageAvatarConfig.json");
            return _imageAvatars.Keys.OrderBy(id => id).ToList();
        }

        public static SkillConfigEntry? GetSkill(uint id)
        {
            if (_skills == null)
                _skills = LoadTyped<SkillConfigEntry>("SkillConfig.json");
            return _skills.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllSkillIds()
        {
            if (_skills == null)
                _skills = LoadTyped<SkillConfigEntry>("SkillConfig.json");
            return _skills.Keys.OrderBy(id => id).ToList();
        }

        public static UberSimOrderConfigEntry? GetUberSimOrder(uint id)
        {
            if (_uberSimOrders == null)
                _uberSimOrders = LoadTyped<UberSimOrderConfigEntry>("UberSimOrderConfig.json");
            return _uberSimOrders.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllUberSimOrderIds()
        {
            if (_uberSimOrders == null)
                _uberSimOrders = LoadTyped<UberSimOrderConfigEntry>("UberSimOrderConfig.json");
            return _uberSimOrders.Keys.OrderBy(id => id).ToList();
        }

        public static VehiclePartConfigEntry? GetVehiclePart(uint id)
        {
            if (_vehicleParts == null)
                _vehicleParts = LoadTyped<VehiclePartConfigEntry>("VehiclePartConfig.json");
            return _vehicleParts.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllVehiclePartIds()
        {
            if (_vehicleParts == null)
                _vehicleParts = LoadTyped<VehiclePartConfigEntry>("VehiclePartConfig.json");
            return _vehicleParts.Keys.OrderBy(id => id).ToList();
        }

        public static VehicleBuffConfigEntry? GetVehicleBuff(uint id)
        {
            if (_vehicleBuffs == null)
                _vehicleBuffs = LoadTyped<VehicleBuffConfigEntry>("VehicleBuffConfig.json");
            return _vehicleBuffs.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllVehicleBuffIds()
        {
            if (_vehicleBuffs == null)
                _vehicleBuffs = LoadTyped<VehicleBuffConfigEntry>("VehicleBuffConfig.json");
            return _vehicleBuffs.Keys.OrderBy(id => id).ToList();
        }

        public static UrbanAttributeConfigEntry? GetUrbanAttribute(uint id)
        {
            if (_urbanAttributes == null)
                _urbanAttributes = LoadTyped<UrbanAttributeConfigEntry>("UrbanAttributeConfig.json");
            return _urbanAttributes.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllUrbanAttributeIds()
        {
            if (_urbanAttributes == null)
                _urbanAttributes = LoadTyped<UrbanAttributeConfigEntry>("UrbanAttributeConfig.json");
            return _urbanAttributes.Keys.OrderBy(id => id).ToList();
        }

        public static WeaponFightStyleConfigEntry? GetWeaponFightStyle(uint id)
        {
            if (_weaponFightStyles == null)
                _weaponFightStyles = LoadTyped<WeaponFightStyleConfigEntry>("WeaponFightStyleConfig.json");
            return _weaponFightStyles.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllWeaponFightStyleIds()
        {
            if (_weaponFightStyles == null)
                _weaponFightStyles = LoadTyped<WeaponFightStyleConfigEntry>("WeaponFightStyleConfig.json");
            return _weaponFightStyles.Keys.OrderBy(id => id).ToList();
        }

        public static FashionSuitConfigEntry? GetFashionSuit(uint id)
        {
            if (_fashionSuits == null)
                _fashionSuits = LoadTyped<FashionSuitConfigEntry>("FashionSuitConfig.json");
            return _fashionSuits.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllFashionSuitIds()
        {
            if (_fashionSuits == null)
                _fashionSuits = LoadTyped<FashionSuitConfigEntry>("FashionSuitConfig.json");
            return _fashionSuits.Keys.OrderBy(id => id).ToList();
        }

        public static BattlePassConfigEntry? GetBattlePass(uint id)
        {
            if (_battlePasses == null)
                _battlePasses = LoadTyped<BattlePassConfigEntry>("BattlePassConfig.json");
            return _battlePasses.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllBattlePassIds()
        {
            if (_battlePasses == null)
                _battlePasses = LoadTyped<BattlePassConfigEntry>("BattlePassConfig.json");
            return _battlePasses.Keys.OrderBy(id => id).ToList();
        }

        public static TaskEventConfigEntry? GetTaskEvent(uint id)
        {
            if (_taskEvents == null)
                _taskEvents = LoadTyped<TaskEventConfigEntry>("TaskEventConfig.json");
            return _taskEvents.TryGetValue(id, out var v) ? v : null;
        }

        public static List<uint> GetAllTaskEventIds()
        {
            if (_taskEvents == null)
                _taskEvents = LoadTyped<TaskEventConfigEntry>("TaskEventConfig.json");
            return _taskEvents.Keys.OrderBy(id => id).ToList();
        }
    }
}
