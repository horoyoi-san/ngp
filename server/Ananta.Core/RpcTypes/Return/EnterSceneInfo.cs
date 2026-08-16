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
        public ulong PlayerSessionId;
        public uint RaidId;
        public ulong InstanceId;
        public UXVector3 Position;
        public float Facing;
        public string[] SpoonLevels;
        public string[] SpoonMd5s;
        public List<SpiritInitData> Spirits;
        public ServerSimpleGridInfo GridInfo;
        public uint MatchGameId;
        public uint SwitchShowId;
        public bool IsSwitchSpiritShow;
        public uint SectorControlId;
        public LoadingTypeInfo LoadingType;

        public EnterSceneInfo()
        {
           
        }

    }
    public class ServerSimpleGridInfo : SerializedClass
    {
        // Fields
        public int MinX;
        public int MinZ;
        public int MaxX;
        public int MaxZ;

        public ServerSimpleGridInfo()
        {
            onlyFields = true;
        }
    }
    public class SpiritInitData : SerializedClass
    {
        // Fields
        public ulong Id;
        public uint TemplateId;
        public bool IsActive;
        public uint WeaponTemplateId;
        public uint WeaponSkinId;

        public SpiritInitData()
        {
            onlyFields = true;
        }
    }

    public class UXVector3 : SerializedClass
    {
        public float X;
        public float Y;
        public float Z;

        public UXVector3()
        {
            onlyFields = true;
        }
    }
    public class LoadingTypeInfo : SerializedClass
    {
        public LoadingType Type;
        public List<ulong> Members;

    }
    public enum LoadingType // TypeDefIndex: 29152
    {
        Default = 0,
        Match = 1,
        WorldBattle = 2
    }
}
