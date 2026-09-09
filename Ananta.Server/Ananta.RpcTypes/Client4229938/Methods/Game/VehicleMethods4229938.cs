using Ananta.SDK.Serialization;
using SceneMethods = Ananta.Server.RpcTypes.Client4229938.Methods.GameScene;

namespace Ananta.Server.RpcTypes.Client4229938.Methods.Game;

/// <summary>
/// Vehicle summon/ownership wire contracts for client 4229938. Field order is the wire
/// order, verified 1:1 against lua/LuaGen/AutoGen/RPCSerializeAuto.lua
/// (WriteVehicleClientInfo, WriteLogicVehicleClientInfo, WriteSummonVehicleResult,
/// WritePlayerVehicleClientDetail, WriteRaidVehicleSeatInfo, WriteNewClientBoardingInfo,
/// WriteBoardingExtInfo, WritePlayerVehicleDriveStateInfo, WriteRaidVehicleSyncData,
/// WriteVehicleClientPart) and ClientToGameSceneDelegate.lua arg serializers.
/// New-vs-4091149 deltas already applied: LogicVehicleClientInfo.VehicleSpoonName (tail)
/// and PlayerVehicleClientDetail.IsPersistent (tail).
/// </summary>
[UxContract(Inline = true)]
internal sealed class AskSummonVehicleArgs4229938
{
    public uint vehicleconfigid;
    public SceneMethods.UxVector3 position;
    public float facingdirection;
}

[UxContract(Inline = true)]
internal sealed class SummonVehicleResult4229938
{
    public ulong VehicleEntityId;
    public ulong TaskToken;
}

[UxContract(Inline = true)]
internal sealed class VehicleClientPart4229938
{
    public uint Type;
    public uint ConfigId;
}

[UxContract]
internal sealed class PlayerVehicleClientDetail4229938
{
    public uint Id;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<VehicleClientPart4229938> Parts = [];
    public uint SuitId;
    public bool IsPersistent;
}

[UxContract]
internal sealed class LogicVehicleClientInfo4229938
{
    public ulong EntityId;
    public uint VehicleConfigId;
    public byte CreateSourceType;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<VehicleClientPart4229938> Parts = [];
    public uint SuitId;
    public string LicensePlate = string.Empty;
    public bool Interactable;
    public int MoveToken;
    public SceneMethods.UxVector3 Position;
    public SceneMethods.UxVector3 EulerAngles;
    public string? VehicleSpoonName;
}

[UxContract]
internal sealed class RaidVehicleSeatInfo4229938
{
    public ulong EntityId;
    public byte SeatIndex;
    public byte SeatState;
    public bool DestroyRelated;
}

[UxContract]
internal sealed class VehicleClientInfo4229938
{
    public ulong ControllerPid;
    public byte CreateSourceType;
    public ulong EntityId;
    public uint VehicleConfigId;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<VehicleClientPart4229938> Parts = [];
    public uint SuitId;
    public SceneMethods.UxVector3 Position;
    public float Facing;
    public SceneMethods.UxVector3 EulerAngles;
    public float Velocity;
    public bool IsStatic;
    public int DeformStatus;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<RaidVehicleSeatInfo4229938> SeatInfos = [];
    public int SpoonId;
    public bool IsDynamicGo;
    public ulong VehicleEnemyId;
    public bool DisableNavigation;
    public bool Interactable;
    public int MoveToken;
    public string LicensePlate = string.Empty;
}

[UxContract(Inline = true)]
internal sealed class SyncChangeVehicleInteractable4229938
{
    public ulong vehicleInstanceId;
    public bool interactable;
}

[UxContract(Inline = true)]
internal sealed class SyncChangeVehicleController4229938
{
    public ulong vehicleInstanceId;
    public ulong controllerPid;
}

[UxContract(Inline = true)]
internal sealed class VehicleTaskState4229938
{
    public ulong VehicleEntityId;
    public ulong TaskToken;
    public byte Status;
}

[UxContract(Inline = true)]
internal sealed class DestroyVehicle4229938
{
    public ulong VehicleEntityId;
    public byte VehicleDestroyType;
    public int Distance;
    public int DynamicGoId;
}

[UxContract]
internal sealed class RaidVehicleSyncData4229938
{
    public ulong Id;
    public SceneMethods.UxVector3 Position;
    public float facingDirection;
    public SceneMethods.UxVector3 EulerAngles;
    public SceneMethods.UxVector3 Velocity;
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<byte> Bits = [];
    public int MoveToken;
}

[UxContract(Inline = true)]
internal sealed class SyncVehicleMove4229938
{
    [UxObject(Encoding = UxObjectEncoding.Complex)]
    public RaidVehicleSyncData4229938 Data = new();
}

[UxContract]
internal sealed class BoardingExtInfo4229938
{
    public SceneMethods.UxVector3 PositionOffset;
    public SceneMethods.UxVector3 RotationOffset;
    public bool CanBeEjected;
    public bool UseSpecificAction;
    public uint ActionGroup;
    public uint ActionId;
}

[UxContract]
internal sealed class NewClientBoardingInfo4229938
{
    public ulong EntityId;
    public byte Status;
    public ulong VehicleUId;
    public byte SeatIndex;
    public BoardingExtInfo4229938? ExtInfo;
}

/// <summary>Server notify: SyncPlayerMoveToDriveSeat (68778293).</summary>
[UxContract(Inline = true)]
internal sealed class SyncPlayerMoveToDriveSeat4229938
{
    public ulong pid;
    public ulong vehicleEntityId;
}

