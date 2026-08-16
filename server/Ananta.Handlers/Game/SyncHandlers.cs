using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    internal class SyncHandlers
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

        // ═══════════════════════════════════════════════════════════════════
        //  INDOOR / SAFE AREA SYNC
        // ═══════════════════════════════════════════════════════════════════

        public class SyncChangeIndoorArgs : SerializedClass
        {
            public uint indoorconfigid;
            public uint boundid;

            public SyncChangeIndoorArgs()
            {
                onlyFields = true;
            }
        }

        [Handler(MethodId.SyncChangeIndoor)]
        public static void SyncChangeIndoorHandler(Connection conn, UxRpcMessage msg)
        {
            SyncChangeIndoorArgs args = msg.GetArgs<SyncChangeIndoorArgs>();
            Console.WriteLine($"[Indoor] SyncChangeIndoor: indoorconfigid={args.indoorconfigid} boundid={args.boundid}");

            UxRpcMessage rspNotify = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeIndoor,
            };
            rspNotify.SetArgs(MethodId.SyncChangeIndoor, new SyncChangeIndoorArgs()
            {
                indoorconfigid = args.indoorconfigid,
                boundid = args.boundid
            });
            conn.SendPacket(rspNotify);
        }

        public class SyncChangeSafeAreaArgs : SerializedClass
        {
            public uint regionid;

            public SyncChangeSafeAreaArgs()
            {
                onlyFields = true;
            }
        }

        [Handler(MethodId.SyncChangeSafeArea)]
        public static void SyncChangeSafeAreaHandler(Connection conn, UxRpcMessage msg)
        {
            SyncChangeSafeAreaArgs args = msg.GetArgs<SyncChangeSafeAreaArgs>();
            Console.WriteLine($"[SafeArea] SyncChangeSafeArea: regionid={args.regionid}");

            UxRpcMessage rspNotify = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncChangeSafeArea,
            };
            rspNotify.SetArgs(MethodId.SyncChangeSafeArea, new SyncChangeSafeAreaArgs()
            {
                regionid = args.regionid
            });
            conn.SendPacket(rspNotify);
        }

        // ═══════════════════════════════════════════════════════════════════
        //  STORY CORE DEBUG/SYNC
        // ═══════════════════════════════════════════════════════════════════

        public class SyncStoryInfoArgs : SerializedClass
        {
            public string info;

            public SyncStoryInfoArgs()
            {
                onlyFields = true;
            }
        }

        [Handler(MethodId.SyncStoryCoreClientDebugInfo)]
        public static void SyncStoryCoreClientDebugInfoHandler(Connection conn, UxRpcMessage msg)
        {
            SyncStoryInfoArgs args = msg.GetArgs<SyncStoryInfoArgs>();
            Console.WriteLine($"[Story] SyncStoryCoreClientDebugInfo: info={args.info}");

            UxRpcMessage rspNotify = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStoryCoreClientDebugInfo,
            };
            rspNotify.SetArgs(MethodId.SyncStoryCoreClientDebugInfo, new SyncStoryInfoArgs()
            {
                info = args.info
            });
            conn.SendPacket(rspNotify);
        }

        [Handler(MethodId.SyncStoryCoreClientInfo)]
        public static void SyncStoryCoreClientInfoHandler(Connection conn, UxRpcMessage msg)
        {
            SyncStoryInfoArgs args = msg.GetArgs<SyncStoryInfoArgs>();
            Console.WriteLine($"[Story] SyncStoryCoreClientInfo: info={args.info}");

            UxRpcMessage rspNotify = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStoryCoreClientInfo,
            };
            rspNotify.SetArgs(MethodId.SyncStoryCoreClientInfo, new SyncStoryInfoArgs()
            {
                info = args.info
            });
            conn.SendPacket(rspNotify);
        }

        [Handler(MethodId.SyncStoryCoreClientDebugInfoGM)]
        public static void SyncStoryCoreClientDebugInfoGMHandler(Connection conn, UxRpcMessage msg)
        {
            SyncStoryInfoArgs args = msg.GetArgs<SyncStoryInfoArgs>();
            Console.WriteLine($"[Story] SyncStoryCoreClientDebugInfoGM: info={args.info}");

            UxRpcMessage rspNotify = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncStoryCoreClientDebugInfoGM,
            };
            rspNotify.SetArgs(MethodId.SyncStoryCoreClientDebugInfoGM, new SyncStoryInfoArgs()
            {
                info = args.info
            });
            conn.SendPacket(rspNotify);
        }

        // ═══════════════════════════════════════════════════════════════════
        //  PSN BLACKLIST
        // ═══════════════════════════════════════════════════════════════════

        public class SyncPSNBlacklistArgs : SerializedClass
        {
            public List<ulong> pids;

            public SyncPSNBlacklistArgs()
            {
                onlyFields = true;
            }
        }

        [Handler(MethodId.SyncPSNBlacklist)]
        public static void SyncPSNBlacklistHandler(Connection conn, UxRpcMessage msg)
        {
            SyncPSNBlacklistArgs args = msg.GetArgs<SyncPSNBlacklistArgs>();
            Console.WriteLine($"[PSN] SyncPSNBlacklist: pids count={args.pids?.Count ?? 0}");

            UxRpcMessage rspNotify = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPSNBlacklist,
            };
            rspNotify.SetArgs(MethodId.SyncPSNBlacklist, new SyncPSNBlacklistArgs()
            {
                pids = args.pids ?? new List<ulong>()
            });
            conn.SendPacket(rspNotify);
        }

        // ═══════════════════════════════════════════════════════════════════
        //  TEST / DEBUG
        // ═══════════════════════════════════════════════════════════════════

        public class TestUpdateDaShenLogTokenArgs : SerializedClass
        {
            public string logtoken;

            public TestUpdateDaShenLogTokenArgs()
            {
                onlyFields = true;
            }
        }

        [Handler(MethodId.TestUpdateDaShenLogToken)]
        public static void TestUpdateDaShenLogTokenHandler(Connection conn, UxRpcMessage msg)
        {
            TestUpdateDaShenLogTokenArgs args = msg.GetArgs<TestUpdateDaShenLogTokenArgs>();
            Console.WriteLine($"[Test] TestUpdateDaShenLogToken: logtoken={args.logtoken}");

            SendEmptySuccessReturn(conn, msg, MethodId.TestUpdateDaShenLogToken);
        }
    }
}
