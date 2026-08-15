using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class AetherAIInitData : SerializedClass
    {
        public uint RaidId; // 0x10
        public bool HasZoneGraph; // 0x14
        public int ZoneStorageDataHandle; // 0x18
   
        public List<ClientTrafficIntersectionInitInfo> Intersections; 
    
        public List<ClientCrowdInitData> Crowds; // 0x28
   
        public List<ClientStaticNpcInitData> StaticNpcs; // 0x30
       
        public List<ClientVehicleInitData> Vehicles; // 0x38
      
        public List<ClientStaticVehicleInitData> StaticVehicles; // 0x40
     
        public List<ClientVehicleNpcInitData> VehicleNpcs; // 0x48
     
        public List<ClientMetroNpcInitData> MetroNpcs; // 0x50

    }
    public class ClientTrafficIntersectionInitInfo : SerializedClass
    {

    }
    public class ClientCrowdInitData : SerializedClass
    {

    }
    public class AgentSyncClientInfo : SerializedClass
    {
        // Fields
        public bool NeedFTF180DegreeInteract; // 0x10
        public bool PlayerFTF180DegreeInteract; // 0x11
        public uint IndoorId; // 0x14
        public ulong chairId; // 0x18
        public ulong gadgetId; // 0x20
        public bool forbidAetherAI; // 0x28
        public bool isApproachNpc; // 0x29
        public bool TriggerLeaveEvent; // 0x2A
        public int approachDistance; // 0x2C
        public int LeaveDistance; // 0x30
        public string petPerformData; // 0x38
        public int[] stimIDList; // 0x40
        public uint randomModelCfgId; // 0x48
        public int layer; // 0x4C
        public float gpsOffsetY; // 0x50
        public bool isTemp; // 0x54
        public uint[] spawnEffectId; // 0x58
        public uint hideEffectId; // 0x60
        public uint actionId; // 0x64
        public uint actionGroupId; // 0x68
        public uint metroLineId; // 0x6C
        public uint metroCarriageId; // 0x70
        public uint AgentDataSetsActivityCfgId; // 0x74
        public uint GameplaySignalId; // 0x78
       
        public string treeName; // 0x80
        public int sitIndex; // 0x88
        
        public List<uint> indoorList; // 0x90
        public int[] roomIds; // 0x98
        public AgentForbidStimulateType forbidStimulateType; // 0xA0
        public PlotAgentStimType agentStimType; // 0xA4
        public PlotAgentBeHitType beHitType; // 0xA8
        public int SpoonAgentId; // 0xAC
        public bool FeiSuo; // 0xB0
        public uint FashionSuitId; // 0xB4
        public bool CanBeExaminedByPolice; // 0xB8
        public bool IgnoreWanted; // 0xB9
        public enum AgentForbidStimulateType // TypeDefIndex: 28982
        {
            None = 0,
            ForbidAllStimulate = 1,
            ForbidSubsequentStimulate = 2
        }
        public enum PlotAgentBeHitType // TypeDefIndex: 28984
        {
            CanNotBeHit = 0,
            CanBeHitNoDamage = 1,
            CanBeHitWithDamage = 2
        }
        public enum PlotAgentStimType // TypeDefIndex: 28983
        {
            AllStim = 0,
            OnlyInitialStim = 1,
            NoStim = 2
        }
        // Constructors
        public AgentSyncClientInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }
    public class SyncCurrentTask : SerializedClass
    {
        public CurrentTaskType type;
        public uint taskId;
        public uint eventId;
        public bool firstTime;
        public TaskGps taskGps;
        public ChangeCurrentTaskReason reason;
        public SyncCurrentTask()
        {
            onlyFields = true;
        }
        public enum ChangeCurrentTaskReason // TypeDefIndex: 28649
        {
            Gm = 0,
            TaskCounterAdd = 1,
            TaskCounterFinish = 2,
            ForceSet = 3,
            Client = 4,
            AcceptTask = 5,
            SubmitTask = 6,
            AbortTask = 7,
            LoginGameServer = 8,
            LoadComplete = 9,
            TaskGpsChange = 10,
            RoleChange = 11,
            InValidSpiritJob = 12,
            MainEvent = 13,
            TaskRoom = 14
        }
        public enum CurrentTaskType // TypeDefIndex: 28648
        {
            Primary = 0
        }
        public class TaskGps : SerializedClass
        {
            public uint BelongTaskId; // 0x10
            public TaskGpsType Type; // 0x14
            public UXVector3 Position; // 0x18
            public ulong EnemyId; // 0x28
            public int NpcSpoonId; // 0x30
            public ulong NpcId; // 0x38

        }
        public enum TaskGpsType // TypeDefIndex: 28745
        {
            None = 0,
            Position = 1,
            Enemy = 2,
            Npc = 3
        }
    }
    public class ClientStaticNpcInitData : SerializedClass
    {
        public ulong StaticNpcInfoId; // 0x28
        public uint NpcFormworkId; // 0x30
        public uint AgentPersonaId; // 0x34
        public uint PoiActionId; // 0x38
        public uint UrbanDiversityId; // 0x3C
        public bool IgnoreAllStim; // 0x40
        public bool TaskRelated; // 0x41
        public bool EnableHack; // 0x42
        public int NpcPid; // 0x44
      
        public AgentSyncClientInfo AgentSyncClientInfo; // 0x48
        public uint LookAtDecisionRulesId; // 0x50
        public bool ForceGo; // 0x54
        public StaticNpcSourceType SourceType; // 0x55
        public ulong Id; // 0x10
        public UXVector3 Position; // 0x18
        public float Facing; // 0x24
        public ClientStaticNpcInitData()
        {
            CustomFlagType = 2;
        }
        public enum StaticNpcSourceType : byte // TypeDefIndex: 28903
        {
            None = 0,
            Spoon = 1,
            Destructible = 2,
            Sector = 3,
            RaidSpoon = 4,
            EventSpoon = 5,
            Prefab = 6,
            Gadget = 7
        }
    }
    public class ClientVehicleInitData : SerializedClass
    {

    }
    public class ClientStaticVehicleInitData : SerializedClass
    {

    }
    public class ClientVehicleNpcInitData : SerializedClass
    {

    }
    public class ClientMetroNpcInitData : SerializedClass
    {

    }
}
