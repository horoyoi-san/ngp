using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SendServerTime : SerializedClass
    {
        public double clientTime; 
        public double time;


        public SendServerTime() : base()
        {
            onlyFields = true;
        }

    }
}
