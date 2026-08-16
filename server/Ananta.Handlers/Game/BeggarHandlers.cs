using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public class AskGiveToBeggarArg : SerializedClass
    {
        public uint npcid;
        public uint itemid;
        public uint count;
        public AskGiveToBeggarArg() { onlyFields = true; }
    }

    public static class BeggarHandlers
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

        [Handler(MethodId.AskGiveToBeggar)]
        public static void AskGiveToBeggarHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskGiveToBeggarArg>();
            Console.WriteLine($"[Beggar] AskGiveToBeggar npc={args.npcid} item={args.itemid} count={args.count}");

            SendEmptySuccessReturn(conn, msg, MethodId.AskGiveToBeggar);
        }

        [Handler(MethodId.AskBegBehavior)]
        public static void AskBegBehaviorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Beggar] AskBegBehavior");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBegBehavior);
        }

        [Handler(MethodId.AskOnNpcAttractedByBeg)]
        public static void AskOnNpcAttractedByBegHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Beggar] AskOnNpcAttractedByBeg");
            SendEmptySuccessReturn(conn, msg, MethodId.AskOnNpcAttractedByBeg);
        }
    }
}
