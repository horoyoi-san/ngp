using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using Ananta.Server.State;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    
    internal const ulong CreationEntityIdBase = 500000000000UL;

    private static long _creationEntitySeq;

    
    
    
    
    
    
    internal static Task SpawnCreationAsync(
        TcpSession session, uint creationId, Vec3 position, CancellationToken token = default)
    {
        if (creationId == 0)
            return Task.CompletedTask;

        var info = new GameMethods.CreationInfo4229938
        {
            Id = CreationEntityIdBase + (ulong)Interlocked.Increment(ref _creationEntitySeq),
            ParentId = 0,
            TargetId = 0,
            DestructibleId = 0,
            CreationId = creationId,
            ParentPosition = new Auto.UXVector3 { X = position.X, Y = position.Y, Z = position.Z },
            Rotate = 0f,
            ClientEnterOrLeave = false,
            SourceSkillId = 0,
            SourceDestructibleId = 0,
            GadgetId = 0,
            GadgetTransformId = 0,
        };

        return session.NotifyAsync(MethodId.SyncAddCreation, UxSerializer.Serialize(info), token);
    }

    
    
    
    
    
    
    internal static Task ActivateTalentLayerAsync(
        TcpSession session, uint spiritId, uint jobClassId, uint talentId, uint layer,
        CancellationToken token = default)
        => session.NotifyAsync(MethodId.SyncActiveSpiritJobTalentLayer, UxSerializer.Serialize(
            new GameMethods.SyncActiveSpiritJobTalentLayer4229938
            {
                spiritId = spiritId,
                jobClassId = jobClassId,
                talentId = talentId,
                layer = layer,
            }), token);

    
    
    
    
    
    
    internal static async Task<(bool Talent, bool Buff, string Note)> GrantBlackoutPrerequisitesAsync(
        TcpSession session, CancellationToken token = default)
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.HackerBlackout;
        if (!settings.Enabled)
            return (false, false, "gameplay.hackerBlackout.enabled = false");

        if (!session.Items.TryGetValue(WorldStateKey, out var raw) || raw is not WorldEntryState state)
            return (false, false, "还没有世界状态（先进入世界）");

        if (state.ActiveSpiritUnitId == 0)
            return (false, false, "当前没有可控单位（先进入世界）");

        
        await ActivateTalentLayerAsync(
            session, state.ActiveSpiritTemplateId, settings.JobClassId, settings.TalentId, 1, token);

        
        uint instanceId;
        lock (state.SyncRoot)
            instanceId = state.NextBuffInstanceId++;

        await session.NotifyAsync(MethodId.SyncUnitAddBuff,
            UxSerializer.Serialize(WorldCodec.UnitAddBuff(state.ActiveSpiritUnitId, settings.CapabilityBuffId, instanceId)),
            token);

        return (true, true,
            $"talent={settings.TalentId} layer=1 job={settings.JobClassId} "
            + $"buff={settings.CapabilityBuffId} instance={instanceId}");
    }

    
    
    
    internal static async Task<(uint CreationId, uint Range, Vec3 Position)> TriggerBlackoutCreationAsync(
        TcpSession session, CancellationToken token = default)
    {
        var settings = PrivateServerConfigStore.Current.Gameplay.HackerBlackout;
        var position = new Vec3(0f, 0f, 0f);

        if (session.Items.TryGetValue(WorldStateKey, out var raw) && raw is WorldEntryState state)
            position = state.LastReportedPlayerPosition;

        await SpawnCreationAsync(session, settings.CreationId, position, token);
        return (settings.CreationId, settings.Range, position);
    }
}
