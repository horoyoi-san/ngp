using System;

namespace AnantaTestGameServer.BehaviorTreeEngine
{
    // ================================================================
    // BASE CONDITION — leaf node that returns Success or Failure
    // Mirrors BehaviorAI.Node.Conditional<T>.GetResult()
    // ================================================================
    public abstract class BTCondition : BTNode
    {
        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            return Check(ctx) ? TaskStatus.Success : TaskStatus.Failure;
        }

        protected abstract bool Check(BTContext ctx);
    }

    // ================================================================
    // CHECK DISTANCE TO PLAYER
    // Returns Success if player is within the specified radius.
    // Mirrors DLL: CheckDistanceToPlayer (SharedVariable<float> distance)
    // ================================================================
    public class CheckDistanceToPlayer : BTCondition
    {
        public float Radius { get; set; }

        public CheckDistanceToPlayer(float radius)
        {
            Radius = radius;
            Name = $"DistToPlayer<={radius}";
        }

        protected override bool Check(BTContext ctx)
        {
            return ctx.PlayerDist <= Radius;
        }
    }

    // ================================================================
    // IS PLAYER NEARBY — simplified distance check
    // ================================================================
    public class IsPlayerNearby : BTCondition
    {
        public float Radius { get; set; }

        public IsPlayerNearby(float radius)
        {
            Radius = radius;
            Name = $"PlayerNearby<={radius}";
        }

        protected override bool Check(BTContext ctx)
        {
            return ctx.PlayerDist <= Radius;
        }
    }

    // ================================================================
    // CHECK PLAYER COMBAT — returns Success if player is in combat
    // Uses conn.InCombat state from the combat system
    // ================================================================
    public class CheckPlayerCombat : BTCondition
    {
        public CheckPlayerCombat()
        {
            Name = "PlayerInCombat";
        }

        protected override bool Check(BTContext ctx)
        {
            return ctx.Conn.InCombat;
        }
    }

    // ================================================================
    // CHECK NPC ALIVE — returns Success if NPC is not dead
    // ================================================================
    public class CheckNpcAlive : BTCondition
    {
        public CheckNpcAlive()
        {
            Name = "NpcAlive";
        }

        protected override bool Check(BTContext ctx)
        {
            return ctx.Npc.CurrentState != Connection.NpcState.Dead
                && !ctx.Npc.IsDestroyed;
        }
    }

    // ================================================================
    // CHECK TIME IN STATE — returns Success if NPC has been in
    // current state for at least the specified duration.
    // ================================================================
    public class CheckTimeInState : BTCondition
    {
        public double MinSeconds { get; set; }

        public CheckTimeInState(double minSeconds)
        {
            MinSeconds = minSeconds;
            Name = $"TimeInState>={minSeconds}s";
        }

        protected override bool Check(BTContext ctx)
        {
            return ctx.TimeInState >= MinSeconds;
        }
    }

    // ================================================================
    // IS STATIC — returns Success if NPC is a static (non-moving) NPC
    // ================================================================
    public class IsStatic : BTCondition
    {
        public IsStatic()
        {
            Name = "IsStatic";
        }

        protected override bool Check(BTContext ctx)
        {
            return ctx.Npc.IsStatic;
        }
    }

    // ================================================================
    // IS MOVING — returns Success if NPC is currently walking/patrolling
    // ================================================================
    public class IsMoving : BTCondition
    {
        public IsMoving()
        {
            Name = "IsMoving";
        }

        protected override bool Check(BTContext ctx)
        {
            return ctx.Npc.CurrentState == Connection.NpcState.PatrolWalking
                || ctx.Npc.CurrentState == Connection.NpcState.Wandering;
        }
    }

    // ================================================================
    // IS FLEEING — returns Success if NPC is currently fleeing
    // ================================================================
    public class IsFleeing : BTCondition
    {
        public IsFleeing()
        {
            Name = "IsFleeing";
        }

        protected override bool Check(BTContext ctx)
        {
            return ctx.Npc.CurrentState == Connection.NpcState.Fleeing;
        }
    }

    // ================================================================
    // CHECK TIME OF DAY — returns Success if current hour matches range
    // ================================================================
    public class CheckTimeOfDay : BTCondition
    {
        public int MinHour { get; set; }
        public int MaxHour { get; set; }

        public CheckTimeOfDay(int minHour, int maxHour)
        {
            MinHour = minHour;
            MaxHour = maxHour;
            Name = $"TimeOfDay({minHour}-{maxHour})";
        }

        protected override bool Check(BTContext ctx)
        {
            // Use DateTime.Now.Hour for server time
            int hour = DateTime.Now.Hour;
            if (MinHour <= MaxHour)
                return hour >= MinHour && hour <= MaxHour;
            else // wraps around midnight (e.g., 22-6)
                return hour >= MinHour || hour <= MaxHour;
        }
    }

    // ================================================================
    // CHECK NEARBY NPCS — returns Success if other NPCs are nearby
    // ================================================================
    public class CheckNearbyNpcs : BTCondition
    {
        public float Radius { get; set; }
        public int MinCount { get; set; }

        public CheckNearbyNpcs(float radius, int minCount = 1)
        {
            Radius = radius;
            MinCount = minCount;
            Name = $"NearbyNpcs>={minCount}@{radius}m";
        }

        protected override bool Check(BTContext ctx)
        {
            int count = 0;
            foreach (var other in ctx.Conn.GetLiveNpcs())
            {
                if (other.EntityId == ctx.Npc.EntityId) continue;
                float dx = other.PosX - ctx.Npc.PosX;
                float dz = other.PosZ - ctx.Npc.PosZ;
                float dist = MathF.Sqrt(dx * dx + dz * dz);
                if (dist <= Radius) count++;
            }
            return count >= MinCount;
        }
    }

    // ================================================================
    // CHECK RANDOM CHANCE — returns Success based on probability
    // ================================================================
    public class CheckRandomChance : BTCondition
    {
        public float Probability { get; set; }
        private static readonly Random _rng = new Random();

        public CheckRandomChance(float probability)
        {
            Probability = Math.Clamp(probability, 0f, 1f);
            Name = $"Random({Probability:P0})";
        }

        protected override bool Check(BTContext ctx)
        {
            return (float)_rng.NextDouble() < Probability;
        }
    }

    // ================================================================
    // CHECK PLAYER VEHICLE — returns Success if player is in vehicle
    // ================================================================
    public class CheckPlayerInVehicle : BTCondition
    {
        public CheckPlayerInVehicle()
        {
            Name = "PlayerInVehicle";
        }

        protected override bool Check(BTContext ctx)
        {
            // Check if player has a current vehicle
            return ctx.Conn.CurrentVehicleId != 0;
        }
    }

    // ================================================================
    // CHECK IDLE TOO LONG — returns Success if idle for too long
    // ================================================================
    public class CheckIdleTooLong : BTCondition
    {
        public double MaxIdleSeconds { get; set; }

        public CheckIdleTooLong(double maxIdleSeconds)
        {
            MaxIdleSeconds = maxIdleSeconds;
            Name = $"IdleTooLong>{maxIdleSeconds}s";
        }

        protected override bool Check(BTContext ctx)
        {
            return ctx.Npc.CurrentState == Connection.NpcState.Idle
                && ctx.TimeInState >= MaxIdleSeconds;
        }
    }
}
