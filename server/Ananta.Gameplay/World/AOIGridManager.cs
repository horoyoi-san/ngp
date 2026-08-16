using System;
using System.Collections.Generic;
using System.Linq;
using AnantaTestGameServer.Configs;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// AOI Grid Driver — tells the client which world grid cells to load.
    ///
    /// The Ananta client has a complete blob-based world loading system (SimpleGrid +
    /// SceneItemBlobGrid + DestructibleBlobGrid) but it is never driven by the private
    /// server. This manager tracks the player's grid position and sends
    /// SyncDestructibleGridAOIIncrease / SyncDestructibleGridAOIDecrease packets so
    /// the client loads the correct world cells from its local blob data.
    ///
    /// Architecture (from DLL reverse engineering):
    ///   - SimpleGrid.Range = 40 cells base
    ///   - SceneItemBlobGrid viewDistance = 40
    ///   - DestructibleBlobGrid viewDistance = 120
    ///   - Grid cell size = GridCellSize (configurable, discovered via frida_hook)
    ///   - Client reads BlobHeadInfo[seekIndex] → binary chunk → placement records → spawn
    /// </summary>
    public static class AOIGridManager
    {
        // ═══════════════════════════════════════════════════════════════
        // CONFIGURATION — adjust GridCellSize after running grid_calibration.py
        // ═══════════════════════════════════════════════════════════════

        /// <summary>
        /// World-unit size of one grid cell. Discovered via frida_hook grid_calibration:
        /// SimpleGrid bounds min=(-1576,-1481) max=(6441,6201) size=(201,193)
        /// cellSize = (6441-(-1576))/201 = 39.89 ≈ 40
        /// Adjustable at runtime: /gm/aoi/cellsize?value=X
        /// </summary>
        public static float GridCellSize = GameConfig.GridCellSize;

        /// <summary>
        /// Grid origin offset. Client formula: gridIndex = floor((worldPos - offset) / cellSize).
        /// From frida calibration: player world(3009.7, 1620.9) = grid(25, 50) with cellSize=40:
        ///   offsetX = 3009.7 - 25*40 = 2009.7 ≈ 2010
        ///   offsetZ = 1620.9 - 50*40 = -379.1 ≈ -379
        /// Adjustable at runtime: /gm/aoi/offset?x=X&amp;z=Z
        /// </summary>
        public static float GridOffsetX = GameConfig.GridOffsetX;
        public static float GridOffsetZ = GameConfig.GridOffsetZ;

        /// <summary>Destructible view range in grid cells (from DLL: DestructibleBlobGrid viewDistance=120).</summary>
        public static int DestructibleRange = GameConfig.DestructibleRange;

        /// <summary>Scene item view range in grid cells (from DLL: SceneItemBlobGrid viewDistance=40).</summary>
        public static int SceneItemRange = GameConfig.SceneItemRange;

        /// <summary>Maximum cells to send per AOI update (safety cap to avoid huge packets).</summary>
        public const int MaxCellsPerUpdate = 5000;

        /// <summary>Speed threshold (m/s) for considering player as moving fast (vehicle/flight).</summary>
        public const float FastMovementThreshold = 15.0f; // ~54 km/h

        /// <summary>Multiplied spawn radius when moving fast.</summary>
        public const float FastMovementRadiusMultiplier = 2.0f;

        // ═══════════════════════════════════════════════════════════════
        // GRID MATH
        // ═══════════════════════════════════════════════════════════════

        /// <summary>Convert world position to grid cell coordinates (with offset).</summary>
        public static (int X, int Z) WorldToGrid(float worldX, float worldZ)
        {
            return ((int)MathF.Floor((worldX - GridOffsetX) / GridCellSize),
                    (int)MathF.Floor((worldZ - GridOffsetZ) / GridCellSize));
        }

        /// <summary>Compute the set of visible grid cells around a center cell (circular range).</summary>
        public static HashSet<(int X, int Z)> ComputeVisibleCells(int centerX, int centerZ, int range)
        {
            var cells = new HashSet<(int, int)>();
            int rangeSq = range * range;
            for (int dx = -range; dx <= range; dx++)
            {
                for (int dz = -range; dz <= range; dz++)
                {
                    if (dx * dx + dz * dz <= rangeSq)
                    {
                        cells.Add((centerX + dx, centerZ + dz));
                    }
                }
            }
            return cells;
        }

        // ═══════════════════════════════════════════════════════════════
        // INITIAL AOI — sent after scene load
        // ═══════════════════════════════════════════════════════════════

        /// <summary>
        /// Send initial AOI grid data after the player finishes loading a scene.
        /// This is the critical packet that tells the client to load world cells.
        /// Called after SyncSceneLoadCompleted in AskLoadingFinished / AskLoadSceneCompleted.
        /// </summary>
        public static void SendInitialAOI(Connection conn)
        {
            var pos = conn.LastKnownPlayerPosition;
            var (gx, gz) = WorldToGrid(pos.X, pos.Z);

            Console.WriteLine($"[AOI] SendInitialAOI: world=({pos.X:F1},{pos.Y:F1},{pos.Z:F1}) grid=({gx},{gz}) cellSize={GridCellSize}");

            // Reset state for new scene
            conn.LoadedDestructibleCells.Clear();
            conn.LoadedSceneItemCells.Clear();
            conn.LastGridX = gx;
            conn.LastGridZ = gz;

            // Compute visible cells for destructibles (larger range)
            var destructibleCells = ComputeVisibleCells(gx, gz, DestructibleRange);

            // Send DestructibleGridAOIIncrease with reason=Loaded
            SendDestructibleAOIIncrease(conn, gx, gz, destructibleCells, AoiAddAndRemoveReason.Loaded);

            // Track loaded cells
            conn.LoadedDestructibleCells = destructibleCells;

            // Also send for scene items (smaller range) — uses the same packet type
            // In the real server these are separate systems, but the destructible AOI
            // covers the most important world objects
            var sceneCells = ComputeVisibleCells(gx, gz, SceneItemRange);
            conn.LoadedSceneItemCells = sceneCells;

            conn.AOIInitialized = true;

            Console.WriteLine($"[AOI] Initial AOI sent: {destructibleCells.Count} destructible cells, {sceneCells.Count} scene item cells");

            // Kick off progressive NPC spawn for initial position
            WorldPopulationBuilder.OnPlayerCellChanged(conn, gx, gz);
        }

        // ═══════════════════════════════════════════════════════════════
        // MOVEMENT TRACKING — called when player position changes
        // ═══════════════════════════════════════════════════════════════

        /// <summary>
        /// Check if the player moved to a new grid cell and send AOI updates.
        /// Called from Connection.TryRememberUnitMoveActionPosition after updating LastKnownPlayerPosition.
        /// </summary>
        public static void OnPlayerMoved(Connection conn)
        {
            if (!conn.AOIInitialized) return;

            var pos = conn.LastKnownPlayerPosition;
            var (gx, gz) = WorldToGrid(pos.X, pos.Z);

            // Calculate player speed
            float speed = CalculatePlayerSpeed(conn);
            bool isMovingFast = speed > FastMovementThreshold;

            // Only process if the player actually changed grid cell OR moving fast
            if (gx == conn.LastGridX && gz == conn.LastGridZ && !isMovingFast)
                return;

            conn.LastGridX = gx;
            conn.LastGridZ = gz;

            // Use larger range when moving fast (vehicle/flight)
            int effectiveDestructibleRange = isMovingFast ?
                (int)(DestructibleRange * 1.5f) : DestructibleRange;
            int effectiveSceneRange = isMovingFast ?
                (int)(SceneItemRange * 1.5f) : SceneItemRange;

            // Compute new visible cells
            var newDestructibleCells = ComputeVisibleCells(gx, gz, effectiveDestructibleRange);

            // Compute diff
            var added = new HashSet<(int, int)>(newDestructibleCells);
            added.ExceptWith(conn.LoadedDestructibleCells);

            var removed = new HashSet<(int, int)>(conn.LoadedDestructibleCells);
            removed.ExceptWith(newDestructibleCells);

            // Send increase for new cells
            if (added.Count > 0 && added.Count <= MaxCellsPerUpdate)
            {
                SendDestructibleAOIIncrease(conn, gx, gz, added, AoiAddAndRemoveReason.AOIMove);
            }

            // Send decrease for removed cells
            if (removed.Count > 0 && removed.Count <= MaxCellsPerUpdate)
            {
                SendDestructibleAOIDecrease(conn, removed);
            }

            // Update tracked cells
            conn.LoadedDestructibleCells = newDestructibleCells;

            // Same for scene items
            var newSceneCells = ComputeVisibleCells(gx, gz, effectiveSceneRange);
            conn.LoadedSceneItemCells = newSceneCells;

            if (added.Count > 0 || removed.Count > 0)
            {
                Console.WriteLine($"[AOI] Player moved to grid ({gx},{gz}) speed={speed:F1}m/s: +{added.Count} -{removed.Count} cells (fast={isMovingFast})");
            }

            // Progressive NPC spawn/despawn based on cell change with speed-aware radius
            WorldPopulationBuilder.OnPlayerCellChanged(conn, gx, gz, isMovingFast);
        }

        /// <summary>
        /// Calculate player movement speed in m/s.
        /// </summary>
        private static float CalculatePlayerSpeed(Connection conn)
        {
            if (conn.LastPositionUpdateTime == 0)
                return 0f;

            long now = Environment.TickCount64;
            long elapsedMs = now - conn.LastPositionUpdateTime;
            if (elapsedMs == 0) return 0f;

            var currentPos = conn.LastKnownPlayerPosition;
            var previousPos = conn.PreviousPlayerPosition;

            // Calculate distance traveled
            float dx = currentPos.X - previousPos.X;
            float dy = currentPos.Y - previousPos.Y;
            float dz = currentPos.Z - previousPos.Z;
            float distance = MathF.Sqrt(dx * dx + dy * dy + dz * dz);

            // Speed = distance / time (convert ms to seconds)
            float speed = distance / (elapsedMs / 1000f);

            // Cap at reasonable maximum (e.g., 200 m/s = 720 km/h)
            return MathF.Min(speed, 200f);
        }

        // ═══════════════════════════════════════════════════════════════
        // PACKET BUILDERS
        // ═══════════════════════════════════════════════════════════════

        /// <summary>Send SyncDestructibleGridAOIIncrease — tells client which cells to load + placement data.</summary>
        public static void SendDestructibleAOIIncrease(Connection conn, int playerGridX, int playerGridZ,
            HashSet<(int X, int Z)> cells, AoiAddAndRemoveReason reason)
        {
            var aoiInfos = new List<AoiDestructibleInfo>();

            // Source 1: Real placement data from extracted scene items (preferred)
            if (SceneItemPlacementLoader.IsLoaded)
            {
                var placements = SceneItemPlacementLoader.GetEntriesForCells(cells);
                foreach (var p in placements)
                {
                    aoiInfos.Add(new AoiDestructibleInfo()
                    {
                        InstanceId = p.uid,
                        UniqueId = p.uid,
                        CfgId = p.tmpl,
                        PathId = (int)(p.pathId & 0x7FFFFFFF), // clamp to int32
                        Position = new UXVector3()
                        {
                            X = p.pos != null && p.pos.Length >= 3 ? p.pos[0] : 0,
                            Y = p.pos != null && p.pos.Length >= 3 ? p.pos[1] : 0,
                            Z = p.pos != null && p.pos.Length >= 3 ? p.pos[2] : 0,
                        },
                        Facing = new UXVector3()
                        {
                            X = p.euler != null && p.euler.Length >= 3 ? p.euler[0] : 0,
                            Y = p.euler != null && p.euler.Length >= 3 ? p.euler[1] : 0,
                            Z = p.euler != null && p.euler.Length >= 3 ? p.euler[2] : 0,
                        },
                        iScale = 1,
                        Hp = 100f,
                        NavId = 0,
                        State = 0,
                        BreakStage = 0,
                        OccupantInfos = new List<SceneItemOccupantInfo>(),
                        DropWeaponId = 0,
                        EffectIds = new List<int>(),
                    });
                }
            }

            // Source 2: Server-side destructible objects (fallback + dynamic objects)
            float worldCenterX = playerGridX * GridCellSize + GridOffsetX;
            float worldCenterZ = playerGridZ * GridCellSize + GridOffsetZ;
            float worldRange = DestructibleRange * GridCellSize * 1.5f;
            var nearbyObjects = DestructibleObjectManager.GetObjectsInRange(worldCenterX, worldCenterZ, worldRange);
            foreach (var obj in nearbyObjects)
            {
                aoiInfos.Add(obj.ToAoiDestructibleInfo());
            }

            var args = new DestructibleGridAOIIncrease()
            {
                PlayerStandardIndex = new GridIndex() { X = playerGridX, Z = playerGridZ },
                addInfos = aoiInfos,
                indexList = cells.Select(c => new GridIndex() { X = c.X, Z = c.Z }).ToList(),
                addUniqueIds = aoiInfos.Select(i => i.UniqueId).ToList(),
                removeIds = new List<ulong>(),
                reason = reason,
            };

            var msg = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestructibleGridAOIIncrease,
            };
            msg.SetArgs(MethodId.SyncDestructibleGridAOIIncrease, args);
            conn.SendPacket(msg);

            Console.WriteLine($"[AOI] Sent AOI increase: {cells.Count} cells, {aoiInfos.Count} addInfos ({(SceneItemPlacementLoader.IsLoaded ? "real" : "synthetic")}), reason={reason}");
        }

        /// <summary>Send SyncDestructibleGridAOIDecrease — tells client which cells to unload.</summary>
        static void SendDestructibleAOIDecrease(Connection conn, HashSet<(int X, int Z)> cells)
        {
            var args = new GridAOIDecrease()
            {
                SectorIdList = new List<int>(),
                StandardIndexList = cells.Select(c => new GridIndex() { X = c.X, Z = c.Z }).ToList(),
                ExceptIds = new List<ulong>(),
            };

            var msg = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestructibleGridAOIDecrease,
            };
            msg.SetArgs(MethodId.SyncDestructibleGridAOIDecrease, args);
            conn.SendPacket(msg);
        }

        // ═══════════════════════════════════════════════════════════════
        // RESET — for scene transitions
        // ═══════════════════════════════════════════════════════════════

        /// <summary>
        /// Reset AOI state (e.g., when the player transitions to a new scene).
        /// Sends decrease for all currently loaded cells, then clears state.
        /// </summary>
        public static void ResetAOI(Connection conn)
        {
            if (conn.LoadedDestructibleCells.Count > 0)
            {
                SendDestructibleAOIDecrease(conn, conn.LoadedDestructibleCells);
            }

            conn.LoadedDestructibleCells.Clear();
            conn.LoadedSceneItemCells.Clear();
            conn.LastGridX = int.MinValue;
            conn.LastGridZ = int.MinValue;
            conn.AOIInitialized = false;

            // Clean up progressive NPC spawn state
            WorldPopulationBuilder.CleanupProgressiveSpawn(conn);

            Console.WriteLine("[AOI] AOI reset");
        }
    }
}
