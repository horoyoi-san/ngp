using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SendServerTimeGame : SerializedClass
    {
        public double clientUnixTime;
        public double serverUnixTime;

        public SendServerTimeGame() : base()
        {
            onlyFields = true;
        }
    }
}
