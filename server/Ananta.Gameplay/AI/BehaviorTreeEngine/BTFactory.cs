using AnantaTestGameServer.BehaviorTreeEngine;

namespace AnantaTestGameServer.BehaviorTreeEngine
{
    /// <summary>
    /// Factory that builds behavior trees for different NPC types.
    /// Each NPC type gets a tree optimized for its role.
    /// </summary>
    public static class BTFactory
    {
        // ================================================================
        // CROWD NPC TREE — pedestrians that walk, react, and flee
        // ================================================================
        //
        // BTUtilitySelector (root)
        // ├── [score=100] FLEE: (PlayerInCombat OR PlayerNearby<8) → ActionFlee
        // ├── [score=80]  SOCIALIZE: NearbyNPCs>2 AND Random(30%) → ActionSocialize
        // ├── [score=60]  REACT: PlayerNearby<15 → ActionLookAtPlayer
        // ├── [score=40]  SIT: NightTime AND Random(20%) → ActionSitDown
        // ├── [score=20]  WANDER: IdleTooLong>8s → ActionWander
        // ├── [score=10]  PATROL: TimeInState>4s → ActionPatrol
        // └── [score=1]   IDLE: ActionIdle
        //
        public static BTTree CreateCrowdTree()
        {
            // FLEE branch (highest priority)
            var fleeCondition = new BTSelector(
                new CheckPlayerCombat(),
                new IsPlayerNearby(8f)
            );
            var fleeSequence = new BTSequence(fleeCondition, new ActionFlee(30f, 2.5f, 8f));

            // SOCIALIZE branch (interact with other NPCs)
            var socializeSequence = new BTSequence(
                new CheckNearbyNpcs(10f, 2),
                new CheckRandomChance(0.3f),
                new ActionSocialize(10f)
            );

            // REACT branch (look at player when nearby)
            var reactSequence = new BTSequence(
                new IsPlayerNearby(15f),
                new BTCooldown(new ActionLookAtPlayer(), 20f)
            );

            // SIT branch (rest at night)
            var sitSequence = new BTSequence(
                new CheckTimeOfDay(22, 6),
                new CheckRandomChance(0.2f),
                new ActionSitDown()
            );

            // WANDER branch (when idle too long)
            var wanderSequence = new BTSequence(
                new CheckIdleTooLong(8.0),
                new ActionWander(15f)
            );

            // PATROL branch (low priority)
            var patrolSequence = new BTSequence(
                new CheckTimeInState(4.0),
                new ActionPatrol()
            );

            // Build utility selector with scored branches
            var root = new BTUtilitySelector()
                .Add(100f, fleeSequence)
                .Add(80f, socializeSequence)
                .Add(60f, reactSequence)
                .Add(40f, sitSequence)
                .Add(20f, wanderSequence)
                .Add(10f, patrolSequence)
                .Add(1f, new ActionIdle());

            root.SwitchThreshold = 15f; // significant difference needed to switch

            return new BTTree("CrowdNPC", root);
        }

        // ================================================================
        // STATIC NPC TREE — fixed position, idle with occasional animations
        // ================================================================
        //
        // BTUtilitySelector (root)
        // ├── [score=100] FLEE: PlayerInCombat → ActionScare
        // ├── [score=5]   IDLE ANIM: TimeInState>10s → ActionPlayAnim (cooldown 30s)
        // └── [score=1]   IDLE: ActionIdle
        //
        public static BTTree CreateStaticTree()
        {
            // FLEE branch
            var fleeSequence = new BTSequence(
                new CheckPlayerCombat(),
                new ActionScare(20f)
            );

            // IDLE ANIM branch
            var idleAnimSequence = new BTSequence(
                new CheckTimeInState(10.0),
                new BTCooldown(new ActionPlayAnimation(0), 30f)
            );

            var root = new BTUtilitySelector()
                .Add(100f, fleeSequence)
                .Add(5f, idleAnimSequence)
                .Add(1f, new ActionIdle());

            root.SwitchThreshold = 10f;

            return new BTTree("StaticNPC", root);
        }

        // ================================================================
        // ASSIGN TREE — assign the appropriate tree to a spawned NPC
        // ================================================================
        public static void AssignTree(Connection.SpawnedNpc npc)
        {
            if (npc.IsStatic)
                npc.BehaviorTree = CreateStaticTree();
            else
                npc.BehaviorTree = CreateCrowdTree();
        }
    }
}
