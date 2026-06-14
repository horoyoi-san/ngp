using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class EnterSceneInfo : SerializedClass
    {
        public ulong PlayerSessionId; // 0x10
        public uint RaidId; // 0x18
        public ulong InstanceId; // 0x20
        public UXVector3 Position; // 0x28
        public float Facing; // 0x34
        public string[] SpoonLevels; // 0x38
        public string[] SpoonMd5s; // 0x40
        public List<SpiritInitData> Spirits; // 0x48
        public ServerSimpleGridInfo GridInfo; // 0x50
        public uint MatchGameId; // 0x60
        public uint SwitchShowId; // 0x64
        public bool IsSwitchSpiritShow; // 0x68
        public uint SectorControlId; // 0x6C
        public LoadingTypeInfo LoadingType; // 0x70

        public EnterSceneInfo()
        {
           
        }

    }
    public class ServerSimpleGridInfo : SerializedClass
    {
        // Fields
        public int MinX; // 0x00
        public int MinZ; // 0x04
        public int MaxX; // 0x08
        public int MaxZ; // 0x0C

        public ServerSimpleGridInfo()
        {
            onlyFields = true;
        }
    }
    public class SpiritInitData : SerializedClass
    {
        // Fields
        public ulong Id; // 0x00
        public uint TemplateId; // 0x08
        public bool IsActive; // 0x0C
        public uint WeaponTemplateId; // 0x10
        public uint WeaponSkinId; // 0x14

        public SpiritInitData()
        {
            onlyFields = true;
        }
    }

    public class UXVector3 : SerializedClass
    {
        public float X; // 0x00
        public float Y; // 0x04
        public float Z; // 0x08

        public UXVector3()
        {
            onlyFields = true;
        }
    }
    public class LoadingTypeInfo : SerializedClass
    {
        public LoadingType Type; // 0x10
        public List<ulong> Members; // 0x18

    }
    public enum LoadingType // TypeDefIndex: 29152
    {
        Default = 0,
        Match = 1,
        WorldBattle = 2
    }
}
