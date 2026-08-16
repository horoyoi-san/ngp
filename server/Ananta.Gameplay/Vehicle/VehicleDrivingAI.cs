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
    /// Vehicle Driving AI — traffic vehicles that actually drive.
    /// Mirrors DLL's Lx6\Drive\AI system (simplified server-side version).
    ///
    /// Features:
    /// - Lane following with waypoints
    /// - Driver personality (Aggressive/Cautious/Normal)
    /// - Speed variation per driver type
    /// - Intersection stop/go (basic traffic light awareness)
    /// - Server-side position tracking for vehicles
    /// - Vehicle-NPC driver binding (driver stays in seat)
    /// </summary>
    public static class VehicleDrivingAI
    {
        static readonly Random _rng = new Random();
        // ================================================================
        // DRIVER PERSONALITY (mirrors DLL DriverPersonality.cs)
        // ================================================================
        public enum DriverPersonality : byte
        {
            Normal = 0,     // Follows rules, medium speed
            Aggressive = 1, // Speeds, honks, risky lane changes
            Cautious = 2    // Slow, stops early, avoids risks
        }

        /// <summary>
        /// Speed ranges per personality (m/s). ~3.6 km/h per m/s.
        /// Normal: 30-50 km/h, Aggressive: 50-80 km/h, Cautious: 20-35 km/h
        /// </summary>
        public static (float min, float max) GetSpeedRange(DriverPersonality personality)
        {
            return personality switch
            {
                DriverPersonality.Aggressive => (14f, 22f),    // 50-80 km/h
                DriverPersonality.Cautious => (5.5f, 10f),    // 20-35 km/h
                _ => (8f, 14f),                                // 30-50 km/h
            };
        }

        // ================================================================
        // TRAFFIC VEHICLE STATE
        // ================================================================
        public class TrafficVehicle
        {
            public ulong EntityId;
            public uint VehicleConfigId;
            public ulong DriverNpcEntityId;     // NPC driving this vehicle
            public float PosX, PosY, PosZ;
            public float Facing;
            public float CurrentSpeed;           // current speed in m/s
            public float TargetSpeed;            // desired speed
            public DriverPersonality Personality;

            // Route following
            public List<ClientZoneGraphPathPoint> Route;  // driving route waypoints
            public int CurrentRouteIndex = 0;
            public bool IsLooping = true;        // loop the route?

            // State
            public bool IsStopped = false;
            public DateTime LastStateChange = DateTime.UtcNow;
            public bool IsDestroyed = false;

            // Intersection behavior
            public bool WaitingAtIntersection = false;
            public float IntersectionWaitTime = 0f;
        }

        // ================================================================
        // TRAFFIC VEHICLE REGISTRY (per-connection)
        // ================================================================

        /// <summary>
        /// Initialize traffic vehicles from the WorldPopulationBuilder data.
        /// Called when vehicles are spawned. Registers with VehicleSyncManager.
        /// </summary>
        public static void RegisterTrafficVehicle(Connection conn, TrafficVehicle vehicle)
        {
            conn.TrafficVehicles.Add(vehicle);
            if (conn.TrafficVehicles.Count > 100) // cap
            {
                conn.TrafficVehicles.RemoveAt(0);
            }

            // Register with VehicleSyncManager for proper sync tree tracking
            VehicleSyncManager.RegisterVehicle(conn, vehicle.EntityId, vehicle.VehicleConfigId,
                vehicle.PosX, vehicle.PosY, vehicle.PosZ, vehicle.Facing, 0);
            var state = VehicleSyncManager.GetVehicleState(conn, vehicle.EntityId);
            if (state != null)
            {
                state.IsTrafficVehicle = true;
                state.LastKnownSpeed = vehicle.CurrentSpeed;
            }
        }

        // ================================================================
        // MAIN TICK — called from GameTickService
        // ================================================================

        /// <summary>
        /// Update all traffic vehicles for a connection.
        /// Moves vehicles along routes, handles speed/intersections.
        /// </summary>
        public static void Tick(Connection conn)
        {
            if (conn.TrafficVehicles == null || conn.TrafficVehicles.Count == 0) return;

            var now = DateTime.UtcNow;

            foreach (var vehicle in conn.TrafficVehicles)
            {
                if (vehicle.IsDestroyed) continue;
                if (vehicle.Route == null || vehicle.Route.Count < 2) continue;

                // Handle intersection wait
                if (vehicle.WaitingAtIntersection)
                {
                    vehicle.IntersectionWaitTime += 2f; // ~2s per tick
                    if (vehicle.IntersectionWaitTime >= 4f) // wait 4s then go
                    {
                        vehicle.WaitingAtIntersection = false;
                        vehicle.IntersectionWaitTime = 0;
                        vehicle.IsStopped = false;
                        ResumeVehicle(conn, vehicle);
                    }
                    continue;
                }

                // Calculate movement this tick (~2s)
                float moveDistance = vehicle.CurrentSpeed * 2f;

                // Advance along route
                if (vehicle.CurrentRouteIndex < vehicle.Route.Count)
                {
                    var target = vehicle.Route[vehicle.CurrentRouteIndex];
                    float dx = target.Position.X - vehicle.PosX;
                    float dz = target.Position.Z - vehicle.PosZ;
                    float dist = MathF.Sqrt(dx * dx + dz * dz);

                    if (dist <= moveDistance)
                    {
                        // Reached waypoint — advance to next
                        vehicle.PosX = target.Position.X;
                        vehicle.PosY = target.Position.Y;
                        vehicle.PosZ = target.Position.Z;
                        vehicle.Facing = target.Facing * 2.8f;
                        vehicle.CurrentRouteIndex++;

                        // Loop?
                        if (vehicle.CurrentRouteIndex >= vehicle.Route.Count)
                        {
                            if (vehicle.IsLooping)
                            {
                                vehicle.CurrentRouteIndex = 0;
                            }
                            else
                            {
                                StopVehicle(conn, vehicle);
                                continue;
                            }
                        }

                        // Random intersection stop (10% chance per waypoint for cautious, 5% normal, 0% aggressive)
                        float stopChance = vehicle.Personality switch
                        {
                            DriverPersonality.Cautious => 0.10f,
                            DriverPersonality.Aggressive => 0f,
                            _ => 0.05f
                        };

                        if (_rng.NextDouble() < stopChance)
                        {
                            vehicle.WaitingAtIntersection = true;
                            vehicle.IsStopped = true;
                            vehicle.LastStateChange = now;
                            StopVehicle(conn, vehicle);
                            continue;
                        }

                        // Send position update
                        SendVehiclePositionUpdate(conn, vehicle);

                        // Update driver NPC position too (stays in vehicle)
                        UpdateDriverPosition(conn, vehicle);
                    }
                    else
                    {
                        // Interpolate towards target
                        float ratio = moveDistance / dist;
                        vehicle.PosX += dx * ratio;
                        vehicle.PosZ += dz * ratio;
                        vehicle.Facing = MathF.Atan2(dx, dz) * 180f / MathF.PI;
                        if (vehicle.Facing < 0) vehicle.Facing += 360f;

                        SendVehiclePositionUpdate(conn, vehicle);
                        UpdateDriverPosition(conn, vehicle);
                    }
                }

                // Speed variation — gradually adjust towards target speed
                float speedRange = 1f;
                if (vehicle.CurrentSpeed < vehicle.TargetSpeed - speedRange)
                {
                    // Accelerate
                    float accel = vehicle.Personality == DriverPersonality.Aggressive ? 3f : 1.5f;
                    vehicle.CurrentSpeed = MathF.Min(vehicle.CurrentSpeed + accel, vehicle.TargetSpeed);
                }
                else if (vehicle.CurrentSpeed > vehicle.TargetSpeed + speedRange)
                {
                    // Decelerate
                    float decel = vehicle.Personality == DriverPersonality.Cautious ? 3f : 1.5f;
                    vehicle.CurrentSpeed = MathF.Max(vehicle.CurrentSpeed - decel, vehicle.TargetSpeed);
                }

                // Random speed variation (change target speed occasionally)
                if ((now - vehicle.LastStateChange).TotalSeconds > 10)
                {
                    var (minSpeed, maxSpeed) = GetSpeedRange(vehicle.Personality);
                    vehicle.TargetSpeed = minSpeed + (float)(_rng.NextDouble() * (maxSpeed - minSpeed));
                    vehicle.LastStateChange = now;
                }
            }
        }

        // ================================================================
        // VEHICLE CONTROL
        // ================================================================

        static void StopVehicle(Connection conn, TrafficVehicle vehicle)
        {
            vehicle.CurrentSpeed = 0;
            // Send vehicle status update (stopped)
            var data = new VehicleStatusArgs()
            {
                instanceId = vehicle.EntityId,
                status = 1  // stopped
            };
            SendNotify(conn, MethodId.SyncAetherAISetVehicleStatus, data);
        }

        static void ResumeVehicle(Connection conn, TrafficVehicle vehicle)
        {
            var (minSpeed, maxSpeed) = GetSpeedRange(vehicle.Personality);
            vehicle.CurrentSpeed = minSpeed;
            vehicle.TargetSpeed = minSpeed + (maxSpeed - minSpeed) * 0.5f;

            var data = new VehicleStatusArgs()
            {
                instanceId = vehicle.EntityId,
                status = 0  // moving
            };
            SendNotify(conn, MethodId.SyncAetherAISetVehicleStatus, data);
        }

        static void SendVehiclePositionUpdate(Connection conn, TrafficVehicle vehicle)
        {
            // Use VehicleSyncManager for proper SyncVehicleMove with full sync tree data
            // (position, velocity, angular velocity, steering, controls)
            VehicleSyncManager.UpdateTrafficVehicle(conn, vehicle.EntityId,
                vehicle.PosX, vehicle.PosY, vehicle.PosZ, vehicle.Facing, vehicle.CurrentSpeed);
        }

        static void UpdateDriverPosition(Connection conn, TrafficVehicle vehicle)
        {
            if (vehicle.DriverNpcEntityId == 0) return;

            // Keep driver NPC at the vehicle's position
            var driverNpc = conn.GetNpcById(vehicle.DriverNpcEntityId);
            if (driverNpc != null)
            {
                driverNpc.PosX = vehicle.PosX;
                driverNpc.PosY = vehicle.PosY;
                driverNpc.PosZ = vehicle.PosZ;
                driverNpc.Facing = vehicle.Facing;
                driverNpc.CurrentState = Connection.NpcState.Driving;
                driverNpc.BoundVehicleEntityId = vehicle.EntityId;

                // Send driver position update
                var data = new ClientNpcMoveData()
                {
                    InstanceId = driverNpc.EntityId,
                    Position = new UXVector3() { X = driverNpc.PosX, Y = driverNpc.PosY, Z = driverNpc.PosZ },
                    Facing = driverNpc.Facing
                };
                SendNotify(conn, MethodId.SyncDebugCrowdPosition, data);
            }
        }

        // ================================================================
        // ROUTE GENERATION
        // ================================================================

        /// <summary>
        /// Generate a driving route for a traffic vehicle.
        /// Creates a loop of waypoints around the vehicle's spawn position.
        /// </summary>
        public static List<ClientZoneGraphPathPoint> GenerateDrivingRoute(
            float startX, float startZ, float radius = 80f, int pointCount = 8)
        {
            var rng = new Random(startX.GetHashCode() ^ startZ.GetHashCode());
            var points = new List<ClientZoneGraphPathPoint>();

            for (int i = 0; i <= pointCount; i++)
            {
                float angle = (360f / pointCount) * i * MathF.PI / 180f;
                float r = radius + (float)(rng.NextDouble() * 30.0 - 15.0); // ±15m jitter
                float nx = startX + MathF.Cos(angle) * r;
                float nz = startZ + MathF.Sin(angle) * r;

                points.Add(new ClientZoneGraphPathPoint()
                {
                    Position = new UXVector3() { X = nx, Y = 0, Z = nz },
                    Facing = (byte)(angle * 255f / (2f * MathF.PI))
                });
            }

            return points;
        }

        // ================================================================
        // PACKET HELPERS
        // ================================================================

        static void SendNotify(Connection conn, MethodId methodId, SerializedClass args)
        {
            var msg = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)methodId,
            };
            msg.SetArgs(methodId, args);
            conn.SendPacket(msg);
        }

        class VehicleStatusArgs : SerializedClass
        {
            public ulong instanceId;
            public byte status;
            public VehicleStatusArgs() { onlyFields = true; }
        }
    }
}
