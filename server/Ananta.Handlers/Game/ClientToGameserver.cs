using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using AnantaTestGameServer.Configs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using UX.RPC.Protocol;
using static AnantaTestGameServer.Methods.Return.SpiritInfo;
using GangMemberInfo = AnantaTestGameServer.GangMemberInfo;
using AnantaTestGameServer.Configs;
using AnantaTestGameServer.Game;


namespace AnantaTestGameServer.Packets.Req
{
    internal partial class ClientToGameserver
    {
        public const uint MilkVehicleConfigId = 81007009;
        public const uint DefaultGmDrivableVehicleConfigId = 81001001;
        private const uint TestVehicleConfigId = DefaultGmDrivableVehicleConfigId;
        // Lazily-built list of vehicle config ids. Previously this was a `static readonly`
        // initialized at type-load time, BEFORE ConfigManager.LoadAll() ran in Server.Main(),
        // so ConfigManager.IsLoaded was always false and only MilkVehicleConfigId made the list.
        // Now rebuilt on first call after ConfigManager finishes loading, then cached.
        private static uint[]? _testVehicleConfigIdsCache;
        private static bool _testVehicleConfigIdsIncludesConfig;
        private static readonly Lazy<Dictionary<uint, string>> VehicleDisplayNames = new(LoadVehicleDisplayNames);
        private static readonly uint[] TestFashionIds = BuildTestFashionIds();
        private static readonly Dictionary<uint, SpiritWearFashionsInfo> SavedSpiritWearFashions = new();

        private static uint[] GetTestVehicleConfigIds()
        {
            // Rebuild if ConfigManager has just finished loading (cache stale), OR if the
            // CSV hasn't been loaded yet (csvLoaded flag is false).
            bool csvLoaded = _csvVehicleIds != null;
            bool needsRebuild = _testVehicleConfigIdsCache == null ||
                                !csvLoaded ||
                                (ConfigManager.IsLoaded && !_testVehicleConfigIdsIncludesConfig);
            if (!needsRebuild) return _testVehicleConfigIdsCache!;

            // 1) Load CSV IDs (authoritative community-sourced list of 152 vehicles).
            HashSet<uint> vehicleIds = new();
            if (!csvLoaded)
            {
                _csvVehicleIds = new HashSet<uint>();
                foreach (string path in GetVehicleNameCsvCandidates())
                {
                    if (!File.Exists(path)) continue;
                    foreach (string rawLine in File.ReadLines(path, Encoding.UTF8))
                    {
                        string line = rawLine.Trim();
                        if (line.Length == 0 || line.StartsWith("#", StringComparison.Ordinal)) continue;
                        string[] parts = line.Split(',', 3);
                        if (parts.Length < 2) continue;
                        if (uint.TryParse(parts[0].Trim(), out uint id))
                        {
                            vehicleIds.Add(id);
                            _csvVehicleIds.Add(id);
                        }
                    }
                    break; // first existing file wins
                }
                Console.WriteLine($"[Vehicle] CSV loaded: {_csvVehicleIds.Count} IDs from vehicle_names.csv");
            }
            else
            {
                foreach (var id in _csvVehicleIds) vehicleIds.Add(id);
            }

            // 2) Add ConfigManager IDs (defense in depth — anything not in CSV is still included).
            int fromConfig = 0;
            if (ConfigManager.IsLoaded)
            {
                try
                {
                    foreach (var id in ConfigManager.GetAllVehicleIds())
                    {
                        vehicleIds.Add(id);
                        fromConfig++;
                    }
                    _testVehicleConfigIdsIncludesConfig = true;
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[Vehicle] ConfigManager.GetAllVehicleIds() threw: {ex.Message}");
                }
            }

            // 3) Always include default + milkcar as safety net.
            vehicleIds.Add(MilkVehicleConfigId);
            vehicleIds.Add(DefaultGmDrivableVehicleConfigId);

            _testVehicleConfigIdsCache = vehicleIds.OrderBy(id => id).ToArray();
            Console.WriteLine($"[Vehicle] GetTestVehicleConfigIds REBUILD: fromCsv={_csvVehicleIds?.Count ?? 0}, fromConfig={fromConfig}, total={_testVehicleConfigIdsCache.Length}");
            return _testVehicleConfigIdsCache;
        }

        // Cache of IDs parsed from vehicle_names.csv on first access.
        private static HashSet<uint>? _csvVehicleIds;

        public static uint[] GetUnlockedVehicleConfigIds()
        {
            return GetTestVehicleConfigIds();
        }

        // Plain-text diagnostic for /gm/vehicle/diagnose — shows the raw state of the
        // vehicle id loading pipeline so the user can paste it in chat when reporting
        // "only 2 vehicle IDs appear" issues.
        public static string BuildVehicleDiagnoseReport()
        {
            var sb = new System.Text.StringBuilder();
            sb.AppendLine("=== Vehicle ID Loading Diagnostic ===");
            sb.AppendLine($"ConfigManager.IsLoaded = {AnantaTestGameServer.Configs.ConfigManager.IsLoaded}");
            sb.AppendLine($"ConfigManager._configDir = {(string.IsNullOrEmpty(_lastDiagConfigDir) ? "(not set)" : _lastDiagConfigDir)}");

            // Try to load and show the raw count.
            int rawCount = 0;
            string loadError = "(no error captured)";
            try
            {
                var ids = AnantaTestGameServer.Configs.ConfigManager.GetAllVehicleIds();
                rawCount = ids.Count;
                sb.AppendLine($"ConfigManager.GetAllVehicleIds() count = {rawCount}");
                if (rawCount > 0)
                {
                    sb.AppendLine($"First 10 IDs:");
                    for (int i = 0; i < Math.Min(10, rawCount); i++)
                        sb.AppendLine($"  [{i}] {ids[i]}");
                }
            }
            catch (Exception ex)
            {
                loadError = $"{ex.GetType().Name}: {ex.Message}";
                sb.AppendLine($"GetAllVehicleIds() THREW: {loadError}");
            }

            sb.AppendLine();
            sb.AppendLine($"LastLoadTypedError = {LastVehicleLoadError ?? "(none)"}");
            sb.AppendLine($"_testVehicleConfigIdsCache == null = {_testVehicleConfigIdsCache == null}");
            sb.AppendLine($"_testVehicleConfigIdsIncludesConfig = {_testVehicleConfigIdsIncludesConfig}");
            sb.AppendLine($"GetTestVehicleConfigIds().Length = {GetTestVehicleConfigIds().Length}");

            // Check the physical file
            string vehicleConfigPath = System.IO.Path.Combine(
                _lastDiagConfigDir ?? "", "VehicleConfig.json");
            if (string.IsNullOrEmpty(_lastDiagConfigDir))
            {
                sb.AppendLine("VehicleConfig.json path: (ConfigManager configDir not set)");
            }
            else
            {
                sb.AppendLine($"VehicleConfig.json path: {vehicleConfigPath}");
                sb.AppendLine($"  File exists: {System.IO.File.Exists(vehicleConfigPath)}");
                if (System.IO.File.Exists(vehicleConfigPath))
                {
                    var info = new System.IO.FileInfo(vehicleConfigPath);
                    sb.AppendLine($"  File size: {info.Length} bytes");
                }
            }
            return sb.ToString();
        }

        // Populated by ConfigManager on LoadAll() so the diagnostic can show the path.
        internal static string? _lastDiagConfigDir = null;
        internal static string? LastVehicleLoadError = null;

        public static string GetVehicleDisplayName(uint vehicleConfigId)
        {
            return VehicleDisplayNames.Value.TryGetValue(vehicleConfigId, out string? displayName)
                ? displayName
                : GetVehicleSeriesDisplayName(vehicleConfigId);
        }

        private static Dictionary<uint, string> LoadVehicleDisplayNames()
        {
            Dictionary<uint, string> names = new()
            {
                [DefaultGmDrivableVehicleConfigId] = "默认可驾驶候选",
                [MilkVehicleConfigId] = "milkcar / 换装车"
            };

            foreach (string path in GetVehicleNameCsvCandidates())
            {
                if (!File.Exists(path))
                    continue;

                foreach (string rawLine in File.ReadLines(path, Encoding.UTF8))
                {
                    string line = rawLine.Trim();
                    if (line.Length == 0 || line.StartsWith("#", StringComparison.Ordinal))
                        continue;

                    string[] parts = line.Split(',', 3);
                    if (parts.Length < 2 || parts[0].Equals("vehicle_config_id", StringComparison.OrdinalIgnoreCase))
                        continue;

                    if (uint.TryParse(parts[0].Trim(), out uint vehicleConfigId))
                    {
                        string displayName = parts[1].Trim();
                        if (!string.IsNullOrWhiteSpace(displayName))
                        {
                            names[vehicleConfigId] = displayName;
                        }
                    }
                }
            }

            return names;
        }

        private static IEnumerable<string> GetVehicleNameCsvCandidates()
        {
            yield return Path.Combine(AppContext.BaseDirectory, "vehicle_names.csv");
            yield return Path.Combine(Environment.CurrentDirectory, "vehicle_names.csv");
            yield return Path.Combine(Environment.CurrentDirectory, "AnantaTestGameServer", "vehicle_names.csv");
            yield return Path.Combine(Environment.CurrentDirectory, "AnantaTestGameServer", "AnantaTestGameServer", "vehicle_names.csv");
        }

        private static string GetVehicleSeriesDisplayName(uint vehicleConfigId)
        {
            return vehicleConfigId switch
            {
                >= 81000000 and < 81001000 => "特殊/测试载具",
                >= 81001000 and < 81002000 => "810010 系列 / 未命名载具",
                >= 81002000 and < 81003000 => "810020 系列 / 未命名载具",
                >= 81003000 and < 81004000 => "810030 系列 / 未命名载具",
                >= 81004000 and < 81005000 => "810040 系列 / 未命名载具",
                >= 81005000 and < 81006000 => "810050 系列 / 未命名载具",
                >= 81006000 and < 81007000 => "810060 系列 / 未命名载具",
                >= 81007000 and < 81008000 => "810070 系列 / 功能或特殊载具",
                _ => "未命名载具"
            };
        }

        private static uint[] BuildTestFashionIds()
        {
            HashSet<uint> fashionIds = new()
            {
                11120030,
                11120031,
                11010048,
                11010051
            };

            for (uint fashionId = 11120000; fashionId <= 11120999; fashionId++)
            {
                fashionIds.Add(fashionId);
            }

            for (uint fashionId = 11010047; fashionId <= 11010999; fashionId++)
            {
                fashionIds.Add(fashionId);
            }

            for (uint prefix = 1; prefix <= 30; prefix++)
            {
                fashionIds.Add(11000000 + prefix * 1000 + 1);
            }

            uint[] scannedFashionIds =
            {
                11001088, 11002112, 11003136, 11004160, 11005184, 11006016,
                11006208, 11007232, 11009024, 11009155, 11009170, 11009178,
                11011072, 11011087, 11011126, 11012096, 11012137, 11012156,
                11013120, 11013161, 11014144, 11015168, 11015228, 11016192,
                11017216, 11018240, 11019008, 11020032, 11021056, 11022080,
                11022198, 11023104, 11023164, 11024128, 11025152, 11026176,
                11026240, 11027200, 11028224, 11029248, 11030016, 11121152,
                11121170, 11122176, 11123200, 11123222, 11124224, 11125248,
                11126016, 11127040, 11128064, 11129088
            };

            foreach (uint fashionId in scannedFashionIds)
            {
                fashionIds.Add(fashionId);
            }

            uint[] visibleFashionIdsFromDump =
            {
                11100000, 11100002, 11100003, 11100004, 11100005, 11100006, 11100007, 11100008, 11100009, 11100010,
                11100012, 11100014, 11100015, 11100016, 11100018, 11100019, 11100021, 11100022, 11100023, 11100031,
                11100032, 11100033, 11100034, 11100038, 11100039, 11100040, 11100041, 11100042, 11100043, 11100044,
                11100045, 11100048, 11100049, 11100050, 11100051, 11100052, 11100053, 11100056, 11100057, 11100058,
                11100059, 11100060, 11100061, 11100062, 11100064, 11100065, 11100066, 11100067, 11100068, 11100074,
                11100075, 11100076, 11100077, 11100085, 11100087, 11100090, 11100091, 11100092, 11100093, 11100094,
                11100095, 11100097, 11100098, 11100099, 11100104, 11130000, 11130001, 11130002, 11130003, 11130004,
                11130006, 11130007, 11130008, 11130009, 11130010, 11130011, 11130012, 11130013, 11130014, 11130015,
                11130016, 11130017, 11130018, 11130019, 11130020, 11130021, 11130022, 11130023, 11130024, 11130025,
                11130026, 11130027, 11130028, 11130041, 11130042, 11130043, 11130044, 11130045, 11130046, 11130047,
                11130048, 11130049, 11130050, 11130051, 11130052, 11130053, 11130054, 11130055, 11130056, 11130057,
                11130058, 11130059, 11130060, 11130061, 11130062, 11130063, 11130064, 11130065, 11130066, 11130067,
                11130068, 11130069, 11130070, 11130071, 11130072, 11130073, 11130074, 11130075, 11130080, 11130081,
                11130082, 11130083, 11130084, 11130085, 11130086, 11130087, 11130088, 11130089, 11130090, 11130091,
                11130092, 11130093, 11130096, 11130097, 11130100, 11130101, 11130102, 11130103, 11130104, 11130105,
                11130106, 11130107, 11130108, 11130109, 11130110, 11130115, 11130116, 11130117, 11130118, 11130123,
                11130124, 11130125, 11130141, 11130142, 11130143, 11130144, 11198000,
            };

            foreach (uint fashionId in visibleFashionIdsFromDump)
            {
                fashionIds.Add(fashionId);
            }

            return fashionIds.OrderBy(id => id).ToArray();
        }

        private static FashionInfo CreateFashionInfo(uint fashionId)
        {
            return new FashionInfo()
            {
                FashionId = fashionId,
                ExpiredTime = 0,
                GainTime = 0,
                Status = 1,
                ApplyColoringSchemeId = 0,
                ColoringSchemeInfoDict = new()
            };
        }

        private static WearFashionInfo CreateWearFashionInfo(uint fashionId)
        {
            return new WearFashionInfo()
            {
                FashionId = fashionId
            };
        }

        private static SpiritWearFashionsInfo CreateWearFashionsInfo()
        {
            return new SpiritWearFashionsInfo()
            {
                FunctionSuitId = 0,
                IsTryWear = false,
                WearFashionInfoList = new(),
                WearFashionEditInfoList = new(),
                HiddenParts = 0,
                EditedHiddenParts = 0
            };
        }

        private static SpiritFashionsInfo CreateSpiritFashionsInfo(uint spiritId)
        {
            SpiritWearFashionsInfo wearFashionsInfo = GetSavedSpiritWearFashionsInfo(spiritId);
            return new SpiritFashionsInfo()
            {
                SpiritId = spiritId,
                FashionCustomSuitSchemeInfos = new FashionCustomSuitSchemeInfo[0],
                FashionFunctionSuitSchemeInfoDict = new(),
                SpiritWearFashionsInfo = wearFashionsInfo,
                SpiritPrevWearFashionsInfo = wearFashionsInfo,
                FirstGainSuitIdList = new(),
                EnableClientTryWearCount = 0
            };
        }

        private static SpiritWearFashionsInfo GetSavedSpiritWearFashionsInfo(uint spiritId)
        {
            if (!SavedSpiritWearFashions.TryGetValue(spiritId, out SpiritWearFashionsInfo info))
            {
                info = CreateWearFashionsInfo();
                SavedSpiritWearFashions[spiritId] = info;
            }

            return info;
        }

        private static PlayerFashionsInfo BuildDefaultPlayerFashionsInfo(Connection conn)
        {
            var fashionIds = ConfigManager.IsLoaded
                ? ConfigManager.GetAllFashionIds()
                : TestFashionIds.ToList();

            return new PlayerFashionsInfo()
            {
                SpiritFashionsInfoDict = conn.Spirits
                    .Select(s => s.TemplateId)
                    .Distinct()
                    .ToDictionary(id => id, CreateSpiritFashionsInfo),
                FashionInfoDict = fashionIds.ToDictionary(id => id, CreateFashionInfo),
                FavoriteFashionIdList = new(),
                FavoriteFashionSuitIdList = new(),
                DefaultSpiritIsInitDefaultFashion = false,
                SpiritId2TaskTryWearInfoDict = new()
            };
        }

        private static PlayerVehicleDetail CreatePlayerVehicleDetail(uint vehicleId)
        {
            return new PlayerVehicleDetail()
            {
                Id = vehicleId,
                Parts = new(),
                UnlockTime = 0
            };
        }

        [Handler(MethodId.LoginGame)]
        public static void LoginGame(Connection conn, UxRpcMessage msg)
        {
            LoginGame args = msg.GetArgs<LoginGame>();
            Console.WriteLine(args.ToString());
            conn.Pid = args.pid;
            GameSessionTracker.SetPid(conn.ClientSocket, args.pid);
            GameSessionTracker.LogEvent(conn.ClientSocket, "LOGIN_GAME", $"PID={args.pid}");
            PhoneSystem.InitDefaultPhoneData(conn);
            PlayerClientInfo data = new PlayerClientInfo()
            {

                InfoLogin = new()
                {
                    AccountId = "aibgr4rznwj5r6zg",
                    Pid = args.pid,
                    Aid = 5944,
                    Level = 1,
                    Name = "Horoyoi-san | AnantaPS",
                    
                    Sex = RPCMethodArgsRequestCreateRoleEx.SexType.Male,
                    PzHeadInfo = new()
                    {
                        HeadType = PersonalZoneHeadInfo.PersonalZoneHeadType.System,
                        SystemHeadId = 91195003
                    },

                },
                Config = new byte[0],
                InfoAchievement = new()
                {
                    ChallengeRecordInfo = new(),
                    CompletedSubQuestCnt = new()
                    {
                        
                    },
                    FirstKillEnemyRecord = new(),
                    CountryReputationInfo = new(),
                    FactionInfoDic = conn.FactionInfoDic,
                    NewChallengeRecordInfo = new(),
                    OccupiedInfluenceArea = new(),
                    SceneFogMapPoiIds = new(),
                    SceneFogMaps = new(),
                    UnlockedCountryList = new(),
                    UnlockedQuestList = new(),
                    UnlockInvestigateGalleryList = new(),

                },
                InfoItem = new()
                {
                    DestructibleShortcut = 0,

                    ItemCountLimitInfoList = new(),
                    PortalPosition = new(),
                    PackItems = new(),
                    ItemDayCounts = new(),
                    ItemShortcutDic = new()
                    {
                        {ItemShortcutType.Wheel1, new ItemShortcutInfo()
                        {
                            
                        } },
                        {ItemShortcutType.Wheel2, new ItemShortcutInfo()
                        {

                        } },
                        {ItemShortcutType.Wheel3, new ItemShortcutInfo()
                        {

                        } },
                        {ItemShortcutType.Wheel4, new ItemShortcutInfo()
                        {

                        } },
                        {ItemShortcutType.Wheel5, new ItemShortcutInfo()
                        {

                        } },
                        {ItemShortcutType.Resurrection, new ItemShortcutInfo()
                        {

                        } }
                    },
                    GachaPoolCount = new(),
                   // PortalRaidId= 23301263
                },
                InfoMinor = new()
                {
                    Badges = new(),
                    ChargeInfo = new()
                    {

                    },
                    ModuleEventProgressInfoDict = new(),
                    ComputerUnlockInfo = new()
                    {
                        ComputerInfos = new(),
                        UnlockEmails = new(),
                        UnlockFiles = new(),

                    },
                    DropLimitCount = new(),
                    FavorNpcDailyScheduleInfos = new(),
                    GroupChats = new(),
                    housesInfo = new()
                    {
                        FurnitureInfoDict = new(),
                        HouseInfoList = new(),
                        NotParkingSpaceVehicleIdList = new(),

                    },
                    InfoNpcCultivation = new()
                    {
                        NpcEventQueueList = new()
                        {
                            IdToNpcDict = new(),
                            NpcQueues = new(),

                        },
                        LockedCardInfos = new(),
                        NpcCardInfos = new(),
                        NpcChats = new(),
                        NpcGroupChats = new(),

                    },
                    InfoNpcProfile = new()
                    {
                        NpcProfiles = new(),
                        ProgressRewards = new(),

                    },
                    LevelRewards = new(),
                    LoadingTexts = new(),
                    MallInfo = new()
                    {
                        CommodityInfoDict = new(),
                        CommoditySpiritDisplayPreferencesList = new(),
                        MonthCardInfo = new()
                        {

                        },

                    },
                    MapPins = new(),
                    MatchInfo = new()
                    {
                        AvailablePrepareActions=new(),
                        LoadingTypeInfo = new()
                        {
                            Members=new()
                        },
                        GameId2LastPlayTime=new()
                    },
                    MiniGame = new()
                    {
                        MiniGame_Bee = new(),

                    },
                    Level = 1,
                    Fan=100,
                    Fan12=100,
                    Fan123=100,
                    
                    PlanningBoardInfo = new()
                    {
                        StepId2OptionIndexDict = new(),
                        
                    },
                    PlayerBattlePassInfo = new()
                    {
                        ChallengeTaskStates = new(),
                        ClaimedLevelRewards = new(),
                        CurrentPassType=BattlePassType.Free,
                        CurrentBattlePassId=1
                    },
                    PlayerCityPediaInfos = new()
                    {
                        CityPedia2IsReadDict = new(),
                        CreditInfo = new()
                        {
                            Credit = 999999,
                            Level = 99,
                            ClaimedLevelRewards = new(),

                        },

                    },
                    PlayerFashionsInfo = BuildDefaultPlayerFashionsInfo(conn),
                    PlayerGachaInfos = new()
                    {
                        GroupInfos = new(),
                        PityInfos = new(),
                        PoolInfos = new()
                    },
                    PlayerInfoAtmosphereGameplay = new()
                    {
                        PartTimeJobUnlockStore = new()
                    },
                    PlayerInfoGuide = new()
                    {
                        FinishedGuides = new(),
                        NewGuideTeachInfos = new(),
                        RewardedGuideTeachInfos = new(),
                        TaskTitleGuideUnlockList = new(),
                        UnlockSystems = new()
                        {
                             
                        },

                    },
                    PlayerInspireHubInfo = new()
                    {
                        TodayGamePlayJoinCountDict = new(),

                    },
                    PlayerInteractionActionInfo = new()
                    {
                        UnlockActionItemDict = new(),

                    },
                    PlayerInterActionInfo = new(),
                    PlayerLinkPlanningBoardInfo = new()
                    {

                        MultiGamePutInKeyCountInfoList = new(),

                    },
                    PlayerPhoneInfo = conn.PhoneData,
                    PopularityInfoNew = new()
                    {
                        ChangeList = new(),
                        DropList = new(),
                        HistoryPopularityList = new(),
                        PastHoursCoinRewards = new(),
                        WalletRewards = new(),
                        

                    },
                    VehicleInfo = new()
                    {
                        UnlockedVehicles = GetTestVehicleConfigIds()
                            .Select(CreatePlayerVehicleDetail)
                            .ToList(),
                        ParkingVehicleId = TestVehicleConfigId

                    },


                },
                InfoSpirit = new()
                {
                    Spirits = conn.Spirits,
                    InfoPokemon = new()
                    {
                        AllPokemons = new()
                        {
                            
                        },
                        EnabledBodyIds = new(),
                        EnabledCampIds = new(),
                        EnabledWeaponIds = new(),
                        FastFightSquad = new(),

                    },
                    AvailableSkinParts = new(),
                    InfoArmory = new()
                    {
                        Weapons = new()
                        {
                            new WeaponData()
                            {
                                TemplateId=98005002,
                                InstanceId=13,
                                SpecialLabel="",
                                WeaponFlags = new()
                                {
                                    AdditionalEffectIds=new(),
                                    IsTaskWheelWeapon=true
                                },

                                Durability=10000,

                            }
                        },

                    },
                    InfoFightStyle = new()
                    {
                        FightStyleIsUnLocked = new(),

                    },
                   
                  
                    DisableBadgeInfoDict = new(),
                    ActiveSpirit = conn.currentSpirit
                },

            };


            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerInfo
            };
            // Add all SystemUnlock values EXCEPT GetOffCar=7 (which controls the car exit cutscene)
            // GetOffCar must stay locked so the client plays the cinematic intro
            foreach(SystemUnlock type in Enum.GetValues(typeof(SystemUnlock)))
            {
                if (type == SystemUnlock.GetOffCar) continue; // Keep locked for car cutscene
                data.InfoMinor.PlayerInfoGuide.UnlockSystems.Add((uint)type);
            }

            rsp.SetArgs(MethodId.SyncPlayerInfo, data);



            // SyncEnterScene - use ANKIRA binary payload (18 spirits with correct order matching JoinableFightSpiritIds)
            UxRpcMessage rsp7 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnterScene,
                Args = AnkiraDataLoader.LoginGameSyncEnterScene
            };




            conn.SendPacket(rsp);

