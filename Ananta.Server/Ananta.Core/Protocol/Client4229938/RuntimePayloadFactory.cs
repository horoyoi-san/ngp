using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.RpcTypes.Client4229938;
using Ananta.Server.State;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Protocol.Client4229938;

internal static class RuntimePayloadFactory
{
    private static PrivateServerConfig Config => PrivateServerConfigStore.Current;

    internal static Auto.PlayerClientInfo MinimalPlayerInfo4229938()
    {
        
        
        var root = new Auto.PlayerClientInfo();
        root.InfoLogin.Aid = Config.Client.Aid;
        root.InfoLogin.Pid = Profile.PlayerPid;
        root.InfoLogin.AccountId = Profile.AccountId;
        root.InfoLogin.Name = Profile.DisplayName;
        root.InfoLogin.Level = 1;
        root.InfoLogin.Sex = 1;
        root.InfoLogin.UseSystemName = false;
        root.InfoLogin.UniverseId = Config.Player.LoginUniverseId;

        
        
        
        
        
        var spirits = ClientConfigRepository.Characters().Select(MinimalActorCharacterSpirit4229938).ToList();
        var actorArmory = spirits
            .SelectMany(spirit => spirit.WeaponSlots)
            .OfType<Auto.WeaponData>()
            .Where(weapon => weapon.InstanceId != 0)
            .GroupBy(weapon => weapon.InstanceId)
            .Select(group => group.First())
            .OrderBy(weapon => weapon.InstanceId)
            .ToList();

        root.InfoSpirit.Spirits = spirits;
        root.InfoSpirit.ActiveSpirit = Config.Player.InitialSpiritTemplateId;
        root.InfoSpirit.InfoPokemon.FastFightSquad = [Config.Player.InitialUnitId];
        root.InfoSpirit.InfoArmory.Weapons = actorArmory;

        
        
        
        
        
        
        
        
        
        
        
        var spiritContent = Config.Gameplay.SpiritContent;
        foreach (var (styleId, unlockTime) in CollectFightStyleUnlocks(spiritContent))
        {
            root.InfoSpirit.InfoFightStyle.FightStyleIsUnLocked[styleId] = true;
            root.InfoSpirit.InfoFightStyle.FightStyleFirstUnlockTimes[styleId] = unlockTime;
        }

        root.InfoMinor.Level = 1;
        root.InfoMinor.MatchInfo.DeviceLevel = 1;
        root.InfoMinor.MatchInfo.CurLinkDeviceLevel = 1;

        
        
        
        
        
        root.InfoSpirit.InstalledApps = CollectInstalledApps(spiritContent);
        
        
        root.InfoMinor.PlayerPhoneInfo.DownLoadAppIds = [.. root.InfoSpirit.InstalledApps];

        
        root.InfoSpirit.CommonSpiritTalentExp = spiritContent.CommonSpiritTalentExp;
        root.InfoSpirit.SpiritInitTalentPointAdd = spiritContent.SpiritInitTalentPointAdd;

        
        if (Config.Gameplay.Vehicles.Enabled && Config.Gameplay.Vehicles.FleetIds.Length > 0)
        {
            root.InfoMinor.VehicleInfo = new Auto.PlayerVehicleInfo
            {
                UnlockedVehicles = Config.Gameplay.Vehicles.FleetIds.Select(fleetId => new Auto.PlayerVehicleDetail
                {
                    Id = fleetId,
                    UnlockTime = 1,
                    SuitId = 0,
                    Parts = [],
                }).ToList(),
                RequisitionVehicleCount = Config.Gameplay.Vehicles.FleetIds.Length,
                ParkingVehicleId = 0,
            };
        }
        
        
        
        
        var summonContacts = new (string Remark, string Number)[]
        {
            (string.Empty, "142857"),
            (string.Empty, "206337"),
        };
        foreach (var character in ClientConfigRepository.Characters())
        {
            root.InfoMinor.PlayerPhoneInfo.SpiritPhoneInfos[character.TemplateId] = new Auto.PhoneInfos
            {
                ContactList = summonContacts.Select(c => new Auto.PhoneContact
                {
                    Remark = c.Remark,
                    PhoneNumber = c.Number,
                }).ToList(),
                ContactGroupList = [],
                CallRecordList = [],
                ContactOutgoingCallTimesDict = new Dictionary<string, uint>(),
            };
        }

        
        
        
        
        
        var phoneProgress = new Auto.ModuleEventProgressInfoBySpirit
        {
            EventProgressInfoDict = new Dictionary<uint, Auto.EventProgressInfo>(),
            FinishedTemplateIdList = [1, 2],
        };
        var phoneModule = new Auto.ModuleEventProgressInfo
        {
            ProgressInfoDict = new Dictionary<uint, Auto.ModuleEventProgressInfoBySpirit>
            {
                [0] = phoneProgress,
            },
        };
        foreach (var character in ClientConfigRepository.Characters())
            phoneModule.ProgressInfoDict[character.TemplateId] = phoneProgress;
        root.InfoMinor.ModuleEventProgressInfoDict[3] = phoneModule;

        
        
        
        
        root.InfoMinor.PlayerInfoGuide.UnlockSystems = ClientConfigRepository.UnlockSystemIds().ToList();
        root.InfoMinor.PlayerFashionsInfo = MinimalPlayerFashions4229938(EffectiveUnlockedFashions4229938());
        ApplyQuestSeed4229938(root);

        
        
        ApplyEconomy4229938(root);

        
        
        
        ApplyCityPedia4229938(root);

        
        
        ApplyAgentProfiles4229938(root);

        
        
        var gameplayTalents = GameplayTalentInfos4229938();
        if (gameplayTalents.Count > 0)
        {
            foreach (var (gameplayId, info) in gameplayTalents)
                root.InfoMinor.GameplayTalentInfos[gameplayId] = info;
        }

        return root;
    }

    
    
    
    
    
    
