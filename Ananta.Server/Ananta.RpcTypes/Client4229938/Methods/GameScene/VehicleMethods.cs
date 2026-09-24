using Ananta.SDK.Serialization;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

[UxContract(Inline = true)]
internal sealed class AskSummonVehicle
{
    public uint VehicleConfigId;
    public UxVector3 Position;
    public float FacingDirection;
}

[UxContract(Inline = true)]
internal sealed class SummonVehicleResult
{
    public ulong VehicleEntityId;
    public ulong TaskToken;
}

[UxContract(Inline = true)]
internal struct VehicleClientPart
{
    public uint Type;
    public uint ConfigId;
}

[UxContract]
internal sealed class PlayerVehicleClientDetail
{
    public uint Id;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<VehicleClientPart> Parts = [];
    public uint SuitId;
    public bool IsPersistent;
}

[UxContract]
internal sealed class SyncLogicVehicleEnter
{
    public ulong EntityId;
    public uint VehicleConfigId;
    
    public byte CreateSourceType;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<VehicleClientPart> Parts = [];
    public uint SuitId;
    public string LicensePlate = string.Empty;
    public bool Interactable;
    public int MoveToken;
    public UxVector3 Position;
    public UxVector3 EulerAngles;
    public string? VehicleSpoonName;
}

[UxContract]
internal sealed class RaidVehicleSeatInfo
{
    public ulong EntityId;
    public byte SeatIndex;
    public byte SeatState;
    public bool DestroyRelated;
}

[UxContract]
internal sealed class VehicleClientInfo
{
    public ulong ControllerPid;
    public byte CreateSourceType;
    public ulong EntityId;
    public uint VehicleConfigId;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<VehicleClientPart> Parts = [];
    public uint SuitId;
    public UxVector3 Position;
    public float Facing;
    public UxVector3 EulerAngles;
    public float Velocity;
    public bool IsStatic;
    public int DeformStatus;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<RaidVehicleSeatInfo> SeatInfos = [];
    public int SpoonId;
    public bool IsDynamicGo;
    public ulong VehicleEnemyId;
    public bool DisableNavigation;
    public bool Interactable;
    public int MoveToken;
    public string LicensePlate = string.Empty;
}

[UxContract(Inline = true)]
internal sealed class DestroyVehicle
{
    public ulong VehicleEntityId;
    public byte VehicleDestroyType;
    public int Distance;
    public int DynamicGoId;
}

[UxContract(Inline = true)]
internal sealed class AskGetUnlockedVehiclesResult
{
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<PlayerVehicleClientDetail> Vehicles = [];
}

[UxContract(Inline = true)]
internal sealed class SyncTeleportVehicle
{
    public ulong EntityId;
    public UxVector3 Position;
    public UxVector3 Rotation;
    public float Velocity;
    public bool Reset;
    public int MoveToken;
}

[UxContract(Inline = true)]
internal sealed class SyncRemoveVehicle
{
    public ulong EntityId;
}

[UxContract]
internal sealed class RaidVehicleSyncData
{
    public ulong Id;
    public UxVector3 Position;
    public float FacingDirection;
    public UxVector3 EulerAngles;
    public UxVector3 Velocity;
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<byte> Bits = [];
    public int MoveToken;
}

[UxContract]
internal sealed class AetherAIInitData
{
    public uint RaidId;
    public bool HasZoneGraph;
    public int ZoneStorageDataHandle;

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<ClientTrafficIntersectionInitInfo> Intersections = [];
}

[UxContract]
internal sealed class ClientTrafficIntersectionInitInfo
{
    public ulong InstanceId;
    public int ZoneIndex;
    public byte CurrentState;
    public byte CurrentPeriodIndex;
    public byte NextPeriodIndex;
    public byte RailPeriodIndex;
}

[UxContract]
internal sealed class ClientVehicleInitData
{
    public uint VehicleConfigId;
    public uint VehicleColorId;
    public byte VehicleLightState;
    public int LaneHandle;
    public float DistanceAlongLane;
    public ulong NextVehicleId;
    public double Timestamp;
    public byte ControlType;
    public float Speed;
    public float DustRatio;

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<VehicleClientPart> Parts = [];

