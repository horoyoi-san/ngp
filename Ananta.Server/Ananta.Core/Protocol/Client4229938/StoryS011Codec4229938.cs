using Ananta.SDK.Serialization;

namespace Ananta.Server.Protocol.Client4229938;

internal static class StoryS011Codec4229938
{
    internal const string RootType = "StoryServer.Story.World.S011.S011PlayerNet";
    internal const string EnterChildType = "StoryServer.Story.World.S011.SVehicleEnterBoardingNet";
    internal const string ExitChildType = "StoryServer.Story.World.S011.SVehicleExitBoardingNet";

    private static readonly string[] RootMessengers =
    [
        "S011PlayerNetEnterVehicleRequest",
        "S011PlayerNetExitVehicleRequest",
        "S011PlayerNetForceEnterVehicleRequest",
        "S011PlayerNetForceExitVehicleRequest",
        "S011PlayerNetEnterVehicleIndoorRequest",
        "S011PlayerNetExitVehicleIndoorRequest",
        "S011PlayerNetForceShiftSeatRequest",
    ];

    
    internal static byte[] BuildRootBootstrap(uint rootNid, long confirmRpcId)
    {
        var w = new UxWriter();
        ListHeader(w, 4);

        Create(w, rootNid, RootType);
        Validate(w, rootNid, messengers: RootMessengers);
        EnableEmpty(w, rootNid);
        ConfirmRpc(w, confirmRpcId);
        return w.ToArray();
    }

    
    internal static byte[] BuildEnterChildBootstrap(uint childNid, ulong vehicleId, byte seat)
    {
        var w = new UxWriter();
        ListHeader(w, 3);

        Create(w, childNid, EnterChildType);
        Validate(w, childNid,
            replicables: ["vehicleEntityId", "seatIndex", "requisitionFailed"],
            messengers: ["MsgrChangePhaseRequest"]);

        var enable = new UxWriter();
        ListHeader(enable, 3);
        NamedPayload(enable, "vehicleEntityId", b => { PayloadTag(b, 44); b.U64(vehicleId); });
        NamedPayload(enable, "seatIndex", b => { PayloadTag(b, 12); b.I32(seat); });
        NamedPayload(enable, "requisitionFailed", b => { PayloadTag(b, 5); b.Bool(false); });
        Enable(w, childNid, enable.ToArray());
        return w.ToArray();
    }

    
    internal static byte[] BuildExitChildBootstrap(uint childNid, ulong vehicleId, byte seat, bool stopBeforeLeave)
    {
        var w = new UxWriter();
        ListHeader(w, 3);

        Create(w, childNid, ExitChildType);
        Validate(w, childNid,
            replicables: ["vehicleEntityId", "seatIndex", "StopBeforeLeave", "IsEscortExit"],
            messengers: ["MsgrChangePhaseRequest"]);

        var enable = new UxWriter();
        ListHeader(enable, 4);
        NamedPayload(enable, "vehicleEntityId", b => { PayloadTag(b, 44); b.U64(vehicleId); });
        NamedPayload(enable, "seatIndex", b => { PayloadTag(b, 12); b.I32(seat); });
        NamedPayload(enable, "StopBeforeLeave", b => { PayloadTag(b, 5); b.Bool(stopBeforeLeave); });
        NamedPayload(enable, "IsEscortExit", b => { PayloadTag(b, 5); b.Bool(false); });
        Enable(w, childNid, enable.ToArray());
        return w.ToArray();
    }

    
    internal static byte[] BuildConfirmRpc(long confirmRpcId)
    {
        var w = new UxWriter();
        ListHeader(w, 1);
        ConfirmRpc(w, confirmRpcId);
        return w.ToArray();
    }

    
    internal static byte[] BuildDeleteNode(uint nid)
    {
        var w = new UxWriter();
        ListHeader(w, 1);
        w.U8(4);   
        w.U32(nid);
        w.I64(0);  
        w.Bool(false);
        return w.ToArray();
    }

    private static void Create(UxWriter w, uint nid, string type)
    {
        w.U8(3);   
        w.U32(nid);
        w.UxString(type);
        w.UxString(string.Empty); 
        w.Bool(false); 
        w.I64(0);      
        w.Bool(false); 
    }

    private static void Validate(UxWriter w, uint nid, string[]? observables = null, string[]? replicables = null, string[]? messengers = null, string[]? syncReplicables = null)
    {
        w.U8(9);   
        w.U32(nid);
        StringList(w, observables);
        StringList(w, replicables);
        StringList(w, messengers);
        StringList(w, syncReplicables);
        w.I64(0);
        w.Bool(false);
    }

    private static void EnableEmpty(UxWriter w, uint nid)
    {
        w.U8(6);   
        w.U32(nid);
        w.U8(0);   
        w.U8(0);   
        w.U8(0);   
        w.I64(0);
        w.Bool(false);
    }

    private static void Enable(UxWriter w, uint nid, byte[] replicablesBody)
    {
        w.U8(6);
        w.U32(nid);
        w.U8(0);   
        w.Raw(replicablesBody);
        w.U8(0);   
        w.I64(0);
        w.Bool(false);
    }

    private static void ConfirmRpc(UxWriter w, long confirmRpcId)
    {
        w.U8(2);   
        w.I64(confirmRpcId);
        w.I64(0);  
        w.Bool(false);
    }

    private static void PayloadTag(UxWriter w, byte tag) => w.U8(tag);

    
    private static void NamedPayload(UxWriter w, string name, Action<UxWriter> writePayload)
    {
        w.U8(0xFF);
        w.UxString(name);
        writePayload(w);
    }

    private static void StringList(UxWriter w, string[]? values)
    {
        if (values is null) { w.U8(0); return; }
        w.U8(0xFF);
        WriteCount(w, values.Length);
        foreach (var v in values) w.UxString(v);
    }

    private static void ListHeader(UxWriter w, int count)
    {
        w.U8(0xFF);
        WriteCount(w, count);
    }

    
    private static void WriteCount(UxWriter w, int count) => w.Int7(count);
}
