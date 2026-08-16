using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncFactionInfosChange : SerializedClass
    {
        public List<FactionChangeInfo> changeInfos;
        public uint dropTextId;

        public SyncFactionInfosChange() : base()
        {
            onlyFields = true;
        }

        public class FactionChangeInfo : SerializedClass
        {
            public uint FactionId;
            public FactionInfo NewInfo;
            public FactionInfo OldInfo;
        }
    }
}
