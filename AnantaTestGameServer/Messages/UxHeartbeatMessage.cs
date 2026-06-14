using AnantaTestGameServer.Utils;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Messages
{
    public class UxHeartbeatMessage : UxMessage
    {

        public ulong ElapsedTicks;
        // Constructors
        public UxHeartbeatMessage() : base(UxMessageType.Heartbeat)
        {

        }
        public override void Parse()
        {
            this.ElapsedTicks = BitConverter.ToUInt64(Body, 0);
        }
        public override void Build()
        {
            this.WriteULong(ElapsedTicks);
           
            this.FinalizeBuild();
        }

        public override string ToString()
        {
            return $"UxMessageType: {Type} ElapsedTicks: {ElapsedTicks}";
        }
    }
}