    private static void ApplyCityPedia4229938(Auto.PlayerClientInfo root)
    {
        var rows = ExtraCatalog.CityPediaRows;
        if (rows.Count == 0)
            return;

        var pedia = root.InfoMinor.PlayerCityPediaInfos;
        foreach (var row in rows)
        {
            var progress = row.MaxProgress > 0 ? row.MaxProgress : 1;
            pedia.CityPediaStatusDict[row.Id] = (byte)Math.Clamp(progress, 1, 255);
        }

        
        
        pedia.CreditInfo.CreditByType.Clear();
        pedia.CreditInfo.Level = 0;
        pedia.CreditInfo.ClaimedLevelRewards.Clear();
    }

    
    
    
    
    private static void ApplyAgentProfiles4229938(Auto.PlayerClientInfo root)
    {
        var profiles = ExtraCatalog.AgentProfiles;
        if (profiles.Count == 0)
            return;

        var targetIds = ExtraCatalog.NpcProfileTargets;
        var profile = root.InfoMinor.InfoNpcProfile;

        foreach (var row in profiles)
        {
            var info = new Auto.TrustNpcInfo
            {
                ProfileId = row.Id,
                TrustValue = row.MaxTrust > 0 ? row.MaxTrust : 1000u,
                ActivateTime = 1,
                IsNew = false,
                IsMaxTrustReward = false,
            };

            
            
            foreach (var targetId in targetIds)
                info.TargetStateList.Add(new Auto.TrustNpcTargetState { TargetId = targetId, IsNew = false });

            profile.NpcProfiles[row.Id] = info;
        }

        
        foreach (var row in profiles)
            profile.ProgressRewardsWithWeb.TryAdd(row.Id, new Auto.NpcProfileWebProgress());

        
        foreach (var badge in ExtraCatalog.Badges)
            root.InfoMinor.Badges.TryAdd(badge.Id, new Auto.BadgeInfo
            {
                TemplateId = badge.Id,
                Active = true,
                DropSend = false,
            });
    }

    
    
    
    
    private static void ApplyQuestSeed4229938(Auto.PlayerClientInfo root)
    {
        
        
        
        
        
        
        
        
        
        
        
        var systems = Config.Gameplay.Systems;
        if (systems.Enabled)
        {
            var systemIds = systems.UnlockAll
                ? ClientData.Client4229938.SystemUnlockCatalogRepository.AllIds()
                : systems.UnlockIds;
            foreach (var systemId in systemIds)
                if (!root.InfoMinor.PlayerInfoGuide.UnlockSystems.Contains(systemId))
                    root.InfoMinor.PlayerInfoGuide.UnlockSystems.Add(systemId);
        }

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        const uint NeutralDispositionLevel = 3;
        var factionInfos = root.InfoAchievement.FactionInfoDic;
        factionInfos[0] = new Auto.FactionInfo { Disposition = 0, DispositionLevel = NeutralDispositionLevel, IsUnlock = true };
        foreach (var factionId in State.ExtraCatalog.Factions)
            factionInfos[factionId] = new Auto.FactionInfo { Disposition = 0, DispositionLevel = NeutralDispositionLevel, IsUnlock = true };

        
        
        
        
        
        
        
        
        
        
        
        var poiIds = root.InfoAchievement.SceneFogMapPoiIds;
        var mapPins = root.InfoMinor.MapPins;
        foreach (var e in State.ExtraCatalog.MapEntrances)
        {
            if (!poiIds.Contains(e.Id))
                poiIds.Add(e.Id);

            mapPins[e.Id] = new Auto.MapPin
            {
                RaidId = e.RaidId,
                Position = new Auto.UXVector3 { X = e.X, Y = e.Y, Z = e.Z },
                Type = (byte)Math.Clamp(e.Type, 0, 255),
                PosAdjusted = false,
            };
        }

        var quests = Config.Gameplay.Quests;
        if (!quests.Enabled)
            return;

        foreach (var questId in quests.UnlockedQuestIds.Distinct())
            if (!root.InfoAchievement.UnlockedQuestList.Contains(questId))
                root.InfoAchievement.UnlockedQuestList.Add(questId);

        foreach (var guideId in quests.FinishedGuideIds.Distinct())
            if (!root.InfoMinor.PlayerInfoGuide.FinishedGuides.Contains(guideId))
                root.InfoMinor.PlayerInfoGuide.FinishedGuides.Add(guideId);

        foreach (var questId in quests.UnlockedQuestIds.Distinct())
            root.InfoAchievement.CompletedSubQuestCnt[questId] = 0;
    }

    
    
    
    
    
    
    
    
    
    
