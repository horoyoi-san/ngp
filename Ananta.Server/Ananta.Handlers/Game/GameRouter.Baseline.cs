using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using Ananta.Server.State;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    
    
    
    
    
    
    
    
    
    
    
    
    
    internal static readonly (string Key, string Label)[] BaselineSteps =
    [
        ("hp",          "玩家单位血量（防昏迷/相机失效）"),
        ("systems",     "系统解锁（拍照等 195 项）"),
        ("actions",     "交互动作解锁（54 个）"),
        ("map",         "地图：传送点 + 迷雾 + 地铁票价"),
        ("factions",    "阵营（地图 tooltip 必需）"),
        ("metro",       "地铁运行线路"),
        ("achievements","成就"),
        ("pedia",       "都市百科"),
        ("handbook",    "手账 / 图鉴（手机资料 + 徽章）"),
        ("phone",       "手机个性化（壁纸/装饰/挂件）"),
        ("spiritcontent","角色专属内容（职业 / 天赋）"),
        ("phoneapp",    "手机 App 内部内容（黑客论坛 / 伪人档案）"),
        ("jobability",  "职业对应能力（骇入目标标记）"),
        ("socialapp",   "社交 App（叭卜动态 + 角色日常行程/邀约）"),
        ("combatpower", "战力"),
        ("tasks",       "任务列表（注释说明已移到进世界流程）"),
        ("fashions",    "恢复已保存的穿戴"),
    ];

    
    internal static async Task<string?> PushBaselineStepAsync(TcpSession session, string key)
    {
        if (!BaselineSteps.Any(x => string.Equals(x.Key, key, StringComparison.OrdinalIgnoreCase)))
            return $"未知的 baseline 项: {key}（可选: {string.Join(", ", BaselineSteps.Select(x => x.Key))}）";

        await PushContentBaselineAsync(session, key);
        return null;
    }

    internal static async Task PushContentBaselineAsync(TcpSession session, string? onlyStep = null)
    {
        
        bool Want(string key) => onlyStep is null
            || string.Equals(onlyStep, key, StringComparison.OrdinalIgnoreCase);

        if (onlyStep is not null)
            session.Log.Info($"[BASELINE] 单项重发 step={onlyStep}");

        
        ResetGrantState();

        var state = SessionState.Current;

        if (Want("hp"))
        {
        
        
        
        
        
        
        
        
        
        if (session.Items.TryGetValue(GameRouter.WorldStateKey, out var rawWorld)
            && rawWorld is Protocol.Client4229938.WorldEntryState world
            && world.ActiveSpiritUnitId != 0)
        {
            var maxHp = Protocol.Client4229938.CombatCodec.MaxHp;
            await Notify(session, MethodId.SyncUnitHp,
                Protocol.Client4229938.CombatCodec.UnitHp(world.ActiveSpiritUnitId, maxHp));
            session.Log.Info(
                $"[HP] 下发玩家单位血量 unit={world.ActiveSpiritUnitId} hp={maxHp}"
                + "（缺这一条客户端会判定昏迷，血条显示「昏迷 100%」且相机被禁用）");
        }
        }

        
        
        
        
        
        
        
        
        
        
        

        if (Want("systems"))
        {
        
        
        
        
        
        var systemCfg = PrivateServerConfigStore.Current.Gameplay.Systems;
        if (systemCfg.Enabled)
        {
            var sysIds = systemCfg.UnlockAll
                ? SystemUnlockCatalogRepository.AllIds()
                : systemCfg.UnlockIds;
            if (sysIds.Length > 0)
            {
                await Notify(session, MethodId.SyncUnlockSystems, new GameMethods.SyncUnlockSystems4229938
                {
                    unlockSystems = [.. sysIds],
                });
                session.Log.Info($"[SYSTEMS] 解锁系统 {sysIds.Length} 个（含拍照 id=120，unlockAll={systemCfg.UnlockAll}）");
            }
        }
        }

        if (Want("actions"))
        {
        
        
        
        
        
        
        var actionCfg = PrivateServerConfigStore.Current.Gameplay.Actions;
        if (actionCfg.Enabled)
        {
            var ids = actionCfg.UnlockAll
                ? ActionItemCatalogRepository.AllIds()
                : actionCfg.UnlockIds;
            if (ids.Length > 0)
            {
                var payload = new GameMethods.SyncUnlockInteractionActionItems4229938();
                foreach (var id in ids)
                    payload.newActionItems.Add(new GameMethods.PlayerInteractionActionItem4229938
                    {
                        CfgId = id,
                        UnlockTime = 0,
                        ShowRedPoint = false,
                    });
                await Notify(session, MethodId.SyncUnlockInteractionActionItems, payload);
                session.Log.Info($"[ACTIONS] 解锁交互动作 {ids.Length} 个（unlockAll={actionCfg.UnlockAll}）");
            }
        }
        }

        if (Want("map"))
        {
        
        var entrances = ExtraCatalog.MapEntrances;
        if (entrances.Count > 0)
        {
            var ids = entrances.Select(e => e.Id).Distinct().ToList();
            await Notify(session, MethodId.SyncMapEntrance, new GameMethods.SyncMapEntrance4229938
            {
                openEntrance = ids,
                displayableEntrances = ids,
            });
            
            foreach (var id in ids)
                await Notify(session, MethodId.UpdateMapEntrance, new GameMethods.UpdateMapEntrance4229938
                {
                    mapEntranceId = id,
                    isOpen = true,
                    isShow = true,
                });

            
            
            
            
            
            
            
            foreach (var id in ids)
                await Notify(session, MethodId.SyncPrepareMapEntrance, new GameMethods.SyncPrepareMapEntrance4229938
                {
                    entrance = id,
                });

            var byRaid = entrances.GroupBy(e => e.RaidId).ToDictionary(g => g.Key, g => g.Count());
            
            
            var metro = entrances.Where(e => e.Type == 11).ToList();
            session.Log.Info($"[MAP] 下发传送点 {ids.Count} 个（SyncMapEntrance + UpdateMapEntrance）分布={string.Join(",", byRaid.Select(kv => kv.Key + ":" + kv.Value))} 其中地铁站 {metro.Count} 个");
            if (metro.Count > 0)
                session.Log.Info($"[MAP] 地铁站入口 id=[{string.Join(",", metro.Select(e => e.Id))}] raid={string.Join(",", metro.Select(e => e.RaidId).Distinct())}");

            
            
            
            
            
            await Notify(session, MethodId.SyncSubwayFare, new GameMethods.SyncSubwayFare4229938
            {
                fare = (uint)Math.Max(0, PrivateServerConfigStore.Current.Gameplay.Transit.SubwayFare),
            });
            session.Log.Info($"[MAP] 下发地铁票价 {PrivateServerConfigStore.Current.Gameplay.Transit.SubwayFare}");
        }
        }

        if (state.MapFullyRevealed)
            await PushFogUnlockAsync(session, unlock: true);

        if (Want("factions"))
        {
        
        var factions = ExtraCatalog.Factions;
        if (factions.Count > 0)
        {
            var body = new GameMethods.SyncFactionInfosChange4229938 { dropTextId = 0 };
            foreach (var id in factions)
                body.changeInfos.Add(new GameMethods.FactionChangeInfo4229938
                {
                    FactionId = id,
                    
                    
                    NewInfo = new GameMethods.FactionInfo4229938 { Disposition = 0, IsUnlock = true },
                    OldInfo = new GameMethods.FactionInfo4229938 { Disposition = 0, IsUnlock = true },
                });
            await Notify(session, MethodId.SyncFactionInfosChange, body);
            session.Log.Info($"[FACTION] 下发阵营 {factions.Count} 个");
        }
        }

        if (Want("metro"))
        {
        
        
        
        
        
        
        
        
        
        var routes = ExtraCatalog.MapRoutes;
        if (routes.Count > 0)
        {
            var metro = new GameMethods.SyncRunningMetroInfos4229938();
            for (var i = 0; i < routes.Count; i++)
            {
                metro.metroInfos.Add(new GameMethods.MetroInfo4229938
                {
                    Id = (int)routes[i].Id,
                    LineId = routes[i].Id,
                    
                    ElapsedTime = (i % 4) * 12f,
                    IsFinalTrain = false,
                });
            }
            await Notify(session, MethodId.SyncRunningMetroInfos, metro);
            session.Log.Info($"[METRO] 下发运行线路 {metro.metroInfos.Count} 条（MapentranceRouteConfig）ids=[{string.Join(",", routes.Select(r => r.Id))}] 名称=[{string.Join(",", routes.Select(r => r.Name))}]");
        }
        }

        if (Want("achievements"))
        {
        
        await PushAchievementsAsync(session);
        }

        if (Want("pedia"))
        {
        
        await PushCityPediaAsync(session);
        }

        if (Want("handbook"))
        {
        
        await PushSpiritHandbookAsync(session);
        }

        if (Want("phone"))
        {
        
        await PushMobileSkinAsync(session);
        }

        if (Want("spiritcontent"))
        {
        
        
        
        
        
        
        await PushAllSpiritJobsAsync(session);
        }

        if (Want("phoneapp"))
        {
        
        
        
        
        
        
        
        
        await PushAllPhoneAppContentAsync(session);
        }

        if (Want("jobability"))
        {
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        await GrantHackingAbilityBuffAsync(session);
        await PushHackerBatteryAsync(session);
        await PushHackableUnitsAsync(session);
        }

        if (Want("socialapp"))
        {
        
        
        
        
        
        
        
        
        
        
        
        await PushFavorNpcTimeTableAsync(session);
        }

        
        
        

        if (Want("combatpower"))
        {
        
        await PushCombatPowerAsync(session);
        }

        if (Want("tasks"))
        {
        
        }
        
        
        
        
        

        if (Want("fashions"))
        {
        
        await PushSavedFashionsAsync(session);
        }
    }

    

    
    
    
    
    
    
    internal static async Task PushFogUnlockAsync(TcpSession session, bool unlock)
    {
        var scenes = new SortedSet<uint>(ExtraCatalog.SceneIds);
        if (Profile.SceneInstanceId != 0)
            scenes.Add((uint)Profile.SceneInstanceId);

        foreach (var sceneId in scenes)
            await Notify(session, MethodId.SyncSceneFogMapAllUnlock, new GameMethods.SyncSceneFogMapAllUnlock4229938
            {
                sceneId = sceneId,
                unlock = unlock,
            });

        session.Log.Info($"[MAP] 迷雾全开 scene 数={scenes.Count}（覆盖全部区域）unlock={unlock}");
    }

    

    internal static async Task PushAchievementsAsync(TcpSession session)
    {
        var ids = ExtraCatalog.Achievements;
        if (ids.Count == 0)
            return;

        var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds() / 1000.0;
        var sent = 0;
        foreach (var id in ids)
        {
            await Notify(session, MethodId.SyncNewAchievement, new GameMethods.SyncNewAchievement4229938
            {
                id = id,
                detail = new GameMethods.AchievementDetail4229938 { AchieveTime = now, Status = 1 },
            });
            sent++;
            
            if (sent % 200 == 0)
                await Task.Yield();
        }
        session.Log.Info($"[ACHIEVEMENT] 下发成就 {sent} 个");
    }

    

    internal static async Task PushCityPediaAsync(TcpSession session)
    {
        var ids = ExtraCatalog.CityPedia;
        if (ids.Count == 0)
            return;

        foreach (var id in ids)
            await Notify(session, MethodId.SyncNewCityPediaInfo,
                new GameMethods.SyncNewCityPediaInfo4229938 { cityPediaId = id });

        session.Log.Info($"[PEDIA] 下发都市百科 {ids.Count} 条");
    }

    

    
    
    
    
    
    
    
    
    
    
    
    internal static async Task PushSpiritHandbookAsync(TcpSession session)
    {
        
        var summonContacts = new (string Remark, string Number)[]
        {
            (string.Empty, "142857"),
            (string.Empty, "206337"),
        };

        var all = GameCatalog.Characters;
        var badgesBySpirit = ExtraCatalog.Badges
            .Where(b => b.FightspiritId != 0)
            .GroupBy(b => b.FightspiritId)
            .ToDictionary(g => g.Key, g => g.Select(x => x.Id).ToList());

        foreach (var character in all)
        {
            await Notify(session, MethodId.AddSpiritPhoneInfos, new GameMethods.AddSpiritPhoneInfos4229938
            {
                spiritId = character.TemplateId,
                phoneInfos = new GameMethods.SpiritPhoneInfos4229938
                {
                    ContactList = summonContacts.Select(c => new GameMethods.SpiritContact4229938
                    {
                        Remark = c.Remark,
                        PhoneNumber = c.Number,
                    }).ToList(),
                    ContactGroupList = [],
                    CallRecordList = [],
                    ContactOutgoingCallTimesDict = new(),
                },
            });

            if (!badgesBySpirit.TryGetValue(character.TemplateId, out var badgeIds))
                continue;

            foreach (var badgeId in badgeIds)
                await Notify(session, MethodId.SyncSpiritBadgeInfo, new GameMethods.SyncSpiritBadgeInfo4229938
                {
                    spiritId = character.TemplateId,
                    badgeId = badgeId,
                    badgeInfo = new GameMethods.SpiritBadgeInfo4229938
                    {
                        TemplateId = badgeId,
                        Active = true,
                        DropSend = false,
                    },
                });
        }

        session.Log.Info($"[HANDBOOK] 下发手账资料 {all.Count} 个角色，联系人 {summonContacts.Length} 个，徽章角色 {badgesBySpirit.Count} 个");
    }

    

    internal static async Task PushMobileSkinAsync(TcpSession session)
    {
        var state = SessionState.Current;
        var parts = state.MobileSkinParts;
        var skin = new GameMethods.MobileSkinInfo4229938
        {
            Wallpaper = parts.Length > 0 ? parts[0] : 0,
            Decoration = parts.Length > 1 ? parts[1] : 0,
            Pendant = parts.Length > 2 ? parts[2] : 0,
        };

        
        
        
        var phoneCfg = PrivateServerConfigStore.Current.Gameplay.Phone;
        var available = phoneCfg.Enabled && phoneCfg.UnlockAllSkinParts
            ? MobileSkinPartCatalogRepository.AllIds().ToList()
            : [.. parts];

        foreach (var character in GameCatalog.Characters)
        {
            await Notify(session, MethodId.SyncSpiritMobileSkinPartInfo,
                new GameMethods.SyncSpiritMobileSkinPartInfo4229938
                {
                    spiritId = character.TemplateId,
                    mobileSkinInfo = skin,
                    availableSkinParts = available,
                });
        }
        session.Log.Info(
            $"[PHONE] 下发手机皮肤 角色={GameCatalog.Characters.Count} 当前部件={string.Join('/', parts)} "
            + $"可用部件={available.Count}（含壁纸 {MobileSkinPartCatalogRepository.WallpaperIds().Length} 个）");
    }

    

    
    
    
    
    internal static IReadOnlyList<uint> FullFashionIds()
    {
        var ids = new SortedSet<uint>();
        foreach (var character in GameCatalog.Characters)
            foreach (var id in ClientConfigRepository.DefaultFashionIds(character.TemplateId))
                ids.Add(id);
        foreach (var id in SessionState.Current.OwnedFashions)
            ids.Add(id);
        return ids.ToArray();
    }

    internal static async Task PushFashionDictAsync(TcpSession session)
    {
        var ids = FullFashionIds();
        var body = new GameMethods.SyncFashionInfoDict4229938();
        foreach (var id in ids)
            body.fashionInfoDict[id] = FashionInfoWire(id);

        await Notify(session, MethodId.SyncFashionInfoDict, body);
        session.Log.Info($"[FASHION] 下发衣橱全量 {body.fashionInfoDict.Count} 件");
    }

    
    internal static async Task PushBackpackAsync(TcpSession session)
    {
        var state = SessionState.Current;
        var body = new GameMethods.SyncBackpackItemChanged4229938();
        foreach (var (templateId, count) in state.Backpack)
        {
            if (count == 0)
                continue;
            body.updateItemList.Add(RuntimePayloadFactory.PackItem(
                templateId, count, RuntimePayloadFactory.BackpackItemUniqueId(templateId)));
        }

        await Notify(session, MethodId.SyncBackpackItemChanged, body);
        session.Log.Info($"[ITEM] 下发背包全量 {body.updateItemList.Count} 种（来自存档）");
    }

    private static Auto.FashionInfo FashionInfoWire(uint id) => new()
    {
        FashionId = id,
        ExpiredTime = 0,
        GainTime = 1,
        Status = 0,
        ApplyColoringSchemeId = 0,
        ColoringSchemeInfoDict = new Dictionary<byte, Auto.FashionColoringInfo>(),
        UnlockColoringSlotCount = 0,
        ColoringSchemeTopNMaxCollectionScore = 0,
        OwnedCount = 1,
    };

    

    internal static async Task PushCombatPowerAsync(TcpSession session)
    {
        var config = Ananta.Server.Configuration.PrivateServerConfigStore.Current.Gameplay.Combat;
        foreach (var character in GameCatalog.Characters)
        {
            await Notify(session, MethodId.IGameToClient_SyncSpiritCombatPowerChanged,
                new GameMethods.SyncSpiritCombatPowerChanged4229938
                {
                    spiritId = character.TemplateId,
                    combatPower = (float)config.Attack + (float)config.Defense + (float)config.MaxHp,
                });
        }
        session.Log.Info($"[POWER] 下发战力 {GameCatalog.Characters.Count} 个角色");
    }

    

    
    internal static async Task PushShopAsync(TcpSession session, uint shopId)
    {
        var body = new GameMethods.SyncCommodityInfos4229938 { shopId = shopId };

        
        foreach (var item in GameCatalog.Items.Where(i => i.Price > 0).Take(24))
        {
            body.infos.Add(new GameMethods.ShopCommodityRow4229938
            {
                TemplateId = item.TemplateId,
                Count = 1,
                RefreshTime = 0,
                Status = 0,
                Discount = 0,
                DiscountPrice = 0,
                MaxBuyCount = 999,
            });
        }

        await Notify(session, MethodId.SyncCommodityInfo, body);
        await Notify(session, MethodId.IGameToClient_SyncShopRefreshState, new GameMethods.SyncShopRefreshState4229938
        {
            shopId = shopId,
            refreshState = new GameMethods.ShopRefreshStateRow4229938(),
        });
        session.Log.Info($"[SHOP] 下发货架 shop={shopId} 商品={body.infos.Count}");
    }

    

    internal static async Task PushHouseAsync(TcpSession session, uint houseId)
    {
        await Notify(session, MethodId.SyncAddHouse, new GameMethods.SyncAddHouse4229938
        {
            houseInfo = new GameMethods.HouseInfo4229938
            {
                HouseId = houseId,
                ParkingSpaceVehicleIdDict = new Dictionary<int, uint>(),
                FloorBuildInfoDict = new Dictionary<uint, GameMethods.HouseFloorBuildInfo4229938>(),
                CurPlacedFurnitureInstanceId = 0,
                
                
                WallInfo = new GameMethods.HouseWallInfo4229938(),
                Configuration = new GameMethods.HouseConfiguration4229938(),
                FashionShowcaseDict = new Dictionary<ulong, GameMethods.HouseFashionShowcase4229938>(),
                PlacementStatistics = new GameMethods.HousePlacementStatistics4229938(),
            },
        });
        session.Log.Info($"[HOUSE] 下发房产 {houseId}");
    }

    private static Task Notify<T>(TcpSession session, uint methodId, T body)
        => session.NotifyAsync(methodId, UxSerializer.Serialize(body), CancellationToken.None);

    
    
    
    
    
    
    internal static GameMethods.MetroInfo4229938 BuildMetroInfo(uint lineId, int index) => new()
    {
        Id = (int)lineId,
        LineId = lineId,
        
        ElapsedTime = (index % 4) * 12f,
        IsFinalTrain = false,
    };
}
