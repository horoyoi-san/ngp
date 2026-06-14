using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class VehicleClientInfo : SerializedClass
    {
        public ulong ControllerPid; // 0x10
        public VehicleCreateSourceType CreateSourceType; // 0x18
        public ulong EntityId; // 0x20
        public uint VehicleConfigId; // 0x28
        public List<VehicleClientPart> Parts; // 0x30
        public UXVector3 Position; // 0x38
        public float Facing; // 0x44
        public float Velocity; // 0x48
        public bool IsStatic; // 0x4C
        public uint ColorConfigId; // 0x50
        public int DeformStatus; // 0x54
        
        public List<RaidVehicleSeatInfo> SeatInfos; // 0x58
        public int SpoonId; // 0x60
        public bool IsDynamicGo; // 0x64
        public VehicleSummonType SummonType; // 0x68
        public ulong VehicleEnemyId; // 0x70
        public bool DisableNavigation; // 0x78
        public bool Interactable; // 0x79
        public RaidVehicleGpsInfo GpsInfo; // 0x80
    }
    public class RaidVehicleGpsInfo : SerializedClass
    {
        // Fields
        public ulong BelongPid; // 0x10
        public uint TargetRaidId; // 0x18
        public GpsType Type; // 0x1C
        public ulong TargetInstanceId; // 0x20
        public UXVector3 TargetPosition; // 0x28

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
        public ulong EntityId; // 0x10
        public byte SeatIndex; // 0x18
        public RaidVehicleSeatState SeatState; // 0x19
        public bool DestroyRelated; // 0x1A

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
        public uint Type; // 0x00
        public uint ConfigId; // 0x04

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
