using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public class AskPublishTuiteArg : SerializedClass
    {
        public string content;
        public AskPublishTuiteArg() { onlyFields = true; }
    }

    public class AskInteractTuiteArg : SerializedClass
    {
        public ulong tuiteid;
        public uint interacttype;
        public AskInteractTuiteArg() { onlyFields = true; }
    }

    public class AskCancelInteractTuiteArg : SerializedClass
    {
        public ulong tuiteid;
        public AskCancelInteractTuiteArg() { onlyFields = true; }
    }

    public class AskTakePopularityRewardArg : SerializedClass
    {
        public uint rewardid;
        public AskTakePopularityRewardArg() { onlyFields = true; }
    }

    public class AskClearPersonalZoneNewFansArg : SerializedClass
    {
        public AskClearPersonalZoneNewFansArg() { onlyFields = true; }
    }

    public class AskGetFansAutoGiveHistoryArg : SerializedClass
    {
        public AskGetFansAutoGiveHistoryArg() { onlyFields = true; }
    }

    public class AskDoAgentFansPerformanceArg : SerializedClass
    {
        public uint performanceid;
        public AskDoAgentFansPerformanceArg() { onlyFields = true; }
    }

    public class AskFinishWpFansPerformanceArg : SerializedClass
    {
        public uint performanceid;
        public AskFinishWpFansPerformanceArg() { onlyFields = true; }
    }

    public class AskStealNPCFanArg : SerializedClass
    {
        public ulong npcpid;
        public AskStealNPCFanArg() { onlyFields = true; }
    }

    public static class PopularityHandlers
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

        [Handler(MethodId.AskPublishTuite)]
        public static void AskPublishTuiteHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPublishTuiteArg>();
            Console.WriteLine($"[Popularity] AskPublishTuite content={args.content}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPublishTuite);
        }

        [Handler(MethodId.AskInteractTuite)]
        public static void AskInteractTuiteHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskInteractTuiteArg>();
            Console.WriteLine($"[Popularity] AskInteractTuite tuite={args.tuiteid} type={args.interacttype}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskInteractTuite);
        }

        [Handler(MethodId.AskCancelInteractTuite)]
        public static void AskCancelInteractTuiteHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskCancelInteractTuiteArg>();
            Console.WriteLine($"[Popularity] AskCancelInteractTuite tuite={args.tuiteid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCancelInteractTuite);
        }

        [Handler(MethodId.AskTakePopularityReward)]
        public static void AskTakePopularityRewardHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskTakePopularityRewardArg>();
            Console.WriteLine($"[Popularity] AskTakePopularityReward reward={args.rewardid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskTakePopularityReward);
        }

        [Handler(MethodId.AskClearPersonalZoneNewFans)]
        public static void AskClearPersonalZoneNewFansHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Popularity] AskClearPersonalZoneNewFans");
            SendEmptySuccessReturn(conn, msg, MethodId.AskClearPersonalZoneNewFans);
        }

        [Handler(MethodId.AskGetFansAutoGiveHistory)]
        public static void AskGetFansAutoGiveHistoryHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Popularity] AskGetFansAutoGiveHistory");
            var history = new FansAutoGiveHistory()
            {
            };

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskGetFansAutoGiveHistory,
            };
            rsp.SetArgs(MethodId.AskGetFansAutoGiveHistory, history);
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDoAgentFansPerformance)]
        public static void AskDoAgentFansPerformanceHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskDoAgentFansPerformanceArg>();
            Console.WriteLine($"[Popularity] AskDoAgentFansPerformance performance={args.performanceid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDoAgentFansPerformance);
        }

        [Handler(MethodId.AskFinishWpFansPerformance)]
        public static void AskFinishWpFansPerformanceHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskFinishWpFansPerformanceArg>();
            Console.WriteLine($"[Popularity] AskFinishWpFansPerformance performance={args.performanceid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFinishWpFansPerformance);
        }

        [Handler(MethodId.AskStealNPCFan)]
        public static void AskStealNPCFanHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskStealNPCFanArg>();
            Console.WriteLine($"[Popularity] AskStealNPCFan npc={args.npcpid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStealNPCFan);
        }
    }
}
