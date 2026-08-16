using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public class AskDoctorCheckArg : SerializedClass
    {
        public uint npcid;
        public AskDoctorCheckArg() { onlyFields = true; }
    }

    public class AskDoctorCureArg : SerializedClass
    {
        public uint npcid;
        public uint curetype;
        public AskDoctorCureArg() { onlyFields = true; }
    }

    public static class DoctorHandlers
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

        [Handler(MethodId.AskDoctorCheck)]
        public static void AskDoctorCheckHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskDoctorCheckArg>();
            Console.WriteLine($"[Doctor] AskDoctorCheck npc={args.npcid}");

            var checkData = new DoctorCheckData()
            {
            };

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDoctorCheck,
            };
            rsp.SetArgs(MethodId.AskDoctorCheck, checkData);
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskDoctorCure)]
        public static void AskDoctorCureHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskDoctorCureArg>();
            Console.WriteLine($"[Doctor] AskDoctorCure npc={args.npcid} type={args.curetype}");

            var cureData = new DoctorCheckCureData()
            {
            };

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskDoctorCure,
            };
            rsp.SetArgs(MethodId.AskDoctorCure, cureData);
            conn.SendPacket(rsp);
        }
    }
}
