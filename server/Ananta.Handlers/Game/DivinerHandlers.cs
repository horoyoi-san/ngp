using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public class AskStartDivinerGameArg : SerializedClass
    {
        public uint npcid;
        public AskStartDivinerGameArg() { onlyFields = true; }
    }

    public class AskStartDivinerGameWithDemandArg : SerializedClass
    {
        public uint npcid;
        public uint demandid;
        public AskStartDivinerGameWithDemandArg() { onlyFields = true; }
    }

    public class AskDivinerChooseBranchArg : SerializedClass
    {
        public uint branchid;
        public AskDivinerChooseBranchArg() { onlyFields = true; }
    }

    public class AskDivinerPersuadeArg : SerializedClass
    {
        public uint persuadeoption;
        public AskDivinerPersuadeArg() { onlyFields = true; }
    }

    public class AskDivinerFinishPersuadeArg : SerializedClass
    {
        public AskDivinerFinishPersuadeArg() { onlyFields = true; }
    }

    public class AskDivinerUpdatePersuadeProgressArg : SerializedClass
    {
        public uint progress;
        public AskDivinerUpdatePersuadeProgressArg() { onlyFields = true; }
    }

    public class AskDivinerTriggerResultArg : SerializedClass
    {
        public AskDivinerTriggerResultArg() { onlyFields = true; }
    }

    public class AskDivinerRequestAppealArg : SerializedClass
    {
        public uint appealtype;
        public AskDivinerRequestAppealArg() { onlyFields = true; }
    }

    public class AskDivinerFinishRequestAppealArg : SerializedClass
    {
        public AskDivinerFinishRequestAppealArg() { onlyFields = true; }
    }

    public class AskDivinerEnterBattleArg : SerializedClass
    {
        public AskDivinerEnterBattleArg() { onlyFields = true; }
    }

    public class AskEnterDivinerGameArg : SerializedClass
    {
        public AskEnterDivinerGameArg() { onlyFields = true; }
    }

    public static class DivinerHandlers
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

        [Handler(MethodId.AskStartDivinerGame)]
        public static void AskStartDivinerGameHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskStartDivinerGameArg>();
            Console.WriteLine($"[Diviner] AskStartDivinerGame npc={args.npcid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStartDivinerGame);
        }

        [Handler(MethodId.AskStartDivinerGameWithDemand)]
        public static void AskStartDivinerGameWithDemandHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskStartDivinerGameWithDemandArg>();
            Console.WriteLine($"[Diviner] AskStartDivinerGameWithDemand npc={args.npcid} demand={args.demandid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskStartDivinerGameWithDemand);
        }

        [Handler(MethodId.AskEnterDivinerGame)]
        public static void AskEnterDivinerGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskEnterDivinerGame");
            SendEmptySuccessReturn(conn, msg, MethodId.AskEnterDivinerGame);
        }

        [Handler(MethodId.AskLeaveDivinerGame)]
        public static void AskLeaveDivinerGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskLeaveDivinerGame");
            SendEmptySuccessReturn(conn, msg, MethodId.AskLeaveDivinerGame);
        }

        [Handler(MethodId.AskDivinerChooseBranch)]
        public static void AskDivinerChooseBranchHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskDivinerChooseBranchArg>();
            Console.WriteLine($"[Diviner] AskDivinerChooseBranch branch={args.branchid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDivinerChooseBranch);
        }

        [Handler(MethodId.AskDivinerPersuade)]
        public static void AskDivinerPersuadeHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskDivinerPersuadeArg>();
            Console.WriteLine($"[Diviner] AskDivinerPersuade option={args.persuadeoption}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDivinerPersuade);
        }

        [Handler(MethodId.AskDivinerFinishPersuade)]
        public static void AskDivinerFinishPersuadeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerFinishPersuade");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDivinerFinishPersuade);
        }

        [Handler(MethodId.AskDivinerUpdatePersuadeProgress)]
        public static void AskDivinerUpdatePersuadeProgressHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskDivinerUpdatePersuadeProgressArg>();
            Console.WriteLine($"[Diviner] AskDivinerUpdatePersuadeProgress progress={args.progress}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDivinerUpdatePersuadeProgress);
        }

        [Handler(MethodId.AskDivinerTriggerResult)]
        public static void AskDivinerTriggerResultHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerTriggerResult");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDivinerTriggerResult);
        }

        [Handler(MethodId.AskDivinerRequestAppeal)]
        public static void AskDivinerRequestAppealHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskDivinerRequestAppealArg>();
            Console.WriteLine($"[Diviner] AskDivinerRequestAppeal type={args.appealtype}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDivinerRequestAppeal);
        }

        [Handler(MethodId.AskDivinerFinishRequestAppeal)]
        public static void AskDivinerFinishRequestAppealHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerFinishRequestAppeal");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDivinerFinishRequestAppeal);
        }

        [Handler(MethodId.AskDivinerEnterBattle)]
        public static void AskDivinerEnterBattleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerEnterBattle");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDivinerEnterBattle);
        }

        [Handler(MethodId.AskDivinerCheckSpecialEvent)]
        public static void AskDivinerCheckSpecialEventHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerCheckSpecialEvent");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDivinerCheckSpecialEvent);
        }

        [Handler(MethodId.AskDivinerStartTimeCheck)]
        public static void AskDivinerStartTimeCheckHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerStartTimeCheck");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDivinerStartTimeCheck);
        }

        [Handler(MethodId.AskDivinerTakeCommission)]
        public static void AskDivinerTakeCommissionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Diviner] AskDivinerTakeCommission");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDivinerTakeCommission);
        }
    }
}
