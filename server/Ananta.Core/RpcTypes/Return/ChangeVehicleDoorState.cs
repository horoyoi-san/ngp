using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class ChangeVehicleDoorState : SerializedClass
    {
        public ulong vehicleEntityId;
        public byte doorIndex;
        public byte doorState;

        public ChangeVehicleDoorState() : base()
        {
            onlyFields = true;
        }
    }
}
