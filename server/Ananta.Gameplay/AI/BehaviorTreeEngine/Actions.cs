using AnantaTestGameServer.Game;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using System;
using System.Collections.Generic;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.BehaviorTreeEngine
{
    // ================================================================
    // ACTION: PATROL — generate a dynamic path and make NPC walk it
    // Sends SyncAetherAICrowdFollowPath to client.
    // ================================================================
    public class ActionPatrol : BTNode
    {
        public ActionPatrol()
        {
            Name = "Patrol";
        }

        protected override void OnStart(BTContext ctx)
        {
            var npc = ctx.Npc;
            if (npc.IsStatic) return;

            var pathType = DynamicPathGenerator.PickRandomPathType();
            var path = DynamicPathGenerator.GeneratePath(
                npc.PosX, npc.PosZ,
                npc.OriginX, npc.OriginZ,
                pathType);

            if (path != null && path.Count >= 2)
            {
                // Apply NPC-NPC avoidance — nudge waypoints away from nearby NPCs
                NpcAvoidance.ApplyAvoidance(path, npc, ctx.Conn.GetLiveNpcs());

                npc.Waypoints = path;
                npc.CurrentWaypointIndex = 0;
                npc.CurrentState = Connection.NpcState.PatrolWalking;
                npc.StateEnteredAt = ctx.Now;

                // Set walk movement mode
                MovementScheduler.SetMovementMode(ctx.Conn, npc, Connection.MovementMode.Walk);

                SendCrowdFollowPath(ctx.Conn, npc);
            }
        }

        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            var npc = ctx.Npc;
            if (npc.IsStatic) return TaskStatus.Failure;

            // Advance waypoint if enough time passed
            if (ctx.TimeInState >= 3.0 && npc.Waypoints != null && npc.Waypoints.Count >= 2)
            {
                npc.CurrentWaypointIndex = (npc.CurrentWaypointIndex + 1) % npc.Waypoints.Count;
                var wp = npc.Waypoints[npc.CurrentWaypointIndex];
                npc.PosX = wp.Position.X;
                npc.PosY = wp.Position.Y;
                npc.PosZ = wp.Position.Z;
                npc.Facing = wp.Facing * 2.8f;
                npc.StateEnteredAt = ctx.Now;

                SendDebugCrowdPosition(ctx.Conn, npc);

                // Loop complete?
                if (npc.CurrentWaypointIndex == 0)
                {
                    return TaskStatus.Success; // let tree pick next behavior
                }

                SendCrowdFollowPath(ctx.Conn, npc);
            }

            return TaskStatus.Running;
        }

        // Packet senders (reuse from NpcBehaviorManager pattern)
        static void SendCrowdFollowPath(Connection conn, Connection.SpawnedNpc npc)
        {
            if (npc.Waypoints == null || npc.Waypoints.Count < 2) return;

            var pathPoints = new List<ClientZoneGraphPathPoint>();
            for (int i = npc.CurrentWaypointIndex; i < npc.Waypoints.Count; i++)
                pathPoints.Add(npc.Waypoints[i]);
            if (npc.CurrentWaypointIndex > 0)
                for (int i = 0; i <= npc.CurrentWaypointIndex; i++)
                    pathPoints.Add(npc.Waypoints[i]);

            var pathData = new ClientZoneGraphPath()
            {
                Id = npc.EntityId,
                TargetLocationReason = ZoneGraphTargetLocationReason.Wander,
                ActionId = 0,
                Points = pathPoints
            };
            BTActions.SendNotify(conn, MethodId.SyncAetherAICrowdFollowPath, pathData);
        }

        static void SendDebugCrowdPosition(Connection conn, Connection.SpawnedNpc npc)
        {
            var data = new ClientNpcMoveData()
            {
                InstanceId = npc.EntityId,
                Position = new UXVector3() { X = npc.PosX, Y = npc.PosY, Z = npc.PosZ },
                Facing = npc.Facing
            };
            BTActions.SendNotify(conn, MethodId.SyncDebugCrowdPosition, data);
        }
    }

    // ================================================================
    // ACTION: FLEE — generate flee path away from player, speed up
    // Sends SyncAetherAICrowdFollowPath + SyncChangeNpcMoveDesiredSpeed
    // + SyncNpcScareNpc
    // ================================================================
    public class ActionFlee : BTNode
    {
        public float Radius { get; set; } = 30f;
        public float SpeedMultiplier { get; set; } = 2.5f;
        public float DurationSeconds { get; set; } = 8f;
        private DateTime _fleeStarted;

        public ActionFlee(float radius = 30f, float speedMul = 2.5f, float duration = 8f)
        {
            Radius = radius;
            SpeedMultiplier = speedMul;
            DurationSeconds = duration;
            Name = $"Flee(r={radius},d={duration}s)";
        }

        protected override void OnStart(BTContext ctx)
        {
            _fleeStarted = ctx.Now;
            var npc = ctx.Npc;

            // Scare nearby NPCs
            BTActions.SendNpcScare(ctx.Conn, npc.EntityId, Radius, Radius * 1.5f, true);

            // Set flee movement mode (handles speed change)
            MovementScheduler.SetMovementMode(ctx.Conn, npc, Connection.MovementMode.Flee);

            // Generate flee path
            var fleePath = DynamicPathGenerator.GeneratePath(
                npc.PosX, npc.PosZ,
                npc.OriginX, npc.OriginZ,
                DynamicPathGenerator.PathType.FleeFromPoint,
                ctx.Conn.LastKnownPlayerPosition.X,
                ctx.Conn.LastKnownPlayerPosition.Z);

            if (fleePath != null && fleePath.Count >= 1)
            {
                // Apply avoidance even when fleeing (don't trample other NPCs)
                NpcAvoidance.ApplyAvoidance(fleePath, npc, ctx.Conn.GetLiveNpcs());

                npc.Waypoints = fleePath;
                npc.CurrentWaypointIndex = 0;
                npc.CurrentState = Connection.NpcState.Fleeing;
                npc.StateEnteredAt = ctx.Now;
                npc.CurrentGoal = Connection.NpcGoal.Flee;

                BTActions.SendCrowdFollowPath(ctx.Conn, npc);

                var last = fleePath[fleePath.Count - 1];
                npc.PosX = last.Position.X;
                npc.PosZ = last.Position.Z;
            }
        }

        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            if ((ctx.Now - _fleeStarted).TotalSeconds >= DurationSeconds)
            {
                // Done fleeing — restore speed
                BTActions.SendChangeSpeed(ctx.Conn, ctx.Npc, ctx.Npc.DesiredSpeed);
                ctx.Npc.CurrentState = Connection.NpcState.Idle;
                ctx.Npc.StateEnteredAt = ctx.Now;
                return TaskStatus.Success;
            }

            return TaskStatus.Running;
        }

        protected override void OnEnd(BTContext ctx)
        {
            // Reset movement mode to walk (or idle, will be synced by MovementScheduler)
            MovementScheduler.SetMovementMode(ctx.Conn, ctx.Npc, Connection.MovementMode.Walk);
        }
    }

    // ================================================================
    // ACTION: IDLE — set NPC state to Idle
    // ================================================================
    public class ActionIdle : BTNode
    {
        public ActionIdle()
        {
            Name = "Idle";
        }

        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            if (ctx.Npc.CurrentState != Connection.NpcState.Idle)
            {
                ctx.Npc.CurrentState = Connection.NpcState.Idle;
                ctx.Npc.StateEnteredAt = ctx.Now;
                ctx.Npc.CurrentGoal = Connection.NpcGoal.Idle;
            }
            // Set idle movement mode
            MovementScheduler.SetMovementMode(ctx.Conn, ctx.Npc, Connection.MovementMode.Idle);
            return TaskStatus.Success;
        }
    }

    // ================================================================
    // ACTION: PLAY ANIMATION — trigger an animation on the NPC
    // Sends SyncAetherAINpcPlayAnimation
    // ================================================================
    public class ActionPlayAnimation : BTNode
    {
        public uint AnimationId { get; set; }

        public ActionPlayAnimation(uint animId = 0)
        {
            AnimationId = animId;
            Name = $"PlayAnim({animId})";
        }

        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            var data = new ClientNpcPlayAnimationData()
            {
                Id = ctx.Npc.EntityId,
                PoiActionId = AnimationId,
                StartTime = 0
            };
            BTActions.SendNotify(ctx.Conn, MethodId.SyncAetherAINpcPlayAnimation, data);
            return TaskStatus.Success;
        }
    }

    // ================================================================
    // ACTION: SCARE — trigger flee reaction for nearby NPCs
    // Sends SyncNpcScareNpc
    // ================================================================
    public class ActionScare : BTNode
    {
        public float Radius { get; set; }

        public ActionScare(float radius = 20f)
        {
            Radius = radius;
            Name = $"Scare(r={radius})";
        }

        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            BTActions.SendNpcScare(ctx.Conn, ctx.Npc.EntityId, Radius, Radius * 1.5f, true);
            return TaskStatus.Success;
        }
    }

    // ================================================================
    // ACTION: WAIT — return Running for N seconds, then Success
    // Useful as a delay in sequences.
    // ================================================================
    public class ActionWait : BTNode
    {
        public float Seconds { get; set; }
        private DateTime _started;

        public ActionWait(float seconds)
        {
            Seconds = seconds;
            Name = $"Wait({seconds}s)";
        }

        protected override void OnStart(BTContext ctx)
        {
            _started = ctx.Now;
        }

        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            if ((ctx.Now - _started).TotalSeconds >= Seconds)
                return TaskStatus.Success;
            return TaskStatus.Running;
        }
    }

    // ================================================================
    // ACTION: SOCIALIZE — make NPC look at and greet nearby NPCs
    // ================================================================
    public class ActionSocialize : BTNode
    {
        public float Radius { get; set; } = 10f;
        private DateTime _started;
        private Connection.SpawnedNpc? _targetNpc;

        public ActionSocialize(float radius = 10f)
        {
            Radius = radius;
            Name = $"Socialize({radius}m)";
        }

        protected override void OnStart(BTContext ctx)
        {
            _started = ctx.Now;
            _targetNpc = FindNearbyNpc(ctx);
            
            if (_targetNpc != null)
            {
                // Face the target NPC
                float dx = _targetNpc.PosX - ctx.Npc.PosX;
                float dz = _targetNpc.PosZ - ctx.Npc.PosZ;
                ctx.Npc.Facing = MathF.Atan2(dx, dz) * (180f / MathF.PI);
                ctx.Npc.CurrentState = Connection.NpcState.Talking;
                MovementScheduler.SetMovementMode(ctx.Conn, ctx.Npc, Connection.MovementMode.Idle);
            }
        }

        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            if ((ctx.Now - _started).TotalSeconds >= 3.0)
                return TaskStatus.Success;
            return TaskStatus.Running;
        }

        private Connection.SpawnedNpc FindNearbyNpc(BTContext ctx)
        {
            Connection.SpawnedNpc closest = null;
            float closestDist = Radius;

            foreach (var other in ctx.Conn.GetLiveNpcs())
            {
                if (other.EntityId == ctx.Npc.EntityId) continue;
                float dx = other.PosX - ctx.Npc.PosX;
                float dz = other.PosZ - ctx.Npc.PosZ;
                float dist = MathF.Sqrt(dx * dx + dz * dz);
                if (dist < closestDist)
                {
                    closestDist = dist;
                    closest = other;
                }
            }
            return closest;
        }
    }

    // ================================================================
    // ACTION: WANDER — random short-distance walk
    // ================================================================
    public class ActionWander : BTNode
    {
        public float Radius { get; set; } = 15f;
        private DateTime _started;

        public ActionWander(float radius = 15f)
        {
            Radius = radius;
            Name = $"Wander({radius}m)";
        }

        protected override void OnStart(BTContext ctx)
        {
            _started = ctx.Now;
            
            // Generate random destination within radius
            var rng = new Random(ctx.Npc.EntityId.GetHashCode());
            float angle = (float)(rng.NextDouble() * Math.PI * 2);
            float dist = 5f + (float)(rng.NextDouble() * (Radius - 5f));
            
            float targetX = ctx.Npc.PosX + MathF.Cos(angle) * dist;
            float targetZ = ctx.Npc.PosZ + MathF.Sin(angle) * dist;

            var path = DynamicPathGenerator.GeneratePath(
                ctx.Npc.PosX, ctx.Npc.PosZ,
                ctx.Npc.OriginX, ctx.Npc.OriginZ,
                DynamicPathGenerator.PathType.WanderLoop);

            if (path != null && path.Count >= 1)
            {
                ctx.Npc.Waypoints = path;
                ctx.Npc.CurrentWaypointIndex = 0;
                ctx.Npc.CurrentState = Connection.NpcState.Wandering;
                ctx.Npc.StateEnteredAt = ctx.Now;
                MovementScheduler.SetMovementMode(ctx.Conn, ctx.Npc, Connection.MovementMode.Walk);
                BTActions.SendCrowdFollowPath(ctx.Conn, ctx.Npc);
            }
        }

        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            if ((ctx.Now - _started).TotalSeconds >= 5.0)
                return TaskStatus.Success;
            return TaskStatus.Running;
        }
    }

    // ================================================================
    // ACTION: LOOK AT PLAYER — face the player
    // ================================================================
    public class ActionLookAtPlayer : BTNode
    {
        public ActionLookAtPlayer()
        {
            Name = "LookAtPlayer";
        }

        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            float dx = ctx.Conn.LastKnownPlayerPosition.X - ctx.Npc.PosX;
            float dz = ctx.Conn.LastKnownPlayerPosition.Z - ctx.Npc.PosZ;
            ctx.Npc.Facing = MathF.Atan2(dx, dz) * (180f / MathF.PI);
            return TaskStatus.Success;
        }
    }

    // ================================================================
    // ACTION: SIT DOWN — transition to sitting state
    // ================================================================
    public class ActionSitDown : BTNode
    {
        private DateTime _started;

        public ActionSitDown()
        {
            Name = "SitDown";
        }

        protected override void OnStart(BTContext ctx)
        {
            _started = ctx.Now;
            ctx.Npc.CurrentState = Connection.NpcState.Sitting;
            ctx.Npc.StateEnteredAt = ctx.Now;
            MovementScheduler.SetMovementMode(ctx.Conn, ctx.Npc, Connection.MovementMode.Idle);
        }

        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            // Sit for 10-30 seconds
            if ((ctx.Now - _started).TotalSeconds >= 10.0)
                return TaskStatus.Success;
            return TaskStatus.Running;
        }
    }

    // ================================================================
    // SHARED PACKET HELPERS (used by action nodes)
    // ================================================================
    public static class BTActions
    {
        public static void SendNotify(Connection conn, MethodId methodId, SerializedClass args)
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

        public static void SendCrowdFollowPath(Connection conn, Connection.SpawnedNpc npc)
        {
            if (npc.Waypoints == null || npc.Waypoints.Count < 2) return;

            var pathPoints = new List<ClientZoneGraphPathPoint>();
            for (int i = npc.CurrentWaypointIndex; i < npc.Waypoints.Count; i++)
                pathPoints.Add(npc.Waypoints[i]);
            if (npc.CurrentWaypointIndex > 0)
                for (int i = 0; i <= npc.CurrentWaypointIndex; i++)
                    pathPoints.Add(npc.Waypoints[i]);

            var pathData = new ClientZoneGraphPath()
            {
                Id = npc.EntityId,
                TargetLocationReason = ZoneGraphTargetLocationReason.Wander,
                ActionId = 0,
                Points = pathPoints
            };
            SendNotify(conn, MethodId.SyncAetherAICrowdFollowPath, pathData);
        }

        public static void SendChangeSpeed(Connection conn, Connection.SpawnedNpc npc, float speed)
        {
            var data = new ChangeSpeedArgs() { id = npc.EntityId, speed = speed };
            SendNotify(conn, MethodId.SyncChangeNpcMoveDesiredSpeed, data);
        }

        public static void SendNpcScare(Connection conn, ulong npcId, float radius, float surroundRadius, bool enable)
        {
            var data = new ScareArgs() { pid = npcId, radius = radius, surroundRadius = surroundRadius, enable = enable };
            SendNotify(conn, MethodId.SyncNpcScareNpc, data);
        }

        class ChangeSpeedArgs : SerializedClass
        {
            public ulong id;
            public float speed;
            public ChangeSpeedArgs() { onlyFields = true; }
        }

        class ScareArgs : SerializedClass
        {
            public ulong pid;
            public float radius;
            public float surroundRadius;
            public bool enable;
            public ScareArgs() { onlyFields = true; }
        }
    }
}
