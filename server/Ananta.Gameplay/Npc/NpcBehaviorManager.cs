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
    /// NPC Behavior Manager — now powered by Behavior Trees.
    ///
    /// Each NPC has a BTTree (assigned by BTFactory on spawn).
    /// Every tick (~2s), we evaluate the tree for each live NPC.
    /// The tree uses UtilitySelector to pick the highest-scoring branch:
    ///   - FLEE (score=100) when player is in combat or nearby
    ///   - REACT (score=50) when player is nearby (greet animation)
    ///   - PATROL (score=10) when idle for 4+ seconds
    ///   - IDLE (score=1) default fallback
    ///
    /// The server sends high-level commands (paths, speed changes, animations)
    /// and the client handles detailed locomotion/animation.
    /// </summary>
    public static class NpcBehaviorManager
    {
        public static bool Enabled { get; set; } = true;

        /// <summary>
        /// Called every tick by GameTickService.
        /// Pipeline per NPC:
        ///   LifeSchedule → EmotionSystem → PoliceAI → GoalPlanner → MovementScheduler → BehaviorTree
        /// </summary>
        public static void Tick(Connection conn)
        {
            if (!Enabled) return;

            var liveNpcs = conn.GetLiveNpcs();
            if (liveNpcs.Count == 0) return;

            // Process all NPCs to ensure movement and behavior updates
            foreach (var npc in liveNpcs)
            {
                // Skip dead NPCs or hidden NPCs (below ground for memory optimization)
                if (npc.CurrentState == Connection.NpcState.Dead) continue;
                if (npc.IsHidden) continue;

                // Layer 0a: Life Schedule — daily routine based on time of day
                LifeSchedule.EvaluateSchedule(conn, npc);

                // Layer 0b: Emotion System — evaluate and sync emotions
                EmotionSystem.EvaluateEmotion(conn, npc);

                // Layer 0c: Police AI — police examine/chase/arrest behavior
                PoliceAI.EvaluatePoliceBehavior(conn, npc);

                // Layer 1: GOAP — evaluate goals (periodic, not every tick)
                GoalPlanner.EvaluateGoals(conn, npc);

                // Layer 2: Movement Scheduler — sync movement mode with NPC state
                MovementScheduler.SyncMovementModeFromState(conn, npc);

                // Layer 3: Behavior Tree — decision making
                if (npc.BehaviorTree == null)
                {
                    BTFactory.AssignTree(npc);
                }
                npc.BehaviorTree?.Evaluate(conn, npc);
            }

            // Layer 4: Pet System — pet behavior (follow, perform, interact)
            PetSystem.TickPets(conn);

            // Layer 5: FuXi NPC AI — special NPC decision making
            FuXiNpcAI.Tick(conn);

            // Layer 6: City Systems — formation movement
            CitySystems.TickFormations(conn);
        }

        // ================================================================
        // PUBLIC API: External triggers (called from combat handlers, etc.)
        // ================================================================

        /// <summary>
        /// Trigger flee on nearby NPCs from a danger point.
        /// This directly sets Fleeing state + flee path, bypassing BT evaluation.
        /// Useful as an immediate reaction to combat events.
        /// </summary>
        public static void TriggerFleeNearby(Connection conn, float dangerX, float dangerZ, float radius)
        {
            if (!Enabled) return;

            foreach (var npc in conn.GetLiveNpcs())
            {
                if (npc.IsStatic) continue;
                if (npc.CurrentState == Connection.NpcState.Dead) continue;

                float dx = npc.PosX - dangerX;
                float dz = npc.PosZ - dangerZ;
                float dist = MathF.Sqrt(dx * dx + dz * dz);

                if (dist <= radius)
                {
                    // Send scare + speed up
                    BTActions.SendNpcScare(conn, npc.EntityId, radius, radius * 1.5f, true);
                    BTActions.SendChangeSpeed(conn, npc, npc.DesiredSpeed * 2.5f);

                    // Generate flee path
                    var fleePath = DynamicPathGenerator.GeneratePath(
                        npc.PosX, npc.PosZ,
                        npc.OriginX, npc.OriginZ,
                        DynamicPathGenerator.PathType.FleeFromPoint,
                        dangerX, dangerZ);

                    if (fleePath != null && fleePath.Count >= 1)
                    {
                        npc.Waypoints = fleePath;
                        npc.CurrentWaypointIndex = 0;
                        npc.CurrentState = Connection.NpcState.Fleeing;
                        npc.StateEnteredAt = DateTime.UtcNow;
                        BTActions.SendCrowdFollowPath(conn, npc);

                        var last = fleePath[fleePath.Count - 1];
                        npc.PosX = last.Position.X;
                        npc.PosZ = last.Position.Z;
                    }

                    // Reset BT so it re-evaluates from scratch
                    npc.BehaviorTree?.Root.Reset();
                }
            }
        }
    }
}
