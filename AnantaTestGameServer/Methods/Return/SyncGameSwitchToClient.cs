using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncGameSwitchToClient : SerializedClass
    {
        public Dictionary<string, SerializedClass> gameSwitch = new();

        public SyncGameSwitchToClient()
        {
            onlyFields = true;
        }
    }
}
