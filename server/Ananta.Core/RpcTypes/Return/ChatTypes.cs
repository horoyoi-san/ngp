using System.Collections.Generic;

namespace AnantaTestGameServer.Methods
{
    // LinkMode enum already defined in RPCMethodArgsLogin.cs

    // === Send Message Args ===

    public class SendMessageToPlayerArgs : SerializedClass
    {
        public ulong Pid;
        public string Text;
        public bool IsAudio;
    }

    public class SendMessageToRoomArgs : SerializedClass
    {
        public string Text;
        public bool IsAudio;
    }

    public class SendMessageToTeamArgs : SerializedClass
    {
        public string Text;
        public bool IsAudio;
    }

    public class SendMessageToChatGroupArgs : SerializedClass
    {
        public ulong GroupId;
        public string Text;
        public bool IsAudio;
    }

    public class SendMessageToLinkArgs : SerializedClass
    {
        public string Text;
        public LinkMode Mode;
        public bool IsAudio;
    }

    public class SendMessageToLocationArgs : SerializedClass
    {
        // Signature unknown - minimal stub
        public string Text;
        public bool IsAudio;
    }

    // === Get Message Args ===

    public class GetP2PMessageListArgs : SerializedClass
    {
        public ulong FriendPid;
        public uint Timestamp;
    }

    public class GetP2PMessageListWithRangeArgs : SerializedClass
    {
        public ulong FriendPid;
        public uint StartTimestamp;
        public uint EndTimestamp;
        public uint Count;
    }

    public class GetP2PLatestMessageListArgs : SerializedClass
    {
        public List<ulong> Targets;
    }

    public class GetManyP2PMessagesArgs : SerializedClass
    {
        public List<ulong> Targets;
    }

    public class GetRoomMessagesArgs : SerializedClass
    {
        public uint Timestamp;
    }

    // GetRoomLatestMessage - no args (empty invoke)

    public class GetTeamMessagesArgs : SerializedClass
    {
        public uint Timestamp;
    }

    // GetTeamLatestMessage - no args (empty invoke)

    public class GetChatGroupMessagesArgs : SerializedClass
    {
        public ulong GroupId;
        public uint Timestamp;
    }

    public class GetChatGroupMessagesWithRangeArgs : SerializedClass
    {
        public ulong GroupId;
        public uint StartTimestamp;
        public uint EndTimestamp;
        public uint Count;
    }

    public class GetLinkMessagesArgs : SerializedClass
    {
        public uint Timestamp;
        public LinkMode Mode;
    }

    public class GetLinkLatestMessageArgs : SerializedClass
    {
        public LinkMode Mode;
    }

    public class GetLinkMessageListArgs : SerializedClass
    {
        public LinkMode Mode;
    }

    // === Utility Args ===

    public class MarkAsReadPrivateMessageArgs : SerializedClass
    {
        public ulong Pid;
    }

    public class GetSimplePlayerInfoByPidListArgs : SerializedClass
    {
        public List<ulong> Pids;
    }

    public class GetServerTimeArgs : SerializedClass
    {
        public double ClientUnixTime;
    }

    public class UploadLogsArgs : SerializedClass
    {
        public List<string> Logs;
        public int Token;
    }

    // === Return types for Get methods ===

    public class GetP2PMessageListReturn : SerializedClass
    {
        public List<ChatMessage> Messages;
    }

    public class GetChatGroupMessagesReturn : SerializedClass
    {
        public List<ChatMessage> Messages;
    }

    public class GetLinkMessagesReturn : SerializedClass
    {
        public List<ChatMessage> Messages;
    }

    public class GetSimplePlayerInfoByPidListReturn : SerializedClass
    {
        public List<NameCard> PlayerInfos;
    }

    public class GetServerTimeReturn : SerializedClass
    {
        public double ServerTime;
        public double ClientTime;
    }
}
