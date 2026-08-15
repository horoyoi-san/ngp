using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncPlayerTaskResidentInfo : SerializedClass
    {
        public List<TaskSpoonViewInfo> taskSpoonViewInfos;
        public List<EventSpoonViewInfo> eventSpoonViewInfos;
        public bool add;

        public SyncPlayerTaskResidentInfo() : base()
        {
            onlyFields = true;
        }
    }
    public class TaskSpoonViewInfo : SerializedClass
    {
        // Fields
        public string SpoonMd5; // 0x10
        public uint SpRaidId; // 0x18
        public uint StartTaskId; // 0x1C
        public uint EndTaskId; // 0x20
     
        public string Alias; // 0x28
        public uint EventId; // 0x30
        public uint EventStartTaskId; // 0x34

        // Constructors
        public TaskSpoonViewInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }
}
