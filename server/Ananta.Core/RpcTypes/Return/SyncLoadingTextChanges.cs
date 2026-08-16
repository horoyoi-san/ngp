using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncLoadingTextChanges : SerializedClass
    {
        public List<uint> addList;
        public List<uint> removeList;

        public SyncLoadingTextChanges() : base()
        {
            onlyFields = true;
        }
    }
}
