using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class PlayerVehicleDriveStateInfo : SerializedClass
    {
        public ulong Pid;
        public bool EnterOrLeave;
        public ulong VehicleEntityId;
        public int SeatIndex;
        public bool IfForce;
        public int OpenDoorTypeId;
        public int OpenDoorActionSpeed;
        public int OpenDoorActionClipLength;
    }
   
}
