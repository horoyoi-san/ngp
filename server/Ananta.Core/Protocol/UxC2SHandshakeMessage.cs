using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Messages
{
    public class UxC2SHandshakeMessage : UxMessage
    {

        public int MagicNum;

        // Constructors
        public UxC2SHandshakeMessage() : base(UxMessageType.C2SHandshake)
        {

        }
        public override void Parse()
        {
            this.MagicNum = BitConverter.ToInt32(Body, 0);
        }
        public override void Build()
        {
            this.WriteInt(MagicNum);
            this.FinalizeBuild();
        }

        public override string ToString()
        {
            return $"UxMessageType: {Type} MagicNum: {MagicNum}";
        }
    }
}
