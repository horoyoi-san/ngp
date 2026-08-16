using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class NEACSetVerifyInfo : SerializedClass
    {
        public string lickey;
        public string serverResponse;
        public string msg;

        public NEACSetVerifyInfo() : base()
        {
            onlyFields = true;
        }
    }
}
