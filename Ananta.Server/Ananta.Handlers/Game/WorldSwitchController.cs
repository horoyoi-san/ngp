using System.Text.Json;
using Ananta.SDK.Network;
using Ananta.Server.RpcTypes.Client4229938;
using Ananta.SDK.Serialization;
using Ananta.Server.Protocol.Client4229938;

namespace Ananta.Server.Handlers.Game;

internal static class WorldSwitchController
{
    
    internal sealed record Result(
        bool Ok, uint RaidId, ulong InstanceId, uint UniverseId,
        float X, float Y, float Z, float Facing, string? Error, string? Note);

    internal static async Task<Result> SwitchRaidAsync(
        TcpSession session, uint raidId, ulong instanceId, uint universeId,
        float x, float y, float z, float facing)
    {
        if (raidId == 0 || instanceId == 0 || universeId == 0)
            return new Result(false, 0, 0, 0, 0, 0, 0, 0, "raidId / sceneInstanceId / universeId 都不能为 0", null);

        if (!float.IsFinite(x) || !float.IsFinite(y) || !float.IsFinite(z) || !float.IsFinite(facing))
            return new Result(false, 0, 0, 0, 0, 0, 0, 0, "坐标必须是有限数", null);

        if (!session.Items.TryGetValue(GameRouter.WorldStateKey, out var raw) || raw is not WorldEntryState state)
            return new Result(false, 0, 0, 0, 0, 0, 0, 0, "没有世界状态（先登录进游戏）", null);

        int generation;
        lock (state.SyncRoot)
        {
            var next = state.WorldEntryControlGeneration + 1;
            if (next <= 0)
                next = 1;
            generation = next;

            state.WorldEntryControlGeneration = generation;
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
            state.WorldEntryCreateHeroPosition = new Vec3(x, y, z);
            state.WorldEntryCreateHeroFacing = facing;
            state.LastReportedPlayerPosition = new Vec3(x, y, z);
            state.LastReportedPlayerRotation = new Vec3(0f, facing, 0f);
            state.HasLastReportedPlayerTransform = true;
            state.LastSwitchShowId = 0;
            state.AllBuildBuffsPublished = false;
            state.GaragePublished = false;
            state.AetherVehicleInitSent = false;
            state.InitialActorPresentationPublished = false;
            state.ActiveSpiritUnitId = Profile.InitialUnitId;
            state.ActiveSpiritTemplateId = Profile.InitialSpiritTemplateId;
            state.WorldEntryIsAirportTravel = false;
            state.Ready = false;

            
            state.ActiveRaidId = raidId;
            state.ActiveInstanceId = instanceId;
            state.ActiveUniverseId = universeId;
        }

        GameRouter.ResetVehicleStory(session);

        var info = RuntimePayloadFactory.EnterScene(
            raidId, instanceId, universeId,
            Profile.InitialUnitId, Profile.InitialSpiritTemplateId,
            new Vec3(x, y, z), facing);

        await session.NotifyAsync(MethodId.SyncEnterScene, UxSerializer.Serialize(info), CancellationToken.None);

        session.Log.Info(
            $"[WORLD-SWITCH] switch-raid generation={generation} raid={raidId} instance={instanceId} "
            + $"universe={universeId} pos=({x:F1},{y:F1},{z:F1}) facing={facing:F1} → 已发 SyncEnterScene");

        return new Result(true, raidId, instanceId, universeId, x, y, z, facing, null,
            "客户端会重新加载场景。若卡在加载画面，重开客户端即可恢复（无存档副作用）。");
    }
}
