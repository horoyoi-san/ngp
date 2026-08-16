using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class AskVehicleHorn : SerializedClass
    {
        public ulong vehicleEntityId;
        public uint hornType;

        public AskVehicleHorn() : base()
        {
            onlyFields = true;
        }
    }
}
