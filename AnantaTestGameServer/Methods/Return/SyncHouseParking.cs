using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncHouseParking : SerializedClass
    {
        public List<HouseVehicleParkingInfo> cancelInfoList;
        public List<HouseVehicleParkingInfo> addInfoList;

        public SyncHouseParking() : base()
        {
            onlyFields = true;
        }
        public class HouseVehicleParkingInfo : SerializedClass
        {

        }
    }
 
}
