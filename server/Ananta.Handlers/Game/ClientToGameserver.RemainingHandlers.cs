using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using System;
using System.Collections.Generic;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    internal partial class ClientToGameserver
    {
        // =============================================
        // REMAINING 204 UNHANDLED RPCs - STUB HANDLERS
        // All return ack (Retcode=0) to prevent
        // client timeout/disconnect on unhandled RPCs.
        // Add real logic here incrementally.
        // Generated: 2026-06-22
        // =============================================

        #region Team/Link (32 handlers)

        [Handler(MethodId.AskApplyToTeam)]
        public static void AskApplyToTeamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskApplyToTeam");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskApplyToTeam,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskChangeRoomSetting)]
        public static void AskChangeRoomSettingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskChangeRoomSetting");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskChangeRoomSetting,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskChangeTeamLeader)]
        public static void AskChangeTeamLeaderHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskChangeTeamLeader");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskChangeTeamLeader,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskChangeTeamLeaderApply)]
        public static void AskChangeTeamLeaderApplyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskChangeTeamLeaderApply");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskChangeTeamLeaderApply,
            };
            conn.SendPacket(rsp);
        }


        [Handler(MethodId.AskInviteFriendToLink)]
        public static void AskInviteFriendToLinkHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskInviteFriendToLink");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskInviteFriendToLink,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskInviteFriendToRoom)]
        public static void AskInviteFriendToRoomHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskInviteFriendToRoom");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskInviteFriendToRoom,
            };
            conn.SendPacket(rsp);
        }


        [Handler(MethodId.AskJoinFriendModeRoom)]
        public static void AskJoinFriendModeRoomHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskJoinFriendModeRoom");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskJoinFriendModeRoom,
            };
            conn.SendPacket(rsp);
        }


        [Handler(MethodId.AskKickFriendFromLink)]
        public static void AskKickFriendFromLinkHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskKickFriendFromLink");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskKickFriendFromLink,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskKickFriendInRoom)]
        public static void AskKickFriendInRoomHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskKickFriendInRoom");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskKickFriendInRoom,
            };
            conn.SendPacket(rsp);
        }


        [Handler(MethodId.AskLeaveLink)]
        public static void AskLeaveLinkHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskLeaveLink");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskLeaveLink,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskLeaveRoom)]
        public static void AskLeaveRoomHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskLeaveRoom");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskLeaveRoom,
            };
            conn.SendPacket(rsp);
        }


        [Handler(MethodId.AskLinkInfo)]
        public static void AskLinkInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskLinkInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskLinkInfo,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskLinkInfos)]
        public static void AskLinkInfosHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskLinkInfos");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskLinkInfos,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskLinkWatchOther)]
        public static void AskLinkWatchOtherHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskLinkWatchOther");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskLinkWatchOther,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskLinkWatcheeList)]
        public static void AskLinkWatcheeListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskLinkWatcheeList");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskLinkWatcheeList,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskMaidTeaMemberInfo)]
        public static void AskMaidTeaMemberInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskMaidTeaMemberInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMaidTeaMemberInfo,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskNewLink)]
        public static void AskNewLinkHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskNewLink");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskNewLink,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskNewRoom)]
        public static void AskNewRoomHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskNewRoom");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskNewRoom,
            };
            conn.SendPacket(rsp);
        }


        [Handler(MethodId.AskQueryTeamInfoByPid)]
        public static void AskQueryTeamInfoByPidHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskQueryTeamInfoByPid");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskQueryTeamInfoByPid,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskReplyToFriendLinkInvite)]
        public static void AskReplyToFriendLinkInviteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskReplyToFriendLinkInvite");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskReplyToFriendLinkInvite,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskReplyToFriendRoomInvite)]
        public static void AskReplyToFriendRoomInviteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskReplyToFriendRoomInvite");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskReplyToFriendRoomInvite,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskResponseTeamInvite)]
        public static void AskResponseTeamInviteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskResponseTeamInvite");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskResponseTeamInvite,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskSetPersonalTeamSetting)]
        public static void AskSetPersonalTeamSettingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskSetPersonalTeamSetting");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSetPersonalTeamSetting,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskSetTeamSetting)]
        public static void AskSetTeamSettingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskSetTeamSetting");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSetTeamSetting,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskStartRoomMatch)]
        public static void AskStartRoomMatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskStartRoomMatch");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskStartRoomMatch,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskSwitchLinkMode)]
        public static void AskSwitchLinkModeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team/Link] AskSwitchLinkMode");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSwitchLinkMode,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Misc (24 handlers)


        [Handler(MethodId.AskBuyMiniGameTicket)]
        public static void AskBuyMiniGameTicketHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskBuyMiniGameTicket");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskBuyMiniGameTicket,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskChangePrepareSetting)]
        public static void AskChangePrepareSettingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskChangePrepareSetting");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskChangePrepareSetting,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDoInteractBindPerformance)]
        public static void AskDoInteractBindPerformanceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskDoInteractBindPerformance");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDoInteractBindPerformance,
            };
            conn.SendPacket(rsp);
        }


        [Handler(MethodId.AskGetAcceptedOrderWraps)]
        public static void AskGetAcceptedOrderWrapsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskGetAcceptedOrderWraps");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetAcceptedOrderWraps,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskGetFinishedOrderWraps)]
        public static void AskGetFinishedOrderWrapsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskGetFinishedOrderWraps");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetFinishedOrderWraps,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskHotPatch)]
        public static void AskHotPatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskHotPatch");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskHotPatch,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskInvitePlayerInteractionAction)]
        public static void AskInvitePlayerInteractionActionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskInvitePlayerInteractionAction");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskInvitePlayerInteractionAction,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskMiniGame_BeeSettlement)]
        public static void AskMiniGame_BeeSettlementHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskMiniGame_BeeSettlement");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMiniGame_BeeSettlement,
            };
            conn.SendPacket(rsp);
        }


        [Handler(MethodId.AskPlanningBoardSelectStepOption)]
        public static void AskPlanningBoardSelectStepOptionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskPlanningBoardSelectStepOption");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPlanningBoardSelectStepOption,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPlayGameAgain)]
        public static void AskPlayGameAgainHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskPlayGameAgain");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPlayGameAgain,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPlayGameNext)]
        public static void AskPlayGameNextHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskPlayGameNext");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPlayGameNext,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskReadCommodities)]
        public static void AskReadCommoditiesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskReadCommodities");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskReadCommodities,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskRemainChangeNameCount)]
        public static void AskRemainChangeNameCountHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskRemainChangeNameCount");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskRemainChangeNameCount,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskReport)]
        public static void AskReportHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskReport");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskReport,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskReportDoublePose)]
        public static void AskReportDoublePoseHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskReportDoublePose");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskReportDoublePose,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskReportSinglePose)]
        public static void AskReportSinglePoseHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskReportSinglePose");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskReportSinglePose,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskSendInteractionInfo)]
        public static void AskSendInteractionInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskSendInteractionInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSendInteractionInfo,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskSendInteractionInfoToWatchee)]
        public static void AskSendInteractionInfoToWatcheeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskSendInteractionInfoToWatchee");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSendInteractionInfoToWatchee,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskStartPlayerInteractionAction)]
        public static void AskStartPlayerInteractionActionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskStartPlayerInteractionAction");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskStartPlayerInteractionAction,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskTimePanelInfo)]
        public static void AskTimePanelInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskTimePanelInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskTimePanelInfo,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskTrackEvent)]
        public static void AskTrackEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Misc] AskTrackEvent");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskTrackEvent,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region NPC (17 handlers)

        [Handler(MethodId.AskBegBehavior)]
        public static void AskBegBehaviorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[NPC] AskBegBehavior");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskBegBehavior,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskCancelNpcProfileNew)]
        public static void AskCancelNpcProfileNewHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[NPC] AskCancelNpcProfileNew");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskCancelNpcProfileNew,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskCloseNpcShop)]
        public static void AskCloseNpcShopHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[NPC] AskCloseNpcShop");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskCloseNpcShop,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskGetNpcGroupPhotos)]
        public static void AskGetNpcGroupPhotosHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[NPC] AskGetNpcGroupPhotos");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetNpcGroupPhotos,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskGiveToBeggar)]
        public static void AskGiveToBeggarHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[NPC] AskGiveToBeggar");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGiveToBeggar,
            };
            conn.SendPacket(rsp);
        }

        // AskHackingNpcPress handled in ClientToGameserver.SaimoHack.cs

        [Handler(MethodId.AskHotSpringInviteCompanionNpc)]
        public static void AskHotSpringInviteCompanionNpcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[NPC] AskHotSpringInviteCompanionNpc");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskHotSpringInviteCompanionNpc,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskInteractNpcWithGift)]
        public static void AskInteractNpcWithGiftHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[NPC] AskInteractNpcWithGift");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskInteractNpcWithGift,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskNpcInteractionActionFinish)]
        public static void AskNpcInteractionActionFinishHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[NPC] AskNpcInteractionActionFinish");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskNpcInteractionActionFinish,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskNpcShareTimeInfo)]
        public static void AskNpcShareTimeInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[NPC] AskNpcShareTimeInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskNpcShareTimeInfo,
            };
            conn.SendPacket(rsp);
        }


        [Handler(MethodId.AskOnNpcAttractedByBeg)]
        public static void AskOnNpcAttractedByBegHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[NPC] AskOnNpcAttractedByBeg");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskOnNpcAttractedByBeg,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskRestaurantInviteNpc)]
        public static void AskRestaurantInviteNpcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[NPC] AskRestaurantInviteNpc");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskRestaurantInviteNpc,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskTakeNpcProfileMaxTrustReward)]
        public static void AskTakeNpcProfileMaxTrustRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[NPC] AskTakeNpcProfileMaxTrustReward");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskTakeNpcProfileMaxTrustReward,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskTakeNpcProfileProgressReward)]
        public static void AskTakeNpcProfileProgressRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[NPC] AskTakeNpcProfileProgressReward");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskTakeNpcProfileProgressReward,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskTakeNpcProfileTrustReward)]
        public static void AskTakeNpcProfileTrustRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[NPC] AskTakeNpcProfileTrustReward");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskTakeNpcProfileTrustReward,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskTriggerNpcQueuedEvent)]
        public static void AskTriggerNpcQueuedEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[NPC] AskTriggerNpcQueuedEvent");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskTriggerNpcQueuedEvent,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Diviner (15 handlers)

        [Handler(MethodId.AskDivinerCheckSpecialEvent)]
        public static void AskDivinerCheckSpecialEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerCheckSpecialEvent");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDivinerCheckSpecialEvent,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDivinerChooseBranch)]
        public static void AskDivinerChooseBranchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerChooseBranch");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDivinerChooseBranch,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDivinerEnterBattle)]
        public static void AskDivinerEnterBattleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerEnterBattle");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDivinerEnterBattle,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDivinerFinishPersuade)]
        public static void AskDivinerFinishPersuadeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerFinishPersuade");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDivinerFinishPersuade,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDivinerFinishRequestAppeal)]
        public static void AskDivinerFinishRequestAppealHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerFinishRequestAppeal");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDivinerFinishRequestAppeal,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDivinerPersuade)]
        public static void AskDivinerPersuadeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerPersuade");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDivinerPersuade,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDivinerRequestAppeal)]
        public static void AskDivinerRequestAppealHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerRequestAppeal");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDivinerRequestAppeal,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDivinerStartTimeCheck)]
        public static void AskDivinerStartTimeCheckHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerStartTimeCheck");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDivinerStartTimeCheck,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDivinerTakeCommission)]
        public static void AskDivinerTakeCommissionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerTakeCommission");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDivinerTakeCommission,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDivinerTriggerResult)]
        public static void AskDivinerTriggerResultHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerTriggerResult");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDivinerTriggerResult,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDivinerUpdatePersuadeProgress)]
        public static void AskDivinerUpdatePersuadeProgressHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerUpdatePersuadeProgress");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDivinerUpdatePersuadeProgress,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskEnterDivinerGame)]
        public static void AskEnterDivinerGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskEnterDivinerGame");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskEnterDivinerGame,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskLeaveDivinerGame)]
        public static void AskLeaveDivinerGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskLeaveDivinerGame");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskLeaveDivinerGame,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskStartDivinerGame)]
        public static void AskStartDivinerGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskStartDivinerGame");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskStartDivinerGame,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskStartDivinerGameWithDemand)]
        public static void AskStartDivinerGameWithDemandHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskStartDivinerGameWithDemand");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskStartDivinerGameWithDemand,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Police (14 handlers)

        [Handler(MethodId.AskAbandonPoliceTask)]
        public static void AskAbandonPoliceTaskHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Police] AskAbandonPoliceTask");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskAbandonPoliceTask,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskAcceptPoliceTask)]
        public static void AskAcceptPoliceTaskHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Police] AskAcceptPoliceTask");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskAcceptPoliceTask,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPoliceDispatch)]
        public static void AskPoliceDispatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Police] AskPoliceDispatch");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPoliceDispatch,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPoliceEffectiveExam)]
        public static void AskPoliceEffectiveExamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Police] AskPoliceEffectiveExam");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPoliceEffectiveExam,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPoliceEscortNpc)]
        public static void AskPoliceEscortNpcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Police] AskPoliceEscortNpc");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPoliceEscortNpc,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPoliceExamInteract)]
        public static void AskPoliceExamInteractHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Police] AskPoliceExamInteract");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPoliceExamInteract,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPoliceExitEscortOrExam)]
        public static void AskPoliceExitEscortOrExamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Police] AskPoliceExitEscortOrExam");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPoliceExitEscortOrExam,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPoliceFakeFileAcceptTaskEvent)]
        public static void AskPoliceFakeFileAcceptTaskEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Police] AskPoliceFakeFileAcceptTaskEvent");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPoliceFakeFileAcceptTaskEvent,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPoliceFineNpc)]
        public static void AskPoliceFineNpcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Police] AskPoliceFineNpc");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPoliceFineNpc,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPolicePrepareEscort)]
        public static void AskPolicePrepareEscortHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Police] AskPolicePrepareEscort");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPolicePrepareEscort,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPolicePrepareExam)]
        public static void AskPolicePrepareExamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Police] AskPolicePrepareExam");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPolicePrepareExam,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPoliceStopHelicopterDispatch)]
        public static void AskPoliceStopHelicopterDispatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Police] AskPoliceStopHelicopterDispatch");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPoliceStopHelicopterDispatch,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPoliceTakeCaseReward)]
        public static void AskPoliceTakeCaseRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Police] AskPoliceTakeCaseReward");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPoliceTakeCaseReward,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskSkipPoliceTask)]
        public static void AskSkipPoliceTaskHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Police] AskSkipPoliceTask");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSkipPoliceTask,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Truck (13 handlers)

        // All Truck handlers moved to DeliveryJobHandlers.cs
        // AskAcceptTruckJobOrder, AskAutoAcceptTruckJobOrder, AskDoTruckNpcAction,
        // AskGetTruckJobOrders, AskGetTruckSatisfactionAverage, AskObsoleteTruckJobOrder,
        // AskPreSettleTruckOrder, AskQueryTruckPosInfo, AskRefreshTruckOrder,
        // AskResetTruckOrderGoods, AskSetTruckJobDefaultVehicleId, AskSettleTruckOrder,
        // AskStartTruckOrderGuide

        #endregion

        #region BVB (8 handlers)

        [Handler(MethodId.AskBVBDebugSelectNpcFightPokemon)]
        public static void AskBVBDebugSelectNpcFightPokemonHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[BVB] AskBVBDebugSelectNpcFightPokemon");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskBVBDebugSelectNpcFightPokemon,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskBVBGetReady)]
        public static void AskBVBGetReadyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[BVB] AskBVBGetReady");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskBVBGetReady,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskBVBLinkGameSelectTeam)]
        public static void AskBVBLinkGameSelectTeamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[BVB] AskBVBLinkGameSelectTeam");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskBVBLinkGameSelectTeam,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskBVBLockChaosBuffCandidates)]
        public static void AskBVBLockChaosBuffCandidatesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[BVB] AskBVBLockChaosBuffCandidates");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskBVBLockChaosBuffCandidates,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskBVBRefreshChaosBuffCandidates)]
        public static void AskBVBRefreshChaosBuffCandidatesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[BVB] AskBVBRefreshChaosBuffCandidates");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskBVBRefreshChaosBuffCandidates,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskBVBSelectChaosBuff)]
        public static void AskBVBSelectChaosBuffHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[BVB] AskBVBSelectChaosBuff");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskBVBSelectChaosBuff,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskBVBSelectFightPokemonList)]
        public static void AskBVBSelectFightPokemonListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[BVB] AskBVBSelectFightPokemonList");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskBVBSelectFightPokemonList,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskFeiSuoSuccess)]
        public static void AskFeiSuoSuccessHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[FeiSuo] AskFeiSuoSuccess");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFeiSuoSuccess);
        }

        #endregion

        #region Job (7 handlers)

        // AskActiveSpiritJobTalentLayer → moved to SpiritTalentHandlers.cs

        [Handler(MethodId.AskApplyDutySwap)]
        public static void AskApplyDutySwapHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Job] AskApplyDutySwap");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskApplyDutySwap,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskConfirmDutySwap)]
        public static void AskConfirmDutySwapHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Job] AskConfirmDutySwap");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskConfirmDutySwap,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskFinishJob)]
        public static void AskFinishJobHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Job] AskFinishJob");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskFinishJob,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskQuitJob)]
        public static void AskQuitJobHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Job] AskQuitJob");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskQuitJob,
            };
            conn.SendPacket(rsp);
        }

        // AskResetSpiritJobTalent → moved to SpiritTalentHandlers.cs

        [Handler(MethodId.AskTakeJob)]
        public static void AskTakeJobHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Job] AskTakeJob");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskTakeJob,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Computer (6 handlers)

        [Handler(MethodId.AskComputerDeleteEmail)]
        public static void AskComputerDeleteEmailHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Computer] AskComputerDeleteEmail");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskComputerDeleteEmail,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskComputerDeleteFile)]
        public static void AskComputerDeleteFileHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Computer] AskComputerDeleteFile");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskComputerDeleteFile,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskComputerEmailRead)]
        public static void AskComputerEmailReadHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Computer] AskComputerEmailRead");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskComputerEmailRead,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskComputerEmailScrollToBottom)]
        public static void AskComputerEmailScrollToBottomHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Computer] AskComputerEmailScrollToBottom");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskComputerEmailScrollToBottom,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskComputerFileRead)]
        public static void AskComputerFileReadHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Computer] AskComputerFileRead");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskComputerFileRead,
            };
            conn.SendPacket(rsp);
        }


        #endregion

        #region House (5 handlers)

        // AskAddBuildHouseIndoor → moved to HousingHandlers.cs
        // AskChangeBuildHouseIndoor → moved to HousingHandlers.cs
        // AskRemoveBuildHouseIndoor → moved to HousingHandlers.cs
        // AskTeleportFromHouseGarage → moved to HousingHandlers.cs
        // AskTeleportToHouseGarage → moved to HousingHandlers.cs

        #endregion

        #region Bartender (5 handlers)

        [Handler(MethodId.AskBartenderCustomerLeave)]
        public static void AskBartenderCustomerLeaveHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Bartender] AskBartenderCustomerLeave");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskBartenderCustomerLeave,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskBartenderGameSettlement)]
        public static void AskBartenderGameSettlementHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Bartender] AskBartenderGameSettlement");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskBartenderGameSettlement,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskBartendingByDrinkMenu)]
        public static void AskBartendingByDrinkMenuHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Bartender] AskBartendingByDrinkMenu");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskBartendingByDrinkMenu,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskEndBartenderGame)]
        public static void AskEndBartenderGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Bartender] AskEndBartenderGame");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskEndBartenderGame,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskStartBartenderGame)]
        public static void AskStartBartenderGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Bartender] AskStartBartenderGame");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskStartBartenderGame,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Challenge (5 handlers)

        [Handler(MethodId.AskChallengeRecord)]
        public static void AskChallengeRecordHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Challenge] AskChallengeRecord");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskChallengeRecord,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskChallengeTeleport)]
        public static void AskChallengeTeleportHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Challenge] AskChallengeTeleport");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskChallengeTeleport,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskClaimChallengeTaskReward)]
        public static void AskClaimChallengeTaskRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Challenge] AskClaimChallengeTaskReward");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskClaimChallengeTaskReward,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskNewChallengeRecord)]
        public static void AskNewChallengeRecordHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Challenge] AskNewChallengeRecord");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskNewChallengeRecord,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskNewChallengeTeleport)]
        public static void AskNewChallengeTeleportHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Challenge] AskNewChallengeTeleport");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskNewChallengeTeleport,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Match (5 handlers)

        [Handler(MethodId.AskConfirmMatchResult)]
        public static void AskConfirmMatchResultHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Match] AskConfirmMatchResult");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskConfirmMatchResult,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskReadyToPlay)]
        public static void AskReadyToPlayHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Match] AskReadyToPlay");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskReadyToPlay,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskStartGame)]
        public static void AskStartGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Match] AskStartGame");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskStartGame,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskStartSingleMatch)]
        public static void AskStartSingleMatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Match] AskStartSingleMatch");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskStartSingleMatch,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskStopMatch)]
        public static void AskStopMatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Match] AskStopMatch");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskStopMatch,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Guide (5 handlers)



        [Handler(MethodId.AskFinishGuideTeachRead)]
        public static void AskFinishGuideTeachReadHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Guide] AskFinishGuideTeachRead called");
            try
            {
                if (msg.Args != null && msg.Args.Length >= 4)
                {
                    int guideId = BitConverter.ToInt32(msg.Args, 0);
                    Console.WriteLine($"[Guide] FinishGuideTeachRead: guideId={guideId} → completed");
                }
            }
            catch { }
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskFinishGuideTeachRead,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskSlowGuide)]
        public static void AskSlowGuideHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Guide] AskSlowGuide called");
            // Client requests to slow down guide animations/instructions
            try
            {
                if (msg.Args != null && msg.Args.Length >= 4)
                {
                    int guideId = BitConverter.ToInt32(msg.Args, 0);
                    Console.WriteLine($"[Guide] SlowGuide: guideId={guideId}");
                }
            }
            catch { }
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSlowGuide,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskStartGuideByClient)]
        public static void AskStartGuideByClientHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Guide] AskStartGuideByClient called");
            // Client initiates a guide/tutorial step
            try
            {
                if (msg.Args != null && msg.Args.Length >= 4)
                {
                    int guideId = BitConverter.ToInt32(msg.Args, 0);
                    Console.WriteLine($"[Guide] StartGuideByClient: guideId={guideId} → started");
                }
            }
            catch { }
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskStartGuideByClient,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Shop (4 handlers)


        [Handler(MethodId.AskMallBuyBundle)]
        public static void AskMallBuyBundleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Shop] AskMallBuyBundle");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMallBuyBundle,
            };
            conn.SendPacket(rsp);
        }


        [Handler(MethodId.AskPurchaseElement)]
        public static void AskPurchaseElementHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Shop] AskPurchaseElement");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPurchaseElement,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Item (4 handlers)

        [Handler(MethodId.AskEnemyItemPickUp)]
        public static void AskEnemyItemPickUpHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Item] AskEnemyItemPickUp");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskEnemyItemPickUp,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskItemCountRecord)]
        public static void AskItemCountRecordHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Item] AskItemCountRecord");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskItemCountRecord,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskSubmitItemsByTask)]
        public static void AskSubmitItemsByTaskHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Item] AskSubmitItemsByTask");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSubmitItemsByTask,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskUseItemToFightSpirit)]
        public static void AskUseItemToFightSpiritHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Item] AskUseItemToFightSpirit");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskUseItemToFightSpirit,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Craft (4 handlers)

        [Handler(MethodId.AskItemBreakdown)]
        public static void AskItemBreakdownHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Craft] AskItemBreakdown");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskItemBreakdown,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskItemExchange)]
        public static void AskItemExchangeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Craft] AskItemExchange");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskItemExchange,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskItemProduce)]
        public static void AskItemProduceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Craft] AskItemProduce");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskItemProduce,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskTakeItemProduced)]
        public static void AskTakeItemProducedHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Craft] AskTakeItemProduced");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskTakeItemProduced,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Hacker (3 handlers)

        // AskAcceptHackerPostTask → moved to HackerHandlers.cs
        // AskChangeHackerName → moved to HackerHandlers.cs
        // AskReadHackerNewPost → moved to HackerHandlers.cs

        #endregion

        #region Washer (3 handlers)

        [Handler(MethodId.AskAcceptWasherMission)]
        public static void AskAcceptWasherMissionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Washer] AskAcceptWasherMission");
            
            // Generate a mission ID (in a real implementation, this would come from args or config)
            uint missionId = 1;
            
            // Add to accepted missions if not already there
            if (!conn.AcceptedWasherMissions.Contains(missionId))
                conn.AcceptedWasherMissions.Add(missionId);
            
            conn.CurrentWasherMissionId = missionId;
            
            // Initialize progress for this mission
            if (!conn.WasherMissionProgress.ContainsKey(missionId))
                conn.WasherMissionProgress[missionId] = 0.0f;
            
            Console.WriteLine($"[Washer] Mission {missionId} accepted, progress initialized to 0%");
            
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskAcceptWasherMission,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskFinishWasherMission)]
        public static void AskFinishWasherMissionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Washer] AskFinishWasherMission");
            
            uint missionId = conn.CurrentWasherMissionId ?? 0;
            
            if (missionId > 0)
            {
                // Mark as finished
                conn.FinishedWasherMissions.Add(missionId);
                conn.AcceptedWasherMissions.Remove(missionId);
                
                // Set progress to 100%
                conn.WasherMissionProgress[missionId] = 1.0f;
                
                conn.CurrentWasherMissionId = null;
                
                Console.WriteLine($"[Washer] Mission {missionId} finished, progress set to 100%");
            }
            
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskFinishWasherMission,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskGetWasherMissionInfo)]
        public static void AskGetWasherMissionInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Washer] AskGetWasherMissionInfo");
            
            uint currentMissionId = conn.CurrentWasherMissionId ?? 0;
            float progress = 0.0f;
            
            if (currentMissionId > 0 && conn.WasherMissionProgress.ContainsKey(currentMissionId))
                progress = conn.WasherMissionProgress[currentMissionId];
            
            Console.WriteLine($"[Washer] Current mission: {currentMissionId}, progress: {progress * 100:F1}%");
            
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetWasherMissionInfo,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Scene (3 handlers)

        [Handler(MethodId.AskAddRaidGamePlayRecordDoubleVa)]
        public static void AskAddRaidGamePlayRecordDoubleVaHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Scene] AskAddRaidGamePlayRecordDoubleVa");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskAddRaidGamePlayRecordDoubleVa,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPlayerChangePositionByScenePo)]
        public static void AskPlayerChangePositionByScenePoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Scene] AskPlayerChangePositionByScenePo");
            
            // Parse scene point data if available
            uint scenePointId = 0;
            try
            {
                if (msg.Args != null && msg.Args.Length >= 4)
                {
                    scenePointId = BitConverter.ToUInt32(msg.Args, 0);
                }
            }
            catch { }
            
            Console.WriteLine($"[Scene] ChangePositionByScenePoint: scenePointId={scenePointId}");
            
            // Sync player position to the scene point
            var currentSpirit = conn.GetCurrentSpirit();
            if (currentSpirit != null)
            {
                conn.SendSyncPosition(currentSpirit.Id);
            }
            
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPlayerChangePositionByScenePo,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskPublicSwitchToPublicScene)]
        public static void AskPublicSwitchToPublicSceneHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Scene] AskPublicSwitchToPublicScene");
            
            // Parse scene data if available
            uint targetSceneId = 0;
            try
            {
                if (msg.Args != null && msg.Args.Length >= 4)
                {
                    targetSceneId = BitConverter.ToUInt32(msg.Args, 0);
                }
            }
            catch { }
            
            Console.WriteLine($"[Scene] PublicSwitchToPublicScene: targetSceneId={targetSceneId}");
            
            // Send scene transition notification
            MissingSyncHandlers.SendSyncPrepareMapEntrance(conn);
            
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPublicSwitchToPublicScene,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Claw (3 handlers)

        [Handler(MethodId.AskClawBuyTicket)]
        public static void AskClawBuyTicketHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Claw] AskClawBuyTicket");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskClawBuyTicket,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskClawDateFail)]
        public static void AskClawDateFailHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Claw] AskClawDateFail");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskClawDateFail,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskClawSettlement)]
        public static void AskClawSettlementHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Claw] AskClawSettlement");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskClawSettlement,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Firework (3 handlers)

        [Handler(MethodId.AskFireworkBuyTicket)]
        public static void AskFireworkBuyTicketHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Firework] AskFireworkBuyTicket");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskFireworkBuyTicket,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskFireworkTriggerPlan)]
        public static void AskFireworkTriggerPlanHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Firework] AskFireworkTriggerPlan");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskFireworkTriggerPlan,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskFireworkWorkStoreInfo)]
        public static void AskFireworkWorkStoreInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Firework] AskFireworkWorkStoreInfo");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskFireworkWorkStoreInfo,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region HotSpring (3 handlers)

        [Handler(MethodId.AskHotSpringSettlement)]
        public static void AskHotSpringSettlementHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[HotSpring] AskHotSpringSettlement");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskHotSpringSettlement,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskHotSpringStart)]
        public static void AskHotSpringStartHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[HotSpring] AskHotSpringStart");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskHotSpringStart,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskHotSpringUseTicket)]
        public static void AskHotSpringUseTicketHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[HotSpring] AskHotSpringUseTicket");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskHotSpringUseTicket,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Phone (2 handlers)

        [Handler(MethodId.AskPhoneAddCallRecord)]
        public static void AskPhoneAddCallRecordHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Phone] AskPhoneAddCallRecord");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPhoneAddCallRecord,
            };
            conn.SendPacket(rsp);
        }


        #endregion

        #region BattlePass (1 handlers)

        [Handler(MethodId.AskBuyBattlePassLevels)]
        public static void AskBuyBattlePassLevelsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[BattlePass] AskBuyBattlePassLevels");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskBuyBattlePassLevels,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Spirit (1 handlers)

        // AskConvertCommonSpiritTalentExp → moved to SpiritTalentHandlers.cs

        #endregion

        #region Gacha (1 handlers)


        #endregion

        #region Mail (1 handlers)


        #endregion

        #region MaidTea (1 handlers)

        [Handler(MethodId.AskMaidTeaSettlement)]
        public static void AskMaidTeaSettlementHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[MaidTea] AskMaidTeaSettlement");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMaidTeaSettlement,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region PersonalZone (1 handlers)

        [Handler(MethodId.AskPersonalZoneUpdateSpiritList)]
        public static void AskPersonalZoneUpdateSpiritListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[PersonalZone] AskPersonalZoneUpdateSpiritList");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPersonalZoneUpdateSpiritList,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Enemy (1 handlers)

        [Handler(MethodId.AskRemoveEnemyStiff)]
        public static void AskRemoveEnemyStiffHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Enemy] AskRemoveEnemyStiff");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskRemoveEnemyStiff,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Restaurant (1 handlers)

        [Handler(MethodId.AskRestaurantBuyFoods)]
        public static void AskRestaurantBuyFoodsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Restaurant] AskRestaurantBuyFoods");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskRestaurantBuyFoods,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Pokemon (1 handlers)

        [Handler(MethodId.AskSetPokemonLockState)]
        public static void AskSetPokemonLockStateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Pokemon] AskSetPokemonLockState");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskSetPokemonLockState,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Mahjong (1 handlers)

        [Handler(MethodId.AskStartMahjongGame)]
        public static void AskStartMahjongGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Mahjong] AskStartMahjongGame");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskStartMahjongGame,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Report (1 handlers)

        [Handler(MethodId.ReportLocation)]
        public static void ReportLocationHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Report] ReportLocation");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ReportLocation,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Police (2 handlers)

        [Handler(MethodId.UsePoliceChargingProgress)]
        public static void UsePoliceChargingProgressHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Police] UsePoliceChargingProgress");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.UsePoliceChargingProgress,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AddPoliceChargingProgress)]
        public static void AddPoliceChargingProgressHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Police] AddPoliceChargingProgress");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AddPoliceChargingProgress,
            };
            conn.SendPacket(rsp);
        }

        #endregion

        #region Team Match (2 handlers)

        [Handler(MethodId.StartMatchInTeam)]
        public static void StartMatchInTeamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team] StartMatchInTeam");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.StartMatchInTeam,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.StartGameInTeam)]
        public static void StartGameInTeamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team] StartGameInTeam");
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.StartGameInTeam,
            };
            conn.SendPacket(rsp);
        }

        #endregion

    }
}