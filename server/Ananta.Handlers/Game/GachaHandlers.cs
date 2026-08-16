using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public class AskDrawGachaArg : SerializedClass
    {
        public uint poolid;
        public uint count;
        public AskDrawGachaArg() { onlyFields = true; }
    }

    public class AskClaimGachaMilestoneArg : SerializedClass
    {
        public uint poolid;
        public uint milestoneid;
        public AskClaimGachaMilestoneArg() { onlyFields = true; }
    }

    public class AskChaosMasterGachaArg : SerializedClass
    {
        public uint count;
        public AskChaosMasterGachaArg() { onlyFields = true; }
    }

    public static class GachaHandlers
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

        [Handler(MethodId.AskDrawGacha)]
        public static void AskDrawGachaHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskDrawGachaArg>();
            Console.WriteLine($"[Gacha] AskDrawGacha pool={args.poolid} count={args.count}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDrawGacha);
        }

        [Handler(MethodId.AskClaimGachaMilestone)]
        public static void AskClaimGachaMilestoneHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskClaimGachaMilestoneArg>();
            Console.WriteLine($"[Gacha] AskClaimGachaMilestone pool={args.poolid} milestone={args.milestoneid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskClaimGachaMilestone);
        }

        [Handler(MethodId.AskChaosMasterGacha)]
        public static void AskChaosMasterGachaHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskChaosMasterGachaArg>();
            Console.WriteLine($"[Gacha] AskChaosMasterGacha count={args.count}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChaosMasterGacha);
        }
    }
}
