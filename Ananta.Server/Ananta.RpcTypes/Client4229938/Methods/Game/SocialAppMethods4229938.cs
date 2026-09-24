using Ananta.SDK.Serialization;
using Auto = Ananta.Server.RpcTypes.Client4229938.Auto;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

[UxContract]
internal sealed class PostPlayerCommentClientInfo4229938
{
    public string Comment = string.Empty;
    public uint CommentId;
    public bool IsFinish;
}

[UxContract]
internal sealed class PostSimpleClientInfo4229938
{
    public uint Id;

    
    public byte PostType;

    
    public uint PostConfigId;

    
    public uint Date;

    public string ImageUrl = string.Empty;
    public bool Approved;
    public string Title = string.Empty;
    public uint Likes;
    public bool Liked;

    
    public List<uint> LikeNpcs = [];

    
    public List<uint> Comments = [];

    
    public List<PostPlayerCommentClientInfo4229938> PlayerComments = [];

    public bool IsRead;
    public bool HasNewLike;
    public uint AcquireCfgId;
    public uint ActivityCfgId;
    public bool IsStory;
    public bool IsPinStory;
}

[UxContract]
internal sealed class SimpleUnreadMessage4229938
{
    public uint PostId;
    public uint CommentId;
    public int MessageType;
}

[UxContract]
internal sealed class EmojiData4229938
{
    public string Id = string.Empty;
    public uint Count;
}

[UxContract]
internal sealed class AskMomentsPostSimpleInfos4229938
{
    public uint lastId;

    
    public byte postType;
}

[UxContract]
internal sealed class AskMomentsPostInfos4229938
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<uint> postIds = [];
}

[UxContract]
internal sealed class AskMomentsPostInfosInt324229938
{
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> postIds = [];
}

[UxContract]
internal sealed class AskMomentsMarkRead4229938
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<uint> postIds = [];
}

[UxContract]
internal sealed class AskMomentsMarkReadInt324229938
{
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> postIds = [];
}

[UxContract]
internal sealed class AskMomentsLikePost4229938
{
    public uint postId;
    public bool like;
}

[UxContract]
internal sealed class AskMomentsSendCommentWithId4229938
{
    public uint postId;
    public uint commentId;
}

[UxContract]
internal sealed class AskMomentsTapPostWithCount4229938
{
    public uint postId;

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<EmojiData4229938> emojiList = [];
}

[UxContract]
internal sealed class AskMomentsTapPostWithCountInt324229938
{
    public uint postId;

    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<EmojiData4229938> emojiList = [];
}

[UxContract]
internal sealed class NpcTimeTableScheduleInfo4229938
{
    public uint ActivityId;
    public int StartDaySecond;

    
    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public Auto.UXVector3 Position = new();

    public int SpoonAgentId;
    public int EndDaySecond;
    public uint RaidId;
}

[UxContract]
internal sealed class NpcTimeTableInfo4229938
{
    public NpcTimeTableScheduleInfo4229938? Schedule0;
    public NpcTimeTableScheduleInfo4229938? Schedule1;
    public NpcTimeTableScheduleInfo4229938? Schedule2;
    public NpcTimeTableScheduleInfo4229938? Schedule3;
    public NpcTimeTableScheduleInfo4229938? Schedule4;

    public int CurrentSpoonAgentId;

    
    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public Auto.UXVector3 SpoonPosition = new();

    public NpcTimeTableScheduleInfo4229938? TempSchedule;
    public bool IsTempScheduleOnly;
    public long RefreshDay;
}

[UxContract]
internal sealed class SyncFavorNpcTimeTableInfos4229938
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<uint, NpcTimeTableInfo4229938> timeTableInfos = new();
}
