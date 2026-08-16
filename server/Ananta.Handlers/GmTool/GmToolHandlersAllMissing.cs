using System;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    internal class GmToolHandlersAllMissing
    {
        private static void SendEmptySuccessReturn(Connection conn, UxRpcMessage msg, MethodId methodId)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)methodId,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GmBreakdownItems)]
        public static void GmBreakdownItemsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmBreakdownItems called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmBreakdownItems);
        }

        [Handler(MethodId.GmCancelPlayerInteractionAction)]
        public static void GmCancelPlayerInteractionActionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmCancelPlayerInteractionAction called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmCancelPlayerInteractionAction);
        }

        [Handler(MethodId.GmCBT)]
        public static void GmCBTHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmCBT called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmCBT);
        }

        [Handler(MethodId.GmCBTAll)]
        public static void GmCBTAllHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmCBTAll called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmCBTAll);
        }

        [Handler(MethodId.GmChangeAgentBehaviorTree)]
        public static void GmChangeAgentBehaviorTreeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmChangeAgentBehaviorTree called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmChangeAgentBehaviorTree);
        }

        [Handler(MethodId.GmChangeAgentWeapon)]
        public static void GmChangeAgentWeaponHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmChangeAgentWeapon called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmChangeAgentWeapon);
        }

        [Handler(MethodId.GmChangeBuildHouseIndoor)]
        public static void GmChangeBuildHouseIndoorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmChangeBuildHouseIndoor called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmChangeBuildHouseIndoor);
        }

        [Handler(MethodId.GMChangeFightStyle)]
        public static void GMChangeFightStyleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMChangeFightStyle called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMChangeFightStyle);
        }

        [Handler(MethodId.GmChangeIndoor)]
        public static void GmChangeIndoorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmChangeIndoor called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmChangeIndoor);
        }

        [Handler(MethodId.GmChangeName)]
        public static void GmChangeNameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmChangeName called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmChangeName);
        }

        [Handler(MethodId.GmChangeNpcInteractPoint)]
        public static void GmChangeNpcInteractPointHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmChangeNpcInteractPoint called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmChangeNpcInteractPoint);
        }

        [Handler(MethodId.GmChangeRoomSetting)]
        public static void GmChangeRoomSettingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmChangeRoomSetting called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmChangeRoomSetting);
        }

        [Handler(MethodId.GmChangeSafeArea)]
        public static void GmChangeSafeAreaHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmChangeSafeArea called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmChangeSafeArea);
        }

        [Handler(MethodId.GmChangeSectorControl)]
        public static void GmChangeSectorControlHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmChangeSectorControl called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmChangeSectorControl);
        }

        [Handler(MethodId.GmChangeSpiritJobTalentPoint)]
        public static void GmChangeSpiritJobTalentPointHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmChangeSpiritJobTalentPoint called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmChangeSpiritJobTalentPoint);
        }

        [Handler(MethodId.GmChangeWorldState)]
        public static void GmChangeWorldStateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmChangeWorldState called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmChangeWorldState);
        }

        [Handler(MethodId.GmChaosMasterGacha)]
        public static void GmChaosMasterGachaHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmChaosMasterGacha called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmChaosMasterGacha);
        }

        [Handler(MethodId.GmChargeClientShip)]
        public static void GmChargeClientShipHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmChargeClientShip called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmChargeClientShip);
        }

        [Handler(MethodId.GmChargeGetBillInfos)]
        public static void GmChargeGetBillInfosHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmChargeGetBillInfos called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmChargeGetBillInfos);
        }

        [Handler(MethodId.GmChargeJellyShip)]
        public static void GmChargeJellyShipHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmChargeJellyShip called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmChargeJellyShip);
        }

        [Handler(MethodId.GmChargeQueryCreateOrder)]
        public static void GmChargeQueryCreateOrderHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmChargeQueryCreateOrder called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmChargeQueryCreateOrder);
        }

        [Handler(MethodId.GmChoosePartyNPC)]
        public static void GmChoosePartyNPCHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmChoosePartyNPC called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmChoosePartyNPC);
        }

        [Handler(MethodId.GmCleanPackages)]
        public static void GmCleanPackagesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmCleanPackages called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmCleanPackages);
        }

        [Handler(MethodId.GmClearAllAchievement)]
        public static void GmClearAllAchievementHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearAllAchievement called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearAllAchievement);
        }

        [Handler(MethodId.GmClearAllDeviceBinding)]
        public static void GmClearAllDeviceBindingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearAllDeviceBinding called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearAllDeviceBinding);
        }

        [Handler(MethodId.GmClearAllLinkDuty)]
        public static void GmClearAllLinkDutyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearAllLinkDuty called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearAllLinkDuty);
        }

        [Handler(MethodId.GmClearAllSubQuest)]
        public static void GmClearAllSubQuestHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearAllSubQuest called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearAllSubQuest);
        }

        [Handler(MethodId.GmClearBartenderGame)]
        public static void GmClearBartenderGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearBartenderGame called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearBartenderGame);
        }

        [Handler(MethodId.GmClearBattleStatisticsData)]
        public static void GmClearBattleStatisticsDataHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearBattleStatisticsData called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearBattleStatisticsData);
        }

        [Handler(MethodId.GmClearBehaviorBreakPoint)]
        public static void GmClearBehaviorBreakPointHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearBehaviorBreakPoint called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearBehaviorBreakPoint);
        }

        [Handler(MethodId.GmClearChallengeRecord)]
        public static void GmClearChallengeRecordHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearChallengeRecord called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearChallengeRecord);
        }

        [Handler(MethodId.GmClearCharacterDialogRecord)]
        public static void GmClearCharacterDialogRecordHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearCharacterDialogRecord called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearCharacterDialogRecord);
        }

        [Handler(MethodId.GmClearDailyChatInfo)]
        public static void GmClearDailyChatInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearDailyChatInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearDailyChatInfo);
        }

        [Handler(MethodId.GmClearDailyRewards)]
        public static void GmClearDailyRewardsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearDailyRewards called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearDailyRewards);
        }

        [Handler(MethodId.GmClearDialog)]
        public static void GmClearDialogHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearDialog called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearDialog);
        }

        [Handler(MethodId.GmClearDialogNpcChat)]
        public static void GmClearDialogNpcChatHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearDialogNpcChat called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearDialogNpcChat);
        }

        [Handler(MethodId.GmClearDropLimit)]
        public static void GmClearDropLimitHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearDropLimit called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearDropLimit);
        }

        [Handler(MethodId.GmClearFerrisWheelTickets)]
        public static void GmClearFerrisWheelTicketsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearFerrisWheelTickets called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearFerrisWheelTickets);
        }

        [Handler(MethodId.GmClearFirstKillEnemyRecord)]
        public static void GmClearFirstKillEnemyRecordHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearFirstKillEnemyRecord called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearFirstKillEnemyRecord);
        }

        [Handler(MethodId.GmClearGmAttractPoint)]
        public static void GmClearGmAttractPointHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearGmAttractPoint called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearGmAttractPoint);
        }

        [Handler(MethodId.GmClearGuides)]
        public static void GmClearGuidesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearGuides called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearGuides);
        }

        [Handler(MethodId.GmClearGuideTeach)]
        public static void GmClearGuideTeachHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearGuideTeach called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearGuideTeach);
        }

        [Handler(MethodId.GmClearItemRecord)]
        public static void GmClearItemRecordHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearItemRecord called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearItemRecord);
        }

        [Handler(MethodId.GMClearLockedNpcCardInfo)]
        public static void GMClearLockedNpcCardInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMClearLockedNpcCardInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMClearLockedNpcCardInfo);
        }

        [Handler(MethodId.GmClearMilkNpcFavor)]
        public static void GmClearMilkNpcFavorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearMilkNpcFavor called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearMilkNpcFavor);
        }

        [Handler(MethodId.GmClearNpcChatInfo)]
        public static void GmClearNpcChatInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearNpcChatInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearNpcChatInfo);
        }

        [Handler(MethodId.GmClearNpcGroupChatInfo)]
        public static void GmClearNpcGroupChatInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearNpcGroupChatInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearNpcGroupChatInfo);
        }

        [Handler(MethodId.GmClearNpcTuite)]
        public static void GmClearNpcTuiteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearNpcTuite called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearNpcTuite);
        }

        [Handler(MethodId.GmClearPopularity)]
        public static void GmClearPopularityHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearPopularity called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearPopularity);
        }

        [Handler(MethodId.GmClearPostInfo)]
        public static void GmClearPostInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearPostInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearPostInfo);
        }

        [Handler(MethodId.GMClearPSNBlackList)]
        public static void GMClearPSNBlackListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMClearPSNBlackList called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMClearPSNBlackList);
        }

        [Handler(MethodId.GmClearSignRecord)]
        public static void GmClearSignRecordHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearSignRecord called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearSignRecord);
        }

        [Handler(MethodId.GmClearSkey)]
        public static void GmClearSkeyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearSkey called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearSkey);
        }

        [Handler(MethodId.GmClearStoryCache)]
        public static void GmClearStoryCacheHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearStoryCache called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearStoryCache);
        }

        [Handler(MethodId.GmClearTempSpirits)]
        public static void GmClearTempSpiritsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearTempSpirits called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearTempSpirits);
        }

        [Handler(MethodId.GmClearTruckJobOrders)]
        public static void GmClearTruckJobOrdersHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearTruckJobOrders called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearTruckJobOrders);
        }

        [Handler(MethodId.GmClearWeaponSlot)]
        public static void GmClearWeaponSlotHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClearWeaponSlot called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClearWeaponSlot);
        }

        [Handler(MethodId.GmClientDialogFinish)]
        public static void GmClientDialogFinishHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClientDialogFinish called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClientDialogFinish);
        }

        [Handler(MethodId.GmClientInputSpoonTest)]
        public static void GmClientInputSpoonTestHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmClientInputSpoonTest called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmClientInputSpoonTest);
        }

        [Handler(MethodId.GmCompleteAgentProfileTarget)]
        public static void GmCompleteAgentProfileTargetHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmCompleteAgentProfileTarget called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmCompleteAgentProfileTarget);
        }

        [Handler(MethodId.GmCompletedSubQuest)]
        public static void GmCompletedSubQuestHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmCompletedSubQuest called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmCompletedSubQuest);
        }

        [Handler(MethodId.GmCompleteTruckJobOrder)]
        public static void GmCompleteTruckJobOrderHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmCompleteTruckJobOrder called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmCompleteTruckJobOrder);
        }

        [Handler(MethodId.GmCompleteUrbanPlay)]
        public static void GmCompleteUrbanPlayHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmCompleteUrbanPlay called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmCompleteUrbanPlay);
        }

        [Handler(MethodId.GmConfirmDutySwap)]
        public static void GmConfirmDutySwapHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmConfirmDutySwap called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmConfirmDutySwap);
        }

        [Handler(MethodId.GmConfirmMatchResult)]
        public static void GmConfirmMatchResultHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmConfirmMatchResult called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmConfirmMatchResult);
        }

        [Handler(MethodId.GmControlEnemyBattleMove)]
        public static void GmControlEnemyBattleMoveHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmControlEnemyBattleMove called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmControlEnemyBattleMove);
        }

        [Handler(MethodId.GmConvertAetherNpcToPureAgent)]
        public static void GmConvertAetherNpcToPureAgentHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmConvertAetherNpcToPureAgent called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmConvertAetherNpcToPureAgent);
        }

        [Handler(MethodId.GmConvertCommonSpiritTalentExp)]
        public static void GmConvertCommonSpiritTalentExpHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmConvertCommonSpiritTalentExp called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmConvertCommonSpiritTalentExp);
        }

        [Handler(MethodId.GmCreateAiOnVehicle)]
        public static void GmCreateAiOnVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmCreateAiOnVehicle called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmCreateAiOnVehicle);
        }

        [Handler(MethodId.GmCreateAndAcceptTruckJobOrder)]
        public static void GmCreateAndAcceptTruckJobOrderHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmCreateAndAcceptTruckJobOrder called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmCreateAndAcceptTruckJobOrder);
        }

        [Handler(MethodId.GmCreateGadget)]
        public static void GmCreateGadgetHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmCreateGadget called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmCreateGadget);
        }

        [Handler(MethodId.GmCreateStaticNpcOnChair)]
        public static void GmCreateStaticNpcOnChairHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmCreateStaticNpcOnChair called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmCreateStaticNpcOnChair);
        }

        [Handler(MethodId.GmCreateTaskAiVehicle)]
        public static void GmCreateTaskAiVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmCreateTaskAiVehicle called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmCreateTaskAiVehicle);
        }

        [Handler(MethodId.GmCreateTeam)]
        public static void GmCreateTeamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmCreateTeam called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmCreateTeam);
        }

        [Handler(MethodId.GmDaVinciCode)]
        public static void GmDaVinciCodeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDaVinciCode called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDaVinciCode);
        }

        [Handler(MethodId.GmDebugAllDestructible)]
        public static void GmDebugAllDestructibleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDebugAllDestructible called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDebugAllDestructible);
        }

        [Handler(MethodId.GmDebugAllGadget)]
        public static void GmDebugAllGadgetHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDebugAllGadget called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDebugAllGadget);
        }

        [Handler(MethodId.GmDebugReserveGpuDumps)]
        public static void GmDebugReserveGpuDumpsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDebugReserveGpuDumps called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDebugReserveGpuDumps);
        }

        [Handler(MethodId.GmDeleteDMOverride)]
        public static void GmDeleteDMOverrideHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDeleteDMOverride called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDeleteDMOverride);
        }

        [Handler(MethodId.GmDeleteGlobalLazyMail)]
        public static void GmDeleteGlobalLazyMailHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDeleteGlobalLazyMail called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDeleteGlobalLazyMail);
        }

        [Handler(MethodId.GmDeletePlayer)]
        public static void GmDeletePlayerHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDeletePlayer called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDeletePlayer);
        }

        [Handler(MethodId.GmDeletePlayerMail)]
        public static void GmDeletePlayerMailHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDeletePlayerMail called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDeletePlayerMail);
        }

        [Handler(MethodId.GmDisableIndoorSectorIds)]
        public static void GmDisableIndoorSectorIdsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDisableIndoorSectorIds called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDisableIndoorSectorIds);
        }

        [Handler(MethodId.GmDisableMapEntranceType)]
        public static void GmDisableMapEntranceTypeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDisableMapEntranceType called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDisableMapEntranceType);
        }

        [Handler(MethodId.GmDivinerAIChat)]
        public static void GmDivinerAIChatHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDivinerAIChat called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDivinerAIChat);
        }

        [Handler(MethodId.GmDMEMOverride)]
        public static void GmDMEMOverrideHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDMEMOverride called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDMEMOverride);
        }

        [Handler(MethodId.GmDoctorCure)]
        public static void GmDoctorCureHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDoctorCure called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDoctorCure);
        }

        [Handler(MethodId.GmDoctorDeathStart)]
        public static void GmDoctorDeathStartHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDoctorDeathStart called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDoctorDeathStart);
        }

        [Handler(MethodId.GmDonateFactionByCfgId)]
        public static void GmDonateFactionByCfgIdHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDonateFactionByCfgId called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDonateFactionByCfgId);
        }

        [Handler(MethodId.GmDonateFactionByMoney)]
        public static void GmDonateFactionByMoneyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDonateFactionByMoney called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDonateFactionByMoney);
        }

        [Handler(MethodId.GmDoResetAccept)]
        public static void GmDoResetAcceptHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDoResetAccept called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDoResetAccept);
        }

        [Handler(MethodId.GmDotnetDump)]
        public static void GmDotnetDumpHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDotnetDump called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDotnetDump);
        }

        [Handler(MethodId.GmDrawGacha)]
        public static void GmDrawGachaHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDrawGacha called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDrawGacha);
        }

        [Handler(MethodId.GmDropEnemyWeapon)]
        public static void GmDropEnemyWeaponHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDropEnemyWeapon called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDropEnemyWeapon);
        }

        [Handler(MethodId.GmDropReward)]
        public static void GmDropRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmDropReward called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmDropReward);
        }

        [Handler(MethodId.GmEditSpiritFashionTransform)]
        public static void GmEditSpiritFashionTransformHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEditSpiritFashionTransform called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEditSpiritFashionTransform);
        }

        [Handler(MethodId.GmEnableAllFileWatch)]
        public static void GmEnableAllFileWatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEnableAllFileWatch called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEnableAllFileWatch);
        }

        [Handler(MethodId.GmEnableClientSpiritFashionTryWe)]
        public static void GmEnableClientSpiritFashionTryWeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEnableClientSpiritFashionTryWe called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEnableClientSpiritFashionTryWe);
        }

        [Handler(MethodId.GmEnableIndoorSectorIds)]
        public static void GmEnableIndoorSectorIdsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEnableIndoorSectorIds called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEnableIndoorSectorIds);
        }

        [Handler(MethodId.GmEnableOxygenSystem)]
        public static void GmEnableOxygenSystemHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEnableOxygenSystem called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEnableOxygenSystem);
        }

        [Handler(MethodId.GmEnableRandomEvent)]
        public static void GmEnableRandomEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEnableRandomEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEnableRandomEvent);
        }

        [Handler(MethodId.GmEnableThreatDebug)]
        public static void GmEnableThreatDebugHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEnableThreatDebug called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEnableThreatDebug);
        }

        [Handler(MethodId.GMEnableVehicleEscapeDebug)]
        public static void GMEnableVehicleEscapeDebugHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMEnableVehicleEscapeDebug called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMEnableVehicleEscapeDebug);
        }

        [Handler(MethodId.GmEndAIDebug)]
        public static void GmEndAIDebugHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEndAIDebug called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEndAIDebug);
        }

        [Handler(MethodId.GmEndEnemyDetectDebug)]
        public static void GmEndEnemyDetectDebugHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEndEnemyDetectDebug called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEndEnemyDetectDebug);
        }

        [Handler(MethodId.GmEndEnemyDetectStateDebug)]
        public static void GmEndEnemyDetectStateDebugHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEndEnemyDetectStateDebug called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEndEnemyDetectStateDebug);
        }

        [Handler(MethodId.GmEndEnemyGroupDebug)]
        public static void GmEndEnemyGroupDebugHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEndEnemyGroupDebug called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEndEnemyGroupDebug);
        }

        [Handler(MethodId.GmEndEnemyStrategyDebug)]
        public static void GmEndEnemyStrategyDebugHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEndEnemyStrategyDebug called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEndEnemyStrategyDebug);
        }

        [Handler(MethodId.GmEndSyncAIAction)]
        public static void GmEndSyncAIActionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEndSyncAIAction called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEndSyncAIAction);
        }

        [Handler(MethodId.GMEndWatchOtherPlayer)]
        public static void GMEndWatchOtherPlayerHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMEndWatchOtherPlayer called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMEndWatchOtherPlayer);
        }

        [Handler(MethodId.GmEnemyAiStopFlagByCamp)]
        public static void GmEnemyAiStopFlagByCampHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEnemyAiStopFlagByCamp called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEnemyAiStopFlagByCamp);
        }

        [Handler(MethodId.GmEnterBowlingZone)]
        public static void GmEnterBowlingZoneHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEnterBowlingZone called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEnterBowlingZone);
        }

        [Handler(MethodId.GmEnterGomokuZoneDoubleAI)]
        public static void GmEnterGomokuZoneDoubleAIHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEnterGomokuZoneDoubleAI called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEnterGomokuZoneDoubleAI);
        }

        [Handler(MethodId.GmEnterGomokuZoneEndGame)]
        public static void GmEnterGomokuZoneEndGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEnterGomokuZoneEndGame called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEnterGomokuZoneEndGame);
        }

        [Handler(MethodId.GmEventConditionFinishModuleProg)]
        public static void GmEventConditionFinishModuleProgHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEventConditionFinishModuleProg called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEventConditionFinishModuleProg);
        }

        [Handler(MethodId.GmEventConditionGetInfos)]
        public static void GmEventConditionGetInfosHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEventConditionGetInfos called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEventConditionGetInfos);
        }

        [Handler(MethodId.GmEventConditionNotifyEvent)]
        public static void GmEventConditionNotifyEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEventConditionNotifyEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEventConditionNotifyEvent);
        }

        [Handler(MethodId.GmEventConditionResetModuleProgr)]
        public static void GmEventConditionResetModuleProgrHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEventConditionResetModuleProgr called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEventConditionResetModuleProgr);
        }

        [Handler(MethodId.GmEventUnlock)]
        public static void GmEventUnlockHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEventUnlock called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEventUnlock);
        }

        [Handler(MethodId.GmFakeFileAcceptTaskEvent)]
        public static void GmFakeFileAcceptTaskEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmFakeFileAcceptTaskEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmFakeFileAcceptTaskEvent);
        }

        [Handler(MethodId.GmFastZengFu)]
        public static void GmFastZengFuHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmFastZengFu called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmFastZengFu);
        }

        [Handler(MethodId.GmFillPlayerData)]
        public static void GmFillPlayerDataHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmFillPlayerData called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmFillPlayerData);
        }

        [Handler(MethodId.GmFinishAchievement)]
        public static void GmFinishAchievementHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmFinishAchievement called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmFinishAchievement);
        }

        [Handler(MethodId.GmFinishAchievementCategory)]
        public static void GmFinishAchievementCategoryHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmFinishAchievementCategory called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmFinishAchievementCategory);
        }

        [Handler(MethodId.GmFinishAllGuides)]
        public static void GmFinishAllGuidesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmFinishAllGuides called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmFinishAllGuides);
        }

        [Handler(MethodId.GmFinishTaskCounter)]
        public static void GmFinishTaskCounterHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmFinishTaskCounter called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmFinishTaskCounter);
        }

        [Handler(MethodId.GmFireworkUnLockPlan)]
        public static void GmFireworkUnLockPlanHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmFireworkUnLockPlan called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmFireworkUnLockPlan);
        }

        [Handler(MethodId.GmFixFrame)]
        public static void GmFixFrameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmFixFrame called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmFixFrame);
        }

        [Handler(MethodId.GmFollowTeamLeader)]
        public static void GmFollowTeamLeaderHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmFollowTeamLeader called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmFollowTeamLeader);
        }

        [Handler(MethodId.GmForceFollowPlayer)]
        public static void GmForceFollowPlayerHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmForceFollowPlayer called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmForceFollowPlayer);
        }

        [Handler(MethodId.GmForceSetSwitchSpiritConfig)]
        public static void GmForceSetSwitchSpiritConfigHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmForceSetSwitchSpiritConfig called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmForceSetSwitchSpiritConfig);
        }

        [Handler(MethodId.GmForwardILFixPatch)]
        public static void GmForwardILFixPatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmForwardILFixPatch called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmForwardILFixPatch);
        }

        [Handler(MethodId.GmGameBalanceResetStatistics)]
        public static void GmGameBalanceResetStatisticsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGameBalanceResetStatistics called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGameBalanceResetStatistics);
        }

        [Handler(MethodId.GmGameEnd)]
        public static void GmGameEndHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGameEnd called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGameEnd);
        }

        [Handler(MethodId.GmGangBossKillMember)]
        public static void GmGangBossKillMemberHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGangBossKillMember called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGangBossKillMember);
        }

        [Handler(MethodId.GmGangBossLockGangMember)]
        public static void GmGangBossLockGangMemberHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGangBossLockGangMember called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGangBossLockGangMember);
        }

        [Handler(MethodId.GmGangBossSetSummonLimitNum)]
        public static void GmGangBossSetSummonLimitNumHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGangBossSetSummonLimitNum called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGangBossSetSummonLimitNum);
        }

        [Handler(MethodId.GmGangBossUnlockAllGangMember)]
        public static void GmGangBossUnlockAllGangMemberHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGangBossUnlockAllGangMember called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGangBossUnlockAllGangMember);
        }

        [Handler(MethodId.GmGangBossUnlockGangMember)]
        public static void GmGangBossUnlockGangMemberHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGangBossUnlockGangMember called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGangBossUnlockGangMember);
        }

        [Handler(MethodId.GmGenMassNpcIds)]
        public static void GmGenMassNpcIdsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGenMassNpcIds called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGenMassNpcIds);
        }

        [Handler(MethodId.GmGetAllNodesNexts)]
        public static void GmGetAllNodesNextsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGetAllNodesNexts called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGetAllNodesNexts);
        }

        [Handler(MethodId.GmGetAllWorkActionNodes)]
        public static void GmGetAllWorkActionNodesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGetAllWorkActionNodes called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGetAllWorkActionNodes);
        }

        [Handler(MethodId.GmGetDestructibleInfo)]
        public static void GmGetDestructibleInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGetDestructibleInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGetDestructibleInfo);
        }

        [Handler(MethodId.GmGetFakeFileInfo)]
        public static void GmGetFakeFileInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGetFakeFileInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGetFakeFileInfo);
        }

        [Handler(MethodId.GmGetHousesInfo)]
        public static void GmGetHousesInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGetHousesInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGetHousesInfo);
        }

        [Handler(MethodId.GmGetLuaString)]
        public static void GmGetLuaStringHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGetLuaString called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGetLuaString);
        }

        [Handler(MethodId.GmGetPlayerDumpInfo)]
        public static void GmGetPlayerDumpInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGetPlayerDumpInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGetPlayerDumpInfo);
        }

        [Handler(MethodId.GmGetPlayerFashionsInfo)]
        public static void GmGetPlayerFashionsInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGetPlayerFashionsInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGetPlayerFashionsInfo);
        }

        [Handler(MethodId.GMGetPSNBlackList)]
        public static void GMGetPSNBlackListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMGetPSNBlackList called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMGetPSNBlackList);
        }

        [Handler(MethodId.GmGetSceneNpcInfo4AutoQA)]
        public static void GmGetSceneNpcInfo4AutoQAHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGetSceneNpcInfo4AutoQA called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGetSceneNpcInfo4AutoQA);
        }

        [Handler(MethodId.GmGetScenePlayerCount)]
        public static void GmGetScenePlayerCountHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGetScenePlayerCount called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGetScenePlayerCount);
        }

        [Handler(MethodId.GmGetServerTime)]
        public static void GmGetServerTimeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGetServerTime called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGetServerTime);
        }

        [Handler(MethodId.GmGetTaskAllNodesName)]
        public static void GmGetTaskAllNodesNameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGetTaskAllNodesName called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGetTaskAllNodesName);
        }

        [Handler(MethodId.GmGetTaskEventNodes)]
        public static void GmGetTaskEventNodesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGetTaskEventNodes called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGetTaskEventNodes);
        }

        [Handler(MethodId.GmGetTruckJobOrders)]
        public static void GmGetTruckJobOrdersHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGetTruckJobOrders called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGetTruckJobOrders);
        }

        [Handler(MethodId.GmGoToNextFrame)]
        public static void GmGoToNextFrameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmGoToNextFrame called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmGoToNextFrame);
        }

        [Handler(MethodId.GmHouseCancelParking)]
        public static void GmHouseCancelParkingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmHouseCancelParking called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmHouseCancelParking);
        }

        [Handler(MethodId.GmHouseParking)]
        public static void GmHouseParkingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmHouseParking called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmHouseParking);
        }

        [Handler(MethodId.GmHouseVisit)]
        public static void GmHouseVisitHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmHouseVisit called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmHouseVisit);
        }

        [Handler(MethodId.GmInjectFixPatch)]
        public static void GmInjectFixPatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmInjectFixPatch called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmInjectFixPatch);
        }

        [Handler(MethodId.GmInspireHubChangeGamePlayJoinCo)]
        public static void GmInspireHubChangeGamePlayJoinCoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmInspireHubChangeGamePlayJoinCo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmInspireHubChangeGamePlayJoinCo);
        }

        [Handler(MethodId.GMInteractNpcWithGift)]
        public static void GMInteractNpcWithGiftHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMInteractNpcWithGift called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMInteractNpcWithGift);
        }

        [Handler(MethodId.GMInteractNpcWithGiftList)]
        public static void GMInteractNpcWithGiftListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMInteractNpcWithGiftList called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMInteractNpcWithGiftList);
        }

        [Handler(MethodId.GmInviteFriendToRoom)]
        public static void GmInviteFriendToRoomHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmInviteFriendToRoom called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmInviteFriendToRoom);
        }

        [Handler(MethodId.GmInviteFriendToRoomAll)]
        public static void GmInviteFriendToRoomAllHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmInviteFriendToRoomAll called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmInviteFriendToRoomAll);
        }

        [Handler(MethodId.GmInviteNpcChat)]
        public static void GmInviteNpcChatHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmInviteNpcChat called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmInviteNpcChat);
        }

        [Handler(MethodId.GmInvitePlayerInteractionAction)]
        public static void GmInvitePlayerInteractionActionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmInvitePlayerInteractionAction called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmInvitePlayerInteractionAction);
        }

        [Handler(MethodId.GmInviteTeam)]
        public static void GmInviteTeamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmInviteTeam called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmInviteTeam);
        }

        [Handler(MethodId.GmIsGameUnlock)]
        public static void GmIsGameUnlockHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmIsGameUnlock called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmIsGameUnlock);
        }

        [Handler(MethodId.GmItemExchange)]
        public static void GmItemExchangeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmItemExchange called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmItemExchange);
        }

        [Handler(MethodId.GmJobEnd)]
        public static void GmJobEndHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmJobEnd called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmJobEnd);
        }

        [Handler(MethodId.GmJobPromote)]
        public static void GmJobPromoteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmJobPromote called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmJobPromote);
        }

        [Handler(MethodId.GmJobQuit)]
        public static void GmJobQuitHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmJobQuit called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmJobQuit);
        }

        [Handler(MethodId.GmJobStart)]
        public static void GmJobStartHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmJobStart called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmJobStart);
        }

        [Handler(MethodId.GmJobTake)]
        public static void GmJobTakeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmJobTake called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmJobTake);
        }

        [Handler(MethodId.GMJoinLinkByPid)]
        public static void GMJoinLinkByPidHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMJoinLinkByPid called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMJoinLinkByPid);
        }

        [Handler(MethodId.GmKickAll)]
        public static void GmKickAllHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmKickAll called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmKickAll);
        }

        [Handler(MethodId.GmKickFriendInRoom)]
        public static void GmKickFriendInRoomHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmKickFriendInRoom called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmKickFriendInRoom);
        }

        [Handler(MethodId.GmKickMe)]
        public static void GmKickMeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmKickMe called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmKickMe);
        }

        [Handler(MethodId.GmKickMyself)]
        public static void GmKickMyselfHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmKickMyself called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmKickMyself);
        }

        [Handler(MethodId.GmKickTeamMember)]
        public static void GmKickTeamMemberHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmKickTeamMember called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmKickTeamMember);
        }

        [Handler(MethodId.GmKillNearestGadget)]
        public static void GmKillNearestGadgetHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmKillNearestGadget called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmKillNearestGadget);
        }

        [Handler(MethodId.GmLeaveBowling)]
        public static void GmLeaveBowlingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLeaveBowling called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLeaveBowling);
        }

        [Handler(MethodId.GmLeaveGame)]
        public static void GmLeaveGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLeaveGame called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLeaveGame);
        }

        [Handler(MethodId.GmLeaveGomoku)]
        public static void GmLeaveGomokuHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLeaveGomoku called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLeaveGomoku);
        }

        [Handler(MethodId.GmLeaveRoom)]
        public static void GmLeaveRoomHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLeaveRoom called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLeaveRoom);
        }

        [Handler(MethodId.GmLeaveScene)]
        public static void GmLeaveSceneHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLeaveScene called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLeaveScene);
        }

        [Handler(MethodId.GmLeaveTeam)]
        public static void GmLeaveTeamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLeaveTeam called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLeaveTeam);
        }

        [Handler(MethodId.GmLinkAddAllMembersSyncRate)]
        public static void GmLinkAddAllMembersSyncRateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLinkAddAllMembersSyncRate called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLinkAddAllMembersSyncRate);
        }

        [Handler(MethodId.GmLinkAddSyncRate)]
        public static void GmLinkAddSyncRateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLinkAddSyncRate called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLinkAddSyncRate);
        }

        [Handler(MethodId.GmLinkCreditReset)]
        public static void GmLinkCreditResetHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLinkCreditReset called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLinkCreditReset);
        }

        [Handler(MethodId.GmLinkInfo)]
        public static void GmLinkInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLinkInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLinkInfo);
        }

        [Handler(MethodId.GmLinkInfos)]
        public static void GmLinkInfosHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLinkInfos called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLinkInfos);
        }

        [Handler(MethodId.GmLinkInvite)]
        public static void GmLinkInviteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLinkInvite called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLinkInvite);
        }

        [Handler(MethodId.GmLinkKick)]
        public static void GmLinkKickHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLinkKick called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLinkKick);
        }

        [Handler(MethodId.GmLinkLeave)]
        public static void GmLinkLeaveHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLinkLeave called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLinkLeave);
        }

        [Handler(MethodId.GmLinkLeaveAll)]
        public static void GmLinkLeaveAllHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLinkLeaveAll called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLinkLeaveAll);
        }

        [Handler(MethodId.GmLinkNew)]
        public static void GmLinkNewHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLinkNew called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLinkNew);
        }

        [Handler(MethodId.GmLinkNewAll)]
        public static void GmLinkNewAllHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLinkNewAll called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLinkNewAll);
        }

        [Handler(MethodId.GmLinkReplyInvite)]
        public static void GmLinkReplyInviteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLinkReplyInvite called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLinkReplyInvite);
        }

        [Handler(MethodId.GmLinkShowInfo)]
        public static void GmLinkShowInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLinkShowInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLinkShowInfo);
        }

        [Handler(MethodId.GmLinkShowSyncRateInfo)]
        public static void GmLinkShowSyncRateInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLinkShowSyncRateInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLinkShowSyncRateInfo);
        }

        [Handler(MethodId.GmLinkSwitchMode)]
        public static void GmLinkSwitchModeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLinkSwitchMode called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLinkSwitchMode);
        }

        [Handler(MethodId.GmLockEmotion)]
        public static void GmLockEmotionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmLockEmotion called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmLockEmotion);
        }

        [Handler(MethodId.GMLockFightStyle)]
        public static void GMLockFightStyleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMLockFightStyle called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMLockFightStyle);
        }

        [Handler(MethodId.GmMallBuyBundle)]
        public static void GmMallBuyBundleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmMallBuyBundle called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmMallBuyBundle);
        }

        [Handler(MethodId.GmMallBuyCommodity)]
        public static void GmMallBuyCommodityHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmMallBuyCommodity called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmMallBuyCommodity);
        }

        [Handler(MethodId.GmMallRefreshCommodity)]
        public static void GmMallRefreshCommodityHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmMallRefreshCommodity called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmMallRefreshCommodity);
        }

        [Handler(MethodId.GmMallSetCommoditySpiritDisplayP)]
        public static void GmMallSetCommoditySpiritDisplayPHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmMallSetCommoditySpiritDisplayP called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmMallSetCommoditySpiritDisplayP);
        }

        [Handler(MethodId.GmMallUnlockCommodity)]
        public static void GmMallUnlockCommodityHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmMallUnlockCommodity called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmMallUnlockCommodity);
        }

        [Handler(MethodId.GmMatchGameComplete)]
        public static void GmMatchGameCompleteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmMatchGameComplete called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmMatchGameComplete);
        }

        [Handler(MethodId.GmMatchGameCompleteAll)]
        public static void GmMatchGameCompleteAllHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmMatchGameCompleteAll called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmMatchGameCompleteAll);
        }

        [Handler(MethodId.GMMaxAllNpcFavor)]
        public static void GMMaxAllNpcFavorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMMaxAllNpcFavor called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMMaxAllNpcFavor);
        }

        [Handler(MethodId.GmNewPrivateLink)]
        public static void GmNewPrivateLinkHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmNewPrivateLink called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmNewPrivateLink);
        }

        [Handler(MethodId.GmNewRoom)]
        public static void GmNewRoomHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmNewRoom called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmNewRoom);
        }

        [Handler(MethodId.GmNotifyDamageSimulationStart)]
        public static void GmNotifyDamageSimulationStartHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmNotifyDamageSimulationStart called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmNotifyDamageSimulationStart);
        }

        [Handler(MethodId.GmNpcChat)]
        public static void GmNpcChatHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmNpcChat called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmNpcChat);
        }

        [Handler(MethodId.GmNpcRandomWearFashions)]
        public static void GmNpcRandomWearFashionsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmNpcRandomWearFashions called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmNpcRandomWearFashions);
        }

        [Handler(MethodId.GmObsoleteCurTruckJobOrder)]
        public static void GmObsoleteCurTruckJobOrderHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmObsoleteCurTruckJobOrder called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmObsoleteCurTruckJobOrder);
        }

        [Handler(MethodId.GmOccupyFactionInfluenceArea)]
        public static void GmOccupyFactionInfluenceAreaHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmOccupyFactionInfluenceArea called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmOccupyFactionInfluenceArea);
        }

        [Handler(MethodId.GmOutOfStuck)]
        public static void GmOutOfStuckHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmOutOfStuck called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmOutOfStuck);
        }

        [Handler(MethodId.GmPartyAddLikeAndGift)]
        public static void GmPartyAddLikeAndGiftHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPartyAddLikeAndGift called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPartyAddLikeAndGift);
        }

        [Handler(MethodId.GmPartyGetPartyInfo)]
        public static void GmPartyGetPartyInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPartyGetPartyInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPartyGetPartyInfo);
        }

        [Handler(MethodId.GmPartyGetSettleData)]
        public static void GmPartyGetSettleDataHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPartyGetSettleData called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPartyGetSettleData);
        }

        [Handler(MethodId.GmPartyLiveAddEvent)]
        public static void GmPartyLiveAddEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPartyLiveAddEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPartyLiveAddEvent);
        }

        [Handler(MethodId.GmPartyLiveOver)]
        public static void GmPartyLiveOverHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPartyLiveOver called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPartyLiveOver);
        }

        [Handler(MethodId.GmPassingTime)]
        public static void GmPassingTimeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPassingTime called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPassingTime);
        }

        [Handler(MethodId.GmPauseBehaviorAI)]
        public static void GmPauseBehaviorAIHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPauseBehaviorAI called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPauseBehaviorAI);
        }

        [Handler(MethodId.GmPidSetHp)]
        public static void GmPidSetHpHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPidSetHp called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPidSetHp);
        }

        [Handler(MethodId.GmPlaceGomokuPiece)]
        public static void GmPlaceGomokuPieceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPlaceGomokuPiece called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPlaceGomokuPiece);
        }

        [Handler(MethodId.GmPlanningBoardClearStepOptions)]
        public static void GmPlanningBoardClearStepOptionsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPlanningBoardClearStepOptions called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPlanningBoardClearStepOptions);
        }

        [Handler(MethodId.GmPlanningBoardSetStepOption)]
        public static void GmPlanningBoardSetStepOptionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPlanningBoardSetStepOption called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPlanningBoardSetStepOption);
        }

        [Handler(MethodId.GmPlayerUseSkillDebugOnly)]
        public static void GmPlayerUseSkillDebugOnlyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPlayerUseSkillDebugOnly called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPlayerUseSkillDebugOnly);
        }

        [Handler(MethodId.GmPoliceEnableCrimeValue)]
        public static void GmPoliceEnableCrimeValueHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPoliceEnableCrimeValue called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPoliceEnableCrimeValue);
        }

        [Handler(MethodId.GmPolicePickNextMission)]
        public static void GmPolicePickNextMissionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPolicePickNextMission called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPolicePickNextMission);
        }

        [Handler(MethodId.GmPrintClientTargetRayVisibility)]
        public static void GmPrintClientTargetRayVisibilityHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPrintClientTargetRayVisibility called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPrintClientTargetRayVisibility);
        }

        [Handler(MethodId.GmPrintRecentMove)]
        public static void GmPrintRecentMoveHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPrintRecentMove called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPrintRecentMove);
        }

        [Handler(MethodId.GmProduceItem)]
        public static void GmProduceItemHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmProduceItem called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmProduceItem);
        }

        [Handler(MethodId.GMPSNSetting)]
        public static void GMPSNSettingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMPSNSetting called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMPSNSetting);
        }

        [Handler(MethodId.GmPublishAllTriggerTuite)]
        public static void GmPublishAllTriggerTuiteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPublishAllTriggerTuite called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPublishAllTriggerTuite);
        }

        [Handler(MethodId.GmPublishNpcTuite)]
        public static void GmPublishNpcTuiteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPublishNpcTuite called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPublishNpcTuite);
        }

        [Handler(MethodId.GmPullMemberToTeam)]
        public static void GmPullMemberToTeamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPullMemberToTeam called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPullMemberToTeam);
        }

        [Handler(MethodId.GmPurchaseElement)]
        public static void GmPurchaseElementHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPurchaseElement called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPurchaseElement);
        }

        [Handler(MethodId.GmQueryBattleStatisticsData)]
        public static void GmQueryBattleStatisticsDataHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmQueryBattleStatisticsData called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmQueryBattleStatisticsData);
        }

        [Handler(MethodId.GmQueryDamageSimulationResult)]
        public static void GmQueryDamageSimulationResultHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmQueryDamageSimulationResult called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmQueryDamageSimulationResult);
        }

        [Handler(MethodId.GmQueryLockTargetRadius)]
        public static void GmQueryLockTargetRadiusHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmQueryLockTargetRadius called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmQueryLockTargetRadius);
        }

        [Handler(MethodId.GmQueryMahjongRoomInfo)]
        public static void GmQueryMahjongRoomInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmQueryMahjongRoomInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmQueryMahjongRoomInfo);
        }

        [Handler(MethodId.GmQueryPlayerMahjongRoomId)]
        public static void GmQueryPlayerMahjongRoomIdHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmQueryPlayerMahjongRoomId called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmQueryPlayerMahjongRoomId);
        }

        [Handler(MethodId.GmQueryPossiblePlayers)]
        public static void GmQueryPossiblePlayersHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmQueryPossiblePlayers called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmQueryPossiblePlayers);
        }

        [Handler(MethodId.GmQuerySkey)]
        public static void GmQuerySkeyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmQuerySkey called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmQuerySkey);
        }

        [Handler(MethodId.GmQuickPlaySingleGame)]
        public static void GmQuickPlaySingleGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmQuickPlaySingleGame called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmQuickPlaySingleGame);
        }

        [Handler(MethodId.GmRaiseSurrender)]
        public static void GmRaiseSurrenderHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRaiseSurrender called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRaiseSurrender);
        }

        [Handler(MethodId.GmRandomCharacterRandomDialog)]
        public static void GmRandomCharacterRandomDialogHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRandomCharacterRandomDialog called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRandomCharacterRandomDialog);
        }

        [Handler(MethodId.GmReadyToPlay)]
        public static void GmReadyToPlayHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmReadyToPlay called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmReadyToPlay);
        }

        [Handler(MethodId.GmRecordAgentBowlingScore)]
        public static void GmRecordAgentBowlingScoreHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRecordAgentBowlingScore called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRecordAgentBowlingScore);
        }

        [Handler(MethodId.GmRecordBowlingScore)]
        public static void GmRecordBowlingScoreHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRecordBowlingScore called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRecordBowlingScore);
        }

        [Handler(MethodId.GmRecoverPlayerAllSkillCharge)]
        public static void GmRecoverPlayerAllSkillChargeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRecoverPlayerAllSkillCharge called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRecoverPlayerAllSkillCharge);
        }

        [Handler(MethodId.GmRefreshAllFavorNpcTimeTable)]
        public static void GmRefreshAllFavorNpcTimeTableHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRefreshAllFavorNpcTimeTable called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRefreshAllFavorNpcTimeTable);
        }

        [Handler(MethodId.GmRefreshAllGadget)]
        public static void GmRefreshAllGadgetHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRefreshAllGadget called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRefreshAllGadget);
        }

        [Handler(MethodId.GmRefreshCrimes)]
        public static void GmRefreshCrimesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRefreshCrimes called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRefreshCrimes);
        }

        [Handler(MethodId.GmRefreshCurrentShop)]
        public static void GmRefreshCurrentShopHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRefreshCurrentShop called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRefreshCurrentShop);
        }

        [Handler(MethodId.GmRefreshRandomEvent)]
        public static void GmRefreshRandomEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRefreshRandomEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRefreshRandomEvent);
        }

        [Handler(MethodId.GmRegenerateWildEnemy)]
        public static void GmRegenerateWildEnemyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRegenerateWildEnemy called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRegenerateWildEnemy);
        }

        [Handler(MethodId.GmRegisterShipUrls)]
        public static void GmRegisterShipUrlsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRegisterShipUrls called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRegisterShipUrls);
        }

        [Handler(MethodId.GmReloadAllSpoonGraph)]
        public static void GmReloadAllSpoonGraphHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmReloadAllSpoonGraph called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmReloadAllSpoonGraph);
        }

        [Handler(MethodId.GMRemoveActiveNpcCard)]
        public static void GMRemoveActiveNpcCardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMRemoveActiveNpcCard called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMRemoveActiveNpcCard);
        }

        [Handler(MethodId.GmRemoveAllPokemon)]
        public static void GmRemoveAllPokemonHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRemoveAllPokemon called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRemoveAllPokemon);
        }

        [Handler(MethodId.GmRemoveBehaviorBreakPoint)]
        public static void GmRemoveBehaviorBreakPointHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRemoveBehaviorBreakPoint called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRemoveBehaviorBreakPoint);
        }

        [Handler(MethodId.GmRemoveBuildHouseIndoor)]
        public static void GmRemoveBuildHouseIndoorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRemoveBuildHouseIndoor called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRemoveBuildHouseIndoor);
        }

        [Handler(MethodId.GmRemoveCompanion)]
        public static void GmRemoveCompanionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRemoveCompanion called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRemoveCompanion);
        }

        [Handler(MethodId.GmRemoveCreation)]
        public static void GmRemoveCreationHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRemoveCreation called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRemoveCreation);
        }

        [Handler(MethodId.GmRemoveDailyChat)]
        public static void GmRemoveDailyChatHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRemoveDailyChat called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRemoveDailyChat);
        }

        [Handler(MethodId.GmRemoveFashions)]
        public static void GmRemoveFashionsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRemoveFashions called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRemoveFashions);
        }

        [Handler(MethodId.GmRemoveFurniture)]
        public static void GmRemoveFurnitureHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRemoveFurniture called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRemoveFurniture);
        }

        [Handler(MethodId.GmRemoveHouse)]
        public static void GmRemoveHouseHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRemoveHouse called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRemoveHouse);
        }

        [Handler(MethodId.GmRemoveOtherUnitState)]
        public static void GmRemoveOtherUnitStateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRemoveOtherUnitState called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRemoveOtherUnitState);
        }

        [Handler(MethodId.GmRemoveOtherUnitStateByInstance)]
        public static void GmRemoveOtherUnitStateByInstanceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRemoveOtherUnitStateByInstance called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRemoveOtherUnitStateByInstance);
        }

        [Handler(MethodId.GmRemoveUnitState)]
        public static void GmRemoveUnitStateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRemoveUnitState called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRemoveUnitState);
        }

        [Handler(MethodId.GmRemoveVehicleBuff)]
        public static void GmRemoveVehicleBuffHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmRemoveVehicleBuff called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmRemoveVehicleBuff);
        }

        [Handler(MethodId.GmReplyInvitePlayerInteractionAc)]
        public static void GmReplyInvitePlayerInteractionAcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmReplyInvitePlayerInteractionAc called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmReplyInvitePlayerInteractionAc);
        }

        [Handler(MethodId.GmReplyToFriendRoomInvite)]
        public static void GmReplyToFriendRoomInviteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmReplyToFriendRoomInvite called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmReplyToFriendRoomInvite);
        }

        [Handler(MethodId.GmReportBattleData)]
        public static void GmReportBattleDataHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmReportBattleData called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmReportBattleData);
        }

        [Handler(MethodId.GmResetBuildHouseIndoor)]
        public static void GmResetBuildHouseIndoorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmResetBuildHouseIndoor called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmResetBuildHouseIndoor);
        }

        [Handler(MethodId.GmResetFashionColoringSchemeInfo)]
        public static void GmResetFashionColoringSchemeInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmResetFashionColoringSchemeInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmResetFashionColoringSchemeInfo);
        }

        [Handler(MethodId.GmResetGachaGroupMilestone)]
        public static void GmResetGachaGroupMilestoneHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmResetGachaGroupMilestone called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmResetGachaGroupMilestone);
        }

        [Handler(MethodId.GmResetGachaPityHistory)]
        public static void GmResetGachaPityHistoryHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmResetGachaPityHistory called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmResetGachaPityHistory);
        }

        [Handler(MethodId.GmResetGachaPoolHistory)]
        public static void GmResetGachaPoolHistoryHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmResetGachaPoolHistory called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmResetGachaPoolHistory);
        }

        [Handler(MethodId.GmResetHackPosts)]
        public static void GmResetHackPostsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmResetHackPosts called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmResetHackPosts);
        }

        [Handler(MethodId.GMResetPersonalZoneInfo)]
        public static void GMResetPersonalZoneInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMResetPersonalZoneInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMResetPersonalZoneInfo);
        }

        [Handler(MethodId.GmResetSpiritJobTalent)]
        public static void GmResetSpiritJobTalentHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmResetSpiritJobTalent called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmResetSpiritJobTalent);
        }

        [Handler(MethodId.GmResetTempCamp)]
        public static void GmResetTempCampHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmResetTempCamp called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmResetTempCamp);
        }

        [Handler(MethodId.GmResumeAllEnemyAi)]
        public static void GmResumeAllEnemyAiHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmResumeAllEnemyAi called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmResumeAllEnemyAi);
        }

        [Handler(MethodId.GmReturnOriginalMode)]
        public static void GmReturnOriginalModeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmReturnOriginalMode called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmReturnOriginalMode);
        }

        [Handler(MethodId.GMReverseSeat)]
        public static void GMReverseSeatHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMReverseSeat called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMReverseSeat);
        }

        [Handler(MethodId.GmScientistAddALLRecipe)]
        public static void GmScientistAddALLRecipeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmScientistAddALLRecipe called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmScientistAddALLRecipe);
        }

        [Handler(MethodId.GMScientistAddRecipe)]
        public static void GMScientistAddRecipeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMScientistAddRecipe called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMScientistAddRecipe);
        }

        [Handler(MethodId.GmScientistClearProducedItems)]
        public static void GmScientistClearProducedItemsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmScientistClearProducedItems called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmScientistClearProducedItems);
        }

        [Handler(MethodId.GmScientistClearProduceHistory)]
        public static void GmScientistClearProduceHistoryHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmScientistClearProduceHistory called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmScientistClearProduceHistory);
        }

        [Handler(MethodId.GmScientistRemoveAllRecipe)]
        public static void GmScientistRemoveAllRecipeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmScientistRemoveAllRecipe called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmScientistRemoveAllRecipe);
        }

        [Handler(MethodId.GMScientistRemoveRecipe)]
        public static void GMScientistRemoveRecipeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMScientistRemoveRecipe called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMScientistRemoveRecipe);
        }

        [Handler(MethodId.GmSelectAllRandomEvent)]
        public static void GmSelectAllRandomEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSelectAllRandomEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSelectAllRandomEvent);
        }

        [Handler(MethodId.GmSelectRandomEvent)]
        public static void GmSelectRandomEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSelectRandomEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSelectRandomEvent);
        }

        [Handler(MethodId.GmSendConfigMail)]
        public static void GmSendConfigMailHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSendConfigMail called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSendConfigMail);
        }

        [Handler(MethodId.GmSendCustomDataToTest)]
        public static void GmSendCustomDataToTestHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSendCustomDataToTest called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSendCustomDataToTest);
        }

        [Handler(MethodId.GmSendReportMail)]
        public static void GmSendReportMailHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSendReportMail called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSendReportMail);
        }

        [Handler(MethodId.GmSendUninformerMail)]
        public static void GmSendUninformerMailHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSendUninformerMail called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSendUninformerMail);
        }

        [Handler(MethodId.GmSetAnimalFavor)]
        public static void GmSetAnimalFavorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetAnimalFavor called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetAnimalFavor);
        }

        [Handler(MethodId.GmSetBasicAttr)]
        public static void GmSetBasicAttrHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetBasicAttr called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetBasicAttr);
        }

        [Handler(MethodId.GMSetBestNpcs)]
        public static void GMSetBestNpcsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMSetBestNpcs called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMSetBestNpcs);
        }

        [Handler(MethodId.GmSetDebugBehaviorNode)]
        public static void GmSetDebugBehaviorNodeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetDebugBehaviorNode called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetDebugBehaviorNode);
        }

        [Handler(MethodId.GmSetDebugInitializeUsages)]
        public static void GmSetDebugInitializeUsagesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetDebugInitializeUsages called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetDebugInitializeUsages);
        }

        [Handler(MethodId.GMSetDeviceLevel)]
        public static void GMSetDeviceLevelHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMSetDeviceLevel called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMSetDeviceLevel);
        }

        [Handler(MethodId.GmSetDgoNavVoxelSurface)]
        public static void GmSetDgoNavVoxelSurfaceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetDgoNavVoxelSurface called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetDgoNavVoxelSurface);
        }

        [Handler(MethodId.GmSetEmotion)]
        public static void GmSetEmotionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetEmotion called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetEmotion);
        }

        [Handler(MethodId.GmSetEnableMaxMultiPlayerId)]
        public static void GmSetEnableMaxMultiPlayerIdHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetEnableMaxMultiPlayerId called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetEnableMaxMultiPlayerId);
        }

        [Handler(MethodId.GmSetFactionDisposition)]
        public static void GmSetFactionDispositionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetFactionDisposition called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetFactionDisposition);
        }

        [Handler(MethodId.GmSetFactionInfluence)]
        public static void GmSetFactionInfluenceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetFactionInfluence called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetFactionInfluence);
        }

        [Handler(MethodId.GmSetFashionColoringSchemeInfos)]
        public static void GmSetFashionColoringSchemeInfosHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetFashionColoringSchemeInfos called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetFashionColoringSchemeInfos);
        }

        [Handler(MethodId.GmSetFavorNpcTimeTable)]
        public static void GmSetFavorNpcTimeTableHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetFavorNpcTimeTable called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetFavorNpcTimeTable);
        }

        [Handler(MethodId.GmSetIndoorSectorId)]
        public static void GmSetIndoorSectorIdHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetIndoorSectorId called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetIndoorSectorId);
        }

        [Handler(MethodId.GmSetLinkDuty)]
        public static void GmSetLinkDutyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetLinkDuty called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetLinkDuty);
        }

        [Handler(MethodId.GmSetMapEntrance)]
        public static void GmSetMapEntranceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetMapEntrance called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetMapEntrance);
        }

        [Handler(MethodId.GmSetMoPai)]
        public static void GmSetMoPaiHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetMoPai called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetMoPai);
        }

        [Handler(MethodId.GmSetOtherAttr)]
        public static void GmSetOtherAttrHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetOtherAttr called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetOtherAttr);
        }

        [Handler(MethodId.GmSetRankScore)]
        public static void GmSetRankScoreHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetRankScore called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetRankScore);
        }

        [Handler(MethodId.GmSetRobotAutoRespond)]
        public static void GmSetRobotAutoRespondHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetRobotAutoRespond called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetRobotAutoRespond);
        }

        [Handler(MethodId.GmSetRoomMemberDuty)]
        public static void GmSetRoomMemberDutyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetRoomMemberDuty called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetRoomMemberDuty);
        }

        [Handler(MethodId.GmSetSectorNavVoxelSurface)]
        public static void GmSetSectorNavVoxelSurfaceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetSectorNavVoxelSurface called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetSectorNavVoxelSurface);
        }

        [Handler(MethodId.GmSetSpiritFashions)]
        public static void GmSetSpiritFashionsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetSpiritFashions called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetSpiritFashions);
        }

        [Handler(MethodId.GmSetSpiritFashionSuits)]
        public static void GmSetSpiritFashionSuitsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetSpiritFashionSuits called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetSpiritFashionSuits);
        }

        [Handler(MethodId.GmSetSpiritWearFashionHiddenPart)]
        public static void GmSetSpiritWearFashionHiddenPartHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetSpiritWearFashionHiddenPart called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetSpiritWearFashionHiddenPart);
        }

        [Handler(MethodId.GmSetStealthValue)]
        public static void GmSetStealthValueHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetStealthValue called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetStealthValue);
        }

        [Handler(MethodId.GmSetStoryValue)]
        public static void GmSetStoryValueHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetStoryValue called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetStoryValue);
        }

        [Handler(MethodId.GmSetTaskCounterValue)]
        public static void GmSetTaskCounterValueHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetTaskCounterValue called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetTaskCounterValue);
        }

        [Handler(MethodId.GmSetTempCamp)]
        public static void GmSetTempCampHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetTempCamp called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetTempCamp);
        }

        [Handler(MethodId.GmSetTruckOrderLimitTime)]
        public static void GmSetTruckOrderLimitTimeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetTruckOrderLimitTime called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetTruckOrderLimitTime);
        }

        [Handler(MethodId.GmSetTrustee)]
        public static void GmSetTrusteeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetTrustee called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetTrustee);
        }

        [Handler(MethodId.GmSetUseForwardGroup)]
        public static void GmSetUseForwardGroupHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetUseForwardGroup called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetUseForwardGroup);
        }

        [Handler(MethodId.GmSetWashCleaningInfo)]
        public static void GmSetWashCleaningInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSetWashCleaningInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSetWashCleaningInfo);
        }

        [Handler(MethodId.GmShowDialog)]
        public static void GmShowDialogHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmShowDialog called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmShowDialog);
        }

        [Handler(MethodId.GmShowGuide)]
        public static void GmShowGuideHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmShowGuide called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmShowGuide);
        }

        [Handler(MethodId.GmShowGuideTeach)]
        public static void GmShowGuideTeachHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmShowGuideTeach called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmShowGuideTeach);
        }

        [Handler(MethodId.GmShowMatchInfo)]
        public static void GmShowMatchInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmShowMatchInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmShowMatchInfo);
        }

        [Handler(MethodId.GmSkipTruckDailyOrder)]
        public static void GmSkipTruckDailyOrderHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSkipTruckDailyOrder called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSkipTruckDailyOrder);
        }

        [Handler(MethodId.GmSpawnAetherVehicle)]
        public static void GmSpawnAetherVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSpawnAetherVehicle called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSpawnAetherVehicle);
        }

        [Handler(MethodId.GmSpawnAetherVehicleAtFront)]
        public static void GmSpawnAetherVehicleAtFrontHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSpawnAetherVehicleAtFront called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSpawnAetherVehicleAtFront);
        }

        [Handler(MethodId.GMSpawnNpcForAttractPoint)]
        public static void GMSpawnNpcForAttractPointHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMSpawnNpcForAttractPoint called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMSpawnNpcForAttractPoint);
        }

        [Handler(MethodId.GmSpawnPoliceVehicle)]
        public static void GmSpawnPoliceVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSpawnPoliceVehicle called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSpawnPoliceVehicle);
        }

        [Handler(MethodId.GmSpawnServerCrowd)]
        public static void GmSpawnServerCrowdHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSpawnServerCrowd called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSpawnServerCrowd);
        }

        [Handler(MethodId.GmSpawnVehicleOnline)]
        public static void GmSpawnVehicleOnlineHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSpawnVehicleOnline called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSpawnVehicleOnline);
        }

        [Handler(MethodId.GmSpawnVehicleOnlineAtFront)]
        public static void GmSpawnVehicleOnlineAtFrontHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSpawnVehicleOnlineAtFront called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSpawnVehicleOnlineAtFront);
        }

        [Handler(MethodId.GmSpiritUndoWearFashions)]
        public static void GmSpiritUndoWearFashionsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSpiritUndoWearFashions called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSpiritUndoWearFashions);
        }

        [Handler(MethodId.GmSpreadStealthFromAToB)]
        public static void GmSpreadStealthFromAToBHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSpreadStealthFromAToB called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSpreadStealthFromAToB);
        }

        [Handler(MethodId.GmStartAIDebug)]
        public static void GmStartAIDebugHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartAIDebug called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartAIDebug);
        }

        [Handler(MethodId.GmStartBartenderGame)]
        public static void GmStartBartenderGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartBartenderGame called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartBartenderGame);
        }

        [Handler(MethodId.GmStartDart)]
        public static void GmStartDartHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartDart called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartDart);
        }

        [Handler(MethodId.GmStartEnemyDetectDebug)]
        public static void GmStartEnemyDetectDebugHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartEnemyDetectDebug called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartEnemyDetectDebug);
        }

        [Handler(MethodId.GmStartEnemyDetectStateDebug)]
        public static void GmStartEnemyDetectStateDebugHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartEnemyDetectStateDebug called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartEnemyDetectStateDebug);
        }

        [Handler(MethodId.GmStartEnemyGroupDebug)]
        public static void GmStartEnemyGroupDebugHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartEnemyGroupDebug called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartEnemyGroupDebug);
        }

        [Handler(MethodId.GmStartEnemyStrategyDebug)]
        public static void GmStartEnemyStrategyDebugHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartEnemyStrategyDebug called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartEnemyStrategyDebug);
        }

        [Handler(MethodId.GmStartEventNode)]
        public static void GmStartEventNodeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartEventNode called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartEventNode);
        }

        [Handler(MethodId.GmStartGame)]
        public static void GmStartGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartGame called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartGame);
        }

        [Handler(MethodId.GmStartGameInTeam)]
        public static void GmStartGameInTeamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartGameInTeam called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartGameInTeam);
        }

        [Handler(MethodId.GmStartHackerAutonomousDriving)]
        public static void GmStartHackerAutonomousDrivingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartHackerAutonomousDriving called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartHackerAutonomousDriving);
        }

        [Handler(MethodId.GmStartInviteRideNpc)]
        public static void GmStartInviteRideNpcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartInviteRideNpc called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartInviteRideNpc);
        }

        [Handler(MethodId.GmStartMahjongWithNpc)]
        public static void GmStartMahjongWithNpcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartMahjongWithNpc called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartMahjongWithNpc);
        }

        [Handler(MethodId.GmStartMatchInTeam)]
        public static void GmStartMatchInTeamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartMatchInTeam called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartMatchInTeam);
        }

        [Handler(MethodId.GmStartPVEMahjong)]
        public static void GmStartPVEMahjongHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartPVEMahjong called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartPVEMahjong);
        }

        [Handler(MethodId.GmStartPlotBehavior)]
        public static void GmStartPlotBehaviorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartPlotBehavior called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartPlotBehavior);
        }

        [Handler(MethodId.GmStartRoomMatch)]
        public static void GmStartRoomMatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartRoomMatch called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartRoomMatch);
        }

        [Handler(MethodId.GmStartRoomMatchAll)]
        public static void GmStartRoomMatchAllHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartRoomMatchAll called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartRoomMatchAll);
        }

        [Handler(MethodId.GmStartSingleMatch)]
        public static void GmStartSingleMatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartSingleMatch called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartSingleMatch);
        }

        [Handler(MethodId.GmStartSingleMatchAll)]
        public static void GmStartSingleMatchAllHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartSingleMatchAll called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartSingleMatchAll);
        }

        [Handler(MethodId.GmStartSingleParty)]
        public static void GmStartSinglePartyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartSingleParty called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartSingleParty);
        }

        [Handler(MethodId.GmStartSyncAIAction)]
        public static void GmStartSyncAIActionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartSyncAIAction called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartSyncAIAction);
        }

        [Handler(MethodId.GMStartWatchOtherPlayer)]
        public static void GMStartWatchOtherPlayerHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMStartWatchOtherPlayer called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMStartWatchOtherPlayer);
        }

        [Handler(MethodId.GmStopAllEnemyAi)]
        public static void GmStopAllEnemyAiHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStopAllEnemyAi called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStopAllEnemyAi);
        }

        [Handler(MethodId.GmStopEnemyAiByCamp)]
        public static void GmStopEnemyAiByCampHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStopEnemyAiByCamp called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStopEnemyAiByCamp);
        }

        [Handler(MethodId.GmStopMatch)]
        public static void GmStopMatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStopMatch called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStopMatch);
        }

        [Handler(MethodId.GmStopWatchOtherPlayer)]
        public static void GmStopWatchOtherPlayerHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStopWatchOtherPlayer called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStopWatchOtherPlayer);
        }

        [Handler(MethodId.GmSubmitAllTask)]
        public static void GmSubmitAllTaskHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSubmitAllTask called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSubmitAllTask);
        }

        [Handler(MethodId.GmSubmitEvent)]
        public static void GmSubmitEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSubmitEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSubmitEvent);
        }

        [Handler(MethodId.GmSubmitTask)]
        public static void GmSubmitTaskHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSubmitTask called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSubmitTask);
        }

        [Handler(MethodId.GmSurrenderVote)]
        public static void GmSurrenderVoteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSurrenderVote called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSurrenderVote);
        }

        [Handler(MethodId.GmSwitchReadyToPlay)]
        public static void GmSwitchReadyToPlayHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSwitchReadyToPlay called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSwitchReadyToPlay);
        }

        [Handler(MethodId.GmSwitchToWeapon)]
        public static void GmSwitchToWeaponHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSwitchToWeapon called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSwitchToWeapon);
        }

        [Handler(MethodId.GmSyncHouseIndoorBuildInfo)]
        public static void GmSyncHouseIndoorBuildInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSyncHouseIndoorBuildInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSyncHouseIndoorBuildInfo);
        }

        [Handler(MethodId.GmSyncLogicTickTime)]
        public static void GmSyncLogicTickTimeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSyncLogicTickTime called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSyncLogicTickTime);
        }

        [Handler(MethodId.GMSyncWorldBattlePlayers)]
        public static void GMSyncWorldBattlePlayersHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMSyncWorldBattlePlayers called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMSyncWorldBattlePlayers);
        }

        [Handler(MethodId.GmSystemAddBuffToAll)]
        public static void GmSystemAddBuffToAllHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmSystemAddBuffToAll called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmSystemAddBuffToAll);
        }

        [Handler(MethodId.GMTakeItemProduced)]
        public static void GMTakeItemProducedHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMTakeItemProduced called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMTakeItemProduced);
        }

        [Handler(MethodId.GmTeleportAllToEntity)]
        public static void GmTeleportAllToEntityHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmTeleportAllToEntity called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmTeleportAllToEntity);
        }

        [Handler(MethodId.GmTeleportAllToPosition)]
        public static void GmTeleportAllToPositionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmTeleportAllToPosition called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmTeleportAllToPosition);
        }

        [Handler(MethodId.GmTeleportToLinkMember)]
        public static void GmTeleportToLinkMemberHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmTeleportToLinkMember called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmTeleportToLinkMember);
        }

        [Handler(MethodId.GmTeleportUnit)]
        public static void GmTeleportUnitHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmTeleportUnit called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmTeleportUnit);
        }

        [Handler(MethodId.GmTeleportUnitXYZ)]
        public static void GmTeleportUnitXYZHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmTeleportUnitXYZ called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmTeleportUnitXYZ);
        }

        [Handler(MethodId.GmTestBanUser)]
        public static void GmTestBanUserHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmTestBanUser called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmTestBanUser);
        }

        [Handler(MethodId.GmTestCrash)]
        public static void GmTestCrashHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmTestCrash called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmTestCrash);
        }

        [Handler(MethodId.GmTestDamage)]
        public static void GmTestDamageHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmTestDamage called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmTestDamage);
        }

        [Handler(MethodId.GmTestPveLowMiddleHigh)]
        public static void GmTestPveLowMiddleHighHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmTestPveLowMiddleHigh called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmTestPveLowMiddleHigh);
        }

        [Handler(MethodId.GmTestS17)]
        public static void GmTestS17Handler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmTestS17 called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmTestS17);
        }

        [Handler(MethodId.GmTestStackoverflow)]
        public static void GmTestStackoverflowHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmTestStackoverflow called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmTestStackoverflow);
        }

        [Handler(MethodId.GmTestTeamControlPowerSkill)]
        public static void GmTestTeamControlPowerSkillHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmTestTeamControlPowerSkill called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmTestTeamControlPowerSkill);
        }

        [Handler(MethodId.GmToggleStoryDebug)]
        public static void GmToggleStoryDebugHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmToggleStoryDebug called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmToggleStoryDebug);
        }

        [Handler(MethodId.GmTriggerDailyChat)]
        public static void GmTriggerDailyChatHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmTriggerDailyChat called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmTriggerDailyChat);
        }

        [Handler(MethodId.GMTriggerNpcQueueEvent)]
        public static void GMTriggerNpcQueueEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMTriggerNpcQueueEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMTriggerNpcQueueEvent);
        }

        [Handler(MethodId.GmTriggerPlotEvent)]
        public static void GmTriggerPlotEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmTriggerPlotEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmTriggerPlotEvent);
        }

        [Handler(MethodId.GmTriggerPlotEvent2)]
        public static void GmTriggerPlotEvent2Handler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmTriggerPlotEvent2 called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmTriggerPlotEvent2);
        }

        [Handler(MethodId.GmTryToLockUnit)]
        public static void GmTryToLockUnitHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmTryToLockUnit called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmTryToLockUnit);
        }

        [Handler(MethodId.GMUnlockAllFightStyle)]
        public static void GMUnlockAllFightStyleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMUnlockAllFightStyle called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMUnlockAllFightStyle);
        }

        [Handler(MethodId.GmUnlockAllNpcVoice)]
        public static void GmUnlockAllNpcVoiceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUnlockAllNpcVoice called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnlockAllNpcVoice);
        }

        [Handler(MethodId.GmUnlockBadge)]
        public static void GmUnlockBadgeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUnlockBadge called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnlockBadge);
        }

        [Handler(MethodId.GmUnlockComputerEmail)]
        public static void GmUnlockComputerEmailHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUnlockComputerEmail called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnlockComputerEmail);
        }

        [Handler(MethodId.GmUnlockComputerFile)]
        public static void GmUnlockComputerFileHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUnlockComputerFile called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnlockComputerFile);
        }

        [Handler(MethodId.GmUnlockCountry)]
        public static void GmUnlockCountryHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUnlockCountry called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnlockCountry);
        }

        [Handler(MethodId.GMUnlockFightStyle)]
        public static void GMUnlockFightStyleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMUnlockFightStyle called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMUnlockFightStyle);
        }

        [Handler(MethodId.GmUnlockFogMapPoi)]
        public static void GmUnlockFogMapPoiHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUnlockFogMapPoi called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnlockFogMapPoi);
        }

        [Handler(MethodId.GmUnlockInvestigateGallery)]
        public static void GmUnlockInvestigateGalleryHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUnlockInvestigateGallery called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnlockInvestigateGallery);
        }

        [Handler(MethodId.GmUnlockNpcActionItem)]
        public static void GmUnlockNpcActionItemHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUnlockNpcActionItem called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnlockNpcActionItem);
        }

        [Handler(MethodId.GmUnlockPost)]
        public static void GmUnlockPostHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUnlockPost called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnlockPost);
        }

        [Handler(MethodId.GmUnLockQuest)]
        public static void GmUnLockQuestHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUnLockQuest called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnLockQuest);
        }

        [Handler(MethodId.GmUnlockRandomEvent)]
        public static void GmUnlockRandomEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUnlockRandomEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnlockRandomEvent);
        }

        [Handler(MethodId.GmUnlockSystem)]
        public static void GmUnlockSystemHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUnlockSystem called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnlockSystem);
        }

        [Handler(MethodId.GmUnlockTarget)]
        public static void GmUnlockTargetHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUnlockTarget called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnlockTarget);
        }

        [Handler(MethodId.GmUnlockTaskTitleGuide)]
        public static void GmUnlockTaskTitleGuideHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUnlockTaskTitleGuide called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnlockTaskTitleGuide);
        }

        [Handler(MethodId.GmUnregisterShipUrls)]
        public static void GmUnregisterShipUrlsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUnregisterShipUrls called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnregisterShipUrls);
        }

        [Handler(MethodId.GmUnsetSpiritAllFashions)]
        public static void GmUnsetSpiritAllFashionsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUnsetSpiritAllFashions called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnsetSpiritAllFashions);
        }

        [Handler(MethodId.GmUpdateAccountActivation)]
        public static void GmUpdateAccountActivationHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUpdateAccountActivation called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUpdateAccountActivation);
        }

        [Handler(MethodId.GmUpdateUserDeviceId)]
        public static void GmUpdateUserDeviceIdHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUpdateUserDeviceId called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUpdateUserDeviceId);
        }

        [Handler(MethodId.GmUseAISkill)]
        public static void GmUseAISkillHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUseAISkill called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUseAISkill);
        }

        [Handler(MethodId.GmUseEnemyStrategy)]
        public static void GmUseEnemyStrategyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUseEnemyStrategy called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUseEnemyStrategy);
        }

        [Handler(MethodId.GmUseSkill)]
        public static void GmUseSkillHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUseSkill called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUseSkill);
        }

        [Handler(MethodId.GmUseSkillWithErrorCode)]
        public static void GmUseSkillWithErrorCodeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUseSkillWithErrorCode called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUseSkillWithErrorCode);
        }

        [Handler(MethodId.GmUtils)]
        public static void GmUtilsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmUtils called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUtils);
        }

        [Handler(MethodId.GmWasherRandomPickMission)]
        public static void GmWasherRandomPickMissionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmWasherRandomPickMission called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmWasherRandomPickMission);
        }

        [Handler(MethodId.GmWatchOtherPlayer)]
        public static void GmWatchOtherPlayerHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmWatchOtherPlayer called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmWatchOtherPlayer);
        }

        [Handler(MethodId.GmWorldRefreshEnemyGroup)]
        public static void GmWorldRefreshEnemyGroupHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmWorldRefreshEnemyGroup called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmWorldRefreshEnemyGroup);
        }

        // ====================================================================
        // Fase 4: GM Commands Omitted - Batch 1 (Account/Delete)
        // ====================================================================

        [Handler(MethodId.GmAccountDeleteClearNotify)]
        public static void GmAccountDeleteClearNotifyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAccountDeleteClearNotify called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAccountDeleteClearNotify);
        }

        [Handler(MethodId.GmAccountDeleteQueryUrls)]
        public static void GmAccountDeleteQueryUrlsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAccountDeleteQueryUrls called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAccountDeleteQueryUrls);
        }

        [Handler(MethodId.GmAccountDeleteRegisterUrls)]
        public static void GmAccountDeleteRegisterUrlsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAccountDeleteRegisterUrls called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAccountDeleteRegisterUrls);
        }

        [Handler(MethodId.GmAccountDeleteUnregisterUrls)]
        public static void GmAccountDeleteUnregisterUrlsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAccountDeleteUnregisterUrls called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAccountDeleteUnregisterUrls);
        }

        // ====================================================================
        // Fase 4: GM Commands Omitted - Batch 2 (Activate/NPC)
        // ====================================================================

        [Handler(MethodId.GMActivateAllNpcCard)]
        public static void GMActivateAllNpcCardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMActivateAllNpcCard called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMActivateAllNpcCard);
        }

        [Handler(MethodId.GMActivateLockedNpcCard)]
        public static void GMActivateLockedNpcCardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMActivateLockedNpcCard called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMActivateLockedNpcCard);
        }

        [Handler(MethodId.GMActivateNpcCard)]
        public static void GMActivateNpcCardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMActivateNpcCard called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMActivateNpcCard);
        }

        [Handler(MethodId.GMActivateNpcProfile)]
        public static void GMActivateNpcProfileHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMActivateNpcProfile called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMActivateNpcProfile);
        }

        // ====================================================================
        // Fase 4: GM Commands Omitted - Batch 3 (Add/Remove)
        // ====================================================================

        [Handler(MethodId.GmAcceptEvent)]
        public static void GmAcceptEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAcceptEvent called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAcceptEvent);
        }

        [Handler(MethodId.GmAcceptSpecialTruckJobOrder)]
        public static void GmAcceptSpecialTruckJobOrderHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAcceptSpecialTruckJobOrder called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAcceptSpecialTruckJobOrder);
        }

        [Handler(MethodId.GmAcceptTask)]
        public static void GmAcceptTaskHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAcceptTask called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAcceptTask);
        }

        [Handler(MethodId.GmAcceptTaskAndSubmitPre)]
        public static void GmAcceptTaskAndSubmitPreHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAcceptTaskAndSubmitPre called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAcceptTaskAndSubmitPre);
        }

        [Handler(MethodId.GmAbilitySetLevel)]
        public static void GmAbilitySetLevelHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAbilitySetLevel called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAbilitySetLevel);
        }

        [Handler(MethodId.GmActiveBadgeEffect)]
        public static void GmActiveBadgeEffectHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmActiveBadgeEffect called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmActiveBadgeEffect);
        }

        [Handler(MethodId.GmActiveSpiritJobTalentLayer)]
        public static void GmActiveSpiritJobTalentLayerHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmActiveSpiritJobTalentLayer called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmActiveSpiritJobTalentLayer);
        }

        [Handler(MethodId.GmAddAllPeiYangItems)]
        public static void GmAddAllPeiYangItemsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddAllPeiYangItems called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddAllPeiYangItems);
        }

        [Handler(MethodId.GmAddAllPokemon)]
        public static void GmAddAllPokemonHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddAllPokemon called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddAllPokemon);
        }

        [Handler(MethodId.GmAddAttractPoint)]
        public static void GmAddAttractPointHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddAttractPoint called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddAttractPoint);
        }

        [Handler(MethodId.GmAddBasicAttr)]
        public static void GmAddBasicAttrHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddBasicAttr called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddBasicAttr);
        }

        [Handler(MethodId.GmAddBehaviorBreakPoint)]
        public static void GmAddBehaviorBreakPointHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddBehaviorBreakPoint called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddBehaviorBreakPoint);
        }

        [Handler(MethodId.GmAddBuffToAllSpirit)]
        public static void GmAddBuffToAllSpiritHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddBuffToAllSpirit called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddBuffToAllSpirit);
        }

        [Handler(MethodId.GmAddBuildHouseIndoor)]
        public static void GmAddBuildHouseIndoorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddBuildHouseIndoor called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddBuildHouseIndoor);
        }

        [Handler(MethodId.GmAddChaosObject)]
        public static void GmAddChaosObjectHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddChaosObject called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddChaosObject);
        }

        [Handler(MethodId.GmAddCommonSpiritTalentExp)]
        public static void GmAddCommonSpiritTalentExpHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddCommonSpiritTalentExp called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddCommonSpiritTalentExp);
        }

        [Handler(MethodId.GmAddCompanion)]
        public static void GmAddCompanionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddCompanion called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddCompanion);
        }

        [Handler(MethodId.GmAddCreation)]
        public static void GmAddCreationHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddCreation called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddCreation);
        }

        [Handler(MethodId.GmAddCreationOnUnit)]
        public static void GmAddCreationOnUnitHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddCreationOnUnit called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddCreationOnUnit);
        }

        [Handler(MethodId.GMAddCredit)]
        public static void GMAddCreditHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMAddCredit called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMAddCredit);
        }

        [Handler(MethodId.GmAddCrimeValue)]
        public static void GmAddCrimeValueHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddCrimeValue called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddCrimeValue);
        }

        [Handler(MethodId.GmAddElement)]
        public static void GmAddElementHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddElement called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddElement);
        }

        [Handler(MethodId.GmAddEnemyByPlayer)]
        public static void GmAddEnemyByPlayerHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddEnemyByPlayer called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddEnemyByPlayer);
        }

        [Handler(MethodId.GmAddEnemyWithPosition)]
        public static void GmAddEnemyWithPositionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddEnemyWithPosition called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddEnemyWithPosition);
        }

        [Handler(MethodId.GMAddExp)]
        public static void GMAddExpHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMAddExp called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMAddExp);
        }

        [Handler(MethodId.GmAddFactionDisposition)]
        public static void GmAddFactionDispositionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddFactionDisposition called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddFactionDisposition);
        }

        [Handler(MethodId.GmAddFactionInfluence)]
        public static void GmAddFactionInfluenceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddFactionInfluence called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddFactionInfluence);
        }

        [Handler(MethodId.GmAddFakeFileClueValue)]
        public static void GmAddFakeFileClueValueHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddFakeFileClueValue called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddFakeFileClueValue);
        }

        [Handler(MethodId.GmAddFakeMirrorDelta)]
        public static void GmAddFakeMirrorDeltaHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddFakeMirrorDelta called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddFakeMirrorDelta);
        }

        [Handler(MethodId.GmAddFashionSuits)]
        public static void GmAddFashionSuitsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddFashionSuits called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddFashionSuits);
        }

        [Handler(MethodId.GmAddFurniture)]
        public static void GmAddFurnitureHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddFurniture called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddFurniture);
        }

        [Handler(MethodId.GmAddHealItems)]
        public static void GmAddHealItemsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddHealItems called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddHealItems);
        }

        [Handler(MethodId.GmAddHouse)]
        public static void GmAddHouseHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddHouse called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddHouse);
        }

        [Handler(MethodId.GmAddLifeSkillItem)]
        public static void GmAddLifeSkillItemHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddLifeSkillItem called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddLifeSkillItem);
        }

        [Handler(MethodId.GmAddMilkNpcFavor)]
        public static void GmAddMilkNpcFavorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddMilkNpcFavor called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddMilkNpcFavor);
        }

        [Handler(MethodId.GmAddMobileSkinPart)]
        public static void GmAddMobileSkinPartHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddMobileSkinPart called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddMobileSkinPart);
        }

        [Handler(MethodId.GmAddOtherBuff)]
        public static void GmAddOtherBuffHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddOtherBuff called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddOtherBuff);
        }

        [Handler(MethodId.GmAddOtherUnitState)]
        public static void GmAddOtherUnitStateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddOtherUnitState called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddOtherUnitState);
        }

        [Handler(MethodId.GmAddOtherUnitStateByInstance)]
        public static void GmAddOtherUnitStateByInstanceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddOtherUnitStateByInstance called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddOtherUnitStateByInstance);
        }

        [Handler(MethodId.GmAddPokemon)]
        public static void GmAddPokemonHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddPokemon called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddPokemon);
        }

        [Handler(MethodId.GmAddPoliceViolation)]
        public static void GmAddPoliceViolationHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddPoliceViolation called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddPoliceViolation);
        }

        [Handler(MethodId.GmAddPopularity)]
        public static void GmAddPopularityHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddPopularity called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddPopularity);
        }

        [Handler(MethodId.GmAddPopularityFromConfig)]
        public static void GmAddPopularityFromConfigHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddPopularityFromConfig called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddPopularityFromConfig);
        }

        [Handler(MethodId.GMAddPSNBlackList)]
        public static void GMAddPSNBlackListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMAddPSNBlackList called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMAddPSNBlackList);
        }

        [Handler(MethodId.GmAddSceneItem)]
        public static void GmAddSceneItemHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddSceneItem called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddSceneItem);
        }

        [Handler(MethodId.GmAddSpiritTalentExp)]
        public static void GmAddSpiritTalentExpHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddSpiritTalentExp called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddSpiritTalentExp);
        }

        [Handler(MethodId.GmAddStory)]
        public static void GmAddStoryHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddStory called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddStory);
        }

        [Handler(MethodId.GmAddTaskCounterValue)]
        public static void GmAddTaskCounterValueHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddTaskCounterValue called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddTaskCounterValue);
        }

        [Handler(MethodId.GmAddUnitState)]
        public static void GmAddUnitStateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddUnitState called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddUnitState);
        }

        [Handler(MethodId.GmAddFan)]
        public static void GmAddFanHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddFan called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddFan);
        }

        [Handler(MethodId.GmAddVehicle)]
        public static void GmAddVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddVehicle called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddVehicle);
        }

        [Handler(MethodId.GmAddVehicleBuff)]
        public static void GmAddVehicleBuffHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAddVehicleBuff called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAddVehicleBuff);
        }

        // ====================================================================
        // Fase 4: GM Commands Omitted - Batch 4 (Aether)
        // ====================================================================

        [Handler(MethodId.GmAetherActivateNpcPrefab)]
        public static void GmAetherActivateNpcPrefabHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAetherActivateNpcPrefab called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAetherActivateNpcPrefab);
        }

        [Handler(MethodId.GmAetherAddDangerZone)]
        public static void GmAetherAddDangerZoneHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAetherAddDangerZone called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAetherAddDangerZone);
        }

        [Handler(MethodId.GmAetherChangeAreaDensity)]
        public static void GmAetherChangeAreaDensityHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAetherChangeAreaDensity called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAetherChangeAreaDensity);
        }

        [Handler(MethodId.GmAetherChangePedNumScale)]
        public static void GmAetherChangePedNumScaleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAetherChangePedNumScale called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAetherChangePedNumScale);
        }

        [Handler(MethodId.GmAetherChangeQuality)]
        public static void GmAetherChangeQualityHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAetherChangeQuality called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAetherChangeQuality);
        }

        [Handler(MethodId.GmAetherChangeVehicleDynamicAOI)]
        public static void GmAetherChangeVehicleDynamicAOIHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAetherChangeVehicleDynamicAOI called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAetherChangeVehicleDynamicAOI);
        }

        [Handler(MethodId.GmAetherCreateCrowd)]
        public static void GmAetherCreateCrowdHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAetherCreateCrowd called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAetherCreateCrowd);
        }

        [Handler(MethodId.GmAetherCreateNpc)]
        public static void GmAetherCreateNpcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAetherCreateNpc called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAetherCreateNpc);
        }

        [Handler(MethodId.GmAetherCreatePed)]
        public static void GmAetherCreatePedHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAetherCreatePed called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAetherCreatePed);
        }

        [Handler(MethodId.GmAetherCreatePedWithDisease)]
        public static void GmAetherCreatePedWithDiseaseHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAetherCreatePedWithDisease called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAetherCreatePedWithDisease);
        }

        [Handler(MethodId.GmAetherEnsureRefreshStaticNpc)]
        public static void GmAetherEnsureRefreshStaticNpcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAetherEnsureRefreshStaticNpc called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAetherEnsureRefreshStaticNpc);
        }

        [Handler(MethodId.GmAetherForceUseUsage)]
        public static void GmAetherForceUseUsageHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAetherForceUseUsage called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAetherForceUseUsage);
        }

        [Handler(MethodId.GmAetherKillAllCrowd)]
        public static void GmAetherKillAllCrowdHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAetherKillAllCrowd called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAetherKillAllCrowd);
        }

        [Handler(MethodId.GmAetherNpcFirstSpawnOnly)]
        public static void GmAetherNpcFirstSpawnOnlyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAetherNpcFirstSpawnOnly called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAetherNpcFirstSpawnOnly);
        }

        [Handler(MethodId.GmAetherRecoverAllCrowd)]
        public static void GmAetherRecoverAllCrowdHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAetherRecoverAllCrowd called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAetherRecoverAllCrowd);
        }

        [Handler(MethodId.GmAetherRefreshNpc)]
        public static void GmAetherRefreshNpcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAetherRefreshNpc called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAetherRefreshNpc);
        }

        [Handler(MethodId.GmAetherResetAreaDensity)]
        public static void GmAetherResetAreaDensityHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAetherResetAreaDensity called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAetherResetAreaDensity);
        }

        // ====================================================================
        // Fase 4: GM Commands Omitted - Batch 5 (Agent/Behavior)
        // ====================================================================

        [Handler(MethodId.GmAgentGetInVehicle)]
        public static void GmAgentGetInVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAgentGetInVehicle called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAgentGetInVehicle);
        }

        [Handler(MethodId.GmAgentGetOutVehicle)]
        public static void GmAgentGetOutVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAgentGetOutVehicle called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAgentGetOutVehicle);
        }

        [Handler(MethodId.GmAllSwitchToBattle)]
        public static void GmAllSwitchToBattleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAllSwitchToBattle called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAllSwitchToBattle);
        }

        [Handler(MethodId.GmAllSwitchToNpc)]
        public static void GmAllSwitchToNpcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAllSwitchToNpc called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAllSwitchToNpc);
        }

        [Handler(MethodId.GmAllTaskReset)]
        public static void GmAllTaskResetHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAllTaskReset called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAllTaskReset);
        }

        [Handler(MethodId.GmAllTaskResetByTitle)]
        public static void GmAllTaskResetByTitleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAllTaskResetByTitle called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAllTaskResetByTitle);
        }

        [Handler(MethodId.GmAnalysisSimpleGridData)]
        public static void GmAnalysisSimpleGridDataHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAnalysisSimpleGridData called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAnalysisSimpleGridData);
        }

        [Handler(MethodId.GmApplyDutySwap)]
        public static void GmApplyDutySwapHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmApplyDutySwap called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmApplyDutySwap);
        }

        [Handler(MethodId.GmApplyFashionColoringSchemeInfo)]
        public static void GmApplyFashionColoringSchemeInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmApplyFashionColoringSchemeInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmApplyFashionColoringSchemeInfo);
        }

        [Handler(MethodId.GmArchiveInvestigateGallery)]
        public static void GmArchiveInvestigateGalleryHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmArchiveInvestigateGallery called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmArchiveInvestigateGallery);
        }

        [Handler(MethodId.GmAskCreateTeam)]
        public static void GmAskCreateTeamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAskCreateTeam called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAskCreateTeam);
        }

        [Handler(MethodId.GmAskJoinLinkOnTeamInvite)]
        public static void GmAskJoinLinkOnTeamInviteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAskJoinLinkOnTeamInvite called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAskJoinLinkOnTeamInvite);
        }

        [Handler(MethodId.GmAskNameAnimal)]
        public static void GmAskNameAnimalHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAskNameAnimal called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAskNameAnimal);
        }

        [Handler(MethodId.GMAskPlayWithAnimal)]
        public static void GMAskPlayWithAnimalHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GMAskPlayWithAnimal called");
            SendEmptySuccessReturn(conn, msg, MethodId.GMAskPlayWithAnimal);
        }

        [Handler(MethodId.GmAskWebviewToken)]
        public static void GmAskWebviewTokenHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmAskWebviewToken called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmAskWebviewToken);
        }

        [Handler(MethodId.GmBartendingByDrinkMenu)]
        public static void GmBartendingByDrinkMenuHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmBartendingByDrinkMenu called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmBartendingByDrinkMenu);
        }

        [Handler(MethodId.GmBehaviorBreakContinue)]
        public static void GmBehaviorBreakContinueHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmBehaviorBreakContinue called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmBehaviorBreakContinue);
        }

        [Handler(MethodId.GmBehaviorNextPoint)]
        public static void GmBehaviorNextPointHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmBehaviorNextPoint called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmBehaviorNextPoint);
        }

        [Handler(MethodId.GmBreakdownItem)]
        public static void GmBreakdownItemHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmBreakdownItem called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmBreakdownItem);
        }

        // ====================================================================
        // Fase 4: GM Commands Omitted - Batch 6 (End/Play/Start)
        // ====================================================================

        [Handler(MethodId.GmEndMahjongGame)]
        public static void GmEndMahjongGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmEndMahjongGame called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmEndMahjongGame);
        }

        [Handler(MethodId.GmPlayGameAgain)]
        public static void GmPlayGameAgainHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmPlayGameAgain called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmPlayGameAgain);
        }

        [Handler(MethodId.GmStartPlayerInteractionAction)]
        public static void GmStartPlayerInteractionActionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[GM] GmStartPlayerInteractionAction called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmStartPlayerInteractionAction);
        }
    }
}
