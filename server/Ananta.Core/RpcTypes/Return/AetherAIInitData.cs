using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    // ======================== ENUMS ========================

    public enum VehicleControlType : byte
    {
        Invalid = 0,
        AetherVehicle = 1,
        RaidVehicle = 2
    }

    public enum ZoneGraphTargetLocationReason : byte
    {
        None = 0,
        Wander = 1,
        SmartObject = 2,
        Escape = 3,
        StaticNpcReturn = 4
    }

    public enum MassTrafficLightStateFlags : byte
    {
        None = 0,
        PedestrianGo = 1,
        VehicleGoStraight = 2,
        VehicleTurnLeft = 3,
        VehicleTurnRight = 4,
        VehicleGo = 5
    }

    // ======================== AUXILIARY TYPES ========================

    public class ClientZoneGraphPathPoint : SerializedClass
    {
        public UXVector3 Position;
        public byte Facing;

        public ClientZoneGraphPathPoint()
        {
            onlyFields = true;
        }
    }

    public class TrafficLightInfoData : SerializedClass
    {
        public int Index;
        public int CrosswalkControlIndex;
        public int VehicleControlIndex;

        public TrafficLightInfoData()
        {
            onlyFields = true;
        }
    }

    public class MassTrafficLightControl : SerializedClass
    {
        public MassTrafficLightStateFlags TrafficLightStateFlags;

        public MassTrafficLightControl()
        {
            onlyFields = true;
        }
    }

    public class TrafficLightPeriodControlInfo : SerializedClass
    {
        public List<MassTrafficLightControl> TrafficLightControls;
        public List<int> VehicleLanesOpen;

        public TrafficLightPeriodControlInfo()
        {
            onlyFields = true;
        }
    }

    // ======================== MAIN INIT DATA ========================

    public class AetherAIInitData : SerializedClass
    {
        public uint RaidId;
        public bool HasZoneGraph;
        public int ZoneStorageDataHandle;

        public List<ClientTrafficIntersectionInitInfo> Intersections;

        public List<ClientCrowdInitData> Crowds;

        public List<ClientStaticNpcInitData> StaticNpcs;

        public List<ClientVehicleInitData> Vehicles;

        public List<ClientStaticVehicleInitData> StaticVehicles;

        public List<ClientVehicleNpcInitData> VehicleNpcs;

        public List<ClientMetroNpcInitData> MetroNpcs;
    }

    // ======================== TRAFFIC INTERSECTION ========================

    public class ClientTrafficIntersectionInitInfo : SerializedClass
    {
        // Derived fields (from TrafficIntersectionPeriodInfo base)
        public byte CurrentPeriodIndex;
        public byte NextPeriodIndex;
        public byte RailPeriodIndex;

        // Own fields
        public ulong InstanceId;
        public int ZoneIndex;
        public UXVector3 Position;
        public List<TrafficLightInfoData> TrafficLightInfos;
        public List<TrafficLightPeriodControlInfo> PeriodControlInfos;
    }

    // ======================== CROWD (PEDESTRIAN NPC) ========================

    public class ClientCrowdInitData : SerializedClass
    {
        // Derived fields first (matching ClientStaticNpcInitData pattern)
        public uint NpcFormworkId;
        public uint AgentPersonaId;
        public uint UrbanDiversityConfigId;
        public float DesiredSpeed;
        public ushort ActionId;
        public ZoneGraphTargetLocationReason TargetLocationReason;
        public uint FashionSuitId;
        public List<ClientZoneGraphPathPoint> Points;

        // Base class fields last (ClientBaseEntityData)
        public ulong Id;
        public UXVector3 Position;
        public float Facing;
    }

    // ======================== AGENT SYNC CLIENT INFO ========================

    public class AgentSyncClientInfo : SerializedClass
    {
        public bool NeedFTF180DegreeInteract;
        public bool PlayerFTF180DegreeInteract;
        public uint IndoorId;
        public ulong chairId;
        public ulong gadgetId;
        public bool forbidAetherAI;
        public bool isApproachNpc;
        public bool TriggerLeaveEvent;
        public int approachDistance;
        public int LeaveDistance;
        public string petPerformData;
        public int[] stimIDList;
        public uint randomModelCfgId;
        public int layer;
        public float gpsOffsetY;
        public bool isTemp;
        public uint[] spawnEffectId;
        public uint hideEffectId;
        public uint actionId;
        public uint actionGroupId;
        public uint metroLineId;
        public uint metroCarriageId;
        public uint AgentDataSetsActivityCfgId;
        public uint GameplaySignalId;

        public string treeName;
        public int sitIndex;

        public List<uint> indoorList;
        public int[] roomIds;
        public AgentForbidStimulateType forbidStimulateType;
        public PlotAgentStimType agentStimType;
        public PlotAgentBeHitType beHitType;
        public int SpoonAgentId;
        public bool FeiSuo;
        public uint FashionSuitId;
        public bool CanBeExaminedByPolice;
        public bool IgnoreWanted;
        public enum AgentForbidStimulateType
        {
            None = 0,
            ForbidAllStimulate = 1,
            ForbidSubsequentStimulate = 2
        }
        public enum PlotAgentBeHitType
        {
            CanNotBeHit = 0,
            CanBeHitNoDamage = 1,
            CanBeHitWithDamage = 2
        }
        public enum PlotAgentStimType
        {
            AllStim = 0,
            OnlyInitialStim = 1,
            NoStim = 2
        }
        public AgentSyncClientInfo() { }
    }

    // ======================== SYNC CURRENT TASK ========================

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
        public enum ChangeCurrentTaskReason
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
        public enum CurrentTaskType
        {
            Primary = 0
        }
        public class TaskGps : SerializedClass
        {
            public uint BelongTaskId;
            public TaskGpsType Type;
            public UXVector3 Position;
            public ulong EnemyId;
            public int NpcSpoonId;
            public ulong NpcId;
        }
        public enum TaskGpsType
        {
            None = 0,
            Position = 1,
            Enemy = 2,
            Npc = 3
        }
    }

    // ======================== STATIC NPC (ALREADY WORKING) ========================

    public class ClientStaticNpcInitData : SerializedClass
    {
        public ulong StaticNpcInfoId;
        public uint NpcFormworkId;
        public uint AgentPersonaId;
        public uint PoiActionId;
        public uint UrbanDiversityId;
        public bool IgnoreAllStim;
        public bool TaskRelated;
        public bool EnableHack;
        public int NpcPid;

        public AgentSyncClientInfo AgentSyncClientInfo;
        public uint LookAtDecisionRulesId;
        public bool ForceGo;
        public StaticNpcSourceType SourceType;
        public ulong Id;
        public UXVector3 Position;
        public float Facing;
        public ClientStaticNpcInitData()
        {
            CustomFlagType = 2;
        }
        public enum StaticNpcSourceType : byte
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

    // ======================== VEHICLE (ACTIVE / TRAFFIC) ========================

    public class ClientVehicleInitData : SerializedClass
    {
        // Derived fields first
        public uint VehicleConfigId;
        public uint VehicleColorId;
        public byte VehicleLightState;
        public int LaneHandle;
        public float DistanceAlongLane;
        public ulong NextVehicleId;
        public double Timestamp;
        public VehicleControlType ControlType;
        public List<VehicleClientPart> Parts;

        // Base class fields last (ClientBaseEntityData)
        public ulong Id;
        public UXVector3 Position;
        public float Facing;
    }

    // ======================== STATIC VEHICLE (PARKED) ========================

    public class ClientStaticVehicleInitData : SerializedClass
    {
        // Derived fields first
        public uint VehicleConfigId;
        public uint ColorConfigId;
        public uint DamageStatusId;
        public double Timestamp;
        public bool NotDrive;
        public float RotationX;
        public float RotationY;
        public float RotationZ;
        public float RotationW;
        public List<VehicleClientPart> Parts;

        // Base class fields last (ClientBaseEntityData)
        public ulong Id;
        public UXVector3 Position;
        public float Facing;
    }

    // ======================== VEHICLE NPC (DRIVER/PASSENGER) ========================

    public class ClientVehicleNpcInitData : SerializedClass
    {
        public ulong Id;
        public uint NpcFormworkId;
        public ulong BindVehicleId;
        public byte SeatIndex;
    }

    // ======================== METRO NPC ========================

    public class ClientMetroNpcInitData : SerializedClass
    {
        // Derived fields first
        public uint NpcFormworkId;
        public ulong MetroInstanceId;
        public byte MetroCarriageIndex;
        public uint PoiActionId;

        // Base class fields last (ClientBaseEntityData)
        public ulong Id;
        public UXVector3 Position;
        public float Facing;
    }
}
