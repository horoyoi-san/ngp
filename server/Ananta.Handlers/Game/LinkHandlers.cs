using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public class AskNewLinkArg : SerializedClass
    {
        public uint linkmode;
        public AskNewLinkArg() { onlyFields = true; }
    }

    public class AskSwitchLinkModeArg : SerializedClass
    {
        public uint linkmode;
        public AskSwitchLinkModeArg() { onlyFields = true; }
    }

    public class AskInviteFriendToLinkArg : SerializedClass
    {
        public ulong friendpid;
        public AskInviteFriendToLinkArg() { onlyFields = true; }
    }

    public class AskReplyToFriendLinkInviteArg : SerializedClass
    {
        public ulong inviterpid;
        public bool accept;
        public AskReplyToFriendLinkInviteArg() { onlyFields = true; }
    }

    public class AskKickFriendFromLinkArg : SerializedClass
    {
        public ulong friendpid;
        public AskKickFriendFromLinkArg() { onlyFields = true; }
    }

    public class AskLeaveLinkArg : SerializedClass
    {
        public AskLeaveLinkArg() { onlyFields = true; }
    }

    public class AskLinkInfoArg : SerializedClass
    {
        public uint linkmode;
        public AskLinkInfoArg() { onlyFields = true; }
    }

    public class AskLinkWatchOtherArg : SerializedClass
    {
        public ulong targetpid;
        public AskLinkWatchOtherArg() { onlyFields = true; }
    }

    public class AskLinkWatcheeListArg : SerializedClass
    {
        public AskLinkWatcheeListArg() { onlyFields = true; }
    }

    public class AskLinkPlanningBoardDividendsPutArg : SerializedClass
    {
        public uint boardid;
        public uint amount;
        public AskLinkPlanningBoardDividendsPutArg() { onlyFields = true; }
    }

    public static class LinkHandlers
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

        [Handler(MethodId.AskNewLink)]
        public static void AskNewLinkHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskNewLinkArg>();
            Console.WriteLine($"[Link] AskNewLink mode={args.linkmode}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskNewLink);
        }

        [Handler(MethodId.AskSwitchLinkMode)]
        public static void AskSwitchLinkModeHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskSwitchLinkModeArg>();
            Console.WriteLine($"[Link] AskSwitchLinkMode mode={args.linkmode}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSwitchLinkMode);
        }

        [Handler(MethodId.AskInviteFriendToLink)]
        public static void AskInviteFriendToLinkHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskInviteFriendToLinkArg>();
            Console.WriteLine($"[Link] AskInviteFriendToLink friend={args.friendpid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskInviteFriendToLink);
        }

        [Handler(MethodId.AskReplyToFriendLinkInvite)]
        public static void AskReplyToFriendLinkInviteHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskReplyToFriendLinkInviteArg>();
            Console.WriteLine($"[Link] AskReplyToFriendLinkInvite inviter={args.inviterpid} accept={args.accept}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskReplyToFriendLinkInvite);
        }

        [Handler(MethodId.AskKickFriendFromLink)]
        public static void AskKickFriendFromLinkHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskKickFriendFromLinkArg>();
            Console.WriteLine($"[Link] AskKickFriendFromLink friend={args.friendpid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskKickFriendFromLink);
        }

        [Handler(MethodId.AskLeaveLink)]
        public static void AskLeaveLinkHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Link] AskLeaveLink");
            SendEmptySuccessReturn(conn, msg, MethodId.AskLeaveLink);
        }

        [Handler(MethodId.AskLinkInfo)]
        public static void AskLinkInfoHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskLinkInfoArg>();
            Console.WriteLine($"[Link] AskLinkInfo mode={args.linkmode}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskLinkInfo);
        }

        [Handler(MethodId.AskLinkInfos)]
        public static void AskLinkInfosHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Link] AskLinkInfos");
            SendEmptySuccessReturn(conn, msg, MethodId.AskLinkInfos);
        }

        [Handler(MethodId.AskLinkWatchOther)]
        public static void AskLinkWatchOtherHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskLinkWatchOtherArg>();
            Console.WriteLine($"[Link] AskLinkWatchOther target={args.targetpid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskLinkWatchOther);
        }

        [Handler(MethodId.AskLinkWatcheeList)]
        public static void AskLinkWatcheeListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Link] AskLinkWatcheeList");
            SendEmptySuccessReturn(conn, msg, MethodId.AskLinkWatcheeList);
        }

        [Handler(MethodId.AskLinkPlanningBoardDividendsPut)]
        public static void AskLinkPlanningBoardDividendsPutHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskLinkPlanningBoardDividendsPutArg>();
            Console.WriteLine($"[Link] AskLinkPlanningBoardDividendsPut board={args.boardid} amount={args.amount}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskLinkPlanningBoardDividendsPut);
        }
    }
}
