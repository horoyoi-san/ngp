using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncPrepareMapEntrance : SerializedClass
    {
        public uint entrance;

        public SyncPrepareMapEntrance() : base()
        {
            onlyFields = true;
        }
    }
}
