using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class LoginGame : SerializedClass
    {

        public ulong pid;
        public string token;
        public LoginGame()
        {
            onlyFields = true;
        }
    }
}
