using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods
{
    public class RPCMethodArgsTryLogin : SerializedClass
    {
        public int aid;
        public string token;
        public bool updateAasInfo;
        public bool kick;
        public string deviceId;
        public bool strictOnlineMode;
        public bool confirmBindDevice;

    }
}
