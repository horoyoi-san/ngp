using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AnantaTestGameServer.Methods.Return;

namespace AnantaTestGameServer.Methods
{
    // ======================== ASK ARGS (Client -> Server) ========================

    // Player boards a running metro train (from platform or mid-route).
    // Inferred fields: MetroInstanceId identifies which train (matches MetroClientInfo.Id),
    // CarriageIndex selects which car (0..N-1), BoardPosition local offset inside car.
    public class AskPlayerOnMetroArg : SerializedClass
    {
        public ulong MetroInstanceId;
        public int CarriageIndex;
        public UXVector3 BoardPosition;
    }

    // Player leaves the metro (voluntary exit at station or mid-route).
    public class AskPlayerLeaveMetroArg : SerializedClass
    {
        public ulong MetroInstanceId;
        public int CarriageIndex;
        public bool ForceExit;
    }

    // Player arrives at a station while still on the train.
    // StationIndex is per-line (0..N-1). Client uses this to trigger open-doors + UI.
    public class AskOnMetroEnterStationArg : SerializedClass
    {
        public ulong MetroInstanceId;
        public uint MetroLineId;
        public int StationIndex;
    }

    // Player's train departs the station.
    public class AskOnMetroExitStationArg : SerializedClass
    {
        public ulong MetroInstanceId;
        public uint MetroLineId;
        public int StationIndex;
    }

    // Client asks for the list of interactable gadgets inside the current carriage
    // (seats, doors, vending machines, etc). Returns MetroCarriageGadgetInfos.
    public class AskMetroGadgetIdsArg : SerializedClass
    {
        public ulong MetroInstanceId;
        public int CarriageIndex;
    }

    // ======================== NOTIFY / SYNC (Server -> Client) ========================

    // Server broadcasts an NPC being bound (attached) to a specific metro carriage.
    // The NPC then moves with the train until SyncUnbindNpcToMetro fires.
    public class SyncBindNpcToMetro : SerializedClass
    {
        public ulong NpcInstanceId;
        public ulong MetroInstanceId;
        public byte MetroCarriageIndex;
        public UXVector3 LocalOffset;

        public SyncBindNpcToMetro() : base()
        {
            onlyFields = true;
        }
    }

    // Server broadcasts an NPC being detached from a metro carriage.
    public class SyncUnbindNpcToMetro : SerializedClass
    {
        public ulong NpcInstanceId;
        public ulong MetroInstanceId;

        public SyncUnbindNpcToMetro() : base()
        {
            onlyFields = true;
        }
    }

    // Server spawns a new metro NPC mid-session (e.g. late-joining passenger).
    // Mirrors ClientMetroNpcInitData so the client can render it on the right carriage.
    public class SyncAetherAIMetroNpcAdd : SerializedClass
    {
        public uint NpcFormworkId;
        public ulong MetroInstanceId;
        public byte MetroCarriageIndex;
        public uint PoiActionId;
        public ulong Id;
        public UXVector3 Position;
        public float Facing;

        public SyncAetherAIMetroNpcAdd() : base()
        {
            onlyFields = true;
        }
    }

    // Server updates hide/show state of metro hide-areas (for stealth / cover mechanics).
    public class SyncHideMetroStates : SerializedClass
    {
        public List<MetroHideArea> HideAreas;

        public SyncHideMetroStates() : base()
        {
            onlyFields = true;
        }
    }

    // Server instructs client to destroy specific metro train instances (they left
    // the visible area, reached end of line, or were despawned).
    public class SyncDestroyMetroInfos : SerializedClass
    {
        public List<int> MetroIds;

        public SyncDestroyMetroInfos() : base()
        {
            onlyFields = true;
        }
    }
}
