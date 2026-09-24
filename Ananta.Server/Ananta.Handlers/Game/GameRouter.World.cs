using Ananta.SDK.Rpc;
using Ananta.Server.Handlers;
using Ananta.Server.Gameplay;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.RpcTypes.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    static WorldEntryState GetWorldState(RpcContext ctx)
    {
        if (ctx.Session.Items.TryGetValue(WorldStateKey, out var raw) && raw is WorldEntryState existing)
            return existing;

        var created = new WorldEntryState();
        ctx.Session.Items[WorldStateKey] = created;
        return created;
    }

    void ArmWorldEntry4229938(WorldEntryState state)
    {
        lock (state.SyncRoot)
        {
            var next = state.WorldEntryControlGeneration + 1;
            if (next <= 0)
                next = 1;

            state.WorldEntryControlGeneration = next;
            state.WorldEntryControlPending = true;
            state.WorldEntryControlFinalized = false;
            state.WorldEntryControlUnit = Profile.InitialUnitId;
            state.WorldEntryControlTemplate = Profile.InitialSpiritTemplateId;
            state.WorldEntryLoadingCompletedGeneration = 0;
            state.WorldEntryOpeningEndedGeneration = 0;
            state.WorldEntryControlFinalizingGeneration = 0;
            state.WorldEntryLogicProjectionPublishedGeneration = 0;
            state.WorldEntryCurrentMetadataPublishedGeneration = 0;
            state.WorldEntrySceneId4229938 = 0;
            state.WorldEntrySessionId4229938 = 0;
            state.WorldEntryCreateHeroPosition = Profile.WorldSpawn;
            state.WorldEntryCreateHeroFacing = Profile.WorldFacing;
            state.LastReportedPlayerPosition = Profile.WorldSpawn;
            state.LastReportedPlayerRotation = new Vec3(0f, Profile.WorldFacing, 0f);
            state.HasLastReportedPlayerTransform = false;
            state.LastSwitchShowId = 0;
            state.AllBuildBuffsPublished = false;
            state.GaragePublished = false;
            state.AetherVehicleInitSent = false;
            state.InitialActorPresentationPublished = false;
            state.ActiveSpiritUnitId = Profile.InitialUnitId;
            state.ActiveSpiritTemplateId = Profile.InitialSpiritTemplateId;
            state.WorldEntryIsAirportTravel = false;
        }
    }

    async Task SendInitialGameState(RpcContext ctx)
    {
        var state = GetWorldState(ctx);
        if (state.InitialStateSent)
        {
            ctx.Session.Log.Info("[WORLD-MIN] LoginGame repeat ignored");
            return;
        }
        state.InitialStateSent = true;

        await ctx.NotifyAsync(MethodId.SendServerTimeGame, LoginCodec.ServerTime());
        await ctx.NotifyAsync(MethodId.SyncPlayerInfo, RuntimePayloadFactory.MinimalPlayerInfo4229938());
        await SendEnterSceneIfNeeded(ctx);
    }

    async Task SendEnterSceneIfNeeded(RpcContext ctx)
    {
        var state = GetWorldState(ctx);
        if (state.EnterSceneSent)
            return;

        state.EnterSceneSent = true;
        ArmWorldEntry4229938(state);
        state.WorldEntrySwitchShowId = 0;
        state.WorldEntryCreateHeroPosition = Profile.WorldSpawn;
        state.WorldEntryCreateHeroFacing = Profile.WorldFacing;

        
        
        await ctx.NotifyAsync(MethodId.SyncEnterScene, RuntimePayloadFactory.EnterScene(
            Profile.RaidId,
            Profile.SceneInstanceId,
            Profile.UniverseId,
            Profile.InitialUnitId,
            Profile.InitialSpiritTemplateId,
            Profile.WorldSpawn,
            Profile.WorldFacing,
            switchShowId: 0,
            isSwitchSpiritShow: false));

        ctx.Session.Log.Info($"[WORLD-MIN] enter generation={state.WorldEntryControlGeneration} raid={Profile.RaidId} instance={Profile.SceneInstanceId} universe={Profile.UniverseId} unit={Profile.InitialUnitId} template={Profile.InitialSpiritTemplateId} pos=({Profile.WorldSpawn.X:0.##},{Profile.WorldSpawn.Y:0.##},{Profile.WorldSpawn.Z:0.##}) opening=false switchShow=0");
    }

    async Task<bool> CommitWorldEntryCreateHeroData4229938(RpcContext ctx, int generation)
    {
        var state = GetWorldState(ctx);
        ulong unitId;
        uint templateId;
        ulong playerPid;
        Vec3 createHeroPosition;
        float createHeroFacing;
        string? reject = null;

        
        
        
        lock (state.SyncRoot)
        {
            if (!state.WorldEntryControlPending || state.WorldEntryControlFinalized)
                reject = "transaction-not-pending";
            else if (generation <= 0 || generation != state.WorldEntryControlGeneration)
                reject = "generation-mismatch";
            else if (Profile.PlayerPid == 0 || state.WorldEntryControlUnit == 0 || state.WorldEntryControlTemplate == 0)
                reject = "zero-identity";
            else if (state.ActiveSpiritUnitId != state.WorldEntryControlUnit
                  || state.ActiveSpiritTemplateId != state.WorldEntryControlTemplate)
                reject = "active-identity-mismatch";
            else if (state.WorldEntryControlUnit != Profile.InitialUnitId
                  || state.WorldEntryControlTemplate != Profile.InitialSpiritTemplateId)
                reject = "profile-identity-mismatch";
            else if (!ClientConfigRepository.Characters().Any(x =>
                         x.UnitId == state.WorldEntryControlUnit &&
                         x.TemplateId == state.WorldEntryControlTemplate))
                reject = "canonical-roster-row-missing";
            else if (!float.IsFinite(state.WorldEntryCreateHeroPosition.X)
                  || !float.IsFinite(state.WorldEntryCreateHeroPosition.Y)
                  || !float.IsFinite(state.WorldEntryCreateHeroPosition.Z)
                  || !float.IsFinite(state.WorldEntryCreateHeroFacing))
                reject = "non-finite-createhero-transform";
            else if (state.WorldEntryLogicProjectionPublishedGeneration == generation
                  && state.WorldEntryCurrentMetadataPublishedGeneration == generation)
                return true;
            else if (state.WorldEntryLogicProjectionPublishedGeneration != 0
                  || state.WorldEntryCurrentMetadataPublishedGeneration != 0)
                reject = "projection-already-claimed";

            unitId = state.WorldEntryControlUnit;
            templateId = state.WorldEntryControlTemplate;
            playerPid = Profile.PlayerPid;
            createHeroPosition = state.WorldEntryCreateHeroPosition;
            createHeroFacing = state.WorldEntryCreateHeroFacing;

            if (reject is null)
            {
                
                
                state.WorldEntryLogicProjectionPublishedGeneration = -generation;
                state.WorldEntryCurrentMetadataPublishedGeneration = -generation;
            }
        }

        if (reject is not null)
        {
            ctx.Session.Log.Warn($"[WORLD-V7] commit rejected generation={generation} reason={reject}");
            return false;
        }

        
        
        await ctx.NotifyAsync(MethodId.SyncLogicAgentEnter, WorldCodec.LogicAgentEnter(unitId));
        await ctx.NotifyAsync(MethodId.SyncManagedLogicAgent, WorldCodec.ManagedLogicAgent(unitId, playerPid, 0));
        await ctx.NotifyAsync(MethodId.SyncRaidBattleUnitSpirit,
            RuntimePayloadFactory.ExistingUnitProjection(unitId, templateId, createHeroPosition, createHeroFacing));

        lock (state.SyncRoot)
        {
            if (state.WorldEntryLogicProjectionPublishedGeneration == -generation)
                state.WorldEntryLogicProjectionPublishedGeneration = generation;
        }

        await ctx.NotifyAsync(MethodId.SyncPlayerCurrentSpirit,
            WorldCodec.CurrentSpirit(playerPid, templateId, unitId, isAgentSwitch: false));

        lock (state.SyncRoot)
        {
            if (state.WorldEntryCurrentMetadataPublishedGeneration == -generation)
                state.WorldEntryCurrentMetadataPublishedGeneration = generation;
            state.CurrentSpiritStateSent = true;
            state.ControlPublished = true;
        }

        ctx.Session.Log.Info($"[HANDOFF-V7] generation={generation} exact=LogicAgentEnter->ManagedLogicAgent->sameID-AOI->CurrentSpirit unit={unitId} template={templateId} presentation=false buffs=false duplicateActor=false");
        return true;
    }

    async Task OnLoadSceneCompleted(RpcContext ctx, ulong sceneId, ulong sessionId)
    {
        var state = GetWorldState(ctx);
        int generation = 0;
        string? reject = null;

        lock (state.SyncRoot)
        {
            if (sceneId == 0 || sessionId == 0)
                reject = "invalid-scene-session";
            else if (!state.WorldEntryControlPending || state.WorldEntryControlFinalized)
                reject = "transaction-not-pending";
            else if (state.WorldEntrySceneId4229938 == 0 && state.WorldEntrySessionId4229938 == 0)
            {
                state.WorldEntrySceneId4229938 = sceneId;
                state.WorldEntrySessionId4229938 = sessionId;
            }
            else if (state.WorldEntrySceneId4229938 != sceneId || state.WorldEntrySessionId4229938 != sessionId)
                reject = "correlation-mismatch";

            if (reject is null)
            {
                generation = state.WorldEntryControlGeneration;
                state.SceneLoadAckSeen = true;
                state.SceneId = sceneId;
            }
        }

        if (reject is not null)
        {
            ctx.Session.Log.Warn($"[WORLD] AskLoadSceneCompleted rejected scene={sceneId} session={sessionId} reason={reject}");
            return;
        }

        if (!await CommitWorldEntryCreateHeroData4229938(ctx, generation))
            return;

        
        
        ctx.Session.Log.Info($"[WORLD] load-edge committed generation={generation} scene={sceneId} session={sessionId} logicProjection={state.WorldEntryLogicProjectionPublishedGeneration} currentMetadata={state.WorldEntryCurrentMetadataPublishedGeneration} sceneComplete=false hydration=false");
    }

    Task OnLoadGameResourcesCompleted(RpcContext ctx, ulong sceneId)
    {
        var state = GetWorldState(ctx);
        state.GameResourcesReadySeen = true;
        if (state.SceneId == 0 && sceneId != 0)
            state.SceneId = sceneId;
        return Task.CompletedTask;
    }

    async Task OnLoadingFinished(RpcContext ctx, ulong sceneId, ulong sessionId)
    {
        var state = GetWorldState(ctx);
        int generation = 0;
        string? reject = null;

        lock (state.SyncRoot)
        {
            if (sceneId == 0 || sessionId == 0)
                reject = "invalid-scene-session";
            else if (!state.WorldEntryControlPending || state.WorldEntryControlFinalized)
                reject = state.WorldEntryControlFinalized ? "already-finalized" : "transaction-not-pending";
            else if (sceneId != state.WorldEntrySceneId4229938 || sessionId != state.WorldEntrySessionId4229938)
                reject = "correlation-mismatch";
            else
            {
                generation = state.WorldEntryControlGeneration;
                if (state.WorldEntryLogicProjectionPublishedGeneration != generation
                 || state.WorldEntryCurrentMetadataPublishedGeneration != generation)
                    reject = "v7-handoff-incomplete";
                else if (state.WorldEntryLoadingCompletedGeneration == generation)
                    return;
                else if (state.WorldEntryLoadingCompletedGeneration != 0)
                    reject = "loading-edge-already-claimed";
                else if (state.WorldEntryControlFinalizingGeneration != 0)
                    reject = "finalizer-already-claimed";
                else
                {
                    state.WorldEntryLoadingCompletedGeneration = -generation;
                    state.WorldEntryControlFinalizingGeneration = -generation;
                    state.SceneId = sceneId;
                }
            }
        }

        if (reject is not null)
        {
            ctx.Session.Log.Warn($"[WORLD-V7] AskLoadingFinished rejected scene={sceneId} session={sessionId} generation={generation} reason={reject}");
            return;
        }

        
        
        
        await ctx.NotifyAsync(MethodId.SyncSceneLoadCompleted, WorldCodec.SceneLoadCompleted(sceneId));

        lock (state.SyncRoot)
        {
            state.SceneCompletionSent = true;
            if (state.WorldEntryLoadingCompletedGeneration == -generation)
                state.WorldEntryLoadingCompletedGeneration = generation;
            state.LivePlayerProfilePublished = false;
            state.CombatProfilePublished = false;
            state.AccountArmoryPublished = true; 
            state.FreeRoamReleased = false;
            state.MovementCapabilityPublished = false;
            state.AllBuildBuffsPublished = false;
            state.GaragePublished = false;
            state.AetherVehicleInitSent = false;
            ResetVehicleStory(ctx.Session);
            state.InitialActorPresentationPublished = false;
            state.InitialCapabilityBuffsPublished = false;
            state.WorldEntryControlPending = false;
            state.WorldEntryControlFinalized = true;
            if (state.WorldEntryControlFinalizingGeneration == -generation)
                state.WorldEntryControlFinalizingGeneration = generation;
            state.Ready = true;
            state.WorldEntryIsAirportTravel = false;
        }

        
        await ctx.NotifyAsync(MethodId.SyncGamePause, WorldCodec.GamePause(false));
        await PublishGarageAsync(ctx);

        
        
        
        
        
        {
            var aetherSession = ctx.Session;
            var gateHub = _gateSessions;
            uint aetherRaidId;
            lock (state.SyncRoot)
                aetherRaidId = state.ActiveRaidId;

            _ = Task.Run(async () =>
            {
                try
                {
                    var delayMs = PrivateServerConfigStore.Current.Gameplay.Aether.WorldEntryDelayMs;
                    aetherSession.Log.Info($"[AETHER-BG] 将在 {delayMs}ms 后异步推送车流和 NPC");
                    await Task.Delay(delayMs);

                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    if (gateHub?.Current is { } gate)
                    {
                        var sw = PrivateServerConfigStore.Current.Gameplay.GameSwitch;
                        if (sw.Enabled)
                        {
                            var framing = GameSwitchCodec.ParseFraming(sw.Framing);
                            var body = GameSwitchCodec.BuildPush(sw.Overrides, framing);
                            await gate.NotifyAsync(MethodId.SyncGameSwitchToClient_3, body, CancellationToken.None);
                            aetherSession.Log.Info(
                                $"[SWITCH] Aether 预初始化重下发 GameSwitch：{GameSwitchCatalog.Count} 项，"
                                + $"{body.Length} 字节，帧 {framing}（Gate socket）");
                        }
                    }
                    else
                    {
                        aetherSession.Log.Warn("[SWITCH] Aether 预初始化时找不到 Gate 会话，无法重下发 GameSwitch");
                    }

                    await PublishAetherInitBackgroundAsync(aetherSession, aetherRaidId, CancellationToken.None);
                }
                catch (OperationCanceledException) { }
                catch (Exception ex)
                {
                    aetherSession.Log.Info($"[AETHER-BG] 异步推送失败: {ex.GetType().Name}: {ex.Message}");
                }
            });
        }

        await EnsureVehicleStoryRoot(ctx);
        await PushSessionTimeAsync(ctx.Session);
        await PushSessionWeatherAsync(ctx.Session);

        
        await PushContentBaselineAsync(ctx.Session);

        
        
        LogSpiritContent();

        
        
        
        
        
        
        await PublishInitialCombatProfileAsync(ctx.Session);

        
        
        if (PrivateServerConfigStore.Current.Gameplay.Quests.SendLoginBootstrap)
        {
            SeedConfiguredQuests(state);
            
            if (PrivateServerConfigStore.Current.Gameplay.Quests.AutoStartStoryChain)
                await StartStoryChainAsync(ctx.Session, token: ctx.CancellationToken);
            await PushTaskContainerAsync(ctx.Session, ctx.CancellationToken);
            await PushConfiguredQuestProgressAsync(ctx.Session, ctx.CancellationToken);
        }

        
        await PublishAllStreetNpcsAsync(ctx.Session, ctx.CancellationToken);

        
        
        
        try
        {
            var wp = Protocol.Client4229938.Profile.WorldSpawn;
            await PublishBasketballCourtsAsync(ctx.Session, wp.X, wp.Z, ctx.CancellationToken);
        }
        catch (Exception ex)
        {
            ctx.Session.Log.Info($"[BASKETBALL] 球场信息下发失败: {ex.GetType().Name}: {ex.Message}");
        }

        ctx.Session.Log.Info($"[WORLD-V7] ready generation={generation} scene={sceneId} session={sessionId} exactGuide=true sceneComplete=first actorPresentation=client-owned buffs=deferred-first-movement noStory=true noAOI=true");
    }

    async Task OnLoadedInSameScene(RpcContext ctx)
    {
        var state = GetWorldState(ctx);
        bool firstPresentationEdge;
        lock (state.SyncRoot)
        {
            firstPresentationEdge = !state.SameSceneAckSeen;
            state.SameSceneAckSeen = true;
            if (firstPresentationEdge && Profile.WorldEntryOpeningEnabled && state.WorldEntryControlGeneration > 0)
                state.WorldEntryOpeningEndedGeneration = state.WorldEntryControlGeneration;
        }

        
        
        
        await ctx.NotifyAsync(MethodId.SyncPlayerLoadRate, WorldCodec.PlayerLoadRate());
        ctx.Session.Log.Info($"[SAME-SCENE] load-rate ack=true first={firstPresentationEdge} generation={state.WorldEntryControlGeneration} pendingSwitch={state.PendingSwitchTemplateId}/{state.PendingSwitchUnitId} controlMutation=false");
    }
}
