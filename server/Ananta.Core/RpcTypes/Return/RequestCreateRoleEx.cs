using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class RequestCreateRoleEx : SerializedClass
    {
        public ulong uid;

        public RequestCreateRoleEx() : base()
        {
            onlyFields = true;
        }
    }
}