    private static void ApplyEconomy4229938(Auto.PlayerClientInfo root)
    {
        var economy = Config.Gameplay.Economy;
        if (!economy.Enabled)
            return;

        root.InfoItem.Money = economy.Money;
        root.InfoItem.Gold = economy.Gold;
        root.InfoItem.BindingGold = economy.BindingGold;
        root.InfoItem.FreeGold = economy.FreeGold;

        var seen = new HashSet<uint>();
        foreach (var item in economy.StartingItems)
        {
            if (item.TemplateId == 0 || item.Count == 0)
                continue;
            
            if (!seen.Add(item.TemplateId))
                continue;
            root.InfoItem.PackItems.Add(PackItem(
                item.TemplateId,
                item.Count,
                StartingPackItemUniqueIdBase + item.TemplateId));
        }

        
        
        if (economy.GrantAllAmmo)
        {
            foreach (var bulletId in CombatCatalogRepository.AmmoTemplateIds)
            {
                if (bulletId == 0 || !seen.Add(bulletId))
                    continue;
                root.InfoItem.PackItems.Add(PackItem(
                    bulletId,
                    99999u,
                    StartingPackItemUniqueIdBase + bulletId));
            }
        }

        var extras = ExtraArmoryWeapons();
        if (extras.Count == 0)
            return;

        var existing = root.InfoSpirit.InfoArmory.Weapons
            .Select(weapon => weapon.InstanceId)
            .ToHashSet();
        foreach (var definition in extras)
        {
            if (!existing.Add(definition.InstanceId))
                continue;
            root.InfoSpirit.InfoArmory.Weapons.Add(WeaponData(definition));
            
            
            
            
            
            root.InfoSpirit.InfoFightStyle.FightStyleIsUnLocked[definition.Style.Id] = true;
            root.InfoSpirit.InfoFightStyle.FightStyleFirstUnlockTimes[definition.Style.Id] =
                Config.Gameplay.SpiritContent.FightStyleUnlockTime;
        }
    }

    private static IReadOnlyList<CombatWeaponDefinition> ExtraArmoryWeapons()
    {
        var economy = Config.Gameplay.Economy;
        if (economy.GrantAllArmoryWeapons)
            return CombatCatalogRepository.AccountWeapons;
        if (economy.ExtraWeaponTemplateIds.Length == 0)
            return [];

        var wanted = economy.ExtraWeaponTemplateIds.ToHashSet();
        return CombatCatalogRepository.AccountWeapons
            .Where(weapon => wanted.Contains(weapon.TemplateId))
            .ToList();
    }

    internal static Auto.EnterSceneInfo EnterScene(uint switchShowId)
    {
        var placement = ClientConfigRepository.EntryPlacement(switchShowId);
        return EnterScene(
            Config.World.RaidId,
            Config.World.SceneInstanceId,
            Config.World.UniverseId,
            Config.Player.InitialUnitId,
            Config.Player.InitialSpiritTemplateId,
            placement.Position,
            placement.Facing,
            switchShowId,
            isSwitchSpiritShow: true);
    }

    
    private static List<string> SpoonNames()
        => Config.Gameplay.Quests.SceneSpoonNames.Length > 0
            ? [.. Config.Gameplay.Quests.SceneSpoonNames]
            : [];

    
    private static List<string> SpoonMd5s()
    {
        var names = Config.Gameplay.Quests.SceneSpoonNames;
        if (names.Length == 0)
            return [];

        var md5s = Config.Gameplay.Quests.SceneSpoonMd5s;
        var list = new List<string>(names.Length);
        for (var i = 0; i < names.Length; i++)
            list.Add(i < md5s.Length ? md5s[i] : string.Empty);
        return list;
    }

    internal static Auto.EnterSceneInfo EnterScene(
        uint raidId,
        ulong instanceId,
        uint universeId,
        ulong unitId,
        uint templateId,
        Vec3 position,
        float facing,
        uint switchShowId = 0,
        bool isSwitchSpiritShow = false,
        uint sectorControlId = 0)
        => new()
        {
            PlayerSessionId = Profile.PlayerPid,
            RaidId = raidId,
            InstanceId = instanceId,
            Position = Vector(position),
            Facing = facing,
            
            
            
            
            SceneSpoonNames = SpoonNames(),
            SceneSpoonMd5s = SpoonMd5s(),
            Spirits =
            [
                new Auto.SpiritInitData
                {
                    Id = unitId,
                    TemplateId = templateId,
                    IsActive = true,
                    
                    
                    WeaponTemplateId = 0,
                    WeaponSkinId = 0,
                }
            ],
            GridInfo = new Auto.ServerSimpleGridInfo
            {
                MinX = 0,
                MinZ = 0,
                MaxX = 300000,
                MaxZ = 300000,
            },
            MatchGameId = 0,
            SwitchShowId = switchShowId,
            IsSwitchSpiritShow = isSwitchSpiritShow,
            UniverseId = universeId,
            SectorControlId = sectorControlId,
            LoadingType = new Auto.LoadingTypeInfo
            {
                Type = 0,
                Members = [],
                Ripple = false,
            },
            LinkSimpleInfo = new Auto.LinkSimpleInfo
            {
                Id = 0,
                Mode = 0,
                DeviceLevel = 1,
                Tag = 0,
                PublicEventId = 0,
                LastPublicEventTime = 0,
                HostPid = 0,
            },
            DataLayerIndices = [],
            Seamless = false,
            TombIslandIds = [],
        };

