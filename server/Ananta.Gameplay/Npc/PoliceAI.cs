using AnantaTestGameServer.BehaviorTreeEngine;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using System;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// Police AI — police examine, chase, and arrest behavior.
    /// Mirrors DLL's PoliceExamineModule + ExamineState FSM.
    ///
    /// When player has "wanted" status (crimes committed), nearby
    /// police NPCs enter examination mode. If suspicion is confirmed,
    /// they chase and attempt arrest.
    /// </summary>
    public static class PoliceAI
    {
        // ================================================================
        // POLICE STATES
        // ================================================================
        public enum PoliceState : byte
        {
            Patrol = 0,       // Normal patrol, not suspicious
            Examining = 1,    // Watching the player suspiciously
            Chasing = 2,      // Actively pursuing the player
            Arresting = 3,    // Attempting arrest (close range)
            Returning = 4,    // Returning to patrol after chase
        }

        // ================================================================
        // WANTED LEVEL SYSTEM
        // ================================================================

        /// <summary>
        /// Player wanted level (0-5). Higher = more police attention.
        /// Stored on Connection.Blackboard.
        /// </summary>
        public static int GetWantedLevel(Connection conn)
        {
            return conn.Blackboard?.Get<int>("wantedLevel", 0) ?? 0;
        }

        public static void SetWantedLevel(Connection conn, int level)
        {
            level = Math.Clamp(level, 0, 5);
            conn.Blackboard?.Set("wantedLevel", level);
            Console.WriteLine($"[Police] Wanted level set to {level}");
        }

        public static void AddCrime(Connection conn, uint crimeId)
        {
            int current = GetWantedLevel(conn);
            SetWantedLevel(conn, Math.Min(current + 1, 5));

            // Send crime sync
            var data = new CrimeArgs() { crimeId = crimeId };
            SendNotify(conn, MethodId.SyncAgentCrimeAdd, data);
        }

        // ================================================================
        // POLICE NPC BEHAVIOR
        // ================================================================

        /// <summary>
        /// Evaluate police behavior for an NPC based on wanted level and proximity.
        /// Called from NpcBehaviorManager.Tick().
        /// Only applies to NPCs with police formwork IDs.
        /// </summary>
        public static void EvaluatePoliceBehavior(Connection conn, Connection.SpawnedNpc npc)
        {
            if (!IsPoliceNpc(npc)) return;

            int wantedLevel = GetWantedLevel(conn);
            if (wantedLevel <= 0)
            {
                // No crimes — police patrol normally
                SetPoliceState(npc, PoliceState.Patrol);
                return;
            }

            float dx = npc.PosX - conn.LastKnownPlayerPosition.X;
            float dz = npc.PosZ - conn.LastKnownPlayerPosition.Z;
            float dist = MathF.Sqrt(dx * dx + dz * dz);

            var currentState = GetPoliceState(npc);

            // Detection radius increases with wanted level
            float detectRadius = 15f + wantedLevel * 5f;   // 20-40m
            float chaseRadius = 30f + wantedLevel * 10f;    // 40-80m
            float arrestRadius = 3f;

            switch (currentState)
            {
                case PoliceState.Patrol:
                    if (dist <= detectRadius)
                    {
                        SetPoliceState(npc, PoliceState.Examining);
                        SendPoliceExamData(conn, npc.EntityId, true);
                    }
                    break;

                case PoliceState.Examining:
                    // After examining for 3-5 seconds, decide to chase or return
                    double examineTime = (DateTime.UtcNow - npc.StateEnteredAt).TotalSeconds;
                    if (examineTime >= 4.0)
                    {
                        if (dist <= chaseRadius)
                        {
                            SetPoliceState(npc, PoliceState.Chasing);
                            // Generate chase path towards player
                            ChasePlayer(conn, npc);
                        }
                        else
                        {
                            SetPoliceState(npc, PoliceState.Returning);
                        }
                    }
                    break;

                case PoliceState.Chasing:
                    if (dist <= arrestRadius)
                    {
                        SetPoliceState(npc, PoliceState.Arresting);
                        // Send arrest sync
                        npc.CurrentState = Connection.NpcState.Examined;
                        npc.StateEnteredAt = DateTime.UtcNow;
                    }
                    else if (dist > chaseRadius * 1.5f)
                    {
                        // Lost the suspect
                        SetPoliceState(npc, PoliceState.Returning);
                    }
                    else
                    {
                        // Continue chasing — update path towards player
                        ChasePlayer(conn, npc);
                    }
                    break;

                case PoliceState.Arresting:
                    // Arrest takes 5 seconds
                    double arrestTime = (DateTime.UtcNow - npc.StateEnteredAt).TotalSeconds;
                    if (arrestTime >= 5.0)
                    {
                        // Arrest complete — reduce wanted level
                        SetWantedLevel(conn, Math.Max(GetWantedLevel(conn) - 1, 0));
                        SetPoliceState(npc, PoliceState.Returning);
                        npc.CurrentState = Connection.NpcState.Idle;
                        npc.StateEnteredAt = DateTime.UtcNow;
                    }
                    break;

                case PoliceState.Returning:
                    // Return to patrol after some time
                    double returnTime = (DateTime.UtcNow - npc.StateEnteredAt).TotalSeconds;
                    if (returnTime >= 10.0)
                    {
                        SetPoliceState(npc, PoliceState.Patrol);
                    }
                    break;
            }
        }

        /// <summary>
        /// Check if an NPC is a police officer (by formwork ID or tag).
        /// </summary>
        public static bool IsPoliceNpc(Connection.SpawnedNpc npc)
        {
            // Check police-related board tag (set during spawn if applicable)
            return npc.Board?.Get<bool>("isPolice", false) ?? false;
        }

        /// <summary>
        /// Mark an NPC as a police officer.
        /// </summary>
        public static void MarkAsPolice(Connection.SpawnedNpc npc)
        {
            npc.Board?.Set("isPolice", true);
            npc.Board?.Set("policeState", (byte)PoliceState.Patrol);
        }

        static PoliceState GetPoliceState(Connection.SpawnedNpc npc)
        {
            byte state = npc.Board?.Get<byte>("policeState", 0) ?? 0;
            return (PoliceState)state;
        }

        static void SetPoliceState(Connection.SpawnedNpc npc, PoliceState state)
        {
            var oldState = GetPoliceState(npc);
            if (oldState == state) return;
            npc.Board?.Set("policeState", (byte)state);
            npc.StateEnteredAt = DateTime.UtcNow;
        }

        static void ChasePlayer(Connection conn, Connection.SpawnedNpc npc)
        {
            // Generate a simple path towards the player
            float px = conn.LastKnownPlayerPosition.X;
            float pz = conn.LastKnownPlayerPosition.Z;

            var path = new System.Collections.Generic.List<ClientZoneGraphPathPoint>()
            {
                new ClientZoneGraphPathPoint()
                {
                    Position = new UXVector3() { X = px, Y = 0, Z = pz },
                    Facing = 0
                }
            };

            npc.Waypoints = path;
            npc.CurrentWaypointIndex = 0;
            npc.CurrentState = Connection.NpcState.PatrolWalking; // closest state for chasing
            MovementScheduler.SetMovementMode(conn, npc, Connection.MovementMode.Run);

            BTActions.SendCrowdFollowPath(conn, npc);
        }

        static void SendPoliceExamData(Connection conn, ulong agentId, bool isExamining)
        {
            var data = new PoliceExamArgs()
            {
                agentId = agentId,
                examining = isExamining
            };
            SendNotify(conn, MethodId.SyncAgentPoliceExamData, data);
        }

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

        class CrimeArgs : SerializedClass
        {
            public uint crimeId;
            public CrimeArgs() { onlyFields = true; }
        }

        class PoliceExamArgs : SerializedClass
        {
            public ulong agentId;
            public bool examining;
            public PoliceExamArgs() { onlyFields = true; }
        }
    }
}
