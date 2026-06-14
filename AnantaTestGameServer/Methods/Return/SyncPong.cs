using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncPong : SerializedClass
    {
        public double time;

        public SyncPong() : base()
        {
            onlyFields = true;
        }
    }
}
