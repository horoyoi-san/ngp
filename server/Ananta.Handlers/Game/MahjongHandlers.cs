using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public static class MahjongHandlers
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

        [Handler(MethodId.AskStartMahjongGame)]
        public static void AskStartMahjongGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Mahjong] AskStartMahjongGame");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStartMahjongGame);
        }

        [Handler(MethodId.AskMahjongInfo)]
        public static void AskMahjongInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Mahjong] AskMahjongInfo");
            var playerInfo = new PlayerMahjongInfo()
            {
            };

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskMahjongInfo,
            };
            rsp.SetArgs(MethodId.AskMahjongInfo, playerInfo);
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.CheckMahjongInfo)]
        public static void CheckMahjongInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Mahjong] CheckMahjongInfo");
            SendEmptySuccessReturn(conn, msg, MethodId.CheckMahjongInfo);
        }

        [Handler(MethodId.GetMahjongRankReward)]
        public static void GetMahjongRankRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Mahjong] GetMahjongRankReward");
            SendEmptySuccessReturn(conn, msg, MethodId.GetMahjongRankReward);
        }

        [Handler(MethodId.MahjongChat)]
        public static void MahjongChatHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Mahjong] MahjongChat");
            SendEmptySuccessReturn(conn, msg, MethodId.MahjongChat);
        }

        [Handler(MethodId.BackToMahjong)]
        public static void BackToMahjongHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Mahjong] BackToMahjong");
            SendEmptySuccessReturn(conn, msg, MethodId.BackToMahjong);
        }
    }
}
