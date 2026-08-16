using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public class AskStartSingleMatchArg : SerializedClass
    {
        public uint matchtype;
        public AskStartSingleMatchArg() { onlyFields = true; }
    }

    public class AskConfirmMatchResultArg : SerializedClass
    {
        public AskConfirmMatchResultArg() { onlyFields = true; }
    }

    public static class MatchHandlers
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

        [Handler(MethodId.AskStartSingleMatch)]
        public static void AskStartSingleMatchHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskStartSingleMatchArg>();
            Console.WriteLine($"[Match] AskStartSingleMatch type={args.matchtype}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStartSingleMatch);
        }

        [Handler(MethodId.AskStartRoomMatch)]
        public static void AskStartRoomMatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Match] AskStartRoomMatch");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStartRoomMatch);
        }

        [Handler(MethodId.AskStopMatch)]
        public static void AskStopMatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Match] AskStopMatch");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStopMatch);
        }

        [Handler(MethodId.AskConfirmMatchResult)]
        public static void AskConfirmMatchResultHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Match] AskConfirmMatchResult");
            SendEmptySuccessReturn(conn, msg, MethodId.AskConfirmMatchResult);
        }

        [Handler(MethodId.AskReadyToPlay)]
        public static void AskReadyToPlayHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Match] AskReadyToPlay");
            SendEmptySuccessReturn(conn, msg, MethodId.AskReadyToPlay);
        }

        [Handler(MethodId.AskStartGame)]
        public static void AskStartGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Match] AskStartGame");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStartGame);
        }

        [Handler(MethodId.StartMatchInTeam)]
        public static void StartMatchInTeamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Match] StartMatchInTeam");
            SendEmptySuccessReturn(conn, msg, MethodId.StartMatchInTeam);
        }

        [Handler(MethodId.StartGameInTeam)]
        public static void StartGameInTeamHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Match] StartGameInTeam");
            SendEmptySuccessReturn(conn, msg, MethodId.StartGameInTeam);
        }
    }
}
