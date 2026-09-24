using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

[UxContract]
internal sealed class PoliceViolationInfo4229938
{
    
    public uint Time;

    
    public uint Id;

    
    public uint LeaveDueTime;
}

[UxContract]
internal sealed class PoliceDispatchInfo4229938
{
    
    public uint Id;

    
    public uint NextAvailableTime;

    
    public bool IsTemp;

    
    public uint TempEventId;

    
    public uint TodayArrestSupportTimes;
}

[UxContract]
internal sealed class PoliceServiceData4229938
{
    public uint DispatchTimes;
    public uint PatrolTimes;
    public uint ArrestTimes;
    public uint FineCount;

    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> TotalDrops = new();

    public uint LastUpdateTime;
    public uint CarFineCount;
}

[UxContract]
internal sealed class PoliceInterrogationInfo4229938
{
    
    public byte State;

    
    public object? NpcInfo;
}

[UxContract]
internal sealed class PoliceCaseInfo4229938
{
    
    public uint Time;

    
    public uint NpcId;

    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> Fines = new();

    
    
    
    
    
    public int Sentence;

    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> Drops = new();

    
    public bool RewardTaken;

    
    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> BonusDrops = new();

    
    public ulong Id;

    
    public bool IsFakePerson;

    
    
    
    
    public PoliceInterrogationInfo4229938? InterrogationInfo;

    
    public byte NpcImprisonStatus;

    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> FinedCrimes = new();

    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> NoCheckCrimeList = new();

    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> NoIssuedBonusDrops = new();

    
    public bool HasUnlockClue;

    
    public byte SourceType;

    [UxCollection(Count = UxCountEncoding.Int32)]
    public List<uint> CrimeDefaultItems = new();
}

[UxContract(Inline = true)]
internal sealed class SyncSpiritPoliceCaseInfos4229938
{
    public uint spiritId;

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<PoliceCaseInfo4229938> cases = new();
}

[UxContract(Inline = true)]
internal sealed class SyncPoliceServiceData4229938
{
    public uint spiritId;

    public PoliceServiceData4229938 serviceData = new();

    public PoliceServiceData4229938 weeklyServiceData = new();

    
    public bool stopPatrol;
}

[UxContract(Inline = true)]
internal sealed class SyncPoliceDispatchInfos4229938
{
    public uint spiritId;

    [UxCollection(Count = UxCountEncoding.Int7, ValueObjectEncoding = UxObjectEncoding.Complex)]
    public Dictionary<uint, PoliceDispatchInfo4229938> dispatchInfos = new();
}

[UxContract(Inline = true)]
internal sealed class SyncSpiritPoliceViolationInfos4229938
{
    public uint spiritId;

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<PoliceViolationInfo4229938> violations = new();
}
