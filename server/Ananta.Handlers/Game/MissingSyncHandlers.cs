using System;
using AnantaTestGameServer.Messages;
using UX.RPC.Protocol;
using AnantaTestGameServer.Methods.Return;
using AnantaTestGameServer.Methods;

namespace AnantaTestGameServer.Packets.Req
{
    internal class MissingSyncHandlers
    {
        internal static void SendSyncAcceptTruckJobOrder(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAcceptTruckJobOrder,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncActionDataOpen(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncActionDataOpen,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncActivateLockedNpcCard(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncActivateLockedNpcCard,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncActivateNpcCard(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncActivateNpcCard,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncActiveSpiritJobTalentLayer(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncActiveSpiritJobTalentLayer,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncActiveWildEnemyGroup(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncActiveWildEnemyGroup,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncActivityData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncActivityData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAddAttractPointViews(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAddAttractPointViews,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAddCreation(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAddCreation,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAddDelayDrop(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAddDelayDrop,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAddDestructibleHook(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAddDestructibleHook,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAddFashion(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAddFashion,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAddFashionList(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAddFashionList,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAddGpsOnVehicle(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAddGpsOnVehicle,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAddHouse(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAddHouse,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAddObstacle(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAddObstacle,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAddTaskDialogArea(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAddTaskDialogArea,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAddUnitState(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAddUnitState,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIBorrowVehicle(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIBorrowVehicle,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIChangeVehicleControl(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIChangeVehicleControl,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAICreateFormation(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAICreateFormation,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAICrowdAdd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAICrowdAdd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAICrowdFollowPath(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAICrowdFollowPath,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIFormationUpdate(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIFormationUpdate,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIHandleVehicleCollisi(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIHandleVehicleCollisi,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIInitDatas(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIInitDatas,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIIntersectionUpdateDa(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIIntersectionUpdateDa,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIMetroNpcAdd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIMetroNpcAdd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAINpcPlayAnimation(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAINpcPlayAnimation,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAINpcRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAINpcRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIPauseUnitControl(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIPauseUnitControl,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIPedConvertToVehicleN(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIPedConvertToVehicleN,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIRaidVehicleRegressAe(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIRaidVehicleRegressAe,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAISetVehicleStatus(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAISetVehicleStatus,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIStaticNpcAddData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIStaticNpcAddData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIStaticNpcConvertToPe(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIStaticNpcConvertToPe,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIStaticVehicleAddData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIStaticVehicleAddData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIStaticVehicleRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIStaticVehicleRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIVehicleAddData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIVehicleAddData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIVehicleAddDatas(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIVehicleAddDatas,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIVehicleForceGo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIVehicleForceGo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIVehicleLaneDatas(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIVehicleLaneDatas,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIVehicleNpcAdd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIVehicleNpcAdd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIVehicleNpcConvertToP(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIVehicleNpcConvertToP,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIVehicleNpcRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIVehicleNpcRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherAIVehicleRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherAIVehicleRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAetherVehicleEscapeStatus(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAetherVehicleEscapeStatus,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentAttractBsIng(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentAttractBsIng,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentBelongings(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentBelongings,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentBubbleConfigs(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentBubbleConfigs,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentCampInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentCampInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentChangeAvoidanceRadius(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentChangeAvoidanceRadius,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentChangeDeathSetting(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentChangeDeathSetting,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentChangeNpcAction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentChangeNpcAction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentChangeWeapon(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentChangeWeapon,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentCharacter(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentCharacter,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentChat(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentChat,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentCrimeAdd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentCrimeAdd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentCrimeData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentCrimeData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentCrimes(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentCrimes,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentCureReaction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentCureReaction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentDiseaseAttack(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentDiseaseAttack,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentDiseaseCured(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentDiseaseCured,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentDiseaseProgress(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentDiseaseProgress,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentDiseases(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentDiseases,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentEmotion(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentEmotion,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentFanPerformanceInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentFanPerformanceInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentFanSinglePerformanceInf(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentFanSinglePerformanceInf,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentFinishBelongingUsage(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentFinishBelongingUsage,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentFinishNpcDialog(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentFinishNpcDialog,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentFocusOn(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentFocusOn,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentForceFinishNpcDialog(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentForceFinishNpcDialog,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentHitPredict(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentHitPredict,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentHitPredictEnd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentHitPredictEnd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentHitPredictId(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentHitPredictId,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentIgnoreCollision(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentIgnoreCollision,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentPersuadeProgress(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentPersuadeProgress,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentPlotBeforeRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentPlotBeforeRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentPlotData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentPlotData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentPoliceExamData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentPoliceExamData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentPrepareStartNpcDialog(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentPrepareStartNpcDialog,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentShowDialogCaption(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentShowDialogCaption,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentStateAdd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentStateAdd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentStateRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentStateRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentStates(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentStates,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentStimTrigger(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentStimTrigger,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentStolenType(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentStolenType,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentSuitChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentSuitChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentUseBelongingChanged(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentUseBelongingChanged,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAgentVirus(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAgentVirus,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAIDebugInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAIDebugInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAIPersistentAction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAIPersistentAction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAllAcceptTruckOrder(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAllAcceptTruckOrder,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAllActivities(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAllActivities,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAllQueryScene(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAllQueryScene,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAllUnlockedVehicles(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAllUnlockedVehicles,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAnimalInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAnimalInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncArmoryAddWeapon(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncArmoryAddWeapon,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncArmoryRemoveWeapon(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncArmoryRemoveWeapon,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAssignVehicleAITask(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAssignVehicleAITask,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAttractPointInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAttractPointInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAttractPointPosition(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAttractPointPosition,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncAttractSoundEnd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncAttractSoundEnd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBackpackItemChanged(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBackpackItemChanged,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBannedReason(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBannedReason,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBartenderCustomerInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBartenderCustomerInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBartenderElementStockOz(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBartenderElementStockOz,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBasketballsOperatorAction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBasketballsOperatorAction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBasketballsOwnerInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBasketballsOwnerInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBattleAiS(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBattleAiS,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBattlePassInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBattlePassInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBattlePassProgress(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBattlePassProgress,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBattlePassRewardClaimState(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBattlePassRewardClaimState,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBattlePassTasks(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBattlePassTasks,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBattlePassType(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBattlePassType,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBattleUnitInstantMoved(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBattleUnitInstantMoved,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBeBreakPoiseByOthers(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBeBreakPoiseByOthers,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBeginPortal(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBeginPortal,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBelongItemAdd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBelongItemAdd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBelongItemRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBelongItemRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBindNpcToMetro(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBindNpcToMetro,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBirdGroupStateChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBirdGroupStateChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBirdGroupViewData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBirdGroupViewData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBowlingClientInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBowlingClientInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBowlingScoreInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBowlingScoreInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBreakDialog(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBreakDialog,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBreakDialogList(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBreakDialogList,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBreakSkill(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBreakSkill,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBVBChaosBuff(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBVBChaosBuff,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBVBChaosTagInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBVBChaosTagInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBVBEnemyUltEnergy(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBVBEnemyUltEnergy,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBVBFightEndTime(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBVBFightEndTime,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBVBGameEnd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBVBGameEnd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBVBLinkSelectTeam(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBVBLinkSelectTeam,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBVBMoney(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBVBMoney,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBVBRoundEnd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBVBRoundEnd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBVBStartFight(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBVBStartFight,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBVBStartGame(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBVBStartGame,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBVBStartSelectChaosBuff(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBVBStartSelectChaosBuff,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBVBStartSelectFightPokemon(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBVBStartSelectFightPokemon,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBVBUltSkill(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBVBUltSkill,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncBVBUpdateFightPokemons(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncBVBUpdateFightPokemons,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCameraXYAxisValue(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCameraXYAxisValue,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCancelInviteePlayerInteracti(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCancelInviteePlayerInteracti,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCancelInviterPlayerInteracti(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCancelInviterPlayerInteracti,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCanDebugAI(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCanDebugAI,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCanWatchOther(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCanWatchOther,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCaptureEnemy(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCaptureEnemy,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCastVote(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCastVote,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChangeActiveSkill(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeActiveSkill,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChangeAetherDangerArea(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeAetherDangerArea,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChangeAgentSpawnInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeAgentSpawnInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChangeCommonSkill(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeCommonSkill,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChangeControlSkill(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeControlSkill,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChangeDodgeSkill(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeDodgeSkill,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChangeEventConditionProgress(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeEventConditionProgress,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChangeHeavyAttack(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeHeavyAttack,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChangeIndoor(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeIndoor,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChangeIndoorFightLimitType(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeIndoorFightLimitType,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChangeName(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeName,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChangeNpcMoveDesiredSpeed(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeNpcMoveDesiredSpeed,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChangeSafeArea(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeSafeArea,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChangeUniqueSkill(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeUniqueSkill,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChangeVehicleAITaskState(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeVehicleAITaskState,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChangeVehicleController(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeVehicleController,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChangeVehicleInteractable(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeVehicleInteractable,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChaosAgentStatisticInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChaosAgentStatisticInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChaosNpcBeAttacked(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChaosNpcBeAttacked,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncChargeDeliveryResult(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChargeDeliveryResult,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCheckAgentDistance(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCheckAgentDistance,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCityPediaCreditInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCityPediaCreditInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCityPediaCreditUpdate(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCityPediaCreditUpdate,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncClawDateInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncClawDateInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncClawDateOut(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncClawDateOut,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCleaningInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCleaningInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCleaningWashMaskInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCleaningWashMaskInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncClearNpcChatInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncClearNpcChatInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncClearNpcGroupChatInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncClearNpcGroupChatInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncClearSpoonEnemies(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncClearSpoonEnemies,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncClientAction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncClientAction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncClientActionBreak(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncClientActionBreak,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncClientCheckPatch(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncClientCheckPatch,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncClientConditional(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncClientConditional,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncClientConfig(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncClientConfig,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncClientDMEMOverrideData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncClientDMEMOverrideData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncClientUseSkill(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncClientUseSkill,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCloseBelongingVoice(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCloseBelongingVoice,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCollectionCountryUnlock(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCollectionCountryUnlock,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCollectionQuestUnlock(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCollectionQuestUnlock,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCommodityInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCommodityInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCommonSpiritTalentExp(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCommonSpiritTalentExp,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCompletedChallenge(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCompletedChallenge,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCompletedSubQuest(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCompletedSubQuest,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncComputerNewUnlockEmail(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncComputerNewUnlockEmail,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncComputerNewUnlockFile(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncComputerNewUnlockFile,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncControllableAgent(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncControllableAgent,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncControllableAgentNextAvailab(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncControllableAgentNextAvailab,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncControlVehicleRadar(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncControlVehicleRadar,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncConvertStaticNpcToTask(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncConvertStaticNpcToTask,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncConvertTaskNpcToPed(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncConvertTaskNpcToPed,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncConvertToNormalNpc(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncConvertToNormalNpc,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCountryReputation(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCountryReputation,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCreateRaidVehicleAndClaimSea(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCreateRaidVehicleAndClaimSea,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCreationPositionAndRotation(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCreationPositionAndRotation,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCrowdClearZone(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCrowdClearZone,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCrowdDangerZone(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCrowdDangerZone,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCrowdSpecifiedDensityRefresh(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCrowdSpecifiedDensityRefresh,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCrowdSurroundZone(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCrowdSurroundZone,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCurrentLinkMode(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCurrentLinkMode,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCurrentStimPriority(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCurrentStimPriority,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCurrentTask(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCurrentTask,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCurrentTaskDebug(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCurrentTaskDebug,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncCurrentTruckOrder(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncCurrentTruckOrder,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDartScoreInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDartScoreInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDebugAgentBehavior(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDebugAgentBehavior,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDebugAgentControl(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDebugAgentControl,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDebugAgentPosition(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDebugAgentPosition,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDebugAgentStimData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDebugAgentStimData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDebugAttractPoint(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDebugAttractPoint,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDebugBodyOccupies(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDebugBodyOccupies,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDebugCrowdAdd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDebugCrowdAdd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDebugCrowdPosition(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDebugCrowdPosition,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDebugDeviationValue(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDebugDeviationValue,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDebugEmotion(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDebugEmotion,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDebugLogicPosition(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDebugLogicPosition,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDebugPlotBT(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDebugPlotBT,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDebugRecentStimEvent(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDebugRecentStimEvent,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDebugReserveGpuDumps(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDebugReserveGpuDumps,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDebugScene(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDebugScene,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDebugUrbanDiversityId(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDebugUrbanDiversityId,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDeleteClientFile(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDeleteClientFile,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDeleteEventPanelView(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDeleteEventPanelView,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDeleteMail(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDeleteMail,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDestroyMetroInfos(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestroyMetroInfos,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDestroyPoliceVehicles(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestroyPoliceVehicles,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDestroySurroundNpc(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestroySurroundNpc,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDestroyVehicle(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestroyVehicle,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDestructibleGridAOIDecrease(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestructibleGridAOIDecrease,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDestructibleGridAOIIncrease(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestructibleGridAOIIncrease,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDestructibleNavVoxels(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestructibleNavVoxels,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDestructibleObjectAdd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestructibleObjectAdd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDestructibleObjectAddList(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestructibleObjectAddList,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDestructibleObjectBreak(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestructibleObjectBreak,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDestructibleObjectRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestructibleObjectRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDestructibleObjectRemoveList(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestructibleObjectRemoveList,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDestructibleSceneAOIActive(Connection conn, bool active)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestructibleSceneAOIActive,
            };
            rsp.Args = BitConverter.GetBytes(active);
            conn.SendPacket(rsp);
            Console.WriteLine($"[AOI] SyncDestructibleSceneAOIActive: active={active}");
        }

        internal static void SendSyncDestructibleSyncInfos(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestructibleSyncInfos,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDestructibleTrustee(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDestructibleTrustee,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDialogDebug(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDialogDebug,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDiDiNextTask(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDiDiNextTask,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDiDiPromoteTask(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDiDiPromoteTask,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDisableBackToPornPos(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDisableBackToPornPos,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDisarmCreateWeaponDestructib(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDisarmCreateWeaponDestructib,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDivinerAIError(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDivinerAIError,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDivinerAIMessage(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDivinerAIMessage,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDivinerCustomerInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDivinerCustomerInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDoAetherAgentBehaviorTaskDef(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDoAetherAgentBehaviorTaskDef,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDoGmCommand(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDoGmCommand,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDoToLuaMaster(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDoToLuaMaster,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDropBelonging(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDropBelonging,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDropLimitInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDropLimitInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDropLimitInfoRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDropLimitInfoRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDynamicGoActiveInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDynamicGoActiveInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncDynamicGoChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncDynamicGoChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnableBackToBornPos(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnableBackToBornPos,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEndPortal(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEndPortal,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEndRaidEnemyGroupSound(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEndRaidEnemyGroupSound,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyBattleMoveTowardPoint(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyBattleMoveTowardPoint,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyBattleMoveTowardUnit(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyBattleMoveTowardUnit,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyBeginItemDrop(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyBeginItemDrop,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyBeginSceneItemDrop(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyBeginSceneItemDrop,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyBindVehicle(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyBindVehicle,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyBubble(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyBubble,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyCurveMove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyCurveMove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyDetect(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyDetect,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyDetectStatus(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyDetectStatus,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyDisarmState(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyDisarmState,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyEndItemDrop(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyEndItemDrop,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyFightEdict(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyFightEdict,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyItemDropDatas(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyItemDropDatas,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyItemPickUp(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyItemPickUp,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyMindPowerInteractId(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyMindPowerInteractId,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyMoveToCanShootPos(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyMoveToCanShootPos,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyMoveToPos(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyMoveToPos,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyMovingLuaSlotId(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyMovingLuaSlotId,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyOwnerId(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyOwnerId,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyPlayAction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyPlayAction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyPoiseRate(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyPoiseRate,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyPoiseWeaponChangeInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyPoiseWeaponChangeInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyPrepareDie(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyPrepareDie,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyScareNpc(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyScareNpc,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemySpoonGroupId(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemySpoonGroupId,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyStopMove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyStopMove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnemyUseClientSkill(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnemyUseClientSkill,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnterFogMapPoiId(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnterFogMapPoiId,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEnterScene(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnterScene,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEntityActionGroup(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEntityActionGroup,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncEventPanelView(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEventPanelView,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFactionHighLightEventList(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFactionHighLightEventList,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFactionInfluenceAreaOccupy(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFactionInfluenceAreaOccupy,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFactionInfoChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFactionInfoChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFactionInfosChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFactionInfosChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFakePersonRed(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFakePersonRed,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFashionInfoDict(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFashionInfoDict,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFavorNpcSpoonAgentId(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFavorNpcSpoonAgentId,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFavorNpcTimeTableInfos(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFavorNpcTimeTableInfos,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFerrisWheelInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFerrisWheelInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFightGamePlayerAction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFightGamePlayerAction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFightGamePlayerInfos(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFightGamePlayerInfos,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFightGamePlayerLeave(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFightGamePlayerLeave,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFightGamePlayerStart(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFightGamePlayerStart,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFightGamePlayerState(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFightGamePlayerState,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFightGameResultInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFightGameResultInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFightGroupDebugInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFightGroupDebugInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFightResource(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFightResource,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFightResourceFreeState(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFightResourceFreeState,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFightSpiritStartDie(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFightSpiritStartDie,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFinishTime(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFinishTime,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFirstEnemyKillRecord(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFirstEnemyKillRecord,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFollowTeamLeader(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFollowTeamLeader,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncForceEnemyRelation(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncForceEnemyRelation,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncForceRelation(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncForceRelation,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncFurnitureInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncFurnitureInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGadgetAdd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGadgetAdd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGadgetAddList(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGadgetAddList,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGadgetAOIAddAndRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGadgetAOIAddAndRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGadgetGridAOIDecrease(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGadgetGridAOIDecrease,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGadgetRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGadgetRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGadgetRemoveList(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGadgetRemoveList,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGadgetUntrustedUIds(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGadgetUntrustedUIds,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGameGroundZoneInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGameGroundZoneInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGameGroundZonePlayerInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGameGroundZonePlayerInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGameGroundZoneState(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGameGroundZoneState,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGameGroundZoneTurnChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGameGroundZoneTurnChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGameModeInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGameModeInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGamePause(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGamePause,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGameSwitchToClient(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGameSwitchToClient,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGameSwitchToClient_2(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGameSwitchToClient_2,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGameSwitchToClient_3(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGameSwitchToClient_3,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGangBossCurrentBattleAgentCo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGangBossCurrentBattleAgentCo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGangBossFullDetails(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGangBossFullDetails,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGangBossGangMemberDetails(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGangBossGangMemberDetails,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGangBoTanBattle(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGangBoTanBattle,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGeneralCutInPost(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGeneralCutInPost,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGeneralSceneTip(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGeneralSceneTip,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGetAgentPlatformInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGetAgentPlatformInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGetEQSPos(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGetEQSPos,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGetOffOnVehicleEnemyDie(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGetOffOnVehicleEnemyDie,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGmCapture(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGmCapture,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGmTime(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGmTime,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGoldAdd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGoldAdd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGoldRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGoldRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGomokuParticipantRecord(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGomokuParticipantRecord,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGomokuScoreInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGomokuScoreInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGravityFieldOn(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGravityFieldOn,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGroupEnemyLockTarget(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGroupEnemyLockTarget,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncGuideTeachInfos(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncGuideTeachInfos,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncHackerBatteryCostInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncHackerBatteryCostInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncHackerBatteryCurrentAndTotal(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncHackerBatteryCurrentAndTotal,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncHasNotEarnedAchievement(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncHasNotEarnedAchievement,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncHideMetroStates(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncHideMetroStates,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncHideNpcAndVehicleState(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncHideNpcAndVehicleState,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncHotPatchAll(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncHotPatchAll,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncHotSpringInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncHotSpringInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncHouseCancelParking(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncHouseCancelParking,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncHouseFurnitureInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncHouseFurnitureInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncHouseParking(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncHouseParking,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncIKIdleRotate(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncIKIdleRotate,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncInactiveWildEnemyGroup(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncInactiveWildEnemyGroup,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncIndoorSectorControl(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncIndoorSectorControl,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncInMjGame(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncInMjGame,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncInteractBindPerformance(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncInteractBindPerformance,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncInteractCmd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncInteractCmd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncInvestigateGallery(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncInvestigateGallery,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncInviteeInvitePlayerInteracti(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncInviteeInvitePlayerInteracti,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncInviteePlayerInteractionActi(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncInviteePlayerInteractionActi,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncInviteRideNpcInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncInviteRideNpcInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncInviterPlayerInteractionActi(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncInviterPlayerInteractionActi,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncInviterReplyInvitePlayerInte(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncInviterReplyInvitePlayerInte,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncItemCountLimit(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncItemCountLimit,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncItemDayCount(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncItemDayCount,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncItemShortcut(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncItemShortcut,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncJobMissionStateChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncJobMissionStateChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLinkAutoRespond(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLinkAutoRespond,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLinkDeviceLevel(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLinkDeviceLevel,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLinkDeviceLevel_2(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLinkDeviceLevel_2,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLinkInvite(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLinkInvite,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLinkKicked(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLinkKicked,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLinkMatchRoomPrepare(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLinkMatchRoomPrepare,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLinkMemberAdd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLinkMemberAdd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLinkMemberInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLinkMemberInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLinkMemberOffline(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLinkMemberOffline,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLinkMemberOnline(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLinkMemberOnline,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLinkMemberRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLinkMemberRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLinkMemberSceneInfoChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLinkMemberSceneInfoChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLinkMemberVehicleInfoChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLinkMemberVehicleInfoChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLoadAiVehicle(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLoadAiVehicle,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLoadIndoorSector(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLoadIndoorSector,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLoadingPanelWait(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLoadingPanelWait,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLoadingTextChanges(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLoadingTextChanges,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLockedNpcFavor(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLockedNpcFavor,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLogicAgentEnter(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLogicAgentEnter,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLogicAgentLeave(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLogicAgentLeave,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLogicStateMachineInwardSigna(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLogicStateMachineInwardSigna,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLoginDebug(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLoginDebug,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLoginKick(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLoginKick,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLoginKick_2(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLoginKick_2,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLoginServerQueue(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLoginServerQueue,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLookAtPosition(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLookAtPosition,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLookAtTarget(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLookAtTarget,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLuaSlotEntityMessage(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLuaSlotEntityMessage,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMahjongChat(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMahjongChat,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMahjongNpcChat(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMahjongNpcChat,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMallCommoditySpiritDisplayPr(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMallCommoditySpiritDisplayPr,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncManagedAgent(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncManagedAgent,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncManagedCreation(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncManagedCreation,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncManagedSpirit(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncManagedSpirit,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMapEntrance(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMapEntrance,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMapRandomEventsList(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMapRandomEventsList,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMassCustomHideArea(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMassCustomHideArea,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchGameLeftFailureDieCount(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchGameLeftFailureDieCount,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchGameMemberLeave(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchGameMemberLeave,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchGameMemberPlayGameAgain(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchGameMemberPlayGameAgain,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchGameMembersAllLoaded(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchGameMembersAllLoaded,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchGameSettleData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchGameSettleData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchGameStart(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchGameStart,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomDismissed(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomDismissed,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomDutyConfirm(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomDutyConfirm,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomDutySwapApplication(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomDutySwapApplication,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomDutySwapRemoved(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomDutySwapRemoved,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomInvite(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomInvite,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomKicked(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomKicked,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomMatchCancel(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomMatchCancel,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomMatchStart(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomMatchStart,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomMemberChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomMemberChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomMemberChangePrepare(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomMemberChangePrepare,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomMemberConfirmed(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomMemberConfirmed,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomMemberReady(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomMemberReady,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomNotReady(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomNotReady,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomPrepare(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomPrepare,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomReady(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomReady,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomSettingChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomSettingChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMATest(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMATest,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMilkNpcFavor(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMilkNpcFavor,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjAutoEnterTuoGuan(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjAutoEnterTuoGuan,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjChaDaJiao(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjChaDaJiao,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjChaHuaZhu(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjChaHuaZhu,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjChi(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjChi,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjChuPai(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjChuPai,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjDingQue(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjDingQue,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjDingQueBegin(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjDingQueBegin,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjGameInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjGameInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjGameOver(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjGameOver,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjGameReconnect(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjGameReconnect,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjGang(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjGang,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjGuo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjGuo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjHanGang(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjHanGang,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjHolds(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjHolds,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjHu(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjHu,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjHuanPai(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjHuanPai,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjHuanPaiBegin(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjHuanPaiBegin,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjHuanPaiResult(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjHuanPaiResult,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjLoginResult(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjLoginResult,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjMaoZhuanYu(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjMaoZhuanYu,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjMoPai(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjMoPai,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjOperations(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjOperations,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjPeng(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjPeng,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjPlayerAdd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjPlayerAdd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjPlayerExit(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjPlayerExit,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjPlayerReady(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjPlayerReady,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjRoomOwnerSeatIndex(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjRoomOwnerSeatIndex,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjRoomState(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjRoomState,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjScoreChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjScoreChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjTuiShui(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjTuiShui,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjTurn(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjTurn,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjYiPaoDuoXiang(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjYiPaoDuoXiang,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMobilePlatformInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMobilePlatformInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMomentsNotify(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMomentsNotify,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMoney(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMoney,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMoneyAdd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMoneyAdd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMoneyRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMoneyRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMoneyRemoveInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMoneyRemoveInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMonitorDisBtnPlayerAndVehicl(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMonitorDisBtnPlayerAndVehicl,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMonitorPoliceApproach(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMonitorPoliceApproach,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMoveToBorder(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMoveToBorder,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMoveToEQS(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMoveToEQS,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMoveWandering(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMoveWandering,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMultiCinemaMovieStart(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMultiCinemaMovieStart,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMultiplayerStatus(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMultiplayerStatus,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNearbyRunningAttractPoint(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNearbyRunningAttractPoint,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNewAchievement(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNewAchievement,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNewActivity(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNewActivity,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNewCityPediaInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNewCityPediaInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNewMail(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNewMail,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNewNpcQueueEvent(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNewNpcQueueEvent,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNewPokemon(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNewPokemon,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNewTuite(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNewTuite,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNotice(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNotice,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcChat(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcChat,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcChatInvite(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcChatInvite,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcChatJoinGameplay(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcChatJoinGameplay,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcChatLeaveGameplay(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcChatLeaveGameplay,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcChats(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcChats,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcFavor(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcFavor,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcFirstChatPosInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcFirstChatPosInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcGiftSendAvailableCount(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcGiftSendAvailableCount,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcGiftTagInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcGiftTagInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcInteractDays(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcInteractDays,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcInteractedOuterStory(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcInteractedOuterStory,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcInteractedOuterVoice(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcInteractedOuterVoice,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcInteractedStory(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcInteractedStory,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcInteractedVoice(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcInteractedVoice,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcInteractPointCount(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcInteractPointCount,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcPhotoPosInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcPhotoPosInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcScareNpc(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcScareNpc,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcTodayEventsTriggerCount(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcTodayEventsTriggerCount,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcUnlockStory(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcUnlockStory,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncNpcUnlockVoice(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncNpcUnlockVoice,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncOnlineKick(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncOnlineKick,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncOpenTuitePanel(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncOpenTuitePanel,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncOtherPlayerBegBehavior(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncOtherPlayerBegBehavior,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncOtherPlayerSpiritWearFashion(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncOtherPlayerSpiritWearFashion,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncOutOfStuckFromVehicle(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncOutOfStuckFromVehicle,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncOverrideGroupDangerArea(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncOverrideGroupDangerArea,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPartyResponse(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPartyResponse,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPartySettleData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPartySettleData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPatchILFix(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPatchILFix,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPatchILFix_2(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPatchILFix_2,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPedDatas(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPedDatas,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPhoneAutoAddContact(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPhoneAutoAddContact,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPhoneAutoDeleteContact(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPhoneAutoDeleteContact,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlanningBoardInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlanningBoardInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlateAddList(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlateAddList,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlateAOIAddAndRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlateAOIAddAndRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlateInfoChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlateInfoChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlateRemoveList(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlateRemoveList,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayActionFinish(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayActionFinish,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayActionStart(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayActionStart,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayActionWithLayerFinish(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayActionWithLayerFinish,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayActionWithLayerStart(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayActionWithLayerStart,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayControlSignal(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayControlSignal,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayEffect(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayEffect,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerAddNewSpirit(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerAddNewSpirit,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerAllSkillChargeData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerAllSkillChargeData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerAllSpirits(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerAllSpirits,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerAllTask(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerAllTask,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerAllTaskDebug(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerAllTaskDebug,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerChangeLeaderApply(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerChangeLeaderApply,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerClearTodayInspireHubGa(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerClearTodayInspireHubGa,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerCompetitionSeason(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerCompetitionSeason,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerCreateTeam(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerCreateTeam,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerCrimeLevel(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerCrimeLevel,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerCurrentOxygenValue(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerCurrentOxygenValue,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerCurrentSpirit(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerCurrentSpirit,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerCurrentTime(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerCurrentTime,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerDead(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerDead,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerExitVehicle(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerExitVehicle,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerFanInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerFanInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerFansWpPerformance(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerFansWpPerformance,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerFightStyleUnLockInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerFightStyleUnLockInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerFinishEnterOrExitVehic(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerFinishEnterOrExitVehic,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerGachaGroupBeenClear(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerGachaGroupBeenClear,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerGachaPityBeenClear(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerGachaPityBeenClear,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerGachaPoolBeenClear(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerGachaPoolBeenClear,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerGadgetTransitionId(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerGadgetTransitionId,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerGameServerInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerGameServerInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerInspireHubTodayGamepla(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerInspireHubTodayGamepla,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerInviteToTeam(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerInviteToTeam,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerJoinTeam(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerJoinTeam,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerLeaveScene(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerLeaveScene,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerLoadRate(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerLoadRate,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerLoadTaskSpoonDebug(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerLoadTaskSpoonDebug,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerMoveToDriveSeat(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerMoveToDriveSeat,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerNpcProfileActivate(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerNpcProfileActivate,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerNpcProfileMultiTrustVa(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerNpcProfileMultiTrustVa,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerNpcProfileRewardGot(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerNpcProfileRewardGot,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerNpcProfileTargetFinish(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerNpcProfileTargetFinish,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerNpcProfileTrustValueCh(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerNpcProfileTrustValueCh,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerOutOfStuck(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerOutOfStuck,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerOxygenSystemState(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerOxygenSystemState,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerPoilceChaseCountDown(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerPoilceChaseCountDown,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerPoliceChasedVehicles(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerPoliceChasedVehicles,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerPoliceChaseFinish(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerPoliceChaseFinish,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerPopularity(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerPopularity,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerPopularityAdd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerPopularityAdd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerPopularityChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerPopularityChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerProduceInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerProduceInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerResponseTeamInvite(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerResponseTeamInvite,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerRevive(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerRevive,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerSceneBasicAtmosphere(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerSceneBasicAtmosphere,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerSingleTask(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerSingleTask,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerSingleTaskDebug(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerSingleTaskDebug,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerSkillCd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerSkillCd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerSkillCdChanged(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerSkillCdChanged,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerSkillChargeData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerSkillChargeData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerStartEnterOrExitVehicl(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerStartEnterOrExitVehicl,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerStimTrigger(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerStimTrigger,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerSwitchSpiritInSitu(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerSwitchSpiritInSitu,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerTaskResidentInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerTaskResidentInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerTeamApply(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerTeamApply,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerTeamInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerTeamInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerTeamInvitationApply(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerTeamInvitationApply,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerTeamLeaderChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerTeamLeaderChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerTeamMemberJoin(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerTeamMemberJoin,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerTeamMemberKick(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerTeamMemberKick,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerTeamMemberLeave(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerTeamMemberLeave,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerTeamSettingChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerTeamSettingChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerTempSpirits(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerTempSpirits,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerTwitterButton(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerTwitterButton,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerUpdateCompetitionSeaso(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerUpdateCompetitionSeaso,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerVehicleGroupEscapeGps(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerVehicleGroupEscapeGps,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerVehicleGroupEscapeStat(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerVehicleGroupEscapeStat,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerVehicleStateChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerVehicleStateChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerWeather(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerWeather,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlayerYesterdayAvgPopularity(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerYesterdayAvgPopularity,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlotCurrentEvent(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlotCurrentEvent,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlotPlayVehicleHornSound(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlotPlayVehicleHornSound,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlotReactionPedAction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlotReactionPedAction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPlotSetVehicleMove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlotSetVehicleMove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPointInteractInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPointInteractInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPointInteractInfoAddOrRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPointInteractInfoAddOrRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPokemonSquad(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPokemonSquad,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPoliceBeginArrest(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPoliceBeginArrest,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPoliceChargingSkillProgress(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPoliceChargingSkillProgress,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPoliceDispatchHelicopter(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPoliceDispatchHelicopter,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPoliceDispatchInfos(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPoliceDispatchInfos,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPoliceDispatchVehicleChase(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPoliceDispatchVehicleChase,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPoliceDispatchVehicleChaseSt(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPoliceDispatchVehicleChaseSt,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPoliceExamReaction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPoliceExamReaction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPoliceFakeFileInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPoliceFakeFileInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPoliceFakeFileSingleInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPoliceFakeFileSingleInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPoliceMissionExamInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPoliceMissionExamInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPoliceNextOrder(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPoliceNextOrder,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPoliceServiceData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPoliceServiceData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPortalItemInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPortalItemInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPrepareKeepPositionSwitchRai(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPrepareKeepPositionSwitchRai,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPrepareMapEntrance(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPrepareMapEntrance,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPrepareSwitchSceneTimeline(Connection conn, bool withoutDefaultTimeline, string replaceTimelineName)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPrepareSwitchSceneTimeline,
            };
            rsp.SetArgs(MethodId.SyncPrepareSwitchSceneTimeline, new SyncPrepareSwitchSceneTimeline()
            {
                withoutDefaultTimeline = withoutDefaultTimeline,
                replaceTimelineName = replaceTimelineName
            });
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPrepareSwitchSpiritAcrossRai(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPrepareSwitchSpiritAcrossRai,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPreSwitchSpirit(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPreSwitchSpirit,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncPSNBlacklist(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPSNBlacklist,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncQuantumWalletInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncQuantumWalletInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncQueryAllClientScene(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncQueryAllClientScene,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncQueryClientGameObjectFilter(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncQueryClientGameObjectFilter,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncQueryClientObject(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncQueryClientObject,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncQueryClientObjectRoot(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncQueryClientObjectRoot,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncQueryClientObjects(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncQueryClientObjects,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncQueryClientScene(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncQueryClientScene,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncQueryFileSystemDownload(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncQueryFileSystemDownload,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncQueryFileSystemPath(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncQueryFileSystemPath,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncQueryFileSystemRoot(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncQueryFileSystemRoot,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncQueryGameObjectFilter(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncQueryGameObjectFilter,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncQueryObject(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncQueryObject,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncQueryObjectFields(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncQueryObjectFields,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncQueryObjectRoot(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncQueryObjectRoot,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncQueryScene(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncQueryScene,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRacingInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRacingInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRaidBattleUnitAgent(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRaidBattleUnitAgent,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRaidBattleUnitSpirit(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRaidBattleUnitSpirit,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRaidCloseTime(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRaidCloseTime,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRaidGamePlayInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRaidGamePlayInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRaidGamePlayRecordDoubleValu(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRaidGamePlayRecordDoubleValu,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRaidGamePlayRecordRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRaidGamePlayRecordRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRaidSettlement(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRaidSettlement,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRaidStartTime(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRaidStartTime,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRaidState(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRaidState,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRaidTargetCounter(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRaidTargetCounter,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRaidTargets(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRaidTargets,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRaidVehicleGpsInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRaidVehicleGpsInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRaiseVote(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRaiseVote,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRecordSpecialTargetPosition(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRecordSpecialTargetPosition,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRecoverShowAction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRecoverShowAction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRecoverStimPriority(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRecoverStimPriority,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemainReviveCount(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemainReviveCount,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveActivity(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveActivity,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveAttractPointViews(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveAttractPointViews,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveCreation(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveCreation,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveDebugPoint(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveDebugPoint,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveDestructibleHook(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveDestructibleHook,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveEffect(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveEffect,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveGpsOnVehicle(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveGpsOnVehicle,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveHouse(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveHouse,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveManagedAgent(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveManagedAgent,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveManagedCreation(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveManagedCreation,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveManagedSpirit(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveManagedSpirit,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveNpc(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveNpc,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveNpcChat(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveNpcChat,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveNpcQueueEvent(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveNpcQueueEvent,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveObstacle(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveObstacle,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemovePokemon(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemovePokemon,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveRaidEntity(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveRaidEntity,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveTaskDialogArea(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveTaskDialogArea,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveUnitClientCustomData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveUnitClientCustomData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRemoveUnitState(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRemoveUnitState,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncReplayEffects(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncReplayEffects,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncReportClientCommands(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncReportClientCommands,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncReportDebugLog(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncReportDebugLog,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncReportDeleteClientFile(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncReportDeleteClientFile,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncReportFileSystemDownload(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncReportFileSystemDownload,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncReportFileSystemPath(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncReportFileSystemPath,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncReportFileSystemRoot(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncReportFileSystemRoot,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncReportUploadClientFile(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncReportUploadClientFile,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRequestNpcPos(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRequestNpcPos,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncResetEventConditionProgress(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncResetEventConditionProgress,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncResetNpcEventsTriggerCount(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncResetNpcEventsTriggerCount,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRideAgent(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRideAgent,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRoleList(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRoleList,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRollIntervalMessage(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRollIntervalMessage,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRollIntervalMessageStop(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRollIntervalMessageStop,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRunGmUtils(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRunGmUtils,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncRunningMetroInfos(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncRunningMetroInfos,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSandevistanEnd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSandevistanEnd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSandevistanStart(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSandevistanStart,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSceneFogMapAllUnlock(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSceneFogMapAllUnlock,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSceneItemAddEffectReplace(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSceneItemAddEffectReplace,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSceneItemEffectChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSceneItemEffectChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSceneItemEffectReplaceDic(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSceneItemEffectReplaceDic,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSceneItemLinkOccupantChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSceneItemLinkOccupantChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSceneItemOccupantChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSceneItemOccupantChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSceneItemRemoveEffectReplace(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSceneItemRemoveEffectReplace,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSceneItemSignalSend(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSceneItemSignalSend,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSceneItemStateChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSceneItemStateChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSceneItemValueChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSceneItemValueChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSceneLoadCompleted(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSceneLoadCompleted,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncScenePlayerName(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncScenePlayerName,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSearchSpecialTargetPosition(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSearchSpecialTargetPosition,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSectorControlChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSectorControlChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncServerAvailableState(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncServerAvailableState,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncServerDebug(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncServerDebug,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncServerLog(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncServerLog,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncServerWarn(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncServerWarn,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSetClientObjectValue(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSetClientObjectValue,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSetCrowdDensity(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSetCrowdDensity,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSetDataToOwner(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSetDataToOwner,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSetEffectData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSetEffectData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSetObjectValue(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSetObjectValue,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSetSpiritEnableTryWear(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSetSpiritEnableTryWear,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSetSpiritFashions(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSetSpiritFashions,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSetTaskTryWearFashionInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSetTaskTryWearFashionInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSetVehicleCalImpulse(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSetVehicleCalImpulse,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSetVehicleTrackable(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSetVehicleTrackable,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncShieldBreak(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncShieldBreak,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncShieldOff(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncShieldOff,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncShieldOn(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncShieldOn,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncShieldValue(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncShieldValue,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncShowDebugPoint(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncShowDebugPoint,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncShowDialog(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncShowDialog,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncShowDialogVoice(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncShowDialogVoice,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncShowGuide(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncShowGuide,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncShowMessage(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncShowMessage,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncShowMessage_2(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncShowMessage_2,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncShowTaskMessage(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncShowTaskMessage,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncShowTipMessage(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncShowTipMessage,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncShowWorldEnemyRewardMessage(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncShowWorldEnemyRewardMessage,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSingleControlFlowDebug(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSingleControlFlowDebug,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSmartObjectBs(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSmartObjectBs,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSmartObjectDebugMessage(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSmartObjectDebugMessage,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSoundInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSoundInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpawnPoliceVehicles(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpawnPoliceVehicles,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpawnSurroundNpc(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpawnSurroundNpc,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpawnVehicle(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpawnVehicle,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpecialClientStartHotFixProc(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpecialClientStartHotFixProc,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritAbilities(Connection conn)
        {
            var currentSpirit = conn.GetCurrentSpirit();
            if (currentSpirit == null) return;

            // Send individual ability info for each ability
            foreach (var ability in currentSpirit.SpiritAbilities.Values)
            {
                SendSyncSpiritAbilityInfo(conn, currentSpirit.Id, ability);
            }

            // Also send the full abilities dictionary
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritAbilities,
            };
            
            var args = new SyncSpiritAbilities()
            {
                id = currentSpirit.Id,
                abilities = currentSpirit.SpiritAbilities
            };
            rsp.SetArgs(MethodId.SyncSpiritAbilities, args);
            conn.SendPacket(rsp);
            
            Console.WriteLine($"[Ability] SyncSpiritAbilities sent: spiritId={currentSpirit.Id}, abilities={currentSpirit.SpiritAbilities.Count}");
        }

        internal static void SendSyncSpiritAbility(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritAbility,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritAbilityInfo(Connection conn, ulong spiritId, SpiritAbilityInfo ability)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritAbilityInfo,
            };
            rsp.Args = BitConverter.GetBytes(spiritId);
            rsp.SetArgs(MethodId.SyncSpiritAbilityInfo, ability);
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritAddWeaponAction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritAddWeaponAction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritBadgeInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritBadgeInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritBartenderInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritBartenderInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritBeggarJobData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritBeggarJobData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritCampInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritCampInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritFightStyleChangeAction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritFightStyleChangeAction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritGroupChatInfos(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritGroupChatInfos,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritHackerDailyCount(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritHackerDailyCount,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritHackerJobInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritHackerJobInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritHistoryJobInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritHistoryJobInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritJobInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritJobInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritJobTalentPoint(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritJobTalentPoint,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritMobileSkinPartInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritMobileSkinPartInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritPoliceCaseInfos(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritPoliceCaseInfos,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritPoliceJobInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritPoliceJobInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritPoliceViolationInfos(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritPoliceViolationInfos,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritRemoveWeaponAction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritRemoveWeaponAction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritSwitchWeaponAction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritSwitchWeaponAction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritTalentExpAndLevel(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritTalentExpAndLevel,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritUnitUrbanAttrs(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritUnitUrbanAttrs,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritUpdateWeaponAction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritUpdateWeaponAction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritVirtualFightStyleInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritVirtualFightStyleInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpiritWeaponDetail(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpiritWeaponDetail,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpoonAddControlFlowDebug(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpoonAddControlFlowDebug,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpoonClientActionTrigger(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpoonClientActionTrigger,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpoonClientConditionJudge(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpoonClientConditionJudge,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpoonClientData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpoonClientData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpoonClientSoundTrigger(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpoonClientSoundTrigger,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpoonEnemyPositionCreate(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpoonEnemyPositionCreate,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpoonEventData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpoonEventData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpoonNpcInteractive(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpoonNpcInteractive,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpoonRaidControlFlowsDebug(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpoonRaidControlFlowsDebug,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpoonRoomState(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpoonRoomState,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpoonSingleControlFlowDebug(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpoonSingleControlFlowDebug,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpoonTaskAbortRecover(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpoonTaskAbortRecover,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpoonTaskClientData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpoonTaskClientData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpoonTaskControlFlowsDebug(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpoonTaskControlFlowsDebug,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSpoonValueDicDebug(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSpoonValueDicDebug,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncStartAttract(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStartAttract,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncStartFightStand(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStartFightStand,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncStartHotFixProcess(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStartHotFixProcess,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncStartPatrolInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStartPatrolInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncStartPlayerInteractionAction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStartPlayerInteractionAction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncStartRaidEnemyGroupSound(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStartRaidEnemyGroupSound,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncStartRayCast4D(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStartRayCast4D,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncStartSummonVehicle(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStartSummonVehicle,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncStopBehaviorSeq(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStopBehaviorSeq,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncStopFightStand(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStopFightStand,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncStopShowAction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStopShowAction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncStoryCoreClientDebugInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStoryCoreClientDebugInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncStoryCoreClientDebugInfoGM(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStoryCoreClientDebugInfoGM,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncStoryCoreClientInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStoryCoreClientInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncStoryCoreMessage(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStoryCoreMessage,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSubwayFare(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSubwayFare,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSwitchControl(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSwitchControl,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSwitchSceneFailed(Connection conn, uint raidId, uint errorId)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSwitchSceneFailed,
            };
            rsp.SetArgs(MethodId.SyncSwitchSceneFailed, new SyncSwitchSceneFailed()
            {
                raidId = raidId,
                errorId = errorId
            });
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSwitchSpiritConfigId(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSwitchSpiritConfigId,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSyncRateLevelUp(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSyncRateLevelUp,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTaskAcceptFailedDebug(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTaskAcceptFailedDebug,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTaskInviteRideNpcCultivation(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTaskInviteRideNpcCultivation,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTaskRoleTeam(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTaskRoleTeam,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTaskRoomAdd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTaskRoomAdd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTaskRoomRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTaskRoomRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTaskSpoonResourceLoaded(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTaskSpoonResourceLoaded,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTaskSpoonVehicleIdDict(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTaskSpoonVehicleIdDict,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTaskTitleGuideUnlock(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTaskTitleGuideUnlock,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTaskWaitResourceLoad(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTaskWaitResourceLoad,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTaxiReachDestination(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTaxiReachDestination,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTeleportVehicle(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTeleportVehicle,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTemporaryCurrentTask(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTemporaryCurrentTask,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncThreatDebugData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncThreatDebugData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncToggleUnitMiniMapHostileIcon(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncToggleUnitMiniMapHostileIcon,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTraceGpsInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTraceGpsInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTruckAbortedOrder(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTruckAbortedOrder,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTruckHighValueOrder(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTruckHighValueOrder,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTruckOrderResult(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTruckOrderResult,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTruckOrdersNewDay(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTruckOrdersNewDay,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTruckOrderWrap(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTruckOrderWrap,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTupoChangeInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTupoChangeInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTurnToPosPosition(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTurnToPosPosition,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncTwitterMonitoredBehaviors(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncTwitterMonitoredBehaviors,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnbindNpcToMetro(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnbindNpcToMetro,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitAddBuff(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitAddBuff,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitAttacked(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitAttacked,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitAttr(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitAttr,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitAttrs(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitAttrs,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitBoardingInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitBoardingInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitBuffList(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitBuffList,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitBuffListDebug(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitBuffListDebug,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitChat(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitChat,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitClientCustomData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitClientCustomData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitDetectSwitch(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitDetectSwitch,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitElement3(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitElement3,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitFacingDirection(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitFacingDirection,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitHeal(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitHeal,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitHp(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitHp,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitHurtEffect(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitHurtEffect,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitLockTarget(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitLockTarget,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitMoveAction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitMoveAction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitMovedByPlot(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitMovedByPlot,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitMoveToPointFloating(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitMoveToPointFloating,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitMoveTowardUnit(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitMoveTowardUnit,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitNavTags(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitNavTags,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitOccur(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitOccur,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitPosition_P(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitPosition_P,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitPositionAndFacing(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitPositionAndFacing,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitRemoveBuff(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitRemoveBuff,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitSay(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitSay,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitSmoothFace(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitSmoothFace,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitSmoothFaceToTarget(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitSmoothFaceToTarget,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitStates(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitStates,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitStopSmoothFace(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitStopSmoothFace,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitUpdateBuff(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitUpdateBuff,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitVehicleStatus(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitVehicleStatus,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnitVelocityAddition(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnitVelocityAddition,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnlockBartender(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnlockBartender,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnlockInteractionActionItems(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnlockInteractionActionItems,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnlockPhoneContactOptions(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnlockPhoneContactOptions,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnlockSystems(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnlockSystems,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUnSetTaskTryWearFashionInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUnSetTaskTryWearFashionInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUpdateDebugPointDetail(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUpdateDebugPointDetail,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUpdatePokemonLockState(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUpdatePokemonLockState,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUploadClientFile(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUploadClientFile,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUrbanBadgeInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUrbanBadgeInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUseSkill(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUseSkill,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncUseTargetSkill(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncUseTargetSkill,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncVehicleAddBuff(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncVehicleAddBuff,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncVehicleAIMovementOverride(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncVehicleAIMovementOverride,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncVehicleBrokenCollision(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncVehicleBrokenCollision,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncVehicleBuffList(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncVehicleBuffList,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncVehicleContactDamage(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncVehicleContactDamage,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncVehicleDangerZone(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncVehicleDangerZone,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncVehicleDatas(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncVehicleDatas,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncVehicleGameplayDamageAction(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncVehicleGameplayDamageAction,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncVehicleHorn(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncVehicleHorn,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncVehicleMove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncVehicleMove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncVehiclePartStatus(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncVehiclePartStatus,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncVehiclePlayAnimation(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncVehiclePlayAnimation,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncVehicleRemoveBuff(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncVehicleRemoveBuff,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncVehicleSkillDamage(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncVehicleSkillDamage,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncVehicleStartAI(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncVehicleStartAI,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncWasherMissionResult(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncWasherMissionResult,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncWatchingPlayer(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncWatchingPlayer,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncWatchInteractionInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncWatchInteractionInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncWeaponDurabilityChanged(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncWeaponDurabilityChanged,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncWeaponsSceneItemHpChanged(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncWeaponsSceneItemHpChanged,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncWildEnemyGroupCheckTime(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncWildEnemyGroupCheckTime,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncWorldBattlePlayers(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncWorldBattlePlayers,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncWorldBossStateChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncWorldBossStateChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncWorldReady(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncWorldReady,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncWorldRewardTriggeredInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncWorldRewardTriggeredInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncXinshouSectorState(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncXinshouSectorState,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncExitHelicopterView(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncExitHelicopterView,
            };
            conn.SendPacket(rsp);
        }

    }
}
