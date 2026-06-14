using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class PatchEntry : SerializedClass
    {
        // Fields
        public int Version;
        public byte[] Content;
        public string Md5;
    }
}
