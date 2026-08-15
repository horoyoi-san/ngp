using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods
{
    public class RPCMethodArgsTryLogin : SerializedClass
    {
        public int aid; // 0x10
        public string token; // 0x18
        public bool updateAasInfo; // 0x20
        public bool kick; // 0x21
        public string deviceId; // 0x28
        public bool strictOnlineMode; // 0x30
        public bool confirmBindDevice; // 0x31


    }
}
