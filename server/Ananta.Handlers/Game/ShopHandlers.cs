using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public class AskNpcShopCommodityInfoArg : SerializedClass
    {
        public uint shopid;
        public AskNpcShopCommodityInfoArg() { onlyFields = true; }
    }

    public class AskReadCommoditiesArg : SerializedClass
    {
        public uint shopid;
        public AskReadCommoditiesArg() { onlyFields = true; }
    }

    public class AskPurchaseElementArg : SerializedClass
    {
        public uint shopid;
        public uint itemid;
        public uint count;
        public AskPurchaseElementArg() { onlyFields = true; }
    }

    public class AskMallBuyBundleArg : SerializedClass
    {
        public uint bundleid;
        public uint count;
        public AskMallBuyBundleArg() { onlyFields = true; }
    }

    public static class ShopHandlers
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

        [Handler(MethodId.AskNpcShopCommodityInfo)]
        public static void AskNpcShopCommodityInfoHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskNpcShopCommodityInfoArg>();
            Console.WriteLine($"[Shop] AskNpcShopCommodityInfo shop={args.shopid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskNpcShopCommodityInfo);
        }

        [Handler(MethodId.AskCloseNpcShop)]
        public static void AskCloseNpcShopHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Shop] AskCloseNpcShop");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCloseNpcShop);
        }

        [Handler(MethodId.AskReadCommodities)]
        public static void AskReadCommoditiesHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskReadCommoditiesArg>();
            Console.WriteLine($"[Shop] AskReadCommodities shop={args.shopid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskReadCommodities);
        }

        [Handler(MethodId.AskPurchaseElement)]
        public static void AskPurchaseElementHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskPurchaseElementArg>();
            Console.WriteLine($"[Shop] AskPurchaseElement shop={args.shopid} item={args.itemid} count={args.count}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskPurchaseElement);
        }

        [Handler(MethodId.AskMallBuyBundle)]
        public static void AskMallBuyBundleHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskMallBuyBundleArg>();
            Console.WriteLine($"[Shop] AskMallBuyBundle bundle={args.bundleid} count={args.count}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskMallBuyBundle);
        }

        [Handler(MethodId.AskVehicleShopSpawnVehicle)]
        public static void AskVehicleShopSpawnVehicleHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Shop] AskVehicleShopSpawnVehicle");
            SendEmptySuccessReturn(conn, msg, MethodId.AskVehicleShopSpawnVehicle);
        }
    }
}