    public uint SuitId;

    
    
    
    public float RandomFraction;

    public ulong Id;

    
    
    
    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public Auto.UXVector3 Position = new();

    public float Facing;

    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public Auto.UXVector3 EulerAngles = new();
}

[UxContract]
internal sealed class ClientStaticVehicleInitData
{
    public uint VehicleConfigId;
    public uint ColorConfigId;
    public uint DamageStatusId;
    public double Timestamp;
    public bool NotDrive;
    public float RotationX;
    public float RotationY;
    public float RotationZ;
    public float RotationW;

    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<VehicleClientPart> Parts = [];

    public uint SuitId;
    public float DustRatio;
    public ulong Id;

    
    
    
    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public Auto.UXVector3 Position = new();

    public float Facing;

    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public Auto.UXVector3 EulerAngles = new();
}

[UxContract(Inline = true)]
internal sealed class SyncChangeVehicleInteractable
{
    public ulong VehicleInstanceId;
    public bool Interactable;
}

[UxContract(Inline = true)]
internal sealed class SyncChangeVehicleController
{
    public ulong VehicleInstanceId;
    public ulong ControllerPid;
}

[UxContract]
internal sealed class BoardingExtInfo
{
    public UxVector3 PositionOffset;
    public UxVector3 RotationOffset;
    public bool CanBeEjected;
    public bool UseSpecificAction;
    public uint ActionGroup;
    public uint ActionId;
}

[UxContract]
internal sealed class NewClientBoardingInfo
{
    public ulong EntityId;
    public byte Status;
    public ulong VehicleUId;
    public byte SeatIndex;
    public BoardingExtInfo? ExtInfo;
}

[UxContract(Inline = true)]
internal sealed class SyncPlayerMoveToDriveSeat
{
    public ulong Pid;
    public ulong VehicleEntityId;
}

[UxContract(Inline = true)]
internal sealed class SyncPlayerExitVehicle
{
    public ulong VehicleEntityId;
    public bool Force;
    public bool StopBeforeLeave;
}

[UxContract(Inline = true)]
internal sealed class PlayerVehicleDriveStateInfo
{
    public ulong Pid;
    public bool EnterOrLeave;
    public ulong VehicleEntityId;
    public int SeatIndex;
    public bool IfForce;
    public int OpenDoorTypeId;
    public int OpenDoorActionSpeed;
    public int OpenDoorActionClipLength;
}

[UxContract]
internal sealed class PlayerVehicleDriveStateInfoClientArg4229938
{
    public ulong Pid;
    public bool EnterOrLeave;
    public ulong VehicleEntityId;
    public int SeatIndex;
    public bool IfForce;
    public int OpenDoorTypeId;
    public int OpenDoorActionSpeed;
    public int OpenDoorActionClipLength;
}

[UxContract(Inline = true)]
internal sealed class AskClaimVehicleSeatArgs
{
    public ulong VehicleEntityId;
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<byte> SeatIndices = [];
}

[UxContract(Inline = true)]
internal sealed class SyncVehicleForceGo4229938
{
    public ulong vehicleEntityId;
    public bool isForceGo;
}

[UxContract]
internal sealed class ClientVehicleNpcInitData4229938
{
    
    public ulong Id;

    
    public uint NpcFormworkId;

    
    public ulong BindVehicleId;

    
    public byte SeatIndex;
}

[UxContract(Inline = true)]
internal sealed class SyncAetherAIVehicleNpcAdd4229938
{
    public ClientVehicleNpcInitData4229938 initData = new();
}

[UxContract(Inline = true)]
internal sealed class SyncAetherAIVehicleRemove4229938
{
    public ulong pid;
}

[UxContract(Inline = true)]
internal sealed class SyncAetherAIVehicleForceGo4229938
{
    public ulong instanceId;
    public bool forceGo;
}

[UxContract(Inline = true)]
internal sealed class SyncAgentForceGo4229938
{
    public ulong id;
    public bool isForceGo;
}

