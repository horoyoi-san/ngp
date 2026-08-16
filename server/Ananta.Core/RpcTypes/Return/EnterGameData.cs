using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class TokenInfo : SerializedClass
    {
        // Fields
        public int Aid; 
        public ulong Pid;
        public string Ip; 
        public int Port; 
        public string Token;
        public string RC4Key; 
        public int GateServerId; 
        public string AccountId; 
    }
    public class EnterGameData : SerializedClass
    {
        public int Aid;
        public ulong Pid;
        public TokenInfo Token;

        public EnterGameData() : base()
        {
            onlyFields = true;
        }
    }
}
