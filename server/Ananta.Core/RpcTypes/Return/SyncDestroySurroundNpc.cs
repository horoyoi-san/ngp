using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncDestroySurroundNpc : SerializedClass
    {
        public ulong npcEntityId;

        public SyncDestroySurroundNpc() : base()
        {
            onlyFields = true;
        }
    }
}
