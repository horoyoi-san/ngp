using System;
using System.Collections.Generic;
using System.Linq;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    // ── Types ──────────────────────────────────────────────────────

    public class NpcChatInfo : SerializedClass
    {
        public uint Timestamp;
        public uint ChatId;
        public uint NextChatId;
        public NpcChatContext ChatContext;
        public bool IsRead;
        public uint BelongNpc;
        public NpcChatInfo() { onlyFields = true; }
    }

    // ── Request Args ──────────────────────────────────────────────

    public class NpcChatIdArg : SerializedClass
    {
        public uint chatid;
        public NpcChatIdArg() { onlyFields = true; }
    }

    public class InviteMultiNpcChatArg : SerializedClass
    {
        public uint chatid;
        public List<uint> npclist;
        public InviteMultiNpcChatArg() { onlyFields = true; }
    }

    // ── Sync Notify Args ──────────────────────────────────────────

    public class SyncNpcChatArgs : SerializedClass
    {
        public NpcChatInfo chatinfo;
        public SyncNpcChatArgs() { onlyFields = true; }
    }

    public class SyncNpcChatsArgs : SerializedClass
    {
        public List<NpcChatInfo> chatinfo;
        public SyncNpcChatsArgs() { onlyFields = true; }
    }

    public class SyncClearNpcChatInfoArgs : SerializedClass
    {
        public uint npccultivationid;
        public SyncClearNpcChatInfoArgs() { onlyFields = true; }
    }

    public class SyncRemoveNpcChatArgs : SerializedClass
    {
        public uint chatid;
        public uint asnpc;
        public SyncRemoveNpcChatArgs() { onlyFields = true; }
    }

    public class SyncNpcChatInviteArgs : SerializedClass
    {
        public uint gameplay;
        public SyncNpcChatInviteArgs() { onlyFields = true; }
    }

    public class SyncClearNpcGroupChatInfoArgs : SerializedClass
    {
        public uint groupid;
        public SyncClearNpcGroupChatInfoArgs() { onlyFields = true; }
    }

    public class SyncLockedNpcFavorArgs : SerializedClass
    {
        public uint npccardid;
        public double favordiff;
        public double favor;
        public SyncLockedNpcFavorArgs() { onlyFields = true; }
    }

    // ── Handlers ──────────────────────────────────────────────────

    public static class NpcChatHandlers
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

        private static uint _nextChatId = 10001;

        /// <summary>
        /// RequestNpcChatList: Return all chat messages for a given chat channel.
        /// </summary>
        [Handler(MethodId.RequestNpcChatList)]
        public static void RequestNpcChatListHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<NpcChatIdArg>();
            uint chatId = args.chatid;
            Console.WriteLine($"[NpcChat] RequestNpcChatList chat={chatId}");

            // Return stored chats for this channel (empty if none)
            conn.NpcChatMessages.TryGetValue(chatId, out var chatList);

            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.RequestNpcChatList,
            };
            rsp.SetArgs(MethodId.RequestNpcChatList, new SyncNpcChatsArgs()
            {
                chatinfo = chatList ?? new List<NpcChatInfo>()
            });
            conn.SendPacket(rsp);
        }

        /// <summary>
        /// InviteNpcChat: Start a new chat conversation with an NPC.
        /// </summary>
        [Handler(MethodId.InviteNpcChat)]
        public static void InviteNpcChatHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<NpcChatIdArg>();
            uint chatId = args.chatid;
            Console.WriteLine($"[NpcChat] InviteNpcChat chat={chatId}");

            // Create a new chat entry for this NPC
            uint newId = _nextChatId++;
            var chatInfo = new NpcChatInfo()
            {
                Timestamp = (uint)(DateTimeOffset.UtcNow.ToUnixTimeSeconds()),
                ChatId = newId,
                NextChatId = 0,
                ChatContext = new NpcChatContext()
                {
                    BubbleId = chatId,
                    AcquireCfgId = 0,
                    EmojiList = new(),
                    Url = "",
                    ActivityCfgId = 0
                },
                IsRead = false,
                BelongNpc = chatId
            };

            if (!conn.NpcChatMessages.ContainsKey(chatId))
                conn.NpcChatMessages[chatId] = new List<NpcChatInfo>();
            conn.NpcChatMessages[chatId].Add(chatInfo);

            // Send SyncNpcChat notify
            SendNotify(conn, MethodId.SyncNpcChat, new SyncNpcChatArgs() { chatinfo = chatInfo });

            SendEmptySuccessReturn(conn, msg, MethodId.InviteNpcChat);
        }

        /// <summary>
        /// InviteMultiNpcChat: Invite multiple NPCs to a group chat.
        /// </summary>
        [Handler(MethodId.InviteMultiNpcChat)]
        public static void InviteMultiNpcChatHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<InviteMultiNpcChatArg>();
            Console.WriteLine($"[NpcChat] InviteMultiNpcChat chat={args.chatid} npcs={args.npclist?.Count ?? 0}");
            SendEmptySuccessReturn(conn, msg, MethodId.InviteMultiNpcChat);
        }

        /// <summary>
        /// InteractNpcChat: Player interacts with a chat (triggers next dialog).
        /// </summary>
        [Handler(MethodId.InteractNpcChat)]
        public static void InteractNpcChatHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<NpcChatIdArg>();
            Console.WriteLine($"[NpcChat] InteractNpcChat chat={args.chatid}");
            SendEmptySuccessReturn(conn, msg, MethodId.InteractNpcChat);
        }

        /// <summary>
        /// InteractNpcChatToEnd: Player reads chat to the end.
        /// </summary>
        [Handler(MethodId.InteractNpcChatToEnd)]
        public static void InteractNpcChatToEndHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<NpcChatIdArg>();
            Console.WriteLine($"[NpcChat] InteractNpcChatToEnd chat={args.chatid}");
            SendEmptySuccessReturn(conn, msg, MethodId.InteractNpcChatToEnd);
        }

        /// <summary>
        /// AskCloseNpcChatWnd: Client closes the NPC chat window.
        /// </summary>
        [Handler(MethodId.AskCloseNpcChatWnd)]
        public static void AskCloseNpcChatWndHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<NpcChatIdArg>();
            Console.WriteLine($"[NpcChat] AskCloseNpcChatWnd chat={args.chatid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskCloseNpcChatWnd);
        }

        /// <summary>
        /// AskMarkNpcChatRead: Mark a chat as read.
        /// </summary>
        [Handler(MethodId.AskMarkNpcChatRead)]
        public static void AskMarkNpcChatReadHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<NpcChatIdArg>();
            uint chatId = args.chatid;
            Console.WriteLine($"[NpcChat] AskMarkNpcChatRead chat={chatId}");

            // Mark all messages in this channel as read
            if (conn.NpcChatMessages.TryGetValue(chatId, out var chatList))
            {
                foreach (var chat in chatList)
                    chat.IsRead = true;
            }

            SendEmptySuccessReturn(conn, msg, MethodId.AskMarkNpcChatRead);
        }

        /// <summary>
        /// AskFinishNpcChatRegistration: Finish registering a new NPC chat.
        /// </summary>
        [Handler(MethodId.AskFinishNpcChatRegistration)]
        public static void AskFinishNpcChatRegistrationHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<NpcChatIdArg>();
            Console.WriteLine($"[NpcChat] AskFinishNpcChatRegistration chat={args.chatid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskFinishNpcChatRegistration);
        }

        /// <summary>
        /// AskClearNpcUncompletedInviteChat: Clear any pending incomplete invite chats.
        /// </summary>
        [Handler(MethodId.AskClearNpcUncompletedInviteChat)]
        public static void AskClearNpcUncompletedInviteChatHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[NpcChat] AskClearNpcUncompletedInviteChat");
            SendEmptySuccessReturn(conn, msg, MethodId.AskClearNpcUncompletedInviteChat);
        }

        /// <summary>
        /// AskClearAllNpcDialogNpcChat: Clear all NPC dialog/chat data.
        /// </summary>
        [Handler(MethodId.AskClearAllNpcDialogNpcChat)]
        public static void AskClearAllNpcDialogNpcChatHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[NpcChat] AskClearAllNpcDialogNpcChat");
            conn.NpcChatMessages.Clear();
            SendEmptySuccessReturn(conn, msg, MethodId.AskClearAllNpcDialogNpcChat);
        }

        /// <summary>
        /// RequestNpcGroupMembers: Return list of NPC IDs in a group.
        /// </summary>
        [Handler(MethodId.RequestNpcGroupMembers)]
        public static void RequestNpcGroupMembersHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<NpcChatIdArg>();
            Console.WriteLine($"[NpcChat] RequestNpcGroupMembers group={args.chatid}");

            // Return empty list (no groups configured on private server)
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.RequestNpcGroupMembers,
            };
            // The return is a List<uint> of member IDs — send as raw primitives
            // Since the deserializer expects List<uint> directly (not a SerializedClass),
            // we write it manually
            var memberList = new List<uint>(); // empty for now
            var returnData = new NpcGroupMembersReturn() { members = memberList };
            rsp.SetArgs(MethodId.RequestNpcGroupMembers, returnData);
            conn.SendPacket(rsp);
        }
    }

    // Return wrapper for group members
    public class NpcGroupMembersReturn : SerializedClass
    {
        public List<uint> members;
        public NpcGroupMembersReturn() { onlyFields = true; }
    }
}