    internal static Auto.RaidBattleUnitSpirit ExistingUnitProjection(uint switchShowId)
    {
        var placement = ClientConfigRepository.EntryPlacement(switchShowId);
        return ExistingUnitProjection(
            Config.Player.InitialUnitId,
            Config.Player.InitialSpiritTemplateId,
            placement.Position,
            placement.Facing);
    }

    internal static Auto.RaidBattleUnitSpirit ExistingUnitProjection(
        ulong unitId,
        uint templateId,
        Vec3 position,
        float facing)
    {
        
        
        
        var projection = CharacterUnitProjection(
            unitId, templateId, position, facing, ClientConfigRepository.DefaultFashionIds(templateId));
        projection.ManagedPid = 0;
        return projection;
    }

    
    private const ulong AgentUnitIdBase = 700000000000UL;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static Auto.RaidBattleUnitSpirit NpcUnitProjection(
        ulong agentId,
        uint templateId,
        Vec3 position,
        float facing,
        IReadOnlyList<uint>? customFashionIds = null)
    {
        var fashionIds = customFashionIds is { Count: > 0 }
            ? customFashionIds
            : ClientConfigRepository.DefaultFashionIds(templateId);

        return new Auto.RaidBattleUnitSpirit
        {
            SpiritWearFashionsInfo = new Auto.OtherPlayerSpiritWearFashionsInfo
            {
                WearFashionColoringInfoDict = new Dictionary<uint, Auto.FashionColoringInfo>(),
                WearFashionInfoList = fashionIds
                    .Select(id => new Auto.WearFashionInfo { FashionId = id })
                    .ToList(),
                WearFashionEditInfoList = [],
                HiddenParts = 0,
                EditedHiddenParts = 0,
            },
            Begging = false,
            IsBot = true,
            Id = agentId,
            TemplateId = templateId,
            Position = Vector(position),
            FacingDirection = facing,
            OwnerId = 0,
            ManagedPid = 0,
            MoveId = 0,
            NavTags = 0,
            GroundData = new Auto.MoveActionGroundData
            {
                MoveGroundType = 0,
                MoveGroundId = 0,
                MetaInfo = 0,
                LocalPos = new Auto.UXVector3(),
            },
        };
    }

    internal static Auto.RaidBattleUnitSpirit CharacterUnitProjection(
        uint templateId,
        Vec3 position,
        float facing)
    {
        var character = ClientConfigRepository.Characters().FirstOrDefault(x => x.TemplateId == templateId);
        if (character is not null)
        {
            return CharacterUnitProjection(
                character.UnitId,
                character.TemplateId,
                position,
                facing,
                ClientConfigRepository.DefaultFashionIds(templateId));
        }

        
        
        
        
        
        if (AgentCatalogRepository.Find(templateId) is null)
            throw new InvalidOperationException(
                $"Template {templateId} is in neither FightSpiritConfig nor AgentCatalog.");

        return CharacterUnitProjection(
            AgentUnitIdBase + templateId % 1000000UL,
            templateId,
            position,
            facing,
            []);
    }

    internal static GameMethods.SyncSetSpiritFashions CharacterFashions(uint templateId)
    {
        var wear = WearFashionsForGameMethods(ClientConfigRepository.DefaultFashionIds(templateId));
        return new GameMethods.SyncSetSpiritFashions
        {
            spiritId = templateId,
            source = 0,
            spiritWearFashionsInfo = wear,
        };
    }

    internal static GameMethods.AskAllSpiritPanelDataResult MinimalAllSpiritPanelData4229938()
    {
        
        
        
        
        var attrs = CombatCodec.PanelAttrs();
        var urban = CombatCodec.UrbanAttrMap();
        return new()
        {
            spirits = ClientConfigRepository.Characters().Select(character => new Auto.SpiritPanelData
            {
                FightSpiritId = character.TemplateId,
                MaxHp = CombatCodec.MaxHp,
                Dam = CombatCodec.PanelDamage,
                DefDeduct = CombatCodec.PanelDefenseDeduct,
                Attrs = new Dictionary<uint, float>(attrs),
                NakedAttrs = new Dictionary<uint, float>(attrs),
                ConsumableAttrs = [],
                UrbanAttrs = new Dictionary<uint, float>(urban),
            }).ToList()
        };
    }

    private static Auto.RaidBattleUnitSpirit CharacterUnitProjection(
        ulong unitId,
        uint templateId,
        Vec3 position,
        float facing,
        IReadOnlyList<uint> fashionIds)
    {
        return new Auto.RaidBattleUnitSpirit
        {
            SpiritWearFashionsInfo = new Auto.OtherPlayerSpiritWearFashionsInfo
            {
                WearFashionColoringInfoDict = new Dictionary<uint, Auto.FashionColoringInfo>(),
                WearFashionInfoList = fashionIds.Select(id => new Auto.WearFashionInfo { FashionId = id }).ToList(),
                WearFashionEditInfoList = [],
                HiddenParts = 0,
                EditedHiddenParts = 0,
            },
            Begging = false,
            IsBot = false,
            Id = unitId,
            TemplateId = templateId,
            Position = Vector(position),
            FacingDirection = facing,
            OwnerId = Profile.PlayerPid,
            
            
            
            ManagedPid = Profile.PlayerPid,
            MoveId = 0,
            NavTags = 0,
            GroundData = new Auto.MoveActionGroundData
            {
                MoveGroundType = 0,
                MoveGroundId = 0,
                MetaInfo = 0,
                LocalPos = new Auto.UXVector3(),
            },
        };
    }

