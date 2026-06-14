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
        public int Id; // 0x10
        public uint LineId; // 0x14
        public float ElapsedTime; // 0x18
        public bool IsFinalTrain; // 0x1C

        // Constructors
        public MetroClientInfo() { } // 0x00000001871763E0-0x00000001871763F0
    }
}
