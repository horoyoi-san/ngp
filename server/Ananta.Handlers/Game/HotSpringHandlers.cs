using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public class AskHotSpringStartArg : SerializedClass
    {
        public uint npcid;
        public AskHotSpringStartArg() { onlyFields = true; }
    }

    public class AskHotSpringUseTicketArg : SerializedClass
    {
        public uint ticketid;
        public AskHotSpringUseTicketArg() { onlyFields = true; }
    }

    public class AskHotSpringSettlementArg : SerializedClass
    {
        public AskHotSpringSettlementArg() { onlyFields = true; }
    }

    public class AskHotSpringInviteCompanionNpcArg : SerializedClass
    {
        public uint npcid;
        public AskHotSpringInviteCompanionNpcArg() { onlyFields = true; }
    }

    public static class HotSpringHandlers
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

        [Handler(MethodId.AskHotSpringStart)]
        public static void AskHotSpringStartHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskHotSpringStartArg>();
            Console.WriteLine($"[HotSpring] AskHotSpringStart npc={args.npcid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskHotSpringStart);
        }

        [Handler(MethodId.AskHotSpringUseTicket)]
        public static void AskHotSpringUseTicketHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskHotSpringUseTicketArg>();
            Console.WriteLine($"[HotSpring] AskHotSpringUseTicket ticket={args.ticketid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskHotSpringUseTicket);
        }

        [Handler(MethodId.AskHotSpringSettlement)]
        public static void AskHotSpringSettlementHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[HotSpring] AskHotSpringSettlement");
            SendEmptySuccessReturn(conn, msg, MethodId.AskHotSpringSettlement);
        }

        [Handler(MethodId.AskHotSpringInviteCompanionNpc)]
        public static void AskHotSpringInviteCompanionNpcHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskHotSpringInviteCompanionNpcArg>();
            Console.WriteLine($"[HotSpring] AskHotSpringInviteCompanionNpc npc={args.npcid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskHotSpringInviteCompanionNpc);
        }
    }
}