    private static Auto.SpiritInfo MinimalActorCharacterSpirit4229938(CharacterCatalogEntry character)
    {
        var loadout = CombatCatalogRepository.Loadout(character.TemplateId);
        var spirit = new Auto.SpiritInfo
        {
            Id = character.UnitId,
            TemplateId = character.TemplateId,
            PossessTime = 1,
            HpRate = 1f,
            EverSwitched = character.TemplateId != Config.Player.InitialSpiritTemplateId,
            Blocked = false,
            LastUsedWeaponInstanceId = loadout.DefaultWeapon.InstanceId,
            WeaponSlots = loadout.Slots
                .Select(weapon => weapon is null ? null! : WeaponData(weapon))
                .ToList(),
        };

        
        foreach (var (typeId, styleId) in loadout.StyleByType)
            spirit.SpiritFightStyle.FightStyleInfo[typeId] = styleId;

        
        
        
        
        ApplySpiritContent4229938(spirit, character.TemplateId);

        
        
        foreach (var badge in ExtraCatalog.Badges)
        {
            if (badge.FightspiritId != character.TemplateId)
                continue;
            spirit.InfoBadge.Badges[badge.Id] = new Auto.BadgeInfo
            {
                TemplateId = badge.Id,
                Active = true,
                DropSend = false,
            };
        }

        return spirit;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private static void ApplySpiritContent4229938(Auto.SpiritInfo spirit, uint spiritId)
    {
        var settings = Config.Gameplay.SpiritContent;
        if (!settings.Enabled)
            return;

        var row = SpiritContentCatalogRepository.Spirit(spiritId);

        
        if (settings.UnlockUniqueSkill)
            spirit.SpiritBattleInfo.IsUniqueSkillLocked = false;

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        if (settings.GrantUrbanAbilities && row is not null)
        {
            if (settings.MaxUrbanAttribute)
            {
                var count = SpiritContentCatalogRepository.UrbanAttributeCount;
                var max = SpiritContentCatalogRepository.UrbanAttributeMaxValue;
                for (var i = 0; i < count; i++)
                    spirit.SpiritUrbanSkill.UrbanAbilities.Add(max);
            }
            else if (row.UrbanAttribute.Length > 0)
            {
                spirit.SpiritUrbanSkill.UrbanAbilities.AddRange(row.UrbanAttribute);
            }
        }

        
        
        
        
        
        if (settings.GrantSpiritTalents && row is not null)
        {
            spirit.TalentInfo.Exp = 0;
            spirit.TalentInfo.Level = settings.SpiritTalentLevel;
            spirit.TalentInfo.TalentPoint = settings.SpiritTalentPoint;

            
            foreach (var talentGroup in SpiritContentCatalogRepository.SpiritTalents(spiritId))
            {
                foreach (var talentId in talentGroup.TalentIds)
                {
                    if (talentId == 0)
                        continue;
                    spirit.TalentInfo.UnlockTalentInfoDict[talentId] =
                        new Auto.SpiritOrJobTalentNodeInfo
                        {
                            TalentId = talentId,
                            Layer = settings.SpiritTalentLayer,
                        };
                }
            }

            
            
            if (settings.UnlockAllSpiritTalents)
            {
                foreach (var tree in SpiritContentCatalogRepository.TalentTreesFor(spiritId))
                {
                    if (tree.GameplayId != 0)
                        continue;   
                    UnlockWholeTree4229938(
                        tree.Id,
                        spirit.TalentInfo.UnlockTalentInfoDict,
                        spirit.TalentInfo.TalentTreeRecordDict,
                        settings.SpiritTalentLayer);
                }
            }
        }

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        if (!settings.GrantDefaultJobs || row is null)
            return;

        var jobIds = settings.GrantAvatarJobs
            ? SpiritContentCatalogRepository.EffectiveJobIds(row)
            : DefaultOnlyJobIds(row);
        foreach (var jobId in jobIds)
        {
            var job = BuildSpiritJob4229938(spiritId, jobId);
            if (job is not null)
                spirit.SpiritJobInfo.AvailableJobs[jobId] = job;
        }

        
        
        var jobless = BuildSpiritJob4229938(spiritId, UrbanJobConfigJobless) ?? new Auto.SpiritJob
        {
            Job = UrbanJobConfigJobless,
            RegisterTime = 1,
        };
        spirit.SpiritJobInfo.AvailableJobs[UrbanJobConfigJobless] = jobless;

        
        
        
        var defaultJobId = SpiritContentCatalogRepository.DefaultJobId(row);
        spirit.SpiritJobInfo.CurrentJob = defaultJobId != 0 ? defaultJobId : UrbanJobConfigJobless;

        
        
        
        
        
        
        if (settings.MaxJobLevel && settings.JobTopTier)
            PromoteToTopTier4229938(spirit, row);

        
        
        if (settings.UnlockPhoneAppJobs)
            GrantPhoneAppJobClasses4229938(spirit, row);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private static void GrantPhoneAppJobClasses4229938(
        Auto.SpiritInfo spirit, SpiritContentCatalogRepository.SpiritRow row)
    {
        
        
        
        var orphans = SpiritContentCatalogRepository.OrphanPhoneAppJobClasses;
        if (orphans.Count == 0)
            return;

        var cultivationId = row.NpcCultivationId;
        var granted = 0;

        foreach (var app in SpiritContentCatalogRepository.AllApps)
        {
            if (app.JobClassIds.Length == 0)
                continue;

            
            if (app.NpcCultivationIds.Length > 0
                && (cultivationId == 0 || !app.NpcCultivationIds.Contains(cultivationId)))
                continue;

            foreach (var jobClass in app.JobClassIds)
            {
                if (!orphans.Contains(jobClass))
                    continue;

                var top = SpiritContentCatalogRepository.TopJobLevelOf(jobClass);
                if (top == 0 || spirit.SpiritJobInfo.AvailableJobs.ContainsKey(top))
                    continue;

                var job = BuildSpiritJob4229938(row.Id, top);
                if (job is null)
                    continue;

                spirit.SpiritJobInfo.AvailableJobs[top] = job;
                granted++;
            }
        }

        if (granted > 0)
        {
            Console.WriteLine($"[SPIRITCONTENT][APPJOB] spirit={row.Id} {row.Name} "
                + $"补 {granted} 个「App 门控职业」最高档 → "
                + string.Join(",", spirit.SpiritJobInfo.AvailableJobs.Keys.OrderBy(x => x)));
        }
    }

    
    
    
    
    
    
    private static void PromoteToTopTier4229938(Auto.SpiritInfo spirit, SpiritContentCatalogRepository.SpiritRow row)
    {
        var defaultClass = SpiritContentCatalogRepository.DefaultJobClass(row);
        foreach (var jobId in spirit.SpiritJobInfo.AvailableJobs.Keys.ToArray())
        {
            if (jobId == UrbanJobConfigJobless)
                continue;
            var cls = SpiritContentCatalogRepository.JobLevel(jobId)?.JobClass ?? 0u;
            if (cls == 0)
                continue;
            var top = SpiritContentCatalogRepository.TopJobLevelOf(cls);
            if (top == 0 || top == jobId)
                continue;

            var topJob = BuildSpiritJob4229938(row.Id, top);
            if (topJob is null)
                continue;
            spirit.SpiritJobInfo.AvailableJobs.Remove(jobId);
            spirit.SpiritJobInfo.AvailableJobs[top] = topJob;
        }

        if (defaultClass != 0)
        {
            var top = SpiritContentCatalogRepository.TopJobLevelOf(defaultClass);
            if (top != 0 && spirit.SpiritJobInfo.AvailableJobs.ContainsKey(top))
                spirit.SpiritJobInfo.CurrentJob = top;
        }
    }

    
    internal const uint UrbanJobConfigJobless = 100u;

    
    
    
    
    
    
    internal static uint JobRegisterTime4229938(uint spiritId, uint jobId)
    {
        var now = (uint)DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        var state = SessionState.Current;
        if (state.SpiritJobRegisterTime.TryGetValue(spiritId, out var byJob)
            && byJob.TryGetValue(jobId, out var saved)
            && saved != 0)
            return saved;

        try
        {
            SessionState.Update(s =>
            {
                if (!s.SpiritJobRegisterTime.TryGetValue(spiritId, out var dict))
                    s.SpiritJobRegisterTime[spiritId] = dict = new Dictionary<uint, uint>();
                dict[jobId] = now;
            });
        }
        catch
        {
            
        }
        return now;
    }

    
    private static IReadOnlyList<uint> DefaultOnlyJobIds(SpiritContentCatalogRepository.SpiritRow row)
    {
        var id = SpiritContentCatalogRepository.DefaultJobId(row);
        return id == 0 ? [] : [id];
    }

    
    
    
    
    
    
    
    
    
    private static void UnlockWholeTree4229938(
        uint treeId,
        Dictionary<uint, Auto.SpiritOrJobTalentNodeInfo> nodes,
        Dictionary<uint, Auto.TalentTreeRecord> records,
        uint minLayer)
    {
        var record = new Auto.TalentTreeRecord();
        foreach (var node in SpiritContentCatalogRepository.TalentNodes(treeId))
        {
            if (node.Id == 0)
                continue;

            var layer = node.LayerNum > 0 ? (uint)node.LayerNum : 1u;
            if (layer < minLayer)
                layer = minLayer;

            nodes[node.Id] = new Auto.SpiritOrJobTalentNodeInfo { TalentId = node.Id, Layer = layer };
            record.ActivatedNodeCount++;
            record.SpentTalentPoint += node.CostPoint;
        }

        if (record.ActivatedNodeCount > 0)
            records[treeId] = record;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static Auto.SpiritJob? BuildSpiritJob4229938(uint spiritId, uint jobId)
    {
        var settings = Config.Gameplay.SpiritContent;
        var level = SpiritContentCatalogRepository.JobLevel(jobId);
        if (level is null)
            return null;

        var state = SessionState.Current;
        var jobClass = level.JobClass;

        
        var maxLevel = settings.MaxJobLevel
            ? SpiritContentCatalogRepository.MaxJobLevelOf(jobClass)
            : 0u;
        var shownLevel = maxLevel > 0
            ? maxLevel
            : (level.Level == 0 ? 1u : level.Level);

        var job = new Auto.SpiritJob
        {
            Job = jobId,
            Exp = settings.MaxJobLevel ? settings.JobMaxExp : 0,
            Level = (byte)Math.Clamp(shownLevel, 1, 255),
            
            
            
            
            
            RegisterTime = JobRegisterTime4229938(spiritId, jobId),
            UnregisterTime = 0,
        };

        
        if (state.SpiritJobTalents.TryGetValue(spiritId, out var saved))
        {
            foreach (var (talentId, layer) in saved)
                job.TalentInfo.UnlockTalentInfoDict[talentId] =
                    new Auto.SpiritOrJobTalentNodeInfo { TalentId = talentId, Layer = layer };
        }
        
        
        job.TalentInfo.TalentPoint = state.SpiritJobTalentPoints.TryGetValue(spiritId, out var savedPoints)
            ? Math.Max(savedPoints, settings.JobTalentPoint)
            : settings.JobTalentPoint;

        
        foreach (var tree in SpiritContentCatalogRepository.TalentTreesFor(spiritId))
        {
            if (jobClass == 0 || tree.JobClassId != jobClass)
                continue;

            if (settings.UnlockAllJobTalents)
            {
                UnlockWholeTree4229938(
                    tree.Id,
                    job.TalentInfo.UnlockTalentInfoDict,
                    job.TalentInfo.TalentTreeRecordDict,
                    1);
                continue;
            }

            var record = new Auto.TalentTreeRecord { SpentTalentPoint = 0, ActivatedNodeCount = 0 };
            foreach (var node in SpiritContentCatalogRepository.TalentNodes(tree.Id))
            {
                var layer = job.TalentInfo.UnlockTalentInfoDict.TryGetValue(node.Id, out var existing)
                    ? existing.Layer
                    : 0u;
                if (layer == 0 && node.IsOrigin)
                {
                    layer = 1;
                    job.TalentInfo.UnlockTalentInfoDict[node.Id] =
                        new Auto.SpiritOrJobTalentNodeInfo { TalentId = node.Id, Layer = 1 };
                }
                if (layer > 0)
                {
                    record.ActivatedNodeCount++;
                    record.SpentTalentPoint += node.CostPoint;
                }
            }
            job.TalentInfo.TalentTreeRecordDict[tree.Id] = record;
        }

        _ = settings;
        return job;
    }

    
    
    
    
    
    
    
    
    
    
    
    internal static Dictionary<uint, Auto.SpiritTalentInfo> GameplayTalentInfos4229938()
    {
        var settings = Config.Gameplay.SpiritContent;
        var result = new Dictionary<uint, Auto.SpiritTalentInfo>();
        if (!settings.Enabled || !settings.UnlockAllGameplayTalents)
            return result;

        foreach (var tree in SpiritContentCatalogRepository.AllTalentTrees)
        {
            if (tree.GameplayId == 0)
                continue;

            if (!result.TryGetValue(tree.GameplayId, out var info))
            {
                result[tree.GameplayId] = info = new Auto.SpiritTalentInfo
                {
                    Exp = 0,
                    Level = settings.SpiritTalentLevel,
                    TalentPoint = settings.SpiritTalentPoint,
                };
            }

            UnlockWholeTree4229938(
                tree.Id, info.UnlockTalentInfoDict, info.TalentTreeRecordDict, 1);
        }

        return result;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private static IEnumerable<(uint StyleId, uint UnlockTime)> CollectFightStyleUnlocks(
        SpiritContentSettings settings)
    {
        var time = settings.FightStyleUnlockTime;
        var ids = new SortedSet<uint>();

        foreach (var character in ClientConfigRepository.Characters())
            foreach (var styleId in CombatCatalogRepository.Loadout(character.TemplateId).StyleByType.Values)
                if (styleId != 0)
                    ids.Add(styleId);

        if (settings.Enabled && settings.UnlockExclusiveFightStyles)
            foreach (var character in ClientConfigRepository.Characters())
                foreach (var style in SpiritContentCatalogRepository.ExclusiveFightStyles(character.TemplateId))
                    ids.Add(style.Id);

        if (settings.Enabled && settings.UnlockAllFightStyles)
            foreach (var style in SpiritContentCatalogRepository.AllFightStyles)
                if (style.FightSkillType != 0)
                    ids.Add(style.Id);

        return ids.Select(id => (id, time));
    }

    
    
    
    
    
    
    
    
    
    
    
    private static List<uint> CollectInstalledApps(SpiritContentSettings settings)
    {
        var ids = new SortedSet<uint>(SessionState.Current.InstalledApps);

        if (!settings.Enabled)
            return [.. ids];

        if (settings.InstallAutoDownloadApps)
            foreach (var appId in SpiritContentCatalogRepository.AutoDownloadAppIds)
                ids.Add(appId);

        if (settings.InstallExclusiveApps)
            foreach (var character in ClientConfigRepository.Characters())
                foreach (var app in SpiritContentCatalogRepository.AppsForSpirit(character.TemplateId))
                    ids.Add(app.Id);

        return [.. ids];
    }

    internal const uint InitialAmmoReserve4229938 = 9999u;

    
    internal const ulong StartingPackItemUniqueIdBase = 920000000000UL;

    
    
    
    
    
    
    
    internal const ulong RuntimePackItemUniqueIdBase = 950000000000UL;

    
    internal static ulong BackpackItemUniqueId(uint templateId) => RuntimePackItemUniqueIdBase + templateId;

    
    
    
    
    internal static Auto.PlayerPackItem PackItem(uint templateId, uint count, ulong uniqueId)
        => new()
        {
            UniqueId = uniqueId,
            TemplateId = templateId,
            Count = count,
            IsNew = false,
            ExpiryTime = 0,
            RemindState = 0,
            Quality = 0,
            Tags = 0,
            IsBind = false,
            Components = null,
            CDFinishTime = 0,
        };

    
    
    
    
    
    internal static Auto.PlayerPackItem BackpackItem4229938(uint templateId, uint count)
        => new()
        {
            UniqueId = 920000000000UL + templateId,
            TemplateId = templateId,
            Count = count,
            IsNew = false,
            ExpiryTime = 0,
            RemindState = 0,
            Quality = 0,
            Tags = 0,
            IsBind = false,
            Components = null,
        };

    internal static Auto.PlayerPackItem AmmoPackItem(uint templateId, uint count = InitialAmmoReserve4229938)
        => new()
        {
            UniqueId = 910000000000UL + templateId,
            TemplateId = templateId,
            Count = count,
            IsNew = false,
            ExpiryTime = 0,
            RemindState = 0,
            Quality = 0,
            Tags = 0,
            IsBind = false,
            Components = null,
            CDFinishTime = 0,
        };

    internal static Auto.WeaponData WeaponData(CombatWeaponDefinition weapon)
        => new()
        {
            TemplateId = weapon.TemplateId,
            Durability = weapon.InitialClientDurability,
            InstanceId = weapon.InstanceId,
            EventId = 0,
            ReceivedTimeStamp = 0,
            OperatorFlags = 0,
            SpecialLabel = null,
            SceneItemHp = 1f,
            StackCount = 1,
            FightStyleId = weapon.Style.Id,
            MagazineAmmo = weapon.InitialMagazineAmmo,
            BulletDatas = new Auto.WeaponBulletDatas { BulletId = weapon.BulletId },
            BindPid = Profile.PlayerPid,
            IsPlayerLocked = false,
        };

    
    
    
    
    
    
    
    
    
    private static IReadOnlyList<uint> EffectiveUnlockedFashions4229938()
    {
        var settings = Config.Gameplay.Fashions;
        if (!settings.Enabled)
            return [];

        var all = FashionCatalogRepository.AllIds;
        if (settings.UnlockAllFashions && all.Count > 0)
            return all;

        return settings.UnlockedFashionIds;
    }

    
    
    
    
    
    private static Auto.PlayerFashionsInfo MinimalPlayerFashions4229938(IReadOnlyList<uint> extraFashionIds)
    {
        var result = new Auto.PlayerFashionsInfo
        {
            DefaultSpiritIsInitDefaultFashion = true,
            ColoringCollectionScore = 0,
        };

        var extra = new HashSet<uint>(extraFashionIds ?? []);
        foreach (var character in ClientConfigRepository.Characters())
        {
            var defaultIds = ClientConfigRepository.DefaultFashionIds(character.TemplateId)
                .Concat(extra)
                .Distinct()
                .ToList();
            foreach (var fashionId in defaultIds)
            {
                if (!result.FashionInfoDict.ContainsKey(fashionId))
                {
                    result.FashionInfoDict[fashionId] = new Auto.FashionInfo
                    {
                        FashionId = fashionId,
                        ExpiredTime = 0,
                        GainTime = 1,
                        Status = 0,
                        ApplyColoringSchemeId = 0,
                        UnlockColoringSlotCount = 0,
                        ColoringSchemeTopNMaxCollectionScore = 0,
                    };
                }
            }

            result.SpiritFashionsInfoDict[character.TemplateId] = new Auto.SpiritFashionsInfo
            {
                SpiritId = character.TemplateId,
                SpiritWearFashionsInfo = WearFashions(defaultIds),
                SpiritPrevWearFashionsInfo = null,
                FirstGainSuitIdList = [],
                ActiveClientTryWearSource = 0,
                UnlockSuitSlotCount = 0,
            };
        }
        return result;
    }

    private static Auto.SpiritWearFashionsInfo WearFashions(IReadOnlyList<uint> ids)
        => new()
        {
            FunctionSuitId = 0,
            WearSourceInfo = new Auto.WearSourceInfo { Source = 0, SourceId = 0 },
            IsTryWear = false,
            WearFashionInfoList = ids.Select(id => new Auto.WearFashionInfo { FashionId = id }).ToList(),
            WearFashionEditInfoList = [],
            HiddenParts = 0,
            EditedHiddenParts = 0,
        };

    private static GameMethods.SpiritWearFashionsInfo WearFashionsForGameMethods(IReadOnlyList<uint> ids)
        => new()
        {
            FunctionSuitId = 0,
            WearSourceInfo = new GameMethods.WearSourceInfo { Source = 0, SourceId = 0 },
            IsTryWear = false,
            WearFashionInfoList = ids.Select(id => new GameMethods.WearFashionInfo { FashionId = id }).ToList(),
            WearFashionEditInfoList = [],
            HiddenParts = 0,
            EditedHiddenParts = 0,
        };

    private static Auto.UXVector3 Vector(Vec3 value)
        => new() { X = value.X, Y = value.Y, Z = value.Z };
}
