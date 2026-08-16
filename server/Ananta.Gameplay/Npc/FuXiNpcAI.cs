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
    /// FuXi NPC AI — Special NPCs with personality, perception, and decision-making.
    /// Mirrors DLL's FuXiNpcManager + FuXiNpcUnit + full data model.
    ///
    /// FuXi NPCs are named characters with rich personality traits,
    /// environment perception, player state tracking, and action dispatch.
    /// They make decisions based on personality + numerical status + environment.
    /// </summary>
    public static class FuXiNpcAI
    {
        // ================================================================
        // PERSONALITY TRAITS
        // ================================================================
        public class Personality
        {
            public float Bravery;      // 0-1: how likely to confront danger
            public float Friendliness;  // 0-1: how likely to interact positively
            public float Curiosity;     // 0-1: how likely to investigate
            public float Aggression;    // 0-1: how likely to attack
            public float Laziness;      // 0-1: how likely to stay idle
        }

        // ================================================================
        // BODY STATE
        // ================================================================
        public enum BodyStateType : byte
        {
            Healthy = 0,
            Injured = 1,
            Exhausted = 2,
            Hungry = 3,
            Scared = 4,
        }

        public class NumericalStatus
        {
            public float Health = 100f;     // 0-100
            public float Stamina = 100f;    // 0-100
            public float Hunger = 50f;      // 0-100 (100 = full)
            public float Fear = 0f;         // 0-100
            public float Anger = 0f;        // 0-100
        }

        // ================================================================
        // PERCEPTION / ENVIRONMENT
        // ================================================================
        public class EnvironmentInfo
        {
            public float TimeOfDay;          // 0-24 hours
            public bool IsRaining;
            public bool IsNight;
            public int NearbyNpcCount;
            public float NoiseLevel;         // 0-100
        }

        public class PlayerPerception
        {
            public float DistanceToPlayer;
            public bool PlayerIsInCombat;
            public bool PlayerIsInVehicle;
            public bool PlayerIsArmed;
            public int PlayerWantedLevel;
            public float LastSeenTime;       // seconds since last saw player
        }

        // ================================================================
        // FuXi NPC UNIT
        // ================================================================
        public class FuXiNpc
        {
            public ulong EntityId;
            public uint FormworkId;
            public string Name;
            public float PosX, PosY, PosZ;
            public float Facing;
            public Personality Personality;
            public NumericalStatus Status;
            public BodyStateType BodyState = BodyStateType.Healthy;
            public EnvironmentInfo Environment;
            public PlayerPerception PlayerInfo;
            public DateTime LastActionTime = DateTime.UtcNow;
            public FuXiAction CurrentAction = FuXiAction.None;
            public float ActionProgress = 0f;

            // Points of Interest this NPC knows about
            public List<UXVector3> KnownLocations = new();
        }

        // ================================================================
        // ACTIONS
        // ================================================================
        public enum FuXiAction : byte
        {
            None = 0,
            Wander = 1,
            Rest = 2,
            Eat = 3,
            Investigate = 4,
            Flee = 5,
            Confront = 6,
            Socialize = 7,
            Guard = 8,
            Sleep = 9,
        }

        // ================================================================
        // FuXi NPC REGISTRY
        // ================================================================

        static readonly Dictionary<ulong, FuXiNpc> _fuXiNpcs = new();

        public static void RegisterFuXiNpc(Connection conn, FuXiNpc fuxi)
        {
            _fuXiNpcs[fuxi.EntityId] = fuxi;

            // Register in main NPC list
            var npc = new Connection.SpawnedNpc()
            {
                EntityId = fuxi.EntityId,
                FormworkId = fuxi.FormworkId,
                PosX = fuxi.PosX,
                PosY = fuxi.PosY,
                PosZ = fuxi.PosZ,
                Facing = fuxi.Facing,
                OriginX = fuxi.PosX,
                OriginZ = fuxi.PosZ,
                CurrentState = Connection.NpcState.Idle,
                IsStatic = false,
                DesiredSpeed = 1.8f,
            };
            npc.Board?.Set("isFuXi", true);
            BTFactory.AssignTree(npc);
            conn.RegisterSpawnedNpc(npc);
        }

        public static FuXiNpc GetFuXi(ulong entityId)
        {
            _fuXiNpcs.TryGetValue(entityId, out var fuxi);
            return fuxi;
        }

        public static IEnumerable<FuXiNpc> GetAllFuXi() => _fuXiNpcs.Values;

        /// <summary>
        /// Clean up FuXi NPCs owned by a connection (called on disconnect).
        /// Prevents memory leak from static _fuXiNpcs dictionary.
        /// </summary>
        public static void CleanupConnection(Connection conn)
        {
            var liveNpcs = conn.GetLiveNpcs();
            foreach (var npc in liveNpcs)
            {
                _fuXiNpcs.Remove(npc.EntityId);
            }
        }

        // ================================================================
        // AI TICK — Decision making based on personality + status + perception
        // ================================================================

        public static void Tick(Connection conn)
        {
            foreach (var fuxi in _fuXiNpcs.Values)
            {
                // Update perception
                UpdatePerception(conn, fuxi);

                // Update numerical status (slow decay/regen)
                UpdateStatus(fuxi);

                // Make decision
                var newAction = DecideAction(fuxi);

                if (newAction != fuxi.CurrentAction)
                {
                    ExecuteAction(conn, fuxi, newAction);
                    fuxi.CurrentAction = newAction;
                    fuxi.LastActionTime = DateTime.UtcNow;
                }

                // Progress current action
                ProgressAction(conn, fuxi);
            }
        }

        static void UpdatePerception(Connection conn, FuXiNpc fuxi)
        {
            if (fuxi.PlayerInfo == null) fuxi.PlayerInfo = new PlayerPerception();

            float dx = fuxi.PosX - conn.LastKnownPlayerPosition.X;
            float dz = fuxi.PosZ - conn.LastKnownPlayerPosition.Z;
            fuxi.PlayerInfo.DistanceToPlayer = MathF.Sqrt(dx * dx + dz * dz);
            fuxi.PlayerInfo.PlayerIsInCombat = conn.InCombat;

            if (fuxi.Environment == null) fuxi.Environment = new EnvironmentInfo();
            fuxi.Environment.TimeOfDay = conn.CurrentHour;
            fuxi.Environment.IsNight = conn.CurrentHour < 6 || conn.CurrentHour >= 22;
        }

        static void UpdateStatus(FuXiNpc fuxi)
        {
            if (fuxi.Status == null) fuxi.Status = new NumericalStatus();

            // Slow hunger increase
            fuxi.Status.Hunger = MathF.Max(0, fuxi.Status.Hunger - 0.1f);
            if (fuxi.Status.Hunger < 20f) fuxi.BodyState = BodyStateType.Hungry;

            // Stamina regen when resting
            if (fuxi.CurrentAction == FuXiAction.Rest || fuxi.CurrentAction == FuXiAction.Sleep)
            {
                fuxi.Status.Stamina = MathF.Min(100f, fuxi.Status.Stamina + 0.5f);
            }
            else
            {
                fuxi.Status.Stamina = MathF.Max(0, fuxi.Status.Stamina - 0.05f);
            }

            // Fear from combat nearby
            if (fuxi.PlayerInfo?.PlayerIsInCombat == true && fuxi.PlayerInfo.DistanceToPlayer < 20f)
            {
                fuxi.Status.Fear = MathF.Min(100f, fuxi.Status.Fear + (1f - fuxi.Personality?.Bravery ?? 0.5f) * 2f);
            }
            else
            {
                fuxi.Status.Fear = MathF.Max(0, fuxi.Status.Fear - 0.5f);
            }

            if (fuxi.Status.Fear > 60f) fuxi.BodyState = BodyStateType.Scared;
        }

        // ================================================================
        // DECISION MAKING
        // ================================================================

        static FuXiAction DecideAction(FuXiNpc fuxi)
        {
            var p = fuxi.Personality ?? new Personality() { Bravery = 0.5f, Friendliness = 0.5f, Curiosity = 0.5f, Aggression = 0.3f, Laziness = 0.3f };
            var s = fuxi.Status ?? new NumericalStatus();
            var pi = fuxi.PlayerInfo ?? new PlayerPerception();

            // Score each possible action
            float fleeScore = 0f;
            float confrontScore = 0f;
            float restScore = 0f;
            float eatScore = 0f;
            float investigateScore = 0f;
            float socializeScore = 0f;
            float sleepScore = 0f;
            float wanderScore = 5f; // base wander

            // Danger response
            if (pi.PlayerIsInCombat && pi.DistanceToPlayer < 20f)
            {
                fleeScore += (1f - p.Bravery) * 50f;
                confrontScore += p.Bravery * p.Aggression * 40f;
            }

            // Status needs
            if (s.Stamina < 30f) restScore += 30f;
            if (s.Hunger < 30f) eatScore += 25f;
            if (s.Fear > 50f) fleeScore += s.Fear * 0.5f;

            // Night behavior
            if (fuxi.Environment?.IsNight == true)
            {
                sleepScore += 20f + p.Laziness * 20f;
            }

            // Player nearby → socialize or investigate
            if (pi.DistanceToPlayer < 15f && !pi.PlayerIsInCombat)
            {
                socializeScore += p.Friendliness * 25f;
                investigateScore += p.Curiosity * 15f;
            }

            // Pick highest scoring action
            var best = FuXiAction.Wander;
            float bestScore = wanderScore;

            if (fleeScore > bestScore) { best = FuXiAction.Flee; bestScore = fleeScore; }
            if (confrontScore > bestScore) { best = FuXiAction.Confront; bestScore = confrontScore; }
            if (restScore > bestScore) { best = FuXiAction.Rest; bestScore = restScore; }
            if (eatScore > bestScore) { best = FuXiAction.Eat; bestScore = eatScore; }
            if (investigateScore > bestScore) { best = FuXiAction.Investigate; bestScore = investigateScore; }
            if (socializeScore > bestScore) { best = FuXiAction.Socialize; bestScore = socializeScore; }
            if (sleepScore > bestScore) { best = FuXiAction.Sleep; bestScore = sleepScore; }

            return best;
        }

        // ================================================================
        // ACTION EXECUTION
        // ================================================================

        static void ExecuteAction(Connection conn, FuXiNpc fuxi, FuXiAction action)
        {
            var npc = conn.GetNpcById(fuxi.EntityId);
            if (npc == null) return;

            switch (action)
            {
                case FuXiAction.Flee:
                    npc.CurrentState = Connection.NpcState.Fleeing;
                    MovementScheduler.SetMovementMode(conn, npc, Connection.MovementMode.Flee);
                    break;

                case FuXiAction.Confront:
                    npc.CurrentState = Connection.NpcState.PatrolWalking;
                    MovementScheduler.SetMovementMode(conn, npc, Connection.MovementMode.Run);
                    break;

                case FuXiAction.Rest:
                    npc.CurrentState = Connection.NpcState.Sitting;
                    MovementScheduler.SetMovementMode(conn, npc, Connection.MovementMode.Idle);
                    break;

                case FuXiAction.Eat:
                    npc.CurrentState = Connection.NpcState.Eating;
                    MovementScheduler.SetMovementMode(conn, npc, Connection.MovementMode.Idle);
                    break;

                case FuXiAction.Sleep:
                    npc.CurrentState = Connection.NpcState.Sleeping;
                    MovementScheduler.SetMovementMode(conn, npc, Connection.MovementMode.Idle);
                    break;

                case FuXiAction.Socialize:
                    npc.CurrentState = Connection.NpcState.Talking;
                    MovementScheduler.SetMovementMode(conn, npc, Connection.MovementMode.Idle);
                    break;

                case FuXiAction.Investigate:
                    npc.CurrentState = Connection.NpcState.PatrolWalking;
                    MovementScheduler.SetMovementMode(conn, npc, Connection.MovementMode.Walk);
                    break;

                case FuXiAction.Wander:
                    npc.CurrentState = Connection.NpcState.Wandering;
                    MovementScheduler.SetMovementMode(conn, npc, Connection.MovementMode.Walk);
                    break;
            }
        }

        static void ProgressAction(Connection conn, FuXiNpc fuxi)
        {
            double elapsed = (DateTime.UtcNow - fuxi.LastActionTime).TotalSeconds;

            switch (fuxi.CurrentAction)
            {
                case FuXiAction.Eat:
                    if (elapsed > 10)
                    {
                        fuxi.Status.Hunger = MathF.Min(100f, fuxi.Status.Hunger + 30f);
                        fuxi.CurrentAction = FuXiAction.None; // will re-decide
                    }
                    break;

                case FuXiAction.Rest:
                    if (fuxi.Status.Stamina >= 80f)
                    {
                        fuxi.CurrentAction = FuXiAction.None;
                    }
                    break;

                case FuXiAction.Flee:
                    if (fuxi.PlayerInfo?.PlayerIsInCombat != true || elapsed > 15)
                    {
                        fuxi.Status.Fear = MathF.Max(0, fuxi.Status.Fear - 20f);
                        fuxi.CurrentAction = FuXiAction.None;
                    }
                    break;

                case FuXiAction.Sleep:
                    if (fuxi.Environment?.IsNight != true || fuxi.Status.Stamina >= 90f)
                    {
                        fuxi.CurrentAction = FuXiAction.None;
                    }
                    break;
            }
        }

        // ================================================================
        // FACTORY — create FuXi NPC with random personality
        // ================================================================

        public static FuXiNpc CreateFuXiNpc(ulong entityId, uint formworkId, string name, float x, float z)
        {
            var rng = new Random(entityId.GetHashCode());
            return new FuXiNpc
            {
                EntityId = entityId,
                FormworkId = formworkId,
                Name = name,
                PosX = x,
                PosY = 0,
                PosZ = z,
                Facing = (float)(rng.NextDouble() * 360f),
                Personality = new Personality
                {
                    Bravery = 0.2f + (float)rng.NextDouble() * 0.6f,
                    Friendliness = 0.3f + (float)rng.NextDouble() * 0.5f,
                    Curiosity = 0.2f + (float)rng.NextDouble() * 0.6f,
                    Aggression = 0.1f + (float)rng.NextDouble() * 0.4f,
                    Laziness = 0.1f + (float)rng.NextDouble() * 0.5f,
                },
                Status = new NumericalStatus(),
                Environment = new EnvironmentInfo(),
                PlayerInfo = new PlayerPerception(),
            };
        }
    }
}
