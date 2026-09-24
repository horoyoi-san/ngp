using System.Globalization;
using System.Text.Json;
using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.State;
using Ananta.Server.Handlers.Game;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.App;

internal sealed partial class DebugApiServer
{
    
    private static readonly ContentState State = new();

    private sealed class ContentState
    {
        internal readonly object Sync = new();
        internal double Money;
        internal double Gold;
        internal double BindingGold;
        internal long WeaponInstanceSeq = 900000000000L;
        internal ulong ItemUniqueSeq = 950000000000UL;
        internal readonly Dictionary<uint, uint> Backpack = new();       
        internal readonly Dictionary<uint, ulong> ItemUniqueIds = new();  
        internal readonly List<WeaponEntry> Weapons = [];
        internal readonly HashSet<uint> Fashions = [];
        internal uint CurrentTaskId;
    }

    internal sealed record WeaponEntry(ulong InstanceId, uint TemplateId, uint SpiritId);

    private static bool _hydrated;

    
    private static void Hydrate()
    {
        if (_hydrated) return;
        _hydrated = true;
        try
        {
            var saved = SessionState.Current;
            lock (State.Sync)
            {
                State.Money = saved.Money;
                State.Gold = saved.Gold;
                State.BindingGold = saved.BindingGold;
                State.Backpack.Clear();
                foreach (var kv in saved.Backpack) State.Backpack[kv.Key] = kv.Value;
                State.Weapons.Clear();
                foreach (var w in saved.Weapons)
                    State.Weapons.Add(new WeaponEntry(w.InstanceId, w.TemplateId, w.SpiritId));
                State.Fashions.Clear();
                foreach (var f in saved.OwnedFashions) State.Fashions.Add(f);
                State.CurrentTaskId = saved.CurrentTaskId;
                if (State.Weapons.Count > 0)
                    State.WeaponInstanceSeq = Math.Max(State.WeaponInstanceSeq, (long)State.Weapons.Max(w => w.InstanceId));
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[STATE] 读取存档失败: {ex.Message}");
        }
    }

    
    private static void Persist()
    {
        try
        {
            SessionState.Update(saved =>
            {
                lock (State.Sync)
                {
                    saved.Money = State.Money;
                    saved.Gold = State.Gold;
                    saved.BindingGold = State.BindingGold;
                    saved.Backpack = new Dictionary<uint, uint>(State.Backpack);
                    saved.Weapons = State.Weapons
                        .Select(w => new WeaponRecord { InstanceId = w.InstanceId, TemplateId = w.TemplateId, SpiritId = w.SpiritId })
                        .ToList();
                    saved.OwnedFashions = State.Fashions.ToList();
                    saved.CurrentTaskId = State.CurrentTaskId;
                }
            });
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[STATE] 写入存档失败: {ex.Message}");
        }
    }

    

    private object Dict(string kind)
    {
        if (!GameCatalog.Available)
            return new { ok = false, error = GameCatalog.Error ?? "字典未加载" };

        return kind switch
        {
            "characters" => GameCatalog.Characters.Select(c => new
            {
                id = c.TemplateId, unitId = c.UnitId, zh = c.Zh, en = c.En, icon = c.IconId,
            }),
            
            
            "weapons" => CombatCatalogRepository.ArmoryWeapons.Select(w => new
            {
                id = w.TemplateId,
                zh = GameCatalog.WeaponLabel(w.TemplateId, w.LegacyWeaponId, w.Name),
                en = w.Name,
                legacy = w.LegacyWeaponId,
                belong = w.OwnerSpiritId,
                isGun = w.IsShootWeapon,
            }),
            "fashions" => GameCatalog.Fashions.Select(f => new
            {
                id = f.FashionId, zh = f.Zh, en = f.En, spirit = f.SpiritId, part = f.Part,
                quality = f.Quality, isDefault = f.IsDefault,
            }),
            "vehicles" => GameCatalog.Vehicles.Select(v => new
            {
                id = v.ConfigId, zh = v.Zh, en = v.En,
                brand = GameCatalog.Label(v.BrandZh, v.Brand), type = v.VehicleType, seats = v.Seats,
            }),
            "vehicleTypes" => GameCatalog.VehicleTypes.Select(t => new { id = t.Id, zh = t.Zh, en = t.En }),
            "items" => GameCatalog.Items.Select(i => new
            {
                id = i.TemplateId, zh = i.Zh, en = i.En, subType = i.SubType, quality = i.Quality, price = i.Price,
            }),
            "tasks" => GameCatalog.Tasks.Select(t => new { id = t.TaskId, zh = t.Zh, en = t.En, raid = t.Raid, chapter = t.Chapter }),
            
            
            "events" => TaskEventCatalogRepository.Search(null, 2000)
                .Select(e => new
                {
                    id = e.Id, zh = e.NameCn, en = e.Name,
                    startTask = e.StartTask, endTasks = e.EndTasks,
                    chapter = e.Chapter, sort = e.SortOrder, tag = e.Tag,
                }),
            
            
            
            
            
            "apps" => SpiritContentCatalogRepository.AllApps.Select(a => new
            {
                id = a.Id, name = a.Name, inStore = a.IsInAppStore, show = a.IsShow,
                systems = a.SystemIds, npcCult = a.NpcCultivationIds, jobClass = a.JobClassIds,
                relatedTasks = a.RelatedTaskIds, exclusive = a.IsExclusive,
            }),
            
            "characteristics" => SpiritContentCatalogRepository.AllCharacteristics.Select(c => new
            {
                id = c.Id, spirits = c.SpiritIds, name = c.Name, desc = c.Description,
                quality = c.Quality, notes = c.Notes,
            }),
            
            
            "jobs" => SpiritContentCatalogRepository.AllJobLevels.Select(j => new
            {
                id = j.Id, name = j.Name, jobClass = j.JobClass,
                className = SpiritContentCatalogRepository.JobClass(j.JobClass)?.ClassName,
                level = j.Level, preJob = j.PreJob, cost = j.Cost,
                systemUnlock = SpiritContentCatalogRepository.JobClass(j.JobClass)?.SystemUnlock,
            }),
            
            "talenttrees" => SpiritContentCatalogRepository.AllTalentTrees.Select(t => new
            {
                id = t.Id, name = t.Name, tab = t.TabIndex, spirits = t.SpiritIds,
                jobClass = t.JobClassId,
                jobClassName = SpiritContentCatalogRepository.JobClass(t.JobClassId)?.ClassName,
                systems = t.SystemIds, nodes = SpiritContentCatalogRepository.TalentNodes(t.Id).Count,
            }),
            
            "spirittalents" => SpiritContentCatalogRepository.AllSpirits
                .SelectMany(s => SpiritContentCatalogRepository.SpiritTalents(s.Id)
                    .SelectMany(g => g.TalentIds)
                    .Select(id => new
                    {
                        spiritId = s.Id,
                        spirit = s.Name,
                        talentId = id,
                        title = SpiritContentCatalogRepository.SpiritTalentEffect(id)?.Title,
                        buffs = SpiritContentCatalogRepository.SpiritTalentEffect(id)?.BuffIds,
                        describe = SpiritContentCatalogRepository.SpiritTalentEffect(id)?.BuffDescribe,
                        unlockWorldLevel = SpiritContentCatalogRepository.SpiritTalentUnlock(id)?.UnlockWorldLevel,
                    })),
            "chapters" => GameCatalog.Chapters.Select(c => new { id = c.Id, zh = c.Zh, en = c.En }),
            "mall" => GameCatalog.Mall.Select(m => new
            {
                id = m.CommodityId, zh = m.Zh, en = m.En, mallId = m.MallId, bindId = m.BindId,
                currency = m.ConsumeItemId, price = m.Price,
            }),
            _ => (object)new
            {
                ok = true,
                build = 4229938,
                counts = GameCatalog.Counts,
                note = GameCatalog.Note,
                extra = new
                {
                    radioSongs = ExtraCatalog.RadioSongs.Count,
                    mapEntrances = ExtraCatalog.MapEntrances.Count,
                    metroLines = ExtraCatalog.MetroLines.Count,
                    railLines = ExtraCatalog.RailLines.Count,
                    achievements = ExtraCatalog.Achievements.Count,
                    cityPedia = ExtraCatalog.CityPedia.Count,
                    cityPediaRows = ExtraCatalog.CityPediaRows.Count,
                    factions = ExtraCatalog.Factions.Count,
                    scenes = ExtraCatalog.SceneIds.Count,
                    raids = ExtraCatalog.Raids.Count,
                    regions = ExtraCatalog.Raids.Select(r => r.CountryId).Distinct().Count(),
                    agentProfiles = ExtraCatalog.AgentProfiles.Count,
                    profileTargets = ExtraCatalog.NpcProfileTargets.Count,
                    badges = ExtraCatalog.Badges.Count,
                    
                    spiritContent = SpiritContentCatalogRepository.Summary(),
                },
            },
        };
    }

    

    private async Task<object> ItemAddAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint templateId;
        uint count;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (!root.TryGetProperty("templateId", out var pt) || (templateId = pt.GetUInt32()) == 0)
                return new { ok = false, error = "缺少 templateId" };
            count = root.TryGetProperty("count", out var pc) ? pc.GetUInt32() : 1u;
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        
        var message = await GameRouter.GrantItemAsync(session, templateId, count, token);
        session.Log.Info($"[DEBUG-API] 物品添加 template={templateId} +{count}: {message}");
        return new { ok = true, templateId, message, backpack = BackpackList() };
    }

