using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.SDK.Serialization;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.State;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    

    
    
    
    
    
    [Handler(MethodId.AskSetSpiritFashionsWithSource, HandlerPacketKind.Invoke)]
    private async Task OnSetSpiritFashionsWithSource(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskSetSpiritFashionsWithSource4229938>();
        var spiritId = args.spiritOrInstanceId;
        var ids = args.wearFashionInfoList.Select(x => x.FashionId).Where(x => x != 0).Distinct().ToList();

        await conn.ReturnEmptyOkAsync(msg);

        SessionState.Update(state =>
        {
            state.WornFashions[spiritId] = ids;
            foreach (var id in ids)
                if (!state.OwnedFashions.Contains(id))
                    state.OwnedFashions.Add(id);
        });

        
        var wear = new GameMethods.SpiritWearFashionsInfo
        {
            FunctionSuitId = args.functionSuitId,
            WearSourceInfo = new GameMethods.WearSourceInfo { Source = args.wearSource, SourceId = args.wearSourceId },
            IsTryWear = args.isTryWear,
            WearFashionInfoList = ids.Select(id => new GameMethods.WearFashionInfo { FashionId = id }).ToList(),
            WearFashionEditInfoList = args.wearFashionEditInfoList ?? [],
            HiddenParts = args.hiddenParts,
            EditedHiddenParts = args.editedHiddenParts,
        };

        await ctxNotify(conn, MethodId.SyncSetSpiritFashions, new GameMethods.SyncSetSpiritFashions
        {
            spiritId = spiritId,
            source = args.source,
            spiritWearFashionsInfo = wear,
        });

        conn.Log.Info($"[FASHION] 保存穿戴 spirit={spiritId} source={args.source} 件数={ids.Count}");
    }

    

    
    [Handler(MethodId.AskMallBuyCommodity, HandlerPacketKind.Invoke)]
    private async Task OnMallBuyCommodity(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskMallBuyCommodity4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        await SettlePurchaseAsync(conn, "mall", args.commodityId, args.count);
    }

    [Handler(MethodId.AskBuyCommodity, HandlerPacketKind.Invoke)]
    private async Task OnBuyCommodity(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskBuyCommodity4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        await SettlePurchaseAsync(conn, $"shop:{args.shopId}", args.commodityId, args.count);
    }

    [Handler(MethodId.AskNpcShop, HandlerPacketKind.Invoke)]
    private async Task OnNpcShop(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskNpcShopId4229938>();
        await conn.ReturnEmptyOkAsync(msg);

        
        await PushShopAsync(conn.Session, args.shopId);
    }

    [Handler(MethodId.AskNpcShopCommodityInfo, HandlerPacketKind.Invoke)]
    private Task OnNpcShopCommodityInfo(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskNpcShopId4229938>();
        
        var body = new GameMethods.NpcShopCommodityInfo4229938 { currentDiscount = 1 };
        return conn.ReturnAsync(msg, body);
    }

    
    private async Task SettlePurchaseAsync(Connection conn, string source, uint commodityId, uint count)
    {
        if (commodityId == 0)
            return;

        var entry = GameCatalog.Mall.FirstOrDefault(m => m.CommodityId == commodityId);
        var bindId = entry?.BindId ?? 0;
        var price = entry?.Price ?? 0;

        if (price > 0)
            await ctxNotify(conn, MethodId.SyncMoneyAdd,
                new GameMethods.SyncMoneyAdd4229938 { value = -price, reason = 0, silence = true });

        if (bindId == 0)
        {
            conn.Log.Info($"[SHOP] {source} 商品 {commodityId} 无绑定物品，仅扣费 {price}");
            return;
        }

        await GrantAsync(conn, bindId, Math.Max(1u, count));
        conn.Log.Info($"[SHOP] {source} 购买 商品={commodityId} 发放={bindId} 数量={count} 价格={price}");
    }

    private async Task GrantAsync(Connection conn, uint bindId, uint count)
    {
        
        if (GameCatalog.Fashions.Any(f => f.FashionId == bindId))
        {
            await ctxNotify(conn, MethodId.SyncAddFashion,
                new GameMethods.SyncAddFashion4229938 { fashionInfo = FashionInfo(bindId) });
            SessionState.Update(s => { if (!s.OwnedFashions.Contains(bindId)) s.OwnedFashions.Add(bindId); });
            return;
        }

        if (CombatCatalogRepository.ArmoryWeapons.Any(w => w.TemplateId == bindId || w.LegacyWeaponId == bindId))
        {
            await GrantWeaponAsync(conn.Session, bindId);
            return;
        }

        await AddBackpackAsync(conn, bindId, count);
    }

    private static async Task AddBackpackAsync(Connection conn, uint templateId, uint count)
    {
        await ctxNotify(conn, MethodId.SyncBackpackItemChanged,
            new GameMethods.SyncBackpackItemChanged4229938
            {
                updateItemList = [PackItem(templateId, 950000000000UL + templateId, count)],
            });
        SessionState.Update(s =>
        {
            s.Backpack.TryGetValue(templateId, out var current);
            s.Backpack[templateId] = current + count;
        });
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

    private static Auto.PlayerPackItem PackItem(uint templateId, ulong uniqueId, uint count) => new()
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

    
    
    
    
    internal static async Task AddWeaponToArmoryAsync(TcpSession session, uint templateId, uint spiritId, string reason, CancellationToken token = default)
    {
        spiritId = spiritId != 0 ? spiritId : (GameCatalog.Characters.FirstOrDefault()?.TemplateId ?? 0);
        var weapon = await CombatCatalogResolver.WeaponDataAsync(templateId, spiritId);

        
        var instanceId = CombatCatalogRepository.InstanceIdForTemplate(templateId);
        if (instanceId == 0)
        {
            
            SessionState.Update(state =>
            {
                instanceId = state.Weapons.Count == 0 ? 900000000000UL : state.Weapons.Max(w => w.InstanceId) + 1;
            });
        }

        SessionState.Update(state =>
        {
            if (state.Weapons.All(w => w.InstanceId != instanceId))
                state.Weapons.Add(new WeaponRecord { InstanceId = instanceId, TemplateId = templateId, SpiritId = spiritId });
        });

        weapon.InstanceId = instanceId;

        await NotifyRaw(session, MethodId.SyncArmoryAddWeapon,
            new GameMethods.SyncArmoryAddWeapon4229938 { weapon = weapon });

        
        var unitId = GameCatalog.Characters.FirstOrDefault(c => c.TemplateId == spiritId)?.UnitId ?? 0;
        var definition = CombatCodec.Weapon(spiritId, instanceId);
        if (definition is not null && unitId != 0)
        {
            var loadout = CombatCatalogRepository.Loadout(spiritId);
            var slots = loadout.Slots.ToArray();
            var index = Array.FindIndex(slots, x => x is null || x.InstanceId == instanceId);
            if (index < 0)
                index = slots.Length - 1;
            if (index >= 0)
                slots[index] = definition;

            var snapshot = CombatCodec.SpiritWeaponSnapshot(unitId, spiritId, instanceId, slots);
            await NotifyRaw(session, MethodId.SyncSpiritWeaponDetail, snapshot);
            await NotifyRaw(session, MethodId.SyncSpiritLastUsedWeapon,
                CombatCodec.SpiritLastUsedWeapon(spiritId, instanceId));
            session.Log.Info($"[WEAPON] 已放入轮盘 slot={index} spirit={spiritId} instance={instanceId}");
        }
        else
        {
            session.Log.Warn($"[WEAPON] {templateId} 无法解析为 {spiritId} 的武器定义，仅入库");
        }

        session.Log.Info($"[WEAPON] 入库 template={templateId} instance={instanceId} spirit={spiritId} reason={reason}");
    }

    [Handler(MethodId.AskDiscardWeaponByInstanceId, HandlerPacketKind.Invoke)]
    private async Task OnDiscardWeaponByInstanceId(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskDiscardWeaponByInstanceId4229938>();
        await conn.ReturnEmptyOkAsync(msg);

        SessionState.Update(s => s.Weapons.RemoveAll(w => w.InstanceId == args.instanceId));
        await ctxNotify(conn, MethodId.SyncArmoryRemoveWeapon,
            new GameMethods.SyncArmoryRemoveWeapon4229938 { id = args.instanceId });

        conn.Log.Info($"[WEAPON] 丢弃 instance={args.instanceId} spirit={args.spiritId}");
    }

    

    
    
    
    
    
    
    
    
    
    [Handler(MethodId.AskTeleport, HandlerPacketKind.Invoke)]
    private async Task OnAskTeleport(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);

        var position = TryExtractTeleportTarget(msg.Body, out var facing);
        if (position is null)
        {
            conn.Log.Warn("[TELEPORT] 无法从请求中解析目标坐标，忽略");
            return;
        }

        await ctxNotify(conn, MethodId.IGameToClient_SyncTeleport, new GameMethods.SyncTeleport4229938
        {
            teleportId = (ulong)DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(),
            Position = position,
            Facing = facing,
            IsSwitchScene = false,
            WaitTaskResource = false,
        });

        conn.Log.Info($"[TELEPORT] 已下发 SyncTeleport -> ({position.X:F1}, {position.Y:F1}, {position.Z:F1}) facing={facing:F1}");
    }

    
    
    
    
    private static Auto.UXVector3? TryExtractTeleportTarget(byte[] body, out float facing)
    {
        facing = 0f;
        if (body is null || body.Length < 24)
            return null;

        for (var offset = body.Length - 24; offset >= 0; offset--)
        {
            if (offset + 24 > body.Length)
                continue;

            var p = ReadFloats(body, offset, 6);
            var (px, py, pz) = (p[0], p[1], p[2]);
            var (rx, ry, rz) = (p[3], p[4], p[5]);

            var positionOk = MathF.Abs(px) < 200000f && MathF.Abs(py) < 200000f && MathF.Abs(pz) < 200000f
                             && (MathF.Abs(px) > 0.001f || MathF.Abs(pz) > 0.001f);
            var rotationOk = MathF.Abs(rx) < 360f && MathF.Abs(rz) < 360f && MathF.Abs(ry) <= 720f;

            if (!positionOk || !rotationOk)
                continue;

            facing = ry;
            return new Auto.UXVector3 { X = px, Y = py, Z = pz };
        }

        return null;
    }

    private static float[] ReadFloats(byte[] buffer, int offset, int count)
    {
        var values = new float[count];
        for (var i = 0; i < count; i++)
            values[i] = BitConverter.ToSingle(buffer, offset + i * 4);
        return values;
    }

    

    
    
    
    
    [Handler(MethodId.AskGetVehicleRadioContent, HandlerPacketKind.Invoke)]
    private async Task OnGetVehicleRadioContent(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskGetVehicleRadioContent4229938>();
        await conn.ReturnEmptyOkAsync(msg);

        var songs = ExtraCatalog.RadioSongs;
        if (songs.Count == 0)
        {
            conn.Log.Warn("[RADIO] 没有可用歌曲（RadioConfig 未找到）");
            return;
        }

        var index = (int)((args.radioId * 7 + args.index) % (uint)songs.Count);
        var songId = songs[index];
        await ctxNotify(conn, MethodId.IGameToClient_SyncAddRadioSong,
            new GameMethods.SyncAddRadioSong4229938 { songId = songId });

        conn.Log.Info($"[RADIO] 下发歌曲 slot={args.radioId} index={args.index} songId={songId} (SoundOnlineUrlConfig)");
    }

    [Handler(MethodId.AskSwitchVehicleRadio, HandlerPacketKind.Notify)]
    private async Task OnSwitchVehicleRadio(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskSwitchVehicleRadio4229938>();
        conn.Log.Info($"[RADIO] 切换电台 slot={args.radioId}");

        
        var songs = ExtraCatalog.RadioSongs;
        if (songs.Count > 0)
            await ctxNotify(conn, MethodId.IGameToClient_SyncAddRadioSong,
                new GameMethods.SyncAddRadioSong4229938 { songId = songs[(int)(args.radioId % (uint)songs.Count)] });
    }

    

    
    
    
    
    
    
    [Handler(MethodId.AskGetAllMetroInfos, HandlerPacketKind.Invoke)]
    private async Task OnGetAllMetroInfos(Connection conn, UxRpcMessage msg)
    {
        
        
        var routes = ExtraCatalog.MapRoutes;
        var body = new GameMethods.SyncRunningMetroInfos4229938();
        for (var i = 0; i < routes.Count; i++)
            body.metroInfos.Add(BuildMetroInfo(routes[i].Id, i));

        conn.Log.Info($"[METRO] 返回运行线路 {body.metroInfos.Count} 条（MapentranceRouteConfig）ids=[{string.Join(",", routes.Select(r => r.Id))}]");
        await conn.ReturnAsync(msg, body);
    }

    
    [Handler(MethodId.AskQueryAllFavorNpcAgentPos, HandlerPacketKind.Invoke)]
    private Task OnQueryAllFavorNpcAgentPos(Connection conn, UxRpcMessage msg)
    {
        var body = new GameMethods.NpcAgentPosDict4229938();

        
        foreach (var entrance in ExtraCatalog.MapEntrances.Take(64))
        {
            body.npcPosDict[entrance.Id] = new GameMethods.NpcAgentPos4229938
            {
                RaidId = entrance.RaidId,
                Position = new Auto.UXVector3 { X = entrance.X, Y = entrance.Y, Z = entrance.Z },
            };
        }

        conn.Log.Info($"[NPC] 下发 NPC 位置 {body.npcPosDict.Count} 个");
        return conn.ReturnAsync(msg, body);
    }

    [Handler(MethodId.AskActiveDynamicGo, HandlerPacketKind.Invoke)]
    private async Task OnActiveDynamicGo(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskActiveDynamicGo4229938>();
        await conn.ReturnEmptyOkAsync(msg);
        conn.Log.Info($"[DYNAMIC-GO] 激活 id={args.id} flags={args.flag0}/{args.flag1}");
    }

    

    
    
    
    
    
    
    
    [Handler(MethodId.AskSetMobileSkinPart, HandlerPacketKind.Invoke)]
    private async Task OnSetMobileSkinPart(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskSetMobileSkinPart4229938>();
        await conn.ReturnEmptyOkAsync(msg);

        SessionState.Update(s => s.MobileSkinParts = [args.part0, args.part1, args.part2]);
        conn.Log.Info($"[PHONE] 保存皮肤 {args.part0}/{args.part1}/{args.part2}");

        
        await PushMobileSkinAsync(conn.Session);
    }

    [Handler(MethodId.AskInstallMobileApp, HandlerPacketKind.Invoke)]
    private async Task OnInstallMobileApp(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskInstallMobileApp4229938>();
        await conn.ReturnEmptyOkAsync(msg);

        SessionState.Update(s =>
        {
            if (!s.InstalledApps.Contains(args.appId))
                s.InstalledApps.Add(args.appId);
        });
        conn.Log.Info($"[PHONE] 安装应用 {args.appId}（已写入存档，重登后由登录包 InstalledApps 恢复）");
    }

    
    
    
    
    [Handler(MethodId.AskUninstallMobileApp, HandlerPacketKind.Invoke)]
    private async Task OnUninstallMobileApp(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);

        if (msg.Body is null || msg.Body.Length < 4)
        {
            conn.Log.Warn("[PHONE] 卸载应用请求为空，忽略");
            return;
        }

        var appId = BitConverter.ToUInt32(msg.Body, 0);
        SessionState.Update(s => s.InstalledApps.RemoveAll(x => x == appId));
        conn.Log.Info($"[PHONE] 卸载应用 {appId}");
    }

    

    
    
    
    
    
    
    
    [Handler(MethodId.AskActivateNpcProfile, HandlerPacketKind.Invoke)]
    private async Task OnActivateNpcProfile(Connection conn, UxRpcMessage msg)
    {
        var args = msg.GetArgs<GameMethods.AskActivateNpcProfile4229938>();
        await conn.ReturnEmptyOkAsync(msg);

        var profileId = args.profileId;
        var row = ExtraCatalog.AgentProfiles.FirstOrDefault(p => p.Id == profileId);
        var trust = row?.MaxTrust > 0 ? row.MaxTrust : 1000u;

        var info = new Auto.TrustNpcInfo
        {
            ProfileId = profileId,
            TrustValue = trust,
            ActivateTime = 1,
            IsNew = false,
            IsMaxTrustReward = false,
        };
        foreach (var targetId in ExtraCatalog.NpcProfileTargets)
            info.TargetStateList.Add(new Auto.TrustNpcTargetState { TargetId = targetId, IsNew = false });

        await ctxNotify(conn, MethodId.SyncPlayerNpcProfileActivate,
            new GameMethods.SyncPlayerNpcProfileActivate4229938 { profileInfo = info });
        await ctxNotify(conn, MethodId.SyncPlayerNpcProfileTrustValueCh,
            new GameMethods.SyncPlayerNpcProfileTrustValueChanged4229938
            {
                ProfileId = profileId,
                TrustValue = trust,
                Reason = 0,
            });

        conn.Log.Info($"[PROFILE] 激活角色档案 {profileId}（{row?.Name ?? "?"}）信任={trust}");
    }

    
    
    
    
    
    
    [Handler(MethodId.AskTakeNpcProfileTrustReward, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskTakeNpcProfileMaxTrustReward, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskTakeNpcProfileProgressReward, HandlerPacketKind.Invoke)]
    [Handler(MethodId.AskTakeNpcProfileProgressRewardWithWeb, HandlerPacketKind.Invoke)]
    private async Task OnTakeNpcProfileReward(Connection conn, UxRpcMessage msg)
    {
        await conn.ReturnEmptyOkAsync(msg);

        var body = msg.Body ?? [];
        var profileId = body.Length >= 4 ? BitConverter.ToUInt32(body, 0) : 0u;
        var rewardId = body.Length >= 8 ? BitConverter.ToUInt32(body, 4) : 0u;

        await ctxNotify(conn, MethodId.SyncPlayerNpcProfileRewardGot,
            new GameMethods.SyncPlayerNpcProfileRewardGot4229938
            {
                profileId = profileId,
                rewardId = rewardId,
            });

        conn.Log.Info($"[PROFILE] 领取档案奖励 profile={profileId} reward={rewardId} mid={msg.MethodId}");
    }

    
    
    
    
    
    
    
    
    

    
    internal static async Task PushSavedFashionsAsync(TcpSession session)
    {
        var state = SessionState.Current;
        if (state.WornFashions.Count == 0)
            return;

        foreach (var (spiritId, ids) in state.WornFashions)
        {
            if (ids.Count == 0)
                continue;
            await NotifyRaw(session, MethodId.SyncSetSpiritFashions, new GameMethods.SyncSetSpiritFashions
            {
                spiritId = spiritId,
                source = 0,
                spiritWearFashionsInfo = new GameMethods.SpiritWearFashionsInfo
                {
                    FunctionSuitId = 0,
                    WearSourceInfo = new GameMethods.WearSourceInfo { Source = 0, SourceId = 0 },
                    IsTryWear = false,
                    WearFashionInfoList = ids.Select(id => new GameMethods.WearFashionInfo { FashionId = id }).ToList(),
                    WearFashionEditInfoList = [],
                    HiddenParts = 0,
                    EditedHiddenParts = 0,
                },
            });
        }

        session.Log.Info($"[FASHION] 恢复已保存穿戴方案 {state.WornFashions.Count} 个角色");
    }

    private static Task ctxNotify<T>(Connection conn, uint methodId, T body)
        => conn.NotifyAsync(methodId, body);

    private static Task NotifyRaw<T>(TcpSession session, uint methodId, T body)
        => session.NotifyAsync(methodId, UxSerializer.Serialize(body), CancellationToken.None);
}
