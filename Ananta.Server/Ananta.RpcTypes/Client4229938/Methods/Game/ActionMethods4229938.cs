using System.Collections.Generic;
using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

[UxContract]
internal sealed class PlayerInteractionActionItem4229938
{
    
    public uint CfgId;

    
    public uint UnlockTime;

    
    public bool ShowRedPoint;
}

[UxContract]
internal sealed class PlayerInteractionActionInfo4229938
{
    
    [UxCollection(Count = UxCountEncoding.Int7, ValueObjectEncoding = UxObjectEncoding.Complex)]
    public Dictionary<uint, PlayerInteractionActionItem4229938> UnlockActionItemDict = [];

    
    public bool InvitedNotDisturb;
}

[UxContract(Inline = true)]
internal sealed class SyncUnlockInteractionActionItems4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<PlayerInteractionActionItem4229938> newActionItems = [];
}

[UxContract(Inline = true)]
internal sealed class SyncUnlockSystems4229938
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<uint> unlockSystems = [];
}
