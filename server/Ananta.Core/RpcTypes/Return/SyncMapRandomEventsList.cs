using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncMapRandomEventsList : SerializedClass
    {
        public Dictionary<uint, UintList> randomDic;
        public List<uint> notAbortList;

        public SyncMapRandomEventsList() : base()
        {
            onlyFields = true;
        }
        public class UintList : SerializedClass
        {
            public List<uint> Value;
        }
    }
}
