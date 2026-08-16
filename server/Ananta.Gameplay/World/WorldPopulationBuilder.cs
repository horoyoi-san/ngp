using AnantaTestGameServer.Configs;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using AnantaTestGameServer.Game;
using System;
using System.Collections.Generic;
using System.Linq;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Game
{
    public static class WorldPopulationBuilder
    {
        public static bool NpcAutoSpawnEnabled { get; set; } = true;
        // Per-type toggles — useful for isolating which category is broken
        public static bool StaticNpcsEnabled { get; set; } = true;
        public static bool CrowdNpcsEnabled { get; set; } = true;
        public static bool TrafficVehiclesEnabled { get; set; } = true;
        public static bool ParkedVehiclesEnabled { get; set; } = true;
        public static bool MetroNpcsEnabled { get; set; } = true;

        // Fast movement multiplier (from AOIGridManager)
        public const float FastMovementRadiusMultiplier = 2.0f;

        // Vehicle configs — from config file
        static readonly uint[] VehicleConfigs = GameConfig.VehicleConfigs.Length > 0
            ? GameConfig.VehicleConfigs
            : new uint[] { 81005001, 81005002, 81005003, 81005004, 81005005 };

        // NPC formworks — from config file
        static readonly uint[] NpcFormworks = GameConfig.AutoSpawnNpcIds.Length > 0
            ? GameConfig.AutoSpawnNpcIds
            : State.NpcStateFactory.BuildAutoSpawnNpcIds();

        // Fashion suits — from config file
        static readonly uint[] FashionSuits = GameConfig.FashionSuits.Length > 0
            ? GameConfig.FashionSuits
            : new uint[] { 11190001, 11190002, 11190003, 11190004, 11190005, 11190006 };

        static readonly Random Rng = new Random(12345);
        static ulong NextId() => (ulong)Rng.NextInt64(100000, int.MaxValue);

        // ── Progressive spawn state ──
        // Tracks which cells have had their NPCs spawned for each connection
        // and maps cell → entity IDs for despawn
        private static readonly Dictionary<Connection, HashSet<(int X, int Z)>> SpawnedCells = new();
        private static readonly Dictionary<Connection, Dictionary<(int X, int Z), List<ulong>>> CellNpcMap = new();

        public static void SendWorldPopulation(Connection conn, float centerX = 1000, float centerZ = 2000)
        {
            DebugLogger.Log("[WorldPop] SendWorldPopulation called");

            if (!NpcAutoSpawnEnabled)
            {
                Console.WriteLine("[WorldPop] Auto-spawn disabled, skipping NPC/vehicle population.");
                return;
            }

            // ── Vehicles: spawn immediately (they're rare and far from player) ──
            var vehicles = BuildTrafficVehicles(centerX, centerZ, out var vehicleNpcs);
            var staticVehicles = BuildParkedVehicles(centerX, centerZ);
            var metroNpcs = BuildMetroNpcs(centerX, centerZ);

            // Send vehicle init (lightweight — no NPCs in bulk init)
            var initData = new AetherAIInitData()
            {
                RaidId = 23300888,
                HasZoneGraph = true,
                ZoneStorageDataHandle = 0,
                Intersections = new(),
                Crowds = new(),
                StaticNpcs = new(),
                Vehicles = vehicles,
                StaticVehicles = staticVehicles,
                VehicleNpcs = vehicleNpcs,
                MetroNpcs = metroNpcs
            };

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIInitDatas,
            };
            rsp.SetArgs(MethodId.SyncAetherAIInitDatas, initData);
            conn.SendPacket(rsp);

            Console.WriteLine($"[WorldPop] Sent vehicles: {vehicles.Count} traffic, {staticVehicles.Count} parked, " +
                $"{vehicleNpcs.Count} drivers, {metroNpcs.Count} metro NPCs");

            // Register traffic vehicles for VehicleDrivingAI
            RegisterTrafficVehicles(conn, vehicles, vehicleNpcs);

            // ── Progressive NPC spawn: spawn NPCs in nearby cells ──
            var (gx, gz) = AOIGridManager.WorldToGrid(centerX, centerZ);
            InitProgressiveSpawn(conn);
            SpawnNpcsForNearbyCells(conn, gx, gz);

            Console.WriteLine($"[WorldPop] Progressive NPC spawn initialized for player at grid ({gx},{gz})");
        }

        // ═══════════════════════════════════════════════════════════════
        // PROGRESSIVE SPAWN — called when player moves to new grid cell
        // ═══════════════════════════════════════════════════════════════

        /// <summary>
        /// Initialize progressive spawn state for a connection.
        /// </summary>
        public static void InitProgressiveSpawn(Connection conn)
        {
            SpawnedCells[conn] = new HashSet<(int, int)>();
            CellNpcMap[conn] = new Dictionary<(int, int), List<ulong>>();
        }

        /// <summary>
        /// Called when the player moves to a new grid cell.
        /// Spawns NPCs in newly visible cells, despawns NPCs from cells that are now out of range.
        /// </summary>
        public static void OnPlayerCellChanged(Connection conn, int newGridX, int newGridZ, bool isMovingFast = false)
        {
            if (!NpcAutoSpawnEnabled) return;
            if (!SpawnedCells.ContainsKey(conn)) return;

            // Use larger radius when moving fast
            int effectiveSpawnRadius = isMovingFast ?
                (int)(NpcPlacementRegistry.SpawnRadius * FastMovementRadiusMultiplier) :
                NpcPlacementRegistry.SpawnRadius;
            int effectiveDespawnRadius = isMovingFast ?
                (int)(NpcPlacementRegistry.DespawnRadius * FastMovementRadiusMultiplier) :
                NpcPlacementRegistry.DespawnRadius;

            DebugLogger.Log($"[WorldPop] Player moved to grid ({newGridX},{newGridZ}) fast={isMovingFast}, spawnRadius={effectiveSpawnRadius}, despawnRadius={effectiveDespawnRadius}");
            SpawnNpcsForNearbyCells(conn, newGridX, newGridZ, effectiveSpawnRadius);
            DespawnDistantNpcs(conn, newGridX, newGridZ, effectiveDespawnRadius);
        }

        /// <summary>
        /// Spawn NPCs in cells within SpawnRadius that haven't been spawned yet.
        /// NPCs are properly removed when out of range, so no restore logic needed.
        /// </summary>
        private static void SpawnNpcsForNearbyCells(Connection conn, int playerGridX, int playerGridZ, int customSpawnRadius = -1)
        {
            var spawnedCells = SpawnedCells[conn];
            var cellNpcMap = CellNpcMap[conn];

            int effectiveRadius = customSpawnRadius > 0 ? customSpawnRadius : NpcPlacementRegistry.SpawnRadius;

            // Get cells that need spawning
            var cellsToSpawn = NpcPlacementRegistry.GetCellsToSpawn(playerGridX, playerGridZ, spawnedCells, effectiveRadius);

            DebugLogger.Log($"[WorldPop] Cells to spawn: {cellsToSpawn.Count}, already spawned: {spawnedCells.Count}");

            int totalSpawned = 0;

            // Spawn new NPCs in cells that haven't been spawned
            foreach (var cell in cellsToSpawn)
            {
                // Respect max alive limit
                int currentCount = cellNpcMap.Values.Sum(list => list.Count);
                if (currentCount >= NpcPlacementRegistry.MaxAliveNpcs)
                {
                    Console.WriteLine($"[WorldPop] Max alive NPCs reached ({NpcPlacementRegistry.MaxAliveNpcs}), stopping spawn");
                    break;
                }

                var placements = NpcPlacementRegistry.GetNpcsForCell(cell.X, cell.Z);
                var entityIds = new List<ulong>();

                foreach (var entry in placements)
                {
                    ulong entityId = NextId();

                    // Generate path for NPC movement (like ka1.4)
                    var path = DynamicPathGenerator.GeneratePath(
                        entry.WorldX,
                        entry.WorldZ,
                        entry.WorldX,
                        entry.WorldZ,
                        DynamicPathGenerator.PathType.WanderLoop);

                    // Build crowd NPC init data (like ka1.4 - makes NPCs walk)
                    var crowdNpc = new ClientCrowdInitData()
                    {
                        Id = entityId,
                        NpcFormworkId = entry.FormworkId,
                        AgentPersonaId = 45200058,
                        UrbanDiversityConfigId = 88888000,
                        DesiredSpeed = MovementScheduler.WalkSpeed,
                        ActionId = 0,
                        TargetLocationReason = ZoneGraphTargetLocationReason.Wander,
                        FashionSuitId = entry.FashionId,
                        Points = path,
                        Position = new() { X = entry.WorldX, Y = entry.WorldY, Z = entry.WorldZ },
                        Facing = entry.Facing,
                    };

                    // Send crowd add packet
                    UxRpcMessage npcRsp = new UxRpcMessage()
                    {
                        Mode = UxRpcPacketMode.Notify,
                        RpcInvokeId = 0,
                        RpcRetcode = 0,
                        RpcMethodId = (int)MethodId.SyncAetherAICrowdAdd,
                    };
                    npcRsp.SetArgs(MethodId.SyncAetherAICrowdAdd, crowdNpc);
                    conn.SendPacket(npcRsp);

                    // Register in AI behavior tracking (like ka1.4)
                    var spawnedNpc = new Connection.SpawnedNpc()
                    {
                        EntityId = entityId,
                        FormworkId = entry.FormworkId,
                        PosX = entry.WorldX,
                        PosY = entry.WorldY,
                        PosZ = entry.WorldZ,
                        Facing = entry.Facing,
                        OriginX = entry.WorldX,
                        OriginZ = entry.WorldZ,
                        CurrentState = Connection.NpcState.Wandering,
                        StateEnteredAt = DateTime.UtcNow,
                        IsStatic = false,
                        DesiredSpeed = MovementScheduler.WalkSpeed,
                        Waypoints = path,
                    };
                    BehaviorTreeEngine.BTFactory.AssignTree(spawnedNpc);
                    conn.RegisterSpawnedNpc(spawnedNpc);
                    MovementScheduler.SetMovementMode(conn, spawnedNpc, Connection.MovementMode.Walk);

                    entityIds.Add(entityId);
                }

                spawnedCells.Add(cell);
                cellNpcMap[cell] = entityIds;
                totalSpawned += entityIds.Count;
            }

            if (totalSpawned > 0)
            {
                DebugLogger.Log($"[WorldPop] Spawned {totalSpawned} new NPCs in {cellsToSpawn.Count} cells (total alive: {cellNpcMap.Values.Sum(l => l.Count)})");
            }
        }

        /// <summary>
        /// Despawn NPCs from cells that are now beyond DespawnRadius.
        /// Properly removes NPCs from client using SyncAetherAINpcRemove.
        /// </summary>
        private static void DespawnDistantNpcs(Connection conn, int playerGridX, int playerGridZ, int customDespawnRadius = -1)
        {
            var spawnedCells = SpawnedCells[conn];
            var cellNpcMap = CellNpcMap[conn];

            int effectiveRadius = customDespawnRadius > 0 ? customDespawnRadius : NpcPlacementRegistry.DespawnRadius;

            var cellsToDespawn = NpcPlacementRegistry.GetCellsToDespawn(playerGridX, playerGridZ, spawnedCells, effectiveRadius);

            int totalRemoved = 0;
            foreach (var cell in cellsToDespawn)
            {
                if (!cellNpcMap.TryGetValue(cell, out var entityIds)) continue;

                // Remove NPCs properly from client
                foreach (var entityId in entityIds)
                {
                    var npc = conn.GetLiveNpcs().FirstOrDefault(n => n.EntityId == entityId);
                    if (npc != null)
                    {
                        // Send remove RPC to client
                        var removeRsp = new UxRpcMessage()
                        {
                            Mode = UxRpcPacketMode.Notify,
                            RpcInvokeId = 0,
                            RpcRetcode = 0,
                            RpcMethodId = (int)MethodId.SyncAetherAINpcRemove,
                        };
                        removeRsp.SetArgs(MethodId.SyncAetherAINpcRemove, new SyncAetherAINpcRemoveArgs()
                        {
                            npcId = entityId
                        });
                        conn.SendPacket(removeRsp);

                        // Mark NPC as destroyed on server
                        conn.MarkNpcDestroyed(entityId);
                    }
                }

                spawnedCells.Remove(cell);
                cellNpcMap.Remove(cell);
                totalRemoved += entityIds.Count;
            }

            if (totalRemoved > 0)
            {
                DebugLogger.Log($"[WorldPop] Removed {totalRemoved} NPCs from {cellsToDespawn.Count} distant cells");
            }
        }

        /// <summary>
        /// Clean up progressive spawn state when player disconnects or changes scene.
        /// Also destroys all NPCs (including hidden ones) to free memory.
        /// </summary>
        public static void CleanupProgressiveSpawn(Connection conn)
        {
            SpawnedCells.Remove(conn);
            CellNpcMap.Remove(conn);

            // Destroy ALL NPCs to free memory (both hidden and visible)
            conn.PurgeDestroyedNpcs();
            conn.ClearAllNpcs();
        }

        // Register traffic vehicles with VehicleDrivingAI for autonomous driving
        static void RegisterTrafficVehicles(
            Connection conn,
            List<ClientVehicleInitData> vehicles,
            List<ClientVehicleNpcInitData> drivers)
        {
            conn.TrafficVehicles.Clear();

            var personalities = new[] {
                VehicleDrivingAI.DriverPersonality.Normal,
                VehicleDrivingAI.DriverPersonality.Aggressive,
                VehicleDrivingAI.DriverPersonality.Cautious,
                VehicleDrivingAI.DriverPersonality.Normal,
                VehicleDrivingAI.DriverPersonality.Aggressive,
            };

            for (int i = 0; i < vehicles.Count; i++)
            {
                var v = vehicles[i];
                var personality = personalities[i % personalities.Length];
                var (minSpeed, maxSpeed) = VehicleDrivingAI.GetSpeedRange(personality);

                var trafficVehicle = new VehicleDrivingAI.TrafficVehicle()
                {
                    EntityId = v.Id,
                    VehicleConfigId = v.VehicleConfigId,
                    DriverNpcEntityId = i < drivers.Count ? drivers[i].Id : 0,
                    PosX = v.Position.X,
                    PosY = v.Position.Y,
                    PosZ = v.Position.Z,
                    Facing = v.Facing,
                    CurrentSpeed = minSpeed + (maxSpeed - minSpeed) * 0.5f,
                    TargetSpeed = minSpeed + (maxSpeed - minSpeed) * 0.5f,
                    Personality = personality,
                    Route = VehicleDrivingAI.GenerateDrivingRoute(v.Position.X, v.Position.Z),
                    CurrentRouteIndex = 0,
                    IsLooping = true,
                };

                VehicleDrivingAI.RegisterTrafficVehicle(conn, trafficVehicle);

                // Also register the driver NPC in Driving state
                if (i < drivers.Count)
                {
                    var driver = drivers[i];
                    var driverNpc = new Connection.SpawnedNpc()
                    {
                        EntityId = driver.Id,
                        FormworkId = driver.NpcFormworkId,
                        PosX = v.Position.X,
                        PosY = v.Position.Y,
                        PosZ = v.Position.Z,
                        Facing = v.Facing,
                        OriginX = v.Position.X,
                        OriginZ = v.Position.Z,
                        CurrentState = Connection.NpcState.Driving,
                        IsStatic = false,
                        DesiredSpeed = 0,
                        BoundVehicleEntityId = v.Id,
                        VehicleSeatIndex = 0,
                    };
                    BehaviorTreeEngine.BTFactory.AssignTree(driverNpc);
                    conn.RegisterSpawnedNpc(driverNpc);
                }
            }

            Console.WriteLine($"[WorldPop] Registered {vehicles.Count} traffic vehicles for VehicleDrivingAI");
        }

        // ---- TRAFFIC VEHICLES (AI-driven cars on roads with drivers) ----
        static List<ClientVehicleInitData> BuildTrafficVehicles(float cx, float cz, out List<ClientVehicleNpcInitData> npcDrivers)
        {
            var vehicles = new List<ClientVehicleInitData>();
            npcDrivers = new List<ClientVehicleNpcInitData>();

            float[,] positions = {
                { cx + 80, cz }, { cx + 100, cz + 20 }, { cx - 50, cz + 10 },
                { cx + 70, cz - 30 }, { cx + 120, cz + 50 }
            };

            for (int i = 0; i < positions.GetLength(0); i++)
            {
                ulong vId = NextId();
                ulong driverId = NextId();
                uint configId = VehicleConfigs[i % VehicleConfigs.Length];
                var vEntry = ConfigManager.GetVehicle(configId);

                vehicles.Add(new ClientVehicleInitData()
                {
                    Id = vId,
                    Position = new() { X = positions[i, 0], Y = 0, Z = positions[i, 1] },
                    Facing = (float)(Rng.NextDouble() * 360.0),
                    VehicleConfigId = configId,
                    VehicleColorId = VehicleColors.GetRandomColorForVehicle(vEntry?.VehicleColor),
                    VehicleLightState = 0,
                    LaneHandle = -1,
                    DistanceAlongLane = 0,
                    NextVehicleId = 0,
                    Timestamp = 0,
                    ControlType = VehicleControlType.AetherVehicle,
                    Parts = new()
                });

                npcDrivers.Add(new ClientVehicleNpcInitData()
                {
                    Id = driverId,
                    NpcFormworkId = NpcFormworks[i % NpcFormworks.Length],
                    BindVehicleId = vId,
                    SeatIndex = 0
                });
            }
            return vehicles;
        }

        // ---- STATIC VEHICLES (parked cars around the area) ----
        static List<ClientStaticVehicleInitData> BuildParkedVehicles(float cx, float cz)
        {
            var list = new List<ClientStaticVehicleInitData>();
            float[,] positions = {
                { cx + 5, cz - 5 }, { cx + 25, cz + 30 }, { cx - 10, cz + 40 },
                { cx + 55, cz - 20 }, { cx + 35, cz + 60 }, { cx - 25, cz - 30 },
                { cx + 65, cz + 35 }
            };

            for (int i = 0; i < positions.GetLength(0); i++)
            {
                uint configId = VehicleConfigs[i % VehicleConfigs.Length];
                var vEntry = ConfigManager.GetVehicle(configId);
                list.Add(new ClientStaticVehicleInitData()
                {
                    Id = NextId(),
                    Position = new() { X = positions[i, 0], Y = 0, Z = positions[i, 1] },
                    Facing = (float)(Rng.NextDouble() * 360.0),
                    VehicleConfigId = configId,
                    ColorConfigId = VehicleColors.GetRandomColorForVehicle(vEntry?.VehicleColor),
                    DamageStatusId = 0,
                    Timestamp = 0,
                    NotDrive = true,
                    RotationX = 0,
                    RotationY = 0,
                    RotationZ = 0,
                    RotationW = 1,
                    Parts = new()
                });
            }
            return list;
        }

        // ---- METRO NPCs (passengers inside metro trains) ----
        static List<ClientMetroNpcInitData> BuildMetroNpcs(float cx, float cz)
        {
            var list = new List<ClientMetroNpcInitData>();
            ulong metroInstanceId = NextId();

            for (int i = 0; i < 4; i++)
            {
                list.Add(new ClientMetroNpcInitData()
                {
                    Id = NextId(),
                    Position = new() { X = cx + i * 5, Y = 0, Z = cz },
                    Facing = 0,
                    NpcFormworkId = NpcFormworks[i % NpcFormworks.Length],
                    MetroInstanceId = metroInstanceId,
                    MetroCarriageIndex = (byte)(i / 2),
                    PoiActionId = 0
                });
            }
            return list;
        }
    }
}
