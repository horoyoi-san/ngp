using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    
    public class NewHotFixPatchData : SerializedClass
    {
        public int Version; // 0x00
        public byte[] Content; // 0x08
        public string Md5; // 0x10


    }
}
