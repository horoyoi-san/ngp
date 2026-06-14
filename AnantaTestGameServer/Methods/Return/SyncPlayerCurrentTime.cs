using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer.Methods.Return
{
    public class SyncPlayerCurrentTime : SerializedClass
    {
        public uint realTime; 
        public uint raidDaySeconds; 
        public bool fix; 
        public uint transitionSecond;
        public RaidTimeAndWeatherChangeReason reason;

        public SyncPlayerCurrentTime() : base()
        {
            onlyFields = true;
        }
        public enum RaidTimeAndWeatherChangeReason // TypeDefIndex: 28793
        {
            Gm = 0,
            Task = 1,
            Loaded = 2,
            Client = 3,
            Spoon = 4,
            Pause = 5,
            Natural = 6,
            Subway = 7
        }
    }
}
