using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class UpdateLoginNgPushRegid : SerializedClass
    {
        public string regid;

        public UpdateLoginNgPushRegid() : base()
        {
            onlyFields = true;
        }
    }
}
