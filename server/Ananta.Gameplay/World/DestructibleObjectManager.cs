using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading;

namespace AnantaTestGameServer
{
    public class DestructibleObjectState
    {
        public ulong DestructibleId;
        public uint ConfigId;
        public UXVector3 Position;
        public float Facing;
        public float Hp;
        public float MaxHp;
        public uint State; // 0=normal, 1=held, 2=broken, 3=destroyed
        public ulong HolderPid;
        public uint HookId;

        public DestructibleInfo ToDestructibleInfo()
        {
            return new DestructibleInfo()
            {
                DestructibleId = DestructibleId,
                ConfigId = ConfigId,
                Position = Position,
                Facing = Facing,
                Hp = Hp,
                MaxHp = MaxHp,
                State = State,
                HolderPid = HolderPid,
                HookId = HookId,
            };
        }

        /// <summary>
        /// Convert to the wire format expected by DestructibleGridAOIIncrease.addInfos.
        /// Matches client Lua Reader[397] field order: 14 fields.
        /// </summary>
        public AoiDestructibleInfo ToAoiDestructibleInfo()
        {
            return new AoiDestructibleInfo()
            {
                InstanceId = DestructibleId,
                UniqueId = DestructibleId,       // same as InstanceId for server-spawned
                CfgId = ConfigId,
                PathId = 0,                       // default asset path
                Position = Position ?? new UXVector3(),
                Facing = new UXVector3() { X = 0, Y = Facing, Z = 0 }, // euler Y rotation
                iScale = 1,
                Hp = Hp,
                NavId = 0,
                State = (byte)(State > 255 ? 0 : State),
                BreakStage = 0,
                OccupantInfos = new List<SceneItemOccupantInfo>(),
                DropWeaponId = 0,
                EffectIds = new List<int>(),
            };
        }

        public SyncDestructibleObjectAddEntry ToAddEntry()
        {
            return new SyncDestructibleObjectAddEntry()
            {
                DestructibleId = DestructibleId,
                ConfigId = ConfigId,
                Position = Position,
                Facing = Facing,
                Hp = Hp,
                MaxHp = MaxHp,
                State = State,
                HolderPid = HolderPid,
                HookId = HookId,
            };
        }
    }

    public static class DestructibleObjectManager
    {
        private static readonly ConcurrentDictionary<ulong, DestructibleObjectState> s_objects = new();
        private static readonly Random s_rng = new();
        private static long s_nextId = 0;

        public static ICollection<DestructibleObjectState> AllObjects => s_objects.Values;

        public static DestructibleObjectState GetObject(ulong id)
        {
            s_objects.TryGetValue(id, out var obj);
            return obj;
        }

        public static bool TryGetObject(ulong id, out DestructibleObjectState obj)
        {
            return s_objects.TryGetValue(id, out obj);
        }

        public static ulong AddObject(DestructibleObjectState obj)
        {
            if (obj.DestructibleId == 0)
                obj.DestructibleId = (ulong)Interlocked.Increment(ref s_nextId) + 0x8000000000000000UL;
            s_objects[obj.DestructibleId] = obj;
            return obj.DestructibleId;
        }

        public static bool RemoveObject(ulong id)
        {
            return s_objects.TryRemove(id, out _);
        }

        public static bool BreakObject(ulong id)
        {
            if (s_objects.TryGetValue(id, out var obj))
            {
                obj.State = 2;
                obj.Hp = 0;
                return true;
            }
            return false;
        }

        public static List<DestructibleObjectState> GetObjectsInRange(float centerX, float centerZ, float range)
        {
            return s_objects.Values
                .Where(o => o.State < 3)
                .Where(o => Math.Abs(o.Position.X - centerX) <= range && Math.Abs(o.Position.Z - centerZ) <= range)
                .ToList();
        }

        public static List<SyncDestructibleObjectAddEntry> GetAddEntriesInRange(float centerX, float centerZ, float range)
        {
            return GetObjectsInRange(centerX, centerZ, range)
                .Select(o => o.ToAddEntry())
                .ToList();
        }

        public static void SpawnCityObjects()
        {
            s_objects.Clear();

            uint[] configIds = new uint[]
            {
                10000001, // Street lamp small
                10000002, // Street lamp large
                10000003, // Bench
                10000004, // Trash can
                10000005, // Barrel metal
                10000006, // Barrel plastic
                10000007, // Crate small
                10000008, // Crate large
                10000009, // Table
                10000010, // Chair
                10000011, // Traffic cone
                10000012, // Signpost
                10000013, // Flower pot
                10000014, // Mailbox
                10000015, // Fire hydrant
            };

            // Multiple clusters across the map to cover player exploration area
            // Each cluster: (baseX, baseZ, rows, cols, spacing)
            var clusters = new (float baseX, float baseZ, int rows, int cols, float spacing)[]
            {
                // Cluster 1: Spawn area (default server spawn at 1000, 2000)
                (980f, 1960f, 8, 6, 8f),
                // Cluster 2: Player's typical position from frida (~3009, 1615)
                (2960f, 1580f, 8, 8, 10f),
                // Cluster 3: Mid-way between spawn and player pos
                (2000f, 1800f, 6, 6, 10f),
                // Cluster 4: North area
                (1500f, 2500f, 6, 6, 8f),
                // Cluster 5: East area
                (3500f, 1200f, 6, 6, 10f),
                // Cluster 6: Along main road (X=1000-3000, Z=1600-1800)
                (1200f, 1700f, 4, 12, 15f),
            };

            int index = 0;
            foreach (var (baseX, baseZ, rows, cols, spacing) in clusters)
            {
                for (int row = 0; row < rows; row++)
                {
                    for (int col = 0; col < cols; col++)
                    {
                        float x = baseX + col * spacing + (float)(s_rng.NextDouble() * 3 - 1.5);
                        float z = baseZ + row * spacing + (float)(s_rng.NextDouble() * 3 - 1.5);
                        float facing = (float)(s_rng.NextDouble() * Math.PI * 2);
                        uint configId = configIds[index % configIds.Length];
                        float hp = 50 + (float)(s_rng.NextDouble() * 50);

                        var obj = new DestructibleObjectState()
                        {
                            DestructibleId = (ulong)Interlocked.Increment(ref s_nextId) + 0x8000000000000000UL,
                            ConfigId = configId,
                            Position = new UXVector3() { X = x, Y = 0, Z = z },
                            Facing = facing,
                            Hp = hp,
                            MaxHp = hp,
                            State = 0,
                            HolderPid = 0,
                            HookId = 0,
                        };

                        s_objects[obj.DestructibleId] = obj;
                        index++;
                    }
                }
            }

            Console.WriteLine($"[Destructible] Spawned {s_objects.Count} city objects in {clusters.Length} clusters");
        }
    }
}
