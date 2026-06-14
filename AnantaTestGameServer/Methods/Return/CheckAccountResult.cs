using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    
    public class CheckAccountResult : SerializedClass
    {
        
        public string unisdk_login_json;
        public string Token;
        public string UserName;
        public int Aid;
        public bool NeedRealNameTip;
        public bool NeedRoleEnter;
        public bool RealNameVerified;
        public int HostId;
        public string OpenIdUrl;
        public int code;
        public int subcode;
        public string msg;

        
    }
}
