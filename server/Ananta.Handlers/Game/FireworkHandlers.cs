using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public class AskFireworkBuyTicketArg : SerializedClass
    {
        public uint fireworkid;
        public AskFireworkBuyTicketArg() { onlyFields = true; }
    }

    public class AskFireworkTriggerPlanArg : SerializedClass
    {
        public uint planid;
        public AskFireworkTriggerPlanArg() { onlyFields = true; }
    }

    public static class FireworkHandlers
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

        [Handler(MethodId.AskFireworkBuyTicket)]
        public static void AskFireworkBuyTicketHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskFireworkBuyTicketArg>();
            Console.WriteLine($"[Firework] AskFireworkBuyTicket firework={args.fireworkid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFireworkBuyTicket);
        }

        [Handler(MethodId.AskFireworkTriggerPlan)]
        public static void AskFireworkTriggerPlanHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskFireworkTriggerPlanArg>();
            Console.WriteLine($"[Firework] AskFireworkTriggerPlan plan={args.planid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFireworkTriggerPlan);
        }

        [Handler(MethodId.AskFireworkWorkStoreInfo)]
        public static void AskFireworkWorkStoreInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Firework] AskFireworkWorkStoreInfo");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFireworkWorkStoreInfo);
        }
    }
}
