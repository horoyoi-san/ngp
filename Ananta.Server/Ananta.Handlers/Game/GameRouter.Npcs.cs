using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.RpcTypes.Client4229938;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    
    private static long _npcEntitySeq = 400000000000L;

    internal static async Task<string> SpawnNpcAsync(
        TcpSession session,
        uint templateId,
        Vec3 position,
        float facing = 0f,
        CancellationToken token = default)
    {
        if (templateId == 0)
            return "templateId must not be zero";

        var character = ClientConfigRepository.Characters()
            .FirstOrDefault(x => x.TemplateId == templateId);
        var agent = character is null ? AgentCatalogRepository.Find(templateId) : null;
        if (character is null && agent is null)
            return $"template {templateId} is in neither FightSpiritConfig nor AgentConfig";

        var label = character?.Name ?? agent!.Name;
        var kind = character is not null ? "character" : $"agent(species={agent!.SpeciesType},enemyClass={agent.EnemyClassType})";

        var state = GetStateIfExists(session);
        if (state is null)
            return "no live game session (is the client in the world?)";

        var entityId = (ulong)Interlocked.Increment(ref _npcEntitySeq);
        var projection = RuntimePayloadFactory.CharacterUnitProjection(templateId, position, facing);
        
        projection.ManagedPid = 0;
        projection.Id = entityId;

        await session.NotifyAsync(
            MethodId.SyncRaidBattleUnitSpirit,
            UxSerializer.Serialize(projection),
            token);
        session.Log.Info($"[NPC] SyncRaidBattleUnitSpirit template={templateId} name='{label}' {kind} entity={entityId} at=({position.X:F1},{position.Y:F1},{position.Z:F1})");
        return $"spawned {label} ({kind}) template={templateId} entity={entityId}";
    }

    
    internal static async Task<string> SpawnNpcNearPlayerAsync(
        TcpSession session,
        uint templateId,
        float distance = 4f,
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
        return await SpawnNpcAsync(session, templateId, target, yawDeg, token);
    }

    
    
    
    
    
    
    
    
    
    internal static async Task<string> SpawnEnemyGroupAsync(
        TcpSession session,
        int groupId,
        uint campId = 0,
        int memberCount = 0,
        CancellationToken token = default)
    {
        var state = GetStateIfExists(session);
        if (state is null)
            return "no live game session (is the client in the world?)";

        var groups = EnemyGroups();
        if (groups.Count == 0)
            return "RandomEnemyConfig has no usable enemy groups";

        if (groupId == 0)
            groupId = groups[0].Id;
        var group = groups.FirstOrDefault(x => x.Id == groupId);
        if (group.Id == 0)
            return $"enemy group {groupId} is not in RandomEnemyConfig (known: {string.Join(", ", groups.Take(8).Select(g => g.Id))}...)";

        if (campId == 0)
            campId = DefaultEnemyCampId();

        
        if (memberCount <= 0)
            memberCount = Math.Max(1, group.MemberCount);
        memberCount = Math.Clamp(memberCount, 1, 32);

        var instanceIds = new List<ulong>(memberCount);
        for (var i = 0; i < memberCount; i++)
            instanceIds.Add((ulong)Interlocked.Increment(ref _enemyInstanceSeq));

        await session.NotifyAsync(
            MethodId.SyncActiveWildEnemyGroup,
            UxSerializer.Serialize(new SceneMethods.SyncActiveWildEnemyGroup4229938
            {
                groupId = groupId,
                campId = campId,
                first = true,
                enemyInstanceIds = instanceIds,
            }),
            token);

        session.Log.Info($"[ENEMY] SyncActiveWildEnemyGroup group={groupId} '{group.Name}' camp={campId} members={memberCount} instances=[{string.Join(",", instanceIds)}]");
        return $"activated enemy group {groupId} '{group.Name}' camp={campId} members={memberCount}";
    }

    
    private static long _enemyInstanceSeq = 500000000000L;

    internal readonly record struct EnemyGroupInfo(int Id, string Name, int MemberCount);

    private static List<EnemyGroupInfo>? _enemyGroups;

    
    internal static List<EnemyGroupInfo> EnemyGroups()
    {
        if (_enemyGroups is not null)
            return _enemyGroups;
        var groups = new List<EnemyGroupInfo>();
        try
        {
            var config = PrivateServerConfigStore.Current;
            var root = PrivateServerConfigStore.ResolveProjectPath(config.Paths.ClientConfigs);
            var path = Path.Combine(root, "RandomEnemyConfig.json");
            if (File.Exists(path))
            {
                using var document = System.Text.Json.JsonDocument.Parse(File.ReadAllText(path));
                if (document.RootElement.TryGetProperty("records", out var records)
                    && records.ValueKind == System.Text.Json.JsonValueKind.Array)
                {
                    foreach (var row in records.EnumerateArray())
                    {
                        if (!row.TryGetProperty("Id", out var idNode) || !idNode.TryGetInt32(out var id) || id == 0)
                            continue;
                        var name = row.TryGetProperty("Name", out var nameNode)
                            ? nameNode.GetString() ?? string.Empty
                            : string.Empty;
                        var members = 0;
                        if (row.TryGetProperty("MonsterList", out var list)
                            && list.ValueKind == System.Text.Json.JsonValueKind.Array)
                            members = list.GetArrayLength();
                        
                        if (members == 0)
                            continue;
                        groups.Add(new EnemyGroupInfo(id, string.IsNullOrWhiteSpace(name) ? $"group {id}" : name, members));
                    }
                }
            }
            Console.WriteLine($"[ENEMY] RandomEnemyConfig 已载入: {groups.Count} 个可用敌人组");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[ENEMY] 载入 RandomEnemyConfig 失败: {ex.Message}");
        }
        _enemyGroups = groups;
        return _enemyGroups;
    }

    
    private static uint DefaultEnemyCampId()
    {
        try
        {
            var config = PrivateServerConfigStore.Current;
            var root = PrivateServerConfigStore.ResolveProjectPath(config.Paths.ClientConfigs);
            var path = Path.Combine(root, "BattleCampConfig.json");
            if (File.Exists(path))
            {
                using var document = System.Text.Json.JsonDocument.Parse(File.ReadAllText(path));
                if (document.RootElement.TryGetProperty("records", out var records)
                    && records.ValueKind == System.Text.Json.JsonValueKind.Array)
                {
                    foreach (var row in records.EnumerateArray())
                        if (row.TryGetProperty("Id", out var id) && id.TryGetUInt32(out var value) && value != 0)
                            return value;
                }
            }
        }
        catch
        {
            
        }
        return 3;
    }

    
    
    
    
    
    
    internal static async Task<string> SpawnEnemyAsync(
        TcpSession session,
        uint templateId,
        int count = 1,
        float distance = 6f,
        CancellationToken token = default)
    {
        var state = GetStateIfExists(session);
        if (state is null)
            return "no live game session (is the client in the world?)";

        if (count < 1)
            count = 1;
        if (count > 20)
            count = 20;

        Vec3 origin;
        float yawDeg;
        lock (state.SyncRoot)
        {
            origin = state.LastReportedPlayerPosition;
            yawDeg = state.LastReportedPlayerRotation.Y;
        }
        if (!float.IsFinite(yawDeg))
            yawDeg = Profile.WorldFacing;

        var spawned = 0;
        for (var i = 0; i < count; i++)
        {
            
            var spread = (i - (count - 1) / 2f) * 2.2f;
            var yawRad = (yawDeg + spread * 3f) * (float)Math.PI / 180f;
            var position = new Vec3(
                origin.X + (float)Math.Sin(yawRad) * distance,
                origin.Y + 0.5f,
                origin.Z + (float)Math.Cos(yawRad) * distance);

            var entityId = (ulong)Interlocked.Increment(ref _npcEntitySeq);
            var projection = RuntimePayloadFactory.CharacterUnitProjection(templateId, position, yawDeg);
            projection.ManagedPid = 0;
            projection.Id = entityId;
            projection.IsBot = true;

            await session.NotifyAsync(MethodId.SyncRaidBattleUnitSpirit, UxSerializer.Serialize(projection), token);

            
            await session.NotifyAsync(MethodId.SyncUnitHp,
                UxSerializer.Serialize(CombatCodec.UnitHp(entityId, CombatCodec.MaxHp)), token);

            spawned++;
        }

        
        var agent = AgentCatalogRepository.Find(templateId);
        var character = ClientConfigRepository.Characters().FirstOrDefault(x => x.TemplateId == templateId);
        var label = character?.Name ?? agent?.Name ?? "unknown";
        var kind = character is not null
            ? "character"
            : agent is null ? "unresolved-template" : $"agent(species={agent.SpeciesType},enemyClass={agent.EnemyClassType})";

        session.Log.Info($"[ENEMY] spawned {spawned}x template={templateId} name='{label}' {kind} at=({origin.X:F1},{origin.Y:F1},{origin.Z:F1})");
        return $"spawned {spawned}x '{label}' ({kind}) template={templateId}";
    }

    
    
    
    
    
    
    internal static async Task<string> GiveAmmoAsync(
        TcpSession session,
        uint count = 999,
        uint templateId = 0,
        CancellationToken token = default)
    {
        
        var ids = templateId != 0
            ? new List<uint> { templateId }
            : AmmoTemplateIds().ToList();
        if (ids.Count == 0)
            return "no ammunition ids are known (CombatCatalog/SceneitemConfig gave none)";

        var granted = 0;
        var failures = new List<string>();
        foreach (var id in ids)
        {
            var result = await GrantItemAsync(session, id, count, token);
            if (result.Contains("no live game session", StringComparison.OrdinalIgnoreCase))
                return result;
            if (result.Contains("granted", StringComparison.OrdinalIgnoreCase)
                || result.Contains("updated", StringComparison.OrdinalIgnoreCase)
                || result.Contains("stack", StringComparison.OrdinalIgnoreCase))
                granted++;
            else
                failures.Add($"{id}: {result}");
        }

        var summary = $"gave {count}x ammo for {granted}/{ids.Count} template(s)";
        if (failures.Count > 0)
            summary += $" | first failure: {failures[0]}";
        session.Log.Info($"[AMMO] {summary}");
        return summary;
    }
}
