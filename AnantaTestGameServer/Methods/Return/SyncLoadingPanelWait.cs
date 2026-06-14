using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncLoadingPanelWait : SerializedClass
    {
        public bool addFlag;
        public string signal;

        public SyncLoadingPanelWait() : base()
        {
            onlyFields = true;
        }
    }
}
