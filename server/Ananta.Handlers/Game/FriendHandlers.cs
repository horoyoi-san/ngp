using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public class ApplyFriendArg : SerializedClass
    {
        public ulong targetpid;
        public string message;
        public ApplyFriendArg() { onlyFields = true; }
    }

    public class ResponseFriendApplicationArg : SerializedClass
    {
        public ulong senderpid;
        public bool accept;
        public ResponseFriendApplicationArg() { onlyFields = true; }
    }

    public class DeleteFriendArg : SerializedClass
    {
        public ulong friendpid;
        public DeleteFriendArg() { onlyFields = true; }
    }

    public class AskChangeFriendRemarkArg : SerializedClass
    {
        public ulong friendpid;
        public string remark;
        public AskChangeFriendRemarkArg() { onlyFields = true; }
    }

    public class AskFriendAddToBlacklistArg : SerializedClass
    {
        public ulong targetpid;
        public AskFriendAddToBlacklistArg() { onlyFields = true; }
    }

    public class AskFriendAddToSpecialListArg : SerializedClass
    {
        public ulong targetpid;
        public AskFriendAddToSpecialListArg() { onlyFields = true; }
    }

    public class AskFriendRemoveFromBlacklistArg : SerializedClass
    {
        public ulong targetpid;
        public AskFriendRemoveFromBlacklistArg() { onlyFields = true; }
    }

    public class AskFriendRemoveFromSpecialListArg : SerializedClass
    {
        public ulong targetpid;
        public AskFriendRemoveFromSpecialListArg() { onlyFields = true; }
    }

    public class QueryFriendRecommendationArg : SerializedClass
    {
        public QueryFriendRecommendationArg() { onlyFields = true; }
    }

    public class GetFriendApplicationListToMeArg : SerializedClass
    {
        public GetFriendApplicationListToMeArg() { onlyFields = true; }
    }

    public class GetFriendApplicationCountToMeArg : SerializedClass
    {
        public GetFriendApplicationCountToMeArg() { onlyFields = true; }
    }

    public class HasFriendApplicationToOtherArg : SerializedClass
    {
        public ulong targetpid;
        public HasFriendApplicationToOtherArg() { onlyFields = true; }
    }

    public class AskSetRejectAllFriendApplyArg : SerializedClass
    {
        public bool rejectall;
        public AskSetRejectAllFriendApplyArg() { onlyFields = true; }
    }

    public class RelationVO : SerializedClass
    {
        public ulong Pid;
        public string Remark;
        public uint RelationType;
        public RelationVO() { onlyFields = true; }
    }

    public static class FriendHandlers
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

        [Handler(MethodId.ApplyFriend)]
        public static void ApplyFriendHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<ApplyFriendArg>();
            Console.WriteLine($"[Friend] ApplyFriend target={args.targetpid}");
            SendEmptySuccessReturn(conn, msg, MethodId.ApplyFriend);
        }

        [Handler(MethodId.ResponseFriendApplication)]
        public static void ResponseFriendApplicationHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<ResponseFriendApplicationArg>();
            Console.WriteLine($"[Friend] ResponseFriendApplication sender={args.senderpid} accept={args.accept}");
            SendEmptySuccessReturn(conn, msg, MethodId.ResponseFriendApplication);
        }

        [Handler(MethodId.ResponseAllFriendApplication)]
        public static void ResponseAllFriendApplicationHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Friend] ResponseAllFriendApplication");
            SendEmptySuccessReturn(conn, msg, MethodId.ResponseAllFriendApplication);
        }

        [Handler(MethodId.DeleteFriend)]
        public static void DeleteFriendHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<DeleteFriendArg>();
            Console.WriteLine($"[Friend] DeleteFriend friend={args.friendpid}");
            SendEmptySuccessReturn(conn, msg, MethodId.DeleteFriend);
        }

        [Handler(MethodId.AskChangeFriendRemark)]
        public static void AskChangeFriendRemarkHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskChangeFriendRemarkArg>();
            Console.WriteLine($"[Friend] AskChangeFriendRemark friend={args.friendpid} remark={args.remark}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChangeFriendRemark);
        }

        [Handler(MethodId.AskFriendAddToBlacklist)]
        public static void AskFriendAddToBlacklistHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskFriendAddToBlacklistArg>();
            Console.WriteLine($"[Friend] AskFriendAddToBlacklist target={args.targetpid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFriendAddToBlacklist);
        }

        [Handler(MethodId.AskFriendAddToSpecialList)]
        public static void AskFriendAddToSpecialListHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskFriendAddToSpecialListArg>();
            Console.WriteLine($"[Friend] AskFriendAddToSpecialList target={args.targetpid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFriendAddToSpecialList);
        }

        [Handler(MethodId.AskFriendRemoveFromBlacklist)]
        public static void AskFriendRemoveFromBlacklistHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskFriendRemoveFromBlacklistArg>();
            Console.WriteLine($"[Friend] AskFriendRemoveFromBlacklist target={args.targetpid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFriendRemoveFromBlacklist);
        }

        [Handler(MethodId.AskFriendRemoveFromSpecialList)]
        public static void AskFriendRemoveFromSpecialListHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskFriendRemoveFromSpecialListArg>();
            Console.WriteLine($"[Friend] AskFriendRemoveFromSpecialList target={args.targetpid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFriendRemoveFromSpecialList);
        }

        [Handler(MethodId.QueryFriendRecommendation)]
        public static void QueryFriendRecommendationHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Friend] QueryFriendRecommendation");
            var simpleData = new FriendSimpleData()
            {
                IsRejectAllFriendApply = false,
                BlackList = new(),
                FriendRelationList = new(),
                SpecialList = new()
            };

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.QueryFriendRecommendation,
            };
            rsp.SetArgs(MethodId.QueryFriendRecommendation, simpleData);
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GetFriendApplicationListToMe)]
        public static void GetFriendApplicationListToMeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Friend] GetFriendApplicationListToMe");
            var simpleData = new FriendSimpleData()
            {
                IsRejectAllFriendApply = false,
                BlackList = new(),
                FriendRelationList = new(),
                SpecialList = new()
            };

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.GetFriendApplicationListToMe,
            };
            rsp.SetArgs(MethodId.GetFriendApplicationListToMe, simpleData);
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.GetFriendApplicationCountToMe)]
        public static void GetFriendApplicationCountToMeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Friend] GetFriendApplicationCountToMe");
            SendEmptySuccessReturn(conn, msg, MethodId.GetFriendApplicationCountToMe);
        }

        [Handler(MethodId.HasFriendApplicationToOther)]
        public static void HasFriendApplicationToOtherHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Friend] HasFriendApplicationToOther");
            SendEmptySuccessReturn(conn, msg, MethodId.HasFriendApplicationToOther);
        }

        [Handler(MethodId.AskSetRejectAllFriendApply)]
        public static void AskSetRejectAllFriendApplyHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskSetRejectAllFriendApplyArg>();
            Console.WriteLine($"[Friend] AskSetRejectAllFriendApply reject={args.rejectall}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetRejectAllFriendApply);
        }
    }
}