            // Send all spirits data so client knows available characters for switching
            UxRpcMessage rspSpirits = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerAllSpirits
            };
            rspSpirits.SetArgs(MethodId.SyncPlayerAllSpirits, new SyncPlayerAllSpirits()
            {
                list = conn.Spirits
            });
            conn.SendPacket(rspSpirits);

            // REMOVED: Do NOT send SyncPlayerCurrentSpirit during login
            // ANKIRA doesn't send this - keeps client in cinematic mode for car exit cutscene
            // UxRpcMessage rspCurrentSpirit = new UxRpcMessage()
            // {
            //     Mode = UxRpcPacketMode.Notify,
            //     RpcInvokeId = msg.RpcInvokeId,
            //     RpcRetcode = 0,
            //     RpcMethodId = (int)MethodId.SyncPlayerCurrentSpirit
            // };
            // rspCurrentSpirit.SetArgs(MethodId.SyncPlayerCurrentSpirit, new SyncPlayerCurrentSpirit()
            // {
            //     pid = conn.Pid,
            //     spiritId = conn.GetCurrentSpirit().Id,
            //     templateId = conn.GetCurrentSpirit().TemplateId,
            //     isAgentSwitch = false
            // });
            // conn.SendPacket(rspCurrentSpirit);

            SendAllUnlockedVehicles(conn, 0, UxRpcPacketMode.Notify, MethodId.SyncAllUnlockedVehicles);

            SendGangBossFullDetails(conn);

            // Initialize task sequence for Natural Born Heroes (Event 1441)
            conn.AcceptedTasks.Add(60004938);
            conn.CurrentTaskId = 60004938;
            conn.TaskCounterValues[60004938] = new List<int> { 0 };

            // Initialize Taffy Event (Event 523)
            conn.AcceptedTasks.Add(60008577);
            conn.TaskCounterValues[60008577] = new List<int> { 0 };

            UxRpcMessage rsp2 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerAllTask
            };

            rsp2.SetArgs(MethodId.SyncPlayerAllTask, new SyncPlayerAllTask()
            {
                eventPanelInfo = new()
                {
                    EventsInfo = new()
                    {
                        new TaskEventInfo()
                        {
                            EventId = 1441,
                            HasAccepted = true,
                            IsUnderway = true,
                            Visible = true,
                            TaskId = 60004938,
                            FinishedChoiceLs = new(),
                            Acceptable = true,
                            RedPoint = true
                        },
                        new TaskEventInfo()
                        {
                            EventId = 523,
                            HasAccepted = true,
                            IsUnderway = true,
                            Visible = true,
                            TaskId = 60008577,
                            FinishedChoiceLs = new(),
                            Acceptable = true,
                            RedPoint = true
                        }
                    }
                },
                eventViewInfoList = new()
                {
                    new EventSpoonViewInfo()
                    {
                        EventId = 1441,
                        RaidId = 23301180,
                        SpoonMd5 = ""
                    },
                    new EventSpoonViewInfo()
                    {
                        EventId = 523,
                        RaidId = 23300888,
                        SpoonMd5 = ""
                    }
                },
                submitEventList = new(),
                loginGameServer = true,
                submitTaskList = new(),
                taskInfos = new()
                {
                    new TaskViewData()
                    {
                        TaskId = 60004938,
                        State = TaskState.Accepted,
                        CounterValues = new List<int> { 0 },
                        Counters = new()
                        {
                            new TaskViewCounter()
                            {
                                ConfigValue = 1,
                                Index = 0,
                                Parent = 0,
                                Duty = new uint[0]
                            }
                        },
                        RecoverResource = false,
                        SpoonViewInfo = new()
                        {
                            EventId = 1441,
                            SpoonMd5 = "",
                            SpRaidId = 23301180,
                            StartTaskId = 60004938,
                            EventStartTaskId = 60004938,
                            Alias = ""
                        }
                    },
                    new TaskViewData()
                    {
                        TaskId = 60008577,
                        State = TaskState.Accepted,
                        CounterValues = new List<int> { 0 },
                        Counters = new()
                        {
                            new TaskViewCounter()
                            {
                                ConfigValue = 1,
                                Index = 0,
                                Parent = 0,
                                Duty = new uint[0]
                            }
                        },
                        RecoverResource = false,
                        SpoonViewInfo = new()
                        {
                            EventId = 523,
                            SpoonMd5 = "",
                            SpRaidId = 23300888,
                            StartTaskId = 60008577,
                            EventStartTaskId = 60008577,
                            Alias = ""
                        }
                    }
                }
            });



            conn.SendPacket(rsp2);
            
            conn.SendPacket(rsp7);

        }

        public class GetServerTimeGame : SerializedClass
        {

            public double clientUnixTime;

            public GetServerTimeGame()
            {
                onlyFields = true;
            }
        }
        public class AskUpdatePlayerCameraDirection : SerializedClass
        {

            public float cameraDirection;
           
            public AskUpdatePlayerCameraDirection()
            {
                onlyFields = true;
            }
        }
        public class SyncUnitFacingDirection : SerializedClass
        {
            public ulong pid;
            public float facing;
         
            public SyncUnitFacingDirection()
            {
                onlyFields = true;
            }
        }
        
        [Handler(MethodId.AskUpdatePlayerCameraDirection)]
        public static void AskUpdatePlayerCameraDirectionHandler(Connection conn, UxRpcMessage msg)
        {
            AskUpdatePlayerCameraDirection args = msg.GetArgs<AskUpdatePlayerCameraDirection>();
            conn.LastCameraFacing = args.cameraDirection;
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitFacingDirection,
            };

            rsp.SetArgs(MethodId.SyncUnitFacingDirection, new SyncUnitFacingDirection()
            {
                pid=conn.Pid,
                facing=args.cameraDirection
            });
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GetServerTimeGame)]
        public static void GetServerTimeGameHandler(Connection conn, UxRpcMessage msg)
        {
            GetServerTimeGame args = msg.GetArgs<GetServerTimeGame>();
            //MethodId.SyncReport
            // conn.SendPacket(rsp1);
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SendServerTimeGame,
            };

            rsp.SetArgs(MethodId.SendServerTimeGame, new SendServerTimeGame()
            {
                serverUnixTime=args.clientUnixTime,
                clientUnixTime=args.clientUnixTime,
            });



            conn.SendPacket(rsp);
            UxRpcMessage rsp2 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitHp,
            };

            rsp2.SetArgs(MethodId.SyncUnitHp, new SyncUnitHp()
            {
                unitId= conn.GetCurrentSpirit().Id,
                hp=50
            });



            conn.SendPacket(rsp2);
            conn.SyncAttributes();
            // Weapons not auto-sent on join; use GmAddAllWeapons or GM phone to add
            UxRpcMessage rsp7 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerAllSkillChargeData,
            };
            rsp7.SetArgs(MethodId.SyncPlayerAllSkillChargeData, new SyncPlayerAllSkillChargeData()
            {

                spiritId = conn.GetCurrentSpirit().Id,
                allChargeDatas = new()
                {
                    {51942120, new ChargeData(){
                        ChargePeriod=1,
                        CurrentCharges=3,
                        CurrentPercentage=100,
                        MaxCharges=3,
                        
                    }},
                    {51942112, new ChargeData(){
                        ChargePeriod=1,
                        CurrentCharges=3,
                        CurrentPercentage=100,
                        MaxCharges=3,

                    }},
                    {51942115, new ChargeData(){
                        ChargePeriod=1,
                        CurrentCharges=3,
                        CurrentPercentage=100,
                        MaxCharges=3,

                    }}
                }

            });
            conn.SendPacket(rsp7);
            UxRpcMessage rsp8 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritUnitUrbanAttrs,
            };
            rsp8.SetArgs(MethodId.SyncSpiritUnitUrbanAttrs, new SyncSpiritUnitUrbanAttrs()
            {

                entityId = conn.GetCurrentSpirit().Id,
                urbanAttrsvalues = new()
                {
                    {1,10 },
                    {2,10 },
                    {3,10 },
                    {4,10 },
                    {5,10 },
                    {6,10 }
                }

            });


            conn.SendPacket(rsp8);

            conn.SyncBuffs();
            UxRpcMessage rsp3 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerWeather,

            };
            rsp3.SetArgs(MethodId.SyncPlayerWeather, new SyncPlayerWeather()
            {
                weatherTypeId = conn.currentWeather,
                nextWeatherTypeId = conn.currentWeather,
                transitionSecond = 1,

            });
            conn.SendPacket(rsp3); // Enable weather on login

            // ANKIRA compat: send weapon detail + equip weapon on initial join ONLY
            if (!conn.WeaponsSynced)
            {
                conn.WeaponsSynced = true;
                conn.SyncWeapons();
                conn.SyncWeapon(0);
            }
        }
        public class AskRemoveClientBuff : SerializedClass
        {
            public ulong unitId;
            public uint buffId;

            public AskRemoveClientBuff()
            {
                onlyFields = true;
            }
        }
        [Handler(MethodId.AskRemoveClientBuff)]
        public static void AskRemoveClientBuffH(Connection conn, UxRpcMessage msg)
        {
            AskRemoveClientBuff args = msg.GetArgs<AskRemoveClientBuff>();
            Console.WriteLine($"[Buff] Remove buff unitId={args.unitId} buffId={args.buffId}");

            UxRpcMessage rspReturn = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = msg.RpcMethodId,
            };
            conn.SendPacket(rspReturn);

            UxRpcMessage rspNotify = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitRemoveBuff,
            };
            rspNotify.SetArgs(MethodId.SyncUnitRemoveBuff, new AskRemoveClientBuff()
            {
                unitId = args.unitId,
                buffId = args.buffId
            });
            conn.SendPacket(rspNotify);
        }
        [Handler(MethodId.AskAetherChangeQuality)]
        public static void AskAetherChangeQualityHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Aether] AskAetherChangeQuality called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAetherChangeQuality);
        }
        public class SyncGamePause : SerializedClass
        {
            public byte pause;

            public SyncGamePause()
            {
                onlyFields = true;
            }
        }
        public class SyncPlayerMoveToDriveSeat : SerializedClass
        {
            public ulong pid;
            public ulong vehicleEntityId;


            public SyncPlayerMoveToDriveSeat()
            {
                onlyFields = true;
            }
        }
        public class SyncChangeVehicleInteractable : SerializedClass
        {
            public ulong vehicleInstanceId;
            public bool interactable;

            public SyncChangeVehicleInteractable()
            {
                onlyFields = true;
            }
        }
        public class SyncPlayerExitVehicleArgs : SerializedClass
        {
            public ulong vehicleEntityId;
            public bool force;
            public bool stopBeforeLeave;

            public SyncPlayerExitVehicleArgs()
            {
                onlyFields = true;
            }
        }
        public class SyncChangeVehicleControllerArgs : SerializedClass
        {
            public ulong vehicleEntityId;
            public ulong newControllerPid;

            public SyncChangeVehicleControllerArgs()
            {
                onlyFields = true;
            }
        }
        public class SyncRemoveUnitState : SerializedClass
        {
            public ulong entityId;
            public uint state;
            public UnitStateChangeType reason;
            public uint effectFreezeState;
            public SyncRemoveUnitState()
            {
                onlyFields = true;
            }
            public enum UnitStateChangeType // TypeDefIndex: 28542
            {
                Add = 0,
                Remove = 1,
                Exclusion = 2
            }
        }
        public class SyncSceneLoadCompleted : SerializedClass
        {
            public ulong sceneId;

            public SyncSceneLoadCompleted()
            {
                onlyFields = true;
            }
        }
        public class AskLoadSceneCompleted : SerializedClass
        {
            public ulong sceneId;
            public ulong sessionId;

            public AskLoadSceneCompleted()
            {
                onlyFields = true;
            }
        }
        [Handler(MethodId.AskLoadingFinished)]
        public static void AskLoadingFinishedHandler(Connection conn, UxRpcMessage msg)
        {
            AskLoadSceneCompleted args = msg.GetArgs<AskLoadSceneCompleted>();

            // ANKIRA LoadingFinished order: HP → Attrs → States → SkillChrg → UrbanAttrs → Buffs → Wpn → Task → Agent → Veh → Wpn(0)

            // 1. SyncUnitHp
            UxRpcMessage rspHp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitHp,
            };
            rspHp.SetArgs(MethodId.SyncUnitHp, new SyncUnitHp()
            {
                unitId = conn.GetCurrentSpirit().Id,
                hp = 50
            });
            conn.SendPacket(rspHp);

            // 2. SyncUnitAttrs (97 attrs all = 1.0)
            conn.SyncAttributes();

            // 3. SyncUnitStates
            UxRpcMessage rspStates = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitStates,
            };
            byte[] stateArgs = new byte[17];
            BitConverter.GetBytes(conn.GetCurrentSpirit().Id).CopyTo(stateArgs, 0);
            stateArgs[8] = 0xFF;
            BitConverter.GetBytes((uint)0).CopyTo(stateArgs, 9);
            BitConverter.GetBytes((uint)0).CopyTo(stateArgs, 13);
            rspStates.Args = stateArgs;
            conn.SendPacket(rspStates);

            // 4. SyncPlayerAllSkillChargeData (3 skills, 3 charges each - ANKIRA compat)
            UxRpcMessage rspCharge = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerAllSkillChargeData,
            };
            rspCharge.SetArgs(MethodId.SyncPlayerAllSkillChargeData, new SyncPlayerAllSkillChargeData()
            {
                spiritId = conn.GetCurrentSpirit().Id,
                allChargeDatas = new()
                {
                    {51942120, new ChargeData(){ ChargePeriod=1, CurrentCharges=3, CurrentPercentage=100, MaxCharges=3 }},
                    {51942112, new ChargeData(){ ChargePeriod=1, CurrentCharges=3, CurrentPercentage=100, MaxCharges=3 }},
                    {51942115, new ChargeData(){ ChargePeriod=1, CurrentCharges=3, CurrentPercentage=100, MaxCharges=3 }}
                }
            });
            conn.SendPacket(rspCharge);

            // 5. SyncSpiritUnitUrbanAttrs (6 attrs all = 10.0)
            UxRpcMessage rspUrban = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritUnitUrbanAttrs,
            };
            rspUrban.SetArgs(MethodId.SyncSpiritUnitUrbanAttrs, new SyncSpiritUnitUrbanAttrs()
            {
                entityId = conn.GetCurrentSpirit().Id,
                urbanAttrsvalues = new()
                {
                    {1, 10}, {2, 10}, {3, 10},
                    {4, 10}, {5, 10}, {6, 10}
                }
            });
            conn.SendPacket(rspUrban);

            // 6. SyncUnitBuffList (5 buffs)
            conn.SyncBuffs();

            // 6b. SyncWorldReady (ANKIRA compat - tells client world is ready)
            UxRpcMessage rspWorldReady = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncWorldReady,
            };
            rspWorldReady.Args = BitConverter.GetBytes((ulong)args.sceneId);
            conn.SendPacket(rspWorldReady);

            // 7. SyncSpiritWeaponDetail (full weapon inventory)
            conn.SyncWeapons();

            // Weather on login
            UxRpcMessage rspWeather = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerWeather,
            };
            rspWeather.SetArgs(MethodId.SyncPlayerWeather, new SyncPlayerWeather()
            {
                weatherTypeId = conn.currentWeather,
                transitionSecond = 0,
            });
            conn.SendPacket(rspWeather);
            Console.WriteLine($"[Login] Weather synced: typeId={conn.currentWeather}");

            // Time on login
            DateTime now = DateTime.Now;
            if (conn.timeOffset != 0)
                now = now.AddSeconds(conn.timeOffset);

            uint raidDaySeconds = (uint)(now.Hour * 3600 + now.Minute * 60 + now.Second);
            uint realTime = (uint)(DateTimeOffset.UtcNow.ToUnixTimeSeconds() + conn.timeOffset);

            UxRpcMessage rspTime = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerCurrentTime,
            };
            rspTime.SetArgs(MethodId.SyncPlayerCurrentTime, new SyncPlayerCurrentTime()
            {
                realTime = realTime,
                raidDaySeconds = raidDaySeconds,
                fix = true,
                transitionSecond = 0,
                reason = SyncPlayerCurrentTime.RaidTimeAndWeatherChangeReason.Loaded,
            });
            conn.SendPacket(rspTime);
            Console.WriteLine($"[Login] Time synced: {now.Hour:D2}:{now.Minute:D2}");

            // 8. SyncCurrentTask
            UxRpcMessage rsp3 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCurrentTask
            };
            rsp3.SetArgs(MethodId.SyncCurrentTask, new SyncCurrentTask()
            {
                eventId = 1441,
                taskId = 60004938,
                firstTime = true,
                reason = SyncCurrentTask.ChangeCurrentTaskReason.MainEvent,
                taskGps = new()
                {
                    BelongTaskId = 60004938,
                    Type = SyncCurrentTask.TaskGpsType.None,
                    Position = new()
                },
                type = SyncCurrentTask.CurrentTaskType.Primary
            });
            conn.SendPacket(rsp3);

            // REMOVED: SyncManagedAgent - ANKIRA doesn't send this during loading
            // Marking spirit as player-controlled breaks the car exit cinematic mode
            // UxRpcMessage rsp5 = new UxRpcMessage()
            // {
            //     Mode = UxRpcPacketMode.Notify,
            //     RpcInvokeId = msg.RpcInvokeId,
            //     RpcRetcode = 0,
            //     RpcMethodId = (int)MethodId.SyncManagedAgent
            // };
            // rsp5.SetArgs(MethodId.SyncManagedAgent, new SyncManagedSpirit()
            // {
            //     pid = conn.Pid,
            //     id = conn.GetCurrentSpirit().Id,
            //     moveId = 0
            // });
            // conn.SendPacket(rsp5);

            // REMOVED: Spawn vehicle + world population during loading
            // The car in the cutscene is a scene prop, not a spawned vehicle
            // if (conn.SkipNextVehicleSpawn)
            // {
            //     Console.WriteLine($"[SpiritSwitch] Skipping vehicle spawn (scene re-entry after spirit switch)");
            //     conn.SkipNextVehicleSpawn = false;
            // }
            // else
            // {
            //     SpawnVehicle(conn);
            //     Game.WorldPopulationBuilder.SendWorldPopulation(conn, conn.LastKnownPlayerPosition.X, conn.LastKnownPlayerPosition.Z);
            // }

            // 11. SyncSceneLoadCompleted (ANKIRA: sent after everything else)
            UxRpcMessage rspSceneLoad = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSceneLoadCompleted,
            };
            rspSceneLoad.SetArgs(MethodId.SyncSceneLoadCompleted, new SyncSceneLoadCompleted()
            {
                sceneId = args.sceneId
            });
            conn.SendPacket(rspSceneLoad);

            // 12. SyncSpiritSwitchWeaponAction (equip current weapon, not forced to 0)
            conn.SyncWeapon(conn.WeaponIndex);

            // 13. Activate player AFTER cutscene - tell client which spirit is active and managed
            // This must come AFTER SyncSceneLoadCompleted so the car cutscene plays first,
            // then the player gains control
            UxRpcMessage rspActivateSpirit = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerCurrentSpirit
            };
            rspActivateSpirit.SetArgs(MethodId.SyncPlayerCurrentSpirit, new SyncPlayerCurrentSpirit()
            {
                pid = conn.Pid,
                spiritId = conn.GetCurrentSpirit().Id,
                templateId = conn.GetCurrentSpirit().TemplateId,
                isAgentSwitch = false
            });
            conn.SendPacket(rspActivateSpirit);

            UxRpcMessage rspManaged = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncManagedAgent
            };
            rspManaged.SetArgs(MethodId.SyncManagedAgent, new SyncManagedSpirit()
            {
                pid = conn.Pid,
                id = conn.GetCurrentSpirit().Id,
                moveId = 0
            });
            conn.SendPacket(rspManaged);

            // 14. Spawn vehicle near player + world population (after player activation)
            if (!conn.SkipNextVehicleSpawn)
            {
                // Spawn vehicle 3 meters to the right of the player's position
                var playerPos = conn.LastKnownPlayerPosition;
                var vehicleSpawnPos = new UXVector3()
                {
                    X = playerPos.X + 3,
                    Y = playerPos.Y,
                    Z = playerPos.Z
                };
                SpawnVehicle(conn, TestVehicleConfigId, vehicleSpawnPos, conn.LastCameraFacing);
                Game.WorldPopulationBuilder.SendWorldPopulation(conn, playerPos.X, playerPos.Z);
                // Drive the client's AOI grid system — tell it which world cells to load
                Game.AOIGridManager.SendInitialAOI(conn);
            }
            else
            {
                Console.WriteLine($"[SpiritSwitch] Skipping vehicle spawn (scene re-entry after spirit switch)");
                conn.SkipNextVehicleSpawn = false;
            }

            // 15. Load and register road/sidewalk/zonegraph lane data, then push to client
            LaneDataLoader.LoadAndRegister(conn);

            GameSessionTracker.LogEvent(conn.ClientSocket, "LOADING_FINISHED", $"SceneId={args.sceneId} PID={conn.Pid}");
        }
        [Handler(MethodId.AskLoadSceneCompleted)]
        public static void AskLoadSceneCompletedHandler(Connection conn, UxRpcMessage msg)
        {
            AskLoadSceneCompleted args = msg.GetArgs<AskLoadSceneCompleted>();
            Console.WriteLine(args.ToString());

            // ANKIRA compat: full state sync on scene transition
            // 1. SyncUnitAttrs
            conn.SyncAttributes();

            // 2. SyncBuffs
            conn.SyncBuffs();

            // 3. SyncWeapons (full weapon detail)
            conn.SyncWeapons();

            // 4. SyncSceneLoadCompleted
            UxRpcMessage rsp1 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSceneLoadCompleted,
            };
            rsp1.SetArgs(MethodId.SyncSceneLoadCompleted, new SyncSceneLoadCompleted()
            {
                sceneId = args.sceneId
            });
            conn.SendPacket(rsp1);

            // 5. SyncWeapon - equip current weapon after scene load
            conn.SyncWeapon(conn.WeaponIndex);

            // 6. Load and register road/sidewalk/zonegraph lane data, then push to client
            LaneDataLoader.LoadAndRegister(conn);

            // 7. Initialize MassEntityManager zones (crowd density, surround zone, intersections)
            Game.MassEntityManager.OnSceneLoad(conn);

            // 8. Spawn vehicles and initialize world population (NPCs)
            var playerPos = conn.LastKnownPlayerPosition;
            Game.WorldPopulationBuilder.SendWorldPopulation(conn, playerPos.X, playerPos.Z);

            // 9. Drive client AOI grid — reset old cells and send new ones for the new scene
            Game.AOIGridManager.ResetAOI(conn);
            Game.AOIGridManager.SendInitialAOI(conn);

            // 10. Initialize metro system — push initial metro train states
            conn.PushMetroResync();
            Console.WriteLine($"[Metro] Initialized {conn.ActiveMetroLines.Count} active lines with {conn.ActiveMetroLines.Count * conn.MetroTrainsPerLine} trains");

            GameSessionTracker.LogEvent(conn.ClientSocket, "SCENE_LOADED", $"SceneId={args.sceneId} PID={conn.Pid}");
        }
        public class AskGetAllMetroInfos : SerializedClass
        {
            public List<MetroClientInfo> list;


            public AskGetAllMetroInfos()
            {
                onlyFields = true;
            }
        }
        [Handler(MethodId.AskGetAllMetroInfos)]
        public static void AskGetAllMetroInfosHandler(Connection conn, UxRpcMessage msg)
        {
            // The set of running trains is driven by the GM Transit Control panel
            // (/gm/transit). conn.ActiveMetroLines + conn.MetroTrainsPerLine are
            // the source of truth; BuildRunningMetros() produces the current list
            // with ElapsedTime advancing from server uptime so trains appear to move.
            // Real line names from vfc_387 bundle (for reference):
            //   LineId 1 = 港湾线 (Harbor/Bayshore) — S_OrangeLine, 300s cycle
            //   LineId 2 = 中央线 (Central)          — S_GreenLine, 300s cycle
            //   LineId 3 = 东城线 (East City)        — S_BlueEast, 240s cycle
            //   LineId 4 = (DynamicFeisuoLine)       — 240s cycle
            var runningMetros = conn.BuildRunningMetros();

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetAllMetroInfos,
            };
            rsp.SetArgs(MethodId.AskGetAllMetroInfos, new AskGetAllMetroInfos() { list = runningMetros });
            conn.SendPacket(rsp);

            // Send initial hide states (no stealth zones active by default)
            Game.MetroManager.SendInitialHideStates(conn);
        }
        private static List<SyncAllUnlockedVehicles.PlayerVehicleClientDetail> BuildUnlockedVehicles(Connection conn = null)
        {
            List<uint> vehicleIds = conn?.UnlockedVehicles?.ToList() ?? GetTestVehicleConfigIds().ToList();
            if (vehicleIds.Count == 0)
                vehicleIds = GetTestVehicleConfigIds().ToList();
            
            // Ensure Cat Express vehicle is always unlocked
            if (!vehicleIds.Contains(81006006))
                vehicleIds.Add(81006006);
            
            return vehicleIds
                .Select(vehicleId => new SyncAllUnlockedVehicles.PlayerVehicleClientDetail()
                {
                    Id = vehicleId
                })
                .ToList();
        }

        private static void SendAllUnlockedVehicles(Connection conn, int invokeId, UxRpcPacketMode mode, MethodId methodId)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = mode,
                RpcInvokeId = invokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)methodId,
            };
            rsp.SetArgs(methodId, new SyncAllUnlockedVehicles()
            {
                unlockedVehicles = BuildUnlockedVehicles(conn)
            });
            conn.SendPacket(rsp);
        }

        private static void SendEmptySuccessReturn(Connection conn, UxRpcMessage msg, MethodId methodId)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)methodId,
            };
            conn.SendPacket(rsp);
        }

        private static void SendNotify(Connection conn, MethodId methodId, SerializedClass args)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)methodId,
            };
            rsp.SetArgs(methodId, args);
            conn.SendPacket(rsp);
        }

        private static void SendErrorReturn(Connection conn, UxRpcMessage msg, MethodId methodId, int errorCode)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = (uint)errorCode,
                RpcMethodId = (int)methodId,
            };
            conn.SendPacket(rsp);
        }

        private static void SendGangMemberDetails(Connection conn, GangMemberInfo member)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGangBossGangMemberDetails,
            };

            var data = new GangMemberDetailData()
            {
                TemplateId = member.TemplateId,
                IsUnlock = member.IsUnlock,
                NextReviveTimeStamp = member.NextReviveTimeStamp,
                InstanceId = member.InstanceId,
                HpPercent = member.HpPercent
            };

            rsp.SetArgs(MethodId.SyncGangBossGangMemberDetails, data);
            conn.SendPacket(rsp);
        }

        private static void SendGangBossFullDetails(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGangBossFullDetails,
            };

            var fullDetails = new GangBossFullDetailsData()
            {
                full = new GangBossMemberListData()
                {
                    GangMembers = conn.GangMembers.Values.Select(m => new GangMemberDetailData()
                    {
                        TemplateId = m.TemplateId,
                        IsUnlock = m.IsUnlock,
                        NextReviveTimeStamp = m.NextReviveTimeStamp,
                        InstanceId = m.InstanceId,
                        HpPercent = m.HpPercent
                    }).ToDictionary(m => m.TemplateId)
                },
                CurrentBattleAgentCount = conn.GangBossCurrentBattleAgentCount
            };

            rsp.SetArgs(MethodId.SyncGangBossFullDetails, fullDetails);
            conn.SendPacket(rsp);
        }

        private static ulong GenerateInstanceId()
        {
            return (ulong)(DateTimeOffset.UtcNow.ToUnixTimeMilliseconds() + Random.Shared.Next(1000));
        }

        private static double GetCurrentTimestamp()
        {
            return DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        }

        [Handler(MethodId.AskGetUnlockedVehicles)]
        public static void AskGetUnlockedVehiclesHandler(Connection conn, UxRpcMessage msg)
        {
            SendAllUnlockedVehicles(conn, msg.RpcInvokeId, UxRpcPacketMode.Return, MethodId.AskGetUnlockedVehicles);
        }

        public class AskSummonVehicleArgs : SerializedClass
        {
            public uint vehicleconfigid;
            public UXVector3 position;
            public float facingdirection;

            public AskSummonVehicleArgs()
            {
                onlyFields = true;
            }
        }

        [Handler(MethodId.AskSummonVehicle)]
        public static void AskSummonVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            AskSummonVehicleArgs args = msg.GetArgs<AskSummonVehicleArgs>();
            uint vehicleConfigId = args.vehicleconfigid == 117 || args.vehicleconfigid == 0
                ? TestVehicleConfigId
                : args.vehicleconfigid;

            Console.WriteLine($"[Vehicle] AskSummonVehicle RequestedConfigId={args.vehicleconfigid} SpawnConfigId={vehicleConfigId} Pos=({args.position?.X}, {args.position?.Y}, {args.position?.Z}) Facing={args.facingdirection}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSummonVehicle);
            SpawnVehicle(conn, vehicleConfigId, args.position, args.facingdirection);
        }

        public class AskSummonGangMemberArgs : SerializedClass
        {
            public uint templateid;

            public AskSummonGangMemberArgs()
            {
                onlyFields = true;
            }
        }

        [Handler(MethodId.AskSummonGangMember)]
        public static void AskSummonGangMemberHandler(Connection conn, UxRpcMessage msg)
        {
            AskSummonGangMemberArgs args = msg.GetArgs<AskSummonGangMemberArgs>();
            uint templateId = args.templateid;

            Console.WriteLine($"[GangMember] AskSummonGangMember TemplateId={templateId}");

            if (!conn.GangMembers.TryGetValue(templateId, out var member))
            {
                SendErrorReturn(conn, msg, MethodId.AskSummonGangMember, 1);
                return;
            }

            if (!member.IsUnlock)
            {
                SendErrorReturn(conn, msg, MethodId.AskSummonGangMember, 2);
                return;
            }

            if (member.InstanceId != 0)
            {
                SendErrorReturn(conn, msg, MethodId.AskSummonGangMember, 3);
                return;
            }

            if (conn.GangBossCurrentBattleAgentCount <= 0)
            {
                SendErrorReturn(conn, msg, MethodId.AskSummonGangMember, 4);
                return;
            }

            member.InstanceId = GenerateInstanceId();
            member.HpPercent = 1.0f;
            conn.GangBossCurrentBattleAgentCount--;

            SendEmptySuccessReturn(conn, msg, MethodId.AskSummonGangMember);
            SendGangMemberDetails(conn, member);
        }

        public class AskDestroyGangMemberArgs : SerializedClass
        {
            public uint templateid;

            public AskDestroyGangMemberArgs()
            {
                onlyFields = true;
            }
        }

        [Handler(MethodId.AskDestroyGangMember)]
        public static void AskDestroyGangMemberHandler(Connection conn, UxRpcMessage msg)
        {
            AskDestroyGangMemberArgs args = msg.GetArgs<AskDestroyGangMemberArgs>();
            uint templateId = args.templateid;

            Console.WriteLine($"[GangMember] AskDestroyGangMember TemplateId={templateId}");

            if (!conn.GangMembers.TryGetValue(templateId, out var member))
            {
                SendErrorReturn(conn, msg, MethodId.AskDestroyGangMember, 1);
                return;
            }

            if (member.InstanceId == 0)
            {
                SendErrorReturn(conn, msg, MethodId.AskDestroyGangMember, 2);
                return;
            }

            member.InstanceId = 0;
            member.NextReviveTimeStamp = GetCurrentTimestamp() + 300;
            conn.GangBossCurrentBattleAgentCount++;

            SendEmptySuccessReturn(conn, msg, MethodId.AskDestroyGangMember);
            SendGangMemberDetails(conn, member);
        }

        [Handler(MethodId.AskReadFashions)]
        public static void AskReadFashionsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Fashion] AskReadFashions");
            var fashionInfo = BuildDefaultPlayerFashionsInfo(conn);
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskReadFashions,
            };
            rsp.SetArgs(MethodId.AskReadFashions, fashionInfo);
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskReadFashionSuits)]
        public static void AskReadFashionSuitsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Fashion] AskReadFashionSuits");
            var suitIds = ConfigManager.IsLoaded
                ? ConfigManager.GetAllFashionSuitIds()
                : new List<uint>();

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskReadFashionSuits,
            };
            rsp.SetArgs(MethodId.AskReadFashionSuits, new SerializedList<uint>() { values = suitIds });
            conn.SendPacket(rsp);
        }

        public class AskSetSpiritFashionsArgs : SerializedClass
        {
            public uint spiritid;
            public SpiritWearFashionsInfo spiritwearfashionsinfo;

            public AskSetSpiritFashionsArgs()
            {
                onlyFields = true;
            }
        }

        public class AskModifySpiritWearFashionsArgs : SerializedClass
        {
            public uint spiritid;
            public List<uint> unwearfashionidlist;
            public List<WearFashionInfo> wearfashioninfolist;
            public List<uint> uneditwearfashionidlist;
            public List<WearFashionEditInfo> editwearfashioneditinfolist;

            public AskModifySpiritWearFashionsArgs()
            {
                onlyFields = true;
            }
        }

        public class AskModifySpiritWearFashionsOnlyWearArgs : SerializedClass
        {
            public uint spiritid;
            public List<uint> unwearfashionidlist;
            public List<WearFashionInfo> wearfashioninfolist;

            public AskModifySpiritWearFashionsOnlyWearArgs()
            {
                onlyFields = true;
            }
        }

        private static void SendSetSpiritFashions(Connection conn, uint spiritId, SpiritWearFashionsInfo wearFashionsInfo)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSetSpiritFashions,
            };
            rsp.SetArgs(MethodId.SyncSetSpiritFashions, new AskSetSpiritFashionsArgs()
            {
                spiritid = spiritId,
                spiritwearfashionsinfo = wearFashionsInfo
            });
            conn.SendPacket(rsp);
        }

        private static void ApplyWearFashionDelta(
            SpiritWearFashionsInfo target,
            IEnumerable<uint> removeFashionIds,
            IEnumerable<WearFashionInfo> addFashionInfos)
        {
            target.WearFashionInfoList ??= new();
            HashSet<uint> removeIds = removeFashionIds?.ToHashSet() ?? new();
            if (removeIds.Count > 0)
                target.WearFashionInfoList.RemoveAll(info => info != null && removeIds.Contains(info.FashionId));

            foreach (WearFashionInfo info in addFashionInfos ?? Enumerable.Empty<WearFashionInfo>())
            {
                if (info == null || info.FashionId == 0)
                    continue;

                target.WearFashionInfoList.RemoveAll(existing => existing != null && existing.FashionId == info.FashionId);
                target.WearFashionInfoList.Add(info);
            }
        }

        private static void ApplyWearFashionEditDelta(
            SpiritWearFashionsInfo target,
            IEnumerable<uint> removeFashionIds,
            IEnumerable<WearFashionEditInfo> addEditInfos)
        {
            target.WearFashionEditInfoList ??= new();
            HashSet<uint> removeIds = removeFashionIds?.ToHashSet() ?? new();
            if (removeIds.Count > 0)
                target.WearFashionEditInfoList.RemoveAll(info => info != null && removeIds.Contains(info.FashionId));

            foreach (WearFashionEditInfo info in addEditInfos ?? Enumerable.Empty<WearFashionEditInfo>())
            {
                if (info == null || info.FashionId == 0)
                    continue;

                target.WearFashionEditInfoList.RemoveAll(existing => existing != null && existing.FashionId == info.FashionId);
                target.WearFashionEditInfoList.Add(info);
            }
        }

        [Handler(MethodId.AskSetSpiritFashions)]
        public static void AskSetSpiritFashionsHandler(Connection conn, UxRpcMessage msg)
        {
            AskSetSpiritFashionsArgs args = msg.GetArgs<AskSetSpiritFashionsArgs>();
            SpiritWearFashionsInfo wearFashionsInfo = args.spiritwearfashionsinfo ?? CreateWearFashionsInfo();
            SavedSpiritWearFashions[args.spiritid] = wearFashionsInfo;

            Console.WriteLine($"[Fashion] AskSetSpiritFashions Spirit={args.spiritid} WearCount={wearFashionsInfo.WearFashionInfoList?.Count ?? 0} EditCount={wearFashionsInfo.WearFashionEditInfoList?.Count ?? 0}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetSpiritFashions);
            SendSetSpiritFashions(conn, args.spiritid, wearFashionsInfo);
        }

        [Handler(MethodId.AskModifySpiritWearFashions)]
        public static void AskModifySpiritWearFashionsHandler(Connection conn, UxRpcMessage msg)
        {
            AskModifySpiritWearFashionsArgs args = msg.GetArgs<AskModifySpiritWearFashionsArgs>();
            SpiritWearFashionsInfo wearFashionsInfo = GetSavedSpiritWearFashionsInfo(args.spiritid);

            ApplyWearFashionDelta(wearFashionsInfo, args.unwearfashionidlist, args.wearfashioninfolist);
            ApplyWearFashionEditDelta(wearFashionsInfo, args.uneditwearfashionidlist, args.editwearfashioneditinfolist);

            Console.WriteLine($"[Fashion] AskModifySpiritWearFashions Spirit={args.spiritid} WearCount={wearFashionsInfo.WearFashionInfoList?.Count ?? 0} EditCount={wearFashionsInfo.WearFashionEditInfoList?.Count ?? 0}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskModifySpiritWearFashions);
            SendSetSpiritFashions(conn, args.spiritid, wearFashionsInfo);
        }

        [Handler(MethodId.AskModifySpiritWearFashionsOnlyW)]
        public static void AskModifySpiritWearFashionsOnlyWearHandler(Connection conn, UxRpcMessage msg)
        {
            AskModifySpiritWearFashionsOnlyWearArgs args = msg.GetArgs<AskModifySpiritWearFashionsOnlyWearArgs>();
            SpiritWearFashionsInfo wearFashionsInfo = GetSavedSpiritWearFashionsInfo(args.spiritid);

            ApplyWearFashionDelta(wearFashionsInfo, args.unwearfashionidlist, args.wearfashioninfolist);

            Console.WriteLine($"[Fashion] AskModifySpiritWearFashionsOnlyWear Spirit={args.spiritid} WearCount={wearFashionsInfo.WearFashionInfoList?.Count ?? 0}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskModifySpiritWearFashionsOnlyW);
            SendSetSpiritFashions(conn, args.spiritid, wearFashionsInfo);
        }

        public class QuerySkey : SerializedClass
        {
            public string key;
            public QuerySkey()
            {
                onlyFields = true;
            }
        }
        [Handler(153965146)]
        public static void QuerySkeyHandler(Connection conn, UxRpcMessage msg)
        {

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)153965146
            };

            rsp.SetArgs(153965146, new QuerySkey()
            {
                key="idk?"
            });



            conn.SendPacket(rsp);
        }
        public class AskAllSpiritPanelData : SerializedClass
        {
            public List<SpiritPanelData> list;


            public AskAllSpiritPanelData()
            {
                onlyFields = true;
            }
           
        }
        [Handler(MethodId.AskAllSpiritPanelData)]
        public static void AskAllSpiritPanelDataHandler(Connection conn, UxRpcMessage msg)
        {

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskAllSpiritPanelData,
            };

            rsp.SetArgs(MethodId.AskAllSpiritPanelData, new AskAllSpiritPanelData()
            {
                list = conn.Spirits.Select(S => S.ToSpiritPanelData()).ToList()
            });



            conn.SendPacket(rsp);
        }
        public class ChangeParkourState : SerializedClass
        {
            public uint parkourStateId;


            public ChangeParkourState()
            {
                onlyFields = true;
            }
           
        }
        public class OnParkourStateChange : SerializedClass
        {
            public uint parkourStateId;


            public OnParkourStateChange()
            {
                onlyFields = true;
            }
        }
        [Handler(MethodId.OnParkourStateChange)]
        public static void OnParkourStateChangeHandler(Connection conn, UxRpcMessage msg)
        {
            OnParkourStateChange args = msg.GetArgs<OnParkourStateChange>();
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.OnParkourStateChange,
            };

            rsp.SetArgs(MethodId.ChangeParkourState, new ChangeParkourState()
            {
               parkourStateId=args.parkourStateId
            });



            conn.SendPacket(rsp);
        }
        public class AskSwitchSpirit : SerializedClass
        {
            public uint spiritId;


            public AskSwitchSpirit()
            {
                onlyFields = true;
            }
        }
        public static void SpawnNPC(Connection conn)
        {
            ulong randomNpcGuid = (ulong)new Random().NextInt64();
            UxRpcMessage rsp8 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIStaticNpcAddData,
            };

            rsp8.SetArgs(MethodId.SyncAetherAIStaticNpcAddData, new ClientStaticNpcInitData()
            {
                Position = new()
                {
                    Y = 0,
                    X = 1003,
                    Z = 2000
                },
                Id = randomNpcGuid,
                StaticNpcInfoId = randomNpcGuid,
                AgentPersonaId = 45200058,
                NpcPid = 41739060,
                UrbanDiversityId = 88888000,
                NpcFormworkId = 40924922,
                PoiActionId = 0,

                AgentSyncClientInfo = new()
                {
                    stimIDList = new int[0],
                    CanBeExaminedByPolice = true,
                    indoorList = new(),
                    roomIds = new int[0],
                    SpoonAgentId = 0,
                    treeName = "",
                    petPerformData = "",
                    spawnEffectId = new uint[0],
                    randomModelCfgId = 0,
                    LeaveDistance = 10000,
                    approachDistance = 10000,
                    FashionSuitId = 11190001,
                    
                },

            });



            conn.SendPacket(rsp8);
        }
        private static void SendNearbyDestructibleObjects(Connection conn, float centerX, float centerZ)
        {
            var objects = DestructibleObjectManager.GetAddEntriesInRange(centerX, centerZ, 500);
            if (objects.Count == 0)
                return;

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestructibleObjectAddList,
            };
            rsp.SetArgs(MethodId.SyncDestructibleObjectAddList, new SyncDestructibleObjectAddListData()
            {
                Objects = objects
            });
            conn.SendPacket(rsp);
            Console.WriteLine($"[Destructible] Sent {objects.Count} objects to player");
        }

        public static void SpawnVehicle(Connection conn, uint vehicleConfigId = TestVehicleConfigId, UXVector3 position = null, float facing = 45, uint colorConfigId = 0)
        {
            colorConfigId = VehicleColors.Normalize(colorConfigId);
            if (colorConfigId == 0)
            {
                var vEntry = ConfigManager.GetVehicle(vehicleConfigId);
                colorConfigId = VehicleColors.GetRandomColorForVehicle(vEntry?.VehicleColor);
            }
            ulong randomVehicleGuid = (ulong)new Random().NextInt64();
            UXVector3 spawnPosition = position ?? new UXVector3()
            {
                Y = 0,
                X = 1015,
                Z = 1998
            };
            conn.LastSpawnedVehicleId = randomVehicleGuid;
            conn.LastSpawnedVehicleConfigId = vehicleConfigId;
            conn.LastVehicleColorConfigId = colorConfigId;
            conn.LastVehicleSpawnPosition = spawnPosition;
            conn.LastVehicleFacing = facing;
            conn.CurrentVehicleId = 0;
            conn.CurrentVehicleSeat = -1;

            UxRpcMessage rsp3 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpawnVehicle,
            };

            rsp3.SetArgs(MethodId.SyncSpawnVehicle, new VehicleClientInfo()
            {
                EntityId = randomVehicleGuid,
                VehicleConfigId = vehicleConfigId,
                Interactable = true,
                ControllerPid = conn.Pid, // Player is the controller so vehicle is drivable
                IsDynamicGo = true,

                Facing = facing,
                Position = spawnPosition,
                Parts = new()
                {

                },
                ColorConfigId = colorConfigId,
                SummonType = VehicleSummonType.NormalSummon,
                GpsInfo = new()
                {
                    TargetPosition = new(),
                    Type = RaidVehicleGpsInfo.GpsType.None
                },
                CreateSourceType = VehicleCreateSourceType.Summon,
                DisableNavigation = false,
                SpoonId = 25001,
                SeatInfos = new()
                {
                    new RaidVehicleSeatInfo()
                    {
                        EntityId = randomVehicleGuid + 1,
                        SeatIndex = 0,
                        SeatState = RaidVehicleSeatInfo.RaidVehicleSeatState.Avaliable,
                        DestroyRelated = true
                    },
                    new RaidVehicleSeatInfo()
                    {
                        EntityId = randomVehicleGuid + 2,
                        SeatIndex = 1,
                        SeatState = RaidVehicleSeatInfo.RaidVehicleSeatState.Avaliable,
                        DestroyRelated = true
                    },
                    new RaidVehicleSeatInfo()
                    {
                        EntityId = randomVehicleGuid + 3,
                        SeatIndex = 2,
                        SeatState = RaidVehicleSeatInfo.RaidVehicleSeatState.Avaliable,
                        DestroyRelated = true
                    },
                    new RaidVehicleSeatInfo()
                    {
                        EntityId = randomVehicleGuid + 4,
                        SeatIndex = 3,
                        SeatState = RaidVehicleSeatInfo.RaidVehicleSeatState.Avaliable,
                        DestroyRelated = true
                    }
                }
            });

            conn.SendPacket(rsp3);
            Console.WriteLine($"[Vehicle][SPAWN] SyncSpawnVehicle sent: EntityId={randomVehicleGuid} ConfigId={vehicleConfigId} Pos=({spawnPosition.X},{spawnPosition.Y},{spawnPosition.Z}) Facing={facing} Interactable=true Seats=4");

            // Track the spawn so /gm/vehicle/list can render the live fleet.
            conn.RegisterSpawnedVehicle(new SpawnedVehicle
            {
                EntityId = randomVehicleGuid,
                ConfigId = vehicleConfigId,
                SpawnX = spawnPosition.X,
                SpawnY = spawnPosition.Y,
                SpawnZ = spawnPosition.Z,
                Facing = facing,
                ColorConfigId = colorConfigId,
                SpawnTime = DateTime.Now,
                IsDestroyed = false,
            });
            Console.WriteLine($"[Vehicle][TRACK] Registered EntityId={randomVehicleGuid} ConfigId={vehicleConfigId}. Live count: {conn.SpawnedVehicles.Count} (active: {conn.GetLiveVehicles().Count}).");

            // Register with VehicleSyncManager for full sync tree tracking
            Game.VehicleSyncManager.RegisterVehicle(conn, randomVehicleGuid, vehicleConfigId,
                spawnPosition.X, spawnPosition.Y, spawnPosition.Z, facing, conn.Pid);

            SendChangeVehicleInteractable(conn, randomVehicleGuid, true);

            // Initialize vehicle boarding state - tell client player is NOT on this vehicle yet
            SendUnitVehicleStatus(conn, randomVehicleGuid, 0, NewClientBoardingInfo.BoardingStatus.NotOnVehicle);

            UxRpcMessage rsp7 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAISetVehicleStatus,
            };

            rsp7.SetArgs(MethodId.SyncAetherAISetVehicleStatus, new SyncAetherAISetVehicleStatus()
            {
                vehicleInstanceId = randomVehicleGuid,
                status = 0
            });

            conn.SendPacket(rsp7);
        }

        private static UXVector3 ClonePosition(UXVector3 position)
        {
            return new UXVector3()
            {
                X = position.X,
                Y = position.Y,
                Z = position.Z
            };
        }

        private static UXVector3 GetGmVehicleSpawnPosition(Connection conn, UXVector3 requestedPosition)
        {
            if (requestedPosition != null)
                return requestedPosition;

            if (conn.HasLastKnownPlayerPosition)
                return ClonePosition(conn.LastKnownPlayerPosition);

            return null;
        }

        private static void RememberPlayerPosition(Connection conn, UXVector3 position, string source)
        {
            if (position == null)
                return;

            if (Math.Abs(position.X) > 100000 || Math.Abs(position.Y) > 100000 || Math.Abs(position.Z) > 100000)
                return;

            // Save previous position for speed calculation
            conn.PreviousPlayerPosition = ClonePosition(conn.LastKnownPlayerPosition);
            conn.LastPositionUpdateTime = Environment.TickCount64;

            conn.LastKnownPlayerPosition = ClonePosition(position);
            conn.HasLastKnownPlayerPosition = true;
            Console.WriteLine($"[Position] {source} X={position.X:0.###} Y={position.Y:0.###} Z={position.Z:0.###}");

            // Drive AOI grid — detect cell changes and send grid updates
            Game.AOIGridManager.OnPlayerMoved(conn);
        }

        private static void SendUnitAddBuffNotify(Connection conn, ulong unitId, uint buffId, int buffLayer)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitAddBuff,
            };
            rsp.SetArgs(MethodId.SyncUnitAddBuff, new AskAddClientBuffArgs()
            {
                unitId = unitId,
                buffId = buffId,
                buffLayer = buffLayer
            });
            conn.SendPacket(rsp);
        }

        private static void SendUnitRemoveBuffNotify(Connection conn, ulong unitId, uint buffId)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitRemoveBuff,
            };
            rsp.SetArgs(MethodId.SyncUnitRemoveBuff, new AskRemoveClientBuff()
            {
                unitId = unitId,
                buffId = buffId
            });
            conn.SendPacket(rsp);
        }

        private static bool TryRememberUnitMoveActionPosition(Connection conn, UxRpcMessage msg)
        {
            byte[] args = msg.Args;
            if (args == null || args.Length < 25 || args[0] != 0xFF)
                return false;

            ulong entityId = BitConverter.ToUInt64(args, 5);
            UXVector3 position = new UXVector3()
            {
                X = BitConverter.ToSingle(args, 13),
                Y = BitConverter.ToSingle(args, 17),
                Z = BitConverter.ToSingle(args, 21)
            };

            if (entityId == conn.GetCurrentSpirit().Id || entityId == 100000000000UL || entityId == 100000000001UL || entityId == 100000000002UL || entityId == 100000000006UL)
            {
                RememberPlayerPosition(conn, position, $"AskUnitMoveAction entity={entityId}");
                return true;
            }

            return false;
        }

        private static void SendChangeVehicleInteractable(Connection conn, ulong vehicleId, bool interactable)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeVehicleInteractable,
            };
            rsp.SetArgs(MethodId.SyncChangeVehicleInteractable, new SyncChangeVehicleInteractable()
            {
                vehicleInstanceId = vehicleId,
                interactable = interactable
            });
            conn.SendPacket(rsp);
        }

        private static void SendUnitVehicleStatus(Connection conn, ulong vehicleId, int seatIndex, NewClientBoardingInfo.BoardingStatus status)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitVehicleStatus,
            };
            rsp.SetArgs(MethodId.SyncUnitVehicleStatus, new NewClientBoardingInfo()
            {
                EntityId = conn.GetCurrentSpirit().Id,
                SeatIndex = (byte)Math.Max(0, seatIndex),
                Status = status,
                VehicleUId = vehicleId
            });
            conn.SendPacket(rsp);
        }

        private static PlayerVehicleDriveStateInfo BuildVehicleDriveState(Connection conn, PlayerVehicleDriveStateInfo args, ulong vehicleId, int seatIndex, bool enterOrLeave)
        {
            return new PlayerVehicleDriveStateInfo()
            {
                Pid = conn.Pid,
                EnterOrLeave = enterOrLeave,
                VehicleEntityId = vehicleId,
                SeatIndex = seatIndex,
                IfForce = args?.IfForce ?? true,
                OpenDoorTypeId = args?.OpenDoorTypeId ?? 0,
                OpenDoorActionSpeed = args?.OpenDoorActionSpeed ?? 0,
                OpenDoorActionClipLength = args?.OpenDoorActionClipLength ?? 0
            };
        }

        private static void SendPlayerStartEnterOrExitVehicle(Connection conn, PlayerVehicleDriveStateInfo state)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerStartEnterOrExitVehicl,
            };
            rsp.SetArgs(MethodId.SyncPlayerStartEnterOrExitVehicl, state);
            conn.SendPacket(rsp);
        }

        private static void SendPlayerFinishEnterOrExitVehicle(Connection conn, PlayerVehicleDriveStateInfo state)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerFinishEnterOrExitVehic,
            };
            rsp.SetArgs(MethodId.SyncPlayerFinishEnterOrExitVehic, state);
            conn.SendPacket(rsp);
        }

        private static void SendPlayerVehicleStateChange(Connection conn, PlayerVehicleDriveStateInfo state)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerVehicleStateChange,
            };
            rsp.SetArgs(MethodId.SyncPlayerVehicleStateChange, state);
            conn.SendPacket(rsp);
        }

        private static void SendSyncEntityActionGroup(Connection conn, ulong pid, uint actionGroupId)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEntityActionGroup,
            };
            rsp.SetArgs(MethodId.SyncEntityActionGroup, new SyncEntityActionGroup()
            {
                Pid = pid,
                ActionGroupId = actionGroupId
            });
            conn.SendPacket(rsp);
        }

        private static void SendPlayerMoveToDriveSeat(Connection conn, ulong vehicleId)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerMoveToDriveSeat,
            };
            rsp.SetArgs(MethodId.SyncPlayerMoveToDriveSeat, new SyncPlayerMoveToDriveSeat()
            {
                pid = conn.Pid,
                vehicleEntityId = vehicleId
            });
            conn.SendPacket(rsp);
        }

        private static void SendManagedSpirit(Connection conn, MethodId methodId, int moveId)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)methodId,
            };
            rsp.SetArgs(methodId, new SyncManagedSpirit()
            {
                pid = conn.Pid,
                id = conn.GetCurrentSpirit().Id,
                moveId = moveId
            });
            conn.SendPacket(rsp);
        }

        private static void SendChangeVehicleController(Connection conn, ulong vehicleId, ulong controllerPid)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeVehicleController,
            };
            rsp.SetArgs(MethodId.SyncChangeVehicleController, new SyncChangeVehicleControllerArgs()
            {
                vehicleEntityId = vehicleId,
                newControllerPid = controllerPid
            });
            conn.SendPacket(rsp);
        }

        private static void SendPlayerExitVehicle(Connection conn, ulong vehicleId)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerExitVehicle,
            };
            rsp.SetArgs(MethodId.SyncPlayerExitVehicle, new SyncPlayerExitVehicleArgs()
            {
                vehicleEntityId = vehicleId,
                force = true,
                stopBeforeLeave = true
            });
            conn.SendPacket(rsp);
        }

        public static ulong GmSpawnVehicle(Connection conn, uint vehicleConfigId = DefaultGmDrivableVehicleConfigId, UXVector3 position = null, float? facing = null, uint colorConfigId = 0)
        {
            UXVector3 spawnPosition = GetGmVehicleSpawnPosition(conn, position);
            SpawnVehicle(conn, vehicleConfigId, spawnPosition, facing ?? conn.LastCameraFacing, colorConfigId);
            Console.WriteLine($"[GM Vehicle] Spawn vehicleConfigId={vehicleConfigId} vehicleEntityId={conn.LastSpawnedVehicleId} Pos=({spawnPosition?.X}, {spawnPosition?.Y}, {spawnPosition?.Z})");
            return conn.LastSpawnedVehicleId;
        }

        public static bool GmEnterVehicle(Connection conn, ulong vehicleId = 0, int seatIndex = 0)
        {
            vehicleId = vehicleId != 0 ? vehicleId : conn.LastSpawnedVehicleId;
            seatIndex = Math.Max(0, seatIndex);

            if (vehicleId == 0)
            {
                Console.WriteLine("[GM Vehicle] Cannot enter vehicle: no vehicle id is available.");
                return false;
            }

            // Determine action group ID based on seat index (from ForceEnterDriveLoopID config)
            uint actionGroupId = seatIndex switch
            {
                0 => 8502, // Driver seat
                1 => 8522, // Front passenger seat
                2 => 8612, // Back left passenger seat
                _ => 8502  // Default to driver
            };

            PlayerVehicleDriveStateInfo state = BuildVehicleDriveState(conn, null, vehicleId, seatIndex, true);
            SendChangeVehicleInteractable(conn, vehicleId, false);
            SendManagedSpirit(conn, MethodId.SyncRemoveManagedSpirit, 0);
            SendPlayerMoveToDriveSeat(conn, vehicleId);
            SendSyncEntityActionGroup(conn, conn.Pid, actionGroupId);
            SendUnitVehicleStatus(conn, vehicleId, seatIndex, NewClientBoardingInfo.BoardingStatus.OnVehicle);
            SendPlayerStartEnterOrExitVehicle(conn, state);
            SendPlayerVehicleStateChange(conn, state);
            SendChangeVehicleController(conn, vehicleId, conn.Pid);
            SendPlayerFinishEnterOrExitVehicle(conn, state);

            conn.CurrentVehicleId = vehicleId;
            conn.CurrentVehicleSeat = seatIndex;
            conn.GmVehicleControlActive = true;
            Console.WriteLine($"[GM Vehicle] Enter vehicleEntityId={vehicleId} seat={seatIndex}");
            return true;
        }

        public static bool GmExitVehicle(Connection conn)
        {
            ulong vehicleId = conn.CurrentVehicleId != 0 ? conn.CurrentVehicleId : conn.LastSpawnedVehicleId;
            int seatIndex = Math.Max(0, conn.CurrentVehicleSeat);

            if (vehicleId == 0)
            {
                Console.WriteLine("[GM Vehicle] Cannot exit vehicle: no vehicle id is available.");
                return false;
            }

            PlayerVehicleDriveStateInfo state = BuildVehicleDriveState(conn, null, vehicleId, seatIndex, false);
            SendPlayerExitVehicle(conn, vehicleId);
            SendManagedSpirit(conn, MethodId.SyncManagedSpirit, 0);
            SendManagedSpirit(conn, MethodId.SyncManagedAgent, 0);
            SendSyncEntityActionGroup(conn, conn.Pid, 1); // Reset to default action group
            SendUnitVehicleStatus(conn, vehicleId, seatIndex, NewClientBoardingInfo.BoardingStatus.NotOnVehicle);
            SendPlayerStartEnterOrExitVehicle(conn, state);
            SendPlayerVehicleStateChange(conn, state);
            SendChangeVehicleController(conn, vehicleId, 0);
            SendPlayerFinishEnterOrExitVehicle(conn, state);
            SendChangeVehicleInteractable(conn, vehicleId, true);

            conn.CurrentVehicleId = 0;
            conn.CurrentVehicleSeat = -1;
            conn.GmVehicleControlActive = true;
            Console.WriteLine($"[GM Vehicle] Exit vehicleEntityId={vehicleId}");
            return true;
        }

        public static ulong GmSpawnAndEnterVehicle(Connection conn, uint vehicleConfigId = DefaultGmDrivableVehicleConfigId, UXVector3 position = null, float? facing = null, int seatIndex = 0, uint colorConfigId = 0)
        {
            ulong vehicleId = GmSpawnVehicle(conn, vehicleConfigId, position, facing, colorConfigId);
            GmEnterVehicle(conn, vehicleId, seatIndex);
            return vehicleId;
        }

        public static void GmAddVehicle(Connection conn, uint vehicleConfigId)
        {
            conn.UnlockedVehicles ??= new HashSet<uint>(GetTestVehicleConfigIds());
            conn.UnlockedVehicles.Add(vehicleConfigId);
            Console.WriteLine($"[GM Vehicle] Added vehicleConfigId={vehicleConfigId} to unlocked vehicles");
            SendAllUnlockedVehicles(conn, 0, UxRpcPacketMode.Notify, MethodId.SyncAllUnlockedVehicles);
        }

        public static void GmAddAllVehicles(Connection conn)
        {
            conn.UnlockedVehicles ??= new HashSet<uint>(GetTestVehicleConfigIds());
            int before = conn.UnlockedVehicles.Count;
            foreach (uint id in GetTestVehicleConfigIds())
                conn.UnlockedVehicles.Add(id);
            int added = conn.UnlockedVehicles.Count - before;
            Console.WriteLine($"[GM Vehicle] Added all vehicles ({added} new, {conn.UnlockedVehicles.Count} total)");
            SendAllUnlockedVehicles(conn, 0, UxRpcPacketMode.Notify, MethodId.SyncAllUnlockedVehicles);
        }

        public static void GmDestroyVehicle(Connection conn, ulong vehicleId = 0)
        {
            vehicleId = vehicleId != 0 ? vehicleId : (conn.CurrentVehicleId != 0 ? conn.CurrentVehicleId : conn.LastSpawnedVehicleId);
            if (vehicleId == 0)
            {
                Console.WriteLine("[GM Vehicle] Cannot destroy: no vehicle available.");
                return;
            }

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestroyVehicle,
            };
            rsp.SetArgs(MethodId.SyncDestroyVehicle, new SyncDestroyVehicle()
            {
                vehicleEntityId = vehicleId
            });
            conn.SendPacket(rsp);

            // Remove from live list so the GM panel reflects the destroy.
            conn.MarkVehicleDestroyed(vehicleId);
            Game.VehicleSyncManager.UnregisterVehicle(conn, vehicleId);

            if (conn.CurrentVehicleId == vehicleId)
            {
                conn.CurrentVehicleId = 0;
                conn.CurrentVehicleSeat = -1;
            }
            if (conn.LastSpawnedVehicleId == vehicleId)
            {
                conn.LastSpawnedVehicleId = 0;
            }
            Console.WriteLine($"[GM Vehicle] Destroyed vehicleEntityId={vehicleId}");
        }

        public static void GmVehicleHorn(Connection conn, uint hornType = 0)
        {
            ulong vehicleId = conn.CurrentVehicleId != 0 ? conn.CurrentVehicleId : conn.LastSpawnedVehicleId;
            if (vehicleId == 0)
            {
                Console.WriteLine("[GM Vehicle] Cannot honk: no vehicle available.");
                return;
            }

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskVehicleHorn,
            };
            rsp.SetArgs(MethodId.AskVehicleHorn, new AskVehicleHorn()
            {
                vehicleEntityId = vehicleId,
                hornType = hornType
            });
            conn.SendPacket(rsp);
            Console.WriteLine($"[GM Vehicle] Horn vehicleEntityId={vehicleId} hornType={hornType}");
        }

        public static void GmChangeVehicleDoorState(Connection conn, byte doorIndex = 0, byte doorState = 1)
        {
            ulong vehicleId = conn.CurrentVehicleId != 0 ? conn.CurrentVehicleId : conn.LastSpawnedVehicleId;
            if (vehicleId == 0)
            {
                Console.WriteLine("[GM Vehicle] Cannot change door state: no vehicle available.");
                return;
            }

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ChangeVehicleDoorState,
            };
            rsp.SetArgs(MethodId.ChangeVehicleDoorState, new ChangeVehicleDoorState()
            {
                vehicleEntityId = vehicleId,
                doorIndex = doorIndex,
                doorState = doorState
            });
            conn.SendPacket(rsp);
            Console.WriteLine($"[GM Vehicle] DoorState vehicleEntityId={vehicleId} doorIndex={doorIndex} doorState={doorState}");
        }

        public static void GmSwitchSpirit(Connection conn, uint spiritId)
        {
            Console.WriteLine($"[GM Spirit] Switching to spiritId={spiritId}");
            Console.WriteLine($"[GM Spirit] Current spirit before switch: {conn.currentSpirit}");
            Console.WriteLine($"[GM Spirit] Available spirits: {string.Join(", ", conn.Spirits.Select(s => s.TemplateId))}");
            PerformSpiritSwitch(conn, spiritId, 0);
            Console.WriteLine($"[GM Spirit] Current spirit after switch: {conn.currentSpirit}");
        }

        public static void GmSetWeather(Connection conn, uint weatherId)
        {
            Console.WriteLine($"[GM Weather] Setting weather to typeId={weatherId}");
            conn.currentWeather = weatherId;
            
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerWeather,
            };
            rsp.SetArgs(MethodId.SyncPlayerWeather, new SyncPlayerWeather()
            {
                weatherTypeId = weatherId,
                nextWeatherTypeId = weatherId,
                transitionSecond = 2, // 2 second transition
            });
            conn.SendPacket(rsp);
        }

        public static void GmSetTime(Connection conn, int hour, int minute)
        {
            // Calculate time offset to make game time match requested hour:minute
            DateTime now = DateTime.Now;
            DateTime targetTime = new DateTime(now.Year, now.Month, now.Day, hour, minute, 0);
            
            // If target is in the past, assume it's for tomorrow
            if (targetTime < now)
                targetTime = targetTime.AddDays(1);
            
            conn.timeOffset = (targetTime - now).TotalSeconds;
            
            // Calculate raid day seconds (seconds since midnight for the target time)
            uint raidDaySeconds = (uint)(hour * 3600 + minute * 60);
            uint realTime = (uint)(DateTimeOffset.UtcNow.ToUnixTimeSeconds() + conn.timeOffset);
            
            Console.WriteLine($"[GM Time] Setting time to {hour:D2}:{minute:D2} (offset={conn.timeOffset:F0}s, raidDaySeconds={raidDaySeconds})");
            
            // Send SyncPlayerCurrentTime packet to client
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerCurrentTime,
            };
            rsp.SetArgs(MethodId.SyncPlayerCurrentTime, new SyncPlayerCurrentTime()
            {
                realTime = realTime,
                raidDaySeconds = raidDaySeconds,
                fix = true,
                transitionSecond = 2, // 2 second transition
                reason = SyncPlayerCurrentTime.RaidTimeAndWeatherChangeReason.Gm,
            });
            conn.SendPacket(rsp);
        }

        // Phone app handlers for weather and time control
        [Handler(MethodId.GmSetWeather)]
        public static void GmSetWeatherHandler(Connection conn, UxRpcMessage msg)
        {
            // Get weather ID from args
            var args = msg.GetArgs<GmSetWeatherArgs>();
            uint weatherId = args.weatherId;
            
            Console.WriteLine($"[Phone Weather] Request to set weather to typeId={weatherId}");
            GmSetWeather(conn, weatherId);
            
            // Send success response
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetWeather);
        }

        public class GmSetWeatherArgs : SerializedClass
        {
            public uint weatherId;
            
            public GmSetWeatherArgs()
            {
                onlyFields = true;
            }
        }

        [Handler(MethodId.GmSetTime)]
        public static void GmSetTimeHandler(Connection conn, UxRpcMessage msg)
        {
            // Get time from args
            var args = msg.GetArgs<GmSetTimeArgs>();
            int hour = args.hour;
            int minute = args.minute;
            
            Console.WriteLine($"[Phone Time] Request to set time to {hour:D2}:{minute:D2}");
            GmSetTime(conn, hour, minute);
            
            // Send success response
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetTime);
        }

        public class GmSetTimeArgs : SerializedClass
        {
            public int hour;
            public int minute;
            
            public GmSetTimeArgs()
            {
                onlyFields = true;
            }
        }

        [Handler(MethodId.AskPlayerStartEnterOrExitVehicle)]
        public static void AskPlayerStartEnterOrExitVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                VehicleLogger.Log($"===== AskPlayerStartEnterOrExitVehicle CALLED =====");
                PlayerVehicleDriveStateInfo args = msg.GetArgs<PlayerVehicleDriveStateInfo>();
                ulong vehicleId = args.VehicleEntityId != 0 ? args.VehicleEntityId : conn.LastDetectedVehicleId != 0 ? conn.LastDetectedVehicleId : conn.LastSpawnedVehicleId;
                int seatIndex = args.SeatIndex >= 0 ? args.SeatIndex : 0;
                VehicleLogger.Log($"Args: Pid={args.Pid} EnterOrLeave={args.EnterOrLeave} VehicleId={args.VehicleEntityId} Seat={args.SeatIndex} Force={args.IfForce} DoorType={args.OpenDoorTypeId}");
                VehicleLogger.Log($"State: CurrentVehicleId={conn.CurrentVehicleId} LastDetectedId={conn.LastDetectedVehicleId} LastSpawnedId={conn.LastSpawnedVehicleId} ResolvedVehicleId={vehicleId} Mode={msg.Mode}");
                
                if (conn.GmVehicleControlActive && msg.Mode == UxRpcPacketMode.Notify)
                {
                    VehicleLogger.Log("Ignoring echo during GM vehicle control");
                    return;
                }

                bool isLeaving = conn.CurrentVehicleId != 0;
                bool enterOrLeave = !isLeaving;
                PlayerVehicleDriveStateInfo state = BuildVehicleDriveState(conn, args, vehicleId, seatIndex, enterOrLeave);

                VehicleLogger.Log($"ServerAction={(isLeaving ? "LEAVE" : "ENTER")} enterOrLeave={enterOrLeave}");

                UxRpcMessage rsp = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Return,
                    RpcInvokeId = msg.RpcInvokeId,
                    RpcRetcode = 0,
                    RpcMethodId = (int)MethodId.AskPlayerStartEnterOrExitVehicle,
                };
                conn.SendPacket(rsp);
                VehicleLogger.Log("Sent Return (retcode=0)");

                if (vehicleId == 0)
                {
                    VehicleLogger.Log("ABORT: No vehicle ID available");
                    return;
                }

                if (isLeaving)
                {
                    VehicleLogger.Log("LEAVE sequence: ExitVehicle -> UnitVehicleStatus(NotOnVehicle) -> StartEnterOrExit -> VehicleStateChange -> ChangeController(0) -> ManagedSpirit+Agent");
                    SendPlayerExitVehicle(conn, vehicleId);
                    SendUnitVehicleStatus(conn, vehicleId, seatIndex, NewClientBoardingInfo.BoardingStatus.NotOnVehicle);
                    SendPlayerStartEnterOrExitVehicle(conn, state);
                    SendPlayerVehicleStateChange(conn, state);
                    SendChangeVehicleController(conn, vehicleId, 0);
                    SendManagedSpirit(conn, MethodId.SyncManagedSpirit, 0);
                    SendManagedSpirit(conn, MethodId.SyncManagedAgent, 0);

                    conn.CurrentVehicleId = 0;
                    conn.CurrentVehicleSeat = -1;
                    conn.GmVehicleControlActive = false;
                    VehicleLogger.Log("LEAVE complete - player now on foot");
                }
                else
                {
                    VehicleLogger.Log("ENTER sequence: ChangeInteractable(false) -> RemoveManagedSpirit -> MoveToDriveSeat -> UnitVehicleStatus(OnVehicle) -> StartEnterOrExit -> VehicleStateChange -> ChangeController(Pid) -> FinishEnterOrExit");
                    VehicleLogger.Log("Sending ChangeInteractable(false)");
                    SendChangeVehicleInteractable(conn, vehicleId, false);
                    VehicleLogger.Log("Sending RemoveManagedSpirit");
                    SendManagedSpirit(conn, MethodId.SyncRemoveManagedSpirit, 0);
                    VehicleLogger.Log("Sending MoveToDriveSeat");
                    SendPlayerMoveToDriveSeat(conn, vehicleId);
                    VehicleLogger.Log("Sending UnitVehicleStatus(OnVehicle)");
                    SendUnitVehicleStatus(conn, vehicleId, seatIndex, NewClientBoardingInfo.BoardingStatus.OnVehicle);
                    VehicleLogger.Log("Sending StartEnterOrExit");
                    SendPlayerStartEnterOrExitVehicle(conn, state);
                    VehicleLogger.Log("Sending VehicleStateChange");
                    SendPlayerVehicleStateChange(conn, state);
                    VehicleLogger.Log("Sending ChangeController(Pid)");
                    SendChangeVehicleController(conn, vehicleId, conn.Pid);
                    VehicleLogger.Log("Sending FinishEnterOrExit");
                    SendPlayerFinishEnterOrExitVehicle(conn, state);

                    conn.CurrentVehicleId = vehicleId;
                    conn.CurrentVehicleSeat = seatIndex;
                    VehicleLogger.Log($"ENTER complete - player now in vehicle {vehicleId} seat {seatIndex}");
                }
            }
            catch (Exception ex)
            {
                VehicleLogger.Log($"ERROR: {ex.Message}\n{ex.StackTrace}");
            }
        }

        [Handler(MethodId.AskPlayerFinishEnterOrExitVehicl)]
        public static void AskPlayerFinishEnterOrExitVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            PlayerVehicleDriveStateInfo args = msg.GetArgs<PlayerVehicleDriveStateInfo>();
            ulong vehicleId = args.VehicleEntityId != 0 ? args.VehicleEntityId : conn.LastDetectedVehicleId != 0 ? conn.LastDetectedVehicleId : conn.LastSpawnedVehicleId;
            int seatIndex = args.SeatIndex >= 0 ? args.SeatIndex : Math.Max(0, conn.CurrentVehicleSeat);
            if (conn.GmVehicleControlActive && msg.Mode == UxRpcPacketMode.Notify)
            {
                Console.WriteLine($"[Vehicle] Ignoring client FinishEnterOrExit echo during GM vehicle control. RequestedEnterOrLeave={args.EnterOrLeave} VehicleId={vehicleId} Seat={seatIndex} CurrentVehicleId={conn.CurrentVehicleId}");
                return;
            }

            bool isOnVehicle = conn.CurrentVehicleId != 0;
            PlayerVehicleDriveStateInfo state = BuildVehicleDriveState(conn, args, vehicleId, seatIndex, isOnVehicle);

            Console.WriteLine($"[Vehicle] FinishEnterOrExit Pid={args.Pid} RequestedEnterOrLeave={args.EnterOrLeave} ServerOnVehicle={isOnVehicle} VehicleId={vehicleId} Seat={seatIndex}");
            SendPlayerFinishEnterOrExitVehicle(conn, state);

            if (!isOnVehicle && vehicleId != 0)
                SendChangeVehicleInteractable(conn, vehicleId, true);
        }

        [Handler(MethodId.AskSwitchSpiritComplete)]
        public static void AskSwitchSpiritCompleteHandler(Connection conn, UxRpcMessage msg)
        {
            // Send Return first
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSwitchSpiritComplete,
            };
            conn.SendPacket(rsp);

            // ANKIRA compat: after return, send full unit runtime state for the new spirit
            // HP → Attrs → States → SkillChrg → UrbanAttrs → Buffs
            conn.SendUnitRuntimeState();

            // Re-sync weapon detail and equip current weapon for the new spirit
            conn.SyncWeapons();
            conn.SyncWeapon(conn.WeaponIndex);

            // Re-sync attributes for the new spirit
            conn.SyncAttributes();
            conn.SyncBuffs();

            // Re-sync managed spirit + agent for the new spirit (fix: frozen after switch)
            SendManagedSpirit(conn, MethodId.SyncManagedSpirit, 0);
            SendManagedSpirit(conn, MethodId.SyncManagedAgent, 0);

            // Position sync for the new spirit entity (fix: fall-through-map on switch complete)
            conn.SendSyncPosition(conn.GetCurrentSpirit().Id);

            Console.WriteLine($"[SpiritSwitch] Complete - full runtime state sent for spirit {conn.GetCurrentSpirit().TemplateId}");
        }

        [Handler(MethodId.AskSwitchSpiritByTaskRole)]
        public static void AskSwitchSpiritByTaskRoleHandler(Connection conn, UxRpcMessage msg)
        {
            AskSwitchSpirit args = msg.GetArgs<AskSwitchSpirit>();
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSwitchSpiritByTaskRole,
            };
            conn.SendPacket(rsp);

            // Perform the spirit switch
            PerformSpiritSwitch(conn, args.spiritId, msg.RpcInvokeId);
        }

        [Handler(MethodId.AskSwitchSpiritByTaskEvent)]
        public static void AskSwitchSpiritByTaskEventHandler(Connection conn, UxRpcMessage msg)
        {
            AskSwitchSpirit args = msg.GetArgs<AskSwitchSpirit>();
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSwitchSpiritByTaskEvent,
            };
            conn.SendPacket(rsp);

            // Perform the spirit switch
            PerformSpiritSwitch(conn, args.spiritId, msg.RpcInvokeId);
        }

        private static void PerformSpiritSwitch(Connection conn, uint spiritId, int rpcInvokeId)
        {
            Console.WriteLine($"[SpiritSwitch] In-situ switch to templateId={spiritId} (ANKIRA-compatible)");

            uint oldSpiritId = conn.currentSpirit;
            conn.currentSpirit = spiritId;

            var targetSpirit = conn.Spirits.FirstOrDefault(s => s.TemplateId == spiritId);
            ulong spiritInstanceId = targetSpirit?.Id ?? 100000000000;

            // 1. SyncSwitchSpiritConfigId - forward client's spiritId (ANKIRA line 288)
            UxRpcMessage rspCfg = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSwitchSpiritConfigId,
            };
            rspCfg.Args = BitConverter.GetBytes(spiritId);
            conn.SendPacket(rspCfg);

            // 2. SyncPlayerWeather (ANKIRA line 292)
            UxRpcMessage rspWeather = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerWeather,
            };
            rspWeather.SetArgs(MethodId.SyncPlayerWeather, new SyncPlayerWeather()
            {
                weatherTypeId = conn.currentWeather,
                nextWeatherTypeId = conn.currentWeather,
                transitionSecond = 1,
            });
            conn.SendPacket(rspWeather);

            // 3. SyncPlayerCurrentSpirit (ANKIRA line 296-298)
            UxRpcMessage rspCurrent = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerCurrentSpirit,
            };
            rspCurrent.SetArgs(MethodId.SyncPlayerCurrentSpirit, new SyncPlayerCurrentSpirit()
            {
                pid = conn.Pid,
                spiritId = spiritInstanceId,
                templateId = spiritId,
                isAgentSwitch = false,
            });
            conn.SendPacket(rspCurrent);

            // 4. Return for AskSwitchSpirit (ANKIRA line 300)
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = rpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSwitchSpirit,
            };
            conn.SendPacket(rsp);

            // 5. SyncPlayerSwitchSpiritInSitu (ANKIRA line 302-304)
            UxRpcMessage rspInSitu = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerSwitchSpiritInSitu,
            };
            rspInSitu.SetArgs(MethodId.SyncPlayerSwitchSpiritInSitu, new SyncPlayerSwitchSpiritInSitu()
            {
                pid = conn.Pid,
                spiritId = spiritId,
                newSpiritInstanceId = spiritInstanceId,
            });
            conn.SendPacket(rspInSitu);

            // 5b. SyncManagedSpirit + SyncManagedAgent - explicitly transfer control (fix: frozen after switch)
            SendManagedSpirit(conn, MethodId.SyncManagedSpirit, 0);
            SendManagedSpirit(conn, MethodId.SyncManagedAgent, 0);

            // 5c. SyncUnitPositionAndFacing - tell client WHERE the new spirit entity is (fix: fall-through-map)
            conn.SendSyncPosition(spiritInstanceId);

            // 5d. SyncSpiritAbilities - sync the new spirit's abilities (fix: telekinesis system locked after switch)
            MissingSyncHandlers.SendSyncSpiritAbilities(conn);

            // 6. SyncPlayerCurrentSpirit again (ANKIRA line 306)
            UxRpcMessage rspCurrent2 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerCurrentSpirit,
            };
            rspCurrent2.SetArgs(MethodId.SyncPlayerCurrentSpirit, new SyncPlayerCurrentSpirit()
            {
                pid = conn.Pid,
                spiritId = spiritInstanceId,
                templateId = spiritId,
                isAgentSwitch = false,
            });
            conn.SendPacket(rspCurrent2);

            Console.WriteLine($"[SpiritSwitch] In-situ switch complete: {oldSpiritId} -> {spiritId}");
        }

        [Handler(MethodId.AskUnitMoveAction)]
        public static void AskUnitMoveActionHandler(Connection conn, UxRpcMessage msg)
        {
            TryRememberUnitMoveActionPosition(conn, msg);
        }

        [Handler(MethodId.AskVehicleMove)]
        public static void AskVehicleMoveHandle(Connection conn, UxRpcMessage msg)
        {
            RaidVehicleSyncData args = msg.GetArgs<RaidVehicleSyncData>();
            if (conn.CurrentVehicleId != 0 && args.Id == conn.CurrentVehicleId)
            {
                RememberPlayerPosition(conn, args.Position, $"AskVehicleMove vehicle={args.Id}");
                conn.LastVehicleSpawnPosition = new UXVector3()
                {
                    X = args.Position.X,
                    Y = args.Position.Y,
                    Z = args.Position.Z
                };
                conn.LastVehicleFacing = args.facingDirection;
            }

            // Track full vehicle state in VehicleSyncManager (sync tree data)
            Game.VehicleSyncManager.OnVehicleMove(conn, args);

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncVehicleMove,
            };
            rsp.SetArgs(MethodId.SyncVehicleMove, args);
            conn.SendPacket(rsp);
        }
        [Handler(MethodId.AskSwitchSpirit)]
        public static void AskSwitchSpiritHandler(Connection conn, UxRpcMessage msg)
        {
            AskSwitchSpirit args = msg.GetArgs<AskSwitchSpirit>();

            Console.WriteLine($"[SpiritSwitch] AskSwitchSpirit: spiritId={args.spiritId}");

            // Perform the spirit switch - matches ANKIRA sendSwitchSpirit exactly
            PerformSpiritSwitch(conn, args.spiritId, msg.RpcInvokeId);
        }

        [Handler(MethodId.ReportPreSwitchSpiritFinish)]
        public static void ReportPreSwitchSpiritFinishHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[TaffyWheel] ReportPreSwitchSpiritFinish received");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportPreSwitchSpiritFinish,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GmSwitchSpiritHere)]
        public static void GmSwitchSpiritHereHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskSwitchSpirit>();
            Console.WriteLine($"[SpiritSwitch] GmSwitchSpiritHere: spiritId={args.spiritId}");

            // GM switch: send the lightweight sequence without the AskSwitchSpirit Return
            // (GM has its own Return)
            uint spiritId = args.spiritId;
            uint oldSpiritId = conn.currentSpirit;
            conn.currentSpirit = spiritId;

            var targetSpirit = conn.Spirits.FirstOrDefault(s => s.TemplateId == spiritId);
            ulong spiritInstanceId = targetSpirit?.Id ?? 100000000000;

            // SyncSwitchSpiritConfigId
            UxRpcMessage rspCfg = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSwitchSpiritConfigId,
            };
            rspCfg.Args = BitConverter.GetBytes(spiritId);
            conn.SendPacket(rspCfg);

            // SyncPlayerWeather
            UxRpcMessage rspWeather = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerWeather,
            };
            rspWeather.SetArgs(MethodId.SyncPlayerWeather, new SyncPlayerWeather()
            {
                weatherTypeId = conn.currentWeather,
                nextWeatherTypeId = conn.currentWeather,
                transitionSecond = 1,
            });
            conn.SendPacket(rspWeather);

            // SyncPlayerCurrentSpirit
            UxRpcMessage rspCurrent = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerCurrentSpirit,
            };
            rspCurrent.SetArgs(MethodId.SyncPlayerCurrentSpirit, new SyncPlayerCurrentSpirit()
            {
                pid = conn.Pid,
                spiritId = spiritInstanceId,
                templateId = spiritId,
                isAgentSwitch = false,
            });
            conn.SendPacket(rspCurrent);

            // SyncPlayerSwitchSpiritInSitu
            UxRpcMessage rspInSitu = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerSwitchSpiritInSitu,
            };
            rspInSitu.SetArgs(MethodId.SyncPlayerSwitchSpiritInSitu, new SyncPlayerSwitchSpiritInSitu()
            {
                pid = conn.Pid,
                spiritId = spiritId,
                newSpiritInstanceId = spiritInstanceId,
            });
            conn.SendPacket(rspInSitu);

            // Position sync for the new spirit entity (fix: fall-through-map on GM switch)
            conn.SendSyncPosition(spiritInstanceId);

            // SyncPlayerCurrentSpirit again
            UxRpcMessage rspCurrent2 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerCurrentSpirit,
            };
            rspCurrent2.SetArgs(MethodId.SyncPlayerCurrentSpirit, new SyncPlayerCurrentSpirit()
            {
                pid = conn.Pid,
                spiritId = spiritInstanceId,
                templateId = spiritId,
                isAgentSwitch = false,
            });
            conn.SendPacket(rspCurrent2);

            // Return for GmSwitchSpiritHere
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.GmSwitchSpiritHere,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskSwitchWeapon)]
        public static void AskSwitchWeaponHandler(Connection conn, UxRpcMessage msg)
        {
            AskSwitchWeapon args = msg.GetArgs<AskSwitchWeapon>();
            if (args.index < 0 || args.index >= conn.Weapons.Count)
            {
                Console.WriteLine($"[Weapon] AskSwitchWeapon invalid index={args.index}, count={conn.Weapons.Count}");
                return;
            }
            conn.SyncWeapon(args.index);
        }

        // ==================== DESTRUCTIBLE OBJECT HANDLERS ====================

        [Handler(MethodId.AskHandHoldDestructibleObject)]
        public static void AskHandHoldDestructibleObjectHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskHandHoldDestructibleObjectArgs>();
            ulong objId = args.DestructibleId;

            if (DestructibleObjectManager.TryGetObject(objId, out var obj) && obj.State == 0)
            {
                obj.State = 1;
                obj.HolderPid = conn.Pid;
                Console.WriteLine($"[Telekinesis] Player {conn.Pid} grabbed object {objId}");

                UxRpcMessage rsp = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Return,
                    RpcInvokeId = msg.RpcInvokeId,
                    RpcRetcode = 0,
                    RpcMethodId = (int)MethodId.AskHandHoldDestructibleObject,
                };
                conn.SendPacket(rsp);

                UxRpcMessage sync = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Notify,
                    RpcInvokeId = 0,
                    RpcRetcode = 0,
                    RpcMethodId = (int)MethodId.SyncDestructibleObjectAdd,
                };
                sync.SetArgs(MethodId.SyncDestructibleObjectAdd, obj.ToDestructibleInfo());
                conn.SendPacket(sync);
            }
            else
            {
                UxRpcMessage rsp = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Return,
                    RpcInvokeId = msg.RpcInvokeId,
                    RpcRetcode = (uint)UxMessageRetcode.DestructibleNotFound,
                    RpcMethodId = (int)MethodId.AskHandHoldDestructibleObject,
                };
                conn.SendPacket(rsp);
            }
        }

        [Handler(MethodId.AskEnterHoldDestructibleObject)]
        public static void AskEnterHoldDestructibleObjectHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskEnterHoldDestructibleObjectArgs>();
            ulong objId = args.DestructibleId;

            if (DestructibleObjectManager.TryGetObject(objId, out var obj) && obj.State == 1 && obj.HolderPid == conn.Pid)
            {
                obj.State = 1;
                Console.WriteLine($"[Telekinesis] Player {conn.Pid} entered hold mode on object {objId}");

                UxRpcMessage rsp = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Return,
                    RpcInvokeId = msg.RpcInvokeId,
                    RpcRetcode = 0,
                    RpcMethodId = (int)MethodId.AskEnterHoldDestructibleObject,
                };
                conn.SendPacket(rsp);
            }
            else
            {
                SendEmptySuccessReturn(conn, msg, MethodId.AskEnterHoldDestructibleObject);
            }
        }

        [Handler(MethodId.AskLeaveHoldDestructibleObject)]
        public static void AskLeaveHoldDestructibleObjectHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskLeaveHoldDestructibleObjectArgs>();
            ulong objId = args.DestructibleId;

            if (DestructibleObjectManager.TryGetObject(objId, out var obj) && obj.HolderPid == conn.Pid)
            {
                obj.State = 0;
                obj.HolderPid = 0;
                Console.WriteLine($"[Telekinesis] Player {conn.Pid} released object {objId}");

                UxRpcMessage rsp = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Return,
                    RpcInvokeId = msg.RpcInvokeId,
                    RpcRetcode = 0,
                    RpcMethodId = (int)MethodId.AskLeaveHoldDestructibleObject,
                };
                conn.SendPacket(rsp);
            }
            else
            {
                SendEmptySuccessReturn(conn, msg, MethodId.AskLeaveHoldDestructibleObject);
            }
        }

        [Handler(MethodId.AskRaiseDestructibleObject)]
        public static void AskRaiseDestructibleObjectHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskRaiseDestructibleObjectArgs>();
            ulong objId = args.DestructibleId;

            if (DestructibleObjectManager.TryGetObject(objId, out var obj) && obj.HolderPid == conn.Pid)
            {
                Console.WriteLine($"[Telekinesis] Player {conn.Pid} raised object {objId}");

                UxRpcMessage rsp = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Return,
                    RpcInvokeId = msg.RpcInvokeId,
                    RpcRetcode = 0,
                    RpcMethodId = (int)MethodId.AskRaiseDestructibleObject,
                };
                conn.SendPacket(rsp);
            }
            else
            {
                SendEmptySuccessReturn(conn, msg, MethodId.AskRaiseDestructibleObject);
            }
        }

        [Handler(MethodId.AskPutDownDestructibleObject)]
        public static void AskPutDownDestructibleObjectHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPutDownDestructibleObjectArgs>();
            ulong objId = args.DestructibleId;

            if (DestructibleObjectManager.TryGetObject(objId, out var obj) && obj.HolderPid == conn.Pid)
            {
                obj.State = 0;
                obj.HolderPid = 0;
                Console.WriteLine($"[Telekinesis] Player {conn.Pid} put down object {objId}");

                UxRpcMessage rsp = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Return,
                    RpcInvokeId = msg.RpcInvokeId,
                    RpcRetcode = 0,
                    RpcMethodId = (int)MethodId.AskPutDownDestructibleObject,
                };
                conn.SendPacket(rsp);
            }
            else
            {
                SendEmptySuccessReturn(conn, msg, MethodId.AskPutDownDestructibleObject);
            }
        }

        [Handler(MethodId.AskMoveDestructibleObject)]
        public static void AskMoveDestructibleObjectHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskMoveDestructibleObjectArgs>();
            ulong objId = args.DestructibleId;

            if (DestructibleObjectManager.TryGetObject(objId, out var obj) && obj.HolderPid == conn.Pid)
            {
                obj.Position = args.Position;
                obj.Facing = args.Facing;
            }

            SendEmptySuccessReturn(conn, msg, MethodId.AskMoveDestructibleObject);
        }

        [Handler(MethodId.AskBreakDestructibleObject)]
        public static void AskBreakDestructibleObjectHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskBreakDestructibleObjectArgs>();
            ulong objId = args.DestructibleId;

            if (DestructibleObjectManager.TryGetObject(objId, out var obj))
            {
                DestructibleObjectManager.BreakObject(objId);
                Console.WriteLine($"[Destructible] Object {objId} broken");

                UxRpcMessage rsp = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Return,
                    RpcInvokeId = msg.RpcInvokeId,
                    RpcRetcode = 0,
                    RpcMethodId = (int)MethodId.AskBreakDestructibleObject,
                };
                conn.SendPacket(rsp);

                UxRpcMessage sync = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Notify,
                    RpcInvokeId = 0,
                    RpcRetcode = 0,
                    RpcMethodId = (int)MethodId.SyncDestructibleObjectBreak,
                };
                sync.SetArgs(MethodId.SyncDestructibleObjectBreak, new SyncDestructibleObjectBreakData()
                {
                    DestructibleId = objId
                });
                conn.SendPacket(sync);
            }
            else
            {
                SendEmptySuccessReturn(conn, msg, MethodId.AskBreakDestructibleObject);
            }
        }

        [Handler(MethodId.AskDestroyDestructibleObject)]
        public static void AskDestroyDestructibleObjectHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskDestroyDestructibleObjectArgs>();
            ulong objId = args.DestructibleId;

            if (DestructibleObjectManager.RemoveObject(objId))
            {
                Console.WriteLine($"[Destructible] Object {objId} destroyed");

                UxRpcMessage rsp = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Return,
                    RpcInvokeId = msg.RpcInvokeId,
                    RpcRetcode = 0,
                    RpcMethodId = (int)MethodId.AskDestroyDestructibleObject,
                };
                conn.SendPacket(rsp);

                UxRpcMessage sync = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Notify,
                    RpcInvokeId = 0,
                    RpcRetcode = 0,
                    RpcMethodId = (int)MethodId.SyncDestructibleObjectRemove,
                };
                sync.SetArgs(MethodId.SyncDestructibleObjectRemove, new DestructibleRemoveEntry()
                {
                    DestructibleId = objId
                });
                conn.SendPacket(sync);
            }
            else
            {
                SendEmptySuccessReturn(conn, msg, MethodId.AskDestroyDestructibleObject);
            }
        }

                [Handler(MethodId.AskQDestructible)]
        public static void AskQDestructibleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskQDestructible called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskQDestructible);
        }

                [Handler(MethodId.AskAddDestructibleHook)]
        public static void AskAddDestructibleHookHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskAddDestructibleHook called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAddDestructibleHook);
        }

                [Handler(MethodId.AskRemoveDestructibleHook)]
        public static void AskRemoveDestructibleHookHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskRemoveDestructibleHook called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskRemoveDestructibleHook);
        }

                [Handler(MethodId.AskMergeDestructibleObjects)]
        public static void AskMergeDestructibleObjectsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskMergeDestructibleObjects called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskMergeDestructibleObjects);
        }

                [Handler(MethodId.AskSelectChaosObject)]
        public static void AskSelectChaosObjectHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Chaos] AskSelectChaosObject called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSelectChaosObject);
        }

                [Handler(MethodId.AskChangeDestructibleHp)]
        public static void AskChangeDestructibleHpHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<DestructibleInfo>();
                Console.WriteLine($"[Destructible] HP change: id={args.DestructibleId} hp={args.Hp}/{args.MaxHp}");
            }
            catch
            {
                Console.WriteLine("[Destructible] HP change (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskChangeDestructibleHp);
        }

                [Handler(MethodId.AskAddDestructibleHp)]
        public static void AskAddDestructibleHpHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<DestructibleInfo>();
                Console.WriteLine($"[Destructible] HP add: id={args.DestructibleId} hp={args.Hp}");
            }
            catch
            {
                Console.WriteLine("[Destructible] HP add (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskAddDestructibleHp);
        }

                [Handler(MethodId.RefreshSceneDestructible)]
        public static void RefreshSceneDestructibleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] RefreshSceneDestructible called");
            
            // Trigger AOI refresh for destructible objects
            if (conn.AOIInitialized)
            {
                var pos = conn.LastKnownPlayerPosition;
                var (gx, gz) = Game.AOIGridManager.WorldToGrid(pos.X, pos.Z);
                
                // Re-send AOI increase to refresh destructible objects
                var destructibleCells = Game.AOIGridManager.ComputeVisibleCells(gx, gz, Game.AOIGridManager.DestructibleRange);
                Game.AOIGridManager.SendDestructibleAOIIncrease(conn, gx, gz, destructibleCells, AnantaTestGameServer.Methods.AoiAddAndRemoveReason.AOIMove);
                
                Console.WriteLine($"[Game] RefreshSceneDestructible: AOI refreshed at grid ({gx},{gz})");
            }
            else
            {
                Console.WriteLine("[Game] RefreshSceneDestructible: AOI not initialized, skipping");
            }
            
            SendEmptySuccessReturn(conn, msg, MethodId.RefreshSceneDestructible);
        }

                [Handler(MethodId.AskItemDestructibleCreate)]
        public static void AskItemDestructibleCreateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Item] AskItemDestructibleCreate called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskItemDestructibleCreate);
        }

                [Handler(MethodId.AskSyncDestructibleSyncInfos)]
        public static void AskSyncDestructibleSyncInfosHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<DestructibleSyncInfo>();
                Console.WriteLine($"[Destructible] Sync infos: id={args.Id} hp={args.Hp}");
                SendNotify(conn, MethodId.SyncDestructibleSyncInfos, new DestructibleSyncInfo()
                {
                    Id = args.Id,
                    Frame = args.Frame,
                    Position = args.Position,
                    Facing = args.Facing,
                    Speed = args.Speed,
                    Hp = args.Hp,
                    mindState = args.mindState,
                    HookUnitId = args.HookUnitId,
                    HostPlayerID = args.HostPlayerID
                });
            }
            catch
            {
                Console.WriteLine("[Destructible] Sync infos (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSyncDestructibleSyncInfos);
        }

                [Handler(MethodId.AskBreakDestructibleObjects)]
        public static void AskBreakDestructibleObjectsHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<SyncDestructibleObjectRemoveListData>();
                int count = args.Objects?.Count ?? 0;
                Console.WriteLine($"[Destructible] Break batch: {count} objects");

                if (args.Objects != null)
                {
                    foreach (var obj in args.Objects)
                    {
                        SendNotify(conn, MethodId.SyncDestructibleObjectBreak, new SyncDestructibleObjectBreakData()
                        {
                            DestructibleId = obj.DestructibleId
                        });
                    }
                }
            }
            catch
            {
                Console.WriteLine("[Destructible] Break batch (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskBreakDestructibleObjects);
        }

                [Handler(MethodId.AskMoveDestructibleObjects)]
        public static void AskMoveDestructibleObjectsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskMoveDestructibleObjects called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskMoveDestructibleObjects);
        }

                [Handler(MethodId.AskDestroyDestructibleObjects)]
        public static void AskDestroyDestructibleObjectsHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<SyncDestructibleObjectRemoveListData>();
                int count = args.Objects?.Count ?? 0;
                Console.WriteLine($"[Destructible] Destroy batch: {count} objects");

                if (args.Objects != null && count > 0)
                {
                    SendNotify(conn, MethodId.SyncDestructibleObjectRemoveList, new SyncDestructibleObjectRemoveListData()
                    {
                        Objects = args.Objects
                    });
                }
            }
            catch
            {
                Console.WriteLine("[Destructible] Destroy batch (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskDestroyDestructibleObjects);
        }

                [Handler(MethodId.AskCreateDynamicGadget)]
        public static void AskCreateDynamicGadgetHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<GadgetEntityInfo>();
                Console.WriteLine($"[Gadget] Create dynamic: inst={args.InstanceId} pos=({args.Position?.X:F1},{args.Position?.Y:F1},{args.Position?.Z:F1})");
                SendNotify(conn, MethodId.SyncGadgetAdd, new GadgetEntityInfo()
                {
                    InstanceId = args.InstanceId,
                    Position = args.Position,
                    Facing = args.Facing,
                    StateIndexDic = args.StateIndexDic,
                    NavId = args.NavId
                });
            }
            catch
            {
                Console.WriteLine("[Gadget] Create dynamic (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskCreateDynamicGadget);
        }

                [Handler(MethodId.AskSceneItemChangeState)]
        public static void AskSceneItemChangeStateHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<DestructibleInfo>();
                Console.WriteLine($"[Item] Scene state change: id={args.DestructibleId} state={args.State}");
                SendNotify(conn, MethodId.SyncSceneItemStateChange, new DestructibleInfo()
                {
                    DestructibleId = args.DestructibleId,
                    ConfigId = args.ConfigId,
                    Position = args.Position,
                    Facing = args.Facing,
                    Hp = args.Hp,
                    MaxHp = args.MaxHp,
                    State = args.State,
                    HolderPid = args.HolderPid
                });
            }
            catch
            {
                Console.WriteLine("[Item] Scene state change (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSceneItemChangeState);
        }

                [Handler(MethodId.AskSceneItemSendSignal)]
        public static void AskSceneItemSendSignalHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<DestructibleInfo>();
                Console.WriteLine($"[Item] Scene signal: id={args.DestructibleId} config={args.ConfigId}");
                SendNotify(conn, MethodId.SyncSceneItemSignalSend, new DestructibleInfo()
                {
                    DestructibleId = args.DestructibleId,
                    ConfigId = args.ConfigId,
                    State = args.State
                });
            }
            catch
            {
                Console.WriteLine("[Item] Scene signal (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSceneItemSendSignal);
        }

                [Handler(MethodId.CheckCanOccupySceneItem)]
        public static void CheckCanOccupySceneItemHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<DestructibleInfo>();
                Console.WriteLine($"[Item] Check occupy: id={args.DestructibleId}");
            }
            catch
            {
                Console.WriteLine("[Item] Check occupy (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.CheckCanOccupySceneItem);
        }

                [Handler(MethodId.ReleaseOccupySceneItem)]
        public static void ReleaseOccupySceneItemHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<DestructibleInfo>();
                Console.WriteLine($"[Item] Release occupy: id={args.DestructibleId}");
                SendNotify(conn, MethodId.SyncSceneItemOccupantChange, new SceneItemOccupantInfo()
                {
                    Pid = conn.Pid,
                    Index = 0,
                    IsState = false
                });
            }
            catch
            {
                Console.WriteLine("[Item] Release occupy (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.ReleaseOccupySceneItem);
        }

                [Handler(MethodId.AskChangeSceneItemQuality)]
        public static void AskChangeSceneItemQualityHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Item] AskChangeSceneItemQuality called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChangeSceneItemQuality);
        }

                [Handler(MethodId.AskChangeSceneItemExtraIndex)]
        public static void AskChangeSceneItemExtraIndexHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Item] AskChangeSceneItemExtraIndex called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChangeSceneItemExtraIndex);
        }

                [Handler(MethodId.AskFishDestructibleCreate)]
        public static void AskFishDestructibleCreateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFishDestructibleCreate called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFishDestructibleCreate);
        }

                [Handler(MethodId.AskFishDestructibleRemove)]
        public static void AskFishDestructibleRemoveHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFishDestructibleRemove called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFishDestructibleRemove);
        }

                [Handler(MethodId.AskAgentDestructibleCreate)]
        public static void AskAgentDestructibleCreateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskAgentDestructibleCreate called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAgentDestructibleCreate);
        }

                [Handler(MethodId.AskSkillDestructibleCreate)]
        public static void AskSkillDestructibleCreateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskSkillDestructibleCreate called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSkillDestructibleCreate);
        }

                [Handler(MethodId.AskPlateDestructibleCreate)]
        public static void AskPlateDestructibleCreateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskPlateDestructibleCreate called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPlateDestructibleCreate);
        }

                [Handler(MethodId.AskCreateSymbiosisDestructible)]
        public static void AskCreateSymbiosisDestructibleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskCreateSymbiosisDestructible called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCreateSymbiosisDestructible);
        }

                [Handler(MethodId.AskChaosNpcBeAttacked)]
        public static void AskChaosNpcBeAttackedHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<ChaosNpcAttackedData>();
                conn.InCombat = true;
                Console.WriteLine($"[Combat] Chaos NPC attacked: npc={args.npcId} attacker={args.attackerId} skill={args.skillId}");

                SendNotify(conn, MethodId.SyncChaosNpcBeAttacked, new ChaosNpcAttackedData()
                {
                    npcId = args.npcId,
                    attackerId = args.attackerId,
                    skillId = args.skillId,
                    damage = args.damage
                });
            }
            catch
            {
                Console.WriteLine("[Combat] Chaos NPC attacked (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskChaosNpcBeAttacked);
        }

                [Handler(MethodId.AskChaosNpcDestoryed)]
        public static void AskChaosNpcDestoryedHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AskChaosNpcDestoryed called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChaosNpcDestoryed);
        }


                private static void SyncPlayerAllTaskToClient(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerAllTask,
            };
            rsp.SetArgs(MethodId.SyncPlayerAllTask, new SyncPlayerAllTask()
            {
                taskInfos = conn.AcceptedTasks.Select(tid => new TaskViewData()
                {
                    TaskId = tid,
                    State = conn.SubmittedTasks.Contains(tid) ? TaskState.Submited : TaskState.Accepted,
                    CounterValues = conn.TaskCounterValues.ContainsKey(tid) ? conn.TaskCounterValues[tid] : new List<int>(),
                }).ToList(),
                currentTask = conn.CurrentTaskId ?? 0,
                loginGameServer = true,
            });
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AakAetherAINpcUpdateMoveDatas)]
        public static void AakAetherAINpcUpdateMoveDatasHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AakAetherAINpcUpdateMoveDatas called");
            SendEmptySuccessReturn(conn, msg, MethodId.AakAetherAINpcUpdateMoveDatas);
        }

                [Handler(MethodId.ActiveGadgetId)]
        public static void ActiveGadgetIdHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] ActiveGadgetId called");
            SendEmptySuccessReturn(conn, msg, MethodId.ActiveGadgetId);
        }

                [Handler(MethodId.ActiveNpcStim)]
        public static void ActiveNpcStimHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] ActiveNpcStim called");
            SendEmptySuccessReturn(conn, msg, MethodId.ActiveNpcStim);
        }

                [Handler(MethodId.ActiveTaskCounter)]
        public static void ActiveTaskCounterHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] ActiveTaskCounter called");
            // Client reports that a task counter was activated/triggered
            // Acknowledge and sync current task state back
            try
            {
                if (msg.Args != null && msg.Args.Length >= 4)
                {
                    uint taskId = BitConverter.ToUInt32(msg.Args, 0);
                    Console.WriteLine($"[Task] ActiveTaskCounter: task={taskId}");
                }
            }
            catch { }
            SyncPlayerAllTaskToClient(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.ActiveTaskCounter);
        }

                [Handler(MethodId.AddMatchTeamRoom)]
        public static void AddMatchTeamRoomHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AddMatchTeamRoom called");
            SendEmptySuccessReturn(conn, msg, MethodId.AddMatchTeamRoom);
        }

                [Handler(MethodId.AddSpiritPhoneInfos)]
        public static void AddSpiritPhoneInfosHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Phone] AddSpiritPhoneInfos called");
            uint spiritId = conn.currentSpirit;
            try
            {
                spiritId = msg.GetArgs<PhoneSpiritIdArgs>().spiritId;
            }
            catch { }

            var phoneInfos = PhoneSystem.GetOrCreatePhoneInfos(conn, spiritId);

            // Send the actual phone data to client with both spiritId and phoneInfos
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AddSpiritPhoneInfos,
            };
            rsp.SetArgs(MethodId.AddSpiritPhoneInfos, new AnantaTestGameServer.AddSpiritPhoneInfosArgs()
            {
                spiritId = spiritId,
                phoneInfos = phoneInfos
            });
            conn.SendPacket(rsp);

            Console.WriteLine($"[Phone] Sent phone infos for spirit {spiritId}: {phoneInfos.ContactList?.Count ?? 0} contacts, {phoneInfos.ContactGroupList?.Count ?? 0} groups");
        }

                [Handler(MethodId.ApplyFriend)]
        public static void ApplyFriendHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] ApplyFriend called");
            SendEmptySuccessReturn(conn, msg, MethodId.ApplyFriend);
        }

                [Handler(MethodId.ApproachAgent)]
        public static void ApproachAgentHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] ApproachAgent called");
            SendEmptySuccessReturn(conn, msg, MethodId.ApproachAgent);
        }

        public class AskAcceptAndSetCurrentTaskArgs : SerializedClass
        {
            public uint taskId;
            public AskAcceptAndSetCurrentTaskArgs() { onlyFields = true; }
        }

        [Handler(MethodId.AskAcceptAndSetCurrentTask)]
        public static void AskAcceptAndSetCurrentTaskHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] AskAcceptAndSetCurrentTask called");
            uint taskId = 1;
            try { taskId = msg.GetArgs<AskAcceptAndSetCurrentTaskArgs>().taskId; } catch { }
            
            Console.WriteLine($"[Task] Accepting and setting current task: {taskId}");
            
            // Add to accepted tasks if not already there
            if (!conn.AcceptedTasks.Contains(taskId))
                conn.AcceptedTasks.Add(taskId);
            
            conn.CurrentTaskId = taskId;
            
            // Initialize counter for this task
            if (!conn.TaskCounterValues.ContainsKey(taskId))
                conn.TaskCounterValues[taskId] = new List<int> { 0 };
            
            // Increment counter to indicate task started
            conn.TaskCounterValues[taskId][0] = 1;
            
            Console.WriteLine($"[Task] Task {taskId} accepted and set as current, counter set to 1");
            
            SyncPlayerAllTaskToClient(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.AskAcceptAndSetCurrentTask);
        }

        public class AskAcceptTaskArgs : SerializedClass
        {
            public uint taskId;
            public AskAcceptTaskArgs() { onlyFields = true; }
        }

        [Handler(MethodId.AskAcceptTask)]
        public static void AskAcceptTaskHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] AskAcceptTask called");
            uint taskId = 1;
            try { taskId = msg.GetArgs<AskAcceptTaskArgs>().taskId; } catch { }
            
            Console.WriteLine($"[Task] Accepting task: {taskId}");
            
            // Add to accepted tasks if not already there
            if (!conn.AcceptedTasks.Contains(taskId))
                conn.AcceptedTasks.Add(taskId);
            
            conn.CurrentTaskId = taskId;
            
            // Initialize counter for this task
            if (!conn.TaskCounterValues.ContainsKey(taskId))
                conn.TaskCounterValues[taskId] = new List<int> { 0 };
            
            // Increment counter to indicate task started
            conn.TaskCounterValues[taskId][0] = 1;
            
            Console.WriteLine($"[Task] Task {taskId} accepted, counter set to 1");
            
            SyncPlayerAllTaskToClient(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.AskAcceptTask);
        }

        [Handler(MethodId.AskActivateNpcProfile)]
        public static void AskActivateNpcProfileHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AskActivateNpcProfile called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskActivateNpcProfile);
        }

                [Handler(MethodId.AskAddClientBuff)]
        public static void AskAddClientBuffHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskAddClientBuffArgs>();
            Console.WriteLine($"[Buff] Add buff unitId={args.unitId} buffId={args.buffId}");

            UxRpcMessage rspReturn = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = msg.RpcMethodId,
            };
            conn.SendPacket(rspReturn);

            UxRpcMessage rspNotify = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitAddBuff,
            };
            rspNotify.SetArgs(MethodId.SyncUnitAddBuff, new AskAddClientBuffArgs()
            {
                unitId = args.unitId,
                buffId = args.buffId,
                buffLayer = args.buffLayer
            });
            conn.SendPacket(rspNotify);
        }

        public class AskAddClientBuffArgs : SerializedClass
        {
            public ulong unitId;
            public uint buffId;
            public int buffLayer;

            public AskAddClientBuffArgs()
            {
                onlyFields = true;
            }
        }

                [Handler(MethodId.AskAddClientGameplayTag)]
        public static void AskAddClientGameplayTagHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskGameplayTagArgs>();
            Console.WriteLine($"[Buff] AskAddClientGameplayTag: entityId={args.agentEntityId}, tagId={args.tagId}");
            
            // Send Return (ack)
            SendEmptySuccessReturn(conn, msg, MethodId.AskAddClientGameplayTag);
            
            // Send Notify (SyncUnitAddBuff) — gameplay tags use same buff sync mechanism
            SendUnitAddBuffNotify(conn, args.agentEntityId, args.tagId, 1);
        }

                [Handler(MethodId.AskAddCurrentWeaponSceneItemHp)]
        public static void AskAddCurrentWeaponSceneItemHpHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Item] AskAddCurrentWeaponSceneItemHp called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAddCurrentWeaponSceneItemHp);
        }

                [Handler(MethodId.AskAetherAIBorrowVehicle)]
        public static void AskAetherAIBorrowVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskAetherAIBorrowVehicle called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAetherAIBorrowVehicle);
        }

                [Handler(MethodId.AskAetherAICreateRaidVehicleAndC)]
        public static void AskAetherAICreateRaidVehicleAndCHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskAetherAICreateRaidVehicleAndC called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAetherAICreateRaidVehicleAndC);
        }

                [Handler(MethodId.AskAetherAICrowdFollowPointPathD)]
        public static void AskAetherAICrowdFollowPointPathDHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskAetherAICrowdFollowPointPathD called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAetherAICrowdFollowPointPathD);
        }

                [Handler(MethodId.AskAetherAIHandleVehicleCollisio)]
        public static void AskAetherAIHandleVehicleCollisioHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskAetherAIHandleVehicleCollisio called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAetherAIHandleVehicleCollisio);
        }

                [Handler(MethodId.AskAetherAIRaidVehicleRegressAet)]
        public static void AskAetherAIRaidVehicleRegressAetHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskAetherAIRaidVehicleRegressAet called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAetherAIRaidVehicleRegressAet);
        }

                [Handler(MethodId.AskAetherAISetVehicleStatus)]
        public static void AskAetherAISetVehicleStatusHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskAetherAISetVehicleStatus called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAetherAISetVehicleStatus);
        }

                [Handler(MethodId.AskAetherNpcUpdatePathForObstacl)]
        public static void AskAetherNpcUpdatePathForObstaclHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AskAetherNpcUpdatePathForObstacl called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAetherNpcUpdatePathForObstacl);
        }

                [Handler(MethodId.AskAetherStaticNpcReturnToSpawnP)]
        public static void AskAetherStaticNpcReturnToSpawnPHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AskAetherStaticNpcReturnToSpawnP called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAetherStaticNpcReturnToSpawnP);
        }

                [Handler(MethodId.AskAgentBackSuccess)]
        public static void AskAgentBackSuccessHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskAgentBackSuccess called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAgentBackSuccess);
        }

                [Handler(MethodId.AskAgentChangeIndoor)]
        public static void AskAgentChangeIndoorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[House] AskAgentChangeIndoor called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAgentChangeIndoor);
        }

                [Handler(MethodId.AskAgentFinishNpcDialog)]
        public static void AskAgentFinishNpcDialogHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<DialogParameter>();
                Console.WriteLine($"[Npc] Finish dialog: npc={args.NpcTemplateId} inst={args.NpcInstanceId}");
                SendNotify(conn, MethodId.SyncBreakDialog, new DialogParameter()
                {
                    NpcTemplateId = args.NpcTemplateId,
                    NpcInstanceId = args.NpcInstanceId
                });
            }
            catch
            {
                Console.WriteLine("[Npc] Finish dialog (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskAgentFinishNpcDialog);
        }

                [Handler(MethodId.AskAgentPatrolFinish)]
        public static void AskAgentPatrolFinishHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskAgentPatrolFinish called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAgentPatrolFinish);
        }

                [Handler(MethodId.AskAgentRegressVehicle)]
        public static void AskAgentRegressVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskAgentRegressVehicle called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAgentRegressVehicle);
        }

                [Handler(MethodId.AskAgentSceneRoomTrigger)]
        public static void AskAgentSceneRoomTriggerHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Room] AskAgentSceneRoomTrigger called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAgentSceneRoomTrigger);
        }

                [Handler(MethodId.AskAgentStartBack)]
        public static void AskAgentStartBackHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskAgentStartBack called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAgentStartBack);
        }

                [Handler(MethodId.AskAgentStartNpcDialog)]
        public static void AskAgentStartNpcDialogHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<DialogParameter>();
                Console.WriteLine($"[Npc] Start dialog: npc={args.NpcTemplateId} inst={args.NpcInstanceId} reason={args.Reason}");

                // Show dialog on client
                SendNotify(conn, MethodId.SyncShowDialog, new DialogParameter()
                {
                    Reason = args.Reason,
                    NpcTemplateId = args.NpcTemplateId,
                    NpcInstanceId = args.NpcInstanceId,
                    AgentPosition = args.AgentPosition,
                    FromTaskId = args.FromTaskId,
                    FromEventId = args.FromEventId,
                    FromClient = args.FromClient,
                    SpoonNodeId = args.SpoonNodeId
                });
            }
            catch
            {
                Console.WriteLine("[Npc] Start dialog (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskAgentStartNpcDialog);
        }

                [Handler(MethodId.AskAgentStartNpcSound)]
        public static void AskAgentStartNpcSoundHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AskAgentStartNpcSound called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAgentStartNpcSound);
        }

                [Handler(MethodId.AskAgentStopVehicle)]
        public static void AskAgentStopVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskAgentStopVehicle called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAgentStopVehicle);
        }

                [Handler(MethodId.AskAgentUpdateBackTransform)]
        public static void AskAgentUpdateBackTransformHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Profile] AskAgentUpdateBackTransform called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAgentUpdateBackTransform);
        }

                [Handler(MethodId.AskAgentVehicleEscape)]
        public static void AskAgentVehicleEscapeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskAgentVehicleEscape called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAgentVehicleEscape);
        }

                [Handler(MethodId.AskApplyFashionColoringSchemeInf)]
        public static void AskApplyFashionColoringSchemeInfHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Fashion] AskApplyFashionColoringSchemeInf called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskApplyFashionColoringSchemeInf);
        }

                [Handler(MethodId.AskBanUser)]
        public static void AskBanUserHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskBanUser called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBanUser);
        }

                [Handler(MethodId.AskBasketballOperatorAction)]
        public static void AskBasketballOperatorActionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskBasketballOperatorAction called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBasketballOperatorAction);
        }

                [Handler(MethodId.AskBirdsGroupAlert)]
        public static void AskBirdsGroupAlertHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskBirdsGroupAlert called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBirdsGroupAlert);
        }

                [Handler(MethodId.AskBlockBasketball)]
        public static void AskBlockBasketballHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskBlockBasketball called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBlockBasketball);
        }

                [Handler(MethodId.AskBreakAction)]
        public static void AskBreakActionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskBreakAction called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBreakAction);
        }

                [Handler(MethodId.AskBreakSkillTimeCurve)]
        public static void AskBreakSkillTimeCurveHandler(Connection conn, UxRpcMessage msg)
        {
            if (conn.ActiveSkills.Count > 0)
                conn.ActiveSkills.Clear();
            Console.WriteLine("[Combat] Skill time curve broken");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBreakSkillTimeCurve);
        }

                [Handler(MethodId.AskBreakStimReaction)]
        public static void AskBreakStimReactionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskBreakStimReaction called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBreakStimReaction);
        }

                [Handler(MethodId.AskBroadcastNpcSignal)]
        public static void AskBroadcastNpcSignalHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AskBroadcastNpcSignal called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBroadcastNpcSignal);
        }

                [Handler(MethodId.AskBuyCinemaTicket)]
        public static void AskBuyCinemaTicketHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskBuyCinemaTicketArgs>();
            Console.WriteLine($"[Activity] AskBuyCinemaTicket: cinema={args.cinemaId}, movie={args.movieId}");
            // Cinema playback is client-side — just acknowledge the ticket purchase
            SendEmptySuccessReturn(conn, msg, MethodId.AskBuyCinemaTicket);
        }

                [Handler(MethodId.AskBuyFerrisWheelTicket)]
        public static void AskBuyFerrisWheelTicketHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskBuyFerrisWheelTicketArgs>();
            Console.WriteLine($"[Activity] AskBuyFerrisWheelTicket: ferrisWheelId={args.ferrisWheelId}, ticketType={args.ticketType}");
            // Ferris wheel ride is client-side — just acknowledge
            SendEmptySuccessReturn(conn, msg, MethodId.AskBuyFerrisWheelTicket);
        }

                [Handler(MethodId.AskBuyVehicleFromMass)]
        public static void AskBuyVehicleFromMassHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskBuyVehicleFromMassArgs>();
            uint vehicleId = args.vehicleId;
            
            conn.UnlockedVehicles ??= new HashSet<uint>(GetTestVehicleConfigIds());
            if (conn.UnlockedVehicles.Add(vehicleId))
            {
                Console.WriteLine($"[Vehicle] Bought vehicle {vehicleId} from mass — now {conn.UnlockedVehicles.Count} unlocked");
                SendAllUnlockedVehicles(conn, 0, UxRpcPacketMode.Notify, MethodId.SyncAllUnlockedVehicles);
            }
            else
            {
                Console.WriteLine($"[Vehicle] Buy vehicle {vehicleId} — already owned");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskBuyVehicleFromMass);
        }

                [Handler(MethodId.AskCaptureAgentFinished)]
        public static void AskCaptureAgentFinishedHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskCaptureAgentFinished called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCaptureAgentFinished);
        }

                [Handler(MethodId.AskChangeAetherVehicleDensity)]
        public static void AskChangeAetherVehicleDensityHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskChangeAetherVehicleDensity called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChangeAetherVehicleDensity);
        }

                [Handler(MethodId.AskChangeCanMoveToDriveSeat)]
        public static void AskChangeCanMoveToDriveSeatHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskChangeCanMoveToDriveSeat called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChangeCanMoveToDriveSeat);
        }

                [Handler(MethodId.AskChangeChatGroupName)]
        public static void AskChangeChatGroupNameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Chat] AskChangeChatGroupName called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChangeChatGroupName);
        }

                [Handler(MethodId.AskChangeCustomVehicleIntervalRa)]
        public static void AskChangeCustomVehicleIntervalRaHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskChangeCustomVehicleIntervalRa called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChangeCustomVehicleIntervalRa);
        }

                [Handler(MethodId.AskChangeFriendRemark)]
        public static void AskChangeFriendRemarkHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskChangeFriendRemark called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChangeFriendRemark);
        }

                [Handler(MethodId.AskChangeGoVehicleDriveState)]
        public static void AskChangeGoVehicleDriveStateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskChangeGoVehicleDriveState called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChangeGoVehicleDriveState);
        }

                [Handler(MethodId.AskChangePedToVehicleNpc)]
        public static void AskChangePedToVehicleNpcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskChangePedToVehicleNpc called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChangePedToVehicleNpc);
        }

                [Handler(MethodId.AskChangeTaskCounterValue)]
        public static void AskChangeTaskCounterValueHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] AskChangeTaskCounterValue called");
            try
            {
                // Args: taskId (uint), counterIndex (int), delta (int)
                if (msg.Args != null && msg.Args.Length >= 12)
                {
                    uint taskId = BitConverter.ToUInt32(msg.Args, 0);
                    int counterIndex = BitConverter.ToInt32(msg.Args, 4);
                    int delta = BitConverter.ToInt32(msg.Args, 8);

                    if (!conn.TaskCounterValues.ContainsKey(taskId))
                        conn.TaskCounterValues[taskId] = new List<int>();

                    var counters = conn.TaskCounterValues[taskId];
                    while (counters.Count <= counterIndex)
                        counters.Add(0);

                    counters[counterIndex] += delta;
                    Console.WriteLine($"[Task] Counter changed: task={taskId} idx={counterIndex} delta={delta} new={counters[counterIndex]}");
                }
            }
            catch { Console.WriteLine("[Task] ChangeTaskCounterValue (parse error)"); }

            SyncPlayerAllTaskToClient(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.AskChangeTaskCounterValue);
        }

                [Handler(MethodId.AskChaosMasterGacha)]
        public static void AskChaosMasterGachaHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Chaos] AskChaosMasterGacha called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChaosMasterGacha);
        }

                [Handler(MethodId.AskChatGroupSetRecvMsg)]
        public static void AskChatGroupSetRecvMsgHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Chat] AskChatGroupSetRecvMsg called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChatGroupSetRecvMsg);
        }

                [Handler(MethodId.AskCheckSpoonCondition)]
        public static void AskCheckSpoonConditionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Spoon] AskCheckSpoonCondition called");
            // Client checks if a Spoon (scene script) condition is met
            // Return success = condition met, allowing the script to proceed
            try
            {
                if (msg.Args != null && msg.Args.Length >= 4)
                {
                    int conditionId = BitConverter.ToInt32(msg.Args, 0);
                    Console.WriteLine($"[Spoon] CheckCondition: id={conditionId} → true");
                }
            }
            catch { }
            SendEmptySuccessReturn(conn, msg, MethodId.AskCheckSpoonCondition);
        }

                [Handler(MethodId.AskCinemaBuyTicket)]
        public static void AskCinemaBuyTicketHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Activity] AskCinemaBuyTicket → ticket purchased (cinema client-side)");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCinemaBuyTicket);
        }

                [Handler(MethodId.AskCinemaEndMovie)]
        public static void AskCinemaEndMovieHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Activity] AskCinemaEndMovie called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCinemaEndMovie);
        }

                [Handler(MethodId.AskCinemaInviteNpc)]
        public static void AskCinemaInviteNpcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AskCinemaInviteNpc called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCinemaInviteNpc);
        }

                [Handler(MethodId.AskCinemaLeave)]
        public static void AskCinemaLeaveHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Activity] AskCinemaLeave called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCinemaLeave);
        }

                [Handler(MethodId.AskCinemaPlayMovie)]
        public static void AskCinemaPlayMovieHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Map] AskCinemaPlayMovie called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCinemaPlayMovie);
        }

                [Handler(MethodId.AskCinemaQueryInfo)]
        public static void AskCinemaQueryInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Activity] AskCinemaQueryInfo → cinema info query (client-side)");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCinemaQueryInfo);
        }

                [Handler(MethodId.AskCinemaRemoveNpc)]
        public static void AskCinemaRemoveNpcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AskCinemaRemoveNpc called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCinemaRemoveNpc);
        }

                [Handler(MethodId.AskCinemaSpawnNpc)]
        public static void AskCinemaSpawnNpcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AskCinemaSpawnNpc called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCinemaSpawnNpc);
        }

                [Handler(MethodId.AskClaimVehicleSeat)]
        public static void AskClaimVehicleSeatHandler(Connection conn, UxRpcMessage msg)
        {
            // Client sends this as Invoke to claim seat(s) in a vehicle
            // Args: vehicleentityid (ulong), seatindices (list of int)
            Console.WriteLine($"[Vehicle][SEAT] ClaimVehicleSeat: vehicleId={conn.LastSpawnedVehicleId}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskClaimVehicleSeat);
        }

        // AskClearAllNpcDialogNpcChat → moved to NpcChatHandlers.cs
        // AskClearNpcUncompletedInviteChat → moved to NpcChatHandlers.cs

                [Handler(MethodId.AskClearVehicleSpawnArea)]
        public static void AskClearVehicleSpawnAreaHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskClearVehicleSpawnArea called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskClearVehicleSpawnArea);
        }

                [Handler(MethodId.AskClientNpcFindPath)]
        public static void AskClientNpcFindPathHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AskClientNpcFindPath called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskClientNpcFindPath);
        }

                [Handler(MethodId.AskClientUseCommonSkill)]
        public static void AskClientUseCommonSkillHandler(Connection conn, UxRpcMessage msg)
        {
            conn.InCombat = true;
            Console.WriteLine("[Combat] Client used common skill");
            SendEmptySuccessReturn(conn, msg, MethodId.AskClientUseCommonSkill);
        }

                [Handler(MethodId.AskCloseConnectionToGame)]
        public static void AskCloseConnectionToGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskCloseConnectionToGame called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCloseConnectionToGame);
        }

                [Handler(MethodId.AskCloseConnectionToGate)]
        public static void AskCloseConnectionToGateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskCloseConnectionToGate called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCloseConnectionToGate);
        }

                [Handler(MethodId.AskControlAgent)]
        public static void AskControlAgentHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskControlAgent called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskControlAgent);
        }

                [Handler(MethodId.AskControlPowerHoldEnemyFallGrou)]
        public static void AskControlPowerHoldEnemyFallGrouHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskControlPowerHoldEnemyFallGrou called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskControlPowerHoldEnemyFallGrou);
        }

                [Handler(MethodId.AskControlPowerHoldEnemyUp)]
        public static void AskControlPowerHoldEnemyUpHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskControlPowerHoldEnemyUp called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskControlPowerHoldEnemyUp);
        }

                [Handler(MethodId.AskCreateAttractPoint)]
        public static void AskCreateAttractPointHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskCreateAttractPoint called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCreateAttractPoint);
        }

                [Handler(MethodId.AskCreateChatGroup)]
        public static void AskCreateChatGroupHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Chat] AskCreateChatGroup called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCreateChatGroup);
        }

                [Handler(MethodId.AskCreateSymbiosisGadget)]
        public static void AskCreateSymbiosisGadgetHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskCreateSymbiosisGadget called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCreateSymbiosisGadget);
        }

                [Handler(MethodId.AskCreateTimelineDangerArea)]
        public static void AskCreateTimelineDangerAreaHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskCreateTimelineDangerArea called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCreateTimelineDangerArea);
        }

                [Handler(MethodId.AskCreationDerivedCreate)]
        public static void AskCreationDerivedCreateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskCreationDerivedCreate called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCreationDerivedCreate);
        }

                [Handler(MethodId.AskCreationMultiEnterOrLeaves)]
        public static void AskCreationMultiEnterOrLeavesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskCreationMultiEnterOrLeaves called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCreationMultiEnterOrLeaves);
        }

                [Handler(MethodId.AskCreationsTriggerDisappear)]
        public static void AskCreationsTriggerDisappearHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskCreationsTriggerDisappear called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCreationsTriggerDisappear);
        }

                [Handler(MethodId.AskCreationTouchMultiPlayer)]
        public static void AskCreationTouchMultiPlayerHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskCreationTouchMultiPlayer called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCreationTouchMultiPlayer);
        }

                [Handler(MethodId.AskDeleteRole)]
        public static void AskDeleteRoleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskDeleteRole called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDeleteRole);
        }

        public class AskDeleteTaskArgs : SerializedClass
        {
            public uint taskId;
            public AskDeleteTaskArgs() { onlyFields = true; }
        }

        [Handler(MethodId.AskDeleteTask)]
        public static void AskDeleteTaskHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] AskDeleteTask called");
            uint taskId = conn.CurrentTaskId ?? 0;
            try { taskId = msg.GetArgs<AskDeleteTaskArgs>().taskId; } catch { }
            conn.CurrentTaskId = null;
            conn.AcceptedTasks.Remove(taskId);
            SyncPlayerAllTaskToClient(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.AskDeleteTask);
        }

                [Handler(MethodId.AskDeleteTaskGroup)]
        public static void AskDeleteTaskGroupHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] AskDeleteTaskGroup called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDeleteTaskGroup);
        }

                [Handler(MethodId.AskDiscardWeaponByInstanceId)]
        public static void AskDiscardWeaponByInstanceIdHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<AskDiscardWeaponArgs>();
                int removed = conn.Weapons.RemoveAll(w => w.InstanceId == args.instanceId);
                if (removed > 0)
                {
                    Console.WriteLine($"[Weapon] Discarded weapon instanceId={args.instanceId} ({removed} removed)");
                    if (conn.WeaponIndex >= conn.Weapons.Count)
                        conn.WeaponIndex = Math.Max(0, conn.Weapons.Count - 1);
                    conn.SyncWeapons();
                }
                else
                {
                    Console.WriteLine($"[Weapon] Discard failed: weapon instanceId={args.instanceId} not found");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Weapon] Discard error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskDiscardWeaponByInstanceId);
        }

                [Handler(MethodId.AskDismissChatGroup)]
        public static void AskDismissChatGroupHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Chat] AskDismissChatGroup called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDismissChatGroup);
        }

                [Handler(MethodId.AskDoAgentFansPerformance)]
        public static void AskDoAgentFansPerformanceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskDoAgentFansPerformance called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDoAgentFansPerformance);
        }

                [Handler(MethodId.AskDoDialogAction)]
        public static void AskDoDialogActionHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<DialogParameter>();
                Console.WriteLine($"[Dialog] AskDoDialogAction: NpcTemplateId={args?.NpcTemplateId}, NpcInstanceId={args?.NpcInstanceId}, FromTaskId={args?.FromTaskId}, SpoonNodeId={args?.SpoonNodeId}");
                SendNotify(conn, MethodId.SyncBreakDialog, new DialogParameter()
                {
                    NpcTemplateId = args?.NpcTemplateId ?? 0,
                    NpcInstanceId = args?.NpcInstanceId ?? 0,
                    FromClient = true
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Dialog] AskDoDialogAction error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskDoDialogAction);
        }

                [Handler(MethodId.AskDoNpcAction)]
        public static void AskDoNpcActionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AskDoNpcAction called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDoNpcAction);
        }

                [Handler(MethodId.AskDoorTransfer)]
        public static void AskDoorTransferHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskDoorTransfer called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDoorTransfer);
        }

                [Handler(MethodId.AskDoPetAction)]
        public static void AskDoPetActionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskDoPetAction called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDoPetAction);
        }

                [Handler(MethodId.AskDoPosAction)]
        public static void AskDoPosActionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskDoPosAction called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDoPosAction);
        }

                [Handler(MethodId.AskDoSpoonServerAction)]
        public static void AskDoSpoonServerActionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Spoon] AskDoSpoonServerAction called");
            // Client requests the server to execute a Spoon (scene script) action
            // This could be spawning objects, changing state, triggering events etc.
            try
            {
                if (msg.Args != null && msg.Args.Length >= 8)
                {
                    int actionType = BitConverter.ToInt32(msg.Args, 0);
                    int actionId = BitConverter.ToInt32(msg.Args, 4);
                    Console.WriteLine($"[Spoon] ServerAction: type={actionType} id={actionId} → executed");

                    // Process common Spoon server actions
                    switch (actionType)
                    {
                        case 0: // Spawn/destroy scene object
                            Console.WriteLine($"[Spoon] Spawn/destroy object id={actionId}");
                            break;
                        case 1: // Change scene state
                            Console.WriteLine($"[Spoon] Change state id={actionId}");
                            break;
                        case 2: // Trigger NPC behavior
                            Console.WriteLine($"[Spoon] Trigger NPC behavior id={actionId}");
                            break;
                        default:
                            Console.WriteLine($"[Spoon] Unknown action type={actionType}");
                            break;
                    }
                }
            }
            catch { Console.WriteLine("[Spoon] ServerAction (parse error)"); }
            SendEmptySuccessReturn(conn, msg, MethodId.AskDoSpoonServerAction);
        }

                [Handler(MethodId.AskDrinkMilk)]
        public static void AskDrinkMilkHandler(Connection conn, UxRpcMessage msg)
        {
            // Drink milk consumible — no known args signature [NO SIGNATURE]
            // Would apply healing/buff from ConsumableConfig and remove item
            Console.WriteLine("[Item] AskDrinkMilk → consumible use (no impl)");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDrinkMilk);
        }

                [Handler(MethodId.AskDroneHitchStateChanged)]
        public static void AskDroneHitchStateChangedHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskDroneHitchStateChanged called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDroneHitchStateChanged);
        }

                [Handler(MethodId.AskDropBelonging)]
        public static void AskDropBelongingHandler(Connection conn, UxRpcMessage msg)
        {
            // Agent drops belongings — DropBelongingData type is in external UX.Game DLL
            // Args: ulong agentEntityId, List<DropBelongingData> belongings
            Console.WriteLine("[Game] AskDropBelonging → agent dropping items (no impl)");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDropBelonging);
        }

                [Handler(MethodId.AskDuoKaiHotPatch)]
        public static void AskDuoKaiHotPatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskDuoKaiHotPatch called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDuoKaiHotPatch);
        }

                [Handler(MethodId.AskEndClimb)]
        public static void AskEndClimbHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskEndClimb called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskEndClimb);
        }

                [Handler(MethodId.AskEndPredictHit)]
        public static void AskEndPredictHitHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<HitPredictData>();
                Console.WriteLine($"[Combat] End predict hit: target={args.TargetId} predictId={args.HitPredictId}");

                SendNotify(conn, MethodId.SyncAgentHitPredictEnd, new HitPredictData()
                {
                    TargetId = args.TargetId,
                    HitPredictId = args.HitPredictId,
                    PredictorId = args.PredictorId
                });
            }
            catch
            {
                Console.WriteLine("[Combat] End predict hit (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskEndPredictHit);
        }

                [Handler(MethodId.AskEndPreparePlotEvent)]
        public static void AskEndPreparePlotEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskEndPreparePlotEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskEndPreparePlotEvent);
        }

                [Handler(MethodId.AskEndTaxiNavigate)]
        public static void AskEndTaxiNavigateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskEndTaxiNavigate called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskEndTaxiNavigate);
        }

                [Handler(MethodId.AskEndTaxiTeleport)]
        public static void AskEndTaxiTeleportHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskEndTaxiTeleport called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskEndTaxiTeleport);
        }

                [Handler(MethodId.AskEnemyEndFall)]
        public static void AskEnemyEndFallHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<EnemyIdData>();
                Console.WriteLine($"[Combat] Enemy end fall: id={args.enemyId}");
                conn.DeadEnemies.Add(args.enemyId);
                if (conn.EnemyHpMap.ContainsKey(args.enemyId))
                    conn.EnemyHpMap[args.enemyId] = 0f;

                // Notify item drop sequence
                SendNotify(conn, MethodId.SyncEnemyEndItemDrop, new EnemyIdData()
                {
                    enemyId = args.enemyId
                });
            }
            catch
            {
                Console.WriteLine("[Combat] Enemy end fall (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskEnemyEndFall);
        }

                [Handler(MethodId.AskEnemyEndItemDropList)]
        public static void AskEnemyEndItemDropListHandler(Connection conn, UxRpcMessage msg)
        {
            var itemList = "drop items";
            Console.WriteLine($"[Combat] Enemy drop items: {itemList}");
            conn.DeadEnemies.Clear();
            SendEmptySuccessReturn(conn, msg, MethodId.AskEnemyEndItemDropList);
        }

                [Handler(MethodId.AskEnemyExistSceneRoom)]
        public static void AskEnemyExistSceneRoomHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Room] AskEnemyExistSceneRoom called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskEnemyExistSceneRoom);
        }

                [Handler(MethodId.AskEnemyFallGround)]
        public static void AskEnemyFallGroundHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<EnemyIdData>();
                Console.WriteLine($"[Combat] Enemy fall ground: id={args.enemyId}");
            }
            catch
            {
                Console.WriteLine("[Combat] Enemy fall ground (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskEnemyFallGround);
        }

                [Handler(MethodId.AskEnemyInteraction)]
        public static void AskEnemyInteractionHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<AskEnemyInteractionArgs>();
                Console.WriteLine($"[Combat] Enemy interaction: enemyId={args.enemyId} type={args.interactionType}");
            }
            catch
            {
                Console.WriteLine("[Combat] Enemy interaction (raw)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskEnemyInteraction);
        }

                [Handler(MethodId.AskEnemyStartFall)]
        public static void AskEnemyStartFallHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<EnemyIdData>();
                Console.WriteLine($"[Combat] Enemy start fall: id={args.enemyId}");
                SendNotify(conn, MethodId.SyncEnemyPrepareDie, new EnemyDieInfo()
                {
                    HasDieAnimation = true,
                    HasDieEffect = false,
                    Killer = conn.Pid,
                    DeadlySkillId = conn.LastSkillId,
                    DieType = DieType.Normal
                });
            }
            catch
            {
                Console.WriteLine("[Combat] Enemy start fall (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskEnemyStartFall);
        }

                [Handler(MethodId.AskEnemyUseClientSkill)]
        public static void AskEnemyUseClientSkillHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<AskSkillExecuteArgs>();
                conn.InCombat = true;
                if (args.targetId != 0 && !conn.EnemyHpMap.ContainsKey(args.targetId))
                    conn.EnemyHpMap[args.targetId] = 1.0f;
                Console.WriteLine($"[Combat] Enemy skill: targetId={args.targetId}");
            }
            catch
            {
                Console.WriteLine("[Combat] Enemy skill (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskEnemyUseClientSkill);
        }

                [Handler(MethodId.AskEnemyUseClientSkillFail)]
        public static void AskEnemyUseClientSkillFailHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Combat] Enemy skill failed");
            SendEmptySuccessReturn(conn, msg, MethodId.AskEnemyUseClientSkillFail);
        }

                [Handler(MethodId.AskEnterFeiSuoCrouch)]
        public static void AskEnterFeiSuoCrouchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskEnterFeiSuoCrouch called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskEnterFeiSuoCrouch);
        }

                [Handler(MethodId.AskEnterMoveGround)]
        public static void AskEnterMoveGroundHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskEnterMoveGround called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskEnterMoveGround);
        }

                [Handler(MethodId.AskEnterRaidByMapEntrance)]
        public static void AskEnterRaidByMapEntranceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Raid] AskEnterRaidByMapEntrance called");
            // Client wants to enter a raid/dungeon via a map entrance
            uint entranceId = 0;
            try
            {
                if (msg.Args != null && msg.Args.Length >= 4)
                    entranceId = BitConverter.ToUInt32(msg.Args, 0);
            }
            catch { }
            Console.WriteLine($"[Raid] EnterRaidByMapEntrance: entrance={entranceId}");

            // Send scene transition to client
            SendNotify(conn, MethodId.SyncPrepareMapEntrance, new SyncPrepareMapEntrance()
            {
                entrance = entranceId
            });
            SendEmptySuccessReturn(conn, msg, MethodId.AskEnterRaidByMapEntrance);
        }

                [Handler(MethodId.AskEnterSceneRoom)]
        public static void AskEnterSceneRoomHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Room] AskEnterSceneRoom called");
            UrbanCrowdSpawner.OnEnterWorld(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.AskEnterSceneRoom);
        }

                [Handler(MethodId.AskEnterShootModeOnCannon)]
        public static void AskEnterShootModeOnCannonHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskEnterShootModeOnCannon called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskEnterShootModeOnCannon);
        }

                [Handler(MethodId.AskEnterVehicleIndoor)]
        public static void AskEnterVehicleIndoorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Vehicle] Enter indoor vehicle");
            conn.InCombat = false;
            SendEmptySuccessReturn(conn, msg, MethodId.AskEnterVehicleIndoor);
        }

                [Handler(MethodId.ReportCreationVehicleEnterOrLeav)]
        public static void ReportCreationVehicleEnterOrLeaveHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Vehicle] Report creation vehicle enter/leave");
            SendEmptySuccessReturn(conn, msg, MethodId.ReportCreationVehicleEnterOrLeav);
        }

                [Handler(MethodId.AskExchangeGiftCode)]
        public static void AskExchangeGiftCodeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskExchangeGiftCode called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskExchangeGiftCode);
        }

                [Handler(MethodId.AskExistSceneRoom)]
        public static void AskExistSceneRoomHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Room] AskExistSceneRoom called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskExistSceneRoom);
        }

                [Handler(MethodId.AskExitShootModeOnCannon)]
        public static void AskExitShootModeOnCannonHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskExitShootModeOnCannon called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskExitShootModeOnCannon);
        }

                [Handler(MethodId.AskExitVehicleIndoor)]
        public static void AskExitVehicleIndoorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Vehicle] Exit indoor vehicle");
            conn.InCombat = false;
            SendEmptySuccessReturn(conn, msg, MethodId.AskExitVehicleIndoor);
        }

                [Handler(MethodId.ReportDrivingVehicle)]
        public static void ReportDrivingVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Vehicle] Report driving vehicle");
            SendEmptySuccessReturn(conn, msg, MethodId.ReportDrivingVehicle);
        }

                [Handler(MethodId.AskFallOffCliff)]
        public static void AskFallOffCliffHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<MoveActionData>();
                Console.WriteLine($"[Movement] Fall off cliff: unit={args.UnitId} pos=({args.Pos?.X:F1},{args.Pos?.Y:F1},{args.Pos?.Z:F1})");

                // Update player position
                if (args.Pos != null)
                {
                    // Save previous position for speed calculation
                    conn.PreviousPlayerPosition = ClonePosition(conn.LastKnownPlayerPosition);
                    conn.LastPositionUpdateTime = Environment.TickCount64;

                    conn.LastKnownPlayerPosition = args.Pos;
                    conn.HasLastKnownPlayerPosition = true;
                    Game.AOIGridManager.OnPlayerMoved(conn);
                    UrbanCrowdSpawner.OnPlayerMoved(conn, args.Pos.X, args.Pos.Z);
                }

                // Notify client of the forced movement
                SendNotify(conn, MethodId.SyncUnitMoveAction, new MoveActionData()
                {
                    UnitId = args.UnitId,
                    Pos = args.Pos,
                    Rot = args.Rot,
                    MoveId = args.MoveId,
                    MoveTime = args.MoveTime
                });
            }
            catch
            {
                Console.WriteLine("[Movement] Fall off cliff (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskFallOffCliff);
        }

                [Handler(MethodId.AskFavoriteFashions)]
        public static void AskFavoriteFashionsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Fashion] AskFavoriteFashions called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFavoriteFashions);
        }

                [Handler(MethodId.AskFavoriteFashionSuits)]
        public static void AskFavoriteFashionSuitsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Fashion] AskFavoriteFashionSuits called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFavoriteFashionSuits);
        }

                [Handler(MethodId.AskFeedback)]
        public static void AskFeedbackHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFeedback called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFeedback);
        }

                [Handler(MethodId.AskFerrisWheelStart)]
        public static void AskFerrisWheelStartHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Activity] AskFerrisWheelStart called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFerrisWheelStart);
        }

                [Handler(MethodId.AskFightGameChangeRole)]
        public static void AskFightGameChangeRoleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFightGameChangeRole called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFightGameChangeRole);
        }

                [Handler(MethodId.AskFightGameEnterRoleStage)]
        public static void AskFightGameEnterRoleStageHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFightGameEnterRoleStage called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFightGameEnterRoleStage);
        }

                [Handler(MethodId.AskFightGameGetPlayers)]
        public static void AskFightGameGetPlayersHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFightGameGetPlayers called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFightGameGetPlayers);
        }

                [Handler(MethodId.AskFightGameLeave)]
        public static void AskFightGameLeaveHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFightGameLeave called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFightGameLeave);
        }

                [Handler(MethodId.AskFightGameReady)]
        public static void AskFightGameReadyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFightGameReady called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFightGameReady);
        }

                [Handler(MethodId.AskFightGameSyncPlayerAction)]
        public static void AskFightGameSyncPlayerActionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFightGameSyncPlayerAction called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFightGameSyncPlayerAction);
        }

                [Handler(MethodId.AskFightGameSyncPlayerState)]
        public static void AskFightGameSyncPlayerStateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFightGameSyncPlayerState called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFightGameSyncPlayerState);
        }

                [Handler(MethodId.AskFinishBelongingUsage)]
        public static void AskFinishBelongingUsageHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFinishBelongingUsage called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFinishBelongingUsage);
        }

                [Handler(MethodId.AskFinishGeneralTeleport)]
        public static void AskFinishGeneralTeleportHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Teleport] AskFinishGeneralTeleport called");
            // Client completed a teleport transition
            try
            {
                if (msg.Args != null && msg.Args.Length >= 12)
                {
                    float x = BitConverter.ToSingle(msg.Args, 0);
                    float y = BitConverter.ToSingle(msg.Args, 4);
                    float z = BitConverter.ToSingle(msg.Args, 8);
                    conn.LastKnownPlayerPosition = new UXVector3() { X = x, Y = y, Z = z };
                    Console.WriteLine($"[Teleport] FinishGeneralTeleport: pos=({x},{y},{z})");
                }
            }
            catch { }
            SendEmptySuccessReturn(conn, msg, MethodId.AskFinishGeneralTeleport);
        }

                [Handler(MethodId.AskFinishNpcStun)]
        public static void AskFinishNpcStunHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AskFinishNpcStun called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFinishNpcStun);
        }

                [Handler(MethodId.AskFinishWpFansPerformance)]
        public static void AskFinishWpFansPerformanceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFinishWpFansPerformance called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFinishWpFansPerformance);
        }

                [Handler(MethodId.AskFixPosOnPlatform)]
        public static void AskFixPosOnPlatformHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFixPosOnPlatform called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFixPosOnPlatform);
        }

                [Handler(MethodId.AskForceFinishDialog)]
        public static void AskForceFinishDialogHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskForceFinishDialog called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskForceFinishDialog);
        }

        [Handler(MethodId.AskForceSkipTask)]
        public static void AskForceSkipTaskHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] AskForceSkipTask called");
            conn.CurrentTaskId = null;
            SyncPlayerAllTaskToClient(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.AskForceSkipTask);
        }

                [Handler(MethodId.AskFreeEmotionByStateTree)]
        public static void AskFreeEmotionByStateTreeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFreeEmotionByStateTree called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFreeEmotionByStateTree);
        }

                [Handler(MethodId.AskFriendAddToBlacklist)]
        public static void AskFriendAddToBlacklistHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFriendAddToBlacklist called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFriendAddToBlacklist);
        }

                [Handler(MethodId.AskFriendAddToSpecialList)]
        public static void AskFriendAddToSpecialListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFriendAddToSpecialList called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFriendAddToSpecialList);
        }

                [Handler(MethodId.AskFriendRemoveFromBlacklist)]
        public static void AskFriendRemoveFromBlacklistHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFriendRemoveFromBlacklist called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFriendRemoveFromBlacklist);
        }

                [Handler(MethodId.AskFriendRemoveFromSpecialList)]
        public static void AskFriendRemoveFromSpecialListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskFriendRemoveFromSpecialList called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFriendRemoveFromSpecialList);
        }

                [Handler(MethodId.AskGadgetDoorTransfer)]
        public static void AskGadgetDoorTransferHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskGadgetDoorTransfer called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskGadgetDoorTransfer);
        }

                [Handler(MethodId.AskGetArrestTimes)]
        public static void AskGetArrestTimesHandler(Connection conn, UxRpcMessage msg)
        {
            // Police system: player has never been arrested on private server
            Console.WriteLine("[Police] AskGetArrestTimes → 0 (no police system)");
            SendEmptySuccessReturn(conn, msg, MethodId.AskGetArrestTimes);
        }

                [Handler(MethodId.AskGetNpcRandomWearFashions)]
        public static void AskGetNpcRandomWearFashionsHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskGetNpcRandomWearFashionsArgs>();
            Console.WriteLine($"[Fashion] AskGetNpcRandomWearFashions: spiritId={args.spiritId}");
            
            var result = new List<uint>();
            var rng = new Random();
            
            if (ConfigManager.IsLoaded)
            {
                // Group fashions by Part slot (0-6)
                var allFashionIds = ConfigManager.GetAllFashionIds();
                var bySlot = new Dictionary<int, List<uint>>();
                
                foreach (var fashionId in allFashionIds)
                {
                    var entry = ConfigManager.GetFashion(fashionId);
                    if (entry == null) continue;
                    
                    // Prefer unisex (Gender=0) for NPC random outfits
                    // Skip spirit-specific fashions (BelongSpiritId != 0)
                    if (entry.BelongSpiritId != 0) continue;
                    if (entry.Gender != 0 && entry.Gender != 1) continue; // Skip female-only for generic NPCs
                    
                    if (!bySlot.ContainsKey(entry.Part))
                        bySlot[entry.Part] = new List<uint>();
                    bySlot[entry.Part].Add(fashionId);
                }
                
                // Pick 1 random fashion per slot (Parts 0-5, skip Part 6 which has only 1 item)
                for (int part = 0; part <= 5; part++)
                {
                    if (bySlot.TryGetValue(part, out var slotFashions) && slotFashions.Count > 0)
                    {
                        result.Add(slotFashions[rng.Next(slotFashions.Count)]);
                    }
                }
            }
            
            Console.WriteLine($"[Fashion] Generated {result.Count} random fashion items for NPC");
            
            // Return List<uint> via SerializedList<uint>
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetNpcRandomWearFashions,
            };
            rsp.SetArgs(MethodId.AskGetNpcRandomWearFashions, new SerializedList<uint>() { values = result });
            conn.SendPacket(rsp);
        }

                [Handler(MethodId.AskGetOffMobilePlatform)]
        public static void AskGetOffMobilePlatformHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskGetOffMobilePlatform called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskGetOffMobilePlatform);
        }

                [Handler(MethodId.AskGetOffMotor)]
        public static void AskGetOffMotorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskGetOffMotor called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskGetOffMotor);
        }

                [Handler(MethodId.AskGetOnMobilePlatform)]
        public static void AskGetOnMobilePlatformHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskGetOnMobilePlatform called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskGetOnMobilePlatform);
        }

                [Handler(MethodId.AskGetTaskValue)]
        public static void AskGetTaskValueHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Task] AskGetTaskValue called");
            try
            {
                uint taskId = conn.CurrentTaskId ?? 0;
                if (msg.Args != null && msg.Args.Length >= 4)
                    taskId = BitConverter.ToUInt32(msg.Args, 0);

                List<int> counters = new List<int>();
                if (conn.TaskCounterValues.ContainsKey(taskId))
                    counters = conn.TaskCounterValues[taskId];

                Console.WriteLine($"[Task] GetTaskValue: task={taskId} counters=[{string.Join(",", counters)}]");

                byte[] response = new byte[counters.Count * 4];
                for (int i = 0; i < counters.Count; i++)
                    BitConverter.GetBytes(counters[i]).CopyTo(response, i * 4);

                UxRpcMessage rsp = new UxRpcMessage()
                {
                    Mode = UxRpcPacketMode.Return,
                    RpcInvokeId = msg.RpcInvokeId,
                    RpcRetcode = 0,
                    RpcMethodId = (int)MethodId.AskGetTaskValue
                };
                rsp.Args = response;
                conn.SendPacket(rsp);
            }
            catch
            {
                Console.WriteLine("[Task] GetTaskValue (parse error)");
                SendEmptySuccessReturn(conn, msg, MethodId.AskGetTaskValue);
            }
        }

                [Handler(MethodId.AskHaveSeenCinema)]
        public static void AskHaveSeenCinemaHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Activity] AskHaveSeenCinema called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskHaveSeenCinema);
        }

                [Handler(MethodId.AskHideMassArea)]
        public static void AskHideMassAreaHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskHideMassArea called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskHideMassArea);
        }

                [Handler(MethodId.AskHotConfigData)]
        public static void AskHotConfigDataHandler(Connection conn, UxRpcMessage msg)
        {
            // Hot config data: server-side config versioning
            // Return type structure is in external UX.Game DLL (not available)
            Console.WriteLine("[Game] AskHotConfigData → empty (no hot config on private server)");
            SendEmptySuccessReturn(conn, msg, MethodId.AskHotConfigData);
        }

        // AskHouseCancelParking → moved to HousingHandlers.cs
        // AskHouseMoveParkingSpace → moved to HousingHandlers.cs
        // AskHouseParking → moved to HousingHandlers.cs

                [Handler(MethodId.AskIgnoreFailPanel)]
        public static void AskIgnoreFailPanelHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[UI] AskIgnoreFailPanel called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskIgnoreFailPanel);
        }

                [Handler(MethodId.AskInteractCmd)]
        public static void AskInteractCmdHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<InteractCmdData>();
                Console.WriteLine($"[Interact] Cmd: type={args.CmdType} sender={args.sender} receiver={args.receiver}");

                SendNotify(conn, MethodId.SyncInteractCmd, new InteractCmdData()
                {
                    CmdType = args.CmdType,
                    sender = args.sender,
                    receiver = args.receiver,
                    CommandData = args.CommandData,
                    CommandDataLen = args.CommandDataLen
                });
            }
            catch
            {
                Console.WriteLine("[Interact] Cmd (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskInteractCmd);
        }

                [Handler(MethodId.AskInterruptSkillExecute)]
        public static void AskInterruptSkillExecuteHandler(Connection conn, UxRpcMessage msg)
        {
            conn.ActiveSkills.Clear();
            conn.InCombat = false;
            Console.WriteLine("[Combat] Skill interrupted - all active skills cancelled");
            SendEmptySuccessReturn(conn, msg, MethodId.AskInterruptSkillExecute);
        }

                [Handler(MethodId.AskInterruptSkillExecuteStiff)]
        public static void AskInterruptSkillExecuteStiffHandler(Connection conn, UxRpcMessage msg)
        {
            conn.ActiveSkills.Clear();
            conn.InCombat = false;
            Console.WriteLine("[Combat] Skill interrupted by stiff");
            SendEmptySuccessReturn(conn, msg, MethodId.AskInterruptSkillExecuteStiff);
        }

                [Handler(MethodId.AskInviteToJoinChatGroup)]
        public static void AskInviteToJoinChatGroupHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Chat] AskInviteToJoinChatGroup called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskInviteToJoinChatGroup);
        }

                [Handler(MethodId.AskIsArrested)]
        public static void AskIsArrestedHandler(Connection conn, UxRpcMessage msg)
        {
            // Police system: player is never arrested on private server
            Console.WriteLine("[Police] AskIsArrested → false (no police system)");
            SendEmptySuccessReturn(conn, msg, MethodId.AskIsArrested);
        }

                [Handler(MethodId.AskKillVehicle)]
        public static void AskKillVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            conn.InCombat = false;
            Console.WriteLine("[Combat] Vehicle killed, combat ended");
            SendEmptySuccessReturn(conn, msg, MethodId.AskKillVehicle);
        }

                [Handler(MethodId.AskLeaveFeiSuoCrouch)]
        public static void AskLeaveFeiSuoCrouchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskLeaveFeiSuoCrouch called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskLeaveFeiSuoCrouch);
        }

                [Handler(MethodId.AskLeaveMoveGround)]
        public static void AskLeaveMoveGroundHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskLeaveMoveGround called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskLeaveMoveGround);
        }

        [Handler(MethodId.AskLoadedInSameScene)]
        public static void AskLoadedInSameSceneHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskLoadedInSameScene called");
            conn.SyncAttributes();

            UxRpcMessage rspWorld = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncWorldReady,
            };
            rspWorld.SetArgs(MethodId.SyncSceneLoadCompleted, new SyncSceneLoadCompleted()
            {
                sceneId = 1
            });
            conn.SendPacket(rspWorld);

            SendEmptySuccessReturn(conn, msg, MethodId.AskLoadedInSameScene);
        }

        [Handler(MethodId.AskLoadGameResCompleted)]
        public static void AskLoadGameResCompletedHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskLoadGameResCompleted called");

            UxRpcMessage rsp1 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSceneLoadCompleted,
            };
            rsp1.SetArgs(MethodId.SyncSceneLoadCompleted, new SyncSceneLoadCompleted()
            {
                sceneId = 1
            });
            conn.SendPacket(rsp1);

            SendEmptySuccessReturn(conn, msg, MethodId.AskLoadGameResCompleted);
        }

                [Handler(MethodId.AskMassHideAreas)]
        public static void AskMassHideAreasHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskMassHideAreas called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskMassHideAreas);
        }

                [Handler(MethodId.AskMetroGadgetIds)]
        public static void AskMetroGadgetIdsHandler(Connection conn, UxRpcMessage msg)
        {
            ulong instanceId = conn.CurrentMetroId;
            int carriage = conn.CurrentMetroCarriage;
            try
            {
                var args = msg.GetArgs<AskMetroGadgetIdsArg>();
                if (args != null)
                {
                    instanceId = args.MetroInstanceId;
                    carriage = args.CarriageIndex;
                }
            }
            catch { }

            Console.WriteLine($"[Metro] AskMetroGadgetIds: metro={instanceId} carriage={carriage}");

            // Return an empty carriage gadget list (no interactable gadgets inside).
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMetroGadgetIds,
            };
            rsp.SetArgs(MethodId.AskMetroGadgetIds, new MetroCarriageGadgetInfos()
            {
                InnerGadgetIds = new(),
                OuterGadgetIds = new(),
            });
            conn.SendPacket(rsp);
        }

                [Handler(MethodId.AskMetroHit)]
        public static void AskMetroHitHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<MetroHitData>();
                conn.InCombat = true;
                Console.WriteLine($"[Combat] Metro hit: metro={args.MetroId} target={args.TargetId} speed={args.Speed}");

                // Track enemy damage from metro hit
                if (args.TargetId != 0 && conn.EnemyHpMap.ContainsKey(args.TargetId))
                {
                    float dmg = args.Speed * 0.05f;
                    conn.EnemyHpMap[args.TargetId] = Math.Max(0f, conn.EnemyHpMap[args.TargetId] - dmg);
                    SendNotify(conn, MethodId.SyncUnitHp, new SyncUnitHp()
                    {
                        unitId = args.TargetId,
                        hp = conn.EnemyHpMap[args.TargetId]
                    });
                    if (conn.EnemyHpMap[args.TargetId] <= 0f)
                    {
                        conn.DeadEnemies.Add(args.TargetId);
                        Console.WriteLine($"[Combat] Enemy killed by metro: id={args.TargetId}");
                    }
                }
            }
            catch
            {
                Console.WriteLine("[Combat] Metro hit (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskMetroHit);
        }

                [Handler(MethodId.AskMetroHitEnd)]
        public static void AskMetroHitEndHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Combat] Metro hit sequence ended (metro={conn.CurrentMetroId})");
            SendEmptySuccessReturn(conn, msg, MethodId.AskMetroHitEnd);
        }

                [Handler(MethodId.AskMindInteractEnemy)]
        public static void AskMindInteractEnemyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Interact] AskMindInteractEnemy called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskMindInteractEnemy);
        }

        // AskModifySpiritCustomSuitSchemeN → moved to SpiritFashionHandlers.cs
        // AskModifySpiritWearFashionEditIn → moved to SpiritFashionHandlers.cs

                [Handler(MethodId.AskMoveCreations)]
        public static void AskMoveCreationsHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<MoveToPosData>();
                Console.WriteLine($"[Movement] Move creations: pid={args.pid} pathLen={args.path?.Count ?? 0}");
            }
            catch
            {
                Console.WriteLine("[Movement] Move creations (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskMoveCreations);
        }

                [Handler(MethodId.AskMoveMobilePlatform)]
        public static void AskMoveMobilePlatformHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskMoveMobilePlatform called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskMoveMobilePlatform);
        }

                [Handler(MethodId.AskMultiCinemaBuyTicket)]
        public static void AskMultiCinemaBuyTicketHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Activity] AskMultiCinemaBuyTicket → multi-cinema ticket (client-side)");
            SendEmptySuccessReturn(conn, msg, MethodId.AskMultiCinemaBuyTicket);
        }

                [Handler(MethodId.AskMultiCinemaLeave)]
        public static void AskMultiCinemaLeaveHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Activity] AskMultiCinemaLeave called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskMultiCinemaLeave);
        }

                [Handler(MethodId.AskMultiCinemaQueryInfo)]
        public static void AskMultiCinemaQueryInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Activity] AskMultiCinemaQueryInfo → multi-cinema info query (client-side)");
            SendEmptySuccessReturn(conn, msg, MethodId.AskMultiCinemaQueryInfo);
        }

                [Handler(MethodId.AskMultipleSkillHit2)]
        public static void AskMultipleSkillHit2Handler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<AskMultipleSkillHit2Args>();
                conn.InCombat = true;
                int hitCount = args.hitTargets?.Count ?? 0;
                Console.WriteLine($"[Combat] Multi-hit: skill={args.skillId} targets={hitCount}");
                if (args.hitTargets != null)
                {
                    foreach (var target in args.hitTargets)
                    {
                        conn.LastSkillHitTarget = target.targetId;

                        // Notify client of each unit attacked
                        SendNotify(conn, MethodId.SyncUnitAttacked, new SyncUnitAttackedData()
                        {
                            targetId = target.targetId,
                            attackerId = conn.Pid,
                            skillId = args.skillId,
                            damage = target.damageRate
                        });

                        // Apply damage to tracked enemies and sync HP
                        if (target.damageRate > 0 && conn.EnemyHpMap.ContainsKey(target.targetId))
                        {
                            conn.EnemyHpMap[target.targetId] = Math.Max(0f, conn.EnemyHpMap[target.targetId] - target.damageRate);
                            SendNotify(conn, MethodId.SyncUnitHp, new SyncUnitHp()
                            {
                                unitId = target.targetId,
                                hp = conn.EnemyHpMap[target.targetId]
                            });

                            // Track dead enemies
                            if (conn.EnemyHpMap[target.targetId] <= 0f)
                            {
                                conn.DeadEnemies.Add(target.targetId);
                                Console.WriteLine($"[Combat] Enemy killed: id={target.targetId}");
                            }
                        }
                    }
                }
            }
            catch
            {
                Console.WriteLine("[Combat] Multi-hit (raw)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskMultipleSkillHit2);
        }

                [Handler(MethodId.AskNearbyRunningAttractPoint)]
        public static void AskNearbyRunningAttractPointHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskNearbyRunningAttractPoint called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskNearbyRunningAttractPoint);
        }

                [Handler(MethodId.AskNewHotFixPatch)]
        public static void AskNewHotFixPatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskNewHotFixPatch called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskNewHotFixPatch);
        }

                [Handler(MethodId.AskNpcBeKnockedDown)]
        public static void AskNpcBeKnockedDownHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AskNpcBeKnockedDown called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskNpcBeKnockedDown);
        }

                [Handler(MethodId.AskNpcFinishEnterOrExitVehicle)]
        public static void AskNpcFinishEnterOrExitVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                // Parse NPC enter/exit vehicle data: NPC entity ID + vehicle entity ID + enter/exit flag
                ulong npcEntityId = 0;
                ulong vehicleEntityId = 0;
                bool isEntering = true;
                if (msg.Args != null && msg.Args.Length >= 17)
                {
                    npcEntityId = BitConverter.ToUInt64(msg.Args, 0);
                    vehicleEntityId = BitConverter.ToUInt64(msg.Args, 8);
                    isEntering = msg.Args[16] != 0;
                }
                Console.WriteLine($"[Vehicle] NpcFinishEnterOrExit: npc={npcEntityId} vehicle={vehicleEntityId} entering={isEntering}");

                // Notify all clients about the NPC seat state change
                SendNotify(conn, MethodId.AskNpcFinishEnterOrExitVehicle, new NpcVehicleEnterExitData()
                {
                    NpcEntityId = npcEntityId,
                    VehicleEntityId = vehicleEntityId,
                    IsEntering = isEntering
                });
            }
            catch
            {
                Console.WriteLine("[Vehicle] NpcFinishEnterOrExit (parse error)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskNpcFinishEnterOrExitVehicle);
        }

                [Handler(MethodId.AskNpcMovePosition)]
        public static void AskNpcMovePositionHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<MoveToPosData>();
                Console.WriteLine($"[Npc] Move position: pid={args.pid} pathLen={args.path?.Count ?? 0}");
            }
            catch
            {
                Console.WriteLine("[Npc] Move position (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskNpcMovePosition);
        }

                [Handler(MethodId.AskNpcMovePositionRequest)]
        public static void AskNpcMovePositionRequestHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AskNpcMovePositionRequest called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskNpcMovePositionRequest);
        }

                [Handler(MethodId.AskNpcShopCommodityInfo)]
        public static void AskNpcShopCommodityInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Shop] AskNpcShopCommodityInfo called");

            var ids = ConfigManager.GetAllConsumableIds();
            var commodities = new List<NpcShopCommodityInfo>(ids.Count);
            foreach (uint templateId in ids)
            {
                commodities.Add(new NpcShopCommodityInfo()
                {
                    TemplateId = templateId,
                    Count = 9999,
                    RefreshTime = 0,
                    Status = 1,
                    BuyTimes = 0,
                    Discount = 0,
                    DiscountPrice = 0,
                });
            }

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskNpcShopCommodityInfo,
            };
            rsp.SetArgs(MethodId.AskNpcShopCommodityInfo, new NpcShopInfo()
            {
                CurrentDiscount = 0,
                NextDiscount = 0,
                CommodityInfoList = commodities,
            });
            conn.SendPacket(rsp);
        }

                [Handler(MethodId.AskNpcStartEnterOrExitVehicle)]
        public static void AskNpcStartEnterOrExitVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                ulong npcEntityId = 0;
                ulong vehicleEntityId = 0;
                bool isEntering = true;
                if (msg.Args != null && msg.Args.Length >= 17)
                {
                    npcEntityId = BitConverter.ToUInt64(msg.Args, 0);
                    vehicleEntityId = BitConverter.ToUInt64(msg.Args, 8);
                    isEntering = msg.Args[16] != 0;
                }
                Console.WriteLine($"[Vehicle] NpcStartEnterOrExit: npc={npcEntityId} vehicle={vehicleEntityId} entering={isEntering}");

                // Notify all clients that the NPC is starting the enter/exit animation
                SendNotify(conn, MethodId.AskNpcStartEnterOrExitVehicle, new NpcVehicleEnterExitData()
                {
                    NpcEntityId = npcEntityId,
                    VehicleEntityId = vehicleEntityId,
                    IsEntering = isEntering
                });
            }
            catch
            {
                Console.WriteLine("[Vehicle] NpcStartEnterOrExit (parse error)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskNpcStartEnterOrExitVehicle);
        }

                [Handler(MethodId.AskOnMetroEnterStation)]
        public static void AskOnMetroEnterStationHandler(Connection conn, UxRpcMessage msg)
        {
            int stationIdx = -1;
            uint lineId = conn.CurrentMetroLineId;
            ulong metroId = conn.CurrentMetroId;
            try
            {
                var args = msg.GetArgs<AskOnMetroEnterStationArg>();
                if (args != null)
                {
                    stationIdx = args.StationIndex;
                    lineId = args.MetroLineId;
                    metroId = args.MetroInstanceId;
                }
            }
            catch { }
            Game.MetroManager.OnMetroEnterStation(conn, metroId, lineId, stationIdx);
            SendEmptySuccessReturn(conn, msg, MethodId.AskOnMetroEnterStation);
        }

                [Handler(MethodId.AskOnMetroExitStation)]
        public static void AskOnMetroExitStationHandler(Connection conn, UxRpcMessage msg)
        {
            int stationIdx = -1;
            uint lineId = conn.CurrentMetroLineId;
            ulong metroId = conn.CurrentMetroId;
            try
            {
                var args = msg.GetArgs<AskOnMetroExitStationArg>();
                if (args != null)
                {
                    stationIdx = args.StationIndex;
                    lineId = args.MetroLineId;
                    metroId = args.MetroInstanceId;
                }
            }
            catch { }
            Game.MetroManager.OnMetroExitStation(conn, metroId, lineId, stationIdx);
            SendEmptySuccessReturn(conn, msg, MethodId.AskOnMetroExitStation);
        }

                [Handler(MethodId.AskPanelBrowsingTime)]
        public static void AskPanelBrowsingTimeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[UI] AskPanelBrowsingTime called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPanelBrowsingTime);
        }

                [Handler(MethodId.AskPanelOpenOrClose)]
        public static void AskPanelOpenOrCloseHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[UI] AskPanelOpenOrClose called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPanelOpenOrClose);
        }

                [Handler(MethodId.AskPhoneAddContact)]
        public static void AskPhoneAddContactHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<PhoneContactRemarkArgs>();
                PhoneSystem.AddContact(conn, args.spiritId, args.remark, args.phoneNumber);
                Console.WriteLine($"[Phone] AddContact: spirit={args.spiritId} remark={args.remark} number={args.phoneNumber}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Phone] AskPhoneAddContact error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskPhoneAddContact);
        }

                [Handler(MethodId.AskPhoneAddContactGroup)]
        public static void AskPhoneAddContactGroupHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<PhoneGroupArgs>();
                PhoneSystem.AddContactGroup(conn, args.spiritId, args.groupName);
                Console.WriteLine($"[Phone] AddGroup: spirit={args.spiritId} name={args.groupName}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Phone] AskPhoneAddContactGroup error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskPhoneAddContactGroup);
        }

                [Handler(MethodId.AskPhoneAddContactToGroup)]
        public static void AskPhoneAddContactToGroupHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<PhoneContactGroupArgs>();
                PhoneSystem.AddContactToGroup(conn, args.spiritId, args.groupName, args.phoneNumber);
                Console.WriteLine($"[Phone] AddToGroup: spirit={args.spiritId} group={args.groupName} number={args.phoneNumber}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Phone] AskPhoneAddContactToGroup error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskPhoneAddContactToGroup);
        }

                [Handler(MethodId.AskPhoneContactOptionAction)]
        public static void AskPhoneContactOptionActionHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<PhoneContactOptionActionArgs>();
                Console.WriteLine($"[Phone] ContactOptionAction: spirit={args.spiritId} number={args.phoneNumber} option={args.optionId}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Phone] AskPhoneContactOptionAction error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskPhoneContactOptionAction);
        }

                [Handler(MethodId.AskPhoneDeleteContact)]
        public static void AskPhoneDeleteContactHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<PhoneContactArgs>();
                PhoneSystem.RemoveContact(conn, args.spiritId, args.phoneNumber);
                Console.WriteLine($"[Phone] DeleteContact: spirit={args.spiritId} number={args.phoneNumber}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Phone] AskPhoneDeleteContact error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskPhoneDeleteContact);
        }

                [Handler(MethodId.AskPhoneDeleteContactGroup)]
        public static void AskPhoneDeleteContactGroupHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<PhoneGroupArgs>();
                PhoneSystem.RemoveContactGroup(conn, args.spiritId, args.groupName);
                Console.WriteLine($"[Phone] DeleteGroup: spirit={args.spiritId} name={args.groupName}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Phone] AskPhoneDeleteContactGroup error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskPhoneDeleteContactGroup);
        }

                [Handler(MethodId.AskPhoneEditContact)]
        public static void AskPhoneEditContactHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<PhoneEditContactArgs>();
                PhoneSystem.EditContact(conn, args.spiritId, args.oldPhoneNumber, args.newRemark, args.newPhoneNumber);
                Console.WriteLine($"[Phone] EditContact: spirit={args.spiritId} old={args.oldPhoneNumber} newRemark={args.newRemark} newNumber={args.newPhoneNumber}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Phone] AskPhoneEditContact error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskPhoneEditContact);
        }

                [Handler(MethodId.AskPhoneEditContactGroup)]
        public static void AskPhoneEditContactGroupHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<PhoneEditGroupArgs>();
                PhoneSystem.EditContactGroup(conn, args.spiritId, args.oldName, args.newName);
                Console.WriteLine($"[Phone] EditGroup: spirit={args.spiritId} old={args.oldName} new={args.newName}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Phone] AskPhoneEditContactGroup error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskPhoneEditContactGroup);
        }

                [Handler(MethodId.AskPickDelayDrop)]
        public static void AskPickDelayDropHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPickDelayDropArgs>();
            Console.WriteLine($"[Item] AskPickDelayDrop: delayDropId={args.delayDropId}");
            // Delayed drop pickup — drop already queued from enemy death
            // Full implementation would resolve DropConfigEntry and add items
            SendEmptySuccessReturn(conn, msg, MethodId.AskPickDelayDrop);
        }

                [Handler(MethodId.AskPickUpAgentAsWeapon)]
        public static void AskPickUpAgentAsWeaponHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Weapon] AskPickUpAgentAsWeapon called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPickUpAgentAsWeapon);
        }

                [Handler(MethodId.AskPickupBasketball)]
        public static void AskPickupBasketballHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskPickupBasketball called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPickupBasketball);
        }

                [Handler(MethodId.AskPickUpWeapon)]
        public static void AskPickUpWeaponHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<AskDiscardWeaponArgs>();
                Console.WriteLine($"[Weapon] Pick up weapon: instanceId={args.instanceId}");
            }
            catch
            {
                Console.WriteLine("[Weapon] Pick up (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskPickUpWeapon);
        }

                [Handler(MethodId.AskPipeGameEnd)]
        public static void AskPipeGameEndHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskPipeGameEnd called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPipeGameEnd);
        }

                [Handler(MethodId.AskPlateLoadComplete)]
        public static void AskPlateLoadCompleteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskPlateLoadComplete called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPlateLoadComplete);
        }

                [Handler(MethodId.AskPlayerChargeBillInfo)]
        public static void AskPlayerChargeBillInfoHandler(Connection conn, UxRpcMessage msg)
        {
            // Billing/payment info — private server has no billing system
            Console.WriteLine("[Game] AskPlayerChargeBillInfo → no billing (private server)");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPlayerChargeBillInfo);
        }

                [Handler(MethodId.AskPlayerEnterWater)]
        public static void AskPlayerEnterWaterHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskPlayerEnterWater called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPlayerEnterWater);
        }

                [Handler(MethodId.AskPlayerLeaveMetro)]
        public static void AskPlayerLeaveMetroHandler(Connection conn, UxRpcMessage msg)
        {
            bool forceExit = false;
            try
            {
                var args = msg.GetArgs<AskPlayerLeaveMetroArg>();
                if (args != null) forceExit = args.ForceExit;
            }
            catch { }

            ulong prev = conn.CurrentMetroId;
            Console.WriteLine($"[Metro] Player left metro: id={prev} carriage={conn.CurrentMetroCarriage} force={forceExit}");
            Game.MetroManager.OnPlayerLeaveMetro(conn, prev);
            SendEmptySuccessReturn(conn, msg, MethodId.AskPlayerLeaveMetro);
        }

                [Handler(MethodId.AskPlayerLeaveWater)]
        public static void AskPlayerLeaveWaterHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskPlayerLeaveWater called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPlayerLeaveWater);
        }

                [Handler(MethodId.AskPlayerOnBVBFinish)]
        public static void AskPlayerOnBVBFinishHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskPlayerOnBVBFinish called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPlayerOnBVBFinish);
        }

                [Handler(MethodId.AskPlayerOnMetro)]
        public static void AskPlayerOnMetroHandler(Connection conn, UxRpcMessage msg)
        {
            ulong metroId = 0;
            int carriage = 0;
            try
            {
                var args = msg.GetArgs<AskPlayerOnMetroArg>();
                if (args != null)
                {
                    metroId = args.MetroInstanceId;
                    carriage = args.CarriageIndex;
                }
            }
            catch { }

            Game.MetroManager.OnPlayerBoardMetro(conn, metroId, carriage);
            SendEmptySuccessReturn(conn, msg, MethodId.AskPlayerOnMetro);
        }

                [Handler(MethodId.AskPlayerOutOfStuck)]
        public static void AskPlayerOutOfStuckHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskPlayerOutOfStuck called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPlayerOutOfStuck);
        }

                [Handler(MethodId.AskPlayersLoadRate)]
        public static void AskPlayersLoadRateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskPlayersLoadRate called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPlayersLoadRate);
        }

                [Handler(MethodId.AskPlayHurtEffect)]
        public static void AskPlayHurtEffectHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<SkillHitData>();
                Console.WriteLine($"[Combat] HurtEffect: target={args.HitTarget} skill={args.SkillId} effect={args.HurtEffectId} stiff={args.StiffId}");

                // Notify client to play hurt effect on the target unit
                SendNotify(conn, MethodId.SyncUnitHurtEffect, new SyncUnitHurtEffectData()
                {
                    unitId = args.HitTarget,
                    hurtEffectId = args.HurtEffectId,
                    attackerId = args.ReleaserId,
                    hitDirection = args.ClientHitPosNormalDir
                });

                // If target is a tracked enemy, sync HP change
                if (args.HitTarget != 0 && conn.EnemyHpMap.ContainsKey(args.HitTarget))
                {
                    float dmg = args.FirmHurt > 0 ? args.FirmHurt : 0.1f;
                    conn.EnemyHpMap[args.HitTarget] = Math.Max(0f, conn.EnemyHpMap[args.HitTarget] - dmg);
                    SendNotify(conn, MethodId.SyncUnitHp, new SyncUnitHp()
                    {
                        unitId = args.HitTarget,
                        hp = conn.EnemyHpMap[args.HitTarget]
                    });
                }
            }
            catch
            {
                Console.WriteLine("[Combat] HurtEffect (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskPlayHurtEffect);
        }

                [Handler(MethodId.AskPlayWithAnimal)]
        public static void AskPlayWithAnimalHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Animal] AskPlayWithAnimal called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPlayWithAnimal);
        }

                [Handler(MethodId.AskPlotControlEnemy)]
        public static void AskPlotControlEnemyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskPlotControlEnemy called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPlotControlEnemy);
        }

                [Handler(MethodId.AskPlotStopControlEnemy)]
        public static void AskPlotStopControlEnemyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskPlotStopControlEnemy called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPlotStopControlEnemy);
        }

                [Handler(MethodId.AskPoliceDistanceMonitorTrigger)]
        public static void AskPoliceDistanceMonitorTriggerHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Police] AskPoliceDistanceMonitorTrigger called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPoliceDistanceMonitorTrigger);
        }

                [Handler(MethodId.AskPredictHitPerformance)]
        public static void AskPredictHitPerformanceHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<HitPredictData>();
                conn.InCombat = true;
                Console.WriteLine($"[Combat] Predict hit: target={args.TargetId} predictId={args.HitPredictId}");

                SendNotify(conn, MethodId.SyncAgentHitPredict, new HitPredictData()
                {
                    TargetId = args.TargetId,
                    HitPredictId = args.HitPredictId,
                    PredictorId = args.PredictorId
                });
            }
            catch
            {
                Console.WriteLine("[Combat] Predict hit (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskPredictHitPerformance);
        }

                [Handler(MethodId.AskPreparePlotEvent)]
        public static void AskPreparePlotEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskPreparePlotEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPreparePlotEvent);
        }

                [Handler(MethodId.AskPreprocessVehicleSpawnArea)]
        public static void AskPreprocessVehicleSpawnAreaHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskPreprocessVehicleSpawnArea called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPreprocessVehicleSpawnArea);
        }

                [Handler(MethodId.AskPreRaidTeleport)]
        public static void AskPreRaidTeleportHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Teleport] AskPreRaidTeleport called");
            // Client requests pre-teleport preparation (scene loading before raid entry)
            uint raidId = 0;
            try
            {
                if (msg.Args != null && msg.Args.Length >= 4)
                    raidId = BitConverter.ToUInt32(msg.Args, 0);
            }
            catch { }
            Console.WriteLine($"[Teleport] PreRaidTeleport: raidId={raidId}");

            // Acknowledge pre-teleport so client can begin loading
            SendEmptySuccessReturn(conn, msg, MethodId.AskPreRaidTeleport);
        }

                [Handler(MethodId.AskPuppetGetup)]
        public static void AskPuppetGetupHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskPuppetGetup called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPuppetGetup);
        }

                [Handler(MethodId.AskQueryAgentDetailList)]
        public static void AskQueryAgentDetailListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Agent] AskQueryAgentDetailList → {conn.GangMembers.Count} agents");
            // Send each gang member's details to client
            foreach (var kvp in conn.GangMembers)
            {
                SendGangMemberDetails(conn, kvp.Value);
            }
        }

                [Handler(MethodId.AskQuitChatGroup)]
        public static void AskQuitChatGroupHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Chat] AskQuitChatGroup called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskQuitChatGroup);
        }

                [Handler(MethodId.AskRaidVehicleConvertToAether)]
        public static void AskRaidVehicleConvertToAetherHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskRaidVehicleConvertToAether called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskRaidVehicleConvertToAether);
        }

        [Handler(MethodId.AskReAcceptTaskFailGroup)]
        public static void AskReAcceptTaskFailGroupHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] AskReAcceptTaskFailGroup called");
            conn.CurrentTaskId = null;
            SyncPlayerAllTaskToClient(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.AskReAcceptTaskFailGroup);
        }

                [Handler(MethodId.AskReadWeaponRedDots)]
        public static void AskReadWeaponRedDotsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Weapon] AskReadWeaponRedDots called");
            var args = msg.GetArgs<AskReadWeaponRedDotsArgs>();

            var result = new List<WeaponRedDotEntry>();
            foreach (ulong instanceId in args.weaponinstanceids)
            {
                var detail = conn.Weapons.FirstOrDefault(w => w.InstanceId == instanceId);
                bool exists = detail != null && ConfigManager.GetWeapon(detail.TemplateId) != null;
                result.Add(new WeaponRedDotEntry()
                {
                    WeaponInstanceId = instanceId,
                    ShowRedDot = false
                });
            }

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskReadWeaponRedDots,
            };
            rsp.SetArgs(MethodId.AskReadWeaponRedDots, new AskReadWeaponRedDotsReturn() { list = result });
            conn.SendPacket(rsp);
        }

        public class AskReadWeaponRedDotsArgs : SerializedClass
        {
            public List<ulong> weaponinstanceids;
            public AskReadWeaponRedDotsArgs() { onlyFields = true; }
        }

        public class AskReadWeaponRedDotsReturn : SerializedClass
        {
            public List<WeaponRedDotEntry> list;
            public AskReadWeaponRedDotsReturn() { onlyFields = true; }
        }

        public class WeaponRedDotEntry : SerializedClass
        {
            public ulong WeaponInstanceId;
            public bool ShowRedDot;
        }

                [Handler(MethodId.AskRecordDrivingBehavior)]
        public static void AskRecordDrivingBehaviorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskRecordDrivingBehavior called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskRecordDrivingBehavior);
        }

                [Handler(MethodId.AskReleaseAIEvent)]
        public static void AskReleaseAIEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskReleaseAIEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskReleaseAIEvent);
        }

                [Handler(MethodId.AskReleaseClientEvent)]
        public static void AskReleaseClientEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskReleaseClientEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskReleaseClientEvent);
        }

                [Handler(MethodId.AskReleaseEnemySignal)]
        public static void AskReleaseEnemySignalHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskReleaseEnemySignal called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskReleaseEnemySignal);
        }

                [Handler(MethodId.AskReleaseLuaSlotEntityEvent)]
        public static void AskReleaseLuaSlotEntityEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskReleaseLuaSlotEntityEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskReleaseLuaSlotEntityEvent);
        }

                [Handler(MethodId.AskReleaseUnitHookBoneSignal)]
        public static void AskReleaseUnitHookBoneSignalHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskReleaseUnitHookBoneSignal called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskReleaseUnitHookBoneSignal);
        }

                [Handler(MethodId.AskReleaseVehicleSeat)]
        public static void AskReleaseVehicleSeatHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskReleaseVehicleSeat called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskReleaseVehicleSeat);
        }

                [Handler(MethodId.AskRemoveAttractPoint)]
        public static void AskRemoveAttractPointHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskRemoveAttractPoint called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskRemoveAttractPoint);
        }

                [Handler(MethodId.AskRemoveClientGameplayTag)]
        public static void AskRemoveClientGameplayTagHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskGameplayTagArgs>();
            Console.WriteLine($"[Buff] AskRemoveClientGameplayTag: entityId={args.agentEntityId}, tagId={args.tagId}");
            
            // Send Return (ack)
            SendEmptySuccessReturn(conn, msg, MethodId.AskRemoveClientGameplayTag);
            
            // Send Notify (SyncUnitRemoveBuff)
            SendUnitRemoveBuffNotify(conn, args.agentEntityId, args.tagId);
        }

                [Handler(MethodId.AskRemoveMemberFromChatGroup)]
        public static void AskRemoveMemberFromChatGroupHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Chat] AskRemoveMemberFromChatGroup called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskRemoveMemberFromChatGroup);
        }

                [Handler(MethodId.AskRemoveSubAgent)]
        public static void AskRemoveSubAgentHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskRemoveSubAgent called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskRemoveSubAgent);
        }

                [Handler(MethodId.AskRemoveTimelineDangerArea)]
        public static void AskRemoveTimelineDangerAreaHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskRemoveTimelineDangerArea called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskRemoveTimelineDangerArea);
        }

                [Handler(MethodId.AskRepairWeaponDurability)]
        public static void AskRepairWeaponDurabilityHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskRepairWeaponDurabilityArgs>();
            ulong weaponInstanceId = args.weaponInstanceId;
            
            var weapon = conn.Weapons.FirstOrDefault(w => w.InstanceId == weaponInstanceId);
            if (weapon != null)
            {
                int oldDurability = weapon.Durability;
                weapon.Durability = 200; // Max durability
                conn.SyncWeapons();
                Console.WriteLine($"[Weapon] Repaired weapon {weaponInstanceId}: {oldDurability} → 200");
            }
            else
            {
                Console.WriteLine($"[Weapon] Repair failed: weapon {weaponInstanceId} not found");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskRepairWeaponDurability);
        }

                [Handler(MethodId.AskReportClientFpsInfo)]
        public static void AskReportClientFpsInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Report] AskReportClientFpsInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskReportClientFpsInfo);
        }

                [Handler(MethodId.AskReportEnvSdkBlockedLog)]
        public static void AskReportEnvSdkBlockedLogHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Report] AskReportEnvSdkBlockedLog called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskReportEnvSdkBlockedLog);
        }

                [Handler(MethodId.AskReportJoystickChange)]
        public static void AskReportJoystickChangeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Report] AskReportJoystickChange called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskReportJoystickChange);
        }

                [Handler(MethodId.AskReportQualitySetting)]
        public static void AskReportQualitySettingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Report] AskReportQualitySetting called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskReportQualitySetting);
        }

                [Handler(MethodId.AskReportWebpageResource)]
        public static void AskReportWebpageResourceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Report] AskReportWebpageResource called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskReportWebpageResource);
        }

                [Handler(MethodId.AskResetFashionColoringSchemeInf)]
        public static void AskResetFashionColoringSchemeInfHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Fashion] AskResetFashionColoringSchemeInf called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskResetFashionColoringSchemeInf);
        }

                [Handler(MethodId.AskResetGlobalTimeSlow)]
        public static void AskResetGlobalTimeSlowHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskResetGlobalTimeSlow called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskResetGlobalTimeSlow);
        }

                [Handler(MethodId.AskResetVehicleToNearestLane)]
        public static void AskResetVehicleToNearestLaneHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskResetVehicleToNearestLane called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskResetVehicleToNearestLane);
        }

                [Handler(MethodId.AskRideAgent)]
        public static void AskRideAgentHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskRideAgent called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskRideAgent);
        }

                [Handler(MethodId.AskSaveActionGroup)]
        public static void AskSaveActionGroupHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskSaveActionGroup called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSaveActionGroup);
        }

                [Handler(MethodId.AskSceneItemRecordValue)]
        public static void AskSceneItemRecordValueHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Item] AskSceneItemRecordValue called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSceneItemRecordValue);
        }

                [Handler(MethodId.AskSetAetherVehicleTimeScale)]
        public static void AskSetAetherVehicleTimeScaleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskSetAetherVehicleTimeScale called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetAetherVehicleTimeScale);
        }

                [Handler(MethodId.AskSetAnimalInteractionId)]
        public static void AskSetAnimalInteractionIdHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Interact] AskSetAnimalInteractionId called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetAnimalInteractionId);
        }

                [Handler(MethodId.AskSetClientLockTarget)]
        public static void AskSetClientLockTargetHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskSetClientLockTarget called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetClientLockTarget);
        }

                [Handler(MethodId.AskSetDataToOwner)]
        public static void AskSetDataToOwnerHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskSetDataToOwner called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetDataToOwner);
        }

                [Handler(MethodId.AskSetDgoNavSurface)]
        public static void AskSetDgoNavSurfaceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskSetDgoNavSurface called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetDgoNavSurface);
        }

                [Handler(MethodId.AskSetDgoVoxelSurface)]
        public static void AskSetDgoVoxelSurfaceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskSetDgoVoxelSurface called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetDgoVoxelSurface);
        }

                [Handler(MethodId.AskSetEffectData)]
        public static void AskSetEffectDataHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskSetEffectData called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetEffectData);
        }

                [Handler(MethodId.AskSetEmotionByStateTree)]
        public static void AskSetEmotionByStateTreeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskSetEmotionByStateTree called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetEmotionByStateTree);
        }

                [Handler(MethodId.AskSetEmotionsByStateTree)]
        public static void AskSetEmotionsByStateTreeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskSetEmotionsByStateTree called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetEmotionsByStateTree);
        }

                [Handler(MethodId.AskSetFashionColoringSchemeInfos)]
        public static void AskSetFashionColoringSchemeInfosHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Fashion] AskSetFashionColoringSchemeInfos called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetFashionColoringSchemeInfos);
        }

                [Handler(MethodId.AskSetGamePause)]
        public static void AskSetGamePauseHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskSetGamePause called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetGamePause);
        }

                [Handler(MethodId.AskSetGlobalTimeSlow)]
        public static void AskSetGlobalTimeSlowHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskSetGlobalTimeSlow called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetGlobalTimeSlow);
        }

                [Handler(MethodId.AskSetRaidVehicleGpsInfo)]
        public static void AskSetRaidVehicleGpsInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskSetRaidVehicleGpsInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetRaidVehicleGpsInfo);
        }

                [Handler(MethodId.AskSetRejectAllFriendApply)]
        public static void AskSetRejectAllFriendApplyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskSetRejectAllFriendApply called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetRejectAllFriendApply);
        }

        // AskSetSpiritCustomSuitSchemeInfo → moved to SpiritFashionHandlers.cs
        // AskSetSpiritFunctionSuitSchemeIn → moved to SpiritFashionHandlers.cs
        // AskSetSpiritWearFashionHiddenPar → moved to SpiritFashionHandlers.cs

                [Handler(MethodId.AskSetTaskCounterValue)]
        public static void AskSetTaskCounterValueHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] AskSetTaskCounterValue called");
            try
            {
                // Args: taskId (uint), counterIndex (int), value (int)
                if (msg.Args != null && msg.Args.Length >= 12)
                {
                    uint taskId = BitConverter.ToUInt32(msg.Args, 0);
                    int counterIndex = BitConverter.ToInt32(msg.Args, 4);
                    int value = BitConverter.ToInt32(msg.Args, 8);

                    if (!conn.TaskCounterValues.ContainsKey(taskId))
                        conn.TaskCounterValues[taskId] = new List<int>();

                    var counters = conn.TaskCounterValues[taskId];
                    while (counters.Count <= counterIndex)
                        counters.Add(0);

                    counters[counterIndex] = value;
                    Console.WriteLine($"[Task] Counter set: task={taskId} idx={counterIndex} value={value}");
                }
            }
            catch { Console.WriteLine("[Task] SetTaskCounterValue (parse error)"); }

            SyncPlayerAllTaskToClient(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetTaskCounterValue);
        }

        [Handler(MethodId.AskSetTaskValue)]
        public static void AskSetTaskValueHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] AskSetTaskValue called");
            if (conn.CurrentTaskId.HasValue)
            {
                uint taskId = conn.CurrentTaskId.Value;
                if (!conn.TaskCounterValues.ContainsKey(taskId))
                    conn.TaskCounterValues[taskId] = new List<int>();
                conn.TaskCounterValues[taskId].Add(1);
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetTaskValue);
        }

                [Handler(MethodId.AskSimplePatchConfig)]
        public static void AskSimplePatchConfigHandler(Connection conn, UxRpcMessage msg)
        {
            // Config patch data — no hot-patching on private server
            Console.WriteLine("[Game] AskSimplePatchConfig → no patch config (private server)");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSimplePatchConfig);
        }

                [Handler(MethodId.AskSimulationInviteNpc)]
        public static void AskSimulationInviteNpcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AskSimulationInviteNpc called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSimulationInviteNpc);
        }

                [Handler(MethodId.AskSkillAddState)]
        public static void AskSkillAddStateHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<SkillStateData>();
                Console.WriteLine($"[Combat] Skill state: inst={args.SkillInstanceId} releaser={args.ReleaserId} states={args.StateIds?.Count ?? 0}");
            }
            catch
            {
                Console.WriteLine("[Combat] Skill state (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSkillAddState);
        }

                [Handler(MethodId.AskSkillCreationCreate)]
        public static void AskSkillCreationCreateHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<SkillCreationData>();
                conn.InCombat = true;
                Console.WriteLine($"[Combat] Skill creation: id={args.Id} releaser={args.ReleaserId} trigger={args.TriggerIndex}");
            }
            catch
            {
                Console.WriteLine("[Combat] Skill creation (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSkillCreationCreate);
        }

        public class AskSkillExecuteArgs : SerializedClass
        {
            public ulong skillInstanceId;
            public uint skillId;
            public ulong targetId;
            public AskSkillExecuteArgs() { onlyFields = true; }
        }

                [Handler(MethodId.AskSkillExecute)]
        public static void AskSkillExecuteHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<AskSkillExecuteArgs>();

                // Check skill cooldown (unless GM infinite cooldown is enabled)
                if (!conn.GmInfiniteSkillCooldown)
                {
                    if (Game.SkillManager.IsSkillOnCooldown(args.skillId))
                    {
                        long remaining = Game.SkillManager.GetSkillCooldownRemaining(args.skillId);
                        Console.WriteLine($"[Combat] Skill on cooldown: id={args.skillId} remaining={remaining}ms");
                        SendEmptySuccessReturn(conn, msg, MethodId.AskSkillExecute);
                        return;
                    }
                }

                conn.ActiveSkills.Add(args.skillInstanceId);
                conn.LastSkillId = args.skillId;
                conn.LastSkillHitTarget = args.targetId;
                conn.InCombat = true;
                Console.WriteLine($"[Combat] Skill started: id={args.skillId} inst={args.skillInstanceId} target={args.targetId}");

                // Get skill config to determine cooldown
                var skillConfig = Configs.ConfigManager.GetSkill(args.skillId);
                if (skillConfig != null && !conn.GmInfiniteSkillCooldown)
                {
                    // Set default cooldown (5 seconds for now, could be from config)
                    Game.SkillManager.SetSkillCooldown(args.skillId, 5000);
                }

                // Apply skill buffs if configured
                var fightSkill = Configs.ConfigManager.GetFightSkill(args.skillId);
                if (fightSkill != null && fightSkill.ActiveSkill > 0)
                {
                    // Apply self-buff for active skills (simplified)
                    Game.SkillManager.ApplyBuff(conn.Pid, (uint)fightSkill.ActiveSkill, 10000, conn);
                }

                // Notify client of skill execution for animation/VFX
                SendNotify(conn, MethodId.SyncUseSkill, new SyncUseSkillData()
                {
                    skillId = args.skillId,
                    releaserId = conn.Pid,
                    targetId = args.targetId,
                    position = conn.LastKnownPlayerPosition,
                    facing = conn.LastCameraFacing
                });
            }
            catch
            {
                Console.WriteLine("[Combat] Skill execute (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSkillExecute);
        }

                [Handler(MethodId.AskSkillExecuteEnd)]
        public static void AskSkillExecuteEndHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<AskSkillExecuteArgs>();
                conn.ActiveSkills.Remove(args.skillInstanceId);
                Console.WriteLine($"[Combat] Skill ended: inst={args.skillInstanceId}");
            }
            catch
            {
                Console.WriteLine("[Combat] Skill execute end (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSkillExecuteEnd);
        }

                [Handler(MethodId.AskSkillOpenShield)]
        public static void AskSkillOpenShieldHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Combat] Shield opened");
            SendNotify(conn, MethodId.SyncShieldOn, new SyncShieldOn());
            SendEmptySuccessReturn(conn, msg, MethodId.AskSkillOpenShield);
        }

                [Handler(MethodId.AskSkillCloseShield)]
        public static void AskSkillCloseShieldHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Combat] Shield closed");
            SendNotify(conn, MethodId.SyncShieldOff, new SyncShieldOff());
            SendEmptySuccessReturn(conn, msg, MethodId.AskSkillCloseShield);
        }

                [Handler(MethodId.AskSkillPauseFrame)]
        public static void AskSkillPauseFrameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Combat] Skill frame paused");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSkillPauseFrame);
        }

                [Handler(MethodId.AskSkillSummon)]
        public static void AskSkillSummonHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<SkillSummonData>();
                conn.InCombat = true;
                Console.WriteLine($"[Combat] Skill summon: inst={args.SkillInstanceId} releaser={args.ReleaserId} trigger={args.TriggerIndex}");
            }
            catch
            {
                Console.WriteLine("[Combat] Skill summon (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSkillSummon);
        }

                [Handler(MethodId.AskSkillTimeCurve)]
        public static void AskSkillTimeCurveHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Combat] Skill time curve updated");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSkillTimeCurve);
        }

                [Handler(MethodId.AskSkillUseWeaponDurability)]
        public static void AskSkillUseWeaponDurabilityHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Weapon] Skill used weapon durability");
            if (!conn.GmWeaponDurabilityFree)
            {
                var spirit = conn.GetCurrentSpirit();
                if (spirit != null && conn.Weapons.Count > conn.WeaponIndex)
                {
                    var weapon = conn.Weapons[conn.WeaponIndex];
                    if (weapon.Durability > 0)
                        weapon.Durability--;
                }
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSkillUseWeaponDurability);
        }

                [Handler(MethodId.AskSkipDialog)]
        public static void AskSkipDialogHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskSkipDialog called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSkipDialog);
        }

                [Handler(MethodId.AskSkipSpoonPlot)]
        public static void AskSkipSpoonPlotHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Spoon] AskSkipSpoonPlot called");
            // Client wants to skip the current Spoon plot/cutscene
            // Acknowledge the skip and allow the script to jump to the next state
            try
            {
                if (msg.Args != null && msg.Args.Length >= 4)
                {
                    int plotId = BitConverter.ToInt32(msg.Args, 0);
                    Console.WriteLine($"[Spoon] SkipPlot: plotId={plotId}");
                }
            }
            catch { }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSkipSpoonPlot);
        }

                [Handler(MethodId.AskSpawnEnemyInNoNavRaid)]
        public static void AskSpawnEnemyInNoNavRaidHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskSpawnEnemyInNoNavRaid called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSpawnEnemyInNoNavRaid);
        }

                [Handler(MethodId.AskSpawnSubAgent)]
        public static void AskSpawnSubAgentHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskSpawnSubAgent called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSpawnSubAgent);
        }

                [Handler(MethodId.AskSpoonButtonClickEvent)]
        public static void AskSpoonButtonClickEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Spoon] AskSpoonButtonClickEvent called");
            // Client reports a button click during a Spoon interaction
            try
            {
                if (msg.Args != null && msg.Args.Length >= 8)
                {
                    int buttonId = BitConverter.ToInt32(msg.Args, 0);
                    int contextId = BitConverter.ToInt32(msg.Args, 4);
                    Console.WriteLine($"[Spoon] ButtonClick: button={buttonId} context={contextId}");
                }
            }
            catch { }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSpoonButtonClickEvent);
        }

                [Handler(MethodId.AskSpoonClientActionComplete)]
        public static void AskSpoonClientActionCompleteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Spoon] AskSpoonClientActionComplete called");
            // Client completed a Spoon action (e.g., picked up item, opened door, activated mechanism)
            try
            {
                if (msg.Args != null && msg.Args.Length >= 8)
                {
                    int actionId = BitConverter.ToInt32(msg.Args, 0);
                    int result = BitConverter.ToInt32(msg.Args, 4);
                    Console.WriteLine($"[Spoon] ActionComplete: action={actionId} result={result}");
                }
            }
            catch { }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSpoonClientActionComplete);
        }

                [Handler(MethodId.AskSpoonClientAttack)]
        public static void AskSpoonClientAttackHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Spoon] AskSpoonClientAttack called");
            // Client performs an attack during a Spoon scripted sequence
            try
            {
                if (msg.Args != null && msg.Args.Length >= 12)
                {
                    ulong targetId = BitConverter.ToUInt64(msg.Args, 0);
                    int attackType = BitConverter.ToInt32(msg.Args, 8);
                    Console.WriteLine($"[Spoon] ClientAttack: target={targetId} type={attackType}");
                    conn.InCombat = true;
                }
            }
            catch { }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSpoonClientAttack);
        }

                [Handler(MethodId.AskSpoonConditionComplete)]
        public static void AskSpoonConditionCompleteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Spoon] AskSpoonConditionComplete called");
            // Client reports that a Spoon condition has been satisfied
            try
            {
                if (msg.Args != null && msg.Args.Length >= 8)
                {
                    int conditionId = BitConverter.ToInt32(msg.Args, 0);
                    bool completed = msg.Args.Length >= 5 && msg.Args[4] != 0;
                    Console.WriteLine($"[Spoon] ConditionComplete: id={conditionId} completed={completed}");
                }
            }
            catch { }
            SendEmptySuccessReturn(conn, msg, MethodId.AskSpoonConditionComplete);
        }

                [Handler(MethodId.AskStartClimb)]
        public static void AskStartClimbHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskStartClimb called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStartClimb);
        }

                [Handler(MethodId.AskStartDialog)]
        public static void AskStartDialogHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<DialogParameter>();
                Console.WriteLine($"[Dialog] Start: npc={args.NpcTemplateId} reason={args.Reason}");
                SendNotify(conn, MethodId.SyncShowDialog, new DialogParameter()
                {
                    Reason = args.Reason,
                    NpcTemplateId = args.NpcTemplateId,
                    NpcInstanceId = args.NpcInstanceId,
                    AgentPosition = args.AgentPosition,
                    FromTaskId = args.FromTaskId,
                    FromEventId = args.FromEventId,
                    FromClient = true,
                    SpoonNodeId = args.SpoonNodeId
                });
            }
            catch
            {
                Console.WriteLine("[Dialog] Start (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskStartDialog);
        }

                [Handler(MethodId.AskStartJob)]
        public static void AskStartJobHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Job] AskStartJob called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStartJob);
        }

                [Handler(MethodId.AskStealBasketball)]
        public static void AskStealBasketballHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskStealBasketball called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStealBasketball);
        }

                [Handler(MethodId.AskStealNPCFan)]
        public static void AskStealNPCFanHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AskStealNPCFan called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStealNPCFan);
        }

                [Handler(MethodId.AskStealNPCMoney)]
        public static void AskStealNPCMoneyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] AskStealNPCMoney called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStealNPCMoney);
        }

                [Handler(MethodId.AskStopControlAgent)]
        public static void AskStopControlAgentHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskStopControlAgent called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStopControlAgent);
        }

                [Handler(MethodId.AskStopRideAgent)]
        public static void AskStopRideAgentHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskStopRideAgent called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStopRideAgent);
        }

                [Handler(MethodId.AskStopVehicleAhead)]
        public static void AskStopVehicleAheadHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskStopVehicleAhead called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStopVehicleAhead);
        }

        public class AskSubmitTaskArgs : SerializedClass
        {
            public uint taskId;
            public AskSubmitTaskArgs() { onlyFields = true; }
        }

        // Task progression mapping for Natural Born Heroes (Event 1441)
        private static readonly Dictionary<uint, uint> TaskProgressionMap = new()
        {
            { 60004938, 60004939 }, // 隧道，大桥 → 城市摆荡
            { 60004939, 60004941 }, // 城市摆荡 → 追逐火车
            { 60004941, 60004943 }, // 追逐火车 → 火车之旅
            { 60004943, 60004942 }, // 火车之旅 → 音像店
            { 60004942, 60004950 }, // 音像店 → 管道与书店
            { 60004950, 60004946 }, // 管道与书店 → 模玩店
            { 60004946, 60004951 }, // 模玩店 → 电梯井
            { 60004951, 60004952 }, // 电梯井 → 无限展厅
            { 60004952, 60004953 }, // 无限展厅 → 屋顶飙车
            { 60004953, 60004955 }  // 屋顶飙车 → 盘旋向上 (FINAL)
        };

        [Handler(MethodId.AskSubmitTask)]
        public static void AskSubmitTaskHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] AskSubmitTask called");
            uint taskId = conn.CurrentTaskId ?? 0;
            try { taskId = msg.GetArgs<AskSubmitTaskArgs>().taskId; } catch { }
            if (taskId > 0)
            {
                conn.SubmittedTasks.Add(taskId);
                conn.AcceptedTasks.Remove(taskId);
                conn.CurrentTaskId = null;

                // Auto-accept next task in sequence if it exists
                if (TaskProgressionMap.TryGetValue(taskId, out uint nextTaskId))
                {
                    Console.WriteLine($"[Task] Auto-accepting next task: {nextTaskId}");
                    conn.AcceptedTasks.Add(nextTaskId);
                    conn.CurrentTaskId = nextTaskId;
                    conn.TaskCounterValues[nextTaskId] = new List<int> { 0 };
                }
            }
            SyncPlayerAllTaskToClient(conn);
            SendEmptySuccessReturn(conn, msg, MethodId.AskSubmitTask);
        }

                [Handler(MethodId.AskSunBathSettlement)]
        public static void AskSunBathSettlementHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskSunBathSettlement called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSunBathSettlement);
        }

                [Handler(MethodId.AskSwitchDefaultWeapon)]
        public static void AskSwitchDefaultWeaponHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Weapon] AskSwitchDefaultWeapon called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSwitchDefaultWeapon);
        }

                [Handler(MethodId.AskSwitchFightStyle)]
        public static void AskSwitchFightStyleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Spirit] AskSwitchFightStyle called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSwitchFightStyle);
        }

                [Handler(MethodId.AskSwitchPrivateWeapon)]
        public static void AskSwitchPrivateWeaponHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Weapon] AskSwitchPrivateWeapon called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSwitchPrivateWeapon);
        }

                [Handler(MethodId.AskSwitchSceneByTask)]
        public static void AskSwitchSceneByTaskHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] AskSwitchSceneByTask called");
            // Client requests scene switch triggered by task progression
            uint taskId = 0;
            uint sceneId = 0;
            try
            {
                if (msg.Args != null && msg.Args.Length >= 8)
                {
                    taskId = BitConverter.ToUInt32(msg.Args, 0);
                    sceneId = BitConverter.ToUInt32(msg.Args, 4);
                }
            }
            catch { }
            Console.WriteLine($"[Task] SwitchSceneByTask: task={taskId} scene={sceneId}");

            // Send scene transition notification
            SendNotify(conn, MethodId.SyncPrepareMapEntrance, new SyncPrepareMapEntrance()
            {
                entrance = sceneId
            });
            SendEmptySuccessReturn(conn, msg, MethodId.AskSwitchSceneByTask);
        }

                [Handler(MethodId.AskSwitchVehicleRadio)]
        public static void AskSwitchVehicleRadioHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskSwitchVehicleRadio called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSwitchVehicleRadio);
        }

                [Handler(MethodId.AskTaskGadgetsListLoadComplete)]
        public static void AskTaskGadgetsListLoadCompleteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] AskTaskGadgetsListLoadComplete called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskTaskGadgetsListLoadComplete);
        }

                [Handler(MethodId.AskTaskPlateLoadComplete)]
        public static void AskTaskPlateLoadCompleteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] AskTaskPlateLoadComplete called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskTaskPlateLoadComplete);
        }

                [Handler(MethodId.AskTeleportToLeavingWaypoint)]
        public static void AskTeleportToLeavingWaypointHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Teleport] AskTeleportToLeavingWaypoint called");
            // Client teleports to their last leaving waypoint
            UXVector3 waypoint = conn.LastKnownPlayerPosition;
            try
            {
                if (msg.Args != null && msg.Args.Length >= 12)
                {
                    waypoint = new UXVector3()
                    {
                        X = BitConverter.ToSingle(msg.Args, 0),
                        Y = BitConverter.ToSingle(msg.Args, 4),
                        Z = BitConverter.ToSingle(msg.Args, 8)
                    };
                }
            }
            catch { }
            conn.LastKnownPlayerPosition = waypoint;
            Console.WriteLine($"[Teleport] TeleportToLeavingWaypoint: pos=({waypoint.X},{waypoint.Y},{waypoint.Z})");
            SendEmptySuccessReturn(conn, msg, MethodId.AskTeleportToLeavingWaypoint);
        }

                [Handler(MethodId.AskTeleportToParkingWaypoint)]
        public static void AskTeleportToParkingWaypointHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Teleport] AskTeleportToParkingWaypoint called");
            // Client teleports to their house parking waypoint
            UXVector3 waypoint = conn.LastVehicleSpawnPosition ?? new UXVector3() { X = 1015, Y = 0, Z = 1998 };
            try
            {
                if (msg.Args != null && msg.Args.Length >= 12)
                {
                    waypoint = new UXVector3()
                    {
                        X = BitConverter.ToSingle(msg.Args, 0),
                        Y = BitConverter.ToSingle(msg.Args, 4),
                        Z = BitConverter.ToSingle(msg.Args, 8)
                    };
                }
            }
            catch { }
            conn.LastKnownPlayerPosition = waypoint;
            Console.WriteLine($"[Teleport] TeleportToParkingWaypoint: pos=({waypoint.X},{waypoint.Y},{waypoint.Z})");
            SendEmptySuccessReturn(conn, msg, MethodId.AskTeleportToParkingWaypoint);
        }

                [Handler(MethodId.AskTeleportToPoliceStation)]
        public static void AskTeleportToPoliceStationHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Teleport] AskTeleportToPoliceStation called");
            // Client teleports to the nearest police station
            UXVector3 stationPos = new UXVector3() { X = 1000, Y = 0, Z = 2000 };
            try
            {
                if (msg.Args != null && msg.Args.Length >= 12)
                {
                    stationPos = new UXVector3()
                    {
                        X = BitConverter.ToSingle(msg.Args, 0),
                        Y = BitConverter.ToSingle(msg.Args, 4),
                        Z = BitConverter.ToSingle(msg.Args, 8)
                    };
                }
            }
            catch { }
            conn.LastKnownPlayerPosition = stationPos;
            Console.WriteLine($"[Teleport] TeleportToPoliceStation: pos=({stationPos.X},{stationPos.Y},{stationPos.Z})");
            SendEmptySuccessReturn(conn, msg, MethodId.AskTeleportToPoliceStation);
        }

                [Handler(MethodId.AskThrowWeaponInHand)]
        public static void AskThrowWeaponInHandHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Weapon] AskThrowWeaponInHand called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskThrowWeaponInHand);
        }

                [Handler(MethodId.AskToggleDebugIntersection)]
        public static void AskToggleDebugIntersectionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskToggleDebugIntersection called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskToggleDebugIntersection);
        }

                [Handler(MethodId.AskToggleDebugLogicVehicle)]
        public static void AskToggleDebugLogicVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskToggleDebugLogicVehicle called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskToggleDebugLogicVehicle);
        }

                [Handler(MethodId.AskToggleGameSwitchAetherVehicle)]
        public static void AskToggleGameSwitchAetherVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskToggleGameSwitchAetherVehicle called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskToggleGameSwitchAetherVehicle);
        }

                [Handler(MethodId.AskToggleGameSwitchAetherVehicle_0)]
        public static void AskToggleGameSwitchAetherVehicle_0Handler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskToggleGameSwitchAetherVehicle_0 called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskToggleGameSwitchAetherVehicle_0);
        }

                [Handler(MethodId.AskToggleGameSwitchDebugAetherVe)]
        public static void AskToggleGameSwitchDebugAetherVeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskToggleGameSwitchDebugAetherVe called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskToggleGameSwitchDebugAetherVe);
        }

                [Handler(MethodId.AskToggleGameSwitchDebugDangerZo)]
        public static void AskToggleGameSwitchDebugDangerZoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskToggleGameSwitchDebugDangerZo called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskToggleGameSwitchDebugDangerZo);
        }

                [Handler(MethodId.AskToggleGameSwitchDebugHiddenAr)]
        public static void AskToggleGameSwitchDebugHiddenArHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskToggleGameSwitchDebugHiddenAr called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskToggleGameSwitchDebugHiddenAr);
        }

                [Handler(MethodId.AskTrailerHitchStateChanged)]
        public static void AskTrailerHitchStateChangedHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskTrailerHitchStateChanged called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskTrailerHitchStateChanged);
        }

                [Handler(MethodId.AskTriggerPlotEvent)]
        public static void AskTriggerPlotEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Spoon] AskTriggerPlotEvent called");
            // Client triggers a plot/cutscene event
            try
            {
                if (msg.Args != null && msg.Args.Length >= 8)
                {
                    int eventId = BitConverter.ToInt32(msg.Args, 0);
                    int eventType = BitConverter.ToInt32(msg.Args, 4);
                    Console.WriteLine($"[Spoon] TriggerPlotEvent: eventId={eventId} type={eventType}");
                }
            }
            catch { }
            SendEmptySuccessReturn(conn, msg, MethodId.AskTriggerPlotEvent);
        }

                [Handler(MethodId.AskTriggerVehicleSpawnArea)]
        public static void AskTriggerVehicleSpawnAreaHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskTriggerVehicleSpawnArea called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskTriggerVehicleSpawnArea);
        }

                [Handler(MethodId.AskUniSdkShareToken_Gate)]
        public static void AskUniSdkShareToken_GateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskUniSdkShareToken_Gate called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskUniSdkShareToken_Gate);
        }

                [Handler(MethodId.AskUniSdkShareToken_Login)]
        public static void AskUniSdkShareToken_LoginHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskUniSdkShareToken_Login called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskUniSdkShareToken_Login);
        }

                [Handler(MethodId.AskUpdateVehicleAITaskStatus)]
        public static void AskUpdateVehicleAITaskStatusHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] AskUpdateVehicleAITaskStatus called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskUpdateVehicleAITaskStatus);
        }

                [Handler(MethodId.AskUpdateVehiclesArchive)]
        public static void AskUpdateVehiclesArchiveHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskUpdateVehiclesArchive called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskUpdateVehiclesArchive);
        }

                [Handler(MethodId.AskUploadConfig)]
        public static void AskUploadConfigHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskUploadConfig called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskUploadConfig);
        }

                [Handler(MethodId.AskUploadPlayerConfig)]
        public static void AskUploadPlayerConfigHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskUploadPlayerConfig called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskUploadPlayerConfig);
        }

                [Handler(MethodId.AskUseFerrisWheelTicket)]
        public static void AskUseFerrisWheelTicketHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Activity] AskUseFerrisWheelTicket called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskUseFerrisWheelTicket);
        }

                [Handler(MethodId.AskUseLoadingText)]
        public static void AskUseLoadingTextHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskUseLoadingText called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskUseLoadingText);
        }

        public class AskUseSkillArgs : SerializedClass
        {
            public uint skillId;
            public ulong targetId;
            public AskUseSkillArgs() { onlyFields = true; }
        }

                [Handler(MethodId.AskUseSkill)]
        public static void AskUseSkillHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<AskUseSkillArgs>();
                conn.LastSkillId = args.skillId;
                conn.InCombat = true;
                Console.WriteLine($"[Combat] UseSkill: id={args.skillId} target={args.targetId}");

                // Notify client of skill usage for visual effects
                SendNotify(conn, MethodId.SyncUseSkill, new SyncUseSkillData()
                {
                    skillId = args.skillId,
                    releaserId = conn.Pid,
                    targetId = args.targetId,
                    position = conn.LastKnownPlayerPosition,
                    facing = conn.LastCameraFacing
                });
            }
            catch
            {
                Console.WriteLine("[Combat] UseSkill (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskUseSkill);
        }

                [Handler(MethodId.AskVehicleComponentStateUpdate)]
        public static void AskVehicleComponentStateUpdateHandler(Connection conn, UxRpcMessage msg)
        {
            // Echo component state to SyncVehiclePartStatus
            UxRpcMessage notify = new UxRpcMessage() { Mode = UxRpcPacketMode.Notify, RpcInvokeId = 0, RpcRetcode = 0, RpcMethodId = (int)MethodId.SyncVehiclePartStatus };
            notify.Args = msg.Args;
            conn.SendPacket(notify);
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleComponentStateUpdate);
        }

                [Handler(MethodId.AskVehicleContactDamage)]
        public static void AskVehicleContactDamageHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<VehicleContactDamageData>();
                Console.WriteLine($"[Vehicle] Contact damage: mass={args.VehicleMass} layer={args.Layer}");

                SendNotify(conn, MethodId.SyncVehicleContactDamage, new VehicleContactDamageData()
                {
                    VehicleMass = args.VehicleMass,
                    VehicleVelocities = args.VehicleVelocities,
                    VehicleRelativeVelocity = args.VehicleRelativeVelocity,
                    Layer = args.Layer,
                    TouchMass = args.TouchMass,
                    EnemyWeight = args.EnemyWeight,
                    EnemyRank = args.EnemyRank,
                    DisableThreshold = args.DisableThreshold,
                    OtherVehicleEntityId = args.OtherVehicleEntityId
                });
            }
            catch
            {
                Console.WriteLine("[Vehicle] Contact damage (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleContactDamage);
        }

                [Handler(MethodId.AskVehicleCrashEnemy)]
        public static void AskVehicleCrashEnemyHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<VehicleHitData>();
                conn.InCombat = true;
                Console.WriteLine($"[Combat] Vehicle crash enemy: vehicle={args.VehicleId} target={args.TargetId} speed={args.Speed}");

                if (args.TargetId != 0 && conn.EnemyHpMap.ContainsKey(args.TargetId))
                {
                    float dmg = Math.Max(0.5f, args.Speed * 0.02f);
                    conn.EnemyHpMap[args.TargetId] = Math.Max(0f, conn.EnemyHpMap[args.TargetId] - dmg);
                    SendNotify(conn, MethodId.SyncUnitHp, new SyncUnitHp()
                    {
                        unitId = args.TargetId,
                        hp = conn.EnemyHpMap[args.TargetId]
                    });
                    if (conn.EnemyHpMap[args.TargetId] <= 0f)
                    {
                        conn.DeadEnemies.Add(args.TargetId);
                        Console.WriteLine($"[Combat] Enemy killed by vehicle crash: id={args.TargetId}");
                    }
                }
            }
            catch
            {
                Console.WriteLine("[Combat] Vehicle crash enemy (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleCrashEnemy);
        }

                [Handler(MethodId.AskVehicleDeadEnd)]
        public static void AskVehicleDeadEndHandler(Connection conn, UxRpcMessage msg)
        {
            ulong vehicleId = conn.CurrentVehicleId != 0 ? conn.CurrentVehicleId : conn.LastSpawnedVehicleId;
            Console.WriteLine($"[Vehicle] DeadEnd: vehicle={vehicleId}");

            if (vehicleId != 0)
            {
                // Stop the vehicle by sending a zero-velocity sync
                SendNotify(conn, MethodId.SyncVehicleMove, new RaidVehicleSyncData()
                {
                    Id = vehicleId,
                    Position = conn.LastVehicleSpawnPosition ?? new UXVector3() { X = 1015, Y = 0, Z = 1998 },
                    facingDirection = conn.LastVehicleFacing,
                    Velocity = new UXVector3() { X = 0, Y = 0, Z = 0 },
                    Bits = new byte[0]
                });
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleDeadEnd);
        }

                [Handler(MethodId.AskVehicleDisMonitorTrigger)]
        public static void AskVehicleDisMonitorTriggerHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskVehicleDisMonitorTrigger called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleDisMonitorTrigger);
        }

                [Handler(MethodId.AskVehicleEnterArea)]
        public static void AskVehicleEnterAreaHandler(Connection conn, UxRpcMessage msg)
        {
            VehicleLogger.Log("===== AskVehicleEnterArea CALLED =====");
            // Client sends this as Invoke when player enters vehicle detection area
            // Server must respond with success to enable F-key interaction prompt
            try
            {
                // Args: identifyareaid (int), vehicleid (ulong)
                int areaId = msg.Args != null && msg.Args.Length >= 4 ? BitConverter.ToInt32(msg.Args, 0) : 0;
                ulong vehicleId = msg.Args != null && msg.Args.Length >= 12 ? BitConverter.ToUInt64(msg.Args, 4) : 0;
                VehicleLogger.Log($"EnterArea: areaId={areaId} vehicleId={vehicleId} LastDetected={conn.LastDetectedVehicleId}");
                // Store the detected vehicle for potential interaction
                if (vehicleId != 0)
                {
                    conn.LastDetectedVehicleId = vehicleId;
                    VehicleLogger.Log($"Updated LastDetectedVehicleId to {vehicleId}");
                }
            }
            catch { VehicleLogger.Log("EnterArea (parse error)"); }
            // Must return success for interaction to work
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleEnterArea);
        }

                [Handler(MethodId.AskVehicleEnterGetOffArea)]
        public static void AskVehicleEnterGetOffAreaHandler(Connection conn, UxRpcMessage msg)
        {
            VehicleLogger.Log("===== AskVehicleEnterGetOffArea CALLED =====");
            // Client sends this as Notify when player enters the get-off/interaction area near a vehicle door
            try
            {
                int areaId = msg.Args != null && msg.Args.Length >= 4 ? BitConverter.ToInt32(msg.Args, 0) : 0;
                ulong vehicleId = msg.Args != null && msg.Args.Length >= 12 ? BitConverter.ToUInt64(msg.Args, 4) : 0;
                VehicleLogger.Log($"EnterGetOffArea: areaId={areaId} vehicleId={vehicleId} LastDetected={conn.LastDetectedVehicleId}");
                // Store the detected vehicle for potential get-off interaction
                if (vehicleId != 0)
                {
                    conn.LastDetectedVehicleId = vehicleId;
                    VehicleLogger.Log($"Updated LastDetectedVehicleId to {vehicleId}");
                }
            }
            catch { VehicleLogger.Log("EnterGetOffArea (parse error)"); }
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleEnterGetOffArea);
        }

                [Handler(MethodId.AskVehicleEnterWater)]
        public static void AskVehicleEnterWaterHandler(Connection conn, UxRpcMessage msg)
        {
            ulong vehicleId = conn.CurrentVehicleId != 0 ? conn.CurrentVehicleId : conn.LastSpawnedVehicleId;
            Console.WriteLine($"[Vehicle] EnterWater: vehicle={vehicleId}");

            if (vehicleId != 0)
            {
                // When vehicle enters water, stop movement and apply buoyancy effect
                SendNotify(conn, MethodId.SyncVehicleMove, new RaidVehicleSyncData()
                {
                    Id = vehicleId,
                    Position = conn.LastVehicleSpawnPosition ?? new UXVector3() { X = 1015, Y = 0, Z = 1998 },
                    facingDirection = conn.LastVehicleFacing,
                    Velocity = new UXVector3() { X = 0, Y = 0, Z = 0 },
                    Bits = new byte[0]
                });
                conn.InCombat = true; // mark as active interaction
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleEnterWater);
        }

                [Handler(MethodId.AskVehicleHit)]
        public static void AskVehicleHitHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<VehicleHitData>();
                conn.InCombat = true;
                Console.WriteLine($"[Vehicle] Hit: vehicle={args.VehicleId} target={args.TargetId} speed={args.Speed}");

                // Notify client of vehicle hit for damage/effects
                SendNotify(conn, MethodId.SyncVehicleContactDamage, new VehicleHitData()
                {
                    VehicleId = args.VehicleId,
                    DriverId = args.DriverId,
                    TargetId = args.TargetId,
                    Speed = args.Speed,
                    HurtEffectId = args.HurtEffectId,
                    HurtStiffId = args.HurtStiffId,
                    VehicleSpeed = args.VehicleSpeed,
                    AgentSpeed = args.AgentSpeed
                });

                // Track enemy damage from vehicle hit
                if (args.TargetId != 0 && conn.EnemyHpMap.ContainsKey(args.TargetId))
                {
                    float dmg = args.Speed * 0.01f; // damage proportional to speed
                    conn.EnemyHpMap[args.TargetId] = Math.Max(0f, conn.EnemyHpMap[args.TargetId] - dmg);
                    SendNotify(conn, MethodId.SyncUnitHp, new SyncUnitHp()
                    {
                        unitId = args.TargetId,
                        hp = conn.EnemyHpMap[args.TargetId]
                    });
                    if (conn.EnemyHpMap[args.TargetId] <= 0f)
                    {
                        conn.DeadEnemies.Add(args.TargetId);
                        Console.WriteLine($"[Vehicle] Enemy killed by vehicle: id={args.TargetId}");
                    }
                }
            }
            catch
            {
                Console.WriteLine("[Vehicle] Hit (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleHit);
        }

                [Handler(MethodId.AskVehicleHitEnd)]
        public static void AskVehicleHitEndHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] Hit sequence ended");
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleHitEnd);
        }

                [Handler(MethodId.AskVehicleHorn)]
        public static void AskVehicleHornHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<AskVehicleHorn>();
                ulong vehicleId = args.vehicleEntityId != 0 ? args.vehicleEntityId : conn.CurrentVehicleId != 0 ? conn.CurrentVehicleId : conn.LastSpawnedVehicleId;
                Console.WriteLine($"[Vehicle] Horn: vehicle={vehicleId} hornType={args.hornType}");
                SendNotify(conn, MethodId.AskVehicleHorn, new AskVehicleHorn()
                {
                    vehicleEntityId = vehicleId,
                    hornType = args.hornType
                });
            }
            catch
            {
                ulong fallbackId = conn.CurrentVehicleId != 0 ? conn.CurrentVehicleId : conn.LastSpawnedVehicleId;
                Console.WriteLine($"[Vehicle] Horn (no args): vehicle={fallbackId}");
                SendNotify(conn, MethodId.AskVehicleHorn, new AskVehicleHorn()
                {
                    vehicleEntityId = fallbackId,
                    hornType = 0
                });
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleHorn);
        }

                [Handler(MethodId.AskVehicleLeaveArea)]
        public static void AskVehicleLeaveAreaHandler(Connection conn, UxRpcMessage msg)
        {
            // Client sends this as Invoke when player leaves vehicle detection area
            try
            {
                int areaId = msg.Args != null && msg.Args.Length >= 4 ? BitConverter.ToInt32(msg.Args, 0) : 0;
                ulong vehicleId = msg.Args != null && msg.Args.Length >= 12 ? BitConverter.ToUInt64(msg.Args, 4) : 0;
                Console.WriteLine($"[Vehicle][AREA] LeaveArea: areaId={areaId} vehicleId={vehicleId}");
                // Clear the detected vehicle when leaving the area
                if (vehicleId != 0 && conn.LastDetectedVehicleId == vehicleId)
                {
                    conn.LastDetectedVehicleId = 0;
                }
            }
            catch { Console.WriteLine("[Vehicle][AREA] LeaveArea (parse error)"); }
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleLeaveArea);
        }

                [Handler(MethodId.AskVehicleLeaveStuck)]
        public static void AskVehicleLeaveStuckHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskVehicleLeaveStuck called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleLeaveStuck);
        }

                [Handler(MethodId.AskVehicleNavigationPathLength)]
        public static void AskVehicleNavigationPathLengthHandler(Connection conn, UxRpcMessage msg)
        {
            // No server-side AI navigation - return 0 length
            Console.WriteLine("[Vehicle] NavigationPathLength: returning 0 (no server navmesh)");
            UxRpcMessage rsp = new UxRpcMessage() { Mode = UxRpcPacketMode.Return, RpcInvokeId = msg.RpcInvokeId, RpcRetcode = 0, RpcMethodId = (int)MethodId.AskVehicleNavigationPathLength };
            rsp.Args = BitConverter.GetBytes((float)0f);
            conn.SendPacket(rsp);
        }

                [Handler(MethodId.AskVehicleNavigationPathLengthLi)]
        public static void AskVehicleNavigationPathLengthLiHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] NavigationPathLengthLi: returning 0");
            UxRpcMessage rsp = new UxRpcMessage() { Mode = UxRpcPacketMode.Return, RpcInvokeId = msg.RpcInvokeId, RpcRetcode = 0, RpcMethodId = (int)MethodId.AskVehicleNavigationPathLengthLi };
            rsp.Args = BitConverter.GetBytes((float)0f);
            conn.SendPacket(rsp);
        }

                [Handler(MethodId.AskVehicleNavigationPathPoints)]
        public static void AskVehicleNavigationPathPointsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] NavigationPathPoints: returning empty");
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleNavigationPathPoints);
        }

                [Handler(MethodId.AskVehicleNavigationPathPointsFr)]
        public static void AskVehicleNavigationPathPointsFrHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] NavigationPathPointsFr: returning empty");
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleNavigationPathPointsFr);
        }

                [Handler(MethodId.AskVehiclePlayAnimation)]
        public static void AskVehiclePlayAnimationHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] PlayAnimation - echoing to SyncVehiclePlayAnimation");
            // Echo the raw args as a SyncVehiclePlayAnimation notify
            UxRpcMessage notify = new UxRpcMessage() { Mode = UxRpcPacketMode.Notify, RpcInvokeId = 0, RpcRetcode = 0, RpcMethodId = (int)MethodId.SyncVehiclePlayAnimation };
            notify.Args = msg.Args;
            conn.SendPacket(notify);
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehiclePlayAnimation);
        }

                [Handler(MethodId.AskVehicleSendGamePlaySignal)]
        public static void AskVehicleSendGamePlaySignalHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                Console.WriteLine("[Vehicle] AskVehicleSendGamePlaySignal - echoing to clients");
                // Echo the gameplay signal as notify to all nearby clients
                UxRpcMessage notify = new UxRpcMessage() { Mode = UxRpcPacketMode.Notify, RpcInvokeId = 0, RpcRetcode = 0, RpcMethodId = (int)MethodId.AskVehicleSendGamePlaySignal };
                notify.Args = msg.Args;
                conn.SendPacket(notify);
            }
            catch
            {
                Console.WriteLine("[Vehicle] AskVehicleSendGamePlaySignal (parse error)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleSendGamePlaySignal);
        }

                [Handler(MethodId.AskVehicleSendSignal)]
        public static void AskVehicleSendSignalHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                // Args: id (ulong), signalName (string)
                ulong vehicleId = msg.Args != null && msg.Args.Length >= 8 ? BitConverter.ToUInt64(msg.Args, 0) : 0;
                Console.WriteLine($"[Vehicle] AskVehicleSendSignal: vehicleId={vehicleId}");
                // Echo the signal as notify to all nearby clients
                UxRpcMessage notify = new UxRpcMessage() { Mode = UxRpcPacketMode.Notify, RpcInvokeId = 0, RpcRetcode = 0, RpcMethodId = (int)MethodId.AskVehicleSendSignal };
                notify.Args = msg.Args;
                conn.SendPacket(notify);
            }
            catch
            {
                Console.WriteLine("[Vehicle] AskVehicleSendSignal (parse error)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleSendSignal);
        }

                [Handler(MethodId.AskVehicleSendStateSignal)]
        public static void AskVehicleSendStateSignalHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                // Args: id (ulong), signal (VehicleStateSignal enum)
                ulong vehicleId = msg.Args != null && msg.Args.Length >= 8 ? BitConverter.ToUInt64(msg.Args, 0) : 0;
                int signal = msg.Args != null && msg.Args.Length >= 12 ? BitConverter.ToInt32(msg.Args, 8) : 0;
                Console.WriteLine($"[Vehicle] AskVehicleSendStateSignal: vehicleId={vehicleId} signal={signal}");
                // Echo the state signal as notify to all nearby clients
                UxRpcMessage notify = new UxRpcMessage() { Mode = UxRpcPacketMode.Notify, RpcInvokeId = 0, RpcRetcode = 0, RpcMethodId = (int)MethodId.AskVehicleSendStateSignal };
                notify.Args = msg.Args;
                conn.SendPacket(notify);
            }
            catch
            {
                Console.WriteLine("[Vehicle] AskVehicleSendStateSignal (parse error)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleSendStateSignal);
        }

                [Handler(MethodId.AskVehicleShopSpawnVehicle)]
        public static void AskVehicleShopSpawnVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            // Spawn vehicle from shop - use default vehicle config
            Console.WriteLine("[Vehicle] ShopSpawnVehicle - spawning default vehicle");
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleShopSpawnVehicle);
            SpawnVehicle(conn, TestVehicleConfigId, null, conn.LastCameraFacing);
        }

                [Handler(MethodId.AskVehicleSkillDamage)]
        public static void AskVehicleSkillDamageHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<VehicleSkillDamageData>();
                Console.WriteLine($"[Vehicle] Skill damage: mass={args.VehicleMass} effect={args.HurtEffectId}");

                SendNotify(conn, MethodId.SyncVehicleSkillDamage, new VehicleSkillDamageData()
                {
                    VehicleMass = args.VehicleMass,
                    VehicleVelocity = args.VehicleVelocity,
                    HurtEffectId = args.HurtEffectId,
                    ReleaserId = args.ReleaserId,
                    HitPoint = args.HitPoint
                });
            }
            catch
            {
                Console.WriteLine("[Vehicle] Skill damage (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleSkillDamage);
        }

                [Handler(MethodId.AskVehicleStartHackerAutonomousD)]
        public static void AskVehicleStartHackerAutonomousDHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskVehicleStartHackerAutonomousD called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleStartHackerAutonomousD);
        }

                [Handler(MethodId.AskVehicleStartMove)]
        public static void AskVehicleStartMoveHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<RaidVehicleSyncData>();
                Console.WriteLine($"[Vehicle] StartMove: id={args.Id} pos=({args.Position?.X},{args.Position?.Y},{args.Position?.Z})");
                if (conn.CurrentVehicleId != 0 && args.Id == conn.CurrentVehicleId)
                {
                    RememberPlayerPosition(conn, args.Position, $"AskVehicleStartMove vehicle={args.Id}");
                }
            }
            catch { Console.WriteLine("[Vehicle] StartMove (no args)"); }
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleStartMove);
        }

                [Handler(MethodId.AskVehicleStopHackerAutonomousDr)]
        public static void AskVehicleStopHackerAutonomousDrHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskVehicleStopHackerAutonomousDr called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleStopHackerAutonomousDr);
        }

                [Handler(MethodId.AskVehicleStopMove)]
        public static void AskVehicleStopMoveHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<RaidVehicleSyncData>();
                Console.WriteLine($"[Vehicle] StopMove: id={args.Id} pos=({args.Position?.X},{args.Position?.Y},{args.Position?.Z})");
                if (conn.CurrentVehicleId != 0 && args.Id == conn.CurrentVehicleId)
                {
                    RememberPlayerPosition(conn, args.Position, $"AskVehicleStopMove vehicle={args.Id}");
                    conn.LastVehicleSpawnPosition = new UXVector3() { X = args.Position.X, Y = args.Position.Y, Z = args.Position.Z };
                    conn.LastVehicleFacing = args.facingDirection;
                }
            }
            catch { Console.WriteLine("[Vehicle] StopMove (no args)"); }
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleStopMove);
        }

                [Handler(MethodId.AskVehicleStuck)]
        public static void AskVehicleStuckHandler(Connection conn, UxRpcMessage msg)
        {
            ulong vehicleId = conn.CurrentVehicleId != 0 ? conn.CurrentVehicleId : conn.LastSpawnedVehicleId;
            Console.WriteLine($"[Vehicle] Stuck detected: vehicle={vehicleId}, attempting unstuck");
            if (vehicleId != 0)
            {
                // Teleport vehicle to last known good position
                var unstuckPos = conn.LastVehicleSpawnPosition ?? new UXVector3() { X = 1015, Y = 0, Z = 1998 };
                SendNotify(conn, MethodId.SyncVehicleMove, new RaidVehicleSyncData()
                {
                    Id = vehicleId,
                    Position = unstuckPos,
                    facingDirection = conn.LastVehicleFacing,
                    Velocity = new UXVector3() { X = 0, Y = 0, Z = 0 },
                    Bits = new byte[0]
                });
                Console.WriteLine($"[Vehicle] Unstuck: teleported vehicle={vehicleId} to ({unstuckPos.X},{unstuckPos.Y},{unstuckPos.Z})");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleStuck);
        }

                [Handler(MethodId.AskVehicleTriggerAiPathEvent)]
        public static void AskVehicleTriggerAiPathEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] AskVehicleTriggerAiPathEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleTriggerAiPathEvent);
        }

                [Handler(MethodId.AskWebpageOpenOrClose)]
        public static void AskWebpageOpenOrCloseHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Social] AskWebpageOpenOrClose called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskWebpageOpenOrClose);
        }

                [Handler(MethodId.AskWebviewToken)]
        public static void AskWebviewTokenHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskWebviewToken called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskWebviewToken);
        }

                [Handler(MethodId.BroadcastBowlingClientInfo)]
        public static void BroadcastBowlingClientInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] BroadcastBowlingClientInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.BroadcastBowlingClientInfo);
        }

                [Handler(MethodId.ChangeFoodIngredient)]
        public static void ChangeFoodIngredientHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] ChangeFoodIngredient called");
            SendEmptySuccessReturn(conn, msg, MethodId.ChangeFoodIngredient);
        }

                [Handler(MethodId.ChangeParkourState)]
        public static void ChangeParkourStateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] ChangeParkourState called");
            SendEmptySuccessReturn(conn, msg, MethodId.ChangeParkourState);
        }

                [Handler(MethodId.ChangeSceneItemEffect)]
        public static void ChangeSceneItemEffectHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Item] ChangeSceneItemEffect called");
            SendEmptySuccessReturn(conn, msg, MethodId.ChangeSceneItemEffect);
        }

                [Handler(MethodId.ChangeVehicleDoorState)]
        public static void ChangeVehicleDoorStateHandler(Connection conn, UxRpcMessage msg)
        {
            // Client sends this as Invoke to open/close a vehicle door
            // Args: doorindex (byte), vehicleid (ulong), reason (int)
            try
            {
                var args = msg.GetArgs<ChangeVehicleDoorState>();
                ulong vehicleId = args.vehicleEntityId != 0 ? args.vehicleEntityId : conn.LastSpawnedVehicleId;
                Console.WriteLine($"[Vehicle][DOOR] ChangeDoorState: vehicle={vehicleId} door={args.doorIndex} state={args.doorState}");
                // Echo door state change back as notify
                SendNotify(conn, MethodId.ChangeVehicleDoorState, new ChangeVehicleDoorState()
                {
                    vehicleEntityId = vehicleId,
                    doorIndex = args.doorIndex,
                    doorState = args.doorState
                });
            }
            catch
            {
                Console.WriteLine("[Vehicle][DOOR] ChangeDoorState (no args)");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.ChangeVehicleDoorState);
        }

                [Handler(MethodId.CheckAccountOpenId)]
        public static void CheckAccountOpenIdHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] CheckAccountOpenId called");
            SendEmptySuccessReturn(conn, msg, MethodId.CheckAccountOpenId);
        }

                [Handler(MethodId.CheckAccountPassBy)]
        public static void CheckAccountPassByHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] CheckAccountPassBy called");
            SendEmptySuccessReturn(conn, msg, MethodId.CheckAccountPassBy);
        }

                [Handler(MethodId.CheckCanLinkOccupySceneItem)]
        public static void CheckCanLinkOccupySceneItemHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Item] CheckCanLinkOccupySceneItem called");
            SendEmptySuccessReturn(conn, msg, MethodId.CheckCanLinkOccupySceneItem);
        }

                [Handler(MethodId.CheckMahjongInfo)]
        public static void CheckMahjongInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] CheckMahjongInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.CheckMahjongInfo);
        }

                [Handler(MethodId.CheckPlayerPosition)]
        public static void CheckPlayerPositionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] CheckPlayerPosition called");
            SendEmptySuccessReturn(conn, msg, MethodId.CheckPlayerPosition);
        }

                [Handler(MethodId.CloseSocket)]
        public static void CloseSocketHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] CloseSocket called");
            SendEmptySuccessReturn(conn, msg, MethodId.CloseSocket);
        }

                [Handler(MethodId.DebugClientNpcDebugDensityStatis)]
        public static void DebugClientNpcDebugDensityStatisHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] DebugClientNpcDebugDensityStatis called");
            SendEmptySuccessReturn(conn, msg, MethodId.DebugClientNpcDebugDensityStatis);
        }

                [Handler(MethodId.DebugForceSyncAetherVehicleDebug)]
        public static void DebugForceSyncAetherVehicleDebugHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] DebugForceSyncAetherVehicleDebug called");
            SendEmptySuccessReturn(conn, msg, MethodId.DebugForceSyncAetherVehicleDebug);
        }

                [Handler(MethodId.DebugRequestEnterGame)]
        public static void DebugRequestEnterGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] DebugRequestEnterGame called");
            SendEmptySuccessReturn(conn, msg, MethodId.DebugRequestEnterGame);
        }

                [Handler(MethodId.DebugSyncIntersectionDebugData)]
        public static void DebugSyncIntersectionDebugDataHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] DebugSyncIntersectionDebugData called");
            SendEmptySuccessReturn(conn, msg, MethodId.DebugSyncIntersectionDebugData);
        }

                [Handler(MethodId.DebugSyncLogicVehicleDebugData)]
        public static void DebugSyncLogicVehicleDebugDataHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] DebugSyncLogicVehicleDebugData called");
            SendEmptySuccessReturn(conn, msg, MethodId.DebugSyncLogicVehicleDebugData);
        }

                [Handler(MethodId.DebugSyncVehicleDangerZone)]
        public static void DebugSyncVehicleDangerZoneHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] DebugSyncVehicleDangerZone called");
            SendEmptySuccessReturn(conn, msg, MethodId.DebugSyncVehicleDangerZone);
        }

                [Handler(MethodId.DebugSyncVehicleDebugData)]
        public static void DebugSyncVehicleDebugDataHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] DebugSyncVehicleDebugData called");
            SendEmptySuccessReturn(conn, msg, MethodId.DebugSyncVehicleDebugData);
        }

                [Handler(MethodId.DebugSyncVehicleEscapeInfo)]
        public static void DebugSyncVehicleEscapeInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] DebugSyncVehicleEscapeInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.DebugSyncVehicleEscapeInfo);
        }

                [Handler(MethodId.DebugSyncVehicleLaneDebugData)]
        public static void DebugSyncVehicleLaneDebugDataHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] DebugSyncVehicleLaneDebugData called");
            SendEmptySuccessReturn(conn, msg, MethodId.DebugSyncVehicleLaneDebugData);
        }

                [Handler(MethodId.EnterBowlingZone)]
        public static void EnterBowlingZoneHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] EnterBowlingZone called");
            SendEmptySuccessReturn(conn, msg, MethodId.EnterBowlingZone);
        }

                [Handler(MethodId.EnterGomokuZoneDoubleAI)]
        public static void EnterGomokuZoneDoubleAIHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] EnterGomokuZoneDoubleAI called");
            SendEmptySuccessReturn(conn, msg, MethodId.EnterGomokuZoneDoubleAI);
        }

                [Handler(MethodId.EnterGomokuZoneDoublePlayer)]
        public static void EnterGomokuZoneDoublePlayerHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] EnterGomokuZoneDoublePlayer called");
            SendEmptySuccessReturn(conn, msg, MethodId.EnterGomokuZoneDoublePlayer);
        }

                [Handler(MethodId.EnterGomokuZoneEndGame)]
        public static void EnterGomokuZoneEndGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] EnterGomokuZoneEndGame called");
            SendEmptySuccessReturn(conn, msg, MethodId.EnterGomokuZoneEndGame);
        }

                [Handler(MethodId.EventSpoonCountBehavior)]
        public static void EventSpoonCountBehaviorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] EventSpoonCountBehavior called");
            SendEmptySuccessReturn(conn, msg, MethodId.EventSpoonCountBehavior);
        }

                [Handler(MethodId.FastReenter)]
        public static void FastReenterHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] FastReenter called");
            SendEmptySuccessReturn(conn, msg, MethodId.FastReenter);
        }

                [Handler(MethodId.FavorNpcInteract)]
        public static void FavorNpcInteractHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Interact] FavorNpcInteract called");
            SendEmptySuccessReturn(conn, msg, MethodId.FavorNpcInteract);
        }

                [Handler(MethodId.ForceAbortTask)]
        public static void ForceAbortTaskHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] ForceAbortTask called");
            SendEmptySuccessReturn(conn, msg, MethodId.ForceAbortTask);
        }

                [Handler(MethodId.ForceChangeTaskState)]
        public static void ForceChangeTaskStateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] ForceChangeTaskState called");
            SendEmptySuccessReturn(conn, msg, MethodId.ForceChangeTaskState);
        }

                [Handler(MethodId.HoldLetterSignal)]
        public static void HoldLetterSignalHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] HoldLetterSignal called");
            SendEmptySuccessReturn(conn, msg, MethodId.HoldLetterSignal);
        }

                [Handler(MethodId.HotPatchTestGm)]
        public static void HotPatchTestGmHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] HotPatchTestGm called");
            SendEmptySuccessReturn(conn, msg, MethodId.HotPatchTestGm);
        }

                [Handler(MethodId.IamRobot)]
        public static void IamRobotHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] IamRobot called");
            SendEmptySuccessReturn(conn, msg, MethodId.IamRobot);
        }

                [Handler(MethodId.IgnoreRpcRushProtect)]
        public static void IgnoreRpcRushProtectHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] IgnoreRpcRushProtect called");
            SendEmptySuccessReturn(conn, msg, MethodId.IgnoreRpcRushProtect);
        }

                [Handler(MethodId.LeaveAgent)]
        public static void LeaveAgentHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] LeaveAgent called");
            SendEmptySuccessReturn(conn, msg, MethodId.LeaveAgent);
        }

                [Handler(MethodId.LeaveBowling)]
        public static void LeaveBowlingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] LeaveBowling called");
            SendEmptySuccessReturn(conn, msg, MethodId.LeaveBowling);
        }

                [Handler(MethodId.LeaveDart)]
        public static void LeaveDartHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] LeaveDart called");
            SendEmptySuccessReturn(conn, msg, MethodId.LeaveDart);
        }

                [Handler(MethodId.LeaveGomoku)]
        public static void LeaveGomokuHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] LeaveGomoku called");
            SendEmptySuccessReturn(conn, msg, MethodId.LeaveGomoku);
        }

                [Handler(MethodId.LiveHouseMusicInterrupt)]
        public static void LiveHouseMusicInterruptHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[LiveHouse] LiveHouseMusicInterrupt called");
            SendEmptySuccessReturn(conn, msg, MethodId.LiveHouseMusicInterrupt);
        }

                [Handler(MethodId.LiveHouseMusicStart)]
        public static void LiveHouseMusicStartHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[LiveHouse] LiveHouseMusicStart called");
            SendEmptySuccessReturn(conn, msg, MethodId.LiveHouseMusicStart);
        }



                [Handler(MethodId.NEACSetVerifyInfo)]
        public static void NEACSetVerifyInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] NEACSetVerifyInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.NEACSetVerifyInfo);
        }

                [Handler(MethodId.OnBreakChair)]
        public static void OnBreakChairHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] OnBreakChair called");
            SendEmptySuccessReturn(conn, msg, MethodId.OnBreakChair);
        }

                [Handler(MethodId.OnCarriageChanged)]
        public static void OnCarriageChangedHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] OnCarriageChanged called");
            SendEmptySuccessReturn(conn, msg, MethodId.OnCarriageChanged);
        }

                [Handler(MethodId.OnImposterExplode)]
        public static void OnImposterExplodeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] OnImposterExplode called");
            SendEmptySuccessReturn(conn, msg, MethodId.OnImposterExplode);
        }

                [Handler(MethodId.OnInteractWithHugePigeon)]
        public static void OnInteractWithHugePigeonHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Interact] OnInteractWithHugePigeon called");
            SendEmptySuccessReturn(conn, msg, MethodId.OnInteractWithHugePigeon);
        }

                [Handler(MethodId.OnPaperCranesFly)]
        public static void OnPaperCranesFlyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] OnPaperCranesFly called");
            SendEmptySuccessReturn(conn, msg, MethodId.OnPaperCranesFly);
        }

                [Handler(MethodId.OnStealPhone)]
        public static void OnStealPhoneHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Phone] OnStealPhone called (NPC phone stealing minigame)");
            SendEmptySuccessReturn(conn, msg, MethodId.OnStealPhone);
        }

                [Handler(MethodId.AskPhoneAppDownload)]
        public static void AskPhoneAppDownloadHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<PhoneAppDownloadArgs>();
                PhoneSystem.AddAppDownload(conn, args.appId);
                Console.WriteLine($"[Phone] AppDownload: appId={args.appId}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Phone] AskPhoneAppDownload error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskPhoneAppDownload);
        }

                [Handler(MethodId.SyncPhoneAutoAddContact)]
        public static void SyncPhoneAutoAddContactHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<PhoneContactRemarkArgs>();
                PhoneSystem.AddContact(conn, args.spiritId, args.remark, args.phoneNumber);
                Console.WriteLine($"[Phone] AutoAddContact: spirit={args.spiritId} remark={args.remark} number={args.phoneNumber}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Phone] SyncPhoneAutoAddContact error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.SyncPhoneAutoAddContact);
        }

                [Handler(MethodId.SyncPhoneAutoDeleteContact)]
        public static void SyncPhoneAutoDeleteContactHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<PhoneContactArgs>();
                PhoneSystem.RemoveContact(conn, args.spiritId, args.phoneNumber);
                Console.WriteLine($"[Phone] AutoDeleteContact: spirit={args.spiritId} number={args.phoneNumber}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Phone] SyncPhoneAutoDeleteContact error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.SyncPhoneAutoDeleteContact);
        }

                [Handler(MethodId.SyncUnlockPhoneContactOptions)]
        public static void SyncUnlockPhoneContactOptionsHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<PhoneUnlockContactOptionsArgs>();
                Console.WriteLine($"[Phone] UnlockContactOptions: spirit={args.spiritId} number={args.phoneNumber} options={string.Join(",", args.optionIds ?? new List<uint>())}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Phone] SyncUnlockPhoneContactOptions error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.SyncUnlockPhoneContactOptions);
        }

                [Handler(MethodId.GmPhoneGetInfos)]
        public static void GmPhoneGetInfosHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Phone] GmPhoneGetInfos: contacts={conn.PhoneData.SpiritPhoneInfos?.Count ?? 0} spirits, apps={conn.PhoneData.DownLoadAppIds?.Count ?? 0}");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPhoneGetInfos);
        }

                [Handler(MethodId.GmPhoneAddContact)]
        public static void GmPhoneAddContactHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<PhoneContactRemarkArgs>();
                PhoneSystem.AddContact(conn, args.spiritId, args.remark, args.phoneNumber);
                Console.WriteLine($"[Phone] GmAddContact: spirit={args.spiritId} remark={args.remark} number={args.phoneNumber}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Phone] GmPhoneAddContact error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.GmPhoneAddContact);
        }

                [Handler(MethodId.GmPhoneUnlockContact)]
        public static void GmPhoneUnlockContactHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<PhoneContactArgs>();
                Console.WriteLine($"[Phone] GmUnlockContact: spirit={args.spiritId} number={args.phoneNumber}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Phone] GmPhoneUnlockContact error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.GmPhoneUnlockContact);
        }

                [Handler(MethodId.GmPhoneUnlockContactOption)]
        public static void GmPhoneUnlockContactOptionHandler(Connection conn, UxRpcMessage msg)
        {
            try
            {
                var args = msg.GetArgs<PhoneContactOptionActionArgs>();
                Console.WriteLine($"[Phone] GmUnlockContactOption: spirit={args.spiritId} number={args.phoneNumber} option={args.optionId}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Phone] GmPhoneUnlockContactOption error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.GmPhoneUnlockContactOption);
        }

                [Handler(MethodId.GmClearPhoneAppDownloadHistory)]
        public static void GmClearPhoneAppDownloadHistoryHandler(Connection conn, UxRpcMessage msg)
        {
            conn.PhoneData.DownLoadAppIds.Clear();
            Console.WriteLine("[Phone] GmClearPhoneAppDownloadHistory: app history cleared");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearPhoneAppDownloadHistory);
        }

                [Handler(MethodId.OnStoneDance)]
        public static void OnStoneDanceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] OnStoneDance called");
            SendEmptySuccessReturn(conn, msg, MethodId.OnStoneDance);
        }

                [Handler(MethodId.OnTafeiMotorAccelerating)]
        public static void OnTafeiMotorAcceleratingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] OnTafeiMotorAccelerating called");
            SendEmptySuccessReturn(conn, msg, MethodId.OnTafeiMotorAccelerating);
        }

                [Handler(MethodId.OnTafeiMotorColliding)]
        public static void OnTafeiMotorCollidingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] OnTafeiMotorColliding called");
            SendEmptySuccessReturn(conn, msg, MethodId.OnTafeiMotorColliding);
        }

                [Handler(MethodId.OnVehicleColliding)]
        public static void OnVehicleCollidingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] OnVehicleColliding called");
            SendEmptySuccessReturn(conn, msg, MethodId.OnVehicleColliding);
        }

                [Handler(MethodId.PlaceGomokuPiece)]
        public static void PlaceGomokuPieceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] PlaceGomokuPiece called");
            SendEmptySuccessReturn(conn, msg, MethodId.PlaceGomokuPiece);
        }

                [Handler(MethodId.Pong)]
        public static void PongHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] Pong called");
            SendEmptySuccessReturn(conn, msg, MethodId.Pong);
        }

                [Handler(MethodId.QueryMobileBind)]
        public static void QueryMobileBindHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] QueryMobileBind called");
            SendEmptySuccessReturn(conn, msg, MethodId.QueryMobileBind);
        }

                [Handler(MethodId.QuerySwitchSpiritTimelineState)]
        public static void QuerySwitchSpiritTimelineStateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Spirit] QuerySwitchSpiritTimelineState called");
            SendEmptySuccessReturn(conn, msg, MethodId.QuerySwitchSpiritTimelineState);
        }

                [Handler(MethodId.ReceivedNpcStim)]
        public static void ReceivedNpcStimHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Npc] ReceivedNpcStim called");
            SendEmptySuccessReturn(conn, msg, MethodId.ReceivedNpcStim);
        }

                [Handler(MethodId.RecordAgentBehavior)]
        public static void RecordAgentBehaviorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] RecordAgentBehavior called");
            SendEmptySuccessReturn(conn, msg, MethodId.RecordAgentBehavior);
        }

                [Handler(MethodId.RecordAgentBowlingScore)]
        public static void RecordAgentBowlingScoreHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] RecordAgentBowlingScore called");
            SendEmptySuccessReturn(conn, msg, MethodId.RecordAgentBowlingScore);
        }

                [Handler(MethodId.RecordBowlingScore)]
        public static void RecordBowlingScoreHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] RecordBowlingScore called");
            SendEmptySuccessReturn(conn, msg, MethodId.RecordBowlingScore);
        }

                [Handler(MethodId.RecordDartEnd)]
        public static void RecordDartEndHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] RecordDartEnd called");
            SendEmptySuccessReturn(conn, msg, MethodId.RecordDartEnd);
        }

                [Handler(MethodId.RecordDartId)]
        public static void RecordDartIdHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] RecordDartId called");
            SendEmptySuccessReturn(conn, msg, MethodId.RecordDartId);
        }

                [Handler(MethodId.RecordDartScore)]
        public static void RecordDartScoreHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] RecordDartScore called");
            SendEmptySuccessReturn(conn, msg, MethodId.RecordDartScore);
        }

                [Handler(MethodId.RecordSceneItemBehavior)]
        public static void RecordSceneItemBehaviorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Item] RecordSceneItemBehavior called");
            SendEmptySuccessReturn(conn, msg, MethodId.RecordSceneItemBehavior);
        }

                [Handler(MethodId.RefreshCleaningProgress)]
        public static void RefreshCleaningProgressHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] RefreshCleaningProgress called");
            SendEmptySuccessReturn(conn, msg, MethodId.RefreshCleaningProgress);
        }

                [Handler(MethodId.RefreshCleaningWashMaskInfo)]
        public static void RefreshCleaningWashMaskInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] RefreshCleaningWashMaskInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.RefreshCleaningWashMaskInfo);
        }

                [Handler(MethodId.ReleaseLinkOccupySceneItem)]
        public static void ReleaseLinkOccupySceneItemHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Item] ReleaseLinkOccupySceneItem called");
            SendEmptySuccessReturn(conn, msg, MethodId.ReleaseLinkOccupySceneItem);
        }

                [Handler(MethodId.RemoveAllItem)]
        public static void RemoveAllItemHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Item] RemoveAllItem called");
            SendEmptySuccessReturn(conn, msg, MethodId.RemoveAllItem);
        }

                [Handler(MethodId.RemoveAllResults)]
        public static void RemoveAllResultsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] RemoveAllResults called");
            SendEmptySuccessReturn(conn, msg, MethodId.RemoveAllResults);
        }

                [Handler(MethodId.RequestFpPassToken)]
        public static void RequestFpPassTokenHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] RequestFpPassToken called");
            SendEmptySuccessReturn(conn, msg, MethodId.RequestFpPassToken);
        }

                [Handler(MethodId.RequestGameSceneData)]
        public static void RequestGameSceneDataHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] RequestGameSceneData called");
            SendEmptySuccessReturn(conn, msg, MethodId.RequestGameSceneData);
        }

        // RequestNpcChatList → moved to NpcChatHandlers.cs

                [Handler(MethodId.RequestPatchesCheckDataFromAvata)]
        public static void RequestPatchesCheckDataFromAvataHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] RequestPatchesCheckDataFromAvata called");
            SendEmptySuccessReturn(conn, msg, MethodId.RequestPatchesCheckDataFromAvata);
        }

                [Handler(MethodId.RequestPatchesFromAvatar)]
        public static void RequestPatchesFromAvatarHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] RequestPatchesFromAvatar called");
            SendEmptySuccessReturn(conn, msg, MethodId.RequestPatchesFromAvatar);
        }

                [Handler(MethodId.RequestPlayerStartHangup)]
        public static void RequestPlayerStartHangupHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] RequestPlayerStartHangup called");
            SendEmptySuccessReturn(conn, msg, MethodId.RequestPlayerStartHangup);
        }

                [Handler(MethodId.RequestPlayerStopHangup)]
        public static void RequestPlayerStopHangupHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] RequestPlayerStopHangup called");
            SendEmptySuccessReturn(conn, msg, MethodId.RequestPlayerStopHangup);
        }

                [Handler(MethodId.RequestRevive)]
        public static void RequestReviveHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] RequestRevive called");
            SendEmptySuccessReturn(conn, msg, MethodId.RequestRevive);
        }

                [Handler(MethodId.ResponseAllFriendApplication)]
        public static void ResponseAllFriendApplicationHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] ResponseAllFriendApplication called");
            SendEmptySuccessReturn(conn, msg, MethodId.ResponseAllFriendApplication);
        }

                [Handler(MethodId.ResponseChatGroupInvite)]
        public static void ResponseChatGroupInviteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Chat] ResponseChatGroupInvite called");
            SendEmptySuccessReturn(conn, msg, MethodId.ResponseChatGroupInvite);
        }

                [Handler(MethodId.ResponseFriendApplication)]
        public static void ResponseFriendApplicationHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] ResponseFriendApplication called");
            SendEmptySuccessReturn(conn, msg, MethodId.ResponseFriendApplication);
        }

                [Handler(MethodId.SetGameGroundPlayerPlayAgain)]
        public static void SetGameGroundPlayerPlayAgainHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] SetGameGroundPlayerPlayAgain called");
            SendEmptySuccessReturn(conn, msg, MethodId.SetGameGroundPlayerPlayAgain);
        }

                [Handler(MethodId.SetGameGroundPlayerReady)]
        public static void SetGameGroundPlayerReadyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] SetGameGroundPlayerReady called");
            SendEmptySuccessReturn(conn, msg, MethodId.SetGameGroundPlayerReady);
        }

                [Handler(MethodId.SetSceneItemNavAndVoxel)]
        public static void SetSceneItemNavAndVoxelHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Item] SetSceneItemNavAndVoxel called");
            SendEmptySuccessReturn(conn, msg, MethodId.SetSceneItemNavAndVoxel);
        }

                [Handler(MethodId.SetUIInvisible)]
        public static void SetUIInvisibleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] SetUIInvisible called");
            SendEmptySuccessReturn(conn, msg, MethodId.SetUIInvisible);
        }

                [Handler(MethodId.SetUIInvisible2)]
        public static void SetUIInvisible2Handler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] SetUIInvisible2 called");
            SendEmptySuccessReturn(conn, msg, MethodId.SetUIInvisible2);
        }

                [Handler(MethodId.ShowAllServerDumpInfo)]
        public static void ShowAllServerDumpInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Map] ShowAllServerDumpInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.ShowAllServerDumpInfo);
        }

                [Handler(MethodId.ShowTaskChangePanel)]
        public static void ShowTaskChangePanelHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] ShowTaskChangePanel called");
            SendEmptySuccessReturn(conn, msg, MethodId.ShowTaskChangePanel);
        }

                [Handler(MethodId.SpoonClientCountBehavior)]
        public static void SpoonClientCountBehaviorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] SpoonClientCountBehavior called");
            SendEmptySuccessReturn(conn, msg, MethodId.SpoonClientCountBehavior);
        }

                [Handler(MethodId.TaskSpoonCountBehavior)]
        public static void TaskSpoonCountBehaviorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Task] TaskSpoonCountBehavior called");
            SendEmptySuccessReturn(conn, msg, MethodId.TaskSpoonCountBehavior);
        }

                [Handler(MethodId.ToggleStoryDebug)]
        public static void ToggleStoryDebugHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] ToggleStoryDebug called");
            SendEmptySuccessReturn(conn, msg, MethodId.ToggleStoryDebug);
        }

                [Handler(MethodId.TriggerChefZone)]
        public static void TriggerChefZoneHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] TriggerChefZone called");
            SendEmptySuccessReturn(conn, msg, MethodId.TriggerChefZone);
        }

                [Handler(MethodId.TriggerDartTiming)]
        public static void TriggerDartTimingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] TriggerDartTiming called");
            SendEmptySuccessReturn(conn, msg, MethodId.TriggerDartTiming);
        }

                [Handler(MethodId.UnlockInvestigateGallery)]
        public static void UnlockInvestigateGalleryHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Investigate] UnlockInvestigateGallery called");
            SendEmptySuccessReturn(conn, msg, MethodId.UnlockInvestigateGallery);
        }

                [Handler(MethodId.UpdateDaShenLogToken)]
        public static void UpdateDaShenLogTokenHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Profile] UpdateDaShenLogToken called");
            SendEmptySuccessReturn(conn, msg, MethodId.UpdateDaShenLogToken);
        }

                [Handler(MethodId.UpdateLoginNgPushRegid)]
        public static void UpdateLoginNgPushRegidHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Profile] UpdateLoginNgPushRegid called");
            SendEmptySuccessReturn(conn, msg, MethodId.UpdateLoginNgPushRegid);
        }

                [Handler(MethodId.UpdateNgPushRegid)]
        public static void UpdateNgPushRegidHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Profile] UpdateNgPushRegid called");
            SendEmptySuccessReturn(conn, msg, MethodId.UpdateNgPushRegid);
        }

                [Handler(MethodId.UpdateNgPushSetting)]
        public static void UpdateNgPushSettingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Profile] UpdateNgPushSetting called");
            SendEmptySuccessReturn(conn, msg, MethodId.UpdateNgPushSetting);
        }

                [Handler(MethodId.VehicleDriveScore)]
        public static void VehicleDriveScoreHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] VehicleDriveScore called");
            SendEmptySuccessReturn(conn, msg, MethodId.VehicleDriveScore);
        }

                [Handler(MethodId.VehicleDriveStateChange)]
        public static void VehicleDriveStateChangeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Vehicle] VehicleDriveStateChange called");
            SendEmptySuccessReturn(conn, msg, MethodId.VehicleDriveStateChange);
        }

                [Handler(MethodId.VerifyMobileBindSMSCode)]
        public static void VerifyMobileBindSMSCodeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] VerifyMobileBindSMSCode called");
            SendEmptySuccessReturn(conn, msg, MethodId.VerifyMobileBindSMSCode);
        }

                [Handler(MethodId.ViewedEventPanel)]
        public static void ViewedEventPanelHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[UI] ViewedEventPanel called");
            SendEmptySuccessReturn(conn, msg, MethodId.ViewedEventPanel);
        }

        // ======================== GANG BOSS DATA WRAPPERS ========================

        private class GangMemberDetailData : SerializedClass
        {
            public uint TemplateId;
            public bool IsUnlock;
            public double NextReviveTimeStamp;
            public ulong InstanceId;
            public float HpPercent;

            public GangMemberDetailData()
            {
                onlyFields = true;
            }
        }

        private class GangBossMemberListData : SerializedClass
        {
            public Dictionary<uint, GangMemberDetailData> GangMembers;

            public GangBossMemberListData()
            {
                onlyFields = true;
            }
        }

        private class GangBossFullDetailsData : SerializedClass
        {
            public GangBossMemberListData full;
            public int CurrentBattleAgentCount;

            public GangBossFullDetailsData()
            {
                onlyFields = true;
            }
        }

        // ==================== FASE 5: ASK STUBS ====================
        // Empty success stubs for common Ask* methods the client sends during gameplay

        [Handler(MethodId.AskCreateTeam)]
        public static void AskCreateTeamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Team] AskCreateTeam called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCreateTeam);
        }

        [Handler(MethodId.AskJoinTeam)]
        public static void AskJoinTeamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Team] AskJoinTeam called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskJoinTeam);
        }

        [Handler(MethodId.AskLeaveTeam)]
        public static void AskLeaveTeamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Team] AskLeaveTeam called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskLeaveTeam);
        }

        [Handler(MethodId.AskInviteToTeam)]
        public static void AskInviteToTeamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Team] AskInviteToTeam called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskInviteToTeam);
        }

        [Handler(MethodId.AskKickTeamMember)]
        public static void AskKickTeamMemberHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Team] AskKickTeamMember called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskKickTeamMember);
        }

        [Handler(MethodId.AskDrawGacha)]
        public static void AskDrawGachaHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Gacha] AskDrawGacha called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDrawGacha);
        }

        [Handler(MethodId.AskDeleteMail)]
        public static void AskDeleteMailHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Mail] AskDeleteMail called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDeleteMail);
        }

        [Handler(MethodId.AskGetMailsItem)]
        public static void AskGetMailsItemHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Mail] AskGetMailsItem called");
            SendEmptySuccessReturn(conn, msg, MethodId.AskGetMailsItem);
        }

        [Handler(MethodId.AskDoGuide)]
        public static void AskDoGuideHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Guide] AskDoGuide called");
            // Client starts a tutorial guide step
            try
            {
                if (msg.Args != null && msg.Args.Length >= 4)
                {
                    int guideId = BitConverter.ToInt32(msg.Args, 0);
                    Console.WriteLine($"[Guide] DoGuide: guideId={guideId} → started");
                }
            }
            catch { }
            SendEmptySuccessReturn(conn, msg, MethodId.AskDoGuide);
        }

        [Handler(MethodId.AskFinishGuide)]
        public static void AskFinishGuideHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Guide] AskFinishGuide called");
            // Client completes a tutorial guide step
            try
            {
                if (msg.Args != null && msg.Args.Length >= 4)
                {
                    int guideId = BitConverter.ToInt32(msg.Args, 0);
                    Console.WriteLine($"[Guide] FinishGuide: guideId={guideId} → completed");
                }
            }
            catch { }
            SendEmptySuccessReturn(conn, msg, MethodId.AskFinishGuide);
        }

        private static void ProcessBuyCommodity(Connection conn, uint templateId, uint count, MethodId methodId, UxRpcMessage msg)
        {
            var config = ConfigManager.GetConsumable(templateId);
            if (config == null)
            {
                Console.WriteLine($"[Shop] Unknown commodity templateId={templateId}");
                SendEmptySuccessReturn(conn, msg, methodId);
                return;
            }

            uint totalCost = (uint)(config.SystemPrice * count);
            if (conn.PlayerItems.Money < totalCost)
            {
                Console.WriteLine($"[Shop] Insufficient money for templateId={templateId} x{count}, cost={totalCost}, balance={conn.PlayerItems.Money}");
                SendEmptySuccessReturn(conn, msg, methodId);
                return;
            }

            conn.PlayerItems.Money -= totalCost;
            var existing = conn.PlayerItems.PackItems?.FirstOrDefault(p => p.TemplateId == templateId);
            if (existing != null)
            {
                existing.Count += count;
                existing.IsNew = true;
                SendNotifyItemChange(conn, existing.UniqueId, templateId, (int)existing.Count, true);
            }
            else
            {
                ulong uniqueId = (ulong)(DateTimeOffset.UtcNow.ToUnixTimeSeconds() * 1000 + new Random().Next(1000, 9999));
                conn.PlayerItems.PackItems.Add(new PlayerPackItem()
                {
                    UniqueId = uniqueId,
                    TemplateId = templateId,
                    Count = count,
                    IsNew = true,
                    ExpiryTime = 0,
                    CDFinishTime = 0
                });
                SendNotifyItemChange(conn, uniqueId, templateId, (int)count, true);
            }

            SendNotifyMoney(conn, conn.PlayerItems.Money);

            Console.WriteLine($"[Shop] Purchased templateId={templateId} x{count}, cost={totalCost}, new balance={conn.PlayerItems.Money}");
            SendEmptySuccessReturn(conn, msg, methodId);
        }

        private static void SendNotifyItemChange(Connection conn, ulong uniqueId, uint itemId, int count, bool isNew)
        {
            UxRpcMessage notify = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBackpackItemChanged,
            };
            notify.SetArgs(MethodId.SyncBackpackItemChanged, new SyncBackpackItemChanged()
            {
                uniqueId = uniqueId,
                itemId = itemId,
                count = count,
                isNew = isNew
            });
            conn.SendPacket(notify);
        }

        private static void SendNotifyMoney(Connection conn, uint totalMoney)
        {
            UxRpcMessage notifyAdd = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMoneyAdd,
            };
            notifyAdd.SetArgs(MethodId.SyncMoneyAdd, new SyncMoneyAddData() { money = totalMoney });
            conn.SendPacket(notifyAdd);

            UxRpcMessage notifySync = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMoney,
            };
            notifySync.SetArgs(MethodId.SyncMoney, new SyncMoneyData() { money = totalMoney });
            conn.SendPacket(notifySync);
        }

        [Handler(MethodId.AskBuyCommodity)]
        public static void AskBuyCommodityHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Shop] AskBuyCommodity called");
            try
            {
                var args = msg.GetArgs<AskBuyCommodityArgs>();
                ProcessBuyCommodity(conn, args.templateId, args.count > 0 ? args.count : 1, MethodId.AskBuyCommodity, msg);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Shop] AskBuyCommodity error: {ex.Message}");
                SendEmptySuccessReturn(conn, msg, MethodId.AskBuyCommodity);
            }
        }

        public class AskBuyCommodityArgs : SerializedClass
        {
            public uint templateId;
            public uint count;
            public AskBuyCommodityArgs() { onlyFields = true; }
        }

        [Handler(MethodId.AskMallBuyCommodity)]
        public static void AskMallBuyCommodityHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Shop] AskMallBuyCommodity called");
            try
            {
                var args = msg.GetArgs<AskMallBuyCommodityArgs>();
                uint c = args.count > 0 ? args.count : 1;
                ProcessBuyCommodity(conn, args.templateId, c, MethodId.AskMallBuyCommodity, msg);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Shop] AskMallBuyCommodity error: {ex.Message}");
                SendEmptySuccessReturn(conn, msg, MethodId.AskMallBuyCommodity);
            }
        }

        public class AskMallBuyCommodityArgs : SerializedClass
        {
            public uint templateId;
            public uint count;
            public AskMallBuyCommodityArgs() { onlyFields = true; }
        }

        public class AskBuyCommoditiesArgs : SerializedClass
        {
            public List<BuyCommodityItem> commodityList;
            public AskBuyCommoditiesArgs() { onlyFields = true; }
        }

        public class BuyCommodityItem : SerializedClass
        {
            public uint templateId;
            public uint count;
            public BuyCommodityItem() { onlyFields = true; }
        }

        [Handler(MethodId.AskBuyCommodities)]
        public static void AskBuyCommoditiesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Shop] AskBuyCommodities called");
            try
            {
                var args = msg.GetArgs<AskBuyCommoditiesArgs>();
                if (args.commodityList != null)
                {
                    foreach (var item in args.commodityList)
                    {
                        uint c = item.count > 0 ? item.count : 1;
                        ProcessBuyCommodity(conn, item.templateId, c, MethodId.AskBuyCommodities, msg);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Shop] AskBuyCommodities error: {ex.Message}");
            }
            SendEmptySuccessReturn(conn, msg, MethodId.AskBuyCommodities);
        }

        [Handler(MethodId.AskQueryTeamInfo)]
        public static void AskQueryTeamInfoHandler(Connection conn, UxRpcMessage msg)
        {
            // Single-player private server: no team/party system
            // ClientTeamInfo type is in external UX.Game DLL (not available)
            Console.WriteLine("[Team] AskQueryTeamInfo → no team (single-player)");
            SendEmptySuccessReturn(conn, msg, MethodId.AskQueryTeamInfo);
        }

        [Handler(MethodId.AskFactionInfo)]
        public static void AskFactionInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Faction] AskFactionInfo → returning {conn.FactionInfoDic.Count} factions");
            
            // Build FactionChangeInfo list from connection's faction data
            var changeInfos = new List<SyncFactionInfosChange.FactionChangeInfo>();
            foreach (var kvp in conn.FactionInfoDic)
            {
                changeInfos.Add(new SyncFactionInfosChange.FactionChangeInfo()
                {
                    FactionId = kvp.Key,
                    NewInfo = kvp.Value,
                    OldInfo = new FactionInfo()
                    {
                        Disposition = kvp.Value.Disposition,
                        DispositionLevel = kvp.Value.DispositionLevel,
                        Influence = kvp.Value.Influence,
                        InteractionCount = kvp.Value.InteractionCount,
                        GreetCount = kvp.Value.GreetCount,
                    },
                });
            }
            
            // Send faction data to client via SyncFactionInfosChange notify
            SendNotify(conn, MethodId.SyncFactionInfosChange, new SyncFactionInfosChange()
            {
                changeInfos = changeInfos,
                dropTextId = 0,
            });
        }

        [Handler(MethodId.AskPassingTime)]
        public static void AskPassingTimeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Game] AskPassingTime called");
            
            // Calculate current game time based on timeOffset
            uint realTime = (uint)(DateTimeOffset.UtcNow.ToUnixTimeSeconds() + conn.timeOffset);
            DateTime now = DateTime.Now.AddSeconds(conn.timeOffset);
            uint raidDaySeconds = (uint)(now.Hour * 3600 + now.Minute * 60 + now.Second);
            
            // Send SyncPlayerCurrentTime notify to client
            SendNotify(conn, MethodId.SyncPlayerCurrentTime, new SyncPlayerCurrentTime()
            {
                realTime = realTime,
                raidDaySeconds = raidDaySeconds,
                fix = false,
                transitionSecond = 0,
                reason = SyncPlayerCurrentTime.RaidTimeAndWeatherChangeReason.Client,
            });
        }

        // ==================== CHAT / MESSAGING HANDLERS ====================

        // --- Send Message handlers ---

        [Handler(MethodId.SendMessageToPlayer)]
        public static void SendMessageToPlayerHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<SendMessageToPlayerArgs>();
            Console.WriteLine($"[Chat] SendMessageToPlayer: pid={args.Pid}, text={args.Text}, isAudio={args.IsAudio}");
            var chatMsg = conn.Chat.CreateMessage(MessageChannel.P2P, conn.Pid, args.Pid, args.Text, args.IsAudio);
            conn.Chat.P2PMessages.Add(chatMsg);
            SendEmptySuccessReturn(conn, msg, MethodId.SendMessageToPlayer);
        }

        [Handler(MethodId.SendMessageToRoom)]
        public static void SendMessageToRoomHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<SendMessageToRoomArgs>();
            Console.WriteLine($"[Chat] SendMessageToRoom: text={args.Text}, isAudio={args.IsAudio}");
            var chatMsg = conn.Chat.CreateMessage(MessageChannel.Room, conn.Pid, 0, args.Text, args.IsAudio);
            conn.Chat.RoomMessages.Add(chatMsg);
            SendEmptySuccessReturn(conn, msg, MethodId.SendMessageToRoom);
        }

        [Handler(MethodId.SendMessageToTeam)]
        public static void SendMessageToTeamHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<SendMessageToTeamArgs>();
            Console.WriteLine($"[Chat] SendMessageToTeam: text={args.Text}, isAudio={args.IsAudio}");
            var chatMsg = conn.Chat.CreateMessage(MessageChannel.Team, conn.Pid, 0, args.Text, args.IsAudio);
            conn.Chat.TeamMessages.Add(chatMsg);
            SendEmptySuccessReturn(conn, msg, MethodId.SendMessageToTeam);
        }

        [Handler(MethodId.SendMessageToChatGroup)]
        public static void SendMessageToChatGroupHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<SendMessageToChatGroupArgs>();
            Console.WriteLine($"[Chat] SendMessageToChatGroup: groupId={args.GroupId}, text={args.Text}, isAudio={args.IsAudio}");
            var chatMsg = conn.Chat.CreateMessage(MessageChannel.ChatGroup, conn.Pid, args.GroupId, args.Text, args.IsAudio);
            if (!conn.Chat.ChatGroupMessages.ContainsKey(args.GroupId))
                conn.Chat.ChatGroupMessages[args.GroupId] = new();
            conn.Chat.ChatGroupMessages[args.GroupId].Add(chatMsg);
            SendEmptySuccessReturn(conn, msg, MethodId.SendMessageToChatGroup);
        }

        [Handler(MethodId.SendMessageToLink)]
        public static void SendMessageToLinkHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<SendMessageToLinkArgs>();
            Console.WriteLine($"[Chat] SendMessageToLink: mode={args.Mode}, text={args.Text}, isAudio={args.IsAudio}");
            MessageChannel channel = args.Mode switch
            {
                LinkMode.Private => MessageChannel.PrivateLink,
                LinkMode.Public => MessageChannel.PublicLink,
                LinkMode.Match => MessageChannel.MatchLink,
                _ => MessageChannel.PrivateLink,
            };
            var chatMsg = conn.Chat.CreateMessage(channel, conn.Pid, 0, args.Text, args.IsAudio);
            int modeKey = (int)args.Mode;
            if (!conn.Chat.LinkMessages.ContainsKey(modeKey))
                conn.Chat.LinkMessages[modeKey] = new();
            conn.Chat.LinkMessages[modeKey].Add(chatMsg);
            SendEmptySuccessReturn(conn, msg, MethodId.SendMessageToLink);
        }

        [Handler(MethodId.SendMessageToLocation)]
        public static void SendMessageToLocationHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Chat] SendMessageToLocation called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendMessageToLocation);
        }

        // --- Get Message handlers ---

        [Handler(MethodId.GetP2PMessageList)]
        public static void GetP2PMessageListHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GetP2PMessageListArgs>();
            Console.WriteLine($"[Chat] GetP2PMessageList: friendPid={args.FriendPid}, timestamp={args.Timestamp}");
            var messages = conn.Chat.GetMessagesAfter(conn.Chat.P2PMessages, args.Timestamp);
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.GetP2PMessageList,
            };
            rsp.SetArgs(MethodId.GetP2PMessageList, new ChatMessagesBlob() { Messages = messages });
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GetP2PMessageListWithRange)]
        public static void GetP2PMessageListWithRangeHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GetP2PMessageListWithRangeArgs>();
            Console.WriteLine($"[Chat] GetP2PMessageListWithRange: friendPid={args.FriendPid}, start={args.StartTimestamp}, end={args.EndTimestamp}, count={args.Count}");
            var messages = conn.Chat.GetMessagesInRange(conn.Chat.P2PMessages, args.StartTimestamp, args.EndTimestamp, args.Count);
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.GetP2PMessageListWithRange,
            };
            rsp.SetArgs(MethodId.GetP2PMessageListWithRange, new ChatMessagesBlob() { Messages = messages });
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GetP2PLatestMessageList)]
        public static void GetP2PLatestMessageListHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GetP2PLatestMessageListArgs>();
            Console.WriteLine($"[Chat] GetP2PLatestMessageList: targets={args.Targets?.Count ?? 0}");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.GetP2PLatestMessageList,
            };
            rsp.SetArgs(MethodId.GetP2PLatestMessageList, new ChatMessagesBlob() { Messages = new() });
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GetManyP2PMessages)]
        public static void GetManyP2PMessagesHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GetManyP2PMessagesArgs>();
            Console.WriteLine($"[Chat] GetManyP2PMessages: targets={args.Targets?.Count ?? 0}");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.GetManyP2PMessages,
            };
            rsp.SetArgs(MethodId.GetManyP2PMessages, new ChatMessagesBlob() { Messages = new() });
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GetRoomMessages)]
        public static void GetRoomMessagesHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GetRoomMessagesArgs>();
            Console.WriteLine($"[Chat] GetRoomMessages: timestamp={args.Timestamp}");
            var messages = conn.Chat.GetMessagesAfter(conn.Chat.RoomMessages, args.Timestamp);
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.GetRoomMessages,
            };
            rsp.SetArgs(MethodId.GetRoomMessages, new ChatMessagesBlob() { Messages = messages });
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GetRoomLatestMessage)]
        public static void GetRoomLatestMessageHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Chat] GetRoomLatestMessage called");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.GetRoomLatestMessage,
            };
            rsp.SetArgs(MethodId.GetRoomLatestMessage, new ChatMessagesBlob() { Messages = new() });
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GetTeamMessages)]
        public static void GetTeamMessagesHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GetTeamMessagesArgs>();
            Console.WriteLine($"[Chat] GetTeamMessages: timestamp={args.Timestamp}");
            var messages = conn.Chat.GetMessagesAfter(conn.Chat.TeamMessages, args.Timestamp);
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.GetTeamMessages,
            };
            rsp.SetArgs(MethodId.GetTeamMessages, new ChatMessagesBlob() { Messages = messages });
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GetTeamLatestMessage)]
        public static void GetTeamLatestMessageHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Chat] GetTeamLatestMessage called");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.GetTeamLatestMessage,
            };
            rsp.SetArgs(MethodId.GetTeamLatestMessage, new ChatMessagesBlob() { Messages = new() });
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GetChatGroupMessages)]
        public static void GetChatGroupMessagesHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GetChatGroupMessagesArgs>();
            Console.WriteLine($"[Chat] GetChatGroupMessages: groupId={args.GroupId}, timestamp={args.Timestamp}");
            var groupMsgs = conn.Chat.ChatGroupMessages.TryGetValue(args.GroupId, out var list) ? list : new List<ChatMessage>();
            var messages = conn.Chat.GetMessagesAfter(groupMsgs, args.Timestamp);
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.GetChatGroupMessages,
            };
            rsp.SetArgs(MethodId.GetChatGroupMessages, new ChatMessagesBlob() { Messages = messages });
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GetChatGroupMessagesWithRange)]
        public static void GetChatGroupMessagesWithRangeHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GetChatGroupMessagesWithRangeArgs>();
            Console.WriteLine($"[Chat] GetChatGroupMessagesWithRange: groupId={args.GroupId}, start={args.StartTimestamp}, end={args.EndTimestamp}, count={args.Count}");
            var groupMsgs = conn.Chat.ChatGroupMessages.TryGetValue(args.GroupId, out var list) ? list : new List<ChatMessage>();
            var messages = conn.Chat.GetMessagesInRange(groupMsgs, args.StartTimestamp, args.EndTimestamp, args.Count);
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.GetChatGroupMessagesWithRange,
            };
            rsp.SetArgs(MethodId.GetChatGroupMessagesWithRange, new ChatMessagesBlob() { Messages = messages });
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GetLinkMessages)]
        public static void GetLinkMessagesHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GetLinkMessagesArgs>();
            Console.WriteLine($"[Chat] GetLinkMessages: mode={args.Mode}, timestamp={args.Timestamp}");
            int modeKey = (int)args.Mode;
            var linkMsgs = conn.Chat.LinkMessages.TryGetValue(modeKey, out var list) ? list : new List<ChatMessage>();
            var messages = conn.Chat.GetMessagesAfter(linkMsgs, args.Timestamp);
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.GetLinkMessages,
            };
            rsp.SetArgs(MethodId.GetLinkMessages, new ChatMessagesBlob() { Messages = messages });
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GetLinkLatestMessage)]
        public static void GetLinkLatestMessageHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GetLinkLatestMessageArgs>();
            Console.WriteLine($"[Chat] GetLinkLatestMessage: mode={args.Mode}");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.GetLinkLatestMessage,
            };
            rsp.SetArgs(MethodId.GetLinkLatestMessage, new ChatMessagesBlob() { Messages = new() });
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GetLinkMessageList)]
        public static void GetLinkMessageListHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GetLinkMessageListArgs>();
            Console.WriteLine($"[Chat] GetLinkMessageList: mode={args.Mode}");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.GetLinkMessageList,
            };
            rsp.SetArgs(MethodId.GetLinkMessageList, new ChatMessagesBlob() { Messages = new() });
            conn.SendPacket(rsp);
        }

        // --- Utility handlers ---

        [Handler(MethodId.MarkAsReadPrivateMessage)]
        public static void MarkAsReadPrivateMessageHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<MarkAsReadPrivateMessageArgs>();
            Console.WriteLine($"[Chat] MarkAsReadPrivateMessage: pid={args.Pid}");
            SendEmptySuccessReturn(conn, msg, MethodId.MarkAsReadPrivateMessage);
        }

        [Handler(MethodId.GetSimplePlayerInfoByPidList)]
        public static void GetSimplePlayerInfoByPidListHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GetSimplePlayerInfoByPidListArgs>();
            Console.WriteLine($"[Chat] GetSimplePlayerInfoByPidList: pids={args.Pids?.Count ?? 0}");
            var playerInfos = new List<NameCard>();
            if (args.Pids != null)
            {
                foreach (var pid in args.Pids)
                {
                    playerInfos.Add(new NameCard()
                    {
                        Pid = pid,
                        Name = pid == conn.Pid ? "Player" : $"Player_{pid}",
                        Level = 1,
                    });
                }
            }
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.GetSimplePlayerInfoByPidList,
            };
            rsp.SetArgs(MethodId.GetSimplePlayerInfoByPidList, new GetSimplePlayerInfoByPidListReturn() { PlayerInfos = playerInfos });
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GetServerTime)]
        public static void GetServerTimeHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<GetServerTimeArgs>();
            Console.WriteLine($"[Chat] GetServerTime: clientTime={args.ClientUnixTime}");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.GetServerTime,
            };
            rsp.SetArgs(MethodId.GetServerTime, new GetServerTimeReturn()
            {
                ServerTime = DateTimeOffset.UtcNow.ToUnixTimeSeconds(),
                ClientTime = args.ClientUnixTime,
            });
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.UploadLogs)]
        public static void UploadLogsHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<UploadLogsArgs>();
            Console.WriteLine($"[Chat] UploadLogs: count={args.Logs?.Count ?? 0}, token={args.Token}");
            SendEmptySuccessReturn(conn, msg, MethodId.UploadLogs);
        }
    }
}
