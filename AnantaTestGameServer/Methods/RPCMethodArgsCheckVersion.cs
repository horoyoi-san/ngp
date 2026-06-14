using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods
{
    public class RPCMethodArgsCheckVersion : SerializedClass
    {
        public string codeMd5; // 0x10
        public int clientVersion; // 0x18

    }
}
