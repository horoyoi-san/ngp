using System;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// Goal-Oriented Action Planning (GOAP) for NPCs.
    /// Mirrors DLL's GoalModule + BehaviorProcessorModule.
    ///
    /// NPCs generate goals based on their situation, then the GoalPlanner
    /// selects the highest-priority goal and feeds it to the Behavior Tree.
    ///
    /// Goals: ReturnToOrigin, Patrol, Flee, Explore, Idle, Interact
    /// Priority scoring considers: distance to origin, time idle,
    /// player proximity, combat state, NPC health/state.
    /// </summary>
    public static class GoalPlanner
    {
        // How often to re-evaluate goals (seconds). Goals don't need per-tick evaluation.
        private const double ReevaluationIntervalSeconds = 6.0;
        static readonly Random _rng = new Random();

        /// <summary>
        /// Evaluate and assign the best goal for an NPC.
        /// Called from NpcBehaviorManager.Tick() before BT evaluation.
        /// </summary>
        public static void EvaluateGoals(Connection conn, Connection.SpawnedNpc npc)
        {
            if (npc.IsStatic)
            {
                npc.CurrentGoal = Connection.NpcGoal.Idle;
                return;
            }

            // Only re-evaluate periodically
            double timeSinceLastEval = (DateTime.UtcNow - npc.StateEnteredAt).TotalSeconds;
            if (npc.CurrentGoal != Connection.NpcGoal.None && timeSinceLastEval < ReevaluationIntervalSeconds)
            {
                return; // keep current goal
            }

            // Score each goal
            float fleeScore = ScoreFleeGoal(conn, npc);
            float returnScore = ScoreReturnGoal(conn, npc);
            float patrolScore = ScorePatrolGoal(conn, npc);
            float exploreScore = ScoreExploreGoal(conn, npc);
            float idleScore = ScoreIdleGoal(conn, npc);

            // Pick highest-scoring goal
            var bestGoal = Connection.NpcGoal.Idle;
            float bestScore = idleScore;

            if (exploreScore > bestScore) { bestGoal = Connection.NpcGoal.Explore; bestScore = exploreScore; }
            if (patrolScore > bestScore) { bestGoal = Connection.NpcGoal.Patrol; bestScore = patrolScore; }
            if (returnScore > bestScore) { bestGoal = Connection.NpcGoal.ReturnToOrigin; bestScore = returnScore; }
            if (fleeScore > bestScore) { bestGoal = Connection.NpcGoal.Flee; bestScore = fleeScore; }

            npc.CurrentGoal = bestGoal;
        }

        // ================================================================
        // GOAL SCORING FUNCTIONS
        // ================================================================

        /// <summary>
        /// FLEE: High score when player is in combat or very close.
        /// </summary>
        static float ScoreFleeGoal(Connection conn, Connection.SpawnedNpc npc)
        {
            float score = 0f;

            // Player in combat nearby
            if (conn.InCombat)
            {
                float dx = npc.PosX - conn.LastKnownPlayerPosition.X;
                float dz = npc.PosZ - conn.LastKnownPlayerPosition.Z;
                float dist = MathF.Sqrt(dx * dx + dz * dz);

                if (dist < 20f)
                    score = 100f - (dist * 2f); // 100 at 0m, 60 at 20m
            }

            // Currently fleeing — keep fleeing until safe
            if (npc.CurrentState == Connection.NpcState.Fleeing)
            {
                score = Math.Max(score, 80f);
            }

            return score;
        }

        /// <summary>
        /// RETURN TO ORIGIN: High score when NPC is far from spawn point.
        /// Prevents NPCs from drifting too far away.
        /// </summary>
        static float ScoreReturnGoal(Connection conn, Connection.SpawnedNpc npc)
        {
            float dx = npc.PosX - npc.OriginX;
            float dz = npc.PosZ - npc.OriginZ;
            float distFromOrigin = MathF.Sqrt(dx * dx + dz * dz);

            // Urgency increases with distance
            if (distFromOrigin > DynamicPathGenerator.MaxWanderRadius * 0.8f)
                return 70f; // very far — must return

            if (distFromOrigin > DynamicPathGenerator.MaxWanderRadius * 0.5f)
                return 30f; // getting far — should return soon

            return 0f; // close enough, no need
        }

        /// <summary>
        /// PATROL: Default active behavior. High score when idle for a while.
        /// </summary>
        static float ScorePatrolGoal(Connection conn, Connection.SpawnedNpc npc)
        {
            float score = 10f; // base patrol score

            // Bonus for being idle (bored NPC wants to walk)
            if (npc.CurrentState == Connection.NpcState.Idle)
            {
                double idleTime = (DateTime.UtcNow - npc.StateEnteredAt).TotalSeconds;
                score += (float)Math.Min(idleTime * 2.0, 30.0); // up to +30 for 15s idle
            }

            // Bonus if already patrolling (continuation)
            if (npc.CurrentState == Connection.NpcState.PatrolWalking)
            {
                score += 15f;
            }

            return score;
        }

        /// <summary>
        /// EXPLORE: Random wandering. Medium score when NPC hasn't moved much.
        /// Provides variety compared to structured patrol paths.
        /// </summary>
        static float ScoreExploreGoal(Connection conn, Connection.SpawnedNpc npc)
        {
            // Base explore score
            float score = 5f;

            // Slight bonus when idle (sometimes explore instead of patrol)
            if (npc.CurrentState == Connection.NpcState.Idle)
            {
                score += 5f;
            }

            // Small random factor for variety
            score += (float)(_rng.NextDouble() * 8.0);

            return score;
        }

        /// <summary>
        /// IDLE: Always available as fallback. Low base score.
        /// </summary>
        static float ScoreIdleGoal(Connection conn, Connection.SpawnedNpc npc)
        {
            return 1f; // minimum fallback
        }

        // ================================================================
        // GOAL → MOVEMENT MODE MAPPING
        // ================================================================

        /// <summary>
        /// Get the suggested movement mode for a goal.
        /// </summary>
        public static Connection.MovementMode GetMovementModeForGoal(Connection.NpcGoal goal)
        {
            return goal switch
            {
                Connection.NpcGoal.Flee => Connection.MovementMode.Flee,
                Connection.NpcGoal.Patrol => Connection.MovementMode.Walk,
                Connection.NpcGoal.Explore => Connection.MovementMode.Walk,
                Connection.NpcGoal.ReturnToOrigin => Connection.MovementMode.Walk,
                Connection.NpcGoal.Interact => Connection.MovementMode.Idle,
                Connection.NpcGoal.Idle => Connection.MovementMode.Idle,
                _ => Connection.MovementMode.Idle,
            };
        }

        /// <summary>
        /// Get the DynamicPathGenerator.PathType for a goal.
        /// </summary>
        public static DynamicPathGenerator.PathType GetPathTypeForGoal(Connection.NpcGoal goal)
        {
            return goal switch
            {
                Connection.NpcGoal.Flee => DynamicPathGenerator.PathType.FleeFromPoint,
                Connection.NpcGoal.Patrol => DynamicPathGenerator.PathType.CirclePatrol,
                Connection.NpcGoal.Explore => DynamicPathGenerator.PathType.WanderLoop,
                Connection.NpcGoal.ReturnToOrigin => DynamicPathGenerator.PathType.DirectionalWalk,
                _ => DynamicPathGenerator.PathType.WanderLoop,
            };
        }
    }
}
