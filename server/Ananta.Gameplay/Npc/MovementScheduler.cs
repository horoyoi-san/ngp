using AnantaTestGameServer.BehaviorTreeEngine;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using System;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// Movement Scheduler — FSM for NPC locomotion modes.
    /// Mirrors DLL's MovementStateMachine (Humanoid/SimpleAvatar states).
    ///
    /// States: Idle → Walk → Run → Flee → Turn → Idle
    /// Transitions send SyncChangeNpcMoveDesiredSpeed to client.
    /// The client handles the actual animation blending.
    /// </summary>
    public static class MovementScheduler
    {
        // Speed values per movement mode (m/s)
        public const float IdleSpeed = 0f;
        public const float WalkSpeed = 1.5f;
        public const float RunSpeed = 3.0f;
        public const float FleeSpeed = 4.0f;
        public const float TurnSpeed = 0f; // no displacement during turn

        /// <summary>
        /// Transition an NPC to a new movement mode.
        /// Sends speed change packet to client.
        /// </summary>
        public static void SetMovementMode(Connection conn, Connection.SpawnedNpc npc, Connection.MovementMode newMode)
        {
            if (npc.CurrentMovementMode == newMode) return;

            var oldMode = npc.CurrentMovementMode;
            npc.CurrentMovementMode = newMode;

            float newSpeed = GetSpeedForMode(newMode);

            // Send speed change to client
            if (newMode != Connection.MovementMode.Idle && newMode != Connection.MovementMode.Turn)
            {
                BTActions.SendChangeSpeed(conn, npc, newSpeed);
            }

            // Log significant transitions
            if (oldMode == Connection.MovementMode.Flee || newMode == Connection.MovementMode.Flee)
            {
                Console.WriteLine($"[Movement] NPC {npc.EntityId}: {oldMode} → {newMode} (speed={newSpeed})");
            }
        }

        /// <summary>
        /// Get the speed value for a movement mode.
        /// </summary>
        public static float GetSpeedForMode(Connection.MovementMode mode)
        {
            return mode switch
            {
                Connection.MovementMode.Idle => IdleSpeed,
                Connection.MovementMode.Walk => WalkSpeed,
                Connection.MovementMode.Run => RunSpeed,
                Connection.MovementMode.Flee => FleeSpeed,
                Connection.MovementMode.Turn => TurnSpeed,
                _ => WalkSpeed,
            };
        }

        /// <summary>
        /// Auto-determine the best movement mode based on NPC state.
        /// Called during BT evaluation to sync movement mode with behavior.
        /// </summary>
        public static void SyncMovementModeFromState(Connection conn, Connection.SpawnedNpc npc)
        {
            Connection.MovementMode targetMode;

            switch (npc.CurrentState)
            {
                case Connection.NpcState.Fleeing:
                    targetMode = Connection.MovementMode.Flee;
                    break;

                case Connection.NpcState.PatrolWalking:
                case Connection.NpcState.Wandering:
                case Connection.NpcState.GettingInVehicle:
                case Connection.NpcState.GettingOutVehicle:
                case Connection.NpcState.Interacting:
                case Connection.NpcState.Shopping:
                case Connection.NpcState.Working:
                case Connection.NpcState.Eating:
                    targetMode = Connection.MovementMode.Walk;
                    break;

                case Connection.NpcState.Idle:
                case Connection.NpcState.Dead:
                case Connection.NpcState.Sitting:
                case Connection.NpcState.Talking:
                case Connection.NpcState.Unconscious:
                case Connection.NpcState.Driving:
                case Connection.NpcState.Passenger:
                case Connection.NpcState.Dancing:
                case Connection.NpcState.Sleeping:
                case Connection.NpcState.Examined:
                case Connection.NpcState.Stunned:
                case Connection.NpcState.Celebrating:
                    targetMode = Connection.MovementMode.Idle;
                    break;

                default:
                    targetMode = Connection.MovementMode.Idle;
                    break;
            }

            SetMovementMode(conn, npc, targetMode);
        }

        /// <summary>
        /// Check if an NPC needs to turn before walking (facing vs movement direction).
        /// If the angle difference is large, insert a Turn phase.
        /// Returns true if NPC should turn before moving.
        /// </summary>
        public static bool NeedsTurn(Connection.SpawnedNpc npc, float targetX, float targetZ, float thresholdDegrees = 45f)
        {
            float dx = targetX - npc.PosX;
            float dz = targetZ - npc.PosZ;

            if (MathF.Sqrt(dx * dx + dz * dz) < 0.5f)
                return false; // too close, no need to turn

            // Calculate desired facing angle (degrees, 0=north/+Z, clockwise)
            float desiredFacing = MathF.Atan2(dx, dz) * 180f / MathF.PI;
            if (desiredFacing < 0) desiredFacing += 360f;

            // Current facing
            float currentFacing = npc.Facing;

            // Angle difference
            float diff = MathF.Abs(desiredFacing - currentFacing);
            if (diff > 180f) diff = 360f - diff;

            return diff > thresholdDegrees;
        }

        /// <summary>
        /// Update NPC facing towards a target position.
        /// </summary>
        public static void FaceTowards(Connection.SpawnedNpc npc, float targetX, float targetZ)
        {
            float dx = targetX - npc.PosX;
            float dz = targetZ - npc.PosZ;
            float angle = MathF.Atan2(dx, dz) * 180f / MathF.PI;
            if (angle < 0) angle += 360f;
            npc.Facing = angle;
        }
    }
}
