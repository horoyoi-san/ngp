using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using System;
using System.Collections.Generic;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    internal partial class ClientToGameserver
    {
        // ═══════════════════════════════════════════════════
        // AUTO-GENERATED EASY HANDLERS
        // Report* = ack-only telemetry from client
        // Ask* = simple ack or minimal state tracking
        // Generated: 2026-06-22
        // ═══════════════════════════════════════════════════

        #region Report* Handlers (ack-only telemetry)

        [Handler(MethodId.ReportBehaviorSeqStart)]
        public static void ReportBehaviorSeqStartHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportBehaviorSeqStart");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportBehaviorSeqStart,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportBehaviorSeqStartList)]
        public static void ReportBehaviorSeqStartListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportBehaviorSeqStartList");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportBehaviorSeqStartList,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportBehaviorSeqFinish)]
        public static void ReportBehaviorSeqFinishHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportBehaviorSeqFinish");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportBehaviorSeqFinish,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportUnitFallGround)]
        public static void ReportUnitFallGroundHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportUnitFallGround");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportUnitFallGround,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportUnitFallGroundEnd)]
        public static void ReportUnitFallGroundEndHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportUnitFallGroundEnd");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportUnitFallGroundEnd,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportUnitFallEnd)]
        public static void ReportUnitFallEndHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportUnitFallEnd");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportUnitFallEnd,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportUnitHitFly)]
        public static void ReportUnitHitFlyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportUnitHitFly");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportUnitHitFly,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportUnitHitFlyEnd)]
        public static void ReportUnitHitFlyEndHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportUnitHitFlyEnd");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportUnitHitFlyEnd,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportUnitStandUp)]
        public static void ReportUnitStandUpHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportUnitStandUp");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportUnitStandUp,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportUnitEnterPuppet)]
        public static void ReportUnitEnterPuppetHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportUnitEnterPuppet");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportUnitEnterPuppet,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportUnitExitPuppet)]
        public static void ReportUnitExitPuppetHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportUnitExitPuppet");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportUnitExitPuppet,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportEnemyBattleMoveEnd)]
        public static void ReportEnemyBattleMoveEndHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportEnemyBattleMoveEnd");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportEnemyBattleMoveEnd,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportEnemyDetectEvent)]
        public static void ReportEnemyDetectEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportEnemyDetectEvent");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportEnemyDetectEvent,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportEnemyHitWall)]
        public static void ReportEnemyHitWallHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportEnemyHitWall");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportEnemyHitWall,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportEnemyMoveFinish)]
        public static void ReportEnemyMoveFinishHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportEnemyMoveFinish");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportEnemyMoveFinish,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportEnemyPrepareFinish)]
        public static void ReportEnemyPrepareFinishHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportEnemyPrepareFinish");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportEnemyPrepareFinish,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportEnemyWeaponState)]
        public static void ReportEnemyWeaponStateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportEnemyWeaponState");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportEnemyWeaponState,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportCanAssassinateEnemies)]
        public static void ReportCanAssassinateEnemiesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportCanAssassinateEnemies");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportCanAssassinateEnemies,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportBlockCounterSuccess)]
        public static void ReportBlockCounterSuccessHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportBlockCounterSuccess");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportBlockCounterSuccess,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportEQSPos)]
        public static void ReportEQSPosHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportEQSPos");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportEQSPos,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportSkillAnimationEnd)]
        public static void ReportSkillAnimationEndHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportSkillAnimationEnd");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportSkillAnimationEnd,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportCreationReachMaxRange)]
        public static void ReportCreationReachMaxRangeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportCreationReachMaxRange");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportCreationReachMaxRange,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportPlayActionFinish)]
        public static void ReportPlayActionFinishHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportPlayActionFinish");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportPlayActionFinish,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportPlayActionWithLayerFinish)]
        public static void ReportPlayActionWithLayerFinishHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportPlayActionWithLayerFinish");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportPlayActionWithLayerFinish,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportLookAtPositionFinish)]
        public static void ReportLookAtPositionFinishHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportLookAtPositionFinish");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportLookAtPositionFinish,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportLookAtTargetFinish)]
        public static void ReportLookAtTargetFinishHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportLookAtTargetFinish");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportLookAtTargetFinish,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportTurnToPositionFinish)]
        public static void ReportTurnToPositionFinishHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportTurnToPositionFinish");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportTurnToPositionFinish,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportSetActionGroup)]
        public static void ReportSetActionGroupHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportSetActionGroup");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportSetActionGroup,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportVisibleUnitList)]
        public static void ReportVisibleUnitListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportVisibleUnitList");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportVisibleUnitList,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportPoliceCrimeEvent)]
        public static void ReportPoliceCrimeEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportPoliceCrimeEvent");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportPoliceCrimeEvent,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportPoliceExamCommandEnd)]
        public static void ReportPoliceExamCommandEndHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportPoliceExamCommandEnd");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportPoliceExamCommandEnd,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportRequisitionVehicle)]
        public static void ReportRequisitionVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportRequisitionVehicle");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportRequisitionVehicle,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportMoveSwing)]
        public static void ReportMoveSwingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportMoveSwing");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportMoveSwing,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportClientActionFinish)]
        public static void ReportClientActionFinishHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportClientActionFinish");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportClientActionFinish,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportClientDetectEventDatas)]
        public static void ReportClientDetectEventDatasHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportClientDetectEventDatas");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportClientDetectEventDatas,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportAgentDeathPerformanceFinis)]
        public static void ReportAgentDeathPerformanceFinisHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportAgentDeathPerformanceFinis");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportAgentDeathPerformanceFinis,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportAgentInteract2F)]
        public static void ReportAgentInteract2FHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportAgentInteract2F");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportAgentInteract2F,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportAgentLeavePuppet)]
        public static void ReportAgentLeavePuppetHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportAgentLeavePuppet");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportAgentLeavePuppet,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportAgentPlatformValidateInfo)]
        public static void ReportAgentPlatformValidateInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportAgentPlatformValidateInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportAgentPlatformValidateInfo,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportAddDestructibleHookFail)]
        public static void ReportAddDestructibleHookFailHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportAddDestructibleHookFail");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportAddDestructibleHookFail,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportDoctorCureReactionCommandF)]
        public static void ReportDoctorCureReactionCommandFHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportDoctorCureReactionCommandF");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportDoctorCureReactionCommandF,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportBattleMoveOneActionLoopEnd)]
        public static void ReportBattleMoveOneActionLoopEndHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportBattleMoveOneActionLoopEnd");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportBattleMoveOneActionLoopEnd,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportRayCast4DRes)]
        public static void ReportRayCast4DResHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportRayCast4DRes");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportRayCast4DRes,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportSpecialTargetPosition)]
        public static void ReportSpecialTargetPositionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportSpecialTargetPosition");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportSpecialTargetPosition,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportPlayerStartCommonInteract)]
        public static void ReportPlayerStartCommonInteractHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportPlayerStartCommonInteract");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportPlayerStartCommonInteract,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.ReportWordReviewFailed)]
        public static void ReportWordReviewFailedHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportWordReviewFailed");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportWordReviewFailed,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Ask* Handlers (simple ack)

        [Handler(MethodId.AskFinishTaskCounter)]
        public static void AskFinishTaskCounterHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskFinishTaskCounter");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskFinishTaskCounter,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskExitWatching)]
        public static void AskExitWatchingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskExitWatching");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskExitWatching,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskHangUpDialog)]
        public static void AskHangUpDialogHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskHangUpDialog");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskHangUpDialog,
            };
            conn.SendPacket(rsp);
        }

        // AskCloseNpcChatWnd → moved to NpcChatHandlers.cs
        // AskMarkNpcChatRead → moved to NpcChatHandlers.cs
        // AskFinishNpcChatRegistration → moved to NpcChatHandlers.cs

        [Handler(MethodId.AskCompleteUrbanPlay)]
        public static void AskCompleteUrbanPlayHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskCompleteUrbanPlay");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskCompleteUrbanPlay,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskFinishPlayerRace)]
        public static void AskFinishPlayerRaceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskFinishPlayerRace");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskFinishPlayerRace,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskFinishQuestionnaire)]
        public static void AskFinishQuestionnaireHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskFinishQuestionnaire");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskFinishQuestionnaire,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskFinishMilkTopic)]
        public static void AskFinishMilkTopicHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskFinishMilkTopic");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskFinishMilkTopic,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskSetTraceTarget)]
        public static void AskSetTraceTargetHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskSetTraceTarget");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSetTraceTarget,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskSetTracePosition)]
        public static void AskSetTracePositionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskSetTracePosition");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSetTracePosition,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskSetTraceMapEntrance)]
        public static void AskSetTraceMapEntranceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskSetTraceMapEntrance");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSetTraceMapEntrance,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskRemoveTraceGps)]
        public static void AskRemoveTraceGpsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskRemoveTraceGps");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskRemoveTraceGps,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskClearRedPointList)]
        public static void AskClearRedPointListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskClearRedPointList");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskClearRedPointList,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskClearAbilityRedPoint)]
        public static void AskClearAbilityRedPointHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskClearAbilityRedPoint");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskClearAbilityRedPoint,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskClearSpiritGroupChat)]
        public static void AskClearSpiritGroupChatHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskClearSpiritGroupChat");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskClearSpiritGroupChat,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskActivityCancelRedPoint)]
        public static void AskActivityCancelRedPointHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskActivityCancelRedPoint");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskActivityCancelRedPoint,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskRemovePersonalZoneRedSpot)]
        public static void AskRemovePersonalZoneRedSpotHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskRemovePersonalZoneRedSpot");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskRemovePersonalZoneRedSpot,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskClearPersonalZoneNewFans)]
        public static void AskClearPersonalZoneNewFansHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskClearPersonalZoneNewFans");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskClearPersonalZoneNewFans,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskClearPersonalZoneNewSpiritNum)]
        public static void AskClearPersonalZoneNewSpiritNumHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskClearPersonalZoneNewSpiritNum");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskClearPersonalZoneNewSpiritNum,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskEnableInvitedNotDisturb)]
        public static void AskEnableInvitedNotDisturbHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskEnableInvitedNotDisturb");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskEnableInvitedNotDisturb,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskSetCurrentOrder)]
        public static void AskSetCurrentOrderHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskSetCurrentOrder");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSetCurrentOrder,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskSetBestNpcs)]
        public static void AskSetBestNpcsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskSetBestNpcs");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSetBestNpcs,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskComputerOpened)]
        public static void AskComputerOpenedHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskComputerOpened");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskComputerOpened,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskTouchMapEntrance)]
        public static void AskTouchMapEntranceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskTouchMapEntrance");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskTouchMapEntrance,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskReadCityPedia)]
        public static void AskReadCityPediaHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskReadCityPedia");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskReadCityPedia,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskChangeNameByItem)]
        public static void AskChangeNameByItemHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskChangeNameByItem");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskChangeNameByItem,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskAidByPid)]
        public static void AskAidByPidHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskAidByPid");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskAidByPid,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPidByAid)]
        public static void AskPidByAidHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskPidByAid");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPidByAid,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskTwitterPanelOpen)]
        public static void AskTwitterPanelOpenHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskTwitterPanelOpen");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskTwitterPanelOpen,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskTwitterPanelClose)]
        public static void AskTwitterPanelCloseHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskTwitterPanelClose");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskTwitterPanelClose,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskTwitterBehaviorFinish)]
        public static void AskTwitterBehaviorFinishHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskTwitterBehaviorFinish");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskTwitterBehaviorFinish,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskClickPlayerTwitterButton)]
        public static void AskClickPlayerTwitterButtonHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskClickPlayerTwitterButton");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskClickPlayerTwitterButton,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPublishTuite)]
        public static void AskPublishTuiteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskPublishTuite");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPublishTuite,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPublishNpcMoment)]
        public static void AskPublishNpcMomentHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskPublishNpcMoment");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPublishNpcMoment,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskInteractTuite)]
        public static void AskInteractTuiteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskInteractTuite");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskInteractTuite,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskCancelInteractTuite)]
        public static void AskCancelInteractTuiteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskCancelInteractTuite");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskCancelInteractTuite,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskGetFansAutoGiveHistory)]
        public static void AskGetFansAutoGiveHistoryHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskGetFansAutoGiveHistory");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetFansAutoGiveHistory,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskSetMobileSkinPart)]
        public static void AskSetMobileSkinPartHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskSetMobileSkinPart");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSetMobileSkinPart,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskResetMobileSkinPart)]
        public static void AskResetMobileSkinPartHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskResetMobileSkinPart");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskResetMobileSkinPart,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskGetMilkTopicInfo)]
        public static void AskGetMilkTopicInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskGetMilkTopicInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetMilkTopicInfo,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskSetMilkTopicList)]
        public static void AskSetMilkTopicListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskSetMilkTopicList");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSetMilkTopicList,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPSNPlayersInfo)]
        public static void AskPSNPlayersInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskPSNPlayersInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPSNPlayersInfo,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPSNSync)]
        public static void AskPSNSyncHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskPSNSync");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPSNSync,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskTrackWildEnemyGroupInfo)]
        public static void AskTrackWildEnemyGroupInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskTrackWildEnemyGroupInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskTrackWildEnemyGroupInfo,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskCancelTrackWildEnemyGroupInfo)]
        public static void AskCancelTrackWildEnemyGroupInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskCancelTrackWildEnemyGroupInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskCancelTrackWildEnemyGroupInfo,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskGetSavedRaidTargetInfo)]
        public static void AskGetSavedRaidTargetInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskGetSavedRaidTargetInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetSavedRaidTargetInfo,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskStartGymExercise)]
        public static void AskStartGymExerciseHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskStartGymExercise");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskStartGymExercise,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskCompleteSingleGymExercise)]
        public static void AskCompleteSingleGymExerciseHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskCompleteSingleGymExercise");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskCompleteSingleGymExercise,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskTakePopularityReward)]
        public static void AskTakePopularityRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskTakePopularityReward");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskTakePopularityReward,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskTakeAccumulateSignInReward)]
        public static void AskTakeAccumulateSignInRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskTakeAccumulateSignInReward");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskTakeAccumulateSignInReward,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskGetWorldEnemyReward)]
        public static void AskGetWorldEnemyRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Ack] AskGetWorldEnemyReward");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetWorldEnemyReward,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Ask* Handlers (state tracking)

        [Handler(MethodId.AskMomentsUnreadMessage)]
        public static void AskMomentsUnreadMessageHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskMomentsUnreadMessage");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMomentsUnreadMessage,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskMomentsHaveUnreadMessage)]
        public static void AskMomentsHaveUnreadMessageHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskMomentsHaveUnreadMessage");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMomentsHaveUnreadMessage,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskMomentsMarkRead)]
        public static void AskMomentsMarkReadHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskMomentsMarkRead");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMomentsMarkRead,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskMomentsLikePost)]
        public static void AskMomentsLikePostHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskMomentsLikePost");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMomentsLikePost,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskMomentsPostInfos)]
        public static void AskMomentsPostInfosHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskMomentsPostInfos");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMomentsPostInfos,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskMomentsPostSimpleInfos)]
        public static void AskMomentsPostSimpleInfosHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskMomentsPostSimpleInfos");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMomentsPostSimpleInfos,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskMomentsSendCommentWithId)]
        public static void AskMomentsSendCommentWithIdHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskMomentsSendCommentWithId");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMomentsSendCommentWithId,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskMomentsShareCustomPost)]
        public static void AskMomentsShareCustomPostHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskMomentsShareCustomPost");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMomentsShareCustomPost,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskMomentsTapPost)]
        public static void AskMomentsTapPostHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskMomentsTapPost");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMomentsTapPost,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskMomentsTapPostWithCount)]
        public static void AskMomentsTapPostWithCountHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskMomentsTapPostWithCount");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMomentsTapPostWithCount,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskMomentsDeleteCustomPost)]
        public static void AskMomentsDeleteCustomPostHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskMomentsDeleteCustomPost");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMomentsDeleteCustomPost,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskUpdatePersonalZoneHead)]
        public static void AskUpdatePersonalZoneHeadHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskUpdatePersonalZoneHead");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskUpdatePersonalZoneHead,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskUpdatePersonalZoneBackground)]
        public static void AskUpdatePersonalZoneBackgroundHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskUpdatePersonalZoneBackground");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskUpdatePersonalZoneBackground,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskUpdatePersonalZoneBirthday)]
        public static void AskUpdatePersonalZoneBirthdayHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskUpdatePersonalZoneBirthday");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskUpdatePersonalZoneBirthday,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskUpdatePersonalZoneDescription)]
        public static void AskUpdatePersonalZoneDescriptionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskUpdatePersonalZoneDescription");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskUpdatePersonalZoneDescription,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskUpdatePersonalZoneAchieveList)]
        public static void AskUpdatePersonalZoneAchieveListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskUpdatePersonalZoneAchieveList");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskUpdatePersonalZoneAchieveList,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskGetPersonalZoneBackGroundList)]
        public static void AskGetPersonalZoneBackGroundListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskGetPersonalZoneBackGroundList");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetPersonalZoneBackGroundList,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskGetPersonalZoneRedSpot)]
        public static void AskGetPersonalZoneRedSpotHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskGetPersonalZoneRedSpot");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetPersonalZoneRedSpot,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskLoadWeaponToSlot)]
        public static void AskLoadWeaponToSlotHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskLoadWeaponToSlot");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskLoadWeaponToSlot,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskExchangeWeaponSlot)]
        public static void AskExchangeWeaponSlotHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskExchangeWeaponSlot");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskExchangeWeaponSlot,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDepositSpiritWeapon)]
        public static void AskDepositSpiritWeaponHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskDepositSpiritWeapon");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDepositSpiritWeapon,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDiscardArmoryWeapon)]
        public static void AskDiscardArmoryWeaponHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[State] AskDiscardArmoryWeapon");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDiscardArmoryWeapon,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Ask* Handlers (config query / simple returns)

        [Handler(MethodId.AskWildEnemyBasicInfo)]
        public static void AskWildEnemyBasicInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskWildEnemyBasicInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskWildEnemyBasicInfo,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskWildEnemyPositionInfo)]
        public static void AskWildEnemyPositionInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskWildEnemyPositionInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskWildEnemyPositionInfo,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskCheckWildEnemyGroup)]
        public static void AskCheckWildEnemyGroupHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskCheckWildEnemyGroup");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskCheckWildEnemyGroup,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskGetRaidWildEnemyInfo)]
        public static void AskGetRaidWildEnemyInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskGetRaidWildEnemyInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetRaidWildEnemyInfo,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskClaimBattlePassReward)]
        public static void AskClaimBattlePassRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskClaimBattlePassReward");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskClaimBattlePassReward,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskClaimGachaMilestone)]
        public static void AskClaimGachaMilestoneHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskClaimGachaMilestone");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskClaimGachaMilestone,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPlayerAchievements)]
        public static void AskPlayerAchievementsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskPlayerAchievements");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPlayerAchievements,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskGetAchievementReward)]
        public static void AskGetAchievementRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskGetAchievementReward");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetAchievementReward,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskGetAllAchievementReward)]
        public static void AskGetAllAchievementRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskGetAllAchievementReward");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetAllAchievementReward,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskTakeLevelReward)]
        public static void AskTakeLevelRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskTakeLevelReward");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskTakeLevelReward,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskMahjongInfo)]
        public static void AskMahjongInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskMahjongInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMahjongInfo,
            };
            conn.SendPacket(rsp);
        }

        // AskLiveHouseMusicList → moved to LiveHouseMusicHandlers.cs

        // AskLiveHouseUseItem → moved to LiveHouseMusicHandlers.cs

        [Handler(MethodId.AskGetComputerUnlockInfo)]
        public static void AskGetComputerUnlockInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskGetComputerUnlockInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetComputerUnlockInfo,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDeleteMails)]
        public static void AskDeleteMailsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskDeleteMails");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDeleteMails,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskAddMailToFavorites)]
        public static void AskAddMailToFavoritesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskAddMailToFavorites");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskAddMailToFavorites,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskRemoveMailFromFavorites)]
        public static void AskRemoveMailFromFavoritesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskRemoveMailFromFavorites");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskRemoveMailFromFavorites,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskGetMailItem)]
        public static void AskGetMailItemHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskGetMailItem");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetMailItem,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskMailFavorites)]
        public static void AskMailFavoritesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskMailFavorites");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMailFavorites,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskInvestigatorInfo)]
        public static void AskInvestigatorInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskInvestigatorInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskInvestigatorInfo,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskNameAnimal)]
        public static void AskNameAnimalHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskNameAnimal");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskNameAnimal,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskAnimalHandbookInteract)]
        public static void AskAnimalHandbookInteractHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskAnimalHandbookInteract");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskAnimalHandbookInteract,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDoctorCheck)]
        public static void AskDoctorCheckHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskDoctorCheck");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDoctorCheck,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDoctorCure)]
        public static void AskDoctorCureHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskDoctorCure");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDoctorCure,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDecompositePokemon)]
        public static void AskDecompositePokemonHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskDecompositePokemon");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDecompositePokemon,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPokemonRebuild)]
        public static void AskPokemonRebuildHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskPokemonRebuild");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPokemonRebuild,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskStartBarDice)]
        public static void AskStartBarDiceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskStartBarDice");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskStartBarDice,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskEndBarDice)]
        public static void AskEndBarDiceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskEndBarDice");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskEndBarDice,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskRouletteDiscardPublicWeapon)]
        public static void AskRouletteDiscardPublicWeaponHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskRouletteDiscardPublicWeapon");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskRouletteDiscardPublicWeapon,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskRouletteSwitchPublicWeapon)]
        public static void AskRouletteSwitchPublicWeaponHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskRouletteSwitchPublicWeapon");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskRouletteSwitchPublicWeapon,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskStartTaxiNavigate)]
        public static void AskStartTaxiNavigateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskStartTaxiNavigate");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskStartTaxiNavigate,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskTaxiAccelerate)]
        public static void AskTaxiAccelerateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AskTaxiAccelerate");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskTaxiAccelerate,
            };
            conn.SendPacket(rsp);
        }

        // ═══════════════════════════════════════════════════
        // NEWLY IMPLEMENTED TODO RPCs
        // ═══════════════════════════════════════════════════

        [Handler(MethodId.ChoosePartyNPC)]
        public static void ChoosePartyNPCHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Party] ChoosePartyNPC");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ChoosePartyNPC,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.SyncWorldBattlePlayers)]
        public static void SyncWorldBattlePlayersHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Battle] SyncWorldBattlePlayers");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncWorldBattlePlayers,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.StartSingleParty)]
        public static void StartSinglePartyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Party] StartSingleParty");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.StartSingleParty,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.SetMiniGame_BeeScore)]
        public static void SetMiniGame_BeeScoreHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[MiniGame] SetMiniGame_BeeScore");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SetMiniGame_BeeScore,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AddPersonalTimeSetting)]
        public static void AddPersonalTimeSettingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Config] AddPersonalTimeSetting");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AddPersonalTimeSetting,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.SyncEnterFogMapPoiId)]
        public static void SyncEnterFogMapPoiIdHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Map] SyncEnterFogMapPoiId");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnterFogMapPoiId,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.DoMessageCallback)]
        public static void DoMessageCallbackHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Message] DoMessageCallback");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.DoMessageCallback,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.SetNewChallengeData)]
        public static void SetNewChallengeDataHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Challenge] SetNewChallengeData");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SetNewChallengeData,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskLinkPlanningBoardDividendsPut)]
        public static void AskLinkPlanningBoardDividendsPutHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Planning] AskLinkPlanningBoardDividendsPut");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskLinkPlanningBoardDividendsPut,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskReadPoliceFakeClueAgentInfoLi)]
        public static void AskReadPoliceFakeClueAgentInfoLiHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Police] AskReadPoliceFakeClueAgentInfoLi");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskReadPoliceFakeClueAgentInfoLi,
            };
            conn.SendPacket(rsp);
        }

        // ═══════════════════════════════════════════════════

        #endregion
    }
}
