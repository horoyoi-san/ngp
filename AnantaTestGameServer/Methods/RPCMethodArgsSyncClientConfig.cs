using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods
{
    public class RPCMethodArgsSyncClientConfig : SerializedClass
    {
        public byte[] config = new byte[0];

       public RPCMethodArgsSyncClientConfig()
        {
            onlyFields = true;
        }
    }
}
