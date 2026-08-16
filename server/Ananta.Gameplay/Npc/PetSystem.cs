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
    /// Pet/Animal System — companion animals with behavior states.
    /// Mirrors DLL's PetUnit, AnimalPerformModule, PetAnimalNpcState*.
    ///
    /// Pet states: Init → Fade → Interactive → NormalPerform → CustomAI
    /// Pets follow the player, perform idle animations, and interact with NPCs.
    /// </summary>
    public static class PetSystem
    {
        static readonly Random _rng = new Random();
        // ================================================================
        // PET STATES (mirrors DLL PetAnimalNpcStateType)
        // ================================================================
        public enum PetState : byte
        {
            Init = 0,           // Spawning, fade-in
            Fade = 1,           // Fading in/out
            Interactive = 2,    // Can interact with player
            NormalPerform = 3,  // Playing idle animations
            CustomAI = 4,       // Custom AI behavior (follow, guard, etc.)
            Following = 5,      // Following the player
            Performing = 6,     // Playing a specific trick/animation
            Sleeping = 7,       // Pet sleeping
        }

        // ================================================================
        // PET DATA
        // ================================================================
        public class PetData
        {
            public ulong EntityId;
            public uint FormworkId;
            public string Name;
            public ulong OwnerPid;           // player who owns this pet
            public PetState CurrentPetState = PetState.Init;
            public float PosX, PosY, PosZ;
            public float Facing;
            public float FollowDistance = 5f; // distance to keep from owner
            public int FavorLevel = 50;       // 0-100, affects behavior
            public DateTime StateEnteredAt = DateTime.UtcNow;
            public uint CurrentAnimId = 0;

            // Perform data — animation tricks the pet can do
            public List<uint> PerformAnimIds = new() { 100, 101, 102 }; // sit, roll, bark
        }

        // ================================================================
        // PET REGISTRY (per-connection)
        // ================================================================

        static readonly Dictionary<ulong, List<PetData>> _petsByConnection = new();

        public static void RegisterPet(Connection conn, PetData pet)
        {
            if (!_petsByConnection.ContainsKey(conn.Pid))
                _petsByConnection[conn.Pid] = new();
            _petsByConnection[conn.Pid].Add(pet);

            // Also register in the main NPC list for position tracking
            var npc = new Connection.SpawnedNpc()
            {
                EntityId = pet.EntityId,
                FormworkId = pet.FormworkId,
                PosX = pet.PosX,
                PosY = pet.PosY,
                PosZ = pet.PosZ,
                Facing = pet.Facing,
                OriginX = pet.PosX,
                OriginZ = pet.PosZ,
                CurrentState = Connection.NpcState.Idle,
                IsStatic = false,
                DesiredSpeed = 2.0f,
            };
            npc.Board?.Set("isPet", true);
            npc.Board?.Set("petOwnerPid", pet.OwnerPid);
            BTFactory.AssignTree(npc);
            conn.RegisterSpawnedNpc(npc);
        }

        public static List<PetData> GetPets(Connection conn)
        {
            _petsByConnection.TryGetValue(conn.Pid, out var pets);
            return pets ?? new();
        }

        public static PetData GetPetById(Connection conn, ulong entityId)
        {
            var pets = GetPets(conn);
            return pets?.Find(p => p.EntityId == entityId);
        }

        // ================================================================
        // PET BEHAVIOR TICK
        // ================================================================

        /// <summary>
        /// Update pet behavior. Called from tick loop.
        /// Pets follow the player, play idle animations, and respond to interactions.
        /// </summary>
        public static void TickPets(Connection conn)
        {
            var pets = GetPets(conn);
            if (pets == null || pets.Count == 0) return;

            foreach (var pet in pets)
            {
                switch (pet.CurrentPetState)
                {
                    case PetState.Init:
                        TickInit(conn, pet);
                        break;

                    case PetState.Following:
                        TickFollowing(conn, pet);
                        break;

                    case PetState.NormalPerform:
                        TickNormalPerform(conn, pet);
                        break;

                    case PetState.Performing:
                        TickPerforming(conn, pet);
                        break;

                    case PetState.Interactive:
                        TickInteractive(conn, pet);
                        break;

                    case PetState.Sleeping:
                        // Sleeping pets don't do anything until woken
                        break;
                }
            }
        }

        static void TickInit(Connection conn, PetData pet)
        {
            // After 2 seconds, transition to following
            if ((DateTime.UtcNow - pet.StateEnteredAt).TotalSeconds >= 2.0)
            {
                SetPetState(pet, PetState.Following);
            }
        }

        static void TickFollowing(Connection conn, PetData pet)
        {
            // Follow the player at a set distance
            float px = conn.LastKnownPlayerPosition.X;
            float pz = conn.LastKnownPlayerPosition.Z;
            float dx = px - pet.PosX;
            float dz = pz - pet.PosZ;
            float dist = MathF.Sqrt(dx * dx + dz * dz);

            if (dist > pet.FollowDistance + 3f)
            {
                // Generate path towards player
                var path = new List<ClientZoneGraphPathPoint>()
                {
                    new ClientZoneGraphPathPoint()
                    {
                        Position = new UXVector3()
                        {
                            X = px - (dx / dist) * pet.FollowDistance,
                            Y = 0,
                            Z = pz - (dz / dist) * pet.FollowDistance
                        },
                        Facing = (byte)(MathF.Atan2(dx, dz) * 128f / MathF.PI + 128)
                    }
                };

                var npc = conn.GetNpcById(pet.EntityId);
                if (npc != null)
                {
                    npc.Waypoints = path;
                    npc.CurrentWaypointIndex = 0;
                    MovementScheduler.SetMovementMode(conn, npc, Connection.MovementMode.Run);
                    BTActions.SendCrowdFollowPath(conn, npc);

                    // Update position tracking
                    pet.PosX = path[0].Position.X;
                    pet.PosZ = path[0].Position.Z;
                }
            }
            else if (dist <= pet.FollowDistance)
            {
                // Close enough — play idle animation occasionally
                double timeSinceState = (DateTime.UtcNow - pet.StateEnteredAt).TotalSeconds;
                if (timeSinceState >= 15.0)
                {
                    SetPetState(pet, PetState.NormalPerform);
                }
            }
        }

        static void TickNormalPerform(Connection conn, PetData pet)
        {
            // Play a random idle animation
            double timeSinceState = (DateTime.UtcNow - pet.StateEnteredAt).TotalSeconds;
            if (timeSinceState >= 5.0)
            {
                // Pick a random perform animation
                    if (pet.PerformAnimIds.Count > 0)
                    {
                        pet.CurrentAnimId = pet.PerformAnimIds[_rng.Next(pet.PerformAnimIds.Count)];

                    var npc = conn.GetNpcById(pet.EntityId);
                    if (npc != null)
                    {
                        BTActions.SendNotify(conn, MethodId.SyncAetherAINpcPlayAnimation,
                            new ClientNpcPlayAnimationData()
                            {
                                Id = pet.EntityId,
                                PoiActionId = pet.CurrentAnimId,
                                StartTime = 0
                            });
                    }
                }

                // After animation, go back to following
                SetPetState(pet, PetState.Following);
            }
        }

        static void TickPerforming(Connection conn, PetData pet)
        {
            // Performing a trick — wait for animation duration then go back to following
            double timeSinceState = (DateTime.UtcNow - pet.StateEnteredAt).TotalSeconds;
            if (timeSinceState >= 3.0)
            {
                SetPetState(pet, PetState.Following);
            }
        }

        static void TickInteractive(Connection conn, PetData pet)
        {
            // Interactive mode — waiting for player interaction
            double timeSinceState = (DateTime.UtcNow - pet.StateEnteredAt).TotalSeconds;
            if (timeSinceState >= 30.0)
            {
                // Timeout — go back to following
                SetPetState(pet, PetState.Following);
            }
        }

        // ================================================================
        // PET STATE MANAGEMENT
        // ================================================================

        public static void SetPetState(PetData pet, PetState newState)
        {
            pet.CurrentPetState = newState;
            pet.StateEnteredAt = DateTime.UtcNow;
        }

        /// <summary>
        /// Command a pet to perform a specific trick.
        /// </summary>
        public static void PerformTrick(Connection conn, ulong petEntityId, uint animId)
        {
            var pet = GetPetById(conn, petEntityId);
            if (pet == null) return;

            pet.CurrentAnimId = animId;
            SetPetState(pet, PetState.Performing);

            var npc = conn.GetNpcById(petEntityId);
            if (npc != null)
            {
                BTActions.SendNotify(conn, MethodId.SyncAetherAINpcPlayAnimation,
                    new ClientNpcPlayAnimationData()
                    {
                        Id = petEntityId,
                        PoiActionId = animId,
                        StartTime = 0
                    });
            }
        }

        /// <summary>
        /// Increase or decrease pet favor (affection level).
        /// </summary>
        public static void ModifyFavor(PetData pet, int delta)
        {
            pet.FavorLevel = Math.Clamp(pet.FavorLevel + delta, 0, 100);
        }

        /// <summary>
        /// Clean up all pet state for a connection (called on disconnect).
        /// Prevents memory leak from static _petsByConnection dictionary.
        /// </summary>
        public static void CleanupConnection(Connection conn)
        {
            _petsByConnection.Remove(conn.Pid);
        }
    }
}
