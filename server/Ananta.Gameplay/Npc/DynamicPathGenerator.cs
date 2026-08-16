using AnantaTestGameServer.Methods.Return;
using System;
using System.Collections.Generic;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// Dynamic path generator for NPCs. Creates realistic walking paths
    /// around the player's position, avoiding obstacles and other NPCs.
    /// Paths are generated procedurally — no hardcoded routes needed.
    /// </summary>
    public static class DynamicPathGenerator
    {
        private static readonly Random Rng = new Random(99887);

        // ================================================================
        // CONFIGURATION
        // ================================================================

        /// <summary>Minimum distance an NPC walks per path segment (units).</summary>
        public const float MinSegmentLength = 5f;

        /// <summary>Maximum distance an NPC walks per path segment (units).</summary>
        public const float MaxSegmentLength = 25f;

        /// <summary>How far NPCs can wander from their spawn/origin point.</summary>
        public const float MaxWanderRadius = 60f;

        /// <summary>Minimum distance to keep from obstacles (destructibles, etc).</summary>
        public const float ObstacleAvoidRadius = 3f;

        /// <summary>How many waypoints to generate per path.</summary>
        public const int WaypointsPerPath = 4;

        /// <summary>
        /// Predefined "road" directions in the game world.
        /// NPCs prefer walking along these axes (simulating sidewalks/roads).
        /// Angles in degrees from north (0=+Z, 90=+X, 180=-Z, 270=-X).
        /// </summary>
        static readonly float[] RoadAngles = { 0f, 45f, 90f, 135f, 180f, 225f, 270f, 315f };

        // ================================================================
        // PATH TYPES
        // ================================================================

        public enum PathType
        {
            /// <summary>Short random walk around current position, returns to start.</summary>
            WanderLoop,
            /// <summary>Straight-ish walk in a general direction.</summary>
            DirectionalWalk,
            /// <summary>Circular patrol around a center point.</summary>
            CirclePatrol,
            /// <summary>Figure-8 or oval patrol pattern.</summary>
            OvalPatrol,
            /// <summary>Flee from a danger point (long segments, away from source).</summary>
            FleeFromPoint,
        }

        // ================================================================
        // MAIN GENERATION METHOD
        // ================================================================

        /// <summary>
        /// Generate a dynamic path for an NPC starting at (startX, startZ).
        /// Returns a list of waypoints the NPC should follow.
        /// </summary>
        public static List<ClientZoneGraphPathPoint> GeneratePath(
            float startX, float startZ,
            float originX, float originZ,
            PathType type,
            float? dangerX = null, float? dangerZ = null)
        {
            switch (type)
            {
                case PathType.WanderLoop:
                    return GenerateWanderLoop(startX, startZ, originX, originZ);
                case PathType.DirectionalWalk:
                    return GenerateDirectionalWalk(startX, startZ, originX, originZ);
                case PathType.CirclePatrol:
                    return GenerateCirclePatrol(startX, startZ);
                case PathType.OvalPatrol:
                    return GenerateOvalPatrol(startX, startZ);
                case PathType.FleeFromPoint:
                    return GenerateFleePath(startX, startZ, dangerX ?? originX, dangerZ ?? originZ);
                default:
                    return GenerateWanderLoop(startX, startZ, originX, originZ);
            }
        }

        /// <summary>
        /// Pick a random path type for crowd NPC variety.
        /// Weighted towards WanderLoop and DirectionalWalk.
        /// </summary>
        public static PathType PickRandomPathType()
        {
            double roll = Rng.NextDouble();
            if (roll < 0.40) return PathType.WanderLoop;
            if (roll < 0.70) return PathType.DirectionalWalk;
            if (roll < 0.85) return PathType.CirclePatrol;
            return PathType.OvalPatrol;
        }

        // ================================================================
        // WANDER LOOP — Random walk that returns to start
        // ================================================================
        static List<ClientZoneGraphPathPoint> GenerateWanderLoop(
            float startX, float startZ, float originX, float originZ)
        {
            var points = new List<ClientZoneGraphPathPoint>();
            float cx = startX, cz = startZ;

            for (int i = 0; i < WaypointsPerPath; i++)
            {
                // Pick a road-aligned direction with some randomness
                float angle = RoadAngles[Rng.Next(RoadAngles.Length)] + (float)(Rng.NextDouble() * 30.0 - 15.0);
                float dist = MinSegmentLength + (float)(Rng.NextDouble() * (MaxSegmentLength - MinSegmentLength));

                float rad = angle * MathF.PI / 180f;
                float nx = cx + MathF.Sin(rad) * dist;
                float nz = cz + MathF.Cos(rad) * dist;

                // Clamp to wander radius from origin
                float dxO = nx - originX, dzO = nz - originZ;
                float distFromOrigin = MathF.Sqrt(dxO * dxO + dzO * dzO);
                if (distFromOrigin > MaxWanderRadius)
                {
                    // Redirect towards origin
                    nx = originX + dxO / distFromOrigin * MaxWanderRadius;
                    nz = originZ + dzO / distFromOrigin * MaxWanderRadius;
                }

                // Avoid obstacles
                var avoided = AvoidObstacles(cx, cz, nx, nz);
                nx = avoided.x;
                nz = avoided.z;

                points.Add(MakeWaypoint(nx, 0, nz));
                cx = nx;
                cz = nz;
            }

            // Close the loop — return to start
            points.Add(MakeWaypoint(startX, 0, startZ));
            return points;
        }

        // ================================================================
        // DIRECTIONAL WALK — Walk in a general direction
        // ================================================================
        static List<ClientZoneGraphPathPoint> GenerateDirectionalWalk(
            float startX, float startZ, float originX, float originZ)
        {
            var points = new List<ClientZoneGraphPathPoint>();
            float cx = startX, cz = startZ;

            // Pick a base direction
            float baseAngle = RoadAngles[Rng.Next(RoadAngles.Length)] + (float)(Rng.NextDouble() * 20.0 - 10.0);

            for (int i = 0; i < WaypointsPerPath; i++)
            {
                // Small deviation from base direction each step
                float angle = baseAngle + (float)(Rng.NextDouble() * 20.0 - 10.0);
                float dist = MinSegmentLength + (float)(Rng.NextDouble() * 15.0);

                float rad = angle * MathF.PI / 180f;
                float nx = cx + MathF.Sin(rad) * dist;
                float nz = cz + MathF.Cos(rad) * dist;

                // Clamp to wander radius
                float dxO = nx - originX, dzO = nz - originZ;
                float distFromOrigin = MathF.Sqrt(dxO * dxO + dzO * dzO);
                if (distFromOrigin > MaxWanderRadius * 1.5f)
                {
                    // Redirect back
                    float returnAngle = MathF.Atan2(originX - cx, originZ - cz) * 180f / MathF.PI;
                    float retRad = returnAngle * MathF.PI / 180f;
                    nx = cx + MathF.Sin(retRad) * dist;
                    nz = cz + MathF.Cos(retRad) * dist;
                }

                var avoided = AvoidObstacles(cx, cz, nx, nz);
                nx = avoided.x;
                nz = avoided.z;

                points.Add(MakeWaypoint(nx, 0, nz));
                cx = nx;
                cz = nz;
            }

            return points;
        }

        // ================================================================
        // CIRCLE PATROL — Walk in a rough circle around a center point
        // ================================================================
        static List<ClientZoneGraphPathPoint> GenerateCirclePatrol(float centerX, float centerZ)
        {
            var points = new List<ClientZoneGraphPathPoint>();
            float radius = 8f + (float)(Rng.NextDouble() * 15.0);
            float startAngle = (float)(Rng.NextDouble() * 360.0);
            int steps = 6 + Rng.Next(3); // 6-8 points around the circle

            for (int i = 0; i <= steps; i++)
            {
                float angle = startAngle + (360f / steps) * i;
                // Add some jitter to make it less perfect
                float jitter = (float)(Rng.NextDouble() * 3.0 - 1.5);
                float r = radius + jitter;

                float rad = angle * MathF.PI / 180f;
                float nx = centerX + MathF.Sin(rad) * r;
                float nz = centerZ + MathF.Cos(rad) * r;

                var avoided = AvoidObstacles(centerX, centerZ, nx, nz);
                nx = avoided.x;
                nz = avoided.z;

                points.Add(MakeWaypoint(nx, 0, nz));
            }

            return points;
        }

        // ================================================================
        // OVAL PATROL — Figure-8 / elongated loop
        // ================================================================
        static List<ClientZoneGraphPathPoint> GenerateOvalPatrol(float centerX, float centerZ)
        {
            var points = new List<ClientZoneGraphPathPoint>();
            float radiusX = 10f + (float)(Rng.NextDouble() * 12.0);
            float radiusZ = 5f + (float)(Rng.NextDouble() * 8.0);
            float rotation = (float)(Rng.NextDouble() * 360.0); // random oval orientation
            float rotRad = rotation * MathF.PI / 180f;
            int steps = 8;

            for (int i = 0; i <= steps; i++)
            {
                float angle = (360f / steps) * i * MathF.PI / 180f;
                float lx = MathF.Cos(angle) * radiusX;
                float lz = MathF.Sin(angle) * radiusZ;

                // Rotate the oval
                float nx = centerX + lx * MathF.Cos(rotRad) - lz * MathF.Sin(rotRad);
                float nz = centerZ + lx * MathF.Sin(rotRad) + lz * MathF.Cos(rotRad);

                points.Add(MakeWaypoint(nx, 0, nz));
            }

            return points;
        }

        // ================================================================
        // FLEE PATH — Run away from a danger point
        // ================================================================
        static List<ClientZoneGraphPathPoint> GenerateFleePath(
            float startX, float startZ, float dangerX, float dangerZ)
        {
            var points = new List<ClientZoneGraphPathPoint>();
            float cx = startX, cz = startZ;

            // Direction away from danger
            float dx = cx - dangerX;
            float dz = cz - dangerZ;
            float len = MathF.Sqrt(dx * dx + dz * dz);
            if (len < 0.1f) { dx = 1; dz = 0; len = 1; }
            float baseAngle = MathF.Atan2(dx, dz) * 180f / MathF.PI;

            // Generate 3 flee waypoints, each further away
            for (int i = 0; i < 3; i++)
            {
                float angle = baseAngle + (float)(Rng.NextDouble() * 40.0 - 20.0);
                float dist = 12f + (float)(Rng.NextDouble() * 15.0); // long flee steps

                float rad = angle * MathF.PI / 180f;
                float nx = cx + MathF.Sin(rad) * dist;
                float nz = cz + MathF.Cos(rad) * dist;

                points.Add(MakeWaypoint(nx, 0, nz));
                cx = nx;
                cz = nz;
            }

            return points;
        }

        // ================================================================
        // OBSTACLE AVOIDANCE
        // ================================================================

        /// <summary>
        /// Check if a path segment (fromX,fromZ)→(toX,toZ) passes near any
        /// destructible objects. If so, nudge the endpoint away.
        /// </summary>
        static (float x, float z) AvoidObstacles(float fromX, float fromZ, float toX, float toZ)
        {
            float nx = toX, nz = toZ;

            foreach (var obj in DestructibleObjectManager.AllObjects)
            {
                if (obj.State == 3) continue; // destroyed, skip

                float ox = obj.Position.X, oz = obj.Position.Z;

                // Distance from obstacle to the target point
                float dx = nx - ox, dz = nz - oz;
                float dist = MathF.Sqrt(dx * dx + dz * dz);

                if (dist < ObstacleAvoidRadius)
                {
                    // Push the waypoint away from the obstacle
                    if (dist < 0.1f) { dx = 1; dz = 0; dist = 1; }
                    float pushDist = ObstacleAvoidRadius - dist + 1f;
                    nx += (dx / dist) * pushDist;
                    nz += (dz / dist) * pushDist;
                }
            }

            return (nx, nz);
        }

        /// <summary>
        /// Check if a position is inside any "no-go" zone.
        /// Returns true if the position should be avoided.
        /// </summary>
        public static bool IsInNoGoZone(float x, float z)
        {
            // For now, just check if too close to any destructible
            foreach (var obj in DestructibleObjectManager.AllObjects)
            {
                if (obj.State == 3) continue;
                float dx = x - obj.Position.X, dz = z - obj.Position.Z;
                if (dx * dx + dz * dz < ObstacleAvoidRadius * ObstacleAvoidRadius)
                    return true;
            }
            return false;
        }

        // ================================================================
        // HELPER
        // ================================================================

        static ClientZoneGraphPathPoint MakeWaypoint(float x, float y, float z)
        {
            return new ClientZoneGraphPathPoint()
            {
                Position = new UXVector3() { X = x, Y = y, Z = z },
                Facing = (byte)Rng.Next(0, 255)
            };
        }
    }
}
