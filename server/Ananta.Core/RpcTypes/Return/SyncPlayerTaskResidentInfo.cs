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
        public string SpoonMd5;
        public uint SpRaidId;
        public uint StartTaskId;
        public uint EndTaskId;
     
        public string Alias;
        public uint EventId;
        public uint EventStartTaskId;

    }
}
