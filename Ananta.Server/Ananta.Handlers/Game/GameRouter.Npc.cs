using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using Ananta.Server.State;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    
    private static long _streetNpcSeq = 600000000000L;

    internal static async Task<string> PlaceStreetNpcAsync(
        TcpSession session,
        uint templateId,
        Vec3 position,
        float facing,
        string? name = null,
        IReadOnlyList<uint>? fashionIds = null,
        CancellationToken token = default)
    {
        if (templateId == 0)
            return "templateId must not be zero";

        var state = GetStateIfExists(session);
        if (state is null)
            return "no live game session (is the client in the world?)";

        
        var character = ClientConfigRepository.Characters().FirstOrDefault(x => x.TemplateId == templateId);
        var agent = character is null ? AgentCatalogRepository.Find(templateId) : null;
        if (character is null && agent is null)
            return $"template {templateId} is in neither FightSpiritConfig nor AgentConfig";
        var label = string.IsNullOrWhiteSpace(name) ? (character?.Name ?? agent!.Name) : name!;

        
        var id = (ulong)Interlocked.Increment(ref _streetNpcSeq);
        var record = new StreetNpcRecord
        {
            Id = id,
            Name = label,
            TemplateId = templateId,
            X = position.X,
            Y = position.Y,
            Z = position.Z,
            Facing = facing,
            FashionIds = fashionIds?.Where(x => x != 0).Distinct().ToList() ?? [],
        };

        SessionState.Update(saved => saved.StreetNpcs.Add(record));
        await SpawnStreetNpcLiveAsync(session, record, token);

        session.Log.Info($"[NPC] 放置 {label} template={templateId} id={id} at=({position.X:F1},{position.Y:F1},{position.Z:F1}) facing={facing:F1}");
        return $"placed '{label}' (template {templateId}, id {id})";
    }

    
    internal static async Task<string> PlaceStreetNpcNearPlayerAsync(
        TcpSession session,
        uint templateId,
        float distance = 4f,
        IReadOnlyList<uint>? fashionIds = null,
        CancellationToken token = default)
    {
        var state = GetStateIfExists(session);
        if (state is null)
            return "no live game session (is the client in the world?)";

        Vec3 origin;
        float yawDeg;
        lock (state.SyncRoot)
        {
            origin = state.LastReportedPlayerPosition;
            yawDeg = state.LastReportedPlayerRotation.Y;
        }
        if (!float.IsFinite(yawDeg))
            yawDeg = Profile.WorldFacing;

        var yawRad = yawDeg * (float)Math.PI / 180f;
        var target = new Vec3(
            origin.X + (float)Math.Sin(yawRad) * distance,
            origin.Y + 0.5f,
            origin.Z + (float)Math.Cos(yawRad) * distance);
        return await PlaceStreetNpcAsync(session, templateId, target, yawDeg, null, fashionIds, token);
    }

    
    internal static async Task SpawnStreetNpcLiveAsync(TcpSession session, StreetNpcRecord npc, CancellationToken token = default)
    {
        var state = GetStateIfExists(session);
        if (state is null || !state.Ready)
            return;

        var pos = new Vec3(npc.X, npc.Y, npc.Z);

        
        await session.NotifyAsync(
            MethodId.SyncLogicAgentEnter,
            UxSerializer.Serialize(WorldCodec.LogicAgentEnter(npc.Id)),
            token);

        
        var projection = RuntimePayloadFactory.NpcUnitProjection(
            npc.Id, npc.TemplateId, pos, npc.Facing,
            npc.FashionIds.Count > 0 ? npc.FashionIds : null);
        await session.NotifyAsync(
            MethodId.SyncRaidBattleUnitSpirit,
            UxSerializer.Serialize(projection),
            token);

        
        await session.NotifyAsync(
            MethodId.SyncUnitPositionAndFacing,
            UxSerializer.Serialize(WorldCodec.PositionAndFacing(npc.Id, pos, npc.Facing)),
            token);

        session.Log.Info($"[NPC] 投放 '{npc.Name}' id={npc.Id} template={npc.TemplateId} at=({npc.X:F1},{npc.Y:F1},{npc.Z:F1})");
    }

    internal static async Task<string> RemoveStreetNpcAsync(TcpSession session, ulong id, CancellationToken token = default)
    {
        var state = GetStateIfExists(session);
        if (state is null)
            return "no live game session (is the client in the world?)";

        var removed = false;
        SessionState.Update(saved =>
        {
            var hit = saved.StreetNpcs.FirstOrDefault(x => x.Id == id);
            if (hit is not null)
            {
                saved.StreetNpcs.Remove(hit);
                removed = true;
            }
        });
        if (!removed)
            return $"street NPC {id} is not in the savegame";

        await session.NotifyAsync(
            MethodId.SyncLogicAgentLeave,
            UxSerializer.Serialize(WorldCodec.LogicAgentLeave(id)),
            token);

        session.Log.Info($"[NPC] 移除 id={id}");
        return $"removed street NPC {id}";
    }

    internal static async Task<string> RemoveAllStreetNpcsAsync(TcpSession session, CancellationToken token = default)
    {
        var state = GetStateIfExists(session);
        if (state is null)
            return "no live game session (is the client in the world?)";

        var ids = SessionState.Current.StreetNpcs.Select(x => x.Id).ToList();
        SessionState.Update(saved => saved.StreetNpcs.Clear());

        foreach (var id in ids)
            await session.NotifyAsync(
                MethodId.SyncLogicAgentLeave,
                UxSerializer.Serialize(WorldCodec.LogicAgentLeave(id)),
                token);

        session.Log.Info($"[NPC] 已清空放置的 NPC（{ids.Count} 个）");
        return $"removed {ids.Count} street NPC(s)";
    }

    
    internal static async Task PublishAllStreetNpcsAsync(TcpSession session, CancellationToken token = default)
    {
        var state = GetStateIfExists(session);
        if (state is null || !state.Ready)
            return;

        var npcs = SessionState.Current.StreetNpcs;
        if (npcs.Count == 0)
            return;

        session.Log.Info($"[NPC] 从存档重新投放 {npcs.Count} 个街道 NPC");
        foreach (var npc in npcs)
            await SpawnStreetNpcLiveAsync(session, npc, token);
    }

    
    internal static IReadOnlyList<StreetNpcRecord> StreetNpcs() => SessionState.Current.StreetNpcs;
}