[UxContract(Inline = true)]
internal sealed class SyncAetherAIChangeVehicleControlType4229938
{
    public ulong vehicleId;
    public byte vehicleControlType;
}

[UxContract(Inline = true)]
internal sealed class SyncAetherAINpcRemove4229938
{
    public ulong pid;
}

[UxContract]
internal sealed class ClientCrowdInitData4229938
{
    public uint NpcFormworkId;
    public uint AgentPersonaId;
    public uint UrbanDiversityConfigId;
    public float DesiredSpeed;
    public ushort ActionId;
    public byte TargetLocationReason;
    public uint FashionSuitId;
    public ulong Id;

    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public Auto.UXVector3 Position = new();

    public float Facing;

    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public Auto.UXVector3 EulerAngles = new();
}

[UxContract(Inline = true)]
internal sealed class SyncAetherAICrowdAdd4229938
{
    public ClientCrowdInitData4229938 crowd = new();
}

[UxContract]
internal sealed class ClientStaticNpcInitData4229938
{
    public ulong StaticNpcInfoId;
    public uint NpcFormworkId;
    public uint AgentPersonaId;
    public uint SPoiActionId;
    public uint CPoiActionId;
    public uint UrbanDiversityId;
    public bool IgnoreAllStim;
    public bool TaskRelated;
    public bool EnableHack;
    public int NpcPid;

    
    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public AgentSyncClientInfo4229938? AgentSyncClientInfo;

    public uint LookAtDecisionRulesId;
    public bool ForceGo;
    public byte SourceType;

    
    
    
    
    public uint MartialArtistGossipConfigID;

    public ulong Id;

    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public Auto.UXVector3 Position = new();

    public float Facing;

    [UxObject(Encoding = UxObjectEncoding.Struct)]
    public Auto.UXVector3 EulerAngles = new();
}

[UxContract(Inline = true)]
internal sealed class SyncAetherAIStaticNpcAddData4229938
{
    public ClientStaticNpcInitData4229938 data = new();
}

[UxContract]
internal sealed class AgentSyncClientInfo4229938
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
    public string? petPerformData = "";
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<int> stimIDList = [];
    public uint randomModelCfgId;
    public int layer;
    public float gpsOffsetY;
    public bool isTemp;
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<uint> spawnEffectId = [];
    public uint hideEffectId;
    public uint actionId;
    public uint actionGroupId;
    public uint initPoiActionId;
    public bool useDefaultPoiOnReturn;
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<uint> returnPoiActionIds = [];

    
    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public NpcAdhereMovingPlatformInfo4229938? AdherePlatformInfo;

    public uint AgentDataSetsActivityCfgId;
    public uint GameplaySignalId;
    public string treeName = "";
    public int sitIndex;
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<uint> indoorList = [];
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<int> roomIds = [];
    public byte forbidStimulateType;
    public byte agentStimType;
    public byte beHitType;
    public int SpoonAgentId;
    public bool isAttackInSafeMode;
    public bool FeiSuo;
    public uint FashionSuitId;
    public bool CanBeExaminedByPolice;
    public bool IgnoreWanted;
    public bool BeAttackIgnorePolicePunish;
    public uint InteractId;
    public uint AISetting;
    public NpcLinkAIAgentInfo4229938 AIAgentInfo = new();
    public bool HackerBetray;
}

[UxContract]
internal sealed class NpcAdhereMovingPlatformInfo4229938
{
    public byte PlatformType;
    public bool IsScene;
    public ulong PlatformId;
    public uint PartId;
    public ulong PlatformEid;
}

[UxContract]
internal sealed class NpcLinkAIAgentInfo4229938
{
    public ulong Uid;
    public uint FightSpiritId;
    public NpcLinkAIFashionInfo4229938? Fashion;
    public string? Nickname;
    public uint NameId;
    public uint AvatarImageId;
    public uint VehicleId;
}

[UxContract]
internal sealed class NpcLinkAIFashionInfo4229938
{
    public uint SuitId;
    public Auto.OtherPlayerSpiritWearFashionsInfo WearInfo = new();
}
