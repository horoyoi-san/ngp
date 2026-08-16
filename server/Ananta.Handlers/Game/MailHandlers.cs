using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public static class MailHandlers
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

        private static void SendNotify(Connection conn, MethodId methodId, SerializedClass args)
        {
            UxRpcMessage notify = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcMethodId = (int)methodId,
            };
            notify.SetArgs(methodId, args);
            conn.SendPacket(notify);
        }

        [Handler(MethodId.GetMailHeadList)]
        public static void GetMailHeadListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Mail] GetMailHeadList");
            SendEmptySuccessReturn(conn, msg, MethodId.GetMailHeadList);
        }

        [Handler(MethodId.RequestMailInfo)]
        public static void RequestMailInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Mail] RequestMailInfo");
            SendEmptySuccessReturn(conn, msg, MethodId.RequestMailInfo);
        }

        [Handler(MethodId.AskDeleteMail)]
        public static void AskDeleteMailHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Mail] AskDeleteMail");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDeleteMail);
        }

        [Handler(MethodId.AskDeleteMails)]
        public static void AskDeleteMailsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Mail] AskDeleteMails");
            SendEmptySuccessReturn(conn, msg, MethodId.AskDeleteMails);
        }

        [Handler(MethodId.RequestMailsItem)]
        public static void RequestMailsItemHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Mail] RequestMailsItem");
            SendEmptySuccessReturn(conn, msg, MethodId.RequestMailsItem);
        }

        [Handler(MethodId.AskGetMailItem)]
        public static void AskGetMailItemHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Mail] AskGetMailItem");
            SendEmptySuccessReturn(conn, msg, MethodId.AskGetMailItem);
        }

        [Handler(MethodId.AskGetMailsItem)]
        public static void AskGetMailsItemHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Mail] AskGetMailsItem");
            SendEmptySuccessReturn(conn, msg, MethodId.AskGetMailsItem);
        }

        [Handler(MethodId.AskAddMailToFavorites)]
        public static void AskAddMailToFavoritesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Mail] AskAddMailToFavorites");
            SendEmptySuccessReturn(conn, msg, MethodId.AskAddMailToFavorites);
        }

        [Handler(MethodId.AskRemoveMailFromFavorites)]
        public static void AskRemoveMailFromFavoritesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Mail] AskRemoveMailFromFavorites");
            SendEmptySuccessReturn(conn, msg, MethodId.AskRemoveMailFromFavorites);
        }

        [Handler(MethodId.AskMailFavorites)]
        public static void AskMailFavoritesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Mail] AskMailFavorites");
            SendEmptySuccessReturn(conn, msg, MethodId.AskMailFavorites);
        }
    }
}
