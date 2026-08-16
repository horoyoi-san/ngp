using AnantaTestGameServer.BehaviorTreeEngine;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using System;
using System.Collections.Generic;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// City Systems — POI spawning, NPC formations, and quest lifecycle.
    /// Mirrors DLL's AetherAI POISystem, FormationSystem, QuestSystem.
    /// </summary>
    public static class CitySystems
    {
        // ================================================================
        // POI SYSTEM — Point of Interest NPC spawning
        // Mirrors DLL: POISystem (Singleton, CreatePOIAetherNpc/DestroyPOIAetherNpc)
        // ================================================================

        public class PointOfInterest
        {
            public uint PoiId;
            public string Name;
            public float PosX, PosZ;
            public float Radius;
            public uint FormworkId;
            public uint MaxNpcs;
            public List<ulong> SpawnedNpcIds = new();
        }

        static readonly Dictionary<uint, PointOfInterest> _pois = new();

        /// <summary>
        /// Register a Point of Interest where NPCs should gather.
        /// </summary>
        public static void RegisterPOI(uint poiId, string name, float x, float z, float radius, uint formworkId, uint maxNpcs = 3)
        {
            _pois[poiId] = new PointOfInterest
            {
                PoiId = poiId,
                Name = name,
                PosX = x,
                PosZ = z,
                Radius = radius,
                FormworkId = formworkId,
                MaxNpcs = maxNpcs,
            };
        }

        /// <summary>
        /// Spawn NPCs at all registered POIs for a connection.
        /// Called when world population is built.
        /// </summary>
        public static void SpawnPOINpcs(Connection conn)
        {
            foreach (var poi in _pois.Values)
            {
                for (int i = 0; i < poi.MaxNpcs; i++)
                {
                    float angle = (360f / poi.MaxNpcs) * i * MathF.PI / 180f;
                    float r = poi.Radius * 0.5f;
                    float nx = poi.PosX + MathF.Cos(angle) * r;
                    float nz = poi.PosZ + MathF.Sin(angle) * r;

                    var npc = new Connection.SpawnedNpc()
                    {
                        EntityId = (ulong)new Random(poi.PoiId.GetHashCode() ^ i).NextInt64(100000, int.MaxValue),
                        FormworkId = poi.FormworkId,
                        PosX = nx,
                        PosY = 0,
                        PosZ = nz,
                        OriginX = nx,
                        OriginZ = nz,
                        Facing = angle * 180f / MathF.PI,
                        CurrentState = Connection.NpcState.Idle,
                        IsStatic = false,
                        DesiredSpeed = 1.5f,
                    };
                    BTFactory.AssignTree(npc);
                    conn.RegisterSpawnedNpc(npc);
                    poi.SpawnedNpcIds.Add(npc.EntityId);
                }
            }
        }

        // ================================================================
        // FORMATION SYSTEM — NPC group formations
        // Mirrors DLL: FormationSystem.CreateFormation(npcIds, rows, cols, spacing, waypoints, moveType)
        // ================================================================

        public class Formation
        {
            public ulong FormationId;
            public List<ulong> MemberNpcIds = new();
            public int Rows;
            public int Cols;
            public float RowSpacing;
            public float ColSpacing;
            public List<UXVector3> Path = new();
            public int CurrentPathIndex = 0;
            public bool IsLooping;
        }

        static readonly Dictionary<ulong, Formation> _formations = new();
        static ulong _nextFormationId = 1;

        /// <summary>
        /// Create an NPC formation and send it to the client.
        /// </summary>
        public static ulong CreateFormation(
            Connection conn,
            List<ulong> npcIds,
            int rows, int cols,
            float rowSpacing, float colSpacing,
            List<UXVector3> path,
            bool looping = true)
        {
            ulong id = _nextFormationId++;
            var formation = new Formation
            {
                FormationId = id,
                MemberNpcIds = npcIds,
                Rows = rows,
                Cols = cols,
                RowSpacing = rowSpacing,
                ColSpacing = colSpacing,
                Path = path,
                IsLooping = looping,
            };
            _formations[id] = formation;

            // Send formation create packet
            SendFormationCreate(conn, formation);

            Console.WriteLine($"[Formation] Created formation {id} with {npcIds.Count} members ({rows}x{cols})");
            return id;
        }

        /// <summary>
        /// Update formation position along path. Called from tick.
        /// </summary>
        public static void TickFormations(Connection conn)
        {
            foreach (var formation in _formations.Values)
            {
                if (formation.Path == null || formation.Path.Count < 2) continue;

                // Advance along path
                formation.CurrentPathIndex = (formation.CurrentPathIndex + 1) % formation.Path.Count;

                // Send formation update
                SendFormationUpdate(conn, formation);
            }
        }

        static void SendFormationCreate(Connection conn, Formation f)
        {
            var data = new FormationCreateArgs()
            {
                npcIds = f.MemberNpcIds,
                rows = f.Rows,
                cols = f.Cols,
                rowSpacing = f.RowSpacing,
                colSpacing = f.ColSpacing,
            };
            SendNotify(conn, MethodId.SyncAetherAICreateFormation, data);
        }

        static void SendFormationUpdate(Connection conn, Formation f)
        {
            if (f.CurrentPathIndex >= f.Path.Count) return;
            var pos = f.Path[f.CurrentPathIndex];

            var data = new FormationUpdateArgs()
            {
                formationId = f.FormationId,
                position = pos,
                facing = 0,
            };
            SendNotify(conn, MethodId.SyncAetherAIFormationUpdate, data);
        }

        /// <summary>
        /// Clean up all POI, formation, and quest data for a connection (on disconnect).
        /// Prevents memory leak from static dictionaries.
        /// </summary>
        public static void CleanupConnection(Connection conn)
        {
            // Clear NPC IDs from POIs (but keep POI definitions themselves)
            foreach (var poi in _pois.Values)
            {
                poi.SpawnedNpcIds.Clear();
            }

            // Remove formations (they're per-connection)
            var toRemoveFormations = new List<ulong>();
            foreach (var kvp in _formations)
            {
                // Check if any member NPCs belong to this connection
                bool hasConnectionNpcs = false;
                foreach (var npcId in kvp.Value.MemberNpcIds)
                {
                    var npc = conn.GetNpcById(npcId);
                    if (npc != null)
                    {
                        hasConnectionNpcs = true;
                        break;
                    }
                }
                if (hasConnectionNpcs)
                {
                    toRemoveFormations.Add(kvp.Key);
                }
            }
            foreach (var id in toRemoveFormations)
            {
                _formations.Remove(id);
            }

            // Clear quest NPC lists (but keep quest definitions)
            foreach (var quest in _quests.Values)
            {
                quest.QuestNpcIds.Clear();
            }
        }

        // ================================================================
        // QUEST SYSTEM — simple quest lifecycle
        // Mirrors DLL: QuestSystem.StartQuest/StopQuest/GetQuest
        // ================================================================

        public enum QuestStatus : byte
        {
            NotStarted = 0,
            Active = 1,
            Completed = 2,
            Failed = 3,
        }

        public class QuestData
        {
            public uint QuestId;
            public string Name;
            public QuestStatus Status = QuestStatus.NotStarted;
            public List<ulong> QuestNpcIds = new();
            public List<UXVector3> Waypoints = new();
            public DateTime StartedAt;
        }

        static readonly Dictionary<uint, QuestData> _quests = new();

        public static void RegisterQuest(uint questId, string name, List<ulong> npcIds, List<UXVector3> waypoints)
        {
            _quests[questId] = new QuestData
            {
                QuestId = questId,
                Name = name,
                QuestNpcIds = npcIds,
                Waypoints = waypoints,
            };
        }

        public static bool StartQuest(uint questId)
        {
            if (_quests.TryGetValue(questId, out var quest))
            {
                quest.Status = QuestStatus.Active;
                quest.StartedAt = DateTime.UtcNow;
                Console.WriteLine($"[Quest] Started quest: {quest.Name} (ID={questId})");
                return true;
            }
            return false;
        }

        public static bool CompleteQuest(uint questId)
        {
            if (_quests.TryGetValue(questId, out var quest) && quest.Status == QuestStatus.Active)
            {
                quest.Status = QuestStatus.Completed;
                Console.WriteLine($"[Quest] Completed quest: {quest.Name} (ID={questId})");
                return true;
            }
            return false;
        }

        public static QuestData GetQuest(uint questId)
        {
            _quests.TryGetValue(questId, out var quest);
            return quest;
        }

        // ================================================================
        // PACKET HELPERS
        // ================================================================

        static void SendNotify(Connection conn, MethodId methodId, SerializedClass args)
        {
            var msg = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)methodId,
            };
            msg.SetArgs(methodId, args);
            conn.SendPacket(msg);
        }

        class FormationCreateArgs : SerializedClass
        {
            public List<ulong> npcIds;
            public int rows;
            public int cols;
            public float rowSpacing;
            public float colSpacing;
            public FormationCreateArgs() { onlyFields = true; }
        }

        class FormationUpdateArgs : SerializedClass
        {
            public ulong formationId;
            public UXVector3 position;
            public float facing;
            public FormationUpdateArgs() { onlyFields = true; }
        }
    }
}
