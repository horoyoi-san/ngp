using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    // ── Request Args ──────────────────────────────────────────────

    public class AskReadHackerNewPostArg : SerializedClass
    {
        public uint postid;
        public AskReadHackerNewPostArg() { onlyFields = true; }
    }

    public class AskChangeHackerNameArg : SerializedClass
    {
        public string name;
        public AskChangeHackerNameArg() { onlyFields = true; }
    }

    public class AskAcceptHackerPostTaskArg : SerializedClass
    {
        public uint postid;
        public AskAcceptHackerPostTaskArg() { onlyFields = true; }
    }

    // ── Sync Notify Args ──────────────────────────────────────────

    public class SyncSpiritHackerJobInfoArgs : SerializedClass
    {
        public uint spiritid;
        public HackerJobInfo hackerjobinfo;
        public SyncSpiritHackerJobInfoArgs() { onlyFields = true; }
    }

    public class HackerJobInfo : SerializedClass
    {
        public string HackerName;
        public Dictionary<uint, HackerPostInfo> PostInfos;
        public uint Rank;
        public HackerDailyCounts DailyCounts;
        public HackerJobInfo() { onlyFields = true; }
    }

    public class HackerPostInfo : SerializedClass
    {
        public uint PostId;
        public bool IsRead;
        public bool IsAccepted;
        public HackerPostInfo() { onlyFields = true; }
    }

    public class HackerDailyCounts : SerializedClass
    {
        public uint HackCount;
        public uint NpcHackCount;
        public HackerDailyCounts() { onlyFields = true; }
    }

    public class NotifyNewHackerPostsArgs : SerializedClass
    {
        public uint spiritid;
        public NotifyNewHackerPostsArgs() { onlyFields = true; }
    }

    // ── Handlers ──────────────────────────────────────────────────

    public static class HackerHandlers
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
        /// AskChangeHackerName: Change the player's hacker alias.
        /// </summary>
        [Handler(MethodId.AskChangeHackerName)]
        public static void AskChangeHackerNameHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskChangeHackerNameArg>();
            string newName = args.name ?? "Anonymous";
            Console.WriteLine($"[Hacker] AskChangeHackerName: {newName}");

            conn.HackerName = newName;

            SendEmptySuccessReturn(conn, msg, MethodId.AskChangeHackerName);
        }

        /// <summary>
        /// AskReadHackerNewPost: Mark a hacker BBS post as read.
        /// </summary>
        [Handler(MethodId.AskReadHackerNewPost)]
        public static void AskReadHackerNewPostHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskReadHackerNewPostArg>();
            Console.WriteLine($"[Hacker] AskReadHackerNewPost: post={args.postid}");

            conn.HackerReadPostIds.Add(args.postid);

            SendEmptySuccessReturn(conn, msg, MethodId.AskReadHackerNewPost);
        }

        /// <summary>
        /// AskAcceptHackerPostTask: Accept a task from a hacker BBS post.
        /// </summary>
        [Handler(MethodId.AskAcceptHackerPostTask)]
        public static void AskAcceptHackerPostTaskHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskAcceptHackerPostTaskArg>();
            Console.WriteLine($"[Hacker] AskAcceptHackerPostTask: post={args.postid}");

            uint postId = args.postid;
            
            // Add to accepted posts if not already there
            if (!conn.HackerAcceptedPostIds.Contains(postId))
                conn.HackerAcceptedPostIds.Add(postId);
            
            Console.WriteLine($"[Hacker] Post task {postId} accepted (total accepted: {conn.HackerAcceptedPostIds.Count})");

            SendEmptySuccessReturn(conn, msg, MethodId.AskAcceptHackerPostTask);
        }
    }
}
