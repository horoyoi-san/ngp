using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// Loads real scene item placement data from extracted/world_data/sceneitem_placements.json.
    /// This provides actual game world objects with real positions, config IDs, and path hashes.
    /// Used by AOIGridManager to populate addInfos with real placement data.
    /// </summary>
    public static class SceneItemPlacementLoader
    {
        private static Dictionary<(int cellX, int cellZ), List<PlacementEntry>> _cells = new();
        private static int _totalEntries = 0;
        private static bool _loaded = false;

        public class PlacementEntry
        {
            public int cellX { get; set; }
            public int cellZ { get; set; }
            public long pathId { get; set; }
            public uint tmpl { get; set; }
            public float[] pos { get; set; }
            public float[] euler { get; set; }
            public int sector { get; set; }
            public ulong uid { get; set; }
            public bool canMind { get; set; }
            public bool canBreak { get; set; }
        }

        public static bool IsLoaded => _loaded;
        public static int TotalEntries => _totalEntries;
        public static int CellCount => _cells.Count;

        public static void Load(string basePath)
        {
            string jsonPath = Path.Combine(basePath, "sceneitem_placements.json");
            if (!File.Exists(jsonPath))
            {
                Console.WriteLine($"[SceneItems] placements file not found: {jsonPath}");
                return;
            }

            try
            {
                Console.WriteLine($"[SceneItems] Loading placements from {jsonPath}...");
                string json = File.ReadAllText(jsonPath);
                var options = new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true,
                    AllowTrailingCommas = true,
                    ReadCommentHandling = JsonCommentHandling.Skip,
                };
                var entries = JsonSerializer.Deserialize<List<PlacementEntry>>(json, options);

                if (entries == null || entries.Count == 0)
                {
                    Console.WriteLine("[SceneItems] No entries loaded");
                    return;
                }

                // Index by cell
                _cells.Clear();
                foreach (var entry in entries)
                {
                    // Skip entries with no valid template (tmpl=1 means no template)
                    if (entry.tmpl <= 1) continue;

                    var key = (entry.cellX, entry.cellZ);
                    if (!_cells.ContainsKey(key))
                        _cells[key] = new List<PlacementEntry>();
                    _cells[key].Add(entry);
                }

                _totalEntries = entries.Count;
                _loaded = true;
                int validEntries = _cells.Values.Sum(l => l.Count);
                Console.WriteLine($"[SceneItems] Loaded {_totalEntries} total entries, {validEntries} with valid templates across {_cells.Count} cells");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SceneItems] Error loading placements: {ex.Message}");
            }
        }

        /// <summary>
        /// Get placement entries for a specific blob grid cell.
        /// </summary>
        public static List<PlacementEntry> GetCellEntries(int cellX, int cellZ)
        {
            if (_cells.TryGetValue((cellX, cellZ), out var entries))
                return entries;
            return new List<PlacementEntry>();
        }

        /// <summary>
        /// Get all placement entries within a set of blob grid cells.
        /// </summary>
        public static List<PlacementEntry> GetEntriesForCells(HashSet<(int X, int Z)> cells)
        {
            var result = new List<PlacementEntry>();
            foreach (var (x, z) in cells)
            {
                if (_cells.TryGetValue((x, z), out var entries))
                    result.AddRange(entries);
            }
            return result;
        }

        /// <summary>
        /// Get all placement entries within range of a world position.
        /// Converts world position to blob grid cell using AOIGridManager settings.
        /// </summary>
        public static List<PlacementEntry> GetEntriesNearWorldPosition(float worldX, float worldZ, float worldRange)
        {
            var (centerX, centerZ) = AOIGridManager.WorldToGrid(worldX, worldZ);
            int cellRange = (int)MathF.Ceiling(worldRange / AOIGridManager.GridCellSize);
            var result = new List<PlacementEntry>();

            for (int dx = -cellRange; dx <= cellRange; dx++)
            {
                for (int dz = -cellRange; dz <= cellRange; dz++)
                {
                    var key = (centerX + dx, centerZ + dz);
                    if (_cells.TryGetValue(key, out var entries))
                        result.AddRange(entries);
                }
            }
            return result;
        }
    }
}
