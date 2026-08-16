using System;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// Life Schedule — NPCs follow daily routines based on time of day.
    /// Mirrors DLL's LifeScheduleNpcModule + LifeScheduleNpcActionExecutor.
    ///
    /// Time periods:
    ///   06:00-08:00  Morning  (wake up, eat breakfast)
    ///   08:00-12:00  Work     (working/walking to work)
    ///   12:00-13:00  Lunch    (eating)
    ///   13:00-18:00  Work     (working)
    ///   18:00-20:00  Evening  (leisure, shopping)
    ///   20:00-23:00  Night    (socializing, dancing)
    ///   23:00-06:00  Sleep    (sleeping)
    /// </summary>
    public static class LifeSchedule
    {
        public enum TimePeriod : byte
        {
            Morning = 0,   // 06-08
            Work = 1,       // 08-12, 13-18
            Lunch = 2,      // 12-13
            Evening = 3,    // 18-20
            Night = 4,      // 20-23
            Sleep = 5       // 23-06
        }

        /// <summary>
        /// Get the current time period based on server hour.
        /// Uses Connection.CurrentHour (set by GmSetTime) or real time.
        /// </summary>
        public static TimePeriod GetCurrentPeriod(Connection conn)
        {
            int hour = conn.CurrentHour;

            if (hour >= 6 && hour < 8) return TimePeriod.Morning;
            if (hour >= 8 && hour < 12) return TimePeriod.Work;
            if (hour >= 12 && hour < 13) return TimePeriod.Lunch;
            if (hour >= 13 && hour < 18) return TimePeriod.Work;
            if (hour >= 18 && hour < 20) return TimePeriod.Evening;
            if (hour >= 20 && hour < 23) return TimePeriod.Night;
            return TimePeriod.Sleep; // 23-06
        }

        /// <summary>
        /// Get the suggested NPC state for a time period.
        /// Static NPCs have limited schedule (always Idle or Working).
        /// Crowd NPCs have full daily routines.
        /// </summary>
        public static Connection.NpcState GetSuggestedState(TimePeriod period, bool isStatic)
        {
            if (isStatic)
            {
                // Static NPCs have simpler schedules
                return period switch
                {
                    TimePeriod.Sleep => Connection.NpcState.Idle, // stay idle, no sleeping anim
                    TimePeriod.Work => Connection.NpcState.Working,
                    TimePeriod.Lunch => Connection.NpcState.Eating,
                    _ => Connection.NpcState.Idle,
                };
            }

            // Crowd NPCs have full daily routines
            return period switch
            {
                TimePeriod.Morning => Connection.NpcState.PatrolWalking,  // walking to work
                TimePeriod.Work => Connection.NpcState.Working,
                TimePeriod.Lunch => Connection.NpcState.Eating,
                TimePeriod.Evening => Connection.NpcState.Shopping,
                TimePeriod.Night => Connection.NpcState.Dancing,
                TimePeriod.Sleep => Connection.NpcState.Sleeping,
                _ => Connection.NpcState.Idle,
            };
        }

        /// <summary>
        /// Evaluate life schedule for an NPC and transition if needed.
        /// Called periodically (not every tick — schedule changes are slow).
        /// Only applies to NPCs that are idle or in a schedule-driven state.
        /// Does NOT override combat/flee/dialogue states.
        /// </summary>
        public static void EvaluateSchedule(Connection conn, Connection.SpawnedNpc npc)
        {
            // Don't override high-priority states
            if (npc.CurrentState == Connection.NpcState.Fleeing ||
                npc.CurrentState == Connection.NpcState.Dead ||
                npc.CurrentState == Connection.NpcState.Talking ||
                npc.CurrentState == Connection.NpcState.Interacting ||
                npc.CurrentState == Connection.NpcState.Unconscious ||
                npc.CurrentState == Connection.NpcState.Stunned ||
                npc.CurrentState == Connection.NpcState.Examined ||
                npc.CurrentState == Connection.NpcState.Driving ||
                npc.CurrentState == Connection.NpcState.GettingInVehicle ||
                npc.CurrentState == Connection.NpcState.GettingOutVehicle)
            {
                return;
            }

            // Only re-evaluate every 30 seconds of real time
            var lastScheduleCheck = npc.Board?.Get<DateTime>("lastScheduleCheck", DateTime.MinValue) ?? DateTime.MinValue;
            if ((DateTime.UtcNow - lastScheduleCheck).TotalSeconds < 30)
                return;

            npc.Board?.Set("lastScheduleCheck", DateTime.UtcNow);

            var period = GetCurrentPeriod(conn);
            var suggestedState = GetSuggestedState(period, npc.IsStatic);

            // Only transition if the NPC is in a "schedule-eligible" state
            if (IsScheduleEligible(npc.CurrentState) && npc.CurrentState != suggestedState)
            {
                npc.PreviousState = npc.CurrentState;
                npc.CurrentState = suggestedState;
                npc.StateEnteredAt = DateTime.UtcNow;
            }
        }

        /// <summary>
        /// Check if a state can be overridden by the schedule system.
        /// Active behaviors (patrol, wander) can be overridden; combat/critical states cannot.
        /// </summary>
        static bool IsScheduleEligible(Connection.NpcState state)
        {
            return state switch
            {
                Connection.NpcState.Idle => true,
                Connection.NpcState.PatrolWalking => true,
                Connection.NpcState.Wandering => true,
                Connection.NpcState.Working => true,
                Connection.NpcState.Eating => true,
                Connection.NpcState.Sleeping => true,
                Connection.NpcState.Shopping => true,
                Connection.NpcState.Dancing => true,
                Connection.NpcState.Sitting => true,
                Connection.NpcState.Celebrating => true,
                _ => false, // Fleeing, Dead, Talking, etc. are not eligible
            };
        }
    }
}
