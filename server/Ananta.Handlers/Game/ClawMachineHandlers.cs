using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public class AskClawBuyTicketArg : SerializedClass
    {
        public uint machineid;
        public AskClawBuyTicketArg() { onlyFields = true; }
    }

    public class AskClawSettlementArg : SerializedClass
    {
        public uint machineid;
        public bool win;
        public AskClawSettlementArg() { onlyFields = true; }
    }

    public class AskClawDateFailArg : SerializedClass
    {
        public uint machineid;
        public AskClawDateFailArg() { onlyFields = true; }
    }

    public static class ClawMachineHandlers
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

        [Handler(MethodId.AskClawBuyTicket)]
        public static void AskClawBuyTicketHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskClawBuyTicketArg>();
            Console.WriteLine($"[ClawMachine] AskClawBuyTicket machine={args.machineid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskClawBuyTicket);
        }

        [Handler(MethodId.AskClawSettlement)]
        public static void AskClawSettlementHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskClawSettlementArg>();
            Console.WriteLine($"[ClawMachine] AskClawSettlement machine={args.machineid} win={args.win}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskClawSettlement);
        }

        [Handler(MethodId.AskClawDateFail)]
        public static void AskClawDateFailHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskClawDateFailArg>();
            Console.WriteLine($"[ClawMachine] AskClawDateFail machine={args.machineid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskClawDateFail);
        }
    }
}
