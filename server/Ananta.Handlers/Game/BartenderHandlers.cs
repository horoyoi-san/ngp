using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public class AskStartBartenderGameArg : SerializedClass
    {
        public uint npcid;
        public AskStartBartenderGameArg() { onlyFields = true; }
    }

    public class AskEndBartenderGameArg : SerializedClass
    {
        public AskEndBartenderGameArg() { onlyFields = true; }
    }

    public class AskBartenderGameSettlementArg : SerializedClass
    {
        public uint score;
        public AskBartenderGameSettlementArg() { onlyFields = true; }
    }

    public class AskBartendingByDrinkMenuArg : SerializedClass
    {
        public uint drinkid;
        public AskBartendingByDrinkMenuArg() { onlyFields = true; }
    }

    public class AskBartenderCustomerLeaveArg : SerializedClass
    {
        public uint customerid;
        public AskBartenderCustomerLeaveArg() { onlyFields = true; }
    }

    public static class BartenderHandlers
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

        [Handler(MethodId.AskStartBartenderGame)]
        public static void AskStartBartenderGameHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskStartBartenderGameArg>();
            Console.WriteLine($"[Bartender] AskStartBartenderGame npc={args.npcid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStartBartenderGame);
        }

        [Handler(MethodId.AskEndBartenderGame)]
        public static void AskEndBartenderGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Bartender] AskEndBartenderGame");
            SendEmptySuccessReturn(conn, msg, MethodId.AskEndBartenderGame);
        }

        [Handler(MethodId.AskBartenderGameSettlement)]
        public static void AskBartenderGameSettlementHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskBartenderGameSettlementArg>();
            Console.WriteLine($"[Bartender] AskBartenderGameSettlement score={args.score}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBartenderGameSettlement);
        }

        [Handler(MethodId.AskBartendingByDrinkMenu)]
        public static void AskBartendingByDrinkMenuHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskBartendingByDrinkMenuArg>();
            Console.WriteLine($"[Bartender] AskBartendingByDrinkMenu drink={args.drinkid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBartendingByDrinkMenu);
        }

        [Handler(MethodId.AskBartenderCustomerLeave)]
        public static void AskBartenderCustomerLeaveHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskBartenderCustomerLeaveArg>();
            Console.WriteLine($"[Bartender] AskBartenderCustomerLeave customer={args.customerid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBartenderCustomerLeave);
        }
    }
}
