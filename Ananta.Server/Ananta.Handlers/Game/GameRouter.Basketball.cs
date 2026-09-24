using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using GadgetMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    
    private static GadgetMethods.GadgetEntityInfo4229938 BuildCourtGadget(
        BasketballCourt template, ulong instanceId, float x, float y, float z, float yaw)
    {
        var facing = yaw * MathF.PI / 180f;
        return new GadgetMethods.GadgetEntityInfo4229938
        {
            InstanceId = instanceId,
            Position = new RpcTypes.Client4229938.Auto.UXVector3 { X = x, Y = y, Z = z },
            Facing = new RpcTypes.Client4229938.Auto.UXVector3 { X = 0f, Y = facing, Z = 0f },
            NavId = 0,
            ChildNavIds = [],
            ForceLod0 = false,
            IsTask = false,
            Pack = new GadgetMethods.PackedGadgetInfo4229938
            {
                posX = x,
                posY = y,
                posZ = z,
                eulerX = 0f,
                eulerY = yaw,
                eulerZ = 0f,
                iScale = 0,
                uniqueId = instanceId,
                pathId = template.PathId,
                spoonSpecialList = [],
                delayDestroy = false,
                startTaskId = 0,
                endTaskId = 0,
                extractionItemContainerId = 0,
                isStatic = true,
            },
        };
    }

    
    
    
    internal static async Task PublishBasketballCourtsAsync(
        TcpSession session, float x, float z, CancellationToken token)
    {
        var cfg = PrivateServerConfigStore.Current.Gameplay.Basketball;
        if (!cfg.Enabled || BasketballCourtTable.Count == 0)
            return;

        var spawn = PrivateServerConfigStore.Current.World.Spawn;
        var nearestPlayable = BasketballCourtTable.Nearest(spawn.X, spawn.Z, playableOnly: true);
        var nearestAny = BasketballCourtTable.Nearest(x, z);

        if (cfg.LogNearestOnWorldEntry)
        {
            if (nearestPlayable is not null)
            {
                session.Log.Info(
                    $"[BASKETBALL] 可对局球场 {BasketballCourtTable.Playable.Count} 个；"
                    + $"最近的一个 #{nearestPlayable.ConfigId}"
                    + $"（ballId={nearestPlayable.BasketballId}）在 "
                    + $"({nearestPlayable.X:F1}, {nearestPlayable.Y:F1}, {nearestPlayable.Z:F1})，"
                    + $"离出生点 {nearestPlayable.DistanceTo(spawn.X, spawn.Z):F0}m"
                    + (cfg.SpawnAtCourt ? "（spawnAtCourt=已把出生点改到球场）"
                                        : "（想直接出生在球场：gameplay.basketball.spawnAtCourt=true）"));
            }
            if (nearestAny is not null)
            {
                session.Log.Info(
                    $"[BASKETBALL] 离当前位置最近的是 {(nearestAny.Playable ? "可对局" : "练习")}场 "
                    + $"{nearestAny.Prefab} @ ({nearestAny.X:F1}, {nearestAny.Y:F1}, {nearestAny.Z:F1})，"
                    + $"距离 {nearestAny.DistanceTo(x, z):F0}m");
            }
        }

        if (!cfg.ExplicitSpawnEnabled)
            return;

        var template = BasketballCourtTable.TryGetPlayable(cfg.ExplicitSpawnCourtId)
                       ?? BasketballCourtTable.Playable.FirstOrDefault();
        if (template is null)
        {
            session.Log.Warn("[BASKETBALL] 找不到可对局球场模板，跳过显式生成");
            return;
        }

        
        
        var px = x + cfg.ExplicitSpawnOffsetX;
        var pz = z + cfg.ExplicitSpawnOffsetZ;
        var info = BuildCourtGadget(template, template.UniqueId, px, template.Y, pz, template.EulerY);

        await session.NotifyAsync(
            MethodId.SyncGadgetAOIAddAndRemove,
            UxSerializer.Serialize(new GadgetMethods.SyncGadgetAOIAddAndRemove4229938
            {
                addInfos = [info],
                addPackSyncInfos = [],
                removeIds = [],
                activeIds = [],
                inactiveIds = [],
                reason = GadgetMethods.AoiAddAndRemoveReason4229938.Init,
            }),
            token);

        session.Log.Info(
            $"[BASKETBALL] 已显式投放球场实例 uid={template.UniqueId}"
            + $"（pathId={template.PathId}）到 ({px:F1}, {template.Y:F1}, {pz:F1})");
    }

    
    internal static void ProbeBasketball()
    {
        var all = BasketballCourtTable.All;
        var playable = BasketballCourtTable.Playable;

        Console.WriteLine($"[probe] 球场总数 {all.Count}"
                          + $"（世界 {all.Count(static c => c.PathId == BasketballCourt.PathScene)}，"
                          + $"raid {all.Count(static c => c.PathId == BasketballCourt.PathRaid)}）");
        Console.WriteLine($"[probe] 可对局（带 BasketBallCourtConfig）{playable.Count} 个：");
        foreach (var c in playable.OrderBy(static c => c.ConfigId))
        {
            Console.WriteLine(
                $"          #{c.ConfigId} ballId={c.BasketballId} uid={c.UniqueId}"
                + $" ({c.X:F1}, {c.Y:F1}, {c.Z:F1}) yaw={c.EulerY:F1} scene={c.Scene}");
        }

        var cfg = PrivateServerConfigStore.Current.Gameplay.Basketball;
        var spawn = PrivateServerConfigStore.Current.World.Spawn;
        var effective = Profile.WorldSpawn;
        Console.WriteLine($"[probe] world.spawn = ({spawn.X:F1}, {spawn.Y:F1}, {spawn.Z:F1})");
        Console.WriteLine($"[probe] 生效出生点 Profile.WorldSpawn = "
                          + $"({effective.X:F1}, {effective.Y:F1}, {effective.Z:F1})"
                          + (cfg.SpawnAtCourt ? "  ← 已被篮球场覆盖" : "  ← 未覆盖（spawnAtCourt=false）"));

        var nearest = BasketballCourtTable.Nearest(spawn.X, spawn.Z, playableOnly: true);
        if (nearest is not null)
        {
            Console.WriteLine($"[probe] 出生点 ({spawn.X:F1}, {spawn.Y:F1}, {spawn.Z:F1})"
                              + $" → 最近可对局球场 #{nearest.ConfigId}"
                              + $" 距离 {nearest.DistanceTo(spawn.X, spawn.Z):F0}m");
        }

        
        var template = playable.FirstOrDefault();
        if (template is not null)
        {
            var info = BuildCourtGadget(template, template.UniqueId, spawn.X + 20f, spawn.Y, spawn.Z + 20f, 0f);
            var body = UxSerializer.Serialize(new GadgetMethods.SyncGadgetAOIAddAndRemove4229938
            {
                addInfos = [info],
                reason = GadgetMethods.AoiAddAndRemoveReason4229938.Init,
            });
            Console.WriteLine($"[probe] SyncGadgetAOIAddAndRemove 单球场包 = {body.Length} 字节");
            Console.WriteLine($"[probe]   头 32 字节 {Convert.ToHexString(body.AsSpan(0, Math.Min(32, body.Length)))}");
        }

        Console.WriteLine($"[probe] spawnAtCourt={cfg.SpawnAtCourt} "
                          + $"spawnCourtId={cfg.SpawnCourtId} "
                          + $"explicitSpawnEnabled={cfg.ExplicitSpawnEnabled}");
    }
}
