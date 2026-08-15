using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class PlayerVehicleDriveStateInfo : SerializedClass
    {
        public ulong Pid; // 0x10
        public bool EnterOrLeave; // 0x18
        public ulong VehicleEntityId; // 0x20
        public int SeatIndex; // 0x28
        public bool IfForce; // 0x2C
        public int OpenDoorTypeId; // 0x30
        public int OpenDoorActionSpeed; // 0x34
        public int OpenDoorActionClipLength; // 0x38
    }
   
}
