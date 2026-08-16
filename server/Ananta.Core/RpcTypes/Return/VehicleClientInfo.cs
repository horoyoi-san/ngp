using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class VehicleClientInfo : SerializedClass
    {
        public ulong ControllerPid;
        public VehicleCreateSourceType CreateSourceType;
        public ulong EntityId;
        public uint VehicleConfigId;
        public List<VehicleClientPart> Parts;
        public UXVector3 Position;
        public float Facing;
        public float Velocity;
        public bool IsStatic;
        public uint ColorConfigId;
        public int DeformStatus;
        
        public List<RaidVehicleSeatInfo> SeatInfos;
        public int SpoonId;
        public bool IsDynamicGo;
        public VehicleSummonType SummonType;
        public ulong VehicleEnemyId;
        public bool DisableNavigation;
        public bool Interactable;
        public RaidVehicleGpsInfo GpsInfo;
    }
    public class RaidVehicleGpsInfo : SerializedClass
    {
        // Fields
        public ulong BelongPid;
        public uint TargetRaidId;
        public GpsType Type;
        public ulong TargetInstanceId;
        public UXVector3 TargetPosition;

        // Constructors
        public enum GpsType // TypeDefIndex: 34346
        {
            None = 0,
            Forward = 1,
            Trace = 2,
            WeakGuide = 3,
            FeiSuo = 4,
            Follow = 5,
            Car = 6,
            WallUpOverJump = 7,
            Responsive = 8,
            CoiledJumpPos = 9,
            FeiSouAttack = 10
        }
    }
    public enum VehicleSummonType // TypeDefIndex: 28853
    {
        None = 0,
        NormalSummon = 1,
        ForceSummon = 2
    }
    public class RaidVehicleSeatInfo : SerializedClass
    {
        // Fields
        public ulong EntityId;
        public byte SeatIndex;
        public RaidVehicleSeatState SeatState;
        public bool DestroyRelated;

        public enum RaidVehicleSeatState : byte // TypeDefIndex: 28861
        {
            Avaliable = 0,
            Claim = 1,
            Occupy = 2
        }
    }
    public class VehicleClientPart : SerializedClass
    {
        // Fields
        public uint Type;
        public uint ConfigId;

        public VehicleClientPart()
        {
            onlyFields=true;
        }
    }
    public enum VehicleCreateSourceType // TypeDefIndex: 28797
    {
        Invalid = 0,
        Task = 1,
        Summon = 2,
        MiniGame = 3,
        Online = 4,
        AetherAIBorrowVehicle = 5,
        AetherAIVehicleCollision = 6,
        EnemyTransform = 7,
        ForRam = 8,
        GM = 9
    }
}
