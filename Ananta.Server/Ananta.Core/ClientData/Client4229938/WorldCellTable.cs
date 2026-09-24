using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal static class WorldCellTable
{
    private static readonly Lazy<IReadOnlyDictionary<(int X, int Z), int[]>> Cache = new(Load);

    internal static IReadOnlyDictionary<(int X, int Z), int[]> Cells => Cache.Value;

    internal static int Count => Cache.Value.Count;

    
    internal static int[] SectorsAt(int cellX, int cellZ)
        => Cache.Value.TryGetValue((cellX, cellZ), out var s) ? s : [];

    
    
    
    
    
    
    internal static List<int> SectorsForWindow(IReadOnlyList<(int X, int Z)> window)
    {
        var set = new HashSet<int> { 0 };
        foreach (var (x, z) in window)
            if (Cache.Value.TryGetValue((x, z), out var secs))
                foreach (var s in secs)
                    set.Add(s);

        var list = new List<int>(set);
        list.Sort();
        return list;
    }

    internal static (int Cells, int Sectors, int NonZeroCells, int MaxSectorsPerCell) Probe()
    {
        var all = Cache.Value;
        var sectors = new HashSet<int>();
        var nonZero = 0;
        var max = 0;
        foreach (var v in all.Values)
        {
            if (v.Length > max)
                max = v.Length;
            var hasNonZero = false;
            foreach (var s in v)
            {
                sectors.Add(s);
                if (s != 0)
                    hasNonZero = true;
            }
            if (hasNonZero)
                nonZero++;
        }
        return (all.Count, sectors.Count, nonZero, max);
    }

    private static IReadOnlyDictionary<(int X, int Z), int[]> Load()
    {
        var result = new Dictionary<(int X, int Z), int[]>(8192);
        try
        {
            var path = PrivateServerConfigStore.ResolveProjectPath(
                PrivateServerConfigStore.Current.Paths.WorldCells);
            if (!File.Exists(path))
            {
                Console.WriteLine($"[CELLS] 找不到网格表 {path}"
                                  + "（跑 tools/gen_world_cells.py 生成；"
                                  + "缺了它场景物件/路灯/念动力目标不会加载）");
                return result;
            }

            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            if (!doc.RootElement.TryGetProperty("cells", out var cells)
                || cells.ValueKind != JsonValueKind.Object)
                return result;

            foreach (var prop in cells.EnumerateObject())
            {
                var comma = prop.Name.IndexOf(',');
                if (comma <= 0)
                    continue;
                if (!int.TryParse(prop.Name.AsSpan(0, comma), out var cx))
                    continue;
                if (!int.TryParse(prop.Name.AsSpan(comma + 1), out var cz))
                    continue;

                var list = new List<int>(4);
                if (prop.Value.ValueKind == JsonValueKind.Array)
                    foreach (var s in prop.Value.EnumerateArray())
                        if (s.TryGetInt32(out var sv))
                            list.Add(sv);

                result[(cx, cz)] = [.. list];
            }

            Console.WriteLine($"[CELLS] 网格表已载入 {result.Count} 格"
                              + $"（{path}）");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[CELLS] 网格表载入失败: {ex.GetType().Name}: {ex.Message}");
        }

        return result;
    }
}
