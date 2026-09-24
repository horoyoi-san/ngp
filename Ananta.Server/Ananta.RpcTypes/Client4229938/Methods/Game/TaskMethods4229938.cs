using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

[UxContract]
internal sealed class TaskInfo4229938
{
    public uint TaskId;

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<int> CounterValues = [];

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<TaskCounter4229938> Counters = [];

    public byte State;

    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<byte, int> ActiveFunctionValue = [];

    [UxCollection(Count = UxCountEncoding.Int7, ValueObjectEncoding = UxObjectEncoding.Complex)]
    public Dictionary<byte, ActiveFunctionId4229938> ActiveFunctionIds = [];

    public bool RecoverResource;

    
    
    
    
    
    
    
    
    
    
    
    
    
    public SpoonViewInfo4229938? SpoonViewInfo;
}

[UxContract]
internal sealed class TaskCounter4229938
{
    public int Index;
    public int Value;
    public int ConfigValue;
    public int Parent;

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<TaskCounter4229938> Child = [];
}

[UxContract]
internal sealed class ActiveFunctionId4229938
{
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<int> Value = [];
}

[UxContract]
internal sealed class SpoonViewInfo4229938
{
    public string SpoonMd5 = string.Empty;
    public uint SpRaidId;
    public uint StartTaskId;
    public uint EndTaskId;
    public string Alias = string.Empty;
    public uint EventId;
    public uint EventStartTaskId;
}

[UxContract]
internal sealed class EventPanelTaskEvent4229938
{
    public uint EventId;
    public uint TaskId;
    public uint UnlockTime;

    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> FinishedChoiceLs = [];

    public byte StatusData;
}

[UxContract]
internal sealed class EventViewInfo4229938
{
    public uint EventId;
    public uint RaidId;
    public string SpoonMd5 = string.Empty;
}

[UxContract]
internal sealed class EventPanelInfo4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<EventPanelTaskEvent4229938> EventsInfo = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<uint> SubmitEventList = [];

    
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<uint> SubmitReplayEventList = [];

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<EventViewInfo4229938> EventViewInfoList = [];
}

[UxContract(Inline = true)]
internal sealed class SyncPlayerAllTask4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<TaskInfo4229938> taskInfos = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<uint> submitTaskList = [];

    public uint currentTask;
    public EventPanelInfo4229938 eventPanelInfo = new();
    public bool loginGameServer;
}

[UxContract(Inline = true)]
internal sealed class SyncCurrentTask4229938
{
    public byte type;
    public uint taskId;
    public uint eventId;
    public bool firstTime;
    public byte reason;
}

[UxContract(Inline = true)]
internal sealed class SyncCollectionQuestUnlock4229938
{
    public uint questId;
}

[UxContract(Inline = true)]
internal sealed class SyncCompletedSubQuest4229938
{
    public uint subQuestId;
}

[UxContract(Inline = true)]
internal sealed class SyncTaskTitleGuideUnlock4229938
{
    public ushort taskTitleId;
    public bool unlock;
}

[UxContract(Inline = true)]
internal sealed class SyncTaskSpoonResourceLoaded4229938
{
    public uint taskId;
    public SpoonTaskResource4229938 resource = new();
}

[UxContract]
internal sealed class SpoonTaskResource4229938
{
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<int> AgentSpoonIds = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> Gadgets = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<ulong> SceneItems = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<int> VehicleSpoonIds = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<int> DynamicGoIds = [];

    public int EntryAgentViewpointSpoonId;
}

[UxContract(Inline = true)]
internal sealed class SyncSpoonTaskClientData4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<SpoonTaskClientData4229938> data = [];
}

[UxContract]
internal sealed class SpoonTaskClientData4229938
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<SpoonTriggerInfo4229938> TriggerInfos = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<int, ulong> Enemies = [];

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<SpoonRoom4229938> SpoonRooms = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<int> RemovedNpcList = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<int, int> VehicleIdDict = [];

    public uint TaskId;
    public uint EventId;
}

[UxContract]
internal sealed class SpoonTriggerInfo4229938
{
    public int FlowIndex;
    public int NodeId;
    public uint StartTime;
    public bool NeedComplete;
    public uint MemoryTaskId;
    public bool IsCondition;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<SpoonPort4229938> Ports = [];

    [UxCollection(Count = UxCountEncoding.Int7)]
    public Dictionary<ulong, int> pid2Index = [];
}

[UxContract]
internal sealed class SpoonPort4229938
{
    
    public byte Type = 1;

    public int PortId;
}

[UxContract]
internal sealed class SpoonRoom4229938
{
    public int Id;
    public bool Enable;
}
