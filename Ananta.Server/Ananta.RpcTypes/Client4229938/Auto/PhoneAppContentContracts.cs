using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Auto;

[UxContract]
internal sealed class HackerPostInfo
{
    public uint Id;

    
    public int State;

    public bool HaveRead;
}

[UxContract]
internal sealed class SpiritHackerJobInfo
{
    public string HackerName = string.Empty;

    
    [UxCollection(Count = UxCountEncoding.Int32, ValueObjectEncoding = UxObjectEncoding.Complex)]
    public Dictionary<uint, HackerPostInfo> PostInfos = new();

    public uint Rank;
}

[UxContract]
internal sealed class SinglePoliceFakeFileInfo
{
    
    
    
    
    
    public byte State;

    public uint InterrogationTime;
}

[UxContract]
internal sealed class PoliceFakeClueAgentInfo
{
    public uint AgentId;
    public bool IsRead;
    public uint ProvideClueTime;
}

[UxContract]
internal sealed class PoliceFakeFileInfo
{
    [UxCollection(Count = UxCountEncoding.Int32, ValueObjectEncoding = UxObjectEncoding.Complex)]
    public Dictionary<uint, SinglePoliceFakeFileInfo> UnlockFileInfoDict = new();

    [UxCollection(Count = UxCountEncoding.Int32, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<PoliceFakeClueAgentInfo> HistoryClueAgentInfoList = new();
}
