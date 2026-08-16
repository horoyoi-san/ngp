using System;
using System.Collections.Generic;
using System.Linq;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    // ── Data type for LiveHouse music records ─────────────────────

    public class LiveHouseMusicRecord : SerializedClass
    {
        public uint MusicId;
        public List<uint> RecordInfo;
        public bool AlreadyReward;

        public LiveHouseMusicRecord() { onlyFields = true; }
    }

    // ── Request Args ──────────────────────────────────────────────

    public class AskLiveHouseMusicListReturn : SerializedClass
    {
        public List<LiveHouseMusicRecord> list;
        public AskLiveHouseMusicListReturn() { onlyFields = true; }
    }

    public class SetLiveHouseMusicResultArg : SerializedClass
    {
        public uint livehousemusicid;
        public List<uint> recordmusicinfo;
        public uint npcid;
        public SetLiveHouseMusicResultArg() { onlyFields = true; }
    }

    public class AskLiveHouseUseItemArg : SerializedClass
    {
        public uint musicid;
        public AskLiveHouseUseItemArg() { onlyFields = true; }
    }

    // ── Handlers ──────────────────────────────────────────────────

    public static class LiveHouseMusicHandlers
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

        /// <summary>
        /// AskLiveHouseMusicList:
        /// Returns the list of all music records (best scores) for this player.
        /// Each record: MusicId, RecordInfo[4] (Perfect, Great, Miss, Special), AlreadyReward.
        /// </summary>
        [Handler(MethodId.AskLiveHouseMusicList)]
        public static void AskLiveHouseMusicListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[LiveHouse] AskLiveHouseMusicList");

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.AskLiveHouseMusicList,
            };
            rsp.SetArgs(MethodId.AskLiveHouseMusicList, new AskLiveHouseMusicListReturn()
            {
                list = conn.LiveHouseRecords.Values.ToList()
            });
            conn.SendPacket(rsp);
        }

        /// <summary>
        /// SetLiveHouseMusicResult:
        /// Client submits a music game result after playing a song.
        /// Server stores the best record (compares total hits) and marks as not-yet-rewarded.
        /// </summary>
        [Handler(MethodId.SetLiveHouseMusicResult)]
        public static void SetLiveHouseMusicResultHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<SetLiveHouseMusicResultArg>();
            uint musicId = args.livehousemusicid;
            List<uint> recordInfo = args.recordmusicinfo ?? new List<uint> { 0, 0, 0, 0 };
            uint npcId = args.npcid;

            Console.WriteLine($"[LiveHouse] SetLiveHouseMusicResult music={musicId} npc={npcId} P={recordInfo.ElementAtOrDefault(0)} G={recordInfo.ElementAtOrDefault(1)} M={recordInfo.ElementAtOrDefault(2)} S={recordInfo.ElementAtOrDefault(3)}");

            // Ensure recordInfo has exactly 4 elements
            while (recordInfo.Count < 4)
                recordInfo.Add(0);

            uint newTotal = (uint)recordInfo.Take(3).Sum(x => (int)x); // Perfect + Great + Miss

            if (conn.LiveHouseRecords.TryGetValue(musicId, out var existing))
            {
                // Compare: keep the better record (higher Perfect+Great+Miss total)
                uint oldTotal = (uint)existing.RecordInfo.Take(3).Sum(x => (int)x);
                if (newTotal > oldTotal)
                {
                    existing.RecordInfo = recordInfo.Take(4).ToList();
                    existing.AlreadyReward = false; // new record = new rewards available
                    Console.WriteLine($"[LiveHouse] Updated record for music={musicId} (old={oldTotal} new={newTotal})");
                }
                else
                {
                    Console.WriteLine($"[LiveHouse] Record not improved for music={musicId} (old={oldTotal} new={newTotal})");
                }
            }
            else
            {
                conn.LiveHouseRecords[musicId] = new LiveHouseMusicRecord()
                {
                    MusicId = musicId,
                    RecordInfo = recordInfo.Take(4).ToList(),
                    AlreadyReward = false
                };
                Console.WriteLine($"[LiveHouse] New record for music={musicId}");
            }

            SendEmptySuccessReturn(conn, msg, MethodId.SetLiveHouseMusicResult);
        }

        /// <summary>
        /// AskLiveHouseUseItem:
        /// Client uses a consumable item during a LiveHouse music session.
        /// For private server, just acknowledge success.
        /// </summary>
        [Handler(MethodId.AskLiveHouseUseItem)]
        public static void AskLiveHouseUseItemHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskLiveHouseUseItemArg>();
            Console.WriteLine($"[LiveHouse] AskLiveHouseUseItem music={args.musicid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskLiveHouseUseItem);
        }
    }
}
