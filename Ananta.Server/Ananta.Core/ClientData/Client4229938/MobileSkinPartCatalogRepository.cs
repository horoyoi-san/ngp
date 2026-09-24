using System.Text.Json;
using Ananta.Server.Configuration;

namespace Ananta.Server.ClientData.Client4229938;

internal static class MobileSkinPartCatalogRepository
{
    private static readonly object Sync = new();
    private static uint[]? _all;
    private static Dictionary<uint, byte>? _types;

    
    internal static uint[] AllIds()
    {
        EnsureLoaded();
        lock (Sync)
            return _all!;
    }

    
    internal static uint[] IdsOfType(byte type)
    {
        EnsureLoaded();
        lock (Sync)
            return _types!.Where(x => x.Value == type).Select(x => x.Key).OrderBy(x => x).ToArray();
    }

    
    internal static uint[] WallpaperIds() => IdsOfType(0);

    private static void EnsureLoaded()
    {
        if (_all is not null)
            return;
        lock (Sync)
        {
            if (_all is not null)
                return;

            _all = [];
            _types = [];
            try
            {
                var config = PrivateServerConfigStore.Current;
                var root = PrivateServerConfigStore.ResolveProjectPath(config.Paths.ClientConfigs);
                var path = Path.Combine(root, "MobileMenuSkinPartConfig.json");
                if (!File.Exists(path))
                {
                    Console.WriteLine($"[PHONE] 找不到 MobileMenuSkinPartConfig: {path}");
                    return;
                }

                using var doc = JsonDocument.Parse(File.ReadAllText(path));
                if (!doc.RootElement.TryGetProperty("records", out var records)
                    || records.ValueKind != JsonValueKind.Array)
                {
                    Console.WriteLine("[PHONE] MobileMenuSkinPartConfig 没有 records 数组");
                    return;
                }

                var ids = new List<uint>();
                foreach (var row in records.EnumerateArray())
                {
                    if (!row.TryGetProperty("Id", out var idNode) || !idNode.TryGetUInt32(out var id) || id == 0)
                        continue;
                    ids.Add(id);
                    _types[id] = row.TryGetProperty("Type", out var t) && t.TryGetByte(out var tv) ? tv : (byte)0;
                }

                _all = [.. ids.Distinct().OrderBy(x => x)];
                var wp = _types.Count(x => x.Value == 0);
                Console.WriteLine($"[PHONE] MobileMenuSkinPartConfig 已载入: {_all.Length} 个部件（壁纸 {wp} 个）");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[PHONE] 载入 MobileMenuSkinPartConfig 失败: {ex.Message}");
            }
        }
    }
}
