using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public class AskMaidTeaMemberInfoArg : SerializedClass
    {
        public AskMaidTeaMemberInfoArg() { onlyFields = true; }
    }

    public class AskMaidTeaSettlementArg : SerializedClass
    {
        public uint score;
        public AskMaidTeaSettlementArg() { onlyFields = true; }
    }

    public class AskPersonalZoneUpdateSpiritListArg : SerializedClass
    {
        public List<uint> spiritids;
        public AskPersonalZoneUpdateSpiritListArg() { onlyFields = true; }
    }

    public class AskBuyMiniGameTicketArg : SerializedClass
    {
        public uint minigametype;
        public AskBuyMiniGameTicketArg() { onlyFields = true; }
    }

    public class AskPlayGameAgainArg : SerializedClass
    {
        public uint minigametype;
        public AskPlayGameAgainArg() { onlyFields = true; }
    }

    public class AskPlayGameNextArg : SerializedClass
    {
        public uint minigametype;
        public AskPlayGameNextArg() { onlyFields = true; }
    }

    public static class MiniGameHandlers
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

        [Handler(MethodId.AskMaidTeaMemberInfo)]
        public static void AskMaidTeaMemberInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[MiniGame] AskMaidTeaMemberInfo");
            SendEmptySuccessReturn(conn, msg, MethodId.AskMaidTeaMemberInfo);
        }

        [Handler(MethodId.AskMaidTeaSettlement)]
        public static void AskMaidTeaSettlementHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskMaidTeaSettlementArg>();
            Console.WriteLine($"[MiniGame] AskMaidTeaSettlement score={args.score}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskMaidTeaSettlement);
        }

        [Handler(MethodId.AskPersonalZoneUpdateSpiritList)]
        public static void AskPersonalZoneUpdateSpiritListHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPersonalZoneUpdateSpiritListArg>();
            Console.WriteLine($"[MiniGame] AskPersonalZoneUpdateSpiritList spirits={args.spiritids?.Count ?? 0}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPersonalZoneUpdateSpiritList);
        }

        [Handler(MethodId.AskBuyMiniGameTicket)]
        public static void AskBuyMiniGameTicketHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskBuyMiniGameTicketArg>();
            Console.WriteLine($"[MiniGame] AskBuyMiniGameTicket type={args.minigametype}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskBuyMiniGameTicket);
        }

        [Handler(MethodId.AskPlayGameAgain)]
        public static void AskPlayGameAgainHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPlayGameAgainArg>();
            Console.WriteLine($"[MiniGame] AskPlayGameAgain type={args.minigametype}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPlayGameAgain);
        }

        [Handler(MethodId.AskPlayGameNext)]
        public static void AskPlayGameNextHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPlayGameNextArg>();
            Console.WriteLine($"[MiniGame] AskPlayGameNext type={args.minigametype}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPlayGameNext);
        }

        [Handler(MethodId.RecordDarts)]
        public static void RecordDartsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[MiniGame] RecordDarts");
            SendEmptySuccessReturn(conn, msg, MethodId.RecordDarts);
        }

        [Handler(MethodId.StartDarts)]
        public static void StartDartsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[MiniGame] StartDarts");
            SendEmptySuccessReturn(conn, msg, MethodId.StartDarts);
        }

        [Handler(MethodId.AskMiniGame_BeeSettlement)]
        public static void AskMiniGame_BeeSettlementHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[MiniGame] AskMiniGame_BeeSettlement");
            SendEmptySuccessReturn(conn, msg, MethodId.AskMiniGame_BeeSettlement);
        }
    }
}
