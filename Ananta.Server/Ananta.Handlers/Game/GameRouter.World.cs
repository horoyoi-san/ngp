using Ananta.SDK.Rpc;
using Ananta.Server.Handlers;
using Ananta.Server.Gameplay;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

/// <summary>World entry and client-driven scene loading barriers.</summary>
internal sealed partial class GameRouter
{
    WorldEntryState GetWorldState(RpcContext ctx)
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
        await PublishVehicleOwnership(ctx);
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

        // Minimal mode intentionally does not ask the client to play an authored opening Timeline.
        // Scene assets and native quest/story systems remain entirely client-owned.
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

        // Port the proven v7 preflight literally: validate the complete canonical identity and
        // CreateHero transform BEFORE claiming/sending the first authority packet. A failure after
        // LogicAgentEnter would leave an orphan authority entity, so this block is fail-closed.
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
            // Login must land on the configured initial actor. Scene switches re-arm the
            // transaction on whichever character is currently active (flag set by rearm only).
            else if (!state.WorldEntryAllowNonInitialControl
                  && (state.WorldEntryControlUnit != Profile.InitialUnitId
                   || state.WorldEntryControlTemplate != Profile.InitialSpiritTemplateId))
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
                // Both generation edges are claimed before any send. Partial failure remains
                // fail-closed; a duplicate callback must never replay half of the transaction.
                state.WorldEntryLogicProjectionPublishedGeneration = -generation;
                state.WorldEntryCurrentMetadataPublishedGeneration = -generation;
            }
        }

        if (reject is not null)
        {
            ctx.Session.Log.Warn($"[WORLD-V7] commit rejected generation={generation} reason={reject}");
            return false;
        }

        // Exact proven order from the supplied v7 guide. No sleep, no presentation hydration,
        // no buffs and no weapon/fashion deltas may be interleaved into this quartet.
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

        // The confirmed handoff transaction ends with CurrentSpirit. Do not interleave roster/combat/state
        // hydration here; the client must reach AskLoadingFinished with the post-load quartet intact.
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

        // Supplied guide invariant: SyncSceneLoadCompleted is the FIRST and ONLY S2C gameplay edge
        // of AskLoadingFinished. Do not put buffs/weapon/fashion/current before it. All optional
        // runtime hydration is deferred to the first real gameplay movement after Ready=true.
        await ctx.NotifyAsync(MethodId.SyncSceneLoadCompleted, WorldCodec.SceneLoadCompleted(sceneId));

        lock (state.SyncRoot)
        {
            state.SceneCompletionSent = true;
            if (state.WorldEntryLoadingCompletedGeneration == -generation)
                state.WorldEntryLoadingCompletedGeneration = generation;
            state.LivePlayerProfilePublished = false;
            state.CombatProfilePublished = false;
            state.AccountArmoryPublished = true; // compact referenced subset already arrived in SyncPlayerInfo
            state.FreeRoamReleased = false;
            state.MovementCapabilityPublished = false;
            state.AllBuildBuffsPublished = false;
            state.InitialActorPresentationPublished = false;
            state.InitialCapabilityBuffsPublished = false;
            state.WorldEntryControlPending = false;
            state.WorldEntryControlFinalized = true;
            if (state.WorldEntryControlFinalizingGeneration == -generation)
                state.WorldEntryControlFinalizingGeneration = generation;
            state.Ready = true;
            state.WorldEntryIsAirportTravel = false;
        }

        // Normal post-load finalization, deliberately after the terminal scene-ready edge.
        await ctx.NotifyAsync(MethodId.SyncGamePause, WorldCodec.GamePause(false));
        await EnsureAetherVehicleInit(ctx);
        await EnsureVehicleStoryRoot(ctx);
        await PushSessionTimeAsync(ctx.Session);
        await PushSessionWeatherAsync(ctx.Session);

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

        // 4229938 emits AskLoadedInSameScene after every authored same-scene character switch, not
        // only once after login. SyncPlayerLoadRate is therefore an acknowledgement for EACH edge.
        // Keep the opening-generation bookkeeping one-shot, but never suppress the per-switch ack.
        await ctx.NotifyAsync(MethodId.SyncPlayerLoadRate, WorldCodec.PlayerLoadRate());
        ctx.Session.Log.Info($"[SAME-SCENE] load-rate ack=true first={firstPresentationEdge} generation={state.WorldEntryControlGeneration} pendingSwitch={state.PendingSwitchTemplateId}/{state.PendingSwitchUnitId} controlMutation=false");
    }
}
