using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncPlayerLoadRate : SerializedClass
    {
        public ulong pid;
        public double rate;

        public SyncPlayerLoadRate() : base()
        {
            onlyFields = true;
        }
    }
}
