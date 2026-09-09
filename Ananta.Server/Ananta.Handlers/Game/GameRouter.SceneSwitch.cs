using Ananta.SDK.Network;
using Ananta.SDK.Rpc;
using Ananta.SDK.Serialization;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

/// <summary>
/// Scene ("raid") switching: re-push SyncEnterScene with a new raid/instance/universe
/// destination and re-arm the world-entry barrier lifecycle so the client's normal
/// AskLoadSceneCompleted → quartet → AskLoadingFinished → movement flow runs again.
/// Ported from the proven newcityps (4091149) airport handoff, adapted to the minimal
/// 4229938 world entry (no timelines, no AOI streaming).
/// </summary>
internal sealed partial class GameRouter
{
    /// <summary>
    /// Client -&gt; server map/teleport request: AskPublicSwitchToPublicScene
    /// (63491547, invoke raidId/delay/mapEntranceId). Known raid ids switch via the
    /// preset arrivals; anything else is accepted and logged for future mapping.
    /// </summary>
    [Handler(MethodId.AskPublicSwitchToPublicScene)]
    private async Task AskPublicSwitchToPublicScene(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.AskPublicSwitchToPublicSceneArgs>(out var args) && args is not null)
        {
            conn.Log.Info($"[SCENE] AskPublicSwitchToPublicScene raid={args.raidId} delay={args.delay} entrance={args.mapEntranceId}");
            if (args.raidId != 0 && GameAdminBridge.TryGetScenePreset(args.raidId, out var preset) && preset is not null)
                await SwitchSceneAsync(msg.Context.Session, preset.RaidId, preset.InstanceId, preset.UniverseId,
                    preset.X, preset.Y, preset.Z, preset.Facing, "client-public-switch");
        }
        else
        {
            conn.Log.Warn($"[SCENE] AskPublicSwitchToPublicScene undecodable bytes={msg.Body.Length}");
        }
        await conn.ReturnEmptyOkAsync(msg);
    }

    [Handler(MethodId.AskEnterRaidByMapEntrance)]
    private async Task AskEnterRaidByMapEntrance(Connection conn, UxRpcMessage msg)
    {
        if (msg.TryGetArgs<GameMethods.AskEnterRaidByMapEntranceArgs>(out var args) && args is not null)
            conn.Log.Info($"[SCENE] AskEnterRaidByMapEntrance entrance={args.mapEntranceId} (no entrance map yet, accepted)");
        else
            conn.Log.Warn($"[SCENE] AskEnterRaidByMapEntrance undecodable bytes={msg.Body.Length}");
        await conn.ReturnEmptyOkAsync(msg);
    }

    /// <summary>
    /// Server-driven scene switch. Re-arms the world-entry transaction for a new
    /// generation, then pushes SyncEnterScene. The existing barrier handlers
    /// (OnLoadSceneCompleted / OnLoadingFinished / movement) complete the handoff.
    /// </summary>
    internal static async Task SwitchSceneAsync(
        TcpSession session, uint raidId, ulong instanceId, uint universeId,
        float x, float y, float z, float facing, string reason)
    {
        var state = GetStateStatic(session);
        ulong unitId;
        uint templateId;
        int generation;
        lock (state.SyncRoot)
        {
            state.ActiveRaidId = raidId;
            state.ActiveInstanceId = instanceId;
            state.ActiveUniverseId = universeId;
            state.ActiveContentScene = raidId == Profile.RaidId ? "WorldMap_Release" : $"raid-{raidId}";

            unitId = state.ActiveSpiritUnitId != 0 ? state.ActiveSpiritUnitId : Profile.InitialUnitId;
            templateId = state.ActiveSpiritTemplateId != 0 ? state.ActiveSpiritTemplateId : Profile.InitialSpiritTemplateId;

            var next = state.WorldEntryControlGeneration + 1;
            if (next <= 0)
                next = 1;
            state.WorldEntryControlGeneration = next;
            generation = next;
            state.WorldEntryControlPending = true;
            state.WorldEntryControlFinalized = false;
            state.WorldEntryControlUnit = unitId;
            state.WorldEntryControlTemplate = templateId;
            // A switch can happen on any owned character, not just the initial one.
            state.WorldEntryAllowNonInitialControl = true;
            state.WorldEntryLoadingCompletedGeneration = 0;
            state.WorldEntryOpeningEndedGeneration = 0;
            state.WorldEntryControlFinalizingGeneration = 0;
            state.WorldEntryLogicProjectionPublishedGeneration = 0;
            state.WorldEntryCurrentMetadataPublishedGeneration = 0;
            state.WorldEntrySceneId4229938 = 0;
            state.WorldEntrySessionId4229938 = 0;
            state.WorldEntryCreateHeroPosition = new Vec3(x, y, z);
            state.WorldEntryCreateHeroFacing = facing;
            state.LastReportedPlayerPosition = new Vec3(x, y, z);
            state.LastReportedPlayerRotation = new Vec3(0f, facing, 0f);
            state.HasLastReportedPlayerTransform = true;
            state.SceneLoadAckSeen = false;
            state.GameResourcesReadySeen = false;
            state.ControlPublished = false;
            state.SceneCompletionSent = false;
            state.CurrentSpiritStateSent = false;
            state.Ready = false;
            state.SameSceneAckSeen = false;
            state.MovementCapabilityPublished = false;
            state.FreeRoamReleased = false;
            state.FirstMovementSeen = false;
            state.InitialCapabilityBuffsPublished = false;
            state.AllBuildBuffsPublished = false;
            state.InitialActorPresentationPublished = false;
            state.CombatProfilePublished = false;
            state.SceneId = 0;
            state.PendingTeleportId = 0;
            state.PendingTeleportPreFinished = false;
            state.PendingTeleportSyncSent = false;
            state.WorldEntryIsAirportTravel = false;
            state.PendingSwitchTemplateId = 0;
            state.PendingSwitchUnitId = 0;
            state.PendingSwitchOldUnitId = 0;
            state.PendingSwitchControlTransferred = false;
            state.PendingSwitchLandingStarted = false;
        }

        await ForceLeaveVehicleAsync(session);
        GetVehicleRuntimeState(session).Clear();
        await session.NotifyAsync(MethodId.SyncGamePause,
            UxSerializer.Serialize(WorldCodec.GamePause(true)), CancellationToken.None);
        await session.NotifyAsync(MethodId.SyncEnterScene,
            UxSerializer.Serialize(RuntimePayloadFactory.EnterScene(
                raidId, instanceId, universeId, unitId, templateId,
                new Vec3(x, y, z), facing, switchShowId: 0, isSwitchSpiritShow: false)),
            CancellationToken.None);
        session.Log.Info($"[SCENE] switch reason={reason} generation={generation} raid={raidId} instance={instanceId} universe={universeId} unit={unitId} template={templateId} pos=({x:F2},{y:F2},{z:F2}) facing={facing:F2}");
    }

    private static WorldEntryState GetStateStatic(TcpSession session)
    {
        if (session.Items.TryGetValue(WorldStateKey, out var raw) && raw is WorldEntryState existing)
            return existing;
        var created = new WorldEntryState();
        session.Items[WorldStateKey] = created;
        return created;
    }
}
