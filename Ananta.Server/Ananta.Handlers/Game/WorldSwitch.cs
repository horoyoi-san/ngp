using System.Text.Json.Nodes;
using Ananta.SDK.Rpc;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using Ananta.Server.State;
using GameMethods = Ananta.Server.RpcTypes.Client4229938.Methods.Game;

namespace Ananta.Server.Handlers.Game;

internal static class WorldSwitch
{
    
    internal const uint NovaRaidId = 23300888;
    internal const uint NovaSceneId = 20001222;

    
    internal const uint ChongxiaoRaidId = 23300999;
    internal const uint ChongxiaoSceneId = 20001223;

    
    internal static WorldSwitchResult ByRaid(uint raidId)
    {
        var raid = ExtraCatalog.Raids.FirstOrDefault(r => r.Id == raidId);
        if (raid is null)
            return WorldSwitchResult.Failure($"RaidConfig 里没有 Id={raidId}");

        return Apply(raid.Id, raid.SceneId, raid.Name, $"raid {raidId} → scene {raid.SceneId} ({raid.Name})");
    }

    
    
    
    
    
    
    internal static WorldSwitchResult ByScene(uint sceneId)
    {
        var raid = ExtraCatalog.Raids.FirstOrDefault(r => r.SceneId == sceneId);
        if (raid is null)
            return WorldSwitchResult.Failure($"没有 RaidConfig 使用 SceneId={sceneId}");

        return Apply(raid.Id, sceneId, raid.Name, $"scene {sceneId} → raid {raid.Id} ({raid.Name})");
    }

    
    internal static WorldSwitchResult BySceneName(string keyword)
    {
        var raid = ExtraCatalog.Raids.FirstOrDefault(
            r => !string.IsNullOrEmpty(r.Name)
                 && r.Name.Contains(keyword, StringComparison.OrdinalIgnoreCase));
        if (raid is null)
            return WorldSwitchResult.Failure($"没有名字含「{keyword}」的 RaidConfig");

        return Apply(raid.Id, raid.SceneId, raid.Name, $"名称含「{keyword}」→ raid {raid.Id} ({raid.Name})");
    }

    private static WorldSwitchResult Apply(uint raidId, uint sceneId, string name, string detail)
    {
        try
        {
            var path = PrivateServerConfigStore.ConfigPath;
            var node = JsonNode.Parse(File.ReadAllText(path));
            if (node?["world"] is not JsonObject world)
                return WorldSwitchResult.Failure("配置里没有 world 段");

            
            
            
            
            
            
            
            var spawn = ExtraCatalog.MapEntrances
                .Where(e => e.RaidId == raidId && (e.X != 0f || e.Z != 0f))
                .Select(e => (e.X, e.Y, e.Z))
                .FirstOrDefault();
            if (spawn == default && raidId == NovaRaidId)
                spawn = (3142.67f, 0f, 2522.78f);   

            world["raidId"] = JsonValue.Create(raidId);
            world["sceneInstanceId"] = JsonValue.Create((ulong)sceneId);
            world["spawn"] = new JsonObject
            {
                ["x"] = JsonValue.Create(spawn.X),
                ["y"] = JsonValue.Create(spawn.Y),
                ["z"] = JsonValue.Create(spawn.Z),
            };
            world["facing"] = JsonValue.Create(0f);

            File.WriteAllText(path, node.ToJsonString(new System.Text.Json.JsonSerializerOptions { WriteIndented = true }));
            return WorldSwitchResult.Success(raidId, sceneId, name, detail, spawn.X, spawn.Y, spawn.Z);
        }
        catch (Exception ex)
        {
            return WorldSwitchResult.Failure($"写配置失败: {ex.Message}");
        }
    }

    
    
    
    
    internal static async Task NotifyClientAsync(RpcContext ctx, WorldSwitchResult result)
    {
        if (!result.Ok)
            return;

        if (ctx.Session.Items.TryGetValue(GameRouter.WorldStateKey, out var raw)
            && raw is Protocol.Client4229938.WorldEntryState state)
        {
            lock (state.SyncRoot)
            {
                state.EnterSceneSent = false;
                state.WorldEntrySceneId4229938 = 0;
                state.WorldEntrySessionId4229938 = 0;
            }
        }

        await ctx.NotifyAsync(MethodId.IGameToClient_SyncTeleport, new GameMethods.SyncTeleport4229938
        {
            teleportId = (ulong)DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(),
            Position = new RpcTypes.Client4229938.Auto.UXVector3
            {
                X = result.SpawnX, Y = result.SpawnY, Z = result.SpawnZ,
            },
            Facing = 0f,
            
            IsSwitchScene = true,
            WaitTaskResource = false,
        });

        ctx.Session.Log.Info(
            $"[WORLD-SWITCH] {result.Detail} → 已写 config.world(spawn=({result.SpawnX:F0},{result.SpawnY:F0},{result.SpawnZ:F0})) "
            + "并下发 SyncTeleport(IsSwitchScene=true)；客户端会走加载流程，服务端在下次进世界时用新 raid 发 SyncEnterScene");
    }
}

internal sealed record WorldSwitchResult(bool Ok, uint RaidId, uint SceneId, string Name, string Detail, string? Error, float SpawnX = 0f, float SpawnY = 0f, float SpawnZ = 0f)
{
    internal static WorldSwitchResult Success(uint raidId, uint sceneId, string name, string detail,
        float spawnX = 0f, float spawnY = 0f, float spawnZ = 0f)
        => new(true, raidId, sceneId, name, detail, null, spawnX, spawnY, spawnZ);

    internal static WorldSwitchResult Failure(string error)
        => new(false, 0, 0, string.Empty, string.Empty, error);
}
