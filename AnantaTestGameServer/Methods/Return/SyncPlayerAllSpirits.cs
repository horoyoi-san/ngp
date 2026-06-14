using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncPlayerAllSpirits : SerializedClass
    {
        public List<SpiritInfo> list;

        public SyncPlayerAllSpirits() : base()
        {
            onlyFields = true;
        }
        
    }
 
}
