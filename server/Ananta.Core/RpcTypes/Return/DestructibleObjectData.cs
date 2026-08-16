using System.Collections.Generic;

namespace AnantaTestGameServer.Methods.Return
{
    public class DestructibleInfo : SerializedClass
    {
        public ulong DestructibleId;
        public uint ConfigId;
        public UXVector3 Position;
        public float Facing;
        public float Hp;
        public float MaxHp;
        public uint State;
        public ulong HolderPid;
        public uint HookId;
        public DestructibleInfo()
        {
            onlyFields = true;
        }
    }

    public class SyncDestructibleObjectAddEntry : SerializedClass
    {
        public ulong DestructibleId;
        public uint ConfigId;
        public UXVector3 Position;
        public float Facing;
        public float Hp;
        public float MaxHp;
        public uint State;
        public ulong HolderPid;
        public uint HookId;
        public SyncDestructibleObjectAddEntry()
        {
            onlyFields = true;
        }
    }

    public class AskHandHoldDestructibleObjectArgs : SerializedClass
    {
        public ulong DestructibleId;
        public AskHandHoldDestructibleObjectArgs()
        {
            onlyFields = true;
        }
    }

    public class AskEnterHoldDestructibleObjectArgs : SerializedClass
    {
        public ulong DestructibleId;
        public AskEnterHoldDestructibleObjectArgs()
        {
            onlyFields = true;
        }
    }

    public class AskLeaveHoldDestructibleObjectArgs : SerializedClass
    {
        public ulong DestructibleId;
        public AskLeaveHoldDestructibleObjectArgs()
        {
            onlyFields = true;
        }
    }

    public class AskRaiseDestructibleObjectArgs : SerializedClass
    {
        public ulong DestructibleId;
        public AskRaiseDestructibleObjectArgs()
        {
            onlyFields = true;
        }
    }

    public class AskPutDownDestructibleObjectArgs : SerializedClass
    {
        public ulong DestructibleId;
        public AskPutDownDestructibleObjectArgs()
        {
            onlyFields = true;
        }
    }

    public class AskMoveDestructibleObjectArgs : SerializedClass
    {
        public ulong DestructibleId;
        public UXVector3 Position;
        public float Facing;
        public AskMoveDestructibleObjectArgs()
        {
            onlyFields = true;
        }
    }

    public class AskBreakDestructibleObjectArgs : SerializedClass
    {
        public ulong DestructibleId;
        public AskBreakDestructibleObjectArgs()
        {
            onlyFields = true;
        }
    }

    public class AskDestroyDestructibleObjectArgs : SerializedClass
    {
        public ulong DestructibleId;
        public AskDestroyDestructibleObjectArgs()
        {
            onlyFields = true;
        }
    }

    public class DestructibleRemoveEntry : SerializedClass
    {
        public ulong DestructibleId;
        public DestructibleRemoveEntry()
        {
            onlyFields = true;
        }
    }

    public class DestructibleBreakEntry : SerializedClass
    {
        public ulong DestructibleId;
        public DestructibleBreakEntry()
        {
            onlyFields = true;
        }
    }

    public class SyncDestructibleObjectAddListData : SerializedClass
    {
        public List<SyncDestructibleObjectAddEntry> Objects;
        public SyncDestructibleObjectAddListData()
        {
            onlyFields = true;
        }
    }

    public class SyncDestructibleObjectRemoveListData : SerializedClass
    {
        public List<DestructibleRemoveEntry> Objects;
        public SyncDestructibleObjectRemoveListData()
        {
            onlyFields = true;
        }
    }

    public class SyncDestructibleObjectBreakData : SerializedClass
    {
        public ulong DestructibleId;
        public SyncDestructibleObjectBreakData()
        {
            onlyFields = true;
        }
    }

    /// <summary>
    /// Wire format for DestructibleGridAOIIncrease.addInfos — matches client Lua Reader[397].
    /// Fields MUST be in exact declaration order for correct serialization.
    /// Separate from DestructibleInfo to avoid breaking existing sync handlers.
    /// </summary>
    public class AoiDestructibleInfo : SerializedClass
    {
        public ulong InstanceId;      // runtime entity ID
        public ulong UniqueId;        // blob unique ID (same as InstanceId for server-spawned)
        public uint CfgId;            // template/config ID
        public int PathId;            // asset path hash (0 for default)
        public UXVector3 Position;    // world position
        public UXVector3 Facing;      // euler angles (x,y,z rotation)
        public int iScale;            // integer scale (1 = normal)
        public float Hp;              // current HP
        public int NavId;             // navmesh ID (0 for none)
        public byte State;            // 0=normal, 1=held, 2=broken, 3=destroyed
        public uint BreakStage;       // break stage (0 = intact)
        public List<SceneItemOccupantInfo> OccupantInfos; // who is occupying this
        public ulong DropWeaponId;    // dropped weapon entity (0 = none)
        public List<int> EffectIds;   // active effect IDs

        public AoiDestructibleInfo()
        {
            onlyFields = true;
            OccupantInfos = new List<SceneItemOccupantInfo>();
            EffectIds = new List<int>();
        }
    }
}
