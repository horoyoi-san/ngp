using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncRunningMetroInfos : SerializedClass
    {
        public List<MetroClientInfo> metroInfos;

        public SyncRunningMetroInfos() : base()
        {
            onlyFields = true;
        }
    }
    public class MetroClientInfo : SerializedClass
    {
        // Fields
        public int Id;
        public uint LineId;
        public float ElapsedTime;
        public bool IsFinalTrain;
        public UXVector3 Position;      // Current world position of the train
        public float Facing;             // Rotation angle in degrees
        public float Speed;              // Current speed (m/s)

    }

    // Server -> Client: subway fare deduction when player boards a metro.
    // MethodId.SyncSubwayFare (64826755)
    public class SyncSubwayFare : SerializedClass
    {
        public float fare;       // fare amount deducted
        public uint lineId;      // which metro line was boarded

        public SyncSubwayFare() : base()
        {
            onlyFields = true;
        }
    }
}
