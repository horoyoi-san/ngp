using AnantaTestGameServer.Methods.Return;
using System;
using System.Collections.Generic;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// NPC-NPC Avoidance — simplified ORCA-style separation.
    ///
    /// Real ORCA uses DOTS/Burst with KD-trees for real-time collision avoidance.
    /// Our server-side version is simpler: when generating paths, check if
    /// waypoints are too close to other NPCs and nudge them away.
    ///
    /// This prevents NPCs from walking on top of each other and creates
    /// more natural-looking crowd movement.
    /// </summary>
    public static class NpcAvoidance
    {
        /// <summary>
        /// Minimum distance between NPCs. Waypoints closer than this
        /// to another NPC will be pushed away.
        /// </summary>
        public const float SeparationRadius = 2.5f;

        /// <summary>
        /// How strongly to push waypoints away from other NPCs (multiplier).
        /// </summary>
        public const float PushStrength = 1.5f;

        /// <summary>
        /// Maximum number of NPCs to check against (performance cap).
        /// </summary>
        private const int MaxNeighborsToCheck = 20;

        /// <summary>
        /// Apply NPC-NPC avoidance to a list of waypoints.
        /// Nudges each waypoint away from nearby NPCs.
        /// Called by DynamicPathGenerator after generating paths.
        /// </summary>
        public static void ApplyAvoidance(
            List<ClientZoneGraphPathPoint> waypoints,
            Connection.SpawnedNpc self,
            List<Connection.SpawnedNpc> allNpcs)
        {
            if (waypoints == null || waypoints.Count == 0 || allNpcs == null) return;

            // Collect neighbor positions (cap for performance)
            var neighbors = new List<(float x, float z)>(MaxNeighborsToCheck);
            int count = 0;

            foreach (var other in allNpcs)
            {
                if (other.EntityId == self.EntityId) continue;
                if (other.IsDestroyed) continue;
                if (other.CurrentState == Connection.NpcState.Dead) continue;

                // Quick distance check — only consider NPCs within a reasonable range
                float dx = other.PosX - self.PosX;
                float dz = other.PosZ - self.PosZ;
                if (dx * dx + dz * dz > 60f * 60f) continue; // >60m = ignore

                neighbors.Add((other.PosX, other.PosZ));
                if (++count >= MaxNeighborsToCheck) break;
            }

            if (neighbors.Count == 0) return;

            // Push each waypoint away from nearby NPCs
            for (int i = 0; i < waypoints.Count; i++)
            {
                var wp = waypoints[i];
                float wx = wp.Position.X;
                float wz = wp.Position.Z;

                foreach (var (nx, nz) in neighbors)
                {
                    float dx = wx - nx;
                    float dz = wz - nz;
                    float distSq = dx * dx + dz * dz;
                    float minDist = SeparationRadius;

                    if (distSq < minDist * minDist && distSq > 0.001f)
                    {
                        float dist = MathF.Sqrt(distSq);
                        float pushDist = (minDist - dist) * PushStrength;

                        // Normalize and push
                        wx += (dx / dist) * pushDist;
                        wz += (dz / dist) * pushDist;
                    }
                    else if (distSq <= 0.001f)
                    {
                        // Exactly overlapping — push in arbitrary direction
                        wx += SeparationRadius * PushStrength;
                    }
                }

                // Update waypoint if it was nudged
                if (wx != wp.Position.X || wz != wp.Position.Z)
                {
                    wp.Position.X = wx;
                    wp.Position.Z = wz;
                }
            }
        }

        /// <summary>
        /// Check if a position is too close to any other NPC.
        /// Returns true if the position should be avoided.
        /// </summary>
        public static bool IsTooCloseToOtherNpc(
            float x, float z,
            Connection.SpawnedNpc self,
            List<Connection.SpawnedNpc> allNpcs,
            float radius = 0)
        {
            if (radius <= 0) radius = SeparationRadius;
            float radiusSq = radius * radius;

            foreach (var other in allNpcs)
            {
                if (other.EntityId == self.EntityId) continue;
                if (other.IsDestroyed) continue;

                float dx = x - other.PosX;
                float dz = z - other.PosZ;
                if (dx * dx + dz * dz < radiusSq)
                    return true;
            }
            return false;
        }

        /// <summary>
        /// Calculate a repulsion vector from all nearby NPCs.
        /// Can be used to influence movement direction.
        /// Returns (pushX, pushZ) — direction to move away from crowd.
        /// </summary>
        public static (float pushX, float pushZ) CalculateRepulsion(
            Connection.SpawnedNpc self,
            List<Connection.SpawnedNpc> allNpcs,
            float influenceRadius = 5f)
        {
            float totalPushX = 0f;
            float totalPushZ = 0f;
            float influenceSq = influenceRadius * influenceRadius;

            foreach (var other in allNpcs)
            {
                if (other.EntityId == self.EntityId) continue;
                if (other.IsDestroyed) continue;

                float dx = self.PosX - other.PosX;
                float dz = self.PosZ - other.PosZ;
                float distSq = dx * dx + dz * dz;

                if (distSq < influenceSq && distSq > 0.001f)
                {
                    float dist = MathF.Sqrt(distSq);
                    // Inverse-distance weighting: closer NPCs push harder
                    float weight = 1f - (dist / influenceRadius);
                    totalPushX += (dx / dist) * weight;
                    totalPushZ += (dz / dist) * weight;
                }
            }

            return (totalPushX, totalPushZ);
        }
    }
}
