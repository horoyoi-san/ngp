using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class ServerAvailableState : SerializedClass
    {
        public EnumServerAvailableState state=EnumServerAvailableState.Normal;

        public ServerAvailableState() : base()
        {
            onlyFields = true;
        }
        public enum EnumServerAvailableState // TypeDefIndex: 28539
        {
            Normal = 0,
            Inavailable = 1,
            Shutdown = 2
        }
    }
}
