using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using System;
using System.Collections.Generic;
using System.Linq;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Game
{
    /// <summary>
    /// Vehicle Sync Manager — server-side vehicle state tracking and synchronization.
    ///
    /// Mirrors the client's VehicleNetManager + VehicleSyncTree architecture:
    /// - Tracks per-vehicle state (position, velocity, angular velocity, steering, controls)
    /// - Periodic full-state SyncVehicleMove push (every 3s for all active vehicles)
    /// - Seat assignment tracking (which player/NPC is in which seat)
    /// - Vehicle sender tracking (who controls each vehicle)
    /// - Enhanced SyncVehicleMove with full sync tree data
    ///
    /// Integration points:
    /// - GameTickService calls Tick() every 2s
    /// - VehicleDrivingAI uses SendVehicleMove() instead of SyncDebugAgentPosition
    /// - AskVehicleMove handler delegates to OnVehicleMove()
    /// </summary>
    public static class VehicleSyncManager
    {
        // ======================== VEHICLE SYNC STATE ========================

        /// <summary>
        /// Full vehicle state tracked by the server. Mirrors the client's
        /// VehicleSyncTree data nodes (position, orientation, velocity,
        /// angular velocity, steering, controls).
        /// </summary>
        public class VehicleSyncState
        {
            // Identity
            public ulong EntityId;
            public uint ConfigId;
            public ulong ControllerPid;       // who is driving (0 = nobody/traffic AI)

            // Position & orientation (SectorPositionDataNode + EntityOrientationDataNode)
            public float PosX, PosY, PosZ;
            public float Facing;              // degrees

            // Velocity (PhysicalVelocityDataNode)
            public float VelX, VelY, VelZ;

            // Angular velocity (PhysicalAngVelocityDataNode + VehicleAngVelocityDataNode)
            public float AngVelX, AngVelY, AngVelZ;
            public bool IsSuperDummyAngVel;

            // Steering (VehicleSteeringDataNode)
            public float SteeringAngle;       // radians, -max to +max

            // Controls (VehicleControlDataNode)
            public float Throttle;            // 0..1
            public float BrakeInput;          // 0..1
            public float HandbrakeInput;      // 0..1
            public bool Reverse;

            // Seat assignments (tracks who is in each seat)
            public Dictionary<int, ulong> SeatOccupants = new(); // seatIndex -> unitId (Pid or NpcId)

            // Metadata
            public bool IsTrafficVehicle;     // true = AI-driven traffic vehicle
            public long LastMoveTime;         // TickCount64 of last position update
            public float LastKnownSpeed;      // cached speed magnitude
        }

        // Per-connection vehicle states. Key = EntityId.
        static readonly Dictionary<ulong, Dictionary<ulong, VehicleSyncState>> _connVehicles = new();

        // Sync intervals
        const int FullSyncIntervalMs = 3000;       // push full vehicle state every 3s
        const int TrafficSyncIntervalMs = 2000;     // traffic vehicle sync (matches tick rate)
        const int StaleVehicleTimeoutMs = 30000;    // remove vehicles with no updates for 30s

        // ======================== PUBLIC API ========================

        /// <summary>
        /// Register a newly spawned vehicle for sync tracking.
        /// Called from SpawnVehicle() after SyncSpawnVehicle is sent.
        /// </summary>
        public static void RegisterVehicle(Connection conn, ulong entityId, uint configId,
            float posX, float posY, float posZ, float facing, ulong controllerPid = 0)
        {
            var vehicles = GetOrCreateVehicles(conn.Pid);
            vehicles[entityId] = new VehicleSyncState
            {
                EntityId = entityId,
                ConfigId = configId,
                ControllerPid = controllerPid,
                PosX = posX, PosY = posY, PosZ = posZ,
                Facing = facing,
                LastMoveTime = Environment.TickCount64,
            };
        }

        /// <summary>
        /// Unregister a destroyed vehicle from sync tracking.
        /// </summary>
        public static void UnregisterVehicle(Connection conn, ulong entityId)
        {
            if (_connVehicles.TryGetValue(conn.Pid, out var vehicles))
                vehicles.Remove(entityId);
        }

        /// <summary>
        /// Assign an occupant (player or NPC) to a vehicle seat.
        /// </summary>
        public static void AssignSeat(Connection conn, ulong vehicleId, int seatIndex, ulong occupantId)
        {
            if (_connVehicles.TryGetValue(conn.Pid, out var vehicles) &&
                vehicles.TryGetValue(vehicleId, out var state))
            {
                state.SeatOccupants[seatIndex] = occupantId;
            }
        }

        /// <summary>
        /// Remove an occupant from a vehicle seat.
        /// </summary>
        public static void RemoveSeat(Connection conn, ulong vehicleId, int seatIndex)
        {
            if (_connVehicles.TryGetValue(conn.Pid, out var vehicles) &&
                vehicles.TryGetValue(vehicleId, out var state))
            {
                state.SeatOccupants.Remove(seatIndex);
            }
        }

        /// <summary>
        /// Get the current sync state of a vehicle. Returns null if not tracked.
        /// </summary>
        public static VehicleSyncState GetVehicleState(Connection conn, ulong entityId)
        {
            if (_connVehicles.TryGetValue(conn.Pid, out var vehicles) &&
                vehicles.TryGetValue(entityId, out var state))
                return state;
            return null;
        }

        /// <summary>
        /// Get all tracked vehicles for a connection.
        /// </summary>
        public static IReadOnlyDictionary<ulong, VehicleSyncState> GetAllVehicles(Connection conn)
        {
            if (_connVehicles.TryGetValue(conn.Pid, out var vehicles))
                return vehicles;
            return new Dictionary<ulong, VehicleSyncState>();
        }

        // ======================== VEHICLE MOVE (enhanced) ========================

        /// <summary>
        /// Called when the server needs to send a vehicle move update.
        /// Builds a full RaidVehicleSyncData from the tracked state and sends SyncVehicleMove.
        /// Used by VehicleDrivingAI for traffic vehicles and by the server for periodic sync.
        /// </summary>
        public static void SendVehicleMove(Connection conn, VehicleSyncState state)
        {
            // Build enhanced sync data with full sync tree fields
            var syncData = new RaidVehicleSyncData
            {
                Id = state.EntityId,
                Position = new UXVector3 { X = state.PosX, Y = state.PosY, Z = state.PosZ },
                facingDirection = state.Facing,
                Velocity = new UXVector3 { X = state.VelX, Y = state.VelY, Z = state.VelZ },
                AngularVelocity = new UXVector3 { X = state.AngVelX, Y = state.AngVelY, Z = state.AngVelZ },
                SteeringAngle = state.SteeringAngle,
                Throttle = state.Throttle,
                BrakeInput = state.BrakeInput,
                HandbrakeInput = state.HandbrakeInput,
                Reverse = state.Reverse,
                IsSuperDummyAngVel = state.IsSuperDummyAngVel,
                Bits = Array.Empty<byte>(),
            };

            SendNotify(conn, MethodId.SyncVehicleMove, syncData);
        }

        /// <summary>
        /// Called when a traffic vehicle (VehicleDrivingAI) updates its position.
        /// Computes derived fields (velocity, steering) from position deltas.
        /// </summary>
        public static void UpdateTrafficVehicle(Connection conn, ulong entityId,
            float posX, float posY, float posZ, float facing, float speed)
        {
            if (!_connVehicles.TryGetValue(conn.Pid, out var vehicles)) return;
            if (!vehicles.TryGetValue(entityId, out var state)) return;

            // Compute velocity from facing direction and speed
            float facingRad = facing * MathF.PI / 180f;
            state.VelX = MathF.Sin(facingRad) * speed;
            state.VelY = 0;
            state.VelZ = MathF.Cos(facingRad) * speed;

            // Compute steering from facing change
            float facingDelta = NormalizeAngle(facing - state.Facing);
            state.SteeringAngle = MathF.Max(-0.5f, MathF.Min(0.5f, facingDelta * 0.1f));

            // Angular velocity (yaw rate from steering)
            state.AngVelY = facingDelta * 0.5f;

            // Throttle/brake from speed
            if (speed > 0.5f)
            {
                state.Throttle = MathF.Min(1f, speed / 20f);
                state.BrakeInput = 0;
            }
            else
            {
                state.Throttle = 0;
                state.BrakeInput = speed < 0.1f ? 0.5f : 0;
            }

            // Update position
            state.PosX = posX;
            state.PosY = posY;
            state.PosZ = posZ;
            state.Facing = facing;
            state.LastKnownSpeed = speed;
            state.LastMoveTime = Environment.TickCount64;

            // Send enhanced move update
            SendVehicleMove(conn, state);
        }

        /// <summary>
        /// Called when the client sends AskVehicleMove.
        /// Updates tracked state from the client's data and echoes back.
        /// </summary>
        public static void OnVehicleMove(Connection conn, RaidVehicleSyncData args)
        {
            if (!_connVehicles.TryGetValue(conn.Pid, out var vehicles)) return;
            if (!vehicles.TryGetValue(args.Id, out var state)) return;

            // Update tracked state from client data
            if (args.Position != null)
            {
                state.PosX = args.Position.X;
                state.PosY = args.Position.Y;
                state.PosZ = args.Position.Z;
            }
            state.Facing = args.facingDirection;

            if (args.Velocity != null)
            {
                state.VelX = args.Velocity.X;
                state.VelY = args.Velocity.Y;
                state.VelZ = args.Velocity.Z;
                state.LastKnownSpeed = MathF.Sqrt(
                    args.Velocity.X * args.Velocity.X +
                    args.Velocity.Y * args.Velocity.Y +
                    args.Velocity.Z * args.Velocity.Z);
            }

            if (args.AngularVelocity != null)
            {
                state.AngVelX = args.AngularVelocity.X;
                state.AngVelY = args.AngularVelocity.Y;
                state.AngVelZ = args.AngularVelocity.Z;
            }

            state.SteeringAngle = args.SteeringAngle;
            state.Throttle = args.Throttle;
            state.BrakeInput = args.BrakeInput;
            state.HandbrakeInput = args.HandbrakeInput;
            state.Reverse = args.Reverse;
            state.IsSuperDummyAngVel = args.IsSuperDummyAngVel;
            state.LastMoveTime = Environment.TickCount64;
        }

        /// <summary>
        /// Set the controller (driver) of a vehicle.
        /// Called during enter/exit sequences.
        /// </summary>
        public static void SetController(Connection conn, ulong vehicleId, ulong controllerPid)
        {
            if (_connVehicles.TryGetValue(conn.Pid, out var vehicles) &&
                vehicles.TryGetValue(vehicleId, out var state))
            {
                state.ControllerPid = controllerPid;
            }
        }

        // ======================== TICK (called by GameTickService) ========================

        public static void Tick(Connection conn)
        {
            if (!_connVehicles.TryGetValue(conn.Pid, out var vehicles)) return;
            if (vehicles.Count == 0) return;

            long now = Environment.TickCount64;

            // 1. Periodic full-state sync for player-driven vehicles
            //    (Traffic vehicles get individual updates from VehicleDrivingAI)
            if (conn.LastVehicleFullSyncTime == 0 ||
                now - conn.LastVehicleFullSyncTime > FullSyncIntervalMs)
            {
                conn.LastVehicleFullSyncTime = now;
                PushFullSync(conn, vehicles);
            }

            // 2. Clean up stale vehicles (no updates for 30s, not traffic vehicles)
            var staleIds = vehicles
                .Where(kvp => !kvp.Value.IsTrafficVehicle &&
                              now - kvp.Value.LastMoveTime > StaleVehicleTimeoutMs)
                .Select(kvp => kvp.Key)
                .ToList();

            foreach (var id in staleIds)
                vehicles.Remove(id);
        }

        /// <summary>
        /// Push full vehicle state for all non-traffic vehicles.
        /// This ensures the client has up-to-date state even if individual
        /// move packets were lost.
        /// </summary>
        static void PushFullSync(Connection conn, Dictionary<ulong, VehicleSyncState> vehicles)
        {
            foreach (var state in vehicles.Values)
            {
                // Only sync player-driven vehicles in full sync
                // (traffic vehicles get their own updates from VehicleDrivingAI)
                if (state.IsTrafficVehicle) continue;
                if (state.ControllerPid == 0) continue;

                SendVehicleMove(conn, state);
            }
        }

        /// <summary>
        /// Clean up all vehicle states for a connection (on disconnect).
        /// </summary>
        public static void CleanupConnection(Connection conn)
        {
            _connVehicles.Remove(conn.Pid);
        }

        // ======================== HELPERS ========================

        static Dictionary<ulong, VehicleSyncState> GetOrCreateVehicles(ulong pid)
        {
            if (!_connVehicles.TryGetValue(pid, out var vehicles))
            {
                vehicles = new Dictionary<ulong, VehicleSyncState>();
                _connVehicles[pid] = vehicles;
            }
            return vehicles;
        }

        /// <summary>
        /// Normalize angle to [-180, 180] range.
        /// </summary>
        static float NormalizeAngle(float angle)
        {
            while (angle > 180f) angle -= 360f;
            while (angle < -180f) angle += 360f;
            return angle;
        }

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
    }
}
