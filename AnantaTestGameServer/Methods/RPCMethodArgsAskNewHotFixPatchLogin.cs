using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods
{
    public class RPCMethodArgsAskNewHotFixPatchLogin : SerializedClass
    {
        public int version;
        public string md5;
        public int clientVersion;
    }
}
