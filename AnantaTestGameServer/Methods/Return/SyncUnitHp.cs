using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncUnitHp : SerializedClass
    {
        public ulong unitId;
        public float hp;

        public SyncUnitHp() : base()
        {
            onlyFields = true;
        }
    }
}
