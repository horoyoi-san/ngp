using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncAllUnlockedVehicles : SerializedClass
    {
        public List<PlayerVehicleClientDetail> unlockedVehicles;

        public SyncAllUnlockedVehicles() : base()
        {
            onlyFields = true;
        }
        public class PlayerVehicleClientDetail : SerializedClass
        {
            public uint Id;
        }
    }
}