    private async Task<object> ItemRemoveAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint templateId;
        uint count;
        var all = false;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (!root.TryGetProperty("templateId", out var pt) || (templateId = pt.GetUInt32()) == 0)
                return new { ok = false, error = "缺少 templateId" };
            all = root.TryGetProperty("all", out var pa) && pa.ValueKind == JsonValueKind.True;
            count = !root.TryGetProperty("count", out var pc) ? 0u : pc.GetUInt32();
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        
        var message = await GameRouter.RemoveItemAsync(session, templateId, count, all, token);
        session.Log.Info($"[DEBUG-API] 物品移除 template={templateId}: {message}");
        return new { ok = true, templateId, message, backpack = BackpackList() };
    }

    
    private static object BackpackList()
        => SessionState.Current.Backpack
            .Where(kv => kv.Value > 0)
            .OrderBy(kv => kv.Key)
            .Select(kv => new { templateId = kv.Key, count = kv.Value })
            .ToList();

    private static Auto.PlayerPackItem PackItem(uint templateId, ulong uniqueId, uint count)
        => new()
        {
            UniqueId = uniqueId == 0 ? 950000000000UL + templateId : uniqueId,
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

    

    private async Task<object> MoneySetAsync(string json, CancellationToken token)
    {
        Hydrate();
        var session = hub.Current;
        if (session is null) return NoSession();

        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            var money = root.TryGetProperty("money", out var pm) ? pm.GetDouble() : 0d;
            var gold = root.TryGetProperty("gold", out var pg) ? pg.GetDouble() : 0d;
            var binding = root.TryGetProperty("bindingGold", out var pb) ? pb.GetDouble() : 0d;

            lock (State.Sync)
            {
                State.Money = money;
                State.Gold = gold;
                State.BindingGold = binding;
            }

            await PushAsync(session, MethodId.SyncMoney,
                new GameMethods.SyncMoney4229938 { money = money, gold = gold, bindingGold = binding }, token);
            Persist();
            session.Log.Info($"[DEBUG-API] 货币设置 money={money} gold={gold} binding={binding}");
            return new { ok = true, money, gold, bindingGold = binding };
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }
    }

    private async Task<object> MoneyAddAsync(string json, CancellationToken token)
    {
        Hydrate();
        var session = hub.Current;
        if (session is null) return NoSession();

        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            var value = root.TryGetProperty("value", out var pv) ? pv.GetDouble() : 0d;
            var reason = root.TryGetProperty("reason", out var pr) ? pr.GetInt32() : 0;
            var silence = !root.TryGetProperty("silence", out var ps) || ps.ValueKind != JsonValueKind.False;

            lock (State.Sync)
                State.Money += value;

            await PushAsync(session, MethodId.SyncMoneyAdd,
                new GameMethods.SyncMoneyAdd4229938 { value = value, reason = reason, silence = silence }, token);
            Persist();
            session.Log.Info($"[DEBUG-API] 货币增加 {value} reason={reason}");
            return new { ok = true, value };
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }
    }

    

    private async Task<object> WeaponAddAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();
        Hydrate();

        uint templateId;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (!doc.RootElement.TryGetProperty("templateId", out var pt) || (templateId = pt.GetUInt32()) == 0)
                return new { ok = false, error = "缺少 templateId" };
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        
        var message = await GameRouter.GrantWeaponAsync(session, templateId, token);
        if (message.StartsWith("weapon template", StringComparison.Ordinal))
            return new { ok = false, error = message };

        var definition = CombatCatalogRepository.AccountWeaponByTemplate(templateId);
        if (definition is not null)
            SessionState.Update(st =>
            {
                if (st.Weapons.All(w => w.InstanceId != definition.InstanceId))
                    st.Weapons.Add(new WeaponRecord { InstanceId = definition.InstanceId, TemplateId = templateId, SpiritId = 0 });
            });
        Persist();
        return new { ok = true, templateId, instanceId = definition?.InstanceId ?? 0, message };
    }

    private async Task<object> WeaponRemoveAsync(string json, CancellationToken token)
    {
        Hydrate();
        var session = hub.Current;
        if (session is null) return NoSession();

        ulong instanceId;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (!doc.RootElement.TryGetProperty("instanceId", out var pi) || (instanceId = pi.GetUInt64()) == 0)
                return new { ok = false, error = "缺少 instanceId" };
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        lock (State.Sync)
            State.Weapons.RemoveAll(w => w.InstanceId == instanceId);

        await PushAsync(session, MethodId.SyncArmoryRemoveWeapon,
            new GameMethods.SyncArmoryRemoveWeapon4229938 { id = instanceId }, token);
        Persist();
        session.Log.Info($"[DEBUG-API] 武器移除 instance={instanceId}");
        return new { ok = true, instanceId };
    }

    

    private async Task<object> FashionAddAsync(string json, CancellationToken token)
    {
        Hydrate();
        var session = hub.Current;
        if (session is null) return NoSession();

        uint fashionId = 0;
        bool all = false, forCurrentSpirit = false;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (root.TryGetProperty("fashionId", out var pf))
                fashionId = pf.GetUInt32();
            all = root.TryGetProperty("all", out var pa) && pa.ValueKind == JsonValueKind.True;
            forCurrentSpirit = root.TryGetProperty("currentSpiritOnly", out var pc) && pc.ValueKind == JsonValueKind.True;
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        if (all)
        {
            var spirit = forCurrentSpirit ? (uint?)ActiveSpiritTemplateId(session) : null;
            var ids = GameCatalog.Fashions
                .Where(f => spirit is null || f.SpiritId == spirit.Value)
                .Select(f => f.FashionId)
                .Distinct()
                .ToList();
            if (ids.Count == 0)
                return new { ok = false, error = "字典为空，无法一键发送" };

            lock (State.Sync)
                foreach (var id in ids)
                    State.Fashions.Add(id);
            await GameRouter.GrantFashionsAsync(session, ids, token);
            Persist();
            session.Log.Info($"[DEBUG-API] 时装批量入库 count={ids.Count} spirit={spirit?.ToString() ?? "全部"}");
            return new { ok = true, count = ids.Count };
        }

        if (fashionId == 0)
            return new { ok = false, error = "缺少 fashionId，或使用 all=true 一键发送" };

        lock (State.Sync)
            State.Fashions.Add(fashionId);
        await GameRouter.GrantFashionsAsync(session, [fashionId], token);
        Persist();
        session.Log.Info($"[DEBUG-API] 时装入库 fashion={fashionId}");
        return new { ok = true, fashionId };
    }

    private async Task<object> FashionRemoveAsync(string json, CancellationToken token)
    {
        Hydrate();
        var session = hub.Current;
        if (session is null) return NoSession();

        uint fashionId;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (!doc.RootElement.TryGetProperty("fashionId", out var pf) || (fashionId = pf.GetUInt32()) == 0)
                return new { ok = false, error = "缺少 fashionId" };
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        lock (State.Sync)
            State.Fashions.Remove(fashionId);
        await PushAsync(session, MethodId.IGameToClient_SyncRemoveFashion,
            new GameMethods.SyncRemoveFashion4229938 { fashionId = fashionId }, token);
        Persist();
        session.Log.Info($"[DEBUG-API] 时装移除 fashion={fashionId}");
        return new { ok = true, fashionId };
    }

    private static Auto.FashionInfo FashionInfo(uint id) => new()
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

    
    
    
    
    

    private async Task<object> QuestAcceptAsync(string json, CancellationToken token)
    {
        Hydrate();
        var session = hub.Current;
        if (session is null) return NoSession();

        uint taskId;
        byte? state = null;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (!root.TryGetProperty("taskId", out var pt) || (taskId = pt.GetUInt32()) == 0)
                return new { ok = false, error = "缺少 taskId" };
            if (root.TryGetProperty("state", out var ps) && ps.TryGetByte(out var sv)) state = sv;
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        var message = await GameRouter.AcceptQuestAsync(session, taskId, state, token);
        session.Log.Info($"[DEBUG-API] 任务接取 task={taskId}: {message}");
        return new { ok = true, taskId, message };
    }

    private async Task<object> QuestCompleteAsync(string json, CancellationToken token)
    {
        Hydrate();
        var session = hub.Current;
        if (session is null) return NoSession();

        uint taskId;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (!doc.RootElement.TryGetProperty("taskId", out var pt) || (taskId = pt.GetUInt32()) == 0)
                return new { ok = false, error = "缺少 taskId" };
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        
        var message = await GameRouter.CompleteAndAdvanceAsync(session, taskId, token);
        session.Log.Info($"[DEBUG-API] 任务完成 task={taskId}: {message}");
        return new { ok = true, taskId, message };
    }

    private async Task<object> QuestSubmitAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint taskId;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (!doc.RootElement.TryGetProperty("taskId", out var pt) || (taskId = pt.GetUInt32()) == 0)
                return new { ok = false, error = "缺少 taskId" };
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        var message = await GameRouter.SubmitQuestAsync(session, taskId, token);
        return new { ok = true, taskId, message };
    }

    
    
    
    
    
    
    
    
    
    
    private async Task<object> QuestResetAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        var reseed = false;
        try
        {
            if (!string.IsNullOrWhiteSpace(json))
            {
                using var doc = JsonDocument.Parse(json);
                if (doc.RootElement.ValueKind == JsonValueKind.Object &&
                    doc.RootElement.TryGetProperty("reseed", out var rs) &&
                    (rs.ValueKind == JsonValueKind.True || rs.ValueKind == JsonValueKind.False))
                    reseed = rs.GetBoolean();
            }
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        var message = await GameRouter.ResetQuestsAsync(session, reseed, token);
        return new { ok = true, reseed, message };
    }

    private async Task<object> QuestUnlockAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint questId;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (!doc.RootElement.TryGetProperty("questId", out var pq) || (questId = pq.GetUInt32()) == 0)
                return new { ok = false, error = "缺少 questId" };
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        var message = await GameRouter.UnlockQuestAsync(session, questId, token);
        return new { ok = true, questId, message };
    }

    private async Task<object> QuestCompleteSubAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint subQuestId;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (!doc.RootElement.TryGetProperty("subQuestId", out var pq) || (subQuestId = pq.GetUInt32()) == 0)
                return new { ok = false, error = "缺少 subQuestId" };
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        var message = await GameRouter.CompleteSubQuestAsync(session, subQuestId, token);
        return new { ok = true, subQuestId, message };
    }

    
    
    
    
    
    
    private object StoryChain(System.Collections.Specialized.NameValueCollection query)
    {
        var root = uint.TryParse(query["root"], out var r) && r != 0 ? r : GameRouter.StoryRootTaskId;
        var chain = TaskCatalogRepository.ChainFrom(root);

        
        var session = hub.Current;
        var container = GameRouter.SnapshotQuestContainer(session);

        return new
        {
            ok = true,
            root,
            rootName = TaskCatalogRepository.Name(root) ?? string.Empty,
            length = chain.Count,
            steps = chain.Select(id => new
            {
                id,
                name = TaskCatalogRepository.Name(id) ?? string.Empty,
                counters = TaskCatalogRepository.Counters(id).Length,
                title = TaskCatalogRepository.TitleId(id),
            }),
            
            hasSession = container is not null,
            currentTask = container?.CurrentTask ?? 0,
            currentTaskName = container is null
                ? string.Empty
                : TaskCatalogRepository.Name(container.CurrentTask) ?? string.Empty,
            tasks = container?.Tasks.Select(t => new
            {
                id = t.TaskId,
                name = TaskCatalogRepository.Name(t.TaskId) ?? string.Empty,
                state = t.State,
                counters = TaskCatalogRepository.Counters(t.TaskId).Length,
                values = t.Values,
            }) ?? [],
        };
    }

    
    private async Task<object> StoryStartAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint rootId = 0;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (doc.RootElement.TryGetProperty("rootId", out var pr) && pr.TryGetUInt32(out var rv)) rootId = rv;
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        var message = await GameRouter.StartStoryChainAsync(session, rootId, token);
        return new { ok = true, message };
    }

    
    private async Task<object> StoryAdvanceAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint taskId = 0;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (doc.RootElement.TryGetProperty("taskId", out var pt) && pt.TryGetUInt32(out var tv)) taskId = tv;
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        if (taskId == 0)
            return new { ok = false, error = "缺少 taskId" };

        var message = await GameRouter.CompleteAndAdvanceAsync(session, taskId, token);
        return new { ok = true, taskId, message };
    }

    
    private object TaskSearch(System.Collections.Specialized.NameValueCollection query)
    {
        var term = query["q"];
        var limit = int.TryParse(query["limit"], out var l) ? Math.Clamp(l, 1, 500) : 80;
        var hits = TaskCatalogRepository.Search(term, limit);
        return new
        {
            ok = true,
            total = TaskCatalogRepository.Count,
            returned = hits.Count(),
            tasks = hits.Select(t => new
            {
                id = t.Id,
                name = t.Name,
                counters = TaskCatalogRepository.Counters(t.Id).Length,
                title = TaskCatalogRepository.TitleId(t.Id),
                next = TaskCatalogRepository.NextTasks(t.Id),
            }),
        };
    }

    
    
    
    
    
    
    private object QuestPacketsProbe(System.Collections.Specialized.NameValueCollection query)
    {
        var taskId = uint.TryParse(query["taskId"], out var t) && t != 0 ? t : GameRouter.StoryRootTaskId;
        var configured = TaskCatalogRepository.Counters(taskId);
        var outList = new List<object>();

        void Add<T>(string name, uint methodId, T body)
        {
            var bytes = UxSerializer.Serialize(body);
            outList.Add(new
            {
                name,
                methodId,
                size = bytes.Length,
                hex = Convert.ToHexString(bytes),
            });
        }

        
        
        var info = new GameMethods.TaskInfo4229938
        {
            TaskId = taskId,
            State = 1,
            RecoverResource = false,
        };
        info.SpoonViewInfo = GameRouter.BuildSpoonViewInfo(taskId);
        for (var i = 0; i < configured.Length; i++)
        {
            info.CounterValues.Add(0);
            info.Counters.Add(new GameMethods.TaskCounter4229938
            {
                Index = i,
                Value = 0,
                ConfigValue = configured[i],
                Parent = 0,
            });
        }
        var container = new GameMethods.SyncPlayerAllTask4229938
        {
            currentTask = taskId,
            loginGameServer = true,
        };
        container.taskInfos.Add(info);
        Add("SyncPlayerAllTask", MethodId.SyncPlayerAllTask, container);

        
        Add("SyncCurrentTask", MethodId.SyncCurrentTask, new GameMethods.SyncCurrentTask4229938
        {
            type = 0,
            taskId = taskId,
            eventId = 0,
            firstTime = true,
            reason = 0,
        });

        
        Add("SyncTaskTitleGuideUnlock", MethodId.SyncTaskTitleGuideUnlock,
            new GameMethods.SyncTaskTitleGuideUnlock4229938
            {
                taskTitleId = (ushort)Math.Max(1, TaskCatalogRepository.TitleId(taskId)),
                unlock = true,
            });

        
        Add("SyncTaskSpoonResourceLoaded", MethodId.SyncTaskSpoonResourceLoaded,
            new GameMethods.SyncTaskSpoonResourceLoaded4229938
            {
                taskId = taskId,
                resource = new GameMethods.SpoonTaskResource4229938(),
            });

        
        
        
        
        
        
        
        
        
        var spoonData = new GameMethods.SpoonTaskClientData4229938
        {
            TaskId = taskId,
            EventId = 0,
        };
        spoonData.TriggerInfos.Add(new GameMethods.SpoonTriggerInfo4229938
        {
            FlowIndex = 0,
            NodeId = 0,
            StartTime = 0,
            NeedComplete = true,
            MemoryTaskId = taskId,
            IsCondition = false,
            Ports = [new GameMethods.SpoonPort4229938 { Type = 1, PortId = 0 }],
        });

        var spoon = new GameMethods.SyncSpoonTaskClientData4229938();
        spoon.data.Add(spoonData);
        Add("SyncSpoonTaskClientData", MethodId.SyncSpoonTaskClientData, spoon);

        
        Add("SyncCollectionQuestUnlock", MethodId.SyncCollectionQuestUnlock,
            new GameMethods.SyncCollectionQuestUnlock4229938 { questId = taskId });

        
        Add("SyncCompletedSubQuest", MethodId.SyncCompletedSubQuest,
            new GameMethods.SyncCompletedSubQuest4229938 { subQuestId = taskId });

        return new
        {
            ok = true,
            taskId,
            taskName = TaskCatalogRepository.Name(taskId) ?? string.Empty,
            counters = configured.Length,
            packets = outList,
        };
    }

    
    
    
    
    
    
    private object MapEntrancesProbe(System.Collections.Specialized.NameValueCollection query)
    {
        var only = int.TryParse(query["type"], out var t) ? t : (int?)null;
        var rows = ExtraCatalog.MapEntrances
            .Where(e => only is null || e.Type == only)
            .OrderBy(e => e.Type).ThenBy(e => e.Id)
            .Select(e => new { id = e.Id, name = e.Name, type = e.Type, raidId = e.RaidId, x = e.X, y = e.Y, z = e.Z })
            .ToList();

        var byType = ExtraCatalog.MapEntrances
            .GroupBy(e => e.Type)
            .OrderBy(g => g.Key)
            .ToDictionary(g => g.Key.ToString(), g => g.Count());

        return new
        {
            ok = true,
            total = ExtraCatalog.MapEntrances.Count,
            byType,
            metroStations = ExtraCatalog.MapEntrances.Count(e => e.Type == 11),
            returned = rows.Count,
            entrances = rows,
        };
    }

    
    private object TaskContainerHex(System.Collections.Specialized.NameValueCollection query)
    {
        var taskId = uint.TryParse(query["taskId"], out var t) && t != 0 ? t : GameRouter.StoryRootTaskId;
        var configured = TaskCatalogRepository.Counters(taskId);

        var info = new GameMethods.TaskInfo4229938
        {
            TaskId = taskId,
            State = 1,
            RecoverResource = false,
        };
        
        info.SpoonViewInfo = GameRouter.BuildSpoonViewInfo(taskId);
        for (var i = 0; i < configured.Length; i++)
        {
            info.CounterValues.Add(0);
            info.Counters.Add(new GameMethods.TaskCounter4229938
            {
                Index = i,
                Value = 0,
                ConfigValue = configured[i],
                Parent = 0,
            });
        }

        var container = new GameMethods.SyncPlayerAllTask4229938
        {
            currentTask = taskId,
            loginGameServer = true,
        };
        container.taskInfos.Add(info);

        var bytes = UxSerializer.Serialize(container);
        return new
        {
            ok = true,
            taskId,
            name = TaskCatalogRepository.Name(taskId) ?? string.Empty,
            counters = configured.Length,
            size = bytes.Length,
            hex = Convert.ToHexString(bytes),
        };
    }

    

    
    
    
    
    
    private async Task<object> ShopBuyAsync(string json, CancellationToken token)
    {
        Hydrate();
        var session = hub.Current;
        if (session is null) return NoSession();

        uint commodityId = 0, bindId = 0, count = 1;
        double price = 0;
        var grant = "item";
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (root.TryGetProperty("commodityId", out var pc)) commodityId = pc.GetUInt32();
            if (root.TryGetProperty("bindId", out var pb)) bindId = pb.GetUInt32();
            if (root.TryGetProperty("count", out var pn)) count = pn.GetUInt32();
            if (root.TryGetProperty("price", out var pp)) price = pp.GetDouble();
            if (root.TryGetProperty("grant", out var pg)) grant = pg.GetString() ?? "item";

            var entry = GameCatalog.Mall.FirstOrDefault(m => m.CommodityId == commodityId);
            if (entry is not null)
            {
                bindId = bindId != 0 ? bindId : entry.BindId;
                price = price > 0 ? price : entry.Price;
            }
            if (count == 0) count = 1;
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        if (bindId == 0)
            return new { ok = false, error = "缺少 bindId（要发放的物品/时装 ID）" };

        if (price > 0)
            await PushAsync(session, MethodId.SyncMoneyAdd,
                new GameMethods.SyncMoneyAdd4229938 { value = -price, reason = 0, silence = true }, token);

        switch (grant)
        {
            case "fashion":
                lock (State.Sync) State.Fashions.Add(bindId);
                await PushAsync(session, MethodId.SyncAddFashion,
                    new GameMethods.SyncAddFashion4229938 { fashionInfo = FashionInfo(bindId) }, token);
                break;
            case "weapon":
                var weapon = await CombatCatalogResolver.WeaponDataAsync(bindId, ResolveSpiritId(0));
                ulong weaponInstance;
                lock (State.Sync)
                {
                    weaponInstance = (ulong)Interlocked.Increment(ref State.WeaponInstanceSeq);
                    State.Weapons.Add(new WeaponEntry(weaponInstance, bindId, ResolveSpiritId(0)));
                }
                weapon.InstanceId = weaponInstance;
                await PushAsync(session, MethodId.SyncArmoryAddWeapon,
                    new GameMethods.SyncArmoryAddWeapon4229938 { weapon = weapon }, token);
                break;
            default:
                ulong uniqueId;
                uint total;
                lock (State.Sync)
                {
                    if (!State.ItemUniqueIds.TryGetValue(bindId, out uniqueId))
                    {
                        uniqueId = ++State.ItemUniqueSeq;
                        State.ItemUniqueIds[bindId] = uniqueId;
                    }
                    State.Backpack.TryGetValue(bindId, out var existing);
                    total = existing + count;
                    State.Backpack[bindId] = total;
                }
                await PushAsync(session, MethodId.SyncBackpackItemChanged,
                    new GameMethods.SyncBackpackItemChanged4229938
                    {
                        updateItemList = [PackItem(bindId, uniqueId, total)],
                    }, token);
                break;
        }

        Persist();
        session.Log.Info($"[DEBUG-API] 商城直购 commodity={commodityId} 发放={bindId}({grant}) 价格={price}");
        return new { ok = true, commodityId, bindId, grant, price, count };
    }

    

    private static object AccountList()
    {
        var active = AccountStore.ActiveAccountId;
        return new
        {
            ok = true,
            active,
            root = AccountStore.Root,
            accounts = AccountStore.Accounts.Select(a => new
            {
                id = a.Id, name = a.Name, uid = a.Uid, pid = a.Pid, username = a.Username,
                createdAt = a.CreatedAt.ToString("yyyy-MM-dd HH:mm:ss"),
                active = a.Id == active,
            }).ToList(),
        };
    }

    private object AccountCreate(string json)
    {
        string id, name, username, password, uid;
        ulong pid = 0;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            id = root.TryGetProperty("id", out var pi) ? (pi.GetString() ?? string.Empty).Trim() : string.Empty;
            name = root.TryGetProperty("name", out var pn) ? (pn.GetString() ?? string.Empty).Trim() : string.Empty;
            username = root.TryGetProperty("username", out var pu) ? (pu.GetString() ?? string.Empty).Trim() : string.Empty;
            password = root.TryGetProperty("password", out var pp) ? (pp.GetString() ?? string.Empty) : string.Empty;
            uid = root.TryGetProperty("uid", out var pui) ? (pui.GetString() ?? string.Empty).Trim() : string.Empty;
            if (root.TryGetProperty("pid", out var ppid) && ppid.TryGetUInt64(out var parsedPid)) pid = parsedPid;
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        if (string.IsNullOrEmpty(id)) id = "acc" + Guid.NewGuid().ToString("N").Substring(0, 6);
        if (string.IsNullOrEmpty(name)) name = id;

        try
        {
            AccountStore.CreateAccount(id, name,
                string.IsNullOrEmpty(username) ? null : username,
                string.IsNullOrEmpty(password) ? null : password,
                string.IsNullOrEmpty(uid) ? null : uid,
                pid);
            return AccountList();
        }
        catch (Exception ex) { return new { ok = false, error = ex.Message }; }
    }

    private object AccountSwitch(string json)
    {
        string id;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (!doc.RootElement.TryGetProperty("id", out var pi)) return new { ok = false, error = "缺少 id" };
            id = pi.GetString() ?? string.Empty;
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        try
        {
            SessionState.SwitchTo(id);
            _hydrated = false;
            return AccountList();
        }
        catch (Exception ex) { return new { ok = false, error = ex.Message }; }
    }

    private object AccountDelete(string json)
    {
        string id;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (!doc.RootElement.TryGetProperty("id", out var pi)) return new { ok = false, error = "缺少 id" };
            id = pi.GetString() ?? string.Empty;
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        return AccountStore.DeleteAccount(id)
            ? AccountList()
            : new { ok = false, error = "删除失败（账号不存在，或至少要保留一个账号）" };
    }

    
    private async Task<object> WeaponAddAllAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();
        Hydrate();

        var onlyCurrent = false;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            onlyCurrent = doc.RootElement.TryGetProperty("currentSpiritOnly", out var pc) && pc.ValueKind == JsonValueKind.True;
        }
        catch { }

        var message = onlyCurrent
            ? await GameRouter.GrantWeaponsAsync(session, GameRouter.ArmoryTemplateIds(true, ResolveSpiritId(0)), token)
            : await GameRouter.GrantAllWeaponsAsync(session, token);

        
        
        
        
        
        
        
        var added = 0;
        foreach (var id in GameRouter.ArmoryTemplateIds(onlyCurrent, ResolveSpiritId(0)))
        {
            var def = CombatCatalogRepository.AccountWeaponByTemplate(id);
            if (def is null) continue;

            SessionState.Update(st =>
            {
                if (st.Weapons.All(w => w.InstanceId != def.InstanceId))
                    st.Weapons.Add(new WeaponRecord { InstanceId = def.InstanceId, TemplateId = id, SpiritId = def.SpiritTemplateId });
            });

            lock (State.Sync)
            {
                if (State.Weapons.All(w => w.InstanceId != def.InstanceId))
                {
                    State.Weapons.Add(new WeaponEntry(def.InstanceId, id, def.SpiritTemplateId));
                    added++;
                }
            }
        }
        Persist();
        
        
        return new { ok = true, count = added, message };
    }

    
    private async Task<object> AmmoAddAllAsync(CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();
        Hydrate();

        
        var ids = GameRouter.AmmoTemplateIds().ToList();
        if (ids.Count == 0)
            ids = GameCatalog.Items
                .Where(i => i.SubType == 20 || i.SubType == 21 || i.SubType == 22
                            || (i.En ?? string.Empty).IndexOf("bullet", StringComparison.OrdinalIgnoreCase) >= 0
                            || (i.Zh ?? string.Empty).Contains("子弹") || (i.Zh ?? string.Empty).Contains("弹药"))
                .Select(i => i.TemplateId).Distinct().ToList();
        if (ids.Count == 0)
            ids = GameCatalog.Items.Where(i => i.SubType == 18).Select(i => i.TemplateId).Take(50).ToList();

        var granted = await GameRouter.GrantItemsAsync(session, ids.Select(id => (id, 9999u)), token);
        lock (State.Sync)
            foreach (var id in ids)
                State.Backpack[id] = 9999;

        Persist();
        session.Log.Info($"[DEBUG-API] 一键补齐弹药 {granted} 种");
        return new { ok = true, count = granted };
    }

    

    
    private async Task<object> ContentBaselineAsync(CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();
        Hydrate();
        await GameRouter.PushContentBaselineAsync(session);
        return new { ok = true };
    }

    
    private async Task<object> MapRevealAsync(CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        SessionState.Update(s => s.MapFullyRevealed = true);

        var ids = ExtraCatalog.MapEntrances.Select(e => e.Id).Distinct().ToList();
        await PushAsync(session, MethodId.SyncMapEntrance, new GameMethods.SyncMapEntrance4229938
        {
            openEntrance = ids,
            displayableEntrances = ids,
        }, token);
        foreach (var id in ids)
            await PushAsync(session, MethodId.UpdateMapEntrance, new GameMethods.UpdateMapEntrance4229938
            {
                mapEntranceId = id, isOpen = true, isShow = true,
            }, token);

        await GameRouter.PushFogUnlockAsync(session, unlock: true);

        var countries = ExtraCatalog.Raids
            .GroupBy(r => r.CountryId)
            .Select(g => new { country = g.Key, raids = g.Count(), scenes = g.Select(x => x.SceneId).Distinct().Count() })
            .ToList();

        session.Log.Info($"[DEBUG-API] 地图全开：传送点 {ids.Count} 个 + 场景 {ExtraCatalog.SceneIds.Count} 个迷雾清除 + 区域 {countries.Count} 个");
        return new { ok = true, entrances = ids.Count, scenes = ExtraCatalog.SceneIds.Count, countries };
    }

    private async Task<object> AchievementUnlockAllAsync(CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();
        await GameRouter.PushAchievementsAsync(session);
        return new { ok = true, count = ExtraCatalog.Achievements.Count };
    }

    private async Task<object> PediaUnlockAllAsync(CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();
        await GameRouter.PushCityPediaAsync(session);
        return new { ok = true, count = ExtraCatalog.CityPedia.Count };
    }

    
    
    
    
    
    private static object LoginPayloadProbe()
    {
        try
        {
            var info = RuntimePayloadFactory.MinimalPlayerInfo4229938();
            var bytes = UxSerializer.Serialize(info);

            
            var routes = ExtraCatalog.MapRoutes;
            var metroBody = new GameMethods.SyncRunningMetroInfos4229938();
            for (var i = 0; i < routes.Count; i++)
                metroBody.metroInfos.Add(GameRouter.BuildMetroInfo(routes[i].Id, i));
            var metroBytes = UxSerializer.Serialize(metroBody);

            return new
            {
                ok = true,
                totalBytes = bytes.Length,
                unlockSystems = info.InfoMinor.PlayerInfoGuide.UnlockSystems.Count,
                factionInfos = info.InfoAchievement.FactionInfoDic.Count,
                hasFactionZero = info.InfoAchievement.FactionInfoDic.ContainsKey(0),
                finishedGuides = info.InfoMinor.PlayerInfoGuide.FinishedGuides.Count,
                unlockSystemsHead = info.InfoMinor.PlayerInfoGuide.UnlockSystems.Take(6).ToArray(),
                installedApps = info.InfoSpirit.InstalledApps,
                
                
                
                
                fightStylesUnlocked = info.InfoSpirit.InfoFightStyle.FightStyleIsUnLocked.Count,
                fightStyleFirstUnlockTimes = info.InfoSpirit.InfoFightStyle.FightStyleFirstUnlockTimes.Count,
                downloadAppIds = info.InfoMinor.PlayerPhoneInfo.DownLoadAppIds.Count,
                commonSpiritTalentExp = info.InfoSpirit.CommonSpiritTalentExp,
                spiritInitTalentPointAdd = info.InfoSpirit.SpiritInitTalentPointAdd,
                spiritsWithJobs = info.InfoSpirit.Spirits.Count(s => s.SpiritJobInfo.CurrentJob != 0),
                spiritsWithTalents = info.InfoSpirit.Spirits.Count(s => s.TalentInfo.UnlockTalentInfoDict.Count > 0),
                spiritsWithUrbanAbilities = info.InfoSpirit.Spirits.Count(s => s.SpiritUrbanSkill.UrbanAbilities.Count > 0),
                
                
                jobSyncProbe = ProbeSpiritJobSync(),
                phoneAppProbe = new
                {
                    hacker = ProbeHackerJobSync(),
                    police = ProbePoliceFakeFileSync(),
                },
                jobSummary = info.InfoSpirit.Spirits
                    .Where(s => s.SpiritJobInfo.CurrentJob != 0)
                    .Select(s => new
                    {
                        spirit = s.TemplateId,
                        job = s.SpiritJobInfo.CurrentJob,
                        jobName = SpiritContentCatalogRepository.JobLevel(s.SpiritJobInfo.CurrentJob)?.Name,
                        jobClass = SpiritContentCatalogRepository.JobLevel(s.SpiritJobInfo.CurrentJob)?.JobClass,
                        className = SpiritContentCatalogRepository.JobClass(
                            SpiritContentCatalogRepository.JobLevel(s.SpiritJobInfo.CurrentJob)?.JobClass ?? 0)?.ClassName,
                        
                        
                        
                        availableJobs = s.SpiritJobInfo.AvailableJobs.Keys.OrderBy(x => x).ToArray(),
                        availableClasses = s.SpiritJobInfo.AvailableJobs.Keys
                            .Select(id => SpiritContentCatalogRepository.JobLevel(id)?.JobClass ?? 0)
                            .Where(c => c != 0).Distinct().OrderBy(x => x).ToArray(),
                        talents = s.SpiritJobInfo.AvailableJobs.Values
                            .SelectMany(j => j.TalentInfo.UnlockTalentInfoDict.Keys).Distinct().Count(),
                    })
                    .ToArray(),
                cityPediaStatusCount = info.InfoMinor.PlayerCityPediaInfos.CityPediaStatusDict.Count,
                cityPediaLevel = info.InfoMinor.PlayerCityPediaInfos.CreditInfo.Level,
                npcProfiles = info.InfoMinor.InfoNpcProfile.NpcProfiles.Count,
                npcProfileTargets = info.InfoMinor.InfoNpcProfile.NpcProfiles.Values
                    .Select(p => p.TargetStateList.Count).DefaultIfEmpty(0).Max(),
                accountBadges = info.InfoMinor.Badges.Count,
                spirits = info.InfoSpirit.Spirits.Count,
                spiritsWithBadges = info.InfoSpirit.Spirits.Count(s => s.InfoBadge.Badges.Count > 0),
                metro = new
                {
                    lines = metroBody.metroInfos.Count,
                    bytes = metroBytes.Length,
                    ids = metroBody.metroInfos.Select(m => m.LineId).ToArray(),
                },
            };
        }
        catch (Exception ex)
        {
            return new { ok = false, error = ex.GetType().Name, message = ex.Message, stack = ex.StackTrace };
        }
    }

    
    
    
    
    
    private static object ProbeSpiritJobSync()
    {
        var target = GameCatalog.Characters
            .FirstOrDefault(c => SpiritContentCatalogRepository.Spirit(c.TemplateId) is { } r
                && SpiritContentCatalogRepository.DefaultJobId(r) != 0);
        var spiritId = target?.TemplateId ?? 0;
        if (spiritId == 0)
            return new { spiritId = 0, bytes = 0, note = "没有带默认职业的角色" };

        var row = SpiritContentCatalogRepository.Spirit(spiritId)!;
        var jobId = SpiritContentCatalogRepository.DefaultJobId(row);
        var job = RuntimePayloadFactory.BuildSpiritJob4229938(spiritId, jobId);
        if (job is null)
            return new { spiritId, jobId, bytes = 0, note = "BuildSpiritJob 返回 null" };

        var payload = new GameMethods.SyncSpiritJobInfo4229938
        {
            spiritId = spiritId,
            spiritJobs = new Dictionary<uint, Auto.SpiritJob> { [jobId] = job },
            currentJob = jobId,
        };
        var bytes = UxSerializer.Serialize(payload);
        return new
        {
            spiritId,
            jobId,
            jobName = SpiritContentCatalogRepository.JobLevel(jobId)?.Name,
            jobClassId = SpiritContentCatalogRepository.JobLevel(jobId)?.JobClass,
            talentPoint = job.TalentInfo.TalentPoint,
            unlockedTalents = job.TalentInfo.UnlockTalentInfoDict.Count,
            trees = job.TalentInfo.TalentTreeRecordDict.Count,
            bytes = bytes.Length,
            
            
            
            
            hex = Convert.ToHexString(bytes),
            decoded = DecodeSpiritJobSync(bytes),
        };
    }

    
    
    
    
    
    
    
    private static List<string> DecodeSpiritJobSync(byte[] b)
    {
        var o = new List<string>();
        var i = 0;
        var overrun = false;

        uint U32()
        {
            if (i + 4 > b.Length) { overrun = true; return 0xDEADBEEF; }
            var v = BitConverter.ToUInt32(b, i); i += 4; return v;
        }
        byte U8()
        {
            if (i + 1 > b.Length) { overrun = true; return 0xEE; }
            return b[i++];
        }

        
        
        int Int7()
        {
            if (i + 1 > b.Length) { overrun = true; return -1; }
            return b[i++] - 1;
        }

        o.Add($"len={b.Length}");
        if (b.Length < 6)
        {
            o.Add("payload too short");
            return o;
        }

        o.Add($"@{i,3} spiritId        = {U32()}");
        var dictMark = U8();
        o.Add($"@{i - 1,3} spiritJobs.mark = 0x{dictMark:X2} (非 0 = 有值)");
        var count = Int7();
        o.Add($"@{i - 1,3} spiritJobs.count= {count} (Int7 已 -1)");

        for (var n = 0; n < count && !overrun; n++)
        {
            var key = U32();
            o.Add($"@{i - 4,3}   key(jobId)     = {key}");
            var jobMark = U8();
            o.Add($"@{i - 1,3}   SpiritJob.mark= 0x{jobMark:X2}");
            o.Add($"@{i,3}     Job          = {U32()}");
            o.Add($"@{i,3}     Exp          = {U32()}");
            o.Add($"@{i,3}     Level        = {U8()}");
            o.Add($"@{i,3}     RegisterTime = {U32()}");
            o.Add($"@{i,3}     UnregisterT  = {U32()}");

            var tp = U8();
            o.Add($"@{i - 1,3}     TalentInfo.mark= 0x{tp:X2}  <<< 必须是 0x01；0xFF 会让客户端崩");
            o.Add($"@{i,3}       TalentPoint  = {U32()}");

            var d1 = U8();
            var c1 = i + 4 <= b.Length ? BitConverter.ToInt32(b, i) : -1;
            i += 4;
            o.Add($"@{i - 5,3}       UnlockTalentInfoDict mark=0x{d1:X2} count={c1}");
            for (var k = 0; k < c1 && i + 8 <= b.Length; k++)
                o.Add($"@{i,3}         talentId={U32()} layer={U32()}");

            var d2 = U8();
            var c2 = i + 4 <= b.Length ? BitConverter.ToInt32(b, i) : -1;
            i += 4;
            o.Add($"@{i - 5,3}       TalentTreeRecordDict mark=0x{d2:X2} count={c2}");
            for (var k = 0; k < c2 && i + 13 <= b.Length; k++)
            {
                var at = i;
                var treeId = U32();
                var recMark = U8();
                var spent = U32();
                var activated = U32();
                o.Add($"@{at,3}         tree={treeId} mark=0x{recMark:X2} spent={spent} nodes={activated}");
            }
        }

        if (i + 4 <= b.Length)
            o.Add($"@{i,3} currentJob      = {U32()}");

        o.Add($"consumed {i}/{b.Length} bytes" + (overrun ? "  *** OVERRUN ***" : "  (OK)"));
        return o;
    }

    private async Task<object> ShopOpenAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint shopId = 0;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (doc.RootElement.TryGetProperty("shopId", out var ps)) shopId = ps.GetUInt32();
        }
        catch { }

        await GameRouter.PushShopAsync(session, shopId);
        return new { ok = true, shopId };
    }

    private async Task<object> HouseBuyAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint houseId = 0;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (doc.RootElement.TryGetProperty("houseId", out var ph)) houseId = ph.GetUInt32();
        }
        catch { }

        if (houseId == 0)
            houseId = ExtraCatalog.MapEntrances.FirstOrDefault()?.Id ?? 1;

        await GameRouter.PushHouseAsync(session, houseId);
        SessionState.Update(s => { if (!s.UnlockedMapEntrances.Contains(houseId)) s.UnlockedMapEntrances.Add(houseId); });
        session.Log.Info($"[DEBUG-API] 房产下发 houseId={houseId}");
        return new { ok = true, houseId };
    }

    
    
    
    
    
    
    
    
    
    
    private async Task<object> WorldEnterAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint raidId = 0, sceneId = 0;
        var sceneName = string.Empty;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (root.TryGetProperty("raidId", out var pr) && pr.TryGetUInt32(out var rv)) raidId = rv;
            if (root.TryGetProperty("sceneId", out var ps) && ps.TryGetUInt32(out var sv)) sceneId = sv;
            if (root.TryGetProperty("sceneName", out var pn) && pn.ValueKind == JsonValueKind.String)
                sceneName = pn.GetString() ?? string.Empty;
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        Ananta.Server.Handlers.Game.WorldSwitchResult result = raidId != 0
            ? Ananta.Server.Handlers.Game.WorldSwitch.ByRaid(raidId)
            : sceneId != 0
                ? Ananta.Server.Handlers.Game.WorldSwitch.ByScene(sceneId)
                : !string.IsNullOrWhiteSpace(sceneName)
                    ? Ananta.Server.Handlers.Game.WorldSwitch.BySceneName(sceneName)
                    : Ananta.Server.Handlers.Game.WorldSwitchResult.Failure("需要 raidId / sceneId / sceneName 之一");

        if (!result.Ok)
            return new { ok = false, error = result.Error };

        
        var ctx = new Ananta.SDK.Rpc.RpcContext(
            session, new Ananta.SDK.Rpc.RpcPacket(Ananta.SDK.Rpc.RpcPacketKind.Notify, 0, 0, []), token);
        await Ananta.Server.Handlers.Game.WorldSwitch.NotifyClientAsync(ctx, result);

        return new
        {
            ok = true,
            raidId = result.RaidId,
            sceneId = result.SceneId,
            name = result.Name,
            detail = result.Detail,
            note = "已写 config.world 并下发 SyncTeleport(IsSwitchScene=true)。"
                 + "客户端会走跨场景加载；若没有自动重进，重新登录一次即可用新城市。",
        };
    }

    
    private static object WorldOptions()
    {
        var raids = Ananta.Server.State.ExtraCatalog.Raids
            .OrderBy(r => r.Id)
            .Select(r => new { id = r.Id, name = r.Name, sceneId = r.SceneId, countryId = r.CountryId })
            .ToList();

        return new
        {
            ok = true,
            shortcuts = new object[]
            {
                new { label = "新启市", raidId = Ananta.Server.Handlers.Game.WorldSwitch.NovaRaidId, sceneId = Ananta.Server.Handlers.Game.WorldSwitch.NovaSceneId },
                new { label = "重霄·凌云市", raidId = Ananta.Server.Handlers.Game.WorldSwitch.ChongxiaoRaidId, sceneId = Ananta.Server.Handlers.Game.WorldSwitch.ChongxiaoSceneId },
            },
            raids,
        };
    }

    
    
    
    
    
    
    
    
    
    
    private async Task<object> SwitchRaidAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint raidId = 0, universeId = 0;
        ulong instanceId = 0;
        float x = Profile.WorldSpawn.X,
              y = Profile.WorldSpawn.Y,
              z = Profile.WorldSpawn.Z,
              facing = Profile.WorldFacing;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (!root.TryGetProperty("raidId", out var pr) || (raidId = pr.GetUInt32()) == 0)
                return new { ok = false, error = "缺少 raidId" };
            if (!root.TryGetProperty("sceneInstanceId", out var psi) || (instanceId = psi.GetUInt64()) == 0)
                return new { ok = false, error = "缺少 sceneInstanceId" };
            if (!root.TryGetProperty("universeId", out var pu) || (universeId = pu.GetUInt32()) == 0)
                return new { ok = false, error = "缺少 universeId" };

            if (root.TryGetProperty("x", out var px)) x = (float)px.GetDouble();
            if (root.TryGetProperty("y", out var py)) y = (float)py.GetDouble();
            if (root.TryGetProperty("z", out var pz)) z = (float)pz.GetDouble();
            if (root.TryGetProperty("facing", out var pf)) facing = (float)pf.GetDouble();
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        var r = await Ananta.Server.Handlers.Game.WorldSwitchController.SwitchRaidAsync(
            session, raidId, instanceId, universeId, x, y, z, facing);

        if (!r.Ok)
            return new { ok = false, error = r.Error };

        return new
        {
            ok = true,
            raidId = r.RaidId,
            sceneInstanceId = r.InstanceId,
            universeId = r.UniverseId,
            x = r.X, y = r.Y, z = r.Z, facing = r.Facing,
            note = r.Note,
        };
    }

    
    
    
    
    
    
    
    
    private static object StoryDialogs(string? queryString)
    {
        
        var query = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        foreach (var pair in (queryString ?? string.Empty).TrimStart('?').Split('&', StringSplitOptions.RemoveEmptyEntries))
        {
            var eq = pair.IndexOf('=');
            if (eq <= 0) continue;
            query[Uri.UnescapeDataString(pair[..eq])] = Uri.UnescapeDataString(pair[(eq + 1)..]);
        }

        var keyword = query.TryGetValue("q", out var kw) ? kw : null;
        var limit = query.TryGetValue("limit", out var ls) && int.TryParse(ls, out var lv) ? lv : 300;

        bool? cutscene = query.TryGetValue("cutscene", out var cs)
            ? cs switch { "1" or "true" => true, "0" or "false" => false, _ => (bool?)null }
            : null;

        var rows = Ananta.Server.Handlers.Game.StoryDialogue
            .Search(keyword, cutscene, limit)
            .Select(x => new { id = x.Id, msg = x.Message, spk = x.Speaker, cam = x.CameraId, type = x.Type })
            .ToList();

        return new { ok = true, total = Ananta.Server.Handlers.Game.StoryDialogue.All.Count, count = rows.Count, dialogs = rows };
    }

    
    private async Task<object> StoryDialogPlayAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint dialogId = 0;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (doc.RootElement.TryGetProperty("dialogId", out var pd)) dialogId = pd.GetUInt32();
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        if (dialogId == 0) return new { ok = false, error = "缺少 dialogId" };

        await Ananta.Server.Handlers.Game.StoryDialoguePusher.PushDialogAsync(session, dialogId);
        var e = Ananta.Server.Handlers.Game.StoryDialogue.Find(dialogId);
        return new
        {
            ok = true,
            dialogId,
            message = e?.Message ?? string.Empty,
            speaker = e?.Speaker ?? string.Empty,
            note = e is null ? "（这条 id 不在索引里，仍然已下发，客户端会按自己的 DialogConfig 播）" : null,
        };
    }

    
    private async Task<object> StoryDialogVoiceAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint dialogId = 0;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (doc.RootElement.TryGetProperty("dialogId", out var pd)) dialogId = pd.GetUInt32();
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        if (dialogId == 0) return new { ok = false, error = "缺少 dialogId" };

        await Ananta.Server.Handlers.Game.StoryDialoguePusher.PushDialogVoiceAsync(session, dialogId);
        var e = Ananta.Server.Handlers.Game.StoryDialogue.Find(dialogId);
        return new { ok = true, dialogId, message = e?.Message ?? string.Empty, speaker = e?.Speaker ?? string.Empty };
    }

    
    
    
    
    
    
    
    
    
    
    
    private static object StoryTimelines(string? queryString)
    {
        var query = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        foreach (var pair in (queryString ?? string.Empty).TrimStart('?').Split('&', StringSplitOptions.RemoveEmptyEntries))
        {
            var eq = pair.IndexOf('=');
            if (eq <= 0) continue;
            query[Uri.UnescapeDataString(pair[..eq])] = Uri.UnescapeDataString(pair[(eq + 1)..]);
        }

        var keyword = query.TryGetValue("q", out var kw) ? kw : null;
        var kind = query.TryGetValue("kind", out var kd) ? kd : null;
        var group = query.TryGetValue("group", out var gp) ? gp : null;
        var limit = query.TryGetValue("limit", out var ls) && int.TryParse(ls, out var lv) ? lv : 300;

        var all = Ananta.Server.Handlers.Game.StoryTimeline.All;
        var rows = Ananta.Server.Handlers.Game.StoryTimeline
            .Search(keyword, kind, group, limit)
            .Select(x => new
            {
                id = x.Id,
                name = x.Name,
                group = x.Group,
                cinematic = x.IsCinematic,
                banSkip = x.BanSkip,
                banPause = x.BanPause,
                banSpeed = x.BanSpeed,
                control = x.PlayerControlType,
                blackScreen = x.ProcessBlackScreen,
                preload = x.NeedPreload,
                pauseAi = x.PauseAI,
            })
            .ToList();

        return new
        {
            ok = true,
            total = all.Count,
            cinematicTotal = all.Count(x => x.IsCinematic),
            count = rows.Count,
            channelReady = Ananta.Server.Handlers.Game.StoryTimelinePusher.ChannelReady,
            channelNote = Ananta.Server.Handlers.Game.StoryTimelinePusher.ChannelNote,
            timelines = rows,
        };
    }

    
    private object StorySwitchSpiritsRouter(string? queryString)
    {
        var query = ParseQuery(queryString);
        var keyword = query.TryGetValue("q", out var kw) ? kw : null;
        var playableOnly = !query.TryGetValue("all", out var al) || al != "1";
        var limit = query.TryGetValue("limit", out var ls) && int.TryParse(ls, out var lv) ? lv : 300;
        return StorySwitchSpirits(keyword, playableOnly, limit);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private async Task<object> StoryCinematicPlayAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint id = 0;
        string name = string.Empty;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (doc.RootElement.TryGetProperty("timelineId", out var pi) && pi.TryGetUInt32(out var iv))
                id = iv;
            if (doc.RootElement.TryGetProperty("id", out var pi2) && pi2.TryGetUInt32(out var iv2))
                id = iv2;
            if (doc.RootElement.TryGetProperty("name", out var pn) && pn.ValueKind == JsonValueKind.String)
                name = pn.GetString() ?? string.Empty;
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        Ananta.Server.Handlers.Game.StoryTimeline.Entry? entry = null;
        if (!string.IsNullOrWhiteSpace(name))
            entry = Ananta.Server.Handlers.Game.StoryTimeline.FindByName(name);
        if (entry is null && id != 0)
            entry = Ananta.Server.Handlers.Game.StoryTimeline.Find(id);

        if (entry is null)
        {
            return new
            {
                ok = false,
                timelineId = id,
                name,
                error = "TimelineConfig 里没有这条 timeline。",
                hint = "用 GET /api/story/timelines?kind=cinematic 查看可播清单。",
            };
        }

        
        var actorId = Ananta.Server.Handlers.Game.GameRouter.TryGetWorldState(session, out var ws)
            ? ws.ActiveSpiritUnitId
            : 0UL;

        var result = await Ananta.Server.Handlers.Game.StoryTimelinePusher.PlayCinematicAsync(
            session, entry, async (mid, body) => await session.NotifyAsync(mid, body, token));

        if (!result.Ok)
            return new { ok = false, timelineId = entry.Id, name = entry.Name, error = result.Error };

        return new
        {
            ok = true,
            timelineId = entry.Id,
            timeline = entry.Name,
            group = entry.Group,
            cinematic = entry.IsCinematic,
            banSkip = entry.BanSkip,
            pauseAi = entry.PauseAI,
            actorUnitId = actorId,
            channel = "SyncPlayTL (68508300) — 直传 timeline 名字",
            note = actorId == 0
                ? "⚠ 已下发 SyncPlayTL，但当前没有受控单位可绑定（actorIds 为空）—— "
                  + "客户端可能因绑不到 actor 而静默忽略。建议先换一次人再试。"
                : "已下发 SyncPlayTL（已把当前受控单位作为 actor 一并下发）。"
                  + "客户端 CutsceneManager 会实时演算播放这段运镜演出。",
        };
    }

    
    private static Dictionary<string, string> ParseQuery(string? queryString)
    {
        var query = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        foreach (var pair in (queryString ?? string.Empty).TrimStart('?').Split('&', StringSplitOptions.RemoveEmptyEntries))
        {
            var eq = pair.IndexOf('=');
            if (eq <= 0) continue;
            query[Uri.UnescapeDataString(pair[..eq])] = Uri.UnescapeDataString(pair[(eq + 1)..]);
        }
        return query;
    }

    
    
    
    private static object StoryTimelineGroups()
        => new { ok = true, groups = Ananta.Server.Handlers.Game.StoryTimeline.GroupSummary() };

    
    
    
    
    private object CinemaOverview()
        => new { ok = true, data = Ananta.Server.Handlers.Game.CinemaContent.Overview() };

    
    
    
    
    
    
    
    
    
    
    
    
    
    private async Task<object> StoryTimelinePlayAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint id = 0;
        uint switchConfigId = 0;
        uint targetSpiritId = 0;
        string name = string.Empty;
        
        var teleport = true;
        
        var skipPreSwitch = false;
        
        Ananta.Server.Handlers.Game.SwitchTeleportTiming? teleportTiming = null;
        
        int? apexDelayMs = null;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (doc.RootElement.TryGetProperty("timelineId", out var pi) && pi.TryGetUInt32(out var iv))
                id = iv;
            if (doc.RootElement.TryGetProperty("switchConfigId", out var ps) && ps.TryGetUInt32(out var sv))
                switchConfigId = sv;
            if (doc.RootElement.TryGetProperty("targetSpiritId", out var pt) && pt.TryGetUInt32(out var tv))
                targetSpiritId = tv;
            if (doc.RootElement.TryGetProperty("name", out var pn) && pn.ValueKind == JsonValueKind.String)
                name = pn.GetString() ?? string.Empty;
            if (doc.RootElement.TryGetProperty("teleport", out var pTp)
                && (pTp.ValueKind == JsonValueKind.True || pTp.ValueKind == JsonValueKind.False))
                teleport = pTp.GetBoolean();
            if (doc.RootElement.TryGetProperty("skipPreSwitch", out var pSk)
                && (pSk.ValueKind == JsonValueKind.True || pSk.ValueKind == JsonValueKind.False))
                skipPreSwitch = pSk.GetBoolean();
            
            if (doc.RootElement.TryGetProperty("teleportTiming", out var pTt))
            {
                if (pTt.ValueKind == JsonValueKind.String)
                {
                    teleportTiming = string.Equals(pTt.GetString()?.Trim(), "immediate", StringComparison.OrdinalIgnoreCase)
                        ? Ananta.Server.Handlers.Game.SwitchTeleportTiming.Immediate
                        : Ananta.Server.Handlers.Game.SwitchTeleportTiming.Apex;
                }
                else if (pTt.ValueKind == JsonValueKind.True)
                {
                    teleportTiming = Ananta.Server.Handlers.Game.SwitchTeleportTiming.Apex;
                }
                else if (pTt.ValueKind == JsonValueKind.False)
                {
                    teleportTiming = Ananta.Server.Handlers.Game.SwitchTeleportTiming.Immediate;
                }
            }
            if (doc.RootElement.TryGetProperty("apexDelayMs", out var pAd) && pAd.TryGetInt32(out var adv))
                apexDelayMs = adv;
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        
        
        if (switchConfigId == 0)
        {
            if (id != 0 && Ananta.Server.Handlers.Game.StoryTimeline.Find(id) is { } tlEntry)
                name = tlEntry.Name;

            if (!string.IsNullOrWhiteSpace(name)
                && Ananta.Server.Handlers.Game.StorySwitchConfig.FindByTimeline(name) is { } byName)
            {
                switchConfigId = byName.Id;
            }
        }

        
        
        if (switchConfigId != 0 && targetSpiritId == 0)
        {
            var authored = Ananta.Server.Handlers.Game.StorySwitchConfig.Find(switchConfigId);
            targetSpiritId = authored?.FirstFightSpiritId ?? 0;
        }

        
        if (switchConfigId == 0 && targetSpiritId == 0)
        {
            return new
            {
                ok = false,
                timelineId = id,
                name,
                error = string.IsNullOrWhiteSpace(name)
                    ? "请提供 switchConfigId（或在面板选一条切人动画），并指定 targetSpiritId。"
                    : $"timeline「{name}」不在 SwitchSpiritConfig 的播片清单里。",
                hint = "用 /api/story/switch-spirits 查看所有可播条目。",
            };
        }

        var target = ClientConfigRepository.Characters().FirstOrDefault(x => x.TemplateId == targetSpiritId);
        if (target is null)
        {
            return new
            {
                ok = false,
                switchConfigId,
                targetSpiritId,
                error = $"模板 {targetSpiritId} 不在可玩角色表里。",
            };
        }

        
        
        
        
        
        
        
        
        
        
        
        var result = await Ananta.Server.Handlers.Game.GameRouter.PlaySwitchTimelineAsync(
            session, switchConfigId, targetSpiritId,
            teleportToAnchor: teleport, skipPreSwitch: skipPreSwitch,
            teleportTiming: teleportTiming, apexDelayMs: apexDelayMs, token: token);

        var row = Ananta.Server.Handlers.Game.StorySwitchConfig.Find(result.SwitchConfigId);

        if (!result.Ok)
            return new { ok = false, switchConfigId, targetSpiritId, error = result.Error };

        return new
        {
            ok = true,
            requestedSwitchConfigId = switchConfigId,
            switchConfigId = result.SwitchConfigId,
            autoPicked = result.AutoPicked,
            timeline = result.Timeline,
            description = row?.Description,
            timelineDescription = row?.TimelineDescription,
            targetSpiritId,
            targetSpiritName = target.Name,
            teleported = result.Teleported,
            skippedPreSwitch = result.SkippedPreSwitch,
            teleportTiming = result.TeleportTiming,
            apexDelayMs = result.ApexDelayMs,
            distance = Math.Round(result.Distance, 2),
            origin = result.Origin is { } o ? new[] { o.X, o.Y, o.Z } : null,
            position = result.Anchor is { } a ? new[] { a.X, a.Y, a.Z } : null,
            place = result.Place,
            show = result.Show,
            companionAgentTemplateIds = result.AgentTemplateIds,
            companionAgentNames = result.AgentTemplateIds
                .Select(id => Ananta.Server.ClientData.Client4229938.AgentCatalogRepository.Find(id)?.Name ?? $"(未知 {id})")
                .ToList(),
            channel = "SwitchTeleport 原版流程复刻 (SyncPreSwitchSpirit + 完整身份交接 "
                + "+ ActorPresentation + BuffSnapshot + companionAgent spawn + SyncSwitchSpiritConfigId)",
            teleportPlan = result.TeleportTiming == "apex" && result.Teleported
                ? $"apex 传送：身份交接先落在玩家原位，等上升段播完（下发 SyncSwitchSpiritConfigId 后 "
                    + $"{result.ApexDelayMs}ms，对应「镜头已爬到高空、刚准备下降」）再把 unit 挪到锚点。"
                : "immediate 传送：在 SyncPreSwitchSpirit 时刻就传送（画面会瞬移，用于对比诊断）。",
            note = (result.Teleported
                ? (result.TeleportTiming == "apex"
                    ? $"目标 {target.Name} 先在玩家原位 ({result.Origin?.X:0.#},{result.Origin?.Y:0.#},{result.Origin?.Z:0.#}) 出现，"
                        + $"{result.ApexDelayMs}ms 后（镜头到高空将降时）送到锚点 "
                        + $"({result.Anchor?.X:0.#},{result.Anchor?.Y:0.#},{result.Anchor?.Z:0.#})，"
                        + $"距离 {result.Distance:0.#}m，播放演出「{result.Show}」。"
                    : $"已把玩家从 ({result.Origin?.X:0.#},{result.Origin?.Y:0.#},{result.Origin?.Z:0.#}) "
                        + $"传送到锚点 ({result.Anchor?.X:0.#},{result.Anchor?.Y:0.#},{result.Anchor?.Z:0.#})，"
                        + $"距离 {result.Distance:0.#}m，播放演出「{result.Show}」。")
                : $"未传送（锚点无效或已关闭），在玩家原位播放演出「{result.Show}」。")
                + (result.AgentTemplateIds.Count > 0
                    ? $" 本条演出 authored 了 {result.AgentTemplateIds.Count} 个同伴 agent，"
                        + "已先 spawn 并把 unitId 填进 spawnedAgentIds。"
                    : string.Empty),
        };
    }

    
    
    
    private static object StoryTargetSpirits()
    {
        var chars = ClientConfigRepository.Characters();
        return new
        {
            ok = true,
            count = chars.Count,
            spirits = chars.Select(x => new
            {
                templateId = x.TemplateId,
                name = x.Name,
                unitId = x.UnitId,
            }).ToList(),
        };
    }

    
    
    
    
    
    
    
    
    
    
    
    private object StorySwitchSpirits(string? keyword, bool playableOnly, int limit)
    {
        var rows = Ananta.Server.Handlers.Game.StorySwitchConfig.Search(keyword, playableOnly, limit);
        var all = Ananta.Server.Handlers.Game.StorySwitchConfig.All;
        var playable = Ananta.Server.Handlers.Game.StorySwitchConfig.Playable;

        
        var origin = Profile.WorldSpawn;
        var hasOrigin = false;
        if (hub.Current is { } session
            && Ananta.Server.Handlers.Game.GameRouter.TryGetWorldState(session, out var ws)
            && ws.HasLastReportedPlayerTransform)
        {
            origin = ws.LastReportedPlayerPosition;
            hasOrigin = true;
        }

        
        var distances = new Dictionary<uint, double>();
        foreach (var x in playable)
        {
            var dx = (double)x.PositionX - origin.X;
            var dz = (double)x.PositionZ - origin.Z;
            distances[x.Id] = Math.Sqrt(dx * dx + dz * dz);
        }
        var nearestId = distances.Count > 0
            ? distances.OrderBy(kv => kv.Value).ThenBy(kv => kv.Key).First().Key
            : 0u;

        return new
        {
            ok = true,
            total = all.Count,
            playableTotal = playable.Count,
            timelineTotal = playable.Select(x => x.Timeline).Distinct(StringComparer.Ordinal).Count(),
            count = rows.Count,
            playerPosition = hasOrigin ? new[] { origin.X, origin.Y, origin.Z } : null,
            playerPositionIsLive = hasOrigin,
            nearestSwitchConfigId = nearestId,
            channelReady = Ananta.Server.Handlers.Game.StoryTimelinePusher.ChannelReady,
            channelNote = Ananta.Server.Handlers.Game.StoryTimelinePusher.ChannelNote,
            rows = rows.Select(x => new
            {
                switchConfigId = x.Id,
                timeline = x.Timeline,
                description = x.Description,
                timelineDescription = x.TimelineDescription,
                switchType = x.SwitchType,
                raidId = x.RaidId,
                weight = x.Weight,
                invalid = x.Invalid,
                playable = x.Playable,
                fightSpiritIds = x.FightSpiritIds,
                defaultTargetSpiritId = x.FirstFightSpiritId,
                position = new[] { x.PositionX, x.PositionY, x.PositionZ },
                distance = distances.TryGetValue(x.Id, out var d) ? Math.Round(d, 1) : (double?)null,
                isNearest = x.Id == nearestId,
                
                
                agentIds = x.AgentIds,
                agentNames = x.AgentIds
                    .Select(a => Ananta.Server.ClientData.Client4229938.AgentCatalogRepository.Find(a)?.Name ?? $"(未知 {a})")
                    .ToList(),
                needsCompanionAgents = x.NeedsCompanionAgents,
            }).ToList(),
        };
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private async Task<object> WeatherSetAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        uint weatherId = 1, transition = 5;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (root.TryGetProperty("weatherId", out var pw)) weatherId = pw.GetUInt32();
            if (root.TryGetProperty("transition", out var pt)) transition = pt.GetUInt32();
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        if (!session.Items.TryGetValue(Ananta.Server.Handlers.Game.GameRouter.WorldStateKey, out var raw)
            || raw is not Ananta.Server.Protocol.Client4229938.WorldEntryState state)
            return new { ok = false, error = "没有世界状态（先登录进游戏）" };

        lock (state.SyncRoot)
        {
            state.WeatherId = weatherId;
            state.WeatherTransitionSeconds = transition;
            state.HasExplicitWeather = true;
        }

        await Ananta.Server.Handlers.Game.GameRouter.PushSessionWeatherAsync(session);
        session.Log.Info($"[DEBUG-API] 天气已切换 id={weatherId} transition={transition}s");

        var name = WeatherName(weatherId);
        return new { ok = true, weatherId, name, transition };
    }

    
    private static object WeatherOptions()
    {
        var rows = Ananta.Server.State.ExtraCatalog.Weathers
            .Select(w => new { id = w.Id, name = w.Name })
            .ToList();
        return new { ok = true, weathers = rows };
    }

    private static string WeatherName(uint id)
        => Ananta.Server.State.ExtraCatalog.Weathers.FirstOrDefault(w => w.Id == id)?.Name ?? $"id {id}";

    
    private static object BaselineSteps()
        => new
        {
            ok = true,
            steps = GameRouter.BaselineSteps.Select(x => new { key = x.Key, label = x.Label }).ToList(),
        };

    
    
    
    
    
    
    private async Task<object> BaselinePushAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        string step = string.Empty;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (doc.RootElement.TryGetProperty("step", out var ps) && ps.ValueKind == JsonValueKind.String)
                step = ps.GetString() ?? string.Empty;
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        if (string.IsNullOrWhiteSpace(step))
            return new { ok = false, error = "缺少 step 参数" };

        var error = await GameRouter.PushBaselineStepAsync(session, step);
        if (error is not null)
            return new { ok = false, error };

        var label = GameRouter.BaselineSteps.FirstOrDefault(
            x => string.Equals(x.Key, step, StringComparison.OrdinalIgnoreCase)).Label ?? step;
        return new { ok = true, step, label, note = $"已单独重发「{label}」（不含其它项）" };
    }

    private async Task<object> MapTeleportAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        float x = 0, y = 0, z = 0, facing = 0;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (root.TryGetProperty("x", out var px)) x = px.GetSingle();
            if (root.TryGetProperty("y", out var py)) y = py.GetSingle();
            if (root.TryGetProperty("z", out var pz)) z = pz.GetSingle();
            if (root.TryGetProperty("facing", out var pf)) facing = pf.GetSingle();
        }
        catch (Exception ex) { return new { ok = false, error = $"请求解析失败: {ex.Message}" }; }

        await PushAsync(session, MethodId.IGameToClient_SyncTeleport, new GameMethods.SyncTeleport4229938
        {
            teleportId = (ulong)DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(),
            Position = new Auto.UXVector3 { X = x, Y = y, Z = z },
            Facing = facing,
            IsSwitchScene = false,
            WaitTaskResource = false,
        }, token);

        SessionState.Update(st => { st.PositionX = x; st.PositionY = y; st.PositionZ = z; st.Facing = facing; });
        session.Log.Info($"[DEBUG-API] SyncTeleport -> ({x:F1}, {y:F1}, {z:F1}) facing={facing:F1}");
        return new { ok = true, x, y, z, facing };
    }

    

    
    
    
    
    
    
    
    private async Task<object> PushZoneGraphAsync(CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();

        var (bytes, intersectionCount, hex) = GameRouter.ProbeAetherInitBytes();
        var cfg = PrivateServerConfigStore.Current;
        var world = cfg.World;
        var pushed = await GameRouter.PushAetherVehiclesAsync(
            session, world.RaidId,
            world.Spawn.X, world.Spawn.Y, world.Spawn.Z, world.Facing,
            cfg.Gameplay.Vehicles.AetherVehicleCount, token);
        var crowd = await GameRouter.PushAetherCrowdAsync(
            session, world.Spawn.X, world.Spawn.Y, world.Spawn.Z,
            cfg.Gameplay.Aether.CrowdCount, token);
        var fixedNpcs = await GameRouter.PushFixedStaticNpcsAsync(
            session, world.Spawn.X, world.Spawn.Y, world.Spawn.Z,
            cfg.Gameplay.Aether.FixedNpcCount, token);

        return new
        {
            ok = true,
            message = "已重新下发初始化并按真实车道/行人路网投放车流、人群与固定 NPC",
            vehicles = pushed,
            crowd,
            fixedNpcs,
            initBytes = bytes,
            intersections = intersectionCount,
            hex,
        };
    }

    
    
    
    
    private async Task<object> SpawnAetherAtAsync(string body, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null) return NoSession();
        _ = body;

        var (bytes, intersectionCount, hex) = GameRouter.ProbeAetherInitBytes();
        float x, y, z;
        try
        {
            using var doc = System.Text.Json.JsonDocument.Parse(string.IsNullOrWhiteSpace(body) ? "{}" : body);
            var r = doc.RootElement;
            x = r.TryGetProperty("x", out var jx) ? jx.GetSingle() : PrivateServerConfigStore.Current.World.Spawn.X;
            y = r.TryGetProperty("y", out var jy) ? jy.GetSingle() : PrivateServerConfigStore.Current.World.Spawn.Y;
            z = r.TryGetProperty("z", out var jz) ? jz.GetSingle() : PrivateServerConfigStore.Current.World.Spawn.Z;
        }
        catch (Exception ex) { return new { ok = false, error = "坐标解析失败: " + ex.Message }; }

        var cfg2 = PrivateServerConfigStore.Current;
        var pushed2 = await GameRouter.PushAetherVehiclesAsync(
            session, cfg2.World.RaidId, x, y, z, cfg2.World.Facing,
            cfg2.Gameplay.Vehicles.AetherVehicleCount, token);
        var crowd2 = await GameRouter.PushAetherCrowdAsync(
            session, x, y, z, cfg2.Gameplay.Aether.CrowdCount, token);
        var fixedNpcs2 = await GameRouter.PushFixedStaticNpcsAsync(
            session, x, y, z, cfg2.Gameplay.Aether.FixedNpcCount, token);
        session.Log.Info($"[AETHER] 在 ({x:F0},{y:F0},{z:F0}) 投放 {pushed2} 台车 + {crowd2} 个人群"
                         + $" + {fixedNpcs2} 个固定 NPC");
        return new
        {
            ok = true,
            x, y, z,
            vehicles = pushed2,
            crowd = crowd2,
            fixedNpcs = fixedNpcs2,
            initBytes = bytes,
            intersections = intersectionCount,
            hex,
        };
    }

    
    private static object ProbeAetherInitBytes()
    {
        var (bytes, intersectionCount, hex) = GameRouter.ProbeAetherInitBytes();
        return new { ok = true, bytes, intersections = intersectionCount, hex };
    }

    
    private static object ProbeVehicleBytes()
    {
        var (bytes, hex) = GameRouter.ProbeVehicleBytes();
        return new { ok = true, actual = bytes, hex };
    }

    
    private static object ProbeCrowdBytes()
    {
        var (c, n) = GameRouter.ProbeCrowdBytes();
        return new
        {
            ok = true,
            crowd = new { actual = c, expected = 60, delta = c - 60, note = "59 数据 + 1 Complex 标记（按 Auto.WriteClientCrowdInitData）" },
            staticNpc = new { actual = n, expected = 83, delta = n - 83, note = "82 数据 + 1 Complex 标记" },
        };
    }

    

    
    
    
    
    
    
    
    
    
    

    

    
    
    
    
    
    
    
    private static object ContentSnapshot()
    {
        var saved = SessionState.Current;
        return new
        {
            money = saved.Money,
            gold = saved.Gold,
            bindingGold = saved.BindingGold,
            backpack = saved.Backpack
                .Where(kv => kv.Value > 0)
                .OrderBy(kv => kv.Key)
                .Select(kv => new { templateId = kv.Key, count = kv.Value })
                .ToList(),
            weapons = saved.Weapons
                .Select(w => new { instanceId = w.InstanceId, templateId = w.TemplateId, spiritId = w.SpiritId })
                .ToList(),
            fashions = saved.OwnedFashions.OrderBy(x => x).ToList(),
            currentTask = saved.CurrentTaskId,
            accountId = saved.AccountId,
            savedAt = saved.UpdatedAt,
        };
    }

    private static uint ResolveSpiritId(uint requested)
    {
        if (requested != 0)
            return requested;
        var first = GameCatalog.Characters.FirstOrDefault();
        return first?.TemplateId ?? 0;
    }

    

    
    
    
    
    
    
    
    
    private static object SpiritContentOverview(string? query)
    {
        var requested = ParseQueryUInt(query, "spiritId");
        if (requested != 0)
            return GameRouter.SpiritContentReport(requested);

        var rows = new List<object>();
        foreach (var character in GameCatalog.Characters)
        {
            var report = GameRouter.SpiritContentReport(character.TemplateId);
            rows.Add(report);
        }
        return new { count = rows.Count, spirits = rows };
    }

    
    
    
    
    
    
    
    
    
    private static object PhoneAppContentOverview()
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        var fakeFileSpirits = SpiritContentCatalogRepository.FakeFileSpiritIds
            .Select(spiritId => new
            {
                spiritId,
                name = SpiritContentCatalogRepository.Spirit(spiritId)?.Name,
                count = SpiritContentCatalogRepository.FakeFilesForSpirit(spiritId).Count,
                ids = SpiritContentCatalogRepository.FakeFilesForSpirit(spiritId).Select(x => x.Id).ToArray(),
            })
            .ToArray();

        return new
        {
            ok = true,
            hacker = new
            {
                enabled = settings.Enabled,
                hackerName = settings.HackerName,
                hackerRank = settings.HackerRank,
                unlockHackerPosts = settings.UnlockHackerPosts,
                hackerPostState = settings.HackerPostState,
                hackerPostsRead = settings.HackerPostsRead,
                postCount = SpiritContentCatalogRepository.AllHackerPosts.Count,
                posts = SpiritContentCatalogRepository.AllHackerPosts
                    .Select(p => new { p.Id, p.PostType, p.Title, p.Name }).ToArray(),
            },
            police = new
            {
                unlockPoliceFakeFiles = settings.UnlockPoliceFakeFiles,
                spirits = fakeFileSpirits,
                
                
                
                appContentEnabled = settings.PoliceAppContentEnabled,
                catalog = PoliceAppCatalog4229938.Summary(),
                appDispatches = PoliceAppCatalog4229938.AppDispatches
                    .Select(d => new { d.Id, d.Name, d.Number, d.ShowInApp }).ToArray(),
                caseSpecs = settings.PoliceCaseSpecs,
                caseDaysAgo = settings.PoliceCaseDaysAgo,
                fines = PoliceAppCatalog4229938.AllFines
                    .Where(f => f.IsShow)
                    .Select(f => new { f.Id, f.Title, f.Drop }).ToArray(),
            },
            hackerSyncProbe = ProbeHackerJobSync(),
            policeSyncProbe = ProbePoliceFakeFileSync(),
            policeAppProbe = ProbePoliceAppSync(),
        };
    }

    
    
    
    
    
    
    
    private static object ProbePoliceAppSync()
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        var cases = GameRouter.BuildPoliceCasesForProbe(settings);
        var dispatches = PoliceAppCatalog4229938.AppDispatches;

        var caseBytes = UxSerializer.Serialize(new GameMethods.SyncSpiritPoliceCaseInfos4229938
        {
            spiritId = GameRouter.FirstNccaSpiritId(),
            cases = cases,
        });
        var serviceBytes = UxSerializer.Serialize(new GameMethods.SyncPoliceServiceData4229938
        {
            spiritId = GameRouter.FirstNccaSpiritId(),
            serviceData = new GameMethods.PoliceServiceData4229938(),
            weeklyServiceData = new GameMethods.PoliceServiceData4229938(),
            stopPatrol = false,
        });
        var dispatchBytes = UxSerializer.Serialize(new GameMethods.SyncPoliceDispatchInfos4229938
        {
            spiritId = GameRouter.FirstNccaSpiritId(),
            dispatchInfos = dispatches.ToDictionary(
                d => d.Id,
                d => new GameMethods.PoliceDispatchInfo4229938 { Id = d.Id }),
        });

        return new
        {
            syncSpiritPoliceCaseInfos = new
            {
                methodId = MethodId.SyncSpiritPoliceCaseInfos,
                bytes = caseBytes.Length,
                hexHead = Convert.ToHexString(caseBytes.AsSpan(0, Math.Min(96, caseBytes.Length))),
                expect = "04×spiritId + FF(list7) + varint(n+1) + 每条 [FF + 17 字段]（reader=Auto.Reader[377]）",
                cases = cases.Count,
            },
            syncPoliceServiceData = new
            {
                methodId = MethodId.SyncPoliceServiceData,
                bytes = serviceBytes.Length,
                hexHead = Convert.ToHexString(serviceBytes.AsSpan(0, Math.Min(96, serviceBytes.Length))),
                expect = "04×spiritId + 30×serviceData + 30×weeklyServiceData + 01×stopPatrol = 65"
                    + "（reader=Auto.Reader[327]，TotalDrops 是 int32 计数）",
            },
            syncPoliceDispatchInfos = new
            {
                methodId = MethodId.SyncPoliceDispatchInfos,
                bytes = dispatchBytes.Length,
                hexHead = Convert.ToHexString(dispatchBytes.AsSpan(0, Math.Min(96, dispatchBytes.Length))),
                expect = "04×spiritId + FF(dict7) + varint(n+1) + (04×key + FF + 5 字段) ×n"
                    + "（reader=Auto.Reader[310]）",
                dispatches = dispatches.Count,
            },
        };
    }

    
    private static object ProbeHackerJobSync()
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        var info = new Auto.SpiritHackerJobInfo
        {
            HackerName = settings.HackerName ?? string.Empty,
            Rank = settings.HackerRank,
        };
        foreach (var post in SpiritContentCatalogRepository.AllHackerPosts)
        {
            info.PostInfos[post.Id] = new Auto.HackerPostInfo
            {
                Id = post.Id,
                State = settings.HackerPostState,
                HaveRead = settings.HackerPostsRead,
            };
        }

        var bytes = UxSerializer.Serialize(new GameMethods.SyncHackerJobInfo4229938
        {
            hackerJobInfo = info,
        });

        return new
        {
            methodId = MethodId.IGameToClient_SyncHackerJobInfo,
            methodName = "SyncHackerJobInfo",
            
            
            fields = "HackerName:string, PostInfos:Dict<u32,HackerPostInfo>(int32 count), Rank:u32",
            posts = info.PostInfos.Count,
            bytes = bytes.Length,
            hexHead = Convert.ToHexString(bytes.AsSpan(0, Math.Min(96, bytes.Length))),
        };
    }

    
    private static object ProbePoliceFakeFileSync()
    {
        var spiritId = SpiritContentCatalogRepository.FakeFileSpiritIds.FirstOrDefault();
        if (spiritId == 0)
            return new { methodId = MethodId.SyncPoliceFakeFileInfo, bytes = 0, note = "没有伪人档案配置" };

        var info = new Auto.PoliceFakeFileInfo();
        foreach (var row in SpiritContentCatalogRepository.FakeFilesForSpirit(spiritId))
        {
            info.UnlockFileInfoDict[row.Id] = new Auto.SinglePoliceFakeFileInfo
            {
                State = GameRouter.PoliceFakeFileStateUnlock,
                InterrogationTime = 0,
            };
        }

        var bytes = UxSerializer.Serialize(new GameMethods.SyncPoliceFakeFileInfo4229938
        {
            spiritId = spiritId,
            policeFakeFileInfo = info,
        });

        return new
        {
            methodId = MethodId.SyncPoliceFakeFileInfo,
            methodName = "SyncPoliceFakeFileInfo",
            fields = "spiritId:u32, PoliceFakeFileInfo{UnlockFileInfoDict:Dict<u32,"
                + "SinglePoliceFakeFileInfo{State:byte,InterrogationTime:u32}>(int32 count), "
                + "HistoryClueAgentInfoList:List<PoliceFakeClueAgentInfo>(int32 count)}",
            spiritId,
            files = info.UnlockFileInfoDict.Count,
            state = GameRouter.PoliceFakeFileStateUnlock,
            bytes = bytes.Length,
            hexHead = Convert.ToHexString(bytes.AsSpan(0, Math.Min(96, bytes.Length))),
        };
    }

    
    
    
    
    
    private async Task<object> PhoneAppContentPushAsync(CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return NoSession();

        await GameRouter.PushAllPhoneAppContentAsync(session);
        return new
        {
            ok = true,
            message = "已补推 SyncHackerJobInfo(64189208) + SyncPoliceFakeFileInfo(64618923)"
                + " + NCCA App 三件套（SyncSpiritPoliceCaseInfos 64848107 /"
                + " SyncPoliceServiceData 64502222 / SyncPoliceDispatchInfos 64393704），"
                + "详情看服务端日志 [PHONEAPP] 行。",
        };
    }

    

    
    
    
    
    
    
    
    
    
    
    private object JobAbilityOverview()
    {
        var session = hub.Current;

        var jobLevels = SpiritContentCatalogRepository.AllJobClasses
            .Select(c => new
            {
                jobClassId = c.Id,
                className = c.ClassName,
                systemUnlock = c.SystemUnlock,
                maxLevel = SpiritContentCatalogRepository.MaxJobLevelOf(c.Id),
                topJobId = SpiritContentCatalogRepository.TopJobLevelOf(c.Id),
                topJobName = SpiritContentCatalogRepository.JobLevel(
                    SpiritContentCatalogRepository.TopJobLevelOf(c.Id))?.Name,
                chain = SpiritContentCatalogRepository.JobLevelChain(c.Id)
                    .Select(x => $"{x.Id}({x.Name},Lv{x.Level})").ToArray(),
                levelTable = SpiritContentCatalogRepository.JobLevelConfigs(c.Id)
                    .Select(x => $"L{x.Level}:{x.Exp}").ToArray(),
            })
            .ToArray();

        var gameplayTrees = SpiritContentCatalogRepository.AllTalentTrees
            .Where(t => t.GameplayId != 0)
            .Select(t => new
            {
                treeId = t.Id,
                t.Name,
                gameplayId = t.GameplayId,
                nodes = SpiritContentCatalogRepository.TalentNodes(t.Id).Count,
            })
            .ToArray();

        var policeVehicles = VehicleCatalog4229938.PoliceVehicleIds
            .Select(id => new
            {
                id,
                name = VehicleCatalog4229938.TryGet(id, out var e) ? e.Name : "?",
                model = VehicleCatalog4229938.TryGet(id, out var e2) ? e2.Model : "?",
            })
            .ToArray();

        return new
        {
            ok = true,
            jobLevels,
            urbanAttribute = new
            {
                count = SpiritContentCatalogRepository.UrbanAttributeCount,
                maxValue = SpiritContentCatalogRepository.UrbanAttributeMaxValue,
                abilities = SpiritContentCatalogRepository.AllUrbanAbilities
                    .Select(a => new { a.Id, a.Name, a.AbilityType, a.MaxLevel }).ToArray(),
            },
            talents = new
            {
                totalNodes = SpiritContentCatalogRepository.AllTalentNodes.Count,
                gameplayTrees,
            },
            jobBoard = SpiritContentCatalogRepository.JobBoard
                .Select(b => new
                {
                    boardId = b.Id,
                    jobClassId = b.JobClassId,
                    b.JobTitle,
                    b.Salary,
                    b.CanResign,
                    relatedTask = b.RelatedTask,
                }).ToArray(),
            hacker = new
            {
                
                
                enableHack = PrivateServerConfigStore.Current.Gameplay.SpiritContent.HackTargetsEnabled,
                battery = new
                {
                    total = PrivateServerConfigStore.Current.Gameplay.SpiritContent.HackerBatteryTotal,
                    current = PrivateServerConfigStore.Current.Gameplay.SpiritContent.HackerBatteryCurrent,
                    note = "缺 SyncHackerBatteryCurrentAndTotalCount ⇒ hackInfo=nil ⇒ 点骇入被本地拦下",
                },
                registeredRpcs = new[]
                {
                    "AskHack", "AskHackVehicle", "AskHackingNpcPress", "AskHackingNpc",
                    "AskFinishHackingKeyFrame", "AskStartHackerTetris", "AskFinishHackerTetris",
                    "AskVehicleStartHackerAutonomousDriving", "AskVehicleStopHackerAutonomousDriving",
                    "AskHackerBetray", "ReportBeHacked", "ReportHackerTetrisCreation",
                },
                
                
                markVehiclesHackable = PrivateServerConfigStore.Current.Gameplay.SpiritContent.MarkVehiclesHackable,
                summonedVehicles = GameRouter.SummonedSnapshot().Count,
                policeVehicles = GameRouter.SpawnedPoliceVehicleIds().Count,
                lastHackableVehicleId = GameRouter.LastHackableVehicleId(),
                hackableChannel = "SyncUnitHackableState(68941159) —— 有 C# 实现；"
                    + "SyncVehicleHackableState(68037721) 本 build **无 C# 实现**，别发",
                hackableUnits = GameRouter.StreetNpcs().Count,
                
                
                
                
                
                
                
                
                hackerSpiritTemplateId =
                    PrivateServerConfigStore.Current.Gameplay.SpiritContent.HackerSpiritTemplateId,
                hackerAbilityBuffIds =
                    PrivateServerConfigStore.Current.Gameplay.SpiritContent.HackerAbilityBuffIds,
                hackerAbilityBuffCount =
                    PrivateServerConfigStore.Current.Gameplay.SpiritContent.HackerAbilityBuffIds.Length,
                hackerAbilityDelivery = "随单位的初始 buff 列表下发（SyncUnitBuffList）—— "
                    + "WebTraversal.CapabilityBuffIds(15021023)。"
                    + "SyncUnitAddBuff 只是兜底（见 GameRouter.GrantHackingAbilityBuffAsync）。",
                hackerBuffSource = "正式版由职业徽章授予（UrbanBadgeConfig.JobId=401："
                    + "19001102/19001103/19001108/19001109/19001110），徽章走 "
                    + "SyncUrbanBadgeInfo(64600925，LuaOnly) —— 私服不发，所以这些 buff 一条都没有。",
                hackerAppTools = GameRouter.HackerAppTools.Select(t => new
                {
                    t.Action,
                    t.Label,
                    t.Trigger,
                    t.Note,
                }).ToArray(),
                hackerAppToolsEndpoint = "POST /api/jobability/hack {\"action\":\"tools\"|\"grant-buffs\""
                    + "|\"spider\"|\"drone\"|\"blackout\"|\"forum\"|\"hackable-all\"}",
                streetNpcs = GameRouter.StreetNpcs()
                    .Take(20)
                    .Select(n => new { n.Id, n.Name, n.TemplateId, n.X, n.Y, n.Z }).ToArray(),
            },
            police = new
            {
                spawnedVehicleIds = GameRouter.SpawnedPoliceVehicleIds(),
                policeVehicleConfigs = policeVehicles,
                dispatchConfigIds = new[] { 1u, 2u, 3u, 4u },
            },
            truck = new
            {
                supported = new[]
                {
                    "AskGetTruckJobOrders", "AskRefreshTruckOrder", "AskGetAcceptedOrderWraps",
                    "AskGetFinishedOrderWraps", "AskQueryTruckPosInfo", "AskAutoAcceptTruckJobOrder",
                    "AskSetTruckJobDefaultVehicleId", "AskSettleTruckOrder", "AskObsoleteTruckJobOrder",
                    "AskResetTruckOrderGoods", "AskStartTruckOrderGuide", "AskGetTruckSatisfactionAverage",
                    "AskDoTruckNpcAction", "AskAddTruckOrderSpecialPointReward",
                },
                limited = new[]
                {
                    "AskAcceptTruckJobOrder / AskPreSettleTruckOrder —— 返回体是 TruckJobOrderWrap，"
                    + "本 build 字段表不可取证（IL2CPP metadata 里是空类、形状串被生成器截断），"
                    + "回 DefaultReturnCatalog 的中性包。",
                    "订单列表（ClientTruckOrderView.Orders）只能为空 —— 同上，"
                    + "伪造字段数不对的结构会让客户端 deserialize failed。",
                },
            },
            probe = new
            {
                syncHackerBattery = ProbeHackerBattery(),
                syncUnitHackableState = ProbeUnitHackable(),
                syncSpawnPoliceVehicles = ProbeSpawnPoliceVehicles(),
                syncDestroyPoliceVehicles = ProbeDestroyPoliceVehicles(),
                jobBoardInfo = ProbeJobBoardInfo(),
                truckOrderView = ProbeTruckOrderView(),
            },
            session = session is null ? "无会话" : "在线",
        };
    }

    
    
    
    
    
    
    private static object ProbeHackerBattery()
    {
        var sc = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        var bytes = GameRouter.BuildHackerBatteryBytes(sc.HackerBatteryTotal, sc.HackerBatteryCurrent);
        return new
        {
            methodId = MethodId.SyncHackerBatteryCurrentAndTotalCount,
            bytes = bytes.Length,
            hex = Convert.ToHexString(bytes),
            expect = "FF + 04×TotalCount + 04×CurrentCount = 9 字节（reader=Auto.Reader[362]）",
        };
    }

    private static object ProbeUnitHackable()
    {
        var bytes = UxSerializer.Serialize(new GameMethods.SyncUnitHackableState4229938
        {
            unitId = 500000000001UL,
            isHackable = true,
        });
        return new
        {
            methodId = MethodId.SyncUnitHackableState,
            bytes = bytes.Length,
            hex = Convert.ToHexString(bytes),
            expect = "08×unitId + 01（ulong + bool，共 9 字节）",
        };
    }

    private static object ProbeSpawnPoliceVehicles()
    {
        var bytes = UxSerializer.Serialize(new GameMethods.SyncSpawnPoliceVehicles4229938
        {
            spawnInfos =
            [
                new GameMethods.PoliceVehicleSpawnClientInfo
                {
                    Id = 700000000001UL,
                    VehicleId = 81004016,
                    Position = new Auto.UXVector3 { X = 1f, Y = 2f, Z = 3f },
                    Facing = 0.5f,
                    EulerAngles = new Auto.UXVector3 { X = 0f, Y = 0.5f, Z = 0f },
                },
            ],
            configInfo = new GameMethods.PoliceVehicleSpawnConfigInfo
            {
                ChaseRange = 60f,
                ChaseDirectlyRange = 25f,
                ApprehendRange = 6f,
                PatrolSpeed = 8f,
                ChaseSpeed = 16f,
                ChaseDirectlySpeed = 22f,
            },
        });
        return new
        {
            methodId = MethodId.SyncSpawnPoliceVehicles,
            bytes = bytes.Length,
            hexHead = Convert.ToHexString(bytes.AsSpan(0, Math.Min(64, bytes.Length))),
            expect = "FF + FF01 + [08×id + 04×vehicleId + 0C×pos + 04×facing + 0C×euler] + 24×config = 77 字节",
        };
    }

    private static object ProbeDestroyPoliceVehicles()
    {
        var bytes = UxSerializer.Serialize(new GameMethods.SyncDestroyPoliceVehicles4229938
        {
            entityIds = [700000000001UL],
        });
        return new
        {
            methodId = MethodId.SyncDestroyPoliceVehicles,
            bytes = bytes.Length,
            hex = Convert.ToHexString(bytes),
            expect = "FF + 01 + 08×id = 10 字节",
        };
    }

    private static object ProbeJobBoardInfo()
    {
        var bytes = UxSerializer.Serialize(new GameMethods.JobBoardInfo
        {
            JoinedJobCount = 1,
            MaxJobCount = 11,
            CountryJobEntries = new Dictionary<uint, GameMethods.JobBoardEntryList>
            {
                [1] = new GameMethods.JobBoardEntryList
                {
                    Entries =
                    [
                        new GameMethods.JobBoardEntry
                        {
                            BoardId = 1,
                            JobId = 11300008,
                            JobClassId = 11300008,
                            State = GameMethods.JobBoardJobState.Available,
                            CanResign = true,
                        },
                    ],
                },
            },
        });
        return new
        {
            methodId = MethodId.AskGetJobBoardInfo,
            bytes = bytes.Length,
            hexHead = Convert.ToHexString(bytes.AsSpan(0, Math.Min(64, bytes.Length))),
            expect = "FF + 04×joined + 04×max + FF01(dict7) + [04×key + FF + 04×boardId + 04×jobId "
                + "+ 04×jobClassId + 01×state + 04×progress + 04×target + 01×canResign + FF01] + FF01",
        };
    }

    private static object ProbeTruckOrderView()
    {
        var bytes = UxSerializer.Serialize(new GameMethods.ClientTruckOrderView
        {
            Orders = [],
            CustomerSatisfactionAverage = 100f,
            TruckGuideClicked = true,
        });
        return new
        {
            methodId = MethodId.AskGetTruckJobOrders,
            bytes = bytes.Length,
            hex = Convert.ToHexString(bytes),
            expect = "FF + FF01 + 00000000 + 0000C842(100f) + 00000000 + 01 + FF01 + 00 + 00000000 "
                + "+ 00000000 = 27 字节（与 DefaultReturnCatalog 的中性包同长）",
        };
    }

    
    
    
    
    private async Task<object> JobAbilityPushAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return NoSession();

        var action = "hackable";
        uint dispatchId = 2;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (root.TryGetProperty("action", out var a) && a.ValueKind == JsonValueKind.String)
                action = a.GetString() ?? "hackable";
            if (root.TryGetProperty("dispatchId", out var d)) d.TryGetUInt32(out dispatchId);
        }
        catch (JsonException ex)
        {
            return new { ok = false, error = $"JSON 解析失败: {ex.Message}" };
        }

        switch (action.ToLowerInvariant())
        {
            case "hackable":
                await GameRouter.PushHackableUnitsAsync(session, token);
                return new
                {
                    ok = true,
                    message = "已下发 SyncUnitHackableState，"
                        + $"当前服务端已知单位 = 街边 NPC {GameRouter.StreetNpcs().Count} 个 + 已召唤车辆",
                };

            case "hackable-vehicles":
                
                
                
                
                var marked = await GameRouter.RemarkAllVehiclesHackableAsync(session, token);
                return new
                {
                    ok = true,
                    message = $"已对 {marked} 辆车重发 SyncUnitHackableState(isHackable=true)",
                    summoned = GameRouter.SummonedSnapshot().Count,
                    policeVehicles = GameRouter.SpawnedPoliceVehicleIds().Count,
                    lastHackableVehicleId = GameRouter.LastHackableVehicleId(),
                };

            case "police":
                await GameRouter.SpawnPoliceVehiclesAsync(session, dispatchId, token);
                return new
                {
                    ok = true,
                    message = $"已下发 SyncSpawnPoliceVehicles（dispatch={dispatchId}），"
                        + $"当前警车 id=[{string.Join(",", GameRouter.SpawnedPoliceVehicleIds())}]",
                };

            case "police-clear":
                await GameRouter.DespawnPoliceVehiclesAsync(session, token);
                return new { ok = true, message = "已下发 SyncDestroyPoliceVehicles" };

            default:
                return new { ok = false, error = $"未知 action '{action}'（可选 hackable / police / police-clear）" };
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private async Task<object> JobAbilityHackAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return NoSession();

        var action = "tools";
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (doc.RootElement.TryGetProperty("action", out var a) && a.ValueKind == JsonValueKind.String)
                action = a.GetString() ?? "tools";
        }
        catch (JsonException ex)
        {
            return new { ok = false, error = $"JSON 解析失败: {ex.Message}" };
        }

        switch (action.ToLowerInvariant())
        {
            case "tools":
                
                return new
                {
                    ok = true,
                    note = "黑客 App 四条菜单的触发链路（来自客户端 Lua HackScriptFunc，非猜测）",
                    menuConfig = "客户端配置 HackerMenuConfig，服务端**加不了条目**",
                    runFunc = "HackAction.RunFunc(cfg.FuncAction) —— FuncAction 是 Lua 源码，被 load 后执行",
                    tools = GameRouter.HackerAppTools.Select(t => new
                    {
                        t.Action,
                        t.Label,
                        t.Trigger,
                        t.Note,
                    }).ToArray(),
                    serverSideLevers = new[]
                    {
                        "POST /api/jobability/hack {\"action\":\"grant-buffs\"} —— 强推整组骇入能力 buff（显示门控）",
                        "POST /api/jobability/hack {\"action\":\"spider\"} —— 推 SpiderStart(52800100) 触发 buff",
                        "POST /api/jobability/hack {\"action\":\"drone\"} —— 推 DroneStart(52800102) 触发 buff",
                        "客户端侧真实入口：点 App 条目 → UseSkillByPid(pid, 51938181 / 51938183)，服务端无法代点",
                    },
                };

            case "grant-buffs":
            case "grant-hacker-buffs":
            {
                var (sent, unitId, templateId, isHacker) =
                    await GameRouter.ForceGrantHackerBuffsAsync(session, token);
                var buffIds = PrivateServerConfigStore.Current.Gameplay.SpiritContent.HackerAbilityBuffIds;
                return new
                {
                    ok = sent > 0,
                    message = sent > 0
                        ? $"已强推 {sent} 条骇入能力 buff（unit={unitId} template={templateId} isHacker={isHacker}）"
                        : "没有活跃单位（客户端还没进世界？）",
                    unitId,
                    templateId,
                    isHacker,
                    expectedHackerTemplateId =
                        PrivateServerConfigStore.Current.Gameplay.SpiritContent.HackerSpiritTemplateId,
                    buffIds,
                    hint = isHacker
                        ? "已推齐。客户端 HasGlobalHackBuff() 查的是 52606133；"
                            + "GetUnitHackBtns 还会逐技能查 HackerConfig.HackNPCAbilityBuff 的 8 条。"
                        : $"⚠️ 当前角色 template={templateId} 不是黑客（{PrivateServerConfigStore.Current.Gameplay.SpiritContent.HackerSpiritTemplateId}）"
                            + "，骇入能力本就不该生效 —— 先切到赛默再试。",
                };
            }

            case "spider":
            case "drone":
            {
                var (buffId, label, skillId) = action.Equals("spider", StringComparison.OrdinalIgnoreCase)
                    ? (GameRouter.SpiderStartBuffId, "Spider Bot 蜂形机器人", GameRouter.SpiderBotSkillId)
                    : (GameRouter.DroneStartBuffId, "Hacker Drone 黑客无人机", GameRouter.HackerDroneSkillId);

                var (ok, unitId, instanceId) = await GameRouter.TriggerBuffAsync(session, buffId, token);
                return new
                {
                    ok,
                    tool = label,
                    triggerBuff = buffId,
                    instanceId,
                    unitId,
                    clientSkillId = skillId,
                    message = ok
                        ? $"已推触发 buff {buffId}（{label}）到 unit={unitId}"
                        : "没有活跃单位（客户端还没进世界？）",
                    note = "这是**第二条路**：客户端自己的入口是点 App 条目 → "
                        + $"UseSkillByPid(pid, {skillId})，那是客户端 API，服务端无法代替点击。"
                        + "如果触发 buff 没反应，请先确认 App 里这条目已出现（需要入口 buff "
                        + $"{(action.Equals("spider", StringComparison.OrdinalIgnoreCase) ? 52606149 : 52606150)}），再点它。",
                };
            }

            case "blackout":
                return new
                {
                    ok = false,
                    tool = "大停电",
                    error = "本 build 的 App 里**没有**可点的入口 —— HackerMenuConfig.Id=4 的 FuncAction 是空字符串",
                    why = "HackAction.RunFunc(\"\") → load(\"\") 得到空函数体 ⇒ 点击什么都不发生",
                    realImplementation = new
                    {
                        talent = "TalentTreeTalentConfig.Id=99906106（JobRequest=401 黑客、NeedActive=true）"
                            + "「可以骇入电网造成1分钟的大停电，使周围行人陷入恐慌…」",
                        creation = "CreationConfig.Id=56860922『【黑客】大停电-范围干扰』"
                            + "（= HackerConfig.HackerTetris_CreationId，俄罗斯方块小游戏的产物）",
                    },
                    serverSide = "菜单是**客户端配置**，服务端加不了条目；"
                        + "天赋侧由 spiritContent.unlockAllJobTalents / jobTalentPoint 解锁（已开）。",
                };

            case "forum":
            {
                await GameRouter.PushHackerJobInfoAsync(session);
                return new
                {
                    ok = true,
                    message = "已重推 SyncHackerJobInfo（含 HackerPostConfig 的 20 条帖子）"
                        + " —— EonBug Forum 面板（PanelId=703）的内容就来自它",
                };
            }

            case "hackable-all":
            {
                var vehicles = await GameRouter.RemarkAllVehiclesHackableAsync(session, token);
                await GameRouter.PushHackableUnitsAsync(session, token);
                return new
                {
                    ok = true,
                    message = $"已重标 {vehicles} 辆车 + 街边 NPC {GameRouter.StreetNpcs().Count} 个",
                    aetherNpcs = "Aether 人群/固定 NPC 的可骇入性来自 ClientStaticNpcInitData.EnableHack"
                        + "（spiritContent.hackTargetsEnabled），不走 SyncUnitHackableState",
                };
            }

            default:
                return new
                {
                    ok = false,
                    error = $"未知 action '{action}'",
                    allowed = new[] { "tools", "grant-buffs", "spider", "drone", "blackout", "forum", "hackable-all" },
                };
        }
    }

    

    
    
    
    
    
    
    
    
    
    
    
    private object SocialAppOverview()
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SocialApp;
        var posts = GameRouter.BuildSocialPostList();
        var bytes = UxSerializer.Serialize(posts);

        return new
        {
            ok = true,
            app = "Bubble（叭叭）= MobileMenuSGuiConfig.Id 12，GuideId = BaBoGuide，"
                + "NpcCultivationIdList = [91050025, 91050026]（男主/女主）",
            enabled = settings.Enabled,
            catalog = GameRouter.SocialAppSummary(),
            transport = "UX-RPC：AskMomentsPostSimpleInfos(63452251) / AskMomentsPostInfos(63879443) "
                + "→ List7Bit<PostSimpleClientInfo>（每项带 0xFF Complex 标记）",
            builtPostCount = posts.Count,
            wire = new
            {
                methodId = MethodId.AskMomentsPostSimpleInfos,
                bytes = bytes.Length,
                head = Convert.ToHexString(bytes.AsSpan(0, Math.Min(64, bytes.Length))),
                layout = "FF(列表非空标记) + Int7(count) + 每项[ FF + 18 字段 ]",
                fields = "Id:u32, PostType:u8, PostConfigId:u32(=SocialMediaConfig.Id), Date:u32, "
                    + "ImageUrl:str, Approved:bool, Title:str, Likes:u32, Liked:bool, "
                    + "LikeNpcs:List7<u32>, Comments:List7<u32>, PlayerComments:List7<complex>, "
                    + "IsRead:bool, HasNewLike:bool, AcquireCfgId:u32, ActivityCfgId:u32, "
                    + "IsStory:bool, IsPinStory:bool",
            },
            firstPosts = posts.Take(5).Select(p => new
            {
                p.Id,
                p.PostType,
                p.PostConfigId,
                p.Date,
                p.Likes,
                p.Liked,
                p.IsRead,
                p.IsStory,
                p.IsPinStory,
                comments = p.Comments.Count,
            }).ToArray(),
            eyeApp = new
            {
                name = "眼界 / Scope = MobileMenuSGuiConfig.Id 17，GuideId = TwitterGuide，SystemIdList = [115]",
                transport = "☠️ **不是 UX-RPC** —— 走 HTTP REST："
                    + "gCS.LuaUtils.GetGraffitoUrl() + /social_media/api/moment/recc_list 等",
                endpoints = new[]
                {
                    "/social_media/api/moment/recc_list?{page}&{pageSize}&{menuTuiteType}",
                    "/social_media/api/moment/follow_list?{page}&{pageSize}",
                    "/social_media/api/moment/detail?{momentId}",
                    "/social_media/api/comment/list?{momentId}&{page}&{pageSize}",
                    "/social_media/api/trend/list?{areaId}&{page}&{pageSize}",
                    "/social_media/api/follow/add|delete",
                },
                note = "响应体要求 {code:0, data:[...]}；本项目没实现该 HTTP 服务，"
                    + "所以眼界（以及走同一套 REST 的界面）仍然是空的。",
            },
            npcSchedule = BuildNpcScheduleOverview(),
        };
    }

    
    
    
    
    
    
    
    private object BuildNpcScheduleOverview()
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.SocialApp;
        var table = GameRouter.BuildNpcTimeTableInfos();
        var bytes = table.Count > 0
            ? UxSerializer.Serialize(new GameMethods.SyncFavorNpcTimeTableInfos4229938
            {
                timeTableInfos = table,
            })
            : [];

        var sample = table.Take(1).Select(kv => new
        {
            agentTag = kv.Key,
            slots = new[]
            {
                kv.Value.Schedule0, kv.Value.Schedule1, kv.Value.Schedule2,
                kv.Value.Schedule3, kv.Value.Schedule4,
            }.Select(s => s is null ? null : new
            {
                s.ActivityId,
                s.StartDaySecond,
                s.EndDaySecond,
                startHhmm = $"{s.StartDaySecond / 3600:D2}:{s.StartDaySecond % 3600 / 60:D2}",
                endHhmm = $"{((s.EndDaySecond % 86400) + 86400) % 86400 / 3600:D2}:{((s.EndDaySecond % 86400) + 86400) % 86400 % 3600 / 60:D2}",
                s.RaidId,
            }).ToArray(),
        }).ToArray();

        return new
        {
            enabled = settings.Enabled && settings.SendNpcSchedule,
            catalog = NpcScheduleCatalogRepository4229938.Summary(),
            transport = "S2C Notify：SyncFavorNpcTimeTableInfos(64219939) = "
                + "Dict7Bit<agentTag, NpcTimeTableInfo>（**Int7 计数**，不是 Int32）",
            builtAgentCount = table.Count,
            wireBytes = bytes.Length,
            layout = "FF(字典非空) + Int7(角色数) + 每个角色[ u32 agentTag + FF + 5×[FF+日程] + "
                + "int32 CurrentSpoonAgentId + UXVector3(无标记) + FF/00 TempSchedule + bool + int64 RefreshDay ]",
            timeSource = "AgentDataSetsTimeTableConfig.Schedule1..4 是 **HHMM 整数**"
                + "（800 = 08:00，1200 = 12:00，1700 = 17:00，2200 = 22:00）",
            activitySource = "AgentDataSetsActivityConfig.Schedule=[{Index,Priority}] ⇒ 槽位→活动；"
                + "ActivityId=0 的时段客户端会当空档过滤",
            sample,
            note = "5 段窗口照客户端 OnSyncNpcTimeTableInfos 的 wrap 修正铺："
                + "Schedule0=[S4-86400,S1)、Schedule1..3=[S1,S2)/[S2,S3)/[S3,S4)、"
                + "Schedule4=[S4,S1+86400) ⇒ 无缝覆盖 24h。",
        };
    }

    
    private object SocialAppReset()
    {
        var before = new
        {
            read = SessionState.Current.SocialReadPosts.Count,
            liked = SessionState.Current.SocialLikedPosts.Count,
            comments = SessionState.Current.SocialPlayerComments.Count,
        };
        SessionState.Update(s =>
        {
            s.SocialReadPosts.Clear();
            s.SocialLikedPosts.Clear();
            s.SocialPlayerComments.Clear();
        });
        return new { ok = true, message = "已清空社交 App 个人状态（已读 / 点赞 / 我的评论）", before };
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private object SocialMediaApiProbe(System.Net.HttpListenerRequest request, string path)
    {
        var query = request.Url?.Query ?? string.Empty;
        var body = string.Empty;
        try
        {
            if (request.HasEntityBody)
            {
                using var reader = new StreamReader(request.InputStream, request.ContentEncoding);
                body = reader.ReadToEnd();
            }
        }
        catch
        {
            
        }

        Console.WriteLine($"[SOCIAL][GRAFFITO] {request.HttpMethod} {path}{query}"
            + (body.Length > 0 ? $" body={body}" : string.Empty));

        
        
        return new
        {
            code = 0,
            data = Array.Empty<object>(),
            _probe = new
            {
                path,
                query,
                note = "探针：已记录该端点。响应体形状待按客户端 RefreshCommonMomentItem 读的字段补齐。",
            },
        };
    }

    
    
    
    
    
    private async Task<object> SpiritJobSetAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return NoSession();

        uint spiritId = 0, jobClassId = 0;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (root.TryGetProperty("spiritId", out var s)) s.TryGetUInt32(out spiritId);
            if (root.TryGetProperty("jobClassId", out var j)) j.TryGetUInt32(out jobClassId);
            if (jobClassId == 0 && root.TryGetProperty("jobId", out var jid) && jid.TryGetUInt32(out var levelId))
                jobClassId = SpiritContentCatalogRepository.JobLevel(levelId)?.JobClass ?? 0;
        }
        catch (JsonException ex)
        {
            return new { ok = false, error = $"JSON 解析失败: {ex.Message}" };
        }

        if (spiritId == 0)
            spiritId = ActiveSpiritTemplateId(session);
        if (jobClassId == 0)
            return new { ok = false, error = "需要 jobClassId（职业大类，例 11300003 = NCCA Officer）或 jobId" };

        var settings = PrivateServerConfigStore.Current.Gameplay.SpiritContent;
        
        var entry = settings.MaxJobLevel && settings.JobTopTier
            ? SpiritContentCatalogRepository.TopJobLevelOf(jobClassId)
            : SpiritContentCatalogRepository.EntryJobLevelOf(jobClassId);
        if (entry == 0)
            entry = SpiritContentCatalogRepository.EntryJobLevelOf(jobClassId);
        if (entry == 0)
            return new { ok = false, error = $"职业大类 {jobClassId} 没有入门等级配置" };

        SessionState.Update(s =>
        {
            if (!s.SpiritJobs.TryGetValue(spiritId, out var list))
                s.SpiritJobs[spiritId] = list = [];
            if (!list.Contains(entry))
                list.Add(entry);
            s.CurrentSpiritJob[spiritId] = entry;
        });

        await GameRouter.PushJobInfoAsync(session, spiritId);
        await GameRouter.PushJobSystemsAsync(session, jobClassId);

        var cls = SpiritContentCatalogRepository.JobClass(jobClassId);
        return new
        {
            ok = true,
            message = $"角色 {spiritId} 已安排职业 {entry}（{SpiritContentCatalogRepository.JobLevel(entry)?.Name} / "
                + $"{cls?.ClassName}），已下发 SyncSpiritJobInfo + 系统解锁 {cls?.SystemUnlock}",
            spiritId,
            jobId = entry,
            jobClassId,
            apps = SpiritContentCatalogRepository.AppsForSpirit(spiritId)
                .Select(a => new { a.Id, a.Name }).ToArray(),
        };
    }

    private static uint ParseQueryUInt(string? query, string key)
    {
        if (string.IsNullOrWhiteSpace(query))
            return 0;
        foreach (var pair in query.TrimStart('?').Split('&', StringSplitOptions.RemoveEmptyEntries))
        {
            var eq = pair.IndexOf('=');
            if (eq <= 0)
                continue;
            if (!pair.AsSpan(0, eq).Equals(key, StringComparison.OrdinalIgnoreCase))
                continue;
            return uint.TryParse(pair[(eq + 1)..], out var v) ? v : 0u;
        }
        return 0;
    }

    
    
    
    
    
    
    
    
    
    
    private async Task<object> SpiritTalentSetAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return NoSession();

        uint spiritId = 0, jobClassId = 0, talentId = 0, layer = 0, points = 0;
        var hasPoints = false;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            if (root.TryGetProperty("spiritId", out var s)) s.TryGetUInt32(out spiritId);
            if (root.TryGetProperty("jobClassId", out var j)) j.TryGetUInt32(out jobClassId);
            if (root.TryGetProperty("talentId", out var t)) t.TryGetUInt32(out talentId);
            if (root.TryGetProperty("layer", out var l)) l.TryGetUInt32(out layer);
            if (root.TryGetProperty("points", out var p) && p.TryGetUInt32(out points))
                hasPoints = true;
        }
        catch (JsonException ex)
        {
            return new { ok = false, error = $"JSON 解析失败: {ex.Message}" };
        }

        if (spiritId == 0)
            spiritId = ActiveSpiritTemplateId(session);

        var resolvedJobClass = jobClassId;
        if (resolvedJobClass == 0)
        {
            var row = SpiritContentCatalogRepository.Spirit(spiritId);
            resolvedJobClass = row is null ? 0u : SpiritContentCatalogRepository.DefaultJobClass(row);
        }

        SessionState.Update(s =>
        {
            if (hasPoints)
                s.SpiritJobTalentPoints[spiritId] = points;

            if (talentId != 0)
            {
                if (!s.SpiritJobTalents.TryGetValue(spiritId, out var dict))
                    s.SpiritJobTalents[spiritId] = dict = new Dictionary<uint, uint>();
                dict[talentId] = layer == 0 ? 1u : layer;
            }
        });

        if (hasPoints)
            await PushAsync(session, MethodId.SyncSpiritJobTalentPoint,
                new GameMethods.SyncSpiritJobTalentPoint4229938
                {
                    spiritId = spiritId,
                    jobClassId = resolvedJobClass,
                    talentPoint = points,
                    reason = 0,
                }, token);

        if (talentId != 0)
            await PushAsync(session, MethodId.SyncActiveSpiritJobTalentLayer,
                new GameMethods.SyncActiveSpiritJobTalentLayer4229938
                {
                    spiritId = spiritId,
                    jobClassId = resolvedJobClass,
                    talentId = talentId,
                    layer = layer == 0 ? 1u : layer,
                }, token);

        await GameRouter.PushJobInfoAsync(session, spiritId);

        var node = SpiritContentCatalogRepository.TalentNodes(
                SpiritContentCatalogRepository.TalentTreesFor(spiritId).FirstOrDefault(t => t.JobClassId == resolvedJobClass)?.Id ?? 0)
            .FirstOrDefault(n => n.Id == talentId);

        return new
        {
            ok = true,
            spiritId,
            jobClassId = resolvedJobClass,
            points = hasPoints ? points : (uint?)null,
            talentId = talentId == 0 ? (uint?)null : talentId,
            talentName = node?.Name,
            message = "已写入存档并下发 SyncSpiritJobTalentPoint / SyncActiveSpiritJobTalentLayer / SyncSpiritJobInfo",
        };
    }

    
    
    
    
    
    
    private object SpiritInstalledAppsAsync(string json, CancellationToken token)
    {
        _ = token;
        var session = hub.Current;
        if (session is null)
            return NoSession();

        List<uint>? add = null, remove = null, set = null;
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            var root = doc.RootElement;
            add = ReadUIntList(root, "add");
            remove = ReadUIntList(root, "remove");
            set = ReadUIntList(root, "set");
        }
        catch (JsonException ex)
        {
            return new { ok = false, error = $"JSON 解析失败: {ex.Message}" };
        }

        SessionState.Update(s =>
        {
            if (set is not null)
                s.InstalledApps = [.. set.Where(x => x != 0).Distinct().OrderBy(x => x)];
            foreach (var id in add ?? [])
                if (id != 0 && !s.InstalledApps.Contains(id))
                    s.InstalledApps.Add(id);
            foreach (var id in remove ?? [])
                s.InstalledApps.RemoveAll(x => x == id);
        });

        var now = SessionState.Current.InstalledApps;
        return new
        {
            ok = true,
            installedApps = now,
            message = "已写入存档。重登（或重进世界）后由登录包 PlayerClientInfoSpirit.InstalledApps 恢复；"
                + "客户端**没有** SyncPlayerMobileAppChanged 的处理器，所以运行中不会即时刷新。",
            known = now
                .Select(id => SpiritContentCatalogRepository.App(id))
                .Where(a => a is not null)
                .Select(a => new { a!.Id, a.Name, a.IsInAppStore }),
        };
    }

    private static List<uint>? ReadUIntList(JsonElement root, string name)
    {
        if (!root.TryGetProperty(name, out var node) || node.ValueKind != JsonValueKind.Array)
            return null;
        return node.EnumerateArray()
            .Where(x => x.TryGetUInt32(out _))
            .Select(x => x.GetUInt32())
            .ToList();
    }

    private static uint ActiveSpiritTemplateId(TcpSession session)
    {
        if (session.Items.TryGetValue(GameRouter.WorldStateKey, out var raw) && raw is WorldEntryState state)
        {
            lock (state.SyncRoot)
                if (state.ActiveSpiritTemplateId != 0)
                    return state.ActiveSpiritTemplateId;
        }
        return GameCatalog.Characters.FirstOrDefault()?.TemplateId ?? 0;
    }

    private static Task PushAsync<T>(TcpSession session, uint methodId, T body, CancellationToken token)
        => session.NotifyAsync(methodId, UxSerializer.Serialize(body), token);

    private static string OrEmpty(string? json) => string.IsNullOrWhiteSpace(json) ? "{}" : json!;

    private static object NoSession()
        => new { ok = false, error = "客户端不在游戏中（没有活动会话）" };

    

    
    
    
    
    
    
    
    private object BlackoutInfo()
    {
        var s = PrivateServerConfigStore.Current.Gameplay.HackerBlackout;
        return new
        {
            ok = true,
            what = "黑客（西摩 / JobRequest=401）的**俄罗斯方块小游戏**，玩完生成一个半径 100 的"
                + "「【黑客】大停电-范围干扰」创造物",
            config = new
            {
                playTime = "HackerConfig.HackerTetris_PlayTime = 60（小游戏 60 秒）",
                dropLimit = "HackerTetris_DropLimit = 50",
                clearPoints = "HackerTetris_ClearPoints1..4 = 100/400/800/1600",
                actionStatus = "HackerTetris_ActionStatus = 156",
                creationId = $"HackerTetris_CreationId = {s.CreationId}"
                    + "（CreationConfig「【黑客】大停电-范围干扰」）",
                range = $"HackerTetris_Range = {s.Range}",
                darkLight = "HackerTetris_CreationId_Dark / _Light = [56860922]（两个都是它）",
            },
            triggerChain = new[]
            {
                "① 天赋 TalentTreeTalentConfig.Id = 99906106「大停电」"
                    + "（JobRequest=401 / NeedActive=true / PreTalentIds=[99906204] / LayerNum=1）"
                    + "  —— 描述：「可以骇入电网造成1分钟的大停电，使周围行人陷入恐慌，"
                    + "敌人感知与行动能力大幅下降一段时间」",
                "② 骇入**电网**对象（世界里一个特定的位置）",
                "③ ★ Spoon 剧情节点 PlayHackerTetrisNode.DoAction()"
                    + "（L50.Spoon.SpoonRunTime，SpoonSerializerData(1932)）",
                "   · replaceEffectIds / replaceEffectNames —— 把场景灯光**换成停电特效**",
                "   · expandingLightDisableBoxId —— ★ **扩张关灯盒**（盒子扩张=一片片灭灯=「全城停电」）",
                "   · lookAtPivotId —— 镜头/朝向定位点（用户说的「特定的位置」）",
                "④ 小游戏 UI（客户端 Lua）→ AskStartHackerTetris(63521495)",
                "⑤ 玩完 → AskFinishHackerTetris(63554976, score)",
                "⑥ ReportHackerTetrisCreation(67652382)",
                "⑦ 生成 Creation 56860922（半径 100）",
            },
            siblingTalents = new[]
            {
                "99906107「游戏植入」：「触发大停电后，于**千集条商业街的入口**可骇入其广告屏，"
                    + "进行游戏游玩」← 直接印证「在一个特定的位置」",
                "99906108「大停电强化」：「大停电的持续时间增加 30 秒」",
            },
            whyServerCannotFixVisual = new[]
            {
                "「全城停电」的**画面**是 Spoon 节点 + 场景对象做的：",
                "  灯光替换 = PlayHackerTetrisNode.replaceEffectIds（节点上配的资产引用）",
                "  灭灯扩散 = ExpandingLightDisableBox（节点用 ComponentLinkId 绑的场景对象）",
                "创造物 56860922 只提供**游戏效果**（范围干扰 / 敌人感知下降），**不带演出**。",
                "⇒ 服务端**没有任何一条 S2C 能让客户端播停电**。",
                "而且 PlayHackerTetrisNode.DoAction() 是 **IFix 打过补丁**的"
                    + "（dump 里是 <>iFixBaseProxy_DoAction）⇒ 方法体在 Lua 里，CBT3 的客户端 Lua 拿不到。",
            },
            serverCanDo = new[]
            {
                "① 补齐前置条件：激活天赋 99906106（SyncActiveSpiritJobTalentLayer 64444711）"
                    + " + 下发能力 buff 52606170「黑客-俄罗斯方块大停电能力」（SyncUnitAddBuff 68596304）。"
                    + " 补齐后，**只要客户端跑到那个 Spoon 节点**，链路就能通。",
                "② 直接生成创造物：SyncAddCreation(68413195) 客户端实现了"
                    + "（midToExportOption=LuaAndCSharp，reader=Base.ReadStruct(Auto.Reader[425])）。"
                    + " 在玩家位置生成 56860922 ⇒ 至少「范围干扰」的游戏效果会出现。",
                "③ 触发入口探测：HackerMenuConfig.Id=4「大停电」是**空壳行**"
                    + "（FuncAction=\"\" / BuffID=0 / Image=0 / GuideId=\"\"）"
                    + "⇒ 千年虫 App 里**不会**出现「大停电」按钮，服务端也加不了条目（菜单是客户端配置）。",
            },
            answer = new
            {
                游戏内能触发吗 = "能，但前提是客户端 Spoon 图跑到 PlayHackerTetrisNode。"
                    + "私服没做任务/剧情链的话，这个节点不会被执行。",
                后台按钮能触发吗 = "能，但只能做「补前置条件 + 生成创造物」两件事，"
                    + "**不能替客户端播放停电演出**（演出在 Spoon 节点 + 场景对象里）。",
                游戏能否修复 = "「范围干扰」的游戏效果可以修（本端点 spawn）；"
                    + "「全城停电」的视觉演出需要客户端 Spoon 图配合，服务端无法单独实现。",
            },
            endpoints = new
            {
                info = "GET /api/hacker/blackout —— 本分析",
                prerequisites = "POST {\"action\":\"prerequisites\"} —— 激活天赋 + 下发能力 buff",
                spawn = "POST {\"action\":\"spawn\"} —— 在玩家位置生成创造物 56860922",
                all = "POST {\"action\":\"all\"} —— 前置条件 + 创造物",
            },
            settings = new
            {
                s.Enabled, s.CreationId, s.Range, s.TalentId, s.CapabilityBuffId, s.JobClassId,
            },
        };
    }

    
    
    
    
    
    private async Task<object> BlackoutTriggerAsync(string json, CancellationToken token)
    {
        var session = hub.Current;
        if (session is null)
            return NoSession();

        var action = "info";
        try
        {
            using var doc = JsonDocument.Parse(OrEmpty(json));
            if (doc.RootElement.TryGetProperty("action", out var a) && a.ValueKind == JsonValueKind.String)
                action = a.GetString() ?? "info";
        }
        catch (JsonException ex)
        {
            return new { ok = false, error = $"JSON 解析失败: {ex.Message}" };
        }

        switch (action.ToLowerInvariant())
        {
            case "info":
                return BlackoutInfo();

            case "prerequisites":
            {
                var (talent, buff, note) = await GameRouter.GrantBlackoutPrerequisitesAsync(session, token);
                return new
                {
                    ok = talent && buff,
                    action = "prerequisites",
                    talentActivated = talent,
                    buffSent = buff,
                    note,
                    caveat = "这只解决「客户端认为玩家有这个能力」，**不会**播停电演出。",
                };
            }

            case "spawn":
            {
                var (creationId, range, position) = await GameRouter.TriggerBlackoutCreationAsync(session, token);
                return new
                {
                    ok = true,
                    action = "spawn",
                    creationId,
                    range,
                    position = new { position.X, position.Y, position.Z },
                    packet = "SyncAddCreation(68413195) = Base.ReadStruct(Auto.Reader[425])",
                    caveat = "创造物只带「范围干扰」的游戏效果；"
                        + "「全城停电」的视觉在客户端 Spoon 节点里，服务端发不出来。",
                };
            }

            case "all":
            {
                var (talent, buff, note) = await GameRouter.GrantBlackoutPrerequisitesAsync(session, token);
                var (creationId, range, position) = await GameRouter.TriggerBlackoutCreationAsync(session, token);
                return new
                {
                    ok = talent && buff,
                    action = "all",
                    talentActivated = talent,
                    buffSent = buff,
                    note,
                    creationId,
                    range,
                    position = new { position.X, position.Y, position.Z },
                    caveat = "前置条件 + 创造物都已下发；"
                        + "停电**演出**仍需客户端 Spoon 图跑到 PlayHackerTetrisNode。",
                };
            }

            default:
                return new
                {
                    ok = false,
                    error = $"未知 action '{action}'",
                    allowed = new[] { "info", "prerequisites", "spawn", "all" },
                };
        }
    }
}
