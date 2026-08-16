using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncTaskRoleTeam : SerializedClass
    {
        public uint[] roleTeam;
        public uint[] enableRoleIds;
        public uint tipRoleId;
        public bool enableSwitch;

        public SyncTaskRoleTeam() : base()
        {
            onlyFields = true;
        }
    }
}
