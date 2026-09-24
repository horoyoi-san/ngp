using Ananta.SDK.Network;
using Ananta.SDK.Serialization;
using Ananta.Server.ClientData.Client4229938;
using Ananta.Server.Configuration;
using Ananta.Server.Protocol.Client4229938;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.Handlers.Game;

internal sealed partial class GameRouter
{
    
    private const string SceneAoiCellKey = "Ananta.sceneContentAoi.cell";

    
    private static (int X, int Z) ToGridIndex(float x, float z, float cellSize)
        => ((int)MathF.Floor(x / cellSize), (int)MathF.Floor(z / cellSize));

    
    private static List<SceneMethods.GridIndex4229938> BuildGridWindow(int cx, int cz, int radius)
    {
        var list = new List<SceneMethods.GridIndex4229938>((radius * 2 + 1) * (radius * 2 + 1));
        for (var dx = -radius; dx <= radius; dx++)
            for (var dz = -radius; dz <= radius; dz++)
                list.Add(new SceneMethods.GridIndex4229938 { X = cx + dx, Z = cz + dz });
        return list;
    }

    
    
    
    internal static async Task PublishSceneContentAoiAsync(
        TcpSession session, float x, float z, bool force, CancellationToken token)
    {
        var cfg = PrivateServerConfigStore.Current.World.SceneContentAoi;
        if (!cfg.Enabled)
            return;

        var cellSize = cfg.CellSizeMeters > 1f ? cfg.CellSizeMeters : 40f;
        var radius = Math.Clamp(cfg.RadiusCells, 1, 8);
        var (cx, cz) = ToGridIndex(x, z, cellSize);

        var first = true;
        lock (session.Items)
        {
            if (session.Items.TryGetValue(SceneAoiCellKey, out var raw)
                && raw is ValueTuple<int, int> prev)
            {
                first = false;
                if (!force && (!cfg.RepublishOnCellChange || (prev.Item1 == cx && prev.Item2 == cz)))
                    return;
            }
            session.Items[SceneAoiCellKey] = (cx, cz);
        }

        var reason = first
            ? SceneMethods.AoiAddAndRemoveReason4229938.Init
            : SceneMethods.AoiAddAndRemoveReason4229938.AOIMove;
        var window = BuildGridWindow(cx, cz, radius);
        var playerIndex = new SceneMethods.GridIndex4229938 { X = cx, Z = cz };

        
        var cellKeys = new List<(int X, int Z)>(window.Count);
        foreach (var g in window)
            cellKeys.Add((g.X, g.Z));
        var sectors = cfg.UseSectorFilter ? WorldCellTable.SectorsForWindow(cellKeys) : [0];

        
        if (first && cfg.ActivateSceneAoi)
        {
            await session.NotifyAsync(MethodId.SyncDestructibleSceneAOIActive,
                UxSerializer.Serialize(new SceneMethods.SyncDestructibleSceneAOIActive4229938 { active = true }),
                token);
            session.Log.Info("[SCENE-AOI] 已开启场景物 AOI（SyncDestructibleSceneAOIActive=true）");
        }

        
        if (cfg.Destructibles)
        {
            await session.NotifyAsync(MethodId.SyncDestructibleGridAOIDecrease,
                UxSerializer.Serialize(new SceneMethods.SyncDestructibleGridAOIDecrease4229938
                {
                    aoiInfo = new SceneMethods.DestructibleGridAOIIncrease4229938
                    {
                        PlayerStandardIndex = playerIndex,
                        IndexList = window,
                        Reason = reason,
                    },
                    addGridInfo = new SceneMethods.GridAOIDecrease4229938
                    {
                        SectorIdList = sectors,
                        BuildingId = 0,
                        StandardIndexList = window,
                        ExceptIds = [],
                    },
                    removeGridInfo = new SceneMethods.GridAOIDecrease4229938(),
                }), token);
        }

        
        if (cfg.Gadgets)
        {
            await session.NotifyAsync(MethodId.SyncGadgetGridAOIDecrease,
                UxSerializer.Serialize(new SceneMethods.SyncGadgetGridAOIDecrease4229938
                {
                    aoiInfo = new SceneMethods.GadgetGridAOIIncrease4229938
                    {
                        PlayerStandardIndex = playerIndex,
                        IndexList = window,
                        Reason = reason,
                    },
                    addGridInfo = new SceneMethods.GridAOIDecrease4229938
                    {
                        SectorIdList = sectors,
                        BuildingId = 0,
                        StandardIndexList = window,
                        ExceptIds = [],
                    },
                    removeGridInfo = new SceneMethods.GridAOIDecrease4229938(),
                    extraInfo = new SceneMethods.GadgetExtraSyncInfo4229938(),
                }), token);
        }

        session.Log.Info(
            $"[SCENE-AOI] 已下发场景内容网格 AOI 格子=({cx},{cz}) 窗口={window.Count}格 "
            + $"sector={sectors.Count} 个{(sectors.Count <= 12 ? "[" + string.Join(",", sectors) + "]" : "")} "
            + $"(边长 {cellSize:F0}m，半径 {radius}，原因 {reason}，"
            + $"gadget={cfg.Gadgets} destructible={cfg.Destructibles})");
    }

    
    internal static (int Activate, int Destructible, int Gadget, int Sectors) ProbeSceneContentBytes()
    {
        var activate = UxSerializer.Serialize(new SceneMethods.SyncDestructibleSceneAOIActive4229938 { active = true });

        var cfg = PrivateServerConfigStore.Current.World.SceneContentAoi;
        var radius = Math.Clamp(cfg.RadiusCells, 1, 8);
        var window = BuildGridWindow(0, 0, radius);
        var playerIndex = new SceneMethods.GridIndex4229938 { X = 0, Z = 0 };

        var cellKeys = new List<(int X, int Z)>(window.Count);
        foreach (var g in window)
            cellKeys.Add((g.X, g.Z));
        var sectors = WorldCellTable.SectorsForWindow(cellKeys);

        var dest = UxSerializer.Serialize(new SceneMethods.SyncDestructibleGridAOIDecrease4229938
        {
            aoiInfo = new SceneMethods.DestructibleGridAOIIncrease4229938
            {
                PlayerStandardIndex = playerIndex,
                IndexList = window,
                Reason = SceneMethods.AoiAddAndRemoveReason4229938.Init,
            },
            addGridInfo = new SceneMethods.GridAOIDecrease4229938
            {
                SectorIdList = sectors,
                StandardIndexList = window,
                ExceptIds = [],
            },
            removeGridInfo = new SceneMethods.GridAOIDecrease4229938(),
        });

        var gad = UxSerializer.Serialize(new SceneMethods.SyncGadgetGridAOIDecrease4229938
        {
            aoiInfo = new SceneMethods.GadgetGridAOIIncrease4229938
            {
                PlayerStandardIndex = playerIndex,
                IndexList = window,
                Reason = SceneMethods.AoiAddAndRemoveReason4229938.Init,
            },
            addGridInfo = new SceneMethods.GridAOIDecrease4229938
            {
                SectorIdList = sectors,
                StandardIndexList = window,
                ExceptIds = [],
            },
            removeGridInfo = new SceneMethods.GridAOIDecrease4229938(),
            extraInfo = new SceneMethods.GadgetExtraSyncInfo4229938(),
        });

        return (activate.Length, dest.Length, gad.Length, sectors.Count);
    }

    
    internal static void ProbeWorldCells(float x, float z)
    {
        var (cells, sectors, nonZero, maxPer) = WorldCellTable.Probe();
        Console.WriteLine($"[probe] 网格表 {cells} 格 / {sectors} 种 sector"
                          + $"（含非零 sector 的格 {nonZero}，单格最多 {maxPer} 个 sector）");

        var cellSize = PrivateServerConfigStore.Current.World.SceneContentAoi.CellSizeMeters;
        if (cellSize <= 1f)
            cellSize = 40f;
        var (cx, cz) = ToGridIndex(x, z, cellSize);
        var radius = Math.Clamp(PrivateServerConfigStore.Current.World.SceneContentAoi.RadiusCells, 1, 8);
        var window = BuildGridWindow(cx, cz, radius);
        var keys = new List<(int X, int Z)>(window.Count);
        foreach (var g in window)
            keys.Add((g.X, g.Z));
        var s = WorldCellTable.SectorsForWindow(keys);

        Console.WriteLine($"[probe] 出生点 ({x:F1},{z:F1}) → 格子 ({cx},{cz})，"
                          + $"半径 {radius} 窗口 {window.Count} 格 → sector 过滤表 {s.Count} 个：");
        Console.WriteLine($"[probe]   {string.Join(",", s)}");

        var (actBytes, destBytes, gadBytes, secCount) = ProbeSceneContentBytes();
        Console.WriteLine($"[probe] SyncDestructibleSceneAOIActive = {actBytes} 字节");
        Console.WriteLine($"[probe] SyncDestructibleGridAOIDecrease = {destBytes} 字节（sector {secCount} 个）");
        Console.WriteLine($"[probe] SyncGadgetGridAOIDecrease        = {gadBytes} 字节");
    }
}
