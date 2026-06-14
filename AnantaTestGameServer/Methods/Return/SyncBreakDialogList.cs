using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncBreakDialogList : SerializedClass
    {
        public List<uint> dialogIds;

        public SyncBreakDialogList() : base()
        {
            onlyFields = true;
        }

      
    }
}
