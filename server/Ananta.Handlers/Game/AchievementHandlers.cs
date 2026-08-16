using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public static class AchievementHandlers
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

        [Handler(MethodId.AskPlayerAchievements)]
        public static void AskPlayerAchievementsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Achievement] AskPlayerAchievements");
            var viewData = new AchievementViewData()
            {
            };

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskPlayerAchievements,
            };
            rsp.SetArgs(MethodId.AskPlayerAchievements, viewData);
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskGetAchievementReward)]
        public static void AskGetAchievementRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Achievement] AskGetAchievementReward");
            SendEmptySuccessReturn(conn, msg, MethodId.AskGetAchievementReward);
        }

        [Handler(MethodId.AskGetAllAchievementReward)]
        public static void AskGetAllAchievementRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Achievement] AskGetAllAchievementReward");
            SendEmptySuccessReturn(conn, msg, MethodId.AskGetAllAchievementReward);
        }

        [Handler(MethodId.AskChallengeRecord)]
        public static void AskChallengeRecordHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Achievement] AskChallengeRecord");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChallengeRecord);
        }

        [Handler(MethodId.AskChallengeTeleport)]
        public static void AskChallengeTeleportHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Achievement] AskChallengeTeleport");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChallengeTeleport);
        }

        [Handler(MethodId.AskClaimChallengeTaskReward)]
        public static void AskClaimChallengeTaskRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Achievement] AskClaimChallengeTaskReward");
            SendEmptySuccessReturn(conn, msg, MethodId.AskClaimChallengeTaskReward);
        }

        [Handler(MethodId.AskNewChallengeRecord)]
        public static void AskNewChallengeRecordHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Achievement] AskNewChallengeRecord");
            SendEmptySuccessReturn(conn, msg, MethodId.AskNewChallengeRecord);
        }

        [Handler(MethodId.AskNewChallengeTeleport)]
        public static void AskNewChallengeTeleportHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Achievement] AskNewChallengeTeleport");
            SendEmptySuccessReturn(conn, msg, MethodId.AskNewChallengeTeleport);
        }
    }
}