/// <summary>Server notify: SyncPlayerExitVehicle (exit leg).</summary>
[UxContract(Inline = true)]
internal sealed class SyncPlayerExitVehicle4229938
{
    public ulong vehicleEntityId;
    public bool force;
    public bool stopBeforeLeave;
}

/// <summary>Drive-state struct shared by client notifies and server enter/exit notifies.</summary>[UxContract(Inline = true)]
internal sealed class PlayerVehicleDriveStateInfo4229938
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
internal sealed class AskClaimVehicleSeatArgs4229938
{
    public ulong vehicleEntityId;
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<byte> seatIndices = [];
}

/// <summary>Client invoke arg: AskPublicSwitchToPublicScene (63491547).</summary>
[UxContract(Inline = true)]
internal sealed class AskPublicSwitchToPublicSceneArgs
{
    public uint raidId;
    public bool delay;
    public uint mapEntranceId;
}

/// <summary>Client invoke arg: AskEnterRaidByMapEntrance (63510026).</summary>
[UxContract(Inline = true)]
internal sealed class AskEnterRaidByMapEntranceArgs
{
    public uint mapEntranceId;
}

/// <summary>Aether vehicle init (SyncAetherAIInitDatas, 68704070). Lists stay empty.</summary>
[UxContract(Inline = true)]
internal sealed class AetherAIInitData4229938
{
    public uint RaidId;
    public bool HasZoneGraph;
    public int ZoneStorageDataHandle;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<AetherInitStub4229938> Intersections = [];
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<AetherInitStub4229938> Vehicles = [];
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Complex)]
    public List<AetherInitStub4229938> StaticVehicles = [];
}

/// <summary>Never serialized (all Aether init lists are empty); satisfies the serializer.</summary>
[UxContract]
internal sealed class AetherInitStub4229938
{
}

/// <summary>Client notify arg: AskInteractCmd (67390408). Logged + accepted.</summary>
[UxContract(Inline = true)]
internal sealed class AskInteractCmdArgs4229938
{
    public uint CmdType;
    public ulong sender;
    public ulong receiver;
    public int broadCastType;
    [UxCollection(Count = UxCountEncoding.Int7)]
    public List<byte>? CommandData;
    public string? stringParam1;
    public string? stringParam2;
}

/// <summary>Client notify: ReportDrivingVehicle (67528706).</summary>
[UxContract(Inline = true)]
internal sealed class ReportDrivingVehicleArgs4229938
{
    public ulong vehicleId;
    public bool isDriving;
    public float deltaDistance;
}

/// <summary>Client notify: AskVehicleNitroValue (67533682).</summary>
[UxContract(Inline = true)]
internal sealed class AskVehicleNitroValueArgs4229938
{
    public ulong vehicleId;
    public float value;
}

/// <summary>Client invoke: AskVehicleNitro (67037029).</summary>
[UxContract(Inline = true)]
internal sealed class AskVehicleNitroArgs4229938
{
    public ulong VehicleId;
    public float NitrogenValue;
    public bool BeginOrEnd;
}

/// <summary>Client notify: AskModifyVehicleTopSpeed (67920147).</summary>
[UxContract(Inline = true)]
internal sealed class AskModifyVehicleTopSpeedArgs4229938
{
    public ulong vehicleId;
    public float topSpeed;
    public bool beginOrEnd;
}

/// <summary>Client notify: AskVehicleHorn (67983272).</summary>
[UxContract(Inline = true)]
internal sealed class AskVehicleHornArgs4229938
{
    public ulong entityId;
    public bool play;
}

/// <summary>Client notify: AskVehicleContactDamage (67589692).</summary>
[UxContract(Inline = true)]
internal sealed class AskVehicleContactDamageArgs4229938
{
    public ulong vehicleId;
    public VehicleContactDamageData4229938 data = new();
}

/// <summary>Full contact-damage struct (WriteVehicleContactDamageData order).</summary>
[UxContract(Inline = true)]
internal sealed class VehicleContactDamageData4229938
{
    public float VehicleMass;
    [UxCollection(Count = UxCountEncoding.Int7, ItemObjectEncoding = UxObjectEncoding.Struct)]
    public List<SceneMethods.UxVector3> VehicleVelocities = [];
    public SceneMethods.UxVector3 VehicleRelativeVelocity;
    public uint Layer;
    public float TouchMass;
    public float EnemyWeight;
    public uint EnemyRank;
    public bool DisableThreshold;
    public ulong OtherVehicleEntityId;
}

/// <summary>Client invoke: AskGetVehicleRadioContent (67725622).</summary>
[UxContract(Inline = true)]
internal sealed class AskGetVehicleRadioContentArgs4229938
{
    public uint radioId;
    public int songIdx;
}

/// <summary>Client notify: SyncChangeSafeArea (63310118).</summary>
[UxContract(Inline = true)]
internal sealed class SyncChangeSafeAreaArgs4229938
{
    public uint regionId;
}

/// <summary>Client invoke: SyncChangeBuilding (63495099).</summary>
[UxContract(Inline = true)]
internal sealed class SyncChangeBuildingArgs4229938
{
    public int buildingId;
    public int floorId;
}

/// <summary>Client invoke: SyncChangeIndoor (63927817).</summary>
[UxContract(Inline = true)]
internal sealed class SyncChangeIndoorArgs4229938
{
    public uint indoorConfigId;
    public uint boundId;
}
