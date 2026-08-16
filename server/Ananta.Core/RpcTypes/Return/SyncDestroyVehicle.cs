using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncDestroyVehicle : SerializedClass
    {
        public ulong vehicleEntityId;

        public SyncDestroyVehicle() : base()
        {
            onlyFields = true;
        }
    }
}
