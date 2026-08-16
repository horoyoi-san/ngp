using System;
using System.Collections.Generic;
using AnantaTestGameServer.Configs;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// Pre-defined NPC spawn positions organized by AOI grid cell.
    /// Positions are placed along streets/sidewalks, not in a grid.
    /// Each cell gets 1-3 NPCs at fixed offsets from the cell center.
    /// </summary>
    public static class NpcPlacementRegistry
    {
        // NPC formwork IDs — from config
        private static readonly uint[] AutoSpawnFormworks = GameConfig.AutoSpawnNpcIds.Length > 0
            ? GameConfig.AutoSpawnNpcIds
            : State.NpcStateFactory.BuildAutoSpawnNpcIds();

        // Fashion suits — from config
        private static readonly uint[] FashionSuits = GameConfig.FashionSuits.Length > 0
            ? GameConfig.FashionSuits
            : new uint[] { 11190001, 11190002, 11190003, 11190004, 11190005, 11190006 };

        // NPCs per cell — from config
        private static int MinNpcsPerCell => GameConfig.MinNpcsPerCell;
        private static int MaxNpcsPerCell => GameConfig.MaxNpcsPerCell;

        // Spawn/despawn ranges — from config
        public static int SpawnRadius => GameConfig.SpawnRadius;
        public static int DespawnRadius => GameConfig.DespawnRadius;
        public static int MaxAliveNpcs => GameConfig.MaxAliveNpcs;

        /// <summary>
        /// Street offset patterns — positions relative to cell center that simulate
        /// NPCs standing on sidewalks or walking along streets.
        /// Each pattern is (offsetX, offsetZ) in world units from cell center.
        /// Sidewalks are typically 15-18 units from road center in a 40-unit cell.
        /// </summary>
        private static readonly (float X, float Z)[] StreetPatterns = new (float, float)[]
        {
            // Sidewalk positions (offset from cell center - closer to cell edges)
            (18f, 0f),       // right sidewalk
            (-18f, 0f),      // left sidewalk
            (0f, 18f),       // top sidewalk
            (0f, -18f),      // bottom sidewalk
            (16f, 16f),     // corner top-right
            (-16f, -16f),   // corner bottom-left
            (16f, -16f),    // corner bottom-right
            (-16f, 16f),    // corner top-left
            (12f, 18f),      // along street edge
            (-12f, -18f),    // along street edge
            (18f, 12f),      // perpendicular
            (-18f, -12f),    // perpendicular
        };

        /// <summary>
        /// Get NPC spawn entries for a specific grid cell.
        /// Returns deterministic but varied NPCs based on cell coordinates.
        /// </summary>
        public static List<NpcPlacementEntry> GetNpcsForCell(int cellX, int cellZ)
        {
            var entries = new List<NpcPlacementEntry>();

            // Deterministic seed from cell coordinates
            int seed = cellX * 73856093 ^ cellZ * 19349663;
            var rng = new Random(seed);

            // Skip cells that are too close to origin (0,0) — that's where players start
            // and we don't want NPCs spawning right on top of them
            int distFromOrigin = cellX * cellX + cellZ * cellZ;
            if (distFromOrigin < 4) // within 2 cells of origin
                return entries;

            // Number of NPCs for this cell
            int count = rng.Next(MinNpcsPerCell, MaxNpcsPerCell + 1);

            // Cell center in world coordinates
            float cellCenterX = cellX * AOIGridManager.GridCellSize + AOIGridManager.GridOffsetX + AOIGridManager.GridCellSize * 0.5f;
            float cellCenterZ = cellZ * AOIGridManager.GridCellSize + AOIGridManager.GridOffsetZ + AOIGridManager.GridCellSize * 0.5f;

            for (int i = 0; i < count; i++)
            {
                // Pick a street pattern offset
                var pattern = StreetPatterns[rng.Next(StreetPatterns.Length)];

                // Add small random jitter to avoid perfect alignment
                float jitterX = (float)(rng.NextDouble() * 4.0 - 2.0);
                float jitterZ = (float)(rng.NextDouble() * 4.0 - 2.0);

                float worldX = cellCenterX + pattern.X + jitterX;
                float worldZ = cellCenterZ + pattern.Z + jitterZ;

                // Pick a random formwork and fashion
                uint formworkId = AutoSpawnFormworks[rng.Next(AutoSpawnFormworks.Length)];
                uint fashionId = FashionSuits[rng.Next(FashionSuits.Length)];
                float facing = (float)(rng.NextDouble() * 360.0);

                entries.Add(new NpcPlacementEntry
                {
                    CellX = cellX,
                    CellZ = cellZ,
                    WorldX = worldX,
                    WorldY = 0,
                    WorldZ = worldZ,
                    Facing = facing,
                    FormworkId = formworkId,
                    FashionId = fashionId,
                });
            }

            return entries;
        }

        /// <summary>
        /// Compute which cells should have NPCs spawned given the player's grid position.
        /// Returns cells within SpawnRadius that haven't been spawned yet.
        /// </summary>
        public static HashSet<(int X, int Z)> GetCellsToSpawn(int playerGridX, int playerGridZ,
            HashSet<(int X, int Z)> alreadySpawned, int customRadius = -1)
        {
            var result = new HashSet<(int, int)>();
            int radius = customRadius > 0 ? customRadius : SpawnRadius;
            int spawnRadiusSq = radius * radius;

            for (int dx = -radius; dx <= radius; dx++)
            {
                for (int dz = -radius; dz <= radius; dz++)
                {
                    if (dx * dx + dz * dz > spawnRadiusSq) continue;

                    var cell = (playerGridX + dx, playerGridZ + dz);
                    if (!alreadySpawned.Contains(cell))
                    {
                        result.Add(cell);
                    }
                }
            }

            return result;
        }

        /// <summary>
        /// Compute which cells are now out of range and should have NPCs despawned.
        /// </summary>
        public static HashSet<(int X, int Z)> GetCellsToDespawn(int playerGridX, int playerGridZ,
            HashSet<(int X, int Z)> spawnedCells, int customRadius = -1)
        {
            var result = new HashSet<(int, int)>();
            int radius = customRadius > 0 ? customRadius : DespawnRadius;
            int despawnRadiusSq = radius * radius;

            foreach (var cell in spawnedCells)
            {
                int dx = cell.X - playerGridX;
                int dz = cell.Z - playerGridZ;
                if (dx * dx + dz * dz > despawnRadiusSq)
                {
                    result.Add(cell);
                }
            }

            return result;
        }

        public class NpcPlacementEntry
        {
            public int CellX;
            public int CellZ;
            public float WorldX;
            public float WorldY;
            public float WorldZ;
            public float Facing;
            public uint FormworkId;
            public uint FashionId;
        }
    }
}
